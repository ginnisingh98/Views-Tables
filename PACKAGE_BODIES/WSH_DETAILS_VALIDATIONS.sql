--------------------------------------------------------
--  DDL for Package Body WSH_DETAILS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DETAILS_VALIDATIONS" as
/* $Header: WSHDDVLB.pls 120.48.12010000.9 2010/08/10 08:47:13 anvarshn ship $ */


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DETAILS_VALIDATIONS';
-- Global Variable added for bug 4399278, 4418754
G_SUBINVENTORY      WSH_DELIVERY_DETAILS.Subinventory%TYPE;
--

--public api changes
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN wsh_glbl_var_strct_grp.delivery_details_rec_type,
      p_out_rec         IN wsh_glbl_var_strct_grp.delivery_details_rec_type,
      p_in_rec          IN wsh_glbl_var_strct_grp.detailInRecType,
      x_return_status   OUT NOCOPY    VARCHAR2);




g_bad_header_ids wsh_util_core.id_tab_type;
g_good_header_ids wsh_util_core.id_tab_type;

-- 2467416
-- Description:
--		PL/SQL table g_passed_crd_Tab: caches the line_ids that passed Credit Check
--		PL/SQL table g_failed_crd_Tab: caches the line_ids that failed Credit Check
--			   Both these table above helps in maintaining the latest record in the table
--			   and deleting the oldest record (Caching).
-- 3481194/3492870 modified logic to hash index on g_passed_crd_tab and g_failed_crd_tab
-- to avoid linear scans on pl/sql lists by calling function get_table_index..


g_passed_crd_Tab wsh_util_core.id_tab_type;
g_failed_crd_Tab wsh_util_core.id_tab_type;

PROCEDURE Insert_PR_Header_Holds (
p_header_id   IN NUMBER,
p_status      IN VARCHAR2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  INSERT INTO WSH_PR_HEADER_HOLDS (
                                     batch_id,
                                     header_id,
                                     status )
                           VALUES (
                                     WSH_PICK_LIST.G_BATCH_ID,
                                     p_header_id,
                                     p_status );

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

END Insert_PR_Header_Holds;
-----------------------------------------------------------------------------
--
-- FUNCTION:		  get_table_index
-- Parameters:	          p_entity_id     entity_id to map to index
--                        p_alt_index     optional alternate index to reuse
--                        x_table         list of ids to map index
-- Returns:		number
-- Description:         Created to fix performance bug 3481194
-- 	                It returns the hashed index to map p_entity_id,
--                      so that x_table(index) = p_entity or
--                      x_table(index) does not exist (without hash collusion):
--                      index is always given; the caller should
--                      validate x_table.exists(index) is true or false.
--                      The caller should add index to the table if appropriate.
--
-- NOTE: For performance reason, there is no debug logic in this API.
-----------------------------------------------------------------------------
function get_table_index(p_entity_id  IN            NUMBER,
                         p_alt_index  IN            NUMBER   DEFAULT NULL,
                         x_table      IN OUT NOCOPY wsh_util_core.id_tab_type)
RETURN NUMBER
IS
  c_hash_base CONSTANT NUMBER := 1;
  c_hash_size CONSTANT NUMBER := power(2, 25);

  l_hash_string      VARCHAR2(1000) := NULL;
  l_index            NUMBER;
  l_hash_exists      BOOLEAN := FALSE;

BEGIN

  IF p_alt_index IS NOT NULL THEN
    -- check if we can reuse the hashed index.
    IF x_table.EXISTS(p_alt_index) THEN
      IF x_table(p_alt_index) = p_entity_id THEN
        l_hash_exists := TRUE;
        l_index := p_alt_index;
      END IF;
    END IF;
  END IF;

  IF NOT l_hash_exists THEN
    -- need to hash this index
    l_hash_string := to_char(p_entity_id);

    l_index := dbms_utility.get_hash_value (
                                          name => l_hash_string,
                                          base => c_hash_base,
                                     hash_size => c_hash_size );

    WHILE NOT l_hash_exists LOOP
     IF x_table.EXISTS(l_index) THEN
       IF (x_table(l_index) = p_entity_id) THEN
         EXIT;
       ELSE
         -- Index exists but p_entity_id does not match this table element.
         -- Bump l_index till p_entity_id matches
         --      or table element does not exist
         l_index := l_index + 1;
       END IF;
     ELSE
       -- Table element does not exist, so the caller can use this new index.
       l_hash_exists := TRUE;
     END IF;
   END LOOP;
  END IF;

  RETURN l_index;

END get_table_index;


-----------------------------------------------------------------------------
--
-- FUNCTION:		  Trx_ID
-- Parameters:	  p_mode, p_source_line_id, p_source_document_type_id
-- Returns:		number
-- Trx_ID:		It reurns the trx_id depending on the given mode, source
--				line id and source_document_type_id
-----------------------------------------------------------------------------

FUNCTION trx_id(
	p_mode varchar2,
	p_source_line_id number,
	p_source_document_type_id number) return number is
l_dest_type varchar2(30);
l_from_org number;
l_to_org number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRX_ID';
--
begin
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
		--
		WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
		WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
		WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_DOCUMENT_TYPE_ID',P_SOURCE_DOCUMENT_TYPE_ID);
	END IF;
	--
	if (p_source_document_type_id <> 10) then /* regular order */
		if (p_mode = 'TRX_ACTION_ID') then
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			return(1); /* 1 = Issue */
		elsif (p_mode = 'TRX_TYPE_ID') then
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			return(33); /* 33 = Sales Order Issue */
		end if;

	elsif (p_source_document_type_id = 10) then
		SELECT	 nvl(destination_type_code,'@'),source_organization_id,
				 destination_organization_id
		INTO	 l_Dest_Type,l_From_Org,l_To_Org
		FROM	 po_requisition_lines_all pl,
				oe_order_lines_all ol
		WHERE	 pl.line_num = to_number(ol.orig_sys_line_ref)
		AND		pl.requisition_header_id = ol.source_document_id
		AND		pl.requisition_line_id = ol.source_document_line_id
		AND		 ol.line_id = p_source_line_id;
		If (p_Mode = 'TRX_TYPE_ID') then
			 If (l_Dest_Type = 'EXPENSE') then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(34); /* 34 = Stores Issue */
			 Elsif (l_From_Org = l_To_Org) then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(50); /* 50 = */
			 Elsif (l_From_Org <> l_To_Org) then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(62); /* 62 = Transit Shipment */
			 End If;
		Elsif (p_Mode = 'TRX_ACTION_ID') then
			 If (l_Dest_Type = 'EXPENSE') then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(1); /* 1 = Issue */
			 Elsif (l_From_Org = l_To_Org) then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(2); /* 2 = Subinv transfer*/
			 Elsif (l_From_Org <> l_To_Org) then
				--
				-- Debug Statements
				--
				IF l_debug_on THEN
					WSH_DEBUG_SV.pop(l_module_name);
				END IF;
				--
				Return(21); /* 62 = Interorg Transfer */
			 End If;
		  End If;
	end if;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  -- Debug Statements
		  --
		  IF l_debug_on THEN
			  WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
		  END IF;
		  --
		  Return(0);
		WHEN OTHERS THEN
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		   END IF;
		   --
		   Return(0);
		END;

--
--  Function:	serial_num_ctl_req
--  Parameters:  p_inventory_item_id
--			   p_org_id
--  Description: This function returns a boolean value to
--			   indicate if the inventory item in that org is
--			   requires a serial number or not
--


FUNCTION serial_num_ctl_req(p_inventory_item_id number, p_org_id number)
RETURN BOOLEAN IS
serial_num_ctl_code number;
cursor c_serial_ctl_info is
	select  serial_number_control_code
	   from	mtl_system_items
	   where   inventory_item_id = p_inventory_item_id
	and	 organization_id = p_org_id;
l_serial_ctl_info c_serial_ctl_info%ROWTYPE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SERIAL_NUM_CTL_REQ';
--
begin
		--
		-- Debug Statements
		--
		--
		l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
		--
		IF l_debug_on IS NULL
		THEN
			l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
		END IF;
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.push(l_module_name);
			--
			WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
			WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
		END IF;
		--
		serial_num_ctl_code := l_serial_ctl_info.serial_number_control_code;
		IF ( serial_num_ctl_code = 2 OR serial_num_ctl_code = 5 OR
			serial_num_ctl_code = 6) THEN
		 -- 2 : predefined serial numbers
		 -- 5 : dynamic entry at inventory receipt
		 -- 6 : dynamic entry at sales order issue
			   --
			   -- Debug Statements
			   --
			   IF l_debug_on THEN
				   WSH_DEBUG_SV.pop(l_module_name);
			   END IF;
			   --
			   RETURN TRUE;
		ELSE -- serial_num_ctl_code = 1
			-- No serial number control
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			RETURN FALSE;
																		END IF;

end serial_num_ctl_req;


-- 2467416
--   Purges the bad/good Header id Table followed by
--	passed/failed line_id tables
PROCEDURE purge_crd_chk_tab IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_CRD_CHK_TAB';
--
begin

	  --
	  -- Debug Statements
	  --
	  --
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  --
	  IF l_debug_on IS NULL
	  THEN
		  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.push(l_module_name);
	  END IF;
	  --
	  g_bad_header_ids.delete;
	  g_good_header_ids.delete;

	  g_passed_crd_Tab.delete;
	  g_failed_crd_Tab.delete;

	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
end purge_crd_chk_tab;

--
--  Procedure:   Check_Shipped_Quantity
--  Parameters:  p_ship_above_tolerance number,
--			   p_requested_quantity number,
--			   p_picked_quantity	number,
--			   p_shipped_quantity number,
--			   p_cycle_count_quantity number,
--			   x_return_status	   OUT VARCHAR2
--  Description: This procedure validates the entered shipped quantity


PROCEDURE check_shipped_quantity(
		p_ship_above_tolerance IN  number,
		p_requested_quantity   IN  number,
		p_picked_quantity	  IN  NUMBER,
		p_shipped_quantity	 IN  number,
		p_cycle_count_quantity IN  number,
		x_return_status		OUT NOCOPY  VARCHAR2) IS
l_attempt_over_percent number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SHIPPED_QUANTITY';
--
begin

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'P_SHIP_ABOVE_TOLERANCE',P_SHIP_ABOVE_TOLERANCE);
	  WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',P_REQUESTED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_PICKED_QUANTITY',P_PICKED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_CYCLE_COUNT_QUANTITY',P_CYCLE_COUNT_QUANTITY);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_picked_quantity > p_requested_quantity THEN
	-- overpick scenario
	IF (	p_cycle_count_quantity > 0
		AND p_shipped_quantity > p_requested_quantity - p_cycle_count_quantity) THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  fnd_message.set_name('WSH', 'WSH_OVERPICK_SH_QTY_EXCEED');
	  fnd_message.set_token('MAX_QTY', (p_requested_quantity - p_cycle_count_quantity));
	  wsh_util_core.add_message(x_return_status);
	ELSIF (p_shipped_quantity > p_picked_quantity) THEN -- Bug 2111939: Removed the check on tolerance here.
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  fnd_message.set_name('WSH', 'WSH_SH_QTY_ABOVE_PICKED');
	  wsh_util_core.add_message(x_return_status);
	END IF;

  ELSE
		-- normal scenario
	-- for bug 1305066.   When requested_quantity = 0, ie. cancelled line,
	-- return false
	IF (p_requested_quantity = 0) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_UI_SHIP_QTY_ABOVE_TOL');
		wsh_util_core.add_message(x_return_status);
	END IF;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	exception
		when others then
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.Check_Shipped_Quantity');
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
				WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END check_shipped_quantity;



--
--  Procedure:   Check_Cycle_Count_Quantity
--  Parameters:  p_ship_above_tolerance number,
--			   p_requested_quantity number,
--			   p_picked_quantity	number,
--			   p_shipped_quantity number,
--			   p_cycle_count_quantity number,
--			   x_return_status	   OUT VARCHAR2
--  Description: This procedure validates the entered cycle count quantity

PROCEDURE check_cycle_count_quantity(
		p_ship_above_tolerance IN  number,
		p_requested_quantity   IN  number,
		p_picked_quantity	  IN  NUMBER,
		p_shipped_quantity	 IN  number,
		p_cycle_count_quantity IN  number,
		x_return_status		OUT NOCOPY  VARCHAR2) IS
   max_qty_to_bo NUMBER;
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CYCLE_COUNT_QUANTITY';
   --
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'P_SHIP_ABOVE_TOLERANCE',P_SHIP_ABOVE_TOLERANCE);
	  WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',P_REQUESTED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_PICKED_QUANTITY',P_PICKED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
	  WSH_DEBUG_SV.log(l_module_name,'P_CYCLE_COUNT_QUANTITY',P_CYCLE_COUNT_QUANTITY);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  max_qty_to_bo := p_requested_quantity - NVL(p_shipped_quantity, 0);
  IF max_qty_to_bo < 0 THEN
	max_qty_to_bo := 0;
  END IF;

  IF p_cycle_count_quantity > max_qty_to_bo THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	fnd_message.set_name('WSH', 'WSH_UI_CYCLE_QTY_ABOVE_TOL');
	wsh_util_core.add_message(x_return_status);
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN OTHERS THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.Check_Cycle_Count_Quantity');
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END check_cycle_count_quantity;




/*	Validates and returns the quantity in this manner (the caller does not need
	to adjust the result):
	This routine checks to make sure that the input quantity precision does
	not exceed the decimal precision. Max Precision is: 10 digits before the
	decimall point and 9 digits after the decimal point.
	The routine also makes sure that if the item is serial number controlled,
	the the quantity in primary UOM is an integer number.
	The routine also makes sure that if the item's indivisible_flag is set
	to yes, then the item quantity is an integer in the primary UOM
	The routine also checks if the profile, INV:DETECT TRUNCATION, is set
	to yes, the item quantity in primary UOM also obeys max precision and that
	it is not zero.
	The procedure retruns a correct output quantity in the transaction UOM,
	returns the primary quantity and returns a status of success, failure, or
	warning.

        The parameter p_max_decimal_digits has been added to determine the max precision
        that should be applied to the quantity after the decimal point. */
PROCEDURE check_decimal_quantity(
	p_item_id number,
	p_organization_id number,
	p_input_quantity number,
	p_uom_code varchar2,
	x_output_quantity out NOCOPY  number,
	x_return_status  out NOCOPY  varchar2,
	p_top_model_line_id number,
        p_max_decimal_digits IN NUMBER DEFAULT NULL) IS -- RV DEC_QTY

l_primary_quantity number;
l_return_status varchar2(30);

others  EXCEPTION;
--
-- RV DEC_QTY
l_max_decimal_digits NUMBER := p_max_decimal_digits ;
l_max_real_digits    CONSTANT        NUMBER := WSH_UTIL_CORE.C_MAX_REAL_DIGITS;
-- HW OPMCONV - Noneed for OPM variables

-- RV DEC_QTY
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DECIMAL_QUANTITY';
--
begin
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_ITEM_ID',P_ITEM_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_INPUT_QUANTITY',P_INPUT_QUANTITY);
    WSH_DEBUG_SV.log(l_module_name,'P_UOM_CODE',P_UOM_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_TOP_MODEL_LINE_ID',P_TOP_MODEL_LINE_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  /* Bug 2177410, skip validate quantity to avoid error for non-item delivery details */

  -- BUG 3376504
  --
  -- RV DEC_QTY
-- HW OPMCONV - No need to check for process_org

  IF (l_max_decimal_digits IS NULL) THEN
  --{
-- HW OPMCONV - Re-arranged code to avoid branching

      l_max_decimal_digits := WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV;

      --}
  END IF;
  --
  -- RV DEC_QTY
  -- BUG 3376504
  if p_item_id is not NULL then  -- {
    if ( p_top_model_line_id is not null and p_input_quantity <> trunc ( p_input_quantity ) ) then  --{
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_CONFIG_NO_DECIMALS');
        wsh_util_core.add_message(x_return_status);
    else
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_DECIMALS_PUB.VALIDATE_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      inv_decimals_pub.validate_quantity(
        p_item_id,
        p_organization_id,
        p_input_quantity,
        p_uom_code,
        x_output_quantity,
        l_primary_quantity,
        x_return_status);

      -- RV DEC_QTY
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      END IF;
-- HW OPMCONV - No need to fork the code


      --{
        -- Using the same message as inventory because this is the message set
        -- by INV when the number of decimal digits entered by user are greater than 9.
        -- This condition is for taking care of setting a message when the number
        -- of decimals are between 5 and 9.
        -- This should not cause any duplicate messages even when INV starts rounding
        -- off to 5 digits of decimal.
-- HW OPMCOMV - Changed the precision from OPM to INV which is 5
        IF (p_input_quantity = round(p_input_quantity,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV)
        AND x_output_quantity <> round(x_output_quantity,l_max_decimal_digits))
        THEN
        --{
          fnd_message.set_name('INV', 'MAX_DECIMAL_LENGTH');
          x_return_status := wsh_util_core.g_ret_sts_warning;
          WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
        --}
        END IF;
        x_output_quantity := round(x_output_quantity,l_max_decimal_digits);
      --}

      -- RV DEC_QTY
      --
     end if; --}

  else --} {

    if ( p_input_quantity <> ROUND(p_input_quantity, l_max_decimal_digits)) then
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'decimal digits exceed ');
      END IF;
      x_output_quantity := ROUND(p_input_quantity, l_max_decimal_digits);
    else
      if (x_output_quantity IS NULL) then
        x_output_quantity := p_input_quantity;
      end if;
    end if;


    if ( trunc(abs(p_input_quantity)) > (POWER(10,l_max_real_digits) - 1) ) then
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'real part of number fail');
      END IF;

      raise others;
    end if;

   end if; --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_output_quantity',x_output_quantity);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
exception
  when others then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
end check_decimal_quantity;


PROCEDURE check_unassign_from_delivery(
	p_detail_rows   IN  wsh_util_core.id_tab_type,
	x_return_status OUT NOCOPY  VARCHAR2) IS

cursor check_unassign (detail_id IN NUMBER) is
select da.parent_delivery_detail_id , da.delivery_id  ,
	   dd.container_name  , dd.container_flag
from wsh_delivery_assignments da,
	 wsh_delivery_Details dd
where da.delivery_detail_id = detail_id
and   nvl(da.type,'S') in ('S', 'C')
and   da.parent_Delivery_Detail_id = dd.delivery_Detail_id (+);

l_parent_delivery_detail_id  NUMBER ;
l_delivery_id				NUMBER ;
l_container_name			 VARCHAR2(30) ;
l_container_flag			 VARCHAR2(1) ;

others	   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UNASSIGN_FROM_DELIVERY';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
	   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
	   WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_detail_rows.count = 0) THEN
	 raise others;
   END IF;

   FOR i IN 1..p_detail_rows.count LOOP

	 OPEN check_unassign (p_detail_rows(i));

	 FETCH check_unassign INTO l_parent_delivery_detail_id , l_delivery_id ,
				   l_container_name , l_container_flag ;

	 IF check_unassign%NOTFOUND THEN

	   raise others ;
	   CLOSE check_unassign;
	 END IF ;

	 IF l_parent_delivery_Detail_id IS NOT NULL THEN
	   if ( l_container_flag IN ('Y', 'C' )) then
		   FND_MESSAGE.SET_NAME('WSH','WSH_PK_DET_UNASSIGN_DEL');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   wsh_util_core.add_message(x_return_status);

		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
			   WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   RETURN;
	   else
	   -- in the unlikely event that a delivery_detail's parent is
	   -- NOT a container.
	   raise others ;
	   end if ;

	 END IF ;

	 CLOSE check_unassign;

   END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	  WHEN others THEN
			IF check_unassign%ISOPEN THEN
			  CLOSE check_unassign;
			END IF;
		wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.CHECK_UNASSIGN_FROM_DELIVERY');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_unassign_from_delivery ;


PROCEDURE check_assign_del_multi(
	p_detail_rows   IN  wsh_util_core.id_tab_type,
	x_del_params	OUT NOCOPY  wsh_delivery_autocreate.grp_attr_rec_type,
	x_return_status OUT NOCOPY  VARCHAR2) IS

l_del_rows   wsh_util_core.id_tab_type;
l_group_rows wsh_util_core.id_tab_type;

l_detail_org_id NUMBER;
l_delivery_id   NUMBER;

cursor check_assign (detail_id IN NUMBER) is
select delivery_id
from wsh_delivery_assignments_v
where delivery_detail_id = detail_id
and delivery_id IS NOT NULL;

l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_action_rec wsh_delivery_autocreate.action_rec_type;
l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
l_matched_entities wsh_util_core.id_tab_type;
l_out_rec wsh_delivery_autocreate.out_rec_type;
l_generic_flag varchar2(1);



others	   EXCEPTION;
assign_error EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ASSIGN_DEL_MULTI';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
	   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
	   WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_detail_rows.count = 0) THEN
	 raise others;
   END IF;

   FOR i IN 1..p_detail_rows.count LOOP

	 OPEN check_assign (p_detail_rows(i));

	 FETCH check_assign INTO l_delivery_id;

	 IF check_assign%FOUND THEN

	   CLOSE check_assign;
	   FND_MESSAGE.SET_NAME('WSH','WSH_DET_ASSIGNED_DEL');
	   FND_MESSAGE.SET_TOKEN('DET_NAME', p_detail_rows(i));
	   FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_id);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   wsh_util_core.add_message(x_return_status);

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
		   WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   RETURN;

	 ELSE

	   CLOSE check_assign;

	 END IF;

   END LOOP;




-- Call autocreate deliveries to group details together. Check if the
-- number of deliveries created is 1. Use the wsh_delivery_autocreate
-- package to return a list of matching delivery parameters and then
-- delete these tables so that subsequent calls are not effected.
--p_init_flag should be N (if it is Y, all the tables get deleted at
--the end of the call to autocreate_deliveries which should not
--happen in this case

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   FOR i in 1..p_detail_rows.count LOOP

       l_attr_tab(i).entity_id := p_detail_rows(i);
       l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';

   END LOOP;

   l_action_rec.action := 'MATCH_GROUPS';
--   l_action_rec.check_single_grp := 'Y';


   WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => x_return_status);
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name, 'Return status from autocreate_deliveries: '|| x_return_status);
    --
   END IF;
   --
   -- Bug 2734531 (handle return status correctly)
   --
   IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
     RAISE assign_error;
   END IF;
   --
   --
   --
   x_del_params := l_group_tab(l_group_tab.FIRST);


   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name, 'Done check_assign_del_multi '|| x_return_status);
    --
   END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	 WHEN assign_error THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_GROUP_ERROR');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'ASSIGN_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ASSIGN_ERROR');
		END IF;
		--
	  WHEN others THEN
			IF check_assign%ISOPEN THEN
			  CLOSE check_assign;
			END IF;
		wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.CHECK_ASSIGN_DEL_MULTI');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_assign_del_multi;

-----------------------------------------------------------------------------
--
-- Procedure:		check_credit_holds
-- Parameters:		p_detail_id - delivery detail id
--				  p_activity_type - 'PICK','PACK','SHIP'
--				  p_source_line_id - optional
--				  p_source_header_id - optional
--				  p_init_flag - 'Y' initializes the table of bad header ids
--				x_return_status
-- Description:	   Checks if there are any credit checks or holds on a line.
--				  Returns a status of FND_API.G_RET_STS_SUCCESS if no such
--				  checks or holds exist
--
-----------------------------------------------------------------------------

PROCEDURE check_credit_holds(
	p_detail_id	 IN  NUMBER,
	p_activity_type IN  VARCHAR2,
	p_source_line_id   IN NUMBER,
	p_source_header_id IN NUMBER,
		p_source_code	  IN  VARCHAR2,
	p_init_flag	 IN  VARCHAR2,
	x_return_status OUT NOCOPY  VARCHAR2) IS

-- BUG#:1549665 hwahdani retrieve ship_from_location_id,order_number,line number
CURSOR get_source_info IS
SELECT source_header_id, source_line_id,ship_from_location_id,
	  source_header_number, source_line_number, org_id, container_flag, source_code -- RTV Changes
FROM   wsh_delivery_details
WHERE  delivery_detail_id = p_detail_id;

-- BUG#:1549665 hwahdani get order information
--Bug 1697471: added source_line_id in the where clause
CURSOR get_order_info IS
SELECT ship_from_location_id,source_header_number, source_line_number, org_id, container_flag
FROM   wsh_delivery_details
WHERE  source_header_id = p_source_header_id
AND	source_code	= p_source_code
AND	source_line_id = p_source_line_id;

CURSOR get_pr_credit_cache IS
SELECT status
FROM   wsh_pr_header_holds
WHERE  header_id = p_source_header_id
AND    batch_id = WSH_PICK_LIST.G_BATCH_ID;

l_header_id NUMBER := p_source_header_id;
l_line_id   NUMBER := p_source_line_id;
-- BUG#: 1549665 hwahdani variable to hold ship_from_location_id
l_ship_from_location_id NUMBER;
l_skip_header_flag VARCHAR2(1) := 'N';
l_cache_status     VARCHAR2(1) ;

l_result_out VARCHAR2(1);
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
-- BUG#:1549665 hwahdani variables for log_exception;
l_request_id NUMBER;
l_exception_return_status		  VARCHAR2(30);
l_exception_msg_count			  NUMBER;
l_exception_msg_data			   VARCHAR2(4000) := NULL;
l_exception_assignment_id		  NUMBER;
l_exception_error_message		  VARCHAR2(2000) := NULL;
l_exception_location_id			NUMBER;
l_dummy_exception_id			   NUMBER;
l_dummy_detail_id				  NUMBER;
l_order_number					 VARCHAR2(150);
l_container_flag                        VARCHAR2(3);
l_line_number					  VARCHAR2(150);
l_org_id						   NUMBER;
l_msg							  VARCHAR2(2000):= NULL;
l_source_code                           VARCHAR2(30); -- RTV Changes

-- 3481194/3492870: add index variables to hash lists of headers and lines
l_bad_index          NUMBER;
l_good_index         NUMBER;
l_passed_index       NUMBER;
l_failed_index       NUMBER;

-- bug 2429004
l_activity_type					VARCHAR2(30);

credit_hold_error EXCEPTION;
header_hold_error EXCEPTION;
line_hold_error   EXCEPTION;

-- 2467416
  l_exists_flag VARCHAR2(1):= 'N';
  l_counter NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CREDIT_HOLDS';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
	   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
	   WSH_DEBUG_SV.push(l_module_name);
	   --
	   WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_ACTIVITY_TYPE',P_ACTIVITY_TYPE);
	   WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
	   WSH_DEBUG_SV.log(l_module_name,'P_INIT_FLAG',P_INIT_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_source_code <> 'OE' THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 return;
   END IF;

-- 2467416: In this check to include purge of the line_id tables also
   IF (p_init_flag = 'Y') THEN
	 g_bad_header_ids.delete;
	 g_good_header_ids.delete;

	 g_passed_crd_Tab.delete;
	 g_failed_crd_Tab.delete;

   END IF;

   IF (l_header_id IS NULL) OR (l_line_id IS NULL) THEN

-- BUG#: 1549665 hwahdani - added ship_from_location_id
-- order_number and line number
	 OPEN  get_source_info;
	 FETCH get_source_info INTO l_header_id, l_line_id,
	 l_ship_from_location_id,l_order_number, l_line_number, l_org_id, l_container_flag, l_source_code; -- RTV Changes
	 CLOSE get_source_info;

         -- RTV Changes
         IF l_source_code <> 'OE' THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
         END IF;

-- BUG#:1549665 hwahdani added else
   ELSE
	OPEN get_order_info;
	 FETCH get_order_info into l_ship_from_location_id,
		 l_order_number,l_line_number, l_org_id, l_container_flag;
	CLOSE get_order_info ;
   END IF;

   IF l_container_flag = 'Y'
   THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 return;
   END IF;

   l_bad_index := get_table_index(p_entity_id=>l_header_id, x_table=>g_bad_header_ids);
   IF g_bad_header_ids.EXISTS(l_bad_index) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HEADER '||TO_CHAR ( L_HEADER_ID ) ||' FAILED CREDIT CHECK OR IS ON HOLD'  );
	END IF;
	--
	raise credit_hold_error;
   END IF;

   l_good_index := get_table_index(p_entity_id=>l_header_id, p_alt_index=>l_bad_index, x_table=>g_good_header_ids);
   IF g_good_header_ids.EXISTS(l_good_index) THEN
	l_skip_header_flag := 'Y';
   END IF;

   -- Check if Header exists in WSH_PR_HEADER_HOLDS Table for Pick Release process
   IF (l_skip_header_flag = 'N') AND (p_activity_type = 'PICK') AND (WSH_PICK_LIST.G_BATCH_ID IS NOT NULL)
   AND (WSH_PICK_LIST.G_PICK_REL_PARALLEL) THEN
      OPEN  get_pr_credit_cache;
      FETCH get_pr_credit_cache INTO l_cache_status;
      IF get_pr_credit_cache%NOTFOUND THEN
         l_cache_status := 'N'; -- not present in cache
      END IF;
      CLOSE get_pr_credit_cache;
      IF l_cache_status = 'F' THEN
         g_bad_header_ids(l_bad_index) := l_header_id;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HEADER '||TO_CHAR ( L_HEADER_ID )
                                  ||' FAILED CREDIT CHECK OR IS ON HOLD'  );
         END IF;
         RAISE credit_hold_error;
      ELSIF l_cache_status = 'P' THEN
 	 l_skip_header_flag := 'Y';
         g_good_header_ids(l_good_index) := l_header_id;
      END IF;
   END IF;

-- Bug: 1580603
   --

   IF (l_skip_header_flag = 'N') THEN

     IF l_org_id IS NULL THEN
        SELECT ORG_ID
        INTO l_org_id
        FROM OE_ORDER_HEADERS_ALL
        WHERE HEADER_ID = l_header_id;
     END IF;

     IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,  'SETTING THE POLICY CONTEXT FOR ORG_ID:' || TO_CHAR ( L_ORG_ID )  );
     END IF;
     --
     MO_GLOBAL.set_policy_context('S', l_org_id);


-- bug 2429004
	  IF (p_activity_type = 'PICK') THEN
		 l_activity_type := 'PICKING';
	  ELSIF (p_activity_type = 'PACK') THEN
		 l_activity_type := 'PACKING';
	  ELSE
		 l_activity_type := 'SHIPPING';
	  END IF;
-- end bug 2429004

	  -- Check header level credit

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_VERIFY_PAYMENT_PUB.VERIFY_PAYMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  oe_verify_payment_pub.verify_payment(
		 p_header_id	   => l_header_id,
		p_calling_action  => l_activity_type, -- bug 2429004 - passing the corresponding activity type.
		p_msg_count	   => l_msg_count,
		p_msg_data		=> l_msg_data,
		p_return_status   => x_return_status);

	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		g_bad_header_ids(l_bad_index) := l_header_id;
                IF (p_activity_type = 'PICK') AND (WSH_PICK_LIST.G_BATCH_ID IS NOT NULL)
                AND (WSH_PICK_LIST.G_PICK_REL_PARALLEL) THEN
                   Insert_PR_Header_Holds (p_header_id => l_header_id, p_status => 'F');
                END IF;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HEADER '||TO_CHAR ( L_HEADER_ID ) ||' FAILED CREDIT CHECK'  );
		END IF;
		--
		raise credit_hold_error;
	  END IF;


	  -- Check generic header holds

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_HOLDS_PUB.CHECK_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  oe_holds_pub.check_holds(
		p_api_version		 => 1.0,
		p_header_id		=> l_header_id,
		 p_wf_item			=> NULL,
		p_wf_activity		=> NULL,
		x_result_out		 => l_result_out,
		x_return_status	 => x_return_status,
		x_msg_count		 => l_msg_count,
		x_msg_data			=> l_msg_data);

	  -- If hold is found return back

	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_result_out = FND_API.G_TRUE) THEN
		   g_bad_header_ids(l_bad_index) := l_header_id;
                   IF (p_activity_type = 'PICK') AND (WSH_PICK_LIST.G_BATCH_ID IS NOT NULL)
                   AND (WSH_PICK_LIST.G_PICK_REL_PARALLEL) THEN
                      Insert_PR_Header_Holds (p_header_id => l_header_id, p_status => 'F');
                   END IF;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HEADER '||TO_CHAR ( L_HEADER_ID ) ||' IS ON HOLD'  );
		END IF;
		--
--BUG#:1549665 hwahdani - check if process was run from conc. request and get id
-- and log exception if order is on hold
		l_request_id := fnd_global.conc_request_id;
	-- 1729516
		IF l_debug_on THEN
		   WSH_DEBUG_SV.log(l_module_name,'l_request_id', l_request_id );
		   WSH_DEBUG_SV.log(l_module_name,'WSH_PICK_LIST.G_BATCH_ID', WSH_PICK_LIST.G_BATCH_ID );
		END IF;

		IF ( l_request_id = -1 AND  WSH_PICK_LIST.G_BATCH_ID IS NULL ) THEN
			   raise header_hold_error;
		ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_PICK_HOLD');
		   FND_MESSAGE.SET_TOKEN('ORDER',l_order_number);
			 l_msg := FND_MESSAGE.GET;
			 --
			 -- Debug Statements
			 --
			 IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG  );
			 END IF;
			 --

		         l_dummy_exception_id :=null;
			 --
			 -- Debug Statements
			 --
			 IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;
			 --
			 wsh_xc_util.log_exception(
			 p_api_version			 => 1.0,
			 x_return_status		   => l_exception_return_status,
			 x_msg_count			   => l_exception_msg_count,
			 x_msg_data				=> l_exception_msg_data,
			 x_exception_id			=> l_dummy_exception_id ,
			 p_logged_at_location_id   => l_ship_from_location_id,
			 p_exception_location_id   => l_ship_from_location_id,
			 p_logging_entity		  => 'SHIPPER',
			 p_logging_entity_id	   => FND_GLOBAL.USER_ID,
			 p_exception_name		  => 'WSH_PICK_HOLD',
			 p_message				 => l_msg,
			 p_error_message		   => l_exception_error_message,
			 p_request_id			  => l_request_id,
			 p_batch_id				=> WSH_PICK_LIST.g_batch_id				 -- Bug: 1729516
			 );

			 IF (l_exception_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_XC_UTIL.LOG_EXCEPTION DID NOT RETURN SUCCESS'  );
			END IF;
			--
			END IF;
--Bug: 1573703 Return status needs to be set to 'E'
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   raise header_hold_error;  --bugfix 6263535

		  END IF;
		END IF;

	  g_good_header_ids(l_good_index) := l_header_id;
          IF (p_activity_type = 'PICK') AND (WSH_PICK_LIST.G_BATCH_ID IS NOT NULL)
          AND (WSH_PICK_LIST.G_PICK_REL_PARALLEL) THEN
             Insert_PR_Header_Holds (p_header_id => l_header_id, p_status => 'P');
          END IF;

   END IF;

   --  2467416  changes Begin
   -- First Check in g_passed_crd_Tab, then in the g_failed_crd_Tab
   -- 3481194/3492870: hash indexes; if this is a new line,
   -- both l_passed_index and l_failed_index will be populated

   l_passed_index := get_table_index(p_entity_id=>l_line_id, x_table=>g_passed_crd_tab);
   IF g_passed_crd_Tab.exists(l_passed_index)  THEN
     l_exists_flag := 'Y';
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

   IF (l_exists_flag = 'N')  THEN
     l_failed_index := get_table_index(p_entity_id=>l_line_id, p_alt_index=>l_passed_index, x_table=>g_failed_crd_tab);
     IF g_failed_crd_Tab.exists(l_failed_index)  THEN
       l_exists_flag := 'Y';
       RAISE line_hold_error;
     END IF;
   END IF;

   -- 2467416 changes End

   -- Check line holds, only if the incoming line_id doesn't exists in the either passed/failed tables

   IF l_exists_flag = 'N' THEN

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_HOLDS_PUB.CHECK_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  oe_holds_pub.check_holds(
	 p_api_version			=> 1.0,
	 p_line_id			=> l_line_id,
		 p_wf_item			=> 'OEOL',
	 p_wf_activity				  => p_activity_type||'_LINE',
	 x_result_out				   => l_result_out,
	 x_return_status		 => x_return_status,
	 x_msg_count			 => l_msg_count,
	 x_msg_data			=> l_msg_data);

	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_result_out = FND_API.G_TRUE) THEN
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER LINE '||TO_CHAR ( L_LINE_ID ) ||' IS ON HOLD'  );
	   END IF;
	   --

	-- BUG#: 1549665 hwahdani - check if process was run from conc. request and
	-- and log exception

	-- 2467416
	   g_failed_crd_Tab(l_failed_index) := l_line_id;

	   l_request_id := fnd_global.conc_request_id;

	-- 1729516
	   IF ( l_request_id = -1 AND WSH_PICK_LIST.G_BATCH_ID IS NULL ) THEN
			 raise line_hold_error;
	   ELSE
		 FND_MESSAGE.SET_NAME('WSH','WSH_PICK_ORDER_LINE_HOLD');
		 FND_MESSAGE.SET_TOKEN('ORDER',l_order_number);
		 FND_MESSAGE.SET_TOKEN('LINE',l_line_number);
			 l_msg := FND_MESSAGE.GET;
			 --
			 -- Debug Statements
			 --
			 IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG  );
			 END IF;
			 --

		 l_dummy_exception_id :=null;
			 --
			 -- Debug Statements
			 --
			 IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;
			 --
			 wsh_xc_util.log_exception(
			 p_api_version			 => 1.0,
			 x_return_status		   => l_exception_return_status,
			 x_msg_count			   => l_exception_msg_count,
			 x_msg_data				=> l_exception_msg_data,
			 x_exception_id			=> l_dummy_exception_id ,
			 p_logged_at_location_id   => l_ship_from_location_id,
			 p_exception_location_id   => l_ship_from_location_id,
			 p_logging_entity		  => 'SHIPPER',
			 p_logging_entity_id	   => FND_GLOBAL.USER_ID,
			 p_exception_name		  => 'WSH_PICK_HOLD',
			 p_message				 => l_msg ,
			 p_error_message		   => l_exception_error_message,
			 p_request_id			  => l_request_id,
			 p_batch_id				=> WSH_PICK_LIST.g_batch_id				 -- Bug: 1729516
			 );

			IF (l_exception_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_XC_UTIL.LOG_EXCEPTION DID NOT RETURN SUCCESS'  );
			END IF;
			--
			END IF;
--Bug: 1573703 Return status needs to be set to 'E'
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   -- bug 2882720: set message in case the concurrent program rolls back so that the exception is gone.
		   IF p_activity_type = 'PICK' THEN
		      FND_MESSAGE.SET_NAME('WSH','WSH_PICK_LINE_HOLD_ERROR');
		      FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
		   ELSIF p_activity_type = 'PACK' THEN
		      FND_MESSAGE.SET_NAME('WSH','WSH_PACK_LINE_HOLD_ERROR');
		      FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
		   ELSE
		      FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_LINE_HOLD_ERROR');
		      FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
		   END IF;
		   wsh_util_core.add_message(x_return_status);
		   -- bug 2882720 change end

		   END IF;   /* 1729516  */

		ELSE
		 --   /* i.e. When HOLD is FALSE , No Hold on the Line */
		 -- 2467416
		  g_passed_crd_Tab(l_passed_index) := l_line_id;

		END IF;  /* if HOLD is TRUE */
   END IF;  /* if l_exists_flag = N */

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
         WHEN header_hold_error THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_HEADER_HOLD_ERROR');
		FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'HEADER_HOLD_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HEADER_HOLD_ERROR');
		END IF;

         WHEN line_hold_error THEN
                IF p_activity_type = 'PICK' THEN
  		   FND_MESSAGE.SET_NAME('WSH','WSH_PICK_LINE_HOLD_ERROR');
  		   FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
                ELSIF p_activity_type = 'PACK' THEN
   		   FND_MESSAGE.SET_NAME('WSH','WSH_PACK_LINE_HOLD_ERROR');
  		   FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
                ELSE
  		   FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_LINE_HOLD_ERROR');
  		   FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
  		END IF;
  		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  		wsh_util_core.add_message(x_return_status);
  		--
  		-- Debug Statements
  		--
  		IF l_debug_on THEN
  			WSH_DEBUG_SV.logmsg(l_module_name, p_activity_type ||'_LINE_HOLD_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
  			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:LINE_HOLD_ERROR');
		END IF;

	 WHEN credit_hold_error THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_CREDIT_HOLD_ERROR');
		FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'CREDIT_HOLD_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREDIT_HOLD_ERROR');
		END IF;
		--
	  WHEN others THEN
		wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.Check_Credit_Holds');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_credit_holds;



-----------------------------------------------------------------------------
--
-- Procedure:		check_quantity_to_pick
-- Parameters:		p_order_line_id,   - order line being picked
--					  p_quantity_to_pick - quantity to transact that
--										   will be checked
--					  x_allowed_flag - 'Y' = allowed, 'N' = not allowed
--					  x_max_quantity_allowed - maximum quantity
--											   that can be picked
--					  x_avail_req_quantity - req quantity not yet staged
--			x_return_status
-- Description:	   Checks if the quantity to pick is within overshipment
--					  tolerance, based on the quantities requested and
--					  staged and assignments to deliveries or containers.
--					  Also returns the maximum quantity allowed to pick.
-- History:			 HW Added Qty2 for OPM and changed procedure parameters
-----------------------------------------------------------------------------

PROCEDURE check_quantity_to_pick(
	p_order_line_id		   IN  NUMBER,
		p_quantity_to_pick		IN  NUMBER,
		p_quantity2_to_pick	   IN  NUMBER,
		x_allowed_flag			OUT NOCOPY  VARCHAR2,
		x_max_quantity_allowed	OUT NOCOPY  NUMBER,
		x_max_quantity2_allowed   OUT NOCOPY  NUMBER,
		x_avail_req_quantity	  OUT NOCOPY  NUMBER,
		x_avail_req_quantity2	 OUT NOCOPY  NUMBER,
	x_return_status		   OUT NOCOPY  VARCHAR2) IS


-- HW OPM retrieve uom2
CURSOR c_detail_info(x_source_line_id IN NUMBER) IS
  SELECT inventory_item_id,
		 organization_id,
		 requested_quantity_uom,
		 requested_quantity_uom2,
		 ship_tolerance_above,
		 ship_tolerance_below, -- 2181132 added following fields
		 source_header_id,
		 source_line_set_id,
		 source_code
  FROM   wsh_delivery_details
  WHERE  source_line_id = x_source_line_id
  AND	source_code = 'OE'  -- pick confirm supports only OE lines
  AND	container_flag = 'N'
  AND	released_status <> 'D'
  AND	rownum = 1;


-- HW OPM added qty2
-- along with Bug 2181132
-- change the cursor because it was not looking at shipped
-- quantity and there can be cases where shipped quantity is not
-- the same as picked quantity for a shipped delivery line
CURSOR c_detail_staged_quantities(x_source_line_id IN NUMBER) IS
  SELECT NVL(SUM(requested_quantity), 0) net_requested_qty,
		 NVL(SUM(decode (released_status,'C',nvl(shipped_quantity,0),
			 NVL(picked_quantity, requested_quantity))
			), 0) net_staged_qty,
		 --NVL(SUM(NVL(picked_quantity, requested_quantity)), 0) net_staged_qty,
		 NVL(SUM(NVL(requested_quantity2,0)), 0) net_requested_qty2,
		 NVL(SUM(NVL(picked_quantity2, requested_quantity2)), 0) net_staged_qty2
  FROM   wsh_delivery_details
  WHERE  source_line_id = x_source_line_id
  AND	source_code	= 'OE'
  AND	container_flag = 'N'
  AND	released_status IN ('X', 'Y', 'C');

-- HW OPMCONV -Retrieve Qty2 and UOM2

CURSOR c_ordered_quantity(x_source_line_id  IN NUMBER,
						  x_item_id		 IN NUMBER,
						  x_primary_uom	 IN VARCHAR2) IS
  SELECT WSH_WV_UTILS.CONVERT_UOM(order_quantity_uom,
				  x_primary_uom,
				  ordered_quantity,
				  x_item_id) quantity ,
		                  order_quantity_uom,
		                  ordered_quantity2,
		                  ordered_quantity_uom2
  FROM   oe_order_lines_all
  WHERE  line_id = x_source_line_id;


l_found_flag	  BOOLEAN;
l_detail_info	 c_detail_info%ROWTYPE;
l_staged_info	 c_detail_staged_quantities%ROWTYPE;
l_order_line	  c_ordered_quantity%ROWTYPE;
--HW OPM variable for OPM cursor
-- HW OPMCONV - No need for OPM specific cursor

quantity		  NUMBER;
l_max_quantity2   NUMBER;
l_min_quantity2   NUMBER;
l_max_quantity	NUMBER;
l_min_quantity	NUMBER;
l_msg_count	   NUMBER;
l_msg_data   VARCHAR2(2000);
l_return_status varchar2(30);

l_apps_uom_ordered_quantity NUMBER := 0; -- Bug 2922649

l_req_qty_left	NUMBER;
others	   EXCEPTION;

-- HW OPM new varibales
-- HW OPMCONV - No need for OPM local variables

l_req_qty2_left	NUMBER;

-- 2181132
  l_minmaxinrectype MinMaxInRecType;
  l_minmaxinoutrectype MinMaxInOutRecType;
  l_minmaxoutrectype MinMaxOutRecType;
  l_quantity_uom  WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE;
  l_quantity_uom2  WSH_DELIVERY_DETAILS.requested_quantity_uom2%TYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_QUANTITY_TO_PICK';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'P_ORDER_LINE_ID',P_ORDER_LINE_ID);
	  WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_PICK',P_QUANTITY_TO_PICK);
	  WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY2_TO_PICK',P_QUANTITY2_TO_PICK);
  END IF;
  --
  OPEN  c_detail_info(p_order_line_id);
  FETCH c_detail_info INTO l_detail_info;
  l_found_flag := c_detail_info%FOUND;
  CLOSE c_detail_info;

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
	FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
	x_allowed_flag		 := 'N';
	x_max_quantity_allowed := NULL;
	x_avail_req_quantity   := NULL;
	x_max_quantity2_allowed := NULL;
	x_avail_req_quantity2   := NULL;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN;
  END IF;

-- HW OPM Need to check the org for forking
  --
  -- Debug Statements
  --


  OPEN  c_detail_staged_quantities(p_order_line_id);
  FETCH c_detail_staged_quantities INTO l_staged_info;
  l_found_flag := c_detail_staged_quantities%FOUND;
  CLOSE c_detail_staged_quantities;

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
	FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
	x_allowed_flag		 := 'N';
	x_max_quantity_allowed := NULL;
	x_avail_req_quantity   := NULL;
	x_max_quantity2_allowed := NULL;
	x_avail_req_quantity2   := NULL;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN;
  END IF;

-- HW OPMCONV - No need to branch code
-- HW OPM for debugging puproses. Print values
-- HW OPM Need to branch

	OPEN  c_ordered_quantity(p_order_line_id,
	 l_detail_info.inventory_item_id,
	 l_detail_info.requested_quantity_uom);
	FETCH c_ordered_quantity INTO l_order_line;
	l_found_flag := c_ordered_quantity%FOUND;
	CLOSE c_ordered_quantity;

-- HW OPM Added qty2
  IF NOT l_found_flag THEN
	FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
	x_allowed_flag		 := 'N';
	x_max_quantity_allowed := NULL;
	x_avail_req_quantity   := NULL;
	x_max_quantity2_allowed := NULL;
	x_avail_req_quantity2   := NULL;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN;
  END IF;

  -- Debug Statements
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.GET_MIN_MAX_TOLERANCE_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
-- Bug 2181132

-- in attributes

	l_minmaxinrectype.source_code := l_detail_info.source_code;
	l_minmaxinrectype.line_id := p_order_line_id;
	l_minmaxinrectype.source_header_id := l_detail_info.source_header_id;
	l_minmaxinrectype.source_line_set_id := l_detail_info.source_line_set_id;
	l_minmaxinrectype.ship_tolerance_above := l_detail_info.ship_tolerance_above;
	l_minmaxinrectype.ship_tolerance_below := l_detail_info.ship_tolerance_below;
	l_minmaxinrectype.action_flag := 'P'; -- pick confirm
	l_minmaxinrectype.lock_flag := 'N';
	l_minmaxinrectype.quantity_uom := l_detail_info.requested_quantity_uom;
	l_minmaxinrectype.quantity_uom2 := l_detail_info.requested_quantity_uom2;

   WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
		(p_in_attributes  => l_minmaxinrectype,
		 x_out_attributes  => l_minmaxoutrectype,
		 p_inout_attributes  => l_minmaxinoutrectype,
		 x_return_status  => l_return_status,
		 x_msg_count  =>  l_msg_count,
		 x_msg_data => l_msg_data
		 );

	l_quantity_uom := l_minmaxoutrectype.quantity_uom;
	l_min_quantity := l_minmaxoutrectype.min_remaining_quantity;
	l_max_quantity := l_minmaxoutrectype.max_remaining_quantity;
	l_quantity_uom2 := l_minmaxoutrectype.quantity2_uom;
	l_min_quantity2 := l_minmaxoutrectype.min_remaining_quantity2;
	l_max_quantity2 := l_minmaxoutrectype.max_remaining_quantity2;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status'||l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'Max Qty'||l_max_quantity);
    WSH_DEBUG_SV.log(l_module_name,'Min Qty'||l_min_quantity);
    WSH_DEBUG_SV.log(l_module_name,'Qty UOM'||l_quantity_uom);
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
	raise others ;
  END IF;



-- HW OPMCONV - Need to branch

	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 l_max_quantity :=  l_max_quantity
			   - l_staged_info.net_staged_qty;


	  l_req_qty_left := GREATEST(0,
			 (l_order_line.quantity
			  - l_staged_info.net_requested_qty)
							);


	 l_max_quantity2 := nvl(l_max_quantity2,0) - nvl(l_staged_info.net_staged_qty2,0);

	 l_req_qty2_left := GREATEST(0,
			 (l_order_line.ordered_quantity2
			  - l_staged_info.net_requested_qty2)
							);

-- HW added for debugging purposes
-- HW OPMCONV - No need to branch

  IF p_quantity_to_pick < 0 THEN
	x_allowed_flag	:= 'N';
-- HW OPM added a checj for qty2
  ELSIF (p_quantity_to_pick > l_max_quantity) THEN
       -- Begin BUG 2675737
       -- OR
       -- nvl(p_quantity2_to_pick,0) > nvl(l_max_quantity2,0) THEN
       -- End   BUG 2675737
	x_allowed_flag	:= 'N';
  ELSE
	x_allowed_flag	:= 'Y';
  END IF;

  x_max_quantity_allowed := l_max_quantity;
  x_avail_req_quantity   := l_req_qty_left;
-- HW OPM added qty2
  x_max_quantity2_allowed := l_max_quantity2;
  x_avail_req_quantity2   := l_req_qty2_left;

-- HW OPMCONV _ Removed print statements
  -- HW for debugging purposes, print values

  x_return_status		:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN others THEN
	  IF c_detail_info%ISOPEN THEN
		CLOSE c_detail_info;
	  END IF;
	  IF c_detail_staged_quantities%ISOPEN THEN
		CLOSE c_detail_staged_quantities;
	  END IF;
	  IF c_ordered_quantity%ISOPEN THEN
		CLOSE c_ordered_quantity;
	  END IF;
-- HW closing OPM cursor

	  x_allowed_flag		 := 'N';
	  x_max_quantity_allowed := NULL;
	  x_avail_req_quantity   := NULL;
-- HW Added for OPM
	  x_max_quantity2_allowed := NULL;
	  x_avail_req_quantity2   := NULL;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.check_quantity_to_pick');

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_quantity_to_pick;

-- Overloaded  check_quantity_to_pick
-- Same as above procedure but is w/o
-- the quantity2's in the signature


PROCEDURE check_quantity_to_pick(
		p_order_line_id		   IN  NUMBER,
		p_quantity_to_pick		IN  NUMBER,
		x_allowed_flag			OUT NOCOPY  VARCHAR2,
		x_max_quantity_allowed	OUT NOCOPY  NUMBER,
		x_avail_req_quantity	  OUT NOCOPY  NUMBER,
		x_return_status		   OUT NOCOPY  VARCHAR2) IS

l_dummy_quantity2_to_pick	NUMBER;
l_dummy_max_quantity2_allowed   NUMBER;
l_dummy_avail_req_quantity2	NUMBER;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_QUANTITY_TO_PICK';
--
BEGIN

--
-- Debug Statements
--
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
	l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	--
	WSH_DEBUG_SV.log(l_module_name,'P_ORDER_LINE_ID',P_ORDER_LINE_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY_TO_PICK',P_QUANTITY_TO_PICK);
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_QUANTITY_TO_PICK',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_details_validations.check_quantity_to_pick(
		p_order_line_id		   => p_order_line_id,
		p_quantity_to_pick		=> p_quantity_to_pick,
		p_quantity2_to_pick	   => l_dummy_quantity2_to_pick,
		x_allowed_flag			=> x_allowed_flag,
		x_max_quantity_allowed	=> x_max_quantity_allowed,
		x_max_quantity2_allowed   => l_dummy_max_quantity2_allowed,
		x_avail_req_quantity	  => x_avail_req_quantity,
		x_avail_req_quantity2	 => l_dummy_avail_req_quantity2,
		x_return_status		   => x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN OTHERS THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.check_quantity_to_pick');

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_quantity_to_pick;


-----------------------------------------------------------------------------
--
-- Procedure:		check_zero_req_confirm
-- Parameters:		p_delivery_id	  - delivery being confirmed
--			x_return_status
-- Description:	   Ensure that delivery details with zero requested
--					  quantities will not be alone after Ship Confirm.
--
-----------------------------------------------------------------------------

PROCEDURE check_zero_req_confirm(
	p_delivery_id		  IN  NUMBER,
	x_return_status		OUT NOCOPY  VARCHAR2) IS

  CURSOR c_check_qty_inside_del (del_id IN NUMBER) IS
  select sum(wdd.requested_quantity), wdd.source_code, wdd.source_line_id
  from wsh_delivery_details wdd, wsh_delivery_assignments_v wda
  where wdd.delivery_detail_id = wda.delivery_detail_id
  and wda.delivery_id is not null
  and wda.delivery_id = del_id
  and wdd.released_status <> 'D'
  group by source_line_id, source_code
  having sum(wdd.requested_quantity) = 0;


  CURSOR c_source_info IS
  select distinct wdd.source_line_id, wdd.source_code
  from wsh_delivery_details wdd, wsh_delivery_assignments_v wda
  where wdd.delivery_detail_id = wda.delivery_detail_id
  and wdd.released_status <> 'D'
  and wda.delivery_id is not null
  and wda.delivery_id = p_delivery_id;

  l_req_qty		NUMBER;
  l_source_code	VARCHAR2(3);
  l_source_line_id NUMBER;

  req_qty_zero EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ZERO_REQ_CONFIRM';
--
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  open c_check_qty_inside_del (p_delivery_id);
  fetch c_check_qty_inside_del into l_req_qty, l_source_code, l_source_line_id;
  IF c_check_qty_inside_del%FOUND THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_REQ_ZERO_INSIDE_ERROR');
	close c_check_qty_inside_del;
	raise req_qty_zero;
  END IF;
  close c_check_qty_inside_del;

  FOR source_rec IN c_source_info LOOP
      BEGIN
         select sum(wdd.requested_quantity)
         into   l_req_qty
         from   wsh_delivery_details wdd, wsh_delivery_assignments_v wda, wsh_new_deliveries wnd
         where  wdd.delivery_detail_id = wda.delivery_detail_id
         and    wnd.delivery_id(+) = wda.delivery_id
         and    (wda.delivery_id <> p_delivery_id or wda.delivery_id is NULL)
         and    wdd.released_status not in ('C', 'D')
         and    NVL(wnd.status_code,'OP') <> 'CO'
         and    wdd.source_line_id = source_rec.source_line_id
         and    wdd.source_code = source_rec.source_code
         having sum(wdd.requested_quantity) = 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_req_qty := 99;
      END;

      IF l_req_qty = 0 THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_REQ_ZERO_OUTSIDE_ERROR');
         l_source_line_id := source_rec.source_line_id;
         l_source_code := source_rec.source_code;
         raise req_qty_zero;
      END IF;
  END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION

	WHEN req_qty_zero THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_TOKEN('DELIVERY', p_delivery_id);
	  FND_MESSAGE.SET_TOKEN('SOURCE_CODE', l_source_code);
	  FND_MESSAGE.SET_TOKEN('SOURCE_LINE', l_source_line_id);
	  wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'REQ_QTY_ZERO exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REQ_QTY_ZERO');
END IF;
--
	WHEN others THEN
	  IF c_check_qty_inside_del%ISOPEN THEN
		close c_check_qty_inside_del;
	  END IF;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.check_zero_req_confirm');

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_zero_req_confirm;


--
--  Procedure:	 Get_Disabled_List
--
--  Parameters:	  p_detail_id -- ID for delivery detail
--						p_delivery_id -- delivery the detail is assigned to
--				p_list_type -- 'FORM', will return list of form field names
--							   'TABLE', will return list of table column names
--				x_return_status  -- return status for execution of this API
--				x_msg_count -- number of error message
--				x_msg_data  -- error message if API failed
--
PROCEDURE Get_Disabled_List(
  p_delivery_detail_id		   IN	 NUMBER
, p_delivery_id			   IN	NUMBER
, p_list_type						 IN	 VARCHAR2
, x_return_status				OUT NOCOPY	  VARCHAR2
, x_disabled_list				OUT NOCOPY	  WSH_UTIL_CORE.column_tab_type
, x_msg_count						OUT NOCOPY	NUMBER
, x_msg_data						OUT NOCOPY	  VARCHAR2
, p_caller IN VARCHAR2 -- DEFAULT NULL, --public api changes
)
IS

CURSOR get_delivery_status
IS
SELECT status_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

-- OPM 09/11/00
CURSOR dd_info
IS
SELECT requested_quantity_uom2,
	  nvl(inspection_flag,'N'),
	   released_status,
	   picked_quantity,
	   container_flag,
	   organization_id,
	   inventory_item_id,
	   pickable_flag,
	   subinventory,
           source_code,
           inventory_item_id,
           nvl(line_direction,'O') line_direction   -- J-IB-NPARIKH
FROM wsh_delivery_details
WHERE delivery_detail_id = p_delivery_detail_id;

-- end of OPM 09/11/00

l_status_code			  VARCHAR2(2);
-- OPM 09/11/00 variables to hold value of qty_uom2
l_qty_uom2					  VARCHAR2(3);
-- end of OPM 09/11/00
i								NUMBER := 0;
WSH_DP_NO_ENTITY		  EXCEPTION;
WSH_DEL_NOT_EXIST				EXCEPTION; -- Bug fix 2650464
WSH_INV_LIST_TYPE		 EXCEPTION;
l_msg_summary		   VARCHAR2(2000) := NULL;
l_msg_details		   VARCHAR2(4000) := NULL;
l_inspection_flag	   VARCHAR2(1)	:= NULL;
l_released_status	   VARCHAR2(1)	:= NULL;
l_picked_quantity	   NUMBER;
l_container_flag		VARCHAR2(1)   := 'N';
l_organization_id	   NUMBER;
l_item_id			   NUMBER;
l_pickable_flag		 VARCHAR2(1);
l_subinventory		  VARCHAR2(30);
l_line_direction      VARCHAR2(30);
l_inv_controls		  WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;

-- BUG FIX 2887330
l_inventory_item_id      NUMBER;
l_reservable_flag        VARCHAR2(1);
l_source_code            VARCHAR2(30);
l_delivery_detail_id	NUMBER;
l_delivery_id		NUMBER;
l_debug_on BOOLEAN;

e_all_disabled EXCEPTION ; --public api changes

--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';
--
BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
	   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
	   WSH_DEBUG_SV.push(l_module_name);
	   --
	   WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- clear the disabled list first
   x_disabled_list.delete;
   -- OPM 09/11/00
   OPEN dd_info;
   FETCH dd_info
   INTO l_qty_uom2,
		l_inspection_flag,
		l_released_status,
		l_picked_quantity,
		l_container_flag,l_organization_id,
		l_item_id, l_pickable_flag, l_subinventory,
                l_source_code, l_inventory_item_id, l_line_direction;

   IF (dd_info%NOTFOUND) THEN
	  CLOSE dd_info ;
	  RAISE wsh_dp_no_entity;
   END IF;
   CLOSE dd_info ;
   --
   -- J-IB-NPARIKH-{
   --
   IF l_line_direction NOT IN ('O','IO')
   THEN
   --{
        --
        i:=i+1; x_disabled_list(i) := 'FULL';
        --
        IF l_released_status = 'X'
        THEN
        --{
            i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
            i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
            i:=i+1; x_disabled_list(i) := 'SHIPPING_INSTRUCTIONS';
            i:=i+1; x_disabled_list(i) := 'PACKING_INSTRUCTIONS';
            i:=i+1; x_disabled_list(i) := 'TRACKING_NUMBER';
            i:=i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'TARE_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'VOLUME';
        --}
        ELSIF l_released_status IN ('C','L','P')
        THEN
        --{
            i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
            i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
            i:=i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'TARE_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'VOLUME';
            --
            IF l_released_status = 'C'
            THEN
                i:=i+1; x_disabled_list(i) := 'TRACKING_NUMBER';
            END IF;
        --}
        END IF;
        --
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
   --}
   END IF;
   --
   -- J-IB-NPARIKH-}
   --

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_RESERVABLE_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;

   l_reservable_flag :=  WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                             x_item_id => l_inventory_item_id,
                             x_organization_id => l_organization_id,
                             x_pickable_flag => l_pickable_flag);
     if l_debug_on then
        wsh_debug_sv.log(l_module_name, 'l_reservable_flag', l_reservable_flag);
        wsh_debug_sv.log(l_module_name, 'l_pickable_flag', l_pickable_flag);
        wsh_debug_sv.log(l_module_name, 'l_source_code', l_source_code);
     end if;

   -- If delivery line is released to warehouse, shipped, or deleted,
   -- disable its fields.
   -- :Bug #2586286  : Enabled the DESC_FLEX even when relead_status 'C' or 'D'
   IF (l_released_status IN ('S', 'C', 'D')) THEN
	  i:=i+1; x_disabled_list(i) := 'FULL';
	  i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
          if l_debug_on then
            wsh_debug_sv.log(l_module_name, 'l_released_status', l_released_status);
            wsh_debug_sv.log(l_module_name, 'l_picked_quantity', l_picked_quantity);
          end if;
	  IF ( l_released_status = 'S'
		   AND l_picked_quantity IS NULL) THEN
		 -- can update some fields if the delivery line
		 -- is released to warehouse and is not pending overpick.
		 i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
		 --i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
		 i:=i+1; x_disabled_list(i) := 'SHIPPING_INSTRUCTIONS';
		 i:=i+1; x_disabled_list(i) := 'PACKING_INSTRUCTIONS';
		 i:=i+1; x_disabled_list(i) := 'TRACKING_NUMBER';
		 i:=i+1; x_disabled_list(i) := 'SEAL_CODE';
                 --X-dock change, allow update from WMS for X-dock lines
                 IF p_caller like 'WMS_XDOCK%' THEN
                   i:=i+1; x_disabled_list(i) := 'RELEASED_STATUS';
                 END IF;
	  END IF;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN;

   END IF;

   IF p_delivery_id is NOT NULL THEN

	  OPEN get_delivery_status;
	  FETCH get_delivery_status INTO l_status_code;
	  IF (get_delivery_status%NOTFOUND) THEN
		 CLOSE get_delivery_status;
		 -- Bug fix 2650464
		 RAISE WSH_DEL_NOT_EXIST;
	  END IF;
	  CLOSE get_delivery_status;

   END IF;


   -- OPM 09/11/00  if line is not assigned, need to add OPM attributes to list
   IF (p_delivery_id IS NULL) OR (l_status_code IN ('OP','PA', 'SA')) THEN

	  -- disabling the gross and tare weights for non-container items
	  -- bug fix 2061295

	  -- commenting the gross weight to make it enable for non-container items
	  -- for the bug #2554087
          -- Commenting the Tare Weight Field to make it enable for
          -- non-container items for bug 2890559
/*
	  IF (l_container_flag = 'N') THEN
	--   i := i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
		 i := i+1; x_disabled_list(i) := 'TARE_WEIGHT';
	  END IF;
*/

	  IF (l_released_status NOT IN ('X', 'Y')) THEN

		 i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY';
		 i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY2';

	  END IF;  -- if l_released_status...

	  IF (l_source_code NOT IN ('OE','WSH','OKE')) THEN --RTV changes
		i:=i+1; x_disabled_list(i) := 'REVISION';
		i:=i+1; x_disabled_list(i) := 'LOT_NUMBER';
		i:=i+1; x_disabled_list(i) := 'SUBINVENTORY';
    i:=i+1; x_disabled_list(i) := 'SERIAL_NUMBER';
    i:=i+1; x_disabled_list(i) := 'LOCATOR_ID';
	  END IF;

	  IF (l_qty_uom2 is NULL) THEN
		 i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY2';
		 i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY2';
		 i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY2';
		 i:=i+1; x_disabled_list(i) := 'CYCLE_COUNT_QUANTITY2';
	  END IF;

	  IF (l_inspection_flag = 'N') THEN
		 i:=i+1; x_disabled_list(i) := 'INSPECTION_FLAG';
	  END IF;

        -- LPN sync-up
        IF (l_container_flag = 'N') THEN
		i:=i+1; x_disabled_list(i) := 'CONTAINER_NAME';
		i:=i+1; x_disabled_list(i) := 'LPN_ID';
        END IF;

        -- R12 MDC
	IF l_container_flag = 'C'  and NVL(p_caller, 'WSH_FSTRX') not like 'WMS%' THEN
	   i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
	END IF;
        --

	ELSIF p_delivery_id is not NULL THEN

	  IF (l_status_code = 'PA') THEN
		 i:=i+1; x_disabled_list(i) := 'CONTAINER_NAME';
 		 -- LPN sync-up
        	 IF (l_container_flag = 'N') THEN
			i:=i+1; x_disabled_list(i) := 'LPN_ID';
             END IF;

		 IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --public api changes
                    i:=i+1; x_disabled_list(i) := 'MASTER_CONTAINER_ITEM_ID';
                    i:=i+1; x_disabled_list(i) := 'DETAIL_CONTAINER_ITEM_ID';
		 ELSE
                    i:=i+1; x_disabled_list(i) := 'MASTER_CONTAINER_ITEM_NAME';
                    i:=i+1; x_disabled_list(i) := 'DETAIL_CONTAINER_ITEM_NAME';
		 END IF;
		 i:=i+1; x_disabled_list(i) := 'LOAD_SEQ_NUMBER';

		 /* H integration: 940 data protection  wrudge */
	  ELSIF (l_status_code IN ('SR', 'SC')) THEN
		 i:=i+1; x_disabled_list(i) := 'FULL';
		 i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
		 i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
		 i:=i+1; x_disabled_list(i) := 'SHIPPING_INSTRUCTIONS';
		 i:=i+1; x_disabled_list(i) := 'PACKING_INSTRUCTIONS';
		 i:=i+1; x_disabled_list(i) := 'TRACKING_NUMBER';
		 i:=i+1; x_disabled_list(i) := 'SEAL_CODE';
	  ELSIF (l_status_code IN ('CO', 'IT', 'CL')) THEN
		 i:=i+1; x_disabled_list(i) := 'FULL';
		 i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
		 i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
		 IF (l_status_code = 'IT') THEN
			i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY';
			-- LPN sync-up
             	IF (nvl(l_container_flag, 'N') = 'N') THEN
				i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY';
			END IF;

			-- OPM 09/11/00
			-- if process_org, then add the following to the list
			IF (l_qty_uom2 is NOT NULL) THEN
			   -- LPN sync-up
             	   IF (nvl(l_container_flag, 'N') = 'N') THEN
			   	i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY2';
			   	i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY2';
			   END IF;
			END IF;

		 ELSIF (l_status_code = 'CO') THEN
			i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY';
			-- LPN sync-up
             	IF (nvl(l_container_flag, 'N') = 'N') THEN
				i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY';
			END IF;
			i:=i+1; x_disabled_list(i) := 'SHIPPING_INSTRUCTIONS';
			i:=i+1; x_disabled_list(i) := 'TRACKING_NUMBER';
			i:=i+1; x_disabled_list(i) := 'SEAL_CODE';
			IF (l_qty_uom2 is NOT NULL) THEN
				-- LPN sync-up
             		IF (nvl(l_container_flag, 'N') = 'N') THEN
			   		i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY2';
			   		i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY2';
				END IF;
			END IF;
			-- OPM 09/11/00
		 END IF;
	  END IF;  -- (l_status_code = 'PA')

   END IF; -- assigned to delviery

   -- bug 2263249 - added SHIPPED_QUANTITY, SHIPPED_QUANTITY2, CYCLE_COUNT_QUANTITY, and CYCLE_COUNT_QUANTITY2
   --			   to disable_list when organization is wms enabled.
   IF ((i = 0) OR (i > 0 AND x_disabled_list(1) <> 'FULL') ) THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.CHECK_WMS_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  IF (wsh_util_validate.Check_Wms_Org(l_organization_id)='Y') THEN
             -- Bug fix 2887330
             -- Disable shipped qty only if item is reservable, transactable and has source code = OM
             -- Or in otherwords, shipped qty should be enabled if item is
             -- non-reservable OR item is non-transactable OR has source code <> OM
             IF l_pickable_flag = 'Y' AND
                l_reservable_flag = 'Y' AND
                l_source_code = 'OE'
             THEN
		 i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY';
             END IF;
		 i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY2';
		 i:=i+1; x_disabled_list(i) := 'CYCLE_COUNT_QUANTITY';
		 i:=i+1; x_disabled_list(i) := 'CYCLE_COUNT_QUANTITY2';

 		 -- LPN sync-up
             IF (nvl(l_container_flag, 'N') IN ('Y','C')) THEN
			i:=i+1; x_disabled_list(i) := 'CONTAINER_NAME';
		 END IF;

	  END IF;
          -- J: W/V Changes
          IF l_container_flag = 'N' THEN
             i:=i+1; x_disabled_list(i) := 'FILLED_VOLUME';
             i:=i+1; x_disabled_list(i) := 'FILL_PERCENT';
          END IF;

   END IF;

   -- LPN sync-up
   IF ((i = 0) OR (i > 0 AND x_disabled_list(1) <> 'FULL') ) THEN
	i := x_disabled_list.COUNT;
	IF (nvl(l_container_flag, 'N') IN ('Y','C')) THEN
		i:=i+1; x_disabled_list(i) := 'PREFERED_GRADE';
		i:=i+1; x_disabled_list(i) := 'SRC_REQUESTED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'SRC_REQUESTED_QUANTITY_UOM2';
		i:=i+1; x_disabled_list(i) := 'REQUESTED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'DELIVERED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'QUALITY_CONTROL_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'CYCLE_COUNT_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'REQUESTED_QUANTITY_UOM2';
		i:=i+1; x_disabled_list(i) := 'SUBLOT_NUMBER';
		i:=i+1; x_disabled_list(i) := 'RETURNED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'RECEIVED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'PICKED_QUANTITY2';
		i:=i+1; x_disabled_list(i) := 'TO_SERIAL_NUMBER';
		i:=i+1; x_disabled_list(i) := 'TRANSACTION_TEMP_ID';
		i:=i+1; x_disabled_list(i) := 'SHIPPED_QUANTITY';
		i:=i+1; x_disabled_list(i) := 'CANCELLED_QUANTITY';
		i:=i+1; x_disabled_list(i) := 'CYCLE_COUNT_QUANTITY';
		i:=i+1; x_disabled_list(i) := 'REQUESTED_QUANTITY_UOM';
    i:=i+1; x_disabled_list(i) := 'REVISION';
	  i:=i+1; x_disabled_list(i) := 'LOT_NUMBER';
	  i:=i+1; x_disabled_list(i) := 'SUBINVENTORY';
    i:=i+1; x_disabled_list(i) := 'SERIAL_NUMBER';

		IF nvl(p_caller, '!!!') LIKE 'FTE%' THEN
			i:=i+1; x_disabled_list(i) := 'LOCATOR_ID';
		ELSE
			i:=i+1; x_disabled_list(i) := 'LOCATOR_NAME';
		END IF;
	END IF;

   END IF;
   -- end bug 2263249

    -- J-IB-NPARIKH-{
    -- public api changes
    --
    -- Update on inbound/drop-ship lines are allowed only if caller
    -- starts with  one of the following:
    --     - FTE
    --     - WSH_IB
    --     - WSH_PUB
    --     - WSH_TP_RELEASE
    --
    IF  NVL(l_line_direction,'O') NOT IN   ('O','IO')
    AND NVL(p_caller, '!!!') NOT LIKE 'FTE%'
    AND NVL(p_caller, '!!!') NOT LIKE 'WSH_PUB%'
    AND NVL(p_caller, '!!!') NOT LIKE 'WSH_IB%'
    AND NVL(p_caller, '!!!') NOT LIKE 'WSH_TP_RELEASE%'
    THEN
        RAISE e_all_disabled;
    END IF;
    --
    -- J-IB-NPARIKH-}

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'count of x_disabled_list', x_disabled_list.COUNT);
    END IF;
  -- public api changes
  IF (x_disabled_list.COUNT = 0) or (x_disabled_list(1) <> 'FULL') THEN
      i :=  x_disabled_list.COUNT;

      IF (l_released_status = 'Y')  THEN

         IF (WSH_DELIVERY_DETAILS_INV.get_reservable_flag(x_item_id => l_item_id,
                                                          x_organization_id => l_organization_id,
                                                          x_pickable_flag => l_pickable_flag) = 'Y')
         THEN

             i:=i+1; x_disabled_list(i) := 'SUBINVENTORY';
             i:=i+1; x_disabled_list(i) := 'REVISION';
	     IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --public api changes
                i:=i+1; x_disabled_list(i) := 'LOCATOR_ID';
	     ELSE
                i:=i+1; x_disabled_list(i) := 'LOCATOR_NAME';
	     END IF;
             i:=i+1; x_disabled_list(i) := 'LOT_NUMBER';

         ELSE
            -- Added for bug 4399278, 4418754
            -- Copy Subinventory passed from public API
            IF ( G_SUBINVENTORY is not null ) THEN
               l_subinventory := G_SUBINVENTORY;
               G_SUBINVENTORY := NULL;
            END IF;


            WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls(p_delivery_detail_id => p_delivery_detail_id,
                                                        p_inventory_item_id => l_item_id,
                                                        p_organization_id => l_organization_id,
                                                        p_subinventory => l_subinventory,
                                                        x_inv_controls_rec => l_inv_controls,
                                                        x_return_status => x_return_status);

            IF l_inv_controls.rev_flag = 'N' THEN

               i:=i+1; x_disabled_list(i) := 'REVISION';

            END IF;
            IF l_inv_controls.loc_flag = 'N' THEN

	     IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --public api changes
                i:=i+1; x_disabled_list(i) := 'LOCATOR_ID';
	     ELSE
                i:=i+1; x_disabled_list(i) := 'LOCATOR_NAME';
	     END IF;


            END IF;
            IF l_inv_controls.lot_flag = 'N' THEN

             i:=i+1; x_disabled_list(i) := 'LOT_NUMBER';

            END IF;

         END IF;

      END IF;  -- if l_released_status...

    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	EXCEPTION
	    WHEN e_all_disabled THEN --public api changes
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
	      FND_MESSAGE.Set_Token('ENTITY_ID',p_delivery_detail_id);
	      wsh_util_core.add_message(x_return_status,l_module_name);
	      IF l_debug_on THEN
		-- Nothing is updateable
		WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
	      END IF;

		WHEN wsh_dp_no_entity THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- Bug fix 2650464
			-- new message for invalid delivery details
			FND_MESSAGE.SET_NAME('WSH', 'WSH_DETAIL_NOT_EXIST');
                        IF p_delivery_detail_id = FND_API.G_MISS_NUM THEN
                         l_delivery_detail_id := NULL;
			ELSE
			 l_delivery_detail_id := p_delivery_detail_id;
			END IF;
			FND_MESSAGE.SET_TOKEN('DETAIL_ID', l_delivery_detail_id);
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
			IF x_msg_count > 1 then
		 	  x_msg_data := l_msg_summary || l_msg_details;
			ELSE
			  x_msg_data := l_msg_summary;
			END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
END IF;
--
		WHEN wsh_del_not_exist THEN  -- Bug fix 2650464
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('WSH', 'WSH_DELIVERY_NOT_EXIST');
			IF p_delivery_id = FND_API.G_MISS_NUM THEN
			  l_delivery_id := NULL;
                        ELSE
                          l_delivery_id := p_delivery_id;
                        END IF;
			FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_delivery_id);
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
			IF x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			ELSE
				x_msg_data := l_msg_summary;
			END IF;
                        --
			IF l_debug_on THEN
			  WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DEL_NOT_EXIST exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
			END IF;

		WHEN wsh_inv_list_type THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
			IF x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			ELSE
				x_msg_data := l_msg_summary;
			END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
END IF;
--
		 WHEN others THEN
			IF (get_delivery_status%ISOPEN) THEN
				CLOSE get_delivery_status;
			END IF;
			wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.get_disabled_list');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;


	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Get_Disabled_list;


--
-- PROCEDURE - Get_Min_Max_Tolerance_Quantity
-- Bug 2181132
--
-- Description - This API is created to take owner ship of Tolerance from OM
-- Parameters are
--  p_in_attributes - In record of type MinMaxInRecType
--        action_flag values:
--              'P' - Pick confirm (always populate ship_tolerance_above etc.)
--              'S' - Ship confirm (always populate ship_tolerance_above etc.)
--              'C' - CTO / call from WSH_INTEGRATION API
--              'I' - call from OM Interface (check_tolerance)
--  x_out_attributes - Out record of type MinMaxOutRecType
--  p_inout_attributes - In Out record of type MinMaxInOutRecType
--  x_return_status - return status
--  x_msg_count - Message Count
--  x_msg_data - Message Data
--

PROCEDURE Get_Min_Max_Tolerance_Quantity
	( p_in_attributes	IN	         MinMaxInRecType,
	  x_out_attributes	   OUT NOCOPY	 MinMaxOutRecType,
	  p_inout_attributes	IN OUT NOCOPY    MinMaxInOutRecType,
	  x_return_status	   OUT NOCOPY	 VARCHAR2,
	  x_msg_count		   OUT NOCOPY	 NUMBER,
	  x_msg_data		   OUT NOCOPY	 VARCHAR2
	)
IS
  l_quantity_uom	     VARCHAR2(3);
  l_min_remaining_quantity   NUMBER;
  l_max_remaining_quantity   NUMBER;
  l_quantity2_uom	     VARCHAR2(3);
  l_min_remaining_quantity2  NUMBER;
  l_max_remaining_quantity2  NUMBER;
  l_shipped_quantity	     NUMBER;
  l_shipped_quantity2	     NUMBER;

  -- cannot combine Cursor 1 and 2 because of <> line_id clause
  -- Get the sum within line set id
  -- HW added requested_quantity2
  CURSOR c_sum_ordered_qty(x_header_id IN NUMBER, x_line_set_id IN NUMBER) IS
  SELECT SUM(requested_quantity),
         SUM(NVL(requested_quantity2,0))
	FROM  wsh_delivery_details
   WHERE  source_line_set_id = x_line_set_id
	 AND  source_code = p_in_attributes.source_code
	 AND  container_flag = 'N'
	 AND  released_status <> 'D'
	 AND  source_header_id = x_header_id;

  -- Get the sum within line set id for staged and shipped lines
  -- but with different source_line_id
  -- same for shipped or picked lines
  -- HW added qty2
  CURSOR c_sum_picked_qty(x_header_id IN NUMBER, x_line_set_id IN NUMBER) IS
  SELECT nvl(SUM(GREATEST(nvl(shipped_quantity,0),
			 nvl(picked_quantity,requested_quantity))),0),
	 nvl(SUM(GREATEST(nvl(shipped_quantity2,0),
			 nvl(picked_quantity2,requested_quantity2))),0)
	FROM wsh_delivery_details
   WHERE  source_line_set_id = x_line_set_id
	 AND released_status <> 'D'
	 AND source_line_id <> p_in_attributes.line_id
	 AND source_code = p_in_attributes.source_code
	 AND  container_flag = 'N'
	 AND source_header_id = x_header_id;

  -- bug 4319050: CTO can call before the line actually gets interfaced.
  -- get the total quantity that has left the warehouse.
  --   oe_interfaced_flag is not checked because we are looking
  --   at the single line; if it were interfaced at this time,
  --   the line would not be split (since line_set_id has to be NULL
  --   to use this cursor) and therefore the source line is fulfilled.
  CURSOR c_sum_line_shp_qty IS
  SELECT NVL(SUM(shipped_quantity), 0),
     NVL(SUM(shipped_quantity2), 0) --Bug#9437761
  FROM wsh_delivery_details
  WHERE  source_line_id = p_in_attributes.line_id
  AND  released_status = 'C'
  AND  source_code = p_in_attributes.source_code
  AND  container_flag = 'N';


  -- this is a line set version of c_sum_line_shp_qty
  --  sum the current line's shipped quantities
  --  and those of only the interfaced lines in the set.
  CURSOR c_sum_line_set_shp_qty(x_header_id   IN NUMBER,
                                x_line_set_id IN NUMBER) IS
  SELECT NVL(SUM(shipped_quantity), 0),
         NVL(SUM(shipped_quantity2), 0) --Bug#9437761
  FROM wsh_delivery_details
  WHERE source_code = p_in_attributes.source_code
  AND released_status = 'C'
  AND (
          source_line_id = p_in_attributes.line_id
       OR oe_interfaced_flag = 'Y'
      )
  AND container_flag = 'N'
  AND source_header_id = x_header_id
  AND source_line_set_id = x_line_set_id;


  -- bug 5196082: ITS needs to recognize the full quantity shipped
  -- regardless of oe_interfaced_flag value.
  -- this cursor is copied from  c_sum_line_set_shp_qty
  -- and modified to total all shipped details in the line set.
  CURSOR c_sum_line_set_shp_qty_ITS(x_header_id   IN NUMBER,
                                    x_line_set_id IN NUMBER) IS
  SELECT NVL(SUM(shipped_quantity), 0),
         NVL(SUM(shipped_quantity2), 0) --Bug#9437761
  FROM wsh_delivery_details
  WHERE source_code = p_in_attributes.source_code
  AND released_status = 'C'
  AND container_flag = 'N'
  AND source_header_id = x_header_id
  AND source_line_set_id = x_line_set_id;


  -- get delivery details information for CTO which will pass
  -- source_line_id and source_code
  CURSOR c_get_details_CTO IS
	SELECT ship_tolerance_below,
		   ship_tolerance_above,
		   source_line_set_id,
		   source_header_id,
		   src_requested_quantity_uom,
		   inventory_item_id,
		   requested_quantity_uom
	  FROM wsh_delivery_details
	 WHERE source_line_id = p_in_attributes.line_id
	   AND container_flag = 'N'
	   AND released_status <> 'D'
	   AND source_code = p_in_attributes.source_code
	   AND rownum = 1;

  -- Get the total ordered quantity, when the line set id is NULL

  -- HW added requested_quantity2

  CURSOR c_sum_ordered_qty1(x_header_id number) IS
  SELECT  SUM(requested_quantity),
          SUM(NVL(requested_quantity2,0))
	FROM  wsh_delivery_details
   WHERE  source_line_id =p_in_attributes.line_id
	 AND  source_code = p_in_attributes.source_code
	 AND  container_flag = 'N'
	 AND  released_status <> 'D'
	 AND  source_header_id = x_header_id;

  -- Lock the Delivery Details within a line set
  CURSOR c_lock_delivery_det(x_header_id IN NUMBER,
                           x_line_set_id IN NUMBER) IS
	SELECT delivery_detail_id
	  FROM wsh_delivery_details
	 WHERE source_line_set_id = x_line_set_id
	   AND source_code = p_in_attributes.source_code
	   AND source_header_id = x_header_id
         FOR UPDATE;

  -- Lock the Delivery Details within a source line id
  CURSOR c_lock_delivery_det1 IS
	SELECT delivery_detail_id
	  FROM wsh_delivery_details
	 WHERE source_line_id = p_in_attributes.line_id
	   FOR UPDATE;

  l_ship_tolerance_above        NUMBER;
  l_ship_tolerance_below        NUMBER;
  l_source_line_set_id          NUMBER;
  l_source_header_id            NUMBER;
  l_req_quantity_uom            VARCHAR2(3);
  l_req_quantity_uom2           VARCHAR2(3);
  l_shipping_quantity_uom       VARCHAR2(3);
  l_del_shipping_quantity       NUMBER;
  -- HW added l_del_shipping_quantity2
  l_del_shipping_quantity2      NUMBER;
  l_OPM_shipped_quantity        NUMBER(19,9);
  l_OPM_shipping_quantity_uom   VARCHAR2(4);
  l_OPM_order_quantity_uom      VARCHAR2(4);
  l_inventory_item_id           NUMBER;
  l_delivery_detail_id          NUMBER;
  l_total_ordered_quantity      NUMBER;
  l_total_ordered_quantity2     NUMBER;
  l_tolerance_quantity_below    NUMBER;
  l_tolerance_quantity_above    NUMBER;
  l_tolerance_quantity_below2   NUMBER;
  l_tolerance_quantity_above2   NUMBER;
  -- csun max_tol chnage
  l_ordered_quantity_uom    wsh_delivery_details.SRC_REQUESTED_QUANTITY_UOM%TYPE;
  l_requested_quantity_uom  wsh_delivery_details.REQUESTED_QUANTITY_UOM%TYPE;
  l_requested_quantity_uom2  wsh_delivery_details.REQUESTED_QUANTITY_UOM2%TYPE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MIN_MAX_TOLERANCE_QUANTITY';
--
BEGIN
-- Bug 2181132
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_del_shipping_quantity  := 0;
  l_del_shipping_quantity2 := 0;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'api_version_number',p_in_attributes.api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'source_code',p_in_attributes.source_code);
    WSH_DEBUG_SV.log(l_module_name,'line_id',p_in_attributes.line_id);
    WSH_DEBUG_SV.log(l_module_name,'dummy_quantity',p_inout_attributes.dummy_quantity);
    WSH_DEBUG_SV.logmsg(l_module_name, 'Action flag-'||p_in_attributes.action_flag);
    WSH_DEBUG_SV.logmsg(l_module_name, 'SHP TOL ABOVE-'||p_in_attributes.ship_tolerance_above);
  END IF;

  IF ( p_in_attributes.source_code IS NULL ) THEN
    x_msg_count := 1;
    x_msg_data := 'INVALID SOURCE_CODE';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_in_attributes.ship_tolerance_above IS NULL  OR
     p_in_attributes.action_flag IN ('C', 'I') THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Looking up details');
    END IF;

    -- fetch the values for CTO and OM Interface
    OPEN c_get_details_CTO;
    FETCH c_get_details_CTO
    INTO l_ship_tolerance_below,
	 l_ship_tolerance_above,
	 l_source_line_set_id,
	 l_source_header_id,
	 l_ordered_quantity_uom,
	 l_inventory_item_id,
	 l_requested_quantity_uom;
    CLOSE c_get_details_CTO;
  ELSE
    -- these values will be passed from Pick Confirm and Ship Confirm
    -- because this is delivery line information and should be
    -- available without extra SELECT
    l_ship_tolerance_below    := p_in_attributes.ship_tolerance_below;
    l_ship_tolerance_above    := p_in_attributes.ship_tolerance_above;
    l_source_line_set_id      := p_in_attributes.source_line_set_id;
    l_source_header_id        := p_in_attributes.source_header_id;
    l_requested_quantity_uom  := p_in_attributes.quantity_uom;
    l_requested_quantity_uom2 := p_in_attributes.quantity_uom2;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_source_header_id', l_source_header_id);
    WSH_DEBUG_SV.log(l_module_name, 'l_source_line_set_id', l_source_line_set_id);
    WSH_DEBUG_SV.log(l_module_name, 'SHP TOL ABOVE',l_ship_tolerance_above);
    WSH_DEBUG_SV.log(l_module_name, 'SHP TOL BELOW',l_ship_tolerance_below);
  END IF;


  -- bug 3511424
  -- Locking the delivery lines within a line set or source line id
  -- if not done already by calling API
  IF (p_in_attributes.lock_flag = 'Y') THEN
    IF (l_source_line_set_id IS NOT NULL) THEN

      FOR rec in c_lock_delivery_det(l_source_header_id, l_source_line_set_id)
      LOOP
	l_delivery_detail_id := rec.delivery_detail_id;
      END LOOP;
    ELSIF (p_in_attributes.line_id IS NOT NULL) THEN
      FOR rec in c_lock_delivery_det1
      LOOP
	l_delivery_detail_id := rec.delivery_detail_id;
      END LOOP;
    END IF;
  END IF;

  --Line set Id is not null
  IF  l_source_line_set_id IS NOT NULL THEN
    OPEN c_sum_ordered_qty(l_source_header_id, l_source_line_set_id);
    FETCH c_sum_ordered_qty
    INTO l_total_ordered_quantity,
	 l_total_ordered_quantity2;
    CLOSE c_sum_ordered_qty;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Ordered_qty-'||l_total_ordered_quantity);
      WSH_DEBUG_SV.logmsg(l_module_name, 'Ordered_qty2-'||l_total_ordered_quantity2);
    END IF;

    IF p_in_attributes.ship_tolerance_above IS NOT NULL THEN  -- Pick Confirm
      x_out_attributes.min_remaining_quantity := 0;

      OPEN  c_sum_picked_qty(l_source_header_id, l_source_line_set_id);
      FETCH c_sum_picked_qty
      INTO l_del_shipping_quantity,
	   l_del_shipping_quantity2;
      CLOSE c_sum_picked_qty;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'l_del_shipping_qty-'||l_del_shipping_quantity);
        WSH_DEBUG_SV.logmsg(l_module_name, 'l_del_shipping_qty2-'||l_del_shipping_quantity2);
      END IF;

    END IF;

  ELSE	 --if source line set id is not null
    -- HW added l_total_ordered_quantity2
    OPEN c_sum_ordered_qty1(l_source_header_id);
    FETCH c_sum_ordered_qty1
    INTO l_total_ordered_quantity,
         l_total_ordered_quantity2;
    CLOSE c_sum_ordered_qty1;

  END IF;  --source_line set id is not null

  IF p_in_attributes.action_flag IN ('C', 'I') THEN
    -- CTO/Integration API
    IF l_source_line_set_id IS NOT NULL THEN
      IF p_in_attributes.action_flag = 'I' THEN
        OPEN c_sum_line_set_shp_qty_ITS(l_source_header_id,
                                        l_source_line_set_id);
        FETCH c_sum_line_set_shp_qty_ITS
         INTO l_del_shipping_quantity,
	      l_del_shipping_quantity2; --Bug#9437761
        CLOSE c_sum_line_set_shp_qty_ITS;
      ELSE
        OPEN c_sum_line_set_shp_qty(l_source_header_id,
                                    l_source_line_set_id);
        FETCH c_sum_line_set_shp_qty
         INTO l_del_shipping_quantity,
 	      l_del_shipping_quantity2; --Bug#9437761
        CLOSE c_sum_line_set_shp_qty;
      END IF;
    ELSE
      OPEN c_sum_line_shp_qty;
      FETCH c_sum_line_shp_qty
       INTO l_del_shipping_quantity,
       	    l_del_shipping_quantity2; --Bug#9437761
      CLOSE c_sum_line_shp_qty;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'CTO/Interface: l_del_shipping_quantity',
                                      l_del_shipping_quantity);
    END IF;

  END IF;


  l_shipped_quantity := l_del_shipping_quantity;
  l_shipped_quantity2 := l_del_shipping_quantity2;

  l_tolerance_quantity_below := l_total_ordered_quantity*nvl(l_ship_tolerance_below,0)/100;
  l_tolerance_quantity_above := l_total_ordered_quantity*nvl(l_ship_tolerance_above,0)/100;

  l_tolerance_quantity_below2 := l_total_ordered_quantity2*nvl(l_ship_tolerance_below,0)/100;
  l_tolerance_quantity_above2 := l_total_ordered_quantity2*nvl(l_ship_tolerance_above,0)/100;


  l_min_remaining_quantity := GREATEST(l_total_ordered_quantity - l_shipped_quantity -
						 l_tolerance_quantity_below,0);

  l_max_remaining_quantity := (l_total_ordered_quantity - l_shipped_quantity +
						 l_tolerance_quantity_above);
  IF (p_in_attributes.action_flag <> 'I') THEN
    l_max_remaining_quantity := GREATEST(l_max_remaining_quantity, 0);
  END IF;


  -- HW OPMCONV - Let's treat qty2 similar to qty1
  l_min_remaining_quantity2 := GREATEST(l_total_ordered_quantity2 - l_shipped_quantity2 -
						 l_tolerance_quantity_below2,0);
  l_max_remaining_quantity2 := GREATEST(l_total_ordered_quantity2 - l_shipped_quantity2 +
						 l_tolerance_quantity_above2,0);

  -- HW OPMCONV - No need to branch
  -- bug 3511424

  --{
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_max_remaining_quantity before the modification',l_max_remaining_quantity);
    WSH_DEBUG_SV.log(l_module_name, 'l_min_remaining_quantity before the modification',l_min_remaining_quantity);
  END IF;
  --
  l_max_remaining_quantity := trunc(l_max_remaining_quantity, wsh_util_core.c_max_decimal_digits_inv);
  IF (round(l_min_remaining_quantity,wsh_util_core.c_max_decimal_digits_inv) < l_min_remaining_quantity) THEN
    --{
    l_min_remaining_quantity := round(l_min_remaining_quantity + 0.000005, wsh_util_core.c_max_decimal_digits_inv);
    --}
  ELSE
    --{
    l_min_remaining_quantity := round(l_min_remaining_quantity, wsh_util_core.c_max_decimal_digits_inv);
    --}
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_max_remaining_quantity after the modification',l_max_remaining_quantity);
    WSH_DEBUG_SV.log(l_module_name, 'l_min_remaining_quantity after the modification',l_min_remaining_quantity);
  END IF;
  --
  --}

  -- bug 3511424
  -- HW Get min and max qty2 for OPM

  --In WSH, there can be multiple lines with same source_line_id, so
  --OPM needs to look and calculate secondary quantities accordingly
  -- HW OPM.

  -- HW OPMCONV - Let's treat Qtys similar to Qty1

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_max_remaining_quantity2 before the modification',l_max_remaining_quantity2);
    WSH_DEBUG_SV.log(l_module_name, 'l_min_remaining_quantity2 before the modification',l_min_remaining_quantity2);
  END IF;
  --
  l_max_remaining_quantity2 := trunc(l_max_remaining_quantity2, wsh_util_core.c_max_decimal_digits_inv);
  IF (round(l_min_remaining_quantity2,wsh_util_core.c_max_decimal_digits_inv) < l_min_remaining_quantity2) THEN
    --{
    l_min_remaining_quantity2 := round(l_min_remaining_quantity2 + 0.000005, wsh_util_core.c_max_decimal_digits_inv);
    --}
  ELSE
    --{
    l_min_remaining_quantity2 := round(l_min_remaining_quantity2, wsh_util_core.c_max_decimal_digits_inv);
    --}
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_max_remaining_quantity2 after the modification',l_max_remaining_quantity2);
    WSH_DEBUG_SV.log(l_module_name, 'l_min_remaining_quantity2 after the modification',l_min_remaining_quantity2);
  END IF;




  x_out_attributes.min_remaining_quantity := l_min_remaining_quantity;
  x_out_attributes.max_remaining_quantity := l_max_remaining_quantity;


  -- HW added qty2 for OPM
  x_out_attributes.min_remaining_quantity2 := l_min_remaining_quantity2;
  x_out_attributes.max_remaining_quantity2 := l_max_remaining_quantity2;
  -- ADD RETURN VALUES FOR UOM and UOM2
  x_out_attributes.quantity_uom  := l_requested_quantity_uom;
  x_out_attributes.quantity2_uom := l_requested_quantity_uom2;

  -- csun max_tol, convert shipping quantity to order quantity for CTO
  IF p_in_attributes.action_flag = 'C' THEN
    -- convert to order line UOM
    IF l_ordered_quantity_uom <> l_requested_quantity_uom THEN

      IF l_min_remaining_quantity > 0 THEN
        x_out_attributes.min_remaining_quantity := WSH_WV_UTILS.convert_uom(
                              from_uom => l_requested_quantity_uom,
                              to_uom   => l_ordered_quantity_uom,
                              quantity => l_min_remaining_quantity,
                              item_id  => l_inventory_item_id);
      END IF;
      IF l_max_remaining_quantity > 0 THEN
        x_out_attributes.max_remaining_quantity := WSH_WV_UTILS.convert_uom(
                              from_uom => l_requested_quantity_uom,
                              to_uom   => l_ordered_quantity_uom,
                              quantity => l_max_remaining_quantity,
                              item_id  => l_inventory_item_id);
      END IF;
      x_out_attributes.quantity_uom  := l_ordered_quantity_uom;

    END IF;

  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.quantity_uom', x_out_attributes.quantity_uom);
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.min_remaining_quantity',x_out_attributes.min_remaining_quantity);
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.max_remaining_quantity',x_out_attributes.max_remaining_quantity);
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.quantity2_uom', x_out_attributes.quantity2_uom);
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.min_remaining_quantity2',x_out_attributes.min_remaining_quantity2);
    WSH_DEBUG_SV.log(l_module_name,'x_out_attributes.max_remaining_quantity2',x_out_attributes.max_remaining_quantity2);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity',
                                  l_module_name);

    x_out_attributes.min_remaining_quantity := 0;
    x_out_attributes.max_remaining_quantity := 0;
    x_out_attributes.min_remaining_quantity2 := 0;
    x_out_attributes.max_remaining_quantity2 := 0;
    x_out_attributes.quantity_uom := NULL;
    x_out_attributes.quantity2_uom := NULL;

    IF c_sum_ordered_qty1%ISOPEN THEN
      CLOSE c_sum_ordered_qty1;
    END IF;
    IF c_sum_line_shp_qty%ISOPEN THEN
      CLOSE c_sum_line_shp_qty;
    END IF;
    IF c_sum_line_set_shp_qty%ISOPEN THEN
      CLOSE c_sum_line_set_shp_qty;
    END IF;
    IF c_sum_line_set_shp_qty_ITS%ISOPEN THEN
      CLOSE c_sum_line_set_shp_qty_ITS;
    END IF;
    IF c_sum_picked_qty%ISOPEN THEN
      CLOSE c_sum_picked_qty;
    END IF;
    IF c_sum_ordered_qty%ISOPEN THEN
      CLOSE c_sum_ordered_qty;
    END IF;
    IF c_get_details_CTO%ISOPEN THEN
      CLOSE c_get_details_CTO;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.Oracle error Message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Get_Min_Max_Tolerance_Quantity;


--Harmonization Project I
PROCEDURE Is_Action_Enabled(
				p_del_detail_rec_tab	IN	  detail_rec_tab_type,
				p_action				IN	  VARCHAR2,
				p_caller				IN	  VARCHAR2,
                                p_deliveryid                IN      NUMBER DEFAULT null,
				x_return_status		 OUT NOCOPY	  VARCHAR2,
				x_valid_ids			 OUT NOCOPY	  wsh_util_core.id_tab_type,
				x_error_ids			 OUT NOCOPY	  wsh_util_core.id_tab_type,
				x_valid_index_tab	   OUT NOCOPY	  wsh_util_core.id_tab_type
			  ) IS

cursor  det_to_del_cur( p_del_det_id IN NUMBER ) is
select  wnd.organization_id,
		wnd.status_code,
		wnd.planned_flag,
		wnd.delivery_id,
                nvl(wnd.shipment_direction, 'O'),  -- J inbound logistics jckwok
                nvl(wnd.ignore_for_planning, 'N'), -- OTM R12 : WSHDEVLS record
                nvl(wnd.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)                                           -- OTM R12 : WSHDEVLS record
from	wsh_new_deliveries wnd,
	wsh_delivery_assignments_v wda
where   wnd.delivery_id = wda.delivery_id
and	wda.delivery_detail_id = p_del_det_id;

-- frontport bug 5478065 of 11i10 performance bug 5439331:
-- this cursor is tuned to check for existence.
CURSOR c_staged_content( p_container_id IN NUMBER) IS
SELECT 1 FROM DUAL
WHERE  EXISTS
     ( SELECT wdd.delivery_detail_id
       FROM   wsh_delivery_details wdd
       WHERE wdd.delivery_detail_id IN
             (SELECT  wda.delivery_detail_id
              FROM  wsh_delivery_assignments_v wda
              START WITH parent_delivery_detail_id = p_container_id
              CONNECT BY prior delivery_detail_id = parent_delivery_detail_id)
       AND   wdd.container_flag = 'N'
       AND   wdd.released_status = 'Y' );

CURSOR c_isdelfirm(p_deliveryid IN NUMBER) IS
SELECT 'Y'
FROM wsh_new_deliveries wnd
WHERE wnd.delivery_id=p_deliveryid
AND wnd.planned_flag='F';

CURSOR c_isvalidtpdel(p_detid IN NUMBER, p_deliveryid IN NUMBER) IS
SELECT 'Y'
FROM wsh_new_deliveries wnd
WHERE wnd.delivery_id=p_deliveryid
AND (nvl(wnd.ignore_for_planning, 'N') <>
            (select nvl(ignore_for_planning,'N') from wsh_delivery_details where delivery_detail_id=p_detid)
    );

-- Added cursor for TPW - Distributed Organization Changes
CURSOR c_del_details ( c_del_det_id IN NUMBER ) is
select shipment_batch_id
from   wsh_delivery_details
where  delivery_detail_id = c_del_det_id;

l_shipment_batch_id      WSH_DELIVERY_DETAILS.Shipment_Batch_Id%TYPE;
-- TPW - Distributed Organization Changes - End

l_content_id  NUMBER := NULL;


l_detail_actions_tab	 DetailActionsTabType;
l_valid_ids		wsh_util_core.id_tab_type;
l_error_ids		wsh_util_core.id_tab_type;
l_valid_index_tab	wsh_util_core.id_tab_type;
l_dlvy_rec_tab		  WSH_DELIVERY_VALIDATIONS.dlvy_rec_tab_type;

l_pass_section_a	VARCHAR2(1):='Y';
l_organization_id	 NUMBER;
l_delivery_id NUMBER;
l_delivery_detail_id NUMBER;
l_planned_flag VARCHAR2(1);
l_status_code VARCHAR2(2);
l_shipment_direction VARCHAR(30);  -- J inbound logistics jckwok
l_source_code VARCHAR2(30);
l_released_status VARCHAR2(30);
l_ship_from_location_id   NUMBER;
l_cnt_flag VARCHAR2(2);
l_counter NUMBER;
l_wh_type VARCHAR2(30);
l_return_status VARCHAR2(1);
-- Bug fix: 2644558 Harmonization Project Patchset I.
l_wms_installed		 VARCHAR2(1);

l_org_type VARCHAR2(30);
l_wms_org_type VARCHAR2(30);
l_wms_org_id NUMBER;
l_non_wms_org_id NUMBER;

l_caller      VARCHAR2(50);

error_in_init_actions	EXCEPTION;
e_record_ineligible	 EXCEPTION;
e_wms_record_ineligible EXCEPTION;
e_tp_record_ineligible EXCEPTION;

-- OTM R12 : due to record changes in WSHDEVLS
l_ignore              WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
l_tms_interface_flag  WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
-- OTM R12-Org specific -Bug 5399341
l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
-- End of OTM R12 : due to record changes in WSHDEVLS


l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_ACTION_ENABLED';
l_wms_table WMS_SHIPPING_INTERFACE_GRP.g_delivery_detail_tbl;


l_msg_count NUMBER := 0;
l_msg_data  VARCHAR2(2000);
BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
	 l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	--
	WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
	WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
 END IF;

 Init_Detail_Actions_Tbl(
	p_action => p_action,
	x_detail_actions_tab => l_detail_actions_tab,
	x_return_status => x_return_status);

 IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'Init_Detail_Actions_Tbl x_return_status',x_return_status);
 END IF;

 IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise error_in_init_actions;
 END IF;

 -- Loop through the given table
 For  j  IN p_del_detail_rec_tab.FIRST..p_del_detail_rec_tab.LAST LOOP

   BEGIN

   l_source_code := p_del_detail_rec_tab(j).source_code;

   l_wms_org_type := NULL;
   --
   IF (p_caller NOT LIKE 'WMS%') THEN

	   if l_debug_on then
		  wsh_debug_sv.log(l_module_name, 'Organization Id', p_del_detail_rec_tab(j).organization_id);
		  wsh_debug_sv.log(l_module_name, 'WMS Organization Id', l_wms_org_id);
		  wsh_debug_sv.log(l_module_name, 'Non WMS Organization Id', l_non_wms_org_id);
	   end if;

	   IF p_del_detail_rec_tab(j).organization_id = l_wms_org_id THEN
		  l_wms_org_type := 'WMS';
	   ELSIF p_del_detail_rec_tab(j).organization_id = l_non_wms_org_id THEN
		  l_wms_org_type := NULL;
	   ELSE
		  IF l_debug_on THEN
			 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.GET_ORG_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
		  END IF;

                  l_org_type := wsh_util_validate.get_org_type(
                                  p_organization_id => p_del_detail_rec_tab(j).organization_id,
                                  p_delivery_detail_id => p_del_detail_rec_tab(j).delivery_detail_id,
				  p_msg_display => 'N', -- Bug# 3332656
                                  x_return_status => l_return_status );
		  IF l_debug_on THEN
		    wsh_debug_sv.log(l_module_name, 'Return status after wsh_util_validate.get_org_type', l_return_status);
		  END IF;
                  IF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = wsh_util_core.g_ret_sts_error THEN
                    raise e_record_ineligible;
                    exit;
                  END IF;

	          IF l_org_type IS NOT NULL THEN
                    l_wms_org_type := substrb(l_org_type, instrb(l_org_type, 'WMS'),3);
                    IF nvl(l_wms_org_type,'!') = 'WMS' THEN
		      l_wms_org_id := p_del_detail_rec_tab(j).organization_id;
                    ELSE
		      l_non_wms_org_id := p_del_detail_rec_tab(j).organization_id;
                    END IF;
                  END IF;
	   END IF;


   END IF;
   --
   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_wms_org_type', l_wms_org_type);
     wsh_debug_sv.log(l_module_name, 'l_detail_actions_tab.Count', l_detail_actions_tab.count);
   END IF;
   -- OTM R12 - Bug 5399341: Get shipping params to figure if the org is OTM enabled.

   WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id => p_del_detail_rec_tab(j).organization_id,
		      p_client_id       => p_del_detail_rec_tab(j).client_id,  -- LSP PROJECT : Client defaults should be considered.
                      x_param_info      => l_param_info,
                      x_return_status   => x_return_status
                      );
   --
   -- R12, X-dock
   -- The piece of code which determines if split is not to be allowed for 'Released to Warehouse'
   -- line has been commented in WSHDDVLB.init_details_action_tbl
   -- As per the requirement, Split should be allowed if
   -- if caller = WMS_XDOCK%
   -- and action = SPLIT-LINE
   -- and released_status for the detail = 'S'
   -- and a) Move order line id is null(Planned X-dock line) OR
   --     b) Move order line id is not null and move_order_type = 'PUTAWAY' (Planned X-dock line progressed)
   --     c) Move order line id is not null and move_order_type = 'PICK_WAVE' (Priotize Inventory case)
   IF p_action = 'SPLIT-LINE' AND
      p_del_detail_rec_tab(j).released_status = WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE THEN

     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'Released_status', p_del_detail_rec_tab(j).released_status);
       wsh_debug_sv.log(l_module_name, 'Caller',p_caller );
     END IF;
     IF p_caller like 'WMS_XDOCK%' THEN
       null; -- allow action
     ELSE
     -- Else Split should not be allowed
     -- Same as the condition which existed before in WSHDDVLB.init_details_action_tbl
       raise e_record_ineligible;
     END IF;
   END IF;
   --
   -- End of R12, X-dock
   --
	-- Section A
	l_pass_section_a :='Y';
	IF (l_DETAIL_actions_tab.COUNT > 0) THEN
	   For k in l_DETAIL_actions_tab.FIRST..l_DETAIL_actions_tab.LAST LOOP

          -- J-IB-NPARIKH-{
          l_released_status       := p_del_detail_rec_tab(j).released_status;
          l_ship_from_location_id := p_del_detail_rec_tab(j).ship_from_location_id;
          l_caller                := p_caller;
          --
          --
          --
          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'l_released_status', l_released_status);
             wsh_debug_sv.log(l_module_name, 'l_ship_from_location_id', l_ship_from_location_id);
             wsh_debug_sv.log(l_module_name, 'l_caller', l_caller);
          END IF;
          --
          --
          -- Actions on inbound/drop-ship lines are allowed only if caller
          -- starts with  one of the following:
          --     - FTE
          --     - WSH_IB
          --     - WSH_PUB
          --     - WSH_TP_RELEASE
          -- For any other callers, set l_caller to WSH_FSTRX
          -- Since for caller, WSH_FSTRX, all actions are disabled
          -- on inbound/drop-ship lines
          --
          --
          IF  nvl(p_del_detail_rec_tab(j).line_direction,'O') NOT IN ('O','IO')  -- Inbound/Drop-ship
          THEN
          --{
                IF l_caller LIKE 'FTE%'
                OR l_caller LIKE 'WSH_PUB%'
                OR l_caller LIKE 'WSH_IB%'
                OR l_caller LIKE 'WSH_TP_RELEASE%'
                THEN
                    NULL;
                ELSE
                    l_caller := 'WSH_FSTRX';
                END IF;
          --}
          END IF;
          --
          IF  nvl(p_del_detail_rec_tab(j).line_direction,'O') NOT IN ('O','IO')  -- Inbound/Drop-ship
          AND l_released_status                               IN ('C','L','P')  -- Shipped/Closed
          AND l_ship_from_location_id                          = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
                                            -- Supplier-managed freight (/Buyer-RReq. not recvd)
          THEN
          --{
	      /*
              IF p_action = 'SPLIT-LINE'
              THEN
                    l_released_status := 'X';
              ELSIF p_action IN ( 'AUTOCREATE-DEL', 'UNASSIGN' )
              THEN
              --{
                  IF p_caller like '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX
                  THEN
                  --{
                      l_released_status       := 'X';
                      l_ship_from_location_id := WSH_UTIL_CORE.C_NOTNULL_SF_LOCN_ID;
                  --}
                  END IF;
              --}
              END IF;
	      */
              --
              --
              --
              IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name, 'After Inbound Checks');
                 wsh_debug_sv.log(l_module_name, 'l_released_status', l_released_status);
                 wsh_debug_sv.log(l_module_name, 'l_ship_from_location_id', l_ship_from_location_id);
                 wsh_debug_sv.log(l_module_name, 'l_caller', l_caller);
              END IF;
              --
          --}
          END IF;
          --
          --
          -- J-IB-NPARIKH-}
          --
          IF( nvl(l_detail_actions_tab(k).released_status,l_released_status) =
                l_released_status   --p_del_detail_rec_tab(j).released_status -- J-IB-NPARIKH
              AND nvl(l_detail_actions_tab(k).ship_from_location_id,l_ship_from_location_id)
                    = l_ship_from_location_id -- J-IB-NPARIKH
			   AND  nvl(l_detail_actions_tab(k).container_flag,p_del_detail_rec_tab(j).container_flag) =
				p_del_detail_rec_tab(j).container_flag
			   AND  nvl(l_detail_actions_tab(k).source_code,l_source_code) = l_source_code
           AND  nvl(l_detail_actions_tab(k).caller,l_caller) = l_caller   -- J-IB-NPARIKH
                           AND nvl(l_detail_actions_tab(k).org_type,nvl(l_wms_org_type,'!')) = nvl(l_wms_org_type,'!')
			   AND l_detail_actions_tab(k).action_not_allowed = p_action
                           /* J new condition to check line_direction jckwok */
                           AND nvl(l_detail_actions_tab(k).line_direction,
                                   nvl(p_del_detail_rec_tab(j).line_direction, 'O'))
                                   = nvl(p_del_detail_rec_tab(j).line_direction, 'O')
                           AND nvl(l_detail_actions_tab(k).otm_enabled, nvl(l_param_info.otm_enabled, 'N'))
                               = nvl(l_param_info.otm_enabled, 'N')
                         ) THEN
			 l_pass_section_a :='N';
                         IF l_detail_actions_tab(k).message_name IS NOT NULL THEN
		           IF l_debug_on THEN
			     wsh_debug_sv.log(l_module_name, 'Message Name is', l_detail_actions_tab(k).message_name);
		           END IF;
                           FND_MESSAGE.SET_NAME('WSH',l_detail_actions_tab(k).message_name);
                           wsh_util_core.add_message(wsh_util_core.g_ret_sts_error);
                         END IF;
			 raise e_record_ineligible;
			 exit;
		  END IF;
	   END LOOP;
	END IF;

	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'l_pass_section_a ',l_pass_section_a);
	END IF;
	-- Section B
	IF (l_pass_section_a = 'Y' ) THEN
	   -- TPW - Distributed Organization Changes - Start
           IF ( p_action IN ( 'AUTOCREATE-DEL', 'ASSIGN' ) ) THEN
           --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                                    p_organization_id  => p_del_detail_rec_tab(j).organization_id,
                                    x_return_status    => l_return_status );
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
               END IF;
               --

               IF nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TW2' THEN
               --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, 'Error: Cannot perform action Auto-create Deliveries/Assign to Delivery in Distributed Enabled Organization');
                    END IF;
                    --
                    RAISE e_record_ineligible;
               END IF;
           END IF;
           -- TPW - Distributed Organization Changes - End

	   open det_to_del_cur(p_del_detail_rec_tab(j).delivery_detail_id);
	   Fetch det_to_del_cur into l_organization_id, l_status_code, l_planned_flag,
                                     l_delivery_id, l_shipment_direction,
                                     l_ignore, l_tms_interface_flag; -- OTM R12

	   IF ( p_action IN ('CYCLE-COUNT','PICK-RELEASE','AUTO-PACK','AUTO-PACK-MASTER',
				  'PACK','UNPACK','PACKING-WORKBENCH') ) THEN
		  IF ( det_to_del_cur%NOTFOUND ) THEN
			 close det_to_del_cur;

		 l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
				(p_organization_id => p_del_detail_rec_tab(j).organization_id,
								 x_return_status   => l_return_status,
				 p_delivery_id	 => l_delivery_id,
				 p_delivery_detail_id => p_del_detail_rec_tab(j).delivery_detail_id,
								 p_msg_display	 => 'N');

			 IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
			 END IF;

               -- TPW - Distributed Organization Changes
 	       --IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
 	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ( 'TPW', 'TW2' ) ) THEN
		        IF ( p_del_detail_rec_tab(j).source_code = 'WSH' and p_del_detail_rec_tab(j).container_flag = 'N' ) THEN
			   x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				   x_valid_index_tab(j) := j;
			ELSE
				   raise e_record_ineligible;
			END IF;
		 ELSE
			x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				x_valid_index_tab(j) := j;
		 END IF;
		  ELSE
			 l_dlvy_rec_tab(1).delivery_id := l_delivery_id;
			 l_dlvy_rec_tab(1).organization_id := l_organization_id;
			 l_dlvy_rec_tab(1).status_code := l_status_code;
			 l_dlvy_rec_tab(1).planned_flag := l_planned_flag;
                         l_dlvy_rec_tab(1).shipment_direction := l_shipment_direction;  -- J inbound logistics jckwok
                         -- OTM R12 : due to record changes in WSHDEVLS
                         l_dlvy_rec_tab(1).ignore_for_planning :=  l_ignore;
                         l_dlvy_rec_tab(1).tms_interface_flag  :=  l_tms_interface_flag;
                         -- End of OTM R12 : due to record changes in WSHDEVLS


			 WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
				p_dlvy_rec_tab		  => l_dlvy_rec_tab,
				p_action				=> p_action,
				p_caller				=> p_caller,
				x_return_status		 => l_return_status,
				x_valid_ids			 => l_valid_ids,
				x_error_ids			 => l_error_ids,
				x_valid_index_tab	   => l_valid_index_tab);

			 IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',
											   l_return_status);
			 END IF;

			 IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                          AND (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
				raise e_record_ineligible;
			 ELSE
			x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				x_valid_index_tab(j) := j;
			 END IF;
		  END IF; -- IF ( det_to_del_cur%

	   ELSIF ( p_action = 'SPLIT-LINE') THEN
		  IF ( det_to_del_cur%NOTFOUND ) THEN
                      close det_to_del_cur;
                      -- TPW - Distributed Organization Changes -- Start
                      -- Do not allow delivery line split if its assigned to a Shipment Batch
                      l_shipment_batch_id := null;
                      open  c_del_details(p_del_detail_rec_tab(j).delivery_detail_id);
                      fetch c_del_details into l_shipment_batch_id;
                      close c_del_details;
                      IF l_shipment_batch_id is not null THEN
                         raise e_record_ineligible;
                      ELSE
                         x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
                         x_valid_index_tab(j) := j;
		      End if;
		      -- TPW - Distributed Organization Changes -- End
		  ELSE
			 l_dlvy_rec_tab(1).delivery_id := l_delivery_id;
			 l_dlvy_rec_tab(1).organization_id := l_organization_id;
			 l_dlvy_rec_tab(1).status_code := l_status_code;
			 l_dlvy_rec_tab(1).planned_flag := l_planned_flag;
                         l_dlvy_rec_tab(1).shipment_direction := l_shipment_direction;  -- jckwok
                         -- OTM R12 : due to record changes in WSHDEVLS
                         l_dlvy_rec_tab(1).ignore_for_planning :=  l_ignore;
                         l_dlvy_rec_tab(1).tms_interface_flag  :=  l_tms_interface_flag;
                         -- End of OTM R12 : due to record changes in WSHDEVLS

			 WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
				p_dlvy_rec_tab		  => l_dlvy_rec_tab,
				p_action				=> p_action,
				p_caller				=> p_caller,
				x_return_status		 => l_return_status,
				x_valid_ids			 => l_valid_ids,
				x_error_ids			 => l_error_ids,
				x_valid_index_tab	   => l_valid_index_tab);

			 IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',
											   l_return_status);
			 END IF;

			 IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                           AND (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
				raise e_record_ineligible;
			 ELSE
				x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				x_valid_index_tab(j) := j;
			 END IF;
		  END IF;

	   ELSIF ( p_action = 'UNASSIGN') THEN
		  IF ( det_to_del_cur%NOTFOUND ) THEN
			 close det_to_del_cur;
		 x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
			 x_valid_index_tab(j) := j;
		  ELSE
			 l_dlvy_rec_tab(1).delivery_id := l_delivery_id;
			 l_dlvy_rec_tab(1).organization_id := l_organization_id;
			 l_dlvy_rec_tab(1).status_code := l_status_code;
			 l_dlvy_rec_tab(1).planned_flag := l_planned_flag;
                         l_dlvy_rec_tab(1).shipment_direction := l_shipment_direction;  -- jckwok
                         -- OTM R12 : due to record changes in WSHDEVLS
                         l_dlvy_rec_tab(1).ignore_for_planning :=  l_ignore;
                         l_dlvy_rec_tab(1).tms_interface_flag  :=  l_tms_interface_flag;
                         -- End of OTM R12 : due to record changes in WSHDEVLS

			 l_wms_installed := wsh_util_validate.check_wms_org(p_del_detail_rec_tab(j).organization_id);
                         -- bug 2750960: call WMS only if record is a container that contains a staged line
			 IF     l_wms_installed = 'Y'
                            AND p_del_detail_rec_tab(j).container_flag in ('Y', 'C')
                         THEN

                           OPEN  c_staged_content(p_del_detail_rec_tab(j).delivery_detail_id);
                           FETCH c_staged_content INTO l_content_id;
                           IF c_staged_content%NOTFOUND THEN
                             l_content_id := NULL;
                           END IF;
                           CLOSE c_staged_content;

                           IF l_content_id IS NOT NULL THEN

			     l_wms_table(1).delivery_detail_id := p_del_detail_rec_tab(j).delivery_detail_id;
			     l_wms_table(1).organization_id    := p_del_detail_rec_tab(j).organization_id;
			     l_wms_table(1).released_status    := p_del_detail_rec_tab(j).released_status;
			     l_wms_table(1).container_flag     := p_del_detail_rec_tab(j).container_flag;
			     l_wms_table(1).source_code	       := p_del_detail_rec_tab(j).source_code;
			     l_wms_table(1).lpn_id	       := p_del_detail_rec_tab(j).lpn_id;

			     WMS_SHIPPING_INTERFACE_GRP.process_delivery_details (
					p_api_version	=> 1.0,
					p_action		 => WMS_SHIPPING_INTERFACE_GRP.g_action_unassign_delivery,
					p_delivery_detail_tbl  => l_wms_table,
					x_return_status  => l_return_status,
					x_msg_count	  => l_msg_count,
					x_msg_data	   => l_msg_data);


				 IF l_debug_on THEN
					WSH_DEBUG_SV.log(l_module_name,'WMS_SHIPPING_INTERFACE_GRP.process_delivery_details l_wms_table(1).return_status',
												   l_wms_table(1).return_status);
				 END IF;

			     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS OR l_wms_table(1).return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				  raise e_wms_record_ineligible;
			     END IF;
                           END IF; -- l_content_id IS NOT NULL
			 END IF;--l_wms_installed

			 WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
				p_dlvy_rec_tab		  => l_dlvy_rec_tab,
				p_action				=> p_action,
				p_caller				=> p_caller,
				x_return_status		 => l_return_status,
				x_valid_ids			 => l_valid_ids,
				x_error_ids			 => l_error_ids,
				x_valid_index_tab	   => l_valid_index_tab);

			 IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled l_return_status',
											   l_return_status);
			 END IF;

			 IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                           AND (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
				raise e_record_ineligible;
			 ELSE
                                IF (p_del_detail_rec_tab(j).source_code = 'WSH' and p_del_detail_rec_tab(j).container_flag = 'N' ) THEN
                                   raise e_record_ineligible;
                                END IF;
				x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				x_valid_index_tab(j) := j;
			 END IF;
		  END IF;

           ELSIF (p_caller<>'TP_RELEASE' AND p_action='ASSIGN') THEN
              FOR cur IN c_isdelfirm(p_deliveryid) LOOP
                  raise e_record_ineligible;
              END LOOP;
              FOR cur IN c_isvalidtpdel(p_del_detail_rec_tab(j).delivery_detail_id, p_deliveryid) LOOP
                  raise e_tp_record_ineligible;
              END LOOP;
              -- TKT
              x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
              x_valid_index_tab(j) := j;

	   ELSIF ( p_action IN ('IGNORE_PLAN','INCLUDE_PLAN')) THEN
              l_wms_installed := wsh_util_validate.check_wms_org(p_del_detail_rec_tab(j).organization_id);

              IF l_wms_installed='Y' AND p_del_detail_rec_tab(j).released_status='S' THEN
                  raise e_wms_record_ineligible;
              ELSE
                  x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
                  x_valid_index_tab(j) := j;
              END IF;

	   ELSIF ( p_action =  'AUTOCREATE-TRIP')  THEN
		  IF ( det_to_del_cur%NOTFOUND ) THEN
			 close det_to_del_cur;

		 l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
				(p_organization_id => p_del_detail_rec_tab(j).organization_id,
								 x_return_status   => l_return_status,
				 p_delivery_id	 => l_delivery_id,
								 p_delivery_detail_id => p_del_detail_rec_tab(j).delivery_detail_id,
								 p_msg_display	 => 'N');

			 IF l_debug_on THEN
			   WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
			 END IF;

		 -- TPW - Distributed Organization Changes
                --IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ('CMS','TPW')) THEN
                IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ('CMS','TPW','TW2')) THEN
				  IF (p_del_detail_rec_tab(j).source_code = 'WSH' and p_del_detail_rec_tab(j).container_flag = 'N' ) THEN
				   x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				   x_valid_index_tab(j) := j;
				ELSE
				   raise e_record_ineligible;
				END IF;
		 ELSE
				x_valid_ids(x_valid_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
				x_valid_index_tab(j) := j;
		 END IF;
	  ELSE
				raise e_record_ineligible;
	  END IF;


	   ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) :=  p_del_detail_rec_tab(j).delivery_detail_id;
		   x_valid_index_tab(j) := j;
	   END IF;

	   IF ( det_to_del_cur%ISOPEN ) THEN
		  close det_to_del_cur;
	   END IF;

	 END IF; --pass section a
	EXCEPTION -- for the local BEGIN
		 WHEN e_record_ineligible THEN
                          IF det_to_del_cur%ISOPEN THEN
                            CLOSE det_to_del_cur;
                          END IF;

			  IF l_debug_on THEN
				 wsh_debug_sv.log(l_module_name, 'Error Id', p_del_detail_rec_tab(j).delivery_detail_id);
			  END IF;
			  x_error_ids(x_error_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
			  IF nvl(p_caller, FND_API.G_MISS_CHAR) = 'WSH_PUB'
                             OR p_caller like 'FTE%' THEN
				 FND_MESSAGE.SET_NAME('WSH', 'WSH_DETAIL_ACTION_INELIGIBLE');
				 FND_MESSAGE.SET_TOKEN('DETAIL_ID', p_del_detail_rec_tab(j).delivery_detail_id);
				 FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('DLVB',p_action));
				 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
			  END IF;

		 WHEN e_wms_record_ineligible THEN
                          IF det_to_del_cur%ISOPEN THEN
                            CLOSE det_to_del_cur;
                          END IF;
			  IF l_debug_on THEN
				 wsh_debug_sv.log(l_module_name, 'Error Id', p_del_detail_rec_tab(j).delivery_detail_id);
			  END IF;
			  x_error_ids(x_error_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
			  IF nvl(p_caller, FND_API.G_MISS_CHAR) = 'WSH_PUB'
                             OR p_caller like 'FTE%' THEN
				 FND_MESSAGE.SET_NAME('WSH', 'WSH_DETAIL_ACTION_INELIGIBLE');
				 FND_MESSAGE.SET_TOKEN('DETAIL_ID', p_del_detail_rec_tab(j).delivery_detail_id);
				 FND_MESSAGE.SET_TOKEN('ACTION', wsh_util_core.get_action_meaning('DLVB',p_action));
				 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
			  END IF;

		 WHEN e_tp_record_ineligible THEN
                          IF det_to_del_cur%ISOPEN THEN
                            CLOSE det_to_del_cur;
                          END IF;
			  IF l_debug_on THEN
				 wsh_debug_sv.log(l_module_name, 'Error Id', p_del_detail_rec_tab(j).delivery_detail_id);
			  END IF;
			  x_error_ids(x_error_ids.COUNT + 1) := p_del_detail_rec_tab(j).delivery_detail_id;
			  IF nvl(p_caller, FND_API.G_MISS_CHAR) = 'WSH_PUB'
                             OR p_caller like 'FTE%' THEN
				 FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_ASSIGN_FIRMDEL_ERROR');
				 FND_MESSAGE.SET_TOKEN('DETAIL_ID', p_del_detail_rec_tab(j).delivery_detail_id);
				 FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_deliveryid));
				 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
			  END IF;

		 WHEN others THEN
                          IF det_to_del_cur%ISOPEN THEN
                            CLOSE det_to_del_cur;
                          END IF;
			  raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END; -- Local BEGIN

 END LOOP;

 IF (x_valid_ids.COUNT = 0 ) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
	  FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
	  wsh_util_core.add_message(x_return_status,l_module_name);
        END IF;
        --
 ELSIF (x_valid_ids.COUNT = p_del_detail_rec_tab.COUNT) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 ELSIF (x_valid_ids.COUNT < p_del_detail_rec_tab.COUNT ) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
        IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
	  FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED_WARN');
	  wsh_util_core.add_message(x_return_status,l_module_name);
        END IF;
        --
 ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
	  FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
	  wsh_util_core.add_message(x_return_status,l_module_name);
        END IF;
        --
 END IF;

 IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN error_in_init_actions THEN
   IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'error_in_init_actions exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:error_in_init_actions');
   END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			   wsh_util_core.add_message(x_return_status, l_module_name);
		   IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
				WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
		   END IF;
   IF c_staged_content%ISOPEN THEN
      CLOSE c_staged_content;
   END IF;

  WHEN OTHERS THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
						  SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   IF c_staged_content%ISOPEN THEN
      CLOSE c_staged_content;
   END IF;
END Is_Action_Enabled;



PROCEDURE eliminate_displayonly_fields (
  p_delivery_detail_rec   IN wsh_glbl_var_strct_grp.delivery_details_rec_type
, p_in_rec                IN wsh_glbl_var_strct_grp.detailInRecType
, x_delivery_detail_rec   IN OUT NOCOPY
 							 wsh_glbl_var_strct_grp.delivery_details_rec_type
)
IS

-- Bug 5728048
CURSOR c_isvalidUOM_Code (p_uom_code VARCHAR2) IS
 SELECT uom.uom_code
 FROM   mtl_uom_conversions conv, mtl_units_of_measure_vl uom
 WHERE  uom.unit_of_measure = conv.unit_of_measure
 AND    uom.uom_code = p_uom_code
 AND    conv.inventory_item_id = 0
 AND    NVL(uom.disable_date, sysdate+1) > sysdate
 AND    NVL(conv.disable_date, sysdate+1) > sysdate ;

 l_uom_code VARCHAR2(3);

BEGIN

	/*
	   Enable the x_delivery_detail_rec, with the columns that are not
	   permanently  disabled.
	*/

	--
	IF p_delivery_detail_rec.container_name <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.container_name IS NULL THEN
	  x_delivery_detail_rec.container_name :=
						  p_delivery_detail_rec.container_name;
	END IF;
	IF p_delivery_detail_rec.shipped_quantity <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.shipped_quantity IS NULL THEN
	  x_delivery_detail_rec.shipped_quantity :=
						  p_delivery_detail_rec.shipped_quantity;
	END IF;
	IF p_delivery_detail_rec.shipped_quantity2 <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.shipped_quantity2 IS NULL THEN
	  x_delivery_detail_rec.shipped_quantity2 :=
						  p_delivery_detail_rec.shipped_quantity2;
	END IF;
	IF p_delivery_detail_rec.cycle_count_quantity <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.cycle_count_quantity IS NULL THEN
	  x_delivery_detail_rec.cycle_count_quantity :=
						  p_delivery_detail_rec.cycle_count_quantity;
	END IF;
	IF p_delivery_detail_rec.cycle_count_quantity2 <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.cycle_count_quantity2 IS NULL THEN
	  x_delivery_detail_rec.cycle_count_quantity2 :=
						  p_delivery_detail_rec.cycle_count_quantity2;
	END IF;
	IF p_delivery_detail_rec.delivered_quantity <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.delivered_quantity IS NULL THEN
	  x_delivery_detail_rec.delivered_quantity :=
						  p_delivery_detail_rec.delivered_quantity;
	END IF;
	IF p_delivery_detail_rec.delivered_quantity2 <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.delivered_quantity2 IS NULL THEN
	  x_delivery_detail_rec.delivered_quantity2 :=
						  p_delivery_detail_rec.delivered_quantity2;
	END IF;
	IF p_delivery_detail_rec.cancelled_quantity <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.cancelled_quantity IS NULL THEN
	  x_delivery_detail_rec.cancelled_quantity :=
						  p_delivery_detail_rec.cancelled_quantity;
	END IF;
	IF p_delivery_detail_rec.cancelled_quantity2 <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.cancelled_quantity2 IS NULL THEN
	  x_delivery_detail_rec.cancelled_quantity2 :=
						  p_delivery_detail_rec.cancelled_quantity2;
	END IF;
	IF p_delivery_detail_rec.load_seq_number <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.load_seq_number IS NULL THEN
	  x_delivery_detail_rec.load_seq_number :=
						  p_delivery_detail_rec.load_seq_number;
	END IF;
	IF p_delivery_detail_rec.gross_weight <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.gross_weight IS NULL THEN
	  x_delivery_detail_rec.gross_weight :=
						  p_delivery_detail_rec.gross_weight;
	END IF;
	IF p_delivery_detail_rec.net_weight <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.net_weight IS NULL THEN
	  x_delivery_detail_rec.net_weight :=
						  p_delivery_detail_rec.net_weight;
	END IF;
	IF p_delivery_detail_rec.volume <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.volume IS NULL THEN
	  x_delivery_detail_rec.volume :=
						  p_delivery_detail_rec.volume;
	END IF;

        -- Update of UOM Codes is allowed only if they are Null and new codes are Valid UOM Codes
        IF p_in_rec.action_code = 'UPDATE' THEN
           IF p_delivery_detail_rec.weight_uom_code <>  FND_API.G_MISS_CHAR
             AND p_delivery_detail_rec.weight_uom_code IS NOT NULL
             AND x_delivery_detail_rec.weight_uom_code IS NULL THEN
             OPEN c_isvalidUOM_Code(p_delivery_detail_rec.weight_uom_code);
             FETCH c_isvalidUOM_Code INTO l_uom_code;
             IF c_isvalidUOM_Code%FOUND THEN
                x_delivery_detail_rec.weight_uom_code :=
                                                  p_delivery_detail_rec.weight_uom_code;
             END IF;
             CLOSE c_isvalidUOM_Code;
           END IF;
           IF p_delivery_detail_rec.volume_uom_code <>  FND_API.G_MISS_CHAR
             AND p_delivery_detail_rec.volume_uom_code IS NOT NULL
             AND x_delivery_detail_rec.volume_uom_code IS NULL THEN
             OPEN c_isvalidUOM_Code(p_delivery_detail_rec.volume_uom_code);
             FETCH c_isvalidUOM_Code INTO l_uom_code;
             IF c_isvalidUOM_Code%FOUND THEN
                x_delivery_detail_rec.volume_uom_code :=
                                                  p_delivery_detail_rec.volume_uom_code;
             END IF;
             CLOSE c_isvalidUOM_Code;
           END IF;
        END IF;

	IF p_delivery_detail_rec.fill_percent <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.fill_percent IS NULL THEN
	  x_delivery_detail_rec.fill_percent :=
						  p_delivery_detail_rec.fill_percent;
	END IF;
	IF p_delivery_detail_rec.master_serial_number <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.master_serial_number IS NULL THEN
	  x_delivery_detail_rec.master_serial_number :=
						  p_delivery_detail_rec.master_serial_number;
	END IF;
	IF p_delivery_detail_rec.master_container_item_id <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.master_container_item_id IS NULL THEN
	  x_delivery_detail_rec.master_container_item_id :=
						  p_delivery_detail_rec.master_container_item_id;
	END IF;
	IF p_delivery_detail_rec.detail_container_item_id <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.detail_container_item_id IS NULL THEN
	  x_delivery_detail_rec.detail_container_item_id :=
						  p_delivery_detail_rec.detail_container_item_id;
	END IF;
	IF p_delivery_detail_rec.shipping_instructions <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.shipping_instructions IS NULL THEN
	  x_delivery_detail_rec.shipping_instructions :=
						  p_delivery_detail_rec.shipping_instructions;
	END IF;
	IF p_delivery_detail_rec.packing_instructions <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.packing_instructions IS NULL THEN
	  x_delivery_detail_rec.packing_instructions :=
						  p_delivery_detail_rec.packing_instructions;
	END IF;
	IF p_delivery_detail_rec.revision <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.revision IS NULL THEN
	  x_delivery_detail_rec.revision :=
						  p_delivery_detail_rec.revision;
	END IF;
	IF p_delivery_detail_rec.subinventory <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.subinventory IS NULL THEN
	  x_delivery_detail_rec.subinventory :=
						  p_delivery_detail_rec.subinventory;
	END IF;
	IF p_delivery_detail_rec.lot_number <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.lot_number IS NULL THEN
	  x_delivery_detail_rec.lot_number :=
						  p_delivery_detail_rec.lot_number;
	END IF;
-- HW OPMCONV - No need for sublot_number

	IF p_delivery_detail_rec.locator_id <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.locator_id IS NULL THEN
	  x_delivery_detail_rec.locator_id :=
						  p_delivery_detail_rec.locator_id;
	END IF;
	IF p_delivery_detail_rec.serial_number <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.serial_number IS NULL THEN
	  x_delivery_detail_rec.serial_number :=
						  p_delivery_detail_rec.serial_number;
	END IF;
	-- Bug Fix: 2651882. KVENKATE.
	-- Need to enable 'to_serial_number'
	IF p_delivery_detail_rec.to_serial_number <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.to_serial_number IS NULL THEN
	  x_delivery_detail_rec.to_serial_number :=
						  p_delivery_detail_rec.to_serial_number;
	END IF;
	-- Bug Fix: 2651882. KVENKATE.

	IF p_delivery_detail_rec.preferred_grade <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.preferred_grade IS NULL THEN
	  x_delivery_detail_rec.preferred_grade :=
						  p_delivery_detail_rec.preferred_grade;
	END IF;
	IF p_delivery_detail_rec.seal_code <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.seal_code IS NULL THEN
	  x_delivery_detail_rec.seal_code :=
						  p_delivery_detail_rec.seal_code;
	END IF;
	IF p_delivery_detail_rec.inspection_flag <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.inspection_flag IS NULL THEN
	  x_delivery_detail_rec.inspection_flag :=
						  p_delivery_detail_rec.inspection_flag;
	END IF;
	IF p_delivery_detail_rec.transaction_temp_id <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.transaction_temp_id IS NULL THEN
	  x_delivery_detail_rec.transaction_temp_id :=
						  p_delivery_detail_rec.transaction_temp_id;
	END IF;


	IF p_delivery_detail_rec.tp_attribute1 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute1 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute1 :=
						  p_delivery_detail_rec.tp_attribute1;
	END IF;
	IF p_delivery_detail_rec.tp_attribute2 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute2 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute2 :=
						  p_delivery_detail_rec.tp_attribute2;
	END IF;
	IF p_delivery_detail_rec.tp_attribute3 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute3 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute3 :=
						  p_delivery_detail_rec.tp_attribute3;
	END IF;
	IF p_delivery_detail_rec.tp_attribute4 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute4 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute4 :=
						  p_delivery_detail_rec.tp_attribute4;
	END IF;
	IF p_delivery_detail_rec.tp_attribute5 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute5 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute5 :=
						  p_delivery_detail_rec.tp_attribute5;
	END IF;
	IF p_delivery_detail_rec.tp_attribute6 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute6 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute6 :=
						  p_delivery_detail_rec.tp_attribute6;
	END IF;
	IF p_delivery_detail_rec.tp_attribute7 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute7 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute7 :=
						  p_delivery_detail_rec.tp_attribute7;
	END IF;
	IF p_delivery_detail_rec.tp_attribute8 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute8 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute8 :=
						  p_delivery_detail_rec.tp_attribute8;
	END IF;
	IF p_delivery_detail_rec.tp_attribute9 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute9 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute9 :=
						  p_delivery_detail_rec.tp_attribute9;
	END IF;
	IF p_delivery_detail_rec.tp_attribute10 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute10 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute10 :=
						  p_delivery_detail_rec.tp_attribute10;
	END IF;
	IF p_delivery_detail_rec.tp_attribute11 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute11 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute11 :=
						  p_delivery_detail_rec.tp_attribute11;
	END IF;
	IF p_delivery_detail_rec.tp_attribute12 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute12 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute12 :=
						  p_delivery_detail_rec.tp_attribute12;
	END IF;
	IF p_delivery_detail_rec.tp_attribute13 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute13 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute13 :=
						  p_delivery_detail_rec.tp_attribute13;
	END IF;
	IF p_delivery_detail_rec.tp_attribute14 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute14 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute14 :=
						  p_delivery_detail_rec.tp_attribute14;
	END IF;
	IF p_delivery_detail_rec.tp_attribute15 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute15 IS NULL THEN
	  x_delivery_detail_rec.tp_attribute15 :=
						  p_delivery_detail_rec.tp_attribute15;
	END IF;
	IF p_delivery_detail_rec.tp_attribute_category <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tp_attribute_category IS NULL THEN
	  x_delivery_detail_rec.tp_attribute_category :=
						  p_delivery_detail_rec.tp_attribute_category;
	END IF;
	IF p_delivery_detail_rec.attribute1 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute1 IS NULL THEN

	  x_delivery_detail_rec.attribute1 :=
						  p_delivery_detail_rec.attribute1;
	END IF;
	IF p_delivery_detail_rec.attribute2 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute2 IS NULL THEN
	  x_delivery_detail_rec.attribute2 :=
						  p_delivery_detail_rec.attribute2;
	END IF;
	IF p_delivery_detail_rec.attribute3 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute3 IS NULL THEN
	  x_delivery_detail_rec.attribute3 :=
						  p_delivery_detail_rec.attribute3;
	END IF;
	IF p_delivery_detail_rec.attribute4 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute4 IS NULL THEN
	  x_delivery_detail_rec.attribute4 :=
						  p_delivery_detail_rec.attribute4;
	END IF;
	IF p_delivery_detail_rec.attribute5 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute5 IS NULL THEN
	  x_delivery_detail_rec.attribute5 :=
						  p_delivery_detail_rec.attribute5;
	END IF;
	IF p_delivery_detail_rec.attribute6 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute6 IS NULL THEN
	  x_delivery_detail_rec.attribute6 :=
						  p_delivery_detail_rec.attribute6;
	END IF;
	IF p_delivery_detail_rec.attribute7 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute7 IS NULL THEN
	  x_delivery_detail_rec.attribute7 :=
						  p_delivery_detail_rec.attribute7;
	END IF;
	IF p_delivery_detail_rec.attribute8 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute8 IS NULL THEN
	  x_delivery_detail_rec.attribute8 :=
						  p_delivery_detail_rec.attribute8;
	END IF;
	IF p_delivery_detail_rec.attribute9 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute9 IS NULL THEN
	  x_delivery_detail_rec.attribute9 :=
						  p_delivery_detail_rec.attribute9;
	END IF;
	IF p_delivery_detail_rec.attribute10 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute10 IS NULL THEN
	  x_delivery_detail_rec.attribute10 :=
						  p_delivery_detail_rec.attribute10;
	END IF;
	IF p_delivery_detail_rec.attribute11 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute11 IS NULL THEN
	  x_delivery_detail_rec.attribute11 :=
						  p_delivery_detail_rec.attribute11;
	END IF;
	IF p_delivery_detail_rec.attribute12 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute12 IS NULL THEN
	  x_delivery_detail_rec.attribute12 :=
						  p_delivery_detail_rec.attribute12;
	END IF;
	IF p_delivery_detail_rec.attribute13 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute13 IS NULL THEN
	  x_delivery_detail_rec.attribute13 :=
						  p_delivery_detail_rec.attribute13;
	END IF;
	IF p_delivery_detail_rec.attribute14 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute14 IS NULL THEN
	  x_delivery_detail_rec.attribute14 :=
						  p_delivery_detail_rec.attribute14;
	END IF;
	IF p_delivery_detail_rec.attribute15 <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute15 IS NULL THEN
	  x_delivery_detail_rec.attribute15 :=
						  p_delivery_detail_rec.attribute15;
	END IF;
	IF p_delivery_detail_rec.attribute_category <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.attribute_category IS NULL THEN
	  x_delivery_detail_rec.attribute_category :=
						  p_delivery_detail_rec.attribute_category;
	END IF;

        -- Need to enable 'Tracking Number'. This is not a permanently disabled field
	IF p_delivery_detail_rec.tracking_number <>  FND_API.G_MISS_CHAR
	  OR p_delivery_detail_rec.tracking_number IS NULL THEN
	  x_delivery_detail_rec.tracking_number :=
						  p_delivery_detail_rec.tracking_number;
	END IF;

        -- J: W/V Changes
	IF p_delivery_detail_rec.filled_volume <>  FND_API.G_MISS_NUM
	  OR p_delivery_detail_rec.filled_volume IS NULL THEN
	  x_delivery_detail_rec.filled_volume :=
						  p_delivery_detail_rec.filled_volume;
	END IF;

        IF p_in_rec.caller='WSH_TP_RELEASE' THEN
           IF p_delivery_detail_rec.tp_delivery_detail_id <> FND_API.G_MISS_NUM
              OR p_delivery_detail_rec.tp_delivery_detail_id IS NULL THEN
              x_delivery_detail_rec.tp_delivery_detail_id :=
                          p_delivery_detail_rec.tp_delivery_detail_id;
           END IF;
        END IF;


END eliminate_displayonly_fields;

/*----------------------------------------------------------
-- Procedure disable_from_list will update the record x_out_rec
-- and disables the field contained in p_disabled_list.
-----------------------------------------------------------*/

PROCEDURE disable_from_list(
  p_disabled_list IN		 WSH_UTIL_CORE.column_tab_type
, p_in_rec         IN            wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_out_rec       IN OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_return_status OUT NOCOPY		 VARCHAR2
, x_field_name	OUT NOCOPY		 VARCHAR2

) IS
BEGIN
  --
  --
  FOR i IN 1..p_disabled_list.COUNT
  LOOP
	IF p_disabled_list(i)  = 'CONTAINER_NAME' THEN
	  x_out_rec.container_name := p_in_rec.container_name ;
	ELSIF p_disabled_list(i)  = 'CYCLE_COUNT_QUANTITY' THEN
	  x_out_rec.cycle_count_quantity := p_in_rec.cycle_count_quantity ;
        --
	ELSIF p_disabled_list(i)  = 'PREFERED_GRADE' THEN
	  x_out_rec.PREFERRED_GRADE := p_in_rec.PREFERRED_GRADE ;
	ELSIF p_disabled_list(i)  = 'LPN_ID' THEN
	  x_out_rec.lpn_id := p_in_rec.lpn_id ;
	ELSIF p_disabled_list(i)  = 'SRC_REQUESTED_QUANTITY2' THEN
	  x_out_rec.SRC_REQUESTED_QUANTITY2 := p_in_rec.SRC_REQUESTED_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'SRC_REQUESTED_QUANTITY_UOM2' THEN
	  x_out_rec.SRC_REQUESTED_QUANTITY_UOM2 := p_in_rec.SRC_REQUESTED_QUANTITY_UOM2 ;
	ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY_UOM2' THEN
	  x_out_rec.REQUESTED_QUANTITY_UOM2 := p_in_rec.REQUESTED_QUANTITY_UOM2 ;
	ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY2' THEN
	  x_out_rec.REQUESTED_QUANTITY2 := p_in_rec.REQUESTED_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'QUALITY_CONTROL_QUANTITY2' THEN
	  x_out_rec.QUALITY_CONTROL_QUANTITY2 := p_in_rec.QUALITY_CONTROL_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'SUBLOT_NUMBER' THEN
	  --x_out_rec.SUBLOT_NUMBER := p_in_rec.SUBLOT_NUMBER ;
          NULL;
	ELSIF p_disabled_list(i)  = 'RETURNED_QUANTITY2' THEN
	  x_out_rec.RETURNED_QUANTITY2 := p_in_rec.RETURNED_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'RECEIVED_QUANTITY2' THEN
	  x_out_rec.RECEIVED_QUANTITY2 := p_in_rec.RECEIVED_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'PICKED_QUANTITY2' THEN
	  x_out_rec.PICKED_QUANTITY2 := p_in_rec.PICKED_QUANTITY2 ;
	ELSIF p_disabled_list(i)  = 'TO_SERIAL_NUMBER' THEN
	  x_out_rec.TO_SERIAL_NUMBER := p_in_rec.TO_SERIAL_NUMBER ;
	ELSIF p_disabled_list(i)  = 'SERIAL_NUMBER' THEN
	  x_out_rec.SERIAL_NUMBER := p_in_rec.SERIAL_NUMBER ;
	ELSIF p_disabled_list(i)  = 'TRANSACTION_TEMP_ID' THEN
	  x_out_rec.TRANSACTION_TEMP_ID := p_in_rec.TRANSACTION_TEMP_ID ;
	ELSIF p_disabled_list(i)  = 'REVISION' THEN
	  x_out_rec.REVISION := p_in_rec.REVISION ;
	ELSIF p_disabled_list(i)  = 'LOT_NUMBER' THEN
	  x_out_rec.LOT_NUMBER := p_in_rec.LOT_NUMBER ;
	ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY_UOM' THEN
	  x_out_rec.REQUESTED_QUANTITY_UOM := p_in_rec.REQUESTED_QUANTITY_UOM ;
        --
	ELSIF p_disabled_list(i)  = 'CYCLE_COUNT_QUANTITY2' THEN
	  x_out_rec.cycle_count_quantity2 := p_in_rec.cycle_count_quantity2 ;
	ELSIF p_disabled_list(i)  = 'CANCELLED_QUANTITY2' THEN
	  x_out_rec.cancelled_quantity2 := p_in_rec.cancelled_quantity2 ;
	ELSIF p_disabled_list(i)  = 'CANCELLED_QUANTITY' THEN
	  x_out_rec.cancelled_quantity := p_in_rec.cancelled_quantity ;
	ELSIF p_disabled_list(i)  = 'INSPECTION_FLAG' THEN
	  x_out_rec.INSPECTION_FLAG := p_in_rec.INSPECTION_FLAG ;
	ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
	  x_out_rec.attribute1 := p_in_rec.attribute1 ;
	  x_out_rec.attribute2 := p_in_rec.attribute2 ;
	  x_out_rec.attribute3 := p_in_rec.attribute3 ;
	  x_out_rec.attribute4 := p_in_rec.attribute4 ;
	  x_out_rec.attribute5 := p_in_rec.attribute5 ;
	  x_out_rec.attribute6 := p_in_rec.attribute6 ;
	  x_out_rec.attribute7 := p_in_rec.attribute7 ;
	  x_out_rec.attribute8 := p_in_rec.attribute8 ;
	  x_out_rec.attribute9 := p_in_rec.attribute9 ;
	  x_out_rec.attribute10 := p_in_rec.attribute10 ;
	  x_out_rec.attribute11 := p_in_rec.attribute11 ;
	  x_out_rec.attribute12 := p_in_rec.attribute12 ;
	  x_out_rec.attribute13 := p_in_rec.attribute13 ;
	  x_out_rec.attribute14 := p_in_rec.attribute14 ;
	  x_out_rec.attribute15 := p_in_rec.attribute15 ;
	  x_out_rec.attribute_category := p_in_rec.attribute_category ;
	ELSIF p_disabled_list(i)  = 'SUBINVENTORY' THEN
	  x_out_rec.subinventory := p_in_rec.subinventory ;
	ELSIF p_disabled_list(i)  = 'REVISION' THEN
	  x_out_rec.revision := p_in_rec.revision ;
	ELSIF p_disabled_list(i)  = 'LOCATOR_NAME' THEN
	  x_out_rec.locator_id := p_in_rec.locator_id ;
	ELSIF p_disabled_list(i)  = 'LOT_NUMBER' THEN
	  x_out_rec.lot_number := p_in_rec.lot_number;
	ELSIF p_disabled_list(i)  = 'DELIVERED_QUANTITY2' THEN
	  x_out_rec.delivered_quantity2 := p_in_rec.delivered_quantity2 ;
	ELSIF p_disabled_list(i)  = 'DELIVERED_QUANTITY' THEN
	  x_out_rec.delivered_quantity := p_in_rec.delivered_quantity ;
	ELSIF p_disabled_list(i)  = 'DETAIL_CONTAINER_ITEM_NAME' THEN
	  x_out_rec.detail_container_item_id := p_in_rec.detail_container_item_id ;
	ELSIF p_disabled_list(i)  = 'GROSS_WEIGHT' THEN
	  x_out_rec.gross_weight := p_in_rec.gross_weight ;
        ELSIF p_disabled_list(i)  = 'TARE_WEIGHT' THEN
          null;
-- J-IB-NPARIKH-{  ---I-bug-fix
 ELSIF p_disabled_list(i)  = 'NET_WEIGHT' THEN
   x_out_rec.net_weight := p_in_rec.net_weight ;
 ELSIF p_disabled_list(i)  = 'VOLUME' THEN
   x_out_rec.VOLUME := p_in_rec.VOLUME ;
-- J-IB-NPARIKH-}
        -- J: W/V Changes
        ELSIF p_disabled_list(i)  = 'FILLED_VOLUME' THEN
          x_out_rec.FILLED_VOLUME := p_in_rec.FILLED_VOLUME ;
        ELSIF p_disabled_list(i)  = 'FILL_PERCENT' THEN
          x_out_rec.FILLED_VOLUME := p_in_rec.FILL_PERCENT ;

	ELSIF p_disabled_list(i)  = 'LOAD_SEQ_NUMBER' THEN
	  x_out_rec.load_seq_number := p_in_rec.load_seq_number ;
	ELSIF p_disabled_list(i)  = 'MASTER_CONTAINER_ITEM_NAME' THEN
	  x_out_rec.master_container_item_id := p_in_rec.master_container_item_id ;
	ELSIF p_disabled_list(i)  = 'PACKING_INSTRUCTIONS' THEN
	  x_out_rec.PACKING_INSTRUCTIONS := p_in_rec.PACKING_INSTRUCTIONS ;
	ELSIF p_disabled_list(i)  = 'SHIPPING_INSTRUCTIONS' THEN
	  x_out_rec.shipping_instructions := p_in_rec.shipping_instructions ;
	ELSIF p_disabled_list(i)  = 'SHIPPED_QUANTITY' THEN
	  x_out_rec.shipped_quantity := p_in_rec.shipped_quantity ;
	ELSIF p_disabled_list(i)  = 'SEAL_CODE' THEN
	  x_out_rec.seal_code := p_in_rec.seal_code ;
	ELSIF p_disabled_list(i)  = 'SHIPPED_QUANTITY2' THEN
	  x_out_rec.shipped_quantity2 := p_in_rec.shipped_quantity2 ;
	ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
	  x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
	  x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
	  x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
	  x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
	  x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
	  x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
	  x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
	  x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
	  x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
	  x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
	  x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
	  x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
	  x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
	  x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
	  x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
	  x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
	ELSIF p_disabled_list(i)  = 'TRACKING_NUMBER' THEN
	  x_out_rec.tracking_number := p_in_rec.tracking_number ;
        -- Commenting out Tare weight Field to make it enable for non-container
        -- items for bug 2890559
/*	ELSIF p_disabled_list(i)  = 'TARE_WEIGHT'
	   OR p_disabled_list(i)  = 'FULL'		THEN*/
        ELSIF p_disabled_list(i)  = 'FULL' THEN
	  NULL;
	ELSE
	  -- invalid name
	  x_field_name := p_disabled_list(i);
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  RETURN;
	  --
	END IF;
  END LOOP;
END disable_from_list;

/*----------------------------------------------------------
-- Procedure enable_from_list will update the record x_out_rec for the fields
--   included in p_disabled_list and will enable them
-----------------------------------------------------------*/

PROCEDURE enable_from_list(
  p_disabled_list IN		 WSH_UTIL_CORE.column_tab_type
, p_in_rec        IN            wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_out_rec       IN OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_return_status OUT NOCOPY		 VARCHAR2
, x_field_name	OUT NOCOPY		 VARCHAR2

) IS
--Added as a part of fix for bug # 6082324 and bug 7165744 added msi.primary_uom_code to cursor
cursor get_MSI_details (p_inventory_item_id NUMBER,p_delivery_detail_id NUMBER) IS
 SELECT msi.container_type_code,msi.maximum_load_weight,msi.primary_uom_code
 FROM   mtl_system_items msi,wsh_delivery_details wdd
 WHERE  msi.inventory_item_id (+) = p_inventory_item_id
 AND    msi.organization_id   (+) = wdd.organization_id
 AND    wdd.container_flag = 'Y'
 AND    wdd.delivery_detail_id = p_delivery_detail_id;

 l_container_type_code     VARCHAR2(30);
 l_maximum_load_weight     NUMBER;
 l_cursor_opened_flag      NUMBER := 0;
-- End of bug # 6082324
 l_requested_quantity_uom  VARCHAR2(30); --bug 7165744
BEGIN
  --
  --
  FOR i IN 2..p_disabled_list.COUNT
  LOOP
	IF p_disabled_list(i)  = 'CONTAINER_NAME' THEN
	 IF p_in_rec.CONTAINER_NAME <> FND_API.G_MISS_CHAR
	  OR p_in_rec.CONTAINER_NAME IS NULL THEN
	   x_out_rec.container_name := p_in_rec.container_name ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'CYCLE_COUNT_QUANTITY' THEN
	 IF p_in_rec.cycle_count_quantity <> FND_API.G_MISS_NUM
	  OR p_in_rec.cycle_count_quantity IS NULL THEN
	   x_out_rec.cycle_count_quantity := p_in_rec.cycle_count_quantity ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'INSPECTION_FLAG' THEN
	 IF p_in_rec.INSPECTION_FLAG <> FND_API.G_MISS_CHAR
	  OR p_in_rec.INSPECTION_FLAG IS NULL THEN
	   x_out_rec.INSPECTION_FLAG := p_in_rec.INSPECTION_FLAG ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'CYCLE_COUNT_QUANTITY2' THEN
	 IF p_in_rec.cycle_count_quantity2 <> FND_API.G_MISS_NUM
	  OR p_in_rec.cycle_count_quantity2 IS NULL THEN
	   x_out_rec.cycle_count_quantity2 := p_in_rec.cycle_count_quantity2 ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'CANCELLED_QUANTITY2' THEN
	 IF p_in_rec.cancelled_quantity2 <> FND_API.G_MISS_NUM
	  OR p_in_rec.cancelled_quantity2 IS NULL THEN
	   x_out_rec.cancelled_quantity2 := p_in_rec.cancelled_quantity2 ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'CANCELLED_QUANTITY' THEN
	 IF p_in_rec.cancelled_quantity <> FND_API.G_MISS_NUM
	  OR p_in_rec.cancelled_quantity IS NULL THEN
	   x_out_rec.cancelled_quantity := p_in_rec.cancelled_quantity ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'DELIVERED_QUANTITY2' THEN
	 IF p_in_rec.delivered_quantity2 <> FND_API.G_MISS_NUM
	  OR p_in_rec.delivered_quantity2 IS NULL THEN
	   x_out_rec.delivered_quantity2 := p_in_rec.delivered_quantity2 ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'DELIVERED_QUANTITY' THEN
	 IF p_in_rec.delivered_quantity <> FND_API.G_MISS_NUM
	  OR p_in_rec.delivered_quantity IS NULL THEN
	   x_out_rec.delivered_quantity := p_in_rec.delivered_quantity ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'DETAIL_CONTAINER_ITEM_NAME' THEN
	 IF p_in_rec.detail_container_item_id <> FND_API.G_MISS_NUM
	  OR p_in_rec.detail_container_item_id IS NULL THEN
	   x_out_rec.detail_container_item_id := p_in_rec.detail_container_item_id ;
	 END IF;
-- for X-dock
	ELSIF p_disabled_list(i)  = 'RELEASED_STATUS' THEN
	 IF p_in_rec.released_status <> FND_API.G_MISS_CHAR
	  OR p_in_rec.released_status IS NULL THEN
	   x_out_rec.released_status := p_in_rec.released_status;
	 END IF;
	ELSIF p_disabled_list(i)  = 'MOVE_ORDER_LINE_ID' THEN
	 IF p_in_rec.move_order_line_id <> FND_API.G_MISS_NUM
	  OR p_in_rec.move_order_line_id IS NULL THEN
	   x_out_rec.move_order_line_id := p_in_rec.move_order_line_id;
	 END IF;
    --bug# 6689448 (replenishment project)
 	ELSIF p_disabled_list(i)  = 'REPLENISHMENT_STATUS' THEN
        IF p_in_rec.REPLENISHMENT_STATUS <> FND_API.G_MISS_CHAR
           OR p_in_rec. REPLENISHMENT_STATUS IS NULL THEN
            x_out_rec.REPLENISHMENT_STATUS:= p_in_rec.REPLENISHMENT_STATUS;
        END IF;
    ELSIF p_disabled_list(i)  = 'BATCH_ID' THEN
         IF p_in_rec.batch_id <> FND_API.G_MISS_NUM
          OR p_in_rec.batch_id IS NULL THEN
           x_out_rec.batch_id := p_in_rec.batch_id;
         END IF;
-- end of X-dock changes
	ELSIF p_disabled_list(i)  = 'GROSS_WEIGHT' THEN
	 IF p_in_rec.gross_weight <> FND_API.G_MISS_NUM
	  OR p_in_rec.gross_weight IS NULL THEN
	   x_out_rec.gross_weight := p_in_rec.gross_weight ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'TARE_WEIGHT' THEN
	   null;
-- J-IB-NPARIKH-{       --I-bug-fix
 ELSIF p_disabled_list(i)  = 'NET_WEIGHT' THEN
  IF p_in_rec.net_weight <> FND_API.G_MISS_NUM
   OR p_in_rec.net_weight IS NULL THEN
    x_out_rec.net_weight := p_in_rec.net_weight ;
  END IF;
 ELSIF p_disabled_list(i)  = 'VOLUME' THEN
  IF p_in_rec.VOLUME <> FND_API.G_MISS_NUM
   OR p_in_rec.VOLUME IS NULL THEN
    x_out_rec.VOLUME := p_in_rec.VOLUME ;
  END IF;
  -- J-IB-NPARIKH-}
        -- bug 5077108
        ELSIF p_disabled_list(i)  = 'INVENTORY_ITEM_ID' THEN
         IF p_in_rec.inventory_item_id <> FND_API.G_MISS_NUM
          OR p_in_rec.inventory_item_id IS NULL THEN
           x_out_rec.inventory_item_id := p_in_rec.inventory_item_id ;
         END IF;
        -- end bug 5077108

        --Bug 5212632 Start
        ELSIF p_disabled_list(i)  = 'CONTAINER_TYPE_CODE' THEN
            IF p_in_rec.container_type_code <> FND_API.G_MISS_CHAR
               OR p_in_rec.container_type_code IS NULL THEN

                   x_out_rec.container_type_code := p_in_rec.container_type_code;
            ELSIF (p_in_rec.inventory_item_id <> FND_API.G_MISS_NUM ) THEN
	    IF l_cursor_opened_flag = 1 THEN
            x_out_rec.container_type_code:=l_container_type_code;
            ELSE
            OPEN get_MSI_details (p_in_rec.inventory_item_id,p_in_rec.delivery_detail_id);
            FETCH get_MSI_details INTO l_container_type_code,
                                    l_maximum_load_weight,
                                    l_requested_quantity_uom;
             x_out_rec.container_type_code:=l_container_type_code;
            CLOSE get_MSI_details ;
            l_cursor_opened_flag:=1;
            END IF;
            END IF;
            --Bug 5212632 End
            --Bug 7165744
     --requested_quantity_uom can be updated for WMS LPNs.
        ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY_UOM' THEN
         IF (p_in_rec.inventory_item_id <> FND_API.G_MISS_NUM ) THEN
          IF l_cursor_opened_flag = 1 THEN
            x_out_rec.requested_quantity_uom:=l_requested_quantity_uom;
          ELSE
          OPEN get_MSI_details (p_in_rec.inventory_item_id,p_in_rec.delivery_detail_id);
          FETCH get_MSI_details INTO l_container_type_code,
                                     l_maximum_load_weight,
                                     l_requested_quantity_uom;
           x_out_rec.requested_quantity_uom:=l_requested_quantity_uom;
           CLOSE get_MSI_details ;
           l_cursor_opened_flag:=1;
           END IF;
          END IF;
     -- end Bug 7165744
     --Added the following code as part of fix for bug 6082324
        ELSIF p_disabled_list(i)  = 'MAXIMUM_LOAD_WEIGHT' THEN
         IF p_in_rec.MAXIMUM_LOAD_WEIGHT <> FND_API.G_MISS_NUM
         OR p_in_rec.MAXIMUM_LOAD_WEIGHT IS NULL THEN
            x_out_rec.MAXIMUM_LOAD_WEIGHT := p_in_rec.MAXIMUM_LOAD_WEIGHT;
         ELSIF (p_in_rec.inventory_item_id <> FND_API.G_MISS_NUM ) THEN
          IF l_cursor_opened_flag = 1 THEN
             x_out_rec.MAXIMUM_LOAD_WEIGHT:=l_maximum_load_weight;
          ELSE
            OPEN get_MSI_details (p_in_rec.inventory_item_id,p_in_rec.delivery_detail_id);
            FETCH get_MSI_details INTO l_container_type_code,
                                       l_maximum_load_weight,
                                       l_requested_quantity_uom;
            CLOSE get_MSI_details ;
            l_cursor_opened_flag:=1;
            x_out_rec.MAXIMUM_LOAD_WEIGHT:=l_maximum_load_weight;
           END IF;
         END IF;
      --End of fix for bug # 6082324


	ELSIF p_disabled_list(i)  = 'LOCATOR_NAME' THEN
	 IF p_in_rec.locator_id <> FND_API.G_MISS_NUM
	  OR p_in_rec.locator_id IS NULL THEN
	   x_out_rec.locator_id := p_in_rec.locator_id ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'LOAD_SEQ_NUMBER' THEN
	 IF p_in_rec.load_seq_number <> FND_API.G_MISS_NUM
	  OR p_in_rec.load_seq_number IS NULL THEN
	   x_out_rec.load_seq_number := p_in_rec.load_seq_number ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'LPN_ID' THEN
	 IF p_in_rec.lpn_id <> FND_API.G_MISS_NUM
	  OR p_in_rec.lpn_id IS NULL THEN
	   x_out_rec.lpn_id := p_in_rec.lpn_id ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'MASTER_CONTAINER_ITEM_NAME' THEN
	 IF p_in_rec.master_container_item_id <> FND_API.G_MISS_NUM
	  OR p_in_rec.master_container_item_id IS NULL THEN
	   x_out_rec.master_container_item_id := p_in_rec.master_container_item_id ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'PACKING_INSTRUCTIONS' THEN
	 IF p_in_rec.PACKING_INSTRUCTIONS <> FND_API.G_MISS_CHAR
	  OR p_in_rec.PACKING_INSTRUCTIONS IS NULL THEN
	   x_out_rec.PACKING_INSTRUCTIONS := p_in_rec.PACKING_INSTRUCTIONS ;
	 END IF;
        ELSIF p_disabled_list(i)  = 'PICKED_QUANTITY2' THEN
         IF p_in_rec.PICKED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.PICKED_QUANTITY2 IS NULL THEN
           x_out_rec.picked_quantity2 := p_in_rec.picked_quantity2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY_UOM2' THEN
         IF p_in_rec.REQUESTED_QUANTITY_UOM2 <> FND_API.G_MISS_CHAR
          OR p_in_rec.REQUESTED_QUANTITY_UOM2 IS NULL THEN
           x_out_rec.REQUESTED_QUANTITY_UOM2 := p_in_rec.REQUESTED_QUANTITY_UOM2 ;
         END IF;

        -- bmso
        ELSIF p_disabled_list(i)  = 'PREFERED_GRADE' THEN
         IF p_in_rec.PREFERRED_GRADE <> FND_API.G_MISS_CHAR
          OR p_in_rec.PREFERRED_GRADE IS NULL THEN
           x_out_rec.PREFERRED_GRADE := p_in_rec.PREFERRED_GRADE ;
         END IF;
        ELSIF p_disabled_list(i)  = 'SRC_REQUESTED_QUANTITY2' THEN
         IF p_in_rec.SRC_REQUESTED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.SRC_REQUESTED_QUANTITY2 IS NULL THEN
           x_out_rec.SRC_REQUESTED_QUANTITY2 := p_in_rec.SRC_REQUESTED_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'SRC_REQUESTED_QUANTITY_UOM2' THEN
         IF p_in_rec.SRC_REQUESTED_QUANTITY_UOM2 <> FND_API.G_MISS_CHAR
          OR p_in_rec.SRC_REQUESTED_QUANTITY_UOM2 IS NULL THEN
           x_out_rec.SRC_REQUESTED_QUANTITY_UOM2 := p_in_rec.SRC_REQUESTED_QUANTITY_UOM2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY2' THEN
         IF p_in_rec.REQUESTED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.REQUESTED_QUANTITY2 IS NULL THEN
           x_out_rec.REQUESTED_QUANTITY2 := p_in_rec.REQUESTED_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'QUALITY_CONTROL_QUANTITY2' THEN
         IF p_in_rec.QUALITY_CONTROL_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.QUALITY_CONTROL_QUANTITY2 IS NULL THEN
           x_out_rec.QUALITY_CONTROL_QUANTITY2 := p_in_rec.QUALITY_CONTROL_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'SUBLOT_NUMBER' THEN
         NULL;
         --IF p_in_rec.SUBLOT_NUMBER <> FND_API.G_MISS_CHAR
          --OR p_in_rec.SUBLOT_NUMBER IS NULL THEN
           --x_out_rec.SUBLOT_NUMBER := p_in_rec.SUBLOT_NUMBER ;
         --END IF;
        ELSIF p_disabled_list(i)  = 'RETURNED_QUANTITY2' THEN
         IF p_in_rec.RETURNED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.RETURNED_QUANTITY2 IS NULL THEN
           x_out_rec.RETURNED_QUANTITY2 := p_in_rec.RETURNED_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'RECEIVED_QUANTITY2' THEN
         IF p_in_rec.RECEIVED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.RECEIVED_QUANTITY2 IS NULL THEN
           x_out_rec.RECEIVED_QUANTITY2 := p_in_rec.RECEIVED_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'PICKED_QUANTITY2' THEN
         IF p_in_rec.PICKED_QUANTITY2 <> FND_API.G_MISS_NUM
          OR p_in_rec.PICKED_QUANTITY2 IS NULL THEN
           x_out_rec.PICKED_QUANTITY2 := p_in_rec.PICKED_QUANTITY2 ;
         END IF;
        ELSIF p_disabled_list(i)  = 'TO_SERIAL_NUMBER' THEN
         IF p_in_rec.TO_SERIAL_NUMBER <> FND_API.G_MISS_CHAR
          OR p_in_rec.TO_SERIAL_NUMBER IS NULL THEN
           x_out_rec.TO_SERIAL_NUMBER := p_in_rec.TO_SERIAL_NUMBER ;
         END IF;
        ELSIF p_disabled_list(i)  = 'SERIAL_NUMBER' THEN
         IF p_in_rec.SERIAL_NUMBER <> FND_API.G_MISS_CHAR
          OR p_in_rec.SERIAL_NUMBER IS NULL THEN
           x_out_rec.SERIAL_NUMBER := p_in_rec.SERIAL_NUMBER ;
         END IF;
        ELSIF p_disabled_list(i)  = 'TRANSACTION_TEMP_ID' THEN
         IF p_in_rec.TRANSACTION_TEMP_ID <> FND_API.G_MISS_NUM
          OR p_in_rec.TRANSACTION_TEMP_ID IS NULL THEN
           x_out_rec.TRANSACTION_TEMP_ID := p_in_rec.TRANSACTION_TEMP_ID ;
         END IF;
        ELSIF p_disabled_list(i)  = 'REVISION' THEN
         IF p_in_rec.REVISION <> FND_API.G_MISS_CHAR
          OR p_in_rec.REVISION IS NULL THEN
           x_out_rec.REVISION := p_in_rec.REVISION ;
         END IF;
        ELSIF p_disabled_list(i)  = 'LOT_NUMBER' THEN
         IF p_in_rec.LOT_NUMBER <> FND_API.G_MISS_CHAR
          OR p_in_rec.LOT_NUMBER IS NULL THEN
           x_out_rec.LOT_NUMBER := p_in_rec.LOT_NUMBER ;
         END IF;
        ELSIF p_disabled_list(i)  = 'REQUESTED_QUANTITY_UOM' THEN
         IF p_in_rec.REQUESTED_QUANTITY_UOM <> FND_API.G_MISS_CHAR
          OR p_in_rec.REQUESTED_QUANTITY_UOM IS NULL THEN
           x_out_rec.REQUESTED_QUANTITY_UOM := p_in_rec.REQUESTED_QUANTITY_UOM ;
         END IF;
        --
	ELSIF p_disabled_list(i)  = 'SHIPPING_INSTRUCTIONS' THEN
	 IF p_in_rec.shipping_instructions <> FND_API.G_MISS_CHAR
	  OR p_in_rec.shipping_instructions IS NULL THEN
	   x_out_rec.shipping_instructions := p_in_rec.shipping_instructions ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'SHIPPED_QUANTITY' THEN
	 IF p_in_rec.shipped_quantity <> FND_API.G_MISS_NUM
	  OR p_in_rec.shipped_quantity IS NULL THEN
	   x_out_rec.shipped_quantity := p_in_rec.shipped_quantity ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'SEAL_CODE' THEN
	 IF p_in_rec.seal_code <> FND_API.G_MISS_CHAR
	  OR p_in_rec.seal_code IS NULL THEN
	   x_out_rec.seal_code := p_in_rec.seal_code ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'SHIPPED_QUANTITY2' THEN
	 IF p_in_rec.shipped_quantity2 <> FND_API.G_MISS_NUM
	  OR p_in_rec.shipped_quantity2 IS NULL THEN
	   x_out_rec.shipped_quantity2 := p_in_rec.shipped_quantity2 ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'SUBINVENTORY' THEN
	 IF p_in_rec.subinventory <> FND_API.G_MISS_CHAR
	  OR p_in_rec.subinventory IS NULL THEN
	   x_out_rec.subinventory := p_in_rec.subinventory ;
	 END IF;
	-- TPW - Distributed changes
        ELSIF p_disabled_list(i)  = 'REVISION' THEN
         IF p_in_rec.revision <> FND_API.G_MISS_CHAR
          OR p_in_rec.revision IS NULL THEN
           x_out_rec.revision := p_in_rec.revision ;
         END IF;
        --Bugfix 6939348 start
	ELSIF p_disabled_list(i)  = 'LOT_NUMBER' THEN
	 IF p_in_rec.lot_number <> FND_API.G_MISS_CHAR
	  OR p_in_rec.lot_number IS NULL THEN
	   x_out_rec.lot_number := p_in_rec.lot_number;
	 END IF;
	-- Bugfix 6939348 end
	ELSIF p_disabled_list(i)  = 'TRACKING_NUMBER' THEN
	 IF p_in_rec.tracking_number <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tracking_number IS NULL THEN
	   x_out_rec.tracking_number := p_in_rec.tracking_number ;
	 END IF;
        ELSIF p_disabled_list(i)  = 'SHIP_METHOD_CODE' THEN
         IF p_in_rec.ship_method_code <> FND_API.G_MISS_CHAR
          OR p_in_rec.ship_method_code IS NULL THEN
           x_out_rec.ship_method_code := p_in_rec.ship_method_code ;
         END IF;
        ELSIF p_disabled_list(i)  = 'CARRIER_ID' THEN
         IF p_in_rec.carrier_id <> FND_API.G_MISS_NUM
          OR p_in_rec.carrier_id IS NULL THEN
           x_out_rec.carrier_id := p_in_rec.carrier_id ;
         END IF;
        ELSIF p_disabled_list(i)  = 'MODE_OF_TRANSPORT' THEN
         IF p_in_rec.ship_method_code <> FND_API.G_MISS_CHAR
          OR p_in_rec.mode_of_transport IS NULL THEN
           x_out_rec.mode_of_transport := p_in_rec.mode_of_transport ;
         END IF;
        ELSIF p_disabled_list(i)  = 'SERVICE_LEVEL' THEN
         IF p_in_rec.service_level <> FND_API.G_MISS_CHAR
          OR p_in_rec.service_level IS NULL THEN
           x_out_rec.service_level := p_in_rec.service_level ;
         END IF;
        ELSIF p_disabled_list(i)  = 'ITEM_NUMBER' THEN
         IF nvl(p_in_rec.inventory_item_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
         THEN
           x_out_rec.inventory_item_id := p_in_rec.inventory_item_id ;
         END IF;
	ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
	 IF p_in_rec.attribute1 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute1 IS NULL THEN
	   x_out_rec.attribute1 := p_in_rec.attribute1 ;
	 END IF;
	 IF p_in_rec.attribute2 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute2  IS NULL THEN
	   x_out_rec.attribute2 := p_in_rec.attribute2 ;
	 END IF;
	 IF p_in_rec.attribute3 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute3 IS NULL THEN
	  x_out_rec.attribute3 := p_in_rec.attribute3 ;
	 END IF;
	 IF p_in_rec.attribute4 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute4 IS NULL THEN
	  x_out_rec.attribute4 := p_in_rec.attribute4 ;
	 END IF;
	 IF p_in_rec.attribute5 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute5 IS NULL THEN
	  x_out_rec.attribute5 := p_in_rec.attribute5 ;
	 END IF;
	 IF p_in_rec.attribute6 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute6 IS NULL THEN
	  x_out_rec.attribute6 := p_in_rec.attribute6 ;
	 END IF;
	 IF p_in_rec.attribute7 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute7 IS NULL THEN
	  x_out_rec.attribute7 := p_in_rec.attribute7 ;
	 END IF;
	 IF p_in_rec.attribute8 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute8 IS NULL THEN
	  x_out_rec.attribute8 := p_in_rec.attribute8 ;
	 END IF;
	 IF p_in_rec.attribute9 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute9 IS NULL THEN
	  x_out_rec.attribute9 := p_in_rec.attribute9 ;
	 END IF;
	 IF p_in_rec.attribute10 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute10 IS NULL THEN
	  x_out_rec.attribute10 := p_in_rec.attribute10 ;
	 END IF;
	 IF p_in_rec.attribute11 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute11 IS NULL THEN
	  x_out_rec.attribute11 := p_in_rec.attribute11 ;
	 END IF;
	 IF p_in_rec.attribute12 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute12 IS NULL THEN
	  x_out_rec.attribute12 := p_in_rec.attribute12 ;
	 END IF;
	 IF p_in_rec.attribute13 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute13 IS NULL THEN
	  x_out_rec.attribute13 := p_in_rec.attribute13 ;
	 END IF;
	 IF p_in_rec.attribute14 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute14 IS NULL THEN
	  x_out_rec.attribute14 := p_in_rec.attribute14 ;
	 END IF;
	 IF p_in_rec.attribute15 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute15 IS NULL THEN
	  x_out_rec.attribute15 := p_in_rec.attribute15 ;
	 END IF;
	 IF p_in_rec.attribute_category <> FND_API.G_MISS_CHAR
	  OR p_in_rec.attribute_category IS NULL THEN
	  x_out_rec.attribute_category := p_in_rec.attribute_category ;
	 END IF;
	ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
	 IF p_in_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute1 IS NULL THEN
	  x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
	 END IF;
	 IF p_in_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute2 IS NULL THEN
	  x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
	 END IF;
	 IF p_in_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute3 IS NULL THEN
	  x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
	 END IF;
	 IF p_in_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute4 IS NULL THEN
	  x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
	 END IF;
	 IF p_in_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute5 IS NULL THEN
	  x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
	 END IF;
	 IF p_in_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute6 IS NULL THEN
	  x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
	 END IF;
	 IF p_in_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute7 IS NULL THEN
	  x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
	 END IF;
	 IF p_in_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute8 IS NULL THEN
	  x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
	 END IF;
	 IF p_in_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute9 IS NULL THEN
	  x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
	 END IF;
	 IF p_in_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute10 IS NULL THEN
	  x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
	 END IF;
	 IF p_in_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute11 IS NULL THEN
	  x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
	 END IF;
	 IF p_in_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute12 IS NULL THEN
	  x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
	 END IF;
	 IF p_in_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute13 IS NULL THEN
	  x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
	 END IF;
	 IF p_in_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute14 IS NULL THEN
	  x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
	 END IF;
	 IF p_in_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute15 IS NULL THEN
	  x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
	 END IF;
	 IF p_in_rec.tp_attribute_category <> FND_API.G_MISS_CHAR
	  OR p_in_rec.tp_attribute_category IS NULL THEN
	  x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
	 END IF;
        -- Commenting out Tare Weight field to make it enable for
        -- non-container items for bug 2890559
/*	ELSIF p_disabled_list(i)  = 'TARE_WEIGHT'  THEN
	  NULL;*/
	ELSE
	  -- invalid name
	  x_field_name := p_disabled_list(i);
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  RETURN;
	  --
	END IF;
  END LOOP;
END enable_from_list;

--
-- Overloaded procedure
--
PROCEDURE Get_Disabled_List  (
  p_delivery_detail_rec   IN  wsh_glbl_var_strct_grp.delivery_details_rec_type
, p_delivery_id		  IN  NUMBER
, p_in_rec                IN  wsh_glbl_var_strct_grp.detailInRecType
, x_return_status	  OUT NOCOPY VARCHAR2
, x_msg_count		  OUT NOCOPY NUMBER
, x_msg_data		  OUT NOCOPY VARCHAR2
, x_delivery_detail_rec   OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_rec_type
)
IS
  l_disabled_list			   WSH_UTIL_CORE.column_tab_type;
  l_db_col_rec                             wsh_glbl_var_strct_grp.delivery_details_rec_type;
  l_return_status			   VARCHAR2(30);
  l_field_name				  VARCHAR2(100);
  j							 NUMBER := 0;
  l_status_code				 VARCHAR2(3);
  l_released_status			 VARCHAR2(1);
  l_lpn_id					  NUMBER;
  l_all_disabled				VARCHAR2(1):='N';
  l_inv_controls                         WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;
  l_inventory_item_id                    NUMBER;
  l_organization_id                      NUMBER;
  l_pickable_flag                        VARCHAR2(1);
  l_subinventory                         VARCHAR2(30);
  i  NUMBER;


l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
			 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';


  CURSOR get_delivery_status IS
  SELECT status_code
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;


  CURSOR c_tbl_rec IS
  SELECT delivery_detail_id
		,source_code
		,source_header_id
		,source_line_id
		,customer_id
		,sold_to_contact_id
		,inventory_item_id
		,item_description
		,hazard_class_id
		,country_of_origin
		,classification
		,ship_from_location_id
		,ship_to_location_id
		,ship_to_contact_id
		,ship_to_site_use_id
		,deliver_to_location_id
		,deliver_to_contact_id
		,deliver_to_site_use_id
		,intmed_ship_to_location_id
		,intmed_ship_to_contact_id
		,hold_code
		,ship_tolerance_above
		,ship_tolerance_below
		,requested_quantity
		,shipped_quantity
		,delivered_quantity
		,requested_quantity_uom
		,subinventory
		,revision
		,lot_number
		,customer_requested_lot_flag
		,serial_number
		,locator_id
		,date_requested
		,date_scheduled
		,master_container_item_id
		,detail_container_item_id
		,load_seq_number
		,ship_method_code
		,carrier_id
		,freight_terms_code
		,shipment_priority_code
		,fob_code
		,customer_item_id
		,dep_plan_required_flag
		,customer_prod_seq
		,customer_dock_code
		,cust_model_serial_number
		,customer_job
		,customer_production_line
		,net_weight
		,weight_uom_code
		,volume
		,volume_uom_code
		,tp_attribute_category
		,tp_attribute1
		,tp_attribute2
		,tp_attribute3
		,tp_attribute4
		,tp_attribute5
		,tp_attribute6
		,tp_attribute7
		,tp_attribute8
		,tp_attribute9
		,tp_attribute10
		,tp_attribute11
		,tp_attribute12
		,tp_attribute13
		,tp_attribute14
		,tp_attribute15
		,attribute_category
		,attribute1
		,attribute2
		,attribute3
		,attribute4
		,attribute5
		,attribute6
		,attribute7
		,attribute8
		,attribute9
		,attribute10
		,attribute11
		,attribute12
		,attribute13
		,attribute14
		,attribute15
		,created_by
		,creation_date
                ,sysdate
                ,FND_GLOBAL.LOGIN_ID
                ,FND_GLOBAL.USER_ID
		,program_application_id
		,program_id
		,program_update_date
		,request_id
		,mvt_stat_status
		,p_delivery_detail_rec.released_flag
		,organization_id
		,transaction_temp_id
		,ship_set_id
		,arrival_set_id
		,ship_model_complete_flag
		,top_model_line_id
		,source_header_number
		,source_header_type_id
		,source_header_type_name
		,cust_po_number
		,ato_line_id
		,src_requested_quantity
		,src_requested_quantity_uom
		,move_order_line_id
		,cancelled_quantity
		,quality_control_quantity
		,cycle_count_quantity
		,tracking_number
		,movement_id
		,shipping_instructions
		,packing_instructions
		,project_id
		,task_id
		,org_id
		,oe_interfaced_flag
		,split_from_delivery_detail_id
		,inv_interfaced_flag
		,source_line_number
		,inspection_flag
		,released_status
		,container_flag
		,container_type_code
		,container_name
		,fill_percent
		,gross_weight
		,master_serial_number
		,maximum_load_weight
		,maximum_volume
		,minimum_fill_percent
		,seal_code
		,unit_number
		,unit_price
		,currency_code
		,freight_class_cat_id
		,commodity_code_cat_id
		,preferred_grade
		,src_requested_quantity2
		,src_requested_quantity_uom2
		,requested_quantity2
		,shipped_quantity2
		,delivered_quantity2
		,cancelled_quantity2
		,quality_control_quantity2
		,cycle_count_quantity2
		,requested_quantity_uom2
-- HW OPMCONV - No need for sublot_number
--              ,sublot_number
		,lpn_id
		,pickable_flag
		,original_subinventory
		,to_serial_number
		,picked_quantity
		,picked_quantity2
		,received_quantity
		,received_quantity2
		,source_line_set_id
		,batch_id
		,p_delivery_detail_rec.ROWID
		,transaction_id
/*J Inbound Logistics new columns. jckwok*/
                ,vendor_id
                ,ship_from_site_id
                ,nvl(line_direction, 'O')
                ,party_id
                ,routing_req_id
                ,shipping_control
                ,source_blanket_reference_id
                ,source_blanket_reference_num
                ,po_shipment_line_id
                ,po_shipment_line_number
                ,returned_quantity
                ,returned_quantity2
                ,rcv_shipment_line_id
                ,source_line_type_code
                ,supplier_item_number
/* J TP Release : New columns ttrichy*/
        ,nvl(IGNORE_FOR_PLANNING, 'N') ignore_for_planning
        ,EARLIEST_PICKUP_DATE
        ,LATEST_PICKUP_DATE
        ,EARLIEST_DROPOFF_DATE
        ,LATEST_DROPOFF_DATE
        ,REQUEST_DATE_TYPE_CODE
        ,tp_delivery_detail_id
        ,source_document_type_id
        -- J: W/V Changes
        ,unit_weight
        ,unit_volume
        ,filled_volume
        ,wv_frozen_flag
        ,mode_of_transport
        ,service_level
/*J IB: asutar*/
        ,po_revision_number
        ,release_revision_number
        ,replenishment_status  --bug# 6689448 (replenishment project)
        -- Standalone Project Start
        ,original_lot_number
        ,reference_number
        ,reference_line_number
        ,reference_line_quantity
        ,reference_line_quantity_uom
        ,original_revision
        ,original_locator_id
        -- Standalone Project End
	-- TPW - Distributed Organization Changes - Start
        ,shipment_batch_id
        ,shipment_line_number
        ,reference_line_id
        -- TPW - Distributed Organization Changes - End
        ,client_id -- LSP PROJECT : Added just for compatibility (not used anywhere)
        ,consignee_flag --RTV changes
  FROM wsh_delivery_details
  WHERE delivery_detail_id = p_delivery_detail_rec.delivery_detail_id;

  e_dp_no_entity EXCEPTION;
  e_bad_field EXCEPTION;
  e_all_disabled EXCEPTION ;

  l_caller               VARCHAR2(32767);
  l_wms_org              VARCHAR2(100) := 'N';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'DELIVERY_DETAIL_ID',p_delivery_detail_rec.DELIVERY_DETAIL_ID);
	  WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	  WSH_DEBUG_SV.log(l_module_name,'p_action',p_in_rec.action_code);
          wsh_debug_sv.log(l_module_name, 'Caller', p_in_rec.caller);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF p_in_rec.action_code = 'CREATE' THEN
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
	 END IF;
	 --
	 -- nothing else need to be disabled
	 --
	 eliminate_displayonly_fields (p_delivery_detail_rec, p_in_rec, x_delivery_detail_rec);
	 IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
	   WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 -- RETURN; --public api changes
  --
  ELSIF p_in_rec.action_code = 'UPDATE' THEN
    --
    l_caller := p_in_rec.caller;
    IF (l_caller like 'FTE%') THEN
      l_caller := 'WSH_PUB';
    END IF;

    -- Added for bug 4399278, 4418754
    IF ( p_in_rec.caller = 'WSH_PUB' and
         p_delivery_detail_rec.subinventory is not null and
         p_delivery_detail_rec.subinventory <> FND_API.G_MISS_CHAR ) THEN
       G_SUBINVENTORY := p_delivery_detail_rec.subinventory;
    END IF;

    Get_Disabled_List( p_delivery_detail_rec.DELIVERY_DETAIL_ID
					 , p_delivery_id
					 , 'FORM'
					 , x_return_status
					 , l_disabled_list
					 , x_msg_count
					 , x_msg_data
					 , l_caller --public api changes
					 );
    --
    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR OR
	x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
    THEN
	--
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
	  WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	RETURN;
	--
    END IF;
    --
    IF l_disabled_list.COUNT = 1 THEN
	IF l_disabled_list(1) = 'FULL' THEN
	  l_all_disabled :='Y';
	  --Everything  is disabled
	END IF;
    END IF;

    OPEN c_tbl_rec;
    FETCH c_tbl_rec INTO x_delivery_detail_rec;
	IF c_tbl_rec%NOTFOUND THEN
	--
	   CLOSE c_tbl_rec;
	   RAISE e_dp_no_entity;
	--
	END IF;
    CLOSE c_tbl_rec;

    --
    l_released_status :=  x_delivery_detail_rec.released_status;

  IF (l_disabled_list(1) <> 'FULL') or (l_disabled_list.COUNT <> 0) THEN

      i :=  l_disabled_list.COUNT;

      IF (l_released_status = 'Y')  THEN

         IF p_delivery_detail_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

            l_inventory_item_id := x_delivery_detail_rec.inventory_item_id;

         ELSE

            l_inventory_item_id := p_delivery_detail_rec.inventory_item_id;

         END IF;
         IF p_delivery_detail_rec.organization_id = FND_API.G_MISS_NUM THEN

            l_organization_id := x_delivery_detail_rec.organization_id;

         ELSE

            l_organization_id := p_delivery_detail_rec.organization_id;

         END IF;
         IF p_delivery_detail_rec.pickable_flag = FND_API.G_MISS_CHAR THEN

            l_pickable_flag := x_delivery_detail_rec.pickable_flag;

         ELSE

            l_pickable_flag := p_delivery_detail_rec.pickable_flag;

         END IF;
         IF p_delivery_detail_rec.subinventory = FND_API.G_MISS_CHAR THEN

            l_subinventory := x_delivery_detail_rec.subinventory;


         ELSE

            l_subinventory := p_delivery_detail_rec.subinventory;

         END IF;

      END IF;  -- if l_released_status...

    END IF;



    l_lpn_id := x_delivery_detail_rec.lpn_id;

    IF l_debug_on THEN
	 WSH_DEBUG_SV.log(l_module_name,'list.COUNT',l_disabled_list.COUNT);
    END IF;

    IF l_disabled_list.COUNT = 0 THEN

	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
	 END IF;
	 --
	 -- nothing else need to be disabled
	 --
	 eliminate_displayonly_fields (p_delivery_detail_rec, p_in_rec, x_delivery_detail_rec);

    ELSIF l_disabled_list(1) = 'FULL' THEN
	IF l_disabled_list.COUNT > 1 THEN

	  IF l_debug_on THEN
		  FOR i in 1..l_disabled_list.COUNT
		  LOOP
			WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
		  END LOOP;
		  WSH_DEBUG_SV.log(l_module_name,'calling enable_from_list');
	  END IF;
	  --enable the columns matching the l_disabled_list
	  enable_from_list(l_disabled_list,
					  p_delivery_detail_rec,
					  x_delivery_detail_rec,
					  l_return_status,
					  l_field_name);
	  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		 RAISE e_bad_field;
	  END IF;
	END IF;
    ELSE -- list.count > 1 and list(1) <> 'FULL'
	l_db_col_rec := x_delivery_detail_rec ;
	--
	FOR i in 1..l_disabled_list.COUNT
	LOOP
  	  IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
	  END IF;
	  -- Added for bug 4399278, 4418754
	  IF ( p_in_rec.caller = 'WSH_PUB' and
	       l_disabled_list(i) = 'LOCATOR_NAME' and
	       l_db_col_rec.locator_id is not null and
	       --Modified for bug 4560576, 4701803
	       l_db_col_rec.released_status = 'Y'  and
	       WSH_DELIVERY_DETAILS_INV.get_reservable_flag (
	                             x_item_id => l_inventory_item_id,
	                             x_organization_id => l_organization_id,
	                             x_pickable_flag   => l_pickable_flag ) = 'N' )
	  THEN
	       l_db_col_rec.locator_id := NULL;
	  END IF;
	END LOOP;

	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'First element is not FULL');
	   WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
        END IF;
	--
	eliminate_displayonly_fields (p_delivery_detail_rec, p_in_rec, x_delivery_detail_rec);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'calling disable_from_list');
	END IF;
	-- The fileds in the list are getting disabled
	disable_from_list(l_disabled_list,
					  l_db_col_rec,
					  x_delivery_detail_rec,
					  l_return_status,
					  l_field_name);
	IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
	   RAISE e_bad_field;
	END IF;
    END IF;

    -- Now enable/disable the fields that need to be enabled/disabled
    -- based on the caller.

    l_disabled_list.delete;
    -- rebuild the list according to the caller

    IF p_in_rec.caller like 'WMS%' THEN

	 j:=j+1; l_disabled_list(j) := 'FULL';
	 -- Only the elements in the list will be enabled.
	 -- The other fields will remain enabled/disabled as before (untouched).

	 IF p_delivery_id is not null THEN
	   open get_delivery_status;
	   fetch get_delivery_status into l_status_code;
	   close get_delivery_status;
	 END IF;
         --
         -- lpn conv.
         IF (nvl(l_organization_id, fnd_api.g_miss_num) = fnd_api.g_miss_num) THEN
           l_organization_id := x_delivery_detail_rec.organization_id;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'organization_id is ', l_organization_id);
         END IF;
         l_wms_org := wsh_util_validate.Check_Wms_Org(l_organization_id);
         -- lpn conv.
         --
         --{
	 IF NVL(l_status_code, 'OP') = 'OP' AND l_released_status = 'Y' THEN

		 j:=j+1; l_disabled_list(j) := 'SUBINVENTORY';
		 j:=j+1; l_disabled_list(j) := 'LOCATOR_NAME';
		 j:=j+1; l_disabled_list(j) := 'PICKED_QUANTITY2';
		 -- Bug 3382932
		 j:=j+1; l_disabled_list(j) := 'SHIPPED_QUANTITY2';
		 j:=j+1; l_disabled_list(j) := 'REQUESTED_QUANTITY_UOM2';

         -- X-dock changes
         -- Only for specific cases, let WMS update released_status and MOL
         ELSIF (l_released_status IN (WSH_DELIVERY_DETAILS_PKG.C_READY_TO_RELEASE,
                                      WSH_DELIVERY_DETAILS_PKG.C_BACKORDERED,
                                      WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE)
               AND p_in_rec.caller like 'WMS_XDOCK%') THEN
           if l_debug_on then
             wsh_debug_sv.log(l_module_name, 'WMS Caller to update Released status and MOL', p_in_rec.caller);
           end if;
		 j:=j+1; l_disabled_list(j) := 'RELEASED_STATUS';
		 j:=j+1; l_disabled_list(j) := 'MOVE_ORDER_LINE_ID';
                 j:=j+1; l_disabled_list(j) := 'BATCH_ID';

        -- end of X-dock changes

        --bug# 6689448 (replenishment project): let WMS update replenishment status for ready to release and backorder dds
        ELSIF (l_released_status IN (WSH_DELIVERY_DETAILS_PKG.C_READY_TO_RELEASE,
                                      WSH_DELIVERY_DETAILS_PKG.C_BACKORDERED) AND p_in_rec.caller like 'WMS_REP%') THEN
            j:=j+1;
            l_disabled_list(j) := 'REPLENISHMENT_STATUS';
        ELSIF p_delivery_detail_rec.lpn_id IS NULL AND l_lpn_id is NOT NULL THEN
	    -- LPN sync-up
	    IF (l_wms_org='N') THEN
	      j:=j+1; l_disabled_list(j) := 'CONTAINER_NAME';
            END IF;
	    j:=j+1; l_disabled_list(j) := 'LPN_ID';
	    IF l_released_status = 'X' then
	      j:=j+1; l_disabled_list(j) := 'SUBINVENTORY';
	      j:=j+1; l_disabled_list(j) := 'LOCATOR_NAME';
	    END IF;
	 ELSIF NVL(x_delivery_detail_rec.container_flag,'N') IN ('Y','C') THEN
	    IF l_released_status = 'X' then
	      j:=j+1; l_disabled_list(j) := 'SUBINVENTORY';
	      j:=j+1; l_disabled_list(j) := 'LOCATOR_NAME';
	    END IF;
	END IF; --}

        IF( l_wms_org = 'Y'
            AND NVL(x_delivery_detail_rec.container_flag,'N') IN ('Y','C')
            AND l_released_status = 'X'
            AND x_delivery_detail_rec.inventory_item_id IS NULL
          ) THEN
        --{
	    j:=j+1; l_disabled_list(j) := 'ITEM_NUMBER';
        --}
        END IF;

        -- bug 5077108
        IF l_db_col_rec.container_flag = 'Y' THEN
        --{
           j:=j+1; l_disabled_list(j) := 'INVENTORY_ITEM_ID';
           --Bug 5212632
           j:=j+1; l_disabled_list(j) := 'CONTAINER_TYPE_CODE';
        --}
	-- bug 6082324 -  Adding MAXIMUM_LOAD_WEIGHT TO disabled_list
           j:=j+1; l_disabled_list(j) := 'MAXIMUM_LOAD_WEIGHT';
           -- bug 7165744 Adding REQUESTED_QUANTITY_UOM TO disabled_list
           j:=j+1; l_disabled_list(j) := 'REQUESTED_QUANTITY_UOM';
        END IF;


    ELSIF p_in_rec.caller = 'WSH_INBOUND' THEN
        if l_debug_on then
           wsh_debug_sv.logmsg(l_module_name, 'WSH_INBOUND: Enabling subinventory', WSH_DEBUG_SV.C_STMT_LEVEL);
           wsh_debug_sv.log(l_module_name, 'Input subinventory', p_delivery_detail_rec.subinventory);
	   wsh_debug_sv.log(l_module_name, 'Input LOT_NUMBER', p_delivery_detail_rec.lot_number);
        end if;
        -- Subinventory should be updateable during inbound processing
        j:=j+1; l_disabled_list(j) := 'FULL';
        j:=j+1; l_disabled_list(j) := 'SUBINVENTORY';
        --Bugfix 6939348  start
	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

        WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls(p_delivery_detail_id => x_delivery_detail_rec.delivery_detail_id,
                                                        p_inventory_item_id => x_delivery_detail_rec.inventory_item_id,
                                                        p_organization_id => x_delivery_detail_rec.organization_id,
                                                        p_subinventory => nvl(x_delivery_detail_rec.subinventory,p_delivery_detail_rec.subinventory), -- bug 8303281
                                                        x_inv_controls_rec => l_inv_controls,
                                                        x_return_status => x_return_status);
        --{Bug 8303281
	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
	END IF;

	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'Lot Control Flag',l_inv_controls.lot_flag);
	   WSH_DEBUG_SV.log(l_module_name,'Locator Control Flag',l_inv_controls.loc_flag);
	END IF;
	--}Bug 8303281
        -- TPW - Distributed changes
        IF l_inv_controls.rev_flag = 'Y' THEN
           j:=j+1; l_disabled_list(j) := 'REVISION';
        END IF;

        IF l_inv_controls.lot_flag = 'Y' THEN
           j:=j+1; l_disabled_list(j) := 'LOT_NUMBER';
        END IF;

	--{Bug 8303281
	IF l_inv_controls.loc_flag = 'Y' THEN
	   j:=j+1; l_disabled_list(j) := 'LOCATOR_NAME';
	END IF;

	j:=j+1; l_disabled_list(j) := 'SHIPPED_QUANTITY';
	j:=j+1; l_disabled_list(j) := 'CYCLE_COUNT_QUANTITY';
	--}Bug 8303281
	--Bugfix 6939348  end

     ELSIF p_in_rec.caller = 'WSH_USA' THEN
     -- Bug 3292364
     -- Enable Ship Method Components to be updated for container during OM changes.

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Enable SM Components for CMS changes, caller = WSH_USA'  );
         END IF;
         j:=j+1; l_disabled_list(j) := 'FULL';
         j:=j+1; l_disabled_list(j) := 'SERVICE_LEVEL';
         j:=j+1; l_disabled_list(j) := 'MODE_OF_TRANSPORT';
         j:=j+1; l_disabled_list(j) := 'CARRIER_ID';
         j:=j+1; l_disabled_list(j) := 'SHIP_METHOD_CODE';
     END IF;

     --{Bug 8303281
     IF l_debug_on THEN
        FOR j in 1..l_disabled_list.COUNT
        LOOP
	   WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(j));
	END LOOP;
     END IF;
     --}Bug 8303281

    IF l_disabled_list.count > 1 and l_disabled_list(1) = 'FULL' THEN

	l_all_disabled :='N';
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'calling enable_from_list');
	END IF;

	enable_from_list(l_disabled_list,
					 p_delivery_detail_rec,
					 x_delivery_detail_rec,
					 l_return_status,
					 l_field_name);

	IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
	   RAISE e_bad_field;
	END IF;


    END IF;

    IF l_all_disabled ='Y' THEN
	 RAISE e_all_disabled;
    END IF;
  --
  END IF; /* if action = 'UPDATE' */

  --public api changes
  IF (NVL(p_in_rec.caller, '!!!') <> 'WSH_FSTRX' AND
      NVL(p_in_rec.caller, '!!!') NOT LIKE 'FTE%'
      AND NVL(p_in_rec.caller, '!!!') <> 'WSH_INBOUND'
      AND NVL(p_in_rec.caller, '!!!') <> 'WSH_TPW_INBOUND') THEN
    --
    user_non_updatable_columns
     (p_user_in_rec   => p_delivery_detail_rec,
      p_out_rec       => x_delivery_detail_rec,
      p_in_rec        => p_in_rec,
      x_return_status => l_return_status);
    --
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       x_return_status := l_return_status;
    END IF;
    --
  END IF;
  --
  IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
	WHEN e_all_disabled THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
	  FND_MESSAGE.Set_Token('ENTITY_ID',p_delivery_detail_rec.delivery_detail_id);
	  wsh_util_core.add_message(x_return_status,l_module_name);
	  IF l_debug_on THEN
		-- Nothing is updateable
		WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
	  END IF;
	WHEN e_dp_no_entity THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  -- the message for this is set in original get_disabled_list
	  IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name,'e_dp_no_entity');
	  END IF;
	WHEN e_bad_field THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('WSH','WSH_BAD_FIELD_NAME');
	  FND_MESSAGE.Set_Token('FIELD_NAME',l_field_name);
	  wsh_util_core.add_message(x_return_status,l_module_name);
	  IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Bad field name passed to the list:'
														,l_field_name);
		WSH_DEBUG_SV.pop(l_module_name,'e_bad_field');
	  END IF;

	WHEN OTHERS THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.get_disabled_list',
									  l_module_name);
	  IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
END Get_Disabled_List;


PROCEDURE Init_Detail_Actions_Tbl (
  p_action				   IN				VARCHAR2
, x_detail_actions_tab	   OUT  NOCOPY			 DetailActionsTabType
, x_return_status			OUT  NOCOPY			 VARCHAR2
)

IS
i NUMBER := 0;
l_debug_on BOOLEAN;
l_gc3_is_installed       VARCHAR2(1);  -- OTM R12
  l_module_name CONSTANT VARCHAR2(100) :=
		 'wsh.plsql.' || G_PKG_NAME || '.' || 'Init_Detail_Actions_Tbl';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	  WSH_DEBUG_SV.push(l_module_name);
	  --
	  WSH_DEBUG_SV.log(l_module_name,'p_action', p_action);
  END IF;
  --
  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- End of OTM R12

  --
  -- J-IB-NPARIKH-{
        --
        -- Disable all the actions for inbound/drop-ship lines
        -- when called from shipping transaction form
        --
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
        x_detail_actions_tab(i).caller := 'WSH_FSTRX';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
        x_detail_actions_tab(i).caller := 'WSH_FSTRX';
        x_detail_actions_tab(i).action_not_allowed := p_action;
  -- J-IB-NPARIKH-}
  --

  -- OTM R12 : disable actions for delivery detail
  IF l_gc3_is_installed = 'Y' THEN
    IF p_action IN ('RATE_WITH_UPS', 'UPS_TIME_IN_TRANSIT', 'UPS_ADDRESS_VALIDATION', 'UPS_TRACKING') THEN
      i := i + 1;
      x_detail_actions_tab(i).action_not_allowed := p_action;
    END IF;
  END IF;
  -- End of OTM R12 : disable actions for delivery detail

  -- R12 MDC
  IF p_action IN ( 'ASSIGN','AUTOCREATE-DEL', 'AUTO-PACK',
   	           'AUTO-PACK-MASTER', 'AUTOCREATE-TRIP',
		   'PACK', 'UNASSIGN','UNPACK', 'DELETE',
		   'PICK-SHIP', 'PICK-PACK-SHIP',
		   'CYCLE-COUNT', 'SPLIT-LINE',
	   	   'INCLUDE_PLAN', 'IGNORE_PLAN')
  THEN
    i := i+1;
    x_detail_actions_tab(i).container_flag     := 'C';
    x_detail_actions_tab(i).action_not_allowed := p_action;
    x_detail_actions_tab(i).caller := 'WSH_FSTRX';
    i := i+1;
    x_detail_actions_tab(i).container_flag     := 'C';
    x_detail_actions_tab(i).action_not_allowed := p_action;
    x_detail_actions_tab(i).caller := 'WSH_PUB';
  END IF;
  --

  IF p_action IN ( 'ASSIGN' ,'AUTOCREATE-DEL', 'AUTO-PACK', 'AUTO-PACK-MASTER',
				   'AUTOCREATE-TRIP', 'PACK' , 'PICK-RELEASE',
				   'PICK-RELEASE-UI', 'UNASSIGN','UNPACK','WT-VOL', 'DELETE',
				   'RESOLVE-EXCEPTIONS-UI') THEN

        -- Fixed as part of bug fix 2864546
        -- Resolve Exceptions should be allowed for cancelled lines
        --Bug 7025876
	      --UNASSIGN action should be allowed for cancelled delivery details assigned to planned deliveries
        IF p_action NOT IN ('RESOLVE-EXCEPTIONS-UI','UNASSIGN') THEN
           i := i+1;
           x_detail_actions_tab(i).released_status := 'D';
           x_detail_actions_tab(i).action_not_allowed := p_action;
        END IF;
/*J Inbound Logistics disallowed actions jckwok */
        IF p_action IN ('AUTOCREATE-TRIP','PICK-RELEASE','PICK-RELEASE-UI','DELETE','RESOLVE-EXCEPTIONS-UI') THEN
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'I';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'D';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
        END IF;
        -- J-IB-NPARIKH-{
        --
        IF p_action = 'WT-VOL'
        THEN
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'O';
           x_detail_actions_tab(i).released_status := 'C';
           x_detail_actions_tab(i).action_not_allowed := p_action;
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'IO';
           x_detail_actions_tab(i).released_status := 'C';
           x_detail_actions_tab(i).action_not_allowed := p_action;
        ELSE
        -- J-IB-NPARIKH-}
          --Bug 4370491 Resolve Exception UI should be allowed for Shipped lines
          IF p_action <> 'RESOLVE-EXCEPTIONS-UI' THEN
            i := i + 1;
            x_detail_actions_tab(i).released_status := 'C';
            x_detail_actions_tab(i).action_not_allowed := p_action;
          END IF;
        END IF;
	IF p_action IN ('AUTO-PACK', 'PACK', 'AUTO-PACK-MASTER', 'UNPACK') THEN
	  IF p_action <> 'UNPACK' THEN
		 i := i+1;
		 x_detail_actions_tab(i).released_status := 'S';
		 x_detail_actions_tab(i).action_not_allowed := p_action;
	  END IF;
	   -- Bug fix 2644558
	   -- Disallow packing actions for WMS
	   i := i+1;
	   x_detail_actions_tab(i).org_type := 'WMS';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
	   -- Bug#: 2648481
	   x_detail_actions_tab(i).message_name := 'WSH_WMS_PACK_NOT_ALLOWED';
/*Inbound Logistics disallowed actions jckwok */
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'I';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'D';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
	END IF;
    -- J-IB-NPARIKH-{
        /*
    IF p_action IN ( 'AUTOCREATE-DEL','ASSIGN', 'UNASSIGN','WT-VOL','RESOLVE-EXCEPTIONS-UI' )
        */
    --
    -- Disable auto-create Delivery/assign to delivery/unassign from delivery
    -- actions for inbound/drop-ship lines
    -- when line status is Closed(received) or Purged.
    -- or ship from location id is -1
    --
    IF p_action IN ( 'AUTOCREATE-DEL','ASSIGN', 'UNASSIGN')
    THEN
    --{
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
        x_detail_actions_tab(i).released_status := 'P';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
        x_detail_actions_tab(i).released_status := 'P';
        x_detail_actions_tab(i).action_not_allowed := p_action;
    --}
    END IF;
    --
    --
    IF p_action IN ( 'AUTOCREATE-DEL','ASSIGN', 'UNASSIGN' )
    THEN
    --{
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
        x_detail_actions_tab(i).released_status := 'L';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
        x_detail_actions_tab(i).released_status := 'L';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).ship_from_location_id := WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
        x_detail_actions_tab(i).action_not_allowed    := p_action;
    --}
    END IF;
    -- J-IB-NPARIKH-}

  ELSIF p_action IN  ('CYCLE-COUNT', 'SPLIT-LINE' )  THEN
        i := i+1;
	x_detail_actions_tab(i).released_status := 'D';
	x_detail_actions_tab(i).action_not_allowed := p_action;
	i := i + 1;
	x_detail_actions_tab(i).released_status := 'C';
	x_detail_actions_tab(i).action_not_allowed := p_action;
	i := i + 1;
	x_detail_actions_tab(i).container_flag := 'Y';
	x_detail_actions_tab(i).action_not_allowed := p_action;
        --
        -- Bug fix 2644558
	-- Disallow cycle_count for WMS
        -- Bug fix 2751113 Disallow cycle-count for OKE source system
        -- R12 X-dock project, Split will be allowed conditionally
        -- for released to warehouse line and caller = WMS_XDOCK%
	IF p_action = 'CYCLE-COUNT' THEN
	   i := i+1;
	   x_detail_actions_tab(i).released_status := WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE;
	   x_detail_actions_tab(i).action_not_allowed := p_action;
	   i := i+1;
	   x_detail_actions_tab(i).org_type := 'WMS';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
           i := i+1;
           x_detail_actions_tab(i).source_code := 'OKE';
    	   x_detail_actions_tab(i).action_not_allowed := p_action;
/*Inbound Logistics disallowed actions jckwok */
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'I';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
           i := i+1;
           x_detail_actions_tab(i).line_direction := 'D';
	   x_detail_actions_tab(i).action_not_allowed := p_action;
	END IF;
    -- J-IB-NPARIKH-{
    --
    -- Disable split line action for inbound/drop-ship lines
    -- when line status is Closed(received) or Purged.
    --
    IF p_action = 'SPLIT-LINE'
    THEN
    --{
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
        x_detail_actions_tab(i).released_status := 'L';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
        x_detail_actions_tab(i).released_status := 'L';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
        x_detail_actions_tab(i).released_status := 'P';
        x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
        x_detail_actions_tab(i).released_status := 'P';
        x_detail_actions_tab(i).action_not_allowed := p_action;
    --}
    END IF;
    -- J-IB-NPARIKH-}
  ELSIF p_action = 'PACKING-WORKBENCH' THEN
        i := i+1;
	x_detail_actions_tab(i).released_status := 'C';
	x_detail_actions_tab(i).container_flag := 'N';
	x_detail_actions_tab(i).action_not_allowed := p_action;
	i := i + 1;
	x_detail_actions_tab(i).released_status := 'S';
	x_detail_actions_tab(i).action_not_allowed := p_action;
	i := i + 1;
	x_detail_actions_tab(i).released_status := 'D';
	x_detail_actions_tab(i).action_not_allowed := p_action;
	   -- Bug fix 2644558
	   -- Disallow packing actions for WMS
	i := i+1;
	x_detail_actions_tab(i).org_type := 'WMS';
	x_detail_actions_tab(i).action_not_allowed := p_action;
/*Inbound Logistics disallowed actions jckwok */
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
	x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
	x_detail_actions_tab(i).action_not_allowed := p_action;
  ELSIF p_action = 'ASSIGN-FREIGHT-COSTS' THEN
/*Inbound Logistics disallowed actions jckwok */
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'I';
	x_detail_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_detail_actions_tab(i).line_direction := 'D';
	x_detail_actions_tab(i).action_not_allowed := p_action;
  -- J-IB-NPARIKH-{
  ELSIF p_Action = 'INCLUDE_PLAN'
  THEN
  --{
        --
        -- Lines cannot be included for planning if ship-from location is null
        --
        i := i+1;
        x_detail_actions_tab(i).ship_from_location_id := WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
        x_detail_actions_tab(i).action_not_allowed    := p_action;
        --bug 3458160
        IF l_gc3_is_installed = 'N' THEN
           -- 5746444: enforce this condition when OTM is disabled.
           i := i + 1;
           x_detail_actions_tab(i).action_not_allowed := p_action;
           x_detail_actions_tab(i).source_code := 'WSH';
           x_detail_actions_tab(i).container_flag := 'N';
        ELSE
           -- 5746110: enforce this condition when OTM is installed.
           i := i + 1;
           x_detail_actions_tab(i).action_not_allowed := p_action;
           x_detail_actions_tab(i).otm_enabled := 'N';
        END IF;
  --}
  -- J-IB-NPARIKH-}
  -- { IB-Phase-2
  ELSIF p_action = 'ASSIGN-CONSOL-LPN'  THEN
       --
       -- Inbound Lines cannot be a part of a consolidated LPN.
       --
       i := i + 1;
       x_detail_actions_tab(i).line_direction := 'I';
       x_detail_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_detail_actions_tab(i).line_direction := 'D';
       x_detail_actions_tab(i).action_not_allowed := p_action;
  -- } IB-Phase-2
  END IF;


  IF l_debug_on THEN
	  WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.Init_Detail_Actions_Tbl', l_module_name);
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;

END Init_Detail_Actions_Tbl;


	-- ---------------------------------------------------------------------
	-- Procedure:	Validate_Shipped_CC_Quantity
	--
	-- Parameters:
	--
	-- Description:  This procedure validates shipped_quantity or cycle_count_quantity
	--			   This procedure consolidates the validations needed for these quantities
	--
	-- Created:   Harmonization Project. Patchset I
	-- -----------------------------------------------------------------------
	PROCEDURE Validate_Shipped_CC_Quantity(
		   p_flag			IN	   VARCHAR2, -- either 'SQ' or 'CCQ'
		   x_det_rec		 IN OUT NOCOPY  ValidateQuantityAttrRecType,
		   x_return_status   OUT NOCOPY   VARCHAR2,
		   x_msg_count	   OUT NOCOPY	 NUMBER,
		   x_msg_data		OUT NOCOPY	 VARCHAR2
		   ) IS

		l_quantity	   NUMBER;
		l_input_quantity NUMBER;

		l_api_name			  CONSTANT VARCHAR2(30)   := 'Validate_Shipped_CC_Quantity';
		l_api_version		   CONSTANT NUMBER		 := 1.0;
		--
	--
	l_return_status			 VARCHAR2(32767);
	l_msg_count				 NUMBER;
	l_msg_data				  VARCHAR2(32767);
	l_program_name			  VARCHAR2(32767);

	l_number_of_errors	NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;

        --added for bug # 3266333
        l_field_name VARCHAR2(50);


	   --
l_debug_on BOOLEAN;
	   --
	   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SHIPPED_CC_QUANTITY';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	 WSH_DEBUG_SV.push(l_module_name);
	 WSH_DEBUG_SV.log(l_module_name,'P_FLAG',P_FLAG);
	 WSH_DEBUG_SV.log(l_module_name, 'Del detail id', x_det_rec.delivery_detail_id);
	 WSH_DEBUG_SV.log(l_module_name, 'Shipped_Quantity', x_det_rec.shipped_quantity);
	 WSH_DEBUG_SV.log(l_module_name, 'Cycle_Count_Quantity', x_det_rec.cycle_count_quantity);
	 WSH_DEBUG_SV.log(l_module_name, 'Requested Quantity', x_det_rec.requested_quantity);
	 WSH_DEBUG_SV.log(l_module_name, 'Picked Quantity', x_det_rec.picked_quantity);
	 WSH_DEBUG_SV.log(l_module_name, 'Organization Id', x_det_rec.organization_id);
	 WSH_DEBUG_SV.log(l_module_name, 'Inventory Item Id', x_det_rec.inventory_item_id);
	 WSH_DEBUG_SV.log(l_module_name, 'Serial Qty', x_det_rec.serial_quantity);
	 WSH_DEBUG_SV.log(l_module_name, 'Transaction Temp Id', x_det_rec.transaction_temp_id);
	 WSH_DEBUG_SV.log(l_module_name, 'Top Model Line Id', x_det_rec.top_model_line_id);
	WSH_DEBUG_SV.log(l_module_name, 'Ship Tolerance Above', x_det_rec.ship_tolerance_above);
	WSH_DEBUG_SV.log(l_module_name, 'requested qty uom', x_det_rec.requested_quantity_uom);
	WSH_DEBUG_SV.log(l_module_name, 'unmark_serial_server ', x_det_rec.unmark_serial_server);
	WSH_DEBUG_SV.log(l_module_name, 'unmark_serial_form ', x_det_rec.unmark_serial_form);
  END IF;

	 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF(p_flag = 'SQ') THEN
	  l_input_quantity := x_det_rec.shipped_quantity;
          --added for Bug # 3266333
	  l_field_name := 'shipped_quantity';
	  --
  ELSIF(p_flag = 'CCQ') THEN
	  l_input_quantity := x_det_rec.cycle_count_quantity;
          --added for Bug # 3266333
	  l_field_name := 'cycle_count_quantity';
	  --
  ELSE
	 -- invalid flag
	 raise fnd_api.g_exc_error;
  END IF;

  --1.a) if entered, enable backordered quantity and update it as max(requested_quantity - shipped_quantity),0)
  --1.b) if null, clear cycle count and secondary quantity
  IF(x_det_rec.shipped_quantity IS NOT NULL) THEN
	x_det_rec.cycle_count_quantity := Greatest((x_det_rec.requested_quantity - x_det_rec.shipped_quantity),0);
  ELSE
	x_det_rec.cycle_count_quantity := NULL;
-- HW Harmonization project for OPM. no need to assign qty2 since it's being handleded in Validate_Shipped_CC_Quantity2
--	x_det_rec.cycle_count_quantity2 := NULL;

  END IF;

   -- 2) Check for negative

   IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --Bug # 3266333
   WSH_UTIL_VALIDATE.validate_negative(
         p_value          =>  l_input_quantity,
	 p_field_name     => l_field_name,
	 x_return_status  => l_return_status );
   --

	   IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		  RAISE FND_API.G_EXC_ERROR;
	   END IF;


   -- 3) check for decimal
-- HW Harmonization project for OPM. No need to call this procedure for OPM
-- Need to branch

-- HW OPMCONV - No need to branch

	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;

	  wsh_details_validations.check_decimal_quantity(
			  p_item_id		 => x_det_rec.inventory_item_id,
			  p_organization_id => x_det_rec.organization_id,
			  p_input_quantity  => l_input_quantity,
			  p_uom_code		=> x_det_rec.requested_quantity_uom,
			  x_output_quantity => l_quantity,
			  x_return_status   => l_return_status,
			  p_top_model_line_id => x_det_rec.top_model_line_id
	   );

	   IF(p_flag = 'SQ') THEN
		   x_det_rec.shipped_quantity := l_quantity;
	   ELSIF(p_flag = 'CCQ') THEN
		   x_det_rec.cycle_count_quantity := l_quantity;
	   END IF;

	  IF l_return_status <> wsh_util_core.g_ret_sts_success THEN
	   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  RAISE WSH_UTIL_CORE.G_EXC_WARNING;
	   ELSE
		  RAISE FND_API.G_EXC_ERROR;
	   END IF;
	  END IF;

-- HW OPM bug 2677054


-- HW -- HW Harmonization project for OPM. end of changes
  -- 4) If SQ, check shipped qty
  --	If CCQ, check cc qty
  IF (p_flag = 'SQ') THEN
		 IF l_debug_on THEN
			 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_SHIPPED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
		 END IF;
		 wsh_details_validations.check_shipped_quantity(
			  p_ship_above_tolerance	=> x_det_rec.ship_tolerance_above,
			  p_requested_quantity	  => x_det_rec.requested_quantity,
			  p_picked_quantity		 => x_det_rec.picked_quantity,
			  p_shipped_quantity		=> NVL(l_quantity, 0),
			  p_cycle_count_quantity	=> NVL(x_det_rec.cycle_count_quantity, 0),
			  x_return_status   => l_return_status);

	   IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		  RAISE FND_API.G_EXC_ERROR;
	   END IF;


  ELSIF(p_flag = 'CCQ') THEN

		 IF l_debug_on THEN
			 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CYCLE_COUNT_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
		 END IF;

		 wsh_details_validations.check_cycle_count_quantity(
			  p_ship_above_tolerance	=> x_det_rec.ship_tolerance_above,
			  p_requested_quantity	=> x_det_rec.requested_quantity,
			  p_picked_quantity			=> x_det_rec.picked_quantity,
			  p_shipped_quantity	=> NVL(x_det_rec.shipped_quantity, 0),
			  p_cycle_count_quantity	=> NVL(l_quantity, 0),
			  x_return_status			 => l_return_status);

	   IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		  RAISE FND_API.G_EXC_ERROR;
	   END IF;
  END IF;

  -- 5) clear and unmark serial numbers based on quantity checks
-- HW OPMCONV - No need to branch


	   IF NVL(x_det_rec.picked_quantity, x_det_rec.requested_quantity)=1 THEN
/*Bug 2174761 */
/*
		 IF ((x_det_rec.shipped_quantity >1 and x_det_rec.serial_number IS NOT NULL)
			 OR -- Bug 2941879 : check for >= 0 . Treat null as 0 .
			 (nvl(x_det_rec.shipped_quantity,0) >= 0 and x_det_rec.serial_quantity >
											x_det_rec.shipped_quantity )) THEN
*/
                 -- Bug 3628620
                 IF ( -- Bug 2941879 : check for >= 0 . Treat null as 0 .
                     (nvl(x_det_rec.shipped_quantity,0) >= 0 and x_det_rec.serial_quantity >
                          x_det_rec.shipped_quantity )) THEN
                 -- End of Bug 3628620
                        -- Bug 2828503 : added warning for unmarking of serial_numbers
                        x_det_rec.unmark_serial_form := 'Y';
			fnd_message.set_name('WSH', 'WSH_UI_UNMARK_SERIAL_NUM');
		        wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
                        l_number_of_warnings := l_number_of_warnings + 1;

		   IF x_det_rec.serial_quantity > 0 AND x_det_rec.unmark_serial_server = 'Y' THEN

			 IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
			 END IF;
			 wsh_delivery_details_inv.unmark_serial_number(
				  p_delivery_detail_id  => x_det_rec.delivery_detail_id,
				  p_serial_number_code  => x_det_rec.inv_ser_control_code,
				  p_serial_number	   => x_det_rec.serial_number,
				  p_transaction_temp_id => x_det_rec.transaction_temp_id,
				  x_return_status	   => l_return_status,
				  p_inventory_item_id   => x_det_rec.inventory_item_id
	);
		   IF l_debug_on THEN
			  wsh_debug_sv.log(l_module_name, 'Return status after Unmark serial', l_return_status);
		   END IF;

			IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		  END IF; -- if serial_quantity > 0

			 x_det_rec.serial_quantity	 := 0;
			 x_det_rec.serial_number	   := NULL;
			 x_det_rec.transaction_temp_id := NULL;
		 END IF;

	   ELSIF x_det_rec.serial_quantity > x_det_rec.shipped_quantity
		  OR nvl(x_det_rec.shipped_quantity,0) = 0
                  -- Bug 3628620 , Commented Code below
                  -- OR
		  --(x_det_rec.serial_quantity = 1 AND x_det_rec.shipped_quantity > 1)  OR
                  --(x_det_rec.serial_quantity = 1 AND x_det_rec.shipped_quantity = 1 AND
                  -- x_det_rec.transaction_temp_id is not null)
                  -- End of Bug 3628620
                  THEN

		  IF x_det_rec.serial_quantity > 0 THEN
                        -- Bug 2828503 : added warning for unmarking of serial_numbers
                        x_det_rec.unmark_serial_form := 'Y';
                        fnd_message.set_name('WSH', 'WSH_UI_UNMARK_SERIAL_NUM');
                        wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
                        l_number_of_warnings := l_number_of_warnings + 1;

		  IF l_debug_on THEN
			  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
		  END IF;

                  IF x_det_rec.unmark_serial_server = 'Y' THEN
  		     wsh_delivery_details_inv.unmark_serial_number(
		   		 p_delivery_detail_id  => x_det_rec.delivery_detail_id,
		   		 p_serial_number_code  => x_det_rec.inv_ser_control_code,
		   		 p_serial_number	   => x_det_rec.serial_number,
				 p_transaction_temp_id => x_det_rec.transaction_temp_id,
				 x_return_status	   => l_return_status,
				 p_inventory_item_id   => x_det_rec.inventory_item_id);

		      IF l_debug_on THEN
	   		  wsh_debug_sv.log(l_module_name, 'Return status after Unmark serial', l_return_status);
	   	      END IF;

			 IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
				RAISE FND_API.G_EXC_ERROR;
			 END IF;
			END IF; -- if serial_quantity > 0

			 x_det_rec.serial_quantity	 := 0;
			 x_det_rec.serial_number	   := NULL;
			 x_det_rec.transaction_temp_id := NULL;

		  END IF;

	   END IF;



  IF(p_flag = 'SQ') THEN
	  x_det_rec.shipped_quantity := l_quantity;

  ELSIF(p_flag = 'CCQ') THEN
	  x_det_rec.cycle_count_quantity := l_quantity;
  END IF;

	 IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Output shipped quantity', x_det_rec.shipped_quantity);
		WSH_DEBUG_SV.log(l_module_name, 'Output Cycle_Count quantity', x_det_rec.cycle_count_quantity);
	 END IF;

  IF l_number_of_warnings > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

	  IF l_debug_on THEN
	   	 WSH_DEBUG_SV.log(l_module_name, 'Return status from api ', x_return_status);
		 WSH_DEBUG_SV.pop(l_module_name);
	  END IF;

EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
				x_return_status := FND_API.G_RET_STS_ERROR ;
				wsh_util_core.add_message(x_return_status, l_module_name);
				FND_MSG_PUB.Count_And_Get
				  (
					 p_count  => x_msg_count,
					 p_data  =>  x_msg_data,
				 p_encoded => FND_API.G_FALSE
				  );

				  IF l_debug_on THEN
					  WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
					  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
				  END IF;
				  --
		WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
			 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			 wsh_util_core.add_message(x_return_status, l_module_name);
			 FND_MSG_PUB.Count_And_Get
			  (
				p_count  => x_msg_count,
				p_data  =>  x_msg_data,
				p_encoded => FND_API.G_FALSE
			  );
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
	   END IF;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				FND_MSG_PUB.Count_And_Get
				  (
					 p_count  => x_msg_count,
					 p_data  =>  x_msg_data,
				 p_encoded => FND_API.G_FALSE
				  );

				  IF l_debug_on THEN
					  WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
					  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
				  END IF;
				  --
		WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY');
		--
				 IF l_debug_on THEN
					 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
					 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
				 END IF;


END Validate_Shipped_CC_Quantity;
--Harmonization Project I


------------------------------------------------------------------------
	-- Procedure:	Validate_Shipped_CC_Quantity2
	--
	-- Parameters:
	--
	-- Description:  This procedure validates shipped_quantity2 or cycle_count_quantity2
	--			   This procedure consolidates the validations needed for these quantities
	--
	-- Created:   Harmonization Project. Patchset I
	--			HW Harmonization project for OPM
	-- -----------------------------------------------------------------------
	PROCEDURE Validate_Shipped_CC_Quantity2(
		   p_flag			IN	   VARCHAR2, -- either 'SQ' or 'CCQ'
		   x_det_rec		 IN OUT NOCOPY  ValidateQuantityAttrRecType,
		   x_return_status   OUT   NOCOPY   VARCHAR2,
		   x_msg_count	   OUT   NOCOPY   NUMBER,
		   x_msg_data		OUT   NOCOPY   VARCHAR2
		   ) IS

		l_quantity	   NUMBER;
		l_input_quantity NUMBER;

		l_api_name			  CONSTANT VARCHAR2(30)   := 'Validate_Shipped_CC_Quantity2';
		l_api_version		   CONSTANT NUMBER		 := 1.0;
		--
	--
	l_return_status			 VARCHAR2(32767);
	l_msg_count				 NUMBER;
	l_msg_data				  VARCHAR2(32767);
	l_program_name			  VARCHAR2(32767);

	l_number_of_errors	NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;

        --added for Bug # 3266333
	l_field_name   VARCHAR2(50);

	   --
l_debug_on BOOLEAN;
	   --
	   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SHIPPED_CC_QUANTITY2';
BEGIN


  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
	  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
	 WSH_DEBUG_SV.push(l_module_name);
	 WSH_DEBUG_SV.log(l_module_name,'P_FLAG',P_FLAG);
	 WSH_DEBUG_SV.log(l_module_name, 'Shipped_Quantity2', x_det_rec.shipped_quantity2);
	 WSH_DEBUG_SV.log(l_module_name, 'Cycle_Count_Quantity2', x_det_rec.cycle_count_quantity2);
	 WSH_DEBUG_SV.log(l_module_name, 'Requested Quantity2', x_det_rec.requested_quantity2);
	 WSH_DEBUG_SV.log(l_module_name, 'Picked Quantity2', x_det_rec.picked_quantity2);
	 WSH_DEBUG_SV.log(l_module_name, 'Organization Id', x_det_rec.organization_id);
	 WSH_DEBUG_SV.log(l_module_name, 'Inventory Item Id', x_det_rec.inventory_item_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF(p_flag = 'SQ') THEN
	  l_input_quantity := x_det_rec.shipped_quantity2;
          --added for Bug # 3266333
	  l_field_name     := 'shipped_quantity2';
	  --
  ELSIF(p_flag = 'CCQ') THEN
	  l_input_quantity := x_det_rec.cycle_count_quantity2;
          --added for Bug # 3266333
	  l_field_name     := 'cycle_count_quantity2';
	  --
  ELSE
	 -- invalid flag
	 raise fnd_api.g_exc_error;
  END IF;

  --1.a) if entered, enable backordered quantity and update it as max(requested_quantity2 - shipped_quantity2),0)
  --1.b) if null, clear cycle count and secondary quantity
  IF(x_det_rec.shipped_quantity2 IS NOT NULL) THEN
     --x_det_rec.cycle_count_quantity2 := Greatest((x_det_rec.requested_quantity2 - x_det_rec.shipped_quantity2),0);
     -- bug 5391211, cycle_count_qty2 should be a value that is derived from qty1
     x_det_rec.cycle_count_quantity2 := WSH_WV_UTILS.convert_uom
                    (
                        from_uom     => x_det_rec.requested_quantity_uom,
                        to_uom       => x_det_rec.requested_quantity_uom2,
                        quantity     => x_det_rec.cycle_count_quantity,
                        item_id      => x_det_rec.inventory_item_id
                    );

  -- PK Bug 3055126 added else clause
  ELSE
        x_det_rec.cycle_count_quantity2 := NULL;

  END IF;

  IF l_debug_on THEN
	 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_NEGATIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
   -- 2) Check for negative
  --Bug # 3266333
  WSH_UTIL_VALIDATE.validate_negative(
         p_value          =>  l_input_quantity,
	 p_field_name     =>  l_field_name,
	 x_return_status  => l_return_status );
  --

   IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		RAISE FND_API.G_EXC_ERROR;
   END IF;

-- HW OPM BUG#:2677054
   IF(p_flag = 'SQ') THEN
	  l_quantity := x_det_rec.shipped_quantity2;

   ELSIF(p_flag = 'CCQ') THEN
	  l_quantity :=x_det_rec.cycle_count_quantity2;
   END IF;

  -- 4) If SQ, check shipped qty
  --	If CCQ, check cc qty
  --Bug 6668217. Uday Phadtare. Commented call wsh_details_validations.check_shipped_quantity
  --and wsh_details_validations.check_cycle_count_quantity for quantity2 because for quantity2
  --validation is not to be done.
  /*
  IF (p_flag = 'SQ') THEN

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_SHIPPED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		 wsh_details_validations.check_shipped_quantity(
			  p_ship_above_tolerance	=> x_det_rec.ship_tolerance_above,
			  p_requested_quantity	  => x_det_rec.requested_quantity2,
			  p_picked_quantity		 => x_det_rec.picked_quantity2,
			  p_shipped_quantity		=> NVL(l_quantity, 0),
			  p_cycle_count_quantity	=> NVL(x_det_rec.cycle_count_quantity2, 0),
			  x_return_status   => l_return_status);

			 IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			  RAISE FND_API.G_EXC_ERROR;
			END IF;
  ELSIF(p_flag = 'CCQ') THEN

	 IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CYCLE_COUNT_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
		 wsh_details_validations.check_cycle_count_quantity(
			  p_ship_above_tolerance	=> x_det_rec.ship_tolerance_above,
			  p_requested_quantity	=> x_det_rec.requested_quantity2,
			  p_picked_quantity			=> x_det_rec.picked_quantity2,
			  p_shipped_quantity	=> NVL(x_det_rec.shipped_quantity2, 0),
			  p_cycle_count_quantity	=> NVL(l_quantity, 0),
			  x_return_status			 => l_return_status);

			  IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
				RAISE FND_API.G_EXC_ERROR;
			  END IF;
  END IF;
  */

  IF(p_flag = 'SQ') THEN
	  x_det_rec.shipped_quantity2 := l_quantity;
  ELSIF(p_flag = 'CCQ') THEN
	  x_det_rec.cycle_count_quantity2 := l_quantity;
  END IF;

   IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Output shipped quantity2', x_det_rec.shipped_quantity2);
		WSH_DEBUG_SV.log(l_module_name, 'Output Cycle_Count quantity2', x_det_rec.cycle_count_quantity2);
	 END IF;

	  IF l_debug_on THEN
		 WSH_DEBUG_SV.pop(l_module_name);
	  END IF;

EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
				x_return_status := FND_API.G_RET_STS_ERROR ;
				FND_MSG_PUB.Count_And_Get
				  (
					 p_count  => x_msg_count,
					 p_data  =>  x_msg_data,
				 p_encoded => FND_API.G_FALSE
				  );

				  IF l_debug_on THEN
					  WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
					  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
				  END IF;
				  --
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				FND_MSG_PUB.Count_And_Get
				  (
					 p_count  => x_msg_count,
					 p_data  =>  x_msg_data,
				 p_encoded => FND_API.G_FALSE
				  );

				  IF l_debug_on THEN
					  WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
					  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
				  END IF;
				  --
		WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.VALIDATE_SHIPPED_CC_QUANTITY2');
		--
				 IF l_debug_on THEN
					 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
					 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
				 END IF;


END Validate_Shipped_CC_Quantity2;

-- for Load Tender Project
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Compare_Detail_Attributes
   PARAMETERS : p_old_table - Table of old records
				p_new_table - Table of new records
				p_entity - entity name -DELIVERY_DETAIL
				p_action_code - action code for each action
				p_phase - 1 for Before the action is performed, 2 for after.
				p_caller - where is this API being called from
				x_changed_id - Table of Changed ids
				x_return_status - Return Status
  DESCRIPTION : This procedure compares the attributes for each entity.
				For Delivery Detail,attributes are - weight/volume,quantity,
				delivery,parent_delivery_detail
				Added for Load Tender Project but this is independent of
				FTE is installed or not.
------------------------------------------------------------------------------
*/
PROCEDURE compare_detail_attributes
  (p_old_table	 IN wsh_interface.deliverydetailtab,
   p_new_table	 IN wsh_interface.deliverydetailtab,
   p_action_code   IN VARCHAR2,
   p_phase		 IN NUMBER,
   p_caller		IN VARCHAR2,
   x_changed_id_tab OUT NOCOPY wsh_util_core.id_tab_type,
   x_return_status OUT NOCOPY VARCHAR2
   ) IS

  l_return_status VARCHAR2(30);
  i NUMBER;
  l_id_tab WSH_UTIL_CORE.ID_TAB_TYPE;
--
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMPARE_DETAIL_ATTRIBUTES';
--

BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
	l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --

  IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_Old_table.count',P_OLD_TABLE.COUNT);
	WSH_DEBUG_SV.log(l_module_name,'P_new_table.count',P_NEW_TABLE.COUNT);
	WSH_DEBUG_SV.log(l_module_name,'P_action_code',P_ACTION_CODE);
	WSH_DEBUG_SV.log(l_module_name,'P_phase',P_PHASE);
	WSH_DEBUG_SV.log(l_module_name,'P_caller',P_CALLER);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_id_tab.DELETE;

  IF p_old_table.count = p_new_table.count THEN
	FOR i in 1..p_old_table.count
	LOOP
	  IF (
		 (p_old_table(i).requested_quantity <>
			p_new_table(i).requested_quantity)
		OR
		 (nvl(p_old_table(i).shipped_quantity,-99) <>
		   nvl(p_new_table(i).shipped_quantity,-99))
		OR
		 (nvl(p_old_table(i).picked_quantity,-99) <>
			nvl(p_new_table(i).picked_quantity,-99))
		OR
		 (nvl(p_old_table(i).gross_weight,-99) <>
			nvl(p_new_table(i).gross_weight,-99))
		OR
		 (nvl(p_old_table(i).net_weight,-99) <>
			nvl(p_new_table(i).net_weight,-99))
		OR
		 (nvl(p_old_table(i).weight_uom_code,'XXX') <>
			nvl(p_new_table(i).weight_uom_code,'XXX'))
		OR
		 (nvl(p_old_table(i).volume,-99) <>
			nvl(p_new_table(i).volume,-99))
		OR
		 (nvl(p_old_table(i).volume_uom_code,'XXX') <>
			nvl(p_new_table(i).volume_uom_code,'XXX'))
		OR
		 (nvl(p_old_table(i).delivery_id,-99) <>
			nvl(p_new_table(i).delivery_id,-99))
		OR
		 (nvl(p_old_table(i).parent_delivery_detail_id,-99) <>
			nvl(p_new_table(i).parent_delivery_detail_id,-99))
		) THEN

		l_id_tab(l_id_tab.count + 1) := p_old_table(i).delivery_detail_id;

	  END IF;

	END LOOP;

	x_changed_id_tab := l_id_tab;
  END IF;

  IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN others THEN
	wsh_util_core.default_handler('WSH_TRIP_UTILITIES.compare_detail_attributes');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;

END compare_detail_attributes;

-- End for Load Tender Project


-- ----------------------------------------------------------------------
-- Procedure:   validate_secondary_quantity
-- Parameters:
--              p_delivery_detail_id  Delivery Detail Id of line to be split
--              x_quantity            Primary Quantity to be split
--              x_quantity2           Secondary Quantity to be split
--
-- Description: Validates secondary quantity for OPM org. for tolerance.
--              Following validations are performed :
--              1. Primary quantity to be split is mandatory and should be positive
--              2. If OPM item then secondary quantity to be split is
--                  mandatory and should be positive
--
--              3. If item is under lot control, then validate lot number
--              4. Check that secondary quantity is within tolerance for
--                 items with dual UOM indicator 2 or 3
--              5. get secondary quantity from primary quantity by applying UOM                    conversion
--                 - for items with dual UOM indicator 1 (Always)
--
--  ----------------------------------------------------------------------
-- HW OPMCONV - Added p_caller parameter
PROCEDURE validate_secondary_quantity
            (
               p_delivery_detail_id  IN              NUMBER,
               x_quantity            IN OUT NOCOPY   NUMBER,
               x_quantity2           IN OUT NOCOPY   NUMBER,
               p_caller              IN              VARCHAR2 ,
               x_return_status       OUT    NOCOPY   VARCHAR2,
               x_msg_count           OUT    NOCOPY   NUMBER,
               x_msg_data            OUT    NOCOPY   VARCHAR2
            )
IS
--{

-- HW OPMCONV - No need for OPM variables

    l_return              NUMBER;
    l_outside_tolerance   BOOLEAN := TRUE;
    l_qty2                NUMBER;

-- HW OPMCONV - New variable
out_of_deviation EXCEPTION;
    --
    -- Fetch delivery line information
    --
    CURSOR line_csr (p_delivery_detail_id IN NUMBER)
    IS
        SELECT organization_id, inventory_item_id,
               lot_number, nvl(line_direction,'O') line_direction,
               requested_quantity_uom,
               requested_quantity_uom2
        FROM   wsh_delivery_details
        WHERE  delivery_detail_id = p_delivery_detail_id;
    --
    --
    l_line_rec            line_csr%ROWTYPE;
    --
    --
    -- Validate lot number for the item
    --
-- HW OPMCONV - Validate lot against Inventory table instead of OPM's
    CURSOR lot_csr (p_item_id IN NUMBER, p_organization_id IN NUMBER,
                    p_lot_number IN VARCHAR2)
    IS
        SELECT lot_number
        FROM   MTL_LOT_NUMBERS
        WHERE  inventory_item_id = p_item_id
        AND    organization_id = p_organization_id
        AND    lot_number  = p_lot_number ;
    --
    --
-- HW OPMCONV - Changed type to char from number
    l_lot_num             VARCHAR2(80);

    --
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'VALIDATE_SECONDARY_QUANTITY';
    --
    l_number_of_errors            NUMBER := 0;
    l_number_of_warnings          NUMBER := 0;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_return_status               VARCHAR2(32767);
    --
-- HW OPMCONV - New variables
    l_item_info                   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
    INVALID_LOT                   EXCEPTION;
    e_end_of_api                  EXCEPTION;
--}
BEGIN
--{
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'p_caller', p_caller);
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_DETAIL_ID', p_delivery_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'X_QUANTITY', x_quantity);
      wsh_debug_sv.LOG(l_module_name, 'X_QUANTITY2', x_quantity2);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    -- Check that primary quantity to be split is mandatory and should be
    -- positive
    --
    IF x_quantity IS NULL
    THEN
    --{
        fnd_message.set_name('WSH', 'WSH_REQUIRED_FIELD_NULL');
        fnd_message.set_token('FIELD_NAME','x_quantity');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
/* HW BUG 4548713- Removed checking for Qty being 0
    ELSIF x_quantity = 0
    THEN
    --{
    	--
        fnd_message.set_name('WSH', 'WSH_NO_ZERO_NUM');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
*/
    ELSIF x_quantity < 0
    THEN
    --{
        fnd_message.set_name('WSH', 'WSH_NO_NEG_NUM');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    -- Fetch Delivery Line information
    --
    OPEN  line_csr (p_delivery_detail_id);
    FETCH line_csr INTO l_line_rec;
    --
    IF line_csr%NOTFOUND
    THEN
    --{
        fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
        fnd_message.set_token('DETAIL_ID',p_delivery_detail_id);
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    CLOSE line_csr;
    --
    --
    IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'l_line_rec.organization_id', l_line_rec.organization_id);
        wsh_debug_sv.LOG(l_module_name, 'l_line_rec.inventory_item_id', l_line_rec.inventory_item_id);
        wsh_debug_sv.LOG(l_module_name, 'l_line_rec.lot_number', l_line_rec.lot_number);
        wsh_debug_sv.LOG(l_module_name, 'l_line_rec.requested_quantity_uom', l_line_rec.requested_quantity_uom);
        wsh_debug_sv.LOG(l_module_name, 'l_line_rec.requested_quantity_uom2', l_line_rec.requested_quantity_uom2);

    END IF;
    --
    --
    --
    IF l_line_rec.inventory_item_id IS NULL
    THEN
        RAISE e_end_of_api;
    END IF;
    --
    --
--  HW OPMCONV - No need to call OPM APIS

-- HW OPMCONV - Call API to get item info
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.Get_item_information',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_DELIVERY_DETAILS_INV.Get_item_information
            (
               p_organization_id       => l_line_rec.organization_id
              , p_inventory_item_id    => l_line_rec.inventory_item_id
              , x_mtl_system_items_rec => l_item_info
              , x_return_status        => l_return_status
            );

     --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_number_of_warnings,
        x_num_errors    => l_number_of_errors
      );
    --
    --
-- HW OPMCONV -Print debugging statements
    IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
        wsh_debug_sv.LOG(l_module_name, 'l_item_info.tracking_quantity_ind', l_item_info.tracking_quantity_ind);
    END IF;
    --
    --
-- HW OPMCONV - Changed condition to check for secondary_default_ind
    IF x_quantity2 IS NULL
    AND l_item_info.secondary_default_ind in ('F','D','N')
    THEN
    --{
        fnd_message.set_name('WSH', 'WSH_OPM_SEC_QTY_REQD_ERROR');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
-- HW OPMCONV - Changed condition to check for secondary_default_ind
-- HW BUG 4548713 - Added check for x_quantity
    ELSIF x_quantity2 = 0
    AND l_item_info.secondary_default_ind in ('F','D','N')
    AND x_quantity > 0
    THEN
    --{
    	--


        fnd_message.set_name('WSH', 'WSH_NO_ZERO_NUM');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
-- HW OPMCONV - Changed condition to check for secondary_default_ind
    ELSIF x_quantity2 < 0
    AND l_item_info.secondary_default_ind in ('F','D','N')
    THEN
    --{
        fnd_message.set_name('WSH', 'WSH_NO_NEG_NUM');
        wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    -- If item is under lot control, validate lot number.
    --
-- HW OPMCONV - Changed condition to check for lot_control_code
-- and lot_number
    IF  l_item_info.lot_control_code > 0
    AND l_line_rec.lot_number     IS NOT NULL
    THEN
    --{
        OPEN  lot_csr (l_line_rec.inventory_item_id,
                       l_line_rec.organization_id,l_line_rec.lot_number);
        FETCH lot_csr INTO l_lot_num;
        --
        IF lot_csr%NOTFOUND
        THEN
        --{
            --fnd_message.set_name('GMI', 'IC_INVALID_LOT');
            --wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
            RAISE INVALID_LOT;
        --}
        END IF;
        --
        --
        CLOSE lot_csr;
    --}
    ELSE
-- HW OPMCONV make lot_number NULL
        l_lot_num := NULL;
    END IF;
    --
    --
    -- Check if secondary quantity is within tolerance for
    -- items with dual UOM indicator 2 or 3
    --
-- HW OPMCONV - Check for two types only (Default and No Default)
    IF ( l_item_info.secondary_default_ind in ('D','N') ) OR
       ( p_caller = 'WSH_PUB' AND l_item_info.secondary_default_ind in ('F','D','N'))
    THEN
    --{
        --
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Calling program unit
	    WSH_WV_UTILS.within_deviation', wsh_debug_sv.c_proc_level);
        END IF;
        --
-- HW OPMCONV - Call new API to check deviation
        l_return := WSH_WV_UTILS.within_deviation
                        (
                          p_organization_id      => l_line_rec.organization_id,
                          p_inventory_item_id    => l_line_rec.inventory_item_id,
                          p_lot_number           => l_lot_num,
                          p_precision            => WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV,
                          p_quantity             => x_quantity,
                          p_uom1                 => l_line_rec.requested_quantity_uom,
                          p_quantity2            => x_quantity2,
                          p_uom2                 =>l_line_rec.requested_quantity_uom2
                        );
        --
         IF ( l_return = 1 ) THEN
           l_outside_tolerance := FALSE;
         ELSE -- this includes invalids UOMs)
           RAISE out_of_deviation;
         END IF;
    END IF;
    --}

    --
    --
    -- get secondary quantity from primary quantity by applying UOM conversion
    -- for items with dual UOM indicator 1 (Always)
    --
    --
-- HW OPMCONV - Changed condition to check for secondary_default_ind
    IF  l_outside_tolerance  AND l_item_info.secondary_default_ind in ('F','D')
        AND ( p_caller <> 'WSH_PUB' )
    THEN
    --{
        --
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_WV_UTILS.convert_uom', wsh_debug_sv.c_proc_level);
        END IF;
        --
-- HW OPMCONV - Call UOM routine passing lot_num
        l_qty2 := WSH_WV_UTILS.convert_uom
                    (
                        item_id      => l_line_rec.inventory_item_id,
                        org_id       => l_line_rec.organization_id,
                        from_uom     => l_line_rec.requested_quantity_uom,
                        to_uom       => l_line_rec.requested_quantity_uom2,
                        quantity     => x_quantity,
                        lot_number   => l_lot_num
                    );
        --
        IF ( l_qty2 <= 0 ) THEN
            FND_MESSAGE.SET_NAME('wsh','WSH_UPDATE_CANNOT_SPLIT');
            wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        IF l_qty2 <> x_quantity2
        THEN
        --{
            FND_MESSAGE.SET_NAME('WSH','WSH_OPM_QTY_ERROR');
            FND_MESSAGE.SET_TOKEN('QUANTITY2',x_quantity2);
            FND_MESSAGE.SET_TOKEN('CONV_QUANTITY2',l_qty2);
            --wsh_util_core.add_message(FND_API.G_RET_STS_ERROR, l_module_name);
            --RAISE FND_API.G_EXC_ERROR;
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING, l_module_name);
            l_number_of_warnings := NVL(l_number_of_warnings,0) + 1;
        --}
        END IF;
        --
        x_quantity2 := l_qty2;
    --}
    END IF;
    --
    IF l_number_of_warnings > 0 THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Number of warnings', l_number_of_warnings);
      END IF;

      RAISE wsh_util_core.g_exc_warning;
    END IF;
    --
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data => x_msg_data,
      p_encoded      => fnd_api.g_false);

    IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'X_QUANTITY2', x_quantity2);
      wsh_debug_sv.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
   WHEN e_end_of_api THEN
        x_return_status := fnd_api.g_ret_sts_success;
       fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
      END IF;
   --

   WHEN INVALID_LOT THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Lot Number');
      END IF;

   WHEN OUT_OF_DEVIATION   THEN
     x_return_status := fnd_api.g_ret_sts_error;
     IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_DETAILS_VALIDATIONS.validate_secondary_quantity',l_module_name);
      --
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded      => fnd_api.g_false);
      --
      IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
--
END validate_secondary_quantity;

--public api change
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN wsh_glbl_var_strct_grp.delivery_details_rec_type,
      p_out_rec         IN wsh_glbl_var_strct_grp.delivery_details_rec_type,
      p_in_rec          IN wsh_glbl_var_strct_grp.detailInRecType,
      x_return_status   OUT NOCOPY    VARCHAR2)

IS
l_attributes VARCHAR2(2500) ;
k         number;
l_return_status VARCHAR2(1);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'user_non_updatable_columns';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.caller',p_in_rec.caller);
    --
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF     p_user_in_rec.DELIVERY_DETAIL_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVERY_DETAIL_ID,-99) <> NVL(p_out_rec.DELIVERY_DETAIL_ID,-99)
  THEN
       l_attributes := l_attributes || 'DELIVERY_DETAIL_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SOURCE_CODE,'!!!') <> NVL(p_out_rec.SOURCE_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SOURCE_CODE, ';
  END IF;

  IF     p_user_in_rec.SOURCE_HEADER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_HEADER_ID,-99) <> NVL(p_out_rec.SOURCE_HEADER_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_HEADER_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_LINE_ID,-99) <> NVL(p_out_rec.SOURCE_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_LINE_ID, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CUSTOMER_ID,-99) <> NVL(p_out_rec.CUSTOMER_ID,-99)
  THEN
       l_attributes := l_attributes || 'CUSTOMER_ID, ';
  END IF;

  IF     p_user_in_rec.SOLD_TO_CONTACT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOLD_TO_CONTACT_ID,-99) <> NVL(p_out_rec.SOLD_TO_CONTACT_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOLD_TO_CONTACT_ID, ';
  END IF;

  IF     p_user_in_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.INVENTORY_ITEM_ID,-99) <> NVL(p_out_rec.INVENTORY_ITEM_ID,-99)
  THEN
       l_attributes := l_attributes || 'INVENTORY_ITEM_ID, ';
  END IF;

  IF     p_user_in_rec.ITEM_DESCRIPTION <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ITEM_DESCRIPTION,'!!!') <> NVL(p_out_rec.ITEM_DESCRIPTION,'!!!')
  THEN
       l_attributes := l_attributes || 'ITEM_DESCRIPTION, ';
  END IF;

  IF     p_user_in_rec.HAZARD_CLASS_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.HAZARD_CLASS_ID,-99) <> NVL(p_out_rec.HAZARD_CLASS_ID,-99)
  THEN
       l_attributes := l_attributes || 'HAZARD_CLASS_ID, ';
  END IF;

  IF     p_user_in_rec.COUNTRY_OF_ORIGIN <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.COUNTRY_OF_ORIGIN,'!!!') <> NVL(p_out_rec.COUNTRY_OF_ORIGIN,'!!!')
  THEN
       l_attributes := l_attributes || 'COUNTRY_OF_ORIGIN, ';
  END IF;

  IF     p_user_in_rec.CLASSIFICATION <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CLASSIFICATION,'!!!') <> NVL(p_out_rec.CLASSIFICATION,'!!!')
  THEN
       l_attributes := l_attributes || 'CLASSIFICATION, ';
  END IF;

  IF     p_user_in_rec.SHIP_FROM_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_FROM_LOCATION_ID,-99) <> NVL(p_out_rec.SHIP_FROM_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_FROM_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_TO_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_TO_LOCATION_ID,-99) <> NVL(p_out_rec.SHIP_TO_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_TO_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_TO_CONTACT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_TO_CONTACT_ID,-99) <> NVL(p_out_rec.SHIP_TO_CONTACT_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_TO_CONTACT_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_TO_SITE_USE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_TO_SITE_USE_ID,-99) <> NVL(p_out_rec.SHIP_TO_SITE_USE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_TO_SITE_USE_ID, ';
  END IF;

  IF     p_user_in_rec.DELIVER_TO_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVER_TO_LOCATION_ID,-99) <> NVL(p_out_rec.DELIVER_TO_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'DELIVER_TO_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.DELIVER_TO_CONTACT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVER_TO_CONTACT_ID,-99) <> NVL(p_out_rec.DELIVER_TO_CONTACT_ID,-99)
  THEN
       l_attributes := l_attributes || 'DELIVER_TO_CONTACT_ID, ';
  END IF;

  IF     p_user_in_rec.DELIVER_TO_SITE_USE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVER_TO_SITE_USE_ID,-99) <> NVL(p_out_rec.DELIVER_TO_SITE_USE_ID,-99)
  THEN
       l_attributes := l_attributes || 'DELIVER_TO_SITE_USE_ID, ';
  END IF;

  IF     p_user_in_rec.INTMED_SHIP_TO_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.INTMED_SHIP_TO_LOCATION_ID,-99) <> NVL(p_out_rec.INTMED_SHIP_TO_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'INTMED_SHIP_TO_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.INTMED_SHIP_TO_CONTACT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.INTMED_SHIP_TO_CONTACT_ID,-99) <> NVL(p_out_rec.INTMED_SHIP_TO_CONTACT_ID,-99)
  THEN
       l_attributes := l_attributes || 'INTMED_SHIP_TO_CONTACT_ID, ';
  END IF;

  IF     p_user_in_rec.HOLD_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.HOLD_CODE,'!!!') <> NVL(p_out_rec.HOLD_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'HOLD_CODE, ';
  END IF;

  IF     p_user_in_rec.SHIP_TOLERANCE_ABOVE <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_TOLERANCE_ABOVE,-99) <> NVL(p_out_rec.SHIP_TOLERANCE_ABOVE,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_TOLERANCE_ABOVE, ';
  END IF;

  IF     p_user_in_rec.SHIP_TOLERANCE_BELOW <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_TOLERANCE_BELOW,-99) <> NVL(p_out_rec.SHIP_TOLERANCE_BELOW,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_TOLERANCE_BELOW, ';
  END IF;

  IF     p_user_in_rec.REQUESTED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.REQUESTED_QUANTITY,-99) <> NVL(p_out_rec.REQUESTED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'REQUESTED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.SHIPPED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIPPED_QUANTITY,-99) <> NVL(p_out_rec.SHIPPED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'SHIPPED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.DELIVERED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVERED_QUANTITY,-99) <> NVL(p_out_rec.DELIVERED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'DELIVERED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.REQUESTED_QUANTITY_UOM <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.REQUESTED_QUANTITY_UOM,'!!!') <> NVL(p_out_rec.REQUESTED_QUANTITY_UOM,'!!!')
  THEN
       l_attributes := l_attributes || 'REQUESTED_QUANTITY_UOM, ';
  END IF;

  IF     p_user_in_rec.SUBINVENTORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SUBINVENTORY,'!!!') <> NVL(p_out_rec.SUBINVENTORY,'!!!')
  THEN
       l_attributes := l_attributes || 'SUBINVENTORY, ';
  END IF;

  IF     p_user_in_rec.REVISION <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.REVISION,'!!!') <> NVL(p_out_rec.REVISION,'!!!')
  THEN
       l_attributes := l_attributes || 'REVISION, ';
  END IF;

  IF     p_user_in_rec.LOT_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.LOT_NUMBER,'!!!') <> NVL(p_out_rec.LOT_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'LOT_NUMBER, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_REQUESTED_LOT_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_REQUESTED_LOT_FLAG,'!!!') <> NVL(p_out_rec.CUSTOMER_REQUESTED_LOT_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_REQUESTED_LOT_FLAG, ';
  END IF;

  IF     p_user_in_rec.SERIAL_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SERIAL_NUMBER,'!!!') <> NVL(p_out_rec.SERIAL_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'SERIAL_NUMBER, ';
  END IF;

  IF     p_user_in_rec.LOCATOR_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LOCATOR_ID,-99) <> NVL(p_out_rec.LOCATOR_ID,-99)
  THEN
       l_attributes := l_attributes || 'LOCATOR_ID, ';
  END IF;

  IF     p_user_in_rec.DATE_REQUESTED <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.DATE_REQUESTED,TO_DATE('2','j')) <> NVL(p_out_rec.DATE_REQUESTED,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'DATE_REQUESTED, ';
  END IF;

  IF     p_user_in_rec.DATE_SCHEDULED <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.DATE_SCHEDULED,TO_DATE('2','j')) <> NVL(p_out_rec.DATE_SCHEDULED,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'DATE_SCHEDULED, ';
  END IF;

  IF     p_user_in_rec.MASTER_CONTAINER_ITEM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MASTER_CONTAINER_ITEM_ID,-99) <> NVL(p_out_rec.MASTER_CONTAINER_ITEM_ID,-99)
  THEN
       l_attributes := l_attributes || 'MASTER_CONTAINER_ITEM_ID, ';
  END IF;

  IF     p_user_in_rec.DETAIL_CONTAINER_ITEM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DETAIL_CONTAINER_ITEM_ID,-99) <> NVL(p_out_rec.DETAIL_CONTAINER_ITEM_ID,-99)
  THEN
       l_attributes := l_attributes || 'DETAIL_CONTAINER_ITEM_ID, ';
  END IF;

  IF     p_user_in_rec.LOAD_SEQ_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LOAD_SEQ_NUMBER,-99) <> NVL(p_out_rec.LOAD_SEQ_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'LOAD_SEQ_NUMBER, ';
  END IF;

  IF     p_user_in_rec.SHIP_METHOD_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIP_METHOD_CODE,'!!!') <> NVL(p_out_rec.SHIP_METHOD_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIP_METHOD_CODE, ';
  END IF;

  IF     p_user_in_rec.CARRIER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CARRIER_ID,-99) <> NVL(p_out_rec.CARRIER_ID,-99)
  THEN
       l_attributes := l_attributes || 'CARRIER_ID, ';
  END IF;

  IF     p_user_in_rec.FREIGHT_TERMS_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FREIGHT_TERMS_CODE,'!!!') <> NVL(p_out_rec.FREIGHT_TERMS_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'FREIGHT_TERMS_CODE, ';
  END IF;

  IF     p_user_in_rec.SHIPMENT_PRIORITY_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPMENT_PRIORITY_CODE,'!!!') <> NVL(p_out_rec.SHIPMENT_PRIORITY_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPMENT_PRIORITY_CODE, ';
  END IF;

  IF     p_user_in_rec.FOB_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FOB_CODE,'!!!') <> NVL(p_out_rec.FOB_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'FOB_CODE, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_ITEM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CUSTOMER_ITEM_ID,-99) <> NVL(p_out_rec.CUSTOMER_ITEM_ID,-99)
  THEN
       l_attributes := l_attributes || 'CUSTOMER_ITEM_ID, ';
  END IF;

  IF     p_user_in_rec.DEP_PLAN_REQUIRED_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.DEP_PLAN_REQUIRED_FLAG,'!!!') <> NVL(p_out_rec.DEP_PLAN_REQUIRED_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'DEP_PLAN_REQUIRED_FLAG, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_PROD_SEQ <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_PROD_SEQ,'!!!') <> NVL(p_out_rec.CUSTOMER_PROD_SEQ,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_PROD_SEQ, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_DOCK_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_DOCK_CODE,'!!!') <> NVL(p_out_rec.CUSTOMER_DOCK_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_DOCK_CODE, ';
  END IF;

  IF     p_user_in_rec.CUST_MODEL_SERIAL_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUST_MODEL_SERIAL_NUMBER,'!!!') <> NVL(p_out_rec.CUST_MODEL_SERIAL_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'CUST_MODEL_SERIAL_NUMBER, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_JOB <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_JOB,'!!!') <> NVL(p_out_rec.CUSTOMER_JOB,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_JOB, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_PRODUCTION_LINE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_PRODUCTION_LINE,'!!!') <> NVL(p_out_rec.CUSTOMER_PRODUCTION_LINE,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_PRODUCTION_LINE, ';
  END IF;

  IF     p_user_in_rec.NET_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.NET_WEIGHT,-99) <> NVL(p_out_rec.NET_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'NET_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.WEIGHT_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WEIGHT_UOM_CODE,'!!!') <> NVL(p_out_rec.WEIGHT_UOM_CODE,'!!!')
  THEN
       IF (NVL(p_in_rec.caller,'WSH')  LIKE 'WMS%')
         AND (NVL(p_in_rec.action_code,'CREATE') = 'UPDATE') THEN
          NULL;
       ELSE
          l_attributes := l_attributes || 'WEIGHT_UOM_CODE, ';
       END IF;
  END IF;

  IF     p_user_in_rec.VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.VOLUME,-99) <> NVL(p_out_rec.VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'VOLUME, ';
  END IF;

  IF     p_user_in_rec.VOLUME_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.VOLUME_UOM_CODE,'!!!') <> NVL(p_out_rec.VOLUME_UOM_CODE,'!!!')
  THEN
       IF (NVL(p_in_rec.caller,'WSH')  LIKE 'WMS%')
         AND (NVL(p_in_rec.action_code,'CREATE') = 'UPDATE') THEN
          NULL;
       ELSE
          l_attributes := l_attributes || 'VOLUME_UOM_CODE, ';
       END IF;
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE1,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE2,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE3,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE4,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE5,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE6,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE7,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE8,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE9,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE10,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE11,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE12,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE13,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE14,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE15,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE15, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE1,'!!!') <> NVL(p_out_rec.ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE2,'!!!') <> NVL(p_out_rec.ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE3,'!!!') <> NVL(p_out_rec.ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE4,'!!!') <> NVL(p_out_rec.ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE5,'!!!') <> NVL(p_out_rec.ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE6,'!!!') <> NVL(p_out_rec.ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE7,'!!!') <> NVL(p_out_rec.ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE8,'!!!') <> NVL(p_out_rec.ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE9,'!!!') <> NVL(p_out_rec.ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE10,'!!!') <> NVL(p_out_rec.ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE11,'!!!') <> NVL(p_out_rec.ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE12,'!!!') <> NVL(p_out_rec.ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE13,'!!!') <> NVL(p_out_rec.ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE14,'!!!') <> NVL(p_out_rec.ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE15,'!!!') <> NVL(p_out_rec.ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE15, ';
  END IF;

  /**
  -- Bug 3613650 : Need not compare WHO columns
  --
  IF     p_user_in_rec.CREATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CREATED_BY,-99) <> NVL(p_out_rec.CREATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'CREATED_BY, ';
  END IF;

  IF     p_user_in_rec.CREATION_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CREATION_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CREATION_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CREATION_DATE, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LAST_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LAST_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_LOGIN <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATE_LOGIN,-99) <> NVL(p_out_rec.LAST_UPDATE_LOGIN,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_LOGIN, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATED_BY,-99) <> NVL(p_out_rec.LAST_UPDATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATED_BY, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_APPLICATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_APPLICATION_ID,-99) <> NVL(p_out_rec.PROGRAM_APPLICATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_APPLICATION_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_ID,-99) <> NVL(p_out_rec.PROGRAM_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'PROGRAM_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.REQUEST_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.REQUEST_ID,-99) <> NVL(p_out_rec.REQUEST_ID,-99)
  THEN
       l_attributes := l_attributes || 'REQUEST_ID, ';
  END IF;
  **/

  IF     p_user_in_rec.MVT_STAT_STATUS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.MVT_STAT_STATUS,'!!!') <> NVL(p_out_rec.MVT_STAT_STATUS,'!!!')
  THEN
       l_attributes := l_attributes || 'MVT_STAT_STATUS, ';
  END IF;

  IF     p_user_in_rec.RELEASED_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.RELEASED_FLAG,'!!!') <> NVL(p_out_rec.RELEASED_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'RELEASED_FLAG, ';
  END IF;

  IF     p_user_in_rec.ORGANIZATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ORGANIZATION_ID,-99) <> NVL(p_out_rec.ORGANIZATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'ORGANIZATION_ID, ';
  END IF;

  IF     p_user_in_rec.TRANSACTION_TEMP_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TRANSACTION_TEMP_ID,-99) <> NVL(p_out_rec.TRANSACTION_TEMP_ID,-99)
  THEN
       l_attributes := l_attributes || 'TRANSACTION_TEMP_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_SET_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_SET_ID,-99) <> NVL(p_out_rec.SHIP_SET_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_SET_ID, ';
  END IF;

  IF     p_user_in_rec.ARRIVAL_SET_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ARRIVAL_SET_ID,-99) <> NVL(p_out_rec.ARRIVAL_SET_ID,-99)
  THEN
       l_attributes := l_attributes || 'ARRIVAL_SET_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_MODEL_COMPLETE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIP_MODEL_COMPLETE_FLAG,'!!!') <> NVL(p_out_rec.SHIP_MODEL_COMPLETE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIP_MODEL_COMPLETE_FLAG, ';
  END IF;

  IF     p_user_in_rec.TOP_MODEL_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TOP_MODEL_LINE_ID,-99) <> NVL(p_out_rec.TOP_MODEL_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'TOP_MODEL_LINE_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_HEADER_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SOURCE_HEADER_NUMBER,'!!!') <> NVL(p_out_rec.SOURCE_HEADER_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'SOURCE_HEADER_NUMBER, ';
  END IF;

  IF     p_user_in_rec.SOURCE_HEADER_TYPE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_HEADER_TYPE_ID,-99) <> NVL(p_out_rec.SOURCE_HEADER_TYPE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_HEADER_TYPE_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_HEADER_TYPE_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SOURCE_HEADER_TYPE_NAME,'!!!') <> NVL(p_out_rec.SOURCE_HEADER_TYPE_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'SOURCE_HEADER_TYPE_NAME, ';
  END IF;

  IF     p_user_in_rec.CUST_PO_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUST_PO_NUMBER,'!!!') <> NVL(p_out_rec.CUST_PO_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'CUST_PO_NUMBER, ';
  END IF;

  IF     p_user_in_rec.ATO_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ATO_LINE_ID,-99) <> NVL(p_out_rec.ATO_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'ATO_LINE_ID, ';
  END IF;

  IF     p_user_in_rec.SRC_REQUESTED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SRC_REQUESTED_QUANTITY,-99) <> NVL(p_out_rec.SRC_REQUESTED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'SRC_REQUESTED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.SRC_REQUESTED_QUANTITY_UOM <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SRC_REQUESTED_QUANTITY_UOM,'!!!') <> NVL(p_out_rec.SRC_REQUESTED_QUANTITY_UOM,'!!!')
  THEN
       l_attributes := l_attributes || 'SRC_REQUESTED_QUANTITY_UOM, ';
  END IF;

  IF     p_user_in_rec.MOVE_ORDER_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MOVE_ORDER_LINE_ID,-99) <> NVL(p_out_rec.MOVE_ORDER_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'MOVE_ORDER_LINE_ID, ';
  END IF;
  --bug# 6689448 (replenishment project)
  IF     p_user_in_rec.REPLENISHMENT_STATUS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.REPLENISHMENT_STATUS,'!!!') <> NVL(p_out_rec.REPLENISHMENT_STATUS,'!!!')
  THEN
       l_attributes := l_attributes || 'REPLENISHMENT_STATUS, ';
  END IF;

  IF     p_user_in_rec.CANCELLED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CANCELLED_QUANTITY,-99) <> NVL(p_out_rec.CANCELLED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'CANCELLED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.QUALITY_CONTROL_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.QUALITY_CONTROL_QUANTITY,-99) <> NVL(p_out_rec.QUALITY_CONTROL_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'QUALITY_CONTROL_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.CYCLE_COUNT_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CYCLE_COUNT_QUANTITY,-99) <> NVL(p_out_rec.CYCLE_COUNT_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'CYCLE_COUNT_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.TRACKING_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TRACKING_NUMBER,'!!!') <> NVL(p_out_rec.TRACKING_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'TRACKING_NUMBER, ';
  END IF;

  IF     p_user_in_rec.MOVEMENT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MOVEMENT_ID,-99) <> NVL(p_out_rec.MOVEMENT_ID,-99)
  THEN
       l_attributes := l_attributes || 'MOVEMENT_ID, ';
  END IF;

  IF     p_user_in_rec.SHIPPING_INSTRUCTIONS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPPING_INSTRUCTIONS,'!!!') <> NVL(p_out_rec.SHIPPING_INSTRUCTIONS,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPPING_INSTRUCTIONS, ';
  END IF;

  IF     p_user_in_rec.PACKING_INSTRUCTIONS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PACKING_INSTRUCTIONS,'!!!') <> NVL(p_out_rec.PACKING_INSTRUCTIONS,'!!!')
  THEN
       l_attributes := l_attributes || 'PACKING_INSTRUCTIONS, ';
  END IF;

  IF     p_user_in_rec.PROJECT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROJECT_ID,-99) <> NVL(p_out_rec.PROJECT_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROJECT_ID, ';
  END IF;

  IF     p_user_in_rec.TASK_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TASK_ID,-99) <> NVL(p_out_rec.TASK_ID,-99)
  THEN
       l_attributes := l_attributes || 'TASK_ID, ';
  END IF;

  IF     p_user_in_rec.ORG_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ORG_ID,-99) <> NVL(p_out_rec.ORG_ID,-99)
  THEN
       l_attributes := l_attributes || 'ORG_ID, ';
  END IF;

  IF     p_user_in_rec.OE_INTERFACED_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.OE_INTERFACED_FLAG,'!!!') <> NVL(p_out_rec.OE_INTERFACED_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'OE_INTERFACED_FLAG, ';
  END IF;

  IF     p_user_in_rec.SPLIT_FROM_DETAIL_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SPLIT_FROM_DETAIL_ID,-99) <> NVL(p_out_rec.SPLIT_FROM_DETAIL_ID,-99)
  THEN
       l_attributes := l_attributes || 'SPLIT_FROM_DETAIL_ID, ';
  END IF;

  IF     p_user_in_rec.INV_INTERFACED_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.INV_INTERFACED_FLAG,'!!!') <> NVL(p_out_rec.INV_INTERFACED_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'INV_INTERFACED_FLAG, ';
  END IF;

  IF     p_user_in_rec.SOURCE_LINE_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SOURCE_LINE_NUMBER,'!!!') <> NVL(p_out_rec.SOURCE_LINE_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'SOURCE_LINE_NUMBER, ';
  END IF;

  IF     p_user_in_rec.INSPECTION_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.INSPECTION_FLAG,'!!!') <> NVL(p_out_rec.INSPECTION_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'INSPECTION_FLAG, ';
  END IF;

  IF     p_user_in_rec.RELEASED_STATUS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.RELEASED_STATUS,'!!!') <> NVL(p_out_rec.RELEASED_STATUS,'!!!')
  THEN
       l_attributes := l_attributes || 'RELEASED_STATUS, ';
  END IF;

  IF     p_user_in_rec.CONTAINER_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CONTAINER_FLAG,'!!!') <> NVL(p_out_rec.CONTAINER_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'CONTAINER_FLAG, ';
  END IF;

  IF     p_user_in_rec.CONTAINER_TYPE_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CONTAINER_TYPE_CODE,'!!!') <> NVL(p_out_rec.CONTAINER_TYPE_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CONTAINER_TYPE_CODE, ';
  END IF;

  IF     p_user_in_rec.CONTAINER_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CONTAINER_NAME,'!!!') <> NVL(p_out_rec.CONTAINER_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'CONTAINER_NAME, ';
  END IF;

  IF     p_user_in_rec.FILL_PERCENT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.FILL_PERCENT,-99) <> NVL(p_out_rec.FILL_PERCENT,-99)
  THEN
       l_attributes := l_attributes || 'FILL_PERCENT, ';
  END IF;

  IF     p_user_in_rec.GROSS_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.GROSS_WEIGHT,-99) <> NVL(p_out_rec.GROSS_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'GROSS_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.MASTER_SERIAL_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.MASTER_SERIAL_NUMBER,'!!!') <> NVL(p_out_rec.MASTER_SERIAL_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'MASTER_SERIAL_NUMBER, ';
  END IF;

  IF     p_user_in_rec.MAXIMUM_LOAD_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MAXIMUM_LOAD_WEIGHT,-99) <> NVL(p_out_rec.MAXIMUM_LOAD_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'MAXIMUM_LOAD_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.MAXIMUM_VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MAXIMUM_VOLUME,-99) <> NVL(p_out_rec.MAXIMUM_VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'MAXIMUM_VOLUME, ';
  END IF;

  IF     p_user_in_rec.MINIMUM_FILL_PERCENT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.MINIMUM_FILL_PERCENT,-99) <> NVL(p_out_rec.MINIMUM_FILL_PERCENT,-99)
  THEN
       l_attributes := l_attributes || 'MINIMUM_FILL_PERCENT, ';
  END IF;

  IF     p_user_in_rec.SEAL_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SEAL_CODE,'!!!') <> NVL(p_out_rec.SEAL_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SEAL_CODE, ';
  END IF;

  IF     p_user_in_rec.UNIT_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.UNIT_NUMBER,'!!!') <> NVL(p_out_rec.UNIT_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'UNIT_NUMBER, ';
  END IF;

  IF     p_user_in_rec.UNIT_PRICE <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.UNIT_PRICE,-99) <> NVL(p_out_rec.UNIT_PRICE,-99)
  THEN
       l_attributes := l_attributes || 'UNIT_PRICE, ';
  END IF;

  IF     p_user_in_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CURRENCY_CODE,'!!!') <> NVL(p_out_rec.CURRENCY_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CURRENCY_CODE, ';
  END IF;

  IF     p_user_in_rec.FREIGHT_CLASS_CAT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.FREIGHT_CLASS_CAT_ID,-99) <> NVL(p_out_rec.FREIGHT_CLASS_CAT_ID,-99)
  THEN
       l_attributes := l_attributes || 'FREIGHT_CLASS_CAT_ID, ';
  END IF;

  IF     p_user_in_rec.COMMODITY_CODE_CAT_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.COMMODITY_CODE_CAT_ID,-99) <> NVL(p_out_rec.COMMODITY_CODE_CAT_ID,-99)
  THEN
       l_attributes := l_attributes || 'COMMODITY_CODE_CAT_ID, ';
  END IF;

  IF     p_user_in_rec.PREFERRED_GRADE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PREFERRED_GRADE,'!!!') <> NVL(p_out_rec.PREFERRED_GRADE,'!!!')
  THEN
       l_attributes := l_attributes || 'PREFERRED_GRADE, ';
  END IF;

  IF     p_user_in_rec.SRC_REQUESTED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SRC_REQUESTED_QUANTITY2,-99) <> NVL(p_out_rec.SRC_REQUESTED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'SRC_REQUESTED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.SRC_REQUESTED_QUANTITY_UOM2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SRC_REQUESTED_QUANTITY_UOM2,'!!!') <> NVL(p_out_rec.SRC_REQUESTED_QUANTITY_UOM2,'!!!')
  THEN
       l_attributes := l_attributes || 'SRC_REQUESTED_QUANTITY_UOM2, ';
  END IF;

  IF     p_user_in_rec.REQUESTED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.REQUESTED_QUANTITY2,-99) <> NVL(p_out_rec.REQUESTED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'REQUESTED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.SHIPPED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIPPED_QUANTITY2,-99) <> NVL(p_out_rec.SHIPPED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'SHIPPED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.DELIVERED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVERED_QUANTITY2,-99) <> NVL(p_out_rec.DELIVERED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'DELIVERED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.CANCELLED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CANCELLED_QUANTITY2,-99) <> NVL(p_out_rec.CANCELLED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'CANCELLED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.QUALITY_CONTROL_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.QUALITY_CONTROL_QUANTITY2,-99) <> NVL(p_out_rec.QUALITY_CONTROL_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'QUALITY_CONTROL_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.CYCLE_COUNT_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CYCLE_COUNT_QUANTITY2,-99) <> NVL(p_out_rec.CYCLE_COUNT_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'CYCLE_COUNT_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.REQUESTED_QUANTITY_UOM2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.REQUESTED_QUANTITY_UOM2,'!!!') <> NVL(p_out_rec.REQUESTED_QUANTITY_UOM2,'!!!')
  THEN
       l_attributes := l_attributes || 'REQUESTED_QUANTITY_UOM2, ';
  END IF;

-- HW OPMCONV - No need for sublot_number

  IF     p_user_in_rec.LPN_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LPN_ID,-99) <> NVL(p_out_rec.LPN_ID,-99)
  THEN
       l_attributes := l_attributes || 'LPN_ID, ';
  END IF;

  IF     p_user_in_rec.PICKABLE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PICKABLE_FLAG,'!!!') <> NVL(p_out_rec.PICKABLE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'PICKABLE_FLAG, ';
  END IF;

  IF     p_user_in_rec.ORIGINAL_SUBINVENTORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ORIGINAL_SUBINVENTORY,'!!!') <> NVL(p_out_rec.ORIGINAL_SUBINVENTORY,'!!!')
  THEN
       l_attributes := l_attributes || 'ORIGINAL_SUBINVENTORY, ';
  END IF;

  IF     p_user_in_rec.TO_SERIAL_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TO_SERIAL_NUMBER,'!!!') <> NVL(p_out_rec.TO_SERIAL_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'TO_SERIAL_NUMBER, ';
  END IF;

  IF     p_user_in_rec.PICKED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PICKED_QUANTITY,-99) <> NVL(p_out_rec.PICKED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'PICKED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.PICKED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PICKED_QUANTITY2,-99) <> NVL(p_out_rec.PICKED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'PICKED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.RECEIVED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RECEIVED_QUANTITY,-99) <> NVL(p_out_rec.RECEIVED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'RECEIVED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.RECEIVED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RECEIVED_QUANTITY2,-99) <> NVL(p_out_rec.RECEIVED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'RECEIVED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.SOURCE_LINE_SET_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_LINE_SET_ID,-99) <> NVL(p_out_rec.SOURCE_LINE_SET_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_LINE_SET_ID, ';
  END IF;

  IF     p_user_in_rec.BATCH_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.BATCH_ID,-99) <> NVL(p_out_rec.BATCH_ID,-99)
  THEN
       l_attributes := l_attributes || 'BATCH_ID, ';
  END IF;

  IF     p_user_in_rec.ROWID <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ROWID,'!!!') <> NVL(p_out_rec.ROWID,'!!!')
  THEN
       l_attributes := l_attributes || 'ROWID, ';
  END IF;

  IF     p_user_in_rec.TRANSACTION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TRANSACTION_ID,-99) <> NVL(p_out_rec.TRANSACTION_ID,-99)
  THEN
       l_attributes := l_attributes || 'TRANSACTION_ID, ';
  END IF;

  IF     p_user_in_rec.VENDOR_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.VENDOR_ID,-99) <> NVL(p_out_rec.VENDOR_ID,-99)
  THEN
       l_attributes := l_attributes || 'VENDOR_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_FROM_SITE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SHIP_FROM_SITE_ID,-99) <> NVL(p_out_rec.SHIP_FROM_SITE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SHIP_FROM_SITE_ID, ';
  END IF;

  IF     p_user_in_rec.LINE_DIRECTION <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.LINE_DIRECTION,'!!!') <> NVL(p_out_rec.LINE_DIRECTION,'!!!')
  THEN
       l_attributes := l_attributes || 'LINE_DIRECTION, ';
  END IF;

  IF     p_user_in_rec.PARTY_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PARTY_ID,-99) <> NVL(p_out_rec.PARTY_ID,-99)
  THEN
       l_attributes := l_attributes || 'PARTY_ID, ';
  END IF;

  IF     p_user_in_rec.ROUTING_REQ_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ROUTING_REQ_ID,-99) <> NVL(p_out_rec.ROUTING_REQ_ID,-99)
  THEN
       l_attributes := l_attributes || 'ROUTING_REQ_ID, ';
  END IF;

  IF     p_user_in_rec.SHIPPING_CONTROL <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPPING_CONTROL,'!!!') <> NVL(p_out_rec.SHIPPING_CONTROL,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPPING_CONTROL, ';
  END IF;

  IF     p_user_in_rec.SOURCE_BLANKET_REFERENCE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_BLANKET_REFERENCE_ID,-99) <> NVL(p_out_rec.SOURCE_BLANKET_REFERENCE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_BLANKET_REFERENCE_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_BLANKET_REFERENCE_NUM <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_BLANKET_REFERENCE_NUM,-99) <> NVL(p_out_rec.SOURCE_BLANKET_REFERENCE_NUM,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_BLANKET_REFERENCE_NUM, ';
  END IF;

  IF     p_user_in_rec.PO_SHIPMENT_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PO_SHIPMENT_LINE_ID,-99) <> NVL(p_out_rec.PO_SHIPMENT_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'PO_SHIPMENT_LINE_ID, ';
  END IF;

  IF     p_user_in_rec.PO_SHIPMENT_LINE_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PO_SHIPMENT_LINE_NUMBER,-99) <> NVL(p_out_rec.PO_SHIPMENT_LINE_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'PO_SHIPMENT_LINE_NUMBER, ';
  END IF;

  IF     p_user_in_rec.RETURNED_QUANTITY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RETURNED_QUANTITY,-99) <> NVL(p_out_rec.RETURNED_QUANTITY,-99)
  THEN
       l_attributes := l_attributes || 'RETURNED_QUANTITY, ';
  END IF;

  IF     p_user_in_rec.RETURNED_QUANTITY2 <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RETURNED_QUANTITY2,-99) <> NVL(p_out_rec.RETURNED_QUANTITY2,-99)
  THEN
       l_attributes := l_attributes || 'RETURNED_QUANTITY2, ';
  END IF;

  IF     p_user_in_rec.RCV_SHIPMENT_LINE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RCV_SHIPMENT_LINE_ID,-99) <> NVL(p_out_rec.RCV_SHIPMENT_LINE_ID,-99)
  THEN
       l_attributes := l_attributes || 'RCV_SHIPMENT_LINE_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_LINE_TYPE_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SOURCE_LINE_TYPE_CODE,'!!!') <> NVL(p_out_rec.SOURCE_LINE_TYPE_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SOURCE_LINE_TYPE_CODE, ';
  END IF;

  IF     p_user_in_rec.SUPPLIER_ITEM_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SUPPLIER_ITEM_NUMBER,'!!!') <> NVL(p_out_rec.SUPPLIER_ITEM_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'SUPPLIER_ITEM_NUMBER, ';
  END IF;

  IF     p_user_in_rec.IGNORE_FOR_PLANNING <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.IGNORE_FOR_PLANNING,'!!!') <> NVL(p_out_rec.IGNORE_FOR_PLANNING,'!!!')
  THEN
       l_attributes := l_attributes || 'IGNORE_FOR_PLANNING, ';
  END IF;

  IF     p_user_in_rec.EARLIEST_PICKUP_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.EARLIEST_PICKUP_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.EARLIEST_PICKUP_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'EARLIEST_PICKUP_DATE, ';
  END IF;

  IF     p_user_in_rec.LATEST_PICKUP_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LATEST_PICKUP_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LATEST_PICKUP_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LATEST_PICKUP_DATE, ';
  END IF;

  IF     p_user_in_rec.EARLIEST_DROPOFF_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.EARLIEST_DROPOFF_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.EARLIEST_DROPOFF_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'EARLIEST_DROPOFF_DATE, ';
  END IF;

  IF     p_user_in_rec.LATEST_DROPOFF_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LATEST_DROPOFF_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LATEST_DROPOFF_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LATEST_DROPOFF_DATE, ';
  END IF;

  IF     p_user_in_rec.REQUEST_DATE_TYPE_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.REQUEST_DATE_TYPE_CODE,'!!!') <> NVL(p_out_rec.REQUEST_DATE_TYPE_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'REQUEST_DATE_TYPE_CODE, ';
  END IF;

  IF     p_user_in_rec.TP_DELIVERY_DETAIL_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TP_DELIVERY_DETAIL_ID,-99) <> NVL(p_out_rec.TP_DELIVERY_DETAIL_ID,-99)
  THEN
       l_attributes := l_attributes || 'TP_DELIVERY_DETAIL_ID, ';
  END IF;

  IF     p_user_in_rec.SOURCE_DOCUMENT_TYPE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_DOCUMENT_TYPE_ID,-99) <> NVL(p_out_rec.SOURCE_DOCUMENT_TYPE_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_DOCUMENT_TYPE_ID, ';
  END IF;

  IF     p_user_in_rec.UNIT_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.UNIT_WEIGHT,-99) <> NVL(p_out_rec.UNIT_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'UNIT_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.UNIT_VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.UNIT_VOLUME,-99) <> NVL(p_out_rec.UNIT_VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'UNIT_VOLUME, ';
  END IF;

  IF     p_user_in_rec.FILLED_VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.FILLED_VOLUME,-99) <> NVL(p_out_rec.FILLED_VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'FILLED_VOLUME, ';
  END IF;

  IF     p_user_in_rec.WV_FROZEN_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WV_FROZEN_FLAG,'!!!') <> NVL(p_out_rec.WV_FROZEN_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'WV_FROZEN_FLAG, ';
  END IF;

  IF     p_user_in_rec.MODE_OF_TRANSPORT <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.MODE_OF_TRANSPORT,'!!!') <> NVL(p_out_rec.MODE_OF_TRANSPORT,'!!!')
  THEN
       l_attributes := l_attributes || 'MODE_OF_TRANSPORT, ';
  END IF;

  IF     p_user_in_rec.SERVICE_LEVEL <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SERVICE_LEVEL,'!!!') <> NVL(p_out_rec.SERVICE_LEVEL,'!!!')
  THEN
       l_attributes := l_attributes || 'SERVICE_LEVEL, ';
  END IF;

  IF     p_user_in_rec.PO_REVISION_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PO_REVISION_NUMBER,-99) <> NVL(p_out_rec.PO_REVISION_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'PO_REVISION_NUMBER, ';
  END IF;

  IF     p_user_in_rec.RELEASE_REVISION_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RELEASE_REVISION_NUMBER,-99) <> NVL(p_out_rec.RELEASE_REVISION_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'RELEASE_REVISION_NUMBER, ';
  END IF;



  IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_attributes',l_attributes);
       WSH_DEBUG_SV.log(l_module_name,'length(l_attributes)',length(l_attributes));
  END IF;


  IF l_attributes IS NULL    THEN
     --no message to be shown to the user
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  ELSE
     Wsh_Utilities.process_message(
                                   p_entity => 'DLVB',
                                   p_entity_name => p_out_rec.DELIVERY_DETAIL_ID,
                                   p_attributes => l_attributes,
                                   x_return_status => l_return_status
                                   );

     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
     THEN
       x_return_status := l_return_status;
       IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'Error returned by wsh_utilities.process_message',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         wsh_debug_sv.pop(l_module_name);
       END IF;
       return;
     ELSE
       x_return_status := wsh_util_core.G_RET_STS_WARNING;
     END IF;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END user_non_updatable_columns;

-- HW OPMCONV - Added new function to check if line is elibible for split
/*
-----------------------------------------------------------------------------
   FUNCTION   : is_split_allowed
   PARAMETERS : p_delivery_detail_id - delivery detail id
                p_organization_id    - organization id
                p_inventory_item_id  - inventory item id
                p_released_status    - released status for this wdd line

  DESCRIPTION : This function checks if delivery detail line
                is eligible for a split
                e.g if delivery detail has an item that is lot
                indivisible and it's staged, split actions will not be permitted
------------------------------------------------------------------------------
*/

FUNCTION is_split_allowed(
           p_delivery_detail_id  IN  NUMBER,
           p_organization_id     IN  NUMBER,
           p_inventory_item_id   IN  NUMBER,
           p_released_status     IN  VARCHAR2)
RETURN BOOLEAN
IS

l_item_info              WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
l_released_status VARCHAR2(1);
l_debug_on                    BOOLEAN;
l_return_status VARCHAR2(1);
l_number_of_errors            NUMBER ;
l_number_of_warnings          NUMBER ;
l_source_line_id              NUMBER;
l_exist                       NUMBER ;
no_entry EXCEPTION;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'is_split_allowed';

 Cursor get_indiv_reservation Is
 Select 1
 From mtl_reservations
 Where demand_source_type_id = 2
   and demand_source_line_id = l_source_line_id
   and rownum = 1
   ;

 BEGIN


   l_debug_on := wsh_debug_interface.g_debug;
   l_exist := 0;
   l_number_of_errors   := 0;
   l_number_of_warnings := 0;
   l_released_status    := p_released_status ;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_DETAIL_ID', p_delivery_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'p_organization_id', p_organization_id);
      wsh_debug_sv.LOG(l_module_name, 'p_inventory_item_id', p_inventory_item_id);
    END IF;
    --

    WSH_DELIVERY_DETAILS_INV.Get_item_information
            (
               p_organization_id       =>  p_organization_id,
               p_inventory_item_id     =>  p_inventory_item_id,
               x_mtl_system_items_rec  =>  l_item_info,
               x_return_status         =>  l_return_status
            );
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_number_of_warnings,
        x_num_errors    => l_number_of_errors
      );

    IF ( l_item_info.lot_divisible_flag = 'N' AND
         l_item_info.lot_control_code = 2 AND l_released_status ='Y') THEN
         IF l_debug_on THEN
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_divisible_flag', l_item_info.lot_divisible_flag);
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
           wsh_debug_sv.LOG(l_module_name, 'l_released_status', l_released_status);
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return(FALSE);

    ELSE
      /* Lgao, bug 5141589, if reservation exists for the line, no split allowed for indivisible items*/
      IF ( l_item_info.lot_divisible_flag = 'N' and l_item_info.lot_control_code = 2) THEN
        Open get_indiv_reservation;
        Fetch get_indiv_reservation into l_exist;
        Close get_indiv_reservation;
        If l_exist = 1 Then
            IF l_debug_on THEN
              wsh_debug_sv.LOG(l_module_name, 'lot_divisible_flag', l_item_info.lot_divisible_flag);
              wsh_debug_sv.LOG(l_module_name, 'Reservation Exists' );
              wsh_debug_sv.LOG(l_module_name, 'Split Not Allowed' );
              WSH_DEBUG_SV.pop(l_module_name);
            End if;
            return(FALSE);
        End if;
      End if;
      IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'lot_divisible_flag', l_item_info.lot_divisible_flag);
        wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
        wsh_debug_sv.LOG(l_module_name, 'l_released_status', l_released_status);

        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

      return(TRUE);
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    return(TRUE);

EXCEPTION
          WHEN NO_DATA_FOUND THEN
		  -- Debug Statements
		  --
       -- CLOSE line_status;
          IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
          END IF;
		  --
	  return(FALSE);

	  WHEN others THEN
          IF get_indiv_reservation%ISOPEN THEN
             Close get_indiv_reservation;
          END IF;
              --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
		   --
          return(FALSE);

 END is_split_allowed;

FUNCTION is_cycle_count_allowed(
           p_delivery_detail_id  IN  NUMBER,
           p_organization_id     IN  NUMBER,
           p_inventory_item_id   IN  NUMBER,
           p_released_status     IN  VARCHAR2,
           p_picked_qty          IN  NUMBER,
           p_cycle_qty           IN  NUMBER)
RETURN BOOLEAN
IS

l_item_info              WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
l_released_status VARCHAR2(1);
l_debug_on                    BOOLEAN;
l_return_status VARCHAR2(1);
l_number_of_errors            NUMBER ;
l_number_of_warnings          NUMBER ;
l_picked_qty                  NUMBER;
l_exist                       NUMBER ;
no_entry EXCEPTION;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'is_cycle_count_allowed';

 BEGIN


   l_debug_on := wsh_debug_interface.g_debug;
   l_exist := 0;
   l_number_of_errors   := 0;
   l_number_of_warnings := 0;
   l_released_status    := p_released_status;
   l_picked_qty         := p_picked_qty;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_DETAIL_ID', p_delivery_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'p_organization_id', p_organization_id);
      wsh_debug_sv.LOG(l_module_name, 'p_inventory_item_id', p_inventory_item_id);
    END IF;
    --

    WSH_DELIVERY_DETAILS_INV.Get_item_information
            (
               p_organization_id       =>  p_organization_id,
               p_inventory_item_id     =>  p_inventory_item_id,
               x_mtl_system_items_rec  =>  l_item_info,
               x_return_status         =>  l_return_status
            );
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_number_of_warnings,
        x_num_errors    => l_number_of_errors
      );

    IF ( l_item_info.lot_divisible_flag = 'N' AND p_cycle_qty <> l_picked_qty AND
         l_item_info.lot_control_code = 2 AND l_released_status ='Y') THEN
         IF l_debug_on THEN
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_divisible_flag', l_item_info.lot_divisible_flag);
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
           wsh_debug_sv.LOG(l_module_name, 'l_released_status', l_released_status);
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return(FALSE);

    ELSE
      IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'lot_divisible_flag', l_item_info.lot_divisible_flag);
        wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
        wsh_debug_sv.LOG(l_module_name, 'l_released_status', l_released_status);

        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

      return(TRUE);
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    return(TRUE);

EXCEPTION
          WHEN NO_DATA_FOUND THEN
		  -- Debug Statements
		  --
       -- CLOSE line_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
          END IF;
		  --
	  return(FALSE);

	  WHEN others THEN
          /*IF line_status%ISOPEN THEN
             CLOSE line_status;
          END IF;
          */
              --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
		   --
          return(FALSE);

 END is_cycle_count_allowed;

END WSH_DETAILS_VALIDATIONS;

/
