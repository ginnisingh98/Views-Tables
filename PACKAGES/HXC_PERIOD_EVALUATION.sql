--------------------------------------------------------
--  DDL for Package HXC_PERIOD_EVALUATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PERIOD_EVALUATION" AUTHID CURRENT_USER as
/* $Header: hxcperevl.pkh 115.3 2003/12/12 03:01:22 sonarasi noship $ */
FUNCTION make_date(p_day varchar2,
                   p_month_year varchar2) RETURN DATE;

TYPE period is RECORD
(START_DATE            DATE
,END_DATE	       DATE
);

TYPE period_list is TABLE OF
period
INDEX BY BINARY_INTEGER;

TYPE r_per_time_period_types IS RECORD
(
p_proc_period_type VARCHAR2(30),
number_per_fiscal_year per_time_period_types.number_per_fiscal_year%type
);
TYPE t_per_time_period_types IS TABLE OF r_per_time_period_types INDEX BY BINARY_INTEGER;
g_per_time_period_types_ct t_per_time_period_types;

FUNCTION  get_period_list (p_current_date		date,
			   p_recurring_period_type	varchar2,
			   p_duration_in_days		number,
			   p_rec_period_start_date      date,
			   p_max_date_in_futur		date,
			   p_max_date_in_past		date)
			   return period_list;
/*
FUNCTION  get_period_list (p_current_date		date,
			   p_resource_id		number,
			   p_max_date_in_futur		date,
			   p_max_date_in_past		date)
			   return period_list;
*/
PROCEDURE get_period_details (p_proc_period_type IN VARCHAR2,
                              p_base_period_type OUT NOCOPY VARCHAR2,
                              p_multiple         OUT NOCOPY NUMBER);

procedure period_start_stop(p_current_date date,
                            p_rec_period_start_date date,
                            l_period_start in out nocopy date,
                            l_period_end in out nocopy date,
                            l_base_period_type varchar2);

PROCEDURE period_start_stop(p_current_date                   date,
                            p_rec_period_start_date          date,
                            l_period_start          in out nocopy   date,
                            l_period_end            in out nocopy   date,
                            l_base_period_type               varchar2,
                            p_multiple			     number);

end hxc_period_evaluation;

 

/
