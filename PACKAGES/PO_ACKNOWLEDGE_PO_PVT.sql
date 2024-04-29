--------------------------------------------------------
--  DDL for Package PO_ACKNOWLEDGE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACKNOWLEDGE_PO_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVACKS.pls 120.1 2005/07/08 08:57:40 smeghani noship $ */

FUNCTION Get_Po_Status_Code (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER )
RETURN VARCHAR2;


FUNCTION Get_Shipment_Ack_Change_Status (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	P_line_location_id	IN	NUMBER,
	p_po_header_id		IN 	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2;


PROCEDURE Acknowledge_Shipment (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_line_location_id	IN	NUMBER,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER,
	p_accepted_flag		IN	VARCHAR2,
	p_comment		IN	VARCHAR2 default null,
	p_buyer_id		IN	NUMBER,
	p_user_id		IN	NUMBER );


PROCEDURE Carry_Over_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER );


FUNCTION All_Shipments_Responded (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2;


PROCEDURE Set_Header_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER );

FUNCTION Get_Header_Ack_Change_Status (
	p_po_header_id	IN 	NUMBER,
	p_po_release_id	IN	NUMBER,
	p_revision_num	IN	NUMBER )
RETURN VARCHAR2;

END PO_ACKNOWLEDGE_PO_PVT;

 

/
