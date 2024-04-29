--------------------------------------------------------
--  DDL for Package Body WMS_EPC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_EPC_PVT" AS
/* $Header: WMSEPCVB.pls 120.22.12010000.4 2012/08/30 18:52:51 sahmahes ship $ */

--Global variable
g_cached_rule_pkg epc_rule_types_tbl;

-----------------------------------------------------
-- trace : TO log all message
-----------------------------------------------------
PROCEDURE trace(p_msg IN VARCHAR2) IS

   l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_trx_util_pub.trace(p_msg,'WMS_EPC_PVT', 9);
   END IF;
END trace;


FUNCTION bin2dec (binval in char) RETURN number IS
  i                 number;
  digits            number;
  result            number := 0;
  current_digit     char(1);
  current_digit_dec number;
BEGIN
  digits := length(binval);

  IF binval IS NOT NULL THEN
     for i in 1..digits loop
	current_digit := SUBSTR(binval, i, 1);
	current_digit_dec := to_number(current_digit);
	result := (result * 2) + current_digit_dec;
     end loop;
  END IF;
  return result;

END bin2dec;

FUNCTION dec2bin (N in number) RETURN varchar2 IS
  binval varchar2(260);
  N2     number := N;
BEGIN
   IF N IS NULL OR N = 0 THEN
      binval := '0';
    ELSE
      while ( N2 > 0 ) loop
	 binval := mod(N2, 2) || binval;
	 N2 := trunc( N2 / 2 );
      end loop;
   END IF;

   return binval;

END dec2bin;

FUNCTION oct2dec (octval in char) RETURN number IS
  i                 number;
  digits            number;
  result            number := 0;
  current_digit     char(1);
  current_digit_dec number;
BEGIN
  digits := length(octval);
  for i in 1..digits loop
     current_digit := SUBSTR(octval, i, 1);
     current_digit_dec := to_number(current_digit);
     result := (result * 8) + current_digit_dec;
  end loop;
  return result;
END oct2dec;

FUNCTION dec2oct (N in number) RETURN varchar2 IS
  octval varchar2(260);
  N2     number := N;
BEGIN
  while ( N2 > 0 ) loop
     octval := mod(N2, 8) || octval;
     N2 := trunc( N2 / 8 );
  end loop;
  return octval;
END dec2oct;

FUNCTION hex2dec (hexval in char) RETURN number IS
  i                 number;
  digits            number;
  result            number := 0;
  current_digit     char(1);
  current_digit_dec number;
BEGIN
   IF hexval IS NULL THEN
      RETURN 0;
    ELSE

      digits := length(hexval);
      for i in 1..digits loop
	 current_digit := SUBSTR(hexval, i, 1);
	 if current_digit in ('A','B','C','D','E','F') then
	    current_digit_dec := ascii(current_digit) - ascii('A') + 10;
	  else
	    current_digit_dec := to_number(current_digit);
	 end if;
	 result := (result * 16) + current_digit_dec;
      end loop;
      return result;
   END IF;

END hex2dec;


-- bug fix  4364965: appending extra 0 in the begining of HEX  result
FUNCTION dec2hex (N in number) RETURN varchar2 IS
  hexval varchar2(260);
  N2     number := N;
  digit  number;
  hexdigit  char;
BEGIN
   IF N > 0 THEN
      while ( N2 > 0 ) LOOP
	 hexdigit := SUBSTR('0123456789ABCDEF',MOD(N2,16)+1,1);
	 hexval := hexdigit || hexval;
	 N2 := trunc( N2 / 16 );
      end loop;

    ELSIF N = 0 THEN
      hexval := '0';
   END IF;

  return hexval;
END dec2hex;


--This API needs to move in the rules Engine code
--Purpose
-- Evaluate whether the LPN is standard
---Standard : Contains single Item
---Non-Standard : Contains multiple Items
FUNCTION is_lpn_standard(p_lpn_id NUMBER) RETURN NUMBER IS

   l_is_standard NUMBER;
   l_item_cnt NUMBER;
   l_parent_lpn_id NUMBER;
   l_outermost_lpn_id NUMBER;
   l_lpn_item_id NUMBER;
   l_uom_code VARCHAR2(3);
   l_rev VARCHAR2(3);
   l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   --to be called from the Rules Engine
   --Rules engine will look in to  WMS_label_requestes table to get thte
   --lpn_id AND pass  it TO this api.

  BEGIN
     SELECT  wlpn.parent_lpn_id, wlpn.outermost_lpn_id
       INTO l_parent_lpn_id, l_outermost_lpn_id
       FROM wms_license_plate_numbers wlpn
       WHERE wlpn.lpn_id = p_lpn_id;

  EXCEPTION
     WHEN no_data_found THEN

	IF l_debug = 1 THEN
	   trace('NO DATA found for the LPN');
	END IF;

	RETURN -1; --error CONDITION

  END;

  --{{ is the LPN pallet OR Case for Rule Engine call }}
  IF  (l_outermost_lpn_id = p_lpn_id AND l_parent_lpn_id IS null ) THEN--Pallet

       BEGIN

	  SELECT DISTINCT wlc.inventory_item_id,wlc.uom_code,wlc.revision,1
	    INTO l_lpn_item_id,l_uom_code,l_rev,l_is_standard
	    FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
	    WHERE wlpn.outermost_lpn_id = p_lpn_id
	    AND wlpn.lpn_id = wlc.parent_lpn_id
	    AND wlc.organization_id = wlpn.organization_id;

	  -- it must be Non-Standard  here if there are multiple records for item,
	  --uom_code,revision combination


       EXCEPTION
	  WHEN too_many_rows THEN
	     --MUITPLE ITEMS OR IN DIFFERETN UOMS OR Different Revision
	     --NON-STANDARD
	      l_is_standard := 0;

	  WHEN no_data_found THEN
	     --Error condition
	     l_is_standard := -1;

	  WHEN OTHERS THEN
	     l_is_standard := -1;
	     IF l_debug = 1 then
		trace('ERROR CODE = ' || SQLCODE);
		trace('ERROR MESSAGE = ' || SQLERRM);
	     END IF;

       END;

   ELSIF (l_parent_lpn_id = l_outermost_lpn_id AND l_parent_lpn_id IS NOT null) THEN --CASE
       BEGIN

	  --FROM RECEIVING SIDE THERE might be multiple records FOR same LPN FOR SAME ITEM

	  --Cases might have further NESTED LPNs inside it. all
	  --quantities must be accounted

	  /*
	  Tested with following data in WMSDV11I and it is working fine
	    4470-LPN2256A

	    --4429 -LPN2248A -wm661
	    -----4509 -LPN2260A - WM661

	    --4449 -LPN2254A -wm661

	    --4471 -LPN2257A -JALI100
	    -----4490 -LPN2259A - WM661
	    ---------4769 --LPN2290A - PUN100

	    LPN_ID : 4470 (4449 , 4429, 4471 )
	    4429( LPN2260A --4509) --same item
	    4471( LPN2259A --4490 (LPN2290A -4769 )) --different item


	    4584 --WM661
	    28816 --JALI100
	    25816 -- PUN100

	  */

	    --there might be more than one level of nesting in LPN but
	    --epc generation AND rfid tagging will be done only AT pallet and
	    --CASE label. so CASE might have nested lpns within it.

	    select  wlc.inventory_item_id,wlc.uom_code,wlc.revision,1
	    INTO l_lpn_item_id,l_uom_code,l_rev,l_is_standard
	    from WMS_LPN_CONTENTS WLC
	    where WLC.parent_lpn_id in (
					select wlpn.lpn_id
					from wms_license_plate_numbers wlpn
					WHERE WLPN.PARENT_LPN_ID is NOT NULL
					START WITH LPN_ID = p_lpn_id
					CONNECT BY WLPN.PARENT_LPN_ID = PRIOR LPN_ID)
		 GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;





       EXCEPTION
	  WHEN too_many_rows THEN
	     --MUITPLE ITEMS
	     --NON-STANDARD
	     l_is_standard := 0;

	  WHEN no_data_found THEN
	     --Error condition
	     l_is_standard := -1;

	  WHEN OTHERS THEN
	     l_is_standard := -1;
	     IF l_debug = 1 then
		trace('ERROR CODE = ' || SQLCODE);
		trace('ERROR MESSAGE = ' || SQLERRM);
	     END IF;

       END;

   ELSE --MORE THAN 1 LEVEL OF NESTING
	     RETURN -1;

  END IF;

  RETURN l_is_standard;


END is_lpn_standard;


  -- p_org_id,  p_item_id ,p_uom , p_rev_id
  -- are needed in this function because
  -- duplicate GTIN can be setup for different item
  -- in form and it is valid setup for business also

  FUNCTION get_serial_for_gtin(P_gtin NUMBER,
			       p_org_id NUMBER,
			       p_item_id NUMBER,
			       p_uom_code VARCHAR2,
			       p_rev_id NUMBER) RETURN NUMBER IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   l_cur_serial_num NUMBER;
   l_new_serial NUMBER := 0; --Just some random start value for a NEW GTIN
   l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- See if there are records in the table for this GTIN
   -- trace('P_gtin :'||p_gtin);


   --user can change the Serial in the Cross-ref form manually, but he will
   --be given warning..At the manual setup time he can assign any value or
   --leave it null

   BEGIN
      SELECT Nvl(epc_gtin_serial,0) INTO l_cur_serial_num
	FROM  mtl_cross_references_b
	WHERE CROSS_REFERENCE = To_char(p_gtin)
	AND cross_reference_type = G_PROFILE_GTIN
	AND inventory_item_id = p_item_id
	AND uom_code = p_uom_code
	AND nvl(revision_id, -99) = nvl(p_rev_id,-99);
   EXCEPTION
      WHEN no_data_found THEN
	 IF l_debug = 1 then
	   trace('no record for GTIN found');
	 END IF;
	 l_new_serial := NULL;
	 RETURN l_new_serial;
      WHEN OTHERS THEN
	 l_new_serial := NULL;
	 IF l_debug = 1 then
	    trace('ERROR CODE = ' || SQLCODE);
	    trace('ERROR MESSAGE = ' || SQLERRM);
	 END IF;
	 RETURN l_new_serial;
   END;

   --reset the serial number to next higer value based on the existing value
   l_new_serial := l_cur_serial_num+1;

   --update the table
   BEGIN

      UPDATE mtl_cross_references_b
	SET epc_gtin_serial = l_new_serial
	WHERE CROSS_REFERENCE = To_char(p_gtin)
	AND cross_reference_type = G_PROFILE_GTIN
	AND inventory_item_id = p_item_id
	AND uom_code = p_uom_code
	AND nvl(revision_id, -99) = nvl(p_rev_id,-99);

   EXCEPTION
      WHEN OTHERS THEN
	 l_new_serial := NULL;
	 IF l_debug = 1 then
	    trace('ERROR CODE = ' || SQLCODE);
	    trace('ERROR MESSAGE = ' || SQLERRM);
	 END IF;
	 RETURN l_new_serial;
   END;

   COMMIT;

   IF l_debug = 1 then
     trace('Returning new GTIN serial_num :'||l_new_serial);
   END IF;

   RETURN l_new_serial;

EXCEPTION

   WHEN OTHERS THEN

      IF l_debug = 1 then
	  trace('get_serial_for_gtin ERROR CODE = ' || SQLCODE);
	 trace('get_serial_for_gtin ERROR MESSAGE = ' || SQLERRM);
      END IF;
  END get_serial_for_gtin;



  --Get GTIN and GTIN-Serial
  --given item + org + total_qty + Revision

  PROCEDURE get_gtin_and_gserial(p_org_id      IN NUMBER,
				 p_item_id     IN NUMBER,
				 p_total_qty   IN NUMBER,
				 p_rev         IN VARCHAR2 ,
				 p_primary_uom IN VARCHAR2,
				 x_gtin          OUT nocopy NUMBER,
				 x_gtin_serial   OUT nocopy NUMBER,
				 x_return_status OUT nocopy VARCHAR2)
    IS

       CURSOR c_mtl_uom IS
	  SELECT uom_code FROM mtl_uom_conversions_view mucv
	    WHERE mucv.inventory_item_id = p_item_id
	    AND mucv.organization_id = p_org_id
	    AND mucv.conversion_rate = p_total_qty
	    AND Nvl(mucv.uom_code,'@@@') = Nvl(p_primary_uom,Nvl(mucv.uom_code,'@@@'));

       l_uom_code    VARCHAR2(3);
       l_found_gtin  NUMBER;
       l_gtin   NUMBER;
       l_rev_id NUMBER;
       l_debug  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF l_debug = 1 THEN
      trace(' Inside get_gtin_and_gserial');
      trace('p_org_id :'||p_org_id ||','||'p_item_id :'||p_item_id);
      trace('p_total_qty :'||p_total_qty||','||'p_rev :'||p_rev);
      trace('p_primary_uom :' || p_primary_uom);
      trace('G_PROFILE_GTIN :'|| g_profile_gtin );
   END IF;


   IF p_rev IS NOT NULL then
      -- open c_gtin_crossref_rev cursor
      --l_lpn_item_id,L_REV,p_org_id,l_total_qty,l_gtin_crossref_rev.UOM_CODE


      FOR l_mtl_uom IN c_mtl_uom LOOP
	 IF l_debug = 1 THEN
	    trace(' REV NOT NULL- UOM Code :'|| l_mtl_uom.UOM_CODE);
	 END IF;

      BEGIN
	 SELECT 1, To_number(mcr.cross_reference),mirb.revision_id INTO
	   l_found_gtin,l_gtin,l_rev_id
	   FROM mtl_cross_references MCR, mtl_item_revisions_b mirb --USING base TABLE FOR PERFORMANCE
	   WHERE mcr.cross_reference_type = G_PROFILE_GTIN
	   AND mcr.inventory_item_id = p_item_id
	   AND mcr.uom_code = l_mtl_uom.UOM_CODE
	   AND mcr.inventory_item_id = mirb.inventory_item_id
	   AND MIRB.revision = p_rev
	   AND mirb.revision_id = mcr.REVISION_ID
	   AND (( mcr.org_independent_flag = 'Y' AND
		  mcr.organization_id IS NULL AND
		  MIRB.organization_id = p_org_id) OR
		(mcr.org_independent_flag = 'N' AND
		 mcr.organization_id = p_org_id AND
		 mcr.organization_id = mirb.organization_id))
		    AND ROWNUM < 2;

      EXCEPTION
	 WHEN no_data_found THEN
	    l_found_gtin := 0;
	    --Do not raise exception here

	 WHEN OTHERS THEN
	    l_found_gtin := 0;
	    RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF l_found_gtin = 1 THEN	       --FOUND GTIN
	 --overwrite the value l_uom_code for GTIN setup
	 l_uom_code := l_mtl_uom.uom_code;
	 EXIT; --EXIT THE LOOP
      END IF;

      END LOOP;


    ELSE --means p_rev IS NULL

	    -- open c_mtl_uom cursor

	    FOR l_mtl_uom IN c_mtl_uom LOOP

	       IF l_debug = 1 THEN
		  trace(' REV NULL- UOM Code :'|| l_mtl_uom.UOM_CODE);
	       END IF;

	    BEGIN
	       SELECT 1, To_number(mcr.cross_reference) INTO
		 l_found_gtin,l_gtin
		 FROM mtl_cross_references MCR
		 WHERE mcr.cross_reference_type = G_PROFILE_GTIN
		 AND mcr.inventory_item_id = p_item_id
		 AND MCR.revision_id is NULL
		   AND mcr.uom_code = l_mtl_uom.UOM_CODE
		   AND (( mcr.org_independent_flag = 'Y' AND mcr.organization_id IS NULL)
			OR (mcr.org_independent_flag = 'N' AND mcr.organization_id = p_org_id))
		     AND ROWNUM<2;

		   l_rev_id := NULL ;

	    EXCEPTION
	       WHEN no_data_found THEN
		  l_found_gtin := 0;
		  --Do not raise exception here

	       WHEN OTHERS THEN
		  l_found_gtin := 0;
		  RAISE fnd_api.g_exc_unexpected_error;

	    END;

	    IF l_debug = 1 then
	       trace('l_found_gtin :' ||l_found_gtin);
	    END IF ;

	    IF l_found_gtin = 1 THEN --FOUND GTIN
	       --overwrite the value l_uom_code for GTIN setup
	       l_uom_code := l_mtl_uom.uom_code;
	       EXIT; --EXIT THE LOOP
	    END IF;

	    END LOOP;

   END IF;-- p_rev IS NULL


   IF l_debug = 1 then
      trace('l_found_gtin :'||l_found_gtin);
   END IF ;



   IF l_found_gtin = 1 THEN

      --PUT VERIFICATION FOR 14 Digit GTIN

      IF Length(To_char(l_gtin)) <> 14 THEN

	 IF l_debug = 1 then
	    trace('Error gtin not 14 digit ');
	 END IF ;

	 fnd_message.set_name('WMS', 'WMS_INVALID_GTIN');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

    ELSIF l_found_gtin = 0 THEN

      fnd_message.set_name('WMS', 'WMS_INVALID_GTIN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

   END IF;


   IF l_debug = 1 then
      trace('Final l_gtin :'||l_gtin );
   END IF ;


   --now get the GTIN-serial
   --we could not do it as a part of above query along with GTIN
   --becasue the call to FUNCTION will unnecessary update the
   --serial number for GTIN

   IF l_gtin IS NOT NULL THEN
      --Finally generated GTIN SUCCESS
      x_gtin := l_gtin;

      --Get GTIN-serial for the GTIN now
      x_gtin_serial := get_serial_for_gtin(l_gtin, p_org_id, p_item_id, l_uom_code,l_rev_id);


      IF x_gtin_serial IS NULL THEN
	 fnd_message.set_name('WMS', 'WMS_INVALID_GTIN_GSERIAL');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;

      END IF;

    ELSE
      fnd_message.set_name('WMS', 'WMS_NO_GTIN_FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE; -- to raised to the outer call

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE; -- to raised to the outer call

   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_gtin_and_gserial()');
	 trace('ERROR CODE = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;

END get_gtin_and_gserial;


--Get GTIN and GTIN-Serial for LPN
procedure get_lpn_gtin_serial(p_lpn_id IN	NUMBER,
			  p_org_id IN  NUMBER,
			  p_filter_value IN NUMBER,
			  p_business_flow_code IN NUMBER,
			  x_gtin          OUT nocopy NUMBER,
			  x_gtin_serial   OUT nocopy VARCHAR2,
			  x_return_status OUT nocopy VARCHAR2)
  IS


     l_lpn_item_id NUMBER;
     l_total_qty NUMBER :=0;
     l_found_gtin NUMBER := 0;
     l_rev VARCHAR2(3);
     l_uom_code VARCHAR2(3);
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_gtin NUMBER;
     l_is_gtin_valid BOOLEAN := TRUE;

     l_total_wlc_qty NUMBER;
     l_total_mmtt_qty NUMBER;
     l_total_mmtt_qty1 NUMBER;
     l_total_mmtt_qty2 NUMBER;
     l_rev_id NUMBER;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_debug = 1 then
      trace('Inside get_lpn_gtin_serial p_business_flow_code :'|| p_business_flow_code);
   END IF;


   --1. See if has single item or multiple items
   --2. See how much quantity of the item is there in pallet/case


   /* p_business_flow_code = inv_label.wms_bf_wip_pick_load --VALUE 28  is not
    needed for components only WIP completion is needed
    p_business_flow_code = inv_label.wms_bf_replenishment_load)--VALUE 34    --Not  Needed */


   IF   (p_business_flow_code = inv_label.wms_bf_pick_load) THEN   --VALUE 18

      --GET FOLLOWING VALUES
      --TOTAL quantity IN LPN,inventory_item_id,TXN.uom_code,TXN.revision
      --	INTO l_total_qty, l_lpn_item_id,L_rev

      --Get values from mmtt pending records, which is either loaded
      -- previously OR it iS curently bening loaded
      --  While loading process, MMTT record is the source of truth for
      -- NVL(transfer_LPN_id,content_lpn_id)
      --Event if te entire LPN is picked, MMTT.qty will have the total qty of
      --picking LPN. Since going against MMTT qty, I do not have to worry
      --about the level of nesting to-be-picked LPN

      BEGIN
	 SELECT DISTINCT mmtt.inventory_item_id, SUM(mmtt.primary_quantity), mmtt.revision
	   INTO l_lpn_item_id,l_total_qty,l_rev
	   FROM mtl_material_transactions_temp mmtt,
	   wms_license_plate_numbers wlpn
	   WHERE Nvl(mmtt.transfer_lpn_id,mmtt.content_lpn_id) = p_lpn_id
	   AND mmtt.organization_id = p_org_id
	   AND wlpn.lpn_id = Nvl(mmtt.transfer_lpn_id,mmtt.content_lpn_id)
	   AND wlpn.lpn_context = wms_container_pub.LPN_CONTEXT_PACKING
	   GROUP BY mmtt.inventory_item_id,mmtt.transaction_uom, mmtt.revision;
	 --All GTINS (transaction_uom) have to different in an LPN for SGTIN EPC generation rule

      EXCEPTION
	 WHEN too_many_rows THEN
	    l_is_gtin_valid := FALSE;
	    IF l_debug = 1 THEN
	       trace('too_many_rows ERROR for wms_bf_pick_load');
	    END IF;


	 WHEN no_data_found THEN
	    l_is_gtin_valid := FALSE;
	    IF l_debug = 1 THEN
	       trace('no_data_found ERROR for wms_bf_pick_load');
	    END IF;

	 WHEN OTHERS THEN
	    IF l_debug = 1 THEN
	       trace('unexpected error for wms_bf_pick_load');
	    END IF;
	    RAISE fnd_api.g_exc_unexpected_error;

      END;

      IF l_debug = 1 then
	 trace('Bus PKLD l_total_qty,l_REV,l_lpn_item_id::'||l_total_qty||':'||l_rev||':'||l_lpn_item_id);
      END IF;



    ELSIF p_business_flow_code = inv_label.WMS_BF_CARTONIZATION THEN	--VALUE 22

	    IF l_debug = 1 then
	       trace('Inside cartonization');
	    END IF;
	    --FIRST TEST PICK RELEASE CARTONIZATION AND THEN LOOK FOR BULK
	    --pack CARTONIZATION. Pick Release Performance is important
	    --PR cartonization and Bulk Pack - both are mutually exclusive cases.
	    -- Both have same business flow -22


	    --Pick Release cartonization
       BEGIN
	  SELECT mmtt.inventory_item_id, SUM(mmtt.primary_quantity), mmtt.revision
	    INTO l_lpn_item_id,l_total_qty,l_rev
	    FROM mtl_material_transactions_temp mmtt
	    WHERE mmtt.cartonization_id = p_lpn_id
	    AND  mmtt.cartonization_id IS NOT NULL
	    AND mmtt.organization_id = p_org_id
	    GROUP BY mmtt.inventory_item_id,mmtt.transaction_uom, mmtt.revision;
	    --All GTINS (transaction_uom) have to different in an LPN for SGTIN EPC generation rule

       EXCEPTION
	  WHEN too_many_rows THEN
	     l_is_gtin_valid := FALSE;
	     IF l_debug = 1 THEN
		trace('too_many_rows ERROR for Pick Release cartonization');
	     END IF;

	  WHEN no_data_found THEN
	     l_total_qty := 0;
	     --Do not put  l_is_gtin_valid := FALSE HERE
	     IF l_debug = 1 THEN
		trace('no_data_found ERROR for Pick Release cartonization');
	     END IF;

	  WHEN OTHERS THEN
	     IF l_debug = 1 THEN
		trace('unexpected error for Pick Release cartonization');
	     END IF;
	     RAISE fnd_api.g_exc_unexpected_error;

       END;

       IF l_debug = 1 then
	  trace('After PR cartonization l_total_qty,l_REV,l_lpn_item_id::'||l_total_qty||':'||l_rev||':'||l_lpn_item_id);
       END IF;

       --Bulk Pack Cartonization

       IF l_is_gtin_valid = TRUE AND l_total_qty = 0 THEN
	  --means this is FOR bulk pack cartonization ..no mmtt record

	  IF p_filter_value = wms_epc_pallet_obj_type THEN --pallet

             BEGIN

		SELECT SUM(wlc.primary_quantity),wlc.inventory_item_id,wlc.uom_code,wlc.revision --UOM CODE TO AVOID FUTURE
		  --support OF HAVING multiple lines FOR same lpn based ON ui UOM
		  --IT SHOULD FAIL TO USE GTIN FOR EPC GENERATION FOR MULTIPLE GTIN IN LPN
		  INTO l_total_qty, l_lpn_item_id, l_uom_code,L_rev
		  FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
		  WHERE wlpn.outermost_lpn_id = p_lpn_id
		  AND wlpn.lpn_id = wlc.parent_lpn_id
		  AND wlc.organization_id = p_org_id
		  AND wlc.organization_id = wlpn.organization_id
		  GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;
		-- it must fail here if there are multiple records for item,
		--uom_code,revision combination

	     EXCEPTION
		WHEN too_many_rows THEN
		   l_is_gtin_valid := FALSE;
		   IF l_debug = 1 THEN
		      trace('Pallet too_many_rows ERROR for Bulk Pack cartonization');
		   END IF;
		WHEN no_data_found THEN
		   l_is_gtin_valid := FALSE;
		   IF l_debug = 1 THEN
		      trace('Pallet No_data_found ERROR for Bulk Pack cartonization');
		   END IF;

		WHEN OTHERS THEN
		   IF l_debug = 1 THEN
		      trace('Pallet unexpected error for Pick Release cartonization');
		   END IF;
		   RAISE fnd_api.g_exc_unexpected_error;

	     END;


	     ELSIF p_filter_value = WMS_EPC_CASE_OBJ_TYPE THEN --case

             BEGIN
		--1. UOM CODE TO AVOID failure due to FUTURE
		--support OF HAVING multiple lines FOR same lpn based ON ui UOM
		--IT SHOULD FAIL TO USE GTIN FOR EPC GENERATION FOR MULTIPLE
		--GTIN IN LPN
		--2. FROM RECEIVING SIDE THERE
		--might be multiple records FOR same LPN FOR SAME ITEM

		--Cases might have further NESTED LPNs inside it. all
		--quantities must be accounted


		SELECT SUM(wlc.primary_quantity),wlc.inventory_item_id,wlc.uom_code,wlc.revision
		  INTO l_total_qty,l_lpn_item_id,l_uom_code,l_rev
		  FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn1, wms_license_plate_numbers wlpn2
		  WHERE wlpn1.lpn_id = p_lpn_id
		  and wlpn1.parent_lpn_id = wlpn2.outermost_lpn_id
		  AND wlpn2.lpn_id = wlc.parent_lpn_id
		  AND wlpn2.lpn_id <> wlpn1.parent_lpn_id --to avoid content of Pallet
		  AND wlc.organization_id = p_org_id
		  aND wlc.organization_id = wlpn1.organization_id
		  and wlc.organization_id = wlpn2.organization_id
		  GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;

	     EXCEPTION
		WHEN too_many_rows THEN
		   l_is_gtin_valid := FALSE;
		   IF l_debug = 1 THEN
		      trace('Case too_many_rows ERROR for Bulk Pack cartonization');
		   END IF;
		WHEN no_data_found THEN
		   l_is_gtin_valid := FALSE;
		   IF l_debug = 1 THEN
		      trace('Case No_data_found ERROR for Bulk Pack cartonization');
		   END IF;

		WHEN OTHERS THEN
		   IF l_debug = 1 THEN
		      trace('Case unexpected error for Pick Release cartonization');
		   END IF;
		   RAISE fnd_api.g_exc_unexpected_error;

	     END;

	    END IF;


       END IF; --for bulk pack cartonization


       IF l_debug = 1 then
	 trace('After BULK PACK cartonization l_total_qty,l_REV,l_lpn_item_id::'||l_total_qty||':'||l_rev||':'||l_lpn_item_id);
      END IF;

    ELSIF (p_business_flow_code = inv_label.WMS_BF_WIP_COMPLETION OR --VALUE 26
	   p_business_flow_code = inv_label.WMS_BF_FLOW_WORK_ASSEMBLY )
      THEN --VALUE 33

	    -- While WIP completion, Nesting of LPN with context of "Reside in
	    -- WIP" is not possible. So there can not be assembly in the
	    --nested lpn . PACKUNPACK IS CALLED DIRECTLY BEFORE CALLING LABEL
	    --printing . so All assembly quantity will be available in WLC
	    --for the same LPN for CURRENT MMTT and previous WIP
	    --completions IN this LPN

	    --Get current MMTT qty for the assembly

	    -- MMTT RECORD IS processed each time (NOT through inv tm rather it IS
	    -- used manually IN wip code, mmtt acts AS a placeholder)

	    --Get current WLC qty for the assembly

      BEGIN
	 SELECT DISTINCT wlc.inventory_item_id, SUM(wlc.primary_quantity),wlc.uom_code,wlc.revision
	   INTO l_lpn_item_id,l_total_qty,l_uom_code,l_rev
	   FROM wms_license_plate_numbers wlpn,
	   wms_lpn_contents wlc
	   WHERE wlc.parent_lpn_id = p_lpn_id
	   AND wlc.organization_id =  p_org_id
	   AND wlpn.lpn_id = wlc.parent_lpn_id
	   AND wlpn.LPN_CONTEXT = wms_container_pub.LPN_CONTEXT_WIP
	   AND wlc.organization_id = wlpn.organization_id
	   GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;
	   --this code will be invoked for Picking business flow only and a
	   --physical lpn can have only one status at a time..that will be
	   --"Picking here" because query is based on p_lpn_id


      EXCEPTION
	 WHEN too_many_rows THEN
	    l_is_gtin_valid := FALSE;
	    IF l_debug = 1 THEN
	       trace('WIP too_many_rows ERROR for Bulk Pack cartonization');
	    END IF;
	 WHEN no_data_found THEN
	    l_is_gtin_valid := FALSE;
	    IF l_debug = 1 THEN
	       trace('WIP No_data_found ERROR for Bulk Pack cartonization');
	    END IF;

	 WHEN OTHERS THEN
	    IF l_debug = 1 THEN
	       trace('WIP unexpected error for Pick Release cartonization');
	    END IF;
	    RAISE fnd_api.g_exc_unexpected_error;

      END;

      IF l_debug = 1 then
	 trace('WIP l_total_qty,l_REV,l_lpn_item_id::'||l_total_qty||':'||l_rev||':'||l_lpn_item_id);
      END IF;


    ELSE --FOR ALL OTHER BUSINESS FLOW

	    IF l_debug = 1 THEN
	       trace('for all other buiness flow');
	    END IF;

	    IF p_filter_value = wms_epc_pallet_obj_type THEN --pallet

             BEGIN

		IF l_debug = 1 THEN
		   trace('for wms_epc_pallet_obj_type');
		END IF;

		SELECT SUM(wlc.primary_quantity),wlc.inventory_item_id,wlc.uom_code,wlc.revision --UOM CODE TO AVOID FUTURE
		  --support OF HAVING multiple lines FOR same lpn based ON ui UOM
		  --IT SHOULD FAIL TO USE GTIN FOR EPC GENERATION FOR MULTIPLE GTIN IN LPN
		  INTO l_total_qty, l_lpn_item_id, l_uom_code,L_rev
		  FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
		  WHERE wlpn.outermost_lpn_id = p_lpn_id
		  AND wlpn.lpn_id = wlc.parent_lpn_id
		  AND wlc.organization_id = p_org_id
		  AND wlc.organization_id = wlpn.organization_id
		  GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;
		-- it must fail here if there are multiple records for item,
		--uom_code,revision combination

	     EXCEPTION
		WHEN too_many_rows THEN
		   l_is_gtin_valid := FALSE;

		WHEN no_data_found THEN
		   l_is_gtin_valid := FALSE;

		WHEN OTHERS THEN
		   RAISE fnd_api.g_exc_unexpected_error;
	     END;


	     ELSIF p_filter_value = WMS_EPC_CASE_OBJ_TYPE THEN --case

		   IF l_debug = 1 THEN
		      trace('for WMS_EPC_CASE_OBJ_TYPE');
		   END IF;

             BEGIN
		--1. UOM CODE TO AVOID failure due to FUTURE
		--support OF HAVING multiple lines FOR same lpn based ON ui UOM
		--IT SHOULD FAIL TO USE GTIN FOR EPC GENERATION FOR MULTIPLE
		--GTIN IN LPN
		--2. FROM RECEIVING SIDE THERE
		--might be multiple records FOR same LPN FOR SAME ITEM

		--Cases might have further NESTED LPNs inside it. all
		--quantities must be accounted

		--tested in logutr12 with case lpn_id=25341 (LPN2148A) --SOLUTION OF BUG 4355961

		select  sum(wlc.primary_quantity), wlc.inventory_item_id,wlc.uom_code, WLC.revision
		  INTO l_total_qty, l_lpn_item_id, l_uom_code,l_rev
		  from WMS_LPN_CONTENTS WLC
		  where WLC.parent_lpn_id in (
					      select wlpn.lpn_id
					      from wms_license_plate_numbers wlpn
					      where WLPN.PARENT_LPN_ID is NOT NULL
					      START WITH LPN_ID = p_lpn_id
					      CONNECT BY WLPN.PARENT_LPN_ID = PRIOR LPN_ID)
				GROUP BY WLC.inventory_item_id,wlc.uom_code,wlc.revision;

	     EXCEPTION
		WHEN too_many_rows THEN
		   l_is_gtin_valid := FALSE;

		WHEN no_data_found THEN
		   l_is_gtin_valid := FALSE;

		WHEN OTHERS THEN
		   RAISE fnd_api.g_exc_unexpected_error;

	     END;

	    END IF;

   END IF; --For business Flows



  --3. look for gtin cross refernece set up for that item

  --4. Find if any gtin UOM has corresponding UOM conversion defined for
  --   quantity, pick that GTIN

   IF l_debug = 1 then
      trace('l_total_qty,l_REV,l_lpn_item_id::'||l_total_qty||':'||l_rev||':'||l_lpn_item_id);
      IF l_is_gtin_valid = TRUE then
	 trace(' l_is_gtin_valid IS TRUE');
       ELSIF  l_is_gtin_valid = FALSE THEN
         trace(' l_is_gtin_valid IS FALSE');
       ELSE
	 trace(' l_is_gtin_valid IS NULL');
      END IF;
   END IF;


   IF l_is_gtin_valid THEN

      --get GTIN and GTIN-Serial now
      get_gtin_and_gserial(p_org_id        => p_org_id,
			   p_item_id       => l_lpn_item_id,
			   p_total_qty     => l_total_qty,
			   p_rev           => l_rev,
			   p_primary_uom   => NULL,
			   x_gtin          => x_gtin,
			   x_gtin_serial   => x_gtin_serial,
			   x_return_status => x_return_status);

    ELSE

      fnd_message.set_name('WMS', 'WMS_NO_GTIN_FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

   END IF;--if l_is_gtin_valid



EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin_serial := NULL;
      x_gtin := NULL;
      RAISE;
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_LPN_gtin_serial()');
	 trace('ERROR CODE = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;

END get_lpn_gtin_serial;


procedure get_item_gtin_serial(p_item_id  IN      NUMBER,
			       p_org_id   IN      NUMBER,
			       p_qty      IN      NUMBER,
			       p_uom_code IN      VARCHAR2,
			       p_rev      IN      VARCHAR2,
			       x_gtin          OUT nocopy NUMBER,
			       x_gtin_serial   OUT nocopy VARCHAR2,
			       x_return_status OUT nocopy VARCHAR2)
  IS

       l_gtin NUMBER;
       l_rev_id NUMBER;
       l_pri_qty NUMBER;
       l_found_gtin NUMBER;
       l_uom_code VARCHAR2(3);
       l_primary_uom_code VARCHAR2(3);
       l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   -- if p_uom_code is NOT primary UOM, get primary qty in primary UOM
   -- For the primary qty, get the corresponding UOM conversion

   IF l_debug = 1 then
      trace(' Inside get_ITEM_gtin_SERIAL');
   END IF;

   /*
   May 2005 :- Question:  if I get request for 5 DZ.
     1- Does it mean that the Dz uom is good and I find the GTIN in the cross-ref for the Dz uom.
     OR
     2- Get primary qty=60 (12x5) and get UOM_code for conversion factor of 60 (may be DZ5) and then find GTIN fir this new UOM.

     Answer: Use Number 2 approach above.

 August 2005 :- Decision changed: We need  to print EPC for GTIN
     corresponding to DZ

     */


     --If p_uom is not primary UOM code then convert it to the primary UOM
     --AND primary_qty and

    IF ( inv_cache.set_item_rec(
           p_organization_id => p_org_id
         , p_item_id         => p_item_id ) )
    THEN
      IF (l_debug = 1) THEN
        trace('Got Item info puom='||inv_cache.item_rec.primary_uom_code);

      END IF;
    ELSE
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;


   IF (p_uom_code <> inv_cache.item_rec.primary_uom_code) THEN
      l_pri_qty :=
	inv_convert.inv_um_convert(item_id        => p_item_id
				   ,precision     => 5
				   ,from_quantity => 1 --p_qty, get the prim qty FOR UOM
				   ,from_unit     => p_uom_code
				   ,to_unit       => inv_cache.item_rec.primary_uom_code
				   ,from_name     => NULL
				   ,to_name       => NULL);
    ELSE

      l_pri_qty := p_qty;

   END IF;

   IF l_debug = 1 then
      trace('for each GTIN l_pri_qty :'||l_pri_qty);
      trace('l_primary_uom_code :'||inv_cache.item_rec.primary_uom_code);
      trace('p_rev              :'||p_rev);
   END IF;


   -- find the "conversion_uom" for the total primary qty, done with cursor c_mtl_uom

   -- See if the conversion UOM obtained above is defined in the
   -- cross-reference table


   --get GTIN and GTIN-Serial now for the item
   get_gtin_and_gserial(p_org_id        => p_org_id,
			p_item_id       => p_item_id,
			p_total_qty     => l_pri_qty,
			p_rev           => p_rev,
			p_primary_uom   => p_uom_code,
			x_gtin          => x_gtin,
			x_gtin_serial   => x_gtin_serial,
			x_return_status => x_return_status);


   IF l_debug = 1 then
      trace('x_gtin         :'||x_gtin );
      trace('x_gtin_serial  :'|| x_gtin_serial);
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin_serial := NULL;
      x_gtin := NULL;
      RAISE;
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_item_gtin_serial()');
	 trace('ERROR CODE    = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;

END get_item_gtin_serial ;



procedure get_serialnum_gtin_serial(p_item_id  IN      NUMBER,
			       p_org_id   IN      NUMBER,
			       p_rev      IN      VARCHAR2,
			       x_gtin          OUT nocopy NUMBER,
			       x_gtin_serial   OUT nocopy VARCHAR2,
			       x_return_status OUT nocopy VARCHAR2)
  IS


     l_gtin NUMBER;
     l_rev_id NUMBER;
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;


     --GET THE PRIMARY  UOM code FOR SERIAL ITEM
    IF ( inv_cache.set_item_rec(
           p_organization_id => p_org_id
         , p_item_id         => p_item_id ) )
    THEN
      IF (l_debug = 1) THEN
        trace('Got Item info puom='||inv_cache.item_rec.primary_uom_code);
      END IF;
    ELSE
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;


     -- See if the PRIMARY UOM obtained above is defined in the cross-reference table
     --GET THE CORRESPONDING GTIN


    --get GTIN and GTIN-Serial now
    get_gtin_and_gserial(p_org_id        => p_org_id,
			 p_item_id       => p_item_id,
			 p_total_qty     => 1, --Always = 1 since primary UOM
			 p_rev           => p_rev,
			 p_primary_uom   => inv_cache.item_rec.primary_uom_code,
			 x_gtin          => x_gtin,
			 x_gtin_serial   => x_gtin_serial,
			 x_return_status => x_return_status);


    IF l_debug = 1 then
       trace('x_gtin         :'||x_gtin );
       trace('x_gtin_serial  :'|| x_gtin_serial);
    END IF;



EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin_serial := NULL;
      x_gtin := NULL;
      RAISE;
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_serialnum_gtin_seria()');
	 trace('ERROR CODE    = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin := NULL;
      x_gtin_serial := NULL;
      RAISE;

END get_serialnum_gtin_serial ;


--get SSCC for give LPN_id
FUNCTION get_sscc(p_lpn_id NUMBER,
		  p_org_id NUMBER) RETURN NUMBER
  IS

     l_is_sscc_valid BOOLEAN;
     l_sscc VARCHAR2(30);
     l_sscc_len NUMBER;
     l_lpn_num_format NUMBER;
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF l_debug = 1 then
      trace('get_ssc() p_lpn_id,p_org_id :'||p_lpn_id ||','||p_org_id);
   END IF;

   --See if SSCC can be used
   --make sure numeric only
   SELECT license_plate_number INTO l_sscc FROM wms_license_plate_numbers
     WHERE lpn_id =  p_lpn_id
     AND organization_id = p_org_id;

   BEGIN
      l_sscc_len := Length(l_sscc);

      IF l_sscc_len = 18 THEN

	 l_lpn_num_format := To_number(l_sscc);--ensure Numeric Only

       ELSE
	 l_lpn_num_format := NULL;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SSCC');
	 FND_MSG_PUB.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN --catch the exception for alphanumeric case
	 l_lpn_num_format := NULL;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SSCC');
	 FND_MSG_PUB.ADD;
	 trace('Other Exception in get_sscc()');
	 RAISE fnd_api.g_exc_error;
   END;

   RETURN l_lpn_num_format;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      RAISE;

   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_sscc()');
	 trace('ERROR CODE    = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      RAISE;

END get_sscc;


  --This API will be called while importing ASNs
  --Purpose
  -- Create Cross-reference in WMS_EPC TABLE
  --between EPC and objects from interface tables

  PROCEDURE populate_outside_epc
    (p_group_id IN NUMBER ,      --obtained from WMS_EPC_S2.nextval by calling API
     p_cross_ref_type IN NUMBER, --1: LPN-EPC , 2: ITEM_SERIAL-EPC , 3: GTIN-EPC
     p_Lpn_id         IN NUMBER DEFAULT NULL, --for p_cross_ref_type =1 only
     p_ITEM_ID        IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 2 only
     p_SERIAL_NUMBER  VARCHAR2  DEFAULT NULL, --for p_cross_ref_type = 2 only
     p_GTIN           IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 3 , for future
     p_GTIN_SERIAL    IN NUMBER DEFAULT NULL, --for p_cross_ref_type = 3 , for future
     p_EPC            IN VARCHAR2,
     x_return_status  OUT nocopy VARCHAR2,
     x_return_mesg    OUT nocopy VARCHAR2
     ) IS

	l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF l_debug = 1 THEN
	trace('p_group_id :'||p_group_id ||' ,'||'p_cross_ref_type :'||p_cross_ref_type);
	trace('p_Lpn_id :'||p_lpn_id);
	trace('p_ITEM_ID :'||p_item_id||' ,'||'p_SERIAL_NUMBER :'||p_SERIAL_NUMBER);
	trace('p_EPC :'||p_epc);
     END IF;

     IF p_group_id IS NULL OR p_cross_ref_type IS NULL OR p_epc IS NULL THEN
	x_return_status := fnd_api.g_ret_sts_error;
	x_return_mesg := fnd_message.get_string('WMS','WMS_EPC_MISSING_VALUES');
	RETURN;

      ELSIF p_lpn_id IS NULL AND
	(p_item_id IS NULL OR p_serial_number IS NULL ) AND
	  (p_gtin IS NULL OR p_gtin_serial IS NULL)	THEN

	x_return_status := fnd_api.g_ret_sts_error;
	x_return_mesg := fnd_message.get_string('WMS','WMS_EPC_MISSING_VALUES');
	RETURN;
     END IF;

     INSERT INTO wms_epc( group_id,
			  cross_ref_type,
			  epc_rule_type_id,
			  lpn_id,
			  serial_number,
			  inventory_item_id,
			  gtin_serial,
			  gtin,
			  sscc,
			  epc,
			  filter_object_type,
			  status_code,
			  status,
			  creation_date,
			  created_by,
			  last_update_date,
			  last_updated_by,
			  last_update_login,
			  epc_id,
			  epc_rule_id
			  ) VALUES (P_group_id,
				    p_cross_ref_type,
				    -1, -- epc_rule_type_id:populated -1 FOR outside party
				    p_lpn_id,
				    p_serial_number,
				    p_ITEM_ID,
				    p_GTIN_SERIAL,
				    P_gtin,
				    NULL,
				    P_epc,
				    null,--filter_object_type
				    'S',
				    'IMPORTED',
				    Sysdate,
				    fnd_global.user_id,
				    Sysdate,
				    fnd_global.user_id,
				    fnd_global.user_id,
				    NULL,  --epc_id NOT used post R12
				    NULL); --epc_rule_id NOT used post R12
     --DO NOT COMMIT

  EXCEPTION
     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_error;
	x_return_mesg := Sqlerrm;

	IF l_debug = 1 THEN
	   trace('Exception in populate_outside_epc');
	   trace('ERROR CODE = ' || SQLCODE);
	   trace('ERROR MESSAGE = ' || SQLERRM);
	END IF;

  END populate_outside_epc;


$IF DBMS_DB_VERSION.VERSION > 11 $THEN
--Bug 8796558 New model chages Begin
--This procedure Insert / Upadate / Delete  in WMS_EPC table with data
--passed based ON action specified
--PROCEDURE definition applicable to RDBMS12c or higher
PROCEDURE uptodate_wms_epc
  (p_action            IN VARCHAR2,
   p_group_id          IN NUMBER,
   p_cross_ref_type    IN NUMBER,
   p_epc_rule_type_name  IN VARCHAR2,
   p_lpn_id         IN NUMBER,
   p_item_id        IN NUMBER,
   p_serial_number  IN NUMBER,
   p_gen_epc        IN VARCHAR2,
   p_sscc         IN NUMBER,
   p_gtin         IN NUMBER, --calling API makes it number
   p_gtin_serial  IN NUMBER,
   p_filter_VALUE IN NUMBER,
   x_return_status OUT nocopy VARCHAR2
   ) IS

      PRAGMA AUTONOMOUS_TRANSACTION;

      l_epc_id NUMBER;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF l_debug = 1 THEN
      trace('************UPtoDATE WMS_EPC with new RFID model***');
      trace('p_action   :'|| p_action );
      trace('p_group_id :'||  p_group_id);
      trace('p_cross_ref_type   :'||  p_cross_ref_type);
      trace('p_epc_rule_type_name :'||  p_epc_rule_type_name);
      trace('p_lpn_id   :'||  p_lpn_id);
      trace('p_item_id  :'|| p_item_id);
      trace('p_serial_number :'||  p_serial_number);
      trace('p_gen_epc :'||  p_gen_epc);
      trace('p_sscc    :'|| p_sscc);
      trace('p_gtin    :'|| p_gtin);
   END IF;


   IF p_cross_ref_type = 1 THEN --LPN-EPC /* LPN related label*/

      IF p_action =  'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_name,
	   sscc = P_sscc,
	   gtin = P_gtin,
	   gtin_serial        = NULL,
	   inventory_item_id  = NULL,
	   serial_number      = NULL,
	   filter_object_type = p_filter_value,
	   status      = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE lpn_id = p_lpn_id;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					p_epc_rule_type_name,
					p_lpn_id,
					NULL,--p_serial_number,
					NULL,--p_ITEM_ID,
					NULL,--p_GTIN_SERIAL,
					P_gtin,
					P_sscc,
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
	 DELETE FROM wms_epc WHERE lpn_id = p_lpn_id;

      END IF;


    ELSIF p_cross_ref_type = 2 THEN -- Item_Serial - EPC /* Serial Label */

      IF p_action =  'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_name,
	   sscc = NULL,-- No other value possible
	   gtin = P_gtin,
	   gtin_serial = NULL,
	   lpn_id = NULL,
	   filter_object_type = p_filter_value,
	   status = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE inventory_item_id  = p_item_id
	   AND serial_number        = p_serial_number;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					p_epc_rule_type_name,
					NULL,-- lpn_id
					p_serial_number,
					p_item_id,
					NULL,--p_gtin_serial,
					P_gtin,
					NULL,--p_sscc
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
	 DELETE FROM wms_epc
	   WHERE inventory_item_id  = p_item_id
	   AND serial_number        = p_serial_number;


      END IF;

    ELSIF  p_cross_ref_type = 3 THEN --GTIN+GTIN_Serial - EPC /* Material Label */

      IF p_action = 'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_name,
	   sscc = NULL, --NO other value possible in this case
	   serial_number = NULL,
	   inventory_item_id  = NULL,
	   lpn_id = NULL,
	   filter_object_type = p_filter_value,
	   status = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE GTIN      = p_gtin
	   AND GTIN_serial = p_gtin_serial;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					p_epc_rule_type_name,
					NULL ,-- p_lpn_id
					NULL, --p_serial_number
					NULL, --p_item_id,
					p_GTIN_serial,
					P_gtin,
					NULL, --p_sscc,
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
      DELETE FROM wms_epc
	WHERE GTIN      = p_gtin
	AND GTIN_serial = p_gtin_serial;

      END IF;


   END IF;


  --COMMIT THE autonomous txn part of updating record in WMS_EPC
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
	 TRACE('UPTODATE WMS_EPC: inside exception');
	 TRACE('ERROR CODE = ' || SQLCODE);
	 TRACE('ERROR MESSAGE = ' || SQLERRM);
      END IF;

END  uptodate_wms_epc;


--Collects all informtion needed to generate EPC for given object
-- For a given EPC generation type the output parameter x_components
-- contains required elements that will be passed to DB- EPC generation API
-- to generate EPC
--PROCEDURE definition applicable to RDBMS12c or higher
PROCEDURE get_epc_gen_info( p_org_id          IN NUMBER,
			    p_lpn_id          IN NUMBER,   --FOR  p_label_type_id = 3,4,5
			    p_serial_number   IN VARCHAR2, --FOR p_label_type_id = 2
			    p_item_id         IN NUMBER,   --FOR  p_label_type_id = 1,2
			    p_txn_qty           IN NUMBER,    --FOR  p_label_type_id = 1
			    p_txn_uom           IN VARCHAR2,  --FOR  p_label_type_id = 1
			    p_rev                IN VARCHAR2, --FOR  p_label_type_id = 1,2
			    p_company_prefix     IN VARCHAR2,
			    p_comp_prefix_index  IN VARCHAR2,
			    p_business_flow_code IN NUMBER,
			    p_label_type_id      IN NUMBER,
			    p_epc_rule_type      IN VARCHAR2,
			    p_filter_value       IN NUMBER,
			    p_cage_code          IN VARCHAR2, --FOR p_label_type_id = 2
			    x_gtin          OUT nocopy NUMBER,
			    x_sscc          OUT nocopy NUMBER,
			    x_gtin_serial   OUT nocopy NUMBER,
			    x_components    OUT nocopy mgd_id_component_varray,
			    x_return_status OUT nocopy VARCHAR2)
  IS

     l_components MGD_ID_COMPONENT_VARRAY;

     l_sscc_len NUMBER;
     l_gtin_len NUMBER;
     l_lpn_num_format NUMBER;
     l_is_sscc_valid BOOLEAN := TRUE;
     l_is_gtin_valid BOOLEAN := TRUE;
     l_item_id NUMBER;
     l_total_qty NUMBER :=0;
     l_found_gtin NUMBER := 0;
     l_rev VARCHAR2(3);
     l_uom_code VARCHAR2(3);
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_gtin NUMBER;

     l_total_wlc_qty NUMBER;
     l_total_mmtt_qty NUMBER;
     l_total_mmtt_qty1 NUMBER;
     l_total_mmtt_qty2 NUMBER;
     l_comp_prefix_dig_len NUMBER;
     l_item_reference NUMBER;
     l_serial_reference NUMBER;
     l_gtin_serial NUMBER;
     l_sscc NUMBER;

     l_return_status VARCHAR2(1);
     --l_primary_uom_code VARCHAR2(3);

     ----------------------------------------
     /*
     Following table shows Valid set up in Label Format Form for EPC
       generation using diferent standard (X means acceptable)

       Standard\LabelType LPN/LPNContent/LPNSummary Material Serial
          SGTIN_96/64	         X	                X      X
          SSCC_96/64	         X		        -      -
          DoD_96/64	         -                      -      X
       */
     -----------------------------------------


BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF p_label_type_id IN (3,4,5) THEN --LPN, LPN Content, LPN Summary

      l_comp_prefix_dig_len:= Length(p_company_prefix);

      IF p_epc_rule_type IN ('SGTIN-96','SGTIN-64') THEN

	 -- {{get GTIN and gtin-Serial for the LPN }}
	 get_lpn_gtin_serial(p_lpn_id => p_lpn_id,
			     p_org_id => p_org_id,
			     p_filter_value       => p_filter_value,
			     p_business_flow_code =>  p_business_flow_code,
			     x_gtin          => l_gtin,
			     x_gtin_serial   => l_gtin_serial,
			     x_return_status => l_return_status);

	 --{{ get the item reference from GTIN for LPN now }}
	 --{{ l_gtin obtained IS NOT NULL }}

	 IF l_return_status = fnd_api.g_ret_sts_success AND l_gtin IS NOT NULL THEN

	    l_item_reference := To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    IF l_debug = 1 THEN
	       trace('l_gtin , l_gtin_serial :' || l_gtin||','||l_gtin_serial);
	       trace('l_item_reference :'|| l_item_reference);
	    END IF;

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;

	    --{{ get all expected components FOR EPC_SGTIN_96}}
	    IF p_epc_rule_type = 'SGTIN-96' THEN

	       --use company-prefix

	       IF l_debug = 1 THEN
		  trace('p_filter_value, p_company_prefix,l_item_reference,l_gtin_serial');
		  trace(p_filter_value||','||p_company_prefix||','||l_item_reference||','||l_gtin_serial);
	       END IF;

            l_components :=  MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-96'));

	     ELSIF p_epc_rule_type = 'SGTIN-64' THEN

	       --{{ get all expected components FOR EPC_SGTIN_64}}

			l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-64'));


	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF  get_lpn_gtin_serial()
	 END IF;


       ELSIF p_epc_rule_type IN ('SSCC-96','SSCC-64') THEN

	 --{{ get SSCC for LPN }}

	 l_sscc := get_sscc(p_lpn_id,p_org_id);

	  IF l_debug = 1 THEN
	     trace('SSCC for the LPN      :'||l_sscc);
	     trace('l_comp_prefix_dig_len :'||l_comp_prefix_dig_len);
	     trace('p_filter_value        :'||p_filter_value);
	     trace('p_company_prefix      :'|| p_company_prefix);
	  END IF;


	  IF l_sscc IS  NOT NULL THEN

	     x_gtin  := NULL;
	     x_sscc  := l_sscc;
	     x_gtin_serial := NULL;

	     --{{ get serial reference from SSCC }}
	     l_serial_reference := To_number(Substr(To_char(L_sscc),1,1)||Substr(To_char(l_sscc),l_comp_prefix_dig_len+2,(16-l_comp_prefix_dig_len)));

	     IF l_debug = 1 THEN

		trace('l_serial_reference :'|| l_serial_reference);
	     END IF;
	     --{{ get all expected components FOR EPC_SSCC_96 for containers}}
	     IF p_epc_rule_type = 'SSCC-96' THEN
		--use company-prefix
					IF l_debug = 1 THEN
						 trace('Coming to calculating SSCC-96  p_filter_value             :'||p_filter_value);
						 trace('Coming to calculating SSCC-96  p_company_prefix           :'||p_company_prefix);
						 trace('Coming to calculating SSCC-96  l_comp_prefix_dig_len      :'||l_comp_prefix_dig_len);
						 trace('Coming to calculating SSCC-96  l_serial_reference         :'||l_serial_reference);
					END IF;
		l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('serialref',l_serial_reference),
               MGD_ID_COMPONENT('schemes','SSCC-96'));

	      ELSIF p_epc_rule_type = 'SSCC-64' THEN


		--{{ get all expected components FOR EPC_SSCC_64 for containers}}

		l_components :=MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('serialref',l_serial_reference),
               MGD_ID_COMPONENT('schemes','SSCC-64'));

	     END IF;

	   ELSE --means l_sscc is NULL
	     IF l_debug = 1 THEN
		trace('Error : Incorrect SSCC value set up for the LPN');
	     END IF;

	     RAISE  fnd_api.g_exc_error;
	  END IF;


       ELSIF p_epc_rule_type IN ('USDOD-96','USDOD-64') THEN


	 --This is INVALID  option for EPC generation FOR LPN label
	 IF l_debug = 1 THEN
	    trace('Error:For LPN label, No EPC can be generated using EPC_DOD_96/64, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;
      END IF;

    ELSIF  p_label_type_id =1 THEN  /*Material Label*/

      l_comp_prefix_dig_len:= Length(p_company_prefix);

      IF l_debug = 1 THEN
	 trace('l_comp_prefix_dig_len :'||l_comp_prefix_dig_len);
      END IF;

      IF p_epc_rule_type IN ('SGTIN-96','SGTIN-64') THEN
	 -- for item_id and qty + UOM, find any set up in GTIN C/R
	 -- Generate EPC for that GTIN.

	 get_item_gtin_serial(p_item_id  => p_item_id,
			      p_org_id   => p_org_id,
			      p_qty      => p_txn_qty,
			      p_uom_code => p_txn_uom,
			      p_rev      => l_rev,
			      x_gtin          => l_gtin,
			      x_gtin_serial   => l_gtin_serial,
			      x_return_status => l_return_status);



	 IF   l_return_status = fnd_api.g_ret_sts_success AND  l_gtin IS NOT NULL THEN



	    --{{ get the item reference from GTIN for the Item now }}

	    l_item_reference :=
	      To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;

	    IF p_epc_rule_type = 'SGTIN-96' THEN

	       --{{ get all expected components FOR EPC_SGTIN_96 for Item}}
	       --use company-prefix
			l_components :=  MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-96'));

	     ELSIF p_epc_rule_type = 'SGTIN-64' THEN

	       IF l_debug = 1 THEN
		  trace('p_comp_prefix_index :'||To_number(p_comp_prefix_index));
		  trace('p_filter_value      :'||p_filter_value);
		  trace('l_item_reference    :'||l_item_reference);
		  trace('l_gtin_serial       :'||l_gtin_serial);
	       END IF;

	       --{{ get all expected components FOR EPC_SGTIN_64 for Item}}
	       --use company-prefix -INDEX

	     	l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-64'));

	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF  get_item_gtin_serial()
	 END IF;

       ELSIF p_epc_rule_type IN ('SSCC-96','SSCC-64') THEN
	 --This is INVALID  option for EPC generation of Material
	 IF l_debug = 1 THEN
	    trace('Error:For Material, No EPC can be generated using SSCC, incorrect SET up');
	 END IF;

	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;


       ELSIF p_epc_rule_type IN ('USDOD-96','USDOD-64') THEN

	 IF l_debug = 1 THEN
	    trace('Error:For Material, No EPC can be generated using EPC_DOD, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;


      END IF;

    ELSIF p_label_type_id = 2 THEN  /*Serial Label*/
      --Components: FILTER,CAGE, SERIAL_NUMBER

      IF p_epc_rule_type IN ('SGTIN-96','SGTIN-64') THEN

	 --Generate EPC for that item for GTIN corresponding to Primary UOM.
	 --we have p_serial_number + p_item_id + p_cage_code+ p_filter_value

	 --P_serial_number will be totally ignored while generating EPC. GTIN_Serial
	 --will be used but it will be stored in wms_EPC table against the
	 --Item+p_serial_number

	 -- for item_id and qty + UOM, find any set up in GTIN C/R
	 -- Generate EPC for that GTIN.

	  IF l_debug = 1 THEN
	     trace('going to call get_serialnum_gtin_serial');
	  END IF;

	 get_serialnum_gtin_serial(p_item_id       => p_item_id,
				   p_org_id        => p_org_id,
				   p_rev           => l_rev,
				   x_gtin          => l_gtin,
				   x_gtin_serial   => l_gtin_serial,
				   x_return_status => l_return_status);


   	 --{{ get the item reference from GTIN for the Item now }}


	  IF l_debug = 1 THEN
	     trace('After call get_serialnum_gtin_serial');
	     trace('l_return_status :'||l_return_status);
	     trace('l_gtin :'||l_gtin);
	     trace('l_gtin_serial :'||l_gtin_serial);
	  END IF;


	 IF l_return_status= fnd_api.g_ret_sts_success AND l_gtin IS NOT NULL THEN

	    l_item_reference :=
	      To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;


	    IF p_epc_rule_type = 'SGTIN-96' THEN
	       --{{ get all expected components FOR EPC_SGTIN_96 for Item}}
	       --use company-prefix
			l_components :=  MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-96'));
	     ELSIF p_epc_rule_type = 'EPC-SGTIN-64' THEN

	       --{{ get all expected components FOR EPC_SGTIN_64 for Item}}
	       --use company-prefix -INDEX

			l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
               MGD_ID_COMPONENT('companyprefix',p_company_prefix),
               MGD_ID_COMPONENT('companyprefixlength',l_comp_prefix_dig_len),
               MGD_ID_COMPONENT('itemref',l_item_reference),
               MGD_ID_COMPONENT('serial',l_gtin_serial),
               MGD_ID_COMPONENT('schemes','SGTIN-64'));
	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF
	    --get_serialnum_gtin_serial() -> get_gtin_and_gserial()

	 END IF;

       ELSIF p_epc_rule_type IN ('SSCC-96','SSCC-64') THEN
	 --This is INVALID  option for EPC generation of Serial NUMBER
	 IF l_debug = 1 THEN
	    trace('Error:For Serial, No EPC can be generated using SSCC, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;

       ELSIF p_epc_rule_type IN ('USDOD-96','USDOD-64') THEN
	 --{{Note: We MUST have Serial uniqueness across items for EPC generation EPC_DOD_96/EPC_DOD_64}}

	 x_gtin  := NULL;
	 x_sscc  := NULL;
	 x_gtin_serial := NULL;

	 IF p_epc_rule_type = 'USDOD-96' THEN
	    --{{ get all expected components FOR EPC_DOD_96 for container}}

	    l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
			   MGD_ID_COMPONENT('cageordodaac',p_cage_code),
               MGD_ID_COMPONENT('serial',p_serial_number),
               MGD_ID_COMPONENT('schemes','USDOD-96'));

	  ELSIF  p_epc_rule_type = 'USDOD-64' THEN
	    --{{ get all expected components FOR EPC_DOD_96 for container }}

	    IF l_debug = 1 THEN
	       trace('Inside EPC_DOD_64 to collect components');
	    END IF;

		l_components := MGD_ID_COMPONENT_VARRAY(
               MGD_ID_COMPONENT('filter',p_filter_value),
			   MGD_ID_COMPONENT('cageordodaac',p_cage_code),
               MGD_ID_COMPONENT('serial',p_serial_number),
               MGD_ID_COMPONENT('schemes','USDOD-64'));
	 END IF;
    END IF;
   END IF;

    x_components :=  l_components;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin_serial := NULL;
      x_gtin        :=NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin_serial := NULL;
      x_gtin        :=NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here


   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_epc_gen_info()');
	 trace('ERROR CODE    = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin_serial := NULL;
      x_gtin        := NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here
END get_epc_gen_info;



--*********************************************
/*
Procedure generate_epc

  FUNCTIONALITY:-
  This is the main API in this package that is responsible for generating
  EPC for current transaction

  PARAMETER:-
   p_org_id          : Organization id
   p_label_type_id   : Supported LPN/Serial/Material labels : VALID VALUES 1,2,3,4,5
   p_group_id	     : groun_id per invocation
   p_label_format_id : label_format_id for this transaction that should have has epc field
   p_item_id         : need TO pass fpr Material Label: 1 only
   p_txn_qty         : need TO pass fpr Material Label: 1 only
   p_txn_uom         : need TO pass fpr Material Label: 1 only (since uom is not in wms_label_requests table)
   p_label_request_id: the id from wms_label_requests foe which label will be generated
   p_business_flow_code : business flow code value
   x_epc : returns generated EPC
   x_return_status :-
     S : success : EPC generated     E : error   : EPC could not be generated for valid reason
     U : Warning : EPC could not be generated for unexpected reason

   x_return_mesg : Appropriate error message

  */

 --*********************************************
 --PROCEDURE definition applicable to RDBMS12c or higher
  Procedure generate_epc
  (p_org_id          IN NUMBER,
   p_label_type_id   IN NUMBER, /* VALID VALUES 1,2,3,4,5*/
   p_group_id	     IN	NUMBER,
   p_label_format_id IN NUMBER,
   p_item_id            IN NUMBER   DEFAULT NULL, --For Material Label: 1
   p_txn_qty            IN NUMBER   DEFAULT null, --For Material Label: 1
   p_txn_uom            IN VARCHAR2 DEFAULT NULL, --For Material Label: 1
   p_label_request_id   IN NUMBER,
   p_business_flow_code IN NUMBER DEFAULT NULL,
   x_epc             OUT nocopy VARCHAR2,
   x_return_status   OUT nocopy VARCHAR2,
   x_return_mesg     OUT nocopy VARCHAR2
   ) IS

      end_processing EXCEPTION;
      l_gen_epc VARCHAR2(260);
      l_gen_binary_epc VARCHAR2(260);
      l_sscc NUMBER;
      l_gtin NUMBER;
      l_gtin_serial NUMBER;
      l_epc VARCHAR2(260);
      l_msg_count NUMBER;

      l_return_status VARCHAR2(1);
      l_regenerate_flag VARCHAR2(1) := 'N';
      l_filter_value NUMBER;
      l_outermost_lpn_id NUMBER;
      l_PARENT_lpn_id NUMBER;
      l_return_mesg VARCHAR2(2000);
       --l_existing_epc_rule_id NUMBER;
      l_epc_output_rep NUMBER;

      --New parameters
      is_epc_enabled VARCHAR2(1);
      l_company_prefix VARCHAR2(30);
      l_company_prefix_index VARCHAR2(30);
      l_cage_code VARCHAR2(30);
      l_custom_company_prefix VARCHAR2(30);
      l_epc_rule_type VARCHAR2(100);
      l_cust_comp_prefix_index NUMBER;
      l_comp_prefix_len NUMBER;
      l_cross_ref_type NUMBER;
      l_epc_category_id NUMBER;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_lpn_id NUMBER;
      l_serial_number VARCHAR2(30);
      l_item_id NUMBER;
      l_rev VARCHAR2(3);
      l_bit_length NUMBER;
      l_components mgd_id_component_varray;
      pcode      mgd_id;

  	 l_internet_proxy_hostname VARCHAR2(100) := FND_PROFILE.VALUE('WMS_INTERNET_PROXY_HOSTNAME');
	 l_internet_proxy_port_number NUMBER := FND_PROFILE.VALUE('WMS_INTERNET_PROXY_PORT');

  BEGIN

     G_PROFILE_GTIN  := FND_PROFILE.value('INV:GTIN_CROSS_REFERENCE_TYPE');
     x_return_status := fnd_api.g_ret_sts_success;


    IF l_debug = 1 THEN
	trace('************ inside generate_epc ***********');
	trace('p_org_id             :'||p_org_id);
	trace(' p_label_request_id  :'||p_label_request_id);
	trace('p_business_flow_code :'||p_business_flow_code);
	trace('p_group_id           :'||p_group_id);
	trace('p_label_type_id      :'||p_label_type_id);
	trace('p_label_format_id    :'||p_label_format_id);
	trace('p_item_id            :'||p_item_id);
	trace('p_txn_qty            :'||p_txn_qty);
	trace('l_internet_proxy_hostname     :'||l_internet_proxy_hostname);
	trace('l_internet_proxy_port_number  :'||l_internet_proxy_port_number);
	END IF;

	IF(l_internet_proxy_hostname IS NOT NULL AND l_internet_proxy_port_number IS NOT NULL) THEN
     DBMS_MGD_ID_UTL.set_proxy(l_internet_proxy_hostname, l_internet_proxy_port_number);	--SETTING PROXY
	ELSE
	    IF l_debug = 1 THEN
			trace('The WMS Internet proxy host name and/or number proxy profile Values are null so 64 bit models can fail');
		END IF;
	END IF;

     DBMS_MGD_ID_UTL.refresh_category(DBMS_MGD_ID_UTL.get_category_id('EPC', NULL));

      --{{get needed information from mtl_parameters setup for EPC generation }}
      IF ( NOT Inv_Cache.set_org_rec( p_organization_id => p_org_id ))THEN
	 IF (l_debug = 1) THEN
	    trace(p_org_id || 'is an invalid organization id');
	 END IF;
	 fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      l_company_prefix       := inv_cache.org_rec.company_prefix;
      l_company_prefix_index :=  inv_cache.org_rec.company_prefix_index;


      IF l_debug = 1 THEN
	 trace('epc_enabled            :'||Nvl(inv_cache.org_rec.epc_generation_enabled_flag,'N'));
	 trace('l_company_prefix       :'||l_company_prefix);
	 trace('l_company_prefix_index :'||l_company_prefix_index);
	 trace('cage_code              :'||inv_cache.org_rec.commercial_govt_entity_number);
      END IF;

      --{{get needed information from label formats setup for the format_id}}
      SELECT epc_rule_type,filter_value,generate_epc,epc_category_id
	INTO l_epc_rule_type,l_filter_value,l_regenerate_flag, l_epc_category_id
	FROM wms_label_formats
	WHERE label_format_id = p_label_format_id
	AND Nvl(label_ENTITY_type,0) =0;  --label format and NOT label-set

      IF l_debug = 1 THEN
	 trace('l_epc_rule_type   :'||l_epc_rule_type);
	 trace('l_filter_value    :'||l_filter_value);
	 trace('l_regenerate_flag :'||l_regenerate_flag);
	 trace('l_epc_category_id :'||l_epc_category_id);
      END IF;

      --Check if EPC is enabled
      IF Nvl(inv_cache.org_rec.epc_generation_enabled_flag,'N') = 'Y' THEN

	 --Get required information about the current transaction
	 SELECT lpn_id,serial_number,inventory_item_id,revision
	   INTO   l_lpn_id,l_serial_number,l_item_id, l_rev
	   FROM wms_label_requests
	   WHERE label_request_id =  p_label_request_id;


	 IF l_debug = 1 THEN
	    trace('l_lpn_id,l_serial_number,l_item_id, l_rev :'||l_lpn_id||','||l_serial_number||','||l_item_id||','||l_rev);
	 END IF;

	 --Find if the EPC cross-ref already exist or it needs to be re-created
	 --For LPN

	 IF l_lpn_id IS NOT NULL AND  p_label_type_id IN (3,4,5) THEN /* LPN / LPN-Content / LPN Summary*/

	    l_cross_ref_type := 1;--/*LPN-EPC Cross ref*/

           BEGIN
	       SELECT wlpn.parent_lpn_id, wlpn.outermost_lpn_id, we.epc
		 INTO l_parent_lpn_id, l_outermost_lpn_id, l_epc
		 FROM wms_license_plate_numbers wlpn, wms_epc we
		 WHERE wlpn.lpn_id =  l_lpn_id
		 AND wlpn.lpn_id = we.lpn_id(+)
		 AND ((we.epc is NOT NULL and Nvl(we.cross_ref_type,1) = 1)
		     or (we.epc is NULL )) ;
		     --Nvl(we.cross_ref_type,1) to support EPC generated
		     --using 11.5.10.2CU code

	      -- starting R12 this must be
	      -- populated AND old data needs to be updated

	   EXCEPTION
	      WHEN no_data_found THEN

		 IF l_debug = 1 THEN
		    trace('NO DATA found for the LPN');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_unexpected_error;
	   END;

	   --Neither pallet or case, then NO support FOR EPC of further
	   -- nested lpn, error out
	   IF  NOT ((l_outermost_lpn_id = l_lpn_id AND l_parent_lpn_id IS null )
	     OR (l_parent_lpn_id = l_outermost_lpn_id AND l_parent_lpn_id IS NOT null)) THEN

	      fnd_message.set_name('WMS', 'WMS_NO_MULTI_NESTING_SUPPORT');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;

	   END IF;

	 --For Serial
	 ELSIF l_serial_number IS NOT NULL AND  p_label_type_id = 2 THEN  --/* Serial Label*/

	       l_cross_ref_type := 2;--/*Serial-EPC Cross ref*/

	       --Item_id + Serial_number will uniquely mapped to an EPC
               BEGIN
		  SELECT we.epc INTO l_epc
		    FROM  wms_epc we
		    WHERE INVENTORY_item_id = l_item_id
		    AND serial_number = l_serial_number
		    AND we.cross_ref_type = 2;
	       EXCEPTION
		  WHEN no_data_found THEN
		     NULL;
		  WHEN  OTHERS THEN
		     RAISE fnd_api.g_exc_unexpected_error;
	       END;

	       --For item_id/GTIN
	 ELSIF l_item_id IS NOT NULL AND p_label_type_id = 1 THEN --/*Material Label*/

		     l_cross_ref_type := 3; --/*GTIN+GTIN_SERIAL-EPC Cross ref*/

		     --No need to check whether EPC exists or NOT for the GTIN
		     --just regenerate EPC, EPC will be unique to GTIN+GTIN-SERIAL combination
		     --and it needs to be inserted

		     l_regenerate_flag := 'Y'; -- override always
	END IF;


	--{{call to see if the custom company_prefix is implemented}}
	wms_epc_pub.GET_CUSTOM_COMPANY_PREFIX(
					      p_org_id => p_org_id,
					      p_label_request_id => p_label_request_id,
					      X_company_prefix  => l_custom_company_prefix,
					      X_RETURN_STATUS  => l_return_status);

	--{{call to see if the custom company_prefix_INDEX is implemented}}
	wms_epc_pub.GET_CUSTOM_COMP_PREFIX_INDEX(p_org_id   => p_org_id,
						 p_label_request_id => p_label_request_id,
						 X_comp_prefix_INDEX => l_CUST_comp_prefix_INDEX,
						 X_RETURN_STATUS     => l_return_status);

	IF l_debug = 1 THEN
	   trace('CUSTOM_COMPANY_PREFIX value :'||l_custom_company_prefix);
	   trace('CUSTOM_COMPANY_PREFIX_INDEX value :'||l_cust_comp_prefix_index);
	END IF;

	IF l_custom_company_prefix IS NOT NULL THEN
	   l_company_prefix := l_custom_company_prefix;
	END IF;

	IF l_cust_comp_prefix_index IS NOT NULL THEN
	   l_company_prefix_index :=  l_cust_comp_prefix_index;
	END IF;

	IF l_debug = 1 THEN
	   trace('Final COMPANY_PREFIX value :'||l_company_prefix);
	   trace('Final COMPANY_PREFIX_INDEX value :'||l_company_prefix_index );
	END IF;

	IF l_debug = 1 THEN
	   trace('Generating EPC now.............');
	END IF;

	--{{ See if the rule is custom or Un-Implemented Standard Rule }}
	IF l_epc_category_id <> DBMS_MGD_ID_UTL.GET_CATEGORY_ID('EPC',NULL)
	  OR ( l_epc_category_id = DBMS_MGD_ID_UTL.GET_CATEGORY_ID('EPC',NULL) AND
	        l_epc_rule_type NOT IN  ('SGTIN-96','SSCC-96','SGTIN-64','SSCC-64','USDOD-96','USDOD-64') )
	  --means in ('GIAI-96','GRAI-96','SGLN-96','GID-96','GIAI-64','GRAI-64','SGLN-64','GID-64')
	  THEN

	   -- {{ get custom EPC generated }}
	   wms_epc_pub.get_custom_epc
	     (p_org_id        => p_org_id,
	      p_category_id      => l_epc_category_id,-- In mgd_idencoding_type table
	      p_epc_rule_type_id => l_epc_rule_type, --Rule_type_id IN mgd_idencoding_type table
	      p_filter_value     => l_filter_value,
	      p_label_request_id => p_label_request_id, --to get all data FROM wms_device_requests label
	      x_return_status => l_return_status,
	      x_return_mesg   => l_return_mesg,
	      x_epc           => l_epc);

	 ELSIF  l_epc_rule_type IN
	   ('SGTIN-96','SSCC-96','SGTIN-64','SSCC-64','USDOD-96','USDOD-64') THEN
	   --{{ get standard EPC generated for standard rule}}

	   --{{ Check to see if regenerate flag is ON..only then generate epc }}
	   IF l_regenerate_flag = 'Y' OR (l_epc is NULL AND
					  Nvl(l_regenerate_flag,'N') = 'N' ) THEN

	      --{{ get EPC Encoding Rule components }}
	      IF l_debug = 1 THEN
		 trace('Collecting information to generate EPC ....');
	      END IF;

	      get_epc_gen_info( p_org_id          => p_org_id,
				p_lpn_id          => l_lpn_id,   --FOR  p_label_type_id = 3,4,5
				p_serial_number   => l_serial_number, --FOR  p_label_type_id = 2
				p_item_id         => Nvl(l_item_id,p_item_id),  --FOR  p_label_type_id = 1
				p_txn_qty         => p_txn_qty,  --FOR  p_label_type_id = 1
				p_txn_uom         => p_txn_uom,  --FOR  p_label_type_id = 1
				p_rev             => l_rev,      --FOR  p_label_type_id = 1,2
				p_company_prefix  => l_company_prefix,
				p_comp_prefix_index  => l_company_prefix_index,
				p_business_flow_code => p_business_flow_code,
				p_label_type_id      => P_label_type_id,
				p_epc_rule_type      => l_epc_rule_type,
				p_filter_value       => l_filter_value,
				p_cage_code          => inv_cache.org_rec.commercial_govt_entity_number,  --FOR p_label_type_id = 2
				x_gtin               => l_gtin,
				x_sscc               => l_sscc,
				x_gtin_serial        => l_gtin_seriaL,
				x_components         => l_components,
				x_return_status      => l_return_status);

	       IF l_debug = 1 THEN
		  trace('after calling  get_epc_gen_info... ');
		  trace('l_gtin :'||l_gtin );
		  trace('l_sscc :'||l_sscc);
		  trace('l_gtin_serial :'||l_gtin_serial);
		  trace('l_return_status :'||l_return_status);
	       END IF;


	      --{{ genereate EPC using the components }}

	    IF l_return_status = fnd_api.g_ret_sts_success  AND l_components IS NOT NULL THEN
		  IF l_debug = 1 THEN
		     trace('Before calling DB EPC category_name :'||DBMS_MGD_ID_UTL.get_category_id('EPC',NULL));
		  END IF;

			BEGIN
				pcode :=  MGD_ID (DBMS_MGD_ID_UTL.get_category_id('EPC',NULL),l_components);
				l_gen_binary_epc := pcode.format(NULL,'BINARY');

				IF l_debug = 1 THEN
				trace('EPC generated by DB Feature in binary via new model :'||l_gen_binary_epc);
				END IF;

				IF(l_gen_binary_epc IS NOT NULL) THEN
				l_gen_epc := dec2hex(bin2dec(l_gen_binary_epc));
				END IF;

				IF l_debug = 1 THEN
				trace('EPC generated by DB Feature in HEX converted from binary :'||l_gen_epc);
				END IF;

			EXCEPTION
				WHEN OTHERS THEN

		       IF l_debug = 1 THEN
			  TRACE('After calling mgd_idcode: Inside exception');
			  TRACE('ERROR CODE = ' || SQLCODE);
			  TRACE('ERROR MESSAGE = ' || SQLERRM);
		       END IF;

		       --EPC generation failed at DB feature level
		       fnd_message.set_name('WMS', 'WMS_DB_EPC_GEN_FAIL');
		       fnd_msg_pub.ADD;

		       --Do not raise exception here as we want to delete
		       --old cross-reference RECORD FROM wms_epc for some
		       --CASES BELOW
			END;

	    ELSE
		 -- {{Error out l_components are null, EPC could not be generated }}

		 IF l_debug = 1 THEN
		    trace('get_epc_gen_info() returned error');
		    trace('Error: Components could not be obtained for EPC generation ');
		 END IF;


		 fnd_message.set_name('WMS', 'WMS_EPC_GEN_FAIL');
		 fnd_msg_pub.ADD;

		 --Do not raise exception here as we want to delete
		 --old cross-reference RECORD FROM wms_epc for some
		 --CASES BELOW

	    END IF; --l_return_status = 'S for get_epc_gen_info()


	   END IF; --l_regenerate_flag = 'Y'

	END IF; --means 'SGTIN-96','SSCC-96','SGTIN-64','SSCC-64',EPC_DOD_96,EPC_DOD_64''SGTIN-96','SSCC-96'

      ELSE
		     IF l_debug = 1 THEN
			trace('EPC generation is NOT enabled at Orgnization level');
		     END IF;

		     fnd_message.set_name('WMS', 'WMS_EPC_DISABLED');
		     fnd_msg_pub.ADD;
		     RAISE fnd_api.g_exc_error;

     END IF;


     --{{ By NOW EPC should be generate for valid cases: Insert EPC or update EPC or delete EPC }}

     IF l_debug = 1 THEN
	trace('Old EPC,if any   :'||l_epc);
	trace('New generated EPC:'||l_gen_epc);
     END IF;



     --{{ Get the EPC ENCODING defined with the profile 'WMS_EPC_ENCODING'}}
     l_epc_output_rep := NVL(fnd_profile.value('WMS_EPC_ENCODING'), 2);
     -- 1 : Binary
     -- 2 : Hex
     -- 3 : Decimal

     IF l_debug = 1 THEN
	 trace('1-Binary,2-Hex,3-Decimal l_epc_output_rep :'||l_epc_output_rep);
     END IF;


     --l_epc_rule_type_id is already identified above
     IF l_regenerate_flag = 'Y' OR (l_epc is NULL AND
				    Nvl(l_regenerate_flag,'N') = 'N' ) THEN


	IF l_epc IS NOT NULL AND l_gen_epc IS NOT NULL THEN
	   --{{ EPC c/r already there: UPDATE LAST EPC with new EPC value }}
	   uptodate_wms_epc ( p_action   => 'UPDATE',
			      p_group_id         => p_group_id,
			      p_cross_ref_type   => l_cross_ref_type,
			      p_epc_rule_type_name => l_epc_rule_type,
			      p_lpn_id           => l_lpn_id,
			      p_item_id          => l_item_id,
			      p_serial_number    => l_serial_number,
			      p_gen_epc          => l_gen_epc,
			      p_sscc             => l_sscc,
			      p_gtin             => l_gtin,
			      p_gtin_serial      => l_gtin_serial,
			      p_filter_VALUE     => l_filter_value,
			      x_return_status    => L_RETURN_STATUS);


		IF l_debug =1 then
	      trace(' uptodate_wms_epc UPDATE: L_RETURN_STATUS:'||l_return_status);
		END IF;

	   --return new EPC IN THE FORMAT SPECIFIED
	   IF L_epc_output_rep = 1 THEN --Binary
	      x_epc := l_gen_binary_epc;

	    ELSIF l_epc_output_rep = 3 THEN --Decimal
	      x_epc := hex2dec(l_gen_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_gen_epc;
	   END IF;

		IF l_debug =1 then
	      trace('Final format EPC :'||x_epc);
		END IF;

	 ELSIF l_epc IS NOT NULL AND l_gen_epc IS NULL THEN
	   -- Delete the existing cross -reference

	   uptodate_wms_epc ( p_action   => 'DELETE',
			      p_group_id         => p_group_id,
			      p_cross_ref_type   => l_cross_ref_type,
			      p_epc_rule_type_name => l_epc_rule_type,
			      p_lpn_id           => l_lpn_id,
			      p_item_id          => l_item_id,
			      p_serial_number    => l_serial_number,
			      p_gen_epc          => l_gen_epc,
			      p_sscc             => l_sscc,
			      p_gtin             => l_gtin,
			      p_gtin_serial      => l_gtin_serial,
			      p_filter_VALUE     => l_filter_value,
			      x_return_status    => L_RETURN_STATUS);

	   IF l_debug =1 then
	      trace(' uptodate_wms_epc DELETE: L_RETURN_STATUS:'||l_return_status);
	   END IF;

	   RAISE fnd_api.g_exc_error;--COULD NOT OVERIDE THE EPC


	 ELSIF l_epc IS NULL AND l_gen_epc IS NOT NULL THEN

	   uptodate_wms_epc( p_action   => 'INSERT',
			     p_group_id         => p_group_id,
			     p_cross_ref_type   => l_cross_ref_type,
			     p_epc_rule_type_name => l_epc_rule_type,
			     p_lpn_id           => l_lpn_id,
			     p_item_id          => l_item_id,
			     p_serial_number    => l_serial_number,
			     p_gen_epc          => l_gen_epc,
			     p_sscc             => l_sscc,
			     p_gtin             => l_gtin,
			     p_gtin_serial      => l_gtin_serial,
			     p_filter_VALUE     => l_filter_value,
			     x_return_status    => L_RETURN_STATUS);

	   IF l_debug =1 then
	      trace(' uptodate_wms_epc INSERT: L_RETURN_STATUS:'||l_return_status);
	   END IF;

	   --return new EPC IN THE FORMAT SPECIFIED
	   IF L_epc_output_rep = 1 THEN --Binary
	      l_bit_length := To_number(Substr(l_epc_rule_type,(Length(l_epc_rule_type)-1),Length(l_epc_rule_type)));
	      x_epc := Lpad(dec2bin(hex2dec(l_gen_epc)),l_bit_length,'0');
	    ELSIF l_epc_output_rep = 3 THEN --Decimal
	      x_epc := hex2dec(l_gen_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_gen_epc;
	   END IF;


	 ELSIF l_epc IS NULL AND l_gen_epc IS NULL THEN

	   RAISE fnd_api.g_exc_error;

	END IF;

      ELSIF Nvl(l_regenerate_flag,'N') = 'N' THEN

	IF l_epc IS NOT NULL THEN

	   --Return Old EPC,Already it was stored in Hex
	   --return new EPC IN THE FORMAT SPECIFIED
	   IF L_epc_output_rep = 1 THEN --Binary
	      l_bit_length := To_number(Substr(l_epc_rule_type,(Length(l_epc_rule_type)-1),Length(l_epc_rule_type)));
	      x_epc := Lpad(dec2bin(hex2dec(l_gen_epc)),l_bit_length,'0');

	    ELSIF l_epc_output_rep = 3 THEN --Decimal
	      x_epc := hex2dec(l_gen_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_gen_epc;
	   END IF;

	END IF; -- L_EPC IS NOT NULL

     END IF; -- For p_regenerate_flag = 'N'

    DBMS_MGD_ID_UTL.REMOVE_PROXY;

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
	fnd_message.set_name('WMS','WMS_EPC_GEN_FAIL');
	fnd_msg_pub.ADD;
	x_return_status  := fnd_api.g_ret_sts_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_encoded  => 'F',p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	IF l_debug = 1 THEN
	   TRACE('Inside g_exc_error l_msg_count :'||l_msg_count);
	   TRACE('x_return_mesg :'||x_return_mesg);
	END IF;

	-- FND_MSG_PUB.initialize;  --bug 5178424


     WHEN fnd_api.g_exc_unexpected_error THEN
	fnd_message.set_name('WMS', 'WMS_EPC_GEN_FAIL');
	fnd_msg_pub.ADD;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	IF l_debug = 1 THEN
	   TRACE('Inside g_exc_unexpected_error l_msg_count :'||l_msg_count);
	   TRACE('x_return_mesg :'||x_return_mesg);
	END IF;

	 -- FND_MSG_PUB.initialize; --bug 5178424

     WHEN OTHERS THEN
	--ROLLBACK; blocked in R12
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	-- FND_MSG_PUB.initialize;  --bug 5178424

	IF l_debug = 1 THEN
	   TRACE('generate EPC: Inside exception');
	   TRACE('ERROR CODE = ' || SQLCODE);
	   TRACE('ERROR MESSAGE = ' || SQLERRM);
	END IF;

  END generate_epc;
--Function applicable to RDBMS12c or higher
FUNCTION db_version RETURN NUMBER IS
	BEGIN
		trace('Call from forms for DB version, returning 12 as higher DB version is 12c or higher so use new RFID model');
		RETURN 12;
END db_version;
--Bug 8796558 new model changes end

$ELSE
--This procedure Insert / Upadate / Delete  in WMS_EPC table with data
--passed based ON action specified
--PROCEDURE applicable to DB versions below RDBMS12c
PROCEDURE uptodate_wms_epc
  (p_action            IN VARCHAR2,
   p_group_id          IN NUMBER,
   p_cross_ref_type    IN NUMBER,
   p_EPC_rule_TYPE_id  IN NUMBER,
   p_lpn_id         IN NUMBER,
   p_item_id        IN NUMBER,
   p_serial_number  IN NUMBER,
   p_gen_epc        IN VARCHAR2,
   p_sscc         IN NUMBER,
   p_gtin         IN NUMBER, --calling API makes it number
   p_gtin_serial  IN NUMBER,
   p_filter_VALUE IN NUMBER,
   x_return_status OUT nocopy VARCHAR2
   ) IS

      PRAGMA AUTONOMOUS_TRANSACTION;

      l_epc_id NUMBER;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF l_debug = 1 THEN
      trace('************UPtoDATE WMS_EPC with old RFID model***');
      trace('p_action   :'|| p_action );
      trace('p_group_id :'||  p_group_id);
      trace('p_cross_ref_type   :'||  p_cross_ref_type);
      trace('p_epc_rule_type_id :'||  p_EPC_rule_TYPE_id);
      trace('p_lpn_id   :'||  p_lpn_id);
      trace('p_item_id  :'|| p_item_id);
      trace('p_serial_number :'||  p_serial_number);
      trace('p_gen_epc :'||  p_gen_epc);
      trace('p_sscc    :'|| p_sscc);
      trace('p_gtin    :'|| p_gtin);
   END IF;


   IF p_cross_ref_type = 1 THEN --LPN-EPC /* LPN related label*/

      IF p_action =  'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_id,
	   sscc = P_sscc,
	   gtin = P_gtin,
	   gtin_serial        = NULL,
	   inventory_item_id  = NULL,
	   serial_number      = NULL,
	   filter_object_type = p_filter_value,
	   status      = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE lpn_id = p_lpn_id;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					P_epc_rule_type_id,
					p_lpn_id,
					NULL,--p_serial_number,
					NULL,--p_ITEM_ID,
					NULL,--p_GTIN_SERIAL,
					P_gtin,
					P_sscc,
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
	 DELETE FROM wms_epc WHERE lpn_id = p_lpn_id;

      END IF;


    ELSIF p_cross_ref_type = 2 THEN -- Item_Serial - EPC /* Serial Label */

      IF p_action =  'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_id,
	   sscc = NULL,-- No other value possible
	   gtin = P_gtin,
	   gtin_serial = NULL,
	   lpn_id = NULL,
	   filter_object_type = p_filter_value,
	   status = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE inventory_item_id  = p_item_id
	   AND serial_number        = p_serial_number;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					P_epc_rule_type_id,
					NULL,-- lpn_id
					p_serial_number,
					p_item_id,
					NULL,--p_gtin_serial,
					P_gtin,
					NULL,--p_sscc
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
	 DELETE FROM wms_epc
	   WHERE inventory_item_id  = p_item_id
	   AND serial_number        = p_serial_number;


      END IF;

    ELSIF  p_cross_ref_type = 3 THEN --GTIN+GTIN_Serial - EPC /* Material Label */

      IF p_action = 'UPDATE' THEN

	 UPDATE wms_epc
	   SET epc          = p_gen_epc,
	   cross_ref_type   = p_cross_ref_type,
	   group_id         = p_group_id,
	   last_update_date = Sysdate,
	   last_updated_by  = fnd_global.user_id,
	   epc_rule_type_id = p_epc_rule_type_id,
	   sscc = NULL, --NO other value possible in this case
	   serial_number = NULL,
	   inventory_item_id  = NULL,
	   lpn_id = NULL,
	   filter_object_type = p_filter_value,
	   status = 'LABEL_PRINTED',
	   status_code = 'S'
	   WHERE GTIN      = p_gtin
	   AND GTIN_serial = p_gtin_serial;

       ELSIF p_action =  'INSERT' THEN

	 --INSERT NEW EPC RECORD

	 INSERT INTO wms_epc( group_id,
			      cross_ref_type,
			      epc_rule_type_id,
			      lpn_id,
			      serial_number,
			      inventory_item_id,
			      gtin_serial,
			      gtin,
			      sscc,
			      epc,
			      filter_object_type,
			      status_code,
			      status,
			      creation_date,
			      created_by,
			      last_update_date,
			      last_updated_by,
			      last_update_login,
			      epc_id,
			      epc_rule_id
			      ) VALUES (P_group_id,
					p_cross_ref_type,
					P_epc_rule_type_id,
					NULL ,-- p_lpn_id
					NULL, --p_serial_number
					NULL, --p_item_id,
					p_GTIN_serial,
					P_gtin,
					NULL, --p_sscc,
					P_gen_epc,
					p_filter_value,
					'S',
					'LABEL_PRINTED',
					Sysdate,
					fnd_global.user_id,
					Sysdate,
					fnd_global.user_id,
					fnd_global.user_id,
				        NULL,  --epc_id NOT used post R12
					NULL); --epc_rule_id NOT used post R12

       ELSIF p_action =  'DELETE' THEN

	 -- Delete the existing cross -reference
      DELETE FROM wms_epc
	WHERE GTIN      = p_gtin
	AND GTIN_serial = p_gtin_serial;

      END IF;


   END IF;


  --COMMIT THE autonomous txn part of updating record in WMS_EPC
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
	 TRACE('UPTODATE WMS_EPC: inside exception');
	 TRACE('ERROR CODE = ' || SQLCODE);
	 TRACE('ERROR MESSAGE = ' || SQLERRM);
      END IF;

END  uptodate_wms_epc;

--Given EPC_rule_type and company_prefix, calculates the pre-defined
--PARTITION value (specified by EPC global standard)
--FUNCTION applicable to DB versions below RDBMS12c
FUNCTION get_PARTITION_value(p_epc_rule_type IN VARCHAR2,
			     P_company_prefix IN VARCHAR2) RETURN  NUMBER
  IS
     l_partition NUMBER;
     l_comp_pref_len NUMBER;
BEGIN

   /*
   following TYPE OF epc TYPE required PARTITION length
     epc_sgtin_96
     epc_sscc_96
     epc_giai_96
     epc_grai_96
     epc_sgln_96

     DoD-96/64 - does NOT need partition value
     */


     --GET THE decimal length of company-prefix
     l_comp_pref_len := Length(P_company_prefix);


   IF p_epc_rule_type = 'EPC_SGTIN_96' OR p_epc_rule_type = 'EPC_SSCC_96'
     OR p_epc_rule_type ='EPC_SGLN_96' OR p_epc_rule_type = 'EPC_GIAI_96'
     OR  p_epc_rule_type = 'EPC_GRAI_96' THEN

      IF l_comp_pref_len = 12	 THEN l_partition := 0;
       ELSIF l_comp_pref_len =11 THEN l_partition := 1;
       ELSIF l_comp_pref_len =10 THEN l_partition := 2;
       ELSIF l_comp_pref_len =9  THEN l_partition := 3;
       ELSIF l_comp_pref_len =8  THEN l_partition := 4;
       ELSIF l_comp_pref_len =7  THEN l_partition := 5;
       ELSIF l_comp_pref_len =6  THEN l_partition := 6;
       ELSE l_partition := -1; --Error condition
      END IF;

    ELSE

      l_partition := 0; --partition is not needed for this STANDARD EPC TYPE generation

   END IF;

   RETURN l_partition;

END  get_PARTITION_value;


--Collects all informtion needed to generate EPC for given object
-- For a given EPC generation type the output parameter x_components
-- contains required elements that will be passed to DB- EPC generation API
-- to generate EPC
--PROCEDURE applicable to DB versions below RDBMS12c
PROCEDURE get_epc_gen_info( p_org_id          IN NUMBER,
			    p_lpn_id          IN NUMBER,   --FOR  p_label_type_id = 3,4,5
			    p_serial_number   IN VARCHAR2, --FOR p_label_type_id = 2
			    p_item_id         IN NUMBER,   --FOR  p_label_type_id = 1,2
			    p_txn_qty           IN NUMBER,    --FOR  p_label_type_id = 1
			    p_txn_uom           IN VARCHAR2,  --FOR  p_label_type_id = 1
			    p_rev                IN VARCHAR2, --FOR  p_label_type_id = 1,2
			    p_company_prefix     IN VARCHAR2,
			    p_comp_prefix_index  IN VARCHAR2,
			    p_business_flow_code IN NUMBER,
			    p_label_type_id      IN NUMBER,
			    p_epc_rule_type      IN VARCHAR2,
			    p_filter_value       IN NUMBER,
			    p_cage_code          IN VARCHAR2, --FOR p_label_type_id = 2
			    p_partition_value    IN NUMBER,
			    x_gtin          OUT nocopy NUMBER,
			    x_sscc          OUT nocopy NUMBER,
			    x_gtin_serial   OUT nocopy NUMBER,
			    x_components    OUT nocopy mgd_idcomponent_varray,
			    x_return_status OUT nocopy VARCHAR2)
  IS

     l_components MGD_IDCOMPONENT_VARRAY;

     l_sscc_len NUMBER;
     l_gtin_len NUMBER;
     l_lpn_num_format NUMBER;
     l_is_sscc_valid BOOLEAN := TRUE;
     l_is_gtin_valid BOOLEAN := TRUE;
     l_item_id NUMBER;
     l_total_qty NUMBER :=0;
     l_found_gtin NUMBER := 0;
     l_rev VARCHAR2(3);
     l_uom_code VARCHAR2(3);
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_gtin NUMBER;

     l_total_wlc_qty NUMBER;
     l_total_mmtt_qty NUMBER;
     l_total_mmtt_qty1 NUMBER;
     l_total_mmtt_qty2 NUMBER;
     l_comp_prefix_dig_len NUMBER;
     l_item_reference NUMBER;
     l_serial_reference NUMBER;
     l_gtin_serial NUMBER;
     l_sscc NUMBER;

     l_return_status VARCHAR2(1);
     --l_primary_uom_code VARCHAR2(3);

     ----------------------------------------
     /*
     Following table shows Valid set up in Label Format Form for EPC
       generation using diferent standard (X means acceptable)

       Standard\LabelType LPN/LPNContent/LPNSummary Material Serial
          SGTIN_96/64	         X	                X      X
          SSCC_96/64	         X		        -      -
          DoD_96/64	         -                      -      X
       */
     -----------------------------------------


BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF p_label_type_id IN (3,4,5) THEN --LPN, LPN Content, LPN Summary

      l_comp_prefix_dig_len:= Length(p_company_prefix);

      IF p_epc_rule_type IN ('EPC_SGTIN_96','EPC_SGTIN_64') THEN

	 -- {{get GTIN and gtin-Serial for the LPN }}
	 get_lpn_gtin_serial(p_lpn_id => p_lpn_id,
			     p_org_id => p_org_id,
			     p_filter_value       => p_filter_value,
			     p_business_flow_code =>  p_business_flow_code,
			     x_gtin          => l_gtin,
			     x_gtin_serial   => l_gtin_serial,
			     x_return_status => l_return_status);

	 --{{ get the item reference from GTIN for LPN now }}
	 --{{ l_gtin obtained IS NOT NULL }}

	 IF l_return_status = fnd_api.g_ret_sts_success AND l_gtin IS NOT NULL THEN

	    l_item_reference := To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    IF l_debug = 1 THEN
	       trace('l_gtin , l_gtin_serial :' || l_gtin||','||l_gtin_serial);
	       trace('l_item_reference :'|| l_item_reference);
	    END IF;

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;

	    --{{ get all expected components FOR EPC_SGTIN_96}}
	    IF p_epc_rule_type = 'EPC_SGTIN_96' THEN

	       --use company-prefix

	       IF l_debug = 1 THEN
		  trace('p_filter_value,p_partition_value, p_company_prefix,l_item_reference,l_gtin_serial');
		  trace(p_filter_value||','||p_partition_value||','||To_number(p_company_prefix)||','||l_item_reference||','||l_gtin_serial);
	       END IF;

	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',48,NULL), --for 00110000
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('PARTITION',p_partition_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIX',To_number(p_company_prefix),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));


	     ELSIF p_epc_rule_type = 'EPC_SGTIN_64' THEN

	       --{{ get all expected components FOR EPC_SGTIN_64}}
	       --use company-prefix -INDEX
	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',2,NULL),--10
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIXINDEX',To_number(p_comp_prefix_index),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));

	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF  get_lpn_gtin_serial()
	 END IF;


       ELSIF p_epc_rule_type IN ('EPC_SSCC_96','EPC_SSCC_64') THEN

	 --{{ get SSCC for LPN }}

	 l_sscc := get_sscc(p_lpn_id,p_org_id);

	  IF l_debug = 1 THEN
	     trace('SSCC for the LPN      :'||l_sscc);
	     trace('l_comp_prefix_dig_len :'||l_comp_prefix_dig_len);
	     trace('p_filter_value        :'||p_filter_value);
	     trace('To_number(p_company_prefix) :'|| To_number(p_company_prefix));
	  END IF;


	  IF l_sscc IS  NOT NULL THEN

	     x_gtin  := NULL;
	     x_sscc  := l_sscc;
	     x_gtin_serial := NULL;

	     --{{ get serial reference from SSCC }}
	     l_serial_reference := To_number(Substr(To_char(L_sscc),1,1)||Substr(To_char(l_sscc),l_comp_prefix_dig_len+2,(16-l_comp_prefix_dig_len)));

	     IF l_debug = 1 THEN

		trace('l_serial_reference :'|| l_serial_reference);
	     END IF;
	     --{{ get all expected components FOR EPC_SSCC_96 for containers}}
	     IF p_epc_rule_type = 'EPC_SSCC_96' THEN
		--use company-prefix
		l_components := mgd_idcomponent_varray(MGD_IDCOMPONENT('HEADER',49,NULL), --for 00110001
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('PARTITION',p_partition_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIX',To_number(p_company_prefix),NULL),
						 MGD_IDCOMPONENT('SERIALREFERENCE',l_serial_reference,NULL),
						 MGD_IDCOMPONENT('UNALLOCATED',0,NULL));
	      ELSIF p_epc_rule_type = 'EPC_SSCC_64' THEN


		--{{ get all expected components FOR EPC_SSCC_64 for containers}}
		l_components :=
		  mgd_idcomponent_varray(MGD_IDCOMPONENT('HEADER',8,NULL), --00001000
				   MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
				   MGD_IDCOMPONENT('COMPANYPREFIXINDEX',To_number(p_comp_prefix_index),NULL),
				   MGD_IDCOMPONENT('SERIALREFERENCE',l_serial_reference,NULL));


	     END IF;

	   ELSE --means l_sscc is NULL
	     IF l_debug = 1 THEN
		trace('Error : Incorrect SSCC value set up for the LPN');
	     END IF;

	     RAISE  fnd_api.g_exc_error;
	  END IF;


       ELSIF p_epc_rule_type IN ('EPC_DOD_96','EPC_DOD_64') THEN


	 --This is INVALID  option for EPC generation FOR LPN label
	 IF l_debug = 1 THEN
	    trace('Error:For LPN label, No EPC can be generated using EPC_DOD_96/64, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;
      END IF;

    ELSIF  p_label_type_id =1 THEN  /*Material Label*/

      l_comp_prefix_dig_len:= Length(p_company_prefix);

      IF l_debug = 1 THEN
	 trace('l_comp_prefix_dig_len :'||l_comp_prefix_dig_len);
      END IF;

      IF p_epc_rule_type IN ('EPC_SGTIN_96','EPC_SGTIN_64') THEN
	 -- for item_id and qty + UOM, find any set up in GTIN C/R
	 -- Generate EPC for that GTIN.

	 get_item_gtin_serial(p_item_id  => p_item_id,
			      p_org_id   => p_org_id,
			      p_qty      => p_txn_qty,
			      p_uom_code => p_txn_uom,
			      p_rev      => l_rev,
			      x_gtin          => l_gtin,
			      x_gtin_serial   => l_gtin_serial,
			      x_return_status => l_return_status);



	 IF   l_return_status = fnd_api.g_ret_sts_success AND  l_gtin IS NOT NULL THEN


	    --{{ get the item reference from GTIN for the Item now }}

	    l_item_reference :=
	      To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;

	    IF p_epc_rule_type = 'EPC_SGTIN_96' THEN

	       --{{ get all expected components FOR EPC_SGTIN_96 for Item}}
	       --use company-prefix
	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',48,NULL), --for 00110000
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('PARTITION',p_partition_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIX',To_number(p_company_prefix),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));

	     ELSIF p_epc_rule_type = 'EPC_SGTIN_64' THEN

	       IF l_debug = 1 THEN
		  trace('p_comp_prefix_index :'||To_number(p_comp_prefix_index));
		  trace('p_filter_value      :'||p_filter_value);
		  trace('l_item_reference    :'||l_item_reference);
		  trace('l_gtin_serial       :'||l_gtin_serial);
	       END IF;

	       --{{ get all expected components FOR EPC_SGTIN_64 for Item}}
	       --use company-prefix -INDEX
	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',2,NULL),--10
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIXINDEX',To_number(p_comp_prefix_index),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));


	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF  get_item_gtin_serial()
	 END IF;

       ELSIF p_epc_rule_type IN ('EPC_SSCC_96','EPC_SSCC_64') THEN
	 --This is INVALID  option for EPC generation of Material
	 IF l_debug = 1 THEN
	    trace('Error:For Material, No EPC can be generated using SSCC, incorrect SET up');
	 END IF;

	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;


       ELSIF p_epc_rule_type IN ('EPC_DOD_96','EPC_DOD_64') THEN

	 IF l_debug = 1 THEN
	    trace('Error:For Material, No EPC can be generated using EPC_DOD, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;


      END IF;

    ELSIF p_label_type_id = 2 THEN  /*Serial Label*/
      --Components: FILTER,CAGE, SERIAL_NUMBER

      IF p_epc_rule_type IN ('EPC_SGTIN_96','EPC_SGTIN_64') THEN

	 --Generate EPC for that item for GTIN corresponding to Primary UOM.
	 --we have p_serial_number + p_item_id + p_cage_code+ p_filter_value

	 --P_serial_number will be totally ignored while generating EPC. GTIN_Serial
	 --will be used but it will be stored in wms_EPC table against the
	 --Item+p_serial_number

	 -- for item_id and qty + UOM, find any set up in GTIN C/R
	 -- Generate EPC for that GTIN.

	  IF l_debug = 1 THEN
	     trace('going to call get_serialnum_gtin_serial');
	  END IF;

	 get_serialnum_gtin_serial(p_item_id       => p_item_id,
				   p_org_id        => p_org_id,
				   p_rev           => l_rev,
				   x_gtin          => l_gtin,
				   x_gtin_serial   => l_gtin_serial,
				   x_return_status => l_return_status);


   	 --{{ get the item reference from GTIN for the Item now }}


	  IF l_debug = 1 THEN
	     trace('After call get_serialnum_gtin_serial');
	     trace('l_return_status :'||l_return_status);
	     trace('l_gtin :'||l_gtin);
	     trace('l_gtin_serial :'||l_gtin_serial);
	  END IF;


	 IF l_return_status= fnd_api.g_ret_sts_success AND l_gtin IS NOT NULL THEN

	    l_item_reference :=
	      To_number(Substr(To_char(l_gtin),1,1)||Substr(To_char(l_gtin),l_comp_prefix_dig_len+2,12-l_comp_prefix_dig_len));

	    x_gtin  := l_gtin;
	    x_sscc  := NULL;
	    x_gtin_serial := l_gtin_serial;


	    IF p_epc_rule_type = 'EPC_SGTIN_96' THEN

	       --{{ get all expected components FOR EPC_SGTIN_96 for Item}}
	       --use company-prefix
	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',48,NULL), --for 00110000
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('PARTITION',p_partition_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIX',To_number(p_company_prefix),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));
	     ELSIF p_epc_rule_type = 'EPC_SGTIN_64' THEN

	       --{{ get all expected components FOR EPC_SGTIN_64 for Item}}
	       --use company-prefix -INDEX
	       l_components := mgd_idcomponent_varray( MGD_IDCOMPONENT('HEADER',2,NULL),--10
						 MGD_IDCOMPONENT('FILTERVALUE',p_filter_value,NULL),
						 MGD_IDCOMPONENT('COMPANYPREFIXINDEX',To_number(p_comp_prefix_index),NULL),
						 MGD_IDCOMPONENT('ITEMREFERENCE',l_item_reference,NULL),
						 MGD_IDCOMPONENT('SERIALNUMBER',l_gtin_serial,NULL));

	    END IF;
	    --WHEN GTIN = NULL IS HANDLED IN THE EXCEPTION OF
	    --get_serialnum_gtin_serial() -> get_gtin_and_gserial()

	 END IF;

       ELSIF p_epc_rule_type IN ('EPC_SSCC_96','EPC_SSCC_64') THEN
	 --This is INVALID  option for EPC generation of Serial NUMBER
	 IF l_debug = 1 THEN
	    trace('Error:For Serial, No EPC can be generated using SSCC, incorrect SET up');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_SETUP');
	 FND_MSG_PUB.ADD;
	 RAISE  fnd_api.g_exc_error;

       ELSIF p_epc_rule_type IN ('EPC_DOD_96','EPC_DOD_64') THEN
	 --{{Note: We MUST have Serial uniqueness across items for EPC generation EPC_DOD_96/EPC_DOD_64}}

	 x_gtin  := NULL;
	 x_sscc  := NULL;
	 x_gtin_serial := NULL;

	 IF p_epc_rule_type = 'EPC_DOD_96' THEN
	    --{{ get all expected components FOR EPC_DOD_96 for container}}

	    l_components := mgd_idcomponent_varray(MGD_IDCOMPONENT('HEADER',207,NULL),--11001111
					     MGD_IDCOMPONENT('FILTER',p_filter_value,NULL),
					     MGD_IDCOMPONENT('GOVERNMENTMANAGEDIDENTIFIER',NULL,p_cage_code),
					     MGD_IDCOMPONENT('SERIALNUMBER',p_serial_number,NULL));


	  ELSIF  p_epc_rule_type = 'EPC_DOD_64' THEN
	    --{{ get all expected components FOR EPC_DOD_96 for container }}

	    IF l_debug = 1 THEN
	       trace('Inside EPC_DOD_64 to collect components');
	    END IF;

	    l_components := mgd_idcomponent_varray(MGD_IDCOMPONENT('HEADER',206,NULL),--11001110
					     MGD_IDCOMPONENT('FILTER',p_filter_value,NULL),
					     MGD_IDCOMPONENT('GOVERNMENTMANAGEDIDENTIFIER',NULL,p_cage_code),
					     MGD_IDCOMPONENT('SERIALNUMBER',p_serial_number,NULL));

	 END IF;


      END IF;

   END IF;

    x_components :=  l_components;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_gtin_serial := NULL;
      x_gtin        :=NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin_serial := NULL;
      x_gtin        :=NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here


   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 trace('Unexpected error inside get_epc_gen_info()');
	 trace('ERROR CODE    = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_gtin_serial := NULL;
      x_gtin        := NULL;
      x_sscc        := NULL;
      x_components  := NULL;
      --RAISE; -- Do not raise here
END get_epc_gen_info;



---This API caches all EPC generation Rule type from the core DB EPC
--TABLES AND keeps it in memory for future calls
--FUNCTION applicable to DB versions below RDBMS12c
FUNCTION Cache_and_get_rule(p_partition_val IN NUMBER,
			    p_type_name IN VARCHAR2,
			    p_category_id IN NUMBER) RETURN NUMBER AS

CURSOR c_epc_gen_rule_types IS
  select type_id, type_name, nvl(partition_value,0) partition_value
    ,category_id
    from mgd_idencoding_type ;

l_index NUMBER;
l_epc_type_id NUMBER := NULL;
l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF l_debug = 1 THEN
      trace('Inside Cache_and_get_rule');
      trace('p_partition_val:'||p_partition_val);
      trace('p_type_name  :'||p_type_name );
      trace(' p_category_id :'||   p_category_id);

   END IF;

   IF g_cached_rule_pkg.COUNT() = 0 THEN --Not cached Yet

      IF l_debug = 1 THEN
	 trace('Caching the rule first time ###########');
      END IF;

      --Cache the rule
      l_index := 1;

      FOR l_epc_gen_rule_types IN c_epc_gen_rule_types LOOP

	 g_cached_rule_pkg(l_index).type_id         :=l_epc_gen_rule_types.TYPE_id;
	 g_cached_rule_pkg(l_index).type_name       :=l_epc_gen_rule_types.type_name;
	 g_cached_rule_pkg(l_index).partition_value :=l_epc_gen_rule_types.partition_value;
	 g_cached_rule_pkg(l_index).category_id     :=l_epc_gen_rule_types.category_id;

	 IF l_epc_gen_rule_types.type_name = p_type_name
	   AND l_epc_gen_rule_types.partition_value = p_partition_val
           AND l_epc_gen_rule_types.category_id = p_category_id THEN

	    l_epc_type_id := l_epc_gen_rule_types.type_id;

	 END IF;

	 l_index := l_index + 1;
      END LOOP;

    ELSE --from the cached rule return proper type_id

      IF l_debug = 1 THEN
	 trace('Retrieving EPC rule from the cache ###########');
      END IF;

      FOR i IN g_cached_rule_pkg.FIRST..g_cached_rule_pkg.LAST
	LOOP

	   IF l_debug = 1 THEN
	      trace('g_cached_rule_pkg(i).type_name:'||g_cached_rule_pkg(i).type_name);
	      trace('g_cached_rule_pkg(i).partition_value :'||g_cached_rule_pkg(i).partition_value);
	      trace('g_cached_rule_pkg(i).category_id :'||g_cached_rule_pkg(i).category_id );
	   END IF;



	   IF g_cached_rule_pkg(i).type_name = p_type_name
	     AND g_cached_rule_pkg(i).partition_value = p_partition_val

	     /* OR
	     (p_partition_val IS NULL AND
	     g_cached_rule_pkg(i).partition_value IS NULL) )*/

		    AND g_cached_rule_pkg(i).category_id = p_category_id THEN

	      l_epc_type_id := g_cached_rule_pkg(i).type_id;

	      EXIT; -- got matching rule, Exit the loop
	   END IF;
	END LOOP;

	IF l_debug = 1 THEN
	   trace('Returned EPC rule type id :'||l_epc_type_id);
	END IF;


   END IF;


   RETURN  l_epc_type_id;

EXCEPTION
   WHEN OTHERS THEN

      IF l_debug = 1 THEN
	 trace('Exception in Cache_and_get_rule');
	 trace('ERROR CODE = ' || SQLCODE);
	 trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;


END Cache_and_get_rule;



--*********************************************
/*
Procedure generate_epc

  FUNCTIONALITY:-
  This is the main API in this package that is responsible for generating
  EPC for current transaction

  PARAMETER:-
   p_org_id          : Organization id
   p_label_type_id   : Supported LPN/Serial/Material labels : VALID VALUES 1,2,3,4,5
   p_group_id	     : groun_id per invocation
   p_label_format_id : label_format_id for this transaction that should have has epc field
   p_item_id         : need TO pass fpr Material Label: 1 only
   p_txn_qty         : need TO pass fpr Material Label: 1 only
   p_txn_uom         : need TO pass fpr Material Label: 1 only (since uom is not in wms_label_requests table)
   p_label_request_id: the id from wms_label_requests foe which label will be generated
   p_business_flow_code : business flow code value
   x_epc : returns generated EPC
   x_return_status :-
     S : success : EPC generated     E : error   : EPC could not be generated for valid reason
     U : Warning : EPC could not be generated for unexpected reason

   x_return_mesg : Appropriate error message

  */

 --*********************************************
 --PROCEDURE applicable to DB versions below RDBMS12c
  Procedure generate_epc
  (p_org_id          IN NUMBER,
   p_label_type_id   IN NUMBER, /* VALID VALUES 1,2,3,4,5*/
   p_group_id	     IN	NUMBER,
   p_label_format_id IN NUMBER,
   p_item_id            IN NUMBER   DEFAULT NULL, --For Material Label: 1
   p_txn_qty            IN NUMBER   DEFAULT null, --For Material Label: 1
   p_txn_uom            IN VARCHAR2 DEFAULT NULL, --For Material Label: 1
   p_label_request_id   IN NUMBER,
   p_business_flow_code IN NUMBER DEFAULT NULL,
   x_epc             OUT nocopy VARCHAR2,
   x_return_status   OUT nocopy VARCHAR2,
   x_return_mesg     OUT nocopy VARCHAR2
   ) IS

      end_processing EXCEPTION;
      l_gen_epc VARCHAR2(260);
      l_sscc NUMBER;
      l_gtin NUMBER;
      l_gtin_serial NUMBER;
      l_epc VARCHAR2(260);
      l_msg_count NUMBER;

      l_return_status VARCHAR2(1);
      l_regenerate_flag VARCHAR2(1) := 'N';
      l_filter_value NUMBER;
      l_outermost_lpn_id NUMBER;
      l_PARENT_lpn_id NUMBER;
      l_return_mesg VARCHAR2(2000);
       --l_existing_epc_rule_id NUMBER;
      l_epc_output_rep NUMBER;

      --New parameters
      is_epc_enabled VARCHAR2(1);
      l_company_prefix VARCHAR2(30);
      l_company_prefix_index VARCHAR2(30);
      l_cage_code VARCHAR2(30);
      l_custom_company_prefix VARCHAR2(30);
      l_epc_rule_type VARCHAR2(100);
      l_epc_rule_type_id NUMBER;
      l_partition_value NUMBER;
      l_cust_comp_prefix_index NUMBER;
      l_comp_prefix_len NUMBER;
      l_cross_ref_type NUMBER;
      l_epc_category_id NUMBER;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_lpn_id NUMBER;
      l_serial_number VARCHAR2(30);
      l_item_id NUMBER;
      l_rev VARCHAR2(3);
      l_bit_length NUMBER;
      l_components mgd_idcomponent_varray := mgd_idcomponent_varray(mgd_idcomponent('HEADER',NULL,null));
      pcode      mgd_idcode;

  BEGIN

     G_PROFILE_GTIN  := FND_PROFILE.value('INV:GTIN_CROSS_REFERENCE_TYPE');
     x_return_status := fnd_api.g_ret_sts_success;

     IF l_debug = 1 THEN
	trace('************ inside generate_epc ***********');
	trace('p_org_id             :'||p_org_id);
	trace(' p_label_request_id  :'||p_label_request_id);
	trace('p_business_flow_code :'||p_business_flow_code);
	trace('p_group_id           :'||p_group_id);
	trace('p_label_type_id      :'||p_label_type_id);
	trace('p_label_format_id    :'||p_label_format_id);
	trace('p_item_id            :'||p_item_id);
	trace('p_txn_qty            :'||p_txn_qty);
	trace('p_txn_uom            :'||p_txn_uom);

      END IF;


      --{{get needed information from mtl_parameters setup for EPC generation }}
      IF ( NOT Inv_Cache.set_org_rec( p_organization_id => p_org_id ))THEN
	 IF (l_debug = 1) THEN
	    trace(p_org_id || 'is an invalid organization id');
	 END IF;
	 fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      l_company_prefix       := inv_cache.org_rec.company_prefix;
      l_company_prefix_index :=  inv_cache.org_rec.company_prefix_index;


      IF l_debug = 1 THEN
	 trace('epc_enabled            :'||Nvl(inv_cache.org_rec.epc_generation_enabled_flag,'N'));
	 trace('l_company_prefix       :'||l_company_prefix);
	 trace('l_company_prefix_index :'||l_company_prefix_index);
	 trace('cage_code              :'||inv_cache.org_rec.commercial_govt_entity_number);
      END IF;

      --{{get needed information from label formats setup for the format_id}}
      SELECT epc_rule_type,filter_value,generate_epc,epc_category_id
	INTO l_epc_rule_type,l_filter_value,l_regenerate_flag, l_epc_category_id
	FROM wms_label_formats
	WHERE label_format_id = p_label_format_id
	AND Nvl(label_ENTITY_type,0) =0;  --label format and NOT label-set

      IF l_debug = 1 THEN
	 trace('l_epc_rule_type   :'||l_epc_rule_type);
	 trace('l_filter_value    :'||l_filter_value);
	 trace('l_regenerate_flag :'||l_regenerate_flag);
	 trace('l_epc_category_id :'||l_epc_category_id);
      END IF;

      --Check if EPC is enabled
      IF Nvl(inv_cache.org_rec.epc_generation_enabled_flag,'N') = 'Y' THEN

	 --Get required information about the current transaction
	 SELECT lpn_id,serial_number,inventory_item_id,revision
	   INTO   l_lpn_id,l_serial_number,l_item_id, l_rev
	   FROM wms_label_requests
	   WHERE label_request_id =  p_label_request_id;


	 IF l_debug = 1 THEN
	    trace('l_lpn_id,l_serial_number,l_item_id, l_rev :'||l_lpn_id||','||l_serial_number||','||l_item_id||','||l_rev);
	 END IF;

	 --Find if the EPC cross-ref already exist or it needs to be re-created
	 --For LPN

	 IF l_lpn_id IS NOT NULL AND  p_label_type_id IN (3,4,5) THEN /* LPN / LPN-Content / LPN Summary*/

	    l_cross_ref_type := 1;--/*LPN-EPC Cross ref*/

           BEGIN
	       SELECT wlpn.parent_lpn_id, wlpn.outermost_lpn_id, we.epc
		 INTO l_parent_lpn_id, l_outermost_lpn_id, l_epc
		 FROM wms_license_plate_numbers wlpn, wms_epc we
		 WHERE wlpn.lpn_id =  l_lpn_id
		 AND wlpn.lpn_id = we.lpn_id(+)
		 AND ((we.epc is NOT NULL and Nvl(we.cross_ref_type,1) = 1)
		     or (we.epc is NULL )) ;
		     --Nvl(we.cross_ref_type,1) to support EPC generated
		     --using 11.5.10.2CU code

	      -- starting R12 this must be
	      -- populated AND old data needs to be updated

	   EXCEPTION
	      WHEN no_data_found THEN

		 IF l_debug = 1 THEN
		    trace('NO DATA found for the LPN');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_unexpected_error;
	   END;

	   --Neither pallet or case, then NO support FOR EPC of further
	   -- nested lpn, error out
	   IF  NOT ((l_outermost_lpn_id = l_lpn_id AND l_parent_lpn_id IS null )
	     OR (l_parent_lpn_id = l_outermost_lpn_id AND l_parent_lpn_id IS NOT null)) THEN

	      fnd_message.set_name('WMS', 'WMS_NO_MULTI_NESTING_SUPPORT');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;

	   END IF;

	 --For Serial
	 ELSIF l_serial_number IS NOT NULL AND  p_label_type_id = 2 THEN  --/* Serial Label*/

	       l_cross_ref_type := 2;--/*Serial-EPC Cross ref*/

	       --Item_id + Serial_number will uniquely mapped to an EPC
               BEGIN
		  SELECT we.epc INTO l_epc
		    FROM  wms_epc we
		    WHERE INVENTORY_item_id = l_item_id
		    AND serial_number = l_serial_number
		    AND we.cross_ref_type = 2;
	       EXCEPTION
		  WHEN no_data_found THEN
		     NULL;
		  WHEN  OTHERS THEN
		     RAISE fnd_api.g_exc_unexpected_error;
	       END;

	       --For item_id/GTIN
	 ELSIF l_item_id IS NOT NULL AND p_label_type_id = 1 THEN --/*Material Label*/

		     l_cross_ref_type := 3; --/*GTIN+GTIN_SERIAL-EPC Cross ref*/

		     --No need to check whether EPC exists or NOT for the GTIN
		     --just regenerate EPC, EPC will be unique to GTIN+GTIN-SERIAL combination
		     --and it needs to be inserted

		     l_regenerate_flag := 'Y'; -- override always
	END IF;


	--{{call to see if the custom company_prefix is implemented}}
	wms_epc_pub.GET_CUSTOM_COMPANY_PREFIX(
					      p_org_id => p_org_id,
					      p_label_request_id => p_label_request_id,
					      X_company_prefix  => l_custom_company_prefix,
					      X_RETURN_STATUS  => l_return_status);

	--{{call to see if the custom company_prefix_INDEX is implemented}}
	wms_epc_pub.GET_CUSTOM_COMP_PREFIX_INDEX(p_org_id   => p_org_id,
						 p_label_request_id => p_label_request_id,
						 X_comp_prefix_INDEX => l_CUST_comp_prefix_INDEX,
						 X_RETURN_STATUS     => l_return_status);

	IF l_debug = 1 THEN
	   trace('CUSTOM_COMPANY_PREFIX value :'||l_custom_company_prefix);
	   trace('CUSTOM_COMPANY_PREFIX_INDEX value :'||l_cust_comp_prefix_index);
	END IF;

	IF l_custom_company_prefix IS NOT NULL THEN
	   l_company_prefix := l_custom_company_prefix;
	END IF;

	IF l_cust_comp_prefix_index IS NOT NULL THEN
	   l_company_prefix_index :=  l_cust_comp_prefix_index;
	END IF;

	IF l_debug = 1 THEN
	   trace('Final COMPANY_PREFIX value :'||l_company_prefix);
	   trace('Final COMPANY_PREFIX_INDEX value :'||l_company_prefix_index );
	END IF;


	l_partition_value :=get_PARTITION_value(l_epc_rule_type, l_company_prefix);

	IF l_debug = 1 THEN
	   trace('l_partition_value :'||l_partition_value);
	END IF;



	--{{ see if partition value returned is correct and get the l_epc_rule_type_id now}}

	 IF l_partition_value = -1 THEN --prefix length is INCORRECT
	    fnd_message.set_name('WMS','WMS_INCORRECT_PREFIX_LEN');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;

	  ELSE
	    --To avoid DB table call for each read:
	    --Cache Entire rule in the memory if first time call
	    --otherwise get epc generation rule type for current txn

	    IF l_debug = 1 THEN
	       trace('GOING TO CALL Cache_and_get_rule');
	    END IF;


	    l_epc_rule_type_id := Cache_and_get_rule(l_partition_value, l_epc_rule_type,l_epc_category_id);

	    --NULL value OF PARTITION  will be treated AS 0

	 END IF;

	 IF l_epc_rule_type_id IS NULL THEN
	    x_epc := NULL;
	    fnd_message.set_name('WMS','WMS_NO_EPC_RULE_FOUND');--No rule found
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;


	IF l_debug = 1 THEN
	   trace('Generating EPC now.............');
	END IF;

	--{{ See if the rule is custom or Un-Implemented Standard Rule }}
	IF l_epc_category_id <> mgd_idcode_utl.epc_encoding_category_id
	  OR ( l_epc_category_id = mgd_idcode_utl.epc_encoding_category_id AND
	        l_epc_rule_type NOT IN  ('EPC_SGTIN_96','EPC_SSCC_96','EPC_SGTIN_64','EPC_SSCC_64','EPC_DOD_96','EPC_DOD_64') )
	  --means in ('EPC_GIAI_96','EPC_GRAI_96','EPC_SGLN_96','EPC_GID_96','EPC_GIAI_64','EPC_GRAI_64','EPC_SGLN_64','EPC_GID_64')
	  THEN

	   -- {{ get custom EPC generated }}
	   wms_epc_pub.get_custom_epc
	     (p_org_id        => p_org_id,
	      p_category_id      => l_epc_category_id,-- In mgd_idencoding_type table
	      p_epc_rule_type_id => l_epc_rule_type_id, --Rule_type_id IN mgd_idencoding_type table
	      p_filter_value  => l_filter_value,
	      p_label_request_id => p_label_request_id, --to get all data FROM wms_device_requests label
	      x_return_status => l_return_status,
	      x_return_mesg   => l_return_mesg,
	      x_epc           => l_epc);

	 ELSIF  l_epc_rule_type IN
	   ('EPC_SGTIN_96','EPC_SSCC_96','EPC_SGTIN_64','EPC_SSCC_64','EPC_DOD_96','EPC_DOD_64') THEN
	   --{{ get standard EPC generated for standard rule}}

	   --{{ Check to see if regenerate flag is ON..only then generate epc }}
	   IF l_regenerate_flag = 'Y' OR (l_epc is NULL AND
					  Nvl(l_regenerate_flag,'N') = 'N' ) THEN

	      --{{ get EPC Encoding Rule components }}
	      IF l_debug = 1 THEN
		 trace('Collecting information to generate EPC ....');
	      END IF;

	      get_epc_gen_info( p_org_id          => p_org_id,
				p_lpn_id          => l_lpn_id,   --FOR  p_label_type_id = 3,4,5
				p_serial_number   => l_serial_number, --FOR  p_label_type_id = 2
				p_item_id         => Nvl(l_item_id,p_item_id),  --FOR  p_label_type_id = 1
				p_txn_qty         => p_txn_qty,  --FOR  p_label_type_id = 1
				p_txn_uom         => p_txn_uom,  --FOR  p_label_type_id = 1
				p_rev             => l_rev,      --FOR  p_label_type_id = 1,2
				p_company_prefix  => l_company_prefix,
				p_comp_prefix_index  => l_company_prefix_index,
				p_business_flow_code => p_business_flow_code,
				p_label_type_id      => P_label_type_id,
				p_epc_rule_type      => l_epc_rule_type,
				p_filter_value       => l_filter_value,
				p_cage_code          => inv_cache.org_rec.commercial_govt_entity_number,  --FOR p_label_type_id = 2
				p_partition_value    => l_partition_value,
				x_gtin               => l_gtin,
				x_sscc               => l_sscc,
				x_gtin_serial        => l_gtin_seriaL,
				x_components         => l_components,
				x_return_status      => l_return_status);

	       IF l_debug = 1 THEN
		  trace('after calling  get_epc_gen_info... ');
		  trace('l_gtin :'||l_gtin );
		  trace('l_sscc :'||l_sscc);
		  trace('l_gtin_serial :'||l_gtin_serial);
		  trace('l_return_status :'||l_return_status);
	       END IF;


	      --{{ genereate EPC using the components }}

	      IF l_return_status = fnd_api.g_ret_sts_success  AND l_components IS NOT NULL THEN


		 -- This is needed to pass correct value (NULL Vs 0)in the DB API
		 --In some case NULL and anohter 0 is needed
		 IF (l_epc_rule_type IN
		   ('EPC_DOD_96','EPC_DOD_64','EPC_SGTIN_64','EPC_SSCC_64','EPC_SGLN_64','EPC_GRAI_64','EPC_GIAI_64','EPC_GID_96')) AND (l_partition_value = 0) THEN
		    l_partition_value := NULL;

		 END IF;


		  IF l_debug = 1 THEN
		     trace('Before calling DB EPC category_name :'||mgd_idcode_utl.EPC_ENCODING_CATEGORY_NAME);
		     trace('partition_val :'||l_partition_value);
		  END IF;

		 BEGIN
		 pcode := mgd_idcode( category_name    => mgd_idcode_utl.EPC_ENCODING_CATEGORY_NAME,
				      category_agency   => NULL,
				      category_version  => NULL,
				      category_uri      => NULL,
				      encoding_type_name => l_epc_rule_type, --mgd_idcode_utl.EPC_SGTIN_96,
				      partition_val      =>  l_partition_value,
				      components         =>  l_components);

		 l_gen_epc := pcode.bit_encoding; --EPC in HEXA system

		 IF l_debug = 1 THEN
		    trace('EPC generated by DB Feature :'||l_gen_epc);
		 END IF;

		 EXCEPTION
		    WHEN OTHERS THEN

		       IF l_debug = 1 THEN
			  TRACE('After calling mgd_idcode: Inside exception');
			  TRACE('ERROR CODE = ' || SQLCODE);
			  TRACE('ERROR MESSAGE = ' || SQLERRM);
		       END IF;

		       --EPC generation failed at DB feature level
		       fnd_message.set_name('WMS', 'WMS_DB_EPC_GEN_FAIL');
		       fnd_msg_pub.ADD;

		       --Do not raise exception here as we want to delete
		       --old cross-reference RECORD FROM wms_epc for some
		       --CASES BELOW
		 END;

	       ELSE
		 -- {{Error out l_components are null, EPC could not be generated }}

		 IF l_debug = 1 THEN
		    trace('get_epc_gen_info() returned error');
		    trace('Error: Components could not be obtained for EPC generation ');
		 END IF;


		 fnd_message.set_name('WMS', 'WMS_EPC_GEN_FAIL');
		 fnd_msg_pub.ADD;

		 --Do not raise exception here as we want to delete
		 --old cross-reference RECORD FROM wms_epc for some
		 --CASES BELOW

	      END IF; --l_return_status = 'S for get_epc_gen_info()


	   END IF; --l_regenerate_flag = 'Y'

	END IF; --means 'EPC_SGTIN_96','EPC_SSCC_96','EPC_SGTIN_64','EPC_SSCC_64',EPC_DOD_96,EPC_DOD_64''EPC_SGTIN_96','EPC_SSCC_96'

      ELSE
		     IF l_debug = 1 THEN
			trace('EPC generation is NOT enabled at Orgnization level');
		     END IF;

		     fnd_message.set_name('WMS', 'WMS_EPC_DISABLED');
		     fnd_msg_pub.ADD;
		     RAISE fnd_api.g_exc_error;

     END IF;


     --{{ By NOW EPC should be generate for valid cases: Insert EPC or update EPC or delete EPC }}

     IF l_debug = 1 THEN
	trace('Old EPC,if any   :'||l_epc);
	trace('New generated EPC:'||l_gen_epc);
     END IF;



     --{{ Get the EPC ENCODING defined with the profile 'WMS_EPC_ENCODING'}}
     l_epc_output_rep := NVL(fnd_profile.value('WMS_EPC_ENCODING'), 2);
     -- 1 : Binary
     -- 2 : Hex
     -- 3 : Decimal

     IF l_debug = 1 THEN
	trace('1-Binary,2-Hex,3-Decimal l_epc_output_rep :'||l_epc_output_rep);
     END IF;

     --l_epc_rule_type_id is already identified above
     IF l_regenerate_flag = 'Y' OR (l_epc is NULL AND
				    Nvl(l_regenerate_flag,'N') = 'N' ) THEN


	IF l_epc IS NOT NULL AND l_gen_epc IS NOT NULL THEN
	   --{{ EPC c/r already there: UPDATE LAST EPC with new EPC value }}
	   uptodate_wms_epc ( p_action   => 'UPDATE',
			      p_group_id         => p_group_id,
			      p_cross_ref_type   => l_cross_ref_type,
			      p_EPC_rule_TYPE_id => l_EPC_rule_TYPE_id,
			      p_lpn_id           => l_lpn_id,
			      p_item_id          => l_item_id,
			      p_serial_number    => l_serial_number,
			      p_gen_epc          => l_gen_epc,
			      p_sscc             => l_sscc,
			      p_gtin             => l_gtin,
			      p_gtin_serial      => l_gtin_serial,
			      p_filter_VALUE     => l_filter_value,
			      x_return_status    => L_RETURN_STATUS);


	   IF l_debug =1 then
	      trace(' uptodate_wms_epc UPDATE: L_RETURN_STATUS:'||l_return_status);
	   END IF;


	   --return new EPC IN THE FORMAT SPECIFIED
	   IF L_epc_output_rep = 1 THEN --Binary
	      l_bit_length := To_number(Substr(l_epc_rule_type,(Length(l_epc_rule_type)-1),Length(l_epc_rule_type)));
	      x_epc := Lpad(dec2bin(hex2dec(l_gen_epc)),l_bit_length,'0');

	    ELSIF l_epc_output_rep = 3 THEN --Decimal
	      x_epc := hex2dec(l_gen_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_gen_epc;
	   END IF;


	 ELSIF l_epc IS NOT NULL AND l_gen_epc IS NULL THEN
	   -- Delete the existing cross -reference

	   uptodate_wms_epc ( p_action   => 'DELETE',
			      p_group_id         => p_group_id,
			      p_cross_ref_type   => l_cross_ref_type,
			      p_EPC_rule_TYPE_id => l_EPC_rule_TYPE_id,
			      p_lpn_id           => l_lpn_id,
			      p_item_id          => l_item_id,
			      p_serial_number    => l_serial_number,
			      p_gen_epc          => l_gen_epc,
			      p_sscc             => l_sscc,
			      p_gtin             => l_gtin,
			      p_gtin_serial      => l_gtin_serial,
			      p_filter_VALUE     => l_filter_value,
			      x_return_status    => L_RETURN_STATUS);

	   IF l_debug =1 then
	      trace(' uptodate_wms_epc DELETE: L_RETURN_STATUS:'||l_return_status);
	   END IF;

	   RAISE fnd_api.g_exc_error;--COULD NOT OVERIDE THE EPC


	 ELSIF l_epc IS NULL AND l_gen_epc IS NOT NULL THEN

	   uptodate_wms_epc( p_action   => 'INSERT',
			     p_group_id         => p_group_id,
			     p_cross_ref_type   => l_cross_ref_type,
			     p_EPC_rule_TYPE_id => l_EPC_rule_TYPE_id,
			     p_lpn_id           => l_lpn_id,
			     p_item_id          => l_item_id,
			     p_serial_number    => l_serial_number,
			     p_gen_epc          => l_gen_epc,
			     p_sscc             => l_sscc,
			     p_gtin             => l_gtin,
			     p_gtin_serial      => l_gtin_serial,
			     p_filter_VALUE     => l_filter_value,
			     x_return_status    => L_RETURN_STATUS);

	   IF l_debug =1 then
	      trace(' uptodate_wms_epc INSERT: L_RETURN_STATUS:'||l_return_status);
	   END IF;

	   --return new EPC IN THE FORMAT SPECIFIED
	   IF l_epc_output_rep = 1 THEN
	      l_bit_length := To_number(Substr(l_epc_rule_type,(Length(l_epc_rule_type)-1),Length(l_epc_rule_type)));
	      x_epc := Lpad(dec2bin(hex2dec(l_gen_epc)),l_bit_length,'0');
	    ELSIF l_epc_output_rep = 3 THEN
	      x_epc := hex2dec(l_gen_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_gen_epc;
	   END IF;


	 ELSIF l_epc IS NULL AND l_gen_epc IS NULL THEN

	   RAISE fnd_api.g_exc_error;

	END IF;

      ELSIF Nvl(l_regenerate_flag,'N') = 'N' THEN

	IF l_epc IS NOT NULL THEN

	   --Return Old EPC,Already it was stored in Hex
	   --return new EPC IN THE FORMAT SPECIFIED
	   IF l_epc_output_rep = 1 THEN
	      l_bit_length := To_number(Substr(l_epc_rule_type,(Length(l_epc_rule_type)-1),Length(l_epc_rule_type)));
	      x_epc := Lpad(dec2bin(hex2dec(l_gen_epc)),l_bit_length,'0');
	    ELSIF l_epc_output_rep = 3 THEN
	      x_epc := hex2dec(l_epc);
	    ELSIF l_epc_output_rep = 2 OR l_epc_output_rep IS NULL THEN --Hex
	      x_epc := l_epc;
	   END IF;


	END IF; -- L_EPC IS NOT NULL

     END IF; -- For p_regenerate_flag = 'N'



  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
	fnd_message.set_name('WMS','WMS_EPC_GEN_FAIL');
	fnd_msg_pub.ADD;
	x_return_status  := fnd_api.g_ret_sts_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_encoded  => 'F',p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	IF l_debug = 1 THEN
	   TRACE('Inside g_exc_error l_msg_count :'||l_msg_count);
	   TRACE('x_return_mesg :'||x_return_mesg);
	END IF;

	-- FND_MSG_PUB.initialize;  --bug 5178424


     WHEN fnd_api.g_exc_unexpected_error THEN
	fnd_message.set_name('WMS', 'WMS_EPC_GEN_FAIL');
	fnd_msg_pub.ADD;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	IF l_debug = 1 THEN
	   TRACE('Inside g_exc_unexpected_error l_msg_count :'||l_msg_count);
	   TRACE('x_return_mesg :'||x_return_mesg);
	END IF;

	 -- FND_MSG_PUB.initialize; --bug 5178424

     WHEN OTHERS THEN
	--ROLLBACK; blocked in R12
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	x_epc := NULL;
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => x_return_mesg);

	FOR i IN 1..l_msg_count LOOP
	   x_return_mesg := x_return_mesg || fnd_msg_pub.get(I,'F');
	END LOOP;

	-- FND_MSG_PUB.initialize;  --bug 5178424

	IF l_debug = 1 THEN
	   TRACE('generate EPC: Inside exception');
	   TRACE('ERROR CODE = ' || SQLCODE);
	   TRACE('ERROR MESSAGE = ' || SQLERRM);
	END IF;

  END generate_epc;

  --FUNCTION applicable to DB versions below RDBMS12c
  FUNCTION db_version RETURN NUMBER IS
	BEGIN
		trace('Call from forms for DB version, returning 10 as DB is 11gR2 or lower so that old model is used');
		RETURN 10;
  END db_version;

$END

/* NOT USED. Coded in R12 but not used
FUNCTION is_epc_enabled(p_org_id IN NUMBER) RETURN VARCHAR2 IS

   l_is_epc_enabled NUMBER :=0;

BEGIN

   IF g_epc_org_id.count > 0 then

      FOR i IN g_epc_org_id.FIRST..g_epc_org_id.last LOOP
	 IF g_epc_org_id(i) = p_org_id then
	    RETURN 'Y';
	 END IF;
      END LOOP;
   END IF;

   BEGIN
      SELECT  1
	INTO  l_is_epc_enabled
	FROM mtl_parameters
	WHERE organization_id = p_org_id
	AND Nvl(epc_generation_enabled_flag, 'N') = 'Y';
   EXCEPTION
      WHEN no_data_found then
	 l_is_epc_enabled :=0;
      WHEN others THEN
	 l_is_epc_enabled :=0;
   END;

   IF l_is_epc_enabled = 1 THEN
      g_epc_org_id(nvl(g_epc_org_id.count,0) + 1 ) := p_org_id;
      RETURN 'Y';
    ELSE
       RETURN 'N';
   END IF;


END is_epc_enabled;
*/


  END wms_epc_pvt;

/
