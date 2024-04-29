--------------------------------------------------------
--  DDL for Package Body PER_CAGR_API_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAGR_API_PARAMETERS_PKG" as
/* $Header: pecaplct.pkb 120.1.12000000.2 2007/05/15 08:52:52 ghshanka ship $ */


procedure KEY_TO_IDS (
  X_DISPLAY_NAME  in VARCHAR2,
  X_API_NAME      in VARCHAR2,
  X_CAGR_API_PARAM_ID out nocopy NUMBER,
  X_CAGR_API_ID    out nocopy NUMBER

) is

  cursor CSR_CAGR_API(  X_API_NAME VARCHAR2    ) is
    select API.CAGR_API_ID
    from PER_CAGR_APIS API
    where API.API_NAME = X_API_NAME;

  cursor CSR_CAGR_DISPLAY_NAME (  X_DISPLAY_NAME VARCHAR2,   X_API_NAME   VARCHAR2     ) is
    select cap.CAGR_API_PARAM_ID
    from PER_CAGR_API_PARAMETERS cap,
         PER_CAGR_APIS api
    where cap.DISPLAY_NAME = X_DISPLAY_NAME
    and   cap.cagr_api_id  = api.cagr_Api_id
    and   api.api_name = X_API_NAME;

  cursor CSR_SEQUENCE is
    select PER_CAGR_API_PARAMETERS_S.nextval
    from   dual;

begin
   open CSR_CAGR_API (    X_API_NAME );
  fetch CSR_CAGR_API into X_CAGR_API_ID;

  open CSR_CAGR_DISPLAY_NAME (    X_DISPLAY_NAME, X_API_NAME );
  fetch CSR_CAGR_DISPLAY_NAME into X_CAGR_API_PARAM_ID;

  if (CSR_CAGR_DISPLAY_NAME%notfound) then
    open CSR_SEQUENCE;
    fetch CSR_SEQUENCE into X_CAGR_API_PARAM_ID;
    close CSR_SEQUENCE;
  end if;
  close CSR_CAGR_DISPLAY_NAME;
end KEY_TO_IDS;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CAGR_API_PARAM_ID in NUMBER,
  X_DEFAULT_UOM in VARCHAR2,
  X_CAGR_API_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_COLUMN_TYPE in VARCHAR2,
  X_COLUMN_SIZE in NUMBER,
  X_UOM_PARAMETER in VARCHAR2,
  X_UOM_LOOKUP in VARCHAR2,
  X_HIDDEN     in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PER_CAGR_API_PARAMETERS
    where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID
    ;
begin
  insert into PER_CAGR_API_PARAMETERS (
    DEFAULT_UOM,
    CAGR_API_PARAM_ID,
    DISPLAY_NAME,
    CAGR_API_ID,
    PARAMETER_NAME,
    COLUMN_TYPE,
    COLUMN_SIZE,
    UOM_PARAMETER,
    UOM_LOOKUP,
	HIDDEN,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DEFAULT_UOM,
    X_CAGR_API_PARAM_ID,
    X_DISPLAY_NAME,
    X_CAGR_API_ID,
    X_PARAMETER_NAME,
    X_COLUMN_TYPE,
    X_COLUMN_SIZE,
    X_UOM_PARAMETER,
    X_UOM_LOOKUP,
	X_HIDDEN,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PER_CAGR_API_PARAMETERS_TL (
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CAGR_API_PARAM_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CAGR_API_PARAM_ID,
    X_DISPLAY_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PER_CAGR_API_PARAMETERS_TL T
    where T.CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure TRANSLATE_ROW (
  X_DISPLAY_NAME1              in VARCHAR2 default null,
  X_DISPLAY_NAME               in VARCHAR2,
  X_API_NAME                   in  VARCHAR2 default null,
  X_OWNER                      in VARCHAR2
   ) is
X_CAGR_API_PARAM_ID NUMBER;
X_CAGR_API_ID NUMBER;
--X_API_NAME VARCHAR2(60);

begin

 KEY_TO_IDS (
    X_DISPLAY_NAME1,
    X_API_NAME,
    X_CAGR_API_PARAM_ID,
    X_CAGR_API_ID
  );


  update per_cagr_api_parameters_tl set
    display_name           = X_display_NAME,
    last_update_date  = sysdate,
    last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = userenv('LANG')
  where cagr_api_param_id   = X_CAGR_API_PARAM_ID
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_CAGR_API_NAME			    in VARCHAR2,
  X_PARAMETER_NAME              in VARCHAR2,
  X_DISPLAY_NAME 	            in VARCHAR2,
  X_OWNER                       in VARCHAR2,
  X_OBJECT_VERSION_NUMBER       in NUMBER,
  X_COLUMN_TYPE		            in VARCHAR2,
  X_COLUMN_SIZE		            in NUMBER,
  X_UOM_PARAMETER	            in VARCHAR2,
  X_UOM_LOOKUP		            in VARCHAR2,
  X_HIDDEN                      in VARCHAR2,
  X_DEFAULT_UOM 	            in VARCHAR2) is

  X_ROW_ID ROWID;
  user_id number := 0;
  X_CAGR_API_PARAM_ID NUMBER;
  X_CAGR_API_ID  NUMBER;

begin

 KEY_TO_IDS (
    X_DISPLAY_NAME,
    X_CAGR_API_NAME,
    X_CAGR_API_PARAM_ID,
    X_CAGR_API_ID
  );

if (X_OWNER = 'SEED') then
    user_id := 1;
  else
    user_id := 0;
  end if;

PER_CAGR_API_PARAMETERS_PKG.UPDATE_ROW(
  X_CAGR_API_PARAM_ID => X_CAGR_API_PARAM_ID,
  X_DEFAULT_UOM => X_DEFAULT_UOM,
  X_CAGR_API_ID => X_CAGR_API_ID,
  X_PARAMETER_NAME => X_PARAMETER_NAME,
  X_COLUMN_TYPE => X_COLUMN_TYPE,
  X_COLUMN_SIZE => X_COLUMN_SIZE,
  X_UOM_PARAMETER => X_UOM_PARAMETER,
  X_UOM_LOOKUP => X_UOM_LOOKUP,
  X_HIDDEN     => X_HIDDEN,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_DISPLAY_NAME => X_DISPLAY_NAME,
  X_LAST_UPDATE_DATE => SYSDATE,
  X_LAST_UPDATED_BY => USER_ID,
  X_LAST_UPDATE_LOGIN => 0
);

exception
  when NO_DATA_FOUND then

PER_CAGR_API_PARAMETERS_PKG.INSERT_ROW(
  X_ROWID	=> X_ROW_ID,
  X_CAGR_API_PARAM_ID => X_CAGR_API_PARAM_ID,
  X_DEFAULT_UOM => X_DEFAULT_UOM,
  X_CAGR_API_ID => X_CAGR_API_ID,
  X_PARAMETER_NAME => X_PARAMETER_NAME,
  X_COLUMN_TYPE => X_COLUMN_TYPE,
  X_COLUMN_SIZE => X_COLUMN_SIZE,
  X_UOM_PARAMETER => X_UOM_PARAMETER,
  X_UOM_LOOKUP => X_UOM_LOOKUP,
  X_HIDDEN     => X_HIDDEN,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_DISPLAY_NAME => X_DISPLAY_NAME,
  X_CREATION_DATE => SYSDATE,
  X_CREATED_BY   => USER_ID,
  X_LAST_UPDATE_DATE => SYSDATE,
  X_LAST_UPDATED_BY => USER_ID,
  X_LAST_UPDATE_LOGIN => 0
);


end LOAD_ROW;

procedure LOCK_ROW (
  X_CAGR_API_PARAM_ID in NUMBER,
  X_DEFAULT_UOM in VARCHAR2,
  X_CAGR_API_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_COLUMN_TYPE in VARCHAR2,
  X_COLUMN_SIZE in NUMBER,
  X_UOM_PARAMETER in VARCHAR2,
  X_UOM_LOOKUP in VARCHAR2,
  X_HIDDEN in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      DEFAULT_UOM,
      CAGR_API_ID,
      PARAMETER_NAME,
      COLUMN_TYPE,
      COLUMN_SIZE,
      UOM_PARAMETER,
      UOM_LOOKUP,
	  HIDDEN,
      OBJECT_VERSION_NUMBER
    from PER_CAGR_API_PARAMETERS
    where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID
    for update of CAGR_API_PARAM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_CAGR_API_PARAMETERS_TL
    where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CAGR_API_PARAM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DEFAULT_UOM = X_DEFAULT_UOM)
           OR ((recinfo.DEFAULT_UOM is null) AND (X_DEFAULT_UOM is null)))
      AND (recinfo.CAGR_API_ID = X_CAGR_API_ID)
      AND ((recinfo.PARAMETER_NAME = X_PARAMETER_NAME)
           OR ((recinfo.PARAMETER_NAME is null) AND (X_PARAMETER_NAME is null)))
      AND ((recinfo.COLUMN_TYPE = X_COLUMN_TYPE)
           OR ((recinfo.COLUMN_TYPE is null) AND (X_COLUMN_TYPE is null)))
      AND ((recinfo.COLUMN_SIZE = X_COLUMN_SIZE)
           OR ((recinfo.COLUMN_SIZE is null) AND (X_COLUMN_SIZE is null)))
      AND ((recinfo.UOM_PARAMETER = X_UOM_PARAMETER)
           OR ((recinfo.UOM_PARAMETER is null) AND (X_UOM_PARAMETER is null)))
      AND ((recinfo.UOM_LOOKUP = X_UOM_LOOKUP)
           OR ((recinfo.UOM_LOOKUP is null) AND (X_UOM_LOOKUP is null)))
	  AND ((recinfo.HIDDEN = X_HIDDEN)
           OR ((recinfo.HIDDEN is null) AND (X_HIDDEN is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_CAGR_API_PARAM_ID in NUMBER,
  X_DEFAULT_UOM in VARCHAR2,
  X_CAGR_API_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_COLUMN_TYPE in VARCHAR2,
  X_COLUMN_SIZE in NUMBER,
  X_UOM_PARAMETER in VARCHAR2,
  X_UOM_LOOKUP in VARCHAR2,
  X_HIDDEN     in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PER_CAGR_API_PARAMETERS set
    DEFAULT_UOM = X_DEFAULT_UOM,
    CAGR_API_ID = X_CAGR_API_ID,
    PARAMETER_NAME = X_PARAMETER_NAME,
    DISPLAY_NAME   = X_DISPLAY_NAME,
    COLUMN_TYPE = X_COLUMN_TYPE,
    COLUMN_SIZE = X_COLUMN_SIZE,
    UOM_PARAMETER = X_UOM_PARAMETER,
    UOM_LOOKUP = X_UOM_LOOKUP,
	HIDDEN     = X_HIDDEN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PER_CAGR_API_PARAMETERS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CAGR_API_PARAM_ID in NUMBER
) is
begin
  delete from PER_CAGR_API_PARAMETERS_TL
  where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PER_CAGR_API_PARAMETERS
  where CAGR_API_PARAM_ID = X_CAGR_API_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PER_CAGR_API_PARAMETERS_TL T
  where not exists
    (select NULL
    from PER_CAGR_API_PARAMETERS B
    where B.CAGR_API_PARAM_ID = T.CAGR_API_PARAM_ID
    );

  update PER_CAGR_API_PARAMETERS_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from PER_CAGR_API_PARAMETERS_TL B
    where B.CAGR_API_PARAM_ID = T.CAGR_API_PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CAGR_API_PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CAGR_API_PARAM_ID,
      SUBT.LANGUAGE
    from PER_CAGR_API_PARAMETERS_TL SUBB, PER_CAGR_API_PARAMETERS_TL SUBT
    where SUBB.CAGR_API_PARAM_ID = SUBT.CAGR_API_PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
  ));

  insert into PER_CAGR_API_PARAMETERS_TL (
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CAGR_API_PARAM_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CAGR_API_PARAM_ID,
    B.DISPLAY_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_CAGR_API_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_CAGR_API_PARAMETERS_TL T
    where T.CAGR_API_PARAM_ID = B.CAGR_API_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PER_CAGR_API_PARAMETERS_PKG;

/
