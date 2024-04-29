--------------------------------------------------------
--  DDL for Package Body OE_ITORD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ITORD_UTIL" AS
/* $Header: OEITORDB.pls 120.6.12010000.4 2008/09/22 06:46:15 smanian ship $ */


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ITORD_UTIL';

--------------------------------------------------------------------------------------
--Function get_item_category_id will return the item category_id for the passed inventory_item_id
--------------------------------------------------------------------------------------
Function get_item_category_id ( p_inventory_item_id IN Number )
Return Number IS
 l_item_category_id Number;
begin

    IF  NOT OE_GLOBALS.Equal( p_inventory_item_id , G_INVENTORY_ITEM_ID ) then
	select category_id
		into l_item_category_id
	from mtl_item_categories ic,
	     MTL_DEFAULT_CATEGORY_SETS CS
	where  ic.category_set_id=cs.category_set_id
	AND CS.functional_area_id         = 7
	AND ic.organization_id=oe_sys_parameters.Value('MASTER_ORGANIZATION_ID')
	AND IC.INVENTORY_ITEM_ID          = p_inventory_item_id ;

        G_INVENTORY_ITEM_ID := p_inventory_item_id;
	G_ITEM_CATEGORY_ID  := l_item_category_id;

        return l_item_category_id;
    ELSE
	Return G_ITEM_CATEGORY_ID;
    END IF;
 Exception
	when others then
	return null;

 End get_item_category_id;

--------------------------------------------------------------------------------------
 --Function get_customer_class_id will return the customer_class_id for the passed customer_id
 --------------------------------------------------------------------------------------
 Function get_customer_class_id ( p_customer_id IN Number )
 Return Number IS
	l_customer_class_id Number;
 begin

    IF  NOT OE_GLOBALS.Equal( p_customer_id , G_SOLD_TO_ORG_ID ) then

        SELECT cp.profile_class_id
		into l_customer_class_id
	FROM
		HZ_CUSTOMER_PROFILES cp ,
		hz_cust_profile_classes cpc
	WHERE  cpc.profile_class_id=cp.PROFILE_CLASS_ID
	AND cp.site_use_id IS NULL
	AND cp.cust_account_id= p_customer_id;

        G_SOLD_TO_ORG_ID := p_customer_id;
	G_CUSTOMER_PROFILE_CLASS_ID := l_customer_class_id;

	return l_customer_class_id;
   ELSE
	Return G_CUSTOMER_PROFILE_CLASS_ID;
   END IF;

 Exception
	when others then
	return null;
 End;

--------------------------------------------------------------------------------------
--Function get_region_id will return the region_id for the passed ship_to_org_id
--bug7294798 using WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches to get all matching region_ids
--Get all the matching region_id for the current location_id and comma seperate it.This
-- comma seperated list of region_ids is used in validation routines and OE_ITEMS_ORD_MV to support rules based on regions
--------------------------------------------------------------------------------------
Function get_region_ids ( p_ship_to_org_id IN NUMBER)
Return varchar2
IS
l_location_id NUMBER;
l_region_id_list varchar2(32000) := ',';
l_return_status VARCHAR2(1);
l_region_id_tbl WSH_UTIL_CORE.ID_TAB_TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
begin

	 IF  NOT OE_GLOBALS.Equal( p_ship_to_org_id , G_SHIP_TO_ORGANIZATION_ID ) then

		IF p_ship_to_org_id IS NULL then
			RETURN NULL;
		END IF;

		l_location_id := OE_ITORD_UTIL.Get_Shipto_Location_Id(p_ship_to_org_id);

		WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches
		( p_location_id	  => l_location_id,
		  p_use_cache	  => TRUE,
		  p_lang_code	  => USERENV('LANG'),
		  x_region_tab    => l_region_id_tbl,
		  x_return_status => l_return_status );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
			IF l_debug_level > 0 then
				oe_debug_pub.add('Unexpected error in WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches');
			END IF;

		    RETURN NULL;
		END IF;

		for i in 1..l_region_id_tbl.count loop
		  l_region_id_list := l_region_id_list||to_char(l_region_id_tbl(i))||',';
		End loop;

		G_SHIP_TO_ORGANIZATION_ID    := p_ship_to_org_id;
		G_SHIP_TO_REGION_ID_LIST     := l_region_id_list;

		return l_region_id_list;
	ELSE
		Return G_SHIP_TO_REGION_ID_LIST;
	END IF;
Exception
	when others then
		IF l_debug_level > 0 then
			oe_debug_pub.add('Unexpected error in getting the region_ids :'||SQLERRM);
		END IF;

	return NULL;

End get_region_ids;

---------------------------------------------------------------------------------------------------------
--Function get_customer_category_code will return the Customer Category Code for the given sold_to_org_id
---------------------------------------------------------------------------------------------------------
Function get_customer_category_code ( p_customer_id IN NUMBER )
Return Varchar2
IS
l_customer_category_code Varchar2(30);
begin
     IF  NOT OE_GLOBALS.Equal( p_customer_id , G_CUST_ID ) then
	SELECT  party.CATEGORY_CODE
		into l_customer_category_code
	FROM
		HZ_CUST_ACCOUNTS cust,
		HZ_PARTIES party
	WHERE cust.party_id = party.party_id
	and   cust.cust_account_id = p_customer_id;

	G_CUST_ID := p_customer_id;
	G_CUST_CATEGORY_CODE := l_customer_category_code;

	return l_customer_category_code;
    ELSE
	return G_CUST_CATEGORY_CODE;
    END IF;
Exception
	when others then
	return null;
END get_customer_category_code;


-----------------------------------------------------------------------------------------------------------
--Function get_item_name returns the concatenated_segments for the passed item_id
-----------------------------------------------------------------------------------------------------------

Function get_item_name ( p_inventory_item_id IN NUMBER )
RETURN VARCHAR2
IS
l_item Varchar2 (30000);
begin
	select concatenated_segments
	into l_item
	from mtl_system_items_kfv
	where inventory_item_id = p_inventory_item_id
	and organization_id = oe_sys_parameters.Value('MASTER_ORGANIZATION_ID');

        return l_item;

Exception
	when others then
	return null;
End get_item_name;

-----------------------------------------------------------------------------------------------------------
--Function get_item_category_name  returns the category  concatenated_segments for the passed item_id
-----------------------------------------------------------------------------------------------------------

Function get_item_category_name(p_inventory_item_id IN NUMBER )
RETURN VARCHAR2
IS
l_category Varchar2(30000);
begin
	select concatenated_segments
	into l_category
	from mtl_categories_kfv
	where  category_id  =  OE_ITORD_UTIL.get_item_category_id (p_inventory_item_id);

	 return l_category;
Exception
	when others then
	return null;
End get_item_category_name;
-----------------------------------------------------------------------------------------------------------
--Procedure set_globals will set the global vartiables which will be referenced in the view oe_items_ord_mv
-----------------------------------------------------------------------------------------------------------
Procedure set_globals (
P_CUSTOMER_ID		IN NUMBER,
P_CUSTOMER_CLASS_ID	IN NUMBER,
P_CUSTOMER_CATEGORY_CODE IN VARCHAR2,
P_REGION_ID_LIST         IN VARCHAR2,
P_ORDER_TYPE_ID         IN NUMBER,
P_SHIP_TO_ORG_ID        IN NUMBER,
P_SALES_CHANNEL_CODE    IN VARCHAR2,
P_SALESREP_ID           IN NUMBER,
P_END_CUSTOMER_ID       IN NUMBER,
P_INVOICE_TO_ORG_ID     IN NUMBER,
P_DELIVER_TO_ORG_ID     IN NUMBER
) IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
begin

	IF l_debug_level > 0 then
		oe_debug_pub.add(' Set Globals - P_CUSTOMER_ID :'||P_CUSTOMER_ID );
		oe_debug_pub.add(' Set Globals - P_CUSTOMER_CLASS_ID :'||P_CUSTOMER_CLASS_ID );
		oe_debug_pub.add(' Set Globals - P_CUSTOMER_CATEGORY_CODE :'||P_CUSTOMER_CATEGORY_CODE );
		oe_debug_pub.add(' Set Globals - P_REGION_ID_LIST :'|| P_REGION_ID_LIST );
		oe_debug_pub.add(' Set Globals - P_ORDER_TYPE_ID :'||P_ORDER_TYPE_ID );
		oe_debug_pub.add(' Set Globals - P_SHIP_TO_ORG_ID :'||P_SHIP_TO_ORG_ID );
		oe_debug_pub.add(' Set Globals - P_SALES_CHANNEL_CODE :'||P_SALES_CHANNEL_CODE);
		oe_debug_pub.add(' Set Globals - P_SALESREP_ID :'||P_SALESREP_ID );
		oe_debug_pub.add(' Set Globals - P_END_CUSTOMER_ID :'||P_END_CUSTOMER_ID );
		oe_debug_pub.add(' Set Globals - P_INVOICE_TO_ORG_ID :'||P_INVOICE_TO_ORG_ID);
		oe_debug_pub.add(' Set Globals - P_DELIVER_TO_ORG_ID :'||P_DELIVER_TO_ORG_ID);
		oe_debug_pub.add(' Set Globals - OPERATING_UNIT_ID  :'|| mo_global.get_current_org_id);
		oe_debug_pub.add(' Set Globals - ITEM_VALIDATION_ORG_ID  :'|| OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'));
	END IF;

	G_CUSTOMER_ID            := P_CUSTOMER_ID;
	G_CUSTOMER_CLASS_ID      := P_CUSTOMER_CLASS_ID;
	G_CUSTOMER_CATEGORY_CODE := P_CUSTOMER_CATEGORY_CODE;
	G_REGION_ID_LIST         := P_REGION_ID_LIST; --bug7294798
	G_ORDER_TYPE_ID          := P_ORDER_TYPE_ID;
	G_SHIP_TO_ORG_ID         := P_SHIP_TO_ORG_ID;
	G_SALES_CHANNEL_CODE     := P_SALES_CHANNEL_CODE;
	G_SALESREP_ID            := P_SALESREP_ID;
	G_END_CUSTOMER_ID        := P_END_CUSTOMER_ID;
	G_INVOICE_TO_ORG_ID      := P_INVOICE_TO_ORG_ID;
	G_DELIVER_TO_ORG_ID      := P_DELIVER_TO_ORG_ID;

	G_OPERATING_UNIT_ID      := mo_global.get_current_org_id;
	G_ITEM_VALIDATION_ORG_ID := OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
Exception
	when others then
	null;
End set_globals;


Function get_customer_id
Return Number
IS
BEGIN
	return G_CUSTOMER_ID;
END;


Function get_customer_class_id
Return number
IS
BEGIN
	return G_CUSTOMER_CLASS_ID;
END;

 Function get_customer_category_code
 Return varchar2
 IS
 BEGIN
	return G_CUSTOMER_CATEGORY_CODE;
 END;

 Function get_region_ids
 Return VARCHAR2
 IS
 BEGIN
	return G_REGION_ID_LIST;
 END;


 Function get_order_type_id
 Return Number
 IS
 BEGIN
	return G_ORDER_TYPE_ID;
 END;


 Function get_ship_to_org_id
 Return Number
 IS
 BEGIN
	return G_SHIP_TO_ORG_ID;
 END;

 Function get_sales_channel_code
 Return Varchar2
 IS
 BEGIN
	return G_SALES_CHANNEL_CODE;
 END;


 Function get_salesrep_id
 Return Number
 IS
 BEGIN
	return G_SALESREP_ID;
 END;



 Function get_end_customer_id
 Return Number
 IS
 BEGIN
	return G_END_CUSTOMER_ID;
 END;


 Function get_invoice_to_org_id
 Return Number
 IS
 BEGIN
	return G_INVOICE_TO_ORG_ID;
 END;


 Function get_deliver_to_org_id
 Return Number
 IS
 BEGIN
	return G_DELIVER_TO_ORG_ID;
 END;



 Function get_operating_unit_id
 Return Number
 IS
 BEGIN
	return G_OPERATING_UNIT_ID;
 END;


 Function get_item_validation_org_id
 Return Number
 IS
 BEGIN
	return G_ITEM_VALIDATION_ORG_ID;
 END;


--This function is called from process_order (Entity level validation OEXLLINB.pls)
--Returns true/false indicating orderable or not

Function Validate_item_orderability ( p_line_rec in OE_Order_PUB.Line_Rec_Type )
Return BOOLEAN IS
l_operating_unit_id NUMBER;
l_exists varchar2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


l_x_item_category_id NUMBER;
l_x_customer_class_id NUMBER;
l_x_sales_channel_code VARCHAR2(30);
l_x_order_type_id NUMBER;
l_x_customer_category_code Varchar2(30);
l_x_region_id_list VARCHAR2(32000);
l_exclusion_rule_exists Varchar2(1);

begin

 l_operating_unit_id   := p_line_rec.org_id;
 l_x_item_category_id  := OE_ITORD_UTIL.get_item_category_id (p_line_rec.inventory_item_id);
 l_x_customer_class_id := OE_ITORD_UTIL.get_customer_class_id(p_line_rec.sold_to_org_id);
 l_x_region_id_list    := OE_ITORD_UTIL.get_region_ids(p_line_rec.ship_to_org_id);
 l_x_customer_category_code := OE_ITORD_UTIL.get_customer_category_code (p_line_rec.sold_to_org_id);
 l_x_order_type_id      := OE_ITORD_UTIL.get_order_type_id (p_line_rec.header_id);
 l_x_sales_channel_code := OE_ITORD_UTIL.get_sales_channel_code(p_line_rec.header_id);

  IF l_debug_level >0 then
	oe_debug_pub.add('Entering OE_ITORD_UTIL.Validate_item_orderability',1);
        oe_debug_pub.add('Inventory_item_id :'||p_line_rec.inventory_item_id);
	oe_debug_pub.add('Item Category Id :'||l_x_item_category_id);
	oe_debug_pub.add('Customer ID :'|| p_line_rec.sold_to_org_id);
	oe_debug_pub.add('Customer Class ID  :'||l_x_customer_class_id);
	oe_debug_pub.add('region_id_list :'||l_x_region_id_list);
	oe_debug_pub.add('order_type_id :'||l_x_order_type_id);
	oe_debug_pub.add('sales_channel_code :'||l_x_sales_channel_code);

  END IF;


--Validation for Exclusion Rules

begin

	select 'Y' into l_exists
	From   oe_item_orderability hdr,
	       oe_item_orderability_rules  rules
	Where  hdr.orderability_id = rules.orderability_id
	and    hdr.generally_available='Y'
	and    hdr.org_id = l_operating_unit_id
	and    hdr.enable_flag = 'Y'
	and    rules.enable_flag = 'Y'
	and   ( hdr.inventory_item_id =  p_line_rec.inventory_item_id or hdr.item_category_id = l_x_item_category_id )
	and   (  rules.customer_id               = p_line_rec.sold_to_org_id
		or  rules.customer_class_id      = l_x_customer_class_id
		or  rules.customer_category_code = l_x_customer_category_code
		or  INSTR( l_x_region_id_list ,(','||to_char(rules.region_id)||',') ) <> 0
		or  rules.order_type_id          = l_x_order_type_id
		or  rules.ship_to_location_id    = p_line_rec.ship_to_org_id
		or  rules.sales_channel_code     = l_x_sales_channel_code
		or  rules.sales_person_id        = p_line_rec.salesrep_id
		or  rules.end_customer_id        = p_line_rec.end_customer_id
		or  rules.bill_to_location_id    = p_line_rec.invoice_to_org_id
		or  rules.deliver_to_location_id = p_line_rec.deliver_to_org_id
	       )
       and rownum = 1;

       l_exclusion_rule_exists := 'Y';
       return false;
Exception
	when others then
	l_exclusion_rule_exists := 'N';
End;

-- Validate Inclusion  Rules
IF l_exclusion_rule_exists = 'N' then

begin

	select 'Y' into l_exists
	From   oe_item_orderability hdr,
	       oe_item_orderability_rules  rules
	Where  hdr.orderability_id = rules.orderability_id
	and    hdr.generally_available='N'
	and    hdr.org_id = l_operating_unit_id
	and    hdr.enable_flag = 'Y'
	and    rules.enable_flag = 'Y'
	and   ( hdr.inventory_item_id = p_line_rec.inventory_item_id or hdr.item_category_id = l_x_item_category_id )
	and   (  rules.customer_id       = p_line_rec.sold_to_org_id
		or  rules.customer_class_id = l_x_customer_class_id
		or  rules.customer_category_code = l_x_customer_category_code
		or  INSTR( l_x_region_id_list ,(','||to_char(rules.region_id)||',') ) <> 0
		or  rules.order_type_id          = l_x_order_type_id
		or  rules.ship_to_location_id    = p_line_rec.ship_to_org_id
		or  rules.sales_channel_code     = l_x_sales_channel_code
		or  rules.sales_person_id        = p_line_rec.salesrep_id
		or  rules.end_customer_id        = p_line_rec.end_customer_id
		or  rules.bill_to_location_id    = p_line_rec.invoice_to_org_id
		or  rules.deliver_to_location_id = p_line_rec.deliver_to_org_id
	       )
       and rownum = 1;

	return true;
 Exception
	when no_data_found then
	 begin
		--This is to handle the inclusion rule case where only item orderablility header is defined but no rules are defined
		--Item is generally not available in all cases(since no rule is defeined in detail block)

		select 'Y' into l_exists
	        From   oe_item_orderability hdr
		where       hdr.generally_available='N'
	             and    hdr.org_id = l_operating_unit_id
	             and    hdr.enable_flag = 'Y'
		     and   (hdr.inventory_item_id = p_line_rec.inventory_item_id  or hdr.item_category_id = l_x_item_category_id )
		     and rownum = 1;

		return false;
	  Exception
		when no_data_found then
		return true;
	  END;
  End;

END IF;


	oe_debug_pub.add('Exiting OE_ITORD_UTIL.Validate_item_orderability',1);

Exception
	when others then
	OE_MSG_PUB.Add_Exc_Msg
         (
          G_PKG_NAME
           ,'Validate_item_orderability'
          );
End Validate_item_orderability;


-- Overloaded Validate_item_orderability
-- This will be called from HVOI OE_BULK_PROCESS_LINE.VALIDATE_ITEM_FIELDS (OEBLLINB.pls)

Function Validate_item_orderability ( p_org_id IN NUMBER,
				      p_line_id IN NUMBER,
				      p_header_id IN NUMBER,
				      p_inventory_item_id IN NUMBER,
				      p_sold_to_org_id IN NUMBER,
			              p_ship_to_org_id IN NUMBER,
				      p_salesrep_id IN NUMBER,
				      p_end_customer_id IN NUMBER,
				      p_invoice_to_org_id IN NUMBER,
				      p_deliver_to_org_id IN NUMBER )
Return BOOLEAN IS

l_x_item_category_id NUMBER;
l_x_customer_class_id NUMBER;
l_x_sales_channel_code VARCHAR2(30);
l_x_order_type_id NUMBER;
l_x_region_id_list VARCHAR2(32000);
l_x_customer_category_code Varchar2(30);

l_exists varchar2(1);
l_exclusion_rule_exists Varchar2(1);

begin


 l_x_item_category_id  := OE_ITORD_UTIL.get_item_category_id (p_inventory_item_id);
 l_x_customer_class_id := OE_ITORD_UTIL.get_customer_class_id(p_sold_to_org_id);
 l_x_region_id_list    := OE_ITORD_UTIL.get_region_ids(p_ship_to_org_id);
 l_x_customer_category_code := OE_ITORD_UTIL.get_customer_category_code (p_sold_to_org_id);
 l_x_order_type_id      := OE_ITORD_UTIL.get_order_type_id(p_header_id);
 l_x_sales_channel_code := OE_ITORD_UTIL.get_sales_channel_code(p_header_id);


 --Validation for Exclusion Rules

begin

	select 'Y' into l_exists
	From   oe_item_orderability hdr,
	       oe_item_orderability_rules  rules
	Where  hdr.orderability_id = rules.orderability_id
	and    hdr.generally_available='Y'
	and    hdr.org_id = p_org_id
	and    hdr.enable_flag = 'Y'
	and    rules.enable_flag = 'Y'
	and   ( hdr.inventory_item_id = p_inventory_item_id or hdr.item_category_id = l_x_item_category_id )
	and   (  rules.customer_id                =  p_sold_to_org_id
		or  rules.customer_class_id       = l_x_customer_class_id
		or  rules.customer_category_code = l_x_customer_category_code
		or  INSTR( l_x_region_id_list ,(','||to_char(rules.region_id)||',') ) <> 0
		or  rules.order_type_id           = l_x_order_type_id
		or  rules.ship_to_location_id     = p_ship_to_org_id
		or  rules.sales_channel_code      = l_x_sales_channel_code
		or  rules.sales_person_id         = p_salesrep_id
		or  rules.end_customer_id         = p_end_customer_id
		or  rules.bill_to_location_id     = p_invoice_to_org_id
		or  rules.deliver_to_location_id  = p_deliver_to_org_id
	       )
       and rownum = 1;

       l_exclusion_rule_exists := 'Y';
       return false;
Exception
	when others then
	l_exclusion_rule_exists := 'N';
End;

-- Validate Inclusion  Rules
IF l_exclusion_rule_exists = 'N' then

begin

	select 'Y' into l_exists
	From   oe_item_orderability hdr,
	       oe_item_orderability_rules  rules
	Where  hdr.orderability_id = rules.orderability_id
	and    hdr.generally_available='N'
	and    hdr.org_id = p_org_id
	and    hdr.enable_flag = 'Y'
	and    rules.enable_flag = 'Y'
	and   ( hdr.inventory_item_id = p_inventory_item_id or hdr.item_category_id = l_x_item_category_id )
	and   (  rules.customer_id               =  p_sold_to_org_id
		or  rules.customer_class_id      = l_x_customer_class_id
		or  rules.customer_category_code = l_x_customer_category_code
		or  INSTR( l_x_region_id_list ,(','||to_char(rules.region_id)||',') ) <> 0
		or  rules.order_type_id          = l_x_order_type_id
		or  rules.ship_to_location_id    = p_ship_to_org_id
		or  rules.sales_channel_code     = l_x_sales_channel_code
		or  rules.sales_person_id        = p_salesrep_id
		or  rules.end_customer_id        = p_end_customer_id
		or  rules.bill_to_location_id    = p_invoice_to_org_id
		or  rules.deliver_to_location_id = p_deliver_to_org_id
	       )
       and rownum = 1;

       return true;
 Exception
	when no_data_found then
	  begin
		select 'Y' into l_exists
	        From   oe_item_orderability hdr
		where       hdr.generally_available='N'
	             and    hdr.org_id = p_org_id
	             and    hdr.enable_flag = 'Y'
		     and   (hdr.inventory_item_id = p_inventory_item_id or hdr.item_category_id = l_x_item_category_id )
		     and rownum=1;

		return false;
	  Exception
		when no_data_found then
		return true;
	  END;


 End;

END IF;


	return true;


Exception
	when others then
	 OE_MSG_PUB.Add_Exc_Msg
         (
          G_PKG_NAME
           ,'Validate_item_orderability'
          );
End Validate_item_orderability;


PROCEDURE Insert_Row
      ( p_item_orderability_rec       IN  OE_ITORD_UTIL.Item_Orderability_Rec
      , x_return_status               OUT NOCOPY VARCHAR2
      )
   IS
   BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO OE_ITEM_ORDERABILITY
             (
              orderability_id,
              org_id,
              item_level,
              item_category_id,
              inventory_item_id,
              generally_available,
              enable_flag,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date
             )
      VALUES (
              p_item_orderability_rec.orderability_id,
              p_item_orderability_rec.org_id,
              p_item_orderability_rec.item_level,
              p_item_orderability_rec.item_category_id,
              p_item_orderability_rec.inventory_item_id,
              p_item_orderability_rec.generally_available,
              p_item_orderability_rec.enable_flag,
              p_item_orderability_rec.created_by,
              p_item_orderability_rec.creation_date,
	      --to_date(to_char(p_item_orderability_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
              p_item_orderability_rec.last_updated_by,
              p_item_orderability_rec.last_update_date
	      --to_date(to_char(p_item_orderability_rec.last_update_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')
             );

   EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      OE_MSG_PUB.Add_Exc_Msg
      (
       G_PKG_NAME
      ,'Insert_Row - OE_ITEM_ORDERABILITY'
      );

   END;

   PROCEDURE Update_Row
      ( p_item_orderability_rec       IN  OE_ITORD_UTIL.Item_Orderability_Rec
      , x_return_status               OUT NOCOPY VARCHAR2
      )
   IS
   BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      UPDATE OE_ITEM_ORDERABILITY
         SET item_level = p_item_orderability_rec.item_level,
             item_category_id = p_item_orderability_rec.item_category_id,
             inventory_item_id = p_item_orderability_rec.inventory_item_id,
             generally_available = p_item_orderability_rec.generally_available,
             enable_flag = p_item_orderability_rec.enable_flag,
             created_by = p_item_orderability_rec.created_by,
             creation_date = p_item_orderability_rec.creation_date ,
	     --creation_date = to_date(to_char(p_item_orderability_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
             last_updated_by = p_item_orderability_rec.last_updated_by,
             last_update_date = p_item_orderability_rec.last_update_date
	     --last_update_date = to_date(to_char(p_item_orderability_rec.last_update_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')
       WHERE orderability_id = p_item_orderability_rec.orderability_id;

   EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      OE_MSG_PUB.Add_Exc_Msg
      (
       G_PKG_NAME
      ,'Update_Row - OE_ITEM_ORDERABILITY'
      );

   END;


   PROCEDURE Insert_Row
      ( p_item_orderability_rules_rec IN  OE_ITORD_UTIL.Item_Orderability_Rules_Rec
      , x_return_status               OUT NOCOPY VARCHAR2
      , x_rowid                       OUT NOCOPY ROWID
      )
   IS
   BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      INSERT INTO OE_ITEM_ORDERABILITY_RULES
             (
              ORDERABILITY_ID,
              RULE_LEVEL,
              CUSTOMER_ID,
              CUSTOMER_CLASS_ID,
              CUSTOMER_CATEGORY_CODE,
              REGION_ID,
              ORDER_TYPE_ID,
              SHIP_TO_LOCATION_ID,
              SALES_CHANNEL_CODE,
              SALES_PERSON_ID,
              END_CUSTOMER_ID,
              BILL_TO_LOCATION_ID,
              DELIVER_TO_LOCATION_ID,
              ENABLE_FLAG,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              CONTEXT,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              ATTRIBUTE16,
              ATTRIBUTE17,
              ATTRIBUTE18,
              ATTRIBUTE19,
              ATTRIBUTE20
             )
      VALUES (
              p_item_orderability_rules_rec.ORDERABILITY_ID,
              p_item_orderability_rules_rec.RULE_LEVEL,
              p_item_orderability_rules_rec.CUSTOMER_ID,
              p_item_orderability_rules_rec.CUSTOMER_CLASS_ID,
              p_item_orderability_rules_rec.CUSTOMER_CATEGORY_CODE,
              p_item_orderability_rules_rec.REGION_ID,
              p_item_orderability_rules_rec.ORDER_TYPE_ID,
              p_item_orderability_rules_rec.SHIP_TO_LOCATION_ID,
              p_item_orderability_rules_rec.SALES_CHANNEL_CODE,
              p_item_orderability_rules_rec.SALES_PERSON_ID,
              p_item_orderability_rules_rec.END_CUSTOMER_ID,
              p_item_orderability_rules_rec.BILL_TO_LOCATION_ID,
              p_item_orderability_rules_rec.DELIVER_TO_LOCATION_ID,
              p_item_orderability_rules_rec.ENABLE_FLAG,
              p_item_orderability_rules_rec.CREATED_BY,
              p_item_orderability_rules_rec.creation_date,
	      --to_date(to_char(p_item_orderability_rules_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
              p_item_orderability_rules_rec.last_updated_by,
              p_item_orderability_rules_rec.last_update_date,
	      --to_date(to_char(p_item_orderability_rules_rec.last_update_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
              p_item_orderability_rules_rec.CONTEXT,
              p_item_orderability_rules_rec.ATTRIBUTE1,
              p_item_orderability_rules_rec.ATTRIBUTE2,
              p_item_orderability_rules_rec.ATTRIBUTE3,
              p_item_orderability_rules_rec.ATTRIBUTE4,
              p_item_orderability_rules_rec.ATTRIBUTE5,
              p_item_orderability_rules_rec.ATTRIBUTE6,
              p_item_orderability_rules_rec.ATTRIBUTE7,
              p_item_orderability_rules_rec.ATTRIBUTE8,
              p_item_orderability_rules_rec.ATTRIBUTE9,
              p_item_orderability_rules_rec.ATTRIBUTE10,
              p_item_orderability_rules_rec.ATTRIBUTE11,
              p_item_orderability_rules_rec.ATTRIBUTE12,
              p_item_orderability_rules_rec.ATTRIBUTE13,
              p_item_orderability_rules_rec.ATTRIBUTE14,
              p_item_orderability_rules_rec.ATTRIBUTE15,
              p_item_orderability_rules_rec.ATTRIBUTE16,
              p_item_orderability_rules_rec.ATTRIBUTE17,
              p_item_orderability_rules_rec.ATTRIBUTE18,
              p_item_orderability_rules_rec.ATTRIBUTE19,
              p_item_orderability_rules_rec.ATTRIBUTE20
             ) returning rowid into x_rowid ;
   EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      OE_MSG_PUB.Add_Exc_Msg
      (
       G_PKG_NAME
      ,'Insert_Row - OE_ITEM_ORDERABILITY_RULES'
      );

   END;

   PROCEDURE Update_Row
      ( p_item_orderability_rules_rec IN  OE_ITORD_UTIL.Item_Orderability_Rules_Rec
      , p_row_id                      IN ROWID
      , x_return_status               OUT NOCOPY VARCHAR2
      )
   IS
   BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      UPDATE OE_ITEM_ORDERABILITY_RULES
         SET RULE_LEVEL                =   p_item_orderability_rules_rec.RULE_LEVEL,
             CUSTOMER_ID               =   p_item_orderability_rules_rec.CUSTOMER_ID,
             CUSTOMER_CLASS_ID         =   p_item_orderability_rules_rec.CUSTOMER_CLASS_ID,
             CUSTOMER_CATEGORY_CODE    =   p_item_orderability_rules_rec.CUSTOMER_CATEGORY_CODE,
             REGION_ID                 =   p_item_orderability_rules_rec.REGION_ID,
             ORDER_TYPE_ID             =   p_item_orderability_rules_rec.ORDER_TYPE_ID,
             SHIP_TO_LOCATION_ID       =   p_item_orderability_rules_rec.SHIP_TO_LOCATION_ID,
             SALES_CHANNEL_CODE        =   p_item_orderability_rules_rec.SALES_CHANNEL_CODE,
             SALES_PERSON_ID           =   p_item_orderability_rules_rec.SALES_PERSON_ID,
             END_CUSTOMER_ID           =   p_item_orderability_rules_rec.END_CUSTOMER_ID,
             BILL_TO_LOCATION_ID       =   p_item_orderability_rules_rec.BILL_TO_LOCATION_ID,
             DELIVER_TO_LOCATION_ID    =   p_item_orderability_rules_rec.DELIVER_TO_LOCATION_ID,
             ENABLE_FLAG               =   p_item_orderability_rules_rec.ENABLE_FLAG,
             CREATED_BY                =   p_item_orderability_rules_rec.CREATED_BY,
             CREATION_DATE             =   p_item_orderability_rules_rec.creation_date,
	     --CREATION_DATE           =   to_date(to_char(p_item_orderability_rules_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
             LAST_UPDATED_BY           =   p_item_orderability_rules_rec.last_updated_by,
	     LAST_UPDATE_DATE          =   p_item_orderability_rules_rec.last_update_date,
	     --LAST_UPDATE_DATE          =   to_date(to_char(p_item_orderability_rules_rec.last_update_date,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
             CONTEXT                   =   p_item_orderability_rules_rec.CONTEXT,
             ATTRIBUTE1                =   p_item_orderability_rules_rec.ATTRIBUTE1,
             ATTRIBUTE2                =   p_item_orderability_rules_rec.ATTRIBUTE2,
             ATTRIBUTE3                =   p_item_orderability_rules_rec.ATTRIBUTE3,
             ATTRIBUTE4                =   p_item_orderability_rules_rec.ATTRIBUTE4,
             ATTRIBUTE5                =   p_item_orderability_rules_rec.ATTRIBUTE5,
             ATTRIBUTE6                =   p_item_orderability_rules_rec.ATTRIBUTE6,
             ATTRIBUTE7                =   p_item_orderability_rules_rec.ATTRIBUTE7,
             ATTRIBUTE8                =   p_item_orderability_rules_rec.ATTRIBUTE8,
             ATTRIBUTE9                =   p_item_orderability_rules_rec.ATTRIBUTE9,
             ATTRIBUTE10               =   p_item_orderability_rules_rec.ATTRIBUTE10,
             ATTRIBUTE11               =   p_item_orderability_rules_rec.ATTRIBUTE11,
             ATTRIBUTE12               =   p_item_orderability_rules_rec.ATTRIBUTE12,
             ATTRIBUTE13               =   p_item_orderability_rules_rec.ATTRIBUTE13,
             ATTRIBUTE14               =   p_item_orderability_rules_rec.ATTRIBUTE14,
             ATTRIBUTE15               =   p_item_orderability_rules_rec.ATTRIBUTE15,
             ATTRIBUTE16               =   p_item_orderability_rules_rec.ATTRIBUTE16,
             ATTRIBUTE17               =   p_item_orderability_rules_rec.ATTRIBUTE17,
             ATTRIBUTE18               =   p_item_orderability_rules_rec.ATTRIBUTE18,
             ATTRIBUTE19               =   p_item_orderability_rules_rec.ATTRIBUTE19,
             ATTRIBUTE20               =   p_item_orderability_rules_rec.ATTRIBUTE20
       WHERE ROWID = p_row_id;

   EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      OE_MSG_PUB.Add_Exc_Msg
      (
       G_PKG_NAME
      ,'Update_Row - OE_ITEM_ORDERABILITY_RULES'
      );

   END;


   FUNCTION Check_Duplicate_Rules (l_sql_stmt varchar2)
   RETURN BOOLEAN
   IS
   l_dup_count   number(1);
   BEGIN
      EXECUTE IMMEDIATE l_sql_stmt INTO l_dup_count;

      IF l_dup_count > 0
      THEN
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   END;


Procedure REFRESH_MATERIALIZED_VIEW
(
   ERRBUF         OUT NOCOPY VARCHAR2,
   RETCODE        OUT NOCOPY VARCHAR2
)
IS
BEGIN
    DBMS_MVIEW.REFRESH(list => 'OE_ITEMS_MV');

    RETCODE := 0;
END refresh_materialized_view;

FUNCTION GET_RULE_LEVEL_VALUE ( P_RULE_LEVEL varchar2
                              , P_RULE_LEVEL_VALUE varchar2
                              )
RETURN VARCHAR2
IS
l_rule_level_id NUMBER;
l_rule_level_value  varchar2(200);
BEGIN
      oe_debug_pub.add('Rule Level: '||P_RULE_LEVEL);
      oe_debug_pub.add('Rule Level Value: '||P_RULE_LEVEL_VALUE);

      IF p_rule_level IN('CUSTOMER','END_CUST')
      THEN

         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT party.party_name
           INTO l_rule_level_value
           FROM hz_parties party,
                hz_cust_accounts acct
          WHERE acct.party_id = party.party_id
            AND acct.cust_account_id = l_rule_level_id;

      ELSIF p_rule_level = 'CUST_CLASS'
      THEN
         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT cpc.name
           INTO l_rule_level_value
           FROM hz_cust_profile_classes cpc
          WHERE profile_class_id = l_rule_level_id;

      ELSIF p_rule_level = 'CUST_CATEGORY'
      THEN

         SELECT meaning
           INTO l_rule_level_value
           FROM ar_lookups
          WHERE lookup_type = 'CUSTOMER_CATEGORY'
            AND lookup_code = p_rule_level_value;

      ELSIF p_rule_level = 'REGIONS'
      THEN
          l_rule_level_id := TO_NUMBER(p_rule_level_value);

          SELECT country || ', '||state||', '||city||', '||ZONE|| ', '||postal_code_from || ' - '||postal_code_to region
            INTO l_rule_level_value
            FROM wsh_regions_v
           WHERE region_id = l_rule_level_id;

      ELSIF p_rule_level = 'ORDER_TYPE'
      THEN
         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT name
           INTO l_rule_level_value
           FROM oe_order_types_v
          WHERE order_type_id = l_rule_level_id;

      ELSIF p_rule_level = 'SALES_CHANNEL'
      THEN

         SELECT meaning
           INTO l_rule_level_value
           FROM oe_lookups
          WHERE lookup_type = 'SALES_CHANNEL'
            AND lookup_code = p_rule_level_value;

      ELSIF p_rule_level = 'SALES_REP'
      THEN

         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT name
           INTO l_rule_level_value
           FROM ra_salesreps
          WHERE salesrep_id = l_rule_level_id;

      ELSIF p_rule_level = 'SHIP_TO_LOC'
      THEN

         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT site.location
           INTO l_rule_level_value
           FROM hz_cust_site_uses_all site
          WHERE site.site_use_code = 'SHIP_TO'
            AND site.site_use_id= l_rule_level_id;

      ELSIF p_rule_level = 'BILL_TO_LOC'
      THEN

         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT site.location
           INTO l_rule_level_value
           FROM hz_cust_site_uses_all site
          WHERE site.site_use_code = 'BILL_TO'
            AND site.site_use_id= l_rule_level_id;

      ELSIF p_rule_level = 'DELIVER_TO_LOC'
      THEN

         l_rule_level_id := TO_NUMBER(p_rule_level_value);

         SELECT site.location
           INTO l_rule_level_value
           FROM hz_cust_site_uses_all site
          WHERE site.site_use_code = 'DELIVER_TO'
            AND site.site_use_id= l_rule_level_id;
      ELSE
         l_rule_level_value := 'Invalid rule passed';
      END IF;

   RETURN l_rule_level_value;

END;

--Returns hz_locations.location_id for the given site_use_id
FUNCTION Get_Shipto_Location_Id
(p_site_use_id          IN        NUMBER
)
RETURN NUMBER
IS
 l_ship_to_location_id     NUMBER;
BEGIN

  SELECT loc.location_id
    INTO l_ship_to_location_id
    FROM hz_cust_site_uses_all   site_uses,
         hz_cust_acct_sites_all  acct_site,
         hz_party_sites          party_site,
         hz_locations            loc
  WHERE site_uses.cust_acct_site_id =  acct_site.cust_acct_site_id
    AND acct_site.party_site_id     =  party_site.party_site_id
    AND loc.location_id             =  party_site.location_id
    AND site_uses.site_use_code     =  'SHIP_TO'
    AND site_uses.site_use_id       =  p_site_use_id;

  RETURN l_ship_to_location_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN NULL;
END Get_Shipto_Location_Id;


Function get_order_type_id (p_header_id IN NUMBER)
Return Number
is
l_order_type_id NUMBER;
begin
     IF  NOT OE_GLOBALS.Equal( p_header_id , G_HEADER_ID ) then
	select order_type_id
	into l_order_type_id
	from oe_order_headers_all
	where header_id = p_header_id;

	G_HEADER_ID   := p_header_id;
	G_TRX_TYPE_ID := l_order_type_id;

	 RETURN l_order_type_id;
    ELSE
         RETURN G_TRX_TYPE_ID;

     END IF;


 Exception
	when others then
	 RETURN NULL;
End get_order_type_id;


Function get_sales_channel_code (p_header_id IN NUMBER)
Return VARCHAR2
is
l_sales_channel_code VARCHAR2(30);
begin

  IF  NOT OE_GLOBALS.Equal( p_header_id , G_HDR_ID ) then
	select sales_channel_code
	into l_sales_channel_code
	from oe_order_headers_all
	where header_id = p_header_id;

	G_HDR_ID := p_header_id;
	G_SC_CODE := l_sales_channel_code;

	RETURN l_sales_channel_code;
  ELSE
        RETURN G_SC_CODE;
  END IF;

 Exception
	when others then
	 RETURN NULL;
End get_sales_channel_code;



END OE_ITORD_UTIL;

/
