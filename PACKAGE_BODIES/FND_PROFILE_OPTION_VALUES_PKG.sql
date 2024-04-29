--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_OPTION_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_OPTION_VALUES_PKG" as
/* $Header: AFPOMPVB.pls 120.2.12010000.1 2008/07/25 14:19:48 appldev ship $ */

   function GET_HIERARCHY_TYPE(
      X_PROFILE_OPTION_ID in NUMBER,
      X_APPLICATION_ID in NUMBER)
   return varchar2 is
         L_HIERARCHY_TYPE VARCHAR2(8);
   begin

      select HIERARCHY_TYPE
      into L_HIERARCHY_TYPE
      from FND_PROFILE_OPTIONS
      where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
      and APPLICATION_ID = X_APPLICATION_ID;

      if SQL%NOTFOUND then
         raise no_data_found;
      end if;

      return L_HIERARCHY_TYPE;

   end GET_HIERARCHY_TYPE;

   /* This procedure is used to insert a row into fnd_profile_option_values.
   ** Due to the nature of profile option values having levels and granular
   ** values associated to its levels, this routine distinguishes between
   ** these levels to ensure data integrity.
   */
   procedure INSERT_ROW (
      X_ROWID in out nocopy VARCHAR2,
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_CREATION_DATE in DATE,
      X_CREATED_BY in NUMBER,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER,
      X_PROFILE_OPTION_VALUE in VARCHAR2,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_LEVEL_VALUE2 in NUMBER
   ) is

      -- Site level cursor
      cursor S is select ROWID from FND_PROFILE_OPTION_VALUES
      where APPLICATION_ID = X_APPLICATION_ID
      and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
      and LEVEL_ID = X_LEVEL_ID
      and LEVEL_VALUE = 0;

      -- Application/Server/Org level cursor
      cursor ARSO is select ROWID from FND_PROFILE_OPTION_VALUES
      where APPLICATION_ID = X_APPLICATION_ID
      and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
      and LEVEL_ID = X_LEVEL_ID
      and LEVEL_VALUE = X_LEVEL_VALUE
      and LEVEL_VALUE_APPLICATION_ID is null
      and LEVEL_VALUE2 is null;

      -- Responsibility level cursor
      cursor R is select ROWID from FND_PROFILE_OPTION_VALUES
      where APPLICATION_ID = X_APPLICATION_ID
      and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
      and LEVEL_ID = X_LEVEL_ID
      and LEVEL_VALUE = X_LEVEL_VALUE
      and LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID
      and LEVEL_VALUE2 is null;

      -- ServResp level cursor
      cursor SR is select ROWID from FND_PROFILE_OPTION_VALUES
      where APPLICATION_ID = X_APPLICATION_ID
      and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
      and LEVEL_ID = X_LEVEL_ID
      and LEVEL_VALUE = X_LEVEL_VALUE
      and LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID
      and LEVEL_VALUE2 = X_LEVEL_VALUE2;

      L_HIERARCHY_TYPE VARCHAR2(8);
      L_PROFILE_OPTION_NAME VARCHAR2(80);
      profile_option_value_too_large EXCEPTION;

   begin

      -- If profile option value being set is > 240 characters, then raise the
      -- profile_option_value_too_large exception.
      if length(X_PROFILE_OPTION_VALUE) > 240 then
         raise profile_option_value_too_large;
      end if;

      L_HIERARCHY_TYPE := FND_PROFILE_OPTION_VALUES_PKG.GET_HIERARCHY_TYPE
         (X_PROFILE_OPTION_ID, X_APPLICATION_ID);

   /* Being conservative here and wanting to make sure that levels get
      profile option values inserted correctly.  For example, if, by some
      chance that, a site-level profile option value is being inserted with
      a non-null level_value (which does not apply), the level_value is
      overriden as well as any other non-applicable columns on insertion.
   */

      if (X_LEVEL_ID = 10001) then
         -- Site level
         insert into FND_PROFILE_OPTION_VALUES (
            APPLICATION_ID,
            PROFILE_OPTION_ID,
            LEVEL_ID,
            LEVEL_VALUE,
            LEVEL_VALUE_APPLICATION_ID,
            PROFILE_OPTION_VALUE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            LEVEL_VALUE2
         ) values (
            X_APPLICATION_ID,
            X_PROFILE_OPTION_ID,
            X_LEVEL_ID,
            0,    -- LEVEL_VALUE = 0 for Site level
            NULL, -- LEVEL_VALUE_APPLICATION_ID is not applicable
            X_PROFILE_OPTION_VALUE,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
            X_CREATION_DATE,
            X_CREATED_BY,
            NULL  -- LEVEL_VALUE2 is not applicable
         );

         open S;
         fetch S into X_ROWID;
         if (S%notfound) then
            close S;
            raise no_data_found;
         end if;
         close S;

      elsif (X_LEVEL_ID = 10007 and L_HIERARCHY_TYPE = 'SERVRESP') then
         -- ServResp level
         insert into FND_PROFILE_OPTION_VALUES (
            APPLICATION_ID,
            PROFILE_OPTION_ID,
            LEVEL_ID,
            LEVEL_VALUE,
            LEVEL_VALUE_APPLICATION_ID,
            PROFILE_OPTION_VALUE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            LEVEL_VALUE2
         ) values (
            X_APPLICATION_ID,
            X_PROFILE_OPTION_ID,
            X_LEVEL_ID,
            X_LEVEL_VALUE,
            X_LEVEL_VALUE_APPLICATION_ID,
            X_PROFILE_OPTION_VALUE,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
            X_CREATION_DATE,
            X_CREATED_BY,
            X_LEVEL_VALUE2
         );

         open SR;
         fetch SR into X_ROWID;
         if (SR%notfound) then
            close SR;
            raise no_data_found;
         end if;
         close SR;

      elsif ((X_LEVEL_ID = 10006 and L_HIERARCHY_TYPE = 'ORG') or
         (X_LEVEL_ID = 10005 and L_HIERARCHY_TYPE = 'SERVER') or
         (X_LEVEL_ID = 10004) or
         (X_LEVEL_ID = 10002 and L_HIERARCHY_TYPE = 'SECURITY')) then
         -- Appl/Resp/Server/Org levels
         insert into FND_PROFILE_OPTION_VALUES (
            APPLICATION_ID,
            PROFILE_OPTION_ID,
            LEVEL_ID,
            LEVEL_VALUE,
            LEVEL_VALUE_APPLICATION_ID,
            PROFILE_OPTION_VALUE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            LEVEL_VALUE2
         ) values (
            X_APPLICATION_ID,
            X_PROFILE_OPTION_ID,
            X_LEVEL_ID,
            X_LEVEL_VALUE,
            NULL,
            X_PROFILE_OPTION_VALUE,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
            X_CREATION_DATE,
            X_CREATED_BY,
            NULL  -- LEVEL_VALUE2 is not applicable
         );

         open ARSO;
         fetch ARSO into X_ROWID;
         if (ARSO%notfound) then
            close ARSO;
            raise no_data_found;
         end if;
         close ARSO;

      elsif (X_LEVEL_ID = 10003 and L_HIERARCHY_TYPE = 'SECURITY') then

         -- Resp level
         insert into FND_PROFILE_OPTION_VALUES (
            APPLICATION_ID,
            PROFILE_OPTION_ID,
            LEVEL_ID,
            LEVEL_VALUE,
            LEVEL_VALUE_APPLICATION_ID,
            PROFILE_OPTION_VALUE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            LEVEL_VALUE2
         ) values (
            X_APPLICATION_ID,
            X_PROFILE_OPTION_ID,
            X_LEVEL_ID,
            X_LEVEL_VALUE,
            X_LEVEL_VALUE_APPLICATION_ID,
            X_PROFILE_OPTION_VALUE,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
            X_CREATION_DATE,
            X_CREATED_BY,
            NULL  -- LEVEL_VALUE2 is not applicable
         );

         open R;
         fetch R into X_ROWID;
         if (R%notfound) then
            close R;
            raise no_data_found;
         end if;
         close R;

      end if;
   exception
      when profile_option_value_too_large then

         select PROFILE_OPTION_NAME
         into L_PROFILE_OPTION_NAME
         from FND_PROFILE_OPTIONS
         where APPLICATION_ID = X_APPLICATION_ID
         and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID;

         fnd_message.set_name('FND', 'FND_PROFILE_OPTION_VAL_TOO_LRG');
         fnd_message.set_token('PROFILE_OPTION_NAME', L_PROFILE_OPTION_NAME);
         fnd_message.set_token('PROFILE_OPTION_VALUE', X_PROFILE_OPTION_VALUE);
         app_exception.raise_exception;

   end INSERT_ROW;

   /* This procedure is used to update profile option values at a given level,
    * (if it applies).  If the profile fails to update, it means that there is
    * no row to update.  If that occurs, INSERT_ROW is called to insert the
    * profile option value.
    */
   procedure UPDATE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_LEVEL_VALUE2 in NUMBER,
      X_PROFILE_OPTION_VALUE in VARCHAR2,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
   ) is

      L_ROWID varchar2(20);
      L_HIERARCHY_TYPE VARCHAR2(8);
      L_PROFILE_OPTION_NAME VARCHAR2(80);
      profile_option_value_too_large EXCEPTION;

   begin

      -- If profile option value being set is > 240 characters, then raise the
      -- profile_option_value_too_large exception.
      if length(X_PROFILE_OPTION_VALUE) > 240 then
         raise profile_option_value_too_large;
      end if;

      L_HIERARCHY_TYPE := FND_PROFILE_OPTION_VALUES_PKG.GET_HIERARCHY_TYPE
         (X_PROFILE_OPTION_ID, X_APPLICATION_ID);

      if (X_LEVEL_ID = 10007 and L_HIERARCHY_TYPE = 'SERVRESP') then
        /* ServResp U P D A T E */
        update FND_PROFILE_OPTION_VALUES
        set    PROFILE_OPTION_VALUE = X_PROFILE_OPTION_VALUE,
               LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN
        where  PROFILE_OPTION_ID    = X_PROFILE_OPTION_ID
        and    APPLICATION_ID       = X_APPLICATION_ID
        and    LEVEL_ID             = X_LEVEL_ID
        and    LEVEL_VALUE          = X_LEVEL_VALUE
        and    LEVEL_VALUE2         = X_LEVEL_VALUE2
        and    (nvl(X_LEVEL_VALUE_APPLICATION_ID, -1) = -1
                or LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID);
      elsif ((X_LEVEL_ID = 10006 and L_HIERARCHY_TYPE = 'ORG') or
         (X_LEVEL_ID = 10005 and L_HIERARCHY_TYPE = 'SERVER') or
         (X_LEVEL_ID = 10004) or
         (X_LEVEL_ID = 10003 and L_HIERARCHY_TYPE = 'SECURITY') or
         (X_LEVEL_ID = 10002 and L_HIERARCHY_TYPE = 'SECURITY') or
         (X_LEVEL_ID = 10001)) then
        /* U P D A T E */
        update FND_PROFILE_OPTION_VALUES
        set    PROFILE_OPTION_VALUE = X_PROFILE_OPTION_VALUE,
               LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN
        where  PROFILE_OPTION_ID    = X_PROFILE_OPTION_ID
        and    APPLICATION_ID       = X_APPLICATION_ID
        and    LEVEL_ID             = X_LEVEL_ID
        and    LEVEL_VALUE          = X_LEVEL_VALUE
        and    (nvl(X_LEVEL_VALUE_APPLICATION_ID, -1) = -1
                or LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID);
      end if;

      if SQL%NOTFOUND then
        /* I N S E R T */
        FND_PROFILE_OPTION_VALUES_PKG.INSERT_ROW(
          L_ROWID,
          X_APPLICATION_ID,
          X_PROFILE_OPTION_ID,
          X_LEVEL_ID,
          X_LEVEL_VALUE,
          sysdate,           -- X_CREATION_DATE
          X_LAST_UPDATED_BY, -- X_CREATED_BY
          sysdate,           -- X_LAST_UPDATE_DATE
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN,
          X_PROFILE_OPTION_VALUE,
          X_LEVEL_VALUE_APPLICATION_ID,
          X_LEVEL_VALUE2
        );
      end if;
   exception
      when profile_option_value_too_large then

         select PROFILE_OPTION_NAME
         into L_PROFILE_OPTION_NAME
         from FND_PROFILE_OPTIONS
         where APPLICATION_ID = X_APPLICATION_ID
         and PROFILE_OPTION_ID = X_PROFILE_OPTION_ID;

         fnd_message.set_name('FND', 'FND_PROFILE_OPTION_VAL_TOO_LRG');
         fnd_message.set_token('PROFILE_OPTION_NAME', L_PROFILE_OPTION_NAME);
         fnd_message.set_token('PROFILE_OPTION_VALUE', X_PROFILE_OPTION_VALUE);
         app_exception.raise_exception;

   end UPDATE_ROW;

   /* Overloaded UPDATE_ROW */
   procedure UPDATE_ROW(
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_VALUE in VARCHAR2,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
   ) is

   begin

      if (X_LEVEL_ID <> 10007) then
        /* Call UPDATE_ROW passing NULL for LEVEL_VALUE2 if
           level_id <> 10007
         */
         UPDATE_ROW(
            X_APPLICATION_ID,
            X_PROFILE_OPTION_ID,
            X_LEVEL_ID,
            X_LEVEL_VALUE,
            X_LEVEL_VALUE_APPLICATION_ID,
            NULL,
            X_PROFILE_OPTION_VALUE,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN);
      end if;

   end UPDATE_ROW;

   procedure DELETE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_LEVEL_VALUE2 in NUMBER
   ) is

      L_HIERARCHY_TYPE VARCHAR2(8);

   begin

      L_HIERARCHY_TYPE := FND_PROFILE_OPTION_VALUES_PKG.GET_HIERARCHY_TYPE
         (X_PROFILE_OPTION_ID, X_APPLICATION_ID);

      if (X_LEVEL_ID = 10007 and L_HIERARCHY_TYPE = 'SERVRESP') then

         /* ServResp D E L E T E */
         delete from FND_PROFILE_OPTION_VALUES
         where  PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
         and    APPLICATION_ID    = X_APPLICATION_ID
         and    LEVEL_ID          = X_LEVEL_ID
         and    LEVEL_VALUE       = X_LEVEL_VALUE
         and    LEVEL_VALUE2      = X_LEVEL_VALUE2
         and    (nvl(X_LEVEL_VALUE_APPLICATION_ID, -1) = -1
         or LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID);

      elsif ((X_LEVEL_ID = 10006 and L_HIERARCHY_TYPE = 'ORG') or
         (X_LEVEL_ID = 10005 and L_HIERARCHY_TYPE = 'SERVER') or
         (X_LEVEL_ID = 10004) or
         (X_LEVEL_ID = 10002 and L_HIERARCHY_TYPE = 'SECURITY') or
         (X_LEVEL_ID = 10001)) then

         /* D E L E T E */
         delete from FND_PROFILE_OPTION_VALUES
         where  PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
         and    APPLICATION_ID    = X_APPLICATION_ID
         and    LEVEL_ID          = X_LEVEL_ID
         and    LEVEL_VALUE       = X_LEVEL_VALUE
         and    (nvl(X_LEVEL_VALUE_APPLICATION_ID, -1) = -1
         or LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID);

      elsif (X_LEVEL_ID = 10003 and L_HIERARCHY_TYPE = 'SECURITY') then

         /* D E L E T E */
         delete from FND_PROFILE_OPTION_VALUES
         where  PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
         and    APPLICATION_ID    = X_APPLICATION_ID
         and    LEVEL_ID          = X_LEVEL_ID
         and    LEVEL_VALUE       = X_LEVEL_VALUE
         and    (nvl(X_LEVEL_VALUE_APPLICATION_ID, -1) = -1
         or LEVEL_VALUE_APPLICATION_ID = X_LEVEL_VALUE_APPLICATION_ID);

      end if;

      if (SQL%NOTFOUND) then
        raise NO_DATA_FOUND;
      end if;

   end DELETE_ROW;

   /* Overloaded DELETE_ROW */
   procedure DELETE_ROW(
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER
   ) is

   begin

      if (X_LEVEL_ID <> 10007) then
        /* Call DELETE_ROW passing NULL for LEVEL_VALUE2 if
           level_id <> 10007
         */
        DELETE_ROW (
           X_APPLICATION_ID,
           X_PROFILE_OPTION_ID,
           X_LEVEL_ID,
           X_LEVEL_VALUE,
           X_LEVEL_VALUE_APPLICATION_ID,
           NULL);
      end if;

   end DELETE_ROW;

   /* This procedure is only going to be called from
    * FND_PROFILE_OPTIONS_PKG.DELETE_ROW which deletes profile option
    * definitions.  This procedure ensures that there will be no dangling
    * references in FND_PROFILE_OPTION_VALUES to the profile option being
    * deleted, i.e. if a profile is being deleted, it should have no rows
    * for profile option values.
    */
   procedure DELETE_PROFILE_OPTION_VALUES (X_PROFILE_OPTION_NAME in VARCHAR2) is
      L_PROFILE_OPTION_ID number;
      L_APPLICATION_ID number;
   begin
      -- Obtain the profile_option_id and application_id of the profile
      -- option being deleted using the profile option name.
      select profile_option_id, application_id
      into L_PROFILE_OPTION_ID, L_APPLICATION_ID
      from fnd_profile_options
      where profile_option_name = X_PROFILE_OPTION_NAME;

      -- If the given profile option does not exist, then raise no_data_found;
      if (SQL%NOTFOUND) then
        raise NO_DATA_FOUND;
      end if;

      -- Delete all rows with the profile_option_id, application_id
      -- combination
      delete from fnd_profile_option_values
      where profile_option_id = L_PROFILE_OPTION_ID
      and application_id = L_APPLICATION_ID;

      -- It is possible for a profile option to not have any profile option
      -- values.  So if the delete raises SQL%NOTFOUND, it is
      -- transparently handled.
      if (SQL%NOTFOUND) then
        NULL;
      end if;

   end DELETE_PROFILE_OPTION_VALUES;

end FND_PROFILE_OPTION_VALUES_PKG;

/
