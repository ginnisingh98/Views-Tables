--------------------------------------------------------
--  DDL for Package Body PSP_REP_ORG_DLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_REP_ORG_DLS_PKG" as
  /* $Header: PSPREDLB.pls 115.6 2002/11/18 11:59:20 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_DLS_LINE_ID in NUMBER,
  X_ORG_DLS_BATCH_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_SCHEDULE_LINE_ID in NUMBER,
  X_SCHEDULE_BEGIN_DATE in DATE,
  X_SCHEDULE_END_DATE in DATE,
  X_ORIGINAL_SCH_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_REP_ORG_DLS
      where ORG_DLS_LINE_ID = X_ORG_DLS_LINE_ID;
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
  insert into PSP_REP_ORG_DLS (
    ORG_DLS_BATCH_ID,
    ORG_DLS_LINE_ID,
    ORGANIZATION_ID,
    ASSIGNMENT_ID,
    PERSON_ID,
    ELEMENT_TYPE_ID,
    SCHEDULE_LINE_ID,
    SCHEDULE_BEGIN_DATE,
    SCHEDULE_END_DATE,
    ORIGINAL_SCH_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ORG_DLS_BATCH_ID,
    X_ORG_DLS_LINE_ID,
    X_ORGANIZATION_ID,
    X_ASSIGNMENT_ID,
    X_PERSON_ID,
    X_ELEMENT_TYPE_ID,
    X_SCHEDULE_LINE_ID,
    X_SCHEDULE_BEGIN_DATE,
    X_SCHEDULE_END_DATE,
    X_ORIGINAL_SCH_CODE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
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
  X_ORG_DLS_LINE_ID in NUMBER,
  X_ORG_DLS_BATCH_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_SCHEDULE_LINE_ID in NUMBER,
  X_SCHEDULE_BEGIN_DATE in DATE,
  X_SCHEDULE_END_DATE in DATE,
  X_ORIGINAL_SCH_CODE in VARCHAR2
) is
  cursor c1 is select
      ORG_DLS_BATCH_ID,
      ORGANIZATION_ID,
      ASSIGNMENT_ID,
      PERSON_ID,
      ELEMENT_TYPE_ID,
      SCHEDULE_LINE_ID,
      SCHEDULE_BEGIN_DATE,
      SCHEDULE_END_DATE,
      ORIGINAL_SCH_CODE
    from PSP_REP_ORG_DLS
    where ORG_DLS_LINE_ID = X_ORG_DLS_LINE_ID
    for update of ORG_DLS_LINE_ID nowait;
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

  if ( (tlinfo.ORG_DLS_BATCH_ID = X_ORG_DLS_BATCH_ID)
      AND (tlinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND (tlinfo.ASSIGNMENT_ID = X_ASSIGNMENT_ID)
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND ((tlinfo.ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID)
           OR ((tlinfo.ELEMENT_TYPE_ID is null)
               AND (X_ELEMENT_TYPE_ID is null)))
      AND ((tlinfo.SCHEDULE_LINE_ID = X_SCHEDULE_LINE_ID)
           OR ((tlinfo.SCHEDULE_LINE_ID is null)
               AND (X_SCHEDULE_LINE_ID is null)))
      AND (tlinfo.SCHEDULE_BEGIN_DATE = X_SCHEDULE_BEGIN_DATE)
      AND (tlinfo.SCHEDULE_END_DATE = X_SCHEDULE_END_DATE)
      AND (tlinfo.ORIGINAL_SCH_CODE = X_ORIGINAL_SCH_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ORG_DLS_LINE_ID in NUMBER,
  X_ORG_DLS_BATCH_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_SCHEDULE_LINE_ID in NUMBER,
  X_SCHEDULE_BEGIN_DATE in DATE,
  X_SCHEDULE_END_DATE in DATE,
  X_ORIGINAL_SCH_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
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
  update PSP_REP_ORG_DLS set
    ORG_DLS_BATCH_ID = X_ORG_DLS_BATCH_ID,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    ASSIGNMENT_ID = X_ASSIGNMENT_ID,
    PERSON_ID = X_PERSON_ID,
    ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID,
    SCHEDULE_LINE_ID = X_SCHEDULE_LINE_ID,
    SCHEDULE_BEGIN_DATE = X_SCHEDULE_BEGIN_DATE,
    SCHEDULE_END_DATE = X_SCHEDULE_END_DATE,
    ORIGINAL_SCH_CODE = X_ORIGINAL_SCH_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ORG_DLS_LINE_ID = X_ORG_DLS_LINE_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_DLS_LINE_ID in NUMBER,
  X_ORG_DLS_BATCH_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_SCHEDULE_LINE_ID in NUMBER,
  X_SCHEDULE_BEGIN_DATE in DATE,
  X_SCHEDULE_END_DATE in DATE,
  X_ORIGINAL_SCH_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_REP_ORG_DLS
     where ORG_DLS_LINE_ID = X_ORG_DLS_LINE_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_DLS_LINE_ID,
     X_ORG_DLS_BATCH_ID,
     X_ORGANIZATION_ID,
     X_ASSIGNMENT_ID,
     X_PERSON_ID,
     X_ELEMENT_TYPE_ID,
     X_SCHEDULE_LINE_ID,
     X_SCHEDULE_BEGIN_DATE,
     X_SCHEDULE_END_DATE,
     X_ORIGINAL_SCH_CODE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ORG_DLS_LINE_ID,
   X_ORG_DLS_BATCH_ID,
   X_ORGANIZATION_ID,
   X_ASSIGNMENT_ID,
   X_PERSON_ID,
   X_ELEMENT_TYPE_ID,
   X_SCHEDULE_LINE_ID,
   X_SCHEDULE_BEGIN_DATE,
   X_SCHEDULE_END_DATE,
   X_ORIGINAL_SCH_CODE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ORG_DLS_LINE_ID in NUMBER
) is
begin
  delete from PSP_REP_ORG_DLS
  where ORG_DLS_LINE_ID = X_ORG_DLS_LINE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_REP_ORG_DLS_PKG;

/
