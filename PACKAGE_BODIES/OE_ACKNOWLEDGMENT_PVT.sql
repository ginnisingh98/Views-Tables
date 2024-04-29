--------------------------------------------------------
--  DDL for Package Body OE_ACKNOWLEDGMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ACKNOWLEDGMENT_PVT" AS
/* $Header: OEXVACKB.pls 120.8.12010000.2 2008/08/04 15:05:44 amallik ship $ */

--  Global constant holding the package name

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'OE_Acknowledgment_Pvt';

-- This to fix the performace issue with the call to the HZ tables
G_CURR_SOLD_TO_ORG_ID    NUMBER;
G_CURR_ADDRESS_ID        NUMBER;
G_TP_RET                 BOOLEAN := TRUE;
G_PRIMARY_SETUP          BOOLEAN := TRUE;
G_POCAO_ENABLED          BOOLEAN := FALSE;

/*  ---------------------------------------------------------------------
--  Start of Comments
--  API name    OE_Acknowledgment_Pvt
--  Type        Private
--  Function
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
--  ---------------------------------------------------------------------
*/

PROCEDURE get_address(
           p_address_type_in      IN  VARCHAR2,
           p_org_id_in            IN  NUMBER,
           p_address_id_in        IN NUMBER,
           p_tp_location_code_in     IN  VARCHAR2,
           p_tp_translator_code_in   IN  VARCHAR2,
l_addr1 OUT NOCOPY VARCHAR2,

l_addr2 OUT NOCOPY VARCHAR2,

l_addr3 OUT NOCOPY VARCHAR2,

l_addr4 OUT NOCOPY VARCHAR2,

l_addr_alt OUT NOCOPY VARCHAR2,

l_city OUT NOCOPY VARCHAR2,

l_county OUT NOCOPY VARCHAR2,

l_state OUT NOCOPY VARCHAR2,

l_zip OUT NOCOPY VARCHAR2,

l_province OUT NOCOPY VARCHAR2,

l_country OUT NOCOPY VARCHAR2,

l_region1 OUT NOCOPY VARCHAR2,

l_region2 OUT NOCOPY VARCHAR2,

l_region3 OUT NOCOPY VARCHAR2,

x_return_status OUT NOCOPY VARCHAR2)

IS

     l_entity_id                   NUMBER;
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(80);
     l_status_code                 NUMBER;
     l_return_status               VARCHAR2(20);
     l_address_type                NUMBER;
     l_org_id                      NUMBER;
     l_tp_location_code            VARCHAR2(3200);
     l_tp_translator_code          VARCHAR2(3200);
     l_tp_location_name            VARCHAR2(3200);
     l_addr_id                     VARCHAR2(3200);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ADDRESS TYPE = '||P_ADDRESS_TYPE_IN ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORG = '||P_ORG_ID_IN ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ADDRESS ID = '||P_ADDRESS_ID_IN ) ;
  END IF;

  IF p_address_type_in = 'CUSTOMER' THEN
    l_address_type := 1;
  ELSIF p_address_type_in = 'HR_LOCATION' THEN
    l_address_type := 2;
  END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING EC ADDRESS DERIVATION API' ) ;
    END IF;

    ece_trading_partners_pub.ece_get_address_wrapper(
      p_api_version_number   => 1.0,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      x_status_code          => l_status_code,
      p_address_type         => l_address_type,
      p_transaction_type     => 'POAO',
      p_org_id_in            => p_org_id_in,
      p_address_id_in        => p_address_id_in,
      p_tp_location_code_in  => p_tp_location_code_in,
      p_translator_code_in   => p_tp_translator_code_in,
      p_tp_location_name_in  => l_tp_location_name,
      p_address_line1_in     => l_addr1,
      p_address_line2_in     => l_addr2,
      p_address_line3_in     => l_addr3,
      p_address_line4_in     => l_addr4,
      p_address_line_alt_in  => l_addr_alt,
      p_city_in              => l_city,
      p_county_in            => l_county,
      p_state_in             => l_state,
      p_zip_in               => l_zip,
      p_province_in          => l_province,
      p_country_in           => l_country,
      p_region_1_in          => l_region1,
      p_region_2_in          => l_region2,
      p_region_3_in          => l_region3,
      x_entity_id_out        => l_entity_id,
      x_org_id_out           => l_org_id,
      x_address_id_out       => l_addr_id,
      x_tp_location_code_out => l_tp_location_code,
      x_translator_code_out  => l_tp_translator_code,
      x_tp_location_name_out => l_tp_location_name,
      x_address_line1_out    => l_addr1,
      x_address_line2_out    => l_addr2,
      x_address_line3_out    => l_addr3,
      x_address_line4_out    => l_addr4,
      x_address_line_alt_out => l_addr_alt,
      x_city_out             => l_city,
      x_county_out           => l_county,
      x_state_out            => l_state,
      x_zip_out              => l_zip,
      x_province_out         => l_province,
      x_country_out          => l_country,
      x_region_1_out         => l_region1,
      x_region_2_out         => l_region2,
      x_region_3_out         => l_region3);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ADDR1 = '||SUBSTR ( L_ADDR1 , 0 , 240 ) ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CITY = '||L_CITY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ZIP = '||L_ZIP ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNTRY = '||L_COUNTRY ) ;
  END IF;
EXCEPTION

  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           OE_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME, 'OE_Acknowledgment_Pvt.get_address');
        END IF;

END get_address;


PROCEDURE Process_Acknowledgment
(p_api_version_number            IN  NUMBER
,p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE

,p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_header_val_rec                IN  OE_Order_Pub.Header_Val_Rec_Type
,p_Header_Adj_tbl                IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_Header_Adj_val_tbl            IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_Header_Scredit_tbl            IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_Header_Scredit_val_tbl        IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_line_tbl                      IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_line_val_tbl                  IN  OE_Order_Pub.Line_Val_Tbl_Type
,p_Line_Adj_tbl                  IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_Line_Adj_val_tbl              IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_Line_Scredit_tbl              IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_Line_Scredit_val_tbl          IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_Lot_Serial_tbl                IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_Lot_Serial_val_tbl            IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL
,p_action_request_tbl	    	 IN  OE_Order_Pub.Request_Tbl_Type :=
 				     OE_Order_Pub.G_MISS_REQUEST_TBL
,p_old_header_rec                IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_old_header_val_rec            IN  OE_Order_Pub.Header_Val_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_VAL_REC
,p_old_Header_Adj_tbl            IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_old_Header_Adj_val_tbl        IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_old_Header_Scredit_tbl        IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_old_Header_Scredit_val_tbl    IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_old_line_tbl                  IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_old_line_val_tbl              IN  OE_Order_Pub.Line_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_VAL_TBL
,p_old_Line_Adj_tbl              IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_old_Line_Adj_val_tbl          IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_old_Line_Scredit_tbl          IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_old_Line_Scredit_val_tbl      IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_old_Lot_Serial_tbl            IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_old_Lot_Serial_val_tbl        IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL

,p_buyer_seller_flag             IN  VARCHAR2 DEFAULT 'B'
,p_reject_order                  IN  VARCHAR2 DEFAULT 'N'

,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_api_version_number          CONSTANT NUMBER      := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Acknowledgment';
l_return_status               VARCHAR2(1) 	   := FND_API.G_MISS_CHAR;

l_header_id			NUMBER;

l_header_rec                    OE_Order_Pub.Header_Rec_Type :=
                                p_header_rec;
l_header_val_rec                OE_Order_Pub.Header_Val_Rec_Type :=
                                p_header_val_rec;
l_Header_Adj_tbl                OE_Order_Pub.Header_Adj_Tbl_Type :=
                                p_Header_Adj_tbl;
l_Header_Adj_val_tbl            OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                p_Header_Adj_val_tbl;
l_Header_Price_Att_tbl          OE_Order_Pub.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl            OE_Order_Pub.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl          OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
l_Header_Scredit_tbl            OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                p_Header_Scredit_tbl;
l_Header_Scredit_val_tbl        OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                p_Header_Scredit_val_tbl;
l_line_rec                      OE_Order_Pub.Line_Rec_Type ;
l_line_tbl                      OE_Order_Pub.Line_Tbl_Type :=
                                p_line_tbl;
l_line_val_tbl                  OE_Order_Pub.Line_Val_Tbl_Type :=
                                p_line_val_tbl;
l_Line_Adj_tbl                  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                p_Line_Adj_tbl;
l_Line_Adj_val_tbl              OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                p_Line_Adj_val_tbl;
l_Line_Price_Att_tbl            OE_Order_Pub.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl              OE_Order_Pub.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl            OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
l_Line_Scredit_tbl              OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                p_Line_Scredit_tbl;
l_Line_Scredit_val_tbl          OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                p_Line_Scredit_val_tbl;
l_Lot_Serial_tbl                OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                p_Lot_Serial_tbl;
l_Lot_Serial_val_tbl            OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                p_Lot_Serial_val_tbl;
l_action_request_tbl	    	OE_Order_Pub.Request_Tbl_Type :=
			     	p_action_request_tbl;

l_old_header_rec                OE_Order_Pub.Header_Rec_Type :=
                                p_old_header_rec;
l_old_header_val_rec            OE_Order_Pub.Header_Val_Rec_Type :=
                                p_old_header_val_rec;
l_old_Header_Adj_tbl            OE_Order_Pub.Header_Adj_Tbl_Type :=
                                p_old_Header_Adj_tbl;
l_old_Header_Adj_val_tbl        OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                p_old_Header_Adj_val_tbl;
l_old_Header_Price_Att_tbl      OE_Order_Pub.Header_Price_Att_Tbl_Type;
l_old_Header_Adj_Att_tbl        OE_Order_Pub.Header_Adj_Att_Tbl_Type;
l_old_Header_Adj_Assoc_tbl      OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
l_old_Header_Scredit_tbl        OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                p_old_Header_Scredit_tbl;
l_old_Header_Scredit_val_tbl    OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                p_old_Header_Scredit_val_tbl;
l_old_line_tbl                  OE_Order_Pub.Line_Tbl_Type :=
                                p_old_line_tbl;
l_old_line_val_tbl              OE_Order_Pub.Line_Val_Tbl_Type :=
                                p_old_line_val_tbl;
l_old_Line_Adj_tbl              OE_Order_Pub.Line_Adj_Tbl_Type :=
                                p_old_Line_Adj_tbl;
l_old_Line_Adj_val_tbl          OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                p_old_Line_Adj_val_tbl;
l_old_Line_Price_Att_tbl        OE_Order_Pub.Line_Price_Att_Tbl_Type;
l_old_Line_Adj_Att_tbl          OE_Order_Pub.Line_Adj_Att_Tbl_Type;
l_old_Line_Adj_Assoc_tbl        OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
l_old_Line_Scredit_tbl          OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                p_old_Line_Scredit_tbl;
l_old_Line_Scredit_val_tbl      OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                p_old_Line_Scredit_val_tbl;
l_old_Lot_Serial_tbl            OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                p_old_Lot_Serial_tbl;
l_old_Lot_Serial_val_tbl        OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                p_old_Lot_Serial_val_tbl;

l_address_id			NUMBER;
l_tp_ret			BOOLEAN;
l_tp_ret_status			VARCHAR2(200);
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(200);

-- Variable to store return value for Trading Partner
l_trading_partner             VARCHAR2(1) := 'Y';

-- Remove below flag once it is passed as parameter
l_force_ack                   VARCHAR2(1) := FND_API.G_MISS_CHAR;

l_ack_req_flag                VARCHAR2(1) := 'N';
l_booked_shipped              VARCHAR2(1) := 'Y';

-- Remove below flag once it is passed as parameter
l_rejected_lines              VARCHAR2(1) := FND_API.G_MISS_CHAR;

-- Following Local Variables are for getting the data related to
-- Rejected Lines and Corresponding Lotserial for Acknowledgment
l_reject_line_tbl             OE_Order_Pub.Line_Tbl_Type :=
                              OE_Order_Pub.G_MISS_LINE_TBL;
l_reject_line_val_tbl         OE_Order_Pub.Line_Val_Tbl_Type :=
                              OE_Order_Pub.G_MISS_LINE_VAL_TBL;
l_reject_Lot_Serial_tbl       OE_Order_Pub.Lot_Serial_Tbl_Type :=
                              OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
l_reject_Lot_Serial_val_tbl   OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                              OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL;

-- This variable will be passed as value for parameter p_reject_order
-- In Insert_Row APIs for creating new rows for the rejected lines
-- in Acknowledgment Line and Lotserial tables.
-- The Value will be 'L' for creating records in acknowledgment
-- tables other value will be directly passed from Import Order API

l_create_rejects              VARCHAR2(1) := 'L';

l_booked_flag		      VARCHAR2(1) := '';

i				pls_integer;
j                               pls_integer;
l_line_index                    pls_integer;
-- This variable is passed to EDI's check for trading partner
l_site_use_id                 NUMBER;

-- Variable for checking the install staus of the EC product before doing
-- Any processing. Short term fix for the issue 1633094
l_status                  varchar2(1);
l_industry                varchar2(1);
l_o_schema                varchar2(30);
l_validation_org_id       NUMBER;
l_concatenated_segments   VARCHAR2(240); --For bug4309609

   l_addr1                       VARCHAR2(3200) := NULL;
   l_addr2                       VARCHAR2(3200) := NULL;
   l_addr3                       VARCHAR2(3200) := NULL;
   l_addr4                       VARCHAR2(3200) := NULL;
   l_addr_alt                    VARCHAR2(3200) := NULL;
   l_city                        VARCHAR2(3200) := NULL;
   l_county                      VARCHAR2(3200) := NULL;
   l_state                       VARCHAR2(3200) := NULL;
   l_zip                         VARCHAR2(3200) := NULL;
   l_province                    VARCHAR2(3200) := NULL;
   l_country                     VARCHAR2(3200) := NULL;
   l_region1                     VARCHAR2(3200) := NULL;
   l_region2                     VARCHAR2(3200) := NULL;
   l_region3                     VARCHAR2(3200) := NULL;
   l_bill_to_addr_id             NUMBER;
   l_ship_to_addr_id             NUMBER;
   l_sold_to_addr_id             NUMBER;
   l_ship_from_addr_id           NUMBER;
   l_bill_to_addr_code           VARCHAR2(40);
   l_ship_to_addr_code           VARCHAR2(40);
   l_sold_to_addr_code           VARCHAR2(40);
   l_ship_from_addr_code         VARCHAR2(40);
   l_sold_to_location_code        VARCHAR2(40);
   l_ship_from_location_code      VARCHAR2(40);
   l_ship_to_location_code        VARCHAR2(40);
   l_bill_to_location_code        VARCHAR2(40);
  /* This code was added for Blanket Sales Order */
   l_top_model_line_id            number;
   l_blanket_number               number;
   l_blanket_line_number          number;
   CURSOR get_top_model(p_top_model_line_id in number) IS
    SELECT
         blanket_number,
         blanket_line_number
    FROM
         OE_ORDER_LINES_ALL
    WHERE
         top_model_line_id = p_top_model_line_id;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --

   l_header_rec_isnull        Varchar2(1) := 'N';

   -- bug 3439319
   l_sales_order_id           Number;

BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_ACKNOWLEDGMENT_PVT.PROCESS_ACKNOWLEDGMENT' , 1 ) ;
   END IF;

   /***
   -- Bug fix 1633094 start
   oe_debug_pub.add('Before Calling FND api to check the EC inst',1);
   IF fnd_installation.get_app_info('EC', l_status, l_industry, l_o_schema)
   THEN
      IF nvl(l_status,'N') = 'N' THEN
         oe_debug_pub.add('EC not installed - No ACK required',1);
         oe_debug_pub.add('Exiting OE_Acknowledgment_Pvt.Process_acknowledgment',1);
         x_return_status                := FND_API.G_RET_STS_SUCCESS;
         RETURN;
      END IF; -- l_status is N
   ELSE
         oe_debug_pub.add('Call to fnd_installation.get_app_info is FALSE',1);
         oe_debug_pub.add('Exiting OE_Acknowledgment_Pvt.Process_acknowledgment',1);
         x_return_status                := FND_API.G_RET_STS_SUCCESS;
         RETURN;
   END IF;  -- call to fnd_installation
   -- Bug fix 1633094 end
   ***/

   -- lkxu, for bug 1701377
   -- to check if EC is installed
   IF OE_GLOBALS.G_EC_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_EC_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(175);
   END IF;

   IF OE_GLOBALS.G_EC_INSTALLED <> 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EC NOT INSTALLED - NO ACK REQUIRED' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ACKNOWLEDGMENT_PVT.PROCESS_ACKNOWLEDGMENT' , 1 ) ;
      END IF;
      RETURN;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CHECKING IF HEADER_ID EXISTS FOR HEADER REC' , 3 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'HEADER_ID_ACK = '||L_HEADER_REC.HEADER_ID ) ;
   END IF;

   IF  (l_header_rec.header_id    <> FND_API.G_MISS_NUM AND
    nvl(l_header_rec.header_id,0) <> 0)
   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE GETTING BOOKED_FLAG' , 3 ) ;
      END IF;

   --    l_header_rec := OE_Header_Util.Query_Row
   --		        (p_header_id => l_header_rec.header_id);

       IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'l_header_rec: price list '||l_header_val_rec.price_list ) ;
       oe_debug_pub.add(  'L_header_rec: order_category_code '||l_header_rec.order_category_code ) ;
       oe_debug_pub.add(  'l_header_rec: first_ack date '||l_header_rec.first_ack_date ) ;
       oe_debug_pub.add(  'l_header_rec: first_ack code '||l_header_rec.first_ack_code ) ;
       oe_debug_pub.add(  'l_header_rec: shipping instructions' ||l_header_rec.shipping_instructions ) ;
       oe_debug_pub.add(  'l_header_rec: packing instructions' ||l_header_rec.packing_instructions ) ;
       END IF;
      BEGIN
          SELECT booked_flag INTO l_booked_flag
            FROM oe_order_headers
           WHERE header_id = l_header_rec.header_id;

          IF l_booked_flag = 'Y' THEN
             l_header_rec.booked_flag := l_booked_flag;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORDER IS BOOKED 1' ) ;
         END IF;
          END IF;

          EXCEPTION
            WHEN OTHERS THEN
              x_return_status                := FND_API.G_RET_STS_SUCCESS;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'EXCEPTION IN GETTING BOOKED_FLAG' , 3 ) ;
              END IF;
              RETURN;
      END;

   ELSIF l_line_tbl.count > 0 AND
       (l_header_rec.header_id = FND_API.G_MISS_NUM OR
    nvl(l_header_rec.header_id,0) = 0) AND
       (l_line_tbl(l_line_tbl.first).header_id <> FND_API.G_MISS_NUM AND
    nvl(l_line_tbl(l_line_tbl.first).header_id,0) <> 0)
   THEN
	Begin
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE QUERYING THE HEADER REC' ) ;
      END IF;
--	 l_header_rec := OE_Header_Util.Query_Row
--			(p_header_id => l_line_tbl(1).header_id);
         -- This is to get the index of the line table, as
         -- the global change, create index, which can be something
         -- other than normal sequence of 1...so on.
         l_line_index := l_line_tbl.First;
         -- start bug 4048709, if the global picture header record is not present
         -- that means that there were no header level changes
         -- but we still need the header record to perform tp check + send ack,
         -- so get it from the cache if possible
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Header Id in cache is : '||oe_order_cache.g_header_rec.header_id);
         END IF;
         IF OE_ORDER_CACHE.g_header_rec.header_id <> FND_API.G_MISS_NUM AND
        	     nvl(OE_ORDER_CACHE.g_header_rec.header_id,0) = l_line_tbl(l_line_index).header_id THEN
            l_header_rec := OE_ORDER_CACHE.g_header_rec;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Assigned header record from cache with booked flag '|| l_header_rec.booked_flag);
            END IF;
         ELSE
         -- end bug 4048709
  	 OE_Header_Util.Query_Row
                -- Below l_line_index is passed insted of 1 for post H
  		(p_header_id => l_line_tbl(l_line_index).header_id,
  		x_header_rec => l_header_rec);
         END IF ;
         --bug 3592147
         l_header_rec_isnull := 'Y';
     Exception
       When Others Then
         x_return_status  := FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NOTHING TO ACKNOWLEDGE - ELSIF' , 3 ) ;
         END IF;
         RETURN;
     End;
   ELSE
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOTHING TO ACKNOWLEDGE - ELSE' , 3 ) ;
      END IF;
      RETURN;
   END IF;


/* -------------------------------------------------------------
-- Following API is called to check if the Customer is a
-- Trading Partner or not? Acknowledgment will only be sent
-- to those customers who are trading partners and who
-- have enabled the acknowledgment transactions.
-- -------------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CHECKING IF TRADING PARTNER' ) ;
   END IF;

   -- aksingh performance cache
   IF G_CURR_SOLD_TO_ORG_ID = l_header_rec.sold_to_org_id AND
      (G_TP_RET = FALSE OR
       G_PRIMARY_SETUP = FALSE)
   THEN
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECKED CACHED VALUE POAO NOT EDI ENABLED G_CURR' , 3 ) ;
      END IF;
      RETURN;
   END IF;

   -- aksingh performance cache
   IF G_CURR_SOLD_TO_ORG_ID = l_header_rec.sold_to_org_id AND
      G_CURR_ADDRESS_ID IS NOT NULL AND
      G_TP_RET = TRUE
   THEN
      -- No need to check anything all information is available
      -- Go and Create acknowledgment records
      goto create_ack;
   END IF;

   l_tp_ret := FALSE;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SOLD_TO_ORG_ID: '||TO_CHAR ( L_HEADER_REC.SOLD_TO_ORG_ID ) , 3 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INVOICE_TO_ORG_ID: '||TO_CHAR ( L_HEADER_REC.INVOICE_TO_ORG_ID ) , 3 ) ;
   END IF;

   BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE GETTING SOLD_TO SITE FOR THE CUSTOMER' ) ;
     END IF;
     -----------------------------------------------------------------
     -- Fixing bug #1513426, using the HZ tables directly instead of
     -- RA views to improve the performance
     ------------------------------------------------------------------

     -- This sql is only performed when customer change to improve performance


     SELECT /*MOAC_SQL_CHANGES*/ b.site_use_id, a.cust_acct_site_id
     INTO   l_site_use_id, l_address_id
     FROM   hz_cust_site_uses b, hz_cust_acct_sites_all a
     WHERE  a.cust_acct_site_id = b.cust_acct_site_id
     AND    a.cust_account_id  = l_header_rec.sold_to_org_id
     AND    b.site_use_code = 'SOLD_TO'
     AND    b.primary_flag = 'Y'
     AND    b.status = 'A'
     AND    b.org_id=a.org_id
     AND    a.status = 'A';

     G_CURR_SOLD_TO_ORG_ID := l_header_rec.sold_to_org_id;
     G_CURR_ADDRESS_ID := l_address_id;
     G_PRIMARY_SETUP := TRUE;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_SITE_USE_ID ' || TO_CHAR ( L_SITE_USE_ID ) , 3 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_ADDRESS_ID ' || TO_CHAR ( L_ADDRESS_ID ) , 3 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER GETTING SOLD_TO SITE FOR THE CUSTOMER' ) ;
     END IF;
   EXCEPTION

     WHEN NO_DATA_FOUND THEN
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO PRIMARY SOLD_TO SET FOR CUSTOMER' , 2 ) ;
        END IF;
        G_CURR_SOLD_TO_ORG_ID := l_header_rec.sold_to_org_id;
        G_CURR_ADDRESS_ID := NULL;
        G_PRIMARY_SETUP := FALSE;
	   RETURN;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOT ABLE TO GET PRIMARY SOLD_TO FOR CUSTOMER' , 1 ) ;
        END IF;
	   RETURN;
    END;


   l_tp_ret := EC_TRADING_PARTNER_PVT.Is_Entity_Enabled (
	 p_api_version_number	=> 1.0
	,p_init_msg_list 	=> null
	,p_simulate 		=> null
	,p_commit 		=> null
	,p_validation_level 	=> null
	,p_transaction_type	=> 'POAO'
	,p_transaction_subtype	=> null
	,p_entity_type		=> EC_TRADING_PARTNER_PVT.G_CUSTOMER
	,p_entity_id		=> l_address_id
	,p_return_status 	=> l_tp_ret_status
	,p_msg_count		=> l_msg_count
	,p_msg_data		=> l_msg_data);

  IF l_header_rec.first_ack_code is not null THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Check if POCAO Enabled ',1 );
     END IF;

     G_POCAO_ENABLED := EC_TRADING_PARTNER_PVT.Is_Entity_Enabled (
         p_api_version_number   => 1.0
        ,p_init_msg_list        => null
        ,p_simulate             => null
        ,p_commit               => null
        ,p_validation_level     => null
        ,p_transaction_type     => 'POCAO'
        ,p_transaction_subtype  => null
        ,p_entity_type          => EC_TRADING_PARTNER_PVT.G_CUSTOMER
        ,p_entity_id            => l_address_id
        ,p_return_status        => l_tp_ret_status
        ,p_msg_count            => l_msg_count
        ,p_msg_data             => l_msg_data);

       IF NOT G_POCAO_ENABLED THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'POCAO NOT ENABLED',1 ) ;
          END IF;
          l_tp_ret := FALSE;
       END IF;
   END IF;


  IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALL TO THE EDI API' ) ;
   END IF;

   IF l_tp_ret = FALSE then
      G_TP_RET := FALSE;
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER/INVOICE-TO-ADDRESS/POAO NOT EDI ENABLED' , 3 ) ;
      END IF;
      RETURN;
   END IF;

   G_TP_RET := TRUE;

   <<create_ack>>
/* --------------------------------------------------------------------
--  If Force_Ack flag is not 'Y' then Check if the Booked_flag = 'Y'
--  and Schedule Ship Date is not null else this check is not required.
-- --------------------------------------------------------------------
*/
    l_booked_shipped := 'Y';
/*
 OE_Line_Util.Query_Rows
        (   p_header_id             => l_header_rec.header_id
           ,   x_line_tbl              => l_line_tbl
        );
*/
--    l_header_rec.booked_flag := 'Y'; -- Temp, because of a bug in PO

    IF nvl(l_force_ack, 'Y') <> 'Y' THEN
       IF l_header_rec.booked_flag = 'Y' THEN
/* commented out nocopy as part of post H global change

		i := l_line_tbl.First;
		While i is not null loop
          --FOR I IN 1..l_line_tbl.COUNT

             IF l_line_tbl(I).schedule_ship_date    is not null AND
                l_line_tbl(I).schedule_arrival_date is not null
	        THEN
-- aksingh 2 line added on 10/22/00
			 NULL;
             ELSE
                oe_debug_pub.add('lines are not scheduled',3);
                l_booked_shipped := 'N';
                EXIT;
             END IF;
		   i := l_line_tbl.Next(i);
          END LOOP;
        */ -- Till this commented for the post H
          NULL;
       ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORDER IS NOT BOOKED' , 3 ) ;
          END IF;
          l_booked_shipped := 'N';
       END IF;
    END IF;

    IF l_booked_shipped = 'N' THEN
       x_return_status  := FND_API.G_RET_STS_SUCCESS;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ACKNOWLEDGMENT NOT REQUIRED' , 3 ) ;
       END IF;
       RETURN;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CHECKING IF FIELDS CHANGED' , 3 ) ;
    END IF;

/* -------------------------------------------------------------
   Now Check to see at what level the data has been changed
   If only Header Level then send only Header Data for acknowledgment
   Else If Shipment Level then send both Header and Line level data
   -------------------------------------------------------------
*/
    J:= l_line_tbl.last;
    I:= l_line_tbl.first;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'I = '||I ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'J = '||J ) ;
	oe_debug_pub.add('header first_ack_code: => ' || l_header_rec.first_ack_code);
    END IF;


    While i is not null loop
     /* Bug 2416561 : Calling the Convert_Miss_To_Null for the id records */
     l_line_rec := l_line_tbl(I);
     oe_line_util.Convert_Miss_To_Null(p_x_line_rec  =>l_line_rec);
     l_line_tbl(I) := l_line_rec;

     -- bug 3439319 added this block instead of NULLing out the resv_qty
     Begin
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('header_id => ' || l_line_tbl(I).header_id);
        oe_debug_pub.add('line_id => ' || l_line_tbl(I).line_id);
        oe_debug_pub.add('org_id => ' || l_line_tbl(I).org_id);
        oe_debug_pub.add('unit_selling_price = '||l_line_tbl(I).unit_selling_price);
        oe_debug_pub.add('unit_selling_price old = '||l_old_line_tbl(I).unit_selling_price);
        oe_debug_pub.add('schedule_ship_date = '||l_line_tbl(I).schedule_ship_date);
        oe_debug_pub.add('schedule_ship_date old = '||l_old_line_tbl(I).schedule_ship_date);
        oe_debug_pub.add('ordered_quantity = '||l_line_tbl(I).ordered_quantity);
        oe_debug_pub.add('ordered_quantity_old = '||l_old_line_tbl(I).ordered_quantity);
        oe_debug_pub.add('schedule_arrival_date = '||l_line_tbl(I).schedule_arrival_date);
        oe_debug_pub.add('schedule_arrival_date old = '||l_old_line_tbl(I).schedule_arrival_date);
        oe_debug_pub.add('shipped_quantity = '||nvl(l_line_tbl(I).shipped_quantity,0));
        oe_debug_pub.add('shipped_quantity old = '||nvl(l_old_line_tbl(I).shipped_quantity,0));
        oe_debug_pub.add('first_ack_code line = '||nvl(l_line_tbl(I).first_ack_code,'Nul'));
        oe_debug_pub.add('uom = '||l_line_tbl(I).order_quantity_uom);
        oe_debug_pub.add('uom old = '||l_old_line_tbl(I).order_quantity_uom);
        oe_debug_pub.add('inv item id = '||l_line_tbl(I).inventory_item_id);
        oe_debug_pub.add('inv item id old = '||l_old_line_tbl(I).inventory_item_id);
        oe_debug_pub.add('line first_ack_code old: => ' || l_old_line_tbl(I).first_ack_code);
        oe_debug_pub.add('line first_ack_code new: => ' || l_line_tbl(I).first_ack_code);
        oe_debug_pub.add('line operation old: => ' || l_old_line_tbl(I).operation);
        oe_debug_pub.add('line operation new: => ' || l_line_tbl(I).operation);
       END IF;

       l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(I).header_id);

       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('l_sales_order_id => ' || l_sales_order_id);
       END IF;

       l_line_tbl(I).reserved_quantity := oe_line_util.Get_Reserved_Quantity (
                                          p_header_id   => l_sales_order_id,
                                          p_line_id     => p_line_tbl(I).line_id,
                                          p_org_id      => p_line_tbl(I).org_id);
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Reserved_Qty => ' || l_line_tbl(I).reserved_quantity);
       END IF;
     Exception
        When Others Then
          oe_debug_pub.add('When Others After the call to get_reserv_qty in OEXVACKB');
          l_line_tbl(I).reserved_quantity := NULL;
     END;

       --    FOR I IN l_line_tbl.first..l_line_tbl.last LOOP

       -- modified the following condition to fix 2380911 to take care of INSERT
       -- operation if the Acknowledgment is already extracted.
      IF NOT (OE_GLOBALS.Equal(l_line_tbl(I).inventory_item_id,
                               l_old_line_tbl(I).inventory_item_id)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).unit_selling_price,
                               l_old_line_tbl(I).unit_selling_price)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).ordered_quantity,
                               l_old_line_tbl(I).ordered_quantity)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).order_quantity_uom,
                               l_old_line_tbl(I).order_quantity_uom)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).shipped_quantity,
                               l_old_line_tbl(I).shipped_quantity)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).schedule_ship_date,
                               l_old_line_tbl(I).schedule_ship_date)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).schedule_arrival_date,
                               l_old_line_tbl(I).schedule_arrival_date)
              ) OR (
                    l_old_line_tbl(I).operation = Oe_Globals.G_OPR_INSERT OR
        	    l_old_line_tbl(I).operation = Oe_Globals.G_OPR_CREATE
                  )
		OR (  l_line_tbl(I).first_ack_code is null  AND
		      l_header_rec.first_ack_code is not null )--bug7207426
      THEN
          -- Set local variable to continue Acknowledgment processing
          -- And Exit from Loop
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE DATA HAS CHANGED' ) ;
          END IF;

          l_ack_req_flag := 'B';
            /* Bug 2671184 :
               IF POCAO and a new line is added to the Order  */
            If l_header_rec.first_ack_code is not null AND
               l_line_tbl(I).FIRST_ACK_CODE is null
               THEN
                l_line_tbl(I).FIRST_ACK_CODE     := 'DR';
                l_line_tbl(I).FIRST_ACK_DATE     := sysdate;
                l_old_line_tbl(I).FIRST_ACK_DATE := sysdate;
            end if;

     ELSE
          -- no attribute change was detected so if the acknowledgment has been
          -- extracted previously, do not send this line
          IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No attribute change detected.');
          END IF;

          If l_header_rec.first_ack_code Is Not Null Then
           IF l_debug_level  > 0 THEN
            oe_debug_pub.add('line will not be acknowledged.');
           END IF;
            l_line_tbl(I).changed_lines_pocao := 'N';
            --EXIT;
          End If;
     END IF;
         l_validation_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FIRST_ACK_CODE FROM PROCAPI = '||L_LINE_TBL ( I ) .FIRST_ACK_CODE ) ;
       END IF;

   BEGIN
    -- Fix for the bug2722519
    SELECT b.cust_acct_site_id, a.ece_tp_location_code,b.location
      INTO l_ship_to_addr_id, l_ship_to_location_code,l_ship_to_addr_code
      FROM hz_cust_acct_sites_all a, hz_cust_site_uses_all b
     WHERE a.cust_acct_site_id = b.cust_acct_site_id
       AND b.site_use_id = l_line_tbl(I).ship_to_org_id
       AND b.site_use_code='SHIP_TO';
-- removed unnecessary validation of customer account, bug 3656640

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP-LINE- TO ADDR ID = '||L_SHIP_TO_ADDR_ID ) ;
    END IF;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO DERIVE SHIP_TO ADDR FOR LINE' ) ;
     END IF;
   END;

        get_address(
           p_address_type_in      => 'CUSTOMER',
           p_org_id_in            => l_validation_org_id,
           p_address_id_in        => l_ship_to_addr_id,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);

      l_line_val_tbl(I).ship_to_address1 := SUBSTR(l_addr1,0,240);
      l_line_val_tbl(I).ship_to_address2 := SUBSTR(l_addr2,0,240);
      l_line_val_tbl(I).ship_to_address3 := SUBSTR(l_addr3,0,240);
      l_line_val_tbl(I).ship_to_address4 := SUBSTR(l_addr4,0,240);
      l_line_val_tbl(I).ship_to_state := SUBSTR(l_state,0,60);
      l_line_val_tbl(I).ship_to_city := SUBSTR(l_city,0,60);
      l_line_val_tbl(I).ship_to_zip := SUBSTR(l_zip,0,60);
      l_line_val_tbl(I).ship_to_country := SUBSTR(l_country,0,60);
      l_line_val_tbl(I).ship_to_county := SUBSTR(l_county,0,60);
      l_line_val_tbl(I).ship_to_province := SUBSTR(l_province,0,60);
      l_line_val_tbl(I).ship_to_location := l_ship_to_addr_code;
      l_line_tbl(I).ship_to_edi_location_code := l_ship_to_location_code;
  /* Code for Blanket Sales Orders */
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Entering into Blanket related model code') ;
      END IF;
      IF l_line_tbl(I).item_type_code = 'INCLUDED' THEN
         l_top_model_line_id := l_line_tbl(I).top_model_line_id;
         OPEN GET_TOP_MODEL(l_top_model_line_id);
         FETCH GET_TOP_MODEL
         INTO
               l_blanket_number,
               l_blanket_line_number;
         IF GET_TOP_MODEL%NOTFOUND THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Blanket number and Blanket line number NOT FOUND for the cursor GET_TOP_MODEL' ) ;
            END IF;
         END IF;
         CLOSE GET_TOP_MODEL;
      l_line_tbl(I).blanket_number := l_blanket_number;
      l_line_tbl(I).blanket_line_number := l_blanket_line_number;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Leaving Blanket related code for the Top Model Line Id: '||l_top_model_line_id) ;
          oe_debug_pub.add(  'Leaving Blanket related code Blanket Number : '||l_blanket_number) ;
          oe_debug_pub.add(  'Leaving Blanket related code Blanket Line Number : '||l_blanket_line_number) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIP TO EDI CODE = '||L_SHIP_TO_LOCATION_CODE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ADDR1 = '||L_LINE_VAL_TBL ( I ) .SHIP_TO_ADDRESS1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIP TO CONTACT ID = '||L_LINE_TBL ( I ) .SHIP_TO_CONTACT_ID ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ACTUAL_SHIPMENT_DATE = '||L_LINE_TBL ( I ) .ACTUAL_SHIPMENT_DATE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ACTUAL_ARRIVAL_DATE = '||L_LINE_TBL ( I ) .ACTUAL_ARRIVAL_DATE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER_DOCK_CODE = '||L_LINE_TBL ( I ) .CUSTOMER_DOCK_CODE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST_PRODUCTION_SEQ_NUM = '||L_LINE_TBL ( I ) .CUST_PRODUCTION_SEQ_NUM ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER_PRODUCTION_LINE = '||L_LINE_TBL ( I ) .CUSTOMER_PRODUCTION_LINE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST_MODEL_SERIAL_NUMBER = '||L_LINE_TBL ( I ) .CUST_MODEL_SERIAL_NUMBER ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER_JOB = '||L_LINE_TBL ( I ) .CUSTOMER_JOB ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER_PAYMENT_TERM = '||L_LINE_VAL_TBL ( I ) .CUSTOMER_PAYMENT_TERM ) ;
      END IF;


   BEGIN
    SELECT a.person_last_name, a.person_first_name
      INTO l_line_val_tbl(I).ship_to_contact_last_name,
           l_line_val_tbl(I).ship_to_contact_first_name
      FROM hz_parties a, hz_relationships b, hz_cust_account_roles c
     WHERE c.cust_account_role_id = l_header_rec.sold_to_contact_id
       AND c.party_id=b.party_id
       AND b.subject_id=a.party_id
       AND c.CUST_ACCOUNT_ID = l_header_rec.sold_to_org_id
 AND   b.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.DIRECTIONAL_FLAG = 'F';
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO CONTACT = '||L_LINE_VAL_TBL ( I ) .SHIP_TO_CONTACT_LAST_NAME ) ;
     END IF;
    EXCEPTION
     WHEN OTHERS THEN
     NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO GET FIRST/LAST NAME FOR LINE SHIP_TO' ) ;
     END IF;
    END;

     BEGIN
         SELECT concatenated_segments
           INTO l_concatenated_segments
           FROM mtl_system_items_vl
          WHERE inventory_item_id = l_line_tbl(I).inventory_item_id
            AND organization_id = l_validation_org_id;
         l_line_val_tbl(I).inventory_item := l_concatenated_segments;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ITEM ID = '||L_LINE_TBL ( I ) .INVENTORY_ITEM_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ITEM NAME = '||L_LINE_VAL_TBL ( I ) .INVENTORY_ITEM ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INDEX IS = '||I ) ;
         END IF;
      EXCEPTION
     WHEN OTHERS THEN
     NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO GET ITEM NAME' ) ;
     END IF;
    END;
         /* 1944673   */
         l_line_val_tbl(i).line_type := OE_Id_To_Value.Line_Type
        (   p_line_type_id                => l_line_tbl(i).line_type_id );

         l_line_val_tbl(i).price_list := OE_Id_To_Value.price_list
        (   p_price_list_id                => l_line_tbl(i).price_list_id );

         l_line_val_tbl(i).salesrep := OE_Id_To_Value.salesrep
        (   p_salesrep_id          => l_line_tbl(i).salesrep_id );

        l_line_val_tbl(i).fob_point := OE_Id_To_Value.Fob_Point
        (   p_Fob_Point_code          => l_line_tbl(i).fob_point_code );

        l_line_val_tbl(i).freight_terms := OE_Id_To_Value.freight_terms
        (   p_freight_terms_code          => l_line_tbl(i).freight_terms_code );

        l_line_val_tbl(i).Agreement := OE_Id_To_Value.Agreement
        (   p_agreement_id         => l_line_tbl(i).agreement_id );

        l_line_val_tbl(i).payment_term := OE_Id_To_Value.payment_term
        (   p_payment_term_id         => l_line_tbl(i).payment_term_id );

--Added for bug 4034441 start
        Oe_Id_To_Value.End_Customer(  p_end_customer_id => l_line_tbl(i).end_customer_id
,   x_end_customer_name => l_line_val_tbl(i).end_customer_name
,   x_end_customer_number => l_line_val_tbl(i).end_customer_number
);
        l_line_val_tbl(i).end_customer_contact := Oe_Id_To_Value.End_Customer_Contact(p_end_customer_contact_id => l_line_tbl(i).end_customer_contact_id);

      OE_ID_TO_VALUE.End_Customer_Site_Use(  p_end_customer_site_use_id => l_line_tbl(i).end_customer_site_use_id
,   x_end_customer_address1 => l_line_val_tbl(i).end_customer_site_address1
,   x_end_customer_address2 => l_line_val_tbl(i).end_customer_site_address2
,   x_end_customer_address3 => l_line_val_tbl(i).end_customer_site_address3
,   x_end_customer_address4 => l_line_val_tbl(i).end_customer_site_address4
,   x_end_customer_location => l_line_val_tbl(i).end_customer_site_location
,   x_end_customer_city => l_line_val_tbl(i).end_customer_site_city
,   x_end_customer_state => l_line_val_tbl(i).end_customer_site_state
,   x_end_customer_postal_code => l_line_val_tbl(i).end_customer_site_postal_code
,   x_end_customer_country => l_line_val_tbl(i).end_customer_site_country
);
 --Added for bug 4034441 end


        /* -----------------------------------------------------------------
          Derive ship_from address for Lines   Bug #2116166
           -----------------------------------------------------------------
        */
 BEGIN
    select hu.location_id,hl.ece_tp_location_code, hl.location_code
    into l_ship_from_addr_id, l_ship_from_location_code,l_ship_from_addr_code
    from hr_all_organization_units hu,
       hr_locations hl
    where hl.location_id = hu.location_id
    AND hu.organization_id = l_line_tbl(I).ship_from_org_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP-FROM LINE ADDR ID = '||L_SHIP_FROM_ADDR_ID ) ;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO DERIVE SHIP_FROM ADDR FOR LINE' ) ;
     END IF;
   END;

        get_address(
           p_address_type_in      => 'HR_LOCATION',
           p_org_id_in            => l_validation_org_id,
           p_address_id_in        => l_ship_from_addr_id,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);

    l_line_val_tbl(I).ship_from_address1 := SUBSTR(l_addr1,0,240);
    l_line_val_tbl(I).ship_from_address2 := SUBSTR(l_addr2,0,240);
    l_line_val_tbl(I).ship_from_address3 := SUBSTR(l_addr3,0,240);
    l_line_val_tbl(I).ship_from_address4 := SUBSTR(l_addr4,0,240);
    l_line_val_tbl(I).ship_from_region1 := SUBSTR(l_region1,0,240);
    l_line_val_tbl(I).ship_from_city := SUBSTR(l_city,0,60);
    l_line_val_tbl(I).ship_from_postal_code := SUBSTR(l_zip,0,60);
    l_line_val_tbl(I).ship_from_country := SUBSTR(l_country,0,60);
    l_line_val_tbl(I).ship_from_region2 := SUBSTR(l_region2,0,240);
    l_line_val_tbl(I).ship_from_region3 := SUBSTR(l_region3,0,240);
    l_line_val_tbl(I).ship_from_org     := l_ship_from_addr_code;
    l_line_tbl(I).ship_from_edi_location_code := SUBSTR(l_ship_from_location_code,0,40);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADDR1 = '||L_LINE_VAL_TBL ( I ) .SHIP_FROM_ADDRESS1 ) ;
    END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE WHILE LOOP I = '||I ) ;
     END IF;

       if (l_line_tbl(I).operation is NULL OR
         l_line_tbl(I).operation = FND_API.G_MISS_CHAR )
         THEN l_line_tbl(I).operation := NULL;
       end if;
	 i:= l_line_tbl.next(i);
    END LOOP;

   /* -----------------------------------------------------------------
      Derive ship_from address for Header   Bug #2116166
      -----------------------------------------------------------------
   */
 BEGIN
  select hu.location_id,hl.ece_tp_location_code, hl.location_code
  into l_ship_from_addr_id, l_ship_from_location_code,l_ship_from_addr_code
  from hr_all_organization_units hu,
       hr_locations hl
  where hl.location_id = hu.location_id
  AND hu.organization_id = l_header_rec.ship_from_org_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP-FROM HEADER ADDR ID = '||L_SHIP_FROM_ADDR_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP-FROM HEADER SHIP_FROM ORG = '||L_HEADER_REC.SHIP_FROM_ORG_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP-FROM HEADER EDI LOC CODE = '||L_SHIP_FROM_LOCATION_CODE ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP-FROM HEADER ADDR CODE = '||L_SHIP_FROM_ADDR_CODE ) ;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO DERIVE SHIP_FROM ADDR FOR HEADER' ) ;
     END IF;
  END;

        get_address(
           p_address_type_in      => 'HR_LOCATION',
           p_org_id_in            => l_header_rec.ship_from_org_id,
           p_address_id_in        => l_ship_from_addr_id,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);

    l_header_val_rec.ship_from_address1 := SUBSTR(l_addr1,0,240);
    l_header_val_rec.ship_from_address2 := SUBSTR(l_addr2,0,240);
    l_header_val_rec.ship_from_address3 := SUBSTR(l_addr3,0,240);
    l_header_val_rec.ship_from_address4 := SUBSTR(l_addr4,0,240);
    l_header_val_rec.ship_from_region1 := SUBSTR(l_region1,0,240);
    l_header_val_rec.ship_from_city := SUBSTR(l_city,0,60);
    l_header_val_rec.ship_from_postal_code := SUBSTR(l_zip,0,60);
    l_header_val_rec.ship_from_country := SUBSTR(l_country,0,60);
    l_header_val_rec.ship_from_region2 := SUBSTR(l_region2,0,240);
    l_header_val_rec.ship_from_region3 := SUBSTR(l_region3,0,240);
    l_header_val_rec.ship_from_org    := l_ship_from_addr_code;
    l_header_rec.ship_from_edi_location_code := l_ship_from_location_code;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADDR1 = '||L_HEADER_VAL_REC.SHIP_FROM_ADDRESS1 ) ;
    END IF;

/* -----------------------------------------------------------------
-- IF the local variable is not set above meaning that data at line
-- level has not changed for sending acknowledgments, check
-- at header level also, else the following check is not required.
-- -----------------------------------------------------------------
*/
    IF l_ack_req_flag = 'N' And
       l_header_rec_isnull = 'N' THEN
       IF NOT (OE_GLOBALS.Equal(l_header_rec.cust_po_number,
                                l_old_header_rec.cust_po_number)
          AND  OE_GLOBALS.Equal(l_header_rec.ship_to_org_id,
                                l_old_header_rec.ship_to_org_id)
          AND  OE_GLOBALS.Equal(l_header_rec.ordered_date,
                                l_old_header_rec.ordered_date))

       THEN
               l_ack_req_flag := 'H';
       END IF;
    END IF;


/* ------------------------------------------------------
   Derive sold_to_location for header
   -----------------------------------------------------
*/
BEGIN
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SOLD_TO_SITE_USE_ID: ' || l_header_rec.sold_to_site_use_id) ;
      END IF;

    OE_ID_TO_VALUE.Customer_Location(p_sold_to_site_use_id => l_header_rec.sold_to_site_use_id,
				     x_sold_to_location_address1 => l_header_val_rec.sold_to_location_address1,
				     x_sold_to_location_address2 =>  l_header_val_rec.sold_to_location_address2,
				     x_sold_to_location_address3 =>  l_header_val_rec.sold_to_location_address3,
				     x_sold_to_location_address4 =>  l_header_val_rec.sold_to_location_address4,
				     x_sold_to_location          =>  l_header_val_rec.sold_to_location,
				     x_sold_to_location_city	  =>  l_header_val_rec.sold_to_location_city,
				     x_sold_to_location_state    =>  l_header_val_rec.sold_to_location_state,
				     x_sold_to_location_postal   =>  l_header_val_rec.sold_to_location_postal,
			             x_sold_to_location_country  =>  l_header_val_rec.sold_to_location_country);

EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE SOLD_TO_LOCATION FOR HEADER' ) ;
      END IF;
END;


--Added for bug 4034441 start
/* ------------------------------------------------------
   Derive end_customer for header
   -----------------------------------------------------
*/

BEGIN
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'END CUSTOMER ID: ' || l_header_rec.end_customer_id) ;
      END IF;

    OE_ID_TO_VALUE.End_Customer(  p_end_customer_id => l_header_rec.end_customer_id
,   x_end_customer_name => l_header_val_rec.end_customer_name
,   x_end_customer_number => l_header_val_rec.end_customer_number
);

EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE END CUSTOMER FOR HEADER' ) ;
      END IF;
END;



/* ------------------------------------------------------
   Derive end_customer contact for header
   -----------------------------------------------------
*/

BEGIN
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'END CUSTOMER CONTACT ID: ' || l_header_rec.end_customer_contact_id) ;
      END IF;

    l_header_val_rec.end_customer_contact := OE_ID_TO_VALUE.End_Customer_Contact(  p_end_customer_contact_id => l_header_rec.end_customer_contact_id);

EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE END CUSTOMER CONTACT FOR HEADER' ) ;
      END IF;
END;



/* ------------------------------------------------------
   Derive end_customer location for header
   -----------------------------------------------------
*/

BEGIN
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'END CUSTOMER SITE USE ID: ' || l_header_rec.end_customer_site_use_id) ;
      END IF;

    OE_ID_TO_VALUE.End_Customer_Site_Use(  p_end_customer_site_use_id => l_header_rec.end_customer_site_use_id
,   x_end_customer_address1 => l_header_val_rec.end_customer_site_address1
,   x_end_customer_address2 => l_header_val_rec.end_customer_site_address2
,   x_end_customer_address3 => l_header_val_rec.end_customer_site_address3
,   x_end_customer_address4 => l_header_val_rec.end_customer_site_address4
,   x_end_customer_location => l_header_val_rec.end_customer_site_location
,   x_end_customer_city => l_header_val_rec.end_customer_site_city
,   x_end_customer_state => l_header_val_rec.end_customer_site_state
,   x_end_customer_postal_code => l_header_val_rec.end_customer_site_postal_code
,   x_end_customer_country => l_header_val_rec.end_customer_site_country
);

EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE END CUSTOMER LOCATION FOR HEADER' ) ;
      END IF;
END;
--Added for bug 4034441 end



/* ------------------------------------------------------
   Derive sold_to,ship_to and  bill_to address for header
   -----------------------------------------------------
*/

   BEGIN
    -- Fix for the bug 2722519
    SELECT b.cust_acct_site_id, a.ece_tp_location_code,b.location
      INTO l_bill_to_addr_id, l_bill_to_location_code,l_bill_to_addr_code
      FROM hz_cust_acct_sites_all a, hz_cust_site_uses_all b
     WHERE a.cust_acct_site_id = b.cust_acct_site_id
       AND b.site_use_id = l_header_rec.invoice_to_org_id
       AND b.site_use_code='BILL_TO';
-- removed unnecessary validation of customer account, bug 3656640

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BILL TO ADDR ID = '||L_BILL_TO_ADDR_ID ) ;
    END IF;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE BILL_TO ADDR FOR HEAD' ) ;
      END IF;
  END;

  BEGIN
    -- Fix for the bug 2722519
    SELECT b.cust_acct_site_id, a.ece_tp_location_code,b.location
      INTO l_ship_to_addr_id, l_ship_to_location_code,l_ship_to_addr_code
      FROM hz_cust_acct_sites_all a, hz_cust_site_uses_all b
     WHERE a.cust_acct_site_id = b.cust_acct_site_id
       AND b.site_use_id = l_header_rec.ship_to_org_id
       AND b.site_use_code='SHIP_TO';
-- removed unnecessary validation of customer account, bug 3656640

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO ADDR ID = '||L_SHIP_TO_ADDR_ID ) ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE SHIP_TO ADDR FOR HEAD' ) ;
      END IF;
  END;

 BEGIN
        SELECT b.cust_acct_site_id, a.ece_tp_location_code,b.location
      INTO l_sold_to_addr_id, l_sold_to_location_code,l_sold_to_addr_code
      FROM hz_cust_acct_sites_all a, hz_cust_site_uses_all b
     WHERE a.cust_acct_site_id = b.cust_acct_site_id
       AND b.site_use_id = l_header_rec.sold_to_org_id
       AND b.site_use_code='SOLD_TO'
       AND a.cust_account_id  = l_header_rec.sold_to_org_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD TO ADDR ID = '||L_SOLD_TO_ADDR_ID ) ;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE SOLD_TO ADDR FOR HEAD' ) ;
      END IF;
  END;

    get_address(
           p_address_type_in      => 'CUSTOMER',
           p_org_id_in            => l_validation_org_id,
           p_address_id_in        => l_bill_to_addr_id,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);
    l_header_val_rec.invoice_to_address1 := SUBSTR(l_addr1,0,240);
    l_header_val_rec.invoice_to_address2 := SUBSTR(l_addr2,0,240);
    l_header_val_rec.invoice_to_address3 := SUBSTR(l_addr3,0,240);
    l_header_val_rec.invoice_to_address4 := SUBSTR(l_addr4,0,240);
    l_header_val_rec.invoice_to_state := SUBSTR(l_state,0,60);
    l_header_val_rec.invoice_to_city := SUBSTR(l_city,0,60);
    l_header_val_rec.invoice_to_zip := SUBSTR(l_zip,0,60);
    l_header_val_rec.invoice_to_country := SUBSTR(l_country,0,60);
    l_header_val_rec.invoice_to_county := SUBSTR(l_county,0,60);
    l_header_val_rec.invoice_to_province := SUBSTR(l_province,0,60);
    l_header_val_rec.invoice_to_location :=  l_bill_to_addr_code;
    l_header_val_rec.ship_to_location :=  l_ship_to_addr_code;
    l_header_val_rec.invoice_to_customer_number :=SUBSTR(l_sold_to_addr_code,0,30);
    l_header_rec.bill_to_edi_location_code := l_bill_to_location_code;
    l_header_rec.ship_to_edi_location_code := l_ship_to_location_code;
    l_header_rec.sold_to_edi_location_code := l_sold_to_location_code;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD TO LOCATION CODE = '||L_SOLD_TO_ADDR_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO EDI CODE = '||L_SHIP_TO_LOCATION_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BILL TO EDI CODE = '||L_BILL_TO_LOCATION_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADDR1 = '||L_HEADER_VAL_REC.INVOICE_TO_ADDRESS1 ) ;
    END IF;

     get_address(
           p_address_type_in      => 'CUSTOMER',
           p_org_id_in            => l_validation_org_id,
           p_address_id_in        => l_ship_to_addr_id,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);

    l_header_val_rec.ship_to_address1 := SUBSTR(l_addr1,0,240);
    l_header_val_rec.ship_to_address2 := SUBSTR(l_addr2,0,240);
    l_header_val_rec.ship_to_address3 := SUBSTR(l_addr3,0,240);
    l_header_val_rec.ship_to_address4 := SUBSTR(l_addr4,0,240);
    l_header_val_rec.ship_to_state := SUBSTR(l_state,0,60);
    l_header_val_rec.ship_to_city := SUBSTR(l_city,0,60);
    l_header_val_rec.ship_to_zip := SUBSTR(l_zip,0,60);
    l_header_val_rec.ship_to_country := SUBSTR(l_country,0,60);
    l_header_val_rec.ship_to_county := SUBSTR(l_county,0,60);
    l_header_val_rec.ship_to_province := SUBSTR(l_province,0,240);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADDR1 = '||L_HEADER_VAL_REC.SHIP_TO_ADDRESS1 ) ;
    END IF;

        get_address(
           p_address_type_in      => 'CUSTOMER',
           p_org_id_in            => l_validation_org_id,
           p_address_id_in        => G_CURR_ADDRESS_ID,
           p_tp_location_code_in  => NULL,
           p_tp_translator_code_in => NULL,
           l_addr1                => l_addr1,
           l_addr2                => l_addr2,
           l_addr3                => l_addr3,
           l_addr4                => l_addr4,
           l_addr_alt             => l_addr_alt,
           l_city                 => l_city,
           l_county               => l_county,
           l_state                => l_state,
           l_zip                  => l_zip,
           l_province             => l_province,
           l_country              => l_country,
           l_region1              => l_region1,
           l_region2              => l_region2,
           l_region3              => l_region3,
           x_return_status        => x_return_status);

    l_header_val_rec.sold_to_address1 := SUBSTR(l_addr1,0,240);
    l_header_val_rec.sold_to_address2 := SUBSTR(l_addr2,0,240);
    l_header_val_rec.sold_to_address3 := SUBSTR(l_addr3,0,240);
    l_header_val_rec.sold_to_address4 := SUBSTR(l_addr4,0,240);
    l_header_val_rec.sold_to_state := SUBSTR(l_state,0,60);
    l_header_val_rec.sold_to_city := SUBSTR(l_city,0,60);
    l_header_val_rec.sold_to_zip := SUBSTR(l_zip,0,60);
    l_header_val_rec.sold_to_country := SUBSTR(l_country,0,60);
    l_header_val_rec.sold_to_county := SUBSTR(l_county,0,60);
    l_header_val_rec.sold_to_province := SUBSTR(l_province,0,240);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADDR1 = '||L_HEADER_VAL_REC.SOLD_TO_ADDRESS1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INV CONTACT ID = '||L_HEADER_REC.INVOICE_TO_CONTACT_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO CONTACT ID= '||L_HEADER_REC.SHIP_TO_CONTACT_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD TO CONTACT ID = '||L_HEADER_REC.SOLD_TO_CONTACT_ID ) ;
    END IF;

   BEGIN
    SELECT a.person_last_name, a.person_first_name
      INTO l_header_val_rec.sold_to_contact_last_name, l_header_val_rec.sold_to_contact_first_name
      FROM hz_parties a, hz_relationships b, hz_cust_account_roles c
     WHERE c.cust_account_role_id = l_header_rec.sold_to_contact_id
       AND c.party_id=b.party_id
       AND b.subject_id=a.party_id
       AND c.CUST_ACCOUNT_ID = l_header_rec.sold_to_org_id
 AND   b.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.DIRECTIONAL_FLAG = 'F';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD TO CONTACT = '||L_HEADER_VAL_REC.SOLD_TO_CONTACT_LAST_NAME ) ;
    END IF;
     EXCEPTION
    WHEN OTHERS THEN
      NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNABLE TO DERIVE SOLD_TO_CONTACT LAST NAME FOR HEAD' ) ;
      END IF;
  END;

 BEGIN

    SELECT a.person_last_name, a.person_first_name
      INTO l_header_val_rec.ship_to_contact_last_name, l_header_val_rec.ship_to_contact_first_name
      FROM hz_parties a, hz_relationships b, hz_cust_account_roles c
     WHERE c.cust_account_role_id = l_header_rec.ship_to_contact_id
       AND c.party_id=b.party_id
       AND b.subject_id=a.party_id
       AND c.CUST_ACCOUNT_ID = l_header_rec.sold_to_org_id
 AND   b.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.DIRECTIONAL_FLAG = 'F';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO CONTACT = '||L_HEADER_VAL_REC.SHIP_TO_CONTACT_LAST_NAME ) ;
    END IF;
      EXCEPTION
    WHEN OTHERS THEN
      NULL;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNABLE TO DERIVE SHIP_TO_CONTACT LAST NAME FOR HEAD' ) ;
    END IF;
  END;
         l_header_val_rec.order_type := OE_Id_To_Value.Order_Type
     (   p_order_type_id               => l_header_rec.order_type_id );

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_HEADER_REC: '||L_HEADER_VAL_REC.ORDER_TYPE ) ;
     END IF;
     l_header_val_rec.payment_term := OE_Id_To_Value.Payment_Term
     (   p_payment_term_id             => l_header_rec.payment_term_id );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_HEADER_REC: PAYMENT TERM :'||L_HEADER_VAL_REC.PAYMENT_TERM ) ;
     END IF;

     l_header_val_rec.price_list := OE_Id_To_Value.Price_List
        (   p_price_list_id               => l_header_rec.price_list_id );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_HEADER_REC: PRICE LIST '||L_HEADER_VAL_REC.PRICE_LIST ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_HEADER_REC: ORDER_CATEGORY_CODE '||L_HEADER_REC.ORDER_CATEGORY_CODE ) ;
     END IF;

    l_header_val_rec.salesrep := OE_Id_To_Value.salesrep
        (   p_salesrep_id          => l_header_rec.salesrep_id
        );

    l_header_val_rec.fob_point := OE_Id_To_Value.fob_point
        (   p_fob_point_code       => l_header_rec.fob_point_code
       );

    l_header_val_rec.freight_terms := OE_Id_To_Value.freight_terms
        (   p_freight_terms_code       => l_header_rec.freight_terms_code
       );

    l_header_val_rec.agreement := OE_Id_To_Value.agreement
        (   p_agreement_id       => l_header_rec.agreement_id
       );

    l_header_val_rec.conversion_type := OE_Id_To_Value.Conversion_Type
        (   p_conversion_type_code        => l_header_rec.conversion_type_code
        );

    l_header_val_rec.tax_exempt_reason := OE_Id_To_Value.Tax_Exempt_Reason
        (   p_tax_exempt_reason_code      => l_header_rec.tax_exempt_reason_code
        );

    l_header_val_rec.tax_point := OE_Id_To_Value.Tax_Point
        (   p_tax_point_code              => l_header_rec.tax_point_code
        );

    l_header_val_rec.invoicing_rule := OE_Id_To_Value.Invoicing_Rule
        (   p_invoicing_rule_id           => l_header_rec.invoicing_rule_id
        );

    OE_Id_To_Value.Sold_To_Org
        (   p_sold_to_org_id              => l_header_rec.sold_to_org_id
        ,   x_org                         => l_header_val_rec.sold_to_org
        ,   x_customer_number             => l_header_val_rec.customer_number
        );

    Oe_Id_To_Value.Deliver_To_Org       -- For bug 2701018
        (   p_deliver_to_org_id           => l_header_rec.deliver_to_org_id
	,   x_deliver_to_address1         => l_header_val_rec.deliver_to_address1
	,   x_deliver_to_address2         => l_header_val_rec.deliver_to_address2
	,   x_deliver_to_address3         => l_header_val_rec.deliver_to_address3
	,   x_deliver_to_address4         => l_header_val_rec.deliver_to_address4
	,   x_deliver_to_location         => l_header_val_rec.deliver_to_location
	,   x_deliver_to_org              => l_header_val_rec.deliver_to_org
	,   x_deliver_to_city             => l_header_val_rec.deliver_to_city
	,   x_deliver_to_state            => l_header_val_rec.deliver_to_state
	,   x_deliver_to_postal_code      => l_header_val_rec.deliver_to_zip
	,   x_deliver_to_country          => l_header_val_rec.deliver_to_country
        );
    l_header_val_rec.deliver_to_customer_number := NULL;   --For bug 2701018

    l_header_val_rec.sold_to_contact := OE_Id_To_Value.Sold_To_Contact
        (   p_sold_to_contact_id          => l_header_rec.sold_to_contact_id
        );

    l_header_val_rec.ship_to_contact := OE_Id_To_Value.Ship_To_Contact
        (   p_ship_to_contact_id          => l_header_rec.ship_to_contact_id
        );

    if (l_header_val_rec.customer_payment_term is NULL OR
     l_header_val_rec.customer_payment_term = FND_API.G_MISS_CHAR )
     THEN l_header_val_rec.customer_payment_term := NULL;
    end if;

    l_header_val_rec.ship_to_org :=l_header_val_rec.ship_to_location;
    l_header_val_rec.invoice_to_org :=l_header_val_rec.invoice_to_location;

    -- for bug 3656640
    OE_ID_TO_VALUE.Ship_To_Customer_Name(p_ship_to_org_id => l_header_rec.ship_to_org_id,
                                         x_ship_to_customer_name => l_header_val_rec.ship_to_customer_name);

    -- for bug 4489065
    OE_ID_TO_VALUE.Invoice_To_Customer_Name(p_invoice_to_org_id => l_header_rec.invoice_to_org_id,
                                         x_invoice_to_customer_name => l_header_val_rec.invoice_to_customer_name);


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_HEADER_REC: SALES REP '||L_HEADER_VAL_REC.SALESREP ) ;
   END IF;

  BEGIN
    SELECT a.person_last_name, a.person_first_name
      INTO l_header_val_rec.invoice_to_contact_last_name, l_header_val_rec.invoice_to_contact_first_name
      FROM hz_parties a, hz_relationships b, hz_cust_account_roles c
     WHERE c.cust_account_role_id = l_header_rec.invoice_to_contact_id
       AND c.party_id=b.party_id
       AND b.subject_id=a.party_id
       AND c.CUST_ACCOUNT_ID = l_header_rec.sold_to_org_id
 AND   b.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   b.DIRECTIONAL_FLAG = 'F';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVOICE TO CONTACT = '||L_HEADER_VAL_REC.INVOICE_TO_CONTACT_LAST_NAME ) ;
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HEADER_REC: PAYMENT TERM :'||L_HEADER_VAL_REC.PAYMENT_TERM ) ;
    END IF;


  EXCEPTION
     WHEN OTHERS THEN
     NULL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNABLE TO DERIVE LAST/FIRST NAME FOR HEADER' ) ;
     END IF;
  END;

/* -------------------------------------------------------------
    Since now all the required information is there to create the
    acknowledgment records, start inserting the records based on
    the l_ack_req_flag value.
   -------------------------------------------------------------
*/
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_ACK_REQ_FLAG = '||L_ACK_REQ_FLAG , 3 ) ;
    END IF;

    IF l_ack_req_flag IN ('B', 'H')
    OR l_header_rec.first_ack_code is null THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE INSERTING HEADER ACKNOWLEDGMENT RECORD' , 3 ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EDI LOCATION CODE'||L_HEADER_REC.SHIP_FROM_EDI_LOCATION_CODE ) ;
        END IF;

        l_rejected_lines := 'Y';
        /* Bug 2416561 : Calling the Convert_Miss_To_Null for the id records */
        OE_Header_Util.Convert_Miss_To_Null(p_x_header_rec  => l_header_rec);

        OE_Header_Ack_Util.Insert_Row
	(   p_header_rec            =>  l_header_rec
        ,   p_header_val_rec        =>  l_header_val_rec
        ,   p_old_header_rec        =>  l_old_header_rec
        ,   p_old_header_val_rec    =>  l_old_header_val_rec
        ,   p_reject_order          =>  p_reject_order
        ,   x_return_status         =>  l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;  -- End of IF l_ack_req_flag IN ('B', 'H')


    --  Insert Line Information

    --  Check if line acknowledgment need to be sent
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CHECK IF LINE ACKNOWLEDGMENT NEED TO BE SENT' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_ACK_REQ_FLAG'|| L_ACK_REQ_FLAG ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HEADER_REC.FIRST_ACK_CODE :'||L_HEADER_REC.FIRST_ACK_CODE ) ;
    END IF;
    IF l_ack_req_flag = 'B'
    OR l_header_rec.first_ack_code is null THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE INSERTING LINE ACKNOWLEDGMENT RECORD' , 3 ) ;
        END IF;
        OE_Line_Ack_Util.Insert_Row
	   (p_line_tbl             =>  l_line_tbl
        ,   p_line_val_tbl         =>  l_line_val_tbl
        ,   p_old_line_tbl         =>  l_old_line_tbl
        ,   p_old_line_val_tbl     =>  l_old_line_val_tbl
        ,   p_reject_order         =>  p_reject_order
        ,   x_return_status        =>  l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        --  Insert Lots Information

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE INSERTING LINE LOTSERIAL ACKNOWLEDGMENT RECORD' , 3 ) ;
        END IF;

        OE_Lots_Ack_Util.Insert_Row
	(   p_lot_serial_tbl          =>  l_lot_serial_tbl
        ,   p_old_lot_serial_tbl      =>  l_old_lot_serial_tbl
        ,   p_lot_serial_val_tbl      =>  l_lot_serial_val_tbl
        ,   p_old_lot_serial_val_tbl  =>  l_old_lot_serial_val_tbl
        ,   p_line_tbl                =>  l_line_tbl
        ,   p_old_line_tbl            =>  l_old_line_tbl
        ,   p_reject_order            =>  p_reject_order
        ,   x_return_status           =>  l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    --  Call Get_Reject_Line to get rejected lines and Lotserials
    --  if l_rejected_line = 'Y'

        IF l_debug_level  > 0 THEN
         oe_debug_pub.add('before getting rejected lines' , 3 ) ;
         oe_debug_pub.add('Order_source_id ' || l_header_rec.order_source_id);
         oe_debug_pub.add('Request_id ' || l_header_rec.request_id);
         oe_debug_pub.add('Orig_Sys_Doc '|| l_header_rec.orig_sys_document_ref);
         oe_debug_pub.add('Change_Seq ' || l_header_rec.change_sequence);
        END IF;

        OE_Rejected_Lines_Ack.Get_Rejected_Lines
        (   p_request_id              =>  l_header_rec.request_id
        ,   p_order_source_id         =>  l_header_rec.order_source_id
        ,   p_orig_sys_document_ref   =>  l_header_rec.orig_sys_document_ref
        ,   p_change_sequence         =>  l_header_rec.change_sequence
        ,   x_rejected_line_tbl       =>  l_reject_line_tbl
        ,   x_rejected_line_val_tbl   =>  l_reject_line_val_tbl
        ,   x_rejected_lot_serial_tbl =>  l_reject_lot_serial_tbl
        ,   x_return_status           =>  l_return_status
        ,   p_header_id               =>  l_header_rec.header_id
        ,   p_sold_to_org             =>  l_header_val_rec.sold_to_org
        ,   p_sold_to_org_id          =>  l_header_rec.sold_to_org_id
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


	-- Insert rejected lines and lotserials only if got any rejected records

	IF l_reject_line_tbl.COUNT > 0 THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE INSERTING REJECTED LINES' , 3 ) ;
           END IF;

           OE_Line_Ack_Util.Insert_Row
	   (p_line_tbl             =>  l_reject_line_tbl
           ,p_old_line_tbl         =>  l_reject_line_tbl
           ,p_line_val_tbl         =>  l_reject_line_val_tbl
           ,p_old_line_val_tbl     =>  l_reject_line_val_tbl
           ,p_buyer_seller_flag    =>  'B'
           ,p_reject_order         =>  l_create_rejects
           ,x_return_status        =>  l_return_status
           );

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_reject_lot_serial_tbl.COUNT > 0 THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE INSERTING REJECTED LINE LOTSERIALS' , 3 ) ;
             END IF;

             OE_Lots_Ack_Util.Insert_Row
	     (p_lot_serial_tbl          =>  l_reject_lot_serial_tbl
             ,p_lot_serial_val_tbl      =>  l_reject_lot_serial_val_tbl
             ,p_old_lot_serial_tbl      =>  l_reject_lot_serial_tbl
             ,p_old_lot_serial_val_tbl  =>  l_reject_lot_serial_val_tbl
             ,p_line_tbl                =>  l_reject_line_tbl
             ,p_old_line_tbl            =>  l_reject_line_tbl
             ,p_reject_order            =>  l_create_rejects
             ,x_return_status           =>  l_return_status
             );

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF; -- IF l_reject_lot_serial_tbl.COUNT > 0
        END IF; -- IF l_reject_line_tbl.COUNT > 0
    END IF; -- IF l_ack_req_flag = 'B'

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED ERROR EXCEPTION' , 2 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED UNEXPECTED ERROR EXCEPTION'||SQLERRM , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED OTHERS ERROR EXCEPTION IN OE_ACKNOWLEDGMENT_PVT.PROCESS_ACKNOWLEDGMENT: '||SQLERRM , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           OE_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME, 'OE_Acknowledgment_Pvt.Process_Acknowledgment');
        END IF;


END Process_Acknowledgment;


Procedure Process_Acknowledgment
 (p_header_rec                   In   OE_Order_Pub.Header_Rec_Type,
  p_line_tbl                     In   OE_Order_Pub.Line_Tbl_Type,
  p_old_header_rec               In   OE_Order_Pub.Header_Rec_Type,
  p_old_line_tbl                 In   OE_Order_Pub.Line_Tbl_Type,
  x_return_status                Out NOCOPY /* file.sql.39 change */  VARCHAR2
 )
Is

  l_debug_level                  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_status                       Varchar2(1);
  l_industry                     Varchar2(1);
  l_o_schema                     Varchar2(30);
  l_booked_flag                  Varchar2(1);
  l_line_index                   Pls_Integer;
  l_header_rec                   OE_Order_Pub.Header_Rec_Type := p_header_rec;
  l_line_tbl                     OE_Order_Pub.Line_Tbl_Type := p_line_tbl;
  l_address_id                   Number;
  l_site_use_id                  Number;
  l_tp_ret                       Boolean;
  l_tp_ret_status                Varchar2(200);
  l_msg_count                    Number;
  l_msg_data                     Varchar2(200);
  l_ack_req_flag                 Varchar2(1) := 'N';
  i                              Pls_Integer;
  j                              Pls_Integer;
  l_line_rec                     OE_Order_Pub.Line_Rec_Type ;
  l_old_line_tbl                 OE_Order_Pub.Line_Tbl_Type := p_old_line_tbl;
  l_old_header_rec               OE_Order_Pub.Header_Rec_Type := p_old_header_rec;
  l_return_status                Varchar2(1);
  l_rejected_lines               Varchar2(1);

  l_reject_line_tbl             OE_Order_Pub.Line_Tbl_Type;
  l_reject_line_val_tbl         OE_Order_Pub.Line_Val_Tbl_Type;
  l_reject_Lot_Serial_tbl       OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_reject_Lot_Serial_val_tbl   OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

  l_xml_message_id               Number;
  l_ack_type                     Varchar2(30);
  l_sold_to_org                  Varchar2(360);
  l_customer_number              Varchar2(30);
  l_raise_event                  Varchar2(1);
  l_message_text                 Varchar2(500);
  l_header_rec_isnull            varchar2(1) := 'N';

  -- bug 3439319
  l_sales_order_id           Number;
Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Entering New Process Acknowledgment');
  End If;

  -- Check if EC is installed
  If Oe_Globals.G_EC_INSTALLED Is Null Then
    Oe_Globals.G_EC_INSTALLED := Oe_Globals.Check_Product_Installed(175);
  End If;
  If Oe_Globals.G_EC_INSTALLED <> 'Y' Then
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    If l_debug_level > 0 Then
      oe_debug_pub.add('EC not installed');
    End If;
      -- Raise event to log message
    Return;
  End If;

  If (l_header_rec.header_id <> FND_API.G_MISS_NUM And
      nvl(l_header_rec.header_id,0) <> 0) Then
    Begin
      Select booked_flag,xml_message_id
      Into   l_booked_flag,l_xml_message_id
      From   oe_order_headers
      Where    header_id = l_header_rec.header_id;
      If l_booked_flag = 'Y' Then
        l_header_rec.booked_flag := l_booked_flag;
      End If;
      If l_header_rec.order_source_id = 0 And
         l_xml_message_id Is Null Then
        Select Oe_Xml_Message_Seq_S.nextval
        Into   l_xml_message_id
        From   dual;
        l_header_rec.xml_message_id := l_xml_message_id;
      End IF;
    Exception
      When Others Then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        If l_debug_level > 0 Then
          oe_debug_pub.add('Exception in getting booked flag');
        End If;
        Return;
    End;
  Elsif l_line_tbl.count > 0 And
        (l_header_rec.header_id = FND_API.G_MISS_NUM OR
         nvl(l_header_rec.header_id,0) = 0) AND
         (l_line_tbl(l_line_tbl.first).header_id <> FND_API.G_MISS_NUM AND
         nvl(l_line_tbl(l_line_tbl.first).header_id,0) <> 0) Then
    Begin
      l_line_index := l_line_tbl.First;
         -- start bug 4048709, if the global picture header record is not present
         -- that means that there were no header level changes
         -- but we still need the header record to perform tp check + send ack,
         -- so get it from the cache if possible
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Header Id in cache is : '||oe_order_cache.g_header_rec.header_id);
         END IF;
         IF OE_ORDER_CACHE.g_header_rec.header_id <> FND_API.G_MISS_NUM AND
        	     nvl(OE_ORDER_CACHE.g_header_rec.header_id,0) = l_line_tbl(l_line_index).header_id THEN
            l_header_rec := OE_ORDER_CACHE.g_header_rec;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Assigned header record from cache with booked flag '|| l_header_rec.booked_flag);
            END IF;
         ELSE
         -- end bug 4048709
	      OE_Header_Util.Query_Row
	       (p_header_id => l_line_tbl(l_line_index).header_id,
	        x_header_rec => l_header_rec
       );
         END IF;
      l_header_rec_isnull := 'Y';
    Exception
      When Others Then
        x_return_status  := FND_API.G_RET_STS_SUCCESS;
        If l_debug_level > 0 Then
          oe_debug_pub.add('Exception in l_line_tbl.count > 0');
        End If;
        Return;
    End;
  Else
    -- Nothing to Acknowledge
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    If l_debug_level > 0 Then
      oe_debug_pub.add('Exception else, Nothing to Acknowledge');
    End If;
    Return;
  End If;

  If G_CURR_SOLD_TO_ORG_ID = l_header_rec.sold_to_org_id and
     (G_TP_RET = FALSE Or G_PRIMARY_SETUP = FALSE) Then
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    If l_debug_level > 0 Then
      oe_debug_pub.add('Transaction Not Enabled for Trading Partner');
    End If;
    -- Raise event to log message
    /*
      fnd_message.set_name('ONT', 'OE_OI_OUTBOUND_SETUP_ERR');
      fnd_message.set_token ('TRANSACTION', l_header_rec.xml_transaction_type_code);
      l_message_text := fnd_message.get;
      OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_header_rec.order_source_id,
             p_partner_document_num   =>  l_header_rec.orig_sys_document_ref,
             p_sold_to_org_id         =>  l_header_rec.sold_to_org_id,
             p_order_type_id          => l_header_rec.order_type_id,
             p_transaction_type       =>  'ONT',
             p_transaction_subtype    => l_header_rec.xml_transaction_type_code,
             p_itemtype               => null,
             p_itemkey                => null,
             p_xmlg_document_id       => l_xml_message_id,
             p_message_text           => l_message_text,
             p_document_num           =>  l_header_rec.order_number,
             p_change_sequence        =>  l_header_rec.change_sequence,
             p_org_id                 =>  l_header_rec.org_id,
             p_doc_status             => 'ERROR',
             p_header_id              => l_header_rec.header_id,
             x_return_status          =>  l_return_status);
    */
    Return;
  End If;

  If G_CURR_SOLD_TO_ORG_ID = l_header_rec.sold_to_org_id And
     G_CURR_ADDRESS_ID Is Not Null And
     G_TP_RET = TRUE Then
    goto create_ack;
  End If;

  l_tp_ret := FALSE;

  Begin
    Oe_Debug_Pub.Add('before select of sold to org id');
    Select /*MOAC_SQL_CHANGES*/ b.site_use_id, a.cust_acct_site_id
    Into   l_site_use_id, l_address_id
    From   hz_cust_site_uses b, hz_cust_acct_sites_all a
    Where  a.cust_acct_site_id = b.cust_acct_site_id
    And    a.cust_account_id  = l_header_rec.sold_to_org_id
    And    b.site_use_code = 'SOLD_TO'
    And    b.primary_flag = 'Y'
    And    b.status = 'A'
    And    a.org_id=b.org_id
    And    a.status = 'A';

    G_CURR_SOLD_TO_ORG_ID := l_header_rec.sold_to_org_id;
    G_CURR_ADDRESS_ID     := l_address_id;
    G_PRIMARY_SETUP       := TRUE;
  Exception
    When NO_DATA_FOUND Then
      x_return_status       := FND_API.G_RET_STS_SUCCESS;
      G_CURR_SOLD_TO_ORG_ID := l_header_rec.sold_to_org_id;
      G_CURR_ADDRESS_ID     := NULL;
      G_PRIMARY_SETUP       := FALSE;

      If l_debug_level > 0 Then
        oe_debug_pub.add('No Primary Sold To set');
      End If;
      -- Raise event to log message
      /*
      fnd_message.set_name('ONT', 'OE_OI_TP_NOT_FOUND');
      fnd_message.set_token ('CUST_ID', l_header_rec.sold_to_org_id);
      l_message_text := fnd_message.get;
      OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_header_rec.order_source_id,
             p_partner_document_num   =>  l_header_rec.orig_sys_document_ref,
             p_sold_to_org_id         =>  l_header_rec.sold_to_org_id,
             p_order_type_id          => l_header_rec.order_type_id,
             p_transaction_type       =>  'ONT',
             p_transaction_subtype    => l_header_rec.xml_transaction_type_code,
             p_itemtype               => null,
             p_itemkey                => null,
             p_xmlg_document_id       => l_xml_message_id,
             p_message_text           => l_message_text,
             p_document_num           =>  l_header_rec.order_number,
             p_change_sequence        =>  l_header_rec.change_sequence,
             p_org_id                 =>  l_header_rec.org_id,
             p_doc_status             => 'ERROR',
             p_header_id              => l_header_rec.header_id,
             x_return_status          =>  l_return_status);
      */
      Return;

    When Others Then
      x_return_status       := FND_API.G_RET_STS_SUCCESS;
      If l_debug_level > 0 Then
        oe_debug_pub.add('Not able to get primary sold to exception');
      End If;
      Return;
  End;

  l_tp_ret := EC_TRADING_PARTNER_PVT.Is_Entity_Enabled (
         p_api_version_number   => 1.0
        ,p_init_msg_list        => null
        ,p_simulate             => null
        ,p_commit               => null
        ,p_validation_level     => null
        ,p_transaction_type     => 'POAO'
        ,p_transaction_subtype  => null
        ,p_entity_type          => EC_TRADING_PARTNER_PVT.G_CUSTOMER
        ,p_entity_id            => l_address_id
        ,p_return_status        => l_tp_ret_status
        ,p_msg_count            => l_msg_count
        ,p_msg_data             => l_msg_data);

  IF l_tp_ret = FALSE Then
    G_TP_RET := FALSE;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    If l_debug_level > 0 Then
      oe_debug_pub.add('Transaction not enabled');
    End If;
    -- Raise event to log message
    Return;
  End If;
  G_TP_RET := TRUE;

  <<create_ack>>

  -- Check if data has changed
  j := l_line_tbl.last;
  i := l_line_tbl.first;

  While i Is Not Null Loop
    l_line_rec := l_line_tbl(I);
    oe_line_util.Convert_Miss_To_Null(p_x_line_rec  =>l_line_rec);
    l_line_tbl(I) := l_line_rec;

    -- bug 3439319 added this block instead of NULLing out the resv_qty
    Begin
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('header_id => ' || l_line_tbl(I).header_id);
       oe_debug_pub.add('line_id => ' || l_line_tbl(I).line_id);
       oe_debug_pub.add('org_id => ' || l_line_tbl(I).org_id);
      END IF;

      l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(I).header_id);

      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('l_sales_order_id => ' || l_sales_order_id);
      END IF;

      l_line_tbl(I).reserved_quantity := oe_line_util.Get_Reserved_Quantity (
                                         p_header_id   => l_sales_order_id,
                                         p_line_id     => p_line_tbl(I).line_id,
                                         p_org_id      => p_line_tbl(I).org_id);
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Reserved_Qty => ' || l_line_tbl(I).reserved_quantity);
      END IF;

    Exception
       When Others Then
         l_line_tbl(I).reserved_quantity := NULL;
    END;

    IF NOT (OE_GLOBALS.Equal(l_line_tbl(I).inventory_item_id,
                               l_old_line_tbl(I).inventory_item_id)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).unit_selling_price,
                               l_old_line_tbl(I).unit_selling_price)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).ordered_quantity,
                               l_old_line_tbl(I).ordered_quantity)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).order_quantity_uom,
                               l_old_line_tbl(I).order_quantity_uom)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).shipped_quantity,
                               l_old_line_tbl(I).shipped_quantity)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).schedule_ship_date,
                               l_old_line_tbl(I).schedule_ship_date)
         AND  OE_GLOBALS.Equal(l_line_tbl(I).schedule_arrival_date,
                               l_old_line_tbl(I).schedule_arrival_date)
              ) OR (
                    l_old_line_tbl(I).operation = Oe_Globals.G_OPR_INSERT OR
                    l_old_line_tbl(I).operation = Oe_Globals.G_OPR_CREATE
                   )
		OR (  l_line_tbl(I).first_ack_code is null  AND
		      l_header_rec.first_ack_code is not null )--bug7207426
    Then
      l_ack_req_flag := 'B';
      If l_header_rec.first_ack_code is not null And
         l_line_tbl(I).FIRST_ACK_CODE Is Null Then
        l_line_tbl(I).FIRST_ACK_CODE     := 'DR';
        l_line_tbl(I).FIRST_ACK_DATE     := sysdate;
        l_old_line_tbl(I).FIRST_ACK_DATE := sysdate;
      End If;

    Else
      If l_header_rec.first_ack_code Is Not Null Then
        l_line_tbl(I).changed_lines_pocao := 'N';
      End If;
    End If;

    if (l_line_tbl(I).operation is NULL OR
      l_line_tbl(I).operation = FND_API.G_MISS_CHAR ) THEN
        l_line_tbl(I).operation := NULL; -- for bug 4764583/5178052
        oe_debug_pub.add(' Setting Operation G_MISS_CHAR to NULL');
    end if;

    i := l_line_tbl.next(i);

  End Loop;

  If l_ack_req_flag = 'N' And
     l_header_rec_isnull = 'N' Then
    If NOT (OE_GLOBALS.Equal(l_header_rec.cust_po_number,
                                l_old_header_rec.cust_po_number)
          And  OE_GLOBALS.Equal(l_header_rec.ship_to_org_id,
                                l_old_header_rec.ship_to_org_id)
          And  OE_GLOBALS.Equal(l_header_rec.ordered_date,
                                l_old_header_rec.ordered_date)) Then
      l_ack_req_flag := 'H';
    End If;
  End If;

  If l_ack_req_flag In ('B','H') Or
     l_header_rec.first_ack_code Is Null Then

    l_rejected_lines := 'Y';
    OE_Header_Util.Convert_Miss_To_Null (l_header_rec);

    -- Start inserting the ack records
    OE_Header_Ack_Util.Insert_Row
     (p_header_rec       =>  l_header_rec,
      x_ack_type         =>  l_ack_type,
      x_return_status    =>  l_return_status);

    If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_ERROR Then
      RAISE FND_API.G_EXC_ERROR;
    Else
      l_raise_event := 'Y';
    End If;
  End If;

  If l_ack_req_flag = 'B' Or
     l_header_rec.first_ack_code Is Null Then
    OE_Line_Ack_Util.Insert_Row
     (p_line_tbl        =>  l_line_tbl,
      p_old_line_tbl    =>  l_old_line_tbl,
      x_return_status   =>  l_return_status);
    If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_ERROR Then
      RAISE FND_API.G_EXC_ERROR;
    Else
      l_raise_event := 'Y';
    End If;

   -- do id to value conversion to get sold_to_org to pass when getting rejected lines

  begin
   IF l_header_rec.sold_to_org_id is not null THEN
      OE_ID_TO_VALUE.sold_to_org(p_sold_to_org_id => l_header_rec.sold_to_org_id,
                                 x_org            => l_sold_to_org,
                                 x_customer_number => l_customer_number);
   END IF;

   exception
   when others then
    If l_debug_level > 0 Then
      oe_debug_pub.add('OTHERS EXCEPTION WHEN DERIVING SOLD TO ORG');
    End If;
   end;

    OE_Rejected_Lines_Ack.Get_Rejected_Lines
        (   p_request_id              =>  l_header_rec.request_id
        ,   p_order_source_id         =>  l_header_rec.order_source_id
        ,   p_orig_sys_document_ref   =>  l_header_rec.orig_sys_document_ref
        ,   p_change_sequence         =>  l_header_rec.change_sequence
        ,   x_rejected_line_tbl       =>  l_reject_line_tbl
        ,   x_rejected_line_val_tbl   =>  l_reject_line_val_tbl
        ,   x_rejected_lot_serial_tbl =>  l_reject_lot_serial_tbl
        ,   x_return_status           =>  l_return_status
        ,   p_header_id               =>  l_header_rec.header_id
        ,   p_sold_to_org             =>  l_sold_to_org
        ,   p_sold_to_org_id          =>  l_header_rec.sold_to_org_id
        );

    If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_ERROR Then
      RAISE FND_API.G_EXC_ERROR;
    End If;

    If l_reject_line_tbl.COUNT > 0 Then
      OE_Line_Ack_Util.Insert_Row
           (p_line_tbl             =>  l_reject_line_tbl
           ,p_old_line_tbl         =>  l_reject_line_tbl
           ,p_line_val_tbl         =>  l_reject_line_val_tbl
           ,p_old_line_val_tbl     =>  l_reject_line_val_tbl
           ,p_buyer_seller_flag    =>  'B'
           ,p_reject_order         =>  'Y'
           ,x_return_status        =>  l_return_status
           );

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          Else
            l_raise_event := 'Y';
          END IF;

     End If;

  End If;

  -- Raise the event (Pack J)
   If l_raise_event = 'Y' Then
    OE_Update_Ack_Util.Raise_Derive_Ack_Data_event
     (p_transaction_type     => 'ONT',
      p_header_id            => l_header_rec.header_id,
      p_org_id               => l_header_rec.org_id,
      p_orig_sys_document_ref => l_header_rec.orig_sys_document_ref,
      p_change_sequence      => l_header_rec.change_sequence,
      p_sold_to_org_id       => l_header_rec.sold_to_org_id,
      p_order_number         => l_header_rec.order_number,
      p_order_source_id      => l_header_rec.order_source_id,
      p_transaction_subtype  => l_ack_type,
      p_order_type_id        => l_header_rec.order_type_id,
      p_xml_msg_id           => l_header_rec.xml_message_id, --l_xml_message_id,
      x_return_status        => l_return_status);
   End If;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

Exception
  When Others Then
    If l_debug_level >0 Then
      Oe_Debug_Pub.Add('When Others in new Process_Acknowledgment');
      Oe_Debug_Pub.Add('Error: '||sqlerrm);
    End If;

End Process_Acknowledgment;



END OE_Acknowledgment_Pvt;

/
