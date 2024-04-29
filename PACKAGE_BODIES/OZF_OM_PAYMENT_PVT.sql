--------------------------------------------------------
--  DDL for Package Body OZF_OM_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OM_PAYMENT_PVT" AS
/* $Header: ozfvompb.pls 120.2 2005/11/21 00:22:36 sashetty noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_OM_PAYMENT_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(15) := 'ozfvompb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

/*=======================================================================*
 | PROCEDURE
 |    Query_Claim
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang   Create.
 *=======================================================================*/
PROCEDURE Query_Claim(
    p_claim_id           IN    NUMBER
   ,x_claim_rec          OUT NOCOPY   OZF_Claim_PVT.claim_rec_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   SELECT
       claim_id
      ,object_version_number
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_update_date
      ,program_id
      ,created_from
      ,batch_id
      ,claim_number
      ,claim_type_id
      ,claim_class
      ,claim_date
      ,due_date
      ,owner_id
      ,history_event
      ,history_event_date
      ,history_event_description
      ,split_from_claim_id
      ,duplicate_claim_id
      ,split_date
      ,root_claim_id
      ,amount
      ,amount_adjusted
      ,amount_remaining
      ,amount_settled
      ,acctd_amount
      ,acctd_amount_remaining
      ,tax_amount
      ,tax_code
      ,tax_calculation_flag
      ,currency_code
      ,exchange_rate_type
      ,exchange_rate_date
      ,exchange_rate
      ,set_of_books_id
      ,original_claim_date
      ,source_object_id
      ,source_object_class
      ,source_object_type_id
      ,source_object_number
      ,cust_account_id
      ,cust_billto_acct_site_id
      ,cust_shipto_acct_site_id
      ,location_id
      ,pay_related_account_flag
      ,related_cust_account_id
      ,related_site_use_id
      ,relationship_type
      ,vendor_id
      ,vendor_site_id
      ,reason_type
      ,reason_code_id
      ,task_template_group_id
      ,status_code
      ,user_status_id
      ,sales_rep_id
      ,collector_id
      ,contact_id
      ,broker_id
      ,territory_id
      ,customer_ref_date
      ,customer_ref_number
      ,assigned_to
      ,receipt_id
      ,receipt_number
      ,doc_sequence_id
      ,doc_sequence_value
      ,gl_date
      ,payment_method
      ,voucher_id
      ,voucher_number
      ,payment_reference_id
      ,payment_reference_number
      ,payment_reference_date
      ,payment_status
      ,approved_flag
      ,approved_date
      ,approved_by
      ,settled_date
      ,settled_by
      ,effective_date
      ,custom_setup_id
      ,task_id
      ,country_id
      ,comments
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,deduction_attribute_category
      ,deduction_attribute1
      ,deduction_attribute2
      ,deduction_attribute3
      ,deduction_attribute4
      ,deduction_attribute5
      ,deduction_attribute6
      ,deduction_attribute7
      ,deduction_attribute8
      ,deduction_attribute9
      ,deduction_attribute10
      ,deduction_attribute11
      ,deduction_attribute12
      ,deduction_attribute13
      ,deduction_attribute14
      ,deduction_attribute15
      ,org_id
      ,order_type_id
   INTO
       x_claim_rec.claim_id
      ,x_claim_rec.object_version_number
      ,x_claim_rec.last_update_date
      ,x_claim_rec.last_updated_by
      ,x_claim_rec.creation_date
      ,x_claim_rec.created_by
      ,x_claim_rec.last_update_login
      ,x_claim_rec.request_id
      ,x_claim_rec.program_application_id
      ,x_claim_rec.program_update_date
      ,x_claim_rec.program_id
      ,x_claim_rec.created_from
      ,x_claim_rec.batch_id
      ,x_claim_rec.claim_number
      ,x_claim_rec.claim_type_id
      ,x_claim_rec.claim_class
      ,x_claim_rec.claim_date
      ,x_claim_rec.due_date
      ,x_claim_rec.owner_id
      ,x_claim_rec.history_event
      ,x_claim_rec.history_event_date
      ,x_claim_rec.history_event_description
      ,x_claim_rec.split_from_claim_id
      ,x_claim_rec.duplicate_claim_id
      ,x_claim_rec.split_date
      ,x_claim_rec.root_claim_id
      ,x_claim_rec.amount
      ,x_claim_rec.amount_adjusted
      ,x_claim_rec.amount_remaining
      ,x_claim_rec.amount_settled
      ,x_claim_rec.acctd_amount
      ,x_claim_rec.acctd_amount_remaining
      ,x_claim_rec.tax_amount
      ,x_claim_rec.tax_code
      ,x_claim_rec.tax_calculation_flag
      ,x_claim_rec.currency_code
      ,x_claim_rec.exchange_rate_type
      ,x_claim_rec.exchange_rate_date
      ,x_claim_rec.exchange_rate
      ,x_claim_rec.set_of_books_id
      ,x_claim_rec.original_claim_date
      ,x_claim_rec.source_object_id
      ,x_claim_rec.source_object_class
      ,x_claim_rec.source_object_type_id
      ,x_claim_rec.source_object_number
      ,x_claim_rec.cust_account_id
      ,x_claim_rec.cust_billto_acct_site_id
      ,x_claim_rec.cust_shipto_acct_site_id
      ,x_claim_rec.location_id
      ,x_claim_rec.pay_related_account_flag
      ,x_claim_rec.related_cust_account_id
      ,x_claim_rec.related_site_use_id
      ,x_claim_rec.relationship_type
      ,x_claim_rec.vendor_id
      ,x_claim_rec.vendor_site_id
      ,x_claim_rec.reason_type
      ,x_claim_rec.reason_code_id
      ,x_claim_rec.task_template_group_id
      ,x_claim_rec.status_code
      ,x_claim_rec.user_status_id
      ,x_claim_rec.sales_rep_id
      ,x_claim_rec.collector_id
      ,x_claim_rec.contact_id
      ,x_claim_rec.broker_id
      ,x_claim_rec.territory_id
      ,x_claim_rec.customer_ref_date
      ,x_claim_rec.customer_ref_number
      ,x_claim_rec.assigned_to
      ,x_claim_rec.receipt_id
      ,x_claim_rec.receipt_number
      ,x_claim_rec.doc_sequence_id
      ,x_claim_rec.doc_sequence_value
      ,x_claim_rec.gl_date
      ,x_claim_rec.payment_method
      ,x_claim_rec.voucher_id
      ,x_claim_rec.voucher_number
      ,x_claim_rec.payment_reference_id
      ,x_claim_rec.payment_reference_number
      ,x_claim_rec.payment_reference_date
      ,x_claim_rec.payment_status
      ,x_claim_rec.approved_flag
      ,x_claim_rec.approved_date
      ,x_claim_rec.approved_by
      ,x_claim_rec.settled_date
      ,x_claim_rec.settled_by
      ,x_claim_rec.effective_date
      ,x_claim_rec.custom_setup_id
      ,x_claim_rec.task_id
      ,x_claim_rec.country_id
      ,x_claim_rec.comments
      ,x_claim_rec.attribute_category
      ,x_claim_rec.attribute1
      ,x_claim_rec.attribute2
      ,x_claim_rec.attribute3
      ,x_claim_rec.attribute4
      ,x_claim_rec.attribute5
      ,x_claim_rec.attribute6
      ,x_claim_rec.attribute7
      ,x_claim_rec.attribute8
      ,x_claim_rec.attribute9
      ,x_claim_rec.attribute10
      ,x_claim_rec.attribute11
      ,x_claim_rec.attribute12
      ,x_claim_rec.attribute13
      ,x_claim_rec.attribute14
      ,x_claim_rec.attribute15
      ,x_claim_rec.deduction_attribute_category
      ,x_claim_rec.deduction_attribute1
      ,x_claim_rec.deduction_attribute2
      ,x_claim_rec.deduction_attribute3
      ,x_claim_rec.deduction_attribute4
      ,x_claim_rec.deduction_attribute5
      ,x_claim_rec.deduction_attribute6
      ,x_claim_rec.deduction_attribute7
      ,x_claim_rec.deduction_attribute8
      ,x_claim_rec.deduction_attribute9
      ,x_claim_rec.deduction_attribute10
      ,x_claim_rec.deduction_attribute11
      ,x_claim_rec.deduction_attribute12
      ,x_claim_rec.deduction_attribute13
      ,x_claim_rec.deduction_attribute14
      ,x_claim_rec.deduction_attribute15
      ,x_claim_rec.org_id
      ,x_claim_rec.order_type_id
   FROM  ozf_claims
   WHERE claim_id = p_claim_id ;

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_QUERY_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Claim Id = '|| p_claim_id);
        OZF_Utility_PVT.debug_message('SQLERRM = '|| SQLERRM);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Query_Claim;


/*=======================================================================*
 | PROCEDURE
 |    Query_Claim_Line
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang   Create.
 *=======================================================================*/
PROCEDURE Query_Claim_Line(
    p_claim_id           IN    NUMBER
   ,x_claim_line_tbl     OUT NOCOPY   OZF_CLAIM_LINE_PVT.claim_line_tbl_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
)
IS
CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  ,      source_object_class
  ,      source_object_id
  ,      source_object_line_id
  ,      item_id
  ,      quantity
  ,      quantity_uom
  ,      rate
  ,      claim_currency_amount
  ,      tax_code
  ,      payment_status
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

i             PLS_INTEGER   := 1;

BEGIN
   OPEN csr_claim_line(p_claim_id);
   LOOP
      FETCH csr_claim_line INTO x_claim_line_tbl(i).claim_line_id
                              , x_claim_line_tbl(i).source_object_class
                              , x_claim_line_tbl(i).source_object_id
                              , x_claim_line_tbl(i).source_object_line_id
                              , x_claim_line_tbl(i).item_id
                              , x_claim_line_tbl(i).quantity
                              , x_claim_line_tbl(i).quantity_uom
                              , x_claim_line_tbl(i).rate
                              , x_claim_line_tbl(i).claim_currency_amount
                              , x_claim_line_tbl(i).tax_code
                              , x_claim_line_tbl(i).payment_status;
      EXIT WHEN csr_claim_line%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE csr_claim_line;

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_QUERY_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Query_Claim_Line;


/*=======================================================================*
 | PROCEDURE
 |    Complete_RMA_Order
 |
 | NOTES
 |
 | HISTORY
 |    15-JAN-2003  mchang   Create.
 *=======================================================================*/
PROCEDURE Complete_RMA_Order(
    p_x_claim_rec            IN OUT NOCOPY  OZF_CLAIM_PVT.claim_rec_type
   ,p_claim_line_tbl         IN    OZF_CLAIM_LINE_PVT.claim_line_tbl_type

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Complete_RMA_Order';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);

l_header_rec                    OE_ORDER_PUB.header_rec_type;
l_header_val_rec                OE_ORDER_PUB.header_val_rec_type;
l_header_adj_tbl                OE_ORDER_PUB.header_adj_tbl_type;
l_header_adj_val_tbl            OE_ORDER_PUB.header_adj_val_tbl_type;
l_header_price_att_tbl          OE_ORDER_PUB.header_price_att_tbl_type;
l_header_adj_att_tbl            OE_ORDER_PUB.header_adj_att_tbl_type;
l_header_adj_assoc_tbl          OE_ORDER_PUB.header_adj_assoc_tbl_type;
l_header_scredit_tbl            OE_ORDER_PUB.header_scredit_tbl_type;
l_header_scredit_val_tbl        OE_ORDER_PUB.header_scredit_val_tbl_type;

l_line_tbl                      OE_ORDER_PUB.line_tbl_type;
l_line_val_tbl                  OE_ORDER_PUB.line_val_tbl_type;
l_line_adj_tbl                  OE_ORDER_PUB.line_adj_tbl_type;
l_line_adj_val_tbl              OE_ORDER_PUB.line_adj_val_tbl_type;
l_line_price_att_tbl            OE_ORDER_PUB.line_price_att_tbl_type;
l_line_adj_att_tbl              OE_ORDER_PUB.line_adj_att_tbl_type;
l_line_adj_assoc_tbl            OE_ORDER_PUB.line_adj_assoc_tbl_type;
l_line_scredit_tbl              OE_ORDER_PUB.line_scredit_tbl_type;
l_line_scredit_val_tbl          OE_ORDER_PUB.line_scredit_val_tbl_type;
l_lot_serial_tbl                OE_ORDER_PUB.lot_serial_tbl_type;
l_lot_serial_val_tbl            OE_ORDER_PUB.lot_serial_val_tbl_type;
l_action_request_tbl            OE_ORDER_PUB.request_tbl_type;

l_x_header_rec                  OE_ORDER_PUB.header_rec_type;
l_x_header_val_rec              OE_ORDER_PUB.header_val_rec_type;
l_x_header_adj_tbl              OE_ORDER_PUB.header_adj_tbl_type;
l_x_header_adj_val_tbl          OE_ORDER_PUB.header_adj_val_tbl_type;
l_x_header_price_att_tbl        OE_ORDER_PUB.header_price_att_tbl_type;
l_x_header_adj_att_tbl          OE_ORDER_PUB.header_adj_att_tbl_type;
l_x_header_adj_assoc_tbl        OE_ORDER_PUB.header_adj_assoc_tbl_type;
l_x_header_scredit_tbl          OE_ORDER_PUB.header_scredit_tbl_type;
l_x_header_scredit_val_tbl      OE_ORDER_PUB.header_scredit_val_tbl_type;

l_x_line_tbl                    OE_ORDER_PUB.line_tbl_type;
l_x_line_val_tbl                OE_ORDER_PUB.line_val_tbl_type;
l_x_line_adj_tbl                OE_ORDER_PUB.line_adj_tbl_type;
l_x_line_adj_val_tbl            OE_ORDER_PUB.line_adj_val_tbl_type;
l_x_line_price_att_tbl          OE_ORDER_PUB.line_price_att_tbl_type;
l_x_line_adj_att_tbl            OE_ORDER_PUB.line_adj_att_tbl_type;
l_x_line_adj_assoc_tbl          OE_ORDER_PUB.line_adj_assoc_tbl_type;
l_x_line_scredit_tbl            OE_ORDER_PUB.line_scredit_tbl_type;
l_x_line_scredit_val_tbl        OE_ORDER_PUB.line_scredit_val_tbl_type;
l_x_lot_serial_tbl              OE_ORDER_PUB.lot_serial_tbl_type;
l_x_lot_serial_val_tbl          OE_ORDER_PUB.lot_serial_val_tbl_type;
l_x_action_request_tbl	        OE_ORDER_PUB.request_tbl_type;

i                               NUMBER;
l_adj_idx                       NUMBER := 1;
l_return_reson_code             VARCHAR2(30);
l_line_type_id                  NUMBER;
l_price_list_id                 NUMBER;
l_oe_msg_count                  NUMBER;
l_oe_msg_data                   VARCHAR2(2000);
l_credit_invoice_line_id        NUMBER;
l_rma_unit_price                NUMBER;
l_rma_price_diff                NUMBER;
l_modifer_header_id             NUMBER;
l_modifer_line_id               NUMBER;
l_tm_order_source_id            NUMBER;


CURSOR csr_return_reason(cv_reason_code_id IN NUMBER) IS
  SELECT reason_code
  FROM ozf_reason_codes_vl
  WHERE reason_code_id = cv_reason_code_id;

CURSOR csr_rma_trx_type(cv_order_type_id IN NUMBER) IS
  SELECT default_inbound_line_type_id
  FROM oe_transaction_types_vl
  WHERE transaction_type_id = cv_order_type_id;

CURSOR csr_inv_ord_line_attr(cv_invoice_line_id IN NUMBER) IS
  SELECT rctl.customer_trx_line_id
  FROM ra_customer_trx_lines rctl
  ,    oe_order_lines ol
  WHERE rctl.customer_trx_line_id = cv_invoice_line_id
  AND TO_NUMBER(rctl.interface_line_attribute6) = ol.line_id;

CURSOR csr_contact_role(cv_party_id IN NUMBER) IS
  SELECT cust_account_role_id
  FROM hz_cust_account_roles
  WHERE party_id = cv_party_id;

CURSOR csr_qp_list_price( cv_item_id IN NUMBER
                        , cv_price_list_id IN NUMBER
                        ) IS
  SELECT ql.list_price
  FROM qp_list_lines ql
  , qp_pricing_attributes atr
  WHERE ql.list_line_id = atr.list_line_id
  AND atr.product_attribute_context = 'ITEM'
  AND atr.product_attribute = 'PRICING_ATTRIBUTE1'
  AND atr.product_attr_value = cv_item_id
  AND atr.list_header_id = cv_price_list_id
  AND atr.excluder_flag = 'N';

CURSOR csr_sales_credit_type(cv_salesrep_id IN NUMBER) IS
  SELECT sales_credit_type_id
  FROM ra_salesreps
  WHERE salesrep_id = cv_salesrep_id;

CURSOR csr_rma_unit_price(cv_line_id IN NUMBER) IS
  SELECT unit_selling_price
  FROM oe_order_lines_all
  WHERE line_id = cv_line_id;

CURSOR csr_modifier(cv_list_line_id IN NUMBER) IS
  SELECT list_header_id
  FROM qp_list_lines
  WHERE list_line_id = cv_list_line_id;

CURSOR csr_order_source(cv_order_source_id IN NUMBER) IS
  SELECT order_source_id
  FROM oe_order_sources
  WHERE order_source_id = cv_order_source_id;


BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   l_price_list_id := FND_PROFILE.value('OZF_CLAIM_PRICE_LIST_ID');
   l_modifer_line_id := FND_PROFILE.value('OZF_CLAIM_RMA_MODIFIER_ID');

   OPEN csr_modifier(l_modifer_line_id);
   FETCH csr_modifier INTO l_modifer_header_id;
   CLOSE csr_modifier;

   ------------------------ start -------------------------
   OPEN csr_return_reason(p_x_claim_rec.reason_code_id);
   FETCH csr_return_reason INTO l_return_reson_code;
   CLOSE csr_return_reason;

   OPEN csr_rma_trx_type(p_x_claim_rec.order_type_id);
   FETCH csr_rma_trx_type INTO l_line_type_id;
   CLOSE csr_rma_trx_type;

  /*------------------------------------------------------*
   | 1. Setting up header record
   *------------------------------------------------------*/
   l_header_rec                             := OE_ORDER_PUB.g_miss_header_rec;

   -- Bug4249629
   l_header_rec.ordered_date :=
               NVL(p_x_claim_rec.effective_date,p_x_claim_rec.settled_date);
   OPEN csr_order_source(24);
   FETCH csr_order_source INTO l_tm_order_source_id;
   CLOSE csr_order_source;
   IF l_tm_order_source_id IS NOT NULL THEN
      l_header_rec.order_source_id          := l_tm_order_source_id;
   END IF;

   l_header_rec.orig_sys_document_ref       := 'OZF_CLAIMS_ALL:'||p_x_claim_rec.claim_number;

   l_header_rec.order_type_id               := p_x_claim_rec.order_type_id;

   l_header_rec.sold_to_org_id           := p_x_claim_rec.cust_account_id;
   IF p_x_claim_rec.pay_related_account_flag = 'T' THEN
      l_header_rec.invoice_to_org_id        := p_x_claim_rec.related_site_use_id;
      l_header_rec.ship_to_org_id           := p_x_claim_rec.cust_shipto_acct_site_id;
   ELSE
      l_header_rec.invoice_to_org_id        := p_x_claim_rec.cust_billto_acct_site_id;
      l_header_rec.ship_to_org_id           := p_x_claim_rec.cust_shipto_acct_site_id;
   END IF;
   IF p_x_claim_rec.sales_rep_id IS NOT NULL THEN
      l_header_rec.salesrep_id              := p_x_claim_rec.sales_rep_id;
   END IF;
   IF p_x_claim_rec.contact_id IS NOT NULL THEN
      OPEN csr_contact_role(p_x_claim_rec.contact_id);
      FETCH csr_contact_role INTO l_header_rec.sold_to_contact_id;
      CLOSE csr_contact_role;
   END IF;
   --l_header_rec.return_reason_code       := l_return_reson_code;
   IF l_price_list_id IS NOT NULL THEN
      l_header_rec.price_list_id               := l_price_list_id;
   END IF;
   --l_header_rec.order_date := sysdate;
   --l_header_rec.pricing_date := sysdate;
   l_header_rec.transactional_curr_code     := p_x_claim_rec.currency_code;
   l_header_rec.operation                   := OE_GLOBALS.g_opr_create;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': RMA header - order_type_id : '||l_header_rec.order_type_id);
      OZF_Utility_PVT.debug_message(l_full_name||': RMA header - sold_to_org_id : '||l_header_rec.sold_to_org_id);
      OZF_Utility_PVT.debug_message(l_full_name||': RMA header - invoice_to_org_id : '||l_header_rec.invoice_to_org_id);
      OZF_Utility_PVT.debug_message(l_full_name||': RMA header - ship_to_org_id : '||l_header_rec.ship_to_org_id);
   END IF;

  /*------------------------------------------------------*
   | 2. Setting up line records
   *------------------------------------------------------*/
   i := p_claim_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF p_claim_line_tbl(i).item_id IS NOT NULL THEN
            l_line_tbl(i)                        := OE_ORDER_PUB.g_miss_line_rec;
            IF p_claim_line_tbl(i).source_object_class IN ('INVOICE', 'ORDER') AND
               p_claim_line_tbl(i).source_object_id IS NOT NULL AND
               p_claim_line_tbl(i).source_object_line_id IS NOT NULL THEN
               IF p_claim_line_tbl(i).source_object_class = 'INVOICE' THEN
                  --[BEGIN OF BUG 3873986 Fixing]
                  IF ( p_x_claim_rec.claim_class = 'CLAIM' )
                     OR
                     ( p_x_claim_rec.claim_class = 'DEDUCTION' AND
                       p_x_claim_rec.source_object_id = p_claim_line_tbl(i).source_object_id
                     ) THEN
                  --[END OF BUG 3873986 Fixing]
                     OPEN csr_inv_ord_line_attr(p_claim_line_tbl(i).source_object_line_id);
                     FETCH csr_inv_ord_line_attr INTO l_credit_invoice_line_id;
                     CLOSE csr_inv_ord_line_attr;
                     IF l_credit_invoice_line_id IS NOT NULL THEN
                        l_line_tbl(i).return_context := 'INVOICE';
                        l_line_tbl(i).return_attribute1 := TO_CHAR(p_claim_line_tbl(i).source_object_id);
                        l_line_tbl(i).return_attribute2 := TO_CHAR(p_claim_line_tbl(i).source_object_line_id);
                     END IF;
                  END IF;
               ELSIF p_claim_line_tbl(i).source_object_class = 'ORDER' THEN
                  l_line_tbl(i).return_context := 'ORDER';
                  l_line_tbl(i).return_attribute1 := TO_CHAR(p_claim_line_tbl(i).source_object_id);
                  l_line_tbl(i).return_attribute2 := TO_CHAR(p_claim_line_tbl(i).source_object_line_id);
               END IF;
            END IF;
             --[BEGIN OF BUG 3735800 Fixing]
            l_line_tbl(i).item_identifier_type    := 'INT';
            --[END OF BUG 3735800 Fixing]
            l_line_tbl(i).inventory_item_id       := p_claim_line_tbl(i).item_id;
            l_line_tbl(i).ordered_quantity        := p_claim_line_tbl(i).quantity * -1;
            l_line_tbl(i).order_quantity_uom      := p_claim_line_tbl(i).quantity_uom;
            l_line_tbl(i).return_reason_code      := l_return_reson_code;
            --[BEGIN OF BUG 3831562 Fixing]
            --l_line_tbl(i).line_type_id            := l_line_type_id;
            --[END OF BUG 3831562 Fixing]
            --l_line_tbl(i).price_list_id           := l_price_list_id;
            --l_line_tbl(i).unit_list_price         := p_claim_line_tbl(i).rate;
            l_line_tbl(i).unit_selling_price      := p_claim_line_tbl(i).rate;
            -- Bug3965003: Tax Code should be passed to OM APIs if the RMA does not
            -- reference an Order/Invoice.
            IF ( p_claim_line_tbl(i).source_object_class IS NULL OR
                 p_claim_line_tbl(i).source_object_class NOT IN ('INVOICE', 'DM', 'CB', 'ORDER')) AND
                p_claim_line_tbl(i).source_object_id IS NULL AND
                p_claim_line_tbl(i).tax_code IS NOT NULL THEN
                  l_line_tbl(i).tax_code                := p_claim_line_tbl(i).tax_code;
            END IF;

            --l_line_tbl(i).calculate_price_flag    := NVL(p_claim_line_tbl(i).payment_status, 'Y');
            --IF l_line_tbl(i).calculate_price_flag = 'N' THEN
               OPEN csr_qp_list_price(p_claim_line_tbl(i).item_id, l_price_list_id);
               FETCH csr_qp_list_price INTO l_line_tbl(i).unit_list_price;
               CLOSE csr_qp_list_price;
            --END IF;
            l_line_tbl(i).operation               := OE_GLOBALS.g_opr_create;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': RMA line'||i||': '||l_line_tbl(i).inventory_item_id||'/'||l_line_tbl(i).ordered_quantity||'/'||l_line_tbl(i).order_quantity_uom||'/'||l_line_tbl(i).unit_list_price);
               OZF_Utility_PVT.debug_message(l_full_name||': RMA line'||i||' reference: '||l_line_tbl(i).return_context||'/'||l_line_tbl(i).return_attribute1||'/'||l_line_tbl(i).return_attribute2);
               OZF_Utility_PVT.debug_message(l_full_name||': RMA line'||i||' return_reason_code : '||l_line_tbl(i).return_reason_code);
               OZF_Utility_PVT.debug_message(l_full_name||': RMA line'||i||' line_type_id : '||l_line_tbl(i).line_type_id);
            END IF;
         END IF;
         EXIT WHEN i = p_claim_line_tbl.LAST;
         i := p_claim_line_tbl.NEXT(i);
      END LOOP;
   END IF;

  /*------------------------------------------------------*
   | 3. Create an order in Order Management
   *------------------------------------------------------*/
   -- [BEGIN OF BUG 3868264 FIXING]
   -- Change OM Order Creation call to OE_ORDER_GRP api, as per apps standards.
   OE_ORDER_GRP.Process_Order(
       p_api_version_number            => l_api_version
      ,p_init_msg_list                 => FND_API.g_false
      ,p_return_values                 => FND_API.g_true
      ,p_commit                        => FND_API.g_false
      ,p_validation_level              => FND_API.g_valid_level_full

      ,x_return_status                 => l_return_status
      ,x_msg_count                     => l_oe_msg_count
      ,x_msg_data                      => l_oe_msg_data
   -- [END OF BUG 3868264 FIXING]
      ,p_header_rec                    => l_header_rec
      ,p_header_val_rec                => l_header_val_rec
      ,p_Header_Adj_tbl                => l_Header_Adj_tbl
      ,p_Header_Adj_val_tbl            => l_Header_Adj_val_tbl
      ,p_Header_price_Att_tbl          => l_Header_price_Att_tbl
      ,p_Header_Adj_Att_tbl            => l_Header_Adj_Att_tbl
      ,p_Header_Adj_Assoc_tbl          => l_Header_Adj_Assoc_tbl
      ,p_Header_Scredit_tbl            => l_Header_Scredit_tbl
      ,p_Header_Scredit_val_tbl        => l_Header_Scredit_val_tbl
      ,p_line_tbl                      => l_line_tbl
      ,p_line_val_tbl                  => l_line_val_tbl
      ,p_Line_Adj_tbl                  => l_Line_Adj_tbl
      ,p_Line_Adj_val_tbl              => l_Line_Adj_val_tbl
      ,p_Line_price_Att_tbl            => l_Line_price_Att_tbl
      ,p_Line_Adj_Att_tbl              => l_Line_Adj_Att_tbl
      ,p_Line_Adj_Assoc_tbl            => l_Line_Adj_Assoc_tbl
      ,p_Line_Scredit_tbl              => l_Line_Scredit_tbl
      ,p_Line_Scredit_val_tbl          => l_Line_Scredit_val_tbl
      ,p_Lot_Serial_tbl                => l_Lot_Serial_tbl
      ,p_Lot_Serial_val_tbl            => l_Lot_Serial_val_tbl
      ,p_action_request_tbl            => l_action_request_tbl

      ,x_header_rec                    => l_x_header_rec
      ,x_header_val_rec                => l_x_header_val_rec
      ,x_Header_Adj_tbl                => l_x_Header_Adj_tbl
      ,x_Header_Adj_val_tbl            => l_x_Header_Adj_val_tbl
      ,x_Header_price_Att_tbl          => l_x_Header_price_Att_tbl
      ,x_Header_Adj_Att_tbl            => l_x_Header_Adj_Att_tbl
      ,x_Header_Adj_Assoc_tbl          => l_x_Header_Adj_Assoc_tbl
      ,x_Header_Scredit_tbl            => l_x_Header_Scredit_tbl
      ,x_Header_Scredit_val_tbl        => l_x_Header_Scredit_val_tbl

      ,x_line_tbl                      => l_x_line_tbl
      ,x_line_val_tbl                  => l_x_line_val_tbl
      ,x_Line_Adj_tbl                  => l_x_Line_Adj_tbl
      ,x_Line_Adj_val_tbl              => l_x_Line_Adj_val_tbl
      ,x_Line_price_Att_tbl            => l_x_Line_price_Att_tbl
      ,x_Line_Adj_Att_tbl              => l_x_Line_Adj_Att_tbl
      ,x_Line_Adj_Assoc_tbl            => l_x_Line_Adj_Assoc_tbl
      ,x_Line_Scredit_tbl              => l_x_Line_Scredit_tbl
      ,x_Line_Scredit_val_tbl          => l_x_Line_Scredit_val_tbl
      ,x_Lot_Serial_tbl                => l_x_Lot_Serial_tbl
      ,x_Lot_Serial_val_tbl            => l_x_Lot_Serial_val_tbl

      ,x_action_request_tbl	         => l_x_action_request_tbl
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      FOR i in 1 .. l_oe_msg_count LOOP
         l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                         , p_encoded   => 'F'
                                         );
         FND_MESSAGE.SET_NAME('OZF', 'OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
         FND_MSG_PUB.ADD;
      END LOOP;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      FOR i in 1 .. l_oe_msg_count LOOP
         l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                         , p_encoded   => 'F'
                                         );
         FND_MESSAGE.SET_NAME('OZF', 'OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
         FND_MSG_PUB.ADD;
      END LOOP;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  /*------------------------------------------------------*
   | 4. Query selling price of RMA created by TM
   *------------------------------------------------------*/
   i := l_x_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      l_header_rec := OE_ORDER_PUB.g_miss_header_rec;
      l_header_rec.header_id := l_x_header_rec.header_id;
      -- [BEGIN OF BUG 3868264 FIXING]
      l_header_rec.change_reason := 'SYSTEM';
      -- [END OF BUG 3868264 FIXING]
      l_header_rec.operation := OE_GLOBALS.g_opr_update;

     LOOP
        IF p_claim_line_tbl(i).item_id = l_x_line_tbl(i).inventory_item_id THEN
           l_line_tbl(i).line_id := l_x_line_tbl(i).line_id;
           -- [BEGIN OF BUG 3868264 FIXING]
           l_line_tbl(i).change_reason := 'SYSTEM';
           -- [END OF BUG 3868264 FIXING]
           l_line_tbl(i).operation := OE_GLOBALS.g_opr_update;

           OPEN csr_rma_unit_price(l_x_line_tbl(i).line_id);
           FETCH csr_rma_unit_price INTO l_rma_unit_price;
           CLOSE csr_rma_unit_price;

           IF p_claim_line_tbl(i).rate IS NOT NULL AND
              l_rma_unit_price <> p_claim_line_tbl(i).rate THEN
              IF l_modifer_line_id IS NULL THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                    FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_MODIFIER_ERR');
                    FND_MSG_PUB.add;
                 END IF;
                 RAISE FND_API.g_exc_error;
              ELSE
                 l_rma_price_diff := l_rma_unit_price - p_claim_line_tbl(i).rate;

                 l_line_adj_tbl(l_adj_idx) :=OE_ORDER_PUB.g_miss_line_adj_rec;

                 l_line_adj_tbl(l_adj_idx).line_index := i;
                 l_line_adj_tbl(l_adj_idx).list_header_id := l_modifer_header_id;
                 l_line_adj_tbl(l_adj_idx).list_line_id := l_modifer_line_id;
                 l_line_adj_tbl(l_adj_idx).modifier_level_code := 'LINE';
                 l_line_adj_tbl(l_adj_idx).operand := l_rma_price_diff;
                 l_line_adj_tbl(l_adj_idx).adjusted_amount_per_pqty := l_rma_price_diff * -1;
                 l_line_adj_tbl(l_adj_idx).arithmetic_operator := 'AMT';
                 l_line_adj_tbl(l_adj_idx).updated_flag := 'Y';
                 l_line_adj_tbl(l_adj_idx).applied_flag := 'Y';
                 -- [BEGIN OF BUG 3868264 FIXING]
                 l_line_adj_tbl(l_adj_idx).change_reason_code := 'SYSTEM';
                 -- [END OF BUG 3868264 FIXING]
                 l_line_adj_tbl(l_adj_idx).operation := OE_GLOBALS.g_opr_create;

                 l_adj_idx := l_adj_idx + 1;
              END IF;
           END IF;
        END IF;
        EXIT WHEN i =  l_x_line_tbl.LAST;
        i :=  l_x_line_tbl.NEXT(i);
     END LOOP;
   END IF;

  /*------------------------------------------------------*
   | 5. Adjust price
   *------------------------------------------------------*/
   i := l_line_adj_tbl.FIRST;
   IF i IS NOT NULL THEN
      OE_ORDER_GRP.Process_Order(
          p_api_version_number            => l_api_version
         ,p_init_msg_list                 => FND_API.g_false
         ,p_return_values                 => FND_API.g_true
         ,p_commit                 => FND_API.g_false
         ,x_return_status                 => l_return_status
         ,x_msg_count                     => l_oe_msg_count
         ,x_msg_data                      => l_oe_msg_data

         ,p_header_rec                    => l_header_rec
         ,p_header_val_rec                => l_header_val_rec
         ,p_Header_Adj_tbl                => l_Header_Adj_tbl
         ,p_Header_Adj_val_tbl            => l_Header_Adj_val_tbl
         ,p_Header_price_Att_tbl          => l_Header_price_Att_tbl
         ,p_Header_Adj_Att_tbl            => l_Header_Adj_Att_tbl
         ,p_Header_Adj_Assoc_tbl          => l_Header_Adj_Assoc_tbl
         ,p_Header_Scredit_tbl            => l_Header_Scredit_tbl
         ,p_Header_Scredit_val_tbl        => l_Header_Scredit_val_tbl
         ,p_line_tbl                      => l_line_tbl
         ,p_line_val_tbl                  => l_line_val_tbl
         ,p_Line_Adj_tbl                  => l_Line_Adj_tbl
         ,p_Line_Adj_val_tbl              => l_Line_Adj_val_tbl
         ,p_Line_price_Att_tbl            => l_Line_price_Att_tbl
         ,p_Line_Adj_Att_tbl              => l_Line_Adj_Att_tbl
         ,p_Line_Adj_Assoc_tbl            => l_Line_Adj_Assoc_tbl
         ,p_Line_Scredit_tbl              => l_Line_Scredit_tbl
         ,p_Line_Scredit_val_tbl          => l_Line_Scredit_val_tbl
         ,p_Lot_Serial_tbl                => l_Lot_Serial_tbl
         ,p_Lot_Serial_val_tbl            => l_Lot_Serial_val_tbl
         ,p_action_request_tbl            => l_action_request_tbl

         ,x_header_rec                    => l_x_header_rec
         ,x_header_val_rec                => l_x_header_val_rec
         ,x_Header_Adj_tbl                => l_x_Header_Adj_tbl
         ,x_Header_Adj_val_tbl            => l_x_Header_Adj_val_tbl
         ,x_Header_price_Att_tbl          => l_x_Header_price_Att_tbl
         ,x_Header_Adj_Att_tbl            => l_x_Header_Adj_Att_tbl
         ,x_Header_Adj_Assoc_tbl          => l_x_Header_Adj_Assoc_tbl
         ,x_Header_Scredit_tbl            => l_x_Header_Scredit_tbl
         ,x_Header_Scredit_val_tbl        => l_x_Header_Scredit_val_tbl

         ,x_line_tbl                      => l_x_line_tbl
         ,x_line_val_tbl                  => l_x_line_val_tbl
         ,x_Line_Adj_tbl                  => l_x_Line_Adj_tbl
         ,x_Line_Adj_val_tbl              => l_x_Line_Adj_val_tbl
         ,x_Line_price_Att_tbl            => l_x_Line_price_Att_tbl
         ,x_Line_Adj_Att_tbl              => l_x_Line_Adj_Att_tbl
         ,x_Line_Adj_Assoc_tbl            => l_x_Line_Adj_Assoc_tbl
         ,x_Line_Scredit_tbl              => l_x_Line_Scredit_tbl
         ,x_Line_Scredit_val_tbl          => l_x_Line_Scredit_val_tbl
         ,x_Lot_Serial_tbl                => l_x_Lot_Serial_tbl
         ,x_Lot_Serial_val_tbl            => l_x_Lot_Serial_val_tbl

         ,x_action_request_tbl	         => l_x_action_request_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         FOR i in 1 .. l_oe_msg_count LOOP
            l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                            , p_encoded   => 'F'
                                            );
            FND_MESSAGE.SET_NAME('AMS', 'AMS_API_DEBUG_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
            FND_MSG_PUB.ADD;
         END LOOP;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         FOR i in 1 .. l_oe_msg_count LOOP
            l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                            , p_encoded   => 'F'
                                            );
            FND_MESSAGE.SET_NAME('AMS', 'AMS_API_DEBUG_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
            FND_MSG_PUB.ADD;
         END LOOP;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_OM_CRE_ORD_U_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


  /*------------------------------------------------------*
   | 6. Update RMA order information in Claim after order is
   |    been successfully created.
   *------------------------------------------------------*/

   UPDATE ozf_claims_all
   SET payment_reference_id = l_x_header_rec.header_id
   ,   payment_reference_number = l_x_header_rec.order_number
   ,   payment_reference_date = l_x_header_rec.ordered_date
   WHERE claim_id = p_x_claim_rec.claim_id;

   i := l_x_line_tbl.FIRST;
   IF i IS NOT NULL THEN
     LOOP
        IF p_claim_line_tbl(i).item_id = l_x_line_tbl(i).inventory_item_id THEN
           UPDATE ozf_claim_lines_all
           SET payment_reference_id = l_x_line_tbl(i).line_id
           ,   payment_reference_number =  l_x_line_tbl(i).line_number
           WHERE claim_line_id = p_claim_line_tbl(i).claim_line_id;
        END IF;
        EXIT WHEN i =  l_x_line_tbl.LAST;
        i :=  l_x_line_tbl.NEXT(i);
     END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Complete_RMA_Order;


/*=======================================================================*
 | PROCEDURE
 |    Book_RMA_Order
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang   Create.
 *=======================================================================*/
PROCEDURE Book_RMA_Order(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_claim_line_tbl         IN    OZF_CLAIM_LINE_PVT.claim_line_tbl_type

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Book_RMA_Order';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);

l_header_rec                    OE_ORDER_PUB.header_rec_type;
l_header_val_rec                OE_ORDER_PUB.header_val_rec_type;
l_header_adj_tbl                OE_ORDER_PUB.header_adj_tbl_type;
l_header_adj_val_tbl            OE_ORDER_PUB.header_adj_val_tbl_type;
l_header_price_att_tbl          OE_ORDER_PUB.header_price_att_tbl_type;
l_header_adj_att_tbl            OE_ORDER_PUB.header_adj_att_tbl_type;
l_header_adj_assoc_tbl          OE_ORDER_PUB.header_adj_assoc_tbl_type;
l_header_scredit_tbl            OE_ORDER_PUB.header_scredit_tbl_type;
l_header_scredit_val_tbl        OE_ORDER_PUB.header_scredit_val_tbl_type;

l_line_tbl                      OE_ORDER_PUB.line_tbl_type;
l_line_val_tbl                  OE_ORDER_PUB.line_val_tbl_type;
l_line_adj_tbl                  OE_ORDER_PUB.line_adj_tbl_type;
l_line_adj_val_tbl              OE_ORDER_PUB.line_adj_val_tbl_type;
l_line_price_att_tbl            OE_ORDER_PUB.line_price_att_tbl_type;
l_line_adj_att_tbl              OE_ORDER_PUB.line_adj_att_tbl_type;
l_line_adj_assoc_tbl            OE_ORDER_PUB.line_adj_assoc_tbl_type;
l_line_scredit_tbl              OE_ORDER_PUB.line_scredit_tbl_type;
l_line_scredit_val_tbl          OE_ORDER_PUB.line_scredit_val_tbl_type;
l_lot_serial_tbl                OE_ORDER_PUB.lot_serial_tbl_type;
l_lot_serial_val_tbl            OE_ORDER_PUB.lot_serial_val_tbl_type;
l_action_request_tbl            OE_ORDER_PUB.request_tbl_type;

l_x_header_rec                  OE_ORDER_PUB.header_rec_type;
l_x_header_val_rec              OE_ORDER_PUB.header_val_rec_type;
l_x_header_adj_tbl              OE_ORDER_PUB.header_adj_tbl_type;
l_x_header_adj_val_tbl          OE_ORDER_PUB.header_adj_val_tbl_type;
l_x_header_price_att_tbl        OE_ORDER_PUB.header_price_att_tbl_type;
l_x_header_adj_att_tbl          OE_ORDER_PUB.header_adj_att_tbl_type;
l_x_header_adj_assoc_tbl        OE_ORDER_PUB.header_adj_assoc_tbl_type;
l_x_header_scredit_tbl          OE_ORDER_PUB.header_scredit_tbl_type;
l_x_header_scredit_val_tbl      OE_ORDER_PUB.header_scredit_val_tbl_type;

l_x_line_tbl                    OE_ORDER_PUB.line_tbl_type;
l_x_line_val_tbl                OE_ORDER_PUB.line_val_tbl_type;
l_x_line_adj_tbl                OE_ORDER_PUB.line_adj_tbl_type;
l_x_line_adj_val_tbl            OE_ORDER_PUB.line_adj_val_tbl_type;
l_x_line_price_att_tbl          OE_ORDER_PUB.line_price_att_tbl_type;
l_x_line_adj_att_tbl            OE_ORDER_PUB.line_adj_att_tbl_type;
l_x_line_adj_assoc_tbl          OE_ORDER_PUB.line_adj_assoc_tbl_type;
l_x_line_scredit_tbl            OE_ORDER_PUB.line_scredit_tbl_type;
l_x_line_scredit_val_tbl        OE_ORDER_PUB.line_scredit_val_tbl_type;
l_x_lot_serial_tbl              OE_ORDER_PUB.lot_serial_tbl_type;
l_x_lot_serial_val_tbl          OE_ORDER_PUB.lot_serial_val_tbl_type;
l_x_action_request_tbl	        OE_ORDER_PUB.request_tbl_type;

i                               NUMBER;
l_oe_msg_count                  NUMBER;
l_oe_msg_data                   VARCHAR2(2000);

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OE_STANDARD_WF.save_messages_off;

   ------------------------ start -------------------------
  /*------------------------------------------------------*
   | Book RMA order
   *------------------------------------------------------*/
   l_action_request_tbl(1)               := OE_ORDER_PUB.g_miss_request_rec;
   l_action_request_tbl(1).request_type  := OE_GLOBALS.g_book_order;
   l_action_request_tbl(1).entity_code   := OE_GLOBALS.g_entity_header;
   --l_action_request_tbl(1).entity_id     := l_x_header_rec.header_id;
   l_action_request_tbl(1).entity_id     := p_claim_rec.payment_reference_id;


   OE_ORDER_GRP.Process_Order(
       p_api_version_number            => l_api_version
      ,p_init_msg_list                 => FND_API.g_false
      ,p_return_values                 => FND_API.g_true
      ,p_commit                 => FND_API.g_false
      ,x_return_status                 => l_return_status
      ,x_msg_count                     => l_oe_msg_count
      ,x_msg_data                      => l_oe_msg_data

      ,p_action_request_tbl            => l_action_request_tbl

      ,x_header_rec                    => l_x_header_rec
      ,x_header_val_rec                => l_x_header_val_rec
      ,x_Header_Adj_tbl                => l_x_Header_Adj_tbl
      ,x_Header_Adj_val_tbl            => l_x_Header_Adj_val_tbl
      ,x_Header_price_Att_tbl          => l_x_Header_price_Att_tbl
      ,x_Header_Adj_Att_tbl            => l_x_Header_Adj_Att_tbl
      ,x_Header_Adj_Assoc_tbl          => l_x_Header_Adj_Assoc_tbl
      ,x_Header_Scredit_tbl            => l_x_Header_Scredit_tbl
      ,x_Header_Scredit_val_tbl        => l_x_Header_Scredit_val_tbl

      ,x_line_tbl                      => l_x_line_tbl
      ,x_line_val_tbl                  => l_x_line_val_tbl
      ,x_Line_Adj_tbl                  => l_x_Line_Adj_tbl
      ,x_Line_Adj_val_tbl              => l_x_Line_Adj_val_tbl
      ,x_Line_price_Att_tbl            => l_x_Line_price_Att_tbl
      ,x_Line_Adj_Att_tbl              => l_x_Line_Adj_Att_tbl
      ,x_Line_Adj_Assoc_tbl            => l_x_Line_Adj_Assoc_tbl
      ,x_Line_Scredit_tbl              => l_x_Line_Scredit_tbl
      ,x_Line_Scredit_val_tbl          => l_x_Line_Scredit_val_tbl
      ,x_Lot_Serial_tbl                => l_x_Lot_Serial_tbl
      ,x_Lot_Serial_val_tbl            => l_x_Lot_Serial_val_tbl

      ,x_action_request_tbl	         => l_x_action_request_tbl
   );
   IF l_x_action_request_tbl(1).request_type <> OE_GLOBALS.g_book_order THEN
      FOR i in 1 .. l_oe_msg_count LOOP
         l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                         , p_encoded   => 'F'
                                         );
         FND_MESSAGE.SET_NAME('OZF', 'OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
         FND_MSG_PUB.ADD;
      END LOOP;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_BOK_ORD_E_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;

   ELSIF l_return_status =  FND_API.g_ret_sts_error THEN
      FOR i in 1 .. l_oe_msg_count LOOP
         l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                         , p_encoded   => 'F'
                                         );
         FND_MESSAGE.SET_NAME('OZF', 'OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
         FND_MSG_PUB.ADD;
      END LOOP;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_BOK_ORD_E_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      FOR i in 1 .. l_oe_msg_count LOOP
         l_oe_msg_data :=  OE_MSG_PUB.get( p_msg_index => i
                                         , p_encoded   => 'F'
                                         );
         FND_MESSAGE.SET_NAME('OZF', 'OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.SET_TOKEN('TEXT', l_oe_msg_data);
         FND_MSG_PUB.ADD;
      END LOOP;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_BOK_ORD_U_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Book_RMA_Order;


/*=======================================================================*
 | PROCEDURE
 |    Create_OM_Payment
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Create_OM_Payment(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Create_OM_Payment';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);

  l_claim_rec            OZF_CLAIM_PVT.claim_rec_type;
  l_claim_line_tbl       OZF_CLAIM_LINE_PVT.claim_line_tbl_type;

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Create_OM_Payment;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   Query_Claim(
        p_claim_id           => p_claim_id
       ,x_claim_rec          => l_claim_rec
       ,x_return_status      => l_return_status
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   Query_Claim_Line(
        p_claim_id           => p_claim_id
       ,x_claim_line_tbl     => l_claim_line_tbl
       ,x_return_status      => l_return_status
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF l_claim_rec.payment_method = 'RMA' THEN
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('Create RMA order for ==> '||l_claim_rec.claim_number);
      END IF;
      OZF_OM_PAYMENT_PVT.Complete_RMA_Order(
          p_x_claim_rec           => l_claim_rec
         ,p_claim_line_tbl        => l_claim_line_tbl
         ,x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count
       );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
      END IF;

      Query_Claim(
           p_claim_id           => p_claim_id
          ,x_claim_rec          => l_claim_rec
          ,x_return_status      => l_return_status
         );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('Book RMA order for ==> '||l_claim_rec.claim_number);
         OZF_Utility_PVT.debug_message('RMA order number = '||l_claim_rec.payment_reference_number);
      END IF;
      Book_RMA_Order(
           p_claim_rec             => l_claim_rec
          ,p_claim_line_tbl        => l_claim_line_tbl
          ,x_return_status         => l_return_status
          ,x_msg_data              => x_msg_data
          ,x_msg_count             => x_msg_count
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- reset payment status in ozf_claim_lines_all
   BEGIN
      UPDATE ozf_claim_lines_all
      SET payment_status = 'PENDING'
      WHERE claim_id = p_claim_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TEXT',SQLERRM);
            FND_MSG_PUB.ADD;
         END IF;
   END;

   ------------------------ finish ------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_OM_Payment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_OM_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

   WHEN OTHERS THEN
      ROLLBACK TO Create_OM_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_OM_Payment;

END OZF_OM_PAYMENT_PVT;

/
