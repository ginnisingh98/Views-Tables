--------------------------------------------------------
--  DDL for Package MSC_HUB_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_HUB_CALENDAR" AUTHID CURRENT_USER as
/*  $Header: MSCHBCAS.pls 120.6 2008/03/19 07:04:07 prdas noship $ */


function first_work_date(p_calendar_code in varchar2,
			 p_sr_instance_id in number,
			 p_bkt_type in number,
			 p_bkt_start_date date) return date;

function last_work_date(p_calendar_code in varchar2,
			 p_sr_instance_id in number,
			 p_bkt_type in number,
			 p_bkt_start_date date) return date ;

function last_work_date(p_plan_id in number,
			p_sr_instance_id in number,
			p_bkt_type in number,
			p_bkt_start_date in date,
			p_bkt_end_date in date) return date;

function last_work_date(p_plan_id in number,
             p_date in date ) return date;

function ss_date(p_plan_id  in number,p_bkt_start_date in date,p_bkt_end_date in date) return date;

function working_day_bkt_start_date(p_plan_id in number,
			p_sr_instance_id in number,
			p_bkt_type in number,
			p_bkt_start_date in date,
			p_bkt_end_date in date) return date;

function get_item_org(p_plan_id in number,p_item_id in number,
                      p_sr_inst_id in number) return number;

end msc_hub_calendar;

/
