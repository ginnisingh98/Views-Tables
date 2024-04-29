--------------------------------------------------------
--  DDL for Package Body OE_SERVICES_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SERVICES_PROCESS" AS
/* $Header: OEXSERVB.pls 115.0 99/07/16 08:15:48 porting ship $  vmulky */
OE_SUCCESS  CONSTANT VARCHAR2(1) := 'Y';
OE_FAILURE  CONSTANT VARCHAR2(1) := 'N';


Procedure  Get_Item_Information
(	Services_Component_Code   	IN OUT VARCHAR2
,	Services_Item_Type_Code	 	IN OUT VARCHAR2
,       Services_Item_Description  	IN OUT VARCHAR2
,	Organization_Id		  	IN NUMBER
,	Services_Inventory_Item_Id 	IN NUMBER
,	Parameter_result		IN OUT VARCHAR2
)
is
	CURSOR item_info ( X_org_id  NUMBER,
			   X_Services_Inventory_Item_Id NUMBER) is
	SELECT DECODE(msi.service_item_flag,'Y', 'SERVICE', 'UNKNOWN' )
	,     TO_CHAR(  SERVICES_INVENTORY_ITEM_ID )
	,     DESCRIPTION
	FROM   MTL_SYSTEM_ITEMS msi
	WHERE  msi.ORGANIZATION_ID   = X_ORG_ID
	AND    msi.INVENTORY_ITEM_ID = X_SERVICES_INVENTORY_ITEM_ID;

begin

	OPEN item_info(Organization_Id,Services_Inventory_Item_Id) ;
	FETCH item_info
	INTO
		SERVICES_ITEM_TYPE_CODE
	, 	SERVICES_COMPONENT_CODE
	,       SERVICES_ITEM_DESCRIPTION;
	CLOSE item_info;

	/*SELECT TO_CHAR(  SERVICES_INVENTORY_ITEM_ID )
	,     DESCRIPTION
       	INTO   SERVICES_COMPONENT_CODE
	,      SERVICES_ITEM_DESCRIPTION
	FROM   MTL_SYSTEM_ITEMS
	WHERE  ORGANIZATION_ID   = ORGANIZATION_ID
	AND    INVENTORY_ITEM_ID = SERVICES_INVENTORY_ITEM_ID;*/

        Parameter_Result:=OE_SUCCESS;

exception

 when no_data_found then
             null;
 when others then
      Parameter_Result:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SERV.Get_Item_Information',
                                Operation=>'',
				Object=>'SERVICE',
                                Message=>' When Others');




end  Get_Item_Information;



Procedure Get_Service_Detail_Controls
( 		    Order_enforce_line_prices_flag  	 IN  VARCHAR2
,                   Services_adjustable_flag  		 OUT VARCHAR2
,                   Services_apply_order_adjs_flag 	 OUT VARCHAR2
,                   Services_creditable_flag  		 OUT VARCHAR2
,   		    Apply_order_adjs_to_service  	 IN VARCHAR2
,                   Parameter_result			 IN OUT VARCHAR2
)
is
begin

      if ( order_enforce_line_prices_flag = 'Y' ) then
	 Services_Adjustable_Flag := 'N';
      else
     	 Services_Adjustable_Flag := 'Y';
      end if;

      Services_apply_order_adjs_flag := Apply_order_adjs_to_service;
      Services_creditable_flag := 'Y';

exception

 when no_data_found then

     null;

 when others then
      Parameter_Result:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                              'OE_SERV.Get_Service_Detail_Controls',
                                Operation=>'',
				Object=>'SERVICE',
                                Message=>' When Others');

end Get_Service_Detail_Controls;

  --
  -- NAME
  --   Next_Line_Number
  --
  -- PURPOSE
  --   Selects the next order services line number sequence for the order.
  --

  FUNCTION Next_Order_Line_Number(X_Service_Parent_Line_Id NUMBER) Return NUMBER IS
    Line_Num NUMBER;
    CURSOR C_Next_Line_Number(X_Service_Parent_Line_Id NUMBER) IS
      SELECT Nvl(Max(line_number), 0) + 1
      FROM   so_lines
      WHERE  service_parent_line_id = X_Service_Parent_Line_Id ;
  begin
    OPEN C_Next_Line_Number(X_Service_Parent_Line_Id);
    FETCH C_Next_Line_Number INTO Line_Num;
    CLOSE C_Next_Line_Number;
    return(Line_Num);
  exception
    When OTHERS then
      OE_MSG.Internal_Exception('OE_SERV.Next_Line_Number',
				'Fetch Next Line Number', 'LINE');
  end Next_Order_Line_Number;

end OE_SERVICES_PROCESS;

/
