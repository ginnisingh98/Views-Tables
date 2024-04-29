--------------------------------------------------------
--  DDL for Package ICX_POR_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_WF_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXWFUTS.pls 115.1 2004/03/31 18:47:53 vkartik noship $ */

/* Function returns po number for the given line_location_id */
FUNCTION get_po_number(p_line_location_id IN NUMBER) RETURN VARCHAR2;

/* Function returns sales order number for the given requsition_line_id */
FUNCTION get_so_number(p_req_line_id IN NUMBER) RETURN VARCHAR2;

/* Function returns cost center for the given requsition_line_id */
FUNCTION get_cost_center(p_req_line_id IN NUMBER) RETURN VARCHAR2 ;

END icx_por_wf_util_pkg;

 

/
