--------------------------------------------------------
--  DDL for Package Body XDP_WI_FA_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_WI_FA_MAPPING_PKG" as
/* $Header: XDPWFMPB.pls 120.2 2005/07/15 06:33:02 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_WI_FA_MAPPING_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_FULFILLMENT_ACTION_ID in NUMBER,
  X_PROVISIONING_SEQ in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_WI_FA_MAPPING
    where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID
    ;
begin
  insert into XDP_WI_FA_MAPPING (
    WI_FA_MAPPING_ID,
    WORKITEM_ID,
    FULFILLMENT_ACTION_ID,
    PROVISIONING_SEQ,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_WI_FA_MAPPING_ID,
    X_WORKITEM_ID,
    X_FULFILLMENT_ACTION_ID,
    X_PROVISIONING_SEQ,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_WI_FA_MAPPING_TL (
    WI_FA_MAPPING_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_WI_FA_MAPPING_ID,
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
    from XDP_WI_FA_MAPPING_TL T
    where T.WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID
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
  X_WI_FA_MAPPING_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_FULFILLMENT_ACTION_ID in NUMBER,
  X_PROVISIONING_SEQ in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      WORKITEM_ID,
      FULFILLMENT_ACTION_ID,
      PROVISIONING_SEQ
    from XDP_WI_FA_MAPPING
    where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID
    for update of WI_FA_MAPPING_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_WI_FA_MAPPING_TL
    where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of WI_FA_MAPPING_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.WORKITEM_ID = X_WORKITEM_ID)
      AND (recinfo.FULFILLMENT_ACTION_ID = X_FULFILLMENT_ACTION_ID)
      AND (recinfo.PROVISIONING_SEQ = X_PROVISIONING_SEQ)
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
  X_WI_FA_MAPPING_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_FULFILLMENT_ACTION_ID in NUMBER,
  X_PROVISIONING_SEQ in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_WI_FA_MAPPING set
    WORKITEM_ID = X_WORKITEM_ID,
    FULFILLMENT_ACTION_ID = X_FULFILLMENT_ACTION_ID,
    PROVISIONING_SEQ = X_PROVISIONING_SEQ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_WI_FA_MAPPING_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WI_FA_MAPPING_ID in NUMBER
) is
begin
  delete from XDP_WI_FA_MAPPING_TL
  where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_WI_FA_MAPPING
  where WI_FA_MAPPING_ID = X_WI_FA_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_WI_FA_MAPPING_TL T
  where not exists
    (select NULL
    from XDP_WI_FA_MAPPING B
    where B.WI_FA_MAPPING_ID = T.WI_FA_MAPPING_ID
    );

  update XDP_WI_FA_MAPPING_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from XDP_WI_FA_MAPPING_TL B
    where B.WI_FA_MAPPING_ID = T.WI_FA_MAPPING_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WI_FA_MAPPING_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WI_FA_MAPPING_ID,
      SUBT.LANGUAGE
    from XDP_WI_FA_MAPPING_TL SUBB, XDP_WI_FA_MAPPING_TL SUBT
    where SUBB.WI_FA_MAPPING_ID = SUBT.WI_FA_MAPPING_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_WI_FA_MAPPING_TL (
    WI_FA_MAPPING_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WI_FA_MAPPING_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_WI_FA_MAPPING_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_WI_FA_MAPPING_TL T
    where T.WI_FA_MAPPING_ID = B.WI_FA_MAPPING_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_WI_FA_MAPPING_ID in NUMBER,
  X_WORKITEM_ID in NUMBER,
  X_FULFILLMENT_ACTION_ID in NUMBER,
  X_PROVISIONING_SEQ in NUMBER,
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

     XDP_WI_FA_MAPPING_PKG.UPDATE_ROW (
  	X_WI_FA_MAPPING_ID => X_WI_FA_MAPPING_ID,
  	X_WORKITEM_ID => X_WORKITEM_ID,
  	X_FULFILLMENT_ACTION_ID => X_FULFILLMENT_ACTION_ID,
  	X_PROVISIONING_SEQ => X_PROVISIONING_SEQ,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_WI_FA_MAPPING_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  		X_WI_FA_MAPPING_ID => X_WI_FA_MAPPING_ID,
  		X_WORKITEM_ID => X_WORKITEM_ID,
  		X_FULFILLMENT_ACTION_ID => X_FULFILLMENT_ACTION_ID,
  		X_PROVISIONING_SEQ => X_PROVISIONING_SEQ,
             	X_DESCRIPTION => X_DESCRIPTION,
             	X_CREATION_DATE => sysdate,
             	X_CREATED_BY => user_id,
             	X_LAST_UPDATE_DATE => sysdate,
             	X_LAST_UPDATED_BY => user_id,
             	X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_WI_FA_MAPPING_ID in NUMBER,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_WI_FA_MAPPING_TL
    set  description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 15-JUL-2005. DECODE replaced with FND API.*/
	last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
  where wi_fa_mapping_id = X_WI_FA_MAPPING_ID
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end XDP_WI_FA_MAPPING_PKG;

/
