--------------------------------------------------------
--  DDL for Package ISC_DBI_SAM_TOP_AGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SAM_TOP_AGR_PKG" AUTHID CURRENT_USER as
/* $Header: ISCRGCGS.pls 120.0 2005/08/30 13:45:19 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl);

end isc_dbi_sam_top_agr_pkg;

 

/
