--------------------------------------------------------
--  DDL for Package PO_VAL_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_CONSTANTS" AUTHID CURRENT_USER AS
/* $Header: PO_VAL_CONSTANTS.pls 120.3.12010000.5 2014/07/17 10:40:19 yuandli ship $ */
--------------------------------------------------------------------------
-- Header Validation ID Constants
--------------------------------------------------------------------------
-- Common
c_po_header_id_not_null CONSTANT NUMBER := 0;
c_po_header_id_unique CONSTANT NUMBER := 1;
c_end_date CONSTANT NUMBER := 2;
c_type_lookup_code_not_null CONSTANT NUMBER := 3;
c_type_lookup_code_valid CONSTANT NUMBER := 4;
c_revision_num CONSTANT NUMBER := 5;
c_document_num_unique CONSTANT NUMBER := 6;
c_document_num_not_null CONSTANT NUMBER := 7;
c_document_num_ge_zero CONSTANT NUMBER := 8;
c_document_num_valid CONSTANT NUMBER := 9;
c_currency_code_not_null CONSTANT NUMBER := 10;
c_currency_code_valid CONSTANT NUMBER := 11;
c_rate_null CONSTANT NUMBER := 12;
c_rate_type_null CONSTANT NUMBER := 13;
c_rate_date_null CONSTANT NUMBER := 14;
c_rate_not_null CONSTANT NUMBER := 15;
c_rate_ge_zero CONSTANT NUMBER := 16;
c_rate_type_not_null CONSTANT NUMBER := 17;
c_rate_valid CONSTANT NUMBER := 18;
c_rate_type_valid CONSTANT NUMBER := 19;
c_agent_id_not_null CONSTANT NUMBER := 20;
c_agent_id_valid CONSTANT NUMBER := 21;
c_vendor_not_null CONSTANT NUMBER := 22;
c_vendor_valid CONSTANT NUMBER := 23;
c_vendor_site_not_null CONSTANT NUMBER := 24;
c_vendor_site_valid CONSTANT NUMBER := 25;
c_vendor_contact_valid CONSTANT NUMBER := 26;
c_vendor_site_ccr_valid CONSTANT NUMBER := 27;
c_ship_to_location_id_not_null CONSTANT NUMBER := 28;
c_ship_to_location_id_valid CONSTANT NUMBER := 29;
c_bill_to_location_id_not_null CONSTANT NUMBER := 30;
c_bill_to_location_id_valid CONSTANT NUMBER := 31;
c_last_updated_by CONSTANT NUMBER := 32;
c_last_update_date CONSTANT NUMBER := 33;
c_release_num CONSTANT NUMBER := 34;
c_po_release_id CONSTANT NUMBER := 35;
c_release_date CONSTANT NUMBER := 36;
c_revised_date CONSTANT NUMBER := 37;
c_printed_date CONSTANT NUMBER := 38;
c_closed_date CONSTANT NUMBER := 39;
c_terms_id_header CONSTANT NUMBER := 40;
c_ship_via_lookup_code CONSTANT NUMBER := 41;
c_fob_lookup_code CONSTANT NUMBER := 42;
c_freight_terms_lookup_code CONSTANT NUMBER := 43;
c_shipping_control CONSTANT NUMBER := 44;
c_approval_status CONSTANT NUMBER := 45;

-- Blanket
c_acceptance_required_flag CONSTANT NUMBER := 100;
c_confirming_order_flag CONSTANT NUMBER := 101;
c_acceptance_due_date CONSTANT NUMBER := 102;
c_amount_agreed CONSTANT NUMBER := 103;
c_firm_status_lookup_header CONSTANT NUMBER := 104;
c_cancel_flag CONSTANT NUMBER := 105;
c_closed_code CONSTANT NUMBER := 106;
c_print_count CONSTANT NUMBER := 107;
c_frozen_flag CONSTANT NUMBER := 108;
c_amount_to_encumber CONSTANT NUMBER := 109;
c_style_id_valid CONSTANT NUMBER := 110;
c_style_id_complex_work CONSTANT NUMBER := 111;
c_amount_limit_gt_zero CONSTANT NUMBER := 112;
c_amount_agreed_not_null CONSTANT NUMBER := 113;
c_amount_limit_gt_amt_agreed CONSTANT NUMBER := 114;


-- Quotation
c_quote_warning_delay CONSTANT NUMBER := 200;
c_approval_required_flag CONSTANT NUMBER := 201;

--------------------------------------------------------------------------
-- Line Validation ID Constants
--------------------------------------------------------------------------
-- Common
c_release_num_null CONSTANT NUMBER := 300;
c_po_release_id_null CONSTANT NUMBER := 301;
c_closed_date_null CONSTANT NUMBER := 302;
c_contractor_name CONSTANT NUMBER := 303;
c_order_type_lookup_code CONSTANT NUMBER := 304;
c_job_id_null CONSTANT NUMBER := 305;
c_job_id_not_null CONSTANT NUMBER := 306;
c_job_id_valid CONSTANT NUMBER := 307;
c_job_id_valid_cat CONSTANT NUMBER := 308;
c_job_bg_id_not_cross_bg CONSTANT NUMBER := 309;
c_job_business_group_id_valid CONSTANT NUMBER := 310;
c_item_desc_not_null CONSTANT NUMBER := 311;
c_item_desc_not_updatable CONSTANT NUMBER := 312;
c_category_id_item CONSTANT NUMBER := 313;
c_category_id_not_null CONSTANT NUMBER := 314;
c_category_id_valid CONSTANT NUMBER := 315;
c_hazard_class_id_null CONSTANT NUMBER := 316;
c_hazard_class_id_valid CONSTANT NUMBER := 317;
c_un_number_id_null CONSTANT NUMBER := 318;
c_un_number_id_valid CONSTANT NUMBER := 319;
c_unit_meas_lookup_null CONSTANT NUMBER := 320;
c_unit_meas_lookup_not_null CONSTANT NUMBER := 321;
c_unit_meas_lookup_item CONSTANT NUMBER := 322;
c_unit_meas_lookup_valid CONSTANT NUMBER := 323;
c_unit_meas_lookup_svc_valid CONSTANT NUMBER := 324;
c_unit_meas_lookup_line_type CONSTANT NUMBER := 325;
c_unit_price_not_null CONSTANT NUMBER := 326;
c_unit_price_ge_zero CONSTANT NUMBER := 327;
c_unit_price_line_type CONSTANT NUMBER := 328;
c_unit_price_null CONSTANT NUMBER := 329;
c_item_id_not_null CONSTANT NUMBER := 330;
c_item_id_null CONSTANT NUMBER := 331;
c_item_id_valid CONSTANT NUMBER := 332;
c_item_id_op_valid CONSTANT NUMBER := 333;
c_item_revision_null CONSTANT NUMBER := 334;
c_item_revision_item CONSTANT NUMBER := 335;
c_line_type_id_not_null CONSTANT NUMBER := 336;
c_line_type_id_valid CONSTANT NUMBER := 337;
c_quantity_ge_zero CONSTANT NUMBER := 338;
c_quantity_null CONSTANT NUMBER := 339;
c_amount_null CONSTANT NUMBER := 340;
c_rate_type_no_usr CONSTANT NUMBER := 341;
c_line_num_not_null CONSTANT NUMBER := 342;
c_line_num_gt_zero CONSTANT NUMBER := 343;
c_line_num_unique CONSTANT NUMBER := 344;
c_po_line_id_not_null CONSTANT NUMBER := 345;
c_po_line_id_unique CONSTANT NUMBER := 346;
c_price_type_lookup_code CONSTANT NUMBER := 347;
c_line_sec_quantity_null CONSTANT NUMBER := 348;
c_line_sec_quantity_ge_zero CONSTANT NUMBER := 349;
c_line_sec_quantity_not_zero CONSTANT NUMBER := 350;
c_line_sec_quantity_not_reqd CONSTANT NUMBER := 351;
c_line_sec_quantity_no_req_uom CONSTANT NUMBER := 352;
c_line_sec_quantity_req_uom CONSTANT NUMBER := 353;
c_uom_update_not_null CONSTANT NUMBER := 354;
c_uom_update_valid CONSTANT NUMBER := 355;
c_unit_price_update_not_null CONSTANT NUMBER := 356;
c_unit_price_update_ge_zero CONSTANT NUMBER := 357;
c_item_desc_update_not_null CONSTANT NUMBER := 358;
c_item_desc_update_unupdatable CONSTANT NUMBER := 359;
c_ip_cat_id_update_not_null CONSTANT NUMBER := 360;
c_ip_cat_id_update_valid CONSTANT NUMBER := 361;
c_cat_id_update_not_null CONSTANT NUMBER := 362;
c_cat_id_update_not_updatable CONSTANT NUMBER := 363;
c_price_adjustment_exist CONSTANT NUMBER := 364; --Enhanced Pricing
c_unvalidated_debit_memo_exist CONSTANT NUMBER := 365; --Bug 18372756

-- Blanket
c_ga_flag_temp_labor CONSTANT NUMBER := 400;
c_ga_flag_op CONSTANT NUMBER := 401;
c_capital_expense_flag CONSTANT NUMBER := 402;
c_not_to_exceed_price_null CONSTANT NUMBER := 403;
c_not_to_exceed_price_valid CONSTANT NUMBER := 404;
c_amount_blanket CONSTANT NUMBER := 405;
c_expiration_date_blk_not_null CONSTANT NUMBER := 406;
c_expiration_date_blk_exc_hdr CONSTANT NUMBER := 407;
c_over_tolerance_err_flag_null CONSTANT NUMBER := 408;
c_ip_category_id_not_null CONSTANT NUMBER := 409;
c_ip_category_id_valid CONSTANT NUMBER := 410;
c_line_secondary_uom_not_null CONSTANT NUMBER := 411;
c_line_secondary_uom_null CONSTANT NUMBER := 412;
c_line_secondary_uom_correct CONSTANT NUMBER := 413;
c_line_preferred_grade CONSTANT NUMBER := 414;
c_line_preferred_grade_item CONSTANT NUMBER := 415;
c_line_preferred_grade_valid CONSTANT NUMBER := 416;
c_line_style_on_line_type CONSTANT NUMBER := 417;
c_line_style_on_purchase_basis CONSTANT NUMBER := 418;
c_negotiated_by_preparer CONSTANT NUMBER := 419;
c_nego_by_prep_update_not_null CONSTANT NUMBER := 420;
c_nego_by_prep_update_valid CONSTANT NUMBER := 421;
c_language CONSTANT NUMBER := 422;
c_amount_ge_zero CONSTANT NUMBER := 423;

-- Quotation
c_over_tolerance_error_flag CONSTANT NUMBER := 500;
c_allow_price_override_null CONSTANT NUMBER := 501;
c_negotiated_by_preparer_null CONSTANT NUMBER := 502;
c_capital_expense_flag_null CONSTANT NUMBER := 503;
c_min_release_amount_null CONSTANT NUMBER := 504;
c_market_price_null CONSTANT NUMBER := 505;
c_committed_amount_null CONSTANT NUMBER := 506;

-- Standard PO
c_amount_gt_zero CONSTANT NUMBER := 550;

--------------------------------------------------------------------------
-- Line Location Validation ID Constants
--------------------------------------------------------------------------
-- Common
c_loc_need_by_date CONSTANT NUMBER := 600;
c_loc_promised_date CONSTANT NUMBER := 601;
c_loc_quantity CONSTANT NUMBER := 602;
c_loc_price_override_not_null CONSTANT NUMBER := 603;
c_loc_price_override_ge_zero CONSTANT NUMBER := 604;
c_loc_price_discount_not_null CONSTANT NUMBER := 605;
c_loc_price_discount_valid CONSTANT NUMBER := 606;
c_ship_to_organization_id CONSTANT NUMBER := 607;
c_loc_ship_to_loc_id_valid CONSTANT NUMBER := 608;
c_terms_id_line_loc CONSTANT NUMBER := 609;
c_shipment_num_not_null CONSTANT NUMBER := 610;
c_shipment_num_gt_zero CONSTANT NUMBER := 611;
c_shipment_num_unique CONSTANT NUMBER := 612;
c_loc_sec_quantity_null CONSTANT NUMBER := 613;
c_loc_sec_quantity_ge_zero CONSTANT NUMBER := 614;
c_loc_sec_quantity_not_zero CONSTANT NUMBER := 615;
c_loc_sec_quantity_not_reqd CONSTANT NUMBER := 616;
c_loc_sec_quantity_not_req_uom CONSTANT NUMBER := 617;
c_loc_sec_quantity_req_uom CONSTANT NUMBER := 618;
c_tax_name CONSTANT NUMBER := 619;
c_loc_quantity_ge_zero CONSTANT NUMBER := 620;
c_loc_amount CONSTANT NUMBER := 621;  -- PDOI for Complex PO Project
c_loc_payment_type CONSTANT NUMBER := 622;  -- PDOI for Complex PO Project


-- Blanket
c_loc_from_date_ge_hdr_start CONSTANT NUMBER := 700;
c_loc_from_date_le_hdr_end CONSTANT NUMBER := 701;
c_loc_from_date_le_loc_end CONSTANT NUMBER := 702;
c_loc_from_date_le_line_end CONSTANT NUMBER := 703;
c_loc_end_date_le_line_end CONSTANT NUMBER := 704;
c_loc_end_date_le_hdr_end CONSTANT NUMBER := 705;
c_loc_end_date_ge_hdr_start CONSTANT NUMBER := 706;
c_shipment_type_not_null CONSTANT NUMBER := 707;
c_shipment_type_valid CONSTANT NUMBER := 708;
c_at_least_one_reqd_field CONSTANT NUMBER := 709;
c_need_by_date_null CONSTANT NUMBER := 710;
c_firm_flag_null CONSTANT NUMBER := 711;
c_freight_carrier_null CONSTANT NUMBER := 712;
c_fob_lookup_code_null CONSTANT NUMBER := 713;
c_freight_terms_null CONSTANT NUMBER := 714;
c_qty_rcv_tolerance_null CONSTANT NUMBER := 715;
c_receipt_reqd_flag_null CONSTANT NUMBER := 716;
c_inspection_reqd_flag_null CONSTANT NUMBER := 717;
c_receipt_days_except_null CONSTANT NUMBER := 718;
c_invoice_close_toler_null CONSTANT NUMBER := 719;
c_receive_close_toler_null CONSTANT NUMBER := 720;
c_days_early_rcpt_allowed_null CONSTANT NUMBER := 721;
c_days_late_rcpt_allowed_null CONSTANT NUMBER := 722;
c_enforce_shipto_loc_code_null CONSTANT NUMBER := 723;
c_allow_sub_receipts_flag_null CONSTANT NUMBER := 724;
c_promised_date_null CONSTANT NUMBER := 725;
c_receiving_routing_null CONSTANT NUMBER := 726;
c_loc_secondary_uom_null CONSTANT NUMBER := 727;
c_loc_secondary_uom_not_null CONSTANT NUMBER := 728;
c_loc_secondary_uom_correct CONSTANT NUMBER := 729;
c_loc_preferred_grade CONSTANT NUMBER := 730;
c_loc_preferred_grade_item CONSTANT NUMBER := 731;
c_loc_preferred_grade_valid CONSTANT NUMBER := 732;
c_loc_style_related_info CONSTANT NUMBER := 733;
c_price_break_not_allowed CONSTANT NUMBER := 734;
c_dates_cumulative_failed CONSTANT NUMBER := 735;

-- Quotation
c_qty_ecv_exception_code CONSTANT NUMBER := 800;
c_loc_fob_lookup_code CONSTANT NUMBER := 801;
c_loc_freight_terms CONSTANT NUMBER := 802;
c_loc_freight_carrier CONSTANT NUMBER := 803;

--------------------------------------------------------------------------
-- Price Differential Validation ID Constants
--------------------------------------------------------------------------
-- Common
c_price_type_not_null CONSTANT NUMBER := 900;
c_price_type_valid CONSTANT NUMBER := 901;
c_multiple_price_diff CONSTANT NUMBER := 902;
c_entity_type CONSTANT NUMBER := 903;
c_multiplier_not_null CONSTANT NUMBER := 904;
c_multiplier_null CONSTANT NUMBER := 905;
c_min_multiplier_null CONSTANT NUMBER := 906;
c_min_multiplier_not_null CONSTANT NUMBER := 907;
c_max_multiplier_null CONSTANT NUMBER := 908;
c_price_diff_style_info CONSTANT NUMBER := 909;

---------------------------------------------------------------------------
-- Validation ID Constants for errors not thrown by validation framework
--------------------------------------------------------------------------
c_line_type_derv CONSTANT NUMBER := 1000;
c_category_derv CONSTANT NUMBER := 1001;
c_ip_category_derv CONSTANT NUMBER := 1002;
c_job_name_derv CONSTANT NUMBER := 1003;
c_uom_code_derv CONSTANT NUMBER := 1004;
c_item_derv CONSTANT NUMBER := 1005;
c_ship_to_org_code_derv CONSTANT NUMBER := 1006;
c_ship_to_location_derv CONSTANT NUMBER := 1007;
c_part_num_derv CONSTANT NUMBER := 1008;
c_line_rec_valid CONSTANT NUMBER := 1009;
--< Shared Proc 14223789 Start >
c_transaction_flow_derv CONSTANT NUMBER := 1010;
--< Shared Proc 14223789 End >

END PO_VAL_CONSTANTS;

/
