--------------------------------------------------------
--  DDL for Package Body INV_MATERIAL_STATUS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MATERIAL_STATUS_GRP" as
/* $Header: INVMSGRB.pls 120.34.12010000.24 2012/01/03 10:20:34 sadibhat ship $ */



-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'INV_MATERIAL_STATUS_GRP';

g_status_id     NUMBER;
g_transaction_type_id   NUMBER;
g_is_allowed   VARCHAR2(1);

g_organization_id                  NUMBER;
g_inventory_item_id                NUMBER;
g_lot_status_enabled               VARCHAR2(1);
g_default_lot_status_id            NUMBER;
g_serial_status_enabled            VARCHAR2(1);
g_default_serial_status_id         NUMBER;

g_isa_trx_type_id                  NUMBER;
g_isa_trx_status_enabled           VARCHAR2(1);
g_isa_sub_status_id                NUMBER;
g_isa_loc_status_id                NUMBER;
g_isa_organization_id              NUMBER;
g_isa_sub_code                     VARCHAR2(10);
g_isa_locator_id                   NUMBER;
--Bug 3804629, changed the datatype from number to varchar2
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
g_isa_lot_number                   VARCHAR2(80);
g_isa_lot_number_status_id         NUMBER;

--Bug #5367711
--Cache the variables for old item, item trackable and freeze flag
g_old_item_id                NUMBER;
g_freeze_flag                csi_install_parameters.freeze_flag%TYPE;
g_item_trackable             mtl_system_items.comms_nl_trackable_flag%TYPE;
g_transaction_action_id      NUMBER;
g_transaction_source_type_id NUMBER;

-- Onhand Material Status Support
g_debug                      NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
g_sub_code                   VARCHAR2(10);
g_locator_control            NUMBER;
-- Onhand Material Status Support


/*LPN Status Project*/
FUNCTION is_status_applicable_lpns
                    (p_wms_installed              IN VARCHAR2,
                           p_trx_status_enabled        IN NUMBER,
                           p_trx_type_id                    IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled    IN VARCHAR2,
                           p_organization_id              IN NUMBER,
                           p_inventory_item_id         IN NUMBER,
                           p_sub_code                        IN VARCHAR2,
                           p_locator_id                       IN NUMBER,
                           p_lot_number                     IN VARCHAR2,
                           p_serial_number                 IN VARCHAR2,
                           p_object_type                     IN VARCHAR2,
                           p_fromlpn_id              IN NUMBER,
                           p_xfer_lpn_id                     IN NUMBER,
                           p_xfer_sub_code              IN VARCHAR2,
                           p_xfer_locator_id            IN NUMBER,
                           p_xfer_org_id                IN NUMBER)
RETURN NUMBER IS

l_allow_mixed_status number :=  NVL(FND_PROFILE.VALUE('WMS_ALLOW_MIXED_STATUS'),2);
l_allow_status  VARCHAR2(1):='Y';
l_allow_transaction VARCHAR2(1):='Y';
l_serial_controlled number := 0;
l_serial_status_enabled number := 0;
l_counter number := 0;
l_count number := 0;
l_xfer_locator_id number := -1;
l_xfer_sub_code VARCHAR2(50) := NULL;
l_xfer_org_id  number := -1;
l_xferlpn_context number := 5;
l_lpn_context number := 5; --bug 6918618
l_return_status_id number := -99;  --bug 6918618
temp_status_id number := NULL; --7007389
c_api_name                varchar2(30) := 'is_status_applicable';

l_validate number := 0 ;

  CURSOR c_lpn_item
  IS
          SELECT  *
          FROM    wms_lpn_contents wlc
          WHERE   wlc.parent_lpn_id IN
                  (SELECT lpn_id
                   FROM wms_license_plate_numbers plpn
                   start with lpn_id = p_fromlpn_id
                   connect by parent_lpn_id = prior lpn_id
                  );


BEGIN
inv_trx_util_pub.TRACE('Entered is_status_applicable  ', 'Material Status', 9);
inv_trx_util_pub.TRACE('p_wms_installed'||p_wms_installed||'p_trx_status_enabled'
                       ||p_trx_status_enabled||'p_trx_type_id'||p_trx_type_id
                       ||'p_lot_status_enabled'||p_lot_status_enabled||'p_serial_status_enabled'
                       ||p_serial_status_enabled, 'Material Status', 9);
inv_trx_util_pub.TRACE('p_organization_id'||p_organization_id||'p_inventory_item_id'
                       ||p_inventory_item_id||'p_sub_code'||p_sub_code||'p_locator_id'
                       ||p_locator_id||'p_lot_number'||p_lot_number||'p_serial_number'
                       ||p_serial_number||'p_object_type'||p_object_type,'Material Status', 9);
inv_trx_util_pub.TRACE('p_fromlpn_id'||p_fromlpn_id||'p_xfer_lpn_id'||p_xfer_lpn_id||'p_xfer_sub_code'||p_xfer_sub_code||'p_xfer_locator_id'||p_xfer_locator_id||'p_xfer_org_id'||p_xfer_org_id, 'Material Status', 9);

 IF p_xfer_lpn_id IS NOT NULL THEN
       BEGIN
        inv_trx_util_pub.TRACE('mixed status: .. Xfer LPN is New LPN or not?? .. 1','Material Status', 9);

        l_xfer_locator_id :=  p_xfer_locator_id;
        l_xfer_sub_code   :=  p_xfer_sub_code;
        l_xfer_org_id     :=  p_xfer_org_id;

                SELECT lpn_context
                into l_xferlpn_context
                from wms_license_plate_numbers where lpn_id = p_xfer_lpn_id
                AND EXISTS(select 1 from mtl_onhand_quantities_detail moqd
                where moqd.organization_id = p_xfer_org_id
                AND moqd.lpn_id IN
                 (
                        SELECT  lpn_id
                        FROM    wms_license_plate_numbers
                        WHERE   outermost_lpn_id =
                        (SELECT outermost_lpn_id
                        FROM    wms_license_plate_numbers
                        WHERE   lpn_id = p_xfer_lpn_id
                        )
                ));
                inv_trx_util_pub.TRACE('mixed status: .. 1.1.1 - l_xferlpn_context'||l_xferlpn_context,'Material Status', 9);

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_xferlpn_context := 5;
                   inv_trx_util_pub.TRACE('mixed status: .. New LPN[Ctrl+G] .. 2','Material Status', 9);
        END;



        IF (l_xfer_locator_id is NULL or l_xfer_locator_id <= 0) AND l_xferlpn_context <> 5 THEN
                BEGIN
                 SELECT subinventory_code,locator_id,organization_id
                 into l_xfer_sub_code,l_xfer_locator_id,l_xfer_org_id
                 from wms_license_plate_numbers where lpn_id = p_xfer_lpn_id;
                EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   l_xferlpn_context := 5;
                   inv_trx_util_pub.TRACE('mixed status: .. 2.1','Material Status', 9);
                END;
         END IF;

        inv_trx_util_pub.TRACE('l_xferlpn_context'||l_xferlpn_context,'Material Status', 9);
   END IF;      --transfer lpnid not null
   inv_trx_util_pub.TRACE('l_xfer_locator_id:'||l_xfer_locator_id||'l_xfer_sub_code'||l_xfer_sub_code||'l_xfer_org_id'||l_xfer_org_id,'Material Status', 9);
--for bug 6918618
 IF  p_fromlpn_id is NOT NULL and p_inventory_item_id IS NOT NULL AND (p_trx_type_id = 42 OR p_trx_type_id = 41) AND l_allow_mixed_status = 2 THEN --7173146
                 BEGIN
                         select lpn_context into l_lpn_context
                         from wms_license_plate_numbers
                         where lpn_id  = p_fromlpn_id;

                         inv_trx_util_pub.TRACE('l_lpn_context::'||l_lpn_context,'Material Status', 9);
                 EXCEPTION
                         when no_data_found then
                         inv_trx_util_pub.TRACE('l_lpn_context'||l_lpn_context,'Material Status', 9);
                           l_lpn_context := 5;
                 END;

          IF l_lpn_context = 1 THEN

               inv_trx_util_pub.TRACE('l_lpn_context'||l_lpn_context,'Material Status', 9);
                  l_return_status_id := get_default_status --calling function to get the MOQD status
                                  (p_organization_id   => p_organization_id,
                                  p_inventory_item_id => p_inventory_item_id,
                                  p_sub_code =>p_sub_code,
                                  p_loc_id => p_locator_id,
                                  p_lot_number => p_lot_number,
                                  p_lpn_id => p_fromlpn_id,
                                  p_transaction_action_id=> NULL,
                                  p_src_status_id => NULL);
               inv_trx_util_pub.TRACE('l_return_status_id'||l_return_status_id,'Material Status', 9);


             IF l_return_status_id <> -1 THEN
             BEGIN
                SELECT  'Y'
                INTO l_allow_status FROM DUAL
                where l_return_status_id IN
                (SELECT moqddst.status_id
                 FROM    mtl_onhand_quantities_detail moqddst
                 WHERE   moqddst.organization_id = p_organization_id
                 AND moqddst.lpn_id         IN
                 (
                  SELECT  lpn_id
                  FROM    wms_license_plate_numbers
                  WHERE   outermost_lpn_id =
                        (SELECT outermost_lpn_id
                        FROM    wms_license_plate_numbers
                        WHERE   lpn_id = p_fromlpn_id
                        )
                ));
                 inv_trx_util_pub.TRACE('l_allow_status::::'||l_allow_status,'Material Status', 9);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_allow_status := 'N';
                  inv_trx_util_pub.TRACE('l_allow_status::::(exception block)'||l_allow_status,'Material Status', 9);
              END;
              END IF; --l_return_status_id <> -1
          END IF; -- lpn context
 END IF; --6918618

IF p_xfer_lpn_id IS NOT NULL AND l_xferlpn_context <> 5 AND l_allow_mixed_status = 2 THEN

   IF  p_inventory_item_id IS NOT NULL THEN
     BEGIN
       inv_trx_util_pub.TRACE('mixed status: inv id not null .. 10','Material Status', 9);

         l_allow_status := 'N';
        --Added for Bug 7007389
        BEGIN
        SELECT moqdsrc.status_id
        INTO temp_status_id
        FROM    mtl_onhand_quantities_detail moqdsrc
        WHERE   moqdsrc.organization_id       = p_organization_id
            AND moqdsrc.inventory_item_id     = p_inventory_item_id
            AND moqdsrc.subinventory_code     = p_sub_code
            AND moqdsrc.locator_id            = p_locator_id
            AND NVL(moqdsrc.lot_number,'@@@') = NVL(p_lot_number,'@@@')
            AND NVL(moqdsrc.lpn_id, 0)    = NVL(p_fromlpn_id, 0)
            AND ROWNUM = 1;

           inv_trx_util_pub.TRACE('mixed status: before excep block SerialCheck.. 10.1','Material Status', 9);

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                inv_trx_util_pub.TRACE('mixed status: in excep block  SerialCheck.. 10.2','Material Status', 9);

        END;

        IF temp_status_id is NULL THEN
           inv_trx_util_pub.TRACE('mixed status: temp_status_id is null .. Serial 10.3','Material Status', 9);
           l_allow_status := 'Y';
        END IF;
        /*End of changes for Bug # 7007389 */
        /*Following condition has also added as part of Bug # 7007389 */
        IF temp_status_id is NOT NULL THEN
           inv_trx_util_pub.TRACE('mixed status: inside if .. 10.4','Material Status', 9);
        SELECT  'Y'
        INTO l_allow_status
        FROM    mtl_onhand_quantities_detail moqdsrc
        WHERE   moqdsrc.organization_id       = p_organization_id
            AND moqdsrc.inventory_item_id     = p_inventory_item_id
            AND moqdsrc.subinventory_code     = p_sub_code
            AND moqdsrc.locator_id            = p_locator_id
            AND NVL(moqdsrc.lot_number,'@@@') = NVL(p_lot_number,'@@@')
            AND NVL(moqdsrc.lpn_id, 0)    = NVL(p_fromlpn_id, 0)
            AND ROWNUM = 1
            AND moqdsrc.status_id IN
        (
        SELECT moqddst.status_id
        FROM    mtl_onhand_quantities_detail moqddst
        WHERE   moqddst.organization_id = l_xfer_org_id
            AND moqddst.lpn_id         IN
                (
                SELECT  lpn_id
                FROM    wms_license_plate_numbers
                WHERE   outermost_lpn_id =
                        (SELECT outermost_lpn_id
                        FROM    wms_license_plate_numbers
                        WHERE   lpn_id = p_xfer_lpn_id
                        )
                )
        );
        END IF; --added as part of 7007389
        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                          l_allow_status := 'N';
                                          inv_trx_util_pub.TRACE('mixed status: came here .. 20 l_allow_status'||l_allow_status,'Material Status', 9);
        END ;

   ELSIF  p_inventory_item_id IS NULL AND p_fromlpn_id is NOT NULL THEN

       BEGIN
          inv_trx_util_pub.TRACE('mixed status: inv id is null and from LPN ID not null .. 30','Material Status', 9);

        SELECT 'N'
        INTO l_allow_status
        FROM dual
        WHERE EXISTS (
       (SELECT   DISTINCT moqdsrc.status_id
        FROM    mtl_onhand_quantities_detail moqdsrc
        WHERE   moqdsrc.organization_id       = p_organization_id
            AND moqdsrc.subinventory_code     = p_sub_code
            AND moqdsrc.locator_id            = p_locator_id
           -- AND NVL(moqdsrc.lot_number,'@@@') = NVL(p_lot_number,'@@@')
            AND moqdsrc.lpn_id               IN
                (SELECT lpn_id
                FROM    wms_license_plate_numbers plpn
                START WITH lpn_id = p_fromlpn_id CONNECT BY parent_lpn_id = prior lpn_id
                AND plpn.organization_id = p_organization_id
                )
	UNION  --bug 10427776
        SELECT   DISTINCT msn.status_id
        FROM mtl_serial_numbers msn
        where msn.current_subinventory_code = p_sub_code
	        and msn.current_locator_id = p_locator_id
       	 	and msn.current_organization_id=p_organization_id
        	and msn.lpn_id = p_fromlpn_id
        )
        MINUS
        (
        SELECT DISTINCT moqddst.status_id
        FROM    mtl_onhand_quantities_detail moqddst
        WHERE   moqddst.organization_id = l_xfer_org_id
            AND moqddst.lpn_id         IN
                (
                SELECT  lpn_id
                FROM    wms_license_plate_numbers
                WHERE   outermost_lpn_id =
                        (SELECT outermost_lpn_id
                        FROM    wms_license_plate_numbers
                        WHERE   lpn_id = p_xfer_lpn_id
                        )
                )
	UNION  --bug 10427776
        SELECT   DISTINCT msn.status_id
        FROM mtl_serial_numbers msn
        where msn.current_subinventory_code = p_sub_code
                and msn.current_locator_id = p_locator_id
                and msn.current_organization_id=l_xfer_org_id
                and msn.lpn_id = p_xfer_lpn_id
        ));
        EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                          l_allow_status := 'Y';
                                         inv_trx_util_pub.TRACE('mixed status: ..40 l_allow_status'||l_allow_status,'Material Status', 9);

        END ;

   END IF; --p_inventory_item_id

END IF; --p_xfer_lpn_id condition

--moved the code out of p_xfer_lpn_id condition bcoz another check added for 6918618
        IF l_allow_status = 'N' THEN
                 l_validate := 1;
                 inv_trx_util_pub.TRACE('mixed status: .. 50 returning l_validate'||l_validate,'Material Status', 9);
                 return l_validate;
        END IF;

IF p_trx_type_id IS NOT NULL AND l_allow_status = 'Y' THEN --Checking for allow/disallow  of source
IF  p_inventory_item_id IS NOT NULL THEN

        BEGIN
           inv_trx_util_pub.TRACE('txn allowed or not: .. 60  verifying at source, inv id not null','Material Status', 9);
                    --First check whether the source material ALLOWS/DISALLOWS the transaction whether from LPN or LOOSE.


       inv_trx_util_pub.TRACE('txn allowed or not: ..60.1 verifying at source','Material Status', 9);
        SELECT 'N'
        INTO    l_allow_transaction
        FROM    dual
        WHERE   EXISTS
        (SELECT 1
        FROM    mtl_onhand_quantities_detail moqd,
                mtl_status_transaction_control mtc
        WHERE   moqd.organization_id       = p_organization_id
            AND moqd.inventory_item_id     = p_inventory_item_id
            AND moqd.subinventory_code     = p_sub_code
            AND nvl(moqd.locator_id,-999)   = nvl(p_locator_id,-999) --6974887
            AND NVL(moqd.lot_number,'@@@') = NVL(p_lot_number,'@@@')
            AND Nvl(moqd.lpn_id,0)       = Nvl(p_fromlpn_id,0)
            AND moqd.status_id          = mtc.status_id
            AND mtc.transaction_type_id = p_trx_type_id
            AND mtc.is_allowed          = 2
            --AND ROWNUM = 1
        ) ;

      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_allow_transaction := 'Y' ;
                inv_trx_util_pub.TRACE('txn allowed or not: .. 70 Reached here for source:'||l_allow_transaction,'Material Status', 9);

      END ;


      --destination check if into another LPN else part for xfer into as LOOSE
      IF l_allow_transaction = 'Y' THEN
      IF p_xfer_lpn_id IS NOT NULL  AND l_xferlpn_context <> 5 THEN
       inv_trx_util_pub.TRACE('txn allowed or not: .. 80 verifying at dest, xfer lpn id not null','Material Status', 9);
           BEGIN
            inv_trx_util_pub.TRACE('txn allowed or not: .. 80.1 verifying at dest','Material Status', 9);
        SELECT 'N'
        INTO    l_allow_transaction
        FROM    dual
        WHERE   EXISTS
                (SELECT 1
                FROM    mtl_onhand_quantities_detail moqd,
                        mtl_status_transaction_control mtc
                WHERE   moqd.organization_id   = l_xfer_org_id
                    AND moqd.inventory_item_id = p_inventory_item_id
                    AND NVL(moqd.lot_number,'@@@') = NVL(p_lot_number,'@@@')
                    AND moqd.lpn_id  = p_xfer_lpn_id
                    AND moqd.status_id          = mtc.status_id
                    AND mtc.transaction_type_id = p_trx_type_id
                    AND mtc.is_allowed          = 2
                ) ;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_allow_transaction := 'Y' ;
                    inv_trx_util_pub.TRACE('txn allowed or not: .. 90 Reached here l_allow_transaction:'||l_allow_transaction,'Material Status', 9);

            END ;


         ELSIF p_xfer_lpn_id is NULL THEN --   transfer lpn id is NULL so making the qty as loose at destination

              BEGIN
             inv_trx_util_pub.TRACE('txn allowed or not: .. 100 verifying at dest, xfer lpn id is null','Material Status', 9);
              SELECT 'N'
              INTO    l_allow_transaction
              FROM    dual
              WHERE   EXISTS
              (SELECT 1
                FROM    mtl_onhand_quantities_detail moqd,
                mtl_status_transaction_control mtc
                WHERE   moqd.organization_id       = l_xfer_org_id
                AND moqd.inventory_item_id     = p_inventory_item_id
                AND moqd.subinventory_code     = l_xfer_sub_code
                AND nvl(moqd.locator_id,-999)  = nvl(l_xfer_locator_id,-999) --6974887        --could be null for INV sub-inventories(doubt)
                AND NVL(moqd.lot_number,'@@@') = NVL(p_lot_number,'@@@')   --only place where used xfer lot
                AND moqd.status_id          = mtc.status_id
                AND mtc.transaction_type_id = p_trx_type_id
                AND mtc.is_allowed          = 2
            --    AND ROWNUM = 1
              ) ;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_allow_transaction := 'Y' ;
            inv_trx_util_pub.TRACE('txn allowed or not: .. 110 ','Material Status', 9);
      END ;

        END IF;
        END IF;


ELSIF p_inventory_item_id is NULL and p_fromlpn_id is NOT NULL THEN -- p_inventory_item_id NULL so passing full LPN which just need to be checked at source

      BEGIN
           inv_trx_util_pub.TRACE('txn allowed or not: .. 120 full LPN Case','Material Status', 9);
                    --checking  whether the source material ALLOWS/DISALLOWS the transaction.
        --if l_serial_status_enabled is 1 then it is serial controlled item
         l_counter := 0;
       FOR l_cur_wlc IN c_lpn_item LOOP
             l_serial_controlled := 0;
             l_serial_status_enabled := 0;

             IF inv_cache.set_item_rec(p_organization_id, l_cur_wlc.inventory_item_id) THEN
              inv_trx_util_pub.TRACE('txn allowed or not: .. 120.0','Material Status', 9);
                  IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                      inv_trx_util_pub.TRACE('txn allowed or not: .. 120.1 serial controlled','Material Status', 9);
                      l_serial_controlled := 1; -- Item is serial controlled
                  END IF;

                  IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                      inv_trx_util_pub.TRACE('txn allowed or not: .. 120.2 serial status enabled-true','Material Status', 9);
                      l_serial_status_enabled := 1;
                  END IF;
             END IF;
                --if it is serial controlled and its serial status is enabled
             IF l_serial_controlled = 1 AND l_serial_status_enabled=1 THEN
               l_counter           := l_counter + 1;
               inv_trx_util_pub.TRACE('txn allowed or not: .. Exitting from the loop','Material Status', 9);
               EXIT; --exit even one item is serial controlled and its serial status enabled
             END IF;
        END LOOP;
              inv_trx_util_pub.TRACE('txn allowed or not: .. 120.3 Serial Count:'||l_counter,'Material Status', 9);
        --check for all non-serial items

        SELECT 'N'
        INTO    l_allow_transaction
        FROM    dual
        WHERE   EXISTS
        (SELECT 1
        FROM    mtl_onhand_quantities_detail moqd,
                mtl_status_transaction_control mtc
        WHERE   moqd.organization_id       = p_organization_id
            AND moqd.subinventory_code     = p_sub_code
            AND moqd.locator_id            = p_locator_id
           -- AND NVL(moqd.lot_number,'@@@') = NVL(p_lot_number,'@@@')
            AND moqd.lpn_id IN
                (SELECT lpn_id
                FROM    wms_license_plate_numbers plpn
                START WITH lpn_id = p_fromlpn_id CONNECT BY parent_lpn_id = prior lpn_id
                AND plpn.organization_id = p_organization_id
                )
            AND moqd.status_id          = mtc.status_id
            AND mtc.transaction_type_id = p_trx_type_id
            AND mtc.is_allowed          = 2
         --   AND ROWNUM = 1
        ) ;

      EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_allow_transaction := 'Y' ;
                inv_trx_util_pub.TRACE('txn allowed or not: .. 120.4 came here','Material Status', 9);

      END;
       --if still the transaction is allowed and the lpn contains serials
       BEGIN
        IF l_counter <> 0 AND l_allow_transaction = 'Y' THEN --if l_counter !=0 then serials exist in the LPN
        inv_trx_util_pub.TRACE('txn allowed or not: .. 120.5 Serials Exist so need to check MSN Status','Material Status', 9);
        SELECT 'N'
        INTO    l_allow_transaction
        FROM    dual
        WHERE   EXISTS
        (SELECT 1
        FROM    wms_lpn_contents wlc  ,
                mtl_serial_numbers msn,
                mtl_status_transaction_control mtc
        WHERE   wlc.parent_lpn_id IN
                (SELECT lpn_id
                FROM    wms_license_plate_numbers START
                WITH lpn_id             = p_fromlpn_id CONNECT BY parent_lpn_id = PRIOR lpn_id
                    AND organization_id = p_organization_id
                )
            AND wlc.serial_summary_entry = 1
            AND wlc.parent_lpn_id        = msn.lpn_id
            AND msn.status_id            = mtc.status_id
            AND mtc.transaction_type_id  = p_trx_type_id
            AND mtc.is_allowed           = 2
        );
       END IF;
       EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_allow_transaction := 'Y' ;
                inv_trx_util_pub.TRACE('txn allowed or not: .. 130 came here','Material Status', 9);

      END;
             --checking  whether the destination LPN ALLOWS/DISALLOWS the transaction.
      IF l_allow_transaction = 'Y' AND p_xfer_lpn_id IS NOT NULL AND l_xferlpn_context <> 5 THEN
       inv_trx_util_pub.TRACE('txn allowed or not: .. 140 verifying at dest-- xfer lpn allows/not','Material Status', 9);
          BEGIN
                SELECT 'N'
                 INTO    l_allow_transaction
                 FROM    dual
                 WHERE   EXISTS
                (SELECT 1
                FROM    mtl_onhand_quantities_detail moqd,
                        mtl_status_transaction_control mtc
                WHERE   moqd.organization_id   = l_xfer_org_id
                    AND moqd.lpn_id           = p_xfer_lpn_id
                    AND moqd.status_id          = mtc.status_id
                    AND mtc.transaction_type_id = p_trx_type_id
                    AND mtc.is_allowed          = 2
                ) ;

         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_allow_transaction := 'Y' ;
                inv_trx_util_pub.TRACE('txn allowed or not: .. 150 came here','Material Status', 9);
         END ;
      END IF; --l_allow_transaction = 'Y' AND p_xfer_lpn_id condition



END IF; --p_inventory_item_id check
                IF l_allow_transaction = 'N' THEN
                         l_validate := 2;
                 inv_trx_util_pub.TRACE('txn allowed or not: .. 160 came here','Material Status', 9);
                END IF;
inv_trx_util_pub.TRACE('txn allowed or not: .. 170 returning the value l_validate'||l_validate,'Material Status', 9);
                 RETURN l_validate;
END IF; --p_trx_type_id check

END is_status_applicable_lpns;

/*LPN Status Project*/

FUNCTION  is_trx_allowed
  (
     p_status_id                 IN NUMBER
   , p_transaction_type_id       IN NUMBER
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   ) return varchar2
IS
    allowed  number := 1;
    c_api_name varchar2(30) := 'is_trx_allowed';
BEGIN
   -- Onhand Material Status Support : Return true if the material status profile is not enabled.
   -- Added this check as now we are calling this method from QtyManager.
   IF NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'),2) <> 1 THEN
      RETURN 'Y';
   END IF;

   -- Onhand Material Status Support : Return true if status_id or transaction_type_id is null
   IF p_status_id is null or p_transaction_type_id is null THEN
      RETURN 'Y';
   END IF;

   x_return_status := fnd_api.g_ret_sts_success ;

   IF p_status_id <> nvl(g_status_id,-9999) OR
      p_transaction_type_id <> nvl(g_transaction_type_id,-9999) THEN
      select is_allowed
      into allowed
      from mtl_status_transaction_control
      where status_id = p_status_id
        and transaction_type_id = p_transaction_type_id;

      g_status_id := p_status_id;
      g_transaction_type_id := p_transaction_type_id;

      if allowed = 1 then
          g_is_allowed := 'Y';
      else
          g_is_allowed := 'N';
      end if;
   END IF;

   return nvl(g_is_allowed,'Y');

   exception
      when NO_DATA_FOUND THEN
          --Begin bug 4536902
                g_status_id := p_status_id;
          g_transaction_type_id := p_transaction_type_id;
          --End bug 4536902
          g_is_allowed := 'Y'; --Added as it was not being set for exception case Bug#6633612
          return 'Y';

      when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        if (fnd_msg_pub.check_msg_level
            (fnd_msg_pub.g_msg_lvl_unexp_error)) then
            fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
        end if;
        -- always return 'Y' when any error occurred
        --Begin bug 4536902
              g_status_id := p_status_id;
        g_transaction_type_id := p_transaction_type_id;
        --End bug 4536902
        g_is_allowed := 'Y'; --Added as it was not being set for exception case Bug#6633612
        return 'Y';
END is_trx_allowed;

/* Bug 6918409: Added a wrapper to call the is_trx_allowed function */
FUNCTION  is_trx_allowed_wrap
  (
     p_status_id                 IN NUMBER
   , p_transaction_type_id       IN NUMBER
   ) return varchar2
IS
    allowed             VARCHAR2(5)  := 'Y';
    c_api_name          VARCHAR2(30) := 'is_trx_allowed_wrap';
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(256);
BEGIN


   allowed := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>p_status_id
                      ,p_transaction_type_id=> p_transaction_type_id
                      ,x_return_status => l_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

   return nvl(allowed,'Y');

   exception
      when others then
        return 'Y';
END is_trx_allowed_wrap;


PROCEDURE get_lot_serial_status_control
(
     p_organization_id                  IN NUMBER
   , p_inventory_item_id                IN NUMBER
   , x_return_status                    OUT NOCOPY VARCHAR2
   , x_msg_count                        OUT NOCOPY NUMBER
   , x_msg_data                         OUT NOCOPY VARCHAR2
   , x_lot_status_enabled               OUT NOCOPY VARCHAR2
   , x_default_lot_status_id            OUT NOCOPY NUMBER
   , x_serial_status_enabled            OUT NOCOPY VARCHAR2
   , x_default_serial_status_id         OUT NOCOPY NUMBER
) IS
   c_api_name varchar2(30) := 'get_lot_serial_status_control';
BEGIN
    x_return_status := fnd_api.g_ret_sts_success ;

    IF p_organization_id <> nvl(g_organization_id,-9999) OR
       p_inventory_item_id <> nvl(g_inventory_item_id,-9999) THEN

       -- Onhand Material Status Support: If status_enabled flags are null then return 'N'.
       SELECT nvl(lot_status_enabled,'N'), Default_Lot_Status_ID,
              nvl(serial_status_enabled,'N'), Default_serial_status_ID
       INTO g_lot_status_enabled, g_default_lot_status_id,
            g_serial_status_enabled, g_default_serial_status_id
       FROM MTL_SYSTEM_ITEMS
       WHERE organization_id = p_organization_id
       AND   inventory_item_id = p_inventory_item_id;
      --bug3713809
       g_organization_id := p_organization_id;
       g_inventory_item_id := p_inventory_item_id;

       /*if x_serial_status_enabled is null then
           x_serial_status_enabled := 'Y';
       end if;

       if x_lot_status_enabled is null then
           x_lot_status_enabled := 'Y';
       end if;*/
    END IF;

    x_lot_status_enabled := g_lot_status_enabled;
    x_default_lot_status_id := g_default_lot_status_id;
    x_serial_status_enabled := g_serial_status_enabled;
    x_default_serial_status_id := g_default_serial_status_id;

    exception
      when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        if (fnd_msg_pub.check_msg_level
            (fnd_msg_pub.g_msg_lvl_unexp_error)) then
            fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
        end if;

         --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END get_lot_serial_status_control;

-- Onhand Material Status Support: Calling the overloaded function.
Function is_status_applicable(p_wms_installed           IN VARCHAR2,
                           p_trx_status_enabled         IN NUMBER,
                           p_trx_type_id                IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled      IN VARCHAR2,
                           p_organization_id            IN NUMBER,
                           p_inventory_item_id          IN NUMBER,
                           p_sub_code                   IN VARCHAR2,
                           p_locator_id                 IN NUMBER,
                           p_lot_number                 IN VARCHAR2,
                           p_serial_number              IN VARCHAR2,
                           p_object_type                IN VARCHAR2)
return varchar2 is

   p_lpn_id NUMBER := NULL;
   l_return_status VARCHAR2(1);
BEGIN

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('inside non-overloaded is_status_applicable ', 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   l_return_status:=  is_status_applicable(p_wms_installed           ,
                           p_trx_status_enabled    ,
                           p_trx_type_id           ,
                           p_lot_status_enabled    ,
                           p_serial_status_enabled ,
                           p_organization_id       ,
                           p_inventory_item_id     ,
                           p_sub_code              ,
                           p_locator_id            ,
                           p_lot_number            ,
                           p_serial_number         ,
                           p_object_type           ,
                           p_lpn_id);

   return l_return_status;

EXCEPTION
   when others then
      return 'Y';
END;

Function is_status_applicable(p_wms_installed           IN VARCHAR2,
                           p_trx_status_enabled         IN NUMBER,
                           p_trx_type_id                IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled      IN VARCHAR2,
                           p_organization_id            IN NUMBER,
                           p_inventory_item_id          IN NUMBER,
                           p_sub_code                   IN VARCHAR2,
                           p_locator_id                 IN NUMBER,
                           p_lot_number                 IN VARCHAR2,
                           p_serial_number              IN VARCHAR2,
                           p_object_type                IN VARCHAR2,
                           p_lpn_id                     IN NUMBER) -- Onhand Material Status Support
return varchar2 is
    l_status_id number;
    l_new_status_id number; --ERES Deferred
    l_return_status VARCHAR2(1);
    l_new_return_status VARCHAR2(1);  --ERES Deferred
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(256);
    l_trx_status_enabled   number := 1;
    l_lot_status_enabled   VARCHAR2(1);
    l_default_lot_status_id  number;
    l_serial_status_enabled  VARCHAR2(1);
    l_default_serial_status_id   number;
    l_wms_installed varchar2(30);
    --ERES Deferred
    l_pending_eres_chk NUMBER :=0;
    l_eres_enabled     VARCHAR2(3)   := NVL(fnd_profile.VALUE('EDR_ERES_ENABLED'), 'N');
    g_eres_enabled         VARCHAR2(3)   := NVL(fnd_profile.VALUE('INV_DEF_ERES_ENABLED'), 'N');
    -- New variables for MACD Validations
    --l_old_item_id        NUMBER := FND_API.g_miss_num;
    l_item_trackable     VARCHAR2(1) := 'N';
    l_freeze_flag        VARCHAR2(1) := NULL;
    l_trx_action_id      NUMBER;
    l_trx_source_type    NUMBER;
    l_trx_id             NUMBER := NULL;
    l_ib_cz_keys         VARCHAR2(1) := 'Y';
    l_default_status_id  NUMBER; -- Onhand Material Status Support
    count_status_id      NUMBER:= -1;-- Onhand Material Status Support
    l_default_item_status_id  NUMBER; -- Onhand Material Status Support
    l_locator_id              NUMBER;    -- Onhand Material Status Support

    /* Bug 6918409 */
    l_serial_controlled  NUMBER:=0;
    l_count              NUMBER:=0;
    l_status_code        VARCHAR2(80);
    l_new_status_code        VARCHAR2(80); --ERES Deferred

BEGIN
   --INCONV kkillams
   -- Bug 4121999
   IF NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'),2) <> 1 THEN
      RETURN 'Y';
   END IF;
  --END INCONV kkillams

  -- Onhand Material Status Support
  if (inv_cache.set_org_rec(p_organization_id)) then
      l_default_status_id :=  inv_cache.org_rec.default_status_id;
  end if;


  -- Call the new CSI Function at the start and disregard if
  -- WMS is installed or not

  -- Check to see if the item is trackable. Only run this for Each Item and
  -- Not every time. Only call the MACD Validations for Serial Checks
  -- p_object_type = S

  --Bug #5367711
  --Caching the values of item_id, freeze_flag, item_trackable to avoid redundant calls
  IF p_object_type = 'S' THEN
    BEGIN
      IF p_inventory_item_id <> NVL(g_old_item_id,-9999) THEN
        SELECT NVL(msi.comms_nl_trackable_flag,'N')
        INTO g_item_trackable
        FROM   mtl_system_items msi,
               mtl_parameters mp
        WHERE  msi.inventory_item_id = p_inventory_item_id
        AND    msi.enabled_flag = 'Y'
        AND    nvl (msi.start_date_active, sysdate) <= sysdate
        AND    nvl (msi.end_date_active, sysdate+1) > sysdate
        AND    msi.organization_id = mp.master_organization_id
        AND    mp.organization_id = p_organization_id;

        g_old_item_id := p_inventory_item_id;
    END IF;
    EXCEPTION
      WHEN others THEN
        g_item_trackable := 'N';
    END;

    -- Get the source and action for the transaction type being passed
    -- in and use that to decide wheather or not to execute the MACD
    -- Validations.

    BEGIN
      --IF l_trx_id IS NULL THEN
      IF ( (p_trx_type_id IS NOT NULL) AND
           (p_trx_type_id <> NVL(g_isa_trx_type_id,-9999))
          ) THEN
        SELECT transaction_action_id,
               transaction_source_type_id
        INTO   g_transaction_action_id,
               g_transaction_source_type_id
        FROM   mtl_transaction_types mtt
        WHERE  mtt.transaction_type_id = p_trx_type_id;
        g_isa_trx_type_id := p_trx_type_id;
      ELSE
        g_transaction_action_id := NULL;
        g_transaction_source_type_id := NULL;
      END IF;
    EXCEPTION
      WHEN others THEN
        g_transaction_action_id      := FND_API.g_miss_num;
        g_transaction_source_type_id := FND_API.g_miss_num;
    END;

    -- Check to see if IB is active Only run this 1 time per session

    BEGIN
      IF g_freeze_flag IS NULL THEN
        SELECT nvl(freeze_flag, 'N')
        INTO   g_freeze_flag
        FROM   csi_install_parameters
        WHERE  rownum = 1;

    END IF;
    EXCEPTION
    WHEN others THEN
      g_freeze_flag := 'N';
    END;

    IF g_item_trackable = 'Y' AND
       g_freeze_flag = 'Y' AND
       g_transaction_action_id = 27 AND
       g_transaction_source_type_id <> 12 THEN -- RMA

         l_ib_cz_keys := csi_utility_grp.check_inv_serial_cz_keys(p_inventory_item_id,
                                                                  p_organization_id,
                                                                  p_serial_number);

    IF l_ib_cz_keys = 'Y' THEN
      Return 'N';
    ELSE
      Return 'Y';
    END IF;

    END IF;

  END IF; -- p_object_type = S



    --INCONV kkillams
    /*
    l_wms_installed := p_wms_installed;
    if p_wms_installed is null then
        IF not wms_install.check_install(l_return_status,
                                   l_msg_count,
                                   l_msg_data,
                                   NULL ) then
             return 'Y';
         ELSE l_wms_installed := 'TRUE';
         END IF;
    end if;

    if UPPER(l_wms_installed) <>'TRUE' then
        return 'Y';
    end if;
   */
   --END INVCONV kkillams
    -- In case user doesn't pass p_trx_status_enabled
    if p_trx_status_enabled is null then
        if p_trx_type_id <> nvl(g_isa_trx_type_id,-9999) THEN
            select status_control_flag
            into g_isa_trx_status_enabled
            from mtl_transaction_types
            where transaction_type_id = p_trx_type_id;
            g_isa_trx_type_id := p_trx_type_id;
        end if;
        l_trx_status_enabled := g_isa_trx_status_enabled;
        if l_trx_status_enabled = 2 then return 'Y'; end if;
    elsif p_trx_status_enabled = 2 then
        return 'Y';
    end if;

    -- In case user doesn't pass p_lot_status_enabled and
    -- p_serial_status_enabled
    l_lot_status_enabled := p_lot_status_enabled;
    l_serial_status_enabled := p_serial_status_enabled;
    -- Onhand Material Status Support: We need lot and serial control even if the object type is not lot or serial.
    if ( (p_lot_status_enabled is null)  or
         (p_serial_status_enabled is null) )then
       INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control(
          p_organization_id =>p_organization_id
        , p_inventory_item_id =>p_inventory_item_id
        , x_return_status =>l_return_status
        , x_msg_count =>l_msg_count
        , x_msg_data =>l_msg_data
        , x_lot_status_enabled =>l_lot_status_enabled
        , x_default_lot_status_id =>l_default_lot_status_id
        , x_serial_status_enabled =>l_serial_status_enabled
        , x_default_serial_status_id =>l_default_serial_status_id);

        -- Bug 6829224 : Should check for lot_status_enabled only if the org is NOT tracking the
        -- material status at onhand level.
        if ( p_object_type = 'O' and l_lot_status_enabled = 'N' and l_default_status_id is null) or
           ( p_object_type = 'S' and l_serial_status_enabled = 'N') then
           return 'Y';
        end if;
    elsif  ( p_object_type = 'O' and p_lot_status_enabled = 'N' and l_default_status_id is null) or
           ( p_object_type = 'S' and p_serial_status_enabled = 'N') then
            return 'Y';
    end if;

    -- Onhand Material Status Support
    if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
       l_default_item_status_id :=  inv_cache.item_rec.default_material_status_id;
    end if;

    /* Bug 6918409 */
    if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
       if (inv_cache.item_rec.serial_number_control_code not in (1,6)) then
         l_serial_controlled :=  1;
       end if;
    end if;
    /* Bug 6918409 */

    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('default org status id ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
    end if;

    if (p_sub_code is not null ) and (p_object_type = 'Z' or p_object_type = 'A') then
        if(( p_organization_id <> nvl(g_isa_organization_id,-9999) ) or
           ( p_sub_code <> nvl(g_isa_sub_code,-9999)) or
           ( l_default_status_id is not null) or -- Onhand Material Status Support: No caching if status is at onhand level
		   NOT(inv_cache.is_pickrelease) OR (inv_cache.is_pickrelease IS NULL)  --Bug 6939535
          )THEN
           -- Onhand Material Status Support : If status is tracked at the onhand level,
           -- then retrieve status_id from MOQD.
           if (l_default_status_id is null) then
              select status_id
              into g_isa_sub_status_id
              from mtl_secondary_inventories
              where organization_id = p_organization_id
              and secondary_inventory_name = p_sub_code;
              g_isa_organization_id := p_organization_id;
              g_isa_sub_code := p_sub_code;

		--ERES Deferred
                --IF g_eres_enabled <> 'N' THEN
		  BEGIN
                    SELECT status_id INTO l_new_status_id
                    FROM mtl_material_status_history
                      where organization_id = p_organization_id
                      and zone_code = p_sub_code
		      and locator_id is null
		      and inventory_item_id is null
		      and lot_number is null
                      AND pending_status = 1
                      and rownum  = 1  ;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		      l_new_status_id := NULL;
		  END;
                --END IF;


           else
              if (p_inventory_item_id is not null) then
                 begin

                    if (g_debug = 1) then
                       inv_trx_util_pub.TRACE('sub ' || p_sub_code, 'INV_MATERIAL_STATUS_GRP', 14);
                    end if;
		--ERES Deferred
               -- IF g_eres_enabled <> 'N' THEN
		  BEGIN
                    SELECT status_id INTO l_new_status_id
                    FROM mtl_material_status_history
                      where inventory_item_id = p_inventory_item_id
		      and organization_id = p_organization_id
                      and zone_code = p_sub_code
                      and lot_number is null
                      and locator_id is null
                      and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                      AND pending_status = 1
                      and rownum  = 1  ;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		      l_new_status_id := NULL;
		  END;
               -- END IF;


                    select nvl(status_id, -1)
                    into g_isa_sub_status_id
                    from mtl_onhand_quantities_detail
                    where inventory_item_id = p_inventory_item_id
                      and organization_id = p_organization_id
                      and subinventory_code = p_sub_code
                      and lot_number is null
                      and locator_id is null
                      and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                      and rownum  = 1  ;

                    if (g_debug = 1) then
                       inv_trx_util_pub.TRACE('sub status id ' || g_isa_sub_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                    end if;

                    g_isa_organization_id := p_organization_id;
                    g_isa_sub_code := p_sub_code;
                 exception
                    when no_data_found then
                       -- If no onhand record exists and the item is not locator/lot/serial controlled then
                       -- we need to check whether the subinv status allows the transaction as that is going to be
                       -- the status in MOQD except for the transfer transactions.
                       if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('locator control '|| get_locator_control(p_organization_id, p_inventory_item_id, p_sub_code), 'INV_MATERIAL_STATUS_GRP', 14);
                       end if;

                       /* Bug 6918409 */
                       if(l_lot_status_enabled = 'Y' or l_serial_controlled = 1
                          or get_locator_control(p_organization_id, p_inventory_item_id, p_sub_code) <> 1) then
                          -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                          if(p_object_type <> 'A' ) then
                             return 'Y';
                          end if;
                       else
                          if (get_action_id(p_trx_type_id) in (2,3,21,28)) then -- Need to use action Id.

                             if (g_debug = 1) then
                               inv_trx_util_pub.TRACE('returning Y as its a transfer transaction', 'INV_MATERIAL_STATUS_GRP', 14);
                             end if;

                             return 'Y';
                          else
                             /* Bug 6918409 */
                             l_count := 0;
                             if (l_lot_status_enabled <> 'Y' ) then
                                if (g_debug = 1) then
                                  inv_trx_util_pub.TRACE('lot status is not enabled', 'INV_MATERIAL_STATUS_GRP', 14);
                                end if;
                             /* Bug 6975416 : Modified the SQL for 10g
                              * compliance
                              */
                                begin
                                   select 1
                                     into l_count
                                   from mtl_onhand_quantities_detail moqd
                                   where moqd.inventory_item_id = p_inventory_item_id
                                   and moqd.organization_id = p_organization_id
                                   and moqd.subinventory_code = p_sub_code
                                   and INV_MATERIAL_STATUS_GRP.is_trx_allowed_wrap(
                                              moqd.status_id
                                             ,p_trx_type_id) = 'Y'
                                   and rownum  = 1;
                                exception
                                   when others then
                                      l_count := 0;
                                end;

                                if (g_debug = 1) then
                                  inv_trx_util_pub.TRACE('sub, l_count: '||l_count, 'INV_MATERIAL_STATUS_GRP', 14);
                                end if;

                                if (l_count = 1 and p_object_type <> 'A') then
                                    return 'Y';
                                end if;
                             end if;

                             if (l_count <> 1 ) then
                                if (l_default_item_status_id is not null) then
                                   g_isa_sub_status_id := l_default_item_status_id;
                                elsif inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                   g_isa_sub_status_id := inv_cache.tosub_rec.status_id;
                                end if;
                                if (g_debug = 1) then
                                  inv_trx_util_pub.TRACE('sub, l_count is 0, sub_status_id: '||g_isa_sub_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                                end if;
                             end if;
                          end if;
                       end if;
                 end;

                 if (g_isa_sub_status_id is null or g_isa_sub_status_id = 0 or g_isa_sub_status_id = -1)
                    and p_object_type <> 'A' then

                    if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
                      if (inv_cache.item_rec.serial_number_control_code in (1,6)) then

                         if (g_debug = 1) then
                            inv_trx_util_pub.TRACE('sub, status is null in MOQD for non-serial controlled item', 'INV_MATERIAL_STATUS_GRP', 14);
                         end if;

                         FND_MESSAGE.SET_NAME('INV', 'INV_NULL_MOQD_STATUS');
                         FND_MESSAGE.SET_TOKEN('ORG_ID', p_organization_id);
                         FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
                         FND_MESSAGE.SET_TOKEN('SUB', p_sub_code);
                         FND_MESSAGE.SET_TOKEN('LOC_ID', p_locator_id );
                         FND_MESSAGE.SET_TOKEN('LOT', p_lot_number);
                         FND_MESSAGE.SET_TOKEN('LPN_ID', p_lpn_id);
                         FND_MSG_PUB.ADD;

                         return 'N';

                      elsif ((inv_cache.item_rec.serial_number_control_code not in (1,6))  and g_isa_sub_status_id = -1) then
                         return 'Y';
                      end if;
                    end if;
                 end if;
              else
                 if (g_debug = 1) then
                   inv_trx_util_pub.TRACE('Item id is null for sub', 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;

                 begin
                    select count(distinct status_id)
                    into count_status_id
                    from mtl_onhand_quantities_detail
                    where organization_id = p_organization_id
                    and subinventory_code = p_sub_code;
                    --Bug 7126137
                    --and lot_number is null
                    --and locator_id is null
                    --and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999);

                    if ( count_status_id = 1) then
                       select status_id
                       into g_isa_sub_status_id
                       from mtl_onhand_quantities_detail
                       where organization_id = p_organization_id
                       and subinventory_code = p_sub_code
                       --Bug 7126137
                       --and lot_number is null
                       --and locator_id is null
                       --and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                       and rownum  = 1  ;
                    else
                       g_isa_organization_id := p_organization_id;
                       g_isa_sub_code := p_sub_code;
                       -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                       if(p_object_type <> 'A' ) then
                          return 'Y';
                       end if;
                    end if;

                    g_isa_organization_id := p_organization_id;
                    g_isa_sub_code := p_sub_code;
                 exception
                    when no_data_found then
                       -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                       if(p_object_type <> 'A' ) then
                          return 'Y';
                       end if;
                 end;
              end if;

           end if;
        end if;
        l_status_id := g_isa_sub_status_id;

     /* Added IF condition for bug 10231569 */
     IF (l_status_id IS NOT NULL) THEN

        SELECT status_code INTO l_status_code
        FROM mtl_material_statuses_vl
        WHERE status_id = l_status_id ;

	IF (l_new_status_id is not null) then
	   SELECT status_code INTO l_new_status_code
           FROM mtl_material_statuses_vl
           WHERE status_id = l_new_status_id ;
	end if;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('sub,'||p_sub_code||' l_status_id ' || l_status_id ||',status ' || l_status_code || 'pending status id is:'
	   ||l_new_status_id||'pending status is:'||l_new_status_code||',trx type id '||p_trx_type_id, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;


        l_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('sub, l return status ' || l_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;

        IF l_new_status_id is not null THEN
          l_new_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_new_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_new_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

          if (g_debug = 1) then
             inv_trx_util_pub.TRACE('sub, l_new_return status ' || l_new_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
          end if;
        END IF;
        if (p_object_type = 'Z') or (p_object_type = 'A' and
                                  (l_return_status = 'N' OR l_new_return_status = 'N')) then
           if( l_return_status = 'N' OR l_new_return_status = 'N') then
                FND_MESSAGE.SET_NAME('INV', 'INV_STATUS_NOT_APP');
		IF l_return_status = 'N' THEN
                  FND_MESSAGE.SET_TOKEN('STATUS',l_status_code);
		ELSIF l_new_return_Status = 'N' THEN
		  FND_MESSAGE.SET_TOKEN('STATUS',l_new_status_code);
		END IF;
                /* Changes done while fixing  bug 6974630 */
                IF l_default_status_id is null THEN
               --     FND_MESSAGE.SET_TOKEN('TOKEN', 'Subinventory');
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'SUB',
                                    TRANSLATE => TRUE);
                      FND_MESSAGE.SET_TOKEN('OBJECT',p_sub_code);
                ELSE
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'OHN',
                                    TRANSLATE => TRUE);
                      FND_MESSAGE.SET_TOKEN('OBJECT','');
                END IF;
                /* End Changes done while fixing  bug 6974630 */
                FND_MSG_PUB.ADD;
		l_return_status := 'N';
           end if;
           return(l_return_status);
        end if;
     END IF;
    end if;

    if (p_locator_id is not null) and (p_object_type = 'L' or
                                       p_object_type = 'A' ) then
        if(( p_organization_id <> nvl(g_isa_organization_id,-9999) ) or
           ( p_locator_id <> nvl(g_isa_locator_id,-9999)) or
           ( l_default_status_id is not null) or -- Onhand Material Status Support: No caching if status is at onhand level
		   NOT(inv_cache.is_pickrelease) OR (inv_cache.is_pickrelease IS NULL)  --Bug 6939535
          ) THEN

           -- Onhand Material Status Support : If status is tracked at the onhand level,
           -- then retrieve status_id from MOQD.
           if (l_default_status_id is null) then
                /* Bug 8515078 Added below query in BEGIN-EXCEPTION block and added exception code */
                 BEGIN
		                    --ERES Deferred
                  -- IF g_eres_enabled <> 'N' THEN
		     BEGIN
                       SELECT status_id INTO l_new_status_id
                       FROM mtl_material_status_history
                       where organization_id = p_organization_id
                       and locator_id  = p_locator_id
		       and inventory_item_id is null
		       and lot_number is null
                       AND pending_status = 1
                       and rownum  = 1  ;
   		     EXCEPTION
		        WHEN NO_DATA_FOUND THEN
		          l_new_status_id := NULL;
		     END;
                  --END IF;

                         SELECT status_id
                         INTO   g_isa_loc_status_id
                         FROM   mtl_item_locations
                         WHERE  inventory_location_id = p_locator_id
                            AND organization_id       = p_organization_id;

                         g_isa_organization_id := p_organization_id;
                         g_isa_locator_id      := p_locator_id;
                 EXCEPTION
                 WHEN no_data_found THEN
                         IF ((p_locator_id = -1) AND
                                 (
                                         p_sub_code IS NOT NULL
                                 )
                                 ) THEN -- Bug 8515078 dynamic locator
                                 IF inv_cache.set_tosub_rec(p_organization_id, p_sub_code) THEN
                                         IF (inv_cache.tosub_rec.default_loc_status_id IS NOT NULL) THEN
                                                 g_isa_loc_status_id := inv_cache.tosub_rec.default_loc_status_id;
                                         ELSE
                                                 RETURN 'Y';
                                         END IF;
                                 ELSE
                                         RETURN 'Y';
                                 END IF;
                         ELSE
                                 RETURN 'Y';
                         END IF;
                 WHEN OTHERS THEN
                         RETURN 'Y';
                 END;
           else
               if (p_inventory_item_id is not null) then
                 begin

                    if (g_debug = 1) then
                       inv_trx_util_pub.TRACE('loc ' || p_locator_id, 'INV_MATERIAL_STATUS_GRP', 14);
                    end if;
		    --ERES Deferred
                   -- IF g_eres_enabled <> 'N' THEN
                      BEGIN
	                    SELECT status_id INTO l_new_status_id
		            FROM mtl_material_status_history
			      where inventory_item_id = p_inventory_item_id
	                      and organization_id = p_organization_id
		              and lot_number is null
			      and locator_id = p_locator_id
	                      and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
	                      AND pending_status = 1
	                      and rownum  = 1  ;
		      EXCEPTION
		        WHEN NO_DATA_FOUND THEN
		          l_new_status_id := NULL;
		      END;
                  --  END IF;

                    select nvl(status_id, -1)
                    into g_isa_loc_status_id
                    from mtl_onhand_quantities_detail
                    where inventory_item_id = p_inventory_item_id
                      and organization_id = p_organization_id
                      and lot_number is null
                      and locator_id = p_locator_id
                      and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                      and rownum  = 1  ;

                    if (g_debug = 1) then
                       inv_trx_util_pub.TRACE('loc status id ' || g_isa_loc_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                    end if;

                    g_isa_organization_id := p_organization_id;
                    g_isa_locator_id := p_locator_id;
                 exception
                    when no_data_found then
                       /* Bug 6918409 */
                       if(l_lot_status_enabled = 'Y' or l_serial_controlled = 1) then
                          -- If object_type is A then we need to validate other objects(lot, serial) before returning
                          if(p_object_type <> 'A' ) then
                             return 'Y';
                          end if;
                       else
                          if (get_action_id(p_trx_type_id) in (2,3,21,28)) then -- Need to change to action ID.
                             return 'Y';
                          else
                             /* Bug 6918409 */
                             l_count := 0;
                             if (l_lot_status_enabled <> 'Y' ) then
                                if (g_debug = 1) then
                                  inv_trx_util_pub.TRACE('loc, lot status is not enabled', 'INV_MATERIAL_STATUS_GRP', 14);
                                end if;
                                /* Bug 6975416 : Modified the SQL for 10g
                                 * compliance
                                 */
                                begin
                                   select 1
                                     into l_count
                                   from mtl_onhand_quantities_detail moqd
                                   where moqd.inventory_item_id = p_inventory_item_id
                                   and moqd.organization_id = p_organization_id
                                   and moqd.locator_id = p_locator_id
                                   and INV_MATERIAL_STATUS_GRP.is_trx_allowed_wrap(
                                              moqd.status_id
                                             ,p_trx_type_id) = 'Y'
                                   and rownum  = 1;
                                exception
                                   when others then
                                      l_count := 0;
                                end;

                                if (g_debug = 1) then
                                  inv_trx_util_pub.TRACE('loc, l_count: '||l_count, 'INV_MATERIAL_STATUS_GRP', 14);
                                end if;

                                if (l_count = 1 and p_object_type <> 'A') then
                                    return 'Y';
                                end if;
                             end if;

                             if (l_count <> 1 ) then
                                if (l_default_item_status_id is not null) then
                                   g_isa_loc_status_id := l_default_item_status_id;
                                elsif inv_cache.set_loc_rec(p_organization_id, p_locator_id) then
                                   if (inv_cache.loc_rec.status_id is not null) then
                                     g_isa_loc_status_id := inv_cache.loc_rec.status_id;
                                   else -- Locator is dynamic
                                     if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                       if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                                         g_isa_loc_status_id := inv_cache.tosub_rec.default_loc_status_id;
                                       else
                                         g_isa_loc_status_id := inv_cache.tosub_rec.status_id;
                                       end if;
                                     elsif p_sub_code is null and p_object_type <> 'A' then -- Bug 6918409
                                       return 'Y';
                                     end if;
                                   end if;
                                else
                                   if p_sub_code is null and p_object_type <> 'A' then -- Bug 6787033
                                      return 'Y';
                                   elsif inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                     if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                                        g_isa_loc_status_id := inv_cache.tosub_rec.default_loc_status_id;
                                     else
                                        g_isa_loc_status_id := inv_cache.tosub_rec.status_id;
                                     end if;
                                   end if;
                                end if;
                             end if;

                          end if;
                       end if;
                 end;

                 if (g_isa_loc_status_id is null or g_isa_loc_status_id = 0 or g_isa_loc_status_id = -1)
                    and p_object_type <> 'A' then
                    if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
                      if (inv_cache.item_rec.serial_number_control_code in (1,6)) then

                         if (g_debug = 1) then
                            inv_trx_util_pub.TRACE('Loc, status is null in MOQD for non-serial controlled item', 'INV_MATERIAL_STATUS_GRP', 14);
                         end if;

                         FND_MESSAGE.SET_NAME('INV', 'INV_NULL_MOQD_STATUS');
                         FND_MESSAGE.SET_TOKEN('ORG_ID', p_organization_id);
                         FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
                         FND_MESSAGE.SET_TOKEN('SUB', p_sub_code);
                         FND_MESSAGE.SET_TOKEN('LOC_ID', p_locator_id );
                         FND_MESSAGE.SET_TOKEN('LOT', p_lot_number);
                         FND_MESSAGE.SET_TOKEN('LPN_ID', p_lpn_id);
                         FND_MSG_PUB.ADD;
                         return 'N';
                      elsif ((inv_cache.item_rec.serial_number_control_code not in (1,6))  and g_isa_loc_status_id = -1) then
                         return 'Y';
                      end if;
                    end if;
                 end if;
              else

                 if (g_debug = 1) then
                   inv_trx_util_pub.TRACE('Item id is null for loc', 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;

                 begin
                    select count(distinct status_id)
                    into count_status_id
                    from mtl_onhand_quantities_detail
                    where organization_id = p_organization_id
                    --and lot_number is null -- Bug 7126137
                    and locator_id = p_locator_id;
                    --and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999); -- Bug 7126137

                    if ( count_status_id = 1) then
                       select status_id
                       into g_isa_loc_status_id
                       from mtl_onhand_quantities_detail
                       where organization_id = p_organization_id
                       and locator_id = p_locator_id
                       --Bug 7126137
                       --and lot_number is null
                       --and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                       and rownum  = 1  ;
                    else
                       g_isa_organization_id := p_organization_id;
                       g_isa_locator_id := p_locator_id;
                       -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                       if(p_object_type <> 'A' ) then
                          return 'Y';
                       end if;
                    end if;

                    g_isa_organization_id := p_organization_id;
                    g_isa_locator_id := p_locator_id;
                 exception
                    when no_data_found then
                       -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                       if(p_object_type <> 'A' ) then
                          return 'Y';
                       end if;
                 end;
              end if;

           end if;
        end if;
        l_status_id := g_isa_loc_status_id;

     /* Added IF condition for bug 10231569 */
     IF (l_status_id IS NOT NULL) THEN

        SELECT status_code INTO l_status_code
        FROM mtl_material_statuses_vl
        WHERE status_id = l_status_id ;

	IF (l_new_status_id is not null) then
	   SELECT status_code INTO l_new_status_code
           FROM mtl_material_statuses_vl
           WHERE status_id = l_new_status_id ;
	end if;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('sub, l_status_id ' || l_status_id ||',status ' || l_status_code || 'pending status id is:'
	   ||l_new_status_id||'pending status is:'||l_new_status_code||',trx type id '||p_trx_type_id, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;

        l_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('loc, l return status ' || l_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;
        IF l_new_status_id is not null THEN
          l_new_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_new_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_new_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

          if (g_debug = 1) then
             inv_trx_util_pub.TRACE('sub, l_new_return status ' || l_new_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
          end if;
        END IF;

        if (p_object_type = 'L') or (p_object_type = 'A' and
                                      (l_return_status = 'N' OR l_new_return_status = 'N')) then
            if( l_return_status = 'N' OR l_new_return_status = 'N' ) then
                FND_MESSAGE.SET_NAME('INV', 'INV_STATUS_NOT_APP');
                IF l_return_status = 'N' THEN
                  FND_MESSAGE.SET_TOKEN('STATUS',l_status_code);
		ELSIF l_new_return_Status = 'N' THEN
		  FND_MESSAGE.SET_TOKEN('STATUS',l_new_status_code);
		END IF;
                /* Changes done while fixing  bug 6974630 */
                IF l_default_status_id is null THEN
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'LOC',
                                    TRANSLATE => TRUE);
                ELSE
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'OHN',
                                    TRANSLATE => TRUE);
                END IF;
                /* End Changes done while fixing  bug 6974630 */
                FND_MESSAGE.SET_TOKEN('OBJECT','');
                FND_MSG_PUB.ADD;
		l_return_status := 'N';
            end if;
            return(l_return_status);
        end if;
     END IF;
    end if;

    -- Onhand Material Status Support: If org is tracking status at onhand level, then we should not check
    -- for lot_status_enabled
    if ((p_lot_number is not null) and ((l_lot_status_enabled = 'Y') or (l_default_status_id is not null))
       ) and (p_object_type = 'O' or p_object_type = 'A') then
             if( p_organization_id <> nvl(g_organization_id, -9999) OR
             p_inventory_item_id <> nvl(g_inventory_item_id, -9999) OR
             p_lot_number <> nvl(g_isa_lot_number, '@@@') OR
            (NOT(inv_cache.is_pickrelease) OR (inv_cache.is_pickrelease IS NULL)) OR
            ( l_default_status_id is not null) -- Onhand Material Status Support: No caching if status is at onhand level
          ) THEN --Bug 5457445

            -- Onhand Material Status Support : If status is tracked at the onhand level,
            -- then retrieve status_id from MOQD.
            if (l_default_status_id is null) then
	     Begin                        -- Bug 10380080
	         --ERES Deferred
                   --IF g_eres_enabled <> 'N' THEN
		     BEGIN
	                     SELECT status_id INTO l_new_status_id
	                     FROM mtl_material_status_history
	                     where inventory_item_id = p_inventory_item_id
	                     and organization_id = p_organization_id
	                     and lot_number  = p_lot_number
			     and zone_code is null
			     and locator_id is null
	                     AND pending_status = 1;
		     EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		         l_new_status_id := NULL;
		     END;
                 --END IF;

               select status_id
               INTO   g_isa_lot_number_status_id
               from mtl_lot_numbers
               where inventory_item_id = p_inventory_item_id
                 and organization_id = p_organization_id
                 and lot_number = p_lot_number;
	    exception
              when NO_DATA_FOUND then

	       select default_lot_status_id
               into g_isa_lot_number_status_id
               from mtl_system_items
               where organization_id = p_organization_id
               and   inventory_item_id = p_inventory_item_id;

               l_status_id := g_isa_lot_number_status_id;

             end;           --End Bug 10380080

               g_isa_lot_number := p_lot_number;
            else
               begin

                 if (g_debug = 1 ) then
                   inv_trx_util_pub.TRACE('Inside lot ', 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('org ' || p_organization_id, 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('item ' || p_inventory_item_id, 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('sub ' || p_sub_code, 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('loc ' || p_locator_id, 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('lot ' || p_lot_number, 'INV_MATERIAL_STATUS_GRP', 14);
                   inv_trx_util_pub.TRACE('lpn ' || p_lpn_id, 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;

          --Adding following locator id logic to support locator_id = -1
          --which is being passed from some mobile pages for null value.
           l_locator_id := p_locator_id;
           IF(l_locator_id = -1 ) THEN
              l_locator_id := NULL;
           END IF;
		--ERES Deferred
               -- IF g_eres_enabled <> 'N' THEN
                  BEGIN
                    SELECT status_id INTO l_new_status_id
                    FROM mtl_material_status_history
                      where inventory_item_id = p_inventory_item_id
                      and organization_id = p_organization_id
                      and zone_code = p_sub_code
                      and lot_number = p_lot_number
                      and nvl(locator_id, -9999) = nvl(l_locator_id, -9999)
                      and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                      AND pending_status = 1
                      and rownum  = 1  ;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		      l_new_status_id := NULL;
		  END;
                -- END IF;

                 select nvl(status_id, -1)
                 into g_isa_lot_number_status_id
                 from mtl_onhand_quantities_detail
                 where inventory_item_id = p_inventory_item_id
                             and organization_id = p_organization_id
                 and subinventory_code = p_sub_code
                             and nvl(locator_id, -9999) = nvl(l_locator_id, -9999)
                             and lot_number = p_lot_number
                 and nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
                 and rownum  = 1  ;

                 if (g_debug = 1 ) then
                    inv_trx_util_pub.TRACE('lot status id ' || g_isa_lot_number_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;

                 g_isa_lot_number := p_lot_number;
              exception
                 when no_data_found then
                    /* Bug 6918409 */
                    if(l_serial_controlled = 1) then
                       -- If object_type is A then we need to validate other objects(loc, lot, serial) before returning
                       if(p_object_type <> 'A' ) then
                          return 'Y';
                       end if;
                    else
                       if (get_action_id(p_trx_type_id) in (2,3,21,28)) then -- Need to put action IDs.
                          return 'Y';
                       else
                          if (l_lot_status_enabled = 'Y') then
                             if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
                                g_isa_lot_number_status_id := inv_cache.item_rec.default_lot_status_id;
                             end if;
                          else
                             /* Bug 6918409 */
                             if (l_default_item_status_id is not null) then
                                g_isa_lot_number_status_id := l_default_item_status_id;
                             elsif (get_locator_control(p_organization_id, p_inventory_item_id, p_sub_code) <> 1) then
                                if inv_cache.set_loc_rec(p_organization_id, l_locator_id) then
                                   if (inv_cache.loc_rec.status_id is not null) then
                                     g_isa_lot_number_status_id := inv_cache.loc_rec.status_id;
                                   else -- Locator is dynamic
                                     if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                       if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                                         g_isa_lot_number_status_id := inv_cache.tosub_rec.default_loc_status_id;
                                       else
                                         g_isa_lot_number_status_id := inv_cache.tosub_rec.status_id;
                                       end if;
                                     elsif p_sub_code is null and p_object_type <> 'A' then
                                       return 'Y';
                                     end if;
                                   end if;
                                else
                                   if p_sub_code is null and p_object_type <> 'A' then -- Bug 6787033
                                      return 'Y';
                                   elsif inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                     if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                                        g_isa_lot_number_status_id := inv_cache.tosub_rec.default_loc_status_id;
                                     else
                                        g_isa_lot_number_status_id := inv_cache.tosub_rec.status_id;
                                     end if;
                                   end if;
                                end if;
                             elsif ( p_sub_code is not null) then
                                if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                                    g_isa_lot_number_status_id := inv_cache.tosub_rec.status_id;
                                end if;
                             else
                                return 'Y';
                             end if;

                          end if;
                       end if;
                    end if;
              end;

              if (g_isa_lot_number_status_id is null or g_isa_lot_number_status_id = 0 or g_isa_lot_number_status_id = -1)
                 and p_object_type <> 'A' then
                 if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
                    if (inv_cache.item_rec.serial_number_control_code in (1,6)) then

                      if (g_debug = 1) then
                         inv_trx_util_pub.TRACE('lot, status is null in MOQD for non-serial controlled item', 'INV_MATERIAL_STATUS_GRP', 14);
                      end if;

                      FND_MESSAGE.SET_NAME('INV', 'INV_NULL_MOQD_STATUS');
                      FND_MESSAGE.SET_TOKEN('ORG_ID', p_organization_id);
                      FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
                      FND_MESSAGE.SET_TOKEN('SUB', p_sub_code);
                      FND_MESSAGE.SET_TOKEN('LOC_ID', p_locator_id );
                      FND_MESSAGE.SET_TOKEN('LOT', p_lot_number);
                      FND_MESSAGE.SET_TOKEN('LPN_ID', p_lpn_id);
                      FND_MSG_PUB.ADD;
                      return 'N';
                    elsif ((inv_cache.item_rec.serial_number_control_code not in (1,6))  and g_isa_lot_number_status_id = -1) then
                      return 'Y';
                    end if;
                 end if;
              end if;

            end if;
        end if;
        l_status_id := g_isa_lot_number_status_id;

     /* Added IF condition for bug 10231569 */
     IF (l_status_id IS NOT NULL) THEN

        SELECT status_code INTO l_status_code
        FROM mtl_material_statuses_vl
        WHERE status_id = l_status_id ;
	IF (l_new_status_id is not null) then
	   SELECT status_code INTO l_new_status_code
           FROM mtl_material_statuses_vl
           WHERE status_id = l_new_status_id ;
	end if;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('sub, l_status_id ' || l_status_id ||',status ' || l_status_code || 'pending status id is:'
	   ||l_new_status_id||'pending status is:'||l_new_status_code||',trx type id '||p_trx_type_id, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;


        l_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('lot, l return status ' || l_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;
        IF l_new_status_id is not null THEN
          l_new_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_new_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_new_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);

          if (g_debug = 1) then
             inv_trx_util_pub.TRACE('sub, l_new_return status ' || l_new_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
          end if;
        END IF;


    if (p_object_type = 'O') or (p_object_type = 'A' and
                                     (l_return_status = 'N' OR l_new_return_status ='N')) then
            if( l_return_status = 'N' OR l_new_return_status = 'N') then
                FND_MESSAGE.SET_NAME('INV', 'INV_STATUS_NOT_APP');
		IF l_return_status = 'N' THEN
                  FND_MESSAGE.SET_TOKEN('STATUS',l_status_code);
		ELSIF l_new_return_Status = 'N' THEN
		  FND_MESSAGE.SET_TOKEN('STATUS',l_new_status_code);
		END IF;

                /* Changes done while fixing  bug 6974630 */
                IF l_default_status_id is null THEN
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'LOT',
                                    TRANSLATE => TRUE);
                      FND_MESSAGE.SET_TOKEN('OBJECT',p_lot_number);
                ELSE
                      FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'OHN',
                                    TRANSLATE => TRUE);
                      FND_MESSAGE.SET_TOKEN('OBJECT','');
                END IF;
                /* END Changes done while fixing  bug 6974630 */
                FND_MSG_PUB.ADD;
		l_return_status := 'N';
            end if;
            return(l_return_status);
        end if;
     END IF;
    end if;

    if (p_serial_number is not null) and (l_serial_status_enabled = 'Y')
        and (p_object_type = 'S' or p_object_type = 'A') then
        /* Bug 7157303 Added below query in BEGIN-EXCEPTION-END block and added exception code */
        BEGIN
                SELECT status_id
                INTO   l_status_id
                FROM   mtl_serial_numbers
                WHERE  inventory_item_id       = p_inventory_item_id
                   AND current_organization_id = p_organization_id
                   AND serial_number           = p_serial_number;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                inv_trx_util_pub.TRACE('In dynamic serial checking default serial status'
                || l_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                SELECT default_serial_status_id
                INTO   l_status_id
                FROM   mtl_system_items
                WHERE  inventory_item_id = p_inventory_item_id
                   AND organization_id   = p_organization_id;

        END;

     /* Added IF condition for bug 10231569 */
     IF (l_status_id IS NOT NULL) THEN

        SELECT status_code INTO l_status_code
        FROM mtl_material_statuses_vl
        WHERE status_id = l_status_id ;

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('ser, l_status_id ' || l_status_id ||',status ' || l_status_code || ',trx type id '||p_trx_type_id, 'INV_MATERIAL_STATUS_GRP', 14);
        end if;

        l_return_status := INV_MATERIAL_STATUS_GRP.is_trx_allowed(
                       p_status_id =>l_status_id
                      ,p_transaction_type_id=> p_trx_type_id
                      ,x_return_status => l_return_status
                      ,x_msg_count => l_msg_count
                      ,x_msg_data => l_msg_data);
        if (p_object_type = 'S') or (p_object_type = 'A' and
                                     l_return_status = 'N') then
            if( l_return_status = 'N' ) then
                FND_MESSAGE.SET_NAME('INV', 'INV_STATUS_NOT_APP');
                FND_MESSAGE.SET_TOKEN('STATUS',l_status_code);
                /* Changes done while fixing  bug 6974630 */
                FND_MESSAGE.SET_TOKEN(
                                    TOKEN     => 'TOKEN',
                                    VALUE     => 'SER',
                                    TRANSLATE => TRUE);
                /* End Changes done while fixing  bug 6974630 */
                FND_MESSAGE.SET_TOKEN('OBJECT',p_serial_number);
                FND_MSG_PUB.ADD;
            end if;
            return(l_return_status);
        end if;
     END IF;
    end if;

    return 'Y';

    exception
      when others then
          return 'Y';
END is_status_applicable;

PROCEDURE update_status
  (  p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_update_method              IN NUMBER
   , p_status_id                  IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER:=NULL
   , p_sub_code                   IN VARCHAR2:=NULL
   , p_locator_id                 IN NUMBER:=NULL
   , p_lot_number                 IN VARCHAR2:=NULL
   , p_serial_number              IN VARCHAR2:=NULL
   , p_to_serial_number           IN VARCHAR2:=NULL
   , p_object_type                IN VARCHAR2
   , p_update_reason_id           IN NUMBER:=NULL
   , p_lpn_id                     IN NUMBER:=NULL -- Onhand Material Status Support
   , p_initial_status_flag        IN VARCHAR2:='N' -- Onhand Material Status Support
   ) IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'update_status';
l_return_status               VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_status_rec                  INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;
BEGIN
   --
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_status_rec.organization_id := p_organization_id;
   l_status_rec.inventory_item_id := p_inventory_item_id;
   l_status_rec.lot_number := p_lot_number;
   l_status_rec.serial_number := p_serial_number;
   l_status_rec.to_serial_number := p_to_serial_number;
   l_status_rec.update_method := p_update_method;
   l_status_rec.status_id := p_status_id;
   l_status_rec.zone_code := p_sub_code;
   l_status_rec.locator_id := p_locator_id;
   l_status_rec.update_reason_id := p_update_reason_id;
   -- Onhand Material Status Support
   l_status_rec.lpn_id := p_lpn_id; -- Setting the value of lpn_id
   l_status_rec.initial_status_flag := p_initial_status_flag; -- Setting the value of initial_status_flag


   INV_MATERIAL_STATUS_PUB.update_status(
                p_api_version_number => p_api_version_number
                , p_init_msg_lst => p_init_msg_lst
                , x_return_status =>l_return_status
                , x_msg_count => x_msg_count
                , x_msg_data => x_msg_data
                , p_object_type => p_object_type
                , p_status_rec => l_status_rec );

   x_return_status := l_return_status;

END update_status;

--Function added for Bug# 2879164
FUNCTION  loc_valid_for_item
   (  p_loc_id              NUMBER
    , p_org_id              NUMBER
    , p_inventory_item_id   NUMBER
    , p_sub_code            VARCHAR2
   ) RETURN VARCHAR2 IS
   l_temp NUMBER := -1;
   l_restrict_loc_code NUMBER := 2;
BEGIN

   --Bug 5500255, if p_loc_id is null, should return Y
        IF (p_loc_id is NULL) THEN
            RETURN 'Y';
        END IF;


     SELECT restrict_locators_code
         INTO l_restrict_loc_code
         FROM mtl_system_items
         WHERE organization_id = p_org_id
         AND inventory_item_id = p_inventory_item_id;

     IF (l_restrict_loc_code = 2) THEN
         RETURN 'Y';
     ELSE
         SELECT count(*)
         INTO l_temp
         FROM mtl_item_locations a, mtl_secondary_locators b
         WHERE b.organization_id = p_org_id
         AND b.inventory_item_id = p_inventory_item_id
         AND b.subinventory_code = p_sub_code
         AND a.inventory_location_id = b.secondary_locator
         AND a.organization_id = b.organization_id
         AND a.inventory_location_id = p_loc_id;
     END IF;

          IF (l_temp = 0) THEN
              RETURN 'N';
          ELSE
              RETURN 'Y';
          END IF;
--Bug 3328939:Added the exception block to handle the case when an
--exception is raised from the select queries in this function.
exception
     when others then
          return 'Y';
END loc_valid_for_item;

--Function added for Bug# 2879164
FUNCTION sub_valid_for_item(p_org_id             NUMBER:=NULL,
                            p_inventory_item_id  NUMBER:=NULL,
                            p_sub_code           VARCHAR2:=NULL)
RETURN VARCHAR2 IS
   l_temp NUMBER := -1;
   l_restrict_sub_code NUMBER := 2;
BEGIN

   SELECT restrict_subinventories_code
      INTO l_restrict_sub_code
      FROM mtl_system_items
      WHERE organization_id = p_org_id
      AND inventory_item_id = p_inventory_item_id;

   IF (l_restrict_sub_code = 2) THEN
      RETURN 'Y';
   ELSE
      SELECT count(*)
        INTO l_temp
        FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
       WHERE a.organization_id = p_org_id
         AND b.inventory_item_id = p_inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.secondary_inventory_name = b.secondary_inventory
         AND a.secondary_inventory_name = p_sub_code;

      IF (l_temp = 0) THEN
              RETURN 'N';
           ELSE
              RETURN 'Y';
           END IF;
   END IF;
--Bug 3328939:Added the exception block to handle the case when an
--exception is raised from the select queries in this function.
exception
     when others then
          return 'Y';
END sub_valid_for_item;

-- On-hand Material Status support
-- Bug 12747846 : Added three new fields: p_txn_source_id, p_txn_source_type_id, p_txn_type_id
Function get_default_status(p_organization_id        IN NUMBER,
                            p_inventory_item_id      IN NUMBER,
                            p_sub_code               IN VARCHAR2,
                            p_loc_id                 IN NUMBER :=NULL,
                            p_lot_number             IN VARCHAR2 :=NULL,
                            p_lpn_id                 IN NUMBER := NULL,
                            p_transaction_action_id  IN NUMBER := NULL,
                            p_src_status_id          IN NUMBER := NULL,
                            p_lock_id                IN NUMBER := 0,
                            p_header_id              IN NUMBER :=NULL,
                            p_txn_source_id          IN NUMBER := NULL,
                            p_txn_source_type_id     IN NUMBER := NULL,
                            p_txn_type_id            IN NUMBER := NULL,
			    m_status_id              IN NUMBER := NULL) --Material Status Enhancement - Tracking bug: 13519864
RETURN NUMBER IS

   l_default_status_id       NUMBER := 1; -- Status: Active
   l_default_org_status_id   NUMBER := 0;
   c_api_name                varchar2(30) := 'get_default_status';
   l_serial_controlled       NUMBER := 0;
   --Bug 12747846 Added new profile
   l_wip_lot_return        number := 0;

BEGIN

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('Inside get default status ', 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('org id ' ||p_organization_id  || ' Item id ' ||  p_inventory_item_id || ' sub ' || p_sub_code, 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('loc '|| p_loc_id || ' lot ' || p_lot_number || ' lpn ' || p_lpn_id || ' action ' || p_transaction_action_id || ' src ' || p_src_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('lock id '|| p_lock_id || ' header id '||p_header_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   if inv_cache.set_org_rec(p_organization_id) then
      l_default_org_status_id :=  inv_cache.org_rec.default_status_id;
   end if;

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('default org status ' || l_default_org_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
       if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
          l_serial_controlled := 1; -- Item is serial controlled
       end if;
   end if;

   if (l_default_org_status_id is null) then -- Org is not tracking status at onhand level
      return null;
   else
      IF p_lpn_id is null then /*LPN Status Project */
        SELECT nvl(status_id, -1)
        INTO l_default_status_id
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND subinventory_code = p_sub_code
        AND nvl( locator_id, -9999) =nvl( p_loc_id, -9999)
        AND nvl(lot_number, '@@@@') = nvl(p_lot_number, '@@@@')
        --AND nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999) /*LPN Status Project */
        AND rownum  = 1;
      ELSE
        SELECT nvl(status_id, -1)
        INTO l_default_status_id
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND nvl(lot_number, '@@@@') = nvl(p_lot_number, '@@@@')
        AND lpn_id  = p_lpn_id /*LPN Status Project */
        AND rownum  = 1;
      END IF ; /*LPN Status Project */

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('default status in MOQD ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
      end if;

      if (l_default_status_id = -1) then
         if (l_serial_controlled = 0) then

            if (g_debug = 1) then
              inv_trx_util_pub.TRACE('status is null in MOQD for non-serial controlled item', 'INV_MATERIAL_STATUS_GRP', 14);
            end if;

            FND_MESSAGE.SET_NAME('INV', 'INV_NULL_MOQD_STATUS');
            FND_MESSAGE.SET_TOKEN('ORG_ID', p_organization_id);
            FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
            FND_MESSAGE.SET_TOKEN('SUB', p_sub_code);
            FND_MESSAGE.SET_TOKEN('LOC_ID', p_loc_id );
            FND_MESSAGE.SET_TOKEN('LOT', p_lot_number);
            FND_MESSAGE.SET_TOKEN('LPN_ID', p_lpn_id);
            FND_MSG_PUB.ADD;
         else
            return null;
         end if;
      end if;

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE(' 1 default status returned ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
      end if;

      return l_default_status_id;
   end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

       --The records need to be locked to avoid comingling of status if multiple workers are
       --running in parallel.
       --Revision is passed as null
       --Issuereceipt is passed as 1 since we want the locking to occur irrespective of onhand
       --p_lock_id is only passed from QtyManager, all other calls to the defaulting logic do not
       --pass p_lock_id and p_header_id

       if (p_lock_id <> 0 and INV_TABLE_LOCK_PVT.lock_onhand_records(p_organization_id,p_inventory_item_id,null
                                                                   ,p_lot_number,p_sub_code,p_loc_id,1,p_header_id)
       ) then
          if (g_debug = 1) then
             inv_trx_util_pub.TRACE('Locked the MOQD record', 'INV_MATERIAL_STATUS_GRP', 14);
          end if;
       else
          if (g_debug = 1) then
             inv_trx_util_pub.TRACE('Unbale to lock MOQD ', 'INV_MATERIAL_STATUS_GRP', 14);
          end if;
       end if;

        -- Material Status Enhancement - Tracking bug: 13519864

       if (g_allow_status_entry <> 'N') then

          If (p_transaction_action_id is not null and p_transaction_action_id  in (27,12,31) ) then
                 If(m_status_id is not null) then

                    if (g_debug = 1) then
                      inv_trx_util_pub.TRACE('src status ex ' || m_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                    end if;
                    -- Calling the insert procedure to insert the status of the new onhand record into
                    -- the table : mtl_material_status_history
                    insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                         ,p_lpn_id, m_status_id, p_lock_id);

                    return m_status_id;
                 End if;
          end if;

        -- If onhand for a lot controlled item doesnt exist and if its
        -- an intransit receipt, the source onhand record's
        -- status_id needs to be stamped onto the new onhand record.

        If (p_transaction_action_id = 12
            and p_txn_source_id IS NOT NULL
            and p_lot_number is not null) then

        begin

          select X.status_id
          into l_default_status_id from
           (SELECT mtln.transaction_id, mtln.status_id
            FROM mtl_transaction_lot_numbers mtln,
                 mtl_material_transactions mmt,
                 rcv_shipment_lines rsl
            WHERE mmt.transaction_id = mtln.transaction_id
            AND mtln.inventory_item_id = p_inventory_item_id
            AND mmt.inventory_item_id = p_inventory_item_id
            AND rsl.shipment_line_id = p_txn_source_id
            AND rsl.to_organization_id = p_organization_id
            AND mtln.organization_id = rsl.from_organization_id
            AND mmt.organization_id = rsl.from_organization_id
            AND rsl.mmt_transaction_id = mmt.transaction_id
            AND mtln.lot_number = p_lot_number
            AND mmt.transaction_action_id = 21) X
          where rownum = 1;

          if (l_default_status_id is not null) then
            return l_default_status_id;
          end if;

        exception
          when others then
            if (g_debug = 1) then
              inv_trx_util_pub.TRACE('exception in the MTLN query',
                                     'INV_MATERIAL_STATUS_GRP', 14);
            end if;
          end;
       end if;
      end if;

       -- Bug 12747846: If onhand record for a lot controlled item doesnt exist and if it's a
       -- WIP component return transaction the original onhand record's status_id needs to
       -- be stamped onto the new onhand record.

       If (p_transaction_action_id = 27 and p_txn_source_type_id = 5 and p_lot_number is not null) then
           l_wip_lot_return  := NVL(FND_PROFILE.VALUE('INV_DEFAULT_LOT_STATUS_FOR_RETURN'),2);
           If(l_wip_lot_return=2) THEN
              If(p_txn_source_id is not null) then
                 if (g_debug = 1) then
                   inv_trx_util_pub.TRACE('src id ' || p_txn_source_id, 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;

                 begin

                     select X.status_id
                     into l_default_status_id from
                     (SELECT mtln.transaction_id, mtln.status_id
                      FROM mtl_transaction_lot_numbers mtln, mtl_material_transactions mmt
                      WHERE mmt.transaction_id = mtln.transaction_id
                      AND mtln.inventory_item_id = p_inventory_item_id
                      AND mtln.organization_id = p_organization_id
                      AND mtln.transaction_source_id = p_txn_source_id
                      AND mtln.lot_number = p_lot_number
                      AND mmt.transaction_action_id = 1
                      AND mmt.transaction_source_type_id = 5
                      ORDER BY mmt.creation_date desc) X
                     where rownum = 1;

                     if (g_debug = 1) then
                        inv_trx_util_pub.TRACE('MTLN l_default_status_id ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                     end if;


                     if (l_default_status_id is not null) then
                          return l_default_status_id;
                     end if;

                 exception
                    when others then
                       if (g_debug = 1) then
                          inv_trx_util_pub.TRACE('exception in the MTLN query', 'INV_MATERIAL_STATUS_GRP', 14);
                       end if;
                 end;
              end if;
           end if;
       end if;


       --If onhand record doesnt exist and if it's a transfer transaction then return
       --the source onhand record's status_id as the status_id of the source record
       --needs to be carried over to the new destination record.
       -- Bug 6736793 : Added lot split and lot translate transactions

       If (p_transaction_action_id is not null and p_transaction_action_id  in (2,3,28,50,51,52,40,42) ) then --ADDED 50,51,52 FOR LPN STATUS PROJECT
              If(p_src_status_id is not null) then

                 if (g_debug = 1) then
                   inv_trx_util_pub.TRACE('src status ex ' || p_src_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
                 end if;
                 -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
                 -- the table : mtl_material_status_history
                 insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                      ,p_lpn_id, p_src_status_id, p_lock_id);

                 return p_src_status_id;
              End if;
       end if;

       if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
          if (l_serial_controlled <> 0) then
             return null;
          elsif (inv_cache.item_rec.lot_status_enabled = 'Y') then
             -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
             -- the table : mtl_material_status_history
             insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                  ,p_lpn_id, inv_cache.item_rec.default_lot_status_id, p_lock_id);

             return inv_cache.item_rec.default_lot_status_id;
          elsif (inv_cache.item_rec.default_material_status_id is not null) then
             -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
             -- the table : mtl_material_status_history
             insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                  ,p_lpn_id, inv_cache.item_rec.default_material_status_id, p_lock_id);

             return inv_cache.item_rec.default_material_status_id;
          end if;
       end if;

       if p_loc_id is not null then
         if inv_cache.set_loc_rec(p_organization_id, p_loc_id) then
            if (inv_cache.loc_rec.status_id is not null) then
               -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
               -- the table : mtl_material_status_history
               insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.loc_rec.status_id, p_lock_id);

               return inv_cache.loc_rec.status_id;
            else -- Locator is dynamic
               if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                 if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                    -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
                    -- the table : mtl_material_status_history
                    insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.tosub_rec.default_loc_status_id, p_lock_id);

                    return inv_cache.tosub_rec.default_loc_status_id;
                 end if;
               end if;
            end if;
         else -- Locator is dynamic
            if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
               if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                  -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
                  -- the table : mtl_material_status_history
                  insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.tosub_rec.default_loc_status_id, p_lock_id);

                  return inv_cache.tosub_rec.default_loc_status_id;
               else
                  -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
                  -- the table : mtl_material_status_history
                  insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.tosub_rec.status_id, p_lock_id);

                  return inv_cache.tosub_rec.status_id;
               end if;
            end if;
         end if;
       end if;

       if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
          if (inv_cache.tosub_rec.status_id is not null) then
             -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
             -- the table : mtl_material_status_history
             insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.tosub_rec.status_id, p_lock_id);

             return inv_cache.tosub_rec.status_id;
          end if;
       end if;

       if inv_cache.set_org_rec(p_organization_id) then
          -- Bug 6798024 : Calling the insert procedure to insert the status of the new onhand record into
          -- the table : mtl_material_status_history
          insert_status_history(p_organization_id, p_inventory_item_id, p_sub_code, p_loc_id, p_lot_number
                                    ,p_lpn_id, inv_cache.org_rec.default_status_id, p_lock_id);

          return inv_cache.org_rec.default_status_id;
       end if;

   WHEN OTHERS THEN

     if (g_debug = 1) then
        inv_trx_util_pub.TRACE('Exception default status returned ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
     end if;

     return l_default_status_id;

END get_default_status;

-- On-hand Material Status support, Bug 6798024
Procedure insert_status_history(p_organization_id        IN NUMBER,
                                p_inventory_item_id      IN NUMBER,
                                p_sub_code               IN VARCHAR2,
                                p_loc_id                 IN NUMBER :=NULL,
                                p_lot_number             IN VARCHAR2 :=NULL,
                                p_lpn_id                 IN NUMBER := NULL,
                                p_status_id              IN NUMBER := NULL,
                                p_lock_id                IN NUMBER := 0)
IS
   c_api_name                varchar2(30) := 'insert_status_history';
   l_update_method           NUMBER := 2;
   l_api_version_number      NUMBER := 1.0;
   l_init_msg_lst            VARCHAR2(5) := 'F';
   l_initial_Status_Flag     VARCHAR2(4) := 'Y';
   l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(240);

BEGIN

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('Inside insert status history ', 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('org id ' ||p_organization_id  || ' Item id ' ||  p_inventory_item_id || ' sub ' || p_sub_code, 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('loc '|| p_loc_id || ' lot ' || p_lot_number || ' lpn ' || p_lpn_id || ' status id ' || p_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('lock id '|| p_lock_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;


   if (p_lock_id <> 0) then
       update_status(l_api_version_number, l_init_msg_lst, l_return_status ,l_msg_count
                    ,l_msg_data ,l_update_method ,p_status_id ,p_organization_id
                    ,p_inventory_item_id ,p_sub_code ,p_loc_id ,p_lot_number
                    ,NULL ,NULL ,'Q' ,NULL ,p_lpn_id, l_initial_status_flag);
   end if;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
   END IF;

EXCEPTION

   WHEN OTHERS THEN

     if (g_debug = 1) then
        inv_trx_util_pub.TRACE('Exception in insert_status_history, l_ret_status: '|| l_return_status, 'INV_MATERIAL_STATUS_GRP', 14);
        inv_trx_util_pub.TRACE('Exception in insert_status_history, l_msg_count: '|| l_msg_count, 'INV_MATERIAL_STATUS_GRP', 14);
        inv_trx_util_pub.TRACE('Exception in insert_status_history, l_msg_data: '||l_msg_data, 'INV_MATERIAL_STATUS_GRP', 14);
     end if;

END insert_status_history;

-- On-hand Material Status support
-- Defaulting logic for the concurrent program
Function get_default_status_conc(p_organization_id        IN NUMBER,
                                 p_inventory_item_id      IN NUMBER,
                            p_sub_code               IN VARCHAR2,
                            p_loc_id                 IN NUMBER :=NULL,
                            p_lot_number             IN VARCHAR2 :=NULL,
                            p_lpn_id                 IN NUMBER := NULL)
RETURN NUMBER IS

   l_default_status_id       NUMBER := 1; -- Status: Active
   l_default_org_status_id   NUMBER := 0;
   c_api_name                varchar2(30) := 'get_default_status_conc';
   l_serial_controlled       NUMBER := 0;
BEGIN

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('Inside get default status conc ', 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('org id ' ||p_organization_id  || ' Item id ' ||  p_inventory_item_id || ' sub ' || p_sub_code, 'INV_MATERIAL_STATUS_GRP', 14);
      inv_trx_util_pub.TRACE('loc '|| p_loc_id || ' lot ' || p_lot_number || ' lpn ' || p_lpn_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   if inv_cache.set_org_rec(p_organization_id) then
      l_default_org_status_id :=  inv_cache.org_rec.default_status_id;
   end if;

   l_default_status_id := l_default_org_status_id;

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('default org status ' || l_default_org_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
       if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
          l_serial_controlled := 1; -- Item is serial controlled
       end if;
   end if;

   if (l_default_org_status_id is null) then

       if inv_cache.set_item_rec(p_organization_id, p_inventory_item_id) then
          if (l_serial_controlled <> 0) then -- serial
             return null;
          elsif (inv_cache.item_rec.lot_status_enabled = 'Y') then -- lot
             return inv_cache.item_rec.default_lot_status_id;
          elsif (inv_cache.item_rec.default_material_status_id is not null) then -- item
             return inv_cache.item_rec.default_material_status_id;
          end if;
       end if;

       if p_loc_id is not null then
          if inv_cache.set_loc_rec(p_organization_id, p_loc_id) then
             if (inv_cache.loc_rec.status_id is not null) then
                return inv_cache.loc_rec.status_id;
             else -- Locator is dynamic
                if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
                  if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                     return inv_cache.tosub_rec.default_loc_status_id;
                  end if;
                end if;
             end if;
          else -- Locator is dynamic
            if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
               if (inv_cache.tosub_rec.default_loc_status_id is not null) then
                  return inv_cache.tosub_rec.default_loc_status_id;
               else
                  return inv_cache.tosub_rec.status_id;
               end if;
            end if;
          end if;
       end if;

       if inv_cache.set_tosub_rec(p_organization_id, p_sub_code) then
          if (inv_cache.tosub_rec.status_id is not null) then
             return inv_cache.tosub_rec.status_id;
          end if;
       end if;

       if inv_cache.set_org_rec(p_organization_id) then
          return inv_cache.org_rec.default_status_id;
       end if;

   end if;

   if (g_debug = 1) then
      inv_trx_util_pub.TRACE(' 1 default status returned ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
   end if;

   return l_default_status_id;

EXCEPTION

   WHEN OTHERS THEN

     if (g_debug = 1) then
        inv_trx_util_pub.TRACE('Exception default status returned ' || l_default_status_id, 'INV_MATERIAL_STATUS_GRP', 14);
     end if;

     return l_default_status_id;

END get_default_status_conc;

--Function added for Onhand Material Status Support
FUNCTION  get_locator_control
   (  p_org_id              NUMBER
    , p_inventory_item_id   NUMBER
    , p_sub_code            VARCHAR2
   ) RETURN NUMBER IS
   l_loc_control NUMBER := 1;
BEGIN

     -- Bug 6828620 : Added the NVLs
     if(nvl(g_organization_id, -9999) <> nvl(p_org_id, -9999)
     or nvl(g_inventory_item_id, -9999) <> nvl(p_inventory_item_id, -9999)
     or nvl(g_sub_code, '@@@@') <> nvl(p_sub_code, '@@@@')) then

         SELECT (decode(P.STOCK_LOCATOR_CONTROL_CODE,4,
                 decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE,S.LOCATOR_TYPE),
                 P.STOCK_LOCATOR_CONTROL_CODE))
         INTO  l_loc_control
         FROM  MTL_PARAMETERS P,MTL_SECONDARY_INVENTORIES S,MTL_SYSTEM_ITEMS I
         WHERE I.INVENTORY_ITEM_ID = p_inventory_item_id
         AND   I.ORGANIZATION_ID =  p_org_id
         AND   S.SECONDARY_INVENTORY_NAME = p_sub_code
         AND   I.ORGANIZATION_ID = S.ORGANIZATION_ID
         AND   P.ORGANIZATION_ID = S.ORGANIZATION_ID
         AND   P.ORGANIZATION_ID = I.ORGANIZATION_ID;

         g_organization_id := p_org_id;
         g_inventory_item_id := p_inventory_item_id;
         g_sub_code := p_sub_code;

         g_locator_control := l_loc_control;

     end if;

     return nvl(g_locator_control,1);

exception
     when others then
          return 1;
END get_locator_control;

--Function added for Onhand Material Status Support
FUNCTION get_action_id( p_trx_type_id NUMBER)
RETURN NUMBER IS

   l_action_id NUMBER := -1;
BEGIN

     select transaction_action_id
     into l_action_id
     from mtl_transaction_types
     where transaction_type_id = p_trx_type_id;

     return l_action_id;

exception
     when others then
          return -1;
END get_action_id;

--Bug #6633612, Adding following Procedure for onhand status support project
 PROCEDURE get_onhand_status_id
        ( p_organization_id        IN NUMBER
         ,p_inventory_item_id      IN NUMBER
         ,p_subinventory_code      IN VARCHAR2
         ,p_locator_id             IN NUMBER
         ,p_lot_number             IN VARCHAR2
         ,p_lpn_id                 IN NUMBER
         ,x_onhand_status_id       OUT NOCOPY NUMBER )

  IS
         l_organization_id NUMBER := p_organization_id;
         l_inventory_item_id NUMBER := p_inventory_item_id;
         l_subinventory_code VARCHAR2(80) := p_subinventory_code ;
         l_locator_id NUMBER := p_locator_id ;
         l_lot_number VARCHAR2(80) := p_lot_number ;
         l_lpn_id NUMBER := p_lpn_id ;
         l_onhand_status_id NUMBER ;

 BEGIN
    IF (g_debug = 1) then
            inv_trx_util_pub.TRACE('Inside get_onhand_status_id' , 'INV_MATERIAL_STATUS_GRP', 9);
    END IF;
    BEGIN
     SELECT NVL( status_id ,0 )
     INTO  l_onhand_status_id
     FROM  mtl_onhand_quantities_detail
     WHERE inventory_item_id = l_inventory_item_id
     AND   organization_id = l_organization_id
     AND   subinventory_code = l_subinventory_code
     AND   NVL(locator_id, -9999) = NVL(l_locator_id,-9999)
     AND   NVL(lot_number,'@@@@') = NVL(l_lot_number,'@@@@')
     AND nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
     --AND   ((l_lpn_id is NULL) OR (lpn_id  = l_lpn_id ))
     AND   rownum = 1;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_onhand_status_id := 0 ;
     END;

     x_onhand_status_id := l_onhand_status_id ;

  END get_onhand_status_id ;


--Bug #6633612, Adding following Procedure for onhand status support project
  PROCEDURE check_move_diff_status(
            p_org_id                IN NUMBER
          , p_inventory_item_id     IN NUMBER
          , p_subinventory_code     IN VARCHAR2
          , p_locator_id            IN NUMBER
          , p_transfer_org_id       IN NUMBER
          , p_transfer_subinventory IN VARCHAR2
          , p_transfer_locator_id   IN NUMBER
          , p_lot_number            IN VARCHAR2
          , p_transaction_action_id IN NUMBER
          , p_object_type           IN VARCHAR2
          , p_lpn_id                IN NUMBER
          , p_demand_src_header_id  IN NUMBER
          , p_revision              IN VARCHAR2
          , p_primary_quantity      IN NUMBER              -- Added this parameter for bug 7833080
          , x_return_status        OUT NOCOPY VARCHAR2
          , x_msg_count            OUT NOCOPY NUMBER
          , x_msg_data             OUT NOCOPY VARCHAR2
          , x_post_action          OUT NOCOPY  VARCHAR2
  ) IS
    c_api_name                varchar2(30) := 'check_move_diff_status';
    l_allow_different_status NUMBER;
    l_org_id NUMBER;
    l_transfer_org_id NUMBER;
    l_lot_status_id NUMBER;

    l_lot_control_code_source NUMBER;
    l_serial_control_code_source NUMBER;
    l_lot_source_status varchar2(1);
    l_revision_control_code_destin NUMBER;

    l_default_source_status_id NUMBER;
    l_default_source_status varchar2(1);

    l_default_destin_status_id NUMBER;
    l_default_destin_status varchar2(1);
    l_lot_destin_status varchar2(1);
    l_lot_control_code_destin NUMBER;
    l_serial_control_code_destin NUMBER;
    l_grade_code VARCHAR2(150);

    l_onhand_source_status_id NUMBER;
    l_onhand_destin_status_id NUMBER;
    l_locator_control_code  NUMBER;

    l_go    BOOLEAN := TRUE;
    l_sqoh                NUMBER;
    l_srqoh               NUMBER;
    l_sqr                 NUMBER;
    l_sqs                 NUMBER;
    l_satt                NUMBER;
    l_satr                NUMBER;
    l_qoh                 NUMBER;
    l_rqoh                NUMBER;
    l_qr                  NUMBER;
    l_qs                  NUMBER;
    l_att                 NUMBER;
    l_atr                 NUMBER;
    l_return_status       VARCHAR2(1)  ;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_revision_control    BOOLEAN;
    l_serial_control      BOOLEAN;
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success ;
      x_post_action := 'N' ;
      --First get the value of move different status parameter.
      --Printing all input parameters to debug file

       if (g_debug = 1) then
            inv_trx_util_pub.TRACE('inside check_move_diff: p_org_id = ' || p_org_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_inventory_item_id = '|| p_inventory_item_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_subinventory_code = ' || p_subinventory_code, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_locator_id = '|| p_locator_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_transfer_org_id = ' || p_transfer_org_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_transfer_subinventory = '|| p_transfer_subinventory, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_transfer_locator_id = ' || p_transfer_locator_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_lot_number = '|| p_lot_number, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_transaction_action_id = ' || p_transaction_action_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_object_type = '|| p_object_type, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_lpn_id = ' || p_lpn_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_demand_src_header_id = '|| p_demand_src_header_id, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_revision = ' || p_revision, 'INV_MATERIAL_STATUS_GRP', 9);
            inv_trx_util_pub.TRACE('inside check_move_diff: p_primary_quantity = ' || p_primary_quantity, 'INV_MATERIAL_STATUS_GRP', 9);
       end if;


      l_org_id := p_org_id ;
      IF p_transaction_action_id IN (2 ,28,50,51,52) THEN
         l_transfer_org_id := p_org_id;
      ELSIF p_transaction_action_id IN ( 3 ,21) THEN
         l_transfer_org_id := p_transfer_org_id;
      END IF;

    /*BEGIN
           SELECT   allow_different_status
           INTO     l_allow_different_status
           FROM     mtl_parameters
           WHERE    organization_id = l_transfer_org_id ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_allow_different_status := 1;
      END; */

      /*Using inv chache instead of running above query every time */
      IF inv_cache.set_org_rec(l_transfer_org_id) THEN
                l_allow_different_status := NVL(inv_cache.org_rec.allow_different_status,1);
      END IF;

      if (g_debug = 1) then
            inv_trx_util_pub.TRACE('inside check_move_diff: l_allow_different_status = ' || l_allow_different_status, 'INV_MATERIAL_STATUS_GRP', 9);
      end if;
      --Correcting below if condition as OR clause is not needed.Transfer subinventory has to be not null irrespective of transaction action.
      --IF (p_transfer_subinventory IS NOT NULL OR p_transaction_action_id = 21 )
      IF p_transfer_subinventory IS NOT NULL
         AND NVL(l_allow_different_status , 1) <> 1
         AND p_transaction_action_id IN (3, 21 ,2 ,28)
      THEN
        l_locator_control_code := get_locator_control(
                                    l_transfer_org_id
                                  , p_inventory_item_id
                                  , p_transfer_subinventory);

        --Get lot and serial control for item from source and destination orgs:

        IF inv_cache.set_item_rec(l_org_id,p_inventory_item_id) THEN
           l_lot_source_status           := NVL(inv_cache.item_rec.LOT_STATUS_ENABLED,'N');
           l_lot_control_code_source     := NVL(inv_cache.item_rec.LOT_CONTROL_CODE,1);
           l_serial_control_code_source  := NVL(inv_cache.item_rec.SERIAL_NUMBER_CONTROL_CODE,1);
        END IF;

        IF inv_cache.set_item_rec(l_transfer_org_id,p_inventory_item_id) THEN
           l_revision_control_code_destin := NVL(inv_cache.item_rec.REVISION_QTY_CONTROL_CODE,1);
           l_lot_destin_status  := NVL(inv_cache.item_rec.LOT_STATUS_ENABLED,'N');
           l_lot_control_code_destin     := NVL(inv_cache.item_rec.LOT_CONTROL_CODE,1);
           l_serial_control_code_destin  := NVL(inv_cache.item_rec.SERIAL_NUMBER_CONTROL_CODE,1);
        END IF;

        if (g_debug = 1) then

           inv_trx_util_pub.TRACE('inside check_move_diff: object_type = ' || p_object_type, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_lot_source_status = '||l_lot_source_status, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_lot_control_code_source = '||l_lot_control_code_source, 'INV_MATERIAL_STATUS_GRP', 9);

           inv_trx_util_pub.TRACE('inside check_move_diff: l_serial_control_code_source = ' || l_serial_control_code_source, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_revision_control_code_destin = '||l_revision_control_code_destin, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_lot_destin_status = '||l_lot_destin_status, 'INV_MATERIAL_STATUS_GRP', 9);

           inv_trx_util_pub.TRACE('inside check_move_diff: l_lot_control_code_destin = ' || l_lot_control_code_destin, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_serial_control_code_destin= '||l_serial_control_code_destin, 'INV_MATERIAL_STATUS_GRP', 9);
           inv_trx_util_pub.TRACE('inside check_move_diff: l_locator_control_code = '||l_locator_control_code, 'INV_MATERIAL_STATUS_GRP', 9);

        end if;

        IF  (
               (
                    ( p_object_type = 'Z' AND p_transfer_subinventory IS NOT NULL
                      AND NVL(l_locator_control_code,1 )= 1 )
                 OR ( p_object_type = 'L' AND p_transfer_locator_id IS NOT NULL)
               )
               AND NVL(l_lot_control_code_source,1) <> 2
            )
            OR
            ( p_object_type = 'O' AND p_lot_number IS NOT NULL)
            THEN
              IF inv_cache.set_org_rec(l_org_id) THEN
                l_default_source_status_id := NVL(inv_cache.org_rec.default_status_id,0);
                IF l_default_source_status_id <> 0 THEN
                  l_default_source_status := 'Y';
                ELSE
                  l_default_source_status := 'N';
                END IF;
              END IF;

              IF inv_cache.set_org_rec(l_transfer_org_id) THEN
                l_default_destin_status_id := NVL(inv_cache.org_rec.default_status_id,0);
                IF l_default_destin_status_id <> 0 THEN
                  l_default_destin_status := 'Y';
                ELSE
                  l_default_destin_status := 'N';
                END IF;
              END IF;

              if (g_debug = 1) then
              inv_trx_util_pub.TRACE('inside check_move_diff: l_default_source_status = ' || l_default_source_status, 'INV_MATERIAL_STATUS_GRP', 9);
              inv_trx_util_pub.TRACE('inside check_move_diff: l_default_destin_status = ' ||l_default_destin_status, 'INV_MATERIAL_STATUS_GRP', 9);
               end if;

              IF (l_default_source_status = 'Y' AND l_default_destin_status ='Y') THEN
              -- AND NVL(l_allow_different_status,1) = 2) --(O,O) Third if
                /*Bug 8201152: Commenting above AND clause */

              -- If both the organizations are onhand status controlled
              -- then get the status from corresponding SKU's and compare.

                if (g_debug = 1) then
                inv_trx_util_pub.TRACE('Inside O=O', 'INV_MATERIAL_STATUS_GRP', 9);
                end if ;
                IF  l_serial_control_code_source IN (1,6) AND l_serial_control_code_destin IN (1,6) THEN
                  --Get onhand status id from source org.

                  inv_material_status_grp.get_onhand_status_id
                   (  p_organization_id   => l_org_id
                    , p_inventory_item_id => p_inventory_item_id
                    , p_subinventory_code => p_subinventory_code
                    , p_locator_id        => p_locator_id
                    , p_lot_number        => p_lot_number
                    , p_lpn_id            => p_lpn_id
                    , x_onhand_status_id  => l_onhand_source_status_id );


                  --Get onhand status id from destination org.
                  inv_material_status_grp.get_onhand_status_id
                   (  p_organization_id   => l_transfer_org_id
                    , p_inventory_item_id => p_inventory_item_id
                    , p_subinventory_code => p_transfer_subinventory
                    , p_locator_id        => p_transfer_locator_id
                    , p_lot_number        => p_lot_number
                    , p_lpn_id            => p_lpn_id
                    , x_onhand_status_id  => l_onhand_destin_status_id );

                  if (g_debug = 1) then
                    inv_trx_util_pub.TRACE('inside check_move_diff: l_onhand_source_status_id = ' || l_onhand_source_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                    inv_trx_util_pub.TRACE('inside check_move_diff: l_onhand_destin_status_id = '||l_onhand_destin_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                  end if;

                  -- Correcting nvl condition
                  IF     NVL(l_onhand_source_status_id , 0)  = 0    --no onhand in source org
                      OR NVL(l_onhand_destin_status_id , 0)  = 0    --no onhand in destin org
                      OR NVL(l_onhand_source_status_id , 0)  = NVL(l_onhand_destin_status_id, 0)
                  THEN
                      l_go := TRUE;
                  ELSE
                      l_go := FALSE;
                  END IF ;

                END IF ;   --IF  l_serial_control_code_source IN (1,6)

              ELSIF ( l_lot_source_status = 'Y' AND l_default_destin_status = 'Y') THEN
               IF p_object_type = 'O' THEN
              --AND NVL(l_allow_different_status,1) = 2)
               /*Bug 7833168 :Commenting above AND clause */
               --(L ,0)
                if (g_debug = 1) then
                inv_trx_util_pub.TRACE('Inside L-O', 'INV_MATERIAL_STATUS_GRP', 9);
                end if ;
                -- In source org, item is lot status enabled and destination org is onhand so
                -- get the lot status from source org and MOQD status from destination org
                IF  l_serial_control_code_destin IN (1,6) THEN
                  BEGIN
                    SELECT status_id
                    INTO   l_lot_status_id
                    FROM   mtl_lot_numbers
                    WHERE  organization_id   = l_org_id
                      AND  inventory_item_id = p_inventory_item_id
                      AND  lot_number        = p_lot_number;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_lot_status_id := 0;
                  END;

                  inv_material_status_grp.get_onhand_status_id
                   ( p_organization_id    => l_transfer_org_id
                   , p_inventory_item_id  => p_inventory_item_id
                   , p_subinventory_code  => p_transfer_subinventory
                   , p_locator_id         => p_transfer_locator_id
                   , p_lot_number         => p_lot_number
                   , p_lpn_id             => p_lpn_id
                   , x_onhand_status_id   => l_onhand_destin_status_id );

                  if (g_debug = 1) then
                    inv_trx_util_pub.TRACE('inside check_move_diff: l_lot_status_id = ' || l_lot_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                    inv_trx_util_pub.TRACE('inside check_move_diff: l_onhand_destin_status_id = '|| l_onhand_destin_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                  end if;

                  -- Correcting nvl condition
                  IF     NVL(l_lot_status_id, 0) = 0              -- lot doesnt exists in source org
                     OR  NVL(l_onhand_destin_status_id,0) = 0     -- No onhand in destin org
                     OR  NVL(l_lot_status_id,0) = NVL(l_onhand_destin_status_id,0)
                  THEN
                     l_go := TRUE;
                  ELSE
                     l_go := FALSE;
                  END IF ;

                END IF ; -- IF  l_serial_control_code_destin IN (1,6) THEN
               END IF ; --IF p_object_type = 'O' THEN
              ELSIF (l_default_source_status = 'Y' AND l_lot_destin_status = 'Y') THEN
               IF p_object_type = 'O' THEN
              --(O,L)
                if (g_debug = 1) then
                inv_trx_util_pub.TRACE('Inside O-L', 'INV_MATERIAL_STATUS_GRP', 9);
                end if ;
              -- source org is onhand status enabled and destination is lot status enabled
              -- Check onhand status id from source org and lot status id from destination org

                IF  l_serial_control_code_source IN (1,6) THEN
                   inv_material_status_grp.get_onhand_status_id
                     (  p_organization_id   => l_org_id
                      , p_inventory_item_id => p_inventory_item_id
                      , p_subinventory_code => p_subinventory_code
                      , p_locator_id        => p_locator_id
                      , p_lot_number        => p_lot_number
                      , p_lpn_id            => p_lpn_id
                      , x_onhand_status_id  => l_onhand_source_status_id);

                   BEGIN
                     SELECT   status_id, grade_code
                       INTO   l_lot_status_id, l_grade_code
                       FROM   mtl_lot_numbers
                       WHERE  organization_id   = l_transfer_org_id
                         AND  inventory_item_id = p_inventory_item_id
                         AND  lot_number        = p_lot_number;
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       l_lot_status_id := 0;
                   END;

                   if (g_debug = 1) then
                   inv_trx_util_pub.TRACE('l_onhand_source_status_id'||l_onhand_source_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                   inv_trx_util_pub.TRACE('l_lot_status_id' || l_lot_status_id, 'INV_MATERIAL_STATUS_GRP', 9);
                   end if ;
                   -- Correcting nvl condition
                   IF   NVL(l_onhand_source_status_id,0)= 0
                     OR NVL(l_lot_status_id ,0) = 0
                     OR NVL(l_lot_status_id,0) = NVL(l_onhand_source_status_id,0)
                   THEN
                      l_go := TRUE ;
                   ELSIF l_allow_different_status = 3 THEN

                      IF NVL(l_revision_control_code_destin,1) = 1 THEN
                         l_revision_control := FALSE;
                      ELSE
                         l_revision_control := TRUE;
                      END IF;
                      IF l_serial_control_code_destin IN (1, 6) THEN
                         l_serial_control := FALSE;
                      ELSE
                         l_serial_control := TRUE;
                      END IF;

                      inv_quantity_tree_pub.query_quantities
                      (
                        p_api_version_number    =>   1.0
                      , p_init_msg_lst          =>   'T'
                      , x_return_status         =>   l_return_status
                      , x_msg_count             =>   l_msg_count
                      , x_msg_data              =>   l_msg_data
                      , p_organization_id       =>   l_transfer_org_id
                      , p_inventory_item_id     =>   p_inventory_item_id
                      , p_tree_mode             =>   1
                      , p_is_revision_control   =>   l_revision_control
                      , p_is_lot_control        =>   TRUE
                      , p_is_serial_control     =>   l_serial_control
                      , p_demand_source_type_id =>   p_demand_src_header_id
                      , p_revision              =>   p_revision
                      , p_lot_number            =>   p_lot_number
                      , p_subinventory_code     =>   p_transfer_subinventory
                      , p_locator_id            =>   p_transfer_locator_id
                      , p_onhand_source         =>   3
                      , x_qoh                   =>   l_qoh
                      , x_rqoh                  =>   l_rqoh
                      , x_qr                    =>   l_qr
                      , x_qs                    =>   l_qs
                      , x_att                   =>   l_att
                      , x_atr                   =>   l_atr
                      , p_grade_code            =>   l_GRADE_CODE
                      , x_sqoh                  =>   l_sqoh
                      , x_satt                  =>   l_satt
                      , x_satr                  =>   l_satr
                      , x_srqoh                 =>   l_srqoh
                      , x_sqr                   =>   l_sqr
                      , x_sqs                   =>   l_sqs
                      , p_lpn_id                     =>   null
                      , p_demand_source_header_id    => -1
                      , p_demand_source_line_id      => -1
                      , p_demand_source_name         => -1
                      );

                      IF l_return_status <> 'S' THEN
                          FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
                          FND_MESSAGE.set_token('token1','XACT_QTY1');
                          fnd_msg_pub.ADD;
                          RAISE fnd_api.g_exc_error;
                      END IF;

                     IF (g_debug = 1) then
                         inv_trx_util_pub.TRACE('l_qoh: '||l_qoh, 'INV_MATERIAL_STATUS_GRP', 9);
                         inv_trx_util_pub.TRACE('p_primary_quantity '|| p_primary_quantity, 'INV_MATERIAL_STATUS_GRP', 9);
                     END IF;
                     /* Added for bug#7833080 Start */
                     IF (p_transaction_action_id = 3) THEN
                         l_qoh := l_qoh + p_primary_quantity;
                      END IF ;
                      /*  bug#7833080 End */

                     IF nvl(l_qoh,0) = 0 THEN
                          l_go := TRUE;
                          x_post_action  := 'Y'  ;             --Added for bug7418564
                     ELSE
                          l_go := FALSE;
                     END IF;
                   ELSIF l_allow_different_status = 2 THEN
                   l_go := FALSE;
                   END IF ;         --IF  NVL(l_lot_status_id ,-1) = 0  OR ..

                END IF;  --IF  l_serial_control_code_source IN (1,6) THEN
               END IF; --IF p_object_type = 'O' THEN
             END IF ; --Third if
              IF NOT l_go THEN
                if (g_debug = 1) then
                inv_trx_util_pub.TRACE('Comingling Occurs', 'INV_MATERIAL_STATUS_GRP', 9);
                end if ;

                fnd_message.set_name('INV','INV_TXF_MOVE_DIFF_MAT_STAT');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF ;
        END IF ;--Second if

      END IF ; --First if
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END check_move_diff_status;

  --adding following procedure for lpn status project to get the lpn status
  PROCEDURE get_lpn_status
            (
            p_organization_id IN     NUMBER,
            p_lpn_id          IN     NUMBER,
            p_sub_code        IN     VARCHAR2 := NULL,
            p_loc_id          IN     NUMBER := NULL,
            p_lpn_context     IN     NUMBER,
            x_return_status_id OUT NOCOPY  NUMBER,
            x_return_status_code OUT NOCOPY VARCHAR2
            )
IS
   l_lpn_sub            VARCHAR2(30) ;
   l_lpn_loc            NUMBER;
   l_lpn_context        NUMBER;
   l_lpn_org_id         NUMBER;
   l_def_org_status     NUMBER;
   l_return_status_id   NUMBER  := NULL;
   l_return_status_code VARCHAR2(30) := NULL;
   l_counter            NUMBER    := 0;
   l_inventory_item_id  NUMBER;
   l_lot_number         NUMBER;
   l_lpn_id             NUMBER;
   l_lot_control_code   NUMBER;
   l_status_id          NUMBER  := NULL;
   l_serial_controlled NUMBER := 0;
   l_lot_controlled NUMBER := 0;
   l_serial_status_enabled NUMBEr := 0;

  CURSOR c_lpn_item
  IS
          SELECT  *
          FROM    wms_lpn_contents wlc
          WHERE   wlc.parent_lpn_id IN
                  (SELECT lpn_id
                   FROM wms_license_plate_numbers plpn
                   start with lpn_id = p_lpn_id
                   connect by parent_lpn_id = prior lpn_id
                  )
         ORDER BY wlc.serial_summary_entry DESC ;

        CURSOR mmtt_cur
        IS
                SELECT mmtt.transaction_temp_id , mmtt.subinventory_code ,
                       mmtt.locator_id , mmtt.inventory_item_id ,
                       mmtt.lpn_id , mmtt.item_lot_control_code
                FROM   mtl_material_transactions_temp mmtt
                WHERE  mmtt.transfer_lpn_id = p_lpn_id
      AND    NVL(mmtt.lpn_id,-99) <> p_lpn_id
      AND    NVL(mmtt.content_lpn_id,-99) <> p_lpn_id;
        CURSOR mtlt_cur(l_transaction_temp_id NUMBER)
        IS
                SELECT mtlt.lot_number
                FROM   mtl_transaction_lots_temp mtlt
                where transaction_temp_id = l_transaction_temp_id;
   CURSOR msn_cur(l_cur_lpn_id NUMBER , l_cur_inventory_item_id NUMBER)
   IS
      SELECT msn.status_id
      FROM mtl_serial_numbers msn
      where msn.inventory_item_id = l_cur_inventory_item_id
      AND   msn.lpn_id = l_cur_lpn_id;
    CURSOR msnt_cur(l_transaction_temp_id NUMBER)
     IS
       SELECT msn.status_id
       FROM mtl_serial_numbers  msn ,  mtl_serial_numbers_temp msnt
       WHERE  msnt.transaction_temp_id = l_transaction_temp_id
       AND msn.serial_number BETWEEN msnt.fm_serial_number AND msnt.to_serial_number;



BEGIN
   if(g_debug = 1)THEN
      inv_trx_util_pub.TRACE('In get_lpn_status','INV_MATERIAL_STATUS_GRP',9);
   END if;
   l_lpn_org_id  := p_organization_id;
   l_lpn_sub := p_sub_code;
   l_lpn_loc := p_loc_id;
   l_lpn_context := p_lpn_context;
   IF(l_lpn_sub IS NULL or l_lpn_loc IS NULL or l_lpn_context IS NULL)    THEN

         BEGIN
            SELECT wlpn.organization_id , wlpn.subinventory_code , wlpn.locator_id , wlpn.lpn_context into
                   l_lpn_org_id , l_lpn_sub ,l_lpn_loc ,l_lpn_context
            FROM   wms_license_plate_numbers wlpn
                   where lpn_id = p_lpn_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if(g_debug = 1)THEN
                  inv_trx_util_pub.TRACE('Unable to find the LPN''INV_MATERIAL_STATUS_GRP',9);
               END IF;
               x_return_status_code := NULL;
               x_return_status_id :=NULL;
               RETURN;
         END;
    END IF;
    IF l_lpn_context IN (WMS_Container_PUB.LPN_CONTEXT_PREGENERATED,
                             WMS_Container_PUB.LPN_CONTEXT_VENDOR) THEN
      IF(g_debug = 1)THEN
       inv_trx_util_pub.TRACE('LPN CONTEXT IS '||l_lpn_context||' Status should be NULL for that','INV_MATERIAL_STATUS_GRP',9);
      END IF;
      l_return_status_id := NULL; --if lpn_context is 5 or 7 lpn status should be NULL
    ELSIF l_lpn_context IN (WMS_Container_PUB.LPN_CONTEXT_STORES,
                           WMS_Container_PUB.LPN_CONTEXT_INTRANSIT) THEN

         SELECT  default_status_id
         INTO    l_def_org_status
         FROM    mtl_parameters
         WHERE   organization_id = l_lpn_org_id;
      IF(g_debug = 1)THEN
         inv_trx_util_pub.TRACE('LPN CONTEXT IS '||l_lpn_context|| ' Status should be default org level staus  which is '||l_return_status_id,'INV_MATERIAL_STATUS_GRP',9);
      END IF;
      l_return_status_id := l_def_org_status; --If lpn_context is 4 or 6 lpn status should be derived from default org parameters
   ELSE

                 IF (l_lpn_context = WMS_Container_PUB.LPN_CONTEXT_PACKING )THEN--wlc don't exists for the lpn therefore checking mmtt
          IF(g_debug = 1)THEN
                           inv_trx_util_pub.TRACE('WLC is not there and no child record is there for the lpn therefor querying mmtt for details','INV_MATERIAL_STATUS_GRP',9);
          END IF;
                        FOR l_mmtt_cur IN mmtt_cur
                        LOOP
              l_serial_status_enabled := 0;
              l_serial_controlled := 0;
              l_lot_controlled := 0;
              IF inv_cache.set_item_rec(l_lpn_org_id, l_mmtt_cur.inventory_item_id) THEN
                 IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                   l_serial_controlled := 1; -- Item is serial controlled
                    IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                       l_serial_status_enabled := 1;
                     END IF;
                 END IF;
                 IF (inv_cache.item_rec.lot_control_code = 2) THEN
                    l_lot_controlled := 1;
                 END IF;
             END IF;

                                IF (l_lot_controlled = 1 AND l_serial_controlled = 0) THEN
                                --item is lot controlled so need to loop through mtlt also
                                        FOR l_mtlt_cur IN mtlt_cur(l_mmtt_cur.transaction_temp_id)
                                        LOOP
                                                l_counter := l_counter + 1;
                                                l_return_status_id  := INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                                                                                               (p_organization_id   => p_organization_id,
                                                                                               p_inventory_item_id => l_mmtt_cur.inventory_item_id,
                                                                                               p_sub_code => l_mmtt_cur.subinventory_code,
                                                                                               p_loc_id => l_mmtt_cur.locator_id,
                                                                                               p_lot_number => l_mtlt_cur.lot_number,
                                                                                               p_lpn_id => l_mmtt_cur.lpn_id,
                                                                                               p_transaction_action_id=> NULL,
                                                                                               p_src_status_id => NULL);
                                                IF l_counter = 1 THEN
                                                -- Assigning status for the first time
                                                        l_status_id := l_return_status_id;
                                                END IF;
                                                IF NVL(l_return_status_id,-99) <> NVL(l_status_id,-99) THEN --checking current status from the first status
                                                --There are mixed status so returning -1 and exiting the loop
                                                    l_return_status_id := -1;
                       IF(g_debug = 1)THEN
                           inv_trx_util_pub.TRACE('lpn has item of mixed statuses so returning mixed at 1','INV_MATERIAL_STATUS_GRP',9);
                       END IF;
                                                    EXIT;
                                                END IF;
                                        END LOOP; --mtlt_cur loop finished
            ELSIF (l_serial_controlled = 1) THEN
               IF (l_serial_status_enabled = 1) THEN
                FOR l_msnt_cur IN msnt_cur(l_mmtt_cur.transaction_temp_id) LOOP
                    l_counter := l_counter + 1;
                    l_return_status_id := l_msnt_cur.status_id;
                    IF l_counter = 1 THEN
                      -- Assigning status for the first time
                          l_status_id := l_return_status_id;
                    END IF;
                    IF l_return_status_id <> l_status_id THEN --checking current status from the first status
                      --There are mixed status so returning -1 and exiting the loop
                        l_return_status_id := -1;
                         IF(g_debug = 1)THEN
                           inv_trx_util_pub.TRACE('lpn has item of mixed statuses so returning mixed at 2','INV_MATERIAL_STATUS_GRP',9);
                         END IF;
                        EXIT;
                    END IF;
                                              END LOOP; --l_msnt_cur loop finished
              END IF;

                                ELSE
                                        l_counter := l_counter + 1;
                                        l_return_status_id :=
                  INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                         (p_organization_id   => p_organization_id,
                         p_inventory_item_id => l_mmtt_cur.inventory_item_id,
                         p_sub_code => l_mmtt_cur.subinventory_code,
                         p_loc_id => l_mmtt_cur.locator_id,
                         p_lot_number => NULL,
                         p_lpn_id => l_mmtt_cur.lpn_id,
                         p_transaction_action_id=> NULL,
                         p_src_status_id => NULL);

                                                IF l_counter = 1 THEN
                                                        l_status_id := l_return_status_id;
                                                END IF;
                                                IF NVL(l_return_status_id,-99) <> NVL(l_status_id,-99) THEN
                                                    l_return_status_id := -1;

                                                END IF;
                                END IF;
                                IF l_return_status_id = -1 THEN
                                   EXIT ;
                                 END IF;
    END LOOP;--mmtt_cur loop finished
  END IF;


                IF(NVL(l_return_status_id ,-99)<> -1) THEN
                        FOR l_cur_wlc IN c_lpn_item
                        LOOP
          l_serial_controlled := 0;
          l_serial_status_enabled := 0;
           IF inv_cache.set_item_rec(p_organization_id, l_cur_wlc.inventory_item_id) THEN
               IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                   l_serial_controlled := 1; -- Item is serial controlled
               END IF;
               IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                  l_serial_status_enabled := 1;
               END IF;
            END IF;
           IF (l_serial_controlled <> 1) then
               l_counter           := l_counter + 1;
               l_return_status_id  :=
               INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                       (p_organization_id   => p_organization_id,
                        p_inventory_item_id => l_cur_wlc.inventory_item_id,
                        p_sub_code => l_lpn_sub,
                        p_loc_id => l_lpn_loc,
                        p_lot_number => l_cur_wlc.lot_number,
                        p_lpn_id => l_cur_wlc.parent_lpn_id,
                        p_transaction_action_id=> NULL, p_src_status_id => NULL);

               IF (l_counter = 1) THEN
                  l_status_id := l_return_status_id ; --assigning it for the first to check further if all the statuses are same or not
               END IF;
               IF (NVL(l_status_id,-99) <> NVL(l_return_status_id,-99)) THEN
                  IF(g_debug = 1)THEN
                     inv_trx_util_pub.TRACE('lpn has item of mixed statuses so returning mixed at 3','INV_MATERIAL_STATUS_GRP',9);
                  END IF;
                  l_return_status_id := -1;
               END IF;
          ELSE --item is serial controlled therefor checkin msn for status
            IF(l_serial_status_enabled = 1) THEN
                 FOR l_msn_cur in msn_cur(l_cur_wlc.parent_lpn_id , l_cur_wlc.inventory_item_id) loop
                    l_counter := l_counter + 1;
                    l_return_status_id := l_msn_cur.status_id;
                     IF(l_counter = 1) Then
                        l_status_id := l_return_status_id ;
                     END IF;
                     IF(NVL(l_return_status_id,-99) <> NVL(l_status_id,-99)) THEN
                        l_return_status_id := -1;
                        EXIT;
                     END IF;
                  END LOOP; --exiting msn_cur
              END IF;
           END IF;
           IF(NVL(l_return_status_id,-99) = -1) THEN
              EXIT;
           END IF;
           END LOOP; --exiting c_lpn_item
         END IF;
        END IF;

        If (l_return_status_id  IS NOT NULL  AND l_return_status_id <> -1) THEN
      BEGIN
         SELECT  status_code
         INTO    l_return_status_code
         FROM    mtl_material_statuses
         WHERE   status_id =l_return_status_id ;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_return_status_id := NULL; --as status_id is not found in mtl_material_statuses therefore returning NULL
           l_return_status_code := NULL;
      END;
        ELSIF (NVL(l_return_status_id,-99) = -1)THEN
         l_return_status_code := FND_MESSAGE.get_string('WMS','WMS_LPN_STATUS_MIXED');
     END IF;
   IF(g_debug = 1)THEN
           inv_trx_util_pub.TRACE('Return Status id is  '||l_return_status_id||' Return staus code is '||l_return_status_code,'INV_MATERIAL_STATUS_GRP',9);
   END IF;
        x_return_status_id   := l_return_status_id;
        x_return_status_code := l_return_status_code;
END get_lpn_status;

--end of lpn status project
/* -- LPN Status Project --*/
FUNCTION Status_Commingle_Check (
            p_item_id                     IN            NUMBER
          , p_lot_number                  IN            VARCHAR2 := NULL
          , p_org_id                      IN            NUMBER
          , p_trx_action_id               IN            NUMBER
          , p_subinv_code                 IN            VARCHAR2
          , p_tosubinv_code               IN            VARCHAR2 := NULL
          , p_locator_id                  IN            NUMBER := NULL
          , p_tolocator_id                IN            NUMBER := NULL
          , p_xfr_org_id                  IN            NUMBER := NULL
          , p_from_lpn_id                 IN            NUMBER := NULL
          , p_cnt_lpn_id                  IN            NUMBER := NULL
          , p_xfr_lpn_id                  IN            NUMBER := NULL )

RETURN VARCHAR2
IS

CURSOR c_wlc_status IS
SELECT moqd.inventory_item_id inventory_item_id,moqd.lot_number lot_number,moqd.status_id status_id
        FROM mtl_onhand_quantities_detail moqd, wms_lpn_contents wlc
        WHERE moqd.organization_id = p_org_id
                AND moqd.inventory_item_id = nvl(p_item_id,moqd.inventory_item_id)
                            AND moqd.subinventory_code = p_subinv_code
                            AND moqd.locator_id = p_locator_id
                            AND moqd.lpn_id = p_from_lpn_id
                            AND moqd.containerized_flag = 1
                            AND wlc.parent_lpn_id=moqd.lpn_id
                            AND wlc.inventory_item_id=nvl(p_item_id,wlc.inventory_item_id)
                            AND wlc.serial_summary_entry <> 1 -- To query only non serial controlled items.
          GROUP BY moqd.inventory_item_id,moqd.lot_number,moqd.status_id;

l_source_status_id  NUMBER ;
l_count NUMBER;
l_comingle VARCHAR2(1):= 'N' ;
l_allow_diff_status       VARCHAR2(1) ;
l_progress VARCHAR2(15);
--l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
/* Have to check the exact meaning of With Exception for plain items.*/
/*
      l_allow_diff_status  -->     1   Means 'Yes'
      l_allow_diff_status  -->     2   Means 'No'
      l_allow_diff_status  -->     3   Means 'With Exception'
      l_allow_diff_status  -->  Null   Means 'Yes'
*/
    BEGIN
        SELECT Nvl(allow_different_status,1) INTO l_allow_diff_status
        FROM mtl_parameters
        WHERE organization_id =p_xfr_org_id ;

        IF(g_debug = 1)THEN
            inv_trx_util_pub.TRACE('Status_Commingle_Check: allow_different_status: '||l_allow_diff_status, 1);
        END IF;
        IF l_allow_diff_status<>1 THEN
            l_comingle:='Y';
          END IF;
    EXCEPTION
    WHEN OTHERS THEN
      IF (g_debug = 1) THEN
          l_progress := 'WMSSCC-0001';
          IF(g_debug = 1)THEN
            inv_trx_util_pub.TRACE('Status_Commingle_Check:  allow_different_status is not available'||l_progress, 1);
           END IF;
      END IF;
    END;

IF l_comingle = 'Y' THEN
    if (p_from_lpn_id is null and p_cnt_lpn_id is null ) then   /* Non LPN transaction */
        l_comingle := 'N'; --added for 6868145
                /*
                ** Look at MTL_ONHAND_QUANTIES, the on hand table for the source status
      Loose -> Loose
      Loose -> LPN (Like packing Trx)
                */
       BEGIN
        SELECT nvl(status_id,-9999) INTO l_source_status_id
        FROM mtl_onhand_quantities_detail
        WHERE organization_id = p_org_id
            AND inventory_item_id  = p_item_id
              AND (lot_number = p_lot_number
                           OR (lot_number is null and p_lot_number is NULL))
                AND subinventory_code = p_subinv_code
                AND  locator_id = p_locator_id
                      AND lpn_id is NULL
              AND containerized_flag = 2 --  (loose material)
          AND ROWNUM=1;


       EXCEPTION

       WHEN No_Data_Found THEN
         IF(g_debug = 1)THEN
           inv_trx_util_pub.TRACE('No onhand is available with this combination ');
         END IF;

       WHEN too_many_rows THEN
          l_source_status_id := NULL;
          l_progress := 'WMSSCC-0002';
       IF(g_debug = 1)THEN
        inv_trx_util_pub.TRACE('Status_Commingle_Check: More than one status for the comming material: ', 1);
        inv_trx_util_pub.TRACE('l_progress: '|| l_progress,1);
       END IF;
       RAISE fnd_api.g_exc_error;
        WHEN OTHERS THEN
               l_progress := 'WMSSCC-0003';
               l_source_status_id := null;
              inv_trx_util_pub.TRACE('l_progress: '|| l_progress,1);
             RAISE fnd_api.g_exc_error;
       END;

      IF l_source_status_id <> -9999 and p_item_id is not null THEN
        BEGIN
          SELECT 'Y' INTO l_comingle
                            FROM DUAL WHERE EXISTS
                            (SELECT 1
                            FROM mtl_onhand_quantities_detail
                            WHERE organization_id = p_xfr_org_id
                            AND inventory_item_id  = p_item_id
                            AND (lot_number = p_lot_number
                                OR (lot_number is null and p_lot_number is null))
                            AND subinventory_code = p_tosubinv_code
                            AND  locator_id = p_tolocator_id
                            AND Nvl(lpn_id,-9999)=Nvl(p_xfr_lpn_id,-9999)
                            AND l_source_status_id <> Nvl(status_id,-9999));


        EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_comingle := 'N';
        END;
     END IF ;  -- IF l_source_status_id IS NOT NULL


    ELSIF p_cnt_lpn_id IS NOT NULL THEN
       -- Entire LPN is moving so we need not worry abt comingling.
       l_comingle := 'N';
    ELSIF p_from_lpn_id IS NOT NULL THEN
      -- LPN -> Loose  (Like Unpacking Trx)
      -- LPN -> LPN    ( Like moving material from one LPN to another LPN)
       l_comingle := 'N';  -- if the following loop contains zero records then default we have to throw is 'N'
                           -- This case will occure if LPN contains all serial controlled items.
        FOR l_wlc_rec IN c_wlc_status() LOOP
         BEGIN
        IF(g_debug = 1)THEN
         inv_trx_util_pub.TRACE('In loop ');
         inv_trx_util_pub.TRACE('p_xfr_org_id: ' ||p_xfr_org_id);
         inv_trx_util_pub.TRACE('l_wlc_rec.inventory_item_id: '||l_wlc_rec.inventory_item_id);
         inv_trx_util_pub.TRACE('Lot number: '||l_wlc_rec.lot_number);
         inv_trx_util_pub.TRACE('p_tosubinv_code: '||p_tosubinv_code);
         inv_trx_util_pub.TRACE('p_tolocator_id: '||p_tolocator_id);
         inv_trx_util_pub.TRACE('p_xfr_lpn_id: '||p_xfr_lpn_id);
         inv_trx_util_pub.TRACE('l_wlc_rec.status_id: '||l_wlc_rec.status_id);
        END IF;

          SELECT 'Y' INTO l_comingle
                            FROM DUAL WHERE EXISTS
                            (SELECT 1
                            FROM mtl_onhand_quantities_detail
                            WHERE organization_id = p_xfr_org_id
                            AND inventory_item_id  =l_wlc_rec.inventory_item_id
                            AND Nvl(lot_number,'@@@@') = Nvl(l_wlc_rec.lot_number,'@@@@')
                            AND subinventory_code = p_tosubinv_code
                            AND  locator_id = p_tolocator_id
                            AND Nvl(lpn_id,-9999) =Nvl(p_xfr_lpn_id,-9999)
           AND nvl(status_id,-9999)<>nvl(l_wlc_rec.status_id,-9999));
           EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  l_comingle := 'N';
           END;


          IF l_comingle='Y' THEN
             EXIT;
          END IF;

        END LOOP;
 END IF; -- if (p_from_lpn_id is null and p_cnt_lpn_id is null  and p_xfr_lpn_id is null )

 END IF;    -- IF l_comingle = 'Y' THEN

      RETURN l_comingle;
EXCEPTION
   WHEN OTHERS THEN
    IF(g_debug = 1)THEN
    inv_trx_util_pub.TRACE('l_progress: '|| l_progress,1);
    END IF;
    RAISE fnd_api.g_exc_error;
END Status_Commingle_Check;


FUNCTION is_trx_allow_lpns(
p_wms_installed              IN VARCHAR2,
p_trx_status_enabled         IN NUMBER,
p_trx_type_id                IN NUMBER,
p_lot_status_enabled         IN VARCHAR2,
p_serial_status_enabled      IN VARCHAR2,
p_organization_id            IN NUMBER,
p_inventory_item_id          IN NUMBER,
p_sub_code                   IN VARCHAR2,
p_locator_id                 IN NUMBER,
p_lot_number                 IN VARCHAR2,
p_serial_number              IN VARCHAR2,
p_object_type                IN VARCHAR2,
p_fromlpn_id                 IN NUMBER,
p_xfer_lpn_id                IN NUMBER,
p_xfer_sub_code              IN VARCHAR2,
p_xfer_locator_id            IN NUMBER,
p_xfer_org_id                IN NUMBER)
RETURN NUMBER IS

l_allow_mixed_status  number :=  NVL(FND_PROFILE.VALUE('WMS_ALLOW_MIXED_STATUS'),2);
l_lpn_context         number;
l_return_status       number :=-1;
l_lpn_loc             number;
l_lpn_sub             VARCHAR2(30);
l_lpn_org_id          number;
l_trx_allowed         varchar2(1):='Y';
l_trx_allowed_count number :=0;
l_trx_not_allowed_count number :=0;
l_trx_allow      NUMBER:=0;
l_trx_type_id    NUMBER:=0;
c_api_name            varchar2(30) := 'is_trx_allow_lpns';
l_serial_controlled number;
l_serial_status_enabled number;
l_msg_count  number;
l_msg_data  varchar(30);
l_lot_controlled NUMBER:=0;

CURSOR l_lpn_mtrl(l_cur_inventory_item_id NUMBER)
IS
 SELECT  *
 FROM    mtl_txn_request_lines mtrl
 WHERE   mtrl.lpn_id IN
       (SELECT lpn_id
        FROM wms_license_plate_numbers plpn
        start with lpn_id = p_fromlpn_id
        connect by parent_lpn_id = prior lpn_id
       )
 AND Nvl(l_cur_inventory_item_id,inventory_item_id)=inventory_item_id
 AND organization_id=p_organization_id
 AND line_status=7;


 CURSOR c_lpn_item(l_cur_inventory_item_id NUMBER)
IS
  SELECT
  /*+ INDEX (WLC WMS_LPN_CONTENTS_N1) */
  *
FROM wms_lpn_contents wlc
WHERE wlc.parent_lpn_id IN
  (SELECT
    /*+ unnest cardinality(plpn, 1) */
    lpn_id
  FROM wms_license_plate_numbers plpn
    START WITH lpn_id        = p_fromlpn_id
    CONNECT BY parent_lpn_id = PRIOR lpn_id
  )
AND NVL (l_cur_inventory_item_id, inventory_item_id) = inventory_item_id
ORDER BY wlc.serial_summary_entry DESC ;


 CURSOR msn_cur(l_cur_lpn_id NUMBER , l_cur_inventory_item_id NUMBER)
 IS
    SELECT msn.status_id
    FROM mtl_serial_numbers msn
    where msn.inventory_item_id = l_cur_inventory_item_id
    AND   msn.lpn_id = l_cur_lpn_id;

CURSOR mmtt_cur(l_cur_inventory_item_id NUMBER)
   IS SELECT mmtt.transaction_temp_id , mmtt.subinventory_code,
           mmtt.transaction_type_id,
                       mmtt.locator_id , mmtt.inventory_item_id ,
                       nvl(mmtt.lpn_id,mmtt.content_lpn_id) lpn_id , mmtt.item_lot_control_code
                FROM   mtl_material_transactions_temp mmtt
                where  mmtt.transfer_lpn_id = p_fromlpn_id
    AND    mmtt.transaction_source_type_id = 2
                AND    mmtt.transaction_type_id = 52
    AND Nvl(l_cur_inventory_item_id,inventory_item_id)=inventory_item_id;

        CURSOR mtlt_cur(l_transaction_temp_id NUMBER)
        IS
                SELECT mtlt.lot_number
                FROM   mtl_transaction_lots_temp mtlt
                where transaction_temp_id = l_transaction_temp_id;

CURSOR msnt_cur(l_transaction_temp_id NUMBER)
     IS
       SELECT msn.status_id
       FROM mtl_serial_numbers  msn ,  mtl_serial_numbers_temp msnt
       WHERE  msnt.transaction_temp_id = l_transaction_temp_id
       AND msn.serial_number BETWEEN msnt.fm_serial_number AND msnt.to_serial_number;


-- CURSOR msnt_cur(l_transaction_temp_id NUMBER)
-- IS
--   SELECT msn.status_id
--  FROM mtl_serial_numbers  msn ,  mtl_serial_numbers_temp msnt
--   WHERE  msnt.transaction_temp_id = l_transaction_temp_id
--   AND msn.serial_number BETWEEN msnt.fm_serial_number AND msnt.to_serial_number;
BEGIN
IF(g_debug = 1)THEN
inv_trx_util_pub.TRACE(c_api_name||':Entered is_status_applicable  ', 'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_wms_installed: '||p_wms_installed,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_trx_status_enabled: '||p_trx_status_enabled,'inv_material_status_grps', 9);
inv_trx_util_pub.TRACE('p_trx_type_id: '||p_trx_type_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_lot_status_enabled: '||p_lot_status_enabled,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_serial_status_enabled: '||p_serial_status_enabled, 'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_organization_id: '||p_organization_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_inventory_item_id: '||p_inventory_item_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_sub_code: '||p_sub_code,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_locator_id: '||p_locator_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_lot_number: '||p_lot_number,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_serial_number: '||p_serial_number,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_object_type: '||p_object_type,'inv_material_status_grp', 9);

inv_trx_util_pub.TRACE('p_fromlpn_id: '||p_fromlpn_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_xfer_lpn_id: '||p_xfer_lpn_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_xfer_sub_code: '||p_xfer_sub_code,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_xfer_locator_id: '||p_xfer_locator_id,'inv_material_status_grp', 9);
inv_trx_util_pub.TRACE('p_xfer_org_id: '||p_xfer_org_id, 'inv_material_status_grp', 9);
END IF;

       BEGIN

            SELECT wlpn.organization_id , wlpn.subinventory_code , wlpn.locator_id , wlpn.lpn_context into
                  l_lpn_org_id , l_lpn_sub ,l_lpn_loc ,l_lpn_context
            FROM   wms_license_plate_numbers wlpn
            where lpn_id = p_fromlpn_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       IF(g_debug = 1)THEN
           inv_trx_util_pub.TRACE('Unable to find the LPN -- Error occured');
       END IF;
               RAISE fnd_api.g_exc_unexpected_error;

      END;

 IF(g_debug = 1)THEN
 inv_trx_util_pub.TRACE('LPN Context: '|| l_lpn_context,'inv_material_status_grp', 9);
 inv_trx_util_pub.TRACE('LPN Org Id: '|| l_lpn_org_id,'inv_material_status_grp', 9);
 inv_trx_util_pub.TRACE('LPN Sub: '|| l_lpn_sub,'inv_material_status_grp', 9);
 inv_trx_util_pub.TRACE('LPN Locator: '|| l_lpn_loc,'inv_material_status_grp', 9);
 END IF;

if l_lpn_context=WMS_Container_PUB.LPN_CONTEXT_INV then

IF p_trx_type_id IS NULL THEN
   -- This will execute only for Putaway pages not for cycle count pages.
   l_trx_type_id:=64; -- Move order Transfer
ELSE
  -- For Cycle count and physical count pages.
   l_trx_type_id:=p_trx_type_id;
END IF;
--call kamesh api
FOR l_cur_wlc IN c_lpn_item(p_inventory_item_id)
LOOP
IF(g_debug = 1)THEN
   inv_trx_util_pub.TRACE('In loop, Checking the material status for the item: '||l_cur_wlc.inventory_item_id);
END IF;
l_trx_allow := inv_material_status_grp.is_status_applicable_lpns(p_wms_installed => p_wms_installed,
                                        p_trx_status_enabled =>p_trx_status_enabled,
                                        p_trx_type_id           => l_trx_type_id,
                                        p_lot_status_enabled    => p_lot_status_enabled,
                                        p_serial_status_enabled => p_serial_status_enabled,
                                        p_organization_id       => p_organization_id,
                                        p_inventory_item_id     => l_cur_wlc.inventory_item_id,
                                        p_sub_code              => l_lpn_sub,
                                        p_locator_id            => l_lpn_loc,
                                        p_lot_number            => l_cur_wlc.lot_number,
                                        p_serial_number         => p_serial_number,
                                        p_object_type           => p_object_type,
                                        p_fromlpn_id            => p_fromlpn_id,
                                        p_xfer_lpn_id           => p_xfer_lpn_id,
                                        p_xfer_sub_code         => p_xfer_sub_code,
                                        p_xfer_locator_id       => p_xfer_locator_id,
                                        p_xfer_org_id           => p_xfer_org_id);

IF(g_debug = 1)THEN
   inv_trx_util_pub.TRACE('l_trx_allow status for the item: '||l_cur_wlc.inventory_item_id||' is: '|| l_trx_allow,'Material Status', 9);
END IF;

        if l_trx_allow=0 THEN
           l_trx_allowed_count := l_trx_allowed_count+1;
           if l_trx_not_allowed_count <> 0 then
              exit;
            end if;
        elsif l_trx_allow=2 then
           l_trx_not_allowed_count := l_trx_not_allowed_count+1;
           if l_trx_allowed_count <> 0 then
              exit;
            end if;
        end if;

END LOOP; --FOR l_cur_wlc IN c_lpn_item


elsif l_lpn_context= WMS_Container_PUB.LPN_CONTEXT_RCV or
      l_lpn_context= WMS_Container_PUB.LPN_CONTEXT_WIP then
-- LPN is in receiving or WIP
IF(g_debug = 1)THEN
    inv_trx_util_pub.TRACE('LPN is in Receiving:','inv_material_status_grp', 9);
END IF;

--IF p_trx_type_id IS NULL AND l_lpn_context= WMS_Container_PUB.LPN_CONTEXT_WIP THEN
   --p_trx_type_id:=43; -- WIP Component Return.
--END IF;


        FOR l_cur_mtrl IN l_lpn_mtrl(p_inventory_item_id)
         LOOP
         IF(g_debug = 1)THEN
              inv_trx_util_pub.TRACE('In loop, Checking the material status for the item: '||l_cur_mtrl.inventory_item_id);
         END IF;
               l_serial_controlled := 0;
               l_serial_status_enabled := 0;
                   IF inv_cache.set_item_rec(p_organization_id, l_cur_mtrl.inventory_item_id) THEN
                       IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                            l_serial_controlled := 1; -- Item is serial controlled
                        END IF;
                       IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                          l_serial_status_enabled := 1;
                       END IF;
                    END IF;
                IF (l_serial_controlled <> 1) then
                      -- Non serial controled item. It may be plain item or lot controlled item.
          IF(g_debug = 1)THEN
            inv_trx_util_pub.TRACE('Before calling get_default_status');
          END IF;
                 l_return_status  :=
                     INV_MATERIAL_STATUS_GRP.get_default_status
                       (p_organization_id   => p_organization_id,
                        p_inventory_item_id => l_cur_mtrl.inventory_item_id,
                        p_sub_code => l_lpn_sub,
                        p_loc_id => l_lpn_loc,
                        p_lot_number => l_cur_mtrl.lot_number,
                        p_lpn_id => l_cur_mtrl.lpn_id,
                        p_transaction_action_id=> NULL, p_src_status_id => NULL);
         IF(g_debug = 1)THEN
             inv_trx_util_pub.TRACE('Value of l_return_status: '||l_return_status);
         END IF;

                        l_trx_allowed := inv_material_status_grp.is_trx_allowed(
                         p_status_id            => l_return_status
                        ,p_transaction_type_id  => l_cur_mtrl.transaction_type_id
                        ,x_return_status        => l_trx_allowed
                        ,x_msg_count            => l_msg_count
                        ,x_msg_data             => l_msg_data);
          IF(g_debug = 1)THEN
             inv_trx_util_pub.TRACE('Value of l_trx_allowed: '||l_trx_allowed);
          END If;
                        if l_trx_allowed='Y' then
                         l_trx_allowed_count:=l_trx_allowed_count+1;
                          if l_trx_not_allowed_count > 0 then
                                exit;
                             end if;
                        ELSE
                          l_trx_not_allowed_count := l_trx_not_allowed_count+1;

                          if l_trx_allowed_count > 0 then
                               exit;
                           end if;

                        end if;

   ELSE           --IF (l_serial_controlled <> 1) then
               --item is serial controlled therefor checkin msn for status
                IF(l_serial_status_enabled = 1) THEN
                  FOR l_msn_cur in msn_cur(l_cur_mtrl.lpn_id , l_cur_mtrl.inventory_item_id) loop
                    --l_counter := l_counter + 1;
                    l_return_status := l_msn_cur.status_id;

                                l_trx_allowed := inv_material_status_grp.is_trx_allowed(
                                    p_status_id            => l_return_status
                                    ,p_transaction_type_id  => l_cur_mtrl.transaction_type_id
                                    ,x_return_status        => l_trx_allowed
                                    ,x_msg_count            => l_msg_count
                                  ,x_msg_data             => l_msg_data);

                                      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                          RAISE fnd_api.g_exc_unexpected_error;
                                      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                                          RAISE fnd_api.g_exc_error;
                                    END IF;

                         IF l_trx_allowed='N' THEN
                            l_trx_allowed_count := l_trx_allowed_count+1;
                             if l_trx_not_allowed_count > 0 then
                                exit;
                             end if;
                         ELSE
                            l_trx_not_allowed_count:=l_trx_not_allowed_count+1;
                             if l_trx_allowed_count > 0 then
                               exit;
                             end if;
                          END IF;
      END LOOP; --exiting msn_cur
                  END IF; -- IF(l_serial_status_enabled = 1)
 END IF; -- IF (l_serial_controlled <> 1) then

 IF(g_debug = 1)THEN
  inv_trx_util_pub.TRACE('Completed if condition execution');
 END IF;

      if l_trx_not_allowed_count>0 and l_trx_allowed_count>0 then
        exit;
       end if;
IF(g_debug = 1)THEN
   inv_trx_util_pub.TRACE('Completed one iteration');
END IF;
  END LOOP; --FOR l_cur_wlc IN c_lpn_item

--elsif l_lpn_context=WMS_Container_PUB.LPN_CONTEXT_PACKING then
-- LPN is in packing context.
--l_trx_allowed_count:=l_trx_allowed_count+1;
--l_trx_allowed_count:=l_trx_allowed_count-1;
elsif l_lpn_context=WMS_Container_PUB.LPN_CONTEXT_PACKING then
    inv_trx_util_pub.TRACE('LPN is in Packing context');
    inv_trx_util_pub.TRACE('Querying MMTT to get the status id and transaction type id');

        FOR l_mmtt_cur IN mmtt_cur(p_inventory_item_id)
                        LOOP
              l_serial_status_enabled := 0;
              l_serial_controlled := 0;
              l_lot_controlled := 0;
                        IF inv_cache.set_item_rec(l_lpn_org_id, l_mmtt_cur.inventory_item_id) THEN
                          IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                                l_serial_controlled := 1; -- Item is serial controlled
                              IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
                                l_serial_status_enabled := 1;
                              END IF;
                          END IF;
                          IF (inv_cache.item_rec.lot_control_code = 2) THEN
                              l_lot_controlled := 1;       -- item is lot controlled
                          END IF;
                       END IF;
             inv_trx_util_pub.TRACE('L_SERIAL_CONTROLLED_FLAG IS '||l_serial_controlled||'l_serial_status_enabled flag is '||l_serial_status_enabled,9);
         IF (l_lot_controlled = 1 AND l_serial_controlled = 0) THEN
           -- Item is lot controlled item. We are not taking care of both lot and serial controlled items.
            FOR l_mtlt_cur IN mtlt_cur(l_mmtt_cur.transaction_temp_id)
                                        LOOP
                l_return_status := INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                                                                                               (p_organization_id   => p_organization_id,
                                                                                               p_inventory_item_id => l_mmtt_cur.inventory_item_id,
                                                                                               p_sub_code => l_mmtt_cur.subinventory_code,
                                                                                               p_loc_id => l_mmtt_cur.locator_id,
                                                                                               p_lot_number => l_mtlt_cur.lot_number,
                                                                                               p_lpn_id => l_mmtt_cur.lpn_id,
                                                                                               p_transaction_action_id=> NULL,
                                                                                               p_src_status_id => NULL);




                        IF(g_debug = 1)THEN
                          inv_trx_util_pub.TRACE('Value of l_return_status: '||l_return_status);

                        END IF;

                  l_trx_allowed := inv_material_status_grp.is_trx_allowed(
                                                  p_status_id            => l_return_status
                                                  ,p_transaction_type_id  => l_mmtt_cur.transaction_type_id
                                                  ,x_return_status        => l_trx_allowed
                                                  ,x_msg_count            => l_msg_count
                                                  ,x_msg_data             => l_msg_data);
                        IF(g_debug = 1)THEN
                               inv_trx_util_pub.TRACE('Value of l_trx_allowed: '||l_trx_allowed);
                               --  inv_trx_util_pub.TRACE('Value of l_allow_transaction: '||l_allow_transaction);

                              END If;

                        /* BEGIN
                             SELECT 'N'
                                    INTO    l_allow_transaction
                                    FROM    dual
                                    WHERE   EXISTS
                                            (SELECT 1
                                            FROM    mtl_onhand_quantities_detail moqd,
                                                    mtl_status_transaction_control mtc
                                            WHERE   moqd.organization_id   = p_xfer_org_id
                                                AND moqd.inventory_item_id = l_mmtt_cur.inventory_item_id
                                                AND NVL(moqd.lot_number,'@@@') = NVL(l_mtlt_cur.lot_number,'@@@')
                                                AND moqd.lpn_id  = p_xfer_lpn_id
                                                AND moqd.status_id          = mtc.status_id
                                                AND mtc.transaction_type_id = l_mmtt_cur.transaction_type_id
                                                AND mtc.is_allowed          = 2
                                          ) ;
                             EXCEPTION
                             WHEN No_Data_Found THEN
                                  l_allow_transaction:='Y';
                             END;
                            */
                        if l_trx_allowed='Y' then
                                  l_trx_allowed_count:=l_trx_allowed_count+1;
                            if l_trx_not_allowed_count > 0 then
                                                  exit;
                                            end if;
                                    ELSE
                                      l_trx_not_allowed_count := l_trx_not_allowed_count+1;
                                if l_trx_allowed_count > 0 then
                                                      exit;
                                                end if;
                   end if;

             END LOOP; -- FOR l_mtlt_cur IN mtlt_cur(l_mmtt_cur.transaction_temp_id)

          ELSIF (l_serial_controlled = 1) THEN
               IF (l_serial_status_enabled = 1) THEN
                      inv_trx_util_pub.TRACE('It is serial controlled item ', 9);
                      inv_trx_util_pub.TRACE('Querying MSN and MSNT to know the status ', 9);
                 FOR l_msnt_cur IN msnt_cur(l_mmtt_cur.transaction_temp_id) LOOP
                          l_return_status := l_msnt_cur.status_id;
                            l_trx_allowed := inv_material_status_grp.is_trx_allowed(
                                                p_status_id            => l_return_status
                                                ,p_transaction_type_id  => l_mmtt_cur.transaction_type_id
                                                ,x_return_status        => l_trx_allowed
                                                ,x_msg_count            => l_msg_count
                                              ,x_msg_data             => l_msg_data);
                      IF(g_debug = 1)THEN
                        inv_trx_util_pub.TRACE('Value of l_trx_allowed: '||l_trx_allowed);
                            END If;
                                              if l_trx_allowed='Y' then
                                                    l_trx_allowed_count:=l_trx_allowed_count+1;
                                                    if l_trx_not_allowed_count > 0 then
                                                      exit;
                                                  end if;
                                              ELSE
                                                l_trx_not_allowed_count := l_trx_not_allowed_count+1;
                                    if l_trx_allowed_count > 0 then
                                                    exit;
                                                      end if;
                                          end if;

             END LOOP; --  FOR l_msnt_cur IN msnt_cur(l_mmtt_cur.transaction_temp_id) LOOP
          END IF;  --  IF (l_serial_status_enabled = 1) THEN

     ELSE
      -- Not lot controlled and not serial controlled item
        l_return_status :=
                  INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                         (p_organization_id   => p_organization_id,
                         p_inventory_item_id => l_mmtt_cur.inventory_item_id,
                         p_sub_code => l_mmtt_cur.subinventory_code,
                         p_loc_id => l_mmtt_cur.locator_id,
                         p_lot_number => NULL,
                         p_lpn_id => l_mmtt_cur.lpn_id,
                         p_transaction_action_id=> NULL,
                         p_src_status_id => NULL);
            l_trx_allowed := inv_material_status_grp.is_trx_allowed(
                                    p_status_id            => l_return_status
                                    ,p_transaction_type_id  => l_mmtt_cur.transaction_type_id
                                    ,x_return_status        => l_trx_allowed
                                    ,x_msg_count            => l_msg_count
                                    ,x_msg_data             => l_msg_data);
                      IF(g_debug = 1)THEN
                        inv_trx_util_pub.TRACE('Value of l_trx_allowed: '||l_trx_allowed);
                           END If;
                                    if l_trx_allowed='Y' then
                                    l_trx_allowed_count:=l_trx_allowed_count+1;
                                      if l_trx_not_allowed_count > 0 then
                                            exit;
                                        end if;
                                    ELSE
                                      l_trx_not_allowed_count := l_trx_not_allowed_count+1;

                                      if l_trx_allowed_count > 0 then
                                          exit;
                                      end if;

                                  end if;

      END IF; -- IF (l_lot_controlled = 1 AND l_serial_controlled = 0) THEN

      if l_trx_not_allowed_count>0 and l_trx_allowed_count>0 then
        exit;
      end if;
      inv_trx_util_pub.TRACE('Completed one iteration of the MMTT');
        END LOOP; -- FOR l_mmtt_cur IN mmtt_cur(p_inventory_item_id)


end if;  --if l_lpn_context=WMS_Container_PUB.LPN_CONTEXT_INV then


IF(g_debug = 1)THEN
        inv_trx_util_pub.TRACE('Before returning the from API is_trx_allow_lpns','Material Status', 9);
        inv_trx_util_pub.TRACE('l_trx_allowed_count: '||l_trx_allowed_count,'Material Status', 9);
        inv_trx_util_pub.TRACE('l_trx_not_allowed_count: ' || l_trx_not_allowed_count,'Material Status', 9);
END IF;

if l_trx_allowed_count=0 AND l_trx_not_allowed_count <> 0 then
   -- All the contents of the LPN dis allowed this transaction
   return 0; --0
elsif l_trx_not_allowed_count=0 AND l_trx_allowed_count<>0 then
  -- All the contents of the LPN allows this transaction
   return 2;
ELSIF l_trx_allowed_count<>0 AND l_trx_not_allowed_count <> 0 then
   -- Some contents of the LPN allows and some contents of the LPN dis allows this transaction.
   return 1;
ELSE
   -- No contents in the LPN. It may be new LPN. So we are allowing the transaction.
   RETURN 2;
end if;

EXCEPTION
WHEN OTHERS THEN
inv_trx_util_pub.TRACE('Exception occured in is_trx_allow_lpns in function');

END is_trx_allow_lpns;
/* -- LPN Status Project --*/
--Bug 7626228, added following function to validate sub and loc together.
FUNCTION sub_loc_valid_for_item(p_org_id             NUMBER:=NULL,
                                 p_inventory_item_id  NUMBER:=NULL,
                                 p_sub_code           VARCHAR2:=NULL,
                                 p_loc_id             NUMBER:=NULL,
                                 p_restrict_sub_code  NUMBER:=NULL,
                                 p_restrict_loc_code  NUMBER:=NULL)
 RETURN VARCHAR2 IS
    l_temp NUMBER := -1;
    l_restrict_loc_code NUMBER := 2;
    l_restrict_sub_code NUMBER := 2;
    loc_valid BOOLEAN := FALSE;
    sub_valid BOOLEAN := FALSE;
 BEGIN

    -- to get sub and loc restrict code ,if not passed
    IF p_restrict_sub_code IS NULL OR p_restrict_loc_code IS NULL THEN
       SELECT restrict_subinventories_code,restrict_locators_code
         INTO l_restrict_sub_code,l_restrict_loc_code
         FROM mtl_system_items
        WHERE organization_id = p_org_id
          AND inventory_item_id = p_inventory_item_id;
    ELSE
       l_restrict_loc_code := p_restrict_loc_code;
       l_restrict_sub_code := p_restrict_sub_code;
    END IF;

    --  Subinventory validation
    IF (l_restrict_sub_code = 2) THEN
       sub_valid := TRUE ;
    ELSE
       SELECT count(*)
         INTO l_temp
         FROM mtl_item_sub_inventories b
        WHERE b.organization_id = p_org_id
          AND b.inventory_item_id = p_inventory_item_id
          AND b.secondary_inventory = p_sub_code;

       IF (l_temp = 0) THEN
          RETURN 'N';
       ELSE
          sub_valid := TRUE;
       END IF;
    END IF;

    -- Locator Validation
    l_temp := -1;

    IF p_loc_id IS NULL  THEN
       loc_valid := TRUE;
    END IF ;
    IF (l_restrict_loc_code = 2) THEN
       loc_valid := TRUE;
    ELSE
       SELECT count(*)
         INTO l_temp
         FROM  mtl_secondary_locators b
        WHERE b.organization_id = p_org_id
          AND b.inventory_item_id = p_inventory_item_id
          AND b.subinventory_code = p_sub_code
          AND b.secondary_locator = p_loc_id;

       IF (l_temp = 0) THEN
           RETURN 'N';
       ELSE
          loc_valid := TRUE;
       END IF;
    END IF;

    IF sub_valid = TRUE AND loc_valid = TRUE THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;

 EXCEPTION
    WHEN  OTHERS  THEN
       RETURN  'Y';
END sub_loc_valid_for_item;

END INV_MATERIAL_STATUS_GRP;

/
