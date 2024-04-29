--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_LINE_SCREDIT" AS
/* $Header: OEXDLSCB.pls 120.0 2005/06/01 00:04:30 appldev noship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Line_Scredit';

g_line_scredit_rec             OE_ORDER_PUB.Line_Scredit_Rec_Type;

FUNCTION Get_Sales_Credit
RETURN NUMBER
IS
l_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    	select OE_SALES_CREDITS_S.nextval
   	into l_id
  	from dual;
 	return l_id;
END Get_Sales_Credit;


FUNCTION Get_Header
RETURN NUMBER
IS
l_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF g_line_scredit_rec.header_id IS NULL OR
	   g_line_scredit_rec.header_id = FND_API.G_MISS_NUM THEN
    	select header_id
   	into l_id
  	from oe_order_lines_all where
	line_id = g_line_scredit_rec.line_id;
 	return l_id;
	ELSE
	return g_line_scredit_rec.header_id;
	END IF;
exception

 when no_data_found then
	return null;

END Get_header;


PROCEDURE Attributes
(   p_x_Line_Scredit_rec          IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec        IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_iteration                   IN  NUMBER := 1
)
IS
--l_old_line_scredit_rec			OE_AK_LINE_SCREDITS_V%ROWTYPE;
l_operation					VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_DEFAULT_LINE_SCREDIT.ATTRIBUTES' ) ;
    END IF;

    --  Due to incompatibilities in the record type structure
    --  Copy the data to a rowtype record format
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DEFAULT ATTRIBUTES 1' ) ;
    END IF;

/* Commented the following code to fix the bug 2044438

    OE_Line_Scredit_UTIL.API_Rec_To_Rowtype_Rec
		(p_line_scredit_rec => p_x_line_scredit_rec
               ,x_rowtype_rec => g_line_scredit_rec);

    oe_debug_pub.add('Default attributes 1.1');
    OE_Line_Scredit_UTIL.API_Rec_To_Rowtype_Rec
		(p_line_scredit_rec => p_old_line_scredit_rec
               ,x_rowtype_rec => l_old_line_scredit_rec);

    oe_debug_pub.add('Default attributes 2');

End Comment for bug 2044438 */

    g_line_scredit_rec := p_x_line_scredit_rec;

    IF g_line_scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
	g_line_scredit_rec.sales_credit_id   := Get_Sales_Credit;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SALES_CREDIT_ID = '||G_LINE_SCREDIT_REC.SALES_CREDIT_ID ) ;
        END IF;
    END IF;

    IF g_line_scredit_rec.line_id IS NOT NULL AND
	g_line_scredit_rec.line_id <> FND_API.G_MISS_NUM THEN
	g_line_scredit_rec.header_id := Get_Header;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DEFAULT ATTRIBUTES 3' ) ;
    END IF;


/* Commented the following code to fix the bug 2044438

    --  Call the default handler framework to default the missing attributes
    oe_debug_pub.add('Default attributes 4');
    ONT_LINE_SCREDIT_Def_Hdlr.Default_Record
	   (p_x_rec		=> g_line_scredit_rec
	   ,p_in_old_rec	=> l_old_line_scredit_rec);

    --  copy the data back to a format that is compatible with the API architecture
    oe_debug_pub.add('Default attributes 5');
    OE_Line_Scredit_UTIL.RowType_Rec_to_API_Rec
		(p_record	=> g_line_scredit_rec
		,x_api_rec 	=> p_x_line_scredit_rec);

End Comment for bug 2044438 */

/* Added the following code to fix the bug 2044438 */

   p_x_line_scredit_rec := g_line_scredit_rec;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALL CONVERT_MISS_TO_NULL' ) ;
   END IF;
   OE_LINE_SCREDIT_UTIL.Convert_Miss_To_Null
      (p_x_line_scredit_rec);

/* End of the code added to fix the bug 2044438 */


    /* 1581620 start */

    IF (p_x_Line_Scredit_rec.lock_control  = FND_API.G_MISS_NUM) THEN
       p_x_Line_Scredit_rec.lock_control := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORIG_SYS_CREDIT_REF = '||NVL ( P_X_LINE_SCREDIT_REC.ORIG_SYS_CREDIT_REF , 'G_MISS_CHAR' ) ) ;
    END IF;
    IF (p_x_Line_Scredit_rec.orig_sys_credit_ref  = FND_API.G_MISS_CHAR) THEN
       p_x_Line_Scredit_rec.orig_sys_credit_ref := 'OE_SALES_CREDITS'||p_x_Line_Scredit_rec.sales_credit_id;
    END IF;

    /* 1581620 end */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DEFAULT ATTRIBUTES 6' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_DEFAULT_LINE_SCREDIT.ATTRIBUTES' ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Attributes'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Attributes;

END OE_Default_Line_Scredit  ;

/
