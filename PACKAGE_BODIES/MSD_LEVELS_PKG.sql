--------------------------------------------------------
--  DDL for Package Body MSD_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_LEVELS_PKG" as
/* $Header: msdlpkgb.pls 120.1 2006/01/18 01:18:57 amitku noship $ */

PROCEDURE LOAD_ROW(
          x_level_id in varchar2,
          x_plan_type in varchar2,
          x_level_name varchar2,
          x_description varchar2,
          x_DIMENSION_CODE VARCHAR2,
          x_LEVEL_TYPE_CODE VARCHAR2,
          X_ORG_RELATIONSHIP_VIEW VARCHAR2,
          X_ATTRIBUTE1_CONTEXT VARCHAR2,
          X_ATTRIBUTE2_CONTEXT VARCHAR2,
          X_ATTRIBUTE3_CONTEXT VARCHAR2,
          X_ATTRIBUTE4_CONTEXT VARCHAR2,
          X_ATTRIBUTE5_CONTEXT VARCHAR2,
          X_ATTRIBUTE_CATEGORY VARCHAR2,
          X_ATTRIBUTE1 VARCHAR2,
          X_ATTRIBUTE2 VARCHAR2,
          X_ATTRIBUTE3 VARCHAR2,
          X_ATTRIBUTE4 VARCHAR2,
          X_ATTRIBUTE5 VARCHAR2,
          X_ATTRIBUTE6 VARCHAR2,
          X_ATTRIBUTE7 VARCHAR2,
          X_ATTRIBUTE8 VARCHAR2,
          X_ATTRIBUTE9 VARCHAR2,
          X_ATTRIBUTE10 VARCHAR2,
          X_ATTRIBUTE11 VARCHAR2,
          X_ATTRIBUTE12 VARCHAR2,
          X_ATTRIBUTE13 VARCHAR2,
          X_ATTRIBUTE14 VARCHAR2,
          X_ATTRIBUTE15 VARCHAR2,
          x_last_update_date in varchar2,
          x_owner in varchar2,
          x_custom_mode in varchar2,
          X_SYSTEM_ATTRIBUTE1_CONTEXT  VARCHAR2,
          X_SYSTEM_ATTRIBUTE2_CONTEXT  VARCHAR2) is

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
          from MSD_LEVELS
          where LEVEL_ID = to_number(x_level_id) and nvl(plan_type, -1)  = nvl( to_char(x_plan_type),-1) ;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update MSD_LEVELS set
             LEVEL_NAME = X_LEVEL_NAME,
             DESCRIPTION = X_DESCRIPTION,
             DIMENSION_CODE = X_DIMENSION_CODE,
             LEVEL_TYPE_CODE = X_LEVEL_TYPE_CODE,
             ORG_RELATIONSHIP_VIEW = X_ORG_RELATIONSHIP_VIEW,
             ATTRIBUTE1_CONTEXT = X_ATTRIBUTE1_CONTEXT,
             ATTRIBUTE2_CONTEXT = X_ATTRIBUTE2_CONTEXT,
             ATTRIBUTE3_CONTEXT = X_ATTRIBUTE3_CONTEXT,
             ATTRIBUTE4_CONTEXT = X_ATTRIBUTE4_CONTEXT,
             ATTRIBUTE5_CONTEXT = X_ATTRIBUTE5_CONTEXT,
             ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
             ATTRIBUTE1 = X_ATTRIBUTE1,
             ATTRIBUTE2 = X_ATTRIBUTE2,
             ATTRIBUTE3 = X_ATTRIBUTE3,
             ATTRIBUTE4 = X_ATTRIBUTE4,
             ATTRIBUTE5 = X_ATTRIBUTE5,
             ATTRIBUTE6 = X_ATTRIBUTE6,
             ATTRIBUTE7 = X_ATTRIBUTE7,
             ATTRIBUTE8 = X_ATTRIBUTE8,
             ATTRIBUTE9 = X_ATTRIBUTE9,
             ATTRIBUTE10 = X_ATTRIBUTE10,
             ATTRIBUTE11 = X_ATTRIBUTE11,
             ATTRIBUTE12 = X_ATTRIBUTE12,
             ATTRIBUTE13 = X_ATTRIBUTE13,
             ATTRIBUTE14 = X_ATTRIBUTE14,
             ATTRIBUTE15 = X_ATTRIBUTE15,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = f_luby,
             LAST_UPDATE_LOGIN = 0,
             SYSTEM_ATTRIBUTE1_CONTEXT = X_SYSTEM_ATTRIBUTE1_CONTEXT,
             SYSTEM_ATTRIBUTE2_CONTEXT = X_SYSTEM_ATTRIBUTE2_CONTEXT
            where LEVEL_ID = to_number(X_LEVEL_ID)and
                   nvl(  PLAN_TYPE, -1) = nvl ( x_plan_type , -1) ;

          else

            update MSD_LEVELS set
             ORG_RELATIONSHIP_VIEW = X_ORG_RELATIONSHIP_VIEW,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = f_luby,
             LAST_UPDATE_LOGIN = 0
            where LEVEL_ID = to_number(X_LEVEL_ID)
               and nvl(  PLAN_TYPE, -1) = nvl(  x_plan_type , -1) ;

          end if;

        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into MSD_LEVELS (
              LEVEL_ID,
              PLAN_TYPE,
              LEVEL_NAME,
              DESCRIPTION,
              DIMENSION_CODE,
              LEVEL_TYPE_CODE,
              ORG_RELATIONSHIP_VIEW,
              ATTRIBUTE1_CONTEXT,
              ATTRIBUTE2_CONTEXT,
              ATTRIBUTE3_CONTEXT,
              ATTRIBUTE4_CONTEXT,
              ATTRIBUTE5_CONTEXT,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              SYSTEM_ATTRIBUTE1_CONTEXT,
              SYSTEM_ATTRIBUTE2_CONTEXT
            ) values (
              to_number(X_LEVEL_ID),
              X_PLAN_TYPE,
              X_LEVEL_NAME,
              X_DESCRIPTION,
              X_DIMENSION_CODE,
              X_LEVEL_TYPE_CODE,
              X_ORG_RELATIONSHIP_VIEW,
              X_ATTRIBUTE1_CONTEXT,
              X_ATTRIBUTE2_CONTEXT,
              X_ATTRIBUTE3_CONTEXT,
              X_ATTRIBUTE4_CONTEXT,
              X_ATTRIBUTE5_CONTEXT,
              X_ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1,
              X_ATTRIBUTE2,
              X_ATTRIBUTE3,
              X_ATTRIBUTE4,
              X_ATTRIBUTE5,
              X_ATTRIBUTE6,
              X_ATTRIBUTE7,
              X_ATTRIBUTE8,
              X_ATTRIBUTE9,
              X_ATTRIBUTE10,
              X_ATTRIBUTE11,
              X_ATTRIBUTE12,
              X_ATTRIBUTE13,
              X_ATTRIBUTE14,
              X_ATTRIBUTE15,
              f_ludate,
              f_luby,
              f_ludate,
              f_luby,
              0,
              X_SYSTEM_ATTRIBUTE1_CONTEXT,
              X_SYSTEM_ATTRIBUTE2_CONTEXT);
        end;
     end LOAD_ROW;


PROCEDURE TRANSLATE_ROW(
        x_level_id in varchar2,
        x_plan_type in varchar2,
        x_level_name varchar2,
        x_description varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2,
        x_custom_mode in varchar2) is

        secgrp_id number;
        view_appid number;
        owner_id number;
        ludate date;
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

        --
        -- update the translation
        --
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_levels
          where level_id = to_number(x_level_id) and nvl( PLAN_TYPE, -1) = nvl(  x_plan_type , -1) ;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update msd_levels
            set
              level_name = nvl(x_level_name, level_name),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0
            where level_id = to_number(x_level_id)
              and nvl( plan_type, -1) = nvl(  x_plan_type , -1)
              and userenv('LANG') = (select language_code
                                      from FND_LANGUAGES
                                      where installed_flag = 'B');
          end if;
        EXCEPTION
          when no_data_found then null;
        end;
     end TRANSLATE_ROW;

end MSD_LEVELS_PKG;

/
