--------------------------------------------------------
--  DDL for Package Body IGW_INSTITUTE_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_INSTITUTE_RATES_PKG" as
-- $Header: igwstrab.pls 115.4 2002/11/14 18:47:09 vmedikon ship $

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RATE_CLASS_ID in NUMBER,
  X_RATE_TYPE_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_FISCAL_YEAR in NUMBER,
  X_LOCATION_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_RATE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_INSTITUTE_RATES
      where RATE_CLASS_ID = X_RATE_CLASS_ID
      and   RATE_TYPE_ID = X_RATE_TYPE_ID
      and   ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE
      and   FISCAL_YEAR = X_FISCAL_YEAR
      and   LOCATION_CODE = X_LOCATION_CODE;
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
  insert into IGW_INSTITUTE_RATES (
    RATE_CLASS_ID,
    RATE_TYPE_ID,
    ACTIVITY_TYPE_CODE,
    FISCAL_YEAR,
    LOCATION_CODE,
    START_DATE,
    RATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RATE_CLASS_ID,
    X_RATE_TYPE_ID,
    X_ACTIVITY_TYPE_CODE,
    X_FISCAL_YEAR,
    X_LOCATION_CODE,
    X_START_DATE,
    X_RATE,
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
  X_ROWID in out NOCOPY VARCHAR2,
  X_RATE_CLASS_ID in NUMBER,
  X_RATE_TYPE_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_FISCAL_YEAR in NUMBER,
  X_LOCATION_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_RATE in NUMBER
) is
  cursor c1 is select *
    from IGW_INSTITUTE_RATES
    where ROWID = X_ROWID
    for update of RATE_CLASS_ID, RATE_TYPE_ID, ACTIVITY_TYPE_CODE, FISCAL_YEAR, LOCATION_CODE nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if (
          (tlinfo.RATE_CLASS_ID = X_RATE_CLASS_ID)
      AND (tlinfo.RATE_TYPE_ID = X_RATE_TYPE_ID)
      AND (tlinfo.ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE)
      AND (tlinfo.FISCAL_YEAR = X_FISCAL_YEAR)
      AND (tlinfo.LOCATION_CODE = X_LOCATION_CODE)
      AND (tlinfo.START_DATE = X_START_DATE)
      AND (tlinfo.RATE = X_RATE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RATE_CLASS_ID in NUMBER,
  X_RATE_TYPE_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_FISCAL_YEAR in NUMBER,
  X_LOCATION_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_RATE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if (X_MODE = 'I') then
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
  update IGW_INSTITUTE_RATES set
    RATE_CLASS_ID = X_RATE_CLASS_ID,
    RATE_TYPE_ID = X_RATE_TYPE_ID,
    ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE,
    FISCAL_YEAR = X_FISCAL_YEAR,
    LOCATION_CODE = X_LOCATION_CODE,
    START_DATE = X_START_DATE,
    RATE = X_RATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RULE_ID in NUMBER,
  X_RULE_SEQUENCE_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_MAP_ID in NUMBER,
  X_VALID_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_BUSINESS_RULES_ALL
     where RULE_ID = X_RULE_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_RULE_ID,
     X_RULE_SEQUENCE_NUMBER,
     X_ORGANIZATION_ID,
     X_RULE_NAME,
     X_RULE_TYPE,
     X_MAP_ID,
     X_VALID_FLAG,
     X_START_DATE_ACTIVE,
     X_END_DATE_ACTIVE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_RULE_ID,
   X_RULE_SEQUENCE_NUMBER,
   X_ORGANIZATION_ID,
   X_RULE_NAME,
   X_RULE_TYPE,
   X_MAP_ID,
   X_VALID_FLAG,
   X_START_DATE_ACTIVE,
   X_END_DATE_ACTIVE,
   X_MODE);
end ADD_ROW; */

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  delete from IGW_INSTITUTE_RATES
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_INSTITUTE_RATES_PKG;

/
