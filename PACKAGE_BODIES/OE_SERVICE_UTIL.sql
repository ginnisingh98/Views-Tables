--------------------------------------------------------
--  DDL for Package Body OE_SERVICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SERVICE_UTIL" As
/* $Header: OEXUSVCB.pls 120.9.12010000.6 2010/07/19 06:42:49 sahvivek ship $ */

G_ASO_STATUS                  VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_OKC_STATUS                  VARCHAR2(1) := FND_API.G_MISS_CHAR;

g_customer_id number := NULL;  -- 2225343

Function Get_Product_Status(p_application_id      NUMBER)
RETURN VARCHAR2 IS
   l_ret_val           BOOLEAN;
   l_status            VARCHAR2(1);
   l_industry          VARCHAR2(1);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   if (p_application_id = 697
		   AND G_ASO_STATUS = FND_API.G_MISS_CHAR)
   or ( p_application_id = 515
          AND G_OKC_STATUS = FND_API.G_MISS_CHAR)
     then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'GET PROD. STATUS' ) ;
     END IF;

           -- Make a call to fnd_installation.get function to check for the
           -- installation status of the CRM products and return the status.

           l_ret_val := fnd_installation.get(p_application_id,p_application_id
                         ,l_status,l_industry);
           if p_application_id = 697         then
               G_ASO_STATUS := l_status;
           elsif p_application_id = 515       then
               G_OKC_STATUS := l_status;
           end if;

    end if;

    if p_application_id = 697 then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RET PROD. STATUS :'||G_ASO_STATUS ) ;
     END IF;
     return (G_ASO_STATUS);
    elsif p_application_id = 515 then
     return (G_OKC_STATUS);
    end if;

END Get_Product_Status;

Procedure Notify_OC
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    							     OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    							    OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	           IN  OE_Order_PUB.request_tbl_type :=
						          OE_Order_PUB.g_miss_request_tbl
)
IS

l_number               	     NUMBER := 0;
l_api_name 		          CONSTANT VARCHAR(30) := 'NOTIFY_OC';
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_sql_stat                    VARCHAR2(3000);
l_init_msg_list               VARCHAR2(240);
l_commit                      VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_bypass_notify_oc            VARCHAR2(30) := nvl(FND_PROFILE.VALUE('ONT_BYPASS_NOTIFY_OC'),'N');
l_buffer                      VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING NOTIFY_OC API' ) ;
  END IF;

  -- Call Describe_Proc to check for the existance of the CRM's
  -- Update_Notice API. If exists Then Call it else No Problem.

  -- Commenting out the call to check proc for performance improvement
/*
  OE_SERVICE_UTIL.CHECK_PROC('ASO_ORDER_FEEDBACK_PUB.UPDATE_NOTICE', l_return_status);
  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
*/

    /* The application id for Order Capture is 697 */

    -- IF Get_Product_Status(697) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    IF OE_GLOBALS.G_ASO_INSTALLED = 'Y' THEN


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BYPASS VALUE:' || L_BYPASS_NOTIFY_OC ) ;
     END IF;
    IF l_bypass_notify_oc = 'Y' then
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'BYPASSING THE CALL TO NOTIFY OC' , 1 ) ;
	   END IF;
    ELSE

    --  Call  Update_Notice API Using Native Dynamic SQL

 /*
  * csheu Fixed bug #1677930 replaced the following call to static call
  *
    l_sql_stat := '
    Begin
    ASO_ORDER_FEEDBACK_PUB.UPDATE_NOTICE(
        1.0
      , :p_init_msg_list
      , :p_commit
      , :x_return_status
      , :x_msg_count
      , :x_msg_data
      , OE_SERVICE_UTIL.g_header_rec
      , OE_SERVICE_UTIL.g_old_header_rec
      , OE_SERVICE_UTIL.g_header_adj_tbl
      , OE_SERVICE_UTIL.g_old_header_adj_tbl
      , OE_SERVICE_UTIL.g_header_price_att_tbl
      , OE_SERVICE_UTIL.g_old_header_price_att_tbl
      , OE_SERVICE_UTIL.g_header_adj_att_tbl
      , OE_SERVICE_UTIL.g_old_header_adj_att_tbl
      , OE_SERVICE_UTIL.g_header_adj_assoc_tbl
      , OE_SERVICE_UTIL.g_old_header_adj_assoc_tbl
      , OE_SERVICE_UTIL.g_header_scredit_tbl
      , OE_SERVICE_UTIL.g_old_header_scredit_tbl
      , OE_SERVICE_UTIL.g_line_tbl
      , OE_SERVICE_UTIL.g_old_line_tbl
      , OE_SERVICE_UTIL.g_line_adj_tbl
      , OE_SERVICE_UTIL.g_old_line_adj_tbl
      , OE_SERVICE_UTIL.g_line_price_att_tbl
      , OE_SERVICE_UTIL.g_old_line_price_att_tbl
      , OE_SERVICE_UTIL.g_line_adj_att_tbl
      , OE_SERVICE_UTIL.g_old_line_adj_att_tbl
      , OE_SERVICE_UTIL.g_line_adj_assoc_tbl
      , OE_SERVICE_UTIL.g_old_line_adj_assoc_tbl
      , OE_SERVICE_UTIL.g_line_scredit_tbl
      , OE_SERVICE_UTIL.g_old_line_scredit_tbl
      , OE_SERVICE_UTIL.g_lot_serial_tbl
      , OE_SERVICE_UTIL.g_old_lot_serial_tbl
	 , OE_SERVICE_UTIL.g_action_request_tbl);
	 END;';


    EXECUTE IMMEDIATE l_sql_stat
	 USING IN  l_init_msg_list
      ,     IN  l_commit
, OUT NOCOPY l_return_status

, OUT NOCOPY x_msg_count

, OUT NOCOPY x_msg_data;

*/
    -- Bug 5603656
    -- Moved the code to the else part
    -- Assign the value of the passed parameters to the Global variable
    OE_SERVICE_UTIL.g_Header_Rec               :=   p_Header_Rec;
    OE_SERVICE_UTIL.g_old_header_rec           :=   p_old_header_rec ;
    OE_SERVICE_UTIL.g_Header_Adj_tbl           :=   p_Header_Adj_tbl;
    OE_SERVICE_UTIL.g_old_Header_Adj_tbl       :=   p_old_Header_Adj_tbl;

    /* Notification Project changes */
/* Comment out nocopy the calls to entities that are not used by the subscriber */


--    OE_SERVICE_UTIL.g_Header_Price_Att_tbl     :=   p_Header_Price_Att_tbl;
--    OE_SERVICE_UTIL.g_old_Header_Price_Att_tbl :=   p_old_Header_Price_Att_tbl;
--    OE_SERVICE_UTIL.g_Header_Adj_Att_tbl       :=   p_Header_Adj_Att_tbl;
--    OE_SERVICE_UTIL.g_old_Header_Adj_Att_tbl   :=   p_old_Header_Adj_Att_tbl;
--    OE_SERVICE_UTIL.g_Header_Adj_Assoc_tbl     :=   p_Header_Adj_Assoc_tbl;
--    OE_SERVICE_UTIL.g_old_Header_Adj_Assoc_tbl :=   p_old_Header_Adj_Assoc_tbl;
    OE_SERVICE_UTIL.g_Header_Scredit_tbl       :=   p_Header_Scredit_tbl;
    OE_SERVICE_UTIL.g_old_Header_Scredit_tbl   :=   p_old_Header_Scredit_tbl;
    OE_SERVICE_UTIL.g_line_tbl                 :=   p_line_tbl;
    OE_SERVICE_UTIL.g_old_line_tbl             :=   p_old_line_tbl;
    OE_SERVICE_UTIL.g_Line_Adj_tbl             :=   p_Line_Adj_tbl;
    OE_SERVICE_UTIL.g_old_Line_Adj_tbl         :=   p_old_Line_Adj_tbl;
--    OE_SERVICE_UTIL.g_Line_Price_Att_tbl       :=   p_Line_Price_Att_tbl;
--    OE_SERVICE_UTIL.g_old_Line_Price_Att_tbl   :=   p_old_Line_Price_Att_tbl;
--    OE_SERVICE_UTIL.g_Line_Adj_Att_tbl         :=   p_Line_Adj_Att_tbl;
--    OE_SERVICE_UTIL.g_old_Line_Adj_Att_tbl     :=   p_old_Line_Adj_Att_tbl;
--    OE_SERVICE_UTIL.g_Line_Adj_Assoc_tbl       :=   p_Line_Adj_Assoc_tbl;
--    OE_SERVICE_UTIL.g_old_Line_Adj_Assoc_tbl   :=   p_old_Line_Adj_Assoc_tbl;
    OE_SERVICE_UTIL.g_Line_Scredit_tbl         :=   p_Line_Scredit_tbl;
    OE_SERVICE_UTIL.g_old_Line_Scredit_tbl     :=   p_old_Line_Scredit_tbl;
    OE_SERVICE_UTIL.g_Lot_Serial_tbl           :=   p_Lot_Serial_tbl;
    OE_SERVICE_UTIL.g_old_Lot_Serial_tbl       :=   p_old_Lot_Serial_tbl;
--    OE_SERVICE_UTIL.g_Lot_Serial_val_tbl       :=   p_Lot_Serial_val_tbl;
--    OE_SERVICE_UTIL.g_old_Lot_Serial_val_tbl   :=   p_old_Lot_Serial_val_tbl;
    OE_SERVICE_UTIL.g_action_request_tbl	  :=   p_action_request_tbl;

--bug 8472737
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CSS: BEFORE CALLS UPDATE_NOTICE ' ) ;
    END IF;

    ASO_ORDER_FEEDBACK_PUB.UPDATE_NOTICE(
        p_api_version => 1.0
      , p_init_msg_list => p_init_msg_list
      , p_commit => l_commit
      , x_return_status => l_return_status
      , x_msg_count => l_msg_count
      , x_msg_data => l_msg_data
      , p_header_rec => OE_SERVICE_UTIL.g_header_rec
      , p_old_header_rec => OE_SERVICE_UTIL.g_old_header_rec
      , p_Header_Adj_tbl => OE_SERVICE_UTIL.g_header_adj_tbl
      , p_old_Header_Adj_tbl => OE_SERVICE_UTIL.g_old_header_adj_tbl
      , p_Header_price_Att_tbl => OE_SERVICE_UTIL.g_header_price_att_tbl
      , p_old_Header_Price_Att_tbl => OE_SERVICE_UTIL.g_old_header_price_att_tbl
      , p_Header_Adj_Att_tbl => OE_SERVICE_UTIL.g_header_adj_att_tbl
      , p_old_Header_Adj_Att_tbl => OE_SERVICE_UTIL.g_old_header_adj_att_tbl
      , p_Header_Adj_Assoc_tbl => OE_SERVICE_UTIL.g_header_adj_assoc_tbl
      , p_old_Header_Adj_Assoc_tbl => OE_SERVICE_UTIL.g_old_header_adj_assoc_tbl
      , p_Header_Scredit_tbl => OE_SERVICE_UTIL.g_header_scredit_tbl
      , p_old_Header_Scredit_tbl => OE_SERVICE_UTIL.g_old_header_scredit_tbl
      , p_line_tbl => OE_SERVICE_UTIL.g_line_tbl
      , p_old_line_tbl => OE_SERVICE_UTIL.g_old_line_tbl
      , p_Line_Adj_tbl => OE_SERVICE_UTIL.g_line_adj_tbl
      , p_old_Line_Adj_tbl => OE_SERVICE_UTIL.g_old_line_adj_tbl
      , p_Line_Price_Att_tbl => OE_SERVICE_UTIL.g_line_price_att_tbl
      , p_old_Line_Price_Att_tbl => OE_SERVICE_UTIL.g_old_line_price_att_tbl
      , p_Line_Adj_Att_tbl => OE_SERVICE_UTIL.g_line_adj_att_tbl
      , p_old_Line_Adj_Att_tbl => OE_SERVICE_UTIL.g_old_line_adj_att_tbl
      , p_Line_Adj_Assoc_tbl => OE_SERVICE_UTIL.g_line_adj_assoc_tbl
      , p_old_Line_Adj_Assoc_tbl => OE_SERVICE_UTIL.g_old_line_adj_assoc_tbl
      , p_Line_Scredit_tbl => OE_SERVICE_UTIL.g_line_scredit_tbl
      , p_old_Line_Scredit_tbl => OE_SERVICE_UTIL.g_old_line_scredit_tbl
      , p_Lot_Serial_tbl => OE_SERVICE_UTIL.g_lot_serial_tbl
      , p_old_Lot_Serial_tbl => OE_SERVICE_UTIL.g_old_lot_serial_tbl
	 , p_action_request_tbl => OE_SERVICE_UTIL.g_action_request_tbl);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'JPN: OC RETURN STATUS IS: ' || L_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CSS: OC RETURN STATUS IS: ' || L_RETURN_STATUS ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOTIFY_OC API - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING NOTIFY_OC API' ) ;
        END IF;
	   Retrieve_OC_Messages;
	   /* OE_DEBUG_PUB.ADD('Notify OC error msg is: ' || substr(x_msg_data, 1,200)); */
         -- For bug 3574480. Modified unepected error to expected error to
         -- support orders of this kind to be rebooked.
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOTIFY_OC API - ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING NOTIFY_OC API' ) ;
        END IF;
     IF l_msg_data is not null THEN
	    /*	  fnd_message.set_encoded(l_msg_data);
		  l_buffer := fnd_message.get;
		  oe_msg_pub.add_text(p_message_text => l_buffer);
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  L_BUFFER , 1 ) ;
		  END IF;*/
	       Retrieve_OC_Messages;
            --RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

   END IF; -- Bypass Notify_OC call
  END IF; -- API exists

EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
    -- For bug 3574480. Modified unexpected errors also to return normal error
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'NOTIFY_OC'
            );
        END IF;
        RAISE FND_API.G_EXC_ERROR;

END NOTIFY_OC;

-- Procedure to Check for the availability of the CRM APIS

Procedure Check_Proc
	(
	p_procedure_name	IN		varchar2,
x_return_status OUT NOCOPY varchar2

	)
is

l_overload	dbms_describe.number_table;
l_position	dbms_describe.number_table;
l_level		dbms_describe.number_table;
l_argumentname	dbms_describe.varchar2_table;
l_datatype	dbms_describe.number_table;
l_defaultvalue	dbms_describe.number_table;
l_inout		dbms_describe.number_table;
l_length	     dbms_describe.number_table;
l_precision	dbms_describe.number_table;
l_scale		dbms_describe.number_table;
l_radix		dbms_describe.number_table;
l_spare		dbms_describe.number_table;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CHECK_PROC API' ) ;
     END IF;
	BEGIN
		dbms_describe.describe_procedure
			(
			p_procedure_name,
			null,
			null,
			l_overload,
			l_position,
			l_level,
			l_argumentname,
			l_datatype,
			l_defaultvalue,
			l_inout,
			l_length,
			l_precision,
			l_scale,
			l_radix,
			l_spare
			);
         x_return_status := FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	END;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CHECK_PROC API' ) ;
     END IF;
END Check_Proc;

PROCEDURE Get_Service_Start      -- added for bug 2897505
(   p_line_id IN NUMBER
  , x_start_date OUT NOCOPY DATE
  , x_return_status OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_init_msg_list    VARCHAR2(1);
l_api_version      NUMBER := 1.0;
l_sql_stat         VARCHAR2(3000);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_end_date     DATE;
l_start_date   DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_START' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE ID PASSED IS ' || to_char(p_line_id) ) ;
  END IF;

  IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
	OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
  END IF;

  IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

   l_sql_stat := '
   Begin
   OKS_OMINT_PUB.GET_SVC_SDATE(
       :p_api_version
     , :p_init_msg_list
     , :p_order_line_id
     , :x_msg_count
     , :x_msg_data
     , :x_return_status
     , :x_start_date
     , :x_end_date);
    END;';

   BEGIN  -- to recover from any unexpected errors, such as OKS_OMINT_PUB.GET_SVC_SDATE not defined
   EXECUTE IMMEDIATE l_sql_stat
	USING IN  l_api_version
	    , IN  l_init_msg_list
	    , IN  p_line_id
	    , OUT l_msg_count
	    , OUT l_msg_data
	    , OUT l_return_status
	    , OUT l_start_date
	    , OUT l_end_date;
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OKS_OMINT_PUB.GET_SVC_SDATE SUCCESSFUL' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'WITH VALUE OF ==>' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'START_DATE ==> ' || TO_CHAR ( L_START_DATE ) ) ;
	END IF;
	x_start_date  := l_start_date;
	x_return_status := l_return_status;
	IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'EXITING GET_SERVICE_START' ) ;
	END IF;
	RETURN;
     END IF;

     x_return_status := l_return_status;
     IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'OKS_OMINT_PUB.GET_SVC_SDATE RETURNED STATUS:'||
	   x_return_status ) ;
     END IF;

     EXCEPTION
       WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
	   oe_debug_pub.add('Unexpected error calling OKS_OMINT_PUB.GET_SVC_SDATE:');
	   oe_debug_pub.add(sqlerrm);
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETURN;
         END IF;
     END;  -- to recover from any unexpected errors

  ELSE
     IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'SERVICE CONTRACTS NOT INSTALLED' ) ;
     END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING GET_SERVICE_START' ) ;
  END IF;
END Get_Service_Start;

--  Procedure : Get_Service_Duration
--

PROCEDURE Get_Service_Duration
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_line_rec IN OUT NOCOPY  OE_ORDER_PUB.Line_Rec_Type
)
IS
l_return_status    VARCHAR2(1);
l_init_msg_list    VARCHAR2(1);
l_api_version      NUMBER := 1.0;
l_sql_stat         VARCHAR2(3000);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_new_end_date     DATE;
l_system_id        NUMBER;
l_service_duration NUMBER;
l_service_period   VARCHAR2(3);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--  oe_debug_pub.Debug_On;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_DURATION' ) ;
  END IF;

  /* The following IF added for 2897505 */
  IF p_x_line_rec.service_reference_type_code = 'GET_SVC_START' THEN
    Get_Service_Start(p_line_id => p_x_line_rec.line_id,
                      x_start_date => p_x_line_rec.service_start_date,
                      x_return_status => x_return_status);
    RETURN;
  END IF;

 /*  OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.GET_DURATION', l_return_status); */


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'JPN: SERVICE DURATION PASSED IS ' || P_X_LINE_REC.SERVICE_DURATION ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'JPN: SERVICE DATE PASSED IS ' || P_X_LINE_REC.SERVICE_START_DATE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'JPN: SERVICE END DATE PASSED IS ' || P_X_LINE_REC.SERVICE_END_DATE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'JPN: SERVICE PERIOD PASSED IS ' || P_X_LINE_REC.SERVICE_PERIOD ) ;
  END IF;
 /* IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

   -- IF Get_Product_Status(515) IN ('I','S') THEN

   -- lkxu, for bug 1701377
   IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
   END IF;

   IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

    l_sql_stat := '
    Begin
    OKS_OMINT_PUB.GET_DURATION(
        :p_api_version
      , :p_init_msg_list
      , :x_msg_count
      , :x_msg_data
      , :x_return_status
      , :p_customer_id
      , :p_system_id
      , :p_service_duration
      , :p_service_period
      , :p_coterm_checked_yn
      , :p_start_date
      , :p_end_date
      , :x_service_duration
      , :x_service_period
	 , :x_new_end_date);
	 END;';

    EXECUTE IMMEDIATE l_sql_stat
	 USING IN l_api_version
	 ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

	 ,     IN p_x_line_rec.sold_to_org_id
	 ,     IN l_system_id
      ,     IN p_x_line_rec.service_duration
      ,     IN p_x_line_rec.service_period
      ,     IN p_x_line_rec.service_coterminate_flag
      ,     IN trunc(p_x_line_rec.service_start_date)
      ,     IN trunc(p_x_line_rec.service_end_date)
, OUT l_service_duration

, OUT l_service_period

, OUT l_new_end_date;


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GET_DURATION RETURN WITH FOLLOWING VALUES OF ==>' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'END_DATE ==> ' || TO_CHAR ( L_NEW_END_DATE ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SERVICE_DURATION ==> ' || TO_CHAR ( L_SERVICE_DURATION ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SERVICE_PERIOD ==> ' || L_SERVICE_PERIOD ) ;
         END IF;
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OKS_OMINT_PUB.GET_DURATION RETURN SUCCESS' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'WITH VALUE OF ==>' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'END_DATE ==> ' || TO_CHAR ( L_NEW_END_DATE ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SERVICE_DURATION ==> ' || TO_CHAR ( L_SERVICE_DURATION ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SERVICE_PERIOD ==> ' || L_SERVICE_PERIOD ) ;
         END IF;
         p_x_line_rec.service_end_date  := l_new_end_date;
         p_x_line_rec.service_duration  := l_service_duration;
         p_x_line_rec.service_period    := l_service_period;
      END IF;
      -- x_return_status := l_return_status;
      IF l_return_status is NULL THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OKS_OMINT_PUB.GET_DURATION NOT RETURNED VALUE' ) ;
         END IF;
         --x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_DURATION' ) ;
      END IF;
   ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OKS_OMINT_PUB.GET_DURATION NOT EXISTS' ) ;
      END IF;
      --x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END Get_Service_Duration;


--  Procedure : Get_Service_Attribute

PROCEDURE Get_Service_Attribute
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_line_rec  IN OUT NOCOPY  OE_ORDER_PUB.Line_Rec_Type
)
IS
l_header_id         NUMBER;
l_line_id           NUMBER;
l_inventory_item_id NUMBER;
l_line_number       NUMBER;
l_shipment_number   NUMBER;
l_option_number     NUMBER;
l_component_number  NUMBER;
l_service_number    NUMBER;
l_service_qty       NUMBER;
l_service_uom       VARCHAR2(3);
l_return_status     VARCHAR2(1);
l_available_yn      VARCHAR2(1);
l_init_msg_list     VARCHAR2(1);
l_api_version       NUMBER := 1.0;
l_sql_stat          VARCHAR2(3000);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_top_model_id      NUMBER;  -- 2331301
l_serviceable       VARCHAR2(1); -- 2331301
l_query_type		VARCHAR2(1); --for ER 5926405,6346045

-- Start of BSA related changes for pack-J by Srini.
-- Added two more variable to dervie the BSA number based on Cust PO.
l_blanket_number         NUMBER;
l_blanket_version_number Number;
l_blanket_line_number    Number;
l_cust_po_number         varchar2(50);
l_request_date           date;
l_fulfilled_quantity	number := null; --5699215

-- End of the Blanket related changes.

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

--  oe_debug_pub.Debug_On;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_ATTRIBUTE' ) ;
      oe_debug_pub.add(  'ENTERING For Blanket '||P_X_LINE_REC.BLANKET_NUMBER) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SERVICE REF TYPE CODE IS:' || P_X_LINE_REC.SERVICE_REFERENCE_TYPE_CODE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SERVICE REF LINE ID:' || P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID ) ;
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_ATTRIBUTE BEFORE IF' ) ;
  END IF;
  IF    (p_x_line_rec.service_reference_type_code is NULL)
    AND (p_x_line_rec.service_reference_line_id is NOT NULL) THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_ATTRIBUTE REF TYPE NULL' ) ;
  END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SERVICE_REFERENCE_TYPE_CODE');
        fnd_message.set_name('ONT','OE_INVALID_SERVICE_REFERENCE_TYPE_CODE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('service_reference_type_code'));
        OE_MSG_PUB.Add;
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
     END IF;
     -- x_return_status := FND_API.G_RET_STS_ERROR;
  ELSIF (p_x_line_rec.service_reference_type_code = 'ORDER') THEN

-- put code for the checking of valid service item
-- first use IS_SERVICE_AVAILABLE API to confirm that the enter
-- service item is valid for the reference item

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_ATTRIBUTE WITH REF AS ORDER' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REF LINEID# ' || TO_CHAR ( P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID ) ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REF LINE# ' || TO_CHAR ( P_X_LINE_REC.SERVICE_REF_LINE_NUMBER ) ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDER# ' || TO_CHAR ( P_X_LINE_REC.SERVICE_REF_ORDER_NUMBER ) ) ;
  END IF;
    BEGIN
     IF p_x_line_rec.service_reference_line_id is null then

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

         SELECT  /* MOAC_SQL_CHANGE */  l.line_number
           , l.shipment_number
           , l.option_number
           , l.component_number
           , l.service_number
           , l.ordered_quantity
           , l.order_quantity_uom
           , l.header_id
           , l.line_id
           , l.inventory_item_id
           , l.blanket_number
           , l.cust_po_number
           , l.fulfilled_quantity --5699215
         INTO   l_line_number
           , l_shipment_number
           , l_option_number
           , l_component_number
           , l_service_number
           , l_service_qty
           , l_service_uom
           , l_header_id
           , l_line_id
           , l_inventory_item_id
           , l_blanket_number
           , l_cust_po_number
		   , l_fulfilled_quantity --5699215
         FROM   oe_order_lines_all l, oe_order_headers h
         WHERE  h.order_number         = p_x_line_rec.service_ref_order_number
         AND    l.line_number          = p_x_line_rec.service_ref_line_number
         AND    l.shipment_number      = p_x_line_rec.service_ref_shipment_number
         AND    NVL(l.option_number,0) = NVL(p_x_line_rec.service_ref_option_number, 0)
         AND    l.header_id            = h.header_id
         AND    rownum                 < 2;
      ELSE
         SELECT /* MOAC_SQL_CHANGE */  l.line_number
	   , l.shipment_number
	   , l.option_number
           , l.component_number
           , l.service_number
           , l.ordered_quantity
           , l.order_quantity_uom
           , l.header_id
           , l.line_id
           , l.inventory_item_id
		   , l.fulfilled_quantity --5699215
         INTO   l_line_number
	   , l_shipment_number
	   , l_option_number
           , l_component_number
           , l_service_number
           , l_service_qty
           , l_service_uom
           , l_header_id
           , l_line_id
           , l_inventory_item_id
		   , l_fulfilled_quantity --5699215
         FROM   oe_order_lines_all l, oe_order_headers h
         WHERE  h.order_number         = p_x_line_rec.service_ref_order_number
         AND    l.line_number          = p_x_line_rec.service_ref_line_number
         AND    l.shipment_number      = p_x_line_rec.service_ref_shipment_number
         AND    NVL(l.option_number,0) = NVL(p_x_line_rec.service_ref_option_number, 0)
         AND    l.header_id            = h.header_id
         AND    rownum                 < 2;
      END IF;

     ELSE

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN SELECT USING REF LINEID#  WITH BLANKET'
                                  || TO_CHAR ( P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID ) ) ;
         END IF;
         SELECT l.line_number
           , l.shipment_number
           , l.option_number
           , l.component_number
           , l.service_number
           , l.ordered_quantity
           , l.order_quantity_uom
           , l.header_id
           , l.line_id
           , l.inventory_item_id
           , l.top_model_line_id -- 2331301
           , NVL(m.serviceable_product_flag, 'N') -- 2331301
           , l.blanket_number
           , l.cust_po_number
		   , l.fulfilled_quantity --5699215
         INTO   l_line_number
           , l_shipment_number
           , l_option_number
           , l_component_number
           , l_service_number
           , l_service_qty
           , l_service_uom
           , l_header_id
           , l_line_id
           , l_inventory_item_id
           , l_top_model_id  -- 2331301
           , l_serviceable  -- 2331301
           , l_blanket_number
           , l_cust_po_number
		   , l_fulfilled_quantity --5699215
         FROM   oe_order_lines l,
             mtl_system_items m
         WHERE  l.line_id    = p_x_line_rec.service_reference_line_id
         AND    l.inventory_item_id = m.inventory_item_id
         AND    m.organization_id = to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));

	--Added for Bug # 4770432 Try to get blanket No from Top Model
	--if unable to get from currently referenced option item
	IF l_blanket_number is NULL AND l_top_model_id is NOT NULL  THEN
	BEGIN
		SELECT blanket_number into l_blanket_number
		FROM oe_order_lines where line_id = l_top_model_id;
	EXCEPTION
		WHEN OTHERS THEN
		l_blanket_number := null;
	END;
	END IF;
	--End of Changes

      ELSE


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SELECT USING REF LINEID# ' || TO_CHAR ( P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID ) ) ;
         END IF;
         SELECT l.line_number
	   , l.shipment_number
	   , l.option_number
           , l.component_number
           , l.service_number
           , l.ordered_quantity
           , l.order_quantity_uom
           , l.header_id
           , l.line_id
           , l.inventory_item_id
           , l.top_model_line_id -- 2331301
           , NVL(m.serviceable_product_flag, 'N') -- 2331301
		   , l.fulfilled_quantity --5699215
         INTO   l_line_number
	   , l_shipment_number
	   , l_option_number
           , l_component_number
           , l_service_number
           , l_service_qty
           , l_service_uom
           , l_header_id
           , l_line_id
           , l_inventory_item_id
           , l_top_model_id  -- 2331301
           , l_serviceable  -- 2331301
		   , l_fulfilled_quantity --5699215
         FROM   oe_order_lines l,
             mtl_system_items m
         WHERE  l.line_id    = p_x_line_rec.service_reference_line_id
         AND    l.inventory_item_id = m.inventory_item_id
         AND    m.organization_id = to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));
      END IF;
     END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECT OF ORDER REF' ) ;
      END IF;

      -- IF OKS_OMINT_PUB.IS_SERVICE_AVAILABLE exists in DB
      -- Then Call it Else Not
  /*    OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.IS_SERVICE_AVAILABLE', l_return_status);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

      -- IF Get_Product_Status(515) IN ('I','S') THEN

      -- lkxu, for bug 1701377
      IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
	   OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
      END IF;

      IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' AND              -- AND added for 2331301
         (NOT(l_top_model_id = l_line_id) OR l_serviceable = 'Y') THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IS SERVICE AVAILABLE IS AVAILABLE - RUN DYNAMIC' ) ;
         END IF;
      -- Check
	 -- Sets customer_id and request date too to fix 1720185

	 -- for bug 2170348
	 -- have modified the dynamic sql and the EXECUTE IMMEDIATE stmt
	 -- beneath

         l_sql_stat :=
         'DECLARE l_check_service_rec OKS_OMINT_PUB.Check_service_rec_type;
         Begin
          l_check_service_rec.product_item_id := :inventory_item_id;
          l_check_service_rec.service_item_id := :service_item_id;
          l_check_service_rec.customer_id := :sold_to_org_id;
          l_check_service_rec.request_date := nvl(:request_date, sysdate);

         OKS_OMINT_PUB.IS_SERVICE_AVAILABLE(
             :p_api_version
         ,   :p_init_msg_list
         ,   :x_msg_count
         ,   :x_msg_data
         ,   :x_return_status
         ,   l_check_service_rec
         ,   :x_available_yn);
	    END;';

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  L_SQL_STAT ) ;
	 END IF;

         EXECUTE IMMEDIATE l_sql_stat   -- added request date to fix 1720185
	   USING    IN l_inventory_item_id
	      ,     IN p_x_line_rec.inventory_item_id
	      ,     IN p_x_line_rec.sold_to_org_id
	      ,     IN p_x_line_rec.request_date
	      ,     IN l_api_version
	      ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

, OUT l_available_yn;


	 -- debug messages added as part of 2170348

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PARAMETERS PASSED TO OKS_OMINT_PUB.IS_SERVICE_AVAILLABLE :' , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' INVENTORY ITEM ID : ' || TO_CHAR ( L_INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' SERVICE ITEM ID : ' || TO_CHAR ( P_X_LINE_REC.INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUSTOMER ID : ' || TO_CHAR ( P_X_LINE_REC.SOLD_TO_ORG_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' REQUEST DATE : ' || TO_CHAR ( P_X_LINE_REC.REQUEST_DATE ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AVAILABLE/RET.STATUS:' || L_AVAILABLE_YN||'/'||L_RETURN_STATUS , 5 ) ;
	 END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AFTER CALL TO SERVICE AVAILABLE API' ) ;
	 END IF;

	 /* OR added for 2282076 */
         IF l_available_yn = 'N' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_ITEM');
            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_Util.Get_Attribute_Name('ordered_item'));
            OE_MSG_PUB.Add;
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;   /* comment on the return statement removed as part of 2271749, though not required to fix that bug */
         END IF; -- Should be a valid service item

      END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'JPN: SERVICE QTY IS' || L_SERVICE_QTY ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'JPN: PRODUCT QTY IS' || P_X_LINE_REC.ORDERED_QUANTITY ) ;
	 END IF;

      IF  p_x_line_rec.ordered_quantity <> Nvl (l_fulfilled_quantity,l_service_qty)THEN --5699215
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM_QTY');
          OE_MSG_PUB.Add;
        /* Fix for the bug 2431953 / 2749740
        ELSIF OE_LINE_UTIL.G_ORDERED_QTY_CHANGE = TRUE THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        Fix ends */
        END IF;
        --x_return_status := FND_API.G_RET_STS_ERROR;
	   -- Make the service quantity same as product quantity
        p_x_line_rec.ordered_quantity :=  Nvl (l_fulfilled_quantity,l_service_qty); --5699215
/* for bug 2068001 */
       -- return;
/* end 2068001 */
      END IF; -- Invalid Service Quantity => Should be equal to Order QTY

      IF l_header_id = p_x_line_rec.header_id THEN
         p_x_line_rec.service_reference_line_id   := l_line_id;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'AKS: LINE NUMBER IN GET SA ' || TO_CHAR ( L_LINE_NUMBER ) ) ;
END IF;
         p_x_line_rec.line_number        := l_line_number;
         p_x_line_rec.shipment_number    := l_shipment_number;
         p_x_line_rec.option_number        := l_option_number;
         p_x_line_rec.component_number   := l_component_number;
         p_x_line_rec.ordered_quantity   := l_service_qty;

         /* Added for Blankets for Pack J */
         if P_X_LINE_REC.BLANKET_NUMBER is null and
            OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' then

            /* Call Blanket Procedure for the Service Item */
            if l_blanket_number is not null and l_cust_po_number is not null
            then
                  oe_default_line.default_blanket_values (
                                   p_blanket_number             => l_blanket_number,
                                   p_cust_po_number             => l_cust_po_number,
				   p_ordered_item_id            => P_X_LINE_REC.ordered_item_id, --bug6826787
                                   p_ordered_item               => P_X_LINE_REC.ordered_item,
                                   p_inventory_item_id          => P_X_LINE_REC.INVENTORY_ITEM_ID,
                                   p_item_identifier_type       => P_X_LINE_REC.item_identifier_type,
                                   p_request_date               => P_X_LINE_REC.request_date,
                                   p_sold_to_org_id             => P_X_LINE_REC.sold_to_org_id,
                                   x_blanket_number             => l_blanket_number,
                                   x_blanket_line_number        => l_blanket_line_number,
                                   x_blanket_version_number     => l_blanket_version_number,
                                   x_blanket_request_date       => l_request_date);
            elsif l_blanket_number is not null then
                  /*disabled this call, since we want to default the BSA, from BSA num as well from Cust PO
                  when a valid BSA is not found in first case.
                  Added by Srini */
                  OE_Default_Line.get_blanket_number_svc_config(
                            p_blanket_number         => l_blanket_number,
                            p_inventory_item_id      => P_X_LINE_REC.INVENTORY_ITEM_ID,
                            x_blanket_line_number    => l_blanket_line_number,
                            x_blanket_version_number => l_blanket_version_number);
            end if;

            P_X_LINE_REC.BLANKET_NUMBER          := l_blanket_number;
            P_X_LINE_REC.blanket_line_number     := l_blanket_line_number;
            P_X_LINE_REC.blanket_version_number  := l_blanket_version_number;
         end if;

	    select nvl(max(service_number)+1,1)
	    into l_service_number
	    from oe_order_lines
	    where header_id = l_header_id
	    and   line_number = l_line_number
	    and   shipment_number = l_shipment_number
	    and   nvl(option_number,0) = nvl(l_option_number,0)
	    and   nvl(component_number,0) = nvl(l_component_number,0)
	    and   item_type_code = 'SERVICE';

	    p_x_line_rec.service_number := l_service_number;

      ELSE

         p_x_line_rec.service_reference_line_id   := l_line_id;
         p_x_line_rec.service_number              := 1;
--         p_x_line_rec.ordered_quantity            := l_service_qty;
         p_x_line_rec.ordered_quantity            := Nvl(l_fulfilled_quantity,l_service_qty); --5699215

         /* Added for Blankets for Pack J */
         if P_X_LINE_REC.BLANKET_NUMBER is null and
            OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
         then

            if l_blanket_number is not null and l_cust_po_number is not null
            then
                 oe_default_line.default_blanket_values (
                                   p_blanket_number             => l_blanket_number,
                                   p_cust_po_number             => l_cust_po_number,
				   p_ordered_item_id            => P_X_LINE_REC.ordered_item_id, --bug6826787
                                   p_ordered_item               => P_X_LINE_REC.ordered_item,
                                   p_inventory_item_id          => P_X_LINE_REC.INVENTORY_ITEM_ID,
                                   p_item_identifier_type       => P_X_LINE_REC.item_identifier_type,
                                   p_request_date               => P_X_LINE_REC.request_date,
                                   p_sold_to_org_id             => P_X_LINE_REC.sold_to_org_id,
                                   x_blanket_number             => l_blanket_number,
                                   x_blanket_line_number        => l_blanket_line_number,
                                   x_blanket_version_number     => l_blanket_version_number,
                                   x_blanket_request_date       => l_request_date);
            elsif l_blanket_number is not null
            then
                 /*disabled this call, since we want to default the BSA, from BSA num as well from Cust PO
                 when a valid BSA is not found in first case.
                 Added by Srini*/

                 OE_Default_Line.get_blanket_number_svc_config(
                            p_blanket_number         => l_blanket_number,
                            p_inventory_item_id      => P_X_LINE_REC.INVENTORY_ITEM_ID,
                            x_blanket_line_number    => l_blanket_line_number,
                            x_blanket_version_number => l_blanket_version_number);
            end if;

            P_X_LINE_REC.BLANKET_NUMBER          := l_blanket_number;
            P_X_LINE_REC.blanket_line_number     := l_blanket_line_number;
            P_X_LINE_REC.blanket_version_number  := l_blanket_version_number;
         end if;

	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'SERVICE NUMBER IS :' || TO_CHAR ( P_X_LINE_REC.SERVICE_NUMBER ) ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'LINE NUMBER IS :'|| TO_CHAR ( P_X_LINE_REC.LINE_NUMBER ) ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'REF LINE ID IS :'|| TO_CHAR ( L_LINE_ID ) ) ;
	    END IF;


      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
      END IF;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg
          (    'G_PKG_NAME'         ,
              'Get_Service_Attribute'
          );
        END IF;

      WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg
          (    'G_PKG_NAME'         ,
              'Get_Service_Attribute'
          );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

  ELSIF (p_x_line_rec.service_reference_type_code = 'CUSTOMER_PRODUCT') THEN
-- put code for the checking of valid service item

    /* Enhancement changes for 1799820. The code references to CS objects */
    /* are being replaced by the new CSI product apis. */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GET SERVICE ATTRIBUTE - TYPE IS CUSTOMER_PRODUCT' ) ;
    END IF;
   --for ER 5926405,6346045 changes start here
   /* IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
     IF NOT (IB_ACTIVE()) THEN
	--3549675 Altered the sql to take bind variables instead of literals
       l_sql_stat := '
        SELECT quantity, unit_of_measure_code
       FROM   cs_customer_products_rg_v
       WHERE  customer_product_id = :b1 AND account_id = :b2 AND rownum < 2 ';
    ELSE
	l_sql_stat := '
        SELECT quantity, unit_of_measure_code
        FROM   csi_instance_accts_rg_v
        WHERE  customer_product_id = :b1 AND account_id = :b2 AND rownum < 2 ';
	*/
	begin
		l_query_type := nvl(OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG_SVC'),'N'); --7120799
	exception
		when others then
			l_query_type := 'N';
	end;
	l_sql_stat := '
				SELECT quantity, unit_of_measure_code
				FROM   csi_instance_accts_rg_v
		        WHERE  customer_product_id = :b1 ';
	if (l_query_type = 'N') THEN
		l_sql_stat := l_sql_stat || ' AND account_id = :b2';
	end if;
	IF (l_query_type = 'Y') THEN
		l_sql_stat := l_sql_stat || ' AND ( account_id in (';
		l_sql_stat := l_sql_stat ||' SELECT cust_account_id';
		l_sql_stat := l_sql_stat ||' FROM hz_cust_acct_relate';
		l_sql_stat := l_sql_stat ||' WHERE related_cust_account_id = :b2 ) OR account_id = :b3 )';
	end if;
	l_sql_stat := l_sql_stat || ' AND rownum < 2 ';

   -- END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE EXECUTE IMMEDIATE FOR CUST ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SQL_STAT ' ||L_SQL_STAT ) ;
      END IF;
      --3549675
  	  /*
	  EXECUTE IMMEDIATE l_sql_stat
	         INTO l_service_qty, l_service_uom
		 USING to_char(p_x_line_rec.service_reference_line_id),
		       to_char(p_x_line_rec.sold_to_org_id) ;
	 */
	 if (l_query_type = 'N' ) then
  	 EXECUTE IMMEDIATE l_sql_stat
	         INTO l_service_qty, l_service_uom
		 USING to_char(p_x_line_rec.service_reference_line_id),
		       to_char(p_x_line_rec.sold_to_org_id) ;
	end if;
	if (l_query_type = 'Y' ) then
		 EXECUTE IMMEDIATE l_sql_stat
	         INTO l_service_qty, l_service_uom
		 USING to_char(p_x_line_rec.service_reference_line_id),
		       to_char(p_x_line_rec.sold_to_org_id),
			   to_char(p_x_line_rec.sold_to_org_id);
	end if;
	if (l_query_type = 'A' ) then
		 EXECUTE IMMEDIATE l_sql_stat
	         INTO l_service_qty, l_service_uom
		 USING to_char(p_x_line_rec.service_reference_line_id);
    end if;
	--for ER 5926405,6346045 changes end here

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER EXECUTE IMMEDIATE FOR CUST ' ) ;
      END IF;



      -- IF OKS_OMINT_PUB.IS_SERVICE_AVAILABLE exists in DB
      -- Then Call it Else Not
    /*  OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.IS_SERVICE_AVAILABLE', l_return_status);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

      -- IF Get_Product_Status(515) IN ('I','S') THEN

      -- lkxu, for bug 1701377
      IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
	   OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
      END IF;

      IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

      -- Check
      /* Removed product_item_id and added customer_id, customer_product_id
	 and request_date to fix 1720185 */

	   -- for bug 2170348

         l_sql_stat :=
         'DECLARE l_check_service_rec OKS_OMINT_PUB.Check_service_rec_type;
         Begin
          l_check_service_rec.service_item_id := :service_item_id;
          l_check_service_rec.customer_id := :sold_to_org_id;
          l_check_service_rec.customer_product_id := :service_reference_line_id;
          l_check_service_rec.request_date := nvl(:request_date, sysdate);

         OKS_OMINT_PUB.IS_SERVICE_AVAILABLE(
             :p_api_version
         ,   :p_init_msg_list
         ,   :x_msg_count
         ,   :x_msg_data
         ,   :x_return_status
         ,   l_check_service_rec
         ,   :x_available_yn);
	    END;';

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE EXECUTE IMMEDIATE FOR CUST-IS_SERVICE_AVAIL' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SQL_STAT ' ||L_SQL_STAT ) ;
         END IF;
         EXECUTE IMMEDIATE l_sql_stat  -- added request_date to fix 1720185
	   USING    IN p_x_line_rec.inventory_item_id
	      ,     IN p_x_line_rec.sold_to_org_id
	      ,     IN p_x_line_rec.service_reference_line_id
	      ,     IN p_x_line_rec.request_date
	      ,     IN l_api_version
	      ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

, OUT l_available_yn;


	 -- debug mesasges added added as part of 2170348
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PARAMETERS PASSED TO OKS_OMINT_PUB.IS_SERVICE_AVAILLABLE :' , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' SERVICE ITEM ID : ' || TO_CHAR ( P_X_LINE_REC.INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUSTOMER ID : ' || TO_CHAR ( P_X_LINE_REC.SOLD_TO_ORG_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUST PROD LINE ID : ' || TO_CHAR ( P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' REQUEST DATE : ' || TO_CHAR ( P_X_LINE_REC.REQUEST_DATE ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AVAILABLE/RET.STATUS:' || L_AVAILABLE_YN||'/'||L_RETURN_STATUS , 5 ) ;
	 END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER EXECUTE IMMEDIATE FOR CUST-IS_SERVICE_AVAIL' ) ;
         END IF;

	 /* OR added for 2282076 */
         IF l_available_yn = 'N' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_ITEM');
            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_Util.Get_Attribute_Name('ordered_item'));
            OE_MSG_PUB.Add;
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;  /* status set to ERROR for 2271749 */
          return;
         END IF; -- Should be a valid service item

      END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'JPN: CUST PROD SERVICE QTY IS ' || L_SERVICE_QTY ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'JPN: CUST PROD ORDERED QTY IS ' || P_X_LINE_REC.ORDERED_QUANTITY ) ;
	 END IF;
      --IF l_service_qty <> p_x_line_rec.ordered_quantity THEN
	  IF  p_x_line_rec.ordered_quantity <> Nvl (l_fulfilled_quantity,l_service_qty)THEN --5699215
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_QUANTITY');
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM_QTY');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                   OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
          OE_MSG_PUB.Add;
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        END IF;
        -- x_return_status := FND_API.G_RET_STS_ERROR;
        --p_x_line_rec.ordered_quantity := l_service_qty;  -- moved in front of RETURN with, but unrelated to, 1720185
		p_x_line_rec.ordered_quantity := Nvl (l_fulfilled_quantity,l_service_qty); --5699215
        return;
      END IF; -- Invalid Service Quantity => Should be equal to Order QTY

      p_x_line_rec.service_number     := 1;
      p_x_line_rec.ordered_quantity   := Nvl (l_fulfilled_quantity,l_service_qty); --5699215
      -- x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
      END IF;
 /* ELSIF    (p_x_line_rec.service_reference_type_code is NULL) OR
		 (p_x_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR) THEN
      OE_DEBUG_PUB.ADD('IN Get_Service_Attribute - where code is NULL');
	 NULL; */
  ELSE
	OE_MSG_PUB.Add_Exc_Msg( 'G_PKG_NAME',
					    'Get_Service_Attribute - Invalid Context');
     -- x_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
     END IF;
  END IF;

END Get_Service_Attribute;


--  Procedure : Get_Service_Duration Overloaded for Form
--

PROCEDURE Get_Service_Duration
( x_return_status OUT NOCOPY VARCHAR2

,   p_line_rec                      IN  OE_OE_FORM_LINE.Line_Rec_Type
, x_line_rec OUT NOCOPY OE_OE_FORM_LINE.Line_Rec_Type

)
IS
l_return_status    VARCHAR2(1);
l_init_msg_list    VARCHAR2(1);
l_api_version      NUMBER := 1.0;
l_sql_stat         VARCHAR2(3000);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_new_end_date     DATE;
l_system_id        NUMBER;
l_service_duration NUMBER;
l_service_period   VARCHAR2(3);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--  oe_debug_pub.Debug_On;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_DURATION' ) ;
  END IF;

  x_line_rec := p_line_rec;
  /* OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.GET_DURATION', l_return_status);
  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

   -- IF Get_Product_Status(515) IN ('I','S') THEN

   -- lkxu, for bug 1701377
   IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
     OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
   END IF;

   IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

    l_sql_stat := '
    Begin
    OKS_OMINT_PUB.GET_DURATION(
        :p_api_version
      , :p_init_msg_list
      , :x_msg_count
      , :x_msg_data
      , :x_return_status
      , :p_customer_id
      , :p_system_id
      , :p_service_duration
      , :p_service_period
      , :p_coterm_checked_yn
      , :p_start_date
      , :p_end_date
      , :x_service_duration
      , :x_service_period
	 , :x_new_end_date);
	 END;';

    EXECUTE IMMEDIATE l_sql_stat
	 USING IN l_api_version
	 ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

	 ,     IN p_line_rec.sold_to_org_id
	 ,     IN l_system_id
      ,     IN p_line_rec.service_duration
      ,     IN p_line_rec.service_period
      ,     IN p_line_rec.service_coterminate_flag
      ,     IN trunc(p_line_rec.service_start_date)
      ,     IN trunc(p_line_rec.service_end_date)
, OUT l_service_duration

, OUT l_service_period

, OUT l_new_end_date;


      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         x_line_rec.service_end_date  := l_new_end_date;
         x_line_rec.service_duration  := l_service_duration;
         x_line_rec.service_period    := l_service_period;
      END IF;
      x_return_status := l_return_status;
      IF l_return_status is NULL THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OKS_OMINT_PUB.GET_DURATION NOT RETURNED VALUE' ) ;
         END IF;
         --x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_DURATION' ) ;
      END IF;
   ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OKS_OMINT_PUB.GET_DURATION NOT EXISTS' ) ;
      END IF;
      --x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END Get_Service_Duration;


--  Procedure : Get_Service_Attribute overloaded for Form

--

PROCEDURE Get_Service_Attribute
( x_return_status OUT NOCOPY VARCHAR2

,   p_line_rec                      IN  OE_OE_FORM_LINE.Line_Rec_Type
, x_line_rec OUT NOCOPY OE_OE_FORM_LINE.Line_Rec_Type

)
IS
l_header_id         NUMBER;
l_line_id           NUMBER;
l_inventory_item_id NUMBER;
l_line_number       NUMBER;
l_shipment_number	NUMBER;
l_option_number	NUMBER;
l_service_number    NUMBER;
l_service_qty       NUMBER;
l_service_uom       VARCHAR2(3);
l_return_status     VARCHAR2(1);
l_available_yn      VARCHAR2(1);
l_init_msg_list     VARCHAR2(1);
l_api_version       NUMBER := 1.0;
l_sql_stat          VARCHAR2(3000);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_top_model_id      NUMBER;  -- 2331301
l_serviceable       VARCHAR2(1); -- 2331301
l_fulfilled_quantity	number := null; --5699215
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

--  oe_debug_pub.Debug_On;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SERVICE_ATTRIBUTE' ) ;
  END IF;

  x_line_rec := p_line_rec;
  IF (p_line_rec.service_reference_type_code is NULL) THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SERVICE_REFERENCE_TYPE_CODE');
        fnd_message.set_name('ONT','OE_INVALID_SERVICE_REFERENCE_TYPE_CODE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('service_reference_type_code'));
        OE_MSG_PUB.Add;
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
  ELSIF (p_line_rec.service_reference_type_code = 'ORDER') THEN

-- put code for the checking of valid service item
-- first use IS_SERVICE_AVAILABLE API to confirm that the enter
-- service item is valid for the reference item

    BEGIN

      SELECT l.line_number
		 , l.shipment_number
		 , l.option_number
           , l.service_number
           , l.ordered_quantity
           , l.order_quantity_uom
           , l.header_id
           , l.line_id
           , l.inventory_item_id
           , l.top_model_line_id  -- 2331301
           , NVL(m.serviceable_product_flag, 'N')
		   , l.fulfilled_quantity --5699215
      INTO   l_line_number
		 , l_shipment_number
		 , l_option_number
           , l_service_number
           , l_service_qty
           , l_service_uom
           , l_header_id
           , l_line_id
           , l_inventory_item_id
           , l_top_model_id   -- 2331301
           , l_serviceable
		   , l_fulfilled_quantity --5699215
      FROM   oe_order_lines l,
             mtl_system_items m
      WHERE  l.line_id    = p_line_rec.service_reference_line_id
      AND    l.inventory_item_id = m.inventory_item_id
      AND    m.organization_id = to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));

      -- IF OKS_OMINT_PUB.IS_SERVICE_AVAILABLE exists in DB
      -- Then Call it Else Not
   /*   OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.IS_SERVICE_AVAILABLE', l_return_status);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

      -- IF Get_Product_Status(515) IN ('I','S') THEN

      -- lkxu, for bug 1701377
      IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
        OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
      END IF;

      IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' AND              -- AND added for 2331301
         (NOT(l_top_model_id = l_line_id) OR l_serviceable = 'Y') THEN


      -- Check
	 -- Sets customer_id and request date too to fix 1720185

	 -- for bug 2170348
         l_sql_stat :=
         'DECLARE l_check_service_rec OKS_OMINT_PUB.Check_service_rec_type;
         Begin
          l_check_service_rec.product_item_id := :inventory_item_id;
          l_check_service_rec.service_item_id := :service_item_id;
          l_check_service_rec.customer_id     := :sold_to_org_id;
          l_check_service_rec.request_date    := nvl(:request_date, sysdate);

         OKS_OMINT_PUB.IS_SERVICE_AVAILABLE(
             :p_api_version
         ,   :p_init_msg_list
         ,   :x_msg_count
         ,   :x_msg_data
         ,   :x_return_status
         ,   l_check_service_rec
	    ,   :x_available_yn);
	    END;';

         EXECUTE IMMEDIATE l_sql_stat   -- added request date to fix 1720185
	      USING IN l_inventory_item_id
	      ,     IN p_line_rec.inventory_item_id
	      ,     IN p_line_rec.sold_to_org_id
	      ,     IN p_line_rec.request_date
	      ,     IN l_api_version
	      ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

, OUT l_available_yn;


	     -- debug messages added as part of 2170348

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PARAMETERS PASSED TO OKS_OMINT_PUB.IS_SERVICE_AVAILLABLE :' , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' INVENTORY ITEM ID : ' || TO_CHAR ( L_INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' SERVICE ITEM ID : ' || TO_CHAR ( P_LINE_REC.INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUSTOMER ID : ' || TO_CHAR ( P_LINE_REC.SOLD_TO_ORG_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' REQUEST DATE : ' || TO_CHAR ( P_LINE_REC.REQUEST_DATE ) , 5 ) ;
	 END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AVAILABLE/RET.STATUS:' || L_AVAILABLE_YN||'/'||L_RETURN_STATUS , 5 ) ;
	 END IF;

	 /* OR added for 2282076 */
         IF l_available_yn = 'N' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_ITEM');
            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_Util.Get_Attribute_Name('ordered_item'));
            OE_MSG_PUB.Add;
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
         END IF; -- Should be a valid service item

      END IF;

--      IF l_service_qty <> p_line_rec.ordered_quantity THEN
	   IF p_line_rec.ordered_quantity <> Nvl (l_fulfilled_quantity,l_service_qty) THEN --5699215
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_QUANTITY');
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM_QTY');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                   OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
          OE_MSG_PUB.Add;
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF; -- Invalid Service Quantity => Should be equal to Order QTY

      IF l_header_id = p_line_rec.header_id THEN
         x_line_rec.service_reference_line_id   := l_line_id;

         x_line_rec.line_number		:= l_line_number;
         x_line_rec.shipment_number		:= l_shipment_number;
         x_line_rec.option_number		:= l_option_number;
         x_line_rec.ordered_quantity   := l_service_qty;

	    select nvl(max(service_number)+1,1)
	    into l_service_number
	    from oe_order_lines
	    where header_id = l_header_id
	    and   line_number = l_line_number
	    and   shipment_number = l_shipment_number
	    and   option_number = l_option_number
	    and   item_type_code = 'SERVICE';

	    x_line_rec.service_number := l_service_number;

      ELSE

         BEGIN
-- aksingh this has to be changed during testing -- see above comment also
           SELECT NVL(MAX(l.line_number)+1,1)
           INTO   l_line_number
           FROM   oe_order_lines l
           WHERE  l.header_id      = p_line_rec.header_id;
         END;

         x_line_rec.service_reference_line_id   := l_line_id;
         x_line_rec.line_number        := l_line_number;
         x_line_rec.service_number     := 1;
         x_line_rec.ordered_quantity   := Nvl(l_fulfilled_quantity,l_service_qty); --5699215

	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'SERVICE NUMBER IS :' || TO_CHAR ( X_LINE_REC.SERVICE_NUMBER ) ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'LINE NUMBER IS :'|| TO_CHAR ( X_LINE_REC.LINE_NUMBER ) ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'LINE ID IS :'|| TO_CHAR ( L_LINE_ID ) ) ;
	    END IF;


      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
      END IF;

    EXCEPTION

      WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg
          (    'G_PKG_NAME'         ,
              'Get_Service_Attribute'
          );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

  ELSIF (p_line_rec.service_reference_type_code = 'CUSTOMER_PRODUCT') THEN
-- put code for the checking of valid service item

   --  IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
   IF NOT (IB_ACTIVE()) THEN
     l_sql_stat := '
        SELECT quantity
             , unit_of_measure_code
        FROM   cs_customer_products_rg_v
        WHERE  customer_product_id    = p_line_rec.service_reference_line_id
	AND    rownum                 < 2';
        -- AND    account_id             = p_line_rec.sold_to_org_id Bug 9346182
   ELSE

    l_sql_stat := '
        SELECT quantity
             , unit_of_measure_code
        FROM   csi_instance_accts_rg_v
        WHERE  customer_product_id    = p_line_rec.service_reference_line_id
	AND    rownum                 < 2';
        -- AND    account_id             = p_line_rec.sold_to_org_id Bug 9382602
   END IF;
	 EXECUTE IMMEDIATE l_sql_stat INTO l_service_qty, l_service_uom;


      -- IF OKS_OMINT_PUB.IS_SERVICE_AVAILABLE exists in DB
      -- Then Call it Else Not
    /*  OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.IS_SERVICE_AVAILABLE', l_return_status);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

      -- IF Get_Product_Status(515) IN ('I','S') THEN

      -- lkxu, for bug 1701377
      IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
        OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
      END IF;

      IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

      -- Check
      /* Removed product_item_id and added customer_id, customer_product_id
	 and request_date to fix 1720185 */

	   -- for bug 2170348

         l_sql_stat :=
         'DECLARE l_check_service_rec OKS_OMINT_PUB.Check_service_rec_type;
         Begin
          l_check_service_rec.service_item_id := :service_item_id;
	  l_check_service_rec.customer_id :=  :sold_to_org_id;
	  l_check_service_rec.customer_product_id := :service_reference_line_id;
	  l_check_service_rec.request_date := nvl(:request_date, sysdate);

         OKS_OMINT_PUB.IS_SERVICE_AVAILABLE(
             :p_api_version
         ,   :p_init_msg_list
         ,   :x_msg_count
         ,   :x_msg_data
         ,   :x_return_status
         ,   l_check_service_rec
	    ,   :x_available_yn);
	    END;';

         EXECUTE IMMEDIATE l_sql_stat  -- added request_date to fix 1720185
	      USING IN p_line_rec.inventory_item_id
	      ,     IN p_line_rec.sold_to_org_id
	      ,     IN p_line_rec.service_reference_line_id
	      ,     IN p_line_rec.request_date
	      ,     IN l_api_version
	      ,     IN l_init_msg_list
, OUT l_msg_count

, OUT l_msg_data

, OUT l_return_status

, OUT l_available_yn;


	  -- debug mesasges added added as part of 2170348
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PARAMETERS PASSED TO OKS_OMINT_PUB.IS_SERVICE_AVAILLABLE :' , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' SERVICE ITEM ID : ' || TO_CHAR ( P_LINE_REC.INVENTORY_ITEM_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUSTOMER ID : ' || TO_CHAR ( P_LINE_REC.SOLD_TO_ORG_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' CUST PROD LINE ID : ' || TO_CHAR ( P_LINE_REC.SERVICE_REFERENCE_LINE_ID ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' REQUEST DATE : ' || TO_CHAR ( P_LINE_REC.REQUEST_DATE ) , 5 ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AVAILABLE/RET.STATUS:' || L_AVAILABLE_YN||'/'||L_RETURN_STATUS , 5 ) ;
	 END IF;

	 /* OR added for 2282076 */
         IF l_available_yn = 'N' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_ITEM');
            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_Util.Get_Attribute_Name('ordered_item'));
            OE_MSG_PUB.Add;
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
         END IF; -- Should be a valid service item

      END IF;

--      IF l_service_qty <> p_line_rec.ordered_quantity THEN
	  IF p_line_rec.ordered_quantity <> Nvl (l_fulfilled_quantity,l_service_qty) THEN--5699215
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_QUANTITY');
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SERV_ITEM_QTY');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                   OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
          OE_MSG_PUB.Add;
          OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF; -- Invalid Service Quantity => Should be equal to Order QTY

      x_line_rec.service_number     := 1;
--      x_line_rec.ordered_quantity   := l_service_qty;
	   x_line_rec.ordered_quantity   := Nvl(l_fulfilled_quantity,l_service_qty);--5699215
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
      END IF;
  ELSIF    (p_line_rec.service_reference_type_code is NULL) OR
		 (p_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN GET_SERVICE_ATTRIBUTE - WHERE CODE IS NULL' ) ;
      END IF;
	 NULL;
  ELSE
	OE_MSG_PUB.Add_Exc_Msg( 'G_PKG_NAME',
					    'Get_Service_Attribute - Invalid Context');
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_SERVICE_ATTRIBUTE' ) ;
     END IF;
  END IF;

END Get_Service_Attribute;


PROCEDURE Get_Service_Ref_Line_Id
( x_return_status OUT NOCOPY VARCHAR2

,   p_order_number                  IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_shipment_number               IN  NUMBER
,   p_option_number                 IN  NUMBER
, x_reference_line_id OUT NOCOPY NUMBER

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_SERVICE_REF_LINE_ID' ) ;
    END IF;

    If p_order_number is not null and
	  p_line_number is not null and
       p_shipment_number is not null Then

       SELECT  /* MOAC_SQL_CHANGE */  l.line_id
       INTO     x_reference_line_id
       FROM     oe_order_lines_all l, oe_order_headers h
       WHERE    h.order_number     = p_order_number
       AND      h.header_id        = l.header_id
       AND      l.line_number      = p_line_number
       AND      l.shipment_number  = p_shipment_number
       AND      nvl(l.option_number, 0) = nvl(p_option_number, 0)
	  AND      l.item_type_code <> 'SERVICE';
    End If;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING GET_SERVICE_REF_LINE_ID' ) ;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	OE_MSG_PUB.Add_Exc_Msg( 'G_PKG_NAME',
					    'Get_Service_Ref_Line_Id -Invalid Order/Line No.');
/* uncomment later
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_DEBUG_PUB.ADD('Exiting Get_Service_Ref_Line_Id');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*/
END Get_Service_Ref_Line_Id;


PROCEDURE Get_Service_Ref_System_Id
( x_return_status OUT NOCOPY VARCHAR2

,   p_system_number                 IN  VARCHAR2
,   p_customer_id                   IN  NUMBER
, x_reference_system_id OUT NOCOPY NUMBER

)
IS
l_sql_stat        VARCHAR2(250);
l_exists    VARCHAR2(1);
l_reference_system_id  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_SERVICE_REF_SYSTEM_ID' ) ;
    END IF;

  -- IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
  IF NOT (IB_ACTIVE()) THEN
    BEGIN
       SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CS_SYSTEMS_RG_V'
      AND    ROWNUM < 2;
     END;
    ELSE
     BEGIN
      SELECT 'Y'
    INTO   l_exists
    FROM   user_views
    WHERE  view_name = 'CSI_SYSTEMS_RG_V'
    AND    ROWNUM < 2;
   END;
 END IF;

   IF l_exists = 'Y' THEN
--  IF NOT(CSI_UTILITY_GRP.IB_ACTIVE()) THEN
    IF NOT(IB_ACTIVE()) THEN
    l_sql_stat := '
    SELECT   system_id
    FROM     cs_systems_rg_v
    WHERE    customer_id = :l_customer_id
    AND      system      = :l_system_number';
  ELSE

     l_sql_stat := '
    SELECT   system_id
    FROM     csi_systems_rg_v
    WHERE    customer_id = :l_customer_id
    AND      system      = :l_system_number';
  END IF;

    EXECUTE IMMEDIATE l_sql_stat INTO l_reference_system_id
            USING     p_customer_id, p_system_number;

    x_reference_system_id := l_reference_system_id;
  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING GET_SERVICE_REF_SYSTEM_ID' ) ;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	OE_MSG_PUB.Add_Exc_Msg( 'G_PKG_NAME',
					    'Get_Service_Ref_System_Id - Invalid System No.');
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_SERVICE_REF_SYSTEM_ID' ) ;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Service_Ref_System_Id;

PROCEDURE Get_Service_Ref_System_Name
( x_return_status OUT NOCOPY VARCHAR2

,   p_reference_system_id           IN  NUMBER
,   p_customer_id                   IN  NUMBER
, x_system_name OUT NOCOPY VARCHAR2

)
IS
l_sql_stat  VARCHAR2(250);
l_system_name  VARCHAR2(50);
l_exists    VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_SERVICE_REF_SYSTEM_NAME' ) ;
    END IF;

   -- IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
  IF NOT (IB_ACTIVE()) THEN
    BEGIN
       SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CS_SYSTEMS_RG_V'
      AND    ROWNUM < 2;
     END;
    ELSE
     BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CSI_SYSTEMS_RG_V'
      AND    ROWNUM < 2;
    END;
   END IF;

      IF l_exists = 'Y' THEN
      -- IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
        IF NOT (IB_ACTIVE()) THEN
           l_sql_stat := '
		SELECT   NAME
          FROM     cs_systems
          WHERE    system_id = :l_system_id'; /*commented for 4731582
	     AND      customer_id = :l_customer_id';*/
        ELSE
         l_sql_stat := '
		SELECT   NAME
          FROM     csi_systems_vl
          WHERE    system_id = :l_system_id';/*commented for 4731582
	     AND      customer_id = :l_customer_id';*/
        END IF;
         Execute Immediate l_sql_stat Into l_system_name
                 Using p_reference_system_id; /* commented for 4731582, p_customer_id;*/
         x_system_name := l_system_name;
      END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING SUCCESS GET_SERVICE_REF_SYSTEM_NAME' ) ;
         END IF;

Exception
   When others then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_SERVICE_REF_SYSTEM_NAME' ) ;
      END IF;
END Get_Service_Ref_System_Name;

PROCEDURE Get_Service_Ref_Cust_Product
( x_return_status OUT NOCOPY VARCHAR2

,   p_reference_line_id             IN  NUMBER
,   p_customer_id                   IN  NUMBER
, x_cust_product OUT NOCOPY VARCHAR2

)
IS
l_sql_stat  VARCHAR2(250);
l_exists    VARCHAR2(1);
l_cust_product VARCHAR2(50);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_SERVICE_REF_CUST_PRODUCT' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER ID IS ' || P_CUSTOMER_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE ID IS ' || P_REFERENCE_LINE_ID ) ;
    END IF;

   -- IF NOT(CSI_UTILITY_GRP.IB_ACTIVE()) THEN
   IF NOT(IB_ACTIVE()) THEN
      BEGIN
       SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CS_CUSTOMER_PRODUCTS_RG_V'
      AND    ROWNUM < 2;
      END;
    ELSE
     BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CSI_INSTANCE_ACCTS_RG_V'
      AND    ROWNUM < 2;
     END;
   END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER EXISTS' ) ;
         END IF;
      IF l_exists = 'Y' THEN
        -- IF NOT(CSI_UTILITY_GRP.IB_ACTIVE()) THEN
        IF NOT(IB_ACTIVE()) THEN
            l_sql_stat := '
          SELECT   PRODUCT
          FROM     cs_customer_products_rg_v
          WHERE    customer_product_id = :l_customer_product_id';
--	     AND      account_id          = :l_customer_id';  --3572516
        ELSE
         l_sql_stat := '
          SELECT   PRODUCT
          FROM    csi_instance_accts_rg_v
          WHERE    customer_product_id = :l_customer_product_id';
--	     AND      account_id          = :l_customer_id';  --3572516
        END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'BEFORE EXECUTE IMMEDIATE' ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'SQL STATEMENT BEING EXECUTED'|| L_SQL_STAT ) ;
	    END IF;
--3572516 using clause is altered accordingly
         Execute Immediate l_sql_stat Into l_cust_product
                 Using p_reference_line_id;
 --                Using p_reference_line_id, p_customer_id;
         x_cust_product := l_cust_product;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'AFTER EXECUTE IMMEDIATE' ) ;
	    END IF;
      END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING SUCCESS GET_SERVICE_REF_CUST_PRODUCT' ) ;
         END IF;

Exception
   When others then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_SERVICE_REF_CUST_PRODUCT' ) ;
      END IF;
END Get_Service_Ref_Cust_Product;



PROCEDURE Get_Cust_Product_Line_ID
( x_return_status OUT NOCOPY VARCHAR2

,   p_reference_line_id             IN  NUMBER
,   p_customer_id                   IN  NUMBER
, x_cust_product_line_id OUT NOCOPY NUMBER

)
IS
l_sql_stat  VARCHAR2(250);
l_exists    VARCHAR2(1);
l_cust_product VARCHAR2(50);
l_order_line_id NUMBER;
l_query_type VARCHAR2(1);--for ER 5926405,6346045

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_CUST_PRODUCT_LINE_ID' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER ID IS ' || P_CUSTOMER_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE ID IS ' || P_REFERENCE_LINE_ID ) ;
    END IF;

  --  IF NOT(CSI_UTILITY_GRP.IB_ACTIVE()) THEN
  --for ER 5926405,6346045
/*	IF NOT(IB_ACTIVE()) THEN
       BEGIN
        SELECT 'Y'
        INTO   l_exists
        FROM   user_views
        WHERE  view_name = 'CS_CUSTOMER_PRODUCTS_RG_V'
        AND    ROWNUM < 2;
       END;
     ELSE
       BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CSI_INSTANCE_ACCTS_RG_V'
      AND    ROWNUM < 2;
      END;
    END IF;
	*/

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER EXISTS' ) ;
         END IF;
    /*  IF l_exists = 'Y' THEN
       -- IF NOT(CSI_UTILITY_GRP.IB_ACTIVE()) THEN
        IF NOT(IB_ACTIVE()) THEN
         l_sql_stat := '
          SELECT   ORIGINAL_ORDER_LINE_ID
          FROM     cs_customer_products_rg_v
          WHERE    customer_product_id = :l_customer_product_id
	     AND      account_id          = :l_customer_id';
        ELSE
	*/
         l_sql_stat := '
          SELECT   ORIGINAL_ORDER_LINE_ID
          FROM     csi_instance_accts_rg_v
          WHERE    customer_product_id = :l_customer_product_id';
     --	     AND      account_id          = :l_customer_id'; Bug 9346261
     --    END IF;

	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'BEFORE EXECUTE IMMEDIATE' ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'SQL STATEMENT BEING EXECUTED'|| L_SQL_STAT ) ;
	    END IF;

         /*Execute Immediate l_sql_stat Into l_order_line_id
                 Using p_reference_line_id, p_customer_id;
         x_cust_product_line_id := l_order_line_id;
		 */
		begin
			l_query_type := nvl(OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG_SVC'),'N'); --7120799
		exception
			when others then
				l_query_type := 'N';
		end;
		-- if (l_query_type = 'N') then Bug 9831517
			Execute Immediate l_sql_stat Into l_order_line_id
			Using p_reference_line_id; -- Bug 9831517
                /* Using p_reference_line_id, p_customer_id;
		else
			l_order_line_id := NULL;
		end if;*/
	  --for ER 5926405,6346045  changes end heer

		x_cust_product_line_id := l_order_line_id;

	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'AFTER EXECUTE IMMEDIATE' ) ;
	    END IF;
--      END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING SUCCESS GET_CUST_PRODUCT_LINE_ID' ) ;
         END IF;

Exception
   WHEN NO_DATA_FOUND THEN
	-- Added for Bug 6889117 Start
	FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer or Customer Product');
	OE_MSG_PUB.Add;
	-- Added for Bug 6889117 End

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'GET_CUST_PRODUCT_LINE_ID: NO DATA FOUND' ) ;
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN FND_API.G_EXC_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_CUST_PRODUCT_LINE_ID' ) ;
      END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Cust_Product_Line_Id;


PROCEDURE Get_Cust_Prod_RG
( x_return_status OUT NOCOPY VARCHAR2

,   p_customer_id                   IN  NUMBER
, x_srv_cust_prod_tbl OUT NOCOPY OE_SERVICE_UTIL.SRV_CUST_PROD_TBL

)
IS
Type CustProdCurTyp IS REF CURSOR;
cust_cv  CustProdCurTyp;
l_cust_prod_id   NUMBER;
l_cust_prod      VARCHAR2(40);
l_cust_prod_desc VARCHAR2(240);
l_sql_stat  VARCHAR2(250);
l_exists    VARCHAR2(1);
I           NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_CUST_PROD_RG' ) ;
    END IF;

    -- IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
   IF NOT (IB_ACTIVE()) THEN
     BEGIN
       SELECT 'Y'
       INTO   l_exists
       FROM   user_views
       WHERE  view_name = 'CS_CUSTOMER_PRODUCTS_RG_V'
       AND    ROWNUM < 2;
      END;
     ELSE
      BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   user_views
      WHERE  view_name = 'CSI_INSTANCE_ACCTS_RG_V'
      AND    ROWNUM < 2;
     END;
    END IF;

-- lchen add REFERENCE_NUMBER, CURRENT_SERIAL_NUMBER to fix bug 1529961 4/5/01

      IF l_exists = 'Y' AND --  other conditions added for 2225343
          (p_customer_id <> g_customer_id OR
          g_customer_id IS NULL) THEN

          OE_SERVICE_UTIL.l_srv_cust_prod_tbl.DELETE; -- 2225343 end

        --IF NOT (CSI_UTILITY_GRP.IB_ACTIVE()) THEN
        IF NOT (IB_ACTIVE()) THEN
          OPEN cust_cv FOR
         'SELECT   CUSTOMER_PRODUCT_ID, PRODUCT, PRODUCT_DESCRIPTION, REFERENCE_NUMBER, CURRENT_SERIAL_NUMBER
          FROM     cs_customer_products_rg_v
          WHERE    account_id          = :l_customer_id' USING p_customer_id;
       ELSE

        OPEN cust_cv FOR
         'SELECT   CUSTOMER_PRODUCT_ID, PRODUCT, PRODUCT_DESCRIPTION, REFERENCE_NUMBER, CURRENT_SERIAL_NUMBER
          FROM     csi_instance_accts_rg_v
          WHERE    account_id          = :l_customer_id' USING p_customer_id;
       END IF;

        I := 1;

        LOOP
          FETCH cust_cv INTO
                     OE_SERVICE_UTIL.l_srv_cust_prod_tbl(I).customer_product_id,
                     OE_SERVICE_UTIL.l_srv_cust_prod_tbl(I).product,
                     OE_SERVICE_UTIL.l_srv_cust_prod_tbl(I).product_description,
		     OE_SERVICE_UTIL.l_srv_cust_prod_tbl(I).reference_number,
		     OE_SERVICE_UTIL.l_srv_cust_prod_tbl(I).current_serial_number;
          I := I + 1;
          EXIT WHEN cust_cv%NOTFOUND;
        END LOOP;
      END IF;
      x_srv_cust_prod_tbl := OE_SERVICE_UTIL.l_srv_cust_prod_tbl;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING SUCCESS GET_CUST_PROD_RG' ) ;
      END IF;

Exception
   When others then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_CUST_PROD_RG' ) ;
      END IF;

END Get_Cust_Prod_RG;

PROCEDURE Get_Avail_Service_RG
( x_return_status OUT NOCOPY VARCHAR2

,   p_service_rec                   IN  OE_SERVICE_UTIL.T_SERVICE_REC
, x_srv_cust_prod_tbl OUT NOCOPY OE_SERVICE_UTIL.SRV_ITEM_ID_TBL

)
IS
l_sql_stat         VARCHAR2(500);
l_return_status    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(500);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_AVAIL_SERVICE_RG' ) ;
  END IF;

  -- Call Describe_Proc to check for the existance of the CRM's
  -- AVAILABLE_SERVICES API. If exists Then Call it else No Problem.

 /*  OE_SERVICE_UTIL.CHECK_PROC('OKS_OMINT_PUB.OKS_AVAILABLE_SERVICES', l_return_status);
  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */

   -- IF Get_Product_Status(515) IN ('I','S') THEN

   -- lkxu, for bug 1701377
   IF OE_GLOBALS.G_OKS_INSTALLED IS NULL THEN
     OE_GLOBALS.G_OKS_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(515);
   END IF;

   IF OE_GLOBALS.G_OKS_INSTALLED = 'Y' THEN

      -- for bug 2170348

     l_sql_stat := 'Declare
      l_service_rec  OKS_OMINT_PUB.AVAIL_SERVICE_REC_TYPE;
      l_service_tbl  OKS_OMINT_PUB.ORDER_SERVICE_TBL_TYPE;
      Begin
       l_service_rec.product_item_id := :product_item_id;
       l_service_rec.customer_id     := :customer_id;

      OKS_OMINT_PUB.OKS_AVAILABLE_SERVICES(
        1.0
      , NULL
      , :x_msg_count
      , :x_msg_data
      , :x_return_status
      , l_service_rec
      , l_service_tbl);

      OE_SERVICE_UTIL.l_srv_tbl := l_service_tbl; ';

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  L_SQL_STAT ) ;
	END IF;

      Execute Immediate l_sql_stat
	Using p_service_rec.product_item_id, p_service_rec.customer_id,
	l_msg_count, l_msg_data, l_return_status;

      -- debug messages added for bug 2170348

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAMETERS PASSED TO OKS_OMINT_PUB.OKS_AVAILABLE_SERVICES : ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' PRODUCT ITEM ID : ' || TO_CHAR ( P_SERVICE_REC.PRODUCT_ITEM_ID ) ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' CUSTOMER ID : ' || TO_CHAR ( P_SERVICE_REC.CUSTOMER_ID ) ) ;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_AVAIL_SERVICE_RG' ) ;
      END IF;
   END IF;

Exception
   When others then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ERROR GET_AVAIL_SERVICE_RG' ) ;
      END IF;

END Get_Avail_Service_RG;

PROCEDURE Retrieve_OC_Messages IS
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(2000);
   x_msg_data   VARCHAR2(2000);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING RETRIEVE OC MESSAGES' ) ;
    END IF;
    fnd_msg_pub.Count_And_Get
		 (p_count   => l_msg_count,
		  p_data    => l_msg_data
		  );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NO. OF OC MESSAGES :' || L_MSG_COUNT ) ;
   END IF;
   for k in 1 ..l_msg_count loop
	x_msg_data := fnd_msg_pub.get( p_msg_index => k,
							 p_encoded => 'F'
                                  );
     -- For bug 3574480. To show the error reason to the user.
     oe_msg_pub.add_text(p_message_text =>X_MSG_DATA);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( X_MSG_DATA , 1 , 255 ) ) ;
     END IF;
   end loop;
 END;

PROCEDURE Val_Item_Change( p_application_id IN NUMBER,
					  p_entity_short_name in VARCHAR2,
					  p_validation_entity_short_name in VARCHAR2,
					  p_validation_tmplt_short_name in VARCHAR2,
					  p_record_set_tmplt_short_name in VARCHAR2,
                           p_scope in VARCHAR2,
p_result OUT NOCOPY NUMBER ) is



l_exists    VARCHAR2(30);
l_line_id NUMBER := oe_line_security.g_record.line_id;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
Select 'EXISTS' into
   l_exists
   from oe_order_lines_all
   where service_reference_line_id = l_line_id;
	  p_result := 1;

EXCEPTION

    when no_data_found then
	    p_result := 0;

End Val_Item_Change;


PROCEDURE Update_Service_Lines
(p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
x_return_status OUT NOCOPY VARCHAR2

 )
IS

l_line_rec         OE_Order_PUB.Line_Rec_Type;
l_referenced_line_rec OE_Order_PUB.Line_Rec_Type;
i                  pls_integer;
j		         pls_integer;
k                  pls_integer;
l_service_number   NUMBER;

l_new_line_rec 	OE_ORDER_PUB.line_rec_type;
l_old_line_rec		OE_ORDER_PUB.line_rec_type;
l_line_id           NUMBER;
line_not_found	     BOOLEAN;
l_cascade_request_flag BOOLEAN := FALSE; -- for bug 2366503

CURSOR order_lines (p_service_reference_line_id NUMBER) IS
SELECT line_id
FROM oe_order_lines
WHERE p_service_reference_line_id = service_reference_line_id
ORDER BY line_id;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SERVICE_UTIL.NEW_SERVICE_LINES' , 1 ) ;
  END IF;

--lchen fix bug 2027650
   I := p_x_line_tbl.FIRST;
   While I is not null loop

--    l_line_rec := p_x_line_tbl(i);  /*3676393*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'I = ' || I , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OPERATION:' || p_x_line_tbl(i).OPERATION , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SERVICE_REFERENCE_LINE_ID:' || p_x_line_tbl(i).SERVICE_REFERENCE_LINE_ID , 1 ) ;
   END IF;
/*3676393-Altered the l_line_rec to p_x_line_tbl in the below conditions*/
    IF p_x_line_tbl(i).item_type_code = 'SERVICE' AND
      p_x_line_tbl(i).service_reference_type_code = 'ORDER' AND
      p_x_line_tbl(i).service_reference_line_id is NOT NULL AND
  --lchen fix for bug 2017271
       p_x_line_tbl(i).service_reference_line_id <> FND_API.G_MISS_NUM AND
     ( p_x_line_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE  or
          p_x_line_tbl(i).operation= OE_GLOBALS.G_OPR_UPDATE) THEN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN OE_SERVICE_UTIL.UPDATE_SERVICE_LINES.ENTERING OE_SERVICE_UTIL.NEW_SERVICE_LINES' , 1 ) ;
   END IF;

    --  oe_debug_pub.ADD('headerId:' || l_line_rec.header_id , 1);
    --  oe_debug_pub.ADD('line_id:' || l_line_rec.line_id , 1);
    --  oe_debug_pub.ADD('service_reference_line_id:' || l_line_rec.service_reference_line_id , 1);

      l_line_rec := p_x_line_tbl(i);  /*3676393*/

      OE_Line_Util.query_row(
                 p_line_id  => l_line_rec.service_reference_line_id,
	            x_line_rec => l_referenced_line_rec);

      IF l_referenced_line_rec.header_id = l_line_rec.header_id THEN

        OE_Line_Util.query_row(
                 p_line_id  => l_line_rec.line_id,
	            x_line_rec => l_old_line_rec);

	   l_new_line_rec := l_old_line_rec;

	   -- assigning line, shipment and option number
	   l_new_line_rec.line_number := l_referenced_line_rec.line_number;
	   l_new_line_rec.shipment_number := l_referenced_line_rec.shipment_number;
	   l_new_line_rec.option_number := l_referenced_line_rec.option_number;

        -- assigning service number
	   IF l_line_rec.service_number IS NULL THEN

		l_service_number := 1;

		OPEN order_lines(l_line_rec.service_reference_line_id);
		LOOP
		  FETCH order_lines INTO l_line_id;
  			  K := p_x_Line_Tbl.First;
			  line_not_found := TRUE;
			  While (K is not null) AND (line_not_found) loop
				IF (p_x_line_tbl(K).line_id = l_line_id) AND
				   (p_x_line_tbl(K).service_number is NULL) THEN
				   line_not_found := FALSE;
				   p_x_line_tbl(K).service_number := l_service_number;
		    		   l_service_number := l_service_number + 1;
				END IF;
				K := p_x_line_tbl.Next(K);
			  End Loop;
		  EXIT WHEN order_lines%NOTFOUND;
          END LOOP;
		CLOSE order_lines;

	   END IF;
	   l_new_line_rec.service_number := p_x_line_tbl(i).service_number;

        OE_LINE_UTIL.Update_Row(p_line_rec => l_new_line_rec);
	l_cascade_request_flag := TRUE;  -- for bug 2366503

      END IF; /* if header id */

    END IF; /* if service line */
    I := p_x_line_tbl.Next(I);
  END LOOP;

  -- for bug 2366503
  IF ( l_cascade_request_flag ) THEN
     OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
  END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_SERVICE_UTIL.UPDATE_SERVICE_LINES' , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   x_return_status 				:= FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Service_Lines'
            );
        END IF;

END Update_Service_Lines;

/* csheu -- added for bug #1533658 */

Procedure CASCADE_CHANGES
( p_parent_line_id     IN  NUMBER,
  p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
x_return_status OUT NOCOPY VARCHAR2

)

IS

-- process_order in variables
    l_control_rec              OE_GLOBALS.Control_Rec_Type;
    l_header_rec               OE_Order_PUB.Header_Rec_Type;
    l_line_rec                 OE_ORDER_PUB.Line_Rec_Type
                               := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_old_line_tbl             OE_Order_PUB.Line_Tbl_Type
						 := OE_ORDER_PUB.G_MISS_LINE_TBL;
    l_line_tbl                 OE_Order_PUB.Line_Tbl_Type
						 := OE_ORDER_PUB.G_MISS_LINE_TBL;
    l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_line_count               NUMBER;


    l_inventory_item_id    NUMBER;
    l_service_start_date       DATE ;
    l_service_end_date       DATE ;
    l_service_duration     NUMBER;
    l_service_period       VARCHAR2(10);


l_service_reference_line_id   NUMBER;
l_parent_line_rec             OE_ORDER_PUB.Line_Rec_Type;
child_line_id                 NUMBER;
l_line_id                 NUMBER;

-- to get the line_id for all childern for the model

     CURSOR model_children IS
     SELECT l.line_id
     FROM   oe_order_lines l
     WHERE  l.top_model_line_id = l_service_reference_line_id
     AND    l.item_type_code in ('INCLUDED','CLASS','OPTION')
     AND    exists (select null from mtl_system_items mtl where
            mtl.inventory_item_id = l.inventory_item_id and
            mtl.serviceable_product_flag = 'Y');

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTER OE_SERVICE_UTIL.CASCADE_CHANGES' , 1 ) ;
 END IF;

 IF fnd_profile.value('ONT_CASCADE_SERVICE') = 'N' THEN
     /* 3128684 */
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DO NOT CASCADE SERVICES' , 2 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
 END IF;
 IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'DO CASCADE SERVICES' , 2 ) ;
 END IF;

 OE_Line_Util.Lock_Row( p_line_id       => p_parent_line_id
                       ,p_x_line_rec    => l_parent_line_rec
                       ,x_return_status => l_return_status);

 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
 END IF;

 l_service_reference_line_id := l_parent_line_rec.service_reference_line_id;
 l_inventory_item_id := l_parent_line_rec.inventory_item_id;
 l_service_start_date := l_parent_line_rec.service_start_date;
 l_service_end_date := l_parent_line_rec.service_end_date;
 l_service_duration := l_parent_line_rec.service_duration;
 l_service_period := l_parent_line_rec.service_period;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'CSH L_INV_ITEM_ID = ' || TO_CHAR ( L_INVENTORY_ITEM_ID ) , 1 ) ;
 END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CSH L_SERVICE_START_DATE = ' || TO_CHAR ( L_SERVICE_START_DATE , 'DD-MON-YYYY HH24:MI:SS' ) , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CSH L_SERVICE_END_DATE = ' || TO_CHAR ( L_SERVICE_END_DATE , 'DD-MON-YYYY HH24:MI:SS' ) , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CSH L_SERVICE_DURATION = ' || TO_CHAR ( L_SERVICE_DURATION ) , 1 ) ;
      END IF;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'CSH L_SERVICE_PERIOD = ' || L_SERVICE_PERIOD , 1 ) ;
 END IF;


 l_line_count  := 0;
 OPEN model_children ;
 LOOP
   FETCH model_children into child_line_id;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CSH CHILD_LINE_ID = ' || TO_CHAR ( CHILD_LINE_ID ) , 1 ) ;
   END IF;
    EXIT when model_children%NOTFOUND;
   BEGIN
     SELECT LINE_ID
       INTO l_line_id
       FROM OE_ORDER_LINES
      WHERE INVENTORY_ITEM_ID = l_inventory_item_id
        AND service_reference_line_id = child_line_id
        AND item_type_code = 'SERVICE'
--      AND ordered_item IS NULL  This AND commented for 2556516
        AND service_reference_type_code = 'ORDER'
      FOR UPDATE NOWAIT;
    /* moved bellow with 3128684
    EXCEPTION
      WHEN OTHERS THEN
        l_line_id := 0;
    END;
    */

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CSH L_LINE_ID = ' || TO_CHAR ( L_LINE_ID ) , 1 ) ;
      END IF;
      l_line_count := l_line_count + 1;
      l_line_rec   := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_rec.line_id := l_line_id;
      l_line_tbl(l_line_count) := l_line_rec;

    EXCEPTION  -- moved from above for 3128684
      WHEN OTHERS THEN
        NULL; -- replacing l_line_id := 0;
    END;

  END LOOP;

    IF l_line_count = 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_SERVICE_UTIL.CASCADE_CHANGES' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO ROWS TO CASCADE' , 2 ) ;
      END IF;
    RETURN;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO OF LINES TO CASCADE: ' || TO_CHAR ( L_LINE_TBL.COUNT ) , 1 ) ;
    END IF;

    FOR I IN 1..l_line_tbl.count LOOP

      IF l_service_duration is not NULL THEN
        l_line_tbl(I).service_duration := l_service_duration;
      END IF;
      IF l_service_period is not NULL THEN
        l_line_tbl(I).service_period := l_service_period;
      END IF;
      IF l_service_start_date is not NULL THEN
        l_line_tbl(I).service_start_date := l_service_start_date;
      END IF;
      IF l_service_end_date is not NULL THEN
        l_line_tbl(I).service_end_date := l_service_end_date;
      END IF;

      l_line_tbl(I).OPERATION := OE_GLOBALS.G_OPR_UPDATE;

    END LOOP;

    -- Call Process Order to update the record.

    --  Set control flags.
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.process              := FALSE;
    l_control_rec.clear_dependents     := TRUE;

    --  Instruct API to retain its caches

    l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' , 1 ) ;
    END IF;

  --  Call OE_Order_PVT.Process_order

    OE_ORDER_PVT.Lines
    (P_validation_level          => FND_API.G_VALID_LEVEL_NONE
    ,p_control_rec               => l_control_rec
    ,p_x_line_tbl                => l_line_tbl
    ,p_x_old_line_tbl            => l_old_line_tbl
    ,x_return_status             => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE UNEXPECTED ERROR ' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE ERROR ' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start: comment out nocopy for notification project

    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
 jolin end */

    -- Clear Table
	l_line_tbl.DELETE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING UPDATE_SERVICE_FOR_OPTIONS' , 1 ) ;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE EXCEPTION EXE ERROR ' , 1 ) ;
        END IF;
	   x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE EXCEPTION UNEXP ERROR ' , 1 ) ;
        END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE EXCEPTION OTHER ERROR ' , 1 ) ;
        END IF;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
		  OE_MSG_PUB.Add_Exc_Msg
		  (   G_PKG_NAME
            ,  'UPDATE_SERVICE_FOR_OPTIONS'
            );
        END IF;

END CASCADE_CHANGES;


FUNCTION IB_ACTIVE RETURN BOOLEAN
IS
l_exists         VARCHAR2(1);
l_sql_stat       VARCHAR2(250);
l_freeze_flag    VARCHAR2(1) := 'N';
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

--  oe_debug_pub.Debug_On;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IB_ACTIVE' ) ;
  END IF;

/* Following sql is commented for Performance problem
 reported in Bug-2159103 */
/*
   SELECT 'Y'
   INTO l_exists
   FROM all_tables
   where table_name='CSI_INSTALL_PARAMETERS';

   OE_DEBUG_PUB.ADD('l_exists= ' || l_exists ,1);


    IF l_exists = 'Y' THEN */

     l_sql_stat := '
     SELECT freeze_flag
     FROM csi_install_parameters
     WHERE rownum = 1';

     EXECUTE IMMEDIATE l_sql_stat INTO l_freeze_flag;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_FREEZE_FLAG= ' || L_FREEZE_FLAG , 1 ) ;
    END IF;

     IF l_freeze_flag = 'Y' THEN
        return TRUE;
     ELSIF l_freeze_flag is NULL or l_freeze_flag = 'N' THEN
              return FALSE;
     END IF;

   /* Commented for Bug-2159103 */
/*
   ELSE

   OE_DEBUG_PUB.ADD('CSI_UTILITY_GRP.IB_ACTIVE does not exists');

   END IF;
 */

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NO DATA FOUND IN CSI_INSTALL_PARAMETERS' ) ;
          END IF;
          return FALSE;

     WHEN OTHERS THEN

        /* Added for Bug-2159103 */

     if sqlcode = -942 then
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  SQLERRM ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CSI_INSTALL_PARAMETERS DOES NOT EXIST' ) ;
           END IF;
        end if;

       return FALSE;

END IB_ACTIVE;

-- Procedure added for bug 2247331 to update the option
-- numbers for service lines. This procedure would be called
-- from OE_CONFIG_PVT package after a call is made to
-- Change_Columns proc while calling the Process Order API.

PROCEDURE Update_Service_Option_Numbers
( p_top_model_line_id IN NUMBER )
IS
  CURSOR option_lines IS
  SELECT line_id, option_number
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  TYPE num_tbl IS TABLE OF NUMBER;
  l_line_ids num_tbl;
  l_option_numbers num_tbl;

  l_ref_type_code CONSTANT VARCHAR2(5) := 'ORDER';
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SERVICE_UTIL.UPDATE_SERVICE_OPTION_NUMBERS' , 2 ) ;
  END IF;

  OPEN option_lines;
  FETCH option_lines BULK COLLECT INTO l_line_ids, l_option_numbers;
  CLOSE option_lines;

  FORALL i IN 1..l_line_ids.count
      UPDATE oe_order_lines_all
      SET    option_number             = l_option_numbers(i)
      WHERE  service_reference_line_id = l_line_ids(i)
      AND service_reference_type_code  = l_ref_type_code; -- For Bug 3087370

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING UPDATE_SERVICE_OPTION_NUMBERS' , 2 ) ;
  END IF;

END;

END OE_SERVICE_UTIL;

/
