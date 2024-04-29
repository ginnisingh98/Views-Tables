--------------------------------------------------------
--  DDL for Package Body IEC_G_REGION_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_REGION_MAPPINGS_PKG" as
/* $Header: IECRGNMB.pls 120.1 2005/07/19 13:07:05 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID
		from 	IEC_G_REGION_MAPPINGS
    where
					TERRITORY_CODE 	= X_TERRITORY_CODE
			and PHONE_AREA_CODE = X_PHONE_AREA_CODE
			and REGION_ID 			= X_REGION_ID;

begin

     insert into IEC_G_REGION_MAPPINGS
                 (TERRITORY_CODE,
                  PHONE_AREA_CODE,
                  REGION_ID,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
								  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER)
     values
                 (X_TERRITORY_CODE,
                  X_PHONE_AREA_CODE,
                  X_REGION_ID,
								  X_CREATED_BY,
								  X_CREATION_DATE,
								  X_LAST_UPDATED_BY,
								  X_LAST_UPDATE_DATE,
								  X_LAST_UPDATE_LOGIN,
								  X_OBJECT_VERSION_NUMBER);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      REGION_ID,
      OBJECT_VERSION_NUMBER
    from IEC_G_REGION_MAPPINGS
	  where TERRITORY_CODE 	= X_TERRITORY_CODE
	  and   PHONE_AREA_CODE = X_PHONE_AREA_CODE
    for update of REGION_ID, OBJECT_VERSION_NUMBER  nowait;
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
  if (    (recinfo.REGION_ID = X_REGION_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

	  update IEC_G_REGION_MAPPINGS
	  set REGION_ID 				= X_REGION_ID,
	      LAST_UPDATED_BY 	= X_LAST_UPDATED_BY,
	      LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE,
	      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where TERRITORY_CODE 	= X_TERRITORY_CODE
	  and   PHONE_AREA_CODE = X_PHONE_AREA_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2
) is
begin
  delete from IEC_G_REGION_MAPPINGS
	  where TERRITORY_CODE 	= X_TERRITORY_CODE
	  and   PHONE_AREA_CODE = X_PHONE_AREA_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
  X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  USER_ID := fnd_load_util.owner_id(x_owner);

  UPDATE_ROW (X_TERRITORY_CODE, X_PHONE_AREA_CODE, X_REGION_ID, USER_ID, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_TERRITORY_CODE, X_PHONE_AREA_CODE, X_REGION_ID, USER_ID, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
  X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
) is
begin
    if(X_upload_mode = 'NLS') then
      IEC_G_REGION_MAPPINGS_PKG.TRANSLATE_ROW(
					X_TERRITORY_CODE,
		 			X_PHONE_AREA_CODE,
					X_REGION_ID,
					X_OWNER);
    else
      IEC_G_REGION_MAPPINGS_PKG.LOAD_ROW(
					X_TERRITORY_CODE,
		 			X_PHONE_AREA_CODE,
					X_REGION_ID,
					X_OWNER);
		end if;
end LOAD_SEED_ROW;

procedure TRANSLATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
  X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
) is
begin


   update IEC_G_REGION_MAPPINGS
   set REGION_ID 				 = X_REGION_ID,
       LAST_UPDATE_DATE  = SYSDATE,
       LAST_UPDATED_BY 	 = fnd_load_util.owner_id(X_OWNER),
       LAST_UPDATE_LOGIN = 0
   where TERRITORY_CODE  = X_TERRITORY_CODE
   and   PHONE_AREA_CODE = X_PHONE_AREA_CODE
   and   userenv('LANG') = ( select LANGUAGE_CODE from FND_LANGUAGES
                             where INSTALLED_FLAG = 'B' );

end TRANSLATE_ROW;

end IEC_G_REGION_MAPPINGS_PKG;

/
