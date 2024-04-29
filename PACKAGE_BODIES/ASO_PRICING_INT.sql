--------------------------------------------------------
--  DDL for Package Body ASO_PRICING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICING_INT" AS
/* $Header: asoiprcb.pls 120.6.12010000.2 2011/09/16 07:07:27 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PRICING_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiprcb.pls';


FUNCTION Set_Global_Rec (
p_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN PRICING_HEADER_REC_TYPE
IS
BEGIN

return ASO_PRICING_CORE_PVT.Set_Global_Rec(p_qte_header_rec => p_qte_header_rec,
                                           p_shipment_rec => p_shipment_rec);
END Set_Global_Rec;

FUNCTION Set_Global_Rec (
  p_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type,
  p_qte_line_dtl_rec    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
  p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN PRICING_LINE_REC_TYPE
IS
BEGIN

return ASO_PRICING_CORE_PVT.Set_Global_Rec(p_qte_line_rec => p_qte_line_rec,
								   p_qte_line_dtl_rec => p_qte_line_dtl_rec,
								   p_shipment_rec => p_shipment_rec);
END Set_Global_Rec;

-- kchervel start
FUNCTION Get_Cust_Acct (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_cust_account_id NUMBER;
BEGIN

   SELECT cust_account_id
   INTO x_cust_account_id
   FROM aso_quote_headers_all
   WHERE quote_header_id = p_quote_header_id;

   IF (SQL%NOTFOUND) THEN
       null;
       x_cust_account_id := null;
   END IF;

   return  x_cust_account_id;

END Get_Cust_Acct;

-- the following four APIs actually create the site use if needed
-- this should be changed in the party int

FUNCTION Get_Ship_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_ship_to_org_id      NUMBER := NULL;
l_cust_account_id     NUMBER;
l_ship_party_site_id  NUMBER;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            NUMBER;
l_ship_to_cust_account_id            NUMBER;

CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
  SELECT qh.cust_account_id, qs.ship_to_party_site_id,qs.ship_to_cust_account_id
  FROM aso_quote_headers_all qh, aso_shipments qs
  WHERE qh.quote_header_id = qs.quote_header_id
  AND qh.quote_header_id = l_quote_header_id
  AND qs.quote_line_id is NULL;

BEGIN

    OPEN C_get_quote_info(p_quote_header_id);
    FETCH C_get_quote_info INTO l_cust_account_id, l_ship_party_site_id,l_ship_to_cust_account_id;
    IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_to_org_id;
    END IF;
    CLOSE C_get_quote_info;

   if l_ship_to_cust_account_id is not null OR l_ship_to_cust_account_id <>  fnd_api.G_MISS_NUM then
     l_cust_account_id := l_ship_to_cust_account_id;
   end if;

   IF l_cust_account_id is not NULL
      AND l_ship_party_site_id is not NULL THEN
      ASO_PARTY_INT.GET_ACCT_SITE_USES (
           p_api_version     => 1.0
          ,P_Cust_Account_Id => l_cust_account_id
          ,P_Party_Site_Id   => l_ship_party_site_id
          ,P_Acct_Site_type  => 'SHIP_TO'
          ,x_return_status   => l_return_status
          ,x_msg_count       => l_msg_count
          ,x_msg_data        => l_msg_data
          ,x_site_use_id     => x_ship_to_org_id
         );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_ship_to_org_id := NULL;
      END IF;

   END IF;  -- not null

  return x_ship_to_org_id;

END Get_Ship_to_Site_Use;

FUNCTION Get_Line_Ship_to_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER
IS
x_ship_to_org_id             NUMBER := NULL;
l_cust_account_id            NUMBER;
l_ship_party_site_id         NUMBER;
l_return_status              VARCHAR2(1);
l_msg_count                  NUMBER;
l_msg_data                   NUMBER;
l_ship_to_cust_account_id    NUMBER;

CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qh.cust_account_id, qs.ship_to_party_site_id,qs.ship_to_cust_account_id
   FROM aso_quote_headers_all qh,
        aso_shipments qs,
        aso_quote_lines_all ql
   WHERE qh.quote_header_id = qs.quote_header_id
   AND ql.quote_header_id = qh.quote_header_id
   AND ql.quote_line_id = l_quote_line_id
   AND ql.quote_line_id = qs.quote_line_id;

BEGIN

     OPEN C_get_quote_info(p_quote_line_id);
     FETCH C_get_quote_info INTO l_cust_account_id, l_ship_party_site_id,l_ship_to_cust_account_id;
     IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_to_org_id;
     END IF;
     CLOSE C_get_quote_info;

     if l_ship_to_cust_account_id is not null
        OR l_ship_to_cust_account_id <>  fnd_api.G_MISS_NUM then
          l_cust_account_id := l_ship_to_cust_account_id;
     end if;

     IF l_cust_account_id is not NULL
       AND l_ship_party_site_id is not NULL THEN
      ASO_PARTY_INT.GET_ACCT_SITE_USES (
           p_api_version     => 1.0
          ,P_Cust_Account_Id => l_cust_account_id
          ,P_Party_Site_Id   => l_ship_party_site_id
          ,P_Acct_Site_type  => 'SHIP_TO'
          ,x_return_status   => l_return_status
          ,x_msg_count       => l_msg_count
          ,x_msg_data        => l_msg_data
          ,x_site_use_id     => x_ship_to_org_id
         );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_ship_to_org_id := NULL;
    END IF;

    END IF;  -- not null

    return x_ship_to_org_id;

END Get_Line_Ship_to_Site_Use;


FUNCTION Get_Invoice_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_invoice_to_org_id                     NUMBER := NULL;
l_cust_account_id                       NUMBER;
l_invoice_party_site_id                 NUMBER;
l_return_status                         VARCHAR2(1);
l_msg_count                             NUMBER;
l_msg_data                              NUMBER;
l_invoice_to_cust_account_id            NUMBER;

CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
     SELECT cust_account_id,
            invoice_to_party_site_id,
            invoice_to_cust_account_id
     FROM aso_quote_headers_all
     WHERE quote_header_id = l_quote_header_id;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO
            l_cust_account_id,
            l_invoice_party_site_id,
            l_invoice_to_cust_account_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_to_org_id;
      END IF;
      CLOSE C_get_quote_info;

     if l_invoice_to_cust_account_id is not null
        OR l_invoice_to_cust_account_id <>  fnd_api.G_MISS_NUM then
        l_cust_account_id := l_invoice_to_cust_account_id;
    end if;

    IF l_cust_account_id is not NULL
       AND l_invoice_party_site_id is not NULL THEN
      ASO_PARTY_INT.GET_ACCT_SITE_USES (
           p_api_version     => 1.0
          ,P_Cust_Account_Id => l_cust_account_id
          ,P_Party_Site_Id   => l_invoice_party_site_id
          ,P_Acct_Site_type  => 'BILL_TO'
          ,x_return_status   => l_return_status
          ,x_msg_count       => l_msg_count
          ,x_msg_data        => l_msg_data
          ,x_site_use_id     => x_invoice_to_org_id
         );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_invoice_to_org_id := NULL;
   END IF;

   END IF;  -- not null

   return x_invoice_to_org_id;

END Get_Invoice_to_Site_Use;


FUNCTION Get_Line_Invoice_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER
IS
x_invoice_to_org_id                     NUMBER := NULL;
l_cust_account_id                       NUMBER;
l_invoice_party_site_id                 NUMBER;
l_return_status                         VARCHAR2(1);
l_msg_count                             NUMBER;
l_msg_data                              NUMBER;
l_invoice_to_cust_account_id            NUMBER;

CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qh.cust_account_id,
          ql.invoice_to_party_site_id,
          ql.invoice_to_cust_account_id
  FROM    aso_quote_headers_all qh, aso_quote_lines_all ql
  WHERE   ql.quote_line_id = l_quote_line_id
  AND     ql.quote_header_id = qh.quote_header_id;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info
      INTO l_cust_account_id,l_invoice_party_site_id,l_invoice_to_cust_account_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_to_org_id;
      END IF;
      CLOSE C_get_quote_info;

     if l_invoice_to_cust_account_id is not null
        OR l_invoice_to_cust_account_id <>  fnd_api.G_MISS_NUM then
           l_cust_account_id := l_invoice_to_cust_account_id;
     end if;

     IF l_cust_account_id is not NULL
         AND l_invoice_party_site_id is not NULL THEN
         ASO_PARTY_INT.GET_ACCT_SITE_USES (
           p_api_version        => 1.0
          ,P_Cust_Account_Id    => l_cust_account_id
          ,P_Party_Site_Id      => l_invoice_party_site_id
          ,P_Acct_Site_type     => 'BILL_TO'
          ,x_return_status      => l_return_status
          ,x_msg_count          => l_msg_count
          ,x_msg_data           => l_msg_data
          ,x_site_use_id        => x_invoice_to_org_id
         );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_invoice_to_org_id := NULL;
       END IF;

   END IF;  -- not null

   return x_invoice_to_org_id;

END Get_Line_Invoice_Site_Use;


FUNCTION Get_Ship_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER
IS
   CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT qs.ship_to_party_site_id
   FROM aso_shipments qs
   WHERE qs.quote_header_id = l_quote_header_id
   AND qs.quote_line_id IS NULL;

   x_ship_party_site_id NUMBER := NULL;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO x_ship_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_ship_party_site_id;
END  Get_Ship_to_Party_Site;



FUNCTION Get_Line_Ship_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
  SELECT qs.ship_to_party_site_id
  FROM aso_shipments qs
  WHERE  qs.quote_line_id = l_quote_line_id;

x_ship_party_site_id NUMBER;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO x_ship_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_ship_party_site_id;
END  Get_Line_Ship_Party_Site;


FUNCTION Get_Invoice_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT qs.invoice_to_party_site_id
     FROM aso_quote_headers_all qs
     WHERE qs.quote_header_id = l_quote_header_id;

x_invoice_party_site_id NUMBER := NULL;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO x_invoice_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_invoice_party_site_id;
END  Get_Invoice_to_Party_Site;



FUNCTION Get_Line_Invoice_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qs.invoice_to_party_site_id
     FROM aso_quote_lines_all qs
     WHERE  qs.quote_line_id = l_quote_line_id;

xl_inv_party_site_id NUMBER;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO xl_inv_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return xl_inv_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return xl_inv_party_site_id;
END  Get_Line_Invoice_Party_Site;


-- wli_start
FUNCTION Get_Customer_Class(p_cust_account_id IN NUMBER)
RETURN VARCHAR2
IS
x_class_code VARCHAR2(240);
BEGIN

    SELECT customer_class_code
    INTO   x_class_code
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_cust_account_id;

    RETURN x_class_code;

END Get_Customer_Class;

FUNCTION Get_Account_Type (p_cust_account_id IN NUMBER)
RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

TYPE t_cursor IS REF CURSOR;

x_account_type_ids     QP_Attr_Mapping_PUB.t_MultiRecord;
l_account_type_id      VARCHAR2(30);
v_count            NUMBER := 1;
l_acct_type_cursor     t_cursor;
BEGIN

    OPEN l_acct_type_cursor FOR
    SELECT profile_class_id
    FROM   HZ_CUSTOMER_PROFILES
    WHERE  cust_account_id = p_cust_account_id;

    LOOP

    FETCH l_acct_type_cursor INTO l_account_type_id;
    EXIT WHEN l_acct_type_cursor%NOTFOUND;

    x_account_type_ids(v_count) := l_account_type_id;
    v_count := v_count + 1;

    END LOOP;

    CLOSE l_acct_type_cursor;

    RETURN x_account_type_ids;

END Get_Account_Type;

FUNCTION Get_Sales_Channel (p_cust_account_id IN NUMBER)
RETURN VARCHAR2
IS
x_sales_channel_code VARCHAR2(240);
BEGIN

    SELECT sales_channel_code
    INTO   x_sales_channel_code
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_cust_account_id;

    RETURN x_sales_channel_code;


END Get_Sales_Channel;


FUNCTION Get_GSA (p_cust_account_id NUMBER)
RETURN VARCHAR2
IS
x_gsa VARCHAR2(1);
BEGIN

    SELECT DECODE(PARTY.PARTY_TYPE, 'ORGANIZATION',PARTY.GSA_INDICATOR_FLAG,'N') gsa_indicator
    INTO   x_gsa
    FROM   hz_cust_accounts cust_acct, hz_parties party
    WHERE  cust_acct.cust_account_id  = p_cust_account_id
    and CUST_ACCT.PARTY_ID = PARTY.PARTY_ID;

    RETURN x_gsa;

END get_gsa;

-- Why do we need

FUNCTION Get_quote_Qty (p_qte_header_id IN NUMBER)
RETURN VARCHAR2
IS

x_quote_qty      VARCHAR2(30);
l_quote_qty      NUMBER;

BEGIN

  SELECT SUM(nvl(quantity,0))
  INTO    l_quote_qty
  FROM aso_quote_lines_all
  WHERE quote_header_id=p_qte_header_id
  AND (line_category_code<>'RETURN' OR line_category_code IS NULL)
  GROUP BY quote_header_id;


   IF (SQL%NOTFOUND) THEN
         l_quote_qty :=0;
   end if;

  x_quote_qty := FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_quote_qty, 0));
  RETURN x_quote_qty;

END Get_quote_Qty;


FUNCTION Get_quote_Amount(p_qte_header_id IN NUMBER) RETURN VARCHAR2
IS
x_quote_amount      VARCHAR2(30);
l_quote_amount      NUMBER;

BEGIN

  SELECT SUM((nvl(quantity,0))*(LINE_LIST_PRICE))
  INTO    l_quote_amount
  FROM aso_quote_lines_all
  WHERE quote_header_id=p_qte_header_id
  AND (line_category_code<>'RETURN' OR line_category_code IS NULL)
  AND charge_periodicity_code IS NULL
  GROUP BY quote_header_id;


  IF (SQL%NOTFOUND) THEN
     l_quote_amount :=0;
  END IF;

  x_quote_amount:=FND_NUMBER.NUMBER_TO_CANONICAL(NVL(l_quote_amount,0));
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_INT:In Get_quote_amount: x_quote_amount:'||x_quote_amount,1,'Y');
  END IF;
  RETURN x_quote_amount;

END Get_quote_Amount;

-- order context

FUNCTION Get_shippable_flag(p_qte_line_id NUMBER)
RETURN VARCHAR2
IS
x_shippable_item_flag VARCHAR2(1);
BEGIN

    SELECT shippable_item_flag
    INTO   x_shippable_item_flag
    FROM  aso_i_items_v i, aso_quote_lines_all l
    WHERE  l.quote_line_id = p_qte_line_id
    and l.inventory_item_id = i.inventory_item_id
    and l.organization_id = i.organization_id;

    RETURN x_shippable_item_flag;
END get_shippable_flag;

--wli_end
PROCEDURE Pricing_Item (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    p_control_rec                IN   PRICING_CONTROL_REC_TYPE,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_hd_shipment_rec            IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                      := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
    p_hd_price_attr_tbl          IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                      := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    p_qte_line_rec               IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_qte_line_dtl_rec           IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type
                                      := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Rec,
    p_ln_shipment_rec            IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                      := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
    p_ln_price_attr_tbl          IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                      := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    x_qte_line_tbl               OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    x_qte_line_dtl_tbl           OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    x_price_adj_tbl              OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    x_price_adj_attr_tbl         OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    x_price_adj_rltship_tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'Pricing_Item';
    l_api_version_number            CONSTANT NUMBER   := 1.0;
    l_request_type                  VARCHAR2(60);
    l_pricing_event                 VARCHAR2(30);
    l_control_rec                   QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
    l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_pricing_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_qual_contexts_Tbl             QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    lx_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
    lx_req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
    lx_req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    lx_req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    lx_req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    lx_req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    lx_req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_return_status                 VARCHAR2(1);
    l_return_status_text            VARCHAR2(2000);
    l_message_text                  VARCHAR2(2000);
    lx_req_line_rec                 QP_PREQ_GRP.LINE_REC_TYPE;
    lv_return_status                VARCHAR2(1);
    i                               BINARY_INTEGER;
    l_hd_pricing_contexts_Tbl       QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_hd_qual_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

    x_pass_line                   VARCHAR2(10);  -- bug 12988510

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT PRICING_ITEM_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_request_type := NVL(p_control_rec.request_type,'ASO');
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_INT:In Pricing Item: p_qte_header_rec.quote_status_id'
					  ||p_qte_header_rec.quote_status_id,1,'Y');
      END IF;
      -- Bug No 6510202. Header rec needs to be intialized since the header rec frozen date is passed
      -- to line rec price effective date which would be picked by pricing for selecting the correct price list
       ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
          	                              p_qte_header_rec    => p_qte_header_rec,
          	                              p_shipment_rec      => p_hd_shipment_rec);

      IF NVL(p_qte_header_rec.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
         l_pricing_event := 'BATCH'; --p_control_rec.pricing_event;
         -- commented for bug no 6510202
        /*   ASO_PRICING_INT.G_HEADER_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
          	                              p_qte_header_rec    => p_qte_header_rec,
          	                              p_shipment_rec      => p_hd_shipment_rec);
        */

--  bug 12988510, using overloaded funtion of build context which passes p_check_line_flag, p_pricing_event and returns x_pass_line
    	    QP_ATTR_MAPPING_PUB.Build_Contexts (
    	 	     P_REQUEST_TYPE_CODE           => l_request_type,
     		P_PRICING_TYPE                => 'H',
		p_check_line_flag                => 'N',
		p_pricing_event                    =>  l_pricing_event,
     		X_PRICE_CONTEXTS_RESULT_TBL   => l_hd_pricing_contexts_tbl,
     		X_QUAL_CONTEXTS_RESULT_TBL    => l_hd_qual_contexts_tbl,
		x_PASS_LINE                                              => x_pass_line);

    	   ASO_PRICING_CALLBACK_PVT.Copy_Attribs_To_Req (
     		p_line_index              => 1,
     		p_pricing_contexts_tbl    => l_hd_pricing_contexts_tbl,
     		p_qualifier_contexts_tbl  => l_hd_qual_contexts_tbl,
     		px_req_line_attr_tbl      => l_req_line_attr_tbl,
     		px_req_qual_tbl           => l_req_qual_tbl);

    	   ASO_PRICING_CALLBACK_PVT.Copy_Header_To_Request(
     		p_Request_Type      => l_request_type,
     		p_pricing_event     => l_pricing_event,
     		p_header_rec        => p_qte_header_rec,
     		px_req_line_tbl     => l_Req_line_tbl);

    	   ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec(
		   p_qte_line_rec		=> p_qte_line_rec,
	        p_qte_line_dtl_rec	=> p_qte_line_dtl_rec,
		   p_shipment_rec		=> p_ln_shipment_rec);

--  bug 12988510, using overloaded funtion of build context which passes p_check_line_flag, p_pricing_event and returns x_pass_line
	   QP_ATTR_MAPPING_PUB.Build_Contexts (
		P_REQUEST_TYPE_CODE	=> l_request_type,
		P_PRICING_TYPE		=> 'L',
		p_check_line_flag                => 'N',
		p_pricing_event                    =>  l_pricing_event,
		X_PRICE_CONTEXTS_RESULT_TBL	=> l_pricing_contexts_tbl,
		X_QUAL_CONTEXTS_RESULT_TBL	=> l_qual_contexts_tbl,
		x_PASS_LINE                                              => x_pass_line);

    	   ASO_PRICING_CALLBACK_PVT.Copy_Attribs_To_Req (
		p_line_index		     => 1+1,
		p_pricing_contexts_tbl	=> l_pricing_contexts_tbl,
		p_qualifier_contexts_tbl => l_qual_contexts_tbl,
		px_req_line_attr_tbl	=> l_req_line_attr_tbl,
          px_req_qual_tbl		=> l_req_qual_tbl);

    	   ASO_PRICING_CALLBACK_PVT.Copy_hdr_attr_to_line (
          	p_line_index        => 1+1,
          	p_pricing_contexts_tbl   => l_hd_pricing_contexts_tbl,
          	p_qualifier_contexts_tbl=> l_hd_qual_contexts_tbl,
          	px_req_line_attr_tbl     => l_req_line_attr_tbl,
          	px_req_qual_tbl          => l_req_qual_tbl);

    	   ASO_PRICING_CALLBACK_PVT.Append_asked_for(
		 p_header_id		   => p_qte_header_rec.quote_header_id
		,p_line_id             => p_qte_line_rec.quote_line_id
    		,p_line_index          => 1
		,px_Req_line_attr_tbl  => l_Req_line_attr_tbl
		,px_Req_qual_tbl	   => l_Req_qual_tbl);

    	   ASO_PRICING_CALLBACK_PVT.Copy_Line_To_Request(
		p_Request_Type	     => l_request_type,
		p_pricing_event     => l_pricing_event,
		p_line_rec          => p_qte_line_rec,
		p_line_dtl_rec      => p_qte_line_dtl_rec,
		p_control_rec       => p_control_rec,
		px_req_line_tbl     => l_Req_line_tbl);

    	  l_control_rec.pricing_event    := l_pricing_event;
    	  l_control_rec.calculate_flag   := p_control_rec.calculate_flag;
    	  l_control_rec.simulation_flag  := p_control_rec.simulation_flag;
    	  l_control_rec.source_order_amount_flag := 'Y';
    	  l_control_rec.TEMP_TABLE_INSERT_FLAG   := 'Y';
    	  l_control_rec.GSA_CHECK_FLAG := 'Y';
    	  l_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
     ELSE
    	  l_pricing_event := NVL(p_control_rec.pricing_event,'LINE');
    	  ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
        	p_qte_line_rec        => p_qte_line_rec,
          p_qte_line_dtl_rec    => p_qte_line_dtl_rec,
        	p_shipment_rec        => p_ln_shipment_rec);

--  bug 12988510, using overloaded funtion of build context which passes p_check_line_flag, p_pricing_event and returns x_pass_line
    	  QP_ATTR_MAPPING_PUB.Build_Contexts (
    		P_REQUEST_TYPE_CODE           => l_request_type,
    		P_PRICING_TYPE                => 'L',
                p_check_line_flag                => 'N',
		p_pricing_event                    =>  l_pricing_event,
    		X_PRICE_CONTEXTS_RESULT_TBL   => l_pricing_contexts_tbl,
    		X_QUAL_CONTEXTS_RESULT_TBL    => l_qual_contexts_tbl,
		x_pass_line  => x_pass_line);

    	  ASO_PRICING_CALLBACK_PVT.Copy_Attribs_To_Req (
    		p_line_index              => 1,
    		p_pricing_contexts_tbl    => l_pricing_contexts_tbl,
    		p_qualifier_contexts_tbl  => l_qual_contexts_tbl,
    		px_req_line_attr_tbl      => l_req_line_attr_tbl,
    		px_req_qual_tbl           => l_req_qual_tbl);
      /************************************************************
    	  ASO_PRICING_CALLBACK_PVT.Append_asked_for(
    		p_header_id           => p_qte_header_rec.quote_header_id
    		,p_line_id            => p_qte_line_rec.quote_line_id
    		,p_line_index         => 1
    		,px_Req_line_attr_tbl => l_Req_line_attr_tbl
    		,px_Req_qual_tbl      => l_Req_qual_tbl);
	********************************************************/
     ASO_PRICING_CALLBACK_PVT.Append_asked_for(
         p_line_index         => 1,
         p_pricing_attr_tbl   => p_ln_price_attr_tbl,
         px_Req_line_attr_tbl => l_Req_line_attr_tbl,
         px_Req_qual_tbl      => l_Req_qual_tbl);

    	   ASO_PRICING_CALLBACK_PVT.Copy_Line_To_Request(
    		p_Request_Type      => l_request_type,
    		p_pricing_event     => l_pricing_event,
    		p_line_rec          => p_qte_line_rec,
    		p_line_dtl_rec      => p_qte_line_dtl_rec,
    		p_control_rec       => p_control_rec,
    		px_req_line_tbl     => l_Req_line_tbl);

    	     l_control_rec.pricing_event := l_pricing_event;
    	     l_control_rec.calculate_flag := p_control_rec.calculate_flag;
    	     l_control_rec.simulation_flag := p_control_rec.simulation_flag;
    	     l_control_rec.source_order_amount_flag := 'Y';
    	     l_control_rec.TEMP_TABLE_INSERT_FLAG := 'Y';
    	     l_control_rec.GSA_CHECK_FLAG := 'Y';
    	     l_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
      END IF;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_INT:In Pricing Item: l_control_rec.pricing_event'
					  ||l_control_rec.pricing_event,1,'Y');
        aso_debug_pub.add('ASO_PRICING_INT:In Pricing Item: l_request_type'||l_request_type,1,'Y');
      END IF;


/* Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar  (MOAC) */

      IF ((p_qte_header_rec.org_id IS NULL) OR (p_qte_header_rec.org_id = FND_API.G_MISS_NUM)) THEN
		IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_MISSING_OU');
			FND_MSG_PUB.ADD;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

/*				End of Change                              (MOAC)    */


      QP_PREQ_PUB.PRICE_REQUEST
        (p_control_rec           => l_control_rec,
         p_line_tbl              => l_Req_line_tbl,
         p_qual_tbl              => l_Req_qual_tbl,
         p_line_attr_tbl         => l_Req_line_attr_tbl,
         p_line_detail_tbl       => l_req_line_detail_tbl,
         p_line_detail_qual_tbl  => l_req_line_detail_qual_tbl,
         p_line_detail_attr_tbl  => l_req_line_detail_attr_tbl,
         p_related_lines_tbl     => l_req_related_lines_tbl,
         x_line_tbl              => lx_req_line_tbl,
         x_line_qual             => lx_Req_qual_tbl,
         x_line_attr_tbl         => lx_Req_line_attr_tbl,
         x_line_detail_tbl       => lx_req_line_detail_tbl,
         x_line_detail_qual_tbl  => lx_req_line_detail_qual_tbl,
         x_line_detail_attr_tbl  => lx_req_line_detail_attr_tbl,
         x_related_lines_tbl     => lx_req_related_lines_tbl,
         x_return_status         => x_return_status,
         x_return_status_text    => l_return_status_text);

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_INT:Price Request Status from Pricing Item:'||x_return_status,1,'Y');
      END IF;

      ASO_PRICING_INT.G_LINE_REC := NULL;
      ASO_PRICING_INT.G_HEADER_REC := NULL;

      i := lx_req_line_tbl.FIRST;
      WHILE i IS NOT NULL LOOP
            lx_req_line_rec := lx_req_line_tbl(i);
            If lx_req_line_rec.status_code in(QP_PREQ_GRP.g_status_invalid_price_list,
               QP_PREQ_GRP.g_sts_lhs_not_found,
               QP_PREQ_GRP.g_status_formula_error,QP_PREQ_GRP.g_status_other_errors,
               fnd_api.g_ret_sts_unexp_error,fnd_api.g_ret_sts_error,
               QP_PREQ_GRP.g_status_calc_error,QP_PREQ_GRP.g_status_uom_failure,
               QP_PREQ_GRP.g_status_invalid_uom,QP_PREQ_GRP.g_status_dup_price_list,
               QP_PREQ_GRP.g_status_invalid_uom_conv,QP_PREQ_GRP.g_status_invalid_incomp,
               QP_PREQ_GRP.g_status_best_price_eval_error,
               QP_PREQ_PUB.g_back_calculation_sts) THEN
                           x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_INT:Fnd_Profile Value for GSA:'
						  ||FND_PROFILE.value('ASO_GSA_PRICING'), 1, 'N');
             aso_debug_pub.add('ASO_PRICING_INT:After price request in pricing_item for line id '
						  ||lx_req_line_rec.line_id ||'status code '||lx_req_line_rec.status_code, 1, 'N');
           END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                    FND_MESSAGE.Set_Token('ROW', 'ASO_PRICING_INT AFTER PRICING CALL', TRUE);
                    FND_MSG_PUB.ADD;
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSE
                l_message_text := lx_req_line_rec.status_code || ': '||lx_req_line_rec.status_text;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
                   FND_MESSAGE.Set_Token('MSG_TXT', substr(l_message_text,1,255), FALSE);
                   FND_MSG_PUB.ADD;
                END IF;
             END IF;
             lv_return_status := x_return_status;
        END IF;
        i :=  lx_req_line_tbl.NEXT(i);
    END LOOP;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:Before Copy_Request_To_Line in pricing_item', 1, 'Y');
    END IF;
    ASO_PRICING_CALLBACK_PVT.Copy_Request_To_Line (
        p_req_line_tbl              => lx_req_line_tbl,
        p_req_line_qual             => lx_Req_qual_tbl,
        p_req_line_attr_tbl         => lx_Req_line_attr_tbl,
        p_req_line_detail_tbl       => lx_req_line_detail_tbl,
        p_req_line_detail_qual_tbl  => lx_req_line_detail_qual_tbl,
        p_req_line_detail_attr_tbl  => lx_req_line_detail_attr_tbl,
        p_req_related_lines_tbl     => lx_req_related_lines_tbl,
        p_qte_line_rec              => p_qte_line_rec,
        p_qte_line_dtl_rec          => p_qte_line_dtl_rec,
        x_qte_line_tbl              => x_qte_line_tbl,
        x_qte_line_dtl_tbl          => x_qte_line_dtl_tbl,
        x_price_adj_tbl             => x_price_adj_tbl,
        x_price_adj_attr_tbl        => x_price_adj_attr_tbl,
        x_price_adj_rltship_tbl     => x_price_adj_rltship_tbl);
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:after Copy_Request_To_Line in pricing_item', 1, 'Y');
    END IF;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
   IF lv_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   End If;


 EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

END Pricing_Item;


PROCEDURE Pricing_Order(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_control_rec              IN   PRICING_CONTROL_REC_TYPE,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_hd_shipment_rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
     p_hd_price_attr_tbl        IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
     p_qte_line_tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     p_line_rltship_tbl         IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Tbl,
     p_qte_line_dtl_tbl         IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl,
     p_ln_shipment_tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl,
     p_ln_price_attr_tbl        IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
     x_qte_header_rec           OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_qte_line_dtl_tbl         OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
     x_price_adj_tbl            OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
     x_price_adj_attr_tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
     x_price_adj_rltship_tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Pricing_Order';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_request_type                VARCHAR2(60);
    l_pricing_event               VARCHAR2(30);
    G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    lx_qte_line_tbl                ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT PRICING_ORDER_PVT;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_INT:Start of Pricing Order.....',1,'Y');
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_INT:Begin FND_API.to_Boolean'||p_init_msg_list, 1, 'Y');
 END IF;
 FND_MSG_PUB.initialize;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

ASO_PRICING_CORE_PVT.Initialize_Global_Tables;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_INT:p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
  aso_debug_pub.add('ASO_PRICING_INT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
END IF;
l_request_type := p_control_rec.request_type;
l_pricing_event := p_control_rec.pricing_event;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_INT:Pricing Order Code Path Determination Flag - PRICE_CONFIG_FLAG:'
                     || p_control_rec.PRICE_CONFIG_FLAG,1,'Y');
  aso_debug_pub.add('ASO_PRICING_INT:p_qte_line_tbl.count:'||nvl(p_qte_line_tbl.count,0),1,'Y');
END IF;
If p_control_rec.PRICE_CONFIG_FLAG = 'Y' then
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_INT:Before Pricing Request Configurator Code Path Begins',1,'Y');
     END IF;

   ASO_PRICING_CALLBACK_PVT.Config_Callback_Pricing_Order(
     P_Api_Version_Number          => P_Api_Version_Number,
     P_Init_Msg_List               => FND_API.G_FALSE,
     P_Commit                      => FND_API.G_FALSE,
     p_control_rec                 => p_control_rec,
     p_qte_header_rec              => p_qte_header_rec,
     p_hd_shipment_rec             => p_hd_shipment_rec,
     p_hd_price_attr_tbl           => p_hd_price_attr_tbl,
     p_qte_line_tbl                => p_qte_line_tbl,
     p_line_rltship_tbl            => p_line_rltship_tbl,
     p_qte_line_dtl_tbl            => p_qte_line_dtl_tbl,
     p_ln_shipment_tbl             => p_ln_shipment_tbl,
     p_ln_price_attr_tbl           => p_ln_price_attr_tbl,
     x_qte_header_rec              => x_qte_header_rec,
     x_qte_line_tbl                => x_qte_line_tbl,
     x_qte_line_dtl_tbl            => x_qte_line_dtl_tbl,
     x_price_adj_tbl               => x_price_adj_tbl,
     x_price_adj_attr_tbl          => x_price_adj_attr_tbl,
     x_price_adj_rltship_tbl       => x_price_adj_rltship_tbl,
     x_return_status               => x_return_status,
     x_msg_count                   => x_msg_count,
     x_msg_data                    => x_msg_data);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_INT:After Config_Callback_Pricing_Order:x_qte_line_tbl.count:'||nvl(x_qte_line_tbl.count,0),1,'Y');
	  If x_qte_line_tbl.count > 0 then
	    For i in 1..x_qte_line_tbl.count loop
	       aso_debug_pub.add('ASO_PRICING_INT:x_qte_line_tbl('||i||').LINE_LIST_PRICE: '||x_qte_line_tbl(i).LINE_LIST_PRICE,1,'Y');
	       aso_debug_pub.add('ASO_PRICING_INT:x_qte_line_tbl('||i||').LINE_QUOTE_PRICE: '||x_qte_line_tbl(i).LINE_QUOTE_PRICE,1,'Y');
	       aso_debug_pub.add('ASO_PRICING_INT:x_qte_line_tbl('||i||').INVENTORY_ITEM_ID: '||x_qte_line_tbl(i).INVENTORY_ITEM_ID,1,'Y');
	    End Loop;
	  End If;

     END IF;-- ASO_DEBUG_PUB.G_Debug_Flag = 'Y'

Else
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('ASO_PRICING_INT: p_control_rec.price_mode: '||NVL(p_control_rec.price_mode,'NULL'),1,'Y');
     END IF;

   --Non Configurator Code Path

   If NVL(p_control_rec.price_mode,'ENTIRE_QUOTE') = 'ENTIRE_QUOTE' then

	   ASO_PRICING_FLOWS_PVT.Price_Entire_Quote(
             P_Api_Version_Number       => P_Api_Version_Number,
             P_Init_Msg_List            => FND_API.G_FALSE,
             P_Commit                   => FND_API.G_FALSE,
             p_control_rec              => p_control_rec,
             p_qte_header_rec           => p_qte_header_rec,
             p_hd_shipment_rec          => p_hd_shipment_rec,
             p_qte_line_tbl             => p_qte_line_tbl,
		   x_qte_line_tbl             => lx_qte_line_tbl,
             x_return_status            => x_return_status,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ELSIF (p_control_rec.price_mode = 'CHANGE_LINE') then
        -- Change Line logic code path

         ASO_PRICING_FLOWS_PVT.Price_Quote_With_Change_Lines(
             P_Api_Version_Number       => P_Api_Version_Number,
             P_Init_Msg_List            => FND_API.G_FALSE,
             P_Commit                   => FND_API.G_FALSE,
             p_control_rec              => p_control_rec,
             p_qte_header_rec           => p_qte_header_rec,
             p_hd_shipment_rec          => p_hd_shipment_rec,
             p_qte_line_tbl             => p_qte_line_tbl,
		   x_qte_line_tbl             => lx_qte_line_tbl,
             x_return_status            => x_return_status,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Else
       --p_control_rec.price_mode = 'QUOTE_LINE'

       ASO_PRICING_FLOWS_PVT.Price_Quote_Line(
           P_Api_Version_Number       => P_Api_Version_Number,
           P_Init_Msg_List            => FND_API.G_FALSE,
           P_Commit                   => FND_API.G_FALSE,
           p_control_rec              => p_control_rec,
           p_qte_header_rec           => p_qte_header_rec,
           p_hd_shipment_rec          => p_hd_shipment_rec,
           p_qte_line_tbl             => p_qte_line_tbl,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   End If;--NVL(p_control_rec.price_mode,'ENTIRE_QUOTE') = 'ENTIRE_QUOTE'


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_INT:After Entire_Quote:lx_qte_line_tbl.count:'||nvl(lx_qte_line_tbl.count,0),1,'Y');
END IF;

x_qte_line_tbl:= p_qte_line_tbl;

If lx_qte_line_tbl.count > 0 then
For i in 1..lx_qte_line_tbl.count loop
x_qte_line_tbl(x_qte_line_tbl.count+1) := lx_qte_line_tbl(i);
end loop;
end If;
End if;--p_control_rec.PRICE_CONFIG_FLAG = 'Y'

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_INT:End of Pricing Order:x_qte_line_tbl.count:'||nvl(x_qte_line_tbl.count,0),1,'Y');
END IF;

 FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

 for l in 1 .. x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_INT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_INT:after inside EXCEPTION  return status'||x_return_status, 1, 'Y');
      END IF;
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);


END Pricing_Order;


PROCEDURE Pricing_Item (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec                IN    PRICING_CONTROL_REC_TYPE,
    p_qte_line_id                IN    NUMBER,
    x_return_status              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */      VARCHAR2)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Pricing_Item';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_qte_line_rec            ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_qte_header_id           NUMBER;
    l_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_hd_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_hd_shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_hd_price_attr_tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_qte_line_dtl_rec        ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_qte_line_dtl_tbl        ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_ln_shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_ln_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_ln_price_attr_tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_qte_line_tbl           ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_dtl_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_price_adj_tbl          ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_price_adj_attr_tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    l_price_list_id     NUMBER;
    l_CURRENCY_CODE  VARCHAR2(15);


    CURSOR c_header_id IS
    SELECT QUOTE_HEADER_ID
    FROM ASO_QUOTE_LINES_ALL
    WHERE QUOTE_LINE_ID = p_qte_line_id;

    CURSOR c_list_id(l_qte_header_id NUMBER) IS
    SELECT price_list_id , CURRENCY_CODE
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE QUOTE_HEADER_ID = l_qte_header_id;

BEGIN

    -- Standard Start of API savepoint
      SAVEPOINT PRICING_ITEM_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_id);
    l_qte_header_id := l_qte_line_rec.QUOTE_HEADER_ID;
    l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(l_qte_header_id);
    l_hd_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(l_qte_header_id, NULL);

    IF l_hd_shipment_tbl.count = 1 THEN
       l_hd_shipment_rec := l_hd_shipment_tbl(1);
    END IF;
    l_hd_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(l_qte_header_id, null);
    l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(p_qte_line_id);

    IF l_qte_line_dtl_tbl.count = 1 THEN
       l_qte_line_dtl_rec := l_qte_line_dtl_tbl(1);
    END IF;
    l_ln_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(l_qte_header_id, p_QTE_LINE_ID);

    IF l_ln_shipment_tbl.count = 1 THEN
       l_ln_shipment_rec := l_ln_shipment_tbl(1);
    END IF;
    l_ln_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(l_qte_header_id, p_qte_line_id);
    --Code changed on   04/18/2000

    OPEN c_header_id;
    FETCH c_header_id INTO l_qte_header_id;
    CLOSE c_header_id;

    OPEN c_list_id (l_qte_header_id);
    FETCH c_list_id INTO l_price_list_id,l_CURRENCY_CODE;
    CLOSE c_list_id;

    IF l_qte_line_rec.price_list_id is NULL or l_qte_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
       l_qte_line_rec.price_list_id := l_price_list_id ;
    ELSE
       l_qte_header_rec.price_list_id := NULL;
    END IF;

    IF l_qte_line_rec.CURRENCY_CODE is NULL or l_qte_line_rec.CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
       l_qte_line_rec.CURRENCY_CODE := l_CURRENCY_CODE ;
    END IF;

    Pricing_Item (
        P_Api_Version_Number    => 1,
        P_Init_Msg_List         => FND_API.G_FALSE,
        P_Commit                => FND_API.G_FALSE,
        p_control_rec           => p_control_rec,
        p_qte_header_rec        => l_qte_header_rec,
        p_hd_shipment_rec       => l_hd_shipment_rec,
        p_hd_price_attr_tbl     => l_hd_price_attr_tbl,
        p_qte_line_rec          => l_qte_line_rec,
        p_qte_line_dtl_rec      => l_qte_line_dtl_rec,
        p_ln_shipment_rec       => l_ln_shipment_rec,
        p_ln_price_attr_tbl     => l_ln_price_attr_tbl,
        x_qte_line_tbl          => lx_qte_line_tbl,
        x_qte_line_dtl_tbl      => lx_qte_line_dtl_tbl,
        x_price_adj_tbl         => lx_price_adj_tbl,
        x_price_adj_attr_tbl    => lx_price_adj_attr_tbl,
        x_price_adj_rltship_tbl => lx_price_adj_rltship_tbl,
        x_return_status         => x_return_status,
        x_msg_data              => x_msg_data,
        x_msg_count             => x_msg_count);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Changed the delete statement as per bug 1874082 */
 /*Removed the Complex Delete Statement with UNION bug 2585468 */
    DELETE from ASO_PRICE_ADJ_RELATIONSHIPS
    WHERE quote_line_id = p_qte_line_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:Rltd adj Lines deleted '||sql%ROWCOUNT,1,'Y');
    END IF;


    DELETE FROM ASO_PRICE_ADJUSTMENTS
    WHERE quote_line_id = p_qte_line_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:ADJ Lines deleted '||sql%ROWCOUNT,1,'Y');
    END IF;

  FOR i IN 1..lx_qte_line_tbl.count LOOP
       l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(lx_qte_line_tbl(i).quote_line_id);
       lx_qte_line_tbl(i).price_list_id := l_qte_line_rec.price_list_id;
  END LOOP;

  ASO_PRICING_CALLBACK_PVT.Update_Quote_Rows (
         p_qte_line_tbl        => lx_qte_line_tbl,
         p_qte_line_dtl_tbl    => lx_qte_line_dtl_tbl,
         p_price_adj_tbl        => lx_price_adj_tbl,
         p_price_adj_attr_tbl    => lx_price_adj_attr_tbl,
         p_price_adj_rltship_tbl => lx_price_adj_rltship_tbl);

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_INT:Pricing Item Ends if the second Pricing Item was called...',1,'Y');
 END IF;

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
      COMMIT WORK;
      END IF;

      EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);


END Pricing_Item;


PROCEDURE Pricing_Order (
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec                IN    PRICING_CONTROL_REC_TYPE,
        p_qte_line_tbl               IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_qte_header_id              IN    NUMBER,
        x_return_status              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
        x_msg_count                  OUT NOCOPY /* file.sql.39 change */      NUMBER,
        x_msg_data                   OUT NOCOPY /* file.sql.39 change */      VARCHAR2)
IS

    l_api_name                      CONSTANT VARCHAR2(30) := 'Pricing_Order';
    l_api_version_number            CONSTANT NUMBER   := 1.0;
    l_control_rec                   QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
    l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_hd_pricing_contexts_Tbl       QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_hd_qual_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_pricing_contexts_Tbl          QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    l_qual_contexts_Tbl             QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
    lx_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
    lx_req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
    lx_req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    lx_req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    lx_req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    lx_req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    lx_req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
    l_qte_header_rec                ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_shipment_tbl                  ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_shipment_rec                  ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_price_attr_tbl                ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_qte_line_tbl                  ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_qte_line_id                   NUMBER;
    l_qte_line_dtl_rec              ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_qte_line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_return_status                 VARCHAR2(1);
    l_return_status_text            VARCHAR2(2000);
    l_request_type                  VARCHAR2(60);
    l_pricing_event                 VARCHAR2(30);
    l_qte_line_rec                  ASO_QUOTE_PUB.Qte_Line_rec_Type;
    lx_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_line_tbl                 ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_qte_line_dtl_tbl             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_price_adj_tbl                ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_price_adj_attr_tbl           ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_price_adj_rltship_tbl        ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    l_message_text                  VARCHAR2(2000);
    i                               BINARY_INTEGER;
    ln_shipment_tbl                 ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_line_rltship_tbl              ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    l_ln_price_attr_tbl             ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_return_status                VARCHAR2(50);
    lx_msg_count                    NUMBER;
    lx_msg_data                     VARCHAR2(2000);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT PRICING_ORDER_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_INT:In Pricing Order with hdr Id', 1, 'Y');
    END IF;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_request_type := p_control_rec.request_type;
    l_pricing_event := p_control_rec.pricing_event;

    l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_id);
    l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_id,NULL);
    IF l_shipment_tbl.count = 1 THEN
      l_shipment_rec := l_shipment_tbl(1);
    END IF;
    l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(p_qte_header_id, null);
    ASO_PRICING_INT.Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => FND_API.G_FALSE,
                    P_Commit                 => FND_API.G_FALSE,
                    p_control_rec            => p_control_rec,
                    p_qte_header_rec         => l_qte_header_rec,
                    p_hd_shipment_rec        => l_shipment_rec,
                    p_hd_price_attr_tbl      => l_price_attr_tbl,
                    p_qte_line_tbl           => p_qte_line_tbl,
                    p_line_rltship_tbl       => l_line_rltship_tbl,
                    p_qte_line_dtl_tbl       => l_qte_line_dtl_tbl,
                    p_ln_shipment_tbl        => ln_shipment_tbl,
                    p_ln_price_attr_tbl      => l_ln_price_attr_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          => lx_price_adj_tbl,
                    x_price_adj_attr_tbl     => lx_price_adj_attr_tbl,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
      COMMIT WORK;
      END IF;

   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

END Pricing_Order;


Procedure Delete_Promotion (
        P_Api_Version_Number IN   NUMBER,
        P_Init_Msg_List      IN   VARCHAR2  := FND_API.G_FALSE,
        P_Commit             IN   VARCHAR2  := FND_API.G_FALSE,
	   p_price_attr_tbl     IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        x_return_status      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count          OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data           OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
BEGIN
ASO_PRICING_CORE_PVT.Delete_Promotion (
        P_Api_Version_Number  => P_Api_Version_Number,
        P_Init_Msg_List       => P_Init_Msg_List,
        P_Commit              => P_Commit,
        p_price_attr_tbl      => p_price_attr_tbl,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);

END Delete_Promotion;

-- hagrawal_start Funtion added
FUNCTION Get_Cust_Po(
    p_qte_header_id     number
    ) RETURN  VARCHAR2
IS
Cursor get_po is SELECT payment_ref_number from aso_payments
WHERE
payment_type_code ='PO' and quote_header_id = p_qte_header_id and quote_line_id is NULL;
Customer_PO VARCHAR2(240);

BEGIN
OPEN get_po;
fetch get_po into Customer_Po;
CLOSE get_po;
RETURN Customer_Po;
END Get_Cust_Po;

FUNCTION Get_line_Cust_Po(
    p_qte_line_id       number
) RETURN  VARCHAR2
IS
Cursor get_po is SELECT payment_ref_number from aso_payments
WHERE
payment_type_code ='PO' and  quote_line_id = p_qte_line_id;
Customer_PO VARCHAR2(240);

BEGIN
OPEN get_po;
fetch get_po into Customer_Po;
CLOSE get_po;
RETURN Customer_Po;
END Get_line_Cust_Po;

FUNCTION Get_Request_date(
    p_qte_header_id     number
    ) RETURN  DATE
IS

Cursor get_req_date is SELECT request_date from aso_shipments
WHERE
quote_header_id = p_qte_header_id and quote_line_id is NULL;
l_request_date DATE;
x_request_date DATE;
BEGIN
OPEN get_req_date;
fetch get_req_date into l_request_date;
CLOSE get_req_date;

x_request_date := FND_DATE.DATE_TO_CANONICAL(l_request_date);
RETURN x_request_date;
END Get_Request_date;

FUNCTION Get_Line_Request_date(
     p_qte_line_id       number
) RETURN  DATE
IS

Cursor get_req_date is SELECT request_date from aso_shipments
WHERE quote_line_id = p_qte_line_id ;
l_request_date DATE;
x_request_date DATE;
BEGIN
OPEN get_req_date;
fetch get_req_date into l_request_date;
CLOSE get_req_date;

x_request_date := FND_DATE.DATE_TO_CANONICAL(l_request_date);
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_INT:In  Get_Line_Request_date'||x_request_date, 1, 'Y');
  END IF;
RETURN x_request_date;
END Get_line_Request_date;


FUNCTION Get_Freight_term(
    p_qte_header_id     number
    ) RETURN  DATE
IS

Cursor get_frieght is SELECT FREIGHT_TERMS_CODE from aso_shipments
WHERE
quote_header_id = p_qte_header_id and quote_line_id is NULL;
l_freight_terms_code VARCHAR2(30);
BEGIN
OPEN get_frieght;
fetch get_frieght into l_freight_terms_code;
CLOSE get_frieght;
RETURN l_freight_terms_code;
END Get_Freight_term;

FUNCTION Get_line_Freight_term(
     p_qte_line_id    number
    ) RETURN  VARCHAR2
IS

Cursor get_frieght is SELECT FREIGHT_TERMS_CODE from aso_shipments
WHERE
quote_line_id = p_qte_line_id;
l_freight_terms_code VARCHAR2(30);
BEGIN
OPEN get_frieght;
fetch get_frieght into l_freight_terms_code;
CLOSE get_frieght;
RETURN l_freight_terms_code;
END Get_line_Freight_term;

FUNCTION Get_Payment_term(
    p_qte_header_id     number
    ) RETURN  NUMBER
IS

Cursor get_pmnt_term is SELECT payment_term_id from aso_payments
WHERE
quote_header_id = p_qte_header_id and quote_line_id IS null;
l_pmnt_term_id NUMBER;
BEGIN
OPEN get_pmnt_term;
fetch get_pmnt_term into l_pmnt_term_id;
CLOSE get_pmnt_term;
RETURN l_pmnt_term_id;
END Get_Payment_term;


FUNCTION Get_line_Payment_term(
       p_qte_line_id    number
    ) RETURN  NUMBER
IS

Cursor get_pmnt_term is SELECT payment_term_id from aso_payments
WHERE
quote_line_id = p_qte_line_id;
l_pmnt_term_id NUMBER;
BEGIN
OPEN get_pmnt_term;
fetch get_pmnt_term into l_pmnt_term_id;
CLOSE get_pmnt_term;
RETURN l_pmnt_term_id;
END Get_line_Payment_term;


End ASO_PRICING_INT;

/
