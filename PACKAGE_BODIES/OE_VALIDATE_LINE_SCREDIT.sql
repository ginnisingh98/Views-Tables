--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_LINE_SCREDIT" AS
/* $Header: OEXLLSCB.pls 120.1 2005/12/29 04:32:41 ppnair noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Line_Scredit';

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
  OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
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
      OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
      Return TRUE;
  ELSE
      OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Duplicate_Salescredit',1);
     Return FALSE;
  END IF;
END Duplicate_Salescredit;

-- Procedure to validate quota percent total

Procedure Validate_LSC_QUOTA_TOTAL
  ( x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2
  , p_line_id       IN NUMBER
  ) IS
l_percent_total Number;
-- FP bug 3872166
l_line_no varchar2(30);
Cursor C_LSC_Quota_Total(p_line_id number) IS
   SELECT sum(Percent) Per_total
   FROM   oe_sales_credits sc,
	     oe_sales_credit_types sct
   WHERE  line_id = p_line_id
   AND    sc.sales_credit_type_id = sct.sales_credit_type_id
   AND    sct.quota_flag = 'Y';

BEGIN
   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE_SCREDIT.Validate_LSC_QUOTA_TOTAL',1);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN C_LSC_Quota_Total(p_line_id);
   FETCH C_LSC_Quota_Total
   INTO  l_percent_total;
   CLOSE C_LSC_Quota_Total;

   --FP bug 3872166 start
   IF l_percent_total = 0 THEN
       l_line_no := OE_ORDER_MISC_PUB.Get_Concat_Line_Number(p_line_id);
       FND_MESSAGE.SET_NAME('ONT','ONT_ZERO_PERCENT_LINE_CREDITS');
       FND_MESSAGE.SET_TOKEN('LINE_NO',l_line_no);
       oe_msg_pub.add;
   --FP bug 3872166 end
   ELSIF l_percent_total <> 100 THEN
       FND_MESSAGE.SET_NAME('ONT','OE_VAL_TTL_LINE_CREDIT');
       FND_MESSAGE.SET_TOKEN('TOTAL',to_char(l_percent_total));
       oe_msg_pub.add;
       x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Validate_LSC_QUOTA_TOTAL',1);
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
            ,   'Validate_LSC_QUOTA_TOTAL'
);
        END IF;
END Validate_LSC_QUOTA_TOTAL;

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

--bug 3275243
l_ar_decimal_limit CONSTANT NUMBER:=4;
BEGIN
   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE_SCREDIT.Entity',1);

    --  Check required attributes.

    IF  p_Line_Scredit_rec.sales_credit_id IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 1',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALES_CREDIT_ID'));

            oe_msg_pub.add;

        END IF;

    END IF;

    IF  p_Line_Scredit_rec.sales_credit_type_id IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 1',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	   IF  p_line_Scredit_rec.salesrep_id IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALESREP_ID'));
                oe_msg_pub.Add;
	    END IF;

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALES_CREDIT_TYPE_ID'));

            oe_msg_pub.add;

        END IF;

    END IF;
    --
    --  Check rest of required attributes here.
    --
    IF  p_line_Scredit_rec.HEADER_ID IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 2',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('HEADER'));
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
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('LINE'));
            oe_msg_pub.add;

        END IF;

    END IF;


    IF  p_line_Scredit_rec.PERCENT IS NULL
    THEN
		oe_debug_pub.add('Validate Entity - 5',1);

        l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('PERCENT'));
            oe_msg_pub.add;

          END IF;
    ElsIf  p_line_Scredit_rec.PERCENT <> FND_API.G_MISS_NUM THEN
         IF length(p_line_scredit_rec.percent- trunc(p_line_Scredit_rec.PERCENT))- 1 > l_ar_decimal_limit THEN
	    oe_debug_pub.add('In OE_Validate_Header_Scredit.entity:Error:percentage more than 4, AR allowes max 4');
	    oe_debug_pub.add('  Header id:'||p_line_scredit_rec.header_id);

	    IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('ONT','ONT_PERCENTAGE_FORMAT');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PERCENT');
              oe_msg_pub.Add;
            END IF;

	    l_return_status := FND_API.G_RET_STS_ERROR;
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
   OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Entity',1);

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

/* changed p_Line_Scredit_rec in the following procedure to IN OUT NOCPY to fix the bug 3006018 */

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
)
IS
BEGIN
   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE_SCREDIT.Attributes',1);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Scredit attributes

    IF  p_Line_Scredit_rec.created_by IS NOT NULL AND
        (   p_Line_Scredit_rec.created_by <>
            p_old_Line_Scredit_rec.created_by OR
            p_old_Line_Scredit_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate.Created_By(p_Line_Scredit_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.creation_date IS NOT NULL AND
        (   p_Line_Scredit_rec.creation_date <>
            p_old_Line_Scredit_rec.creation_date OR
            p_old_Line_Scredit_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate.Creation_Date(p_Line_Scredit_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.dw_update_advice_flag IS NOT NULL AND
        (   p_Line_Scredit_rec.dw_update_advice_flag <>
            p_old_Line_Scredit_rec.dw_update_advice_flag OR
            p_old_Line_Scredit_rec.dw_update_advice_flag IS NULL )
    THEN
        IF NOT OE_Validate.Dw_Update_Advice(p_Line_Scredit_rec.dw_update_advice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.header_id IS NOT NULL AND
        (   p_Line_Scredit_rec.header_id <>
            p_old_Line_Scredit_rec.header_id OR
            p_old_Line_Scredit_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate.Header(p_Line_Scredit_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.last_updated_by IS NOT NULL AND
        (   p_Line_Scredit_rec.last_updated_by <>
            p_old_Line_Scredit_rec.last_updated_by OR
            p_old_Line_Scredit_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate.Last_Updated_By(p_Line_Scredit_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.last_update_date IS NOT NULL AND
        (   p_Line_Scredit_rec.last_update_date <>
            p_old_Line_Scredit_rec.last_update_date OR
            p_old_Line_Scredit_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Date(p_Line_Scredit_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.last_update_login IS NOT NULL AND
        (   p_Line_Scredit_rec.last_update_login <>
            p_old_Line_Scredit_rec.last_update_login OR
            p_old_Line_Scredit_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Login(p_Line_Scredit_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.line_id IS NOT NULL AND
        (   p_Line_Scredit_rec.line_id <>
            p_old_Line_Scredit_rec.line_id OR
            p_old_Line_Scredit_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate.Line(p_Line_Scredit_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.percent IS NOT NULL AND
        (   p_Line_Scredit_rec.percent <>
            p_old_Line_Scredit_rec.percent OR
            p_old_Line_Scredit_rec.percent IS NULL )
    THEN
        IF NOT OE_Validate.Percent(p_Line_Scredit_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Line_Scredit_rec.salesrep_id IS NOT NULL AND
        (   p_Line_Scredit_rec.salesrep_id <>
            p_old_Line_Scredit_rec.salesrep_id OR
            p_old_Line_Scredit_rec.salesrep_id IS NULL )
    THEN
        IF NOT OE_Validate.Salesrep(p_Line_Scredit_rec.salesrep_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.sales_credit_id IS NOT NULL AND
        (   p_Line_Scredit_rec.sales_credit_id <>
            p_old_Line_Scredit_rec.sales_credit_id OR
            p_old_Line_Scredit_rec.sales_credit_id IS NULL )
    THEN
        IF NOT OE_Validate.Sales_Credit(p_Line_Scredit_rec.sales_credit_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Scredit_rec.wh_update_date IS NOT NULL AND
        (   p_Line_Scredit_rec.wh_update_date <>
            p_old_Line_Scredit_rec.wh_update_date OR
            p_old_Line_Scredit_rec.wh_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Wh_Update_Date(p_Line_Scredit_rec.wh_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    if OE_GLOBALS.g_validate_desc_flex ='Y' then --bug 4343612
     oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Line_Scredit.attributes ',1);
    IF  (p_Line_Scredit_rec.attribute1 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute1 <>
            p_old_Line_Scredit_rec.attribute1 OR
            p_old_Line_Scredit_rec.attribute1 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute10 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute10 <>
            p_old_Line_Scredit_rec.attribute10 OR
            p_old_Line_Scredit_rec.attribute10 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute11 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute11 <>
            p_old_Line_Scredit_rec.attribute11 OR
            p_old_Line_Scredit_rec.attribute11 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute12 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute12 <>
            p_old_Line_Scredit_rec.attribute12 OR
            p_old_Line_Scredit_rec.attribute12 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute13 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute13 <>
            p_old_Line_Scredit_rec.attribute13 OR
            p_old_Line_Scredit_rec.attribute13 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute14 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute14 <>
            p_old_Line_Scredit_rec.attribute14 OR
            p_old_Line_Scredit_rec.attribute14 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute15 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute15 <>
            p_old_Line_Scredit_rec.attribute15 OR
            p_old_Line_Scredit_rec.attribute15 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute2 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute2 <>
            p_old_Line_Scredit_rec.attribute2 OR
            p_old_Line_Scredit_rec.attribute2 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute3 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute3 <>
            p_old_Line_Scredit_rec.attribute3 OR
            p_old_Line_Scredit_rec.attribute3 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute4 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute4 <>
            p_old_Line_Scredit_rec.attribute4 OR
            p_old_Line_Scredit_rec.attribute4 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute5 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute5 <>
            p_old_Line_Scredit_rec.attribute5 OR
            p_old_Line_Scredit_rec.attribute5 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute6 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute6 <>
            p_old_Line_Scredit_rec.attribute6 OR
            p_old_Line_Scredit_rec.attribute6 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute7 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute7 <>
            p_old_Line_Scredit_rec.attribute7 OR
            p_old_Line_Scredit_rec.attribute7 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute8 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute8 <>
            p_old_Line_Scredit_rec.attribute8 OR
            p_old_Line_Scredit_rec.attribute8 IS NULL ))
    OR  (p_Line_Scredit_rec.attribute9 IS NOT NULL AND
        (   p_Line_Scredit_rec.attribute9 <>
            p_old_Line_Scredit_rec.attribute9 OR
            p_old_Line_Scredit_rec.attribute9 IS NULL ))
    OR  (p_Line_Scredit_rec.context IS NOT NULL AND
        (   p_Line_Scredit_rec.context <>
            p_old_Line_Scredit_rec.context OR
            p_old_Line_Scredit_rec.context IS NULL ))
    THEN


         oe_debug_pub.add('Before calling Line Sales_Credits_Desc_Flex',2);
         IF NOT OE_VALIDATE.Sales_Credits_Desc_Flex
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

/* Added the following code to fix the bug 3006018 */

          ELSE
              IF p_line_scredit_rec.context IS NULL
              OR p_line_scredit_rec.context = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.context    := oe_validate.g_context;
            END IF;

            IF p_line_scredit_rec.attribute1 IS NULL
              OR p_line_scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_line_scredit_rec.attribute2 IS NULL
              OR p_line_scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_line_scredit_rec.attribute3 IS NULL
              OR p_line_scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_line_scredit_rec.attribute4 IS NULL
              OR p_line_scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_line_scredit_rec.attribute5 IS NULL
              OR p_line_scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_line_scredit_rec.attribute6 IS NULL
              OR p_line_scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_line_scredit_rec.attribute7 IS NULL
              OR p_line_scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_line_scredit_rec.attribute8 IS NULL
              OR p_line_scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_line_scredit_rec.attribute9 IS NULL
              OR p_line_scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_line_scredit_rec.attribute10 IS NULL
              OR p_line_scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute10 := oe_validate.g_attribute10;
            END IF;

            IF p_line_scredit_rec.attribute11 IS NULL
              OR p_line_scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_line_scredit_rec.attribute12 IS NULL
              OR p_line_scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_line_scredit_rec.attribute13 IS NULL
              OR p_line_scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_line_scredit_rec.attribute14 IS NULL
              OR p_line_scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_line_scredit_rec.attribute15 IS NULL
              OR p_line_scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
               p_line_scredit_rec.attribute15 := oe_validate.g_attribute15;
            END IF;

/* End of the code added to fix the bug 3006018 */

         END IF;
         oe_debug_pub.add('After Line Sales_Credits_Desc_Flex  ' || x_return_status,2);

    END IF;

   OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Attributes',1);
    --  Done validating attributes
    end if ; /*if OE_GLOBALS.g_validate_desc_flex ='Y' then bug 4343612*/
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

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_request_rec                 OE_Order_PUB.request_rec_type;
BEGIN

    --  Validate entity delete.

   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE_SCREDIT.Entity_Delete',1);
    NULL;
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code            =>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id              =>p_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code =>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id   =>p_Line_Scredit_rec.sales_credit_id
               ,p_request_type           =>OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL
               ,p_param1                 => to_char(p_Line_Scredit_rec.Line_id)
               ,x_return_status          =>l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


	-- Adding service sales credit delayed request
	-- Here we are executing the delayed request procedure which will
	-- cascade the sc delete.

       IF OE_GLOBALS.G_RECURSION_MODE <> 'Y' THEN
        -- Preparing request_rec.
         l_request_rec.entity_code  := OE_GLOBALS.G_ENTITY_line_Scredit;
         l_request_rec.entity_id    := p_Line_Scredit_rec.sales_credit_id;
         l_request_rec.request_type := OE_GLOBALS.G_CASCADE_SERVICE_SCREDIT;
         l_request_rec.param8 := to_char(p_Line_Scredit_rec.Line_id);
         l_request_rec.param1 := to_char(p_Line_Scredit_rec.salesrep_id);
         l_request_rec.param2 := to_char(p_Line_Scredit_rec.salesrep_id);
         l_request_rec.param3 := to_char(p_Line_Scredit_rec.Sales_credit_type_id);
         l_request_rec.param4 := to_char(p_Line_Scredit_rec.Sales_credit_type_id);
         l_request_rec.param5 := to_char(p_Line_Scredit_rec.percent);
         l_request_rec.param6 := to_char(p_Line_Scredit_rec.percent);
         l_request_rec.param7 := p_Line_Scredit_rec.operation;


            OE_DELAYED_REQUESTS_UTIL.Cascade_Service_Scredit
              ( x_return_status =>l_return_status
               ,p_request_rec   =>l_request_rec);

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Done.

   OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE_SCREDIT.Entity_Delete',1);
    x_return_status := l_return_status;

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
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END OE_Validate_Line_Scredit;

/
