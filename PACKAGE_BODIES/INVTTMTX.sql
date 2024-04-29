--------------------------------------------------------
--  DDL for Package Body INVTTMTX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVTTMTX" as
/* $Header: INVTTMTB.pls 120.6 2006/09/14 18:39:21 jsrivast ship $ */

PROCEDURE tdatechk(org_id 		IN	INTEGER,
		   transaction_date 	IN	DATE,
		   period_id 		OUT 	nocopy INTEGER,
 		   open_past_period 	IN OUT 	nocopy BOOLEAN) IS
	v_transaction_period_id INTEGER;
	v_current_period_id     INTEGER;
   l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     v_scheduled_close_date        DATE;
begin
   if( l_debug = 1 ) then
	inv_log_util.trace('tdatechk ' || nvl(G_ORG_ID, -1) || ' ' || nvl(G_TRANSACTION_DATE, trunc(sysdate)), 'tdatechk', 9);
	inv_log_util.trace('org_id = ' || org_id || ' transaction_date = ' || transaction_date, 'tdatechk', 9);
   end if;
   if( nvl(G_ORG_ID, -1) <> org_id OR nvl(G_TRANSACTION_DATE, trunc(sysdate)) <> trunc(nvl(transaction_date, sysdate)) OR G_PERIOD_STATUS <> 1) THEN
      if( l_debug = 1 ) then
	  inv_log_util.trace('will query database', 'tdatechk', 9);
      end if;
      begin
	period_id := 0;

	-- Bug 4737520 (Base bugfix 4721230) move caching to the end to make sure current_period_id gets populated correctly.
	--G_ORG_ID := org_id;

	G_TRANSACTION_DATE := trunc(nvl(transaction_date, sysdate));

	SELECT ACCT_PERIOD_ID, TRUNC(SCHEDULE_CLOSE_DATE)
        INTO   v_transaction_period_id,v_scheduled_close_date
        FROM   ORG_ACCT_PERIODS
        WHERE  PERIOD_CLOSE_DATE IS NULL
        AND    ORGANIZATION_ID = org_id
        AND    TRUNC(SCHEDULE_CLOSE_DATE) >=
               TRUNC(INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Nvl(transaction_date,Sysdate),org_id))
        AND    TRUNC(PERIOD_START_DATE) <=
               TRUNC(INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Nvl(transaction_date,Sysdate),org_id));
	period_id := v_transaction_period_id;
	G_TRANSACTION_PERIOD_ID := v_transaction_period_id;
	G_PERIOD_STATUS := 1;

	EXCEPTION
		when NO_DATA_FOUND then
			G_TRANSACTION_PERIOD_ID := 0;
			period_id := 0;
			G_PERIOD_STATUS := 0;
		when OTHERS then
			G_TRANSACTION_PERIOD_ID := -1;
			period_id := -1;
			G_PERIOD_STATUS := 0;
     end;
  else
     if( l_debug = 1 ) then
	inv_log_util.trace('get the value from global package var ' || g_transaction_period_id, 'tdatechk', 9);
     end if;
     v_transaction_period_id := G_TRANSACTION_PERIOD_ID;
     period_id := G_TRANSACTION_PERIOD_ID;
  end if;
/*   Check to see if the selected period id falls within the current
     period or is in a past period.
*/

   begin
	if (open_past_period) then
	    if( l_debug = 1 ) then
	        inv_log_util.trace('open_past_period is true', 'tdatechk', 9);
	        inv_log_util.trace('G_CURRENT_DATE is ' || trunc(nvl(G_CURRENT_DATE, sysdate)), 'tdatechk', 9);
	    end if;

	-- Bug 4737520 base bugfix 4721230 should still query the current_period_id, if cached g_current_period_id is null

	   if( nvl(G_ORG_ID, -1) <> org_id OR trunc(nvl(G_CURRENT_DATE, sysdate)) <> trunc(sysdate) OR G_CURRENT_PERIOD_ID is NULL ) THEN
		if l_debug = 1 then
		   inv_log_util.trace('going to query db', 'tdatechk', 9);
	        end if;
		G_CURRENT_DATE := trunc(sysdate);

	        SELECT ACCT_PERIOD_ID
		INTO   v_current_period_id
        	FROM   ORG_ACCT_PERIODS
        	WHERE  PERIOD_CLOSE_DATE IS NULL
        	AND    ORGANIZATION_ID = org_id
        	AND    TRUNC(INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,org_id))
               		BETWEEN TRUNC(PERIOD_START_DATE) and
				TRUNC(SCHEDULE_CLOSE_DATE);
		G_CURRENT_PERIOD_ID := v_current_period_id;

	        if v_transaction_period_id <> v_current_period_id then
		   open_past_period := FALSE;
	        end if;
	     else
		if l_debug = 1 then
		    inv_log_util.trace('getting from cache ' || g_current_period_id, 'tdatechk', 9);
		end if;
		if v_transaction_period_id <> G_CURRENT_PERIOD_ID THEN
		    open_past_period := FALSE;
		end if;
	     end if;

	end if;
	EXCEPTION
		when NO_DATA_FOUND then
		        G_CURRENT_PERIOD_ID := -1;
			open_past_period := FALSE;
		when OTHERS then
			G_CURRENT_PERIOD_ID := -1;
			period_id := -1;
   end;
	G_ORG_ID := org_id;     --bugfix 4721230
end tdatechk;

FUNCTION ship_number_validation(shipment_number IN VARCHAR2) RETURN NUMBER IS
	counter	NUMBER := 0;
	found_row  VARCHAR2(100);
	vall	varchar2(30);
BEGIN
  vall := shipment_number;
  /* Bug:5154903. For the following two select statements added
     conditions to check transaction_type_id and transaction_action_id
     to query for only Transaction Type Inter-Org Transfer*/
  SELECT shipment_number
  INTO found_row
  FROM mtl_transactions_interface m
  WHERE m.shipment_number = vall
  AND   m.transaction_type_id  = INV_GLOBALS.G_SOURCETYPE_INVENTORY
  AND   m.transaction_action_id= INV_GLOBALS.G_ACTION_INTRANSITSHIPMENT
  AND ROWNUM = 1 ;

  return 0;

  EXCEPTION WHEN NO_DATA_FOUND then
  BEGIN
    SELECT shipment_number
    INTO found_row
    FROM mtl_material_transactions_temp m
    WHERE m.shipment_number = vall
    AND   m.transaction_type_id  = INV_GLOBALS.G_SOURCETYPE_INVENTORY
    AND   m.transaction_action_id= INV_GLOBALS.G_ACTION_INTRANSITSHIPMENT
    AND ROWNUM = 1 ;

    return 0;

    EXCEPTION WHEN NO_DATA_FOUND then
    BEGIN
      /* Bug:5154903.Added condition to check for receipt_source_code to
         query for only Transaction Type Inter-Org Transfer*/
      SELECT shipment_num
      INTO found_row
      FROM rcv_shipment_headers m
      WHERE m.shipment_num = vall
      AND   m.receipt_source_code = 'INVENTORY'
      AND ROWNUM = 1 ;

      return 0;

      EXCEPTION WHEN NO_DATA_FOUND then
        return 1;
     END;
  END;
end ship_number_validation;

  procedure post_query(
    p_org_id                in  number,
    p_inventory_item_id     in  number,
    p_subinv                in  varchar2,
    p_to_subinv             in  varchar2,
    p_reason_id             in  number,
    p_trx_type              in  varchar2,
    p_transaction_action_id in  number,
    p_from_uom              in  varchar2,
    p_to_uom                in  varchar2,
    p_sub_qty_tracked       out nocopy number,
    p_sub_asset_inv         out nocopy number,
    p_sub_locator_type      out nocopy number,
    p_sub_material_acct     out nocopy number,
    p_to_sub_qty_tracked    out nocopy number,
    p_to_sub_asset_inv      out nocopy number,
    p_to_sub_locator_type   out nocopy number,
    p_to_sub_material_acct  out nocopy number,
    p_reason_name           out nocopy varchar2,
    p_transaction_type      out nocopy varchar2,
    p_conversion_rate       out nocopy number) is

    cursor get_sub_info(
      c_org_id  number,
      c_item_id number,
      c_subinventory varchar2) is
    select quantity_tracked,
           asset_inventory,
           locator_type,
           material_account
    from   mtl_subinventories_all_v
    where  organization_id = c_org_id
    and    secondary_inventory_name = c_subinventory;

    cursor get_transaction_type(c_transaction_action_id number) is
    select meaning
    from   mfg_lookups
    where  lookup_type = 'WIP_TRANSACTION_DIRECTION'
    and    lookup_code = decode(c_transaction_action_id,
                                1, 1 /* return */,
                                   2 /* otherwise, issue */);

    cursor get_reason(c_reason_id number) is
    select reason_name
    from   mtl_transaction_reasons
    where  reason_id = c_reason_id;

  begin
    -- get subinv information
    if (p_subinv is NOT NULL) then
      open get_sub_info(
        c_org_id       => p_org_id,
        c_item_id      => p_inventory_item_id,
        c_subinventory => p_subinv);
      fetch get_sub_info into
        p_sub_qty_tracked,
        p_sub_asset_inv,
        p_sub_locator_type,
        p_sub_material_acct;
      if (get_sub_info%NOTFOUND) then
        p_sub_qty_tracked   := NULL;
        p_sub_asset_inv     := NULL;
        p_sub_locator_type  := NULL;
        p_sub_material_acct := NULL;
      end if;
      close get_sub_info;
    end if;

    -- get to subinv information
    if (p_to_subinv is NOT NULL) then
      open get_sub_info(
        c_org_id       => p_org_id,
        c_item_id      => p_inventory_item_id,
        c_subinventory => p_to_subinv);
      fetch get_sub_info into
        p_to_sub_qty_tracked,
        p_to_sub_asset_inv,
        p_to_sub_locator_type,
        p_to_sub_material_acct;
      if (get_sub_info%NOTFOUND) then
        p_to_sub_qty_tracked   := NULL;
        p_to_sub_asset_inv     := NULL;
        p_to_sub_locator_type  := NULL;
        p_to_sub_material_acct := NULL;
      end if;
      close get_sub_info;
    end if;

    -- get transaction type for backflush
    if (p_trx_type = 'WIP_BACKFLUSH') then
      open get_transaction_type(
        c_transaction_action_id => p_transaction_action_id);
      fetch get_transaction_type into p_transaction_type;
      if (get_transaction_type%NOTFOUND) then
        p_transaction_type := NULL;
      end if;
      close get_transaction_type;
    end if;

    -- get reason name
    if (p_reason_id is NOT NULL) then
      open  get_reason(c_reason_id => p_reason_id);
      fetch get_reason into p_reason_name;
      if (get_reason%NOTFOUND) then
        p_reason_name := NULL;
      end if;
      close get_reason;
    end if;

    -- get conversion rate
    p_conversion_rate :=
      inv_convert.inv_um_convert(
        item_id => p_inventory_item_id,
        precision => 38,
        from_quantity => 1,
        from_unit => p_from_uom,
        to_unit => p_to_uom,
        from_name => NULL,
        to_name => NULL);
  end post_query;




Procedure RPC_FAILURE_ROLLBACK(trx_header_id number,
			       cleanup_success in out nocopy boolean) IS
v_trx_header_id NUMBER ;

BEGIN
      cleanup_success := TRUE;
      v_trx_header_id := trx_header_id ;

      DECLARE
      -- Delete predefined serial numbers
      cursor c1 is select group_mark_id from
      mtl_serial_numbers
      where group_mark_id = v_trx_header_id
      and current_status = 6
      for update of group_mark_id nowait;
      BEGIN
      open c1 ;
       delete mtl_serial_numbers
       where group_mark_id = v_trx_header_id
       and current_status = 6;
      close c1 ;
      EXCEPTION
	WHEN OTHERS then
	  NULL;
      END ;

      DECLARE
      -- Unmark serial numbers
      cursor c2 is select group_mark_id from
      mtl_serial_numbers
      where group_mark_id = v_trx_header_id
      for update of group_mark_id nowait;
      BEGIN
      open c2 ;
       update mtl_serial_numbers
       set group_mark_id = null,
          line_mark_id = null,
          lot_line_mark_id = null
       where group_mark_id = v_trx_header_id;
      close c2 ;
      EXCEPTION
	WHEN OTHERS then
	  NULL;
      END ;

      DECLARE
      -- Delete lot and serial records from temp tables
      cursor c3 is select group_header_id from
      mtl_serial_numbers_temp
      where group_header_id = v_trx_header_id
      for update of group_header_id nowait;
      BEGIN
      open c3 ;
       delete mtl_serial_numbers_temp
       where group_header_id = v_trx_header_id;
      close c3 ;
      EXCEPTION
	WHEN OTHERS then
	  NULL;
      END ;

      DECLARE
      cursor c4 is select group_header_id from
      mtl_transaction_lots_temp
      where group_header_id = v_trx_header_id
      for update of group_header_id nowait;
      BEGIN
      open c4 ;
       delete mtl_transaction_lots_temp
       where group_header_id = v_trx_header_id;
      close c4 ;
      EXCEPTION
	WHEN OTHERS then
	  NULL;
      END ;

      delete mtl_material_transactions_temp
      where transaction_header_id = trx_header_id;
      commit;


      EXCEPTION
	WHEN NO_DATA_FOUND then
	  null;
	WHEN OTHERS then
	  cleanup_success := FALSE;
end rpc_failure_rollback;

Procedure lot_handling(hdr_id NUMBER, lot_success IN OUT nocopy VARCHAR2) IS
	completed                       NUMBER := 100;

    /** INVCONV Anand Thiyagarajan 02-Nov-2004 Start **/

    /* Jalaj Srivastava Bug 5527373
       varibales no longer needed are commented */

    --l_transaction_Action_id         mtl_material_transactions_temp.transaction_action_id%TYPE;
    --l_transaction_source_type_id    mtl_material_transactions_temp.transaction_source_type_id%TYPE;
    --l_origination_type              mtl_lot_numbers.origination_type%TYPE;
    --l_lot_rec_type                  mtl_lot_numbers%ROWTYPE;
    --l_organization_id               mtl_lot_numbers.organization_id%TYPE;
    --l_inventory_item_id             mtl_lot_numbers.inventory_item_id%TYPE;
    --l_transaction_date              DATE;
    --l_expiration_date               DATE;
    --l_return_status                 VARCHAR2(1)  ;
    --l_msg_data                      VARCHAR2(3000)  ;
    --l_msg_count                     NUMBER;


    /** INVCONV Anand Thiyagarajan 02-Nov-2004 End **/

BEGIN
if ( lot_success = 'FULL_LOT_PROCESSING' OR lot_success = 'KILL_ORPHANS' ) then
  BEGIN
    if ( (hdr_id IS NULL) OR (hdr_id < 0) ) then
      completed := 1;
    else
      BEGIN
      DELETE FROM mtl_transaction_lots_temp
      WHERE group_header_id = hdr_id AND
      transaction_temp_id NOT IN
      (SELECT mmtt.transaction_temp_id FROM
      mtl_material_transactions_temp mmtt
      WHERE mmtt.transaction_header_id = hdr_id AND mmtt.transaction_temp_id
      IS NOT NULL AND mmtt.transaction_header_id IS NOT NULL);


      DELETE FROM mtl_serial_numbers_temp
      WHERE group_header_id = hdr_id AND
      transaction_temp_id NOT IN
      (SELECT mmtt.transaction_temp_id  FROM
      mtl_material_transactions_temp mmtt
      WHERE mmtt.transaction_header_id = hdr_id AND mmtt.transaction_temp_id
      IS NOT NULL) AND transaction_temp_id NOT IN
      ( SELECT mtlt.serial_transaction_temp_id
        FROM mtl_transaction_lots_temp mtlt
        WHERE  mtlt.group_header_id = hdr_id
        AND mtlt.serial_transaction_temp_id IS NOT NULL);

      completed := 1;
      EXCEPTION
        WHEN OTHERS then
	 completed := -1 ;
      END;
    end if;
   END;
end if;
if ( (lot_success='FULL_LOT_PROCESSING' OR
      lot_success='MOVE_MMTT_LOTS_TO_MTLT') AND (completed > 0) ) then
  BEGIN
    if ( (hdr_id IS NULL) OR ( hdr_id < 0) ) then
      completed := 2;
    elsif ( completed > 0 ) then

    /** INVCONV Anand Thiyagarajan 02-Nov-2004 Start **/

    /* Jalaj Srivastava Bug 5527373
       commenting out the code below as
        1. there may not be lots in mmtt OR
        2. there will be multiple rows with different items
           in mmtt so we cannot pick up attributes of just one record */

    /* *************************************************************************************

        BEGIN
            select  mmtt.transaction_action_id, mmtt.transaction_source_type_id,
                    mmtt.organization_id, mmtt.inventory_item_id,
                    mmtt.transaction_date, mmtt.lot_expiration_date
            into    l_transaction_Action_id, l_transaction_source_type_id,
                    l_organization_id, l_inventory_item_id,
                    l_transaction_date, l_expiration_date
            from    mtl_material_transactions_temp mmtt
            where   mmtt.transaction_header_id = hdr_id
            AND     mmtt.lot_number IS NOT NULL
            AND     mmtt.transaction_header_id IS NOT NULL
	    AND	    rownum = 1;
        EXCEPTION
            when no_data_found then
                l_transaction_Action_id := null;
                l_transaction_source_type_id := null;
        END;

        IF l_transaction_source_type_id IN ('1','7') THEN
            l_origination_type := 3;
        ELSIF l_transaction_source_type_id IN ('13','6','12') THEN
            l_origination_type := 4;
        ELSIF l_transaction_source_type_id = '31' THEN
            l_origination_type := 1;
        END IF;

        l_lot_rec_type.organization_id := l_organization_id;
        l_lot_rec_type.inventory_item_id := l_inventory_item_id;
        l_lot_rec_type.origination_Date := l_transaction_date;
        l_lot_rec_type.expiration_Date := l_expiration_date;
        inv_lot_api_pkg.Set_Msi_Default_Attr    (
                                                  p_lot_rec           =>      l_lot_rec_type
                                                , x_return_status     =>      l_return_status
                                                , x_msg_count         =>      l_msg_count
                                                , x_msg_data          =>      l_msg_data
                                                ) ;
         IF l_return_status <> 'S' THEN
            fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
            if( l_msg_count > 1 ) then
               l_msg_data := fnd_msg_pub.get(l_msg_count, FND_API.G_FALSE);
            end if;
         END IF;
      *************************************************************************************************************** */

    /** INVCONV Anand Thiyagarajan 02-Nov-2004 End **/

     /* INSERT INTO MTL_TRANSACTION_LOTS_TEMP
      ( transaction_temp_id, last_update_date, last_updated_by, creation_date,
      created_by, last_update_login, request_id, program_application_id,
      program_id, program_update_date, transaction_quantity, primary_quantity,
      lot_number, lot_expiration_date, group_header_id,
      serial_transaction_temp_id, status_id)
      (select  mmtt.transaction_temp_id, mmtt.last_update_date,
      mmtt.last_updated_by, mmtt.creation_date,
      mmtt.created_by, mmtt.last_update_login, mmtt.request_id,
      mmtt.program_application_id,
      mmtt.program_id, mmtt.program_update_date,
      mmtt.transaction_quantity, mmtt.primary_quantity, mmtt.lot_number,
      mmtt.lot_expiration_date, mmtt.transaction_header_id,
      mmtt.transaction_temp_id, msi.default_lot_status_id
      FROM mtl_material_transactions_temp mmtt,
           mtl_system_items msi
      WHERE mmtt.transaction_header_id = hdr_id AND mmtt.lot_number IS
      NOT NULL AND mmtt.transaction_header_id IS NOT NULL
      AND msi.inventory_item_id = mmtt.inventory_item_id
      AND msi.organization_id = mmtt.organization_id) ; */


      INSERT INTO MTL_TRANSACTION_LOTS_TEMP
      ( transaction_temp_id, last_update_date, last_updated_by, creation_date,
      created_by, last_update_login, request_id, program_application_id,
      program_id, program_update_date, transaction_quantity, primary_quantity,
      lot_number, lot_expiration_date, group_header_id,
      serial_transaction_temp_id, status_id
      , lot_attribute_category
      , attribute_category
      , attribute1
      , attribute2
      , attribute3
      , attribute4
      , attribute5
      , attribute6
      , attribute7
      , attribute8
      , attribute9
      , attribute10
      , attribute11
      , attribute12
      , attribute13
      , attribute14
      , attribute15
      , c_attribute1
      , c_attribute2
      , c_attribute3
      , c_attribute4
      , c_attribute5
      , c_attribute6
      , c_attribute7
      , c_attribute8
      , c_attribute9
      , c_attribute10
      , c_attribute11
      , c_attribute12
      , c_attribute13
      , c_attribute14
      , c_attribute15
      , c_attribute16
      , c_attribute17
      , c_attribute18
      , c_attribute19
      , c_attribute20
      , n_attribute1
      , n_attribute2
      , n_attribute3
      , n_attribute4
      , n_attribute5
      , n_attribute6
      , n_attribute7
      , n_attribute8
      , n_attribute9
      , n_attribute10
      , d_attribute1
      , d_attribute2
      , d_attribute3
      , d_attribute4
      , d_attribute5
      , d_attribute6
      , d_attribute7
      , d_attribute8
      , d_attribute9
      , d_attribute10
      , grade_code
      , origination_date
      , date_code
      , change_date
      , age
      , retest_date
      , maturity_date
      , item_size
      , color
      , volume
      , volume_uom
      , place_of_origin
      , best_by_date
      , length
      , length_uom
      , recycled_content
      , thickness
      , thickness_uom
      , width
      , width_uom
      , territory_code
      , supplier_lot_number
      , vendor_name
/* INVCONV Anand Thiyagarajan 22-Oct-2004 Start */
      , secondary_quantity
      , parent_lot_number
      , origination_type
      , expiration_action_code
      , expiration_action_date
      , hold_date
      , reason_id
/* INVCONV Anand Thiyagarajan 22-Oct-2004 End */
      )
      (select  mmtt.transaction_temp_id, mmtt.last_update_date,
      mmtt.last_updated_by, mmtt.creation_date,
      mmtt.created_by, mmtt.last_update_login, mmtt.request_id,
      mmtt.program_application_id,
      mmtt.program_id, mmtt.program_update_date,
      mmtt.transaction_quantity, mmtt.primary_quantity, mmtt.lot_number,
      nvl(mmtt.lot_expiration_date,decode(msi.shelf_life_code,2,NVL(mln.origination_date, mmtt.transaction_date) + shelf_life_days,null)), /* Jalaj Srivastava Bug 5527373*/
      mmtt.transaction_header_id,
      mmtt.transaction_temp_id, NVL(mln.status_id, msi.default_lot_status_id)
      ,mln.lot_attribute_category
      ,mln.attribute_category
      ,mln.attribute1
      ,mln.attribute2
      ,mln.attribute3
      ,mln.attribute4
      ,mln.attribute5
      ,mln.attribute6
      ,mln.attribute7
      ,mln.attribute8
      ,mln.attribute9
      ,mln.attribute10
      ,mln.attribute11
      ,mln.attribute12
      ,mln.attribute13
      ,mln.attribute14
      ,mln.attribute15
      ,mln.c_attribute1
      ,mln.c_attribute2
      ,mln.c_attribute3
      ,mln.c_attribute4
      ,mln.c_attribute5
      ,mln.c_attribute6
      ,mln.c_attribute7
      ,mln.c_attribute8
      ,mln.c_attribute9
      ,mln.c_attribute10
      ,mln.c_attribute11
      ,mln.c_attribute12
      ,mln.c_attribute13
      ,mln.c_attribute14
      ,mln.c_attribute15
      ,mln.c_attribute16
      ,mln.c_attribute17
      ,mln.c_attribute18
      ,mln.c_attribute19
      ,mln.c_attribute20
      ,mln.n_attribute1
      ,mln.n_attribute2
      ,mln.n_attribute3
      ,mln.n_attribute4
      ,mln.n_attribute5
      ,mln.n_attribute6
      ,mln.n_attribute7
      ,mln.n_attribute8
      ,mln.n_attribute9
      ,mln.n_attribute10
      ,mln.d_attribute1
      ,mln.d_attribute2
      ,mln.d_attribute3
      ,mln.d_attribute4
      ,mln.d_attribute5
      ,mln.d_attribute6
      ,mln.d_attribute7
      ,mln.d_attribute8
      ,mln.d_attribute9
      ,mln.d_attribute10
      , nvl(mln.grade_code, decode(msi.grade_control_flag,'Y',msi.default_grade,null)) /* Jalaj Srivastava Bug 5527373*/ /* INVCONV Anand Thiyagarajan 22-Oct-2004 Start */
      , NVL(mln.origination_date, mmtt.transaction_date) /* Jalaj Srivastava Bug 5527373*/
      , mln.date_code
      , mln.change_date
      , mln.age
      , nvl(mln.retest_date, NVL(mln.origination_date, mmtt.transaction_date) + msi.retest_interval) /* Jalaj Srivastava Bug 5527373*/
      , nvl(mln.maturity_date, NVL(mln.origination_date, mmtt.transaction_date) + msi.maturity_days) /* Jalaj Srivastava Bug 5527373*/
      , mln.item_size
      , mln.color
      , mln.volume
      , mln.volume_uom
      , mln.place_of_origin
      , mln.best_by_date
      , mln.length
      , mln.length_uom
      , mln.recycled_content
      , mln.thickness
      , mln.thickness_uom
      , mln.width
      , mln.width_uom
      , mln.territory_code
      , mln.supplier_lot_number
      , mln.vendor_name
/* INVCONV Anand Thiyagarajan 22-Oct-2004 Start */
      , mmtt.secondary_transaction_quantity
      , mln.parent_lot_number
      , NVL(mln.origination_type, decode(mmtt.transaction_source_type_id,1,3,7,3,13,4,6,4,12,4,31,1,6)) /* Jalaj Srivastava Bug 5527373*/
      , NVL(mln.expiration_action_code, decode(msi.shelf_life_code,1,null,msi.expiration_action_code)) /* Jalaj Srivastava Bug 5527373*/
      , NVL(mln.expiration_action_date,
            decode(msi.shelf_life_code,1,null,nvl(mmtt.lot_expiration_date,
            decode(msi.shelf_life_code,2,NVL(mln.origination_date, mmtt.transaction_date) + shelf_life_days,null)) + msi.expiration_action_interval)) /* Jalaj Srivastava Bug 5527373*/
      , NVL(mln.hold_date, NVL(mln.origination_date, mmtt.transaction_date) + hold_days) /* Jalaj Srivastava Bug 5527373*/
      , mmtt.reason_id
/* INVCONV Anand Thiyagarajan 22-Oct-2004 End */
      FROM mtl_material_transactions_temp mmtt,
           mtl_system_items msi,
           mtl_lot_numbers mln
      WHERE mmtt.transaction_header_id = hdr_id AND mmtt.lot_number IS
      NOT NULL AND mmtt.transaction_header_id IS NOT NULL
      AND msi.inventory_item_id = mmtt.inventory_item_id
      AND msi.organization_id = mmtt.organization_id
      and mln.inventory_item_id(+) = mmtt.inventory_item_id
      and mln.organization_id(+) = mmtt.organization_id
      and mln.lot_number(+) =mmtt.lot_number);

      -- The  quantity in mtlt should always be positive
      UPDATE mtl_transaction_lots_temp
      SET    primary_quantity = -1 * primary_quantity ,
             transaction_quantity = -1 * transaction_quantity ,
             secondary_quantity = -1 * secondary_quantity /* INVCONV Anand Thiyagarajan 22-Oct-2004*/
      WHERE  transaction_temp_id in
             (select  mmtt.transaction_temp_id
             FROM mtl_material_transactions_temp mmtt
             WHERE mmtt.transaction_header_id = hdr_id AND mmtt.lot_number IS
             NOT NULL AND mmtt.transaction_header_id IS NOT NULL)
      AND    ( primary_quantity < 0 OR transaction_quantity < 0 OR secondary_quantity < 0); /* INVCONV Anand Thiyagarajan 22-Oct-2004 */

      completed := 2;
    end if;
    EXCEPTION WHEN OTHERS then
    completed := -2;
  END;

  BEGIN
    if ( ((hdr_id IS NULL) OR (hdr_id < 0 )) AND (completed > 0) ) then
      completed := 3;
    elsif ( completed > 0 ) then
      UPDATE mtl_material_transactions_temp
      SET lot_number = NULL, lot_expiration_date = NULL
      WHERE transaction_header_id = hdr_id AND process_flag = 'Y';
      completed := 3;
    end if;
    EXCEPTION WHEN OTHERS then
      completed := -3;
  END;
end if;
if ( ((lot_success = 'FULL_LOT_PROCESSING') AND (completed > 0 )) OR
     ( (lot_success = 'KILL_ORPHANS') AND (completed >0))  ) then
  BEGIN
  if ( ( hdr_id is NULL ) or (hdr_id < 0 )) then
    null;
    completed := 4;
  else
 -- Bug 4062450 performance change.
    DELETE /*+ INDEX(MSN MTL_SERIAL_NUMBERS_N2) */
    FROM mtl_serial_numbers MSN
    WHERE current_status = 6
    AND group_mark_id = -1
    AND (MSN.inventory_item_id, MSN.current_organization_id)  in
                (select inventory_item_id,ORGANIZATION_ID
                FROM mtl_material_transactions_temp
                WHERE transaction_header_id = hdr_id);
--2101601
    completed := 4 ;
  end if;
  EXCEPTION when others then
    completed := -4 ;
  END;
end if;
lot_success := to_char(completed) ;
end lot_handling;

end INVTTMTX;

/
