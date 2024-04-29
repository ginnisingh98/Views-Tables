--------------------------------------------------------
--  DDL for Package Body JTF_UM_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_SUBSCRIPTIONS_PKG" as
/* $Header: JTFUMSBB.pls 120.4 2006/01/16 01:26:40 vimohan ship $ */
MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_SUBSCRIPTIONS_PKG';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);

procedure INSERT_ROW (
  X_SUBSCRIPTION_ID out NOCOPY NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER
  )
 is
  cursor C is select ROWID from JTF_UM_SUBSCRIPTIONS_B
    where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
    ;

begin
  insert into JTF_UM_SUBSCRIPTIONS_B (
    APPLICATION_ID,
    EFFECTIVE_START_DATE,
    SUBSCRIPTION_ID,
    SUBSCRIPTION_KEY,
    ENABLED_FLAG,
    EFFECTIVE_END_DATE,
    APPROVAL_ID,
    PARENT_SUBSCRIPTION_ID,
    AVAILABILITY_CODE,
    LOGON_DISPLAY_FREQUENCY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    AUTH_DELEGATION_ROLE_ID
  ) values (
    X_APPLICATION_ID,
    X_EFFECTIVE_START_DATE,
    JTF_UM_SUBSCRIPTIONS_B_S.NEXTVAL,
    X_SUBSCRIPTION_KEY,
    X_ENABLED_FLAG,
    X_EFFECTIVE_END_DATE,
    X_APPROVAL_ID,
    X_PARENT_SUBSCRIPTION_ID,
    X_AVAILABILITY_CODE,
    X_LOGON_DISPLAY_FREQUENCY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_AUTH_DELEGATION_ROLE_ID
  )RETURNING SUBSCRIPTION_ID INTO X_SUBSCRIPTION_ID;

  insert into JTF_UM_SUBSCRIPTIONS_TL (
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    DESCRIPTION,
    APPLICATION_ID,
    SUBSCRIPTION_ID,
    SUBSCRIPTION_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_DESCRIPTION,
    X_APPLICATION_ID,
    X_SUBSCRIPTION_ID,
    X_SUBSCRIPTION_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_UM_SUBSCRIPTIONS_TL T
    where T.SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER
) is
  cursor c is select
      APPLICATION_ID,
      EFFECTIVE_START_DATE,
      SUBSCRIPTION_KEY,
      ENABLED_FLAG,
      EFFECTIVE_END_DATE,
      APPROVAL_ID,
      PARENT_SUBSCRIPTION_ID,
      AVAILABILITY_CODE,
      LOGON_DISPLAY_FREQUENCY,
      AUTH_DELEGATION_ROLE_ID
    from JTF_UM_SUBSCRIPTIONS_B
    where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
    for update of SUBSCRIPTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SUBSCRIPTION_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_UM_SUBSCRIPTIONS_TL
    where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SUBSCRIPTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND (recinfo.SUBSCRIPTION_KEY = X_SUBSCRIPTION_KEY)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE)
           OR ((recinfo.EFFECTIVE_END_DATE is null) AND (X_EFFECTIVE_END_DATE is null)))
      AND ((recinfo.APPROVAL_ID = X_APPROVAL_ID)
           OR ((recinfo.APPROVAL_ID is null) AND (X_APPROVAL_ID is null)))
      AND ((recinfo.PARENT_SUBSCRIPTION_ID = X_PARENT_SUBSCRIPTION_ID)
           OR ((recinfo.PARENT_SUBSCRIPTION_ID is null) AND (X_PARENT_SUBSCRIPTION_ID is null)))
      AND ((recinfo.AVAILABILITY_CODE = X_AVAILABILITY_CODE)
           OR ((recinfo.AVAILABILITY_CODE is null) AND (X_AVAILABILITY_CODE is null)))
      AND ((recinfo.LOGON_DISPLAY_FREQUENCY = X_LOGON_DISPLAY_FREQUENCY)
           OR ((recinfo.LOGON_DISPLAY_FREQUENCY is null) AND (X_LOGON_DISPLAY_FREQUENCY is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SUBSCRIPTION_NAME = X_SUBSCRIPTION_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER
) is
begin
  update JTF_UM_SUBSCRIPTIONS_B set
    APPLICATION_ID = X_APPLICATION_ID,
    SUBSCRIPTION_KEY = X_SUBSCRIPTION_KEY,
    ENABLED_FLAG = X_ENABLED_FLAG,
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    APPROVAL_ID = X_APPROVAL_ID,
    PARENT_SUBSCRIPTION_ID = X_PARENT_SUBSCRIPTION_ID,
    AVAILABILITY_CODE = X_AVAILABILITY_CODE,
    LOGON_DISPLAY_FREQUENCY = X_LOGON_DISPLAY_FREQUENCY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    AUTH_DELEGATION_ROLE_ID = X_AUTH_DELEGATION_ROLE_ID
  where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_UM_SUBSCRIPTIONS_TL set
    SUBSCRIPTION_NAME = X_SUBSCRIPTION_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SUBSCRIPTION_ID in NUMBER
) is
begin
  delete from JTF_UM_SUBSCRIPTIONS_TL
  where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_UM_SUBSCRIPTIONS_B
  where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_UM_SUBSCRIPTIONS_TL T
  where not exists
    (select NULL
    from JTF_UM_SUBSCRIPTIONS_B B
    where B.SUBSCRIPTION_ID = T.SUBSCRIPTION_ID
    );

  update JTF_UM_SUBSCRIPTIONS_TL T set (
      SUBSCRIPTION_NAME,
      DESCRIPTION
    ) = (select
      B.SUBSCRIPTION_NAME,
      B.DESCRIPTION
    from JTF_UM_SUBSCRIPTIONS_TL B
    where B.SUBSCRIPTION_ID = T.SUBSCRIPTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SUBSCRIPTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SUBSCRIPTION_ID,
      SUBT.LANGUAGE
    from JTF_UM_SUBSCRIPTIONS_TL SUBB, JTF_UM_SUBSCRIPTIONS_TL SUBT
    where SUBB.SUBSCRIPTION_ID = SUBT.SUBSCRIPTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SUBSCRIPTION_NAME <> SUBT.SUBSCRIPTION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_UM_SUBSCRIPTIONS_TL (
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    DESCRIPTION,
    APPLICATION_ID,
    SUBSCRIPTION_ID,
    SUBSCRIPTION_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.DESCRIPTION,
    B.APPLICATION_ID,
    B.SUBSCRIPTION_ID,
    B.SUBSCRIPTION_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_UM_SUBSCRIPTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_UM_SUBSCRIPTIONS_TL T
    where T.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--For this procedure, if SUBSCRIPTION_ID passed as input is NULL, then create a new record
-- otherwise, modify the existing record.

procedure LOAD_ROW (
    X_SUBSCRIPTION_ID        IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPROVAL_ID	     IN NUMBER,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_PARENT_SUBSCRIPTION_ID IN NUMBER,
    X_AVAILABILITY_CODE      IN VARCHAR2,
    X_LOGON_DISPLAY_FREQUENCY IN NUMBER,
    X_SUBSCRIPTION_KEY       IN VARCHAR2,
    X_SUBSCRIPTION_NAME          IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_AUTH_DELEGATION_ROLE_ID IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
        l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
        l_subscription_id NUMBER := 0;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  --      if (x_owner = 'SEED') then
   --             l_user_id := 1;
    --    end if;


	-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

        -- If SUBSCRIPTION_ID passed in NULL, insert the record
        if ( X_SUBSCRIPTION_ID is NULL ) THEN
           INSERT_ROW(
		X_SUBSCRIPTION_ID 	=> l_subscription_id,
                X_EFFECTIVE_START_DATE 	=> X_EFFECTIVE_START_DATE,
		X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		X_APPROVAL_ID 		=> X_APPROVAL_ID,
		X_APPLICATION_ID 	=> X_APPLICATION_ID,
		X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		X_PARENT_SUBSCRIPTION_ID => X_PARENT_SUBSCRIPTION_ID,
		X_AVAILABILITY_CODE	=> X_AVAILABILITY_CODE,
		X_LOGON_DISPLAY_FREQUENCY => X_LOGON_DISPLAY_FREQUENCY,
		X_SUBSCRIPTION_KEY	=> X_SUBSCRIPTION_KEY,
		X_SUBSCRIPTION_NAME	=> X_SUBSCRIPTION_NAME,
		X_DESCRIPTION		=> X_DESCRIPTION,
                X_CREATION_DATE         => f_ludate,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATE_DATE      => f_ludate,
                X_LAST_UPDATED_BY       => f_luby,
                X_LAST_UPDATE_LOGIN     => l_user_id,
                X_AUTH_DELEGATION_ROLE_ID => X_AUTH_DELEGATION_ROLE_ID
             );
          else
              -- This select stmnt also checks if
              -- there is a row for this app_id and this app_short_name
              -- Exception is thrown otherwise.
              select LAST_UPDATED_BY, LAST_UPDATE_DATE
                into db_luby, db_ludate
                FROM JTF_UM_SUBSCRIPTIONS_B
               where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

              if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

                     UPDATE_ROW(
                          X_SUBSCRIPTION_ID 	=> X_SUBSCRIPTION_ID,
		          X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		          X_APPROVAL_ID 		=> X_APPROVAL_ID,
		          X_APPLICATION_ID 	=> X_APPLICATION_ID,
		          X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		          X_PARENT_SUBSCRIPTION_ID => X_PARENT_SUBSCRIPTION_ID,
		          X_AVAILABILITY_CODE	=> X_AVAILABILITY_CODE,
		          X_LOGON_DISPLAY_FREQUENCY => X_LOGON_DISPLAY_FREQUENCY,
		          X_SUBSCRIPTION_KEY	=> X_SUBSCRIPTION_KEY,
		          X_SUBSCRIPTION_NAME	=> X_SUBSCRIPTION_NAME,
		          X_DESCRIPTION		=> X_DESCRIPTION,
                          X_LAST_UPDATE_DATE      => f_ludate,
                          X_LAST_UPDATED_BY       => f_luby,
                          X_LAST_UPDATE_LOGIN     => l_user_id,
                          X_AUTH_DELEGATION_ROLE_ID => X_AUTH_DELEGATION_ROLE_ID
                       );

	      end if;
     end if;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_SUBSCRIPTION_ID in NUMBER, -- key field
  X_SUBSCRIPTION_NAME in VARCHAR2, -- translated name
  X_DESCRIPTION in VARCHAR2, -- translated description
  X_OWNER in VARCHAR2, -- owner field
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
     f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM JTF_UM_SUBSCRIPTIONS_TL
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
          update JTF_UM_SUBSCRIPTIONS_TL set
        	SUBSCRIPTION_NAME   = X_SUBSCRIPTION_NAME,
        	DESCRIPTION       = X_DESCRIPTION,
        	LAST_UPDATE_DATE  = f_ludate,
        	LAST_UPDATED_BY   = f_luby,
        	LAST_UPDATE_LOGIN = 0,
        	SOURCE_LANG       = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  	        and SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;
    end if;

end TRANSLATE_ROW;

FUNCTION IS_TEMPLATE_ASSIGNED(X_SUBSCRIPTION_ID NUMBER, X_TEMPLATE_ID NUMBER) RETURN BOOLEAN IS
l_dummy NUMBER;
CURSOR C IS SELECT SUBSCRIPTION_ID FROM JTF_UM_SUBSCRIPTION_TMPL WHERE SUBSCRIPTION_ID = X_SUBSCRIPTION_ID AND TEMPLATE_ID = X_TEMPLATE_ID AND (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE);
begin
open c;
   fetch c into l_dummy;
    if(c%NOTFOUND) then
       return (false);
    else
       return (true);
    end if;
close c;
end IS_TEMPLATE_ASSIGNED;


procedure REMOVE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER
) is
begin

   UPDATE JTF_UM_SUBSCRIPTION_TMPL SET
   EFFECTIVE_END_DATE = SYSDATE,
   LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
   LAST_UPDATE_DATE= SYSDATE
   WHERE SUBSCRIPTION_ID = X_SUBSCRIPTION_ID ;

end REMOVE_TEMPLATE_ASSIGNMENT;

procedure CREATE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE DEFAULT SYSDATE,
   X_EFFECTIVE_END_DATE IN DATE DEFAULT NULL,
   X_CREATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
   X_LAST_UPDATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID
) is
begin

INSERT INTO JTF_UM_SUBSCRIPTION_TMPL(
            SUBSCRIPTION_ID,
	    TEMPLATE_ID,
	    EFFECTIVE_START_DATE,
	    EFFECTIVE_END_DATE,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE)
      VALUES(
             X_SUBSCRIPTION_ID,
	     X_TEMPLATE_ID,
	     X_EFFECTIVE_START_DATE,
	     X_EFFECTIVE_END_DATE,
	     X_CREATED_BY,
	     SYSDATE,
	     X_LAST_UPDATED_BY,
	     SYSDATE
	     );
end CREATE_TEMPLATE_ASSIGNMENT;

procedure ASSOCIATE_TEMPLATE(
   X_SUBSCRIPTION_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER
) is
begin

   IF NOT IS_TEMPLATE_ASSIGNED(X_SUBSCRIPTION_ID, X_TEMPLATE_ID) THEN
      REMOVE_TEMPLATE_ASSIGNMENT(X_SUBSCRIPTION_ID);
      CREATE_TEMPLATE_ASSIGNMENT(X_SUBSCRIPTION_ID, X_TEMPLATE_ID);
   END IF;


end ASSOCIATE_TEMPLATE;

procedure UPDATE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE,
   X_EFFECTIVE_END_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
) is
begin
	update JTF_UM_SUBSCRIPTION_TMPL
	set EFFECTIVE_END_DATE=X_EFFECTIVE_END_DATE,
	    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	where  SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
	and    TEMPLATE_ID = X_TEMPLATE_ID
	and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

end UPDATE_TEMPLATE_ASSIGNMENT;

procedure LOAD_SUBSCRIPTION_TMPL_ROW(
    X_SUBSCRIPTION_ID        IN NUMBER,
    X_TEMPLATE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
)
is
        l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
        h_record_exists NUMBER := 0;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  --      if (x_owner = 'SEED') then
   --             l_user_id := 1;
    --    end if;

        select count(*)
        into   h_record_exists
        from   jtf_UM_SUBSCRIPTION_TMPL
	where  SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
	and    TEMPLATE_ID = X_TEMPLATE_ID
	and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

     -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


	-- TRY update, and if it fails, insert

          if ( h_record_exists = 0 ) then
            CREATE_TEMPLATE_ASSIGNMENT(
                X_SUBSCRIPTION_ID       => X_SUBSCRIPTION_ID,
                X_TEMPLATE_ID           => X_TEMPLATE_ID,
                X_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE,
                X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATED_BY       => f_luby
             );
          else
             -- This select stmnt also checks if
             -- there is a row for this app_id and this app_short_name
             -- Exception is thrown otherwise.
             select LAST_UPDATED_BY, LAST_UPDATE_DATE
               into db_luby, db_ludate
               FROM JTF_UM_SUBSCRIPTION_TMPL
              where SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
	         and    TEMPLATE_ID = X_TEMPLATE_ID
	         and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

             if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

                    UPDATE_TEMPLATE_ASSIGNMENT(
                         X_SUBSCRIPTION_ID       => X_SUBSCRIPTION_ID,
                         X_TEMPLATE_ID           => X_TEMPLATE_ID,
                         X_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE,
			 X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
			 X_LAST_UPDATE_DATE      => f_ludate,
                         X_LAST_UPDATED_BY       => f_luby,
                         X_LAST_UPDATE_LOGIN     => l_user_id
                      );
             end if;
    end if;

end LOAD_SUBSCRIPTION_TMPL_ROW;



procedure INSERT_SUBREG_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_LAST_APPROVER_COMMENT in VARCHAR2,
  X_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_REG_ID out NOCOPY NUMBER,
  X_USER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GRANT_DELEGATION_FLAG in VARCHAR2

) is
begin
  insert into JTF_UM_SUBSCRIPTION_REG (
    LAST_APPROVER_COMMENT,
    APPROVER_USER_ID,
    EFFECTIVE_END_DATE,
    WF_ITEM_TYPE,
    EFFECTIVE_START_DATE,
    SUBSCRIPTION_REG_ID,
    SUBSCRIPTION_ID,
    USER_ID,
    STATUS_CODE,
    CREATION_DATE,
     CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    GRANT_DELEGATION_FLAG
  ) values (
    X_LAST_APPROVER_COMMENT,
    X_APPROVER_USER_ID,
    X_EFFECTIVE_END_DATE,
    X_WF_ITEM_TYPE,
    X_EFFECTIVE_START_DATE,
    JTF_UM_UT_SUBSC_REG_S.NEXTVAL,
    X_SUBSCRIPTION_ID,
    X_USER_ID,
    X_STATUS_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_GRANT_DELEGATION_FLAG
  ) RETURNING SUBSCRIPTION_REG_ID INTO X_SUBSCRIPTION_REG_ID;
end INSERT_SUBREG_ROW;


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in boolean
                                        ) is

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
l_flag_value VARCHAR2(1) := 'N';

begin

   JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_reg_id:' || p_subscription_reg_id || '+' || 'p_grant_delegation_flag:' || JTF_DBSTRING_UTILS.getBooleanString(p_grant_delegation_flag)
                                    );
  end if;


     if p_grant_delegation_flag then

          l_flag_value := 'Y';

     end if;

     UPDATE JTF_UM_SUBSCRIPTION_REG SET GRANT_DELEGATION_FLAG = l_flag_value
     WHERE  SUBSCRIPTION_REG_ID = p_subscription_reg_id ;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

end update_grant_delegation_flag;

/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *   p_grant_delegation_role:
 *     description:  The Boolean equivallent int value of the decision
 *                   whether to grant delegation role or not
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in number,
                       p_grant_delegation_role     in number
                                        ) IS

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
l_flag_value VARCHAR2(1) := 'N';

CURSOR FIND_PRINCIPAL_NAME IS SELECT FU.USER_NAME, SUBREG.SUBSCRIPTION_ID
FROM FND_USER FU, JTF_UM_SUBSCRIPTION_REG SUBREG
WHERE FU.USER_ID = SUBREG.USER_ID
AND   SUBREG.SUBSCRIPTION_REG_ID = p_subscription_reg_id;

l_principal_name FND_USER.USER_NAME%TYPE;
l_subscription_id NUMBER;
l_role_id NUMBER;

begin

   JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_reg_id:' || p_subscription_reg_id || '+' || 'p_grant_delegation_flag:'
                                     || p_grant_delegation_flag || '+' || 'p_grant_delegation_role:' || p_grant_delegation_role
                                    );
  end if;


     if p_grant_delegation_flag = 1 then

          l_flag_value := 'Y';

     end if;

     UPDATE JTF_UM_SUBSCRIPTION_REG SET GRANT_DELEGATION_FLAG = l_flag_value
     WHERE  SUBSCRIPTION_REG_ID = p_subscription_reg_id ;

  -- Grant the delegation role, if required
  IF p_grant_delegation_role = 1 AND p_grant_delegation_flag = 1 THEN

     OPEN FIND_PRINCIPAL_NAME;
     FETCH FIND_PRINCIPAL_NAME INTO l_principal_name,l_subscription_id;
     CLOSE FIND_PRINCIPAL_NAME;

     JTF_UM_SUBSCRIPTIONS_PKG.get_delegation_role(
                       p_subscription_id  => l_subscription_id,
                       x_delegation_role  => l_role_id
                             );


           IF l_role_id IS NOT NULL  AND l_principal_name IS NOT NULL THEN

               -- Grant delegation role to a user
               JTF_UM_UTIL_PVT.GRANT_ROLES(
                       p_user_name      => l_principal_name,
                       p_role_id        => l_role_id,
                       p_source_name    => 'JTF_UM_SUBSCRIPTIONS_B',
                       p_source_id      => l_subscription_id
                     );

               -- Assign the deleagtion access role

               JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => l_principal_name,
                       ROLE_NAME       => 'JTA_UM_DELEGATION_ACCESS',
                       OWNERTABLE_NAME => 'JTF_UM_SUBSCRIPTIONS_B',
                       OWNERTABLE_KEY  => l_subscription_id);
           END IF;

  END IF;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END update_grant_delegation_flag;



/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in number
                                        ) IS

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
l_grant_delegation_flag boolean := false;

begin

 JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_reg_id:' || p_subscription_reg_id || '+' || 'p_grant_delegation_flag:' || p_grant_delegation_flag
                                    );
  end if;


if p_grant_delegation_flag = 1 then
  l_grant_delegation_flag := true;
end if;

   update_grant_delegation_flag (
                       p_subscription_reg_id   => p_subscription_reg_id,
                       p_grant_delegation_flag => l_grant_delegation_flag
                                        );

 JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

end update_grant_delegation_flag;


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_name:
 *     description:  The user_name of a user
 *     required   :  Y
 *     validation :  Must be a valid user_name.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_name             in varchar2,
                       p_grant_delegation_flag in boolean
                                        ) is

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';

CURSOR FIND_REG_ID IS SELECT SUBSCRIPTION_REG_ID
FROM JTF_UM_SUBSCRIPTION_REG SUBREG, FND_USER FU
WHERE  SUBSCRIPTION_ID = p_subscription_id
AND    SUBREG.USER_ID  = FU.USER_ID
AND    FU.USER_NAME    = p_user_name
AND    NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE;

l_subscription_reg_id JTF_UM_SUBSCRIPTION_REG.SUBSCRIPTION_REG_ID%TYPE;

begin

   JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_name:' || p_user_name || '+' || 'p_grant_delegation_flag:' || JTF_DBSTRING_UTILS.getBooleanString(p_grant_delegation_flag)
                                     );
  end if;


     OPEN FIND_REG_ID;
     FETCH FIND_REG_ID INTO l_subscription_reg_id;

     IF FIND_REG_ID%FOUND THEN
       update_grant_delegation_flag (
                       p_subscription_reg_id   => l_subscription_reg_id,
                       p_grant_delegation_flag => p_grant_delegation_flag
                                     );

     END IF;
     CLOSE FIND_REG_ID;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

end update_grant_delegation_flag;

/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_name:
 *     description:  The user_name of a user
 *     required   :  Y
 *     validation :  Must be a valid user_name.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_name             in varchar2,
                       p_grant_delegation_flag in number
                                        ) IS

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
l_grant_delegation_flag boolean := false;

begin

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_name:' || p_user_name || '+' || 'p_grant_delegation_flag:' || p_grant_delegation_flag
                                    );
  end if;


if p_grant_delegation_flag = 1 then
  l_grant_delegation_flag := true;
end if;

   update_grant_delegation_flag (
                       p_subscription_id       => p_subscription_id,
                       p_user_name             => p_user_name,
                       p_grant_delegation_flag => l_grant_delegation_flag
                                        );

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


end update_grant_delegation_flag;



/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_id               in number,
                       p_grant_delegation_flag in boolean
                                        ) is

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
CURSOR FIND_REG_ID IS SELECT SUBSCRIPTION_REG_ID
FROM JTF_UM_SUBSCRIPTION_REG SUBREG, FND_USER FU
WHERE  SUBSCRIPTION_ID = p_subscription_id
AND    SUBREG.USER_ID  = FU.USER_ID
AND    FU.USER_ID      = p_user_id
AND    NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE;

l_subscription_reg_id JTF_UM_SUBSCRIPTION_REG.SUBSCRIPTION_REG_ID%TYPE;

begin

     JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_id:' || p_user_id || '+' || 'p_grant_delegation_flag:' || JTF_DBSTRING_UTILS.getBooleanString(p_grant_delegation_flag)

                                    );
     end if;

     OPEN FIND_REG_ID;
     FETCH FIND_REG_ID INTO l_subscription_reg_id;

     IF FIND_REG_ID%FOUND THEN
       update_grant_delegation_flag (
                       p_subscription_reg_id   => l_subscription_reg_id,
                       p_grant_delegation_flag => p_grant_delegation_flag
                                     );

     END IF;
     CLOSE FIND_REG_ID;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

end update_grant_delegation_flag;


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */

procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_id               in number,
                       p_grant_delegation_flag in number
                                        ) IS

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';
l_grant_delegation_flag boolean := false;

begin

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


if p_grant_delegation_flag = 1 then
  l_grant_delegation_flag := true;
end if;

   update_grant_delegation_flag (
                       p_subscription_id       => p_subscription_id,
                       p_user_id               => p_user_id,
                       p_grant_delegation_flag => l_grant_delegation_flag
                                        );

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


end update_grant_delegation_flag;


/*
 * Name        : get_delegation_role
 * Pre_reqs    :  None
 * Description :  Will determine if an enrollment has a delegation role
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id
 * output parameters
 * x_delegation_role
 *    description: The value of the column auth_delegation_id of the table
 *                 JTF_UM_ENROLLMENTS_B. This value will be null, if no
 *                 no delegation role has been defined for this enrollment
 *
 * Note:
 *
 *   This API will raise an exception if no record is found which matches
 *   to the subscription_id being passed
 */
procedure get_delegation_role(
                       p_subscription_id  in number,
                       x_delegation_role  out NOCOPY number
                             ) is

l_procedure_name CONSTANT varchar2(30) := 'update_grant_delegation_flag';

CURSOR FIND_DELEGATION_ROLE IS SELECT AUTH_DELEGATION_ROLE_ID FROM JTF_UM_SUBSCRIPTIONS_B
WHERE SUBSCRIPTION_ID = p_subscription_id;

begin

 JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id
                                    );
  end if;


OPEN FIND_DELEGATION_ROLE;
FETCH FIND_DELEGATION_ROLE INTO x_delegation_role;

IF FIND_DELEGATION_ROLE%NOTFOUND THEN
CLOSE FIND_DELEGATION_ROLE;
JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id')
                            );
RAISE_APPLICATION_ERROR(-20000,JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id'));
END IF;



CLOSE FIND_DELEGATION_ROLE;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


end get_delegation_role;


/**
 * Procedure   :  get_grant_delegation_flag
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will return the value of the column grant_delegation_flag
 *                from the table JTF_UM_SUBSCRIPTION_REG
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * output parameters
 * x_result: The Boolean value based on the column grant_delegation_flag
 *
 * Note:
 *
 * This API will raise an exception, if subscription_id or user_id is invalid
 * or there is no matching record in JTF_UM_SUBSCRIPTION_REG table
 *
 */

procedure get_grant_delegation_flag(
                       p_subscription_id  in number,
                       p_user_id          in number,
                       x_result           out NOCOPY boolean
                                  ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_grant_delegation_flag';

CURSOR FIND_DELEGATION_FLAG IS SELECT GRANT_DELEGATION_FLAG FROM JTF_UM_SUBSCRIPTION_REG
WHERE SUBSCRIPTION_ID = p_subscription_id AND USER_ID = p_user_id
AND NVL(EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE;

l_flag_value varchar2(1);

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_subscription_id:'||p_subscription_id || '+' || 'p_user_id:' || p_user_id
                              );
end if;

IF NOT JTF_UM_UTIL_PVT.VALIDATE_USER_ID(p_user_id) THEN
JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id')
                            );
RAISE_APPLICATION_ERROR(-20000,JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id'));
END IF;

IF NOT JTF_UM_UTIL_PVT.VALIDATE_SUBSCRIPTION_ID(p_subscription_id) THEN
JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id')
                            );
RAISE_APPLICATION_ERROR(-20000,JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id'));
END IF;


OPEN FIND_DELEGATION_FLAG;

FETCH FIND_DELEGATION_FLAG INTO l_flag_value;

IF FIND_DELEGATION_FLAG%NOTFOUND THEN
CLOSE FIND_DELEGATION_FLAG;
 JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('JTA_UM_USER_ENROLL_NO_ASGN')
                            );

    RAISE_APPLICATION_ERROR(-20000,  JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('JTA_UM_USER_ENROLL_NO_ASGN'));
END IF;

CLOSE FIND_DELEGATION_FLAG;

IF l_flag_value = 'Y' THEN
x_result := TRUE;
ELSE
x_result := FALSE;
END IF;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END get_grant_delegation_flag;


end JTF_UM_SUBSCRIPTIONS_PKG;

/
