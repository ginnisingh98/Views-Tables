--------------------------------------------------------
--  DDL for Package Body MSC_X_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_PLANNING" AS
/* $Header: MSCXSVPB.pls 115.14 2004/07/21 22:30:07 jguo noship $ */

  g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');

  SUPPLIER_IS_OEM   number := 1;
  CUSTOMER_IS_OEM   number := 2;

  -- calculate average daily demand
  PROCEDURE calculate_average_demand
    IS
    l_total_supply_schedule NUMBER;
    l_average_daily_demand NUMBER;
    l_sce_customer_id NUMBER;
    l_sce_organization_id NUMBER;
    l_sce_supplier_id NUMBER;
    l_sce_supplier_site_id NUMBER;

    l_horizon_end_date DATE;

    CURSOR c_forecast_items IS
     SELECT DISTINCT
          mis.plan_id
        , mis.inventory_item_id
        , mis.organization_id
        , mis.sr_instance_id
        , mis.supplier_id
        , mis.supplier_site_id
        , mis.using_organization_id
     FROM msc_item_suppliers mis
      WHERE mis.plan_id = -1
      AND mis.vmi_flag = 1
      ;

  BEGIN

print_debug_info('Start of average daily demand engine');

    FOR forecast_item IN c_forecast_items LOOP

print_debug_info( '  plan/item/org/instance/supplier/supplier site/using org = '
                                 || forecast_item.plan_id
                                 || '/' || forecast_item.inventory_item_id
                                 || '/' || forecast_item.organization_id
                                 || '/' || forecast_item.sr_instance_id
                                 || '/' || forecast_item.supplier_id
                                 || '/' || forecast_item.supplier_site_id
                                 || '/' || forecast_item.using_organization_id
                                 );
  calculate_average_demand_api
  ( forecast_item.plan_id
  , forecast_item.inventory_item_id
  , forecast_item.organization_id
  , forecast_item.sr_instance_id
  , forecast_item.supplier_id
  , forecast_item.supplier_site_id
  , forecast_item.using_organization_id
  , 1
  , SYSDATE
  , l_average_daily_demand
  );

    END LOOP; -- c_forecast_items
print_debug_info( 'End of average daily demand calculation engine');
  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in average daily demand calculation engine = ' || sqlerrm);
     RAISE;
  END calculate_average_demand;

  -- calculate average daily demand
  PROCEDURE calculate_average_demand_api
  ( p_plan_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_organization_id IN NUMBER
  , p_sr_instance_id IN NUMBER
  , p_supplier_id IN NUMBER
  , p_supplier_site_id IN NUMBER
  , p_using_organization_id IN NUMBER
  , p_update_flag IN NUMBER DEFAULT 1
  , p_horizon_start_date IN DATE DEFAULT SYSDATE
  , p_average_daily_demand OUT NOCOPY NUMBER
  )
    IS
    l_total_supply_schedule NUMBER;
    l_sce_customer_id NUMBER;
    l_sce_organization_id NUMBER;
    l_sce_supplier_id NUMBER;
    l_sce_supplier_site_id NUMBER;

    l_horizon_end_date DATE;
    l_vmi_refresh_flag NUMBER;
    l_forecast_horizon NUMBER;
    l_old_average_daily_demand NUMBER;

lv_calendar_code    varchar2(14);
lv_instance_id      number;

    CURSOR c_total_supply_schedule
      ( p_plan_id NUMBER
      , p_inventory_item_id NUMBER
      , p_organization_id NUMBER
      -- , p_sr_instance_id NUMBER
      , p_supplier_id NUMBER
      , p_supplier_site_id NUMBER
      , p_horizon_end_date DATE
      ) IS
     SELECT SUM(sd.primary_quantity) total_demand
     FROM msc_sup_dem_entries sd
      WHERE sd.plan_id = p_plan_id
      AND sd.inventory_item_id = p_inventory_item_id
      AND sd.customer_site_id = p_organization_id
      -- AND sd.sr_instance_id = p_sr_instance_id
      AND sd.supplier_id = p_supplier_id
      AND sd.supplier_site_id = p_supplier_site_id
      AND TRUNC(receipt_date) BETWEEN TRUNC(p_horizon_start_date)
        AND TRUNC(p_horizon_end_date + 1)
      AND publisher_order_type = 2 -- order forecast
      ;

      CURSOR c_asl_attributes
        ( p_inventory_item_id IN NUMBER
	    , p_plan_id IN NUMBER
	    , p_sr_instance_id IN NUMBER
	    , p_organization_id IN NUMBER
	    , p_supplier_id IN NUMBER
	    , p_supplier_site_id IN NUMBER
        , p_using_organization_id IN NUMBER

      ) IS
      SELECT  mis.forecast_horizon, mvt.average_daily_demand
	       FROM  msc_item_suppliers mis
	       , msc_vmi_temp mvt
	       WHERE mis.inventory_item_id = p_inventory_item_id
	       AND  mis.plan_id = p_plan_id
	       AND  mis.sr_instance_id = p_sr_instance_id
	       AND  mis.organization_id = p_organization_id
           AND mis. supplier_id = p_supplier_id
           AND mis. supplier_site_id = p_supplier_site_id
           AND mis.using_organization_id = p_using_organization_id
	      and mvt.plan_id (+) = mis.plan_id
	      and mvt.inventory_item_id (+) = mis.inventory_item_id
	      and mvt.organization_id (+) = mis.organization_id
	      and mvt.sr_instance_id (+) = mis.sr_instance_id
	      and mvt.supplier_site_id (+) = mis.supplier_site_id
	      and mvt.supplier_id (+) = mis.supplier_id
	      and NVL (mvt.using_organization_id(+), 1) = NVL(mis.using_organization_id, -1)
          and mvt.vmi_type (+) = 1 -- supplier facing vmi
      ;

  BEGIN

print_debug_info( '  plan/item/org/instance/supplier/supplier site/using org = '
                                 || p_plan_id
                                 || '/' || p_inventory_item_id
                                 || '/' || p_organization_id
                                 || '/' || p_sr_instance_id
                                 || '/' || p_supplier_id
                                 || '/' || p_supplier_site_id
                                 || '/' || p_using_organization_id
                                 );
      l_sce_organization_id := msc_x_replenish.aps_to_sce(p_organization_id, MSC_X_REPLENISH.ORGANIZATION_MAPPING, p_sr_instance_id);
      l_sce_supplier_id := msc_x_replenish.aps_to_sce(p_supplier_id, MSC_X_REPLENISH.COMPANY_MAPPING);
      l_sce_supplier_site_id := msc_x_replenish.aps_to_sce(p_supplier_site_id, MSC_X_REPLENISH.SITE_MAPPING);

print_debug_info( '  cp org/cp supplier/cp supplier site = '
                                 || l_sce_organization_id
                                 || '/' || l_sce_supplier_id
                                 || '/' || l_sce_supplier_site_id
                                 );

      OPEN c_asl_attributes
        ( p_inventory_item_id
	    , p_plan_id
	    , p_sr_instance_id
	    , p_organization_id
	    , p_supplier_id
	    , p_supplier_site_id
        , p_using_organization_id
      );
      FETCH c_asl_attributes INTO l_forecast_horizon, l_old_average_daily_demand;
      CLOSE c_asl_attributes;

print_debug_info( '  forecast horizon/old average daily demand = '
                                 || l_forecast_horizon
                                 || '/' || l_old_average_daily_demand
                                 );

     if (nvl(l_forecast_horizon,0) > 0) then
	  /* Call the API to get the correct Calendar */

	 BEGIN
	 msc_x_util.get_calendar_code(
			     p_supplier_id,
			     p_supplier_site_id,
			     1,                 --- OEM
			     p_organization_id, -- oem Org
			     lv_calendar_code,
			     lv_instance_id,
			     2,                -- TP ids are in terms of APS
			     p_sr_instance_id,
			     CUSTOMER_IS_OEM);
   	EXCEPTION
	  WHEN OTHERS THEN
	    IF (lv_calendar_code = '-1') THEN
	      print_user_info( '  Default calendar code is not correct, please check profile option MSC: Collaborative Planning Default Calendar.');
	    ELSE
		  RAISE;
		END IF;
   	END;
	 print_debug_info(' Calendar/sr_instance_id : ' || lv_calendar_code||'/'||lv_instance_id);

	l_horizon_end_date := MSC_CALENDAR.DATE_OFFSET(
				  lv_calendar_code -- arg_calendar_code IN varchar2,
				, lv_instance_id -- arg_instance_id IN NUMBER,
				, p_horizon_start_date -- arg_date IN DATE,
				, l_forecast_horizon -- arg_offset IN NUMBER
				, 99999  --arg_offset_type
				);
     end if;

print_debug_info( '  forecast horizon end date = '
                                 || l_horizon_end_date
                                 );

      OPEN c_total_supply_schedule
      ( p_plan_id
      , p_inventory_item_id
      , l_sce_organization_id
      -- , p_sr_instance_id
      , l_sce_supplier_id
      , l_sce_supplier_site_id
      , l_horizon_end_date
      );
      FETCH c_total_supply_schedule INTO l_total_supply_schedule;
      CLOSE c_total_supply_schedule;

      IF (l_forecast_horizon <> 0) AND (l_forecast_horizon IS NOT NULL) THEN
        p_average_daily_demand := NVL(l_total_supply_schedule, 0)
                             / l_forecast_horizon;
      ELSE
print_user_info( '  Forecast horizon is zero or NULL, please set up forecast horizon correctly');
        p_average_daily_demand := 0;
      END IF;

print_debug_info( '  total order forecast/average daily demand = '
                                 || l_total_supply_schedule
                                 || '/' || p_average_daily_demand
                                 );

  IF (p_update_flag = 1) THEN
      IF (p_average_daily_demand <> l_old_average_daily_demand) THEN
        l_vmi_refresh_flag := 1;
      ELSE
        l_vmi_refresh_flag := NULL;
      END IF;

      UPDATE msc_item_suppliers
        SET -- average_daily_demand = p_average_daily_demand
          vmi_refresh_flag = NVL(l_vmi_refresh_flag, vmi_refresh_flag)
        WHERE plan_id = p_plan_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND sr_instance_id = p_sr_instance_id
        AND supplier_id = p_supplier_id
        AND supplier_site_id = p_supplier_site_id
        AND using_organization_id = p_using_organization_id
        ;
print_debug_info( '  vmi refresh flag updated, number of rows updated = '
                                 || SQL%ROWCOUNT
                                 );

      UPDATE msc_vmi_temp
        SET average_daily_demand = p_average_daily_demand
        WHERE plan_id = p_plan_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND sr_instance_id = p_sr_instance_id
        AND supplier_id = p_supplier_id
        AND supplier_site_id = p_supplier_site_id
        AND using_organization_id = p_using_organization_id
        AND vmi_type = 1 -- supplier facing vmi
        ;

print_debug_info( '  average daily demand updated, number of rows updated = '
                                 || SQL%ROWCOUNT
                                 );

      IF (SQL%ROWCOUNT = 0 ) THEN
		INSERT INTO msc_vmi_temp
		  ( PLAN_ID,
			INVENTORY_ITEM_ID,
			ORGANIZATION_ID ,
			SR_INSTANCE_ID ,
			SUPPLIER_ID ,
			SUPPLIER_SITE_ID ,
			USING_ORGANIZATION_ID ,
			VMI_TYPE ,
			AVERAGE_DAILY_DEMAND
		  ) VALUES
		  ( p_PLAN_ID,
			p_INVENTORY_ITEM_ID,
			p_ORGANIZATION_ID ,
			p_SR_INSTANCE_ID ,
			p_SUPPLIER_ID ,
			p_SUPPLIER_SITE_ID ,
			p_USING_ORGANIZATION_ID ,
			1 ,
			p_AVERAGE_DAILY_DEMAND
		  );
print_debug_info( '  average daily demand inserted, number of rows inserted = '
                                 || SQL%ROWCOUNT
                                 );

	END IF;

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in average daily demand calculation ' || sqlerrm);
     RAISE;
  END calculate_average_demand_api;

  -- This procesure prints out debug information
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  )IS
  BEGIN
    IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
    END IF;
    -- dbms_output.put_line(p_debug_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_debug_info;

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  ) IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
    -- dbms_output.put_line(p_user_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_user_info;

END MSC_X_PLANNING;

/
