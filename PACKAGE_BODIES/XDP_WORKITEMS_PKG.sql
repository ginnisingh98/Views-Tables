--------------------------------------------------------
--  DDL for Package Body XDP_WORKITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_WORKITEMS_PKG" as
/* $Header: XDPWIB.pls 120.2 2005/07/15 06:31:42 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_WORKITEM_ID in NUMBER,
  X_WORKITEM_NAME in VARCHAR2,
  X_VERSION in VARCHAR2,
  X_WI_TYPE_CODE in VARCHAR2,
  X_VALID_DATE in DATE,
  X_INVALID_DATE in DATE,
  X_VALIDATION_ENABLED_FLAG in VARCHAR2,
  X_VALIDATION_PROCEDURE in VARCHAR2,
  X_FA_EXEC_MAP_PROC in VARCHAR2,
  X_USER_WF_ITEM_TYPE in VARCHAR2,
  X_USER_WF_ITEM_KEY_PREFIX in VARCHAR2,
  X_USER_WF_PROCESS_NAME in VARCHAR2,
  X_WF_EXEC_PROC in VARCHAR2,
  X_TIME_ESTIMATE in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_WORKITEMS
    where WORKITEM_ID = X_WORKITEM_ID
    ;
begin
  insert into XDP_WORKITEMS (
    WORKITEM_ID,
    WORKITEM_NAME,
    VERSION,
    WI_TYPE_CODE,
    VALID_DATE,
    INVALID_DATE,
    VALIDATION_ENABLED_FLAG,
    VALIDATION_PROCEDURE,
    FA_EXEC_MAP_PROC,
    USER_WF_ITEM_TYPE,
    USER_WF_ITEM_KEY_PREFIX,
    USER_WF_PROCESS_NAME,
    WF_EXEC_PROC,
    TIME_ESTIMATE,
    PROTECTED_FLAG,
    ROLE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_WORKITEM_ID,
    X_WORKITEM_NAME,
    X_VERSION,
    X_WI_TYPE_CODE,
    X_VALID_DATE,
    X_INVALID_DATE,
    X_VALIDATION_ENABLED_FLAG,
    X_VALIDATION_PROCEDURE,
    X_FA_EXEC_MAP_PROC,
    X_USER_WF_ITEM_TYPE,
    X_USER_WF_ITEM_KEY_PREFIX,
    X_USER_WF_PROCESS_NAME,
    X_WF_EXEC_PROC,
    X_TIME_ESTIMATE,
    X_PROTECTED_FLAG,
    X_ROLE_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_WORKITEMS_TL (
    WORKITEM_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_WORKITEM_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XDP_WORKITEMS_TL T
    where T.WORKITEM_ID = X_WORKITEM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_WORKITEM_ID in NUMBER,
  X_WORKITEM_NAME in VARCHAR2,
  X_VERSION in VARCHAR2,
  X_WI_TYPE_CODE in VARCHAR2,
  X_VALID_DATE in DATE,
  X_INVALID_DATE in DATE,
  X_VALIDATION_ENABLED_FLAG in VARCHAR2,
  X_VALIDATION_PROCEDURE in VARCHAR2,
  X_FA_EXEC_MAP_PROC in VARCHAR2,
  X_USER_WF_ITEM_TYPE in VARCHAR2,
  X_USER_WF_ITEM_KEY_PREFIX in VARCHAR2,
  X_USER_WF_PROCESS_NAME in VARCHAR2,
  X_WF_EXEC_PROC in VARCHAR2,
  X_TIME_ESTIMATE in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      WORKITEM_NAME,
      VERSION,
      WI_TYPE_CODE,
      VALID_DATE,
      INVALID_DATE,
      VALIDATION_ENABLED_FLAG,
      VALIDATION_PROCEDURE,
      FA_EXEC_MAP_PROC,
      USER_WF_ITEM_TYPE,
      USER_WF_ITEM_KEY_PREFIX,
      USER_WF_PROCESS_NAME,
      WF_EXEC_PROC,
      TIME_ESTIMATE,
      PROTECTED_FLAG,
      ROLE_NAME
    from XDP_WORKITEMS
    where WORKITEM_ID = X_WORKITEM_ID
    for update of WORKITEM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_WORKITEMS_TL
    where WORKITEM_ID = X_WORKITEM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of WORKITEM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.WORKITEM_NAME = X_WORKITEM_NAME)
      AND (recinfo.VERSION = X_VERSION)
  AND ((recinfo.VALIDATION_PROCEDURE = X_VALIDATION_PROCEDURE)
           OR ((recinfo.VALIDATION_PROCEDURE is null) AND (X_VALIDATION_PROCEDURE is null)))
      AND (recinfo.VALIDATION_ENABLED_FLAG = X_VALIDATION_ENABLED_FLAG)
      AND (recinfo.WI_TYPE_CODE = X_WI_TYPE_CODE)
      AND ((recinfo.VALID_DATE = X_VALID_DATE)
           OR ((recinfo.VALID_DATE is null) AND (X_VALID_DATE is null)))
      AND ((recinfo.INVALID_DATE = X_INVALID_DATE)
           OR ((recinfo.INVALID_DATE is null) AND (X_INVALID_DATE is null)))
      AND ((recinfo.FA_EXEC_MAP_PROC = X_FA_EXEC_MAP_PROC)
           OR ((recinfo.FA_EXEC_MAP_PROC is null) AND (X_FA_EXEC_MAP_PROC is null)))
      AND ((recinfo.USER_WF_ITEM_TYPE = X_USER_WF_ITEM_TYPE)
           OR ((recinfo.USER_WF_ITEM_TYPE is null) AND (X_USER_WF_ITEM_TYPE is null)))
      AND ((recinfo.USER_WF_ITEM_KEY_PREFIX = X_USER_WF_ITEM_KEY_PREFIX)
           OR ((recinfo.USER_WF_ITEM_KEY_PREFIX is null) AND (X_USER_WF_ITEM_KEY_PREFIX is null)))
      AND ((recinfo.USER_WF_PROCESS_NAME = X_USER_WF_PROCESS_NAME)
           OR ((recinfo.USER_WF_PROCESS_NAME is null) AND (X_USER_WF_PROCESS_NAME is null)))
      AND ((recinfo.WF_EXEC_PROC = X_WF_EXEC_PROC)
           OR ((recinfo.WF_EXEC_PROC is null) AND (X_WF_EXEC_PROC is null)))
      AND ((recinfo.TIME_ESTIMATE = X_TIME_ESTIMATE)
           OR ((recinfo.TIME_ESTIMATE is null) AND (X_TIME_ESTIMATE is null)))
      AND (recinfo.PROTECTED_FLAG = X_PROTECTED_FLAG)
      AND ((recinfo.ROLE_NAME = X_ROLE_NAME)
           OR ((recinfo.ROLE_NAME is null) AND (X_ROLE_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_WORKITEM_ID in NUMBER,
  X_WORKITEM_NAME in VARCHAR2,
  X_VERSION in VARCHAR2,
  X_WI_TYPE_CODE in VARCHAR2,
  X_VALID_DATE in DATE,
  X_INVALID_DATE in DATE,
  X_VALIDATION_ENABLED_FLAG in VARCHAR2,
  X_VALIDATION_PROCEDURE in VARCHAR2,
  X_FA_EXEC_MAP_PROC in VARCHAR2,
  X_USER_WF_ITEM_TYPE in VARCHAR2,
  X_USER_WF_ITEM_KEY_PREFIX in VARCHAR2,
  X_USER_WF_PROCESS_NAME in VARCHAR2,
  X_WF_EXEC_PROC in VARCHAR2,
  X_TIME_ESTIMATE in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_WORKITEMS set
    WORKITEM_NAME = X_WORKITEM_NAME,
    VERSION = X_VERSION,
    WI_TYPE_CODE = X_WI_TYPE_CODE,
    VALID_DATE = X_VALID_DATE,
    INVALID_DATE = X_INVALID_DATE,
    VALIDATION_ENABLED_FLAG = X_VALIDATION_ENABLED_FLAG,
    VALIDATION_PROCEDURE = X_VALIDATION_PROCEDURE,
    FA_EXEC_MAP_PROC = X_FA_EXEC_MAP_PROC,
    USER_WF_ITEM_TYPE = X_USER_WF_ITEM_TYPE,
    USER_WF_ITEM_KEY_PREFIX = X_USER_WF_ITEM_KEY_PREFIX,
    USER_WF_PROCESS_NAME = X_USER_WF_PROCESS_NAME,
    WF_EXEC_PROC = X_WF_EXEC_PROC,
    TIME_ESTIMATE = X_TIME_ESTIMATE,
    PROTECTED_FLAG = X_PROTECTED_FLAG,
    ROLE_NAME = X_ROLE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where WORKITEM_ID = X_WORKITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_WORKITEMS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WORKITEM_ID = X_WORKITEM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WORKITEM_ID in NUMBER
) is
begin
  delete from XDP_WORKITEMS_TL
  where WORKITEM_ID = X_WORKITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_WORKITEMS
  where WORKITEM_ID = X_WORKITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_WORKITEMS_TL T
  where not exists
    (select NULL
    from XDP_WORKITEMS B
    where B.WORKITEM_ID = T.WORKITEM_ID
    );

  update XDP_WORKITEMS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_WORKITEMS_TL B
    where B.WORKITEM_ID = T.WORKITEM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WORKITEM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WORKITEM_ID,
      SUBT.LANGUAGE
    from XDP_WORKITEMS_TL SUBB, XDP_WORKITEMS_TL SUBT
    where SUBB.WORKITEM_ID = SUBT.WORKITEM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_WORKITEMS_TL (
    WORKITEM_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WORKITEM_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_WORKITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_WORKITEMS_TL T
    where T.WORKITEM_ID = B.WORKITEM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_WORKITEM_ID in NUMBER,
  X_WORKITEM_NAME in VARCHAR2,
  X_VERSION in VARCHAR2,
  X_WI_TYPE_CODE in VARCHAR2,
  X_VALID_DATE in DATE,
  X_INVALID_DATE in DATE,
  X_VALIDATION_ENABLED_FLAG in VARCHAR2,
  X_VALIDATION_PROCEDURE in VARCHAR2,
  X_FA_EXEC_MAP_PROC in VARCHAR2,
  X_USER_WF_ITEM_TYPE in VARCHAR2,
  X_USER_WF_ITEM_KEY_PREFIX in VARCHAR2,
  X_USER_WF_PROCESS_NAME in VARCHAR2,
  X_WF_EXEC_PROC in VARCHAR2,
  X_TIME_ESTIMATE in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     /* The following derivation has been replaced with the FND API.		dputhiye 15-JUL-2005. R12 ATG "Seed Version by Date" Uptake */
     --if (X_OWNER = 'SEED') then
     --   user_id := 1;
     --end if;
     user_id := fnd_load_util.owner_id(X_OWNER);

     XDP_WORKITEMS_PKG.UPDATE_ROW (
  	X_WORKITEM_ID => X_WORKITEM_ID,
  	X_WORKITEM_NAME => X_WORKITEM_NAME,
  	X_VERSION => X_VERSION,
  	X_WI_TYPE_CODE => X_WI_TYPE_CODE,
  	X_VALID_DATE => X_VALID_DATE,
  	X_INVALID_DATE => X_INVALID_DATE,
        X_VALIDATION_ENABLED_FLAG =>X_VALIDATION_ENABLED_FLAG,
        X_VALIDATION_PROCEDURE => X_VALIDATION_PROCEDURE,
  	X_FA_EXEC_MAP_PROC => X_FA_EXEC_MAP_PROC,
  	X_USER_WF_ITEM_TYPE => X_USER_WF_ITEM_TYPE,
  	X_USER_WF_ITEM_KEY_PREFIX => X_USER_WF_ITEM_KEY_PREFIX,
  	X_USER_WF_PROCESS_NAME => X_USER_WF_PROCESS_NAME,
  	X_WF_EXEC_PROC => X_WF_EXEC_PROC,
  	X_TIME_ESTIMATE => X_TIME_ESTIMATE,
  	X_PROTECTED_FLAG => X_PROTECTED_FLAG,
  	X_ROLE_NAME => X_ROLE_NAME,
  	X_DISPLAY_NAME => X_DISPLAY_NAME,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_WORKITEMS_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  		X_WORKITEM_ID => X_WORKITEM_ID,
  		X_WORKITEM_NAME => X_WORKITEM_NAME,
  		X_VERSION => X_VERSION,
  		X_WI_TYPE_CODE => X_WI_TYPE_CODE,
  		X_VALID_DATE => X_VALID_DATE,
  		X_INVALID_DATE => X_INVALID_DATE,
                X_VALIDATION_ENABLED_FLAG =>X_VALIDATION_ENABLED_FLAG,
                X_VALIDATION_PROCEDURE => X_VALIDATION_PROCEDURE,
  		X_FA_EXEC_MAP_PROC => X_FA_EXEC_MAP_PROC,
  		X_USER_WF_ITEM_TYPE => X_USER_WF_ITEM_TYPE,
  		X_USER_WF_ITEM_KEY_PREFIX => X_USER_WF_ITEM_KEY_PREFIX,
  		X_USER_WF_PROCESS_NAME => X_USER_WF_PROCESS_NAME,
  		X_WF_EXEC_PROC => X_WF_EXEC_PROC,
  		X_TIME_ESTIMATE => X_TIME_ESTIMATE,
  		X_PROTECTED_FLAG => X_PROTECTED_FLAG,
  		X_ROLE_NAME => X_ROLE_NAME,
  		X_DISPLAY_NAME => X_DISPLAY_NAME,
  		X_DESCRIPTION => X_DESCRIPTION,
             	X_CREATION_DATE => sysdate,
             	X_CREATED_BY => user_id,
             	X_LAST_UPDATE_DATE => sysdate,
             	X_LAST_UPDATED_BY => user_id,
             	X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_WORKITEM_ID in NUMBER,
   X_DISPLAY_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_WORKITEMS_TL
    set  description = X_DESCRIPTION,
        display_name = X_DISPLAY_NAME,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 15-JUL-2005. DECODE replaced with FND API.*/
	last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
  where workitem_id = X_WORKITEM_ID
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end XDP_WORKITEMS_PKG;

/
