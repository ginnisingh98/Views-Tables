--------------------------------------------------------
--  DDL for Package OE_DROP_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DROP_SHIP_PVT" AUTHID CURRENT_USER as
/* $Header: OEXVDPVS.pls 115.1 99/10/20 15:28:10 porting shi $ */

FUNCTION get_po_status
(
  p_po_header_id	IN	NUMBER
) return VARCHAR2;

/*pragma restrict_references(get_po_status, WNDS, WNPS);*/

FUNCTION get_release_status
(
  p_po_release_id	IN	NUMBER
) return VARCHAR2;

/*pragma restrict_references(get_release_status, WNDS, WNPS); */


Function COMPARE_PO_SO ( p_so_location number,
                         p_po_location number,
                         p_so_unit_of_measure varchar2,
                         p_po_unit_of_measure varchar2,
                         p_so_schedule_date date,
                         p_po_schedule_date date,
                         p_so_ordered_qty number,
                         p_so_cancelled_qty number,
			 p_so_shipped_quantity number,
                         p_potableused varchar2,
                         p_headerid number,
                         p_lineid number) return varchar2;

pragma restrict_references(COMPARE_PO_SO, WNDS, WNPS);

Function get_hold_name(p_holdid in number) return varchar2;

pragma restrict_references(get_hold_name, WNDS, WNPS);

PROCEDURE recover_schedule (P_API_Version      In Number,
                                  P_Return_Status    Out Varchar2,
                                  P_Msg_Count        Out Number,
                                  P_MSG_Data         Out Varchar2,
                                  p_line_id	IN	NUMBER);


END OE_DROP_SHIP_PVT;

 

/
