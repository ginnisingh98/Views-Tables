--------------------------------------------------------
--  DDL for Package Body INV_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CACHE" AS
/* $Header: INVCACHB.pls 120.2.12010000.6 2010/06/22 16:10:08 mporecha ship $ */

g_om_installed 		VARCHAR2(10);
g_wms_installed_org	NUMBER;
g_oe_header_id	        NUMBER;

FUNCTION set_org_rec
  (
   p_organization_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF org_rec.organization_id = p_organization_id THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO org_rec
	FROM MTL_PARAMETERS
	WHERE organization_id = p_organization_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END set_org_rec;


FUNCTION set_org_rec
  (
   p_organization_code IN VARCHAR2
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF org_rec.organization_code = p_organization_code THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO org_rec
	FROM MTL_PARAMETERS
	WHERE organization_code = p_organization_code;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END set_org_rec;


FUNCTION set_item_rec
  (
   p_organization_id IN NUMBER,
   p_item_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (item_rec.organization_id = p_organization_id AND
       item_rec.inventory_item_id = p_item_id)  THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO item_rec
	FROM MTL_SYSTEM_ITEMS
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_item_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


FUNCTION set_tosub_rec
  (
   p_organization_id IN NUMBER,
   p_subinventory_code IN VARCHAR2
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (tosub_rec.organization_id = p_organization_id AND
       tosub_rec.secondary_inventory_name = p_subinventory_code)  THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO tosub_rec
	FROM MTL_SECONDARY_INVENTORIES
	WHERE organization_id = p_organization_id
	AND secondary_inventory_name = p_subinventory_code;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


FUNCTION set_fromsub_rec
  (
   p_organization_id IN NUMBER,
   p_subinventory_code IN VARCHAR2
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (fromsub_rec.organization_id = p_organization_id AND
       fromsub_rec.secondary_inventory_name = p_subinventory_code)  THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO fromsub_rec
	FROM MTL_SECONDARY_INVENTORIES
	WHERE organization_id = p_organization_id
	AND secondary_inventory_name = p_subinventory_code;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_mmtt_rec
  (
   p_transaction_temp_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (mmtt_rec.transaction_temp_id = p_transaction_temp_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO mmtt_rec
	FROM MTL_MATERIAL_TRANSACTIONS_TEMP
	WHERE transaction_temp_id = p_transaction_temp_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_mol_rec
  (
   p_line_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (mol_rec.line_id = p_line_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO mol_rec
	FROM MTL_TXN_REQUEST_LINES
	WHERE line_id = p_line_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_mtrh_rec
  (
   p_header_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (mtrh_rec.header_id = p_header_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO mtrh_rec
	FROM MTL_TXN_REQUEST_HEADERS
	WHERE header_id = p_header_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_wdd_rec
  (
   p_move_order_line_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (wdd_rec.move_order_line_id = p_move_order_line_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO wdd_rec
	FROM WSH_DELIVERY_DETAILS
	WHERE move_order_line_id = p_move_order_line_id;
	--AND NVL(released_status, 'Z') <> 'Y'; --Bug 8642550
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_mso_rec
  (
   p_oe_header_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_order_source     VARCHAR2(1000);
      l_order_number     VARCHAR2(50);
      l_order_type       VARCHAR2(50);
      l_return_val BOOLEAN := FALSE;

BEGIN
   -- Same as inv_sales_order.get_salesorder_for_oeheader(p_oe_header_id);
   IF (g_oe_header_id = p_oe_header_id) THEN
      l_return_val := TRUE;
    ELSE
      oe_header_util.get_order_info(p_oe_header_id,
				    l_order_number,
				    l_order_type,
				    l_order_source);

      SELECT *
	INTO mso_rec
	FROM mtl_sales_orders
	WHERE segment1 = l_order_number
	AND segment2 = l_order_type
	AND segment3 = l_order_source ;
      g_oe_header_id := p_oe_header_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;

FUNCTION set_oeh_id
  (
   p_salesorder_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN

   IF  mso_rec.sales_order_id = p_salesorder_id THEN
      l_return_val := TRUE;
    ELSE

      -- initialize x_oe_order_id to -1, assume default that SO row not created by OOM
      g_oe_header_id := -1 ;

      -- now check if the SO was created by Oracle Order Management (OOM). If not return (-1)
      if ( g_om_installed IS NULL ) then
	 g_om_installed := oe_install.get_active_product ;
      end if;
      if (g_om_installed <> 'ONT') then -- OOM is not active
	 return TRUE ;
      end if;

      -- now select segment 2 for the given sales order id
      SELECT *
	INTO  mso_rec
	FROM mtl_sales_orders
	WHERE sales_order_id = p_salesorder_id ;


      /*g_oe_header_id := inv_sales_order.get_header_id(to_number(mso_rec.segment1),
                                                        mso_rec.segment2,
                                                        mso_rec.segment3);
	*/
     l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


FUNCTION set_mtt_rec
  (
   p_transaction_type_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (mtt_rec.transaction_type_id = p_transaction_type_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO mtt_rec
	FROM MTL_TRANSACTION_TYPES
	WHERE transaction_type_id = p_transaction_type_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


FUNCTION set_wms_installed
  (
   p_organization_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN

   IF g_wms_installed_org = p_organization_id THEN
      l_return_val := TRUE;
    ELSE
      wms_installed := inv_install.adv_inv_installed(p_organization_id);
      g_wms_installed_org := p_organization_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


FUNCTION set_pick_release
  (
   p_value IN BOOLEAN
   ) RETURN BOOLEAN IS
BEGIN

   is_pickrelease := p_value;
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END;

FUNCTION set_to_locator
  (
   p_locator_id IN NUMBER
   ) RETURN BOOLEAN IS
BEGIN

   tolocator_id := p_locator_id;
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END;

FUNCTION set_to_subinventory
  (
   p_subinventory_code IN NUMBER
   ) RETURN BOOLEAN IS
BEGIN

   tosubinventory_code := p_subinventory_code;
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      RETURN False;
END;

--4171297
FUNCTION set_oola_rec
  (
   p_order_line_id IN NUMBER
   ) RETURN BOOLEAN IS
      l_return_val BOOLEAN := FALSE;
BEGIN
   IF (oola_rec.line_id = p_order_line_id) THEN
      l_return_val := TRUE;
    ELSE
      SELECT *
	INTO oola_rec
	FROM oe_order_lines_all
	WHERE line_id = p_order_line_id;
      l_return_val := TRUE;
   END IF;
   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END;


-- Bug# 4258360: Added for R12 Crossdock Pegging Project
-- Retrieve the picking batch record for a pick release batch
FUNCTION set_wpb_rec
  (p_batch_id       IN NUMBER,
   p_request_number IN VARCHAR2
   ) RETURN BOOLEAN IS
BEGIN
   IF (p_batch_id IS NULL AND p_request_number IS NULL) THEN
      -- At least one value must be inputted
      RETURN FALSE;
    ELSIF (p_batch_id IS NOT NULL AND wpb_rec.batch_id = p_batch_id) THEN
      -- Value is already cached
      RETURN TRUE;
    ELSIF (p_request_number IS NOT NULL AND wpb_rec.name = p_request_number) THEN
      -- Value is already cached
      RETURN TRUE;
    ELSIF (p_batch_id IS NOT NULL) THEN
      -- Query and cache the value based on p_batch_id
      SELECT *
	INTO wpb_rec
	FROM wsh_picking_batches
	WHERE batch_id = p_batch_id;
      RETURN TRUE;
    ELSIF (p_request_number IS NOT NULL) THEN
      -- Query and cache the value based on p_request_number
      SELECT *
	INTO wpb_rec
	FROM wsh_picking_batches
	WHERE name = p_request_number;
      RETURN TRUE;
    ELSE
      -- Should not reach this condition
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END;

-- Onhand Material Status Support
-- Cache locator record.
FUNCTION set_loc_rec
  (
   p_organization_id IN NUMBER,
   p_locator_id IN VARCHAR2
  ) RETURN BOOLEAN IS

   l_return_val BOOLEAN := FALSE;
BEGIN
    IF loc_rec.organization_id = p_organization_id  and
      loc_rec.inventory_location_id = p_locator_id THEN
          l_return_val := TRUE;
    ELSE
       SELECT *
       INTO loc_rec
       FROM MTL_ITEM_LOCATIONS
       WHERE inventory_location_id = p_locator_id
       AND organization_id = p_organization_id;

       l_return_val := TRUE;
    END IF;

    RETURN l_return_val;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
    WHEN OTHERS THEN
      RETURN l_return_val;
END set_loc_rec;

-- Onhand Material Status Support
-- Cache status_id of MOQD for a given SKU.
FUNCTION set_moqd_status_rec
  (
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_sub_code IN VARCHAR2,
   p_loc_id IN NUMBER,
   p_lot_number IN VARCHAR2,
   p_lpn_id IN NUMBER
  ) RETURN BOOLEAN IS

   l_return_val BOOLEAN := FALSE;

BEGIN
   IF moqd_rec.organization_id = p_organization_id  and
      moqd_rec.inventory_item_id = p_inventory_item_id  and
      moqd_rec.subinventory_code = p_sub_code and
      nvl(moqd_rec.locator_id, -9999) = nvl(p_loc_id, -9999) and
      nvl(moqd_rec.lot_number, '@@@@') = nvl(p_lot_number, '@@@@') and
      nvl(moqd_rec.lpn_id, -9999) = nvl(p_lpn_id, -9999) THEN

          l_return_val := TRUE;
    ELSE
      SELECT status_id
      INTO moqd_rec.status_id
      FROM MTL_ONHAND_QUANTITIES_DETAIL
      WHERE inventory_item_id = p_inventory_item_id
      AND organization_id = p_organization_id
      AND subinventory_code = p_sub_code
      AND nvl( locator_id, -9999) =nvl(p_loc_id, -9999)
      AND nvl(lot_number, '@@@@') = nvl(p_lot_number, '@@@@')
      AND nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
      AND rownum  = 1;

      l_return_val := TRUE;
   END IF;

   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END set_moqd_status_rec;

--8809951 High Volume Projec Phase-2
FUNCTION set_pjm_org_parms_rec
  (
  p_organization_id IN NUMBER
  ) RETURN BOOLEAN IS

 l_return_val BOOLEAN := FALSE;

BEGIN
   IF pjm_org_parms_rec.organization_id = p_organization_id THEN
          l_return_val := TRUE;
    ELSE
      SELECT allow_cross_proj_issues
           , allow_cross_unitnum_issues
           INTO pjm_org_parms_rec.allow_cross_proj_issues,
           pjm_org_parms_rec.allow_cross_unitnum_issues
        FROM pjm_org_parameters
       WHERE organization_id = p_organization_id;

      l_return_val := TRUE;
   END IF;

   RETURN l_return_val;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_return_val;
   WHEN OTHERS THEN
      RETURN l_return_val;
END set_pjm_org_parms_rec;

/* ==================================================================================*
 | Procedure : get_client_default_parameters                                        |
 |              Added for LSP Project                                               |
 |                                                                                  |
 | Description : For getting the client parameter record , to be used by Shipping   |
 |               Team                                                               |
 | Input Parameters:                                                                |
 |   p_client_id          -  The client ID for which the record needs to be passed. |
 | Output Parameters:                                                               |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded                 |
 |                          fnd_api.g_ret_sts_error, if  error occurred             |
 |   x_client_parameters_rec - It returns the record of mtl_client_parameters       |
 |                             for the passed client_id                             |
 |                             and can be queried in the following format           |
 |               Dbms_Output.put_line('Client ID  -'||ct_rec.client_rec.client_id)  |
 *================================================================================== */

  PROCEDURE get_client_default_parameters
          (
                p_client_id          IN MTL_CLIENT_PARAMETERS.CLIENT_ID%TYPE
              , x_return_status        OUT NOCOPY VARCHAR2
              , x_client_parameters_rec OUT NOCOPY ct_rec_type
          )
          AS

      CURSOR client_info(p_client_id NUMBER)
      IS SELECT * FROM MTL_CLIENT_PARAMETERS
      WHERE client_id = p_client_id ;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
    IF ct_table.EXISTS(p_client_id) THEN
            x_client_parameters_rec := ct_table(p_client_id);
    ELSE
        FOR client_rec_new IN client_info(p_client_id)
            LOOP
              ct_table(p_client_id).client_rec := client_rec_new;
            END LOOP;
            x_client_parameters_rec := ct_table(p_client_id);
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_error;
   END get_client_default_parameters;

  /* End of changes for LSP Project */

    --Serial Tagged
    FUNCTION get_serial_tagged
              (     p_organization_id      IN         NUMBER
                  , p_inventory_item_id    IN         NUMBER
                  , p_transaction_type_id  IN         NUMBER
              ) RETURN NUMBER IS
        x_serial_tag NUMBER := 1;
        l_hash_value NUMBER;
    BEGIN

        l_hash_value := DBMS_UTILITY.get_hash_value
                              ( NAME      => p_organization_id ||':'|| p_inventory_item_id ||':'|| p_transaction_type_id
                              , base      => 1
                              , hash_size => POWER(2, 25)
                              );

        IF serial_tag_table.exists(l_hash_value) THEN
            x_serial_tag := serial_tag_table(l_hash_value);
        ELSE
            BEGIN
                SELECT 2 INTO x_serial_tag
                FROM DUAL
                WHERE EXISTS (SELECT 1 FROM mtl_serial_tagging_assignments
                              WHERE organization_id = p_organization_id
                              AND inventory_item_id = p_inventory_item_id
                              AND transaction_type_id = p_transaction_type_id
                             );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            serial_tag_table(l_hash_value)        := x_serial_tag;
        END IF;
        RETURN x_serial_tag;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN x_serial_tag;
    END get_serial_tagged;

END inv_cache;

/
