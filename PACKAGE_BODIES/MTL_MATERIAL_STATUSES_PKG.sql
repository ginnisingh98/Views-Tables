--------------------------------------------------------
--  DDL for Package Body MTL_MATERIAL_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MATERIAL_STATUSES_PKG" as
/* $Header: INVMSMLB.pls 120.3 2008/02/15 10:22:17 aambulka ship $ */

--Bugfix 2396883. This flag will determine where the update failed.
X_UPDATE_FLAG VARCHAR2(1) := 'N';

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STATUS_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_LOCATOR_CONTROL in NUMBER,
  X_LOT_CONTROL in NUMBER,
  X_SERIAL_CONTROL in NUMBER,
  X_ONHAND_CONTROL in NUMBER,  -- Onhand Material Status Support Bug #6633612
  X_ZONE_CONTROL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ENABLED_FLAG in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LPN_CONTROL in NUMBER,
  --INVCONV KKILLAMS
  X_inventory_atp_code  IN NUMBER,
  X_reservable_type     IN NUMBER,
  X_availability_type   IN NUMBER
  --END INVCONV KKILLAMS
) is
  cursor C is select ROWID from MTL_MATERIAL_STATUSES_B
    where STATUS_ID = X_STATUS_ID
    ;
begin
  insert into MTL_MATERIAL_STATUSES_B (
    ATTRIBUTE15,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    LOCATOR_CONTROL,
    LOT_CONTROL,
    SERIAL_CONTROL,
    ONHAND_CONTROL, -- Onhand Material Status Support Bug #6633612
    STATUS_ID,
    ZONE_CONTROL,
    ATTRIBUTE1,
    ATTRIBUTE14,
    REQUEST_ID,
    ATTRIBUTE_CATEGORY,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LPN_CONTROL,
    --INVCONV KKILLAMS
    INVENTORY_ATP_CODE,
    RESERVABLE_TYPE,
    AVAILABILITY_TYPE
    --END INVCONV KKILLAMS
  ) values (
    X_ATTRIBUTE15,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_LOCATOR_CONTROL,
    X_LOT_CONTROL,
    X_SERIAL_CONTROL,
    X_ONHAND_CONTROL, -- Onhand Material Status Support Bug #6633612
    X_STATUS_ID,
    X_ZONE_CONTROL,
    X_ATTRIBUTE1,
    X_ATTRIBUTE14,
    X_REQUEST_ID,
    X_ATTRIBUTE_CATEGORY,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LPN_CONTROL,
    --INVCONV KKILLAMS
    X_INVENTORY_ATP_CODE,
    X_RESERVABLE_TYPE,
    X_AVAILABILITY_TYPE
    --END INVCONV KKILLAMS
  );

  insert into MTL_MATERIAL_STATUSES_TL (
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    STATUS_CODE,
    DESCRIPTION,
    STATUS_ID,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_STATUS_CODE,
    X_DESCRIPTION,
    X_STATUS_ID,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MTL_MATERIAL_STATUSES_TL T
    where T.STATUS_ID = X_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

-- Bugfix 2396883
procedure INSERT_TL_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STATUS_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
   IS
   cursor C is select ROWID from MTL_MATERIAL_STATUSES_TL
    where STATUS_ID = X_STATUS_ID
     ;
 BEGIN
  insert into MTL_MATERIAL_STATUSES_TL (
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    STATUS_CODE,
    DESCRIPTION,
    STATUS_ID,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_STATUS_CODE,
    X_DESCRIPTION,
    X_STATUS_ID,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MTL_MATERIAL_STATUSES_TL T
    where T.STATUS_ID = X_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_TL_ROW;

procedure LOCK_ROW (
  X_STATUS_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_LOCATOR_CONTROL in NUMBER,
  X_LOT_CONTROL in NUMBER,
  X_SERIAL_CONTROL in NUMBER,
  X_ONHAND_CONTROL in NUMBER,  -- Onhand Material Status Support Bug #6633612
  X_ZONE_CONTROL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ENABLED_FLAG in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LPN_CONTROL in NUMBER,
  --INVCONV KKILLAMS
  X_INVENTORY_ATP_CODE  IN NUMBER,
  X_RESERVABLE_TYPE     IN NUMBER,
  X_AVAILABILITY_TYPE   IN NUMBER
  --END INVCONV KKILLAMS
) is
  cursor c is select
      ATTRIBUTE15,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      LOCATOR_CONTROL,
      LOT_CONTROL,
      SERIAL_CONTROL,
      ONHAND_CONTROL, -- Onhand Material Status Support Bug #6633612
      ZONE_CONTROL,
      ATTRIBUTE1,
      ATTRIBUTE14,
      REQUEST_ID,
      ATTRIBUTE_CATEGORY,
      ENABLED_FLAG,
      LPN_CONTROL,
    --INVCONV KKILLAMS
      INVENTORY_ATP_CODE,
      RESERVABLE_TYPE,
      AVAILABILITY_TYPE
    --END INVCONV KKILLAMS
    from MTL_MATERIAL_STATUSES_B
    where STATUS_ID = X_STATUS_ID
    for update of STATUS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STATUS_CODE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from MTL_MATERIAL_STATUSES_TL
    where STATUS_ID = X_STATUS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND (recinfo.LOCATOR_CONTROL = X_LOCATOR_CONTROL)
      AND (recinfo.LOT_CONTROL = X_LOT_CONTROL)
      AND (recinfo.SERIAL_CONTROL = X_SERIAL_CONTROL)
      AND (recinfo.ONHAND_CONTROL = X_ONHAND_CONTROL) -- Onhand Material Status Support
      AND (recinfo.ZONE_CONTROL = X_ZONE_CONTROL)
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null
)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.LPN_CONTROL = X_LPN_CONTROL)
      --INVCONV KKILLAMS
      AND ((recinfo.INVENTORY_ATP_CODE = X_INVENTORY_ATP_CODE)
           OR ((recinfo.INVENTORY_ATP_CODE is null) AND (X_INVENTORY_ATP_CODE is null)))
      AND ((recinfo.RESERVABLE_TYPE = X_RESERVABLE_TYPE)
           OR ((recinfo.RESERVABLE_TYPE is null) AND (X_RESERVABLE_TYPE is null)))
      AND ((recinfo.AVAILABILITY_TYPE = X_AVAILABILITY_TYPE)
           OR ((recinfo.AVAILABILITY_TYPE is null) AND (X_AVAILABILITY_TYPE is null)))
      --END INVCONV KKILLAMS
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.STATUS_CODE = X_STATUS_CODE)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_STATUS_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_LOCATOR_CONTROL in NUMBER,
  X_LOT_CONTROL in NUMBER,
  X_SERIAL_CONTROL in NUMBER,
  X_ONHAND_CONTROL in NUMBER,  -- Onhand Material Status Support Bug #6633612
  X_ZONE_CONTROL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ENABLED_FLAG in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LPN_CONTROL in NUMBER,
  --INVCONV KKILLAMS
  X_INVENTORY_ATP_CODE  IN NUMBER,
  X_RESERVABLE_TYPE     IN NUMBER,
  X_AVAILABILITY_TYPE   IN NUMBER
  --END INVCONV KKILLAMS
) is
  --INVCONV KKILLAMS
  --Cursor is to verify the atp,reservable and available flags are getting modified or not.
  CURSOR cur_status IS SELECT 1 FROM MTL_MATERIAL_STATUSES_B
                                WHERE STATUS_ID = X_STATUS_ID
                                AND (INVENTORY_ATP_CODE    <> X_INVENTORY_ATP_CODE
                                    OR  RESERVABLE_TYPE    <>   X_RESERVABLE_TYPE
                                    OR  AVAILABILITY_TYPE  <>  X_AVAILABILITY_TYPE );
  l_dummy        NUMBER;
  --END INVCONV KKILLAMS
BEGIN
  --INVCONV KKILLAMS
  OPEN cur_status;
  FETCH cur_status INTO l_dummy;
  --END INVCONV KKILLAMS
  update MTL_MATERIAL_STATUSES_B set
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    LOCATOR_CONTROL = X_LOCATOR_CONTROL,
    LOT_CONTROL = X_LOT_CONTROL,
    SERIAL_CONTROL = X_SERIAL_CONTROL,
    ONHAND_CONTROL = X_ONHAND_CONTROL, -- Onhand Material Status Support Bug #6633612
    ZONE_CONTROL = X_ZONE_CONTROL,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    REQUEST_ID = X_REQUEST_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LPN_CONTROL = X_LPN_CONTROL,
    --INVCONV KKILLAMS
    INVENTORY_ATP_CODE = X_INVENTORY_ATP_CODE,
    RESERVABLE_TYPE    = X_RESERVABLE_TYPE,
    AVAILABILITY_TYPE  = X_AVAILABILITY_TYPE
    --END INVCONV KKILLAMS
  where STATUS_ID = X_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update MTL_MATERIAL_STATUSES_TL set
    STATUS_CODE = X_STATUS_CODE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_ID = X_STATUS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
     -- Setting the flag to indicate that update failed for MTL_MATERIAL_STATUSES_TL Table
     X_UPDATE_FLAG := 'T';
    raise no_data_found;
  end if;
   --INVCONV KKILLAMS
   --Update the Sub Inventory, Lot Number, Serial Number and Location table only if
   --ATP, Availablity type, Reservable flags modified.
   IF cur_status%FOUND THEN
           UPDATE MTL_LOT_NUMBERS SET   INVENTORY_ATP_CODE =X_INVENTORY_ATP_CODE,
                                        AVAILABILITY_TYPE  =X_RESERVABLE_TYPE,
                                        RESERVABLE_TYPE    =X_AVAILABILITY_TYPE
                                  WHERE STATUS_ID = X_STATUS_ID;
           UPDATE MTL_ITEM_LOCATIONS SET   INVENTORY_ATP_CODE =X_INVENTORY_ATP_CODE,
                                           AVAILABILITY_TYPE  =X_RESERVABLE_TYPE,
                                           RESERVABLE_TYPE    =X_AVAILABILITY_TYPE
                                  WHERE STATUS_ID = X_STATUS_ID;
           UPDATE MTL_SECONDARY_INVENTORIES SET   INVENTORY_ATP_CODE =X_INVENTORY_ATP_CODE,
                                                  AVAILABILITY_TYPE  =X_RESERVABLE_TYPE,
                                                  RESERVABLE_TYPE    =X_AVAILABILITY_TYPE
                                  WHERE STATUS_ID = X_STATUS_ID;
   END IF;
   CLOSE cur_status;
   --END INVCONV KKILLAMS
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_ID in NUMBER
) is
begin
  delete from MTL_MATERIAL_STATUSES_TL
  where STATUS_ID = X_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from MTL_MATERIAL_STATUSES_B
  where STATUS_ID = X_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

-- Bugfix 2354241
PROCEDURE Translate_row
   ( X_STATUS_ID   IN   	VARCHAR2,
     X_OWNER       IN		VARCHAR2,
     X_DESCRIPTION IN    	VARCHAR2,
     X_STATUS_CODE IN     VARCHAR2)
IS
BEGIN
    update mtl_material_statuses_tl set
	        status_code = X_STATUS_CODE,
	        description = X_DESCRIPTION,
	        last_update_date = sysdate,
		     last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
           last_update_login = 0,
           source_lang     = userenv('LANG')
	    where status_id = fnd_number.canonical_to_number(x_status_id)
 	    and userenv('LANG') IN (language, source_lang);
END translate_row;


PROCEDURE load_row
   (X_STATUS_ID        IN VARCHAR2,
    X_OWNER            IN	VARCHAR2,
    X_ZONE_CONTROL     IN VARCHAR2,
    X_LOCATOR_CONTROL  IN VARCHAR2,
    X_LOT_CONTROL      IN VARCHAR2,
    X_SERIAL_CONTROL   IN VARCHAR2,
    X_ONHAND_CONTROL   IN VARCHAR2,  -- Onhand Material Status Support Bug #6633612
    X_ENABLED_FLAG     IN VARCHAR2,
    X_ATTRIBUTE_CATEGORY IN	VARCHAR2,
    X_ATTRIBUTE1		IN    VARCHAR2,
    X_ATTRIBUTE2		IN    VARCHAR2,
    X_ATTRIBUTE3		IN    VARCHAR2,
    X_ATTRIBUTE4		IN    VARCHAR2,
    X_ATTRIBUTE5		IN    VARCHAR2,
    X_ATTRIBUTE6		IN    VARCHAR2,
    X_ATTRIBUTE7		IN    VARCHAR2,
    X_ATTRIBUTE8		IN    VARCHAR2,
    X_ATTRIBUTE9		IN    VARCHAR2,
    X_ATTRIBUTE10	   IN    VARCHAR2,
    X_ATTRIBUTE11	   IN 	VARCHAR2,
    X_ATTRIBUTE12	   IN 	VARCHAR2,
    X_ATTRIBUTE13	   IN 	VARCHAR2,
    X_ATTRIBUTE14	   IN 	VARCHAR2,
    X_ATTRIBUTE15	   IN 	VARCHAR2,
    X_DESCRIPTION    IN   	VARCHAR2,
    X_STATUS_CODE    IN    VARCHAR2,
    X_LPN_CONTROL    IN    NUMBER,
    --INVCONV KKILLAMS
    X_INVENTORY_ATP_CODE  IN NUMBER,
    X_RESERVABLE_TYPE     IN NUMBER,
    X_AVAILABILITY_TYPE   IN NUMBER
    --END INVCONV KKILLAMS
    ) IS
BEGIN
   DECLARE
      l_status_id       NUMBER;
      l_user_id         NUMBER := 0;
      l_zone_control    NUMBER;
      l_locator_control NUMBER;
      l_lot_control     NUMBER;
      l_serial_control  NUMBER;
      l_onhand_control  NUMBER; --Onhand Material Status Control Bug #6633612
      l_lpn_control     NUMBER;
      l_enabled_flag    NUMBER;
      l_row_id          VARCHAR2(64);
      l_sysdate         DATE;
      ---INVCONV kkillams
      l_inventory_atp_code  NUMBER;
      l_reservable_type     NUMBER;
      l_availability_type   NUMBER;
      ---END INVCONV kkillams
   BEGIN
      IF (x_owner = 'SEED') THEN
         l_user_id := 1;
      END IF;

      SELECT SYSDATE INTO l_sysdate FROM dual;
      l_status_id       := fnd_number.canonical_to_number(x_status_id);
      l_zone_control    := fnd_number.canonical_to_number(x_zone_control);
      l_locator_control := fnd_number.canonical_to_number(x_locator_control);
      l_lot_control     := fnd_number.canonical_to_number(x_lot_control);
      l_serial_control  := fnd_number.canonical_to_number(x_serial_control);
      l_enabled_flag    := fnd_number.canonical_to_number(x_enabled_flag);
      l_lpn_control     := fnd_number.canonical_to_number(x_lpn_control);
      --INVCONV kkillams
      l_inventory_atp_code  := fnd_number.canonical_to_number(x_inventory_atp_code);
      l_reservable_type     := fnd_number.canonical_to_number(x_reservable_type);
      l_availability_type   := fnd_number.canonical_to_number(x_availability_type);

      l_onhand_control      := fnd_number.canonical_to_number(x_onhand_control); --Onhand Material Status Control Bug #6633612
      --END INVCONV kkillams

      MTL_MATERIAL_STATUSES_PKG.update_row
       (
         X_STATUS_ID    => l_status_id,
         X_ATTRIBUTE15  => X_ATTRIBUTE15,
         X_ATTRIBUTE2   => X_ATTRIBUTE2,
         X_ATTRIBUTE3   => X_ATTRIBUTE3,
         X_ATTRIBUTE4   => X_ATTRIBUTE4,
         X_ATTRIBUTE5   => X_ATTRIBUTE5,
         X_ATTRIBUTE6   => X_ATTRIBUTE6,
         X_ATTRIBUTE7   => X_ATTRIBUTE7,
         X_ATTRIBUTE8   => X_ATTRIBUTE8,
         X_ATTRIBUTE9   => X_ATTRIBUTE9,
         X_ATTRIBUTE10  => X_ATTRIBUTE10,
         X_ATTRIBUTE11  => X_ATTRIBUTE11,
         X_ATTRIBUTE12  => X_ATTRIBUTE12,
         X_ATTRIBUTE13  => X_ATTRIBUTE13,
         X_LOCATOR_CONTROL => l_locator_control,
         X_LOT_CONTROL     => l_lot_control,
         X_SERIAL_CONTROL  => l_serial_control,
	 X_ONHAND_CONTROL  => l_onhand_control, -- Onhand Material Status Support Bug #6633612
         X_ZONE_CONTROL    => l_zone_control,
         X_ATTRIBUTE1         => X_ATTRIBUTE1,
         X_ATTRIBUTE14        => X_ATTRIBUTE14,
         X_REQUEST_ID         => NULL,
         X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE15,
         X_ENABLED_FLAG       => l_enabled_flag,
         X_STATUS_CODE        => x_status_code,
         X_DESCRIPTION        => x_description,
         X_LAST_UPDATE_DATE   => l_sysdate,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN  => 0,
         X_LPN_CONTROL        => l_lpn_control,
         --INVCONV kkillams
         X_INVENTORY_ATP_CODE  => l_inventory_atp_code,
         X_RESERVABLE_TYPE     => l_reservable_type,
         X_AVAILABILITY_TYPE   => l_availability_type
         --END INVCONV kkillams
         );
   EXCEPTION
      WHEN no_data_found THEN
        -- Bugfix 2396883.
        --  If the update failed for MTL_MATERIAL_STATUSES_TL Table then insert recoreds into that table alone
        --  else insert records into both the tables.
        IF X_UPDATE_FLAG = 'T' THEN

          MTL_MATERIAL_STATUSES_PKG.insert_tl_row
          (
           X_ROWID              => l_row_id,
           X_STATUS_ID          => l_status_id,
           X_STATUS_CODE        => x_status_code,
           X_DESCRIPTION        => x_description,
           X_CREATION_DATE      => l_sysdate,
           X_CREATED_BY         => l_user_id,
           X_LAST_UPDATE_DATE   => l_sysdate,
           X_LAST_UPDATED_BY    => l_user_id,
           X_LAST_UPDATE_LOGIN  => 0
          );

       ELSE

        MTL_MATERIAL_STATUSES_PKG.insert_row
        (
         X_ROWID        => l_row_id,
         X_STATUS_ID    => l_status_id,
         X_ATTRIBUTE15  => X_ATTRIBUTE15,
         X_ATTRIBUTE2   => X_ATTRIBUTE2,
         X_ATTRIBUTE3   => X_ATTRIBUTE3,
         X_ATTRIBUTE4   => X_ATTRIBUTE4,
         X_ATTRIBUTE5   => X_ATTRIBUTE5,
         X_ATTRIBUTE6   => X_ATTRIBUTE6,
         X_ATTRIBUTE7   => X_ATTRIBUTE7,
         X_ATTRIBUTE8   => X_ATTRIBUTE8,
         X_ATTRIBUTE9   => X_ATTRIBUTE9,
         X_ATTRIBUTE10  => X_ATTRIBUTE10,
         X_ATTRIBUTE11  => X_ATTRIBUTE11,
         X_ATTRIBUTE12  => X_ATTRIBUTE12,
         X_ATTRIBUTE13  => X_ATTRIBUTE13,
         X_LOCATOR_CONTROL => l_locator_control,
         X_LOT_CONTROL     => l_lot_control,
         X_SERIAL_CONTROL  => l_serial_control,
 	 X_ONHAND_CONTROL  => l_onhand_control, -- Onhand Material Status Support Bug #6633612
         X_ZONE_CONTROL    => l_zone_control,
         X_ATTRIBUTE1         => X_ATTRIBUTE1,
         X_ATTRIBUTE14        => X_ATTRIBUTE14,
         X_REQUEST_ID         => NULL,
         X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE15,
         X_ENABLED_FLAG       => l_enabled_flag,
         X_STATUS_CODE        => x_status_code,
         X_DESCRIPTION        => x_description,
         X_CREATION_DATE      => l_sysdate,
         X_CREATED_BY         => l_user_id,
         X_LAST_UPDATE_DATE   => l_sysdate,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN  => 0,
         X_LPN_CONTROL        => l_lpn_control,
         --INVCONV kkillams
         X_INVENTORY_ATP_CODE  => l_inventory_atp_code,
         X_RESERVABLE_TYPE     => l_reservable_type,
         X_AVAILABILITY_TYPE   => l_availability_type
         --END INVCONV kkillams
        );

       END IF;

   END;

END load_row;

procedure ADD_LANGUAGE
is
begin
  delete from MTL_MATERIAL_STATUSES_TL T
  where not exists
    (select NULL
    from MTL_MATERIAL_STATUSES_B B
    where B.STATUS_ID = T.STATUS_ID
    );

  update MTL_MATERIAL_STATUSES_TL T set (
      STATUS_CODE,
      DESCRIPTION
    ) = (select
      B.STATUS_CODE,
      B.DESCRIPTION
    from MTL_MATERIAL_STATUSES_TL B
    where B.STATUS_ID = T.STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_ID,
      SUBT.LANGUAGE
    from MTL_MATERIAL_STATUSES_TL SUBB, MTL_MATERIAL_STATUSES_TL SUBT
    where SUBB.STATUS_ID = SUBT.STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STATUS_CODE <> SUBT.STATUS_CODE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into MTL_MATERIAL_STATUSES_TL (
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    STATUS_CODE,
    DESCRIPTION,
    STATUS_ID,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.STATUS_CODE,
    B.DESCRIPTION,
    B.STATUS_ID,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MTL_MATERIAL_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MTL_MATERIAL_STATUSES_TL T
    where T.STATUS_ID = B.STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end MTL_MATERIAL_STATUSES_PKG;

/
