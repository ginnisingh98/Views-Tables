--------------------------------------------------------
--  DDL for Package Body PSP_SUB_LINE_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SUB_LINE_REASONS_PKG" as
 /* $Header: PSPPITRB.pls 115.5 2002/11/18 11:02:42 ddubey ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_SUB_LINE_ID in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_PARENT_LINE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_SUB_LINE_REASONS
      where PAYROLL_SUB_LINE_ID = X_PAYROLL_SUB_LINE_ID
      and REASON_CODE = X_REASON_CODE;
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
  insert into PSP_SUB_LINE_REASONS (
    PAYROLL_SUB_LINE_ID,
    REASON_CODE,
    PARENT_LINE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PAYROLL_SUB_LINE_ID,
    X_REASON_CODE,
    X_PARENT_LINE_ID,
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
  X_PAYROLL_SUB_LINE_ID in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_PARENT_LINE_ID in NUMBER
) is
  cursor c1 is select
      PARENT_LINE_ID
    from PSP_SUB_LINE_REASONS
    where PAYROLL_SUB_LINE_ID = X_PAYROLL_SUB_LINE_ID
    and REASON_CODE = X_REASON_CODE
    for update of PAYROLL_SUB_LINE_ID nowait;
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

  if ( (tlinfo.PARENT_LINE_ID = X_PARENT_LINE_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PAYROLL_SUB_LINE_ID in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_PARENT_LINE_ID in NUMBER,
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
  update PSP_SUB_LINE_REASONS set
    PARENT_LINE_ID = X_PARENT_LINE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PAYROLL_SUB_LINE_ID = X_PAYROLL_SUB_LINE_ID
  and REASON_CODE = X_REASON_CODE
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_SUB_LINE_ID in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_PARENT_LINE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_SUB_LINE_REASONS
     where PAYROLL_SUB_LINE_ID = X_PAYROLL_SUB_LINE_ID
     and REASON_CODE = X_REASON_CODE
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PAYROLL_SUB_LINE_ID,
     X_REASON_CODE,
     X_PARENT_LINE_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_PAYROLL_SUB_LINE_ID,
   X_REASON_CODE,
   X_PARENT_LINE_ID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_PAYROLL_SUB_LINE_ID in NUMBER,
  X_REASON_CODE in VARCHAR2
) is
begin
  delete from PSP_SUB_LINE_REASONS
  where PAYROLL_SUB_LINE_ID = X_PAYROLL_SUB_LINE_ID
  and REASON_CODE = X_REASON_CODE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_SUB_LINE_REASONS_PKG;

/
