--------------------------------------------------------
--  DDL for Package Body GMD_ITEM_SUBSTITUTION_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ITEM_SUBSTITUTION_DTL_PKG" as
/* $Header: GMDITSDB.pls 120.1 2005/07/13 02:57:13 kkillams noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SUBSTITUTION_LINE_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_UNIT_QTY in NUMBER,
  X_DETAIL_UOM in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_ITEM_SUBSTITUTION_DTL
    where SUBSTITUTION_LINE_ID = X_SUBSTITUTION_LINE_ID
    ;
begin
  insert into GMD_ITEM_SUBSTITUTION_DTL (
    SUBSTITUTION_LINE_ID,
    SUBSTITUTION_ID,
    INVENTORY_ITEM_ID,
    UNIT_QTY,
    DETAIL_UOM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SUBSTITUTION_LINE_ID,
    X_SUBSTITUTION_ID,
    X_INVENTORY_ITEM_ID,
    X_UNIT_QTY,
    X_DETAIL_UOM,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SUBSTITUTION_LINE_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_UNIT_QTY in NUMBER,
  X_DETAIL_UOM in VARCHAR2
) is
  cursor c is select
      SUBSTITUTION_ID,
      INVENTORY_ITEM_ID,
      UNIT_QTY,
      DETAIL_UOM
    from GMD_ITEM_SUBSTITUTION_DTL
    where SUBSTITUTION_LINE_ID = X_SUBSTITUTION_LINE_ID
    for update of SUBSTITUTION_LINE_ID nowait;
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
  if (    (recinfo.SUBSTITUTION_ID = X_SUBSTITUTION_ID)
      AND (recinfo.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID)
      AND (recinfo.UNIT_QTY = X_UNIT_QTY)
      AND (recinfo.DETAIL_UOM = X_DETAIL_UOM)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SUBSTITUTION_LINE_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_UNIT_QTY in NUMBER,
  X_DETAIL_UOM in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_ITEM_SUBSTITUTION_DTL set
    SUBSTITUTION_ID = X_SUBSTITUTION_ID,
    INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
    UNIT_QTY = X_UNIT_QTY,
    DETAIL_UOM = X_DETAIL_UOM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SUBSTITUTION_LINE_ID = X_SUBSTITUTION_LINE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_SUBSTITUTION_LINE_ID in NUMBER
) is
begin

  delete from GMD_ITEM_SUBSTITUTION_DTL
  where SUBSTITUTION_LINE_ID = X_SUBSTITUTION_LINE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end GMD_ITEM_SUBSTITUTION_DTL_PKG;

/
