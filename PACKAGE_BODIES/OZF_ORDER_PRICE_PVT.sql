--------------------------------------------------------
--  DDL for Package Body OZF_ORDER_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ORDER_PRICE_PVT" AS
/* $Header: ozfvorpb.pls 120.4 2006/12/15 03:23:23 mkothari noship $ */

-- Package name     : OZF_ORDER_PRICE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_ORDER_PRICE_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfvorpb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
---------------------------------------------------------------------
-- PROCEDURE
--    build_order_header
--
-- PURPOSE
--    This procedure use the input order information construct information
--    for an order header.
--
-- PARAMETERS
--    p_hdr            in oe_order_pub.header_rec_type
--    x_return_status  out varchar2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE build_order_header(
     p_hdr IN line_rec_type
     ,x_return_status out NOCOPY varchar2)
IS
l_msg_data varchar2(2000);
l_msg_count number;
l_return_status varchar2(30);

l_msg_parameter_list   WF_PARAMETER_LIST_T;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_PVT.debug_message('in build order header');
   END IF;
   -- Mapping, default and validation rules here
   -- Since we can not use the OM defaulting rule. We just default order type based on the cust account id
/*
   IF oe_order_pub.g_hdr.order_type_id is null or
     oe_order_pub.g_hdr.order_type_id = FND_API.g_miss_num THEN

     OPEN order_type_csr(oe_order_pub.g_hdr.sold_to_org_id);
     FETCH order_type_csr into oe_order_pub.g_hdr.order_type_id;
     CLOSE order_type_csr;
   END IF;

   OZF_CHARGEBACK_ATTRMAP_PUB.Create_Global_Header(
    p_api_version      => 1.0
   ,p_init_msg_list    => FND_API.G_FALSE
   ,p_commit           => FND_API.G_FALSE
   ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
   ,x_return_status    => l_return_status
   ,x_msg_data         => l_msg_data
   ,x_msg_count        => l_msg_count
   ,xp_hdr             => oe_order_pub.g_hdr
   ,p_interface_id     => p_hdr.chargeback_int_id
   );
*/

   WF_EVENT.AddParameterToList(
      p_name          => 'INTERFACE_ID',
      p_value         => p_hdr.chargeback_int_id,
      p_parameterlist => l_msg_parameter_list
   );

   -- bug 5331553 (+)
   WF_EVENT.AddParameterToList(
      p_name          => 'RESALE_TABLE_TYPE',
      p_value         => p_hdr.resale_table_type,
      p_parameterlist => l_msg_parameter_list
   );
   -- bug 5331553 (-)

   WF_EVENT.raise (
      p_event_name => 'oracle.apps.ozf.idsm.OMGHDR',
      p_event_key  => p_hdr.resale_table_type||to_char(p_hdr.chargeback_int_id)||'_'||to_char(sysdate,'YYYYMMDD HH24MISS'),
      p_parameters => l_msg_parameter_list
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END build_order_header;

---------------------------------------------------------------------
-- PROCEDURE
--    build_order_line
--
-- PURPOSE
--    This procedure use the input order information construct information
--    for an order header.
--
-- PARAMETERS
--    p_line            in oe_order_pub.line_rec_type
--    x_return_status  out NOCOPY varchar2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE build_order_line(
    p_line IN line_rec_type
   ,x_return_status out NOCOPY varchar2)
IS
l_msg_data varchar2(2000);
l_msg_count number;
l_return_status varchar2(30);
l_msg_parameter_list   WF_PARAMETER_LIST_T;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_PVT.debug_message('in build order line');
   END IF;
   -- Mapping, default and validation rules here
/*
   OZF_CHARGEBACK_ATTRMAP_PUB.Create_Global_line(
    p_api_version      => 1.0
   ,p_init_msg_list    => FND_API.G_FALSE
   ,p_commit           => FND_API.G_FALSE
   ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
   ,x_return_status    => l_return_status
   ,x_msg_data         => l_msg_data
   ,x_msg_count        => l_msg_count
   ,xp_line            => oe_order_pub.g_line
   ,p_interface_id     => p_line.chargeback_int_id
   );
*/
   WF_EVENT.AddParameterToList(
      p_name          => 'INTERFACE_ID',
      p_value         => p_line.chargeback_int_id,
      p_parameterlist => l_msg_parameter_list
   );

   -- bug 5331553 (+)
   WF_EVENT.AddParameterToList(
      p_name          => 'RESALE_TABLE_TYPE',
      p_value         => p_line.resale_table_type,
      p_parameterlist => l_msg_parameter_list
   );
   -- bug 5331553 (-)

   WF_EVENT.raise (
      p_event_name => 'oracle.apps.ozf.idsm.OMGLINE',
      p_event_key  => p_line.resale_table_type||to_char(p_line.chargeback_int_id)||'_'||to_char(sysdate,'YYYYMMDD HH24MISS'),
      p_parameters => l_msg_parameter_list
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END build_order_line;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Order_Price
--
-- PURPOSE
--    Get_Order_Price
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Get_Order_Price
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_control_rec            IN            QP_PREQ_GRP.CONTROL_RECORD_TYPE
   ,xp_line_tbl              IN OUT NOCOPY LINE_REC_TBL_TYPE
   ,x_ldets_tbl              OUT NOCOPY    LDETS_TBL_TYPE
   ,x_related_lines_tbl      OUT NOCOPY    RLTD_LINE_TBL_TYPE
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Get_Order_Price';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

l_return_status_code varchar2(240);
l_price_return_msg   varchar2(240);

I                   Number;
l_header_build      boolean :=False;
l_control_rec       QP_PREQ_GRP.CONTROL_RECORD_TYPE := p_control_rec;

cursor cl_lines_tmp is
select *
from qp_preq_lines_tmp
order by line_index;

cursor cl_ldets_tmp is
select *
from qp_ldets_v
where pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

CURSOR cl_rltd_tmp IS
SELECT  *
FROM QP_PREQ_RLTD_LINES_TMP
WHERE PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
ORDER BY SETUP_VALUE_FROM;

cursor cl_line_attrs_tmp is
select *
from  qp_preq_line_attrs_tmp_t;

G_LINE_INDEX_tbl                QP_PREQ_GRP.pls_integer_type;
G_LINE_TYPE_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICING_EFFECTIVE_DATE_TBL  QP_PREQ_GRP.DATE_TYPE   ;
G_ACTIVE_DATE_FIRST_TBL       QP_PREQ_GRP.DATE_TYPE   ;
G_ACTIVE_DATE_FIRST_TYPE_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
G_ACTIVE_DATE_SECOND_TBL      QP_PREQ_GRP.DATE_TYPE   ;
G_ACTIVE_DATE_SECOND_TYPE_TBL QP_PREQ_GRP.VARCHAR_TYPE ;
G_LINE_QUANTITY_TBL           QP_PREQ_GRP.NUMBER_TYPE ;
G_LINE_UOM_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_REQUEST_TYPE_CODE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICED_QUANTITY_TBL         QP_PREQ_GRP.NUMBER_TYPE;
G_PRICED_UOM_CODE_TBL         QP_PREQ_GRP.VARCHAR_TYPE;
G_CURRENCY_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_UNIT_PRICE_TBL              QP_PREQ_GRP.NUMBER_TYPE;
G_PERCENT_PRICE_TBL           QP_PREQ_GRP.NUMBER_TYPE;
G_UOM_QUANTITY_TBL            QP_PREQ_GRP.NUMBER_TYPE;
G_ADJUSTED_UNIT_PRICE_TBL     QP_PREQ_GRP.NUMBER_TYPE;
G_UPD_ADJUSTED_UNIT_PRICE_TBL QP_PREQ_GRP.NUMBER_TYPE;
G_PROCESSED_FLAG_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICE_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;

--mkothari 13-dec-2006
G_LIST_PRICE_OVERRIDE_TBL     QP_PREQ_GRP.VARCHAR_TYPE;

G_LINE_ID_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
G_PROCESSING_ORDER_TBL        QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_PRICING_STATUS_CODE_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICING_STATUS_TEXT_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
G_ROUNDING_FLAG_TBL                QP_PREQ_GRP.FLAG_TYPE;
G_ROUNDING_FACTOR_TBL              QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_QUALIFIERS_EXIST_FLAG_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICING_ATTRS_EXIST_FLAG_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICE_LIST_ID_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
G_PL_VALIDATED_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_PRICE_REQUEST_CODE_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
G_USAGE_PRICING_TYPE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
/*
G_LINE_CATEGORY_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
G_CONTRACT_START_DATE_DEF_TBL   QP_PREQ_GRP.DATE_TYPE;
G_CONTRACT_END_DATE_DEF_TBL     QP_PREQ_GRP.DATE_TYPE;
G_LINE_UNIT_PRICE_DEF_TBL       QP_PREQ_GRP.NUMBER_TYPE;
*/
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Get_Order_Price_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_PVT.debug_message('in get_order_price' );
   END IF;

   -- Default control record if necessary
   IF l_control_rec.pricing_event is null THEN
      l_control_rec.pricing_event := 'BATCH';
   END IF;

   IF l_control_rec.calculate_flag is null THEN
      l_control_rec.calculate_flag := 'Y';
   END IF;
   IF l_control_rec.simulation_flag is null THEN
      l_control_rec.simulation_flag := 'Y';
   END IF;
/*
   IF l_control_rec.source_order_amount_flag is NULL THEN
      l_control_rec.source_order_amount_flag := 'Y';
   END IF;

   IF l_control_rec.GSA_CHECK_FLAG is null THEN
      l_control_rec.GSA_CHECK_FLAG := 'N';
   END IF;

   IF l_control_rec.GSA_DUP_CHECK_FLAG is null THEN
      l_control_rec.GSA_DUP_CHECK_FLAG := 'N';
   END IF;
*/
   -- always read information from QP temp tables
   l_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';

   IF l_control_rec.request_type_code is null THEN
      l_control_rec.request_type_code := 'ONT';
   END IF;

   -- Bug 4665626 (+)
   l_control_rec.rounding_flag := 'Q';
   -- Bug 4665626 (-)

   -- Construct the order
   For I in xp_line_tbl.FIRST..xp_line_tbl.count LOOP
      IF xp_line_tbl(I).line_type_code = G_HDR_TYPE OR
         xp_line_tbl(I).line_type_code = G_LINE_TYPE THEN

         -- Assign request infromation to the insert structure.
         IF xp_line_tbl(I).line_index is NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_ORD_LN_INDX_MISS');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            G_LINE_INDEX_TBL(I):=xp_line_tbl(I).line_index;
         END IF;

         IF xp_line_tbl(I).line_type_code is NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_ORD_LN_TYPCODE_MISS');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            G_LINE_TYPE_CODE_TBL(I):= xp_line_tbl(I).line_type_code;
         END IF;

         IF xp_line_tbl(I).PRICING_EFFECTIVE_DATE is NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_ORD_EFF_DATE_MISS');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            G_PRICING_EFFECTIVE_DATE_TBL(I):=xp_line_tbl(I).PRICING_EFFECTIVE_DATE;
         END IF;

         IF xp_line_tbl(I).ACTIVE_DATE_FIRST is null THEN
             G_ACTIVE_DATE_FIRST_TBL(I):= sysdate;
         ELSE
            G_ACTIVE_DATE_FIRST_TBL(I):= xp_line_tbl(I).ACTIVE_DATE_FIRST;
         END IF;

         IF xp_line_tbl(I).ACTIVE_DATE_FIRST_TYPE is null THEN
            G_ACTIVE_DATE_FIRST_TYPE_TBL(I):='NO TYPE';
         ELSE
            G_ACTIVE_DATE_FIRST_TYPE_TBL(I):= xp_line_tbl(I).ACTIVE_DATE_FIRST_TYPE;
         END IF;

         IF xp_line_tbl(I).ACTIVE_DATE_SECOND is NULL THEN
            G_ACTIVE_DATE_SECOND_TBL(I):= sysdate;
         ELSE
            G_ACTIVE_DATE_SECOND_TBL(I):= xp_line_tbl(I).ACTIVE_DATE_SECOND;
         END IF;

         IF xp_line_tbl(I).ACTIVE_DATE_SECOND_TYPE is NULL THEN
            G_ACTIVE_DATE_SECOND_TYPE_TBL(I) := 'NO TYPE';
         ELSE
            G_ACTIVE_DATE_SECOND_TYPE_TBL(I) := xp_line_tbl(I).ACTIVE_DATE_SECOND_TYPE;
         END IF;

         G_LINE_QUANTITY_TBL(I):= xp_line_tbl(I).LINE_QUANTITY;
         G_LINE_UOM_CODE_TBL(I):= xp_line_tbl(I).LINE_UOM_CODE;

         IF xp_line_tbl(I).REQUEST_TYPE_CODE IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_ORD_REQ_TYPCD_MISS');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            G_REQUEST_TYPE_CODE_TBL(I):= xp_line_tbl(I).REQUEST_TYPE_CODE;
         END IF;

         G_PRICED_QUANTITY_TBL(I):= xp_line_tbl(I).PRICED_QUANTITY;
         G_PRICED_UOM_CODE_TBL(I):= xp_line_tbl(I).PRICED_UOM_CODE;
         G_CURRENCY_CODE_TBL(I):= xp_line_tbl(I).CURRENCY_CODE;
         G_UNIT_PRICE_TBL(I):= xp_line_tbl(I).UNIT_PRICE;
         G_PERCENT_PRICE_TBL(I):= xp_line_tbl(I).PERCENT_PRICE;
         G_UOM_QUANTITY_TBL(I):= xp_line_tbl(I).UOM_QUANTITY;
         G_ADJUSTED_UNIT_PRICE_TBL(I):= xp_line_tbl(I).ADJUSTED_UNIT_PRICE;
         G_UPD_ADJUSTED_UNIT_PRICE_TBL(I):= xp_line_tbl(I).UPD_ADJUSTED_UNIT_PRICE;
         G_PROCESSED_FLAG_TBL(I):= xp_line_tbl(I).PROCESSED_FLAG;

         IF xp_line_tbl(I).PRICE_FLAG is null THEN
            G_PRICE_FLAG_TBL(I):= 'Y'; -- Apply all price and modifier to the request line.
         ELSE
            G_PRICE_FLAG_TBL(I):= xp_line_tbl(I).PRICE_FLAG;
         END IF;

         --mkothari 13-dec-2006
         G_LIST_PRICE_OVERRIDE_TBL(I):= xp_line_tbl(I).LIST_PRICE_OVERRIDE_FLAG;

         G_LINE_ID_TBL(I):= xp_line_tbl(I).line_Id;
         G_PROCESSING_ORDER_TBL(I):= xp_line_tbl(I).PROCESSING_ORDER;

         -- Always this value
         G_PRICING_STATUS_CODE_tbl(I):= QP_PREQ_GRP.G_STATUS_UNCHANGED;

         G_PRICING_STATUS_TEXT_tbl(I):= xp_line_tbl(I).PRICING_STATUS_TEXT;
         G_ROUNDING_FLAG_TBL(I):= xp_line_tbl(I).ROUNDING_FLAG;
         G_ROUNDING_FACTOR_TBL(I):= xp_line_tbl(I).ROUNDING_FACTOR;
         G_QUALIFIERS_EXIST_FLAG_TBL(I):= xp_line_tbl(I).QUALIFIERS_EXIST_FLAG;
         G_PRICING_ATTRS_EXIST_FLAG_TBL(I):= xp_line_tbl(I).PRICING_ATTRS_EXIST_FLAG;
         G_PRICE_LIST_ID_TBL(I):= xp_line_tbl(I).PRICE_LIST_ID;
         G_PL_VALIDATED_FLAG_TBL(I):= xp_line_tbl(I).PL_VALIDATED_FLAG;
         G_PRICE_REQUEST_CODE_TBL(I):= xp_line_tbl(I).PRICE_REQUEST_CODE;
         G_USAGE_PRICING_TYPE_tbl(I):= xp_line_tbl(I).USAGE_PRICING_TYPE;

/*
   IF xp_line_tbl(I).LINE_CATEGORY = FND_API.G_MISS_CHAR THEN
      G_LINE_CATEGORY_tbl(I):= null;
   END IF;

    -- We don't have to fill these columns
   G_CONTRACT_START_DATE_DEF_TBL(I):= null;
        G_CONTRACT_END_DATE_DEF_TBL(I)  := null;
        G_LINE_UNIT_PRICE_DEF_TBL(I)    := null;
*/

         IF xp_line_tbl(I).line_type_code = G_HDR_TYPE THEN
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('before build header' );
            END IF;
            oe_order_pub.g_hdr := g_header_rec;
            build_order_header(  p_hdr => xp_line_tbl(I),
                                 x_return_status => l_return_status);
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            QP_Attr_Mapping_PUB.Build_Contexts(
               p_request_type_code => 'ONT',
               p_line_index        => xp_line_tbl(I).line_index,
               p_pricing_type_code =>'H'
            );
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('after build header' );
            END IF;
         ELSE
            --  It has to be line
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('before build line' );
            END IF;
            oe_order_pub.g_line := g_line_rec_tbl(I);
            build_order_line( p_line => xp_line_tbl(I),
                        x_return_status => l_return_status);
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            QP_Attr_Mapping_PUB.Build_Contexts(
               p_request_type_code => 'ONT',
               p_line_index        => xp_line_tbl(I).line_index,
               p_pricing_type_code =>'L'
               );
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('after build line' );
            END IF;
         END IF;
     ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_ORD_LINE_TYPE_WRG');
          FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   End LOOP;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('Before insert_lines2' );
   END IF;

   QP_PREQ_GRP.INSERT_LINES2
                (p_LINE_INDEX =>   G_LINE_INDEX_TBL,
                 p_LINE_TYPE_CODE =>  G_LINE_TYPE_CODE_TBL,
                 p_PRICING_EFFECTIVE_DATE =>G_PRICING_EFFECTIVE_DATE_TBL,
                 p_ACTIVE_DATE_FIRST       =>G_ACTIVE_DATE_FIRST_TBL,
                 p_ACTIVE_DATE_FIRST_TYPE  =>G_ACTIVE_DATE_FIRST_TYPE_TBL,
                 p_ACTIVE_DATE_SECOND      =>G_ACTIVE_DATE_SECOND_TBL,
                 p_ACTIVE_DATE_SECOND_TYPE =>G_ACTIVE_DATE_SECOND_TYPE_TBL,
                 p_LINE_QUANTITY =>     G_LINE_QUANTITY_TBL,
                 p_LINE_UOM_CODE =>     G_LINE_UOM_CODE_TBL,
                 p_REQUEST_TYPE_CODE => G_REQUEST_TYPE_CODE_TBL,
                 p_PRICED_QUANTITY =>   G_PRICED_QUANTITY_TBL,
                 p_PRICED_UOM_CODE =>   G_PRICED_UOM_CODE_TBL,
                 p_CURRENCY_CODE   =>   G_CURRENCY_CODE_TBL,
                 p_UNIT_PRICE      =>   G_UNIT_PRICE_TBL,
                 p_PERCENT_PRICE   =>   G_PERCENT_PRICE_TBL,
                 p_UOM_QUANTITY =>      G_UOM_QUANTITY_TBL,
                 p_ADJUSTED_UNIT_PRICE =>G_ADJUSTED_UNIT_PRICE_TBL,
                 p_UPD_ADJUSTED_UNIT_PRICE =>G_UPD_ADJUSTED_UNIT_PRICE_TBL,
                 p_PROCESSED_FLAG      =>G_PROCESSED_FLAG_TBL,
                 p_PRICE_FLAG          =>G_PRICE_FLAG_TBL,
                 p_LINE_ID             =>G_LINE_ID_TBL,
                 p_PROCESSING_ORDER    =>G_PROCESSING_ORDER_TBL,
                 p_PRICING_STATUS_CODE =>G_PRICING_STATUS_CODE_tbl,
                 p_PRICING_STATUS_TEXT =>G_PRICING_STATUS_TEXT_tbl,
                 p_ROUNDING_FLAG       =>G_ROUNDING_FLAG_TBL,
                 p_ROUNDING_FACTOR     =>G_ROUNDING_FACTOR_TBL,
                 p_QUALIFIERS_EXIST_FLAG => G_QUALIFIERS_EXIST_FLAG_TBL,
                 p_PRICING_ATTRS_EXIST_FLAG =>G_PRICING_ATTRS_EXIST_FLAG_TBL,
                 p_PRICE_LIST_ID          => G_PRICE_LIST_ID_TBL,
                 p_VALIDATED_FLAG         => G_PL_VALIDATED_FLAG_TBL,
                 p_PRICE_REQUEST_CODE     => G_PRICE_REQUEST_CODE_TBL,
                 p_USAGE_PRICING_TYPE  =>G_USAGE_PRICING_TYPE_tbl,
                 --mkothari 13-dec-2006
                 p_LIST_PRICE_OVERRIDE_FLAG =>G_LIST_PRICE_OVERRIDE_TBL,
--                 p_line_category       =>G_LINE_CATEGORY_tbl,
                 x_status_code         =>l_return_status_code,
                 x_status_text         =>l_price_return_msg);

   IF l_return_status_code <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ORDER_INSERT_ERR');
         FND_MSG_PUB.add;
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_PVT.debug_message(l_price_return_msg);
         END IF;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('After insert lines2' );
   END IF;



   -- Call qp price engine
   QP_PREQ_PUB.PRICE_REQUEST
       (p_control_rec        => l_control_rec,
        x_return_status      => l_return_status,
        x_return_status_text => l_msg_data);

   IF l_return_status = FND_API.g_ret_sts_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('in error'||l_msg_data);
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('in un'||l_msg_data);
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('After price_request' );
   END IF;
   -- Populate the result from the temp tables.
   -- We will be looking for adjusted_price and price adjustments
   -- with automatic_flag := 'Y' and accrual_flag := 'Y'  */

   -- Line table

   I:= 1;
   for line in  cl_lines_tmp
   LOOP
      xp_line_tbl(I).LINE_INDEX               := line.line_index;
      xp_line_tbl(I).LINE_ID               := line.line_id;
      xp_line_tbl(I).LINE_TYPE_CODE      := line.line_type_code;
      xp_line_tbl(I).PRICING_EFFECTIVE_DATE  := line.PRICING_EFFECTIVE_DATE;
      xp_line_tbl(I).ACTIVE_DATE_FIRST      := line.START_DATE_ACTIVE_FIRST;
      xp_line_tbl(I).ACTIVE_DATE_FIRST_TYPE  := line.ACTIVE_DATE_FIRST_TYPE;
      xp_line_tbl(I).ACTIVE_DATE_SECOND        := line.START_DATE_ACTIVE_SECOND;
      xp_line_tbl(I).ACTIVE_DATE_SECOND_TYPE := line.ACTIVE_DATE_SECOND_TYPE;
      xp_line_tbl(I).LINE_QUANTITY       := line.line_quantity;
      xp_line_tbl(I).LINE_UOM_CODE       := line.line_uom_code;
      xp_line_tbl(I).REQUEST_TYPE_CODE      := line.request_type_code;
      xp_line_tbl(I).PRICED_QUANTITY        := line.priced_quantity;
      xp_line_tbl(I).PRICED_UOM_CODE        := line.priced_uom_code;
      xp_line_tbl(I).CURRENCY_CODE       := line.currency_code;
      xp_line_tbl(I).UNIT_PRICE              := line.line_unit_price;
      xp_line_tbl(I).PERCENT_PRICE           := line.percent_price;
      xp_line_tbl(I).UOM_QUANTITY            := line.uom_quantity;
      xp_line_tbl(I).ADJUSTED_UNIT_PRICE     := line.ADJUSTED_UNIT_PRICE;
      xp_line_tbl(I).UPD_ADJUSTED_UNIT_PRICE := line.UPDATED_ADJUSTED_UNIT_PRICE;
      xp_line_tbl(I).PROCESSED_FLAG          := line.PROCESSED_FLAG;
      xp_line_tbl(I).PRICE_FLAG               := line.price_flag;
      --mkothari 13-dec-2006
      xp_line_tbl(I).LIST_PRICE_OVERRIDE_FLAG := line.LIST_PRICE_OVERRIDE_FLAG;
      xp_line_tbl(I).PROCESSING_ORDER        := line.PROCESSING_ORDER;
      xp_line_tbl(I).PRICING_STATUS_CODE     := line.PRICING_STATUS_CODE;
      xp_line_tbl(I).PRICING_STATUS_TEXT     := line.PRICING_STATUS_TEXT;
      xp_line_tbl(I).ROUNDING_FLAG           := line.ROUNDING_FLAG;
      xp_line_tbl(I).ROUNDING_FACTOR        := line.ROUNDING_FACTOR;
      xp_line_tbl(I).QUALIFIERS_EXIST_FLAG   := line.QUALIFIERS_EXIST_FLAG;
      xp_line_tbl(I).PRICING_ATTRS_EXIST_FLAG:= line.PRICING_ATTRS_EXIST_FLAG;
      xp_line_tbl(I).PRICE_LIST_ID            := line.price_list_header_id;
      xp_line_tbl(I).PL_VALIDATED_FLAG       := line.validated_flag;
      xp_line_tbl(I).PRICE_REQUEST_CODE       := line.price_request_code;
      xp_line_tbl(I).USAGE_PRICING_TYPE       := line.usage_pricing_type;
      xp_line_tbl(I).LINE_CATEGORY            := line.line_category;
      I:= I+1;
   END LOOP;

   I:=1;
   FOR ldets in cl_ldets_tmp
   LOOP
      x_ldets_tbl(I) := ldets;
      I:=I+1;
   END LOOP;

   I:=1;
   FOR rltd in cl_rltd_tmp
   LOOP
      x_related_lines_tbl(I) :=  rltd;
      I:= I+1;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data
   );
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_PVT.debug_message('end of order price');
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_Order_Price_pvt ;
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_Order_Price_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO Get_Order_Price_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Get_Order_Price;

---------------------------------------------------------------------
-- PROCEDURE
--    Purge_Pricing_Temp_table
--
-- PURPOSE
--    Purge Pricing Temporary tables
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Purge_Pricing_Temp_table (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
) is
l_api_name          CONSTANT VARCHAR2(30) := 'Purge_Pricing_Temp_table';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
Begin

   SAVEPOINT PURGE_PRICING_TEMP;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PURGE_PRICING_TEMP;
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PURGE_PRICING_TEMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO PURGE_PRICING_TEMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Purge_Pricing_Temp_table;
END OZF_ORDER_PRICE_PVT;

/
