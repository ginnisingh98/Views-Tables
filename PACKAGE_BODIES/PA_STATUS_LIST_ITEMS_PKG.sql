--------------------------------------------------------
--  DDL for Package Body PA_STATUS_LIST_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_LIST_ITEMS_PKG" as
/* $Header: PACISITB.pls 120.2 2005/08/22 05:13:16 sukhanna noship $ */
procedure INSERT_ROW (
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_LIST_ITEM_ID in out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_STATUS_LIST_ID in NUMBER,
  X_PROJECT_STATUS_CODE in VARCHAR2,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_STATUS_LIST_ITEMS
    where STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID
    ;
  l_rowid ROWID;
  l_status_list_item_id NUMBER;
begin
  l_status_list_item_id := x_status_list_item_id; --Added for bug 4565156
  IF (X_STATUS_LIST_ITEM_ID = -99) THEN
	SELECT pa_status_list_items_s.nextval into l_status_list_item_id FROM dual;
	X_STATUS_LIST_ITEM_ID := l_status_list_item_id;
  END IF;

  insert into PA_STATUS_LIST_ITEMS (
    STATUS_LIST_ID,
    RECORD_VERSION_NUMBER,
    PROJECT_STATUS_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    STATUS_LIST_ITEM_ID
  ) values(
    X_STATUS_LIST_ID,
    1,
    X_PROJECT_STATUS_CODE,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.user_id,
    X_STATUS_LIST_ITEM_ID);

  open c;
  fetch c into l_rowid;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  exception --Added for bug 4565156
      when others then
       x_status_list_item_id := l_status_list_item_id;
       raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_STATUS_LIST_ITEM_ID in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_PROJECT_STATUS_CODE in VARCHAR2
) is
  cursor c1 is select
      STATUS_LIST_ID,
      RECORD_VERSION_NUMBER,
      PROJECT_STATUS_CODE,
      STATUS_LIST_ITEM_ID
    from PA_STATUS_LIST_ITEMS
    where STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID
    for update of STATUS_LIST_ITEM_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID)
          AND (tlinfo.STATUS_LIST_ID = X_STATUS_LIST_ID)
          AND ((tlinfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER)
               OR ((tlinfo.RECORD_VERSION_NUMBER is null) AND (X_RECORD_VERSION_NUMBER is null)))
          AND (tlinfo.PROJECT_STATUS_CODE = X_PROJECT_STATUS_CODE)
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
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_LIST_ITEM_ID in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_PROJECT_STATUS_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER ,
  X_CREATION_DATE IN DATE ,
  X_CREATED_BY IN NUMBER
) is
begin
  update PA_STATUS_LIST_ITEMS set
    STATUS_LIST_ID = X_STATUS_LIST_ID,
    RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER,
    PROJECT_STATUS_CODE = X_PROJECT_STATUS_CODE,
    STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.user_id,
    CREATION_DATE = X_CREATION_DATE,
    CREATED_BY = X_CREATED_BY
   where STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_LIST_ITEM_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
) is
begin
  delete from PA_STATUS_LIST_ITEMS
  where STATUS_LIST_ITEM_ID = X_STATUS_LIST_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end PA_STATUS_LIST_ITEMS_PKG;

/
