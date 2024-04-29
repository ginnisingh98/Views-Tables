--------------------------------------------------------
--  DDL for Package Body GMS_AWARDS_TC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARDS_TC_PKG" as
-- $Header: gmsawtcb.pls 120.1 2005/07/26 14:21:02 appldev ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from GMS_AWARDS_TERMS_CONDITIONS
      where AWARD_ID = X_AWARD_ID
      and CATEGORY_ID = X_CATEGORY_ID
      and TERM_ID = X_TERM_ID;
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
  insert into GMS_AWARDS_TERMS_CONDITIONS (
    AWARD_ID,
    CATEGORY_ID,
    TERM_ID,
    OPERAND,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AWARD_ID,
    X_CATEGORY_ID,
    X_TERM_ID,
    X_OPERAND,
    X_VALUE,
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
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER
) is
  cursor c1 is select
      OPERAND,
      VALUE
    from GMS_AWARDS_TERMS_CONDITIONS
    where AWARD_ID = X_AWARD_ID
    and CATEGORY_ID = X_CATEGORY_ID
    and TERM_ID = X_TERM_ID
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
      if ( ((tlinfo.OPERAND = X_OPERAND)
           OR ((tlinfo.OPERAND is null)
               AND (X_OPERAND is null)))
      AND ((tlinfo.VALUE = X_VALUE)
           OR ((tlinfo.VALUE is null)
               AND (X_VALUE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER,
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
  update GMS_AWARDS_TERMS_CONDITIONS set
    OPERAND = X_OPERAND,
    VALUE = X_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AWARD_ID = X_AWARD_ID
  and CATEGORY_ID = X_CATEGORY_ID
  and TERM_ID = X_TERM_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER
) is
begin
  delete from GMS_AWARDS_TERMS_CONDITIONS
  where AWARD_ID = X_AWARD_ID
  and CATEGORY_ID = X_CATEGORY_ID
  and TERM_ID = X_TERM_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end GMS_AWARDS_TC_PKG;

/
