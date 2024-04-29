--------------------------------------------------------
--  DDL for Package Body XDP_SERVICE_WI_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_SERVICE_WI_MAP_PKG" as
/* $Header: XDPSWMPB.pls 120.1 2005/06/16 02:42:25 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_SERVICE_WI_MAP_ID in NUMBER,
  X_SERVICE_VAL_ACT_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_PROVISION_SEQ in NUMBER,
  X_MAPPING_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_SERVICE_WI_MAP
    where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID
    ;
begin
  insert into XDP_SERVICE_WI_MAP (
    SERVICE_WI_MAP_ID,
    SERVICE_VAL_ACT_ID,
    WORKITEM_ID,
    PROVISION_SEQ,
    MAPPING_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SERVICE_WI_MAP_ID,
    X_SERVICE_VAL_ACT_ID,
    X_WORKITEM_ID,
    X_PROVISION_SEQ,
    X_MAPPING_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_SERVICE_WI_MAP_TL (
    SERVICE_WI_MAP_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SERVICE_WI_MAP_ID,
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
    from XDP_SERVICE_WI_MAP_TL T
    where T.SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID
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
  X_SERVICE_WI_MAP_ID in NUMBER,
  X_SERVICE_VAL_ACT_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_PROVISION_SEQ in NUMBER,
  X_MAPPING_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SERVICE_VAL_ACT_ID,
      WORKITEM_ID,
      PROVISION_SEQ,
      MAPPING_TYPE
    from XDP_SERVICE_WI_MAP
    where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID
    for update of SERVICE_WI_MAP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_SERVICE_WI_MAP_TL
    where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SERVICE_WI_MAP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SERVICE_VAL_ACT_ID = X_SERVICE_VAL_ACT_ID)
      AND (recinfo.WORKITEM_ID = X_WORKITEM_ID)
      AND (recinfo.PROVISION_SEQ = X_PROVISION_SEQ)
      AND (recinfo.MAPPING_TYPE = X_MAPPING_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_SERVICE_WI_MAP_ID in NUMBER,
  X_SERVICE_VAL_ACT_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_PROVISION_SEQ in NUMBER,
  X_MAPPING_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_SERVICE_WI_MAP set
    SERVICE_VAL_ACT_ID = X_SERVICE_VAL_ACT_ID,
    WORKITEM_ID = X_WORKITEM_ID,
    PROVISION_SEQ = X_PROVISION_SEQ,
    MAPPING_TYPE = X_MAPPING_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_SERVICE_WI_MAP_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SERVICE_WI_MAP_ID in NUMBER
) is
begin
  delete from XDP_SERVICE_WI_MAP_TL
  where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_SERVICE_WI_MAP
  where SERVICE_WI_MAP_ID = X_SERVICE_WI_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_SERVICE_WI_MAP_TL T
  where not exists
    (select NULL
    from XDP_SERVICE_WI_MAP B
    where B.SERVICE_WI_MAP_ID = T.SERVICE_WI_MAP_ID
    );

  update XDP_SERVICE_WI_MAP_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from XDP_SERVICE_WI_MAP_TL B
    where B.SERVICE_WI_MAP_ID = T.SERVICE_WI_MAP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SERVICE_WI_MAP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SERVICE_WI_MAP_ID,
      SUBT.LANGUAGE
    from XDP_SERVICE_WI_MAP_TL SUBB, XDP_SERVICE_WI_MAP_TL SUBT
    where SUBB.SERVICE_WI_MAP_ID = SUBT.SERVICE_WI_MAP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_SERVICE_WI_MAP_TL (
    SERVICE_WI_MAP_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SERVICE_WI_MAP_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_SERVICE_WI_MAP_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_SERVICE_WI_MAP_TL T
    where T.SERVICE_WI_MAP_ID = B.SERVICE_WI_MAP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_SERVICE_WI_MAP_ID in NUMBER,
  X_SERVICE_VAL_ACT_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_PROVISION_SEQ in NUMBER,
  X_MAPPING_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     XDP_SERVICE_WI_MAP_PKG.UPDATE_ROW (
  	X_SERVICE_WI_MAP_ID => X_SERVICE_WI_MAP_ID,
  	X_SERVICE_VAL_ACT_ID => X_SERVICE_VAL_ACT_ID,
  	X_WORKITEM_ID => X_WORKITEM_ID,
  	X_PROVISION_SEQ => X_PROVISION_SEQ,
  	X_MAPPING_TYPE => X_MAPPING_TYPE,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_SERVICE_WI_MAP_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  		X_SERVICE_WI_MAP_ID => X_SERVICE_WI_MAP_ID,
  		X_SERVICE_VAL_ACT_ID => X_SERVICE_VAL_ACT_ID,
  		X_WORKITEM_ID => X_WORKITEM_ID,
  		X_PROVISION_SEQ => X_PROVISION_SEQ,
  		X_MAPPING_TYPE => X_MAPPING_TYPE,
             	X_DESCRIPTION => X_DESCRIPTION,
             	X_CREATION_DATE => sysdate,
             	X_CREATED_BY => user_id,
             	X_LAST_UPDATE_DATE => sysdate,
             	X_LAST_UPDATED_BY => user_id,
             	X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_SERVICE_WI_MAP_ID in NUMBER,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_SERVICE_WI_MAP_TL
    set  description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0
  where service_wi_map_id = X_SERVICE_WI_MAP_ID
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;



end XDP_SERVICE_WI_MAP_PKG;

/
