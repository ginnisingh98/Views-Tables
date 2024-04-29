--------------------------------------------------------
--  DDL for Package Body AMS_CPAG_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CPAG_QUERIES_PKG" as
/* $Header: amslcqrb.pls 115.0 2002/06/13 19:01:57 gdeodhar noship $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_QUERY_ID in NUMBER,
  X_QUERY_TEXT in VARCHAR2,
  X_UPLOAD_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID from AMS_CPAG_QUERIES
    where QUERY_ID = X_QUERY_ID
    ;
begin
  insert into AMS_CPAG_QUERIES (
    QUERY_ID,
    QUERY_TEXT,
    UPLOAD_DATE,
    EXPIRATION_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_QUERY_ID,
    X_QUERY_TEXT,
    X_UPLOAD_DATE,
    X_EXPIRATION_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER
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
  X_QUERY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_TEXT in VARCHAR2,
  X_UPLOAD_DATE in DATE,
  X_EXPIRATION_DATE in DATE
) is
  cursor c is select
     OBJECT_VERSION_NUMBER
     ,QUERY_TEXT
     ,UPLOAD_DATE
     ,EXPIRATION_DATE
    from AMS_CPAG_QUERIES
    where QUERY_ID = X_QUERY_ID
    for update of QUERY_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.QUERY_TEXT = X_QUERY_TEXT)
           OR ((recinfo.QUERY_TEXT is null) AND (X_QUERY_TEXT is null)))
      AND ((recinfo.UPLOAD_DATE = X_UPLOAD_DATE)
           OR ((recinfo.UPLOAD_DATE is null) AND (X_UPLOAD_DATE is null)))
      AND ((recinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
           OR ((recinfo.EXPIRATION_DATE is null) AND (X_EXPIRATION_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_QUERY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_TEXT in VARCHAR2,
  X_UPLOAD_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_CPAG_QUERIES set
    OBJECT_VERSION_NUMBER  = X_OBJECT_VERSION_NUMBER,
    QUERY_TEXT             = X_QUERY_TEXT,
    UPLOAD_DATE            = X_UPLOAD_DATE,
    EXPIRATION_DATE        = X_EXPIRATION_DATE,
    LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN
  where QUERY_ID           = X_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_ID in NUMBER
) is
begin
  delete from AMS_CPAG_QUERIES
  where QUERY_ID = X_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure  LOAD_ROW(
  X_QUERY_ID in NUMBER,
  X_QUERY_TEXT in VARCHAR2,
  X_UPLOAD_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_OWNER in  VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

cursor c_obj_verno is
  select object_version_number
  from   AMS_CPAG_QUERIES
  where  query_id =  X_QUERY_ID;

cursor c_chk_qry_exists is
  select 'x'
  from   AMS_CPAG_QUERIES
  where  QUERY_ID = X_QUERY_ID;

BEGIN

 if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_qry_exists;
 fetch c_chk_qry_exists into l_dummy_char;
 if c_chk_qry_exists%notfound
 then
    close c_chk_qry_exists;

    l_obj_verno := 1;

    AMS_CPAG_QUERIES_PKG.INSERT_ROW(
       X_ROWID				         =>    l_row_id,
       X_QUERY_ID				      =>    X_QUERY_ID,
       X_QUERY_TEXT  		      =>    X_QUERY_TEXT,
       X_UPLOAD_DATE             =>    X_UPLOAD_DATE,
       X_EXPIRATION_DATE         =>    X_EXPIRATION_DATE,
       X_CREATION_DATE           =>    SYSDATE,
       X_CREATED_BY              =>    l_user_id,
       X_LAST_UPDATE_DATE        =>    SYSDATE,
       X_LAST_UPDATED_BY         =>    l_user_id,
       X_LAST_UPDATE_LOGIN       =>    0,
       X_OBJECT_VERSION_NUMBER   =>    l_obj_verno
    );
else
   close c_chk_qry_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
   AMS_CPAG_QUERIES_PKG.UPDATE_ROW(
       X_QUERY_ID                =>    X_QUERY_ID,
       X_QUERY_TEXT              =>    X_QUERY_TEXT,
       X_UPLOAD_DATE             =>    X_UPLOAD_DATE,
       X_EXPIRATION_DATE         =>    X_EXPIRATION_DATE,
       X_LAST_UPDATE_DATE        =>    SYSDATE,
       X_LAST_UPDATED_BY         =>    l_user_id,
       X_LAST_UPDATE_LOGIN       =>    0,
       X_OBJECT_VERSION_NUMBER   =>    l_obj_verno + 1
   );
end if;

END LOAD_ROW;

end AMS_CPAG_QUERIES_PKG;

/
