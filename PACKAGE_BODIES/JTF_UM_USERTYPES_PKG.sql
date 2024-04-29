--------------------------------------------------------
--  DDL for Package Body JTF_UM_USERTYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_USERTYPES_PKG" as
/* $Header: JTFUMUTB.pls 120.6.12010000.2 2008/08/07 10:34:35 ruddas ship $ */
procedure INSERT_ROW (
  X_USERTYPE_ID out NOCOPY NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_EMAIL_NOTIFICATION_FLAG in VARCHAR2,
  X_IS_SELF_SERVICE_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_USERTYPE_KEY in VARCHAR2,
  X_USERTYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USERTYPE_SHORTNAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER
) is
  cursor C is select ROWID from JTF_UM_USERTYPES_B
    where USERTYPE_ID = X_USERTYPE_ID
    ;
begin
  insert into JTF_UM_USERTYPES_B (
    EFFECTIVE_END_DATE,
    APPROVAL_ID,
    APPLICATION_ID,
    ENABLED_FLAG,
    EMAIL_NOTIFICATION_FLAG,
    IS_SELF_SERVICE_FLAG,
    EFFECTIVE_START_DATE,
    USERTYPE_ID,
    USERTYPE_KEY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DISPLAY_ORDER
  ) values (
    X_EFFECTIVE_END_DATE,
    X_APPROVAL_ID,
    X_APPLICATION_ID,
    X_ENABLED_FLAG,
    X_EMAIL_NOTIFICATION_FLAG,
    X_IS_SELF_SERVICE_FLAG,
    X_EFFECTIVE_START_DATE,
    JTF_UM_USERTYPES_B_S.NEXTVAL,
    X_USERTYPE_KEY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DISPLAY_ORDER
  ) RETURNING USERTYPE_ID INTO X_USERTYPE_ID;

  insert into JTF_UM_USERTYPES_TL (
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USERTYPE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    USERTYPE_ID,
    LANGUAGE,
    SOURCE_LANG,
    USERTYPE_SHORTNAME
  ) select
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USERTYPE_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_USERTYPE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_USERTYPE_SHORTNAME
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_UM_USERTYPES_TL T
    where T.USERTYPE_ID = X_USERTYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_USERTYPE_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_EMAIL_NOTIFICATION_FLAG in VARCHAR2,
  X_IS_SELF_SERVICE_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_USERTYPE_KEY in VARCHAR2,
  X_USERTYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      EFFECTIVE_END_DATE,
      APPROVAL_ID,
      APPLICATION_ID,
      ENABLED_FLAG,
      EMAIL_NOTIFICATION_FLAG,
      IS_SELF_SERVICE_FLAG,
      EFFECTIVE_START_DATE,
      USERTYPE_KEY
    from JTF_UM_USERTYPES_B
    where USERTYPE_ID = X_USERTYPE_ID
    for update of USERTYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USERTYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_UM_USERTYPES_TL
    where USERTYPE_ID = X_USERTYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of USERTYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE)
           OR ((recinfo.EFFECTIVE_END_DATE is null) AND (X_EFFECTIVE_END_DATE is null)))
      AND ((recinfo.APPROVAL_ID = X_APPROVAL_ID)
           OR ((recinfo.APPROVAL_ID is null) AND (X_APPROVAL_ID is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.EMAIL_NOTIFICATION_FLAG = X_EMAIL_NOTIFICATION_FLAG)
      AND (recinfo.IS_SELF_SERVICE_FLAG = X_IS_SELF_SERVICE_FLAG)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND (recinfo.USERTYPE_KEY = X_USERTYPE_KEY)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USERTYPE_NAME = X_USERTYPE_NAME)
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
  X_USERTYPE_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_EMAIL_NOTIFICATION_FLAG in VARCHAR2,
  X_IS_SELF_SERVICE_FLAG in VARCHAR2,
  X_USERTYPE_KEY in VARCHAR2,
  X_USERTYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USERTYPE_SHORTNAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER
) is
begin
  update JTF_UM_USERTYPES_B set
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    APPROVAL_ID = X_APPROVAL_ID,
    APPLICATION_ID = X_APPLICATION_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    EMAIL_NOTIFICATION_FLAG = X_EMAIL_NOTIFICATION_FLAG,
    IS_SELF_SERVICE_FLAG = X_IS_SELF_SERVICE_FLAG,
    USERTYPE_KEY = X_USERTYPE_KEY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    DISPLAY_ORDER = X_DISPLAY_ORDER
  where USERTYPE_ID = X_USERTYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_UM_USERTYPES_TL set
    USERTYPE_NAME = X_USERTYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
    USERTYPE_SHORTNAME = X_USERTYPE_SHORTNAME
  where USERTYPE_ID = X_USERTYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_USERTYPE_ID in NUMBER
) is
begin
  delete from JTF_UM_USERTYPES_TL
  where USERTYPE_ID = X_USERTYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_UM_USERTYPES_B
  where USERTYPE_ID = X_USERTYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_UM_USERTYPES_TL T
  where not exists
    (select NULL
    from JTF_UM_USERTYPES_B B
    where B.USERTYPE_ID = T.USERTYPE_ID
    );

  update JTF_UM_USERTYPES_TL T set (
      USERTYPE_NAME,
      DESCRIPTION,
      USERTYPE_SHORTNAME
    ) = (select
      B.USERTYPE_NAME,
      B.DESCRIPTION,
      B.USERTYPE_SHORTNAME
    from JTF_UM_USERTYPES_TL B
    where B.USERTYPE_ID = T.USERTYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.USERTYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.USERTYPE_ID,
      SUBT.LANGUAGE
    from JTF_UM_USERTYPES_TL SUBB, JTF_UM_USERTYPES_TL SUBT
    where SUBB.USERTYPE_ID = SUBT.USERTYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USERTYPE_NAME <> SUBT.USERTYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.USERTYPE_SHORTNAME <> SUBT.USERTYPE_SHORTNAME
  ));

  insert into JTF_UM_USERTYPES_TL (
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USERTYPE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    USERTYPE_ID,
    LANGUAGE,
    SOURCE_LANG,
    USERTYPE_SHORTNAME
  ) select
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USERTYPE_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.USERTYPE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.USERTYPE_SHORTNAME
  from JTF_UM_USERTYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_UM_USERTYPES_TL T
    where T.USERTYPE_ID = B.USERTYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--For this procedure, if USERTYPE_ID passed as input is NULL, then create a new record
-- otherwise, modify the existing record.

procedure LOAD_ROW (
    X_USERTYPE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPROVAL_ID	     IN NUMBER,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_EMAIL_NOTIFICATION_FLAG IN VARCHAR2,
    X_IS_SELF_SERVICE_FLAG   IN VARCHAR2,
    X_USERTYPE_KEY           IN VARCHAR2,
    X_USERTYPE_NAME          IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_USERTYPE_SHORTNAME in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
        l_user_id NUMBER :=  fnd_load_util.owner_id(x_owner);
        l_usertype_id NUMBER := 0;
	 f_luby    number;  -- entity owner in file
         f_ludate  date;    -- entity update date in file
         db_luby   number;  -- entity owner in db
         db_ludate date;    -- entity update date in db
	 v_db_owner_id number;
         v_db_display_order number;
         v_db_usertype_shortname varchar2(230);
begin
        --if (x_owner = 'SEED') then
        --        l_user_id := 1;
       -- end if;

       -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

        -- If USERTYPE_ID passed in NULL, insert the record
        if ( X_USERTYPE_ID is NULL ) THEN
           INSERT_ROW(
		X_USERTYPE_ID 		=> l_usertype_id,
                X_EFFECTIVE_START_DATE 	=> X_EFFECTIVE_START_DATE,
		X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		X_APPROVAL_ID 		=> X_APPROVAL_ID,
		X_APPLICATION_ID 	=> X_APPLICATION_ID,
		X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		X_EMAIL_NOTIFICATION_FLAG => X_EMAIL_NOTIFICATION_FLAG,
		X_IS_SELF_SERVICE_FLAG	=> X_IS_SELF_SERVICE_FLAG,
		X_USERTYPE_KEY		=> X_USERTYPE_KEY,
		X_USERTYPE_NAME		=> X_USERTYPE_NAME,
		X_DESCRIPTION		=> X_DESCRIPTION,
                X_CREATION_DATE         => f_ludate,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATE_DATE      => f_ludate,
                X_LAST_UPDATED_BY       => f_luby,
                X_LAST_UPDATE_LOGIN     => l_user_id,
                X_USERTYPE_SHORTNAME    => X_USERTYPE_SHORTNAME,
                X_DISPLAY_ORDER         => X_DISPLAY_ORDER

             );
          else
             -- This select stmnt also checks if
             -- there is a row for this app_id and this app_short_name
             -- Exception is thrown otherwise.
             select LAST_UPDATED_BY, LAST_UPDATE_DATE
               into db_luby, db_ludate
               FROM JTF_UM_USERTYPES_B
              where USERTYPE_ID = X_USERTYPE_ID;

             if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                           db_ludate, X_CUSTOM_MODE)) then

                    UPDATE_ROW(
		          X_USERTYPE_ID 		=> X_USERTYPE_ID,
		          X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		          X_APPROVAL_ID 		=> X_APPROVAL_ID,
		          X_APPLICATION_ID 	=> X_APPLICATION_ID,
		          X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		          X_EMAIL_NOTIFICATION_FLAG => X_EMAIL_NOTIFICATION_FLAG,
		          X_IS_SELF_SERVICE_FLAG	=> X_IS_SELF_SERVICE_FLAG,
		          X_USERTYPE_KEY		=> X_USERTYPE_KEY,
		          X_USERTYPE_NAME		=> X_USERTYPE_NAME,
		          X_DESCRIPTION		=> X_DESCRIPTION,
                          X_LAST_UPDATE_DATE      => f_ludate,
                          X_LAST_UPDATED_BY       => f_luby,
                          X_LAST_UPDATE_LOGIN     => l_user_id,
                          X_USERTYPE_SHORTNAME    => X_USERTYPE_SHORTNAME,
                          X_DISPLAY_ORDER         => X_DISPLAY_ORDER
                       );

              else

	    select LAST_UPDATED_BY, DISPLAY_ORDER, USERTYPE_SHORTNAME
            into v_db_owner_id, v_db_display_order, v_db_usertype_shortname
            from JTF_UM_USERTYPES_VL
            where USERTYPE_ID = JTF_UMUTIL.usertype_lookup(x_usertype_key, X_EFFECTIVE_START_DATE);

	      if
	       ((v_db_display_order is NULL) AND
               (v_db_usertype_shortname = 'CHANGE ME IN THE ADMIN CONSOLEx_ USERTYPE SETUP SCREEN') ) then

                UPDATE_ROW_SPECIAL(
  		  X_USERTYPE_ID		=> JTF_UMUTIL.usertype_lookup(x_usertype_key, X_EFFECTIVE_START_DATE),
  		  X_USERTYPE_NAME => x_usertype_name,
                  X_USERTYPE_SHORTNAME => NVL(x_usertype_shortname, 'CHANGE ME IN THE ADMIN CONSOLE: USERTYPE SETUP SCREEN'),
                  X_DISPLAY_ORDER => x_display_order,
  		  X_OWNER => x_owner);

              end if;
      end if;
     end if;
end LOAD_ROW;

FUNCTION IS_TEMPLATE_ASSIGNED(X_USERTYPE_ID NUMBER, X_TEMPLATE_ID NUMBER) RETURN BOOLEAN IS
l_dummy NUMBER;
CURSOR C IS SELECT USERTYPE_ID FROM JTF_UM_USERTYPE_TMPL WHERE USERTYPE_ID = X_USERTYPE_ID AND TEMPLATE_ID = X_TEMPLATE_ID AND (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE);
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
   X_USERTYPE_ID IN NUMBER
) is
begin

   UPDATE JTF_UM_USERTYPE_TMPL SET
   EFFECTIVE_END_DATE = SYSDATE,
   LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
   LAST_UPDATE_DATE= SYSDATE
   WHERE USERTYPE_ID = X_USERTYPE_ID;

end REMOVE_TEMPLATE_ASSIGNMENT;

procedure CREATE_TEMPLATE_ASSIGNMENT(
   X_USERTYPE_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE DEFAULT SYSDATE,
   X_EFFECTIVE_END_DATE IN DATE DEFAULT NULL,
   X_CREATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
   X_LAST_UPDATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID
) is
begin

INSERT INTO JTF_UM_USERTYPE_TMPL(
            USERTYPE_ID,
	    TEMPLATE_ID,
	    EFFECTIVE_START_DATE,
	    EFFECTIVE_END_DATE,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE)
      VALUES(
             X_USERTYPE_ID,
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
   X_USERTYPE_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER
) is
begin

      IF NOT IS_TEMPLATE_ASSIGNED(X_USERTYPE_ID, X_TEMPLATE_ID) THEN
      REMOVE_TEMPLATE_ASSIGNMENT(X_USERTYPE_ID);
      CREATE_TEMPLATE_ASSIGNMENT(X_USERTYPE_ID, X_TEMPLATE_ID);
      END IF;

end ASSOCIATE_TEMPLATE;

procedure UPDATE_TEMPLATE_ASSIGNMENT(
   X_USERTYPE_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE,
   X_EFFECTIVE_END_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
) is
begin
	update JTF_UM_USERTYPE_TMPL
	set EFFECTIVE_END_DATE=X_EFFECTIVE_END_DATE,
	    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	where  USERTYPE_ID = X_USERTYPE_ID
	and    TEMPLATE_ID = X_TEMPLATE_ID
	and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

end UPDATE_TEMPLATE_ASSIGNMENT;

procedure LOAD_USERTYPE_TMPL_ROW(
    X_USERTYPE_ID            IN NUMBER,
    X_TEMPLATE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
        l_user_id NUMBER :=  fnd_load_util.owner_id(x_owner);
        h_record_exists NUMBER := 0;
	  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
       -- if (x_owner = 'SEED') then
       --          l_user_id := 1;
       --  end if;

        select count(*)
        into   h_record_exists
        from   jtf_UM_USERTYPE_TMPL
	where  USERTYPE_ID = X_USERTYPE_ID
	and    TEMPLATE_ID = X_TEMPLATE_ID
	and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

        -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);



-- TRY update, and if it fails, insert

          if ( h_record_exists = 0 ) then
            CREATE_TEMPLATE_ASSIGNMENT(
                X_USERTYPE_ID           => X_USERTYPE_ID,
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
               FROM JTF_UM_USERTYPE_TMPL
              where USERTYPE_ID = X_USERTYPE_ID
	         and    TEMPLATE_ID = X_TEMPLATE_ID
	         and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

             if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                           db_ludate, X_CUSTOM_MODE)) then
                    UPDATE_TEMPLATE_ASSIGNMENT(
                         X_USERTYPE_ID           => X_USERTYPE_ID,
                         X_TEMPLATE_ID           => X_TEMPLATE_ID,
                         X_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE,
                         X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
                         X_LAST_UPDATE_DATE      => f_ludate,
                         X_LAST_UPDATED_BY       => f_luby,
                         X_LAST_UPDATE_LOGIN     => l_user_id
                      );
             end if;

   end if;

end LOAD_USERTYPE_TMPL_ROW;

-- USERTYPE - SUBSCRIPTION ASSIGNMENT

procedure REMOVE_SUBSCRIPTION_ASSIGNMENT(
   X_USERTYPE_ID IN NUMBER,
   X_SUBSCRIPTION_ID IN NUMBER
) is
begin

   UPDATE JTF_UM_USERTYPE_SUBSCRIP SET
   EFFECTIVE_END_DATE = SYSDATE,
   LAST_UPDATED_BY=FND_GLOBAL.USER_ID,
   LAST_UPDATE_DATE= SYSDATE
   WHERE USERTYPE_ID = X_USERTYPE_ID
   AND   SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

end REMOVE_SUBSCRIPTION_ASSIGNMENT;

procedure CREATE_SUBSCRIPTION_ASSIGNMENT(
   X_USERTYPE_ID NUMBER,
   X_SUBSCRIPTION_ID NUMBER,
   X_SUBSCRIPTION_FLAG VARCHAR2,
   X_DISPLAY_ORDER NUMBER,
   X_EFFECTIVE_START_DATE IN DATE DEFAULT SYSDATE,
   X_EFFECTIVE_END_DATE IN DATE DEFAULT NULL,
   X_CREATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
   X_LAST_UPDATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID
) is
begin
INSERT INTO JTF_UM_USERTYPE_SUBSCRIP(
            USERTYPE_ID,
	    SUBSCRIPTION_ID,
	    SUBSCRIPTION_FLAG,
	    SUBSCRIPTION_DISPLAY_ORDER,
	    EFFECTIVE_START_DATE,
	    EFFECTIVE_END_DATE,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE)
      VALUES(
             X_USERTYPE_ID,
	     X_SUBSCRIPTION_ID,
	     X_SUBSCRIPTION_FLAG,
	     X_DISPLAY_ORDER,
	     X_EFFECTIVE_START_DATE,
	     X_EFFECTIVE_END_DATE,
	     X_CREATED_BY,
	     SYSDATE,
	     X_LAST_UPDATED_BY,
	     SYSDATE
	     );
end CREATE_SUBSCRIPTION_ASSIGNMENT;

procedure UPDATE_SUBSCRIPTION_ASSIGNMENT(
   X_USERTYPE_ID NUMBER,
   X_SUBSCRIPTION_ID NUMBER,
   X_SUBSCRIPTION_FLAG VARCHAR2,
   X_DISPLAY_ORDER NUMBER
) is
begin
	update JTF_UM_USERTYPE_SUBSCRIP
	set SUBSCRIPTION_FLAG=X_SUBSCRIPTION_FLAG,
    	    SUBSCRIPTION_DISPLAY_ORDER = X_DISPLAY_ORDER
	where  USERTYPE_ID = X_USERTYPE_ID
	and    SUBSCRIPTION_ID = X_SUBSCRIPTION_ID;

end UPDATE_SUBSCRIPTION_ASSIGNMENT;

procedure UPDATE_SUBSCRIPTION_ASSIGNMENT(
   X_USERTYPE_ID 		IN NUMBER,
   X_SUBSCRIPTION_ID 		IN NUMBER,
   X_SUBSCRIPTION_FLAG 		IN VARCHAR2,
   X_DISPLAY_ORDER 		IN NUMBER,
   X_EFFECTIVE_START_DATE 	IN DATE,
   X_EFFECTIVE_END_DATE 	IN DATE,
   X_LAST_UPDATE_DATE	  	IN DATE,
   X_LAST_UPDATED_BY  		IN NUMBER,
   X_LAST_UPDATE_LOGIN 		IN NUMBER
) is
begin
        update JTF_UM_USERTYPE_SUBSCRIP
        set SUBSCRIPTION_FLAG=X_SUBSCRIPTION_FLAG,
            SUBSCRIPTION_DISPLAY_ORDER = X_DISPLAY_ORDER,
	    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
	    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	    LAST_UPDATED_BY  = X_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        where  USERTYPE_ID = X_USERTYPE_ID
        and    SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
        and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

end UPDATE_SUBSCRIPTION_ASSIGNMENT;


procedure LOAD_USERTYPES_SUB_ROW(
    X_USERTYPE_ID            IN NUMBER,
    X_SUBSCRIPTION_ID        IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_SUBSCRIPTION_FLAG      IN VARCHAR2,
    X_DISPLAY_ORDER 	     IN NUMBER,
    X_OWNER                  IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
        l_user_id NUMBER :=  fnd_load_util.owner_id(x_owner);
        h_record_exists NUMBER := 0;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
      -- if (x_owner = 'SEED') then
      --          l_user_id := 1;
      --  end if;

        select count(*)
        into   h_record_exists
        from   jtf_UM_USERTYPE_SUBSCRIP
        where  USERTYPE_ID = X_USERTYPE_ID
        and    SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
        and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


        -- TRY update, and if it fails, insert

          if ( h_record_exists = 0 ) then
            CREATE_SUBSCRIPTION_ASSIGNMENT(
                X_USERTYPE_ID           => X_USERTYPE_ID,
                X_SUBSCRIPTION_ID       => X_SUBSCRIPTION_ID,
                X_SUBSCRIPTION_FLAG     => X_SUBSCRIPTION_FLAG,
                X_DISPLAY_ORDER       	=> X_DISPLAY_ORDER,
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
	      FROM JTF_UM_USERTYPE_SUBSCRIP
	     where USERTYPE_ID = X_USERTYPE_ID
		and    SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
		and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

	    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
						  db_ludate, X_CUSTOM_MODE)) then
		   UPDATE_SUBSCRIPTION_ASSIGNMENT(
			X_USERTYPE_ID           => X_USERTYPE_ID,
			X_SUBSCRIPTION_ID       => X_SUBSCRIPTION_ID,
			X_SUBSCRIPTION_FLAG     => X_SUBSCRIPTION_FLAG,
			X_DISPLAY_ORDER       	=> X_DISPLAY_ORDER,
			X_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE,
			X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
			X_LAST_UPDATE_DATE      => f_ludate,
			X_LAST_UPDATED_BY       => f_luby,
			X_LAST_UPDATE_LOGIN     => l_user_id
		     );
          end if;

   end if;

end LOAD_USERTYPES_SUB_ROW;

procedure TRANSLATE_ROW (
  X_USERTYPE_ID in NUMBER, -- key field
  X_USERTYPE_NAME in VARCHAR2, -- translated name
  X_DESCRIPTION in VARCHAR2, -- translated description
  X_USERTYPE_SHORTNAME in VARCHAR2,
  X_OWNER in VARCHAR2, -- owner field
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL
)

is
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
      FROM JTF_UM_USERTYPES_TL
      where USERTYPE_ID = X_USERTYPE_ID
      and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

           update JTF_UM_USERTYPES_TL set
	        USERTYPE_NAME 	  = X_USERTYPE_NAME,
	        DESCRIPTION       = X_DESCRIPTION,
	        LAST_UPDATE_DATE  = f_ludate,
	        LAST_UPDATED_BY   = f_luby,
	        LAST_UPDATE_LOGIN = 0,
                USERTYPE_SHORTNAME = X_USERTYPE_SHORTNAME,
	        SOURCE_LANG       = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  	        and USERTYPE_ID = X_USERTYPE_ID;

     end if;

end TRANSLATE_ROW;

procedure INSERT_UMREG_ROW (
  X_USERTYPE_ID in NUMBER,
  X_LAST_APPROVER_COMMENT in VARCHAR2,
  X_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_USERTYPE_REG_ID out NOCOPY NUMBER,
  X_USER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

lcnt NUMBER ;

begin

-- Changes for 4287135
-- Check if there are any valid records for this customer
-- If any PENDING records are present no new records
-- for this FND User ID is possible

   SELECT COUNT(*) INTO lcnt
   FROM jtf_um_usertype_reg
   WHERE user_id =X_USER_ID and status_code in ( 'PENDING', 'UPGRADE_APPROVAL_PENDING')  --- Changes done for Bug 7291138 / bug 6617457
   AND NVL(effective_end_date, SYSDATE + 1) > SYSDATE;

   IF lcnt > 0 THEN
   	  raise_application_error(-20001, ' WEB REGISTRATION PENDING FOR THIS FND USER ID ' || x_user_id );
   END IF;

   -- As we allow re-registration (update in bug 4287135 )
   -- any previous approved entry has to be end dated.
   UPDATE jtf_um_usertype_reg
   SET effective_end_date=SYSDATE
   WHERE user_id =X_USER_ID and status_code in ( 'APPROVED', 'UPGRADE')   --- Changes done for Bug 7291138 / bug 6617457
   AND NVL(effective_end_date, SYSDATE + 1) > SYSDATE;

-- End of changes for 4287135

  insert into JTF_UM_USERTYPE_REG (
    LAST_APPROVER_COMMENT,
    APPROVER_USER_ID,
    EFFECTIVE_END_DATE,
    WF_ITEM_TYPE,
    EFFECTIVE_START_DATE,
    USERTYPE_REG_ID,
    USERTYPE_ID,
    USER_ID,
    STATUS_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LAST_APPROVER_COMMENT,
    X_APPROVER_USER_ID,
    X_EFFECTIVE_END_DATE,
    X_WF_ITEM_TYPE,
    X_EFFECTIVE_START_DATE,
    JTF_UM_UT_SUBSC_REG_S.NEXTVAL,
    X_USERTYPE_ID,
    X_USER_ID,
    X_STATUS_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  ) RETURNING USERTYPE_REG_ID INTO X_USERTYPE_REG_ID;
end INSERT_UMREG_ROW;

procedure UPDATE_ROW_SPECIAL (
  X_OWNER in VARCHAR2,
  X_USERTYPE_ID in NUMBER,
  X_USERTYPE_NAME in VARCHAR2,
  X_USERTYPE_SHORTNAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER
) is
        l_user_id NUMBER :=  fnd_load_util.owner_id(x_owner);
begin
        --if (x_owner = 'SEED') then
        --        l_user_id := 1;
        --end if;
  update JTF_UM_USERTYPES_B set
    LAST_UPDATE_LOGIN = l_user_id,
    LAST_UPDATE_DATE = SYSDATE,
    DISPLAY_ORDER = X_DISPLAY_ORDER
  where USERTYPE_ID = X_USERTYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_UM_USERTYPES_TL set
    USERTYPE_NAME = X_USERTYPE_NAME,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id,
    LAST_UPDATE_DATE = SYSDATE,
    SOURCE_LANG = userenv('LANG'),
    USERTYPE_SHORTNAME = X_USERTYPE_SHORTNAME
  where USERTYPE_ID = X_USERTYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW_SPECIAL;

end JTF_UM_USERTYPES_PKG;

/
