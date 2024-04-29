--------------------------------------------------------
--  DDL for Package Body ECX_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TRANSACTIONS_PKG" as
/* $Header: ECXTXNB.pls 120.2.12000000.3 2007/07/20 07:41:17 susaha ship $ */

procedure TRANSLATE_ROW(
  X_TRANSACTION_TYPE              IN      VARCHAR2,
  X_TRANSACTION_SUBTYPE           IN      VARCHAR2,
  X_PARTY_TYPE                    IN      VARCHAR2,
  X_TRANSACTION_DESCRIPTION       IN      VARCHAR2,
  X_OWNER                         IN      VARCHAR2,
  X_CUSTOM_MODE                   IN      VARCHAR2
)
is
  l_luby            number;  -- entity owner in file
  l_ludate          date;    -- entity update date in file
  l_db_luby         number;  -- entity owner in db
  l_db_ludate       date;    -- entity update date in db
  l_transaction_id  number;
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_luby := 1;
  else
    l_luby := 0;
  end if;
  -- Translate char last_update_date to date
  l_ludate := sysdate;

  begin
    select transaction_id
      into l_transaction_id
      from ecx_transactions
     where transaction_type = X_TRANSACTION_TYPE
      and transaction_subtype = X_TRANSACTION_SUBTYPE
      and party_type = X_PARTY_TYPE;

    select last_updated_by, last_update_date
    into l_db_luby, l_db_ludate
    from ecx_transactions_tl
    where transaction_id = l_transaction_id
      and LANGUAGE = userenv('LANG');

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
        ((l_luby = 0) and (l_db_luby = 1)) or
        ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
        update ECX_TRANSACTIONS_TL  set
          TRANSACTION_DESCRIPTION  = nvl(X_TRANSACTION_DESCRIPTION, TRANSACTION_DESCRIPTION),
          SOURCE_LANG              = userenv('LANG'),
          LAST_UPDATE_DATE         = l_ludate,
          LAST_UPDATED_BY          = l_luby,
          LAST_UPDATE_LOGIN        = 0
        where TRANSACTION_ID = L_TRANSACTION_ID
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TRANSACTION_TYPE              IN      VARCHAR2,
  X_TRANSACTION_SUBTYPE           IN      VARCHAR2,
  X_PARTY_TYPE                    IN      VARCHAR2,
  X_TRANSACTION_DESCRIPTION       IN      VARCHAR2,
  X_ADMIN_USER                    IN      VARCHAR2 DEFAULT NULL,
  X_OWNER                         IN      VARCHAR2,
  X_CUSTOM_MODE                   IN      VARCHAR2
)
is
  l_row_id             varchar2(64);
  l_ret_code           pls_integer := 0;
  l_errmsg             varchar2(2000) := null;
  l_transaction_id     pls_integer := -1;
  l_luby               number;  -- entity owner in file
  l_ludate             date;    -- entity update date in file
  l_db_luby            number;  -- entity owner in db
  l_db_ludate          date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_luby := 1;
  else
    l_luby := 0;
  end if;

  -- Translate char last_update_date to date
  l_ludate := sysdate;

  begin
    select TRANSACTION_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE
      into l_transaction_id,
           l_db_luby,
           l_db_ludate
      from ECX_TRANSACTIONS_B
     where TRANSACTION_TYPE = X_TRANSACTION_TYPE
       and TRANSACTION_SUBTYPE = X_TRANSACTION_SUBTYPE
       and PARTY_TYPE = X_PARTY_TYPE;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
       ((l_luby = 0) and (l_db_luby = 1)) or
       ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
        ecx_transactions_api.update_transaction (
          X_RETURN_STATUS               => l_ret_code,
          X_MSG                         => l_errmsg,
          P_TRANSACTION_ID              => l_transaction_id,
          P_TRANSACTION_TYPE 		=> X_TRANSACTION_TYPE,
	  P_TRANSACTION_SUBTYPE		=> X_TRANSACTION_SUBTYPE,
	  P_PARTY_TYPE			=> X_PARTY_TYPE,
	  P_TRANSACTION_DESCRIPTION 	=> X_TRANSACTION_DESCRIPTION,
          P_OWNER    	                => X_OWNER);

         if (l_ret_code <> ECX_UTIL_API.G_NO_ERROR) then
           raise_application_error(-20000, l_errmsg);
         end if;
    end if;
    exception
    when no_data_found then
        ecx_transactions_api.create_transaction (
          x_return_status           => l_ret_code,
          x_msg                     => l_errmsg,
          x_transaction_id          => l_transaction_id,
          p_transaction_type        => X_TRANSACTION_TYPE,
          p_transaction_subtype     => X_TRANSACTION_SUBTYPE,
          p_transaction_description => X_TRANSACTION_DESCRIPTION,
          p_admin_user              => X_ADMIN_USER,
          p_party_type              => X_PARTY_TYPE,
          p_owner                   => X_OWNER);

        if (l_ret_code <> ECX_UTIL_API.G_NO_ERROR) then
           raise_application_error(-20000, l_errmsg);
        end if;
  end;

end LOAD_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2,
  X_ADMIN_USER    in VARCHAR2 DEFAULT NULL,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ECX_TRANSACTIONS_B
    where TRANSACTION_ID = X_TRANSACTION_ID
    ;
begin
  insert into ECX_TRANSACTIONS_B (
    TRANSACTION_ID,
    TRANSACTION_TYPE,
    TRANSACTION_SUBTYPE,
    PARTY_TYPE,
    ADMIN_USER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TRANSACTION_ID,
    X_TRANSACTION_TYPE,
    X_TRANSACTION_SUBTYPE,
    X_PARTY_TYPE,
    X_ADMIN_USER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ECX_TRANSACTIONS_TL (
    TRANSACTION_ID,
    TRANSACTION_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TRANSACTION_ID,
    X_TRANSACTION_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG ='Y'
  and not exists
    (select NULL
    from ECX_TRANSACTIONS_TL T
    where T.TRANSACTION_ID = X_TRANSACTION_ID
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TRANSACTION_TYPE,
      TRANSACTION_SUBTYPE,
      PARTY_TYPE
    from ECX_TRANSACTIONS_B
    where TRANSACTION_ID = X_TRANSACTION_ID
    for update of TRANSACTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TRANSACTION_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ECX_TRANSACTIONS_TL
    where TRANSACTION_ID = X_TRANSACTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TRANSACTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TRANSACTION_TYPE = X_TRANSACTION_TYPE)
      AND (recinfo.TRANSACTION_SUBTYPE = X_TRANSACTION_SUBTYPE)
      AND (recinfo.PARTY_TYPE = X_PARTY_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TRANSACTION_DESCRIPTION = X_TRANSACTION_DESCRIPTION)
               OR ((tlinfo.TRANSACTION_DESCRIPTION is null) AND (X_TRANSACTION_DESCRIPTION is null)))
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
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2,
  X_ADMIN_USER in VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ECX_TRANSACTIONS_B set
    TRANSACTION_TYPE = X_TRANSACTION_TYPE,
    TRANSACTION_SUBTYPE = X_TRANSACTION_SUBTYPE,
    PARTY_TYPE = X_PARTY_TYPE,
    ADMIN_USER = X_ADMIN_USER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TRANSACTION_ID = X_TRANSACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ECX_TRANSACTIONS_TL set
    TRANSACTION_DESCRIPTION = X_TRANSACTION_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TRANSACTION_ID = X_TRANSACTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TRANSACTION_ID in NUMBER
) is
begin
  delete from ECX_TRANSACTIONS_TL
  where TRANSACTION_ID = X_TRANSACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ECX_TRANSACTIONS_B
  where TRANSACTION_ID = X_TRANSACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ECX_TRANSACTIONS_TL T
  where not exists
    (select NULL
    from ECX_TRANSACTIONS_B B
    where B.TRANSACTION_ID = T.TRANSACTION_ID
    );

  update ECX_TRANSACTIONS_TL T set (
      TRANSACTION_DESCRIPTION
    ) = (select
      B.TRANSACTION_DESCRIPTION
    from ECX_TRANSACTIONS_TL B
    where B.TRANSACTION_ID = T.TRANSACTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TRANSACTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TRANSACTION_ID,
      SUBT.LANGUAGE
    from ECX_TRANSACTIONS_TL SUBB, ECX_TRANSACTIONS_TL SUBT
    where SUBB.TRANSACTION_ID = SUBT.TRANSACTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TRANSACTION_DESCRIPTION <> SUBT.TRANSACTION_DESCRIPTION
      or (SUBB.TRANSACTION_DESCRIPTION is null and SUBT.TRANSACTION_DESCRIPTION is not null)
      or (SUBB.TRANSACTION_DESCRIPTION is not null and SUBT.TRANSACTION_DESCRIPTION is null)));

  insert into ECX_TRANSACTIONS_TL (
    TRANSACTION_ID,
    TRANSACTION_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TRANSACTION_ID,
    B.TRANSACTION_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.CODE,
    B.SOURCE_LANG
  from ECX_TRANSACTIONS_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ECX_TRANSACTIONS_TL T
    where T.TRANSACTION_ID = B.TRANSACTION_ID
    and T.LANGUAGE = L.CODE);
end ADD_LANGUAGE;

end ECX_TRANSACTIONS_PKG;

/
