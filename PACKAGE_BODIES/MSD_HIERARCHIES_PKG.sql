--------------------------------------------------------
--  DDL for Package Body MSD_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_HIERARCHIES_PKG" as
/* $Header: msdhpkgb.pls 120.0 2005/05/25 20:40:47 appldev noship $ */
PROCEDURE LOAD_ROW(
          X_HIERARCHY_ID    varchar2,
          X_PLAN_TYPE   varchar2,--- Added to include PLAN_TYPE
          X_HIERARCHY_NAME  varchar2,
          X_DESCRIPTION     varchar2,
          X_DIMENSION_CODE  varchar2,
          X_VALID_FLAG      varchar2,
          X_ATTRIBUTE_CATEGORY  varchar2,
          X_ATTRIBUTE1 varchar2,
          X_ATTRIBUTE2 varchar2,
          X_ATTRIBUTE3 varchar2,
          X_ATTRIBUTE4 varchar2,
          X_ATTRIBUTE5 varchar2,
          X_ATTRIBUTE6 varchar2,
          X_ATTRIBUTE7 varchar2,
          X_ATTRIBUTE8 varchar2,
          X_ATTRIBUTE9 varchar2,
          X_ATTRIBUTE10 varchar2,
          X_ATTRIBUTE11 varchar2,
          X_ATTRIBUTE12 varchar2,
          X_ATTRIBUTE13 varchar2,
          X_ATTRIBUTE14 varchar2,
          X_ATTRIBUTE15 varchar2,
          x_last_update_date in varchar2,
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
          from MSD_HIERARCHIES
          where HIERARCHY_ID = to_number(x_HIERARCHY_id)
          and nvl(plan_type,-1) = nvl(to_char(x_plan_type),-1) ;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update MSD_HIERARCHIES set
             HIERARCHY_NAME = X_HIERARCHY_NAME,
             DESCRIPTION = X_DESCRIPTION,
             DIMENSION_CODE = X_DIMENSION_CODE,
             VALID_FLAG = to_number(X_VALID_FLAG),
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
             LAST_UPDATE_LOGIN = 0
            where HIERARCHY_ID = to_number(X_HIERARCHY_ID) and
           nvl( plan_type , -1)  =nvl(  to_char( x_plan_type) , -1);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into MSD_HIERARCHIES (
              HIERARCHY_ID,
              PLAN_TYPE,
              HIERARCHY_NAME,
              DESCRIPTION,
              DIMENSION_CODE,
              VALID_FLAG,
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
              LAST_UPDATE_LOGIN
            ) values (
              to_number(X_HIERARCHY_ID),
              to_char(X_PLAN_TYPE),
              X_HIERARCHY_NAME,
              X_DESCRIPTION,
              X_DIMENSION_CODE,
              to_number(X_VALID_FLAG),
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
              0);
        end;
     end LOAD_ROW;


PROCEDURE TRANSLATE_ROW(
        x_hierarchy_id in varchar2,
        x_plan_type in varchar2,
        x_hierarchy_name varchar2,
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
          from MSD_HIERARCHIES
          where HIERARCHY_id = to_number(x_HIERARCHY_id) and
           nvl(plan_type,-1) =nvl(  to_char(x_plan_type),-1) ;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update MSD_HIERARCHIES
            set
              HIERARCHY_name = nvl(x_HIERARCHY_name, HIERARCHY_name),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0
            where HIERARCHY_id = to_number(x_HIERARCHY_id)
             and nvl( plan_type ,-1)= nvl( to_char(x_plan_type) , -1)
              and userenv('LANG') = (select language_code
                                      from FND_LANGUAGES
                                      where installed_flag = 'B');
          end if;
        EXCEPTION
          when no_data_found then null;
        end;
     end TRANSLATE_ROW;


PROCEDURE LOAD_HIERARCHY_LEVEL_ROW(
        x_HIERARCHY_ID in varchar2,
        x_plan_type in varchar2,
        x_LEVEL_ID in varchar2,
        x_PARENT_LEVEL_ID in varchar2,
        x_RELATIONSHIP_VIEW in varchar2,
        x_LEVEL_VALUE_COLUMN in varchar2,
        x_LEVEL_VALUE_PK_COLUMN in varchar2,
        x_LEVEL_VALUE_DESC_COLUMN in varchar2,
        x_PARENT_VALUE_COLUMN in varchar2,
        x_PARENT_VALUE_PK_COLUMN in varchar2,
        x_PARENT_VALUE_DESC_COLUMN in varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2,
        x_custom_mode in varchar2) IS

        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
        h_mod     number;  -- was any hierarchy level modified?

    begin
         -- Translate owner to file_last_updated_by
         if (x_owner = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

        -- check if any hierarchy levels exist that were updated by !seed
        begin
          select 1 into h_mod from dual
          where exists(select 1 from msd_hierarchy_levels
                       where hierarchy_id = to_number(x_HIERARCHY_id)
                           and nvl( plan_type,-1) = nvl( to_char(x_plan_type),-1)
                         and last_updated_by <> 1);
        exception
          when no_data_found then
            h_mod := 0;
        end;

        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from MSD_HIERARCHY_LEVELS
          where HIERARCHY_ID = to_number(x_HIERARCHY_id)
            and level_id = to_number(x_level_id)
            and parent_level_id = to_number(x_parent_level_id)
            and nvl( plan_type,-1) = nvl( to_char(x_plan_type),-1) ;


          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((x_custom_mode = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            update MSD_HIERARCHY_LEVELS set
             relationship_view = x_RELATIONSHIP_VIEW,
             level_value_column = x_LEVEL_VALUE_COLUMN,
             level_value_pk_column = x_LEVEL_VALUE_PK_COLUMN,
             level_value_desc_column = x_LEVEL_VALUE_DESC_COLUMN,
             parent_value_column = x_PARENT_VALUE_COLUMN,
             parent_value_pk_column = x_PARENT_VALUE_PK_COLUMN,
             parent_value_desc_column = x_PARENT_VALUE_DESC_COLUMN,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = f_luby,
             LAST_UPDATE_LOGIN = 0
            where HIERARCHY_ID = to_number(X_HIERARCHY_ID)
              and level_id = to_number(x_level_id)
              and parent_level_id = to_number(x_parent_level_id)
              and nvl(plan_type,-1) = nvl(to_char(x_plan_type),-1) ;
          end if;
        EXCEPTION
          when no_data_found then
            /* Record doesn't exist - do not insert if the hierarchy has
               been modified and the file owner is seed unless running
               in FORCE mode */
            if ((x_custom_mode = 'FORCE') or
                 not(h_mod = 1 and x_owner = 'SEED'))
            then
                /* do not insert if hierarchy is complete unless
                   running in FORCE mode */
                if ((x_custom_mode = 'FORCE') or
                     not(is_hierarchy_complete(to_number(X_HIERARCHY_ID),to_char(x_plan_type))))
                then
                   insert into MSD_HIERARCHY_LEVELS(
                   HIERARCHY_ID,
                   PLAN_TYPE ,
                   LEVEL_ID,
                   PARENT_LEVEL_ID,
                   RELATIONSHIP_VIEW,
                   LEVEL_VALUE_COLUMN,
                   LEVEL_VALUE_PK_COLUMN,
                   level_value_desc_column,
                   PARENT_VALUE_COLUMN,
                   PARENT_VALUE_PK_COLUMN,
                   parent_value_desc_column,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN
                 ) SELECT
                   to_number(X_HIERARCHY_ID),
                   to_char(X_PLAN_TYPE) ,
                   to_number(X_LEVEL_ID),
                   to_number(X_PARENT_LEVEL_ID),
                   X_RELATIONSHIP_VIEW,
                   X_LEVEL_VALUE_COLUMN,
                   X_LEVEL_VALUE_PK_COLUMN,
                   x_level_value_desc_column,
                   X_PARENT_VALUE_COLUMN,
                   X_PARENT_VALUE_PK_COLUMN,
                   x_parent_value_desc_column,
                   f_ludate,
                   f_luby,
                   f_ludate,
                   f_luby,
                   0
                   FROM dual
                   WHERE
                   (x_custom_mode = 'FORCE')
                   OR
                   (
                   /* child level does not already have a parent */
                   not exists(select level_id from msd_hierarchy_levels
                               where HIERARCHY_ID = to_number(x_HIERARCHY_id)
                                 and nvl(plan_type,-1)  =nvl( to_char(x_plan_type),-1)
                                 and level_id = to_number(x_level_id))
                   AND
                   /* parent level does not already have a child */
                   not exists(select level_id from msd_hierarchy_levels
                               where HIERARCHY_ID = to_number(x_HIERARCHY_id)
                                 and nvl(plan_type,-1)  =nvl( to_char(x_plan_type),-1)
                                 and parent_level_id = to_number(x_parent_level_id))
                   AND
                   /* child level is not topmost */
                   not exists(select level_id from msd_levels
                              where level_id = to_number(x_level_id)
                                and level_type_code = '1'
                                and nvl(plan_type,-1)  =nvl( to_char(x_plan_type),-1) )
                   AND
                   /* parent level is not bottom-most */
                   not exists(select level_id from msd_levels
                              where level_id = to_number(x_parent_level_id)
                                and level_type_code = '2'
                                and nvl(plan_type,-1)  =nvl( to_char(x_plan_type),-1) )
                   );
                end if;
            end if;
        end;
     END LOAD_HIERARCHY_LEVEL_ROW;


function is_hierarchy_complete(hid number, p_plan_type varchar2 ) return boolean is

  lvl  number;
  lvl_type msd_levels.level_type_code%TYPE;
  hcount number;
  ctr number := 0;

begin
  /* get bound on hierarchy levels */
  select count(*)
  into hcount
  from msd_hierarchy_levels
  where hierarchy_id = hid
  and nvl(plan_type,-1) =nvl( p_plan_type,-1) ;

  /* get bottom level */
  begin
    select l.level_id
    into lvl
    from msd_levels l, msd_hierarchies h
    where h.hierarchy_id = hid
      and l.dimension_code = h.dimension_code
      and l.level_type_code = 2
      and nvl(h.plan_type,-1) = nvl( p_plan_type,-1)
      and nvl( l.plan_type,-1) = nvl(p_plan_type,-1) ;

  EXCEPTION
    when NO_DATA_FOUND then
      return false;
  end;

  /* try to loop until top level is reached */
  loop

    ctr := ctr+1;

    /* get parent of level in this hierarchy */
    begin
      select l.level_id, l.level_type_code
      into lvl, lvl_type
      from msd_hierarchy_levels mhl, msd_levels l
      where mhl.level_id = lvl
        and mhl.hierarchy_id = hid
        and mhl.parent_level_id = l.level_id
        and nvl(mhl.plan_type,-1) = nvl( p_plan_type,-1)
        and nvl( l.plan_type,-1)  = nvl( p_plan_type,-1) ;

      EXCEPTION
        when NO_DATA_FOUND then
          return false;
    end;

    /* is this the top level? */
    if (lvl_type = '1') then
      return true;
    end if;

    /* does hierarchy have a loop? */
    if (ctr > hcount) then
      return false;
    end if;
  end loop;

end is_hierarchy_complete;

end MSD_HIERARCHIES_PKG;

/
