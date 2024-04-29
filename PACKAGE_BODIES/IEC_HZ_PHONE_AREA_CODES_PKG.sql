--------------------------------------------------------
--  DDL for Package Body IEC_HZ_PHONE_AREA_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_HZ_PHONE_AREA_CODES_PKG" as
/* $Header: IECHZACB.pls 120.1 2005/07/20 06:26:09 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID
		from 	HZ_PHONE_AREA_CODES
    where
					TERRITORY_CODE 	= X_TERRITORY_CODE
			and AREA_CODE 			= X_AREA_CODE;

begin

	   insert into HZ_PHONE_AREA_CODES
	               (TERRITORY_CODE,
	                PHONE_COUNTRY_CODE,
	                AREA_CODE,
	                DESCRIPTION,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
								  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER)
	   values
	               (X_TERRITORY_CODE,
	                X_PHONE_COUNTRY_CODE,
	                X_AREA_CODE,
	                X_DESCRIPTION,
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
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      PHONE_COUNTRY_CODE,
      DESCRIPTION,
      OBJECT_VERSION_NUMBER
    from HZ_PHONE_AREA_CODES
    where TERRITORY_CODE = X_TERRITORY_CODE
    and   AREA_CODE = X_AREA_CODE
    for update of PHONE_COUNTRY_CODE, DESCRIPTION, OBJECT_VERSION_NUMBER  nowait;
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
  if (    (recinfo.PHONE_COUNTRY_CODE 	 = X_PHONE_COUNTRY_CODE)
      AND (recinfo.DESCRIPTION 					 = X_DESCRIPTION)
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
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

    update HZ_PHONE_AREA_CODES
    set PHONE_COUNTRY_CODE	= X_PHONE_COUNTRY_CODE,
        DESCRIPTION 				= X_DESCRIPTION,
        LAST_UPDATE_DATE 		= X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY 		= X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN
    where TERRITORY_CODE 		= X_TERRITORY_CODE
    and   AREA_CODE 				= X_AREA_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2
) is
begin
  delete from HZ_PHONE_AREA_CODES
    where TERRITORY_CODE = X_TERRITORY_CODE
    and   AREA_CODE = X_AREA_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  USER_ID := fnd_load_util.owner_id(x_owner);

  UPDATE_ROW (X_TERRITORY_CODE, X_PHONE_COUNTRY_CODE, X_AREA_CODE, X_DESCRIPTION, USER_ID, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_TERRITORY_CODE, X_PHONE_COUNTRY_CODE, X_AREA_CODE, X_DESCRIPTION, USER_ID, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

    if (X_upload_mode = 'NLS') then
    	IEC_HZ_PHONE_AREA_CODES_PKG.TRANSLATE_ROW(
						X_TERRITORY_CODE,
						X_PHONE_COUNTRY_CODE,
						X_AREA_CODE,
						X_DESCRIPTION,
						X_OWNER);
    else
    	IEC_HZ_PHONE_AREA_CODES_PKG.LOAD_ROW(
						X_TERRITORY_CODE,
						X_PHONE_COUNTRY_CODE,
						X_AREA_CODE,
						X_DESCRIPTION,
						X_OWNER);
    end if;
end LOAD_SEED_ROW;

procedure TRANSLATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_COUNTRY_CODE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

	 update HZ_PHONE_AREA_CODES
	 set PHONE_COUNTRY_CODE = X_PHONE_COUNTRY_CODE,
	     DESCRIPTION 				= X_DESCRIPTION,
	     LAST_UPDATE_DATE 	= SYSDATE,
	     LAST_UPDATED_BY    = fnd_load_util.owner_id(X_OWNER),
	     LAST_UPDATE_LOGIN 	= 0
	 where TERRITORY_CODE 	= X_TERRITORY_CODE
	 and   AREA_CODE 				= X_AREA_CODE
	 and   userenv('LANG')  = ( select LANGUAGE_CODE from FND_LANGUAGES
	                            where INSTALLED_FLAG = 'B' );

end TRANSLATE_ROW;


end IEC_HZ_PHONE_AREA_CODES_PKG;

/
