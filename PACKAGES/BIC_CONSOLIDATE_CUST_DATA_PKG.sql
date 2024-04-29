--------------------------------------------------------
--  DDL for Package BIC_CONSOLIDATE_CUST_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIC_CONSOLIDATE_CUST_DATA_PKG" AUTHID CURRENT_USER as
/* $Header: bicflats.pls 115.3 2004/05/13 15:42:48 vsegu ship $ */

  --
  -- This procedure calls two procedures populate_party_data and
  -- populate party_status_data. These two procedures take data from
  -- bic_customer_summary_all and bic_party_summary which is in row form
  -- and convert it into column format and insert into bic_party_summ and
  -- bic_party_status_summ tables respectively.
  --
   procedure main_proc(p_start_date date,
				  p_end_date   date) ;
  -- This procedure just delete records from  bic_customer_summary_all
  -- and bic_party_summary tables
  procedure purge_summary_data (p_start_date date,
				            p_end_date   date) ;
  procedure purge_party_summary_data ;

  procedure purge_customer_summary_data ;
  procedure populate_status_data (p_start_date date,
	                 		  p_end_date   date, p_measure_code varchar2 default null);
  procedure populate_party_data (p_start_date date,
				 p_end_date   date);
  procedure update_market_segment ;
end;



 

/
