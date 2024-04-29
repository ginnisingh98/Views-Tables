--------------------------------------------------------
--  DDL for Package MSC_VERTICAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_VERTICAL_PLAN_SC" AUTHID CURRENT_USER AS
/* $Header: MSCVERPS.pls 115.7 2002/12/02 17:50:22 eychen ship $ */

TYPE column_number IS TABLE OF number INDEX BY binary_integer;

  -- added by utham for multi_return action proc
  TYPE number_arr is TABLE OF NUMBER;
  TYPE sd_tbl_type IS record (p_query_id  number_arr
                             ,p_number_1 number_arr);



PROCEDURE populate_bucketed_quantity (
			  arg_plan_id IN NUMBER,
                          arg_instance_id IN NUMBER,
			  arg_org_id IN NUMBER,
                          arg_item_id IN NUMBER,
			  arg_cutoff_date IN DATE,
                          arg_bucket_type IN VARCHAR2,
                          p_quantity_string OUT NOCOPY VARCHAR2,
                          p_period_string OUT NOCOPY VARCHAR2,
                          p_period_count OUT NOCOPY NUMBER);

FUNCTION  get_exception_group(l_where varchar2) return column_number;

PROCEDURE flush_multi_return ( p_sd_table in msc_vertical_plan_sc.sd_tbl_type);


END Msc_VERTICAL_PLAN_SC;

 

/
