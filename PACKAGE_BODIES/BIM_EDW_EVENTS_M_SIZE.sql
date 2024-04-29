--------------------------------------------------------
--  DDL for Package Body BIM_EDW_EVENTS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_EVENTS_M_SIZE" AS
/* $Header: bimszevb.pls 115.0 2001/03/14 12:01:57 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER) IS


-- v_num_rows        NUMBER := 0;

CURSOR c_cnt_rows IS
   select sum(cnt)
   from (
        select count(*) cnt
	FROM ams_event_offers_vl aeo ,
	ams_event_headers_all_b aeh ,
	edw_local_instance inst
	WHERE
        aeo.event_header_id = aeh.event_header_id and aeo.event_level = 'MAIN'
	and ((aeo.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD'))
        or
        (aeh.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD')))
	and
	aeo.last_update_date between
        p_from_date  and  p_to_date
        UNION
        select count(*)
	FROM ams_event_headers_vl aeh ,
	edw_local_instance inst
	WHERE
	aeh.event_level = 'MAIN' and
        aeh.last_update_date between
        p_from_date  and  p_to_date
        );


BEGIN

  dbms_output.enable(1000000);

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

    dbms_output.put_line('The number of rows is: ' || to_char(p_num_rows));
END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

 x_event_offer_name NUMBER;
 x_event_offer_id NUMBER;
 x_parent_event_offer_id NUMBER;
 x_event_header_id NUMBER;
 x_event_level NUMBER;
 x_event_type_code NUMBER;
 x_user_status_id NUMBER;
 x_last_status_date NUMBER;
 x_system_status_code NUMBER;
 x_timezone_id NUMBER;
 x_reg_waitlist_pct NUMBER;
 x_reg_overbook_pct NUMBER;
 x_reg_minimum_capacity NUMBER;
 x_reg_maximum_capacity NUMBER;
 x_reg_effective_capacity NUMBER;
 x_pricelist_line_id NUMBER;
 x_pricelist_header_id NUMBER;
 x_owner_user_id NUMBER;
 x_org_id NUMBER;
 x_inventory_item_id NUMBER;
 x_event_location_id NUMBER;
 x_event_duration NUMBER;
 x_event_delivery_method_id NUMBER;
 x_coordinator_id NUMBER;
 x_certification_credits NUMBER;
 x_waitlist_action_type_code NUMBER;
 x_stream_type_code NUMBER;
 x_source_code NUMBER;
 x_reg_waitlist_allowed_flag NUMBER;
 x_reg_start_time NUMBER;
 x_reg_required_flag NUMBER;
 x_reg_overbook_allowed_flag NUMBER;
 x_reg_invited_only_flag NUMBER;
 x_reg_frozen_flag NUMBER;
 x_reg_end_time NUMBER;
 x_reg_charge_flag NUMBER;
 x_priority_type_code NUMBER;
 x_partner_flag NUMBER;
 x_overflow_flag NUMBER;
 x_event_start_date_time NUMBER;
 x_event_standalone_flag NUMBER;
 x_event_required_flag NUMBER;
 x_event_language_code NUMBER;
 x_event_full_flag NUMBER;
 x_event_end_date_time NUMBER;
 x_event_duration_uom_code NUMBER;
 x_cert_credit_type_code NUMBER;
 x_cancellation_reason_code NUMBER;
 x_inbound_script_name NUMBER;
 x_email NUMBER;
 x_phone NUMBER;
 x_url NUMBER;
 x_auto_register_flag NUMBER;
 x_event_venue_id NUMBER;
 x_reg_start_date NUMBER;
 x_reg_minimum_req_by_date NUMBER;
 x_reg_end_date NUMBER;
 x_event_start_date NUMBER;
 x_event_end_date NUMBER;
 x_event_mktg_message NUMBER;
 x_description NUMBER;
 x_creation_date NUMBER;
 x_INSTANCE NUMBER;


  CURSOR c_1 IS
	SELECT
	avg(nvl(vsize(aeo.event_offer_name), 0)),
	avg(nvl(vsize(aeo.event_offer_id), 0)),
	avg(nvl(vsize(aeo.parent_event_offer_id), 0)),
	avg(nvl(vsize(aeo.event_header_id), 0)),
	avg(nvl(vsize(aeo.event_level), 0)),
	avg(nvl(vsize(aeo.event_type_code), 0)),
	avg(nvl(vsize(aeo.user_status_id), 0)),
	avg(nvl(vsize(aeo.last_status_date), 0)),
	avg(nvl(vsize(aeo.system_status_code), 0)),
	avg(nvl(vsize(aeo.timezone_id), 0)),
	avg(nvl(vsize(aeo.reg_waitlist_pct), 0)),
	avg(nvl(vsize(aeo.reg_overbook_pct), 0)),
	avg(nvl(vsize(aeo.reg_minimum_capacity), 0)),
	avg(nvl(vsize(aeo.reg_maximum_capacity), 0)),
	avg(nvl(vsize(aeo.reg_effective_capacity), 0)),
	avg(nvl(vsize(aeo.pricelist_line_id), 0)),
	avg(nvl(vsize(aeo.pricelist_header_id), 0)),
	avg(nvl(vsize(aeo.owner_user_id), 0)),
	avg(nvl(vsize(aeo.org_id), 0)),
	avg(nvl(vsize(aeo.inventory_item_id), 0)),
	avg(nvl(vsize(aeo.event_location_id), 0)),
	avg(nvl(vsize(aeo.event_duration), 0)),
	avg(nvl(vsize(aeo.event_delivery_method_id), 0)),
	avg(nvl(vsize(aeo.coordinator_id), 0)),
	avg(nvl(vsize(aeo.certification_credits), 0)),
	avg(nvl(vsize(aeo.waitlist_action_type_code), 0)),
	avg(nvl(vsize(aeo.stream_type_code), 0)),
	avg(nvl(vsize(aeo.source_code), 0)),
	avg(nvl(vsize(aeo.reg_waitlist_allowed_flag), 0)),
	avg(nvl(vsize(aeo.reg_start_time), 0)),
	avg(nvl(vsize(aeo.reg_required_flag), 0)),
	avg(nvl(vsize(aeo.reg_overbook_allowed_flag), 0)),
	avg(nvl(vsize(aeo.reg_invited_only_flag), 0)),
	avg(nvl(vsize(aeo.reg_frozen_flag), 0)),
	avg(nvl(vsize(aeo.reg_end_time), 0)),
	avg(nvl(vsize(aeo.reg_charge_flag), 0)),
	avg(nvl(vsize(aeo.priority_type_code), 0)),
	avg(nvl(vsize(aeo.partner_flag), 0)),
	avg(nvl(vsize(aeo.overflow_flag), 0)),
	avg(nvl(vsize(aeo.event_start_date_time), 0)),
	avg(nvl(vsize(aeo.event_standalone_flag), 0)),
	avg(nvl(vsize(aeo.event_required_flag), 0)),
	avg(nvl(vsize(aeo.event_language_code), 0)),
	avg(nvl(vsize(aeo.event_full_flag), 0)),
	avg(nvl(vsize(aeo.event_end_date_time), 0)),
	avg(nvl(vsize(aeo.event_duration_uom_code), 0)),
	avg(nvl(vsize(aeo.cert_credit_type_code), 0)),
	avg(nvl(vsize(aeo.cancellation_reason_code), 0)),
	avg(nvl(vsize(aeo.inbound_script_name), 0)),
	avg(nvl(vsize(aeo.email), 0)),
	avg(nvl(vsize(aeo.phone), 0)),
	avg(nvl(vsize(aeo.url), 0)),
	avg(nvl(vsize(aeo.auto_register_flag), 0)),
	avg(nvl(vsize(aeo.event_venue_id), 0)),
	avg(nvl(vsize(aeo.reg_start_date), 0)),
	avg(nvl(vsize(aeo.reg_minimum_req_by_date), 0)),
	avg(nvl(vsize(aeo.reg_end_date), 0)),
	avg(nvl(vsize(aeo.event_start_date), 0)),
	avg(nvl(vsize(aeo.event_end_date), 0)),
	avg(nvl(vsize(aeo.event_mktg_message), 0)),
	avg(nvl(vsize(aeo.event_offer_name), 0)),
	avg(nvl(vsize(aeo.description), 0)),
	avg(nvl(vsize(aeo.creation_date), 0))
        FROM ams_event_offers_vl aeo ,
        ams_event_headers_all_b aeh ,
        edw_local_instance inst
        WHERE
        aeo.event_header_id = aeh.event_header_id and aeo.event_level = 'MAIN'
        and ((aeo.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD'))
        or
        (aeh.last_update_date > to_date('1000/01/01', 'YYYY/MM/DD')));


  CURSOR c_2 IS
	select
	 avg(nvl(vsize(INSTANCE_CODE), 0))
	 from EDW_LOCAL_INSTANCE ;



  BEGIN

    dbms_output.enable(1000000);

    OPEN c_1;
      FETCH c_1 INTO
	 x_event_offer_name,
	 x_event_offer_id,
	 x_parent_event_offer_id,
	 x_event_header_id,
	 x_event_level,
	 x_event_type_code,
	 x_user_status_id,
	 x_last_status_date,
	 x_system_status_code,
	 x_timezone_id,
	 x_reg_waitlist_pct,
	 x_reg_overbook_pct,
	 x_reg_minimum_capacity,
	 x_reg_maximum_capacity,
	 x_reg_effective_capacity,
	 x_pricelist_line_id,
	 x_pricelist_header_id,
	 x_owner_user_id,
	 x_org_id,
	 x_inventory_item_id,
	 x_event_location_id,
	 x_event_duration,
	 x_event_delivery_method_id,
	 x_coordinator_id,
	 x_certification_credits,
	 x_waitlist_action_type_code,
	 x_stream_type_code,
	 x_source_code,
	 x_reg_waitlist_allowed_flag,
	 x_reg_start_time,
	 x_reg_required_flag,
	 x_reg_overbook_allowed_flag,
	 x_reg_invited_only_flag,
	 x_reg_frozen_flag,
	 x_reg_end_time,
	 x_reg_charge_flag,
	 x_priority_type_code,
	 x_partner_flag,
	 x_overflow_flag,
	 x_event_start_date_time,
	 x_event_standalone_flag,
	 x_event_required_flag,
	 x_event_language_code,
	 x_event_full_flag,
	 x_event_end_date_time,
	 x_event_duration_uom_code,
	 x_cert_credit_type_code,
	 x_cancellation_reason_code,
	 x_inbound_script_name,
	 x_email,
	 x_phone,
	 x_url,
	 x_auto_register_flag,
	 x_event_venue_id,
	 x_reg_start_date,
	 x_reg_minimum_req_by_date,
	 x_reg_end_date,
	 x_event_start_date,
	 x_event_end_date,
	 x_event_mktg_message,
	 x_event_offer_name,
	 x_description,
	 x_creation_date ;

    CLOSE c_1;

    x_total := 20  +
	ceil(x_event_offer_name+1) +
	ceil(x_event_offer_id+1) +
	ceil(x_parent_event_offer_id+1) +
	ceil(x_event_header_id+1) +
	ceil(x_event_level+1) +
	ceil(x_event_type_code+1) +
	ceil(x_user_status_id+1) +
	ceil(x_last_status_date+1) +
	ceil(x_system_status_code+1) +
	ceil(x_timezone_id+1) +
	ceil(x_reg_waitlist_pct+1) +
	ceil(x_reg_overbook_pct+1) +
	ceil(x_reg_minimum_capacity+1) +
	ceil(x_reg_maximum_capacity+1) +
	ceil(x_reg_effective_capacity+1) +
	ceil(x_pricelist_line_id+1) +
	ceil(x_pricelist_header_id+1) +
	ceil(x_owner_user_id+1) +
	ceil(x_org_id+1) +
	ceil(x_inventory_item_id+1) +
	ceil(x_event_location_id+1) +
	ceil(x_event_duration+1) +
	ceil(x_event_delivery_method_id+1) +
	ceil(x_coordinator_id+1) +
	ceil(x_certification_credits+1) +
	ceil(x_waitlist_action_type_code+1) +
	ceil(x_stream_type_code+1) +
	ceil(x_source_code+1) +
	ceil(x_reg_waitlist_allowed_flag+1) +
	ceil(x_reg_start_time+1) +
	ceil(x_reg_required_flag+1) +
	ceil(x_reg_overbook_allowed_flag+1) +
	ceil(x_reg_invited_only_flag+1) +
	ceil(x_reg_frozen_flag+1) +
	ceil(x_reg_end_time+1) +
	ceil(x_reg_charge_flag+1) +
	ceil(x_priority_type_code+1) +
	ceil(x_partner_flag+1) +
	ceil(x_overflow_flag+1) +
	ceil(x_event_start_date_time+1) +
	ceil(x_event_standalone_flag+1) +
	ceil(x_event_required_flag+1) +
	ceil(x_event_language_code+1) +
	ceil(x_event_full_flag+1) +
	ceil(x_event_end_date_time+1) +
	ceil(x_event_duration_uom_code+1) +
	ceil(x_cert_credit_type_code+1) +
	ceil(x_cancellation_reason_code+1) +
	ceil(x_inbound_script_name+1) +
	ceil(x_email+1) +
	ceil(x_phone+1) +
	ceil(x_url+1) +
	ceil(x_auto_register_flag+1) +
	ceil(x_event_venue_id+1) +
	ceil(x_reg_start_date+1) +
	ceil(x_reg_minimum_req_by_date+1) +
	ceil(x_reg_end_date+1) +
	ceil(x_event_start_date+1) +
	ceil(x_event_end_date+1) +
	ceil(x_event_mktg_message+1) +
	ceil(x_event_offer_name+1) +
	ceil(x_description+1) +
	ceil(x_creation_date+1);


    OPEN c_2;
      FETCH c_2 INTO  x_INSTANCE;
    CLOSE c_2;

    x_total := x_total + 3*ceil(x_INSTANCE + 1);

    x_total := 2*x_total + 15*(x_constant + 1);

    -- dbms_output.put_line('     ');
    dbms_output.put_line('The average row length is : ' || to_char(x_total));

  p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body BIM_EDW_EVENTS_M_SIZE

/
