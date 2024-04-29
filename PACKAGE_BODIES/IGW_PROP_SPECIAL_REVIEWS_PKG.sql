--------------------------------------------------------
--  DDL for Package Body IGW_PROP_SPECIAL_REVIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_SPECIAL_REVIEWS_PKG" as
 /* $Header: igwpr60b.pls 115.7 2002/03/28 19:13:31 pkm ship      $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_SPECIAL_REVIEW_CODE in VARCHAR2,
  X_SPECIAL_REVIEW_TYPE in VARCHAR2,
  X_APPROVAL_TYPE_CODE in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_APPLICATION_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_PROP_SPECIAL_REVIEWS
      where PROPOSAL_ID = X_PROPOSAL_ID
      AND   SPECIAL_REVIEW_CODE = X_SPECIAL_REVIEW_CODE;

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
  insert into IGW_PROP_SPECIAL_REVIEWS (
    PROPOSAL_ID,
    SPECIAL_REVIEW_CODE,
    SPECIAL_REVIEW_TYPE,
    APPROVAL_TYPE_CODE,
    PROTOCOL_NUMBER,
    APPLICATION_DATE,
    APPROVAL_DATE,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROPOSAL_ID,
    X_SPECIAL_REVIEW_CODE,
    X_SPECIAL_REVIEW_TYPE,
    X_APPROVAL_TYPE_CODE,
    X_PROTOCOL_NUMBER,
    X_APPLICATION_DATE,
    X_APPROVAL_DATE,
    X_COMMENTS,
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
  X_SPECIAL_REVIEW_CODE in VARCHAR2,
  X_SPECIAL_REVIEW_TYPE in VARCHAR2,
  X_APPROVAL_TYPE_CODE in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_APPLICATION_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_COMMENTS in VARCHAR2
) is
  cursor c1 is select
      SPECIAL_REVIEW_CODE,
      SPECIAL_REVIEW_TYPE,
      APPROVAL_TYPE_CODE,
      PROTOCOL_NUMBER,
      APPLICATION_DATE,
      APPROVAL_DATE,
      COMMENTS
    from IGW_PROP_SPECIAL_REVIEWS
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

  if ( (tlinfo.SPECIAL_REVIEW_CODE = X_SPECIAL_REVIEW_CODE)
      AND ((tlinfo.SPECIAL_REVIEW_TYPE = X_SPECIAL_REVIEW_TYPE)
           OR ((tlinfo.SPECIAL_REVIEW_TYPE is null)
               AND (X_SPECIAL_REVIEW_TYPE is null)))
      AND (tlinfo.APPROVAL_TYPE_CODE = X_APPROVAL_TYPE_CODE)
      AND ((tlinfo.PROTOCOL_NUMBER = X_PROTOCOL_NUMBER)
           OR ((tlinfo.PROTOCOL_NUMBER is null)
               AND (X_PROTOCOL_NUMBER is null)))
      AND ((tlinfo.APPLICATION_DATE = X_APPLICATION_DATE)
           OR ((tlinfo.APPLICATION_DATE is null)
               AND (X_APPLICATION_DATE is null)))
      AND ((tlinfo.APPROVAL_DATE = X_APPROVAL_DATE)
           OR ((tlinfo.APPROVAL_DATE is null)
               AND (X_APPROVAL_DATE is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_SPECIAL_REVIEW_CODE in VARCHAR2,
  X_SPECIAL_REVIEW_TYPE in VARCHAR2,
  X_APPROVAL_TYPE_CODE in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_APPLICATION_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_COMMENTS in VARCHAR2,
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
  update IGW_PROP_SPECIAL_REVIEWS set
    SPECIAL_REVIEW_CODE = X_SPECIAL_REVIEW_CODE,
    SPECIAL_REVIEW_TYPE = X_SPECIAL_REVIEW_TYPE,
    APPROVAL_TYPE_CODE = X_APPROVAL_TYPE_CODE,
    PROTOCOL_NUMBER = X_PROTOCOL_NUMBER,
    APPLICATION_DATE = X_APPLICATION_DATE,
    APPROVAL_DATE = X_APPROVAL_DATE,
    COMMENTS = X_COMMENTS,
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
  X_SPECIAL_REVIEW_CODE in VARCHAR2,
  X_SPECIAL_REVIEW_TYPE in VARCHAR2,
  X_APPROVAL_TYPE_CODE in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_APPLICATION_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_PROP_SPECIAL_REVIEWS
     where PROPOSAL_ID = X_PROPOSAL_ID
     and   SPECIAL_REVIEW_CODE = X_SPECIAL_REVIEW_CODE
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
     X_SPECIAL_REVIEW_CODE,
     X_SPECIAL_REVIEW_TYPE,
     X_APPROVAL_TYPE_CODE,
     X_PROTOCOL_NUMBER,
     X_APPLICATION_DATE,
     X_APPROVAL_DATE,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROPOSAL_ID,
   X_SPECIAL_REVIEW_CODE,
   X_SPECIAL_REVIEW_TYPE,
   X_APPROVAL_TYPE_CODE,
   X_PROTOCOL_NUMBER,
   X_APPLICATION_DATE,
   X_APPROVAL_DATE,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  delete from IGW_PROP_SPECIAL_REVIEWS
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_PROP_SPECIAL_REVIEWS_PKG;

/
