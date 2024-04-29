--------------------------------------------------------
--  DDL for Package Body WMS_XDOCK_SRC_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_XDOCK_SRC_ASSIGN_PKG" as
/* $Header: WMSXDSAB.pls 120.1 2005/05/26 14:08:23 appldev  $ */
procedure INSERT_ROW (
  X_CRITERION_ID in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_PRIORITY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into WMS_XDOCK_SOURCE_ASSIGNMENTS (
    CRITERION_ID,
    SOURCE_TYPE,
    SOURCE_CODE,
    PRIORITY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CRITERION_ID,
    X_SOURCE_TYPE,
    X_SOURCE_CODE,
    X_PRIORITY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_CRITERION_ID in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_PRIORITY in NUMBER
) is
  cursor c is select
      PRIORITY
    from WMS_XDOCK_SOURCE_ASSIGNMENTS
    where CRITERION_ID = X_CRITERION_ID
    and SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    for update nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (recinfo.PRIORITY = X_PRIORITY) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CRITERION_ID in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_PRIORITY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_XDOCK_SOURCE_ASSIGNMENTS set
    PRIORITY = X_PRIORITY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CRITERION_ID = X_CRITERION_ID
  and SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CRITERION_ID in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER
) is
begin
  delete from WMS_XDOCK_SOURCE_ASSIGNMENTS
  where CRITERION_ID = X_CRITERION_ID
  and SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end WMS_XDOCK_SRC_ASSIGN_PKG;

/
