--------------------------------------------------------
--  DDL for Package Body OZF_OM_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OM_VALIDATION_PVT" AS
/* $Header: ozfvomvb.pls 120.2.12010000.2 2009/01/01 05:16:44 psomyaju ship $ */

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'OZF_OM_VALIDATION_PVT';
G_FILE_NAME          CONSTANT VARCHAR2(12) := 'ozfvomvb.pls';

OZF_DEBUG_HIGH_ON    CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON     CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

/*=======================================================================*
 | PROCEDURE
 |    Price_Item
 |
 | NOTES
 |    This API default the unit price for a item.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Price_Item(
    p_cust_account_id       IN  NUMBER
   ,p_order_type_id         IN  NUMBER
   --,p_price_list_id         IN  NUMBER
   ,p_currency_code         IN  VARCHAR2

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_item_tbl            IN OUT NOCOPY claim_line_item_tbl_type
)
IS
l_api_version          CONSTANT NUMBER       := 1.0;
l_api_name             CONSTANT VARCHAR2(30) := 'Price_Item';
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status                 VARCHAR2(1);
/*
l_p_line_tbl                  QP_PREQ_GRP.line_tbl_type;
l_p_qual_tbl                  QP_PREQ_GRP.qual_tbl_type;
l_p_line_attr_tbl             QP_PREQ_GRP.line_attr_tbl_type;
l_p_line_detail_tbl           QP_PREQ_GRP.line_detail_tbl_type;
l_p_line_detail_qual_tbl      QP_PREQ_GRP.line_detail_qual_tbl_type;
l_p_line_detail_attr_tbl      QP_PREQ_GRP.line_detail_attr_tbl_type;
l_p_related_lines_tbl         QP_PREQ_GRP.related_lines_tbl_type;
l_p_control_rec               QP_PREQ_GRP.control_record_type;
l_x_line_tbl                  QP_PREQ_GRP.line_tbl_type;
l_x_line_qual                 QP_PREQ_GRP.qual_tbl_type;
l_x_line_attr_tbl             QP_PREQ_GRP.line_attr_tbl_type;
l_x_line_detail_tbl           QP_PREQ_GRP.line_detail_tbl_type;l_x_line_detail_qual_tbl      QP_PREQ_GRP.line_detail_qual_tbl_type;
l_x_line_detail_attr_tbl      QP_PREQ_GRP.line_detail_attr_tbl_type;
l_x_related_lines_tbl         QP_PREQ_GRP.related_lines_tbl_type;
l_return_status               VARCHAR2(240);
l_return_status_text          VARCHAR2(240);
*/

l_header_id                   NUMBER      := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24MISS'));
l_p_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_p_x_line_tbl                OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE;
l_x_ldets_tbl                 OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;
l_x_related_lines_tbl         OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE;
l_price_list_id               NUMBER;

i                             NUMBER;
idx_price_line                NUMBER;
l_prod_name                   VARCHAR2(40);
l_uom_name                    VARCHAR2(25);
l_error                       BOOlEAN     := FALSE;
l_inv_org_id                  NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OZF_ORDER_PRICE_PVT.Purge_Pricing_Temp_table(
        p_api_version            => l_api_version
       ,p_init_msg_list          => FND_API.g_false
       ,p_commit                 => FND_API.g_false
       ,p_validation_level       => FND_API.g_valid_level_full
       ,x_return_status          => l_return_status
       ,x_msg_data               => x_msg_data
       ,x_msg_count              => x_msg_count
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT','Expected error happened when calling OZF_ORDER_PRICE_PVT.Purge_Pricing_Temp_table().');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT','Unexpected error happened when calling OZF_ORDER_PRICE_PVT.Purge_Pricing_Temp_table().');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   l_price_list_id := FND_PROFILE.value('OZF_CLAIM_PRICE_LIST_ID');

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : price list id from profile = '||l_price_list_id);
   END IF;

   i := p_x_item_tbl.FIRST;
   IF i IS NOT NULL THEN
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.header_id                  := l_header_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.sold_to_org_id             := p_cust_account_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.order_type_id              := p_order_type_id;


      OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL.delete();

      LOOP
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).header_id          := l_header_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).inventory_item_id  := p_x_item_tbl(i).item_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).line_id            := null;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).ordered_quantity   := p_x_item_tbl(i).quantity;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).order_quantity_uom := p_x_item_tbl(i).quantity_uom;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).price_list_id      := null;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).sold_to_org_id     := p_cust_account_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(i).request_date       := sysdate;

         l_p_x_line_tbl(i).LINE_INDEX              := i;
         l_p_x_line_tbl(i).LINE_ID                 := null;
         l_p_x_line_tbl(i).LINE_TYPE_CODE          := 'LINE';
         l_p_x_line_tbl(i).PRICING_EFFECTIVE_DATE  := sysdate;
         l_p_x_line_tbl(i).ACTIVE_DATE_FIRST       := sysdate;
         l_p_x_line_tbl(i).ACTIVE_DATE_FIRST_TYPE  := 'NO TYPE';
         l_p_x_line_tbl(i).ACTIVE_DATE_SECOND      := sysdate;
         l_p_x_line_tbl(i).ACTIVE_DATE_SECOND_TYPE := 'NO TYPE';
         l_p_x_line_tbl(i).LINE_QUANTITY           := p_x_item_tbl(i).quantity;
         l_p_x_line_tbl(i).LINE_UOM_CODE           := p_x_item_tbl(i).quantity_uom;
         l_p_x_line_tbl(i).REQUEST_TYPE_CODE       := 'ONT';
         l_p_x_line_tbl(i).PRICED_QUANTITY         := null;
         l_p_x_line_tbl(i).PRICED_UOM_CODE         := null;
         l_p_x_line_tbl(i).CURRENCY_CODE           := p_currency_code;
         l_p_x_line_tbl(i).UNIT_PRICE              := null;
         l_p_x_line_tbl(i).PERCENT_PRICE           := null;
         l_p_x_line_tbl(i).UOM_QUANTITY            := null;
         l_p_x_line_tbl(i).ADJUSTED_UNIT_PRICE     := null;
         l_p_x_line_tbl(i).UPD_ADJUSTED_UNIT_PRICE := null;
         l_p_x_line_tbl(i).PROCESSED_FLAG          := null;
         l_p_x_line_tbl(i).PRICE_FLAG              := 'Y';
         l_p_x_line_tbl(i).PROCESSING_ORDER        := null;
         l_p_x_line_tbl(i).PRICING_STATUS_CODE     := QP_PREQ_GRP.G_STATUS_UNCHANGED;
         l_p_x_line_tbl(i).PRICING_STATUS_TEXT     := null;
         l_p_x_line_tbl(i).ROUNDING_FLAG           := null;
         l_p_x_line_tbl(i).ROUNDING_FACTOR         := null;
         l_p_x_line_tbl(i).QUALIFIERS_EXIST_FLAG   := null;
         l_p_x_line_tbl(i).PRICING_ATTRS_EXIST_FLAG:= null;
         l_p_x_line_tbl(i).PRICE_LIST_ID           := l_price_list_id;
         l_p_x_line_tbl(i).PL_VALIDATED_FLAG       := null;
         l_p_x_line_tbl(i).PRICE_REQUEST_CODE      := null;
         l_p_x_line_tbl(i).USAGE_PRICING_TYPE      := null;
      EXIT WHEN i = p_x_item_tbl.LAST;
      i := p_x_item_tbl.NEXT(i);
      END LOOP;
   END IF;

   OZF_ORDER_PRICE_PVT.Get_Order_Price(
       p_api_version       => l_api_version
      ,p_init_msg_list     => FND_API.g_false
      ,p_commit            => FND_API.g_false
      ,p_validation_level  => FND_API.g_valid_level_full
      ,x_return_status     => l_return_status
      ,x_msg_data          => x_msg_data
      ,x_msg_count         => x_msg_count
      ,p_control_rec       => l_p_control_rec
      ,xp_line_tbl         => l_p_x_line_tbl
      ,x_ldets_tbl         => l_x_ldets_tbl
      ,x_related_lines_tbl => l_x_related_lines_tbl
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT','Expected error happened when calling OZF_ORDER_PRICE_PVT.Get_Order_Price().');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT','Unexpected error happened when calling OZF_ORDER_PRICE_PVT.Get_Order_Price().');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   i := l_p_x_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF l_p_x_line_tbl(i).adjusted_unit_price IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	    l_inv_org_id := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
               l_prod_name := OZF_UTILITY_PVT.get_product_name(
                                       p_prod_level => 'PRODUCT'
                                      ,p_prod_id    => p_x_item_tbl(i).item_id
                                      --,p_org_id     => TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10))
                                      ,p_org_id     => l_inv_org_id

                              );
/*
               IF l_p_x_line_tbl(i).pricing_status_code = 'IPL' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Invalid price list for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'GSA' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','GSA violation for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'FER' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Error processing formula for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'CALC' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Error in calculation engine for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'UOM' THEN
                  l_uom_name := OZF_UTILITY_PVT.get_uom_name(p_uom_code => l_p_x_line_tbl(i).LINE_UOM_CODE);
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Failed to price using unit of measure('||l_uom_name||') for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'INVALID_UOM' THEN
                  l_uom_name := OZF_UTILITY_PVT.get_uom_name(p_uom_code => l_p_x_line_tbl(i).LINE_UOM_CODE);
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Invalid unit of measure('||l_uom_name||') for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'DUPLICATE_PRICE_LIST' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Duplicate price list for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'INVALID_UOM_CONV' THEN
                  l_uom_name := OZF_UTILITY_PVT.get_uom_name(p_uom_code => l_p_x_line_tbl(i).LINE_UOM_CODE);
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Unit of measure('||l_uom_name||') conversion is not found for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'INVALID_INCOMP' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Could not resolve incompatibility for pricing product '||l_prod_name);
                  FND_MSG_PUB.Add;
               ELSIF l_p_x_line_tbl(i).pricing_status_code = 'INVALID_BEST_PRICE' THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                  FND_MESSAGE.Set_Token('TEXT','Could not resolve best price for product '||l_prod_name);
                  FND_MSG_PUB.Add;
               END IF;
*/
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',l_p_x_line_tbl(i).pricing_status_text);
               FND_MSG_PUB.Add;

               FND_MESSAGE.set_name('OZF', 'OZF_SETL_DEF_PROD_PRICE_ERR');
               FND_MESSAGE.set_token('PROD', l_prod_name);
               FND_MSG_PUB.add;
            END IF;
            l_error := TRUE;
         ELSE
            p_x_item_tbl(i).rate := l_p_x_line_tbl(i).adjusted_unit_price; --adjusted_unit_price??
         END IF;
         EXIT WHEN i = l_p_x_line_tbl.LAST;
         i := l_p_x_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF l_error THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

/*
   -- Setting up the control record variables
   l_p_control_rec.pricing_event := 'LINE';
   l_p_control_rec.calculate_flag := 'Y';
   l_p_control_rec.simulation_flag := 'N';

   i := p_x_item_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         -- Request Line (Order Line) Information
         l_p_line_tbl(i).request_type_code :='ONT';
         l_p_line_tbl(i).line_id :=9999;
         l_p_line_tbl(i).line_Index := i;
         l_p_line_tbl(i).line_type_code := 'LINE';
         l_p_line_tbl(i).pricing_effective_date := sysdate;
         l_p_line_tbl(i).active_date_first := sysdate;
         l_p_line_tbl(i).active_date_second := sysdate;
         l_p_line_tbl(i).active_date_first_type := 'NO TYPE';
         l_p_line_tbl(i).active_date_second_type :='NO TYPE';
         l_p_line_tbl(i).line_quantity := p_x_item_tbl(i).quantity;
         l_p_line_tbl(i).line_uom_code := p_x_item_tbl(i).quantity_uom;
         l_p_line_tbl(i).currency_code := p_currency_code;
         l_p_line_tbl(i).price_flag := 'Y';

         -- Set Pricing Attributes
         l_p_line_attr_tbl(idx_line_attr).line_index := i;
         l_p_line_attr_tbl(idx_line_attr).pricing_context :='ITEM';
         l_p_line_attr_tbl(idx_line_attr).pricing_attribute :='PRICING_ATTRIBUTE1';
         l_p_line_attr_tbl(idx_line_attr).pricing_attr_value_from  := p_x_item_tbl(i).item_id; -- Inventory Item Id
         l_p_line_attr_tbl(idx_line_attr).validated_flag :='N';
         idx_line_attr := idx_line_attr + 1;

         -- Set Qualifiers (Price_List_Id)
         l_p_qual_tbl(idx_qual).line_index := i;
         l_p_qual_tbl(idx_qual).qualifier_context :='MODLIST';
         l_p_qual_tbl(idx_qual).qualifier_attribute :='QUALIFIER_ATTRIBUTE4';
         l_p_qual_tbl(idx_qual).qualifier_attr_value_from :=p_price_list_id; -- Price List Id
         l_p_qual_tbl(idx_qual).comparison_operator_code := '=';
         l_p_qual_tbl(idx_qual).validated_flag :='Y';
         idx_qual := idx_qual + 1;
         -- Set Qualifiers (Customer)
         l_p_qual_tbl(idx_qual).line_index := i;
         l_p_qual_tbl(idx_qual).qualifier_context :='CUSTOMER';
         l_p_qual_tbl(idx_qual).qualifier_attribute :='QUALIFIER_ATTRIBUTE2';
         l_p_qual_tbl(idx_qual).qualifier_attr_value_from :=p_cust_account_id;
         l_p_qual_tbl(idx_qual).comparison_operator_code := '=';
         l_p_qual_tbl(idx_qual).validated_flag :='Y';
         idx_qual := idx_qual + 1;

      EXIT WHEN i = p_x_item_tbl.LAST;
      i := p_x_item_tbl.NEXT(i);
      END LOOP;
   END IF;

    -- Call Pricing Engine
    QP_PREQ_GRP.PRICE_REQUEST(
        l_p_line_tbl,
        l_p_qual_tbl,
        l_p_line_attr_tbl,
        l_p_line_detail_tbl,
        l_p_line_detail_qual_tbl,
        l_p_line_detail_attr_tbl,
        l_p_related_lines_tbl,
        l_p_control_rec,
        l_x_line_tbl,
        l_x_line_qual,
        l_x_line_attr_tbl,
        l_x_line_detail_tbl,
        l_x_line_detail_qual_tbl,
        l_x_line_detail_attr_tbl,
        l_x_related_lines_tbl,
        l_return_status,
        l_return_status_text
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   i := l_x_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         p_x_item_tbl(i).rate := l_x_line_tbl(i).unit_price; --adjusted_unit_price??
         EXIT WHEN i = l_x_line_tbl.LAST;
         i := l_x_line_tbl.NEXT(i);
      END LOOP;
   END IF;
*/

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Price_Item;


/*=======================================================================*
 | PROCEDURE
 |    Price_Invoice_Line
 |
 | NOTES
 |    This API default the unit price for a invoice line.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Price_Invoice_Line(
    x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_inv_line_tbl        IN OUT NOCOPY claim_line_item_tbl_type
)
IS
l_api_version          CONSTANT NUMBER       := 1.0;
l_api_name             CONSTANT VARCHAR2(30) := 'Price_Invoice_Line';
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

CURSOR csr_inv_line_price(cv_customer_trx_line_id IN NUMBER) IS
  SELECT inventory_item_id
  ,      unit_selling_price
  ,      uom_code
  FROM ra_customer_trx_lines
  WHERE customer_trx_line_id = cv_customer_trx_line_id;

--Added for bug 7680032
CURSOR csr_om_line_price(cv_customer_trx_line_id NUMBER) IS
  SELECT ra.inventory_item_id
       , ol.unit_selling_price
       , ra.uom_code
  FROM ra_customer_trx_lines_all ra,
       oe_order_lines_all ol
  WHERE ra.customer_trx_line_id = cv_customer_trx_line_id
    AND ra.interface_line_attribute6 = ol.line_id;

i                             NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   i := p_x_inv_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
        --Profile logic added for bug 7680032
         IF fnd_profile.Value('OE_DISCOUNT_DETAILS_ON_INVOICE') = 'Y' THEN
           OPEN csr_om_line_price(p_x_inv_line_tbl(i).source_object_line_id);
           FETCH csr_om_line_price INTO p_x_inv_line_tbl(i).item_id
                                       , p_x_inv_line_tbl(i).rate
                                       , p_x_inv_line_tbl(i).quantity_uom;
           CLOSE csr_om_line_price;
         ELSE
           OPEN csr_inv_line_price(p_x_inv_line_tbl(i).source_object_line_id);
           FETCH csr_inv_line_price INTO p_x_inv_line_tbl(i).item_id
                                     , p_x_inv_line_tbl(i).rate
                                     , p_x_inv_line_tbl(i).quantity_uom;
           CLOSE csr_inv_line_price;
         END IF;
         EXIT WHEN i = p_x_inv_line_tbl.LAST;
         i := p_x_inv_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Price_Invoice_Line;


/*=======================================================================*
 | PROCEDURE
 |    Price_Order_Line
 |
 | NOTES
 |    This API default the unit price for a order line.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Price_Order_Line(
    x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_ord_line_tbl        IN OUT NOCOPY claim_line_item_tbl_type
)
IS
l_api_version          CONSTANT NUMBER       := 1.0;
l_api_name             CONSTANT VARCHAR2(30) := 'Price_Order_Line';
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

CURSOR csr_ord_line_price(cv_order_line_id IN NUMBER) IS
  SELECT inventory_item_id
  ,      unit_selling_price
  ,      order_quantity_uom
  FROM oe_order_lines
  WHERE line_id = cv_order_line_id;

i                               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   i := p_x_ord_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         OPEN csr_ord_line_price(p_x_ord_line_tbl(i).source_object_line_id);
         FETCH csr_ord_line_price INTO p_x_ord_line_tbl(i).item_id
                                     , p_x_ord_line_tbl(i).rate
                                     , p_x_ord_line_tbl(i).quantity_uom;
         CLOSE csr_ord_line_price;

         EXIT WHEN i = p_x_ord_line_tbl.LAST;
         i := p_x_ord_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Price_Order_Line;


/*=======================================================================*
 | PROCEDURE
 |    Get_Default_Order_Type
 |
 | NOTES
 |    This API default order_type_id for Claim.
 |
 | HISTORY
 |    16-JAN-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Get_Default_Order_Type(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_reason_code_id        IN  NUMBER
   ,p_claim_type_id         IN  NUMBER
   ,p_set_of_books_id       IN  NUMBER
   ,x_order_type_id         OUT NOCOPY NUMBER
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Get_Default_Order_Type';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_reason_rma_trx_type(cv_reason_code_id IN NUMBER) IS
  SELECT order_type_id
  FROM ozf_reason_codes_vl
  WHERE reason_code_id = cv_reason_code_id;

CURSOR csr_claim_type_rma_trx_type(cv_claim_type_id IN NUMBER) IS
  SELECT order_type_id
  FROM ozf_claim_types_vl
  WHERE claim_type_id = cv_claim_type_id;

CURSOR csr_sys_param_rma_trx_type(cv_set_of_books_id IN NUMBER) IS
  SELECT order_type_id
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_set_of_books_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- The following hierarchy is used to determine the default RMA transaction type,
   -- stopping when one is found
   -- 1. Reason (ozf_reason_codes_all_b.order_type_id)
   -- 2. Claim Type (ozf_claim_types_all_b.order_type_id)
   -- 3. System Parameter (ozf_sys_parameters_all.order_type_id)

   OPEN csr_reason_rma_trx_type(p_reason_code_id);
   FETCH csr_reason_rma_trx_type INTO x_order_type_id;
   CLOSE csr_reason_rma_trx_type;

   IF x_order_type_id IS NULL THEN
      OPEN csr_claim_type_rma_trx_type(p_claim_type_id);
      FETCH csr_claim_type_rma_trx_type INTO x_order_type_id;
      CLOSE csr_claim_type_rma_trx_type;
   END IF;

   IF x_order_type_id IS NULL THEN
      OPEN csr_sys_param_rma_trx_type(p_set_of_books_id);
      FETCH csr_sys_param_rma_trx_type INTO x_order_type_id;
      CLOSE csr_sys_param_rma_trx_type;
   END IF;

   IF x_order_type_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_MISSING_RMA_TRX_TYPE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Get_Default_Order_Type;


/*=======================================================================*
 | PROCEDURE
 |    Default_Claim_Line
 |
 | NOTES
 |    This API default claim line recored for RMA settlement method.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Default_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_rec      IN  OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Default_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);
/*
CURSOR csr_claim(p_claim_id IN NUMBER) IS
  SELECT cust_account_id
  ,      currency_code
  FROM ozf_claims
  WHERE claim_id = p_claim_id;

l_cust_account_id       NUMBER;
l_claim_currency        VARCHAR2(15);
l_price_list_id         NUMBER := 1000;
l_line_item_tbl         claim_line_item_tbl_type;
*/
l_claim_line_tbl        OZF_CLAIM_LINE_PVT.claim_line_tbl_type;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   l_claim_line_tbl(1) := p_x_claim_line_rec;

   Default_Claim_Line_Tbl(
       p_api_version           => l_api_version
      ,p_init_msg_list         => FND_API.g_false
      ,p_validation_level      => FND_API.g_valid_level_full
      ,x_return_status         => l_return_status
      ,x_msg_data              => x_msg_data
      ,x_msg_count             => x_msg_count
      ,p_x_claim_line_tbl      => l_claim_line_tbl
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

/*
   IF p_x_claim_line_rec.source_object_line_id IS NOT NULL AND
         p_x_claim_line_rec.source_object_class = 'INVOICE' THEN
      l_line_item_tbl(1).source_object_class := p_x_claim_line_rec.source_object_class;
      l_line_item_tbl(1).source_object_id := p_x_claim_line_rec.source_object_id;
      l_line_item_tbl(1).source_object_line_id := p_x_claim_line_rec.source_object_line_id;

      Price_Invoice_Line(
          x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count
         ,p_x_inv_line_tbl        => l_line_item_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_x_claim_line_rec.item_id IS NOT NULL THEN
      l_line_item_tbl(1).claim_line_index := 1;
      l_line_item_tbl(1).item_id := p_x_claim_line_rec.item_id;
      l_line_item_tbl(1).quantity := p_x_claim_line_rec.quantity;
      l_line_item_tbl(1).quantity_uom := p_x_claim_line_rec.quantity_uom;
      l_line_item_tbl(1).currency_code := p_x_claim_line_rec.currency_code;

      OPEN csr_claim(p_x_claim_line_rec.claim_id);
      FETCH csr_claim INTO l_cust_account_id, l_claim_currency;
      CLOSE csr_claim;

      Price_Item(
          p_cust_account_id       => l_cust_account_id
         ,p_price_list_id         => l_price_list_id
         ,p_currency_code         => l_claim_currency
         ,x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count

         ,p_x_item_tbl            => l_line_item_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF;
*/
   IF l_claim_line_tbl(1).rate IS NOT NULL THEN
      p_x_claim_line_rec.rate := l_claim_line_tbl(1).rate;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Default_Claim_Line;


/*=======================================================================*
 | PROCEDURE
 |    Default_Claim_Line_Tbl
 |
 | NOTES
 |    This API default claim line table for RMA settlement method.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Default_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_tbl      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_tbl_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Default_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_claim(p_claim_id IN NUMBER) IS
  SELECT cust_account_id
  ,      order_type_id
  ,      currency_code
  FROM ozf_claims
  WHERE claim_id = p_claim_id;

CURSOR csr_product_name(cv_item_id IN NUMBER, cv_org_id IN NUMBER) IS
  SELECT description
  FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_item_id
  AND organization_id = cv_org_id;

CURSOR csr_line_old_rate(cv_claim_line_id IN NUMBER) IS
  SELECT rate
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

l_csr_product_name      csr_product_name%ROWTYPE;
l_cust_account_id       NUMBER;
l_order_type_id         NUMBER;
l_claim_currency        VARCHAR2(15);
--l_price_list_id         NUMBER      := 1000;
l_item_tbl              claim_line_item_tbl_type;
l_inv_line_tbl          claim_line_item_tbl_type;
l_ord_line_tbl          claim_line_item_tbl_type;
i                       NUMBER;
idx_item                NUMBER       := 1;
idx_inv_line            NUMBER       := 1;
idx_ord_line            NUMBER       := 1;
l_org_id                NUMBER;
l_line_old_rate         NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   --l_org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));

   ----------------------------
   -- Default RMA Line Price --
   ----------------------------
   i := p_x_claim_line_tbl.FIRST;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' p_x_claim_line_tbl.FIRST='||i);
   END IF;

   IF i IS NOT NULL THEN
      OPEN csr_claim(p_x_claim_line_tbl(1).claim_id);
      FETCH csr_claim INTO l_cust_account_id
                         , l_order_type_id
                         , l_claim_currency;
      CLOSE csr_claim;

      LOOP
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message(l_full_name||' : p_x_claim_line_tbl('||i||').source_object_class='||p_x_claim_line_tbl(i).source_object_class);
            OZF_Utility_PVT.debug_message(l_full_name||' : p_x_claim_line_tbl('||i||').source_object_id='||p_x_claim_line_tbl(i).source_object_id);
            OZF_Utility_PVT.debug_message(l_full_name||' : p_x_claim_line_tbl('||i||').source_object_line_id='||p_x_claim_line_tbl(i).source_object_line_id);
            OZF_Utility_PVT.debug_message(l_full_name||' : p_x_claim_line_tbl('||i||').item_type='||p_x_claim_line_tbl(i).item_type);
            OZF_Utility_PVT.debug_message(l_full_name||' : p_x_claim_line_tbl('||i||').item_id='||p_x_claim_line_tbl(i).item_id);
         END IF;
         IF ( p_x_claim_line_tbl(i).source_object_line_id IS NOT NULL AND
              p_x_claim_line_tbl(i).source_object_line_id <> FND_API.g_miss_num
            ) OR
            ( p_x_claim_line_tbl(i).item_type = 'PRODUCT' AND
              p_x_claim_line_tbl(i).item_id IS NOT NULL AND
              p_x_claim_line_tbl(i).item_id <> FND_API.g_miss_num AND
              p_x_claim_line_tbl(i).rate IS NULL
            ) THEN
             -- Quantity is required for pricing item
             IF p_x_claim_line_tbl(i).quantity IS NULL THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_QUANTITY_REQ');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
             END IF;

            IF p_x_claim_line_tbl(i).source_object_line_id IS NOT NULL AND
               p_x_claim_line_tbl(i).source_object_line_id <> FND_API.g_miss_num AND
               p_x_claim_line_tbl(i).rate IS NOT NULL THEN
               IF p_x_claim_line_tbl(i).source_object_class = 'INVOICE' THEN
                  l_inv_line_tbl(idx_inv_line).claim_line_index := i;
                  l_inv_line_tbl(idx_inv_line).source_object_class := p_x_claim_line_tbl(i).source_object_class;
                  l_inv_line_tbl(idx_inv_line).source_object_id := p_x_claim_line_tbl(i).source_object_id;
                  l_inv_line_tbl(idx_inv_line).source_object_line_id := p_x_claim_line_tbl(i).source_object_line_id;
                  idx_inv_line := idx_inv_line + 1;
               ELSIF p_x_claim_line_tbl(i).source_object_class = 'ORDER' THEN
                  l_ord_line_tbl(idx_ord_line).claim_line_index := i;
                  l_ord_line_tbl(idx_ord_line).source_object_class := p_x_claim_line_tbl(i).source_object_class;
                  l_ord_line_tbl(idx_ord_line).source_object_id := p_x_claim_line_tbl(i).source_object_id;
                  l_ord_line_tbl(idx_ord_line).source_object_line_id := p_x_claim_line_tbl(i).source_object_line_id;
                  idx_ord_line := idx_ord_line + 1;
               END IF;
            ELSIF p_x_claim_line_tbl(i).item_type = 'PRODUCT' AND
                  p_x_claim_line_tbl(i).item_id IS NOT NULL AND
                  p_x_claim_line_tbl(i).item_id <> FND_API.g_miss_num AND
                  p_x_claim_line_tbl(i).rate IS NULL THEN
               l_item_tbl(idx_item).claim_line_index := i;
               l_item_tbl(idx_item).item_id := p_x_claim_line_tbl(i).item_id;
               l_item_tbl(idx_item).quantity := p_x_claim_line_tbl(i).quantity;
               -- UOM is required for pricing item
               IF p_x_claim_line_tbl(i).quantity_uom IS NULL THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                     l_org_id := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
                     OPEN csr_product_name(p_x_claim_line_tbl(i).item_id, l_org_id);
                     --OPEN csr_product_name(p_x_claim_line_tbl(i).item_id, l_org_id);
                     FETCH csr_product_name INTO l_csr_product_name;
                     CLOSE csr_product_name;
                     FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_UOM_REQ');
                     FND_MESSAGE.set_token('ITEM', l_csr_product_name.description);
                     FND_MSG_PUB.add;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  l_item_tbl(idx_item).quantity_uom := p_x_claim_line_tbl(i).quantity_uom;
               END IF;
               l_item_tbl(idx_item).currency_code := l_claim_currency;
               idx_item := idx_item + 1;
            END IF;
         ELSIF p_x_claim_line_tbl(i).rate IS NOT NULL AND
               p_x_claim_line_tbl(i).rate <> FND_API.g_miss_num THEN
            -- create mode
            IF p_x_claim_line_tbl(i).claim_line_id IS NULL OR
               p_x_claim_line_tbl(i).claim_line_id = FND_API.g_miss_num THEN
               p_x_claim_line_tbl(i).payment_status := 'N'; --set calculate_price_flag

            -- update mode
            ELSE
               IF p_x_claim_line_tbl(i).payment_status = 'Y' THEN
                  OPEN csr_line_old_rate(p_x_claim_line_tbl(i).claim_line_id);
                  FETCH csr_line_old_rate INTO l_line_old_rate;
                  CLOSE csr_line_old_rate;
                  IF p_x_claim_line_tbl(i).rate <> l_line_old_rate THEN
                     p_x_claim_line_tbl(i).payment_status := 'N';
                  END IF;
               END IF;
            END IF;
         END IF;
         EXIT WHEN i = p_x_claim_line_tbl.LAST;
         i := p_x_claim_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : count-inv line tbl='||l_inv_line_tbl.COUNT);
      OZF_Utility_PVT.debug_message(l_full_name||' : count-ord line tbl='||l_ord_line_tbl.COUNT);
      OZF_Utility_PVT.debug_message(l_full_name||' : count-prd line tbl='||l_item_tbl.COUNT);
   END IF;

   ------ Price Item -------
   i := l_item_tbl.FIRST;
   IF i IS NOT NULL THEN
      Price_Item(
          p_cust_account_id       => l_cust_account_id
         ,p_order_type_id         => l_order_type_id
         --,p_price_list_id         => l_price_list_id
         ,p_currency_code         => l_claim_currency

         ,x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count

         ,p_x_item_tbl            => l_item_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      LOOP
         p_x_claim_line_tbl(l_item_tbl(i).claim_line_index).rate := l_item_tbl(i).rate;
         p_x_claim_line_tbl(l_item_tbl(i).claim_line_index).payment_status := 'Y'; -- calculate_price_flag
         EXIT WHEN i = l_item_tbl.LAST;
         i := l_item_tbl.NEXT(i);
      END LOOP;
   END IF;

   ------ Price Invoice Line -------
   i := l_inv_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      Price_Invoice_Line(
          x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count
         ,p_x_inv_line_tbl        => l_inv_line_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      LOOP
         p_x_claim_line_tbl(l_inv_line_tbl(i).claim_line_index).item_id := l_inv_line_tbl(i).item_id;
         p_x_claim_line_tbl(l_inv_line_tbl(i).claim_line_index).rate := l_inv_line_tbl(i).rate;
         p_x_claim_line_tbl(l_inv_line_tbl(i).claim_line_index).quantity_uom := l_inv_line_tbl(i).quantity_uom;
         p_x_claim_line_tbl(l_inv_line_tbl(i).claim_line_index).payment_status := 'Y'; -- calculate_price_flag
         EXIT WHEN i = l_inv_line_tbl.LAST;
         i := l_inv_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   ------ Price Order Line -------
   i := l_ord_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      Price_Order_Line(
          x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count
         ,p_x_ord_line_tbl        => l_ord_line_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      LOOP
         p_x_claim_line_tbl(l_ord_line_tbl(i).claim_line_index).item_id := l_ord_line_tbl(i).item_id;
         p_x_claim_line_tbl(l_ord_line_tbl(i).claim_line_index).rate := l_ord_line_tbl(i).rate;
         p_x_claim_line_tbl(l_ord_line_tbl(i).claim_line_index).quantity_uom := l_ord_line_tbl(i).quantity_uom;
         p_x_claim_line_tbl(l_ord_line_tbl(i).claim_line_index).payment_status := 'Y'; -- calculate_price_flag
         EXIT WHEN i = l_ord_line_tbl.LAST;
         i := l_ord_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Default_Claim_Line_Tbl;


/*=======================================================================*
 | PROCEDURE
 |    Validate_Claim_Line
 |
 | NOTES
 |    This API validate claim line recored against RMA settlement.
 |
 | HISTORY
 |    30-JUL-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Validate_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_rec        IN  OZF_CLAIM_LINE_PVT.claim_line_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;


l_error                 BOOLEAN   := FALSE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Validate_Claim_Line;


/*=======================================================================*
 | PROCEDURE
 |    Validate_Claim_Line_Tbl
 |
 | NOTES
 |    This API validate claim line table against RMA settlement.
 |
 | HISTORY
 |    30-JUL-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Validate_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_tbl        IN  OZF_CLAIM_LINE_PVT.claim_line_tbl_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

i                       NUMBER;
l_error                 BOOLEAN   := FALSE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- Start -----------------------
   i := p_claim_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF p_claim_line_tbl(i).claim_line_id IS NOT NULL THEN
            Validate_Claim_Line(
                p_api_version        => l_api_version
               ,p_init_msg_list      => FND_API.g_false
               ,p_validation_level   => FND_API.g_valid_level_full
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
               ,p_claim_line_rec     => p_claim_line_tbl(i)
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;
         EXIT WHEN i = p_claim_line_tbl.LAST;
         i := p_claim_line_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Validate_Claim_Line_Tbl;

-- kishore
-- Fix for bug 4565361
/*=======================================================================*
 | Procedure
 |    Validate_reference_information
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    15-DEC-2005  kdhulipa  Created.
 |    17-Jan-2006  kdhulipa  Fix for bug 4565507
 *=======================================================================*/
PROCEDURE Validate_reference_information(
    x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER
   ,p_source_object_id       IN    NUMBER
   ,p_source_object_line_id  IN    NUMBER
   ,p_source_object_class    IN    VARCHAR2
   ,p_quantity               IN    NUMBER
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_reference_information';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

CURSOR csr_order_reference(cv_customer_trx_id IN NUMBER) IS
   SELECT interface_header_context
   FROM ra_customer_trx_all
   WHERE customer_trx_id = cv_customer_trx_id;

CURSOR csr_ord_total_quantity(cv_header_id IN NUMBER) IS
  SELECT ordered_quantity
  FROM oe_order_lines_all
  WHERE header_id = cv_header_id;

CURSOR csr_ord_return_quantity(cv_header_id IN NUMBER, cv_line_id NUMBER) IS
   SELECT   sum(nvl(ordered_quantity, 0))
   FROM   oe_order_lines_all
   WHERE  reference_header_id = cv_header_id
   AND reference_line_id = cv_line_id
   AND    booked_flag = 'Y'
   AND    cancelled_flag <> 'Y'
   AND    line_category_code = 'RETURN';

CURSOR csr_inv_ord_number(cv_cust_id IN NUMBER) IS
  SELECT interface_header_attribute1
  FROM ra_customer_trx_all
  WHERE customer_trx_id =  cv_cust_id;

CURSOR csr_inv_header_id(cv_customer_trx IN NUMBER) IS
  SELECT header_id
  FROM oe_order_headers_all
  WHERE order_number = cv_customer_trx;

CURSOR csr_inv_line_id(cv_line_id IN NUMBER) IS
  SELECT interface_line_attribute6
  FROM ra_customer_trx_lines_all
  WHERE customer_trx_line_id =  cv_line_id;

l_reference_header  varchar(20);
l_total_order_quantity NUMBER;
l_return_order_quantity NUMBER;
l_inv_order_number NUMBER;
l_inv_header_id  NUMBER;
l_inv_line_id  NUMBER;

BEGIN

  IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- check whether invoice is generated from ORDER or not.
   IF p_source_object_class = 'INVOICE' THEN
      OPEN csr_order_reference(p_source_object_id);
      FETCH csr_order_reference INTO l_reference_header;
      CLOSE csr_order_reference;
      IF nvl(l_reference_header, 'OZF_DUMMY') <> 'ORDER ENTRY' THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_INVOICE_ORDER_ERROR');
              FND_MSG_PUB.Add;
   	      END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;


   -- BUG 4565507 Begin
   IF p_source_object_class = 'ORDER' THEN

       OPEN csr_ord_return_quantity(p_source_object_id, p_source_object_line_id);
       FETCH csr_ord_return_quantity INTO l_return_order_quantity;
       CLOSE csr_ord_return_quantity;

       OPEN csr_ord_total_quantity(p_source_object_id);
       FETCH csr_ord_total_quantity into l_total_order_quantity;
       CLOSE csr_ord_total_quantity;

       IF l_return_order_quantity IS NOT NULL THEN
          IF ( (p_quantity + l_return_order_quantity ) > l_total_order_quantity ) THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('OZF','OZF_RETURN_INVALID_QUANTITY');
                FND_MSG_PUB.Add;
             END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
   END IF;

   IF p_source_object_class = 'INVOICE' THEN

     -- to find the order number
     OPEN csr_inv_ord_number(p_source_object_id);
     FETCH csr_inv_ord_number INTO l_inv_order_number;
     CLOSE csr_inv_ord_number;

     -- to find header id
     OPEN csr_inv_header_id(l_inv_order_number);
     FETCH csr_inv_header_id INTO l_inv_header_id;
     CLOSE csr_inv_header_id;

     -- to find the line id
     OPEN csr_inv_line_id(p_source_object_line_id);
     FETCH csr_inv_line_id INTO l_inv_line_id;
     CLOSE csr_inv_line_id;

     OPEN csr_ord_return_quantity(l_inv_header_id, l_inv_line_id);
     FETCH csr_ord_return_quantity INTO l_return_order_quantity;
     CLOSE csr_ord_return_quantity;

     OPEN csr_ord_total_quantity(l_inv_header_id);
     FETCH csr_ord_total_quantity into l_total_order_quantity;
     CLOSE csr_ord_total_quantity;

     IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message(' Order Number  '|| l_inv_order_number);
         OZF_Utility_PVT.debug_message(' Return Order Quantity  '|| l_return_order_quantity);
         OZF_Utility_PVT.debug_message(' Total quantity  '|| l_total_order_quantity);
     END IF;

     IF l_return_order_quantity IS NOT NULL THEN
         IF ( (p_quantity + l_return_order_quantity ) > l_total_order_quantity ) THEN
            IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('OZF','OZF_RETURN_INVALID_QUANTITY');
              FND_MSG_PUB.Add;
   	        END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;

   END IF;

   -- BUG 4565507 END


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;
END Validate_reference_information;


/*=======================================================================*
 | Procedure
 |    Validate_Return_Quantity
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    13-DEC-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Validate_Return_Quantity(
    x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_line_rec         IN    OZF_CLAIM_LINE_PVT.claim_line_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Return_Quantity';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_inv_line_quantity(cv_invoice_line_id IN NUMBER) IS
  SELECT quantity_invoiced
  ,      inventory_item_id
  FROM ra_customer_trx_lines
  WHERE customer_trx_line_id = cv_invoice_line_id;

CURSOR csr_ord_line_quantity(cv_order_line_id IN NUMBER) IS
  SELECT ordered_quantity
  ,      inventory_item_id
  FROM oe_order_lines
  WHERE line_id = cv_order_line_id;

CURSOR csr_product_name(cv_item_id IN NUMBER, cv_org_id IN NUMBER) IS
  SELECT description
  FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_item_id
  AND organization_id = cv_org_id;

i                       NUMBER;
l_most_quantity         NUMBER;
l_item_id               NUMBER;
l_csr_product_name      csr_product_name%ROWTYPE;
l_org_id                NUMBER;
l_error                 BOOLEAN   := FALSE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   -- Checking Reference information -----
   -- kishore.

   IF p_claim_line_rec.source_object_class IN ('INVOICE', 'ORDER') AND
      p_claim_line_rec.source_object_id IS NOT NULL AND
      p_claim_line_rec.source_object_line_id IS NOT NULL THEN

      Validate_reference_information(
                  x_return_status        => l_return_status
                 ,x_msg_data             => x_msg_data
                 ,x_msg_count            => x_msg_count
                 ,p_source_object_id     => p_claim_line_rec.source_object_id
                 ,p_source_object_line_id => p_claim_line_rec.source_object_line_id
                 ,p_source_object_class   => p_claim_line_rec.source_object_class
                 ,p_quantity              => p_claim_line_rec.quantity
             );

      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

    END IF;

   ----------------------- Start -----------------------
   IF p_claim_line_rec.source_object_class IN ('INVOICE', 'ORDER') AND
      p_claim_line_rec.source_object_id IS NOT NULL AND
      p_claim_line_rec.source_object_line_id IS NOT NULL THEN
      ------- INVOICE -------
      IF p_claim_line_rec.source_object_class = 'INVOICE' THEN
         OPEN csr_inv_line_quantity(p_claim_line_rec.source_object_line_id);
         FETCH csr_inv_line_quantity INTO l_most_quantity, l_item_id;
         CLOSE csr_inv_line_quantity;
      ------- ORDER -------
      ELSIF p_claim_line_rec.source_object_class = 'ORDER' THEN
         OPEN csr_ord_line_quantity(p_claim_line_rec.source_object_line_id);
         FETCH csr_ord_line_quantity INTO l_most_quantity, l_item_id;
         CLOSE csr_ord_line_quantity;
      END IF;

      -- If both product and invoice/order line are defined,
      -- the product needs to belong to the same invoice/order line.
      IF p_claim_line_rec.item_id IS NOT NULL AND
         p_claim_line_rec.item_id <> l_item_id THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            l_org_id := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
            OPEN csr_product_name(p_claim_line_rec.item_id, l_org_id);
--            OPEN csr_product_name(p_claim_line_rec.item_id, l_org_id);
            FETCH csr_product_name INTO l_csr_product_name;
            CLOSE csr_product_name;
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_PROD_ERR');
            FND_MESSAGE.set_token('PROD', l_csr_product_name.description);
            FND_MSG_PUB.add;
         END IF;
         l_error := TRUE;
      END IF;

      IF p_claim_line_rec.quantity > l_most_quantity THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_RMA_QUTY_ERR');
            FND_MSG_PUB.add;
         END IF;
         l_error := TRUE;
      END IF;
   END IF;

   IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Validate_Return_Quantity;

/*=======================================================================*
 | Procedure
 |    Check_RMA_Item_Attribute
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    13-DEC-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Check_RMA_Item_Attribute(
    x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_item_id                IN    NUMBER
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Check_RMA_Item_Attribute';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

CURSOR csr_item_attr(cv_item_id IN NUMBER, cv_org_id IN NUMBER) IS
  SELECT invoice_enabled_flag
  ,      invoiceable_item_flag
  ,      returnable_flag
  ,      description
  FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_item_id
  AND organization_id = cv_org_id;

l_csr_item_attr         csr_item_attr%ROWTYPE;
l_org_id                NUMBER;
l_error                 BOOLEAN   := FALSE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

--   l_org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));
   l_org_id := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');

   OPEN csr_item_attr(p_item_id, l_org_id);
   FETCH csr_item_attr INTO l_csr_item_attr;
   CLOSE csr_item_attr;

   IF l_csr_item_attr.invoice_enabled_flag = 'N' OR
      l_csr_item_attr.invoiceable_item_flag = 'N' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_RMA_INV_ERR');
         FND_MESSAGE.set_token('PROD', l_csr_item_attr.description);
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   IF l_csr_item_attr.returnable_flag <> 'Y' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_ITEM_RMA_ERR');
         FND_MESSAGE.set_token('PROD', l_csr_item_attr.description);
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Check_RMA_Item_Attribute;


/*=======================================================================*
 | Procedure
 |    Check_RMA_Line_Items
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    13-DEC-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Check_RMA_Line_Items(
    x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_claim_line_rec         IN    OZF_CLAIM_LINE_PVT.claim_line_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Check_RMA_Line_Items';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_error                 BOOLEAN      := FALSE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   -- 1. invoice line or product is required
   IF (p_claim_line_rec.item_id IS NULL OR p_claim_line_rec.item_type <> 'PRODUCT') AND
      p_claim_line_rec.source_object_line_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_PROD_ERR');
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   -- 2. quantity is required
   IF p_claim_line_rec.quantity IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_QUANTITY_ERR');
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   -- 3. uom is required
   IF p_claim_line_rec.quantity_uom IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_UOM_ERR');
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   -- 4. price is required
   IF p_claim_line_rec.rate IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OM_RATE_ERR');
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   -- 5. Pay Related Customer is not applicable if RMA is with referenced order/line
   IF p_claim_line_rec.source_object_class IN ('INVOICE', 'ORDER') AND
      p_claim_line_rec.source_object_line_id IS NOT NULL AND
      p_claim_rec.pay_related_account_flag = 'T' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_RMA_REL_CUST_NA');
         FND_MSG_PUB.add;
      END IF;
      l_error := TRUE;
   END IF;

   IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Check_RMA_Line_Items;


/*=======================================================================*
 | Procedure
 |    Complete_RMA_Validation
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Complete_RMA_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT   NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_RMA_Validation';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

i                       NUMBER;
l_claim_line_tbl        OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_claim_line_rec        OZF_CLAIM_LINE_PVT.claim_line_rec_type;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

   ----------------------- Start -----------------------
   OZF_OM_PAYMENT_PVT.Query_Claim_Line(
       p_claim_id           => p_claim_rec.claim_id
      ,x_claim_line_tbl     => l_claim_line_tbl
      ,x_return_status      => l_return_status
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   i := l_claim_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF l_claim_line_tbl(i).claim_line_id IS NOT NULL THEN
            l_claim_line_rec := l_claim_line_tbl(i);

            -------------------------------
            -- RMA Line Items Validation --
            -------------------------------
            Check_RMA_Line_Items(
                x_return_status         => l_return_status
               ,x_msg_data              => x_msg_data
               ,x_msg_count             => x_msg_count
               ,p_claim_rec             => p_claim_rec
               ,p_claim_line_rec        => l_claim_line_rec
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            -------------------------------------
            -- RMA Items Attributes Validation --
            -------------------------------------
            Check_RMA_Item_Attribute(
                x_return_status         => l_return_status
               ,x_msg_data              => x_msg_data
               ,x_msg_count             => x_msg_count
               ,p_item_id               => l_claim_line_rec.item_id
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            --------------------------------
            -- Return Quantity Validation --
            --------------------------------
            Validate_Return_Quantity(
                x_return_status        => l_return_status
               ,x_msg_data             => x_msg_data
               ,x_msg_count            => x_msg_count
               ,p_claim_line_rec       => l_claim_line_rec
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         END IF;
         EXIT WHEN i = l_claim_line_tbl.LAST;
         i := l_claim_line_tbl.NEXT(i);
      END LOOP;
   END IF;


   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Complete_RMA_Validation;



END OZF_OM_VALIDATION_PVT;

/
