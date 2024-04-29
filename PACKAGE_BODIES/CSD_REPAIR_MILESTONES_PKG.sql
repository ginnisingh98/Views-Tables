--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_MILESTONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_MILESTONES_PKG" as
/* $Header: csdtromb.pls 120.0 2005/07/14 18:57:09 vkjain noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_REPAIR_MILESTONE_ID in out nocopy NUMBER,
  P_REPAIR_LINE_ID in NUMBER,
  P_MILESTONE_CODE in VARCHAR2,
  P_MILESTONE_DATE in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is

  P_ROWID ROWID;

  cursor C is select ROWID from CSD_REPAIR_MILESTONES
    where REPAIR_MILESTONE_ID = PX_REPAIR_MILESTONE_ID
    ;

begin

  select CSD_REPAIR_MILESTONES_S1.nextval
  into PX_REPAIR_MILESTONE_ID
  from dual;

  insert into CSD_REPAIR_MILESTONES (
    REPAIR_MILESTONE_ID,
    REPAIR_LINE_ID,
    MILESTONE_CODE,
    MILESTONE_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    PX_REPAIR_MILESTONE_ID,
    P_REPAIR_LINE_ID,
    P_MILESTONE_CODE,
    P_MILESTONE_DATE,
    P_OBJECT_VERSION_NUMBER,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_REPAIR_MILESTONE_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CSD_REPAIR_MILESTONES
    where REPAIR_MILESTONE_ID = P_REPAIR_MILESTONE_ID
    for update of REPAIR_MILESTONE_ID nowait;
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

  if (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_REPAIR_MILESTONE_ID in NUMBER,
  P_REPAIR_LINE_ID in NUMBER,
  P_MILESTONE_CODE in VARCHAR2,
  P_MILESTONE_DATE in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CSD_REPAIR_MILESTONES set
    REPAIR_LINE_ID = P_REPAIR_LINE_ID,
    MILESTONE_CODE = P_MILESTONE_CODE,
    MILESTONE_DATE = P_MILESTONE_DATE,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where REPAIR_MILESTONE_ID = P_REPAIR_MILESTONE_ID AND
        OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_REPAIR_MILESTONE_ID in NUMBER
) is
begin

  delete from CSD_REPAIR_MILESTONES
  where REPAIR_MILESTONE_ID = P_REPAIR_MILESTONE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end CSD_REPAIR_MILESTONES_PKG;

/