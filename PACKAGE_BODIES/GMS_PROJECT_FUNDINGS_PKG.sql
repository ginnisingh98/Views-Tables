--------------------------------------------------------
--  DDL for Package Body GMS_PROJECT_FUNDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PROJECT_FUNDINGS_PKG" as
-- $Header: gmsawpfb.pls 115.5 2002/11/26 12:47:43 mmalhotr ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GMS_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_INSTALLMENT_ID in NUMBER,
  X_FUNDING_AMOUNT in NUMBER,
  X_DATE_ALLOCATED in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from GMS_PROJECT_FUNDINGS
      where GMS_PROJECT_FUNDING_ID = X_GMS_PROJECT_FUNDING_ID;
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
  insert into GMS_PROJECT_FUNDINGS (
    GMS_PROJECT_FUNDING_ID,
    PROJECT_FUNDING_ID,
    PROJECT_ID,
    TASK_ID,
    INSTALLMENT_ID,
    FUNDING_AMOUNT,
    DATE_ALLOCATED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_GMS_PROJECT_FUNDING_ID,
    X_PROJECT_FUNDING_ID,
    X_PROJECT_ID,
    X_TASK_ID,
    X_INSTALLMENT_ID,
    X_FUNDING_AMOUNT,
    X_DATE_ALLOCATED,
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
  X_GMS_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_INSTALLMENT_ID in NUMBER,
  X_FUNDING_AMOUNT in NUMBER,
  X_DATE_ALLOCATED in DATE
) is
  cursor c1 is select
      PROJECT_FUNDING_ID,
      PROJECT_ID,
      TASK_ID,
      INSTALLMENT_ID,
      FUNDING_AMOUNT,
      DATE_ALLOCATED
    from GMS_PROJECT_FUNDINGS
    where GMS_PROJECT_FUNDING_ID = X_GMS_PROJECT_FUNDING_ID
    for update of GMS_PROJECT_FUNDING_ID nowait;
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

      if ( ((tlinfo.PROJECT_FUNDING_ID = X_PROJECT_FUNDING_ID)
           OR ((tlinfo.PROJECT_FUNDING_ID is null)
               AND (X_PROJECT_FUNDING_ID is null)))
      AND (tlinfo.PROJECT_ID = X_PROJECT_ID)
      AND ((tlinfo.TASK_ID = X_TASK_ID)
           OR ((tlinfo.TASK_ID is null)
               AND (X_TASK_ID is null)))
      AND (tlinfo.INSTALLMENT_ID = X_INSTALLMENT_ID)
      AND (tlinfo.FUNDING_AMOUNT = X_FUNDING_AMOUNT)
      AND (tlinfo.DATE_ALLOCATED = X_DATE_ALLOCATED)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_GMS_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_INSTALLMENT_ID in NUMBER,
  X_FUNDING_AMOUNT in NUMBER,
  X_DATE_ALLOCATED in DATE,
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
  update GMS_PROJECT_FUNDINGS set
    PROJECT_FUNDING_ID = X_PROJECT_FUNDING_ID,
    PROJECT_ID = X_PROJECT_ID,
    TASK_ID = X_TASK_ID,
    INSTALLMENT_ID = X_INSTALLMENT_ID,
    FUNDING_AMOUNT = X_FUNDING_AMOUNT,
    DATE_ALLOCATED = X_DATE_ALLOCATED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GMS_PROJECT_FUNDING_ID = X_GMS_PROJECT_FUNDING_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GMS_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_FUNDING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_INSTALLMENT_ID in NUMBER,
  X_FUNDING_AMOUNT in NUMBER,
  X_DATE_ALLOCATED in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from GMS_PROJECT_FUNDINGS
     where GMS_PROJECT_FUNDING_ID = X_GMS_PROJECT_FUNDING_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GMS_PROJECT_FUNDING_ID,
     X_PROJECT_FUNDING_ID,
     X_PROJECT_ID,
     X_TASK_ID,
     X_INSTALLMENT_ID,
     X_FUNDING_AMOUNT,
     X_DATE_ALLOCATED,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_GMS_PROJECT_FUNDING_ID,
   X_PROJECT_FUNDING_ID,
   X_PROJECT_ID,
   X_TASK_ID,
   X_INSTALLMENT_ID,
   X_FUNDING_AMOUNT,
   X_DATE_ALLOCATED,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_GMS_PROJECT_FUNDING_ID in NUMBER
) is
begin
  delete from GMS_PROJECT_FUNDINGS
  where GMS_PROJECT_FUNDING_ID = X_GMS_PROJECT_FUNDING_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end GMS_PROJECT_FUNDINGS_PKG;

/
