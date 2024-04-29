--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_PRICE_LIST_LINE" AS
/* $Header: OEXLPRLB.pls 115.5 1999/11/15 20:39:56 pkm ship      $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Price_List_Line';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_PRICE_LIST_LINE_rec.price_list_line_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute1 Missing');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.


-- Added by
    if NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision , p_old_PRICE_LIST_LINE_rec.revision )
    then
          if OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id ,
			p_old_PRICE_LIST_LINE_rec.customer_item_id )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id ,
			p_old_PRICE_LIST_LINE_rec.inventory_item_id )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_price ,
			p_old_PRICE_LIST_LINE_rec.list_price )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.unit_code ,
			p_old_PRICE_LIST_LINE_rec.unit_code )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute1 ,
			p_old_PRICE_LIST_LINE_rec.pricing_attribute1 )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute2 ,
			p_old_PRICE_LIST_LINE_rec.pricing_attribute2 )
	   AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.start_date_active ,
			p_old_PRICE_LIST_LINE_rec.start_date_active )
           AND
          OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.end_date_active ,
			p_old_PRICE_LIST_LINE_rec.end_date_active )
	  THEN
	     	l_return_status := FND_API.G_RET_STS_ERROR;

	/*       	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      		THEN
       	  	FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
       	 	FND_MESSAGE.SET_TOKEN('REVISION','revision');
       		OE_MSG_PUB.Add;
    		x_return_status := l_return_status;

       		END IF;
	*/
	  ELSE
     -- attribute changed , revison changed
	     	l_return_status := FND_API.G_RET_STS_SUCCESS;
/*
	       	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      		THEN
       	  	FND_MESSAGE.SET_NAME('OE','Changed OE_ATTRIBUTE_REQUIRED');
       	 	FND_MESSAGE.SET_TOKEN('REVISION','revision');
       		OE_MSG_PUB.Add;
    		x_return_status := l_return_status;
		END IF;
*/
	  end if;

	ELSE
	--  revison codes are equal
	     	l_return_status := FND_API.G_RET_STS_SUCCESS;
/*
	       	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      		THEN
       	  	FND_MESSAGE.SET_NAME('OE','Equal OE_ATTRIBUTE_REQUIRED');
       	 	FND_MESSAGE.SET_TOKEN('REVISION','revision');
       		OE_MSG_PUB.Add;
		END IF;
*/
	end if;

        x_return_status := l_return_status;

	if l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	elsif l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	end if;

-- end added by

	Check_PLL_Duplicates( l_return_status,
			      p_PRICE_LIST_LINE_rec ,
			      p_old_PRICE_LIST_LINE_rec );

	if l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	elsif l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	end if;

    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;


-- Geresh Added to check dupliacates
Procedure Check_PLL_Duplicates
(    x_return_status		OUT  varchar2
,	p_PRICE_LIST_LINE_rec   IN   OE_Price_List_PUB.Price_List_Line_Rec_Type
,	p_old_PRICE_LIST_LINE_rec IN OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_Count NUMBER := 0;
l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
PLL_Duplicates EXCEPTION;
BEGIN

/*      if ( p_PRICE_LIST_LINE_rec.revision is NOT NULL )
       AND (p_PRICE_LIST_LINE_rec.customer_item_id is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.inventory_item_id is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.unit_code is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.start_date_active is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.end_date_active is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.pricing_attribute1 is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.pricing_attribute2 is NOT NULL )
       AND ( p_PRICE_LIST_LINE_rec.list_price is NOT NULL )
      then
	    and  list_price = p_PRICE_LIST_LINE_rec.list_price
*/

/*
	    SELECT count(*)
	    into   l_Count
	    from oe_price_list_lines
	    where price_list_id = p_PRICE_LIST_LINE_rec.price_list_id
	    and   unit_code = p_PRICE_LIST_LINE_rec.unit_code
	    and  pricing_attribute1 = p_PRICE_LIST_LINE_rec.pricing_attribute1
	    and  pricing_attribute2 = p_PRICE_LIST_LINE_rec.pricing_attribute2
	    and (
		( p_PRICE_LIST_LINE_rec.start_date_active between
			start_date_active and end_date_active)
		OR
		(p_PRICE_LIST_LINE_rec.end_date_active  between
			start_date_active and end_date_active ));



	   if l_Count <> 0  then
		l_return_status := FND_API.G_RET_STS_ERROR;
	       	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      		THEN
       	  	FND_MESSAGE.SET_NAME('OE','ATTRIBUTE_REQUIRED');
       	 	FND_MESSAGE.SET_TOKEN('REVISION','revision');
       		OE_MSG_PUB.Add;
		END IF;
		RAISE PLL_DUPLICATES;
	   end if;

*/

NULL;

/*
      end if;
*/

      x_return_status := l_return_status ;


EXCEPTION
	WHEN PLL_DUPLICATES OR NO_DATA_FOUND then
            x_return_status := l_return_status ;

END Check_PLL_Duplicates;



--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
)
IS
l_primary_exists BOOLEAN;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PRICE_LIST_LINE attributes

    IF  p_PRICE_LIST_LINE_rec.comments IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.comments <>
            p_old_PRICE_LIST_LINE_rec.comments OR
            p_old_PRICE_LIST_LINE_rec.comments IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Comments(p_PRICE_LIST_LINE_rec.comments) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_PRICE_LIST_LINE_rec.created_by IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.created_by <>
            p_old_PRICE_LIST_LINE_rec.created_by OR
            p_old_PRICE_LIST_LINE_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Created_By(p_PRICE_LIST_LINE_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.creation_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.creation_date <>
            p_old_PRICE_LIST_LINE_rec.creation_date OR
            p_old_PRICE_LIST_LINE_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Creation_Date(p_PRICE_LIST_LINE_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.customer_item_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.customer_item_id <>
            p_old_PRICE_LIST_LINE_rec.customer_item_id OR
            p_old_PRICE_LIST_LINE_rec.customer_item_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Customer_Item(p_PRICE_LIST_LINE_rec.customer_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.end_date_active IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.end_date_active <>
            p_old_PRICE_LIST_LINE_rec.end_date_active OR
            p_old_PRICE_LIST_LINE_rec.end_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.End_Date_Active(p_Price_List_Line_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

         ELSIF NOT OE_Validate_Attr.Start_Date_End_Date(
                       p_Price_List_Line_rec.start_date_active,
                       p_Price_List_Line_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.inventory_item_id <>
            p_old_PRICE_LIST_LINE_rec.inventory_item_id OR
            p_old_PRICE_LIST_LINE_rec.inventory_item_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Inventory_Item(p_PRICE_LIST_LINE_rec.inventory_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_updated_by IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_updated_by <>
            p_old_PRICE_LIST_LINE_rec.last_updated_by OR
            p_old_PRICE_LIST_LINE_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Updated_By(p_PRICE_LIST_LINE_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_update_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_update_date <>
            p_old_PRICE_LIST_LINE_rec.last_update_date OR
            p_old_PRICE_LIST_LINE_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Date(p_PRICE_LIST_LINE_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_update_login IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_update_login <>
            p_old_PRICE_LIST_LINE_rec.last_update_login OR
            p_old_PRICE_LIST_LINE_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Login(p_PRICE_LIST_LINE_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_price IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_price <>
            p_old_PRICE_LIST_LINE_rec.list_price OR
            p_old_PRICE_LIST_LINE_rec.list_price IS NULL )
    THEN
        IF NOT OE_Validate_Attr.List_Price(p_PRICE_LIST_LINE_rec.list_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.method_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.method_code <>
            p_old_PRICE_LIST_LINE_rec.method_code OR
            p_old_PRICE_LIST_LINE_rec.method_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Method(p_PRICE_LIST_LINE_rec.method_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.price_list_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.price_list_id <>
            p_old_PRICE_LIST_LINE_rec.price_list_id OR
            p_old_PRICE_LIST_LINE_rec.price_list_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price_List(p_PRICE_LIST_LINE_rec.price_list_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.price_list_line_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.price_list_line_id <>
            p_old_PRICE_LIST_LINE_rec.price_list_line_id OR
            p_old_PRICE_LIST_LINE_rec.price_list_line_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price_List_Line(p_PRICE_LIST_LINE_rec.price_list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute1 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute1 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute1 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute1 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute1(p_PRICE_LIST_LINE_rec.pricing_attribute1) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute11 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute11 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute11 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute11 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute11(p_PRICE_LIST_LINE_rec.pricing_attribute11) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute12 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute12 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute12 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute12 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute12(p_PRICE_LIST_LINE_rec.pricing_attribute12) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute13 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute13 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute13 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute13 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute13(p_PRICE_LIST_LINE_rec.pricing_attribute13) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute14 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute14 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute14 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute14 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute14(p_PRICE_LIST_LINE_rec.pricing_attribute14) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute15 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute15 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute15 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute15 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute15(p_PRICE_LIST_LINE_rec.pricing_attribute15) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_PRICE_LIST_LINE_rec.pricing_attribute2 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute2 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute2 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute2 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute2(p_PRICE_LIST_LINE_rec.pricing_attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute3 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute3 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute3 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute3 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute3(p_PRICE_LIST_LINE_rec.pricing_attribute3) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute4 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute4 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute4 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute4 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute4(p_PRICE_LIST_LINE_rec.pricing_attribute4) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute5 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute5 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute5 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute5 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute5(p_PRICE_LIST_LINE_rec.pricing_attribute5) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_PRICE_LIST_LINE_rec.pricing_attribute6 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute6 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute6 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute6 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute6(p_PRICE_LIST_LINE_rec.pricing_attribute6) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute7 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute7 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute7 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute7 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute7(p_PRICE_LIST_LINE_rec.pricing_attribute7) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute8 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute8 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute8 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute8 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute8(p_PRICE_LIST_LINE_rec.pricing_attribute8) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_attribute9 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute9 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute9 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute9 IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute9(p_PRICE_LIST_LINE_rec.pricing_attribute9) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_context <>
            p_old_PRICE_LIST_LINE_rec.pricing_context OR
            p_old_PRICE_LIST_LINE_rec.pricing_context IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Context(p_PRICE_LIST_LINE_rec.pricing_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.pricing_rule_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_rule_id <>
            p_old_PRICE_LIST_LINE_rec.pricing_rule_id OR
            p_old_PRICE_LIST_LINE_rec.pricing_rule_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Pricing_Rule(p_PRICE_LIST_LINE_rec.pricing_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.primary IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.primary <>
            p_old_PRICE_LIST_LINE_rec.primary OR
            p_old_PRICE_LIST_LINE_rec.primary IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Primary(p_PRICE_LIST_LINE_rec.primary) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_application_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_application_id <>
            p_old_PRICE_LIST_LINE_rec.program_application_id OR
            p_old_PRICE_LIST_LINE_rec.program_application_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program_Application(p_PRICE_LIST_LINE_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_id <>
            p_old_PRICE_LIST_LINE_rec.program_id OR
            p_old_PRICE_LIST_LINE_rec.program_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program(p_PRICE_LIST_LINE_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_update_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_update_date <>
            p_old_PRICE_LIST_LINE_rec.program_update_date OR
            p_old_PRICE_LIST_LINE_rec.program_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program_Update_Date(p_PRICE_LIST_LINE_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.reprice_flag <>
            p_old_PRICE_LIST_LINE_rec.reprice_flag OR
            p_old_PRICE_LIST_LINE_rec.reprice_flag IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Reprice(p_PRICE_LIST_LINE_rec.reprice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.request_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.request_id <>
            p_old_PRICE_LIST_LINE_rec.request_id OR
            p_old_PRICE_LIST_LINE_rec.request_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Request(p_PRICE_LIST_LINE_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision <>
            p_old_PRICE_LIST_LINE_rec.revision OR
            p_old_PRICE_LIST_LINE_rec.revision IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision(p_PRICE_LIST_LINE_rec.revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision_date <>
            p_old_PRICE_LIST_LINE_rec.revision_date OR
            p_old_PRICE_LIST_LINE_rec.revision_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision_Date(p_PRICE_LIST_LINE_rec.revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision_reason_code <>
            p_old_PRICE_LIST_LINE_rec.revision_reason_code OR
            p_old_PRICE_LIST_LINE_rec.revision_reason_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision_Reason(p_PRICE_LIST_LINE_rec.revision_reason_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.start_date_active IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.start_date_active <>
            p_old_PRICE_LIST_LINE_rec.start_date_active OR
            p_old_PRICE_LIST_LINE_rec.start_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Start_Date_Active(p_PRICE_LIST_LINE_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF NOT OE_Validate_Attr.Start_Date_End_Date(
                       p_Price_List_Line_rec.start_date_active,
                       p_Price_List_Line_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.unit_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.unit_code <>
            p_old_PRICE_LIST_LINE_rec.unit_code OR
            p_old_PRICE_LIST_LINE_rec.unit_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Unit(p_PRICE_LIST_LINE_rec.unit_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_line_type_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_line_type_code <>
            p_old_PRICE_LIST_LINE_rec.list_line_type_code OR
            p_old_PRICE_LIST_LINE_rec.list_line_type_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.List_Line_Type(p_PRICE_LIST_LINE_rec.list_line_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  (p_PRICE_LIST_LINE_rec.attribute1 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute1 <>
            p_old_PRICE_LIST_LINE_rec.attribute1 OR
            p_old_PRICE_LIST_LINE_rec.attribute1 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute10 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute10 <>
            p_old_PRICE_LIST_LINE_rec.attribute10 OR
            p_old_PRICE_LIST_LINE_rec.attribute10 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute11 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute11 <>
            p_old_PRICE_LIST_LINE_rec.attribute11 OR
            p_old_PRICE_LIST_LINE_rec.attribute11 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute12 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute12 <>
            p_old_PRICE_LIST_LINE_rec.attribute12 OR
            p_old_PRICE_LIST_LINE_rec.attribute12 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute13 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute13 <>
            p_old_PRICE_LIST_LINE_rec.attribute13 OR
            p_old_PRICE_LIST_LINE_rec.attribute13 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute14 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute14 <>
            p_old_PRICE_LIST_LINE_rec.attribute14 OR
            p_old_PRICE_LIST_LINE_rec.attribute14 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute15 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute15 <>
            p_old_PRICE_LIST_LINE_rec.attribute15 OR
            p_old_PRICE_LIST_LINE_rec.attribute15 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute2 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute2 <>
            p_old_PRICE_LIST_LINE_rec.attribute2 OR
            p_old_PRICE_LIST_LINE_rec.attribute2 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute3 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute3 <>
            p_old_PRICE_LIST_LINE_rec.attribute3 OR
            p_old_PRICE_LIST_LINE_rec.attribute3 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute4 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute4 <>
            p_old_PRICE_LIST_LINE_rec.attribute4 OR
            p_old_PRICE_LIST_LINE_rec.attribute4 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute5 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute5 <>
            p_old_PRICE_LIST_LINE_rec.attribute5 OR
            p_old_PRICE_LIST_LINE_rec.attribute5 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute6 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute6 <>
            p_old_PRICE_LIST_LINE_rec.attribute6 OR
            p_old_PRICE_LIST_LINE_rec.attribute6 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute7 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute7 <>
            p_old_PRICE_LIST_LINE_rec.attribute7 OR
            p_old_PRICE_LIST_LINE_rec.attribute7 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute8 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute8 <>
            p_old_PRICE_LIST_LINE_rec.attribute8 OR
            p_old_PRICE_LIST_LINE_rec.attribute8 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute9 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute9 <>
            p_old_PRICE_LIST_LINE_rec.attribute9 OR
            p_old_PRICE_LIST_LINE_rec.attribute9 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.context <>
            p_old_PRICE_LIST_LINE_rec.context OR
            p_old_PRICE_LIST_LINE_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out
 NULL;
/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT OE_Validate_Attr.Desc_Flex( 'SO_PRICE_LIST_LINES' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF  (p_PRICE_LIST_LINE_rec.pricing_attribute1 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute1 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute1 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute1 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute10 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute10 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute10 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute10 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute2 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute2 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute2 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute2 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute3 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute3 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute3 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute3 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute4 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute4 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute4 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute4 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute5 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute5 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute5 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute5 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute6 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute6 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute6 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute6 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute7 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute7 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute7 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute7 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute8 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute8 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute8 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute8 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_attribute9 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_attribute9 <>
            p_old_PRICE_LIST_LINE_rec.pricing_attribute9 OR
            p_old_PRICE_LIST_LINE_rec.pricing_attribute9 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.pricing_context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.pricing_context <>
            p_old_PRICE_LIST_LINE_rec.pricing_context OR
            p_old_PRICE_LIST_LINE_rec.pricing_context IS NULL ))
    THEN

    --  These calls are temporarily commented out
NULL;
/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE1'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE10'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE2'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE3'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE4'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE5'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE6'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE7'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE8'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_ATTRIBUTE9'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'PRICING_CONTEXT'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.pricing_context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT OE_Validate_Attr.Desc_Flex( 'PRICING_ATTRIBUTES' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF  p_Price_List_Line_rec.primary IS NOT NULL AND
        (   p_Price_List_Line_rec.primary <>
            p_old_Price_List_Line_rec.primary OR
            p_old_Price_List_Line_rec.primary IS NULL )
    THEN

-- Passing start date and end date to primary exists function
-- Geresh
       l_primary_exists :=
                 OE_VALIDATE_ATTR.PRIMARY_EXISTS(
                 p_PRICE_LIST_LINE_rec.price_list_id,
                 p_Price_List_Line_rec.inventory_item_id,
                 p_Price_List_Line_rec.customer_item_id,
                 p_Price_List_Line_rec.pricing_attribute1,
                 p_Price_List_Line_rec.pricing_attribute2,
                 p_Price_List_Line_rec.pricing_attribute3,
                 p_Price_List_Line_rec.pricing_attribute4,
                 p_Price_List_Line_rec.pricing_attribute5,
                 p_Price_List_Line_rec.pricing_attribute6,
                 p_Price_List_Line_rec.pricing_attribute7,
                 p_Price_List_Line_rec.pricing_attribute8,
                 p_Price_List_Line_rec.pricing_attribute9,
                 p_Price_List_Line_rec.pricing_attribute10,
                 p_Price_List_Line_rec.pricing_attribute11,
                 p_Price_List_Line_rec.pricing_attribute12,
                 p_Price_List_Line_rec.pricing_attribute13,
                 p_Price_List_Line_rec.pricing_attribute14,
                 p_Price_List_Line_rec.pricing_attribute15,
		 p_Price_List_Line_rec.start_date_active,
		 p_Price_List_Line_rec.end_date_active );


      IF p_Price_List_Line_rec.primary = 'Y' THEN

         IF l_primary_exists THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

      ELSIF p_Price_List_Line_rec.primary = 'N' THEN

         IF (NOT l_primary_exists) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

      END IF;


/*
        ELSIF NOT OE_Validate_Attr.PRIMARY(p_Price_List_Line_rec.primary) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
*/

    END IF;



    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END OE_Validate_Price_List_Line;

/
