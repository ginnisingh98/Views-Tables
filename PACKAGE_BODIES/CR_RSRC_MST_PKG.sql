--------------------------------------------------------
--  DDL for Package Body CR_RSRC_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CR_RSRC_MST_PKG" as
/* $Header: GMPRSMSB.pls 120.0.12010000.3 2008/11/05 18:53:09 rpatangy ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RESOURCES in VARCHAR2,
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_MIN_CAPACITY in NUMBER,
  X_MAX_CAPACITY in NUMBER,
  X_CAPACITY_CONSTRAINT in NUMBER,
  X_CAPACITY_UOM in VARCHAR2,
  X_STD_USAGE_UM in VARCHAR2,
  X_COST_CMPNTCLS_ID in NUMBER,
  X_RESOURCE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CAPACITY_TOLERANCE in NUMBER,
  X_UTILIZATION in NUMBER,
  X_EFFICIENCY  in NUMBER
) is
  cursor C is select ROWID from CR_RSRC_MST_B
    where RESOURCES = X_RESOURCES
    ;
begin
  insert into CR_RSRC_MST_B (
    RESOURCE_CLASS,
    TRANS_CNT,
    DELETE_MARK,
    TEXT_CODE,
    MIN_CAPACITY,
    MAX_CAPACITY,
    CAPACITY_CONSTRAINT,
    CAPACITY_UM, /*sowsubra - resource model changes*/
    RESOURCES,
    STD_USAGE_UOM, /*sowsubra - resource model changes*/
    COST_CMPNTCLS_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CAPACITY_TOLERANCE,
    UTILIZATION,
    EFFICIENCY
  ) values (
    X_RESOURCE_CLASS,
    X_TRANS_CNT,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_MIN_CAPACITY,
    X_MAX_CAPACITY,
    X_CAPACITY_CONSTRAINT,
    X_CAPACITY_UOM,
    X_RESOURCES,
    X_STD_USAGE_UM,
    X_COST_CMPNTCLS_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CAPACITY_TOLERANCE,
    X_UTILIZATION,
    X_EFFICIENCY
  );

  insert into CR_RSRC_MST_TL (
    RESOURCES,
    RESOURCE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RESOURCES,
    X_RESOURCE_DESC,
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
    from CR_RSRC_MST_TL T
    where T.RESOURCES = X_RESOURCES
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
  X_RESOURCES in VARCHAR2,
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_MIN_CAPACITY in NUMBER,
  X_MAX_CAPACITY in NUMBER,
  X_CAPACITY_CONSTRAINT in NUMBER,
  X_CAPACITY_UOM in VARCHAR2,
  X_STD_USAGE_UM in VARCHAR2,
  X_COST_CMPNTCLS_ID in NUMBER,
  X_RESOURCE_DESC in VARCHAR2,
  X_CAPACITY_TOLERANCE in NUMBER,
  X_UTILIZATION in NUMBER,
  X_EFFICIENCY  in NUMBER
) is
  cursor c is select
      RESOURCE_CLASS,
      TRANS_CNT,
      DELETE_MARK,
      TEXT_CODE,
      MIN_CAPACITY,
      MAX_CAPACITY,
      CAPACITY_CONSTRAINT,
      CAPACITY_UM,/*sowsubra - resource model changes*/
      STD_USAGE_UOM, /*sowsubra - resource model changes*/
      COST_CMPNTCLS_ID,
      CAPACITY_TOLERANCE,
      UTILIZATION,
      EFFICIENCY
    from CR_RSRC_MST_B
    where RESOURCES = X_RESOURCES
    for update of RESOURCES nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RESOURCE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CR_RSRC_MST_TL
    where RESOURCES = X_RESOURCES
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RESOURCES nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.RESOURCE_CLASS = X_RESOURCE_CLASS)
           OR ((recinfo.RESOURCE_CLASS is null) AND (X_RESOURCE_CLASS is null)))
      AND ((recinfo.TRANS_CNT = X_TRANS_CNT)
           OR ((recinfo.TRANS_CNT is null) AND (X_TRANS_CNT is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.MIN_CAPACITY = X_MIN_CAPACITY)
           OR ((recinfo.MIN_CAPACITY is null) AND (X_MIN_CAPACITY is null)))
      AND ((recinfo.MAX_CAPACITY = X_MAX_CAPACITY)
           OR ((recinfo.MAX_CAPACITY is null) AND (X_MAX_CAPACITY is null)))
      AND ((recinfo.CAPACITY_CONSTRAINT = X_CAPACITY_CONSTRAINT)
           OR ((recinfo.CAPACITY_CONSTRAINT is null) AND (X_CAPACITY_CONSTRAINT is null)))
      AND ((recinfo.CAPACITY_UM = X_CAPACITY_UOM)
           OR ((recinfo.CAPACITY_UM is null) AND (X_CAPACITY_UOM is null)))
      AND (recinfo.STD_USAGE_UOM = X_STD_USAGE_UM)
      AND (recinfo.COST_CMPNTCLS_ID = X_COST_CMPNTCLS_ID)
      AND ((recinfo.CAPACITY_TOLERANCE = X_CAPACITY_TOLERANCE)
           OR ((recinfo.CAPACITY_TOLERANCE is null) AND (X_CAPACITY_TOLERANCE is null)))
      AND ((recinfo.UTILIZATION = X_UTILIZATION)
           OR ((recinfo.UTILIZATION is null) AND (X_UTILIZATION is null)))
      AND ((recinfo.EFFICIENCY = X_EFFICIENCY)
           OR ((recinfo.EFFICIENCY is null) AND (X_EFFICIENCY is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.RESOURCE_DESC = X_RESOURCE_DESC)
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
  X_RESOURCES in VARCHAR2,
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_MIN_CAPACITY in NUMBER,
  X_MAX_CAPACITY in NUMBER,
  X_CAPACITY_CONSTRAINT in NUMBER,
  X_CAPACITY_UOM in VARCHAR2,
  X_STD_USAGE_UM in VARCHAR2,
  X_COST_CMPNTCLS_ID in NUMBER,
  X_RESOURCE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CAPACITY_TOLERANCE in NUMBER,
  X_UTILIZATION in NUMBER,
  X_EFFICIENCY  in NUMBER
) is
begin
  update CR_RSRC_MST_B set
    RESOURCE_CLASS = X_RESOURCE_CLASS,
    TRANS_CNT = X_TRANS_CNT,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    MIN_CAPACITY = X_MIN_CAPACITY,
    MAX_CAPACITY = X_MAX_CAPACITY,
    CAPACITY_CONSTRAINT = X_CAPACITY_CONSTRAINT,
    CAPACITY_UM = X_CAPACITY_UOM, /*sowsubra - resource model changes*/
    STD_USAGE_UOM = X_STD_USAGE_UM, /*sowsubra - resource model changes*/
    COST_CMPNTCLS_ID = X_COST_CMPNTCLS_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CAPACITY_TOLERANCE = X_CAPACITY_TOLERANCE,
    UTILIZATION = X_UTILIZATION,
    EFFICIENCY  = X_EFFICIENCY
  where RESOURCES = X_RESOURCES;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CR_RSRC_MST_TL set
    RESOURCE_DESC = X_RESOURCE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RESOURCES = X_RESOURCES
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RESOURCES in VARCHAR2
) is
begin
/******************

  delete from CR_RSRC_MST_TL
  where RESOURCES = X_RESOURCES;

  if (sql%notfound) then
    raise no_data_found;
  end if;

******************/
  update CR_RSRC_MST_B set delete_mark = 1
  where RESOURCES = X_RESOURCES;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CR_RSRC_MST_TL T
  where not exists
    (select NULL
    from CR_RSRC_MST_B B
    where B.RESOURCES = T.RESOURCES
    );

  update CR_RSRC_MST_TL T set (
      RESOURCE_DESC
    ) = (select
      B.RESOURCE_DESC
    from CR_RSRC_MST_TL B
    where B.RESOURCES = T.RESOURCES
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESOURCES,
      T.LANGUAGE
  ) in (select
      SUBT.RESOURCES,
      SUBT.LANGUAGE
    from CR_RSRC_MST_TL SUBB, CR_RSRC_MST_TL SUBT
    where SUBB.RESOURCES = SUBT.RESOURCES
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RESOURCE_DESC <> SUBT.RESOURCE_DESC
  ));

  insert into CR_RSRC_MST_TL (
    RESOURCES,
    RESOURCE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RESOURCES,
    B.RESOURCE_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CR_RSRC_MST_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CR_RSRC_MST_TL T
    where T.RESOURCES = B.RESOURCES
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CR_RSRC_MST_PKG;

/
