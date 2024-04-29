--------------------------------------------------------
--  DDL for Package Body IEC_P_VDU_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_P_VDU_TYPES_PKG" as
/* $Header: IECVDUTB.pls 115.1 2004/08/02 18:00:42 minwang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID
		from 	IEC_P_VDU_TYPES
    where
					VDU_TYPE_ID = X_VDU_TYPE_ID
			and VDU_TYPE_NAME = X_VDU_TYPE_NAME
			and HARDWARE_LAYER = X_HARDWARE_LAYER;

begin

		insert into IEC_P_VDU_TYPES
					( VDU_TYPE_ID,
						VDU_TYPE_NAME,
						HARDWARE_LAYER,
						CREATED_BY,
						CREATION_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_DATE,
						LAST_UPDATE_LOGIN,
						OBJECT_VERSION_NUMBER )
		values( X_VDU_TYPE_ID,
						X_VDU_TYPE_NAME,
						X_HARDWARE_LAYER,
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
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      VDU_TYPE_NAME,
      HARDWARE_LAYER,
      OBJECT_VERSION_NUMBER
    from IEC_P_VDU_TYPES
    where VDU_TYPE_ID = X_VDU_TYPE_ID
    for update of VDU_TYPE_NAME, HARDWARE_LAYER, OBJECT_VERSION_NUMBER  nowait;
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
  if (    (recinfo.VDU_TYPE_NAME = X_VDU_TYPE_NAME)
      AND (recinfo.HARDWARE_LAYER = X_HARDWARE_LAYER)
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
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

  update IEC_P_VDU_TYPES b
      set b.LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
          b.LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
          b.LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN,
					b.VDU_TYPE_NAME 			= X_VDU_TYPE_NAME,
					b.HARDWARE_LAYER 			= X_HARDWARE_LAYER
      where b.VDU_TYPE_ID = X_VDU_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_VDU_TYPE_ID in NUMBER
) is
begin
  delete from IEC_P_VDU_TYPES
  where VDU_TYPE_ID = X_VDU_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW (X_VDU_TYPE_ID, X_VDU_TYPE_NAME, X_HARDWARE_LAYER, USER_ID, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_VDU_TYPE_ID, X_VDU_TYPE_NAME, X_HARDWARE_LAYER, USER_ID, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

end IEC_P_VDU_TYPES_PKG;

/
