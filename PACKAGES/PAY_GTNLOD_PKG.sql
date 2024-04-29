--------------------------------------------------------
--  DDL for Package PAY_GTNLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GTNLOD_PKG" AUTHID CURRENT_USER AS
/* $Header: pygtnlod.pkh 120.1.12010000.2 2009/04/28 07:22:26 kagangul ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed for GTN to run Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   21-NOV-1999  ssarma      40.0   created
   17-MAY-2002  ahanda      115.1  Added dbdrv.
   09-DEC-2004  sgajula     115.3  Overloaded load_date and changed signatures of other procedures for implementing BRA
   16-OCT-2006  jdevasah    115.4  Bug 4942114: Input parameters to load_data procedure are changed.
   20-APR-2009  kagangul    115.5  Bug# 8363373: Introducing function get_state_name, get_county_name
				   and get_city_name to get the names based on jurisdiction code.
				   This will help distinguishing the City Withheld for same city name
				   but in different state/county.
--
*/
TYPE sum_table IS TABLE OF pay_us_rpt_totals%ROWTYPE INDEX BY BINARY_INTEGER;
g_totals_table sum_table;
l_index   number :=0;
procedure load_data
(
   pactid   in     varchar2,     /* payroll action id */
   chnkno   in     number,
   ppa_finder in varchar2
);
/*-- Bug#4942114 starts -- */
procedure load_data
(
	p_payroll_action_id number ,
	p_chunk   number,
	ppa_finder number ,
	p_ded_bal_status1 varchar2,
	p_ded_bal_status2 varchar2,
	p_earn_bal_status varchar2,
	p_fed_bal_status varchar2,
	p_state_bal_status varchar2,
	p_local_bal_status varchar2,
	p_fed_liab_bal_status varchar2,
	p_state_liab_bal_status varchar2,
	p_futa_status_count number,
	p_futa_def_bal_id number,
	p_er_liab_status varchar2,
	p_wc_er_liab_status_count number,
	p_asg_flag varchar2
);

/*procedure load_data
(
	p_payroll_action_id number ,
	p_chunk   number,
	ppa_finder number ,
	p_ded_view_name varchar2 ,
	p_earn_view_name varchar2 ,
	p_fed_view_name varchar2  ,
	p_state_view_name varchar2  ,
	p_local_view_name varchar2 ,
	p_fed_liab_view_name varchar2 ,
	p_state_liab_view_name varchar2 ,
	p_futa_where varchar2,
	p_futa_from varchar2,
	p_er_liab_where varchar2 ,
	p_er_liab_from varchar2,
	p_wc_er_liab_where varchar2 ,
	p_wc_er_liab_from varchar2,
	p_asg_flag varchar2
); */
/*-- Bug#4942114 ends -- */

/* Bug # 8363373 Start */

FUNCTION get_state_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_county_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_city_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2;

/* Bug # 8363373 End */

end pay_gtnlod_pkg;

/
