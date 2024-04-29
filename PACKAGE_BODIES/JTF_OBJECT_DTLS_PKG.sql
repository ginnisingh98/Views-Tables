--------------------------------------------------------
--  DDL for Package Body JTF_OBJECT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECT_DTLS_PKG" as
/* $Header: jtfobdtb.pls 120.1 2005/07/02 00:52:13 appldev noship $ */
procedure INSERT_ROW  ( X_ROWID  IN OUT NOCOPY   VARCHAR2,
      X_OBJECT_CODE IN VARCHAR2,
      X_APPLICATION_ID IN NUMBER,
      X_PAGE_TYPE IN VARCHAR2,
      X_PG_REGION_PATH  IN VARCHAR2,
      X_CREATION_DATE IN DATE,
      X_CREATED_BY IN  NUMBER,
      X_LAST_UPDATED_BY IN NUMBER,
      X_LAST_UPDATE_DATE IN DATE,
      X_LAST_UPDATE_LOGIN IN NUMBER
   )is

      l_OBJECT_DTLS_ID   number;
  cursor c is
  select ROWID from jtf_object_pg_dtls
    where object_dtls_id=l_OBJECT_DTLS_ID;

begin

  INSERT INTO  JTF_OBJECT_PG_DTLS
                       (OBJECT_DTLS_ID ,
                        OBJECT_CODE ,
                        APPLICATION_ID ,
                        PAGE_TYPE ,
                        PG_REGION_PATH,
                        CREATION_DATE ,
                        CREATED_BY ,
                        LAST_UPDATED_BY ,
                        LAST_UPDATE_DATE ,
                        LAST_UPDATE_LOGIN,
                        OBJECT_VERSION_NUMBER)
           VALUES      (
                        JTF_OBJECT_PG_DTLS_S.NEXTVAL,
                        X_OBJECT_CODE ,
                        X_APPLICATION_ID ,
                        X_PAGE_TYPE ,
                        X_PG_REGION_PATH,
                        X_CREATION_DATE ,
                        X_CREATED_BY ,
                        X_LAST_UPDATED_BY ,
                        X_LAST_UPDATE_DATE ,
                        X_LAST_UPDATE_LOGIN,
                        1.0 )
                        returning OBJECT_DTLS_ID into l_OBJECT_DTLS_ID;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_OBJECT_DTLS_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is
  cursor c is select
   OBJECT_VERSION_NUMBER
    from jtf_object_pg_dtls
    where object_dtls_id = X_OBJECT_DTLS_ID
    for update of OBJECT_DTLS_ID nowait;
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

procedure UPDATE_ROW  ( X_OBJECT_DTLS_ID  IN NUMBER,
      X_OBJECT_CODE IN VARCHAR2,
      X_APPLICATION_ID IN NUMBER,
      X_PAGE_TYPE IN VARCHAR2,
      X_PG_REGION_PATH  IN VARCHAR2,
      X_LAST_UPDATED_BY IN NUMBER,
      X_LAST_UPDATE_DATE IN DATE,
      X_LAST_UPDATE_LOGIN IN NUMBER,
      X_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER
   ) is

begin

  update JTF_OBJECT_PG_DTLS set
          OBJECT_CODE=X_OBJECT_CODE ,
          APPLICATION_ID=X_APPLICATION_ID ,
          PAGE_TYPE=X_PAGE_TYPE,
          PG_REGION_PATH=X_PG_REGION_PATH,
          LAST_UPDATED_BY=X_LAST_UPDATED_BY,
          LAST_UPDATE_DATE=X_LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN=X_LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER=(X_OBJECT_VERSION_NUMBER+1.0)
   where  OBJECT_DTLS_ID=X_OBJECT_DTLS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_DTLS_ID  IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is

begin

  delete from JTF_OBJECT_PG_DTLS
  where OBJECT_DTLS_ID = X_OBJECT_DTLS_ID
  and   OBJECT_VERSION_NUMBER=X_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;
end ;

/
