--------------------------------------------------------
--  DDL for Package Body CSI_FA_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_FA_HEADERS_PKG" as
/* $Header: csitfahb.pls 120.0 2005/06/17 15:06:00 brmanesh noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INTERFACE_HEADER_ID in NUMBER,
  X_FA_ASSET_ID in NUMBER,
  X_FEEDER_SYSTEM_NAME in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_FA_BOOK_TYPE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into CSI_FA_HEADERS (
    INTERFACE_HEADER_ID,
    FA_ASSET_ID,
    FA_BOOK_TYPE_CODE,
    FEEDER_SYSTEM_NAME,
    STATUS_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_INTERFACE_HEADER_ID,
    X_FA_ASSET_ID,
    X_FA_BOOK_TYPE_CODE,
    X_FEEDER_SYSTEM_NAME,
    X_STATUS_CODE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN
  from SYS.dual;

end INSERT_ROW;

procedure LOCK_ROW (
  X_INTERFACE_HEADER_ID in NUMBER,
  X_FA_ASSET_ID in NUMBER,
  X_FEEDER_SYSTEM_NAME in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_FA_BOOK_TYPE_CODE in VARCHAR2
) is
  cursor c1 is select
      FA_ASSET_ID,
      FEEDER_SYSTEM_NAME,
      STATUS_CODE,
      FA_BOOK_TYPE_CODE
    from CSI_FA_HEADERS
    where INTERFACE_HEADER_ID = X_INTERFACE_HEADER_ID
    for update of INTERFACE_HEADER_ID nowait;
begin
  for tlinfo in c1 loop
    if (    (tlinfo.FA_BOOK_TYPE_CODE = X_FA_BOOK_TYPE_CODE)
        AND (tlinfo.FA_ASSET_ID = X_FA_ASSET_ID)
        AND (tlinfo.FEEDER_SYSTEM_NAME = X_FEEDER_SYSTEM_NAME)
        AND ((tlinfo.STATUS_CODE = X_STATUS_CODE)
             OR ((tlinfo.STATUS_CODE is null) AND (X_STATUS_CODE is null)))
    ) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INTERFACE_HEADER_ID in NUMBER,
  X_FA_ASSET_ID in NUMBER,
  X_FEEDER_SYSTEM_NAME in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_FA_BOOK_TYPE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CSI_FA_HEADERS set
    FA_ASSET_ID = X_FA_ASSET_ID,
    FEEDER_SYSTEM_NAME = X_FEEDER_SYSTEM_NAME,
    STATUS_CODE = X_STATUS_CODE,
    FA_BOOK_TYPE_CODE = X_FA_BOOK_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INTERFACE_HEADER_ID = X_INTERFACE_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTERFACE_HEADER_ID in NUMBER
) is
begin
  delete from CSI_FA_HEADERS
  where INTERFACE_HEADER_ID = X_INTERFACE_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end CSI_FA_HEADERS_PKG;

/
