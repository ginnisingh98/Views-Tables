--------------------------------------------------------
--  DDL for Package PO_REQCHANGEREQUESTNOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQCHANGEREQUESTNOTIF_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRCNS.pls 120.3 2006/07/10 07:57:04 yqian noship $ */

/*************************************************************************
 * +=======================================================================+
 * |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
 * |                         All rights reserved.                          |
 * +=======================================================================+
 * |  FILE NAME:    POXVRCNS.pls                                           |
 * |                                                                       |
 * |  PACKAGE NAME: PO_ReqChangeRequestNotif_PVT                           |
 * |                                                                       |
 * |  DESCRIPTION:                                                         |
 * |    PO_ReqChangeRequestNotif_PVT is a private level package.           |
 * |    It contains 3 public procedure which are used to generate          |
 * |    notifications used in requester change order workflows.            |
 * |                                                                       |
 * |  PROCEDURES:                                                          |
 * |      Get_Req_Chg_Approval_Notif                                       |
 * |           generate the req change approval notification               |
 * |      Get_Req_Chg_Response_Notif                                       |
 * |           generate the notification to requester about the response   |
 * |           to the change request                                       |
 * |      Get_Po_Chg_Approval_Notif                                        |
 * |           generate the notification to the buyer of the PO            |
 * |           for buyer's approval                                        |
 * |  FUNCTIONS:                                                           |
 * |      none                                                             |
 * |                                                                       |
 * +=======================================================================+
 */

PROCEDURE Get_Req_Chg_Approval_Notif(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out nocopy clob,
                                 document_type	in out	nocopy varchar2);
PROCEDURE Get_Req_Chg_Response_Notif(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out nocopy clob,
                                 document_type	in out	nocopy varchar2);
PROCEDURE Get_Po_Chg_Approval_Notif(document_id	IN varchar2,
                                 display_type   in      Varchar2,
                                 document in out nocopy clob,
                                 document_type  in out  nocopy varchar2);

function get_goods_shipment_new_amount(p_group_id in number,
                            p_po_line_id in number,
                            p_po_shipment_id in number,
                            p_old_price in number,
                            p_old_quantity in number
)
return number;



FUNCTION get_goods_shipment_new_amount(p_org_id in number,
 	            p_group_id in number,
                    p_line_id in number,
                    p_item_id in number,
                    p_line_uom in varchar2,
                    p_old_price in number,
                    p_line_location_id in number
)
return number;


FUNCTION Get_PO_Price_Break_Grp(p_org_id in number,
 				  p_group_id in number,
                        	  p_line_id in number,
                        	  p_item_id in number,
                        	  p_line_uom in varchar2,
                        	  p_old_price in number,
                                  p_line_location_id number)
return number;

FUNCTION  Get_Price(p_org_id in number,
                    p_group_id in number,
                    p_line_id in number,
                    p_item_id in number,
                    p_line_uom in varchar2,
                    p_old_price in number,
                    p_line_location_id in number)
return number;

PROCEDURE Get_Currency_Info ( p_po_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              x_po_in_txn_currency OUT NOCOPY VARCHAR2,
                              x_rate OUT NOCOPY NUMBER
                               ) ;

end PO_ReqChangeRequestNotif_PVT;

 

/
