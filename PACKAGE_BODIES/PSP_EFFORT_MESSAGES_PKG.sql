--------------------------------------------------------
--  DDL for Package Body PSP_EFFORT_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFFORT_MESSAGES_PKG" as
 /* $Header: PSPERMEB.pls 115.4 2002/11/18 12:34:34 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MESSAGE_ID in NUMBER,
  X_EFFORT_REPORT_MESSAGE_TYPE in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_EFFORT_MESSAGES
      where MESSAGE_ID = X_MESSAGE_ID;
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
  insert into PSP_EFFORT_MESSAGES (
    MESSAGE_ID,
    EFFORT_REPORT_MESSAGE_TYPE,
    TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MESSAGE_ID,
    X_EFFORT_REPORT_MESSAGE_TYPE,
    X_TEXT,
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
  X_MESSAGE_ID in NUMBER,
  X_EFFORT_REPORT_MESSAGE_TYPE in VARCHAR2,
  X_TEXT in VARCHAR2
) is
  cursor c1 is select
      EFFORT_REPORT_MESSAGE_TYPE,
      TEXT
    from PSP_EFFORT_MESSAGES
    where MESSAGE_ID = X_MESSAGE_ID
    for update of MESSAGE_ID nowait;
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

  if ( (tlinfo.EFFORT_REPORT_MESSAGE_TYPE = X_EFFORT_REPORT_MESSAGE_TYPE)
      AND (tlinfo.TEXT = X_TEXT)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_MESSAGE_ID in NUMBER,
  X_EFFORT_REPORT_MESSAGE_TYPE in VARCHAR2,
  X_TEXT in VARCHAR2,
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
  update PSP_EFFORT_MESSAGES set
    EFFORT_REPORT_MESSAGE_TYPE = X_EFFORT_REPORT_MESSAGE_TYPE,
    TEXT = X_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MESSAGE_ID = X_MESSAGE_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MESSAGE_ID in NUMBER,
  X_EFFORT_REPORT_MESSAGE_TYPE in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_EFFORT_MESSAGES
     where MESSAGE_ID = X_MESSAGE_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_MESSAGE_ID,
     X_EFFORT_REPORT_MESSAGE_TYPE,
     X_TEXT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_MESSAGE_ID,
   X_EFFORT_REPORT_MESSAGE_TYPE,
   X_TEXT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_MESSAGE_ID in NUMBER
) is
begin
  delete from PSP_EFFORT_MESSAGES
  where MESSAGE_ID = X_MESSAGE_ID;
  ---if (sql%notfound) then
    ---raise no_data_found;
  ---end if;
end DELETE_ROW;

end PSP_EFFORT_MESSAGES_PKG;

/
