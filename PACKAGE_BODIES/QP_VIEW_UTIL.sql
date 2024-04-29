--------------------------------------------------------
--  DDL for Package Body QP_VIEW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VIEW_UTIL" AS
/* $Header: QPXVVUTB.pls 120.1 2005/06/16 02:10:46 appldev  $ */

    G_QUALIFIER_ATTRIBUTE6         CONSTANT NUMBER       := 1004; /*'Customer PONumber';*/
    G_NEW_QUALIFIER_ATTRIBUTE6     CONSTANT NUMBER       := 1053; /*'Customer PONumber';*/
    G_QUALIFIER_ATTRIBUTE7         CONSTANT NUMBER       := 1007; /*'Order Type';*/
    G_NEW_QUALIFIER_ATTRIBUTE7     CONSTANT NUMBER       := 1325; /*'Order Type';*/
    G_QUALIFIER_ATTRIBUTE8         CONSTANT NUMBER       := 1005; /*'Agreement Type';*/
    G_NEW_QUALIFIER_ATTRIBUTE8     CONSTANT NUMBER       := 1468; /*'Agreement Type';*/
    G_QUALIFIER_ATTRIBUTE9         CONSTANT NUMBER       := 1006; /*'Agreement Name';*/
    G_NEW_QUALIFIER_ATTRIBUTE9     CONSTANT NUMBER       := 1467; /*'Agreement Name';*/
    G_PRODUCT_ATTRIBUTE1           CONSTANT NUMBER       := 1001; /*'Item Number';*/
    G_NEW_PRODUCT_ATTRIBUTE1       CONSTANT NUMBER       := 1208; /*'Item Number';*/
    G_PRODUCT_ATTRIBUTE2           CONSTANT NUMBER       := 1045; /*'Item Catego
    ry';*/


 FUNCTION Get_Entity_Id( p_list_line_id IN NUMBER
				    ) RETURN VARCHAR2 IS

 x_return VARCHAR2(30) :=FND_API.G_MISS_CHAR;

   v_qualifier_attribute         QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_order_type_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_customer_po_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_agreement_type_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_agreement_name_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   v_qualifier_context           QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_order_type_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_customer_po_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_agreement_type_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_agreement_name_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;

   v_product_attribute           QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
   l_item_no_attribute             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
   l_item_category_attribute             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
   v_product_attribute_context   QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;
   l_item_no_context             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;
   l_item_category_context             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;


 BEGIN

    QP_UTIL.Get_Context_Attribute(1007,l_order_type_context,l_order_type_attribute);
    QP_UTIL.Get_Context_Attribute(1004,l_customer_po_context,l_customer_po_attribute);
    QP_UTIL.Get_Context_Attribute(1005,l_agreement_type_context,l_agreement_type_attribute);
    QP_UTIL.Get_Context_Attribute(1006,l_agreement_name_context,l_agreement_name_attribute);


    BEGIN

    select QUALIFIER_CONTEXT, QUALIFIER_ATTRIBUTE
    into   v_qualifier_context, v_qualifier_attribute
    from   QP_QUALIFIERS
    where  LIST_LINE_ID = p_list_line_id
    and    ( (QUALIFIER_CONTEXT = l_order_type_context
    and    QUALIFIER_ATTRIBUTE = l_order_type_attribute)
    or     (QUALIFIER_CONTEXT = l_customer_po_context
    and    QUALIFIER_ATTRIBUTE =  l_customer_po_attribute)
    or     (QUALIFIER_CONTEXT = l_agreement_type_context
    and    QUALIFIER_ATTRIBUTE =  l_agreement_type_attribute)
    or     (QUALIFIER_CONTEXT = l_agreement_name_context
    and    QUALIFIER_ATTRIBUTE = l_agreement_name_attribute));


       x_return := Get_Attribute_Code(v_qualifier_context,v_qualifier_attribute);
	  RETURN x_return;


    EXCEPTION
    when no_data_found then

      QP_UTIL.Get_Context_Attribute(1001,l_item_no_context,l_item_no_attribute);
      QP_UTIL.Get_Context_Attribute(1045,l_item_category_context,l_item_category_attribute);

	  BEGIN

	  select PRODUCT_ATTRIBUTE_CONTEXT, PRODUCT_ATTRIBUTE
	  into   v_product_attribute_context, v_product_attribute
	  from   QP_PRICING_ATTRIBUTES
	  where  LIST_LINE_ID = p_list_line_id
	  and    ( (PRODUCT_ATTRIBUTE_CONTEXT = l_item_no_context
	  and     PRODUCT_ATTRIBUTE = l_item_no_attribute)
	  or     (PRODUCT_ATTRIBUTE_CONTEXT = l_item_category_context
	  and     PRODUCT_ATTRIBUTE = l_item_category_attribute));

       x_return := Get_Attribute_Code(v_product_attribute_context,v_product_attribute);
	  RETURN x_return;

       EXCEPTION
       when no_data_found then
       x_return := 0;
       RETURN x_return;


       END;

    END;


 END Get_Entity_Id;


 FUNCTION Get_Entity_Value( p_list_line_id IN NUMBER
				      ) RETURN VARCHAR2 IS

 x_return VARCHAR2(240) :=FND_API.G_MISS_CHAR;

   l_order_type_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_customer_po_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_agreement_type_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_agreement_name_attribute        QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
   l_order_type_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_customer_po_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_agreement_type_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_agreement_name_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;

   l_item_no_attribute             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
   l_item_category_attribute             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
   l_item_no_context             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;
   l_item_category_context             QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;

   v_qualifier_attr_value           QP_QUALIFIERS.QUALIFIER_ATTR_VALUE%TYPE;
   v_product_attr_value             QP_PRICING_ATTRIBUTES.PRODUCT_ATTR_VALUE%TYPE;


 BEGIN

    QP_UTIL.Get_Context_Attribute(1007,l_order_type_context,l_order_type_attribute);
    QP_UTIL.Get_Context_Attribute(1004,l_customer_po_context,l_customer_po_attribute);
    QP_UTIL.Get_Context_Attribute(1005,l_agreement_type_context,l_agreement_type_attribute);
    QP_UTIL.Get_Context_Attribute(1006,l_agreement_name_context,l_agreement_name_attribute);


    select QUALIFIER_ATTR_VALUE
    into   v_qualifier_attr_value
    from   QP_QUALIFIERS
    where  LIST_LINE_ID = p_list_line_id
    and    ( (QUALIFIER_CONTEXT = l_order_type_context
    and    QUALIFIER_ATTRIBUTE = l_order_type_attribute)
    or     (QUALIFIER_CONTEXT = l_customer_po_context
    and    QUALIFIER_ATTRIBUTE =  l_customer_po_attribute)
    or     (QUALIFIER_CONTEXT = l_agreement_type_context
    and    QUALIFIER_ATTRIBUTE =  l_agreement_type_attribute)
    or     (QUALIFIER_CONTEXT = l_agreement_name_context
    and    QUALIFIER_ATTRIBUTE = l_agreement_name_attribute));


    if v_qualifier_attr_value is null then

      QP_UTIL.Get_Context_Attribute(1001,l_item_no_context,l_item_no_attribute);
      QP_UTIL.Get_Context_Attribute(1045,l_item_category_context,l_item_category_attribute);


	  select PRODUCT_ATTR_VALUE
	  into   v_product_attr_value
	  from   QP_PRICING_ATTRIBUTES
	  where  LIST_LINE_ID = p_list_line_id
	  and    ( (PRODUCT_ATTRIBUTE_CONTEXT = l_item_no_context
	  and     PRODUCT_ATTRIBUTE = l_item_no_attribute)
	  or     (PRODUCT_ATTRIBUTE_CONTEXT = l_item_category_context
	  and     PRODUCT_ATTRIBUTE = l_item_category_attribute));

       x_return := v_product_attr_value;
	  RETURN x_return;

    else

       x_return := v_qualifier_attr_value;
	  RETURN x_return;

    end if;


exception
when no_data_found then
      QP_UTIL.Get_Context_Attribute(1001,l_item_no_context,l_item_no_attribute);
      QP_UTIL.Get_Context_Attribute(1045,l_item_category_context,l_item_category_attribute);


	  select PRODUCT_ATTR_VALUE
	  into   v_product_attr_value
	  from   QP_PRICING_ATTRIBUTES
	  where  LIST_LINE_ID = p_list_line_id
	  and    ( (PRODUCT_ATTRIBUTE_CONTEXT = l_item_no_context
	  and     PRODUCT_ATTRIBUTE = l_item_no_attribute)
	  or     (PRODUCT_ATTRIBUTE_CONTEXT = l_item_category_context
	  and     PRODUCT_ATTRIBUTE = l_item_category_attribute));

       x_return := v_product_attr_value;
	  RETURN x_return;
 END Get_Entity_Value;

FUNCTION Are_There_Breaks( p_list_line_id       IN NUMBER
    			          )   RETURN VARCHAR2 IS

 x_return VARCHAR2(1) :=FND_API.G_MISS_CHAR;

   v_pricing_attr_value_from     QP_PRICING_ATTRIBUTES.PRICING_ATTR_VALUE_FROM%TYPE;
   v_pricing_attr_value_to       QP_PRICING_ATTRIBUTES.PRICING_ATTR_VALUE_TO%TYPE;


 BEGIN

select 'X'  into v_pricing_attr_value_to from qp_pricing_attributes
where  list_line_id = p_list_line_id and pricing_attr_value_to is not null;

--    select   X
--   PRICING_ATTR_VALUE_TO
--    into    v_pricing_attr_value_to
--    from   QP_PRICING_ATTRIBUTES
 --   where  LIST_LINE_ID = p_list_line_id;


	  x_return := 'Y';
	  RETURN x_return;


exception
when no_data_found then
	  x_return := 'N';
	  RETURN x_return;

 END Are_There_Breaks;

FUNCTION Get_Price_List_Attribute RETURN VARCHAR2 IS

 x_return VARCHAR2(30) :=FND_API.G_MISS_CHAR;

   l_price_list_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_price_list_attribute      QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;


 BEGIN

    QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID',l_price_list_context,l_price_list_attribute);

x_return:= l_price_list_attribute;

return x_return;

END Get_Price_List_Attribute;

FUNCTION Get_Price_List_Context  RETURN VARCHAR2 IS

 x_return VARCHAR2(30) :=FND_API.G_MISS_CHAR;

   l_price_list_context        QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
   l_price_list_attribute      QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;


 BEGIN

    QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID',l_price_list_context,l_price_list_attribute);

x_return:= l_price_list_context;

return x_return;

END Get_Price_List_Context;

FUNCTION Get_Parent_Discount_Line_Id( p_list_line_id  IN NUMBER
                                     )  RETURN NUMBER IS

 x_return NUMBER :=FND_API.G_MISS_NUM;

 BEGIN

    select MIN(qpa.LIST_LINE_ID)
    into   x_return
    from   QP_PRICING_ATTRIBUTES qpa
    where  ATTRIBUTE_GROUPING_NO in ( select qpb.ATTRIBUTE_GROUPING_NO
					             from   QP_PRICING_ATTRIBUTES qpb
					             where  qpb.LIST_LINE_ID = p_list_line_id) ;

    RETURN x_return;

 END Get_Parent_Discount_Line_Id;

FUNCTION Get_Attribute_Code(p_context IN VARCHAR2,
			              p_attribute_name IN VARCHAR2
     		                   )  RETURN VARCHAR2 IS

 x_return VARCHAR2(240)  :=FND_API.G_MISS_CHAR;


 BEGIN

     --Agreement Name
     IF  p_context = 'CUSTOMER' and p_attribute_name = 'QUALIFIER_ATTRIBUTE7'then
	    x_return := '1467';
	    RETURN x_return;

     --Agreement Type
     ELSIF  p_context = 'CUSTOMER' and p_attribute_name = 'QUALIFIER_ATTRIBUTE8'then
	    x_return := '1468';
	    RETURN x_return;

     -- Order Type
     ELSIF  p_context = 'ORDER' and p_attribute_name = 'QUALIFIER_ATTRIBUTE9'then
	    x_return := '1325';
	    RETURN x_return;

	-- Customer PO
     ELSIF  p_context = 'ORDER' and p_attribute_name = 'QUALIFIER_ATTRIBUTE12'then
	    x_return := '1053';
	    RETURN x_return;

-------Pricing Attributes
     -- Item Number
     ELSIF  p_context = 'ITEM' and p_attribute_name = 'PRICING_ATTRIBUTE1'then
	    x_return := '1208';
	    RETURN x_return;

     -- Item Category
     ELSIF  p_context = 'ITEM' and p_attribute_name = 'PRICING_ATTRIBUTE2'then
	    x_return := '1045';
	    RETURN x_return;

     -- Units
     ELSIF  p_context = 'VOLUME' and p_attribute_name = 'PRICING_ATTRIBUTE10'then  --Changed for 2159318
     --ELSIF  p_context = 'VOLUME' and p_attribute_name = 'PRICING_ATTRIBUTE3'then
	    x_return := 'UNITS';
	    RETURN x_return;

/* Added for 2159318 */

     ELSIF  p_context = 'VOLUME' and p_attribute_name = 'PRICING_ATTRIBUTE12'then
            x_return := 'DOLLARS';
            RETURN x_return;



/* Commented out for 2159318
     -- Amount
     ELSIF  p_context = 'LINEAMT' and p_attribute_name = 'PRICING_ATTRIBUTE4'then
	    x_return := 'DOLLARS';
	    RETURN x_return;
*/

     END IF;

 END Get_Attribute_Code;

  PROCEDURE Get_Context_Attributes(   p_entity_id              NUMBER,
						        x_context           OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
						  	   x_attribute         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
						  	   x_product_flag      OUT NOCOPY /* file.sql.39 change */  BOOLEAN,
						  	   x_qualifier_flag    OUT NOCOPY /* file.sql.39 change */  BOOLEAN) AS
  BEGIN
	-- Init the variables to null

			x_context           := NULL;
			x_attribute         := NULL;

	IF (p_entity_id = G_PRODUCT_ATTRIBUTE1 OR p_entity_id = G_NEW_PRODUCT_ATTRIBUTE1) THEN
	  -- Get the attribute and context for item
	  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := TRUE;
     	   x_qualifier_flag := FALSE;
	ELSIF (p_entity_id = G_PRODUCT_ATTRIBUTE2) THEN
    	  -- Get the attribute and context for item category
	  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := TRUE;
		   x_qualifier_flag := FALSE;
	ELSIF (p_entity_id = G_QUALIFIER_ATTRIBUTE6  OR p_entity_id = G_NEW_QUALIFIER_ATTRIBUTE6) THEN
	 -- Get the attribute and context for customer po
	  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := FALSE;
		   x_qualifier_flag := TRUE;
	-- For creating record in qp_pricing_attributes table with Units or Dollars for these qualifiers
     ELSIF (p_entity_id = G_QUALIFIER_ATTRIBUTE7  OR p_entity_id = G_NEW_QUALIFIER_ATTRIBUTE7) THEN
            -- Get the attribute and context for order type
		  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := FALSE;
		   x_qualifier_flag := TRUE;
    -- For creating record in qp_pricing_attributes table with Units or Dollars for these qualifiers
    	ELSIF (p_entity_id = G_QUALIFIER_ATTRIBUTE8  OR p_entity_id = G_NEW_QUALIFIER_ATTRIBUTE8) THEN
	  -- Get the attribute and context for agreement type
		  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := FALSE;
		   x_qualifier_flag := TRUE;
	-- For creating record in qp_pricing_attributes table with Units or Dollars for these qualifiers
    	ELSIF (p_entity_id = G_QUALIFIER_ATTRIBUTE9  OR p_entity_id = G_NEW_QUALIFIER_ATTRIBUTE9) THEN
	  -- Get the attribute and context for agreement name
		  QP_UTIL.get_context_attribute(p_entity_id,x_context,x_attribute);
		   x_product_flag := FALSE;
             x_qualifier_flag := TRUE;
	--   For creating record in qp_pricing_ attributes table with Units or Dollars for these qualifiers
	ELSE
		   x_product_flag := FALSE;
		   x_qualifier_flag := FALSE;
     END IF;
																END Get_Context_Attributes;




END QP_VIEW_UTIL;

/
