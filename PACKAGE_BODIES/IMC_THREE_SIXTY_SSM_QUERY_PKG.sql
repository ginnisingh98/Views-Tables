--------------------------------------------------------
--  DDL for Package Body IMC_THREE_SIXTY_SSM_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_THREE_SIXTY_SSM_QUERY_PKG" as
/* $Header: ARHTSSQB.pls 120.0 2005/05/25 22:00:28 achung noship $ */

procedure INSERT_ROW (
  X_SSM_QUERY_ID in out NOCOPY NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_STRING  in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) IS
   CURSOR C2 IS SELECT IMC_THREE_SIXTY_SSM_QUERY_S.nextval FROM sys.dual;
   begin
     IF ( X_SSM_QUERY_ID IS NULL) OR (X_SSM_QUERY_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO X_SSM_QUERY_ID;

        if (c2%notfound) then
           close c2;
           raise no_data_found;
        end if;

        CLOSE C2;
    END IF;

   begin
 insert into IMC_THREE_SIXTY_SSM_QUERY (
    SSM_QUERY_ID,
    APPLICATION_ID,
    SSM_QUERY_STRING,
  	CREATION_DATE ,
  	CREATED_BY ,
  	LAST_UPDATE_DATE ,
  	LAST_UPDATED_BY ,
  	LAST_UPDATE_LOGIN ,
  	OBJECT_VERSION_NUMBER
  ) values (
    X_SSM_QUERY_ID,
    X_APPLICATION_ID,
    X_SSM_QUERY_STRING,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );
 end;
end INSERT_ROW;

procedure LOCK_ROW (
  X_SSM_QUERY_ID in NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_STRING  in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      APPLICATION_ID,
      SSM_QUERY_STRING,
      OBJECT_VERSION_NUMBER
    from IMC_THREE_SIXTY_SSM_QUERY
    where SSM_QUERY_ID = X_SSM_QUERY_ID
      for update of SSM_QUERY_ID nowait;
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
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.SSM_QUERY_STRING = X_SSM_QUERY_STRING)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND
          (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
   return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SSM_QUERY_ID in NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_STRING  in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

begin
  update IMC_THREE_SIXTY_SSM_QUERY set
    APPLICATION_ID = X_APPLICATION_ID,
    SSM_QUERY_STRING = X_SSM_QUERY_STRING,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SSM_QUERY_ID = X_SSM_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 end UPDATE_ROW;

procedure DELETE_ROW (
  X_SSM_QUERY_ID in NUMBER
  ) is
begin
  delete from IMC_THREE_SIXTY_SSM_QUERY
  where SSM_QUERY_ID = X_SSM_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


 procedure LOAD_ROW(
  X_SSM_QUERY_ID in out NOCOPY NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_STRING  in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2) IS

begin
  declare
     user_id		number := 0;
     row_id     	varchar2(64);
     L_SSM_QUERY_ID  NUMBER := X_SSM_QUERY_ID;
     L_OBJECT_VERSION_NUMBER number;

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     L_OBJECT_VERSION_NUMBER := NVL(X_OBJECT_VERSION_NUMBER, 1) + 1;

     IMC_THREE_SIXTY_SSM_QUERY_PKG.UPDATE_ROW (
     X_SSM_QUERY_ID => X_SSM_QUERY_ID,
     X_APPLICATION_ID => X_APPLICATION_ID,
     X_SSM_QUERY_STRING => X_SSM_QUERY_STRING,
     X_LAST_UPDATE_DATE =>  sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER );

    exception
       when NO_DATA_FOUND then

     IMC_THREE_SIXTY_SSM_QUERY_PKG.INSERT_ROW (
     X_SSM_QUERY_ID => L_SSM_QUERY_ID,
     X_APPLICATION_ID => X_APPLICATION_ID,
     X_SSM_QUERY_STRING => X_SSM_QUERY_STRING,
     X_CREATION_DATE => sysdate,
     X_CREATED_BY => user_id,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER =>1);

  end ;
end LOAD_ROW;

end IMC_THREE_SIXTY_SSM_QUERY_PKG;

/
