--------------------------------------------------------
--  DDL for Package POR_APPRV_WF_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_APPRV_WF_UTIL_GRP" AUTHID CURRENT_USER AS
/* $Header: PORWFUTS.pls 115.1 2004/03/31 18:47:56 vkartik noship $ */

/*===========================================================================
  FUNCTION NAME:        get_po_number

  DESCRIPTION:          Gets the po number for the given line_location_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_po_number(p_line_location_id IN NUMBER) RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:        get_so_number

  DESCRIPTION:          Gets the sales order number for the given
                        requisition_line_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_so_number(p_req_line_id IN NUMBER) RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:        get_cost_center

  DESCRIPTION:          Gets the cost_center for the given requisition_line_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_cost_center(p_req_line_id IN NUMBER) RETURN VARCHAR2 ;

END POR_APPRV_WF_UTIL_GRP;

 

/
