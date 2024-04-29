--------------------------------------------------------
--  DDL for Package Body OE_ORDER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_GRP" AS
/* $Header: OEXGORDB.pls 120.16.12010000.3 2009/01/02 08:36:25 smanian ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_GRP';

-- Local procedure: Control_Rec_For_Service_Level
PROCEDURE Control_Rec_For_Service_Level
( p_api_service_level		IN VARCHAR2
, p_control_rec			IN OE_GLOBALS.Control_Rec_Type
, p_validation_level		IN VARCHAR2
, x_control_rec			OUT NOCOPY /* file.sql.39 change */ OE_GLOBALS.Control_Rec_Type
, x_validation_level		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
BEGIN

	IF  p_control_rec.controlled_operation THEN
		x_control_rec.process_partial 	:= p_control_rec.process_partial;
	END IF;

	IF p_api_service_level = OE_GLOBALS.G_CHECK_SECURITY_ONLY THEN

		x_control_rec.controlled_operation	:= TRUE;
		x_control_rec.check_security		:= TRUE;
                -- Bug 2988993 => clear_dependents should also be FALSE
                -- if default attributes should be FALSE
		x_control_rec.clear_dependents          := FALSE;
		x_control_rec.default_attributes	:= FALSE;
		x_control_rec.change_attributes		:= FALSE;
		x_control_rec.validate_entity		:= FALSE;
		x_control_rec.write_to_db		:= FALSE;
		x_control_rec.process			:= FALSE;

		x_validation_level			:= FND_API.G_VALID_LEVEL_NONE;

	ELSIF p_api_service_level = OE_GLOBALS.G_VALIDATION_ONLY THEN

		x_control_rec.controlled_operation	:= TRUE;
		x_control_rec.check_security		:= TRUE;
		x_control_rec.default_attributes	:= TRUE;
		x_control_rec.change_attributes		:= TRUE;
		x_control_rec.validate_entity		:= TRUE;
		x_control_rec.write_to_db		:= TRUE;
		x_control_rec.process			:= FALSE;

        -- No check for branch scheduling is needed. Therefore, removing the
        -- check for profile value.
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING   := 'N';


		x_validation_level			:= FND_API.G_VALID_LEVEL_FULL;


	ELSE

		x_control_rec.controlled_operation	:= p_control_rec.controlled_operation;
		x_control_rec.private_call		:= FALSE;

		x_validation_level			:= p_validation_level;

	END IF;

        x_control_rec.require_reason := p_control_rec.require_reason;

END Control_Rec_For_Service_Level;

--For bug 3390458
Procedure RTrim_data
(  p_x_header_rec IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
 , p_x_line_tbl  IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 , x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
BEGIN

p_x_header_rec.transactional_curr_code:=RTRIM(p_x_header_rec.transactional_curr_code,' ');
p_x_header_rec.packing_instructions:=RTRIM(p_x_header_rec.packing_instructions,' ');
p_x_header_rec.shipping_instructions:=RTRIM(p_x_header_rec.shipping_instructions,' ');
p_x_header_rec.cust_po_number:=RTRIM(p_x_header_rec.cust_po_number,' ');
p_x_header_rec.tp_context:=RTRIM(p_x_header_rec.tp_context,' ');
p_x_header_rec.tp_attribute1:=RTRIM(p_x_header_rec.tp_attribute1,' ');
p_x_header_rec.tp_attribute2:=RTRIM(p_x_header_rec.tp_attribute2,' ');
p_x_header_rec.tp_attribute3:=RTRIM(p_x_header_rec.tp_attribute3,' ');
p_x_header_rec.tp_attribute4:=RTRIM(p_x_header_rec.tp_attribute4,' ');
p_x_header_rec.tp_attribute5:=RTRIM(p_x_header_rec.tp_attribute5,' ');
p_x_header_rec.tp_attribute6:=RTRIM(p_x_header_rec.tp_attribute6,' ');
p_x_header_rec.tp_attribute7:=RTRIM(p_x_header_rec.tp_attribute7,' ');
p_x_header_rec.tp_attribute8:=RTRIM(p_x_header_rec.tp_attribute8,' ');
p_x_header_rec.tp_attribute9:=RTRIM(p_x_header_rec.tp_attribute9,' ');
p_x_header_rec.tp_attribute10:=RTRIM(p_x_header_rec.tp_attribute10,' ');
p_x_header_rec.tp_attribute11:=RTRIM(p_x_header_rec.tp_attribute11,' ');
p_x_header_rec.tp_attribute12:=RTRIM(p_x_header_rec.tp_attribute12,' ');
p_x_header_rec.tp_attribute13:=RTRIM(p_x_header_rec.tp_attribute13,' ');
p_x_header_rec.tp_attribute14:=RTRIM(p_x_header_rec.tp_attribute14,' ');
p_x_header_rec.tp_attribute15:=RTRIM(p_x_header_rec.tp_attribute15,' ');

  FOR I IN 1..p_x_line_tbl.COUNT
  LOOP
     p_x_line_tbl(I).customer_dock_code:=RTRIM(p_x_line_tbl(I).customer_dock_code,' ');
     p_x_line_tbl(I).customer_job:=RTRIM(p_x_line_tbl(I).customer_job,' ');
     p_x_line_tbl(I).cust_production_seq_num:=RTRIM(p_x_line_tbl(I).cust_production_seq_num,' ');
     p_x_line_tbl(I).customer_production_line:=RTRIM(p_x_line_tbl(I).customer_production_line,' ');
     p_x_line_tbl(I).end_item_unit_number:=RTRIM(p_x_line_tbl(I).end_item_unit_number,' ');
     p_x_line_tbl(I).user_item_description:=RTRIM(p_x_line_tbl(I).user_item_description,' ');
     p_x_line_tbl(I).packing_instructions:=RTRIM(p_x_line_tbl(I).packing_instructions,' ');
     p_x_line_tbl(I).shipping_instructions:=RTRIM(p_x_line_tbl(I).shipping_instructions,' ');
     p_x_line_tbl(I).cust_po_number:=RTRIM(p_x_line_tbl(I).cust_po_number,' ');
     p_x_line_tbl(I).cust_model_serial_number:=RTRIM(p_x_line_tbl(I).cust_model_serial_number,' ');
     p_x_line_tbl(I).tp_context:=RTRIM(p_x_line_tbl(I).tp_context,' ');
     p_x_line_tbl(I).tp_attribute1:=RTRIM(p_x_line_tbl(I).tp_attribute1,' ');
     p_x_line_tbl(I).tp_attribute2:=RTRIM(p_x_line_tbl(I).tp_attribute2,' ');
     p_x_line_tbl(I).tp_attribute3:=RTRIM(p_x_line_tbl(I).tp_attribute3,' ');
     p_x_line_tbl(I).tp_attribute4:=RTRIM(p_x_line_tbl(I).tp_attribute4,' ');
     p_x_line_tbl(I).tp_attribute5:=RTRIM(p_x_line_tbl(I).tp_attribute5,' ');
     p_x_line_tbl(I).tp_attribute6:=RTRIM(p_x_line_tbl(I).tp_attribute6,' ');
     p_x_line_tbl(I).tp_attribute7:=RTRIM(p_x_line_tbl(I).tp_attribute7,' ');
     p_x_line_tbl(I).tp_attribute8:=RTRIM(p_x_line_tbl(I).tp_attribute8,' ');
     p_x_line_tbl(I).tp_attribute9:=RTRIM(p_x_line_tbl(I).tp_attribute9,' ');
     p_x_line_tbl(I).tp_attribute10:=RTRIM(p_x_line_tbl(I).tp_attribute10,' ');
     p_x_line_tbl(I).tp_attribute11:=RTRIM(p_x_line_tbl(I).tp_attribute11,' ');
     p_x_line_tbl(I).tp_attribute12:=RTRIM(p_x_line_tbl(I).tp_attribute12,' ');
     p_x_line_tbl(I).tp_attribute13:=RTRIM(p_x_line_tbl(I).tp_attribute13,' ');
     p_x_line_tbl(I).tp_attribute14:=RTRIM(p_x_line_tbl(I).tp_attribute14,' ');
     p_x_line_tbl(I).tp_attribute15:=RTRIM(p_x_line_tbl(I).tp_attribute15,' ');

  END LOOP;

END RTrim_data;


--  Start of Comments
--  API name    Process_Order
--  Type        Group
--  Function    OverLoaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec		    IN  OE_GLOBALS.Control_Rec_Type :=
					OE_GLOBALS.G_MISS_CONTROL_REC
,   p_api_service_level		    IN  VARCHAR2 := OE_GLOBALS.G_ALL_SERVICE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_old_header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl    IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type:=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl      IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_Action_Request_tbl            IN  OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
)
IS
l_org_id                      NUMBER;  -- MOAC
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Order';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_validation_level	VARCHAR2(30);
l_return_status               VARCHAR2(1);
l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_Header_Payment_tbl      OE_Order_PUB.Header_Payment_Tbl_Type;
l_old_Line_Payment_tbl        OE_Order_PUB.Line_Payment_Tbl_Type;

l_aac_header_rec              OE_Order_PUB.Header_Rec_Type;
l_aac_line_tbl                OE_Order_PUB.Line_Tbl_Type;

l_header_rec OE_Order_PUB.Header_Rec_Type;
l_cust_info_tbl OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE;
l_line_tbl  OE_ORDER_PUB.LINE_TBL_TYPE;

I			      NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level  > 0 THEN  /* added for 3677092 */
           oe_debug_pub.add(  'ENTERING OE_ORDER_GRP.PROCESS_ORDER', 0.5) ;
    END IF;

    l_return_status := FND_API.G_RET_STS_SUCCESS; --Nocopy changes

  -- MOAC change
  -- Check if org context has been set before doing any process
  -- If there is no org context set, we stop calling group process order API
  -- and raise an error though we don't do any validation for the org_id.
  l_org_id := MO_GLOBAL.get_current_org_id;
  IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Bug 4129234/ orig bug 3823649 ReSet the Audit Trail Global variables
        OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
        OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG  := 'N';


  -- Bug 3013210 => set a savepoint so that rollbacks can be done for
  -- validation only service level call

  SAVEPOINT Group_Process_Order;


--Added to fix #1566362 as these tables were not getting passed to the PVT API.

l_old_Header_price_Att_tbl := p_old_Header_Price_Att_tbl;
l_old_Header_Adj_Att_tbl   := p_old_Header_Adj_Att_tbl;
l_old_Header_Adj_Assoc_tbl := p_old_Header_Adj_Assoc_tbl;
l_old_Line_price_Att_tbl   := p_old_Line_Price_Att_tbl;
l_old_Line_Adj_Att_tbl     := p_old_Line_Adj_Att_tbl;
l_old_Line_Adj_Assoc_tbl   := p_old_Line_Adj_Assoc_tbl;
x_Header_price_Att_tbl     := p_Header_price_Att_tbl;
x_Header_Adj_Assoc_tbl     := p_Header_Adj_Assoc_tbl;
x_Header_Adj_Att_tbl       := p_Header_Adj_Att_tbl;
x_Line_price_Att_tbl       := p_Line_price_Att_tbl;
x_Line_Adj_Assoc_tbl       := p_Line_Adj_Assoc_tbl;
x_Line_Adj_Att_tbl         := p_Line_Adj_Att_tbl;

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- determine if we should default reason for versioning, for bug 3636884
    IF p_control_rec.require_reason THEN
       -- We are calling from Order Import, don't do anything.
       NULL;
    ELSE
       OE_GLOBALS.G_DEFAULT_REASON := TRUE;
    END IF;


    -- Initialize the control record based on the api_service_level

    Control_Rec_For_Service_Level
		(p_api_service_level 	=> p_api_service_level
		,p_control_rec			=> p_control_rec
		,p_validation_level		=> p_validation_level
		,x_control_rec			=> l_control_rec
		,x_validation_level		=> l_validation_level
		);



--ER7675548
savepoint ADD_CUSTOMER_INFO;

l_cust_info_tbl := p_header_customer_info_tbl;
l_header_rec    := p_header_rec;

 OE_HEADER_UTIL.Get_customer_info_ids
(
 p_header_customer_info_tbl => l_cust_info_tbl,
 p_x_header_rec => l_header_rec,
 x_return_status => x_return_status,
 x_msg_count  => x_msg_count,
 x_msg_data   => x_msg_data
);

IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
        RAISE FND_API.G_EXC_ERROR;
END IF;


l_line_tbl := p_line_tbl;
l_cust_info_tbl := p_line_customer_info_tbl;

OE_LINE_UTIL.Get_customer_info_ids
(
 p_line_customer_info_tbl => l_cust_info_tbl,
 p_x_line_tbl => l_line_tbl,
 x_return_status => x_return_status,
 x_msg_count  => x_msg_count,
 x_msg_data   => x_msg_data
);


IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
        RAISE FND_API.G_EXC_ERROR;
END IF;

--ER7675548

    --  Bug 5555080 Call Value_to_Id before AAC so that if Ids are passed we don't create Account

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => l_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => l_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => x_header_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Perform Value to Id conversion (for old)

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => p_old_header_rec
    ,   p_header_val_rec              => p_old_header_val_rec
    ,   p_Header_Adj_tbl              => p_old_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_old_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_old_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_old_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => p_old_line_tbl
    ,   p_line_val_tbl                => p_old_line_val_tbl
    ,   p_Line_Adj_tbl                => p_old_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_old_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_old_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_old_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => l_old_header_rec
    ,   x_Header_Adj_tbl              => l_old_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => l_old_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => l_old_line_tbl
    ,   x_Line_Adj_tbl                => l_old_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => l_old_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => l_old_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Copy action request tbl to OUT variable

    x_action_request_tbl := p_action_request_tbl;

    -- automatic account creation

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    THEN

       automatic_account_creation(p_header_rec     => x_header_rec,
				  p_header_val_rec => p_header_val_rec,
				  p_line_tbl       => x_line_tbl,
				  p_line_val_tbl   => p_line_val_tbl,
				  x_header_rec     => x_header_rec,
				  x_line_tbl       => x_line_tbl,
				  x_return_status  => x_return_status,
				  x_msg_count      => x_msg_count,
				  x_msg_data       => x_msg_data);
    end if;



   -- added for notification framework
   IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
   END IF;

   --added for bug 3390458
   IF p_rtrim_data ='Y'
   THEN
      RTrim_data
          (  p_x_header_rec => x_header_rec
           , p_x_line_tbl => x_line_tbl
           , x_return_status =>x_return_status);

   END IF;

   -- added for bug 5001819
   -- need to supress defaulting of credit card when trxn_extension_id is passed
   I := x_Header_Payment_tbl.FIRST;

   WHILE I IS NOT NULL LOOP
     IF x_Header_Payment_tbl(I).payment_type_code = 'CREDIT_CARD'
       AND x_Header_Payment_tbl(I).trxn_extension_id IS NOT NULL
       AND NOT OE_GLOBALS.Equal(x_Header_Payment_tbl(I).trxn_extension_id,FND_API.G_MISS_NUM) THEN --bug 5020737
       x_header_rec.credit_card_number := null;
       x_header_rec.credit_card_code := null;
       x_header_rec.credit_card_holder_name := null;
       x_header_rec.credit_card_expiration_date := null;

       exit;   -- exit the loop
     END IF;

     I := x_Header_Payment_tbl.NEXT(I);
   END LOOP;

   OE_GLOBALS.g_validate_desc_flex := p_validate_desc_flex ;--bug4343612
    --  Call OE_Order_PVT.Process_Order
    OE_Order_PVT.Process_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => l_validation_level
--    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => x_header_rec
    ,   p_old_header_rec              => l_old_header_rec
    ,   p_x_Header_Adj_tbl            => x_Header_Adj_tbl
    ,   p_old_Header_Adj_tbl          => l_old_Header_Adj_tbl
    ,   p_x_Header_Price_Att_tbl      => x_Header_Price_Att_tbl
    ,   p_old_Header_Price_Att_tbl    => l_old_Header_Price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl	      => x_Header_Adj_Att_tbl
    ,   p_old_Header_Adj_Att_tbl      => l_old_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => x_Header_Adj_Assoc_tbl
    ,   p_old_Header_Adj_Assoc_tbl    => l_old_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => x_Header_Scredit_tbl
    ,   p_old_Header_Scredit_tbl      => l_old_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => x_Header_Payment_tbl
    ,   p_old_Header_Payment_tbl      => l_old_Header_Payment_tbl
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_old_line_tbl                => l_old_line_tbl
    ,   p_x_Line_Adj_tbl              => x_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl            => l_old_Line_Adj_tbl
    ,   p_x_Line_Price_Att_tbl	      => x_Line_Price_Att_tbl
    ,   p_old_Line_Price_Att_tbl      => l_old_Line_Price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl	      => x_Line_Adj_Att_tbl
    ,   p_old_Line_Adj_Att_tbl	      => l_old_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl	      => x_Line_Adj_Assoc_tbl
    ,   p_old_Line_Adj_Assoc_tbl      => l_old_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => x_Line_Scredit_tbl
    ,   p_old_Line_Scredit_tbl        => l_old_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => x_Line_Payment_tbl
    ,   p_old_Line_Payment_tbl        => l_old_Line_Payment_tbl
    ,   p_x_Lot_Serial_tbl            => x_Lot_Serial_tbl
    ,   p_old_Lot_Serial_tbl          => l_old_Lot_Serial_tbl
    ,   p_x_Action_Request_tbl        => x_Action_Request_tbl
    );

   --Added for bug 4697870 start
   if x_return_status =FND_API.G_RET_STS_UNEXP_ERROR or x_return_status = FND_API.G_RET_STS_ERROR then
     ROLLBACK TO SAVEPOINT Group_Process_Order;
     OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
     if x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
     elsif x_return_status =FND_API.G_RET_STS_ERROR then
         raise FND_API.G_EXC_ERROR ;
     end if;
   end if;
   --Added for bug 4697870 end
    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => x_header_rec
        ,   p_Header_Adj_tbl              => x_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => x_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => x_Header_Payment_tbl
        ,   p_line_tbl                    => x_line_tbl
        ,   p_Line_Adj_tbl                => x_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => x_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => x_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => x_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

	   -- This is set for validation only mode hence resetting

        -- No check for branch scheduling is needed. Therefore, removing the
        -- check for profile value.

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING   := 'Y';


    -- Bug 3013210 => if service level is validation only, rollback any
    -- DB writes and also clear delayed requests

    IF p_api_service_level = OE_GLOBALS.G_VALIDATION_ONLY THEN

       ROLLBACK TO SAVEPOINT Group_Process_Order;

       OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF; -- End if service level is validation only

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Order;



--  Start of Comments
--  API name    Lock_Order
--  Type        Group
--  Function   Overloaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Order';
l_return_status               VARCHAR2(1);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => p_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => p_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => x_header_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call OE_Order_PVT.Lock_Order

    OE_Order_PVT.Lock_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_x_header_rec                => x_header_rec
    ,   p_x_Header_Adj_tbl            => x_Header_Adj_tbl
    ,   p_x_Header_Price_Att_tbl      => x_Header_Price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl	      => x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => x_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => x_Header_Payment_tbl
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_x_Line_Adj_tbl              => x_Line_Adj_tbl
    ,   p_x_Line_Price_Att_tbl	      => x_Line_Price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl	      => x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl	      => x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => x_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => x_Line_Payment_tbl
    ,   p_x_Lot_Serial_tbl            => x_Lot_Serial_tbl
    );

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => x_header_rec
        ,   p_Header_Adj_tbl              => x_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => x_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => x_Header_Payment_tbl
        ,   p_line_tbl                    => x_line_tbl
        ,   p_Line_Adj_tbl                => x_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => x_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => x_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => x_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Order;


--  Start of Comments
--  API name    Get_Order
--  Type        Public
--  Function    Overloaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order';
l_header_id                   NUMBER := p_header_id;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Standard check for Val/ID conversion

    IF  p_header = FND_API.G_MISS_CHAR
    THEN

        l_header_id := p_header_id;

    ELSIF p_header_id <> FND_API.G_MISS_NUM THEN

        l_header_id := p_header_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        /*l_header_id := OE_Value_To_Id.header
        (   p_header                      => p_header
        );*/

        IF l_header_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                fnd_message.set_name('ONT','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call OE_Order_PVT.Get_Order

    OE_Order_PVT.Get_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_header_id                   => l_header_id
    ,   x_header_rec                  => x_header_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Price_Att_tbl	      => x_Header_Price_Att_tbl
    ,   x_Header_Adj_Att_tbl	      => x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl	      => x_Header_Adj_Assoc_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Price_Att_tbl	      => x_Line_Price_Att_tbl
    ,   x_Line_Adj_Att_tbl	      => x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl	      => x_Line_Adj_Assoc_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    );


    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => x_header_rec
        ,   p_Header_Adj_tbl              => x_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => x_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => x_Header_PAyment_tbl
        ,   p_line_tbl                    => x_line_tbl
        ,   p_Line_Adj_tbl                => x_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => x_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => x_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => x_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Order;


--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
BEGIN

    --  Convert header

    x_header_val_rec := OE_Header_Util.Get_Values(p_header_rec);

    --  Convert Header_Adj

    FOR I IN 1..p_Header_Adj_tbl.COUNT LOOP
        x_Header_Adj_val_tbl(I) :=
            OE_Header_Adj_Util.Get_Values(p_Header_Adj_tbl(I));
    END LOOP;

    --  Convert Header_Scredit

    FOR I IN 1..p_Header_Scredit_tbl.COUNT LOOP
        x_Header_Scredit_val_tbl(I) :=
            OE_Header_Scredit_Util.Get_Values(p_Header_Scredit_tbl(I));
    END LOOP;

    --  Convert Header_Payment

    FOR I IN 1..p_Header_Payment_tbl.COUNT LOOP
        x_Header_Payment_val_tbl(I) :=
            OE_Header_Payment_Util.Get_Values(p_Header_Payment_tbl(I));
    END LOOP;


    --  Convert line

    FOR I IN 1..p_line_tbl.COUNT LOOP
        x_line_val_tbl(I) :=
            OE_Line_Util.Get_Values(p_line_tbl(I));
    END LOOP;

    --  Convert Line_Adj

    FOR I IN 1..p_Line_Adj_tbl.COUNT LOOP
        x_Line_Adj_val_tbl(I) :=
            OE_Line_Adj_Util.Get_Values(p_Line_Adj_tbl(I));
    END LOOP;

    --  Convert Line_Scredit

    FOR I IN 1..p_Line_Scredit_tbl.COUNT LOOP
        x_Line_Scredit_val_tbl(I) :=
            OE_Line_Scredit_Util.Get_Values(p_Line_Scredit_tbl(I));
    END LOOP;

    --  Convert Line_Payment

    FOR I IN 1..p_Line_Payment_tbl.COUNT LOOP
        x_Line_Payment_val_tbl(I) :=
	     OE_Line_Payment_Util.Get_Values(p_Line_Payment_tbl(I));
    END LOOP;

    --  Convert Lot_Serial

    FOR I IN 1..p_Lot_Serial_tbl.COUNT LOOP
        x_Lot_Serial_val_tbl(I) :=
            OE_Lot_Serial_Util.Get_Values(p_Lot_Serial_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
)
IS
l_order_source_id           NUMBER := p_header_rec.order_source_id;
l_orig_sys_document_ref     VARCHAR2(50) :=  p_header_rec.orig_sys_document_ref;
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50) := p_header_rec.change_sequence;
l_source_document_type_id   NUMBER := p_header_rec.source_document_type_id;
l_source_document_id        NUMBER := p_header_rec.source_document_id;
l_source_document_line_id        NUMBER;

l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Scredit_rec            OE_Order_PUB.Line_Scredit_Rec_Type;
l_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_Header_Payment_rec          OE_Order_PUB.Header_Payment_Rec_Type;
l_Line_Payment_rec            OE_Order_PUB.Line_Payment_Rec_Type;

l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert header

    x_header_rec	:= p_header_rec;

        --Setting message context for bug 2829206
        IF p_header_rec.header_Id IS NOT NULL AND
           p_header_rec.header_Id <> FND_API.G_MISS_NUM THEN
           BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = p_header_rec.header_Id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
        END IF;

    OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER'
  	,p_entity_id         		=> p_header_rec.header_id
    	,p_header_id         		=> p_header_rec.header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => l_change_sequence
    	,p_source_document_id		=> l_source_document_id
    	,p_source_document_line_id	=> null
	,p_order_source_id            => l_order_source_id
	,p_source_document_type_id    => l_source_document_type_id);

    OE_Header_Util.Get_Ids
    (   p_x_header_rec                => x_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    );

    IF x_header_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    OE_MSG_PUB.reset_msg_context('HEADER');

    --  Convert Header_Adj

    x_Header_Adj_tbl := p_Header_Adj_tbl;

    l_index := p_Header_Adj_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        --Setting message context for bug 2829206
        IF x_header_Adj_tbl(l_index).header_Id IS NOT NULL AND
           x_header_Adj_tbl(l_index).header_Id <> FND_API.G_MISS_NUM THEN
           BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = x_header_Adj_tbl(l_index).header_Id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
        END IF;

        OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'HEADER_ADJ'
  		,p_entity_id         		=> x_header_Adj_tbl(l_index).price_adjustment_id
    		,p_header_id         		=> x_header_Adj_tbl(l_index).header_Id
        	,p_line_id                      => null
        	,p_order_source_id              => l_order_source_id
        	,p_orig_sys_document_ref        => l_orig_sys_document_ref
        	,p_orig_sys_document_line_ref   => null
        	,p_change_sequence              => l_change_sequence
        	,p_source_document_type_id      => l_source_document_type_id
        	,p_source_document_id           => l_source_document_id
        	,p_source_document_line_id      => null );

        OE_Header_Adj_Util.Get_Ids
        (   p_x_Header_Adj_rec            => x_Header_Adj_tbl(l_index)
        ,   p_Header_Adj_val_rec          => p_Header_Adj_val_tbl(l_index)
        );

        IF x_Header_Adj_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Header_Adj_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('HEADER_ADJ');

    END LOOP;

    --  Convert Header_Scredit

    x_Header_Scredit_tbl := p_Header_Scredit_tbl;

    l_index := p_Header_Scredit_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

         --Setting message context for bug 2829206
         IF x_header_Scredit_tbl(l_index).header_id IS NOT NULL AND
            x_header_Scredit_tbl(l_index).header_id <> FND_API.G_MISS_NUM THEN
            BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = x_header_Scredit_tbl(l_index).header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;

        OE_MSG_PUB.set_msg_context(
	 	p_entity_code			=> 'HEADER_SCREDIT'
  		,p_entity_id         		=> x_header_Scredit_tbl(l_index).sales_credit_id
    		,p_header_id         		=> x_header_Scredit_tbl(l_index).header_Id
    		,p_line_id           		=> null
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> null );

        OE_Header_Scredit_Util.Get_Ids
        (   p_x_Header_Scredit_rec        => x_Header_Scredit_tbl(l_index)
        ,   p_Header_Scredit_val_rec      => p_Header_Scredit_val_tbl(l_index)
        );

        IF x_Header_Scredit_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Header_Scredit_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

    END LOOP;

    --  Convert Header_Payment

    x_Header_Payment_tbl := p_Header_Payment_tbl;

    l_index := p_Header_Payment_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

         --Setting message context for bug 2829206
         IF x_header_Payment_tbl(l_index).header_id IS NOT NULL AND
            x_header_Payment_tbl(l_index).header_id <> FND_API.G_MISS_NUM THEN
            BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = x_header_Payment_tbl(l_index).header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;

        OE_MSG_PUB.set_msg_context(
                p_entity_code                   => 'HEADER_PAYMENT'
                ,p_entity_id                    => x_header_Payment_tbl(l_index).payment_number
                ,p_header_id                    => x_header_Payment_tbl(l_index).header_Id
                ,p_line_id                      => null
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
                ,p_source_document_line_id      => null );

        OE_Header_Payment_Util.Get_Ids
        (   p_x_Header_Payment_rec        => x_Header_Payment_tbl(l_index)
        ,   p_Header_Payment_val_rec      => p_Header_Payment_val_tbl(l_index)
        );

        IF x_Header_Payment_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Header_Payment_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

    END LOOP;

    --  Convert line

    x_line_tbl := p_line_tbl;

    l_index := p_line_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP
        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => x_line_tbl(l_index).line_id
         ,p_header_id                   => x_line_tbl(l_index).header_id
         ,p_line_id                     => x_line_tbl(l_index).line_id
         ,p_orig_sys_document_ref       => x_line_tbl(l_index).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => x_line_tbl(l_index).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => x_line_tbl(l_index).orig_sys_shipment_ref
         ,p_change_sequence             => x_line_tbl(l_index).change_sequence
         ,p_source_document_id          => x_line_tbl(l_index).source_document_id
         ,p_source_document_line_id     => x_line_tbl(l_index).source_document_line_id
         ,p_order_source_id             => x_line_tbl(l_index).order_source_id
         ,p_source_document_type_id     => x_line_tbl(l_index).source_document_type_id);

	   -- Fix bug 1351061: populate the sold_to_org_id on the
	   -- line record from the header record. This is needed as
	   -- the customer related value fields (ship_to_org, bill_to_org
	   -- etc.) are converted to ID fields only if the sold_to_org_id
	   -- is provided.
	   IF nvl(x_line_tbl(l_index).sold_to_org_id,FND_API.G_MISS_NUM)
			 = FND_API.G_MISS_NUM
		 AND nvl(p_line_val_tbl(l_index).sold_to_org,FND_API.G_MISS_CHAR)
			 = FND_API.G_MISS_CHAR
		 AND x_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM
        THEN
		 x_line_tbl(l_index).sold_to_org_id := x_header_rec.sold_to_org_id;
        END IF;

        OE_Line_Util.Get_Ids
        (   p_x_line_rec                  => x_line_tbl(l_index)
        ,   p_line_val_rec                => p_line_val_tbl(l_index)
        );

        IF x_line_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_line_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LINE');

    END LOOP;

    --  Convert Line_Adj

    x_Line_Adj_tbl := p_Line_Adj_tbl;

    l_index := p_Line_Adj_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP
           IF x_Line_Adj_tbl(l_index).line_id IS NOT NULL AND
              x_Line_Adj_tbl(l_index).line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = x_Line_Adj_tbl(l_index).line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_ADJ'
  		,p_entity_id         		=> x_Line_Adj_tbl(l_index).price_adjustment_id
    		,p_header_id         		=> x_Line_Adj_tbl(l_index).header_id
    		,p_line_id           		=> x_Line_Adj_tbl(l_index).line_id
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
                ,p_source_document_line_id      => l_source_document_line_id );

        OE_Line_Adj_Util.Get_Ids
        (   p_x_Line_Adj_rec              => x_Line_Adj_tbl(l_index)
        ,   p_Line_Adj_val_rec            => p_Line_Adj_val_tbl(l_index)
        );

        IF x_Line_Adj_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Line_Adj_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LINE_ADJ');

    END LOOP;

    --  Convert Line_Scredit

    x_Line_Scredit_tbl := p_Line_Scredit_tbl;

    l_index := p_Line_Scredit_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        IF x_Line_Scredit_tbl(l_index).line_id IS NOT NULL AND
           x_Line_Scredit_tbl(l_index).line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = x_Line_Scredit_tbl(l_index).line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

        OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_SCREDIT'
  		,p_entity_id         		=> x_Line_Scredit_tbl(l_index).sales_credit_id
    		,p_header_id         		=> x_Line_Scredit_tbl(l_index).header_id
    		,p_line_id           		=> x_Line_Scredit_tbl(l_index).line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        OE_Line_Scredit_Util.Get_Ids
        (   p_x_Line_Scredit_rec          => x_Line_Scredit_tbl(l_index)
        ,   p_Line_Scredit_val_rec        => p_Line_Scredit_val_tbl(l_index)
        );

        IF x_Line_Scredit_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Line_Scredit_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');

    END LOOP;

    --  Convert Line_Payment

    x_Line_Payment_tbl := p_Line_Payment_tbl;

    l_index := p_Line_Payment_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        IF x_Line_Payment_tbl(l_index).line_id IS NOT NULL AND
           x_Line_Payment_tbl(l_index).line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = x_Line_Payment_tbl(l_index).line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

        OE_MSG_PUB.set_msg_context(
                 p_entity_code                  => 'LINE_PAYMENT'
                ,p_entity_id                    => x_Line_Payment_tbl(l_index).payment_number
                ,p_header_id                    => x_Line_Payment_tbl(l_index).header_id
                ,p_line_id                      => x_Line_Payment_tbl(l_index).line_id
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
                ,p_source_document_line_id      => l_source_document_line_id );

        OE_Line_Payment_Util.Get_Ids
        (   p_x_Line_Payment_rec          => x_Line_Payment_tbl(l_index)
        ,   p_Line_Payment_val_rec        => p_Line_Payment_val_tbl(l_index)
        );

        IF x_Line_Payment_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Line_Payment_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');

    END LOOP;

    --  Convert Lot_Serial

    x_Lot_Serial_tbl := p_Lot_Serial_tbl;

    l_index := p_Lot_Serial_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        IF x_Lot_Serial_tbl(l_index).line_id IS NOT NULL AND
           x_Lot_Serial_tbl(l_index).line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = x_Lot_Serial_tbl(l_index).line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

        OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LOT_SERIAL'
  		,p_entity_id         		=> null
    		,p_header_id         		=> p_header_rec.header_id
    		,p_line_id           		=> x_Lot_Serial_tbl(l_index).line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        OE_Lot_Serial_Util.Get_Ids
        (   p_x_Lot_Serial_rec            => x_Lot_Serial_tbl(l_index)
        ,   p_Lot_Serial_val_rec          => p_Lot_Serial_val_tbl(l_index)
        );

        IF x_Lot_Serial_tbl(l_index).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Lot_Serial_val_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LOT_SERIAL_ID');

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

-- API Name:    Get_Option_Lines
-- Type    :    Group
-- Function
--
-- Pre-reqs
--
-- Parameters
--
-- Version      Current version = 1.0
--              Initial version = 1.0
--
-- Notes
--
-- End of Comments



Procedure Get_Option_Lines
(   p_api_version_number        IN  NUMBER
,   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE
,   p_top_model_line_id         IN  NUMBER
,   x_line_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_Pub.Line_Tbl_Type
,   x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
l_api_version_number       CONSTANT NUMBER := 1.0;
l_api_name                 CONSTANT VARCHAR2(30) := 'Get_Option_Lines';
l_return_status            VARCHAR2(1);
l_top_model_line_id        NUMBER;
l_line_tbl                 OE_Order_PUB.Line_Tbl_Type;

BEGIN

     -- Standard  call to check for API compatibility

		   IF NOT FND_API.Compatible_API_Call
				(   l_api_version_number
			    	,   p_api_version_number
			     ,   l_api_name
			     ,   G_PKG_NAME
			     )
		  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

		  -- Standard check for Val/ID conversion

         IF  p_top_model_line_id <> FND_API.G_MISS_NUM THEN

		   l_top_model_line_id := p_top_model_line_id;

		   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
		   THEN
			  fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
			  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Top Model Line');
			  OE_MSG_PUB.Add;
             END IF;

      ELSE
	   IF l_top_model_line_id = FND_API.G_MISS_NUM THEN
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	       THEN
			 fnd_message.set_name('ONT','Invalid Business Object Value');
			 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Top Model Line');
			 OE_MSG_PUB.Add;
            END IF;
       END IF;

	   RAISE FND_API.G_EXC_ERROR;
     END IF;

	-- Make a call to OE_Config_Util.Query_OPtions
   	OE_Config_Util.Query_Options
	   	(p_top_model_line_id   => l_top_model_line_id
		,x_line_tbl		=> l_line_tbl
		);

     -- Load the OUT parameters

	x_line_tbl   := l_line_tbl;

	-- Set the return status

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Get message count and data

	OE_MSG_PUB.Count_And_Get
	(  p_count       =>x_msg_count
	,  p_data        =>x_msg_data
	);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;

      -- Get message count and data

	  OE_MSG_PUB.Count_And_Get
	  (  p_count     => x_msg_count
	  ,  p_data      => x_msg_data
	  );

	   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		  --  Get message count and data
		   OE_MSG_PUB.Count_And_Get
		   (  p_count      =>  x_msg_count
		   ,  p_data       =>  x_msg_data
		   );

        WHEN OTHERS THEN

		 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		 THEN
                OE_MSG_PUB.Add_Exc_Msg
			 (   G_PKG_NAME
			 ,   'Get_Option_Lines'
			 );
          END IF;

		-- Get message count and data
		 OE_MSG_PUB.Count_And_Get
		 (  p_count    => x_msg_count
		 ,  p_data     => x_msg_data
		 );

END Get_Option_Lines;

 -- Existing APIs Calling the New APIs with Payments

PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec		    IN  OE_GLOBALS.Control_Rec_Type :=
					OE_GLOBALS.G_MISS_CONTROL_REC
,   p_api_service_level		    IN  VARCHAR2 := OE_GLOBALS.G_ALL_SERVICE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                       OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_Action_Request_tbl            IN  OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Order';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_validation_level	VARCHAR2(30);
l_return_status               VARCHAR2(1);
l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
x_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl      OE_Order_PUB.Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl        OE_Order_PUB.Line_Payment_Val_Tbl_Type;
I			      NUMBER;

BEGIN

     l_return_status := FND_API.G_RET_STS_SUCCESS;  --Nocopy changes

Process_Order
(   p_api_version_number            => p_api_version_number
,   p_init_msg_list                 => p_init_msg_list
,   p_return_values                 =>  p_return_values
,   p_commit                        => p_commit
,   p_validation_level              => p_validation_level
,   p_control_rec                   => p_control_rec
,   p_api_service_level             => p_api_service_level
,   x_return_status                 =>  x_return_status
,   x_msg_count                     =>  x_msg_count
,   x_msg_data                      => x_msg_data
,   p_header_rec                    =>  p_header_rec
,   p_old_header_rec                => p_old_header_rec
,   p_header_val_rec                => p_header_val_rec
,   p_old_header_val_rec            =>  p_old_header_val_rec
,   p_Header_Adj_tbl                => p_Header_Adj_tbl
,   p_old_Header_Adj_tbl            =>  p_old_Header_Adj_tbl
,   p_Header_Adj_val_tbl            => p_Header_Adj_val_tbl
,   p_old_Header_Adj_val_tbl        =>  p_old_Header_Adj_val_tbl
,   p_Header_price_Att_tbl          =>  p_Header_price_Att_tbl
,   p_old_Header_Price_Att_tbl      =>   p_old_Header_Price_Att_tbl
,   p_Header_Adj_Att_tbl            =>  p_Header_Adj_Att_tbl
,   p_old_Header_Adj_Att_tbl        => p_old_Header_Adj_Att_tbl
,   p_Header_Adj_Assoc_tbl          => p_Header_Adj_Assoc_tbl
,   p_old_Header_Adj_Assoc_tbl      => p_old_Header_Adj_Assoc_tbl
,   p_Header_Scredit_tbl            => p_Header_Scredit_tbl
,   p_old_Header_Scredit_tbl        => p_old_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl        => p_Header_Scredit_val_tbl
,   p_old_Header_Scredit_val_tbl    => p_old_Header_Scredit_val_tbl
,   p_Header_Payment_tbl            => OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        => OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        => OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl    => OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      => p_line_tbl
,   p_old_line_tbl                  => p_old_line_tbl
,   p_line_val_tbl               => p_line_val_tbl
,   p_old_line_val_tbl       => p_old_line_val_tbl
,   p_Line_Adj_tbl             => p_Line_Adj_tbl
,   p_old_Line_Adj_tbl      => p_old_Line_Adj_tbl
,   p_Line_Adj_val_tbl       => p_Line_Adj_val_tbl
,   p_old_Line_Adj_val_tbl    => p_old_Line_Adj_val_tbl
,   p_Line_price_Att_tbl          => p_Line_price_Att_tbl
,   p_old_Line_Price_Att_tbl   => p_old_Line_Price_Att_tbl
,   p_Line_Adj_Att_tbl            => p_Line_Adj_Att_tbl
,   p_old_Line_Adj_Att_tbl    => p_old_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl       => p_Line_Adj_Assoc_tbl
,   p_old_Line_Adj_Assoc_tbl    => p_old_Line_Adj_Assoc_tbl
,   p_Line_Scredit_tbl              => p_Line_Scredit_tbl
,   p_old_Line_Scredit_tbl      => p_old_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl       => p_Line_Scredit_val_tbl
,   p_old_Line_Scredit_val_tbl   => p_old_Line_Scredit_val_tbl
,   p_Line_Payment_tbl      =>  OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl  => OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl  => OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl  => OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                => p_Lot_Serial_tbl
,   p_old_Lot_Serial_tbl            => p_old_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl            => p_Lot_Serial_val_tbl
,   p_old_Lot_Serial_val_tbl     => p_old_Lot_Serial_val_tbl
,   p_action_request_tbl            => p_action_request_tbl
,   p_rtrim_data                   =>p_rtrim_data
,   x_header_rec                    => x_header_rec
,   x_header_val_rec            => x_header_val_rec
,   x_Header_Adj_tbl          => x_Header_Adj_tbl
,   x_Header_Adj_val_tbl    => x_Header_Adj_val_tbl
,   x_Header_price_Att_tbl   => x_Header_price_Att_tbl
,   x_Header_Adj_Att_tbl     => x_Header_Adj_Att_tbl
,   x_Header_Adj_Assoc_tbl    => x_Header_Adj_Assoc_tbl
,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
,   x_Header_Scredit_val_tbl  => x_Header_Scredit_val_tbl
,   x_Header_Payment_tbl     => x_Header_Payment_tbl
,   x_Header_Payment_val_tbl  => x_Header_Payment_val_tbl
,   x_line_tbl                      => x_line_tbl
,   x_line_val_tbl                => x_line_val_tbl
,   x_Line_Adj_tbl              => x_Line_Adj_tbl
,   x_Line_Adj_val_tbl       => x_Line_Adj_val_tbl
,   x_Line_price_Att_tbl    => x_Line_price_Att_tbl
,   x_Line_Adj_Att_tbl      => x_Line_Adj_Att_tbl
,   x_Line_Adj_Assoc_tbl   => x_Line_Adj_Assoc_tbl
,   x_Line_Scredit_tbl         => x_Line_Scredit_tbl
,   x_Line_Scredit_val_tbl   => x_Line_Scredit_val_tbl
,   x_Line_Payment_tbl              => x_Line_Payment_tbl
,   x_Line_Payment_val_tbl      => x_Line_Payment_val_tbl
,   x_Lot_Serial_tbl               => x_Lot_Serial_tbl
,   x_Lot_Serial_val_tbl       => x_Lot_Serial_val_tbl
,   x_action_request_tbl      => x_action_request_tbl
,   p_validate_desc_flex     =>  p_validate_desc_flex   --bug4343612
--ER7675548
,   p_header_customer_info_tbl      =>p_header_customer_info_tbl
,   p_line_customer_info_tbl        =>p_line_customer_info_tbl
);

END Process_Order;

PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Order';
l_return_status               VARCHAR2(1);
x_Header_Payment_tbl            OE_Order_PUB.Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl   OE_Order_PUB.Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl             OE_Order_PUB.Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl      OE_Order_PUB.Line_Payment_Val_Tbl_Type;

BEGIN

   Lock_Order
(   p_api_version_number            => p_api_version_number
,   p_init_msg_list                 => p_init_msg_list
,   p_return_values               =>  p_return_values
,   x_return_status               =>  x_return_status
,   x_msg_count                   =>  x_msg_count
,   x_msg_data                     => x_msg_data
,   p_header_rec                  =>  p_header_rec
,   p_header_val_rec               => p_header_val_rec
,   p_Header_Adj_tbl               => p_Header_Adj_tbl
,   p_Header_Adj_val_tbl            => p_Header_Adj_val_tbl
,   p_Header_price_Att_tbl        =>  p_Header_price_Att_tbl
,   p_Header_Adj_Att_tbl          =>  p_Header_Adj_Att_tbl
,   p_Header_Adj_Assoc_tbl        => p_Header_Adj_Assoc_tbl
,   p_Header_Scredit_tbl           => p_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
,   p_Header_Payment_tbl        => OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl => OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      => p_line_tbl
,   p_line_val_tbl               => p_line_val_tbl
,   p_Line_Adj_tbl             => p_Line_Adj_tbl
,   p_Line_Adj_val_tbl       => p_Line_Adj_val_tbl
,   p_Line_price_Att_tbl          => p_Line_price_Att_tbl
,   p_Line_Adj_Att_tbl            => p_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl       => p_Line_Adj_Assoc_tbl
,   p_Line_Scredit_tbl              => p_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl       => p_Line_Scredit_val_tbl
,   p_Line_Payment_tbl      =>  OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl  => OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                => p_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl            => p_Lot_Serial_val_tbl
,   x_header_rec                    => x_header_rec
,   x_header_val_rec            => x_header_val_rec
,   x_Header_Adj_tbl          => x_Header_Adj_tbl
,   x_Header_Adj_val_tbl    => x_Header_Adj_val_tbl
,   x_Header_price_Att_tbl   => x_Header_price_Att_tbl
,   x_Header_Adj_Att_tbl     => x_Header_Adj_Att_tbl
,   x_Header_Adj_Assoc_tbl    => x_Header_Adj_Assoc_tbl
,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
,   x_Header_Scredit_val_tbl  => x_Header_Scredit_val_tbl
,   x_Header_Payment_tbl     => x_Header_Payment_tbl
,   x_Header_Payment_val_tbl  => x_Header_Payment_val_tbl
,   x_line_tbl                      => x_line_tbl
,   x_line_val_tbl                => x_line_val_tbl
,   x_Line_Adj_tbl              => x_Line_Adj_tbl
,   x_Line_Adj_val_tbl       => x_Line_Adj_val_tbl
,   x_Line_price_Att_tbl    => x_Line_price_Att_tbl
,   x_Line_Adj_Att_tbl      => x_Line_Adj_Att_tbl
,   x_Line_Adj_Assoc_tbl   => x_Line_Adj_Assoc_tbl
,   x_Line_Scredit_tbl         => x_Line_Scredit_tbl
,   x_Line_Scredit_val_tbl   => x_Line_Scredit_val_tbl
,   x_Line_Payment_tbl              => x_Line_Payment_tbl
,   x_Line_Payment_val_tbl      => x_Line_Payment_val_tbl
,   x_Lot_Serial_tbl               => x_Lot_Serial_tbl
,   x_Lot_Serial_val_tbl       => x_Lot_Serial_val_tbl
);

END Lock_Order;

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order';
l_header_id                   NUMBER := p_header_id;
x_Header_Payment_tbl            OE_Order_PUB.Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl   OE_Order_PUB.Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl             OE_Order_PUB.Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl      OE_Order_PUB.Line_Payment_Val_Tbl_Type;

BEGIN

   Get_Order
(   p_api_version_number            => p_api_version_number
,   p_init_msg_list                 => p_init_msg_list
,   p_return_values               =>  p_return_values
,   x_return_status               =>  x_return_status
,   x_msg_count                   =>  x_msg_count
,   x_msg_data                     => x_msg_data
,   p_header_id                  =>  p_header_id
,   p_header                        => p_header
,   x_header_rec                    => x_header_rec
,   x_header_val_rec            => x_header_val_rec
,   x_Header_Adj_tbl          => x_Header_Adj_tbl
,   x_Header_Adj_val_tbl    => x_Header_Adj_val_tbl
,   x_Header_price_Att_tbl   => x_Header_price_Att_tbl
,   x_Header_Adj_Att_tbl     => x_Header_Adj_Att_tbl
,   x_Header_Adj_Assoc_tbl    => x_Header_Adj_Assoc_tbl
,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
,   x_Header_Scredit_val_tbl  => x_Header_Scredit_val_tbl
,   x_Header_Payment_tbl     => x_Header_Payment_tbl
,   x_Header_Payment_val_tbl  => x_Header_Payment_val_tbl
,   x_line_tbl                      => x_line_tbl
,   x_line_val_tbl                => x_line_val_tbl
,   x_Line_Adj_tbl              => x_Line_Adj_tbl
,   x_Line_Adj_val_tbl       => x_Line_Adj_val_tbl
,   x_Line_price_Att_tbl    => x_Line_price_Att_tbl
,   x_Line_Adj_Att_tbl      => x_Line_Adj_Att_tbl
,   x_Line_Adj_Assoc_tbl   => x_Line_Adj_Assoc_tbl
,   x_Line_Scredit_tbl         => x_Line_Scredit_tbl
,   x_Line_Scredit_val_tbl   => x_Line_Scredit_val_tbl
,   x_Line_Payment_tbl              => x_Line_Payment_tbl
,   x_Line_Payment_val_tbl      => x_Line_Payment_val_tbl
,   x_Lot_Serial_tbl               => x_Lot_Serial_tbl
,   x_Lot_Serial_val_tbl       => x_Lot_Serial_val_tbl
);
END Get_Order;

PROCEDURE Id_To_Value
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
)
IS
x_Header_Payment_val_tbl   OE_Order_PUB.Header_Payment_Val_Tbl_Type;
x_Line_Payment_val_tbl      OE_Order_PUB.Line_Payment_Val_Tbl_Type;

BEGIN

Id_To_value
(   p_header_rec                  =>  p_header_rec
,   p_Header_Adj_tbl               => p_Header_Adj_tbl
,   p_Header_Scredit_tbl           => p_Header_Scredit_tbl
,   p_Header_Payment_tbl        => OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_line_tbl                      => p_line_tbl
,   p_Line_Adj_tbl             => p_Line_Adj_tbl
,   p_Line_Scredit_tbl              => p_Line_Scredit_tbl
,   p_Line_Payment_tbl      =>  OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Lot_Serial_tbl                => p_Lot_Serial_tbl
,   x_header_val_rec            => x_header_val_rec
,   x_Header_Adj_val_tbl    => x_Header_Adj_val_tbl
,   x_Header_Scredit_val_tbl  => x_Header_Scredit_val_tbl
,   x_Header_Payment_val_tbl  => x_Header_Payment_val_tbl
,   x_line_val_tbl                => x_line_val_tbl
,   x_Line_Adj_val_tbl       => x_Line_Adj_val_tbl
,   x_Line_Scredit_val_tbl   => x_Line_Scredit_val_tbl
,   x_Line_Payment_val_tbl      => x_Line_Payment_val_tbl
,   x_Lot_Serial_val_tbl       => x_Lot_Serial_val_tbl
);

End Id_To_Value;

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
)
IS
l_order_source_id           NUMBER := p_header_rec.order_source_id;
l_orig_sys_document_ref     VARCHAR2(50) :=  p_header_rec.orig_sys_document_ref;
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50) := p_header_rec.change_sequence;
l_source_document_type_id   NUMBER := p_header_rec.source_document_type_id;
l_source_document_id        NUMBER := p_header_rec.source_document_id;
l_source_document_line_id        NUMBER;

l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Scredit_rec            OE_Order_PUB.Line_Scredit_Rec_Type;
l_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
x_Header_Payment_tbl            OE_Order_PUB.Header_Payment_Tbl_Type;
x_Line_Payment_tbl              OE_Order_PUB.Line_Payment_Tbl_Type;
l_index                       BINARY_INTEGER;
BEGIN

Value_To_Id
(   x_return_status               =>  x_return_status
,   p_header_rec                  =>  p_header_rec
,   p_header_val_rec               => p_header_val_rec
,   p_Header_Adj_tbl               => p_Header_Adj_tbl
,   p_Header_Adj_val_tbl            => p_Header_Adj_val_tbl
,   p_Header_Scredit_tbl           => p_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
,   p_Header_Payment_tbl        => OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl => OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      => p_line_tbl
,   p_line_val_tbl               => p_line_val_tbl
,   p_Line_Adj_tbl             => p_Line_Adj_tbl
,   p_Line_Adj_val_tbl       => p_Line_Adj_val_tbl
,   p_Line_Scredit_tbl              => p_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl       => p_Line_Scredit_val_tbl
,   p_Line_Payment_tbl      =>  OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl  => OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                => p_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl            => p_Lot_Serial_val_tbl
,   x_header_rec                    => x_header_rec
,   x_Header_Adj_tbl          => x_Header_Adj_tbl
,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
,   x_Header_Payment_tbl     => x_Header_Payment_tbl
,   x_line_tbl                      => x_line_tbl
,   x_Line_Adj_tbl              => x_Line_Adj_tbl
,   x_Line_Scredit_tbl         => x_Line_Scredit_tbl
,   x_Line_Payment_tbl              => x_Line_Payment_tbl
,   x_Lot_Serial_tbl               => x_Lot_Serial_tbl
);

END Value_To_Id;

PROCEDURE automatic_account_creation(
				     p_header_rec	IN OE_Order_Pub.Header_Rec_Type,
				     p_Header_Val_Rec   IN OE_Order_pub.Header_Val_Rec_type,
				     p_line_tbl		IN OE_Order_Pub.Line_Tbl_Type,
				     p_Line_Val_tbl     IN OE_Order_pub.Line_Val_tbl_Type,
				     x_header_rec	IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type, --bug6278382
				     x_line_tbl		IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type,   --bug6278382
				     x_return_status	OUT NOCOPY VARCHAR2,
				     x_msg_count        OUT NOCOPY NUMBER,
				     x_msg_data         OUT NOCOPY VARCHAR2
				     ) IS

   p_control_rec oe_create_account_info.control_rec_type;
   p_account_tbl oe_create_account_info.account_tbl;
   p_contact_tbl oe_create_account_info.contact_tbl;
   p_site_tbl oe_create_account_info.site_tbl_type;
   p_line_site_tbl oe_create_account_info.site_tbl_type;
   p_party_customer_rec oe_create_account_info.party_customer_rec;

   l_cust_account_role_id number;
   l_multiple_sold_to varchar2(32000);
   l_sold_to_org_id VARCHAR2(80);
   l_sold_to VARCHAR2(360);
   l_customer_name varchar2(360);
   l_account_number varchar2(30);
   l_email_address varchar2(2000);
   l_contact_name varchar2(360);
   l_count number;

   l_message           varchar2(300);
   l_site_tbl_counter number := 1;
   l_create_account boolean  := FALSE;	--do we need to call AAC?
   l_create_hdr_account boolean  := FALSE;	--do we need to call AAC for the header?

   l_line_acct_matched number := 0;
   i number;
   j number;

   l_header_end_cust_exists varchar2(2) :='N';	-- added for bug 4240715

   TYPE line_acct IS RECORD (
			     ship boolean      := FALSE
			     ,ship_value boolean := FALSE
			     ,deliver boolean  := FALSE
			     ,deliver_value boolean := FALSE
			     ,invoice boolean  := FALSE
			     ,invoice_value boolean := FALSE
     			     ,end_customer boolean :=FALSE  -- End Customer Enhancement(bug 4240715)
			     ,end_customer_value boolean :=FALSE
			     );

   type line_acct_needed_tbl is table of line_acct index by binary_integer;
   l_line_acct_needed line_acct_needed_tbl;

   l_debug_level NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   --oe_create_account_info.set_debug_on();

   IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' AAC:Inside Process Order: Automatic Account Creation');
   oe_debug_pub.add(' operation='||p_header_rec.operation);
   END IF;

   /* copy input records to output records */
   x_header_rec := p_header_rec;
   x_line_tbl   := p_line_tbl;

   -- Retrieve the sold_to_org_id if not passed on the header record. This
    -- will be needed by the value_to_id functions for related fields.
    -- For e.g. oe_value_to_id.ship_to_org_id requires sold_to_org_id

   IF p_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
      p_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN

     IF l_debug_level  > 0 THEN
     oe_debug_pub.add('AAC: Selecting Customer Based on old sold_to_org_id');
     END IF;
     SELECT SOLD_TO_ORG_ID
       INTO l_sold_to_org_id
       FROM OE_ORDER_HEADERS
      WHERE HEADER_ID = p_header_rec.header_id;
     x_header_rec.sold_to_org_id := l_sold_to_org_id;
   END IF;



   IF l_debug_level  > 0 THEN
   oe_debug_pub.add('AAC: header_id:'||p_header_rec.header_id);
   oe_debug_pub.add('AAC: sold_to_party_id:'|| p_header_rec.sold_to_party_id);
   oe_debug_pub.add('AAC: sold_to_party_number:'|| p_header_rec.sold_to_party_number);
   oe_debug_pub.add('AAC: sold_to_org_id:'|| p_header_rec.sold_to_org_id);
   oe_debug_pub.add('AAC: l_sold_to_org_id:'|| l_sold_to_org_id);
   END IF;

   /* check to see if we need account creation at all, return ASAP if not{ */
   /* check header level party info */
   -- l_sold_to_org_id is not null for UPDATE case of an Order
   IF l_sold_to_org_id is null then
     IF ((nvl(p_header_rec.sold_to_org_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM
	and ( (p_header_rec.sold_to_party_id is not null or p_header_rec.sold_to_party_number is not null)
	     or nvl(p_header_val_rec.sold_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
       or
	  ((nvl(p_header_rec.sold_to_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
	   and (nvl(p_header_val_Rec.sold_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		or nvl(p_header_Rec.sold_to_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)))
     THEN
       IF l_debug_level  > 0 THEN
       oe_debug_pub.add('AAC: sold_to_org_id/sold_to_contact_id creation needed');
       oe_debug_pub.add('AAC: sold_to_party_id:'|| p_header_rec.sold_to_party_id);
       oe_debug_pub.add('AAC: sold_to_party_number:'|| p_header_rec.sold_to_party_number);
       END IF;
       l_create_account := TRUE;
       l_create_hdr_account := TRUE;
     END IF;
   END IF; -- if l_sold_to_org_id is not null

   l_header_end_cust_exists :='N';	--bug 4240715

   /* check header ship_to party info */
   IF ((nvl(p_header_rec.ship_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (p_header_rec.ship_to_party_id is not null or
    p_header_rec.ship_to_party_number is not null or
    p_header_rec.ship_to_party_site_id is not null or
    p_header_rec.ship_to_party_site_use_id is not null or
    p_header_rec.ship_to_org_contact_id is not null) or
    (nvl(p_header_val_Rec.ship_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.ship_to_zip,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)))
   THEN
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: ship_to sites creation needed');
      oe_debug_pub.add('AAC: ship_to_org_id           :'|| p_header_Rec.ship_to_org_id);
      oe_debug_pub.add('AAC: ship_to_party_id         :'|| p_header_rec.ship_to_party_id);
      oe_debug_pub.add('AAC: ship_to_party_number         :'|| p_header_rec.ship_to_party_number);
      oe_debug_pub.add('AAC: ship_to_party_site_id    :'|| p_header_rec.ship_to_party_site_id);
      oe_debug_pub.add('AAC: ship_to_party_site_use_id:'|| p_header_rec.ship_to_party_site_use_id);
      oe_debug_pub.add('AAC: ship_to_org_contact_id   :'|| p_header_rec.ship_to_org_contact_id);
      oe_debug_pub.add('AAC: ship_to_org              :'|| p_header_val_Rec.ship_to_org);
      oe_debug_pub.add('AAC: ship_to_customer_number  :'|| p_header_val_Rec.ship_to_customer_number_oi);
      oe_debug_pub.add('AAC: ship_to_customer_name  :'|| p_header_val_Rec.ship_to_customer_name_oi);
      oe_debug_pub.add('AAC: ship_to_contact          :'|| p_header_val_Rec.ship_to_contact);
      END IF;

      l_create_account := TRUE;
      l_create_hdr_account := TRUE;

      p_site_tbl(l_site_tbl_counter).p_party_id          := p_header_rec.ship_to_party_id;
      p_site_tbl(l_site_tbl_counter).p_party_site_id     := p_header_rec.ship_to_party_site_id;
      if(p_header_rec.ship_to_org_id = FND_API.G_MISS_NUM)
      then
	 p_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
      else
	 p_site_tbl(l_site_tbl_counter).p_site_use_id    := p_header_rec.ship_to_org_id;
      end if;

      p_site_tbl(l_site_tbl_counter).p_cust_account_role_id := p_header_rec.ship_to_contact_id;
      p_site_tbl(l_site_tbl_counter).p_org_contact_id       := p_header_rec.ship_to_org_contact_id;
      p_site_tbl(l_site_tbl_counter).p_contact_name         := p_header_val_rec.ship_to_contact;

      p_site_tbl(l_site_tbl_counter).p_party_site_use_id := p_header_rec.ship_to_party_site_use_id;
      p_site_tbl(l_site_tbl_counter).p_site_use_code     := 'SHIP_TO';

      --p_site_tbl(l_site_tbl_counter).p_party_name        := p_header_val_Rec.ship_to_org;
      p_site_tbl(l_site_tbl_counter).p_party_name        := p_header_val_Rec.ship_to_customer_name_oi;
      p_site_tbl(l_site_tbl_counter).p_party_number      := p_header_rec.ship_to_party_number;
      p_site_tbl(l_site_tbl_counter).p_cust_account_number := p_header_val_Rec.ship_to_customer_number_oi;

      p_site_tbl(l_site_tbl_counter).p_site_address1       := p_header_val_rec.ship_to_address1 ;
      p_site_tbl(l_site_tbl_counter).p_site_address2 	   := p_header_val_rec.ship_to_address2 ;
      p_site_tbl(l_site_tbl_counter).p_site_address3 	   := p_header_val_rec.ship_to_address3 ;
      p_site_tbl(l_site_tbl_counter).p_site_address4 	   := p_header_val_rec.ship_to_address4 ;
      p_site_tbl(l_site_tbl_counter).p_site_state    	   := p_header_val_rec.ship_to_state    ;
      p_site_tbl(l_site_tbl_counter).p_site_country  	   := p_header_val_rec.ship_to_country  ;
      p_site_tbl(l_site_tbl_counter).p_site_city           := p_header_val_rec.ship_to_city     ;
      p_site_tbl(l_site_tbl_counter).p_site_postal_code    := p_header_val_rec.ship_to_zip      ;

      l_site_tbl_counter := l_site_tbl_counter + 1;
   END IF;

   /* check header deliver_to party info */
   IF ((nvl(p_header_rec.deliver_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (p_header_rec.deliver_to_party_id is not null or
    p_header_rec.deliver_to_party_number is not null or
    p_header_rec.deliver_to_party_site_id is not null or
    p_header_rec.deliver_to_party_site_use_id is not null or
    p_header_rec.deliver_to_org_contact_id is not null) or
    (nvl(p_header_val_Rec.deliver_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.deliver_to_zip,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)))

   THEN
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: deliver_to sites creation needed');
      oe_debug_pub.add('AAC: deliver_to_org_id           :'|| p_header_rec.deliver_to_org_id);
      oe_debug_pub.add('AAC: deliver_to_party_id         :'|| p_header_rec.deliver_to_party_id);
      oe_debug_pub.add('AAC: deliver_to_party_number         :'|| p_header_rec.deliver_to_party_number);
      oe_debug_pub.add('AAC: deliver_to_party_site_id    :'|| p_header_rec.deliver_to_party_site_id);
      oe_debug_pub.add('AAC: deliver_to_party_site_use_id:'|| p_header_rec.deliver_to_party_site_use_id);
      oe_debug_pub.add('AAC: deliver_to_org_contact_id   :'|| p_header_rec.deliver_to_org_contact_id);
      oe_debug_pub.add('AAC: deliver_to_org              :'|| p_header_val_Rec.deliver_to_org);
      oe_debug_pub.add('AAC: deliver_to_customer_number  :'|| p_header_val_Rec.deliver_to_customer_number_oi);
      oe_debug_pub.add('AAC: deliver_to_customer_name  :'|| p_header_val_Rec.deliver_to_customer_number_oi);
      oe_debug_pub.add('AAC: deliver_to_contact          :'|| p_header_val_Rec.deliver_to_contact);
      END IF;

      l_create_account := TRUE;
      l_create_hdr_account := TRUE;

      p_site_tbl(l_site_tbl_counter).p_party_id          := p_header_rec.deliver_to_party_id;
      p_site_tbl(l_site_tbl_counter).p_party_site_id     := p_header_rec.deliver_to_party_site_id;

      if(p_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM)
      then
	 p_site_tbl(l_site_tbl_counter).p_site_use_id     := NULL;
      else
	 p_site_tbl(l_site_tbl_counter).p_site_use_id     := p_header_rec.deliver_to_org_id;
      end if;

      p_site_tbl(l_site_tbl_counter).p_cust_account_role_id := p_header_rec.deliver_to_contact_id;
      p_site_tbl(l_site_tbl_counter).p_org_contact_id       := p_header_rec.deliver_to_org_contact_id;
      p_site_tbl(l_site_tbl_counter).p_contact_name         := p_header_val_rec.deliver_to_contact;

      p_site_tbl(l_site_tbl_counter).p_party_site_use_id := p_header_rec.deliver_to_party_site_use_id;
      p_site_tbl(l_site_tbl_counter).p_site_use_code     := 'DELIVER_TO';

      p_site_tbl(l_site_tbl_counter).p_party_name        := p_header_val_Rec.deliver_to_customer_name_oi;
      p_site_tbl(l_site_tbl_counter).p_party_number      := p_header_rec.deliver_to_party_number;
      p_site_tbl(l_site_tbl_counter).p_cust_account_number := p_header_val_Rec.deliver_to_customer_number_oi;

      p_site_tbl(l_site_tbl_counter).p_site_address1       := p_header_val_rec.deliver_to_address1 ;
      p_site_tbl(l_site_tbl_counter).p_site_address2 	   := p_header_val_rec.deliver_to_address2 ;
      p_site_tbl(l_site_tbl_counter).p_site_address3 	   := p_header_val_rec.deliver_to_address3 ;
      p_site_tbl(l_site_tbl_counter).p_site_address4 	   := p_header_val_rec.deliver_to_address4 ;
      p_site_tbl(l_site_tbl_counter).p_site_state    	   := p_header_val_rec.deliver_to_state    ;
      p_site_tbl(l_site_tbl_counter).p_site_country  	   := p_header_val_rec.deliver_to_country  ;
      p_site_tbl(l_site_tbl_counter).p_site_city           := p_header_val_rec.deliver_to_city     ;
      p_site_tbl(l_site_tbl_counter).p_site_postal_code    := p_header_val_rec.deliver_to_zip      ;

      l_site_tbl_counter := l_site_tbl_counter + 1;
   END IF;

   /* check header invoice_to party info */
   IF (nvl(p_header_rec.invoice_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (p_header_rec.invoice_to_party_id is not null or
    p_header_rec.invoice_to_party_number is not null or
    p_header_rec.invoice_to_party_site_id is not null or
    p_header_rec.invoice_to_party_site_use_id is not null or
    p_header_rec.invoice_to_org_contact_id is not null) or
    (nvl(p_header_val_Rec.invoice_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.invoice_to_zip,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))

   THEN
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: invoice_to sites creation needed');
      oe_debug_pub.add('AAC: invoice_to_party_id         :'|| p_header_rec.invoice_to_party_id);
      oe_debug_pub.add('AAC: invoice_to_party_number         :'|| p_header_rec.invoice_to_party_number);
      oe_debug_pub.add('AAC: invoice_to_party_site_id    :'|| p_header_rec.invoice_to_party_site_id);
      oe_debug_pub.add('AAC: invoice_to_party_site_use_id:'|| p_header_rec.invoice_to_party_site_use_id);
      oe_debug_pub.add('AAC: invoice_to_org_contact_id   :'|| p_header_rec.invoice_to_org_contact_id);
      oe_debug_pub.add('AAC: invoice_to_org              :'|| p_header_val_Rec.invoice_to_org);
      oe_debug_pub.add('AAC: invoice_to_customer_number  :'|| p_header_val_Rec.invoice_to_customer_number_oi);
      oe_debug_pub.add('AAC: invoice_to_customer_name  :'|| p_header_val_Rec.invoice_to_customer_name_oi);
      oe_debug_pub.add('AAC: invoice_to_contact          :'|| p_header_val_Rec.invoice_to_contact);
      END IF;

      l_create_account := TRUE;
      l_create_hdr_account := TRUE;

      p_site_tbl(l_site_tbl_counter).p_party_id          := p_header_rec.invoice_to_party_id;
      p_site_tbl(l_site_tbl_counter).p_party_site_id     := p_header_rec.invoice_to_party_site_id;
      if(p_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM)
      then
	 p_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
      else
	 p_site_tbl(l_site_tbl_counter).p_site_use_id    := p_header_rec.invoice_to_org_id;
      end if;
      p_site_tbl(l_site_tbl_counter).p_cust_account_role_id := p_header_rec.invoice_to_contact_id;
      p_site_tbl(l_site_tbl_counter).p_org_contact_id       := p_header_rec.invoice_to_org_contact_id;
      p_site_tbl(l_site_tbl_counter).p_contact_name         := p_header_val_rec.invoice_to_contact;

      p_site_tbl(l_site_tbl_counter).p_party_site_use_id := p_header_rec.invoice_to_party_site_use_id;
      p_site_tbl(l_site_tbl_counter).p_site_use_code     := 'BILL_TO';

      p_site_tbl(l_site_tbl_counter).p_party_name        := p_header_val_Rec.invoice_to_customer_name_oi;
      p_site_tbl(l_site_tbl_counter).p_party_number      := p_header_rec.invoice_to_party_number;
      p_site_tbl(l_site_tbl_counter).p_cust_account_number := p_header_val_Rec.invoice_to_customer_number_oi;

      p_site_tbl(l_site_tbl_counter).p_site_address1       := p_header_val_rec.invoice_to_address1 ;
      p_site_tbl(l_site_tbl_counter).p_site_address2 	   := p_header_val_rec.invoice_to_address2 ;
      p_site_tbl(l_site_tbl_counter).p_site_address3 	   := p_header_val_rec.invoice_to_address3 ;
      p_site_tbl(l_site_tbl_counter).p_site_address4 	   := p_header_val_rec.invoice_to_address4 ;
      p_site_tbl(l_site_tbl_counter).p_site_state    	   := p_header_val_rec.invoice_to_state    ;
      p_site_tbl(l_site_tbl_counter).p_site_country  	   := p_header_val_rec.invoice_to_country  ;
      p_site_tbl(l_site_tbl_counter).p_site_city           := p_header_val_rec.invoice_to_city     ;
      p_site_tbl(l_site_tbl_counter).p_site_postal_code    := p_header_val_rec.invoice_to_zip      ;

      l_site_tbl_counter := l_site_tbl_counter + 1;
   END IF;

   	-- added for bug 4240715
	-- to check for end customer information
   IF (nvl(p_header_rec.end_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (p_header_rec.end_customer_party_id is not null or
    p_header_rec.end_customer_party_number is not null or
    nvl(p_header_val_Rec.end_customer_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
    nvl(p_header_val_Rec.end_customer_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)) then

      l_create_account := TRUE;
      l_create_hdr_account := TRUE;
      l_header_end_cust_exists :='Y';
      p_site_tbl(l_site_tbl_counter).p_party_id          := p_header_rec.end_customer_party_id;
      p_site_tbl(l_site_tbl_counter).p_party_name        := p_header_val_Rec.end_customer_name;
      p_site_tbl(l_site_tbl_counter).p_party_number      := p_header_rec.end_customer_party_number;
      p_site_tbl(l_site_tbl_counter).p_cust_account_number := p_header_val_Rec.end_customer_number;
      p_site_tbl(l_site_tbl_counter).p_site_use_code     := 'END_CUST';
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('AAC: VALUE OF l_create_account: TRUE');		--remem
	 oe_debug_pub.add('AAC: end customer account creation needed');
	 oe_debug_pub.add('AAC: end_customer_party_id         :'|| p_header_rec.end_customer_party_id);
	 oe_debug_pub.add('AAC: end_customer_party_number         :'|| p_header_rec.end_customer_party_number);
	 oe_debug_pub.add('AAC: end_customer              :'|| p_header_val_Rec.end_customer_name);
	 oe_debug_pub.add('AAC: end_customer_number  :'|| p_header_val_Rec.end_customer_number);
      END IF;


      IF  p_header_rec.end_customer_party_site_id is not null or
	 p_header_rec.end_customer_party_site_use_id is not null or
	    p_header_rec.end_customer_org_contact_id is not null or
	       nvl(p_header_val_Rec.end_customer_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
	       nvl(p_header_val_Rec.end_customer_site_postal_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: end customer sites creation needed');
	    oe_debug_pub.add('AAC: end_customer_party_site_id    :'|| p_header_rec.end_customer_party_site_id);
	    oe_debug_pub.add('AAC: end_customer_party_site_use_id:'|| p_header_rec.end_customer_party_site_use_id);
	    oe_debug_pub.add('AAC: end_customer_org_contact_id   :'|| p_header_rec.end_customer_org_contact_id);
	    oe_debug_pub.add('AAC: end_customer_contact          :'|| p_header_val_Rec.end_customer_contact);
	 END IF;


	 if(p_header_rec.end_customer_site_use_id = FND_API.G_MISS_NUM)
	 then
	    p_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
	 else
	    p_site_tbl(l_site_tbl_counter).p_site_use_id    := p_header_rec.end_customer_site_use_id;
	 end if;
	 p_site_tbl(l_site_tbl_counter).p_cust_account_role_id := p_header_rec.end_customer_contact_id;
	 p_site_tbl(l_site_tbl_counter).p_org_contact_id       := p_header_rec.end_customer_org_contact_id;
	 p_site_tbl(l_site_tbl_counter).p_contact_name         := p_header_val_rec.end_customer_contact;
	 p_site_tbl(l_site_tbl_counter).p_party_site_id		:=p_header_rec.end_customer_party_site_id; --4240715(new)

	 p_site_tbl(l_site_tbl_counter).p_party_site_use_id := p_header_rec.end_customer_party_site_use_id;
--	 p_site_tbl(l_site_tbl_counter).p_site_use_code     := 'END_CUST';
	 p_site_tbl(l_site_tbl_counter).p_site_address1       := p_header_val_rec.end_customer_site_address1 ;
	 p_site_tbl(l_site_tbl_counter).p_site_address2 	   := p_header_val_rec.end_customer_site_address2 ;
	 p_site_tbl(l_site_tbl_counter).p_site_address3 	   := p_header_val_rec.end_customer_site_address3 ;
	 p_site_tbl(l_site_tbl_counter).p_site_address4 	   := p_header_val_rec.end_customer_site_address4 ;
	 p_site_tbl(l_site_tbl_counter).p_site_state    	   := p_header_val_rec.end_customer_site_state    ;
	 p_site_tbl(l_site_tbl_counter).p_site_country  	   := p_header_val_rec.end_customer_site_country  ;
	 p_site_tbl(l_site_tbl_counter).p_site_city           := p_header_val_rec.end_customer_site_city     ;
	 p_site_tbl(l_site_tbl_counter).p_site_postal_code    := p_header_val_rec.end_customer_site_postal_code      ;

      END IF; -- for end customer site creation
      l_site_tbl_counter := l_site_tbl_counter + 1;
   END IF; -- for end customer account creation (bug 4240715)

   /* done checking for header level account creation} */

   /* if no header level account creation needed, check all lines{ */
   IF (l_create_account = FALSE )
   THEN
      oe_debug_pub.add('AAC: no header level account creation needed, checking all lines');
      if x_line_tbl.COUNT > 0 then

         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('X1');
         END IF;
      for i in x_line_tbl.FIRST..x_line_tbl.LAST loop
         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('X2');
         END IF;
	 /* l_create_account might change in this loop, so keep checking */
	 IF ( l_create_Account = FALSE
	     and
		((nvl(x_line_tbl(i).ship_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (x_line_tbl(i).ship_to_party_id is not null or
    x_line_tbl(i).ship_to_party_number is not null or
    x_line_tbl(i).ship_to_party_site_id is not null or
    x_line_tbl(i).ship_to_party_site_use_id is not null))
	      or
		 (nvl(x_line_tbl(i).deliver_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (x_line_tbl(i).deliver_to_party_id is not null or
    x_line_tbl(i).deliver_to_party_number is not null or
    x_line_tbl(i).deliver_to_party_site_id is not null or
    x_line_tbl(i).deliver_to_party_site_use_id is not null))
		 or
		    (nvl(x_line_tbl(i).invoice_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
   (x_line_tbl(i).invoice_to_party_id is not null or
    x_line_tbl(i).invoice_to_party_number is not null or
    x_line_tbl(i).invoice_to_party_site_id is not null or
    x_line_tbl(i).invoice_to_party_site_use_id is not null))
		or
			(nvl(x_line_tbl(i).end_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and  /* added to check for end customer (bug 4240715)*/
   (x_line_tbl(i).end_customer_party_id is not null or
    x_line_tbl(i).end_customer_party_number is not null or
    x_line_tbl(i).end_customer_party_site_id is not null or
    x_line_tbl(i).end_customer_party_site_use_id is not null))
	))
	 THEN
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: line level account creation needed');
            END IF;
	    l_create_account := TRUE;
	 END IF; /* ok, we need account creation */

      END loop;
   END IF;
   END IF;

   IF p_line_val_tbl.COUNT > 0 then
       for i in p_line_val_tbl.FIRST..p_line_val_tbl.LAST loop

	  IF (nvl(x_line_tbl(i).ship_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).ship_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(x_line_tbl(i).ship_to_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM or
		 nvl(x_line_tbl(i).ship_to_party_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                 nvl(p_line_val_tbl(i).ship_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                 nvl(p_line_val_tbl(i).ship_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).ship_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('ship to value present line#'||i);
             END IF;
	     l_create_account := TRUE;
	  end if;

	  IF (x_line_tbl(i).ship_to_org_contact_id is not null or nvl(p_line_val_tbl(i).ship_to_contact,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) then
	    l_create_account := TRUE;
	  END IF;

	  IF (nvl(x_line_tbl(i).deliver_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).deliver_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(x_line_tbl(i).deliver_to_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM or
		 nvl(x_line_tbl(i).deliver_to_party_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).deliver_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                   nvl(p_line_val_tbl(i).deliver_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('deliver to value present line#'||i);
            END IF;
	    l_create_account := TRUE;
	  end if;

	  IF (x_line_tbl(i).deliver_to_org_contact_id is not null or
	      nvl(p_line_val_tbl(i).deliver_to_contact,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR)
	  then
	    l_create_account := TRUE;
	  END IF;

	 IF (nvl(x_line_tbl(i).invoice_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).invoice_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(x_line_tbl(i).invoice_to_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM or
		 nvl(x_line_tbl(i).invoice_to_party_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                 nvl(p_line_val_tbl(i).invoice_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                 nvl(p_line_val_tbl(i).invoice_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
	    l_create_account := TRUE;
	  end if;

	  IF (x_line_tbl(i).invoice_to_org_contact_id is not null or
	      nvl(p_line_val_tbl(i).invoice_to_contact,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR)
	  then
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('invoice to value present line#'||i);
            END IF;
	    l_create_account := TRUE;
	    End If;

	    --{ added for 4240715
	    IF nvl(x_line_tbl(i).end_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	     and
		 (nvl(p_line_val_tbl(i).end_customer_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(x_line_tbl(i).end_customer_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM or
		  nvl(x_line_tbl(i).end_customer_party_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).end_customer_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).end_customer_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)
	  then
	    oe_debug_pub.add('once');
	    l_create_account := TRUE;
	 end if;

          oe_debug_pub.add('checking before org contactid');

	 IF (x_line_tbl(i).end_customer_org_contact_id is not null or
	      nvl(p_line_val_tbl(i).end_customer_contact,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR)
	 then
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('end customer value present line#'||i);
	 END IF;
	    l_create_account := TRUE;
	    --bug 4240715}
	 END IF;
      end loop;
   end if;

/* done checking lines} */
   oe_debug_pub.add('AAC: done checking...');
   IF (l_create_account = FALSE)
   THEN
      /* we don't actually need account creation. return */
      x_return_status := 'S';
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: no account creation needed. returning...');
      END IF;
      return;
   END IF;

   --  API Operation control flags.
   p_control_rec.p_allow_account_creation       := 'CHECK';
   p_control_rec.p_init_msg_list                := FALSE;
   p_control_rec.p_commit                       := FALSE;
   p_control_rec.p_multiple_account_is_error    := TRUE;
   p_control_rec.p_multiple_contact_is_error    := TRUE;
   p_control_rec.p_created_by_module            := 'ONT_PROCESS_ORDER_API';
   p_control_rec.p_continue_processing_on_error := FALSE;
   p_control_rec.p_return_if_only_party         := FALSE;


   -- Customer Information
   p_party_customer_rec.p_party_id              := p_header_rec.sold_to_party_id;
   p_party_customer_rec.p_party_number          := p_header_rec.sold_to_party_number;
   p_party_customer_rec.p_party_name            := p_header_val_rec.sold_to_org;

   IF nvl(p_header_rec.sold_to_org_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM AND
      l_sold_to_org_id is NULL then
      p_party_customer_rec.p_cust_account_id    := NULL;
   ELSE
     IF nvl(p_header_rec.sold_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
       p_party_customer_rec.p_cust_account_id    := l_sold_to_org_id;
     ELSE
       p_party_customer_rec.p_cust_account_id    := p_header_rec.sold_to_org_id;
     END IF;
   END IF;

   --p_party_customer_rec.p_cust_account_number   := p_header_val_rec.customer_number;

   -- Contact Information:
   if nvl(p_header_rec.sold_to_org_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      p_party_customer_rec.p_org_contact_id     := NULL;
   else
      p_party_customer_rec.p_org_contact_id        := p_header_rec.sold_to_org_contact_id;
   end if;
   if nvl(p_header_rec.sold_to_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      p_party_customer_rec.p_cust_account_role_id  := NULL;
   else
      p_party_customer_rec.p_cust_account_role_id  := p_header_rec.sold_to_contact_id;
   end if;
   if nvl(p_header_val_rec.sold_to_contact,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR then
      p_party_customer_rec.p_contact_name          := NULL;
   else
      p_party_customer_rec.p_contact_name          := p_header_val_rec.sold_to_contact;
   end if;

    /* header needs to have account creation */
   if (l_create_hdr_account = TRUE)
   then

      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: before calling Create_Account_layer for header level site creation{ ');
      END IF;

      oe_create_account_info.Create_Account_Layer(
						  p_control_rec  =>p_control_rec
						  ,x_return_status =>x_return_status
						  ,x_msg_count   =>x_msg_count
						  ,x_msg_data  =>x_Msg_data
						  ,p_party_customer_rec =>p_party_customer_rec
						  ,p_site_tbl  =>p_site_tbl
						  ,p_account_tbl  =>p_account_tbl
						  ,p_contact_tbl  =>p_contact_tbl
						  );
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: after calling Create_Account_layer for header level site creation} ');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 l_count :=oe_msg_pub.count_msg;

         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('AAC: Main Status is not success'||
			      ' msg='||x_msg_data||
			      ' count='||x_msg_count
			      );
         END IF;
	 RAISE FND_API.G_EXC_ERROR;

      ELSE
	 oe_debug_pub.add('AAC: Status is success');


	 -- Error out IF only party and no site information
	 IF p_account_tbl.COUNT = 0 AND p_party_customer_rec.p_party_id IS NOT NULL
	    THEN
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: Only party, no site. error out'||
				 ' msg='||x_msg_data||
				 ' count='||x_msg_count);
            END IF;
	    RAISE FND_API.G_EXC_ERROR;

	 END IF;

      END IF;

      IF p_account_tbl.COUNT <> 1
      THEN
	 --error
         IF l_debug_level  > 0 and l_header_end_cust_exists = 'N' THEN	--modified for bug 4240715
	 oe_debug_pub.add(' More than one party site/account record'||
			      ' msg='||x_msg_data||
			      ' count='||x_msg_count
			      );
         END IF;
	 RAISE FND_API.G_EXC_ERROR;
      /*TODO: more exception handling? */
      END IF;

      if p_account_tbl.count >= 1 then -- added if condition for end customer(bug 4240715)
      x_header_rec.sold_to_org_id := p_account_tbl(1);
      end if;
      if p_contact_tbl.COUNT=1 then
	 x_header_rec.sold_to_contact_id := p_contact_tbl(1);
      end if;


      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: sold_to_org_id :'||x_header_rec.sold_to_org_id);
      oe_debug_pub.add('AAC: sold_to_contact_id :'||x_header_rec.sold_to_contact_id);
      oe_debug_pub.add('AAC: p_site_tbl has '||p_site_tbl.COUNT||' rows');
      END IF;

    /* get the relevant ship/deliver/invoice to fields */
      IF p_site_tbl.COUNT > 0 then

	 FOR i in p_site_tbl.FIRST..p_site_tbl.LAST LOOP

	    IF (p_site_tbl(i).p_site_use_code = 'SHIP_TO')
	    THEN

               IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('AAC: header SHIP_TO org_id:'|| p_site_tbl(i).p_site_use_id);
	       oe_debug_pub.add('AAC: header SHIP_TO cust_account_id:'|| p_site_tbl(i).p_cust_account_id);
               END IF;
	       x_header_rec.ship_to_org_id := p_site_tbl(i).p_site_use_id;
	       x_header_rec.ship_to_customer_id := p_site_tbl(i).p_cust_account_id;
	       x_header_rec.ship_to_contact_id  := p_site_tbl(i).p_cust_account_role_id;

	    ELSIF (p_site_tbl(i).p_site_use_code = 'DELIVER_TO')
	    THEN
               IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('AAC: header DELIVER_TO org_id:'|| p_site_tbl(i).p_site_use_id);
	       oe_debug_pub.add('AAC: header DELIVER_TO cust_account_id:'|| p_site_tbl(i).p_cust_account_id);
               END IF;
	       x_header_rec.deliver_to_org_id := p_site_tbl(i).p_site_use_id;
	       x_header_rec.deliver_to_customer_id := p_site_tbl(i).p_cust_account_id;
	       x_header_rec.deliver_to_contact_id  := p_site_tbl(i).p_cust_account_role_id;

	    ELSIF (p_site_tbl(i).p_site_use_code = 'BILL_TO')
	    THEN

               IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('AAC: header INVOICE_TO org_id:'|| p_site_tbl(i).p_site_use_id);
	       oe_debug_pub.add('AAC: header INVOICE_TO cust_account_id:'|| p_site_tbl(i).p_cust_account_id);
               END IF;
	       x_header_rec.invoice_to_org_id := p_site_tbl(i).p_site_use_id;
	       x_header_rec.invoice_to_customer_id := p_site_tbl(i).p_cust_account_id;
	       x_header_rec.invoice_to_contact_id  := p_site_tbl(i).p_cust_account_role_id;
	    ELSIF (p_site_tbl(i).p_site_use_code = 'END_CUST')  /* end customer changes -bug 4240715 */
	      THEN

		IF l_debug_level  > 0 THEN
		     oe_debug_pub.add('AAC: header End Customer  :'|| p_site_tbl(i).p_site_use_id);
		     oe_debug_pub.add('AAC: header End Customer cust_account_id:'|| p_site_tbl(i).p_cust_account_id);
		END IF;
		x_header_rec.end_customer_site_use_id := p_site_tbl(i).p_site_use_id;
		x_header_rec.end_customer_id := p_site_tbl(i).p_cust_account_id;
		x_header_rec.end_customer_contact_id  := p_site_tbl(i).p_cust_account_role_id;
		oe_debug_pub.add('here the end custoemr id'||x_header_rec.end_customer_contact_id);
	    END IF;

	 END LOOP;
      end if;
   end if; --end header level account creation

   IF l_debug_level  > 0 THEN
   oe_debug_pub.add('AAC: cache: start header level cache lookup... ');
   END IF;

    /* loop through all the lines, looking for lines with party
       information similar to header level info, replace if
       found (thus implementing caching)
       Also pre-store the info if each line needs account creation in l_line_acct_needed,
       so we don't have to re-compute it later on.
       We want to call this even if no header accounts were created, since we
       pre-compute the info for each line.
    */

   IF x_line_tbl.COUNT > 0 then
      FOR i IN x_line_tbl.FIRST..x_line_tbl.LAST loop
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AAC: checking if account creation needed for line.'||i);
      END IF;
      IF ((nvl(x_line_tbl(i).ship_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	   and
	      (x_line_tbl(i).ship_to_party_id is not null or
	       x_line_tbl(i).ship_to_party_number is not null or
	       x_line_tbl(i).ship_to_party_site_id is not null or
	       x_line_tbl(i).ship_to_party_site_use_id is not null))
	  OR
	     (nvl(x_line_tbl(i).ship_to_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and x_line_tbl(i).ship_to_org_contact_id is not null ))
      then
         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('AAC: ship party info not null line#'||i);
         END IF;

	  /* look for similar ship_to_party_id s */
	 IF (nvl(x_line_tbl(i).ship_to_party_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.ship_to_party_id,FND_API.G_MISS_NUM) and
	     nvl(x_line_tbl(i).ship_to_party_number,FND_API.G_MISS_CHAR)=nvl(p_header_rec.ship_to_party_number,FND_API.G_MISS_CHAR) and
	     nvl(x_line_tbl(i).ship_to_party_site_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.ship_to_party_site_id,FND_API.G_MISS_NUM) and
	     nvl(x_line_tbl(i).ship_to_party_site_use_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.ship_to_party_site_use_id,FND_API.G_MISS_NUM))
	 THEN
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: cache: >> matching header ship_to_org_id:'||x_header_rec.ship_to_org_id||' found');
            END IF;
	    x_line_tbl(i).ship_to_org_id    :=  x_header_rec.ship_to_org_id;
	    x_line_tbl(i).ship_to_party_id := x_header_rec.ship_to_party_id;
	 else

            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: need ship account creation for line#'||i);
            END IF;
	    l_line_acct_needed(i).ship := TRUE;
	 END IF;
       end if;

       if ((nvl(x_line_tbl(i).deliver_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	   and
	      (x_line_tbl(i).deliver_to_party_id is not null or
	       x_line_tbl(i).deliver_to_party_number is not null or
	       x_line_tbl(i).deliver_to_party_site_id is not null or
	       x_line_tbl(i).deliver_to_party_site_use_id is not null))
	  OR
	     (nvl(x_line_tbl(i).deliver_to_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and x_line_tbl(i).deliver_to_org_contact_id is not null))
       then

         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('AAC: deliver party info not null line#'||i);
         END IF;

          /* look for similar deliver_to_party_id s */
	  IF (nvl(x_line_tbl(i).deliver_to_party_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.deliver_to_party_id,FND_API.G_MISS_NUM) and
	       nvl(x_line_tbl(i).deliver_to_party_number,FND_API.G_MISS_CHAR)=nvl(p_header_rec.deliver_to_party_number,FND_API.G_MISS_CHAR) and
	      nvl(x_line_tbl(i).deliver_to_party_site_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.deliver_to_party_site_id,FND_API.G_MISS_NUM) and
	      nvl(x_line_tbl(i).deliver_to_party_site_use_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.deliver_to_party_site_use_id,FND_API.G_MISS_NUM))
	  THEN
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('AAC: cache: >> matching header deliver_to_org_id:'||x_header_rec.deliver_to_org_id||' found');
             END IF;
	     x_line_tbl(i).deliver_to_org_id :=  x_header_rec.deliver_to_org_id;
	     x_line_tbl(i).deliver_to_party_id := x_header_rec.deliver_to_party_id;
	  else
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: need deliver account creation for line#'||i);
            END IF;
	    l_line_acct_needed(i).deliver := TRUE;
	  END IF;

       end if;


       if ((nvl(x_line_tbl(i).invoice_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	   and
	      (x_line_tbl(i).invoice_to_party_id is not null or
	       x_line_tbl(i).invoice_to_party_number is not null or
	       x_line_tbl(i).invoice_to_party_site_id is not null or
	       x_line_tbl(i).invoice_to_party_site_use_id is not null))
	  OR
	     (nvl(x_line_tbl(i).invoice_to_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and x_line_tbl(i).invoice_to_org_contact_id is not null))
       THEN
         IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('AAC: invoice party info not null line#'||i);
         END IF;
	  /* look for similar invoice_to_party_id s */
	  IF (nvl(x_line_tbl(i).invoice_to_party_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.invoice_to_party_id,FND_API.G_MISS_NUM) and
	       nvl(x_line_tbl(i).invoice_to_party_number,FND_API.G_MISS_CHAR)=nvl(p_header_rec.invoice_to_party_number,FND_API.G_MISS_CHAR) and
	      nvl(x_line_tbl(i).invoice_to_party_site_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.invoice_to_party_site_id,FND_API.G_MISS_NUM) and
	      nvl(x_line_tbl(i).invoice_to_party_site_use_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.invoice_to_party_site_use_id,FND_API.G_MISS_NUM))
	  THEN
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('AAC: cache: >> matching header invoice_to_org_id:'||x_header_rec.invoice_to_org_id||' found');
             END IF;
	     x_line_tbl(i).invoice_to_org_id :=  x_header_rec.invoice_to_org_id;
	     x_line_tbl(i).invoice_to_party_id := x_header_rec.invoice_to_party_id;
	  else
            IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: need invoice account creation for line#'||i);
            END IF;
	     l_line_acct_needed(i).invoice := TRUE;
	  END IF;
       end if;

              --added for bug 4240715 - end customer project
       if ((nvl(x_line_tbl(i).end_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	    and
	      (x_line_tbl(i).end_customer_party_id is not null or
	       x_line_tbl(i).end_customer_party_number is not null or
	       x_line_tbl(i).end_customer_party_site_id is not null or
	       x_line_tbl(i).end_customer_party_site_use_id is not null))
	   OR
	      (nvl(x_line_tbl(i).end_customer_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	       and x_line_tbl(i).end_customer_org_contact_id is not null))
       THEN
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('AAC: end customer party info not null line#'||i);
	  END IF;
	  IF (nvl(x_line_tbl(i).end_customer_party_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.end_customer_party_id,FND_API.G_MISS_NUM) and
	      nvl(x_line_tbl(i).end_customer_party_number,FND_API.G_MISS_CHAR)=nvl(p_header_rec.end_customer_party_number,FND_API.G_MISS_CHAR) and
	      nvl(x_line_tbl(i).end_customer_party_site_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.end_customer_party_site_id,FND_API.G_MISS_NUM) and
	      nvl(x_line_tbl(i).end_customer_party_site_use_id,FND_API.G_MISS_NUM)=nvl(p_header_rec.invoice_to_party_site_use_id,FND_API.G_MISS_NUM))
	  THEN
             IF l_debug_level  > 0 THEN
		oe_debug_pub.add('AAC: cache: >> matching header end customer id:'||x_header_rec.end_customer_id||' found');
             END IF;
	     x_line_tbl(i).end_customer_id :=  x_header_rec.end_customer_id;
	     x_line_tbl(i).end_customer_party_id := x_header_rec.end_customer_party_id;
	  else
	     IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC: need end customer account creation for line#'||i);
	 END IF;
	 l_line_acct_needed(i).end_customer := TRUE;
      END IF;
   end if;
   -- bug 4240715

    END loop;
    end if;

    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AAC: cache: done header level cache lookup ');
    END IF;

    IF p_line_val_tbl.COUNT > 0 then
       for i in p_line_val_tbl.FIRST..p_line_val_tbl.LAST loop

	  IF (x_line_tbl.EXISTS(i) and nvl(x_line_tbl(i).ship_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).ship_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).ship_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).ship_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).ship_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR) )
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('ship to present:ship_to_org:'||p_line_val_tbl(i).ship_to_org|| 'ship_to_customer_number:'||p_line_val_tbl(i).ship_to_customer_number_oi||' ship_to_contact:'||p_line_val_tbl(i).ship_to_contact);
             END IF;
	     l_line_acct_needed(i).ship := TRUE;
	     l_line_acct_needed(i).ship_value := TRUE;
	  end if;

	  IF (x_line_tbl.EXISTS(i) and (nvl(x_line_tbl(i).ship_to_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  or
					nvl(p_line_val_tbl(i).ship_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)) then

             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('ship to contact present');
             END IF;
	     l_line_acct_needed(i).ship := TRUE;
	     l_line_acct_needed(i).ship_value := TRUE;
	  END IF;

	  IF (x_line_tbl.EXISTS(i) and nvl(x_line_tbl(i).deliver_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).deliver_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).deliver_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).deliver_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).deliver_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('deliver to present:deliver_to_org:'||p_line_val_tbl(i).deliver_to_org|| 'deliver_to_customer_number:'||p_line_val_tbl(i).deliver_to_customer_number_oi||' deliver_to_contact:'||p_line_val_tbl(i).deliver_to_contact);
             END IF;
	     l_line_acct_needed(i).deliver := TRUE;
	     l_line_acct_needed(i).deliver_value := TRUE;
	  end if;

	  IF (x_line_tbl.EXISTS(i) and (nvl(x_line_tbl(i).deliver_to_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM or
					nvl(p_line_val_tbl(i).deliver_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('deliver to contact present');
             END IF;
	     l_line_acct_needed(i).deliver := TRUE;
	     l_line_acct_needed(i).deliver_value := TRUE;
	  END IF;

	 IF (x_line_tbl.EXISTS(i) and nvl(x_line_tbl(i).invoice_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	      and
		 (nvl(p_line_val_tbl(i).invoice_to_org,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).invoice_to_customer_number_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
                  nvl(p_line_val_tbl(i).invoice_to_customer_name_oi,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		  nvl(p_line_val_tbl(i).invoice_to_zip,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('invoice to present:invoice_to_org:'||p_line_val_tbl(i).invoice_to_org|| 'invoice_to_customer_number:'||p_line_val_tbl(i).invoice_to_customer_number_oi||' invoice_to_contact:'||p_line_val_tbl(i).invoice_to_contact);
             END IF;
	     l_line_acct_needed(i).invoice := TRUE;
	     l_line_acct_needed(i).invoice_value := TRUE;
	  end if;

	  IF (x_line_tbl.EXISTS(i) and (nvl(x_line_tbl(i).invoice_to_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  or
					nvl(p_line_val_tbl(i).invoice_to_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('invoice to contact present');
             END IF;
	    l_line_acct_needed(i).invoice := TRUE;
	    l_line_acct_needed(i).invoice_value := TRUE;
	 END IF;

	 --added for bug 4240715
	 -- end customer changes

	 IF (x_line_tbl.EXISTS(i) and nvl(x_line_tbl(i).end_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	     and
		(nvl(p_line_val_tbl(i).end_customer_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_address1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_address2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_address3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_address4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR or
		 nvl(p_line_val_tbl(i).end_customer_site_postal_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	 then
	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('end customer present:end customer name:'||p_line_val_tbl(i).end_customer_name|| 'end_customer_number:'||p_line_val_tbl(i).end_customer_number||' invoice_to_contact:'||p_line_val_tbl(i).end_customer_contact);
	    END IF;
	    l_line_acct_needed(i).end_customer := TRUE;
	     l_line_acct_needed(i).end_customer_value := TRUE;
	  end if;

	  IF (x_line_tbl.EXISTS(i) and (nvl(x_line_tbl(i).end_customer_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  or
					nvl(p_line_val_tbl(i).end_customer_contact,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR))
	  then
             IF l_debug_level  > 0 THEN
		oe_debug_pub.add('end_customer contact present');
             END IF;
	     l_line_acct_needed(i).end_customer := TRUE;
	    l_line_acct_needed(i).end_customer_value := TRUE;
	 END IF;
	 -- bug 4240715
      end loop;
   end if;

   IF l_debug_level  > 0 THEN
   oe_debug_pub.add('AAC: cache: start line level account creation and cache lookups...');
   END IF;

    /* Loop through all the line records:
          1. decide if we want to create an account, (check in l_line_acct_needed(i) )
          2. if so, try to lookup similar account in previous lines
             and copy that (thus implementing caching)
          3. if no match found, call account creation
    */

   IF x_line_tbl.COUNT > 0 then
    for i in x_line_tbl.FIRST..x_line_tbl.LAST loop

       IF l_debug_level  > 0 THEN
       oe_debug_pub.add(' AAC: processing line_id:'||x_line_tbl(i).line_id);
       oe_debug_pub.add(' AAC: line#'||i);
       END IF;

      /* check if we need to create account for this line{ */
       IF (l_line_acct_needed.EXISTS(i)
	   and
	      (l_line_acct_needed(i).ship = TRUE
	       or
	       l_line_acct_needed(i).deliver = TRUE
	       or
	       l_line_acct_needed(i).invoice = TRUE
	       or
	       l_line_acct_needed(i).end_customer = TRUE	--bug 4240715
	       ))
       THEN
   	  /* Ok, account needs to be created */

	  /* keep track of how many accounts matched,
              reset to zero on each i iteration */
	  l_line_acct_matched := 0;

	  /* Look for similar account in previously visited lines = Caching */
	  for j in x_line_tbl.FIRST..i LOOP
	     if x_line_tbl.EXISTS(j) and i <> j then
		IF (nvl(x_line_tbl(i).ship_to_party_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).ship_to_party_id,FND_API.G_MISS_NUM) and
		    nvl(x_line_tbl(i).ship_to_party_number,FND_API.G_MISS_CHAR) = nvl(x_line_tbl(j).ship_to_party_number,FND_API.G_MISS_CHAR) and
		    nvl(x_line_tbl(i).ship_to_party_site_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).ship_to_party_site_id,FND_API.G_MISS_NUM) and
		    nvl(x_line_tbl(i).ship_to_party_site_use_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).ship_to_party_site_use_id,FND_API.G_MISS_NUM))
		THEN
	        /* this ship_to line matches, copy record */
                   IF l_debug_level  > 0 THEN
		   oe_debug_pub.add('AAC: cache: >> matching line ship_to_org_id:'||x_line_tbl(j).ship_to_org_id||' found ');
                   END IF;
		   x_line_tbl(i).ship_to_org_id     := x_line_tbl(j).ship_to_org_id;
		   x_line_tbl(i).ship_to_customer_id:= x_line_tbl(j).ship_to_customer_id;
		   l_line_acct_matched              := l_line_acct_matched+1;
		END IF;
                IF l_debug_level  > 0 THEN
		oe_debug_pub.add(' AAC: X_ship#'||i||'.'||j);
                END IF;
		IF(nvl(x_line_tbl(i).deliver_to_party_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).deliver_to_party_id,FND_API.G_MISS_NUM) and
		   nvl(x_line_tbl(i).deliver_to_party_number,FND_API.G_MISS_CHAR) = nvl(x_line_tbl(j).deliver_to_party_number,FND_API.G_MISS_CHAR) and
		   nvl(x_line_tbl(i).deliver_to_party_site_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).deliver_to_party_site_id,FND_API.G_MISS_NUM) and
		   nvl(x_line_tbl(i).deliver_to_party_site_use_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).deliver_to_party_site_use_id,FND_API.G_MISS_NUM))
		THEN
	        /* this deliver_to line matches, copy record */
                   IF l_debug_level  > 0 THEN
		   oe_debug_pub.add('AAC: cache: >> matching line deliver_to_org_id:'||x_line_tbl(j).deliver_to_org_id||' found ');
                   END IF;
		   x_line_tbl(i).deliver_to_org_id  := x_line_tbl(j).deliver_to_org_id;
		   x_line_tbl(i).deliver_to_customer_id:= x_line_tbl(j).deliver_to_customer_id;
		   l_line_acct_matched              := l_line_acct_matched+1;
		END IF;
                IF l_debug_level  > 0 THEN
		oe_debug_pub.add(' AAC: X_deliver#'||i||'.'||j);
                END IF;
		IF(nvl(x_line_tbl(i).invoice_to_party_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).invoice_to_party_id,FND_API.G_MISS_NUM) and
		   nvl(x_line_tbl(i).invoice_to_party_number,FND_API.G_MISS_CHAR) = nvl(x_line_tbl(j).invoice_to_party_number,FND_API.G_MISS_CHAR) and
		   nvl(x_line_tbl(i).invoice_to_party_site_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).invoice_to_party_site_id,FND_API.G_MISS_NUM) and
		   nvl(x_line_tbl(i).invoice_to_party_site_use_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).invoice_to_party_site_use_id,FND_API.G_MISS_NUM))
		THEN
	        /* this invoice_to line matches, copy record */
                   IF l_debug_level  > 0 THEN
		   oe_debug_pub.add('AAC: cache: >> matching line invoice_to_org_id:'||x_line_tbl(j).invoice_to_org_id||' found ');
                   END IF;
		   x_line_tbl(i).invoice_to_org_id  := x_line_tbl(j).invoice_to_org_id;
		   x_line_tbl(i).invoice_to_customer_id:= x_line_tbl(j).invoice_to_customer_id;
		   l_line_acct_matched              := l_line_acct_matched+1;
		END IF;
                IF l_debug_level  > 0 THEN
		oe_debug_pub.add(' AAC: X_invoice#'||i||'.'||j);
                END IF;

		--{added for bug 4240715
		IF (nvl(x_line_tbl(i).end_customer_party_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).end_customer_party_id,FND_API.G_MISS_NUM) and
		    nvl(x_line_tbl(i).end_customer_party_number,FND_API.G_MISS_CHAR) = nvl(x_line_tbl(j).end_customer_party_number,FND_API.G_MISS_CHAR) and
		    nvl(x_line_tbl(i).end_customer_party_site_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).end_customer_party_site_id,FND_API.G_MISS_NUM) and
		    nvl(x_line_tbl(i).end_customer_party_site_use_id,FND_API.G_MISS_NUM) = nvl(x_line_tbl(j).end_customer_party_site_use_id,FND_API.G_MISS_NUM))
		THEN
	        /* this end_customer line matches, copy record */
                   IF l_debug_level  > 0 THEN
		   oe_debug_pub.add('AAC: cache: >> matching line end customer:'||x_line_tbl(j).end_customer_id||' found ');
                   END IF;
		   x_line_tbl(i).end_customer_site_use_id     := x_line_tbl(j).end_customer_site_use_id;
		   x_line_tbl(i).end_customer_id:= x_line_tbl(j).end_customer_id;
		   l_line_acct_matched              := l_line_acct_matched+1;
		END IF;

                IF l_debug_level  > 0 THEN
                oe_debug_pub.add(' AAC: X_End Customer#'||i||'.'||j);
                END IF;
		--bug 4240715
		oe_debug_pub.add('tested all four for line'||j);

	     END IF;
	     /* Done looking for similar accounts in prev lines */
	  END loop;

          IF l_debug_level  > 0 THEN
	  oe_debug_pub.add('AAC: Cache: done cache lookup for line: '||l_line_acct_matched||' matches found');
          END IF;

	  /* conservative search */
	  IF (l_line_acct_matched <> 3 ) THEN
	      /* we have to create a new site{ */
             IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('AAC: line: creating new account sites for line');
             END IF;

	     l_site_tbl_counter := 1;

	     IF (l_line_acct_needed(i).ship = TRUE)
	     then
                IF l_debug_level  > 0 THEN
		oe_debug_pub.add('AAC: line: creating new ship to account site for line');
                END IF;
		p_line_site_tbl(l_site_tbl_counter).p_party_site_id     := x_line_tbl(i).ship_to_party_site_id;
		p_line_site_tbl(l_site_tbl_counter).p_party_site_use_id := x_line_tbl(i).ship_to_party_site_use_id;

		if (nvl(x_line_tbl(i).ship_to_org_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM) then
		   p_line_site_tbl(l_site_tbl_counter).p_site_use_id     := NULL;
		else
		   p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := x_line_tbl(i).ship_to_org_id;
		end if;

		IF (l_line_acct_needed(i).ship_value = TRUE)
		then
		   p_line_site_tbl(l_site_tbl_counter).p_party_name             := p_line_val_tbl(i).ship_to_customer_name_oi;
		   p_line_site_tbl(l_site_tbl_counter).p_party_number           := null;
		   p_line_site_tbl(l_site_tbl_counter).p_cust_account_number    := p_line_val_tbl(i).ship_to_customer_number_oi;

		   p_line_site_tbl(l_site_tbl_counter).p_contact_name           := p_line_val_tbl(i).ship_to_contact;

		   p_line_site_tbl(l_site_tbl_counter).p_site_address1          := p_line_val_tbl(i).ship_to_address1 ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_address2 	   := p_line_val_tbl(i).ship_to_address2 ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_address3 	   := p_line_val_tbl(i).ship_to_address3 ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_address4 	   := p_line_val_tbl(i).ship_to_address4 ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_state    	   := p_line_val_tbl(i).ship_to_state    ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_country  	   := p_line_val_tbl(i).ship_to_country  ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_city              := p_line_val_tbl(i).ship_to_city     ;
		   p_line_site_tbl(l_site_tbl_counter).p_site_postal_code       := p_line_val_tbl(i).ship_to_zip   ;
		end if;

		p_line_site_tbl(l_site_tbl_counter).p_party_id          := x_line_tbl(i).ship_to_party_id;
		p_line_site_tbl(l_site_tbl_counter).p_party_number          := x_line_tbl(i).ship_to_party_number;
		p_line_site_tbl(l_site_tbl_counter).p_site_use_code     := 'SHIP_TO';
                p_line_site_tbl(l_site_tbl_counter).p_cust_account_id := x_line_tbl(i).ship_to_customer_id;
		p_line_site_tbl(l_site_tbl_counter).p_cust_account_role_id := x_line_tbl(i).ship_to_contact_id;
		p_line_site_tbl(l_site_tbl_counter).p_org_contact_id       := x_line_tbl(i).ship_to_org_contact_id;

		l_site_tbl_counter := l_site_tbl_counter + 1;
	      end if;

	      IF (l_line_acct_needed(i).deliver = TRUE)
	      then
                 IF l_debug_level  > 0 THEN
		 oe_debug_pub.add('AAC: line: creating new deliver to account site for line');
                 END IF;
		 p_line_site_tbl(l_site_tbl_counter).p_party_site_id     := x_line_tbl(i).deliver_to_party_site_id;
		 p_line_site_tbl(l_site_tbl_counter).p_party_site_use_id := x_line_tbl(i).deliver_to_party_site_use_id;

		 if (nvl(x_line_tbl(i).deliver_to_org_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM) then
		    p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
		 else
		    p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := x_line_tbl(i).deliver_to_org_id;
		 end if;

		 IF (l_line_acct_needed(i).deliver_value = TRUE)
		 then
		    p_line_site_tbl(l_site_tbl_counter).p_party_name          := p_line_val_tbl(i).deliver_to_customer_name_oi;
		    p_line_site_tbl(l_site_tbl_counter).p_party_number        := null;
		    p_line_site_tbl(l_site_tbl_counter).p_cust_account_number := p_line_val_tbl(i).deliver_to_customer_number_oi;

		    p_line_site_tbl(l_site_tbl_counter).p_contact_name        := p_line_val_tbl(i).deliver_to_contact;

		    p_line_site_tbl(l_site_tbl_counter).p_site_address1       := p_line_val_tbl(i).deliver_to_address1 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address2 	 := p_line_val_tbl(i).deliver_to_address2 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address3 	 := p_line_val_tbl(i).deliver_to_address3 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address4 	 := p_line_val_tbl(i).deliver_to_address4 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_state    	 := p_line_val_tbl(i).deliver_to_state    ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_country  	 := p_line_val_tbl(i).deliver_to_country  ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_city           := p_line_val_tbl(i).deliver_to_city     ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_postal_code    := p_line_val_tbl(i).deliver_to_zip   ;
		 end if;

		 p_line_site_tbl(l_site_tbl_counter).p_party_id          := x_line_tbl(i).deliver_to_party_id;
		 p_line_site_tbl(l_site_tbl_counter).p_party_number          := x_line_tbl(i).deliver_to_party_number;
		 p_line_site_tbl(l_site_tbl_counter).p_site_use_code     := 'DELIVER_TO';
                 p_line_site_tbl(l_site_tbl_counter).p_cust_account_id := x_line_tbl(i).deliver_to_customer_id;
		 p_line_site_tbl(l_site_tbl_counter).p_cust_account_role_id   := x_line_tbl(i).deliver_to_contact_id;
		 p_line_site_tbl(l_site_tbl_counter).p_org_contact_id         := x_line_tbl(i).deliver_to_org_contact_id;

		 l_site_tbl_counter := l_site_tbl_counter + 1;
	      end if;

	      IF (l_line_acct_needed(i).invoice = TRUE)
	      then
                 IF l_debug_level  > 0 THEN
		 oe_debug_pub.add('AAC: line: creating new invoice to account site for line');
                 END IF;
		 p_line_site_tbl(l_site_tbl_counter).p_party_site_id     := x_line_tbl(i).invoice_to_party_site_id;
		 p_line_site_tbl(l_site_tbl_counter).p_party_site_use_id := x_line_tbl(i).invoice_to_party_site_use_id;

		 if (nvl(x_line_tbl(i).invoice_to_org_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM) then
		    p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
		 else
		    p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := x_line_tbl(i).invoice_to_org_id;
		 end if;

		 IF (l_line_acct_needed(i).invoice_value = TRUE)
		 then
		    p_line_site_tbl(l_site_tbl_counter).p_party_name             := p_line_val_tbl(i).invoice_to_customer_name_oi;
		    p_line_site_tbl(l_site_tbl_counter).p_party_number           := null;
		    p_line_site_tbl(l_site_tbl_counter).p_cust_account_number    := p_line_val_tbl(i).invoice_to_customer_number_oi;

		    p_line_site_tbl(l_site_tbl_counter).p_contact_name           := p_line_val_tbl(i).invoice_to_contact;

		    p_line_site_tbl(l_site_tbl_counter).p_site_address1          := p_line_val_tbl(i).invoice_to_address1 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address2 	 := p_line_val_tbl(i).invoice_to_address2 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address3 	 := p_line_val_tbl(i).invoice_to_address3 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_address4 	 := p_line_val_tbl(i).invoice_to_address4 ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_state    	 := p_line_val_tbl(i).invoice_to_state    ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_country  	 := p_line_val_tbl(i).invoice_to_country  ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_city              := p_line_val_tbl(i).invoice_to_city     ;
		    p_line_site_tbl(l_site_tbl_counter).p_site_postal_code       := p_line_val_tbl(i).invoice_to_zip   ;
		 end if;

		 p_line_site_tbl(l_site_tbl_counter).p_party_id          := x_line_tbl(i).invoice_to_party_id;
		 p_line_site_tbl(l_site_tbl_counter).p_party_number          := x_line_tbl(i).invoice_to_party_number;
		 p_line_site_tbl(l_site_tbl_counter).p_site_use_code     := 'BILL_TO';
                 p_line_site_tbl(l_site_tbl_counter).p_cust_account_id := x_line_tbl(i).invoice_to_customer_id;
		 p_line_site_tbl(l_site_tbl_counter).p_cust_account_role_id   := x_line_tbl(i).invoice_to_contact_id;
		 p_line_site_tbl(l_site_tbl_counter).p_org_contact_id         := x_line_tbl(i).invoice_to_org_contact_id;

		 l_site_tbl_counter := l_site_tbl_counter + 1;
	      end if;

		-- { added for bug 4240715
	       -- End customer changes

	        IF (l_line_acct_needed(i).end_customer = TRUE)
		then
		   IF l_debug_level  > 0 THEN
		      oe_debug_pub.add('AAC: line: creating new end customer account site for line');
		   END IF;
		   p_line_site_tbl(l_site_tbl_counter).p_party_site_id     := x_line_tbl(i).end_customer_party_site_id;
		   p_line_site_tbl(l_site_tbl_counter).p_party_site_use_id := x_line_tbl(i).end_customer_party_site_use_id;

		   if (nvl(x_line_tbl(i).end_customer_site_use_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM) then
		      p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := NULL;
		   else
		      p_line_site_tbl(l_site_tbl_counter).p_site_use_id    := x_line_tbl(i).end_customer_site_use_id;
		   end if;

		   IF (l_line_acct_needed(i).end_customer_value = TRUE)
		   then
		      p_line_site_tbl(l_site_tbl_counter).p_party_name             := p_line_val_tbl(i).end_customer_name;
		      p_line_site_tbl(l_site_tbl_counter).p_party_number           := null;
		      p_line_site_tbl(l_site_tbl_counter).p_cust_account_number    := p_line_val_tbl(i).end_customer_number;

		      p_line_site_tbl(l_site_tbl_counter).p_contact_name           := p_line_val_tbl(i).end_customer_contact;

		      p_line_site_tbl(l_site_tbl_counter).p_site_address1          := p_line_val_tbl(i).end_customer_site_address1 ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_address2 	 := p_line_val_tbl(i).end_customer_site_address2 ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_address3 	 := p_line_val_tbl(i).end_customer_site_address3 ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_address4 	 := p_line_val_tbl(i).end_customer_site_address4 ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_state    	 := p_line_val_tbl(i).end_customer_site_state    ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_country  	 := p_line_val_tbl(i).end_customer_site_country  ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_city              := p_line_val_tbl(i).end_customer_site_city     ;
		      p_line_site_tbl(l_site_tbl_counter).p_site_postal_code       := p_line_val_tbl(i).end_customer_site_postal_code   ;
		   end if;

		   p_line_site_tbl(l_site_tbl_counter).p_party_id          := x_line_tbl(i).end_customer_party_id;
		   p_line_site_tbl(l_site_tbl_counter).p_party_number          := x_line_tbl(i).end_customer_party_number;
		   p_line_site_tbl(l_site_tbl_counter).p_site_use_code     := 'END_CUST';
		   p_line_site_tbl(l_site_tbl_counter).p_cust_account_role_id   := x_line_tbl(i).end_customer_contact_id;
		   p_line_site_tbl(l_site_tbl_counter).p_org_contact_id         := x_line_tbl(i).end_customer_org_contact_id;

		 if (nvl(x_line_tbl(i).end_customer_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM) then
		    p_line_site_tbl(l_site_tbl_counter).p_cust_account_id    := NULL;
		 else
		    p_line_site_tbl(l_site_tbl_counter).p_cust_account_id    := x_line_tbl(i).end_customer_id;
		 end if;


                 oe_debug_pub.add('end customer party_id'||x_line_tbl(i).end_customer_party_id ||'p_custacc'||p_line_site_tbl(l_site_tbl_counter).p_cust_account_id||'counter is'||l_site_tbl_counter);

		 l_site_tbl_counter := l_site_tbl_counter + 1;

	      end if;
	      -- bug 4240715}

              IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('AAC: line: calling Create_Account_Layer...');
              END IF;
	      oe_create_account_info.Create_Account_Layer(
							  p_control_rec  =>p_control_rec
							  ,x_return_status =>x_return_status
							  ,x_msg_count   =>x_msg_count
							  ,x_msg_data  =>x_Msg_data
							  ,p_party_customer_rec =>p_party_customer_rec
							  ,p_site_tbl  =>p_line_site_tbl
							  ,p_account_tbl  =>p_account_tbl
							  ,p_contact_tbl  =>p_contact_tbl
							  );


              IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('AAC: line: after calling create_account_layer');
              END IF;

	      /* check for errors{ */
	      IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
		 l_count :=oe_msg_pub.count_msg;

                 IF l_debug_level  > 0 THEN
		 oe_debug_pub.add('AAC: line: Main Status is not success'||
				  ' msg='||x_msg_data||
				  ' count='||x_msg_count
				  );
                 END IF;
		 RAISE FND_API.G_EXC_ERROR;
	      ELSE
                 IF l_debug_level  > 0 THEN
		 oe_debug_pub.add('AAC: line: Status is success');
                 END IF;

	      END IF; /* END checking for errors} */

	      IF p_line_site_tbl.COUNT > 0 then

		 FOR j in p_line_site_tbl.FIRST..p_line_site_tbl.LAST LOOP

		    IF (p_line_site_tbl(j).p_site_use_code = 'SHIP_TO')
		    THEN
                       IF l_debug_level  > 0 THEN
		       oe_debug_pub.add('AAC: line SHIP_TO org_id:'|| p_line_site_tbl(j).p_site_use_id);
		       oe_debug_pub.add('AAC: line SHIP_TO cust_account_id:'|| p_line_site_tbl(j).p_cust_account_id);
                       END IF;

		       x_line_tbl(i).ship_to_org_id := p_line_site_tbl(j).p_site_use_id;
		       x_line_tbl(i).ship_to_customer_id := p_line_site_tbl(j).p_cust_account_id;
		       x_line_tbl(i).ship_to_contact_id  := p_line_site_tbl(j).p_cust_account_role_id;
                       x_line_tbl(i).ship_to_party_id := p_line_site_tbl(j).p_party_id;
		    ELSIF (p_line_site_tbl(j).p_site_use_code = 'DELIVER_TO')
		    THEN

                       IF l_debug_level  > 0 THEN
		       oe_debug_pub.add('AAC: line DELIVER_TO org_id:'|| p_line_site_tbl(j).p_site_use_id);
		       oe_debug_pub.add('AAC: line DELIVER_TO cust_account_id:'|| p_line_site_tbl(j).p_cust_account_id);
                       END IF;
		       x_line_tbl(i).deliver_to_org_id := p_line_site_tbl(j).p_site_use_id;
		       x_line_tbl(i).deliver_to_customer_id := p_line_site_tbl(j).p_cust_account_id;
		       x_line_tbl(i).deliver_to_contact_id  := p_line_site_tbl(j).p_cust_account_role_id;
                       x_line_tbl(i).deliver_to_party_id := p_line_site_tbl(j).p_party_id;
		    ELSIF (p_line_site_tbl(j).p_site_use_code = 'BILL_TO')
		    THEN
                       IF l_debug_level  > 0 THEN
		       oe_debug_pub.add('AAC: line INVOICE_TO org_id:'|| p_line_site_tbl(j).p_site_use_id);
		       oe_debug_pub.add('AAC: line INVOICE_TO cust_account_id:'|| p_line_site_tbl(j).p_cust_account_id);
                       END IF;
		       x_line_tbl(i).invoice_to_org_id := p_line_site_tbl(j).p_site_use_id;
		       x_line_tbl(i).invoice_to_customer_id := p_line_site_tbl(j).p_cust_account_id;
		       x_line_tbl(i).invoice_to_contact_id  := p_line_site_tbl(j).p_cust_account_role_id;
                       x_line_tbl(i).invoice_to_party_id := p_line_site_tbl(j).p_party_id;

		     --{ added for bug 4240715
		    ELSIF (p_line_site_tbl(j).p_site_use_code = 'END_CUST') -- end customer changes
		       THEN
                       IF l_debug_level  > 0 THEN
		       oe_debug_pub.add('AAC: line End customer site use id:'|| p_line_site_tbl(j).p_site_use_id);
		       oe_debug_pub.add('AAC: line End customer cust_account_id:'|| p_line_site_tbl(j).p_cust_account_id);
                       END IF;
		       x_line_tbl(i).end_customer_site_use_id := p_line_site_tbl(j).p_site_use_id;
		       x_line_tbl(i).end_customer_id := p_line_site_tbl(j).p_cust_account_id;
		       x_line_tbl(i).end_customer_contact_id  := p_line_site_tbl(j).p_cust_account_role_id;
		       x_line_tbl(i).end_customer_party_id := p_line_site_tbl(j).p_party_id;
		       -- bug 4240715}

		    END IF;

		 END LOOP;
	      end if;

	   END IF; /* END creating a new site} */

	END IF; /* END checking account creation for line} */

   END loop;
   end if;

   IF l_debug_level  > 0 THEN
   oe_debug_pub.add('AAC: Exiting Process Order Automatic Account Creation}');
   END IF;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
	 OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Automatic_Account_Creation');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END AUTOMATIC_ACCOUNT_CREATION;


/* Introduced this API for OKC workbench to chekc security on contract terms.
the API will work for both sales orders and blanket sales agreements
*/

PROCEDURE Check_Header_Security
( p_document_type IN VARCHAR2
, p_column        IN VARCHAR2 := NULL
, p_header_id     IN NUMBER
, p_operation     IN VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_result        OUT NOCOPY NUMBER
)
IS
l_blanket_header_rec            OE_BLANKET_PUB.Header_Rec_Type;
l_blanket_rowtype_rec           oe_ak_blanket_headers_v%rowtype;
l_header_rec            OE_ORDER_PUB.Header_Rec_Type;
l_header_rowtype_rec    oe_ak_order_headers_v%rowtype;
l_action                NUMBER;

BEGIN


OE_MSG_PUB.initialize;
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF(p_operation IS NULL or p_operation = '' ) THEN
   --raise an error for null operation
   FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Operation');
   OE_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;

IF(p_header_id IS NULL) THEN
   --raise an error for null header_id
   FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header_id');
   OE_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
ELSE
   -- (1)query header_rec by header_id
   -- (2) convert to RowType Rec
   -- (3) call Entity_Security.Is_OP_Constrained to see if
   -- there are entity level constrains and attribute level constrains

   IF(p_document_type IS NULL OR p_document_type ='') THEN
     -- raise an error for null document_type
     FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE','document_type');
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   ELSIF p_document_type= 'O' THEN
     -- the caller is from Sales Order
     OE_HEADER_UTIL.QUERY_ROW(p_header_id=>p_header_id
                             ,x_header_rec=>l_header_rec);
     OE_HEADER_UTIL.API_Rec_To_Rowtype_Rec(l_header_rec
                             ,l_header_rowtype_rec);

      x_result := OE_Header_Security.Is_OP_Constrained
                               (p_operation =>  p_operation
                               ,p_column_name => p_column
                               ,p_record => l_header_rowtype_rec
                               ,x_on_operation_action => l_action
                               );


   ELSIF p_document_type= 'B' THEN
     -- the caller is from Blanket Order
     OE_Blanket_Util.Query_Header
                   (p_header_id     => p_header_id,
                    x_header_rec    => l_blanket_header_rec,
                    x_return_status => x_return_status);
     OE_BLANKET_UTIL.API_Rec_To_Rowtype_Rec(l_blanket_header_rec
                                           ,l_blanket_rowtype_rec);

      x_result := OE_Blanket_Header_Security.Is_OP_Constrained
                               (p_operation =>  p_operation
                               ,p_column_name => p_column
                               ,p_record => l_blanket_rowtype_rec
                               ,x_on_operation_action => l_action
                               );
    END IF;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Header_Security'
            );
        END IF;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Check_Header_Security;


END OE_Order_GRP;

/
