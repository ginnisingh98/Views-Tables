--------------------------------------------------------
--  DDL for Package ISC_DBI_SAM_PRF_COM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SAM_PRF_COM_PKG" AUTHID CURRENT_USER as
/* $Header: ISCRGCCS.pls 120.0 2005/08/30 13:44:09 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl);

end isc_dbi_sam_prf_com_pkg;

 

/
