--------------------------------------------------------
--  DDL for Package Body PSP_ER_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ER_APPROVALS_PKG" as
 /* $Header: PSPERAPB.pls 115.4 2002/11/18 12:24:42 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EFFORT_REPORT_ID in NUMBER,
  X_VERSION_NUM in NUMBER,
  X_APPROVING_PERSON_ID in NUMBER,
  X_APPROVED_DATE in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_ER_APPROVALS
      where EFFORT_REPORT_ID = X_EFFORT_REPORT_ID
      and VERSION_NUM = X_VERSION_NUM
      and APPROVING_PERSON_ID = X_APPROVING_PERSON_ID;
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
  insert into PSP_ER_APPROVALS (
    EFFORT_REPORT_ID,
    VERSION_NUM,
    APPROVING_PERSON_ID,
    APPROVED_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EFFORT_REPORT_ID,
    X_VERSION_NUM,
    X_APPROVING_PERSON_ID,
    X_APPROVED_DATE,
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
  commit;

end INSERT_ROW;

procedure LOCK_ROW (
  X_EFFORT_REPORT_ID in NUMBER,
  X_VERSION_NUM in NUMBER,
  X_APPROVING_PERSON_ID in NUMBER,
  X_APPROVED_DATE in DATE
) is
  cursor c1 is select
      APPROVED_DATE
    from PSP_ER_APPROVALS
    where EFFORT_REPORT_ID = X_EFFORT_REPORT_ID
    and VERSION_NUM = X_VERSION_NUM
    and APPROVING_PERSON_ID = X_APPROVING_PERSON_ID
    for update of EFFORT_REPORT_ID nowait;
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

  if ( (tlinfo.APPROVED_DATE = X_APPROVED_DATE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_EFFORT_REPORT_ID in NUMBER,
  X_VERSION_NUM in NUMBER,
  X_APPROVING_PERSON_ID in NUMBER,
  X_APPROVED_DATE in DATE,
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
  update PSP_ER_APPROVALS set
    APPROVED_DATE = X_APPROVED_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EFFORT_REPORT_ID = X_EFFORT_REPORT_ID
  and VERSION_NUM = X_VERSION_NUM
  and APPROVING_PERSON_ID = X_APPROVING_PERSON_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EFFORT_REPORT_ID in NUMBER,
  X_VERSION_NUM in NUMBER,
  X_APPROVING_PERSON_ID in NUMBER,
  X_APPROVED_DATE in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_ER_APPROVALS
     where EFFORT_REPORT_ID = X_EFFORT_REPORT_ID
     and VERSION_NUM = X_VERSION_NUM
     and APPROVING_PERSON_ID = X_APPROVING_PERSON_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_EFFORT_REPORT_ID,
     X_VERSION_NUM,
     X_APPROVING_PERSON_ID,
     X_APPROVED_DATE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_EFFORT_REPORT_ID,
   X_VERSION_NUM,
   X_APPROVING_PERSON_ID,
   X_APPROVED_DATE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_EFFORT_REPORT_ID in NUMBER,
  X_VERSION_NUM in NUMBER,
  X_APPROVING_PERSON_ID in NUMBER
) is
begin
  delete from PSP_ER_APPROVALS
  where EFFORT_REPORT_ID = X_EFFORT_REPORT_ID
  and VERSION_NUM = X_VERSION_NUM
  and APPROVING_PERSON_ID = X_APPROVING_PERSON_ID;
  ---if (sql%notfound) then
    ---raise no_data_found;
  --- end if;
  commit;
end DELETE_ROW;

end PSP_ER_APPROVALS_PKG;

/
