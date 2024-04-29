--------------------------------------------------------
--  DDL for Package Body IGW_PROP_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_LOCATIONS_PKG" as
 /* $Header: igwpr30b.pls 115.6 2002/03/28 19:13:27 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_PROP_LOCATIONS
      where PROPOSAL_ID = X_PROPOSAL_ID
      and   PERFORMING_ORGANIZATION_ID = X_PERFORMING_ORGANIZATION_ID;
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
  insert into IGW_PROP_LOCATIONS (
    PROPOSAL_ID,
    PERFORMING_ORGANIZATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROPOSAL_ID,
    X_PERFORMING_ORGANIZATION_ID,
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
  X_PERFORMING_ORGANIZATION_ID in NUMBER
) is
  cursor c1 is select
      PERFORMING_ORGANIZATION_ID
    from IGW_PROP_LOCATIONS
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

  if ( (tlinfo.PERFORMING_ORGANIZATION_ID = X_PERFORMING_ORGANIZATION_ID)
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
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
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
  update IGW_PROP_LOCATIONS set
    PERFORMING_ORGANIZATION_ID = X_PERFORMING_ORGANIZATION_ID,
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
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_PROP_LOCATIONS
     where PROPOSAL_ID = X_PROPOSAL_ID
     and   PERFORMING_ORGANIZATION_ID = X_PERFORMING_ORGANIZATION_ID
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
     X_PERFORMING_ORGANIZATION_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROPOSAL_ID,
   X_PERFORMING_ORGANIZATION_ID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  delete from IGW_PROP_LOCATIONS
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_PROP_LOCATIONS_PKG;

/
