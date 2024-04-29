--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_SCREDIT" AS
/* $Header: OEXDHSCB.pls 120.0 2005/06/01 23:13:14 appldev noship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Header_Scredit';

g_header_scredit_rec            OE_ORDER_PUB.Header_Scredit_Rec_Type;

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


PROCEDURE Attributes
(   p_x_Header_Scredit_rec          IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)
IS
--l_old_header_scredit_rec			OE_AK_HEADER_SCREDITS_V%ROWTYPE;
l_operation					VARCHAR2(30);
l_action  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER OE_DEFAULT_HEADER_SCREDIT.ATTRIBUTES' ) ;
     END IF;

/* Commented the following code to fix the bug 2044438

     --  Due to incompatibilities in the record type structure
     --  copy the data to a rowtype record format
	oe_debug_pub.add('In defaulting1');

     OE_Header_Scredit_UTIL.API_Rec_To_Rowtype_Rec
			(p_header_scredit_rec 	=> p_x_header_scredit_rec
               ,x_rowtype_rec 		=> g_header_scredit_rec);
	oe_debug_pub.add('In defaulting2');
     OE_Header_Scredit_UTIL.API_Rec_To_Rowtype_Rec
			(p_header_scredit_rec 	=> p_old_header_scredit_rec
               ,x_rowtype_rec 		=> l_old_header_scredit_rec);
	oe_debug_pub.add('In defaulting3');

End Comment for bug 2044438 */

     g_header_scredit_rec := p_x_header_scredit_rec;

     --  For some fields, get hardcoded defaults based on the operation
     l_operation := p_x_header_scredit_rec.operation;

     IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN

	  IF g_header_scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
		   g_header_scredit_rec.sales_credit_id   := Get_Sales_Credit;
	  END IF;

     END IF;


/* Commented the following code to fix the bug 2044438

     --  call the default handler framework to default the missing attributes
	oe_debug_pub.add('In defaulting4');

     ONT_HEADER_SCREDIT_Def_Hdlr.Default_Record
			(p_x_rec		=> g_header_scredit_rec
			,p_in_old_rec	=> l_old_header_scredit_rec);

     oe_debug_pub.add('In defaulting5');

     --  copy the data back to a format that is compatible with the API architecture

     OE_Header_Scredit_UTIL.RowType_Rec_to_API_Rec
			(p_record	=> g_header_scredit_rec
			,x_api_rec => p_x_header_scredit_rec);

End Comment for bug 2044438 */

/* Added the following code to fix the bug 2044438 */

   p_x_header_scredit_rec := g_header_scredit_rec;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALL CONVERT_MISS_TO_NULL' ) ;
   END IF;
   OE_HEADER_SCREDIT_UTIL.Convert_Miss_To_Null
      (p_x_header_scredit_rec);

/* End of the code added to fix the bug 2044438 */

     /* 1581620 start */

     IF (p_x_Header_Scredit_rec.lock_control  = FND_API.G_MISS_NUM) THEN
	   p_x_Header_Scredit_rec.lock_control := NULL;
	END IF;

     IF (p_x_Header_Scredit_rec.orig_sys_credit_ref  = FND_API.G_MISS_CHAR) THEN
	   p_x_Header_Scredit_rec.orig_sys_credit_ref := 'OE_SALES_CREDITS'||p_x_Header_Scredit_rec.sales_credit_id;
	END IF;

     /* 1581620 end */

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN DEFAULTING6' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_DEFAULT_HEADER_SCREDIT.ATTRIBUTES' ) ;
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

END OE_Default_Header_Scredit  ;

/
