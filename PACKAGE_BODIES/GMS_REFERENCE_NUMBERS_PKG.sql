--------------------------------------------------------
--  DDL for Package Body GMS_REFERENCE_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_REFERENCE_NUMBERS_PKG" as
-- $Header: gmsawrfb.pls 115.7 2002/11/26 19:03:16 jmuthuku ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from GMS_REFERENCE_NUMBERS
      where AWARD_ID = X_AWARD_ID
      and TYPE = X_TYPE
      and (VALUE = X_VALUE
          OR (VALUE IS NULL AND X_VALUE IS NULL)) ;  -- Bug 2652987, Added;
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
  insert into GMS_REFERENCE_NUMBERS (
    AWARD_ID,
    TYPE,
    VALUE,
    REQUIRED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AWARD_ID,
    X_TYPE,
    X_VALUE,
    X_REQUIRED_FLAG,
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
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_ROWID in VARCHAR2
) is
  cursor c1 is select
      TYPE, VALUE, REQUIRED_FLAG
    from GMS_REFERENCE_NUMBERS
    where ROWID = X_ROWID  -- Bug 2652987, Added
    for update of AWARD_ID nowait;
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

  if ( (tlinfo.TYPE = X_TYPE)  -- Bug 2652987, Added
     AND (tlinfo.VALUE = X_VALUE OR tlinfo.VALUE is null AND X_VALUE is null)
     AND (tlinfo.REQUIRED_FLAG = X_REQUIRED_FLAG OR tlinfo.REQUIRED_FLAG is null AND X_REQUIRED_FLAG is null)
     ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROW_ID in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2
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
  update GMS_REFERENCE_NUMBERS set
    TYPE = X_TYPE,
    VALUE = X_VALUE,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
/* Commented out NOCOPY for bug fix 1829009.Now rowid is used to uniquely identify the records

  where AWARD_ID = X_AWARD_ID
  and TYPE = X_TYPE
*/
  where rowid = X_ROW_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
  cursor c1 is select rowid from GMS_REFERENCE_NUMBERS
     where AWARD_ID = X_AWARD_ID
     and TYPE = X_TYPE
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_AWARD_ID,
     X_TYPE,
     X_VALUE,
     X_REQUIRED_FLAG,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_AWARD_ID,
   X_TYPE,
   X_VALUE,
   X_REQUIRED_FLAG,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2, -- Bug 2652987, Added
  X_ROWID in VARCHAR2  -- Bug 2652987, Added
) is
begin
  delete from GMS_REFERENCE_NUMBERS
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end GMS_REFERENCE_NUMBERS_PKG;

/
