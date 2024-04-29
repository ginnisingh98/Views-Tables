--------------------------------------------------------
--  DDL for Package Body JTF_UM_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_APPROVALS_PKG" as
/* $Header: JTFUMAWB.pls 120.7 2006/03/13 09:13:38 vimohan ship $ */
procedure INSERT_ROW (
  X_APPROVAL_ID out NOCOPY NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_APPROVAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USE_PENDING_REQ_FLAG in VARCHAR2
) is
begin
  insert into JTF_UM_APPROVALS_B (
    EFFECTIVE_END_DATE,
    APPROVAL_ID,
    APPROVAL_KEY,
    ENABLED_FLAG,
    WF_ITEM_TYPE,
    EFFECTIVE_START_DATE,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USE_PENDING_REQ_FLAG
  ) values (
    X_EFFECTIVE_END_DATE,
    JTF_UM_APPROVALS_B_S.NEXTVAL,
    X_APPROVAL_KEY,
    X_ENABLED_FLAG,
    X_WF_ITEM_TYPE,
    X_EFFECTIVE_START_DATE,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USE_PENDING_REQ_FLAG
  ) RETURNING APPROVAL_ID INTO X_APPROVAL_ID;

  insert into JTF_UM_APPROVALS_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    APPROVAL_ID,
    APPROVAL_NAME,
    APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_APPROVAL_ID,
    X_APPROVAL_NAME,
    X_APPLICATION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_UM_APPROVALS_TL T
    where T.APPROVAL_ID = X_APPROVAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure INSERT_APPROVERS_ROW (
  X_APPROVER_ID out NOCOPY NUMBER,
  X_APPROVAL_ID in NUMBER,
  X_APPROVAL_SEQ in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USER_ID in NUMBER,
  X_ORG_PARTY_ID in NUMBER
) is
begin
 JTF_DEBUG_PUB.LOG_PARAMETERS( p_module => 'JTF.UM.PLSQL.BUGTEST',
                    p_message => 'bef insert approver');
  insert into JTF_UM_APPROVERS (
    APPROVER_ID,
    APPROVAL_ID,
    APPROVER_SEQ,
    EFFECTIVE_START_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    USER_ID,
    ORG_PARTY_ID
  ) values (
    JTF_UM_APPROVERS_S.NEXTVAL,
    X_APPROVAL_ID,
    X_APPROVAL_SEQ,
    X_EFFECTIVE_START_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_USER_ID,
    X_ORG_PARTY_ID
  ) RETURNING APPROVER_ID INTO X_APPROVER_ID;

end INSERT_APPROVERS_ROW;

procedure LOCK_ROW (
  X_APPROVAL_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_APPROVAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      EFFECTIVE_END_DATE,
      APPROVAL_KEY,
      ENABLED_FLAG,
      WF_ITEM_TYPE,
      EFFECTIVE_START_DATE,
      APPLICATION_ID
    from JTF_UM_APPROVALS_B
    where APPROVAL_ID = X_APPROVAL_ID
    for update of APPROVAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      APPROVAL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_UM_APPROVALS_TL
    where APPROVAL_ID = X_APPROVAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPROVAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (   ((recinfo.EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE)
           OR ((recinfo.EFFECTIVE_END_DATE is null) AND (X_EFFECTIVE_END_DATE is null)))
      AND (recinfo.APPROVAL_KEY = X_APPROVAL_KEY)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.WF_ITEM_TYPE = X_WF_ITEM_TYPE)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.APPROVAL_NAME = X_APPROVAL_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_APPROVAL_ID in NUMBER,
  X_APPROVAL_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_APPROVAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USE_PENDING_REQ_FLAG in VARCHAR2
) is
begin
  update JTF_UM_APPROVALS_B set
    APPROVAL_KEY = X_APPROVAL_KEY,
    ENABLED_FLAG = X_ENABLED_FLAG,
    WF_ITEM_TYPE = X_WF_ITEM_TYPE,
    APPLICATION_ID = X_APPLICATION_ID,
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    USE_PENDING_REQ_FLAG = X_USE_PENDING_REQ_FLAG
  where APPROVAL_ID = X_APPROVAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_UM_APPROVALS_TL set
    APPROVAL_NAME = X_APPROVAL_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPROVAL_ID = X_APPROVAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;



--For this procedure, if APPROVAL_ID passed as input is NULL, then create a new record
-- otherwise, modify the existing record.

procedure LOAD_ROW (
    X_APPROVAL_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_WF_ITEM_TYPE 	     IN VARCHAR2,
    X_USE_PENDING_REQ_FLAG   IN VARCHAR2,
    X_APPROVAL_KEY           IN VARCHAR2,
    X_APPROVAL_NAME          IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
  l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
  l_approval_id NUMBER := 0;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
       -- if (x_owner = 'SEED') then
      --          l_user_id := 1;
       -- end if;

	-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


        -- If APPROVAL_ID passed in NULL, insert the record
        if ( X_APPROVAL_ID is NULL ) THEN
           INSERT_ROW(
		X_APPROVAL_ID 		=> l_approval_id,
                X_EFFECTIVE_START_DATE 	=> X_EFFECTIVE_START_DATE,
		X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		X_APPLICATION_ID 	=> X_APPLICATION_ID,
		X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		X_WF_ITEM_TYPE 	        => X_WF_ITEM_TYPE,
    		X_USE_PENDING_REQ_FLAG  => X_USE_PENDING_REQ_FLAG,
		X_APPROVAL_KEY		=> X_APPROVAL_KEY,
		X_APPROVAL_NAME		=> X_APPROVAL_NAME,
		X_DESCRIPTION		=> X_DESCRIPTION,
                X_CREATION_DATE         => f_ludate,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATE_DATE      => f_ludate,
                X_LAST_UPDATED_BY       => f_luby,
                X_LAST_UPDATE_LOGIN     => l_user_id
             );
          else
             -- This select stmnt also checks if
             -- there is a row for this app_id and this app_short_name
             -- Exception is thrown otherwise.
             select LAST_UPDATED_BY, LAST_UPDATE_DATE
               into db_luby, db_ludate
               FROM JTF_UM_APPROVALS_B
              where APPROVAL_ID = X_APPROVAL_ID;

             if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                           db_ludate, X_CUSTOM_MODE)) then

                     UPDATE_ROW(
		          X_APPROVAL_ID 		=> X_APPROVAL_ID,
		          X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		          X_APPLICATION_ID 	=> X_APPLICATION_ID,
		          X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
			  X_WF_ITEM_TYPE 	        => X_WF_ITEM_TYPE,
			  X_USE_PENDING_REQ_FLAG  => X_USE_PENDING_REQ_FLAG,
		          X_APPROVAL_KEY		=> X_APPROVAL_KEY,
		          X_APPROVAL_NAME		=> X_APPROVAL_NAME,
		          X_DESCRIPTION		=> X_DESCRIPTION,
                          X_LAST_UPDATE_DATE      => f_ludate,
			  X_LAST_UPDATED_BY       => f_luby,
			  X_LAST_UPDATE_LOGIN     => l_user_id
                     );

	     end if;
   end if;

end LOAD_ROW;



procedure UPDATE_APPROVERS_ROW (
  X_APPROVER_ID in NUMBER,
  X_APPROVAL_ID in NUMBER,
  X_APPROVAL_SEQ in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USER_ID in NUMBER,
  X_ORG_PARTY_ID in NUMBER
) is
begin
  update JTF_UM_APPROVERS set
    APPROVAL_ID = X_APPROVAL_ID,
    APPROVER_SEQ = X_APPROVAL_SEQ,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    USER_ID = X_USER_ID,
    ORG_PARTY_ID = X_ORG_PARTY_ID
  where APPROVER_ID = X_APPROVER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_APPROVERS_ROW;

-- To overload this API, LAST_UPDATED_BY and LAST_UPDATE_LOGIN have same value and so only 1 is passed
procedure UPDATE_APPROVERS_ROW (
  X_APPROVER_ID in NUMBER,
  X_APPROVAL_ID in NUMBER,
  X_APPROVER_SEQ in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_USER_ID in NUMBER
) is
begin
  update JTF_UM_APPROVERS set
    APPROVAL_ID = X_APPROVAL_ID,
    APPROVER_SEQ = X_APPROVER_SEQ,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATED_BY,
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    USER_ID = X_USER_ID
  where APPROVER_ID = X_APPROVER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_APPROVERS_ROW;

procedure CREATE_APPROVERS_ROW (
  X_APPROVER_ID out NOCOPY NUMBER,
  X_APPROVAL_ID in NUMBER,
  X_APPROVER_SEQ in NUMBER,
  X_USER_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_UM_APPROVERS
    where APPROVER_ID = X_APPROVER_ID
    ;
begin
  insert into JTF_UM_APPROVERS (
    EFFECTIVE_END_DATE,
    APPROVAL_ID,
    USER_ID,
    APPROVER_SEQ,
    EFFECTIVE_START_DATE,
    APPROVER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EFFECTIVE_END_DATE,
    X_APPROVAL_ID,
    X_USER_ID,
    X_APPROVER_SEQ,
    X_EFFECTIVE_START_DATE,
    JTF_UM_APPROVERS_S.NEXTVAL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  ) RETURNING APPROVER_ID INTO X_APPROVER_ID;

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end CREATE_APPROVERS_ROW;

procedure LOAD_APPROVERS_ROW(
  X_APPROVAL_ID	 		IN	NUMBER,
  X_APPROVER_SEQ 		IN	NUMBER,
  X_USER_ID	  		IN	NUMBER,
  X_EFFECTIVE_START_DATE 	IN	DATE,
  X_EFFECTIVE_END_DATE  	IN	DATE,
  X_OWNER    			IN	VARCHAR2,
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL
) is

  l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
  l_approver_id NUMBER := 0;
  h_record_exists NUMBER := 0;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
       -- if (x_owner = 'SEED') then
        --        l_user_id := 1;
       -- end if;

        select count(*)
        into   h_record_exists
        from   JTF_UM_APPROVERS
	where  USER_ID = X_USER_ID
	and    APPROVAL_ID = X_APPROVAL_ID
        and    APPROVER_SEQ = X_APPROVER_SEQ
	and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;

        -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


 -- TRY update, and if it fails, insert

          if ( h_record_exists = 0 ) then

            CREATE_APPROVERS_ROW(
                X_APPROVER_ID		=> l_approver_id,
                X_APPROVAL_ID           => X_APPROVAL_ID,
		X_APPROVER_SEQ		=> X_APPROVER_SEQ,
		X_USER_ID		=> X_USER_ID,
                X_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE,
                X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
                X_CREATION_DATE         => f_ludate,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATE_DATE      => f_ludate,
                X_LAST_UPDATED_BY       => f_luby,
                X_LAST_UPDATE_LOGIN     => l_user_id
             );
          else
              -- selecting the approver_id as it is needed for update
	             select APPROVER_ID
	             into  l_approver_id
	             from   JTF_UM_APPROVERS
	             where  USER_ID = X_USER_ID
	             and    APPROVAL_ID = X_APPROVAL_ID
	             and    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE;




	      -- This select stmnt also checks if
              -- there is a row for this app_id and this app_short_name
              -- Exception is thrown otherwise.
              select LAST_UPDATED_BY, LAST_UPDATE_DATE
                into db_luby, db_ludate
                FROM JTF_UM_APPROVERS
                where APPROVER_ID = l_approver_id;

              if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


                     UPDATE_APPROVERS_ROW(
                          X_APPROVER_ID		=> l_approver_id,
                          X_APPROVAL_ID           => X_APPROVAL_ID,
		          X_APPROVER_SEQ		=> X_APPROVER_SEQ,
		          X_USER_ID		=> X_USER_ID,
                          X_EFFECTIVE_END_DATE    => X_EFFECTIVE_END_DATE,
                          X_LAST_UPDATE_DATE      => f_ludate,
			  X_LAST_UPDATED_BY       => f_luby
		     );
              end if;

       end if;

end LOAD_APPROVERS_ROW;

procedure DELETE_ROW (
  X_APPROVAL_ID in NUMBER
) is
begin
  delete from JTF_UM_APPROVALS_TL
  where APPROVAL_ID = X_APPROVAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_UM_APPROVALS_B
  where APPROVAL_ID = X_APPROVAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure DELETE_APPROVERS_ROW (
  X_APPROVER_ID in NUMBER
) is
begin
  delete from JTF_UM_APPROVERS
  where APPROVER_ID = X_APPROVER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_APPROVERS_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_UM_APPROVALS_TL T
  where not exists
    (select NULL
    from JTF_UM_APPROVALS_B B
    where B.APPROVAL_ID = T.APPROVAL_ID
    );

  update JTF_UM_APPROVALS_TL T set (
      APPROVAL_NAME,
      DESCRIPTION
    ) = (select
      B.APPROVAL_NAME,
      B.DESCRIPTION
    from JTF_UM_APPROVALS_TL B
    where B.APPROVAL_ID = T.APPROVAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPROVAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPROVAL_ID,
      SUBT.LANGUAGE
    from JTF_UM_APPROVALS_TL SUBB, JTF_UM_APPROVALS_TL SUBT
    where SUBB.APPROVAL_ID = SUBT.APPROVAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.APPROVAL_NAME <> SUBT.APPROVAL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_UM_APPROVALS_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    APPROVAL_ID,
    APPROVAL_NAME,
    APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.APPROVAL_ID,
    B.APPROVAL_NAME,
    B.APPLICATION_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_UM_APPROVALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_UM_APPROVALS_TL T
    where T.APPROVAL_ID = B.APPROVAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPROVAL_ID in NUMBER, -- key field
  X_APPROVAL_NAME in VARCHAR2, -- translated name
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
      FROM JTF_UM_APPROVALS_TL
      where APPROVAL_ID = X_APPROVAL_ID
      and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
    update JTF_UM_APPROVALS_TL set
	APPROVAL_NAME 	  = X_APPROVAL_NAME,
	DESCRIPTION       = X_DESCRIPTION,
	LAST_UPDATE_DATE  = f_ludate,
	LAST_UPDATED_BY   = f_luby,
	LAST_UPDATE_LOGIN = 0,
	SOURCE_LANG       = userenv('LANG')
  where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  	and APPROVAL_ID = X_APPROVAL_ID;
end if;

end TRANSLATE_ROW;

function is_approval_overridden(
   				p_approval_id IN NUMBER,
				p_org_party_id IN NUMBER
				)
return varchar2 is
cursor ap is select approval_id from jtf_um_approvers
where approval_id = p_approval_id
and   org_party_id = p_org_party_id
and   (effective_end_date is null or effective_end_date > sysdate);
p_result varchar2(1):= 'N';
p_ap_id NUMBER:= -1;
begin

  open ap;
   fetch ap into p_ap_id;
  close ap;

  if p_ap_id <> -1 then
  p_result := 'Y';
  end if;
return p_result;
end is_approval_overridden;

end JTF_UM_APPROVALS_PKG;

/
