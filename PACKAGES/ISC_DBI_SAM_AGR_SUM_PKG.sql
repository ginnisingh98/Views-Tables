--------------------------------------------------------
--  DDL for Package ISC_DBI_SAM_AGR_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SAM_AGR_SUM_PKG" AUTHID CURRENT_USER as
/* $Header: ISCRGCBS.pls 120.1 2005/09/02 14:49:21 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl);

function ttl1 (p_param in bis_pmv_page_parameter_tbl) return varchar2;

function ttl2 (p_param in bis_pmv_page_parameter_tbl) return varchar2;


end isc_dbi_sam_agr_sum_pkg;

 

/
