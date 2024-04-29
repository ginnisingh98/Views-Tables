--------------------------------------------------------
--  DDL for Package Body PSP_ENC_PAYROLL_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_PAYROLL_ASSIGN_PKG" AS
--$Header: PSPENPAB.pls 115.9 2002/11/19 11:47:22 ddubey ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_PAYROLL_ASSIGNMENT_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ENC_PAYROLL_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_ENC_PAYROLL_ASSIGNMENTS
      where ENC_PAYROLL_ASSIGNMENT_ID = X_ENC_PAYROLL_ASSIGNMENT_ID;
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
  insert into PSP_ENC_PAYROLL_ASSIGNMENTS (
    ENC_PAYROLL_ASSIGNMENT_ID,
    BUSINESS_GROUP_ID,
    SET_OF_BOOKS_ID,
    ENC_PAYROLL_ID,
    ASSIGNMENT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ENC_PAYROLL_ASSIGNMENT_ID,
    X_BUSINESS_GROUP_ID,
    X_SET_OF_BOOKS_ID,
    X_ENC_PAYROLL_ID,
    X_ASSIGNMENT_ID,
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
  --  raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ENC_PAYROLL_ASSIGNMENT_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ENC_PAYROLL_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER
) is
  cursor c1 is select
      BUSINESS_GROUP_ID,
      SET_OF_BOOKS_ID,
      ENC_PAYROLL_ID,
      ASSIGNMENT_ID
    from PSP_ENC_PAYROLL_ASSIGNMENTS
    where ENC_PAYROLL_ASSIGNMENT_ID = X_ENC_PAYROLL_ASSIGNMENT_ID
    for update of ENC_PAYROLL_ASSIGNMENT_ID nowait;
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

  if ((tlinfo.BUSINESS_GROUP_ID =  X_BUSINESS_GROUP_ID)
      AND (tlinfo.SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID)
      AND (tlinfo.ENC_PAYROLL_ID = X_ENC_PAYROLL_ID)
      AND (tlinfo.ASSIGNMENT_ID = X_ASSIGNMENT_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ENC_PAYROLL_ASSIGNMENT_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ENC_PAYROLL_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
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
  update PSP_ENC_PAYROLL_ASSIGNMENTS set
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID,
    ENC_PAYROLL_ID = X_ENC_PAYROLL_ID,
    ASSIGNMENT_ID = X_ASSIGNMENT_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ENC_PAYROLL_ASSIGNMENT_ID = X_ENC_PAYROLL_ASSIGNMENT_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_PAYROLL_ASSIGNMENT_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ENC_PAYROLL_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_ENC_PAYROLL_ASSIGNMENTS
     where ENC_PAYROLL_ASSIGNMENT_ID = X_ENC_PAYROLL_ASSIGNMENT_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENC_PAYROLL_ASSIGNMENT_ID,
     X_BUSINESS_GROUP_ID,
     X_SET_OF_BOOKS_ID,
     X_ENC_PAYROLL_ID,
     X_ASSIGNMENT_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ENC_PAYROLL_ASSIGNMENT_ID,
   X_BUSINESS_GROUP_ID,
   X_SET_OF_BOOKS_ID,
   X_ENC_PAYROLL_ID,
   X_ASSIGNMENT_ID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ENC_PAYROLL_ASSIGNMENT_ID in NUMBER
) is
begin
  delete from PSP_ENC_PAYROLL_ASSIGNMENTS
  where ENC_PAYROLL_ASSIGNMENT_ID = X_ENC_PAYROLL_ASSIGNMENT_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_ENC_PAYROLL_ASSIGN_PKG;

/
