--------------------------------------------------------
--  DDL for Package Body AR_BPA_AREA_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_AREA_ITEMS_PKG" as
/* $Header: ARBPAIB.pls 120.1 2004/12/03 01:44:55 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_AREA_ITEMS
    where AREA_ITEM_ID = X_AREA_ITEM_ID
    ;
begin
  insert into AR_BPA_AREA_ITEMS (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    SECONDARY_APP_ID,
    ITEM_ID,
    DISPLAY_SEQUENCE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    PARENT_AREA_CODE,
    TEMPLATE_ID,
    DISPLAY_LEVEL,
    AREA_ITEM_ID,
    DATA_SOURCE_ID,
    FLEXFIELD_ITEM_FLAG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_SECONDARY_APP_ID,
    X_ITEM_ID,
    X_DISPLAY_SEQUENCE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_PARENT_AREA_CODE,
    X_TEMPLATE_ID,
    X_DISPLAY_LEVEL,
    X_AREA_ITEM_ID,
    X_DATA_SOURCE_ID,
    X_FLEXFIELD_ITEM_FLAG
  FROM DUAL;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2
) is
  cursor c1 is select
      SECONDARY_APP_ID,
      ITEM_ID,
      DISPLAY_SEQUENCE,
      TEMPLATE_ID,
      DISPLAY_LEVEL,
      PARENT_AREA_CODE,
      DATA_SOURCE_ID,
      FLEXFIELD_ITEM_FLAG
    from AR_BPA_AREA_ITEMS
    where AREA_ITEM_ID = X_AREA_ITEM_ID
    for update of AREA_ITEM_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.PARENT_AREA_CODE = X_PARENT_AREA_CODE)
          AND (tlinfo.SECONDARY_APP_ID = X_SECONDARY_APP_ID)
          AND (tlinfo.ITEM_ID = X_ITEM_ID)
          AND (tlinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
          AND (tlinfo.TEMPLATE_ID = X_TEMPLATE_ID)
          AND (tlinfo.DISPLAY_LEVEL = X_DISPLAY_LEVEL)
          AND (tlinfo.DATA_SOURCE_ID = X_DATA_SOURCE_ID)
          AND (tlinfo.FLEXFIELD_ITEM_FLAG = X_FLEXFIELD_ITEM_FLAG)
      ) then
        null;
      else
	    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	    app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_AREA_ITEMS set
    SECONDARY_APP_ID = X_SECONDARY_APP_ID,
    ITEM_ID = X_ITEM_ID,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    TEMPLATE_ID = X_TEMPLATE_ID,
    DISPLAY_LEVEL = X_DISPLAY_LEVEL,
    PARENT_AREA_CODE = X_PARENT_AREA_CODE,
    DATA_SOURCE_ID = X_DATA_SOURCE_ID,
    FLEXFIELD_ITEM_FLAG = X_FLEXFIELD_ITEM_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AREA_ITEM_ID = X_AREA_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_AREA_ITEM_ID in NUMBER
) is
begin
  delete from AR_BPA_AREA_ITEMS
  where AREA_ITEM_ID = X_AREA_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
        X_AREA_ITEM_ID                   IN NUMBER,
        X_DISPLAY_LEVEL                  IN VARCHAR2,
        X_DISPLAY_SEQUENCE               IN NUMBER,
        X_ITEM_ID                        IN NUMBER,
        X_PARENT_AREA_CODE               IN VARCHAR2,
        X_SECONDARY_APP_ID               IN NUMBER,
        X_TEMPLATE_ID                    IN NUMBER,
        X_DATA_SOURCE_ID                 IN NUMBER,
        X_FLEXFIELD_ITEM_FLAG            IN VARCHAR2,
        X_OWNER                 IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_BPA_AREA_ITEMS_PKG.UPDATE_ROW (
	  X_AREA_ITEM_ID  => X_AREA_ITEM_ID,
	  X_SECONDARY_APP_ID => X_SECONDARY_APP_ID,
	  X_ITEM_ID => X_ITEM_ID,
	  X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
	  X_TEMPLATE_ID => X_TEMPLATE_ID,
	  X_DISPLAY_LEVEL => X_DISPLAY_LEVEL,
	  X_PARENT_AREA_CODE => X_PARENT_AREA_CODE,
	  X_DATA_SOURCE_ID => X_DATA_SOURCE_ID,
	  X_FLEXFIELD_ITEM_FLAG => X_FLEXFIELD_ITEM_FLAG,
        X_LAST_UPDATE_DATE 	=> sysdate,
         X_LAST_UPDATED_BY 	=> user_id,
         X_LAST_UPDATE_LOGIN 	=> 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_AREA_ITEMS_PKG.INSERT_ROW (
                 X_ROWID => row_id,
		  X_AREA_ITEM_ID  => X_AREA_ITEM_ID,
		  X_SECONDARY_APP_ID => X_SECONDARY_APP_ID,
		  X_ITEM_ID => X_ITEM_ID,
		  X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
		  X_TEMPLATE_ID => X_TEMPLATE_ID,
		  X_DISPLAY_LEVEL => X_DISPLAY_LEVEL,
		  X_PARENT_AREA_CODE => X_PARENT_AREA_CODE,
		  X_DATA_SOURCE_ID => X_DATA_SOURCE_ID,
		  X_FLEXFIELD_ITEM_FLAG => X_FLEXFIELD_ITEM_FLAG,
			X_CREATION_DATE 	=> sysdate,
                X_CREATED_BY 		=> user_id,
                X_LAST_UPDATE_DATE 	=> sysdate,
                X_LAST_UPDATED_BY 	=> user_id,
                X_LAST_UPDATE_LOGIN 	=> 0);
    end;
end LOAD_ROW;

end AR_BPA_AREA_ITEMS_PKG;

/
