--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_HEADER_SCREDIT" AS
/* $Header: OEXLHSCB.pls 120.2 2007/12/18 09:15:01 vybhatia ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Header_Scredit';

Function Duplicate_Salescredit
         (p_salesrep_id          IN NUMBER
         ,p_sales_credit_type_id IN NUMBER
         ,p_header_id            IN NUMBER
         ,p_sales_credit_id      IN NUMBER) Return Boolean is
Cursor C_Dup_Salescredit( p_salesrep_id          NUMBER
                         ,p_sales_credit_type_id NUMBER
                         ,p_header_id            NUMBER
                         ,p_sales_credit_id      NUMBER) IS
    Select 'DUPLICATE'
    From  oe_sales_credits
    Where header_id = p_header_id
    And   line_id is null
    And   salesrep_id = p_salesrep_id
    And   sales_credit_type_id  = p_sales_credit_type_id
    And   sales_credit_id <> nvl(p_sales_credit_id,-5);
l_dummy varchar2(30);
Begin
  OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Duplicate_salescredit',1);
  open C_Dup_Salescredit(p_salesrep_id
                        ,p_sales_credit_type_id
                        ,p_header_id
                        ,p_sales_credit_id);
  fetch C_Dup_Salescredit into l_dummy;
  close C_Dup_Salescredit;
  IF l_dummy =  'DUPLICATE' THEN
        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_ORDER_CREDIT');
            oe_msg_pub.Add;

        END IF;
      OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Duplicate_salescredit',1);
      Return TRUE;
  ELSE
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Duplicate_salescredit',1);
    Return FALSE;
  END IF;
End;

-- Procedure to validate quota percent total

Procedure Validate_HSC_QUOTA_TOTAL
  ( x_return_status 	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  , p_header_id     	IN  NUMBER
  ) IS

   l_percent_total NUMBER;
   CURSOR C_HSC_Quota_Total(p_header_id number) IS
   SELECT sum(Percent) Per_total
   FROM oe_sales_credits sc,
	   oe_sales_credit_types sct
   WHERE header_id = p_header_id
   AND sct.sales_credit_type_id = sc.sales_credit_type_id
   AND line_id is null
   AND sct.quota_flag = 'Y';
--   l_orcl_customization Varchar2(1):= NVL(FND_PROFILE.VALUE('ONT_ACTIVATE_ORACLE_CUSTOMIZATION'),'N');
   l_booked_flag Varchar2(15);
BEGIN
   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Validate_HSC_QUOTA_TOTAL',1);
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Order import or it is not oracle specific customization than validate 100% when saving
   --Do not enforce 100% when saving for Oracle customization. enforce 100% only when booking


   --If l_orcl_customization = 'N' or Not OE_GLOBALS.G_UI_FLAG Then
     OPEN C_HSC_Quota_Total(p_header_id);
     FETCH C_HSC_Quota_Total
     INTO  l_percent_total;
     CLOSE C_HSC_Quota_Total;

     IF l_percent_total <> 100 THEN
       fnd_message.set_name('ONT','OE_VAL_ORDER_CREDIT');
       FND_MESSAGE.SET_TOKEN('TOTAL',to_char(l_percent_total));
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   --End If;

/* coded removde under direction from jgould. Oracle IT has canceled this project
   If l_orcl_customization = 'Y' Then
     Begin
       Select booked_flag into l_booked_flag
       From   oe_order_headers
       where  header_id = p_header_id;

       If l_booked_flag = 'Y' Then
         l_percent_total := 0;
         OPEN C_HSC_Quota_Total(p_header_id);
         FETCH C_HSC_Quota_Total
         INTO  l_percent_total;
         CLOSE C_HSC_Quota_Total;

         IF l_percent_total <> 100 THEN
          fnd_message.set_name('ONT','OE_VAL_ORDER_CREDIT');
          FND_MESSAGE.SET_TOKEN('TOTAL',to_char(l_percent_total));
          OE_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

      End If;
     Exception when others then
       null;
     End;
   End If;*/

   OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Validate_HSC_QUOTA_TOTAL',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_HSC_QUOTA_TOTAL'
            );
        END IF;
END Validate_HSC_QUOTA_TOTAL;

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

--bug 3275243
l_ar_decimal_limit CONSTANT NUMBER:=4;
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Entity',1);
    --  Check required attributes.

    IF  p_Header_Scredit_rec.sales_credit_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALES_CREDIT_ID'));
            oe_msg_pub.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF  p_Header_Scredit_rec.HEADER_ID IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','HEADER');
            oe_msg_pub.Add;

        END IF;

    END IF;


    IF  p_Header_Scredit_rec.PERCENT IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('PERCENT'));
            oe_msg_pub.Add;

        END IF;
    ElsIf  p_Header_Scredit_rec.PERCENT <> FND_API.G_MISS_NUM THEN
         IF length(p_header_scredit_rec.percent- trunc(p_Header_Scredit_rec.PERCENT))- 1 > l_ar_decimal_limit THEN
	    oe_debug_pub.add('In OE_Validate_Header_Scredit.entity:Error:percentage more than 4, AR allowes max 4');
	    oe_debug_pub.add('  Header id:'||p_header_scredit_rec.header_id);

	    IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('ONT','ONT_PERCENTAGE_FORMAT');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PERCENT');
              oe_msg_pub.Add;
            END IF;

	    l_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
    END IF;



    IF  p_Header_Scredit_rec.sales_credit_type_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            IF  p_Header_Scredit_rec.salesrep_id IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALESREP_ID'));
                oe_msg_pub.Add;
	    END IF;

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('SALES_CREDIT_TYPE_ID'));
            oe_msg_pub.Add;

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
           (p_salesrep_id=>p_Header_Scredit_rec.salesrep_id
           ,p_sales_credit_type_id=>p_Header_Scredit_rec.sales_credit_type_id
           ,p_header_id=>p_Header_Scredit_rec.header_id
           ,p_sales_credit_id=>p_Header_Scredit_rec.sales_credit_id)
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


    --  Done validating entity

    x_return_status := l_return_status;

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Entity',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

/* changed the p_Header_Scredit_rec to IN OUT NOCOPY in the following procedure to fix the bug 3006018 */

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Scredit_rec            IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
)
IS
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Attributes',1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Header_Scredit attributes

    IF  p_Header_Scredit_rec.created_by IS NOT NULL AND
        (   p_Header_Scredit_rec.created_by <>
            p_old_Header_Scredit_rec.created_by OR
            p_old_Header_Scredit_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate.Created_By(p_Header_Scredit_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.creation_date IS NOT NULL AND
        (   p_Header_Scredit_rec.creation_date <>
            p_old_Header_Scredit_rec.creation_date OR
            p_old_Header_Scredit_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate.Creation_Date(p_Header_Scredit_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.dw_update_advice_flag IS NOT NULL AND
        (   p_Header_Scredit_rec.dw_update_advice_flag <>
            p_old_Header_Scredit_rec.dw_update_advice_flag OR
            p_old_Header_Scredit_rec.dw_update_advice_flag IS NULL )
    THEN
        IF NOT OE_Validate.Dw_Update_Advice(p_Header_Scredit_rec.dw_update_advice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.header_id IS NOT NULL AND
        (   p_Header_Scredit_rec.header_id <>
            p_old_Header_Scredit_rec.header_id OR
            p_old_Header_Scredit_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate.Header(p_Header_Scredit_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.last_updated_by IS NOT NULL AND
        (   p_Header_Scredit_rec.last_updated_by <>
            p_old_Header_Scredit_rec.last_updated_by OR
            p_old_Header_Scredit_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate.Last_Updated_By(p_Header_Scredit_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.last_update_date IS NOT NULL AND
        (   p_Header_Scredit_rec.last_update_date <>
            p_old_Header_Scredit_rec.last_update_date OR
            p_old_Header_Scredit_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Date(p_Header_Scredit_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.last_update_login IS NOT NULL AND
        (   p_Header_Scredit_rec.last_update_login <>
            p_old_Header_Scredit_rec.last_update_login OR
            p_old_Header_Scredit_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Login(p_Header_Scredit_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.line_id IS NOT NULL AND
        (   p_Header_Scredit_rec.line_id <>
            p_old_Header_Scredit_rec.line_id OR
            p_old_Header_Scredit_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate.Line(p_Header_Scredit_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.percent IS NOT NULL AND
        (   p_Header_Scredit_rec.percent <>
            p_old_Header_Scredit_rec.percent OR
            p_old_Header_Scredit_rec.percent IS NULL )
    THEN
        IF NOT OE_Validate.Percent(p_Header_Scredit_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Header_Scredit_rec.salesrep_id IS NOT NULL AND
        (   p_Header_Scredit_rec.salesrep_id <>
            p_old_Header_Scredit_rec.salesrep_id OR
            p_old_Header_Scredit_rec.salesrep_id IS NULL )
    THEN
        IF NOT OE_Validate.Salesrep(p_Header_Scredit_rec.salesrep_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.sales_credit_type_id IS NOT NULL AND
        (   p_Header_Scredit_rec.sales_credit_type_id <>
            p_old_Header_Scredit_rec.sales_credit_type_id OR
            p_old_Header_Scredit_rec.sales_credit_type_id IS NULL )
    THEN
        IF NOT OE_Validate.sales_credit_type(p_Header_Scredit_rec.sales_credit_type_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.sales_credit_id IS NOT NULL AND
        (   p_Header_Scredit_rec.sales_credit_id <>
            p_old_Header_Scredit_rec.sales_credit_id OR
            p_old_Header_Scredit_rec.sales_credit_id IS NULL )
    THEN
        IF NOT OE_Validate.Sales_Credit(p_Header_Scredit_rec.sales_credit_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Scredit_rec.wh_update_date IS NOT NULL AND
        (   p_Header_Scredit_rec.wh_update_date <>
            p_old_Header_Scredit_rec.wh_update_date OR
            p_old_Header_Scredit_rec.wh_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Wh_Update_Date(p_Header_Scredit_rec.wh_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    if OE_GLOBALS.g_validate_desc_flex ='Y' then    --4343612
      oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Header_Scredit.attributes ',1);
    IF  (p_Header_Scredit_rec.attribute1 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute1 <>
            p_old_Header_Scredit_rec.attribute1 OR
            p_old_Header_Scredit_rec.attribute1 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute10 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute10 <>
            p_old_Header_Scredit_rec.attribute10 OR
            p_old_Header_Scredit_rec.attribute10 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute11 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute11 <>
            p_old_Header_Scredit_rec.attribute11 OR
            p_old_Header_Scredit_rec.attribute11 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute12 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute12 <>
            p_old_Header_Scredit_rec.attribute12 OR
            p_old_Header_Scredit_rec.attribute12 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute13 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute13 <>
            p_old_Header_Scredit_rec.attribute13 OR
            p_old_Header_Scredit_rec.attribute13 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute14 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute14 <>
            p_old_Header_Scredit_rec.attribute14 OR
            p_old_Header_Scredit_rec.attribute14 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute15 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute15 <>
            p_old_Header_Scredit_rec.attribute15 OR
            p_old_Header_Scredit_rec.attribute15 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute2 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute2 <>
            p_old_Header_Scredit_rec.attribute2 OR
            p_old_Header_Scredit_rec.attribute2 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute3 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute3 <>
            p_old_Header_Scredit_rec.attribute3 OR
            p_old_Header_Scredit_rec.attribute3 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute4 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute4 <>
            p_old_Header_Scredit_rec.attribute4 OR
            p_old_Header_Scredit_rec.attribute4 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute5 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute5 <>
            p_old_Header_Scredit_rec.attribute5 OR
            p_old_Header_Scredit_rec.attribute5 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute6 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute6 <>
            p_old_Header_Scredit_rec.attribute6 OR
            p_old_Header_Scredit_rec.attribute6 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute7 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute7 <>
            p_old_Header_Scredit_rec.attribute7 OR
            p_old_Header_Scredit_rec.attribute7 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute8 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute8 <>
            p_old_Header_Scredit_rec.attribute8 OR
            p_old_Header_Scredit_rec.attribute8 IS NULL ))
    OR  (p_Header_Scredit_rec.attribute9 IS NOT NULL AND
        (   p_Header_Scredit_rec.attribute9 <>
            p_old_Header_Scredit_rec.attribute9 OR
            p_old_Header_Scredit_rec.attribute9 IS NULL ))
    OR  (p_Header_Scredit_rec.context IS NOT NULL AND
        (   p_Header_Scredit_rec.context <>
            p_old_Header_Scredit_rec.context OR
            p_old_Header_Scredit_rec.context IS NULL ))
    THEN


         oe_debug_pub.add('Before calling Sales_Credits_Desc_Flex',2);
         IF NOT OE_VALIDATE.Sales_Credits_Desc_Flex
          (p_context            => p_Header_Scredit_rec.context
          ,p_attribute1         => p_Header_Scredit_rec.attribute1
          ,p_attribute2         => p_Header_Scredit_rec.attribute2
          ,p_attribute3         => p_Header_Scredit_rec.attribute3
          ,p_attribute4         => p_Header_Scredit_rec.attribute4
          ,p_attribute5         => p_Header_Scredit_rec.attribute5
          ,p_attribute6         => p_Header_Scredit_rec.attribute6
          ,p_attribute7         => p_Header_Scredit_rec.attribute7
          ,p_attribute8         => p_Header_Scredit_rec.attribute8
          ,p_attribute9         => p_Header_Scredit_rec.attribute9
          ,p_attribute10        => p_Header_Scredit_rec.attribute10
          ,p_attribute11        => p_Header_Scredit_rec.attribute11
          ,p_attribute12        => p_Header_Scredit_rec.attribute12
          ,p_attribute13        => p_Header_Scredit_rec.attribute13
          ,p_attribute14        => p_Header_Scredit_rec.attribute14
          ,p_attribute15        => p_Header_Scredit_rec.attribute15) THEN

                x_return_status := FND_API.G_RET_STS_ERROR;

/* Added the following code to fix the bug 3006018 */

          ELSE
              IF p_header_scredit_rec.context IS NULL
              OR p_header_scredit_rec.context = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.context    := oe_validate.g_context;
            END IF;

            IF p_header_scredit_rec.attribute1 IS NULL
              OR p_header_scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_header_scredit_rec.attribute2 IS NULL
              OR p_header_scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_header_scredit_rec.attribute3 IS NULL
              OR p_header_scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_header_scredit_rec.attribute4 IS NULL
              OR p_header_scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_header_scredit_rec.attribute5 IS NULL
              OR p_header_scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_header_scredit_rec.attribute6 IS NULL
              OR p_header_scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_header_scredit_rec.attribute7 IS NULL
              OR p_header_scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_header_scredit_rec.attribute8 IS NULL
              OR p_header_scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_header_scredit_rec.attribute9 IS NULL
              OR p_header_scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_header_scredit_rec.attribute10 IS NULL
              OR p_header_scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute10 := oe_validate.g_attribute10;
            END IF;

            IF p_header_scredit_rec.attribute11 IS NULL
              OR p_header_scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_header_scredit_rec.attribute12 IS NULL
              OR p_header_scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_header_scredit_rec.attribute13 IS NULL
              OR p_header_scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_header_scredit_rec.attribute14 IS NULL
              OR p_header_scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_header_scredit_rec.attribute15 IS NULL
              OR p_header_scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
               p_header_scredit_rec.attribute15 := oe_validate.g_attribute15;
            END IF;

/* End of the code added to fix the bug 3006018 */
          END IF;

         oe_debug_pub.add('After Sales_Credits_Desc_Flex  ' || x_return_status,2);

    END IF;
    end if; /* OE_GLOBALS.g_validate_desc_flex ='Y' then    --4343612*/
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Attributes',1);
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
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Entity_Delete',1);
    --  Validate entity delete.

/* Modified the following request to fix the bug 5746190 */

         OE_Delayed_Requests_Pvt.Log_Request
                 (p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL
                 ,p_entity_id             =>p_Header_Scredit_rec.header_id
                 ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Header_Scredit
                 ,p_requesting_entity_id  =>p_Header_Scredit_rec.sales_credit_id
                 ,p_request_type          =>OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL
                 ,p_param1                =>to_char(p_Header_Scredit_rec.header_id)
                 ,x_return_status         =>l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


    --  Done.

    x_return_status := l_return_status;
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Entity_Delete',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

-- Procedure to validate quota percent total for booking

Procedure Validate_HSC_TOTAL_FOR_BK
  ( x_return_status 	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  , p_header_id     	IN  NUMBER
  ) IS
l_percent_total Number;
Cursor C_HSC_Quota_Total(p_header_id number) IS
Select sum(Percent) Per_total
  From oe_sales_credits sc,
       oe_sales_credit_types sct
 Where header_id = p_header_id
   And sct.sales_credit_type_id = sc.sales_credit_type_id
   And line_id is null
   And sct.quota_flag = 'Y';

BEGIN
   OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Scredits.Validate_HSC_TOTAL_FOR_BK',1);
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Open  C_HSC_Quota_Total(p_header_id);
   Fetch C_HSC_Quota_Total
   Into  l_percent_total;
   Close C_HSC_Quota_Total;

   IF nvl(l_percent_total,0) <> 100 THEN
       FND_MESSAGE.SET_NAME('ONT','OE_VAL_ORDER_CREDIT');
       FND_MESSAGE.SET_TOKEN('TOTAL',to_char(l_percent_total));
       oe_msg_pub.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Scredits.Validate_HSC_TOTAL_FOR_BK',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_HSC_QUOTA_TOTAL_FOR_BK'
            );
        END IF;
END Validate_HSC_TOTAL_FOR_BK;


END OE_Validate_Header_Scredit;

/
