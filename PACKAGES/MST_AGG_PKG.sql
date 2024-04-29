--------------------------------------------------------
--  DDL for Package MST_AGG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_AGG_PKG" AUTHID CURRENT_USER AS
/*$Header: MSTAGGQS.pls 115.14 2004/06/09 10:19:51 skakani noship $ */

   TYPE NumList IS TABLE OF NUMBER;
   P_Delim CONSTANT VARCHAR2(10) := '#';
   OE      CONSTANT VARCHAR2(10) := 'OE';
   RFC     CONSTANT VARCHAR2(10) := 'RFC';   -- Return from Customer
   PO      CONSTANT VARCHAR2(10) := 'PO';
   RTV     CONSTANT VARCHAR2(10) := 'RTV';   -- Return to Vendor


   G_Time_delim CONSTANT VARCHAR2(1) := ':';
   G_delim      CONSTANT VARCHAR2(1) := '#';

   ORGANIZATION CONSTANT NUMBER := 1;
   CUSTOMER CONSTANT NUMBER :=2;
   CARRIER CONSTANT NUMBER := 3;
   SUPPLIER CONSTANT NUMBER := 4;

   TRUCK    CONSTANT VARCHAR2(5) := 'TRUCK';  -- TRUCK
   DTL      CONSTANT VARCHAR2(3) := 'DTL';    -- Direct TL
   MTL      CONSTANT VARCHAR2(3) := 'MTL';    -- Multistop TL
   LTL      CONSTANT VARCHAR2(3) := 'LTL';    -- LESS THAN TRUCK
   PARCEL   CONSTANT VARCHAR2(6) := 'PARCEL'; -- PARCEL
/********************************************************
   g_num_of_facilities number;
   p_delim varchar2(10) := '#';
   OE varchar2(10) := 'OE';
   RFC varchar2(10) := 'RFC';   -- Return from Customer
   PO varchar2(10) := 'PO';
   RTS varchar2(10) := 'RTS';   -- Return to Supplier
   ******************************************************/

/* Plan Summary */
  function get_loads_count(p_plan_id in number)
    return number;

  function get_trip_count(p_plan_id in number, p_mode_of_transport in varchar2)
    return number;

  function get_cm_count(p_plan_id in number)
    return number;

  function get_loads_orders(p_plan_id in number)
    return number;

  function get_trip_orders(p_plan_id in number, p_mode_of_transport in varchar2)
    return number;

  function get_cm_orders(p_plan_id in number)
    return number;

  function get_unassigned_order_count(p_plan_id in number)
    return number;
  function get_unassigned_order_weight(p_plan_id in number)
    return number;
  function get_unassigned_order_cube(p_plan_id in number)
    return number;
  function get_unassigned_order_pieces(p_plan_id in number)
    return number;
  function get_unassigned_order_pallets(p_plan_id in number)
    return number;

/* All Truckloads Summary */
  function get_summary_fixed_charge(p_plan_id in number, p_mode in varchar2)
    return number;

  function get_summary_stop_charge(p_plan_id in number)
    return number;

  function get_summary_ld_unld_charge(p_plan_id in number)
    return number;

  function get_summary_layover_charge(p_plan_id in number)
    return number;

  function get_summary_assessorial_charge(p_plan_id in number, p_mode in varchar2)
    return number;

/* TruckLoad Details */
FUNCTION Get_alloc_cost_for_delivery(p_plan_id IN NUMBER,
                                     p_delivery_id IN NUMBER)
    RETURN NUMBER;

/* Vehicle Trip Stop Details */
  function get_loading_charge(p_plan_id IN NUMBER,
                              p_stop_id in number)
    return number;

  function get_unloading_charge(p_stop_id in number)
    return number;
-- Loading Weight/Cube/Pallets/Pieces
  function get_loading_weight(p_stop_id in number)
    return number;
  function get_loading_volume(p_stop_id in number)
    return number;

  function get_loading_pallets(p_stop_id in number)
    return number;

  function get_loading_pieces(p_stop_id in number)
    return number;
-- Unloading Weight/Cube/Pallets/Pieces
  function get_unloading_weight(p_stop_id in number)
    return number;

  function get_unloading_volume(p_stop_id in number)
    return number;

  function get_unloading_pallets(p_stop_id in number)
    return number;

  function get_unloading_pieces(p_stop_id in number)
    return number;

/* Vehicle Trip Leg Details */
-- No aggregation fields:
-- On board weight/cube/pallets/pieces can be fetched directly from MST_TRIP_STOPS
-- the columns are departure weight/cube/pieces/pallets of the first stop

-- On board orders:
---- ?????

-- Distance Charge:
---- ?????

-- Max weight/cube/pallets for a vehicle
/*
select
item.maximum_load_weight max_load_weight,
??decode() max_load_volume -- based on direct move, pool move, stop numbers, the effective cap could be different
pallet_floor_space * pallet_stacking_height max_number_of_pallets
from fte_vehicle_types fte, mtl_system_items item
where vehicle_type_id = p_vehicle_type_id
and fte.organization_id = item.organization_id
and fte.inventory_item_id = item.inventory_item_id
*/

/* Delivery Details */
  function get_delivery_cost(p_delivery_id in number)
    return number;

/* LTL/Parcel Summary */
-- Weight Based/Minimum charges
---- use get_summary_fixed_charge() with appropriate mode and plan_id

-- Assessorial charges
---- use get_summary_assessorial_charge() with appropriate mode and plan_id

/* LTL/Parcel Details */
-- no aggregate functions, cost/weight/cube/pallets/pieces can be fetched
--  directly from base tables in view


/* All Continuous Moves */
  function get_total_savings(p_plan_id in number)
    return number;

  function get_percent_of_tl_in_cm(p_plan_id in number)
    return number;

/* Continuous Move Details */
-- open issues

/* All Orders */
-- number of orders, total costs can be fetched directly from MST_PLANS
/* Order Details */
   function get_order_weight(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number;

   function get_order_cube(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number ;

   function get_order_pallets(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number;

   function get_order_pieces(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number;

/* Carrier Details */

   function get_carrier_total_cost(p_plan_id in number, p_carrier_id in number)
      return number;

   function get_carrier_weight(p_plan_id in number, p_carrier_id in number)
      return number;

   function get_carrier_volume(p_plan_id in number,p_carrier_id in number)
      return number;
   function get_carrier_pallets(p_plan_id in number,p_carrier_id in number)
      return number;
   function get_carrier_pieces(p_plan_id in number,p_carrier_id in number)
      return number;
   function get_carrier_orders(p_plan_id in number,p_carrier_id in number)
      return number;

/* Service Details */
-- Should we exclude cost for tls in CM for mode = TL?
   function get_carrier_service_total_cost(p_plan_id in number,
                p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number;

   function get_carrier_service_weight(p_plan_id in number, p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number;
   function get_carrier_service_volume(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number;
   function get_carrier_service_pallets(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number;
   function get_carrier_service_pieces(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number;

/* Customer Details */
   function get_total_cost_cust (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_weight_cust (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_cube_cust (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_pallets_cust (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_pieces_cust  (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_orders_cust  (p_plan_id in number, p_customer_id in number)
      return number;

   function get_total_trip_count_partner  (p_plan_id in number, p_partner_id in number, p_partner_type in number )
      return varchar2 ;

   function get_customer_facilities(p_plan_id in number, p_customer_id in number)
      return NumList;

   function get_num_of_stops_for_tl(p_plan_id in number, p_trip_id in number)
      return number;

   function get_first_or_last_delivery_leg(p_plan_id in number, p_delivery_id in number, p_type in number)
      return number ;
/* Supplier Details */
   function get_total_cost_supp (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_total_weight_supp (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_total_cube_supp (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_total_pallets_supp (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_total_pieces_supp  (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_total_orders_supp  (p_plan_id in number, p_supplier_id in number)
      return number;

   function get_supplier_facilities(p_plan_id in number, p_supplier_id in number)
      return NumList;


/* Customer/Supplier Facility Details */
   function get_total_cost_c_s_fac (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number;


   function get_total_weight_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number;

   function get_total_cube_c_s_fac  (p_plan_id in number,p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number;
   function get_total_pallets_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number;
   function get_total_pieces_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number;
   function get_total_order_c_s_fac (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number,p_location_id in number)
      return number;
-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_direct_tls_facility for consistency
   FUNCTION get_total_tl_count_c_s_fac
                                      (p_plan_id           IN NUMBER,
                                       p_partner_id        IN NUMBER,
                                       p_partner_type      IN NUMBER,
                                       p_location_id       IN NUMBER,
                                       p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_trips_facility for consistency
   FUNCTION get_total_trips_c_s_fac  (p_plan_id           IN NUMBER,
                                       p_partner_id        IN NUMBER,
                                       p_partner_type      IN NUMBER,
                                       p_location_id       IN NUMBER,
                                       p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;

/* My Facility Details*/
-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_trips_Myfacility for consistency
   FUNCTION get_total_trips_for_myfac( p_plan_id           IN NUMBER,
                                        P_Fac_Loc_Id        IN NUMBER,
                                        p_mode_of_transport IN VARCHAR2,
                                        p_location_type     IN VARCHAR2)
      RETURN NUMBER;

-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_orders_Myfacility for consistency
-- the implementation logic has also been changed to aggregate on TP orders instead of raw orders
   FUNCTION get_total_orders_for_myfac(  p_plan_id            IN NUMBER,
                                         p_my_fac_location_id IN NUMBER,
                                         p_mode               IN VARCHAR2 DEFAULT null,
                                         p_activity_type      IN VARCHAR2 DEFAULT null)
      RETURN NUMBER;

-- loading/unloading/total cost for TL/LTL/Parcel
   function get_loading_cost_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_unloading_cost_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_total_cost_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

-- loading/unloading weight/cube/pallets/pieces for TL/LTL/Parcels

   function get_loading_weight_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_unloading_weight_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_loading_cube_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_unloading_cube_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_loading_pallet_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_unloading_pallet_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_loading_piece_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

   function get_unloading_piece_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number;

/* Carrier Details */
/* Carrier Facility Details */
/* The following functions for Carrier Details and Carrier Facility Details windows were created by Sasidhar */
-- Function# 46.
   FUNCTION get_total_trips_carrier(p_plan_id           IN NUMBER,
                                    p_carrier_id        IN NUMBER)
    RETURN VARCHAR2;
-- Function# 47.
   FUNCTION get_total_cost_carrier(p_plan_id           IN NUMBER,
                                   p_carrier_id        IN NUMBER)
    RETURN NUMBER;
-- Function# 48.
   FUNCTION get_total_weight_carr_facility(p_plan_id       IN NUMBER,
                                           p_carrier_id    IN NUMBER,
                                           p_location_id   IN NUMBER,
                                           p_location_type IN VARCHAR2,
                                           p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
-- Function# 49.
   FUNCTION get_total_cube_carr_facility(p_plan_id       IN NUMBER,
                                         p_carrier_id    IN NUMBER,
                                         p_location_id   IN NUMBER,
                                         p_location_type IN VARCHAR2,
                                         p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
-- Function# 50.
   FUNCTION get_tot_pal_carr_facility(p_plan_id       IN NUMBER,
                                      p_carrier_id    IN NUMBER,
                                      p_location_id   IN NUMBER,
                                      p_location_type IN VARCHAR2,
                                      p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
-- Function# 51.
   FUNCTION get_tot_Pieces_carr_facility(p_plan_id       IN NUMBER,
                                         p_carrier_id    IN NUMBER,
                                         p_location_id   IN NUMBER,
                                         p_location_type IN VARCHAR2,
                                         p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
-- Function# 52.
-- the implementation logic has been changed to aggregate on TP orders instead of raw orders
   FUNCTION get_tot_Orders_carr_facility(p_plan_id       IN NUMBER,
                                        p_carrier_id    IN NUMBER,
                                        p_fac_location_id   IN NUMBER,
                                        p_activity_type IN VARCHAR2,
                                        p_mode IN VARCHAR2
                                        )
      RETURN NUMBER;
-- Function# 53.
   FUNCTION get_tot_trips_carr_Facility(p_plan_id     IN NUMBER,
                                        p_carrier_id  IN NUMBER,
                                        P_LOCATION_ID IN NUMBER,
                                        p_location_type IN VARCHAR2,
                                        p_mode_of_transport IN VARCHAR2)
    RETURN NUMBER;
   FUNCTION get_direct_tls_carr_facility
                                      (p_plan_id        IN NUMBER,
                                       p_carrier_id     IN NUMBER,
                                       p_location_id    IN NUMBER,
                                       p_Location_type  IN VARCHAR2,
                                       p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER;
    FUNCTION get_total_cost_carr_fac(p_plan_id           IN NUMBER,
                                     p_carrier_id        IN NUMBER,
                                     p_location_id       IN NUMBER,
                                     p_mode_of_transport IN VARCHAR2)
    RETURN NUMBER;


-- Used by view definitions of Delivery Line grids:
-- 1. Call this function when source_code = OE for the Destination Company Name:
-- p_location_id = MST_DELIVERY_DETAILS.ship_to_location_id
-- p_customer_id = MST_DELIVERY_DETAILS.customer_id
-- 2. Call this function when source_code = OE for the Origin Company Name:
-- p_location_id = MST_DELIVERY_DETAILS.ship_from_location_id
-- p_customer_id = null

function get_owner_name_for_del_line(p_location_id IN number, p_customer_id IN number)
  return varchar2 ;

-- Used by view definitions of Delivery Leg grids:
-- Call this function to get both the Origin Company Name and the Destination Company Name

function get_owner_name_for_del_leg(p_location_id IN number,
                                    p_plan_id IN NUMBER,
                                    p_delivery_id IN number)
  return varchar2;

-- Used by view definitions of Trips/Loads/Stops/Trip-legs grids:
-- Call this function to get both the Origin Company Name and the Destination Company Name

function get_owner_name_for_trip(p_location_id IN number)
  return varchar2;

  -- Utility functions used by release related views

  --  TRIP related functions ------------

   function get_total_trip_weight(p_plan_id in number,
                                  p_trip_id in number)
      return number;

   function get_total_trip_volume(p_plan_id in number,
                                  p_trip_id in number)
      return number;


   function get_total_trip_pallets(p_plan_id in number,
                                   p_trip_id in number)
      return number;


   function get_total_trip_pieces(p_plan_id in number,
                                  p_trip_id in number)
      return number;

   ---- PLAN related functions -------------


   function get_total_direct_tls(p_plan_id in number)
      return number;

   function get_total_direct_mstop_tls(p_plan_id in number)
      return number;

   function get_total_tls_in_cms(p_plan_id in number)
      return number;

   function get_total_excp_in_plan(p_plan_id in number)
      return number;

   function get_total_excp_in_trip(p_plan_id in number, p_trip_id in number)
      return number;

        function get_auto_release_trip_count (p_plan_id number, p_mode varchar2)
        return number;

        function get_released_trip_count (p_plan_id number, p_mode varchar2)
        return number;

        function get_release_failed_trip_count (p_plan_id number, p_mode varchar2)
        return number;

        function get_flag_for_rel_trip_count (p_plan_id number, p_mode varchar2)
        return number;

        function get_not_rel_trip_count (p_plan_id number, p_mode varchar2)
        return number;

        function get_auto_release_cm_count (p_plan_id number)
        return number;

        function get_released_cm_count (p_plan_id number)
        return number;

        function get_rel_failed_cm_count (p_plan_id number)
        return number;

        function get_flag_for_rel_cm_count (p_plan_id number)
        return number;

        function get_not_rel_cm_count (p_plan_id number)
        return number;

        function get_total_excp_in_cm(p_plan_id in number, p_cm_id in number)
        return number;

END MST_AGG_PKG;

 

/
