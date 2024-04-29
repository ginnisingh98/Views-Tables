--------------------------------------------------------
--  DDL for Package Body FTE_FREIGHT_RATING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FREIGHT_RATING_PUB" AS
/*$Header: FTEFRPBB.pls 120.3 2007/11/30 05:48:22 sankarun ship $ */

   G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_FREIGHT_RATING_PUB';

-- Private Package level Variables


    TYPE rate_rec_type IS RECORD
    (
               price           NUMBER,        -- including discount
               charge          NUMBER,        -- total charges
               currency        VARCHAR2(10),
               qty             NUMBER,
               uom             VARCHAR2(10)
    );

   TYPE rate_tab_type IS TABLE OF rate_rec_type INDEX BY BINARY_INTEGER;

   CURSOR c_get_ship_method_code (c_carrier_id VARCHAR2, c_mode_of_trans VARCHAR2, c_service_level VARCHAR2, c_org_id NUMBER) IS
   SELECT a.ship_method_code
   FROM wsh_carrier_services a, wsh_org_carrier_services b
   WHERE a.carrier_service_id = b.carrier_service_id
     AND b.organization_id = c_org_id
     AND b.enabled_flag = 'Y'
     AND a.enabled_flag = 'Y'
     AND a.mode_of_transport = c_mode_of_trans
     AND a.service_level = c_service_level
     AND a.carrier_id = c_carrier_id;

   CURSOR c_get_carrier_freight_code (c_carrier_id VARCHAR2) IS
   SELECT freight_code
   FROM   wsh_carriers
   WHERE carrier_id = c_carrier_id;

   CURSOR c_get_generic_carrier_flag (c_carrier_id VARCHAR2) IS
   SELECT generic_flag
   FROM   wsh_carriers
   WHERE carrier_id = c_carrier_id;

   CURSOR c_get_generic_carrier_flag2 (c_ship_method_code VARCHAR2) IS
   SELECT a.generic_flag
   FROM   wsh_carriers a, wsh_carrier_services b
   WHERE a.carrier_id = b.carrier_id
     AND b.ship_method_code = c_ship_method_code;

   CURSOR  c_carrier_services(c_shp_mthd_cd VARCHAR2)
   IS
   SELECT ship_method_code,carrier_id, service_level, mode_of_transport, ship_method_meaning
   FROM   wsh_carrier_services
   WHERE  ship_method_code = c_shp_mthd_cd;

   PROCEDURE convert_amount(
     	p_from_currency		IN VARCHAR2,
     	p_from_amount		IN NUMBER,
	p_conversion_type	IN VARCHAR2,
     	p_to_currency		IN VARCHAR2,
	x_to_amount		OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2)
   IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'convert_amount';
     l_conversion_type VARCHAR2(30);
   BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(l_log_level,'p_from_currency= '||p_from_currency);
     fte_freight_pricing_util.print_msg(l_log_level,'p_from_amount= '||p_from_amount);
     fte_freight_pricing_util.print_msg(l_log_level,'p_conversion_type= '||p_conversion_type);
     fte_freight_pricing_util.print_msg(l_log_level,'p_to_currency= '||p_to_currency);

     IF p_conversion_type is null THEN
       l_conversion_type := 'Corporate';
     ELSE
       l_conversion_type := p_conversion_type;
     END IF;
     fte_freight_pricing_util.print_msg(l_log_level,'l_conversion_type= '||l_conversion_type);

     x_to_amount := GL_CURRENCY_API.convert_amount(
                                     p_from_currency,
                                     p_to_currency,
                                     SYSDATE,
                                     l_conversion_type,
                                     p_from_amount
                                     );

     fte_freight_pricing_util.print_msg(l_log_level,'x_to_amount= '||x_to_amount);

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level, l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   END convert_amount;

   PROCEDURE print_rates_tab (
     p_source_line_rates_tab IN FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
     p_source_header_rates_tab IN FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
     x_return_status         OUT NOCOPY  VARCHAR2)
   IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'print_rates_tab';
     i NUMBER;
   BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-----------BEGIN Source Line Rates Tab -------------');

    i := p_source_line_rates_tab.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I = '||i);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'source_line_id = '||p_source_line_rates_tab(i).source_line_id);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'cost_type_id = '||p_source_line_rates_tab(i).cost_type_id);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'line_type_code = '||p_source_line_rates_tab(i).line_type_code);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'cost_type = '||p_source_line_rates_tab(i).cost_type);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'cost_sub_type = '||p_source_line_rates_tab(i).cost_sub_type);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'priced_quantity = '||p_source_line_rates_tab(i).priced_quantity);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'priced_uom = '||p_source_line_rates_tab(i).priced_uom);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'unit_price = '||p_source_line_rates_tab(i).unit_price);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'base_price = '||p_source_line_rates_tab(i).base_price);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'adjusted_unit_price = '||p_source_line_rates_tab(i).adjusted_unit_price);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'adjusted_price = '||p_source_line_rates_tab(i).adjusted_price);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'currency = '||p_source_line_rates_tab(i).currency);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'consolidation_id = '||p_source_line_rates_tab(i).consolidation_id);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'lane_id = '||p_source_line_rates_tab(i).lane_id);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'carrier_id = '||p_source_line_rates_tab(i).carrier_id);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'carrier_freight_code = '||p_source_line_rates_tab(i).carrier_freight_code);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'service_level = '||p_source_line_rates_tab(i).service_level);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'mode_of_transport = '||p_source_line_rates_tab(i).mode_of_transport);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'ship_method_code = '||p_source_line_rates_tab(i).ship_method_code);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'vehicle_type_id = '||p_source_line_rates_tab(i).vehicle_type_id);
     fte_freight_pricing_util.print_msg(l_log_level,'------------------------');

    EXIT WHEN (i >= p_source_line_rates_tab.LAST);
    i := p_source_line_rates_tab.NEXT(i);
    END LOOP;
    END IF;

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-----------BEGIN Source header Rates Tab -------------');

    i := p_source_header_rates_tab.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
     fte_freight_pricing_util.print_msg(l_log_level,'I = '||i);
     fte_freight_pricing_util.print_msg(l_log_level,'consolidation_id = '||p_source_header_rates_tab(i).consolidation_id);
     fte_freight_pricing_util.print_msg(l_log_level,'lane_id = '||p_source_header_rates_tab(i).lane_id);
     fte_freight_pricing_util.print_msg(l_log_level,'carrier_id = '||p_source_header_rates_tab(i).carrier_id);
     fte_freight_pricing_util.print_msg(l_log_level,'carrier_freight_code = '||p_source_header_rates_tab(i).carrier_freight_code);
     fte_freight_pricing_util.print_msg(l_log_level,'service_level = '||p_source_header_rates_tab(i).service_level);
     fte_freight_pricing_util.print_msg(l_log_level,'mode_of_transport = '||p_source_header_rates_tab(i).mode_of_transport);
     fte_freight_pricing_util.print_msg(l_log_level,'ship_method_code = '||p_source_header_rates_tab(i).ship_method_code);
     fte_freight_pricing_util.print_msg(l_log_level,'vehicle_type_id = '||p_source_header_rates_tab(i).vehicle_type_id);
     fte_freight_pricing_util.print_msg(l_log_level,'cost_type_id = '||p_source_header_rates_tab(i).cost_type_id);
     fte_freight_pricing_util.print_msg(l_log_level,'cost_type = '||p_source_header_rates_tab(i).cost_type);
     fte_freight_pricing_util.print_msg(l_log_level,'price = '||p_source_header_rates_tab(i).price);
     fte_freight_pricing_util.print_msg(l_log_level,'currency = '||p_source_header_rates_tab(i).currency);
     fte_freight_pricing_util.print_msg(l_log_level,'transit_time = '||p_source_header_rates_tab(i).transit_time);
     fte_freight_pricing_util.print_msg(l_log_level,'transit_time_uom = '||p_source_header_rates_tab(i).transit_time_uom);
     fte_freight_pricing_util.print_msg(l_log_level,'first_line_index = '||p_source_header_rates_tab(i).first_line_index);
     fte_freight_pricing_util.print_msg(l_log_level,'------------------------');

    EXIT WHEN (i >= p_source_header_rates_tab.LAST);
    i := p_source_header_rates_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'----   END Source header Rates Tab ------- ');

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level, l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   END print_rates_tab;

  PROCEDURE print_matched_services (
    p_matched_services  IN lane_info_tab_type,
    x_return_status  OUT NOCOPY VARCHAR2)
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'print_matched_services';
     i NUMBER;
  BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN Matched Services Tab -------------');

    i := p_matched_services.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
fte_freight_pricing_util.print_msg(l_log_level,'i = '||i);
fte_freight_pricing_util.print_msg(l_log_level,'lane_id = '||p_matched_services(i).lane_id);
fte_freight_pricing_util.print_msg(l_log_level,'carrier_id = '||p_matched_services(i).carrier_id);
fte_freight_pricing_util.print_msg(l_log_level,'carrier_freight_code = '||p_matched_services(i).carrier_freight_code);
fte_freight_pricing_util.print_msg(l_log_level,'mode_of_transport_code = '||p_matched_services(i).mode_of_transportation_code);
fte_freight_pricing_util.print_msg(l_log_level,'service_type_code = '||p_matched_services(i).service_type_code);
fte_freight_pricing_util.print_msg(l_log_level,'ship_method_code = '||p_matched_services(i).ship_method_code);
fte_freight_pricing_util.print_msg(l_log_level,'pricelist_id = '||p_matched_services(i).pricelist_id);
fte_freight_pricing_util.print_msg(l_log_level,'origin_id = '||p_matched_services(i).origin_id);
fte_freight_pricing_util.print_msg(l_log_level,'destination_id = '||p_matched_services(i).destination_id);
fte_freight_pricing_util.print_msg(l_log_level,'basis = '||p_matched_services(i).basis);
fte_freight_pricing_util.print_msg(l_log_level,'commodity_catg_id = '||p_matched_services(i).commodity_catg_id);
fte_freight_pricing_util.print_msg(l_log_level,'classification_code = '||p_matched_services(i).classification_code);
fte_freight_pricing_util.print_msg(l_log_level,'transit_time = '||p_matched_services(i).transit_time);
fte_freight_pricing_util.print_msg(l_log_level,'transit_time_uom = '||p_matched_services(i).transit_time_uom);
     fte_freight_pricing_util.print_msg(l_log_level,'------------------------');

    EXIT WHEN (i >= p_matched_services.LAST);
    i := p_matched_services.NEXT(i);
    END LOOP;
    END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END print_matched_services;

  PROCEDURE print_source_line_tab (
    p_source_line_tab  IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
    x_return_status  OUT NOCOPY VARCHAR2)
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'print_source_line_tab';
     i NUMBER;
  BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN Source Line Tab -------------');

    i := p_source_line_tab.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'i := '||i);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).source_type :='||p_source_line_tab(i).source_type);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).source_header_id :='||p_source_line_tab(i).source_header_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).source_line_id :='||p_source_line_tab(i).source_line_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_from_org_id :='||p_source_line_tab(i).ship_from_org_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_from_location_id :='||p_source_line_tab(i).ship_from_location_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_to_site_id :='||p_source_line_tab(i).ship_to_site_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_to_location_id :='||p_source_line_tab(i).ship_to_location_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).customer_id :='||p_source_line_tab(i).customer_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).inventory_item_id :='||p_source_line_tab(i).inventory_item_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).source_quantity :='||p_source_line_tab(i).source_quantity);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).source_quantity_uom :='||p_source_line_tab(i).source_quantity_uom);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_date :='||p_source_line_tab(i).ship_date);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).arrival_date :='||p_source_line_tab(i).arrival_date);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).delivery_lead_time :='||p_source_line_tab(i).delivery_lead_time);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).scheduled_flag :='||p_source_line_tab(i).scheduled_flag);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).order_set_type :='||p_source_line_tab(i).order_set_type);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).order_set_id :='||p_source_line_tab(i).order_set_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).intmed_ship_to_site_id :='||p_source_line_tab(i).intmed_ship_to_site_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).intmed_ship_to_loc_id :='||p_source_line_tab(i).intmed_ship_to_loc_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).carrier_id :='||p_source_line_tab(i).carrier_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_method_flag :='||p_source_line_tab(i).ship_method_flag);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).ship_method_code :='||p_source_line_tab(i).ship_method_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).freight_carrier_code :='||p_source_line_tab(i).freight_carrier_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).service_level :='||p_source_line_tab(i).service_level);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).mode_of_transport :='||p_source_line_tab(i).mode_of_transport);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).freight_terms :='||p_source_line_tab(i).freight_terms);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).fob_code :='||p_source_line_tab(i).fob_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).weight  :='||p_source_line_tab(i).weight );
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).weight_uom_code :='||p_source_line_tab(i).weight_uom_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).volume  :='||p_source_line_tab(i).volume );
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).volume_uom_code :='||p_source_line_tab(i).volume_uom_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).freight_rating_flag :='||p_source_line_tab(i).freight_rating_flag);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).freight_rate :='||p_source_line_tab(i).freight_rate);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).freight_rate_currency :='||p_source_line_tab(i).freight_rate_currency);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).status  :='||p_source_line_tab(i).status );
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).message_data :='||p_source_line_tab(i).message_data);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).consolidation_id :='||p_source_line_tab(i).consolidation_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).override_ship_method :='||p_source_line_tab(i).override_ship_method);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).currency :='||p_source_line_tab(i).currency);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).currency_conversion_type :='||p_source_line_tab(i).currency_conversion_type);


fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).origin_country :='||p_source_line_tab(i).origin_country);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).origin_state :='||p_source_line_tab(i).origin_state);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).origin_city :='||p_source_line_tab(i).origin_city);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).origin_zip :='||p_source_line_tab(i).origin_zip);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).destination_country :='||p_source_line_tab(i).destination_country);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).destination_state :='||p_source_line_tab(i).destination_state);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).destination_city :='||p_source_line_tab(i).destination_city);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).destination_zip :='||p_source_line_tab(i).destination_zip);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).distance :='||p_source_line_tab(i).distance);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).distance_uom :='||p_source_line_tab(i).distance_uom);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).vehicle_item_id :='||p_source_line_tab(i).vehicle_item_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_line_tab(i).commodity_category_id :='||p_source_line_tab(i).commodity_category_id);


     fte_freight_pricing_util.print_msg(l_log_level,'------------------------');

    EXIT WHEN (i >= p_source_line_tab.LAST);
    i := p_source_line_tab.NEXT(i);
    END LOOP;
    END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END print_source_line_tab;

  PROCEDURE print_source_header_tab (
    p_source_header_tab IN FTE_PROCESS_REQUESTS.fte_source_header_tab,
    x_return_status  OUT NOCOPY VARCHAR2)
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'print_source_header_tab';
     i NUMBER;
  BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-----------BEGIN Source Header Tab -------------');

    i := p_source_header_tab.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'i := '||i);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).consolidation_id :='||p_source_header_tab(i).consolidation_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_from_org_id :='||p_source_header_tab(i).ship_from_org_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_from_location_id :='||p_source_header_tab(i).ship_from_location_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_to_location_id :='||p_source_header_tab(i).ship_to_location_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_to_site_id :='||p_source_header_tab(i).ship_to_site_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).customer_id :='||p_source_header_tab(i).customer_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_date :='||p_source_header_tab(i).ship_date);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).arrival_date :='||p_source_header_tab(i).arrival_date);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).delivery_lead_time :='||p_source_header_tab(i).delivery_lead_time);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).scheduled_flag :='||p_source_header_tab(i).scheduled_flag);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).total_weight :='||p_source_header_tab(i).total_weight);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).weight_uom_code :='||p_source_header_tab(i).weight_uom_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).total_volume :='||p_source_header_tab(i).total_volume);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).volume_uom_code :='||p_source_header_tab(i).volume_uom_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).ship_method_code :='||p_source_header_tab(i).ship_method_code);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).carrier_id :='||p_source_header_tab(i).carrier_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).service_level :='||p_source_header_tab(i).service_level);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).mode_of_transport :='||p_source_header_tab(i).mode_of_transport);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).freight_terms :='||p_source_header_tab(i).freight_terms);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).status  :='||p_source_header_tab(i).status );
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).message_data :='||p_source_header_tab(i).message_data);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).enforce_lead_time :='||p_source_header_tab(i).enforce_lead_time);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).currency :='||p_source_header_tab(i).currency);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).currency_conversion_type :='||p_source_header_tab(i).currency_conversion_type);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).origin_country :='||p_source_header_tab(i).origin_country);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).origin_state :='||p_source_header_tab(i).origin_state);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).origin_city :='||p_source_header_tab(i).origin_city);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).origin_zip :='||p_source_header_tab(i).origin_zip);


fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).destination_country :='||p_source_header_tab(i).destination_country);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).destination_state :='||p_source_header_tab(i).destination_state);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).destination_city :='||p_source_header_tab(i).destination_city);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).destination_zip :='||p_source_header_tab(i).destination_zip);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).distance :='||p_source_header_tab(i).distance);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).distance_uom :='||p_source_header_tab(i).distance_uom);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).vehicle_item_id :='||p_source_header_tab(i).vehicle_item_id);
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_source_header_tab(i).commodity_category_id :='||p_source_header_tab(i).commodity_category_id);


     fte_freight_pricing_util.print_msg(l_log_level,'------------------------');


    EXIT WHEN (i >= p_source_header_tab.LAST);
    i := p_source_header_tab.NEXT(i);
    END LOOP;
    END IF;


   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_source_header_tab;

PROCEDURE populate_rate (
  p_source_header_rec		IN 	      FTE_PROCESS_REQUESTS.fte_source_header_rec,
  p_service_rec  		IN	      lane_info_rec_type,
  p_lane_rate			IN	      NUMBER,
  p_lane_rate_uom		IN	      VARCHAR2,
  p_fc_temp_price         	IN 	      FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
  p_fc_temp_charge        	IN 	      FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
  x_source_line_rates_tab 	IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab 	IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_return_status     		OUT NOCOPY  VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'POPULATE_RATE';
  l_return_status         VARCHAR2(1);

  i                         NUMBER:=0;
  j                         NUMBER:=0;
  k                         NUMBER:=0;
  ii			    NUMBER;
  jj			    NUMBER;
  l_found_group		    BOOLEAN;
  l_need_move		    BOOLEAN;
  l_converted_amount	    NUMBER;
  l_target_currency	    VARCHAR2(10);
  l_cost_type_code          WSH_FREIGHT_COST_TYPES.freight_cost_type_code%TYPE;
  l_sub_type_code           WSH_FREIGHT_COST_TYPES.name%TYPE;

  l_charge_tab    rate_tab_type;
  l_rate_tab      rate_tab_type;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  IF p_source_header_rec.currency is NULL THEN
    l_target_currency := 'USD';
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'source header currency is null, use USD');
  ELSE
    l_target_currency := p_source_header_rec.currency;
  END IF;
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'target currency is '||l_target_currency);

  IF (p_lane_rate_uom <> l_target_currency) THEN
    convert_amount(
     		p_from_currency		=>p_lane_rate_uom,
     		p_from_amount		=>p_lane_rate,
		p_conversion_type	=>p_source_header_rec.currency_conversion_type,
     		p_to_currency		=>l_target_currency,
		x_to_amount		=>l_converted_amount,
		x_return_status		=> l_return_status);

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'currency_conversion_failed');
		raise FND_API.G_EXC_ERROR;
	      END IF;

  ELSE
		l_converted_amount := p_lane_rate;
  END IF;
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'convert p_lane_rate '||p_lane_rate||' to l_converted_amount='||l_converted_amount);

      i := x_source_line_rates_tab.COUNT;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source line rates records is '||i);

      ii := x_source_header_rates_tab.COUNT;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source header rates records is '||ii);

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'in this sorted header_rates_tab finding the right position for the current header rate...');

      l_found_group := false;
      l_need_move := false;

      IF ii > 0 THEN
	jj:= x_source_header_rates_tab.FIRST;
	LOOP
	  IF (x_source_header_rates_tab(jj).consolidation_id = p_source_header_rec.consolidation_id) THEN

	    l_found_group := true;

	    IF (l_converted_amount < x_source_header_rates_tab(jj).price) THEN
	      l_need_move := true;
  	      EXIT; -- out of the loop
	    END IF;

	  ELSE -- not the same group
	    IF (l_found_group) THEN
	      l_need_move := true;
  	      EXIT; -- out of the loop
	    END IF;
	  END IF;

	  IF (jj = x_source_header_rates_tab.LAST) THEN
	    jj := jj +1;
	    EXIT; -- out of the loop
	  ELSE
	    jj := x_source_header_rates_tab.NEXT(jj);
	  END IF;
	END LOOP;
      ELSE -- ii <= 0
	jj := 1;
      END IF; -- ii > 0

      IF (l_need_move) THEN
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move source_header_rates_tab ('||jj||', '||x_source_header_rates_tab.LAST||' ) one records up.. ');
	FOR ii IN REVERSE jj..x_source_header_rates_tab.LAST LOOP
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move ii='|| ii||' one record up...');
	  x_source_header_rates_tab(ii+1).consolidation_id := x_source_header_rates_tab(ii).consolidation_id;
	  x_source_header_rates_tab(ii+1).lane_id := x_source_header_rates_tab(ii).lane_id;
	  x_source_header_rates_tab(ii+1).carrier_id := x_source_header_rates_tab(ii).carrier_id;
	  x_source_header_rates_tab(ii+1).carrier_freight_code := x_source_header_rates_tab(ii).carrier_freight_code;
	  x_source_header_rates_tab(ii+1).service_level := x_source_header_rates_tab(ii).service_level;
	  x_source_header_rates_tab(ii+1).mode_of_transport := x_source_header_rates_tab(ii).mode_of_transport;
	  x_source_header_rates_tab(ii+1).ship_method_code := x_source_header_rates_tab(ii).ship_method_code;
	  x_source_header_rates_tab(ii+1).cost_type_id := x_source_header_rates_tab(ii).cost_type_id;
	  x_source_header_rates_tab(ii+1).cost_type := x_source_header_rates_tab(ii).cost_type;
	  x_source_header_rates_tab(ii+1).price := x_source_header_rates_tab(ii).price;
	  x_source_header_rates_tab(ii+1).currency := x_source_header_rates_tab(ii).currency;
	  x_source_header_rates_tab(ii+1).transit_time := x_source_header_rates_tab(ii).transit_time;
	  x_source_header_rates_tab(ii+1).transit_time_uom := x_source_header_rates_tab(ii).transit_time_uom;
	  x_source_header_rates_tab(ii+1).first_line_index := x_source_header_rates_tab(ii).first_line_index;
	END LOOP;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating jj '|| jj || ' with current header rates...');

      x_source_header_rates_tab(jj).consolidation_id := p_source_header_rec.consolidation_id;
      x_source_header_rates_tab(jj).lane_id := p_service_rec.lane_id;
      x_source_header_rates_tab(jj).carrier_id := p_service_rec.carrier_id;
      x_source_header_rates_tab(jj).carrier_freight_code := p_service_rec.carrier_freight_code;
      x_source_header_rates_tab(jj).service_level := p_service_rec.service_type_code;
      x_source_header_rates_tab(jj).mode_of_transport := p_service_rec.mode_of_transportation_code;
      x_source_header_rates_tab(jj).ship_method_code := p_service_rec.ship_method_code;
      x_source_header_rates_tab(jj).cost_type_id := null;
      x_source_header_rates_tab(jj).cost_type := 'SUMMARY';
      x_source_header_rates_tab(jj).price := l_converted_amount;
      x_source_header_rates_tab(jj).currency := l_target_currency;
      x_source_header_rates_tab(jj).transit_time := p_service_rec.transit_time;
      x_source_header_rates_tab(jj).transit_time_uom := p_service_rec.transit_time_uom;
      x_source_header_rates_tab(jj).first_line_index := i+1;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 1 ');
      j := p_fc_temp_price.FIRST;
      IF (j IS NOT NULL) THEN
      -- {
      LOOP
         -- {
           IF (p_fc_temp_price(j).line_type_code = 'PRICE') THEN
          -- {
               -- store for later

  	     IF (p_fc_temp_price(j).currency_code <> l_target_currency) THEN
    	       convert_amount(
     		p_from_currency		=>p_fc_temp_price(j).currency_code,
     		p_from_amount		=>p_fc_temp_price(j).unit_amount,
		p_conversion_type	=>p_source_header_rec.currency_conversion_type,
     		p_to_currency		=>l_target_currency,
		x_to_amount		=>l_converted_amount,
		x_return_status		=> l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'currency_conversion_failed');
		raise FND_API.G_EXC_ERROR;
	       END IF;

  	     ELSE
		l_converted_amount := p_fc_temp_price(j).unit_amount;
  	     END IF;
  	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'convert p_fc_temp_price(j).unit_amount '||p_fc_temp_price(j).unit_amount||' to l_converted_amount='||l_converted_amount);

               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).price := l_converted_amount ;   -- including discount
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).charge := 0;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).currency := l_target_currency ;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).qty := p_fc_temp_price(j).quantity ;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).uom := p_fc_temp_price(j).uom ;

             i := i + 1;
             x_source_line_rates_tab(i).source_line_id := p_fc_temp_price(j).delivery_detail_id;
             x_source_line_rates_tab(i).cost_type_id   := p_fc_temp_price(j).freight_cost_type_id;
             x_source_line_rates_tab(i).line_type_code := p_fc_temp_price(j).line_type_code;

             x_source_line_rates_tab(i).cost_type      := 'FTEPRICE';
             x_source_line_rates_tab(i).cost_sub_type  := 'PRICE';

             x_source_line_rates_tab(i).priced_quantity    := p_fc_temp_price(j).quantity;
             x_source_line_rates_tab(i).priced_uom     := p_fc_temp_price(j).uom;
             x_source_line_rates_tab(i).adjusted_unit_price    := (l_converted_amount)/(p_fc_temp_price(j).quantity) ;   -- adjusted unit price
             x_source_line_rates_tab(i).adjusted_price    := l_converted_amount ;   -- adjusted unit price (including discount)
             x_source_line_rates_tab(i).currency := l_target_currency;

  	     IF (p_fc_temp_price(j).currency_code <> l_target_currency) THEN
    	       convert_amount(
     		p_from_currency		=>p_fc_temp_price(j).currency_code,
     		p_from_amount		=>p_fc_temp_price(j).charge_unit_value,
		p_conversion_type	=>p_source_header_rec.currency_conversion_type,
     		p_to_currency		=>l_target_currency,
		x_to_amount		=>l_converted_amount,
		x_return_status		=> l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'currency_conversion_failed');
		raise FND_API.G_EXC_ERROR;
	       END IF;

  	     ELSE
		l_converted_amount := p_fc_temp_price(j).charge_unit_value;
  	     END IF;
  	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'convert p_fc_temp_price(j).charge_unit_value '||p_fc_temp_price(j).charge_unit_value||' to l_converted_amount='||l_converted_amount);

             x_source_line_rates_tab(i).unit_price     := l_converted_amount;
             x_source_line_rates_tab(i).base_price     := l_converted_amount * p_fc_temp_price(j).quantity;

             x_source_line_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
             x_source_line_rates_tab(i).lane_id := p_service_rec.lane_id;
      	     x_source_line_rates_tab(i).carrier_id := p_service_rec.carrier_id;
             x_source_line_rates_tab(i).carrier_freight_code := p_service_rec.carrier_freight_code;
             x_source_line_rates_tab(i).service_level := p_service_rec.service_type_code;
             x_source_line_rates_tab(i).mode_of_transport := p_service_rec.mode_of_transportation_code;
             x_source_line_rates_tab(i).ship_method_code := p_service_rec.ship_method_code;

         -- }
          END IF;

         EXIT WHEN ( j >= p_fc_temp_price.LAST);
         j := p_fc_temp_price.NEXT(j);
         -- }
      END LOOP;
      -- }
      END IF;


      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 2 ');
      -- sum up charges by source_line_id
      j := p_fc_temp_charge.FIRST;
      IF (j IS NOT NULL) THEN
      LOOP
          IF (p_fc_temp_charge(j).line_type_code = 'CHARGE') THEN

               IF l_charge_tab.EXISTS(p_fc_temp_charge(j).delivery_detail_id) THEN
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge := l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge + p_fc_temp_charge(j).total_amount;
               ELSE
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge := p_fc_temp_charge(j).total_amount;
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).currency := p_fc_temp_charge(j).currency_code;
               END IF;

          END IF;
      EXIT WHEN ( j = p_fc_temp_charge.LAST);
      j := p_fc_temp_charge.NEXT(j);
      END LOOP;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 3 ');
      -- now for each value in l_charge_tab, create a source_line_rec for charges
      k := l_charge_tab.FIRST;
      IF (k IS NOT NULL) THEN
      LOOP
         i := i + 1;
          x_source_line_rates_tab(i).source_line_id := k;
          x_source_line_rates_tab(i).cost_type_id   := NULL; -- fix this
          x_source_line_rates_tab(i).line_type_code := 'CHARGE';
          x_source_line_rates_tab(i).cost_type      := 'FTECHARGE';
          x_source_line_rates_tab(i).cost_sub_type  := NULL;
          x_source_line_rates_tab(i).priced_quantity    := l_rate_tab(k).qty;
          x_source_line_rates_tab(i).priced_uom     := l_rate_tab(k).uom;

  	     IF (l_charge_tab(k).currency <> l_target_currency) THEN
    	       convert_amount(
     		p_from_currency		=>l_charge_tab(k).currency,
     		p_from_amount		=>l_charge_tab(k).charge,
		p_conversion_type	=>p_source_header_rec.currency_conversion_type,
     		p_to_currency		=>l_target_currency,
		x_to_amount		=>l_converted_amount,
		x_return_status		=> l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'currency_conversion_failed');
		raise FND_API.G_EXC_ERROR;
	       END IF;

  	     ELSE
		l_converted_amount := l_charge_tab(k).charge;
  	     END IF;
  	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'convert l_charge_tab(k).charge '||l_charge_tab(k).charge||' to l_converted_amount='||l_converted_amount);

          x_source_line_rates_tab(i).unit_price     := l_converted_amount / l_rate_tab(k).qty;
          x_source_line_rates_tab(i).base_price     := l_converted_amount;
          x_source_line_rates_tab(i).adjusted_unit_price    := l_converted_amount / l_rate_tab(k).qty;
          x_source_line_rates_tab(i).adjusted_price    := l_converted_amount;
          x_source_line_rates_tab(i).currency :=  l_target_currency;

             x_source_line_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
             x_source_line_rates_tab(i).lane_id := p_service_rec.lane_id;
      	     x_source_line_rates_tab(i).carrier_id := p_service_rec.carrier_id;
             x_source_line_rates_tab(i).carrier_freight_code := p_service_rec.carrier_freight_code;
             x_source_line_rates_tab(i).service_level := p_service_rec.service_type_code;
             x_source_line_rates_tab(i).mode_of_transport := p_service_rec.mode_of_transportation_code;
             x_source_line_rates_tab(i).ship_method_code := p_service_rec.ship_method_code;

      EXIT WHEN (k = l_charge_tab.LAST);
      k := l_charge_tab.NEXT(k);
      END LOOP;
      END IF;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END populate_rate;

-- For FTE J Estimate Rates
-- No currency conversions
-- No sorting of rates

PROCEDURE populate_rate_2 (
  p_source_header_rec		IN 	      FTE_PROCESS_REQUESTS.fte_source_header_rec,
  p_service_rec  		IN	      lane_info_rec_type,
  p_lane_rate			IN	      NUMBER,
  p_lane_rate_uom		IN	      VARCHAR2,
  p_fc_temp_price         	IN 	      FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
  p_fc_temp_charge        	IN 	      FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
  x_source_line_rates_tab 	IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab 	IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_return_status     		OUT NOCOPY  VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'POPULATE_RATE_2';
  l_return_status         VARCHAR2(1);

  i                         NUMBER:=0;
  j                         NUMBER:=0;
  k                         NUMBER:=0;
  ii			    NUMBER;
  l_found_group		    BOOLEAN;
  l_need_move		    BOOLEAN;
  l_converted_amount	    NUMBER;
  l_target_currency	    VARCHAR2(10);
  l_cost_type_code          WSH_FREIGHT_COST_TYPES.freight_cost_type_code%TYPE;
  l_sub_type_code           WSH_FREIGHT_COST_TYPES.name%TYPE;

  l_charge_tab    rate_tab_type;
  l_rate_tab      rate_tab_type;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);


      i := x_source_line_rates_tab.COUNT;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source line rates records is '||i);

      ii := x_source_header_rates_tab.COUNT;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source header rates records is '||ii);

      ii := ii+1;
      x_source_header_rates_tab(ii).consolidation_id := p_source_header_rec.consolidation_id;
      x_source_header_rates_tab(ii).lane_id := p_service_rec.lane_id;
      x_source_header_rates_tab(ii).carrier_id := p_service_rec.carrier_id;
      x_source_header_rates_tab(ii).carrier_freight_code := p_service_rec.carrier_freight_code;
      x_source_header_rates_tab(ii).service_level := p_service_rec.service_type_code;
      x_source_header_rates_tab(ii).mode_of_transport := p_service_rec.mode_of_transportation_code;
      x_source_header_rates_tab(ii).ship_method_code := p_service_rec.ship_method_code;
      x_source_header_rates_tab(ii).cost_type_id := null;
      x_source_header_rates_tab(ii).cost_type := 'SUMMARY';
      x_source_header_rates_tab(ii).price := p_lane_rate;
      x_source_header_rates_tab(ii).currency := p_lane_rate_uom;
      x_source_header_rates_tab(ii).transit_time := p_service_rec.transit_time;
      x_source_header_rates_tab(ii).transit_time_uom := p_service_rec.transit_time_uom;
      x_source_header_rates_tab(ii).first_line_index := i+1;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 1 ');
      j := p_fc_temp_price.FIRST;
      IF (j IS NOT NULL) THEN
      -- {
      LOOP
         -- {
           IF (p_fc_temp_price(j).line_type_code = 'PRICE') THEN
          -- {
               -- store for later
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).price := p_fc_temp_price(j).unit_amount ;   -- including discount
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).charge := 0;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).currency := p_fc_temp_price(j).currency_code ;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).qty := p_fc_temp_price(j).quantity ;
               l_rate_tab(p_fc_temp_price(j).delivery_detail_id).uom := p_fc_temp_price(j).uom ;

             i := i + 1;
             x_source_line_rates_tab(i).source_line_id := p_fc_temp_price(j).delivery_detail_id;
             x_source_line_rates_tab(i).cost_type_id   := p_fc_temp_price(j).freight_cost_type_id;
             x_source_line_rates_tab(i).line_type_code := p_fc_temp_price(j).line_type_code;

             x_source_line_rates_tab(i).cost_type      := 'FTEPRICE';
             x_source_line_rates_tab(i).cost_sub_type  := 'PRICE';

             x_source_line_rates_tab(i).priced_quantity    := p_fc_temp_price(j).quantity;
             x_source_line_rates_tab(i).priced_uom     := p_fc_temp_price(j).uom;
             x_source_line_rates_tab(i).adjusted_unit_price    := (p_fc_temp_price(j).unit_amount)/(p_fc_temp_price(j).quantity) ;   -- adjusted unit price
             x_source_line_rates_tab(i).adjusted_price    := p_fc_temp_price(j).unit_amount ;   -- adjusted unit price (including discount)
             x_source_line_rates_tab(i).currency := p_fc_temp_price(j).currency_code;

             x_source_line_rates_tab(i).unit_price     := p_fc_temp_price(j).charge_unit_value;
             x_source_line_rates_tab(i).base_price     := p_fc_temp_price(j).charge_unit_value * p_fc_temp_price(j).quantity;

             x_source_line_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
             x_source_line_rates_tab(i).lane_id := p_service_rec.lane_id;
      	     x_source_line_rates_tab(i).carrier_id := p_service_rec.carrier_id;
             x_source_line_rates_tab(i).carrier_freight_code := p_service_rec.carrier_freight_code;
             x_source_line_rates_tab(i).service_level := p_service_rec.service_type_code;
             x_source_line_rates_tab(i).mode_of_transport := p_service_rec.mode_of_transportation_code;
             x_source_line_rates_tab(i).ship_method_code := p_service_rec.ship_method_code;

         -- }
          END IF;

         EXIT WHEN ( j >= p_fc_temp_price.LAST);
         j := p_fc_temp_price.NEXT(j);
         -- }
      END LOOP;
      -- }
      END IF;


      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 2 ');
      -- sum up charges by source_line_id
      j := p_fc_temp_charge.FIRST;
      IF (j IS NOT NULL) THEN
      LOOP
          IF (p_fc_temp_charge(j).line_type_code = 'CHARGE') THEN

               IF l_charge_tab.EXISTS(p_fc_temp_charge(j).delivery_detail_id) THEN
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge := l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge + p_fc_temp_charge(j).total_amount;
               ELSE
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).charge := p_fc_temp_charge(j).total_amount;
                  l_charge_tab(p_fc_temp_charge(j).delivery_detail_id).currency := p_fc_temp_charge(j).currency_code;
               END IF;

          END IF;
      EXIT WHEN ( j = p_fc_temp_charge.LAST);
      j := p_fc_temp_charge.NEXT(j);
      END LOOP;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Loop 3 ');
      -- now for each value in l_charge_tab, create a source_line_rec for charges
      k := l_charge_tab.FIRST;
      IF (k IS NOT NULL) THEN
      LOOP
         i := i + 1;
          x_source_line_rates_tab(i).source_line_id := k;
          x_source_line_rates_tab(i).cost_type_id   := NULL; -- fix this
          x_source_line_rates_tab(i).line_type_code := 'CHARGE';
          x_source_line_rates_tab(i).cost_type      := 'FTECHARGE';
          x_source_line_rates_tab(i).cost_sub_type  := NULL;
          x_source_line_rates_tab(i).priced_quantity    := l_rate_tab(k).qty;
          x_source_line_rates_tab(i).priced_uom     := l_rate_tab(k).uom;

          x_source_line_rates_tab(i).unit_price     := l_charge_tab(k).charge / l_rate_tab(k).qty;
          x_source_line_rates_tab(i).base_price     := l_charge_tab(k).charge;
          x_source_line_rates_tab(i).adjusted_unit_price    := l_charge_tab(k).charge / l_rate_tab(k).qty;
          x_source_line_rates_tab(i).adjusted_price    := l_charge_tab(k).charge;
          x_source_line_rates_tab(i).currency :=  l_charge_tab(k).currency;

             x_source_line_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
             x_source_line_rates_tab(i).lane_id := p_service_rec.lane_id;
      	     x_source_line_rates_tab(i).carrier_id := p_service_rec.carrier_id;
             x_source_line_rates_tab(i).carrier_freight_code := p_service_rec.carrier_freight_code;
             x_source_line_rates_tab(i).service_level := p_service_rec.service_type_code;
             x_source_line_rates_tab(i).mode_of_transport := p_service_rec.mode_of_transportation_code;
             x_source_line_rates_tab(i).ship_method_code := p_service_rec.ship_method_code;

      EXIT WHEN (k = l_charge_tab.LAST);
      k := l_charge_tab.NEXT(k);
      END LOOP;
      END IF;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END populate_rate_2;

PROCEDURE populate_shipment(
    p_source_header_rec	IN 	    FTE_PROCESS_REQUESTS.fte_source_header_rec,
    p_source_line_tab	IN 	    FTE_PROCESS_REQUESTS.fte_source_line_tab,
    x_return_status     OUT NOCOPY  VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'POPULATE_SHIPMENT';
  l_return_status         VARCHAR2(1);
  i 			NUMBER;
  idx			NUMBER;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  fte_freight_pricing.g_shipment_line_rows.DELETE;

  FOR i in p_source_line_tab.FIRST..p_source_line_tab.LAST LOOP
    IF (p_source_line_tab(i).consolidation_id = p_source_header_rec.consolidation_id
            AND nvl(p_source_line_tab(i).freight_rating_flag,'Y') = 'Y' ) THEN

      idx := p_source_line_tab(i).source_line_id;
      fte_freight_pricing.g_shipment_line_rows(idx).delivery_detail_id  	:= p_source_line_tab(i).source_line_id;
      fte_freight_pricing.g_shipment_line_rows(idx).delivery_id         	:= p_source_line_tab(i).consolidation_id;
      fte_freight_pricing.g_shipment_line_rows(idx).delivery_leg_id     	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).reprice_required    	:= 'Y';
      fte_freight_pricing.g_shipment_line_rows(idx).parent_delivery_detail_id	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).customer_id         	:= p_source_line_tab(i).customer_id;
      fte_freight_pricing.g_shipment_line_rows(idx).sold_to_contact_id  	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).inventory_item_id   	:= p_source_line_tab(i).inventory_item_id;
      fte_freight_pricing.g_shipment_line_rows(idx).item_description    	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).hazard_class_id     	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).country_of_origin   	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).classification     	 	:= NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).requested_quantity  	:= p_source_line_tab(i).source_quantity;
      fte_freight_pricing.g_shipment_line_rows(idx).requested_quantity_uom   	:= p_source_line_tab(i).source_quantity_uom;
      fte_freight_pricing.g_shipment_line_rows(idx).master_container_item_id    := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).detail_container_item_id    := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).customer_item_id            := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).net_weight                  := p_source_line_tab(i).weight;
      fte_freight_pricing.g_shipment_line_rows(idx).organization_id             := p_source_line_tab(i).ship_from_org_id;
      fte_freight_pricing.g_shipment_line_rows(idx).container_flag              := 'N';
      fte_freight_pricing.g_shipment_line_rows(idx).container_type_code         := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).container_name              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).fill_percent                := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).gross_weight                := p_source_line_tab(i).weight;
      fte_freight_pricing.g_shipment_line_rows(idx).currency_code               := p_source_line_tab(i).freight_rate_currency;
      fte_freight_pricing.g_shipment_line_rows(idx).freight_class_cat_id        := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).commodity_code_cat_id       := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).weight_uom_code             := p_source_line_tab(i).weight_uom_code;
      fte_freight_pricing.g_shipment_line_rows(idx).volume                      := p_source_line_tab(i).volume;
      fte_freight_pricing.g_shipment_line_rows(idx).volume_uom_code             := p_source_line_tab(i).volume_uom_code;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute_category       := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute1               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute2               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute3               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute4               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute5               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute6               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute7               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute8               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute9               := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute10              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute11              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute12              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute13              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute14              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).tp_attribute15              := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute_category          := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute1                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute2                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute3                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute4                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute5                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute6                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute7                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute8                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute9                  := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute10                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute11                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute12                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute13                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute14                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).attribute15                 := NULL;
      fte_freight_pricing.g_shipment_line_rows(idx).source_type                 := p_source_line_tab(i).source_type;
      fte_freight_pricing.g_shipment_line_rows(idx).source_line_id              := p_source_line_tab(i).source_line_id;
      fte_freight_pricing.g_shipment_line_rows(idx).source_header_id            := p_source_line_tab(i).source_header_id;
      fte_freight_pricing.g_shipment_line_rows(idx).source_consolidation_id     := p_source_line_tab(i).consolidation_id;
      fte_freight_pricing.g_shipment_line_rows(idx).ship_date                   := p_source_line_tab(i).ship_date;
      fte_freight_pricing.g_shipment_line_rows(idx).arrival_date                := p_source_line_tab(i).arrival_date;
      -- FTE J rate estimate
      fte_freight_pricing.g_shipment_line_rows(idx).comm_category_id            := p_source_line_tab(i).commodity_category_id;

    END IF;
  END LOOP; -- p_source_line_tab

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END populate_shipment;

PROCEDURE Search_Services(
    p_source_header_rec	IN 	    FTE_PROCESS_REQUESTS.fte_source_header_rec,
    p_ignore_TL         IN          VARCHAR2  DEFAULT 'Y',    -- FTE J estimate rate
    p_filter_shipmethod IN          VARCHAR2  DEFAULT 'Y',    -- FTE J estimate rate
    x_matched_services  OUT NOCOPY  lane_info_tab_type,
    x_return_status     OUT NOCOPY  VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'SEARCH_SERVICES';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(32767);
  l_search_criteria fte_search_criteria_rec;
  l_lanes_tab  fte_lane_tab;
  l_lane_rec   fte_lane_rec;
  l_schedules_tab  fte_schedule_tab;
  i                NUMBER;
  j                NUMBER;
  l_filter_lanes	BOOLEAN;
  l_lead_time		NUMBER;
  l_ship_method_code	VARCHAR2(30);
  l_generic_carrier    	VARCHAR2(1);
  l_carrier_id		NUMBER;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_ignore_TL='||p_ignore_TL);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_filter_shipmethod='||p_filter_shipmethod);

  l_ship_method_code := p_source_header_rec.ship_method_code;
  l_carrier_id := p_source_header_rec.carrier_id;
  l_mode_of_transport := p_source_header_rec.mode_of_transport;
  l_service_level := p_source_header_rec.service_level;

    IF (l_ship_method_code is not null)
	AND (l_carrier_id is null
	  OR l_mode_of_transport is null
	  OR l_service_level is null) THEN

      OPEN  c_carrier_services(l_ship_method_code);
      FETCH c_carrier_services INTO c_carr_srv_rec;
      CLOSE c_carrier_services;

      l_carrier_id := c_carr_srv_rec.carrier_id;
      l_mode_of_transport := c_carr_srv_rec.mode_of_transport;
      l_service_level := c_carr_srv_rec.service_level;

    END IF;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_carrier_id='||l_carrier_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_mode_of_transport'||l_mode_of_transport);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_service_level='||l_service_level);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ship_method_code='||l_ship_method_code);

  IF l_carrier_id is not null THEN

    OPEN c_get_generic_carrier_flag(l_carrier_id);
    FETCH c_get_generic_carrier_flag INTO l_generic_carrier;
    CLOSE c_get_generic_carrier_flag;

    IF (l_generic_carrier = 'Y') THEN
      l_carrier_id := null;
    END IF;
  END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate l_search_criteria... ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_from_location_id='||p_source_header_rec.ship_from_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_to_location_id='||p_source_header_rec.ship_to_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_mode_of_transport='||l_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_carrier_id='||l_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_service_level='||l_service_level);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_date='||p_source_header_rec.ship_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.arrival_date='||p_source_header_rec.arrival_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_from_location_id='||p_source_header_rec.ship_from_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_to_site_id='||p_source_header_rec.ship_to_site_id);

    l_search_criteria := fte_search_criteria_rec(
                  relax_flag             => 'Y',
                  origin_loc_id          => p_source_header_rec.ship_from_location_id,
                  destination_loc_id     => p_source_header_rec.ship_to_location_id,
                  -- FTE J rate estimate : begin --
                  origin_country         => p_source_header_rec.origin_country,
                  origin_state           => p_source_header_rec.origin_state,
                  origin_city            => p_source_header_rec.origin_city,
                  origin_zip             => p_source_header_rec.origin_zip,
                  destination_country    => p_source_header_rec.destination_country,
                  destination_state      => p_source_header_rec.destination_state,
                  destination_city       => p_source_header_rec.destination_city,
                  destination_zip        => p_source_header_rec.destination_zip,
                  -- FTE J rate estimate : end --
                  mode_of_transport      => l_mode_of_transport,
                  lane_number            => null,
                  carrier_id             => l_carrier_id,
                  carrier_name           => null,
                  commodity_catg_id      => null,
                  commodity              => null,
                  service_code           => l_service_level,
                  service                => null,
                  --Changes to fte_search_criteria_rec 11-Oct-2004(remove equipment_code,equipment,add tariff_name
                  --equipment_code         => null,
                  --equipment              => null,
                  tariff_name		   => null,

                  schedule_only_flag     => null,
                  dep_date_from          => p_source_header_rec.ship_date,
                  dep_date_to            => p_source_header_rec.ship_date,
                  arr_date_from          => p_source_header_rec.arrival_date,
                  arr_date_to            => p_source_header_rec.arrival_date,
                  lane_ids_string        => null,
                  delivery_leg_id        => null,
                  exists_in_database     => null,
                  delivery_id            => null,
                  sequence_number        => null,
                  pick_up_stop_id        => null,
                  drop_off_stop_id       => null,
                  pickupstop_location_id => p_source_header_rec.ship_from_location_id,
                  -- dropoffstop_location_id => null,
                  dropoffstop_location_id => p_source_header_rec.ship_to_location_id, -- FTE J rate estimate
		  ship_to_site_id 	 => p_source_header_rec.ship_to_site_id,
		  vehicle_id		 => null,
		  --Changes made to fte_search_criteria_rec 19-FEB-2004
		  effective_date         => p_source_header_rec.ship_date,
		  effective_date_type    => '='
		  );

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling FTE_LANE_SEARCH.Search_Lanes... ');

  FTE_LANE_SEARCH.Search_Lanes(p_search_criteria => l_search_criteria,
			       p_search_type => 'L',
			       p_source_type => 'R',
			       p_num_results => 999,
			       x_lane_results => l_lanes_tab,
			       x_schedule_results => l_schedules_tab,
			       x_return_message => l_msg_data,
			       x_return_status => l_return_status);

  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'search_lane_failed');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,l_msg_data);
    raise FND_API.G_EXC_ERROR;
  END IF;

/*
  -- for testing
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'manually set up lane results... ');

  l_lanes_tab := fte_lane_tab();

  l_lane_rec := fte_lane_rec(
		lane_id 		=> 1369,
		carrier_id		=> 15451,
		rate_chart_id		=> null,
		mode_of_transport	=> 'LTL',
		origin_id		=> null,
		destination_id		=> null,
		basis			=> null,
		commodity_catg_id	=> null,
		service_code		=> 'D2D',
		comm_fc_class_code	=> null,
		transit_time		=> 1,
		transit_time_uom	=> null,
 lane_number		=> null,
 equipment_code		=> null,
 schedules_flag_code	=> null,
 distance		=> null,
 distance_uom		=> null,
 carrier_name		=> null,
 mode_of_transport_code	=> null,
 commodity		=> null,
 equipment		=> null,
 service		=> null,
 schedules_flag		=> null,
 port_of_loading	=> null,
 port_of_discharge	=> null,
 rate_chart_name	=> null,
 owner_id		=> null,
 special_handling	=> null,
 addl_instr		=> null,
 commodity_flag		=> null,
 equipment_flag		=> null,
 service_flag		=> null,
 rate_chart_view_flag	=> null,
 effective_date		=> null,
 expiry_date		=> null,
 origin_region_type	=> null,
 dest_region_type	=> null
			);


  --IF p_source_header_rec.consolidation_id = 1 then
    --l_lane_rec.lane_id := 111;
  --end if;

  l_lanes_tab.EXTEND;
  i := 1;
  l_lanes_tab(i) := l_lane_rec;

  l_lane_rec := fte_lane_rec(
		lane_id 		=> 1378,
		carrier_id		=> 15453,
		rate_chart_id		=> null,
		mode_of_transport	=> 'LTL',
		origin_id		=> null,
		destination_id		=> null,
		basis			=> null,
		commodity_catg_id	=> null,
		service_code		=> 'D2D',
		comm_fc_class_code	=> null,
		transit_time		=> 1,
		transit_time_uom	=> null,
 lane_number		=> null,
 equipment_code		=> null,
 schedules_flag_code	=> null,
 distance		=> null,
 distance_uom		=> null,
 carrier_name		=> null,
 mode_of_transport_code	=> null,
 commodity		=> null,
 equipment		=> null,
 service		=> null,
 schedules_flag		=> null,
 port_of_loading	=> null,
 port_of_discharge	=> null,
 rate_chart_name	=> null,
 owner_id		=> null,
 special_handling	=> null,
 addl_instr		=> null,
 commodity_flag		=> null,
 equipment_flag		=> null,
 service_flag		=> null,
 rate_chart_view_flag	=> null,
 effective_date		=> null,
 expiry_date		=> null,
 origin_region_type	=> null,
 dest_region_type	=> null
			);

  --IF p_source_header_rec.consolidation_id = 1 then
    --l_lane_rec.lane_id := 111;
  --end if;

  l_lanes_tab.EXTEND;
  i := 2;
  l_lanes_tab(i) := l_lane_rec;

  l_lane_rec := fte_lane_rec(
		lane_id 		=> 1379,
		carrier_id		=> 15453,
		rate_chart_id		=> null,
		mode_of_transport	=> 'LTL',
		origin_id		=> null,
		destination_id		=> null,
		basis			=> null,
		commodity_catg_id	=> null,
		service_code		=> 'D2D',
		comm_fc_class_code	=> null,
		transit_time		=> 10,
		transit_time_uom	=> null,
 lane_number		=> null,
 equipment_code		=> null,
 schedules_flag_code	=> null,
 distance		=> null,
 distance_uom		=> null,
 carrier_name		=> null,
 mode_of_transport_code	=> null,
 commodity		=> null,
 equipment		=> null,
 service		=> null,
 schedules_flag		=> null,
 port_of_loading	=> null,
 port_of_discharge	=> null,
 rate_chart_name	=> null,
 owner_id		=> null,
 special_handling	=> null,
 addl_instr		=> null,
 commodity_flag		=> null,
 equipment_flag		=> null,
 service_flag		=> null,
 rate_chart_view_flag	=> null,
 effective_date		=> null,
 expiry_date		=> null,
 origin_region_type	=> null,
 dest_region_type	=> null
			);

  --IF p_source_header_rec.consolidation_id = 1 then
    --l_lane_rec.lane_id := 111;
  --end if;

  l_lanes_tab.EXTEND;
  i := 3;
  l_lanes_tab(i) := l_lane_rec;
*/

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating matched_services from search_lane results... ');
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'filtering lanes on following fields in source_header_rec:');
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'scheduled_flag='||p_source_header_rec.scheduled_flag);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery_lead_time='||p_source_header_rec.delivery_lead_time);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'enforce_lead_time='||p_source_header_rec.enforce_lead_time);
  IF (p_source_header_rec.scheduled_flag = 'Y') and
	(p_source_header_rec.delivery_lead_time is not null) and
	(p_source_header_rec.delivery_lead_time > 0) and
	(p_source_header_rec.enforce_lead_time = 'Y') THEN

    l_filter_lanes := true;
    l_lead_time := p_source_header_rec.delivery_lead_time;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'filter lane results based on lead time: '||l_lead_time);

  ELSE
    l_filter_lanes := false;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'not filter lane results');
  END IF;

  IF l_lanes_tab is not null AND l_lanes_tab.COUNT > 0 THEN
  j := 0;
  FOR i IN l_lanes_tab.FIRST..l_lanes_tab.LAST LOOP
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i='||i);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found lane_id='||l_lanes_tab(i).lane_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'transit time='||l_lanes_tab(i).transit_time);

    IF ( l_lanes_tab(i).mode_of_transport_code = 'TRUCK'
       AND p_ignore_TL = 'Y' )               -- FTE J estimate rate
    THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ignore this TL lane...');
    ELSIF l_filter_lanes and (l_lanes_tab(i).transit_time is null) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane transit time is null, ignore');
    ELSIF l_filter_lanes and (l_lead_time < l_lanes_tab(i).transit_time) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane transit time is longer than lead time, ignore');
    ELSE
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lanes_tab(i).carrier_id '||l_lanes_tab(i).carrier_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lanes_tab(i).mode_of_transport_code '||l_lanes_tab(i).mode_of_transport_code);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lanes_tab(i).service_code '||l_lanes_tab(i).service_code);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_rec.ship_from_org_id '||p_source_header_rec.ship_from_org_id);

      l_ship_method_code := null;

      OPEN c_get_ship_method_code(l_lanes_tab(i).carrier_id,l_lanes_tab(i).mode_of_transport_code,l_lanes_tab(i).service_code, p_source_header_rec.ship_from_org_id);
      FETCH c_get_ship_method_code INTO l_ship_method_code;
      CLOSE c_get_ship_method_code;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ship_method_code='||l_ship_method_code);

      IF l_ship_method_code is null and p_filter_shipmethod = 'Y' THEN
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship method is null, ignore');
      ELSE
        j := j+1;
        x_matched_services(j).lane_id       	:= l_lanes_tab(i).lane_id;
        x_matched_services(j).carrier_id    	:= l_lanes_tab(i).carrier_id;
        x_matched_services(j).pricelist_id  	:= l_lanes_tab(i).rate_chart_id;
        x_matched_services(j).mode_of_transportation_code := l_lanes_tab(i).mode_of_transport_code;
        x_matched_services(j).origin_id     	:= l_lanes_tab(i).origin_id;
        x_matched_services(j).destination_id  	:= l_lanes_tab(i).destination_id;
        x_matched_services(j).basis           	:= l_lanes_tab(i).basis;
        x_matched_services(j).commodity_catg_id   	:= l_lanes_tab(i).commodity_catg_id;
        x_matched_services(j).service_type_code   	:= l_lanes_tab(i).service_code;
        x_matched_services(j).classification_code 	:= l_lanes_tab(i).comm_fc_class_code;
        x_matched_services(j).transit_time        	:= l_lanes_tab(i).transit_time;
        x_matched_services(j).transit_time_uom      := l_lanes_tab(i).transit_time_uom;

        x_matched_services(j).ship_method_code	:= l_ship_method_code;

        l_ship_method_code := null;

        OPEN c_get_carrier_freight_code(l_lanes_tab(i).carrier_id);
        FETCH c_get_carrier_freight_code INTO l_ship_method_code;
        CLOSE c_get_carrier_freight_code;

        x_matched_services(j).carrier_freight_code:= l_ship_method_code;
      END IF;
    END IF;
  END LOOP; -- l_lanes_tab loop

  END IF;

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

END Search_Services;


PROCEDURE Append_Rates(
	p_source_header_rates_tab  IN 	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	p_source_line_rates_tab	IN FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status        OUT NOCOPY Varchar2)

IS


i NUMBER;
j NUMBER;
l_first_line_index_offset NUMBER;
l_first_line_index_tab dbms_utility.number_array;
l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
l_api_name              CONSTANT VARCHAR2(30)   := 'Append_Rates';
l_return_status         VARCHAR2(1);


BEGIN


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);


	--HEader Rates

	j:=x_source_header_rates_tab.LAST;
	IF(j IS NULL)
	THEN
		j:=1;
	ELSE
		j:=j+1;
	END IF;
	i:=p_source_header_rates_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		x_source_header_rates_tab(j):=p_source_header_rates_tab(i);

		l_first_line_index_tab(x_source_header_rates_tab(j).first_line_index):=j;

		j:=j+1;
		i:=p_source_header_rates_tab.NEXT(i);
	END LOOP;

	--Line Rates

	j:=x_source_line_rates_tab.LAST;

	IF(j IS NULL)
	THEN
		j:=1;
	ELSE
		j:=j+1;
	END IF;
	i:=p_source_line_rates_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		x_source_line_rates_tab(j):=p_source_line_rates_tab(i);

		IF (l_first_line_index_tab.EXISTS(i))
		THEN
			IF (x_source_header_rates_tab.EXISTS(l_first_line_index_tab(i)))
			THEN
				--Adjust first line index
				x_source_header_rates_tab(l_first_line_index_tab(i)).first_line_index:=j;

			END IF;

		END IF;

		j:=j+1;
		i:=p_source_line_rates_tab.NEXT(i);
	END LOOP;



	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

EXCEPTION



   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


END Append_Rates;



PROCEDURE Sort_Source_Rates(
	P_LCSS_flag IN VARCHAR2,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status        OUT NOCOPY Varchar2)
IS

l_values_tab FTE_TRIP_RATING_GRP.Sort_Value_Tab_Type;
i NUMBER;
j NUMBER;
l_value_rec FTE_TRIP_RATING_GRP.Sort_Value_Rec_Type;
l_value dbms_utility.number_array;
l_sorted_index dbms_utility.number_array;
l_source_header_rates_tab FTE_PROCESS_REQUESTS.fte_source_header_rates_tab;

l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
l_api_name              CONSTANT VARCHAR2(30)   := 'Sort_Source_Rates';
l_return_status         VARCHAR2(1);


BEGIN


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);


	l_values_tab.DELETE;

	i:=x_source_header_rates_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		l_values_tab(i):=l_value_rec;
		l_values_tab(i).value(0):=x_source_header_rates_tab(i).price;

		i:=x_source_header_rates_tab.NEXT(i);
	END LOOP;


	FTE_TRIP_RATING_GRP.Sort(
		p_values_tab=>l_values_tab,
		p_sort_type=>NULL,
		x_sorted_index=>l_sorted_index,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_sort_fail;
	       END IF;
	END IF;

	i:=l_sorted_index.FIRST;
	j:=x_source_header_rates_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		l_source_header_rates_tab(j):=x_source_header_rates_tab(l_sorted_index(i));
		j:=j+1;

		i:=l_sorted_index.NEXT(i);
	END LOOP;


	x_source_header_rates_tab:=l_source_header_rates_tab;

	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_sort_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_sort_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


END Sort_Source_Rates;


PROCEDURE OM_TL_Rate(
	p_lane_info_tab   IN FTE_FREIGHT_RATING_PUB.lane_info_tab_type,
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_LCSS_flag IN VARCHAR2,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status        OUT NOCOPY Varchar2)
IS

i NUMBER;
l_lane_rows 	dbms_utility.number_array;
l_schedule_rows	dbms_utility.number_array;
l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
l_api_name              CONSTANT VARCHAR2(30)   := 'OM_TL_Rate';
l_return_status         VARCHAR2(1);


BEGIN


  	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

	i:=p_lane_info_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		l_lane_rows(i):=p_lane_info_tab(i).lane_id;
		l_schedule_rows(i):=NULL;

		i:=p_lane_info_tab.NEXT(i);
	END LOOP;

	FTE_TL_RATING.TL_OM_RATING(
		p_lane_rows=>l_lane_rows,
		p_schedule_rows=>l_schedule_rows,
		p_lane_info_tab=>p_lane_info_tab,
		p_source_header_rec=>p_source_header_rec,
		p_source_lines_tab=>p_source_lines_tab,
		p_LCSS_flag=>p_LCSS_flag,
		x_source_header_rates_tab=>x_source_header_rates_tab,
		x_source_line_rates_tab=>x_source_line_rates_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_om_rating_fail;
	       END IF;
	END IF;

	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_om_rating_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_om_rating_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);



END OM_TL_Rate;

PROCEDURE Get_Services(
  p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
  p_source_header_tab           IN OUT NOCOPY   FTE_PROCESS_REQUESTS.fte_source_header_tab,
  x_source_line_rates_tab  	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab 	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_return_status		OUT NOCOPY 	VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'GET_SERVICES';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(240);
  l_group_count 	  NUMBER;
  l_fail_group_count	  NUMBER;
  l_matched_services  	  lane_info_tab_type;
  l_all_lane_failed	  BOOLEAN;
  l_lane_rate		  NUMBER;
  l_lane_rate_uom	  VARCHAR2(10);
  l_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
  l_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
  k NUMBER;
  l_lane_info_tab lane_info_tab_type;



BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through groups... ');

  l_fail_group_count := 0;
  l_group_count := p_source_header_tab.COUNT;

  FOR i in p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i = '||i);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'consolidation_id = '||p_source_header_tab(i).consolidation_id);
    p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    Search_Services(
      p_source_header_rec => p_source_header_tab(i),
      p_ignore_TL=>'N',
      x_matched_services  => l_matched_services,
      x_return_status 	  => l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'search_services failed');
      p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_SEARCH_SERVICES_FAIL');
      p_source_header_tab(i).message_data := FND_MESSAGE.GET;
      l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

    ELSE -- search services successful

      IF (l_matched_services.COUNT < 1) THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no services found');
	-- no services found
        p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_NO_SERVICES_FOUND');
        p_source_header_tab(i).message_data := FND_MESSAGE.GET;
        l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

      ELSE -- found services

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following services');
    	print_matched_services(
	  p_matched_services => l_matched_services,
	  x_return_status => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating shipment...');
      	populate_shipment(
	  p_source_header_rec 	=> p_source_header_tab(i),
	  p_source_line_tab   	=> p_source_line_tab,
          x_return_status	=> l_return_status);

      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_shipment_failed');
    	  raise FND_API.G_EXC_ERROR;

      	END IF;

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on all the lanes...');
      	l_all_lane_failed := true;

	k:=1;
	l_lane_info_tab.DELETE;

      	FOR j in l_matched_services.FIRST..l_matched_services.LAST
      	LOOP

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'j = '||j);
    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on lane_id = '||l_matched_services(j).lane_id);


      	  IF((l_matched_services(j).mode_of_transportation_code IS NOT NULL)AND
      	  	(l_matched_services(j).mode_of_transportation_code='TRUCK'))
      	  THEN
      	  	l_lane_info_tab(k):=l_matched_services(j);


      	  	k:=k+1;


      	  ELSE



		  -- rate the group on one lane
		  fte_freight_pricing.shipment_rating (
			p_lane_id                 	=> l_matched_services(j).lane_id,
			p_service_type            	=> l_matched_services(j).service_type_code,
			p_mode_of_transport		=> l_matched_services(j).mode_of_transportation_code,
			x_summary_lanesched_price      	=> l_lane_rate,
			x_summary_lanesched_price_uom	=> l_lane_rate_uom,
			x_freight_cost_temp_price  	=> l_lane_fct_price,
			x_freight_cost_temp_charge 	=> l_lane_fct_charge,
			x_return_status           	=> l_return_status,
			x_msg_count               	=> l_msg_count,
			x_msg_data                	=> l_msg_data );

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
		     l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating failed');
		  ELSIF l_lane_rate is null or l_lane_rate_uom is null THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate null');
		  ELSIF l_lane_fct_price is null THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_fct_price null');
		  ELSE
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating success');
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||j);
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate='||l_lane_rate);
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate_uom='||l_lane_rate_uom);

		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating line_rate and header_rate...');
		    populate_rate (
			p_source_header_rec		=> p_source_header_tab(i),
			p_service_rec			=> l_matched_services(j),
			p_lane_rate			=> l_lane_rate,
			p_lane_rate_uom 		=> l_lane_rate_uom,
			p_fc_temp_price 		=> l_lane_fct_price,
			p_fc_temp_charge 		=> l_lane_fct_charge,
			x_source_line_rates_tab 	=> x_source_line_rates_tab,
			x_source_header_rates_tab 	=> x_source_header_rates_tab,
			x_return_status           	=> l_return_status);

		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_rate_failed');
		      raise FND_API.G_EXC_ERROR;

		    END IF;

		    l_all_lane_failed := false;

		    print_rates_tab(
		      p_source_line_rates_tab => x_source_line_rates_tab,
		      p_source_header_rates_tab => x_source_header_rates_tab,
		      x_return_status => l_return_status
			);

		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
		      raise FND_API.G_EXC_ERROR;

		    END IF;

		  END IF;

          END IF;

      	END LOOP; -- l_matched_services loop


      	OM_TL_Rate(
		p_lane_info_tab=>l_lane_info_tab,
		p_source_header_rec=>p_source_header_tab(i),
		p_source_lines_tab=>p_source_line_tab,
		p_LCSS_flag=>'N',
		x_source_header_rates_tab=>x_source_header_rates_tab,
		x_source_line_rates_tab=>x_source_line_rates_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'OM_TL_Rate failed');
		      raise FND_API.G_EXC_ERROR;
	       END IF;
	END IF;

	IF(x_source_header_rates_tab.COUNT > 0)
	THEN

		l_all_lane_failed:=false;

	END IF;


	Sort_Source_Rates(
		p_LCSS_flag=>'N',
		x_source_header_rates_tab=>x_source_header_rates_tab,
		x_source_line_rates_tab=>x_source_line_rates_tab,
		x_return_status=>l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Sort_Source_Rates failed');
		      raise FND_API.G_EXC_ERROR;
	       END IF;
	END IF;



      	IF (l_all_lane_failed) THEN

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found');
	  p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_NO_RATES_FOUND');
          p_source_header_tab(i).message_data := FND_MESSAGE.GET;
          l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

      	END IF;

      END IF; -- found services

    END IF;  -- search services successful

  END LOOP; -- p_source_header_tab loop

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_group_count='||l_group_count);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_fail_group_count='||l_fail_group_count);

  IF (l_fail_group_count = l_group_count) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF (l_fail_group_count = 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_SUC_W');
      FND_MSG_PUB.ADD;
  END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END Get_Services;


-- FTE J rate estimate -- internal API

PROCEDURE Get_FTE_Estimate_Rates(
  p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
  p_source_header_tab           IN OUT NOCOPY   FTE_PROCESS_REQUESTS.fte_source_header_tab,
  x_source_line_rates_tab  	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab 	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_return_status		OUT NOCOPY 	VARCHAR2)
IS
  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'GET_FTE_ESTIMATE_RATES';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(240);
  l_group_count 	  NUMBER;
  l_fail_group_count	  NUMBER;
  l_matched_services  	  lane_info_tab_type;
  l_all_lane_failed	  BOOLEAN;
  l_lane_rate		  NUMBER;
  l_lane_rate_uom	  VARCHAR2(10);
  l_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
  l_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
   l_lane_rows          dbms_utility.number_array;
   l_schedule_rows      dbms_utility.number_array;
   l_vehicle_rows       dbms_utility.number_array;
   l_ref_rows 		dbms_utility.number_array;
   l_tl_base_rows       dbms_utility.number_array;
   l_tl_chrg_rows       dbms_utility.number_array;
   l_tl_curr_rows       dbms_utility.name_array;
   i                    NUMBER;
   j                    NUMBER;
   k                    NUMBER;
   kk                   NUMBER;
   l_lane_out_rows          dbms_utility.number_array;
   l_schedule_out_rows      dbms_utility.number_array;
   l_vehicle_out_rows       dbms_utility.number_array;
     --Bug 6625274 Added l_origin_id and l_destination_id variables to pass origin and destination to TL_FREIGHT_ESTIMATE
   l_origin_id          NUMBER;
   l_destination_id     NUMBER;


BEGIN

  -- Each groups (consolidation_id) stands for one mode_of_transport
  -- seach services for each group
  -- call mode specific rating api
  -- process and merge output

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through groups... ');

  l_fail_group_count := 0;
  l_group_count := p_source_header_tab.COUNT;

  FOR i in p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP

    --Bug 6625274 Initialize Origin and Destination id to null each item loop iterates
    l_origin_id := null;
    l_destination_id := null;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'i = '||i);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'consolidation_id = '||p_source_header_tab(i).consolidation_id);
    p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    Search_Services(
      p_source_header_rec => p_source_header_tab(i),
      p_ignore_TL         => 'N',
      p_filter_shipmethod => 'N',
      x_matched_services  => l_matched_services,
      x_return_status 	  => l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'search_services failed');
      p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_SEARCH_SERVICES_FAIL');
      p_source_header_tab(i).message_data := FND_MESSAGE.GET;
      l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

    ELSE -- search services successful

      IF (l_matched_services.COUNT < 1) THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no services found');
	-- no services found
        p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_NO_SERVICES_FOUND');
        p_source_header_tab(i).message_data := FND_MESSAGE.GET;
        l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

      ELSE -- found services

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following services');
    	print_matched_services(
	  p_matched_services => l_matched_services,
	  x_return_status => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
	END IF;
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'>>>1');
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_header_tab(i).mode_of_transport='
                                         ||p_source_header_tab(i).mode_of_transport);

        IF (p_source_header_tab(i).mode_of_transport = 'TRUCK') THEN
           -- Call TL API here
           -- add output of tl api to output tables
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Doing TRUCK');
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_matched_services.COUNT='||l_matched_services.COUNT);

      	   FOR j in l_matched_services.FIRST..l_matched_services.LAST LOOP
              l_lane_rows(j)     := l_matched_services(j).lane_id;
              l_schedule_rows(j) := null;

               --Bug 6625274 Storing origin and destination id for passing it to the procedure TL_FREIGHT_ESTIMATE
              IF (l_origin_id is null) THEN
                 l_origin_id := l_matched_services(j).origin_id;
              END IF;

              IF (l_destination_id is null) THEN
                 l_destination_id := l_matched_services(j).destination_id;
              END IF;
              --End of Fix for Bug 6625274


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Calling vehicle API inventory item:'||p_source_header_tab(i).vehicle_item_id);

		l_vehicle_rows(j):=FTE_VEHICLE_PKG.GET_VEHICLE_TYPE_ID(
			p_inventory_item_id=> p_source_header_tab(i).vehicle_item_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Vehicle API returned:'||l_vehicle_rows(j));

		IF (l_vehicle_rows(j) = -1)
		THEN
			l_vehicle_rows(j):=NULL;

		END IF;


           END LOOP;

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'>>>2');

	  FTE_TL_RATING.Get_Vehicles_For_LaneSchedules(
		p_trip_id=>NULL,
		p_lane_rows=>l_lane_rows,
		p_schedule_rows=>l_schedule_rows,
		p_vehicle_rows=>l_vehicle_rows,
		x_vehicle_rows=>l_vehicle_out_rows,
		x_lane_rows=>l_lane_out_rows,
		x_schedule_rows=>l_schedule_out_rows,
		x_ref_rows=>l_ref_rows,
		x_return_status=>l_return_status);

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      THEN
		 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
		 THEN
		    raise FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail;
		 END IF;
	      END IF;



           FTE_TL_RATING.TL_FREIGHT_ESTIMATE(
               p_lane_rows            => l_lane_out_rows,
               p_schedule_rows        => l_schedule_out_rows,
               p_vehicle_rows         => l_vehicle_out_rows,
               p_pickup_location_id   => p_source_header_tab(i).ship_from_location_id,
               p_dropoff_location_id  => p_source_header_tab(i).ship_to_location_id,
               p_ship_date            => p_source_header_tab(i).ship_date,
               p_delivery_date        => p_source_header_tab(i).arrival_date,
               p_weight               => p_source_header_tab(i).total_weight,
               p_weight_uom           => p_source_header_tab(i).weight_uom_code,
               p_volume               => p_source_header_tab(i).total_volume,
               p_volume_uom           => p_source_header_tab(i).volume_uom_code,
               p_distance             => p_source_header_tab(i).distance,
               p_distance_uom         => p_source_header_tab(i).distance_uom,
               x_lane_sched_base_rows => l_tl_base_rows,
               x_lane_sched_acc_rows  => l_tl_chrg_rows,
               x_lane_sched_curr_rows => l_tl_curr_rows ,
               x_return_status        => l_return_status,
               --Bug 6625274 Passing Origin and Destination id to TL_FREIGHT_ESTIMATE procedure
               p_origin_id            => l_origin_id,
               p_destination_id       => l_destination_id);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
              l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING AND
              l_tl_base_rows.COUNT = 0 THEN
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'tl_freight_estimate failed');
	   ELSE
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'tl_freight_estimate success');

              k := x_source_line_rates_tab.COUNT;
              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source line rates records is '||k);

              kk := x_source_header_rates_tab.COUNT;
              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'number of existing source header rates records is '||kk);

              --Sujith added 27-Oct-2003
              IF (l_tl_base_rows.COUNT > 0)
              THEN

                 FOR j IN l_tl_base_rows.FIRST..l_tl_base_rows.LAST LOOP
                  IF (l_tl_base_rows(j) IS NOT NULL AND l_tl_chrg_rows(j) IS NOT NULL) THEN

                   kk := kk + 1;
                   x_source_header_rates_tab(kk).consolidation_id := p_source_header_tab(i).consolidation_id;
                   x_source_header_rates_tab(kk).lane_id := l_lane_out_rows(j);
                   x_source_header_rates_tab(kk).carrier_freight_code := l_matched_services(l_ref_rows(j)).carrier_freight_code;
                   x_source_header_rates_tab(kk).carrier_id := l_matched_services(l_ref_rows(j)).carrier_id;
                   x_source_header_rates_tab(kk).service_level := l_matched_services(l_ref_rows(j)).service_type_code;
                   x_source_header_rates_tab(kk).mode_of_transport := l_matched_services(l_ref_rows(j)).mode_of_transportation_code;
                   x_source_header_rates_tab(kk).ship_method_code := l_matched_services(l_ref_rows(j)).ship_method_code;
                   x_source_header_rates_tab(kk).cost_type_id := null;
                   x_source_header_rates_tab(kk).cost_type := 'SUMMARY';
                   x_source_header_rates_tab(kk).price := nvl(l_tl_base_rows(j),0) + nvl(l_tl_chrg_rows(j),0);
                   x_source_header_rates_tab(kk).currency := l_tl_curr_rows(j);
                   x_source_header_rates_tab(kk).transit_time := l_matched_services(l_ref_rows(j)).transit_time;
                   x_source_header_rates_tab(kk).transit_time_uom := l_matched_services(l_ref_rows(j)).transit_time_uom;
                   x_source_header_rates_tab(kk).vehicle_type_id:=l_vehicle_out_rows(j);
                   x_source_header_rates_tab(kk).first_line_index := k+1;


                   k := k + 1;
                   x_source_line_rates_tab(k).cost_type_id   := NULL;
                   x_source_line_rates_tab(k).line_type_code := 'PRICE';
                   x_source_line_rates_tab(k).cost_type      := 'FTEPRICE';
                   x_source_line_rates_tab(k).cost_sub_type  := 'PRICE';

                   x_source_line_rates_tab(k).priced_quantity    := null;
                   x_source_line_rates_tab(k).priced_uom         := null;
                   x_source_line_rates_tab(k).adjusted_unit_price  := null;
                   x_source_line_rates_tab(k).adjusted_price    := nvl(l_tl_base_rows(j),0);
                   x_source_line_rates_tab(k).currency := l_tl_curr_rows(j);

                   x_source_line_rates_tab(k).unit_price     := null;
                   x_source_line_rates_tab(k).base_price     := nvl(l_tl_base_rows(j),0);

                   x_source_line_rates_tab(k).consolidation_id := p_source_header_tab(i).consolidation_id;
                   x_source_line_rates_tab(k).lane_id := l_matched_services(l_ref_rows(j)).lane_id;
      	           x_source_line_rates_tab(k).carrier_id := l_matched_services(l_ref_rows(j)).carrier_id;
                   x_source_line_rates_tab(k).carrier_freight_code := l_matched_services(l_ref_rows(j)).carrier_freight_code;
                   x_source_line_rates_tab(k).service_level := l_matched_services(l_ref_rows(j)).service_type_code;
                   x_source_line_rates_tab(k).mode_of_transport := l_matched_services(l_ref_rows(j)).mode_of_transportation_code;
                   x_source_line_rates_tab(k).ship_method_code := l_matched_services(l_ref_rows(j)).ship_method_code;
		   x_source_line_rates_tab(k).vehicle_type_id := l_vehicle_out_rows(j);

                   k := k + 1;
                   x_source_line_rates_tab(k).cost_type_id   := NULL;
                   x_source_line_rates_tab(k).line_type_code := 'CHARGE';
                   x_source_line_rates_tab(k).cost_type      := 'FTECHARGE';
                   x_source_line_rates_tab(k).cost_sub_type  := 'CHARGE';

                   x_source_line_rates_tab(k).priced_quantity    := null;
                   x_source_line_rates_tab(k).priced_uom         := null;
                   x_source_line_rates_tab(k).adjusted_unit_price  := null;
                   x_source_line_rates_tab(k).adjusted_price    := nvl(l_tl_chrg_rows(j),0);
                   x_source_line_rates_tab(k).currency := l_tl_curr_rows(j);

                   x_source_line_rates_tab(k).unit_price     := null;
                   x_source_line_rates_tab(k).base_price     := nvl(l_tl_chrg_rows(j),0);

                   x_source_line_rates_tab(k).consolidation_id := p_source_header_tab(i).consolidation_id;
                   x_source_line_rates_tab(k).lane_id := l_matched_services(l_ref_rows(j)).lane_id;
      	           x_source_line_rates_tab(k).carrier_id := l_matched_services(l_ref_rows(j)).carrier_id;
                   x_source_line_rates_tab(k).carrier_freight_code := l_matched_services(l_ref_rows(j)).carrier_freight_code;
                   x_source_line_rates_tab(k).service_level := l_matched_services(l_ref_rows(j)).service_type_code;
                   x_source_line_rates_tab(k).mode_of_transport := l_matched_services(l_ref_rows(j)).mode_of_transportation_code;
                   x_source_line_rates_tab(k).ship_method_code := l_matched_services(l_ref_rows(j)).ship_method_code;
		   --Fixed typo was earlier l_vehicle_out_rows(l_ref_rows(j))
                   x_source_line_rates_tab(k).vehicle_type_id := l_vehicle_out_rows(j);

                  END IF;
                 END LOOP;
		END IF;
           END IF;

        ELSE  -- 'LTL' / 'PARCEL'

           FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating shipment...');
      	   populate_shipment(
	     p_source_header_rec 	=> p_source_header_tab(i),
	     p_source_line_tab   	=> p_source_line_tab,
             x_return_status	=> l_return_status);

      	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

             FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_shipment_failed');
    	     raise FND_API.G_EXC_ERROR;

      	   END IF;

    	   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on all the lanes...');
      	   l_all_lane_failed := true;

      	   FOR j in l_matched_services.FIRST..l_matched_services.LAST LOOP

    	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'j = '||j);
    	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on lane_id = '||l_matched_services(j).lane_id);
	     -- rate the group on one lane
	     fte_freight_pricing.shipment_rating (
	      	   p_lane_id                 	=> l_matched_services(j).lane_id,
              	   p_service_type            	=> l_matched_services(j).service_type_code,
	      	   p_mode_of_transport		=> l_matched_services(j).mode_of_transportation_code,
        	   x_summary_lanesched_price      	=> l_lane_rate,
        	   x_summary_lanesched_price_uom	=> l_lane_rate_uom,
	           x_freight_cost_temp_price  	=> l_lane_fct_price,
	           x_freight_cost_temp_charge 	=> l_lane_fct_charge,
	           x_return_status           	=> l_return_status,
	           x_msg_count               	=> l_msg_count,
	           x_msg_data                	=> l_msg_data );

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
                l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
    	         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating failed');
	     ELSIF l_lane_rate is null or l_lane_rate_uom is null THEN
    	         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate null');
	     ELSIF l_lane_fct_price is null THEN
    	         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_fct_price null');
	     ELSE
    	       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating success');
    	       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||j);
    	       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate='||l_lane_rate);
    	       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate_uom='||l_lane_rate_uom);

    	       FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating line_rate and header_rate...');
	       populate_rate_2 (
		   p_source_header_rec		=> p_source_header_tab(i),
		   p_service_rec			=> l_matched_services(j),
		   p_lane_rate			=> l_lane_rate,
		   p_lane_rate_uom 		=> l_lane_rate_uom,
  		   p_fc_temp_price 		=> l_lane_fct_price,
  		   p_fc_temp_charge 		=> l_lane_fct_charge,
  		   x_source_line_rates_tab 	=> x_source_line_rates_tab,
  		   x_source_header_rates_tab 	=> x_source_header_rates_tab,
	           x_return_status           	=> l_return_status);

      	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_rate_failed');
    	         raise FND_API.G_EXC_ERROR;

      	       END IF;

	       l_all_lane_failed := false;

	       print_rates_tab(
	         p_source_line_rates_tab => x_source_line_rates_tab,
	         p_source_header_rates_tab => x_source_header_rates_tab,
	         x_return_status => l_return_status
		   );

      	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
    	         raise FND_API.G_EXC_ERROR;

      	       END IF;

             END IF;

      	   END LOOP; -- l_matched_services loop

      	   IF (l_all_lane_failed) THEN

    	     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found');
	     p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_NO_RATES_FOUND');
             p_source_header_tab(i).message_data := FND_MESSAGE.GET;
             l_fail_group_count := l_fail_group_count + 1;

               FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
               FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
               FND_MSG_PUB.ADD;

      	   END IF;

        END IF; -- 'TRUCK'

      END IF; -- found services

    END IF;  -- search services successful

  END LOOP; -- p_source_header_tab loop

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_group_count='||l_group_count);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_fail_group_count='||l_fail_group_count);

  -- IF (l_fail_group_count = l_group_count) THEN
  --   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  -- ELSIF (l_fail_group_count = 0) THEN
  IF (l_fail_group_count = 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_SUC_W');
      FND_MSG_PUB.ADD;
  END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END Get_FTE_Estimate_Rates;



PROCEDURE Get_Freight_Costs(
  p_api_version			IN 		NUMBER DEFAULT 1.0,
  p_init_msg_list		IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit			IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
  p_source_header_tab           IN OUT NOCOPY   FTE_PROCESS_REQUESTS.fte_source_header_tab,
  p_source_type			IN              VARCHAR2,
  p_action			IN	        VARCHAR2,
  x_source_line_rates_tab	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
  x_source_header_rates_tab	OUT NOCOPY 	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
  x_request_id                  OUT NOCOPY      NUMBER,
  x_return_status		OUT NOCOPY 	VARCHAR2,
  x_msg_count			OUT NOCOPY 	NUMBER,
  x_msg_data			OUT NOCOPY 	VARCHAR2)
  IS

   CURSOR c_get_req_id IS
   SELECT fte_pricing_comp_request_s.nextval
   FROM   sys.dual;

    l_api_name              CONSTANT VARCHAR2(30)   := 'GET_FREIGHT_COSTS';
    l_api_version           CONSTANT NUMBER         := 1.0;

    l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_request_id              NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count           NUMBER := 0;
    l_msg_data            VARCHAR2(240);

    i   NUMBER;
    l_matched_services        lane_info_tab_type;

    l_group_count 	  NUMBER;
    l_fail_group_count	  NUMBER;

    l_lane_rate		  NUMBER;
    l_lane_rate_uom	  VARCHAR2(10);
    l_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_index NUMBER;
    l_lowest_lane_rate NUMBER;
    l_lowest_lane_rate_uom VARCHAR2(10);
    l_lowest_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_all_lane_failed BOOLEAN;
    l_converted_amount	    NUMBER;
    k NUMBER;
    l_lane_info_tab lane_info_tab_type;
    l_tl_source_line_rates_tab 	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab;
    l_tl_source_header_rates_tab	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab;



  BEGIN

    SAVEPOINT GET_FREIGHT_COSTS;

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

    FTE_FREIGHT_PRICING_UTIL.initialize_logging( x_return_status  => l_return_status );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'init_log_failed');
      raise FND_API.G_EXC_ERROR;
    ELSE
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Initialize Logging successful ');
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_api_version='||p_api_version);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_init_msg_list='||p_init_msg_list);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_source_type='||p_source_type);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_action='||p_action);

        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

    IF (p_source_header_tab.COUNT < 1) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no_source_header');
      raise FND_API.G_EXC_ERROR;

    END IF;

    IF (p_source_line_tab.COUNT < 1) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no_source_line');
      raise FND_API.G_EXC_ERROR;

    END IF;

    print_source_line_tab(
      p_source_line_tab => p_source_line_tab,
      x_return_status => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
    END IF;

    print_source_header_tab(
      p_source_header_tab => p_source_header_tab,
      x_return_status => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
    END IF;

   --  Generate comparison request_id here and populate it into l_request_id
   OPEN c_get_req_id;
   FETCH c_get_req_id INTO l_request_id;
   CLOSE c_get_req_id;
   x_request_id  := l_request_id;
   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'*** Request Id :'||l_request_id);

        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

    IF (p_action = 'GET_RATE_CHOICE') THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'OM-DisplayChoices...');

      Get_Services(
	p_source_line_tab => p_source_line_tab,
	p_source_header_tab => p_source_header_tab,
	x_source_line_rates_tab => x_source_line_rates_tab,
	x_source_header_rates_tab => x_source_header_rates_tab,
	x_return_status => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        and (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'get_services_failed');
	raise FND_API.G_EXC_ERROR;
      ELSE
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
	x_return_status := l_return_status;
      END IF;

    ELSIF (p_action = 'GET_ESTIMATE_RATE') THEN

      Get_FTE_Estimate_Rates(
	p_source_line_tab => p_source_line_tab,
	p_source_header_tab => p_source_header_tab,
	x_source_line_rates_tab => x_source_line_rates_tab,
	x_source_header_rates_tab => x_source_header_rates_tab,
	x_return_status => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        and (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSE
             FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Get_FTE_Estimate_Rates failed');
	     raise FND_API.G_EXC_ERROR;
         END IF;
      ELSE
        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
	x_return_status := l_return_status;
      END IF;

    ELSE -- p_action <> 'GET_RATE_CHOICE'

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'OM-LCSS...');

  l_fail_group_count := 0;
  l_group_count := p_source_header_tab.COUNT;

   FOR i in p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'consolidation_id = '||p_source_header_tab(i).consolidation_id);
    p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    Search_Services(
      p_source_header_rec => p_source_header_tab(i),
      p_ignore_TL=>'N',
      x_matched_services  => l_matched_services,
      x_return_status 	  => l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'search_services failed');
      p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_SEARCH_SERVICES_FAIL');
      p_source_header_tab(i).message_data := FND_MESSAGE.GET;
      l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

    ELSE -- search services successful

      IF (l_matched_services.COUNT < 1) THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no services found');
	-- no services found
        p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

      ELSE -- found services

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following services');
    	print_matched_services(
	  p_matched_services => l_matched_services,
	  x_return_status => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating shipment...');
      	populate_shipment(
	  p_source_header_rec 	=> p_source_header_tab(i),
	  p_source_line_tab   	=> p_source_line_tab,
          x_return_status	=> l_return_status);

      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_shipment_failed');
    	  raise FND_API.G_EXC_ERROR;

      	END IF;

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on all the lanes...');

    	k:=1;
    	l_lane_info_tab.DELETE;
      	l_all_lane_failed := true;
	l_lowest_lane_rate:=NULL;
      	FOR j in l_matched_services.FIRST..l_matched_services.LAST
      	LOOP

      	  IF((l_matched_services(j).mode_of_transportation_code IS NOT NULL)AND
      	  	(l_matched_services(j).mode_of_transportation_code='TRUCK'))
      	  THEN
      	  	l_lane_info_tab(k):=l_matched_services(j);


      	  	k:=k+1;


      	  ELSE


		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rating on lane_id = '||l_matched_services(j).lane_id);
		  -- rate the group on one lane
		  fte_freight_pricing.shipment_rating (
			p_lane_id                 	=> l_matched_services(j).lane_id,
			p_service_type            	=> l_matched_services(j).service_type_code,
			p_mode_of_transport		=> l_matched_services(j).mode_of_transportation_code,
			x_summary_lanesched_price      	=> l_lane_rate,
			x_summary_lanesched_price_uom	=> l_lane_rate_uom,
			x_freight_cost_temp_price  	=> l_lane_fct_price,
			x_freight_cost_temp_charge 	=> l_lane_fct_charge,
			x_return_status           	=> l_return_status,
			x_msg_count               	=> l_msg_count,
			x_msg_data                	=> l_msg_data );

		  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
		     (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating failed');

		  ELSE -- rating successful
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating success');
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||j);
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate='||l_lane_rate);
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate_uom='||l_lane_rate_uom);

		      IF (l_all_lane_failed) THEN

			l_lowest_lane_index := j;
			l_lowest_lane_rate := l_lane_rate;
			l_lowest_lane_rate_uom := l_lane_rate_uom;
			l_lowest_lane_fct_price := l_lane_fct_price;
			l_lowest_lane_fct_charge := l_lane_fct_charge;
			l_all_lane_failed := false;

		      ELSE
			--compare with current lowest cost lane;

			IF (l_lowest_lane_rate_uom <> l_lane_rate_uom) THEN
			  convert_amount(
			    p_from_currency		=>l_lane_rate_uom,
			    p_from_amount		=>l_lane_rate,
			    p_conversion_type		=>p_source_header_tab(i).currency_conversion_type,
			    p_to_currency		=>l_lowest_lane_rate_uom,
			    x_to_amount			=>l_converted_amount,
			    x_return_status		=> l_return_status);

			  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'currency_conversion_failed');
			    raise FND_API.G_EXC_ERROR;
			  END IF;

			ELSE
			  l_converted_amount := l_lane_rate;
			END IF;
			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_converted_amount='||l_converted_amount);

			IF (l_lowest_lane_rate > l_converted_amount) THEN
			  l_lowest_lane_index := j;
			  l_lowest_lane_rate := l_lane_rate;
			  l_lowest_lane_rate_uom := l_lane_rate_uom;
			  l_lowest_lane_fct_price := l_lane_fct_price;
			  l_lowest_lane_fct_charge := l_lane_fct_charge;
			END IF;
		      END IF;

		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_index='||l_lowest_lane_index);
		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate='||l_lowest_lane_rate);
		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate_uom='||l_lowest_lane_rate_uom);
		  END IF; -- rating successful
	  END IF;

      	END LOOP; -- l_matched_services loop

	l_tl_source_header_rates_tab.delete;
	l_tl_source_line_rates_tab.delete;

      	OM_TL_Rate(
		p_lane_info_tab=>l_lane_info_tab,
		p_source_header_rec=>p_source_header_tab(i),
		p_source_lines_tab=>p_source_line_tab,
		p_LCSS_flag=>'Y',
		x_source_header_rates_tab=>l_tl_source_header_rates_tab,
		x_source_line_rates_tab=>l_tl_source_line_rates_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'OM_TL_Rate failed');
		      raise FND_API.G_EXC_ERROR;
	       END IF;
	END IF;


	IF(l_tl_source_header_rates_tab.COUNT > 0)
	THEN

		l_all_lane_failed:=false;

	END IF;



      	IF (l_all_lane_failed) THEN

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found');
	  p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_NO_RATES_FOUND');
          p_source_header_tab(i).message_data := FND_MESSAGE.GET;
          l_fail_group_count := l_fail_group_count + 1;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_OMDEL_FL');
      FND_MESSAGE.SET_TOKEN('CONSOLIDATION_ID',p_source_header_tab(i).consolidation_id);
      FND_MSG_PUB.ADD;

	ELSE -- found rate

	  -- Pick minimum of TL and non-TL all rates are in target currency

	  IF ((l_tl_source_header_rates_tab.COUNT=0)
	  	OR((l_lowest_lane_rate IS NOT NULL ) AND (l_lowest_lane_rate < l_tl_source_header_rates_tab(l_tl_source_header_rates_tab.FIRST).price)))
	  THEN


		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found Lowest rate:');
		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_index='||l_lowest_lane_index);
		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate='||l_lowest_lane_rate);
		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate_uom='||l_lowest_lane_rate_uom);

		  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating line_rate and header_rate...');
		  populate_rate (
			p_source_header_rec		=> p_source_header_tab(i),
			p_service_rec			=> l_matched_services(l_lowest_lane_index),
			p_lane_rate			=> l_lowest_lane_rate,
			p_lane_rate_uom 		=> l_lowest_lane_rate_uom,
			p_fc_temp_price 		=> l_lowest_lane_fct_price,
			p_fc_temp_charge 		=> l_lowest_lane_fct_charge,
			x_source_line_rates_tab 	=> x_source_line_rates_tab,
			x_source_header_rates_tab 	=> x_source_header_rates_tab,
			x_return_status           	=> l_return_status);

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate_rate_failed');
		    raise FND_API.G_EXC_ERROR;

		  END IF;
	   ELSE

		Append_Rates(
			p_source_header_rates_tab=>l_tl_source_header_rates_tab,
			p_source_line_rates_tab=>l_tl_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_return_status=>l_return_status);

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Append_Rates');
		    raise FND_API.G_EXC_ERROR;

		  END IF;

	   END IF;




	  print_rates_tab(
	      p_source_line_rates_tab => x_source_line_rates_tab,
	      p_source_header_rates_tab => x_source_header_rates_tab,
	      x_return_status => l_return_status);

      	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
    	      raise FND_API.G_EXC_ERROR;

      	  END IF;

      	END IF; -- found rate

      END IF; -- found services

    END IF;  -- search services successful

   END LOOP; -- p_source_header_tab loop

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_group_count='||l_group_count);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_fail_group_count='||l_fail_group_count);

  IF (l_fail_group_count = l_group_count) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
      FND_MSG_PUB.ADD;
  ELSIF (l_fail_group_count = 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_SUC_W');
      FND_MSG_PUB.ADD;
        -- Standard check of p_commit.
	--
        IF FND_API.To_Boolean( p_commit )
	THEN
                COMMIT WORK;
        END IF;
  END IF;

    END IF; -- p_action <> 'GET_RATE_CHOICE'

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'here is what we return to OM...');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

	    print_rates_tab(
	      p_source_line_rates_tab => x_source_line_rates_tab,
	      p_source_header_rates_tab => x_source_header_rates_tab,
	      x_return_status => l_return_status
		);

      	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
    	      raise FND_API.G_EXC_ERROR;

      	    END IF;

    print_source_header_tab(
      p_source_header_tab => p_source_header_tab,
      x_return_status => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'print_failed');
	  raise FND_API.G_EXC_ERROR;
    END IF;

	--
	--
        -- Standard call to get message count and if count is 1,get message info.
	--
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   FTE_FREIGHT_PRICING_UTIL.close_logs;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
      FND_MSG_PUB.ADD;
        ROLLBACK TO GET_FREIGHT_COSTS;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
      FND_MSG_PUB.ADD;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
        ROLLBACK TO GET_FREIGHT_COSTS;
   WHEN others THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
      FND_MSG_PUB.ADD;
        ROLLBACK TO GET_FREIGHT_COSTS;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
          );
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  END Get_Freight_Costs;


END FTE_FREIGHT_RATING_PUB;

/
