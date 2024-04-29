--------------------------------------------------------
--  DDL for Package Body IGW_EXP_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_EXP_CATEGORIES_PKG" as
-- $Header: igwstecb.pls 115.7 2002/11/14 18:44:59 vmedikon ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EXPENDITURE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_BUDGET_CATEGORY_CODE in VARCHAR2,
  X_PERSONNEL_ATTACHED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_EXPENDITURE_CATEGORIES
      where EXPENDITURE_CATEGORY = X_EXPENDITURE_CATEGORY;
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
  insert into IGW_EXPENDITURE_CATEGORIES (
    EXPENDITURE_CATEGORY,
    DESCRIPTION,
    BUDGET_CATEGORY_CODE,
    PERSONNEL_ATTACHED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EXPENDITURE_CATEGORY,
    decode(igw_security.gms_enabled, 'N', X_DESCRIPTION, null),
    X_BUDGET_CATEGORY_CODE,
    X_PERSONNEL_ATTACHED_FLAG,
    decode(igw_security.gms_enabled, 'N', X_START_DATE_ACTIVE, null),
    decode(igw_security.gms_enabled, 'N', X_END_DATE_ACTIVE, null),
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
  X_EXPENDITURE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_BUDGET_CATEGORY_CODE in VARCHAR2,
  X_PERSONNEL_ATTACHED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c1 is select *
    from IGW_EXPENDITURE_CATEGORIES
    where ROWID = X_ROWID
    for update of EXPENDITURE_CATEGORY nowait;
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
          (tlinfo.EXPENDITURE_CATEGORY = X_EXPENDITURE_CATEGORY)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
                OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)) OR (igw_security.gms_enabled = 'Y'))
      AND (tlinfo.BUDGET_CATEGORY_CODE = X_BUDGET_CATEGORY_CODE)
      AND (tlinfo.PERSONNEL_ATTACHED_FLAG = X_PERSONNEL_ATTACHED_FLAG)
      AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
         OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)) OR (igw_security.gms_enabled = 'Y'))
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
         OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)) OR (igw_security.gms_enabled = 'Y'))
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
  X_EXPENDITURE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_BUDGET_CATEGORY_CODE in VARCHAR2,
  X_PERSONNEL_ATTACHED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  update IGW_EXPENDITURE_CATEGORIES set
    EXPENDITURE_CATEGORY = X_EXPENDITURE_CATEGORY,
    DESCRIPTION = decode(igw_security.gms_enabled, 'N', X_DESCRIPTION, null),
    BUDGET_CATEGORY_CODE = X_BUDGET_CATEGORY_CODE,
    PERSONNEL_ATTACHED_FLAG = X_PERSONNEL_ATTACHED_FLAG,
    START_DATE_ACTIVE = decode(igw_security.gms_enabled, 'N', X_START_DATE_ACTIVE, null),
    END_DATE_ACTIVE = decode(igw_security.gms_enabled, 'N', X_END_DATE_ACTIVE, null),
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
  delete from IGW_EXPENDITURE_CATEGORIES
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_EXP_CATEGORIES_PKG;

/
