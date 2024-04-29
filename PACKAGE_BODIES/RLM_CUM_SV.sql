--------------------------------------------------------
--  DDL for Package Body RLM_CUM_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_CUM_SV" AS
/* $Header: RLMCUMMB.pls 120.5.12010000.2 2008/07/30 12:54:08 sunilku ship $ */

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
/*=============================== rlm_cum_sv ===============================*/

/*============================================================================

  PROCEDURE NAME:	CalculateCumKey

=============================================================================*/

 PROCEDURE CalculateCumKey (
        x_cum_key_record IN     RLM_CUM_SV.cum_key_attrib_rec_type,
        x_cum_record     IN OUT NOCOPY RLM_CUM_SV.cum_rec_type)
 IS
	v_rlm_setup_terms_record	rlm_setup_terms_sv.setup_terms_rec_typ;
	v_cum_control_code	 	rlm_cust_shipto_terms.cum_control_code%TYPE;
	v_cum_org_level_code	 	rlm_cust_shipto_terms.cum_org_level_code%TYPE;
	v_address_id		 	NUMBER;
	v_terms_level		 	VARCHAR2(20) DEFAULT NULL;
	v_setup_terms_status	 	BOOLEAN;
	v_start_date_num          	NUMBER;
	v_record_year_num         	NUMBER;
	v_setup_terms_msg		VARCHAR2(2000);

     /* These are variables used as switches when finding cum key ids.
	Initially, all the switches are turned OFF by setting each to NULL */
	p_ship_from_org_id		NUMBER DEFAULT NULL;
	p_ship_to_address_id		NUMBER DEFAULT NULL;
	p_intrmd_ship_to_address_id	NUMBER DEFAULT NULL;
	p_bill_to_address_id		NUMBER DEFAULT NULL;
	p_customer_item_id		NUMBER DEFAULT NULL;
	p_purchase_order_number 	RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE DEFAULT NULL;
	p_cust_record_year		RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE DEFAULT NULL;
	p_cum_start_date		DATE   DEFAULT NULL;
	E_UNEXPECTED    		EXCEPTION;
	v_ship_from_org_name		VARCHAR2(250) DEFAULT NULL;
	v_customer_name			VARCHAR2(360) DEFAULT NULL;
	v_ship_to_location		VARCHAR2(250) DEFAULT NULL;
	v_customer_item_number		VARCHAR2(250) DEFAULT NULL;
    --
    v_OrgId                         NUMBER;
    --
 BEGIN
   --
   -- DEBUGGING - INPUT Values
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'CalculateCumKey');
      rlm_core_sv.dlog(C_DEBUG, '');
      rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE INPUT VALUES:');
      rlm_core_sv.dlog(C_DEBUG, '--------------------------');
      rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id', x_cum_key_record.ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', x_cum_key_record.ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'bill_to_address_id', x_cum_key_record.bill_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'intrmd_ship_to_address_id', x_cum_key_record.intrmd_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'customer_item_id', x_cum_key_record.customer_item_id);
      rlm_core_sv.dlog(C_DEBUG, 'purchase_order_number', x_cum_key_record.purchase_order_number);
      rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_key_record.cum_start_date);
      rlm_core_sv.dlog(C_DEBUG, 'cust_record_year', x_cum_key_record.cust_record_year);
      rlm_core_sv.dlog(C_DEBUG, 'create_cum_key', x_cum_key_record.create_cum_key_flag);
      rlm_core_sv.dlog(C_DEBUG, 'actual_shipment_date', x_cum_record.actual_shipment_date);
      rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', x_cum_record.shipped_quantity);
   END IF;
   --
   -- Get the current Org ID and raise error if the current Org is not set
   -- This piece of code has been added as a fail-safe mechanism, we
   -- always expect the current org context to be set before this API
   -- is called
   --
   v_OrgId := MO_GLOBAL.get_current_org_id;
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Current Org ID', v_OrgId);
   END IF;
   --
   IF v_OrgID IS NULL THEN
    --
    x_cum_record.msg_name := 'RLM_OU_CONTEXT_NOT_SET';
    rlm_message_sv.get_msg_text(
                 x_message_name  => x_cum_record.msg_name,
                 x_text          => x_cum_record.msg_data);
    --
    RAISE e_Unexpected;
    --
   END IF;
   --
-- Determine whether to use Ship To or Intermediate Ship To
   --
   IF x_cum_key_record.intrmd_ship_to_address_id IS NULL THEN
	--
	IF x_cum_key_record.ship_to_address_id IS NULL THEN
		--
                x_cum_record.msg_name := 'RLM_CUM_ADDRESS_REQUIRED';
		rlm_message_sv.get_msg_text(
	  		x_message_name	=> x_cum_record.msg_name,
	  		x_text		=> x_cum_record.msg_data);
		RAISE E_UNEXPECTED;
		--
	ELSE
		--
		v_address_id := x_cum_key_record.ship_to_address_id;
		--
	END IF;
	--
   ELSE
	--
	IF x_cum_key_record.ship_to_address_id IS NULL THEN
		--
		v_address_id := x_cum_key_record.intrmd_ship_to_address_id;
		--
	ELSE
		--
		v_address_id := x_cum_key_record.ship_to_address_id;
		--
	END IF;
	--
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'address_id', v_address_id);
   END IF;
   --
-- Get the CUM Control Code from the setup terms table
   --
   RLM_TPA_SV.get_setup_terms(
	x_ship_from_org_id 		=> x_cum_key_record.ship_from_org_id,
	x_customer_id 			=> x_cum_key_record.customer_id,
	x_ship_to_address_id 		=> v_address_id,
	x_customer_item_id		=> x_cum_key_record.customer_item_id,
	x_terms_definition_level 	=> v_terms_level,
	x_terms_rec			=> v_rlm_setup_terms_record,
	x_return_message		=> v_setup_terms_msg,
	x_return_status			=> v_setup_terms_status);
   --
   IF v_setup_terms_status = FALSE THEN
		--
		v_ship_from_org_name := RLM_CORE_SV.get_ship_from(x_cum_key_record.ship_from_org_id);
		v_customer_name := RLM_CORE_SV.get_customer_name(x_cum_key_record.customer_id);
		v_ship_to_location := RLM_CORE_SV.get_ship_to(v_address_id);
		v_customer_item_number := RLM_CORE_SV.get_item_number(x_cum_key_record.customer_item_id);
		--
                x_cum_record.msg_name := 'RLM_CUM_SETUP_TERMS_REQUIRED';
                --
		rlm_message_sv.get_msg_text(
	  			x_message_name	=> x_cum_record.msg_name,
	  			x_text		=> x_cum_record.msg_data,
				x_token1	=> 'SF',
				x_value1	=> v_ship_from_org_name,
				x_token2	=> 'CUST',
				x_value2	=> v_customer_name,
				x_token3	=> 'ST',
				x_value3	=> v_ship_to_location,
				x_token4	=> 'CI',
				x_value4	=> v_customer_item_number);
		--
        	RAISE E_UNEXPECTED;
		--
   ELSE
	--
        IF v_rlm_setup_terms_record.cum_control_code IS NULL THEN
			--
                        x_cum_record.msg_name := 'RLM_CUM_CTRLCD_REQUIRED';
                        --
			rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
			--
           		RAISE E_UNEXPECTED;
			--
        ELSE
	   --
	   IF v_terms_level = 'CUSTOMER_ITEM' THEN
	      --
              IF v_rlm_setup_terms_record.calc_cum_flag <> 'Y'
                 OR v_rlm_setup_terms_record.calc_cum_flag IS NULL THEN
			--
			v_ship_from_org_name := RLM_CORE_SV.get_ship_from(x_cum_key_record.ship_from_org_id);
			v_customer_name := RLM_CORE_SV.get_customer_name(x_cum_key_record.customer_id);
			v_ship_to_location := RLM_CORE_SV.get_ship_to(v_address_id);
		v_customer_item_number := RLM_CORE_SV.get_item_number(x_cum_key_record.customer_item_id);
			--
                        x_cum_record.msg_name := 'RLM_CUM_NO_CALC_FLAG';
                        --
			rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data,
					x_token1	=> 'CI',
					x_value1	=> v_customer_item_number);
			--
                	RAISE E_UNEXPECTED;
			--
              END IF;
	      --
           END IF;
	   --
        END IF;
	--
   END IF;
   --
-- CUM Organization Level
   --
   v_cum_org_level_code := v_rlm_setup_terms_record.cum_org_level_code;
   --
/* Customer Item Id is always populated in the CUM Key table regardless of
   CUM control code or CUM Organization Level. Ship From Organization Id
   is always populated in the CUM Key table except for the case of
   ALL_SHIP_FROMS. Therefore, the switches below are turned ON and
   assigned to the associated parameters passed by the calling program */
   --
   p_customer_item_id := x_cum_key_record.customer_item_id;
   p_ship_from_org_id := x_cum_key_record.ship_from_org_id;
   --
   IF v_rlm_setup_terms_record.cum_control_code <> 'NO_CUM' THEN
     --
     IF (x_cum_key_record.cum_start_date
                                           = rlm_manage_demand_sv.K_DNULL)
        AND (NVL(v_rlm_setup_terms_record.cum_control_code,'NO_CUM')
        IN ('CUM_BY_DATE_PO','CUM_BY_DATE_RECORD_YEAR','CUM_BY_DATE_ONLY'))
     THEN
       --
       rlm_cum_sv.GetLatestCum(x_cum_key_record,
                    v_rlm_setup_terms_record,
                    x_cum_record);
       --
       IF x_cum_record.record_return_status = FALSE THEN
         --
         fnd_file.put_line(fnd_file.log,x_cum_record.msg_data);
         --
       END IF;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_DEBUG,'CalculateCumKey');
       END IF;
       --
       RETURN;
       --
     END IF;
     --
 --Turn ON switches based on cum control code
     --
     IF v_rlm_setup_terms_record.cum_control_code = 'CUM_BY_PO_ONLY' THEN
	  --
	  IF (x_cum_key_record.purchase_order_number IS NULL) THEN
			--
                        x_cum_record.msg_name := 'RLM_CUM_PO_REQUIRED';
                        --
			rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
			--
                   	RAISE E_UNEXPECTED;
			--
	  END IF;
		--
		p_purchase_order_number := x_cum_key_record.purchase_order_number;
		--
     ELSIF v_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_ONLY'
	   OR v_rlm_setup_terms_record.cum_control_code = 'CUM_UNTIL_MANUAL_RESET' THEN
	--
	IF x_cum_key_record.cum_start_date IS NULL THEN
	--
                  x_cum_record.msg_name := 'RLM_CUM_START_DT_REQUIRED';
                  --
                  rlm_message_sv.get_msg_text(
	  		x_message_name	=> x_cum_record.msg_name,
	  		x_text		=> x_cum_record.msg_data);
                  --
                	RAISE E_UNEXPECTED;
			--
		END IF;
		--
		p_cum_start_date := x_cum_key_record.cum_start_date;
		--
	--
     ELSIF v_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_RECORD_YEAR' THEN
	--
        IF (x_cum_key_record.cum_start_date IS NULL)
            OR (x_cum_key_record.cust_record_year IS NULL) THEN
		--
                x_cum_record.msg_name := 'RLM_CUM_REC_YEAR_REQUIRED';
                --
		rlm_message_sv.get_msg_text(
  				x_message_name	=> x_cum_record.msg_name,
  				x_text		=> x_cum_record.msg_data);
		--
                RAISE E_UNEXPECTED;
		--
        END IF;
	--
        p_cum_start_date := x_cum_key_record.cum_start_date;
	p_cust_record_year := x_cum_key_record.cust_record_year;
	--
     ELSIF v_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_PO' THEN
	--
	IF (x_cum_key_record.cum_start_date IS NULL)
            OR (x_cum_key_record.purchase_order_number IS NULL) THEN
		--
                x_cum_record.msg_name := 'RLM_CUM_DATE_PO_REQUIRED';
                --
		rlm_message_sv.get_msg_text(
  				x_message_name	=> x_cum_record.msg_name,
  				x_text		=> x_cum_record.msg_data);
		--
            	RAISE E_UNEXPECTED;
		--
	END IF;
	--
	p_purchase_order_number := x_cum_key_record.purchase_order_number;
        p_cum_start_date := x_cum_key_record.cum_start_date;
	--
     ELSE
			--
                        x_cum_record.msg_name := 'RLM_CUM_DATE_PO_REQUIRED';
                        --
			rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
			--
	                RAISE E_UNEXPECTED;
			--
     END IF;
     --
   ELSE
		--
		v_ship_from_org_name := RLM_CORE_SV.get_ship_from(x_cum_key_record.ship_from_org_id);
		v_customer_name := RLM_CORE_SV.get_customer_name(x_cum_key_record.customer_id);
		v_ship_to_location := RLM_CORE_SV.get_ship_to(v_address_id);
		v_customer_item_number := RLM_CORE_SV.get_item_number(x_cum_key_record.customer_item_id);
		--
                x_cum_record.msg_name := 'RLM_CUM_NO_CUM_CALC';
                --
		rlm_message_sv.get_msg_text(
	  			x_message_name	=> x_cum_record.msg_name,
	  			x_text		=> x_cum_record.msg_data,
				x_token1	=> 'CUST',
				x_value1	=> v_customer_name,
				x_token2	=> 'ST',
				x_value2	=> v_ship_to_location);
		--
	        RAISE E_UNEXPECTED;
		--
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'cum_control_code', v_rlm_setup_terms_record.cum_control_code);
      rlm_core_sv.dlog(C_DEBUG, 'cum_org_level_code', v_cum_org_level_code);
      rlm_core_sv.dlog(C_DEBUG, ' ');
      rlm_core_sv.dlog(C_DEBUG, 'The setup terms were retrieved at this level: ', v_terms_level);
   END IF;
   --
-- Turn ON/OFF switches based on cum organization level code
   --
   IF v_cum_org_level_code = 'BILL_TO_SHIP_FROM' THEN
		--
		IF x_cum_key_record.bill_to_address_id IS NULL THEN
		       --
                       x_cum_record.msg_name := 'RLM_CUM_BILL_TO_REQUIRED';
                       --
		       rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
		       --
                       RAISE E_UNEXPECTED;
		       --
		END IF;
		--
		p_bill_to_address_id := x_cum_key_record.bill_to_address_id;
		--
   ELSIF v_cum_org_level_code = 'SHIP_TO_SHIP_FROM' THEN
		--
		IF x_cum_key_record.ship_to_address_id IS NULL THEN
		       --
                       x_cum_record.msg_name := 'RLM_CUM_SHIP_TO_REQUIRED';
                       --
		       rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
		       --
                       RAISE E_UNEXPECTED;
		       --
		END IF;
		--
	        p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
		--
   ELSIF v_cum_org_level_code = 'INTRMD_SHIP_TO_SHIP_FROM' THEN
		--
		IF x_cum_key_record.intrmd_ship_to_address_id IS NULL THEN
		       --
                       x_cum_record.msg_name := 'RLM_CUM_INTER_SHIP_TO_REQUIRED';
                       --
		       rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
		       --
                       RAISE E_UNEXPECTED;
		       --
		END IF;
		--
	        p_intrmd_ship_to_address_id := x_cum_key_record.intrmd_ship_to_address_id;
   ELSIF v_cum_org_level_code = 'SHIP_TO_ALL_SHIP_FROMS' THEN
		p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
   		p_ship_from_org_id := NULL;
		--
   ELSE
		       --
                       x_cum_record.msg_name := 'RLM_CUM_UNKNOWN_ORG_LEVEL';
                       --
		       rlm_message_sv.get_msg_text(
	  				x_message_name	=> x_cum_record.msg_name,
	  				x_text		=> x_cum_record.msg_data);
		       --
	               RAISE E_UNEXPECTED;
		       --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'cust_record_year', x_cum_key_record.cust_record_year);
      rlm_core_sv.dlog(C_DEBUG, '');
      rlm_core_sv.dlog(C_DEBUG, 'ATTRIBUTES ACTUALLY USED TO FIND/CREATE THE KEY:');
      rlm_core_sv.dlog(C_DEBUG, '------------------------------------------------');
      rlm_core_sv.dlog(C_DEBUG, 'p_ship_from_org_id', p_ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_ship_to_address_id', p_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_intrmd_ship_to_address_id', p_intrmd_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_bill_to_address_id', p_bill_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_customer_item_id', p_customer_item_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_purchase_order_number', p_purchase_order_number);
      rlm_core_sv.dlog(C_DEBUG, 'p_cust_record_year', p_cust_record_year);
      rlm_core_sv.dlog(C_DEBUG, 'p_cum_start_date', p_cum_start_date);
   END IF;
   --
   --Find the cum key id using the CUM RULES
   --
   IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS'THEN
   --
      	SELECT 	cum_key_id,
	    	cum_qty,
     		cum_qty_to_be_accumulated,
		cum_qty_after_cutoff,
     		last_cum_qty_update_date,
     		cust_uom_code
     		INTO  	x_cum_record.cum_key_id,
     		x_cum_record.cum_qty,
     		x_cum_record.cum_qty_to_be_accumulated,
     		x_cum_record.cum_qty_after_cutoff,
     		x_cum_record.last_cum_qty_update_date,
     		x_cum_record.cust_uom_code
     		FROM   RLM_CUST_ITEM_CUM_KEYS
     		WHERE  NVL(ship_from_org_id,0)		= NVL(p_ship_from_org_id,0)
      		AND    NVL(ship_to_address_id,0)     	= NVL(p_ship_to_address_id,0)
      		AND    NVL(intrmd_ship_to_id,0) 	= NVL(p_intrmd_ship_to_address_id,0)
      		AND    NVL(bill_to_address_id,0)     	= NVL(p_bill_to_address_id,0)
      		AND    NVL(customer_item_id,0) 	   	= NVL(p_customer_item_id,0)
      		AND    NVL(purchase_order_number,' ')	= NVL(p_purchase_order_number, ' ')
      		AND    NVL(cust_record_year, ' ')	= NVL(p_cust_record_year, ' ')
      		AND    NVL(TRUNC(cum_start_date), sysdate)
                              = NVL(TRUNC(p_cum_start_date), sysdate)
                AND     NVL(inactive_flag,'N')          =  'N';
--truncation for bug 1667299
	--
   ELSE
	--
      	SELECT	cum_key_id,
     		cum_qty,
     		cum_qty_to_be_accumulated,
		cum_qty_after_cutoff,
     		last_cum_qty_update_date,
     		cust_uom_code
     		INTO	x_cum_record.cum_key_id,
     		x_cum_record.cum_qty,
     		x_cum_record.cum_qty_to_be_accumulated,
		x_cum_record.cum_qty_after_cutoff,
     		x_cum_record.last_cum_qty_update_date,
     		x_cum_record.cust_uom_code
     		FROM   RLM_CUST_ITEM_CUM_KEYS
    		WHERE  ship_from_org_id IS NULL
		AND    NVL(ship_to_address_id, 0)	= NVL(p_ship_to_address_id,0)
      		AND    NVL(intrmd_ship_to_id, 0) 	= NVL(p_intrmd_ship_to_address_id,0)
      		AND    NVL(bill_to_address_id, 0)    	= NVL(p_bill_to_address_id,0)
      		AND    NVL(customer_item_id, 0) 	= NVL(p_customer_item_id,0)
      		AND    NVL(purchase_order_number,' ')	= NVL(p_purchase_order_number, ' ')
      		AND    NVL(cust_record_year, ' ')	= NVL(p_cust_record_year, ' ')
      		AND    NVL(TRUNC(cum_start_date), sysdate)
                	= NVL(TRUNC(p_cum_start_date), sysdate)
                AND     NVL(inactive_flag,'N')          =  'N';
--truncation for bug 1667299
		--
   END IF;
   --
   x_cum_record.cum_start_date := p_cum_start_date;
   x_cum_record.record_return_status := TRUE;
   x_cum_record.cum_key_created_flag := FALSE;
   x_cum_record.shipment_rule_code := v_rlm_setup_terms_record.cum_shipment_rule_code;

   IF x_cum_record.cum_qty IS NULL THEN
      x_cum_record.cum_qty := 0;
   END IF;

   IF x_cum_record.cum_qty_to_be_accumulated IS NULL THEN
      x_cum_record.cum_qty_to_be_accumulated := 0;
   END IF;

   IF x_cum_record.cum_qty_after_cutoff IS NULL THEN
      x_cum_record.cum_qty_after_cutoff := 0;
   END IF;
   --
   /* DEBUGGING - OUTPUT Values */
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, '');
      rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES:');
      rlm_core_sv.dlog(C_DEBUG, '---------------------------');
      rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', x_cum_record.cum_key_id);
      rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_record.cum_start_date);
      rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', x_cum_record.shipped_quantity);
      rlm_core_sv.dlog(C_DEBUG, 'actual_shipment_date', x_cum_record.actual_shipment_date);
      rlm_core_sv.dlog(C_DEBUG, 'cum_key_created_flag', x_cum_record.cum_key_created_flag);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'as_of_date_cum_qty', x_cum_record.as_of_date_cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
      rlm_core_sv.dlog(C_DEBUG, 'last_cum_qty_update_date', x_cum_record.last_cum_qty_update_date);
      rlm_core_sv.dlog(C_DEBUG, 'cust_uom_code', x_cum_record.cust_uom_code);
      rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', x_cum_record.shipment_rule_code);
      rlm_core_sv.dlog(C_DEBUG, 'use_ship_incl_rule_flag', x_cum_record.use_ship_incl_rule_flag);
      rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
      rlm_core_sv.dpop(C_DEBUG, 'Cum key record is retrieved successfully');
   END IF;
   --
   EXCEPTION
	--
	WHEN TOO_MANY_ROWS THEN
	   --
           x_cum_record.msg_name := 'RLM_CUM_TOO_MANY_ROWS';
           --
	   rlm_message_sv.get_msg_text(
	  		x_message_name	=> x_cum_record.msg_name,
	  		x_text		=> x_cum_record.msg_data);
	   --
	   x_cum_record.record_return_status := FALSE;
	   --
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'msg_data', x_cum_record.msg_data);
             rlm_core_sv.dpop(C_DEBUG, 'TOO_MANY_ROWS');
	   END IF;
	   --
	WHEN NO_DATA_FOUND THEN
	   --
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'No cum key id is found');
             rlm_core_sv.dlog(C_DEBUG, 'disable_create_cum_key_flag',v_rlm_setup_terms_record.disable_create_cum_key_flag);
             rlm_core_sv.dlog(C_DEBUG, 'v_orgId ', v_orgId);
	   END IF;
	   --
	   --IF x_cum_key_record.create_cum_key_flag = 'Y' THEN
           IF (nvl(v_rlm_setup_terms_record.disable_create_cum_key_flag,'N') = 'N'
                AND x_cum_key_record.create_cum_key_flag = 'Y' OR (g_manual_cum)) -- BugFix #4147544
	   THEN

	     --------------------------------------------------------------------+
	     /* Insert a new cum key record if the record does not exist yet and
	    	if the calling progam sets the create cum key flag to 'Y' */

		--
            	BEGIN
		  --
		  x_cum_record.cum_qty := 0;
		  x_cum_record.cum_qty_to_be_accumulated := 0;
		  x_cum_record.cum_qty_after_cutoff := 0;
		  --
		  INSERT INTO rlm_cust_item_cum_keys_all(
			cum_key_id,
			cum_qty,
			cum_qty_to_be_accumulated,
			cum_qty_after_cutoff,
			customer_item_id,
			ship_to_address_id,
			bill_to_address_id,
			intrmd_ship_to_id,
			ship_from_org_id,
			cum_start_date,
			cust_record_year,
			purchase_order_number,
			last_cum_qty_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_date,
			cust_uom_code,
                        org_id)
		  VALUES(
			rlm_cust_item_cum_keys_s.nextval,
			x_cum_record.cum_qty,
			x_cum_record.cum_qty_to_be_accumulated,
			x_cum_record.cum_qty_after_cutoff,
			p_customer_item_id,
			p_ship_to_address_id,
			p_bill_to_address_id,
			p_intrmd_ship_to_address_id,
			p_ship_from_org_id,
			p_cum_start_date,
			p_cust_record_year,
			p_purchase_order_number,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			sysdate,
			x_cum_record.cust_uom_code,
                        v_OrgId);
		  --
		  SELECT	rlm_cust_item_cum_keys_s.currval
		  INTO		x_cum_record.cum_key_id
		  FROM		DUAL;
		  --
		  x_cum_record.cum_start_date := p_cum_start_date;
		  x_cum_record.cum_key_created_flag := TRUE;
		  x_cum_record.record_return_status := TRUE;
		  x_cum_record.last_cum_qty_update_date := SYSDATE;
		  --
                  x_cum_record.msg_name := 'RLM_CUM_KEY_ID_CREATED';
                  --
		  rlm_message_sv.get_msg_text(
	  			x_message_name	=> x_cum_record.msg_name,
	  			x_text		=> x_cum_record.msg_data);
		  --
	        --DEBUGGING - Output Values
                  IF (l_debug <> -1) THEN
   	   	    rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE NEWLY INSERTED RECORD VALUES');
              	    rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', x_cum_record.cum_key_id);
              	    rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_record.cum_start_date);
              	    rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', x_cum_record.shipped_quantity);
              	    rlm_core_sv.dlog(C_DEBUG, 'actual_ship_date', x_cum_record.actual_shipment_date);
              	    rlm_core_sv.dlog(C_DEBUG, 'cum_key_created', x_cum_record.cum_key_created_flag);
              	    rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
              	    rlm_core_sv.dlog(C_DEBUG, 'cust_uom_code', x_cum_record.cust_uom_code);
              	    rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
   	  	    rlm_core_sv.dpop(C_DEBUG, x_cum_record.msg_data);
	   	  END IF;
		  --
                EXCEPTION
		  --
		  WHEN OTHERS THEN
			--
                        x_cum_record.msg_name := 'RLM_CUM_KEY_NOT_CREATED';
                        --
			rlm_message_sv.get_msg_text(
	  			x_message_name	=> x_cum_record.msg_name,
	  			x_text		=> x_cum_record.msg_data,
				x_token1	=> 'SQLERRM',
				x_value1	=> SQLERRM);
			--
	             	x_cum_record.record_return_status := FALSE;
			--
                        IF (l_debug <> -1) THEN
   	             	  rlm_core_sv.dlog(C_DEBUG, x_cum_record.msg_data);
   	             	  rlm_core_sv.dpop(C_DEBUG, SQLERRM);
	             	END IF;
			--
                END;
                ----------------------------------------------------------------+

	   ELSE
		-- If create_cum_key_flag is 'N', set record return status to TRUE
		--
                x_cum_record.cum_key_id := NULL; -- Bug 4667349
		x_cum_record.record_return_status := TRUE;
		--
                IF (l_debug <> -1) THEN
   	   	  rlm_core_sv.dpop(C_DEBUG, 'CUM Key Id is not found, and not created as create_cum_key_flag is set to N');
	   	END IF;
		--
	   END IF;
	   --
        WHEN E_UNEXPECTED THEN
	    --
	    x_cum_record.record_return_status := FALSE;
	    --
            IF (l_debug <> -1) THEN
   	      rlm_core_sv.dlog(C_DEBUG,'msg_data',x_cum_record.msg_data);
   	      rlm_core_sv.dlog(C_DEBUG,'record_return_status',x_cum_record.record_return_status);
   	      rlm_core_sv.dpop(C_DEBUG,'E_UNEXPECTED');
	    END IF;
	    --
	WHEN OTHERS THEN
	    --
	    -- RLM_CUM_SQLERR
	    --
	    x_cum_record.record_return_status := FALSE;
	  --DEBUGGING - OUTPUT Values
            IF (l_debug <> -1) THEN
   	       rlm_core_sv.dlog(C_DEBUG, '');
   	       rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES:');
   	       rlm_core_sv.dlog(C_DEBUG, '---------------------------');
               rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', x_cum_record.cum_key_id);
               rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_record.cum_start_date);
               rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', x_cum_record.shipped_quantity);
               rlm_core_sv.dlog(C_DEBUG, 'actual_ship_date', x_cum_record.actual_shipment_date);
               rlm_core_sv.dlog(C_DEBUG, 'cum_key_created', x_cum_record.cum_key_created_flag);
               rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
               rlm_core_sv.dlog(C_DEBUG, 'cust_uom_code', x_cum_record.cust_uom_code);
               rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
   	       rlm_core_sv.dpop(C_DEBUG, SQLERRM);
	    END IF;
	    --
   END CalculateCumKey;
   --
/*============================================================================

  PROCEDURE NAME:	CalculateCumKeyClient

=============================================================================*/

 PROCEDURE CalculateCumKeyClient (
 -- Parameter definition was changed TCA obsolescence project.
  x_customer_id			IN	HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE,
  x_customer_item_id		IN	RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  x_ship_from_org_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE,
  x_intrmd_ship_to_address_id 	IN	RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE,
  x_ship_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE,
  x_bill_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE,
  x_purchase_order_number	IN	RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE,
  x_cust_record_year		IN	RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE,
  x_create_cum_key_flag		IN	VARCHAR2,
  x_msg_data			IN OUT	NOCOPY VARCHAR2,
  x_record_return_status	IN OUT	NOCOPY BOOLEAN,
  x_cum_key_id			IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE,
  x_cum_start_date		IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_START_DATE%TYPE,
  x_shipped_quantity		IN OUT	NOCOPY OE_ORDER_LINES.SHIPPED_QUANTITY%TYPE,
  x_actual_shipment_date	IN OUT	NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE,
  x_cum_key_created_flag	IN OUT	NOCOPY BOOLEAN,
  x_cum_qty			IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_as_of_date_cum_qty		IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_cum_qty_to_be_accumulated	IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_TO_BE_ACCUMULATED%TYPE,
  x_cum_qty_after_cutoff	IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_AFTER_CUTOFF%TYPE,
  x_last_cum_qty_update_date	IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_CUM_QTY_UPDATE_DATE%TYPE,
  x_cust_uom_code		IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUST_UOM_CODE%TYPE,
  x_use_ship_incl_rule_flag	IN OUT	NOCOPY VARCHAR2,
  x_shipment_rule_code		IN OUT	NOCOPY RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE,
  x_yesterday_time_cutoff	IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_last_update_date		IN OUT	NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_as_of_date_time		IN OUT	NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE)
  --
 IS
     --
     x_cum_key_record cum_key_attrib_rec_type;
     x_cum_record     cum_rec_type;
     --
 BEGIN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.start_debug;
        rlm_core_sv.dpush(C_SDEBUG, 'CalculateCumKeyClient');
     END IF;
	--
	x_cum_key_record.customer_id      := x_customer_id;
	x_cum_key_record.customer_item_id := x_customer_item_id;

	x_cum_key_record.ship_from_org_id := x_ship_from_org_id;
	x_cum_key_record.intrmd_ship_to_address_id := x_intrmd_ship_to_address_id;
	x_cum_key_record.ship_to_address_id := x_ship_to_address_id;
	x_cum_key_record.bill_to_address_id := x_bill_to_address_id;
	x_cum_key_record.purchase_order_number := x_purchase_order_number;
	x_cum_key_record.cust_record_year:= x_cust_record_year;
	x_cum_key_record.cum_start_date := x_cum_start_date;
	x_cum_key_record.create_cum_key_flag := x_create_cum_key_flag;
	x_cum_key_record.create_cum_key_flag := 'Y';
	x_cum_record.msg_data := x_msg_data;
	x_cum_record.record_return_status := x_record_return_status;
	x_cum_record.cum_key_id := x_cum_key_id;
	x_cum_record.cum_start_date := x_cum_start_date;
	x_cum_record.shipped_quantity := x_shipped_quantity;
	--
        IF x_actual_shipment_date IS NOT NULL THEN
	   --
	   x_cum_record.actual_shipment_date := x_actual_shipment_date;
	   --
        ELSE
	   --
	   SELECT SYSDATE
	   INTO   x_cum_record.actual_shipment_date
	   FROM   DUAL;
	   --
        END IF;
	--
	x_cum_record.cum_key_created_flag := x_cum_key_created_flag;
	x_cum_record.cum_qty:= x_cum_qty;
	x_cum_record.as_of_date_cum_qty := x_as_of_date_cum_qty;
	x_cum_record.cum_qty_to_be_accumulated := x_cum_qty_to_be_accumulated;
	x_cum_record.cum_qty_after_cutoff := x_cum_qty_after_cutoff;
	x_cum_record.last_cum_qty_update_date:= x_last_cum_qty_update_date;
	x_cum_record.cust_uom_code := x_cust_uom_code;
	x_cum_record.use_ship_incl_rule_flag := x_use_ship_incl_rule_flag;
	x_cum_record.shipment_rule_code := x_shipment_rule_code;
	x_cum_record.yesterday_time_cutoff := x_yesterday_time_cutoff;
	x_cum_record.last_update_date := x_last_update_date;
	x_cum_record.as_of_date_time := x_as_of_date_time;
	--
   -- Call calculate cum key api passing cum key records and cum records
	--
	g_manual_cum := TRUE; -- BugFix #4147544
	--
   	RLM_TPA_SV.CalculateCumKey (x_cum_key_record => x_cum_key_record,
	                            x_cum_record     => x_cum_record);
	x_msg_data := x_cum_record.msg_data;
	x_record_return_status := x_cum_record.record_return_status;
	x_cum_key_id := x_cum_record.cum_key_id;
	x_cum_start_date := x_cum_record.cum_start_date;
	x_shipped_quantity := x_cum_record.shipped_quantity;
 	x_actual_shipment_date := x_cum_record.actual_shipment_date;
 	x_cum_key_created_flag := x_cum_record.cum_key_created_flag;
 	x_cum_qty := x_cum_record.cum_qty;
 	x_as_of_date_cum_qty := x_cum_record.as_of_date_cum_qty;
 	x_cum_qty_to_be_accumulated := x_cum_record.cum_qty_to_be_accumulated;
 	x_cum_qty_after_cutoff := x_cum_record.cum_qty_after_cutoff;
 	x_last_cum_qty_update_date := x_cum_record.last_cum_qty_update_date;
 	x_cust_uom_code := x_cum_record.cust_uom_code;
 	x_use_ship_incl_rule_flag := x_cum_record.use_ship_incl_rule_flag;
	x_shipment_rule_code := x_cum_record.shipment_rule_code;
	x_yesterday_time_cutoff := x_cum_record.yesterday_time_cutoff;
	x_last_update_date := x_cum_record.last_update_date;
	x_as_of_date_time := x_cum_record.as_of_date_time;
	--
	g_manual_cum := FALSE; -- BugFix #4147544
	--
        IF (l_debug <> -1) THEN
          rlm_core_sv.stop_debug;
        END IF;
        --
   EXCEPTION
	--
	WHEN OTHERS THEN
          --
          IF (l_debug <> -1) THEN
   	    rlm_core_sv.dpop(C_DEBUG, SQLERRM);
            rlm_core_sv.stop_debug;
	  END IF;
          --
   END CalculateCumKeyClient;
   --

/*============================================================================

  PROCEDURE NAME:	CalculateSupplierCum

=============================================================================*/

 PROCEDURE CalculateSupplierCum (
     x_new_ship_count        IN     RLM_CUM_SV.t_new_ship_count := RLM_CUM_SV.g_miss_new_ship_count,
     x_cum_key_record        IN     RLM_CUM_SV.cum_key_attrib_rec_type,
     x_cum_record            IN OUT NOCOPY RLM_CUM_SV.cum_rec_type)
 IS
	--
	E_UNEXPECTED			EXCEPTION;
	v_terms_level			VARCHAR2(15) DEFAULT NULL;
	v_terms_level2			VARCHAR2(15) DEFAULT NULL;
	v_setup_terms_msg		VARCHAR2(2000);
	v_return_status			BOOLEAN DEFAULT FALSE;
	rlm_setup_record		rlm_setup_terms_sv.setup_terms_rec_typ;
	v_cutoff_date			DATE;
	v_ship_to_org_id		NUMBER;
	v_bill_to_org_id		NUMBER;
	adj_qty				NUMBER DEFAULT 0;
	v_ship_from_org_name		VARCHAR2(250);
	v_customer_name			VARCHAR2(360);
	v_ship_to_location		VARCHAR2(250);
	v_customer_item_number		VARCHAR2(250);
	--
 BEGIN
   --
   /* DEBUGGING - INPUT Values */
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'CalculateSupplierCum');
      rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE INPUT VALUES');
      rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', x_cum_key_record.ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id', x_cum_key_record.ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'inventory_item_id', x_cum_key_record.inventory_item_id);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
      rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', x_cum_record.shipped_quantity);
      rlm_core_sv.dlog(C_DEBUG, 'actual_shipment_date', x_cum_record.actual_shipment_date);
      rlm_core_sv.dlog(C_DEBUG, 'use_ship_incl_rule_flag',	x_cum_record.use_ship_incl_rule_flag);
      rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
   END IF;
   --
   IF x_cum_record.record_return_status = FALSE THEN
	--
        x_cum_record.msg_name := 'RLM_CUM_INVALID_RECORD';
        --
        rlm_message_sv.get_msg_text(
		x_message_name	=> x_cum_record.msg_name,
		x_text		=> x_cum_record.msg_data);
	--
	RAISE E_UNEXPECTED;
	--
   END IF;
   --
   --
   IF x_cum_record.use_ship_incl_rule_flag = 'N' THEN

	/* CUM calculation will be done using as_of_date_time being
           the cutoff date. This as_of_date_time is not necessarily
	   the cum_shipment_rule_code cutoff date. The as_of_date_time
	   could be any value between the cum_start_date and today */
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'Cum calculation is done using as_of_date_time');
   	  rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', x_cum_record.cum_key_id);
   	  rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_record.cum_start_date);
   	  rlm_core_sv.dlog(C_DEBUG, 'as_of_date_time', x_cum_record.as_of_date_time);
	END IF;
	--
        SELECT	NVL((SUM(shipped_quantity)), 0)
	INTO	x_cum_record.as_of_date_cum_qty
       	FROM	OE_ORDER_LINES
       	WHERE   veh_cus_item_cum_key_id = x_cum_record.cum_key_id
	AND	actual_shipment_date >= x_cum_record.cum_start_date
	AND	actual_shipment_date <= x_cum_record.as_of_date_time
	AND	source_document_type_id = 5
	AND	open_flag = 'N'
        AND     shipped_quantity IS NOT NULL
        AND     inventory_item_id = x_cum_key_record.inventory_item_id;
        --
        SELECT  NVL(SUM(transaction_qty), 0)
        INTO    adj_qty
        FROM    rlm_cust_item_cum_adj
        WHERE   cum_key_id = x_cum_record.cum_key_id
        AND     transaction_date_time >= x_cum_record.cum_start_date
        AND     transaction_date_time <= x_cum_record.as_of_date_time;
	--
        x_cum_record.as_of_date_cum_qty := x_cum_record.as_of_date_cum_qty + adj_qty;
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'as_of_date_cum_qty', x_cum_record.as_of_date_cum_qty);
	END IF;
 	--
   ELSIF x_cum_record.use_ship_incl_rule_flag = 'Y' THEN

	/* Get cum_shipment_rule_code and cum_yesterd_time_cutoff */
	--
	RLM_TPA_SV.get_setup_terms(
		x_ship_from_org_id => x_cum_key_record.ship_from_org_id,
		x_customer_id => x_cum_key_record.customer_id,
		x_ship_to_address_id => x_cum_key_record.ship_to_address_id,
		x_customer_item_id => x_cum_key_record.customer_item_id,
		x_terms_definition_level => v_terms_level,
		x_terms_rec => rlm_setup_record,
		x_return_message => v_setup_terms_msg,
		x_return_status => v_return_status);
	--
	IF v_return_status = FALSE THEN
		--
		v_ship_from_org_name := RLM_CORE_SV.get_ship_from(x_cum_key_record.ship_from_org_id);
		v_customer_name := RLM_CORE_SV.get_customer_name(x_cum_key_record.customer_id);
		v_ship_to_location := RLM_CORE_SV.get_ship_to(x_cum_key_record.ship_to_address_id);
		v_customer_item_number := RLM_CORE_SV.get_item_number(x_cum_key_record.customer_item_id);
		--
                x_cum_record.msg_name := 'RLM_CUM_SETUP_TERMS_REQUIRED';
                --
		rlm_message_sv.get_msg_text(
	 		x_message_name	=> x_cum_record.msg_name,
	 		x_text		=> x_cum_record.msg_data,
			x_token1	=> 'SF',
			x_value1	=> v_ship_from_org_name,
			x_token2	=> 'CUST',
			x_value2	=> v_customer_name,
			x_token3	=> 'ST',
			x_value3	=> v_ship_to_location,
			x_token4	=> 'CI',
			x_value4	=> v_customer_item_number);
			--
			RAISE E_UNEXPECTED;
			--
	END IF;
	--
	--
	IF rlm_setup_record.cum_shipment_rule_code IS NOT NULL THEN
		--
		x_cum_record.shipment_rule_code := rlm_setup_record.cum_shipment_rule_code;
		--
	ELSE
		--
		-- RLM_CUM_NO_SHIP_RULE
		-- This message will not go to the end user
		x_cum_record.msg_data := 'Cum shipment rule code is not found. Proceed with "As of Current Shipment" rule code';
                IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG, x_cum_record.msg_data);
                END IF;
		--
	END IF;
	--
	IF x_cum_record.shipment_rule_code <> 'AS_OF_YESTERDAY' THEN
		--
		IF x_cum_record.shipment_rule_code = 'AS_OF_CURRENT' THEN
		   --
		   IF x_cum_record.as_of_date_time IS NULL THEN
			--
			x_cum_record.cum_qty := NVL(x_cum_record.cum_qty,0) + NVL(x_cum_record.cum_qty_to_be_accumulated,0) + NVL(x_cum_record.shipped_quantity,0);
			--
			x_cum_record.cum_qty_to_be_accumulated := 0;
			--
		   ELSE
			--
			v_cutoff_date := x_cum_record.as_of_date_time;
			--
 		   END IF;
		   --
		ELSIF x_cum_record.shipment_rule_code = 'AS_OF_PRIOR' THEN
		   --
		   IF x_cum_record.as_of_date_time IS NULL THEN
		     --
		     IF x_new_ship_count(x_cum_record.cum_key_id) = 1 THEN
			--
			x_cum_record.cum_qty := NVL(x_cum_record.cum_qty,0) + NVL(x_cum_record.cum_qty_to_be_accumulated,0);
			--
			x_cum_record.cum_qty_to_be_accumulated := 0;
			--
                     END IF;
			--
			x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.cum_qty_to_be_accumulated,0) + NVL(x_cum_record.shipped_quantity,0);
			--
		   ELSE
			--
			-- Get the last shipment date before the as_of_date_time
			--
			BEGIN
				--
				-- TODO: Verify this logic again
				--
				SELECT 	MAX(actual_shipment_date)
				INTO	v_cutoff_date
				FROM 	oe_order_lines
				WHERE	veh_cus_item_cum_key_id = x_cum_record.cum_key_id
				AND	source_document_type_id = 5
				AND	open_flag = 'N'
                                AND     shipped_quantity IS NOT NULL
				AND	actual_shipment_date < x_cum_record.as_of_date_time
                                AND     inventory_item_id = x_cum_key_record.inventory_item_id;
				--
			EXCEPTION
				--
				WHEN NO_DATA_FOUND THEN
					--
                                        IF (l_debug <> -1) THEN
   					  rlm_core_sv.dlog(C_DEBUG, 'No data found');
					END IF;
					--
			END;
			--
		   END IF;
		   --
		ELSE
			--
                        x_cum_record.msg_name := 'RLM_CUM_UNKNOWN_SHIP_RULE';
                        --
	        	rlm_message_sv.get_msg_text(
				x_message_name	=> x_cum_record.msg_name,
				x_text		=> x_cum_record.msg_data);
			--
			RAISE E_UNEXPECTED;
			--
		END IF;
		--
	ELSE
		--
		-- 'AS_OF_YESTERDAY'
		--
		IF x_cum_record.as_of_date_time IS NULL THEN
			--
			SELECT	TO_DATE(TO_CHAR(SYSDATE-1, 'DD/MM/YYYY')
        		  ||
          		DECODE(SIGN(rlm_setup_record.cum_yesterd_time_cutoff/1000-1),
                		 -1, '0'||to_char(rlm_setup_record.cum_yesterd_time_cutoff),
                 		to_char(rlm_setup_record.cum_yesterd_time_cutoff)),
                 		'DD/MM/YYYY HH24MI')
	        	INTO	x_cum_record.yesterday_time_cutoff
			FROM	DUAL;
			--
                        IF x_cum_key_record.called_by_reset_cum = 'N' THEN
                          --
			  /* Calculate supplier_cum based on all shipments dated
			     since CUM start date excluding the shipments since yesterday
			     cutoff time. */
                	  --
                          IF (SYSDATE-1) < (x_cum_record.yesterday_time_cutoff) THEN
                            --
                            IF TRUNC(x_cum_record.last_cum_qty_update_date) < TRUNC(SYSDATE) THEN
                              --
                              x_cum_record.cum_qty := NVL(x_cum_record.cum_qty,0) + NVL(x_cum_record.cum_qty_to_be_accumulated,0);
                              x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.shipped_quantity,0) + NVL(x_cum_record.cum_qty_after_cutoff,0);
                              x_cum_record.cum_qty_after_cutoff := 0;
                              --
                            ELSE
                              --
                              x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.cum_qty_to_be_accumulated,0) + NVL(x_cum_record.shipped_quantity,0);
                              --
                            END IF;
                	    --
                          ELSE
                            --
                            IF TRUNC(x_cum_record.last_cum_qty_update_date) < TRUNC(SYSDATE) THEN
                              --
                              x_cum_record.cum_qty := NVL(x_cum_record.cum_qty,0) + NVL(x_cum_record.cum_qty_to_be_accumulated,0);
                              x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.cum_qty_after_cutoff,0);
                              x_cum_record.cum_qty_after_cutoff := 0;
                              --
                            END IF;
                            --
                            x_cum_record.cum_qty_after_cutoff := NVL(x_cum_record.shipped_quantity,0) + NVL(x_cum_record.cum_qty_after_cutoff,0);
                            --
                          END IF;
                          --
                        ELSE
                          --
                          IF x_cum_record.actual_shipment_date < x_cum_record.yesterday_time_cutoff THEN
                            --
                            x_cum_record.cum_qty := NVL(x_cum_record.cum_qty,0) + NVL(x_cum_record.shipped_quantity,0);
                          ELSE
                            --
                            IF TRUNC(x_cum_record.actual_shipment_date) < TRUNC(SYSDATE) THEN
                              --
                              x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.cum_qty_to_be_accumulated,0) + NVL(x_cum_record.shipped_quantity,0);
                              --
                            ELSE
                              --
                              IF x_cum_record.actual_shipment_date < (x_cum_record.yesterday_time_cutoff + 1) THEN
                                --
                                x_cum_record.cum_qty_to_be_accumulated := NVL(x_cum_record.cum_qty_to_be_accumulated,0) + NVL(x_cum_record.shipped_quantity,0);
                                --
                              ELSE
                                --
                                x_cum_record.cum_qty_after_cutoff := NVL(x_cum_record.cum_qty_after_cutoff,0) + NVL(x_cum_record.shipped_quantity,0);
                                --
                              END IF;
                              --
                            END IF;
                            --
                          END IF;
                          --
                        END IF;
                        --
		ELSE
			--
			SELECT	TO_DATE(TO_CHAR(x_cum_record.as_of_date_time, 'DD/MM/YYYY')
        		  ||
          		DECODE(SIGN(rlm_setup_record.cum_yesterd_time_cutoff/1000-1),
                		 -1, '0'||to_char(rlm_setup_record.cum_yesterd_time_cutoff),
                 		to_char(rlm_setup_record.cum_yesterd_time_cutoff)),
                 		'DD/MM/YYYY HH24MI')
	        	INTO	x_cum_record.yesterday_time_cutoff
			FROM	DUAL;
			--
			v_cutoff_date := x_cum_record.yesterday_time_cutoff;
			--
		END IF;
		--
   	END IF;
	--
	--
	IF x_cum_record.as_of_date_time IS NOT NULL THEN
		--
		IF x_cum_record.as_of_date_time <> x_cum_record.last_cum_qty_update_date THEN
			--
			BEGIN
				--
      				SELECT	NVL(SUM(shipped_quantity), 0)
				INTO	x_cum_record.as_of_date_cum_qty
				FROM	OE_ORDER_LINES
   				WHERE   veh_cus_item_cum_key_id = x_cum_record.cum_key_id
				AND	actual_shipment_date >= x_cum_record.cum_start_date
				AND	actual_shipment_date <= v_cutoff_date
				AND	source_document_type_id = 5
				AND	open_flag = 'N'
                                AND     shipped_quantity IS NOT NULL
                                AND     inventory_item_id = x_cum_key_record.inventory_item_id;
				--
				SELECT 	NVL(SUM(transaction_qty), 0)
				INTO	adj_qty
				FROM	rlm_cust_item_cum_adj
				WHERE	cum_key_id = x_cum_record.cum_key_id
				AND	transaction_date_time >= x_cum_record.cum_start_date
				AND	transaction_date_time <= v_cutoff_date;
				--
				x_cum_record.as_of_date_cum_qty := x_cum_record.as_of_date_cum_qty + adj_qty;
				--
   			EXCEPTION
				--
				WHEN NO_DATA_FOUND THEN
					--
                                        x_cum_record.msg_name := 'RLM_CUM_NO_AOD_SHIPMENT';
                                        --
			        	rlm_message_sv.get_msg_text(
						x_message_name	=> x_cum_record.msg_name,
						x_text		=> x_cum_record.msg_data,
						x_token1	=> 'CSD',
						x_value1	=> TO_CHAR(x_cum_record.cum_start_date),
						x_token2	=> 'CTD',
						x_value2	=> TO_CHAR(v_cutoff_date));
					--
                                        IF (l_debug <> -1) THEN
   					  rlm_core_sv.dlog(C_DEBUG, 'RLM_CUM_NO_AOD_SHIPMENT -- as_of_date_time not null');
					END IF;
					--
   			END;
			--
		ELSE
			--
			/* There is no intransit shipment. The previously stored quantity is the same */
			--
			x_cum_record.as_of_date_cum_qty := x_cum_record.cum_qty;
			--
		END IF;
		--
	END IF;
	--
   END IF;
   --
   x_cum_record.record_return_status := TRUE;
   --
   /* DEBUGGING - OUTPUT Values */
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES');
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
      rlm_core_sv.dlog(C_DEBUG, 'as_of_date_cum_qty', x_cum_record.as_of_date_cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', x_cum_record.shipment_rule_code);
      rlm_core_sv.dlog(C_DEBUG, 'yesterday_time_cutoff', x_cum_record.yesterday_time_cutoff);
      rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
      rlm_core_sv.dpop(C_DEBUG, 'Terminate successfully');
   END IF;
   --
 EXCEPTION
	--
	WHEN E_UNEXPECTED THEN
	   --
	   x_cum_record.record_return_status := FALSE;
	   --
	   /* DEBUGGING - OUTPUT Values */
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES');
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', x_cum_record.shipment_rule_code);
   	     rlm_core_sv.dlog(C_DEBUG, 'yesterday_time_cutoff', x_cum_record.yesterday_time_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
   	     rlm_core_sv.dpop(C_DEBUG, x_cum_record.msg_data);
	   END IF;
	   --
	WHEN NO_DATA_FOUND THEN
	   --
	   x_cum_record.record_return_status := FALSE;
	   --
	   /* DEBUGGING - OUTPUT Values */
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES');
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', x_cum_record.shipment_rule_code);
   	     rlm_core_sv.dlog(C_DEBUG, 'yesterday_time_cutoff', x_cum_record.yesterday_time_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
   	     rlm_core_sv.dpop(C_DEBUG, 'No record found using the set of input values provided');
	   END IF;
	   --
	WHEN OTHERS THEN
	   --
	   x_cum_record.record_return_status := FALSE;
	   --
	   /* DEBUGGING - OUTPUT Values */
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES');
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', x_cum_record.cum_qty_to_be_accumulated);
   	     rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', x_cum_record.cum_qty_after_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', x_cum_record.shipment_rule_code);
   	     rlm_core_sv.dlog(C_DEBUG, 'yesterday_time_cutoff', x_cum_record.yesterday_time_cutoff);
   	     rlm_core_sv.dlog(C_DEBUG, 'record_return_status', x_cum_record.record_return_status);
	     -- RLM_CUM_SQLERR
   	     rlm_core_sv.dpop(C_DEBUG, SQLERRM);
	   END IF;
	   --
 END CalculateSupplierCum;

/*============================================================================

  PROCEDURE NAME:	CalculateSupplierCumClient

=============================================================================*/

 PROCEDURE CalculateSupplierCumClient (
 -- Parameter definition was changed TCA obsolescence project.
  x_customer_id			IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE,
  x_customer_item_id		IN RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  x_inventory_item_id           IN      OE_ORDER_LINES.INVENTORY_ITEM_ID%TYPE,
  x_ship_from_org_id		IN RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE,
  x_intrmd_ship_to_address_id	IN RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE,
  x_ship_to_address_id		IN RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE,
  x_bill_to_address_id		IN RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE,
  x_purchase_order_number	IN RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE,
  x_cust_record_year		IN RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE,
  x_create_cum_key_flag		IN VARCHAR2,
  x_msg_data			IN OUT NOCOPY VARCHAR2,
  x_record_return_status	IN OUT NOCOPY BOOLEAN,
  x_cum_key_id			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE,
  x_cum_start_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_START_DATE%TYPE,
  x_shipped_quantity		IN OUT NOCOPY OE_ORDER_LINES.SHIPPED_QUANTITY%TYPE,
  x_actual_shipment_date	IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE,
  x_cum_key_created_flag	IN OUT NOCOPY BOOLEAN,
  x_cum_qty			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_as_of_date_cum_qty		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_cum_qty_to_be_accumulated	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_TO_BE_ACCUMULATED%TYPE,
  x_cum_qty_after_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_AFTER_CUTOFF%TYPE,
  x_last_cum_qty_update_date	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_CUM_QTY_UPDATE_DATE%TYPE,
  x_cust_uom_code		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUST_UOM_CODE%TYPE,
  x_use_ship_incl_rule_flag	IN OUT NOCOPY VARCHAR2,
  x_shipment_rule_code		IN OUT NOCOPY RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE,
  x_yesterday_time_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_last_update_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_as_of_date_time		IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE)

 IS
     --
     x_cum_key_record cum_key_attrib_rec_type;
     x_cum_record     cum_rec_type;
     --
 BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.start_debug;
      rlm_core_sv.dpush(C_SDEBUG, 'CalculateSupplierCumClient');
   END IF;
	--
	x_cum_key_record.customer_id      := x_customer_id;
	x_cum_key_record.customer_item_id := x_customer_item_id;
        x_cum_key_record.inventory_item_id := x_inventory_item_id;
	x_cum_key_record.ship_from_org_id := x_ship_from_org_id;
	x_cum_key_record.intrmd_ship_to_address_id := x_intrmd_ship_to_address_id;
	x_cum_key_record.ship_to_address_id := x_ship_to_address_id;
	x_cum_key_record.bill_to_address_id := x_bill_to_address_id;
	x_cum_key_record.purchase_order_number := x_purchase_order_number;
	x_cum_key_record.cust_record_year:= x_cust_record_year;
	x_cum_key_record.create_cum_key_flag := x_create_cum_key_flag;
	x_cum_record.msg_data := x_msg_data;
	x_cum_record.record_return_status := x_record_return_status;
	x_cum_record.cum_key_id := x_cum_key_id;
	x_cum_record.cum_start_date := x_cum_start_date;
	x_cum_record.shipped_quantity := x_shipped_quantity;
	x_cum_record.actual_shipment_date := x_actual_shipment_date;
	x_cum_record.cum_key_created_flag := x_cum_key_created_flag;
	x_cum_record.cum_qty:= x_cum_qty;
	x_cum_record.as_of_date_cum_qty := x_as_of_date_cum_qty;
	x_cum_record.cum_qty_to_be_accumulated := x_cum_qty_to_be_accumulated;
	x_cum_record.cum_qty_after_cutoff := x_cum_qty_after_cutoff;
	x_cum_record.last_cum_qty_update_date:= x_last_cum_qty_update_date;
	x_cum_record.cust_uom_code := x_cust_uom_code;
	x_cum_record.use_ship_incl_rule_flag := x_use_ship_incl_rule_flag;
	x_cum_record.shipment_rule_code := x_shipment_rule_code;
	x_cum_record.yesterday_time_cutoff := x_yesterday_time_cutoff;
	x_cum_record.last_update_date := x_last_update_date;
	x_cum_record.as_of_date_time := x_as_of_date_time;
	--
   -- Call calculate cum key api passing cum key records and cum records
   	RLM_TPA_SV.CalculateSupplierCum (x_cum_key_record => x_cum_key_record,
	                                 x_cum_record     => x_cum_record);
	--
	x_msg_data := x_cum_record.msg_data;
 	x_record_return_status := x_cum_record.record_return_status;
	x_cum_key_id := x_cum_record.cum_key_id;
	x_cum_start_date := x_cum_record.cum_start_date;
	x_shipped_quantity := x_cum_record.shipped_quantity;
	x_actual_shipment_date := x_cum_record.actual_shipment_date;
	x_cum_key_created_flag := x_cum_record.cum_key_created_flag;
	x_cum_qty := x_cum_record.cum_qty;
	x_as_of_date_cum_qty := x_cum_record.as_of_date_cum_qty;
	x_cum_qty_to_be_accumulated := x_cum_record.cum_qty_to_be_accumulated;
	x_cum_qty_after_cutoff := x_cum_record.cum_qty_after_cutoff;
	x_last_cum_qty_update_date := x_cum_record.last_cum_qty_update_date;
	x_cust_uom_code := x_cum_record.cust_uom_code;
	x_use_ship_incl_rule_flag := x_cum_record.use_ship_incl_rule_flag;
	x_shipment_rule_code := x_cum_record.shipment_rule_code;
	x_yesterday_time_cutoff := x_cum_record.yesterday_time_cutoff;
	x_last_update_date := x_cum_record.last_update_date;
	x_as_of_date_time := x_cum_record.as_of_date_time;
    	--
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(C_SDEBUG, 'Completed successfully');
      rlm_core_sv.stop_debug;
   END IF;
   --
   EXCEPTION
	--
	WHEN OTHERS THEN
          --
          IF (l_debug <> -1) THEN
   	    rlm_core_sv.dpop(C_DEBUG,SQLERRM);
            rlm_core_sv.stop_debug;
	  END IF;
          --
   END CalculateSupplierCumClient;


/*============================================================================

  PROCEDURE NAME:	UpdateCumKey

=============================================================================*/

 PROCEDURE UpdateCumKey (
	x_trip_stop_id   IN  NUMBER,
	x_return_status OUT NOCOPY BOOLEAN)
 IS
	--
      --Local Variables
	--
	v_rlm_setup_terms_record  	rlm_setup_terms_sv.setup_terms_rec_typ;
	v_cum_key_record	  	cum_key_attrib_rec_type;
	v_cum_record		  	cum_rec_type;
	v_delivery_id			NUMBER;
	v_header_id		  	NUMBER;
	v_line_id		  	NUMBER;
	v_schedule_header_id		NUMBER;
	v_schedule_line_id		NUMBER;
	v_terms_level		  	VARCHAR2(80) 		DEFAULT NULL;
	v_terms_level2		  	VARCHAR2(80) 		DEFAULT NULL;
	v_setup_terms_msg	  	VARCHAR2(4000);
	v_setup_terms_status	  	BOOLEAN;
	v_veh_cus_item_cum_key_id 	NUMBER;
	v_ship_to_site_use_id		NUMBER 			DEFAULT NULL;
	v_intrmd_ship_to_site_use_id	NUMBER 			DEFAULT NULL;
	v_bill_to_site_use_id		NUMBER			DEFAULT NULL;
	v_level			  	VARCHAR2(80);
	counter			  	NUMBER			DEFAULT 0;
   v_new_ship_count	  	t_new_ship_count;
	v_msg_text			VARCHAR2(4000);
	v_upd_indicator			BOOLEAN 		DEFAULT FALSE;
	v_tmp_cust_record_year		VARCHAR2(240);
	v_tmp_return_message		VARCHAR2(4000);
	v_tmp_return_status		BOOLEAN;
	v_oe_header			t_oe_header;
	v_oe_header_id			NUMBER;
	v_org_id			NUMBER;
	hdr_count			NUMBER 			DEFAULT 0;
	v_loop_count			NUMBER;
        k                               NUMBER;
	--
      --Used by process_order api
	x_oe_api_version		NUMBER 			DEFAULT 1;
	l_return_status			VARCHAR2(1);
	x_msg_count			NUMBER;
	x_msg_data			VARCHAR2(4000);
	--

      --Used for UOM conversion: Bug 4439006
        v_Primary_UOM_Code		wsh_delivery_details.requested_quantity_uom%TYPE;
        v_shipped_qty                   NUMBER;

      --Exception variables declaration
	e_general_error			EXCEPTION;
	e_no_shipment_line		EXCEPTION;
	e_null_mandatory		EXCEPTION;
	e_do_not_update			EXCEPTION;
	e_cum_start_date		EXCEPTION;
        e_no_cum_key	                EXCEPTION;
	--
      --Cursor to populate t_oe_header
	--
	CURSOR 	c_oe_header IS
	SELECT 	DISTINCT oelines.header_id, oelines.org_id
	FROM  	WSH_DELIVERY_LEGS wleg,
		WSH_DELIVERY_ASSIGNMENTS_V wdass,
		WSH_DELIVERY_DETAILS wdel,
		OE_ORDER_LINES_ALL oelines
	WHERE	wleg.pick_up_stop_id    		= x_trip_stop_id
	AND	wdass.delivery_id 			= wleg.delivery_id
	AND	wdel.delivery_detail_id 		= wdass.delivery_detail_id
	AND	oelines.shipped_quantity 		IS NOT NULL
	AND	oelines.line_id 			= wdel.source_line_id
        AND     wdel.container_flag                     = 'N'                      -- 4301944
	AND	oelines.header_id 			= wdel.source_header_id    -- 4301944
	AND	oelines.source_document_type_id		= 5;
	--
        --Cursor to hold oe_order_lines rows of data
	--
	CURSOR 	c_oe_lines IS
	SELECT 	oelines.line_id,
		wleg.delivery_id,
		oelines.header_id,
		sum(wdel.shipped_quantity),
		oelines.actual_shipment_date,
		oelines.ordered_item_id,
                oelines.inventory_item_id,
		oelines.ship_to_org_id,
		oelines.intmed_ship_to_org_id,
		oelines.ship_from_org_id,
		oelines.cust_po_number,
		oelines.industry_attribute1,
		oelines.invoice_to_org_id,
		oelines.actual_shipment_date,
                wdel.requested_quantity_uom, -- Bug 4439006
		oelines.order_quantity_uom,
		oelines.veh_cus_item_cum_key_id,
		oelines.source_document_id,
		oelines.source_document_line_id,
                oelines.org_id
	FROM  	WSH_DELIVERY_LEGS wleg,
		WSH_DELIVERY_ASSIGNMENTS_V wdass,
		WSH_DELIVERY_DETAILS wdel,
		OE_ORDER_LINES_ALL oelines
	WHERE	wleg.pick_up_stop_id    		= x_trip_stop_id
	AND	wdass.delivery_id 			= wleg.delivery_id
	AND	wdel.delivery_detail_id 		= wdass.delivery_detail_id
	AND	oelines.header_id 			= v_oe_header_id
	AND	oelines.shipped_quantity 		IS NOT NULL
	AND	oelines.line_id 			= wdel.source_line_id
        AND     wdel.container_flag                     = 'N'                      -- 4301944
	AND	oelines.header_id 			= wdel.source_header_id    -- 4301944
	AND	oelines.source_document_type_id		= 5
        group by oelines.line_id,
                 wleg.delivery_id,
                 oelines.header_id,
                 oelines.actual_shipment_date,
                 oelines.ordered_item_id,
                 oelines.inventory_item_id,
                 oelines.ship_to_org_id,
                 oelines.intmed_ship_to_org_id,
                 oelines.ship_from_org_id,
                 oelines.cust_po_number,
                 oelines.industry_attribute1,
                 oelines.invoice_to_org_id,
                 oelines.actual_shipment_date,
                 wdel.requested_quantity_uom, -- Bug 4439006
                 oelines.order_quantity_uom,
                 oelines.veh_cus_item_cum_key_id,
                 oelines.source_document_id,
                 oelines.source_document_line_id,
                 oeLines.org_id;
        --
	l_oe_line_tbl_out   oe_order_pub.line_tbl_type;
	--
 BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.start_debug;
      rlm_core_sv.dpush(C_SDEBUG, 'UpdateCumKey');
   END IF;
   --
   savepoint updatecumkey; --bug 3719088

-- Check for mandatory input
   --
   IF x_trip_stop_id IS NULL THEN
	--
	RAISE e_null_mandatory;
	--
   END IF;
   --
-- Find out how many oe headers assigned to the trip stop
   --
   OPEN c_oe_header;
	--
   	LOOP
	   --
	   FETCH c_oe_header INTO v_oe_header(hdr_count).header_id, v_oe_header(hdr_count).org_id;
	   --
	   EXIT WHEN c_oe_header%NOTFOUND;
	   --
	   hdr_count := hdr_count + 1;
	   --
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(C_DEBUG, 'Inside c_oe_header Loop');
	   END IF;
	   --
   	END LOOP;
	--
   CLOSE c_oe_header;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Number of oe headers to update: ', hdr_count);
   END IF;
   --
--
IF hdr_count = 0 THEN
	--
	RAISE e_no_shipment_line;
	--
END IF;
--
----------------------------------------------------------+
FOR v_loop_count IN 0 .. (hdr_count-1) LOOP
--
-- LOOP to fetch distinct header ids
--
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_loop_count', v_loop_count);
      rlm_core_sv.dlog(C_DEBUG, 'Inside v_loop_count Loop');
   END IF;
   --
 --Reset counter
   counter := 0;
   g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
   --
 --Get the header_id for each loop iteration
   --
   v_oe_header_id := v_oe_header(v_loop_count).header_id;
   v_org_id := v_oe_header(v_loop_count).org_id;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_oe_header_id', v_oe_header_id);
      rlm_core_sv.dlog(C_DEBUG, 'v_org_id', v_org_id);
   END IF;
   --
   MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                p_org_id      => v_org_id);
   --
/* For the supplied delivery detail id, find all shipment lines and
   attributes needed to calculate cum key */
   --
   ---------------+
   OPEN c_oe_lines;
   --
   LOOP --LOOP to fetch OE Order Lines
   	--DEBUGGING
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'Inside c_oe_lines Loop');
	END IF;
        --
   	v_msg_text := NULL;
        --
        -- Reset loop variables so as to not retain values from prior fetch
	--
        v_line_id := NULL;
        v_delivery_id := NULL;
        v_header_id := NULL;
        v_cum_record.shipped_quantity := NULL;
        v_cum_record.actual_shipment_date := NULL;
        v_cum_key_record.customer_item_id := NULL;
        v_cum_key_record.inventory_item_id := NULL;
        v_ship_to_site_use_id := NULL;
        v_intrmd_ship_to_site_use_id := NULL;
        v_cum_key_record.ship_from_org_id := NULL;
        v_cum_key_record.purchase_order_number := NULL;
        v_cum_key_record.cust_record_year := NULL;
        v_bill_to_site_use_id := NULL;
        v_cum_record.as_of_date_time := NULL;
        v_Primary_UOM_Code := NULL;         -- Bug 4439006
        v_cum_record.cust_uom_code := NULL;
        v_veh_cus_item_cum_key_id := NULL;
        v_schedule_header_id := NULL;
        v_schedule_line_id := NULL;
        v_org_id := NULL;
        --
	FETCH c_oe_lines INTO	v_line_id,
				v_delivery_id,
				v_header_id,
				v_cum_record.shipped_quantity,
				v_cum_record.actual_shipment_date,
				v_cum_key_record.customer_item_id,
                                v_cum_key_record.inventory_item_id,
				v_ship_to_site_use_id,
				v_intrmd_ship_to_site_use_id,
				v_cum_key_record.ship_from_org_id,
				v_cum_key_record.purchase_order_number,
				v_cum_key_record.cust_record_year,
				v_bill_to_site_use_id,
				v_cum_record.as_of_date_time,
                                v_Primary_UOM_Code,         -- Bug 4439006
				v_cum_record.cust_uom_code,
				v_veh_cus_item_cum_key_id,
				v_schedule_header_id,
				v_schedule_line_id,
                                v_org_id;
	--
	EXIT WHEN c_oe_lines%NOTFOUND;
	--
	v_level := 'SHIP_TO_ADDRESS_ID';
	--
     -- Find the ship_to_address_id
	--
	IF v_ship_to_site_use_id IS NOT NULL THEN
		--
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT_SITE_ID
		INTO 	v_cum_key_record.ship_to_address_id
		FROM	HZ_CUST_SITE_USES
		WHERE	site_use_id = v_ship_to_site_use_id
                AND	site_use_code = 'SHIP_TO';
		--
	ELSE
		--
		v_cum_key_record.ship_to_address_id := NULL;
		--
	END IF;
	--
	v_level := 'INTRMD_SHIP_TO_ADDRESS_ID';
	--
     -- Find the intrmd_ship_to_address_id
	--
	IF v_intrmd_ship_to_site_use_id IS NOT NULL THEN
		--
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT_SITE_ID
		INTO 	v_cum_key_record.intrmd_ship_to_address_id
		FROM	HZ_CUST_SITE_USES
		WHERE	site_use_id = v_intrmd_ship_to_site_use_id
                AND	site_use_code = 'SHIP_TO';
		--
	ELSE
		--
		v_cum_key_record.intrmd_ship_to_address_id := NULL;
		--
	END IF;
	--
	v_level := 'BILL_TO_ADDRESS_ID';
	--
     -- Find the bill_to_address_id
	--
	IF v_bill_to_site_use_id IS NOT NULL THEN
		--
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT_SITE_ID
		INTO 	  v_cum_key_record.bill_to_address_id
		FROM	  HZ_CUST_SITE_USES
		WHERE	  site_use_id = v_bill_to_site_use_id
		AND	  site_use_code = 'BILL_TO';
		--
	ELSE
		--
		v_cum_key_record.bill_to_address_id := NULL;
		--
	END IF;
	--
      --DEBUGGING - INPUT Values
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, '');
           rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE INPUT VALUES:');
           rlm_core_sv.dlog(C_DEBUG, '--------------------------');
           rlm_core_sv.dlog(C_DEBUG, 'x_trip_stop_id', x_trip_stop_id);
           rlm_core_sv.dlog(C_DEBUG, 'v_delivery_id', v_delivery_id);
           rlm_core_sv.dlog(C_DEBUG, 'v_line_id', v_line_id);
           rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id', v_cum_key_record.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', v_cum_key_record.ship_from_org_id);
           rlm_core_sv.dlog(C_DEBUG, 'bill_to_address_id', v_cum_key_record.bill_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'intrmd_ship_to_address_id', v_cum_key_record.intrmd_ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'customer_item_id', v_cum_key_record.customer_item_id);
           rlm_core_sv.dlog(C_DEBUG, 'purchase_order_number', v_cum_key_record.purchase_order_number);
           rlm_core_sv.dlog(C_DEBUG, 'cust_record_year', v_cum_key_record.cust_record_year);
           rlm_core_sv.dlog(C_DEBUG, 'create_cum_key', v_cum_key_record.create_cum_key_flag);
           rlm_core_sv.dlog(C_DEBUG, 'actual_shipment_date', v_cum_record.actual_shipment_date);
           rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', v_cum_record.shipped_quantity);
        END IF;
	--
     -- User friendly message
     -- TODO: Make the message more user friendly
     --
	rlm_message_sv.get_msg_text(
	  		x_message_name	=> 'RLM_TRIP_DEL_INFO',
	  		x_text		=> v_msg_text,
			x_token1	=> 'TRIP_STOP',
			x_value1	=> x_trip_stop_id,
			x_token2	=> 'DELIVERY',
			x_value2	=> v_delivery_id,
			x_token3	=> 'OE_LINE',
			x_value3	=> v_line_id,
			x_token4	=> 'SHIP_DATE',
			x_value4	=> v_cum_record.actual_shipment_date,
			x_token5	=> 'SHIP_QTY',
			x_value5	=> v_cum_record.shipped_quantity);
	  --
	  fnd_file.put_line(fnd_file.log, v_msg_text);
	  --
      --Find customer_id, as it is a required input parameter for rlm_setup_terms
	--
	v_level := 'CUSTOMER_ID';
	--
        -- Following query is changed as per TCA obsolescence project.
/*		SELECT	DISTINCT ACCT_SITE.CUST_ACCOUNT_ID
		INTO	v_cum_key_record.customer_id
		FROM	HZ_CUST_ACCT_SITES	 ACCT_SITE
		WHERE	ACCT_SITE.CUST_ACCT_SITE_ID = v_cum_key_record.ship_to_address_id;
*/
                -- CR changes
                SELECT  DISTINCT sold_to_org_id
                INTO    v_cum_key_record.customer_id
                FROM    oe_order_headers_all oeh
                WHERE   oeh.header_id = v_oe_header_id;

	--
      --DEBUGGING
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'customer_id', v_cum_key_record.customer_id);
        END IF;
	--
      --Get the CUM_CONTROL_CODE defined at CUSTOMER or ADDRESS level
	--
	RLM_TPA_SV.get_setup_terms(
		x_ship_from_org_id 	     	=> v_cum_key_record.ship_from_org_id,
		x_customer_id 	     		=> v_cum_key_record.customer_id,
	    	x_ship_to_address_id     	=> v_cum_key_record.ship_to_address_id,
	    	x_customer_item_id	     	=> v_cum_key_record.customer_item_id,
	    	x_terms_definition_level	=> v_terms_level,
	    	x_terms_rec	 	     	=> v_rlm_setup_terms_record,
	    	x_return_message	     	=> v_setup_terms_msg,
	    	x_return_status 	     	=> v_setup_terms_status);
	--
      --DEBUGGING
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Setup terms x_return_status', v_setup_terms_status);
           rlm_core_sv.dlog(C_DEBUG, 'Terms level', v_terms_level);
           rlm_core_sv.dlog(C_DEBUG, 'cum_control_code', v_rlm_setup_terms_record.cum_control_code);
           rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id', v_cum_key_record.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', v_cum_key_record.ship_from_org_id);
           rlm_core_sv.dlog(C_DEBUG, 'customer_id', v_cum_key_record.customer_id);
           rlm_core_sv.dlog(C_DEBUG, 'customer_item_id', v_cum_key_record.customer_item_id);
           rlm_core_sv.dlog(C_DEBUG, 'calc_cum_flag', v_rlm_setup_terms_record.calc_cum_flag);
        END IF;
	--
     -- User friendly message
	--
	rlm_message_sv.get_msg_text(
	  		x_message_name	=> 'RLM_TRIP_CTRLCD',
	  		x_text		=> v_msg_text,
			x_token1	=> 'CUM_CONTROL_CODE',
			x_value1	=> v_rlm_setup_terms_record.cum_control_code);
	--
	fnd_file.put_line(fnd_file.log, v_msg_text);
	--
      --Continue only if cum_control_code is found and not set to NO_CUM
	--
	IF v_setup_terms_status = TRUE AND
	   v_rlm_setup_terms_record.cum_control_code <> 'NO_CUM' THEN
	       --
               IF (v_terms_level = 'CUSTOMER_ITEM' AND
		   v_rlm_setup_terms_record.calc_cum_flag = 'Y')
                   OR v_terms_level <> 'CUSTOMER_ITEM' THEN
		      --
	              --DEBUGGING
			--
                        IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG, 'Setup terms x_return_status at item level', v_setup_terms_status);
                        END IF;
			--
		      --Find the cum start date
			--
			GetCumStartDate(i_schedule_header_id => v_schedule_header_id,
					i_schedule_line_id   => v_schedule_line_id,
					o_cum_start_date     => v_cum_key_record.cum_start_date,
					o_cust_record_year   => v_tmp_cust_record_year,
					o_return_message     => v_tmp_return_message,
					o_return_status	     => v_tmp_return_status);
			--
			IF v_tmp_return_status = FALSE THEN
					--
					RAISE e_cum_start_date;
					--
			END IF;
			--
                        IF (l_debug <> -1) THEN
   		          rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', v_cum_key_record.cum_start_date);
		        END IF;
			--
		     /* Call calculate_cum_key procedure to search for the cum
		        key id, and the cum quantity stored in the database as
		        of the time of shipment */
			--
		   	RLM_TPA_SV.CalculateCumKey(
					x_cum_key_record => v_cum_key_record,
					x_cum_record     => v_cum_record);
			--
			IF v_cum_record.record_return_status <> FALSE THEN
				     --
				     -- User friendly message
				     --
			  		rlm_message_sv.get_msg_text(
				  		x_message_name	=> 'RLM_TRIP_CUM_KEY_ID',
				  		x_text		=> v_msg_text,
						x_token1	=> 'CUM_KEY_ID',
						x_value1	=> v_cum_record.cum_key_id);
					--
	      		  		fnd_file.put_line(fnd_file.log, v_msg_text);
					--
			ELSE
				--
				RAISE e_general_error;
				--
			END IF;

			--
                        IF(v_cum_record.cum_key_id IS NULL) THEN
                          --
                          raise e_no_cum_key;
                          --
                        END IF;

		      --Check if this delivery line has actually been updated
			--
		     /* Initialize v_new_ship_count. This variable is used to keep track of the
		        shipment lines that have the same cum_key_id and
		        shipment_rule_code = 'AS_OF_PRIOR' */
		        ------------------------------------------------------------+
                        BEGIN
			   --
			   SELECT v_new_ship_count(v_cum_record.cum_key_id) + 1
			   INTO v_new_ship_count(v_cum_record.cum_key_id)
			   FROM DUAL;
			   --
                        EXCEPTION
			   --
			   WHEN NO_DATA_FOUND THEN
				--
				v_new_ship_count(v_cum_record.cum_key_id) := 0;
				--
				SELECT v_new_ship_count(v_cum_record.cum_key_id) + 1
			   	INTO v_new_ship_count(v_cum_record.cum_key_id)
			   	FROM DUAL;
				--
	    	        END;
		        ------------------------------------------------------------+
			--
		        IF NVL(v_veh_cus_item_cum_key_id,0) <> v_cum_record.cum_key_id THEN
			  --
			  /* Need to set this to 'Y' since we're going to include the
			     current shipment into the supplier CUM calculation */
			     v_cum_record.use_ship_incl_rule_flag := 'Y';
			     v_cum_record.as_of_date_time := NULL;

			  /* Bug 4439006: Start
                             While ship confirming, shipped qty is specified in Primary Uom,
                             where as the Uom attached with the CUM Key can be different.
                             The Cum key should be updated with qty specified in Cum key uom. */
                          --
                          IF (l_debug <> -1) THEN
                              rlm_core_sv.dlog(C_DEBUG, 'inventory_item_id', v_cum_key_record.inventory_item_id);
                              rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', v_cum_key_record.ship_from_org_id);
                          END IF;
                          --
                          v_shipped_qty := v_cum_record.shipped_quantity;
                          --
                          IF (v_cum_record.cust_uom_code <> v_Primary_UOM_Code) THEN
                            RLM_FORECAST_SV.Convert_UOM (v_Primary_UOM_Code,
                                                         v_cum_record.cust_uom_code,
                                                         v_cum_record.shipped_quantity,
                                                         v_cum_key_record.inventory_item_id,
                                                         v_cum_key_record.ship_from_org_id);
                            --
                            IF (l_debug <> -1) THEN
                              rlm_core_sv.dlog(C_DEBUG, 'Primary Uom', v_Primary_UOM_Code);
                              rlm_core_sv.dlog(C_DEBUG, 'Cum Key Uom', v_cum_record.cust_uom_code);
                              rlm_core_sv.dlog(C_DEBUG, 'Shipd Qty.-Before Conversion to CUM Uom', v_shipped_qty);
                              rlm_core_sv.dlog(C_DEBUG, 'Shipd Qty.-After Conversion -CUM Uom', v_cum_record.shipped_quantity);
                              rlm_core_sv.dlog(C_DEBUG, 'Primary Uom and Cum Key Uom differ: Calling Convert_UOM');
                            END IF;
                            --
                          END IF;
			  /* Bug 4439006: End */
			  --
		          /* Call calculate_supplier_cum procedure to calculate the
			     total supplier cum by summing the current line shipped
			     quantity and the stored quantity */
			     --
			     RLM_TPA_SV.CalculateSupplierCum(
					x_new_ship_count => v_new_ship_count,
					x_cum_key_record => v_cum_key_record,
					x_cum_record     => v_cum_record);
			     --
                             -- Bug 4439006
                             v_cum_record.shipped_quantity := v_shipped_qty;

			   --DEBUGGING - OUTPUT Values
                             IF (l_debug <> -1) THEN
   			       rlm_core_sv.dlog(C_DEBUG, '');
   		   	       rlm_core_sv.dlog(C_DEBUG, 'HERE ARE THE OUTPUT VALUES:');
   		   	       rlm_core_sv.dlog(C_DEBUG, '---------------------------');
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', v_cum_record.cum_key_id);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', v_cum_record.cum_start_date);
    		   	       rlm_core_sv.dlog(C_DEBUG, 'shipped_quantity', v_cum_record.shipped_quantity);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'actual_shipment_date', v_cum_record.actual_shipment_date);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cum_key_created_flag', v_cum_record.cum_key_created_flag);
   			       rlm_core_sv.dlog(C_DEBUG, 'cum_qty', v_cum_record.cum_qty);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'as_of_date_cum_qty', v_cum_record.as_of_date_cum_qty);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cum_qty_to_be_accumulated', v_cum_record.cum_qty_to_be_accumulated);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cum_qty_after_cutoff', v_cum_record.cum_qty_after_cutoff);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'last_cum_qty_update_date', v_cum_record.last_cum_qty_update_date);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'cust_uom_code', v_cum_record.cust_uom_code);
                               rlm_core_sv.dlog(C_DEBUG, 'Primary_uom_code', v_Primary_UOM_Code);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'use_ship_incl_rule_flag', v_cum_record.use_ship_incl_rule_flag);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'shipment_rule_code', v_cum_record.shipment_rule_code);
   		   	       rlm_core_sv.dlog(C_DEBUG, 'record_return_status', v_cum_record.record_return_status);
			     END IF;
			     --
                             --Bug 3688778 jckwok : Need to Lock the Cum Key
			     --
		   	     IF (LockCumKey(v_cum_record.cum_key_id) AND
                                           v_cum_record.record_return_status = TRUE) THEN

				 /* Update the CUM related quantity in
				    RLM_CUS_ITEM_CUM_KEY_ALL table */
				    --
				    UPDATE RLM_CUST_ITEM_CUM_KEYS_ALL
				    SET    cum_qty = v_cum_record.cum_qty,
			  	           cum_qty_to_be_accumulated = v_cum_record.cum_qty_to_be_accumulated,
			  	           cum_qty_after_cutoff = v_cum_record.cum_qty_after_cutoff,
			  		   last_cum_qty_update_date = sysdate,
			  		   last_update_login = fnd_global.login_id,
			  		   last_update_date = sysdate,
			  		   last_updated_by = fnd_global.user_id
				    WHERE  cum_key_id = v_cum_record.cum_key_id;
				    --
 				    v_upd_indicator := TRUE;
				    --
		   	         /* Populate g_oe_line_tbl data structure with the
		      	            calculated cum_key_id so it can be used when
                      	            oe_order_grp.process order api to update
                      	            oe_order_lines table */
				    --
			            counter := counter + 1;
				    -- Bug# 1466909
				    g_oe_line_tbl(counter) := OE_Order_PUB.G_MISS_LINE_REC;
			            g_oe_line_tbl(counter).header_id := v_header_id;
			            g_oe_line_tbl(counter).line_id := v_line_id;
	  	   	            g_oe_line_tbl(counter).operation := oe_globals.G_OPR_UPDATE;
		   	            g_oe_line_tbl(counter).veh_cus_item_cum_key_id := v_cum_record.cum_key_id;
		   	            g_oe_line_tbl(counter).industry_attribute7 := TO_CHAR(v_cum_record.cum_qty);
		   	            g_oe_line_tbl(counter).industry_attribute8 := v_cum_record.cust_uom_code;
                                    g_oe_line_tbl(counter).org_id := v_org_id;
				    --
			          --DEBUGGING
                                    IF (l_debug <> -1) THEN
           		              rlm_core_sv.dlog(C_DEBUG, 'counter', counter);
           		              rlm_core_sv.dlog(C_DEBUG, 'g_oe_line_tbl(counter).header_id',
								g_oe_line_tbl(counter).header_id);
          			      rlm_core_sv.dlog(C_DEBUG, 'g_oe_line_tbl(counter).line_id',
								g_oe_line_tbl(counter).line_id);
           		              rlm_core_sv.dlog(C_DEBUG,'g_oe_line_tbl(counter).veh_cus_item_cum_key_id',
								g_oe_line_tbl(counter).veh_cus_item_cum_key_id);
           		              rlm_core_sv.dlog(C_DEBUG, 'g_oe_line_tbl(counter).industry_attribute7',
								g_oe_line_tbl(counter).industry_attribute7);
           		              rlm_core_sv.dlog(C_DEBUG, 'g_oe_line_tbl(counter).industry_attribute8',
								g_oe_line_tbl(counter).industry_attribute8);
           		              rlm_core_sv.dlog(C_DEBUG, 'g_oe_line_tbl(counter).org_id',
								g_oe_line_tbl(counter).org_id);
        		            END IF;
				    --
			     ELSE
				    --
				    RAISE e_general_error;
				    --
		   	     END IF; 	-- record_return_status = TRUE
			     --
		      ELSE
			     --
			     x_return_status := TRUE;
			     --
			     v_msg_text := 'RLM_TRIP_NO_UPDATE';
			     --
                             IF (l_debug <> -1) THEN
    		  	       rlm_core_sv.dlog(C_SDEBUG, v_msg_text);
 		  	     END IF;
			     --
		       	  -- User friendly message
			     --
			     rlm_message_sv.get_msg_text(
				  x_message_name	=> 'RLM_TRIP_NO_UPDATE',
				  x_text		=> v_msg_text);
			     --
			     fnd_file.put_line(fnd_file.log, v_msg_text);
			     --
			  -- Pls do not remove the line below
			     --
			     v_msg_text := 'RLM_TRIP_NO_UPDATE';

		      END IF; 		-- cum key id
		      --
	       ELSE
		      --
		      x_return_status := TRUE;
		      --
	       END IF; 			-- v_calc_cum_flag = 'Y'
	       --
	ELSE
	   --
	   x_return_status := TRUE;
	   --
	   -- RLM_TRIP_NO_SETUP
	   --
           IF (l_debug <> -1) THEN
    	       rlm_core_sv.dlog(C_SDEBUG, 'RLM_TRIP_NO_SETUP');
 	   END IF;
	   --
	   -- User friendly message
			  --
			  rlm_message_sv.get_msg_text(
				  x_message_name	=> 'RLM_TRIP_NO_SETUP',
				  x_text		=> v_msg_text);
			  --
	      		  fnd_file.put_line(fnd_file.log, v_msg_text);
			  --
   	END IF; -- v_cum_control_code <> 'NO_CUM'
	--
   END LOOP; -- END LOOP to fetch OE Order Lines
   --
   CLOSE c_oe_lines;
   ----------------+
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_msg_text', v_msg_text);
      rlm_core_sv.dlog(C_DEBUG, 'v_upd_indicator', v_upd_indicator);
   END IF;
   --
   IF v_upd_indicator = TRUE THEN
       --
       -----------------------------------------------------------------------+
       BEGIN
       /* Call OE_Order_GRP.Process_Order procedure to update OE_ORDER_LINES
  	  table by passing the g_oe_line_tbl structure that has been prepared
  	  inside the loop above */
	--
        --Pass only g_oe_line_tbl. The rest uses default values
	--
  	  OE_Order_GRP.Process_order(
	  	p_api_version_number     => x_oe_api_version,
  		p_init_msg_list          => FND_API.G_TRUE,
  		p_return_values          => FND_API.G_FALSE,
  		--p_commit                 => FND_API.G_FALSE,
  		p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
  		x_return_status          => l_return_status,
  		x_msg_count              => x_msg_count,
 		x_msg_data               => x_msg_data,
		------------------------------------------
  		p_line_tbl               => g_oe_line_tbl,
		------------------------------------------
  		x_header_rec             => g_oe_header_out_rec,
  		x_header_val_rec         => g_oe_header_val_out_rec,
  		x_Header_Adj_tbl         => g_oe_Header_Adj_out_tbl,
  		x_Header_Adj_val_tbl	 => g_oe_Header_Adj_val_out_tbl,
   		x_Header_price_Att_tbl   => g_Header_price_Att_out_tbl,
    		x_Header_Adj_Att_tbl     => g_Header_Adj_Att_out_tbl,
    		x_Header_Adj_Assoc_tbl   => g_Header_Adj_Assoc_out_tbl,
  		x_Header_Scredit_tbl     => g_oe_Header_Scredit_out_tbl,
  		x_Header_Scredit_val_tbl => g_oe_Hdr_Scdt_val_out_tbl,
  		x_line_tbl               => l_oe_line_tbl_out,
  		x_line_val_tbl           => g_oe_line_val_out_tbl,
  		x_Line_Adj_tbl           => g_oe_line_Adj_out_tbl,
  		x_Line_Adj_val_tbl       => g_oe_line_Adj_val_out_tbl,
    		x_Line_price_Att_tbl     => g_Line_price_Att_out_tbl,
    		x_Line_Adj_Att_tbl       => g_Line_Adj_Att_out_tbl,
    		x_Line_Adj_Assoc_tbl     => g_Line_Adj_Assoc_out_tbl,
  		x_Line_Scredit_tbl       => g_oe_line_scredit_out_tbl,
  		x_Line_Scredit_val_tbl   => g_oe_line_scredit_val_out_tbl,
  		x_Lot_Serial_tbl         => g_oe_lot_serial_out_tbl,
  		x_Lot_Serial_val_tbl     => g_oe_lot_serial_val_out_tbl,
  		x_Action_Request_tbl     => g_oe_Action_Request_out_Tbl);
	--
        --Handle the exceptions caused by the OE call
 	--
          IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_SDEBUG, 'Input tbl count', g_oe_line_tbl.LAST);
           rlm_core_sv.dlog(C_SDEBUG, 'Output tbl count', l_oe_line_tbl_out.LAST);
          END IF;
	  --
  	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		--
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		--
  	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		--
		RAISE FND_API.G_EXC_ERROR;
		--
  	  ELSE
		--
		x_return_status := TRUE;
		--
	      --DEBUGGING
                IF (l_debug <> -1) THEN
   		  rlm_core_sv.dlog(C_SDEBUG,'l_return_status', l_return_status);
   		  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
   		  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_count', x_msg_count);
   		  rlm_core_sv.dlog(C_SDEBUG, 'Process Order is completed succesfully');
		END IF;
		--
 	  END IF;
	  --
       EXCEPTION
	     --
	     WHEN FND_API.G_EXC_ERROR THEN
		      --
		      --Get message count and data
		      --
			OE_MSG_PUB.Count_And_Get(
				p_count	=> x_msg_count,
				p_data  => x_msg_data);
			--
			x_return_status := FALSE;
			--
			ROLLBACK to updatecumkey;
			--
		     -- DEBUGGING
                        IF (l_debug <> -1) THEN
   			  rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_ERROR');
   			  rlm_core_sv.dlog(C_SDEBUG, 'l_return_status', l_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_count', x_msg_count);
   			  rlm_core_sv.dlog(C_SDEBUG, 'Main x_msg_data', x_msg_data);
			END IF;
			--
			IF x_msg_count > 0 THEN
			  --
			  FOR k in 1 .. x_msg_count LOOP
				--
        			x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        				      p_encoded   => 'F');
				--
				fnd_file.put_line(fnd_file.log, x_msg_data);
			        --
                                IF (l_debug <> -1) THEN
   			          rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
			        END IF;
				--
                          END LOOP;
			  --
			END IF;
			--
                        IF (l_debug <> -1) THEN
   			  rlm_core_sv.dpop(C_SDEBUG, 'Process Order Error');
			END IF;
			--
		     --
		     -- User friendly message
		     --
			rlm_message_sv.get_msg_text(
				x_message_name	=> 'RLM_CUM_PROCESS_ORDER',
				x_text		=> v_msg_text);
			--
			fnd_file.put_line(fnd_file.log, v_msg_text);
			--
                        IF (l_debug <> -1) THEN
   			  rlm_core_sv.stop_debug;
			END IF;
			--
			RAISE e_general_error;
			--
	     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		     --
		     -- Get message count and data
		     --
			OE_MSG_PUB.Count_And_Get(
				p_count	=> x_msg_count,
				p_data  => x_msg_data);
			--
			v_msg_text := x_msg_data;
			--
			x_return_status := FALSE;
			--
			ROLLBACK to updatecumkey;
			--
		     -- DEBUGGING
                        IF (l_debug <> -1) THEN
   			  rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_UNEXPECTED_ERROR');
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
   			  rlm_core_sv.dlog(C_SDEBUG, 'l_return_status', l_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_count', x_msg_count);
   			  rlm_core_sv.dlog(C_SDEBUG, 'Main x_msg_data', x_msg_data);
			END IF;
			--
			IF x_msg_count > 0 THEN
			  --
			  FOR k in 1 .. x_msg_count LOOP
				--
        			x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        				      p_encoded   => 'F');
				--
				fnd_file.put_line(fnd_file.log, x_msg_data);
				--
  				IF (l_debug <> -1) THEN
   			          rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
			        END IF;
				--
                          END LOOP;
			  --
			END IF;
			--
  			IF (l_debug <> -1) THEN
   			  rlm_core_sv.dpop(C_SDEBUG, 'Process Order Error');
			END IF;
			--
		     --
		     -- User friendly message
		     --
			rlm_message_sv.get_msg_text(
				x_message_name	=> 'RLM_CUM_PROCESS_ORDER',
				x_text		=> v_msg_text);
			--
			fnd_file.put_line(fnd_file.log, v_msg_text);
			--
  			IF (l_debug <> -1) THEN
   			  rlm_core_sv.stop_debug;
			END IF;
			--
			RAISE e_general_error;
			--
             WHEN OTHERS THEN
		     --
		     -- Get message count and data
		     --
			OE_MSG_PUB.Count_And_Get(
				p_count	=> x_msg_count,
				p_data  => x_msg_data);
			--
			v_msg_text := x_msg_data;
			--
			x_return_status := FALSE;
			--
			ROLLBACK to updatecumkey;
			--
		     -- DEBUGGING
  			IF (l_debug <> -1) THEN
   			  rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_UNEXPECTED_ERROR');
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
   			  rlm_core_sv.dlog(C_SDEBUG, 'l_return_status', l_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   			  rlm_core_sv.dlog(C_SDEBUG, 'x_msg_count', x_msg_count);
			END IF;
			--
			FOR k in 1 .. x_msg_count LOOP
				--
        			x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        				      p_encoded   => 'F');
				--
				fnd_file.put_line(fnd_file.log, x_msg_data);
				--
  				IF (l_debug <> -1) THEN
   			          rlm_core_sv.dlog(C_SDEBUG, 'x_msg_data', x_msg_data);
			        END IF;
				--
                        END LOOP;
			--
  			IF (l_debug <> -1) THEN
   			  rlm_core_sv.dpop(C_SDEBUG, 'Process Order Error. When Others');
			END IF;
			--
			--
		     -- User friendly message
			--
			rlm_message_sv.get_msg_text(
				x_message_name	=> 'RLM_CUM_PROCESS_ORDER',
				x_text		=> v_msg_text);
			--
			fnd_file.put_line(fnd_file.log, v_msg_text);
			--
  			IF (l_debug <> -1) THEN
   			  rlm_core_sv.stop_debug;
			END IF;
			--
      END;
      --------------------------------------------------------------------------------+
   END IF;
   --
END LOOP;			-- END LOOP to fetch distinct header ids
--
 --DEBUGGING
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
      rlm_core_sv.dpop(C_DEBUG, 'Completed successfully');
   END IF;
 --
 --User friendly message
 --
   rlm_message_sv.get_msg_text(
		x_message_name	=> 'RLM_CUM_SUCCESS',
		x_text		=> v_msg_text);
   --
   fnd_file.put_line(fnd_file.log, v_msg_text);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.stop_debug;
   END IF;
   --
 EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
	--
	IF v_level = 'SHIP_TO_ADDRESS_ID' THEN
		--
		v_msg_text := 'No ship_to_address_id is associated with the ship_to_org_id';
		--
	ELSIF v_level = 'INTRMD_SHIP_TO_ADDRESS_ID' THEN
		--
		v_msg_text := 'No intrmd_ship_to_address_id is associated with the intmed_ship_to_org_id';
		--
	ELSIF v_level = 'CUSTOMER_ID' THEN
		--
		v_msg_text := 'No customer_id is associated with the address_id';
		--
	ELSIF v_level = 'BILL_TO_ADDRESS_ID' THEN
		--
		v_msg_text := 'No bill_to_address_id is associated with the bill_to_org_id';
		--
	END IF;
	--
	ROLLBACK to updatecumkey;
	--
	x_return_status := FALSE;
	--
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
      	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: NO_DATA_FOUND');
      	  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   	  rlm_core_sv.stop_debug;
	END IF;
	--
	-- User-friendly message
	--
	IF v_level <> 'CUSTOMER_ID' THEN
		--
		rlm_message_sv.get_msg_text(
			x_message_name	=> 'RLM_NO_ID_FOR_ORG',
			x_text		=> v_msg_text);
		--
	ELSE
		--
		rlm_message_sv.get_msg_text(
			x_message_name	=> 'RLM_NO_CUST_FOR_ADDRESS',
			x_text		=> v_msg_text);
		--
	END IF;
	--
	fnd_file.put_line(fnd_file.log, v_msg_text);
	--
   WHEN e_no_shipment_line THEN
        ----------------------------------------------------+
	DECLARE
		--
		v_hr_location_code		hr_locations.location_code%TYPE;
		--
        BEGIN
		--
		ROLLBACK to updatecumkey;
		--
		x_return_status := TRUE;
		--
                IF (l_debug <> -1) THEN
           	  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
      		  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: e_no_shipment_line');
        	END IF;
		--
		SELECT 	location_code
		INTO	v_hr_location_code
		FROM 	hr_locations hr, wsh_trip_stops tstop
		WHERE	tstop.stop_id	= x_trip_stop_id
		AND	hr.location_id 	= tstop.stop_location_id;
		--
 		rlm_message_sv.get_msg_text(
				x_message_name	=> 'RLM_NO_SHIPMENT_LINE',
				x_text		=> v_msg_text,
				x_token1	=> 'TRIP_STOP',
				x_value1	=> v_hr_location_code);
		--
                IF (l_debug <> -1) THEN
      		  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   		END IF;
                --
                -- Bug 1306894: Shipping requests the removal of this
		-- misleading message for non-RLM customers
		--
		-- fnd_file.put_line(fnd_file.log, v_msg_text);
		--
                IF (l_debug <> -1) THEN
   		  rlm_core_sv.stop_debug;
		END IF;
		--
	EXCEPTION
		--
		WHEN OTHERS THEN
			--
	 		rlm_message_sv.get_msg_text(
				x_message_name	=> 'RLM_NO_SHIPMENT_LINE',
				x_text		=> v_msg_text,
				x_token1	=> 'TRIP_STOP',
				x_value1	=> NULL);
			--
                        IF (l_debug <> -1) THEN
   	   		  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   			  rlm_core_sv.stop_debug;
			END IF;
			--
			fnd_file.put_line(fnd_file.log, v_msg_text);
			--
	END;
        -----------------------------------------------------------+
   WHEN e_null_mandatory THEN
	--
	ROLLBACK to updatecumkey;
	--
	x_return_status := FALSE;
	--
	rlm_message_sv.get_msg_text(
		x_message_name	=> 'RLM_TRIP_STOP_REQUIRED',
		x_text		=> v_msg_text);
	--
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
      	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: e_null_mandatory');
      	  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   	  rlm_core_sv.stop_debug;
        END IF;
        --
	fnd_file.put_line(fnd_file.log, v_msg_text);
	--
   WHEN e_cum_start_date THEN
	--
	ROLLBACK to updatecumkey;
	--
	x_return_status := FALSE;
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
        END IF;
	v_msg_text := v_tmp_return_message;
	--
        IF (l_debug <> -1) THEN
      	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: e_cum_start_date');
      	  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   	  rlm_core_sv.stop_debug;
   	END IF;
	--
	fnd_file.put_line(fnd_file.log, v_msg_text);
	--
   WHEN e_no_cum_key THEN
        ROLLBACK to updatecumkey;
        rlm_message_sv.get_msg_text(
		x_message_name	=> 'RLM_NO_CUM_DISABLE_CUM_KEY',
		x_text		=> v_msg_text);
	--
	x_return_status := FALSE;
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
           rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: e_no_cum_key');
      	   rlm_core_sv.dpop(C_SDEBUG);
   	   rlm_core_sv.stop_debug;
        END IF;
	fnd_file.put_line(fnd_file.log, v_msg_text);

   WHEN e_general_error THEN
	--
	ROLLBACK to updatecumkey;
	--
	x_return_status := FALSE;
	--
   WHEN OTHERS THEN
	--
	ROLLBACK to updatecumkey;
	--
	x_return_status := FALSE;
	--
	v_msg_text := SQLERRM;
	--
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: OTHERS');
   	  rlm_core_sv.dpop(C_SDEBUG, v_msg_text);
   	  rlm_core_sv.stop_debug;
	END IF;
	--
	fnd_file.put_line(fnd_file.log, v_msg_text);
	--
 END UpdateCumKey;

/*============================================================================

  PROCEDURE NAME:	UpdateCumKeyClient

=============================================================================*/

 PROCEDURE UpdateCumKeyClient (
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	x_trip_stop_id   IN  NUMBER)
 IS
   --
   v_return_status BOOLEAN;
   --
 BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.start_debug;
  END IF;
  --
  RLM_TPA_SV.UpdateCumKey( x_trip_stop_id,
		v_return_status);
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.stop_debug;
  END IF;
  --
 END UpdateCumKeyClient;

/*============================================================================

  PROCEDURE NAME:	ResetCumClient

=============================================================================*/

PROCEDURE ResetCumClient (
	errbuf				OUT NOCOPY VARCHAR2,
	retcode				OUT NOCOPY NUMBER,
        p_org_id                        IN NUMBER,
	x_ship_from_org_id  		IN NUMBER,
	x_customer_id 			IN NUMBER,
	x_ship_to_org_id		IN NUMBER,
	x_intrmd_ship_to_org_id		IN NUMBER,
	x_bill_to_org_id		IN NUMBER,
	x_customer_item_id              IN NUMBER,
	x_transaction_start_date	IN VARCHAR2,
	x_transaction_end_date		IN VARCHAR2)
 IS
        --
	v_return_status BOOLEAN;
	v_transaction_start_date	DATE;
	v_transaction_end_date		DATE;
	--
 --
 BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.start_debug;
  END IF;
	--
        --4316744: Commented out the following code.

/*	v_transaction_start_date := to_date(x_transaction_start_date, 'YYYY/MM/DD HH24:MI:SS');
	v_transaction_end_date := to_date(x_transaction_end_date, 'YYYY/MM/DD HH24:MI:SS');*/
	--
        --4316744: Timezone uptake in RLM.
        v_transaction_start_date := FND_DATE.canonical_to_date(x_transaction_start_date);
        v_transaction_end_date := FND_DATE.canonical_to_date(x_transaction_end_date);

	ResetCum(
                p_org_id,
		x_ship_from_org_id,
		x_customer_id,
		x_ship_to_org_id,
		x_intrmd_ship_to_org_id,
		x_bill_to_org_id,
		x_customer_item_id,
		v_transaction_start_date,
		v_transaction_end_date,
		v_return_status);
	--
  IF (l_debug <> -1) THEN
    rlm_core_sv.stop_debug;
  END IF;
  --
 END ResetCumClient;


/*=============================================================================
  FUNCTION NAME:	GetCumControl

  DESCRIPTION:		This procedure will be called by Demand Status
                        Inquiry Report, to get the CUM Control Code
			based on the setup made in the RLM Setup Terms Form.

  PARAMETERS:		x_ship_from_org_id	 IN NUMBER
                        x_customer_id            IN NUMBER,
                        x_ship_to_address_id     IN NUMBER,
                        x_customer_item_id       IN NUMBER


 ============================================================================*/
  FUNCTION GetCumControl(
               i_ship_from_org_id          IN NUMBER,
               i_customer_id               IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER
                            )
  RETURN VARCHAR2 IS

  v_temp                     VARCHAR2(10);
  v_terms_level              VARCHAR2(25);
  v_setup_terms_msg	     VARCHAR2(2000);
  v_return_status            BOOLEAN;
  v_rlm_setup_terms_record   rlm_setup_terms_sv.setup_terms_rec_typ;

  BEGIN

  v_terms_level := 'CUSTOMER_ITEM';
  RLM_TPA_SV.get_setup_terms(
                x_ship_from_org_id              => i_ship_from_org_id,
                x_customer_id                   => i_customer_id,
                x_ship_to_address_id            => i_ship_to_address_id,
                x_customer_item_id              => i_customer_item_id,
                x_terms_definition_level        => v_terms_level,
                x_terms_rec                     => v_rlm_setup_terms_record,
		x_return_message		=> v_setup_terms_msg,
                x_return_status                 => v_return_status);

  return v_rlm_setup_terms_record.cum_control_code;

  END GetCumControl;

/*=============================================================================
  FUNCTION NAME:	get_cum_control

  DESCRIPTION:		This procedure will be called by Demand Status
                        Inquiry Report, to get the CUM Control Code
			based on the setup made in the RLM Setup Terms Form.

  PARAMETERS:		x_ship_from_org_id	 IN NUMBER
                        x_customer_id            IN NUMBER,
                        x_ship_to_address_id     IN NUMBER,
                        x_customer_item_id       IN NUMBER


 ============================================================================*/
  FUNCTION get_cum_control(
               i_ship_from_org_id          IN NUMBER,
               i_customer_id               IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER
                            )
  RETURN VARCHAR2 IS

  v_temp                     VARCHAR2(10);
  v_terms_level              VARCHAR2(25);
  v_setup_terms_msg	     VARCHAR2(2000);
  v_return_status            BOOLEAN;
  v_rlm_setup_terms_record   rlm_setup_terms_sv.setup_terms_rec_typ;

  BEGIN

--  v_terms_level := 'CUSTOMER';
--  v_terms_level := 'ADDRESS';
  v_terms_level := 'CUSTOMER_ITEM';
  RLM_TPA_SV.get_setup_terms(
                x_ship_from_org_id              => i_ship_from_org_id,
                x_customer_id                   => i_customer_id,
                x_ship_to_address_id            => i_ship_to_address_id,
                x_customer_item_id              => i_customer_item_id,
                x_terms_definition_level        => v_terms_level,
                x_terms_rec                     => v_rlm_setup_terms_record,
		x_return_message		=> v_setup_terms_msg,
                x_return_status                 => v_return_status);

  return v_rlm_setup_terms_record.cum_control_code;

  END get_cum_control;

/*=============================================================================
  PROCEDURE NAME:	GetCumManagement

  DESCRIPTION:		This procedure will be called by Release Workbench
                        to get the CUM Control Code and CUM Org Level Code
			based on the setup made in the RLM Setup Terms Form.

  PARAMETERS:		x_ship_from_org_id	 IN NUMBER
                        x_customer_id            IN NUMBER,
                        x_ship_to_address_id     IN NUMBER,
                        x_customer_item_id       IN NUMBER,
			o_cum_control_code	 IN VARCHAR2,
			o_cum_org_level_code	 IN VARCHAR2


 ============================================================================*/
  PROCEDURE GetCumManagement(
               i_ship_from_org_id          IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER,
	       o_cum_control_code	   OUT NOCOPY VARCHAR2,
	       o_cum_org_level_code	   OUT NOCOPY VARCHAR2
                            )
  IS
  v_temp                     VARCHAR2(10);
  v_terms_level              VARCHAR2(25);
  v_setup_terms_msg	     VARCHAR2(2000);
  v_return_status            BOOLEAN;
  v_rlm_setup_terms_record   rlm_setup_terms_sv.setup_terms_rec_typ;
  v_customer_id		     NUMBER;

  BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.start_debug;
     rlm_core_sv.dpush(C_SDEBUG, 'GetCumManagement');
  END IF;
  --

	/* Find customer_id, as it is a required input parameter for
   	rlm_setup_terms */
        -- Following query is changed as per TCA obsolescence project.
        SELECT  DISTINCT ACCT_SITE.CUST_ACCOUNT_ID
        INTO    v_customer_id
        FROM    HZ_CUST_ACCT_SITES ACCT_SITE
        WHERE   ACCT_SITE.CUST_ACCT_SITE_ID = i_ship_to_address_id;

  RLM_TPA_SV.get_setup_terms(
                x_ship_from_org_id              => i_ship_from_org_id,
                x_customer_id                   => v_customer_id,
                x_ship_to_address_id            => i_ship_to_address_id,
                x_customer_item_id              => i_customer_item_id,
                x_terms_definition_level        => v_terms_level,
                x_terms_rec                     => v_rlm_setup_terms_record,
	        x_return_message		=> v_setup_terms_msg,
                x_return_status                 => v_return_status);

  o_cum_control_code   := v_rlm_setup_terms_record.cum_control_code;
  o_cum_org_level_code := v_rlm_setup_terms_record.cum_org_level_code;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop('Completed successfully');
     rlm_core_sv.stop_debug;
  END IF;
  --
  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
           --
           IF (l_debug <> -1) THEN
   		rlm_core_sv.dpop('no data found');
           END IF;
	   --
	  WHEN OTHERS THEN
           --
           IF (l_debug <> -1) THEN
   		rlm_core_sv.dpop('when others');
           END IF;

  END GetCumManagement;

/*=============================================================================
  PROCEDURE NAME:	GetCumStartDate

  DESCRIPTION:		This procedure will be called by CalculateCumKey to
                        to get the CUM current start date and CUM current
			record year from the schedule

  PARAMETERS:		i_schedule_header_id	IN NUMBER
                	i_schedule_line_id	IN NUMBER
			o_cum_start_date	OUT NOCOPY DATE
			o_cust_record_year	OUT NOCOPY VARCHAR2
			o_return_message	OUT NOCOPY VARCHAR2
			o_return_status		OUT NOCOPY BOOLEAN

 ============================================================================*/

  PROCEDURE GetCumStartDate(
			i_schedule_header_id	IN NUMBER,
                	i_schedule_line_id	IN NUMBER,
			o_cum_start_date	OUT NOCOPY DATE,
			o_cust_record_year	OUT NOCOPY VARCHAR2,
			o_return_message	OUT NOCOPY VARCHAR2,
			o_return_status		OUT NOCOPY BOOLEAN
                            )
  IS
	v_ship_from_org_id	NUMBER;
	v_ship_to_address_id	NUMBER;
	v_customer_item_id	NUMBER;
        v_customer_id           NUMBER;
        v_terms_level           VARCHAR2(20) DEFAULT NULL;
        v_rlm_setup_terms_record  rlm_setup_terms_sv.setup_terms_rec_typ;
        v_setup_terms_msg       VARCHAR2(2000);
        v_setup_terms_status    BOOLEAN;
        v_cust_po_number        VARCHAR2(50);  --Bugfix 7007638
        v_industry_attribute1   VARCHAR2(150); --Bugfix 7007638


  BEGIN
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpush(C_SDEBUG, 'GetCumStartDate');
     	  rlm_core_sv.dlog(C_DEBUG, 'i_schedule_header_id', i_schedule_header_id);
     	  rlm_core_sv.dlog(C_DEBUG, 'i_schedule_line_id', i_schedule_line_id);
	END IF;
	--
	SELECT	line.ship_from_org_id,
		line.ship_to_address_id,
		line.customer_item_id,
        header.customer_id,
        line.cust_po_number,     --Bugfix 7007638
        line.industry_attribute1 --Bugfix 7007638
	INTO	v_ship_from_org_id,
		v_ship_to_address_id,
		v_customer_item_id,
                v_customer_id,
                v_cust_po_number,     --Bugfix 7007638
                v_industry_attribute1 --Bugfix 7007638
	FROM	rlm_schedule_lines_all line,
                rlm_schedule_headers header
	WHERE	line.header_id = i_schedule_header_id
	AND	line.line_id = i_schedule_line_id
        AND     line.header_id = header.header_id;
	--
        IF (l_debug <> -1) THEN
     	  rlm_core_sv.dlog(C_DEBUG, 'v_ship_from_org_id', v_ship_from_org_id);
     	  rlm_core_sv.dlog(C_DEBUG, 'v_ship_to_address_id', v_ship_to_address_id);
     	  rlm_core_sv.dlog(C_DEBUG, 'v_customer_item_id', v_customer_item_id);
     	  rlm_core_sv.dlog(C_DEBUG, 'customer_id', v_customer_id);
  	END IF;
	--
        BEGIN
          --
  	  SELECT  start_date_time, industry_attribute1
  	  INTO	  o_cum_start_date, o_cust_record_year
  	  FROM    rlm_schedule_lines
	  WHERE	 header_id = i_schedule_header_id
	  AND	ship_from_org_id = v_ship_from_org_id
	  AND	ship_to_address_id = v_ship_to_address_id
	  AND	customer_item_id = v_customer_item_id
	  AND   NVL(cust_po_number,' ')	= NVL(v_cust_po_number,' ')           --Bugfix 7007638
      AND   NVL(industry_attribute1,' ') = NVL(v_industry_attribute1,' ') --Bugfix 7007638
	  AND	item_detail_type = '4'
	  AND	item_detail_subtype = 'CUM';
          --
       EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
         --
         -- see if there are setup terms set for CUM management
         --
         RLM_TPA_SV.get_setup_terms(
          x_ship_from_org_id              => v_ship_from_org_id,
          x_customer_id                   => v_customer_id,
          x_ship_to_address_id            => v_ship_to_address_id,
          x_customer_item_id              => v_customer_item_id,
          x_terms_definition_level        => v_terms_level,
          x_terms_rec                     => v_rlm_setup_terms_record,
          x_return_message                => v_setup_terms_msg,
          x_return_status                 => v_setup_terms_status);
         --
         IF (l_debug <> -1) THEN
     	   rlm_core_sv.dlog(C_DEBUG, 'cum_control_code',
                            v_rlm_setup_terms_record.cum_control_code);
     	   rlm_core_sv.dlog(C_DEBUG, 'v_setup_terms_status',
                            v_setup_terms_status);
  	 END IF;
         --
         IF (v_setup_terms_status = FALSE)
         OR (NVL(v_rlm_setup_terms_record.cum_control_code,'NO_CUM') NOT IN
         ('CUM_BY_DATE_ONLY','CUM_BY_DATE_RECORD_YEAR','CUM_BY_DATE_PO'))
         THEN
           --
           RAISE NO_DATA_FOUND;
           --
         END IF;
         --
         --This is indicating that CalculateCumKey should get the latest Key
         o_cum_start_date := rlm_manage_demand_sv.k_DNULL;
         --
       END;

	rlm_message_sv.get_msg_text(
		x_message_name	=> 'RLM_CUM_SUCCESS',
		x_text		=> o_return_message);

  	o_return_status := TRUE;
	--
        IF (l_debug <> -1) THEN
     	  rlm_core_sv.dlog(C_DEBUG, 'o_cum_start_date', o_cum_start_date);
     	  rlm_core_sv.dlog(C_DEBUG, 'o_cust_record_year', o_cust_record_year);
     	  rlm_core_sv.dlog(C_DEBUG, 'o_return_status', o_return_status);
     	  rlm_core_sv.dpop('Completed successfully');
  	END IF;
	--
  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		o_return_status := FALSE;
		rlm_message_sv.get_msg_text(
			x_message_name	=> 'RLM_CUM_CSD_NOT_FOUND',
			x_text		=> o_return_message);
		--
  		IF (l_debug <> -1) THEN
		  --
   		  rlm_core_sv.dlog(C_DEBUG, 'o_cum_start_date', o_cum_start_date);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_cust_record_year', o_cust_record_year);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_return_message', o_return_message);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_return_status', o_return_status);
   		  rlm_core_sv.dpop(C_DEBUG);
		  --
		END IF;

	  WHEN OTHERS THEN
		o_return_status := FALSE;
		o_return_message := SQLERRM;
		--
                IF (l_debug <> -1) THEN
   		  rlm_core_sv.dlog(C_DEBUG, 'o_cum_start_date', o_cum_start_date);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_cust_record_year', o_cust_record_year);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_return_message', o_return_message);
     		  rlm_core_sv.dlog(C_DEBUG, 'o_return_status', o_return_status);
   		  rlm_core_sv.dpop(C_DEBUG);
		END IF;

  END GetCumStartDate;

/*=============================================================================
  PROCEDURE NAME:	GetTPContext

  DESCRIPTION:		This procedure returns the tpcontext using CUM Key
			Record

  PARAMETERS:		x_cum_key_record		IN  RLM_CUM_SV.cum_key_attrib_rec_type
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/
  PROCEDURE GetTPContext(
			x_cum_key_record		IN  RLM_CUM_SV.cum_key_attrib_rec_type,
                       	x_customer_number 		OUT NOCOPY VARCHAR2,
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2)
  IS
	v_level 	VARCHAR2(50) := 'NONE';
  BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_DEBUG, 'GetTPContext');
  END IF;
  --
  IF x_cum_key_record.customer_id IS NOT NULL THEN

	IF x_cum_key_record.ship_to_address_id IS NOT NULL THEN
		v_level := 'SHIP_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  acct_site.ece_tp_location_code,
			c.tp_group_code
		INTO	x_ship_to_ece_locn_code,
			x_tp_group_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE,
			ece_tp_headers b,
			ece_tp_group c
		WHERE	 ACCT_SITE.CUST_ACCOUNT_ID  = x_cum_key_record.customer_id
		AND	ACCT_SITE.CUST_ACCT_SITE_ID = x_cum_key_record.ship_to_address_id
		AND	b.tp_header_id = acct_site.tp_header_id
		AND	c.tp_group_id = b.tp_group_id;
	END IF;

	IF x_cum_key_record.bill_to_address_id IS NOT NULL THEN
		v_level := 'BILL_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  acct_site.ece_tp_location_code
		INTO	x_bill_to_ece_locn_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE
		WHERE	ACCT_SITE.CUST_ACCT_SITE_ID = x_cum_key_record.bill_to_address_id
		AND	ACCT_SITE.CUST_ACCOUNT_ID   = x_cum_key_record.customer_id;
	END IF;

	IF x_cum_key_record.intrmd_ship_to_address_id IS NOT NULL THEN
		v_level := 'INTER_SHIP_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT	acct_site.ece_tp_location_code
		INTO	x_inter_ship_to_ece_locn_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE
		WHERE	ACCT_SITE.CUST_ACCT_SITE_ID = x_cum_key_record.intrmd_ship_to_address_id
		AND	ACCT_SITE.CUST_ACCOUNT_ID   = x_cum_key_record.customer_id;
	END IF;

	IF x_cum_key_record.customer_id IS NOT NULL THEN
		v_level := 'CUSTOMER_NUMBER';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT.ACCOUNT_NUMBER
		INTO	x_customer_number
		FROM	HZ_CUST_ACCOUNTS CUST_ACCT
		WHERE  	CUST_ACCT.CUST_ACCOUNT_ID = x_cum_key_record.customer_id;
  	END IF;

  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'customer_number', x_customer_number);
     rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_tp_group_code',x_tp_group_code);
     rlm_core_sv.dpop(C_DEBUG, 'Successful');
  END IF;
  --
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	IF v_level = 'SHIP_TO_ECE_LOCN_CODE' THEN
          --
  	  IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Ship-To Address ID',
			x_cum_key_record.ship_to_address_id);
	  END IF;
	  --
	  x_ship_to_ece_locn_code := NULL;
	  --
	ELSIF v_level = 'BILL_TO_ECE_LOCN_CODE' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Bill-To Address ID',
			x_cum_key_record.bill_to_address_id);
	  END IF;
	  --
	  x_bill_to_ece_locn_code := NULL;
	  --
	ELSIF v_level = 'INTER_SHIP_TO_ECE_LOCN_CODE' THEN
          --
	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Intermediate Ship-To Address ID',
				x_cum_key_record.intrmd_ship_to_address_id);
	  END IF;
	  --
	  x_inter_ship_to_ece_locn_code := NULL;
 	  --
	ELSIF v_level = 'CUSTOMER_NUMBER' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Customer Number Found for Customer ID ',
				x_cum_key_record.customer_id);
	  END IF;
	  --
	  x_customer_number := NULL;
	  --
	END IF;
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_DEBUG);
	END IF;
	--
  WHEN OTHERS THEN
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_SDEBUG, 'Level: ', v_level);
   	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
   	  rlm_core_sv.dpop(C_DEBUG);
	END IF;
	--
	RAISE;

  END GetTPContext;

/*=============================================================================
  PROCEDURE NAME:	GetTPContext2

  DESCRIPTION:		This procedure returns the tpcontext using Trip Stop ID

  PARAMETERS:		x_trip_stop_id			IN  NUMBER
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/
  PROCEDURE GetTPContext2(
			x_trip_stop_id			IN  NUMBER,
                       	x_customer_number 		OUT NOCOPY VARCHAR2,
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2)
  IS
	CURSOR c_oe_lines IS
	SELECT 	oelines.sold_to_org_id,
		oelines.ship_to_org_id,
		oelines.intmed_ship_to_org_id,
		oelines.invoice_to_org_id
	FROM  	WSH_DELIVERY_LEGS wleg,
		WSH_DELIVERY_ASSIGNMENTS_V wdass,
		WSH_DELIVERY_DETAILS wdel,
		OE_ORDER_LINES oelines
	WHERE	wleg.pick_up_stop_id    = x_trip_stop_id
	AND	wdass.delivery_id 	= wleg.delivery_id
	AND	wdel.delivery_detail_id = wdass.delivery_detail_id
	AND	oelines.shipped_quantity IS NOT NULL
	AND	oelines.line_id 	= wdel.source_line_id
        AND     wdel.container_flag                     = 'N'                      -- 4301944
	AND	oelines.header_id 			= wdel.source_header_id    -- 4301944
	AND	oelines.source_document_type_id	= 5;

	v_customer_id			NUMBER;
	v_ship_to_org_id		NUMBER;
	v_ship_to_address_id		NUMBER;
	v_bill_to_org_id		NUMBER;
	v_bill_to_address_id		NUMBER;
	v_intmed_ship_to_org_id		NUMBER;
	v_intrmd_ship_to_address_id	NUMBER;
	v_level 			VARCHAR2(50) := 'NONE';
	e_no_delivery_lines		EXCEPTION;
  BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_DEBUG, 'GetTPContext2');
  END IF;
  --
  OPEN 	c_oe_lines;
  FETCH c_oe_lines
  INTO	v_customer_id,
	v_ship_to_org_id,
	v_intmed_ship_to_org_id,
	v_bill_to_org_id;
  CLOSE c_oe_lines;

  IF c_oe_lines%NOTFOUND THEN
	RAISE e_no_delivery_lines;
  END IF;

  IF v_customer_id IS NOT NULL THEN
		v_level := 'CUSTOMER_NUMBER';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT.ACCOUNT_NUMBER
		INTO	x_customer_number
		FROM	HZ_CUST_ACCOUNTS CUST_ACCT
		WHERE  	CUST_ACCT.CUST_ACCOUNT_ID = v_customer_id;
  END IF;

  IF v_ship_to_org_id IS NOT NULL THEN
		v_level := 'SHIP_TO_ADDRESS_ID';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  CUST_ACCT_SITE_ID
		INTO	v_ship_to_address_id
		FROM	HZ_CUST_SITE_USES
		WHERE	site_use_id = v_ship_to_org_id
		AND	site_use_code = 'SHIP_TO';

	IF v_ship_to_address_id IS NOT NULL THEN
		v_level := 'SHIP_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT  acct_site.ece_tp_location_code,
			c.tp_group_code
		INTO	x_ship_to_ece_locn_code,
			x_tp_group_code
		FROM	HZ_CUST_ACCT_SITES	 ACCT_SITE,
			ece_tp_headers b,
			ece_tp_group c
		WHERE	ACCT_SITE.CUST_ACCOUNT_ID = v_customer_id
		AND	ACCT_SITE.CUST_ACCT_SITE_ID = v_ship_to_address_id
		AND	b.tp_header_id = acct_site.tp_header_id
		AND	c.tp_group_id = b.tp_group_id;
	END IF;
  END IF;

  IF v_bill_to_org_id IS NOT NULL THEN
		v_level := 'BILL_TO_ADDRESS_ID';
                -- Following query is changed as per TCA obsolescence project.
		SELECT	CUST_ACCT_SITE_ID
		INTO	v_bill_to_address_id
		FROM	HZ_CUST_SITE_USES
		WHERE	site_use_id = v_bill_to_org_id
		AND	site_use_code = 'BILL_TO';

	IF v_bill_to_address_id IS NOT NULL THEN
		v_level := 'BILL_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT 	ACCT_SITE.ece_tp_location_code
		INTO	x_bill_to_ece_locn_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE
		WHERE	ACCT_SITE.CUST_ACCOUNT_ID = v_customer_id
		AND	ACCT_SITE.CUST_ACCT_SITE_ID = v_bill_to_address_id;

	END IF;

  END IF;

  IF v_intmed_ship_to_org_id IS NOT NULL THEN
		v_level := 'INTRMD_SHIP_TO_ADDRESS_ID';
                -- Following query is changed as per TCA obsolescence project.
		SELECT	CUST_ACCT_SITE_ID
		INTO	v_intrmd_ship_to_address_id
		FROM	HZ_CUST_SITE_USES
		WHERE	site_use_id = v_intmed_ship_to_org_id
		AND	site_use_code = 'SHIP_TO';

  	IF v_intrmd_ship_to_address_id IS NOT NULL THEN
		v_level := 'INTER_SHIP_TO_ECE_LOCN_CODE';
                -- Following query is changed as per TCA obsolescence project.
		SELECT 	ACCT_SITE.ece_tp_location_code
		INTO	x_inter_ship_to_ece_locn_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE
		WHERE	ACCT_SITE.CUST_ACCOUNT_ID = v_customer_id
		AND	ACCT_SITE.CUST_ACCT_SITE_ID = v_intrmd_ship_to_address_id;
	END IF;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'customer_number', x_customer_number);
     rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_tp_group_code',x_tp_group_code);
     rlm_core_sv.dpop(C_DEBUG, 'Successful');
  END IF;
  --
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	--
	IF v_level = 'SHIP_TO_ECE_LOCN_CODE' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Ship-To Address ID', v_ship_to_address_id);
	  END IF;
	  --
	  x_ship_to_ece_locn_code := NULL;
	  --
	ELSIF v_level = 'BILL_TO_ECE_LOCN_CODE' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Bill-To Address ID', v_bill_to_address_id);
	  END IF;
	  --
	  x_bill_to_ece_locn_code := NULL;
	  --
	ELSIF v_level = 'INTER_SHIP_TO_ECE_LOCN_CODE' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	   rlm_core_sv.dlog(C_DEBUG, 'No Location Code Found for Intermediate Ship-To Address ID',
			v_intrmd_ship_to_address_id);
	  END IF;
	  --
	  x_inter_ship_to_ece_locn_code := NULL;
	  --
	ELSIF v_level = 'CUSTOMER_NUMBER' THEN
	  --
  	  IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'No Customer Number Found for Customer ID ', v_customer_id);
	  END IF;
	  --
	  x_customer_number := NULL;
	  --
	ELSIF v_level = 'SHIP_TO_ADDRESS_ID' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Address ID Found for Ship-To Org ID ', v_ship_to_org_id);
	  END IF;
	  --
	ELSIF v_level = 'INTRMD_SHIP_TO_ADDRESS_ID' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Address ID Found for Intermediate Ship-To Org ID ',
			 v_intmed_ship_to_org_id);
	  END IF;
	  --
	ELSIF v_level = 'BILL_TO_ADDRESS_ID' THEN
	  --
  	  IF (l_debug <> -1) THEN
   	    rlm_core_sv.dlog(C_DEBUG, 'No Address ID Found for Bill-To Org ID ', v_bill_to_org_id);
	  END IF;
	  --
	END IF;
	--
  	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_DEBUG);
	END IF;
  	--
  WHEN e_no_delivery_lines THEN
	--
	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'No delivery line is associated with Trip Stop ID ', x_trip_stop_id);
	END IF;
 	--
  WHEN OTHERS THEN
	--
	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_SDEBUG, 'Level: ', v_level);
   	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
   	  rlm_core_sv.dpop(C_DEBUG);
	END IF;
	--
	RAISE;

  END GetTPContext2;

-- The procedure GetNameForId is removed as it was commented out.


/*============================================================================

  PROCEDURE NAME:	ResetCum

  Flow:  Get the setupterms based on the parameters passed, then call GetCums
   which will return 3 tables.  One table is the new cums created to reset the
   old ones, the other table is the old cums and the third table is used to
   relate the first and second table.  For each cum in the old table, call
   SetSupplierCum which calls CalculateSupplierCum for all the shipments
   for the given Cum Key.  It populates oe global tables and it calculates
   the cum qty .
   Then call the process_order once for each header_id.  If process_order
   completes without error then call UpdateOldKey to recalculate the old
   cums which have been reset.

=============================================================================*/

 PROCEDURE ResetCum (
        p_org_id                        IN NUMBER,
	x_ship_from_org_id  		IN NUMBER,
	x_customer_id 			IN NUMBER,
	x_ship_to_org_id		IN NUMBER,
	x_intrmd_ship_to_org_id		IN NUMBER,
	x_bill_to_org_id		IN NUMBER,
	x_customer_item_id		IN NUMBER,
	x_transaction_start_date	IN DATE,
	x_transaction_end_date		IN DATE,
	x_return_status			OUT NOCOPY BOOLEAN)
 IS
	--
	v_rlm_setup_terms_rec	   	rlm_setup_terms_sv.setup_terms_rec_typ;
        v_index                         NUMBER;
        v_index2                        NUMBER;
        v_index3                        NUMBER;
        v_num                           NUMBER;
        v_start_num                     NUMBER DEFAULT 0;
        v_end_num                       NUMBER DEFAULT 0;
	v_cum_key_record	   	cum_key_attrib_rec_type;
        v_old_cum_counter               RLM_CUM_SV.t_new_ship_count;
	p_ship_from_org_id	   	NUMBER DEFAULT NULL;
	p_ship_to_org_id	   	NUMBER DEFAULT NULL;
	p_intmed_ship_to_org_id    	NUMBER DEFAULT NULL;
        p_bill_to_org_id           	NUMBER DEFAULT NULL;
        p_cum_key_id                    NUMBER DEFAULT NULL;
	v_ship_to_address_id	   	NUMBER;
	v_bill_to_address_id	   	NUMBER;
	v_intrmd_ship_to_address_id 	NUMBER;
	v_terms_level		   	VARCHAR2(25) DEFAULT NULL;
	v_setup_terms_msg	   	VARCHAR2(5000);
	v_setup_terms_status	   	BOOLEAN;
	v_level			   	VARCHAR2(60);
	counter			   	NUMBER DEFAULT 1;
        counter2                        NUMBER DEFAULT 0;
        v_reset_counter                 NUMBER DEFAULT 0;
	error_count			NUMBER DEFAULT 0;
	v_trail1			VARCHAR2(5000);
	v_trail2			VARCHAR2(5000);
	v_trail3			VARCHAR2(5000);
	v_trail4			VARCHAR2(5000);
	v_trail5			VARCHAR2(5000);
	v_trail6			VARCHAR2(5000);
	--v_old_cum_table			t_old_cum;
        v_old_cum_records               RLM_CUM_SV.t_cums;
        v_tmp_old_table                 t_old_cum;
	----
     ---- Used by Process Order API
	--
	x_oe_api_version		NUMBER DEFAULT 1;
	l_return_status			VARCHAR2(1);
        v_return_status                 BOOLEAN;
        v_return_stat                   NUMBER DEFAULT 0 ;
	v_msg_data			VARCHAR2(2000);
        v_adjustment_ids                t_new_ship_count;
        v_adjustment_date               DATE DEFAULT NULL;
        v_header_id                     NUMBER;
        v_cum_records                   RLM_CUM_SV.t_cums;
        v_msg_count                     NUMBER;
        adj_qty                         NUMBER DEFAULT 0;
        l_file_val                      VARCHAR2(80);
        v_om_dbg_dir                    VARCHAR2(80);
        v_end_date_time                 date DEFAULT NULL;
        tmp_char                        VARCHAR2(50);
        v_shipLineCounter               NUMBER;
	--
        e_NoCum                          EXCEPTION;
        e_NoShipment                     EXCEPTION;
        v_visited                        BOOLEAN;
	--
	l_oe_line_tbl_out              oe_order_pub.line_tbl_type;
	--
 BEGIN
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'ResetCum');
   END IF;
   --
   x_return_status := TRUE;
   --
   MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                p_org_id      => p_org_id);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'p_org_id',p_org_id);
      rlm_core_sv.dlog(C_SDEBUG, 'x_ship_from_org_id',x_ship_from_org_id);
      rlm_core_sv.dlog(C_SDEBUG, 'x_customer_id',x_customer_id);
      rlm_core_sv.dlog(C_SDEBUG, 'x_customer_item_id',x_customer_item_id);
      rlm_core_sv.dlog(C_SDEBUG, 'x_transaction_start_date',
                                  x_transaction_start_date);
   END IF;
   --
   -- add time stamp
   --
   --4316744: Commented out the following code.
   /*IF x_transaction_end_date IS NOT NULL THEN
     tmp_char := to_char(x_transaction_end_date ,'DD-MM-YYYY') || ' 23:59:59';
     v_end_date_time := to_date(tmp_char,'DD-MM-YYYY HH24:MI:SS');
   END IF;*/
   --
   --4316744: Timezone uptake in RLM.
   IF x_transaction_end_date IS NOT NULL THEN
     v_end_date_time := x_transaction_end_date;
   END IF;

   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'v_end_date_time',
                                     v_end_date_time);
   END IF;
--
-- Start logging the ResetCum trail into the fnd log file here!
--
   fnd_file.put_line(fnd_file.log, 'User Input Parameters: ');
   fnd_file.put_line(fnd_file.log, 'Operating Unit: '	                	||p_org_id);
   fnd_file.put_line(fnd_file.log, 'Ship-From Organization ID: '		||x_ship_from_org_id);
   fnd_file.put_line(fnd_file.log, 'Ship-To Organization ID: '			||x_ship_to_org_id);
   fnd_file.put_line(fnd_file.log, 'Intermediate Ship-To Organization ID: '	||x_intrmd_ship_to_org_id);
   fnd_file.put_line(fnd_file.log, 'Bill-To Organization ID: '			||x_bill_to_org_id);
   fnd_file.put_line(fnd_file.log, 'Customer Item ID: '				||x_customer_item_id);
   fnd_file.put_line(fnd_file.log, 'Transaction Start Date: '			||x_transaction_start_date);
   fnd_file.put_line(fnd_file.log, 'Transaction End Date: '			||NVL(v_end_date_time, SYSDATE));
   fnd_file.put_line(fnd_file.log, ' ');
--
-- v_level is used to keep track of where in the program flow the exception occurs
-- Find the ship_to_address_id
--
   v_level := 'SHIP_TO_ADDRESS_ID';
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'x_ship_to_org_id',x_ship_to_org_id);
   END IF;
   --
   --IF x_ship_to_org_id IS NOT NULL THEN
   --
   -- Following query is changed as per TCA obsolescence project.
       SELECT CUST_ACCT_SITE_ID
       INTO   v_ship_to_address_id
       FROM   HZ_CUST_SITE_USES
       WHERE  site_use_id = x_ship_to_org_id
       AND    site_use_code = 'SHIP_TO';

-- Find the intrmd_ship_to_address_id
   --
   v_level := 'INTRMD_SHIP_TO_ADDRESS_ID';
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'x_intrmd_ship_to_org_id',x_intrmd_ship_to_org_id);
   END IF;
   --
   IF x_intrmd_ship_to_org_id IS NOT NULL THEN
	--
        -- Following query is changed as per TCA obsolescence project.
	SELECT	CUST_ACCT_SITE_ID
	INTO	v_intrmd_ship_to_address_id
	FROM	HZ_CUST_SITE_USES
	WHERE	site_use_id = x_intrmd_ship_to_org_id
	AND	site_use_code = 'SHIP_TO';
	--
   ELSE
     --
     -- There is no intermediate ship-to address id associated with that int shipto org id
     --
	v_intrmd_ship_to_address_id := NULL;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'v_intrmd_ship_to_address_id',
                                v_intrmd_ship_to_address_id);
   END IF;
   --
-- Find the bill_to_address_id
   --
   v_level := 'BILL_TO_ADDRESS_ID';
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'x_bill_to_org_id',x_bill_to_org_id);
   END IF;
   --
   IF x_bill_to_org_id IS NOT NULL THEN
	--
        -- Following query is changed as per TCA obsolescence project.
	SELECT	CUST_ACCT_SITE_ID
	INTO	v_bill_to_address_id
	FROM	HZ_CUST_SITE_USES
	WHERE	site_use_id = x_bill_to_org_id
	AND	site_use_code = 'BILL_TO';
	--
   ELSE
     --
     -- There is no bill-to address id associated with that bill-to org id
	--
	v_bill_to_address_id := NULL;
	--
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'v_bill_to_address_id',v_bill_to_address_id);
   END IF;
   --
-- Get the setup terms at the appropriate/lowest level so that
   --
   RLM_TPA_SV.get_setup_terms(
	x_ship_from_org_id 	  => x_ship_from_org_id,
	x_customer_id 		  => x_customer_id,
	x_ship_to_address_id 	  => v_ship_to_address_id,
	x_customer_item_id 	  => x_customer_item_id,
	x_terms_definition_level  => v_terms_level,
	x_terms_rec	 	  => v_rlm_setup_terms_rec,
	x_return_message	  => v_setup_terms_msg,
	x_return_status 	  => v_setup_terms_status);
   --
-- Continue only if the records return status is TRUE
-- Continue only if the cum control code is NO_CUM
   --
   IF v_setup_terms_status = TRUE THEN --{
     --
     IF (nvl(v_rlm_setup_terms_rec.cum_control_code,'NO_CUM') <> 'NO_CUM'
	AND v_rlm_setup_terms_rec.cum_control_code <> 'CUM_BY_PO_ONLY') THEN
	  --{
	  IF (v_terms_level = 'CUSTOMER_ITEM'
              AND v_rlm_setup_terms_rec.calc_cum_flag = 'Y')
              OR v_terms_level <> 'CUSTOMER_ITEM' THEN --{
	     --
 	     -- Determine the select criteria based on the cum org level code
	     --
             --
             IF v_rlm_setup_terms_rec.cum_org_level_code = 'BILL_TO_SHIP_FROM'
             THEN
             --
                p_ship_from_org_id 	:= x_ship_from_org_id;
                p_bill_to_org_id	:= x_bill_to_org_id;
			--
             ELSIF v_rlm_setup_terms_rec.cum_org_level_code =
              'SHIP_TO_SHIP_FROM'
             THEN
             --
		p_ship_from_org_id	:= x_ship_from_org_id;
		p_ship_to_org_id	:= x_ship_to_org_id;
			--
             ELSIF v_rlm_setup_terms_rec.cum_org_level_code =
              'INTRMD_SHIP_TO_SHIP_FROM'
             THEN
		--
		p_ship_from_org_id	:= x_ship_from_org_id;
		p_intmed_ship_to_org_id	:= x_ship_to_org_id;
		--
             ELSIF v_rlm_setup_terms_rec.cum_org_level_code =
              'SHIP_TO_ALL_SHIP_FROMS'
             THEN
             --
		p_ship_to_org_id	:= x_ship_to_org_id;
		--
	     END IF;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_SDEBUG, 'The criteria used to select the shipment ' ||'lines');
             rlm_core_sv.dlog(C_SDEBUG, 'p_ship_from_org_id', p_ship_from_org_id);
             rlm_core_sv.dlog(C_SDEBUG, 'p_ship_to_org_id', p_ship_to_org_id);
             rlm_core_sv.dlog(C_SDEBUG, 'p_intmed_ship_to_org_id',
                       p_intmed_ship_to_org_id);
             rlm_core_sv.dlog(C_SDEBUG, 'p_bill_to_org_id', p_bill_to_org_id);
             rlm_core_sv.dlog(C_SDEBUG, 'x_customer_item_id', x_customer_item_id);
             rlm_core_sv.dlog(C_SDEBUG, 'x_transaction_start_date',
                       x_transaction_start_date);
             rlm_core_sv.dlog(C_SDEBUG, 'v_end_date_time',
                       v_end_date_time);
          END IF;
          --
          fnd_file.put_line(fnd_file.log, 'p_ship_from_org_id: '
   		||p_ship_from_org_id);
          fnd_file.put_line(fnd_file.log, 'p_ship_to_org_id: '
                ||p_ship_to_org_id);
          fnd_file.put_line(fnd_file.log, 'p_intmed_ship_to_org_id: '
        	||p_intmed_ship_to_org_id);
          fnd_file.put_line(fnd_file.log, 'p_bill_to_org_id: '
 		||p_bill_to_org_id);
          fnd_file.put_line(fnd_file.log, ' ');
          fnd_file.put_line(fnd_file.log,
                'Loop to find all qualified shipment lines ');
          fnd_file.put_line(fnd_file.log, ' ');
          --
	  --

           v_cum_key_record.customer_id := x_customer_id;
           v_cum_key_record.customer_item_id := x_customer_item_id;
           v_cum_key_record.ship_from_org_id := x_ship_from_org_id;
           v_cum_key_record.intrmd_ship_to_address_id:=
                                       v_intrmd_ship_to_address_id;
           v_cum_key_record.ship_to_address_id := v_ship_to_address_id;
           v_cum_key_record.bill_to_address_id := v_bill_to_address_id;


           rlm_cum_sv.GetCums(v_rlm_setup_terms_rec
                                 ,v_terms_level
                                 ,v_cum_key_record
                                 ,x_transaction_start_date
                                 ,v_end_date_time
                                 ,p_ship_from_org_id
                                 ,p_ship_to_org_id
                                 ,p_intmed_ship_to_org_id
                                 ,p_bill_to_org_id
                                 ,v_cum_records
                                 ,v_old_cum_records
                                 ,v_old_cum_counter
                                 ,v_return_stat);
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_return_stat',v_return_stat);
          END IF;
          --
          IF v_return_stat = 0 THEN
          --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Could not find any CUM to reset');
             END IF;
             --
             raise e_NoCum;
          --
          END IF;

          v_num := v_old_cum_counter.count;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_num',v_num);
          END IF;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_cum_records.count',v_cum_records.count);
             rlm_core_sv.dlog(C_DEBUG,'v_old_cum_records.count',
                                                     v_old_cum_records.count);
          END IF;
          --
          g_oe_tmp_line_tbl := oe_order_pub.g_miss_line_tbl;
          --
          FOR v_index IN 1..v_num LOOP --{
          --
            SAVEPOINT s_reset_counter;
            --
            --v_reset_counter is used to undo cum_keys processed with error
            --
            v_reset_counter := counter;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_reset_counter',v_reset_counter);
            END IF;
            --
            /* these indexes are used to get the relationships between
             v_cum_records, v_old_cum_records, and v_old_cum_counter
            */
            --
            v_start_num := v_end_num + 1;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_start_num',v_start_num);
            END IF;
            --
            v_end_num := v_start_num + v_old_cum_counter(v_index) -1 ;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_end_num',v_end_num);
            END IF;
            --
            v_index2 := v_end_num;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_index2',v_index2);
            END IF;
            --
            /* following are set for CalculateSuplierCum*/
            v_cum_records(v_index).cum_qty := 0;
            --
            v_cum_records(v_index).cum_qty_to_be_accumulated := 0;
            v_cum_records(v_index).cum_qty_after_cutoff := 0;
            --
            -- Set shipment inclusion rule and as of date time
            --
            v_cum_records(v_index).use_ship_incl_rule_flag := 'Y';
            --
            v_cum_records(v_index).as_of_date_time := NULL;
            --
            --set record_return_status to TRUE used in CalculateSuplierCum
            --
            v_cum_records(v_index).record_return_status := TRUE;
            --
            v_adjustment_date := NULL;
            --
            v_tmp_old_table.DELETE;
            g_cum_oe_lines.DELETE;
            --
            v_shipLineCounter  := 1;
            v_visited := FALSE;

            LOOP --{
            --
             p_cum_key_id := v_old_cum_records(v_index2).cum_key_id;
             --

             --calculate inventory_item_id from customer_item_id once for the old cum group

             IF (v_visited = FALSE) THEN
             --
               v_old_cum_records(v_index2).inventory_item_id := GetInventoryItemId(v_old_cum_records(v_index2).customer_item_id);

               --inventory_item_id populated in v_cum_key_record to improve queries (bug 1893220)

               v_cum_key_record.inventory_item_id := v_old_cum_records(v_index2).inventory_item_id;
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'customer_item_id',v_old_cum_records(v_index2).customer_item_id);
                  rlm_core_sv.dlog(C_DEBUG,'inventory_item_id',v_cum_key_record.inventory_item_id);
               END IF;

               v_visited := TRUE;
             --

             ELSE

               v_old_cum_records(v_index2).inventory_item_id :=v_cum_key_record.inventory_item_id;

             END IF;


      /* For each new key, put the old one in table v_tmp_old_table
         If SetSupplierCum returned false then keep this table so that
         we can delete these keys from the table passed to UpdateOldKey
         so that these keys won't get processed.  If everything goes well
         then delete this table
      */
             v_tmp_old_table(v_index2)   := p_cum_key_id;
             --
             rlm_cum_sv.GetShippLines(
                        x_cum_key_id             => p_cum_key_id,
                        x_ship_from_org_id       => p_ship_from_org_id,
                        x_ship_to_org_id         => p_ship_to_org_id,
                        x_intmed_ship_to_org_id  => p_intmed_ship_to_org_id,
                        x_bill_to_org_id         => p_bill_to_org_id,
                        x_customer_item_id       => x_customer_item_id,
                        x_inventory_item_id      => v_cum_key_record.inventory_item_id,
                        x_transaction_start_date => x_transaction_start_date,
                        x_transaction_end_date   => v_end_date_time,
                        x_index                  => v_shipLineCounter);
             --
            --set the cum_key_id from adjustment to be the new cum_key_id

            UPDATE rlm_cust_item_cum_adj
            SET cum_key_id = v_cum_records(v_index).cum_key_id
            WHERE cum_key_id = p_cum_key_id
            AND transaction_date_time <= nvl(v_end_date_time,sysdate)
            AND transaction_date_time >= x_transaction_start_date;
            --

             v_index2 := v_index2 -1;
             --
             IF(v_index2 < v_start_num) THEN
             --
                EXIT;
             --
             END IF;
            --
            END LOOP; --}
            --
            --take care off the shipment for the new cum
            p_cum_key_id := v_cum_records(v_index).cum_key_id;
            --
            --
            -- if the end date is smaller than sysdate then we should
            --increase it to today's date to calculate the qty for
            --new cum correctly.
            --
            v_end_date_time := SYSDATE;
            --
            rlm_cum_sv.GetShippLines(
                       x_cum_key_id             => p_cum_key_id,
                       x_ship_from_org_id       => p_ship_from_org_id,
                       x_ship_to_org_id         => p_ship_to_org_id,
                       x_intmed_ship_to_org_id  => p_intmed_ship_to_org_id,
                       x_bill_to_org_id         => p_bill_to_org_id,
                       x_customer_item_id       => x_customer_item_id,
                       x_inventory_item_id      => v_cum_key_record.inventory_item_id,
                       x_transaction_start_date => NULL,
                       x_transaction_end_date   => v_end_date_time,
                       x_index                  => v_shipLineCounter);
             --
             IF g_cum_oe_lines.COUNT > 0 THEN
             --
                 rlm_cum_sv.quicksort(g_cum_oe_lines.FIRST,
                                      g_cum_oe_lines.LAST,
                                      C_cum_oe_lines);
             --
             END IF;
             --
            -- Need to set called_by_reset_cum to 'Y'
            v_cum_key_record.called_by_reset_cum := 'Y';
            --

            rlm_cum_sv.SetSupplierCum(
                       x_index                  => v_index,
                       x_cum_key_record         => v_cum_key_record,
                       x_transaction_start_date => x_transaction_start_date,
                       x_cum_records            => v_cum_records,
                       x_return_status          => v_return_status,
                       x_counter                => counter,
                       x_adjustment_date        => v_adjustment_date);
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'v_return_status',v_return_status);
             END IF;
             --
             IF(v_return_status = FALSE)
               OR (v_cum_records(v_index).record_return_status = FALSE)
             THEN
                 -- For this Cum clear the OE table and the updates in
                 -- adjustment table.  Also mark the old_table so the procedure
                 --does not recalculate the cum for them
                 ROLLBACK TO s_reset_counter;
                 --
                 IF counter > v_reset_counter THEN
                 --
                     FOR i in v_reset_counter..(counter-1) LOOP
                     --
                       g_oe_tmp_line_tbl.DELETE(i);
                     --
                     END LOOP;
                 --
                 END IF;
                 --
                 counter := v_reset_counter;
                 --
                 v_index3 := v_tmp_old_table.FIRST;
                 --
                 LOOP
                 --
                    v_old_cum_records(v_index3).cum_key_id := NULL;
                    --
                    EXIT WHEN v_index3 = v_tmp_old_table.LAST;
                    --
                    v_index3 := v_tmp_old_table.NEXT(v_index3);
                 --
                 END LOOP;
                 --
                 v_tmp_old_table.DELETE;
                 --
             ELSE --if there are no problems then update the CUM table
                 --
                 -- get all adjustments after the last shipment
                 IF v_adjustment_date IS NULL THEN
                 --
                   SELECT  SUM(transaction_qty)
                   INTO    adj_qty
                   FROM    rlm_cust_item_cum_adj
                   WHERE   cum_key_id = v_cum_records(v_index).cum_key_id
                   AND     transaction_date_time <= sysdate;
                 --
                 ELSE
                 --
                   SELECT  SUM(transaction_qty)
                   INTO    adj_qty
                   FROM    rlm_cust_item_cum_adj
                   WHERE   cum_key_id = v_cum_records(v_index).cum_key_id
                   AND     transaction_date_time >= v_adjustment_date
                   AND     transaction_date_time <= sysdate;
                 --
                 END IF;
		 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'v_adjustment_date',
                                                       v_adjustment_date);
                 END IF;
                 --
                 IF adj_qty IS NULL THEN
                 --
                   adj_qty := 0;
                   --
                 --
                 END IF;
                 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG, 'adj_qty',adj_qty);
                    rlm_core_sv.dlog(C_DEBUG,'v_index',v_index);
                 END IF;

                 v_cum_records(v_index).cum_qty :=
                                    v_cum_records(v_index).cum_qty + adj_qty;
                 --
                 UPDATE rlm_cust_item_cum_keys
                 SET cum_qty                   = v_cum_records(v_index).cum_qty,
                     cum_qty_to_be_accumulated =
                              v_cum_records(v_index).cum_qty_to_be_accumulated,
                     cum_qty_after_cutoff =
                              v_cum_records(v_index).cum_qty_after_cutoff,
                     last_cum_qty_update_date  = SYSDATE,
                     last_update_login         = FND_GLOBAL.LOGIN_ID,
                     last_update_date          = SYSDATE,
                     last_updated_by           = FND_GLOBAL.USER_ID
                     WHERE   cum_key_id = v_cum_records(v_index).cum_key_id
                     AND     NVL(inactive_flag,'N')          =  'N';
                     --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'v_cum_records(v_index).cum_key_id',
                                            v_cum_records(v_index).cum_key_id);
                    rlm_core_sv.dlog(C_DEBUG,'v_cum_records(v_index).cum_qty',
                                            v_cum_records(v_index).cum_qty);
                 END IF;
                 --
             END IF;
             --
          END LOOP; --}
          --  group the g_oe_tmp_line_tbl by header_id
          IF g_oe_tmp_line_tbl.COUNT = 0 THEN
          --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'There are no order lines to process');
             END IF;
             --
             RAISE e_NoShipment;
          --
          END IF;
          --
          rlm_cum_sv.quicksort(g_oe_tmp_line_tbl.FIRST,
                               g_oe_tmp_line_tbl.LAST,
                               RLM_CUM_SV.C_line_table_type);
          --
          v_index3 := g_oe_tmp_line_tbl.FIRST;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'v_index3',v_index3);
          END IF;
          --
          v_index2 := 1;
          --
          v_header_id := g_oe_tmp_line_tbl(v_index3).header_id;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'v_header_id',v_header_id);
          END IF;
          --
          g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
          --
          --g_oe_tmp_line_tbl := oe_order_pub.g_miss_line_tbl;
          --
          BEGIN --{
          --
          fnd_profile.get('ECE_OUT_FILE_PATH',v_om_dbg_dir);
          --
          fnd_profile.put('OE_DEBUG_LOG_DIRECTORY',v_om_dbg_dir);
          --
          l_file_val      := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
          --
          --oe_Debug_pub.setdebuglevel(5);
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'l_file_val',l_file_val);
          END IF;
          --
          LOOP --{
          /* Call OE_Order_GRP.Process_Order procedure to update OE_ORDER_LINES
             table by passing the g_oe_line_tbl structure that has been prepared
             this loop calls the process_order API once per each header_id,
             since the table is sorted by header_id then this loop
             calls the process_order once the header_id is changed  */
             --
             IF g_oe_tmp_line_tbl(v_index3).header_id = v_header_id THEN --{
             --
                g_oe_line_tbl(v_index2) := g_oe_tmp_line_tbl(v_index3);
                --
                v_index2 := v_index2 + 1;
                --
                IF v_index3 = g_oe_tmp_line_tbl.LAST THEN --{
                   -- process order for the last time
                   OE_Order_GRP.Process_order(
                     p_api_version_number     => x_oe_api_version,
                     p_init_msg_list          => FND_API.G_TRUE,
                     p_return_values          => FND_API.G_FALSE,
                     p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status          => l_return_status,
                     x_msg_count              => v_msg_count,
                     x_msg_data               => v_msg_data,
                     ------------------------------------------
                     p_line_tbl               => g_oe_line_tbl,
                     ------------------------------------------
                     x_header_rec             => g_oe_header_out_rec,
                     x_header_val_rec         => g_oe_header_val_out_rec,
                     x_Header_Adj_tbl         => g_oe_Header_Adj_out_tbl,
                     x_Header_Adj_val_tbl     => g_oe_Header_Adj_val_out_tbl,
                     x_Header_price_Att_tbl   => g_Header_price_Att_out_tbl,
                     x_Header_Adj_Att_tbl     => g_Header_Adj_Att_out_tbl,
                     x_Header_Adj_Assoc_tbl   => g_Header_Adj_Assoc_out_tbl,
                     x_Header_Scredit_tbl     => g_oe_Header_Scredit_out_tbl,
                     x_Header_Scredit_val_tbl => g_oe_Hdr_Scdt_val_out_tbl,
                     x_line_tbl               => l_oe_line_tbl_out,
                     x_line_val_tbl           => g_oe_line_val_out_tbl,
                     x_Line_Adj_tbl           => g_oe_line_Adj_out_tbl,
                     x_Line_Adj_val_tbl       => g_oe_line_Adj_val_out_tbl,
                     x_Line_price_Att_tbl     => g_Line_price_Att_out_tbl,
                     x_Line_Adj_Att_tbl       => g_Line_Adj_Att_out_tbl,
                     x_Line_Adj_Assoc_tbl     => g_Line_Adj_Assoc_out_tbl,
                     x_Line_Scredit_tbl       => g_oe_line_scredit_out_tbl,
                     x_Line_Scredit_val_tbl   => g_oe_line_scredit_val_out_tbl,
                     x_Lot_Serial_tbl         => g_oe_lot_serial_out_tbl,
                     x_Lot_Serial_val_tbl     => g_oe_lot_serial_val_out_tbl,
                     x_Action_Request_tbl     => g_oe_Action_Request_out_Tbl) ;
                     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'G_FILE',OE_DEBUG_PUB.G_FILE);
                        rlm_core_sv.dlog(C_DEBUG, 'Input tbl count',
                                         g_oe_line_tbl.LAST);
                        rlm_core_sv.dlog(C_DEBUG, 'Output tbl count',
                                         l_oe_line_tbl_out.LAST);
                     END IF;
                     --
                  -- Handle the exceptions caused by the OE call
                     --

                   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN --{
                            --
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            --}
                    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN --{
                            --
                            RAISE FND_API.G_EXC_ERROR;
                            --}
                    ELSE    --{
                            --
                            counter2 := counter2 + 1;
                            x_return_status := TRUE;
                            --
  			    IF (l_debug <> -1) THEN
                               rlm_core_sv.dlog(C_DEBUG,
                                'Order line is updated successfully');
                            END IF;
                            --
                            rlm_message_sv.get_msg_text(
                                    x_message_name  => 'RLM_CUM_RESET_TRAIL4',
                                    x_text          => v_trail4);
                            --
                            fnd_file.put_line(fnd_file.output, v_trail1);
                            fnd_file.put_line(fnd_file.output, v_trail2);
                            fnd_file.put_line(fnd_file.output, v_trail3);
                            fnd_file.put_line(fnd_file.output, v_trail4);
                            --
                    END IF; --}
                   EXIT;
                --}
                --{ if not the last element
                ELSE
                --
                   v_index3 := g_oe_tmp_line_tbl.NEXT(v_index3);
                   --
                END IF; --}
             --}
             --{ if header_id has changed
             ELSE
                --
                v_header_id := g_oe_tmp_line_tbl(v_index3).header_id;
                --
                v_index2 := 1;
                --

                OE_Order_GRP.Process_order(
                     p_api_version_number     => x_oe_api_version,
                     p_init_msg_list          => FND_API.G_TRUE,
                     p_return_values          => FND_API.G_FALSE,
                     p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status          => l_return_status,
                     x_msg_count              => v_msg_count,
                     x_msg_data               => v_msg_data,
                     ------------------------------------------
                     p_line_tbl               => g_oe_line_tbl,
                     ------------------------------------------
                     x_header_rec             => g_oe_header_out_rec,
                     x_header_val_rec         => g_oe_header_val_out_rec,
                     x_Header_Adj_tbl         => g_oe_Header_Adj_out_tbl,
                     x_Header_Adj_val_tbl     => g_oe_Header_Adj_val_out_tbl,
                     x_Header_price_Att_tbl   => g_Header_price_Att_out_tbl,
                     x_Header_Adj_Att_tbl     => g_Header_Adj_Att_out_tbl,
                     x_Header_Adj_Assoc_tbl   => g_Header_Adj_Assoc_out_tbl,
                     x_Header_Scredit_tbl     => g_oe_Header_Scredit_out_tbl,
                     x_Header_Scredit_val_tbl => g_oe_Hdr_Scdt_val_out_tbl,
                     x_line_tbl               => l_oe_line_tbl_out,
                     x_line_val_tbl           => g_oe_line_val_out_tbl,
                     x_Line_Adj_tbl           => g_oe_line_Adj_out_tbl,
                     x_Line_Adj_val_tbl       => g_oe_line_Adj_val_out_tbl,
                     x_Line_price_Att_tbl     => g_Line_price_Att_out_tbl,
                     x_Line_Adj_Att_tbl       => g_Line_Adj_Att_out_tbl,
                     x_Line_Adj_Assoc_tbl     => g_Line_Adj_Assoc_out_tbl,
                     x_Line_Scredit_tbl       => g_oe_line_scredit_out_tbl,
                     x_Line_Scredit_val_tbl   => g_oe_line_scredit_val_out_tbl,
                     x_Lot_Serial_tbl         => g_oe_lot_serial_out_tbl,
                     x_Lot_Serial_val_tbl     => g_oe_lot_serial_val_out_tbl,
                     x_Action_Request_tbl     => g_oe_Action_Request_out_Tbl) ;
                     --
                  -- Handle the exceptions caused by the OE call
                     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'G_FILE',OE_DEBUG_PUB.G_FILE);
                        rlm_core_sv.dlog(C_DEBUG, 'Input tbl count',
                                         g_oe_line_tbl.LAST);
                        rlm_core_sv.dlog(C_DEBUG, 'Output tbl count',
                                         l_oe_line_tbl_out.LAST);
                     END IF;
                     --
                     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN --{
                             --
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                             --}
                     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN --{
                             --
                             RAISE FND_API.G_EXC_ERROR;
                             --}
                     ELSE    --{
                             --
                             counter2 := counter2 + 1;
                             x_return_status := TRUE;
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                 'Order line is updated successfully');
                             END IF;
                             --
                             rlm_message_sv.get_msg_text(
                                     x_message_name  => 'RLM_CUM_RESET_TRAIL4',
                                     x_text          => v_trail4);
                             --
                             fnd_file.put_line(fnd_file.output, v_trail1);
                             fnd_file.put_line(fnd_file.output, v_trail2);
                             fnd_file.put_line(fnd_file.output, v_trail3);
                             fnd_file.put_line(fnd_file.output, v_trail4);
                             --
                     END IF; --}
                     --
                     g_oe_line_tbl.DELETE;
                     --
                     g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
                     --
                     g_oe_line_tbl(v_index2) := g_oe_tmp_line_tbl(v_index3);
                     --
                  END IF; --} if the header_id has not changed
                  --
            END LOOP; --}
            --
            EXCEPTION
                  --
                WHEN FND_API.G_EXC_ERROR THEN --{
                      --
                      x_return_status := FALSE;
                      --
                   -- Get message count and data
                      --
                      OE_MSG_PUB.Count_And_Get(
                                      p_count => v_msg_count,
                                      p_data  => v_msg_data);
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_ERROR');
                         rlm_core_sv.dlog(C_SDEBUG, 'l_return_status',
                                                              l_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'x_return_status',
                                                              x_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'v_msg_count', v_msg_count);
                         rlm_core_sv.dlog(C_SDEBUG, 'Main v_msg_data', v_msg_data);
                      END IF;
                      --
                      fnd_file.put_line(fnd_file.log, 'Process Order Error: '
                                                                  ||v_msg_data);
                      fnd_file.put_line(fnd_file.log, ' ');
                      --
                      IF v_msg_count > 0 THEN  --{
                        --
                        FOR k in 1 .. v_msg_count LOOP --{
                              --
                              v_msg_data := oe_msg_pub.get( p_msg_index => k,
                                                            p_encoded=> 'F');
                              --
                              fnd_file.put_line(fnd_file.log, v_msg_data);
			      --
  			      IF (l_debug <> -1) THEN
                                 rlm_core_sv.dlog(C_SDEBUG, 'v_msg_data',
                                                                   v_msg_data);
                              END IF;
                              --
                        END LOOP; --}
                        --
                      END IF; --}
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dpop(C_SDEBUG,
                                            'Process Order Error. Rollback');
                      END IF;
                      --
                      --
                      rlm_message_sv.get_msg_text(
                              x_message_name  => 'RLM_CUM_RESET_TRAIL5',
                              x_text          => v_trail5);
                      --
                      fnd_file.put_line(fnd_file.output, v_trail1);
                      fnd_file.put_line(fnd_file.output, v_trail2);
                      fnd_file.put_line(fnd_file.output, v_trail3);
                      fnd_file.put_line(fnd_file.output, v_trail4);
                      fnd_file.put_line(fnd_file.output, v_trail5);
                      --
                      error_count := error_count+1;
                      --
                      ROLLBACK;
                      --}

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                      --{
                      x_return_status := FALSE;
                      --
                      --
                   -- Get message count and data
                      --
                      OE_MSG_PUB.Count_And_Get(
                                      p_count => v_msg_count,
                                      p_data  => v_msg_data);
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_UNEXPECTED_ERROR');
                         rlm_core_sv.dlog(C_SDEBUG, 'l_return_status',
                                                            l_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'x_return_status',
                                                            x_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'v_msg_count', v_msg_count);
                         rlm_core_sv.dlog(C_SDEBUG, 'Main v_msg_data', v_msg_data);
                      END IF;
                      --
                      fnd_file.put_line(fnd_file.log, 'Process Order Error: '
                                                               ||v_msg_data);
                      fnd_file.put_line(fnd_file.log, ' ');
                      IF v_msg_count > 0 THEN   --{
                      --
                        FOR k in 1 .. v_msg_count LOOP  --{
                              --
                              v_msg_data := oe_msg_pub.get( p_msg_index => k,
                                                            p_encoded=> 'F');
                              --
                              fnd_file.put_line(fnd_file.log, v_msg_data);
			      --
  			      IF (l_debug <> -1) THEN
                                 rlm_core_sv.dlog(C_SDEBUG, 'v_msg_data',
                                                                   v_msg_data);
                              END IF;
                              --
                        END LOOP; --}
                        --
                      END IF; --}
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dpop(C_SDEBUG,
                                             'Process Order Error. Rollback');
                      END IF;
                      --
                      --
                      fnd_file.put_line(fnd_file.log, 'Process Order Error: '
                                                                  ||v_msg_data);
                      fnd_file.put_line(fnd_file.log, ' ');
                      --
                      rlm_message_sv.get_msg_text(
                              x_message_name  => 'RLM_CUM_RESET_TRAIL5',
                              x_text          => v_trail5);
                      --
                      fnd_file.put_line(fnd_file.output, v_trail1);
                      fnd_file.put_line(fnd_file.output, v_trail2);
                      fnd_file.put_line(fnd_file.output, v_trail3);
                      fnd_file.put_line(fnd_file.output, v_trail4);
                      fnd_file.put_line(fnd_file.output, v_trail5);
                      --
                      error_count := error_count+1;
                      --
                      ROLLBACK;
                      --}
                WHEN OTHERS THEN
                      --{
                      x_return_status := FALSE;
                      --
                   -- Get message count and data
                      --
                      OE_MSG_PUB.Count_And_Get(
                                      p_count => v_msg_count,
                                      p_data  => v_msg_data);
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_SDEBUG, 'WHEN OTHERS');
                         rlm_core_sv.dlog(C_SDEBUG, 'l_return_status',
                                                               l_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'x_return_status',
                                                               x_return_status);
                         rlm_core_sv.dlog(C_SDEBUG, 'v_msg_count', v_msg_count);
                         rlm_core_sv.dlog(C_SDEBUG, 'Main v_msg_data', v_msg_data);
                      END IF;
                      --
                      fnd_file.put_line(fnd_file.log, 'Process Order Error: '
                                                               ||v_msg_data);
                      fnd_file.put_line(fnd_file.log, ' ');
                      --
                      IF v_msg_count > 0 THEN  --{
                      --
                        FOR k in 1 .. v_msg_count LOOP  --{
                              --
                              v_msg_data := oe_msg_pub.get( p_msg_index => k,
                                                            p_encoded=> 'F');
                              --
                              fnd_file.put_line(fnd_file.log, v_msg_data);
			      --
  			      IF (l_debug <> -1) THEN
                                 rlm_core_sv.dlog(C_SDEBUG, 'v_msg_data',
                                                                  v_msg_data);
                              END IF;
                              --
                        END LOOP;   --}
                        --
                      END IF; --}
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dpop(C_SDEBUG,
                                              'Process Order Error. Rollback');
                      END IF;
                      --
                      fnd_file.put_line(fnd_file.log, 'Process Order Error: '
                                                                || v_msg_data);
                      fnd_file.put_line(fnd_file.log, ' ');
                      --
                      rlm_message_sv.get_msg_text(
                              x_message_name  => 'RLM_CUM_RESET_TRAIL5',
                              x_text          => v_trail5);
                      --
                      fnd_file.put_line(fnd_file.output, v_trail1);
                      fnd_file.put_line(fnd_file.output, v_trail2);
                      fnd_file.put_line(fnd_file.output, v_trail3);
                      fnd_file.put_line(fnd_file.output, v_trail4);
                      fnd_file.put_line(fnd_file.output, v_trail5);
                      --
                      error_count := error_count+1;
                      --
                      ROLLBACK;
                      --}
          END;  --}
   -- DEBUGGING
   --
       END IF;		-- v_terms_level }
       --}
     ELSE --{
    --
    v_msg_data := 'Adjust CUM Transactions is not processed against NO_CUM and CUM_BY_PO_ONLY CUM management types';
    --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG, v_msg_data);
           END IF;
    --
    fnd_file.put_line(fnd_file.log, v_msg_data);
    --
     END IF; 		-- cum_control_code }
     --}
   ELSE --{
    --
    v_msg_data := 'Release Management setup terms are not found';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, v_msg_data);
    END IF;
     --
    fnd_file.put_line(fnd_file.log, v_msg_data);
    --
   END IF;		-- setup_terms_status }
   --
   v_msg_data := 'Number of lines eligible for adjustment: ';
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, v_msg_data, counter -1);
   END IF;
   --
   --fnd_file.put_line(fnd_file.log, v_msg_data ||counter2);
   --
   IF error_count > 0 THEN --{
	--
	v_msg_data := 'Completed with errors';
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_DEBUG, v_msg_data);
	END IF;
	--
   	fnd_file.put_line(fnd_file.log, v_msg_data);
	-- }
   ELSE
	-- {
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'v_old_cum_records.COUNT',
                                          v_old_cum_records.COUNT);
	END IF;
	--
	IF v_old_cum_records.COUNT > 0 THEN
		--
		UpdateOldKey(	v_old_cum_records,
				v_cum_records(1).shipment_rule_code,
				v_cum_records(1).yesterday_time_cutoff,
                                v_cum_key_record,
                                p_ship_from_org_id,
                                p_ship_to_org_id,
                                p_intmed_ship_to_org_id,
                                p_bill_to_org_id,
                                x_customer_item_id,
				v_return_status);
		--
		IF v_return_status THEN
			--
			v_msg_data := 'Completed successfully';
			--
	   		COMMIT;
			--
		ELSE
			--
			v_msg_data := 'Update old CUM key error. Rollback';
			--
			ROLLBACK;
			--
		END IF;
		--
	ELSE
		--
		v_msg_data := 'Completed successfully';
		--
	END IF;
	--
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_DEBUG, v_msg_data);
	END IF;
	--
	fnd_file.put_line(fnd_file.log, v_msg_data);
	--
   END IF;--} if error_count = 0
   --
 EXCEPTION
     --
     WHEN NO_DATA_FOUND THEN
	--
	IF v_level = 'SHIP_TO_ADDRESS_ID' THEN
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
               'No ship_to_address_id is associated with the ship_to_org_id');
           END IF;
           --
	ELSIF v_level = 'INTRMD_SHIP_TO_ADDRESS_ID' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
              'No intrmd_ship_to_address_id is associated with the'
               ||'  intmed_ship_to_org_id');
           END IF;
           --
	ELSIF v_level = 'CUSTOMER_ID' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
              'No customer_id is associated with the address_id');
           END IF;
           --
	ELSIF v_level = 'BILL_TO_ADDRESS_ID' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
               'No bill_to_address_id is associated with the bill_to_org_id');
           END IF;
           --
         ELSIF v_level = 'SHIP_TO_ADDRESS_ID2' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
                'Second time: No ship_to_address_id is associated with the'
                ||'  ship_to_org_id');
           END IF;
           --
	ELSIF v_level = 'INTRMD_SHIP_TO_ADDRESS_ID2' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
                'Second time: No intrmd_ship_to_address_id is associated '
                ||'with the intmed_ship_to_org_id');
           END IF;
           --
	ELSIF v_level = 'BILL_TO_ADDRESS_ID2' THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_SDEBUG,
                 'Second time: No bill_to_address_id is associated with the'
                 || '  bill_to_org_id');
           END IF;
           --
	END IF;
	--
        ROLLBACK;
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_SDEBUG, 'No data found');
	END IF;
	--
     WHEN e_NoCum THEN
        --
        --ROLLBACK;
        COMMIT;
        --
        v_msg_data := 'There are no qualifying shipments.';
        --
        fnd_file.put_line(fnd_file.log,v_msg_data);
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(C_SDEBUG,'ResetCum:e_NoCum');
        END IF;
        --
     WHEN e_NoShipment THEN
        --
        v_msg_data := 'There are no qualifying shipments.  Manual adjustments'
          ||' would be processed';
        --
        fnd_file.put_line(fnd_file.log,v_msg_data);
        --
        BEGIN
        --
  	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, 'v_old_cum_records.COUNT',
                                          v_old_cum_records.COUNT);
	END IF;
	--
	IF v_old_cum_records.COUNT > 0 THEN
		--
                UpdateOldKey(  v_old_cum_records,
                                v_cum_records(1).shipment_rule_code,
                                v_cum_records(1).yesterday_time_cutoff,
                                v_cum_key_record,
                                p_ship_from_org_id,
                                p_ship_to_org_id,
                                p_intmed_ship_to_org_id,
                                p_bill_to_org_id,
                                x_customer_item_id,
                                v_return_status);
		--
		IF v_return_status THEN
			--
			v_msg_data := 'Completed successfully';
			--
	   		COMMIT;
			--
		ELSE
			--
			v_msg_data := 'Update old CUM key error. Rollback';
			--
			ROLLBACK;
			--
		END IF;
                --
                fnd_file.put_line(fnd_file.log,v_msg_data);
		--
	ELSE
		--
		v_msg_data := 'Completed successfully';
                --
                fnd_file.put_line(fnd_file.log,v_msg_data);
		--
	END IF;
	--
        COMMIT;
        --
        EXCEPTION
          WHEN OTHERS THEN
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG, 'when others::',substr(SQLERRM,1,200));
            END IF;
	    --
            fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,200));
             --
             x_return_status := FALSE;
        END;
	--
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(C_SDEBUG,'ResetCum:e_NoShipment');
        END IF;
        --
     WHEN OTHERS THEN
	--
  	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_SDEBUG, substr(SQLERRM,1,200));
	END IF;
	--
	fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,200));
        --
        x_return_status := FALSE;
        --
        ROLLBACK;
	--
 END ResetCum;



/*============================================================================

  PROCEDURE NAME:       GetCums


  This procedure is called by reset cum.  According to the parameters and
  the setup terms for the cum, it gets all the cum records from
  rlm_cust_item_cum_keys.  From the records returned, the program filters
  out those recors which do not have any manual adjustments within the period
  nor any shipments(if there is any shipment the field last_cum_qty_update_date
  would be within the time frame).  These records would be sorted, so that all
  corresponding Cums are in sorted together(for example same customer items
  may be sorted together).  The program recognizes the first record of each
  group as the newly created CUM and the reset of the group as the CUMs which
  are being adjusted.  It then puts all the new cums in one table and all the
  old one in a different table.


  PARAMETERS:

   **  x_rlm_setup_terms_record      IN
       This is setupterms generated from the resetCums parameters
   **  x_terms_level                 IN
       This is the same as parameter x_terms_definition_level of
       rlm_setup_terms_sv.get_setup_terms
   **  x_cum_key_record              IN
       This records would containe the followings if it could be derived in
       resetcum
       bill_to_address_id, ship_to_address_id, intrmd_ship_to_address_id,
       ship_from_org_id,customer_item_id,customer_id
   **  x_transaction_start_date      IN
       same as parameter in resetcum
   **  x_transaction_end_date        IN
       same as parameter in resetcum would be defaulted to sysdate
   **  x_cum_records                 OUT NOCOPY
       These are records of all new cum_keys created
   **  x_old_cum_records             OUT NOCOPY
       These are all old_cums which either have shipment or manual adjustments
   **  x_counter                     OUT NOCOPY
       This is a table that indicates the relation ship between x_cum_records
       and x_old_cum_records.  For example, if x_cum_records(3) has
       2 records in the old cums table x_old_cum_records, then
       x_counter(3) would have the value 2
   **  x_return_status               OUT NOCOPY
       1 if any cums found to be adjusted, 0 if no cum

=============================================================================*/

 PROCEDURE GetCums (
        x_rlm_setup_terms_record  IN  rlm_setup_terms_sv.setup_terms_rec_typ,
        x_terms_level             IN  VARCHAR2,
        x_cum_key_record          IN  OUT NOCOPY rlm_cum_sv.cum_key_attrib_rec_type,
        x_transaction_start_date  IN  DATE,
        x_transaction_end_date    IN  DATE ,
        x_ship_from_org_id        IN  NUMBER,
        x_ship_to_org_id          IN  NUMBER,
        x_intmed_ship_to_org_id   IN  NUMBER,
        x_bill_to_org_id          IN  NUMBER,
        x_cum_records             OUT NOCOPY RLM_CUM_SV.t_cums,
        x_old_cum_records         OUT NOCOPY RLM_CUM_SV.t_cums,
        x_counter                 OUT NOCOPY RLM_CUM_SV.t_new_ship_count,
        x_return_status           OUT NOCOPY NUMBER)
 IS
  v_cum_control_code              rlm_cust_shipto_terms.cum_control_code%TYPE;
  v_cum_org_level_code            rlm_cust_shipto_terms.cum_org_level_code%TYPE;
  v_tmp_cum_record                rlm_cum_sv.cum_rec_type;
  v_address_id                    NUMBER;
  v_cum_rec_ctr                   NUMBER DEFAULT 0;
  v_old_cum_ctr                   NUMBER DEFAULT 0;
  v_counter_ctr                   NUMBER DEFAULT 0;
  v_exist                         NUMBER;
  v_new_customer_item_id          NUMBER DEFAULT 0;
  v_old_customer_item_id         NUMBER DEFAULT 0;
  p_ship_from_org_id              NUMBER DEFAULT NULL;
  p_ship_to_address_id            NUMBER DEFAULT NULL;
  p_intrmd_ship_to_address_id     NUMBER DEFAULT NULL;
  p_bill_to_address_id            NUMBER DEFAULT NULL;
  p_customer_item_id              NUMBER DEFAULT NULL;
  msg_data                        VARCHAR2(2500);
  msg_name                        VARCHAR2(30) DEFAULT NULL;
  v_new_purchase_order_number     RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE DEFAULT NULL;
  v_new_cust_record_year          RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE
                                  DEFAULT NULL;
  v_ship_from_org_name            VARCHAR2(250);
  v_customer_name                 VARCHAR2(360);
  v_ship_to_location              VARCHAR2(250);
  v_customer_item_number          VARCHAR2(250);
  v_new_cum_start_date            DATE DEFAULT NULL;

/* these strings will create the cursor that contains the cum keys*/

  v_select                        VARCHAR2(3600);
  v_where_clause                  VARCHAR2(3600);
  v_statment                      VARCHAR2(3600);
  v_shipment_count                NUMBER;

  E_UNEXPECTED                    EXCEPTION;

  TYPE ref_cum_t    IS REF CURSOR;
  c_cum_keys        ref_cum_t;
  --


 BEGIN --{
 --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'GetCums');
      rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id',
                                 x_cum_key_record.ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'customer_item_id',
                                 x_cum_key_record.customer_item_id);
      rlm_core_sv.dlog(C_DEBUG,'Ship_to_address_id',
                                 x_cum_key_record.ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG,'intrmd_ship_to_address_id',
                                 x_cum_key_record.intrmd_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG,'bill_to_address_id',
			      x_cum_key_record.bill_to_address_id);
      rlm_core_sv.dlog(C_DEBUG,'x_terms_level'
                                  ,x_terms_level);
   END IF;
   --
   --return status of zero indicates that procedure did not find any
   --cum records, return status of 1 tells there are some records found
   x_return_status := 1;

-- Determine whether to use Ship To or Intermediate Ship To
   --
   IF x_cum_key_record.intrmd_ship_to_address_id IS NULL THEN --{
        --
        IF x_cum_key_record.ship_to_address_id IS NULL THEN --{
                --
                msg_name := 'RLM_CUM_ADDRESS_REQUIRED';
                rlm_message_sv.get_msg_text(
                        x_message_name  => msg_name,
                        x_text          => msg_data);
                --
                RAISE E_UNEXPECTED;
                --
        ELSE
                --
                v_address_id := x_cum_key_record.ship_to_address_id;
                --
        END IF; --}
        --
   ELSE
        --
        IF x_cum_key_record.ship_to_address_id IS NULL THEN
                --
                v_address_id := x_cum_key_record.intrmd_ship_to_address_id;
                --
        ELSE
                --
                v_address_id := x_cum_key_record.ship_to_address_id;
                --
        END IF;
        --
   END IF; --}
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'address_id', v_address_id);
   END IF;
   --
-- Get the CUM Control Code from the setup terms table
   --
   v_cum_control_code := x_rlm_setup_terms_record.cum_control_code;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_cum_control_code',v_cum_control_code);
   END IF;
   --
   IF x_rlm_setup_terms_record.cum_control_code IS NULL THEN --{
      --
      msg_name := 'RLM_CUM_CTRLCD_REQUIRED';
      --
      rlm_message_sv.get_msg_text(
                      x_message_name  => msg_name,
                      x_text          => msg_data);
      --
      RAISE E_UNEXPECTED;
      --}
/*
   ELSE
      --{

      IF (x_terms_level = 'CUSTOMER_ITEM')
        AND (nvl(x_rlm_setup_terms_record.calc_cum_flag,'N') <> 'Y') THEN --{
 we do not need this check anymore.  We can get all setup information for
 cum at the address level.  calc_cum_flag is the only field that could be
 different at the customer item level.  However, we check later on that
 all items should have a new cum key and also shipment/adjustments during
 the transactions
             --
	     v_ship_from_org_name := RLM_CORE_SV.get_ship_from(x_cum_key_record.ship_from_org_id);
	     v_customer_name := RLM_CORE_SV.get_customer_name(x_cum_key_record.customer_id);
	     v_ship_to_location := RLM_CORE_SV.get_ship_to(v_address_id);
	     v_customer_item_number := RLM_CORE_SV.get_item_number(x_cum_key_record.customer_item_id);
	     --
             msg_name := 'RLM_CUM_NO_CALC_FLAG';
             --
             rlm_message_sv.get_msg_text(
                   x_message_name  => msg_name,
                   x_text          => msg_data,
                   x_token1        => 'CI',
                   x_value1        => v_customer_item_number);
             --
             RAISE E_UNEXPECTED;
                        --
      END IF; --}
*/
      --
   END IF; --}

   --
-- CUM Organization Level
   --
   v_cum_org_level_code := x_rlm_setup_terms_record.cum_org_level_code;
   --
/* Customer Item Id is always populated in the CUM Key table regardless of
   CUM control code or CUM Organization Level. Ship From Organization Id
   is always populated in the CUM Key table except for the case of
   ALL_SHIP_FROMS. Therefore, the switches below are turned ON and
   assigned to the associated parameters passed by the calling program */
   --
   p_customer_item_id := x_cum_key_record.customer_item_id;
   p_ship_from_org_id := x_cum_key_record.ship_from_org_id;
   --
 --Turn ON switches based on cum control code
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'cum_control_code',
       x_rlm_setup_terms_record.cum_control_code);
   END IF;
   --
   IF v_cum_org_level_code = 'BILL_TO_SHIP_FROM' THEN
      --
      IF x_cum_key_record.bill_to_address_id IS NULL THEN
             --
             msg_name := 'RLM_CUM_BILL_TO_REQUIRED';
             --
             rlm_message_sv.get_msg_text(
                              x_message_name  => msg_name,
                              x_text          => msg_data);
             --
             RAISE E_UNEXPECTED;
             --
      END IF;
      --
      p_bill_to_address_id := x_cum_key_record.bill_to_address_id;
      --
   ELSIF v_cum_org_level_code = 'SHIP_TO_SHIP_FROM' THEN
      --
      IF x_cum_key_record.ship_to_address_id IS NULL THEN
             --
             msg_name := 'RLM_CUM_SHIP_TO_REQUIRED';
             --
             rlm_message_sv.get_msg_text(
                              x_message_name  => msg_name,
                              x_text          => msg_data);
             --
             RAISE E_UNEXPECTED;
             --
      END IF;
      --
      p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
      --
   ELSIF v_cum_org_level_code = 'INTRMD_SHIP_TO_SHIP_FROM' THEN
      --
      IF x_cum_key_record.intrmd_ship_to_address_id IS NULL THEN
             --
             msg_name := 'RLM_CUM_INTER_SHIP_TO_REQUIRED' ;
             --
             rlm_message_sv.get_msg_text(
                              x_message_name  => msg_name,
                              x_text          => msg_data);
             --
             RAISE E_UNEXPECTED;
             --
      END IF;
      --
      p_intrmd_ship_to_address_id := x_cum_key_record.intrmd_ship_to_address_id;
      --
   ELSIF v_cum_org_level_code = 'SHIP_TO_ALL_SHIP_FROMS' THEN
      --
      p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
      p_ship_from_org_id := NULL;
                --
   ELSE
             --
             msg_name := 'RLM_CUM_UNKNOWN_ORG_LEVEL';
             --
             rlm_message_sv.get_msg_text(
                              x_message_name  => msg_name,
                              x_text          => msg_data);
             --
             RAISE E_UNEXPECTED;
             --
   END IF;
   --
    --
    --Build the cursor dynamicly
    --
     v_select := 'SELECT cum_key_id, cum_qty, cum_qty_to_be_accumulated, cum_qty_after_cutoff,
                  last_cum_qty_update_date,cust_uom_code,cum_start_date,
                  cust_record_year,purchase_order_number ,customer_item_id
                  FROM RLM_CUST_ITEM_CUM_KEYS
';

     IF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_ONLY'
        OR x_rlm_setup_terms_record.cum_control_code = 'CUM_UNTIL_MANUAL_RESET'
     THEN
     --
        IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN
             --
    /* ---------------------------------------------
      This cursor is used when the proc is called by ResetCum and the cum
      control code is cum by date only and the cum organization level is not
      for all ship froms ------------------------------------ */

            v_where_clause := '
            WHERE NVL(ship_from_org_id,0)= NVL('''||p_ship_from_org_id||''',0)
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                           = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NULL
            AND     cust_record_year             IS NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC,cum_start_date DESC';
        ELSE
             --
     /*-------------------------------------------------------------------
      This cursor is used when the proc is called by ResetCum and the cum
      control code is cum by date only and the cum organization level is for
      all ship froms ----------------------------------------------------*/

            v_where_clause:='
            WHERE   ship_from_org_id                IS NULL
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                        = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NULL
            AND     cust_record_year             IS NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC,cum_start_date DESC';
             --
        END IF;
     --
    ELSIF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_RECORD_YEAR'
    THEN
        --
        IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN
             --
     /* --------------------------------------------------------------------
        This cursor is used when the proc is called by ResetCum and the cum
        control code is cum by date/record year and the cum organization level
        is not for all ship froms -----------------------------------------*/

            v_where_clause:='
            WHERE NVL(ship_from_org_id,0)  = NVL('''||p_ship_from_org_id||''',0)
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                     = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NULL
            AND     cust_record_year             IS NOT NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC,cum_start_date DESC,cust_record_year DESC';
             --
        ELSE
             --
     /* ---------------------------------------------------------------------
        This cursor is used when the proc is called by ResetCum and the cum
        control code is cum by date/record year and the cum organization level
        is for all ship froms -----------------------------------------------*/

            v_where_clause :='
            WHERE   ship_from_org_id                IS NULL
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                         = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NULL
            AND     cust_record_year             IS NOT NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC,cum_start_date DESC,cust_record_year DESC';
             --
        END IF;
        --
    ELSIF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_PO' THEN
        --
        IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN
             --
     /* ---------------------------------------------------------------------
       This cursor is used when the proc is called by ResetCum and the cum
       control code is cum by date/po and the cum organization level is not for
       all ship froms -------------------------------------------------------*/

            v_where_clause :='
            WHERE NVL(ship_from_org_id,0)  = NVL('''||p_ship_from_org_id||''',0)
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                           = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NOT NULL
            AND     cust_record_year             IS NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC, cum_start_date DESC, purchase_order_number DESC ';
             --
        ELSE
             --
     /*------------------------------------------------------------------------
        This cursor is used when the proc is called by ResetCum and the cum
        control code is cum by date/po and the cum organization level is for
        all ship froms ------------------------------------------------------*/

            v_where_clause := '
            WHERE   ship_from_org_id                IS NULL
            AND NVL(ship_to_address_id,0)= NVL('''||p_ship_to_address_id||''',0)
            AND     NVL(intrmd_ship_to_id,0)
                        = NVL('''||p_intrmd_ship_to_address_id||''',0)
            AND NVL(bill_to_address_id,0)= NVL('''||p_bill_to_address_id||''',0)
            AND     ((customer_item_id = '''||p_customer_item_id||''') OR
              ('''||p_customer_item_id||''' IS NULL))
            AND     cum_start_date               IS NOT NULL
            AND     cum_start_date               < SYSDATE
            AND     purchase_order_number        IS NOT NULL
            AND     cust_record_year             IS NULL
            AND     NVL(inactive_flag,''N'')     =  ''N''
            ORDER BY customer_item_id,creation_date DESC,cum_start_date DESC, purchase_order_number DESC';

        END IF;
        --
     END IF;
     --
     v_statment := v_select ||  v_where_clause;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,v_statment);
     END IF;
     --
     OPEN c_cum_keys FOR v_statment;
     LOOP --{
       FETCH c_cum_keys
       INTO          v_tmp_cum_record.cum_key_id,
                     v_tmp_cum_record.cum_qty,
                     v_tmp_cum_record.cum_qty_to_be_accumulated,
                     v_tmp_cum_record.cum_qty_after_cutoff,
                     v_tmp_cum_record.last_cum_qty_update_date,
                     v_tmp_cum_record.cust_uom_code,
                     v_tmp_cum_record.cum_start_date,
                     v_new_cust_record_year,
                     v_new_purchase_order_number,
                     v_new_customer_item_id;
       --
       EXIT WHEN c_cum_keys%NOTFOUND;
       --
       BEGIN --{
         v_exist := 1;

         v_tmp_cum_record.customer_item_id := v_new_customer_item_id;
         --
         v_new_cum_start_date := v_tmp_cum_record.cum_start_date;
         --
         IF (v_new_customer_item_id <> v_old_customer_item_id) THEN --{
         --
            v_old_customer_item_id := v_new_customer_item_id;
            v_cum_rec_ctr := v_cum_rec_ctr +1;
            --
            IF(v_cum_rec_ctr - v_counter_ctr) <> 1 THEN --{
              --
              IF x_cum_records.EXISTS(v_cum_rec_ctr-1) THEN
                   fnd_file.put_line(fnd_file.log,'Could not find '
                    ||'corresponding CumKey for cum_key_id: ' ||
                    x_cum_records(v_cum_rec_ctr-1).cum_key_id);
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Could not find correspounding'
                    ||  ' CumKey for cum_key_id: ',
                     x_cum_records(v_cum_rec_ctr-1).cum_key_id);
                   END IF;
		   --
              ELSE
		   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Could not find correspounding'
                    || ' CumKey for cum_key_id: ',v_tmp_cum_record.cum_key_id);
                   END IF;
		   --
              END IF;
              --
              v_cum_rec_ctr := v_cum_rec_ctr -1;
            --
            END IF; --}
            --
            x_cum_records(v_cum_rec_ctr).cum_key_id :=
                  v_tmp_cum_record.cum_key_id;
	    --
	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_SDEBUG,'x_cum_records(v_cum_rec_ctr).cum_key_id',
				x_cum_records(v_cum_rec_ctr).cum_key_id);
            END IF;
            --
            x_counter(v_cum_rec_ctr) := 0;
            --
            x_cum_records(v_cum_rec_ctr).cum_qty := v_tmp_cum_record.cum_qty;
            --
            x_cum_records(v_cum_rec_ctr).cum_qty_to_be_accumulated :=
                  v_tmp_cum_record.cum_qty_to_be_accumulated;
            x_cum_records(v_cum_rec_ctr).cum_qty_after_cutoff :=
                  v_tmp_cum_record.cum_qty_after_cutoff;
            x_cum_records(v_cum_rec_ctr).last_cum_qty_update_date :=
                  v_tmp_cum_record.last_cum_qty_update_date;
            x_cum_records(v_cum_rec_ctr).cust_uom_code :=
                  v_tmp_cum_record.cust_uom_code;
            x_cum_records(v_cum_rec_ctr).cum_start_date :=
                   v_tmp_cum_record.cum_start_date;
            x_cum_records(v_cum_rec_ctr).customer_item_id :=
                   v_tmp_cum_record.customer_item_id;

         --}
/*
    else if the customer_item_id has not changed see if there are
    old cum with shipment or manual adjustment for it
 */
         ELSE --{
         --
           SELECT COUNT(*)
           INTO v_shipment_count
           FROM oe_order_lines
           WHERE (ship_from_org_id               = x_ship_from_org_id
                     OR x_ship_from_org_id           IS NULL)
             AND     (ship_to_org_id                 = x_ship_to_org_id
                     OR x_ship_to_org_id             IS NULL)
             AND     (intmed_ship_to_org_id          = x_intmed_ship_to_org_id
                     OR x_intmed_ship_to_org_id      IS NULL)
             AND     (invoice_to_org_id              = x_bill_to_org_id
                     OR x_bill_to_org_id             IS NULL)
             AND     ordered_item_id       =       v_new_customer_item_id
             AND     actual_shipment_date           >= x_transaction_start_date
             AND     actual_shipment_date           <= NVL(x_transaction_end_date, SYSDATE)
             AND     open_flag = 'N'
             AND     shipped_quantity IS NOT NULL
             AND     source_document_type_id         = 5
             AND     veh_cus_item_cum_key_id     = v_tmp_cum_record.cum_key_id;

           --
           IF nvl(v_shipment_count,0) = 0 THEN --{
            --see if there are adjustments
             SELECT COUNT(*)
             INTO v_exist
             FROM rlm_cust_item_cum_adj
             WHERE cum_key_id = v_tmp_cum_record.cum_key_id
             AND transaction_date_time <= nvl(x_transaction_end_date,sysdate)
             AND transaction_date_time >= x_transaction_start_date;
           --
           END IF; --}
           --
           IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'v_shipment_count', v_shipment_count);
            rlm_core_sv.dlog(C_DEBUG, 'Adjustments', v_exist);
           END IF;
           IF nvl(v_exist,0) > 0 THEN
           --
             v_old_cum_ctr := v_old_cum_ctr + 1;
             --
             x_counter(v_cum_rec_ctr) := x_counter(v_cum_rec_ctr) + 1;
             --
             v_counter_ctr := v_cum_rec_ctr;
             --
             --x_counter(v_cum_rec_ctr) := v_old_cum_ctr;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_SDEBUG,'v_cum_rec_ctr',v_cum_rec_ctr);
                rlm_core_sv.dlog(C_SDEBUG,'x_counter',x_counter(v_cum_rec_ctr));
                rlm_core_sv.dlog(C_SDEBUG,'v_old_cum_ctr',v_old_cum_ctr);
             END IF;
             --
             x_old_cum_records(v_old_cum_ctr).cum_key_id :=
                  v_tmp_cum_record.cum_key_id;
	     --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_SDEBUG,
               'x_old_cum_records(v_old_cum_ctr).cum_key_id',
                x_old_cum_records(v_old_cum_ctr).cum_key_id);
             END IF;
             --
             x_old_cum_records(v_old_cum_ctr).cum_qty :=
                  v_tmp_cum_record.cum_qty;
             x_old_cum_records(v_old_cum_ctr).cum_qty_to_be_accumulated :=
                  v_tmp_cum_record.cum_qty_to_be_accumulated;
             x_old_cum_records(v_old_cum_ctr).cum_qty_after_cutoff :=
                  v_tmp_cum_record.cum_qty_after_cutoff;
             x_old_cum_records(v_old_cum_ctr).last_cum_qty_update_date :=
                  v_tmp_cum_record.last_cum_qty_update_date;
             x_old_cum_records(v_old_cum_ctr).cust_uom_code :=
                  v_tmp_cum_record.cust_uom_code;
             x_old_cum_records(v_old_cum_ctr).cum_start_date :=
                   v_tmp_cum_record.cum_start_date;
             x_old_cum_records(v_old_cum_ctr).customer_item_id :=
                   v_tmp_cum_record.customer_item_id;
           --
           END IF;
         --
         END IF; --}
       --
       END; --}
       --
     END LOOP; --}
     --
     CLOSE c_cum_keys;
     --
     /* If the last new_cum did not have any old_cum then delete it from the
        table */

     IF Not (x_counter.EXISTS(v_cum_rec_ctr)) THEN
     --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG,'could not find old cums for cum key id: ',
           x_cum_records(v_cum_rec_ctr).cum_key_id);
       END IF;
       --
       x_cum_records.DELETE(v_cum_rec_ctr);
       --
       v_cum_rec_ctr := v_cum_rec_ctr -1 ;
       --
     ELSE
     --
       IF x_counter(v_cum_rec_ctr) = 0 THEN
       --
         IF x_cum_records.EXISTS(v_cum_rec_ctr) THEN
         --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_SDEBUG,'could not find old cums for cum key id:',
                x_cum_records(v_cum_rec_ctr).cum_key_id);
            END IF;
            --
            x_cum_records.DELETE(v_cum_rec_ctr);
         --
         END IF;
         --
         x_counter.DELETE(v_cum_rec_ctr);
         --
         v_cum_rec_ctr := v_cum_rec_ctr -1 ;
       --
       END IF;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'v_cum_rec_ctr',v_cum_rec_ctr);
       END IF;
       --
     END IF;
     --
     /* if there are no cum found then return 0 */
     IF (v_cum_rec_ctr = 0 ) THEN
        x_return_status := 0;
	--
  	IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_DEBUG,
                'GetCums:Cum key record could not be retrieved');
        END IF;
       --
     ELSE
       x_return_status := 1;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_DEBUG,
                'GetCums:Cum key record is retrieved successfully');
       END IF;
       --
     END IF;
   --
 EXCEPTION
      --
      WHEN E_UNEXPECTED THEN
          --
          x_return_status := 0;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'msg_data',msg_data);
             rlm_core_sv.dpop(C_DEBUG,'GetCums E_UNEXPECTED');
          END IF;
          --
      WHEN NO_DATA_FOUND THEN
          --
          x_return_status := 0;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'msg_data',msg_data);
             rlm_core_sv.dpop(C_DEBUG,'GetCums NO_DATA_FOUND');
          END IF;
          --
      WHEN OTHERS THEN
          --
          -- RLM_CUM_SQLERR
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dpop(C_DEBUG,'GetCums' ||  substr(SQLERRM,1,100));
          END IF;
          --
          RAISE;
 END GetCums; --}

/*============================================================================

  PROCEDURE NAME:       SetSupplierCum

    This procedure calls the CalculateSupplierCum for all the shipments
    for the given Cum Key.  It populates oe global tables and it calculates
    the cum qty

  PARAMETERS:

     ** x_index                   IN              NUMBER
        This is the index for table x_cum_records
     ** x_cum_key_record          IN              cum_key_attrib_rec_type
        contains information about address ids
     ** x_transaction_start_date  IN              DATE
     ** x_cum_records             IN OUT NOCOPY          RLM_CUM_SV.t_cums
        Using the x_index we get the new cum record which needs to be rest
     ** x_return_status           OUT NOCOPY          BOOLEAN
        This will return FALSE if unexpected error happens
     ** x_counter                 IN OUT NOCOPY          NUMBER
        Shows the number of order lines modified

=============================================================================*/

 PROCEDURE SetSupplierCum (
        x_index                   IN              NUMBER,
        x_cum_key_record          IN              cum_key_attrib_rec_type,
        x_transaction_start_date  IN              DATE,
        x_cum_records             IN OUT NOCOPY          RLM_CUM_SV.t_cums,
        x_return_status           OUT NOCOPY             BOOLEAN,
        x_counter                 IN OUT NOCOPY          NUMBER,
        x_adjustment_date         IN OUT NOCOPY          DATE )
 IS
        v_new_ship_count          t_new_ship_count;
        tmp_shipment_date         DATE   DEFAULT TO_DATE('01/01/1500', 'DD/MM/YYYY');
        adj_qty                   NUMBER DEFAULT 0;
        v_header_id               NUMBER;
        v_line_id                 NUMBER;
        v_index                   NUMBER;

        e_Unexpected              EXCEPTION;

 BEGIN

    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'SetSupplierCum');
    END IF;
    --
    v_new_ship_count(x_cum_records(x_index).cum_key_id) := 0;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'cum_key_id', x_cum_records(x_index).cum_key_id);
    END IF;
    --
    x_return_status := FALSE;
    --
    IF x_cum_records(x_index).record_return_status = FALSE THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'CalculateSupplierCum returned false.');
        END IF;
        --
        RAISE e_Unexpected;
        --
    END IF;
    --
    IF g_cum_oe_lines.COUNT > 0 THEN  --{
      v_index := g_cum_oe_lines.FIRST;
      --
      LOOP --{
      --
        v_header_id := g_cum_oe_lines(v_index).header_id;
        v_line_id :=   g_cum_oe_lines(v_index).line_id;
        x_cum_records(x_index).shipped_quantity :=
                       g_cum_oe_lines(v_index).shipped_quantity;
        x_cum_records(x_index).actual_shipment_date :=
                       g_cum_oe_lines(v_index).actual_shipment_date;
        x_cum_records(x_index).cust_uom_code :=
                       g_cum_oe_lines(v_index).order_quantity_uom;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'shipment_date',
                        x_cum_records(x_index).actual_shipment_date);
        END IF;
	--
        IF x_cum_records(x_index).actual_shipment_date
          = tmp_shipment_date
        THEN
            v_new_ship_count(x_cum_records(x_index).cum_key_id) :=
                v_new_ship_count(x_cum_records(x_index).cum_key_id) + 1;
        ELSE
            v_new_ship_count(x_cum_records(x_index).cum_key_id) := 1;
            tmp_shipment_date :=
                         x_cum_records(x_index).actual_shipment_date;
        END IF;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'shipped_quantity',
                                  x_cum_records(x_index).shipped_quantity);
        END IF;
        --
        RLM_TPA_SV.CalculateSupplierCum(
              x_new_ship_count => v_new_ship_count,
              x_cum_key_record => x_cum_key_record,
              x_cum_record     => x_cum_records(x_index));
        --

        IF x_cum_records(x_index).record_return_status = FALSE THEN
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'CalculateSupplierCum returned false.');
            END IF;
            --
            RAISE e_Unexpected;
            --
        END IF;
        --
        IF x_adjustment_date IS NULL THEN
        --
          SELECT  SUM(transaction_qty)
          INTO    adj_qty
          FROM    rlm_cust_item_cum_adj
          WHERE   cum_key_id = x_cum_records(x_index).cum_key_id
          AND     transaction_date_time <
                     x_cum_records(x_index).actual_shipment_date;
        --
        ELSE
        --
          SELECT  SUM(transaction_qty)
          INTO    adj_qty
          FROM    rlm_cust_item_cum_adj
          WHERE   cum_key_id = x_cum_records(x_index).cum_key_id
          AND     transaction_date_time >= x_adjustment_date
          AND     transaction_date_time <
                     x_cum_records(x_index).actual_shipment_date;

        --
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'x_adjustment_date',x_adjustment_date);
        END IF;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'actual_shipment_date',
                     x_cum_records(x_index).actual_shipment_date);
        END IF;
	--
        IF adj_qty IS NULL THEN
        --
          adj_qty := 0;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'No adjustment found.');
          END IF;
        --
        END IF;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'adj_qty',adj_qty);
        END IF;
        --
        x_adjustment_date := x_cum_records(x_index).actual_shipment_date;
        --
        x_cum_records(x_index).cum_qty :=
                           x_cum_records(x_index).cum_qty + adj_qty;
	--
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'cum qty',
                                    x_cum_records(x_index).cum_qty);
        END IF;
	--
        --g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
        --
        g_oe_tmp_line_tbl(x_counter) := OE_Order_PUB.G_MISS_LINE_REC;
        --
        g_oe_tmp_line_tbl(x_counter).header_id      := v_header_id;
        --
        g_oe_tmp_line_tbl(x_counter).line_id        := v_line_id;
        --
        g_oe_tmp_line_tbl(x_counter).operation      := oe_globals.G_OPR_UPDATE;
        --
        g_oe_tmp_line_tbl(x_counter).veh_cus_item_cum_key_id  :=
                                           x_cum_records(x_index).cum_key_id;
        g_oe_tmp_line_tbl(x_counter).industry_attribute7      :=
                                                x_cum_records(x_index).cum_qty;
        g_oe_tmp_line_tbl(x_counter).industry_attribute8      :=
                                          x_cum_records(x_index).cust_uom_code;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'x_counter', x_counter);
           rlm_core_sv.dlog(C_DEBUG, 'g_oe_tmp_line_tbl(x_counter).header_id',
                                        g_oe_tmp_line_tbl(x_counter).header_id);
           rlm_core_sv.dlog(C_DEBUG, 'g_oe_tmp_line_tbl(x_counter).line_id',
                                          g_oe_tmp_line_tbl(x_counter).line_id);
           rlm_core_sv.dlog(C_DEBUG,
                         'g_oe_tmp_line_tbl(x_counter).veh_cus_item_cum_key_id',
                          g_oe_tmp_line_tbl(x_counter).veh_cus_item_cum_key_id);
           rlm_core_sv.dlog(C_DEBUG,'g_oe_tmp_line_tbl(counter).industry_attribute7',
                             g_oe_tmp_line_tbl(x_counter).industry_attribute7);
           rlm_core_sv.dlog(C_DEBUG,'g_oe_tmp_line_tbl(counter).industry_attribute8',
                              g_oe_tmp_line_tbl(x_counter).industry_attribute8);
        END IF;
        --
        x_counter := x_counter + 1;
        --
        EXIT WHEN v_index = g_cum_oe_lines.LAST;
        --
        v_index := g_cum_oe_lines.NEXT(v_index);
        --
      END LOOP; --}
    --
    END IF; --}
    --
    x_return_status := TRUE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_DEBUG,'SetSupplierCum');
    END IF;
    --
 EXCEPTION
 --
    WHEN e_Unexpected THEN
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'SetSupplierCum: e_unexpected');
      END IF;
      --
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'SetSupplierCum' ||  substr(SQLERRM,1,200));
      END IF;
      --
      RAISE;

 END SetSupplierCum;


/*===========================================================================

PROCEDURE NAME:    QuickSort

===========================================================================*/

PROCEDURE QuickSort(first    IN NUMBER,
                    last     IN NUMBER,
                    sortType IN NUMBER)
IS

  Low           NUMBER;
  High          NUMBER;
  Pivot_d       DATE;
  Pivot_n       NUMBER;
  v_Progress    VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'QuickSort');
  END IF;
  --
  low := First;
  high := Last;

  /* Select an element from the middle. */
  IF sortType = RLM_CUM_SV.C_line_table_type THEN
    pivot_n :=  g_oe_tmp_line_tbl(TRUNC((First + Last) / 2)).header_id;
    LOOP
      /* Find lowest element that is >= Pivot */
      WHILE g_oe_tmp_line_tbl(Low).header_id < Pivot_n LOOP
        Low := Low + 1;
      END LOOP;
      /* Find highest element that is <= Pivot */
      WHILE g_oe_tmp_line_tbl(High).header_id > Pivot_n LOOP
        High := High - 1;
      END LOOP;
      /*  swap the elements */
      IF Low <= High THEN
        Swap(High, Low,sortType);
        Low := Low + 1;
        High := High - 1;
      End IF;
      EXIT WHEN Low > High;
    END LOOP ;
  ELSE
    pivot_d :=  g_cum_oe_lines(TRUNC((First + Last) / 2)).actual_shipment_date;
    LOOP
      /* Find lowest element that is >= Pivot */
      WHILE g_cum_oe_lines(Low).actual_shipment_date < Pivot_d LOOP
        Low := Low + 1;
      END LOOP;
      /* Find highest element that is <= Pivot */
      WHILE g_cum_oe_lines(High).actual_shipment_date > Pivot_d LOOP
        High := High - 1;
      END LOOP;
      /*  swap the elements */
      IF Low <= High THEN
        Swap(High, Low,sortType);
        Low := Low + 1;
        High := High - 1;
      End IF;
      EXIT WHEN Low > High;
    END LOOP ;
  END IF;
  --
  IF (First < High) THEN
      Quicksort(First, High,sortType);
  END IF;
  IF (Low < Last) THEN
     Quicksort(Low, Last,sortType);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_DEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_cum_sv.QuickSort', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END QuickSort;

/*===========================================================================

PROCEDURE NAME:    Swap

===========================================================================*/
PROCEDURE Swap( i        IN NUMBER,
                j        IN NUMBER,
                sortType IN NUMBER)
IS

  T             oe_order_pub.Line_Rec_Type ;
  T2            rlm_cum_sv.cum_oe_lines_type;
  v_Progress    VARCHAR2(3) := '010';

BEGIN

--  rlm_core_sv.dpush(C_SDEBUG,'Swap');

  IF sortType = rlm_cum_sv.C_line_table_type THEN
    T := g_oe_tmp_line_tbl(i);
    g_oe_tmp_line_tbl(i) := g_oe_tmp_line_tbl(j);
    g_oe_tmp_line_tbl(j) := T;
  ELSE
    T2 := g_cum_oe_lines(i);
    g_cum_oe_lines(i) := g_cum_oe_lines(j);
    g_cum_oe_lines(j) := T2;
  END IF;

--  rlm_core_sv.dpop(C_SDEBUG);

EXCEPTION

  WHEN OTHERS THEN
    --rlm_message_sv.sql_error('rlm_cum_sv.Swap', v_Progress);
    --rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
    --rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    raise;

END Swap;

 PROCEDURE GetShippLines (
        x_cum_key_id              IN              NUMBER,
        x_ship_from_org_id        IN              NUMBER,
        x_ship_to_org_id          IN              NUMBER,
        x_intmed_ship_to_org_id   IN              NUMBER,
        x_bill_to_org_id          IN              NUMBER,
        x_customer_item_id        IN              NUMBER,
        x_inventory_item_id       IN              NUMBER,
        x_transaction_start_date  IN              DATE,
        x_transaction_end_date    IN              DATE,
        x_index                   IN  OUT NOCOPY         NUMBER )
 IS
        CURSOR c_oe_lines IS
             SELECT  header_id,
                     line_id,
                     shipped_quantity,
                     actual_shipment_date,
                     order_quantity_uom,
                     org_id
             FROM    oe_order_lines_all
             WHERE   (ship_from_org_id               = x_ship_from_org_id
                     OR x_ship_from_org_id           IS NULL)
             AND     (ship_to_org_id                 = x_ship_to_org_id
                     OR x_ship_to_org_id             IS NULL)
             AND     (intmed_ship_to_org_id          = x_intmed_ship_to_org_id
                     OR x_intmed_ship_to_org_id      IS NULL)
             AND     (invoice_to_org_id              = x_bill_to_org_id
                     OR x_bill_to_org_id             IS NULL)
             AND     (ordered_item_id                = x_customer_item_id
                     OR x_customer_item_id           IS NULL)
             AND     (actual_shipment_date           >= x_transaction_start_date
                     OR x_transaction_start_date     IS NULL)
             AND     (actual_shipment_date           <= NVL(x_transaction_end_date, SYSDATE))
             AND     shipped_quantity                IS NOT NULL
             AND     open_flag                       = 'N'
             AND     source_document_type_id         = 5
             AND     veh_cus_item_cum_key_id         = x_cum_key_id
             AND     inventory_item_id               = x_inventory_item_id
             ORDER BY actual_shipment_date;


 BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'GetShippLines');
       rlm_core_sv.dlog(C_DEBUG,'cum_key_id',x_cum_key_id);
       rlm_core_sv.dlog(C_DEBUG,'x_ship_from_org_id',x_ship_from_org_id);
       rlm_core_sv.dlog(C_DEBUG,'x_ship_to_org_id',x_ship_to_org_id);
       rlm_core_sv.dlog(C_DEBUG,'x_intmed_ship_to_org_id',x_intmed_ship_to_org_id);
       rlm_core_sv.dlog(C_DEBUG,'x_bill_to_org_id',x_bill_to_org_id);
       rlm_core_sv.dlog(C_DEBUG,'x_customer_item_id',x_customer_item_id);
       rlm_core_sv.dlog(C_DEBUG,'x_inventory_item_id',x_inventory_item_id);
       rlm_core_sv.dlog(C_DEBUG,'x_transaction_start_date',x_transaction_start_date);
       rlm_core_sv.dlog(C_DEBUG,'x_transaction_end_date',x_transaction_end_date);
       rlm_core_sv.dlog(C_DEBUG,'x_index',x_index);
    END IF;
    --
    OPEN c_oe_lines ;
    --
    LOOP --{
    --
      FETCH c_oe_lines INTO
           g_cum_oe_lines(x_index).header_id,
           g_cum_oe_lines(x_index).line_id,
           g_cum_oe_lines(x_index).shipped_quantity,
           g_cum_oe_lines(x_index).actual_shipment_date,
           g_cum_oe_lines(x_index).order_quantity_uom,
           g_cum_oe_lines(x_index).org_id;
      --
      EXIT WHEN c_oe_lines%NOTFOUND;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'shipped_quantity',
                                g_cum_oe_lines(x_index).shipped_quantity);
      END IF;
      --
      x_index := x_index + 1;
      --
    END LOOP; --}
    --
    CLOSE c_oe_Lines;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_DEBUG,'GetShippLines');
    END IF;
    --
 EXCEPTION
    --
    WHEN OTHERS THEN
        --
        IF c_oe_lines%ISOPEN THEN
        --
           CLOSE c_oe_lines;
        --
        END IF;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(C_DEBUG,'GetShippLines' ||  substr(SQLERRM,1,200));
        END IF;
        --
        RAISE;

 END GetShippLines;

/*=============================================================================
  PROCEDURE NAME: UpdateOldKey

  DESCRIPTION:    This procedure will be called to update CUM Key ID record(s) t
hat
                  are previously attached to order lines

  PARAMETERS:     x_old_cum_table               IN t_old_cum

 ============================================================================*/
 --{
 PROCEDURE UpdateOldKey(x_old_cum_records        IN OUT NOCOPY RLM_CUM_SV.t_cums,
                         x_shipment_rule_code     IN VARCHAR2,
                         x_cutoff_time            IN DATE,
                         x_cum_key_record         IN OUT NOCOPY cum_key_attrib_rec_type,
                         x_ship_from_org_id       IN NUMBER,
                         x_ship_to_org_id         IN NUMBER,
                         x_intmed_ship_to_org_id  IN NUMBER,
                         x_bill_to_org_id         IN NUMBER,
                         x_customer_item_id       IN NUMBER,
                         x_return_status          OUT NOCOPY BOOLEAN)
 IS
        v_index                 NUMBER;
        v_adjustment_date       DATE;
        counter                 NUMBER DEFAULT 1;
        cum_records_counter     NUMBER;
        adj_qty                 NUMBER DEFAULT 0;
        v_return_status         BOOLEAN;
        v_line_idx              NUMBER;
        v_tmp_line_idx          NUMBER;
        v_header_id             NUMBER;
        l_file_val              VARCHAR2(80);
        v_om_dbg_dir            VARCHAR2(80);
        x_oe_api_version        NUMBER                  DEFAULT 1;
        l_return_status         VARCHAR2(1);
        v_msg_count             NUMBER;
        v_msg_data              VARCHAR2(2000);
        e_noshipment            EXCEPTION;
        e_SetSupplierCum        EXCEPTION;
        --
	l_oe_line_tbl_out	oe_order_pub.line_tbl_type;
	--
 BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_DEBUG, 'UpdateOldKey');
  END IF;
  --
  g_oe_tmp_line_tbl.DELETE;
  g_oe_tmp_line_tbl := oe_order_pub.g_miss_line_tbl;
  g_oe_line_tbl.DELETE;
  g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
  --
  x_return_status := TRUE;
  --
  FOR cum_records_counter in 1..x_old_cum_records.COUNT LOOP
    --return if the table is empty
    IF x_old_cum_records(cum_records_counter).cum_key_id IS NOT NULL THEN --{
    --
      g_cum_oe_lines.DELETE;
      v_index := 1;
      v_adjustment_date := NULL;
      v_return_status := TRUE;
      --

      --for each old cum record x_cum_key_record needs to be updated with correct inventory_item_id

      x_cum_key_record.inventory_item_id := x_old_cum_records(cum_records_counter).inventory_item_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'inventory_item_id', x_cum_key_record.inventory_item_id);
      END IF;
      --
      rlm_cum_sv.GetShippLines(
                 x_cum_key_id             => x_old_cum_records(cum_records_counter).cum_key_id,
                 x_ship_from_org_id       => x_ship_from_org_id,
                 x_ship_to_org_id         => x_ship_to_org_id,
                 x_intmed_ship_to_org_id  => x_intmed_ship_to_org_id,
                 x_bill_to_org_id         => x_bill_to_org_id,
                 x_customer_item_id       => x_customer_item_id,
                 x_inventory_item_id      => x_cum_key_record.inventory_item_id,
                 x_transaction_start_date => NULL,
                 x_transaction_end_date   => SYSDATE,
                 x_index                  => v_index);
      --
      IF g_cum_oe_lines.COUNT > 0 THEN
      --
          rlm_cum_sv.quicksort(g_cum_oe_lines.FIRST,
                               g_cum_oe_lines.LAST,
                               C_cum_oe_lines);
      --
      END IF;
      --
      x_old_cum_records(cum_records_counter).record_return_status := TRUE;
      x_old_cum_records(cum_records_counter).cum_qty := 0;
      --
      x_old_cum_records(cum_records_counter).cum_qty_to_be_accumulated := 0;
      --
      x_old_cum_records(cum_records_counter).cum_qty_after_cutoff := 0;
      --
      x_old_cum_records(cum_records_counter).use_ship_incl_rule_flag := 'Y';
      --
      x_old_cum_records(cum_records_counter).as_of_date_time := NULL;

      -- Need to set called_by_reset_cum to 'Y'
      x_cum_key_record.called_by_reset_cum := 'Y';
      --

      rlm_cum_sv.SetSupplierCum(
                 x_index                  => cum_records_counter,
                 x_cum_key_record         => x_cum_key_record,
                 x_transaction_start_date => NULL,
                 x_cum_records            => x_old_cum_records,
                 x_return_status          => v_return_status,
                 x_counter                => counter,
                 x_adjustment_date        => v_adjustment_date);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_return_status',v_return_status);
      END IF;
      --
      IF v_return_status = FALSE THEN
      --
        x_return_status := FALSE;
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'SetSupplierCum failed');
        END IF;
	--
        fnd_file.put_line(fnd_file.log,'Failed to update Old CUMs, rolling back');
        RAISE e_SetSupplierCum;
      --
      ELSE --{
      --
      -- get all adjustments after the last shipment
        SELECT  SUM(transaction_qty)
        INTO    adj_qty
        FROM    rlm_cust_item_cum_adj
        WHERE   cum_key_id = x_old_cum_records(cum_records_counter).cum_key_id
        AND     transaction_date_time <= sysdate
        AND     ((transaction_date_time >= v_adjustment_date)
             OR (v_adjustment_date IS NULL));
	--
	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_adjustment_date',
                                              v_adjustment_date);
           rlm_core_sv.dlog(C_DEBUG, 'adj_qty',adj_qty);
        END IF;
        --
        x_old_cum_records(cum_records_counter).cum_qty :=
                           x_old_cum_records(cum_records_counter).cum_qty +
                           nvl(adj_qty,0);
        --
        UPDATE rlm_cust_item_cum_keys
        SET cum_qty           = x_old_cum_records(cum_records_counter).cum_qty,
            cum_qty_to_be_accumulated =
               x_old_cum_records(cum_records_counter).cum_qty_to_be_accumulated,
            cum_qty_after_cutoff =
               x_old_cum_records(cum_records_counter).cum_qty_after_cutoff,
            last_cum_qty_update_date  = SYSDATE,
            last_update_login         = FND_GLOBAL.LOGIN_ID,
            last_update_date          = SYSDATE,
            last_updated_by           = FND_GLOBAL.USER_ID
            WHERE  cum_key_id=x_old_cum_records(cum_records_counter).cum_key_id
            AND NVL(inactive_flag,'N')          =  'N';
            --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'x_old_cum_records.cum_key_id',
                             x_old_cum_records(cum_records_counter).cum_key_id);
           rlm_core_sv.dlog(C_DEBUG,'x_old_cum_records.cum_qty',
                           x_old_cum_records(cum_records_counter).cum_qty);
        END IF;
        --

      END IF; --}
    END IF; --}
  --
  END LOOP;
  --

   --  group the g_oe_tmp_line_tbl by header_id
   IF g_oe_tmp_line_tbl.COUNT = 0 THEN
   --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'There are no order lines to process in ' ||
       'update old cum');
      END IF;
      --
      RAISE e_NoShipment;
   --
   END IF;
   --
   rlm_cum_sv.quicksort(g_oe_tmp_line_tbl.FIRST,
                        g_oe_tmp_line_tbl.LAST,
                        RLM_CUM_SV.C_line_table_type);
   --
   v_tmp_line_idx := g_oe_tmp_line_tbl.FIRST;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_tmp_line_idx',v_tmp_line_idx);
   END IF;
   --
   v_line_idx := 1;
   --
   v_header_id := g_oe_tmp_line_tbl(v_tmp_line_idx).header_id;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_header_id',v_header_id);
   END IF;
   --
   g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
   --
   BEGIN --{
   --
   fnd_profile.get('ECE_OUT_FILE_PATH',v_om_dbg_dir);
   --
   fnd_profile.put('OE_DEBUG_LOG_DIRECTORY',v_om_dbg_dir);
   --
   l_file_val      := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'l_file_val',l_file_val);
   END IF;
   --
   LOOP --{
   /* Call OE_Order_GRP.Process_Order procedure to update OE_ORDER_LINES
      table by passing the g_oe_line_tbl structure that has been prepared
      this loop calls the process_order API once per each header_id,
      since the table is sorted by header_id then this loop
      calls the process_order once the header_id is changed  */
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'processing header_id',v_header_id);
      END IF;
      --
      IF g_oe_tmp_line_tbl(v_tmp_line_idx).header_id = v_header_id THEN --{
      --
         g_oe_line_tbl(v_line_idx) := g_oe_tmp_line_tbl(v_tmp_line_idx);
         --
         v_line_idx := v_line_idx + 1;
         --
         IF v_tmp_line_idx = g_oe_tmp_line_tbl.LAST THEN --{
            -- process order for the last time
            OE_Order_GRP.Process_order(
              p_api_version_number     => x_oe_api_version,
              p_init_msg_list          => FND_API.G_TRUE,
              p_return_values          => FND_API.G_FALSE,
              p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
              x_return_status          => l_return_status,
              x_msg_count              => v_msg_count,
              x_msg_data               => v_msg_data,
              ------------------------------------------
              p_line_tbl               => g_oe_line_tbl,
              ------------------------------------------
              x_header_rec             => g_oe_header_out_rec,
              x_header_val_rec         => g_oe_header_val_out_rec,
              x_Header_Adj_tbl         => g_oe_Header_Adj_out_tbl,
              x_Header_Adj_val_tbl     => g_oe_Header_Adj_val_out_tbl,
              x_Header_price_Att_tbl   => g_Header_price_Att_out_tbl,
              x_Header_Adj_Att_tbl     => g_Header_Adj_Att_out_tbl,
              x_Header_Adj_Assoc_tbl   => g_Header_Adj_Assoc_out_tbl,
              x_Header_Scredit_tbl     => g_oe_Header_Scredit_out_tbl,
              x_Header_Scredit_val_tbl => g_oe_Hdr_Scdt_val_out_tbl,
              x_line_tbl               => l_oe_line_tbl_out,
              x_line_val_tbl           => g_oe_line_val_out_tbl,
              x_Line_Adj_tbl           => g_oe_line_Adj_out_tbl,
              x_Line_Adj_val_tbl       => g_oe_line_Adj_val_out_tbl,
              x_Line_price_Att_tbl     => g_Line_price_Att_out_tbl,
              x_Line_Adj_Att_tbl       => g_Line_Adj_Att_out_tbl,
              x_Line_Adj_Assoc_tbl     => g_Line_Adj_Assoc_out_tbl,
              x_Line_Scredit_tbl       => g_oe_line_scredit_out_tbl,
              x_Line_Scredit_val_tbl   => g_oe_line_scredit_val_out_tbl,
              x_Lot_Serial_tbl         => g_oe_lot_serial_out_tbl,
              x_Lot_Serial_val_tbl     => g_oe_lot_serial_val_out_tbl,
              x_Action_Request_tbl     => g_oe_Action_Request_out_Tbl) ;
              --
  	      IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'G_FILE',OE_DEBUG_PUB.G_FILE);
               rlm_core_sv.dlog(C_DEBUG, 'Input tbl count', g_oe_line_tbl.LAST);
               rlm_core_sv.dlog(C_DEBUG, 'Output tbl count',
                                       l_oe_line_tbl_out.LAST);
              END IF;
              --
           -- Handle the exceptions caused by the OE call
              --

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN --{
                     --
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     --}
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN --{
                     --
                     RAISE FND_API.G_EXC_ERROR;
                     --}
             ELSE    --{
                     --
                     x_return_status := TRUE;
                     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,
                         'Order line is updated successfully');
                     END IF;
                     --
             END IF; --}
            EXIT;
         --}
         --{ if not the last element
         ELSE
         --
            v_tmp_line_idx := g_oe_tmp_line_tbl.NEXT(v_tmp_line_idx);
            --
         END IF; --}
      --}
      --{ if header_id has changed
      ELSE
         --
         v_header_id := g_oe_tmp_line_tbl(v_tmp_line_idx).header_id;
         --
         v_line_idx := 1;
         --

         OE_Order_GRP.Process_order(
              p_api_version_number     => x_oe_api_version,
              p_init_msg_list          => FND_API.G_TRUE,
              p_return_values          => FND_API.G_FALSE,
              p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
              x_return_status          => l_return_status,
              x_msg_count              => v_msg_count,
              x_msg_data               => v_msg_data,
              ------------------------------------------
              p_line_tbl               => g_oe_line_tbl,
              ------------------------------------------
              x_header_rec             => g_oe_header_out_rec,
              x_header_val_rec         => g_oe_header_val_out_rec,
              x_Header_Adj_tbl         => g_oe_Header_Adj_out_tbl,
              x_Header_Adj_val_tbl     => g_oe_Header_Adj_val_out_tbl,
              x_Header_price_Att_tbl   => g_Header_price_Att_out_tbl,
              x_Header_Adj_Att_tbl     => g_Header_Adj_Att_out_tbl,
              x_Header_Adj_Assoc_tbl   => g_Header_Adj_Assoc_out_tbl,
              x_Header_Scredit_tbl     => g_oe_Header_Scredit_out_tbl,
              x_Header_Scredit_val_tbl => g_oe_Hdr_Scdt_val_out_tbl,
              x_line_tbl               => l_oe_line_tbl_out,
              x_line_val_tbl           => g_oe_line_val_out_tbl,
              x_Line_Adj_tbl           => g_oe_line_Adj_out_tbl,
              x_Line_Adj_val_tbl       => g_oe_line_Adj_val_out_tbl,
              x_Line_price_Att_tbl     => g_Line_price_Att_out_tbl,
              x_Line_Adj_Att_tbl       => g_Line_Adj_Att_out_tbl,
              x_Line_Adj_Assoc_tbl     => g_Line_Adj_Assoc_out_tbl,
              x_Line_Scredit_tbl       => g_oe_line_scredit_out_tbl,
              x_Line_Scredit_val_tbl   => g_oe_line_scredit_val_out_tbl,
              x_Lot_Serial_tbl         => g_oe_lot_serial_out_tbl,
              x_Lot_Serial_val_tbl     => g_oe_lot_serial_val_out_tbl,
              x_Action_Request_tbl     => g_oe_Action_Request_out_Tbl) ;
              --
           -- Handle the exceptions caused by the OE call
              --
  	      IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'G_FILE',OE_DEBUG_PUB.G_FILE);
               rlm_core_sv.dlog(C_DEBUG, 'Input tbl count', g_oe_line_tbl.LAST);               rlm_core_sv.dlog(C_DEBUG, 'Output tbl count',
                                       l_oe_line_tbl_out.LAST);
              END IF;
              --
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN --{
                      --
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      --}
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN --{
                      --
                      RAISE FND_API.G_EXC_ERROR;
                      --}
              ELSE    --{
                      --
                      x_return_status := TRUE;
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_DEBUG,
                          'Order line is updated successfully');
                      END IF;
                      --
              END IF; --}
              --
              g_oe_line_tbl.DELETE;
              --
              g_oe_line_tbl := oe_order_pub.g_miss_line_tbl;
              --
              g_oe_line_tbl(v_line_idx) := g_oe_tmp_line_tbl(v_tmp_line_idx);
              --
           END IF; --} if the header_id has not changed
           --
     END LOOP; --}
  END ; --}
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_DEBUG);
  END IF;
  --
 EXCEPTION
   WHEN e_noshipment THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG, 'UpdateOldKey e_noshipment ');
     END IF;
     --
   WHEN e_SetSupplierCum THEN
     --
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG, 'UpdateOldKey e_SetSupplierCum');
     END IF;
     --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FALSE;
      --
      --Get message count and data
      --
	OE_MSG_PUB.Count_And_Get(
		p_count	=> v_msg_count,
		p_data  => v_msg_data);
	--
        rlm_message_sv.get_msg_text(
                x_message_name  => 'RLM_CUM_PROCESS_ORDER',
                x_text          => v_msg_data);
        --
	fnd_file.put_line(fnd_file.log, v_msg_data);
	--
     -- DEBUGGING
  	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_ERROR');
   	  rlm_core_sv.dlog(C_SDEBUG, 'l_return_status', l_return_status);
   	  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   	  rlm_core_sv.dlog(C_SDEBUG, 'v_msg_count', v_msg_count);
   	  rlm_core_sv.dlog(C_SDEBUG, 'Main v_msg_data', v_msg_data);
	END IF;
	--
	IF v_msg_count > 0 THEN
	  --
	  FOR k in 1 .. v_msg_count LOOP
		--
       		v_msg_data := oe_msg_pub.get( p_msg_index => k,
                      				      p_encoded   => 'F');
		--
		fnd_file.put_line(fnd_file.log, v_msg_data);
		--
  		IF (l_debug <> -1) THEN
   	          rlm_core_sv.dlog(C_SDEBUG, 'v_msg_data', v_msg_data);
	        END IF;
		--
          END LOOP;
	  --
	END IF;
	--
	--
     --
     -- User friendly message
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG, 'UpdateOldKey G_EXC_ERROR');
     END IF;
     --
   WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FALSE;
      --
      --Get message count and data
      --
	OE_MSG_PUB.Count_And_Get(
		p_count	=> v_msg_count,
		p_data  => v_msg_data);
	--
        rlm_message_sv.get_msg_text(
                x_message_name  => 'RLM_CUM_PROCESS_ORDER',
                x_text          => v_msg_data);
        --
	fnd_file.put_line(fnd_file.log, v_msg_data);
	--
     -- DEBUGGING
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_SDEBUG, 'G_EXC_UNEXPECTED_ERROR');
   	  rlm_core_sv.dlog(C_SDEBUG, 'l_return_status', l_return_status);
   	  rlm_core_sv.dlog(C_SDEBUG, 'x_return_status', x_return_status);
   	  rlm_core_sv.dlog(C_SDEBUG, 'v_msg_count', v_msg_count);
   	  rlm_core_sv.dlog(C_SDEBUG, 'Main v_msg_data', v_msg_data);
	END IF;
	--
	IF v_msg_count > 0 THEN
	  --
	  FOR k in 1 .. v_msg_count LOOP
		--
       		v_msg_data := oe_msg_pub.get( p_msg_index => k,
                      				      p_encoded   => 'F');
		--
		fnd_file.put_line(fnd_file.log, v_msg_data);
	        --
  		IF (l_debug <> -1) THEN
   	          rlm_core_sv.dlog(C_SDEBUG, 'v_msg_data', v_msg_data);
	        END IF;
		--
          END LOOP;
	  --
	END IF;
	--
     --
     -- User friendly message
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG, 'UpdateOldKey G_EXC_UNEXPECTED_ERROR');
     END IF;

   WHEN OTHERS THEN
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG, 'UpdateOldKey others: '|| substr(SQLERRM,1,200));
     END IF;
 --
 END UpdateOldKey;--}


FUNCTION GetInventoryItemId(x_customer_item_id IN NUMBER)
RETURN NUMBER
IS

v_inventory_item_id             NUMBER          :=      NULL;
Temp_Master_Organization_Id	Number		:=	NULL;
Temp_Inventory_Item_Id		Number		:=	NULL;
Temp_Inactive_Flag		Varchar2(1)	:=	NULL;

CURSOR	CI_XREF_Cur IS
SELECT	Master_Organization_Id, Inventory_Item_Id, Inactive_Flag
FROM	MTL_CUSTOMER_ITEM_XREFS
WHERE	Customer_Item_Id = x_customer_item_id
ORDER BY  Preference_Number ASC;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'GetInventoryItemId');
  END IF;
  --
  OPEN CI_XREF_Cur;
  FETCH CI_XREF_Cur INTO Temp_Master_Organization_Id,
		         Temp_Inventory_Item_Id,
		         Temp_Inactive_Flag;

  IF (CI_XREF_Cur%NOTFOUND) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_SDEBUG, 'Inventory Item Id could not be derived');
       rlm_core_sv.dpop(C_DEBUG, 'GetInventoryItemId');
    END IF;
    --
    return null;
    --
  ELSIF (Temp_Inactive_Flag = 'Y') THEN

    LOOP

      FETCH CI_XREF_Cur INTO Temp_Master_Organization_Id,
	  	             Temp_Inventory_Item_Id,
	                     Temp_Inactive_Flag;

      IF (CI_XREF_Cur%NOTFOUND) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_SDEBUG, 'Inventory Item Id could not be derived');
           rlm_core_sv.dpop(C_DEBUG, 'GetInventoryItemId');
        END IF;
	--
        return null;
	--
      ELSIF (Temp_Inactive_Flag = 'N') THEN
	--
        v_inventory_item_id:=Temp_Inventory_Item_Id;
	--
      END IF;
      --
      EXIT WHEN ((CI_XREF_Cur%NOTFOUND) OR (Temp_Inactive_Flag = 'N'));
      --
    END LOOP;

  ELSE

    v_inventory_item_id:=Temp_Inventory_Item_Id;

  END IF;

  CLOSE CI_XREF_Cur;

  --CURSOR

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'inventory_item_id', v_inventory_item_id);
     rlm_core_sv.dpop(C_DEBUG, 'GetInventoryItemId');
  END IF;
  --
  return v_inventory_item_id;
  --
EXCEPTION

when others then
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'Inventory Item Id could not be derived');
     rlm_core_sv.dpop(C_DEBUG, 'GetInventoryItemId');
  END IF;
  --
  return null;
  --
END;


/*===========================================================================

Procedure GetLatestCum
Parameters:       x_cum_key_record:  Has the information needed to retrive the
                                     cum key
                  x_rlm_setup_terms_record: It has the setup terms info
                  x_cum_record            : returns the latest cum record

============================================================================*/



 PROCEDURE GetLatestCum (
        x_cum_key_record IN     RLM_CUM_SV.cum_key_attrib_rec_type,
        x_rlm_setup_terms_record IN rlm_setup_terms_sv.setup_terms_rec_typ,
        x_cum_record     IN OUT NOCOPY RLM_CUM_SV.cum_rec_type,
        x_called_from_vd IN NUMBER)
 IS
	v_cum_org_level_code	 	rlm_cust_shipto_terms.cum_org_level_code%TYPE;
	p_ship_from_org_id		NUMBER DEFAULT NULL;
	p_ship_to_address_id		NUMBER DEFAULT NULL;
	p_intrmd_ship_to_address_id	NUMBER DEFAULT NULL;
	p_bill_to_address_id		NUMBER DEFAULT NULL;
	p_customer_item_id		NUMBER DEFAULT NULL;
	p_purchase_order_number 	RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE DEFAULT NULL;
	p_cust_record_year		RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE DEFAULT NULL;
	p_cum_start_date		DATE   DEFAULT NULL;
	E_UNEXPECTED    		EXCEPTION;


     /* The purpose of the following cursors is to get the cum key id,
        cum qty, cum start date, cust record year, po number, etc. that
        already exist in rlm_cust_item_cum_keys table. The cum record of
        interest is the one that got created last and which cum start date is
        no later than sysdate. */

     /* This cursor is used when the proc is called by  to get the latest cum
        and the cum control code is cum by date only and the cum organization
        level is not for all ship froms */

	--
	CURSOR	c_cum_by_date1 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
			cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
                WHERE   NVL(ship_from_org_id,0)	= NVL(p_ship_from_org_id,0)
      		AND    	NVL(ship_to_address_id,0) = NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0)=
                                              NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0)= NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)	= NVL(p_customer_item_id,0)
      		AND    	cum_start_date			IS NOT NULL
		AND    	(cum_start_date			< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )
		AND    	purchase_order_number 		IS NULL
		AND    	cust_record_year 		IS NULL
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--

     /* This cursor is used when the proc is called by to get the latest cum
        and the cum control code is cum by date only and the cum organization
        level is for all ship froms */
	--
	CURSOR 	c_cum_by_date2 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
	     		cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
      		WHERE  	ship_from_org_id		IS NULL
      		AND    	NVL(ship_to_address_id,0)= NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0) =
                                              NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0) = NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)= NVL(p_customer_item_id,0)
      		AND    	cum_start_date     		IS NOT NULL
		AND    	(cum_start_date			< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )
		AND    	purchase_order_number 		IS NULL
		AND    	cust_record_year 		IS NULL
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--

     /* This cursor is used when the proc is called by to get the latest cum
        and the cum control code is cum by date/record year and the cum
        organization level is not for all ship froms */
	--
	CURSOR 	c_cum_by_date_record_year1 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
	     		cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
      		WHERE  	NVL(ship_from_org_id,0)= NVL(p_ship_from_org_id,0)
      		AND    	NVL(ship_to_address_id,0)= NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0)
                                           = NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0)= NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)= NVL(p_customer_item_id,0)
      		AND    	cum_start_date     		IS NOT NULL
		AND    	(cum_start_date			< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )
		AND    	purchase_order_number 		IS NULL
		AND    	cust_record_year 		IS NOT NULL
                AND     (cust_record_year         = p_cust_record_year
                         OR p_cust_record_year IS NULL
                         )
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--

     /* This cursor is used when the proc is called by to get the latest cum
        and the cum control code is cum by date/record year and the cum
        organization level is for all ship froms */
	--
	CURSOR 	c_cum_by_date_record_year2 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
	     		cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
      		WHERE  	ship_from_org_id		IS NULL
      		AND    	NVL(ship_to_address_id,0) = NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0)
                                            = NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0) = NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)	= NVL(p_customer_item_id,0)
      		AND    	cum_start_date     		IS NOT NULL
		AND    	(cum_start_date 		< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )
		AND    	purchase_order_number 		IS NULL
		AND    	cust_record_year 		IS NOT NULL
                AND     (cust_record_year         = p_cust_record_year
                         OR p_cust_record_year IS NULL
                         )
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--

     /* This cursor is used when the proc is called by to get the latest cum
        and the cum control code is cum by date/po and the cum
        organization level is not for all ship froms */
	--
	CURSOR 	c_cum_by_date_po1 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
	     		cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
      		WHERE  	NVL(ship_from_org_id,0)= NVL(p_ship_from_org_id,0)
      		AND    	NVL(ship_to_address_id,0)= NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0)
                         	= NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0)= NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)	= NVL(p_customer_item_id,0)
      		AND    	cum_start_date     		IS NOT NULL
		AND    	(cum_start_date 		< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )
		AND    	purchase_order_number 		IS NOT NULL
                AND     (purchase_order_number = p_purchase_order_number
                         OR p_purchase_order_number IS NULL
                         )
		AND    	cust_record_year 		IS NULL
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--

     /* This cursor is used when the proc is called by to get the latest cum
        and the cum control code is cum by date/po and the cum organization
        level is for all ship froms */
	--
	CURSOR c_cum_by_date_po2 IS
		SELECT 	cum_key_id,
	 		cum_qty,
	     		cum_qty_to_be_accumulated,
	     		cum_qty_after_cutoff,
	     		last_cum_qty_update_date,
	     		cust_uom_code,
			cum_start_date,
			cust_record_year,
			purchase_order_number
      		FROM   	RLM_CUST_ITEM_CUM_KEYS
      		WHERE  	ship_from_org_id		IS NULL
      		AND    	NVL(ship_to_address_id,0) = NVL(p_ship_to_address_id,0)
      		AND    	NVL(intrmd_ship_to_id,0)
                                            = NVL(p_intrmd_ship_to_address_id,0)
      		AND    	NVL(bill_to_address_id,0) = NVL(p_bill_to_address_id,0)
      		AND    	NVL(customer_item_id,0)= NVL(p_customer_item_id,0)
      		AND    	cum_start_date     		IS NOT NULL
		AND    	(cum_start_date			< SYSDATE
                         OR x_called_from_vd     = rlm_cum_sv.k_CalledByVD
                         )

		AND    	purchase_order_number 		IS NOT NULL
                AND     (purchase_order_number = p_purchase_order_number
                         OR p_purchase_order_number IS NULL
                         )
		AND    	cust_record_year 		IS NULL
                AND     NVL(inactive_flag,'N')          =  'N'
		ORDER BY creation_date DESC;
	--
 BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'GetLatestCum');
      rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id',
                                   x_cum_key_record.ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id',
                                   x_cum_key_record.ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'bill_to_address_id',
                                   x_cum_key_record.bill_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'intrmd_ship_to_address_id',
                                   x_cum_key_record.intrmd_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'customer_item_id',
                                   x_cum_key_record.customer_item_id);
      rlm_core_sv.dlog(C_DEBUG, 'purchase_order_number',
                                   x_cum_key_record.purchase_order_number);
      rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_key_record.cum_start_date);
      rlm_core_sv.dlog(C_DEBUG, 'cust_record_year',
                                   x_cum_key_record.cust_record_year);
   END IF;
   --
   v_cum_org_level_code := x_rlm_setup_terms_record.cum_org_level_code;
   --
   p_customer_item_id := x_cum_key_record.customer_item_id;
   p_ship_from_org_id := x_cum_key_record.ship_from_org_id;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'cum_control_code',
                                 x_rlm_setup_terms_record.cum_control_code);
      rlm_core_sv.dlog(C_DEBUG, 'cum_org_level_code', v_cum_org_level_code);
   END IF;
   --
   x_cum_record.cum_key_id := NULL;
   --
   IF v_cum_org_level_code = 'BILL_TO_SHIP_FROM' THEN--{
	--
	IF x_cum_key_record.bill_to_address_id IS NULL THEN--{
	       --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Error:',
                                                    'RLM_CUM_BILL_TO_REQUIRED');
               END IF;
               --
               RAISE E_UNEXPECTED;
	       --
	END IF;--}
	--
	p_bill_to_address_id := x_cum_key_record.bill_to_address_id;
		--
   ELSIF v_cum_org_level_code = 'SHIP_TO_SHIP_FROM' THEN--}{
	--
	IF x_cum_key_record.ship_to_address_id IS NULL THEN--{
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Error:', 'RLM_CUM_SHIP_TO_REQUIRED');
               END IF;
               --
               RAISE E_UNEXPECTED;
	       --
	END IF;--}
	--
        p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
	--
   ELSIF v_cum_org_level_code = 'INTRMD_SHIP_TO_SHIP_FROM' THEN--}{
		--
         IF x_cum_key_record.intrmd_ship_to_address_id IS NULL THEN--{
	       --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Error:',
                                          'RLM_CUM_INTER_SHIP_TO_REQUIRED');
               END IF;
	       --
               RAISE E_UNEXPECTED;
               --
	END IF;--}
	--
        p_intrmd_ship_to_address_id :=
                                  x_cum_key_record.intrmd_ship_to_address_id;
   ELSIF v_cum_org_level_code = 'SHIP_TO_ALL_SHIP_FROMS' THEN		--}{
		p_ship_to_address_id := x_cum_key_record.ship_to_address_id;
   		p_ship_from_org_id := NULL;
		--
   ELSE--}{
	       --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Error:', 'RLM_CUM_UNKNOWN_ORG_LEVEL');
               END IF;
               --
               RAISE E_UNEXPECTED;
	       --
   END IF;--}
   --
   --Open the cursors previously defined and fetch only the first row of records
   --
   IF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_ONLY'
   OR x_rlm_setup_terms_record.cum_control_code = 'CUM_UNTIL_MANUAL_RESET' THEN--{
        --
        IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN--{
           --
           OPEN 	c_cum_by_date1;
           --
           FETCH 	c_cum_by_date1
           INTO	x_cum_record.cum_key_id,
	   	x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
           --
           CLOSE c_cum_by_date1;
         ELSE--}{
            --
            OPEN 	c_cum_by_date2;
            FETCH 	c_cum_by_date2
            INTO	x_cum_record.cum_key_id,
	   	x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
            --
            CLOSE c_cum_by_date2;
          END IF;--}
          --
   ELSIF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_RECORD_YEAR' THEN--}{
      --
      p_cust_record_year := x_cum_key_record.cust_record_year;
      --
      IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN--{
         --
         OPEN 	c_cum_by_date_record_year1;
         --
         FETCH 	c_cum_by_date_record_year1
         INTO	x_cum_record.cum_key_id,
		x_cum_record.cum_qty,
	        x_cum_record.cum_qty_to_be_accumulated,
	        x_cum_record.cum_qty_after_cutoff,
	        x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
         --
         CLOSE c_cum_by_date_record_year1;
      ELSE--}{
         --
         OPEN 	c_cum_by_date_record_year2;
            --
            FETCH 	c_cum_by_date_record_year2
            INTO	x_cum_record.cum_key_id,
	   	x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
         CLOSE c_cum_by_date_record_year2;
         --
      END IF;--}
      --
   ELSIF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_DATE_PO' THEN--}{
      --
      p_purchase_order_number := x_cum_key_record.purchase_order_number;
      --
      IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN--{
         --
         OPEN 	c_cum_by_date_po1;
         --
         FETCH 	c_cum_by_date_po1
         INTO	x_cum_record.cum_key_id,
		x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
         --
         CLOSE c_cum_by_date_po1;
         --
      ELSE--}{
         --
         OPEN 	c_cum_by_date_po2;
         --
         FETCH 	c_cum_by_date_po2
         INTO	x_cum_record.cum_key_id,
		x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code,
		p_cum_start_date,
		p_cust_record_year,
		p_purchase_order_number;
         --
         CLOSE c_cum_by_date_po2;
         --
      END IF;--}
      --
--Bug 4307505 uncommented the code
   ELSIF x_rlm_setup_terms_record.cum_control_code = 'CUM_BY_PO_ONLY' THEN--}{

    p_purchase_order_number := x_cum_key_record.purchase_order_number;

      IF v_cum_org_level_code <> 'SHIP_TO_ALL_SHIP_FROMS' THEN--{
         --
         SELECT	cum_key_id,
	    	cum_qty,
		cum_qty_to_be_accumulated,
		cum_qty_after_cutoff,
	     	last_cum_qty_update_date,
	     	cust_uom_code
         INTO  	x_cum_record.cum_key_id,
  		x_cum_record.cum_qty,
		x_cum_record.cum_qty_to_be_accumulated,
		x_cum_record.cum_qty_after_cutoff,
	   	x_cum_record.last_cum_qty_update_date,
	   	x_cum_record.cust_uom_code
         FROM 	RLM_CUST_ITEM_CUM_KEYS
         WHERE NVL(ship_from_org_id,0)	      = NVL(p_ship_from_org_id,0)
         AND    	NVL(ship_to_address_id,0)
                                            = NVL(p_ship_to_address_id,0)
         AND    	NVL(intrmd_ship_to_id,0)
                                      = NVL(p_intrmd_ship_to_address_id,0)
         AND    	NVL(bill_to_address_id,0)
                                             = NVL(p_bill_to_address_id,0)
         AND    	NVL(customer_item_id,0)
                                               = NVL(p_customer_item_id,0)
         AND    	purchase_order_number = NVL(p_purchase_order_number, ' ')
         AND    	NVL(cust_record_year, ' ')
                                            = NVL(p_cust_record_year, ' ')
         AND    	NVL(cum_start_date, sysdate)
                                          = NVL(p_cum_start_date, sysdate)
         AND            purchase_order_number IS NOT NULL
         AND     NVL(inactive_flag,'N')          =  'N'
         ORDER BY creation_date desc ;
         --
      ELSE--}{
         --
         SELECT	cum_key_id,
		cum_qty,
		cum_qty_to_be_accumulated,
		cum_qty_after_cutoff,
		last_cum_qty_update_date,
		cust_uom_code
         INTO	x_cum_record.cum_key_id,
		x_cum_record.cum_qty,
	     	x_cum_record.cum_qty_to_be_accumulated,
	     	x_cum_record.cum_qty_after_cutoff,
	     	x_cum_record.last_cum_qty_update_date,
	     	x_cum_record.cust_uom_code
         FROM   	RLM_CUST_ITEM_CUM_KEYS
         WHERE  	ship_from_org_id IS NULL
         AND    	NVL(ship_to_address_id, 0)
                                                 = NVL(p_ship_to_address_id,0)
         AND    	NVL(intrmd_ship_to_id, 0)
                                          = NVL(p_intrmd_ship_to_address_id,0)
         AND    	NVL(bill_to_address_id, 0)
                                                 = NVL(p_bill_to_address_id,0)
         AND    	NVL(customer_item_id, 0)
                                                   = NVL(p_customer_item_id,0)
         AND    	purchase_order_number = NVL(p_purchase_order_number, ' ')
         AND    	NVL(cust_record_year, ' ')
                                                = NVL(p_cust_record_year, ' ')
         AND    	NVL(cum_start_date, sysdate)
                                              = NVL(p_cum_start_date, sysdate)
         AND          NVL(inactive_flag,'N')          =  'N'
         AND       purchase_order_number IS NOT NULL
         ORDER BY creation_date desc ;
         --
      END IF;--}
      --

   END IF;--}
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'p_ship_from_org_id', p_ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_ship_to_address_id', p_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_intrmd_ship_to_address_id', p_intrmd_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_bill_to_address_id', p_bill_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_customer_item_id', p_customer_item_id);
      rlm_core_sv.dlog(C_DEBUG, 'p_purchase_order_number', p_purchase_order_number);
      rlm_core_sv.dlog(C_DEBUG, 'p_cust_record_year', p_cust_record_year);
      rlm_core_sv.dlog(C_DEBUG, 'p_cum_start_date', p_cum_start_date);
   END IF;
   --
   x_cum_record.cum_start_date := p_cum_start_date;
   --
   IF x_cum_record.cum_key_id IS NOT NULL THEN
      --
      x_cum_record.record_return_status := TRUE;
      --
      IF (x_called_from_vd = rlm_cum_sv.k_CalledByVD )
      AND NVL(x_cum_record.cum_start_date,SYSDATE) > SYSDATE
      THEN
        --
        x_cum_record.msg_name := 'RLM_CUM_START_FUTURE';
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'RLM_CUM_START_FUTURE');
        END IF;
        --
      END IF;
      --
   ELSE
      --
      x_cum_record.record_return_status := FALSE;
      --
      x_cum_record.msg_name := 'RLM_NO_ACTIVE_CUM_SP';
      --
      rlm_message_sv.get_msg_text(
             x_message_name  => x_cum_record.msg_name ,
             x_text          => x_cum_record.msg_data);

      --
   END IF;
   --
   IF x_cum_record.cum_qty IS NULL THEN
      x_cum_record.cum_qty := 0;
   END IF;

   IF x_cum_record.cum_qty_to_be_accumulated IS NULL THEN
      x_cum_record.cum_qty_to_be_accumulated := 0;
   END IF;

   IF x_cum_record.cum_qty_after_cutoff IS NULL THEN
      x_cum_record.cum_qty_after_cutoff := 0;
   END IF;

   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'cum_key_id', x_cum_record.cum_key_id);
      rlm_core_sv.dlog(C_DEBUG, 'cum_start_date', x_cum_record.cum_start_date);
      rlm_core_sv.dlog(C_DEBUG, 'cum_qty', x_cum_record.cum_qty);
      rlm_core_sv.dlog(C_DEBUG, 'record_return_status',
                             x_cum_record.record_return_status);
      rlm_core_sv.dpop(C_DEBUG,'GetLatestCum');
   END IF;
   --
   EXCEPTION
	--
        WHEN E_UNEXPECTED THEN
	    --
	    x_cum_record.record_return_status := FALSE;
	    --
            x_cum_record.msg_name := 'RLM_NO_ACTIVE_CUM_SP';
            --
            rlm_message_sv.get_msg_text(
                   x_message_name  => x_cum_record.msg_name ,
                   x_text          => x_cum_record.msg_data);

            --
  	    IF (l_debug <> -1) THEN
   	      rlm_core_sv.dpop(C_DEBUG,'E_UNEXPECTED');
	    END IF;
	    --
	WHEN OTHERS THEN
	    --
	    x_cum_record.record_return_status := FALSE;
            --
            x_cum_record.msg_name := 'RLM_NO_ACTIVE_CUM_SP';
            --
            rlm_message_sv.get_msg_text(
                   x_message_name  => x_cum_record.msg_name ,
                   x_text          => x_cum_record.msg_data);

            --
  	    IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG, 'when others');
   	      rlm_core_sv.dpop(C_DEBUG, substr(SQLERRM,1,200));
	    END IF;
	    --
   END GetLatestCum;


/*=========================================================================

PROCEDURE NAME:       LockCumKey

Parameter: x_CumKeyId  IN NUMBER

Created by: jckwok

Creation Date: June 15, 2004

History: Created due to Bug 3688778

===========================================================================*/

FUNCTION LockCumKey (x_CumKeyId  IN NUMBER)
RETURN BOOLEAN
IS
   --
   CURSOR c IS
     SELECT *
     FROM   RLM_CUST_ITEM_CUM_KEYS_ALL
     WHERE  cum_key_id = x_CumKeyId
     FOR UPDATE NOWAIT;
   --

BEGIN
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'LockCumKey');
     rlm_core_sv.dlog(C_DEBUG,'Locking RLM_CUST_ITEM_CUM_KEYS_ALL');
   END IF;
   --
   OPEN  c;
   CLOSE c;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
   RETURN(TRUE);
   --
EXCEPTION
   --
   WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Cum Key Record in RLM_CUST_ITEM_CUM_KEYS_ALL cannot be locked');
       rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RETURN(FALSE);
     --
   WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('Locking Cum Key Failed', 'rlm_cum_sv.LockCumKey');
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
     END IF;
     --
     RAISE;
     --
END LockCumKey;


END RLM_CUM_SV;

/
