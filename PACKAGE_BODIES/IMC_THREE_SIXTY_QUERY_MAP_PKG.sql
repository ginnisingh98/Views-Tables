--------------------------------------------------------
--  DDL for Package Body IMC_THREE_SIXTY_QUERY_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_THREE_SIXTY_QUERY_MAP_PKG" as
/* $Header: ARHTSQMB.pls 120.0 2005/05/25 22:00:25 achung noship $ */

procedure INSERT_ROW (
  X_QUERY_ID in out NOCOPY NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_ID in Number,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_POSITION in Number,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) IS

   begin

 insert into IMC_THREE_SIXTY_SSM_QUERY_MAP (
    QUERY_ID,
    APPLICATION_ID,
    SSM_QUERY_ID ,
  	PARAM_SOURCE ,
  	PARAM_POSITION ,
  	CREATION_DATE ,
  	CREATED_BY ,
  	LAST_UPDATE_DATE ,
  	LAST_UPDATED_BY ,
  	LAST_UPDATE_LOGIN ,
  	OBJECT_VERSION_NUMBER
  ) values (
    X_QUERY_ID,
    X_APPLICATION_ID,
    X_SSM_QUERY_ID,
    X_PARAM_SOURCE,
    X_PARAM_POSITION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_QUERY_ID in NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_ID in Number,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_POSITION in Number,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      SSM_QUERY_ID,
      APPLICATION_ID,
      PARAM_SOURCE,
      PARAM_POSITION,
      OBJECT_VERSION_NUMBER
    from IMC_THREE_SIXTY_SSM_QUERY_MAP
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
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.SSM_QUERY_ID = X_SSM_QUERY_ID)
      AND (recinfo.PARAM_SOURCE = X_PARAM_SOURCE)
      AND (recinfo.PARAM_POSITION = X_PARAM_POSITION)
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
  X_QUERY_ID in NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_ID in Number,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_POSITION in Number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

begin
  update IMC_THREE_SIXTY_SSM_QUERY_MAP set
    APPLICATION_ID = X_APPLICATION_ID,
    PARAM_SOURCE = X_PARAM_SOURCE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUERY_ID = X_QUERY_ID
    and NVL(SSM_QUERY_ID,0) = NVL(X_SSM_QUERY_ID,0)
	and PARAM_POSITION = X_PARAM_POSITION;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_ID in NUMBER
  ) is
begin
  delete from IMC_THREE_SIXTY_SSM_QUERY_MAP
  where QUERY_ID = X_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


 procedure LOAD_ROW(
  X_QUERY_ID in out NOCOPY NUMBER,
  X_APPLICATION_ID in Number,
  X_SSM_QUERY_ID in Number,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_POSITION in Number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2) IS

begin
  declare
     user_id		number := 0;
     row_id     	varchar2(64);
     L_QUERY_ID  NUMBER := X_QUERY_ID;
     L_OBJECT_VERSION_NUMBER number;

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     L_OBJECT_VERSION_NUMBER := NVL(X_OBJECT_VERSION_NUMBER, 1) + 1;

     IMC_THREE_SIXTY_QUERY_MAP_PKG.UPDATE_ROW (
     X_QUERY_ID => X_QUERY_ID,
     X_APPLICATION_ID => X_APPLICATION_ID,
     X_SSM_QUERY_ID => X_SSM_QUERY_ID,
     X_PARAM_SOURCE => X_PARAM_SOURCE,
     X_PARAM_POSITION => X_PARAM_POSITION,
     X_LAST_UPDATE_DATE =>  sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER );

    exception
       when NO_DATA_FOUND then

     IMC_THREE_SIXTY_QUERY_MAP_PKG.INSERT_ROW (
     X_QUERY_ID => L_QUERY_ID,
     X_APPLICATION_ID => X_APPLICATION_ID,
     X_SSM_QUERY_ID => X_SSM_QUERY_ID,
     X_PARAM_SOURCE => X_PARAM_SOURCE,
     X_PARAM_POSITION => X_PARAM_POSITION,
     X_CREATION_DATE => sysdate,
     X_CREATED_BY => user_id,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER =>1);

  end ;
end LOAD_ROW;

end IMC_THREE_SIXTY_QUERY_MAP_PKG;

/
