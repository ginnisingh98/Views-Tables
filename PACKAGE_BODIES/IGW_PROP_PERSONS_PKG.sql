--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PERSONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PERSONS_PKG" as
 /* $Header: igwpr40b.pls 115.11 2002/03/28 19:13:29 pkm ship      $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_PERSON_SEQUENCE in NUMBER,
  X_PROPOSAL_ROLE_CODE in VARCHAR2,
  X_PI_FLAG in VARCHAR2,
  X_KEY_PERSON_FLAG in VARCHAR2,
  X_PERCENT_EFFORT in NUMBER,
  X_PERSON_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_PROP_PERSONS
      where PROPOSAL_ID = X_PROPOSAL_ID
      and PERSON_ID = X_PERSON_ID;
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
  insert into IGW_PROP_PERSONS (
    PROPOSAL_ID,
    PERSON_ID,
    PERSON_SEQUENCE,
    PROPOSAL_ROLE_CODE,
    PI_FLAG,
    KEY_PERSON_FLAG,
    PERCENT_EFFORT,
    PERSON_ORGANIZATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROPOSAL_ID,
    X_PERSON_ID,
    X_PERSON_SEQUENCE,
    X_PROPOSAL_ROLE_CODE,
    X_PI_FLAG,
    X_KEY_PERSON_FLAG,
    X_PERCENT_EFFORT,
    X_PERSON_ORGANIZATION_ID,
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
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_PERSON_SEQUENCE in NUMBER,
  X_PROPOSAL_ROLE_CODE in VARCHAR2,
  X_PI_FLAG in VARCHAR2,
  X_KEY_PERSON_FLAG in VARCHAR2,
  X_PERCENT_EFFORT in NUMBER,
  X_PERSON_ORGANIZATION_ID in NUMBER
) is
  cursor c1 is select
      PERSON_ID,
      PERSON_SEQUENCE,
      PROPOSAL_ROLE_CODE,
      PI_FLAG,
      KEY_PERSON_FLAG,
      PERCENT_EFFORT,
      PERSON_ORGANIZATION_ID
    from IGW_PROP_PERSONS
    where ROWID = X_ROWID
    for update of PROPOSAL_ID nowait;
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

      if ( (tlinfo.PERSON_ID = X_PERSON_ID)
      AND  ((tlinfo.PERSON_SEQUENCE = X_PERSON_SEQUENCE)
           OR ((tlinfo.PERSON_SEQUENCE is null)
               AND (X_PERSON_SEQUENCE is null)))
      AND (tlinfo.PROPOSAL_ROLE_CODE = X_PROPOSAL_ROLE_CODE)
      AND ((tlinfo.PI_FLAG = X_PI_FLAG)
           OR ((tlinfo.PI_FLAG is null)
               AND (X_PI_FLAG is null)))
      AND ((tlinfo.KEY_PERSON_FLAG = X_KEY_PERSON_FLAG)
           OR ((tlinfo.KEY_PERSON_FLAG is null)
               AND (X_KEY_PERSON_FLAG is null)))
      AND ((tlinfo.PERCENT_EFFORT = X_PERCENT_EFFORT)
           OR ((tlinfo.PERCENT_EFFORT is null)
               AND (X_PERCENT_EFFORT is null)))
      AND ((tlinfo.PERSON_ORGANIZATION_ID = X_PERSON_ORGANIZATION_ID)
           OR ((tlinfo.PERSON_ORGANIZATION_ID is null)
               AND (X_PERSON_ORGANIZATION_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_PERSON_SEQUENCE in NUMBER,
  X_PROPOSAL_ROLE_CODE in VARCHAR2,
  X_PI_FLAG in VARCHAR2,
  X_KEY_PERSON_FLAG in VARCHAR2,
  X_PERCENT_EFFORT in NUMBER,
  X_PERSON_ORGANIZATION_ID in NUMBER,
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
  update IGW_PROP_PERSONS set
    PERSON_ID = X_PERSON_ID,
    PERSON_SEQUENCE = X_PERSON_SEQUENCE,
    PROPOSAL_ROLE_CODE = X_PROPOSAL_ROLE_CODE,
    PI_FLAG = X_PI_FLAG,
    KEY_PERSON_FLAG = X_KEY_PERSON_FLAG,
    PERCENT_EFFORT = X_PERCENT_EFFORT,
    PERSON_ORGANIZATION_ID = X_PERSON_ORGANIZATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_PERSON_SEQUENCE in NUMBER,
  X_PROPOSAL_ROLE_CODE in VARCHAR2,
  X_PI_FLAG in VARCHAR2,
  X_KEY_PERSON_FLAG in VARCHAR2,
  X_PERCENT_EFFORT in NUMBER,
  X_PERSON_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_PROP_PERSONS
     where PROPOSAL_ID = X_PROPOSAL_ID
     and PERSON_ID = X_PERSON_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROPOSAL_ID,
     X_PERSON_ID,
     X_PERSON_SEQUENCE,
     X_PROPOSAL_ROLE_CODE,
     X_PI_FLAG,
     X_KEY_PERSON_FLAG,
     X_PERCENT_EFFORT,
     X_PERSON_ORGANIZATION_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROPOSAL_ID,
   X_PERSON_ID,
   X_PERSON_SEQUENCE,
   X_PROPOSAL_ROLE_CODE,
   X_PI_FLAG,
   X_KEY_PERSON_FLAG,
   X_PERCENT_EFFORT,
   X_PERSON_ORGANIZATION_ID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  delete from IGW_PROP_PERSONS
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_PROP_PERSONS_PKG;

/
