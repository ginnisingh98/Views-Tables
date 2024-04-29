--------------------------------------------------------
--  DDL for Package Body OE_OPT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OPT_PROCESS" AS
/* $Header: OEXOPPRB.pls 115.3 99/07/16 08:13:58 porting shi $ */

OE_SUCCESS  CONSTANT VARCHAR2(1) := 'Y';
OE_FAILURE  CONSTANT VARCHAR2(1) := 'N';

PROCEDURE Get_Item_Information
(
      Options_Inventory_Item_Id                  IN NUMBER,
      Options_Item_Type_Code                     IN OUT VARCHAR2,
      Options_Item_Type                          OUT VARCHAR2,
      P_Organization_Id                          IN NUMBER,
      Lines_Component_Sequence_Id                IN NUMBER,
      Options_Component_Code                     IN VARCHAR2,
      Configuration_Parent_Line_Id  		 IN NUMBER,
      Options_ATO_Flag                           OUT VARCHAR2,
      Options_ATO_Line_Id                        OUT NUMBER,
      ATO_Parent_Component_Code          	 OUT VARCHAR2,
      Lines_ATO_Flag                             IN  VARCHAR2 ,
      Options_Line_Id                            IN OUT NUMBER,
      Serviceable_Flag                           OUT VARCHAR2,
      Item                                       IN VARCHAR2,
      Lines_Ship_Model_Comp_Flag                 IN VARCHAR2,
      Options_Ship_Model_Comp_Flag               OUT VARCHAR2,
      Options_Plan_Level                         IN  NUMBER,
      Lines_Creation_Date_Time                   IN  DATE,
      Return_Status  				 OUT VARCHAR2
)
is

L_Return_status    VARCHAR2(1);



CURSOR c_ato_attributes(x_options_comp_code   VARCHAR2,
			x_lines_comp_seq_id   NUMBER,
			x_options_plan_level  NUMBER,
			x_lines_creation_date DATE) is
SELECT   'Y'
        ,DECODE( BOMEXP.COMPONENT_CODE,
		 x_options_comp_code, NULL, OELIN.LINE_ID )
        ,BOMEXP.COMPONENT_CODE
  FROM   BOM_EXPLOSIONS  BOMEXP
        ,MTL_SYSTEM_ITEMS MTLITM
        ,SO_LINES OELIN
  WHERE  BOMEXP.TOP_BILL_SEQUENCE_ID = x_lines_comp_seq_id
  AND    BOMEXP.EXPLOSION_TYPE = 'OPTIONAL'
  AND    BOMEXP.PLAN_LEVEL <= x_options_plan_level
  AND    BOMEXP.EFFECTIVITY_DATE <=
         NVL(x_lines_creation_date,  SYSDATE)
  AND    BOMEXP.DISABLE_DATE >
         NVL(x_lines_creation_date,  SYSDATE)
  AND    BOMEXP.COMPONENT_CODE =
         SUBSTR( x_options_comp_code, 1,
		 LENGTH( BOMEXP.COMPONENT_CODE ) )
  AND    LENGTH( BOMEXP.COMPONENT_CODE ) <=
         LENGTH( x_options_comp_code )
  AND    MTLITM.ORGANIZATION_ID = BOMEXP.ORGANIZATION_ID
  AND    MTLITM.INVENTORY_ITEM_ID = BOMEXP.COMPONENT_ITEM_ID
  AND    DECODE( MTLITM.BOM_ITEM_TYPE,
                 1, NVL( MTLITM.REPLENISH_TO_ORDER_FLAG, 'N' ),
                 4, DECODE( MTLITM.REPLENISH_TO_ORDER_FLAG,
                            'Y', DECODE( MTLITM.BUILD_IN_WIP_FLAG,
                                         'Y', 'Y', 'N' ),
                            'N' ),
                 'N' ) = 'Y'
  AND    OELIN.PARENT_LINE_ID (+) = CONFIGURATION_PARENT_LINE_ID
  AND    OELIN.SERVICE_PARENT_LINE_ID (+) is NULL
  AND    OELIN.COMPONENT_CODE (+) = BOMEXP.COMPONENT_CODE
  ORDER BY BOMEXP.SORT_ORDER;

begin

  Return_Status:=OE_SUCCESS;

  Options_Ship_Model_Comp_Flag:=Lines_Ship_Model_Comp_Flag;


  if (Lines_ATO_Flag = 'Y') then
     Options_ATO_Flag:='Y';
     Options_ATO_Line_Id:=Configuration_Parent_Line_Id;
  else
     Options_ATO_Flag:='N';
     Options_ATO_Line_Id:=NULL;
  end if;

  if OPTIONS_INVENTORY_ITEM_ID is not null then
     SELECT DECODE( BOM_ITEM_TYPE,
               1, 'MODEL',
               2, 'CLASS',
               4, DECODE( PICK_COMPONENTS_FLAG, 'Y', 'KIT', 'STANDARD' ),
               'UNKNOWN' ),
      NVL(SERVICEABLE_PRODUCT_FLAG,'N')
      INTO   Options_ITEM_TYPE_CODE,
          Serviceable_Flag
      FROM   MTL_SYSTEM_ITEMS
      WHERE  ORGANIZATION_ID = P_Organization_Id
      AND    INVENTORY_ITEM_ID = Options_INVENTORY_ITEM_ID;

     select meaning into Options_Item_Type from so_lookups
       where lookup_type = 'ITEM TYPE' and
             lookup_code = Options_Item_Type_Code;


--Search for a parent ATO component in the explosion table.  Note that we
--cannot search SO_LINES for a parent ATO component because it may not yet
--exist in the database.  Also note that we're looking for the highest-
--positioned ATO component in the BOM (the ORDER BY clause ensures that the
--highest-positioned component is selected first).  The cursor now
--explicitly retrieves only the first record.

     if  Lines_ATO_Flag <> 'Y' THEN

	OPEN c_ato_attributes(options_component_code,
			      lines_component_sequence_id,
			      options_plan_level,
			      lines_creation_date_time);

	FETCH c_ato_attributes INTO
	  options_ato_flag,
	  options_ato_line_id,
	  ato_parent_component_code;

	CLOSE c_ato_attributes;

     end if;

  end if;

exception

 when no_data_found then
             null;
 when too_many_rows then
     null;
 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Get_Item_Information',
                                Operation=>'',
				Object=>'OPTION',
                                Message=>' When Others'||sqlcode);


end Get_Item_Information;


PROCEDURE Get_Option_Detail_Controls
(
        World_Organization_Id            IN NUMBER,
        Options_Inventory_Item_Id        IN NUMBER,
        Options_ATO_Flag                 IN VARCHAR2,
        ATO_Parent_Component_Code        IN VARCHAR2,
        Options_Component_Code           IN VARCHAR2,
        Options_ATO_Line_Id              IN NUMBER,
        Options_Schedulable_Flag         OUT VARCHAR2,
        Order_Enforce_List_Prices_Flag   IN VARCHAR2,
        Options_Adjustable_Flag          OUT VARCHAR2,
        Apply_Order_Adjs_Flag            OUT VARCHAR2,
        Options_Serviceable_Flag         OUT VARCHAR2,
	P_Return_Status			 OUT VARCHAR2
)

is

begin


if (Options_ATO_Flag = 'Y') then
--  if (Options_ATO_Parent_Component_Code =
--           Options_Component_Code) then
	if ( Options_ATO_Line_Id is null ) then
	      Options_Schedulable_Flag:='Y';
	else
	      Options_Schedulable_Flag:='N';
	end if;
else
	Options_Schedulable_Flag:='Y';
end if;

if (Order_Enforce_List_Prices_Flag  = 'Y') then
    Options_Adjustable_Flag:='N';
else
    Options_Adjustable_Flag:='Y';
end if;

Apply_Order_Adjs_Flag:='Y';

SELECT NVL(SERVICEABLE_PRODUCT_FLAG,'N')
INTO   Options_Serviceable_Flag
FROM   MTL_SYSTEM_ITEMS
WHERE  ORGANIZATION_ID = World_Organization_Id
AND    INVENTORY_ITEM_ID = Options_Inventory_Item_Id;

exception

when no_data_found then

     null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Get_Option_Detail_Controls',
                                Operation=>'',
				Object=>'OPTION',
                                Message=>' When Others');


end Get_Option_Detail_Controls;

PROCEDURE Get_ATO_Parent_Information
(
        Options_ATO_Line_Id               IN NUMBER,
        Options_ATO_Parent_Comp_Code      OUT VARCHAR2,
	P_Return_Status			  OUT VARCHAR2
)
is

begin

        SELECT COMPONENT_CODE
        INTO   Options_ATO_Parent_Comp_Code
        FROM   SO_LINES
        WHERE  LINE_ID = Options_ATO_Line_Id;

exception

 when no_data_found then
       null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Get_ATO_Parent_Information',
                                Operation=>'',
				Object=>'OPTION',
                                Message=>' When Others');

end Get_ATO_Parent_Information;

PROCEDURE Insert_Installn_Details
(
        P_Line_Id                           IN NUMBER,
        P_User_Id                           IN NUMBER,
        P_Login_Id                          IN NUMBER,
        P_Configuration_Parent_Line_Id      IN NUMBER,
	P_Return_Status			    OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;

INSERT INTO SO_LINE_SERVICE_DETAILS
(      LINE_SERVICE_DETAIL_ID
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN
     , LINE_ID
     , SOURCE_LINE_SERVICE_DETAIL_ID
     , TRANSACTION_TYPE_ID
     , SYSTEM_ID
     , SYSTEM_TYPE_CODE
     , CUSTOMER_PRODUCT_ID
     , CUSTOMER_PRODUCT_TYPE_CODE
     , CUSTOMER_PRODUCT_QUANTITY
     , INSTALLATION_SITE_USE_ID
     , TECHNICAL_CONTACT_ID
     , SERVICE_ADMIN_CONTACT_ID
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
)
SELECT SO_LINE_SERVICE_DETAILS_S.NEXTVAL
     , SYSDATE
     , P_User_Id
     , SYSDATE
     , P_User_Id
     , P_Login_Id
     , P_Line_Id
     , LINE_SERVICE_DETAIL_ID
     , TRANSACTION_TYPE_ID
     , SYSTEM_ID
     , SYSTEM_TYPE_CODE
     , CUSTOMER_PRODUCT_ID
     , CUSTOMER_PRODUCT_TYPE_CODE
     , CUSTOMER_PRODUCT_QUANTITY
     , INSTALLATION_SITE_USE_ID
     , TECHNICAL_CONTACT_ID
     , SERVICE_ADMIN_CONTACT_ID
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
FROM   SO_LINE_SERVICE_DETAILS
WHERE  LINE_ID = P_Configuration_Parent_Line_Id
AND    TRANSACTION_TYPE_ID = 2;

exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Insert_Service_Details',
                                Operation=>'',
				Object=>'OPTION',
                                Message=>' When Others');

end Insert_Installn_Details;

/* Select statement modified to get low,high quantities from
   the BOM - 895383 (894316 in Rel 11) */

PROCEDURE Query_BOM_Quantity
(
        P_Creation_Date_Time                IN DATE,
        P_Component_Sequence_Id             IN NUMBER,
        P_Component_Code                    IN VARCHAR2,
        P_Model_Open_Quantity               IN NUMBER,
        P_Component_Quantity                IN OUT NUMBER,
        P_Low_Quantity                      IN OUT NUMBER,
        P_High_Quantity                     IN OUT NUMBER,
        P_Return_Status                     OUT VARCHAR2
)
is

begin

	P_Return_Status:=OE_SUCCESS;

        SELECT EXTENDED_QUANTITY / COMPONENT_QUANTITY *
               P_Model_Open_Quantity
        ,      NVL( LOW_QUANTITY, 1 )
        ,      HIGH_QUANTITY
        INTO   P_Component_Quantity
        ,      P_Low_quantity
        ,      P_High_Quantity
        FROM   BOM_EXPLOSIONS
        WHERE  TOP_BILL_SEQUENCE_ID = P_Component_Sequence_Id
        AND    COMPONENT_CODE = P_Component_Code
	   AND    EXPLOSION_TYPE = 'OPTIONAL'
	   AND    PLAN_LEVEL > 0
	   AND    EFFECTIVITY_DATE <=
          NVL(P_Creation_Date_Time,
          SYSDATE)
	   AND    DISABLE_DATE >
          NVL(P_Creation_Date_Time,
          SYSDATE);



exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Query_BOM_Quantity',
                                Operation=>'',
				            Object=>'OPTION',
                                Message=>' When Others');

end Query_BOM_Quantity;

PROCEDURE Set_Update_Subconfig_Flag
(
        P_Row_Id                            IN VARCHAR2,
        P_Ordered_Quantity                  IN NUMBER,
        P_Update_Subconfig_Flag             OUT VARCHAR2,
        P_Return_Status                     OUT VARCHAR2
)
is

L_Dummy NUMBER;

begin

     SELECT NULL INTO L_Dummy
	FROM   SO_LINES
	WHERE  ROWID = P_Row_Id
	AND    NVL( ORDERED_QUANTITY, -1 )
	<> NVL( P_Ordered_Quantity, -1 );

      P_Update_Subconfig_Flag:='Y';

exception

 when  no_data_found then

      P_Update_Subconfig_Flag:='N';

 when others then

      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_PROCESS.Set_Update_Subconfig_Flag',
                                Operation=>'',
                                Object=>'OPTION',
                                Message=>' When Others');

end Set_Update_Subconfig_Flag;


end OE_OPT_PROCESS;

/
