--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_LINE_PVT" as
/* $Header: ozfvoalb.pls 120.8 2006/07/28 13:20:34 gramanat noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Line_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- Mon Dec 01 2003:7/36 PM RSSHARMA Added new procedure complete_rec_for_create to initialize list_line_id and
--    pricing_attribute_id of discount line rec to g_miss. In future all the creation specif initializations
--     should go here
-- Tue Dec 02 2003:1/49 PM  RSSHARMA Added new procedure populate_volume_offer to populate line items
-- for a volume offer from tiers table
-- Mon Mar 29 2004:2/1 PM RSSHARMA Fixed bug # 3439211. Corrected debug_message
--  Thu May 12 2005:3/47 PM RSSHARMA Fixed bug # 4354567.
--  Corrected debug_message. Corrected populating list_line_id , arithmetic_operator and operand
-- for multi-tier lines
-- Wed Jan 11 2006:8/25 PM  RSSHARMA Schriber fixes Fixed issue where user could not create an adjustmentline
-- if the td_discount was not entered.
-- 03/04/2006 rssharma Added discoutnEndDate column in call to insert_row and update_row
-- Mon May 22 2006:3/34 PM  RSSHARMA Fixed bug # 5239763. Fixed debug message.
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adj_Line_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'offvadjb.pls';
OZF_DEBUG_HIGH_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Offadj_Line_Items (
   p_offadj_line_rec IN  offadj_line_rec_type ,
   x_offadj_line_rec OUT NOCOPY offadj_line_rec_type
) ;

--=================================================================================
--  Fixed bug # 4354567. Fixed debug_message procedure. the procedure was calling itself
-- recursively withOUT any counter or exit condition. This put the procedure in an infinite loop
-- and made the transaction hang.
--====================================================================================
PROCEDURE debug_message(
                        p_message_text   IN  VARCHAR2
                        )
IS
BEGIN
IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message(p_message_text);
END IF;

END debug_message;

PROCEDURE populate_order_value_rec(p_list_line_rec IN offadj_new_line_rec_type,
                                   p_offadj_line_rec IN OUT NOCOPY offadj_line_rec_type )
IS
l_order_value_discount_type ozf_offers.order_value_discount_type%type;
 CURSOR cur_get_ov_discount_type(p_list_header_id NUMBER) IS
 SELECT order_value_discount_type
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;
  BEGIN
open cur_get_ov_discount_type(p_list_line_rec.list_header_id);
fetch cur_get_ov_discount_type into l_order_value_discount_type;
close cur_get_ov_discount_type;

    IF l_order_value_discount_type = 'DIS' THEN
      p_offadj_line_rec.arithmetic_operator      := '%';
      ELSIF l_order_value_discount_type = 'AMT' THEN
      p_offadj_line_rec.arithmetic_operator      := 'AMT';
    END IF;

END populate_order_value_rec;
/*
This method sets the default values for creating offer discount rules
*/
PROCEDURE complete_rec_for_create(
    p_modifier_line_rec IN OUT NOCOPY ozf_offer_pvt.Modifier_Line_Rec_Type
    )
    IS
    BEGIN
        p_modifier_line_rec.list_line_id := FND_API.g_miss_num;
        p_modifier_line_rec.pricing_attribute_id := FND_API.g_miss_num;
    END complete_rec_for_create;


PROCEDURE populate_volume_offer(p_list_line_rec  IN offadj_new_line_rec_type,
                                p_modifier_line_rec IN OUT NOCOPY ozf_offer_pvt.Modifier_Line_Rec_Type )
IS
  CURSOR c_tier_data (p_list_header_id NUMBER) IS
  SELECT discount , discount_type_code , uom_code , volume_type , tier_value_from , active,tier_value_to FROM ozf_volume_offer_tiers
  WHERE qp_list_header_id = p_list_header_id
       AND tier_value_from = (SELECT min(tier_value_from) FROM ozf_volume_offer_tiers WHERE qp_list_header_id = p_list_header_id ) ;

l_tier_data c_tier_data%rowtype;

BEGIN
debug_message('@Inside populate Volume Offer');
open c_tier_data(p_list_line_rec.list_header_id);
fetch c_tier_data into l_tier_data;
close c_tier_data;

p_modifier_line_rec.operand := l_tier_data.discount;
p_modifier_line_rec.arithmetic_operator := l_tier_data.discount_type_code;
p_modifier_line_rec.pricing_attr := l_tier_data.volume_type;
p_modifier_line_rec.pricing_attr_value_from := l_tier_data.tier_value_from;
p_modifier_line_rec.pricing_attr_value_to := l_tier_data.tier_value_to;
p_modifier_line_rec.product_uom_code := l_tier_data.uom_code;
debug_message('@UOmCode is '|| p_modifier_line_rec.product_uom_code);

END populate_volume_offer;


PROCEDURE populate_new_adj_rec(p_list_line_rec  IN offadj_new_line_rec_type,
                                p_modifier_line_rec IN OUT NOCOPY ozf_offer_pvt.Modifier_Line_Rec_Type )
IS
   CURSOR c_offer_type (p_list_header_id IN NUMBER) IS
        SELECT offer_type
         FROM ozf_offers
         WHERE qp_list_header_id = p_list_header_id;
    l_offer_type OZF_OFFERS.offer_type%type;
BEGIN
p_modifier_line_rec.LIST_HEADER_ID := p_list_line_rec.list_header_id;
p_modifier_line_rec.list_line_id := p_list_line_rec.list_line_id;
p_modifier_line_rec.LIST_LINE_TYPE_CODE := p_list_line_rec.list_line_type_code;
p_modifier_line_rec.OPERAND := p_list_line_rec.operand;
p_modifier_line_rec.ARITHMETIC_OPERATOR := p_list_line_rec.arithmetic_operator;
p_modifier_line_rec.INACTIVE_FLAG:= 'N';
p_modifier_line_rec.PRODUCT_ATTR := p_list_line_rec.product_attr;
p_modifier_line_rec.PRODUCT_ATTR_VAL := p_list_line_rec.product_attr_val;
p_modifier_line_rec.PRODUCT_UOM_CODE := p_list_line_rec.product_uom_code;

-- note pricing_attribute_id is necessary for updates on pricing_attributes
p_modifier_line_rec.pricing_attribute_id := p_list_line_rec.pricing_attribute_id;
p_modifier_line_rec.PRICING_ATTR := p_list_line_rec.pricing_attr;
p_modifier_line_rec.PRICING_ATTR_VALUE_FROM := p_list_line_rec.pricing_attr_value_from;
--p_modifier_line_rec.PRICING_ATTR_VALUE_TO := p_list_line_rec.pricing_attr_value_to;
p_modifier_line_rec.EXCLUDER_FLAG := 'N';

debug_message('list_line_id is '||p_modifier_line_rec.list_line_id);
debug_message('LIST_LINE_TYPE_CODE is '||p_modifier_line_rec.LIST_LINE_TYPE_CODE);
debug_message('OPERAND is '||p_modifier_line_rec.OPERAND);
debug_message('START_DATE_ACTIVE is '||p_modifier_line_rec.START_DATE_ACTIVE);
debug_message('ARITHMETIC_OPERATOR is '||p_modifier_line_rec.ARITHMETIC_OPERATOR);
debug_message('lsit header id is '||p_modifier_line_rec.list_header_id);
debug_message('pricing_attribute is '||p_modifier_line_rec.PRICING_ATTR );
debug_message('pricing_attribute_id is '||p_modifier_line_rec.pricing_attribute_id);
debug_message('pricing_attr_value_from is '||p_modifier_line_rec.PRICING_ATTR_VALUE_FROM );

/*debug_message('list_line_id is '||p_modifier_line_rec.list_line_id);
debug_message('list_line_id is '||p_modifier_line_rec.list_line_id);
*/


p_modifier_line_rec.ORDER_VALUE_FROM := p_list_line_rec.order_value_from;
p_modifier_line_rec.ORDER_VALUE_TO := p_list_line_rec.order_value_to;
p_modifier_line_rec.QUALIFIER_ID := p_list_line_rec.qualifier_id;


p_modifier_line_rec.QD_OPERAND:= Fnd_Api.g_miss_num;
p_modifier_line_rec.QD_ARITHMETIC_OPERATOR:= Fnd_Api.g_miss_char;
p_modifier_line_rec.QD_RELATED_DEAL_LINES_ID:= Fnd_Api.g_miss_num;
p_modifier_line_rec.QD_OBJECT_VERSION_NUMBER:= Fnd_Api.g_miss_num;
p_modifier_line_rec.QD_ESTIMATED_QTY_IS_MAX:= Fnd_Api.g_miss_char;
p_modifier_line_rec.QD_LIST_LINE_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.QD_ESTIMATED_AMOUNT_IS_MAX := Fnd_Api.g_miss_char;
p_modifier_line_rec.ESTIM_GL_VALUE := Fnd_Api.g_miss_num;
p_modifier_line_rec.BENEFIT_PRICE_LIST_LINE_ID := p_list_line_rec.BENEFIT_PRICE_LIST_LINE_ID;
p_modifier_line_rec.BENEFIT_LIMIT := Fnd_Api.g_miss_num;
p_modifier_line_rec.BENEFIT_QTY := p_list_line_rec.BENEFIT_QTY;
p_modifier_line_rec.BENEFIT_UOM_CODE := p_list_line_rec.BENEFIT_UOM_CODE;
p_modifier_line_rec.SUBSTITUTION_CONTEXT := Fnd_Api.g_miss_char;
p_modifier_line_rec.SUBSTITUTION_ATTR := Fnd_Api.g_miss_char;
p_modifier_line_rec.SUBSTITUTION_VAL := Fnd_Api.g_miss_char;
p_modifier_line_rec.PRICE_BREAK_TYPE_CODE := Fnd_Api.g_miss_char;
--p_modifier_line_rec.PRICING_ATTRIBUTE_ID:= Fnd_Api.g_miss_num;


p_modifier_line_rec.COMMENTS := Fnd_Api.g_miss_char;
p_modifier_line_rec.CONTEXT := p_list_line_rec.CONTEXT;
p_modifier_line_rec.ATTRIBUTE1 := p_list_line_rec.ATTRIBUTE1;
p_modifier_line_rec.ATTRIBUTE2 := p_list_line_rec.ATTRIBUTE2;
p_modifier_line_rec.ATTRIBUTE3 := p_list_line_rec.ATTRIBUTE3;
p_modifier_line_rec.ATTRIBUTE4 := p_list_line_rec.attribute4;
p_modifier_line_rec.ATTRIBUTE5 := p_list_line_rec.attribute5;
p_modifier_line_rec.ATTRIBUTE6 := p_list_line_rec.attribute6;
p_modifier_line_rec.ATTRIBUTE7 := p_list_line_rec.attribute7;
p_modifier_line_rec.ATTRIBUTE8 := p_list_line_rec.attribute8;
p_modifier_line_rec.ATTRIBUTE9 := p_list_line_rec.attribute9;
p_modifier_line_rec.ATTRIBUTE10:= p_list_line_rec.attribute10;
p_modifier_line_rec.ATTRIBUTE11:= p_list_line_rec.attribute11;
p_modifier_line_rec.ATTRIBUTE12:= p_list_line_rec.attribute12;
p_modifier_line_rec.ATTRIBUTE13:= p_list_line_rec.attribute13;
p_modifier_line_rec.ATTRIBUTE14:= p_list_line_rec.attribute14;
p_modifier_line_rec.ATTRIBUTE15:= p_list_line_rec.attribute15;
p_modifier_line_rec.MAX_QTY_PER_ORDER:= Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_QTY_PER_ORDER_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_QTY_PER_CUSTOMER := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_QTY_PER_CUSTOMER_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_QTY_PER_RULE := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_QTY_PER_RULE_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_ORDERS_PER_CUSTOMER := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_ORDERS_PER_CUSTOMER_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_AMOUNT_PER_RULE := Fnd_Api.g_miss_num;
p_modifier_line_rec.MAX_AMOUNT_PER_RULE_ID := Fnd_Api.g_miss_num;
p_modifier_line_rec.ESTIMATE_QTY_UOM := Fnd_Api.g_miss_char;
p_modifier_line_rec.generate_using_formula_id := FND_API.G_MISS_NUM;
p_modifier_line_rec.price_by_formula_id := FND_API.G_MISS_NUM;
p_modifier_line_rec.generate_using_formula := FND_API.G_MISS_CHAR;
p_modifier_line_rec.price_by_formula := FND_API.G_MISS_CHAR;

IF  p_list_line_rec.operation = 'CREATE' THEN
    complete_rec_for_create(p_modifier_line_rec => p_modifier_line_rec);
END IF;
open c_offer_type (p_list_line_rec.list_header_id);
fetch c_offer_type INTO l_offer_type;
close c_offer_type;

debug_message('@Offer Type is :'||l_offer_type );
IF l_offer_type = 'VOLUME_OFFER' THEN
populate_volume_offer(p_modifier_line_rec => p_modifier_line_rec
                                ,p_list_line_rec  => p_list_line_rec);
END IF;

END populate_new_adj_rec;




PROCEDURE populate_pro_good_get_rec(p_list_line_rec  IN offadj_new_line_rec_type,
                                p_modifier_line_rec IN OUT NOCOPY ozf_offer_pvt.Modifier_Line_Rec_Type )
IS
BEGIN
P_modifier_line_rec.list_line_type_code := 'DIS';
p_modifier_line_rec.list_line_id := FND_API.G_MISS_NUM;
p_modifier_line_rec.pricing_attribute_id  := FND_API.G_MISS_NUM;
p_modifier_line_rec.product_attr := 'PRICING_ATTRIBUTE1';
--              l_orec[i].arithmetic_operator = (String) getAPIParamValue(this, "arithmeticOperator",l_orec[i].arithmetic_operator);
END populate_pro_good_get_rec;

--=================================================================================
--  Fixed bug # 4354567. THe procedure was not populating arithmetic operator and operand properly
-- for Multi-tier offer lines, since the values are created in the background and not passed in
-- the record.. Corrected the procedure to query the values created in the background and then
-- populate the record
--====================================================================================
PROCEDURE populate_adj_rec(p_offadj_line_rec IN OUT NOCOPY offadj_line_rec_type ,p_list_line_rec IN offadj_new_line_rec_type)
IS
CURSOR c_operator(p_list_line_id number)IS
SELECT arithmetic_operator,operand,list_line_type_code FROM qp_list_lines
WHERE list_line_id = p_list_line_id;
l_operator c_operator%rowtype;
BEGIN
    p_offadj_line_rec.offer_adjustment_id := p_list_line_rec.offer_adjustment_id;

    p_offadj_line_rec.list_header_id := p_list_line_rec.list_header_id;
    p_offadj_line_rec.last_update_date := sysdate;
    p_offadj_line_rec.last_updated_by := 1;
    p_offadj_line_rec.creation_date := sysdate;
    p_offadj_line_rec.created_by := 1;
    p_offadj_line_rec.last_update_login := 1;
    p_offadj_line_rec.quantity := 1;
    p_offadj_line_rec.created_from_adjustments := 'Y';
    p_offadj_line_rec.object_version_number :=  p_list_line_rec.object_version_number;

/*open cur_get_ov_discount_type(p_list_line_rec.list_header_id);
fetch cur_get_ov_discount_type into l_order_value_discount_type;
close cur_get_ov_discount_type;
*/
debug_message('LIST_LINE_TYPE_CODE IS : '||p_list_line_rec.list_line_type_code);
IF p_list_line_rec.list_line_type_code = 'DIS' THEN
    p_offadj_line_rec.arithmetic_operator := p_list_line_rec.arithmetic_operator;
    p_offadj_line_rec.modified_discount := p_list_line_rec.operand;
    p_offadj_line_rec.original_discount := p_list_line_rec.operand-1;
ELSIF p_list_line_rec.list_line_type_code = 'PBH' THEN
    OPEN c_operator(p_offadj_line_rec.list_line_id);
        FETCH c_operator into l_operator;
        debug_message('ListLIneTypecode is '||l_operator.list_line_type_code||' : '|| 'operator is '||l_operator.arithmetic_operator);
        p_offadj_line_rec.arithmetic_operator := l_operator.arithmetic_operator;
        p_offadj_line_rec.modified_discount := l_operator.operand;
        p_offadj_line_rec.original_discount := l_operator.operand-1;
    CLOSE c_operator;
END IF;

END populate_adj_rec;


-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Offer_Adj_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_line_rec              IN   offadj_line_rec_type  := g_miss_offadj_line_rec,
    x_offer_adjustment_line_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Offer_Adj_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_adjustment_line_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ozf_offer_adjustment_lines_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_OFFER_ADJUSTMENT_LINES
      WHERE offer_adjustment_line_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_offer_adj_line_pvt;

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



      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Local variable initialization

   IF p_offadj_line_rec.offer_adjustment_line_id IS NULL OR p_offadj_line_rec.offer_adjustment_line_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_offer_adjustment_line_id;
         CLOSE c_id;
         debug_message('Inside line id null'||l_offer_adjustment_line_id);
         OPEN c_id_exists(l_offer_adjustment_line_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
     --   p_offadj_line_rec.offer_adjustment_line_id :=  l_offer_adjustment_line_id;
   ELSE
         l_offer_adjustment_line_id := p_offadj_line_rec.offer_adjustment_line_id;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      --IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      --THEN
          -- Debug message
          debug_message('Private API: Validate_Offer_Adj_Line');


          -- Invoke validation procedures
          Validate_offer_adj_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_offadj_line_rec  =>  p_offadj_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

      --END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      debug_message( 'Private API: Calling create table handler');


      -- Invoke table handler(Ozf_Offer_Adj_Line_Pkg.Insert_Row)
      Ozf_Offer_Adj_Line_Pkg.Insert_Row(
          px_offer_adjustment_line_id  => l_offer_adjustment_line_id,
          p_offer_adjustment_id  => p_offadj_line_rec.offer_adjustment_id,
          p_list_line_id  => p_offadj_line_rec.list_line_id,
          p_arithmetic_operator  => p_offadj_line_rec.arithmetic_operator,
          p_original_discount  => p_offadj_line_rec.original_discount,
          p_modified_discount  => p_offadj_line_rec.modified_discount,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_list_header_id  => p_offadj_line_rec.list_header_id,
          p_accrual_flag  => p_offadj_line_rec.accrual_flag,
          p_list_line_id_td  => p_offadj_line_rec.list_line_id_td,
          p_original_discount_td  => p_offadj_line_rec.original_discount_td,
          p_modified_discount_td  => p_offadj_line_rec.modified_discount_td,
          p_quantity => p_offadj_line_rec.quantity,
          p_created_from_adjustments => p_offadj_line_rec.created_from_adjustments,
          p_discount_end_date        => p_offadj_line_rec.discount_end_date
);

          x_offer_adjustment_line_id := l_offer_adjustment_line_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Offer_Adj_Line;


--=============================================================================
--  Fixed bug # 4354567. THe procedure was not populating list_line_id into properly into adjustment rec
-- list list_line_type_code = PBH ie. Multi-tier lines. The procedure was simply getting the first record in
-- the table of lines created and assigning the list_line_id to list_line_id in the adjustment rec.
-- changed the code to look at list_line_type_code = DIS before assigning the list_line_id to the adjustment rec
-- this works OK as only one DIS record is created. For multiple rec this cannot work since only one adjustment
-- line is created at a time
--======================================================================================
PROCEDURE Create_New_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

--    p_offadj_line_rec              IN   offadj_line_rec_type  := g_miss_offadj_line_rec,
    p_list_line_rec                IN   offadj_new_line_rec_type := g_miss_offadj_new_line_rec,
    x_offer_adjustment_line_id              OUT NOCOPY  NUMBER
     )
     IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_New_Offer_Adj_Line';
l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_adjustment_line_id  NUMBER;
   l_dummy                     NUMBER;
   l_offer_type                OZF_OFFERS.OFFER_TYPE%TYPE;
   l_error_loc NUMBER;
 l_modifier_line_tbl       ozf_offer_pvt.MODIFIER_LINE_TBL_TYPE;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 l_offadj_line_rec         offadj_line_rec_type ;

 i number := 1;
 l_tier_count number := 0;
 l_list_header_id NUMBER;
 l_override_flag VARCHAR2(1);
 l_accrual_flag VARCHAR2(1):= 'N';

   CURSOR c_offer_type (p_list_header_id IN NUMBER) IS
        SELECT offer_type
         FROM ozf_offers
         WHERE qp_list_header_id = p_list_header_id;

 CURSOR cur_get_ov_discount_type(p_list_header_id NUMBER) IS
 SELECT order_value_discount_type
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_new_offer_adj_line_pvt;

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



      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

--CREATE NEW LIST LINE IN QP
/*
INactive flag not working right now.
Ask Jun to open up automatic flag
*/
--===========================================================
--Populate record for Creating new LIne in QP
--===========================================================
l_modifier_line_tbl(i).operation := 'CREATE';
--l_modifier_line_tbl(i).list_line_id := Fnd_Api.g_miss_num
populate_new_adj_rec(p_modifier_line_rec => l_modifier_line_tbl(i)
                        , p_list_line_rec => p_list_line_rec);

open c_offer_type(p_list_line_rec.list_header_id);
fetch c_offer_type into l_offer_type;
close c_offer_type;

IF l_offer_type = 'ACCRUAL' THEN
 l_accrual_flag := 'Y';
 END IF;

--===============================================================
-- Populate values for promotional goods offer
--===============================================================
IF l_offer_type = 'OID' AND l_modifier_line_tbl(i).list_line_type_code = 'DIS' THEN
populate_pro_good_get_rec(p_modifier_line_rec => l_modifier_line_tbl(i)
                                ,p_list_line_rec  => p_list_line_rec);
END IF;


debug_message('Return status is '||x_return_status);

debug_message('Calling process qp list lines');

debug_message('list line type code : '|| l_modifier_line_tbl(i).list_line_type_code);
debug_message('list_line_id is : '||l_modifier_line_tbl(i).list_line_id);
debug_message('pricing attribute id is :'||l_modifier_line_tbl(i).pricing_attribute_id);
debug_message('product attr is :'||l_modifier_line_tbl(i).product_attr);
debug_message('benefit price list id is : '||l_modifier_line_tbl(i).BENEFIT_PRICE_LIST_LINE_ID);
debug_message('benefit qty is :'||l_modifier_line_tbl(i).BENEFIT_QTY );
debug_message('benefit uom code is :'||l_modifier_line_tbl(i).BENEFIT_UOM_CODE);
debug_message('uom code is :'||l_modifier_line_tbl(i).product_uom_code);
--================================================================
-- create discount rule in qp
--================================================================
ozf_offer_pvt.process_qp_list_lines(
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_offer_type           => l_offer_type,
        p_modifier_line_tbl    => l_modifier_line_tbl,
        p_list_header_id       => p_list_line_rec.list_header_id,
        x_modifier_line_tbl    => v_modifiers_tbl,
        x_error_location       => l_error_loc
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

debug_message('Return status is '||x_return_status);
-- create a new adjustment line in ozf_offer_adjustments with created from ADJUSTMENTS ='Y'
debug_message('returned table size is '||v_modifiers_tbl.count);
    FOR k IN v_modifiers_tbl.first..v_modifiers_tbl.last LOOP
    IF (v_modifiers_tbl(k).list_line_type_code = 'DIS') THEN
    debug_message('LINE : '|| k || ' list_line_id : '||v_modifiers_tbl(k).list_line_id || ' : '||v_modifiers_tbl(k).list_line_type_code);
    l_offadj_line_rec.list_line_id := v_modifiers_tbl(k).list_line_id;
    END IF;
    END LOOP;


--============================================================
-- populate adjustment record
--============================================================
    populate_adj_rec(p_offadj_line_rec => l_offadj_line_rec, p_list_line_rec => p_list_line_rec);

    l_offadj_line_rec.accrual_flag := l_accrual_flag;


   IF l_offer_type = 'ORDER' THEN
    populate_order_value_rec (p_list_line_rec => p_list_line_rec,
                                   p_offadj_line_rec => l_offadj_line_rec);
    END IF;


--update qp_list_lines set automatic_flag = 'N' where list_line_id = v_modifiers_tbl(1).list_line_id;

--===============================================================
-- create adjustment line
--===============================================================
Create_Offer_Adj_Line(
    p_api_version_number         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              =>x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_offadj_line_rec            => l_offadj_line_rec,
    x_offer_adjustment_line_id   => l_offer_adjustment_line_id
     );

debug_message('New Created adjustment line id is '||l_offer_adjustment_line_id);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_offer_adjustment_line_id   :=  l_offer_adjustment_line_id;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_UTILITY_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_new_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_New_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_New_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Create_New_Offer_Adj_Line;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offer_Adj_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_line_rec               IN    offadj_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_offer_adj_line(offer_adjustment_line_id NUMBER) IS
    SELECT *
    FROM  ozf_OFFER_ADJUSTMENT_LINES
    WHERE  offer_adjustment_line_id = p_offadj_line_rec.offer_adjustment_line_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offer_Adj_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_adjustment_line_id    NUMBER;
l_ref_offadj_line_rec  c_get_Offer_Adj_Line%ROWTYPE ;
l_tar_offadj_line_rec  offadj_line_rec_type := P_offadj_line_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_offer_adj_line_pvt;

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



      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Offer_Adj_Line( l_tar_offadj_line_rec.offer_adjustment_line_id);

      FETCH c_get_Offer_Adj_Line INTO l_ref_offadj_line_rec  ;

       If ( c_get_Offer_Adj_Line%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Adj_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Offer_Adj_Line;


      If (l_tar_offadj_line_rec.object_version_number is NULL or
          l_tar_offadj_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_offadj_line_rec.object_version_number <> l_ref_offadj_line_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Adj_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      --IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      --THEN
          -- Debug message
          debug_message('Private API: Validate_Offer_Adj_Line');

          -- Invoke validation procedures
          Validate_offer_adj_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_offadj_line_rec  =>  p_offadj_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      --END IF;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

                            -- assigned to obj.ver.num variable which is passed to Update_Row() -- sangara
      l_object_version_number := p_offadj_line_rec.object_version_number;

      -- Debug Message
      debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW || 'Private API: Calling update table handler');

-- Debug Message sangara
      -- debug_message('OFFER_ADJUSTMENT_LINE_ID:' || p_offadj_line_rec.offer_adjustment_line_id);

      -- Invoke table handler(Ozf_Offer_Adj_Line_Pkg.Update_Row)

     debug_message('b4 update off inv discount='||p_offadj_line_rec.modified_discount);
     debug_message('b4 update off acc discount='||p_offadj_line_rec.modified_discount_td);
     -- RAISE FND_API.G_EXC_ERROR;
      Ozf_Offer_Adj_Line_Pkg.Update_Row(
          p_offer_adjustment_line_id  => p_offadj_line_rec.offer_adjustment_line_id,
          p_offer_adjustment_id  => p_offadj_line_rec.offer_adjustment_id,
          p_list_line_id  => p_offadj_line_rec.list_line_id,
          p_arithmetic_operator  => p_offadj_line_rec.arithmetic_operator,
          p_original_discount  => p_offadj_line_rec.original_discount,
          p_modified_discount  => p_offadj_line_rec.modified_discount,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_list_header_id  => p_offadj_line_rec.list_header_id,
          p_accrual_flag  => p_offadj_line_rec.accrual_flag,
          p_list_line_id_td  => p_offadj_line_rec.list_line_id_td,
          p_original_discount_td  => p_offadj_line_rec.original_discount_td,
          p_modified_discount_td  => p_offadj_line_rec.modified_discount_td,
          p_quantity  => p_offadj_line_rec.quantity,
          p_created_from_adjustments => p_offadj_line_rec.created_from_adjustments,
          p_discount_end_date        => p_offadj_line_rec.discount_end_date
);
   x_object_version_number := l_object_version_number;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Offer_Adj_Line;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_New_Offer_Adj_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_line_rec            IN   offadj_new_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   Procedure updated discount lines created from adjustments.
--   These new Discount rules will be created in QP with end date active already passed ie. sysdate -1 so that the rule is not active
--   additionally for further safety the lines will be created with automatic flag = 'N'
--   Since there is some diffeculty in making updates to qp_list_lines when automatic_flag = 'N'
--   the API first updates the line and makes automatic_flag = 'Y', then executes the updates. then again makes automatic_flag = 'N'
--   when the adjustment goes active the Adjustment line is made automatic.
--   ==============================================================================

PROCEDURE Update_New_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

--    p_offadj_line_rec               IN    offadj_line_rec_type,
    p_list_line_rec                 IN    offadj_new_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )
    IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Update_New_Offer_Adj_Line';
l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_adjustment_line_id  NUMBER;
   l_dummy                     NUMBER;
   l_offer_type                OZF_OFFERS.OFFER_TYPE%TYPE;
   l_error_loc NUMBER;

l_modifier_line_tbl       ozf_offer_pvt.MODIFIER_LINE_TBL_TYPE;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
l_offadj_line_rec         offadj_line_rec_type ;

 i number := 1;
 l_tier_count number := 0;
 l_list_header_id NUMBER;
 l_override_flag VARCHAR2(1);
 l_accrual_flag VARCHAR2(1):= 'N';

   CURSOR c_offer_type (p_list_header_id IN NUMBER) IS
        SELECT offer_type
         FROM ozf_offers
         WHERE qp_list_header_id = p_list_header_id;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_new_offer_adj_line_pvt;

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

      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

--UPDATE LIST LINE IN QP
/*
INactive flag not working right now.
Ask Jun to open up automatic flag
*/
--======================================================================
-- populate record for creating discount line in qp
--======================================================================
l_modifier_line_tbl(i).operation := 'UPDATE';

populate_new_adj_rec(p_modifier_line_rec => l_modifier_line_tbl(i)
                        , p_list_line_rec => p_list_line_rec);
open c_offer_type(p_list_line_rec.list_header_id);
fetch c_offer_type into l_offer_type;
close c_offer_type;

IF l_offer_type = 'ACCRUAL' THEN
 l_accrual_flag := 'Y';
 END IF;

/*
Update qp_list_lines with the entered information
*/
-- flipping automatic flag to active coz the update does not go thru, if the automatic fLAG is N
--update qp_list_lines set automatic_flag = 'Y' where list_line_id = p_list_line_rec.list_line_id;

debug_message('Calling process qp_list lines');

--==========================================================================
-- create discount rule in qp
--==========================================================================
ozf_offer_pvt.process_qp_list_lines(
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_offer_type           => l_offer_type,
        p_modifier_line_tbl    => l_modifier_line_tbl,
        p_list_header_id       => p_list_line_rec.list_header_id,
        x_modifier_line_tbl    => v_modifiers_tbl,
        x_error_location       => l_error_loc
      );

--                RAISE FND_API.G_EXC_ERROR;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- flipping automatic flag back to N
--update qp_list_lines set automatic_flag = 'N' where list_line_id = p_list_line_rec.list_line_id;


-- create a new adjustment line in ozf_offer_adjustments with created from ADJUSTMENTS ='Y'

/*
update adjustment_lines with entered information
*/
-- initialize update recird
--==========================================================================
-- populate adjustment record
--==========================================================================
    l_offadj_line_rec.list_line_id := p_list_line_rec.list_line_id;
    l_offadj_line_rec.offer_adjustment_line_id := p_list_line_rec.offer_adjustment_line_id;

    populate_adj_rec(p_offadj_line_rec => l_offadj_line_rec,p_list_line_rec => p_list_line_rec);

    l_offadj_line_rec.accrual_flag := l_accrual_flag;

--============================================================================
-- Populate order valie records
--============================================================================
    IF l_offer_type = 'ORDER' THEN
    debug_message('CALLING populate order value rec');
    populate_order_value_rec (p_list_line_rec => p_list_line_rec,
                                   p_offadj_line_rec => l_offadj_line_rec);
    END IF;

--============================================================================
-- update qp list line
--============================================================================
-- call update api
Update_Offer_Adj_Line(
    p_api_version_number         => 1.0 ,
    p_init_msg_list              => FND_API.G_TRUE,
    p_commit                     => FND_API.G_FALSE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_offadj_line_rec            =>l_offadj_line_rec,
    x_object_version_number   => l_object_version_number
     );
--    l_offadj_line_rec.created_from_adjustments := 'Y';

--update qp_list_lines set automatic_flag = 'N' where list_line_id = v_modifiers_tbl(1).list_line_id;

debug_message('Updated adjustment line id is '||l_offer_adjustment_line_id);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_UTILITY_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_new_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_New_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_New_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    END;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_Adj_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_adjustment_line_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adjustment_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offer_Adj_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_offer_adj_line_pvt;

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



      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ozf_Offer_Adj_Line_Pkg.Delete_Row)
      Ozf_Offer_Adj_Line_Pkg.Delete_Row(
          p_offer_adjustment_line_id  => p_offer_adjustment_line_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Offer_Adj_Line;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Offer_Adj_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjustment_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offer_Adj_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_offer_adjustment_line_id                  NUMBER;

BEGIN

      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
OZF_Offer_Adj_Line_PKG.Lock_Row(l_offer_adjustment_line_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offer_Adj_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Offer_Adj_Line;




PROCEDURE check_Offadj_Line_Uk_Items(
    p_offadj_line_rec               IN   offadj_line_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      --   l_valid_flag := OZF_Utility_PVT.check_uniqueness(
      --  'ozf_offer_adjustment_lines',
      --   'offer_adjustment_line_id = ''' || p_offadj_line_rec.offer_adjustment_line_id ||''''
      --   );
        l_valid_flag := FND_API.g_true;
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_offer_adjustment_lines',
         'offer_adjustment_line_id = ''' || p_offadj_line_rec.offer_adjustment_line_id ||
         ''' AND offer_adjustment_line_id <> ' || p_offadj_line_rec.offer_adjustment_line_id
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_ADJ_LINE_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Offadj_Line_Uk_Items;


PROCEDURE check_offadj_inter_attr
(
    p_offadj_line_rec               IN  offadj_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
BEGIN
IF (
    p_offadj_line_rec.modified_discount IS NOT NULL AND p_offadj_line_rec.modified_discount <> FND_API.G_MISS_NUM
    )
    AND
    (
    p_offadj_line_rec.original_discount IS NOT NULL AND p_offadj_line_rec.original_discount <> FND_API.G_MISS_NUM
    )
THEN
    IF
    (p_offadj_line_rec.original_discount < 0 AND p_offadj_line_rec.modified_discount > 0)
    OR
    (p_offadj_line_rec.original_discount > 0 AND p_offadj_line_rec.modified_discount < 0)
    THEN
                OZF_Utility_PVT.Error_Message('OZF_OFFADJ_DISC_DIFF');
                x_return_status := FND_API.g_ret_sts_error;
                return;
    END IF;
END IF;
IF (
    p_offadj_line_rec.modified_discount_td IS NOT NULL AND p_offadj_line_rec.modified_discount_td <> FND_API.G_MISS_NUM
    )
    AND
    (
    p_offadj_line_rec.original_discount_td IS NOT NULL AND p_offadj_line_rec.original_discount_td <> FND_API.G_MISS_NUM
    )
THEN
    IF
    (p_offadj_line_rec.original_discount_td < 0 AND p_offadj_line_rec.modified_discount_td > 0)
    OR
    (p_offadj_line_rec.original_discount_td > 0 AND p_offadj_line_rec.modified_discount_td < 0)
    THEN
                OZF_Utility_PVT.Error_Message('OZF_OFFADJ_DISC_DIFF');
                x_return_status := FND_API.g_ret_sts_error;
                return;
    END IF;
END IF;


END check_offadj_inter_attr;

PROCEDURE check_Offadj_Line_Req_Items(
    p_offadj_line_rec               IN  offadj_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
CURSOR c_offer_type(p_list_header_id NUMBER) is
SELECT offer_type from ozf_offers where qp_list_header_id = p_list_header_id;

CURSOR c_list_line_type_Code(p_list_line_id NUMBER) is
select list_line_type_code from qp_list_lines where list_line_id = p_list_line_id;

l_list_line_type_code qp_list_lines.list_line_type_code%type;
l_offer_type ozf_offers.offer_type%type;

BEGIN

open c_offer_type(p_offadj_line_rec.list_header_id);
fetch c_offer_type into l_offer_type;
close c_offer_type;

open c_list_line_type_code(p_offadj_line_rec.list_line_id);
fetch c_list_line_type_code into l_list_line_type_code;
close c_list_line_type_code;


debug_message('OfferType is '||l_offer_type);
   x_return_status := FND_API.g_ret_sts_success;

OZF_Offer_Adj_Line_PVT.debug_message('ValidationMOde is '||p_validation_mode || ' : '||JTF_PLSQL_API.g_create);
IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_offadj_line_rec.offer_adjustment_id = FND_API.G_MISS_NUM OR p_offadj_line_rec.offer_adjustment_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
      IF p_offadj_line_rec.list_line_id = FND_API.G_MISS_NUM OR p_offadj_line_rec.list_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
      IF p_offadj_line_rec.list_header_id = FND_API.G_MISS_NUM OR p_offadj_line_rec.list_header_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
    debug_message('MOdified discount:' ||p_offadj_line_rec.modified_discount);

    IF (l_offer_type = 'OID'  AND l_list_line_type_code <> 'DIS') THEN
    debug_message('Promotional Goods buy:  offer type' ||l_offer_type||' list line type code: '|| l_list_line_type_code);
    ELSIF l_offer_type = 'DEAL' THEN
    IF  (p_offadj_line_rec.modified_discount = FND_API.G_MISS_NUM OR p_offadj_line_rec.modified_discount IS NULL)
        AND
        (p_offadj_line_rec.modified_discount_td = FND_API.G_MISS_NUM OR p_offadj_line_rec.modified_discount_td IS NULL)
    THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT/MODIFIED_DISCOUNT_TD' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
    END IF;
          IF (p_offadj_line_rec.original_discount IS NULL OR p_offadj_line_rec.original_discount = FND_API.G_MISS_NUM )
              AND
             (p_offadj_line_rec.original_discount_td IS NULL OR p_offadj_line_rec.original_discount_td = FND_API.G_MISS_NUM)

          THEN
                  OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','ORIGINAL_DISCOUNT/ORIGINAL_DISCOUNT_TD');
                  x_return_status := FND_API.g_ret_sts_error;
                  return;
          END IF;
    ELSE
/*          IF p_offadj_line_rec.quantity = FND_API.G_MISS_NUM OR p_offadj_line_rec.quantity IS NULL THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'Quantity' );
              --     x_return_status := FND_API.g_ret_sts_error;
          END IF;
*/
    debug_message('MOdified discount:' ||p_offadj_line_rec.modified_discount);
          IF p_offadj_line_rec.modified_discount = FND_API.G_MISS_NUM OR p_offadj_line_rec.modified_discount IS NULL THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
            END IF;
          IF p_offadj_line_rec.original_discount IS NULL OR p_offadj_line_rec.original_discount = FND_API.G_MISS_NUM THEN
                  OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','ORIGINAL_DISCOUNT');
                  x_return_status := FND_API.g_ret_sts_error;
                  return;
          END IF;
    END IF;

ELSE
      IF p_offadj_line_rec.offer_adjustment_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_offadj_line_rec.offer_adjustment_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_offadj_line_rec.list_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_offadj_line_rec.list_header_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

    IF (l_offer_type = 'OID'  AND l_list_line_type_code <> 'DIS') THEN
    debug_message('Promotional Goods buy:  offer type' ||l_offer_type||' list line type code: '|| l_list_line_type_code);
    ELSIF l_offer_type = 'DEAL' THEN
    IF  (p_offadj_line_rec.modified_discount = FND_API.G_MISS_NUM )
        AND
        (p_offadj_line_rec.modified_discount_td = FND_API.G_MISS_NUM )
    THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT/MODIFIED_DISCOUNT_TD' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
    END IF;
          IF ( p_offadj_line_rec.original_discount = FND_API.G_MISS_NUM )
              AND
             (p_offadj_line_rec.original_discount_td = FND_API.G_MISS_NUM)
          THEN
                  OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','ORIGINAL_DISCOUNT/ORIGINAL_DISCOUNT_TD');
                  x_return_status := FND_API.g_ret_sts_error;
                  return;
          END IF;
    ELSE
    debug_message('MOdified discount:' ||p_offadj_line_rec.modified_discount);
          IF p_offadj_line_rec.modified_discount = FND_API.G_MISS_NUM OR p_offadj_line_rec.modified_discount IS NULL THEN
                  IF p_offadj_line_rec.modified_discount_td = FND_API.G_MISS_NUM OR p_offadj_line_rec.modified_discount_td IS NULL THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT');
                   x_return_status := FND_API.g_ret_sts_error;
            END IF;
    debug_message('Original discount:' ||p_offadj_line_rec.original_discount);
          IF p_offadj_line_rec.original_discount IS NULL OR p_offadj_line_rec.original_discount = FND_API.G_MISS_NUM THEN
                  OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','original_discount');
                  x_return_status := FND_API.g_ret_sts_error;
                  return;
          END IF;

    END IF;
END IF;
END IF;

END check_Offadj_Line_Req_Items;



PROCEDURE check_Offadj_Line_Fk_Items(
    p_offadj_line_rec IN offadj_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offadj_Line_Fk_Items;



PROCEDURE check_Offadj_Line_Lookup_Items(
    p_offadj_line_rec IN offadj_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offadj_Line_Lookup_Items;



PROCEDURE Check_Offadj_Line_Items (
    P_offadj_line_rec     IN    offadj_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
debug_message('inside check offadj line Req items');
   check_offadj_line_req_items(
      p_offadj_line_rec => p_offadj_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Uniqueness API calls

debug_message('inside check offadj line Uk items');
   check_Offadj_line_Uk_Items(
      p_offadj_line_rec => p_offadj_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   -- Check Items Foreign Keys API calls

debug_message('inside check offadj line Fk items');
   check_offadj_line_FK_items(
      p_offadj_line_rec => p_offadj_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Lookups
debug_message('inside check offadj line LkUP items');
   check_offadj_line_Lookup_items(
      p_offadj_line_rec => p_offadj_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

check_offadj_inter_attr
(
      p_offadj_line_rec => p_offadj_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

   x_return_status := l_return_status;

END Check_offadj_line_Items;





PROCEDURE Complete_Offadj_Line_Rec (
   p_offadj_line_rec IN offadj_line_rec_type,
   x_complete_rec OUT NOCOPY offadj_line_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adjustment_lines
      WHERE offer_adjustment_line_id = p_offadj_line_rec.offer_adjustment_line_id and offer_adjustment_id = p_offadj_line_rec.offer_adjustment_id;

   l_offadj_line_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offadj_line_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_offadj_line_rec;
   CLOSE c_complete;

   -- offer_adjustment_line_id
   IF p_offadj_line_rec.offer_adjustment_line_id IS NULL THEN
      x_complete_rec.offer_adjustment_line_id := l_offadj_line_rec.offer_adjustment_line_id;
   END IF;

   -- offer_adjustment_id
   IF p_offadj_line_rec.offer_adjustment_id IS NULL THEN
      x_complete_rec.offer_adjustment_id := l_offadj_line_rec.offer_adjustment_id;
   END IF;

   -- list_line_id
   IF p_offadj_line_rec.list_line_id IS NULL THEN
      x_complete_rec.list_line_id := l_offadj_line_rec.list_line_id;
   END IF;

   -- arithmetic_operator
   IF p_offadj_line_rec.arithmetic_operator IS NULL THEN
      x_complete_rec.arithmetic_operator := l_offadj_line_rec.arithmetic_operator;
   END IF;

   -- original_discount
   IF p_offadj_line_rec.original_discount IS NULL THEN
      x_complete_rec.original_discount := l_offadj_line_rec.original_discount;
   END IF;

   -- modified_discount
  -- IF p_offadj_line_rec.modified_discount IS NULL THEN
    --  x_complete_rec.modified_discount := l_offadj_line_rec.modified_discount;
  -- END IF;

   -- last_update_date
   IF p_offadj_line_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_offadj_line_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offadj_line_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_offadj_line_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offadj_line_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_offadj_line_rec.creation_date;
   END IF;

   -- created_by
   IF p_offadj_line_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_offadj_line_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offadj_line_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_offadj_line_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offadj_line_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_offadj_line_rec.object_version_number;
   END IF;

   -- list_header_id
   IF p_offadj_line_rec.list_header_id IS NULL THEN
      x_complete_rec.list_header_id := l_offadj_line_rec.list_header_id;
   END IF;

   -- accrual_flag
   IF p_offadj_line_rec.accrual_flag IS NULL THEN
      x_complete_rec.accrual_flag := l_offadj_line_rec.accrual_flag;
   END IF;

   -- list_line_id_td
   IF p_offadj_line_rec.list_line_id_td IS NULL THEN
      x_complete_rec.list_line_id_td := l_offadj_line_rec.list_line_id_td;
   END IF;

   -- original_discount_td
   IF p_offadj_line_rec.original_discount_td IS NULL THEN
      x_complete_rec.original_discount_td := l_offadj_line_rec.original_discount_td;
   END IF;

   -- modified_discount_td
  -- IF p_offadj_line_rec.modified_discount_td IS NULL THEN
    --  x_complete_rec.modified_discount_td := l_offadj_line_rec.modified_discount_td;
  -- END IF;

   -- quantity
   IF p_offadj_line_rec.quantity IS NULL THEN
      x_complete_rec.quantity := l_offadj_line_rec.quantity;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Offadj_Line_Rec;




PROCEDURE Default_Offadj_Line_Items ( p_offadj_line_rec IN offadj_line_rec_type ,
                                x_offadj_line_rec OUT NOCOPY offadj_line_rec_type )
IS
   l_offadj_line_rec offadj_line_rec_type := p_offadj_line_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
    x_offadj_line_rec.offer_adjustment_line_id :=  p_offadj_line_rec.offer_adjustment_line_id;
    x_offadj_line_rec.offer_adjustment_id      :=  p_offadj_line_rec.offer_adjustment_id;
    x_offadj_line_rec.list_line_id             :=  p_offadj_line_rec.list_line_id;
    x_offadj_line_rec.arithmetic_operator      :=  p_offadj_line_rec.arithmetic_operator;
    x_offadj_line_rec.original_discount        :=  p_offadj_line_rec.original_discount;
    x_offadj_line_rec.modified_discount        :=  p_offadj_line_rec.modified_discount;
    x_offadj_line_rec.last_update_date         :=  p_offadj_line_rec.last_update_date;
    x_offadj_line_rec.last_updated_by          :=  p_offadj_line_rec.last_updated_by;
    x_offadj_line_rec.creation_date            :=  p_offadj_line_rec.creation_date;
    x_offadj_line_rec.created_by               :=  p_offadj_line_rec.created_by;
    x_offadj_line_rec.last_update_login        :=  p_offadj_line_rec.last_update_login;
    x_offadj_line_rec.object_version_number    :=  p_offadj_line_rec.object_version_number;
    x_offadj_line_rec.list_header_id           :=  p_offadj_line_rec.list_header_id;
    x_offadj_line_rec.accrual_flag             :=  p_offadj_line_rec.accrual_flag;
    x_offadj_line_rec.list_line_id_td          :=  p_offadj_line_rec.list_line_id_td;
    x_offadj_line_rec.original_discount_td     :=  p_offadj_line_rec.original_discount_td;
    x_offadj_line_rec.modified_discount_td     :=  p_offadj_line_rec.modified_discount_td;
    x_offadj_line_rec.quantity           :=  p_offadj_line_rec.quantity;
   NULL ;
END;




PROCEDURE Validate_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offadj_line_rec               IN   offadj_line_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offer_Adj_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offadj_line_rec  offadj_line_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_offer_adj_line_;

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

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_offadj_line_Items(
                 p_offadj_line_rec        => p_offadj_line_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Offadj_Line_Items (p_offadj_line_rec => p_offadj_line_rec ,
                                x_offadj_line_rec => l_offadj_line_rec) ;
      END IF ;


      Complete_offadj_line_Rec(
         p_offadj_line_rec     => p_offadj_line_rec,
         x_complete_rec        => l_offadj_line_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offadj_line_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offadj_line_rec           =>    l_offadj_line_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Line_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Offer_Adj_Line;


PROCEDURE Validate_Offadj_Line_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offadj_line_rec               IN    offadj_line_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offadj_line_Rec;

FUNCTION get_price_list_name(p_list_line_id IN NUMBER)
RETURN VARCHAR2
IS
l_price_list_name qp_list_headers_tl.name%type;
        cursor c_price_list_name(p_list_line_id IN NUMBER) IS
        SELECT name FROM qp_list_headers_vl
        WHERE list_header_id = (SELECT list_header_id FROM qp_list_lines WHERE list_line_id = p_list_line_id);
BEGIN
        OPEN c_price_list_name(p_list_line_id);
        FETCH c_price_list_name INTO l_price_list_name;
        CLOSE c_price_list_name;
        return l_price_list_name;
END  ;

END OZF_Offer_Adj_Line_PVT;

/
