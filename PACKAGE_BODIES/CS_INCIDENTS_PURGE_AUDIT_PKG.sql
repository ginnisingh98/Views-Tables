--------------------------------------------------------
--  DDL for Package Body CS_INCIDENTS_PURGE_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENTS_PURGE_AUDIT_PKG" as
/* $Header: csthipab.pls 120.0 2005/10/27 15:45:08 aneemuch noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INCIDENT_ID in NUMBER,
  X_PURGED_BY in NUMBER,
  X_INCIDENT_NUMBER in VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INV_ORGANIZATION_ID in NUMBER,
  X_CUSTOMER_PRODUCT_ID in NUMBER,
  X_INC_CREATION_DATE in DATE,
  X_INC_LAST_UPDATE_DATE in DATE,
  X_PURGED_DATE in DATE,
  X_PURGE_ID in NUMBER,
  X_SUMMARY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_INCIDENTS_PURGE_AUDIT_B
    where INCIDENT_ID = X_INCIDENT_ID
    ;
begin
  insert into CS_INCIDENTS_PURGE_AUDIT_B (
    PURGED_BY,
    INCIDENT_ID,
    INCIDENT_NUMBER,
    INCIDENT_TYPE_ID,
    CUSTOMER_ID,
    INVENTORY_ITEM_ID,
    INV_ORGANIZATION_ID,
    CUSTOMER_PRODUCT_ID,
    INC_CREATION_DATE,
    INC_LAST_UPDATE_DATE,
    PURGED_DATE,
    PURGE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PURGED_BY,
    X_INCIDENT_ID,
    X_INCIDENT_NUMBER,
    X_INCIDENT_TYPE_ID,
    X_CUSTOMER_ID,
    X_INVENTORY_ITEM_ID,
    X_INV_ORGANIZATION_ID,
    X_CUSTOMER_PRODUCT_ID,
    X_INC_CREATION_DATE,
    X_INC_LAST_UPDATE_DATE,
    X_PURGED_DATE,
    X_PURGE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_INCIDENTS_PURGE_AUDIT_TL (
    PURGE_ID,
    INCIDENT_ID,
    SUMMARY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PURGE_ID,
    X_INCIDENT_ID,
    X_SUMMARY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_INCIDENTS_PURGE_AUDIT_TL T
    where T.INCIDENT_ID = X_INCIDENT_ID
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
  X_INCIDENT_ID in NUMBER,
  X_PURGED_BY in NUMBER,
  X_INCIDENT_NUMBER in VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INV_ORGANIZATION_ID in NUMBER,
  X_CUSTOMER_PRODUCT_ID in NUMBER,
  X_INC_CREATION_DATE in DATE,
  X_INC_LAST_UPDATE_DATE in DATE,
  X_PURGED_DATE in DATE,
  X_PURGE_ID in NUMBER,
  X_SUMMARY in VARCHAR2
) is
  cursor c is select
      PURGED_BY,
      INCIDENT_NUMBER,
      INCIDENT_TYPE_ID,
      CUSTOMER_ID,
      INVENTORY_ITEM_ID,
      INV_ORGANIZATION_ID,
      CUSTOMER_PRODUCT_ID,
      INC_CREATION_DATE,
      INC_LAST_UPDATE_DATE,
      PURGED_DATE,
      PURGE_ID
    from CS_INCIDENTS_PURGE_AUDIT_B
    where INCIDENT_ID = X_INCIDENT_ID
    for update of INCIDENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SUMMARY,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_INCIDENTS_PURGE_AUDIT_TL
    where INCIDENT_ID = X_INCIDENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INCIDENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PURGED_BY = X_PURGED_BY)
      AND (recinfo.INCIDENT_NUMBER = X_INCIDENT_NUMBER)
      AND (recinfo.INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID)
      AND ((recinfo.CUSTOMER_ID = X_CUSTOMER_ID)
           OR ((recinfo.CUSTOMER_ID is null) AND (X_CUSTOMER_ID is null)))
      AND ((recinfo.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID)
           OR ((recinfo.INVENTORY_ITEM_ID is null) AND (X_INVENTORY_ITEM_ID is null)))
      AND ((recinfo.INV_ORGANIZATION_ID = X_INV_ORGANIZATION_ID)
           OR ((recinfo.INV_ORGANIZATION_ID is null) AND (X_INV_ORGANIZATION_ID is null)))
      AND ((recinfo.CUSTOMER_PRODUCT_ID = X_CUSTOMER_PRODUCT_ID)
           OR ((recinfo.CUSTOMER_PRODUCT_ID is null) AND (X_CUSTOMER_PRODUCT_ID is null)))
      AND (recinfo.INC_CREATION_DATE = X_INC_CREATION_DATE)
      AND (recinfo.INC_LAST_UPDATE_DATE = X_INC_LAST_UPDATE_DATE)
      AND (recinfo.PURGED_DATE = X_PURGED_DATE)
      AND (recinfo.PURGE_ID = X_PURGE_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SUMMARY = X_SUMMARY)
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
  X_INCIDENT_ID in NUMBER,
  X_PURGED_BY in NUMBER,
  X_INCIDENT_NUMBER in VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INV_ORGANIZATION_ID in NUMBER,
  X_CUSTOMER_PRODUCT_ID in NUMBER,
  X_INC_CREATION_DATE in DATE,
  X_INC_LAST_UPDATE_DATE in DATE,
  X_PURGED_DATE in DATE,
  X_PURGE_ID in NUMBER,
  X_SUMMARY in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_INCIDENTS_PURGE_AUDIT_B set
    PURGED_BY = X_PURGED_BY,
    INCIDENT_NUMBER = X_INCIDENT_NUMBER,
    INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID,
    CUSTOMER_ID = X_CUSTOMER_ID,
    INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
    INV_ORGANIZATION_ID = X_INV_ORGANIZATION_ID,
    CUSTOMER_PRODUCT_ID = X_CUSTOMER_PRODUCT_ID,
    INC_CREATION_DATE = X_INC_CREATION_DATE,
    INC_LAST_UPDATE_DATE = X_INC_LAST_UPDATE_DATE,
    PURGED_DATE = X_PURGED_DATE,
    PURGE_ID = X_PURGE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INCIDENT_ID = X_INCIDENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_INCIDENTS_PURGE_AUDIT_TL set
    SUMMARY = X_SUMMARY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INCIDENT_ID = X_INCIDENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INCIDENT_ID in NUMBER
) is
begin
  delete from CS_INCIDENTS_PURGE_AUDIT_TL
  where INCIDENT_ID = X_INCIDENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_INCIDENTS_PURGE_AUDIT_B
  where INCIDENT_ID = X_INCIDENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_INCIDENTS_PURGE_AUDIT_TL T
  where not exists
    (select NULL
    from CS_INCIDENTS_PURGE_AUDIT_B B
    where B.INCIDENT_ID = T.INCIDENT_ID
    );

  update CS_INCIDENTS_PURGE_AUDIT_TL T set (
      SUMMARY
    ) = (select
      B.SUMMARY
    from CS_INCIDENTS_PURGE_AUDIT_TL B
    where B.INCIDENT_ID = T.INCIDENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INCIDENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INCIDENT_ID,
      SUBT.LANGUAGE
    from CS_INCIDENTS_PURGE_AUDIT_TL SUBB, CS_INCIDENTS_PURGE_AUDIT_TL SUBT
    where SUBB.INCIDENT_ID = SUBT.INCIDENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SUMMARY <> SUBT.SUMMARY
  ));

  insert into CS_INCIDENTS_PURGE_AUDIT_TL (
    PURGE_ID,
    INCIDENT_ID,
    SUMMARY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PURGE_ID,
    B.INCIDENT_ID,
    B.SUMMARY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_INCIDENTS_PURGE_AUDIT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_INCIDENTS_PURGE_AUDIT_TL T
    where T.INCIDENT_ID = B.INCIDENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CS_INCIDENTS_PURGE_AUDIT_PKG;

/
