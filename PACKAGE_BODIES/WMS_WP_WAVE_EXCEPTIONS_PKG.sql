--------------------------------------------------------
--  DDL for Package Body WMS_WP_WAVE_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WP_WAVE_EXCEPTIONS_PKG" as
/* $Header: WMSWPTEB.pls 120.1.12010000.1 2009/03/25 09:55:23 shrmitra noship $ */
procedure INSERT_ROW (
  X_EXCEPTION_ID in NUMBER,
  X_EXCEPTION_ENTITY in VARCHAR2,
  X_EXCEPTION_STAGE in VARCHAR2,
  X_EXCEPTION_LEVEL in VARCHAR2,
  X_EXCEPTION_MSG in VARCHAR2,
  X_WAVE_HEADER_ID in NUMBER,
  X_TRIP_ID in NUMBER,
  X_DELIVERY_ID in NUMBER,
  X_ORDER_NUMBER in NUMBER,
  X_ORDER_LINE_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_READY_TO_RELEASE in VARCHAR2,
  X_BACKORDERED in VARCHAR2,
  X_CROSSDOCK_PLANNED in VARCHAR2,
  X_REPLENISHMENT_PLANNED in VARCHAR2,
  X_TASKED in VARCHAR2,
  X_PICKED in VARCHAR2,
  X_PACKED in VARCHAR2,
  X_STAGED in VARCHAR2,
  X_LOADED_TO_DOCK in VARCHAR2,
  X_SHIPPED in VARCHAR2,
  X_CONCURRENT_REQUEST_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_EXCEPTION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from WMS_WP_WAVE_EXCEPTIONS_B
    where EXCEPTION_ID = X_EXCEPTION_ID
    ;

    -- create a cursor variable here SUDHEER
  c_var c%rowtype;
begin
  insert into WMS_WP_WAVE_EXCEPTIONS_B (
    EXCEPTION_ID,
    EXCEPTION_ENTITY,
    EXCEPTION_STAGE,
    EXCEPTION_LEVEL,
    EXCEPTION_MSG,
    WAVE_HEADER_ID,
    TRIP_ID,
    DELIVERY_ID,
    ORDER_NUMBER,
    ORDER_LINE_ID,
    STATUS,
    READY_TO_RELEASE,
    BACKORDERED,
    CROSSDOCK_PLANNED,
    REPLENISHMENT_PLANNED,
    TASKED,
    PICKED,
    PACKED,
    STAGED,
    LOADED_TO_DOCK,
    SHIPPED,
    CONCURRENT_REQUEST_ID,
    PROGRAM_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EXCEPTION_ID,
    X_EXCEPTION_ENTITY,
    X_EXCEPTION_STAGE,
    X_EXCEPTION_LEVEL,
    X_EXCEPTION_MSG,
    X_WAVE_HEADER_ID,
    X_TRIP_ID,
    X_DELIVERY_ID,
    X_ORDER_NUMBER,
    X_ORDER_LINE_ID,
    X_STATUS,
    X_READY_TO_RELEASE,
    X_BACKORDERED,
    X_CROSSDOCK_PLANNED,
    X_REPLENISHMENT_PLANNED,
    X_TASKED,
    X_PICKED,
    X_PACKED,
    X_STAGED,
    X_LOADED_TO_DOCK,
    X_SHIPPED,
    X_CONCURRENT_REQUEST_ID,
    X_PROGRAM_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into WMS_WP_WAVE_EXCEPTIONS_TL (
    EXCEPTION_ID,
    EXCEPTION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_EXCEPTION_ID,
    X_EXCEPTION_NAME,
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
    from WMS_WP_WAVE_EXCEPTIONS_TL T
    where T.EXCEPTION_ID = X_EXCEPTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  --fetch c into X_ROWID;  -- sudheer
  fetch c into c_var;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_EXCEPTION_ID in NUMBER,
  X_EXCEPTION_ENTITY in VARCHAR2,
  X_EXCEPTION_STAGE in VARCHAR2,
  X_EXCEPTION_LEVEL in VARCHAR2,
  X_EXCEPTION_MSG in VARCHAR2,
  X_WAVE_HEADER_ID in NUMBER,
  X_TRIP_ID in NUMBER,
  X_DELIVERY_ID in NUMBER,
  X_ORDER_NUMBER in NUMBER,
  X_ORDER_LINE_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_READY_TO_RELEASE in VARCHAR2,
  X_BACKORDERED in VARCHAR2,
  X_CROSSDOCK_PLANNED in VARCHAR2,
  X_REPLENISHMENT_PLANNED in VARCHAR2,
  X_TASKED in VARCHAR2,
  X_PICKED in VARCHAR2,
  X_PACKED in VARCHAR2,
  X_STAGED in VARCHAR2,
  X_LOADED_TO_DOCK in VARCHAR2,
  X_SHIPPED in VARCHAR2,
  X_CONCURRENT_REQUEST_ID in NUMBER,
  X_PROGRAM_ID in NUMBER, -- sudheer
  X_EXCEPTION_NAME in VARCHAR2
) is
  cursor c is select
      EXCEPTION_ENTITY,
      EXCEPTION_STAGE,
      EXCEPTION_LEVEL,
      EXCEPTION_MSG,
      WAVE_HEADER_ID,
      TRIP_ID,
      DELIVERY_ID,
      ORDER_NUMBER,
      ORDER_LINE_ID,
      STATUS,
      READY_TO_RELEASE,
      BACKORDERED,
      CROSSDOCK_PLANNED,
      REPLENISHMENT_PLANNED,
      TASKED,
      PICKED,
      PACKED,
      STAGED,
      LOADED_TO_DOCK,
      SHIPPED,
      CONCURRENT_REQUEST_ID,
      PROGRAM_ID -- sudheer
    from WMS_WP_WAVE_EXCEPTIONS_B
    where EXCEPTION_ID = X_EXCEPTION_ID
    for update of EXCEPTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      EXCEPTION_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_WP_WAVE_EXCEPTIONS_TL
    where EXCEPTION_ID = X_EXCEPTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EXCEPTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.EXCEPTION_ENTITY = X_EXCEPTION_ENTITY)
           OR ((recinfo.EXCEPTION_ENTITY is null) AND (X_EXCEPTION_ENTITY is null)))
      AND ((recinfo.EXCEPTION_STAGE = X_EXCEPTION_STAGE)
           OR ((recinfo.EXCEPTION_STAGE is null) AND (X_EXCEPTION_STAGE is null)))
      AND ((recinfo.EXCEPTION_LEVEL = X_EXCEPTION_LEVEL)
           OR ((recinfo.EXCEPTION_LEVEL is null) AND (X_EXCEPTION_LEVEL is null)))
      AND ((recinfo.EXCEPTION_MSG = X_EXCEPTION_MSG)
           OR ((recinfo.EXCEPTION_MSG is null) AND (X_EXCEPTION_MSG is null)))
      AND (recinfo.WAVE_HEADER_ID = X_WAVE_HEADER_ID)
      AND ((recinfo.TRIP_ID = X_TRIP_ID)
           OR ((recinfo.TRIP_ID is null) AND (X_TRIP_ID is null)))
      AND ((recinfo.DELIVERY_ID = X_DELIVERY_ID)
           OR ((recinfo.DELIVERY_ID is null) AND (X_DELIVERY_ID is null)))
      AND ((recinfo.ORDER_NUMBER = X_ORDER_NUMBER)
           OR ((recinfo.ORDER_NUMBER is null) AND (X_ORDER_NUMBER is null)))
      AND ((recinfo.ORDER_LINE_ID = X_ORDER_LINE_ID)
           OR ((recinfo.ORDER_LINE_ID is null) AND (X_ORDER_LINE_ID is null)))
      AND ((recinfo.STATUS = X_STATUS)
           OR ((recinfo.STATUS is null) AND (X_STATUS is null)))
      AND ((recinfo.READY_TO_RELEASE = X_READY_TO_RELEASE)
           OR ((recinfo.READY_TO_RELEASE is null) AND (X_READY_TO_RELEASE is null)))
      AND ((recinfo.BACKORDERED = X_BACKORDERED)
           OR ((recinfo.BACKORDERED is null) AND (X_BACKORDERED is null)))
      AND ((recinfo.CROSSDOCK_PLANNED = X_CROSSDOCK_PLANNED)
           OR ((recinfo.CROSSDOCK_PLANNED is null) AND (X_CROSSDOCK_PLANNED is null)))
      AND ((recinfo.REPLENISHMENT_PLANNED = X_REPLENISHMENT_PLANNED)
           OR ((recinfo.REPLENISHMENT_PLANNED is null) AND (X_REPLENISHMENT_PLANNED is null)))
      AND ((recinfo.TASKED = X_TASKED)
           OR ((recinfo.TASKED is null) AND (X_TASKED is null)))
      AND ((recinfo.PICKED = X_PICKED)
           OR ((recinfo.PICKED is null) AND (X_PICKED is null)))
      AND ((recinfo.PACKED = X_PACKED)
           OR ((recinfo.PACKED is null) AND (X_PACKED is null)))
      AND ((recinfo.STAGED = X_STAGED)
           OR ((recinfo.STAGED is null) AND (X_STAGED is null)))
      AND ((recinfo.LOADED_TO_DOCK = X_LOADED_TO_DOCK)
           OR ((recinfo.LOADED_TO_DOCK is null) AND (X_LOADED_TO_DOCK is null)))
      AND ((recinfo.SHIPPED = X_SHIPPED)
           OR ((recinfo.SHIPPED is null) AND (X_SHIPPED is null)))
      AND ((recinfo.CONCURRENT_REQUEST_ID = X_CONCURRENT_REQUEST_ID)
           OR ((recinfo.CONCURRENT_REQUEST_ID is null) AND (X_CONCURRENT_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)                  -- sudheer
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null))) -- sudheer

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.EXCEPTION_NAME = X_EXCEPTION_NAME)
               OR ((tlinfo.EXCEPTION_NAME is null) AND (X_EXCEPTION_NAME is null)))
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
  X_EXCEPTION_ID in NUMBER,
  X_EXCEPTION_ENTITY in VARCHAR2,
  X_EXCEPTION_STAGE in VARCHAR2,
  X_EXCEPTION_LEVEL in VARCHAR2,
  X_EXCEPTION_MSG in VARCHAR2,
  X_WAVE_HEADER_ID in NUMBER,
  X_TRIP_ID in NUMBER,
  X_DELIVERY_ID in NUMBER,
  X_ORDER_NUMBER in NUMBER,
  X_ORDER_LINE_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_READY_TO_RELEASE in VARCHAR2,
  X_BACKORDERED in VARCHAR2,
  X_CROSSDOCK_PLANNED in VARCHAR2,
  X_REPLENISHMENT_PLANNED in VARCHAR2,
  X_TASKED in VARCHAR2,
  X_PICKED in VARCHAR2,
  X_PACKED in VARCHAR2,
  X_STAGED in VARCHAR2,
  X_LOADED_TO_DOCK in VARCHAR2,
  X_SHIPPED in VARCHAR2,
  X_CONCURRENT_REQUEST_ID in NUMBER,
  X_PROGRAM_ID in NUMBER, -- added by sudheer.
  X_EXCEPTION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_WP_WAVE_EXCEPTIONS_B set
    EXCEPTION_ENTITY = X_EXCEPTION_ENTITY,
    EXCEPTION_STAGE = X_EXCEPTION_STAGE,
    EXCEPTION_LEVEL = X_EXCEPTION_LEVEL,
    EXCEPTION_MSG = X_EXCEPTION_MSG,
    WAVE_HEADER_ID = X_WAVE_HEADER_ID,
    TRIP_ID = X_TRIP_ID,
    DELIVERY_ID = X_DELIVERY_ID,
    ORDER_NUMBER = X_ORDER_NUMBER,
    ORDER_LINE_ID = X_ORDER_LINE_ID,
    STATUS = X_STATUS,
    READY_TO_RELEASE = X_READY_TO_RELEASE,
    BACKORDERED = X_BACKORDERED,
    CROSSDOCK_PLANNED = X_CROSSDOCK_PLANNED,
    REPLENISHMENT_PLANNED = X_REPLENISHMENT_PLANNED,
    TASKED = X_TASKED,
    PICKED = X_PICKED,
    PACKED = X_PACKED,
    STAGED = X_STAGED,
    LOADED_TO_DOCK = X_LOADED_TO_DOCK,
    SHIPPED = X_SHIPPED,
    CONCURRENT_REQUEST_ID = X_CONCURRENT_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID, -- by SUDHEER
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_WP_WAVE_EXCEPTIONS_TL set
    EXCEPTION_NAME = X_EXCEPTION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where EXCEPTION_ID = X_EXCEPTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_EXCEPTION_ID in NUMBER
) is
begin
  delete from WMS_WP_WAVE_EXCEPTIONS_TL
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_WP_WAVE_EXCEPTIONS_B
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_WP_WAVE_EXCEPTIONS_TL T
  where not exists
    (select NULL
    from WMS_WP_WAVE_EXCEPTIONS_B B
    where B.EXCEPTION_ID = T.EXCEPTION_ID
    );

  update WMS_WP_WAVE_EXCEPTIONS_TL T set (
      EXCEPTION_NAME
    ) = (select
      B.EXCEPTION_NAME
    from WMS_WP_WAVE_EXCEPTIONS_TL B
    where B.EXCEPTION_ID = T.EXCEPTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXCEPTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXCEPTION_ID,
      SUBT.LANGUAGE
    from WMS_WP_WAVE_EXCEPTIONS_TL SUBB, WMS_WP_WAVE_EXCEPTIONS_TL SUBT
    where SUBB.EXCEPTION_ID = SUBT.EXCEPTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXCEPTION_NAME <> SUBT.EXCEPTION_NAME
      or (SUBB.EXCEPTION_NAME is null and SUBT.EXCEPTION_NAME is not null)
      or (SUBB.EXCEPTION_NAME is not null and SUBT.EXCEPTION_NAME is null)
  ));

  insert into WMS_WP_WAVE_EXCEPTIONS_TL (
    EXCEPTION_ID,
    EXCEPTION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.EXCEPTION_ID,
    B.EXCEPTION_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_WP_WAVE_EXCEPTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_WP_WAVE_EXCEPTIONS_TL T
    where T.EXCEPTION_ID = B.EXCEPTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end WMS_WP_WAVE_EXCEPTIONS_PKG;

/
