--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_TYPES_PKG" as
/* $Header: XDPATYPB.pls 120.2 2005/07/14 05:18:53 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_ADAPTER_TYPES_B
    where ADAPTER_TYPE = X_ADAPTER_TYPE
    ;
begin
  insert into XDP_ADAPTER_TYPES_B (
    ADAPTER_TYPE,
    ADAPTER_CLASS,
    BASE_ADAPTER_TYPE,
    APPLICATION_MODE,
    INBOUND_REQUIRED_FLAG,
    CONNECTION_REQUIRED_FLAG,
    MAX_BUFFER_SIZE,
    CMD_LINE_OPTIONS,
    CMD_LINE_ARGS,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ADAPTER_TYPE,
    X_ADAPTER_CLASS,
    X_BASE_ADAPTER_TYPE,
    X_APPLICATION_MODE,
    X_INBOUND_REQUIRED_FLAG,
    X_CONNECTION_REQUIRED_FLAG,
    X_MAX_BUFFER_SIZE,
    X_CMD_LINE_OPTIONS,
    X_CMD_LINE_ARGS,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_ADAPTER_TYPES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ADAPTER_TYPE,
    DISPLAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_ADAPTER_TYPE,
    X_DISPLAY_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XDP_ADAPTER_TYPES_TL T
    where T.ADAPTER_TYPE = X_ADAPTER_TYPE
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
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      ADAPTER_CLASS,
      BASE_ADAPTER_TYPE,
      APPLICATION_MODE,
      INBOUND_REQUIRED_FLAG,
      CONNECTION_REQUIRED_FLAG,
      MAX_BUFFER_SIZE,
      CMD_LINE_OPTIONS,
      CMD_LINE_ARGS,
      OBJECT_VERSION_NUMBER
    from XDP_ADAPTER_TYPES_B
    where ADAPTER_TYPE = X_ADAPTER_TYPE
    for update of ADAPTER_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_ADAPTER_TYPES_TL
    where ADAPTER_TYPE = X_ADAPTER_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ADAPTER_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ADAPTER_CLASS = X_ADAPTER_CLASS)
      AND (recinfo.APPLICATION_MODE = X_APPLICATION_MODE)
      AND (recinfo.INBOUND_REQUIRED_FLAG = X_INBOUND_REQUIRED_FLAG)
      AND (recinfo.CONNECTION_REQUIRED_FLAG = X_CONNECTION_REQUIRED_FLAG)
      AND ((recinfo.MAX_BUFFER_SIZE = X_MAX_BUFFER_SIZE)
           OR ((recinfo.MAX_BUFFER_SIZE is null) AND (X_MAX_BUFFER_SIZE is null)))
      AND ((recinfo.CMD_LINE_OPTIONS = X_CMD_LINE_OPTIONS)
           OR ((recinfo.CMD_LINE_OPTIONS is null) AND (X_CMD_LINE_OPTIONS is null)))
      AND ((recinfo.CMD_LINE_ARGS = X_CMD_LINE_ARGS)
           OR ((recinfo.CMD_LINE_ARGS is null) AND (X_CMD_LINE_ARGS is null)))
      AND ((recinfo.BASE_ADAPTER_TYPE = X_BASE_ADAPTER_TYPE)
           OR ((recinfo.BASE_ADAPTER_TYPE is null) AND (X_BASE_ADAPTER_TYPE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
               OR ((tlinfo.DISPLAY_NAME is null) AND (X_DISPLAY_NAME is null)))
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
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_ADAPTER_TYPES_B set
    ADAPTER_CLASS = X_ADAPTER_CLASS,
    BASE_ADAPTER_TYPE = X_BASE_ADAPTER_TYPE,
    APPLICATION_MODE = X_APPLICATION_MODE,
    INBOUND_REQUIRED_FLAG = X_INBOUND_REQUIRED_FLAG,
    CONNECTION_REQUIRED_FLAG = X_CONNECTION_REQUIRED_FLAG,
    MAX_BUFFER_SIZE = X_MAX_BUFFER_SIZE,
    CMD_LINE_OPTIONS = X_CMD_LINE_OPTIONS,
    CMD_LINE_ARGS = X_CMD_LINE_ARGS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ADAPTER_TYPE = X_ADAPTER_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_ADAPTER_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ADAPTER_TYPE = X_ADAPTER_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ADAPTER_TYPE in VARCHAR2
) is
begin
  delete from XDP_ADAPTER_TYPES_TL
  where ADAPTER_TYPE = X_ADAPTER_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_ADAPTER_TYPES_B
  where ADAPTER_TYPE = X_ADAPTER_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_ADAPTER_TYPES_TL T
  where not exists
    (select NULL
    from XDP_ADAPTER_TYPES_B B
    where B.ADAPTER_TYPE = T.ADAPTER_TYPE
    );

  update XDP_ADAPTER_TYPES_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from XDP_ADAPTER_TYPES_TL B
    where B.ADAPTER_TYPE = T.ADAPTER_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ADAPTER_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.ADAPTER_TYPE,
      SUBT.LANGUAGE
    from XDP_ADAPTER_TYPES_TL SUBB, XDP_ADAPTER_TYPES_TL SUBT
    where SUBB.ADAPTER_TYPE = SUBT.ADAPTER_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or (SUBB.DISPLAY_NAME is null and SUBT.DISPLAY_NAME is not null)
      or (SUBB.DISPLAY_NAME is not null and SUBT.DISPLAY_NAME is null)
  ));

  insert into XDP_ADAPTER_TYPES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ADAPTER_TYPE,
    DISPLAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.ADAPTER_TYPE,
    B.DISPLAY_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_ADAPTER_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_ADAPTER_TYPES_TL T
    where T.ADAPTER_TYPE = B.ADAPTER_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
	X_ADAPTER_TYPE in VARCHAR2,
	X_ADAPTER_CLASS in VARCHAR2,
	X_BASE_ADAPTER_TYPE in VARCHAR2,
	X_APPLICATION_MODE in VARCHAR2,
	X_INBOUND_REQUIRED_FLAG in VARCHAR2,
	X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
	X_CMD_LINE_OPTIONS in VARCHAR2,
	X_CMD_LINE_ARGS in VARCHAR2,
	X_MAX_BUFFER_SIZE in NUMBER,
	X_DISPLAY_NAME in VARCHAR2,
	X_OWNER in VARCHAR2) IS
BEGIN

  DECLARE
     user_id            NUMBER := 0;
     row_id             VARCHAR2(64);

  BEGIN

     /* The following derivation has been replaced with the FND API.		dputhiye 14-JUL-2005. R12 ATG "Seed Version by Date" Uptake */
     --IF (X_OWNER = 'SEED') THEN
     --   user_id := 1;
     --END IF;
     user_id := fnd_load_util.owner_id(X_OWNER);

     XDP_ADAPTER_TYPES_PKG.UPDATE_ROW (
	            X_ADAPTER_TYPE => X_ADAPTER_TYPE,
	            X_ADAPTER_CLASS => X_ADAPTER_CLASS,
	            X_BASE_ADAPTER_TYPE => X_BASE_ADAPTER_TYPE,
	            X_APPLICATION_MODE => X_APPLICATION_MODE,
	            X_INBOUND_REQUIRED_FLAG => X_INBOUND_REQUIRED_FLAG,
	            X_CONNECTION_REQUIRED_FLAG => X_CONNECTION_REQUIRED_FLAG,
	            X_MAX_BUFFER_SIZE => X_MAX_BUFFER_SIZE,
	            X_CMD_LINE_OPTIONS => X_CMD_LINE_OPTIONS,
	            X_CMD_LINE_ARGS => X_CMD_LINE_ARGS,
  				X_OBJECT_VERSION_NUMBER => null,
	            X_DISPLAY_NAME => X_DISPLAY_NAME,
        		X_LAST_UPDATE_DATE => sysdate,
		        X_LAST_UPDATED_BY => user_id,
		        X_LAST_UPDATE_LOGIN => 0);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          XDP_ADAPTER_TYPES_PKG.INSERT_ROW (
				X_ROWID => row_id,
				X_ADAPTER_TYPE => X_ADAPTER_TYPE,
				X_ADAPTER_CLASS => X_ADAPTER_CLASS,
				X_BASE_ADAPTER_TYPE => X_BASE_ADAPTER_TYPE,
				X_APPLICATION_MODE => X_APPLICATION_MODE,
				X_INBOUND_REQUIRED_FLAG => X_INBOUND_REQUIRED_FLAG,
				X_CONNECTION_REQUIRED_FLAG => X_CONNECTION_REQUIRED_FLAG,
				X_MAX_BUFFER_SIZE => X_MAX_BUFFER_SIZE,
				X_CMD_LINE_OPTIONS => X_CMD_LINE_OPTIONS,
				X_CMD_LINE_ARGS => X_CMD_LINE_ARGS,
  				X_OBJECT_VERSION_NUMBER => null,
				X_DISPLAY_NAME => X_DISPLAY_NAME,
				X_CREATION_DATE => sysdate,
				X_CREATED_BY => user_id,
				X_LAST_UPDATE_DATE => sysdate,
				X_LAST_UPDATED_BY => user_id,
				X_LAST_UPDATE_LOGIN => 0);
   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
   X_ADAPTER_TYPE in VARCHAR2,
   X_DISPLAY_NAME in VARCHAR2,
   X_OWNER in VARCHAR2) IS

BEGIN
    -- only update rows that have not been altered by user

    UPDATE XDP_ADAPTER_TYPES_TL
    SET display_name = X_DISPLAY_NAME,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 14-JUL-2005. DECODE replaced with FND API.*/
	last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
    where adapter_type = X_ADAPTER_TYPE
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end XDP_ADAPTER_TYPES_PKG;

/
