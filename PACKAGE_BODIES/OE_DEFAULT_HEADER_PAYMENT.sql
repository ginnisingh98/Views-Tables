--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_PAYMENT" AS
/* $Header: OEXDHPMB.pls 120.3.12010000.2 2009/12/08 11:48:09 msundara ship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Header_Payment';

g_header_payment_rec            OE_AK_HEADER_PAYMENTS_V%ROWTYPE;

PROCEDURE Attributes
(   p_x_Header_Payment_rec          IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Rec_Type
,   p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)
IS
l_old_header_Payment_rec			OE_AK_HEADER_PAYMENTS_V%ROWTYPE;
l_operation					VARCHAR2(30);
l_action  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_org_id number := 0;
l_payment_type_code varchar2(30) := NULL;
l_old_payment_type_code varchar2(30) := NULL;
l_defer varchar2(1) := NULL;

BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER OE_DEFAULT_HEADER_PAYMENT.ATTRIBUTES' ) ;
     END IF;

     l_operation := p_x_header_payment_rec.operation;

     IF (p_x_Header_Payment_rec.payment_number = FND_API.G_MISS_NUM
        OR  p_x_Header_Payment_rec.payment_number IS NULL)
        AND  l_operation = OE_GLOBALS.G_OPR_CREATE
        THEN
       p_x_Header_Payment_rec.payment_number
               := Get_Payment_Number(p_x_Header_Payment_rec.header_id);
     END IF;

    --  Due to incompatibilities in the record type structure
    --  copy the data to a rowtype record format

    OE_Header_Payment_UTIL.API_Rec_To_Rowtype_Rec
                        (p_header_payment_rec => p_x_header_payment_rec
                        ,x_rowtype_rec => g_header_payment_rec);
    OE_Header_Payment_UTIL.API_Rec_To_Rowtype_Rec
                        (p_header_payment_rec => p_old_header_payment_rec
                         ,x_rowtype_rec => l_old_header_payment_rec);


    --  For some fields, get hardcoded defaults based on the operation
    IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN

       g_header_payment_rec.payment_level_code := 'ORDER';

    END IF;
     --  call the default handler framework to default the missing attributes
    IF l_debug_level > 0 THEN
	     oe_debug_pub.add('In defaulting4');

	     oe_debug_pub.add('OEXDHPMB -- trxn_extension_id is: '||p_x_header_payment_rec.trxn_extension_id);
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_number...'||g_header_payment_rec.credit_card_number);
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_code...'||g_header_payment_rec.credit_card_code);
	    -- bug 5001819
	    IF OE_GLOBALS.G_UI_FLAG THEN
		oe_debug_pub.add('G ui flag True');

	    ELSE
		oe_debug_pub.add('Gui flag false');
	    END IF;
    END IF;
    --bug 5020737
    --Checking the UI flag here since defaulting was happening when
    --other products were passing the trxn extension id alone and the
    --other credit card attributes were set as G_MISS values. When
    --the call comes from OM, defaulting would need to happen.
    IF p_x_header_payment_rec.trxn_extension_id IS NOT NULL AND
    NOT OE_GLOBALS.Equal(p_x_header_payment_rec.trxn_extension_id,FND_API.G_MISS_NUM)
    AND NOT OE_GLOBALS.G_UI_FLAG AND p_x_header_payment_rec.operation = OE_GLOBALS.G_OPR_CREATE
    THEN
      IF OE_GLOBALS.Equal(g_header_payment_rec.credit_Card_number,FND_API.G_MISS_CHAR) THEN --bug 5020737
	      g_header_payment_rec.credit_card_number := null;
      END IF;

      IF OE_GLOBALS.Equal(g_header_payment_rec.credit_card_code,FND_API.G_MISS_CHAR) THEN --bug 5020737
	      g_header_payment_rec.credit_card_code := null;
      END IF;

      IF OE_GLOBALS.Equal(g_header_payment_rec.credit_card_holder_name,FND_API.G_MISS_CHAR) THEN --bug 5020737
	      g_header_payment_rec.credit_card_holder_name := null;
      END IF;

      IF OE_GLOBALS.Equal(g_header_payment_rec.credit_card_expiration_date,FND_API.G_MISS_DATE) THEN --bug 5020737
           g_header_payment_rec.credit_card_expiration_date := null;
      END IF;

    END IF;
    --bug 5020737
    --IF l_debug_level > 0 THEN
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_number...'||g_header_payment_rec.credit_card_number);
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_code...'||g_header_payment_rec.credit_card_code);
    --END IF;
     ONT_HEADER_Payment_Def_Hdlr.Default_Record
			(p_x_rec		=> g_header_payment_rec
			,p_in_old_rec	=> l_old_header_payment_rec);
    IF l_debug_level > 0 THEN
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_number...'||g_header_payment_rec.credit_card_number);
	     --oe_debug_pub.add('g_header_payment_rec.credit_card_code...'||g_header_payment_rec.credit_card_code);
	     oe_debug_pub.add('In defaulting5');
    END IF;
     --  copy the data back to a format that is compatible with the API architecture

     OE_Header_Payment_UTIL.RowType_Rec_to_API_Rec
			(p_record	=> g_header_Payment_rec
			,x_api_rec => p_x_header_Payment_rec);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALL CONVERT_MISS_TO_NULL' ) ;
   END IF;
   OE_HEADER_Payment_UTIL.Convert_Miss_To_Null
      (p_x_header_Payment_rec);

   /* code change for defer_payment_processing_flag */

    l_org_id := OE_GLOBALS.G_ORG_ID;
    l_payment_type_code := p_x_header_Payment_rec.payment_type_code;
    l_old_payment_type_code := p_old_header_Payment_rec.payment_type_code;

    if l_org_id is null then
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    end if;

    Begin
    --bug3504713  commenting the following condition and adding a new condition
    --  if p_x_header_Payment_rec.defer_payment_processing_flag is null
        if NOT OE_GLOBALS.EQUAL(l_payment_type_code,l_old_payment_type_code)
        and l_payment_type_code is not null
        and (
            (OE_GLOBALS.EQUAL(p_x_header_Payment_rec.defer_payment_processing_flag,
                        p_old_header_Payment_rec.defer_payment_processing_flag)
             and p_x_header_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
             or
               (nvl(p_x_header_Payment_rec.defer_payment_processing_flag,
                     FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
               and p_x_header_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE)
             or
               (nvl(p_old_header_Payment_rec.defer_payment_processing_flag,
                     FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
               and p_x_header_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE)
            )
        then

           select defer_payment_processing_flag into l_defer
           from oe_payment_types_all
           where payment_type_code = l_payment_type_code
           and nvl(org_id, -99) = nvl(l_org_id, -99);

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Defaulting the defer_payment_processing_flag. ' ) ;
           END IF;

           p_x_header_Payment_rec.defer_payment_processing_flag := l_defer;

        end if;

       Exception
        when others then
             p_x_header_Payment_rec.defer_payment_processing_flag := 'N';

    End;

   /* end of code change for defer payment processing flag */

     IF (p_x_Header_Payment_rec.lock_control  = FND_API.G_MISS_NUM) THEN
	   p_x_Header_Payment_rec.lock_control := NULL;
     END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_DEFAULT_HEADER_PAYMENT.ATTRIBUTES' ) ;
	END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

	   RAISE FND_API.G_EXC_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attributes;

FUNCTION Get_Payment_Number
(p_header_id IN NUMBER)
RETURN NUMBER
IS
l_payment_number	NUMBER := NULL;
l_exists_null_number	VARCHAR2(1) := 'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In OE_Default_Header_Payment: FUNCTION Get_Payment_Number' ) ;
        oe_debug_pub.add(  'header_id is: '||p_header_id ) ;
    END IF;

    IF p_header_id IS NOT NULL
       AND p_header_id <> FND_API.G_MISS_NUM THEN
      BEGIN
        SELECT 'Y'
        INTO   l_exists_null_number
        FROM   oe_payments
        WHERE  payment_number is null
        AND    header_id = p_header_id
        AND    line_id is null
        AND    rownum = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_exists_null_number := 'N';
      END;

      IF l_exists_null_number = 'N' THEN
        SELECT  NVL(MAX(PAYMENT_NUMBER)+1,1)
        INTO    l_payment_number
        FROM    OE_PAYMENTS
        WHERE   HEADER_ID = p_header_id
        AND     LINE_ID IS NULL;
      ELSE
        SELECT  MAX(NVL(PAYMENT_NUMBER, 1))+1
        INTO    l_payment_number
        FROM    OE_PAYMENTS
        WHERE   HEADER_ID = p_header_id
        AND     LINE_ID IS NULL;
      END IF;

    END IF;

    RETURN (l_payment_number);

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Payment_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Payment_Number;

END OE_Default_Header_Payment  ;

/
