--------------------------------------------------------
--  DDL for Package Body GMS_PERSONNEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PERSONNEL_PKG" as
-- $Header: gmsawplb.pls 115.4 2002/11/26 18:49:56 jmuthuku ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSONNEL_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_AWARD_ROLE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from GMS_PERSONNEL
      where PERSONNEL_ID = X_PERSONNEL_ID;
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
  insert into GMS_PERSONNEL (
    AWARD_ID,
    PERSON_ID,
    AWARD_ROLE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    PERSONNEL_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUIRED_FLAG
  ) values (
    X_AWARD_ID,
    X_PERSON_ID,
    X_AWARD_ROLE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_PERSONNEL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUIRED_FLAG
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
  X_PERSONNEL_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_AWARD_ROLE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_REQUIRED_FLAG in VARCHAR2
) is
  cursor c1 is select
      AWARD_ID,
      PERSON_ID,
      AWARD_ROLE,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      REQUIRED_FLAG
    from GMS_PERSONNEL
    where PERSONNEL_ID = X_PERSONNEL_ID
    for update of PERSONNEL_ID nowait;
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

  if ( (tlinfo.AWARD_ID = X_AWARD_ID)
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.AWARD_ROLE = X_AWARD_ROLE)
      AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((tlinfo.START_DATE_ACTIVE is null)
               AND (X_START_DATE_ACTIVE is null)))
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
      AND ((tlinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
           OR ((tlinfo.REQUIRED_FLAG is null)
               AND (X_REQUIRED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PERSONNEL_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_AWARD_ROLE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_REQUIRED_FLAG in VARCHAR2,
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
  update GMS_PERSONNEL set
    AWARD_ID = X_AWARD_ID,
    PERSON_ID = X_PERSON_ID,
    AWARD_ROLE = X_AWARD_ROLE,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUIRED_FLAG  = X_REQUIRED_FLAG
  where PERSONNEL_ID = X_PERSONNEL_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSONNEL_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_AWARD_ROLE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from GMS_PERSONNEL
     where PERSONNEL_ID = X_PERSONNEL_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSONNEL_ID,
     X_AWARD_ID,
     X_PERSON_ID,
     X_AWARD_ROLE,
     X_START_DATE_ACTIVE,
     X_END_DATE_ACTIVE,
     X_REQUIRED_FLAG,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_PERSONNEL_ID,
   X_AWARD_ID,
   X_PERSON_ID,
   X_AWARD_ROLE,
   X_START_DATE_ACTIVE,
   X_END_DATE_ACTIVE,
   X_REQUIRED_FLAG,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_PERSONNEL_ID in NUMBER
) is
begin
  delete from GMS_PERSONNEL
  where PERSONNEL_ID = X_PERSONNEL_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end GMS_PERSONNEL_PKG;

/
