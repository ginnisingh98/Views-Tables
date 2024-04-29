--------------------------------------------------------
--  DDL for Package Body GMS_AWARDS_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARDS_CONTACTS_PKG" as
-- $Header: gmsawctb.pls 115.5 2002/11/25 23:23:20 jmuthuku ship $

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_CONTACT_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_CUSTOMER_ID in NUMBER,
  X_PRIMARY_FLAG in VARCHAR2 default 'N',
  X_USAGE_CODE in VARCHAR2
  ) is
    cursor C is select ROWID from GMS_AWARDS_CONTACTS
      where AWARD_ID = X_AWARD_ID
      and CONTACT_ID = X_CONTACT_ID;
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
  insert into GMS_AWARDS_CONTACTS (
    AWARD_ID,
    CONTACT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CUSTOMER_ID,
    PRIMARY_FLAG,
    USAGE_CODE
  ) values (
    X_AWARD_ID,
    X_CONTACT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CUSTOMER_ID,
    X_PRIMARY_FLAG,
    X_USAGE_CODE
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
  X_CONTACT_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
  X_PRIMARY_FLAG IN VARCHAR2,
  X_USAGE_CODE in VARCHAR2,
  X_ROWID      in VARCHAR2
) is
  cursor c1 is select award_id, usage_code, primary_flag, contact_id, customer_id
    from GMS_AWARDS_CONTACTS
    where ROWID = X_ROWID
    for update of AWARD_ID nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  close c1;
  if (
		(tlinfo.award_id = x_award_id)
	  AND   (   (tlinfo.usage_code = x_usage_code)
	      OR    (	(tlinfo.usage_code is NULL)
		     AND (x_usage_code is NULL)))
          AND   (   (tlinfo.primary_flag = x_primary_flag)
	      OR    (    (tlinfo.primary_flag is NULL)
		     AND (x_primary_flag is NULL)))
	  AND   (tlinfo.contact_id = x_contact_id)
          AND   (tlinfo.customer_id = x_customer_id)
   	  ) then
	  return;
  else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       app_exception.raise_exception;
  end if;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_AWARD_ID in NUMBER,
  X_CONTACT_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_CUSTOMER_ID in NUMBER,
  X_PRIMARY_FLAG in VARCHAR2,
  X_USAGE_CODE in VARCHAR2,
  X_ROWID      in VARCHAR2
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
  update GMS_AWARDS_CONTACTS set
    CONTACT_ID = X_CONTACT_ID,
    PRIMARY_FLAG = X_PRIMARY_FLAG,
    USAGE_CODE = X_USAGE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_AWARD_ID in NUMBER,
  X_CONTACT_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
  X_ROWID       in VARCHAR2
) is
begin
  delete from GMS_AWARDS_CONTACTS
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end GMS_AWARDS_CONTACTS_PKG;

/
