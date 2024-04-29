--------------------------------------------------------
--  DDL for Package Body FTE_FREIGHT_PRICING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FREIGHT_PRICING" as
/* $Header: FTEFRPRB.pls 120.23 2005/12/02 09:53:05 mechawla ship $ */

-- Private Package level Variables

   G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_FREIGHT_PRICING';

   G_RC_SUCCESS 		CONSTANT NUMBER := 0;
   G_RC_ERROR 			CONSTANT NUMBER := 1;
   G_RC_REPRICE_NOT_REQUIRED 	CONSTANT NUMBER := 2;
   G_RC_NOT_RATE_FREIGHT_TERM 	CONSTANT NUMBER := 3;
   G_RC_NOT_RATE_MANIFESTING 	CONSTANT NUMBER := 4;

   g_finished_success		EXCEPTION;
   g_finished_warning		EXCEPTION;

CURSOR get_uom_for_each
IS
SELECT uom_for_num_of_units
FROM wsh_global_parameters;

-- CURSOR get_uom_for_each
-- IS
-- SELECT 'Ea' uom_for_num_of_units
-- FROM wsh_global_parameters;

CURSOR get_category(c_item_id IN NUMBER,c_org_id IN NUMBER,c_classification_code IN VARCHAR2) IS
SELECT mc.category_id
FROM   mtl_categories mc, mtl_item_categories mic,
       mtl_category_sets_tl mcstl
WHERE  mic.inventory_item_id = c_item_id
AND    mic.organization_id   = c_org_id
AND    mic.category_set_id   = mcstl.category_set_id
AND    mc.category_id        = mic.category_id
AND    mc.segment1           = c_classification_code
AND    mcstl.category_set_name = 'WSH_COMMODITY_CODE';

CURSOR get_category_basis(c_lane_id IN NUMBER,c_category_id IN NUMBER) IS
SELECT basis
FROM   fte_lane_commodities
WHERE  lane_id = c_lane_id
AND    commodity_catg_id = c_category_id;

-- This category id will get assigned to an item when a lane does not have any classification code assigned to it
-- which effectively means the user does not care about the categories of the items going on that lane eg. Parcel lanes
g_default_category_id      NUMBER:= -9999;

   CURSOR c_get_delivery_id(c_leg_id NUMBER)
   IS
   SELECT delivery_id
   FROM wsh_delivery_legs
   WHERE delivery_leg_id = c_leg_id;

   CURSOR c_count_delivery_details(c_delivery_id NUMBER)
   IS
   SELECT count(delivery_detail_id) FROM wsh_delivery_assignments
   WHERE delivery_id = c_delivery_id;

   CURSOR c_count_delivery_details2(c_trip_id NUMBER)
   IS
   SELECT count(delivery_detail_id) FROM wsh_delivery_assignments
   WHERE delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id = c_trip_id
   	 AND   wts2.trip_id = c_trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);

   -- count the number of deliveries which should not be rated due to freight term
   CURSOR c_check_del_freight_term(c_delivery_id NUMBER)
   IS
   SELECT count(wd.delivery_id)
   FROM   wsh_new_deliveries wd, wsh_global_parameters wgp
   WHERE (
	  ((wd.shipment_direction in ('I'))
	   and (wgp.rate_ib_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ib_dels_fgt_term <> wd.freight_terms_code)
	  )
   	  OR
	  ((wd.shipment_direction in ('D'))
	   and (wgp.rate_ds_dels_fgt_term_id is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ds_dels_fgt_term_id <> wd.freight_terms_code)
	  )
   	  OR
	  ((nvl(wd.shipment_direction,'O') in ('O','IO'))
           and (wgp.skip_rate_ob_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
 	   and (wgp.skip_rate_ob_dels_fgt_term = wd.freight_terms_code)
	  )
	 )
   AND    wd.delivery_id    = c_delivery_id;

   -- count the number of deliveries which should not be rated due to freight term
   CURSOR c_check_del_freight_term2(c_trip_id NUMBER)
   IS
   SELECT count(wd.delivery_id)
   FROM   wsh_new_deliveries wd, wsh_global_parameters wgp
   WHERE (
	  ((wd.shipment_direction in ('I'))
	   and (wgp.rate_ib_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ib_dels_fgt_term <> wd.freight_terms_code)
	  )
   	  OR
	  ((wd.shipment_direction in ('D'))
	   and (wgp.rate_ds_dels_fgt_term_id is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ds_dels_fgt_term_id <> wd.freight_terms_code)
	  )
   	  OR
	  ((nvl(wd.shipment_direction,'O') in ('O','IO'))
           and (wgp.skip_rate_ob_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
 	   and (wgp.skip_rate_ob_dels_fgt_term = wd.freight_terms_code)
	  )
	 )
   AND    wd.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id = c_trip_id
   	 AND   wts2.trip_id = c_trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);

   -- count the number of deliveries which should not be rated due to manifesting
  CURSOR c_check_del_manifesting(c_delivery_id NUMBER)
  IS
  SELECT count(a.delivery_id)
  FROM   wsh_new_deliveries a,
	 mtl_parameters b,
	 wsh_carriers c
  WHERE  a.organization_id = b.organization_id
  AND    a.carrier_id = c.carrier_id
  AND    c.manifesting_enabled_flag = 'Y'
  AND    b.carrier_manifesting_flag = 'Y'
  AND    a.delivery_id = c_delivery_id;

   -- count the number of deliveries which should not be rated due to manifesting
  CURSOR c_check_del_manifesting2(c_trip_id NUMBER)
  IS
  SELECT count(a.delivery_id)
  FROM   wsh_new_deliveries a,
	 mtl_parameters b,
	 wsh_carriers c
  WHERE  a.organization_id = b.organization_id
  AND    a.carrier_id = c.carrier_id
  AND    c.manifesting_enabled_flag = 'Y'
  AND    b.carrier_manifesting_flag = 'Y'
  AND    a.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id = c_trip_id
   	 AND   wts2.trip_id = c_trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);

   CURSOR c_cnt_trip_legs(c_trip_id NUMBER)
   IS
   SELECT count(wdl.delivery_leg_id)
   FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   WHERE wts1.trip_id = c_trip_id
   AND   wts2.trip_id = c_trip_id
   AND   wts1.stop_id = wdl.pick_up_stop_id
   AND   wts2.stop_id = wdl.drop_off_stop_id;

   CURSOR c_count_reprice_reqd(c_trip_id IN NUMBER) IS
   Select count(*)
   from   wsh_delivery_legs wdl, wsh_trip_stops wts1, wsh_trip_stops wts2,wsh_trips wt
   where  wdl.pick_up_stop_id    = wts1.stop_id
   and    wdl.drop_off_stop_id   = wts2.stop_id
   and    wdl.reprice_required = 'Y'
   and    wts1.trip_id           = wt.trip_id
   and    wts2.trip_id           = wt.trip_id
   and    wt.trip_id             = c_trip_id;

   TYPE pricing_engine_output_rec_type IS RECORD
                (output_index                                   NUMBER ,  -- Should be same as input index
                 -- input_index                                    NUMBER ,  --  One record per input index
                 priced_quantity                                NUMBER ,
                 priced_uom_code                                VARCHAR2(30), -- Do we need or should we
                                                                              -- return in input uom and currency
                 unit_price                                     NUMBER ,
                 adjusted_unit_price                            NUMBER ,
                 updated_adjusted_unit_price                    NUMBER,
                 line_unit_price                                NUMBER,
                 percent_price                                  NUMBER
                 );

   TYPE pricing_engine_output_tab_type IS TABLE OF pricing_engine_output_rec_type INDEX BY BINARY_INTEGER;

   TYPE dlvy_leg_summ_rec_type IS RECORD
                (entity_id                                  NUMBER ,
                 summary_amount                             NUMBER
                 );

   TYPE dlvy_leg_summ_tab_type IS TABLE OF dlvy_leg_summ_rec_type INDEX BY BINARY_INTEGER;

   TYPE basis_categ_rec_type IS RECORD
                (category_id                                    NUMBER ,
                 basis                                          NUMBER
                 );

   TYPE basis_categ_tab_type IS TABLE OF basis_categ_rec_type INDEX BY BINARY_INTEGER;

   TYPE instance_category_rec_type IS RECORD
                (category_id                                    NUMBER ,
                 instance_index                                 NUMBER
                 );

   TYPE instance_category_tab_type IS TABLE OF instance_category_rec_type INDEX BY BINARY_INTEGER;

   TYPE instance_basis_rec_type IS RECORD
                (basis                                          NUMBER ,
                 instance_index                                 NUMBER
                 );

   TYPE instance_basis_tab_type IS TABLE OF instance_basis_rec_type INDEX BY BINARY_INTEGER;

   TYPE instance_enginerow_rec_type IS RECORD
                (input_index                                    NUMBER ,
                 tot_amount                                     NUMBER
                 );

   TYPE instance_enginerow_tab_type IS TABLE OF instance_enginerow_rec_type INDEX BY BINARY_INTEGER;

   TYPE quantity_rec_type IS RECORD
                (quantity                                     NUMBER ,
                 uom                                          VARCHAR2(30)
                 );

   TYPE quantity_tab_type IS TABLE OF quantity_rec_type INDEX BY BINARY_INTEGER;

   TYPE quantity_basis_rec_type IS RECORD
                (basis                                        NUMBER ,
                 quantity                                     NUMBER ,
                 uom                                          VARCHAR2(30)
                 );

   TYPE quantity_basis_tab_type IS TABLE OF quantity_basis_rec_type INDEX BY BINARY_INTEGER;

   TYPE total_discount_rec_type IS RECORD
                (total_amount                                 NUMBER ,
                 discount_amount                              NUMBER
                 );

   TYPE total_discount_tab_type IS TABLE OF total_discount_rec_type INDEX BY BINARY_INTEGER;

   TYPE container_sum_rec_type IS RECORD
                (currency_code                                VARCHAR2(30),
                 total_amount                                 NUMBER ,
                 discount_amount                              NUMBER ,
                 delivery_id                                  NUMBER ,
                 delivery_leg_id                              NUMBER DEFAULT NULL,
                 bquantity                                    NUMBER DEFAULT NULL,
                 bbasis                                       NUMBER DEFAULT NULL,
                 buom                                         VARCHAR2(20) DEFAULT NULL
                 );

   TYPE container_sum_tab_type IS TABLE OF container_sum_rec_type INDEX BY BINARY_INTEGER;

   TYPE container_detail_rec_type IS RECORD
                (entity_id                                    NUMBER ,
                 detail_id                                    NUMBER
                 );

   TYPE container_detail_tab_type IS TABLE OF container_detail_rec_type INDEX BY BINARY_INTEGER;

   TYPE trip_info_rec IS RECORD
   (
          trip_id                         NUMBER,
          name                            VARCHAR2(30),
          planned_flag                    VARCHAR2(1),
          status_code                     VARCHAR2(2),
          carrier_id                      NUMBER,
          ship_method_code                VARCHAR2(30),
          service_level                   VARCHAR2(30),
          mode_of_transport               VARCHAR2(30),
          consolidation_allowed           VARCHAR2(1),
          lane_id                         NUMBER,
          schedule_id                     NUMBER,
          load_tender_status              wsh_trips.load_tender_status%TYPE
    );

-- Private APIs

PROCEDURE Get_Basis_Meaning ( p_basis           IN NUMBER,
                              x_basis_meaning   OUT NOCOPY VARCHAR2
                             )
IS

BEGIN
     IF p_basis = G_CONTAINER_BASIS THEN
        x_basis_meaning := 'CONTAINER';
     ELSIF p_basis = G_WEIGHT_BASIS THEN
        x_basis_meaning := 'WEIGHT';
     ELSIF p_basis = G_VOLUME_BASIS THEN
        x_basis_meaning := 'VOLUME';
     END IF;
END Get_Basis_Meaning;

PROCEDURE MDC_Get_child_fraction(
	p_consol_LPN_children IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child detail id, value of parent consol detail id
	x_fraction  OUT NOCOPY DBMS_UTILITY.NUMBER_ARRAY,
	x_return_status           OUT NOCOPY     VARCHAR2) IS

i	NUMBER;
l_uom VARCHAR2(30);
l_weight NUMBER;
l_parent_detail_id NUMBER;
l_detail_weight DBMS_UTILITY.NUMBER_ARRAY;
l_total_lpn_weight DBMS_UTILITY.NUMBER_ARRAY;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'MDC_Get_child_fraction','start');


	--Gather sum of all children weight in l_total_lpn_weight

	l_uom:=NULL;
	i:=p_consol_LPN_children.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		l_detail_weight(i):=0;
		IF((g_shipment_line_rows(i).gross_weight IS NOT NULL)
		AND (g_shipment_line_rows(i).weight_uom_code IS NOT NULL)
		)
		THEN
			IF(l_uom IS NULL)
			THEN
				l_uom:=g_shipment_line_rows(i).weight_uom_code;
			END IF;

			IF (l_uom <> g_shipment_line_rows(i).weight_uom_code)
			THEN

				l_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					g_shipment_line_rows(i).weight_uom_code,
					l_uom,
					g_shipment_line_rows(i).gross_weight,
					0);
				IF (l_weight IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;
				END IF;


			ELSE
				l_weight:=g_shipment_line_rows(i).gross_weight;

			END IF;
			l_detail_weight(i):=l_weight;
			IF (l_total_lpn_weight.EXISTS(p_consol_LPN_children(i)))
			THEN
				l_total_lpn_weight(p_consol_LPN_children(i)):=
					l_total_lpn_weight(p_consol_LPN_children(i))+l_weight;
			ELSE
				l_total_lpn_weight(p_consol_LPN_children(i)):=l_weight;
			END IF;



		END IF;


		i:=p_consol_LPN_children.NEXT(i);
	END LOOP;

	--Determine fraction

	i:=p_consol_LPN_children.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		x_fraction(i):=0;
		l_parent_detail_id:=p_consol_LPN_children(i);
		IF ((l_total_lpn_weight.EXISTS(l_parent_detail_id) )
		AND (l_total_lpn_weight(l_parent_detail_id)>0))
		THEN
			x_fraction(i):=l_detail_weight(i)/l_total_lpn_weight(l_parent_detail_id);

		END IF;

		i:=p_consol_LPN_children.NEXT(i);
	END LOOP;


	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Get_child_fraction');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Get_child_fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Get_child_fraction');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Get_child_fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Get_child_fraction');

END MDC_Get_child_fraction;

PROCEDURE MDC_Get_LPN_Cost_rec(
	p_consol_LPNs IN DBMS_UTILITY.NUMBER_ARRAY,
	p_freight_cost_main_tab IN Freight_Cost_Main_Tab_Type,
	p_freight_cost_temp_tab IN Freight_Cost_Temp_Tab_Type,
	x_ref OUT NOCOPY DBMS_UTILITY.NUMBER_ARRAY,
	x_return_status           OUT NOCOPY     VARCHAR2) IS

i	NUMBER;
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'MDC_Get_LPN_Cost_rec','start');

	i:=p_freight_cost_main_tab.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		IF((p_freight_cost_main_tab(i).delivery_detail_id IS NOT NULL)
		AND (p_freight_cost_main_tab(i).line_type_code IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(p_freight_cost_main_tab(i).delivery_detail_id)))
		THEN
			x_ref(p_freight_cost_main_tab(i).delivery_detail_id):=i;

		END IF;

		i:=p_freight_cost_main_tab.NEXT(i);
	END LOOP;

	i:=p_freight_cost_temp_tab.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		IF((p_freight_cost_temp_tab(i).delivery_detail_id IS NOT NULL)
		AND (p_freight_cost_temp_tab(i).line_type_code IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(p_freight_cost_temp_tab(i).delivery_detail_id)))
		THEN
			x_ref(p_freight_cost_temp_tab(i).delivery_detail_id):=i;

		END IF;

		i:=p_freight_cost_temp_tab.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Get_LPN_Cost_rec');

EXCEPTION

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Get_LPN_Cost_rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Get_LPN_Cost_rec');


END MDC_Get_LPN_Cost_rec;

PROCEDURE MDC_Alloc_From_consol_LPN(
	p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
	p_consol_LPNs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by consol LPN detail id
	p_consol_LPN_children IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child detail id, value of parent consol detail id
        x_freight_cost_main_price IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
        x_freight_cost_main_charge IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
	x_return_status           OUT NOCOPY     VARCHAR2) IS
i	NUMBER;
j	NUMBER;
n	NUMBER;
l_temp NUMBER;
l_price_ref	DBMS_UTILITY.NUMBER_ARRAY;


l_fractions	DBMS_UTILITY.NUMBER_ARRAY;
l_dtl_fraction NUMBER;
l_LPN_rec_index NUMBER;

l_child_dtl_temp_rec Freight_Cost_temp_Rec_Type;
l_child_dtl_main_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_LPN_main_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_LPN_temp_rec Freight_Cost_Temp_Rec_Type;

l_freight_cost_type_id NUMBER;

l_return_status VARCHAR2(1);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'MDC_Alloc_From_consol_LPN','start');



	--Get LPN Summary records locations
	MDC_Get_LPN_Cost_rec(
		p_consol_LPNs=>p_consol_LPNs,
		p_freight_cost_main_tab=>x_freight_cost_main_price,
		p_freight_cost_temp_tab=>x_freight_cost_temp_price,
		x_ref=>l_price_ref,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_Get_LPN_cost_rec_fail;
	       END IF;
	END IF;



	MDC_Get_child_fraction(
		p_consol_LPN_children=>p_consol_LPN_children,--Indexed by child detail id, value of parent consol detail id
		x_fraction=>l_fractions,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_get_chld_fract_fail;
	       END IF;
	END IF;



	--Price records


	i:=p_consol_LPN_children.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		l_dtl_fraction:=l_fractions(i);

		l_LPN_rec_index:=l_price_ref(p_consol_LPN_children(i));

		IF(p_save_flag='M')
		THEN

			l_LPN_main_rec:=x_freight_cost_main_price(l_LPN_rec_index);
			l_child_dtl_main_rec:=l_LPN_main_rec;
			l_child_dtl_main_rec.delivery_id:=g_shipment_line_rows(i).delivery_id;
			l_child_dtl_main_rec.delivery_leg_id:=g_shipment_line_rows(i).delivery_leg_id;
			l_child_dtl_main_rec.delivery_detail_id:=i;
			l_child_dtl_main_rec.total_amount:=l_dtl_fraction*l_child_dtl_main_rec.total_amount;
			l_child_dtl_main_rec.unit_amount:=l_dtl_fraction*l_child_dtl_main_rec.unit_amount;
			l_child_dtl_main_rec.quantity:=l_dtl_fraction*l_child_dtl_main_rec.quantity;
			l_child_dtl_main_rec.billable_quantity:=l_dtl_fraction*l_child_dtl_main_rec.billable_quantity;
			l_child_dtl_main_rec.line_type_code:='PRICE';
			x_freight_cost_main_price(x_freight_cost_main_price.LAST+1):=l_child_dtl_main_rec;


		--ELSIF(p_save_flag='T')
		ELSE -- P or T
		--THEN

			l_LPN_temp_rec:=x_freight_cost_temp_price(l_LPN_rec_index);

			l_child_dtl_temp_rec:=l_LPN_temp_rec;

			l_child_dtl_temp_rec.delivery_id:=g_shipment_line_rows(i).delivery_id;

			l_child_dtl_temp_rec.delivery_leg_id:=g_shipment_line_rows(i).delivery_leg_id;
			l_child_dtl_temp_rec.delivery_detail_id:=i;
			l_child_dtl_temp_rec.total_amount:=l_dtl_fraction*l_child_dtl_temp_rec.total_amount;
			l_child_dtl_temp_rec.unit_amount:=l_dtl_fraction*l_child_dtl_temp_rec.unit_amount;
			l_child_dtl_temp_rec.quantity:=l_dtl_fraction*l_child_dtl_temp_rec.quantity;
			l_child_dtl_temp_rec.billable_quantity:=l_dtl_fraction*l_child_dtl_temp_rec.billable_quantity;
			l_child_dtl_temp_rec.line_type_code:='PRICE';

			x_freight_cost_temp_price(x_freight_cost_temp_price.LAST+1):=l_child_dtl_temp_rec;



		END IF;




		i:=p_consol_LPN_children.NEXT(i);
	END LOOP;


	--Charge records



	i:=x_freight_cost_main_charge.FIRST;
	n:=x_freight_cost_main_charge.LAST;
	WHILE((i IS NOT NULL) AND (i<= n) )
	LOOP


		IF ((x_freight_cost_main_charge(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(x_freight_cost_main_charge(i).delivery_detail_id)))
		THEN
			j:=p_consol_LPN_children.FIRST;
			WHILE(j IS NOT NULL)
			LOOP
				IF(p_consol_LPN_children(j)=x_freight_cost_main_charge(i).delivery_detail_id)
				THEN

					l_dtl_fraction:=l_fractions(j);

					l_child_dtl_main_rec:=x_freight_cost_main_charge(i);
					l_child_dtl_main_rec.delivery_id:=g_shipment_line_rows(j).delivery_id;
					l_child_dtl_main_rec.delivery_leg_id:=g_shipment_line_rows(j).delivery_leg_id;
					l_child_dtl_main_rec.delivery_detail_id:=j;
					l_child_dtl_main_rec.total_amount:=l_dtl_fraction*l_child_dtl_main_rec.total_amount;
					l_child_dtl_main_rec.unit_amount:=l_dtl_fraction*l_child_dtl_main_rec.unit_amount;
					l_child_dtl_main_rec.quantity:=l_dtl_fraction*l_child_dtl_main_rec.quantity;
					l_child_dtl_main_rec.billable_quantity:=l_dtl_fraction*l_child_dtl_main_rec.billable_quantity;
					x_freight_cost_main_charge(x_freight_cost_main_charge.LAST+1):=l_child_dtl_main_rec;



				END IF;

				j:=p_consol_LPN_children.NEXT(j);

			END LOOP;
			--Delete this charge for the consol LPN
			x_freight_cost_main_charge.DELETE(i);

		END IF;

		i:=x_freight_cost_main_charge.NEXT(i);
	END LOOP;





	i:=x_freight_cost_temp_charge.FIRST;
	n:=x_freight_cost_temp_charge.LAST;
	WHILE((i IS NOT NULL) AND (i<= n) )
	LOOP
		IF ((x_freight_cost_temp_charge(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(x_freight_cost_temp_charge(i).delivery_detail_id)))
		THEN
			j:=p_consol_LPN_children.FIRST;
			WHILE(j IS NOT NULL)
			LOOP
				IF(p_consol_LPN_children(j)=x_freight_cost_temp_charge(i).delivery_detail_id)
				THEN

					l_dtl_fraction:=l_fractions(j);

					l_child_dtl_temp_rec:=x_freight_cost_temp_charge(i);
					l_child_dtl_temp_rec.delivery_id:=g_shipment_line_rows(j).delivery_id;
					l_child_dtl_temp_rec.delivery_leg_id:=g_shipment_line_rows(j).delivery_leg_id;
					l_child_dtl_temp_rec.delivery_detail_id:=j;
					l_child_dtl_temp_rec.total_amount:=l_dtl_fraction*l_child_dtl_temp_rec.total_amount;
					l_child_dtl_temp_rec.unit_amount:=l_dtl_fraction*l_child_dtl_temp_rec.unit_amount;
					l_child_dtl_temp_rec.quantity:=l_dtl_fraction*l_child_dtl_temp_rec.quantity;
					l_child_dtl_temp_rec.billable_quantity:=l_dtl_fraction*l_child_dtl_temp_rec.billable_quantity;
					x_freight_cost_temp_charge(x_freight_cost_temp_charge.LAST+1):=l_child_dtl_temp_rec;



				END IF;

				j:=p_consol_LPN_children.NEXT(j);

			END LOOP;
			--Delete this charge for the consol LPN
			x_freight_cost_temp_charge.DELETE(i);

		END IF;

		i:=x_freight_cost_temp_charge.NEXT(i);
	END LOOP;









	get_fc_type_id(
	   p_line_type_code => 'FTESUMMARY',
	   p_charge_subtype_code  => 'SUMMARY',
	   x_freight_cost_type_id  =>  l_freight_cost_type_id,
	   x_return_status  =>  l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
		END IF;
	ELSE
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
	END IF;



	--Alter PRICE to SUMMARY for consol LPNs

	i:=l_price_ref.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF(p_save_flag='M')
		THEN

			x_freight_cost_main_price(l_price_ref(i)).line_type_code:='SUMMARY';

			x_freight_cost_main_price(l_price_ref(i)).freight_cost_type_id:=l_freight_cost_type_id;
		ELSE--(p_save_flag='T') or P
		--THEN
			x_freight_cost_temp_price(l_price_ref(i)).line_type_code:='SUMMARY';

			x_freight_cost_temp_price(l_price_ref(i)).freight_cost_type_id:=l_freight_cost_type_id;


		END IF;

		i:=l_price_ref.NEXT(i);
	END LOOP;


	--Remove gaps in x_freight_cost_main_charge

	i:=x_freight_cost_main_charge.FIRST;
	j:=i;
	WHILE(i IS NOT NULL)
	LOOP
		IF(j <> i)
		THEN
			x_freight_cost_main_charge(j):=x_freight_cost_main_charge(i);

		END IF;


		j:=j+1;
		i:=x_freight_cost_main_charge.NEXT(i);
	END LOOP;


	--Remove gaps in x_freight_cost_temp_charge

	i:=x_freight_cost_temp_charge.FIRST;
	j:=i;
	WHILE(i IS NOT NULL)
	LOOP
		IF(j <> i)
		THEN
			x_freight_cost_temp_charge(j):=x_freight_cost_temp_charge(i);

		END IF;


		j:=j+1;
		i:=x_freight_cost_temp_charge.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Alloc_From_consol_LPN');

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_Get_LPN_cost_rec_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Alloc_From_consol_LPN',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_Get_LPN_cost_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Alloc_From_consol_LPN');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_get_chld_fract_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Alloc_From_consol_LPN',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_get_chld_fract_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Alloc_From_consol_LPN');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Alloc_From_consol_LPN',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Alloc_From_consol_LPN');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Alloc_From_consol_LPN',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Alloc_From_consol_LPN');



END MDC_Alloc_From_consol_LPN;


PROCEDURE Create_Parent_Dleg_Summaries(
	p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
	p_parent_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by parent dleg id
	p_child_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child dleg id, value of parent dleg id
	p_dleg_to_delivery IN DBMS_UTILITY.NUMBER_ARRAY,
        x_freight_cost_main_price IN OUT NOCOPY Freight_Cost_main_Tab_Type,
        x_freight_cost_temp_price IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
	x_return_status           OUT NOCOPY     VARCHAR2) IS
i	NUMBER;
l_parent_dleg_summaries DBMS_UTILITY.NUMBER_ARRAY;
l_existing_dlegs DBMS_UTILITY.NUMBER_ARRAY;
l_freight_cost_temp_price Freight_Cost_temp_Rec_Type;
l_freight_cost_main_price WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_return_status VARCHAR2(1);
l_index NUMBER;
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Parent_Dleg_Summaries','start');




	i:=x_freight_cost_main_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		IF ((x_freight_cost_main_price(i).delivery_leg_id IS NOT NULL)
		AND (x_freight_cost_main_price(i).delivery_detail_id IS NULL)
		AND (p_child_dlegs.EXISTS(x_freight_cost_main_price(i).delivery_leg_id)))
		THEN


			IF(l_parent_dleg_summaries.EXISTS(p_child_dlegs(x_freight_cost_main_price(i).delivery_leg_id)))
			THEN

				l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_main_price(i).delivery_leg_id)):=
				 l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_main_price(i).delivery_leg_id))
				 +x_freight_cost_main_price(i).total_amount;
			ELSE

				l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_main_price(i).delivery_leg_id)):=
				 x_freight_cost_main_price(i).total_amount;

				l_freight_cost_main_price:=x_freight_cost_main_price(i);
			END IF;

		END IF;

		IF ((x_freight_cost_main_price(i).delivery_leg_id IS NOT NULL)
		AND (x_freight_cost_main_price(i).delivery_detail_id IS NULL)
		AND (p_parent_dlegs.EXISTS(x_freight_cost_main_price(i).delivery_leg_id)))
		THEN

			l_existing_dlegs(x_freight_cost_main_price(i).delivery_leg_id):=i;

		END IF;

		i:=x_freight_cost_main_price.NEXT(i);
	END LOOP;


	i:=x_freight_cost_temp_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		IF ((x_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND (x_freight_cost_temp_price(i).delivery_detail_id IS NULL)
		AND (p_child_dlegs.EXISTS(x_freight_cost_temp_price(i).delivery_leg_id)))
		THEN

			IF(l_parent_dleg_summaries.EXISTS(p_child_dlegs(x_freight_cost_temp_price(i).delivery_leg_id)))
			THEN

				l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_temp_price(i).delivery_leg_id)):=
				 l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_temp_price(i).delivery_leg_id))
				 +x_freight_cost_temp_price(i).total_amount;
			ELSE

				l_parent_dleg_summaries(p_child_dlegs(x_freight_cost_temp_price(i).delivery_leg_id)):=
				 x_freight_cost_temp_price(i).total_amount;

				l_freight_cost_temp_price:=x_freight_cost_temp_price(i);
			END IF;

		END IF;


		IF ((x_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND (x_freight_cost_temp_price(i).delivery_detail_id IS NULL)
		AND (p_parent_dlegs.EXISTS(x_freight_cost_temp_price(i).delivery_leg_id)))
		THEN

			l_existing_dlegs(x_freight_cost_temp_price(i).delivery_leg_id):=i;
		END IF;

		i:=x_freight_cost_temp_price.NEXT(i);
	END LOOP;


	i:=l_parent_dleg_summaries.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		IF  ( l_existing_dlegs.EXISTS(i))
		THEN

			IF(p_save_flag='M')
			THEN
				x_freight_cost_main_price(l_existing_dlegs(i)).total_amount:=l_parent_dleg_summaries(i);
				x_freight_cost_main_price(l_existing_dlegs(i)).unit_amount:=l_parent_dleg_summaries(i);
			ELSE--(p_save_flag='T')
			--THEN
				x_freight_cost_temp_price(l_existing_dlegs(i)).total_amount:=l_parent_dleg_summaries(i);
				x_freight_cost_temp_price(l_existing_dlegs(i)).unit_amount:=l_parent_dleg_summaries(i);
			END IF;


		ELSE


			IF(p_save_flag='M')
			THEN

				--get fc id for dleg
				l_freight_cost_main_price.freight_cost_id:=FTE_FREIGHT_PRICING.get_fc_id_from_dleg(i);

				l_freight_cost_main_price.delivery_leg_id:=i;

				l_freight_cost_main_price.delivery_id:=p_dleg_to_delivery(i);

				l_freight_cost_main_price.total_amount:=l_parent_dleg_summaries(i);
				l_freight_cost_main_price.unit_amount:=l_parent_dleg_summaries(i);

				x_freight_cost_main_price(x_freight_cost_main_price.LAST+1):=l_freight_cost_main_price;


			ELSE--(p_save_flag='T') or P
			--THEN

				l_freight_cost_temp_price.delivery_leg_id:=i;

				l_freight_cost_temp_price.delivery_id:=p_dleg_to_delivery(i);

				l_freight_cost_temp_price.total_amount:=l_parent_dleg_summaries(i);
				l_freight_cost_temp_price.unit_amount:=l_parent_dleg_summaries(i);

				l_index:=x_freight_cost_temp_price.LAST+1;
				x_freight_cost_temp_price(l_index):=l_freight_cost_temp_price;


			END IF;

		END IF;
		i:=l_parent_dleg_summaries.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Parent_Dleg_Summaries');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Parent_Dleg_Summaries',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Parent_Dleg_Summaries');

END Create_Parent_Dleg_Summaries;


PROCEDURE Create_Child_Dleg_Summaries(
	p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
	p_dleg_to_delivery IN DBMS_UTILITY.NUMBER_ARRAY,
	p_parent_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by parent dleg id
	p_child_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child dleg id, value of parent dleg id
        x_freight_cost_main_price IN OUT NOCOPY Freight_Cost_main_Tab_Type,
        x_fc_main_update_rows IN OUT NOCOPY Freight_Cost_main_Tab_Type,
        x_freight_cost_temp_price IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
	x_return_status           OUT NOCOPY     VARCHAR2) IS

l_child_dleg_summaries DBMS_UTILITY.NUMBER_ARRAY;
l_existing_dlegs DBMS_UTILITY.NUMBER_ARRAY;
i	NUMBER;
l_freight_cost_main_price WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_cost_temp_price Freight_Cost_Temp_Rec_Type;
l_freight_cost_type_id NUMBER;
l_return_status VARCHAR2(1);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Child_Dleg_Summaries','start');



	i:=x_freight_cost_main_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF((x_freight_cost_main_price(i).delivery_detail_id IS NOT NULL)
		AND (x_freight_cost_main_price(i).line_type_code ='PRICE')
		AND (x_freight_cost_main_price(i).delivery_leg_id IS NOT NULL)
		AND(p_child_dlegs.EXISTS(x_freight_cost_main_price(i).delivery_leg_id)))
		THEN

			l_freight_cost_main_price:=x_freight_cost_main_price(i);

			IF(l_child_dleg_summaries.EXISTS(x_freight_cost_main_price(i).delivery_leg_id))
			THEN
				l_child_dleg_summaries(x_freight_cost_main_price(i).delivery_leg_id):=
				 l_child_dleg_summaries(x_freight_cost_main_price(i).delivery_leg_id)
				 +x_freight_cost_main_price(i).total_amount;
			ELSE
				l_child_dleg_summaries(x_freight_cost_main_price(i).delivery_leg_id):=
				 x_freight_cost_main_price(i).total_amount;

			END IF;

		END IF;

		IF((x_freight_cost_main_price(i).delivery_detail_id IS NULL)
		AND (x_freight_cost_main_price(i).line_type_code ='SUMMARY')
		AND (x_freight_cost_main_price(i).delivery_leg_id IS NOT NULL)
		AND(p_child_dlegs.EXISTS(x_freight_cost_main_price(i).delivery_leg_id)))
		THEN
			l_existing_dlegs(x_freight_cost_main_price(i).delivery_leg_id):=i;

		END IF;

		i:=x_freight_cost_main_price.NEXT(i);
	END LOOP;



	i:=x_freight_cost_temp_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF((x_freight_cost_temp_price(i).delivery_detail_id IS NOT NULL)
		AND (x_freight_cost_temp_price(i).line_type_code ='PRICE')
		AND (x_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND(p_child_dlegs.EXISTS(x_freight_cost_temp_price(i).delivery_leg_id)))
		THEN

			l_freight_cost_temp_price:=x_freight_cost_temp_price(i);
			IF(l_child_dleg_summaries.EXISTS(x_freight_cost_temp_price(i).delivery_leg_id))
			THEN
				l_child_dleg_summaries(x_freight_cost_temp_price(i).delivery_leg_id):=
				 l_child_dleg_summaries(x_freight_cost_temp_price(i).delivery_leg_id)
				 +x_freight_cost_temp_price(i).total_amount;
			ELSE
				l_child_dleg_summaries(x_freight_cost_temp_price(i).delivery_leg_id):=
				 x_freight_cost_temp_price(i).total_amount;

			END IF;

		END IF;


		IF((x_freight_cost_temp_price(i).delivery_detail_id IS  NULL)
		AND (x_freight_cost_temp_price(i).line_type_code ='SUMMARY')
		AND (x_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND(p_child_dlegs.EXISTS(x_freight_cost_temp_price(i).delivery_leg_id)))
		THEN

			l_existing_dlegs(x_freight_cost_temp_price(i).delivery_leg_id):=i;
		END IF;

		i:=x_freight_cost_temp_price.NEXT(i);
	END LOOP;



	get_fc_type_id(
	   p_line_type_code => 'FTESUMMARY',
	   p_charge_subtype_code  => 'SUMMARY',
	   x_freight_cost_type_id  =>  l_freight_cost_type_id,
	   x_return_status  =>  l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
		END IF;
	ELSE
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
	END IF;

	l_freight_cost_main_price.freight_cost_type_id:=l_freight_cost_type_id;
	l_freight_cost_main_price.line_type_code:='SUMMARY';
	l_freight_cost_main_price.delivery_detail_id:=NULL;
	l_freight_cost_main_price.quantity:=NULL;
	l_freight_cost_main_price.uom:=NULL;
	l_freight_cost_main_price.billable_basis:=NULL;
	l_freight_cost_main_price.billable_quantity:=NULL;
	l_freight_cost_main_price.billable_uom:=NULL;
	l_freight_cost_main_price.charge_unit_value:=NULL;

	l_freight_cost_temp_price.freight_cost_type_id:=l_freight_cost_type_id;
	l_freight_cost_temp_price.line_type_code:='SUMMARY';
	l_freight_cost_temp_price.delivery_detail_id:=NULL;
	l_freight_cost_temp_price.quantity:=NULL;
	l_freight_cost_temp_price.uom:=NULL;
	l_freight_cost_temp_price.billable_basis:=NULL;
	l_freight_cost_temp_price.billable_quantity:=NULL;
	l_freight_cost_temp_price.billable_uom:=NULL;
	l_freight_cost_temp_price.charge_unit_value:=NULL;


	i:=l_child_dleg_summaries.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		--Some dlegs may already have summaries created
		--over write their amounts
		IF  ( l_existing_dlegs.EXISTS(i))
		THEN

			IF(p_save_flag='M')
			THEN
				x_fc_main_update_rows(l_existing_dlegs(i)).total_amount:=l_child_dleg_summaries(i);
				x_fc_main_update_rows(l_existing_dlegs(i)).unit_amount:=l_child_dleg_summaries(i);
			ELSE--(p_save_flag='T') or P
			--THEN
				x_freight_cost_temp_price(l_existing_dlegs(i)).total_amount:=l_child_dleg_summaries(i);
				x_freight_cost_temp_price(l_existing_dlegs(i)).unit_amount:=l_child_dleg_summaries(i);
			END IF;


		ELSE
			IF(p_save_flag='M')
			THEN


				l_freight_cost_main_price.freight_cost_id:=FTE_FREIGHT_PRICING.get_fc_id_from_dleg(i);


				l_freight_cost_main_price.total_amount:=l_child_dleg_summaries(i);
				l_freight_cost_main_price.unit_amount:=l_child_dleg_summaries(i);
				l_freight_cost_main_price.delivery_leg_id:=i;
				l_freight_cost_main_price.delivery_id:=p_dleg_to_delivery(i);

				x_fc_main_update_rows(x_fc_main_update_rows.LAST+1):=l_freight_cost_main_price;

			ELSE--IF(p_save_flag='T') or P
			--THEN

				l_freight_cost_temp_price.total_amount:=l_child_dleg_summaries(i);
				l_freight_cost_temp_price.unit_amount:=l_child_dleg_summaries(i);
				l_freight_cost_temp_price.delivery_leg_id:=i;
				l_freight_cost_temp_price.delivery_id:=p_dleg_to_delivery(i);

				x_freight_cost_temp_price(x_freight_cost_temp_price.LAST+1):=l_freight_cost_temp_price;


			END IF;

		END IF;

		i:=l_child_dleg_summaries.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Child_Dleg_Summaries');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Child_Dleg_Summaries',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Child_Dleg_Summaries');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Child_Dleg_Summaries',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Child_Dleg_Summaries');


END Create_Child_Dleg_Summaries;


PROCEDURE Populate_Dleg_Id(
	p_delivery_to_dleg IN DBMS_UTILITY.NUMBER_ARRAY,
	x_freight_cost_temp  IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
	x_return_status           OUT NOCOPY     VARCHAR2 ) IS

i	NUMBER;
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Populate_Dleg_Id','start');


	i:=x_freight_cost_temp.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		IF((x_freight_cost_temp(i).delivery_id IS NOT NULL)
		AND (x_freight_cost_temp(i).delivery_leg_id IS NULL)
		AND(p_delivery_to_dleg.EXISTS(x_freight_cost_temp(i).delivery_id)))
		THEN

			x_freight_cost_temp(i).delivery_leg_id:=
				p_delivery_to_dleg(x_freight_cost_temp(i).delivery_id);

		END IF;

		i:=x_freight_cost_temp.NEXT(i);
	END LOOP;
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_Dleg_Id');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Populate_Dleg_Id',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_Dleg_Id');


END Populate_Dleg_Id;

PROCEDURE Create_LPN_Summary(
	p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
	p_consol_LPN_children IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child detail id, value of parent consol detail id
        x_freight_cost_main_price IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
        x_freight_cost_main_charge IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge IN OUT NOCOPY Freight_Cost_temp_Tab_Type,
	x_return_status           OUT NOCOPY     VARCHAR2) IS

i	NUMBER;
l_LPN_summaries DBMS_UTILITY.NUMBER_ARRAY;
l_existing_LPN DBMS_UTILITY.NUMBER_ARRAY;--If it is required to update existing LPN summaries
l_freight_cost_main_price WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_cost_temp_price Freight_Cost_temp_Rec_Type;
l_freight_cost_type_id NUMBER;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_LPN_Summary','start');


	i:=x_freight_cost_main_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF ((x_freight_cost_main_price(i).delivery_detail_id IS NOT NULL)
		AND(x_freight_cost_main_price(i).line_type_code='PRICE')
		AND (p_consol_LPN_children.EXISTS(x_freight_cost_main_price(i).delivery_detail_id)))
		THEN

			IF(l_LPN_summaries.EXISTS(p_consol_LPN_children(x_freight_cost_main_price(i).delivery_detail_id)))
			THEN
				l_LPN_summaries(p_consol_LPN_children(x_freight_cost_main_price(i).delivery_detail_id)):=
				 l_LPN_summaries(p_consol_LPN_children(x_freight_cost_main_price(i).delivery_detail_id))
				 +x_freight_cost_main_price(i).total_amount;
			ELSE

				l_LPN_summaries(p_consol_LPN_children(x_freight_cost_main_price(i).delivery_detail_id)):=
				 x_freight_cost_main_price(i).total_amount;

				l_freight_cost_main_price:=x_freight_cost_main_price(i);
			END IF;

		END IF;

		i:=x_freight_cost_main_price.NEXT(i);
	END LOOP;


	i:=x_freight_cost_temp_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF ((x_freight_cost_temp_price(i).delivery_detail_id IS NOT NULL)
		AND(x_freight_cost_temp_price(i).line_type_code='PRICE')
		AND (p_consol_LPN_children.EXISTS(x_freight_cost_temp_price(i).delivery_detail_id)))
		THEN

			IF(l_LPN_summaries.EXISTS(p_consol_LPN_children(x_freight_cost_temp_price(i).delivery_detail_id)))
			THEN
				l_LPN_summaries(p_consol_LPN_children(x_freight_cost_temp_price(i).delivery_detail_id)):=
				 l_LPN_summaries(p_consol_LPN_children(x_freight_cost_temp_price(i).delivery_detail_id))
				 +x_freight_cost_temp_price(i).total_amount;
			ELSE

				l_LPN_summaries(p_consol_LPN_children(x_freight_cost_temp_price(i).delivery_detail_id)):=
				 x_freight_cost_temp_price(i).total_amount;

				l_freight_cost_temp_price:=x_freight_cost_temp_price(i);
			END IF;

		END IF;

		i:=x_freight_cost_temp_price.NEXT(i);
	END LOOP;


	get_fc_type_id(
	   p_line_type_code => 'FTESUMMARY',
	   p_charge_subtype_code  => 'SUMMARY',
	   x_freight_cost_type_id  =>  l_freight_cost_type_id,
	   x_return_status  =>  l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
		END IF;
	ELSE
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
	END IF;

	l_freight_cost_main_price.freight_cost_type_id:=l_freight_cost_type_id;
	l_freight_cost_main_price.line_type_code:='SUMMARY';
	l_freight_cost_main_price.delivery_detail_id:=NULL;
	l_freight_cost_main_price.quantity:=NULL;
	l_freight_cost_main_price.uom:=NULL;
	l_freight_cost_main_price.billable_basis:=NULL;
	l_freight_cost_main_price.billable_quantity:=NULL;
	l_freight_cost_main_price.billable_uom:=NULL;
	l_freight_cost_main_price.charge_unit_value:=NULL;

	l_freight_cost_temp_price.freight_cost_type_id:=l_freight_cost_type_id;
	l_freight_cost_temp_price.line_type_code:='SUMMARY';
	l_freight_cost_temp_price.delivery_detail_id:=NULL;
	l_freight_cost_temp_price.quantity:=NULL;
	l_freight_cost_temp_price.uom:=NULL;
	l_freight_cost_temp_price.billable_basis:=NULL;
	l_freight_cost_temp_price.billable_quantity:=NULL;
	l_freight_cost_temp_price.billable_uom:=NULL;
	l_freight_cost_temp_price.charge_unit_value:=NULL;



	i:=l_LPN_summaries.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF(p_save_flag='M')
		THEN

			l_freight_cost_main_price.delivery_detail_id:=i;
			l_freight_cost_main_price.delivery_id:=g_shipment_line_rows(i).delivery_id;
			l_freight_cost_main_price.delivery_leg_id:=g_shipment_line_rows(i).delivery_leg_id;

			l_freight_cost_main_price.total_amount:=l_LPN_summaries(i);
			l_freight_cost_main_price.unit_amount:=l_LPN_summaries(i);
			x_freight_cost_main_price(x_freight_cost_main_price.LAST+1):=l_freight_cost_main_price;


		ELSE--(p_save_flag='T') or P
		--THEN
			l_freight_cost_temp_price.delivery_detail_id:=i;
			l_freight_cost_temp_price.delivery_id:=g_shipment_line_rows(i).delivery_id;
			l_freight_cost_temp_price.delivery_leg_id:=g_shipment_line_rows(i).delivery_leg_id;

			l_freight_cost_temp_price.total_amount:=l_LPN_summaries(i);
			l_freight_cost_temp_price.unit_amount:=l_LPN_summaries(i);
			x_freight_cost_temp_price(x_freight_cost_temp_price.LAST+1):=l_freight_cost_temp_price;

		END IF;

		i:=l_LPN_summaries.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_LPN_Summary');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_LPN_Summary',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_LPN_Summary');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_LPN_Summary',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_LPN_Summary');


END Create_LPN_Summary;

PROCEDURE MDC_Check_Rated(
	p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
	p_consol_LPNs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by consol LPN detail id
	p_consol_LPN_children IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child detail id, value of parent consol detail id
	p_parent_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by parent dleg id
	p_child_dlegs IN DBMS_UTILITY.NUMBER_ARRAY,--Indexed by child dleg id, value of parent dleg id
	p_freight_cost_main_price IN Freight_Cost_Main_Tab_Type,
	p_freight_cost_temp_price  IN Freight_Cost_Temp_Tab_Type,
	p_fc_main_update_rows     IN Freight_Cost_Main_Tab_Type,  -- For update of SUMMARY records
	x_child_details_rated	OUT NOCOPY	VARCHAR2,
	x_consol_LPNs_rated	OUT NOCOPY	VARCHAR2,
	x_child_dlegs_rated	OUT NOCOPY	VARCHAR2,
	x_parent_dlegs_rated	OUT NOCOPY	VARCHAR2,
        x_return_status	OUT NOCOPY	VARCHAR2) IS


l_child_detail_rated DBMS_UTILITY.NUMBER_ARRAY;
l_consol_LPN_rated DBMS_UTILITY.NUMBER_ARRAY;
l_child_dlegs_rated DBMS_UTILITY.NUMBER_ARRAY;
l_parent_dlegs_rated DBMS_UTILITY.NUMBER_ARRAY;
i NUMBER;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'MDC_Check_Rated','start');


	l_child_detail_rated.DELETE;
	l_consol_LPN_rated.DELETE;

	l_child_dlegs_rated.DELETE;
	l_parent_dlegs_rated.DELETE;


	x_child_details_rated:='N';
	x_consol_LPNs_rated:='N';
	x_child_dlegs_rated:='N';
	x_parent_dlegs_rated:='N';


	i:=p_freight_cost_main_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF ((p_freight_cost_main_price(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPN_children.EXISTS(p_freight_cost_main_price(i).delivery_detail_id)))
		THEN
			l_child_detail_rated(p_freight_cost_main_price(i).delivery_detail_id):=1;

		END IF;

		IF ((p_freight_cost_main_price(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(p_freight_cost_main_price(i).delivery_detail_id)))
		THEN
			l_consol_LPN_rated(p_freight_cost_main_price(i).delivery_detail_id):=1;

		END IF;


		i:=p_freight_cost_main_price.NEXT(i);
	END LOOP;


	i:=p_freight_cost_temp_price.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF ((p_freight_cost_temp_price(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPN_children.EXISTS(p_freight_cost_temp_price(i).delivery_detail_id)))
		THEN
			l_child_detail_rated(p_freight_cost_temp_price(i).delivery_detail_id):=1;

		END IF;

		IF ((p_freight_cost_temp_price(i).delivery_detail_id IS NOT NULL)
		AND (p_consol_LPNs.EXISTS(p_freight_cost_temp_price(i).delivery_detail_id)))
		THEN
			l_consol_LPN_rated(p_freight_cost_temp_price(i).delivery_detail_id):=1;

		END IF;


		IF ((p_freight_cost_temp_price(i).delivery_detail_id IS NULL)
		AND (p_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND (p_child_dlegs.EXISTS(p_freight_cost_temp_price(i).delivery_leg_id)))
		THEN
			l_child_dlegs_rated(p_freight_cost_temp_price(i).delivery_leg_id):=1;

		END IF;

		IF ((p_freight_cost_temp_price(i).delivery_detail_id IS NULL)
		AND (p_freight_cost_temp_price(i).delivery_leg_id IS NOT NULL)
		AND (p_parent_dlegs.EXISTS(p_freight_cost_temp_price(i).delivery_leg_id)))
		THEN
			l_parent_dlegs_rated(p_freight_cost_temp_price(i).delivery_leg_id):=1;

		END IF;



		i:=p_freight_cost_temp_price.NEXT(i);
	END LOOP;


	i:=p_fc_main_update_rows.FIRST;
	WHILE(i IS NOT NULL)
	LOOP


		IF ((p_fc_main_update_rows(i).delivery_detail_id IS NULL)
		AND (p_fc_main_update_rows(i).delivery_leg_id IS NOT NULL)
		AND (p_child_dlegs.EXISTS(p_fc_main_update_rows(i).delivery_leg_id)))
		THEN
			l_child_dlegs_rated(p_fc_main_update_rows(i).delivery_leg_id):=1;

		END IF;

		IF ((p_fc_main_update_rows(i).delivery_detail_id IS NULL)
		AND (p_fc_main_update_rows(i).delivery_leg_id IS NOT NULL)
		AND (p_parent_dlegs.EXISTS(p_fc_main_update_rows(i).delivery_leg_id)))
		THEN
			l_parent_dlegs_rated(p_fc_main_update_rows(i).delivery_leg_id):=1;

		END IF;



		i:=p_fc_main_update_rows.NEXT(i);
	END LOOP;



	IF(l_child_detail_rated.COUNT > 0)
	THEN
		x_child_details_rated:='Y';

	END IF;

	IF(l_consol_LPN_rated.COUNT > 0)
	THEN
		x_consol_LPNs_rated:='Y';
	END IF;


	IF(l_child_dlegs_rated.COUNT = p_child_dlegs.COUNT)
	THEN
		x_child_dlegs_rated:='Y';

	END IF;

	IF(l_parent_dlegs_rated.COUNT > 0)
	THEN

		x_parent_dlegs_rated:='Y';
	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'Child Detail Rated:'||x_child_details_rated||
	'Consol LPN Rated:'||x_consol_LPNs_rated||
	' Child Dlegs rated:'||x_child_dlegs_rated||
	'Parent Dlegs rated:'||x_parent_dlegs_rated);


	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Check_Rated');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('MDC_Check_Rated',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'MDC_Check_Rated');


END MDC_Check_Rated;



PROCEDURE Handle_MDC(
        p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or temp table
        x_freight_cost_main_price IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     IN OUT NOCOPY     Freight_Cost_Main_Tab_Type,  -- For update of SUMMARY records
        x_return_status           OUT NOCOPY     VARCHAR2 ) IS

l_parent_deliveries DBMS_UTILITY.NUMBER_ARRAY;
l_child_deliveries DBMS_UTILITY.NUMBER_ARRAY;
l_parent_dlegs DBMS_UTILITY.NUMBER_ARRAY;
l_child_dlegs DBMS_UTILITY.NUMBER_ARRAY;
l_consol_LPNs DBMS_UTILITY.NUMBER_ARRAY;--Indexed by child detail id
l_consol_LPN_children DBMS_UTILITY.NUMBER_ARRAY;
l_delivery_to_dleg DBMS_UTILITY.NUMBER_ARRAY;
l_dleg_to_delivery DBMS_UTILITY.NUMBER_ARRAY;
i	NUMBER;
l_child_details_rated VARCHAR2(1);
l_consol_LPNs_rated VARCHAR2(1);
l_child_dlegs_rated VARCHAR2(1);
l_parent_dlegs_rated VARCHAR2(1);
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Handle_MDC','start');



	IF (p_save_flag IS NOT NULL)--((p_save_flag IS NOT NULL) AND ((p_save_flag ='T') OR (p_save_flag='M')))
	THEN

		--gather MDC information from cache

		i:=g_shipment_line_rows.FIRST;
		WHILE(i IS NOT NULL)
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
			'Detail_id:'||g_shipment_line_rows(i).delivery_detail_id ||
			' Delivery Id:'||g_shipment_line_rows(i).delivery_id ||
			' Dleg Id:'||g_shipment_line_rows(i).delivery_leg_id||
			' Parent Delivery Detail id:'||g_shipment_line_rows(i).parent_delivery_detail_id ||
			' Parent Delivery id:'||g_shipment_line_rows(i).parent_delivery_id ||
			'Parent Dleg Id:'||g_shipment_line_rows(i).parent_delivery_leg_id||
			'Assignment type:'||g_shipment_line_rows(i).assignment_type);

			IF ((g_shipment_line_rows(i).delivery_id IS NOT NULL) AND (g_shipment_line_rows(i).delivery_leg_id IS NOT NULL))
			THEN
				IF (NOT (l_delivery_to_dleg.EXISTS(g_shipment_line_rows(i).delivery_id)))
				THEN
					l_delivery_to_dleg(g_shipment_line_rows(i).delivery_id):=
						g_shipment_line_rows(i).delivery_leg_id;
				END IF;

				IF (NOT (l_dleg_to_delivery.EXISTS(g_shipment_line_rows(i).delivery_leg_id)))
				THEN
					l_dleg_to_delivery(g_shipment_line_rows(i).delivery_leg_id):=
						g_shipment_line_rows(i).delivery_id;
				END IF;


			END IF;

			IF ((g_shipment_line_rows(i).parent_delivery_id IS NOT NULL) AND (g_shipment_line_rows(i).parent_delivery_leg_id IS NOT NULL))
			THEN
				l_parent_deliveries(g_shipment_line_rows(i).parent_delivery_id):=g_shipment_line_rows(i).parent_delivery_id;
				l_child_deliveries(g_shipment_line_rows(i).delivery_id):=g_shipment_line_rows(i).delivery_id;

				l_parent_dlegs(g_shipment_line_rows(i).parent_delivery_leg_id):=g_shipment_line_rows(i).parent_delivery_leg_id;
				l_child_dlegs(g_shipment_line_rows(i).delivery_leg_id):=g_shipment_line_rows(i).parent_delivery_leg_id;

				l_delivery_to_dleg(g_shipment_line_rows(i).parent_delivery_id):=
					g_shipment_line_rows(i).parent_delivery_leg_id;

				l_dleg_to_delivery(g_shipment_line_rows(i).parent_delivery_leg_id):=
					g_shipment_line_rows(i).parent_delivery_id;


			END IF;


			IF ((g_shipment_line_rows(i).assignment_type IS NOT NULL) AND (g_shipment_line_rows(i).assignment_type='C')
			AND (g_shipment_line_rows(i).parent_delivery_detail_id IS NOT NULL))
			THEN
				l_consol_LPNs(g_shipment_line_rows(i).parent_delivery_detail_id):=g_shipment_line_rows(i).parent_delivery_detail_id;
				l_consol_LPN_children(g_shipment_line_rows(i).delivery_detail_id):=g_shipment_line_rows(i).parent_delivery_detail_id;
			END IF;

			i:=g_shipment_line_rows.NEXT(i);
		END LOOP;




		--Check if there is any MDC content otherwise do nothing
		IF (l_parent_deliveries.COUNT>0)
		THEN


			Populate_Dleg_Id(
				p_delivery_to_dleg=>l_delivery_to_dleg,
				x_freight_cost_temp=>x_freight_cost_temp_price,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_populate_dleg_id;
			       END IF;
			END IF;



			Populate_Dleg_Id(
				p_delivery_to_dleg=>l_delivery_to_dleg,
				x_freight_cost_temp=>x_freight_cost_temp_charge,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_populate_dleg_id;
			       END IF;
			END IF;



			 MDC_Check_Rated(
				p_save_flag=>p_save_flag,
				p_consol_LPNs=>l_consol_LPNs,
				p_consol_LPN_children=>l_consol_LPN_children,
				p_parent_dlegs=>l_parent_dlegs,
				p_child_dlegs=>l_child_dlegs,
				p_freight_cost_main_price=>x_freight_cost_main_price,
				p_freight_cost_temp_price=>x_freight_cost_temp_price,
				p_fc_main_update_rows=>x_fc_main_update_rows,
				x_child_details_rated=>l_child_details_rated,
				x_consol_LPNs_rated=>l_consol_LPNs_rated,
				x_child_dlegs_rated=>l_child_dlegs_rated,
				x_parent_dlegs_rated=>l_parent_dlegs_rated,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_check_rated;
			       END IF;
			END IF;



			--Rates at the detail level

			IF((l_consol_LPNs.COUNT>0) AND (l_consol_LPNs_rated='Y') AND (l_consol_LPN_children.COUNT> 0)
				AND (l_child_details_rated='N'))
			THEN

				MDC_Alloc_From_consol_LPN(
					p_save_flag=>p_save_flag,
					p_consol_LPNs=>l_consol_LPNs,
					p_consol_LPN_children=>l_consol_LPN_children,
					x_freight_cost_main_price=>x_freight_cost_main_price,
					x_freight_cost_temp_price=>x_freight_cost_temp_price,
					x_freight_cost_main_charge=>x_freight_cost_main_charge,
					x_freight_cost_temp_charge=>x_freight_cost_temp_charge,
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_alloc_from_consol_LPN;
				       END IF;
				END IF;



			ELSIF((l_consol_LPNs.COUNT>0) AND (l_consol_LPNs_rated='N') AND (l_consol_LPN_children.COUNT> 0)
				AND (l_child_details_rated='Y'))
			THEN
				Create_LPN_Summary(
					p_save_flag=>p_save_flag,
					p_consol_LPN_children=>l_consol_LPN_children,
					x_freight_cost_main_price=>x_freight_cost_main_price,
					x_freight_cost_temp_price=>x_freight_cost_temp_price,
					x_freight_cost_main_charge=>x_freight_cost_main_charge,
					x_freight_cost_temp_charge=>x_freight_cost_temp_charge,
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_LPN_summ;
				       END IF;
				END IF;




			END IF;


			--Rates at dleg level
			--Always recalculate child dleg summaries
			IF((l_child_dlegs.COUNT > 0) AND (l_parent_dlegs.COUNT >0))
			THEN

				Create_Child_Dleg_Summaries(
					p_save_flag=>p_save_flag,
					p_dleg_to_delivery=>l_dleg_to_delivery,
					p_parent_dlegs=>l_parent_dlegs,
					p_child_dlegs=>l_child_dlegs,
					x_freight_cost_main_price=>x_fc_main_update_rows,
					x_freight_cost_temp_price=>x_freight_cost_temp_price,
					x_fc_main_update_rows=>x_fc_main_update_rows,
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_child_dleg_summ;
				       END IF;
				END IF;



			END IF;


			--IF((l_child_dlegs.COUNT > 0) AND (l_child_dlegs_rated='Y')
			--AND (l_parent_dlegs.COUNT >0) AND (l_parent_dlegs_rated='N'))

			--Always recalculate parent dleg summaries
			IF((l_child_dlegs.COUNT > 0)AND (l_parent_dlegs.COUNT >0))
			THEN
				Create_Parent_Dleg_Summaries(
					p_save_flag=>p_save_flag,
					p_parent_dlegs=>l_parent_dlegs,
					p_child_dlegs=>l_child_dlegs,
					p_dleg_to_delivery=>l_dleg_to_delivery,
					x_freight_cost_main_price=>x_fc_main_update_rows,
					x_freight_cost_temp_price=>x_freight_cost_temp_price,
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_parent_dleg_summ;
				       END IF;
				END IF;



			END IF;





		END IF;


	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_populate_dleg_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_populate_dleg_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_check_rated THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_check_rated');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_alloc_from_consol_LPN THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_alloc_from_consol_LPN');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_LPN_summ THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_cre_LPN_summ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_parent_dleg_summ THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_cre_parent_dleg_summ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_cre_child_dleg_summ THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_cre_child_dleg_summ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_MDC',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_MDC');


END Handle_MDC;

FUNCTION hasMultipleLegs (
         p_delivery_id IN NUMBER) RETURN VARCHAR2

IS

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

    CURSOR c_get_legs(c_delivery_id NUMBER) IS
    SELECT count(delivery_leg_id) FROM wsh_delivery_legs
    WHERE delivery_id = c_delivery_id;

    l_count NUMBER :=0;

BEGIN

    OPEN c_get_legs(p_delivery_id);
    FETCH c_get_legs INTO l_count;
    CLOSE c_get_legs;

    IF l_count > 1 THEN
     RETURN 'Y';
    ELSE
     RETURN 'N';
    END IF;

END hasMultipleLegs;


   FUNCTION get_default_category (
        p_classification_code IN VARCHAR2) RETURN NUMBER
   IS

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

    CURSOR c_get_structure_id
    IS
    SELECT structure_id
    FROM mtl_category_sets mcs, mtl_category_sets_tl mcst
    WHERE mcs.category_set_id = mcst.category_set_id
    AND   mcst.category_set_name='WSH_COMMODITY_CODE'
    AND   mcst.language='US';

    CURSOR c_get_def_category(c_classification_code VARCHAR2, c_structure_id NUMBER)
    IS
    SELECT category_id
    FROM mtl_categories_b
    WHERE segment1=c_classification_code
    AND   segment4='Y'
    AND structure_id=c_structure_id;

    l_structure_id NUMBER;
    l_category_id  NUMBER;

   BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_default_category','start');

    OPEN c_get_structure_id;
    FETCH c_get_structure_id INTO l_structure_id;
    CLOSE c_get_structure_id;

    IF (p_classification_code IS NOT NULL) THEN
       OPEN c_get_def_category(p_classification_code, l_structure_id);
       FETCH c_get_def_category INTO l_category_id;
       CLOSE c_get_def_category;
    ELSE
       l_category_id := g_default_category_id;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_default_category');
    RETURN l_category_id;

   EXCEPTION
   WHEN others THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_default_category',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_default_category');
   END  get_default_category;



PROCEDURE  Get_Trip_Mode(
	p_trip_id IN NUMBER,
	p_dleg_id IN NUMBER,
	x_trip_id IN OUT NOCOPY NUMBER,
	x_mode_of_transport IN OUT NOCOPY VARCHAR2,
	x_return_status       OUT NOCOPY     VARCHAR2 )
IS

	CURSOR c_get_trip_from_dleg(c_dleg_id IN NUMBER)
	IS
	SELECT  t.trip_id, t.mode_of_transport
	FROM    wsh_delivery_legs dl,
		wsh_trip_stops s,
		wsh_trips t
	WHERE dl.delivery_leg_id =c_dleg_id AND
	      dl.pick_up_stop_id=s.stop_id AND
	     s.trip_id=t.trip_id ;


	CURSOR c_get_mode_for_trip(c_trip_id IN NUMBER)
	IS
	select t.mode_of_transport
	FROM wsh_trips t
	WHERE t.trip_id=c_trip_id;

      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_count	NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_DELIVERY';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');


	x_mode_of_transport:=NULL;
	x_trip_id:=NULL;
	IF(p_trip_id IS NOT NULL)
	THEN
		x_trip_id:=p_trip_id;
		OPEN c_get_mode_for_trip(p_trip_id);
		FETCH c_get_mode_for_trip INTO x_mode_of_transport;
		CLOSE c_get_mode_for_trip;

	ELSIF(p_dleg_id IS NOT NULL)
	THEN

		OPEN c_get_trip_from_dleg(p_dleg_id);
		FETCH c_get_trip_from_dleg INTO x_trip_id,x_mode_of_transport;
		CLOSE c_get_trip_from_dleg;

	END IF;

   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);



END Get_Trip_Mode;



  PROCEDURE validate_delivery      (p_delivery_id           IN NUMBER,
				    x_return_code	    OUT NOCOPY NUMBER)
  IS
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_count	NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_DELIVERY';
  BEGIN
--
    x_return_code := G_RC_SUCCESS;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_id='||p_delivery_id);

    -- check for empty delivery
    l_count := 0;
    OPEN c_count_delivery_details(p_delivery_id);
    FETCH c_count_delivery_details INTO l_count;
    CLOSE c_count_delivery_details;
    IF ( l_count <= 0 ) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'empty delivery');

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_EMPTY_DEL',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
	        	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- validate freight term
    l_count := 0;
    OPEN c_check_del_freight_term(p_delivery_id);
    FETCH c_check_del_freight_term INTO l_count;
    CLOSE c_check_del_freight_term;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_DEL_FGT_TERM',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'do not rate the freight term.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- Manifesting validation
    l_count := 0;
    OPEN c_check_del_manifesting(p_delivery_id);
    FETCH c_check_del_manifesting INTO l_count;
    CLOSE c_check_del_manifesting;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_DEL_MAN',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery organization is manifesting enabled and carrier is manifesting enabled, do not rate.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
	WHEN g_finished_warning THEN
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_code := G_RC_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_code := G_RC_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
  END validate_delivery;

  PROCEDURE validate_nontl_trip    (p_trip_id               IN NUMBER,
                                    x_return_code           OUT NOCOPY  NUMBER)
  IS
    l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_NONTL_TRIP';
    l_count	NUMBER;
  BEGIN

    x_return_code := G_RC_SUCCESS;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);

    l_count := 0;
    OPEN c_cnt_trip_legs(p_trip_id);
    FETCH c_cnt_trip_legs INTO l_count;
    CLOSE c_cnt_trip_legs;

    IF (l_count <= 0) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip '||p_trip_id||' has no delivery');
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_TRP_NO_DLV',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
	        	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check for empty delivery
    l_count := 0;
    OPEN c_count_delivery_details2(p_trip_id);
    FETCH c_count_delivery_details2 INTO l_count;
    CLOSE c_count_delivery_details2;
    IF ( l_count <= 0 ) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'empty delivery');

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_TRP_NO_DEL_CONTENT',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
	        	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- validate freight term
    l_count := 0;
    OPEN c_check_del_freight_term2(p_trip_id);
    FETCH c_check_del_freight_term2 INTO l_count;
    CLOSE c_check_del_freight_term2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_FGT_TERM',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'do not rate the freight term.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- Manifesting validation
    l_count := 0;
    OPEN c_check_del_manifesting2(p_trip_id);
    FETCH c_check_del_manifesting2 INTO l_count;
    CLOSE c_check_del_manifesting2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_MAN',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery organization is manifesting enabled and carrier is manifesting enabled, do not rate.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
	WHEN g_finished_warning THEN
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_code := G_RC_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_code := G_RC_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END validate_nontl_trip;
--
PROCEDURE Create_Freight_Cost_Temp(
         p_freight_cost_temp_info IN     Freight_Cost_Temp_Rec_Type,
         x_freight_cost_temp_id   OUT NOCOPY     NUMBER,
         x_return_status          OUT NOCOPY     VARCHAR2)
IS

CURSOR C_Next_Freight_Cost_Id
IS
SELECT fte_freight_costs_temp_s.nextval
FROM sys.dual;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Freight_Cost_Temp','start');

      OPEN C_Next_Freight_Cost_Id;
      FETCH C_Next_Freight_Cost_Id INTO x_freight_cost_temp_id;
      CLOSE C_Next_Freight_Cost_Id;

      INSERT INTO fte_freight_costs_temp(
                freight_cost_id,
                freight_cost_type_id,
                charge_unit_value,
                unit_amount,
                calculation_method,
                uom,
                quantity,
                total_amount,
                currency_code,
                line_type_code,
                charge_source_code,
                estimated_flag,
                comparison_request_id,
                lane_id,
                schedule_id,
                moved_to_main_flag,
                service_type_code,  -- bug2741467
                conversion_date,
                conversion_rate,
                conversion_type_code,
                trip_id,
                stop_id,
                delivery_id,
                delivery_leg_id,
                delivery_detail_id,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
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
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
                commodity_category_id,
                billable_quantity,
                billable_uom,
                billable_basis
        ) VALUES (
        x_freight_cost_temp_id,
                p_freight_cost_temp_info.freight_cost_type_id,
                p_freight_cost_temp_info.charge_unit_value,
                p_freight_cost_temp_info.unit_amount,
                p_freight_cost_temp_info.calculation_method,
                p_freight_cost_temp_info.uom,
                p_freight_cost_temp_info.quantity,
                p_freight_cost_temp_info.total_amount,
                p_freight_cost_temp_info.currency_code,
                p_freight_cost_temp_info.line_type_code,
                p_freight_cost_temp_info.charge_source_code,
                p_freight_cost_temp_info.estimated_flag,
                p_freight_cost_temp_info.comparison_request_id,
                p_freight_cost_temp_info.lane_id,
                p_freight_cost_temp_info.schedule_id,
                p_freight_cost_temp_info.moved_to_main_flag,
                p_freight_cost_temp_info.service_type_code,
                p_freight_cost_temp_info.conversion_date,
                p_freight_cost_temp_info.conversion_rate,
                p_freight_cost_temp_info.conversion_type_code,
                p_freight_cost_temp_info.trip_id,
                p_freight_cost_temp_info.stop_id,
                p_freight_cost_temp_info.delivery_id,
                p_freight_cost_temp_info.delivery_leg_id,
                p_freight_cost_temp_info.delivery_detail_id,
                p_freight_cost_temp_info.attribute_category,
                p_freight_cost_temp_info.attribute1,
                p_freight_cost_temp_info.attribute2,
                p_freight_cost_temp_info.attribute3,
                p_freight_cost_temp_info.attribute4,
                p_freight_cost_temp_info.attribute5,
                p_freight_cost_temp_info.attribute6,
                p_freight_cost_temp_info.attribute7,
                p_freight_cost_temp_info.attribute8,
                p_freight_cost_temp_info.attribute9,
                p_freight_cost_temp_info.attribute10,
                p_freight_cost_temp_info.attribute11,
                p_freight_cost_temp_info.attribute12,
                p_freight_cost_temp_info.attribute13,
                p_freight_cost_temp_info.attribute14,
                p_freight_cost_temp_info.attribute15,
                p_freight_cost_temp_info.creation_date,
                p_freight_cost_temp_info.created_by,
                p_freight_cost_temp_info.last_update_date,
                p_freight_cost_temp_info.last_updated_by,
                p_freight_cost_temp_info.last_update_login,
                p_freight_cost_temp_info.program_application_id,
                p_freight_cost_temp_info.program_id,
                p_freight_cost_temp_info.program_update_date,
                p_freight_cost_temp_info.request_id,
                p_freight_cost_temp_info.commodity_category_id,
                p_freight_cost_temp_info.billable_quantity,
                p_freight_cost_temp_info.billable_uom,
                p_freight_cost_temp_info.billable_basis
        );

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Freight_Cost_Temp');
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Freight_Cost_Temp',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Freight_Cost_Temp');

END Create_Freight_Cost_Temp;

--      This API will look up global g_rolledup_lines
--      It will return the input category/basis total for the input container

PROCEDURE get_rolledup_amount(
        p_container_id            IN  NUMBER,    -- Mandatory
        p_category_id             IN  NUMBER DEFAULT NULL,   -- Either category id or basis
        p_basis                   IN  NUMBER DEFAULT NULL,
        p_line_type_code          IN  VARCHAR2 DEFAULT NULL,  --  gets list line type code from line details
        p_wsh_amount              IN  NUMBER,
        p_fte_amount              IN  NUMBER DEFAULT NULL,
        p_fc_dlvd_rows            IN  total_discount_tab_type,
        p_quantity                IN  NUMBER,
        p_uom                     IN  VARCHAR2,
        p_save_flag               IN  VARCHAR2,
        x_freight_cost_main_price  IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_quantity                OUT NOCOPY  NUMBER, -- Returns in input uom
        x_return_status           OUT NOCOPY  VARCHAR2)
IS

        i           NUMBER:=0;
        l_sum       NUMBER:=0;
        l_quantity  NUMBER:=0;
        l_wsh_amount NUMBER:=0;
        l_fte_amount NUMBER:=0;
        l_charge_total_amount         NUMBER:=0;
        l_discount_total_amount       NUMBER:=0;
        l_index                       NUMBER:=0;
        l_main_price_index            NUMBER:=x_freight_cost_main_price.COUNT;
        l_main_charge_index           NUMBER:=x_freight_cost_main_charge.COUNT;
        l_temp_price_index            NUMBER:=x_freight_cost_temp_price.COUNT;
        l_temp_charge_index           NUMBER:=x_freight_cost_temp_charge.COUNT;

        l_fc_rec                      top_level_fc_rec_type;

        l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
        l_basis_meaning VARCHAR2(30);

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_rolledup_amount','start');
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Container : '||p_container_id);

   IF p_save_flag = 'M' THEN

      IF p_line_type_code IS NOT NULL THEN   --  charge
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'For Charge ');
         l_index       := l_main_charge_index;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'For Base Price ');
         l_index       := l_main_price_index;
      END IF;

   ELSE

      IF p_line_type_code IS NOT NULL THEN   --  charge
         l_index       := l_temp_charge_index;
      ELSE
         l_index       := l_temp_price_index;
      END IF;

   END IF;

   Get_Basis_Meaning( p_basis => p_basis,
                      x_basis_meaning => l_basis_meaning);

   i := g_rolledup_lines.FIRST;
   LOOP
      IF g_rolledup_lines(i).master_container_id = p_container_id THEN

         --l_index       := l_index + 1;

         IF g_rolledup_lines(i).line_uom <> p_uom THEN

            l_quantity :=  WSH_WV_UTILS.convert_uom(g_rolledup_lines(i).line_uom,
                                       p_uom,
                                       g_rolledup_lines(i).line_quantity,
                                       0);  -- Within same UOM class
         ELSE

            l_quantity := g_rolledup_lines(i).line_quantity;
         END IF;

         l_wsh_amount := p_wsh_amount * (l_quantity/p_quantity);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'roll->delivery_detail_id='||g_rolledup_lines(i).delivery_detail_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_quantity='||l_quantity);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_quantity='||p_quantity);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_wsh_amount='||l_wsh_amount);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_category_id='||p_category_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_basis='||p_basis);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_basis_meaning'||l_basis_meaning);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_uom='||p_uom);


        IF (p_category_id IS NOT NULL AND g_rolledup_lines(i).category_id = p_category_id) OR
            (p_basis IS NOT NULL AND g_rolledup_lines(i).rate_basis = p_basis)  THEN

               l_index       := l_index + 1;

               IF p_fc_dlvd_rows.COUNT > 0 THEN
                  l_charge_total_amount := p_fc_dlvd_rows(g_rolledup_lines(i).delivery_detail_id).total_amount;
                  l_discount_total_amount := p_fc_dlvd_rows(g_rolledup_lines(i).delivery_detail_id).discount_amount;
               ELSE
                  l_charge_total_amount := 0;
                  l_discount_total_amount := 0;
               END IF;

               l_sum := l_sum + l_quantity;
               l_fc_rec.delivery_detail_id := g_rolledup_lines(i).delivery_detail_id;
               l_fc_rec.quantity := l_quantity;

               IF p_line_type_code IS NULL THEN   --  base price

                  --l_fc_rec.unit_amount := l_wsh_amount - p_fc_dlvd_rows(g_rolledup_lines(i).delivery_detail_id).discount_amount;
                  l_fc_rec.unit_amount := l_wsh_amount - l_discount_total_amount;

               ELSE
                  --IF nvl(p_line_type_code,'-N') <> 'DISCOUNT' THEN
                  IF nvl(p_line_type_code,'-N') <> 'DIS' THEN

                     l_fc_rec.unit_amount := l_wsh_amount;

                  ELSE

                     l_fc_rec.line_type_code := 'DISCOUNT';

                  END IF;
               END IF;

               IF p_fte_amount IS NOT NULL THEN   --  Charge

                 l_fc_rec.total_amount := l_wsh_amount;

               ELSE

                 --l_fc_rec.total_amount := l_wsh_amount + p_fc_dlvd_rows(g_rolledup_lines(i).delivery_detail_id).total_amount;
                 l_fc_rec.total_amount := l_wsh_amount + l_charge_total_amount;

               END IF;

         IF p_save_flag = 'M' THEN

            IF p_line_type_code IS NULL THEN   --  base price
               x_freight_cost_main_price(l_index).line_type_code := l_fc_rec.line_type_code;
               x_freight_cost_main_price(l_index).delivery_detail_id := l_fc_rec.delivery_detail_id;
               x_freight_cost_main_price(l_index).quantity := l_fc_rec.quantity;
               x_freight_cost_main_price(l_index).unit_amount := round(l_fc_rec.unit_amount,2);
               x_freight_cost_main_price(l_index).total_amount := round(l_fc_rec.total_amount,2);
            ELSE
               x_freight_cost_main_charge(l_index).line_type_code := l_fc_rec.line_type_code;
               x_freight_cost_main_charge(l_index).delivery_detail_id := l_fc_rec.delivery_detail_id;
               x_freight_cost_main_charge(l_index).quantity := l_fc_rec.quantity;
               x_freight_cost_main_charge(l_index).unit_amount := round(l_fc_rec.unit_amount,2);
               x_freight_cost_main_charge(l_index).total_amount := round(l_fc_rec.total_amount,2);
            END IF;

         ELSE

            IF p_line_type_code IS NULL THEN   --  base price
               x_freight_cost_temp_price(l_index).line_type_code := l_fc_rec.line_type_code;
               x_freight_cost_temp_price(l_index).delivery_detail_id := l_fc_rec.delivery_detail_id;
               x_freight_cost_temp_price(l_index).quantity := l_fc_rec.quantity;
               x_freight_cost_temp_price(l_index).unit_amount := round(l_fc_rec.unit_amount,2);
               x_freight_cost_temp_price(l_index).total_amount := round(l_fc_rec.total_amount,2);
            ELSE
               x_freight_cost_temp_charge(l_index).line_type_code := l_fc_rec.line_type_code;
               x_freight_cost_temp_charge(l_index).delivery_detail_id := l_fc_rec.delivery_detail_id;
               x_freight_cost_temp_charge(l_index).quantity := l_fc_rec.quantity;
               x_freight_cost_temp_charge(l_index).unit_amount := round(l_fc_rec.unit_amount,2);
               x_freight_cost_temp_charge(l_index).total_amount := round(l_fc_rec.total_amount,2);
            END IF;

         END IF;

        ELSIF p_category_id IS NULL AND p_basis IS NULL  THEN

               l_sum := l_sum + l_quantity;

        END IF;

      END IF;

      EXIT WHEN i = g_rolledup_lines.LAST;
      i := g_rolledup_lines.NEXT(i);
   END LOOP;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_sum='||l_sum);
   x_quantity := l_sum;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_rolledup_amount');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_rolledup_amount',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_rolledup_amount');

END get_rolledup_amount;

PROCEDURE get_fc_type_id (
            p_line_type_code       IN  VARCHAR2,
            p_charge_subtype_code  IN  VARCHAR2 DEFAULT NULL,
            x_freight_cost_type_id OUT NOCOPY  NUMBER,
            x_return_status        OUT NOCOPY  VARCHAR2 )
                                                           -- RETURN NUMBER
                                                           -- Also get the charge_subtype_code
                                                           -- for line type code = 'CHARGE'
IS

   CURSOR  c_get_fc_type_id IS
   SELECT  freight_cost_type_id
   FROM    WSH_FREIGHT_COST_TYPES
   WHERE   freight_cost_type_code = p_line_type_code;

   CURSOR  c_get_fc_charge_type_id IS
   SELECT  freight_cost_type_id
   FROM    WSH_FREIGHT_COST_TYPES
   WHERE   freight_cost_type_code = p_line_type_code
   AND     name                   = p_charge_subtype_code;

   l_freight_cost_type_id       NUMBER:=0;
   l_type_count                 NUMBER:=0;

   l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_fc_type_id','start');

   IF p_charge_subtype_code IS NOT NULL THEN
   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'charge');

   OPEN  c_get_fc_charge_type_id;
   FETCH c_get_fc_charge_type_id INTO l_freight_cost_type_id;
   l_type_count := c_get_fc_charge_type_id%ROWCOUNT;
   CLOSE c_get_fc_charge_type_id;

   ELSE
   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'not charge');

   OPEN c_get_fc_type_id;
   FETCH c_get_fc_type_id INTO l_freight_cost_type_id;
   l_type_count := c_get_fc_type_id%ROWCOUNT;
   CLOSE c_get_fc_type_id;

   END IF;
   IF l_type_count = 0 THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_invalid_fc_type;
   END IF;

   x_freight_cost_type_id := l_freight_cost_type_id;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_fc_type_id');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_invalid_fc_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_fc_type_id',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_invalid_fc_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_fc_type_id');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_fc_type_id',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_fc_type_id');

END get_fc_type_id;

PROCEDURE prepare_fc_records (
         p_delivery_detail_id       IN NUMBER,  --  Top level container / loose item
         p_delivery_id              IN NUMBER,   --  Will be delivery id for 'T'
         p_entity_id                IN NUMBER,   --  Will be delivery id for 'T' and delivery leg id for 'M'
         p_qp_output_line_row       IN QP_PREQ_GRP.LINE_REC_TYPE,
         p_qp_output_detail_rows    IN QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
         p_pricing_engine_input     IN pricing_engine_input_tab_type,
         p_grouping_level           IN VARCHAR2 DEFAULT NULL,
         p_aggregation              IN VARCHAR2 DEFAULT NULL,
         p_save_flag                IN VARCHAR2,
         p_rate_basis               IN VARCHAR2 DEFAULT NULL,
         x_container_summary        IN OUT NOCOPY container_sum_tab_type,
         x_fc_dleg_rows             IN OUT NOCOPY dlvy_leg_summ_tab_type,
         x_freight_cost_main_price  IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
         x_freight_cost_temp_price  IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
         x_freight_cost_main_charge IN OUT NOCOPY Freight_Cost_Main_Tab_Type,
         x_freight_cost_temp_charge IN OUT NOCOPY Freight_Cost_Temp_Tab_Type,
         x_return_status            OUT NOCOPY  VARCHAR2)
IS

         m                             NUMBER:=0;
         n                             NUMBER:=0;
         o                             NUMBER:=0;
         l_output_fte                  NUMBER:=0;
         l_output_wsh                  NUMBER:=0;
         l_charge_unit_value           NUMBER:=0;
         l_dleg_sum_amount             NUMBER:=0;
         l_fte_total_amount            NUMBER:=0;
         l_curr_fc_count               NUMBER:=0;
         l_end_fc_count                NUMBER:=0;
         l_category_price              NUMBER:=0;
         l_container_price             NUMBER:=0;
         l_basis_price                 NUMBER:=0;
         l_category_charge             NUMBER:=0;
         l_container_charge            NUMBER:=0;
         l_basis_charge                NUMBER:=0;
         l_category_sum                NUMBER:=0;
         l_basis_sum                   NUMBER:=0;
         l_total_amount                NUMBER:=0;
         l_charge_total_amount         NUMBER:=0;
         l_discount_total_amount       NUMBER:=0;
         l_freight_cost_type_id        NUMBER:=0;
         l_delivery_detail_id          NUMBER:=0;
         l_discount_total              NUMBER:=0;
         l_discount_cont               NUMBER:=0;
         l_container_quantity          NUMBER:=0;
         l_return_status               VARCHAR2(1);
         --l_container_summary           WSH_UTIL_CORE.id_tab_type;
         l_container_summary           container_sum_tab_type;
         l_main_price_index            NUMBER:=x_freight_cost_main_price.COUNT;
         l_main_charge_index           NUMBER:=x_freight_cost_main_charge.COUNT;
         l_temp_price_index            NUMBER:=x_freight_cost_temp_price.COUNT;
         l_temp_charge_index           NUMBER:=x_freight_cost_temp_charge.COUNT;
         l_fc_dlvd_rows                total_discount_tab_type;
         l_fc_rec                      top_level_fc_rec_type;
         l_fc_charge_rec               top_level_fc_rec_type;

         l_freight_cost_main_price   Freight_Cost_Main_Tab_Type;
         l_freight_cost_temp_price   Freight_Cost_Temp_Tab_Type;
         l_freight_cost_main_charge  Freight_Cost_Main_Tab_Type;
         l_freight_cost_temp_charge  Freight_Cost_Temp_Tab_Type;

         l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;
         l_billed_weight   NUMBER;

BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'prepare_fc_records','start');

      l_fte_total_amount := 0;
      l_main_price_index :=l_main_price_index + 1;
      l_temp_price_index :=l_temp_price_index + 1;

      l_fc_rec.delivery_detail_id := p_delivery_detail_id;
      l_fc_rec.delivery_leg_id    := p_entity_id;

      l_fc_rec.line_type_code     := 'PRICE';
      l_fc_rec.currency_code      := p_qp_output_line_row.currency_code ;
      l_fc_rec.quantity           := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
      l_fc_rec.uom                := p_pricing_engine_input(p_qp_output_line_row.line_index).line_uom;

      -- uom conversion
      --l_fc_rec.charge_unit_value  := p_qp_output_line_row.unit_price;
      l_fc_rec.charge_unit_value  := (p_qp_output_line_row.unit_price)*(p_qp_output_line_row.priced_quantity/l_fc_rec.quantity);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_fc_rec.quantity='||l_fc_rec.quantity);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_fc_rec.uom='||l_fc_rec.uom);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_fc_rec.charge_unit_value='||l_fc_rec.charge_unit_value);

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,' QP Output Detail row count : '||p_qp_output_detail_rows.COUNT);
      m := p_qp_output_detail_rows.FIRST;    --   Determine the charges/discounts
      IF m IS NOT NULL THEN
      -- {
      LOOP
       -- {
       l_discount_cont  := 0;
       l_discount_total :=0;

       IF p_qp_output_detail_rows(m).list_line_type_code = 'SUR' OR
          p_qp_output_detail_rows(m).list_line_type_code = 'DIS' THEN
       -- {

         IF p_qp_output_line_row.line_index = p_qp_output_detail_rows(m).line_index THEN
         -- {

            l_fc_charge_rec.delivery_detail_id := p_delivery_detail_id;
            l_fc_charge_rec.delivery_leg_id    := p_entity_id;

            l_fc_charge_rec.line_type_code     := p_qp_output_detail_rows(m).charge_subtype_code;
            l_fc_charge_rec.currency_code      := p_qp_output_line_row.currency_code ;
            -- No change for dfw
            l_fc_charge_rec.quantity           := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
            l_fc_charge_rec.uom                := p_pricing_engine_input(p_qp_output_line_row.line_index).line_uom;
            -- uom conversion
            l_charge_unit_value                := ABS(p_qp_output_detail_rows(m).adjustment_amount);
            -- No change for dfw
            --l_fc_charge_rec.charge_unit_value  := (ABS(p_qp_output_detail_rows(m).adjustment_amount))*(p_qp_output_line_row.priced_quantity/l_fc_charge_rec.quantity);
            l_fc_charge_rec.charge_unit_value  := (l_charge_unit_value)*(p_qp_output_line_row.priced_quantity/l_fc_charge_rec.quantity);

            l_output_fte := l_charge_unit_value*p_qp_output_line_row.priced_quantity;



            IF p_save_flag = 'M' THEN
               l_curr_fc_count := x_freight_cost_main_charge.COUNT;
            ELSE
               l_curr_fc_count := x_freight_cost_temp_charge.COUNT;
            END IF;

            IF p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id IS NOT NULL THEN
            -- {

               -- Variable to keep track of the sum of the charges for the loose item

               -- Take care of the fc rows
                l_main_price_index       := l_curr_fc_count + 1;

               IF p_save_flag = 'M' THEN  --  Populate appropriate columns
               -- {

                x_freight_cost_main_charge(l_main_price_index).delivery_detail_id := p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id;
                x_freight_cost_main_charge(l_main_price_index).quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                x_freight_cost_main_charge(l_main_price_index).total_amount := round(l_output_fte,2);




                IF p_qp_output_detail_rows(m).list_line_type_code <> 'DIS' THEN

                  x_freight_cost_main_charge(l_main_price_index).unit_amount := round(l_output_fte,2);

                ELSE

                  x_freight_cost_main_charge(l_main_price_index).line_type_code := 'DISCOUNT';

                END IF;

               -- }
               ELSE
               -- {

                x_freight_cost_temp_charge(l_main_price_index).delivery_detail_id := p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id;
                x_freight_cost_temp_charge(l_main_price_index).quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                x_freight_cost_temp_charge(l_main_price_index).total_amount := round(l_output_fte,2);


                IF p_qp_output_detail_rows(m).list_line_type_code <> 'DIS' THEN

                  x_freight_cost_temp_charge(l_main_price_index).unit_amount := round(l_output_fte,2);

                ELSE

                  x_freight_cost_temp_charge(l_main_price_index).line_type_code := 'DISCOUNT';

                END IF;

               -- }
               END IF;

            -- }
            ELSE  --  Need to prorate among the top level lines
            -- {

               IF p_aggregation = 'WITHIN' THEN
               -- {
               --  Need to prorate back to top level lines based on the category
               --  Find out the output line category and quantity : x
               --  Find out the rolledup line quantity for that category :y
               --  l_fc_charge_rec.total_amount = output line total_amount * y/x

               -- This API would put the freight costs with the applicable/appropriate delivery detail
               -- i.e. rolled up line, It would also populate the total_amount and unit_amount

                  get_rolledup_amount(
                               p_container_id  =>  p_delivery_detail_id,
                               --p_basis         =>  p_pricing_engine_input(p_qp_output_line_row.line_index).basis,
                               p_category_id   =>  p_pricing_engine_input(p_qp_output_line_row.line_index).category_id,
                               p_line_type_code => p_qp_output_detail_rows(m).list_line_type_code,
                               p_wsh_amount     =>  l_output_fte,
                               p_fte_amount     =>  l_output_fte,
                               p_fc_dlvd_rows   =>  l_fc_dlvd_rows,  --  dummy
                               p_quantity      =>   p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity,
                               p_uom           =>  l_fc_charge_rec.uom,
                               p_save_flag     =>  p_save_flag,
                               x_freight_cost_main_price  => l_freight_cost_main_price,
                               x_freight_cost_temp_price  => l_freight_cost_temp_price,
                               x_freight_cost_main_charge  => x_freight_cost_main_charge,
                               x_freight_cost_temp_charge  => x_freight_cost_temp_charge,
                               x_quantity      =>  l_category_sum, -- Returns in input uom
                               x_return_status =>  l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Charge get_rolled_up');
                           raise FTE_FREIGHT_PRICING_UTIL.g_proration_failed;
                        END IF;
                     ELSE
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Engine row quantity : '||p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container : '||p_delivery_detail_id||' Category : '||p_pricing_engine_input(p_qp_output_line_row.line_index).category_id||' Children Qty Sum : '||l_category_sum);
                     END IF;

                     --l_billed_weight := l_category_sum;
                   -- When the category is not there in engine row, there is no proration
                   IF p_pricing_engine_input(p_qp_output_line_row.line_index).category_id IS NULL
                      AND p_grouping_level = 'CONTAINER' THEN
                      l_category_sum := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                   END IF;


                   -- Need to create container level SUMMARY FC record here
                   -- Only if any new fc record got created

                   l_container_charge := l_output_fte * (l_category_sum/p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);

                   IF p_qp_output_detail_rows(m).list_line_type_code = 'DIS' THEN

                     l_discount_cont    := l_container_charge;
                     l_container_charge := 0 - l_container_charge;

                   END IF;

                   -- new code for loose items
                   -- no need for summary records for loose items
                   IF ((g_shipment_line_rows(p_delivery_detail_id).container_flag = 'Y')OR (g_shipment_line_rows(p_delivery_detail_id).container_flag = 'C')) THEN
                   IF NOT x_container_summary.EXISTS(p_delivery_detail_id) THEN
                      x_container_summary(p_delivery_detail_id).currency_code := l_fc_rec.currency_code;
                      x_container_summary(p_delivery_detail_id).total_amount := l_container_charge;
                      x_container_summary(p_delivery_detail_id).discount_amount   := l_discount_cont;

                  --MDC
                      --x_container_summary(p_delivery_detail_id).delivery_id   := p_delivery_id;
                  x_container_summary(p_delivery_detail_id).delivery_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_id;



                      IF p_save_flag = 'M' THEN
                         x_container_summary(p_delivery_detail_id).delivery_leg_id   := p_entity_id;
                      END IF;
                   ELSE
                      x_container_summary(p_delivery_detail_id).total_amount := x_container_summary(p_delivery_detail_id).total_amount + l_container_charge;
                      x_container_summary(p_delivery_detail_id).discount_amount := x_container_summary(p_delivery_detail_id).discount_amount + l_discount_cont;
                   END IF;
                   END IF;

               -- }
               ELSE
               -- {
               --  Need to prorate back to top level lines based on the basis
               --  Find out the output line basis and quantity : x
               --  Find out the rolledup line quantity for that basis :y
               --  l_fc_charge_rec.total_amount = output line total_amount * y/x

                  --  New API : Case for global l_rolledup_lines
                  get_rolledup_amount(
                               p_container_id  =>  p_delivery_detail_id,
                               p_basis         =>  p_pricing_engine_input(p_qp_output_line_row.line_index).basis,
                               --p_line_type_code => p_qp_output_detail_rows(m).charge_subtype_code,
                               p_line_type_code => p_qp_output_detail_rows(m).list_line_type_code,
                               p_wsh_amount     =>  l_output_fte,
                               p_fte_amount     =>  l_output_fte,
                               p_fc_dlvd_rows   =>  l_fc_dlvd_rows,  --  dummy
                               p_quantity      =>   p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity,
                               p_uom           =>  l_fc_charge_rec.uom,
                               p_save_flag     =>  p_save_flag,
                               x_freight_cost_main_price  => l_freight_cost_main_price,
                               x_freight_cost_temp_price  => l_freight_cost_temp_price,
                               x_freight_cost_main_charge  => x_freight_cost_main_charge,
                               x_freight_cost_temp_charge  => x_freight_cost_temp_charge,
                               x_quantity      =>  l_basis_sum, -- Returns in input uom
                               x_return_status =>  l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Charge get_rolled_up');
                           raise FTE_FREIGHT_PRICING_UTIL.g_proration_failed;
                        END IF;
                     ELSE
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Engine row quantity : '||p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container : '||p_delivery_detail_id||' Basis : '||p_pricing_engine_input(p_qp_output_line_row.line_index).basis||' Children Qty Sum : '||l_basis_sum);
                     END IF;

                   -- When the basis is not there in engine row, there is no proration
                   IF p_pricing_engine_input(p_qp_output_line_row.line_index).basis IS NULL
                      AND p_grouping_level = 'CONTAINER' THEN
                      l_basis_sum := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                   END IF;

                   -- Need to create container level SUMMARY FC record here

                   l_container_charge := l_output_fte * (l_basis_sum/p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);

                   IF p_qp_output_detail_rows(m).list_line_type_code = 'DIS' THEN

                     l_discount_cont    := l_container_charge;
                     l_container_charge := 0 - l_container_charge;

                   END IF;

                   -- new code for loose items
                   -- no need for summary records for loose items
                   IF ((g_shipment_line_rows(p_delivery_detail_id).container_flag = 'Y') OR (g_shipment_line_rows(p_delivery_detail_id).container_flag = 'C')) THEN
                   IF NOT x_container_summary.EXISTS(p_delivery_detail_id) THEN
                      x_container_summary(p_delivery_detail_id).currency_code := l_fc_rec.currency_code;
                      x_container_summary(p_delivery_detail_id).total_amount := l_container_charge;
                      x_container_summary(p_delivery_detail_id).discount_amount   := l_discount_cont;

                      --x_container_summary(p_delivery_detail_id) := l_container_charge;
                      --MDC
                      --x_container_summary(p_delivery_detail_id).delivery_id   := p_delivery_id;
                      x_container_summary(p_delivery_detail_id).delivery_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_id;

                      -- Billable Weight at Container Level Summary
                      x_container_summary(p_delivery_detail_id).bquantity   := l_basis_sum;
                      x_container_summary(p_delivery_detail_id).bbasis   :=  p_pricing_engine_input(p_qp_output_line_row.line_index).basis;
                      x_container_summary(p_delivery_detail_id).buom   := l_fc_charge_rec.uom;

                      IF p_save_flag = 'M' THEN
                         --MDC
                         --x_container_summary(p_delivery_detail_id).delivery_leg_id   := p_entity_id;
                           x_container_summary(p_delivery_detail_id).delivery_leg_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_leg_id;
                      END IF;
                   ELSE
                      x_container_summary(p_delivery_detail_id).total_amount := x_container_summary(p_delivery_detail_id).total_amount + l_container_charge;
                      x_container_summary(p_delivery_detail_id).discount_amount := x_container_summary(p_delivery_detail_id).discount_amount + l_discount_cont;
                      --x_container_summary(p_delivery_detail_id) := x_container_summary(p_delivery_detail_id) + l_container_charge;
                   END IF;
                   END IF;

               -- }
               END IF;

            -- }
            END IF;

            IF p_save_flag = 'M' THEN
               l_end_fc_count := x_freight_cost_main_charge.COUNT;
            ELSE
               l_end_fc_count := x_freight_cost_temp_charge.COUNT;
            END IF;

            IF l_end_fc_count = l_curr_fc_count THEN  -- Do it only if No rolled up lines got new fc records
            -- {
                                      -- And it is not because the container did not have any matching lines
                                      -- eg.in case of consolidating SCWB with MCWB

             IF p_aggregation = 'ACROSS' AND p_pricing_engine_input(p_qp_output_line_row.line_index).basis IS NULL
             -- {
                 AND p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id IS NULL THEN

              -- If basis on the input engine line is NULL for commodity_aggregation = 'ACROSS'
              -- Put the charge at the container level itself with the proper line type code
              -- In this case the container will not have the summary record
              -- What about unit amount
              -- For these kind of lines unit amount and total amount follows exactly the same logic

               l_main_price_index := l_end_fc_count + 1;
               l_container_quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;

               IF p_save_flag = 'M' THEN  --  Populate appropriate columns

                     x_freight_cost_main_charge(l_main_price_index).delivery_detail_id := p_delivery_detail_id;
                     -- This quantity will now become the container level gross quantity
                     x_freight_cost_main_charge(l_main_price_index).quantity := l_container_quantity;

                     x_freight_cost_main_charge(l_main_price_index).total_amount := round(l_output_fte,2);

                     IF p_qp_output_detail_rows(m).list_line_type_code <> 'DIS' THEN
                       x_freight_cost_main_charge(l_main_price_index).unit_amount := round(l_output_fte,2);
                     END IF;


               ELSE

                     x_freight_cost_temp_charge(l_main_price_index).delivery_detail_id := p_delivery_detail_id;
                     -- This quantity will now become the container level gross quantity
                     x_freight_cost_temp_charge(l_main_price_index).quantity := l_container_quantity;

                     x_freight_cost_temp_charge(l_main_price_index).total_amount := round(l_output_fte,2);

                     IF p_qp_output_detail_rows(m).list_line_type_code <> 'DIS' THEN
                       x_freight_cost_temp_charge(l_main_price_index).unit_amount := round(l_output_fte,2);
                     END IF;


               END IF;
               l_end_fc_count := l_end_fc_count + 1;

             -- }
             END IF;

            -- }
            END IF;

            IF p_qp_output_detail_rows(m).list_line_type_code = 'SUR' THEN
               --l_freight_cost_type_id := get_fc_type_id(
               get_fc_type_id(
                      p_line_type_code => 'FTECHARGE',
                      p_charge_subtype_code  => l_fc_charge_rec.line_type_code,
                      x_freight_cost_type_id  =>  l_freight_cost_type_id,
                      x_return_status  =>  l_return_status);
            ELSIF p_qp_output_detail_rows(m).list_line_type_code = 'DIS' THEN
               --l_freight_cost_type_id := get_fc_type_id(
               get_fc_type_id(
                      p_line_type_code => 'FTEDISCOUNT',
                      p_charge_subtype_code  => 'DISCOUNT',
                      x_freight_cost_type_id  =>  l_freight_cost_type_id,
                      x_return_status  =>  l_return_status);
            END IF;

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
               END IF;
            ELSE
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
            END IF;

            l_fte_total_amount := 0;

            IF l_end_fc_count > l_curr_fc_count THEN
            -- {

            n := l_curr_fc_count + 1;    --   Determine the charges/discounts

            LOOP

            IF p_save_flag = 'M' THEN  --  Populate appropriate columns

               IF x_freight_cost_main_charge(n).line_type_code IS NULL THEN

                  x_freight_cost_main_charge(n).line_type_code := 'CHARGE';

               END IF;

               x_freight_cost_main_charge(n).charge_source_code := 'PRICING_ENGINE';
               --x_freight_cost_main_charge(n).estimated_flag := 'Y';
               x_freight_cost_main_charge(n).estimated_flag := 'N';

               x_freight_cost_main_charge(n).freight_cost_type_id := l_freight_cost_type_id;
               --x_freight_cost_main_charge(n).delivery_leg_id := l_fc_charge_rec.delivery_leg_id;

	       --MDC
               --x_freight_cost_main_charge(n).delivery_leg_id := p_entity_id;
               --x_freight_cost_main_charge(n).delivery_id := p_delivery_id;

               x_freight_cost_main_charge(n).delivery_leg_id := g_shipment_line_rows(x_freight_cost_main_charge(n).delivery_detail_id).delivery_leg_id;
               x_freight_cost_main_charge(n).delivery_id := g_shipment_line_rows(x_freight_cost_main_charge(n).delivery_detail_id).delivery_id;


               x_freight_cost_main_charge(n).currency_code := l_fc_charge_rec.currency_code;
               x_freight_cost_main_charge(n).uom := l_fc_charge_rec.uom;
               x_freight_cost_main_charge(n).charge_unit_value := l_fc_charge_rec.charge_unit_value;

               l_total_amount :=  x_freight_cost_main_charge(n).total_amount;

               IF x_freight_cost_main_charge(n).line_type_code = 'DISCOUNT' THEN

                  l_total_amount := 0 - l_total_amount;
                  l_discount_total := x_freight_cost_main_charge(n).total_amount;

               END IF;

               l_delivery_detail_id := x_freight_cost_main_charge(n).delivery_detail_id;

            -- ELSIF p_save_flag = 'T' THEN
            ELSE        -- VVP (OM Est change)

               IF x_freight_cost_temp_charge(n).line_type_code IS NULL THEN

                  x_freight_cost_temp_charge(n).line_type_code := 'CHARGE';

               END IF;

               x_freight_cost_temp_charge(n).charge_source_code := 'PRICING_ENGINE';
               x_freight_cost_temp_charge(n).estimated_flag := 'Y';

               x_freight_cost_temp_charge(n).freight_cost_type_id := l_freight_cost_type_id;

	       --MDC
               --x_freight_cost_temp_charge(n).delivery_id := p_entity_id;
	       x_freight_cost_temp_charge(n).delivery_id := g_shipment_line_rows(x_freight_cost_temp_charge(n).delivery_detail_id).delivery_id;

               x_freight_cost_temp_charge(n).currency_code := l_fc_charge_rec.currency_code;
               x_freight_cost_temp_charge(n).uom := l_fc_charge_rec.uom;
               x_freight_cost_temp_charge(n).charge_unit_value := l_fc_charge_rec.charge_unit_value;

               l_total_amount :=  x_freight_cost_temp_charge(n).total_amount;

               IF x_freight_cost_temp_charge(n).line_type_code = 'DISCOUNT' THEN

                  l_total_amount := 0 - l_total_amount;
                  l_discount_total := x_freight_cost_temp_charge(n).total_amount;

               END IF;

               l_delivery_detail_id := x_freight_cost_temp_charge(n).delivery_detail_id;

            END IF;

            -- WSH amount for base price lines should be base price
            -- less sum of the discounts on that base price

            IF NOT l_fc_dlvd_rows.EXISTS(l_delivery_detail_id) THEN
                l_fc_dlvd_rows(l_delivery_detail_id).total_amount := l_total_amount;
                l_fc_dlvd_rows(l_delivery_detail_id).discount_amount := l_discount_total;
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Discount total for detail '||l_delivery_detail_id||' is '||l_fc_dlvd_rows(l_delivery_detail_id).discount_amount);
            ELSE
                l_fc_dlvd_rows(l_delivery_detail_id).total_amount := l_fc_dlvd_rows(l_delivery_detail_id).total_amount + l_total_amount;
                l_fc_dlvd_rows(l_delivery_detail_id).discount_amount := l_fc_dlvd_rows(l_delivery_detail_id).discount_amount + l_discount_total;
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Discount total for detail '||l_delivery_detail_id||' is '||l_fc_dlvd_rows(l_delivery_detail_id).discount_amount);
            END IF;

            IF p_save_flag = 'M' THEN

            EXIT WHEN n = x_freight_cost_main_charge.LAST;   --  Same number of rows in either table
            n := x_freight_cost_main_charge.NEXT(n);

            ELSE

            EXIT WHEN n = x_freight_cost_temp_charge.LAST;   --  Same number of rows in either table
            n := x_freight_cost_temp_charge.NEXT(n);

            END IF;

            END LOOP;

          --}
          END IF;   -- No new fc records were created

         -- }
         END IF;

        -- }   -- 'SUR' or 'DIS'
        END IF;

        EXIT WHEN m = p_qp_output_detail_rows.LAST;
        m := p_qp_output_detail_rows.NEXT(m);
       -- }
      END LOOP;
      -- }
      ELSE
      -- {
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'NO QP line detail records created');
      -- }
      END IF;

      l_charge_unit_value  := p_qp_output_line_row.unit_price;
      --l_output_wsh := l_fc_rec.charge_unit_value * l_fc_rec.quantity;
      l_output_wsh := l_charge_unit_value * p_qp_output_line_row.priced_quantity;

      IF p_save_flag = 'M' THEN
         l_curr_fc_count := x_freight_cost_main_price.COUNT;
      ELSE
         l_curr_fc_count := x_freight_cost_temp_price.COUNT;
      END IF;

      IF p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id IS NOT NULL THEN
      -- {

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loose item id : '||p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id);

               l_main_price_index       := l_curr_fc_count + 1;

               IF l_fc_dlvd_rows.COUNT > 0 THEN
                  l_charge_total_amount := l_fc_dlvd_rows(p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id).total_amount;
                  l_discount_total_amount := l_fc_dlvd_rows(p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id).discount_amount;
               ELSE
                  l_charge_total_amount := 0;
                  l_discount_total_amount := 0;
               END IF;

               IF p_save_flag = 'M' THEN  --  Populate appropriate columns

                x_freight_cost_main_price(l_main_price_index).delivery_detail_id := p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id;
                x_freight_cost_main_price(l_main_price_index).quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                x_freight_cost_main_price(l_main_price_index).unit_amount := round(l_output_wsh - l_discount_total_amount,2);

                x_freight_cost_main_price(l_main_price_index).total_amount := round(l_output_wsh + l_charge_total_amount,2);

               ELSE

                x_freight_cost_temp_price(l_main_price_index).delivery_detail_id := p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id;
                x_freight_cost_temp_price(l_main_price_index).quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                x_freight_cost_temp_price(l_main_price_index).unit_amount := round(l_output_wsh - l_discount_total_amount,2);

                x_freight_cost_temp_price(l_main_price_index).total_amount := round(l_output_wsh + l_charge_total_amount,2);

               END IF;

      -- }
      ELSE  --  Need to prorate among the top level lines
      -- {

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'p_aggregation= '||p_aggregation);
         IF p_aggregation = 'WITHIN' THEN
         -- {
         --  Need to prorate back to top level lines based on the category

                  --  New API : Case for global l_rolledup_lines
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,' Basis is : '||p_pricing_engine_input(p_qp_output_line_row.line_index).basis);
                  get_rolledup_amount(
                               p_container_id  =>  p_delivery_detail_id,
                               --p_basis         =>  p_pricing_engine_input(p_qp_output_line_row.line_index).basis,
                               p_category_id   =>  p_pricing_engine_input(p_qp_output_line_row.line_index).category_id,
                               p_wsh_amount    =>  l_output_wsh,
                               p_fc_dlvd_rows  =>  l_fc_dlvd_rows,
                               p_quantity      =>   p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity,
                               p_uom           =>  l_fc_rec.uom,
                               p_save_flag     =>  p_save_flag,
                               x_freight_cost_main_price  => x_freight_cost_main_price,
                               x_freight_cost_temp_price  => x_freight_cost_temp_price,
                               x_freight_cost_main_charge  => l_freight_cost_main_charge,
                               x_freight_cost_temp_charge  => l_freight_cost_temp_charge,
                               x_quantity      =>  l_category_sum, -- Returns in input uom
                               x_return_status =>  l_return_status);

            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,' l_category_sum ='||l_category_sum);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Price get_rolled_up');
                           raise FTE_FREIGHT_PRICING_UTIL.g_proration_failed;
                        END IF;
                     ELSE
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Engine row quantity : '||p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container : '||p_delivery_detail_id||' Category : '||p_pricing_engine_input(p_qp_output_line_row.line_index).category_id||' Children Qty Sum : '||l_category_sum);
                     END IF;

                   -- When the category is not there in engine row, there is no proration
                   IF p_pricing_engine_input(p_qp_output_line_row.line_index).category_id IS NULL
                      AND p_grouping_level = 'CONTAINER' THEN
                      l_category_sum := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                   END IF;

                   -- Need to create container level SUMMARY FC record here

                   l_container_price := l_output_wsh * (l_category_sum/p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);

                    l_billed_weight := l_category_sum;
                   -- new code for loose items
                   -- no need for summary records for loose items
                   IF ((g_shipment_line_rows(p_delivery_detail_id).container_flag = 'Y') OR (g_shipment_line_rows(p_delivery_detail_id).container_flag = 'C')) THEN
                   -- {
                   IF x_container_summary.EXISTS(p_delivery_detail_id) THEN
                      x_container_summary(p_delivery_detail_id).total_amount := x_container_summary(p_delivery_detail_id).total_amount + l_container_price;
                      x_container_summary(p_delivery_detail_id).discount_amount := l_container_price - x_container_summary(p_delivery_detail_id).discount_amount;

                   ELSE
                      x_container_summary(p_delivery_detail_id).currency_code := l_fc_rec.currency_code;
                      x_container_summary(p_delivery_detail_id).total_amount :=  l_container_price;
                      x_container_summary(p_delivery_detail_id).discount_amount := l_container_price;
                      --Billable columns at container level
                      x_container_summary(p_delivery_detail_id).bquantity   := l_category_sum;--p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                      x_container_summary(p_delivery_detail_id).bbasis   :=  p_pricing_engine_input(p_qp_output_line_row.line_index).basis;
                      x_container_summary(p_delivery_detail_id).buom   := l_fc_rec.uom;

		      --MDC
                      --x_container_summary(p_delivery_detail_id).delivery_id   := p_delivery_id;
		      x_container_summary(p_delivery_detail_id).delivery_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_id;

                      IF p_save_flag = 'M' THEN
			 --MDC
                         --x_container_summary(p_delivery_detail_id).delivery_leg_id   := p_entity_id;
			 x_container_summary(p_delivery_detail_id).delivery_leg_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_leg_id;

                      END IF;
                   END IF;
                   -- }
                   END IF;   --container flag

         -- }
         ELSE
         -- {

                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,' Basis 2 is : '||p_pricing_engine_input(p_qp_output_line_row.line_index).basis);
                  get_rolledup_amount(
                               p_container_id  =>  p_delivery_detail_id,
                               p_basis         =>  p_pricing_engine_input(p_qp_output_line_row.line_index).basis,
                               p_wsh_amount    =>  l_output_wsh,
                               p_fc_dlvd_rows  =>  l_fc_dlvd_rows,
                               p_quantity      =>   p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity,
                               p_uom           =>  l_fc_rec.uom,
                               p_save_flag     =>  p_save_flag,
                               x_freight_cost_main_price  => x_freight_cost_main_price,
                               x_freight_cost_temp_price  => x_freight_cost_temp_price,
                               x_freight_cost_main_charge  => l_freight_cost_main_charge,
                               x_freight_cost_temp_charge  => l_freight_cost_temp_charge,
                               x_quantity      =>  l_basis_sum, -- Returns in input uom
                               x_return_status =>  l_return_status);

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,' l_basis_sum ='||l_basis_sum);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Price get_rolled_up');
                           raise FTE_FREIGHT_PRICING_UTIL.g_proration_failed;
                        END IF;
                     ELSE
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Engine row quantity : '||p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container : '||p_delivery_detail_id||' Basis : '||p_pricing_engine_input(p_qp_output_line_row.line_index).basis||' Children Qty Sum : '||l_basis_sum);
                     END IF;

                   -- When the basis is not there in engine row, there is no proration
                   IF p_pricing_engine_input(p_qp_output_line_row.line_index).basis IS NULL
                      AND p_grouping_level = 'CONTAINER' THEN
                      l_basis_sum := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                   END IF;

                   -- Need to create container level SUMMARY FC record here

                   l_container_price := l_output_wsh * (l_basis_sum/p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity);

                   l_billed_weight := l_basis_sum;

                   -- new code for loose items
                   -- no need for summary records for loose items
                   IF ((g_shipment_line_rows(p_delivery_detail_id).container_flag = 'Y')OR (g_shipment_line_rows(p_delivery_detail_id).container_flag = 'C')) THEN
                   -- {
                   IF x_container_summary.EXISTS(p_delivery_detail_id) THEN
                      x_container_summary(p_delivery_detail_id).total_amount := x_container_summary(p_delivery_detail_id).total_amount + l_container_price;
                      x_container_summary(p_delivery_detail_id).discount_amount := l_container_price - x_container_summary(p_delivery_detail_id).discount_amount;

                   ELSE
                      x_container_summary(p_delivery_detail_id).currency_code := l_fc_rec.currency_code;
                      x_container_summary(p_delivery_detail_id).total_amount :=  l_container_price;
                      x_container_summary(p_delivery_detail_id).discount_amount := l_container_price;
                      --Billable columns at container level
                      x_container_summary(p_delivery_detail_id).bquantity   := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;
                      x_container_summary(p_delivery_detail_id).bbasis   :=  p_pricing_engine_input(p_qp_output_line_row.line_index).basis;
                      x_container_summary(p_delivery_detail_id).buom   := l_fc_rec.uom;


		              --MDC
                      --x_container_summary(p_delivery_detail_id).delivery_id   := p_delivery_id;
		             x_container_summary(p_delivery_detail_id).delivery_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_id;
                      IF p_save_flag = 'M' THEN
			            --MDC
                         --x_container_summary(p_delivery_detail_id).delivery_leg_id   := p_entity_id;

			             x_container_summary(p_delivery_detail_id).delivery_leg_id   := g_shipment_line_rows(p_delivery_detail_id).delivery_leg_id;

                      END IF;
                   END IF;
                   -- }
                   END IF;

         -- }
         END IF;
      -- }
      END IF;

     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_billed_weight='||l_billed_weight);

      IF p_save_flag = 'M' THEN
         l_end_fc_count := x_freight_cost_main_price.COUNT;
      ELSE
         l_end_fc_count := x_freight_cost_temp_price.COUNT;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No. of fc base price records created w/o Container level BP : '||to_char(l_end_fc_count - l_curr_fc_count));

      IF l_end_fc_count = l_curr_fc_count THEN  -- Do it only if No rolled up lines got new fc records     -- {
                                                -- And it is not because the container did not have any matching lines
                                                -- eg.in case of consolidating SCWB with MCWB

      -- IF p_aggregation = 'ACROSS' AND p_pricing_engine_input(p_qp_output_line_row.line_index).basis IS NULL
      --    AND p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_id IS NULL THEN
      IF p_aggregation = 'ACROSS' AND p_pricing_engine_input(p_qp_output_line_row.line_index).basis IS NULL
         AND p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_flag = 'N' THEN
      -- {
      -- If basis on the input engine line is NULL for commodity_aggregation = 'ACROSS'
      -- Put the charge at the container level itself with the proper line type code
      -- In this case the container will not have the summary record
      -- What about unit amount
      -- For these kind of lines unit amount and total amount follows exactly the same logic

       l_main_price_index := l_end_fc_count + 1;
       l_container_quantity := p_pricing_engine_input(p_qp_output_line_row.line_index).line_quantity;



      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Container Quantity : '|| l_container_quantity);

       IF p_save_flag = 'M' THEN  --  Populate appropriate columns
             x_freight_cost_main_price(l_main_price_index).delivery_detail_id := p_delivery_detail_id;
             -- This quantity will now become the container level gross quantity
             x_freight_cost_main_price(l_main_price_index).quantity := l_container_quantity;
             x_freight_cost_main_price(l_main_price_index).total_amount := round(x_container_summary(p_delivery_detail_id).total_amount,2);
             x_freight_cost_main_price(l_main_price_index).unit_amount := round(x_container_summary(p_delivery_detail_id).discount_amount,2);
             x_freight_cost_main_price(l_main_price_index).billable_quantity := l_container_quantity;
             x_freight_cost_main_price(l_main_price_index).billable_uom := l_fc_rec.uom;
             x_freight_cost_main_price(l_main_price_index).billable_basis := p_rate_basis;

       ELSE
             x_freight_cost_temp_price(l_main_price_index).delivery_detail_id := p_delivery_detail_id;
             -- This quantity will now become the container level gross quantity
             x_freight_cost_temp_price(l_main_price_index).quantity := l_container_quantity;
             x_freight_cost_temp_price(l_main_price_index).total_amount := round(x_container_summary(p_delivery_detail_id).total_amount,2);
             x_freight_cost_temp_price(l_main_price_index).unit_amount := round(x_container_summary(p_delivery_detail_id).discount_amount,2);
             x_freight_cost_temp_price(l_main_price_index).billable_quantity := l_container_quantity;
             x_freight_cost_temp_price(l_main_price_index).billable_uom := l_fc_rec.uom;
             x_freight_cost_temp_price(l_main_price_index).billable_basis := p_rate_basis;

       END IF;
       l_end_fc_count := l_end_fc_count + 1;
       x_container_summary.DELETE(p_delivery_detail_id);  -- No summary record for this one

      -- }
      END IF;

      -- }
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No. of fc base price records created in all : '||to_char(l_end_fc_count - l_curr_fc_count));

      IF l_end_fc_count > l_curr_fc_count THEN

        get_fc_type_id(
                      p_line_type_code => 'FTEPRICE',
                      p_charge_subtype_code  => 'PRICE',
                      x_freight_cost_type_id  =>  l_freight_cost_type_id,
                      x_return_status  =>  l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
           END IF;
        ELSE
           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
        END IF;

        o := l_curr_fc_count + 1;    --   Determine the base price
        LOOP

        --l_freight_cost_type_id := get_fc_type_id(

        IF p_save_flag = 'M' THEN  --  Populate appropriate columns

           x_freight_cost_main_price(o).line_type_code := l_fc_rec.line_type_code;
           --x_freight_cost_main_price(o).line_type_code := nvl(x_freight_cost_main_price(n).line_type_code,'PRICE');
           x_freight_cost_main_price(o).charge_source_code := 'PRICING_ENGINE';
           --x_freight_cost_main_price(o).estimated_flag := 'Y';
           x_freight_cost_main_price(o).estimated_flag := 'N';
           x_freight_cost_main_price(o).freight_cost_type_id := l_freight_cost_type_id;
           --x_freight_cost_main_price(o).delivery_leg_id := l_fc_rec.delivery_leg_id;

	   --MDC
	   --x_freight_cost_main_price(o).delivery_leg_id := p_entity_id;
	   x_freight_cost_main_price(o).delivery_leg_id :=g_shipment_line_rows(x_freight_cost_main_price(o).delivery_detail_id).delivery_leg_id;
           --x_freight_cost_main_price(o).delivery_id := p_delivery_id;
	   x_freight_cost_main_price(o).delivery_id :=g_shipment_line_rows(x_freight_cost_main_price(o).delivery_detail_id).delivery_id;

           x_freight_cost_main_price(o).currency_code := l_fc_rec.currency_code;
           x_freight_cost_main_price(o).uom := l_fc_rec.uom;
           x_freight_cost_main_price(o).charge_unit_value := l_fc_rec.charge_unit_value;

           -- Need to set for Top level Price record in case of commodity based rating
           -- Container rates columns are set during container summary records.

           IF p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_flag = 'Y'
             AND l_fc_rec.line_type_code = 'PRICE' THEN
               x_freight_cost_main_price(o).billable_uom := l_fc_rec.uom;
               x_freight_cost_main_price(o).billable_quantity := l_billed_weight;--l_fc_rec.quantity;
               x_freight_cost_main_price(o).billable_basis := p_rate_basis;--p_pricing_engine_input(p_qp_output_line_row.line_index).basis;
           END IF;

		--MDC
		IF x_freight_cost_main_price(o).delivery_leg_id IS NOT NULL THEN

		 IF NOT x_fc_dleg_rows.EXISTS(x_freight_cost_main_price(o).delivery_leg_id) THEN
		    x_fc_dleg_rows(x_freight_cost_main_price(o).delivery_leg_id).entity_id := x_freight_cost_main_price(o).delivery_leg_id;
		    x_fc_dleg_rows(x_freight_cost_main_price(o).delivery_leg_id).summary_amount := x_freight_cost_main_price(o).total_amount;
		 ELSE
		    x_fc_dleg_rows(x_freight_cost_main_price(o).delivery_leg_id).summary_amount := x_fc_dleg_rows(x_freight_cost_main_price(o).delivery_leg_id).summary_amount + x_freight_cost_main_price(o).total_amount;
		 END IF;

		END IF;


           --l_dleg_sum_amount := l_dleg_sum_amount + x_freight_cost_main_price(o).total_amount;

        --ELSIF p_save_flag = 'T' THEN
        ELSE              -- VVP (OM Est change)

           x_freight_cost_temp_price(o).line_type_code := l_fc_rec.line_type_code;
           --x_freight_cost_temp_price(o).line_type_code := nvl(x_freight_cost_temp_price(n).line_type_code,l_fc_rec.line_type_code);
           x_freight_cost_temp_price(o).charge_source_code := 'PRICING_ENGINE';
           x_freight_cost_temp_price(o).estimated_flag := 'Y';
           x_freight_cost_temp_price(o).freight_cost_type_id := l_freight_cost_type_id;

       --MDC
           --x_freight_cost_temp_price(o).delivery_id := p_entity_id;

	   x_freight_cost_temp_price(o).delivery_id := g_shipment_line_rows(x_freight_cost_temp_price(o).delivery_detail_id).delivery_id;

           x_freight_cost_temp_price(o).currency_code := l_fc_rec.currency_code;
           x_freight_cost_temp_price(o).uom := l_fc_rec.uom;
           -- Need to set for Top level Price record in case of commodity based rating
           -- Container rates columns are set during container summary records.
           IF p_pricing_engine_input(p_qp_output_line_row.line_index).loose_item_flag = 'Y'
             AND l_fc_rec.line_type_code = 'PRICE' THEN
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Setting billed Weight in case of Price and lose Item Y');

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_billed_weight ='||l_billed_weight);
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_fc_rec.quantity ='||l_fc_rec.quantity);

               x_freight_cost_temp_price(o).billable_uom := l_fc_rec.uom;
               x_freight_cost_temp_price(o).billable_quantity := l_billed_weight;--l_fc_rec.quantity;
               x_freight_cost_temp_price(o).billable_basis := p_rate_basis;--p_pricing_engine_input(p_qp_output_line_row.line_index).basis;
           END IF;
           x_freight_cost_temp_price(o).charge_unit_value := l_fc_rec.charge_unit_value;

		--MDC
		IF x_freight_cost_temp_price(o).delivery_id IS NOT NULL THEN

		 IF NOT x_fc_dleg_rows.EXISTS(x_freight_cost_temp_price(o).delivery_id) THEN
		    x_fc_dleg_rows(x_freight_cost_temp_price(o).delivery_id).entity_id := x_freight_cost_temp_price(o).delivery_id;
		    x_fc_dleg_rows(x_freight_cost_temp_price(o).delivery_id).summary_amount := x_freight_cost_temp_price(o).total_amount;
		 ELSE
		    x_fc_dleg_rows(x_freight_cost_temp_price(o).delivery_id).summary_amount := x_fc_dleg_rows(x_freight_cost_temp_price(o).delivery_id).summary_amount + x_freight_cost_temp_price(o).total_amount;
		 END IF;

		END IF;


           --l_dleg_sum_amount := l_dleg_sum_amount + x_freight_cost_temp_price(o).total_amount;

        END IF;

        IF p_save_flag = 'M' THEN

           EXIT WHEN o = x_freight_cost_main_price.LAST;   --  Same number of rows in either table
           o := x_freight_cost_main_price.NEXT(o);

        ELSE

           EXIT WHEN o = x_freight_cost_temp_price.LAST;   --  Same number of rows in either table
           o := x_freight_cost_temp_price.NEXT(o);

        END IF;

        END LOOP;

	--MDC
        --IF p_entity_id IS NOT NULL THEN

         --IF NOT x_fc_dleg_rows.EXISTS(p_entity_id) THEN
            --x_fc_dleg_rows(p_entity_id).entity_id := p_entity_id;
            --x_fc_dleg_rows(p_entity_id).summary_amount := l_dleg_sum_amount;
         --ELSE
            --x_fc_dleg_rows(p_entity_id).summary_amount := x_fc_dleg_rows(p_entity_id).summary_amount + l_dleg_sum_amount;
         --END IF;

        --END IF;

      END IF;  --  No new fc records were inserted
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'prepare_fc_records');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_proration_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('prepare_fc_records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_proration_failed');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'prepare_fc_records failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'prepare_fc_records');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('prepare_fc_records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'prepare_fc_records');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('prepare_fc_records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'prepare_fc_records');
END prepare_fc_records;

--      This API will result in one qp output line per instance
--      It will delete other engine rows and associated engine output line details

PROCEDURE resolve_pricing_objective(
             p_pricing_dual_instances   IN  pricing_dual_instance_tab_type,
             x_pricing_engine_input     IN OUT NOCOPY  pricing_engine_input_tab_type,
             x_qp_output_line_rows      IN OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
             x_qp_output_line_details   IN OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
             x_return_status            OUT NOCOPY   VARCHAR2)
IS
        i                         NUMBER:=0;
        j                         NUMBER:=0;
        l_tot_amount              NUMBER:=0;
        l_return_status           VARCHAR2(1);

        l_instance_output         instance_enginerow_tab_type;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'resolve_pricing_objective','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'QP Output line row count : '||x_qp_output_line_rows.COUNT);
   i := x_qp_output_line_rows.FIRST;
   IF i IS NOT NULL THEN
   LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'QP line index : '||x_qp_output_line_rows(i).line_index);
    -- IF x_pricing_engine_input(x_qp_output_line_rows(i).line_index).loose_item_id IS NULL THEN -- Container
    IF x_pricing_engine_input(x_qp_output_line_rows(i).line_index).loose_item_flag = 'N' THEN -- Container

     IF NOT l_instance_output.EXISTS(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index) THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'QP line index : '||x_qp_output_line_rows(i).line_index||'Instance : '
        ||x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index||' Quanitity : '||x_pricing_engine_input(x_qp_output_line_rows(i).line_index).line_quantity);

        l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).input_index := x_qp_output_line_rows(i).line_index;
        --l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount := x_qp_output_line_rows(i).unit_price * x_pricing_engine_input(x_qp_output_line_rows(i).line_index).line_quantity;

        l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount := x_qp_output_line_rows(i).unit_price * x_qp_output_line_rows(i).priced_quantity;

     ELSE

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'QP line index : '||x_qp_output_line_rows(i).line_index||'Instance : '
        ||x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index||' Quanitity : '||x_pricing_engine_input(x_qp_output_line_rows(i).line_index).line_quantity);

     --  Find out the line index to choose for this instance based on pricing objective
     --  What happens if there is no pricing objective ?

        --l_tot_amount := x_qp_output_line_rows(i).unit_price * x_pricing_engine_input(x_qp_output_line_rows(i).line_index).line_quantity; --  assuming same input and output currency code

        l_tot_amount := x_qp_output_line_rows(i).unit_price * x_qp_output_line_rows(i).priced_quantity; --  assuming same input and output currency code

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Current Total amount : '||l_tot_amount);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Existing instance amount : '||l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Pricing objective : '||p_pricing_dual_instances(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).objective);

        IF p_pricing_dual_instances(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).objective IS NOT NULL THEN

        IF ((p_pricing_dual_instances(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).objective = G_OBJECTIVE_HIGHEST AND
           l_tot_amount > l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount )   OR
           (p_pricing_dual_instances(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).objective = G_OBJECTIVE_LOWEST AND
           l_tot_amount < l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount ))   THEN

              x_pricing_engine_input.DELETE(l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).input_index);

              FTE_QP_ENGINE.delete_lines (
                      p_line_index     =>   l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).input_index,
                      x_qp_output_line_rows     => x_qp_output_line_rows ,
                      x_qp_output_detail_rows   =>  x_qp_output_line_details,
                      x_return_status  =>   l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Highest current higher delete_lines ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed;
                 END IF;
              ELSE
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Deleted QP output : '||l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).input_index);
              END IF;

              l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).tot_amount := l_tot_amount;
              l_instance_output(x_pricing_engine_input(x_qp_output_line_rows(i).line_index).instance_index).input_index := x_qp_output_line_rows(i).line_index;

        ELSE

              x_pricing_engine_input.DELETE(x_qp_output_line_rows(i).line_index);

              FTE_QP_ENGINE.delete_lines (
                      p_line_index     =>   i,
                      x_qp_output_line_rows     => x_qp_output_line_rows ,
                      x_qp_output_detail_rows   =>  x_qp_output_line_details,
                      x_return_status  =>   l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Highest current not higher delete_lines');
                    raise FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed;
                 END IF;
              ELSE
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Deleted QP output : '||i);
              END IF;

        -- For NULL pricing objective we will keep all the output lines for the instance

        END IF;
        END IF;  -- pricing_objective NOT NULL

     END IF;

     --  Found out the line index for this instance based on pricing objective
    END IF;

    EXIT WHEN i >= x_qp_output_line_rows.LAST;
    i := x_qp_output_line_rows.NEXT(i);
   END LOOP;
   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'resolve_pricing_objective');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('resolve_pricing_objective',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_delete_qpline_failed');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'delete_qpline_failed failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'resolve_pricing_objective');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('resolve_pricing_objective',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'resolve_pricing_objective');

END resolve_pricing_objective;

PROCEDURE add_other_container_summary (
          p_save_flag                 IN             VARCHAR2,
          x_freight_cost_main_price   IN OUT NOCOPY  Freight_Cost_Main_Tab_Type,
          x_freight_cost_temp_price   IN OUT NOCOPY  Freight_Cost_Temp_Tab_Type,
          x_return_status             OUT NOCOPY             VARCHAR2)
IS

          i                           NUMBER:=0;
          j                           NUMBER:=0;
          l                           NUMBER:=0;
          n                           NUMBER:=0;
          p                           NUMBER:=0;
          l_price_first               NUMBER:=0;
          l_child_container           NUMBER:=0;
          l_master_container          NUMBER:=0;
          l_parent_container          NUMBER:=0;
          l_price_last                NUMBER:=0;
          l_curr_fc_count             NUMBER:=0;
          l_main_price_index          NUMBER:=0;
          l_freight_cost_type_id      NUMBER:=0;
          l_in_between_cont_prv_cnt   NUMBER:=0;
          l_container_summary         container_sum_tab_type;
          l_between_cont_sum          container_sum_tab_type;
          l_in_between_containers     container_detail_tab_type;
          l_return_status             VARCHAR2(1);

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'add_other_container_summary','start');

   IF p_save_flag = 'M' THEN
      l_price_first := x_freight_cost_main_price.FIRST;
      l_price_last := x_freight_cost_main_price.LAST;
      l_curr_fc_count := x_freight_cost_main_price.COUNT;
   ELSE
      l_price_first := x_freight_cost_temp_price.FIRST;
      l_price_last := x_freight_cost_temp_price.LAST;
      l_curr_fc_count := x_freight_cost_temp_price.COUNT;
   END IF;

   p := 0;
   i := g_rolledup_lines.FIRST;
   LOOP
      IF g_rolledup_lines(i).master_container_id <> g_rolledup_lines(i).container_id THEN
                            -- This is a rolled up line which
                            -- actually is inside a non top level container
                            -- For this delivery detail we need to look up the total_amount

         -- Now, an interesting problem here would be if the container_id here is not a direct
         -- child of the master_container_id and there is no rolled up line
         -- for the in between containers
         -- For all those in between containers a SUMMARY record needs to be inserted
         -- these records will look exactly the same as that of the actual container_id here

         l_in_between_cont_prv_cnt := l_in_between_containers.COUNT;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Parent non top level container for detail : '||g_rolledup_lines(i).delivery_detail_id);

         l_child_container  := g_rolledup_lines(i).container_id;
         l_master_container := g_rolledup_lines(i).master_container_id;
         LOOP

           l_parent_container  := g_shipment_line_rows(l_child_container).parent_delivery_detail_id;

           IF l_parent_container <> l_master_container THEN
            -- We have to deal with in between containers

               IF NOT l_container_summary.EXISTS(l_parent_container) THEN
                  p := p + 1;
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adding in between container : '||l_parent_container);

                  -- If indexed by container_id then can not store detail id
                  -- Create a hash of detail and container together  ?
                  -- and store both detail and container

                  l_in_between_containers(p).detail_id := g_rolledup_lines(i).delivery_detail_id;
                  l_in_between_containers(p).entity_id := l_parent_container;

               END IF;
               l_child_container := g_shipment_line_rows(l_child_container).parent_delivery_detail_id;
           ELSE
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done adding in between containers for detail : '||g_rolledup_lines(i).delivery_detail_id);
               EXIT;
           END IF;
         END LOOP;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Parent container : '||g_rolledup_lines(i).container_id);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Master container : '||g_rolledup_lines(i).master_container_id);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'In between container count : '||l_in_between_containers.COUNT);

         -- No need to loop over charge records as the PRICE record for the
         -- delivery detail would already have taken care of the charges and discounts
         -- in its TOTAL_AMOUNT column

         -- Loop over price records
         j := l_price_first;
         IF j IS NOT NULL THEN
         LOOP
           IF p_save_flag = 'M' THEN
              IF x_freight_cost_main_price(j).delivery_detail_id = g_rolledup_lines(i).delivery_detail_id THEN
                 IF NOT l_container_summary.EXISTS(g_rolledup_lines(i).container_id) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adding non in between other container : '||g_rolledup_lines(i).container_id);

                    l_container_summary(g_rolledup_lines(i).container_id).total_amount    := x_freight_cost_main_price(j).total_amount;
                    l_container_summary(g_rolledup_lines(i).container_id).currency_code   := x_freight_cost_main_price(j).currency_code;
                    l_container_summary(g_rolledup_lines(i).container_id).delivery_leg_id := x_freight_cost_main_price(j).delivery_leg_id;
                    l_container_summary(g_rolledup_lines(i).container_id).delivery_id     := x_freight_cost_main_price(j).delivery_id;
                 ELSE
                    l_container_summary(g_rolledup_lines(i).container_id).total_amount    :=
                    l_container_summary(g_rolledup_lines(i).container_id).total_amount     + x_freight_cost_main_price(j).total_amount;
                 END IF;
              END IF;
           ELSE
              IF x_freight_cost_temp_price(j).delivery_detail_id = g_rolledup_lines(i).delivery_detail_id THEN
                 IF NOT l_container_summary.EXISTS(g_rolledup_lines(i).container_id) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adding non in between other container : '||g_rolledup_lines(i).container_id);

                    l_container_summary(g_rolledup_lines(i).container_id).total_amount    := x_freight_cost_temp_price(j).total_amount;
                    l_container_summary(g_rolledup_lines(i).container_id).currency_code   := x_freight_cost_temp_price(j).currency_code;
                    --l_container_summary(g_rolledup_lines(i).container_id).delivery_leg_id := x_freight_cost_temp_price(j).delivery_leg_id;
                    l_container_summary(g_rolledup_lines(i).container_id).delivery_id     := x_freight_cost_temp_price(j).delivery_id;
                 ELSE
                    l_container_summary(g_rolledup_lines(i).container_id).total_amount    :=
                    l_container_summary(g_rolledup_lines(i).container_id).total_amount     + x_freight_cost_temp_price(j).total_amount;
                 END IF;
              END IF;
           END IF;

           IF l_in_between_containers.COUNT > l_in_between_cont_prv_cnt THEN
           n := l_in_between_cont_prv_cnt + 1;
           IF n IS NOT NULL THEN
           LOOP
             IF p_save_flag = 'M' THEN
                IF ((x_freight_cost_main_price(j).delivery_detail_id = g_rolledup_lines(i).delivery_detail_id) AND
                   (x_freight_cost_main_price(j).delivery_detail_id = l_in_between_containers(n).detail_id)) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Fc exists for in between container : '||l_in_between_containers(n).entity_id);

                    IF NOT l_between_cont_sum.EXISTS(l_in_between_containers(n).entity_id) THEN
                      l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount    := x_freight_cost_main_price(j).total_amount;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).currency_code   := x_freight_cost_main_price(j).currency_code;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).delivery_leg_id := x_freight_cost_main_price(j).delivery_leg_id;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).delivery_id     := x_freight_cost_main_price(j).delivery_id;
                    ELSE
                      l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount :=
                        l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount +
                        x_freight_cost_main_price(j).total_amount;
                    END IF;
                END IF;

             ELSE
                IF ((x_freight_cost_temp_price(j).delivery_detail_id = g_rolledup_lines(i).delivery_detail_id) AND
                   (x_freight_cost_temp_price(j).delivery_detail_id = l_in_between_containers(n).detail_id)) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Fc exists for in between container : '||l_in_between_containers(n).entity_id);

                    IF NOT l_between_cont_sum.EXISTS(l_in_between_containers(n).entity_id) THEN
                      l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount    := x_freight_cost_temp_price(j).total_amount;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).currency_code   := x_freight_cost_temp_price(j).currency_code;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).delivery_leg_id := x_freight_cost_temp_price(j).delivery_leg_id;
                      l_between_cont_sum(l_in_between_containers(n).entity_id).delivery_id     := x_freight_cost_temp_price(j).delivery_id;
                    ELSE
                      l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount :=
                        l_between_cont_sum(l_in_between_containers(n).entity_id).total_amount +
                        x_freight_cost_main_price(j).total_amount;
                    END IF;

                END IF;

             END IF;

             EXIT WHEN n = l_in_between_containers.LAST;
             n := l_in_between_containers.NEXT(n);
           END LOOP;
           END IF;
           END IF;

           EXIT WHEN j = l_price_last;
           IF p_save_flag = 'M' THEN
              j := x_freight_cost_main_price.NEXT(j);
           ELSE
              j := x_freight_cost_temp_price.NEXT(j);
           END IF;

         END LOOP;
         END IF;

      END IF;

      EXIT WHEN i = g_rolledup_lines.LAST;
      i := g_rolledup_lines.NEXT(i);
   END LOOP;

   IF l_container_summary.COUNT > 0 OR l_between_cont_sum.COUNT > 0 THEN

    get_fc_type_id(
           p_line_type_code => 'FTESUMMARY',
           p_charge_subtype_code  => 'SUMMARY',
           x_freight_cost_type_id  =>  l_freight_cost_type_id,
           x_return_status  =>  l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
       END IF;
    ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
    END IF;

   END IF;

   -- Use l_container_summary to add to fc records

   IF l_container_summary.COUNT > 0 THEN

       l_main_price_index       := l_curr_fc_count;
       --l_freight_cost_type_id := get_fc_type_id(

       l := l_container_summary.FIRST;
       LOOP

       l_main_price_index := l_main_price_index + 1;
       IF p_save_flag = 'M' THEN  --  Populate appropriate columns

            x_freight_cost_main_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_main_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_main_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_main_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_main_price(l_main_price_index).delivery_leg_id := l_container_summary(l).delivery_leg_id;
            x_freight_cost_main_price(l_main_price_index).delivery_id := l_container_summary(l).delivery_id;
            x_freight_cost_main_price(l_main_price_index).total_amount := round(l_container_summary(l).total_amount,2);
            x_freight_cost_main_price(l_main_price_index).currency_code := l_container_summary(l).currency_code;

       ELSE

            x_freight_cost_temp_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_temp_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_temp_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_temp_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_temp_price(l_main_price_index).delivery_id := l_container_summary(l).delivery_id;

            x_freight_cost_temp_price(l_main_price_index).total_amount := round(l_container_summary(l).total_amount,2);
            x_freight_cost_temp_price(l_main_price_index).currency_code := l_container_summary(l).currency_code;

       END IF;

       EXIT WHEN l = l_container_summary.LAST;
       l := l_container_summary.NEXT(l);
       END LOOP;
   END IF;

   -- Use l_in_between_containers to add to fc records

   IF l_between_cont_sum.COUNT > 0 THEN

       IF p_save_flag = 'M' THEN
         l_curr_fc_count := x_freight_cost_main_price.COUNT;
       ELSE
         l_curr_fc_count := x_freight_cost_temp_price.COUNT;
       END IF;

       l_main_price_index       := l_curr_fc_count;
       --l_freight_cost_type_id := get_fc_type_id(

       l := l_between_cont_sum.FIRST;
       LOOP

       IF NOT l_container_summary.EXISTS(l) THEN
       l_main_price_index := l_main_price_index + 1;
       IF p_save_flag = 'M' THEN  --  Populate appropriate columns

            x_freight_cost_main_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_main_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_main_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_main_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_main_price(l_main_price_index).delivery_leg_id := l_between_cont_sum(l).delivery_leg_id;
            x_freight_cost_main_price(l_main_price_index).delivery_id := l_between_cont_sum(l).delivery_id;

            x_freight_cost_main_price(l_main_price_index).total_amount := round(l_between_cont_sum(l).total_amount,2);
            x_freight_cost_main_price(l_main_price_index).currency_code := l_between_cont_sum(l).currency_code;

       ELSE

            x_freight_cost_temp_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_temp_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_temp_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_temp_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_temp_price(l_main_price_index).delivery_id := l_between_cont_sum(l).delivery_id;

            x_freight_cost_temp_price(l_main_price_index).total_amount := round(l_between_cont_sum(l).total_amount,2);
            x_freight_cost_temp_price(l_main_price_index).currency_code := l_between_cont_sum(l).currency_code;

       END IF;
       END IF;

       EXIT WHEN l = l_between_cont_sum.LAST;
       l := l_between_cont_sum.NEXT(l);
       END LOOP;
   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'add_other_container_summary');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('add_other_container_summary',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'add_other_container_summary');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('add_other_container_summary',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'add_other_container_summary');
END add_other_container_summary;


--      This is the QP engine output post processing API
--      It analyzes the QP engine output by looking at the output lines and input lines
--      It uses l_pricing_dual_instances,l_intersection_rows,l_shpmnt_toplevel_rows
--      and g_shipment_line_rows to deconsolidate freight costs to the proper level
--      It creates freight_costs main/temp record and sends back
--      Looks up delivery detail info from g_shipment_line_rows

PROCEDURE process_qp_output (
        p_qp_output_line_rows     IN     QP_PREQ_GRP.LINE_TBL_TYPE,  -- line_index = input_index
        p_qp_output_detail_rows   IN     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        p_pricing_engine_input    IN     pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN     pricing_dual_instance_tab_type,
        p_pattern_rows            IN     top_level_pattern_tab_type,
        p_shpmnt_toplevel_rows    IN     shpmnt_content_tab_type,
        p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or MAIN table
        p_rate_basis              IN     VARCHAR2 DEFAULT NULL,
        x_freight_cost_main_price  OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge OUT NOCOPY Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     OUT NOCOPY     Freight_Cost_Main_Tab_Type,  -- For update of SUMMARY records
        x_summary_lanesched_price      OUT NOCOPY     NUMBER,   -- Only in case of 'T'
        x_summary_lanesched_price_uom  OUT NOCOPY     VARCHAR2,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

        CURSOR c_get_fc_id(p_dleg_id IN NUMBER) IS
        SELECT freight_cost_id,created_by,creation_date
        FROM   wsh_freight_costs
        WHERE  delivery_leg_id = p_dleg_id
        AND delivery_detail_id IS NULL
        AND    line_type_code = 'SUMMARY';

        CURSOR c_get_dlv_id(c_dleg_id IN NUMBER) IS
        SELECT delivery_id
        FROM   wsh_delivery_legs
        WHERE  delivery_leg_id = c_dleg_id;

        j                         NUMBER:=0;
        k                         NUMBER:=0;
        l                         NUMBER:=0;
        l_freight_cost_id          NUMBER:=0;
        l_freight_cost_type_id     NUMBER:=0;
        l_curr_fc_count           NUMBER:=0;
        l_created_by              NUMBER:=0;
        l_creation_date           DATE;
        l_main_price_index        NUMBER:=0;
        l_temp_price_index        NUMBER:=0;
        l_price_count             NUMBER:=0;
        l_charge_count            NUMBER:=0;
        l_entity_id               NUMBER:=0;
        l_delivery_id             NUMBER:=0;
        l_return_status           VARCHAR2(1);
        l_container_summary       container_sum_tab_type;
        l_container_summary_dummy container_sum_tab_type;

        l_currency_code           VARCHAR2(30);

        l_temp_amt                NUMBER;

        l_fc_dleg_rows            dlvy_leg_summ_tab_type;
        l_dlv_id                  NUMBER;
        l_basis_meaning             VARCHAR2(100);
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;


BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'process_qp_output','start');

   -- This API will result in one qp output line per instance
   -- It will delete other output lines and associated engine output line details

      j := p_qp_output_line_rows.FIRST;  -- Can still have more than one output_line_row per instance
                                         -- if there is no pricing objective

      l_currency_code := p_qp_output_line_rows(j).currency_code;
      LOOP
      -- {

         -- If there are still more than one output line for an instance
         -- we should put as many freight cost records for the associated pattern(s)
         -- No special logic required

         IF p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id IS NOT NULL THEN
         -- {

            IF p_save_flag = 'M' THEN
               l_price_count := x_freight_cost_main_price.COUNT;
               l_charge_count := x_freight_cost_main_charge.COUNT;
            ELSE
               l_price_count := x_freight_cost_temp_price.COUNT;
               l_charge_count := x_freight_cost_temp_charge.COUNT;
            END IF;

            IF p_save_flag = 'M' THEN
               l_entity_id := p_shpmnt_toplevel_rows(p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id).delivery_leg_id;
               l_delivery_id := g_shipment_line_rows(p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id).delivery_id;
            ELSE
               l_entity_id := g_shipment_line_rows(p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id).delivery_id;
               l_delivery_id := g_shipment_line_rows(p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id).delivery_id;
            END IF;

                 prepare_fc_records (
                    p_delivery_detail_id    =>  p_pricing_engine_input(p_qp_output_line_rows(j).line_index).loose_item_id,
                    p_delivery_id           =>  l_delivery_id,
                    p_entity_id             =>  l_entity_id,
                    p_qp_output_line_row    =>  p_qp_output_line_rows(j) ,
                    p_qp_output_detail_rows => p_qp_output_detail_rows,
                    p_pricing_engine_input  => p_pricing_engine_input,
                    p_save_flag             => p_save_flag,
                    p_rate_basis            => p_rate_basis,
                    x_container_summary     => l_container_summary_dummy,
                    x_fc_dleg_rows          => l_fc_dleg_rows,
                    x_freight_cost_main_price  =>  x_freight_cost_main_price,
                    x_freight_cost_temp_price  =>  x_freight_cost_temp_price,
                    x_freight_cost_main_charge =>  x_freight_cost_main_charge,
                    x_freight_cost_temp_charge =>  x_freight_cost_temp_charge,
                    x_return_status           => l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Loose Item ');
                           raise FTE_FREIGHT_PRICING_UTIL.g_prepare_fc_rec_failed;
                        END IF;
                     ELSE
                        IF p_save_flag = 'M' THEN
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_main_price.COUNT - l_price_count || ' Main fc base price Records created ');
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_main_charge.COUNT - l_charge_count || ' Main fc charge Records created ');
                        ELSE
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_temp_price.COUNT - l_price_count || ' Temp fc base price Records created ');
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_temp_charge.COUNT - l_charge_count || ' Temp fc charge Records created ');
                        END IF;
                     END IF;


         -- }
         ELSE
         -- {
         k := p_pattern_rows.FIRST;
         LOOP
          -- {

              IF p_pattern_rows(k).instance_index = p_pricing_engine_input(p_qp_output_line_rows(j).line_index).instance_index THEN

                 IF p_save_flag = 'M' THEN
                    l_price_count := x_freight_cost_main_price.COUNT;
                    l_charge_count := x_freight_cost_main_charge.COUNT;
                 ELSE
                    l_price_count := x_freight_cost_temp_price.COUNT;
                    l_charge_count := x_freight_cost_temp_charge.COUNT;
                 END IF;

                 IF p_save_flag = 'M' THEN
                    l_entity_id := p_shpmnt_toplevel_rows(p_pattern_rows(k).content_id).delivery_leg_id;
                    l_delivery_id := g_shipment_line_rows(p_pattern_rows(k).content_id).delivery_id;
                 ELSE
                    l_entity_id := g_shipment_line_rows(p_pattern_rows(k).content_id).delivery_id;
                    l_delivery_id := g_shipment_line_rows(p_pattern_rows(k).content_id).delivery_id;
                 END IF;

                 prepare_fc_records (
                    p_delivery_detail_id    =>  p_pattern_rows(k).content_id,
                    p_delivery_id           =>  l_delivery_id,
                    p_entity_id             =>  l_entity_id,
                    p_qp_output_line_row    =>  p_qp_output_line_rows(j) ,
                    p_qp_output_detail_rows => p_qp_output_detail_rows,
                    p_pricing_engine_input  => p_pricing_engine_input,
                    p_grouping_level        => p_pricing_dual_instances(p_pattern_rows(k).instance_index).grouping_level,
                    p_aggregation           => p_pricing_dual_instances(p_pattern_rows(k).instance_index).aggregation,
                    p_save_flag             => p_save_flag,
                    p_rate_basis            => p_rate_basis,
                    x_container_summary     => l_container_summary,
                    x_fc_dleg_rows          => l_fc_dleg_rows,
                    x_freight_cost_main_price  =>  x_freight_cost_main_price,
                    x_freight_cost_temp_price  =>  x_freight_cost_temp_price,
                    x_freight_cost_main_charge =>  x_freight_cost_main_charge,
                    x_freight_cost_temp_charge =>  x_freight_cost_temp_charge,
                    x_return_status           => l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Container '||p_pattern_rows(k).content_id);
                           raise FTE_FREIGHT_PRICING_UTIL.g_prepare_fc_rec_failed;
                        END IF;
                     ELSE
                        IF p_save_flag = 'M' THEN
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_main_price.COUNT - l_price_count || ' Main fc base price Records created ');
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_main_charge.COUNT - l_charge_count || ' Main fc charge Records created ');
                        ELSE
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_temp_price.COUNT - l_price_count || ' Temp fc base price Records created ');
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_temp_charge.COUNT - l_charge_count || ' Temp fc charge Records created ');
                        END IF;
                     END IF;

              END IF;

              EXIT WHEN k = p_pattern_rows.LAST;
              k := p_pattern_rows.NEXT(k);
          -- }
         END LOOP;
         -- }
         END IF;  --  Loose item

         EXIT WHEN j = p_qp_output_line_rows.LAST;
         j := p_qp_output_line_rows.NEXT(j);
      -- }
      END LOOP;

      get_fc_type_id(
                      p_line_type_code => 'FTESUMMARY',
                      p_charge_subtype_code  => 'SUMMARY',
                      x_freight_cost_type_id  =>  l_freight_cost_type_id,
                      x_return_status  =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed;
         END IF;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||l_freight_cost_type_id);
      END IF;

      IF l_container_summary.COUNT > 0 THEN

       IF p_save_flag = 'M' THEN
          l_curr_fc_count := x_freight_cost_main_price.COUNT;
       ELSE
          l_curr_fc_count := x_freight_cost_temp_price.COUNT;
       END IF;

       l_main_price_index       := l_curr_fc_count;
       --l_freight_cost_type_id := get_fc_type_id(

       l := l_container_summary.FIRST;
       LOOP

       IF nvl(l_container_summary(l).total_amount,0) <> 0 THEN

       l_main_price_index := l_main_price_index + 1;
       Get_Basis_Meaning ( p_basis => l_container_summary(l).bbasis,
                           x_basis_meaning => l_basis_meaning);

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Before setting billable columns in main for basis :'||l_basis_meaning);
       IF p_save_flag = 'M' THEN  --  Populate appropriate columns

            x_freight_cost_main_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_main_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_main_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_main_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_main_price(l_main_price_index).delivery_leg_id := l_container_summary(l).delivery_leg_id;
            x_freight_cost_main_price(l_main_price_index).delivery_id := l_container_summary(l).delivery_id;

            x_freight_cost_main_price(l_main_price_index).total_amount := round(l_container_summary(l).total_amount,2);
            --x_freight_cost_main_price(l_main_price_index).currency_code := l_currency_code;
            x_freight_cost_main_price(l_main_price_index).currency_code := l_container_summary(l).currency_code;
            x_freight_cost_main_price(l_main_price_index).billable_quantity := l_container_summary(l).bquantity;
            x_freight_cost_main_price(l_main_price_index).billable_uom := l_container_summary(l).buom;
            x_freight_cost_main_price(l_main_price_index).billable_basis := l_basis_meaning;
       ELSE

            x_freight_cost_temp_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_temp_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_temp_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_temp_price(l_main_price_index).delivery_detail_id := l;
            x_freight_cost_temp_price(l_main_price_index).delivery_id := l_container_summary(l).delivery_id;

            x_freight_cost_temp_price(l_main_price_index).total_amount := round(l_container_summary(l).total_amount,2);
            --x_freight_cost_temp_price(l_main_price_index).currency_code := l_currency_code;
            x_freight_cost_temp_price(l_main_price_index).currency_code := l_container_summary(l).currency_code;
            x_freight_cost_temp_price(l_main_price_index).billable_quantity := l_container_summary(l).bquantity;
            x_freight_cost_temp_price(l_main_price_index).billable_basis := l_basis_meaning;
            x_freight_cost_temp_price(l_main_price_index).billable_uom := l_container_summary(l).buom;

       END IF;
       END IF;

       EXIT WHEN l = l_container_summary.LAST;
       l := l_container_summary.NEXT(l);
       END LOOP;

      -- Here need to create additional summary fc record for all containers
      -- in this shipment_pricing session irrespective of their level in the hierarchy
      -- Applicable only if atleast one top level container summary record has been created

       IF p_save_flag = 'M' THEN
          l_price_count := x_freight_cost_main_price.COUNT;
       ELSE
          l_price_count := x_freight_cost_temp_price.COUNT;
       END IF;

       add_other_container_summary (
                        p_save_flag                 =>  p_save_flag,
                        x_freight_cost_main_price   =>  x_freight_cost_main_price,
                        x_freight_cost_temp_price   =>  x_freight_cost_temp_price,
                        x_return_status             =>  l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           raise FTE_FREIGHT_PRICING_UTIL.g_other_cont_summ_failed;
                        END IF;
                     ELSE
                        IF p_save_flag = 'M' THEN
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_main_price.COUNT - l_price_count || ' Non top level container summary records created');
                        ELSE
                           FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,x_freight_cost_temp_price.COUNT - l_price_count || ' Non top level container summary records created');
                        END IF;
                     END IF;

      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_container_summary.COUNT || ' Top level Container Summary fc Records created ');

      IF l_fc_dleg_rows.COUNT > 0 THEN

       IF p_save_flag = 'M' THEN
          l_main_price_index := 0;
       ELSE
          l_main_price_index := x_freight_cost_temp_price.COUNT;
       END IF;

      --l_main_price_index := 0;
      l := l_fc_dleg_rows.FIRST;  --  Can be delivery level also for 'T'
      LOOP

         l_main_price_index := l_main_price_index + 1;
         IF p_save_flag = 'M' THEN  --  Populate appropriate columns

            OPEN c_get_fc_id(l);
            FETCH c_get_fc_id INTO l_freight_cost_id,l_created_by,l_creation_date;
            CLOSE c_get_fc_id;

            OPEN  c_get_dlv_id(l);
            FETCH c_get_dlv_id INTO l_dlv_id;
            CLOSE c_get_dlv_id;

            --l_main_price_index := 1;
            x_fc_main_update_rows(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_fc_main_update_rows(l_main_price_index).freight_cost_id := l_freight_cost_id;
            x_fc_main_update_rows(l_main_price_index).created_by := l_created_by;
            x_fc_main_update_rows(l_main_price_index).creation_date := l_creation_date;
            x_fc_main_update_rows(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_fc_main_update_rows(l_main_price_index).line_type_code := 'SUMMARY';
            x_fc_main_update_rows(l_main_price_index).delivery_leg_id := l;
            x_fc_main_update_rows(l_main_price_index).currency_code := l_currency_code;
            x_fc_main_update_rows(l_main_price_index).total_amount := round(l_fc_dleg_rows(l).summary_amount,2);
            -- WSH wants to see the summary record. Hence unit_amount and delivery_id is needed(12/20/02)
            x_fc_main_update_rows(l_main_price_index).unit_amount := round(l_fc_dleg_rows(l).summary_amount,2);
            x_fc_main_update_rows(l_main_price_index).delivery_id := l_dlv_id;

         -- ELSIF p_save_flag = 'T' THEN  --  Populate appropriate columns
         ELSE              -- VVP (OM Est change)

            --l_temp_price_index := x_freight_cost_temp_price.COUNT + 1;
            /*
            x_freight_cost_temp_price(l_temp_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_temp_price(l_temp_price_index).freight_cost_id := l_freight_cost_id;
            x_freight_cost_temp_price(l_temp_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_temp_price(l_temp_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_temp_price(l_temp_price_index).delivery_id := l;
            x_freight_cost_temp_price(l_temp_price_index).currency_code := l_currency_code;
            x_freight_cost_temp_price(l_temp_price_index).total_amount := round(l_fc_dleg_rows(l).summary_amount,2);
            */
            x_freight_cost_temp_price(l_main_price_index).freight_cost_type_id := l_freight_cost_type_id;
            x_freight_cost_temp_price(l_main_price_index).freight_cost_id := l_freight_cost_id;
            x_freight_cost_temp_price(l_main_price_index).charge_source_code := 'PRICING_ENGINE';
            x_freight_cost_temp_price(l_main_price_index).line_type_code := 'SUMMARY';
            x_freight_cost_temp_price(l_main_price_index).delivery_id := l;
            x_freight_cost_temp_price(l_main_price_index).currency_code := l_currency_code;
            x_freight_cost_temp_price(l_main_price_index).total_amount := round(l_fc_dleg_rows(l).summary_amount,2);
            x_freight_cost_temp_price(l_main_price_index).unit_amount := round(l_fc_dleg_rows(l).summary_amount,2);

         END IF;

         EXIT WHEN l = l_fc_dleg_rows.LAST;
         l := l_fc_dleg_rows.NEXT(l);
      END LOOP;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_fc_dleg_rows.COUNT || ' Delivery Leg Summary fc Records created ');

      -- IF p_save_flag = 'T' THEN
      IF p_save_flag <> 'M' THEN       -- VVP  (OM Est change)
         -- Need to send back lane/sched level summary amount
         -- which will be equal to l_fc_dleg_rows(l).summary_amount
         -- as in this case only one entity can be there per call

         -- bug 3373643 : the above assumption is no longer true for J, because
         -- it is possible to assign multiple deliveries to trips first and then do service compare
         -- from trip workbench. So we must take a sum of summary amounts.
         -- I am adding the if condition, only to isolate the problem from cases where the above assumption
         -- is still valid

        l_temp_amt :=0;
        IF (l_fc_dleg_rows.COUNT > 1) THEN
           l := l_fc_dleg_rows.FIRST;
           LOOP

               l_temp_amt      :=   l_temp_amt + l_fc_dleg_rows(l).summary_amount;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                       'l='||l||' summary='||l_fc_dleg_rows(l).summary_amount);

             EXIT WHEN l = l_fc_dleg_rows.LAST;
             l := l_fc_dleg_rows.NEXT(l);
           END LOOP;
           x_summary_lanesched_price      :=   round(l_temp_amt,2);
           x_summary_lanesched_price_uom  :=   l_currency_code;

        ELSE
           -- original code (bug 3373643)
           x_summary_lanesched_price      :=   round(l_fc_dleg_rows(l).summary_amount,2);
           x_summary_lanesched_price_uom  :=   l_currency_code;
           l_temp_amt := round(l_fc_dleg_rows(l).summary_amount,2); --for debug only
        END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'x_summary_lanesched_price='||round(l_temp_amt,2));

      END IF;
      ELSE
          raise FTE_FREIGHT_PRICING_UTIL.g_dleg_sum_not_created;
      END IF; -- l_fc_dleg_rows.COUNT > 0
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_prepare_fc_rec_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_qp_output',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_prepare_fc_rec_failed');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'prepare_fc_rec failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_other_cont_summ_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_qp_output',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_other_cont_summ_failed');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'other_cont_sum failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_fc_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_qp_output',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_fc_type_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_dleg_sum_not_created THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_qp_output',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_dleg_sum_not_created');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Delivery summary not created ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_qp_output',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_qp_output');

END process_qp_output;

--  Start printing procedures

PROCEDURE print_top_level_detail (
        p_first_level_rows        IN    shpmnt_content_tab_type, -- Will get indexed on delivery_detail_id
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_first_level_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<TOP_LEVEL_DETAIL>');
   i := p_first_level_rows.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg =>
	'content_id:'||p_first_level_rows(i).content_id
	||' delivery_leg_id:'||p_first_level_rows(i).delivery_leg_id
	||' container_flag:'||p_first_level_rows(i).container_flag
	||' container_type_code:'||p_first_level_rows(i).container_type_code
	||' det gross wt:'||g_shipment_line_rows(p_first_level_rows(i).content_id).gross_weight
	||' '||g_shipment_line_rows(p_first_level_rows(i).content_id).weight_uom_code
	||' top level wt:'||p_first_level_rows(i).gross_weight
	||' '||p_first_level_rows(i).weight_uom
	||' wdd_volume:'||p_first_level_rows(i).wdd_volume
	||' '||p_first_level_rows(i).wdd_volume_uom_code
	||' wdd_net_weight:'||p_first_level_rows(i).wdd_net_weight
	||' wdd_tare_weight:'||p_first_level_rows(i).wdd_tare_weight
	||' wdd_gross_weight:'||p_first_level_rows(i).wdd_gross_weight
	||' '||p_first_level_rows(i).wdd_weight_uom_code);

      EXIT WHEN i=p_first_level_rows.LAST;
      i := p_first_level_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</TOP_LEVEL_DETAIL>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_top_level_detail',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_top_level_detail;


PROCEDURE print_rolledup_lines (
        p_rolledup_lines          IN    rolledup_line_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_rolledup_lines.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<ROLLEDUP_LINES>');
   i := p_rolledup_lines.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'delivery_detail_id : '||p_rolledup_lines(i).delivery_detail_id||' category_id : '||p_rolledup_lines(i).category_id||' rate_basis : '||
   p_rolledup_lines(i).rate_basis||'container_id : '||p_rolledup_lines(i).container_id||' master_container_id : '||p_rolledup_lines(i).master_container_id||'line_quantity : '||
   p_rolledup_lines(i).line_quantity||' line_uom : '||p_rolledup_lines(i).line_uom);

      EXIT WHEN i=p_rolledup_lines.LAST;
      i := p_rolledup_lines.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</ROLLEDUP_LINES>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_rolledup_lines',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
END print_rolledup_lines;


PROCEDURE print_top_level_pattern (
        p_pattern_rows            IN    top_level_pattern_tab_type, -- Will get indexed on delivery_detail_id
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_pattern_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<PATTERNS>');
   i := p_pattern_rows.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'pattern_index : '||p_pattern_rows(i).pattern_index||' pattern_no : '||p_pattern_rows(i).pattern_no||' services_hash : '||
      p_pattern_rows(i).services_hash||' content_id : '||p_pattern_rows(i).content_id||' instance_index : '||p_pattern_rows(i).instance_index);

      EXIT WHEN i=p_pattern_rows.LAST;
      i := p_pattern_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</PATTERNS>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_top_level_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_top_level_pattern;

PROCEDURE print_dual_instances (
        p_dual_instances          IN    pricing_dual_instance_tab_type, -- Will get indexed on delivery_detail_id
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_dual_instances.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<INSTANCES>');
   i := p_dual_instances.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(
      p_msg => 'instance_index : '||p_dual_instances(i).instance_index||' pattern_no : '||p_dual_instances(i).pattern_no||' services_hash : '||p_dual_instances(i).services_hash||
      ' grouping_level : '||p_dual_instances(i).grouping_level||' aggregation : '||p_dual_instances(i).aggregation||' objective : '||p_dual_instances(i).objective||' count_pattern : '
       ||p_dual_instances(i).count_pattern||' loose_item_flag : '||p_dual_instances(i).loose_item_flag);

      EXIT WHEN i=p_dual_instances.LAST;
      i := p_dual_instances.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</INSTANCES>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_dual_instances',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_dual_instances;

PROCEDURE print_qp_output_lines (
        p_engine_output_line             IN    QP_PREQ_GRP.LINE_TBL_TYPE,
        p_engine_output_detail           IN    QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        p_return_status                  IN    VARCHAR2 ,
        x_return_status                  OUT NOCOPY    VARCHAR2 )
IS

       I     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Return Status text '||  p_return_status);

FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<Request_Line_Information>');

I := p_engine_output_line.FIRST;
IF I IS NOT NULL THEN
 LOOP
  FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Line Index: '||p_engine_output_line(I).line_index);
  FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Unit_price: '||p_engine_output_line(I).unit_price);
  FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Adjusted Unit Price: '||p_engine_output_line(I).adjusted_unit_price);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Percent price: '||p_engine_output_line(I).percent_price);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Pricing status code: '||p_engine_output_line(I).status_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Pricing status text: '||p_engine_output_line(I).status_text);
 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-------------------------------- -------------------');
  EXIT WHEN I = p_engine_output_line.LAST;
  I := p_engine_output_line.NEXT(I);
 END LOOP;
END IF;
FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</Request_Line_Information>');
--FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => '</Request Line Information>');

I := p_engine_output_detail.FIRST;

FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_DBG,'<Price_List_Discount_Information>');

IF I IS NOT NULL THEN
 LOOP
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Line Index: '||p_engine_output_detail(I).line_index);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Line Detail Index: '||p_engine_output_detail(I).line_detail_index);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Line Detail Type:'||p_engine_output_detail(I).line_detail_type_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'List Header Id: '||p_engine_output_detail(I).list_header_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'List Line Id: '||p_engine_output_detail(I).list_line_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'List Line Type Code: '||p_engine_output_detail(I).list_line_type_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Charge Type Code: '||p_engine_output_detail(I).charge_type_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Charge Sub Type Code: '||p_engine_output_detail(I).charge_subtype_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adjustment Amount : '||p_engine_output_detail(I).adjustment_amount);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Line Quantity : '||p_engine_output_detail(I).line_quantity);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Operand Calculation Code: '||p_engine_output_detail(I).Operand_calculation_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Operand value: '||p_engine_output_detail(I).operand_value);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Automatic Flag: '||p_engine_output_detail(I).automatic_flag);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Override Flag: '||p_engine_output_detail(I).override_flag);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'status_code: '||p_engine_output_detail(I).status_code);
  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'status text: '||p_engine_output_detail(I).status_text);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-------------------------------- -------------------');
  EXIT WHEN I =  p_engine_output_detail.LAST;
  I := p_engine_output_detail.NEXT(I);
 END LOOP;
END IF;
FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_DBG,'</Price_List_Discount_Information>');
   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_qp_output_lines',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_qp_output_lines;

PROCEDURE print_engine_rows (
        p_engine_rows             IN    pricing_engine_input_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_engine_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<ENGINE_ROWS>');
   i := p_engine_rows.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg =>
	'input_index:'||p_engine_rows(i).input_index
	||' instance_index:'||p_engine_rows(i).instance_index
	||' Loose item id:'||p_engine_rows(i).loose_item_id
	||' category_id:'||p_engine_rows(i).category_id
	||' basis:'||p_engine_rows(i).basis
	||' line_quantity:'||p_engine_rows(i).line_quantity
	||' line_uom:'||p_engine_rows(i).line_uom
	||' loose_item_flag:'||p_engine_rows(i).loose_item_flag
	||' container_type_code:'||p_engine_rows(i).container_type_code);

      EXIT WHEN i=p_engine_rows.LAST;
      i := p_engine_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</ENGINE_ROWS>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_engine_rows',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_engine_rows;

PROCEDURE print_attribute_rows (
        p_attribute_rows          IN    pricing_attribute_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_attribute_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_INF,'<ATTRIBUTE_ROWS>');
   i := p_attribute_rows.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'attribute_index : '||p_attribute_rows(i).attribute_index||' input_index : '||p_attribute_rows(i).input_index||' attribute_name : '||
      p_attribute_rows(i).attribute_name||' attribute_value : '||p_attribute_rows(i).attribute_value);

      EXIT WHEN i=p_attribute_rows.LAST;
      i := p_attribute_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_INF,'</ATTRIBUTE_ROWS>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_attribute_rows',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_attribute_rows;

PROCEDURE print_fc_main_rows (
        p_fc_main_rows            IN    Freight_Cost_Main_Tab_Type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_fc_main_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_INF,'<FC_Records>');
   i := p_fc_main_rows.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'fc type id : '||p_fc_main_rows(i).freight_cost_type_id||' line type code : '||
      p_fc_main_rows(i).line_type_code||' detail id : '||p_fc_main_rows(i).delivery_detail_id||' delivery leg : '||
      p_fc_main_rows(i).delivery_leg_id||' quantity : '||p_fc_main_rows(i).quantity||' uom : '||p_fc_main_rows(i).uom||' unit amount : '||p_fc_main_rows(i).unit_amount||'total amount : '||
      p_fc_main_rows(i).total_amount||' currency code : '||p_fc_main_rows(i).currency_code||' Charge unit value : '||p_fc_main_rows(i).charge_unit_value||' Delivery id : '||p_fc_main_rows(i).delivery_id);

      EXIT WHEN i=p_fc_main_rows.LAST;
      i := p_fc_main_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(FTE_FREIGHT_PRICING_UTIL.G_INF,'</FC_Records>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_fc_main_rows',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_fc_main_rows;

PROCEDURE print_fc_temp_rows (
        p_fc_temp_rows            IN    Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_fc_temp_rows.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(l_log_level,'<FC_TEMP_Records>');
   i := p_fc_temp_rows.FIRST;
   LOOP

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'-------------');
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'FREIGHT_COST_ID='||p_fc_temp_rows(i).FREIGHT_COST_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'FREIGHT_COST_TYPE_ID='||p_fc_temp_rows(i).FREIGHT_COST_TYPE_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'UNIT_AMOUNT='||p_fc_temp_rows(i).UNIT_AMOUNT);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CALCULATION_METHOD='||p_fc_temp_rows(i).CALCULATION_METHOD);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'UOM='||p_fc_temp_rows(i).UOM);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'QUANTITY='||p_fc_temp_rows(i).QUANTITY);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'TOTAL_AMOUNT='||p_fc_temp_rows(i).TOTAL_AMOUNT);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CURRENCY_CODE='||p_fc_temp_rows(i).CURRENCY_CODE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CONVERSION_DATE='||p_fc_temp_rows(i).CONVERSION_DATE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CONVERSION_RATE='||p_fc_temp_rows(i).CONVERSION_RATE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CONVERSION_TYPE_CODE='||p_fc_temp_rows(i).CONVERSION_TYPE_CODE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'TRIP_ID='||p_fc_temp_rows(i).TRIP_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'STOP_ID='||p_fc_temp_rows(i).STOP_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'DELIVERY_ID='||p_fc_temp_rows(i).DELIVERY_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'DELIVERY_LEG_ID='||p_fc_temp_rows(i).DELIVERY_LEG_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'DELIVERY_DETAIL_ID='||p_fc_temp_rows(i).DELIVERY_DETAIL_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'LINE_TYPE_CODE='||p_fc_temp_rows(i).LINE_TYPE_CODE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'PRICING_LIST_HEADER_ID='||p_fc_temp_rows(i).PRICING_LIST_HEADER_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'PRICING_LIST_LINE_ID='||p_fc_temp_rows(i).PRICING_LIST_LINE_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'APPLIED_TO_CHARGE_ID='||p_fc_temp_rows(i).APPLIED_TO_CHARGE_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CHARGE_UNIT_VALUE='||p_fc_temp_rows(i).CHARGE_UNIT_VALUE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'CHARGE_SOURCE_CODE='||p_fc_temp_rows(i).CHARGE_SOURCE_CODE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'ESTIMATED_FLAG='||p_fc_temp_rows(i).ESTIMATED_FLAG);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'COMPARISON_REQUEST_ID='||p_fc_temp_rows(i).COMPARISON_REQUEST_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'LANE_ID='||p_fc_temp_rows(i).LANE_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'SCHEDULE_ID='||p_fc_temp_rows(i).SCHEDULE_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'MOVED_TO_MAIN_FLAG='||p_fc_temp_rows(i).MOVED_TO_MAIN_FLAG);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'SERVICE_TYPE_CODE='||p_fc_temp_rows(i).SERVICE_TYPE_CODE);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'COMMODITY_CATEGORY_ID='||p_fc_temp_rows(i).COMMODITY_CATEGORY_ID);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'BILLABLE_QUANTITY='||p_fc_temp_rows(i).BILLABLE_QUANTITY);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'BILLABLE_UOM='||p_fc_temp_rows(i).BILLABLE_UOM);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'BILLABLE_BASIS='||p_fc_temp_rows(i).BILLABLE_BASIS);


	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'-------------');

      EXIT WHEN i=p_fc_temp_rows.LAST;
      i := p_fc_temp_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(l_log_level,'</FC_TEMP_Records>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_fc_temp_rows',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);

END print_fc_temp_rows;
--  End printing procedures

PROCEDURE rollup_container_hierarchy (
        p_container_id            IN     NUMBER,
        p_classification_code     IN     VARCHAR2,
        p_lane_basis              IN     VARCHAR2,
        p_lane_id                 IN     NUMBER,
        x_rolledup_lines          IN OUT NOCOPY rolledup_line_tab_type,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

     l_uom_ea			     VARCHAR2(30);
  l_api_name              CONSTANT VARCHAR2(30)   := 'rollup_container_hierarchy';
        i                     NUMBER:=0;
        l_category_id         NUMBER:=0;
        l_basis               VARCHAR2(30):=NULL;
        l_num_basis           NUMBER:=0;
        l_start_count         NUMBER:=0;
        l_detail_count        NUMBER:=0;
        l_return_status       VARCHAR2(1);

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'rollup_container_hierarchy','start');

       OPEN get_uom_for_each;
       FETCH get_uom_for_each INTO l_uom_ea;
       CLOSE get_uom_for_each;

	IF l_uom_ea is null THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After get_uom_for_each ');
          fte_freight_pricing_util.set_exception(l_api_name,l_log_level,'g_get_uom_for_each_failed');
          raise FND_API.G_EXC_ERROR;
	END IF;

   i := g_shipment_line_rows.FIRST;
   LOOP
      IF g_shipment_line_rows(i).parent_delivery_detail_id = p_container_id THEN

         IF ((g_shipment_line_rows(i).container_flag = 'Y' ) OR (g_shipment_line_rows(i).container_flag = 'C' ))THEN

            l_start_count := x_rolledup_lines.COUNT;
            rollup_container_hierarchy (
                p_container_id         =>  g_shipment_line_rows(i).delivery_detail_id,
                p_classification_code  =>  p_classification_code,
                p_lane_basis           =>  p_lane_basis,
                p_lane_id              =>  p_lane_id,
                x_rolledup_lines       =>  x_rolledup_lines,
                x_return_status        =>  l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Container '||g_shipment_line_rows(i).delivery_detail_id);
                           raise FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed;
                        END IF;
                ELSE
                        l_detail_count := x_rolledup_lines.COUNT - l_start_count;
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container '||g_shipment_line_rows(i).delivery_detail_id||' has '||l_detail_count||' rolled up lines');
                END IF;
         ELSE

            IF p_classification_code IS NOT NULL THEN

             IF (g_shipment_line_rows(i).inventory_item_id IS NULL
                 AND g_shipment_line_rows(i).comm_category_id IS NOT NULL) THEN
                 -- FTE J FTE estimate rate --
                 l_category_id := g_shipment_line_rows(i).comm_category_id;
             ELSIF (g_shipment_line_rows(i).inventory_item_id IS NULL
                 AND g_shipment_line_rows(i).comm_category_id IS NULL) THEN
                 -- FTE J one-time items --
                 l_category_id := get_default_category(p_classification_code=>p_classification_code);

                 IF (l_category_id IS NOT NULL) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                     'Default category id '||l_category_id||' got assigned to : '
                        || g_shipment_line_rows(i).delivery_detail_id);
                    g_shipment_line_rows(i).comm_category_id := l_category_id;
                 ELSE
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_LOG,
                        'No default category found ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_category_not_found;
                 END IF;

             ELSE

               OPEN get_category(g_shipment_line_rows(i).inventory_item_id,g_shipment_line_rows(i).organization_id,p_classification_code);
               -- There should be only one category for one classification code for an item-org
               FETCH get_category INTO l_category_id;
               IF get_category%NOTFOUND THEN
                  CLOSE get_category;
                  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Rolledup line  '||g_shipment_line_rows(i).delivery_detail_id);
                  -- FTE J --
                  -- Attempt to assign a default category and continue
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                  'Delivery detail has no commodity assignment. Try to get default category');
                 l_category_id := get_default_category(p_classification_code=>p_classification_code);
                 IF (l_category_id IS NULL) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_LOG,
                        'No default category found ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_category_not_found;
                 END IF;
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                    'Default category id '||l_category_id);
               ELSE
                 CLOSE get_category;
               END IF;

             END IF; -- if inventory_item_id is null

             OPEN get_category_basis(p_lane_id,l_category_id);
             FETCH get_category_basis INTO l_basis;
             CLOSE get_category_basis;

            ELSE

               l_category_id := g_default_category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Default category id (-9999)  got assigned to : '|| g_shipment_line_rows(i).delivery_detail_id||' as no classification code is found on the lane');

            END IF;

            IF l_basis IS NULL THEN
               l_basis := p_lane_basis;
            END IF;

            IF l_basis = 'CONTAINER' THEN
               l_num_basis := G_CONTAINER_BASIS;
            ELSIF l_basis = 'WEIGHT' THEN
               l_num_basis := G_WEIGHT_BASIS;
            ELSIF l_basis = 'VOLUME' THEN
               l_num_basis := G_VOLUME_BASIS;
            ELSE   -- NULL or non supported basis
               raise FTE_FREIGHT_PRICING_UTIL.g_invalid_basis;
            END IF;

            x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).delivery_detail_id := g_shipment_line_rows(i).delivery_detail_id;
            x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).container_id  := p_container_id;
            x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).category_id   := l_category_id;
            x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).rate_basis    := l_num_basis;

            g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).delivery_detail_id := g_shipment_line_rows(i).delivery_detail_id;
            g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).container_id  := p_container_id;
            g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).category_id   := l_category_id;
            g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).rate_basis    := l_num_basis;

            IF l_num_basis = G_CONTAINER_BASIS THEN

               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := 1;
               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := l_uom_ea;
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := 1;
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := l_uom_ea;
            ELSIF l_num_basis = G_WEIGHT_BASIS THEN

               --x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := g_shipment_line_rows(i).net_weight;
               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := nvl(g_shipment_line_rows(i).net_weight,g_shipment_line_rows(i).gross_weight);
               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := g_shipment_line_rows(i).weight_uom_code;
               --g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := g_shipment_line_rows(i).net_weight;
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := nvl(g_shipment_line_rows(i).net_weight,g_shipment_line_rows(i).gross_weight);
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := g_shipment_line_rows(i).weight_uom_code;
            ELSIF l_num_basis = G_VOLUME_BASIS THEN

               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := g_shipment_line_rows(i).volume;
               x_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := g_shipment_line_rows(i).volume_uom_code;
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_quantity := g_shipment_line_rows(i).volume;
               g_rolledup_lines(g_shipment_line_rows(i).delivery_detail_id).line_uom      := g_shipment_line_rows(i).volume_uom_code;
            END IF;

         END IF;
      END IF;

      EXIT WHEN i = g_shipment_line_rows.LAST;
      i := g_shipment_line_rows.NEXT(i);
   END LOOP;
   x_return_status := l_return_status;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_container_hierarchy',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_rollup_container_failed');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('rollup_container failed ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'rollup_container failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_category_not_found THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_container_hierarchy',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_category_not_found');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('category_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'category_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_container_hierarchy',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_invalid_basis');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_container_hierarchy',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_container_hierarchy');

END rollup_container_hierarchy;


PROCEDURE rollup_loose_item (
        p_loose_item_id           IN     NUMBER,
        p_classification_code     IN     VARCHAR2,
        p_lane_basis              IN     VARCHAR2,
        p_lane_id                 IN     NUMBER,
        x_rolledup_rec            IN OUT NOCOPY rolledup_line_rec_type,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

     l_uom_ea			     VARCHAR2(30);
  l_api_name              CONSTANT VARCHAR2(30)   := 'rollup_loose_item';
        i                     NUMBER:=0;
        l_category_id         NUMBER:=0;
        l_basis               VARCHAR2(30):=NULL;
        l_num_basis           NUMBER:=0;
        l_return_status       VARCHAR2(1);

        l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;

BEGIN
-- {

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'rollup_loose_item','start');

       OPEN get_uom_for_each;
       FETCH get_uom_for_each INTO l_uom_ea;
       CLOSE get_uom_for_each;

	IF l_uom_ea is null THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After get_uom_for_each ');
          fte_freight_pricing_util.set_exception(l_api_name,l_log_level,'g_get_uom_for_each_failed');
          raise FND_API.G_EXC_ERROR;
	END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_classification_code='||p_classification_code);
   IF p_classification_code IS NOT NULL THEN
   -- {
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_shipment_line_rows.COUNT='||g_shipment_line_rows.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_shipment_line_rows(p_loose_item_id).inventory_item_id ='||g_shipment_line_rows(p_loose_item_id).inventory_item_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_shipment_line_rows(p_loose_item_id).organization_id ='||g_shipment_line_rows(p_loose_item_id).organization_id);


      IF (g_shipment_line_rows(p_loose_item_id).inventory_item_id IS NULL
         AND g_shipment_line_rows(p_loose_item_id).comm_category_id IS NOT NULL) THEN
         -- FTE J FTE estimate rate --
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_shipment_line_rows(p_loose_item_id).comm_category_id='||g_shipment_line_rows(p_loose_item_id).comm_category_id);
         l_category_id := g_shipment_line_rows(p_loose_item_id).comm_category_id;
      ELSIF (g_shipment_line_rows(p_loose_item_id).inventory_item_id IS NULL
         AND g_shipment_line_rows(p_loose_item_id).comm_category_id IS NULL) THEN
                 -- FTE J one-time items --
                 l_category_id := get_default_category(p_classification_code=>p_classification_code);

                 IF (l_category_id IS NOT NULL) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                     'Default category id '||l_category_id||' got assigned to : '
                        || g_shipment_line_rows(p_loose_item_id).delivery_detail_id);
                    g_shipment_line_rows(p_loose_item_id).comm_category_id := l_category_id;
                 ELSE
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_LOG,
                        'No default category found ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_category_not_found;
                 END IF;
      ELSE

        OPEN get_category(g_shipment_line_rows(p_loose_item_id).inventory_item_id,g_shipment_line_rows(p_loose_item_id).organization_id,p_classification_code);
              -- There should be only one category for one classification code for an item-org
        FETCH get_category INTO l_category_id;
        IF get_category%NOTFOUND THEN
           CLOSE get_category;
           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Rolledup line  '||g_shipment_line_rows(p_loose_item_id).delivery_detail_id);
                  -- FTE J --
                  -- Attempt to assign a default category and continue
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                  'Delivery detail has no commodity assignment. Try to get default category');
                 l_category_id := get_default_category(p_classification_code=>p_classification_code);
                 IF (l_category_id IS NULL) THEN
                    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_LOG,
                        'No default category found ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_category_not_found;
                 END IF;
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,
                    'Default category id '||l_category_id);
        ELSE
          CLOSE get_category;
        END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_category_id='||l_category_id);

      END IF;

      OPEN get_category_basis(p_lane_id,l_category_id);
      FETCH get_category_basis INTO l_basis;
      CLOSE get_category_basis;

   -- }
   ELSE
   -- {

      l_category_id := g_default_category_id;
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Default category id got assigned to : '|| p_loose_item_id ||' as no classification code is found on the lane');

   -- }
   END IF;

   IF l_basis IS NULL THEN
      l_basis := p_lane_basis;
   END IF;

   IF l_basis = 'CONTAINER' THEN
      l_num_basis := G_CONTAINER_BASIS;
   ELSIF l_basis = 'WEIGHT' THEN
      l_num_basis := G_WEIGHT_BASIS;
   ELSIF l_basis = 'VOLUME' THEN
      l_num_basis := G_VOLUME_BASIS;
   ELSE   -- NULL or non supported basis
      raise FTE_FREIGHT_PRICING_UTIL.g_invalid_basis;
   END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'p_loose_item_id= '||p_loose_item_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'got basis');

   x_rolledup_rec.delivery_detail_id := p_loose_item_id;
   -- x_rolledup_rec.container_id       := null;
   x_rolledup_rec.container_id       := p_loose_item_id;
   x_rolledup_rec.category_id        := l_category_id;
   x_rolledup_rec.rate_basis         := l_num_basis;

   g_rolledup_lines(p_loose_item_id)   := x_rolledup_rec;
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'added to g_rolledup_lines');

   IF l_num_basis = G_CONTAINER_BASIS THEN

         x_rolledup_rec.line_quantity := 1;
         x_rolledup_rec.line_uom      := l_uom_ea;
         g_rolledup_lines(p_loose_item_id).line_quantity := 1;
         g_rolledup_lines(p_loose_item_id).line_uom      := l_uom_ea;

   ELSIF l_num_basis = G_WEIGHT_BASIS THEN
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'before x_rolledup_rec.line_quantity');

         x_rolledup_rec.line_quantity := nvl(g_shipment_line_rows(p_loose_item_id).net_weight,g_shipment_line_rows(p_loose_item_id).gross_weight);
         x_rolledup_rec.line_uom      := g_shipment_line_rows(p_loose_item_id).weight_uom_code;
         g_rolledup_lines(p_loose_item_id).line_quantity := x_rolledup_rec.line_quantity;
         g_rolledup_lines(p_loose_item_id).line_uom      := x_rolledup_rec.line_uom;

   ELSIF l_num_basis = G_VOLUME_BASIS THEN

         x_rolledup_rec.line_quantity := g_shipment_line_rows(p_loose_item_id).volume;
         x_rolledup_rec.line_uom      := g_shipment_line_rows(p_loose_item_id).volume_uom_code;
         g_rolledup_lines(p_loose_item_id).line_quantity := x_rolledup_rec.line_quantity;
         g_rolledup_lines(p_loose_item_id).line_uom      := x_rolledup_rec.line_uom;

   END IF;


   x_return_status := l_return_status;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_loose_item',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_rollup_container_failed');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('rollup_container failed ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'rollup_loose_item failed ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_category_not_found THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_loose_item',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_category_not_found');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('category_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'category_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_loose_item',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_invalid_basis');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('rollup_loose_item',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'rollup_loose_item');

-- }
END rollup_loose_item;

PROCEDURE search_matching_instance (
        --p_rolledup_category_rows  IN     WSH_UTIL_CORE.id_tab_type, -- Indexed on category_id
        --p_rolledup_category_basis IN     WSH_UTIL_CORE.id_tab_type,
        p_pattern_no              IN     NUMBER,
        p_grouping_level          IN     VARCHAR2,
        p_aggregation             IN     VARCHAR2,
        p_objective               IN     VARCHAR2,
        p_toplevel_charges_hash   IN     VARCHAR2, -- Top level requested additional services hash
        p_pricing_dual_instances  IN     pricing_dual_instance_tab_type,
        --p_pricing_engine_rows     IN     pricing_engine_input_tab_type,
        x_matched_instance_index  OUT NOCOPY     NUMBER,  --  -100 if does not match
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

        i                                NUMBER :=0;
        j                                NUMBER :=0;
        k                                NUMBER :=0;
        l                                NUMBER :=0;
        m                                NUMBER :=0;
        n                                NUMBER :=0;
        l_matched_index                  WSH_UTIL_CORE.id_tab_type;
        l_matched_category_rows          instance_category_tab_type;
        l_matched_basis_rows             instance_basis_tab_type;
        l_matched_instance_index         NUMBER :=0;
        l_hash_string                    VARCHAR2(50);
        l_index                          NUMBER:=0;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'search_matching_instance','start');

   i := p_pricing_dual_instances.FIRST;
   LOOP
         -- SC_WB(2) should match with MC_WB(5) and SC_VB(3) should match with MC_VB(6)
         -- as long as the pricing dual and pricing objectives match
         IF p_pricing_dual_instances(i).pattern_no = p_pattern_no THEN  -- Can match with more than one here
            l_matched_index(p_pricing_dual_instances(i).instance_index) := p_pricing_dual_instances(i).instance_index;
         ELSIF (p_pattern_no = G_PATTERN_2 OR p_pattern_no = G_PATTERN_5 OR p_pattern_no = G_PATTERN_9) THEN
            IF (p_pricing_dual_instances(i).pattern_no = G_PATTERN_5  OR
		p_pricing_dual_instances(i).pattern_no = G_PATTERN_9 OR
               p_pricing_dual_instances(i).pattern_no = G_PATTERN_2)  AND
               p_pricing_dual_instances(i).grouping_level = p_grouping_level AND
               p_pricing_dual_instances(i).aggregation = p_aggregation AND
               NVL(p_pricing_dual_instances(i).objective,'N') = NVL(p_objective,'N') THEN
               l_matched_index(p_pricing_dual_instances(i).instance_index) :=
                                    p_pricing_dual_instances(i).instance_index;
            END IF;
         ELSIF (p_pattern_no = G_PATTERN_3 OR p_pattern_no = G_PATTERN_6 OR p_pattern_no = G_PATTERN_10) THEN
            IF (p_pricing_dual_instances(i).pattern_no = G_PATTERN_6  OR
		p_pricing_dual_instances(i).pattern_no = G_PATTERN_10 OR
               p_pricing_dual_instances(i).pattern_no = G_PATTERN_3)  AND
               p_pricing_dual_instances(i).grouping_level = p_grouping_level AND
               p_pricing_dual_instances(i).aggregation = p_aggregation AND
               NVL(p_pricing_dual_instances(i).objective,'N') = NVL(p_objective,'N') THEN
               l_matched_index(p_pricing_dual_instances(i).instance_index) :=
                                    p_pricing_dual_instances(i).instance_index;
            END IF;
         END IF;

         EXIT WHEN i = p_pricing_dual_instances.LAST;
         i := p_pricing_dual_instances.NEXT(i);
   END LOOP;

   IF l_matched_index.COUNT <> 0 THEN

   -- Comes here if there are instances from same pattern and
   -- p_aggregation = 'ACROSS' and matching basis or p_aggregation = 'WITHIN' and matching categories
   -- Now match the additional services for the top level row with that of the matched instances

      m := p_pricing_dual_instances.FIRST;
      LOOP
        IF l_matched_index.EXISTS(p_pricing_dual_instances(m).instance_index) THEN
           IF NVL(p_pricing_dual_instances(m).services_hash,'N') = NVL(p_toplevel_charges_hash,'N') THEN
              l_matched_instance_index := p_pricing_dual_instances(m).instance_index;
              EXIT; -- Maximum one can match
           END IF;
        END IF;

        EXIT WHEN m = p_pricing_dual_instances.LAST;
        m := p_pricing_dual_instances.NEXT(m);
      END LOOP;

      IF l_matched_instance_index = 0 THEN
         l_matched_instance_index := -100;
      END IF;

   ELSE
      l_matched_instance_index := -100;

   END IF;

   x_matched_instance_index := l_matched_instance_index;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'search_matching_instance');
   RETURN;

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('search_matching_instance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'search_matching_instance');
END search_matching_instance;

--      This procedure should be called to create associated engine rows while creating one new instance
--      It also creates relevant associated attribute rows
--      The calling procedure takes care of creating pattern_row and dual_instance_row
--      Additional attributes either at delivery level/container level are also added there
--      It is called for each top level container
--      Can be called for both Single-commodity and multi-commodity (ie. for all patterns)

PROCEDURE create_new_instance (
        p_rolled_up_lines         IN     rolledup_line_tab_type,
        p_toplevel_lines          IN     shpmnt_content_rec_type,
        p_grouping_level          IN     VARCHAR2,
        p_aggregation             IN     VARCHAR2,
        p_objective               IN     VARCHAR2,
        p_instance_count          IN     NUMBER,
        x_pricing_engine_rows     IN OUT NOCOPY   pricing_engine_input_tab_type,
        x_pricing_attribute_rows  IN OUT NOCOPY   pricing_attribute_tab_type,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

        i                                NUMBER:=0;
        j                                NUMBER:=0;
        l_container_working_weight       NUMBER:=0;
        l_container_working_volume       NUMBER:=0;
        l_instance_index                 NUMBER:= p_instance_count;
        l_input_index                    NUMBER:= x_pricing_engine_rows.COUNT;
        l_input_engine_row_count         NUMBER;
        l_attribute_index                NUMBER:= x_pricing_attribute_rows.COUNT;
        l_hash_string                    VARCHAR2(50);
        l_hash_value                     NUMBER;
        l_category_rows                  quantity_tab_type;
        l_basis_rows                     quantity_tab_type;
        l_basis_categ_tab                basis_categ_tab_type;
        l_container_flag                 VARCHAR2(1) := 'Y';

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'create_new_instance','start');
   l_instance_index := l_instance_index + 1;

   l_input_engine_row_count := l_input_index;
   i := p_rolled_up_lines.FIRST;
   LOOP
   -- {

    IF p_aggregation = 'WITHIN' THEN
         --OR p_rolled_up_lines(i).rate_basis = G_CONTAINER_BASIS THEN
    -- {

   -- Group p_rolled_up_lines by category
   -- Sum up quantities for lines within each group (For CONTAINER basis do not sum up the line quantities)
   -- Prepare one engine row for each group

      IF NOT l_category_rows.EXISTS(p_rolled_up_lines(i).category_id) THEN
      -- {

         l_category_rows(p_rolled_up_lines(i).category_id).uom := p_rolled_up_lines(i).line_uom;
         l_category_rows(p_rolled_up_lines(i).category_id).quantity := p_rolled_up_lines(i).line_quantity;
         l_input_index := l_input_index + 1;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index);
         x_pricing_engine_rows(l_input_index).input_index := l_input_index;
         x_pricing_engine_rows(l_input_index).instance_index := l_instance_index;
         x_pricing_engine_rows(l_input_index).category_id := p_rolled_up_lines(i).category_id;
         --x_pricing_engine_rows(l_input_index).basis := p_rolled_up_lines(i).rate_basis;  -- No basis for WITHIN
         x_pricing_engine_rows(l_input_index).basis := p_rolled_up_lines(i).rate_basis;  -- No basis for WITHIN
         x_pricing_engine_rows(l_input_index).line_quantity := p_rolled_up_lines(i).line_quantity;
         x_pricing_engine_rows(l_input_index).line_uom := p_rolled_up_lines(i).line_uom;

         IF p_rolled_up_lines(i).rate_basis = G_CONTAINER_BASIS THEN
         -- {
              l_attribute_index := l_attribute_index + 1;
              x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
              x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
              x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CONTAINER_TYPE';
              x_pricing_attribute_rows(l_attribute_index).attribute_value := g_shipment_line_rows(p_toplevel_lines.content_id).container_type_code; --  Need to convert to VARCHAR2

         -- }
         END IF;

         l_attribute_index := l_attribute_index + 1;
         x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
         x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
         x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
         x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(p_rolled_up_lines(i).category_id); --  Need to convert to VARCHAR2

      -- }
      ELSE
      -- {
         IF p_rolled_up_lines(i).rate_basis <> G_CONTAINER_BASIS THEN
          -- {
           IF p_rolled_up_lines(i).line_uom = l_category_rows(p_rolled_up_lines(i).category_id).uom THEN
            l_category_rows(p_rolled_up_lines(i).category_id).quantity :=
              l_category_rows(p_rolled_up_lines(i).category_id).quantity + p_rolled_up_lines(i).line_quantity;
           ELSE
            FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Within - uom conversion');
            l_category_rows(p_rolled_up_lines(i).category_id).quantity :=
              l_category_rows(p_rolled_up_lines(i).category_id).quantity +
                                        WSH_WV_UTILS.convert_uom(p_rolled_up_lines(i).line_uom,
                                                     l_category_rows(p_rolled_up_lines(i).category_id).uom,
                                                     p_rolled_up_lines(i).line_quantity,
                                                     0);  -- Within same UOM class
           END IF;
         -- }
         END IF;
      -- }
      END IF;

    -- }
    ELSE -- p_aggregation = 'ACROSS'
    -- {

         FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Across - creating hash');
         l_hash_string := CONCAT(TO_CHAR(p_rolled_up_lines(i).rate_basis),TO_CHAR(p_rolled_up_lines(i).category_id));
         l_hash_value := dbms_utility.get_hash_value(
                                  name => l_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

   -- Group p_rolled_up_lines by basis
   -- Sum up quantities for lines within each group

      IF NOT l_basis_rows.EXISTS(p_rolled_up_lines(i).rate_basis) THEN
      -- {

         l_basis_categ_tab(l_hash_value).basis := p_rolled_up_lines(i).rate_basis;
         l_basis_categ_tab(l_hash_value).category_id := p_rolled_up_lines(i).category_id;

         l_basis_rows(p_rolled_up_lines(i).rate_basis).uom := p_rolled_up_lines(i).line_uom;
         l_basis_rows(p_rolled_up_lines(i).rate_basis).quantity := p_rolled_up_lines(i).line_quantity;
         l_input_index := l_input_index + 1;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index);
         x_pricing_engine_rows(l_input_index).input_index := l_input_index;
         x_pricing_engine_rows(l_input_index).instance_index := l_instance_index;
         x_pricing_engine_rows(l_input_index).category_id := p_rolled_up_lines(i).category_id;

         x_pricing_engine_rows(l_input_index).basis := p_rolled_up_lines(i).rate_basis;
         x_pricing_engine_rows(l_input_index).line_quantity := p_rolled_up_lines(i).line_quantity;
         x_pricing_engine_rows(l_input_index).line_uom := p_rolled_up_lines(i).line_uom;

         IF p_rolled_up_lines(i).rate_basis = G_CONTAINER_BASIS THEN
         -- {
              l_attribute_index := l_attribute_index + 1;
              x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
              x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
              x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CONTAINER_TYPE';
              x_pricing_attribute_rows(l_attribute_index).attribute_value := g_shipment_line_rows(p_toplevel_lines.content_id).container_type_code; --  Need to convert to VARCHAR2

         -- }
         END IF;

         -- Would not put category id if pricing objective is null
         IF p_objective IS NOT NULL THEN
         -- {

         l_attribute_index := l_attribute_index + 1;
         x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
         x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
         x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
         x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(p_rolled_up_lines(i).category_id);

         -- }
         END IF;

      -- }
      ELSE
      -- {

         IF NOT l_basis_categ_tab.EXISTS(l_hash_value) AND p_objective IS NOT NULL THEN
         -- {
            l_basis_categ_tab(l_hash_value).basis := p_rolled_up_lines(i).rate_basis;
            l_basis_categ_tab(l_hash_value).category_id := p_rolled_up_lines(i).category_id;

         -- Prepare as many engine row as many distinct categories within each group
         -- Need to sum up quantities within basis across categories
         -- Would not create new engine rows if pricing objective is null

            l_input_index := l_input_index + 1;
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index);
            x_pricing_engine_rows(l_input_index).input_index := l_input_index;
            x_pricing_engine_rows(l_input_index).instance_index := l_instance_index;
            x_pricing_engine_rows(l_input_index).category_id := p_rolled_up_lines(i).category_id;
            x_pricing_engine_rows(l_input_index).basis := p_rolled_up_lines(i).rate_basis;
            x_pricing_engine_rows(l_input_index).line_quantity := p_rolled_up_lines(i).line_quantity;
            x_pricing_engine_rows(l_input_index).line_uom := p_rolled_up_lines(i).line_uom;

            IF p_rolled_up_lines(i).rate_basis = G_CONTAINER_BASIS THEN
            -- {
                 l_attribute_index := l_attribute_index + 1;
                 x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
                 x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
                 x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CONTAINER_TYPE';
                 x_pricing_attribute_rows(l_attribute_index).attribute_value := g_shipment_line_rows(p_toplevel_lines.content_id).container_type_code; --  Need to convert to VARCHAR2

            -- }
            END IF;

            l_attribute_index := l_attribute_index + 1;
            x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
            x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
            x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
            x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(p_rolled_up_lines(i).category_id);

         -- }
         END IF;

         IF p_rolled_up_lines(i).rate_basis <> G_CONTAINER_BASIS THEN
         -- {
           IF p_rolled_up_lines(i).line_uom = l_basis_rows(p_rolled_up_lines(i).rate_basis).uom THEN
            l_basis_rows(p_rolled_up_lines(i).rate_basis).quantity :=
              l_basis_rows(p_rolled_up_lines(i).rate_basis).quantity + p_rolled_up_lines(i).line_quantity;
           ELSE
            FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Across - uom conversion');
            l_basis_rows(p_rolled_up_lines(i).rate_basis).quantity :=
              l_basis_rows(p_rolled_up_lines(i).rate_basis).quantity +
                                        WSH_WV_UTILS.convert_uom(p_rolled_up_lines(i).line_uom,
                                                     l_basis_rows(p_rolled_up_lines(i).rate_basis).uom,
                                                     p_rolled_up_lines(i).line_quantity,
                                                     0);  -- Within same UOM class
           END IF;
         -- }
         END IF;
      -- }
      END IF;

    -- }
    END IF;

    EXIT WHEN i = p_rolled_up_lines.LAST;
    i := p_rolled_up_lines.NEXT(i);
   -- }
   END LOOP;

   IF x_pricing_engine_rows.COUNT > l_input_engine_row_count THEN
   -- {
   j := l_input_engine_row_count + 1;
   LOOP
   -- {
      -- new code for loose items
      -- set the loose_item_id in the pricing_engine_row
      IF (p_toplevel_lines.container_flag = 'N') THEN
         -- x_pricing_engine_rows(j).loose_item_id := p_toplevel_lines.content_id;
         x_pricing_engine_rows(j).loose_item_flag := 'Y';
      END IF;

      IF x_pricing_engine_rows(j).basis <> G_CONTAINER_BASIS THEN  --  Might not have basis ?
       IF p_aggregation = 'WITHIN' THEN
         x_pricing_engine_rows(j).line_quantity := l_category_rows(x_pricing_engine_rows(j).category_id).quantity;
       ELSE
         x_pricing_engine_rows(j).line_quantity := l_basis_rows(x_pricing_engine_rows(j).basis).quantity;
       END IF;
      END IF;

      -- Do not populate basis in engine row if there exists only one basis for the top level line
      -- irrespective of pricing objective present or not
      -- No longer 04/30 ST

      IF l_basis_rows.COUNT = 1 AND p_aggregation = 'ACROSS' THEN
      -- {

         -- If there is no objective container gross weight/volume should replace sum (line weight/volume)
         -- Do not populate basis in engine row
         -- Affected - Parcel
         -- For now we are going to do this only for a grouping level = Container   03/15
         -- If there is a need we will do it for shipment level also

         IF p_objective IS NULL AND p_grouping_level = 'CONTAINER' THEN
            IF x_pricing_engine_rows(j).basis = G_WEIGHT_BASIS  THEN

               IF nvl(g_shipment_line_rows(p_toplevel_lines.content_id).gross_weight,0) <> 0 THEN

               -- uom conversion TODO ?
                IF g_shipment_line_rows(p_toplevel_lines.content_id).weight_uom_code = x_pricing_engine_rows(j).line_uom THEN

                  IF p_toplevel_lines.weight_uom = x_pricing_engine_rows(j).line_uom THEN

                    l_container_working_weight := GREATEST(g_shipment_line_rows(p_toplevel_lines.content_id).gross_weight,x_pricing_engine_rows(j).line_quantity + p_toplevel_lines.gross_weight);

                  ELSE

                    l_container_working_weight := GREATEST(g_shipment_line_rows(p_toplevel_lines.content_id).gross_weight,x_pricing_engine_rows(j).line_quantity +
                            WSH_WV_UTILS.convert_uom(p_toplevel_lines.weight_uom,
                            x_pricing_engine_rows(j).line_uom,
                            p_toplevel_lines.gross_weight,
                            0) );  -- Within same UOM class

                  END IF;

                ELSE

                  IF p_toplevel_lines.weight_uom = x_pricing_engine_rows(j).line_uom THEN

                    l_container_working_weight := GREATEST(
                            WSH_WV_UTILS.convert_uom(g_shipment_line_rows(p_toplevel_lines.content_id).weight_uom_code,
                            x_pricing_engine_rows(j).line_uom,
                            g_shipment_line_rows(p_toplevel_lines.content_id).gross_weight,
                            0),x_pricing_engine_rows(j).line_quantity + p_toplevel_lines.gross_weight);


                  ELSE

                    l_container_working_weight := GREATEST(
                            WSH_WV_UTILS.convert_uom(g_shipment_line_rows(p_toplevel_lines.content_id).weight_uom_code,
                            x_pricing_engine_rows(j).line_uom,
                            g_shipment_line_rows(p_toplevel_lines.content_id).gross_weight,
                            0),x_pricing_engine_rows(j).line_quantity +
                            WSH_WV_UTILS.convert_uom(p_toplevel_lines.weight_uom,
                            x_pricing_engine_rows(j).line_uom,
                            p_toplevel_lines.gross_weight,
                            0));  -- Within same UOM class

                  END IF;

                END IF;

                x_pricing_engine_rows(j).line_quantity := l_container_working_weight;

               ELSE

                -- uom conversion TODO
                IF p_toplevel_lines.weight_uom = x_pricing_engine_rows(j).line_uom THEN
                   x_pricing_engine_rows(j).line_quantity := x_pricing_engine_rows(j).line_quantity + p_toplevel_lines.gross_weight ;
                ELSE
                   x_pricing_engine_rows(j).line_quantity := x_pricing_engine_rows(j).line_quantity +
                            WSH_WV_UTILS.convert_uom(p_toplevel_lines.weight_uom,
                            x_pricing_engine_rows(j).line_uom,
                            p_toplevel_lines.gross_weight,
                            0);  -- Within same UOM class

                END IF;
               END IF;

            ELSIF x_pricing_engine_rows(j).basis = G_VOLUME_BASIS THEN

               IF nvl(g_shipment_line_rows(p_toplevel_lines.content_id).volume,0) <> 0 THEN

               -- uom conversion TODO ?
                IF g_shipment_line_rows(p_toplevel_lines.content_id).volume_uom_code = x_pricing_engine_rows(j).line_uom THEN

                  l_container_working_volume := GREATEST(g_shipment_line_rows(p_toplevel_lines.content_id).volume,x_pricing_engine_rows(j).line_quantity);

                ELSE

                  l_container_working_volume := GREATEST(
                            WSH_WV_UTILS.convert_uom(g_shipment_line_rows(p_toplevel_lines.content_id).volume_uom_code,
                            x_pricing_engine_rows(j).line_uom,
                            g_shipment_line_rows(p_toplevel_lines.content_id).volume,
                            0),x_pricing_engine_rows(j).line_quantity);

                END IF;

                x_pricing_engine_rows(j).line_quantity := l_container_working_volume;

               ELSE   --  For Volume basis we consider either container volume or if it is not there
                      --  sum of the rolled up lines' volume
                      --  Rolled up lines' volume can't be added to container's unit volume in this case

                NULL;

               END IF;
            END IF;
            x_pricing_engine_rows(j).basis := NULL;
         END IF;
         --x_pricing_engine_rows(j).basis := NULL;

      -- }
      END IF;
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Created engine row '||j||' with quantity : '||x_pricing_engine_rows(j).line_quantity||x_pricing_engine_rows(j).line_uom);

      EXIT WHEN j = x_pricing_engine_rows.LAST;
    j := x_pricing_engine_rows.NEXT(j);
   -- }
   END LOOP;
   -- }
   ELSE
   -- {
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Could not create any engine row for Container : '||p_toplevel_lines.content_id);
      raise FTE_FREIGHT_PRICING_UTIL.g_no_enginerow_created;
   -- }
   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'create_new_instance');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_enginerow_created THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('create_new_instance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_enginerow_created');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'create_new_instance');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('create_new_instance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'create_new_instance');
END create_new_instance;

--      This procedure should be called to add a pattern to a matched instance
--      The calling procedure takes care of creating pattern_row and modifying dual_instance_row
--      This procedure might need to create new engine rows and associated attribute rows
--      for any new category in case of 'WITHIN' and for new basis and new category in existing basis
--      in case of ACROSS
--      It is called for a top level container for which a matching instance has already been found
--      Can be called for both Single-commodity and multi-commodity (ie. for all patterns)

PROCEDURE add_to_instance (
        p_container_flag          IN             VARCHAR2  DEFAULT 'Y', -- new for loose item
        p_rolled_up_lines         IN             rolledup_line_tab_type,
        p_matching_instance_index IN             NUMBER,
        p_aggregation             IN             VARCHAR2,
        p_objective               IN             VARCHAR2,
        x_pricing_engine_rows     IN OUT NOCOPY  pricing_engine_input_tab_type,
        x_pricing_attribute_rows  IN OUT NOCOPY  pricing_attribute_tab_type,
        x_return_status           OUT NOCOPY             VARCHAR2 )
IS
        l_unmatched_categories   basis_categ_tab_type;
        l_unmatched_basis        quantity_tab_type;
        l_unmatched_bascateg     basis_categ_tab_type;
        l_unmatched_categ        quantity_basis_tab_type;
        l_basis_sum              quantity_tab_type;
        l_hash_string                    VARCHAR2(50);
        l_hash_value                     NUMBER;
        l_engine_categ           quantity_tab_type;
        l_engine_basis           quantity_tab_type;
        l_engine_bas_categ       basis_categ_tab_type;
        i                        NUMBER:=0;
        j                        NUMBER:=0;
        k                        NUMBER:=0;
        l                        NUMBER:=0;
        m                        NUMBER:=0;
        n                        NUMBER:=0;
        l_input_index            NUMBER;
        l_attribute_index        NUMBER;

        -- to fix bug 2739329
        l_consumed_rollup_det    wsh_util_core.id_tab_type;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'add_to_instance','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            'Parameters :');
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            '    p_container_flag = '||p_container_flag);
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            '    p_matching_instance_index = '||p_matching_instance_index);
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            '    x_pricing_engine_rows.COUNT = '||x_pricing_engine_rows.COUNT);
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            '    p_aggregation = '||p_aggregation);

   i := x_pricing_engine_rows.FIRST;
   LOOP
   -- {
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 1 ');

    -- IF x_pricing_engine_rows(i).loose_item_id IS NULL THEN  --  Search/ADD only for containers
    -- IF (( p_container_flag = 'Y' AND x_pricing_engine_rows(i).loose_item_id IS NULL)
    --     OR (p_container_flag = 'N' AND x_pricing_engine_rows(i).loose_item_id IS NOT NULL)) THEN  --  Search/ADD only for containers, or only for loose items
    --IF (( p_container_flag = 'Y' AND x_pricing_engine_rows(i).loose_item_flag = 'N')
      --  OR (p_container_flag = 'N' AND x_pricing_engine_rows(i).loose_item_flag = 'Y' )) THEN  --  Search/ADD only for containers, or only for loose items
       -- don't mix loose items and containers
    -- {
      IF x_pricing_engine_rows(i).instance_index = p_matching_instance_index THEN
      -- {
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adding to instance index : '||p_matching_instance_index);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                              'x_pricing_engine_rows=> i = '||i);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                              'x_pricing_engine_rows=> category_id = '||x_pricing_engine_rows(i).category_id);

            IF p_aggregation = 'WITHIN' THEN
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 2 ');
               -- To store unique list of category ids for matching engine rows
               IF NOT l_engine_categ.EXISTS(x_pricing_engine_rows(i).category_id) THEN
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 3 ');
                  l_engine_categ(x_pricing_engine_rows(i).category_id).quantity := x_pricing_engine_rows(i).line_quantity;
                  l_engine_categ(x_pricing_engine_rows(i).category_id).uom := x_pricing_engine_rows(i).line_uom;
               END IF;
            ELSIF p_aggregation = 'ACROSS' THEN

               IF NOT l_engine_basis.EXISTS(x_pricing_engine_rows(i).basis) THEN
                  l_engine_basis(x_pricing_engine_rows(i).basis).quantity := x_pricing_engine_rows(i).line_quantity;
                  l_engine_basis(x_pricing_engine_rows(i).basis).uom := x_pricing_engine_rows(i).line_uom;
               END IF;

               -- Is it required for Pricing Objective = NULL
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Across - creating hash');
               l_hash_string := CONCAT(TO_CHAR(x_pricing_engine_rows(i).basis),TO_CHAR(x_pricing_engine_rows(i).category_id));
               l_hash_value := dbms_utility.get_hash_value(
                                        name => l_hash_string,
                                        base => g_hash_base,
                                        hash_size =>g_hash_size );

               IF NOT l_engine_bas_categ.EXISTS(l_hash_value) THEN
                  l_engine_bas_categ(l_hash_value).basis := x_pricing_engine_rows(i).basis;
                  l_engine_bas_categ(l_hash_value).category_id := x_pricing_engine_rows(i).category_id;
               END IF;
            END IF;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 4 ');

         j := p_rolled_up_lines.FIRST;
         LOOP
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 5 ');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                                           'p_rolled_up_lines=> j ='||j);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                                      'p_rolled_up_lines=> category_id ='||p_rolled_up_lines(j).category_id);

            IF p_aggregation = 'WITHIN' THEN
               --  Need to add quantities to the correct category
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 6 ');

               IF x_pricing_engine_rows(i).category_id = p_rolled_up_lines(j).category_id THEN
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 7 ');
                  IF l_unmatched_categ.EXISTS(p_rolled_up_lines(j).category_id) THEN
                     l_unmatched_categ.DELETE(p_rolled_up_lines(j).category_id);
                  END IF;
                  IF p_rolled_up_lines(j).line_uom <> x_pricing_engine_rows(i).line_uom THEN
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 8 ');
                     FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Within matching category uom conversion');

                     x_pricing_engine_rows(i).line_quantity := x_pricing_engine_rows(i).line_quantity +
                                                     WSH_WV_UTILS.convert_uom(p_rolled_up_lines(j).line_uom,
                                                     x_pricing_engine_rows(i).line_uom,
                                                     p_rolled_up_lines(j).line_quantity,
                                                     0);  -- Within same UOM class
                  ELSE
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 8 ');
                     x_pricing_engine_rows(i).line_quantity := x_pricing_engine_rows(i).line_quantity +
                                                               p_rolled_up_lines(j).line_quantity;
                  END IF;
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                            'x_pricing_engine_rows=>line_quantity='||x_pricing_engine_rows(i).line_quantity);
               ELSE  --   Populate new categories table
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 9 ');
                  --IF NOT l_unmatched_categ.EXISTS(p_rolled_up_lines(j).category_id) THEN
                  IF (NOT l_engine_categ.EXISTS(p_rolled_up_lines(j).category_id)) AND (NOT l_unmatched_categ.EXISTS(p_rolled_up_lines(j).category_id)) THEN
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 10 ');
                     l_unmatched_categ(p_rolled_up_lines(j).category_id).basis := p_rolled_up_lines(j).rate_basis;
                     l_unmatched_categ(p_rolled_up_lines(j).category_id).quantity := p_rolled_up_lines(j).line_quantity;
                     l_unmatched_categ(p_rolled_up_lines(j).category_id).uom := p_rolled_up_lines(j).line_uom;
                     -- begin fix bug 2739329
                     -- everytime an entry is created in l_unmatched_categ, keep track of rollup lines
                     -- so that we don't sum the same delivery detail again and again
                     l_consumed_rollup_det(p_rolled_up_lines(j).delivery_detail_id) := p_rolled_up_lines(j).delivery_detail_id;
                     -- end fix

                  ELSE -- Sum up quantity within the new category
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 11 ');

                   -- begin fix bug 2739329
                   IF (NOT l_consumed_rollup_det.EXISTS(p_rolled_up_lines(j).delivery_detail_id) ) THEN
                   -- end fix
                    IF l_unmatched_categ.EXISTS(p_rolled_up_lines(j).category_id) THEN
                     FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 12 ');
                     IF p_rolled_up_lines(j).line_uom <> l_unmatched_categ(p_rolled_up_lines(j).category_id).uom THEN
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 13 ');
                        FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Within new category uom conversion');

                        l_unmatched_categ(p_rolled_up_lines(j).category_id).quantity :=
                                          l_unmatched_categ(p_rolled_up_lines(j).category_id).quantity +
                                          WSH_WV_UTILS.convert_uom(p_rolled_up_lines(j).line_uom,
                                          l_unmatched_categ(p_rolled_up_lines(j).category_id).uom,
                                          p_rolled_up_lines(j).line_quantity,
                                          0);  -- Within same UOM class
                     ELSE
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 13 ');
                        l_unmatched_categ(p_rolled_up_lines(j).category_id).quantity :=
                                          l_unmatched_categ(p_rolled_up_lines(j).category_id).quantity +
                                          p_rolled_up_lines(j).line_quantity;
                     END IF;

                    END IF;
                   -- begin fix bug 2739329
                   END IF;
                   -- end fix

                  END IF;
               END IF;
            ELSE -- p_aggregation = 'ACROSS'
                 -- Add quantities within same basis
                 -- If there is no pricing objective send only one line per basis
                   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 14 ');

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Engine row category : '||x_pricing_engine_rows(i).category_id);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'rolledup line category : '||p_rolled_up_lines(j).category_id);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Engine row basis : '||x_pricing_engine_rows(i).basis);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'rolledup line basis : '||p_rolled_up_lines(j).rate_basis);

               l_hash_string := CONCAT(TO_CHAR(p_rolled_up_lines(j).rate_basis),TO_CHAR(p_rolled_up_lines(j).category_id));
               l_hash_value := dbms_utility.get_hash_value(
                                        name => l_hash_string,
                                        base => g_hash_base,
                                        hash_size =>g_hash_size );

               IF x_pricing_engine_rows(i).basis = p_rolled_up_lines(j).rate_basis THEN
               -- Problem if there is NULL basis in engine row

                 IF l_unmatched_basis.EXISTS(p_rolled_up_lines(j).rate_basis) THEN
                     l_unmatched_basis.DELETE(p_rolled_up_lines(j).rate_basis);
                 END IF;

                 -- Might need to create new engine rows if new categories (within the same basis) come up
                 -- Only if pricing objective is not null

                 IF x_pricing_engine_rows(i).category_id IS NOT NULL THEN
                  IF x_pricing_engine_rows(i).category_id <> p_rolled_up_lines(j).category_id AND
                     p_objective IS NOT NULL THEN

                     --IF NOT l_unmatched_categories.EXISTS(p_rolled_up_lines(j).category_id) THEN
                     IF (NOT l_engine_bas_categ.EXISTS(l_hash_value)) AND (NOT l_unmatched_categories.EXISTS(p_rolled_up_lines(j).category_id)) THEN

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Adding unmatched category : '||p_rolled_up_lines(j).category_id);

                        l_unmatched_categories(p_rolled_up_lines(j).category_id).category_id := p_rolled_up_lines(j).category_id;
                        l_unmatched_categories(p_rolled_up_lines(j).category_id).basis := x_pricing_engine_rows(i).basis;
                     END IF;
                  ELSE
                     IF l_unmatched_categories.EXISTS(p_rolled_up_lines(j).category_id) THEN
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Deleting from unmatched category : '||p_rolled_up_lines(j).category_id);
                        l_unmatched_categories.DELETE(p_rolled_up_lines(j).category_id);
                     END IF;
                  END IF;
                 END IF;

                 IF p_rolled_up_lines(j).line_uom <> x_pricing_engine_rows(i).line_uom THEN
                     FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Within matching basis uom conversion');

                     x_pricing_engine_rows(i).line_quantity := x_pricing_engine_rows(i).line_quantity +
                                                     WSH_WV_UTILS.convert_uom(p_rolled_up_lines(j).line_uom,
                                                     x_pricing_engine_rows(i).line_uom,
                                                     p_rolled_up_lines(j).line_quantity,
                                                     0);  -- Within same UOM class
                 ELSE
                     x_pricing_engine_rows(i).line_quantity := x_pricing_engine_rows(i).line_quantity +
                                                               p_rolled_up_lines(j).line_quantity;
                 END IF;
               ELSE  --   Populate new basis table

                  --IF NOT l_unmatched_basis.EXISTS(p_rolled_up_lines(j).rate_basis) THEN
                  IF (NOT l_engine_basis.EXISTS(p_rolled_up_lines(j).rate_basis)) AND (NOT l_unmatched_basis.EXISTS(p_rolled_up_lines(j).rate_basis)) THEN

                    IF l_unmatched_basis.EXISTS(p_rolled_up_lines(j).rate_basis) THEN
                     l_unmatched_basis(p_rolled_up_lines(j).rate_basis).quantity := p_rolled_up_lines(j).line_quantity;
                     l_unmatched_basis(p_rolled_up_lines(j).rate_basis).uom := p_rolled_up_lines(j).line_uom;
                    END IF;
                  ELSE -- Sum up quantity within the new basis
                  -- Might need to create new engine rows if new categories (within this new basis) come up
                  -- Only if pricing objective is not null

                    IF l_unmatched_basis.EXISTS(p_rolled_up_lines(j).rate_basis) THEN
                     --IF NOT l_unmatched_bascateg.EXISTS(p_rolled_up_lines(j).category_id) AND
                     IF NOT l_unmatched_bascateg.EXISTS(l_hash_value) AND
                        p_objective IS NOT NULL THEN
                        -- It could have been okay to index the following on category_id as well
                        -- because more than one different bases can never
                        -- have any common categories
                        -- We are using l_hash_value to index to be on the safer side

                        l_unmatched_bascateg(l_hash_value).category_id := p_rolled_up_lines(j).category_id;
                        l_unmatched_bascateg(l_hash_value).basis := p_rolled_up_lines(j).rate_basis;
                     END IF;

                     IF p_rolled_up_lines(j).line_uom <> l_unmatched_basis(p_rolled_up_lines(j).rate_basis).uom THEN
                        FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Within new basis uom conversion');

                        l_unmatched_basis(p_rolled_up_lines(j).rate_basis).quantity :=
                                          l_unmatched_basis(p_rolled_up_lines(j).rate_basis).quantity +
                                          WSH_WV_UTILS.convert_uom(p_rolled_up_lines(j).line_uom,
                                          l_unmatched_basis(p_rolled_up_lines(j).rate_basis).uom,
                                          p_rolled_up_lines(j).line_quantity,
                                          0);  -- Within same UOM class
                     ELSE
                        l_unmatched_basis(p_rolled_up_lines(j).rate_basis).quantity :=
                                          l_unmatched_basis(p_rolled_up_lines(j).rate_basis).quantity +
                                          p_rolled_up_lines(j).line_quantity;
                     END IF;
                    END IF;
                  END IF;
               END IF;

            END IF;
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 15 ');

            EXIT WHEN j = p_rolled_up_lines.LAST;
            j := p_rolled_up_lines.NEXT(j);
         END LOOP;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 16 ');

         -- ACROSS : Handling new categories within existing basis
         IF l_unmatched_categories.COUNT > 0 AND NOT l_basis_sum.EXISTS(x_pricing_engine_rows(i).basis) THEN
            l_basis_sum(x_pricing_engine_rows(i).basis).quantity := x_pricing_engine_rows(i).line_quantity;
            l_basis_sum(x_pricing_engine_rows(i).basis).uom := x_pricing_engine_rows(i).line_uom;
         END IF;

      -- }
      END IF;
    -- }
    --END IF;

    EXIT WHEN i = x_pricing_engine_rows.LAST;
    i := x_pricing_engine_rows.NEXT(i);
   -- }
   END LOOP;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 17 ');
   -- ACROSS : Handling new categories within existing basis
   IF l_unmatched_categories.COUNT > 0 AND p_aggregation = 'ACROSS' THEN
      k := l_unmatched_categories.FIRST;
      LOOP

         l_input_index := x_pricing_engine_rows.COUNT + 1;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index||' with category id : '||l_unmatched_categories(k).category_id);
         x_pricing_engine_rows(l_input_index).input_index := l_input_index;
         x_pricing_engine_rows(l_input_index).instance_index := p_matching_instance_index;
         x_pricing_engine_rows(l_input_index).category_id := l_unmatched_categories(k).category_id;
         x_pricing_engine_rows(l_input_index).basis := l_unmatched_categories(k).basis;
         x_pricing_engine_rows(l_input_index).line_quantity := l_basis_sum(l_unmatched_categories(k).basis).quantity;
         x_pricing_engine_rows(l_input_index).line_uom := l_basis_sum(l_unmatched_categories(k).basis).uom;
         -- new code for loose items
         IF (p_container_flag = 'N') THEN
            x_pricing_engine_rows(l_input_index).loose_item_flag := 'Y';
         END IF;

         l_attribute_index := x_pricing_attribute_rows.COUNT + 1;
         x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
         x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
         x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
         x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(l_unmatched_categories(k).category_id);


         EXIT WHEN k = l_unmatched_categories.LAST;
         k := l_unmatched_categories.NEXT(k);
      END LOOP;
   END IF;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 18 ');
   -- WITHIN : Handling new categories
   IF l_unmatched_categ.COUNT > 0 AND p_aggregation = 'WITHIN' THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 19 ');
      l := l_unmatched_categ.FIRST;
      LOOP

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 20 ');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                                            'l_unmatched_categ => l=category_id='||l);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                                            'l_unmatched_categ=>quantity='||l_unmatched_categ(l).quantity);
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                                            'l_unmatched_categ=>uom='||l_unmatched_categ(l).uom);
         l_input_index := x_pricing_engine_rows.COUNT + 1;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index);
         x_pricing_engine_rows(l_input_index).input_index := l_input_index;
         x_pricing_engine_rows(l_input_index).instance_index := p_matching_instance_index;
         x_pricing_engine_rows(l_input_index).category_id := l;
         --x_pricing_engine_rows(l_input_index).basis := l_unmatched_categories(k).basis;
         -- Need to put the correct category id
         -- l_unmatched_categ rectype needs to include basis also
         x_pricing_engine_rows(l_input_index).basis := l_unmatched_categ(l).basis;
         x_pricing_engine_rows(l_input_index).line_quantity := l_unmatched_categ(l).quantity;
         x_pricing_engine_rows(l_input_index).line_uom := l_unmatched_categ(l).uom;
         -- new code for loose items
         IF (p_container_flag = 'N') THEN
            x_pricing_engine_rows(l_input_index).loose_item_flag := 'Y';
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 21 ');

         l_attribute_index := x_pricing_attribute_rows.COUNT + 1;
         x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
         x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
         x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
         x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(l);


         EXIT WHEN l = l_unmatched_categ.LAST;
         l := l_unmatched_categ.NEXT(l);
      END LOOP;
   END IF;
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, '>>> 22 ');

   -- ACROSS : Handling new basis
   IF l_unmatched_basis.COUNT > 0 AND p_aggregation = 'ACROSS' THEN
      m := l_unmatched_basis.FIRST;
      LOOP

       IF l_unmatched_bascateg.COUNT > 0 THEN
      -- ACROSS : Handling individual categories in the new basis
         n := l_unmatched_bascateg.FIRST;
         LOOP

            l_input_index := x_pricing_engine_rows.COUNT + 1;
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index||' with basis : '||m);
            x_pricing_engine_rows(l_input_index).input_index := l_input_index;
            x_pricing_engine_rows(l_input_index).instance_index := p_matching_instance_index;
            --x_pricing_engine_rows(l_input_index).category_id := n;
            x_pricing_engine_rows(l_input_index).category_id := l_unmatched_bascateg(n).category_id;
            x_pricing_engine_rows(l_input_index).basis := m;
            x_pricing_engine_rows(l_input_index).line_quantity := l_unmatched_basis(m).quantity;
            x_pricing_engine_rows(l_input_index).line_uom := l_unmatched_basis(m).uom;
            -- new code for loose items
            IF (p_container_flag = 'N') THEN
               x_pricing_engine_rows(l_input_index).loose_item_flag := 'Y';
            END IF;

            l_attribute_index := x_pricing_attribute_rows.COUNT + 1;
            x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
            x_pricing_attribute_rows(l_attribute_index).input_index     := l_input_index;
            x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'CATEGORY_ID';
            --x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(n);
            x_pricing_attribute_rows(l_attribute_index).attribute_value := TO_CHAR(l_unmatched_bascateg(n).category_id);

            EXIT WHEN n = l_unmatched_bascateg.LAST;
            n := l_unmatched_bascateg.NEXT(n);
         END LOOP;
       ELSE
            l_input_index := x_pricing_engine_rows.COUNT + 1;
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Creating engine row : '||l_input_index);
            x_pricing_engine_rows(l_input_index).input_index := l_input_index;
            x_pricing_engine_rows(l_input_index).instance_index := p_matching_instance_index;
            x_pricing_engine_rows(l_input_index).basis := m;
            x_pricing_engine_rows(l_input_index).line_quantity := l_unmatched_basis(m).quantity;
            x_pricing_engine_rows(l_input_index).line_uom := l_unmatched_basis(m).uom;
            -- new code for loose items
            IF (p_container_flag = 'N') THEN
               x_pricing_engine_rows(l_input_index).loose_item_flag := 'Y';
            END IF;

       END IF;

       /*
       IF l_unmatched_basis.COUNT = 1 THEN
            x_pricing_engine_rows(l_input_index).basis := NULL;
       END IF;
       */

       EXIT WHEN m = l_unmatched_basis.LAST;
       m := l_unmatched_basis.NEXT(m);
      END LOOP;
   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'add_to_instance');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('add_to_instance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'add_to_instance');
END add_to_instance;

--      This procedure looks up the delivery lines in each of the input content rows and
--      based on the commodity/freight class and pricing basis determines pattern for each
--      It then acknowledges all the patterns and looks up pricing dual from the preferences
--      table for each of them. It consolidates dual instances if possible and formulates input lines
--      For mixed commodity patterns considers pricing objective
--      Looks up delivery detail isnfo from g_shipment_line_rows

PROCEDURE process_shipment_pattern (
        p_classification_code     IN     VARCHAR2,       --  Is this right datatype ?
        p_lane_basis              IN     VARCHAR2,
        p_lane_id                 IN     NUMBER,
        p_carrier_id              IN     NUMBER,
        p_service_code            IN     VARCHAR2,
        p_shpmnt_toplevel_rows    IN OUT NOCOPY  shpmnt_content_tab_type,
        p_shpmnt_toplevel_charges IN     addl_services_tab_type, -- Top level requested additional services
        x_pricing_dual_instances  OUT NOCOPY     pricing_dual_instance_tab_type,
        x_pricing_engine_rows     OUT NOCOPY     pricing_engine_input_tab_type,
        x_pattern_rows            OUT NOCOPY     top_level_pattern_tab_type,
        x_pricing_attribute_rows  OUT NOCOPY     pricing_attribute_tab_type,  --  Probably not required/required for line level attributes like category/hazard/container_type ?
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

        i                     NUMBER:=0;
        j                     NUMBER:=0;
        k                     NUMBER:=0;
        l                     NUMBER:=0;
        m                     NUMBER:=0;
        l_prev_categ          NUMBER:=NULL;
        l_prev_basis          NUMBER:=NULL;
        l_num_basis           NUMBER:=NULL;
        l_basis               VARCHAR2(30):=NULL;
        l_wt_basis_count      NUMBER:=0;
        l_vol_basis_count     NUMBER:=0;
        l_cont_basis_count    NUMBER:=0;
        l_pattern_no          NUMBER:=0;
        l_pattern_name        VARCHAR2(30);
        l_services_hash       VARCHAR2(100):=NULL;
        l_lane_function       VARCHAR2(30);
        l_grouping_level      VARCHAR2(30);
        l_aggregation         VARCHAR2(30);
        l_pricing_objective   VARCHAR2(30);
        l_mixed_categ         VARCHAR2(1):='N';
        l_mixed_basis         VARCHAR2(1):='N';
        l_return_status       VARCHAR2(1);
        l_pattern_index       NUMBER:=0;
        l_count_pattern       NUMBER:=0;
        l_instance_count      NUMBER:=0;
        l_input_index         NUMBER:=0;
        l_attribute_index     NUMBER:=0;
        l_category_id         NUMBER:=0;
        l_instance_index      NUMBER:=0;
        l_matched_instance_index         NUMBER:=0;
        l_curr_engine_row_count          NUMBER:=0;
        l_curr_attribute_count           NUMBER:=0;
        l_rolledup_lines                 rolledup_line_tab_type;
        l_rolledup_category_rows         WSH_UTIL_CORE.id_tab_type;
        l_rolledup_category_basis        WSH_UTIL_CORE.id_tab_type;

        l_rolledup_rec              rolledup_line_rec_type;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_INF;

BEGIN
 -- {

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'process_shipment_pattern','start');

  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Inside process_shipment_pattern .Before initialization');




   FTE_FREIGHT_PRICING_SPECIAL.initialize(
                   p_lane_id         => p_lane_id,
                   x_lane_function   => l_lane_function,
                   x_return_status   => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         raise FTE_FREIGHT_PRICING_UTIL.g_initialize_failed;
      END IF;
   ELSE -- What happens if there is an empty container ?
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Parameters and Rules for lane : '||p_lane_id||' has been looked up');
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Lane Function : '||l_lane_function);
   END IF;

   g_rolledup_lines.DELETE;
   i := p_shpmnt_toplevel_rows.FIRST;  -- Catch empty delivery exception
   LOOP
   -- {
      l_wt_basis_count := 0 ;
      l_vol_basis_count := 0 ;
      l_cont_basis_count := 0 ;
      l_prev_categ := 0;
      l_prev_basis := 0;
      l_matched_instance_index := 0;
      l_mixed_categ := 'N';
      l_mixed_basis := 'N';
      l_grouping_level := NULL;
      l_aggregation := NULL;
      l_pricing_objective := NULL;
      l_services_hash := NULL;

      l_rolledup_category_rows.DELETE;
      l_rolledup_category_basis.DELETE;

      l_curr_engine_row_count := x_pricing_engine_rows.COUNT;
      l_curr_attribute_count  := x_pricing_attribute_rows.COUNT;

      IF ((p_shpmnt_toplevel_rows(i).container_flag = 'Y') OR (p_shpmnt_toplevel_rows(i).container_flag = 'C')) THEN
      -- {
         l_rolledup_lines.DELETE;

         rollup_container_hierarchy(
                p_container_id         =>  p_shpmnt_toplevel_rows(i).content_id,
                p_classification_code  =>  p_classification_code,
                p_lane_basis           =>  p_lane_basis,
                p_lane_id              =>  p_lane_id,
                x_rolledup_lines       =>  l_rolledup_lines,
                x_return_status        =>  l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Container '||p_shpmnt_toplevel_rows(i).content_id);
                           raise FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed;
                        END IF;
                ELSE -- What happens if there is an empty container ?
                        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Container '||p_shpmnt_toplevel_rows(i).content_id||' has '||l_rolledup_lines.COUNT||' rolled up lines');
                END IF;

         IF l_rolledup_lines.COUNT = 0 THEN
            goto nextpass;
         END IF;

         j := l_rolledup_lines.FIRST;
         LOOP
         -- {
           l_rolledup_lines(j).master_container_id := p_shpmnt_toplevel_rows(i).content_id;
           g_rolledup_lines(j).master_container_id := p_shpmnt_toplevel_rows(i).content_id;

           IF nvl(l_rolledup_lines(j).line_quantity,0) = 0 THEN

              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Rolled up line : '||j||' has line quantity = 0');
              raise FTE_FREIGHT_PRICING_UTIL.g_invalid_line_quantity;

           END IF;

           IF l_rolledup_lines(j).rate_basis = G_WEIGHT_BASIS THEN
              l_wt_basis_count := l_wt_basis_count + 1;
           ELSIF l_rolledup_lines(j).rate_basis = G_VOLUME_BASIS THEN
              l_vol_basis_count := l_vol_basis_count + 1;
           ELSIF l_rolledup_lines(j).rate_basis = G_CONTAINER_BASIS THEN
              l_cont_basis_count := l_cont_basis_count + 1;
           END IF;


           IF j <> l_rolledup_lines.FIRST THEN
           -- {

            IF l_rolledup_lines(j).category_id <> l_prev_categ THEN
              l_mixed_categ := 'Y';
              l_prev_categ := l_rolledup_lines(j).category_id;
              IF NOT l_rolledup_category_rows.EXISTS(l_rolledup_lines(j).category_id) THEN
                 l_rolledup_category_rows(l_rolledup_lines(j).category_id) := l_rolledup_lines(j).category_id;
              END IF;
              -- To be used for searching instances
            END IF;

            IF l_rolledup_lines(j).rate_basis <> l_prev_basis THEN
              l_mixed_basis := 'Y';
              l_prev_basis := l_rolledup_lines(j).rate_basis;
              IF NOT l_rolledup_category_basis.EXISTS(l_rolledup_lines(j).rate_basis) THEN
                 l_rolledup_category_basis(l_rolledup_lines(j).rate_basis) := l_rolledup_lines(j).rate_basis;
              END IF;
            END IF;

            -- }
           ELSE  --  First pass
           -- {

            l_rolledup_category_rows(l_rolledup_lines(j).category_id) := l_rolledup_lines(j).category_id;
            l_rolledup_category_basis(l_rolledup_lines(j).rate_basis) := l_rolledup_lines(j).rate_basis;
            l_prev_categ := l_rolledup_lines(j).category_id;
            l_prev_basis := l_rolledup_lines(j).rate_basis;

           -- }
           END IF;


           EXIT WHEN j = l_rolledup_lines.LAST;
           j := l_rolledup_lines.NEXT(j);

         -- }
         END LOOP;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Before Applying Dimensional Weight');

         --  Apply dimensional weight to the applicable l_rolledup_lines here per top level container

         FTE_FREIGHT_PRICING_SPECIAL.apply_dimensional_weight (
            p_lane_id              =>    p_lane_id,
            p_carrier_id           =>    p_carrier_id,
            p_service_code         =>    p_service_code,
            p_top_level_rec        =>    p_shpmnt_toplevel_rows(i),
            p_rolledup_rows        =>    l_rolledup_lines,
            x_return_status        =>    l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FTE_FREIGHT_PRICING_UTIL.g_dimensional_weight_failed;
            END IF;
         END IF;

         --  Process l_rolledup_lines here per top level container
         --  Identify the package pattern
         --  Determine value of l_pattern_name conforming to fte_prc_parameter_defaults.PARAMETER_SUB_TYPE
         --  looking at l_mixed_categ, l_mixed_basis,l_wt_basis_count,l_cont_basis_count,l_vol_basis_count

         IF l_mixed_categ = 'N' THEN   --  Single commodity will have l_mixed_basis = 'N'
            IF l_cont_basis_count > 0 THEN
               l_pattern_no := G_PATTERN_1;
               l_pattern_name := G_PATTERN_1_NAME;
            ELSIF l_wt_basis_count > 0 THEN
               l_pattern_no := G_PATTERN_2;
               l_pattern_name := G_PATTERN_2_NAME;
            ELSIF l_vol_basis_count > 0 THEN
               l_pattern_no := G_PATTERN_3;
               l_pattern_name := G_PATTERN_3_NAME;
            END IF;
         ELSE    --  Mixed commodity
            IF l_mixed_basis = 'N' THEN    --  Same basis
                IF l_cont_basis_count > 0 THEN
                   l_pattern_no := G_PATTERN_4;
                   l_pattern_name := G_PATTERN_4_NAME;
                ELSIF l_wt_basis_count > 0 THEN
                   l_pattern_no := G_PATTERN_5;
                   l_pattern_name := G_PATTERN_5_NAME;
                ELSIF l_vol_basis_count > 0 THEN
                   l_pattern_no := G_PATTERN_6;
                   l_pattern_name := G_PATTERN_6_NAME;
                END IF;
            ELSE                           --  Mixed basis
                IF l_cont_basis_count > 0 THEN
                   l_pattern_no := G_PATTERN_7;
                   l_pattern_name := G_PATTERN_7_NAME;
                ELSE
                   l_pattern_no := G_PATTERN_8;
                   l_pattern_name := G_PATTERN_8_NAME;
                END IF;
            END IF;
         END IF;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done identifying pattern');
         --  How do you identify Parcel  here ?  Not required to identify

         --  Look up FTE pricing preferences table to find out the pricing dual for that pattern

         l_grouping_level := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).grouping_level;
         l_aggregation := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).commodity_aggregation;
         l_pricing_objective := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).pricing_objective;

         -- What happens if grouping level or/and commodity_aggregation is null Exception ?

         --   Need to create services_hash here
         --   The freight_cost_type_id s come as an ordered list of integers
         --   which can be concatenated to be used for across pattern comparison purpose

         IF p_shpmnt_toplevel_charges.COUNT > 0 THEN
         -- {
         k := p_shpmnt_toplevel_charges.FIRST;

         LOOP
         -- {
            IF p_shpmnt_toplevel_charges(k).content_id = p_shpmnt_toplevel_rows(i).content_id THEN
               l_services_hash := CONCAT(l_services_hash,TO_CHAR(p_shpmnt_toplevel_charges(k).freight_cost_type_id));
            END IF;

            EXIT WHEN k = p_shpmnt_toplevel_charges.LAST;
            k := p_shpmnt_toplevel_charges.NEXT(k);

         -- }
         END LOOP;
         -- }
         END IF;

         --  See if already the same dual exists with (same commodity type for Sh-Wi ) a grouping rule = shipment.
         --  If yes, consolidate this one to that. If no, create a new pricing dual instance

         l_pattern_index := l_pattern_index + 1;

         --  Create a new record into x_pattern_rows here

         x_pattern_rows(l_pattern_index).pattern_index := l_pattern_index;
         x_pattern_rows(l_pattern_index).content_id := p_shpmnt_toplevel_rows(i).content_id;
         x_pattern_rows(l_pattern_index).pattern_no := l_pattern_no;
         x_pattern_rows(l_pattern_index).services_hash := l_services_hash;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done initializing pattern row');
         IF l_grouping_level = 'CONTAINER' THEN
         -- {

             l_count_pattern := 1;
             create_new_instance (
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   --p_toplevel_line_id        =>     p_shpmnt_toplevel_rows(i).content_id,
                   p_toplevel_lines        =>     p_shpmnt_toplevel_rows(i),
                   p_grouping_level          =>     l_grouping_level,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   p_instance_count          =>     x_pricing_dual_instances.COUNT,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'create_instance for container '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_create_instance_failed;
                END IF;
             ELSE -- What happens if no new instance is created ? Exception ?
                  -- already handled inside the called procedure
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Instance created for container '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

             --  Create a new record into x_pricing_dual_instances here
             l_instance_index := x_pricing_dual_instances.COUNT + 1;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).instance_index := l_instance_index;
             x_pricing_dual_instances(l_instance_index).pattern_no     := l_pattern_no;
             x_pricing_dual_instances(l_instance_index).services_hash  := l_services_hash;
             x_pricing_dual_instances(l_instance_index).grouping_level := l_grouping_level;
             x_pricing_dual_instances(l_instance_index).aggregation    := l_aggregation;
             x_pricing_dual_instances(l_instance_index).objective      := l_pricing_objective;
             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;   --  Need to be incremented and initialized appropriately


          -- }
         ELSIF l_grouping_level ='SHIPMENT' THEN    --  Grouping level = shipment
         -- {


            -- Now search for matching patterns
            -- Pass in x_pricing_dual_instances,x_pricing_engine_rows,l_pattern,l_grouping_level,
            -- l_aggregation,l_pricing_objective,l_rolledup_category_rows
            -- and additional services hash for current pattern (at the top line level)
            -- Get back matching instance_index (if matches), -100 if does not match

           IF l_cont_basis_count = 0 THEN
           -- {

            l_instance_count := x_pricing_dual_instances.COUNT;

            IF l_instance_count > 0 THEN
            -- {

             --  Need to search here

             search_matching_instance (
                --p_rolledup_category_rows  =>     l_rolledup_category_rows,
                --p_rolledup_category_basis =>     l_rolledup_category_basis,
                p_pattern_no              =>     l_pattern_no,      -- Created here
                p_grouping_level          =>     l_grouping_level,
                p_aggregation             =>     l_aggregation,
                p_objective               =>     l_pricing_objective,
                p_toplevel_charges_hash   =>     l_services_hash, -- Created here from p_shpmnt_toplevel_charges
                p_pricing_dual_instances  =>     x_pricing_dual_instances,
                --p_pricing_engine_rows     =>     x_pricing_engine_rows,
                x_matched_instance_index  =>     l_matched_instance_index,  --  -100 if does not match
                x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'search for container '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_search_instance_failed;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matched Instance '||l_matched_instance_index||' found for container '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

            -- }
            END IF;

           -- }  -- l_cont_basis_count = 0
           END IF;

           IF l_cont_basis_count > 0
           OR (l_cont_basis_count = 0 AND l_instance_count = 0)
           OR (l_cont_basis_count = 0 AND l_matched_instance_index = -100)  THEN
                --  Create new instance and engine row here

             l_count_pattern := 1;
             create_new_instance (
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   --p_toplevel_line_id        =>     p_shpmnt_toplevel_rows(i).content_id,
                   p_toplevel_lines        =>     p_shpmnt_toplevel_rows(i),
                   p_grouping_level          =>     l_grouping_level,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   p_instance_count          =>     x_pricing_dual_instances.COUNT,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'create_instance for container '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_create_instance_failed;
                END IF;
             ELSE -- What happens if no new instance is created ? Exception ?
                  -- already handled inside the called procedure
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Instance created for container '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

              --  Create a new record into x_pricing_dual_instances here

             l_instance_index := x_pricing_dual_instances.COUNT + 1;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).instance_index := l_instance_index;
             x_pricing_dual_instances(l_instance_index).pattern_no     := l_pattern_no;
             x_pricing_dual_instances(l_instance_index).services_hash  := l_services_hash;
             x_pricing_dual_instances(l_instance_index).grouping_level := l_grouping_level;
             x_pricing_dual_instances(l_instance_index).aggregation    := l_aggregation;
             x_pricing_dual_instances(l_instance_index).objective      := l_pricing_objective;
             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;   --  Need to be incremented and initialized appropriately

           ELSE  --   Found a matching instance

              --  Add to the matching instance l_matched_instance_index

             l_count_pattern := x_pricing_dual_instances(l_matched_instance_index).count_pattern + 1;
             add_to_instance (
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   p_matching_instance_index =>     l_matched_instance_index,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'add_to_instance for container '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_add_to_instance_failed;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Container '||p_shpmnt_toplevel_rows(i).content_id||' added to instance '||l_matched_instance_index);
             END IF;

              --  Modify x_pricing_dual_instances(l_matched_instance_index) here
             l_instance_index := l_matched_instance_index;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;

           END IF;
          -- }
          END IF;  -- grouping level

      -- }
      ELSE   -- shipment top level loose item
             -- new code to use patterns for loose items
      -- {
             -- look up basis for current top level row (loose item)
             -- assign pattern_no based on basis
             -- create new pattern row
             -- find out grouping level and aggregation level
             -- if grouping level = ITEM
             --    create new instance
             -- else    -- if grouping_level = SHIPMENT
             --    if instance_count > 0
             --          search for matching instance
             --    end if
             --    if instance_count = 0 or no match found
             --          create new instance
             --    else
             --          add to instance
             --    end if
             --  end if


                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'For loose item :'|| p_shpmnt_toplevel_rows(i).content_id);

             l_rolledup_rec.delivery_detail_id := null;
             l_rolledup_rec.container_id       := null;
             l_rolledup_rec.category_id        := null;
             l_rolledup_rec.rate_basis         := null;
             l_rolledup_rec.line_quantity      := null;
             l_rolledup_rec.line_uom           := null;

             -- find basis

             l_rolledup_lines.DELETE;  -- bug 2779306
             rollup_loose_item (
                 p_loose_item_id           => p_shpmnt_toplevel_rows(i).content_id,
                 p_classification_code     => p_classification_code,
                 p_lane_basis              => p_lane_basis,
                 p_lane_id                 => p_lane_id,
                 x_rolledup_rec            => l_rolledup_rec,
                 x_return_status           => l_return_status );


                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Loose Item '||p_shpmnt_toplevel_rows(i).content_id);
                           raise FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed;
                        END IF;
                END IF;

           l_rolledup_rec.master_container_id := p_shpmnt_toplevel_rows(i).content_id;
           g_rolledup_lines(p_shpmnt_toplevel_rows(i).content_id).master_container_id := p_shpmnt_toplevel_rows(i).content_id;

                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'rollup_rec ->');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'       delivery_detail_id = '||
                l_rolledup_rec.delivery_detail_id||'   container_id='||l_rolledup_rec.container_id||' category_id = '||l_rolledup_rec.category_id
          ||' rate_basis = '||l_rolledup_rec.rate_basis||' qty='||l_rolledup_rec.line_quantity||' '||l_rolledup_rec.line_uom);

              IF (nvl(l_rolledup_rec.line_quantity,0) = 0) THEN
                  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Rolled up line has line quantity = 0');
                  raise FTE_FREIGHT_PRICING_UTIL.g_invalid_line_quantity;
              END IF;

             IF (l_rolledup_rec.rate_basis = G_WEIGHT_BASIS) THEN
                 l_pattern_no   := G_PATTERN_9;
                 l_pattern_name := G_PATTERN_9_NAME;
             ELSIF (l_rolledup_rec.rate_basis = G_VOLUME_BASIS) THEN
                 l_pattern_no   := G_PATTERN_10;
                 l_pattern_name := G_PATTERN_10_NAME;
             ELSE
                 raise FTE_FREIGHT_PRICING_UTIL.g_invalid_basis;
             END IF;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done identifying pattern: '||l_pattern_no);

         l_pattern_index := l_pattern_index + 1;

         --  Create a new record into x_pattern_rows here

         x_pattern_rows(l_pattern_index).pattern_index := l_pattern_index;
         x_pattern_rows(l_pattern_index).content_id := p_shpmnt_toplevel_rows(i).content_id;
         x_pattern_rows(l_pattern_index).pattern_no := l_pattern_no;
         x_pattern_rows(l_pattern_index).services_hash := null;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done initializing pattern row');

         --  Look up FTE pricing preferences table to find out the pricing dual for that pattern

         l_grouping_level   := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).grouping_level;
         l_aggregation      := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).commodity_aggregation;
         -- l_pricing_objective := FTE_FREIGHT_PRICING_SPECIAL.g_lane_rules_tab(l_pattern_no).pricing_objective;
         l_pricing_objective := NULL;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done getting pricing dual');
         l_rolledup_lines(1) := l_rolledup_rec;

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_rolledup_lines.COUNT = '||l_rolledup_lines.COUNT);

         IF l_grouping_level = 'ITEM' THEN
         -- {

             l_count_pattern := 1;
             create_new_instance (
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   --p_toplevel_line_id        =>     p_shpmnt_toplevel_rows(i).content_id,
                   p_toplevel_lines        =>     p_shpmnt_toplevel_rows(i),
                   p_grouping_level          =>     l_grouping_level,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   p_instance_count          =>     x_pricing_dual_instances.COUNT,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'create_instance for loose item '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_create_instance_failed;
                END IF;
             ELSE -- What happens if no new instance is created ? Exception ?
                  -- already handled inside the called procedure
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Instance created for loose item '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

             --  Create a new record into x_pricing_dual_instances here
             l_instance_index := x_pricing_dual_instances.COUNT + 1;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).instance_index := l_instance_index;
             x_pricing_dual_instances(l_instance_index).pattern_no     := l_pattern_no;
             x_pricing_dual_instances(l_instance_index).services_hash  := null;
             x_pricing_dual_instances(l_instance_index).grouping_level := l_grouping_level;
             x_pricing_dual_instances(l_instance_index).aggregation    := l_aggregation;
             x_pricing_dual_instances(l_instance_index).objective      := l_pricing_objective;
             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;   --  Need to be incremented and initialized appropriately
             x_pricing_dual_instances(l_instance_index).loose_item_flag := 'Y';
             -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'instance_index = '||l_instance_index||' loose_item_flag ='||x_pricing_dual_instances(l_instance_index).loose_item_flag);


          -- }
         ELSE         -- Grouping level = 'SHIPMENT'  (Loose Items only)
          -- {

              -- should we be looking only at loose item instances? or this will be handled by
              -- search matching instances?
              l_instance_count := x_pricing_dual_instances.COUNT;

            IF l_instance_count > 0 THEN
            -- {

             --  Need to search here

             search_matching_instance (
                p_pattern_no              =>     l_pattern_no,      -- Created here
                p_grouping_level          =>     l_grouping_level,
                p_aggregation             =>     l_aggregation,
                p_objective               =>     l_pricing_objective,
                p_toplevel_charges_hash   =>     null, -- Created here from p_shpmnt_toplevel_charges
                p_pricing_dual_instances  =>     x_pricing_dual_instances,
                x_matched_instance_index  =>     l_matched_instance_index,  --  -100 if does not match
                x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'search for loose item '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_search_instance_failed;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matched Instance '||l_matched_instance_index||' found for loose item '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

            -- }
            END IF;

            IF ( l_instance_count = 0 OR l_matched_instance_index = -100)  THEN
            -- {

             l_count_pattern := 1;
             create_new_instance (
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   p_toplevel_lines          =>     p_shpmnt_toplevel_rows(i),
                   p_grouping_level          =>     l_grouping_level,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   p_instance_count          =>     x_pricing_dual_instances.COUNT,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'create_instance for loose item '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_create_instance_failed;
                END IF;
             ELSE -- What happens if no new instance is created ? Exception ?
                  -- already handled inside the called procedure
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Instance created for loose item '||p_shpmnt_toplevel_rows(i).content_id);
             END IF;

              --  Create a new record into x_pricing_dual_instances here

             l_instance_index := x_pricing_dual_instances.COUNT + 1;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).instance_index := l_instance_index;
             x_pricing_dual_instances(l_instance_index).pattern_no     := l_pattern_no;
             x_pricing_dual_instances(l_instance_index).services_hash  := l_services_hash;
             x_pricing_dual_instances(l_instance_index).grouping_level := l_grouping_level;
             x_pricing_dual_instances(l_instance_index).aggregation    := l_aggregation;
             x_pricing_dual_instances(l_instance_index).objective      := l_pricing_objective;
             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;   --  Need to be incremented and initialized appropriately
             x_pricing_dual_instances(l_instance_index).loose_item_flag := 'Y';
             -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'instance_index = '||l_instance_index||' loose_item_flag ='||x_pricing_dual_instances(l_instance_index).loose_item_flag);

            -- }
           ELSE
            -- {
              -- match found
              --  Add to the matching instance l_matched_instance_index

             l_count_pattern := x_pricing_dual_instances(l_matched_instance_index).count_pattern + 1;
             -- new method --
             add_to_instance (
                   p_container_flag          =>     p_shpmnt_toplevel_rows(i).container_flag,
                   p_rolled_up_lines         =>     l_rolledup_lines,
                   p_matching_instance_index =>     l_matched_instance_index,
                   p_aggregation             =>     l_aggregation,
                   p_objective               =>     l_pricing_objective,
                   x_pricing_engine_rows     =>     x_pricing_engine_rows,
                   x_pricing_attribute_rows  =>     x_pricing_attribute_rows,
                   x_return_status           =>     l_return_status );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'add_to_instance for loose item '||p_shpmnt_toplevel_rows(i).content_id);
                    raise FTE_FREIGHT_PRICING_UTIL.g_add_to_instance_failed;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loose Item '||p_shpmnt_toplevel_rows(i).content_id||' added to instance '||l_matched_instance_index);
             END IF;

              --  Modify x_pricing_dual_instances(l_matched_instance_index) here
             l_instance_index := l_matched_instance_index;
             x_pattern_rows(l_pattern_index).instance_index := l_instance_index;

             x_pricing_dual_instances(l_instance_index).count_pattern  := l_count_pattern;
             -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'instance_index = '||l_instance_index||' loose_item_flag ='||x_pricing_dual_instances(l_instance_index).loose_item_flag);

            -- }
           END IF;

          -- }
         END IF;  -- grouping level


      -- }    -- container_flag
      END IF;

      IF x_pricing_engine_rows.COUNT > l_curr_engine_row_count THEN
      -- {
      l_attribute_index := l_curr_attribute_count;
      m := l_curr_engine_row_count + 1;
      LOOP

       IF p_shpmnt_toplevel_charges.COUNT > 0 THEN
       l := p_shpmnt_toplevel_charges.FIRST;
       LOOP

         IF p_shpmnt_toplevel_charges(l).content_id = p_shpmnt_toplevel_rows(i).content_id THEN

           l_attribute_index := l_attribute_index + 1;
           x_pricing_attribute_rows(l_attribute_index).attribute_index := l_attribute_index;
           x_pricing_attribute_rows(l_attribute_index).input_index     := x_pricing_engine_rows(m).input_index;
           x_pricing_attribute_rows(l_attribute_index).attribute_name  := 'ADDITIONAL_CHARGE';
           x_pricing_attribute_rows(l_attribute_index).attribute_value := p_shpmnt_toplevel_charges(l).freight_cost_type_code;

         END IF;

         EXIT WHEN l = p_shpmnt_toplevel_charges.LAST;
         l := p_shpmnt_toplevel_charges.NEXT(l);
       END LOOP;
       -- }
       END IF;

       EXIT WHEN m = x_pricing_engine_rows.LAST;
       m := x_pricing_engine_rows.NEXT(m);
      END LOOP;
      END IF;

      <<nextpass>>

      EXIT WHEN i = p_shpmnt_toplevel_rows.LAST;
      i := p_shpmnt_toplevel_rows.NEXT(i);

   -- }
   END LOOP;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_function='||l_lane_function);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_classification_code='||p_classification_code);

  IF l_lane_function = 'LTL' and p_classification_code = 'FC' THEN

   print_rolledup_lines (
        p_rolledup_lines          =>   g_rolledup_lines,
        x_return_status           =>   l_return_status );

   print_engine_rows (
        p_engine_rows             =>    x_pricing_engine_rows,
        x_return_status           =>    l_return_status );

    FTE_FREIGHT_PRICING_SPECIAL.distribute_LTL_container_wt(
        p_top_level_rows          => 	p_shpmnt_toplevel_rows,
        x_pricing_engine_rows     =>    x_pricing_engine_rows,
        x_return_status           =>    l_return_status );

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF; --l_lane_function = 'LTL' and p_classification_code = 'FC'

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_initialize_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_initialize_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_rollup_container_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_rollup_container_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_invalid_line_quantity THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_invalid_line_quantity');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_dimensional_weight_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_dimensional_weight_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_instance_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_create_instance_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_search_instance_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_search_instance_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_add_to_instance_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_add_to_instance_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_category_not_found THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_category_not_found');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_invalid_basis');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'basis_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_loose_item_wrong_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_loose_item_wrong_basis');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Loose item can not have container basis');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Loose item can not have container basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'process_shipment_pattern');

-- }
END process_shipment_pattern;

PROCEDURE get_currency_code (
          p_carrier_id      IN   NUMBER,
          x_currency_code   OUT NOCOPY   wsh_carriers.currency_code%TYPE,
          x_return_status   OUT NOCOPY   VARCHAR2)
IS

    CURSOR c_get_currency IS
    SELECT currency_code
    FROM   wsh_carriers
    WHERE  carrier_id = p_carrier_id;

    --l_currency_code     wsh_carriers.currency_code%TYPE;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_currency_code','start');

    OPEN c_get_currency;
    FETCH c_get_currency INTO x_currency_code;
    IF c_get_currency%NOTFOUND THEN
       raise FTE_FREIGHT_PRICING_UTIL.g_no_currency_found;
       CLOSE c_get_currency;
    END IF;
    CLOSE c_get_currency;

    --RETURN l_currency_code;
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_currency_code');

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_currency_found THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_currency_code',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_currency_found');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('currency_not_found ');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'currency_not_found ');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_currency_code');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_currency_code',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_currency_code');
END get_currency_code;

-- shipment_rating will be called by
--	WSH-LCSS (FTE_FREIGHT_RATING_DLVY_GRP.Rate_Delivery)
--  and OM-LCSS, (FTE_FREIGHT_RATING_PUB.Get_Freight_Costs)
--  and OM-DisplayChoices (FTE_FREIGHT_RATING_PUB.Get_Services)
--
-- shipment_rating rate shipments in g_shipment_line_rows on p_lane_id and p_service_type
-- if p_mode_of_transport = 'TRUCK' it calls tl_shipment_pricing
-- otherwise it calls shipment_pricing
-- shipment_rating always returns rates in pl/sql table
--
PROCEDURE shipment_rating (
        p_lane_id                 	IN     	   NUMBER,
        p_service_type            	IN         VARCHAR2,
        p_mode_of_transport		IN	   VARCHAR2,
        p_ship_date               	IN     	   DATE  DEFAULT sysdate,
        p_arrival_date            	IN     	   DATE  DEFAULT sysdate,
        p_currency_code                 IN         VARCHAR2 DEFAULT NULL,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom	OUT NOCOPY VARCHAR2,
        x_freight_cost_temp_price  	OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY Freight_Cost_Temp_Tab_Type,
        x_return_status           	OUT NOCOPY VARCHAR2,
        x_msg_count               	OUT NOCOPY NUMBER,
        x_msg_data                	OUT NOCOPY VARCHAR2 )
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'SHIPMENT_RATING';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(240);
  l_first_level_rows  	  shpmnt_content_tab_type;
  l_first_level_charges   addl_services_tab_type;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_lane_id='||p_lane_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_service_type='||p_service_type);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_mode_of_transport='||p_mode_of_transport);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_ship_date='||p_ship_date);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_arrival_date='||p_arrival_date);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'flatten shipment... ');

        flatten_shipment (
            x_first_level_rows        =>    l_first_level_rows,
            x_return_status           =>    l_return_status );

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
           l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
        ELSE
           FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level, 'No. of top level lines 7 : '||l_first_level_rows.COUNT);
           IF l_first_level_rows.COUNT = 0 THEN
               raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
           END IF;
        END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_currency_code='|| p_currency_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'call shipment_pricing... ');
    shipment_pricing (
        p_lane_id 			=> p_lane_id,
        p_service_type			=> p_service_type,
        p_ship_date			=> p_ship_date,
        p_arrival_date			=> p_arrival_date,
        p_shpmnt_toplevel_rows    	=> l_first_level_rows,
        p_shpmnt_toplevel_charges 	=> l_first_level_charges,
        p_save_flag               	=> 'P',
        p_currency_code                 => p_currency_code,
        x_summary_lanesched_price      	=> x_summary_lanesched_price,
        x_summary_lanesched_price_uom  	=> x_summary_lanesched_price_uom,
        x_freight_cost_temp_price      	=> x_freight_cost_temp_price,
        x_freight_cost_temp_charge     	=> x_freight_cost_temp_charge,
        x_return_status           	=> l_return_status ) ;

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
           l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed;
        END IF;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_shipment_pricing_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_flatten_shipment_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END shipment_rating;


--      This procedure is the basic shipment freight charge calculation API
--      Takes a lane id/schedule id  or WSH trip id
--      It processes each input shipment content line to identify their patterns
--      and to construct input lines to send to the QP engine using the Pricing preferences
--      Uses process_shipment_pattern to construct inputs to QP engine line and attribute line
--      This API also calls out post-processing APIs and saves to
--      WSH_FREIGHT_COSTS or FTE_FREIGHT_COSTS_TEMP depending on p_save_flag values ('T' or 'M')
--      Looks up delivery detail info from g_shipment_line_rows

PROCEDURE shipment_pricing (
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_segment_id              IN     NUMBER DEFAULT NULL,-- Input either Lane/schedule or the trip segment
        p_service_type            IN     VARCHAR2 DEFAULT NULL, -- service type is required with lane/schedule
        p_ship_date               IN     DATE  DEFAULT sysdate, -- VVP (09/30/02)
        p_arrival_date            IN     DATE  DEFAULT sysdate, -- VVP (09/30/02)
        --p_shpmnt_toplevel_rows    IN OUT NOCOPY  shpmnt_content_tab_type,
        p_shpmnt_toplevel_rows    IN     shpmnt_content_tab_type, /* bug# 2501240 -VVP */
        p_shpmnt_toplevel_charges IN     addl_services_tab_type, -- Top level requested additional services
--      p_shpmnt_charges          IN     shpmnt_charges_tab_type,  --  Not supported in Phase I
        p_save_flag               IN     VARCHAR2, -- Whether to save to TEMP table or MAIN table
        p_request_id              IN     NUMBER DEFAULT NULL, -- Required only in case of saving to TEMP table
        p_currency_code           IN     VARCHAR2 DEFAULT NULL,
        x_summary_lanesched_price      OUT NOCOPY     NUMBER,   -- Only in case of 'T'
        x_summary_lanesched_price_uom  OUT NOCOPY     VARCHAR2,
        x_freight_cost_temp_price  OUT NOCOPY     Freight_Cost_Temp_Tab_Type,
        x_freight_cost_temp_charge OUT NOCOPY     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

        CURSOR c_get_lane_info(c_lane_id IN NUMBER) IS
        SELECT fl.lane_id,fl.carrier_id,flrc.list_header_id pricelist_id,
               fl.mode_of_transportation_code,fl.origin_id,fl.destination_id,
               fl.basis,fl.commodity_catg_id,fl.service_type_code,fl.comm_fc_class_code
        FROM   fte_lanes fl, fte_lane_rate_charts flrc
        WHERE  fl.lane_id = c_lane_id
    	AND    fl.lane_id = flrc.lane_id
	AND    (flrc.start_date_active is null OR flrc.start_date_active <= p_ship_date)
	AND    (flrc.end_date_active is null OR flrc.end_date_active > p_ship_date);

        CURSOR c_get_lane_info_from_trip(c_wsh_trip_id IN NUMBER) IS
        SELECT fl.lane_id,fl.carrier_id,flrc.list_header_id pricelist_id,
               fl.mode_of_transportation_code,fl.origin_id,fl.destination_id,
               fl.basis,fl.commodity_catg_id,fl.service_type_code,fl.comm_fc_class_code
        FROM   fte_lanes fl, wsh_trips wt, fte_lane_rate_charts flrc
        WHERE  fl.lane_id = wt.lane_id
        AND    wt.trip_id = c_wsh_trip_id
    	AND    fl.lane_id = flrc.lane_id
	AND    (flrc.start_date_active is null OR flrc.start_date_active <= p_ship_date)
	AND    (flrc.end_date_active is null OR flrc.end_date_active > p_ship_date);

        CURSOR c_get_lane_info_from_schedule(c_schedule_id IN NUMBER) IS
        SELECT fl.lane_id,fl.carrier_id,flrc.list_header_id pricelist_id,
               fl.mode_of_transportation_code,fl.origin_id,fl.destination_id,
               fl.basis,fl.commodity_catg_id,fl.service_type_code,fl.comm_fc_class_code
        FROM   fte_lanes fl, fte_schedules fs, fte_lane_rate_charts flrc
        WHERE  fl.lane_id = fs.lane_id
        AND    fs.schedules_id = c_schedule_id
    	AND    fl.lane_id = flrc.lane_id
	AND    (flrc.start_date_active is null OR flrc.start_date_active <= p_ship_date)
	AND    (flrc.end_date_active is null OR flrc.end_date_active > p_ship_date);

        CURSOR c_get_service_type(c_wsh_trip_id IN NUMBER) IS
        SELECT service_level
        FROM   wsh_trips
        WHERE  trip_id = c_wsh_trip_id;

        i                                    NUMBER:=0;
        j                                    NUMBER:=0;
        k                                    NUMBER:=0;
        l                                    NUMBER:=0;
        m                                    NUMBER:=0;
        n                                    NUMBER:=0;
        o                                    NUMBER:=0;
        l_return_status                      VARCHAR2(1);
        l_service_type                       VARCHAR2(60);
        l_currency_code                      VARCHAR2(30);

        l_lane_info                          lane_info_rec_type;
        l_pricing_dual_instances             pricing_dual_instance_tab_type;
        l_pricing_engine_rows                pricing_engine_input_tab_type;
        l_pattern_rows                       top_level_pattern_tab_type;
        l_pricing_attribute_rows             pricing_attribute_tab_type;
        l_pricing_control_rec                pricing_control_input_rec_type;
        l_pricing_qualifier                  fte_qual_rec_type;
        l_pricing_engine_output_lines        QP_PREQ_GRP.LINE_TBL_TYPE;
        l_qp_output_line_details             QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
        l_freight_cost_main_price            Freight_Cost_Main_Tab_Type;
        l_freight_cost_main_charge           Freight_Cost_Main_Tab_Type;
        l_freight_cost_temp_price            Freight_Cost_Temp_Tab_Type;
        l_freight_cost_temp_charge           Freight_Cost_Temp_Tab_Type;
        l_fc_main_update_rows                Freight_Cost_Main_Tab_Type;
        l_freight_cost_id                    NUMBER;
        l_freight_cost_main_ids              WSH_UTIL_CORE.id_tab_type;
        l_freight_cost_temp_ids              WSH_UTIL_CORE.id_tab_type;
        l_freight_cost_temp_id               NUMBER;
        l_rowid                              VARCHAR2(30);
        l_rowids                             WSH_UTIL_CORE.column_tab_type;
        l_temp_row_count                     NUMBER;
        l_return_status_text                 VARCHAR2(240);

        l_shpmnt_toplevel_rows              shpmnt_content_tab_type;
        p                                    NUMBER:=0;

        l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_pricing','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_lane_id='||p_lane_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_schedule_id='||p_schedule_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_segment_id='||p_segment_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_service_type='||p_service_type);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_ship_date='||p_ship_date);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_arrival_date='||p_arrival_date);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_save_flag='||p_save_flag);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_request_id='||p_request_id);

   -- Calls process_shipment_pattern and gets back l_pricing_engine_rows and l_pricing_attribute_rows
   -- Modifies l_pricing_attribute_rows to add more rows to it
   -- Calls call_qp_engine passing in l_pricing_engine_rows,l_pricing_attribute_rows and l_pricing_qualifier
   -- Gets back l_pricing_engine_output_lines and l_qp_output_line_details
   -- Processes these two tables together with l_pricing_dual_instances and g_shipment_line_rows
   -- Prepares records to go to WSH_FREIGHT_COST main/temp table


   g_effectivity_dates.date_from     := p_ship_date;
   g_effectivity_dates.date_to       := p_arrival_date;

   IF p_lane_id IS NULL AND p_segment_id IS NULL AND p_schedule_id IS NULL THEN

      raise FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg;

   ELSIF p_lane_id IS NULL AND p_schedule_id IS NULL THEN

      OPEN c_get_lane_info_from_trip(p_segment_id);
      FETCH c_get_lane_info_from_trip INTO l_lane_info;
      IF c_get_lane_info_from_trip%NOTFOUND THEN
         CLOSE c_get_lane_info_from_trip;
         raise FTE_FREIGHT_PRICING_UTIL.g_no_lane_info;
      END IF;
      CLOSE c_get_lane_info_from_trip;

      OPEN c_get_service_type(p_segment_id);
      FETCH c_get_service_type INTO l_service_type;
      -- Is this required TODO
      IF c_get_service_type%NOTFOUND THEN
         CLOSE c_get_service_type;
         raise FTE_FREIGHT_PRICING_UTIL.g_no_segment_service_type;
      END IF;
      CLOSE c_get_service_type;

   ELSIF p_segment_id IS NULL AND p_schedule_id IS NULL THEN

      OPEN c_get_lane_info(p_lane_id);
      FETCH c_get_lane_info INTO l_lane_info;
      IF c_get_lane_info%NOTFOUND THEN
         CLOSE c_get_lane_info;
         raise FTE_FREIGHT_PRICING_UTIL.g_no_lane_info;
      END IF;
      CLOSE c_get_lane_info;

      l_service_type := p_service_type;

   ELSIF p_segment_id IS NULL AND p_lane_id IS NULL THEN

      OPEN c_get_lane_info_from_schedule(p_schedule_id);
      FETCH c_get_lane_info_from_schedule INTO l_lane_info;
      IF c_get_lane_info_from_schedule%NOTFOUND THEN
         CLOSE c_get_lane_info_from_schedule;
         raise FTE_FREIGHT_PRICING_UTIL.g_no_lane_info;
      END IF;
      CLOSE c_get_lane_info_from_schedule;

      l_service_type := p_service_type;

   END IF;

   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_info.lane_id='||l_lane_info.lane_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_info.pricelist_id='||l_lane_info.pricelist_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_service_type='||l_service_type);

   -- Modified for 12i for multi currency support. Get the currency code in the begining
   -- to use everywhere.

   IF p_currency_code IS NULL THEN
            get_currency_code(
            p_carrier_id      =>   l_lane_info.carrier_id,
            x_currency_code   =>   l_currency_code,
            x_return_status   =>   l_return_status );  -- New API

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'get_currency_code ');
                   raise FTE_FREIGHT_PRICING_UTIL.g_currency_code_failed;
              END IF;
           ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Currency code for carrier '||l_lane_info.carrier_id||' is : '||l_currency_code);
           END IF;
   ELSE
        l_currency_code := p_currency_code;
   END IF;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Currency Code is = ' || l_currency_code);

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Rate Basis is =' || l_lane_info.basis);

   IF l_lane_info.basis = 'CONTAINER_ALL' THEN

     l_lane_info.service_type_code := l_service_type;

     FTE_FREIGHT_PRICING_SPECIAL.rate_container_all(
        p_lane_info			=> l_lane_info,
        p_top_level_rows          	=> p_shpmnt_toplevel_rows,
        p_save_flag               	=> p_save_flag,
        p_currency_code             => l_currency_code,
        x_freight_cost_main_price  	=> l_freight_cost_main_price,
        x_freight_cost_temp_price  	=> l_freight_cost_temp_price,
        x_freight_cost_main_charge 	=> l_freight_cost_main_charge,
        x_freight_cost_temp_charge 	=> l_freight_cost_temp_charge,
        x_fc_main_update_rows     	=> l_fc_main_update_rows,
        x_summary_lanesched_price  	=> x_summary_lanesched_price,
        x_summary_lanesched_price_uom 	=> x_summary_lanesched_price_uom,
        x_return_status           =>    l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
        and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;

   ELSE -- l_lane_info.basis <> 'CONTAINER_ALL'

       -- copy p_shpmnt_toplevel_rows to local l_shpmnt_toplevel_rows
       p := p_shpmnt_toplevel_rows.FIRST;
       IF p is NOT NULL THEN
       LOOP
          l_shpmnt_toplevel_rows(p) := p_shpmnt_toplevel_rows(p);
          EXIT WHEN p = p_shpmnt_toplevel_rows.LAST;
          p := p_shpmnt_toplevel_rows.NEXT(p);
       END LOOP;
       END IF;


       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' After copying top level rows ' );

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Service Type Code::=' || l_lane_info.service_type_code);

       process_shipment_pattern (
            p_classification_code     =>    l_lane_info.classification_code,
            p_lane_basis              =>    l_lane_info.basis,
            p_lane_id                 =>    l_lane_info.lane_id,
            p_carrier_id              =>    l_lane_info.carrier_id,
            p_service_code            =>    l_lane_info.service_type_code,
            --p_shpmnt_toplevel_rows    =>    p_shpmnt_toplevel_rows,
            p_shpmnt_toplevel_rows    =>    l_shpmnt_toplevel_rows,
            p_shpmnt_toplevel_charges =>    p_shpmnt_toplevel_charges,
            x_pricing_dual_instances  =>    l_pricing_dual_instances,
            x_pricing_engine_rows     =>    l_pricing_engine_rows,
            x_pattern_rows            =>    l_pattern_rows,
            x_pricing_attribute_rows  =>    l_pricing_attribute_rows,
            x_return_status           =>    l_return_status );


       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' After process_shipment_pattern ' );

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'process_shipment_pattern ');
              raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pattern_failed;
          END IF;
       ELSE -- What happens if no new instance is created ? Exception ?
            -- already handled inside the called procedure
          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_pricing_engine_rows.COUNT ||'engine rows created');
       END IF;

       IF FTE_FREIGHT_PRICING_SPECIAL.g_special_flags.lane_function = 'FLAT'
        AND FTE_FREIGHT_PRICING_SPECIAL.g_special_flags.flat_containerwt_flag = 'Y' THEN

         l_lane_info.service_type_code := l_service_type;

          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Inside FlatRate');

         FTE_FREIGHT_PRICING_SPECIAL.process_shipment_flatrate(
        p_lane_info			=> l_lane_info,
            p_top_level_rows          	=> l_shpmnt_toplevel_rows,
            p_save_flag               	=> p_save_flag,
            p_currency_code             => l_currency_code,
            x_freight_cost_main_price  	=> l_freight_cost_main_price,
            x_freight_cost_temp_price  	=> l_freight_cost_temp_price,
            x_freight_cost_main_charge 	=> l_freight_cost_main_charge,
            x_freight_cost_temp_charge 	=> l_freight_cost_temp_charge,
            x_fc_main_update_rows     	=> l_fc_main_update_rows,
            x_summary_lanesched_price  	=> x_summary_lanesched_price,
            x_summary_lanesched_price_uom 	=> x_summary_lanesched_price_uom,
            x_return_status           =>    l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
        and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;

       ELSE

          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Not in FlatRate');
           l_pricing_control_rec.pricing_event_num := G_LINE_EVENT_NUM;
           l_pricing_control_rec.currency_code     := l_currency_code;
           l_pricing_control_rec.lane_id           := l_lane_info.lane_id;
           l_pricing_control_rec.price_list_id     := l_lane_info.pricelist_id;
           l_pricing_control_rec.party_id          := l_lane_info.carrier_id;

           i := l_pricing_engine_rows.FIRST;
           j := l_pricing_attribute_rows.COUNT;
           LOOP

          j := j + 1;
             l_pricing_attribute_rows(j).attribute_index := j;
             l_pricing_attribute_rows(j).input_index     := l_pricing_engine_rows(i).input_index;
             l_pricing_attribute_rows(j).attribute_name  := 'ORIGIN_ZONE';
             l_pricing_attribute_rows(j).attribute_value := TO_CHAR(l_lane_info.origin_id);
          j := j + 1;
             l_pricing_attribute_rows(j).attribute_index := j;
             l_pricing_attribute_rows(j).input_index     := l_pricing_engine_rows(i).input_index;
             l_pricing_attribute_rows(j).attribute_name  := 'DESTINATION_ZONE';
             l_pricing_attribute_rows(j).attribute_value := TO_CHAR(l_lane_info.destination_id);

          IF l_service_type IS NOT NULL THEN

          j := j + 1;
             l_pricing_attribute_rows(j).attribute_index := j;
             l_pricing_attribute_rows(j).input_index     := l_pricing_engine_rows(i).input_index;
             l_pricing_attribute_rows(j).attribute_name  := 'SERVICE_TYPE';  --  Is it required always
             l_pricing_attribute_rows(j).attribute_value := l_service_type;

          END IF;

          -- logistics:total_quantity and volume:total_quantity are special cases,
          -- Assuming category, container_type,additional_services
          -- and hazard_code
          -- come from process_shipment_pattern

          EXIT WHEN i = l_pricing_engine_rows.LAST;
          i := l_pricing_engine_rows.NEXT(i);

       END LOOP;

      -- Print engine input details

       print_rolledup_lines (
            p_rolledup_lines          =>   g_rolledup_lines,
            x_return_status           =>   l_return_status );

       print_top_level_detail (
            --p_first_level_rows        =>    p_shpmnt_toplevel_rows,
            p_first_level_rows        =>    l_shpmnt_toplevel_rows,
            x_return_status           =>    l_return_status );

       print_top_level_pattern (
            p_pattern_rows            =>    l_pattern_rows,
            x_return_status           =>    l_return_status );

       print_dual_instances (
            p_dual_instances          =>    l_pricing_dual_instances,
            x_return_status           =>    l_return_status );

       print_engine_rows (
            p_engine_rows             =>    l_pricing_engine_rows,
            x_return_status           =>    l_return_status );

       print_attribute_rows (
            p_attribute_rows          =>    l_pricing_attribute_rows,
            x_return_status           =>    l_return_status );

      -- First prototype breakpoint

     FTE_FREIGHT_PRICING_SPECIAL.process_special_conditions(
            p_pricing_control_rec     =>     l_pricing_control_rec,
            --p_top_level_rows          =>     p_shpmnt_toplevel_rows,
            p_top_level_rows          =>     l_shpmnt_toplevel_rows,
            p_pattern_rows            =>     l_pattern_rows,
            p_pricing_dual_instances  =>     l_pricing_dual_instances,
            x_pricing_engine_rows     =>     l_pricing_engine_rows,
            x_pricing_attribute_rows  =>     l_pricing_attribute_rows ,
            x_qp_output_line_rows     =>     l_pricing_engine_output_lines,  -- line_index = input_index
            x_qp_output_detail_rows   =>     l_qp_output_line_details,
            x_return_status           =>     l_return_status );

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'process_special_conditions ');
              raise FTE_FREIGHT_PRICING_UTIL.g_special_conditions_failed;
          END IF;
       ELSE -- What happens if no QP output lines come back ? Exception ?
            -- already handled inside the called procedure
          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_pricing_engine_output_lines.COUNT ||' QP output lines resulted ');
       END IF;

       print_qp_output_lines (
            p_engine_output_line             =>    l_pricing_engine_output_lines,
            p_engine_output_detail           =>    l_qp_output_line_details,
            p_return_status                  =>    l_return_status_text ,
            x_return_status                  =>    l_return_status );

       process_qp_output (
            p_qp_output_line_rows     =>    l_pricing_engine_output_lines,  -- line_index = input_index
            p_qp_output_detail_rows   =>    l_qp_output_line_details,
            p_pricing_engine_input    =>    l_pricing_engine_rows,
            p_pricing_dual_instances  =>    l_pricing_dual_instances,
            p_pattern_rows            =>    l_pattern_rows,
            --p_shpmnt_toplevel_rows    =>    p_shpmnt_toplevel_rows,      -- Indexed on delivery_detail_id
            p_shpmnt_toplevel_rows    =>    l_shpmnt_toplevel_rows,      -- Indexed on delivery_detail_id
            p_save_flag               =>    p_save_flag, -- Whether to save to TEMP table or MAIN table
            p_rate_basis              =>    l_lane_info.basis,
            x_freight_cost_main_price  =>   l_freight_cost_main_price,
            x_freight_cost_temp_price  =>   l_freight_cost_temp_price,
            x_freight_cost_main_charge =>   l_freight_cost_main_charge,
            x_freight_cost_temp_charge =>   l_freight_cost_temp_charge,
            x_fc_main_update_rows     =>    l_fc_main_update_rows,  -- For update of SUMMARY records
            x_summary_lanesched_price  =>    x_summary_lanesched_price,   -- Only in case of 'T'
            x_summary_lanesched_price_uom => x_summary_lanesched_price_uom,
            x_return_status           =>    l_return_status ) ;

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'process_qp_output');
              raise FTE_FREIGHT_PRICING_UTIL.g_process_qp_output_failed;
          END IF;
       ELSE -- What happens if no new fc records created ? Exception ?
            -- already handled inside the called procedure ?
          -- IF p_save_flag = 'T' THEN   --  Means  either lane/schedule has been passed in
          IF p_save_flag <> 'M' THEN   --  VVP (OM Est change)
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_freight_cost_temp_price.COUNT ||' FC temp price records resulted ');
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_freight_cost_temp_charge.COUNT ||' FC temp charge records resulted ');
          ELSIF p_save_flag = 'M' THEN   --  Means  either lane/schedule has been passed in
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_freight_cost_main_price.COUNT ||' FC main price records resulted ');
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_freight_cost_main_charge.COUNT ||' FC main charge records resulted ');
          END IF;
       END IF;

       END IF;  -- l_is_shipment_flatrate = 'N'

   END IF; -- l_lane_info.basis <> 'CONTAINER_ALL'


  --MDC Allocation

   Handle_MDC(
        p_save_flag=>p_save_flag,
        x_freight_cost_main_price  =>   l_freight_cost_main_price,
        x_freight_cost_temp_price  =>   l_freight_cost_temp_price,
        x_freight_cost_main_charge =>   l_freight_cost_main_charge,
        x_freight_cost_temp_charge =>   l_freight_cost_temp_charge,
        x_fc_main_update_rows     =>    l_fc_main_update_rows,  -- For update of SUMMARY records
        x_return_status           =>    l_return_status ) ;

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_MDC_handle_MDC;
      END IF;
   END IF;


   IF p_save_flag = 'M' THEN

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'CHARGE');
   print_fc_main_rows (
        p_fc_main_rows            =>   l_freight_cost_main_charge,
        x_return_status           =>   l_return_status );

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'BASE PRICE');
   print_fc_main_rows (
        p_fc_main_rows            =>   l_freight_cost_main_price,
        x_return_status           =>   l_return_status );

   ELSE

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'CHARGE');
   print_fc_temp_rows (
        p_fc_temp_rows            =>   l_freight_cost_temp_charge,
        x_return_status           =>   l_return_status );

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'BASE PRICE');
   print_fc_temp_rows (
        p_fc_temp_rows            =>   l_freight_cost_temp_price,
        x_return_status           =>   l_return_status );

   END IF;


   -- Insert one row at a time and get back the freight cost id
   -- create a table indexed on delivery detail id which stores the freight cost ids for the base price lines
   -- This table will then be used to populate applied_to_charge id for the charge record

   IF p_save_flag = 'T' THEN   --  Means  either lane/schedule has been passed in

      k := l_freight_cost_temp_price.FIRST;
      IF k is NOT NULL THEN
      LOOP
         l_freight_cost_temp_price(k).creation_date := SYSDATE;
         l_freight_cost_temp_price(k).created_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_temp_price(k).last_update_date    := sysdate;
         l_freight_cost_temp_price(k).last_updated_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_temp_price(k).last_update_login    := FND_GLOBAL.LOGIN_ID;
         l_freight_cost_temp_price(k).comparison_request_id := p_request_id;

         IF p_schedule_id IS NULL THEN
           l_freight_cost_temp_price(k).lane_id             := p_lane_id;   -- Need to insert schedule_id/lane_id
         ELSIF p_lane_id IS NULL THEN
           l_freight_cost_temp_price(k).schedule_id         := p_schedule_id;
         END IF;

         l_freight_cost_temp_price(k).moved_to_main_flag    := 'N';
         -- added for bug2741467
         l_freight_cost_temp_price(k).service_type_code     := l_service_type;


         -- pack J enhancement for FPA --
         IF ( l_freight_cost_temp_price(k).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_temp_price(k).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_temp_price(k).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_temp_price(k).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_temp_price(k).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_temp_price(k).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_temp_price(k).commodity_category_id);
         END IF;



   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Reprinting BASE PRICE');
   print_fc_temp_rows (
        p_fc_temp_rows            =>   l_freight_cost_temp_price,
        x_return_status           =>   l_return_status );



         Create_Freight_Cost_Temp(
            p_freight_cost_temp_info =>  l_freight_cost_temp_price(k),
            x_freight_cost_temp_id   =>  l_freight_cost_temp_id,
            x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Create_Freight_Cost_Temp Price');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_fc_temp_failed;
            END IF;
         END IF;

         IF l_freight_cost_temp_price(k).line_type_code <> 'SUMMARY' THEN
            l_freight_cost_temp_ids(l_freight_cost_temp_price(k).delivery_detail_id) := l_freight_cost_temp_id;
         END IF;

         EXIT WHEN k=l_freight_cost_temp_price.LAST;
         k := l_freight_cost_temp_price.NEXT(k);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Temp fc base price record got created');
      END IF;

      n := l_freight_cost_temp_charge.FIRST;
      IF n IS NOT NULL THEN
      LOOP
         l_freight_cost_temp_charge(n).creation_date := SYSDATE;
         l_freight_cost_temp_charge(n).created_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_temp_charge(n).last_update_date    := sysdate;
         l_freight_cost_temp_charge(n).last_updated_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_temp_charge(n).last_update_login    := FND_GLOBAL.LOGIN_ID;
         l_freight_cost_temp_charge(n).comparison_request_id := p_request_id;

         IF p_schedule_id IS NULL THEN
           l_freight_cost_temp_charge(n).lane_id             := p_lane_id;   -- Need to insert schedule_id/lane_id
         ELSIF p_lane_id IS NULL THEN
           l_freight_cost_temp_charge(n).schedule_id         := p_schedule_id;
         END IF;

         l_freight_cost_temp_charge(n).applied_to_charge_id  := l_freight_cost_temp_ids(l_freight_cost_temp_charge(n).delivery_detail_id);
         l_freight_cost_temp_charge(n).moved_to_main_flag    := 'N';
         -- added for bug2741467
         l_freight_cost_temp_charge(n).service_type_code     := l_service_type;

         -- pack J enhancement for FPA --
         IF ( l_freight_cost_temp_charge(n).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_temp_charge(n).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_temp_charge(n).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_temp_charge(n).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_temp_charge(n).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_temp_charge(n).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_temp_charge(n).commodity_category_id);
         END IF;


         Create_Freight_Cost_Temp(
            p_freight_cost_temp_info =>  l_freight_cost_temp_charge(n),
            x_freight_cost_temp_id   =>  l_freight_cost_temp_id,
            x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Create_Freight_Cost_Temp Charge');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_fc_temp_failed;
            END IF;
         END IF;

         EXIT WHEN n=l_freight_cost_temp_charge.LAST;
         n := l_freight_cost_temp_charge.NEXT(n);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Temp fc charge record got created');
      END IF;

   ELSIF p_save_flag = 'M' THEN

      l := l_fc_main_update_rows.FIRST;
      IF l IS NOT NULL THEN
      LOOP
         -- For now
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Update row delivery leg id : '||l_fc_main_update_rows(l).delivery_leg_id);

         l_fc_main_update_rows(l).last_update_date := sysdate;
         l_fc_main_update_rows(l).last_updated_by := FND_GLOBAL.USER_ID;
         l_fc_main_update_rows(l).last_update_login := FND_GLOBAL.LOGIN_ID;
      WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
         p_rowid                  =>  l_rowid,
         p_freight_cost_info      =>  l_fc_main_update_rows(l),
         x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Update_Freight_Cost');
                raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
            ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Update_Freight_Cost returned warning ');
            END IF;
         END IF;

         EXIT WHEN l=l_fc_main_update_rows.LAST;
         l := l_fc_main_update_rows.NEXT(l);
      END LOOP;
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Done Update_Freight_Cost ');
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Main fc update record got created');
      END IF;

      m := l_freight_cost_main_price.FIRST;
      IF m IS NOT NULL THEN
      LOOP
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Create base price delivery detail id : '||l_freight_cost_main_price(m).delivery_detail_id);
         l_freight_cost_main_price(m).creation_date := SYSDATE;
         l_freight_cost_main_price(m).created_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_main_price(m).last_update_date    := sysdate;
         l_freight_cost_main_price(m).last_updated_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_main_price(m).last_update_login    := FND_GLOBAL.LOGIN_ID;

         -- pack J enhancement for FPA --
         IF ( l_freight_cost_main_price(m).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_main_price(m).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_main_price(m).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_main_price(m).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_main_price(m).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_main_price(m).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_main_price(m).commodity_category_id);
         END IF;

      WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
         p_freight_cost_info      =>  l_freight_cost_main_price(m),
         x_rowid                  =>  l_rowid,
         x_freight_cost_id        =>  l_freight_cost_id,
         x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Create_Freight_Cost Main Price');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;

         IF l_freight_cost_main_price(m).line_type_code <> 'SUMMARY' THEN
            l_freight_cost_main_ids(l_freight_cost_main_price(m).delivery_detail_id) := l_freight_cost_id;
         END IF;

         EXIT WHEN m=l_freight_cost_main_price.LAST;
         m := l_freight_cost_main_price.NEXT(m);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Main fc base price record got created');
      END IF;

      o := l_freight_cost_main_charge.FIRST;
      IF o IS NOT NULL THEN
      LOOP
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Create charge delivery detail id : '||l_freight_cost_main_charge(o).delivery_detail_id);
         l_freight_cost_main_charge(o).creation_date := SYSDATE;
         l_freight_cost_main_charge(o).created_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_main_charge(o).last_update_date    := sysdate;
         l_freight_cost_main_charge(o).last_updated_by    := FND_GLOBAL.USER_ID;
         l_freight_cost_main_charge(o).last_update_login    := FND_GLOBAL.LOGIN_ID;
         l_freight_cost_main_charge(o).applied_to_charge_id  := l_freight_cost_main_ids(l_freight_cost_main_charge(o).delivery_detail_id); -- For a delivery detail there is only one base price to which any charge gets applied to

         -- pack J enhancement for FPA --
         IF ( l_freight_cost_main_charge(o).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_main_charge(o).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_main_charge(o).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_main_charge(o).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_main_charge(o).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_main_charge(o).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_main_charge(o).commodity_category_id);
         END IF;

      WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
         p_freight_cost_info      =>  l_freight_cost_main_charge(o),
         x_rowid                  =>  l_rowid,
         x_freight_cost_id        =>  l_freight_cost_id,
         x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Create_Freight_Cost Main Charge');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;

         EXIT WHEN o=l_freight_cost_main_charge.LAST;
         o := l_freight_cost_main_charge.NEXT(o);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Main fc charge record got created');
      END IF;

   ELSIF  p_save_flag = 'P' THEN   -- pl/sql table (OM est)

      k := l_freight_cost_temp_price.FIRST;
      IF k is NOT NULL THEN
      LOOP
         -- pack J enhancement for FPA --
         IF ( l_freight_cost_temp_price(k).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_temp_price(k).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_temp_price(k).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_temp_price(k).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_temp_price(k).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_temp_price(k).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_temp_price(k).commodity_category_id);
         END IF;

         EXIT WHEN k=l_freight_cost_temp_price.LAST;
         k := l_freight_cost_temp_price.NEXT(k);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Temp fc base price record got created');
      END IF;

      n := l_freight_cost_temp_charge.FIRST;
      IF n IS NOT NULL THEN
      LOOP
         -- pack J enhancement for FPA --
         IF ( l_freight_cost_temp_charge(n).delivery_detail_id IS NOT NULL
              AND g_rolledup_lines.EXISTS(l_freight_cost_temp_charge(n).delivery_detail_id)
              AND g_rolledup_lines(l_freight_cost_temp_charge(n).delivery_detail_id).category_id
                   <> g_default_category_id )
         THEN
               l_freight_cost_temp_charge(n).commodity_category_id
                 := g_rolledup_lines(l_freight_cost_temp_charge(n).delivery_detail_id).category_id;
               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  'delivery_detail_id='||l_freight_cost_temp_charge(n).delivery_detail_id
                   ||' commodity_category_id ='||l_freight_cost_temp_charge(n).commodity_category_id);
         END IF;

         EXIT WHEN n=l_freight_cost_temp_charge.LAST;
         n := l_freight_cost_temp_charge.NEXT(n);
      END LOOP;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'No Temp fc charge record got created');
      END IF;

   END IF;

   x_freight_cost_temp_price := l_freight_cost_temp_price;
   x_freight_cost_temp_charge := l_freight_cost_temp_charge;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('process_shipment_pattern',FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_MDC_handle_MDC THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_MDC_handle_MDC');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_lanesched_seg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_lane_info THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_lane_info');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_segment_service_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_segment_service_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_currency_code_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_currency_code_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_shipment_pattern_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_shipment_pattern_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_special_conditions_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_special_conditions_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_process_qp_output_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_process_qp_output_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_fc_temp_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_create_fc_temp_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_create_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_pricing',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_pricing');

END shipment_pricing;

--      This procedure looks up the delivery lines in g_shipment_line_rows and
--      creates a table of delivery lines after flattening out the hierarchy to
--      only one level under the delivery

PROCEDURE flatten_shipment (
        p_delivery_leg_id         IN     NUMBER DEFAULT NULL,    --  Not required
        x_first_level_rows        OUT NOCOPY     shpmnt_content_tab_type, -- Will get indexed on delivery_detail_id
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS
   CURSOR c_get_msi_attribs(c_inv_item_id IN NUMBER) IS
   SELECT unit_length,unit_width,unit_height,dimension_uom_code,
          unit_weight,weight_uom_code,unit_volume,volume_uom_code
   FROM   mtl_system_items
   WHERE  inventory_item_id = c_inv_item_id;

 -- Bug 2980373 (Front port from 115.27.1158.2) --
   CURSOR c_get_def_uoms (c_organization_id IN NUMBER) IS
   SELECT uomw.uom_code weight_uom, uomv.uom_code volume_uom
   FROM   mtl_units_of_measure uomw,
          mtl_units_of_measure uomv,
          wsh_shipping_parameters wsp
   WHERE  wsp.weight_uom_class = uomw.uom_class
   AND    wsp.volume_uom_class = uomv.uom_class
   AND    uomw.base_uom_flag='Y'
   AND    uomv.base_uom_flag='Y'
   AND    wsp.organization_id = c_organization_id;

   i                          NUMBER;
   l_msi_attrib_rec           c_get_msi_attribs%rowtype;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'flatten_shipment','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_shipment_line_rows COUNT : '||g_shipment_line_rows.COUNT);

   i := g_shipment_line_rows.FIRST;
   LOOP

      -- Bug 2980373 (front port) --
      -- clear out record before every iteration
      l_msi_attrib_rec.unit_weight := null;
      l_msi_attrib_rec.weight_uom_code := null;
      l_msi_attrib_rec.unit_volume := null;
      l_msi_attrib_rec.volume_uom_code := null;
      l_msi_attrib_rec.dimension_uom_code := null;
      l_msi_attrib_rec.unit_length := null;
      l_msi_attrib_rec.unit_width := null;
      l_msi_attrib_rec.unit_height := null;


      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Delivery leg Id : '||g_shipment_line_rows(i).delivery_leg_id);

      IF (p_delivery_leg_id IS NOT NULL) AND (g_shipment_line_rows(i).delivery_leg_id <> p_delivery_leg_id) THEN
         goto nextpass;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Delivery leg Id : '||g_shipment_line_rows(i).delivery_leg_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Delivery Detail Id : '||g_shipment_line_rows(i).delivery_detail_id);

      -- inventory_item_id can be null on delivery details for various reasons :
      -- 1) FTE J estimate rate
      -- 2) FTE J one-time items (OKE, inbound)
      -- 3) WMS containers (logical groupings) - bug 2980373

      IF g_shipment_line_rows(i).parent_delivery_detail_id IS NULL THEN    -- Top level delivery line
         x_first_level_rows(i).content_id := g_shipment_line_rows(i).delivery_detail_id;
         x_first_level_rows(i).delivery_leg_id := g_shipment_line_rows(i).delivery_leg_id;
         x_first_level_rows(i).container_type_code := g_shipment_line_rows(i).container_type_code;
         x_first_level_rows(i).wdd_weight_uom_code := g_shipment_line_rows(i).weight_uom_code;
         x_first_level_rows(i).wdd_volume_uom_code := g_shipment_line_rows(i).volume_uom_code;
         x_first_level_rows(i).wdd_net_weight 	   := g_shipment_line_rows(i).net_weight;
         x_first_level_rows(i).wdd_gross_weight    := g_shipment_line_rows(i).gross_weight;
         x_first_level_rows(i).wdd_volume 	   := g_shipment_line_rows(i).volume;

	IF g_shipment_line_rows(i).gross_weight is NULL
		or g_shipment_line_rows(i).net_weight is NULL THEN
          x_first_level_rows(i).wdd_tare_weight := 0;
	ELSIF g_shipment_line_rows(i).gross_weight <= g_shipment_line_rows(i).net_weight THEN
          x_first_level_rows(i).wdd_tare_weight := 0;
	ELSE
          x_first_level_rows(i).wdd_tare_weight :=
	    g_shipment_line_rows(i).gross_weight - g_shipment_line_rows(i).net_weight;
	END IF;

        -- branching added to handle null inventory_item_id
         IF (g_shipment_line_rows(i).inventory_item_id IS NOT NULL ) THEN
            OPEN c_get_msi_attribs(g_shipment_line_rows(i).inventory_item_id);
            FETCH c_get_msi_attribs INTO l_msi_attrib_rec;
            CLOSE c_get_msi_attribs;
            IF (l_msi_attrib_rec.unit_weight is null) THEN
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Warning : Item weight is null ');
            END IF;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Inventory_item_id is null');
         END IF;

         -- Following fields are obtained from msi
         x_first_level_rows(i).dim_uom := l_msi_attrib_rec.dimension_uom_code;
         x_first_level_rows(i).length := l_msi_attrib_rec.unit_length;
         x_first_level_rows(i).width := l_msi_attrib_rec.unit_width;
         x_first_level_rows(i).height := l_msi_attrib_rec.unit_height;

         IF g_shipment_line_rows(i).container_flag = 'N' THEN -- Loose item

           x_first_level_rows(i).container_flag := 'N';
           --x_first_level_rows(i).gross_weight := g_shipment_line_rows(i).gross_weight;
           x_first_level_rows(i).gross_weight := nvl(g_shipment_line_rows(i).net_weight,g_shipment_line_rows(i).gross_weight);
           x_first_level_rows(i).weight_uom := g_shipment_line_rows(i).weight_uom_code;
           x_first_level_rows(i).volume := g_shipment_line_rows(i).volume;
           x_first_level_rows(i).volume_uom := g_shipment_line_rows(i).volume_uom_code;

         ELSE  --  Top level container

           x_first_level_rows(i).container_flag := 'Y';
           IF (g_shipment_line_rows(i).inventory_item_id IS NOT NULL ) THEN
             x_first_level_rows(i).gross_weight := l_msi_attrib_rec.unit_weight;  -- Container Item's unit weight
             x_first_level_rows(i).weight_uom := l_msi_attrib_rec.weight_uom_code;
             x_first_level_rows(i).volume := l_msi_attrib_rec.unit_volume;
             x_first_level_rows(i).volume_uom := l_msi_attrib_rec.volume_uom_code;
           ELSE
             -- Bug 2980373 (front port) --
             -- get default uoms for the organization and set weight/volume to 0
             OPEN c_get_def_uoms (g_shipment_line_rows(i).organization_id);
             FETCH c_get_def_uoms INTO l_msi_attrib_rec.weight_uom_code,
                                       l_msi_attrib_rec.volume_uom_code;
             CLOSE c_get_def_uoms;

             IF (l_msi_attrib_rec.weight_uom_code IS NULL
                 OR l_msi_attrib_rec.weight_uom_code IS NULL ) THEN
                 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Warning : Shipping parameters - default weight / volume class missing');
             END IF;
             x_first_level_rows(i).gross_weight := 0;
             x_first_level_rows(i).weight_uom := l_msi_attrib_rec.weight_uom_code;
             x_first_level_rows(i).volume := 0;
             x_first_level_rows(i).volume_uom := l_msi_attrib_rec.volume_uom_code;
           END IF;

         END IF;

      END IF;

      <<nextpass>>

        EXIT WHEN i=g_shipment_line_rows.LAST;
        i := g_shipment_line_rows.NEXT(i);

   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Exit loop ');
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'flatten_shipment');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('flatten_shipment',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'flatten_shipment');
END flatten_shipment;

PROCEDURE get_top_level_charges (
        p_first_level_rows        IN    shpmnt_content_tab_type, -- Will get indexed on delivery_detail_id
        x_shpmnt_toplevel_charges OUT NOCOPY    addl_services_tab_type, -- Top level additional services
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS
   CURSOR c_get_services(c_delivery_detail_id IN NUMBER) IS
   SELECT DISTINCT wfct.freight_cost_type_code,wfct.freight_cost_type_id
   FROM   wsh_freight_cost_types     wfct,
          wsh_freight_costs          wfc
   WHERE  wfc.delivery_detail_id   = c_delivery_detail_id
   AND    wfc.charge_source_code   = 'REQUESTED'
   AND    wfc.freight_cost_type_id = wfct.freight_cost_type_id;

   i                         NUMBER:=0;
   l_service_line_index      NUMBER:=0;
   l_freight_cost_type_id    NUMBER:=0;
   l_freight_cost_type_code  VARCHAR2(200);

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_top_level_charges','start');

   i := p_first_level_rows.FIRST;
   LOOP

      OPEN c_get_services(p_first_level_rows(i).content_id);
      LOOP
         FETCH c_get_services INTO l_freight_cost_type_code,l_freight_cost_type_id;
         EXIT  WHEN c_get_services%NOTFOUND;

         l_service_line_index := l_service_line_index + 1;
         x_shpmnt_toplevel_charges(l_service_line_index).service_line_index := l_service_line_index;
         x_shpmnt_toplevel_charges(l_service_line_index).content_id := p_first_level_rows(i).content_id;
         x_shpmnt_toplevel_charges(l_service_line_index).freight_cost_type_code := l_freight_cost_type_code;
         x_shpmnt_toplevel_charges(l_service_line_index).freight_cost_type_id := l_freight_cost_type_id;

      END LOOP;
      CLOSE c_get_services;

      EXIT WHEN i=p_first_level_rows.LAST;
      i := p_first_level_rows.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_top_level_charges');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_top_level_charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_top_level_charges');
END get_top_level_charges;

-- Public Procedures

FUNCTION is_consolidated (
        p_segment_id              IN     NUMBER ) RETURN BOOLEAN
IS
    -- CURSOR c_get_consolidate_flag IS
    -- SELECT nvl(consolidation_allowed,'N')
    -- FROM   wsh_trips
    -- WHERE  trip_id = p_segment_id;

  CURSOR c_get_lane_function IS
  SELECT nvl(value_from, 'NONE')
  FROM wsh_trips a, fte_prc_parameters b
  WHERE a.trip_id = p_segment_id
  AND   a.lane_id = b.lane_id
  AND   b.parameter_id = 1;

    l_consolidation_allowed    VARCHAR2(1);
    l_lane_function	FTE.FTE_PRC_PARAMETERS.VALUE_FROM%TYPE;
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'is_consolidated','start');

    -- OPEN c_get_consolidate_flag;
    -- FETCH c_get_consolidate_flag INTO l_consolidation_allowed;
    -- CLOSE c_get_consolidate_flag;

    -- IF l_consolidation_allowed = 'Y' THEN
    -- FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'is_consolidated');
    --    RETURN TRUE;
    -- ELSE
    -- FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'is_consolidated');
    --    RETURN FALSE;
    -- END IF;

    -- *** FTE J --
    -- Always return TRUE
    -- original code to look at trips commented out

    -- J+ delivery flat rating

    OPEN c_get_lane_function;
    FETCH c_get_lane_function INTO l_lane_function;
    CLOSE c_get_lane_function;

    IF l_lane_function = 'FLAT' THEN
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'is_consolidated');
      RETURN FALSE;
    ELSE
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'is_consolidated');
      RETURN TRUE;
    END IF;
EXCEPTION
   WHEN others THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('is_consolidated',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'is_consolidated');
END  is_consolidated;

FUNCTION get_segment_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER
IS
    CURSOR c_get_segment IS
    SELECT wt.trip_id
    FROM   wsh_trips wt,
           wsh_delivery_legs  wdl,
           wsh_trip_stops wts1,
           wsh_trip_stops wts2
    WHERE  wts1.stop_id = wdl.pick_up_stop_id
    AND    wts2.stop_id = wdl.drop_off_stop_id
    AND    wts1.trip_id = wt.trip_id
    and    wts2.trip_id = wt.trip_id
    AND    wdl.delivery_leg_id = p_delivery_leg_id;

    l_segment_id    NUMBER;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_segment_from_dleg','start');
    OPEN c_get_segment;
    FETCH c_get_segment INTO l_segment_id;
    CLOSE c_get_segment;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_segment_from_dleg');
    RETURN l_segment_id;

EXCEPTION
   WHEN others THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_segment_from_dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_segment_from_dleg');
END get_segment_from_dleg;

FUNCTION get_delivery_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER
IS
    CURSOR c_get_delivery IS
    SELECT delivery_id
    FROM   wsh_delivery_legs
    WHERE  delivery_leg_id = p_delivery_leg_id;

    l_delivery_id    NUMBER;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_delivery_from_dleg','start');

    OPEN c_get_delivery;
    FETCH c_get_delivery INTO l_delivery_id;
    CLOSE c_get_delivery;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_delivery_from_dleg');
    RETURN l_delivery_id;

EXCEPTION
   WHEN others THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_delivery_from_dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        --FTE_FREIGHT_PRICING_UTIL.print_debug('Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_delivery_from_dleg');
END get_delivery_from_dleg;

FUNCTION get_fc_id_from_dleg (
        p_delivery_leg_id         IN     NUMBER ) RETURN NUMBER
IS

    CURSOR c_get_freight_cost_id IS
    SELECT freight_cost_id
    FROM   wsh_freight_costs
    WHERE  delivery_leg_id = p_delivery_leg_id
    AND delivery_detail_id IS NULL
    AND    line_type_code  = 'SUMMARY';

    l_freight_cost_id    NUMBER;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_fc_id_from_dleg','start');


    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DLEG ID:'||p_delivery_leg_id);

    OPEN c_get_freight_cost_id;
    FETCH c_get_freight_cost_id INTO l_freight_cost_id;
    CLOSE c_get_freight_cost_id;

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FC ID:'||l_freight_cost_id);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_fc_id_from_dleg');
    RETURN l_freight_cost_id;

EXCEPTION
   WHEN others THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_fc_id_from_dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_fc_id_from_dleg');
END get_fc_id_from_dleg;

PROCEDURE delete_invalid_fc_recs (
     p_segment_id      IN  NUMBER DEFAULT NULL,
     p_delivery_leg_id IN  NUMBER DEFAULT NULL,
     x_return_status   OUT NOCOPY  VARCHAR2 )
IS

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;



    CURSOR c_lock_wfc_1(c_segment_id NUMBER)
    IS

	SELECT wfc.freight_cost_id
	FROM wsh_freight_costs wfc,
	     wsh_delivery_legs dl ,
	     wsh_trip_stops s
	WHERE wfc.delivery_leg_id = dl.delivery_leg_id
	      and dl.pick_up_stop_id=s.stop_id
	      and s.trip_id=c_segment_id
	      and wfc.charge_source_code='PRICING_ENGINE'
	FOR UPDATE OF wfc.freight_cost_id NOWAIT;

    CURSOR c_lock_wfc_2(c_delivery_leg_id NUMBER)
    IS
    SELECT wfc.freight_cost_id
    FROM wsh_freight_costs wfc
    WHERE  wfc.delivery_leg_id = c_delivery_leg_id
    AND    charge_source_code = 'PRICING_ENGINE'
    FOR UPDATE NOWAIT;


    l_wfc_detail_ids DBMS_UTILITY.NUMBER_ARRAY;
    l_wfc_dleg_ids DBMS_UTILITY.NUMBER_ARRAY;


BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'delete_invalid_fc_recs','start');

   -- Here determine if a trip has been passed or a delivery leg

   IF p_segment_id IS NULL AND p_delivery_leg_id IS NULL THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_invalid_fc_recs');
      RETURN;

   ELSIF p_delivery_leg_id IS NULL THEN

       OPEN c_lock_wfc_1(p_segment_id);
       FETCH c_lock_wfc_1 BULK COLLECT INTO l_wfc_detail_ids;
       CLOSE c_lock_wfc_1;

	IF (l_wfc_detail_ids.FIRST IS NOT NULL)
	THEN

		FORALL i IN l_wfc_detail_ids.FIRST..l_wfc_detail_ids.LAST
		       DELETE
		       FROM   wsh_freight_costs wfc
		       WHERE  wfc.freight_cost_id = l_wfc_detail_ids(i)
		       AND    (line_type_code <> 'SUMMARY'
			      OR (line_type_code = 'SUMMARY' AND delivery_detail_id IS NOT NULL));

		FORALL i IN l_wfc_detail_ids.FIRST..l_wfc_detail_ids.LAST

		       UPDATE wsh_freight_costs wfc
		       SET  unit_amount=NULL,
			    total_amount=NULL,
			    currency_code=NULL
		       WHERE  wfc.freight_cost_id=l_wfc_detail_ids(i)
		       AND    line_type_code = 'SUMMARY'
		       AND    delivery_detail_id IS NULL;

	END IF;

   ELSIF p_segment_id IS NULL THEN

       OPEN c_lock_wfc_2(p_delivery_leg_id);
       FETCH c_lock_wfc_2 BULK COLLECT INTO l_wfc_dleg_ids;
       CLOSE c_lock_wfc_2;

	IF ( l_wfc_dleg_ids.FIRST IS NOT NULL)
	THEN

		FORALL i IN l_wfc_dleg_ids.FIRST..l_wfc_dleg_ids.LAST
		       DELETE
		       FROM   wsh_freight_costs wfc
		       WHERE  wfc.freight_cost_id=l_wfc_dleg_ids(i)
		       AND    (line_type_code <> 'SUMMARY'
			      OR (line_type_code = 'SUMMARY' AND delivery_detail_id IS NOT NULL));


		FORALL i IN l_wfc_dleg_ids.FIRST..l_wfc_dleg_ids.LAST
		       UPDATE wsh_freight_costs wfc
		       SET  unit_amount=NULL,
			    total_amount=NULL,
			    currency_code=NULL
		       WHERE   wfc.freight_cost_id=l_wfc_dleg_ids(i)
		       AND  line_type_code = 'SUMMARY'
		       AND  delivery_detail_id IS NULL;



	END IF;



   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_invalid_fc_recs');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('delete_invalid_fc_recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_invalid_fc_recs');
END delete_invalid_fc_recs;

PROCEDURE unmark_reprice_required (
     p_segment_id      IN  NUMBER DEFAULT NULL,
     p_delivery_leg_id IN  NUMBER DEFAULT NULL,
     x_return_status   OUT NOCOPY  VARCHAR2 )
IS

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'unmark_reprice_required','start');

   -- Here determine if a trip has been passed or a delivery leg

   IF p_segment_id IS NULL AND p_delivery_leg_id IS NULL THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'unmark_reprice_required');
      RETURN;

   ELSIF p_delivery_leg_id IS NULL THEN

       UPDATE wsh_delivery_legs
       SET    reprice_required = 'N'
       WHERE  delivery_leg_id IN (
              SELECT wdl.delivery_leg_id
              FROM   wsh_delivery_legs wdl,
                     wsh_trips         wt,
                     wsh_trip_stops    wts1,
                     wsh_trip_stops    wts2
              WHERE  wt.trip_id     = wts1.trip_id
              AND    wt.trip_id     = wts2.trip_id
              AND    wts1.stop_id   = wdl.pick_up_stop_id
              AND    wts2.stop_id   = wdl.drop_off_stop_id
              AND    wt.trip_id     = p_segment_id );

   ELSIF p_segment_id IS NULL THEN

       UPDATE wsh_delivery_legs
       SET    reprice_required = 'N'
       WHERE  delivery_leg_id = p_delivery_leg_id;

   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'unmark_reprice_required');

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('unmark_reprice_required',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'unmark_reprice_required');
END unmark_reprice_required;

PROCEDURE shipment_price_consolidate (
        p_delivery_leg_id         IN     NUMBER DEFAULT NULL,    --  Gets either Dleg or wsh trip
        p_segment_id              IN     NUMBER DEFAULT NULL,
        p_check_reprice_flag      IN     VARCHAR2 DEFAULT 'N',
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS

   CURSOR c_delivery_from_trip(c_trip_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          wdl.delivery_leg_id,
          nvl(wdl.reprice_required,'N') as reprice_required,  --  Added AG 05/10
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,             -- arrival_date
          NULL,             -- comm_category_id
	  wda.type,
	  wda.parent_delivery_id,
	  wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda,
	  wsh_new_deliveries wd,
          wsh_delivery_legs wdl, wsh_trip_stops wts1, wsh_trip_stops wts2,wsh_trips wt
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = wdl.delivery_id
   and    wdl.delivery_id 	 = wd.delivery_id
   and    wdl.pick_up_stop_id    = wts1.stop_id
   and    wdl.drop_off_stop_id   = wts2.stop_id
   --and    wdl.reprice_required = 'Y'          -- Not required AG 05/10
   and    wts1.trip_id           = wt.trip_id
   and    wts2.trip_id           = wt.trip_id
   and      (wda.type IS null  OR wda.type <> 'O')--MDC
   and    wt.trip_id             = c_trip_id;

   CURSOR c_delivery_leg(c_delivery_leg_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          wdl.delivery_leg_id,
          nvl(wdl.reprice_required,'N') as reprice_required,  --  Added AG 05/10
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,            -- arrival_date
          NULL,            -- comm_category_id
	  wda.type,
	  wda.parent_delivery_id,
	  wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_delivery_legs wdl,
	  wsh_new_deliveries wd
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = wdl.delivery_id
   and    wdl.delivery_id 	 = wd.delivery_id
   and    ((wdl.reprice_required = 'Y' AND p_check_reprice_flag = 'Y') OR (p_check_reprice_flag = 'N'))
   and      (wda.type IS null  OR wda.type <> 'O')--MDC
   and    wdl.delivery_leg_id    = c_delivery_leg_id;

   CURSOR c_trip_first_stop(c_trip_id NUMBER)
   IS
   SELECT planned_departure_date
   FROM    wsh_trip_stops
   WHERE  trip_id = c_trip_id
   AND	  stop_sequence_number =
   (SELECT min(stop_sequence_number)
    FROM wsh_trip_stops
    WHERE trip_id = c_trip_id);

   CURSOR c_trip_last_stop(c_trip_id NUMBER)
   IS
   SELECT planned_arrival_date
   FROM    wsh_trip_stops
   WHERE  trip_id = c_trip_id
   AND	  stop_sequence_number =
   (SELECT max(stop_sequence_number)
    FROM wsh_trip_stops
    WHERE trip_id = c_trip_id);
--
   l_return_status     VARCHAR2(1);
      l_return_code             NUMBER;
   l_delvy_det_rec     shipment_line_rec_type;
   l_dlvy              WSH_UTIL_CORE.id_tab_type;
   l_first_level_rows  shpmnt_content_tab_type;
   l_first_level_charges  addl_services_tab_type;

   l_dummy_summary     NUMBER;
   l_dummy_summary_uom VARCHAR2(40);
   l_segment_id        NUMBER;
   l_reprice_reqd_count NUMBER:=0;
   l_delivery_id       NUMBER;
   i                   NUMBER;
   j                   NUMBER;
   l_dummy_fc_temp_price     Freight_Cost_Temp_Tab_Type;
   l_dummy_fc_temp_charge     Freight_Cost_Temp_Tab_Type;

      l_initial_pickup_date		DATE;
      l_ultimate_dropoff_date		DATE;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_price_consolidate','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_leg_id='||p_delivery_leg_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_segment_id='||p_segment_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_check_reprice_flag='||p_check_reprice_flag);

   IF p_segment_id IS NULL AND p_delivery_leg_id IS NULL THEN

      raise FTE_FREIGHT_PRICING_UTIL.g_noleg_segment;

   ELSIF p_segment_id IS NOT NULL THEN
      validate_nontl_trip(
	p_trip_id 	=> p_segment_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = G_RC_REPRICE_NOT_REQUIRED
	     OR l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;
   ELSE

    OPEN c_get_delivery_id(p_delivery_leg_id);
    FETCH c_get_delivery_id INTO l_delivery_id;
    CLOSE c_get_delivery_id;

      validate_delivery(
	p_delivery_id 	=> l_delivery_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = G_RC_REPRICE_NOT_REQUIRED
	     OR l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;
   END IF;

   g_shipment_line_rows.DELETE;

   SAVEPOINT before_pricing;

   -- Here determine if a trip has been passed or a delivery leg

   IF p_segment_id IS NOT NULL THEN

    IF p_check_reprice_flag = 'Y' THEN

    OPEN c_count_reprice_reqd(p_segment_id);
    FETCH c_count_reprice_reqd INTO l_reprice_reqd_count;
    CLOSE c_count_reprice_reqd;

    END IF;

    IF (p_check_reprice_flag = 'Y' AND l_reprice_reqd_count > 0) OR
       p_check_reprice_flag = 'N' THEN

      OPEN c_delivery_from_trip(p_segment_id);

      LOOP
         FETCH c_delivery_from_trip INTO l_delvy_det_rec;
         EXIT WHEN c_delivery_from_trip%NOTFOUND;
         g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
      END LOOP;
      IF c_delivery_from_trip%ROWCOUNT = 0 THEN
         CLOSE c_delivery_from_trip;
         --raise FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required;
         raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
         --raise others;  --  Should not happen ie. unexpected error
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matching number of delivery lines : '||c_delivery_from_trip%ROWCOUNT);
      END IF;

      CLOSE c_delivery_from_trip;


      IF is_consolidated(p_segment_id) THEN     --  New API
         -- If atleast one delivery leg for this segment has reprice required flag = 'Y'
         -- then all the delivery legs need to be repriced irrespective of their flags

         -- Need to delete existing freight cost records
         -- for all delivery legs in this trip segment

      delete_invalid_fc_recs (
             p_segment_id      =>  p_segment_id,
             x_return_status   =>  l_return_status ) ;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             ROLLBACK to before_pricing;
             FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:delete_invalid_fc_recs ');
             raise FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed;
         END IF;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,p_segment_id||' : Existing freight cost records deleted ');
      END IF;

         flatten_shipment (
            x_first_level_rows        =>    l_first_level_rows,
            x_return_status           =>    l_return_status );

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:Consolidate=Y:flatten_shipment ');
               ROLLBACK to before_pricing;
               raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
           END IF;
        ELSE -- What happens if no first level rows are created
             -- raise FTE_FREIGHT_PRICING_UTIL.g_an exception
           -- Should never happen AG 05/10
           IF l_first_level_rows.COUNT = 0 THEN
              ROLLBACK to before_pricing;
              raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
           END IF;
           FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'No. of top level lines 2 : '||l_first_level_rows.COUNT);
        END IF;

         -- Scoped out for patch H
         /*
         get_top_level_charges (
            p_first_level_rows        =>    l_first_level_rows,
            x_shpmnt_toplevel_charges =>    l_first_level_charges,
            x_return_status           =>    l_return_status );
         */

      	OPEN c_trip_first_stop(p_segment_id);
      	FETCH c_trip_first_stop INTO l_initial_pickup_date;
      	CLOSE c_trip_first_stop;

      	OPEN c_trip_last_stop(p_segment_id);
      	FETCH c_trip_last_stop INTO l_ultimate_dropoff_date;
      	CLOSE c_trip_last_stop;

         shipment_pricing (
            p_segment_id              =>    p_segment_id,-- Input either Lane or the trip segment
            p_shpmnt_toplevel_rows    =>    l_first_level_rows,
            p_shpmnt_toplevel_charges =>    l_first_level_charges,
	    p_ship_date		      =>    l_initial_pickup_date,
	    p_arrival_date	      =>    l_ultimate_dropoff_date,
            p_save_flag               =>    'M', -- Whether to save to TEMP table or MAIN table
            x_summary_lanesched_price      => l_dummy_summary,
            x_summary_lanesched_price_uom  => l_dummy_summary_uom,
            x_freight_cost_temp_price      => l_dummy_fc_temp_price,
            x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
            x_return_status           =>    l_return_status ) ;

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               ROLLBACK to before_pricing;
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:Consolidate=Y:shipment_pricing ');
               raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed;
           END IF;
        ELSE -- What happens if no first level rows are created
           FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful ');
        END IF;

      -- Here the reprice required flag for all the delivery legs for this segment should be marked as 'N'
      unmark_reprice_required (
             p_segment_id      =>  p_segment_id,
             x_return_status   =>  l_return_status ) ;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             ROLLBACK to before_pricing;
             FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:unmark_reprice_required ');
             raise FTE_FREIGHT_PRICING_UTIL.g_unmark_reprice_req_failed;
         END IF;
      ELSE -- What happens if no first level rows are created
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,p_segment_id||' : reprice required flag unmarked ');
      END IF;

      ELSE  --  Need to call separately for each different delivery leg in the segment
            --  if it's reprice_required flag = 'Y'
         i := g_shipment_line_rows.FIRST;
         LOOP
            IF NOT l_dlvy.EXISTS(g_shipment_line_rows(i).delivery_leg_id) THEN
               -- If the delivery leg has reprice required flag = 'Y'
               --IF g_shipment_line_rows(i).reprice_required = 'Y' THEN

               IF (p_check_reprice_flag = 'Y' AND g_shipment_line_rows(i).reprice_required = 'Y') OR
                  p_check_reprice_flag = 'N' THEN

         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,'Adding delivery leg id :'||g_shipment_line_rows(i).delivery_leg_id||' to l_dlvy');
                  l_dlvy(g_shipment_line_rows(i).delivery_leg_id) := g_shipment_line_rows(i).delivery_leg_id;
               END IF;
            END IF;
            EXIT WHEN i=g_shipment_line_rows.LAST;
            i := g_shipment_line_rows.NEXT(i);

         END LOOP;

         IF l_dlvy.COUNT > 0 THEN
         j := l_dlvy.FIRST;
         LOOP

            l_first_level_rows.delete;
            l_first_level_charges.delete;

            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_dlvy(j)||' : First level lines initialized ');

         -- Need to delete existing freight cost records
         -- for this delivery leg

         delete_invalid_fc_recs (
             p_delivery_leg_id =>  l_dlvy(j),
             x_return_status   =>  l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_pricing;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:N:delete_invalid_fc_recs ');
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed;
            END IF;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_dlvy(j)||' : Existing freight cost records deleted ');
         END IF;

               flatten_shipment (
                  p_delivery_leg_id         =>    l_dlvy(j),
                  x_first_level_rows        =>    l_first_level_rows,
                  x_return_status           =>    l_return_status );

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:Consolidate=N:flatten_shipment ');
                         ROLLBACK to before_pricing;
                         raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
                     END IF;
               ELSE -- What happens if no first level rows are created
                       -- raise FTE_FREIGHT_PRICING_UTIL.g_an exception
                       -- Should not ever happen AG 05/10
                     IF l_first_level_rows.COUNT = 0 THEN
                        ROLLBACK to before_pricing;
                        raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
                     END IF;
                     FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'No. of top level lines 3 : '||l_first_level_rows.COUNT);
               END IF;

               /*
               get_top_level_charges (
                  p_first_level_rows        =>    l_first_level_rows,
                  x_shpmnt_toplevel_charges =>    l_first_level_charges,
                  x_return_status           =>    l_return_status );
               */

               shipment_pricing (
                  p_segment_id              =>    p_segment_id,-- Input either Lane or the trip segment
                  p_shpmnt_toplevel_rows    =>    l_first_level_rows,
                  p_shpmnt_toplevel_charges =>    l_first_level_charges,
                  p_save_flag               =>    'M', -- Whether to save to TEMP table or MAIN table
                  x_summary_lanesched_price      => l_dummy_summary,
                  x_summary_lanesched_price_uom  => l_dummy_summary_uom,
                  x_freight_cost_temp_price      => l_dummy_fc_temp_price,
                  x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
                  x_return_status           =>    l_return_status ) ;

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     ROLLBACK to before_pricing;
                     FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment:Consolidate=N:shipment_pricing ');
                     raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed;
                 END IF;
              ELSE -- What happens if no first level rows are created
                 FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful ');
              END IF;

           -- Here the reprice required flag for this delivery leg should be marked as 'N'
           unmark_reprice_required (
                  p_delivery_leg_id =>  l_dlvy(j),
                  x_return_status   =>  l_return_status ) ;

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  ROLLBACK to before_pricing;
                  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:N:unmark_reprice_required ');
                  raise FTE_FREIGHT_PRICING_UTIL.g_unmark_reprice_req_failed;
              END IF;
           ELSE
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_dlvy(j)||' : reprice required flag unmarked ');
           END IF;

            EXIT WHEN j=l_dlvy.LAST;
            j := l_dlvy.NEXT(j);

         END LOOP;
         ELSE
            -- Even though reprice_required count > 0
            -- No g_shipment_line_rows got created with reprice_required = 'Y'
            -- which can arise out of the concerning delivery leg being empty
            raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
         END IF;

      END IF;

    ELSE
       raise FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required;
    END IF; -- reprice required count > 0

   ELSIF p_delivery_leg_id IS NOT NULL THEN

      l_segment_id := get_segment_from_dleg(p_delivery_leg_id);   --  New API

      IF is_consolidated(l_segment_id) THEN

       IF p_check_reprice_flag = 'Y' THEN

        OPEN c_count_reprice_reqd(l_segment_id);
        FETCH c_count_reprice_reqd INTO l_reprice_reqd_count;
        CLOSE c_count_reprice_reqd;

       END IF;

        IF (p_check_reprice_flag = 'Y' AND l_reprice_reqd_count > 0) OR
           p_check_reprice_flag = 'N' THEN

        --IF l_reprice_reqd_count > 0 THEN

         OPEN c_delivery_from_trip(l_segment_id);

         LOOP
            FETCH c_delivery_from_trip INTO l_delvy_det_rec;
            EXIT WHEN c_delivery_from_trip%NOTFOUND;
            g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
         END LOOP;
         IF c_delivery_from_trip%ROWCOUNT = 0 THEN
            CLOSE c_delivery_from_trip;
            raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
            --raise FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matching number of delivery lines : '||c_delivery_from_trip%ROWCOUNT);
         END IF;

         CLOSE c_delivery_from_trip;

         -- Need to delete existing freight cost records
         -- for all delivery legs in this trip segment

      delete_invalid_fc_recs (
             p_segment_id      =>  l_segment_id,
             x_return_status   =>  l_return_status ) ;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             ROLLBACK to before_pricing;
             FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:Y:delete_invalid_fc_recs ');
             raise FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed;
         END IF;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_segment_id||' : Existing freight cost records deleted ');
      END IF;

         flatten_shipment (
            x_first_level_rows        =>    l_first_level_rows,
            x_return_status           =>    l_return_status );

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:Consolidate=Y:flatten_shipment ');
               ROLLBACK to before_pricing;
               raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
           END IF;
        ELSE -- What happens if no first level rows are created
             -- raise FTE_FREIGHT_PRICING_UTIL.g_an exception
           -- Should never happen AG 5/10
           IF l_first_level_rows.COUNT = 0 THEN
              ROLLBACK to before_pricing;
              raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
           END IF;
           FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'No. of top level lines 4 : '||l_first_level_rows.COUNT);
        END IF;

         /*
         get_top_level_charges (
            p_first_level_rows        =>    l_first_level_rows,
            x_shpmnt_toplevel_charges =>    l_first_level_charges,
            x_return_status           =>    l_return_status );
         */

      	OPEN c_trip_first_stop(l_segment_id);
      	FETCH c_trip_first_stop INTO l_initial_pickup_date;
      	CLOSE c_trip_first_stop;

      	OPEN c_trip_last_stop(l_segment_id);
      	FETCH c_trip_last_stop INTO l_ultimate_dropoff_date;
      	CLOSE c_trip_last_stop;

         shipment_pricing (
            p_segment_id              =>    l_segment_id,-- Input either Lane or the trip segment
            p_shpmnt_toplevel_rows    =>    l_first_level_rows,
            p_shpmnt_toplevel_charges =>    l_first_level_charges,
	    p_ship_date		      =>    l_initial_pickup_date,
	    p_arrival_date	      =>    l_ultimate_dropoff_date,
            p_save_flag               =>    'M', -- Whether to save to TEMP table or MAIN table
            x_summary_lanesched_price      => l_dummy_summary,
            x_summary_lanesched_price_uom  => l_dummy_summary_uom,
            x_freight_cost_temp_price      => l_dummy_fc_temp_price,
            x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
            x_return_status           =>    l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     ROLLBACK to before_pricing;
                     FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:Consolidate=Y:shipment_pricing ');
                     raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed;
              END IF;
         ELSE -- What happens if no first level rows are created
              FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful ');
         END IF;

            -- Here the reprice required flag for all the delivery legs for this segment should be marked as 'N'
         unmark_reprice_required (
                   p_segment_id      =>  l_segment_id,
                   x_return_status   =>  l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   ROLLBACK to before_pricing;
                   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:Y:unmark_reprice_required ');
                   raise FTE_FREIGHT_PRICING_UTIL.g_unmark_reprice_req_failed;
             END IF;
         ELSE -- What happens if no first level rows are created
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,l_segment_id||' : reprice required flag unmarked ');
         END IF;

       ELSE
          raise FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required;
       END IF; -- reprice required count > 0

      ELSE

         OPEN c_delivery_leg(p_delivery_leg_id);

         LOOP
            FETCH c_delivery_leg INTO l_delvy_det_rec;
            EXIT WHEN c_delivery_leg%NOTFOUND;
            g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
         END LOOP;
         IF c_delivery_leg%ROWCOUNT = 0 THEN
            CLOSE c_delivery_leg;
            ROLLBACK to before_pricing;
            raise FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matching number of delivery lines : '||c_delivery_leg%ROWCOUNT);
         END IF;

         CLOSE c_delivery_leg;

         -- Need to delete existing freight cost records
         -- for this delivery leg

         delete_invalid_fc_recs (
             p_delivery_leg_id =>  p_delivery_leg_id,
             x_return_status   =>  l_return_status ) ;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_pricing;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:N:delete_invalid_fc_recs ');
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed;
            END IF;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,p_delivery_leg_id||' : Existing freight cost records deleted ');
         END IF;

         flatten_shipment (
--          p_delivery_leg_id         =>    p_delivery_leg_id,    --  Not required
            x_first_level_rows        =>    l_first_level_rows,
            x_return_status           =>    l_return_status );

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:Consolidate=N:flatten_shipment ');
               ROLLBACK to before_pricing;
               raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
           END IF;
        ELSE -- What happens if no first level rows are created
             -- raise FTE_FREIGHT_PRICING_UTIL.g_an exception
           -- Should never happen AG 5/10
           IF l_first_level_rows.COUNT = 0 THEN
              ROLLBACK to before_pricing;
              raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
           END IF;
           FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'No. of top level lines 5: '||l_first_level_rows.COUNT);
        END IF;

         /*
         get_top_level_charges (
            p_first_level_rows        =>    l_first_level_rows,
            x_shpmnt_toplevel_charges =>    l_first_level_charges,
            x_return_status           =>    l_return_status );
         */

         shipment_pricing (
            p_segment_id              =>    l_segment_id,-- Input either Lane or the trip segment
            p_shpmnt_toplevel_rows    =>    l_first_level_rows,
            p_shpmnt_toplevel_charges =>    l_first_level_charges,
            p_save_flag               =>    'M', -- Whether to save to TEMP table or MAIN table
            x_summary_lanesched_price      => l_dummy_summary,
            x_summary_lanesched_price_uom  => l_dummy_summary_uom,
            x_freight_cost_temp_price      => l_dummy_fc_temp_price,
            x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
            x_return_status           =>    l_return_status ) ;

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    ROLLBACK to before_pricing;
                    FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:Consolidate=N:shipment_pricing ');
                    raise FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed;
                END IF;
             ELSE -- What happens if no first level rows are created
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful ');
             END IF;

           -- Here the reprice required flag for this delivery leg should be marked as 'N'
           unmark_reprice_required (
                  p_delivery_leg_id =>  p_delivery_leg_id,
                  x_return_status   =>  l_return_status ) ;

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  ROLLBACK to before_pricing;
                  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'dleg:consolidate:N:unmark_reprice_required ');
                  raise FTE_FREIGHT_PRICING_UTIL.g_unmark_reprice_req_failed;
              END IF;
           ELSE -- What happens if no first level rows are created
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_INF,p_delivery_leg_id||' : reprice required flag unmarked ');
           END IF;

      END IF;

   END IF;
   --FTE_FREIGHT_PRICING_UTIL.close_logs;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');

EXCEPTION
   WHEN g_finished_warning THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_noleg_segment THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_noleg_segment');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_pricing_not_required THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_pricing_not_required');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_flatten_shipment_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_empty_delivery THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_empty_delivery');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_shipment_pricing_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_unmark_reprice_req_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_unmark_reprice_req_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_delete_invalid_fc_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');
   WHEN others THEN
        ROLLBACK to before_pricing;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_consolidate',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate');

END shipment_price_consolidate;

PROCEDURE shipment_price_consolidate (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
        p_in_attributes           IN     FtePricingInRecType,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_msg_count               OUT NOCOPY     NUMBER,
        x_msg_data                OUT NOCOPY     VARCHAR2 )
IS

        l_return_status    VARCHAR2(1);

    l_trip_id NUMBER;
    l_mode VARCHAR2(30);
    l_output_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN

   FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
                                                x_return_status  => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
   END IF;

    END IF;

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_price_consolidate_standard','start');


	l_trip_id:=NULL;
	l_mode:=NULL;


   	IF(p_in_attributes.segment_id IS NOT NULL)
   	THEN

		Get_Trip_Mode(
			p_trip_id=>p_in_attributes.segment_id,
			p_dleg_id=>NULL,
			x_trip_id=>l_trip_id,
			x_mode_of_transport=>l_mode,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail;
		       END IF;
		END IF;
	ELSIF(p_in_attributes.delivery_leg_id IS NOT NULL)
	THEN

		Get_Trip_Mode(
			p_trip_id=>NULL,
			p_dleg_id=>p_in_attributes.delivery_leg_id,
			x_trip_id=>l_trip_id,
			x_mode_of_transport=>l_mode,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail;
		       END IF;
		END IF;


	END IF;

	IF ((l_mode IS NOT NULL) AND (l_mode='TRUCK'))
	THEN
		FTE_TL_RATING.TL_Rate_Trip (
		   p_trip_id=>l_trip_id ,
		   p_output_type=>'M',
		   p_check_reprice_flag=>'Y',
		   x_output_cost_tab=>l_output_tab,
		   x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail;
		       END IF;
		END IF;



	ELSE



	   shipment_price_consolidate (
		   p_delivery_leg_id         =>     p_in_attributes.delivery_leg_id,
		   p_segment_id              =>     p_in_attributes.segment_id,
		   p_check_reprice_flag      =>     'Y',
		   x_return_status           =>     l_return_status );

	   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful ');
	   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  x_return_status := l_return_status;
	       FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful with warning ');
	   ELSE
		  raise FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed;
	   END IF;
	 END IF;

   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get (
     p_count         =>      x_msg_count,
     p_data          =>      x_msg_data );

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate_standard');
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_consolidate_standard','g_get_trip_mode_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate_standard');
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_consolidate_standard','g_tl_rate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate_standard');
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;


   WHEN FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_consolidate_standard','g_price_consolidate_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate_standard');
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_consolidate_standard','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_consolidate_standard');
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
END shipment_price_consolidate;

PROCEDURE shipment_price_compare (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
        p_delivery_id             IN     NUMBER,
        -- JDBC Thin driver can not support PL/SQL tables having one column (OCI driver supports) types
        -- thats why we are goint with this clumsy way of comma separated list
        p_lane_rows               IN     VARCHAR2 DEFAULT NULL,
        p_schedule_rows           IN     VARCHAR2 DEFAULT NULL,
        p_service_lane            IN     VARCHAR2 DEFAULT NULL,
        p_service_sched           IN     VARCHAR2 DEFAULT NULL,
        p_dep_date                IN     DATE DEFAULT sysdate,
        p_arr_date                IN     DATE DEFAULT sysdate,
        x_summary_lane_price      OUT NOCOPY     VARCHAR2,
        x_summary_lane_price_uom  OUT NOCOPY     VARCHAR2,
        x_summary_sched_price     OUT NOCOPY     VARCHAR2,
        x_summary_sched_price_uom OUT NOCOPY     VARCHAR2,
        x_request_id              OUT NOCOPY     NUMBER,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS


BEGIN

	NULL;

END shipment_price_compare;

PROCEDURE shipment_reprice (
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_fte_trip_id         IN     NUMBER DEFAULT NULL, -- Input only ONE of the following FOUR
        p_segment_id          IN     NUMBER DEFAULT NULL,
        p_delivery_id         IN     NUMBER DEFAULT NULL,
        p_delivery_leg_id     IN     NUMBER DEFAULT NULL )
IS

        l_return_status         VARCHAR2(1);
        l_status                VARCHAR2(10);
        l_temp                  BOOLEAN;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

BEGIN
   FTE_FREIGHT_PRICING_UTIL.initialize_logging(p_debug_mode  => 'CONC',
                                               x_return_status => l_return_status );

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_reprice_conc','start');

   shipment_reprice2 (
        p_fte_trip_id         =>     p_fte_trip_id,
        p_segment_id          =>     p_segment_id,
        p_delivery_id         =>     p_delivery_id,
        p_delivery_leg_id     =>     p_delivery_leg_id,
        x_return_status       =>     l_return_status );

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_status := 'NORMAL';
        errbuf := 'Shipment Reprice is completed successfully';
        retcode := '0';
  ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_status := 'WARNING';
        errbuf := 'Shipment Reprice is completed with warning';
        retcode := '1';
  ELSE
        l_status := 'ERROR';
        errbuf := 'Shipment Reprice is completed with error';
        retcode := '2';
  END IF;

  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_status,'');
  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice_conc');

EXCEPTION
  WHEN OTHERS THEN
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Shipment Reprice is completed with an Unexpected error';
        retcode := '2';
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice_conc');

END shipment_reprice;

PROCEDURE shipment_reprice2 (
        p_init_prc_log	      IN     VARCHAR2 DEFAULT 'Y',
        p_fte_trip_id         IN     NUMBER DEFAULT NULL,
        p_segment_id          IN     NUMBER DEFAULT NULL,
        p_delivery_id         IN     NUMBER DEFAULT NULL,
        p_delivery_leg_id     IN     NUMBER DEFAULT NULL,
        x_return_status       OUT NOCOPY     VARCHAR2 )
IS
        l_segment_id       NUMBER;
        l_delivery_leg_id  NUMBER;
        l_return_status    VARCHAR2(1);
/*
 CURSOR c_segment_from_fte_trip IS
 SELECT fwt.wsh_trip_id
 FROM   fte_trips ft, fte_wsh_trips fwt
 WHERE  ft.fte_trip_id = fwt.fte_trip_id
 AND    ft.fte_trip_id = p_fte_trip_id;
*/
 CURSOR c_delivery_leg_from_dlvy IS
 SELECT delivery_leg_id
 FROM   wsh_delivery_legs
 WHERE  delivery_id = p_delivery_id;


 l_output_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
 l_mode VARCHAR2(30);
 l_trip_id NUMBER;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_init_prc_log = 'Y' THEN
   FTE_FREIGHT_PRICING_UTIL.initialize_logging(x_return_status => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
   END IF;
  END IF;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_reprice2','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Input : FTE Trip Id - '||p_fte_trip_id||' Trip Segment Id -'||p_segment_id||' Delivery Id - '||p_delivery_id||' Delivery Leg Id - '||p_delivery_leg_id);

   IF p_fte_trip_id IS NULL AND p_segment_id IS NULL AND p_delivery_id IS NULL AND p_delivery_leg_id IS NULL
   THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_no_input;
   ELSIF p_segment_id IS NOT NULL THEN

	Get_Trip_Mode(
		p_trip_id=>p_segment_id,
		p_dleg_id=>NULL,
		x_trip_id=>l_trip_id,
		x_mode_of_transport=>l_mode,
		x_return_status=>l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
        THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
               THEN
              raise FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail;
               END IF;
        END IF;

	IF ((l_mode IS NOT NULL) AND (l_mode='TRUCK'))
	THEN
		FTE_TL_RATING.TL_Rate_Trip (
		   p_trip_id=>p_segment_id ,
		   p_output_type=>'M',
		   p_check_reprice_flag=>'N',
		   x_output_cost_tab=>l_output_tab,
		   x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail;
		       END IF;
		END IF;



	ELSE

	      	shipment_price_consolidate (
			p_segment_id              =>     p_segment_id,
			x_return_status           =>     l_return_status );

		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful for segment : '||p_segment_id);
		ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  x_return_status := l_return_status;
		   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful with warning for segment : '||p_segment_id);
		ELSE
		       FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'segment: '||p_segment_id||' shipment_price_consolidate ');
		       raise FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed;
		END IF;


	END IF;



   ELSIF p_delivery_id IS NOT NULL THEN
   --  Need to call for all delivery legs belonging to this delivery

      OPEN c_delivery_leg_from_dlvy;
      LOOP
         FETCH c_delivery_leg_from_dlvy INTO l_delivery_leg_id;
         EXIT WHEN c_delivery_leg_from_dlvy%NOTFOUND;



	Get_Trip_Mode(
		p_trip_id=>NULL,
		p_dleg_id=>l_delivery_leg_id,
		x_trip_id=>l_trip_id,
		x_mode_of_transport=>l_mode,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail;
	       END IF;
	END IF;

	IF ((l_mode IS NOT NULL) AND (l_mode='TRUCK'))
	THEN
		FTE_TL_RATING.TL_Rate_Trip (
		   p_trip_id=>l_trip_id ,
		   p_output_type=>'M',
		   p_check_reprice_flag=>'N',
		   x_output_cost_tab=>l_output_tab,
		   x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail;
		       END IF;
		END IF;



	ELSE


		 shipment_price_consolidate (
		   p_delivery_leg_id         =>     l_delivery_leg_id,
		   x_return_status           =>     l_return_status );

		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful for delivery leg : '||l_delivery_leg_id);
		ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  x_return_status := l_return_status;
		   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful for segment : '||p_segment_id);
		ELSE
		       FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Delivery leg: '||l_delivery_leg_id||' shipment_price_consolidate ');
		       raise FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed;
		END IF;
	END IF;

      END LOOP;
      CLOSE c_delivery_leg_from_dlvy;

   ELSIF p_delivery_leg_id IS NOT NULL THEN

	Get_Trip_Mode(
		p_trip_id=>NULL,
		p_dleg_id=>p_delivery_leg_id,
		x_trip_id=>l_trip_id,
		x_mode_of_transport=>l_mode,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail;
	       END IF;
	END IF;

	IF ((l_mode IS NOT NULL) AND (l_mode='TRUCK'))
	THEN
		FTE_TL_RATING.TL_Rate_Trip (
		   p_trip_id=>l_trip_id ,
		   p_output_type=>'M',
		   p_check_reprice_flag=>'N',
		   x_output_cost_tab=>l_output_tab,
		   x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail;
		       END IF;
		END IF;


    ELSE

	      shipment_price_consolidate (
		p_delivery_leg_id         =>     p_delivery_leg_id,
		x_return_status           =>     l_return_status );

		IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment price consolidate successful for delivery leg : '||p_delivery_leg_id);
		ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  x_return_status := l_return_status;
		ELSE
		       FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'delivery leg: '||p_delivery_leg_id||' shipment_price_consolidate ');
		       raise FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed;
		END IF;
	END IF;

   END IF;
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
   FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_input THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_input');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

   WHEN FTE_FREIGHT_PRICING_UTIL.g_get_trip_mode_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_get_trip_mode_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;


   WHEN FTE_FREIGHT_PRICING_UTIL.g_price_consolidate_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_price_consolidate_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
  IF p_init_prc_log = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;
END shipment_reprice2;


--PROCEDURE validate_rerate_delivery(p_delv_list IN FTE_ID_TAB_TYPE,

-- Added for R12 to get Delivery Legs for all the deliveries.
-- This is added to allow multi leg rating in case of rerating.
-- In addition to this , this delivery needs to find out all the
-- delivery legs for it's child deliveries in case it's console delivery.

PROCEDURE  get_delivery_legs(
            p_deliveries_list IN  FTE_ID_TAB_TYPE,
            x_delivery_legs   OUT NOCOPY DELIVERY_LEG_TAB_TYPE,
            x_return_status   OUT NOCOPY  VARCHAR2)
IS

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_delvy_tab     DELIVERY_LEG_TAB_TYPE;
    l_delv_leg_rec  delivery_leg_rec_type;
    i               NUMBER := 0;
    l_index         NUMBER := 0;

    CURSOR c_get_delivery_legs_detail(c_delivery_id IN NUMBER) IS
    SELECT wdl.delivery_id,delivery_leg_id,wnd.name
    FROM   wsh_delivery_legs wdl, wsh_new_deliveries wnd
    WHERE  wdl.delivery_id= c_delivery_id
    AND    wnd.delivery_id = wdl.delivery_id;

BEGIN

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'get_delivery_legs','start');

  FOR i in p_deliveries_list.FIRST..p_deliveries_list.LAST LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through Delivery ids in get_delivery_legs... ');
    OPEN c_get_delivery_legs_detail(p_deliveries_list(i));
    LOOP
        FETCH c_get_delivery_legs_detail INTO l_delv_leg_rec;
        EXIT WHEN c_get_delivery_legs_detail%NOTFOUND;
        l_index := l_index +1;
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_delv_leg_rec.delivery_leg_id. ' ||l_delv_leg_rec.delivery_leg_id );
        --l_delvy_tab(l_delv_leg_rec.delivery_leg_id) := l_delv_leg_rec;
        l_delvy_tab(l_index) := l_delv_leg_rec;
    END LOOP;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Total Leg Count for Delivery. ' || p_deliveries_list(i) || ' is '|| l_delvy_tab.COUNT );
    CLOSE c_get_delivery_legs_detail ;
  END LOOP;

  FOR i IN l_delvy_tab.FIRST..l_delvy_tab.LAST LOOP
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Leg  is='|| l_delvy_tab(i).delivery_leg_id);
  END LOOP;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Out of loop for Delivery ids in get_delivery_legs... ');

  x_delivery_legs := l_delvy_tab;

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_delivery_legs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_delivery_legs');
END get_delivery_legs;

-- Internal procedure to get distinct trip_ids for a given
-- delivery legs table.
-- Added for R12. Used in rerate_shipment_online.

PROCEDURE get_distinct_trip_ids( p_dleg_list IN FTE_ID_TAB_TYPE,
                                 x_trip_ids  OUT NOCOPY DELIVERY_TRIP_TAB_TYPE,
                                 x_all_trips OUT NOCOPY DELIVERY_TRIP_TAB_TYPE,
                                 x_return_status OUT NOCOPY VARCHAR2)

IS

    CURSOR c_get_distinct_trip_ids(c_dleg_id IN VARCHAR2) IS
    SELECT DISTINCT  wdl.delivery_id,wts1.trip_id ,wdl.delivery_leg_id,wnd.name
    FROM  wsh_delivery_legs wdl ,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2,
          wsh_trips      wt,
          wsh_new_deliveries wnd
    WHERE wdl.pick_up_stop_id  = wts1.stop_id
    AND   wdl.drop_off_stop_id = wts2.stop_id
    AND   wdl.delivery_leg_id  = c_dleg_id
    AND   wt.trip_id           = wts1.trip_id
    AND   wnd.delivery_id      = wdl.delivery_id;

    i               NUMBER := 0;
    l_dleg_ids      VARCHAR2(32767);
    l_trip_ids      VARCHAR2(32767);
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_api_name      CONSTANT VARCHAR2(30)   := 'get_distinct_trip_ids';
    l_trip_id       NUMBER;
    l_is_first      BOOLEAN := TRUE ;
    --l_del_trip_tab  DELIVERY_TRIP_TAB_TYPE;
    l_del_trip_rec  DELIVERY_TRIP_REC_TYPE;
    j               NUMBER  := 0;
    trip_exists     BOOLEAN := FALSE;
    l_trip_index    NUMBER  := 0;

BEGIN

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);
    --x_trip_ids := FTE_ID_TAB_TYPE();

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,p_dleg_list.COUNT);

    FOR i IN p_dleg_list.FIRST..p_dleg_list.COUNT LOOP
        OPEN c_get_distinct_trip_ids(p_dleg_list(i));
        FETCH c_get_distinct_trip_ids INTO l_del_trip_rec;
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'After Fetch');
        -- Only store unique trips in trips table.
        IF x_trip_ids.COUNT > 0 THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_trip_ids.COUNT > 0');
            FOR j IN x_trip_ids.FIRST..x_trip_ids.COUNT LOOP
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_trip_ids(j).trip_id = ' || x_trip_ids(j).trip_id);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_del_trip_rec.trip_id = ' || l_del_trip_rec.trip_id);
                IF x_trip_ids(j).trip_id  = l_del_trip_rec.trip_id THEN
                    trip_exists := true;
                    EXIT WHEN trip_exists;
                    -- break the loop
                ELSE
                    trip_exists := false;
                END IF;
            END LOOP;
        END IF;
FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'After Unique trip loop ');
--FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_exists = ' || to_char(trip_exists));

         IF NOT trip_exists then
            l_trip_index := l_trip_index +1;
            x_trip_ids(l_trip_index) := l_del_trip_rec;
         END IF;

         x_all_trips(i) := l_del_trip_rec;

        CLOSE c_get_distinct_trip_ids;
    END LOOP;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip Ids Count=' || x_trip_ids.COUNT);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_distinct_trip_ids');


EXCEPTION
  WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('get_distinct_trip_ids',FTE_FREIGHT_PRICING_UTIL.G_ERR,'get distinct trips failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'get_distinct_trip_ids');
END get_distinct_trip_ids;

 --This API is written for R12. It does the following validation
 -- 1) Delivery type is Outbound/Internal Orders and status is Open
 -- 2) Or Delivery type is Inbound/Drop Ship
 -- If a delivery  doesnt meet this criteria, it;s removed from the deliveries list
 -- which need rerating
 -- For Deliveries which fail validation a new message is written in log file.

PROCEDURE    validate_delv_for_rerating
                    ( p_deliveries_list IN FTE_ID_TAB_TYPE,
                      x_deliveries_list OUT NOCOPY FTE_ID_TAB_TYPE
                     )

IS

    l_new_delv_list         FTE_ID_TAB_TYPE;
    l_api_name              CONSTANT VARCHAR2(30)   := 'validate_delv_for_rerating';
    l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    i                       NUMBER := 0;
    l_var                   VARCHAR2(1);

    CURSOR check_delivery_type (c_delivery_id IN NUMBER)
    IS
    SELECT 'X' FROM WSH_NEW_DELIVERIES
    WHERE ( shipment_direction IN ('O','IO') AND status_code = 'OP')
    OR    (  shipment_direction IN ('D','I') )
    AND delivery_id = c_delivery_id ;

BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);
    l_new_delv_list := FTE_ID_TAB_TYPE();

   FOR i IN p_deliveries_list.FIRST..p_deliveries_list.LAST
   LOOP
       OPEN check_delivery_type(p_deliveries_list(i));
       FETCH check_delivery_type INTO l_var;
       IF check_delivery_type%NOTFOUND THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Delv='|| p_deliveries_list(i) || ' doesnt meet criteria of direction 0/IO with Status OP OR Direction D/I');
        ELSE
            l_new_delv_list.EXTEND;
            l_new_delv_list(i) := p_deliveries_list(i);
        END IF;
        CLOSE check_delivery_type;
   END LOOP;

   x_deliveries_list := l_new_delv_list;

EXCEPTION

    WHEN OTHERS THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception('validate_delv_for_rerating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'validate_delv_for_rerating failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'validate_delv_for_rerating');

END validate_delv_for_rerating;

--This API is written for R12. It does the following validation
-- 1) Delivery leg has a rate
-- If a delivery leg doesnt have existing rates, it removes it from
-- the list of dlegs which need to be rerated.
-- For Dlegs which fail validation a new message is written in log file.
PROCEDURE     validate_delivery_legs(p_dlegs_list IN FTE_ID_TAB_TYPE,
                                     x_dleg_list  OUT NOCOPY FTE_ID_TAB_TYPE,
                                     x_failed_dleg_list OUT NOCOPY FTE_ID_TAB_TYPE,
                                     x_return_status OUT NOCOPY VARCHAR2
                                     )

IS
    l_new_dleg_list         FTE_ID_TAB_TYPE;
    l_failed_dleg_list      FTE_ID_TAB_TYPE;
    l_api_name              CONSTANT VARCHAR2(30)   := 'validate_delivery_legs';
    l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    i                       NUMBER := 0;
    l_var                   NUMBER;--VARCHAR2(1);
    dleg_rates_not_found    EXCEPTION;


    CURSOR check_freight_cost_exist (c_delivery_leg_id IN NUMBER)
    IS
    SELECT total_amount FROM wsh_freight_costs
    WHERE line_type_code='SUMMARY'
    AND delivery_detail_id is null
    AND freight_cost_type_id is not null
    AND delivery_leg_id= c_delivery_leg_id;

BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);
    l_new_dleg_list := FTE_ID_TAB_TYPE();
    l_failed_dleg_list := FTE_ID_TAB_TYPE();

   FOR i IN p_dlegs_list.FIRST..p_dlegs_list.LAST
   LOOP
       OPEN check_freight_cost_exist(p_dlegs_list(i));
       FETCH check_freight_cost_exist INTO l_var;
       IF check_freight_cost_exist%NOTFOUND THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' No existing rates found for dleg='|| p_dlegs_list(i) || ' Required for rerating ');
            l_failed_dleg_list.EXTEND;
            l_failed_dleg_list(l_failed_dleg_list.LAST) := p_dlegs_list(i);
        ELSIF  l_var IS NULL THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Total amt. Null for dleg='|| p_dlegs_list(i) || ' Required for rerating ');
            l_failed_dleg_list.EXTEND;
            l_failed_dleg_list(l_failed_dleg_list.LAST) := p_dlegs_list(i);
        ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Existing rates found for dleg='|| p_dlegs_list(i) || ' Required for rerating ');
            l_new_dleg_list.EXTEND;
            l_new_dleg_list(l_new_dleg_list.LAST) := p_dlegs_list(i);
        END IF;
        CLOSE check_freight_cost_exist;
   END LOOP;

   x_dleg_list := l_new_dleg_list;
   x_failed_dleg_list := l_failed_dleg_list;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'validate_delivery_legs');


EXCEPTION

    --WHEN dleg_rates_not_found THEN
      --  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
      --  FTE_FREIGHT_PRICING_UTIL.set_exception('validate_delivery_legs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'dleg_rates_not_found');
      --  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'validate_delivery_legs');
    WHEN OTHERS THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception('validate_delivery_legs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'validate_delivery_legs failed');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'validate_delivery_legs');
END validate_delivery_legs;


PROCEDURE    validate_trips(p_trip_id_list IN WSH_UTIL_CORE.id_tab_type,
                            x_failed_trips_list OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
                            x_success_trips_list OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
                            x_closed_trips_list  OUT NOCOPY WSH_UTIL_CORE.id_tab_type)

IS

   CURSOR c_trip_info(c_trip_id NUMBER)
   IS
   SELECT wt.trip_id,
      wt.name,
      wt.planned_flag,
      wt.status_code,
      wt.carrier_id,
      wt.ship_method_code,
      wt.service_level,
      wt.mode_of_transport,
      wt.consolidation_allowed,
      wt.lane_id,
      wt.schedule_id,
      wt.load_tender_status
   FROM   wsh_trips wt
   WHERE  wt.trip_id = c_trip_id;

   CURSOR c_get_trip_direction(c_trip_id NUMBER)
   IS
   SELECT shipments_type_flag
   FROM   wsh_trips
   WHERE  trip_id = c_trip_id;

   l_trip_info trip_info_rec;
   i                NUMBER;
   l_fail_index     NUMBER := 0;
   l_success_index  NUMBER := 0;
   l_closed_index   NUMBER := 0;
   l_api_name       CONSTANT VARCHAR2(30)   := 'validate_trips';
   l_log_level      NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
   l_trip_direction VARCHAR2(30);
   l_valid_trip     VARCHAR2(1) := 'Y';

BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

    FOR i IN p_trip_id_list.FIRST..p_trip_id_list.LAST
    LOOP
        OPEN c_trip_info(p_trip_id_list(i));
        FETCH c_trip_info INTO l_trip_info;
        CLOSE c_trip_info;

       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Trip Id is ='|| p_trip_id_list(i));
       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip status  is ='|| l_trip_info.status_code);

        -- In CASE OF closed trips, only allow re-rating of
        -- Inbound or Mixed trips. Do not allow rerating of
        -- closed outbound trips.
        IF l_trip_info.status_code = 'CL' THEN
            OPEN c_get_trip_direction(p_trip_id_list(i));
            FETCH c_get_trip_direction INTO l_trip_direction;
            CLOSE c_get_trip_direction;
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_trip_direction ='|| l_trip_direction);
            IF (l_trip_direction = 'O' ) OR (l_trip_direction IS NULL) THEN
                l_valid_trip := 'N';
            ELSE
                l_valid_trip := 'Y';
            END IF;
        END IF;

        IF l_valid_trip = 'Y' THEN

            IF l_trip_info.carrier_id is null OR l_trip_info.mode_of_transport is null
             OR l_trip_info.service_level is null  THEN
                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'should have full ship method to rerate a trip !!! Trip Id ='|| p_trip_id_list(i));
                 l_fail_index := l_fail_index + 1;
                 x_failed_trips_list(l_fail_index) := p_trip_id_list(i);
             ELSE
                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip has full ship method  !!! Trip Id ='|| p_trip_id_list(i));
                 l_success_index := l_success_index + 1;
                 x_success_trips_list(l_success_index) := p_trip_id_list(i);
             END IF;
        ELSE
             FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip Direction/Status combination is not elegible for rarating ');
             l_closed_index := l_closed_index + 1;
             x_closed_trips_list(l_closed_index) := p_trip_id_list(i);
        END IF;
    END LOOP;

   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Failed Trips = '|| x_failed_trips_list.COUNT);
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Success Trips = '|| x_success_trips_list.COUNT);

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION

    WHEN OTHERS THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'validate_trips failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

END validate_trips;
-- This API is called directly from DWB
-- Modified the signature for 12i. p_delivery_leg_list can contain list of Delivery Ids or Delivery Legs
-- Based on p_deliveries_list_type , it'll call different rating modules.
-- In R12 behavior of rerating will change as in case of a delivery/dleg , with more
-- delivery legs on the same trip we'll call rerating of the complete trip.
-- So in case of rerating Trip level rating will be called always instead of individual delivery leg

PROCEDURE rerate_shipment_online(
            p_api_version		IN  NUMBER DEFAULT 1.0,
            p_init_msg_list		IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
            p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
            p_deliveries_list    IN  FTE_ID_TAB_TYPE,
            p_delivery_name_list	IN  FTE_NAME_TAB_TYPE,
            p_deliveries_list_type IN VARCHAR2 ,  -- This will have 'DEL' for Delivery IDs or 'DLEG' for Delivery Leg Ids.
            x_success_list		OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_warning_list		OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_fail_list		OUT NOCOPY  FTE_ID_TAB_TYPE,
            x_return_status         OUT NOCOPY  VARCHAR2,
            x_msg_count	        OUT NOCOPY  NUMBER,
            x_msg_data        OUT NOCOPY  VARCHAR2)
IS
  l_dleg_list_empty     EXCEPTION;
  l_del_name_mismatch   EXCEPTION;
  l_delv_list_empty     EXCEPTION;
  l_trip_rating_failed  EXCEPTION;
  l_dleg_validation_failed EXCEPTION;
  l_delivery_validation_failed EXCEPTION;

  l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30)   := 'rerate_shipment_online';
  --l_return_status         VARCHAR2(1);
  l_msg_count               NUMBER := 0;
  l_msg_data                VARCHAR2(32767);
  l_fail_delivery_name_list VARCHAR2(32767);
  l_warn_delivery_name_list VARCHAR2(32767);
  i                         NUMBER;
  l_failed_leg_list         FTE_ID_TAB_TYPE;
  l_success_leg_list        FTE_ID_TAB_TYPE;
  l_warning_leg_list        FTE_ID_TAB_TYPE;
  l_dleg_list               FTE_ID_TAB_TYPE;
  --l_trip_ids              FTE_ID_TAB_TYPE;
  l_new_deliveries_list     FTE_ID_TAB_TYPE;
  l_new_dleg_list           FTE_ID_TAB_TYPE;
  l_delv_legs               DELIVERY_LEG_TAB_TYPE;
  l_index                   NUMBER := 0;
  l_trip_id                 NUMBER;
  l_failed_list             FTE_ID_TAB_TYPE;
  l_success_list            FTE_ID_TAB_TYPE;
  l_warning_list            FTE_ID_TAB_TYPE;
  l_trip_ids                DELIVERY_TRIP_TAB_TYPE;
  j                         NUMBER;
  l_all_trips               DELIVERY_TRIP_TAB_TYPE;
  j1                        NUMBER;
  l_service_failed          VARCHAR2(1) ;
  l_service_failed_delv_ids VARCHAR2(32767);
  l_closed_trips_delv_ids   VARCHAR2(32767);
  l_fail_val_dleg_list      FTE_ID_TAB_TYPE;
  l_action_params           FTE_TRIP_RATING_GRP.action_param_rec;
  l_trip_id_list            WSH_UTIL_CORE.id_tab_type;
  l_failed_trips            WSH_UTIL_CORE.id_tab_type;
  l_success_trips           WSH_UTIL_CORE.id_tab_type;
  l_temp_trips_tab          WSH_UTIL_CORE.id_tab_type;
  l_closed_trips            WSH_UTIL_CORE.id_tab_type;
  l_number_of_warnings      NUMBER;
  l_number_of_errors        NUMBER;
  l_return_status           VARCHAR2(32767);
  l_no_rates_delv_ids       VARCHAR2(32767);
  l_status                  VARCHAR2(30);
  l_message		    VARCHAR2(32767);
  l_delv_with_multlegs_names    VARCHAR2(32767);
  l_delv_srv_failed_names       VARCHAR2(32767);
  l_close_trdelv_name_list VARCHAR2(32767);

  CURSOR c_get_status_meaning
  IS
  SELECT meaning
  FROM   wsh_lookups
  WHERE  lookup_code = 'CL'
  AND    lookup_type = 'TRIP_STATUS';




BEGIN
    SAVEPOINT  rerate_shipment_online;
--
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
    THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
     THEN
        FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FTE_FREIGHT_PRICING_UTIL.initialize_logging(x_return_status => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Initialize Logging successful ');
   END IF;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_api_version='||p_api_version);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_init_msg_list='||p_init_msg_list);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_deliveries_list_type='||p_deliveries_list_type);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_deliveries_name_list.count='||p_delivery_name_list.count);


  IF p_deliveries_list.COUNT <= 0 THEN
    IF p_deliveries_list_type = 'DEL' THEN
        raise l_delv_list_empty;
    ELSE
        raise l_dleg_list_empty;
    END IF;
  END IF;


  IF p_deliveries_list.COUNT <> p_delivery_name_list.COUNT THEN
    raise l_del_name_mismatch;
  END IF;

  -- If deliveries are passed for re-rating.
  -- get all the delivery legs for those deliveries. Done for R12

    l_dleg_list := FTE_ID_TAB_TYPE();
    l_failed_list := FTE_ID_TAB_TYPE();
    l_success_list := FTE_ID_TAB_TYPE();
    l_warning_list := FTE_ID_TAB_TYPE();


    IF  p_deliveries_list_type = 'DEL' THEN

        validate_delv_for_rerating( p_deliveries_list => p_deliveries_list,
                                    x_deliveries_list => l_new_deliveries_list
                                  );
        get_delivery_legs( p_deliveries_list    => l_new_deliveries_list,
                           x_delivery_legs      => l_delv_legs,
                           x_return_status      => x_return_status);

        FOR l_index IN p_deliveries_list.FIRST..p_deliveries_list.LAST LOOP
           IF ( hasMultipleLegs(p_deliveries_list(l_index)) = 'Y') THEN
               IF l_delv_with_multlegs_names IS NOT NULL THEN
                    l_delv_with_multlegs_names := l_delv_with_multlegs_names ||' '|| p_delivery_name_list(l_index);
               ELSE
                    l_delv_with_multlegs_names := p_delivery_name_list(l_index);
               END IF;
               l_warning_list.EXTEND;
               l_warning_list(l_warning_list.LAST) := p_deliveries_list(l_index);
           END IF;
        END LOOP;
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_delv_legs.count=' || l_delv_legs.count);
        l_index := 0;
        FOR l_index IN l_delv_legs.FIRST..l_delv_legs.LAST LOOP
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_index=' || l_index);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_delv_legs(l_index).delivery_leg_id' || l_delv_legs(l_index).delivery_leg_id);
            l_dleg_list.EXTEND;
            l_dleg_list(l_dleg_list.LAST) := l_delv_legs(l_index).delivery_leg_id;
        END LOOP;
    ELSE
        For l_index IN p_deliveries_list.FIRST..p_deliveries_list.LAST
        LOOP
           l_dleg_list.EXTEND;
           l_dleg_list(l_dleg_list.LAST) := p_deliveries_list(l_index);
        END LOOP;
    END IF;


    validate_delivery_legs(p_dlegs_list => l_dleg_list,
                           x_dleg_list  => l_new_dleg_list,
                           x_failed_dleg_list => l_fail_val_dleg_list,
                           x_return_status => x_return_status
                          );

    -- Get distinct trips from these delivery legs so that
    -- rating is not performed for same trips multiple times
    -- Add validation failed delivery legs also to failed list
    -- And raise Exception
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' No rates failed list::= '||l_fail_val_dleg_list.COUNT);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Total Delivery Legs list l_delv_legs::= '||l_delv_legs.COUNT);

    l_index := 0;

    IF  l_fail_val_dleg_list.COUNT > 0 THEN
        FOR j1 IN l_fail_val_dleg_list.FIRST..l_fail_val_dleg_list.LAST LOOP
            IF p_deliveries_list_type = 'DEL' THEN
                FOR l_index IN l_delv_legs.FIRST..l_delv_legs.LAST LOOP
                    IF l_delv_legs(l_index).delivery_leg_id = l_fail_val_dleg_list(j1) THEN
                          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Failed Delivery Name :='||l_delv_legs(l_index).delivery_name);
                          IF l_fail_delivery_name_list IS NOT NULL THEN
                             l_fail_delivery_name_list := l_delv_legs(l_index).delivery_name;
                          ELSE
                             l_fail_delivery_name_list := l_fail_delivery_name_list ||' '||l_delv_legs(l_index).delivery_name;
                          END IF;
                    END IF;
                END LOOP;
            ELSE
                FOR l_index IN l_dleg_list.FIRST..l_dleg_list.LAST LOOP
                    IF l_dleg_list(l_index) = l_fail_val_dleg_list(j1) THEN
                          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Failed Delivery Name :='||p_delivery_name_list(l_index));
                          IF l_fail_delivery_name_list IS NOT NULL THEN
                             l_fail_delivery_name_list := p_delivery_name_list(l_index);
                          ELSE
                             l_fail_delivery_name_list := l_fail_delivery_name_list ||' '||p_delivery_name_list(l_index);
                          END IF;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' No rates failed list::= '||l_no_rates_delv_ids);
        FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_NORATES');
        FND_MESSAGE.SET_TOKEN('DEL_NAMES',l_fail_delivery_name_list);
        --FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
        FND_MSG_PUB.ADD;
        raise l_delivery_validation_failed;
    END IF;



    IF (l_new_dleg_list IS NOT NULL ) OR (l_new_dleg_list.COUNT > 0 )
    THEN
        get_distinct_trip_ids( p_dleg_list => l_new_dleg_list,
                               x_trip_ids => l_trip_ids ,
                               x_all_trips => l_all_trips,
                               x_return_status => x_return_status) ;
        l_index := 0;
        -- Call Trip rating for all the trips.
        j := 1;
        FOR l_index IN l_trip_ids.FIRST..l_trip_ids.LAST LOOP
            l_trip_id_list (j) := l_trip_ids(l_index).trip_id;
            j := j+1;
        END LOOP;
        validate_trips(p_trip_id_list => l_trip_id_list,
                       x_failed_trips_list => l_failed_trips,
                       x_success_trips_list => l_success_trips,
                       x_closed_trips_list => l_closed_trips);
        -- For trips which failed to validate for full ship_method
        -- Get the deliveries/Dlegs and add them to failed list.
        j := 0;
        IF l_failed_trips.COUNT > 0 THEN
            FOR j IN l_failed_trips.FIRST..l_failed_trips.LAST LOOP
                FOR j1 IN l_failed_trips.FIRST..l_failed_trips.LAST LOOP
                    IF l_all_trips(j1).trip_id = l_failed_trips(j) THEN
                        --IF l_service_failed_delv_ids is null THEN
                        --    l_service_failed_delv_ids := l_all_trips(j1).delivery_id;
                        --ELSE
                        --   l_service_failed_delv_ids := l_service_failed_delv_ids ||' '||l_all_trips(j1).delivery_id;
                        --END IF;
                        l_failed_list.EXTEND;
                        IF p_deliveries_list_type = 'DEL' THEN
                            l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_id;
                        ELSE
                            l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_leg_id;
                        END IF;
                        IF l_delv_srv_failed_names IS NOT NULL THEN
                            l_delv_srv_failed_names := l_all_trips(j1).delivery_name;
                        ELSE
                            l_delv_srv_failed_names := l_delv_srv_failed_names ||' '||l_all_trips(j1).delivery_name;
                        END IF;
                    END IF;
                END LOOP;
            END LOOP;
    END IF;


    -- Handle Closed trips information for Error Messages and Warning.
    -- Trips which failed to validate for status/direction
    -- Get the deliveries/Dlegs and add them to failed list.
    j := 0;
    j1 := 0;
    IF l_closed_trips.COUNT > 0 THEN

        OPEN c_get_status_meaning;
        FETCH c_get_status_meaning INTO l_status;
        CLOSE c_get_status_meaning;
        FOR j IN l_closed_trips.FIRST..l_closed_trips.LAST LOOP
            FOR j1 IN l_all_trips.FIRST..l_all_trips.LAST LOOP
                IF l_all_trips(j1).trip_id = l_closed_trips(j) THEN
                    --IF l_closed_trips_delv_ids is null THEN
                    --    l_closed_trips_delv_ids := l_all_trips(j1).delivery_id;
                    --ELSE
                    --    l_closed_trips_delv_ids := l_closed_trips_delv_ids ||' '||l_all_trips(j1).delivery_id;
                    --END IF;
                    l_failed_list.EXTEND;
                    IF p_deliveries_list_type = 'DEL' THEN
                        l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_id;
                    ELSE
                        l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_leg_id;
                    END IF;
                    IF l_close_trdelv_name_list IS NOT NULL THEN
                       l_close_trdelv_name_list := l_all_trips(j1).delivery_name;
                    ELSE
                       l_close_trdelv_name_list := l_close_trdelv_name_list ||' '||l_all_trips(j1).delivery_name;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Failed Service Deliveries= '||l_service_failed_delv_ids);



l_index := 0;

    IF l_success_trips.COUNT > 0 THEN
        FOR l_index IN l_success_trips.FIRST..l_success_trips.LAST LOOP
            l_action_params.caller :=  'FTE';
            l_action_params.event  := 'RE-RATING';
            l_action_params.action := 'RATE';
            l_temp_trips_tab(1)    := l_success_trips(l_index);
            l_action_params.trip_id_list := l_temp_trips_tab;

            FTE_TRIP_RATING_GRP.Rate_Trip
            (
                 p_api_version              => 1.0,
                 p_init_msg_list            => FND_API.G_FALSE,
                 p_action_params            => l_action_params,
                 p_commit                   => FND_API.G_FALSE,
                 p_init_prc_log             => 'N',
                 x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data
             );
            j1 := 0;
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Trip Re-Rating successful for trip_id : '||l_trip_ids(l_index).trip_id);
                FOR j1 IN l_all_trips.FIRST..l_all_trips.LAST LOOP
                  IF l_all_trips(j1).trip_id = l_trip_ids(l_index).trip_id THEN
                      l_success_list.EXTEND;
                      IF p_deliveries_list_type = 'DEL' THEN
                          l_success_list(l_success_list.LAST) := l_all_trips(j1).delivery_id;
                      ELSE
                          l_success_list(l_success_list.LAST) := l_all_trips(j1).delivery_leg_id;
                      END IF;
                  END IF;
                END LOOP;
             ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Trip Re-Rating with Warnings for trip_id : '||l_trip_ids(l_index).trip_id);
                x_return_status := l_return_status;

                FND_MSG_PUB.Count_And_Get
                (
                   p_count  => l_msg_count,
                   p_data  =>  l_message,
                   p_encoded => FND_API.G_FALSE
                );
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Warning : '||l_message);
                FOR j1 IN l_all_trips.FIRST..l_all_trips.LAST LOOP
                  IF l_all_trips(j1).trip_id = l_trip_ids(l_index).trip_id THEN
                     IF l_warn_delivery_name_list is null THEN
                          l_warn_delivery_name_list := l_all_trips(j1).delivery_id;
                      ELSE
                          l_warn_delivery_name_list := l_warn_delivery_name_list ||' '||l_all_trips(j1).delivery_id;
                      END IF;
                      l_warning_list.EXTEND;
                      IF p_deliveries_list_type = 'DEL' THEN
                        l_warning_list(l_warning_list.LAST) := l_all_trips(j1).delivery_id;
                      ELSE
                        l_warning_list(l_warning_list.LAST) := l_all_trips(j1).delivery_leg_id;
                      END IF;
                  END IF;
                END LOOP;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'trip id: '|| l_trip_ids(l_index).trip_id || ' rate_trip2 ');
                x_return_status := l_return_status;
                FND_MSG_PUB.Count_And_Get
                (
                   p_count  => l_msg_count,
                   p_data  =>  l_message,
                   p_encoded => FND_API.G_FALSE
                );
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Error : '||l_message);
                FOR j1 IN l_all_trips.FIRST..l_all_trips.LAST LOOP
                  IF l_all_trips(j1).trip_id = l_trip_ids(l_index).trip_id THEN
                    IF l_fail_delivery_name_list is null THEN
                          l_fail_delivery_name_list := l_all_trips(j1).delivery_id;
                      ELSE
                          l_fail_delivery_name_list := l_fail_delivery_name_list ||' '||l_all_trips(j1).delivery_id;
                      END IF;
                      l_failed_list.EXTEND;
                      IF p_deliveries_list_type = 'DEL' THEN
                          l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_id;
                      ELSE
                          l_failed_list(l_failed_list.LAST) := l_all_trips(j1).delivery_leg_id;
                      END IF;
                  END IF;
                END LOOP;
             END IF;
        END LOOP; -- End Loop for l_trip_ids. Trip rating.
    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_trip_ids.COUNT=' || l_trip_ids.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_failed_list.COUNT='|| l_failed_list.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_warning_list.COUNT='|| l_warning_list.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_success_list.COUNT='|| l_success_list.COUNT);

    FND_MSG_PUB.Delete_Msg ( p_msg_index => null);

    IF l_success_list.COUNT > 0 THEN
        IF l_success_list.COUNT = l_dleg_list.COUNT THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;
    END IF;

    IF l_warning_list.COUNT > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        IF l_delv_with_multlegs_names IS NOT NULL THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Delv with MulipleLegs::= '||l_delv_with_multlegs_names);
            FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_MULTILEG_WARN');
            FND_MESSAGE.SET_TOKEN('DEL_NAMES',l_delv_with_multlegs_names);
            FND_MSG_PUB.ADD;
        END IF;
        FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_SHIPMENT_WARNIN');
        FND_MESSAGE.SET_TOKEN('DEL_NAMES',l_warn_delivery_name_list);
        FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
        FND_MSG_PUB.ADD;
    END IF;


     IF l_failed_list.COUNT >0 THEN
        IF l_delv_srv_failed_names IS NOT NULL THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Service failed list::= '||l_delv_srv_failed_names);
            FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_SERVICE_FAILED');
            FND_MESSAGE.SET_TOKEN('DEL_NAMES',l_delv_srv_failed_names);
            --FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
            FND_MSG_PUB.ADD;
        END IF;
        IF l_closed_trips_delv_ids IS NOT NULL THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Deliveries with Closed Trips list::= '||l_close_trdelv_name_list);
            FND_MESSAGE.SET_NAME('FTE','FTE_MLS_CANNOT_UPD_RATE');
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_close_trdelv_name_list);
            FND_MESSAGE.SET_TOKEN('DELIVERY_STATUS',l_status);
            --FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
            FND_MSG_PUB.ADD;
        END IF;
        IF l_fail_delivery_name_list IS NOT NULL THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' failed list::= '||l_fail_delivery_name_list);
            FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_SHIPMENT_FAIL');
            FND_MESSAGE.SET_TOKEN('DEL_NAMES',l_fail_delivery_name_list);
            FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
            FND_MSG_PUB.ADD;
        END IF;
        IF  l_success_list.COUNT > 0 OR l_warning_list.COUNT > 0 THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;
     END IF;
     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

  x_success_list := l_success_list;
  x_warning_list := l_warning_list;
  x_fail_list :=    l_failed_list;
ELSE
    RAISE l_dleg_validation_failed;
END IF;


   IF FND_API.To_Boolean( p_commit ) THEN

      COMMIT WORK;

  END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );



  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Msg Count'||x_msg_count||' Msg data:'||x_msg_data);

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;

EXCEPTION
   WHEN  l_delivery_validation_failed THEN
    ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --FND_MSG_PUB.Count_And_Get
	--  (
	--     p_count  => x_msg_count,
	--     p_data  =>  x_msg_data,
	--     p_encoded => FND_API.G_FALSE
	--  );
    --    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'msg count is ='||x_msg_count);
    --    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'msg data is ='||x_msg_data);
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'l_delivery_validation_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN l_dleg_list_empty THEN
	ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'l_dleg_list_empty');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;

    WHEN l_delv_list_empty THEN
	ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'l_delv_list_empty');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;

   WHEN l_del_name_mismatch THEN
	ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'l_del_name_mismatch');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN l_dleg_validation_failed THEN
   	ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'l_dleg_validation_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN l_trip_rating_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_reprice2',FTE_FREIGHT_PRICING_UTIL.G_ERR,'l_delivery_leg_rating_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_reprice2');
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'FND_API.G_EXC_UNEXPECTED_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN others THEN
	ROLLBACK TO rerate_shipment_online;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_api_name,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
END rerate_shipment_online;


PROCEDURE delete_fc_temp_pvt (
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        p_initialized             IN     BOOLEAN DEFAULT TRUE,
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2)
IS

  l_return_status                   VARCHAR2(1);
  l_log_level                       NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF p_initialized THEN
      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'delete_fc_temp_pvt','start');
   END IF;

   DELETE
   FROM   fte_freight_costs_temp
   WHERE  comparison_request_id = p_request_id
   --AND    nvl(lane_id,-9999) <> nvl(p_lane_id,-19999)
   AND    nvl(lane_id,-9999) <> nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-19999)
   AND    nvl(schedule_id,-9999) <> nvl(p_schedule_id,-19999);

   IF p_initialized THEN
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_fc_temp_pvt');
   END IF;

EXCEPTION
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF p_initialized THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception('delete_fc_temp_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_fc_temp_pvt');
      END IF;
END delete_fc_temp_pvt;

-- 	This API is called by Rate_Delivery of LCSS project
-- 	To move freight costs from pl/sql table to wsh_freight_costs
-- 	for non-TL rates, dleg_id is not populated in freight_cost_temp

PROCEDURE Move_fc_temp_to_main (
        p_delivery_leg_id          IN     NUMBER,
        p_freight_cost_temp_price  IN     Freight_Cost_Temp_Tab_Type,
        p_freight_cost_temp_charge IN     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'MOVE_FC_TEMP_TO_MAIN';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(240);

  l_empty_main_row           WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_main_row           WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_main_charge        WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_price_fc_ids                    WSH_UTIL_CORE.id_tab_type;
  l_rowid                           VARCHAR2(30);
  l_update_rowid                    VARCHAR2(30);
  l_freight_cost_id                 NUMBER;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_leg_id='||p_delivery_leg_id);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_freight_cost_temp_price.COUNT=' || p_freight_cost_temp_price.COUNT );

   IF (p_delivery_leg_id IS NULL) THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg;
   END IF;

  --IF p_freight_cost_temp_price.COUNT = 0 THEN
  --    raise FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move;
  --END IF;

   SAVEPOINT before_fc_creation;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through p_freight_cost_temp_price...');
  IF p_freight_cost_temp_price.COUNT > 0 THEN

  FOR i in p_freight_cost_temp_price.FIRST..p_freight_cost_temp_price.LAST LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i='||i);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_freight_cost_temp_price(i).TOTAL_AMOUNT=' ||   p_freight_cost_temp_price(i).TOTAL_AMOUNT);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_freight_cost_temp_price(i).BILLABLE_QUANTITY=' ||   p_freight_cost_temp_price(i).BILLABLE_QUANTITY);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_freight_cost_temp_price(i).UNIT_AMOUNT=' ||   p_freight_cost_temp_price(i).UNIT_AMOUNT);

      --ensures no spill overs from earlier rows
      l_freight_cost_main_row:=l_empty_main_row;

      l_freight_cost_main_row.FREIGHT_COST_TYPE_ID := p_freight_cost_temp_price(i).FREIGHT_COST_TYPE_ID;
      l_freight_cost_main_row.UNIT_AMOUNT          := p_freight_cost_temp_price(i).UNIT_AMOUNT;
      l_freight_cost_main_row.UOM                  := p_freight_cost_temp_price(i).UOM;
      l_freight_cost_main_row.QUANTITY             := p_freight_cost_temp_price(i).QUANTITY;
      l_freight_cost_main_row.TOTAL_AMOUNT         := p_freight_cost_temp_price(i).TOTAL_AMOUNT;
      l_freight_cost_main_row.CURRENCY_CODE        := p_freight_cost_temp_price(i).CURRENCY_CODE;
      l_freight_cost_main_row.DELIVERY_ID          := p_freight_cost_temp_price(i).DELIVERY_ID;

      IF (p_freight_cost_temp_price(i).DELIVERY_LEG_ID IS NULL)
      THEN

	l_freight_cost_main_row.DELIVERY_LEG_ID      := p_delivery_leg_id;
      ELSE
	l_freight_cost_main_row.DELIVERY_LEG_ID      := p_freight_cost_temp_price(i).DELIVERY_LEG_ID;
      END IF;

      l_freight_cost_main_row.DELIVERY_DETAIL_ID   := p_freight_cost_temp_price(i).DELIVERY_DETAIL_ID;
      --l_freight_cost_main_row.FREIGHT_CODE         := p_freight_cost_temp_price(i).FREIGHT_CODE;
      l_freight_cost_main_row.LINE_TYPE_CODE       := p_freight_cost_temp_price(i).LINE_TYPE_CODE;
      l_freight_cost_main_row.CHARGE_UNIT_VALUE    := p_freight_cost_temp_price(i).CHARGE_UNIT_VALUE;
      l_freight_cost_main_row.CHARGE_SOURCE_CODE   := p_freight_cost_temp_price(i).CHARGE_SOURCE_CODE;
      --l_freight_cost_main_row.ESTIMATED_FLAG        := p_freight_cost_temp_price(i).ESTIMATED_FLAG;
      l_freight_cost_main_row.ESTIMATED_FLAG       := 'Y';
      l_freight_cost_main_row.LAST_UPDATE_DATE     := SYSDATE;
      l_freight_cost_main_row.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
      l_freight_cost_main_row.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
      l_freight_cost_main_row.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      l_freight_cost_main_row.BILLABLE_UOM          := p_freight_cost_temp_price(i).BILLABLE_UOM;
      l_freight_cost_main_row.BILLABLE_BASIS          := p_freight_cost_temp_price(i).BILLABLE_BASIS;
      l_freight_cost_main_row.BILLABLE_QUANTITY          := p_freight_cost_temp_price(i).BILLABLE_QUANTITY;
      --l_freight_cost_main_row.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
      --l_freight_cost_main_row.PROGRAM_UPDATE_DATE  := SYSDATE;

          -- pack J Enhancement for FPA
      l_freight_cost_main_row.COMMODITY_CATEGORY_ID
               := p_freight_cost_temp_price(i).COMMODITY_CATEGORY_ID;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
       '(FPA)l_freight_cost_main_row.COMMODITY_CATEGORY_ID='||l_freight_cost_main_row.COMMODITY_CATEGORY_ID);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.line_type_code='||l_freight_cost_main_row.line_type_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.delivery_detail_id='||l_freight_cost_main_row.delivery_detail_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.delivery_leg_id='||l_freight_cost_main_row.delivery_leg_id);

      IF l_freight_cost_main_row.line_type_code = 'SUMMARY'
             AND l_freight_cost_main_row.delivery_detail_id IS NULL
	     AND l_freight_cost_main_row.delivery_leg_id is not null THEN

         -- To update the delivery leg summary row
         -- Get the delivery leg id as input and get the freight cost id for that
         -- The lane level summary amount becomes the delivery leg level summary amount

         l_freight_cost_main_row.FREIGHT_COST_ID      := get_fc_id_from_dleg(l_freight_cost_main_row.delivery_leg_id);
         l_freight_cost_main_row.DELIVERY_LEG_ID      := l_freight_cost_main_row.delivery_leg_id;

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.FREIGHT_COST_ID='||l_freight_cost_main_row.FREIGHT_COST_ID);

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost...');
         WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
          p_rowid                  =>  l_update_rowid,
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Update_Freight_Cost ');

      ELSE

         l_freight_cost_main_row.CREATION_DATE        := SYSDATE;
         l_freight_cost_main_row.CREATED_BY           := FND_GLOBAL.USER_ID;

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost...');
         WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_rowid                  =>  l_rowid,
          x_freight_cost_id        =>  l_freight_cost_id,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Base price');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

      END IF;

   END LOOP; -- p_freight_cost_temp_price loop
  END IF;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through p_freight_cost_temp_charge...');
  IF p_freight_cost_temp_charge.COUNT > 0 THEN
  FOR i in p_freight_cost_temp_charge.FIRST..p_freight_cost_temp_charge.LAST LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i='||i);

      --ensures no spill overs from earlier rows
      l_freight_cost_main_charge:=l_empty_main_row;

      l_freight_cost_main_charge.FREIGHT_COST_TYPE_ID := p_freight_cost_temp_charge(i).FREIGHT_COST_TYPE_ID;
      l_freight_cost_main_charge.UNIT_AMOUNT          := p_freight_cost_temp_charge(i).UNIT_AMOUNT;
      l_freight_cost_main_charge.UOM                  := p_freight_cost_temp_charge(i).UOM;
      l_freight_cost_main_charge.QUANTITY             := p_freight_cost_temp_charge(i).QUANTITY;
      l_freight_cost_main_charge.TOTAL_AMOUNT         := p_freight_cost_temp_charge(i).TOTAL_AMOUNT;
      l_freight_cost_main_charge.CURRENCY_CODE        := p_freight_cost_temp_charge(i).CURRENCY_CODE;
      l_freight_cost_main_charge.DELIVERY_ID          := p_freight_cost_temp_charge(i).DELIVERY_ID;

      IF (p_freight_cost_temp_charge(i).DELIVERY_LEG_ID IS NULL)
      THEN

	      l_freight_cost_main_charge.DELIVERY_LEG_ID      := p_delivery_leg_id;
      ELSE
	      l_freight_cost_main_charge.DELIVERY_LEG_ID      := p_freight_cost_temp_charge(i).DELIVERY_LEG_ID;
      END IF;
      l_freight_cost_main_charge.DELIVERY_DETAIL_ID   := p_freight_cost_temp_charge(i).DELIVERY_DETAIL_ID;
      --l_freight_cost_main_charge.FREIGHT_CODE         := p_freight_cost_temp_charge(i).FREIGHT_CODE;
      l_freight_cost_main_charge.LINE_TYPE_CODE       := p_freight_cost_temp_charge(i).LINE_TYPE_CODE;
      l_freight_cost_main_charge.CHARGE_UNIT_VALUE    := p_freight_cost_temp_charge(i).CHARGE_UNIT_VALUE;
      l_freight_cost_main_charge.CHARGE_SOURCE_CODE   := p_freight_cost_temp_charge(i).CHARGE_SOURCE_CODE;
      --l_freight_cost_main_charge.ESTIMATED_FLAG        := p_freight_cost_temp_charge(i).ESTIMATED_FLAG;
      l_freight_cost_main_charge.ESTIMATED_FLAG       := 'Y';
      l_freight_cost_main_charge.CREATION_DATE        := SYSDATE;
      l_freight_cost_main_charge.CREATED_BY           := FND_GLOBAL.USER_ID;
      l_freight_cost_main_charge.LAST_UPDATE_DATE     := SYSDATE;
      l_freight_cost_main_charge.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
      l_freight_cost_main_charge.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
      l_freight_cost_main_charge.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      l_freight_cost_main_row.BILLABLE_UOM            := p_freight_cost_temp_charge(i).BILLABLE_UOM;
      l_freight_cost_main_row.BILLABLE_BASIS          := p_freight_cost_temp_charge(i).BILLABLE_BASIS;
      l_freight_cost_main_row.BILLABLE_QUANTITY       := p_freight_cost_temp_charge(i).BILLABLE_QUANTITY;

      --l_freight_cost_main_charge.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
      --l_freight_cost_main_charge.PROGRAM_UPDATE_DATE  := SYSDATE;

          -- pack J Enhancement for FPA
      l_freight_cost_main_charge.COMMODITY_CATEGORY_ID
               := p_freight_cost_temp_charge(i).COMMODITY_CATEGORY_ID;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
       '(FPA)l_freight_cost_main_charge.COMMODITY_CATEGORY_ID='||l_freight_cost_main_charge.COMMODITY_CATEGORY_ID);

         WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
          p_freight_cost_info      =>  l_freight_cost_main_charge,
          x_rowid                  =>  l_rowid,
          x_freight_cost_id        =>  l_freight_cost_id,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Charge');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

   END LOOP; -- p_freight_cost_temp_charge loop
  END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_temp_fc_to_move');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_create_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END;

-- 	This API is called by Rate_Delivery of LCSS project
-- 	To move freight costs from pl/sql table to wsh_freight_costs
-- 	for TL rates, tl cost allocation will populate dleg_id in freight_cost_temp

PROCEDURE Move_fc_temp_to_main (
        p_freight_cost_temp  IN     Freight_Cost_Temp_Tab_Type,
        x_return_status           OUT NOCOPY     VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'MOVE_FC_TEMP_TO_MAIN';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(240);
  l_empty_main_row WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_main_row           WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_rowid                           VARCHAR2(30);
  l_update_rowid                    VARCHAR2(30);
  l_freight_cost_id                 NUMBER;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

--  IF p_freight_cost_temp.COUNT = 0 THEN
--      raise FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move;
--  END IF;

   SAVEPOINT before_fc_creation;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through p_freight_cost_temp...');
  IF p_freight_cost_temp.COUNT > 0 THEN
  FOR i in p_freight_cost_temp.FIRST..p_freight_cost_temp.LAST LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i='||i);

      --ensures no spill overs from earlier rows
      l_freight_cost_main_row:=l_empty_main_row;


      l_freight_cost_main_row.FREIGHT_COST_TYPE_ID := p_freight_cost_temp(i).FREIGHT_COST_TYPE_ID;
      l_freight_cost_main_row.UNIT_AMOUNT          := p_freight_cost_temp(i).UNIT_AMOUNT;
      l_freight_cost_main_row.UOM                  := p_freight_cost_temp(i).UOM;
      l_freight_cost_main_row.QUANTITY             := p_freight_cost_temp(i).QUANTITY;
      l_freight_cost_main_row.TOTAL_AMOUNT         := p_freight_cost_temp(i).TOTAL_AMOUNT;
      l_freight_cost_main_row.CURRENCY_CODE        := p_freight_cost_temp(i).CURRENCY_CODE;
      l_freight_cost_main_row.TRIP_ID          	   := p_freight_cost_temp(i).TRIP_ID;
      l_freight_cost_main_row.STOP_ID              := p_freight_cost_temp(i).STOP_ID;
      l_freight_cost_main_row.DELIVERY_ID          := p_freight_cost_temp(i).DELIVERY_ID;
      l_freight_cost_main_row.DELIVERY_LEG_ID      := p_freight_cost_temp(i).DELIVERY_LEG_ID;
      l_freight_cost_main_row.DELIVERY_DETAIL_ID   := p_freight_cost_temp(i).DELIVERY_DETAIL_ID;
      --l_freight_cost_main_row.FREIGHT_CODE         := p_freight_cost_temp(i).FREIGHT_CODE;
      l_freight_cost_main_row.LINE_TYPE_CODE       := p_freight_cost_temp(i).LINE_TYPE_CODE;
      l_freight_cost_main_row.CHARGE_UNIT_VALUE    := p_freight_cost_temp(i).CHARGE_UNIT_VALUE;
      l_freight_cost_main_row.CHARGE_SOURCE_CODE   := p_freight_cost_temp(i).CHARGE_SOURCE_CODE;
      --l_freight_cost_main_row.ESTIMATED_FLAG        := p_freight_cost_temp(i).ESTIMATED_FLAG;
      l_freight_cost_main_row.ESTIMATED_FLAG       := 'Y';
      l_freight_cost_main_row.LAST_UPDATE_DATE     := SYSDATE;
      l_freight_cost_main_row.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
      l_freight_cost_main_row.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
      l_freight_cost_main_row.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      --l_freight_cost_main_row.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
      --l_freight_cost_main_row.PROGRAM_UPDATE_DATE  := SYSDATE;

          -- pack J Enhancement for FPA
      l_freight_cost_main_row.COMMODITY_CATEGORY_ID
               := p_freight_cost_temp(i).COMMODITY_CATEGORY_ID;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
       '(FPA)l_freight_cost_main_row.COMMODITY_CATEGORY_ID='||l_freight_cost_main_row.COMMODITY_CATEGORY_ID);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.line_type_code='||l_freight_cost_main_row.line_type_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.delivery_detail_id='||l_freight_cost_main_row.delivery_detail_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.delivery_leg_id='||l_freight_cost_main_row.delivery_leg_id);

      IF l_freight_cost_main_row.line_type_code = 'SUMMARY'
             AND l_freight_cost_main_row.delivery_detail_id IS NULL
	     AND l_freight_cost_main_row.delivery_leg_id is not null THEN

         -- To update the delivery leg summary row
         -- Get the delivery leg id as input and get the freight cost id for that
         -- The lane level summary amount becomes the delivery leg level summary amount

         l_freight_cost_main_row.FREIGHT_COST_ID      := get_fc_id_from_dleg(l_freight_cost_main_row.delivery_leg_id);

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_freight_cost_main_row.FREIGHT_COST_ID='||l_freight_cost_main_row.FREIGHT_COST_ID);

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost...');
         WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
          p_rowid                  =>  l_update_rowid,
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Update_Freight_Cost ');

      ELSE

         l_freight_cost_main_row.CREATION_DATE        := SYSDATE;
         l_freight_cost_main_row.CREATED_BY           := FND_GLOBAL.USER_ID;

         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost...');
         WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_rowid                  =>  l_rowid,
          x_freight_cost_id        =>  l_freight_cost_id,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Base price');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

      END IF;

   END LOOP; -- p_freight_cost_temp_price loop
  END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_no_temp_fc_to_move');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_create_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END;

-- todo take care of applied_to_charge_id
PROCEDURE Move_fc_temp_to_main (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	          IN     VARCHAR2 DEFAULT 'Y',
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        p_delivery_leg_id         IN     NUMBER,
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_service_type_code       IN     VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2)
IS

  -- bug : 2763791 : added p_service_type_code

  CURSOR c_move_fc_temp IS
  SELECT *
  FROM   FTE_FREIGHT_COSTS_TEMP
  WHERE  comparison_request_id = p_request_id
  --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
  AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
  AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
  AND    moved_to_main_flag = 'N'
  AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
  AND    line_type_code NOT IN ('CHARGE','DISCOUNT');

  CURSOR c_move_fc_temp_charge IS
  SELECT *
  FROM   FTE_FREIGHT_COSTS_TEMP
  WHERE  comparison_request_id = p_request_id
  --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
  AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
  AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
  AND    moved_to_main_flag = 'N'
  AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
  AND    line_type_code IN ('CHARGE','DISCOUNT');


CURSOR c_get_lane_mode(c_lane_id IN NUMBER)
IS
SELECT  mode_of_transportation_code
FROM    fte_lanes
WHERE   lane_id = c_lane_id;


CURSOR c_get_sched_mode(c_schedule_id IN NUMBER)
IS
SELECT  mode_of_transportation_code
FROM    fte_lanes l, fte_schedules s
WHERE   l.lane_id = s.lane_id
AND     s.schedules_id = c_schedule_id;

  l_mode	VARCHAR2(30);
  l_freight_cost_temp_row           c_move_fc_temp%ROWTYPE;
  l_empty_main_row WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_main_row           WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_temp_charge        c_move_fc_temp_charge%ROWTYPE;
  l_freight_cost_main_charge        WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_price_fc_ids                    WSH_UTIL_CORE.id_tab_type;
  l_rowid                           VARCHAR2(30);
  l_update_rowid                    VARCHAR2(30);
  l_freight_cost_id                 NUMBER;
  l_return_status                   VARCHAR2(1);

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (p_init_prc_log = 'Y') THEN
     FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
                                                x_return_status => l_return_status );
   END IF;

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
   END IF;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Move_fc_temp_to_main','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Input : Request Id - '||p_request_id||' Delivery Leg Id - '||p_delivery_leg_id||' Lane id - '||p_lane_id||' Schedule Id - '||p_schedule_id
||' Service type - '||p_service_type_code );

   IF (p_delivery_leg_id IS NULL) OR (p_lane_id IS NULL AND p_schedule_id IS NULL) OR (p_request_id IS NULL)THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg;
   END IF;

   SAVEPOINT before_fc_creation;

   l_mode:=NULL;
   IF (p_schedule_id IS NOT NULL)
   THEN
   	OPEN c_get_sched_mode(p_schedule_id);
   	FETCH c_get_sched_mode INTO l_mode;
   	CLOSE c_get_sched_mode;
   ELSE

   	OPEN c_get_lane_mode(p_lane_id);
   	FETCH c_get_lane_mode INTO l_mode;
   	CLOSE c_get_lane_mode;

   END IF;


   IF ((l_mode IS NOT NULL) AND (l_mode='TRUCK'))
   THEN

   	FTE_TL_RATING.Move_Dlv_Records_To_Main(
		p_dleg_id=>p_delivery_leg_id,
		p_lane_id=>p_lane_id,
		p_schedule_id=>p_schedule_id,
		p_comparison_request_id=>p_request_id,
		x_return_status=>l_return_status);

	 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_dlv_rec_fail;
	    END IF;
	END IF;




   ELSE


	   OPEN c_move_fc_temp;
	   LOOP
	      FETCH c_move_fc_temp INTO l_freight_cost_temp_row;
	      EXIT WHEN c_move_fc_temp%NOTFOUND;

	      --ensures no spill overs from earlier rows
	      l_freight_cost_main_row:=l_empty_main_row;


	      -- When does estimated flag get updated ?

	      l_freight_cost_main_row.FREIGHT_COST_TYPE_ID := l_freight_cost_temp_row.FREIGHT_COST_TYPE_ID;
	      l_freight_cost_main_row.UNIT_AMOUNT          := l_freight_cost_temp_row.UNIT_AMOUNT;
	      l_freight_cost_main_row.UOM                  := l_freight_cost_temp_row.UOM;
	      l_freight_cost_main_row.QUANTITY             := l_freight_cost_temp_row.QUANTITY;
	      l_freight_cost_main_row.TOTAL_AMOUNT         := l_freight_cost_temp_row.TOTAL_AMOUNT;
	      l_freight_cost_main_row.CURRENCY_CODE        := l_freight_cost_temp_row.CURRENCY_CODE;
	      l_freight_cost_main_row.DELIVERY_ID          := l_freight_cost_temp_row.DELIVERY_ID;

	      IF (l_freight_cost_temp_row.DELIVERY_LEG_ID IS NULL)
	      THEN
		      l_freight_cost_main_row.DELIVERY_LEG_ID      := p_delivery_leg_id;
	      ELSE
		      l_freight_cost_main_row.DELIVERY_LEG_ID      := l_freight_cost_temp_row.DELIVERY_LEG_ID;
	      END IF;
	      l_freight_cost_main_row.DELIVERY_DETAIL_ID   := l_freight_cost_temp_row.DELIVERY_DETAIL_ID;
	      --l_freight_cost_main_row.FREIGHT_CODE         := l_freight_cost_temp_row.FREIGHT_CODE;
	      l_freight_cost_main_row.LINE_TYPE_CODE       := l_freight_cost_temp_row.LINE_TYPE_CODE;
	      l_freight_cost_main_row.CHARGE_UNIT_VALUE    := l_freight_cost_temp_row.CHARGE_UNIT_VALUE;
	      l_freight_cost_main_row.CHARGE_SOURCE_CODE   := l_freight_cost_temp_row.CHARGE_SOURCE_CODE;
	      --l_freight_cost_main_row.ESTIMATED_FLAG        := l_freight_cost_temp_row.ESTIMATED_FLAG;
	      l_freight_cost_main_row.ESTIMATED_FLAG       := 'Y';
	      l_freight_cost_main_row.LAST_UPDATE_DATE     := SYSDATE;
	      l_freight_cost_main_row.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	      l_freight_cost_main_row.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
	      l_freight_cost_main_row.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
          -- Added for R12
          l_freight_cost_main_row.BILLABLE_QUANTITY    := l_freight_cost_temp_row.BILLABLE_QUANTITY;
          l_freight_cost_main_row.BILLABLE_UOM         := l_freight_cost_temp_row.BILLABLE_UOM;
          l_freight_cost_main_row.BILLABLE_BASIS       := l_freight_cost_temp_row.BILLABLE_BASIS;

	      --l_freight_cost_main_row.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
	      --l_freight_cost_main_row.PROGRAM_UPDATE_DATE  := SYSDATE;

		  -- pack J Enhancement for FPA
	      l_freight_cost_main_row.COMMODITY_CATEGORY_ID
		       := l_freight_cost_temp_row.COMMODITY_CATEGORY_ID;
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	       '(FPA)l_freight_cost_main_row.COMMODITY_CATEGORY_ID='||l_freight_cost_main_row.COMMODITY_CATEGORY_ID);

	      IF l_freight_cost_main_row.line_type_code <> 'SUMMARY'
		 OR (l_freight_cost_main_row.line_type_code = 'SUMMARY'
		     AND l_freight_cost_main_row.delivery_detail_id IS NOT NULL) THEN

		 l_freight_cost_main_row.CREATION_DATE        := SYSDATE;
		 l_freight_cost_main_row.CREATED_BY           := FND_GLOBAL.USER_ID;

		 WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
		  p_freight_cost_info      =>  l_freight_cost_main_row,
		  x_rowid                  =>  l_rowid,
		  x_freight_cost_id        =>  l_freight_cost_id,
		  x_return_status          =>  l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			ROLLBACK to before_fc_creation;
			FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Base price');
			raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
		    END IF;
		 END IF;
		 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

		 IF l_freight_cost_main_row.line_type_code <> 'SUMMARY' THEN
		    l_price_fc_ids(l_freight_cost_main_row.delivery_detail_id) := l_freight_cost_id;
		 END IF;


	      ELSE
		 -- To update the delivery leg summary row
		 -- Get the delivery leg id as input and get the freight cost id for that
		 -- The lane level summary amount becomes the delivery leg level summary amount

		 l_freight_cost_main_row.FREIGHT_COST_ID      := get_fc_id_from_dleg(l_freight_cost_main_row.DELIVERY_LEG_ID);
		 --l_freight_cost_main_row.DELIVERY_LEG_ID      := p_delivery_leg_id;

		 WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
		  p_rowid                  =>  l_update_rowid,
		  p_freight_cost_info      =>  l_freight_cost_main_row,
		  x_return_status          =>  l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			ROLLBACK to before_fc_creation;
			raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
		    END IF;
		 END IF;
		 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Update_Freight_Cost ');

	      END IF;


	   END LOOP;
--	   IF c_move_fc_temp%ROWCOUNT = 0 THEN
--	      raise FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move;
--	   END IF;

	   OPEN c_move_fc_temp_charge;
	   LOOP
	      FETCH c_move_fc_temp_charge INTO l_freight_cost_temp_charge;
	      EXIT WHEN c_move_fc_temp_charge%NOTFOUND;

	      --ensures no spill overs from earlier rows
	      l_freight_cost_main_charge:=l_empty_main_row;

	      l_freight_cost_main_charge.FREIGHT_COST_TYPE_ID := l_freight_cost_temp_charge.FREIGHT_COST_TYPE_ID;
	      l_freight_cost_main_charge.UNIT_AMOUNT          := l_freight_cost_temp_charge.UNIT_AMOUNT;
	      l_freight_cost_main_charge.UOM                  := l_freight_cost_temp_charge.UOM;
	      l_freight_cost_main_charge.QUANTITY             := l_freight_cost_temp_charge.QUANTITY;
	      l_freight_cost_main_charge.TOTAL_AMOUNT         := l_freight_cost_temp_charge.TOTAL_AMOUNT;
	      l_freight_cost_main_charge.CURRENCY_CODE        := l_freight_cost_temp_charge.CURRENCY_CODE;
	      l_freight_cost_main_charge.DELIVERY_ID          := l_freight_cost_temp_charge.DELIVERY_ID;

	      IF (l_freight_cost_temp_charge.DELIVERY_LEG_ID IS NULL)
	      THEN

		l_freight_cost_main_charge.DELIVERY_LEG_ID      := p_delivery_leg_id;
	      ELSE
		l_freight_cost_main_charge.DELIVERY_LEG_ID      := l_freight_cost_temp_charge.DELIVERY_LEG_ID;
	      END IF;

	      l_freight_cost_main_charge.DELIVERY_DETAIL_ID   := l_freight_cost_temp_charge.DELIVERY_DETAIL_ID;
	      --l_freight_cost_main_charge.FREIGHT_CODE         := l_freight_cost_temp_charge.FREIGHT_CODE;
	      l_freight_cost_main_charge.LINE_TYPE_CODE       := l_freight_cost_temp_charge.LINE_TYPE_CODE;
	      l_freight_cost_main_charge.CHARGE_UNIT_VALUE    := l_freight_cost_temp_charge.CHARGE_UNIT_VALUE;
	      l_freight_cost_main_charge.CHARGE_SOURCE_CODE   := l_freight_cost_temp_charge.CHARGE_SOURCE_CODE;
	      --l_freight_cost_main_charge.ESTIMATED_FLAG        := l_freight_cost_temp_charge.ESTIMATED_FLAG;
	      l_freight_cost_main_charge.ESTIMATED_FLAG       := 'Y';
	      l_freight_cost_main_charge.CREATION_DATE        := SYSDATE;
	      l_freight_cost_main_charge.CREATED_BY           := FND_GLOBAL.USER_ID;
	      l_freight_cost_main_charge.LAST_UPDATE_DATE     := SYSDATE;
	      l_freight_cost_main_charge.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	      l_freight_cost_main_charge.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
	      l_freight_cost_main_charge.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
	      --l_freight_cost_main_charge.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
	      --l_freight_cost_main_charge.PROGRAM_UPDATE_DATE  := SYSDATE;



		  -- pack J Enhancement for FPA
	      l_freight_cost_main_charge.COMMODITY_CATEGORY_ID
		       := l_freight_cost_temp_charge.COMMODITY_CATEGORY_ID;
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	       '(FPA)l_freight_cost_main_charge.COMMODITY_CATEGORY_ID='||l_freight_cost_main_charge.COMMODITY_CATEGORY_ID);

	      l_freight_cost_main_charge.applied_to_charge_id := l_price_fc_ids(l_freight_cost_main_charge.delivery_detail_id);

		 WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
		  p_freight_cost_info      =>  l_freight_cost_main_charge,
		  x_rowid                  =>  l_rowid,
		  x_freight_cost_id        =>  l_freight_cost_id,
		  x_return_status          =>  l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			ROLLBACK to before_fc_creation;
			FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Charge');
			raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
		    END IF;
		 END IF;
		 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

	   END LOOP;

	   BEGIN  -- anonymous block to make sure transaction goes through even if the
		  -- enclosed update statement fails

	   UPDATE fte_freight_costs_temp
	   SET    moved_to_main_flag = 'Y'
	   WHERE  comparison_request_id = p_request_id
	   --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
	   AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
	   AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
	   AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
	   AND    moved_to_main_flag = 'N';

	   EXCEPTION
	     WHEN others THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Updating freight_costs_temp moved_to_main_flag failed');
		  null;
	   END;

	   delete_fc_temp_pvt (
		p_request_id              =>     p_request_id,     -- Comparison Request ID to move to main
		p_lane_id                 =>     p_lane_id,
		p_schedule_id             =>     p_schedule_id,
		x_return_status           =>     l_return_status);

	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp failed ');
		  raise FTE_FREIGHT_PRICING_UTIL.g_delete_fc_temp_failed;
	       END IF;
	   ELSE
	       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp successful ');
	   END IF;

   END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
   IF (p_init_prc_log = 'Y') THEN
   FTE_FREIGHT_PRICING_UTIL.close_logs;
   END IF;

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_move_dlv_rec_fail THEN
   	ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_tl_move_dlv_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;

   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_no_lanesched_seg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move THEN
        --ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_no_temp_fc_to_move');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_create_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_update_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_fc_temp_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_delete_fc_temp_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN others THEN
        ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
END Move_fc_temp_to_main;


PROCEDURE Move_fc_temp_to_main (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	          IN     VARCHAR2 DEFAULT 'Y',
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        p_trip_id         	  IN     NUMBER,
        p_lane_id                 IN     NUMBER DEFAULT NULL,
        p_schedule_id             IN     NUMBER DEFAULT NULL,
        p_service_type_code       IN     VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2)

IS

  -- bug : 2763791 : added p_service_type_code

  CURSOR c_move_fc_temp IS
  SELECT *
  FROM   FTE_FREIGHT_COSTS_TEMP
  WHERE  comparison_request_id = p_request_id
  --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
  AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
  AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
  AND    moved_to_main_flag = 'N'
  AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
  AND    line_type_code NOT IN ('CHARGE','DISCOUNT');

  CURSOR c_move_fc_temp_charge IS
  SELECT *
  FROM   FTE_FREIGHT_COSTS_TEMP
  WHERE  comparison_request_id = p_request_id
  --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
  AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
  AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
  AND    moved_to_main_flag = 'N'
  AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
  AND    line_type_code IN ('CHARGE','DISCOUNT');


CURSOR c_get_dlegs_from_trip(c_trip_id IN NUMBER) IS
        SELECT  dl.delivery_leg_id,dl.delivery_id
        FROM    wsh_delivery_legs dl ,
                wsh_trip_stops s
        WHERE   dl.pick_up_stop_id = s.stop_id
                and s.trip_id=c_trip_id;

  l_empty_main_row WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_temp_row           c_move_fc_temp%ROWTYPE;
  l_freight_cost_main_row           WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_freight_cost_temp_charge        c_move_fc_temp_charge%ROWTYPE;
  l_freight_cost_main_charge        WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
  l_price_fc_ids                    WSH_UTIL_CORE.id_tab_type;
  l_rowid                           VARCHAR2(30);
  l_update_rowid                    VARCHAR2(30);
  l_dleg_ids         		    DBMS_UTILITY.NUMBER_ARRAY;
  l_delivery_id			    NUMBER;
  l_dleg_id			    NUMBER;
  l_init_msg_list                   VARCHAR2(30) :=FND_API.G_FALSE;
  l_freight_cost_id                 NUMBER;
  l_return_status                   VARCHAR2(1);

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (p_init_prc_log = 'Y') THEN
     FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
                                                x_return_status => l_return_status );
   END IF;

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
   END IF;
   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Move_fc_temp_to_main','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Input : Request Id - '||p_request_id||' Trip Id - '||p_trip_id||' Lane id - '||p_lane_id||' Schedule Id - '||p_schedule_id
||' Service type - '||p_service_type_code );

   IF (p_trip_id IS NULL) OR (p_lane_id IS NULL AND p_schedule_id IS NULL) THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg;
   END IF;


   --Gather mapping from delivery to dleg id. Since this is for a single trip
   --There is only one dleg for a delivery
   l_delivery_id:=NULL;
   l_dleg_id:=NULL;
   l_dleg_ids.delete;

   OPEN c_get_dlegs_from_trip(p_trip_id);
   FETCH c_get_dlegs_from_trip INTO l_dleg_id,l_delivery_id;
   WHILE(c_get_dlegs_from_trip%FOUND)
   LOOP
   	IF ((l_dleg_id IS NOT NULL) AND (l_delivery_id IS NOT NULL))
   	THEN

   		l_dleg_ids(l_delivery_id):=l_dleg_id;

   	ELSE
   		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Null dleg/delivery '||l_dleg_id||' '||l_delivery_id);

   	END IF;

   	FETCH c_get_dlegs_from_trip INTO l_dleg_id,l_delivery_id;

   END LOOP;
   CLOSE c_get_dlegs_from_trip;


   SAVEPOINT before_fc_creation;

   OPEN c_move_fc_temp;
   LOOP
      FETCH c_move_fc_temp INTO l_freight_cost_temp_row;
      EXIT WHEN c_move_fc_temp%NOTFOUND;

      --ensures no spill overs from earlier rows
      l_freight_cost_main_row:=l_empty_main_row;


      -- When does estimated flag get updated ?

      l_freight_cost_main_row.FREIGHT_COST_TYPE_ID := l_freight_cost_temp_row.FREIGHT_COST_TYPE_ID;
      l_freight_cost_main_row.UNIT_AMOUNT          := l_freight_cost_temp_row.UNIT_AMOUNT;
      l_freight_cost_main_row.UOM                  := l_freight_cost_temp_row.UOM;
      l_freight_cost_main_row.QUANTITY             := l_freight_cost_temp_row.QUANTITY;
      l_freight_cost_main_row.TOTAL_AMOUNT         := l_freight_cost_temp_row.TOTAL_AMOUNT;
      l_freight_cost_main_row.CURRENCY_CODE        := l_freight_cost_temp_row.CURRENCY_CODE;
      l_freight_cost_main_row.DELIVERY_ID          := l_freight_cost_temp_row.DELIVERY_ID;

      l_freight_cost_main_row.FREIGHT_COST_ID:=NULL;-- To avoid this from bein retained from earlier

      IF (l_freight_cost_temp_row.DELIVERY_LEG_ID IS NULL)
      THEN

	      IF ((l_freight_cost_main_row.DELIVERY_ID IS NOT NULL)
		AND (l_dleg_ids.EXISTS(l_freight_cost_main_row.DELIVERY_ID)))
	      THEN

		l_freight_cost_main_row.DELIVERY_LEG_ID      := l_dleg_ids(l_freight_cost_main_row.DELIVERY_ID);

	      ELSE
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No dleg for delivery '||l_freight_cost_main_row.DELIVERY_ID);
		ROLLBACK to before_fc_creation;
		raise FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg;
	      END IF;

      ELSE
		l_freight_cost_main_row.DELIVERY_LEG_ID      := l_freight_cost_temp_row.DELIVERY_LEG_ID;
      END IF;

      l_freight_cost_main_row.DELIVERY_DETAIL_ID   := l_freight_cost_temp_row.DELIVERY_DETAIL_ID;
      --l_freight_cost_main_row.FREIGHT_CODE         := l_freight_cost_temp_row.FREIGHT_CODE;
      l_freight_cost_main_row.LINE_TYPE_CODE       := l_freight_cost_temp_row.LINE_TYPE_CODE;
      l_freight_cost_main_row.CHARGE_UNIT_VALUE    := l_freight_cost_temp_row.CHARGE_UNIT_VALUE;
      l_freight_cost_main_row.CHARGE_SOURCE_CODE   := l_freight_cost_temp_row.CHARGE_SOURCE_CODE;
      --l_freight_cost_main_row.ESTIMATED_FLAG        := l_freight_cost_temp_row.ESTIMATED_FLAG;
      l_freight_cost_main_row.ESTIMATED_FLAG       := 'Y';
      l_freight_cost_main_row.LAST_UPDATE_DATE     := SYSDATE;
      l_freight_cost_main_row.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
      l_freight_cost_main_row.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
      l_freight_cost_main_row.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      --l_freight_cost_main_row.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
      --l_freight_cost_main_row.PROGRAM_UPDATE_DATE  := SYSDATE;

      -- Added for R12
      l_freight_cost_main_row.BILLABLE_QUANTITY    := l_freight_cost_temp_row.BILLABLE_QUANTITY;
      l_freight_cost_main_row.BILLABLE_UOM         := l_freight_cost_temp_row.BILLABLE_UOM;
      l_freight_cost_main_row.BILLABLE_BASIS       := l_freight_cost_temp_row.BILLABLE_BASIS;

          -- pack J Enhancement for FPA
      l_freight_cost_main_row.COMMODITY_CATEGORY_ID
               := l_freight_cost_temp_row.COMMODITY_CATEGORY_ID;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
       '(FPA)l_freight_cost_main_row.COMMODITY_CATEGORY_ID='||l_freight_cost_main_row.COMMODITY_CATEGORY_ID);

      IF l_freight_cost_main_row.line_type_code <> 'SUMMARY'
         OR (l_freight_cost_main_row.line_type_code = 'SUMMARY'
             AND l_freight_cost_main_row.delivery_detail_id IS NOT NULL) THEN

         l_freight_cost_main_row.CREATION_DATE        := SYSDATE;
         l_freight_cost_main_row.CREATED_BY           := FND_GLOBAL.USER_ID;

         WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_rowid                  =>  l_rowid,
          x_freight_cost_id        =>  l_freight_cost_id,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Base price');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

         IF l_freight_cost_main_row.line_type_code <> 'SUMMARY' THEN
            l_price_fc_ids(l_freight_cost_main_row.delivery_detail_id) := l_freight_cost_id;
         END IF;


      ELSE
         -- To update the delivery leg summary row
         -- Get the delivery leg id as input and get the freight cost id for that
         -- The lane level summary amount becomes the delivery leg level summary amount

         l_freight_cost_main_row.FREIGHT_COST_ID      := get_fc_id_from_dleg(l_freight_cost_main_row.DELIVERY_LEG_ID);


         WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
          p_rowid                  =>  l_update_rowid,
          p_freight_cost_info      =>  l_freight_cost_main_row,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Update_Freight_Cost ');

      END IF;


   END LOOP;
--   IF c_move_fc_temp%ROWCOUNT = 0 THEN
--      raise FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move;
--   END IF;
   CLOSE c_move_fc_temp;

   OPEN c_move_fc_temp_charge;
   LOOP
      FETCH c_move_fc_temp_charge INTO l_freight_cost_temp_charge;
      EXIT WHEN c_move_fc_temp_charge%NOTFOUND;

      --ensures no spill overs from earlier rows
      l_freight_cost_main_charge:=l_empty_main_row;


      l_freight_cost_main_charge.FREIGHT_COST_TYPE_ID := l_freight_cost_temp_charge.FREIGHT_COST_TYPE_ID;
      l_freight_cost_main_charge.UNIT_AMOUNT          := l_freight_cost_temp_charge.UNIT_AMOUNT;
      l_freight_cost_main_charge.UOM                  := l_freight_cost_temp_charge.UOM;
      l_freight_cost_main_charge.QUANTITY             := l_freight_cost_temp_charge.QUANTITY;
      l_freight_cost_main_charge.TOTAL_AMOUNT         := l_freight_cost_temp_charge.TOTAL_AMOUNT;
      l_freight_cost_main_charge.CURRENCY_CODE        := l_freight_cost_temp_charge.CURRENCY_CODE;
      l_freight_cost_main_charge.DELIVERY_ID          := l_freight_cost_temp_charge.DELIVERY_ID;

      l_freight_cost_main_row.FREIGHT_COST_ID:=NULL;-- To avoid this from bein retained from earlier

      IF(l_freight_cost_temp_charge.DELIVERY_LEG_ID IS NULL)
      THEN


	      IF ((l_freight_cost_main_charge.DELIVERY_ID IS NOT NULL)
		AND (l_dleg_ids.EXISTS(l_freight_cost_main_charge.DELIVERY_ID)))
	      THEN

		l_freight_cost_main_charge.DELIVERY_LEG_ID      := l_dleg_ids(l_freight_cost_main_charge.DELIVERY_ID);

	      ELSE

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No dleg for delivery '||l_freight_cost_main_charge.DELIVERY_ID);

	      END IF;

        ELSE
		l_freight_cost_main_charge.DELIVERY_LEG_ID      :=l_freight_cost_temp_charge.DELIVERY_LEG_ID;
	END IF;

	l_freight_cost_main_charge.DELIVERY_DETAIL_ID   := l_freight_cost_temp_charge.DELIVERY_DETAIL_ID;
      --l_freight_cost_main_charge.FREIGHT_CODE         := l_freight_cost_temp_charge.FREIGHT_CODE;
      l_freight_cost_main_charge.LINE_TYPE_CODE       := l_freight_cost_temp_charge.LINE_TYPE_CODE;
      l_freight_cost_main_charge.CHARGE_UNIT_VALUE    := l_freight_cost_temp_charge.CHARGE_UNIT_VALUE;
      l_freight_cost_main_charge.CHARGE_SOURCE_CODE   := l_freight_cost_temp_charge.CHARGE_SOURCE_CODE;
      --l_freight_cost_main_charge.ESTIMATED_FLAG        := l_freight_cost_temp_charge.ESTIMATED_FLAG;
      l_freight_cost_main_charge.ESTIMATED_FLAG       := 'Y';
      l_freight_cost_main_charge.CREATION_DATE        := SYSDATE;
      l_freight_cost_main_charge.CREATED_BY           := FND_GLOBAL.USER_ID;
      l_freight_cost_main_charge.LAST_UPDATE_DATE     := SYSDATE;
      l_freight_cost_main_charge.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
      l_freight_cost_main_charge.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
      l_freight_cost_main_charge.PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      --l_freight_cost_main_charge.PROGRAM_ID           := FND_GLOBAL.CONC_PROGRAM_ID;
      --l_freight_cost_main_charge.PROGRAM_UPDATE_DATE  := SYSDATE;


          -- pack J Enhancement for FPA
      l_freight_cost_main_charge.COMMODITY_CATEGORY_ID
               := l_freight_cost_temp_charge.COMMODITY_CATEGORY_ID;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
       '(FPA)l_freight_cost_main_charge.COMMODITY_CATEGORY_ID='||l_freight_cost_main_charge.COMMODITY_CATEGORY_ID);

      l_freight_cost_main_charge.applied_to_charge_id := l_price_fc_ids(l_freight_cost_main_charge.delivery_detail_id);

         WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
          p_freight_cost_info      =>  l_freight_cost_main_charge,
          x_rowid                  =>  l_rowid,
          x_freight_cost_id        =>  l_freight_cost_id,
          x_return_status          =>  l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                ROLLBACK to before_fc_creation;
                FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Charge');
                raise FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed;
            END IF;
         END IF;
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'After Create_Freight_Cost id : '||l_freight_cost_id);

   END LOOP;
   CLOSE c_move_fc_temp_charge;

   BEGIN  -- anonymous block to make sure transaction goes through even if the
          -- enclosed update statement fails

   UPDATE fte_freight_costs_temp
   SET    moved_to_main_flag = 'Y'
   WHERE  comparison_request_id = p_request_id
   --AND    nvl(lane_id,-9999) = nvl(p_lane_id,-9999)
   AND    nvl(lane_id,-9999) = nvl(decode(p_schedule_id,NULL,p_lane_id,NULL),-9999)
   AND    nvl(schedule_id,-9999) = nvl(p_schedule_id,-9999)
   AND    nvl(service_type_code,'X') = nvl(p_service_type_code,'X')
   AND    moved_to_main_flag = 'N';

   EXCEPTION
     WHEN others THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Updating freight_costs_temp moved_to_main_flag failed');
          null;
   END;

   delete_fc_temp_pvt (
        p_request_id              =>     p_request_id,     -- Comparison Request ID to move to main
        p_lane_id                 =>     p_lane_id,
        p_schedule_id             =>     p_schedule_id,
        x_return_status           =>     l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp failed ');
          raise FTE_FREIGHT_PRICING_UTIL.g_delete_fc_temp_failed;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp successful ');
   END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
   IF (p_init_prc_log = 'Y') THEN
   FTE_FREIGHT_PRICING_UTIL.close_logs;
   END IF;

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_lanesched_seg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_no_lanesched_seg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_no_temp_fc_to_move THEN
        --ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_no_temp_fc_to_move');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_create_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_create_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_update_freight_cost_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_fc_temp_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_delete_fc_temp_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
   WHEN others THEN
        ROLLBACK to before_fc_creation;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Move_fc_temp_to_main','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_fc_temp_to_main');
        IF (p_init_prc_log = 'Y') THEN
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
END Move_fc_temp_to_main;


PROCEDURE delete_fc_temp (
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
        p_request_id              IN     NUMBER,     -- Comparison Request ID to move to main
        x_return_status           OUT NOCOPY     VARCHAR2)
IS

  l_initialized                     BOOLEAN := TRUE;
  l_return_status                   VARCHAR2(1);
  l_log_level                       NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
   SAVEPOINT DELETE_FC_TEMP;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
                                                x_return_status => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_initialized    :=  FALSE;
            x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
       FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
       FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'delete_fc_temp','start');
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Input : Request Id - '||p_request_id);
   END IF;

   delete_fc_temp_pvt (
        p_request_id              =>     p_request_id,     -- Comparison Request ID to move to main
        p_initialized             =>     l_initialized,
        x_return_status           =>     l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          IF l_initialized THEN
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp failed ');
          END IF;
          ROLLBACK TO DELETE_FC_TEMP;
          x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;
   ELSE
       IF l_initialized THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'delete_fc_temp successful ');
       END IF;
       COMMIT;
   END IF;

   IF l_initialized THEN
      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_fc_temp');
      FTE_FREIGHT_PRICING_UTIL.close_logs;
   END IF;

EXCEPTION

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        IF l_initialized THEN
             FTE_FREIGHT_PRICING_UTIL.set_exit_exception('delete_fc_temp','g_others');
             FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
             FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'delete_fc_temp');
             FTE_FREIGHT_PRICING_UTIL.close_logs;
        END IF;
END delete_fc_temp;


--
-- API: SHIPMENT_PRICE_COMPARE_PVT
--      Internal api for price comparison for LTL and PARCEL
--      Can accept delivery or trip. Can generate its own comparison request id
--      or can be passed in.
--      Not to be called from outside rating
--      Does not initialize the log file
--      Introduced for pack J
--
--      Parameters :
--          p_delivery_id        -> Input either delivery_id or trip_id (not both)
--          p_trip_id            -> Input either delivery_id or trip_id (not both)
--          p_lane_id_tab        -> table of lane ids
--          p_schedule_id_tab    -> table of schedule ids
--          Note : p_lane_id_tab and p_schedule_id_tab can have overlapping indices
--                 For this API both tables are assumed to be independent of each
--                 other
--          p_dep_date           -> departure date
--          p_arr_date           -> arrival date
--          x_sum_lane_price_tab        ->
--          x_sum_lane_price_curr_tab   ->
--          x_sum_sched_price_tab       ->
--          x_sum_sched_price_curr_tab  ->
--          x_request_id              -> Can generate its own id if not passed in
--          x_return_status           -> return status
--

PROCEDURE shipment_price_compare_pvt (
        p_delivery_id             IN     NUMBER DEFAULT NULL,
        p_trip_id                 IN     NUMBER DEFAULT NULL,
        p_lane_id_tab             IN     WSH_UTIL_CORE.id_tab_type,
        p_sched_id_tab            IN     WSH_UTIL_CORE.id_tab_type,
        p_service_lane_tab        IN     WSH_UTIL_CORE.Column_Tab_Type,
        p_service_sched_tab       IN     WSH_UTIL_CORE.Column_Tab_Type,
        p_dep_date                IN     DATE DEFAULT sysdate,
        p_arr_date                IN     DATE DEFAULT sysdate,
        x_sum_lane_price_tab      OUT    NOCOPY  WSH_UTIL_CORE.id_tab_type,
        x_sum_lane_price_curr_tab OUT    NOCOPY  WSH_UTIL_CORE.Column_tab_type,
        x_sum_sched_price_tab      OUT   NOCOPY  WSH_UTIL_CORE.id_tab_type,
        x_sum_sched_price_curr_tab OUT   NOCOPY  WSH_UTIL_CORE.Column_tab_type,
        x_request_id              IN OUT NOCOPY     NUMBER,
        x_return_status           OUT    NOCOPY     VARCHAR2 )
IS

   CURSOR c_delivery(c_delivery_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          NULL,   --  No delivery leg here
          NULL,   --  No reprice_required flag here
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,            -- arrival_date
          NULL,             -- comm_category_id
	  wda.type,
	  wda.parent_delivery_id,
	  NULL--wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda,
	  wsh_new_deliveries wd
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = c_delivery_id
   and      (wda.type IS null  OR wda.type <> 'O')--MDC
   and    wda.delivery_id 	 = wd.delivery_id;

   CURSOR c_delivery_from_trip(c_trip_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          wdl.delivery_leg_id,
          nvl(wdl.reprice_required,'N') as reprice_required,  --  Added AG 05/10
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,            -- arrival_date
          NULL,             -- comm_category_id
	  wda.type,
	  wda.parent_delivery_id,
	  wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda,
	  wsh_new_deliveries wd,
          wsh_delivery_legs wdl, wsh_trip_stops wts1, wsh_trip_stops wts2,wsh_trips wt
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = wdl.delivery_id
   and    wdl.delivery_id 	 = wd.delivery_id
   and    wdl.pick_up_stop_id    = wts1.stop_id
   and    wdl.drop_off_stop_id   = wts2.stop_id
   and    wts1.trip_id           = wt.trip_id
   and    wts2.trip_id           = wt.trip_id
   and      (wda.type IS null  OR wda.type <> 'O')--MDC
   and    wt.trip_id             = c_trip_id;


   CURSOR c_get_req_id IS
   SELECT fte_pricing_comp_request_s.nextval
   FROM   sys.dual;

   CURSOR c_get_carrier_for_lane(c_lane_id IN NUMBER) IS
   SELECT carrier_id
   FROM fte_lanes
   WHERE lane_id = c_lane_id;

   l_return_status                   VARCHAR2(1);
   l_return_code             NUMBER;
   l_delvy_det_rec                   shipment_line_rec_type;
   l_first_level_rows                shpmnt_content_tab_type;
   l_first_level_charges             addl_services_tab_type;
   l_request_id                      NUMBER:=0;
   l_lane_summary                    NUMBER:=0;
   l_lane_summary_uom                VARCHAR2(40);
   l_sched_summary                   NUMBER:=0;
   l_sched_summary_uom               VARCHAR2(40);
   l_lane_num                        VARCHAR2(100);
   l_sched_num                       VARCHAR2(100);
   i                                 NUMBER:=0;
   j                                 NUMBER:=0;
   l_dummy_fc_temp_price             Freight_Cost_Temp_Tab_Type;
   l_dummy_fc_temp_charge            Freight_Cost_Temp_Tab_Type;
   l_currency_code                   VARCHAR2(10);
   l_carrier_id                     NUMBER;

   l_log_level    NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;


BEGIN

   SAVEPOINT SHIPMENT_PRICE_COMPARE_PVT;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_price_compare_pvt','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_delivery_id ='||p_delivery_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_trip_id     ='||p_trip_id);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_lane_id_tab.COUNT ='||p_lane_id_tab.COUNT);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_sched_id_tab.COUNT ='||p_sched_id_tab.COUNT);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_dep_date    ='||p_dep_date);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_arr_date    ='||p_arr_date);
   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'x_request_id ='||x_request_id);

   IF p_trip_id IS NOT NULL THEN
      validate_nontl_trip(
	p_trip_id 	=> p_trip_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = G_RC_REPRICE_NOT_REQUIRED
	     OR l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;



   ELSIF p_delivery_id IS NOT NULL THEN

      validate_delivery(
	p_delivery_id 	=> p_delivery_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = G_RC_REPRICE_NOT_REQUIRED
	     OR l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;
   END IF;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             raise FTE_FREIGHT_PRICING_UTIL.g_currency_code_failed;
          END IF;
      END IF;




   -- Important : must delete global table
   g_shipment_line_rows.DELETE;

   --  Generate comparison request_id here and populate it into l_request_id

   IF (x_request_id IS NULL OR x_request_id = 0) THEN

      OPEN c_get_req_id;
      FETCH c_get_req_id INTO l_request_id;
      CLOSE c_get_req_id;

      x_request_id := l_request_id;

   ELSE
      l_request_id := x_request_id;

   END IF;

   fte_freight_pricing_util.print_msg(p_msg => 'Comparison request_id is ' || l_request_id);

   IF (p_delivery_id IS NOT NULL) THEN

      OPEN c_delivery(p_delivery_id);

      LOOP
      FETCH c_delivery INTO l_delvy_det_rec;
         EXIT WHEN c_delivery%NOTFOUND;
         g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
      END LOOP;

      IF c_delivery%ROWCOUNT = 0 THEN
         CLOSE c_delivery;
         raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matching number of delivery lines : '||c_delivery%ROWCOUNT);
      END IF;

      CLOSE c_delivery;

   ELSIF (p_trip_id IS NOT NULL) THEN

      OPEN c_delivery_from_trip(p_trip_id);

      LOOP
         FETCH c_delivery_from_trip INTO l_delvy_det_rec;
         EXIT WHEN c_delivery_from_trip%NOTFOUND;
         g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
      END LOOP;

      IF c_delivery_from_trip%ROWCOUNT = 0 THEN
         CLOSE c_delivery_from_trip;
         raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
      ELSE
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Matching number of delivery lines : '||c_delivery_from_trip%ROWCOUNT);
      END IF;

      CLOSE c_delivery_from_trip;

   ELSE
         raise FTE_FREIGHT_PRICING_UTIL.g_invalid_parameters;
   END IF;


   flatten_shipment (
     x_first_level_rows        =>    l_first_level_rows,
     x_return_status           =>    l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         raise FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed;
      END IF;
   ELSE
      IF l_first_level_rows.COUNT = 0 THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_empty_delivery;
      END IF;
      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'No. of top level lines 6 : '||l_first_level_rows.COUNT);
   END IF;


   IF (p_lane_id_tab.COUNT > 0) THEN

       IF p_lane_id_tab.COUNT <> p_service_lane_tab.COUNT THEN
            ROLLBACK TO SHIPMENT_PRICE_COMPARE_PVT;
            raise FTE_FREIGHT_PRICING_UTIL.g_missing_service_type;
       END IF;

       i := p_lane_id_tab.FIRST;
       LOOP

       OPEN c_get_carrier_for_lane(p_lane_id_tab(i));
       FETCH c_get_carrier_for_lane INTO l_carrier_id;
       CLOSE c_get_carrier_for_lane;

    IF p_trip_id IS NOT NULL THEN
         FTE_FREIGHT_PRICING_UTIL.get_currency_code
            (
                p_trip_id => p_trip_id,
                p_carrier_id => l_carrier_id,
                x_currency_code   =>   l_currency_code,
                x_return_status   =>   l_return_status
            );
    ELSE
          FTE_FREIGHT_PRICING_UTIL.get_currency_code
         (
             p_delivery_id => p_delivery_id,
             p_carrier_id => l_carrier_id,
             x_currency_code   =>   l_currency_code,
             x_return_status   =>   l_return_status
         );

    END IF;

         shipment_pricing (
            p_lane_id                 =>    p_lane_id_tab(i),
            p_service_type            =>    p_service_lane_tab(i),
                                              -- service type is required with lane/schedule
            p_ship_date               =>    p_dep_date,
            p_arrival_date            =>    p_arr_date,
            p_shpmnt_toplevel_rows    =>    l_first_level_rows,
            p_shpmnt_toplevel_charges =>    l_first_level_charges,
            p_save_flag               =>    'T',
            p_request_id              =>    l_request_id,
            p_currency_code           =>    l_currency_code,
            x_summary_lanesched_price      => l_lane_summary,
            x_summary_lanesched_price_uom  => l_lane_summary_uom,
            x_freight_cost_temp_price      => l_dummy_fc_temp_price,
            x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
            x_return_status           =>    l_return_status ) ;

            FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'After shipment_pricing - p_lane_id = '||p_lane_id_tab(i));
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_return_status='||l_return_status);
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   x_sum_lane_price_tab(i) := -1;
                   x_sum_lane_price_curr_tab(i) := 'NULL';
                   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'lane: '||p_lane_id_tab(i)||' shipment_pricing ');
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful for lane : '||p_lane_id_tab(i));

                x_sum_lane_price_tab(i)      := nvl(l_lane_summary,0);
                x_sum_lane_price_curr_tab(i) := l_lane_summary_uom;

             END IF;

       EXIT WHEN i = p_lane_id_tab.LAST;
         i := p_lane_id_tab.NEXT(i);
       END LOOP;

   END IF;


   IF (p_sched_id_tab.COUNT > 0) THEN

       IF p_sched_id_tab.COUNT <> p_service_sched_tab.COUNT THEN
            ROLLBACK TO SHIPMENT_PRICE_COMPARE_PVT;
            raise FTE_FREIGHT_PRICING_UTIL.g_missing_service_type;
       END IF;

       i := p_sched_id_tab.FIRST;
       LOOP

         shipment_pricing (
            p_schedule_id             =>    p_sched_id_tab(i),
            p_service_type            =>    p_service_sched_tab(i),
                                              -- service type is required with lane/schedule
            p_ship_date               =>    p_dep_date,
            p_arrival_date            =>    p_arr_date,
            p_shpmnt_toplevel_rows    =>    l_first_level_rows,
            p_shpmnt_toplevel_charges =>    l_first_level_charges,
            p_save_flag               =>    'T',
            p_request_id              =>    l_request_id,
            x_summary_lanesched_price      => l_sched_summary,
            x_summary_lanesched_price_uom  => l_sched_summary_uom,
            x_freight_cost_temp_price      => l_dummy_fc_temp_price,
            x_freight_cost_temp_charge     => l_dummy_fc_temp_charge,
            x_return_status           =>    l_return_status ) ;

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   x_sum_sched_price_tab(i) := -1;
                   x_sum_sched_price_curr_tab(i) := 'NULL';
                   FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'sched: '||p_sched_id_tab(i)||' shipment_pricing ');
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                END IF;
             ELSE
                FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'Shipment pricing successful for sched : '||p_sched_id_tab(i));

                x_sum_sched_price_tab(i)      := nvl(l_sched_summary,0);
                x_sum_sched_price_curr_tab(i) := l_sched_summary_uom;

             END IF;

       EXIT WHEN i = p_sched_id_tab.LAST;
         i := p_sched_id_tab.NEXT(i);
       END LOOP;

   END IF;

   x_request_id := l_request_id;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');

EXCEPTION
   WHEN g_finished_warning THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_delivery_not_found THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_delivery_not_found');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_flatten_shipment_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_flatten_shipment_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_empty_delivery THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_empty_delivery');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_missing_service_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_missing_service_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_shipment_pricing_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_shipment_pricing_failed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');
   WHEN others THEN
        ROLLBACK TO SHIPMENT_PRICE_COMPARE_PVT;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('shipment_price_compare_pvt',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare_pvt');

END shipment_price_compare_pvt;


PROCEDURE FPA_total_commodity_weight(
                           p_init_msg_list IN  VARCHAR2 DEFAULT fnd_api.g_true,
                           p_delivery_id   IN  NUMBER,
                           x_total_comm_wt   OUT NOCOPY NUMBER,
                           x_wt_uom        OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2 )
IS

    l_return_status    VARCHAR2(1);
    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

   CURSOR c_delivery_details(c_delivery_id IN NUMBER) IS
   SELECT wdd.delivery_detail_id,
          wdd.gross_weight        ,
          wdd.weight_uom_code
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wdd.container_flag = 'N'
   and      (wda.type IS null  OR wda.type <> 'O')--MDC
   and    wda.delivery_id        = c_delivery_id;

   CURSOR c_delivery_wt_uom(c_delivery_id IN NUMBER) IS
   SELECT weight_uom_code
   FROM   wsh_new_deliveries
   WHERE  delivery_id = c_delivery_id;

   l_target_wt_uom   VARCHAR2(30);
   l_cum_wt          NUMBER;
   l_temp_wt         NUMBER;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.

   FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
                                                x_return_status  => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status  :=  l_return_status;
            RETURN;
       END IF;
   ELSE
       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
   END IF;


   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'FPA_total_commodity_weight','start');

   OPEN c_delivery_wt_uom(p_delivery_id);
   FETCH c_delivery_wt_uom INTO l_target_wt_uom;
   CLOSE c_delivery_wt_uom;

   IF (l_target_wt_uom IS NULL) THEN
     raise fte_freight_pricing_util.g_weight_uom_not_found;
   END IF;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_target_wt_uom='||l_target_wt_uom);

   l_cum_wt :=0;

   FOR c_det_rec IN c_delivery_details(p_delivery_id) LOOP

     IF (c_det_rec.gross_weight IS NULL OR c_det_rec.weight_uom_code IS NULL) THEN
       FTE_FREIGHT_PRICING_UTIL.setmsg (p_api =>'FPA_total_commodity_weight',
                                         p_exc =>'g_tl_dtl_no_gross_weight',
                                         p_msg_name =>'FTE_INVALID_DEL_DET_WT',
                                         p_delivery_detail_id =>c_det_rec.delivery_detail_id);
       raise fte_freight_pricing_util.g_tl_dtl_no_gross_weight;
     END IF;

     IF (c_det_rec.weight_uom_code <> l_target_wt_uom) THEN
            l_temp_wt :=  WSH_WV_UTILS.convert_uom(c_det_rec.weight_uom_code,
                                       l_target_wt_uom,
                                       c_det_rec.gross_weight,
                                       0);  -- Within same UOM class

        l_cum_wt := l_cum_wt + l_temp_wt;
     ELSE
        l_cum_wt := l_cum_wt + c_det_rec.gross_weight;
     END IF;

   END LOOP;

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_cum_wt='||l_cum_wt);
   x_total_comm_wt := l_cum_wt;
   x_wt_uom := l_target_wt_uom;

   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get (
     p_count         =>      x_msg_count,
     p_data          =>      x_msg_data );

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_total_commodity_weight');
   FTE_FREIGHT_PRICING_UTIL.close_logs;

EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_gross_weight THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('FPA_total_commodity_weight','g_tl_dtl_no_gross_weight');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_total_commodity_weight');
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN FTE_FREIGHT_PRICING_UTIL.g_weight_uom_not_found THEN
        FTE_FREIGHT_PRICING_UTIL.setmsg (p_api =>'FPA_total_commodity_weight',
                                         p_exc =>'g_tl_dtl_no_gross_weight',
                                         p_msg_name =>'FTE_INVALID_DEL_WT_UOM',
                                         p_delivery_id =>p_delivery_id);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('FPA_total_commodity_weight','g_weight_uom_not_found');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_total_commodity_weight');
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('FPA_total_commodity_weight','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_total_commodity_weight');
        FTE_FREIGHT_PRICING_UTIL.close_logs;
END FPA_total_commodity_weight;




--      This API is called from the Multi-leg UI for price comparison across lanes/schedules
--      It stores frieght cost details in WSH_FREIGHT_COSTS_TEMP table for all the lanes
--      for display purpose.
--      It returns PL/SQL tables (dense) of summary price in the same sequence as the input
--      Calls shipment hierarchy flattening API

PROCEDURE shipment_price_compare (
	p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_true,
	p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	p_delivery_id             IN     NUMBER,
	p_trip_id		IN 	NUMBER,
	p_lane_sched_id_tab        IN  FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	p_lane_sched_tab           IN  FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	p_mode_tab                 IN  FTE_CODE_TAB_TYPE,
	p_service_type_tab         IN  FTE_CODE_TAB_TYPE,
	p_vehicle_type_tab           IN  FTE_ID_TAB_TYPE,
	p_dep_date                IN     DATE DEFAULT sysdate,
	p_arr_date                IN     DATE DEFAULT sysdate,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	x_lane_sched_id_tab        OUT  NOCOPY FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	x_lane_sched_tab           OUT  NOCOPY FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	x_vehicle_type_tab    OUT  NOCOPY FTE_ID_TAB_TYPE,--Vehicle Type ID
	x_mode_tab                 OUT  NOCOPY FTE_CODE_TAB_TYPE,
	x_service_type_tab         OUT NOCOPY FTE_CODE_TAB_TYPE,
	x_sum_rate_tab             OUT NOCOPY FTE_ID_TAB_TYPE,
	x_sum_rate_curr_tab        OUT NOCOPY FTE_CODE_TAB_TYPE,
	x_request_id              OUT NOCOPY     NUMBER,     -- One request ID per comparison request
	x_return_status           OUT NOCOPY     VARCHAR2 )
IS


CURSOR c_get_req_id IS
SELECT fte_pricing_comp_request_s.nextval
FROM   sys.dual;



   l_return_status                   VARCHAR2(1);
   l_request_id            NUMBER;
   i                       NUMBER;
   j                       NUMBER;
   k			   NUMBER;
   l			   NUMBER;
   s			   NUMBER;


   l_lane_id_tab             WSH_UTIL_CORE.id_tab_type;
   l_sched_id_tab            WSH_UTIL_CORE.id_tab_type;
   l_service_lane_tab        WSH_UTIL_CORE.Column_Tab_Type;
   l_service_sched_tab       WSH_UTIL_CORE.Column_Tab_Type;

   l_sum_lane_price_tab      WSH_UTIL_CORE.id_tab_type;
   l_sum_lane_price_curr_tab WSH_UTIL_CORE.Column_tab_type;
   l_sum_sched_price_tab     WSH_UTIL_CORE.id_tab_type;
   l_sum_sched_price_curr_tab WSH_UTIL_CORE.Column_tab_type;

l_tl_lane_rows         dbms_utility.number_array;
l_tl_schedule_rows     dbms_utility.number_array;
l_tl_vehicle_rows      dbms_utility.number_array;
l_tl_lane_sched_sum_rows   dbms_utility.number_array;
l_tl_lane_sched_curr_rows  dbms_utility.name_array;
l_tl_xref           dbms_utility.number_array;

l_exploded_lane_rows         dbms_utility.number_array;
l_exploded_schedule_rows     dbms_utility.number_array;
l_exploded_vehicle_rows      dbms_utility.number_array;
l_exploded_ref_rows      dbms_utility.number_array;

l_output_count NUMBER;
l_ref NUMBER;
l_warn_flag VARCHAR2(1);
l_tl_ref dbms_utility.number_array;
l_lane_xref dbms_utility.number_array;
l_sched_xref dbms_utility.number_array;

    l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

   l_ret_stat               VARCHAR2(1);  -- used only for returning log file name

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

   SAVEPOINT SHIPMENT_PRICE_COMPARE;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF(p_init_prc_log='Y')
   THEN




	   FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
							x_return_status  => l_return_status );

	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		    x_return_status  :=  l_return_status;
		    RETURN;
	       END IF;
	   ELSE
	       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
	   END IF;

   END IF;

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'shipment_price_compare','start');

   FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'p_delivery_id='||p_delivery_id);


   l_warn_flag := 'N';

   j:=1;
   k:=1;
   l:=1;
   i:=p_lane_sched_tab.FIRST;
   WHILE( i IS NOT NULL)
   LOOP
   	IF((p_lane_sched_tab(i)='L') AND (p_mode_tab(i) IS NOT NULL) AND (p_mode_tab(i)='TRUCK'))
   	THEN
   		l_tl_lane_rows(j):=p_lane_sched_id_tab(i);
   		l_tl_schedule_rows(j):=NULL;
   		l_tl_vehicle_rows(j):=p_vehicle_type_tab(i);
   		l_tl_ref(j):=i;
   		j:=j+1;


   	ELSIF((p_lane_sched_tab(i)='S') AND (p_mode_tab(i) IS NOT NULL) AND (p_mode_tab(i)='TRUCK'))
   	THEN

		l_tl_lane_rows(j):=NULL;
		l_tl_schedule_rows(j):=p_lane_sched_id_tab(i);
		l_tl_vehicle_rows(j):=p_vehicle_type_tab(i);
		l_tl_ref(j):=i;
		j:=j+1;


   	ELSIF(p_lane_sched_tab(i)='L')
   	THEN

               l_lane_id_tab(k)       := p_lane_sched_id_tab(i);
               l_service_lane_tab(k)  := p_service_type_tab(i);
               l_lane_xref(k)         := i; -- xref to input index
               k:=k+1;


   	ELSIF(p_lane_sched_tab(i)='S')
   	THEN

               l_sched_id_tab(l)       := p_lane_sched_id_tab(i);
               l_service_sched_tab(l)  := p_service_type_tab(i);
               l_sched_xref(l)         := i; -- xref to input index
               l:=l+1;

   	END IF;

   	i:=p_lane_sched_tab.NEXT(i);
   END LOOP;

	OPEN c_get_req_id;
	FETCH c_get_req_id INTO l_request_id;
	CLOSE c_get_req_id;
	x_request_id := l_request_id;


   -- Call new internal API


    shipment_price_compare_pvt (
        p_delivery_id             =>     p_delivery_id,
        p_trip_id                 =>     NULL,
        p_lane_id_tab             =>     l_lane_id_tab,
        p_sched_id_tab            =>     l_sched_id_tab,
        p_service_lane_tab        =>     l_service_lane_tab,
        p_service_sched_tab       =>     l_service_sched_tab,
        p_dep_date                =>     p_dep_date,
        p_arr_date                =>     p_arr_date,
        x_sum_lane_price_tab      =>     l_sum_lane_price_tab,
        x_sum_lane_price_curr_tab =>     l_sum_lane_price_curr_tab,
        x_sum_sched_price_tab     =>     l_sum_sched_price_tab,
        x_sum_sched_price_curr_tab =>    l_sum_sched_price_curr_tab,
        x_request_id              =>     l_request_id,
        x_return_status           =>     l_return_status );

     x_request_id   := l_request_id;

	 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_return_status='||l_return_status);

	 IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
		  raise fte_freight_pricing_util.g_unexp_err;
	 ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN
		  --raise fte_freight_pricing_util.g_ship_prc_compare_fail;
		  --In case of expected errors in shipment_price_compare_pvt
		  ---Allow this procedure to continue to TL if necessary
		  x_return_status := l_return_status;
		  l_warn_flag := 'Y';

	 ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN

		  x_return_status := l_return_status;
		  l_warn_flag := 'Y';
	 END IF;



      	IF (l_tl_lane_rows.COUNT > 0)
      	THEN

		--Delivery validation is already handled by shipment_price_compare_pvt


       		FTE_TL_RATING.Get_Vehicles_For_LaneSchedules(
			p_trip_id	=>NULL,
			p_lane_rows	=>l_tl_lane_rows,
			p_schedule_rows =>l_tl_schedule_rows,
			p_vehicle_rows	=>l_tl_vehicle_rows,
			x_vehicle_rows  =>l_exploded_vehicle_rows,
			x_lane_rows 	=>l_exploded_lane_rows,
			x_schedule_rows =>l_exploded_schedule_rows,
			x_ref_rows	=>l_exploded_ref_rows,
			x_return_status =>l_return_status);

	      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      	THEN
		 	IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
		 	THEN
		    		raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
	      		END IF;
	      	END IF;





      		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>6');

		FTE_TL_RATING.TL_DELIVERY_PRICE_COMPARE(
			p_wsh_delivery_id=>p_delivery_id,
			p_lane_rows=>l_exploded_lane_rows,
			p_schedule_rows=>l_exploded_schedule_rows,
			p_vehicle_rows=>l_exploded_vehicle_rows,
			p_dep_date=>p_dep_date,
			p_arr_date=>p_arr_date,
			p_pickup_location_id=>p_pickup_location_id,
			p_dropoff_location_id=>p_dropoff_location_id,
			x_request_id=>l_request_id,
			x_lane_sched_sum_rows=>l_tl_lane_sched_sum_rows,
			x_lane_sched_curr_rows=>l_tl_lane_sched_curr_rows,
			x_return_status=>l_return_status);


              -- Error checking here
              -- For now only unexpected errors returned cause this procedure to fail
              -- However, we can go more granular, and fail even on certain
              -- errors caused in the child procedures

	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_return_status='||l_return_status);
		      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		      THEN
			 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
			 THEN
			    raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
			 ELSE
			  --In case of expected errors
			  ---Allow this procedure to continue if necessary
				l_warn_flag := 'Y';
		         END IF;
		       END IF;
	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_tl_lane_sched_sum_rows.COUNT='||l_tl_lane_sched_sum_rows.COUNT);


	END IF;


---Recombine results





      l_output_count:=p_lane_sched_id_tab.COUNT;
      IF (l_tl_lane_rows.COUNT > 0)
      THEN
      	l_output_count:=l_output_count+ l_exploded_ref_rows.COUNT-l_tl_lane_rows.COUNT;
      END IF;

      -- initialize output nested tables
      IF (p_lane_sched_id_tab.COUNT > 0 )
      THEN

      	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Init op tables');

	      x_sum_rate_tab := FTE_ID_TAB_TYPE(0);
	      x_sum_rate_curr_tab := FTE_CODE_TAB_TYPE('NULL');
	      -- init all elements  the tables with 0 and 'NULL' resp.

	      x_lane_sched_id_tab:=FTE_ID_TAB_TYPE(0);
	      x_lane_sched_tab:=FTE_CODE_TAB_TYPE('NULL');
	      x_vehicle_type_tab:=FTE_ID_TAB_TYPE(0);
	      x_mode_tab:=FTE_CODE_TAB_TYPE('NULL');
	      x_service_type_tab:=FTE_CODE_TAB_TYPE('NULL');


	      x_sum_rate_tab.EXTEND(l_output_count-1,1);
	      x_sum_rate_curr_tab.EXTEND(l_output_count-1,1);

	      x_lane_sched_id_tab.EXTEND(l_output_count-1,1);
	      x_lane_sched_tab.EXTEND(l_output_count-1,1);
	      x_vehicle_type_tab.EXTEND(l_output_count-1,1);
	      x_mode_tab.EXTEND(l_output_count-1,1);
	      x_service_type_tab.EXTEND(l_output_count-1,1);

	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Init op tables End');

      END IF;



      L :=l_sum_lane_price_tab.FIRST;
      S:=l_sum_sched_price_tab.FIRST;
      j:=l_tl_lane_rows.FIRST;
      i:=p_lane_sched_id_tab.FIRST;
      k:=x_sum_rate_tab.FIRST;
      l_ref:=l_exploded_ref_rows.FIRST;

      WHILE(k<=l_output_count)
      LOOP
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Op index:'||k);

         IF (p_mode_tab(i) <> 'TRUCK' )
         THEN
           IF (p_lane_sched_tab(i) = 'L')
           THEN

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Lane:');
               IF ((l_sum_lane_price_tab.EXISTS(L)) AND (l_sum_lane_price_curr_tab.EXISTS(L)))
	       THEN
		       x_sum_rate_tab(k)      := l_sum_lane_price_tab(L);
		       x_sum_rate_curr_tab(k) := l_sum_lane_price_curr_tab(L);
	       END IF;

	       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
	       x_lane_sched_tab(k):=p_lane_sched_tab(i);
	       x_vehicle_type_tab(k):=p_vehicle_type_tab(i);
	       x_mode_tab(k):=p_mode_tab(i);
	       x_service_type_tab(k):=p_service_type_tab(i);


               L := L + 1;
               k:=k+1;

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Lane ENd:');

           ELSIF (p_lane_sched_tab(i) = 'S')
           THEN

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Schedule:');

               IF ((l_sum_sched_price_tab.EXISTS(S)) AND (l_sum_sched_price_curr_tab.EXISTS(S)))
	       THEN

		       x_sum_rate_tab(k)      := l_sum_sched_price_tab(S);
		       x_sum_rate_curr_tab(k) := l_sum_sched_price_curr_tab(S);
	       END IF;

	       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
	       x_lane_sched_tab(k):=p_lane_sched_tab(i);
	       x_vehicle_type_tab(k):=p_vehicle_type_tab(i);
	       x_mode_tab(k):=p_mode_tab(i);
	       x_service_type_tab(k):=p_service_type_tab(i);



               S := S + 1;
               k:=k+1;

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Schedule End:');

           END IF;

         ELSIF (p_mode_tab(i) = 'TRUCK' )
         THEN

              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL :');
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_ref'||l_ref);
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'j'||j);
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_exploded_ref_rows count'||l_exploded_ref_rows.COUNT);

	       WHILE(l_exploded_ref_rows.EXISTS(l_ref) AND l_exploded_ref_rows(l_ref)=j)
	       LOOP

		      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_exploded_ref_rows(l_ref)'||l_exploded_ref_rows(l_ref));

		      --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_tl_lane_sched_sum_rows(l_ref)'||l_tl_lane_sched_sum_rows(l_ref));

	       	       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 1:');
	       	       x_sum_rate_tab(k):=-1;
		       IF (l_tl_lane_sched_sum_rows.EXISTS(l_ref))
		       THEN
			x_sum_rate_tab(k)       := nvl(l_tl_lane_sched_sum_rows(l_ref),-1);
		       END IF;

		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 2:');
		       x_sum_rate_curr_tab(k):='NULL';
		       IF(l_tl_lane_sched_curr_rows.EXISTS(l_ref))
		       THEN
			x_sum_rate_curr_tab(k)  := nvl(l_tl_lane_sched_curr_rows(l_ref),'NULL');
		       END IF;
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 3:');

		       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 4:');
		       x_lane_sched_tab(k):=p_lane_sched_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 5:');
		       IF (l_exploded_vehicle_rows.EXISTS(l_ref))
		       THEN
			x_vehicle_type_tab(k):=l_exploded_vehicle_rows(l_ref);
		       END IF;
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 6:');
		       x_mode_tab(k):=p_mode_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 7:');
		       x_service_type_tab(k):=p_service_type_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 8:');

                  --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  --' '||l_ref||'-'||i||'-'||l_lane_sched_sum_rows(l_ref)||'-'||l_lane_sched_curr_rows(l_ref));


		       k:=k+1;

		       l_ref:=l_ref+1;
	       END LOOP;

	   j := j + 1;

	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL End:');

	 END IF;


      	i:=i+1;
      END LOOP;



      IF (x_sum_rate_tab.COUNT > 0) THEN
	      FOR i IN x_sum_rate_tab.FIRST .. x_sum_rate_tab.LAST
	      LOOP
		      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
		       ' '||x_lane_sched_id_tab(i)||' '||x_lane_sched_tab(i)||' '||x_mode_tab(i)||' '||x_service_type_tab(i)||' '
		     ||x_vehicle_type_tab(i)||' '||x_sum_rate_tab(i)||' '||x_sum_rate_curr_tab(i) );
	      END LOOP;
      END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'warn flag'||l_warn_flag);

	 IF (l_warn_flag = 'Y' ) THEN
		   -- bug 2762257
		   FTE_FREIGHT_PRICING_UTIL.set_price_comp_exit_warn;
		   --Added to ensure return status is warning if l_warn_flag=Y
		   x_return_status :=WSH_UTIL_CORE.G_RET_STS_WARNING;
	 END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBg.2');
	 x_request_id := l_request_id;
FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBg.3');

   COMMIT;  --  Commit Autonomous transaction

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBg.4');
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare');
   IF(p_init_prc_log='Y')
   THEN
	FTE_FREIGHT_PRICING_UTIL.close_logs;
   END IF;




EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_ship_prc_compare_fail THEN
        ROLLBACK; -- TO SHIPMENT_PRICE_COMPARE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


   WHEN FTE_FREIGHT_PRICING_UTIL.g_unexp_err THEN
        ROLLBACK; -- TO SHIPMENT_PRICE_COMPARE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_compare','g_others');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;

   WHEN others THEN
        ROLLBACK; -- TO SHIPMENT_PRICE_COMPARE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('shipment_price_compare','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'shipment_price_compare');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


END shipment_price_compare;


END FTE_FREIGHT_PRICING;


/
