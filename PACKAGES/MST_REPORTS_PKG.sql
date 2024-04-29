--------------------------------------------------------
--  DDL for Package MST_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: MSTREPOS.pls 115.3 2004/06/17 15:44:32 bramacha noship $ */

  --define/declare package level variables here
  -- g_release_type                number; -- being used in MSTEXCEP.pld

  --declare functions/procedures here
  --

function get_plan_order_count (p_plan_id       in number
                             , p_report_for    in number
			     , p_report_for_id in number) return number;

function get_order_group_count (p_plan_id       in number
                             , p_report_for     in number
			     , p_report_for_id  in number) return number;

function get_weight (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number) return number;

function get_volume (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number) return number;

function get_pieces (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number) return number;

function get_plan_value (p_plan_id in number
                       , p_report_for    in number
    		       , p_report_for_id in number) return number;

function get_trips_per_mode (p_plan_id       in number
                           , p_report_for    in number
		           , p_report_for_id in number
			   , p_mode          in varchar2) return number;

function get_trans_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
		                , p_report_for_id in number
			        , p_mode          in varchar2) return number;

function get_handl_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
		                , p_report_for_id in number
		                , p_mode         in varchar2) return number;

function get_total_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
      		                , p_report_for_id in number
		                , p_mode          in varchar2) return number;

function get_stops_per_load (p_plan_id       in number
                           , p_report_for    in number
      		           , p_report_for_id in number) return number;

function get_TL_distance (p_plan_id       in number
                        , p_report_for    in number
                        , p_report_for_id in number) return number;

function get_carr_movements(p_plan_id       in number
                          , p_report_for    in number
                          , p_report_for_id in number
			  , p_carrier_id    in number) return number;

function get_carr_cost(p_plan_id       in number
                     , p_report_for    in number
                     , p_report_for_id in number
		     , p_carrier_id    in number) return number;

function get_orders_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_weight_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_volume_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_pieces_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_MTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_DTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_LTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_PCL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		       , p_orig_state    in varchar2) return number;

function get_total_cost_mode_orig (p_plan_id       in number
                                 , p_report_for    in number
      		                 , p_report_for_id in number
		                 , p_mode          in varchar2
		       , p_orig_state    in varchar2) return number;

function get_orders_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_weight_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_volume_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_pieces_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_MTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_DTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_LTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_PCL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		       , p_destination_state    in varchar2) return number;

function get_total_cost_mode_dest (p_plan_id            in number
                                 , p_report_for         in number
      		                 , p_report_for_id      in number
		                 , p_mode               in varchar2
		       , p_destination_state    in varchar2) return number;

function get_orders_myfac (p_plan_id       in number
                         , p_report_for    in number
			 , p_report_for_id in number
			 , p_myfac_id      in number) return number;

function get_weight_myfac (p_plan_id       in number
                         , p_report_for    in number
   	  	         , p_report_for_id in number
		         , p_myfac_id      in number) return number;

function get_volume_myfac (p_plan_id       in number
                         , p_report_for    in number
   	  	         , p_report_for_id in number
		         , p_myfac_id      in number) return number;

function get_pieces_myfac (p_plan_id       in number
                         , p_report_for    in number
   	  	         , p_report_for_id in number
		         , p_myfac_id      in number) return number;

function get_trips_per_mode_myfac (p_plan_id       in number
                                 , p_report_for    in number
		                 , p_report_for_id in number
			         , p_mode          in varchar2
			         , p_myfac_id      in number) return number;

function get_cost_per_mode_myfac (p_plan_id       in number
                                , p_report_for    in number
                                , p_report_for_id in number
	                        , p_mode          in varchar2
				, p_myfac_id      in number) return number;

function get_orders_c_s (p_plan_id       in number
                       , p_report_for    in number
		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number) return number;

function get_weight_c_s (p_plan_id       in number
                       , p_report_for    in number
   		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number) return number;

function get_volume_c_s (p_plan_id       in number
                       , p_report_for    in number
   		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number) return number;

function get_pieces_c_s (p_plan_id       in number
                       , p_report_for    in number
   		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number) return number;

function get_trips_per_mode_c_s (p_plan_id       in number
                               , p_report_for    in number
		               , p_report_for_id in number
			       , p_mode          in varchar2
			       , p_c_s_ident     in number
			       , p_cust_supp_id  in number) return number;

function get_cost_per_mode_c_s (p_plan_id       in number
                              , p_report_for    in number
      		              , p_report_for_id in number
		              , p_mode          in varchar2
			      , p_c_s_ident     in number
			      , p_cust_supp_id  in number) return number;

function get_DTL_c_s (p_plan_id       in number
                    , p_report_for    in number
		    , p_report_for_id in number
		    , p_c_s_ident     in number
		    , p_cust_supp_id  in varchar2) return number;

function get_MTL_c_s (p_plan_id       in number
                    , p_report_for    in number
		    , p_report_for_id in number
		    , p_c_s_ident     in number
		    , p_cust_supp_id  in varchar2) return number;

PROCEDURE Populate_Master_Summary_GTT (p_plan_id       in number
                                     , p_report_for    in number
				     , p_report_for_id in number default 0);

function get_freight_classes_per_order (p_plan_id              in number
                                      , p_source_header_number in number) return varchar2;

/*
 * To calculate the wait time at a particular stop for a given trip in a given plan
 */
function get_wait_time_at_stop ( p_plan_id	in number
                                 , p_trip_id	in number
                                 , p_stop_id	in number ) return varchar2;

END MST_REPORTS_PKG;

 

/
