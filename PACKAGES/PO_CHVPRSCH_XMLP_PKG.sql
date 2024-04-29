--------------------------------------------------------
--  DDL for Package PO_CHVPRSCH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHVPRSCH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CHVPRSCHS.pls 120.1 2007/12/25 10:38:24 krreddy noship $ */
	P_horizon_end	date;
	P_schedule_type	varchar2(25);
	P_horizon_start	date;
	P_schedule_sub	varchar2(25);
	P_schedule_num	varchar2(30);
	P_vendor_name_from	varchar2(80);
	P_site	varchar2(15);
	P_test_print	varchar2(1);
	P_organization_name	varchar2(40);
	P_vendor_name_to	varchar2(80);
	P_ORGANIZATION_ID	number;
	P_qty_precision	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_EXCLUDE_ZERO_QUANTITY_LINES	varchar2(40);
	P_BATCH_ID	varchar2(40);
	P_SCHEDULE_REV	varchar2(40);
	P_AUTOSCHEDULE_FLAG	varchar2(40);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function g_headersgroupfilter(csh_schedule_id in number) return boolean  ;
	function addressformula(organization_id in number) return char  ;
	function AfterReport return boolean  ;
END PO_CHVPRSCH_XMLP_PKG;


/
