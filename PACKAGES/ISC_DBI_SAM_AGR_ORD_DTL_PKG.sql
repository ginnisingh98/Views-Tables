--------------------------------------------------------
--  DDL for Package ISC_DBI_SAM_AGR_ORD_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SAM_AGR_ORD_DTL_PKG" AUTHID CURRENT_USER as
/* $Header: ISCRGCLS.pls 120.0 2005/08/30 13:45:39 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl);

end isc_dbi_sam_agr_ord_dtl_pkg;

 

/
