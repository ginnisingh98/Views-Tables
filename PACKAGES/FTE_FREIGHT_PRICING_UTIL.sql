--------------------------------------------------------
--  DDL for Package FTE_FREIGHT_PRICING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FREIGHT_PRICING_UTIL" AUTHID CURRENT_USER as
/* $Header: FTEFRUTS.pls 120.0 2005/05/26 17:44:32 appldev noship $ */

-- Global Variables

   g_package_name               CONSTANT        VARCHAR2(100) := 'FTE_FREIGHT_PRICING_UTIL';

-- Global Exception ---
   G_NO_PARAMS_FOUND        EXCEPTION;   -- if parameter table is empty or required param is not available
   G_INVALID_PARAM_VAL      EXCEPTION;   -- parameter has an invalid value

   g_total_base_price_failed      EXCEPTION;
   g_apply_new_base_price_failed  EXCEPTION;
   g_create_attribute_failed      EXCEPTION;
   g_create_qual_record_failed    EXCEPTION;
   g_qp_insert_lines2_failed      EXCEPTION;
   g_qp_insert_line_attrs2_failed EXCEPTION;
   g_qp_price_request_failed      EXCEPTION;
   g_invalid_pricing_event        EXCEPTION;
   g_not_on_pricelist             EXCEPTION;
   g_add_qp_output_detail_failed  EXCEPTION;
   g_get_qp_output_failed         EXCEPTION;
   g_clear_qp_input_failed        EXCEPTION;
   g_post_process_failed          EXCEPTION;
   g_remove_gaps_failed           EXCEPTION;


   g_load_rules_failed               EXCEPTION;
   -- g_no_params_found                 EXCEPTION;
   g_total_shipment_weight_failed    EXCEPTION;
   g_create_control_record_failed    EXCEPTION;
   g_create_line_record_failed       EXCEPTION;
   g_create_qualifiers_failed        EXCEPTION;
   g_create_attr_failed              EXCEPTION;
   g_get_next_weight_break_failed    EXCEPTION;

   g_no_volume_found           EXCEPTION;
   g_no_weights_found          EXCEPTION;
   g_weight_uom_not_found      EXCEPTION;
   g_weight_break_not_found    EXCEPTION;
   g_def_wt_break_not_found    EXCEPTION;
   g_invalid_uom_conversion    EXCEPTION;
   g_invalid_uom_code          EXCEPTION;
   g_invalid_wt_break          EXCEPTION;
   g_param_validation_failed   EXCEPTION;
   g_analyse_deficit_failed    EXCEPTION;
   g_delete_set_failed         EXCEPTION;
   g_not_eligible_for_LTL      EXCEPTION;
   g_process_LTL_deficit_failed EXCEPTION;
   g_resolve_pricing_objective EXCEPTION;
   g_apply_min_charge          EXCEPTION;
   g_prepare_next_event_failed EXCEPTION;
   g_parcel_not_eligible       EXCEPTION;
   g_get_bumped_up_wt_failed   EXCEPTION;
   -- g_prepare_next_event_failed EXCEPTION;
   -- g_prepare_next_event_failed EXCEPTION;
   g_process_LTL_failed        EXCEPTION;
   g_process_Parcel_failed     EXCEPTION;
   g_process_others_failed     EXCEPTION;
   g_calc_gross_wt_failed      EXCEPTION;
   g_prorate_failed            EXCEPTION;
   g_qp_price_request_failed_2      EXCEPTION;

   g_no_currency_found         EXCEPTION;
   g_invalid_fc_type           EXCEPTION;
   g_no_lane_found             EXCEPTION;
   g_no_price_list_on_lane     EXCEPTION;
   g_no_party_id_found         EXCEPTION;

   g_proration_failed        EXCEPTION;
   g_delete_qpline_failed    EXCEPTION;
   g_prepare_fc_rec_failed   EXCEPTION;
   g_get_fc_type_failed      EXCEPTION;
   g_other_cont_summ_failed  EXCEPTION;
   g_dleg_sum_not_created    EXCEPTION;
   g_rollup_container_failed EXCEPTION;
   g_invalid_line_quantity   EXCEPTION;
   g_category_not_found      EXCEPTION;
   g_invalid_basis           EXCEPTION;
   g_loose_item_wrong_basis  EXCEPTION;
   g_no_enginerow_created    EXCEPTION;
   g_initialize_failed       EXCEPTION;
   g_dimensional_weight_failed    EXCEPTION;
   g_create_instance_failed  EXCEPTION;
   g_search_instance_failed  EXCEPTION;
   g_add_to_instance_failed  EXCEPTION;
   g_no_lanesched_seg        EXCEPTION;
   g_no_lane_info            EXCEPTION;
   g_no_segment_service_type EXCEPTION;
   g_shipment_pattern_failed EXCEPTION;
   g_currency_code_failed    EXCEPTION;
   g_special_conditions_failed    EXCEPTION;
   g_process_qp_output_failed    EXCEPTION;
   g_create_fc_temp_failed   EXCEPTION;
   g_update_freight_cost_failed    EXCEPTION;
   g_create_freight_cost_failed    EXCEPTION;
   g_no_temp_fc_to_move            EXCEPTION;
   g_delete_fc_temp_failed         EXCEPTION;
   g_noleg_segment           EXCEPTION;
   g_flatten_shipment_failed EXCEPTION;
   g_empty_delivery          EXCEPTION;
   g_shipment_pricing_failed EXCEPTION;
   g_unmark_reprice_req_failed    EXCEPTION;
   g_delete_invalid_fc_failed     EXCEPTION;
   g_missing_service_type    EXCEPTION;
   g_no_input                EXCEPTION;
   g_price_consolidate_failed    EXCEPTION;
   g_pricing_not_required    EXCEPTION;
   g_delivery_not_found      EXCEPTION;

   g_invalid_parameters      EXCEPTION;
   g_ship_prc_compare_fail   EXCEPTION;
   g_unexp_err               EXCEPTION;

   g_freight_costs_int_fail      EXCEPTION;
   g_ln_no_lane_found      EXCEPTION;
   g_ln_too_many_found      EXCEPTION;
   g_lane_search_failed      EXCEPTION;
   g_no_ship_method        EXCEPTION;
   g_invalid_ship_method   EXCEPTION;
   g_get_cost_type_failed  EXCEPTION;
   g_tl_get_schedule_info_fail	EXCEPTION;
   g_get_trip_mode_fail	EXCEPTION;
   g_rank_list_update_fail EXCEPTION;


   g_MDC_get_chld_fract_fail EXCEPTION;
   g_MDC_Get_LPN_cost_rec_fail EXCEPTION;
   g_MDC_alloc_from_consol_LPN EXCEPTION;
   g_MDC_cre_parent_dleg_summ EXCEPTION;
   g_MDC_cre_child_dleg_summ EXCEPTION;
   g_MDC_populate_dleg_id EXCEPTION;
   g_MDC_cre_LPN_summ  EXCEPTION;
   g_MDC_check_rated EXCEPTION;
   g_MDC_handle_MDC EXCEPTION;


   --FTE_TL_CACHE exceptions

   g_tl_no_dleg_id_in_dtl 	EXCEPTION;
   g_tl_weight_uom_conv_fail	EXCEPTION;
   g_tl_vol_uom_conv_fail	EXCEPTION;
   g_tl_no_carrier_or_service	EXCEPTION;
   g_tl_get_carrier_pref_fail	EXCEPTION;
   g_tl_get_car_from_sched_fail EXCEPTION;
   g_tl_get_carr_from_lane_fail  EXCEPTION;
   g_tl_get_lane_info_fail	EXCEPTION;
   g_tl_trip_id_from_dleg_fail	EXCEPTION;
   g_tl_dates_loc_from_dlv_fail	EXCEPTION;
   g_tl_lane_info_with_id_fail	EXCEPTION;
   g_tl_get_trip_info_fail	EXCEPTION;


   g_tl_dist_uom_conv_fail	EXCEPTION;
   g_tl_no_lane_sched_veh	EXCEPTION;
   g_tl_no_lane_sched		EXCEPTION;
   g_tl_combine_carrier_fail	EXCEPTION;
   g_tl_validate_carrier_fail	EXCEPTION;
   g_tl_validate_trip_fail	EXCEPTION;
   g_tl_validate_stop_fail	EXCEPTION;
   g_tl_validate_dlv_dtl_fail	EXCEPTION;
   g_tl_add_dropoff_qty_fail	EXCEPTION;
   g_tl_insert_dlv_dtl_fail	EXCEPTION;
   g_tl_add_pickup_qty_fail	EXCEPTION;
   g_tl_validate_dleg_fail	EXCEPTION;
   g_tl_add_ip_dist_fail	EXCEPTION;
   g_tl_updt_trip_with_stop_fail	EXCEPTION;
   g_tl_get_distances_fail	EXCEPTION;
   g_tl_get_facility_info_fail	EXCEPTION;
   g_tl_init_dummy_dleg_fail	EXCEPTION;
   g_tl_init_dummy_trip_fail	EXCEPTION;
   g_tl_init_dummy_pu_stop_fail	EXCEPTION;
   g_tl_init_dummy_do_stop_fail	EXCEPTION;
   g_tl_add_dlv_dtl_fail	EXCEPTION;
   g_tl_get_car_prf_for_lane_fail	EXCEPTION;
   g_tl_updt_dummy_recs_fail	EXCEPTION;
   g_tl_get_trp_inf_frm_schd_fail	EXCEPTION;
   g_tl_get_trp_inf_frm_lane_fail	EXCEPTION;
   g_tl_get_car_prf_for_schd_fail	EXCEPTION;
   g_tl_cache_trip_fail	EXCEPTION;
   g_tl_cache_first_trp_lane_fail	EXCEPTION;
   g_tl_convert_uom_for_trip_fail	EXCEPTION;
   g_tl_convert_uom_for_stop_fail	EXCEPTION;
   g_tl_convert_uom_for_dleg_fail	EXCEPTION;
   g_tl_build_cache_trp_fail		EXCEPTION;
   g_tl_lane_info_with_sched_fail	EXCEPTION;
   g_tl_get_reg_for_loc_fail	EXCEPTION;
   g_tl_get_fac_info_fail	EXCEPTION;
   g_tl_init_cache_indices_fail	EXCEPTION;
   g_tl_delete_cache_fail	EXCEPTION;
   g_tl_no_trips_cached		EXCEPTION;
   g_tl_get_vehicle_type_fail	EXCEPTION;


   g_tl_time_uom_conv_fail	EXCEPTION;
   g_tl_get_dist_time_fail	EXCEPTION;
   g_tl_no_car_time_dist_uom	EXCEPTION;
   g_tl_no_time_dist_uom	EXCEPTION;
   g_tl_no_time_dist	EXCEPTION;
   g_tl_no_time_dist_for_stop	EXCEPTION;
   g_tl_no_time_dist_for_dleg	EXCEPTION;
   g_tl_no_time_dist_for_trip	EXCEPTION;
   g_tl_call_mileage_if_fail	EXCEPTION;
   g_tl_get_pricelistid_fail    EXCEPTION;
   g_tl_no_pallet_item_type	EXCEPTION;
   g_tl_replace_dleg_fail	EXCEPTION;
   g_tl_get_int_loc_fail	EXCEPTION;
   g_tl_copy_src_dtl_fail       EXCEPTION;
   g_tl_add_src_as_dtl_fail	EXCEPTION;
   g_tl_cache_first_om_lane_fail EXCEPTION;
   g_tl_build_cache_lcss_fail	EXCEPTION;
   g_tl_sync_dleg_fail		EXCEPTION;
   g_tl_cache_int_cont_fail	EXCEPTION;
   g_tl_classify_dtl_fail	EXCEPTION;

   g_tl_util_get_currency_fail  EXCEPTION;
   g_tl_get_currency_fail  EXCEPTION;

--FTE_TL_CACHE validation exceptions

g_tl_trp_no_trip_id			EXCEPTION;
g_tl_trp_no_lane_id			EXCEPTION;
g_tl_trp_no_service_type		EXCEPTION;
g_tl_trp_no_carrier_id			EXCEPTION;
g_tl_trp_no_mode		EXCEPTION;
g_tl_trp_no_vehicle_type		EXCEPTION;
g_tl_trp_no_price_list_id		EXCEPTION;
g_tl_trp_no_ld_distance			EXCEPTION;
g_tl_trp_no_ud_distance			EXCEPTION;
g_tl_trp_no_pallets			EXCEPTION;
g_tl_trp_no_containers			EXCEPTION;
g_tl_trp_no_weight			EXCEPTION;
g_tl_trp_no_volume			EXCEPTION;
g_tl_trp_no_time			EXCEPTION;
g_tl_trp_no_number_of_stops		EXCEPTION;
g_tl_trp_no_total_trp_distance		EXCEPTION;
g_tl_trp_no_total_dir_distance		EXCEPTION;
g_tl_trp_no_distance_method		EXCEPTION;
g_tl_trp_no_continous_move		EXCEPTION;
g_tl_trp_no_departure_date		EXCEPTION;
g_tl_trp_no_arrival_date		EXCEPTION;
g_tl_trp_no_dead_head			EXCEPTION;
g_tl_trp_no_stop_reference		EXCEPTION;
g_tl_trp_no_dleg_reference		EXCEPTION;


g_tl_stp_no_stop_id			EXCEPTION;
g_tl_stp_no_trip_id			EXCEPTION;
g_tl_stp_no_location_id			EXCEPTION;
g_tl_stp_no_weekday_layovers		EXCEPTION;
g_tl_stp_no_weekend_layovers		EXCEPTION;
g_tl_stp_no_distance			EXCEPTION;
g_tl_stp_no_time			EXCEPTION;
g_tl_stp_no_pickup_weight		EXCEPTION;
g_tl_stp_no_pickup_volume		EXCEPTION;
g_tl_stp_no_pickup_pallets		EXCEPTION;
g_tl_stp_no_pickup_containers		EXCEPTION;
g_tl_stp_no_loading_protocol		EXCEPTION;
g_tl_stp_no_dropoff_weight		EXCEPTION;
g_tl_stp_no_dropoff_volume		EXCEPTION;
g_tl_stp_no_dropoff_pallets		EXCEPTION;
g_tl_stp_no_dropoff_containers		EXCEPTION;
g_tl_stp_no_stop_region			EXCEPTION;
g_tl_stp_no_arrival_date		EXCEPTION;
g_tl_stp_no_departure_date		EXCEPTION;
g_tl_stp_no_fac_charge_basis		EXCEPTION;
g_tl_stp_no_fac_currency		EXCEPTION;
g_tl_stp_no_fac_modifier_id		EXCEPTION;
g_tl_stp_no_fac_pricelist_id		EXCEPTION;
g_tl_stp_no_fac_weight_uom		EXCEPTION;
g_tl_stp_no_fac_volume_uom		EXCEPTION;
g_tl_stp_no_fac_distance_uom		EXCEPTION;
g_tl_stp_no_fac_time_uom		EXCEPTION;


g_tl_dlg_no_delivery_leg_id		EXCEPTION;
g_tl_dlg_no_trip_id			EXCEPTION;
g_tl_dlg_no_delivery_id			EXCEPTION;
g_tl_dlg_no_pickup_stop_id		EXCEPTION;
g_tl_dlg_no_pickup_loc_id		EXCEPTION;
g_tl_dlg_no_dropoff_stop_id		EXCEPTION;
g_tl_dlg_no_dropoff_loc_id		EXCEPTION;
g_tl_dlg_no_weight			EXCEPTION;
g_tl_dlg_no_volume			EXCEPTION;
g_tl_dlg_no_pallets			EXCEPTION;
g_tl_dlg_no_containers			EXCEPTION;
g_tl_dlg_no_distance			EXCEPTION;
g_tl_dlg_no_direct_distance		EXCEPTION;


g_tl_dtl_no_dlv_dtl_id			EXCEPTION;
g_tl_dtl_no_dlv_id			EXCEPTION;
g_tl_dtl_no_dlg_id			EXCEPTION;
g_tl_dtl_no_gross_weight		EXCEPTION;
g_tl_dtl_no_weight_uom			EXCEPTION;
g_tl_dtl_no_volume			EXCEPTION;
g_tl_dtl_no_volume_uom			EXCEPTION;


g_tl_car_no_carrier_id			EXCEPTION;
g_tl_car_no_max_out_of_route		EXCEPTION;
g_tl_car_no_min_cm_distance		EXCEPTION;
g_tl_car_no_min_cm_time			EXCEPTION;
g_tl_car_no_cm_free_dh_mileage		EXCEPTION;
g_tl_car_no_cm_frst_ld_dsc_flg		EXCEPTION;
g_tl_car_no_currency			EXCEPTION;
g_tl_car_no_cm_rate_variant		EXCEPTION;
g_tl_car_no_unit_basis			EXCEPTION;
g_tl_car_no_weight_uom			EXCEPTION;
g_tl_car_no_volume_uom			EXCEPTION;
g_tl_car_no_distance_uom		EXCEPTION;
g_tl_car_no_time_uom			EXCEPTION;
g_tl_get_apprx_dist_time_fail		EXCEPTION;
g_tl_delete_main_rec_fail		EXCEPTION;


g_tl_trip_index_invalid			EXCEPTION;
g_tl_validate_trp_cache_fail		EXCEPTION;

--FTE_TL_CACHE warnings

g_tl_stp_no_fac_wrn			EXCEPTION;
g_tl_cmp_trip_sched_fail		EXCEPTION;
g_tl_cmp_trip_lane_fail			EXCEPTION;


--FTE_TL_COST_ALLOCATION

g_tl_invalid_basis	EXCEPTION;
g_tl_invalid_output_type	EXCEPTION;
g_tl_conv_currency_fail	EXCEPTION;
g_tl_get_stpff_per_stop_fail	EXCEPTION;
g_tl_loading_chrg_fr_fail	EXCEPTION;
g_tl_ast_ld_chrg_fr_fail	EXCEPTION;
g_tl_fac_ld_chrg_fr_fail	EXCEPTION;
g_tl_fac_ast_ld_chrg_fr_fail	EXCEPTION;
g_tl_unld_chrg_fr_fail	EXCEPTION;
g_tl_ast_unld_chrg_fr_fail	EXCEPTION;
g_tl_fac_unld_chrg_fr_fail	EXCEPTION;
g_tl_fac_ast_unld_chrg_fr_fail	EXCEPTION;
g_tl_assgn_stpff_chrg_fail	EXCEPTION;
g_tl_fac_hnd_chrg_pu_fr_fail	EXCEPTION;
g_tl_alloc_hndl_chrg_fail	EXCEPTION;
g_tl_org_chrg_fr_fail		EXCEPTION;
g_tl_dst_chrg_fr_fail		EXCEPTION;
g_tl_cr_fr_cost_temp_fail	EXCEPTION;
g_tl_cr_fr_cost_fail		EXCEPTION;
g_tl_ins_charge_rec_fail	EXCEPTION;
g_tl_get_tot_stop_cost_fail	EXCEPTION;
g_tl_get_tot_trp_cost_fail	EXCEPTION;
g_tl_ins_tot_trp_chrg_fail	EXCEPTION;
g_tl_ins_dist_ld_trp_chrg_fail	EXCEPTION;
g_tl_ins_dist_ud_trp_chrg_fail	EXCEPTION;
g_tl_no_carr_unit_basis		EXCEPTION;
g_tl_ins_unit_trp_chrg_fail	EXCEPTION;
g_tl_ins_time_trp_chrg_fail	EXCEPTION;
g_tl_ins_flat_trp_chrg_fail	EXCEPTION;
g_tl_ins_stpoff_trp_chrg_fail	EXCEPTION;
g_tl_ins_outrt_trp_chrg_fail	EXCEPTION;
g_tl_ins_hndl_trp_chrg_fail	EXCEPTION;
g_tl_ins_cmdisc_trp_chrg_fail	EXCEPTION;
g_tl_ins_tot_stp_chrg_fail	EXCEPTION;
g_tl_ins_wkdayl_stp_chrg_fail	EXCEPTION;
g_tl_ins_wkendl_stp_chrg_fail	EXCEPTION;
g_tl_ins_ld_stp_chrg_fail	EXCEPTION;
g_tl_ins_ast_ld_stp_chrg_fail	EXCEPTION;
g_tl_ins_ud_stp_chrg_fail	EXCEPTION;
g_tl_ins_ast_ud_stp_chrg_fail	EXCEPTION;
g_tl_ins_org_stp_chrg_fail	EXCEPTION;
g_tl_ins_f_ld_stp_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ld_stp_chrg_fail	EXCEPTION;
g_tl_ins_f_ud_stp_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ud_stp_chrg_fail	EXCEPTION;
g_tl_ins_f_hndl_stp_chrg_fail	EXCEPTION;
g_tl_get_to_dleg_cost_fail	EXCEPTION;
g_tl_ins_tot_dlg_chrg_fail	EXCEPTION;
g_tl_ins_dist_ld_dlg_chrg_fail	EXCEPTION;
g_tl_ins_unit_dlg_chrg_fail	EXCEPTION;
g_tl_ins_time_dlg_chrg_fail	EXCEPTION;
g_tl_ins_flat_dlg_chrg_fail	EXCEPTION;
g_tl_ins_stpoff_dlg_chrg_fail	EXCEPTION;
g_tl_ins_outrt_dlg_chrg_fail	EXCEPTION;
g_tl_ins_hndl_dlg_chrg_fail	EXCEPTION;
g_tl_ins_wkdayl_dlg_chrg_fail	EXCEPTION;
g_tl_ins_wkendl_dlg_chrg_fail	EXCEPTION;
g_tl_ins_ld_dlg_chrg_fail	EXCEPTION;
g_tl_ins_as_ld_dlg_chrg_fail	EXCEPTION;
g_tl_ins_ud_dlg_chrg_fail	EXCEPTION;
g_tl_ins_as_ud_dlg_chrg_fail	EXCEPTION;
g_tl_ins_org_dlg_chrg_fail	EXCEPTION;
g_tl_ins_dst_dlg_chrg_fail	EXCEPTION;
g_tl_ins_f_ld_dlg_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ld_dlg_chrg_fail	EXCEPTION;
g_tl_ins_f_ud_dlg_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ud_dlg_chrg_fail	EXCEPTION;
g_tl_ins_f_hndl_dlg_chrg_fail	EXCEPTION;
g_tl_ins_cm_dist_dtl_chrg_fail	EXCEPTION;
g_tl_ins_dist_ld_dtl_chrg_fail	EXCEPTION;
g_tl_ins_dist_ud_dtl_chrg_fail	EXCEPTION;
g_tl_ins_unit_dtl_chrg_fail	EXCEPTION;
g_tl_ins_time_dtl_chrg_fail	EXCEPTION;
g_tl_ins_flat_dtl_chrg_fail	EXCEPTION;
g_tl_ins_stpoff_dtl_chrg_fail	EXCEPTION;
g_tl_ins_outrt_dtl_chrg_fail	EXCEPTION;
g_tl_ins_hndl_dtl_chrg_fail	EXCEPTION;
g_tl_ins_wkday_dtl_chrg_fail	EXCEPTION;
g_tl_ins_ld_dtl_chrg_fail	EXCEPTION;
g_tl_ins_as_ld_dtl_chrg_fail	EXCEPTION;
g_tl_ins_ud_dtl_chrg_fail	EXCEPTION;
g_tl_ins_as_ud_dtl_chrg_fail	EXCEPTION;
g_tl_ins_org_dtl_chrg_fail	EXCEPTION;
g_tl_ins_dst_dtl_chrg_fail	EXCEPTION;
g_tl_ins_f_ld_dtl_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ld_dtl_chrg_fail	EXCEPTION;
g_tl_ins_f_ud_dtl_chrg_fail	EXCEPTION;
g_tl_ins_f_as_ud_dtl_chrg_fail	EXCEPTION;
g_tl_ins_f_hndl_dtl_chrg_fail	EXCEPTION;
g_tl_cr_dlv_dtl_fail		EXCEPTION;
g_tl_cr_trp_price_recs_fail	EXCEPTION;
g_tl_cr_stp_price_recs_fail	EXCEPTION;
g_tl_cr_dlg_price_recs_fail	EXCEPTION;
g_tl_init_fr_codes_fail		EXCEPTION;
g_tl_cr_stp_hash_fail		EXCEPTION;
g_tl_alloc_ld_stpoff_dleg_fail	EXCEPTION;
g_tl_alloc_chrges_dleg_fail	EXCEPTION;
g_tl_alloc_to_dtls_fail		EXCEPTION;
g_tl_cr_summry_price_recs_fail	EXCEPTION;
g_tl_copy_fr_rec_fail		EXCEPTION;
g_tl_fac_hnd_chrg_do_fr_fail	EXCEPTION;
g_tl_ins_dst_stp_chrg_fail	EXCEPTION;

g_tl_ins_wkend_dtl_chrg_fail	EXCEPTION;
g_tl_is_dtl_pallet_fail		EXCEPTION;
g_tl_get_cost_alloc_param_fail	EXCEPTION;
g_tl_no_dtl_on_dleg		EXCEPTION;
g_tl_ins_sum_dtl_chrg_fail	EXCEPTION;
g_tl_fetch_alloc_param_fail	EXCEPTION;
g_tl_ins_fuel_trp_chrg_fail     EXCEPTION;
g_tl_ins_fuel_dlg_chrg_fail	EXCEPTION;
g_tl_ins_fuel_dtl_chrg_fail	EXCEPTION;
g_tl_mdc_top_dleg_fail		EXCEPTION;
g_tl_mdc_alloc_chld_dleg_fail	EXCEPTION;
g_tl_mdc_alloc_int_dtl_fail	EXCEPTION;

--3756411
g_tl_ins_tmp_bulk_arr_fail	EXCEPTION;
g_tl_clr_bulk_arr_fail		EXCEPTION;
g_tl_bulk_ins_tmp_fail		EXCEPTION;

--FTE_TL_RATING Exceptions

g_tl_build_cache_move_fail   EXCEPTION;
g_tl_core_fail			 EXCEPTION;
g_tl_scale_trip_charges_fail	 EXCEPTION;
g_tl_scale_stop_charges_fail	 EXCEPTION;
g_tl_cost_allocation_fail	 EXCEPTION;
g_tl_rate_move_fail		 EXCEPTION;
g_tl_rate_trip_fail		 EXCEPTION;

g_tl_rate_cached_trip_fail	 EXCEPTION;
g_tl_bld_cache_trp_cmp_fail	 EXCEPTION;
g_tl_handle_cm_disc_var_fail	 EXCEPTION;
g_tl_handle_cm_rate_var_fail	 EXCEPTION;
g_tl_is_pricing_required_fail	 EXCEPTION;
g_tl_move_rec_lane_sched_null	 EXCEPTION;
g_tl_get_fc_id_fail		 EXCEPTION;
g_tl_check_freight_term_fail	 EXCEPTION;
g_tl_cache_estimate_fail	 EXCEPTION;
g_tl_get_base_acc_chrg_fail	 EXCEPTION;
g_tl_fpa_get_trip_inf_fail	 EXCEPTION;
g_tl_update_dist_stop_fail       EXCEPTION;
g_tl_veh_for_lane_sched_fail	 EXCEPTION;
g_tl_calc_dim_weight_fail	 EXCEPTION;
g_tl_bld_cache_om_fail		 EXCEPTION;
g_tl_om_filt_least_veh_fail	 EXCEPTION;
g_tl_om_populate_rate_fail	 EXCEPTION;
g_tl_om_rating_fail		 EXCEPTION;
g_tl_populate_summary_fail	 EXCEPTION;
g_tl_move_dlv_rec_fail		 EXCEPTION;

--Warnings
g_tl_trip_cmp_rate_schd_fail     EXCEPTION;
g_tl_trip_cmp_rate_lane_fail     EXCEPTION;

-- FTE_TRIP_RATING Exceptions
g_unsupported_action             EXCEPTION;
g_nontl_move_rec_to_main_fail    EXCEPTION;
g_tl_move_rec_to_main_fail       EXCEPTION;
g_quicksort_partition_fail 	 EXCEPTION;
g_quicksort_fail		 EXCEPTION;
g_seq_tender_sort_fail		 EXCEPTION;
g_sort_fail			 EXCEPTION;
g_quicksort_compare_fail	 EXCEPTION;
g_lane_matches_rank_fail	 EXCEPTION;
g_copy_lane_rank_fail		 EXCEPTION;
g_get_veh_item_org_fail		 EXCEPTION;
g_elim_dup_rank_fail		 EXCEPTION;

--- Debugging Utils ---
   -- code locators
   g_method             VARCHAR2(240);
   g_location           VARCHAR2(240);
   g_exception          VARCHAR2(240);

   -- This variable holds the state of the debug flag for the session
   g_debug              boolean := false;  --false by default
   g_oe_debug           boolean := false;
   g_debug_level        NUMBER  :=1;  --currently we support only one debug level.
   g_debug_mode         VARCHAR2(30)  := 'FILE' ; --only 'FILE' supported right now
   --g_debug_mode         VARCHAR2(30)  := NULL ; --only 'FILE' supported right now

   -- If this variable is true, debugging will be enabled for the Advanced Pricing engine
   --g_qp_debug      boolean := false;

   -- Log levels
   G_LOG           NUMBER :=0;
   G_ERR           NUMBER :=1;
   G_WRN           NUMBER :=2;
   G_INF           NUMBER :=3;
   G_DBG           NUMBER :=4;

   -- resets the method variables (code locators)
   PROCEDURE reset_dbg_vars;

   -- Sets the debug flag on for the session
   PROCEDURE set_debug_on;

   -- Sets the debug flag off for the session
   PROCEDURE set_debug_off;

   /*
   -- Sets debug on for the qp engine
   PROCEDURE set_qp_debug_on;

   -- Sets debug off for the qp engine
   PROCEDURE set_qp_debug_off;
   */

   --prints the message along with the debug information
   --to the log destination

   /*
   PROCEDURE print_debug( p_msg IN VARCHAR2 DEFAULT NULL);

   --prints the message only without the debug information
   PROCEDURE print_msg( p_msg_old IN VARCHAR2 );
   */

   --prints the message wrapping the line in <L> </L> tags
   PROCEDURE print_msg( p_log_level IN NUMBER DEFAULT G_LOG, p_msg IN VARCHAR2 ) ;

   --prints the message without wrapping the line in <L> </L> tags
   --to be used when p_msg itself contains tags
   PROCEDURE print_tag( p_log_level IN NUMBER DEFAULT G_LOG, p_msg IN VARCHAR2 ) ;

   -- flushes the log buffers
   PROCEDURE flush_logs;

   -- flushes the log files. Should be called at all exit points
   PROCEDURE close_logs;

   -- used to set the current method name
   PROCEDURE set_method(p_log_level IN NUMBER DEFAULT G_LOG, p_met IN VARCHAR2,
                        p_loc IN VARCHAR2 DEFAULT NULL);

   PROCEDURE unset_method(p_log_level IN NUMBER DEFAULT G_LOG, p_met IN VARCHAR2);

   -- used to set the current location
   PROCEDURE set_location(p_log_level IN NUMBER DEFAULT G_DBG, p_loc IN VARCHAR2);

   -- Called in case of errors/warnings for outermost procedures to set the current exception
   -- and to set the log file name on the stack
   PROCEDURE set_exit_exception(p_met IN VARCHAR2, p_exc IN VARCHAR2);

   -- used to set the current exception (in case of exception handlers )
   PROCEDURE set_exception(p_met IN VARCHAR2,
                           p_log_level IN NUMBER DEFAULT G_LOG,
                           p_exc IN VARCHAR2);


   -- This procedure checks the profile options to:
      --  check if debuging is turned on for the user
      --  check if qp debugging is on for the user
      --  get the location of the debug trace directory
   -- It initializes the debug trace file if debug is on
   -- It should be called at the beginning of each entry point

   PROCEDURE initialize_logging (p_debug_mode IN VARCHAR2 DEFAULT NULL,
                                 p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status OUT NOCOPY  VARCHAR2);

   FUNCTION get_log_file_name RETURN VARCHAR2;

   FUNCTION get_lookup_meaning (p_lookup_type IN VARCHAR2,
                                p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2;

   PROCEDURE comma_to_table (
     p_list       IN     VARCHAR2,
     x_tab        OUT NOCOPY     dbms_utility.uncl_array );

   PROCEDURE comma_to_number_table (
     p_list       IN     VARCHAR2,
     x_num_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type );

   PROCEDURE table_to_comma (
     p_tab        IN     dbms_utility.uncl_array,
     x_list       OUT NOCOPY     VARCHAR2 );

  PROCEDURE number_table_to_comma (
     p_num_tab        IN     wsh_util_core.id_tab_type,
     x_list           OUT NOCOPY     VARCHAR2 );

   FUNCTION get_msg_count RETURN NUMBER;

   -- bug 2762257
   PROCEDURE set_price_comp_exit_warn;
   PROCEDURE set_trip_prc_comp_exit_warn;


   --
   -- Procedure setmsg
   --  Used to add a message to the message stack
   --     p_api -> calling program name
   --     p_exc -> exception name (form g_... )
   --     p_msg_type -> 'E' - Error (default), 'W'-Warning, 'U'- unexpected
   --error
   --     p_trip_id, ... -> tokens
   --

      PROCEDURE setmsg (p_api                IN VARCHAR2,
                        p_exc                IN VARCHAR2,
                        p_msg_name           IN VARCHAR2 DEFAULT NULL,
                        p_msg_type           IN VARCHAR2 DEFAULT 'E',
                        p_trip_id            IN NUMBER DEFAULT NULL,
                        p_stop_id            IN NUMBER DEFAULT NULL,
                        p_delivery_id        IN NUMBER DEFAULT NULL,
                        p_delivery_leg_id    IN NUMBER DEFAULT NULL,
                        p_delivery_detail_id IN NUMBER DEFAULT NULL,
                        p_carrier_id         IN NUMBER DEFAULT NULL,
                        p_location_id        IN NUMBER DEFAULT NULL,
                      	p_list_header_id     IN NUMBER DEFAULT NULL,
		        p_lane_id	     IN NUMBER DEFAULT NULL,
                        p_schedule_id	     IN NUMBER DEFAULT NULL,
                        p_move_id 	     IN NUMBER DEFAULT NULL);

   -- This is added for R12 to get currency code for rating.
   -- Added to support Multiple currency for international shippings.
   PROCEDURE get_currency_code (p_delivery_id IN NUMBER DEFAULT NULL,
                                p_trip_id      IN NUMBER DEFAULT NULL,
                                p_location_id IN NUMBER DEFAULT NULL,
                                p_carrier_id IN NUMBER DEFAULT NULL,
                                x_currency_code OUT NOCOPY VARCHAR2 ,
                                x_return_status OUT NOCOPY VARCHAR2 );



--Internally calls WSH_WV_UTILS.convert_uom
-- returns NULL if conversion fails
FUNCTION convert_uom(from_uom IN VARCHAR2,
                       to_uom IN VARCHAR2,
                     quantity IN NUMBER,
                      item_id IN NUMBER DEFAULT NULL)  RETURN NUMBER;

END FTE_FREIGHT_PRICING_UTIL;

 

/
