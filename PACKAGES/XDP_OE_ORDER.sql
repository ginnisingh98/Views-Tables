--------------------------------------------------------
--  DDL for Package XDP_OE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_OE_ORDER" AUTHID CURRENT_USER AS
/* $Header: XDPOEORS.pls 120.1 2005/06/16 02:09:15 appldev  $ */

	-- API Specifications

	PROCEDURE Insert_OE_Order( P_OE_Order_Header IN XDP_TYPES.OE_ORDER_HEADER,
				P_OE_Order_Parameter_List IN XDP_TYPES.OE_ORDER_PARAMETER_LIST,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2 ) ;

	FUNCTION OE_Order_Exists( P_Order_Number IN varchar2,
					P_Version IN VARCHAR2 DEFAULT '1') RETURN VARCHAR2 ;

	PROCEDURE Insert_OE_Order_Line( P_OE_Order_Line IN XDP_TYPES.OE_ORDER_LINE,
				P_OE_Order_Line_Detail_List IN XDP_TYPES.OE_ORDER_LINE_DETAIL_LIST,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2 ) ;

	PROCEDURE Submit_OE_Order( P_OE_Order_Number IN VARCHAR2,
				P_OE_Order_Version IN VARCHAR2 DEFAULT '1',
				SDP_Order_ID OUT NOCOPY NUMBER,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2) ;
END	XDP_OE_ORDER ;

 

/
