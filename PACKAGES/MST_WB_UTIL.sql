--------------------------------------------------------
--  DDL for Package MST_WB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_WB_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSTWUTLS.pls 120.1 2005/05/27 05:20:38 appldev  $ */

--Bug_Fix for 4394839
/**
 *	Returns the value of profile "MST: Operator Company Name"
 *	or 'CUSTOMER', 'SUPPLIER', 'CARRIER'
 *	depending on the company type.
 */
  FUNCTION get_company_type ( p_facility_id IN NUMBER )
  RETURN VARCHAR2;

/*
  Returns the format string for the type indicated by the argument "p_format_type"
  For Numbers: p_format_type = 'NUMBER'
*/
  FUNCTION get_format_string ( p_format_type IN VARCHAR2 )
  RETURN VARCHAR2;

-- Function#  14.
   FUNCTION get_total_order_weight( p_plan_id              IN NUMBER,
                                    p_source_code          IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER;
-- Function#  15.
   FUNCTION get_total_order_volume( p_plan_id              IN NUMBER,
                                    p_source_code          IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER;
-- Function#  16.
   FUNCTION get_total_order_pallets(p_plan_id              IN NUMBER,
                                    p_source_code          IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER;
-- Function#  17.
   FUNCTION get_total_order_pieces( p_plan_id              IN NUMBER,
                                    p_source_code          IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER;
-- Function#  18.
   FUNCTION get_total_order_cost ( p_plan_id              IN NUMBER,
                                   p_source_code          IN VARCHAR2,
                                   p_source_header_number IN VARCHAR2)
      RETURN NUMBER;

-- Function#  26.
   FUNCTION Get_Trip_Circuity(P_Plan_id IN NUMBER,
                              P_Trip_id IN NUMBER)
	  RETURN NUMBER;
-- Function#  27.
   FUNCTION Get_Trip_Stops(P_Plan_id IN NUMBER,
                           P_Trip_id IN NUMBER)
	  RETURN NUMBER;
-- Function#  28.
   FUNCTION Get_Trip_Orders(P_plan_id IN NUMBER,
                            P_TRIP_ID IN NUMBER )
	  RETURN NUMBER;
-- Function#  29.
   FUNCTION Get_Trip_Det(P_plan_id    IN NUMBER,
                         P_Trip_Id    IN NUMBER,
						 P_Return_val IN VARCHAR2)
	RETURN NUMBER;
-- Function#  30.
   FUNCTION Get_Trip_Det(P_plan_id    IN NUMBER,
                         P_Trip_Id    IN NUMBER,
						 P_Stop_Id    IN NUMBER,
						 P_Stop_Type  IN VARCHAR2,
						 P_Return_val IN VARCHAR2)
	  RETURN NUMBER;
-- Function#  31.
   FUNCTION Get_STOP_Orders(P_plan_id IN NUMBER,
                            P_TRIP_ID IN NUMBER,
			                P_Stop_Id IN NUMBER )
	  RETURN NUMBER;
-- Function#  32.
   FUNCTION GET_DELIVERY_ORDERS(P_Plan_Id       IN NUMBER,
                                P_DELIVERY_ID   IN NUMBER,
						        P_Delivery_Flag IN VARCHAR2 )
	  RETURN NUMBER;
-- Function#  33.
   FUNCTION Get_Name(P_Location_id IN NUMBER)
      RETURN VARCHAR2;
-- Function#  34.
   FUNCTION Get_meaning( p_Lookup_Type IN VARCHAR2,
                         p_Lookup_Code IN VARCHAR2,
                         p_Product     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION Get_Partner_Name(P_PARTY_id IN Number, P_PARTY_type IN Number)
      RETURN VARCHAR2;

-- Function#  35.
   FUNCTION Get_Cont_Move_Distance( p_Plan_Id      IN NUMBER,
                                    p_cont_move_id IN NUMBER)
      RETURN NUMBER;
-- Function#  36.
   FUNCTION GET_FIRST_DEPARTURE_DATE(P_PLAN_ID IN NUMBER,
                                     P_TRIP_ID IN NUMBER)
      RETURN DATE;
-- Function#  37.
   FUNCTION GET_LAST_ARRIVAL_DATE(P_PLAN_ID IN NUMBER,
                                  P_TRIP_ID IN NUMBER)
      RETURN DATE;
-- Function#  38.
   FUNCTION Get_Cont_Move_total_loads( p_Plan_Id      IN NUMBER,
                                       p_cont_move_id IN NUMBER)
      RETURN NUMBER;

  FUNCTION get_effective_cube_capacity(p_plan_id  IN NUMBER,
                                p_trip_id IN NUMBER)
    RETURN NUMBER;
-- Function#  39.
   FUNCTION GET_VEHICLE_CAPACITY(P_Plan_Id         IN NUMBER,
                                 P_VEHICLE_TYPE_ID IN NUMBER,
			                     P_Ret_Val         IN VARCHAR2)
      RETURN NUMBER;
-- Function#  40.
   FUNCTION ELAPSED_TIME(P_Start_Date IN DATE,
                         P_End_Date   IN DATE)
      RETURN VARCHAR2;
-- Function#  41.
   FUNCTION ELAPSED_TIME(P_End_Date IN DATE,
                         P_Delay    IN NUMBER)
      RETURN VARCHAR2;
-- Function#  42.
   FUNCTION get_threshold_value (p_exception_type IN NUMBER)
      RETURN VARCHAR2;
-- Function#  43.
   FUNCTION get_facility_owner(P_Facility_id IN NUMBER, P_Delim IN VARCHAR2)
    RETURN VARCHAR2;
-- Function#  44.
   FUNCTION Get_Contact_name(p_contact_id IN NUMBER)
   RETURN VARCHAR2;
-- Function#  45.
   FUNCTION get_phone_number(p_contact_id IN NUMBER)
    RETURN VARCHAR2;
   FUNCTION get_min_sec(p_hours NUMBER)
    RETURN VARCHAR2;
   FUNCTION get_hr_min(p_hours IN NUMBER)
    RETURN VARCHAR2;
   FUNCTION get_local_chardt(p_location_id IN NUMBER, p_date IN DATE)
    RETURN VARCHAR2;
   FUNCTION get_local_chardtzone(p_location_id IN NUMBER, p_date IN DATE)
    RETURN VARCHAR2;
   FUNCTION GET_LEG_NUMBER(P_PLAN_ID IN NUMBER,
                           P_TRIP_ID IN NUMBER,
                           P_STOP_ID IN NUMBER)
    RETURN NUMBER;
   FUNCTION GET_TRIP_UTILIZATION(P_PLAN_ID IN NUMBER,
                                 P_TRIP_ID IN NUMBER)
    RETURN NUMBER;

   FUNCTION GET_TRIP_REMAINING_TIME(P_PLAN_ID IN NUMBER,
                                    P_TRIP_ID IN NUMBER)
    RETURN NUMBER;
   FUNCTION GET_CM_REMAINING_TIME(P_PLAN_ID IN NUMBER,
                                  P_CM_ID IN NUMBER)
    RETURN NUMBER;

    FUNCTION GET_TRIP_TOKENIZED_EXCEPTION(P_PLAN_ID IN NUMBER,
                                 P_EXCEPTION_DETAIL_ID IN NUMBER,
				 P_TRIP_ID IN NUMBER,
				 P_LINE_NUM IN NUMBER)
    RETURN VARCHAR2;


  --p_contact_id expects party_id (as defined in hz_parties) as input
  --p_ret_str_type expects 'NAME', 'EMAIL' or 'PHONE' as input
  --p_owner_type_id expects owner_type (as defined in wsh_location_owners) as input
    FUNCTION GET_CONTACT_INFO (P_CONTACT_ID IN NUMBER
                              ,P_RET_STR_TYPE IN VARCHAR2
			      ,P_OWNER_TYPE_ID IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2;


/**************************USED IN REPORTS***************************/

function r_get_canonical_number (p_number            in number
                               , p_format_mask_ident in number default 1)
return varchar2;

function r_get_company_name(p_location_id in number, p_owner_type in number)
return varchar2;

function r_plan_value (p_plan_id in number)
return number;

function r_plan_alloc_cost (p_plan_id in number)
return number;
/*
function r_total_orders_myfac(p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2, p_activity_type in varchar2)
return number;
*/
function r_total_cost_myfac  (p_plan_id in number,p_my_fac_location_id in number, p_mode in varchar2)
return number;

function r_loading_weight_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
return number;

function r_loading_cube_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
return number;

function r_loading_piece_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
return number;

function r_value_myfac(p_plan_id in number, p_facility_id in number)
return number;

function r_total_orders_myfac_general (p_plan_id in number, p_my_fac_location_id in number)
return number;

function r_total_weight_myfac (p_plan_id in number, p_facility_id in number)
return number;

function r_total_cube_myfac (p_plan_id in number, p_facility_id in number)
return number;

function r_total_pieces_myfac (p_plan_id in number, p_facility_id in number)
return number;

function r_total_trans_cost_myfac (p_plan_id in number, p_facility_id in number)
return number;

function r_value_origin(p_plan_id in number, p_origin_id in number)
return number;

function r_get_alloc_cost_origin (p_plan_id in number, p_origin_id in number)
return number;

function r_get_total_orders_origin (p_plan_id in number, p_origin_id in number)
return number;

function r_get_count_stops_origin (p_plan_id in number, p_origin_id in number)
return number;

function r_get_total_weight_origin (p_plan_id in number, p_origin_id in number)
return number;

function r_get_total_volume_origin (p_plan_id in number, p_origin_id in number)
return number;

function r_get_total_pieces_origin (p_plan_id in number, p_origin_id in number)
RETURN number;

FUNCTION r_get_trip_count_origin (p_plan_id in number, p_origin_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_cost_origin (p_plan_id in number, p_origin_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_count_dtl_origin (p_plan_id in number, p_origin_id in number)
RETURN number;

function r_value_dest(p_plan_id in number, p_dest_id in number)
return number;

function r_get_alloc_cost_dest (p_plan_id in number, p_dest_id in number)
return number;

FUNCTION r_get_total_orders_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

FUNCTION r_get_count_stops_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

FUNCTION r_get_total_weight_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

FUNCTION r_get_total_volume_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

FUNCTION r_get_total_pieces_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

FUNCTION r_get_trip_count_dest (p_plan_id in number, p_dest_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_cost_dest (p_plan_id in number, p_dest_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_count_dtl_dest (p_plan_id in number, p_dest_id in number)
RETURN number;

function r_value_cust(p_plan_id in number, p_customer_id in number)
return number;

function r_get_alloc_cost_cust (p_plan_id in number, p_customer_id in number)
return number;

FUNCTION r_get_count_stops_cust (p_plan_id in number, p_customer_id in number)
RETURN number;

FUNCTION r_get_trip_count_cust (p_plan_id in number, p_customer_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_cost_cust (p_plan_id in number, p_customer_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_count_dtl_cust (p_plan_id in number, p_customer_id in number)
RETURN number;

function r_value_supp(p_plan_id in number, p_supplier_id in number)
return number;

function r_get_alloc_cost_supp (p_plan_id in number, p_supplier_id in number)
return number;

FUNCTION r_get_count_stops_supp (p_plan_id in number, p_supplier_id in number)
RETURN number;

FUNCTION r_get_trip_count_supp (p_plan_id in number, p_supplier_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_cost_supp (p_plan_id in number, p_supplier_id in number, p_mode_of_transport in varchar2)
RETURN number;

FUNCTION r_get_count_dtl_supp (p_plan_id in number, p_supplier_id in number)
RETURN number;

function r_get_wait_time_at_stop (p_plan_id in number, p_stop_id in number, p_trip_id in number)
return varchar2;

function r_get_prev_carr_detail (p_plan_id in number,p_delivery_id in number,p_trip_id in number, p_stop_location_id in number, p_identifier in varchar2)
return number;

function r_get_prev_stop_seqnum (p_plan_id in number, p_trip_id in number, p_curr_seq_num in number)
return number;

function r_get_prev_trip_detail (p_plan_id in number, p_trip_id in number, p_curr_seq_num in number, p_identifier in varchar2)
return number;

function r_get_pool_loc_detail (ret_type in varchar2, loc_id in number)
return varchar2;

function r_dep_frm_dest(p_plan_id in number, p_trip_id in number, p_stop_location_id in number)
return varchar2;

function r_get_order_cost(p_source_code in varchar2,p_source_header_number in varchar2)
return number;

function r_checkif_orig_ispool (p_plan_id in number,p_delivery_id in number,p_delivery_leg_id in number,p_pick_up_stop_id in number)
return varchar2;

function r_checkif_dest_ispool (p_plan_id in number,p_delivery_id in number,p_delivery_leg_id in number,p_drop_off_stop_id in number)
return varchar2;

  PROCEDURE Execute_Report (ERRBUF OUT NOCOPY VARCHAR2
                    ,RETCODE OUT NOCOPY VARCHAR2
                    , request_id out nocopy number
                    , arg1 in number
                    , arg2 in number
                    , arg3 in number
                    , arg4 in number
                    , arg5 in number
                    , arg6 in number
                    , arg7 in varchar2
                    , arg8 in varchar2
                    , arg9 in number
                    , arg10 in number
                    );

 /******************************************************************************/

  FUNCTION GET_COST_WIHTOUT_CM_FOR_TRIPS (P_PLAN_ID IN NUMBER,
                                          P_TRIP_ID1 IN NUMBER,
					  P_TRIP_ID2 IN NUMBER)
  RETURN NUMBER;

  FUNCTION GET_LOAD_TYPE (P_PLAN_ID IN NUMBER,
                          P_TRIP_ID IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION GET_ACT_TOKENIZED_EXCEPTION(P_PLAN_ID IN NUMBER,
                                       P_OUT_REQUEST_DETAIL_ID IN NUMBER,
				       P_EXCEPTION_TYPE IN NUMBER,
				       P_LINE_NUM IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION adjust_to_server_time(p_datetime IN DATE,
                                 p_location_id IN NUMBER,
                                 p_facility_id IN NUMBER) RETURN DATE;


  FUNCTION convert_time(p_time      IN NUMBER,
                        p_uom_from  IN VARCHAR2,
                        p_uom_to    IN VARCHAR2) RETURN NUMBER;

  /**************FOLLOWING ARE BEING USED FOR PURGE PLAN************************/

  procedure purge_plan (p_err_code           OUT NOCOPY VARCHAR2
                      , p_err_buff           OUT NOCOPY VARCHAR2
                      , p_plan_id            IN         NUMBER
                      , p_compile_designator IN         VARCHAR2
                      , p_description        IN         VARCHAR2);

  procedure submit_purge_plan_request ( p_request_id         OUT NOCOPY NUMBER
                                      , p_plan_id            IN         NUMBER
                                      , p_compile_designator IN         VARCHAR2
                                      , p_description        IN         VARCHAR2);

  /******************************************************************************/

 function get_org_id(p_plan_id in number, p_delivery_id in number) return number;

 function get_workflow_status (p_plan_id in number, p_exception_detail_id in number) return varchar2;

 function get_city_code(p_location_id NUMBER) return VARCHAR2;

 procedure Compute_Exception_Counts(p_Plan_Id IN NUMBER, p_Exp_Summary_Where_Clause IN VARCHAR2, p_Exp_Details_Where_Clause IN VARCHAR2);

 PROCEDURE run_dynamic_sql(p_query_string IN VARCHAR2);

 PROCEDURE notify_engine(p_plan_id     IN NUMBER,
                         p_object_type IN NUMBER,
                         p_object_id   IN NUMBER,
                         p_firm_status IN NUMBER);

 PROCEDURE Update_Del_And_Rel_Trips(p_Plan_Id      IN  NUMBER,
                                    p_Trip_Id      IN  NUMBER,
                                    p_Planned_Flag IN  NUMBER,
                                    P_Notified     OUT NOCOPY NUMBER);

 PROCEDURE Update_Trips_Of_CM(p_Plan_Id            IN  NUMBER,
                              p_Continuous_Move_Id IN  NUMBER,
                              P_Notified           OUT NOCOPY NUMBER);

 FUNCTION GET_UOM_CONVERSION_RATE (p_from_uom_code VARCHAR2,
                                   p_to_uom_code VARCHAR2,
				   p_org_id NUMBER,
				   p_inventory_item_id NUMBER)
 RETURN NUMBER;

/*
  Determines whether the rule is for Currency or Weight/Volume/Count
*/
  FUNCTION get_rule_type ( p_rule_id IN NUMBER )
  RETURN VARCHAR2;

  FUNCTION get_row_count (p_view_name IN VARCHAR2, p_where_clause in VARCHAR2)
  RETURN NUMBER;

END MST_WB_UTIL;

 

/
