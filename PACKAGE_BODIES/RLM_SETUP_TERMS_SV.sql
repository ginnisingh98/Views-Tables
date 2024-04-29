--------------------------------------------------------
--  DDL for Package Body RLM_SETUP_TERMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_SETUP_TERMS_SV" AS
/* $Header: RLMSETTB.pls 120.1.12010000.2 2009/05/13 13:12:22 sunilku ship $ */
/*======================== rlm_setup_terms_sv ==============================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--

/*============================================================================

  PROCEDURE NAME:        get_setup_terms

=============================================================================*/

PROCEDURE get_setup_terms (
                x_ship_from_org_id        IN NUMBER,
                x_customer_id             IN NUMBER,
                x_ship_to_address_id      IN NUMBER,
                x_customer_item_id        IN NUMBER,
                x_terms_definition_level  IN OUT NOCOPY VARCHAR2,
                x_terms_rec               OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message          OUT NOCOPY VARCHAR2,
                x_return_status           OUT NOCOPY BOOLEAN)
  IS
        -- Exception to indicate that mandatory parameters can not be blank
        -- regardless of terms_definition_level
        e_null_mandatory        EXCEPTION;

        -- Exception to indicate that ship_to_address_id can not be blank
        -- when terms_definition_level is ADDRESS
        e_null_address                EXCEPTION;

        -- Exception to indicate that customer_item_id can not be blank
        -- when terms_definition_level is CUSTOMER_ITEM_ID
        e_null_customer_item        EXCEPTION;

        -- Exception to indicate that the input terms_definition_level
        -- is invalid (other than CUSTOMER, ADDRESS, and CUSTOMER_ITEM)
        e_invalid_terms_level        EXCEPTION;

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG, 'get_setup_terms');
      rlm_core_sv.dlog(C_DEBUG, 'x_ship_from_org_id', x_ship_from_org_id);
      rlm_core_sv.dlog(C_DEBUG, 'x_customer_id', x_customer_id);
      rlm_core_sv.dlog(C_DEBUG, 'x_ship_to_address_id', x_ship_to_address_id);
      rlm_core_sv.dlog(C_DEBUG, 'x_customer_item_id', x_customer_item_id);
   END IF;
   --
    -- Mandatory parameters can not be null
    -- global_atp: ship_from_org_id can be null
    IF x_customer_id is NULL THEN
       --
       RAISE e_null_mandatory;
       --
    END IF;
    --
    IF (x_terms_definition_level is NULL) THEN
      --
      IF x_customer_item_id is NULL THEN
        --
        IF x_ship_to_address_id is NULL THEN
           --
           RLM_TPA_SV.populate_record_cust(x_ship_from_org_id,
                                x_customer_id,
                                x_terms_definition_level,
                                x_terms_rec,
                                x_return_message,
                                x_return_status);
           --
        ELSE  /*x_ship_to_address_id is NOT NULL*/
           --
           RLM_TPA_SV.populate_record_add(x_ship_from_org_id,
                               x_customer_id,
                               x_ship_to_address_id,
			       x_customer_item_id,
                               x_terms_definition_level,
                               x_terms_rec,
                               x_return_message,
                               x_return_status);
         END IF;
       ELSE /* x_customer_item_id is NOT NULL */
         --
         RLM_TPA_SV.populate_record_item(x_ship_from_org_id,
                              x_customer_id,
                              x_ship_to_address_id,
                              x_customer_item_id,
                              x_terms_definition_level,
                              x_terms_rec,
                              x_return_message,
                              x_return_status);
         --
       END IF;
      /* Terms definition level, if known, can be supplied by calling
         program explicitly at three levels */
    ELSIF x_terms_definition_level = 'CUSTOMER' THEN
       --
       RLM_TPA_SV.populate_record_cust(x_ship_from_org_id,
                            x_customer_id,
                            x_terms_definition_level,
                            x_terms_rec,
                            x_return_message,
                            x_return_status);
    ELSIF x_terms_definition_level = 'ADDRESS' THEN
       --
       IF x_ship_to_address_id is NULL THEN
          --
          RAISE e_null_address;
          --
       END IF;
       --
       RLM_TPA_SV.populate_record_add(x_ship_from_org_id,
                           x_customer_id,
                           x_ship_to_address_id,
			   x_customer_item_id,
                           x_terms_definition_level,
                           x_terms_rec,
                           x_return_message,
                           x_return_status);
       --
    ELSIF x_terms_definition_level = 'ADDRESS_ITEM' THEN
       --
       IF x_customer_item_id is NULL THEN
         --
         RAISE e_null_customer_item;
         --
       END IF;
       --
       IF x_ship_to_address_id is NULL THEN
         --
         RAISE e_null_address;
         --
       END IF;
       --
       RLM_TPA_SV.populate_record_item(x_ship_from_org_id,
                            x_customer_id,
                            x_ship_to_address_id,
                            x_customer_item_id,
                            x_terms_definition_level,
                            x_terms_rec,
                            x_return_message,
                            x_return_status);
       --
    ELSIF x_terms_definition_level = 'CUSTOMER_ITEM' THEN
       --
       IF x_customer_item_id is NULL THEN
         --
         RAISE e_null_customer_item;
         --
       END IF;
       --
       RLM_TPA_SV.populate_record_cust_item(x_ship_from_org_id,
                                 x_customer_id,
                                 x_ship_to_address_id,
                                 x_customer_item_id,
                                 x_terms_definition_level,
                                 x_terms_rec,
                                 x_return_message,
                                 x_return_status);
       --
    ELSE
       --
       RAISE e_invalid_terms_level;
       --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
EXCEPTION
  WHEN e_null_mandatory THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_NULL_MANDATORY';
    rlm_message_sv.get_msg_text(x_terms_rec.msg_name,
                                x_return_message);
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'Mandatory parameters can not be blank');
    END IF;
    --
  WHEN e_null_address THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_NULL_ADDRESS';
    rlm_message_sv.get_msg_text(x_message_name => x_terms_rec.msg_name,
                                x_text => x_return_message,
                                x_token1 => 'SHIP_FROM_ORG_ID',
                                x_value1 => x_ship_from_org_id,
                                x_token2 => 'CUSTOMER_ID',
                                x_value2 => x_customer_id);
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'Ship_to_address_id is required when terms definition level is ADDRESS');
    END IF;
    --
  WHEN e_null_customer_item THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_NULL_CUSTOMER_ITEM';
    rlm_message_sv.get_msg_text(
                      x_message_name => x_terms_rec.msg_name,
                      x_text => x_return_message);
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'Customer_item_id is required when terms definition level is CUSTOMER_ITEM');
    END IF;
    --
  WHEN e_invalid_terms_level THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_INVALID_TERMS_LEVEL';
    rlm_message_sv.get_msg_text(
                      x_message_name => x_terms_rec.msg_name,
                      x_text => x_return_message,
                      x_token1 => 'TERMS_DEFINITION_LEVEL',
                      x_value1 => x_terms_definition_level);
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'The terms_definition_level has to be one of the following: CUSTOMER, ADDRESS, CUSTOMER_ITEM');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'SQL Error', SQLERRM);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    raise;
    --
END get_setup_terms;

/*=============================================================================

  PROCEDURE NAME:        populate_record_cust

=============================================================================*/

PROCEDURE populate_record_cust (
                x_ship_from_org_id         IN NUMBER,
                x_customer_id              IN NUMBER,
                x_terms_definition_level   IN OUT NOCOPY VARCHAR2,
                x_terms_rec                OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message           IN OUT NOCOPY VARCHAR2,
                x_return_status            OUT NOCOPY BOOLEAN)
IS
   v_ship_from_org_id               NUMBER DEFAULT -1;
   e_inactive_record                EXCEPTION;
   e_no_default                     EXCEPTION;
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'populate_record_cust');
  END IF;
  --
  v_ship_from_org_id := x_ship_from_org_id;
  --
  -- Before selecting the terms, check if the ship_from_org_id is null */
  -- global_atp
  IF x_ship_from_org_id IS NULL THEN
    --
    BEGIN

      SELECT ship_from_org_id
      INTO   v_ship_from_org_id
      FROM   rlm_cust_shipto_terms
      WHERE  customer_id = x_customer_id
      AND    address_id IS NULL
      AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

      -- Proceed
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'v_ship_from_org_id', v_ship_from_org_id );
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        -- Get the default
        BEGIN
          SELECT ship_from_org_id
          INTO   v_ship_from_org_id
          FROM   rlm_cust_shipto_terms
          WHERE  customer_id = x_customer_id
          AND    address_id IS NULL
          AND    NVL(default_ship_from,'N') = 'Y'
          AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

          -- Proceed
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'Default v_ship_from_org_id', v_ship_from_org_id );
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_no_default;
        END;

      WHEN NO_DATA_FOUND THEN
        RAISE;

      WHEN e_no_default THEN
        RAISE;

      WHEN OTHERS THEN
        RAISE;

    END;
    --
  END IF;

  SELECT cust_shipto_terms_id,
         customer_id,
         cum_control_code,
         cum_org_level_code,
         cum_shipment_rule_code,
         cum_yesterd_time_cutoff,
         cust_assign_supplier_cd,
         customer_rcv_calendar_cd,
         supplier_shp_calendar_cd,
         unship_firm_cutoff_days,
         unshipped_firm_disp_cd,
         inactive_date,
         critical_attribute_key,
         schedule_hierarchy_code,
         comments,
         intransit_time,
         time_uom_code,
         ship_from_org_id,
         address_id,
         header_id,
	 agreement_id,
         agreement_name,
	 future_agreement_id,
         future_agreement_name,
         round_to_std_pack_flag,
         ship_delivery_rule_name,
         ship_method,
         std_pack_qty,
         price_list_id,
         use_edi_sdp_code_flag,
         match_across_key,
         match_within_key,
         pln_firm_day_to,
         pln_firm_day_from,
         pln_forecast_day_from,
         pln_forecast_day_to,
         pln_frozen_day_to,
         pln_frozen_day_from,
         seq_firm_day_from,
         seq_firm_day_to,
         seq_forecast_day_to,
         seq_forecast_day_from,
         seq_frozen_day_from,
         seq_frozen_day_to,
         shp_firm_day_from,
         shp_firm_day_to,
         shp_frozen_day_from,
         shp_frozen_day_to,
         shp_forecast_day_from,
         shp_forecast_day_to,
         pln_mrp_forecast_day_from,
         pln_mrp_forecast_day_to,
         shp_mrp_forecast_day_from,
         shp_mrp_forecast_day_to,
         seq_mrp_forecast_day_from,
         seq_mrp_forecast_day_to,
         demand_tolerance_above,
         demand_tolerance_below,
         customer_contact_id,
         freight_code,
         supplier_contact_id,
         attribute_category,
         tp_attribute_category,
         attribute1,
         attribute2,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         tp_attribute1,
         tp_attribute2,
         tp_attribute3,
         tp_attribute4,
         tp_attribute5,
         tp_attribute6,
         tp_attribute7,
         tp_attribute8,
         tp_attribute9,
         tp_attribute10,
         tp_attribute11,
         tp_attribute12,
         tp_attribute13,
         tp_attribute14,
         tp_attribute15,
         intransit_calc_basis,
         pln_frozen_flag,
         shp_frozen_flag,
         seq_frozen_flag,
         issue_warning_drop_parts_flag,
	 blanket_number,
  	 release_rule,
	 release_time_frame,
	 release_time_frame_uom,
         exclude_non_workdays_flag,
         disable_create_cum_key_flag
  INTO   x_terms_rec.cust_shipto_terms_id,
         x_terms_rec.customer_id,
         x_terms_rec.cum_control_code,
         x_terms_rec.cum_org_level_code,
         x_terms_rec.cum_shipment_rule_code,
         x_terms_rec.cum_yesterd_time_cutoff,
         x_terms_rec.cust_assign_supplier_cd,
         x_terms_rec.customer_rcv_calendar_cd,
         x_terms_rec.supplier_shp_calendar_cd,
         x_terms_rec.unship_firm_cutoff_days,
         x_terms_rec.unshipped_firm_disp_cd,
         x_terms_rec.inactive_date,
         x_terms_rec.critical_attribute_key,
         x_terms_rec.schedule_hierarchy_code,
         x_terms_rec.comments,
         x_terms_rec.intransit_time,
         x_terms_rec.time_uom_code,
         x_terms_rec.ship_from_org_id,
         x_terms_rec.address_id,
         x_terms_rec.header_id,
	 x_terms_rec.agreement_id,
         x_terms_rec.agreement_name,
	 x_terms_rec.future_agreement_id,
         x_terms_rec.future_agreement_name,
         x_terms_rec.round_to_std_pack_flag,
         x_terms_rec.ship_delivery_rule_name,
         x_terms_rec.ship_method,
         x_terms_rec.std_pack_qty,
         x_terms_rec.price_list_id,
         x_terms_rec.use_edi_sdp_code_flag,
         x_terms_rec.match_across_key,
         x_terms_rec.match_within_key,
         x_terms_rec.pln_firm_day_to,
         x_terms_rec.pln_firm_day_from,
         x_terms_rec.pln_forecast_day_from,
         x_terms_rec.pln_forecast_day_to,
         x_terms_rec.pln_frozen_day_to,
         x_terms_rec.pln_frozen_day_from,
         x_terms_rec.seq_firm_day_from,
         x_terms_rec.seq_firm_day_to,
         x_terms_rec.seq_forecast_day_to,
         x_terms_rec.seq_forecast_day_from,
         x_terms_rec.seq_frozen_day_from,
         x_terms_rec.seq_frozen_day_to,
         x_terms_rec.shp_firm_day_from,
         x_terms_rec.shp_firm_day_to,
         x_terms_rec.shp_frozen_day_from,
         x_terms_rec.shp_frozen_day_to,
         x_terms_rec.shp_forecast_day_from,
         x_terms_rec.shp_forecast_day_to,
         x_terms_rec.pln_mrp_forecast_day_from,
         x_terms_rec.pln_mrp_forecast_day_to,
         x_terms_rec.shp_mrp_forecast_day_from,
         x_terms_rec.shp_mrp_forecast_day_to,
         x_terms_rec.seq_mrp_forecast_day_from,
         x_terms_rec.seq_mrp_forecast_day_to,
         x_terms_rec.demand_tolerance_above,
         x_terms_rec.demand_tolerance_below,
         x_terms_rec.customer_contact_id,
         x_terms_rec.freight_code,
         x_terms_rec.supplier_contact_id,
         x_terms_rec.attribute_category,
         x_terms_rec.tp_attribute_category,
         x_terms_rec.attribute1,
         x_terms_rec.attribute2,
         x_terms_rec.attribute4,
         x_terms_rec.attribute5,
         x_terms_rec.attribute6,
         x_terms_rec.attribute7,
         x_terms_rec.attribute8,
         x_terms_rec.attribute9,
         x_terms_rec.attribute10,
         x_terms_rec.attribute11,
         x_terms_rec.attribute12,
         x_terms_rec.attribute13,
         x_terms_rec.attribute14,
         x_terms_rec.attribute15,
         x_terms_rec.tp_attribute1,
         x_terms_rec.tp_attribute2,
         x_terms_rec.tp_attribute3,
         x_terms_rec.tp_attribute4,
         x_terms_rec.tp_attribute5,
         x_terms_rec.tp_attribute6,
         x_terms_rec.tp_attribute7,
         x_terms_rec.tp_attribute8,
         x_terms_rec.tp_attribute9,
         x_terms_rec.tp_attribute10,
         x_terms_rec.tp_attribute11,
         x_terms_rec.tp_attribute12,
         x_terms_rec.tp_attribute13,
         x_terms_rec.tp_attribute14,
         x_terms_rec.tp_attribute15,
         x_terms_rec.intransit_calc_basis,
         x_terms_rec.pln_frozen_flag,
         x_terms_rec.shp_frozen_flag,
         x_terms_rec.seq_frozen_flag,
         x_terms_rec.issue_warning_drop_parts_flag,
	 x_terms_rec.blanket_number,
	 x_terms_rec.release_rule,
	 x_terms_rec.release_time_frame,
	 x_terms_rec.release_time_frame_uom,
         x_terms_rec.exclude_non_workdays_flag,
         x_terms_rec.disable_create_cum_key_flag
  FROM   RLM_CUST_SHIPTO_TERMS
  WHERE  SHIP_FROM_ORG_ID = v_ship_from_org_id
  AND    CUSTOMER_ID = x_customer_id
  AND    ADDRESS_ID is NULL;

  /* By default, inactive_date is NULL */
  --
  IF x_terms_rec.inactive_date is NOT NULL THEN
     --
     IF x_terms_rec.inactive_date <= sysdate THEN
       --
       raise e_inactive_record;
       --
     END IF;
     --
  END IF;
  --
  /* By default, match_within_key is ABCDEFG  */
  --
  IF x_terms_rec.match_within_key is NULL THEN
     --
     x_terms_rec.match_within_key := rlm_core_sv.get_default_key;
     --
  END IF;
  --
  /* By default, match_across_key is ABCDEFG  */
  --
  IF x_terms_rec.match_across_key is NULL THEN
     --
     x_terms_rec.match_across_key := rlm_core_sv.get_default_key;
     --
  END IF;
  --
  x_terms_rec.calc_cum_flag := 'Y';
  x_terms_definition_level := 'CUSTOMER';
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN TOO_MANY_ROWS THEN
     --
     x_terms_rec.msg_name := 'RLM_SETUP_CUST_MULTIPLE_ROWS';
     rlm_message_sv.get_msg_text(
                  x_message_name => x_terms_rec.msg_name,
                  x_text => x_return_message,
                  x_token1 => 'CUSTOMER',
                  x_value1 => rlm_core_sv.get_customer_name(x_Customer_id));
     --
     x_terms_definition_level := NULL;
     --
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Too Many Rows ');
        rlm_core_sv.dpop(C_SDEBUG, 'There are more than one record of RLM Setup Terms at the CUSTOMER level');
     END IF;
     --
  WHEN e_no_default THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_CUST_NO_DEFAULT';
    rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text         => x_return_message,
                    x_token1       => 'CUST',
                    x_value1       => RLM_CORE_SV.get_customer_name(x_customer_id));

    --
    x_terms_definition_level := NULL;
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'No Default');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;

  WHEN e_inactive_record THEN
     --
     x_terms_rec.msg_name := 'RLM_SETUP_CUST_INACTIVE_RECORD';
     --
     x_terms_definition_level := NULL;
     --
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG, 'The RLM Setup Terms record at the CUSTOMER level has been inactivated');
     END IF;
     --
  WHEN NO_DATA_FOUND THEN
     --
     x_terms_rec.msg_name := 'RLM_SETUP_NO_DATA_FOUND';
     rlm_message_sv.get_msg_text(
                  x_message_name => x_terms_rec.msg_name,
                  x_text => x_return_message,
                  x_token1 => 'SHIPFROM',
                  x_value1 => rlm_core_sv.get_ship_from(x_Ship_from_org_id),
                  x_token2 => 'CUSTOMER',
                  x_value2 => rlm_core_sv.get_customer_name(x_Customer_id));
     --
     x_terms_definition_level := NULL;
     --
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'No data found');
        rlm_core_sv.dpop(C_SDEBUG, 'No data found');
     END IF;
     --
  WHEN OTHERS THEN
     --
     x_return_status := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'SQL Error', SQLERRM);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     raise;
     --
END populate_record_cust;


/*=============================================================================

  PROCEDURE NAME:        populate_record_add

=============================================================================*/

PROCEDURE populate_record_add (
                x_ship_from_org_id        IN NUMBER,
                x_customer_id             IN NUMBER,
                x_ship_to_address_id      IN NUMBER,
		x_customer_item_id	  IN NUMBER,
                x_terms_definition_level  IN OUT NOCOPY VARCHAR2,
                x_terms_rec               OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message          IN OUT NOCOPY VARCHAR2,
                x_return_status           OUT NOCOPY BOOLEAN)
IS
 --
 v_ship_from_org_id             NUMBER DEFAULT -1;
 e_multiple_rows                EXCEPTION;
 e_inactive_record              EXCEPTION;
 e_no_default                   EXCEPTION;
 --
 -- 4129188
 --
 v_match_within_key             VARCHAR2(240);
 v_match_across_key             VARCHAR2(240);
 --
 CURSOR c_optional_match_cust(p_shipFromOrgId NUMBER,
                              p_CustomerId NUMBER) IS
 SELECT match_within_key, match_across_key
 FROM rlm_cust_shipto_terms
 WHERE ship_from_org_id = p_shipFromOrgId
 AND customer_id = p_CustomerId
 AND address_id IS NULL;
 --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'populate_record_add');
  END IF;

  v_ship_from_org_id := x_ship_from_org_id;

  -- Before selecting the terms, check if the ship_from_org_id is null */
  -- global_atp
  IF x_ship_from_org_id IS NULL THEN
    --
    BEGIN

      SELECT ship_from_org_id
      INTO   v_ship_from_org_id
      FROM   rlm_cust_shipto_terms
      WHERE  customer_id = x_customer_id
      AND    address_id = x_ship_to_address_id
      AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

      -- Proceed
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'v_ship_from_org_id', v_ship_from_org_id);
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        -- Get the default
        BEGIN
          SELECT ship_from_org_id
          INTO   v_ship_from_org_id
          FROM   rlm_cust_shipto_terms
          WHERE  customer_id = x_customer_id
          AND    address_id = x_ship_to_address_id
          AND    NVL(default_ship_from,'N') = 'Y'
          AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

          -- Proceed
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'Default v_ship_from_org_id', v_ship_from_org_id);
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_no_default;
        END;

      WHEN NO_DATA_FOUND THEN
        RAISE;

      WHEN e_no_default THEN
        RAISE;

      WHEN OTHERS THEN
        RAISE;

    END;
    --
  END IF;

  SELECT cust_shipto_terms_id,
          customer_id,
          cum_control_code,
          cum_org_level_code,
          cum_shipment_rule_code,
          cum_yesterd_time_cutoff,
          cust_assign_supplier_cd,
          customer_rcv_calendar_cd,
          supplier_shp_calendar_cd,
          unship_firm_cutoff_days,
          unshipped_firm_disp_cd,
          inactive_date,
          critical_attribute_key,
          schedule_hierarchy_code,
          comments,
          intransit_time,
          time_uom_code,
          ship_from_org_id,
          address_id,
          header_id,
	  agreement_id,
          agreement_name,
          future_agreement_id,
          future_agreement_name,
          round_to_std_pack_flag,
          ship_delivery_rule_name,
          ship_method,
          std_pack_qty,
          price_list_id,
          use_edi_sdp_code_flag,
          match_across_key,
          match_within_key,
          pln_firm_day_to,
          pln_firm_day_from,
          pln_forecast_day_from,
          pln_forecast_day_to,
          pln_frozen_day_to,
          pln_frozen_day_from,
          seq_firm_day_from,
          seq_firm_day_to,
          seq_forecast_day_to,
          seq_forecast_day_from,
          seq_frozen_day_from,
          seq_frozen_day_to,
          shp_firm_day_from,
          shp_firm_day_to,
          shp_frozen_day_from,
          shp_frozen_day_to,
          shp_forecast_day_from,
          shp_forecast_day_to,
          pln_mrp_forecast_day_from,
          pln_mrp_forecast_day_to,
          shp_mrp_forecast_day_from,
          shp_mrp_forecast_day_to,
          seq_mrp_forecast_day_from,
          seq_mrp_forecast_day_to,
          demand_tolerance_above,
          demand_tolerance_below,
          customer_contact_id,
          freight_code,
          supplier_contact_id,
          attribute_category,
          tp_attribute_category,
          attribute1,
          attribute2,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          tp_attribute1,
          tp_attribute2,
          tp_attribute3,
          tp_attribute4,
          tp_attribute5,
          tp_attribute6,
          tp_attribute7,
          tp_attribute8,
          tp_attribute9,
          tp_attribute10,
          tp_attribute11,
          tp_attribute12,
          tp_attribute13,
          tp_attribute14,
          tp_attribute15,
	  intransit_calc_basis,
          pln_frozen_flag,
          shp_frozen_flag,
          seq_frozen_flag,
          issue_warning_drop_parts_flag,
	  blanket_number,
  	  release_rule,
	  release_time_frame,
	  release_time_frame_uom,
          exclude_non_workdays_flag,
          disable_create_cum_key_flag
  INTO  x_terms_rec.cust_shipto_terms_id,
        x_terms_rec.customer_id,
        x_terms_rec.cum_control_code,
--        x_terms_rec.cum_current_record_year,
--        x_terms_rec.cum_previous_record_year,
        x_terms_rec.cum_org_level_code,
        x_terms_rec.cum_shipment_rule_code,
        x_terms_rec.cum_yesterd_time_cutoff,
        x_terms_rec.cust_assign_supplier_cd,
        x_terms_rec.customer_rcv_calendar_cd,
        x_terms_rec.supplier_shp_calendar_cd,
        x_terms_rec.unship_firm_cutoff_days,
        x_terms_rec.unshipped_firm_disp_cd,
        x_terms_rec.inactive_date,
        x_terms_rec.critical_attribute_key,
        x_terms_rec.schedule_hierarchy_code,
        x_terms_rec.comments,
        x_terms_rec.intransit_time,
        x_terms_rec.time_uom_code,
        x_terms_rec.ship_from_org_id,
        x_terms_rec.address_id,
        x_terms_rec.header_id,
	x_terms_rec.agreement_id,
        x_terms_rec.agreement_name,
        x_terms_rec.future_agreement_id,
        x_terms_rec.future_agreement_name,
--        x_terms_rec.cum_current_start_date,
--        x_terms_rec.cum_previous_start_date,
        x_terms_rec.round_to_std_pack_flag,
        x_terms_rec.ship_delivery_rule_name,
        x_terms_rec.ship_method,
        x_terms_rec.std_pack_qty,
        x_terms_rec.price_list_id,
        x_terms_rec.use_edi_sdp_code_flag,
        x_terms_rec.match_across_key,
        x_terms_rec.match_within_key,
        x_terms_rec.pln_firm_day_to,
        x_terms_rec.pln_firm_day_from,
        x_terms_rec.pln_forecast_day_from,
        x_terms_rec.pln_forecast_day_to,
        x_terms_rec.pln_frozen_day_to,
        x_terms_rec.pln_frozen_day_from,
        x_terms_rec.seq_firm_day_from,
        x_terms_rec.seq_firm_day_to,
        x_terms_rec.seq_forecast_day_to,
        x_terms_rec.seq_forecast_day_from,
        x_terms_rec.seq_frozen_day_from,
        x_terms_rec.seq_frozen_day_to,
        x_terms_rec.shp_firm_day_from,
        x_terms_rec.shp_firm_day_to,
        x_terms_rec.shp_frozen_day_from,
        x_terms_rec.shp_frozen_day_to,
        x_terms_rec.shp_forecast_day_from,
        x_terms_rec.shp_forecast_day_to,
        x_terms_rec.pln_mrp_forecast_day_from,
        x_terms_rec.pln_mrp_forecast_day_to,
        x_terms_rec.shp_mrp_forecast_day_from,
        x_terms_rec.shp_mrp_forecast_day_to,
        x_terms_rec.seq_mrp_forecast_day_from,
        x_terms_rec.seq_mrp_forecast_day_to,
        x_terms_rec.demand_tolerance_above,
        x_terms_rec.demand_tolerance_below,
        x_terms_rec.customer_contact_id,
        x_terms_rec.freight_code,
        x_terms_rec.supplier_contact_id,
        x_terms_rec.attribute_category,
        x_terms_rec.tp_attribute_category,
        x_terms_rec.attribute1,
        x_terms_rec.attribute2,
        x_terms_rec.attribute4,
        x_terms_rec.attribute5,
        x_terms_rec.attribute6,
        x_terms_rec.attribute7,
        x_terms_rec.attribute8,
        x_terms_rec.attribute9,
        x_terms_rec.attribute10,
        x_terms_rec.attribute11,
        x_terms_rec.attribute12,
        x_terms_rec.attribute13,
        x_terms_rec.attribute14,
        x_terms_rec.attribute15,
        x_terms_rec.tp_attribute1,
        x_terms_rec.tp_attribute2,
        x_terms_rec.tp_attribute3,
        x_terms_rec.tp_attribute4,
        x_terms_rec.tp_attribute5,
        x_terms_rec.tp_attribute6,
        x_terms_rec.tp_attribute7,
        x_terms_rec.tp_attribute8,
        x_terms_rec.tp_attribute9,
        x_terms_rec.tp_attribute10,
        x_terms_rec.tp_attribute11,
        x_terms_rec.tp_attribute12,
        x_terms_rec.tp_attribute13,
        x_terms_rec.tp_attribute14,
        x_terms_rec.tp_attribute15,
        x_terms_rec.intransit_calc_basis,
        x_terms_rec.pln_frozen_flag,
        x_terms_rec.shp_frozen_flag,
        x_terms_rec.seq_frozen_flag,
        x_terms_rec.issue_warning_drop_parts_flag,
	x_terms_rec.blanket_number,
	x_terms_rec.release_rule,
	x_terms_rec.release_time_frame,
	x_terms_rec.release_time_frame_uom,
        x_terms_rec.exclude_non_workdays_flag,
        x_terms_rec.disable_create_cum_key_flag
  FROM  RLM_CUST_SHIPTO_TERMS
  WHERE SHIP_FROM_ORG_ID = v_ship_from_org_id
  AND   CUSTOMER_ID = x_customer_id
  AND   ADDRESS_ID = x_ship_to_address_id;

  /* By default, inactive_date is NULL */
  IF x_terms_rec.inactive_date is NOT NULL THEN
     IF x_terms_rec.inactive_date <= sysdate THEN
        raise e_inactive_record;
     END IF;
  END IF;
  --
  -- 4129188
  --
  IF (x_terms_rec.match_within_key IS NULL OR
      x_terms_rec.match_across_key IS NULL) THEN
   --{
   OPEN c_optional_match_cust(v_ship_from_org_id, x_customer_id);
   FETCH c_optional_match_cust INTO v_match_within_key, v_match_across_key;
   CLOSE c_optional_match_cust;
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Cust. Level Match Within', v_match_within_key);
    rlm_core_sv.dlog(C_DEBUG, 'Cust. Level Match Across', v_match_across_key);
   END IF;
   --
   IF (x_terms_rec.match_within_key IS NULL) THEN
    IF v_match_within_key IS NOT NULL THEN
     x_terms_rec.match_within_key := v_match_within_key;
    ELSE
     /* By default, match_within_key is ABCDEFG  */
     x_terms_rec.match_within_key := RLM_CORE_SV.get_default_key;
    END IF;
   END IF;
   --
   IF (x_terms_rec.match_across_key IS NULL) THEN
    IF v_match_across_key IS NOT NULL THEN
     x_terms_rec.match_across_key := v_match_across_key;
    ELSE
     /* By default, match_across_key is ABCDEFG  */
     x_terms_rec.match_across_key := RLM_CORE_SV.get_default_key;
    END IF;
   END IF;
   --}
  END IF;
  --
  x_terms_rec.calc_cum_flag := 'Y';
  x_terms_definition_level := 'ADDRESS';
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

  EXCEPTION

    WHEN TOO_MANY_ROWS THEN
      --
      x_terms_rec.msg_name := 'RLM_SETUP_ADD_MULTIPLE_ROWS';
      rlm_message_sv.get_msg_text(
                         x_message_name => x_terms_rec.msg_name,
                         x_text => x_return_message);
      x_terms_definition_level := NULL;
      x_return_status := FALSE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'There are more than one record of RLM Setup Terms at the ADDRESS level');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    WHEN e_no_default THEN
      --
      x_terms_rec.msg_name := 'RLM_SETUP_ADDRESS_NO_DEFAULT';
      rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text         => x_return_message,
                    x_token1       => 'CUST',
                    x_value1       => RLM_CORE_SV.get_customer_name(x_customer_id),
                    x_token2       => 'ST',
                    x_value2       => RLM_CORE_SV.get_ship_to(x_ship_to_address_id));
      --
      --x_terms_definition_level := NULL;
      --x_return_status := FALSE;
      --
      -- Bug 4888849 : Query next level of setup terms
      --
      RLM_TPA_SV.populate_record_cust_item(x_ship_from_org_id,
                                x_customer_id,
                                x_ship_to_address_id,
                                x_customer_item_id,
                                x_terms_definition_level,
                                x_terms_rec,
                                x_return_message,
                                x_return_status);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    WHEN e_inactive_record THEN
      --
      RLM_TPA_SV.populate_record_cust_item(x_ship_from_org_id,
                                x_customer_id,
				x_ship_to_address_id,
				x_customer_item_id,
                                x_terms_definition_level,
                                x_terms_rec,
                                x_return_message,
                                x_return_status);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'The RLM Setup Terms record at the ADDRESS level has been inactivated');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    WHEN NO_DATA_FOUND THEN
       --
       RLM_TPA_SV.populate_record_cust_item(x_ship_from_org_id,
                                 x_customer_id,
				 x_ship_to_address_id,
				 x_customer_item_id,
                                 x_terms_definition_level,
                                 x_terms_rec,
                                 x_return_message,
                                 x_return_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'No data found at ADDRESS level');
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
    WHEN OTHERS THEN
       --
       x_terms_definition_level := NULL;
       x_return_status := FALSE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'SQL Error', SQLERRM);
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RAISE;

  END populate_record_add;

/*=============================================================================

  PROCEDURE NAME:        populate_record_item

=============================================================================*/

PROCEDURE populate_record_item (
                x_ship_from_org_id          IN NUMBER,
                x_customer_id               IN NUMBER,
                x_ship_to_address_id        IN NUMBER,
                x_customer_item_id          IN NUMBER,
                x_terms_definition_level    IN OUT NOCOPY VARCHAR2,
                x_terms_rec                 OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message            IN OUT NOCOPY VARCHAR2,
                x_return_status             OUT NOCOPY BOOLEAN)
IS
  --
  v_ship_to_address_id          NUMBER        DEFAULT -1;
  v_ship_from_org_id            NUMBER        DEFAULT -1;
  v_customer_item_id            NUMBER;
  e_inactive_record             EXCEPTION;
  v_level                       VARCHAR2(30)  DEFAULT NULL;
  e_no_default                  EXCEPTION;
  --
  -- 4129188
  --
  v_match_within_key             VARCHAR2(240);
  v_match_across_key             VARCHAR2(240);
  --
  CURSOR c_optional_match_cust(p_shipFromOrgId NUMBER,
                               p_CustomerId NUMBER) IS
  SELECT match_within_key, match_across_key
  FROM rlm_cust_shipto_terms
  WHERE ship_from_org_id = p_shipFromOrgId
  AND customer_id = p_CustomerId
  AND address_id IS NULL;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'populate_record_item');
     --global_atp
     rlm_core_sv.dlog(C_DEBUG, 'x_ship_from_org_id', x_ship_from_org_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_customer_id', x_customer_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_ship_to_address_id', x_ship_to_address_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_customer_item_id', x_customer_item_id );
     rlm_core_sv.dlog(C_DEBUG, 'Before Item Level Select ');
  END IF;

  v_ship_from_org_id := x_ship_from_org_id;

  -- Before selecting the terms, check if the ship_from_org_id is null */
  -- global_atp
  IF x_ship_from_org_id IS NULL THEN
    --
    BEGIN

      SELECT ship_from_org_id
      INTO   v_ship_from_org_id
      FROM   rlm_cust_item_terms
      WHERE  customer_id = x_customer_id
      AND    address_id = x_ship_to_address_id
      AND    customer_item_id = x_customer_item_id
      AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

      -- Proceed
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'v_ship_from_org_id', v_ship_from_org_id );
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        -- Get the default
        BEGIN
          SELECT ship_from_org_id
          INTO   v_ship_from_org_id
          FROM   rlm_cust_item_terms
          WHERE  customer_id = x_customer_id
          AND    address_id = x_ship_to_address_id
          AND    customer_item_id = x_customer_item_id
          AND    NVL(default_ship_from,'N') = 'Y'
          AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

          -- Proceed
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'Default v_ship_from_org_id', v_ship_from_org_id );
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_no_default;
        END;

      WHEN NO_DATA_FOUND THEN
        RAISE;

      WHEN e_no_default THEN
        RAISE;

      WHEN OTHERS THEN
        RAISE;

    END;
    --
  END IF;
  --
  -- Find Address Item terms
  --
  --
  v_level := 'REGULAR_TERMS';
  --
  SELECT ship_from_org_id,
         address_id,
         header_id,
	 agreement_id,
         agreement_name,
         future_agreement_id,
         future_agreement_name,
         round_to_std_pack_flag,
         ship_delivery_rule_name,
         ship_method,
         intransit_time,
         time_uom_code,
         std_pack_qty,
         price_list_id,
         use_edi_sdp_code_flag,
         pln_firm_day_to,
         pln_firm_day_from,
         pln_forecast_day_from,
         pln_forecast_day_to,
         pln_frozen_day_to,
         pln_frozen_day_from,
         seq_firm_day_from,
         seq_firm_day_to,
         seq_forecast_day_to,
         seq_forecast_day_from,
         seq_frozen_day_from,
         seq_frozen_day_to,
         shp_firm_day_from,
         shp_firm_day_to,
         shp_frozen_day_from,
         shp_frozen_day_to,
         shp_forecast_day_from,
         shp_forecast_day_to,
         pln_mrp_forecast_day_from,
         pln_mrp_forecast_day_to,
         shp_mrp_forecast_day_from,
         shp_mrp_forecast_day_to,
         seq_mrp_forecast_day_from,
         seq_mrp_forecast_day_to,
         demand_tolerance_above,
         demand_tolerance_below,
         customer_contact_id,
         freight_code,
         supplier_contact_id,
         attribute_category,
         tp_attribute_category,
         attribute1,
         attribute2,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         tp_attribute1,
         tp_attribute2,
         tp_attribute3,
         tp_attribute4,
         tp_attribute5,
         tp_attribute6,
         tp_attribute7,
         tp_attribute8,
         tp_attribute9,
         tp_attribute10,
         tp_attribute11,
         tp_attribute12,
         tp_attribute13,
         tp_attribute14,
         tp_attribute15,
         cust_item_terms_id,
         customer_item_id,
         calc_cum_flag,
         cust_item_status_code,
         inactive_date,
         pln_frozen_flag,
         shp_frozen_flag,
         seq_frozen_flag,
         issue_warning_drop_parts_flag,
	 blanket_number,
  	 release_rule,
	 release_time_frame,
	 release_time_frame_uom,
         exclude_non_workdays_flag
  INTO   x_terms_rec.ship_from_org_id,
         x_terms_rec.address_id,
         x_terms_rec.header_id,
	 x_terms_rec.agreement_id,
         x_terms_rec.agreement_name,
	 x_terms_rec.future_agreement_id,
         x_terms_rec.future_agreement_name,
         x_terms_rec.round_to_std_pack_flag,
         x_terms_rec.ship_delivery_rule_name,
         x_terms_rec.ship_method,
         x_terms_rec.intransit_time,
         x_terms_rec.time_uom_code,
         x_terms_rec.std_pack_qty,
         x_terms_rec.price_list_id,
         x_terms_rec.use_edi_sdp_code_flag,
         x_terms_rec.pln_firm_day_to,
         x_terms_rec.pln_firm_day_from,
         x_terms_rec.pln_forecast_day_from,
         x_terms_rec.pln_forecast_day_to,
         x_terms_rec.pln_frozen_day_to,
         x_terms_rec.pln_frozen_day_from,
         x_terms_rec.seq_firm_day_from,
         x_terms_rec.seq_firm_day_to,
         x_terms_rec.seq_forecast_day_to,
         x_terms_rec.seq_forecast_day_from,
         x_terms_rec.seq_frozen_day_from,
         x_terms_rec.seq_frozen_day_to,
         x_terms_rec.shp_firm_day_from,
         x_terms_rec.shp_firm_day_to,
         x_terms_rec.shp_frozen_day_from,
         x_terms_rec.shp_frozen_day_to,
         x_terms_rec.shp_forecast_day_from,
         x_terms_rec.shp_forecast_day_to,
         x_terms_rec.pln_mrp_forecast_day_from,
         x_terms_rec.pln_mrp_forecast_day_to,
         x_terms_rec.shp_mrp_forecast_day_from,
         x_terms_rec.shp_mrp_forecast_day_to,
         x_terms_rec.seq_mrp_forecast_day_from,
         x_terms_rec.seq_mrp_forecast_day_to,
         x_terms_rec.demand_tolerance_above,
         x_terms_rec.demand_tolerance_below,
         x_terms_rec.customer_contact_id,
         x_terms_rec.freight_code,
         x_terms_rec.supplier_contact_id,
         x_terms_rec.attribute_category,
         x_terms_rec.tp_attribute_category,
         x_terms_rec.attribute1,
         x_terms_rec.attribute2,
         x_terms_rec.attribute4,
         x_terms_rec.attribute5,
         x_terms_rec.attribute6,
         x_terms_rec.attribute7,
         x_terms_rec.attribute8,
         x_terms_rec.attribute9,
         x_terms_rec.attribute10,
         x_terms_rec.attribute11,
         x_terms_rec.attribute12,
         x_terms_rec.attribute13,
         x_terms_rec.attribute14,
         x_terms_rec.attribute15,
         x_terms_rec.tp_attribute1,
         x_terms_rec.tp_attribute2,
         x_terms_rec.tp_attribute3,
         x_terms_rec.tp_attribute4,
         x_terms_rec.tp_attribute5,
         x_terms_rec.tp_attribute6,
         x_terms_rec.tp_attribute7,
         x_terms_rec.tp_attribute8,
         x_terms_rec.tp_attribute9,
         x_terms_rec.tp_attribute10,
         x_terms_rec.tp_attribute11,
         x_terms_rec.tp_attribute12,
         x_terms_rec.tp_attribute13,
         x_terms_rec.tp_attribute14,
         x_terms_rec.tp_attribute15,
         x_terms_rec.cust_item_terms_id,
         x_terms_rec.customer_item_id,
         x_terms_rec.calc_cum_flag,
         x_terms_rec.cust_item_status_code,
         x_terms_rec.inactive_date,
         x_terms_rec.pln_frozen_flag,
         x_terms_rec.shp_frozen_flag,
         x_terms_rec.seq_frozen_flag,
         x_terms_rec.issue_warning_drop_parts_flag,
	 x_terms_rec.blanket_number,
	 x_terms_rec.release_rule,
	 x_terms_rec.release_time_frame,
	 x_terms_rec.release_time_frame_uom,
         x_terms_rec.exclude_non_workdays_flag
  FROM   RLM_CUST_ITEM_TERMS
  WHERE  SHIP_FROM_ORG_ID = v_ship_from_org_id
  AND    CUSTOMER_ID = x_customer_id
  AND    ADDRESS_ID = x_ship_to_address_id
  AND    CUSTOMER_ITEM_ID = x_customer_item_id;
  --
  v_level := 'EXCEPTIONAL_TERMS';
  --
  -- Select exceptional terms
  --
  SELECT cum_control_code,
         critical_attribute_key,
         NVL(match_within_key, rlm_core_sv.get_default_key),
         NVL(match_across_key, rlm_core_sv.get_default_key),
         schedule_hierarchy_code,
         unshipped_firm_disp_cd,
         unship_firm_cutoff_days,
         cum_shipment_rule_code,
         cum_org_level_code,
         cum_yesterd_time_cutoff,
         customer_rcv_calendar_cd,
         supplier_shp_calendar_cd,
         cust_assign_supplier_cd,
         intransit_calc_basis,
         disable_create_cum_key_flag  --Bugfix 8506409
  INTO   x_terms_rec.cum_control_code,
         x_terms_rec.critical_attribute_key,
         x_terms_rec.match_within_key,
         x_terms_rec.match_across_key,
         x_terms_rec.schedule_hierarchy_code,
         x_terms_rec.unshipped_firm_disp_cd,
         x_terms_rec.unship_firm_cutoff_days,
         x_terms_rec.cum_shipment_rule_code,
         x_terms_rec.cum_org_level_code,
         x_terms_rec.cum_yesterd_time_cutoff,
         x_terms_rec.customer_rcv_calendar_cd,
         x_terms_rec.supplier_shp_calendar_cd,
         x_terms_rec.cust_assign_supplier_cd,
         x_terms_rec.intransit_calc_basis,
         x_terms_rec.disable_create_cum_key_flag --Bugfix 8506409
  FROM   RLM_CUST_SHIPTO_TERMS
  WHERE  SHIP_FROM_ORG_ID = v_ship_from_org_id
  AND    CUSTOMER_ID = x_customer_id
  AND    ADDRESS_ID = x_ship_to_address_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Picked up exceptional terms at address level');
     rlm_core_sv.dlog(C_DEBUG, 'After Item Level Select ');
  END IF;
  --
  /* By default, inactive_date is NULL */
  IF x_terms_rec.inactive_date is NOT NULL THEN
     IF x_terms_rec.inactive_date <= sysdate THEN
        raise e_inactive_record;
     END IF;
  END IF;
  --
  -- 4129188
  --
  IF (x_terms_rec.match_within_key IS NULL OR
      x_terms_rec.match_across_key IS NULL) THEN
   --{
   OPEN c_optional_match_cust(v_ship_from_org_id, x_customer_id);
   FETCH c_optional_match_cust INTO v_match_within_key, v_match_across_key;
   CLOSE c_optional_match_cust;
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Cust. Level Match Within', v_match_within_key);
    rlm_core_sv.dlog(C_DEBUG, 'Cust. Level Match Across', v_match_across_key);
   END IF;
   --
   IF (x_terms_rec.match_within_key IS NULL) THEN
    --
    IF v_match_within_key IS NOT NULL THEN
     x_terms_rec.match_within_key := v_match_within_key;
    ELSE
     x_terms_rec.match_within_key := RLM_CORE_SV.get_default_key;
    END IF;
    --
   END IF;
   --
   IF (x_terms_rec.match_across_key IS NULL) THEN
    --
    IF v_match_across_key IS NOT NULL THEN
     x_terms_rec.match_across_key := v_match_across_key;
    ELSE
     x_terms_rec.match_across_key := RLM_CORE_SV.get_default_key;
    END IF;
    --
   END IF;
   --}
  END IF;
  --
  x_terms_definition_level := 'ADDRESS_ITEM';
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN TOO_MANY_ROWS THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_ITEM_MULTIPLE_ROWS';
    rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text => x_return_message);
    --
    x_terms_definition_level := NULL;
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Too Many Rows ');
       rlm_core_sv.dpop(C_SDEBUG, 'There are more than one record of RLM Setup Terms at the CUSTOMER_ITEM level');
    END IF;


  WHEN e_no_default THEN
    --
    x_terms_rec.msg_name := 'RLM_SETUP_ITEM_NO_DEFAULT';
    rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text         => x_return_message,
                    x_token1       => 'CUST',
                    x_value1       => RLM_CORE_SV.get_customer_name(x_customer_id),
                    x_token2       => 'ST',
                    x_value2       => RLM_CORE_SV.get_ship_to(x_ship_to_address_id),
                    x_token3       => 'CI',
                    x_value3       => RLM_CORE_SV.get_item_number(x_customer_item_id));
    --
    --x_terms_definition_level := NULL;
    --x_return_status := FALSE;
    --
    -- Bug 4888849 : Query next level of terms
    --
    RLM_TPA_SV.populate_record_add(x_ship_from_org_id,
                        x_customer_id,
                        x_ship_to_address_id,
                        x_customer_item_id,
                        x_terms_definition_level,
                        x_terms_rec,
                        x_return_message,
                        x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN e_inactive_record THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Inactive Record ');
       rlm_core_sv.dlog(C_DEBUG, 'Populating Rec Addres ');
    END IF;
    --
    RLM_TPA_SV.populate_record_add(x_ship_from_org_id,
                        x_customer_id,
                        x_ship_to_address_id,
			x_customer_item_id,
                        x_terms_definition_level,
                        x_terms_rec,
                        x_return_message,
                        x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'The RLM Setup Terms record at the CUSTOMER_ITEM level has been inactivated');
    END IF;
      --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'No data found');
    END IF;
    --
    RLM_TPA_SV.populate_record_add(x_ship_from_org_id,
                        x_customer_id,
                        x_ship_to_address_id,
			x_customer_item_id,
                        x_terms_definition_level,
                        x_terms_rec,
                        x_return_message,
                        x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'No data found');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_terms_definition_level := NULL;
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'SQL Error', SQLERRM);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RAISE;

  END populate_record_item;

/*=============================================================================

  PROCEDURE NAME:        populate_record_cust_item

=============================================================================*/

PROCEDURE populate_record_cust_item (
                x_ship_from_org_id          IN NUMBER,
                x_customer_id               IN NUMBER,
                x_ship_to_address_id        IN NUMBER,
                x_customer_item_id          IN NUMBER,
                x_terms_definition_level    IN OUT NOCOPY VARCHAR2,
                x_terms_rec                 OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message            IN OUT NOCOPY VARCHAR2,
                x_return_status             OUT NOCOPY BOOLEAN)
IS
  --
  v_ship_to_address_id          NUMBER        DEFAULT -1;
  v_ship_from_org_id            NUMBER        DEFAULT -1;
  v_customer_item_id            NUMBER;
  e_inactive_record             EXCEPTION;
  v_level                       VARCHAR2(30)  DEFAULT NULL;
  e_no_default                  EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'populate_record_cust_item');
     --global_atp
     rlm_core_sv.dlog(C_DEBUG, 'x_ship_from_org_id', x_ship_from_org_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_customer_id', x_customer_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_ship_to_address_id', x_ship_to_address_id );
     rlm_core_sv.dlog(C_DEBUG, 'x_customer_item_id', x_customer_item_id );
     rlm_core_sv.dlog(C_DEBUG, 'Before Item Level Select ');
  END IF;
  --
  v_ship_from_org_id := x_ship_from_org_id;

  -- Before selecting the terms, check if the ship_from_org_id is null */
  -- global_atp
  IF x_ship_from_org_id IS NULL THEN
    --
    BEGIN

      SELECT ship_from_org_id
      INTO   v_ship_from_org_id
      FROM   rlm_cust_item_terms
      WHERE  customer_id = x_customer_id
      AND    address_id IS NULL
      AND    customer_item_id = x_customer_item_id
      AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

      -- Proceed
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'v_ship_from_org_id', v_ship_from_org_id );
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        -- Get the default
        BEGIN
          SELECT ship_from_org_id
          INTO   v_ship_from_org_id
          FROM   rlm_cust_item_terms
          WHERE  customer_id = x_customer_id
          AND    address_id IS NULL
          AND    customer_item_id = x_customer_item_id
          AND    NVL(default_ship_from,'N') = 'Y'
          AND    (inactive_date IS NULL OR inactive_date > SYSDATE);

          -- Proceed
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'Default v_ship_from_org_id', v_ship_from_org_id );
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE e_no_default;
        END;

      WHEN NO_DATA_FOUND THEN
        RAISE;

      WHEN e_no_default THEN
        RAISE;

      WHEN OTHERS THEN
        RAISE;

    END;
    --
  END IF;

  -- Find Customer Item terms
  --
  --
  v_level := 'REGULAR_TERMS';
  --
  SELECT ship_from_org_id,
         address_id,
         header_id,
	 agreement_id,
         agreement_name,
         future_agreement_id,
         future_agreement_name,
         round_to_std_pack_flag,
         ship_delivery_rule_name,
         ship_method,
         intransit_time,
         time_uom_code,
         std_pack_qty,
         price_list_id,
         use_edi_sdp_code_flag,
         pln_firm_day_to,
         pln_firm_day_from,
         pln_forecast_day_from,
         pln_forecast_day_to,
         pln_frozen_day_to,
         pln_frozen_day_from,
         seq_firm_day_from,
         seq_firm_day_to,
         seq_forecast_day_to,
         seq_forecast_day_from,
         seq_frozen_day_from,
         seq_frozen_day_to,
         shp_firm_day_from,
         shp_firm_day_to,
         shp_frozen_day_from,
         shp_frozen_day_to,
         shp_forecast_day_from,
         shp_forecast_day_to,
         pln_mrp_forecast_day_from,
         pln_mrp_forecast_day_to,
         shp_mrp_forecast_day_from,
         shp_mrp_forecast_day_to,
         seq_mrp_forecast_day_from,
         seq_mrp_forecast_day_to,
         demand_tolerance_above,
         demand_tolerance_below,
         customer_contact_id,
         freight_code,
         supplier_contact_id,
         attribute_category,
         tp_attribute_category,
         attribute1,
         attribute2,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         tp_attribute1,
         tp_attribute2,
         tp_attribute3,
         tp_attribute4,
         tp_attribute5,
         tp_attribute6,
         tp_attribute7,
         tp_attribute8,
         tp_attribute9,
         tp_attribute10,
         tp_attribute11,
         tp_attribute12,
         tp_attribute13,
         tp_attribute14,
         tp_attribute15,
         cust_item_terms_id,
         customer_item_id,
         calc_cum_flag,
         cust_item_status_code,
         inactive_date,
         pln_frozen_flag,
         shp_frozen_flag,
         seq_frozen_flag,
         issue_warning_drop_parts_flag,
	 blanket_number,
  	 release_rule,
	 release_time_frame,
	 release_time_frame_uom,
         exclude_non_workdays_flag
  INTO   x_terms_rec.ship_from_org_id,
         x_terms_rec.address_id,
         x_terms_rec.header_id,
	 x_terms_rec.agreement_Id,
         x_terms_rec.agreement_name,
	 x_terms_rec.future_agreement_id,
         x_terms_rec.future_agreement_name,
         x_terms_rec.round_to_std_pack_flag,
         x_terms_rec.ship_delivery_rule_name,
         x_terms_rec.ship_method,
         x_terms_rec.intransit_time,
         x_terms_rec.time_uom_code,
         x_terms_rec.std_pack_qty,
         x_terms_rec.price_list_id,
         x_terms_rec.use_edi_sdp_code_flag,
         x_terms_rec.pln_firm_day_to,
         x_terms_rec.pln_firm_day_from,
         x_terms_rec.pln_forecast_day_from,
         x_terms_rec.pln_forecast_day_to,
         x_terms_rec.pln_frozen_day_to,
         x_terms_rec.pln_frozen_day_from,
         x_terms_rec.seq_firm_day_from,
         x_terms_rec.seq_firm_day_to,
         x_terms_rec.seq_forecast_day_to,
         x_terms_rec.seq_forecast_day_from,
         x_terms_rec.seq_frozen_day_from,
         x_terms_rec.seq_frozen_day_to,
         x_terms_rec.shp_firm_day_from,
         x_terms_rec.shp_firm_day_to,
         x_terms_rec.shp_frozen_day_from,
         x_terms_rec.shp_frozen_day_to,
         x_terms_rec.shp_forecast_day_from,
         x_terms_rec.shp_forecast_day_to,
         x_terms_rec.pln_mrp_forecast_day_from,
         x_terms_rec.pln_mrp_forecast_day_to,
         x_terms_rec.shp_mrp_forecast_day_from,
         x_terms_rec.shp_mrp_forecast_day_to,
         x_terms_rec.seq_mrp_forecast_day_from,
         x_terms_rec.seq_mrp_forecast_day_to,
         x_terms_rec.demand_tolerance_above,
         x_terms_rec.demand_tolerance_below,
         x_terms_rec.customer_contact_id,
         x_terms_rec.freight_code,
         x_terms_rec.supplier_contact_id,
         x_terms_rec.attribute_category,
         x_terms_rec.tp_attribute_category,
         x_terms_rec.attribute1,
         x_terms_rec.attribute2,
         x_terms_rec.attribute4,
         x_terms_rec.attribute5,
         x_terms_rec.attribute6,
         x_terms_rec.attribute7,
         x_terms_rec.attribute8,
         x_terms_rec.attribute9,
         x_terms_rec.attribute10,
         x_terms_rec.attribute11,
         x_terms_rec.attribute12,
         x_terms_rec.attribute13,
         x_terms_rec.attribute14,
         x_terms_rec.attribute15,
         x_terms_rec.tp_attribute1,
         x_terms_rec.tp_attribute2,
         x_terms_rec.tp_attribute3,
         x_terms_rec.tp_attribute4,
         x_terms_rec.tp_attribute5,
         x_terms_rec.tp_attribute6,
         x_terms_rec.tp_attribute7,
         x_terms_rec.tp_attribute8,
         x_terms_rec.tp_attribute9,
         x_terms_rec.tp_attribute10,
         x_terms_rec.tp_attribute11,
         x_terms_rec.tp_attribute12,
         x_terms_rec.tp_attribute13,
         x_terms_rec.tp_attribute14,
         x_terms_rec.tp_attribute15,
         x_terms_rec.cust_item_terms_id,
         x_terms_rec.customer_item_id,
         x_terms_rec.calc_cum_flag,
         x_terms_rec.cust_item_status_code,
         x_terms_rec.inactive_date,
         x_terms_rec.pln_frozen_flag,
         x_terms_rec.shp_frozen_flag,
         x_terms_rec.seq_frozen_flag,
         x_terms_rec.issue_warning_drop_parts_flag,
	 x_terms_rec.blanket_number,
	 x_terms_rec.release_rule,
	 x_terms_rec.release_time_frame,
	 x_terms_rec.release_time_frame_uom,
         x_terms_rec.exclude_non_workdays_flag
 FROM    RLM_CUST_ITEM_TERMS
 WHERE   SHIP_FROM_ORG_ID = v_ship_from_org_id
 AND     CUSTOMER_ID = x_customer_id
 AND     ADDRESS_ID IS NULL
 AND     CUSTOMER_ITEM_ID = x_customer_item_id;
 --
 v_level := 'EXCEPTIONAL_TERMS';
 --
 -- Select exceptional terms
 --
 SELECT	cum_control_code,
       	critical_attribute_key,
	NVL(match_within_key, rlm_core_sv.get_default_key),
        NVL(match_across_key, rlm_core_sv.get_default_key),
        schedule_hierarchy_code,
        unshipped_firm_disp_cd,
        unship_firm_cutoff_days,
        cum_shipment_rule_code,
        cum_org_level_code,
        cum_yesterd_time_cutoff,
        customer_rcv_calendar_cd,
        supplier_shp_calendar_cd,
        cust_assign_supplier_cd,
        intransit_calc_basis,
        disable_create_cum_key_flag  --Bugfix 8506409
 INTO
        x_terms_rec.cum_control_code,
	x_terms_rec.critical_attribute_key,
	x_terms_rec.match_within_key,
	x_terms_rec.match_across_key,
	x_terms_rec.schedule_hierarchy_code,
	x_terms_rec.unshipped_firm_disp_cd,
	x_terms_rec.unship_firm_cutoff_days,
	x_terms_rec.cum_shipment_rule_code,
	x_terms_rec.cum_org_level_code,
 	x_terms_rec.cum_yesterd_time_cutoff,
	x_terms_rec.customer_rcv_calendar_cd,
 	x_terms_rec.supplier_shp_calendar_cd,
	x_terms_rec.cust_assign_supplier_cd,
	x_terms_rec.intransit_calc_basis,
        x_terms_rec.disable_create_cum_key_flag --Bugfix 8506409
 FROM   RLM_CUST_SHIPTO_TERMS
 WHERE  SHIP_FROM_ORG_ID = v_ship_from_org_id
 AND    CUSTOMER_ID = x_customer_id
 AND    ADDRESS_ID IS NULL;
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Picked up exceptional terms at Customer level');
    rlm_core_sv.dlog(C_DEBUG, 'After Item Level Select ');
 END IF;
 --
  /* By default, inactive_date is NULL */
  IF x_terms_rec.inactive_date is NOT NULL THEN
     IF x_terms_rec.inactive_date <= sysdate THEN
        raise e_inactive_record;
     END IF;
  END IF;
  --
  IF x_terms_rec.match_within_key is NULL THEN
     x_terms_rec.match_within_key := rlm_core_sv.get_default_key;
  END IF;
  --
  IF x_terms_rec.match_across_key is NULL THEN
     x_terms_rec.match_across_key := rlm_core_sv.get_default_key;
  END IF;
  --
  x_terms_definition_level := 'CUSTOMER_ITEM';
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN TOO_MANY_ROWS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Too Many Rows ');
    END IF;
    --
    x_terms_rec.msg_name := 'RLM_SETUP_ITEM_MULTIPLE_ROWS';
    rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text => x_return_message);
    --
    x_terms_definition_level := NULL;
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'There are more than one record of RLM Setup Terms at the CUSTOMER_ITEM level');
    END IF;
    --

  WHEN e_no_default THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'No Default');
    END IF;
    --
    x_terms_rec.msg_name := 'RLM_SETUP_CITEM_NO_DEFAULT';
    rlm_message_sv.get_msg_text(
                    x_message_name => x_terms_rec.msg_name,
                    x_text         => x_return_message,
                    x_token1       => 'CUST',
                    x_value1       => RLM_CORE_SV.get_customer_name(x_customer_id),
                    x_token2       => 'CI',
                    x_value2       => RLM_CORE_SV.get_item_number(x_customer_item_id));
    --
    --x_terms_definition_level := NULL;
    --x_return_status := FALSE;
    --
    -- Bug 4888849 : Query next level of setup terms
    --
    RLM_TPA_SV.populate_record_cust(x_ship_from_org_id,
                         x_customer_id,
                         x_terms_definition_level,
                         x_terms_rec,
                         x_return_message,
                         x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;


  WHEN e_inactive_record THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Inactive Record ');
       rlm_core_sv.dlog(C_DEBUG, 'Populating Rec Customer ');
    END IF;
    --
    RLM_TPA_SV.populate_record_cust(x_ship_from_org_id,
                         x_customer_id,
                         x_terms_definition_level,
                         x_terms_rec,
                         x_return_message,
                         x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'The RLM Setup Terms record at the CUSTOMER_ITEM level has been inactivated');
    END IF;
      --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'No data found');
    END IF;
    --
    RLM_TPA_SV.populate_record_cust(x_ship_from_org_id,
                         x_customer_id,
                         x_terms_definition_level,
                         x_terms_rec,
                         x_return_message,
                         x_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'No data found');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_terms_definition_level := NULL;
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'SQL Error', SQLERRM);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RAISE;

  END populate_record_cust_item;


/*=============================================================================
  PROCEDURE NAME:	GetTPContext

  DESCRIPTION:		This procedure returns the tpcontext

  PARAMETERS:		x_customer_id	 		IN NUMBER DEFAULT NULL
		        x_ship_to_address_id 		IN NUMBER DEFAULT NULL
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/


  PROCEDURE GetTPContext(
			x_customer_id	 		IN NUMBER,
		        x_ship_to_address_id 		IN NUMBER,
                       	x_customer_number 		OUT NOCOPY VARCHAR2,
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2)
 IS

  BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_DEBUG, 'GetTPContext');
  END IF;

  IF x_customer_id IS NOT NULL THEN

	IF x_ship_to_address_id IS NOT NULL THEN
               -- Following query is changed as per TCA obsolescence project.
		SELECT 	acct_site.ece_tp_location_code,
			ETG.tp_group_code
		INTO	x_ship_to_ece_locn_code,
			x_tp_group_code
		FROM	HZ_CUST_ACCT_SITES ACCT_SITE,
			ece_tp_headers ETH,
			ece_tp_group ETG
		WHERE	ACCT_SITE.CUST_ACCOUNT_ID = x_customer_id
		AND	ACCT_SITE.CUST_ACCT_SITE_ID  = x_ship_to_address_id
		AND	ETH.tp_header_id = acct_site.tp_header_id
		AND	ETG.tp_group_id = ETH.tp_group_id;
	END IF;

        -- Following query is changed as per TCA obsolescence project.
	SELECT	account_number
	INTO	x_customer_number
	FROM	HZ_CUST_ACCOUNTS CUST_ACCT
	WHERE	CUST_ACCT.CUST_ACCOUNT_ID = x_customer_id;

  END IF;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'customer_number', x_customer_number);
     rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
     rlm_core_sv.dlog(C_DEBUG, 'x_tp_group_code',x_tp_group_code);
     rlm_core_sv.dpop(C_DEBUG, 'Successful');
  END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
        --
        x_customer_number:=null;
        x_ship_to_ece_locn_code:=null;
        x_bill_to_ece_locn_code:=null;
        x_inter_ship_to_ece_locn_code:=null;
        x_tp_group_code:=null;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'customer_number', x_customer_number);
           rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
           rlm_core_sv.dlog(C_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
           rlm_core_sv.dlog(C_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
           rlm_core_sv.dlog(C_DEBUG, 'x_tp_group_code',x_tp_group_code);
   	   rlm_core_sv.dpop(C_DEBUG);
        END IF;
        --
  WHEN OTHERS THEN
	--
  	IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_SDEBUG, 'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
   	  rlm_core_sv.dpop(C_DEBUG);
	END IF;
	--
	RAISE;

  END GetTPContext;


END rlm_setup_terms_sv;

/
