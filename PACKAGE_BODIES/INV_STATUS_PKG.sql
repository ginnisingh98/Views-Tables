--------------------------------------------------------
--  DDL for Package Body INV_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_STATUS_PKG" AS
/* $Header: INVUPMSB.pls 120.17.12010000.1 2008/07/24 01:50:57 appldev ship $ */

-- START SCHANDRU INVERES
function get_from_status_code (   p_org_id in number default null,
                                  p_item_id in number default null,
                                  p_sub_inv in varchar2 default null,
                                  p_locator_id in number default null,
                                  p_lot in varchar2 default null,
                                  p_serial in varchar2 default null) return varchar2
as

PRAGMA AUTONOMOUS_TRANSACTION;

x_status_code varchar2(100) := NULL;

begin


  if (p_sub_inv  IS NOT NULL ) then

     select mms.status_code
     into   x_status_code
     from   mtl_material_statuses mms ,
            MTL_SECONDARY_INVENTORIES msi
     where  mms.status_id = msi.status_id
     and    msi.SECONDARY_INVENTORY_NAME = p_sub_inv
     and    msi.organization_id = p_org_id;

  elsif (p_locator_id  IS NOT NULL ) then

     select mms.status_code
     into   x_status_code
     from   mtl_material_statuses mms ,
            MTL_ITEM_LOCATIONS_KFV mil
     where  mms.status_id = mil.status_id
     and    mil.INVENTORY_LOCATION_ID = p_locator_id
     and    mil.organization_id = p_org_id;

  elsif (p_serial IS NOT NULL) then

     select mms.status_code
     into   x_status_code
     from   mtl_material_statuses mms ,
            MTL_SERIAL_NUMBERS msn
     where  mms.status_id = msn.status_id
     and    msn.SERIAL_NUMBER = p_serial
     and    msn.current_organization_id = p_org_id
     and    msn.inventory_item_id = p_item_id;

  elsIF (p_lot IS NOT NULL) then

     select mms.status_code
     into   x_status_code
     from   mtl_material_statuses mms ,
            MTL_LOT_NUMBERS mln
     where  mms.status_id = mln.status_id
     and    mln.LOT_NUMBER = p_lot
     and    mln.organization_id = p_org_id
     and    mln.inventory_item_id = p_item_id;

   end if;

   return x_status_code;

   exception when others then
      return NULL;

end get_from_status_code ;
--END SCHANDRU INVERES

PROCEDURE mdebug(msg in varchar2)
IS
   l_msg VARCHAR2(5100);
   l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;

   l_msg:=l_ts||'  '||msg;

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'INV_STATUS_PKG',
      p_level => 4);
   END IF;

   --dbms_output.put_line(msg);
--   null;
END;

PROCEDURE check_lot_range_status(
  				p_org_id                IN NUMBER,
			  	p_item_id               IN NUMBER,
                                p_from_lot 		IN VARCHAR2,
				p_to_lot		IN VARCHAR2,
                                x_Status                OUT nocopy VARCHAR2,
				x_Message               OUT nocopy VARCHAR2,
                                x_Status_Code           OUT nocopy VARCHAR2
                                ) IS
    lot_status_id  	NUMBER:=0;
    first_row           BOOLEAN := TRUE;
-- Bug# 1520495
     l_lot_status_enabled       VARCHAR2(1);
     l_default_lot_status_id    NUMBER;
     l_serial_status_enabled    VARCHAR2(1);
     l_default_serial_status_id NUMBER;
     l_return_status		VARCHAR2(1);
     l_msg_data			VARCHAR2(2000);
     l_msg_count		NUMBER;


    cursor lot_cur is
       SELECT status_id
       FROM MTL_LOT_NUMBERS
       WHERE organization_id = p_org_id
         AND inventory_item_id = p_item_id
         AND lot_number BETWEEN p_from_lot AND p_to_lot;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_Status := 'C';
    FOR cc IN lot_cur LOOP
        if first_row then
            lot_status_id := cc.status_id;
            first_row := FALSE;
        elsif cc.status_id <> lot_status_id then
            x_Status := 'E';
            FND_MESSAGE.SET_NAME('WMS','WMS_MULTI_STATUS');
            x_Message := FND_MESSAGE.GET;
            --            x_Message := 'Multiple lot status';
        end if;
    END LOOP;

-- Bug# 1520495
-- From the above fetch, it is possible that lot_status_id is NULL in which
-- case get the default lot status id for the organization item.

    if (x_Status <> 'E') AND (lot_status_id is null) then
	 INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control(
                p_organization_id               => p_org_id
           ,    p_inventory_item_id             => p_item_id
           ,    x_return_status                 => l_return_status
           ,    x_msg_count                     => l_msg_count
           ,    x_msg_data                      => l_msg_data
           ,    x_lot_status_enabled            => l_lot_status_enabled
           ,    x_default_lot_status_id         => l_default_lot_status_id
           ,    x_serial_status_enabled         => l_serial_status_enabled
           ,    x_default_serial_status_id      => l_default_serial_status_id);

	if ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
              x_Status:=  'E';
	      x_Message := l_msg_data;
        end if;
  	if (NVL(l_lot_status_enabled, 'Y')='Y') then
		lot_status_id := l_default_lot_status_id;
	end if;
    end if;
    if x_Status = 'C' then
        SELECT status_code
        INTO  x_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = lot_status_id;
    end if;

END check_lot_range_status;


PROCEDURE check_serial_range_status(
                                p_org_id                IN NUMBER,
                                p_item_id               IN NUMBER,
                                p_from_serial           IN VARCHAR2,
                                p_to_serial             IN VARCHAR2,
                                x_Status                OUT nocopy VARCHAR2,
                                x_Message               OUT nocopy VARCHAR2,
                                x_Status_Code           OUT nocopy VARCHAR2
                                ) IS
    serial_status_id       NUMBER:=0;
    first_row           BOOLEAN := TRUE;
-- Bug# 1520495
     l_lot_status_enabled       VARCHAR2(1);
     l_default_lot_status_id    NUMBER;
     l_serial_status_enabled    VARCHAR2(1);
     l_default_serial_status_id NUMBER;
     l_return_status            VARCHAR2(1);
     l_msg_data                 VARCHAR2(2000);
     l_msg_count                NUMBER;

    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    cursor serial_cur is
       SELECT status_id
       FROM MTL_SERIAL_NUMBERS
       WHERE current_organization_id = p_org_id
         AND inventory_item_id = p_item_id
         --AND current_status in (1, 3, 5)
         AND current_status in (1, 3, 5, 7)
         AND serial_number BETWEEN p_from_serial AND p_to_serial;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_Status := 'C';
    FOR cc IN serial_cur LOOP
        if first_row then
            serial_status_id := cc.status_id;
            first_row := FALSE;
        elsif cc.status_id <> serial_status_id then
            x_Status := 'E';
            FND_MESSAGE.SET_NAME('WMS','WMS_MULTI_STATUS');
            x_Message := FND_MESSAGE.GET;
           -- x_Message := 'Multiple serial status';
        end if;
    END LOOP;

-- Bug# 1520495
-- From the above fetch, it is possible that serial_status_id is NULL in which
-- case get the default serial status id for the organization item.

    if (x_Status <> 'E') AND (serial_status_id is null) then
         INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control(
                p_organization_id               => p_org_id
           ,    p_inventory_item_id             => p_item_id
           ,    x_return_status                 => l_return_status
           ,    x_msg_count                     => l_msg_count
           ,    x_msg_data                      => l_msg_data
           ,    x_lot_status_enabled            => l_lot_status_enabled
           ,    x_default_lot_status_id         => l_default_lot_status_id
           ,    x_serial_status_enabled         => l_serial_status_enabled
           ,    x_default_serial_status_id      => l_default_serial_status_id);

        if ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
              x_Status:=  'E';
              x_Message := l_msg_data;
        end if;
        if (NVL(l_serial_status_enabled, 'Y')='Y') then
                serial_status_id := l_default_serial_status_id;
        end if;
    end if;

    if x_Status = 'C' then
        SELECT status_code
        INTO  x_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = serial_status_id;
    end if;

END check_serial_range_status;

PROCEDURE update_status(
     p_update_method              IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER
   , p_sub_code                   IN VARCHAR2
   , p_sub_status_id              IN NUMBER
   , p_sub_reason_id              IN NUMBER
   , p_locator_id                 IN NUMBER
   , p_loc_status_id              IN NUMBER
   , p_loc_reason_id              IN NUMBER
   , p_from_lot_number            IN VARCHAR2
   , p_to_lot_number              IN VARCHAR2
   , p_lot_status_id              IN NUMBER
   , p_lot_reason_id              IN NUMBER
   , p_from_SN                    IN VARCHAR2
   , p_to_SN                      IN VARCHAR2
   , p_serial_status_id           IN NUMBER
   , p_serial_reason_id           IN NUMBER
   , x_Status                     OUT nocopy VARCHAR2
   , x_Message                    OUT nocopy VARCHAR2
   , p_update_from_mobile         IN VARCHAR2 DEFAULT 'Y'
   -- NSRIVAST, INVCONV , Start
   , p_grade_code                 IN VARCHAR2  DEFAULT NULL
   , p_primary_onhand             IN NUMBER    DEFAULT NULL
   , p_secondary_onhand           IN NUMBER    DEFAULT NULL
   , p_onhand_status_id           IN NUMBER    DEFAULT NULL -- Added for # 6633612
   , p_onhand_reason_id           IN NUMBER    DEFAULT NULL -- Added for # 6633612
   , p_lpn_id                     IN NUMBER    DEFAULT NULL -- Added for # 6633612
  -- NSRIVAST, INVCONV , End
   )
IS
l_status_rec                  INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;
dummy varchar2(100);
-- Added below two variables for LPN status Project
l_serial_controlled NUMBER;
l_serial_status_enabled NUMBER;


TYPE rowidtab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
rowid_list      rowidtab;
-- Added for bug # 6882196
TYPE rowidtab1 IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
rowid_list1      rowidtab1;

cursor cur_lot_number is
	SELECT lot_number
        FROM MTL_LOT_NUMBERS
        WHERE organization_id = p_organization_id
          AND inventory_item_id = p_inventory_item_id
          AND lot_number between p_from_lot_number and p_to_lot_number;

-- Added the cur_onhand for bug 6633612
-- Added the cursor CUR_ONHSERIAL and modified the exists clause in the cusror CUR_ONHAND for bug# 6633612

CURSOR cur_onhand IS
          select moqd.rowid FROM mtl_onhand_quantities_detail moqd
          where inventory_item_id = Nvl(p_inventory_item_id, inventory_item_id)
	  and organization_id = p_organization_id
          and subinventory_code = Nvl(p_sub_code, subinventory_code)
	  and nvl(locator_id, -9999) = nvl(p_locator_id, Nvl(locator_id, -9999))
	  and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)	-- Bug 7012984, Modified the lpn_id condition
	  and nvl(lot_number, '@@@@') BETWEEN nvl (p_from_lot_number, Nvl(lot_number, '@@@@'))
	                                  and nvl (p_to_lot_number, Nvl(lot_number, '@@@@'))
	  and exists
	  (select 1 from mtl_system_items_b msi
	   where moqd.inventory_item_id = msi.inventory_item_id
           AND moqd.organization_id = msi.organization_id
           AND msi.serial_number_control_code in (1,6)
          )
	  FOR UPDATE NOWAIT;

CURSOR cur_onhserial IS
          select msn.rowid FROM mtl_serial_numbers msn
          where inventory_item_id = Nvl(p_inventory_item_id, inventory_item_id)
	  and current_organization_id = p_organization_id
          and current_subinventory_code = Nvl(p_sub_code, current_subinventory_code)
	  and nvl(current_locator_id, -9999) = nvl(p_locator_id, Nvl(current_locator_id, -9999))
	  and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999) -- Bug 7012984, Modified the lpn_id condition
	  and nvl(lot_number, '@@@@') BETWEEN nvl (p_from_lot_number, Nvl(lot_number, '@@@@'))
	                                  and nvl (p_to_lot_number, Nvl(lot_number, '@@@@'))
	  and current_status = 3
	  and exists
	  (select 1 from mtl_system_items_b msi
	   where msn.inventory_item_id = msi.inventory_item_id
           AND msn.current_organization_id = msi.organization_id
           AND nvl(msi.serial_status_enabled, 'N') = 'Y'
          )
          FOR UPDATE NOWAIT;
         --LPN status project

   CURSOR wlc_cur
  IS
          SELECT  *
          FROM    wms_lpn_contents wlc
          WHERE   wlc.parent_lpn_id IN
                  (SELECT lpn_id
                   FROM wms_license_plate_numbers plpn
                   start with lpn_id = p_lpn_id
                   connect by parent_lpn_id = prior lpn_id
                  )
           order by serial_summary_entry
                   FOR UPDATE NOWAIT;

                --LPN status project end



    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_allow_mixed_status NUMBER :=  NVL(FND_PROFILE.VALUE('WMS_ALLOW_MIXED_STATUS'),2);--lpn status project
    l_ret_status varchar2(20) := 'S';
    l_outermost_lpn_id NUMBER;
    l_count NUMBER :=0; -- Bug 6798024
    l_serial_status_control NUMBER := 1;--bug 6952533
BEGIN
   --BEGIN SCHANDRU INVERES
  IF p_update_from_mobile = 'Y' THEN
	  SAVEPOINT   INV_UPDATE_STATUS;
   END IF;
  -- SAVEPOINT   INV_UPDATE_STATUS;
   --END SCHANDRU INVERES
    IF (l_debug = 1) THEN
       mdebug('in update status');
    END IF;
    x_Status := 'C';
    l_status_rec.organization_id := p_organization_id;
    l_status_rec.update_method := INV_MATERIAL_STATUS_PUB.g_update_method_manual;

    IF (l_debug = 1) THEN
       mdebug('p_sub_status_id: '||p_sub_status_id);
    END IF;
    if p_sub_status_id >0 then
        update mtl_secondary_inventories
        set status_id = p_sub_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
        where organization_id = p_organization_id
          and secondary_inventory_name = p_sub_code;

        l_status_rec.zone_code := p_sub_code;
        l_status_rec.status_id := p_sub_status_id;
        l_status_rec.update_reason_id := p_sub_reason_id;
              -- Bug# 1695432 added initial_status_flag and from_mobile_apps_flag
	l_status_rec.initial_status_flag   := 'N';
	l_status_rec.from_mobile_apps_flag := p_update_from_mobile;
        -- update the status history
        INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
    end if;
    IF (l_debug = 1) THEN
       mdebug('p_loc_status_id: '||p_loc_status_id);
    END IF;
    if p_loc_status_id >0 then
         update  mtl_item_locations
         set status_id = p_loc_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
         where organization_id = p_organization_id
          and inventory_location_id = p_locator_id;

        l_status_rec.zone_code := p_sub_code;
        l_status_rec.locator_id := p_locator_id;
        l_status_rec.status_id := p_loc_status_id;
        l_status_rec.update_reason_id := p_loc_reason_id;
              -- Bug# 1695432 added initial_status_flag and from_mobile_apps_flag
	l_status_rec.initial_status_flag   := 'N';
	l_status_rec.from_mobile_apps_flag := p_update_from_mobile;
        -- update the status history
        INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
    end if;
    IF (l_debug = 1) THEN
       mdebug('p_lot_status_id: '||p_lot_status_id);
    END IF;
    if p_lot_status_id >0 then
         update  mtl_lot_numbers
         set status_id = p_lot_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
         where organization_id = p_organization_id
	  and inventory_item_id = p_inventory_item_id
          and lot_number BETWEEN p_from_lot_number and p_to_lot_number ;

         -- update status history
         l_status_rec.inventory_item_id := p_inventory_item_id;
         l_status_rec.status_id := p_lot_status_id;
         l_status_rec.update_reason_id := p_lot_reason_id;
    -- NSRIVAST, INVCONV , Start
         l_status_rec.grade_code       :=  p_grade_code        ;
         l_status_rec.primary_onhand   :=  p_primary_onhand    ;
         l_status_rec.secondary_onhand :=  p_secondary_onhand  ;
    -- NSRIVAST, INVCONV , End
         FOR cc IN cur_lot_number LOOP
             l_status_rec.lot_number := cc.lot_number;
                 -- Bug# 1695432 added initial_status_flag and from_mobile_apps_flag
	     l_status_rec.initial_status_flag   := 'N';
	     l_status_rec.from_mobile_apps_flag := p_update_from_mobile;
             INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
         END LOOP;
     end if;
     IF (l_debug = 1) THEN
        mdebug('p_serial_status_id: '||p_serial_status_id);
     END IF;
     if p_serial_status_id >0 then
         update mtl_serial_numbers
         set status_id = p_serial_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
         where current_organization_id = p_organization_id
          and inventory_item_id = p_inventory_item_id
          and serial_number BETWEEN p_from_SN AND p_to_SN;

        l_status_rec.inventory_item_id := p_inventory_item_id;
        l_status_rec.status_id := p_serial_status_id;
        l_status_rec.update_reason_id := p_serial_reason_id;
        l_status_rec.serial_number := p_from_SN;
        l_status_rec.to_serial_number := p_to_SN;
             -- Bug# 1695432 added initial_status_flag and from_mobile_apps_flag
	l_status_rec.initial_status_flag   := 'N';
	l_status_rec.from_mobile_apps_flag := p_update_from_mobile;
        -- update the status history
        INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);

     end if;

------Start of changes for # 6633612---------------
    IF (l_debug = 1) THEN
        mdebug('p_onhand_status_id: '||p_onhand_status_id);
     END IF;

    if p_onhand_status_id >0 and p_serial_status_id = 0 then
    ---lpn status project start for updating full lpn case
     IF (p_lpn_id IS NOT NULL AND p_inventory_item_id IS NULL)THEN
     --bug 6952533
         SELECT serial_control into l_serial_status_control
         from mtl_material_statuses
         WHERE status_id = p_onhand_status_id;
     --end of bug 6952533
         IF(l_allow_mixed_status = 2)THEN
              SELECT outermost_lpn_id into l_outermost_lpn_id
              FROM wms_license_plate_numbers
              WHERE lpn_id = p_lpn_id ;
              l_ret_status := get_mixed_status(p_lpn_id => p_lpn_id,
                                              p_organization_id =>p_organization_id,
                                              p_outermost_lpn_id => l_outermost_lpn_id,
                                              p_inventory_item_id => NULL,
                                              p_lot_number => NULL,
                                              p_status_id =>p_onhand_status_id);
              IF (l_ret_status = 'M') THEN
                    x_status := 'M';
                    RETURN;
              END IF;
        END IF;
      FOR l_wlc_cur IN wlc_cur LOOP
      l_serial_controlled := 0;
      l_serial_status_enabled := 0;
      mdebug('in mass update of lpn '||p_onhand_status_id);
            IF inv_cache.set_item_rec(p_organization_id, l_wlc_cur.inventory_item_id) THEN
               IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                   l_serial_controlled := 1; -- Item is serial controlled
               END IF;
               IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                  l_serial_status_enabled := 1;
                  --bug 6952533
                   IF(l_serial_status_control = 2)THEN
                       x_status := 'E';
                       FND_MESSAGE.SET_NAME('WMS','WMS_STATUS_UPDATE_FAILED');
                       x_Message := FND_MESSAGE.GET;
                       RETURN;
                   END IF;
                  --end of bug 6952533
               END IF;
            END IF;
      IF(l_serial_controlled = 0)THEN
      UPDATE mtl_onhand_quantities_detail
      SET status_id = p_onhand_status_id
      , last_updated_by = FND_GLOBAL.USER_ID
      , last_update_date = SYSDATE
      , last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE   inventory_item_id = l_wlc_cur.inventory_item_id
      AND     organization_id = p_organization_id
      AND     subinventory_code = Nvl(p_sub_code,'@@@@')
      AND     locator_id    = Nvl(p_locator_id ,-9999)
      AND     Nvl(lot_number,'@@@@') = Nvl(l_wlc_cur.lot_number,'@@@@')
      AND    lpn_id = l_wlc_cur.parent_lpn_id;
      ELSIF(l_serial_status_enabled = 1)THEN
      UPDATE mtl_serial_numbers
      set status_id = p_onhand_status_id
      , last_updated_by = FND_GLOBAL.USER_ID
      , last_update_date = SYSDATE
      , last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE   inventory_item_id = l_wlc_cur.inventory_item_id
      AND     current_organization_id = p_organization_id
      AND     current_subinventory_code = Nvl(p_sub_code,'@@@@')
      AND     current_locator_id    = Nvl(p_locator_id ,-9999)
      AND     lpn_id = l_wlc_cur.parent_lpn_id;
      END IF;
      END LOOP;


    --LPN status project end for full lpn update
    --bug 6952533
       ELSIF (p_lpn_id IS NOT NULL AND p_inventory_item_id IS NOT NULL AND p_from_SN IS NOT NULL AND p_to_SN is not null) THEN
       mdebug('came here for updating serial in range to status '|| p_onhand_status_id);

        IF ( l_allow_mixed_status = 2) THEN
           SELECT outermost_lpn_id into l_outermost_lpn_id
           FROM wms_license_plate_numbers
           WHERE lpn_id = p_lpn_id ;
           l_ret_status := get_mixed_status_serial(p_lpn_id => p_lpn_id,
                             p_organization_id =>p_organization_id ,
                             p_outermost_lpn_id => l_outermost_lpn_id,
                             p_inventory_item_id => p_inventory_item_id,
                             p_lot_number => p_from_lot_number,
                             p_fm_sn => p_from_SN,
                             p_to_sn => p_to_SN,
                             p_status_id => p_onhand_status_id);
           IF (l_ret_status = 'M') THEN
               x_status := 'M';
               RETURN;
           END IF;
         END IF;

      update mtl_serial_numbers
      set status_id = p_onhand_status_id
       , last_updated_by = FND_GLOBAL.USER_ID
      , last_update_date = SYSDATE
      , last_update_login = FND_GLOBAL.LOGIN_ID
      where lpn_id = p_lpn_id
      AND current_organization_id = p_organization_id
      AND inventory_item_id = p_inventory_item_id
      AND serial_number  BETWEEN p_from_SN AND p_to_SN
      AND Nvl(lot_number,'@@@@') = Nvl(p_from_lot_number,'@@@@');

--end of bug 6952533

    ELSE
    --lpn status project
      IF(p_lpn_id IS NOT null)THEN
         IF(l_allow_mixed_status = 2)THEN
            SELECT outermost_lpn_id into l_outermost_lpn_id
            FROM wms_license_plate_numbers
            WHERE lpn_id = p_lpn_id;
              l_ret_status := get_mixed_status(p_lpn_id => p_lpn_id,
                                              p_organization_id =>p_organization_id,
                                              p_outermost_lpn_id => l_outermost_lpn_id,
                                              p_inventory_item_id => p_inventory_item_id,
                                              p_lot_number => p_from_lot_number,
                                              p_status_id =>p_onhand_status_id);
          IF l_ret_status = 'M' THEN
            x_status := 'M';
            RETURN;
          END IF;
        END IF;
       END IF;
--lpn status project

     begin

        OPEN cur_onhand;
        FETCH cur_onhand BULK COLLECT INTO rowid_list ;
         FORALL j in rowid_list.first .. rowid_list.last

         update  mtl_onhand_quantities_detail
         set status_id = p_onhand_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
          where ROWID = rowid_list(j);
	-- Modified the where clause in the above update as it is not required for the bug # 6633612
         COMMIT;
        CLOSE cur_onhand;

        mdebug(' update executed in sql: Onhand');

     -- Added the serial status check for bug # 7113129
         SELECT serial_control into l_serial_status_control
         from mtl_material_statuses
         WHERE status_id = p_onhand_status_id;

        IF (l_serial_status_control = 1) THEN
         OPEN cur_onhserial;
         FETCH cur_onhserial BULK COLLECT INTO rowid_list1 ;
         FORALL j in rowid_list1.first .. rowid_list1.last

         update  mtl_serial_numbers
         set status_id = p_onhand_status_id
            , last_updated_by = FND_GLOBAL.USER_ID
            , last_update_date = SYSDATE
            , last_update_login = FND_GLOBAL.LOGIN_ID
          where ROWID = rowid_list1(j);
         COMMIT;
        CLOSE cur_onhserial;
	END IF;

 -- Removed the Loop in the above two cursors as a part of changes made for the bug # 6882196
        mdebug(' update executed in sql: Onhand Serial');

        /* Bug 6917621 */
        if (p_inventory_item_id is not null) then
          l_status_rec.inventory_item_id := p_inventory_item_id;
        end if;
        l_status_rec.zone_code := p_sub_code;
        l_status_rec.locator_id := p_locator_id;
	l_status_rec.lpn_id := p_lpn_id;
        l_status_rec.status_id := p_onhand_status_id;
        l_status_rec.update_reason_id := p_onhand_reason_id;
	l_status_rec.initial_status_flag   := 'N';
	l_status_rec.from_mobile_apps_flag := p_update_from_mobile;

	FOR cc IN cur_lot_number LOOP -- To update all the lots in a given sub, locator combination..
             l_status_rec.lot_number := cc.lot_number;
	     l_status_rec.initial_status_flag   := 'N';
	     l_status_rec.from_mobile_apps_flag := p_update_from_mobile;
             -- Bug 6798024
             l_count := l_count + 1;
             INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
        END LOOP;

        -- Bug 6798024 : If insert history was not called from inside the lot loop then call it from here
        if (l_count = 0) then
           INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
        end if;
    EXCEPTION WHEN OTHERS THEN
     mdebug(' IN OTHERS EXCEPTION '||sqlerrm);
      FND_MESSAGE.SET_NAME('FND','FLEX-HASH DEADLOCK');
      x_message := FND_MESSAGE.GET;
      x_status :='E';
    IF cur_onhand%ISOPEN THEN
      CLOSE cur_onhand;
    END IF;
-- Added for bug # 6882196
    IF cur_onhserial%ISOPEN THEN
      CLOSE cur_onhserial;
    END IF;
    RETURN;
   END;
   end if; --added for full lpn update case
   end if;

-- End of changes for # 6633612---------------

      -- invoke workflow to process the update
     if p_sub_status_id >0 or p_loc_status_id >0 or
        p_lot_status_id >0 or p_serial_status_id >0 or p_onhand_status_id > 0 then
	IF (l_debug = 1) THEN
   	mdebug('before INV_STATUS_PKG.invoke_reason_wf');
	END IF;

	INV_STATUS_PKG.invoke_reason_wf(
   	  p_update_method
   	, p_organization_id
   	, p_inventory_item_id
   	, p_sub_code
   	, p_sub_status_id
   	, p_sub_reason_id
   	, p_locator_id
   	, p_loc_status_id
   	, p_loc_reason_id
   	, p_from_lot_number
   	, p_to_lot_number
   	, p_lot_status_id
   	, p_lot_reason_id
   	, p_from_SN
   	, p_to_SN
   	, p_serial_status_id
   	, p_serial_reason_id
        , p_onhand_status_id      -- Added for # 6633612
        , p_onhand_reason_id    -- Added for # 6633612
	, p_lpn_id                -- Added for # 6633612
     	, x_Status
   	, x_Message
					);
	IF (l_debug = 1) THEN
   	mdebug('after INV_STATUS_PKG.invoke_reason_wf');
	END IF;
     end if;
     IF (l_debug = 1) THEN
        mdebug('x_status: '||x_status);
     END IF;
     if x_status ='E' then
        --BEGIN SCHANDRU INVERES
	IF p_update_from_mobile = 'Y' THEN
		ROLLBACK TO INV_UPDATE_STATUS;
	 END IF;
	--ROLLBACK TO INV_UPDATE_STATUS;
        --END SCHANDRU INVERES
        FND_MESSAGE.SET_NAME('WMS','WMS_WORKFLOW_CALL_FAIL');
        x_message := FND_MESSAGE.GET;
     end if;
     if p_sub_status_id <=0 and p_loc_status_id <=0 and
        p_lot_status_id <=0 and p_serial_status_id <=0
        and p_onhand_status_id<=0 and x_status ='C' then
         x_Status := 'E';
         FND_MESSAGE.SET_NAME('WMS','WMS_NO_STATUS_CHANGED');
         x_Message := FND_MESSAGE.GET;
         -- x_Message := 'No changes to update';
     else
        --BEGIN SCHANDRU INVERES
	 --commit; --For bug 5487508, the commit will be issued from Java
	 x_Status := 'S';
	--END SCHANDRU INVERES
     end if;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_status := 'E';
   WHEN OTHERS THEN
	--BEGIN SCHANDRU INVERES
	IF p_update_from_mobile = 'Y' THEN
		ROLLBACK TO INV_UPDATE_STATUS;
	 END IF;

       --ROLLBACK TO INV_UPDATE_STATUS;
	--END SCHANDRU INVERES
	x_status := 'E';
       FND_MESSAGE.SET_NAME('WMS','WMS_STATUS_UPDATE_FAILED');
       x_Message := FND_MESSAGE.GET;
END update_status;


PROCEDURE invoke_reason_wf(
     p_update_method              IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER
   , p_sub_code                   IN VARCHAR2
   , p_sub_status_id              IN NUMBER
   , p_sub_reason_id              IN NUMBER
   , p_locator_id                 IN NUMBER
   , p_loc_status_id              IN NUMBER
   , p_loc_reason_id              IN NUMBER
   , p_from_lot_number            IN VARCHAR2
   , p_to_lot_number              IN VARCHAR2
   , p_lot_status_id              IN NUMBER
   , p_lot_reason_id              IN NUMBER
   , p_from_SN                    IN VARCHAR2
   , p_to_SN                      IN VARCHAR2
   , p_serial_status_id           IN NUMBER
   , p_serial_reason_id           IN NUMBER
   , p_onhand_status_id           IN NUMBER    DEFAULT NULL   -- Added for # 6633612
   , p_onhand_reason_id           IN NUMBER    DEFAULT NULL   -- Added for # 6633612
   , p_lpn_id                     IN NUMBER    DEFAULT NULL   -- Added for # 6633612
   , x_Status                     OUT nocopy VARCHAR2
   , x_Message                    OUT nocopy VARCHAR2)
IS
    l_workflow_name         varchar2(250);
    l_reason_name           varchar2(30);
    l_calling_program_name   VARCHAR2(30);
    l_update_method         varchar2(80);
    l_status_code           varchar2(80);
      -- defining output variables
         lX_RETURN_STATUS               VARCHAR2(250);
         lX_MSG_DATA                    VARCHAR2(250);
         lX_MSG_COUNT                   NUMBER;
         lX_ORGANIZATION_ID             NUMBER;
         lX_SUBINVENTORY                VARCHAR2(250);
         lX_SUBINVENTORY_STATUS         VARCHAR2(250);
         lX_LOCATOR                     NUMBER;
         lX_LOCATOR_STATUS              VARCHAR2(250);
	 lX_LPN_ID                      NUMBER;
         lX_LPN_STATUS                  VARCHAR2(250);
	 lX_INVENTORY_ITEM_ID           NUMBER;
	 lX_REVISION                    VARCHAR2(250);
         lX_LOT_NUMBER                  VARCHAR2(250);
         lX_LOT_STATUS                  VARCHAR2(250);
         lX_QUANTITY                    NUMBER;
	 lX_UOM_CODE                    VARCHAR2(250);
         lX_PRIMARY_QUANTITY            NUMBER;
         lX_TRANSACTION_QUANTITY        NUMBER;
         lX_RESERVATION_ID              NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In invoke_reason_wf');
   END IF;
   l_calling_program_name := 'Update Status';
    x_Status := 'C';
    IF (l_debug = 1) THEN
       mdebug('l_calling_orogram_name: '||l_calling_program_name);
    END IF;
    SELECT meaning
    INTO l_update_method
    FROM MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_STATUS_UPDATE_METHOD'
      AND LOOKUP_CODE = p_update_method;

    IF (l_debug = 1) THEN
       mdebug('p_sub_status_id: '||p_sub_status_id);
    END IF;
    if p_sub_status_id >0 then
        SELECT WORKFLOW_NAME
        INTO  l_workflow_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_sub_reason_id;

        SELECT REASON_NAME
        INTO l_reason_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_sub_reason_id;

        SELECT status_code
        INTO l_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = p_sub_status_id;

	IF (l_debug = 1) THEN
   	mdebug('l_workflow_name: '||l_workflow_name);
	END IF;

	  if l_workflow_name is not null then
	   IF (l_debug = 1) THEN
   	   mdebug('Before starting workflow: '||l_reason_name);
	   END IF;
	   wms_workflow_wrappers.wf_start_workflow
	     (
	      P_REASON_ID                     => p_sub_reason_id
	      ,P_REASON_NAME		      => l_reason_name
	      ,P_CALLING_PROGRAM_NAME         => l_calling_program_name
	      ,P_SOURCE_ORGANIZATION_ID       => p_organization_id
	      ,P_SOURCE_SUBINVENTORY          => p_sub_code
	      ,P_SOURCE_SUBINVENTORY_STATUS   => l_status_code
	      ,P_UPDATE_STATUS_METHOD         => l_update_method
	      ,X_RETURN_STATUS		      => lX_RETURN_STATUS
	      ,X_MSG_DATA		      => lX_MSG_DATA
	      ,X_MSG_COUNT		      => lX_MSG_COUNT
	      ,X_ORGANIZATION_ID	      => lX_ORGANIZATION_ID
	      ,X_SUBINVENTORY		      => lX_SUBINVENTORY
	      ,X_SUBINVENTORY_STATUS	      => lX_SUBINVENTORY_STATUS
	      ,X_LOCATOR		      => lX_LOCATOR
	      ,X_LOCATOR_STATUS		      => lX_LOCATOR_STATUS
	      ,X_LPN_ID			      => lX_LPN_ID
	      ,X_LPN_STATUS		      => lX_LPN_STATUS
	      ,X_INVENTORY_ITEM_ID	      => lX_INVENTORY_ITEM_ID
	      ,X_REVISION		      => lX_REVISION
	      ,X_LOT_NUMBER		      => lX_LOT_NUMBER
	      ,X_LOT_STATUS		      => lX_LOT_STATUS
	      ,X_QUANTITY		      => lX_QUANTITY
	      ,X_UOM_CODE		      => lX_UOM_CODE
	      ,X_PRIMARY_QUANTITY	      => lX_PRIMARY_QUANTITY
	      ,X_TRANSACTION_QUANTITY 	      => lX_TRANSACTION_QUANTITY
	      ,X_RESERVATION_ID		      => lX_RESERVATION_ID
	     );

        end if;
     end if;

     if p_loc_status_id >0 then
        SELECT WORKFLOW_NAME
        INTO  l_workflow_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_loc_reason_id;

        SELECT REASON_NAME
        INTO l_reason_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_loc_reason_id;

        SELECT status_code
        INTO l_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = p_loc_status_id;

        if l_workflow_name is not null THEN

            wms_workflow_wrappers.wf_start_workflow
	      (
	       P_REASON_ID                    => p_sub_reason_id
	       ,p_reason_name                 => l_reason_name
	       ,p_calling_program_name        => l_calling_program_name
	       ,P_SOURCE_ORGANIZATION_ID      => p_organization_id
	       ,P_SOURCE_SUBINVENTORY         => p_sub_code
	       ,P_SOURCE_LOCATOR	      => p_locator_id
	       ,P_SOURCE_LOCATOR_STATUS       => l_status_code
	       ,P_UPDATE_STATUS_METHOD        => l_update_method
	       ,X_RETURN_STATUS		      => lX_RETURN_STATUS
	       ,X_MSG_DATA		      => lX_MSG_DATA
	       ,X_MSG_COUNT		      => lX_MSG_COUNT
	       ,X_ORGANIZATION_ID	      => lX_ORGANIZATION_ID
	       ,X_SUBINVENTORY		      => lX_SUBINVENTORY
	       ,X_SUBINVENTORY_STATUS	      => lX_SUBINVENTORY_STATUS
	       ,X_LOCATOR		      => lX_LOCATOR
	       ,X_LOCATOR_STATUS	      => lX_LOCATOR_STATUS
	       ,X_LPN_ID		      => lX_LPN_ID
	       ,X_LPN_STATUS		      => lX_LPN_STATUS
	       ,X_INVENTORY_ITEM_ID	      => lX_INVENTORY_ITEM_ID
	       ,X_REVISION		      => lX_REVISION
	       ,X_LOT_NUMBER		      => lX_LOT_NUMBER
	       ,X_LOT_STATUS		      => lX_LOT_STATUS
	       ,X_QUANTITY		      => lX_QUANTITY
	       ,X_UOM_CODE		      => lX_UOM_CODE
	       ,X_PRIMARY_QUANTITY	      => lX_PRIMARY_QUANTITY
	       ,X_TRANSACTION_QUANTITY 	      => lX_TRANSACTION_QUANTITY
	       ,X_RESERVATION_ID	      => lX_RESERVATION_ID
	      );
        end if;
     end if;

    if p_lot_status_id >0 then
        SELECT WORKFLOW_NAME
        INTO  l_workflow_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_lot_reason_id;

        SELECT REASON_NAME
        INTO l_reason_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_lot_reason_id;

        SELECT status_code
        INTO l_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = p_lot_status_id;

        if l_workflow_name is not null then
	   wms_workflow_wrappers.wf_start_workflow
	     (
	      P_REASON_ID		      => p_sub_reason_id
	      ,P_REASON_NAME                  => l_reason_name
	      ,p_calling_program_name         => l_calling_program_name
	      ,P_SOURCE_ORGANIZATION_ID       => p_organization_id
	      ,P_SOURCE_SUBINVENTORY          => p_sub_code
	      ,P_SOURCE_LOCATOR               => p_locator_id
	      ,P_INVENTORY_ITEM_ID            => p_inventory_item_id
	      ,P_LOT_NUMBER		      => p_from_lot_number
	      ,P_TO_LOT_NUMBER                => p_to_lot_number
	      ,P_LOT_STATUS                   => l_status_code
	      ,P_UPDATE_STATUS_METHOD         => l_update_method
	      ,X_RETURN_STATUS		      => lX_RETURN_STATUS
	      ,X_MSG_DATA		      => lX_MSG_DATA
	      ,X_MSG_COUNT		      => lX_MSG_COUNT
	      ,X_ORGANIZATION_ID	      => lX_ORGANIZATION_ID
	      ,X_SUBINVENTORY		      => lX_SUBINVENTORY
	      ,X_SUBINVENTORY_STATUS	      => lX_SUBINVENTORY_STATUS
	      ,X_LOCATOR		      => lX_LOCATOR
	      ,X_LOCATOR_STATUS		      => lX_LOCATOR_STATUS
	      ,X_LPN_ID			      => lX_LPN_ID
	      ,X_LPN_STATUS		      => lX_LPN_STATUS
	      ,X_INVENTORY_ITEM_ID	      => lX_INVENTORY_ITEM_ID
	      ,X_REVISION		      => lX_REVISION
	      ,X_LOT_NUMBER		      => lX_LOT_NUMBER
	      ,X_LOT_STATUS		      => lX_LOT_STATUS
	      ,X_QUANTITY		      => lX_QUANTITY
	      ,X_UOM_CODE		      => lX_UOM_CODE
	      ,X_PRIMARY_QUANTITY	      => lX_PRIMARY_QUANTITY
	      ,X_TRANSACTION_QUANTITY 	      => lX_TRANSACTION_QUANTITY
	      ,X_RESERVATION_ID		      => lX_RESERVATION_ID
	     );
        end if;
     end if;

     if p_serial_status_id >0 then
        SELECT WORKFLOW_NAME
        INTO  l_workflow_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_serial_reason_id;

        SELECT REASON_NAME
        INTO l_reason_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_serial_reason_id;

        SELECT status_code
        INTO l_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = p_serial_status_id;

        if l_workflow_name is not null then
	   wms_workflow_wrappers.wf_start_workflow
	     (
	      P_REASON_ID                    => p_sub_reason_id
	      ,P_REASON_NAME		     => l_reason_name
	      ,p_calling_program_name        => l_calling_program_name
	      ,P_SOURCE_ORGANIZATION_ID       => p_organization_id
	      ,P_SOURCE_SUBINVENTORY          => p_sub_code
	      ,P_SOURCE_LOCATOR               => p_locator_id
	      ,P_INVENTORY_ITEM_ID            => p_inventory_item_id
	      ,P_LOT_NUMBER                   => p_from_lot_number
	      ,P_TO_LOT_NUMBER                => p_to_lot_number
	      ,P_SERIAL_NUMBER                => p_from_SN
	      ,P_TO_SERIAL_NUMBER             => p_to_SN
	      ,P_SERIAL_NUMBER_STATUS         => l_status_code
	      ,P_UPDATE_STATUS_METHOD         => l_update_method
	      ,X_RETURN_STATUS		      => lX_RETURN_STATUS
	      ,X_MSG_DATA		      => lX_MSG_DATA
	      ,X_MSG_COUNT		      => lX_MSG_COUNT
	      ,X_ORGANIZATION_ID	      => lX_ORGANIZATION_ID
	      ,X_SUBINVENTORY		      => lX_SUBINVENTORY
	      ,X_SUBINVENTORY_STATUS	      => lX_SUBINVENTORY_STATUS
	      ,X_LOCATOR		      => lX_LOCATOR
	      ,X_LOCATOR_STATUS		      => lX_LOCATOR_STATUS
	      ,X_LPN_ID			      => lX_LPN_ID
	      ,X_LPN_STATUS		      => lX_LPN_STATUS
	      ,X_INVENTORY_ITEM_ID	      => lX_INVENTORY_ITEM_ID
	      ,X_REVISION		      => lX_REVISION
	      ,X_LOT_NUMBER		      => lX_LOT_NUMBER
	      ,X_LOT_STATUS		      => lX_LOT_STATUS
	      ,X_QUANTITY		      => lX_QUANTITY
	      ,X_UOM_CODE		      => lX_UOM_CODE
	      ,X_PRIMARY_QUANTITY	      => lX_PRIMARY_QUANTITY
	      ,X_TRANSACTION_QUANTITY 	      => lX_TRANSACTION_QUANTITY
	      ,X_RESERVATION_ID		      => lX_RESERVATION_ID
	     );
        end if;
     end if;

-- Start of changes for # 6633612---------------

if p_onhand_status_id >0 then
        SELECT WORKFLOW_NAME
        INTO  l_workflow_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_onhand_reason_id;

        SELECT REASON_NAME
        INTO l_reason_name
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_ID = p_onhand_reason_id;

        SELECT status_code
        INTO l_status_code
        FROM MTL_MATERIAL_STATUSES_VL
        WHERE status_id = p_onhand_status_id;

	IF (l_debug = 1) THEN
   	mdebug('l_workflow_name: '||l_workflow_name);
	END IF;

	  if l_workflow_name is not null then
	   IF (l_debug = 1) THEN
   	   mdebug('Before starting workflow: '||l_reason_name);
	   END IF;
	   wms_workflow_wrappers.wf_start_workflow
	     (
	      P_REASON_ID                     => p_sub_reason_id
	      ,P_REASON_NAME		      => l_reason_name
	      ,P_CALLING_PROGRAM_NAME         => l_calling_program_name
	      ,P_SOURCE_ORGANIZATION_ID       => p_organization_id
	      ,P_SOURCE_SUBINVENTORY          => p_sub_code
	      ,P_SOURCE_LOCATOR               => p_locator_id
	      ,P_INVENTORY_ITEM_ID            => p_inventory_item_id
	      ,P_LOT_NUMBER		      => p_from_lot_number
	      ,P_TO_LOT_NUMBER                => p_to_lot_number
	      ,P_LPN_ID                       => p_lpn_id           -- Added for # 6633612
	      ,P_ONHAND_STATUS                => l_status_code   -- -- Added for # 6633612 -- Needs to be added in the WMS file.
	      ,P_UPDATE_STATUS_METHOD         => l_update_method
	      ,X_RETURN_STATUS		      => lX_RETURN_STATUS
	      ,X_MSG_DATA		      => lX_MSG_DATA
	      ,X_MSG_COUNT		      => lX_MSG_COUNT
	      ,X_ORGANIZATION_ID	      => lX_ORGANIZATION_ID
	      ,X_SUBINVENTORY		      => lX_SUBINVENTORY
	      ,X_SUBINVENTORY_STATUS	      => lX_SUBINVENTORY_STATUS
	      ,X_LOCATOR		      => lX_LOCATOR
	      ,X_LOCATOR_STATUS		      => lX_LOCATOR_STATUS
	      ,X_LPN_ID			      => lX_LPN_ID
	      ,X_LPN_STATUS		      => lX_LPN_STATUS
	      ,X_INVENTORY_ITEM_ID	      => lX_INVENTORY_ITEM_ID
	      ,X_REVISION		      => lX_REVISION
	      ,X_LOT_NUMBER		      => lX_LOT_NUMBER
	      ,X_LOT_STATUS		      => lX_LOT_STATUS
	      ,X_QUANTITY		      => lX_QUANTITY
	      ,X_UOM_CODE		      => lX_UOM_CODE
	      ,X_PRIMARY_QUANTITY	      => lX_PRIMARY_QUANTITY
	      ,X_TRANSACTION_QUANTITY 	      => lX_TRANSACTION_QUANTITY
	      ,X_RESERVATION_ID		      => lX_RESERVATION_ID
	     );

        end if;
     end if;


-- End of changes for # 6633612---------------

EXCEPTION
   WHEN OTHERS THEN
       x_status := 'E';

END invoke_reason_wf;
--Bug#5577767 Created this procedure to filter sec qty/uom based on tracking_quantity_ind.
PROCEDURE TRACKING_QUANTITY_IND(p_item_id IN NUMBER, p_org_id IN NUMBER ,x_sec_qty IN OUT nocopy NUMBER,x_sec_uom IN OUT nocopy VARCHAR2) IS
p_tracking_qty_ind  VARCHAR2(10);
BEGIN
IF p_item_id IS NULL OR p_org_id IS NULL THEN
   x_sec_qty := NULL;
   x_sec_uom := NULL;
ELSE
   SELECT tracking_quantity_ind INTO p_tracking_qty_ind
   FROM   mtl_system_items_kfv
   WHERE  inventory_item_id = p_item_id
   AND    organization_id = p_org_id;
   IF p_tracking_qty_ind = 'P' THEN
   x_sec_qty := NULL;
   x_sec_uom := NULL;
   END IF;
END IF;
END TRACKING_QUANTITY_IND;

--added for lpn status project to check whether update transaction will result in mixed or not
FUNCTION get_mixed_status(p_lpn_id NUMBER,
                          p_organization_id NUMBER,
                           p_outermost_lpn_id NUMBER,
                           p_inventory_item_id NUMBER,
                           p_lot_number VARCHAR2 := NULL,
                           p_status_id NUMBER)
                           RETURN VARCHAR2 is

CURSOR wlc_cur is
   SELECT  *
             FROM    wms_lpn_contents wlc
             WHERE   wlc.parent_lpn_id IN
                     (SELECT lpn_id
                      FROM wms_license_plate_numbers plpn
                      start with lpn_id = p_outermost_lpn_id
                      connect by parent_lpn_id = prior lpn_id
                     )
             and wlc.parent_lpn_id not in
                     (SELECT lpn_id
                      FROM wms_license_plate_numbers plpn
                      start with lpn_id = p_lpn_id
                      connect by parent_lpn_id = prior lpn_id
                     );
 CURSOR wlc_item_cur is
   SELECT  *
             FROM    wms_lpn_contents wlc
             WHERE   wlc.parent_lpn_id IN
                     (SELECT lpn_id
                      FROM wms_license_plate_numbers plpn
                      start with lpn_id = p_outermost_lpn_id
                      connect by parent_lpn_id = prior lpn_id
                     );
  CURSOR msn_cur(l_inventory_item_id NUMBER,l_lpn_id NUMBER) is
   select status_id
          FROM mtl_serial_numbers
          where inventory_item_id = l_inventory_item_id
          AND   lpn_id = l_lpn_id;

 l_serial_controlled NUMBER := 0;
 l_serial_status_enabled NUMBER := 0;
 l_return_mixed NUMBER := 0;
 l_return_status VARCHAR2(10) := 'S';
 l_default_status_id NUMBER;
BEGIN
   mdebug('In get_mixed_status');
   mdebug('Values Passed--------');
   mdebug('p_lpn_id  '||p_lpn_id);
   mdebug('p_organization_id '||p_organization_id);
   mdebug('p_inventory_item_id '||p_inventory_item_id);
   mdebug('p_lot_number '||p_lot_number);
   mdebug('p_status_id '||p_status_id);
   mdebug('p_outermost_lpn_id '||p_outermost_lpn_id);
   IF(p_inventory_item_id is NULL) THEN
      mdebug('Item id is NULL so have to check for whole LPN case');
      FOR l_wlc_cur in wlc_cur loop
            l_serial_controlled := 0;
            l_serial_status_enabled := 0;
            IF inv_cache.set_item_rec(p_organization_id, l_wlc_cur.inventory_item_id) THEN
                 IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                         l_serial_controlled := 1; -- Item is serial controlled
                 END IF;
                 IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                        l_serial_status_enabled := 1;
                 END IF;
             END IF;
             mdebug('Inventory item id from wlc_cur '||l_wlc_cur.inventory_item_id);
             mdebug('parent_lpn_id from wlc_cur '||l_wlc_cur.parent_lpn_id);
             IF l_serial_controlled = 0 THEN
                mdebug('Item is not serial controlled so checking moqd for status');
                select DISTINCT status_id INTO l_default_status_id
                from mtl_onhand_quantities_detail
                WHERE lpn_id = l_wlc_cur.parent_lpn_id
                AND   inventory_item_id = l_wlc_cur.inventory_item_id
                AND   NVL(lot_number,'@@@@') = NVL(l_wlc_cur.lot_number,'@@@@')
                AND   organization_id = p_organization_id;
                mdebug('status returned from moqd is '||l_default_status_id);
                IF(l_default_status_id <> p_status_id) THEN
                   l_return_mixed := 1;
                END IF;
             ELSIF (l_serial_controlled = 1 AND l_serial_status_enabled = 1) THEN
                  mdebug('Item is serial controlled and serial status is alos enabled so checking MSN for status');
                  FOR l_msn_cur in msn_cur(l_wlc_cur.inventory_item_id,l_wlc_cur.parent_lpn_id) loop
                     mdebug('MSN status is  '||l_msn_cur.status_id);
                     IF(l_msn_cur.status_id <>p_status_id)THEN
                        l_return_mixed := 1;
                        EXIT;
                     END IF;
                 END LOOP;
             END IF;
             IF(l_return_mixed = 1)THEN
               EXIT;
             END IF;
       END LOOP;
       IF (l_return_mixed =1)THEN
           l_return_status :=  'M';
       ELSE
           l_return_status :=  'S';
       END IF;

  ELSE
   mdebug('Item id is not null ...');
   FOR l_wlc_item_cur in wlc_item_cur loop
      l_return_mixed := 0;
      IF(l_wlc_item_cur.inventory_item_id<>p_inventory_item_id
         OR NVL(l_wlc_item_cur.lot_number,'@@@@') <> NVL(p_lot_number,'@@@@')
         OR l_wlc_item_cur.parent_lpn_id <> p_lpn_id
         )THEN
            l_serial_controlled := 0;
            l_serial_status_enabled := 0;
            IF inv_cache.set_item_rec(p_organization_id, l_wlc_item_cur.inventory_item_id) THEN
                 IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                         l_serial_controlled := 1; -- Item is serial controlled
                 END IF;
                 IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                        l_serial_status_enabled := 1;
                 END IF;
             END IF;
             mdebug('Inventory item id from wlc_item_cur  '||l_wlc_item_cur.inventory_item_id);
             mdebug('parent_lpn_id from wlc_item_cur  '||l_wlc_item_cur.parent_lpn_id);
             IF l_serial_controlled = 0 then
                 mdebug('Item is not serial controlled so checking moqd for status');
                select DISTINCT status_id into l_default_status_id
                from mtl_onhand_quantities_detail
                where lpn_id = l_wlc_item_cur.parent_lpn_id
                AND   inventory_item_id = l_wlc_item_cur.inventory_item_id
                AND   NVL(lot_number,'@@@@') = NVL(l_wlc_item_cur.lot_number,'@@@@')
                AND   organization_id = p_organization_id;
                  mdebug('status returned from moqd is '||l_default_status_id);
                IF(l_default_status_id <> p_status_id) THEN
                   l_return_mixed := 1;
                END IF;
             ELSIF(l_serial_controlled = 1 AND l_serial_status_enabled = 1)THEN
                  mdebug('Item is serial controlled and serial status is alos enabled so checking MSN for status');
                  FOR l_msn_cur in msn_cur(l_wlc_item_cur.inventory_item_id,l_wlc_item_cur.parent_lpn_id) loop
                     mdebug('MSN status is '||l_msn_cur.status_id);
                     IF(l_msn_cur.status_id <>p_status_id)THEN
                        l_return_mixed := 1;
                        EXIT;
                     END IF;
                 END LOOP;
             END IF;
           END IF;
             IF(l_return_mixed = 1)THEN
               EXIT;
             END IF;
       END LOOP;
       IF (l_return_mixed =1)THEN
           l_return_status :=  'M';
       ELSE
           l_return_status :=  'S';
       END IF;
   END IF;
 RETURN l_return_status;
 EXCEPTION
  WHEN OTHERS THEN
   mdebug('Exception occured so returning M');
   RETURN 'M';
END get_mixed_status;
--bug 6952533
FUNCTION get_mixed_status_serial(p_lpn_id NUMBER,
                          p_organization_id NUMBER,
                          p_outermost_lpn_id NUMBER,
                          p_inventory_item_id NUMBER,
                          p_lot_number VARCHAR2 := NULL,
                          p_fm_sn VARCHAR2,
                          p_to_sn VARCHAR2,
                          p_status_id NUMBER)
                          RETURN VARCHAR2 is
 CURSOR wlc_item_cur is
   SELECT  *
             FROM    wms_lpn_contents wlc
             WHERE   wlc.parent_lpn_id IN
                     (SELECT lpn_id
                      FROM wms_license_plate_numbers plpn
                      start with lpn_id = p_outermost_lpn_id
                      connect by parent_lpn_id = prior lpn_id
                     );
  CURSOR msn_cur(l_inventory_item_id NUMBER,l_lpn_id NUMBER) is
   select status_id
          FROM mtl_serial_numbers msn
          where inventory_item_id = l_inventory_item_id
          AND   lpn_id = l_lpn_id
          AND nvl(msn.lot_number , '@@@@') = NVL(p_lot_number,'@@@@')
          AND msn.serial_number NOT IN (select serial_number
                                        from mtl_serial_numbers
                                        where serial_number between p_fm_sn AND p_to_sn);

 l_serial_controlled NUMBER := 0;
 l_serial_status_enabled NUMBER := 0;
 l_return_mixed NUMBER := 0;
 l_return_status VARCHAR2(10) := 'S';
 l_default_status_id NUMBER;
BEGIN
  FOR l_wlc_item_cur in wlc_item_cur loop
      l_return_mixed := 0;
      l_serial_controlled := 0;
      l_serial_status_enabled := 0;
      IF inv_cache.set_item_rec(p_organization_id, l_wlc_item_cur.inventory_item_id) THEN
         IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
              l_serial_controlled := 1; -- Item is serial controlled
         END IF;
         IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
              l_serial_status_enabled := 1;
         END IF;
      END IF;
             mdebug('Inventory item id from wlc_item_cur  '||l_wlc_item_cur.inventory_item_id);
             mdebug('parent_lpn_id from wlc_item_cur  '||l_wlc_item_cur.parent_lpn_id);
             IF l_serial_controlled = 0 then
                mdebug('Item is not serial controlled so checking moqd for status');
                select DISTINCT status_id into l_default_status_id
                from mtl_onhand_quantities_detail
                where lpn_id = l_wlc_item_cur.parent_lpn_id
                AND   inventory_item_id = l_wlc_item_cur.inventory_item_id
                AND   NVL(lot_number,'@@@@') = NVL(l_wlc_item_cur.lot_number,'@@@@')
                AND   organization_id = p_organization_id;
                mdebug('status returned from moqd is '||l_default_status_id);
                IF(l_default_status_id <> p_status_id) THEN
                   l_return_mixed := 1;
                END IF;
             ELSIF(l_serial_controlled = 1 AND l_serial_status_enabled = 1)THEN
                  mdebug('Item is serial controlled and serial status is alos enabled so checking MSN for status');
                  FOR l_msn_cur in msn_cur(l_wlc_item_cur.inventory_item_id,l_wlc_item_cur.parent_lpn_id) loop
                     mdebug('MSN status is '||l_msn_cur.status_id);
                     IF(l_msn_cur.status_id <>p_status_id)THEN
                        l_return_mixed := 1;
                        EXIT;
                     END IF;
                 END LOOP;
             END IF;
             IF(l_return_mixed = 1)THEN
                EXIT;
              END IF;
       END LOOP;
        IF l_return_mixed = 1 THEN
           l_return_status := 'M';
        END IF;
     RETURN l_return_status;
    EXCEPTION
     WHEN OTHERS THEN
        mdebug('Exception occured so returning M');
        RETURN 'M';
   END get_mixed_status_serial;
   --end of bug 6952533
END INV_STATUS_PKG;

/
