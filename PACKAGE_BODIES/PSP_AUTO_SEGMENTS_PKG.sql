--------------------------------------------------------
--  DDL for Package Body PSP_AUTO_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_AUTO_SEGMENTS_PKG" as
--$Header: PSPAUSGB.pls 115.9 2002/11/19 10:55:50 ddubey psp2376993.sql $
 /* $HEADER$ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SEGMENT_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from PSP_AUTO_SEGMENTS
      where SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID and
            BUSINESS_GROUP_ID =X_BUSINESS_GROUP_ID;
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
  insert into PSP_AUTO_SEGMENTS (
    SET_OF_BOOKS_ID,
  BUSINESS_GROUP_ID ,
    SEGMENT_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SET_OF_BOOKS_ID,
    X_BUSINESS_GROUP_ID ,
    X_SEGMENT_NUMBER,
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
  X_SET_OF_BOOKS_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SEGMENT_NUMBER in NUMBER
) is
  cursor c1 is select
      SEGMENT_NUMBER
    from PSP_AUTO_SEGMENTS
    where SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
    and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
    for update of SET_OF_BOOKS_ID, BUSINESS_GROUP_ID nowait;
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

      if ( ((tlinfo.SEGMENT_NUMBER = X_SEGMENT_NUMBER)
           OR ((tlinfo.SEGMENT_NUMBER is null)
               AND (X_SEGMENT_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SET_OF_BOOKS_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SEGMENT_NUMBER in NUMBER,
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
  update PSP_AUTO_SEGMENTS set
    SEGMENT_NUMBER = X_SEGMENT_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
   ANd BUSINESS_GROUP_ID =X_BUSINESS_GROUP_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SEGMENT_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from PSP_AUTO_SEGMENTS
     where SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
     and BUSINESS_GROUP_ID=X_BUSINESS_GROUP_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SET_OF_BOOKS_ID,
     X_BUSINESS_GROUP_ID,
     X_SEGMENT_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_SET_OF_BOOKS_ID,
   X_BUSINESS_GROUP_ID,
   X_SEGMENT_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_SET_OF_BOOKS_ID in NUMBER,
  X_BUSINESS_GROUP_ID IN NUMBER
) is
begin
  delete from PSP_AUTO_SEGMENTS
  where SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
  and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_AUTO_SEGMENTS_PKG;

/
