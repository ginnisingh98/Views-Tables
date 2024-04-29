--------------------------------------------------------
--  DDL for Package Body PSP_SCHEDULE_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SCHEDULE_HIERARCHY_PKG" as
-- $Header: PSPLSHIB.pls 115.7 2002/11/18 12:17:32 lveerubh ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHEDULE_HIERARCHY_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_SCHEDULING_TYPES_CODE in VARCHAR2,
  X_ELEMENT_GROUP_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER
  ) is
    cursor C is select ROWID from PSP_SCHEDULE_HIERARCHY
      where SCHEDULE_HIERARCHY_ID = X_SCHEDULE_HIERARCHY_ID
      and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
      and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    app_exception.raise_exception;
  end if;
  insert into PSP_SCHEDULE_HIERARCHY (
    SCHEDULE_HIERARCHY_ID,
    ASSIGNMENT_ID,
    SCHEDULING_TYPES_CODE,
    ELEMENT_GROUP_ID,
    ELEMENT_TYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    BUSINESS_GROUP_ID,
    SET_OF_BOOKS_ID
  ) values (
    X_SCHEDULE_HIERARCHY_ID,
    X_ASSIGNMENT_ID,
    X_SCHEDULING_TYPES_CODE,
    X_ELEMENT_GROUP_ID,
    X_ELEMENT_TYPE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_BUSINESS_GROUP_ID,
    X_SET_OF_BOOKS_ID
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
  X_SCHEDULE_HIERARCHY_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_SCHEDULING_TYPES_CODE in VARCHAR2,
  X_ELEMENT_GROUP_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER
) is
  cursor c1 is select
      ASSIGNMENT_ID,
      SCHEDULING_TYPES_CODE,
      ELEMENT_GROUP_ID,
      ELEMENT_TYPE_ID
    from PSP_SCHEDULE_HIERARCHY
    where SCHEDULE_HIERARCHY_ID = X_SCHEDULE_HIERARCHY_ID
    for update of SCHEDULE_HIERARCHY_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.ASSIGNMENT_ID = X_ASSIGNMENT_ID)
      AND ((tlinfo.SCHEDULING_TYPES_CODE = X_SCHEDULING_TYPES_CODE)
           OR ((tlinfo.SCHEDULING_TYPES_CODE is null)
               AND (X_SCHEDULING_TYPES_CODE is null)))
      AND ((tlinfo.ELEMENT_GROUP_ID = X_ELEMENT_GROUP_ID)
           OR ((tlinfo.ELEMENT_GROUP_ID is null)
               AND (X_ELEMENT_GROUP_ID is null)))
      AND ((tlinfo.ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID)
           OR ((tlinfo.ELEMENT_TYPE_ID is null)
               AND (X_ELEMENT_TYPE_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SCHEDULE_HIERARCHY_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_SCHEDULING_TYPES_CODE in VARCHAR2,
  X_ELEMENT_GROUP_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    app_exception.raise_exception;
  end if;
  update PSP_SCHEDULE_HIERARCHY set
    ASSIGNMENT_ID = X_ASSIGNMENT_ID,
    SCHEDULING_TYPES_CODE = X_SCHEDULING_TYPES_CODE,
    ELEMENT_GROUP_ID = X_ELEMENT_GROUP_ID,
    ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SCHEDULE_HIERARCHY_ID = X_SCHEDULE_HIERARCHY_ID
  and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
  and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHEDULE_HIERARCHY_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_SCHEDULING_TYPES_CODE in VARCHAR2,
  X_ELEMENT_GROUP_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER
  ) is
  cursor c1 is select rowid from PSP_SCHEDULE_HIERARCHY
     where SCHEDULE_HIERARCHY_ID = X_SCHEDULE_HIERARCHY_ID
     and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
     and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SCHEDULE_HIERARCHY_ID,
     X_ASSIGNMENT_ID,
     X_SCHEDULING_TYPES_CODE,
     X_ELEMENT_GROUP_ID,
     X_ELEMENT_TYPE_ID,
     X_MODE,
     X_BUSINESS_GROUP_ID,
     X_SET_OF_BOOKS_ID
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_SCHEDULE_HIERARCHY_ID,
   X_ASSIGNMENT_ID,
   X_SCHEDULING_TYPES_CODE,
   X_ELEMENT_GROUP_ID,
   X_ELEMENT_TYPE_ID,
   X_MODE,
   X_BUSINESS_GROUP_ID,
   X_SET_OF_BOOKS_ID);
end ADD_ROW;

procedure DELETE_ROW (
  X_SCHEDULE_HIERARCHY_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER
) is
begin
  delete from PSP_SCHEDULE_HIERARCHY
  where SCHEDULE_HIERARCHY_ID = X_SCHEDULE_HIERARCHY_ID
  and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
  and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_SCHEDULE_HIERARCHY_PKG;

/
