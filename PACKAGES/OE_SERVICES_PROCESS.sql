--------------------------------------------------------
--  DDL for Package OE_SERVICES_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SERVICES_PROCESS" AUTHID CURRENT_USER AS
/* $Header: OEXSERVS.pls 115.0 99/07/16 08:15:51 porting ship $ */

PROCEDURE Get_Item_Information
(	Services_Component_Code    	IN OUT VARCHAR2
,	Services_Item_Type_code		IN OUT VARCHAR2
,       Services_Item_Description  	IN OUT VARCHAR2
,	Organization_Id		   	IN NUMBER
,	Services_Inventory_Item_Id	IN NUMBER
,	Parameter_result		IN OUT VARCHAR2
) ;


Procedure Get_Service_Detail_Controls
( 		   Order_enforce_line_prices_flag 	 IN VARCHAR2 ,
                   Services_adjustable_flag 		 OUT VARCHAR2 ,
                   Services_apply_order_adjs_flag 	 OUT VARCHAR2 ,
                   Services_creditable_flag 		 OUT VARCHAR2 ,
		   Apply_order_adjs_to_service 		IN  VARCHAR2 ,
                   Parameter_result  			IN OUT VARCHAR2
);


FUNCTION Next_Order_Line_Number(X_Service_Parent_Line_Id NUMBER) Return NUMBER  ;


END OE_SERVICES_PROCESS;



 

/
