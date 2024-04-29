--------------------------------------------------------
--  DDL for Package Body OTA_OM_UPD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OM_UPD_API" as
/* $Header: ottomupd.pkb 120.1.12000000.2 2007/10/17 11:04:43 smahanka noship $ */
g_package  varchar2(33)	:= ' ota_om_upd_api.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------------< cancel_order>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to cancel order line.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure cancel_order(
p_Line_id	 	IN	NUMBER,
p_org_id		IN	NUMBER)

IS

l_Line_id  oe_order_lines.Line_Id%type;
l_header_id oe_order_lines.header_id%type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type:=
					OE_GLOBALS.G_MISS_CONTROL_REC;

--Declare all local variable.
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl			OE_Order_PUB.Line_Tbl_Type;   --added for bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);
l_proc 	varchar2(72) := g_package||'cancel_order';
l_err_num                    VARCHAR2(30) := '';
l_err_msg                    VARCHAR2(1000) := '';
l_order_exception            exception;  -- added for bug #1657510

l_order_number     oe_order_headers.order_number%type;
l_ordered_quantity  oe_order_lines.ordered_quantity%type;
l_caller_source            varchar2(30);  -- Bug 2707198
l_org_id  oe_order_headers.org_id%type;


CURSOR C_ORDER
IS
SELECT OH.ORDER_NUMBER ,
	 OH.HEADER_ID,
       OH.ORG_ID,
       OL.ordered_quantity
FROM OE_ORDER_HEADERS_ALL OH,
	OE_ORDER_LINES_ALL OL
WHERE OH.HEADER_ID = OL.HEADER_ID AND
      OL.LINE_ID = p_line_id;



BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
--fnd_client_info.set_org_context(context => to_char(p_org_id));

  /* Bug 2707198 */
  Begin
      l_caller_source  :=  wf_engine.GetItemAttrtext(itemtype => 'OTWF'
                                                    ,itemkey  => to_char(p_line_id)
                                                    ,aname    => 'CALLER_SOURCE');
  Exception when others then
     null;
  end;
  /* Bug 2707198 */

  OPEN C_ORDER;
  FETCH C_ORDER INTO l_order_number,
                     l_header_id,
                     l_org_id,
                     l_ordered_quantity;
  CLOSE C_ORDER;

  hr_utility.set_location('Entering:'||l_proc, 10);
--  IF l_ordered_quantity is not null and l_ordered_quantity  > 0 THEN
  IF l_ordered_quantity is not null and l_ordered_quantity  > 0 and l_caller_source is null THEN -- Bug 2707198
     BEGIN
     MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support
     l_line_rec := OE_Order_Pub.G_MISS_LINE_REC;
  	--l_header_rec.header_id :=  l_header_id;
   	l_line_rec.operation := OE_Globals.G_OPR_UPDATE ;
       --l_line_rec.change_reason := 'NOT PROVIDED';
       -- Changed the seeded lookup code to mixed case for bug# 3142472
        l_line_rec.change_reason := 'Not provided';
	l_line_rec.ordered_quantity := 0;
	l_line_rec.line_id := p_line_id;
	l_line_tbl(1) := l_line_rec;

 	OE_Order_GRP.Process_Order
	(   p_api_version_number      => 1.0
	,   p_init_msg_list           => FND_API.G_FALSE
	,   p_return_values      	=> l_return_values
	,   p_commit                  => FND_API.G_FALSE
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_return_status      	=> l_return_status
	,   x_msg_count          	=> l_msg_count
	,   x_msg_data           	=>  l_msg_data
	,   p_header_rec         	=> l_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   p_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   p_Header_Scredit_tbl      => l_header_scredit_tbl
	,   p_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_Lot_Serial_tbl          => l_lot_serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_Action_Request_tbl      => l_request_tbl
	,   x_header_rec              => l_header_rec
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl       --modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       	=> l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   	=> l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl 	=> l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     	=> l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl 	=> l_action_request_tbl
	);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	   retrieve_oe_messages(l_message_data);

	  -- raise_application_error(-20001,l_message_data);
         raise l_order_exception;  -- added for bug #1657510
--
     END IF;
      exception
--
-- start added for bug #1657510
--
      when l_order_exception then
         fnd_message.set_name('OTA', 'OTA_TDB_CANCEL_LINE_FAILED');
         fnd_message.set_token('OM_ERR_MSG',l_message_data);
         fnd_message.raise_error;
--
-- end added for bug #1657510
--

      when others then
    	l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 1000);

       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', l_proc);
         hr_utility.set_message_token('STEP',l_err_msg );
        hr_utility.raise_error;

     END;
 END IF;


END;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< create_rma>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create RMA.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure create_rma(
p_Line_id	 	IN	NUMBER,
p_org_id		IN	NUMBER
)
IS

l_proc 	varchar2(72) := g_package||'create_rma';

l_Line_id  oe_order_lines.Line_Id%type;
l_header_id oe_order_lines.header_id%type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type ;

--Declare all local variable.
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
x_header_rec		OE_Order_PUB.Header_Rec_Type;		--added for bug 6347596
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl			OE_Order_PUB.Line_Tbl_Type;		--added for bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);
l_order_number     oe_order_headers.order_number%type;
l_ordered_quantity  oe_order_lines.ordered_quantity%type;
l_sold_to_org_id		oe_order_headers.sold_to_org_id%type;
l_sold_to_contact_id    oe_order_headers.sold_to_contact_id%type;
l_order_type_id         oe_order_headers.order_type_id%type;
l_invoicing_rule_id     oe_order_lines.invoicing_rule_id%type;
l_currency_code         VARCHAR2(15);
l_accounting_rule_id	oe_order_lines.accounting_rule_id%type;
l_ordered_quantity_uom  oe_order_lines.order_quantity_uom%type;
l_price_list_id         oe_order_lines.price_list_id%type;
l_ordered_item_id       oe_order_lines.ordered_item_id%type;
l_ordered_item          oe_order_lines.ordered_item%type;
l_inventory_item_id     oe_order_lines.inventory_item_id%type;
l_item_identifier_type  oe_order_lines.item_identifier_type%type;
l_unit_list_price       oe_order_lines.unit_list_price%type;
l_unit_selling_price    oe_order_lines.unit_selling_price%type;
l_ship_to_org_id        oe_order_headers.ship_to_org_id%type;
l_ship_to_contact_id    oe_order_lines.ship_to_contact_id%type;
l_salesrep_id           oe_order_headers.salesrep_id%type;
l_sold_from_org_id      oe_order_headers.sold_from_org_id%type;
l_ship_from_org_id      oe_order_headers.ship_from_org_id%type;

/*Bug  2360833 */
l_invoice_to_org_id   	oe_order_headers.invoice_to_org_id%type;
--l_ship_to_org_id		oe_order_headers.ship_to_org_id%type;
l_agreement_id		oe_order_headers.agreement_id%type;
--l_ship_to_contact_id	oe_order_headers.ship_to_contact_id%type;
l_invoice_to_contact_id	oe_order_headers.invoice_to_contact_id%type;
l_payment_type_code	oe_order_headers.payment_type_code%type;
l_credit_card_code	oe_order_headers.credit_card_code%type;
l_cc_holder_name		oe_order_headers.credit_card_holder_name%type;
l_cc_number			oe_order_headers.credit_card_number%type;
l_cc_expiration_date	oe_order_headers.credit_card_expiration_date%type;
l_commitment_id         oe_order_lines.commitment_id%type;
l_check_number 		oe_order_headers.check_number%type;
l_payment_amount		oe_order_headers.payment_amount%type;
/*Bug  2360833 */

l_line_type_id		oe_order_lines.line_type_id%type;
l_err_num                    VARCHAR2(30) := '';
l_err_msg                    VARCHAR2(1000) := '';
l_order_exception       EXCEPTION;    --  added for bug #1657510
l_count                 number;

v						Varchar2(30);
l_org_id  oe_order_headers.org_id%type;

CURSOR C_ORDER
IS
SELECT OH.ORDER_NUMBER ,
	 OH.HEADER_ID,
       OL.ordered_quantity,
       oh.sold_to_org_id,
       oh.sold_to_contact_id,
       oh.Order_type_id,
       oh.transactional_curr_code,
       oh.accounting_rule_id,
       oh.ship_to_org_id,
       oh.salesrep_id,
       oh.sold_from_org_id,
       oh.ship_from_org_id,
/*Bug  2360833 */
       oh.invoice_to_org_id,
     --  oh.ship_to_org_id,
       oh.agreement_id,
    --   oh.ship_to_contact_id,
       oh.invoice_to_contact_id,
       oh.payment_type_code,
       oh.credit_card_code,
       oh.credit_card_holder_name,
       oh.credit_card_number,
       oh.credit_card_expiration_date,
       oh.check_number,
       oh.payment_amount,
/*Bug  2360833 */
       ol.order_quantity_uom,
       ol.price_list_id,
       ol.ordered_item_id,
       ol.ordered_item,
       ol.inventory_item_id,
       ol.item_identifier_type,
       ol.unit_list_price,
       ol.unit_selling_price,
       oh.ship_to_contact_id ,
       ol.line_type_id,
       ol.commitment_id,
       oh.org_id
FROM OE_ORDER_HEADERS_ALL OH,
	OE_ORDER_LINES_ALL OL
WHERE OH.HEADER_ID = OL.HEADER_ID AND
      OL.LINE_ID = p_line_id;


BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

Select count(*)into l_count from oe_order_lines_all
where reference_line_id = p_line_id;
if l_count = 0 then

  OPEN C_ORDER;
  FETCH C_ORDER INTO l_order_number,
                     l_header_id,
                     l_ordered_quantity,
                     l_sold_to_org_id,
                     l_sold_to_contact_id,
			   l_order_type_id,
                     l_currency_code,
                     l_accounting_rule_id,
                     l_ship_to_org_id,
                     l_salesrep_id,
                     l_sold_from_org_id,
                     l_ship_from_org_id,
   /* Bug 2360833 */
                     l_invoice_to_org_id,
			--   l_ship_to_org_id,
       		   l_agreement_id,
       		--   l_ship_to_contact_id,
      		   l_invoice_to_contact_id,
      		   l_payment_type_code,
      		   l_credit_card_code,
       		   l_cc_holder_name,
       		   l_cc_number,
      		   l_cc_expiration_date,
                     l_check_number,
        		   l_payment_amount,
   /* Bug 2360833 */

       		   l_ordered_quantity_uom,
       	         l_price_list_id,
       	         l_ordered_item_id,
       		   l_ordered_item,
       		   l_inventory_item_id,
       		   l_item_identifier_type,
       		   l_unit_list_price,
       		   l_unit_selling_price,
                     l_ship_to_contact_id,
                     l_line_type_id,
                     l_commitment_id,
                     l_org_id;
  CLOSE C_ORDER;
  hr_utility.set_location('Entering:'||l_proc, 10);
   BEGIN

-- Header Level
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support
      l_header_rec := OE_Order_Pub.G_MISS_HEADER_REC;
      l_header_rec.operation :=  OE_Globals.G_OPR_CREATE ;
      l_header_rec.sold_to_org_id :=  l_sold_to_org_id;
     	l_header_rec.order_type_id := l_order_type_id;
      l_header_rec.price_list_id := l_price_list_id;
      l_header_rec.accounting_rule_id := l_accounting_rule_id;

      l_header_rec.salesrep_id := l_salesrep_id;
  --  l_header_rec.booked_flag := 'Y';
      l_header_rec.sold_from_org_id :=l_sold_from_org_id;
      l_header_rec.ship_from_org_id := l_ship_from_org_id;
      /* Bug 2360833 */
      l_header_rec.invoice_to_org_id := l_invoice_to_org_id;
 	l_header_rec.ship_to_org_id:= l_ship_to_org_id;
 	l_header_rec.agreement_id:= l_agreement_id;
 	l_header_rec.ship_to_contact_id := l_ship_to_contact_id;
 	l_header_rec.invoice_to_contact_id:= l_invoice_to_contact_id;
 	l_header_rec.payment_type_code := l_payment_type_code ;
	l_header_rec.credit_card_code := l_credit_card_code ;
 	l_header_rec.credit_card_holder_name := l_cc_holder_name;
 	l_header_rec.credit_card_number  := l_cc_number;
 	l_header_rec.credit_card_expiration_date  := l_cc_expiration_date;
      l_header_rec.check_number := l_check_number;
   	l_header_rec.payment_amount:= l_payment_amount;

      /* Bug 2360833 */

-- Line Level
      l_line_rec := OE_Order_Pub.G_MISS_LINE_REC;
      l_line_rec.sold_to_org_id := l_sold_to_org_id;
   	l_line_rec.operation := OE_Globals.G_OPR_CREATE ;
     	l_line_rec.line_category_code  := 'RETURN';
	l_line_rec.ordered_quantity := 1;
      l_line_rec.order_quantity_uom := l_ordered_quantity_uom;
      l_line_rec.inventory_item_id := l_inventory_item_id;
      l_line_rec.ordered_item_id := l_ordered_item_id;
      l_line_rec.ordered_item := l_ordered_item;
      l_line_rec.price_list_id := l_price_list_id;
      l_line_rec.item_identifier_type := l_item_identifier_type;
      l_line_rec.return_reason_code := 'RETURN';
      /* Bug 2360833 */
      l_line_rec.return_context := 'ORDER';
      l_line_rec.return_attribute1 := l_header_id;
      l_line_rec.return_attribute2 := p_line_id;
      l_line_rec.commitment_id:= l_commitment_id;
      l_line_rec.agreement_id:=  l_agreement_id;

      /* Bug 2360833 */
     -- l_line_rec.booked_flag := 'Y';
      l_line_rec.reference_Line_id := p_line_id;
	l_line_rec.reference_header_id := l_header_id;
    --  l_line_rec.request_date := sysdate;

  l_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;
  l_request_tbl(1).entity_code :=  OE_GLOBALS.G_ENTITY_HEADER;

	l_line_tbl(1) := l_line_rec;


 	OE_Order_GRP.Process_Order
	(   p_api_version_number      =>  l_api_version_number
	,   p_init_msg_list           => FND_API.G_FALSE
	,   p_return_values      	=> l_return_values
	,   p_commit                  => FND_API.G_FALSE
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_return_status      	=> l_return_status
	,   x_msg_count          	=> l_msg_count
	,   x_msg_data           	=> l_msg_data
	,   p_header_rec         	=> l_header_rec
	,   p_old_header_rec          => l_old_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_old_header_val_rec      => l_old_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_old_Header_Adj_tbl	=> l_old_Header_Adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_old_Header_Adj_val_tbl  => l_old_Header_Adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl
	,   p_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   p_old_Header_Adj_Att_tbl  => l_old_Header_Adj_Att_tbl
	,   p_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl
	,   p_Header_Scredit_tbl      => l_header_scredit_tbl
	,   p_old_Header_Scredit_tbl  => l_old_Header_Scredit_tbl
	,   p_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   p_old_Header_Scredit_val_tbl => l_old_Header_Scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_old_line_tbl 		=> l_old_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_old_line_val_tbl 		=> l_old_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_old_Line_Adj_tbl    	=> l_old_Line_Adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_old_Line_Adj_val_tbl	=> l_old_Line_Adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_old_Line_Price_Att_tbl  => l_old_Line_Price_Att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_old_Line_Adj_Att_tbl	=> l_old_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_old_Line_Adj_Assoc_tbl  => l_old_Line_Adj_Assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_old_Line_Scredit_tbl	=> l_old_Line_Scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_old_Line_Scredit_val_tbl  => l_old_Line_Scredit_val_tbl
	,   p_Lot_Serial_tbl          => l_lot_serial_tbl
	,   p_old_Lot_Serial_tbl	=> l_old_Lot_Serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_old_Lot_Serial_val_tbl  => l_old_Lot_Serial_val_tbl
	,   p_Action_Request_tbl      => l_request_tbl
	,   x_header_rec              => x_header_rec    	--modified for bug 6347596
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl              --modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       	=> l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   	=> l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl 	=> l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     	=> l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl 	=> l_action_request_tbl
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	   retrieve_oe_messages(l_message_data);
	 -- raise_application_error(-20001,l_message_data);
         raise l_order_exception;          -- added for bug #1657510
 	END IF;
      exception

--
-- start added for bug #1657510
--
      when l_order_exception then
         fnd_message.set_name('OTA', 'OTA_TDB_CREATE_RMA_FAILED');
         fnd_message.set_token('OM_ERR_MSG',l_message_data);
         fnd_message.raise_error;
--
-- end added for bug #1657510
--
      when others then

    	l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 300);


    --  raise_application_error(-20001,l_err_num||': '||l_err_msg);
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP',l_message_data);
    hr_utility.raise_error;


      END;
END IF;
END;


-- ----------------------------------------------------------------------------
-- |---------------------------------< create_order>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create New Order and order line.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_inventory_item_id
-- p_customer_id
-- p_contact_id
--
-- out Argument
-- p_return_status
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure create_order(
p_customer_id	    IN	NUMBER,
p_contact_id          IN 	NUMBER,
p_inventory_item_id   IN 	NUMBER,
p_header_id           OUT NOCOPY  NUMBER,
p_line_id             OUT NOCOPY 	NUMBER,
p_return_status       OUT NOCOPY 	VARCHAR2)
--p_msg_data            OUT     VARCHAR2)
IS

l_proc 	varchar2(72) := g_package||'create_order';

l_Line_id  oe_order_lines.Line_Id%type;
l_header_id oe_order_lines.header_id%type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type ;

--Declare all local variable.
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
x_header_rec		OE_Order_PUB.Header_Rec_Type;		--added fro bug 6347596
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl			OE_Order_PUB.Line_Tbl_Type;	--added fro bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);
l_order_number     oe_order_headers.order_number%type;
l_ordered_quantity  oe_order_lines.ordered_quantity%type;
l_sold_to_org_id		oe_order_headers.sold_to_org_id%type;
l_sold_to_contact_id    oe_order_headers.sold_to_contact_id%type;
l_order_type_id         oe_order_headers.order_type_id%type := 1193;  --revisit later
l_invoicing_rule_id     oe_order_lines.invoicing_rule_id%type;
l_currency_code         VARCHAR2(15);
l_accounting_rule_id	oe_order_lines.accounting_rule_id%type;
l_ordered_quantity_uom  oe_order_lines.order_quantity_uom%type;
l_price_list_id         oe_order_lines.price_list_id%type;
l_ordered_item_id       oe_order_lines.ordered_item_id%type;
l_ordered_item          oe_order_lines.ordered_item%type;
l_inventory_item_id     oe_order_lines.inventory_item_id%type;
l_item_identifier_type  oe_order_lines.item_identifier_type%type;
l_unit_list_price       oe_order_lines.unit_list_price%type;
l_unit_selling_price    oe_order_lines.unit_selling_price%type;
l_ship_to_org_id        oe_order_headers.ship_to_org_id%type;
l_ship_to_contact_id    oe_order_lines.ship_to_contact_id%type;
l_salesrep_id           oe_order_headers.salesrep_id%type;
l_sold_from_org_id      oe_order_headers.sold_from_org_id%type;
l_ship_from_org_id      oe_order_headers.ship_from_org_id%type;
l_line_type_id		oe_order_lines.line_type_id%type;
l_err_num                    VARCHAR2(30) := '';
l_err_msg                    VARCHAR2(1000) := '';

v						Varchar2(30);
l_order_exception       EXCEPTION;
l_org_id  oe_order_headers.org_id%type;

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Entering:'||l_proc, 10);
   BEGIN
      MO_GLOBAL.INIT('ONT');
      l_org_id := MO_UTILS.Get_Default_Org_Id;
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support
      l_header_rec := OE_Order_Pub.G_MISS_HEADER_REC;
      l_header_rec.operation :=  OE_Globals.G_OPR_CREATE ;

      l_line_rec := OE_Order_Pub.G_MISS_LINE_REC;
   	l_line_rec.operation := OE_Globals.G_OPR_CREATE ;
     	l_line_rec.line_category_code  := 'ORDER';
	l_line_rec.ordered_quantity := 1;
      l_line_rec.order_quantity_uom := 'ENR';
      l_line_rec.inventory_item_id := p_inventory_item_id;


	l_line_tbl(1) := l_line_rec;


 	OE_Order_GRP.Process_Order
	(   p_api_version_number      =>  l_api_version_number
	,   p_init_msg_list           => FND_API.G_FALSE
	,   p_return_values      	=> l_return_values
	,   p_commit                  => FND_API.G_FALSE
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_return_status      	=> l_return_status
	,   x_msg_count          	=> l_msg_count
	,   x_msg_data           	=> l_msg_data
	,   p_header_rec         	=> l_header_rec
	,   p_old_header_rec          => l_old_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_old_header_val_rec      => l_old_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_old_Header_Adj_tbl	=> l_old_Header_Adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_old_Header_Adj_val_tbl  => l_old_Header_Adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl
	,   p_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   p_old_Header_Adj_Att_tbl  => l_old_Header_Adj_Att_tbl
	,   p_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl
	,   p_Header_Scredit_tbl      => l_header_scredit_tbl
	,   p_old_Header_Scredit_tbl  => l_old_Header_Scredit_tbl
	,   p_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   p_old_Header_Scredit_val_tbl => l_old_Header_Scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_old_line_tbl 		=> l_old_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_old_line_val_tbl 		=> l_old_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_old_Line_Adj_tbl    	=> l_old_Line_Adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_old_Line_Adj_val_tbl	=> l_old_Line_Adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_old_Line_Price_Att_tbl  => l_old_Line_Price_Att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_old_Line_Adj_Att_tbl	=> l_old_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_old_Line_Adj_Assoc_tbl  => l_old_Line_Adj_Assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_old_Line_Scredit_tbl	=> l_old_Line_Scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_old_Line_Scredit_val_tbl  => l_old_Line_Scredit_val_tbl
	,   p_Lot_Serial_tbl          => l_lot_serial_tbl
	,   p_old_Lot_Serial_tbl	=> l_old_Lot_Serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_old_Lot_Serial_val_tbl  => l_old_Lot_Serial_val_tbl
	,   p_Action_Request_tbl      => l_request_tbl
	,   x_header_rec              => x_header_rec		--modified for bug 6347596
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl		--modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       	=> l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   	=> l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl 	=> l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     	=> l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl 	=> l_action_request_tbl
	);

      p_header_id := l_header_rec.header_id;
      p_line_id := l_line_tbl(1).line_id;
      p_return_status :=l_return_status;
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	   retrieve_oe_messages(l_message_data);
         raise l_order_exception;
      END IF;
      exception
      when l_order_exception then
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP',l_message_data);
          hr_utility.raise_error;
       -- RAISE FND_API.G_EXC_ERROR;


      when others then
    	   l_err_num := SQLCODE;
         l_err_msg := SUBSTR(SQLERRM, 1, 100);


         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', l_proc);
         hr_utility.set_message_token('STEP',l_err_msg );
         hr_utility.raise_error;

      END;
END;

-- ----------------------------------------------------------------------------
-- |--------------------------< retrieve_oe_messages>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to retrieve error message when calling Process
--   Order API.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE retrieve_oe_messages (
p_msg_data out nocopy varchar2)
IS

l_msg_count NUMBER;
l_msg_data  VARCHAR2(2000);
x_msg_data  VARCHAR2(2000);


 BEGIN
     oe_MSG_PUB.Count_And_Get
          ( p_count           =>      l_msg_count,
            p_data            =>      l_msg_data
          );

     if l_msg_count > 0 then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OTA', 'OTA_OM_ERROR_MSG');
            FND_MSG_PUB.ADD;
      END IF;
     end if;

     for k in 1 ..l_msg_count loop
       x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OTA', 'OTA_OM_ERROR');
            FND_MESSAGE.Set_Token('MSG_TXT', x_msg_data, FALSE);
            FND_MSG_PUB.ADD;

		p_msg_data := x_msg_data;
         END IF;
       --dbms_output.put_line('Error msg: '||substr(x_msg_data,1,200));
     end loop;
  END;

-- ----------------------------------------------------------------------------
-- |---------------------------------< create_enroll_from_om>------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create New enrollment and this procedure
--   will be called by OM Sales Order form.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
-- p_sold_to_org_id
-- p_ship_to_org_id
-- p_sold_to_contact_id
-- p_ship_to_contact_id
-- p_event_id
--
-- out Argument
-- p_return_status
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure create_enroll_from_om(
p_Line_id	          IN	NUMBER,
p_org_id	          IN 	NUMBER,
p_sold_to_org_id      IN 	NUMBER,
p_ship_to_org_id      IN      NUMBER,
p_sold_to_contact_id  IN 	NUMBER,
p_ship_to_contact_id  IN 	NUMBER,
p_event_id            IN      NUMBER,
p_order_date          IN      DATE,
x_enrollment_id       OUT NOCOPY     NUMBER,
x_enrollment_status   OUT NOCOPY     VARCHAR2,
x_return_status       OUT NOCOPY     VARCHAR2 )
IS


 l_commit  boolean;
  l_booking_id              number := NULL;
  l_type 		    varchar2(1);
  l_version		    number := NULL;
  l_type_id		    number;
  l_finance_line_id         number   := NULL;
  l_meaning		    varchar2(100);
  l_booking_status_type_id  ota_booking_status_types.booking_status_type_id%TYPE;
  l_booking_priority        ota_delegate_bookings.booking_priority%TYPE := NULL;
  l_delegate_contact_phone  varchar2(80);
  l_delegate_contact_fax    varchar2(80);
  l_delegate_contact_email  HZ_PARTIES.email_address%TYPE;  ---changed
  l_contact_address_id          HZ_CUST_ACCT_SITES.cust_acct_site_id%TYPE   :=  NULL;  --changed
  l_correspondent               varchar2(1) := 'C';
  l_student_address_id          varchar2(1)  :=  NULL;
  l_control_contact_address_id  ota_customer_contacts_v.address_id%TYPE  := NULL;
  l_control_student_address_id  ota_customer_contacts_v.address_id%TYPE  := NULL;
  l_stud_cont                      number := NULL;
  l_customer_id              number;
  l_third_party_id           number;
  l_contact_id               number;
  l_student_id               number;
  l_event_status             ota_events.event_status%type;
  l_business_group_id  number ;
--  l_business_group_id  number:=FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
  l_ship_to_org_id          number;
  l_single_business_group_id  	ota_delegate_bookings.business_group_id%type:=
							fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
--Third party info --
  l_third_contact_phone  varchar2(80);
  l_third_contact_fax    varchar2(80);
  l_third_contact_email  HZ_PARTIES.email_address%TYPE; --changed
  l_third_address_id          HZ_CUST_ACCT_SITES.cust_acct_site_id%TYPE   :=  NULL; --changed
  l_control_third_address_id  ota_customer_contacts_v.address_id%TYPE  := NULL;
  l_third_contact_id               number;



--

Cursor get_booking_status_type_id IS
Select booking_status_type_id,
       name
From ota_booking_status_types
Where active_flag  = 'Y'
And   default_flag = 'Y'
And   type         = 'W'
and business_group_id = L_BUSINESS_GROUP_ID;
--
-- Bug 2599144 Country code added and a space added in between numbers ---
Cursor get_phone IS
select con.phone_country_code||' '|| con.phone_area_code||' '||decode(con.contact_point_type,'TLX',con.telex_number,con.phone_number)  from hz_contact_points con, hz_cust_account_roles acct_role
 where con.owner_table_id=acct_role.party_id
 and con.Primary_Flag='Y'
 and acct_role.cust_account_role_id=l_stud_cont
 And con.owner_table_name = 'HZ_PARTIES'
 And con.contact_point_type not in ('EDI', 'EMAIL', 'WEB');

--
-- Bug 2599144 Country code added and a space added in between numbers ---
Cursor get_fax IS
Select phone_country_code||' '||phone_area_code ||' '||
  decode(con.contact_point_type,'TLX',con.telex_number,con.phone_number)
  phone_number
  From  HZ_CONTACT_POINTS con,
  HZ_CUST_ACCOUNT_ROLES car
  where car.party_id = con.owner_table_id
  and con.owner_table_name = 'HZ_PARTIES'
  and con.contact_point_type not in ('EDI','EMAIL','WEB')
  and car.cust_account_role_id = l_stud_cont
  and nvl(con.phone_line_type,con.contact_point_type) = 'FAX';
--
Cursor get_email IS
Select rel_party.email_address
     From HZ_CUST_ACCOUNT_ROLES acct_role,
         HZ_PARTIES rel_party,
         HZ_RELATIONSHIPS rel,
         HZ_CUST_ACCOUNTS role_acct
    where acct_role.party_id = rel.party_id
      and acct_role.role_type = 'CONTACT'
      and rel.party_id = rel_party.party_id
      and rel.subject_table_name = 'HZ_PARTIES'
      and rel.object_table_name  = 'HZ_PARTIES'
      and acct_role.cust_account_id = role_acct.cust_account_id
      and role_acct.party_id  = rel.object_id
      and acct_role.cust_account_role_id = l_stud_cont;
--
Cursor get_control_contact_address_id IS
select address_id
from ota_customer_contacts_v
where contact_id = P_SOLD_TO_CONTACT_ID
      and status = 'A'
      and (l_contact_address_id is not null
      and l_correspondent = 'C'
      and address_id = l_contact_address_id
      or not exists (select null
                    from ota_customer_contacts_v cus
                    where cus.contact_id = P_SOLD_TO_CONTACT_ID
                    and cus.address_id =l_contact_address_id)
                    or l_contact_address_id is null
                    or l_correspondent <> 'C' );

-- ***
Cursor get_control_student_address_id IS
select address_id
from ota_customer_contacts_v
where contact_id = P_SHIP_TO_CONTACT_ID
and status = 'A'
and (l_contact_address_id is not null
and l_correspondent = 'S'
and address_id = l_contact_address_id
or not exists (select null
from ota_customer_contacts_v cus
where cus.contact_id = P_SHIP_TO_CONTACT_ID
and cus.address_id = l_contact_address_id)
or l_contact_address_id is null
or l_correspondent <> 'S' );

-- ***
Cursor get_address_id IS
select adr.address_id
    from  (select LOC.address1 ADDRESS1,LOC.address2 ADDRESS2,LOC.address3 ADDRESS3,LOC.address4 ADDRESS4,
             LOC.city CITY,LOC.state STATE,LOC.province PROVINCE,LOC.county COUNTY,LOC.postal_code POSTAL_CODE,
             LOC.country COUNTRY,ACCT_SITE.cust_acct_site_id   ADDRESS_ID,ACCT_SITE.status  STATUS,
            ACCT_SITE.cust_account_id  CUSTOMER_ID
            from HZ_LOCATIONS loc,HZ_CUST_ACCT_SITES acct_site,HZ_PARTY_SITES party_site
            where PARTY_SITE.location_id = LOC.location_id
            and ACCT_SITE.party_site_id = PARTY_SITE.party_site_id)adr
   where adr.status = 'A' and
        adr.customer_id=P_SOLD_TO_ORG_ID and
        (adr.address_id = decode(l_correspondent, 'S',
      l_control_student_address_id, 'C',l_control_contact_address_id) or
      decode(l_correspondent,'S',l_control_student_address_id,'C',l_control_contact_address_id) is null )
   order by address1,address2,address3,address4,city,state,province,county,postal_code,country;



Cursor get_ship_address_id IS
select adr.address_id
   from   (select LOC.address1 ADDRESS1,LOC.address2 ADDRESS2,LOC.address3 ADDRESS3,LOC.address4 ADDRESS4,
             LOC.city CITY,LOC.state STATE,LOC.province PROVINCE,LOC.county COUNTY,LOC.postal_code POSTAL_CODE,
             LOC.country COUNTRY,ACCT_SITE.cust_acct_site_id   ADDRESS_ID,ACCT_SITE.status  STATUS,
            ACCT_SITE.cust_account_id  CUSTOMER_ID
            from HZ_LOCATIONS loc,HZ_CUST_ACCT_SITES acct_site,HZ_PARTY_SITES party_site
            where PARTY_SITE.location_id = LOC.location_id
            and ACCT_SITE.party_site_id = PARTY_SITE.party_site_id)adr
   where adr.status = 'A' and
        adr.customer_id = L_SHIP_TO_ORG_ID and
          ( adr.address_id = decode(l_correspondent, 'S',
      l_control_student_address_id, 'C',l_control_contact_address_id) or
      decode(l_correspondent,'S',l_control_student_address_id,'C',l_control_contact_address_id) is null )
  order by address1,address2,address3,address4,city,state,province,county,postal_code,country;



Cursor Get_Event_status
is
Select event_status
from
OTA_EVENTS
WHERE
EVENT_ID = p_event_id;

-- For Third Party --
Cursor get_control_third_address_id IS
select address_id
from ota_customer_contacts_v
where contact_id = P_SOLD_TO_CONTACT_ID
and status = 'A';


Cursor get_third_address_id IS
select adr.address_id
    from   (select LOC.address1 ADDRESS1,LOC.address2 ADDRESS2,LOC.address3 ADDRESS3,LOC.address4 ADDRESS4,
             LOC.city CITY,LOC.state STATE,LOC.province PROVINCE,LOC.county COUNTY,LOC.postal_code POSTAL_CODE,
             LOC.country COUNTRY,ACCT_SITE.cust_acct_site_id   ADDRESS_ID,ACCT_SITE.status  STATUS,
            ACCT_SITE.cust_account_id  CUSTOMER_ID
            from HZ_LOCATIONS loc,HZ_CUST_ACCT_SITES acct_site,HZ_PARTY_SITES party_site
            where PARTY_SITE.location_id = LOC.location_id
            and ACCT_SITE.party_site_id = PARTY_SITE.party_site_id)adr
   where adr.status = 'A' and
         adr.customer_id = P_SOLD_TO_ORG_ID and
          ( adr.address_id = decode(l_control_third_address_id, null, null, l_control_third_address_id))
   order by address1,address2,address3,address4,city,state,province,county,postal_code,country;



cursor c_get_ship_to_org_id is
select customer_id
    from (select LOC.address1 ADDRESS1,LOC.address2 ADDRESS2,LOC.address3 ADDRESS3,LOC.address4 ADDRESS4,
              LOC.city CITY,LOC.state STATE,LOC.province PROVINCE,LOC.county COUNTY,LOC.postal_code POSTAL_CODE,
              LOC.country COUNTRY,ACCT_SITE.cust_acct_site_id   ADDRESS_ID,
              ACCT_SITE.status  STATUS,ACCT_SITE.cust_account_id  CUSTOMER_ID
              from HZ_LOCATIONS loc,HZ_CUST_ACCT_SITES acct_site,HZ_PARTY_SITES party_site
              where PARTY_SITE.location_id = LOC.location_id
              and ACCT_SITE.party_site_id = PARTY_SITE.party_site_id)rad,
              (Select cust_acct_site_id address_id,site_use_id,status
              From hz_cust_site_uses)rsu
   where rad.address_id = rsu.address_id and
        rsu.site_use_id = p_ship_to_org_id;

--
BEGIN
  -- * Check line Id

  x_return_status :='F';
  IF p_line_id is null then
     FND_MESSAGE.set_name  ('OTA', 'OTA_13901_TDB_NO_LINE_ID');
   --  FND_MESSAGE.error;
    fnd_message.raise_error;
  END IF;
  -- ***

  IF P_SOLD_TO_ORG_ID     is null or
       (P_SOLD_TO_CONTACT_ID is null and P_SHIP_TO_CONTACT_ID is null) then
           FND_MESSAGE.set_name  ('OTA', 'OTA_13903_TDB_OM_MISS_PAR_VAL');
	--   FND_MESSAGE.error;
	     fnd_message.raise_error;
  END IF;
  IF l_single_business_group_id is not null then
     l_business_group_id := l_single_business_group_id;
  ELSE
     l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
  END IF;

  OPEN get_event_status;
  FETCH get_event_status into l_event_status;
  CLOSE get_event_status;
  ota_bst_api.default_booking_status_type(p_business_group_id      => L_BUSINESS_GROUP_ID,
					p_type                   => NULL,
					p_event_status           => l_event_status,
					p_booking_status_type_id => l_type_id,
					p_name                   => l_meaning);



  if l_type_id is not null then
    l_type :=  ota_tdb_bus.booking_status_type(l_type_id);
  end if;


  IF l_type_id  is NULL THEN

   OPEN  get_booking_status_type_id;
   FETCH get_booking_status_type_id into l_booking_status_type_id,l_meaning;
   CLOSE get_booking_status_type_id;

  ELSE
   IF ota_tdb_bus.Booking_status_type(l_type_id) = 'R' then

      OPEN  get_booking_status_type_id;
      FETCH get_booking_status_type_id into l_booking_status_type_id,l_meaning;
      CLOSE get_booking_status_type_id;

   ELSE

      l_booking_status_type_id := l_type_id;

   END IF;
  END IF;


-- ***
    IF ota_tdb_bus.Booking_status_type(l_booking_status_type_id) = 'W' then
       l_booking_priority := fnd_profile.value('OTA_WAITLIST_PRIORITY');
       if l_booking_priority is null then
           FND_MESSAGE.set_name  ('OTA', 'OTA_13902_TDB_OM_NO_PROFILE');

           fnd_message.raise_error;
       end if;

    END IF;

  IF P_SHIP_TO_ORG_ID IS NOT NULL then
     OPEN c_get_ship_to_org_id ;
     FETCH c_get_ship_to_org_id into L_SHIP_TO_ORG_ID;
     CLOSE c_get_ship_to_org_id ;
  END IF;

  IF L_SHIP_TO_ORG_ID is not null THEN
     IF P_SOLD_TO_ORG_ID <> L_SHIP_TO_ORG_ID Then
     --   l_customer_id := p_ship_to_org_id;
        IF p_SOLD_TO_CONTACT_ID is not null then

          OPEN  get_control_third_address_id;
          FETCH get_control_third_address_id  into l_control_third_address_id;
          CLOSE get_control_third_address_id;

          OPEN  get_third_address_id;
          FETCH get_third_address_id       into l_third_address_id;
          CLOSE get_third_address_id;

          l_stud_cont := p_SOLD_TO_CONTACT_ID;


           OPEN  get_phone;
           FETCH get_phone       into l_third_contact_phone;
           CLOSE get_phone;

           OPEN  get_fax;
           FETCH get_fax         into l_third_contact_fax;
           CLOSE get_fax;

           OPEN  get_email;
           FETCH get_email         into l_third_contact_email;
           CLOSE get_email;

           l_third_party_id := p_sold_to_org_id;
           l_third_contact_id :=p_sold_to_contact_id;

        END IF;

        IF P_SHIP_TO_CONTACT_ID is not null then

         l_correspondent := 'S';
          OPEN  get_control_student_address_id;
          FETCH get_control_student_address_id  into l_control_student_address_id;
          CLOSE get_control_student_address_id;

          OPEN  get_ship_address_id;
          FETCH get_ship_address_id       into l_contact_address_id;
          CLOSE get_ship_address_id;

          l_stud_cont := P_SHIP_TO_CONTACT_ID;


          OPEN  get_phone;
          FETCH get_phone         into l_delegate_contact_phone;
          CLOSE get_phone;

          OPEN  get_fax;
          FETCH get_fax         into l_delegate_contact_fax;
          CLOSE get_fax;

          OPEN  get_email;
          FETCH get_email         into l_delegate_contact_email;
          CLOSE get_email;
          l_customer_id := l_ship_to_org_id;
          l_student_id  := p_ship_to_contact_id;
        END IF;

     ELSE

       If p_SOLD_TO_CONTACT_ID is not null then
          l_correspondent := 'C';

          OPEN  get_control_contact_address_id;
          FETCH get_control_contact_address_id  into l_control_contact_address_id;
          CLOSE get_control_contact_address_id;

          OPEN  get_address_id;
          FETCH get_address_id       into l_contact_address_id;
          CLOSE get_address_id;

          l_contact_id := p_sold_to_contact_id;
          l_student_id := p_ship_to_contact_id;

       else
         if p_ship_to_contact_id is not null then
          l_correspondent := 'S';
          OPEN  get_control_student_address_id;
          FETCH get_control_student_address_id  into l_control_student_address_id;
          CLOSE get_control_student_address_id;

          OPEN  get_address_id;
          FETCH get_address_id       into l_contact_address_id;
          CLOSE get_address_id;
          l_student_id := p_ship_to_contact_id;
         end if;
       end if;


       if p_SOLD_TO_CONTACT_ID is not null then
          l_stud_cont := p_SOLD_TO_CONTACT_ID;
       else
          l_stud_cont := p_SHIP_TO_CONTACT_ID;
       end if;
       OPEN  get_phone;
       FETCH get_phone         into l_delegate_contact_phone;
       CLOSE get_phone;

       OPEN  get_fax;
       FETCH get_fax         into l_delegate_contact_fax;
       CLOSE get_fax;

       OPEN  get_email;
       FETCH get_email         into l_delegate_contact_email;
       CLOSE get_email;
       l_customer_id := p_sold_to_org_id;
     ENd IF;
  ELSE
    If p_SOLD_TO_CONTACT_ID is not null then
          l_correspondent := 'C';
          OPEN  get_control_contact_address_id;
          FETCH get_control_contact_address_id  into l_control_contact_address_id;
          CLOSE get_control_contact_address_id;

          OPEN  get_address_id;
          FETCH get_address_id       into l_contact_address_id;
          CLOSE get_address_id;
          l_contact_id := p_sold_to_contact_id;
          l_student_id := p_ship_to_contact_id;
    else
       if p_ship_to_contact_id is not null then

          l_correspondent := 'S';
          OPEN  get_control_student_address_id;
          FETCH get_control_student_address_id  into l_control_student_address_id;
          CLOSE get_control_student_address_id;

          OPEN  get_address_id;
          FETCH get_address_id       into l_contact_address_id;
          CLOSE get_address_id;
          l_student_id := p_ship_to_contact_id;
        end if;
    end if;


       if p_SOLD_TO_CONTACT_ID is not null then
          l_stud_cont := p_SOLD_TO_CONTACT_ID;
       else
          l_stud_cont := p_SHIP_TO_CONTACT_ID;
       end if;
       OPEN  get_phone;
       FETCH get_phone         into l_delegate_contact_phone;
       CLOSE get_phone;

       OPEN  get_fax;
       FETCH get_fax         into l_delegate_contact_fax;
       CLOSE get_fax;

       OPEN  get_email;
       FETCH get_email         into l_delegate_contact_email;
       CLOSE get_email;
       l_customer_id := p_sold_to_org_id;

  END IF;

ota_tdb_api_ins2.create_enrollment  (
  p_booking_id                   => l_booking_id,
  p_booking_status_type_id       => l_booking_status_type_id,
  p_customer_id                  => l_customer_id,
  p_delegate_person_id           => null,
  p_contact_id                   => l_contact_id,
  p_contact_address_id           => l_contact_address_id,
  p_delegate_contact_phone       => l_delegate_contact_phone,
  p_delegate_contact_fax         => l_delegate_contact_fax,
  p_third_party_customer_id      => l_third_party_id,
  p_third_party_contact_id       => l_third_contact_id,
  p_third_party_address_id       => l_third_address_id,
  p_third_party_contact_phone    => l_third_contact_phone,
  p_third_party_contact_fax      => l_third_contact_fax,
  p_business_group_id            => l_business_group_id,
  p_event_id                     => p_event_id,
  p_date_booking_placed          => P_ORDER_DATE,
  p_corespondent                 => l_correspondent ,
  p_internal_booking_flag        => 'N',
  p_number_of_places             =>  1,
  p_booking_priority             => l_booking_priority,
  p_successful_attendance_flag   => null,
  p_failure_reason               => null,
  p_attendance_result            => null,
  p_administrator                => fnd_profile.value('USER_ID'),
  p_authorizer_person_id         => null,
  p_comments                     => null,
  p_date_status_changed          =>  NULL,
  p_language_id                  => null,
  p_source_of_booking            => null,
  p_special_booking_instructions => null,
  p_tdb_information_category     => null,
  p_tdb_information1             => null,
  p_tdb_information2             => null,
  p_tdb_information3             => null,
  p_tdb_information4             => null,
  p_tdb_information5             => null,
  p_tdb_information6             => null,
  p_tdb_information7             => null,
  p_tdb_information8             => null,
  p_tdb_information9             => null,
  p_tdb_information10            => null,
  p_tdb_information11            => null,
  p_tdb_information12            => null,
  p_tdb_information13            => null,
  p_tdb_information14            => null,
  p_tdb_information15            => null,
  p_tdb_information16            => null,
  p_tdb_information17            => null,
  p_tdb_information18            => null,
  p_tdb_information19            => null,
  p_tdb_information20            => null,
  p_finance_header_id            => null,
  p_create_finance_line          =>  'N',
  p_currency_code                => null,
  p_standard_amount              => null,
  p_unitary_amount               => null,
  p_money_amount                 => null,
  p_booking_deal_id              => null,
  p_booking_deal_type            => null,
  p_finance_line_id              => l_finance_line_id,
  p_object_version_number        => l_version,
  p_enrollment_type              => 'S',
  p_validate                     => false,
  p_organization_id              => null,
  p_sponsor_person_id            => null,
  p_sponsor_assignment_id        => null,
  p_person_address_id            => null,
  p_delegate_assignment_id       =>null,
  p_delegate_contact_id          => l_student_id,
  p_delegate_contact_email       => l_delegate_contact_email,
  p_third_party_email            => l_third_contact_email,
  p_person_address_type          =>  NULL,
  p_line_id			 => P_LINE_ID,
  p_org_id			 => p_org_id,
  p_daemon_flag			 =>  NULL,
  p_daemon_type			 =>  NULL
);

 if l_booking_id is null then
   x_return_status := 'F' ;
 else
   x_return_status := 'T';
  x_enrollment_id     := l_booking_id;
  x_enrollment_status := l_meaning;
 end if;
END;

end ota_om_upd_api;

/
