--------------------------------------------------------
--  DDL for Package HXC_TCD_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TCD_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: hxctcdrpt.pkh 120.3.12010000.3 2008/11/14 13:37:55 anuthi ship $ */


	p_resource_id		varchar2(100);

	p_rec_period_id	varchar2(100);
	p_tc_period		varchar2(100);
	p_period_start_date	DATE;
	p_period_end_date	DATE;
	p_supervisor_id	varchar2(100);
	p_reptng_emp		varchar2(20) ;
	p_org_id		varchar2(100);
	p_location_id		varchar2(100);

	p_sel_supervisor_id 	varchar2(100);
	p_sel_tc_status		varchar2(20);


	l_resource_id		varchar2(100);

	l_rec_period_id		varchar2(100);
	l_period_start_date	DATE;
	l_period_end_date	DATE;
	l_supervisor_id		varchar2(100);
	l_reptng_emp		varchar2(20) ;
	l_org_id		varchar2(100);
	l_location_id		varchar2(100);

	l_rec_period		varchar2(100);
	l_tc_period		varchar2(100);
	l_supervisor_name	varchar2(240);
	l_location_name	varchar2(240);
	l_org_name		varchar2(240);

	l_sel_supervisor_id 	varchar2(100);
	l_sel_tc_status		varchar2(20);
	l_rpt_status		varchar2(50);


	procedure populate_report_table;
	procedure clear_report_table;
	function afterpform return boolean;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function get_timecard_end_date(p_person_id IN NUMBER, p_timecard_id IN NUMBER, p_period_end_date IN DATE default null) return date;
	function get_timecard_start_date(p_person_id IN NUMBER, p_timecard_id IN NUMBER, p_period_start_date IN DATE default null, p_period_end_date IN DATE default null) return date;
END HXC_TCD_XML_PKG;

/
