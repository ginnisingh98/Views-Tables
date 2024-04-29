--------------------------------------------------------
--  DDL for Package Body OE_CNCL_VALIDATE_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_VALIDATE_LINE_SCREDIT" AS
/* $Header: OEXVCLCB.pls 120.0 2005/05/31 23:39:23 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Validate_Line_Scredit';

Function Duplicate_Salescredit
(p_salesrep_id          IN Number
,p_sales_credit_type_id IN NUMBER
,p_line_id              IN NUMBER
,p_sales_credit_id      IN NUMBER
) RETURN BOOLEAN IS
Cursor C_Dup_Salescredit(p_salesrep_id          NUMBER
                        ,p_sales_credit_type_id NUMBER
                        ,p_line_id              NUMBER
                        ,p_sales_credit_id      NUMBER) IS
    SELECT 'DUPLICATE'
    FROM  oe_sales_credits
    WHERE line_id = p_line_id
    AND   salesrep_id = p_salesrep_id
    AND   sales_credit_type_id  = p_sales_credit_type_id
    AND   sales_credit_id <> nvl(p_sales_credit_id,-5);
l_dummy varchar2(30);
BEGIN
  OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
  OPEN C_Dup_Salescredit(p_salesrep_id
                        ,p_sales_credit_type_id
                        ,p_line_id
                        ,p_sales_credit_id);
  FETCH C_Dup_Salescredit INTO l_dummy;
  CLOSE C_Dup_Salescredit;
  IF l_dummy =  'DUPLICATE' THEN
        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_LINE_CREDIT');
            oe_msg_pub.add;

        END IF;
      OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
      Return TRUE;
  ELSE
      OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
     Return FALSE;
  END IF;
END Duplicate_Salescredit;


--  Procedure Entity

PROCEDURE Entity
(   x_return_status               OUT NOCOPY VARCHAR2  /* file.sql.39 change */
,   p_Line_Scredit_rec            IN  OE_Order_PUB.Line_Scredit_Rec_Type
)

IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
   OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE_SCREDIT.Entity',1);

    --  Check required attributes.

/*    IF  p_Line_Scredit_rec.sales_credit_id IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 1',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit');
            oe_msg_pub.add;

        END IF;

    END IF;
*/

    IF  p_Line_Scredit_rec.sales_credit_type_id IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 1',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type_id');
            oe_msg_pub.add;

        END IF;

    END IF;
    --
    --  Check rest of required attributes here.
    --
/*    IF  p_line_Scredit_rec.HEADER_ID IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 2',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','HEADER');
            oe_msg_pub.add;

        END IF;

    END IF;

    IF  p_line_Scredit_rec.line_id IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 3',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LINE');
            oe_msg_pub.add;

        END IF;

    END IF;
*/

    IF  p_line_Scredit_rec.PERCENT IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 5',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PERCENT');
            oe_msg_pub.add;

        END IF;

    END IF;



    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --
     IF Duplicate_Salescredit
           (p_salesrep_id=>p_Line_Scredit_rec.salesrep_id
           ,p_sales_credit_type_id=>p_Line_Scredit_rec.sales_credit_type_id
           ,p_line_id=>p_Line_Scredit_rec.line_id
           ,p_sales_credit_id=>p_Line_Scredit_rec.sales_credit_id)
      THEN
		oe_debug_pub.add('Validate Entity - 6',1);
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      end if;


    --  Done validating entity

    x_return_status := l_return_status;
   OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE_SCREDIT.Entity',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status               OUT NOCOPY VARCHAR2  /* file.sql.39 change */
,   p_Line_Scredit_rec            IN  OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
BEGIN
   OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE_SCREDIT.Attributes',1);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Scredit attributes

    IF  p_Line_Scredit_rec.created_by IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Created_By(p_Line_Scredit_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.creation_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Creation_Date(p_Line_Scredit_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.dw_update_advice_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Dw_Update_Advice(p_Line_Scredit_rec.dw_update_advice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_Line_Scredit_rec.header_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Header(p_Line_Scredit_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Line_Scredit_rec.last_updated_by IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Last_Updated_By(p_Line_Scredit_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.last_update_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Last_Update_Date(p_Line_Scredit_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.last_update_login IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Last_Update_Login(p_Line_Scredit_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_Line_Scredit_rec.line_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Line(p_Line_Scredit_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_Line_Scredit_rec.percent IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Percent(p_Line_Scredit_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Line_Scredit_rec.salesrep_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Salesrep(p_Line_Scredit_rec.salesrep_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_Line_Scredit_rec.sales_credit_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Sales_Credit(p_Line_Scredit_rec.sales_credit_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Line_Scredit_rec.wh_update_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Wh_Update_Date(p_Line_Scredit_rec.wh_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF   p_Line_Scredit_rec.attribute1 IS NOT NULL

    OR   p_Line_Scredit_rec.attribute10 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute11 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute12 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute13 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute14 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute15 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute2 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute3 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute4 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute5 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute6 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute7 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute8 IS NOT NULL
    OR   p_Line_Scredit_rec.attribute9 IS NOT NULL
    OR   p_Line_Scredit_rec.context IS NOT NULL
    THEN


         oe_debug_pub.add('Before calling Line Sales_Credits_Desc_Flex',2);
         IF NOT OE_CNCL_VALIDATE.Sales_Credits_Desc_Flex
          (p_context            => p_Line_Scredit_rec.context
          ,p_attribute1         => p_Line_Scredit_rec.attribute1
          ,p_attribute2         => p_Line_Scredit_rec.attribute2
          ,p_attribute3         => p_Line_Scredit_rec.attribute3
          ,p_attribute4         => p_Line_Scredit_rec.attribute4
          ,p_attribute5         => p_Line_Scredit_rec.attribute5
          ,p_attribute6         => p_Line_Scredit_rec.attribute6
          ,p_attribute7         => p_Line_Scredit_rec.attribute7
          ,p_attribute8         => p_Line_Scredit_rec.attribute8
          ,p_attribute9         => p_Line_Scredit_rec.attribute9
          ,p_attribute10        => p_Line_Scredit_rec.attribute10
          ,p_attribute11        => p_Line_Scredit_rec.attribute11
          ,p_attribute12        => p_Line_Scredit_rec.attribute12
          ,p_attribute13        => p_Line_Scredit_rec.attribute13
          ,p_attribute14        => p_Line_Scredit_rec.attribute14
          ,p_attribute15        => p_Line_Scredit_rec.attribute15) THEN

           x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
         oe_debug_pub.add('After Line Sales_Credits_Desc_Flex  ' || x_return_status,2);

    END IF;

   OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE_SCREDIT.Attributes',1);
    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;


END OE_CNCL_Validate_Line_Scredit;

/
