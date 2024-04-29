--------------------------------------------------------
--  DDL for Package Body AMS_CTD_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTD_USAGES_PKG" as
/* $Header: amslctub.pls 115.1 2003/11/18 13:49:51 mayjain noship $ */
procedure INSERT_ROW (
	X_ROWID IN OUT NOCOPY VARCHAR2,
	X_USAGE_ID IN NUMBER,
	X_ACTION_ID IN NUMBER,
	X_APPLICABLE_FOR IN VARCHAR2,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select ROWID from AMS_CLIK_THRU_USAGES
    where USAGE_ID = X_USAGE_ID
    ;

begin
	insert into AMS_CLIK_THRU_USAGES (
		USAGE_ID,
		ACTION_ID,
		APPLICABLE_FOR,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER
	) values (
		X_USAGE_ID,
		X_ACTION_ID,
		X_APPLICABLE_FOR,
		DECODE(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_LAST_UPDATE_DATE),
		DECODE(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATED_BY),
		DECODE(X_CREATION_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_CREATION_DATE),
		DECODE(X_CREATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_CREATED_BY),
		DECODE(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATE_LOGIN),
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
	X_USAGE_ID IN NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER,
	X_ACTION_ID IN NUMBER,
	X_APPLICABLE_FOR IN VARCHAR2
) is
  cursor c is select
		OBJECT_VERSION_NUMBER,
		ACTION_ID,
		APPLICABLE_FOR,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
    from AMS_CLIK_THRU_USAGES
    where USAGE_ID = X_USAGE_ID
    for update of USAGE_ID nowait;
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
      AND ((recinfo.ACTION_ID = X_ACTION_ID)
           OR ((recinfo.ACTION_ID is null) AND (X_ACTION_ID is null)))
      AND ((recinfo.APPLICABLE_FOR = X_APPLICABLE_FOR)
           OR ((recinfo.APPLICABLE_FOR is null) AND (X_APPLICABLE_FOR is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;



procedure UPDATE_ROW (
	X_USAGE_ID IN NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER,
	X_ACTION_ID IN NUMBER,
	X_APPLICABLE_FOR IN VARCHAR2,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_CLIK_THRU_USAGES set
		OBJECT_VERSION_NUMBER	= X_OBJECT_VERSION_NUMBER
		,ACTION_ID				= X_ACTION_ID
		,APPLICABLE_FOR				= X_APPLICABLE_FOR
		,LAST_UPDATE_DATE			= X_LAST_UPDATE_DATE
		,LAST_UPDATED_BY			= X_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN		= X_LAST_UPDATE_LOGIN
  where USAGE_ID           = X_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
	X_USAGE_ID IN NUMBER
) is
begin

	delete from AMS_CLIK_THRU_USAGES
		where USAGE_ID = X_USAGE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;

end DELETE_ROW;



procedure  LOAD_ROW(
	X_USAGE_ID IN NUMBER,
	X_ACTION_ID IN NUMBER,
	X_APPLICABLE_FOR IN VARCHAR2,
	X_OWNER in  VARCHAR2,
	X_CUSTOM_MODE in VARCHAR2
) is

l_user_id   number := 0;
l_last_updated_by number;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

cursor c_obj_verno is
  select OBJECT_VERSION_NUMBER,
	 last_updated_by
  from   AMS_CLIK_THRU_USAGES
  where  USAGE_ID =  X_USAGE_ID;

cursor c_chk_prd_exists is
  select 'x'
  from   AMS_CLIK_THRU_USAGES
  where  USAGE_ID = X_USAGE_ID;

BEGIN

 if X_OWNER = 'SEED' then
     l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
     l_user_id := 2;
 elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
 end if;

 open c_chk_prd_exists;
 fetch c_chk_prd_exists into l_dummy_char;
 if c_chk_prd_exists%notfound
 then
    close c_chk_prd_exists;

    l_obj_verno := 1;

    AMS_CTD_USAGES_PKG.INSERT_ROW (
			X_ROWID			=>	l_row_id,
			X_USAGE_ID		=>	X_USAGE_ID,
			X_ACTION_ID		=>	X_ACTION_ID,
			X_APPLICABLE_FOR	=>	X_APPLICABLE_FOR,
			X_LAST_UPDATE_DATE	=>	sysdate,
			X_LAST_UPDATED_BY	=>	l_user_id,
			X_CREATION_DATE		=>	sysdate,
			X_CREATED_BY		=>	l_user_id,
			X_LAST_UPDATE_LOGIN	=>	0,
			X_OBJECT_VERSION_NUMBER =>	l_obj_verno
		);
else
   close c_chk_prd_exists;

   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno,l_last_updated_by;
   close c_obj_verno;

   if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

       AMS_CTD_USAGES_PKG.UPDATE_ROW(
		X_USAGE_ID		=>	X_USAGE_ID,
		X_ACTION_ID		=>	X_ACTION_ID,
		X_APPLICABLE_FOR	=>	X_APPLICABLE_FOR,
		X_LAST_UPDATE_DATE      =>	SYSDATE,
		X_LAST_UPDATED_BY       =>	l_user_id,
		X_LAST_UPDATE_LOGIN     =>	0,
		X_OBJECT_VERSION_NUMBER =>	l_obj_verno + 1
         );
    end if;
end if;

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
	X_USAGE_ID IN NUMBER,
	X_OWNER IN VARCHAR2,
	X_CUSTOM_MODE IN VARCHAR2
)
is
l_date DATE;
BEGIN
	select sysdate into l_date from dual;
END TRANSLATE_ROW;


end AMS_CTD_USAGES_PKG;

/
