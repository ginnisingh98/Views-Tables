--------------------------------------------------------
--  DDL for Package Body JTF_OBJECT_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECT_PARAM_PKG" as
/* $Header: jtfobpab.pls 120.1 2005/07/02 00:52:26 appldev noship $ */
procedure INSERT_ROW  ( X_ROWID  IN OUT NOCOPY   VARCHAR2,
    X_OBJECT_DTLS_ID IN NUMBER,
    X_SOURCE_PARAM IN VARCHAR2,
    X_DEST_PARAM IN VARCHAR2,
    X_CREATION_DATE IN DATE,
    X_CREATED_BY IN NUMBER,
    X_LAST_UPDATED_BY IN NUMBER,
    X_LAST_UPDATE_DATE IN DATE,
    X_LAST_UPDATE_LOGIN IN NUMBER)
   is

   l_PARAMETER_ID jtf_object_pg_params.parameter_id%type;
  cursor c is
  select ROWID from jtf_object_pg_params
    where parameter_id=l_PARAMETER_ID;


begin

INSERT INTO  JTF_OBJECT_PG_PARAMS
      (  PARAMETER_ID ,
         OBJECT_DTLS_ID ,
         SOURCE_PARAM ,
         DEST_PARAM ,
         CREATION_DATE,
         CREATED_BY ,
         LAST_UPDATED_BY ,
         LAST_UPDATE_DATE ,
         LAST_UPDATE_LOGIN ,
         OBJECT_VERSION_NUMBER )
         VALUES
         (
         JTF_OBJECT_PG_PARAMS_S.NEXTVAL,
         X_OBJECT_DTLS_ID ,
         X_SOURCE_PARAM ,
         X_DEST_PARAM ,
         X_CREATION_DATE,
         X_CREATED_BY ,
         X_LAST_UPDATED_BY ,
         X_LAST_UPDATE_DATE ,
         X_LAST_UPDATE_LOGIN ,
         1.0 )
         returning PARAMETER_ID into l_PARAMETER_ID;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PARAMETER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from jtf_object_pg_params
    where parameter_id= X_PARAMETER_ID
    for update of PARAMETER_ID nowait;
   recinfo c%rowtype;

begin
	open c;
	fetch c into recinfo;
	if (c%notfound) then
		close c;
		fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
		fnd_msg_pub.add;
		app_exception.raise_exception;
	 end if;
	 close c;

  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
    fnd_msg_pub.add;
    app_exception.raise_exception;
  end if;


end LOCK_ROW;

procedure UPDATE_ROW  ( X_PARAMETER_ID  IN NUMBER,
        X_SOURCE_PARAM IN VARCHAR2,
        X_DEST_PARAM IN VARCHAR2,
        X_LAST_UPDATED_BY IN NUMBER,
        X_LAST_UPDATE_DATE IN DATE,
        X_LAST_UPDATE_LOGIN IN NUMBER,
        X_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER
   ) is

   l_object_version_number jtf_object_pg_params.object_version_number%type;
begin



UPDATE  JTF_OBJECT_PG_PARAMS A
SET
   A.SOURCE_PARAM = X_SOURCE_PARAM
 , A.DEST_PARAM = X_DEST_PARAM
 , A.LAST_UPDATED_BY = X_LAST_UPDATED_BY
 , A.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
 , A.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
 , A.OBJECT_VERSION_NUMBER =(X_OBJECT_VERSION_NUMBER + 1.0)

  where  PARAMETER_ID=X_PARAMETER_ID;


  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_ID  IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is

begin


  delete from JTF_OBJECT_PG_PARAMS
  where PARAMETER_ID = X_PARAMETER_ID
  and   object_version_number=X_OBJECT_VERSION_NUMBER ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ;


/
