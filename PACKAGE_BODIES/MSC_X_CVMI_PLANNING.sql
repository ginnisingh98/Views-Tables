--------------------------------------------------------
--  DDL for Package Body MSC_X_CVMI_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_CVMI_PLANNING" AS
/* $Header: MSCXCVPB.pls 115.14 2004/07/14 01:04:38 jguo noship $ */

  COMPANY_MAPPING CONSTANT NUMBER := 1;
  ORGANIZATION_MAPPING CONSTANT NUMBER := 2;
  SITE_MAPPING CONSTANT NUMBER := 3;
  OEM_COMPANY_ID CONSTANT NUMBER := 1;

  g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
  l_old_average_daily_demand NUMBER;
  l_forecast_horizon NUMBER;
  l_vmi_refresh_flag NUMBER;

  -- calculate average daily demand
  PROCEDURE calculate_average_demand
    IS
    l_total_forecast NUMBER;
    l_old_average_daily_demand NUMBER;
    l_sce_customer_id NUMBER;
    l_sce_organization_id NUMBER;
    l_sce_supplier_id NUMBER;
    l_sce_supplier_site_id NUMBER;

    l_horizon_end_date DATE;
    l_forecast_order_type NUMBER;
    l_vmi_forecast_type NUMBER;

    CURSOR c_forecast_items IS
      SELECT
          msi.plan_id
        , msi.inventory_item_id
        , msi.organization_id
        , msi.sr_instance_id
        , mtp.modeled_customer_id
        , mtp.modeled_customer_site_id
        , NVL(msi.forecast_horizon, 0) forecast_horizon
        , msi.vmi_forecast_type
	, msi.uom_code
        , mvt.average_daily_demand
      FROM msc_system_items msi
      , msc_trading_partners mtp
      , msc_vmi_temp mvt
      WHERE msi.inventory_planning_code = 7
      AND msi.organization_id = mtp.sr_tp_id
      AND msi.sr_instance_id = mtp.sr_instance_id
      AND mtp.partner_type = 3 -- org
      AND mtp.modeled_customer_id IS NOT NULL
      AND mtp.modeled_customer_site_id IS NOT NULL
      AND msi.plan_id = -1
	      and mvt.plan_id (+) = msi.plan_id
	      and mvt.inventory_item_id (+) = msi.inventory_item_id
	      and mvt.organization_id (+) = msi.organization_id
	      and mvt.sr_instance_id (+) = msi.sr_instance_id
          and mvt.vmi_type (+) = 2 -- customer facing vmi
      ;

  BEGIN

print_debug_info('Start of average daily demand engine');

    FOR forecast_item IN c_forecast_items LOOP

print_debug_info( '  plan/item/org/instance/customer/customer site = '
                                 || forecast_item.plan_id
                                 || '-' || forecast_item.inventory_item_id
                                 || '-' || forecast_item.organization_id
                                 || '-' || forecast_item.sr_instance_id
                                 || '-' || forecast_item.modeled_customer_id
                                 || '-' || forecast_item.modeled_customer_site_id
                                 );
print_debug_info( '  forecast horizon/forecast type/uom/old average daily demand = '
                                 || forecast_item.forecast_horizon
                                 || '-' || forecast_item.vmi_forecast_type
				 || '-' || forecast_item.uom_code
                                 || '-' || forecast_item.average_daily_demand
                                 );


  calculate_average_demand
  ( forecast_item.plan_id
  , forecast_item.inventory_item_id
  , forecast_item.organization_id
  , forecast_item.sr_instance_id
  , forecast_item.modeled_customer_id
  , forecast_item.modeled_customer_site_id
  , forecast_item.forecast_horizon
  , forecast_item.vmi_forecast_type
  , forecast_item.uom_code
  , forecast_item.average_daily_demand
  );

    END LOOP; -- c_forecast_items
print_debug_info( 'End of average daily demand calculation engine');
  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in average daily demand calculation engine = ' || sqlerrm);
     RAISE;
  END calculate_average_demand;

  -- calculate average daily demand
  PROCEDURE calculate_average_demand
  ( p_plan_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_organization_id IN NUMBER
  , p_sr_instance_id IN NUMBER
  , p_customer_id IN NUMBER
  , p_customer_site_id IN NUMBER
  , p_forecast_horizon IN NUMBER
  , p_vmi_forecast_type IN NUMBER
  , p_item_uom_code     IN varchar2
  , p_old_average_daily_demand IN NUMBER
  )
    IS
    l_total_forecast NUMBER := 0;
    l_average_daily_demand NUMBER;
    l_sce_supplier_id NUMBER;
    l_sce_organization_id NUMBER;
    l_sce_customer_id NUMBER;
    l_sce_customer_site_id NUMBER;
    l_horizon_end_date DATE;
    l_forecast_order_type NUMBER;
    l_horizon_start_date DATE;

lv_calendar_code    varchar2(14);
lv_instance_id      number;

l_conv_found BOOLEAN := FALSE;
l_conv_rate NUMBER := 1;
lv_forecast_type    NUMBER;

    CURSOR c_total_forecast
      ( p_plan_id NUMBER
      , p_inventory_item_id NUMBER
      , p_organization_id NUMBER
      , p_customer_id NUMBER
      , p_customer_site_id NUMBER
      , p_horizon_end_date DATE
      , l_forecast_type    NUMBER
      , p_horizon_start_date DATE
      ) IS
     SELECT distinct SUM(sd.primary_quantity) total_demand,
			 sd.primary_uom
     FROM msc_sup_dem_entries sd
      WHERE sd.plan_id = p_plan_id
      AND sd.inventory_item_id = p_inventory_item_id
      AND sd.customer_id = p_customer_id
      AND sd.customer_site_id = p_customer_site_id
      AND TRUNC(key_date) BETWEEN TRUNC(p_horizon_start_date)
				AND TRUNC(p_horizon_end_date)
      AND publisher_order_type = l_forecast_type
      AND sd.supplier_id = 1
      AND p_forecast_horizon > 0
      GROUP BY
	   sd.primary_uom
      ;

  BEGIN

print_debug_info( '  plan/item/org/instance/customer/customer site = '
                                 || p_plan_id
                                 || '-' || p_inventory_item_id
                                 || '-' || p_organization_id
                                 || '-' || p_sr_instance_id
                                 || '-' || p_customer_id
                                 || '-' || p_customer_site_id
                                 );
print_debug_info( '  forecast horizon/forecast type/old average daily demand = '
                                 || p_forecast_horizon
                                 || '-' || p_vmi_forecast_type
                                 || '-' || p_old_average_daily_demand
                                 );
      l_sce_organization_id := aps_to_sce(p_organization_id, ORGANIZATION_MAPPING, p_sr_instance_id);
      l_sce_customer_id := aps_to_sce(p_customer_id, COMPANY_MAPPING);
      l_sce_customer_site_id := aps_to_sce(p_customer_site_id, SITE_MAPPING);

	  /* Call the API to get the correct Calendar */
	 msc_x_util.get_calendar_code(
			     1,
			     l_sce_organization_id,
			     l_sce_customer_id,
			     l_sce_customer_site_id,
			     lv_calendar_code,
			     lv_instance_id);
	 print_debug_info(' Calendar/sr_instance_id : ' || lv_calendar_code||'/'||lv_instance_id);

	print_debug_info( '  cp org/cp customer/cp customer site = '
					 || l_sce_organization_id
					 || '/' || l_sce_customer_id
					 || '/' || l_sce_customer_site_id
					 );

      IF (p_vmi_forecast_type = 1 OR p_vmi_forecast_type = 2) THEN
        l_horizon_start_date := SYSDATE;
        l_horizon_end_date := MSC_CALENDAR.DATE_OFFSET( lv_calendar_code -- arg_calendar_code IN varchar2,
		                                , lv_instance_id -- arg_instance_id IN NUMBER,
                                        , SYSDATE -- l_horizon_start_date -- arg_date IN DATE,
                                        , p_forecast_horizon -- arg_offset IN NUMBER
					, 99999  --arg_offset_type
                                        );
      ELSIF (p_vmi_forecast_type = 3) THEN
        l_horizon_start_date := MSC_CALENDAR.DATE_OFFSET( lv_calendar_code -- arg_calendar_code IN varchar2,
		                                , lv_instance_id -- arg_instance_id IN NUMBER,
                                        , SYSDATE -- l_horizon_start_date -- arg_date IN DATE,
                                        , 0 - p_forecast_horizon -- arg_offset IN NUMBER
					, 99999  --arg_offset_type
                                        );
        l_horizon_end_date := SYSDATE;
      END IF;

print_user_info( '  forecast horizon end date = ' || l_horizon_end_date);

IF (p_vmi_forecast_type = 1) THEN
	      /* ORDER - FORECAST */
      lv_forecast_type := 2;
      print_debug_info('Order Forecast');

ELSIF (p_vmi_forecast_type = 2) THEN
	      /* SALES - FORECAST */
      lv_forecast_type := 1;
      print_debug_info('Sales Forecast');

ELSIF (p_vmi_forecast_type = 3) THEN
	      /* HISTORICAL - SALES */
      lv_forecast_type := 4;
      print_debug_info('Historical Sales');

END IF;

        FOR c_rec IN c_total_forecast(
			  p_plan_id
			, p_inventory_item_id
			, l_sce_organization_id
			, l_sce_customer_id
			, l_sce_customer_site_id
			, l_horizon_end_date
			, lv_forecast_type
			, l_horizon_start_date
			)
	LOOP
		  IF (c_rec.primary_uom <> p_item_uom_code) THEN
			 MSC_X_UTIL.GET_UOM_CONVERSION_RATES( c_rec.primary_uom
							    , p_item_uom_code
							    , p_inventory_item_id
							    , l_conv_found
							    , l_conv_rate
							    );
			  print_debug_info('t_primary_uom/item_uom_code/l_conv_rate:'
					    || c_rec.primary_uom||'/'||p_item_uom_code
					    ||'/'||l_conv_rate);
			  l_total_forecast := l_total_forecast + c_rec.total_demand*l_conv_rate;
		  ELSE
			  l_total_forecast := l_total_forecast + c_rec.total_demand;
		  END IF;
       END LOOP;


      IF (p_forecast_horizon <> 0) AND (p_forecast_horizon IS NOT NULL) THEN
        l_average_daily_demand := round((NVL(l_total_forecast, 0)
                             / p_forecast_horizon),6);
      ELSE
print_user_info( '  Forecast horizon is zero or NULL, please set up forecast horizon correctly');

      END IF;

print_debug_info( '  total order forecast/average daily demand = '
                                 || l_total_forecast
                                 || '/' || l_average_daily_demand
                                 );

      IF (l_average_daily_demand <> p_old_average_daily_demand) THEN
        l_vmi_refresh_flag := 1;
      ELSE
        l_vmi_refresh_flag := NULL;
      END IF;

      UPDATE msc_system_items
        SET -- average_daily_demand = l_average_daily_demand
        vmi_refresh_flag = NVL(l_vmi_refresh_flag, vmi_refresh_flag)
        WHERE plan_id = p_plan_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND sr_instance_id = p_sr_instance_id
        ;
print_debug_info( '  vmi refresh flag updated, number of rows updated = '
                                 || SQL%ROWCOUNT
                                 );

      UPDATE msc_vmi_temp
        SET average_daily_demand = l_average_daily_demand
        WHERE plan_id = p_plan_id
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND sr_instance_id = p_sr_instance_id
        AND vmi_type = 2 -- customer facing vmi
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
			NULL, -- p_SUPPLIER_ID ,
			NULL, -- p_SUPPLIER_SITE_ID ,
			NULL, -- p_USING_ORGANIZATION_ID ,
			2 ,
			l_AVERAGE_DAILY_DEMAND
		  );

print_debug_info( '  average daily demand inserted, number of rows inserted = '
                                 || SQL%ROWCOUNT
                                 );

	END IF;

				 commit;

  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in average daily demand calculation ' || sqlerrm);
     RAISE;
  END calculate_average_demand;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION aps_to_sce(
      p_tp_key IN NUMBER
    , p_map_type IN NUMBER
    , p_sr_instance_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER IS

    l_company_key NUMBER;

    CURSOR c_company_key_1 IS
      SELECT cr.object_id
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = p_map_type
      AND map.tp_key = p_tp_key
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 1 -- customer of, 2 -- supplier of
      ;

    CURSOR c_company_key_2 IS
      SELECT map.company_key
      FROM msc_trading_partner_maps map
      , msc_trading_partners tp
      WHERE map.map_type = p_map_type
      AND tp.partner_id = map.tp_key
      AND tp.sr_tp_id = p_tp_key
      AND tp.sr_instance_id = p_sr_instance_id
      ;

    CURSOR c_company_key_3 IS
      SELECT  map.company_key
      FROM msc_trading_partner_maps map
      WHERE map.map_type = p_map_type
      AND map.tp_key = p_tp_key
      ;
BEGIN
    IF (p_map_type = COMPANY_MAPPING) THEN -- company
      OPEN c_company_key_1;
      FETCH c_company_key_1 INTO l_company_key;
      CLOSE c_company_key_1;
    END IF;

    IF (p_map_type = ORGANIZATION_MAPPING) THEN -- org
      OPEN c_company_key_2;
      FETCH c_company_key_2 INTO l_company_key;
      CLOSE c_company_key_2;
    END IF;

    IF (p_map_type = SITE_MAPPING) THEN -- site
      OPEN c_company_key_3;
      FETCH c_company_key_3 INTO l_company_key;
      CLOSE c_company_key_3;
    END IF;

 print_debug_info('    p_map_type = ' || p_map_type
                                  || ' p_tp_key = ' || p_tp_key
                                  || ' l_company_key = ' || l_company_key
                                  );
    RETURN l_company_key;
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END aps_to_sce;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION sce_to_aps(
      p_company_key IN NUMBER
    , p_map_type IN NUMBER
    ) RETURN NUMBER IS

    l_tp_key NUMBER;

    CURSOR c_tp_key_1 IS
      SELECT map.tp_key
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = p_map_type
      AND cr.object_id = p_company_key
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 1 -- customer of, 2 -- supplier of
      AND cr.subject_id = OEM_COMPANY_ID
      ;

    CURSOR c_tp_key_2 IS
      SELECT tp.sr_tp_id
      FROM msc_trading_partner_maps map
      , msc_trading_partners tp
      WHERE map.map_type = p_map_type
      AND tp.partner_id = map.tp_key
      AND map.company_key= p_company_key
      ;
      /*AND tp.partner.partner_type = 3*/

    CURSOR c_tp_key_3 IS
      SELECT  map.tp_key
      FROM msc_trading_partner_maps map
      WHERE map.map_type = p_map_type
      AND  map.company_key = p_company_key

      ;
BEGIN
    IF (p_map_type = COMPANY_MAPPING) THEN -- company
      OPEN c_tp_key_1;
      FETCH c_tp_key_1 INTO l_tp_key;
      CLOSE c_tp_key_1;
    END IF;

    IF (p_map_type = ORGANIZATION_MAPPING) THEN -- org
      OPEN c_tp_key_2;
      FETCH c_tp_key_2 INTO l_tp_key;
      CLOSE c_tp_key_2;
    END IF;

    IF (p_map_type = SITE_MAPPING) THEN -- site
      OPEN c_tp_key_3;
      FETCH c_tp_key_3 INTO l_tp_key;
      CLOSE c_tp_key_3;
    END IF;

 print_debug_info('sce_to_aps:000 p_map_type = ' || p_map_type
                                  || ' p_company_key = ' || p_company_key
                                  || ' l_tp_key = ' || l_tp_key
                                  );
    RETURN l_tp_key;

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END sce_to_aps;

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

END MSC_X_CVMI_PLANNING;

/
