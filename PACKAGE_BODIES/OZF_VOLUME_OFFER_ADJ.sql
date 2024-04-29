--------------------------------------------------------
--  DDL for Package Body OZF_VOLUME_OFFER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOLUME_OFFER_ADJ" AS
/* $Header: ozfvvadb.pls 120.7 2006/08/16 01:25:20 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_VOLUME_OFFER_ADJ
-- Purpose
--
-- History
--  Tue Mar 14 2006:4/33 PM RSSHARMA Created
-- Mon Apr 03 2006:1/27 PM  RSSHARMA Fixed end date Query for end dating lines
-- Tue Aug 15 2006:3/26 PM RSSHARMA Fixed bug # 5468261. Fixed query in populate_dis_lines, to outer join qp_rltd_deal_lines
-- with ozf_qp_discounts. The default tier for price breaks starting with "0" does not correspong to any ozf_qp_discount.
-- This outer join will enable selection of the default tier starting with "0".
-- Tue Aug 15 2006:6/17 PM  RSSHARMA Contd # 5468261 fixes. Changed order of calling zero discounts. Also DO not create
-- relations for default line.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE update_vo_tier
(
  x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerDiscountLineId IN NUMBER
  , p_offerAdjustmentId IN NUMBER
)
IS
l_vo_disc_rec OZF_Volume_Offer_disc_PVT.vo_disc_rec_type;
CURSOR c_discountLine(cp_offerDiscountLineId NUMBER, cp_offerAdjustmentId NUMBER) IS
SELECT a.object_version_number
, a.offer_id
, a.parent_discount_line_id
, b.modified_discount
FROM ozf_offer_discount_lines a, ozf_offer_adjustment_tiers b
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.offer_discount_line_id = cp_offerDiscountLineId
AND b.offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
/*
initialize return rec
initialize record
populate the record
update VO discount tiers
*/
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_discountLine IN c_discountLine(cp_offerDiscountLineId => p_offerDiscountLineId , cp_offerAdjustmentId => p_offerAdjustmentId )
LOOP
    l_vo_disc_rec := null;
    l_vo_disc_rec.offer_discount_line_id := p_offerDiscountLineId;
    l_vo_disc_rec.offer_id := l_discountLine.offer_id;
    l_vo_disc_rec.object_version_number := l_discountLine.object_version_number;
    l_vo_disc_rec.discount              := l_discountLine.modified_discount;
END LOOP;
OZF_Volume_Offer_disc_PVT.Update_vo_discount(
    p_api_version_number         => 1.0
    , p_init_msg_list            => FND_API.G_FALSE
    , p_commit                   => FND_API.G_FALSE
    , p_validation_level         => FND_API.G_VALID_LEVEL_FULL
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    , p_vo_disc_rec              => l_vo_disc_rec
);
END update_vo_tier;

PROCEDURE update_adj_vo_tiers
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjustmentTiers(cp_offerAdjustmentId NUMBER)
IS
SELECT offer_discount_line_id
FROM ozf_offer_adjustment_tiers
WHERE offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
-- initialize return status
-- loop thru. all adjustment tiers
-- for each adjustment tier update the discount line and handle exception
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_adjustmentTiers IN c_adjustmentTiers(cp_offerAdjustmentId => p_offerAdjustmentId)
    LOOP
        update_vo_tier
        (
          x_return_status          => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_offerDiscountLineId   => l_adjustmentTiers.offer_discount_line_id
          , p_offerAdjustmentId     => p_offerAdjustmentId
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END update_adj_vo_tiers;

PROCEDURE end_qp_line
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_listLineId           IN NUMBER
  ,p_offerAdjustmentId     IN NUMBER
)
IS
CURSOR c_listLines(cp_listLineId NUMBER)
IS
SELECT list_line_id, list_header_id , list_line_type_code, price_break_type_code
FROM qp_list_lines
WHERE list_line_id = cp_listLineId;
/*
Cursor works fine but the implementation is not satisfying, need to relook into the end date query
*/
CURSOR c_endDate(cp_offerAdjustmentId NUMBER , cp_listLineId NUMBER)
IS
SELECT
decode(c.start_date_active
                            , null
                            , decode(d.start_date_active, null, a.effective_date -1 , decode(greatest(d.start_date_active,a.effective_date - 1) , d.start_date_active, d.start_date_active, a.effective_date -1 ))
                            , decode(greatest(c.start_date_active, a.effective_date -1 ), c.start_date_active , c.start_date_active ,a.effective_date - 1)
        ) endDate
--greatest(nvl(d.start_date_active, a.effective_date - 5 ),nvl(d.start_date_active, a.effective_date - 5 ), a.effective_date - 1 )  endDate
, b.offer_type, b.qp_list_header_id
, c.start_date_active lineStartDate, d.start_date_active headerStartDate
FROM ozf_offer_adjustments_b  a, ozf_offers b , qp_list_lines c , qp_list_headers_b d
WHERE
a.list_header_id = b.qp_list_header_id
AND b.qp_list_header_id = c.list_header_id
AND c.list_header_id = d.list_header_id
AND offer_adjustment_id = cp_offerAdjustmentId
AND c.list_line_id      = cp_listLineId;
l_endDate c_endDate%ROWTYPE;

x_modifier_line_tbl     qp_modifiers_pub.modifiers_tbl_type;
l_modifier_line_tbl     qp_modifiers_pub.Modifiers_Tbl_Type;
l_errorLoc NUMBER;
V_MODIFIER_LIST_rec             QP_MODIFIERS_PUB.Modifier_List_Rec_Type;
V_MODIFIER_LIST_val_rec         QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type;
V_MODIFIERS_tbl                 QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
V_MODIFIERS_val_tbl             QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type;
V_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
V_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
V_PRICING_ATTR_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
V_PRICING_ATTR_val_tbl          QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- retrieve end_date into local record
-- initialize record
-- populate record
-- call process_qp_list_lines
--l_modifier_line_tbl.delete;
OPEN c_endDate(cp_offerAdjustmentId => p_offerAdjustmentId , cp_listLineId => p_listLineId);
    FETCH c_endDate INTO l_endDate;
CLOSE c_endDate;
ozf_utility_pvt.debug_message('Dates are:end Date:'||l_endDate.endDate||':header start date:'||l_endDate.headerStartDate||':lineStartDate:'||l_endDate.lineStartDate);
FOR l_listLines IN c_listLines(cp_listLineId => p_listLineId)
LOOP

    l_modifier_line_tbl(1).list_line_id         := p_listLineId;
    l_modifier_line_tbl(1).end_date_active      := l_endDate.endDate;
    l_modifier_line_tbl(1).operation            := QP_GLOBALS.G_OPR_UPDATE;
    l_modifier_line_tbl(1).list_line_type_code  := l_listLines.list_line_type_code;
    l_modifier_line_tbl(1).price_break_type_code:= l_listLines.price_break_type_code;
END LOOP;
   QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifier_line_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
END end_qp_line;

PROCEDURE end_date_qp_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_qpListLines(cp_offerAdjustmentId NUMBER)
IS
SELECT distinct parent_discount_line_id , c.list_line_id
FROM ozf_offer_adjustment_tiers a, ozf_offer_discount_lines b , ozf_qp_discounts c
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.parent_discount_line_id = c.offer_discount_line_id
AND a.offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_qpListLines IN c_qpListLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
end_qp_line
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_listLineId            => l_qpListLines.list_line_id
  ,p_offerAdjustmentId     => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END LOOP;
END end_date_qp_lines;




PROCEDURE populate_discounts
(
 x_modifiers_rec  IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
, p_list_line_id  IN NUMBER
)
IS
CURSOR c_discounts(cp_listLineId NUMBER) IS
SELECT
c.list_header_id
, c.arithmetic_operator
, c.operand
, c.list_line_id
, c.print_on_invoice_flag
, c.accrual_flag
, c.pricing_phase_id
, c.pricing_group_sequence
, c.incompatibility_grp_code
, c.product_precedence
, c.generate_using_formula_id
, c.price_by_formula_id
, c.context
, c.attribute1
, c.attribute2
, c.attribute3
, c.attribute4
, c.attribute5
, c.attribute6
, c.attribute7
, c.attribute8
, c.attribute9
, c.attribute10
, c.attribute11
, c.attribute12
, c.attribute13
, c.attribute14
, c.attribute15
, c.proration_type_code
, c.qualification_ind
, c.modifier_level_code
, c.automatic_flag
, c.override_flag
, c.price_break_type_code
, c.benefit_qty
, c.benefit_uom_code
, c.benefit_price_list_line_id
--, accum_context
, accum_attribute
--, accum_attr_run_src_flag
, list_line_type_code
FROM
qp_list_lines c
WHERE c.list_line_id = cp_listLineId;
i NUMBER := null;
l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;
BEGIN
--dbms_output.put_line('listLIneId1 is :'||p_list_line_id);
FOR l_discounts in c_discounts(cp_listLineId => p_list_line_id) LOOP
x_modifiers_rec.list_header_id := l_discounts.list_header_id;
x_modifiers_rec.list_line_type_code := l_discounts.list_line_type_code;
x_modifiers_rec.end_date_active := null;
x_modifiers_rec.arithmetic_operator := l_discounts.arithmetic_operator;
--dbms_output.put_line('arithmetic operator1 is :'||x_modifiers_rec.arithmetic_operator||' : '||l_discounts.arithmetic_operator);
x_modifiers_rec.price_break_type_code   := l_discounts.price_break_type_code;
--dbms_output.put_line('Price break type code is :'||x_modifiers_rec.price_break_type_code||' : '||l_discounts.price_break_type_code);
----------------------advanced options---------------------------------
x_modifiers_rec.print_on_invoice_flag    := l_discounts.print_on_invoice_flag;
x_modifiers_rec.accrual_flag             := l_discounts.accrual_flag;
x_modifiers_rec.pricing_phase_id         := l_discounts.pricing_phase_id;
x_modifiers_rec.pricing_group_sequence   := l_discounts.pricing_group_sequence;
x_modifiers_rec.incompatibility_grp_code := l_discounts.incompatibility_grp_code;
x_modifiers_rec.product_precedence       := l_discounts.product_precedence;
x_modifiers_rec.proration_type_code      := l_discounts.proration_type_code;
--------------------formulas------------------------------------------
x_modifiers_rec.price_by_formula_id      := l_discounts.price_by_formula_id;
x_modifiers_rec.generate_using_formula_id:= l_discounts.generate_using_formula_id;
-------------------PG items-------------------------------------------
x_modifiers_rec.benefit_qty              := l_discounts.benefit_qty;
x_modifiers_rec.benefit_uom_code         := l_discounts.benefit_uom_code;
x_modifiers_rec.benefit_price_list_line_id:= l_discounts.benefit_price_list_line_id;
-------------------Flex Fields----------------------------------------
x_modifiers_rec.context                  := l_discounts.context;
x_modifiers_rec.attribute1               := l_discounts.attribute1;
x_modifiers_rec.attribute2               := l_discounts.attribute2;
x_modifiers_rec.attribute3               := l_discounts.attribute3;
x_modifiers_rec.attribute4               := l_discounts.attribute4;
x_modifiers_rec.attribute5               := l_discounts.attribute5;
x_modifiers_rec.attribute6               := l_discounts.attribute6;
x_modifiers_rec.attribute7               := l_discounts.attribute7;
x_modifiers_rec.attribute8               := l_discounts.attribute8;
x_modifiers_rec.attribute9               := l_discounts.attribute9;
x_modifiers_rec.attribute10              := l_discounts.attribute10;
x_modifiers_rec.attribute11              := l_discounts.attribute11;
x_modifiers_rec.attribute12              := l_discounts.attribute12;
x_modifiers_rec.attribute13              := l_discounts.attribute13;
x_modifiers_rec.attribute14              := l_discounts.attribute14;
x_modifiers_rec.attribute15              := l_discounts.attribute15;
x_modifiers_rec.modifier_level_code      := l_discounts.modifier_level_code;
x_modifiers_rec.automatic_flag           := l_discounts.automatic_flag;
x_modifiers_rec.override_flag            := l_discounts.override_flag;
x_modifiers_rec.comments                 := p_list_line_id;
---------------------Accumulation attributes ------------------------
x_modifiers_rec.accum_attribute          := l_discounts.accum_attribute;
END LOOP;
END populate_discounts;

PROCEDURE populate_pricing_attributes
(
 x_pricing_attr_tbl OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
 , p_list_line_id IN NUMBER
 , p_index IN NUMBER
)
IS
CURSOR c_pricingAttributes(cp_listLineId NUMBER) IS
SELECT
a.product_attribute_context
, a.product_attribute
, a.product_attr_value
, a.product_uom_code
, a.excluder_flag
, a.pricing_attr_value_from
, a.pricing_attr_value_to
, a.pricing_attribute_context
, a.pricing_attribute
, a.comparison_operator_code
FROM qp_pricing_attributes a
WHERE a.list_line_id = cp_listLineId;
i NUMBER :=  null;
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
x_pricing_attr_tbl.delete;
i := 1;
FOR l_pricingAttributes in c_pricingAttributes(cp_listLineId => p_list_line_id) LOOP
    --dbms_output.put_line('ist line id :'||p_list_line_id||' :index :'||P_INDEX||' : Attr Value :'||l_pricingAttributes.product_attr_value||': Excluder :'||l_pricingAttributes.excluder_flag);
    x_pricing_attr_tbl(i).product_attribute_context := l_pricingAttributes.product_attribute_context;
    x_pricing_attr_tbl(i).product_attribute         := l_pricingAttributes.product_attribute;
    x_pricing_attr_tbl(i).product_attr_value        := l_pricingAttributes.product_attr_value;
    x_pricing_attr_tbl(i).product_uom_code          := l_pricingAttributes.product_uom_code;
    x_pricing_attr_tbl(i).excluder_flag             := l_pricingAttributes.excluder_flag;
    x_pricing_attr_tbl(i).pricing_attr_value_from   := l_pricingAttributes.pricing_attr_value_from;
    x_pricing_attr_tbl(i).pricing_attr_value_to     := l_pricingAttributes.pricing_attr_value_to;
    x_pricing_attr_tbl(i).pricing_attribute_context := l_pricingAttributes.pricing_attribute_context;
    x_pricing_attr_tbl(i).pricing_attribute         := l_pricingAttributes.pricing_attribute;
    X_pricing_attr_tbl(i).operation                 := Qp_Globals.G_OPR_CREATE;
    X_pricing_attr_tbl(i).comparison_operator_code  := l_pricingAttributes.comparison_operator_code;
    X_pricing_attr_tbl(i).modifiers_index           := P_INDEX;
    i := i + 1;
END LOOP;

END populate_pricing_attributes;

PROCEDURE populate_pbh_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
BEGIN
--dbms_output.put_line('IN populate pbh line');
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
x_modifier_line_tbl(1).operation                    := QP_GLOBALS.G_OPR_CREATE;
x_modifier_line_tbl(1).list_line_type_code          := 'PBH';
x_modifier_line_tbl(1).automatic_flag               := 'Y';
--dbms_output.put_line('Before populate discounts');
populate_discounts
(
 x_modifiers_rec  => x_modifier_line_tbl(1)
, p_list_line_id  => p_listLineId
);
--dbms_output.put_line('After populate discounts');
populate_pricing_attributes
(
 x_pricing_attr_tbl => x_pricing_attr_tbl
 , p_list_line_id   => p_listLineId
 , p_index          => 1
);
END populate_pbh_line;

PROCEDURE merge_modifiers
(
  p_to_modifier_line_tbl    IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , p_from_modifier_line_tbl IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_modifier_line_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
)
IS
BEGIN
x_modifier_line_tbl.delete;
for i in p_to_modifier_line_tbl.first .. p_to_modifier_line_tbl.last LOOP
    IF p_to_modifier_line_tbl.exists(i) THEN
        x_modifier_line_tbl(i) := p_to_modifier_line_tbl(i);
    END IF;
END LOOP;
FOR i in p_from_modifier_line_tbl.first .. p_from_modifier_line_tbl.last LOOP
    IF p_from_modifier_line_tbl.exists(i) THEN
        x_modifier_line_tbl(x_modifier_line_tbl.count + 1) := p_from_modifier_line_tbl(i);
    END IF;
END LOOP;
END merge_modifiers;

PROCEDURE merge_modifiers
(
  px_to_modifier_line_tbl    IN OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , p_from_modifier_line_tbl IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
)
IS
BEGIN
--dbms_output.put_line('In Merge Modifiers:');
IF nvl(p_from_modifier_line_tbl.count,0) > 0 THEN
FOR i in p_from_modifier_line_tbl.first .. p_from_modifier_line_tbl.last LOOP
--dbms_output.put_line('Merge Modifiers:'||i);
    IF p_from_modifier_line_tbl.exists(i) THEN
        --dbms_output.put_line('Merge Modifiers:');
        px_to_modifier_line_tbl(px_to_modifier_line_tbl.count + 1) := p_from_modifier_line_tbl(i);
    END IF;
END LOOP;
END IF;
--dbms_output.put_line('End Merge modifiers');
END merge_modifiers;

PROCEDURE merge_pricing_attributes
(
  p_to_pricing_attr_tbl    IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_from_pricing_attr_tbl IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
BEGIN
x_pricing_attr_tbl.delete;
for i in p_to_pricing_attr_tbl.first .. p_to_pricing_attr_tbl.last LOOP
    IF p_to_pricing_attr_tbl.exists(i) THEN
        x_pricing_attr_tbl(i) := p_to_pricing_attr_tbl(i);
    END IF;
END LOOP;
FOR i in p_from_pricing_attr_tbl.first .. p_from_pricing_attr_tbl.last LOOP
    IF p_from_pricing_attr_tbl.exists(i) THEN
        x_pricing_attr_tbl(x_pricing_attr_tbl.count + 1) := p_from_pricing_attr_tbl(i);
    END IF;
END LOOP;
END merge_pricing_attributes;


PROCEDURE merge_pricing_attributes
(
  px_to_pricing_attr_tbl    IN OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_from_pricing_attr_tbl IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
BEGIN
IF nvl(p_from_pricing_attr_tbl.count,0) > 0 THEN
for i in p_from_pricing_attr_tbl.first .. p_from_pricing_attr_tbl.last LOOP
IF p_from_pricing_attr_tbl.exists(i) THEN
    px_to_pricing_attr_tbl(px_to_pricing_attr_tbl.count+1) := p_from_pricing_attr_tbl(i);
END IF;
END LOOP;
END IF;
--dbms_output.put_line('end pricing attributes');
END merge_pricing_attributes;

PROCEDURE populate_dis_lines
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN   NUMBER
  , p_offerAdjustmentId     IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl          OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_discountLines(cp_listLineId NUMBER , cp_offerAdjustmentId NUMBER)
IS
SELECT a.from_rltd_modifier_id, a.to_rltd_modifier_id, b.offer_discount_line_id , nvl(c.modified_discount,d.operand) discount  , d.arithmetic_operator
FROM qp_rltd_modifiers a, ozf_qp_discounts b , ozf_offer_adjustment_tiers c , qp_list_lines d
WHERE a.to_rltd_modifier_id = b.list_line_id(+)
and b.offer_discount_line_id = c.offer_discount_line_id(+)
AND a.to_rltd_modifier_id = d.list_line_id
AND a.from_rltd_modifier_id = cp_listLineId
AND c.offer_adjustment_id(+) = cp_offerAdjustmentId;

/*SELECT to_rltd_modifier_id
FROM qp_rltd_modifiers
WHERE from_rltd_modifier_id = cp_listLineId;
*/
i NUMBER;
l_pricingAttrTbl QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_pricingAttrTbl.delete;

i := 1;
FOR l_discountLines IN c_discountLines(cp_listLineId => p_listLineId , cp_offerAdjustmentId => p_offerAdjustmentId)
LOOP
        x_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
        x_modifier_line_tbl(i).list_line_type_code          := 'DIS';
        x_modifier_line_tbl(i).start_date_active            := null;
        x_modifier_line_tbl(i).rltd_modifier_grp_type        := 'PRICE BREAK';
        x_modifier_line_tbl(i).rltd_modifier_grp_no          := 1;
        x_modifier_line_tbl(i).modifier_parent_index         := 1;
populate_discounts
(
 x_modifiers_rec  => x_modifier_line_tbl(i)
, p_list_line_id  => l_discountLines.to_rltd_modifier_id
);
----dbms_output.put_line('List Line Id for pricing attr:'||l_discountLines.to_rltd_modifier_id);
        x_modifier_line_tbl(i).arithmetic_operator          := l_discountLines.arithmetic_operator;
        x_modifier_line_tbl(i).operand                      := l_discountLines.discount;
populate_pricing_attributes
(
 x_pricing_attr_tbl => l_pricingAttrTbl
 , p_list_line_id   => l_discountLines.to_rltd_modifier_id
 , p_index          => i + 1 -- i + 1 the 1 for the row which is already populated for pbh line
);
merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricingAttrTbl
);
i := i + 1;
END LOOP;
END populate_dis_lines;

PROCEDURE populate_modifier_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId   IN   NUMBER
  , x_modifier_line_tbl    OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl          OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_offerAdjustmentId     IN   NUMBER
)
IS
pbh_pricing_attr_tbl QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
dis_pricing_attr_tbl QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
pbh_modifier_line_tbl    QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
dis_modifier_line_tbl    QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
CURSOR c_additionalDetails(cp_offerAdjustmentId NUMBER)
IS
SELECT
a.effective_date, a.list_header_id
FROM ozf_offer_adjustments_b a
WHERE a.offer_adjustment_id = cp_offerAdjustmentId;
l_additionalDetails c_additionalDetails%ROWTYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- initialize table
-- populate pbh line
-- populate dis lines
-- merge the dis lines with pbh lines
x_modifier_line_tbl.delete;
pbh_pricing_attr_tbl.delete;
dis_pricing_attr_tbl.delete;
pbh_modifier_line_tbl.delete;
dis_modifier_line_tbl.delete;
populate_pbh_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  , x_modifier_line_tbl     => pbh_modifier_line_tbl
  , x_pricing_attr_tbl      => pbh_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OPEN c_additionalDetails(cp_offerAdjustmentId => p_offerAdjustmentId);
    FETCH c_additionalDetails INTO l_additionalDetails;
CLOSE c_additionalDetails;
pbh_modifier_line_tbl(1).start_date_active := l_additionalDetails.effective_date;
    ----dbms_output.put_line('Price break type code is1 :'||pbh_modifier_line_tbl(1).price_break_type_code||' : '||p_listLineId);
populate_dis_lines
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  , p_offerAdjustmentId     => p_offerAdjustmentId
  , x_modifier_line_tbl     => dis_modifier_line_tbl
  , x_pricing_attr_tbl      => dis_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
merge_modifiers
(
  p_to_modifier_line_tbl    => pbh_modifier_line_tbl
  , p_from_modifier_line_tbl => dis_modifier_line_tbl
  , x_modifier_line_tbl      => x_modifier_line_tbl
);
merge_pricing_attributes
(
  p_to_pricing_attr_tbl    => pbh_pricing_attr_tbl
  , p_from_pricing_attr_tbl => dis_pricing_attr_tbl
  , x_pricing_attr_tbl      => x_pricing_attr_tbl
);
for i in x_modifier_line_tbl.first .. x_modifier_line_tbl.last LOOP
----dbms_output.put_line('Counter:'||i);
IF x_modifier_line_tbl.exists(i) THEN
----dbms_output.put_line('Parent Index'||x_modifier_line_tbl(i).modifier_parent_index);
null;
END IF;
END LOOP;
--dbms_output.put_line('================Pricing Attr---------------------');
for i in x_pricing_attr_tbl.first .. x_pricing_attr_tbl.last LOOP
IF x_pricing_attr_tbl.exists(i) THEN
----dbms_output.put_line('Counter:'||i);
----dbms_output.put_line('Index:'||x_pricing_attr_tbl(i).modifiers_index);
null;
END IF;
END LOOP;
/*x_modifier_line_tbl := pbh_modifier_line_tbl MULTISET UNION dis_modifier_line_tbl;
x_pricing_attr_tbl  := pbh_pricing_attr_tbl MULTISET UNION dis_pricing_attr_tbl;
*/
EXCEPTION
WHEN OTHERS THEN
null;
END populate_modifier_lines;

/**
Copies a qp_list_line and pricing attributes, with start date as the effective date of the adjustmentId passed in
*/
PROCEDURE create_modifier_from_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerAdjustmentId     IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
V_MODIFIER_LIST_rec             QP_MODIFIERS_PUB.Modifier_List_Rec_Type;
V_MODIFIER_LIST_val_rec         QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type;
V_MODIFIERS_tbl                 QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
V_MODIFIERS_val_tbl             QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type;
V_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
V_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
V_PRICING_ATTR_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
V_PRICING_ATTR_val_tbl          QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type;
l_modifier_line_tbl             QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pricing_attr_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
-- initialize  return status, nested tables
-- for given adjustment id get the adjustment tiers
-- populate the qp_list_lines using the tiers and adjustment tiers
-- create the QP list lines
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;
populate_modifier_lines
(
x_return_status         => x_return_status
, x_msg_count           => x_msg_count
, x_msg_data            => x_msg_data
, p_offerAdjustmentId   => p_offerAdjustmentId
, p_listLineId          => p_listLineId --l_tierHeader.list_line_id
, x_modifier_line_tbl   => l_modifier_line_tbl
, x_pricing_attr_tbl    => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifier_line_tbl,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
x_modifier_line_tbl := v_modifiers_tbl;
x_pricing_attr_tbl  := v_pricing_attr_tbl;
--dbms_output.put_line('Table sizes 1 are :'||v_modifiers_tbl.count||' : '||v_pricing_attr_tbl.count);
--dbms_output.put_line('Table sizes 2 are :'||x_modifier_line_tbl.count||' : '||x_pricing_attr_tbl.count);
END create_modifier_from_line;

/**
*/
PROCEDURE map_ozf_qp_lines
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId      IN   NUMBER
  ,p_offerDiscountLineId    IN  NUMBER
  ,p_modifier_line_tbl      IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  ,p_pricing_attr_tbl       IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
l_qpDiscountsRec OZF_QP_DISCOUNTS_PVT.qp_discount_rec_type;
l_qpProductsRec OZF_QP_PRODUCTS_PVT.qp_product_rec_type;
l_qpDiscountId NUMBER;
l_qpProductId NUMBER;
l_objectVersion NUMBER;
l_prodObjectVersion NUMBER;

CURSOR c_discounts(cp_offerDiscountLineId NUMBER, cp_offerAdjustmentId NUMBER)
IS
SELECT discount
, tier_type
, offer_discount_line_id
FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = cp_offerDiscountlineId
OR parent_discount_line_id   = cp_offerDiscountLineId;
CURSOR c_products(cp_offerDiscountLineId NUMBER) IS
SELECT off_discount_product_id
, product_attribute
, product_attr_value
, excluder_flag
FROM ozf_offer_discount_products
WHERE offer_discount_line_id = cp_offerDiscountlineId;

BEGIN
-- initialize
-- loop thru the Discount Structure
-- for each discount line loop thru. the qp_modifiers table
-- check for discount equality, in case yes insert into ozf_qp_discounts table
-- similar thing for relating products
x_return_status := FND_API.G_RET_STS_SUCCESS;
--dbms_output.put_line('Map Ozf qp lines');
--dbms_output.put_line('Table counts are :'||p_modifier_line_tbl.count||' : '||p_pricing_attr_tbl.count);
FOR l_discounts in c_discounts(cp_offerDiscountLineId => p_offerDiscountLineId , cp_offerAdjustmentId => p_offerAdjustmentId)
LOOP
    --dbms_output.put_line('OfferDiscount line Id :'||l_discounts.offer_discount_line_id);
    FOR i IN p_modifier_line_tbl.first .. p_modifier_line_tbl.last LOOP
        IF p_modifier_line_tbl.exists(i) THEN
            --dbms_output.put_line('List line Id :'||p_modifier_line_tbl(i).list_line_id||' : '||p_modifier_line_tbl(i).list_line_type_code);
            IF
            (l_discounts.tier_type = p_modifier_line_tbl(i).list_line_type_code )
            AND
            (nvl(l_discounts.discount,0) = nvl(p_modifier_line_tbl(i).operand,0))
            THEN
                --dbms_output.put_line('ListLIneId:'||p_modifier_line_tbl(i).list_line_id||' :Discount Line Id :'||l_discounts.offer_discount_line_id);
                l_qpDiscountsRec := null;
                l_qpDiscountsRec.list_line_id            := p_modifier_line_tbl(i).list_line_id;
                l_qpDiscountsRec.offer_discount_line_id  := l_discounts.offer_discount_line_id;
                l_qpDiscountsRec.start_date              := sysdate;
                 OZF_QP_DISCOUNTS_PVT. Create_ozf_qp_discount
                                                            (
                                                                p_api_version_number         => 1.0
                                                                , p_init_msg_list              => FND_API.G_FALSE
                                                                , p_commit                     => FND_API.G_FALSE
                                                                , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                                , x_return_status              =>  x_return_status
                                                                , x_msg_count                  => x_msg_count
                                                                , x_msg_data                   => x_msg_data
                                                                , p_qp_disc_rec                => l_qpDiscountsRec
                                                                , x_qp_discount_id             => l_qpDiscountId
                                                            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            ELSE
                null;
                --dbms_output.put_line('No Discounts found for list line id:'||p_modifier_line_tbl(i).list_line_id||':'||l_discounts.offer_discount_line_id);
            END IF;
        END IF;
    END LOOP;
END LOOP;

FOR l_products IN c_products(cp_offerDiscountLineId => p_offerDiscountLineId) LOOP
    FOR i in p_pricing_attr_tbl.first .. p_pricing_attr_tbl.last LOOP
        IF p_pricing_attr_tbl.exists(i) THEN
            IF
            (l_products.excluder_flag = p_pricing_attr_tbl(i).excluder_flag)
            AND
            (l_products.product_attribute = p_pricing_attr_tbl(i).product_attribute)
            AND
            (l_products.product_attr_value = p_pricing_attr_tbl(i).product_attr_value)
            THEN
            --dbms_output.put_line('Pricing Attribute id:'||p_pricing_attr_tbl(i).pricing_attribute_id||': Product Id :'||l_products.off_discount_product_id);
            l_qpProductsRec.off_discount_product_id := l_products.off_discount_product_id;
            l_qpProductsRec.pricing_attribute_id    := p_pricing_attr_tbl(i).pricing_attribute_id;
                OZF_QP_PRODUCTS_PVT.Create_ozf_qp_product(
                                                            p_api_version_number         => 1.0
                                                            , p_init_msg_list              => FND_API.G_FALSE
                                                            , p_commit                     => FND_API.G_FALSE
                                                            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                            , x_return_status              => x_return_status
                                                            , x_msg_count                  => x_msg_count
                                                            , x_msg_data                   => x_msg_data
                                                            , p_qp_product_rec             => l_qpProductsRec
                                                            , x_qp_product_id              => l_qpProductId
                                                        );
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSE
                null;
                --dbms_output.put_line('No Products  found for pricing_attribute :'||p_pricing_attr_tbl(i).pricing_attribute_id||' : '||l_products.off_discount_product_id);
            END IF;
        END IF;
    END LOOP;
    END LOOP;
END map_ozf_qp_lines;

/**
Creates new qp_list_lines and qp_pricing_attributes
for a given offer_adjustment_id
*/
PROCEDURE create_new_qp_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
l_modifier_line_tbl             QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pricing_attr_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
CURSOR c_tierHeader(cp_offerAdjustmentId NUMBER)
IS
SELECT distinct parent_discount_line_id , c.list_line_id
FROM ozf_offer_adjustment_tiers a, ozf_offer_discount_lines b , ozf_qp_discounts c , qp_list_lines d
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.parent_discount_line_id = c.offer_discount_line_id
AND c.list_line_id = d.list_line_id
AND d.list_line_type_code = 'PBH'
AND offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
-- initialize
-- get all the tier Headers for which adjustments have been entered
-- for each tier header create QP Data, corresponding to data already entered in QP
-- merge the modifier tables created for each discount
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
FOR l_tierHeader in c_tierHeader(cp_offerAdjustmentId => p_offerAdjustmentId)
LOOP
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;
create_modifier_from_line
(
   x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId     => p_offerAdjustmentId
  , p_listLineId           => l_tierHeader.list_line_id--l_tierHeader.parent_discount_line_id
  , x_modifier_line_tbl    => l_modifier_line_tbl
  , x_pricing_attr_tbl     => l_pricing_attr_tbl
);
--dbms_output.put_line('Table sizes 3 are :'||l_modifier_line_tbl.count||' : '||l_pricing_attr_tbl.count);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
map_ozf_qp_lines
(
   x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId     => p_offerAdjustmentId
  ,p_offerDiscountLineId   => l_tierHeader.parent_discount_line_id
  ,p_modifier_line_tbl    => l_modifier_line_tbl
  ,p_pricing_attr_tbl     => l_pricing_attr_tbl
);
/*map_ozf_qp_lines
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId      IN   NUMBER
  ,p_offerDiscountLineId    IN  NUMBER
  ,p_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  ,p_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)*/
merge_modifiers
(
  px_to_modifier_line_tbl    => x_modifier_line_tbl
  , p_from_modifier_line_tbl => l_modifier_line_tbl
);
merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricing_attr_tbl
);
END LOOP;
-- passback the created modifier lines and pricing attributes.
END create_new_qp_lines;

/**
Creates relation between two qp_list_lines for a given offer_adjustment_id
*/
PROCEDURE relate_lines
(
  p_from_list_line_id IN NUMBER
  , p_to_list_line_id IN NUMBER
  , p_offer_adjustment_id IN NUMBER
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
INSERT INTO ozf_offer_adj_rltd_lines
(
 OFFER_ADJ_RLTD_LINE_ID
 , OFFER_ADJUSTMENT_ID
 , FROM_LIST_LINE_ID
 , TO_LIST_LINE_ID
 , LAST_UPDATE_DATE
 , LAST_UPDATED_BY
 , CREATION_DATE
 , CREATED_BY
 , LAST_UPDATE_LOGIN
 , OBJECT_VERSION_NUMBER
 , security_group_id
)
VALUES
(
ozf_offer_adj_rltd_lines_s.nextval
, p_offer_adjustment_id
, p_from_list_line_id
, p_to_list_line_id
, sysdate
, FND_GLOBAL.USER_ID
, sysdate
, FND_GLOBAL.USER_ID
, FND_GLOBAL.CONC_LOGIN_ID
, 1
, null
);
EXCEPTION
WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
END relate_lines;

PROCEDURE relate_lines
(
 p_modifiers_tbl          IN qp_modifiers_pub.modifiers_tbl_type
  , p_offer_adjustment_id IN NUMBER
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_modifiers_tbl.count,0) > 0 THEN
    FOR k IN p_modifiers_tbl.first .. p_modifiers_tbl.last LOOP
        IF p_modifiers_tbl.exists(k) THEN
             IF p_modifiers_tbl(k).operation <> 'CREATE' THEN
                 null;
             ELSE
                IF p_modifiers_tbl(k).comments IS NULL OR p_modifiers_tbl(k).comments = FND_API.G_MISS_CHAR THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
                ELSE
                    relate_lines
                    (
                      p_from_list_line_id => to_number(p_modifiers_tbl(k).comments)
                      , p_to_list_line_id => p_modifiers_tbl(k).list_line_id
                      , p_offer_adjustment_id => p_offer_adjustment_id
                      , x_return_status   => x_return_status
                      , x_msg_count       => x_return_status
                      , x_msg_data        => x_return_status
                    );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        return;
                    END IF;
                END IF;
             END IF;
        END IF;
    END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
END relate_lines;


PROCEDURE adjust_old_discounts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
l_modifier_line_tbl             QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pricing_attr_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
        Corresponding to the discount changes, update the tier definitions.
        End Date the QP List lines corresponding to the tier definitions changed.
        Create new QP List lines with the updated tier definitions.(1)[1]
        Create new discount-tier mapping(1)
        *Create new product-product mapping
*/
update_adj_vo_tiers
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
end_date_qp_lines
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
create_new_qp_lines
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
  , x_modifier_line_tbl     => l_modifier_line_tbl
  , x_pricing_attr_tbl      => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
relate_lines
(
 p_modifiers_tbl          => l_modifier_line_tbl
  , p_offer_adjustment_id => p_offerAdjustmentId
  , x_return_status          => x_return_status
  ,x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
     OE_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     OE_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( 'VOLUME_OFFER_ADJ','adjust_old_discounts');
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     OE_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

END adjust_old_discounts;

/**
Old exclusions are not included in the new qp_list_lines created. Need to take care of that
*/
PROCEDURE create_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_products(cp_offerAdjustmentId NUMBER) IS
SELECT
 a.offer_discount_line_id
, a.off_discount_product_id
, a.product_context
, a.product_attribute
, a.product_attr_value
, a.excluder_flag
, a.apply_discount_flag
, a.include_volume_flag
, b.offer_id
, a.offer_adjustment_product_id
, a.object_version_number
FROM ozf_offer_adjustment_products a, ozf_offer_discount_lines b
WHERE
a.offer_discount_line_id = b.offer_discount_line_id
AND offer_adjustment_id = cp_offerAdjustmentId;

l_productsRec OZF_Volume_Offer_disc_PVT.vo_prod_rec_type;
l_objId NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_products in c_products(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
l_productsRec := null;
l_productsRec.excluder_flag           :=    l_products.excluder_flag;
l_productsRec.offer_discount_line_id  :=    l_products.offer_discount_line_id;
l_productsRec.offer_id                :=    l_products.offer_id;
l_productsRec.product_context         :=    l_products.product_context;
l_productsRec.product_attribute       :=    l_products.product_attribute;
l_productsRec.product_attr_value      :=    l_products.product_attr_value;
l_productsRec.apply_discount_flag     :=    l_products.apply_discount_flag;
l_productsRec.include_volume_flag     :=    l_products.include_volume_flag;

OZF_Volume_Offer_disc_PVT.Create_vo_Product(
                                            p_api_version_number           => 1.0
                                            , p_init_msg_list              => FND_API.G_FALSE
                                            , p_commit                     => FND_API.G_FALSE
                                            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                            , x_return_status              => x_return_status
                                            , x_msg_count                  => x_msg_count
                                            , x_msg_data                   => x_msg_data
                                            , p_vo_prod_rec                => l_productsRec
                                            , x_off_discount_product_id    => l_objId
                                             );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--dbms_output.put_line('Created Product successfully:'||l_objId);
--dbms_output.put_line('Updating :'||l_products.offer_adjustment_product_id);
UPDATE ozf_offer_adjustment_products
SET off_discount_product_id = l_objId , object_version_number = object_version_number + 1
WHERE offer_adjustment_product_id = l_products.offer_adjustment_product_id;
--AND object_version_number         = l_products.object_version_number;

END LOOP;
EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

-- initialize
-- query new products added in the adjustment
-- insert the new products into ozf_offer_discount_products
-- update ozf_offer_adjustment_products with the off_discount_product_id of the newly created product
END create_new_products;


PROCEDURE populate_advanced_options
(
p_listHeaderId IN NUMBER
, x_modifiers_rec IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
)
IS
CURSOR c_advOptions(cp_listHeaderId NUMBER)
IS
SELECT
print_on_invoice_flag
, accrual_flag
, pricing_phase_id
, pricing_group_sequence
, incompatibility_grp_code
, product_precedence
, proration_type_code
FROM qp_list_lines
WHERE list_header_id = cp_listHeaderId
AND rownum < 2;
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_advOptions IN c_advOptions(cp_listHeaderId => p_listHeaderId ) LOOP
    x_modifiers_rec.print_on_invoice_flag    := l_advOptions.print_on_invoice_flag;
    x_modifiers_rec.accrual_flag             := l_advOptions.accrual_flag;
    x_modifiers_rec.pricing_phase_id         := l_advOptions.pricing_phase_id;
    x_modifiers_rec.pricing_group_sequence   := l_advOptions.pricing_group_sequence;
    x_modifiers_rec.incompatibility_grp_code := l_advOptions.incompatibility_grp_code;
    x_modifiers_rec.product_precedence       := l_advOptions.product_precedence;
    x_modifiers_rec.proration_type_code      := l_advOptions.proration_type_code;
END LOOP;
END populate_advanced_options;


/**
This produre populates and returns a qp_modifier_rec given the offerDiscountLineId
*/
PROCEDURE populate_discounts
(
 x_modifiers_rec            IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
, p_offerDiscountLineId     IN NUMBER
)
IS
-- list header id
-- modifierlevelCode
-- accrual flag
-- arithmetic operator
-- price break type code
-- start date active
-- formula
-- accumulation attribute
CURSOR c_discountDetails(cp_offerDiscountLineId NUMBER ) IS
SELECT
c.list_header_id
, b.modifier_level_code
, decode(b.offer_type, 'ACCRUAL','Y','VOLUME_OFFER', decode(b.volume_offer_type,'ACCRUAL','Y','N'),'N') accrual_flag
, nvl(a.discount_type,d.discount_type) discount_type
, a.volume_break_type price_break_type_code
, a.formula_id
, a.discount
, c.effective_date
FROM
ozf_offer_discount_lines a, ozf_offers b , ozf_offer_adjustments_b c , ozf_offer_discount_lines d
WHERE
a.offer_discount_line_id = cp_offerDiscountLineId
AND a.offer_id           = b.offer_id
AND b.qp_list_header_id  = c.list_header_id
AND a.parent_discount_line_id = d.offer_discount_line_id(+);
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_discountDetails IN c_discountDetails(cp_offerDiscountLineId => p_offerDiscountLineId) LOOP
        x_modifiers_rec.list_header_id := l_discountDetails.list_header_id;
        x_modifiers_rec.end_date_active := null;
        x_modifiers_rec.arithmetic_operator := l_discountDetails.discount_type;
        x_modifiers_rec.operand             := l_discountDetails.discount;
--        --dbms_output.put_line('arithmetic operator1 is :'||x_modifiers_rec.arithmetic_operator||' : '||l_discounts.discount_type);
        x_modifiers_rec.price_break_type_code   := l_discountDetails.price_break_type_code;
--        --dbms_output.put_line('Price break type code is :'||x_modifiers_rec.price_break_type_code||' : '||l_discounts.volume_break_type);
        ----------------------advanced options---------------------------------
        x_modifiers_rec.accrual_flag             := l_discountDetails.accrual_flag;
        --------------------formulas------------------------------------------
        x_modifiers_rec.price_by_formula_id      := l_discountDetails.formula_id;
        x_modifiers_rec.generate_using_formula_id:= l_discountDetails.formula_id;

        x_modifiers_rec.modifier_level_code      := l_discountDetails.modifier_level_code;
        x_modifiers_rec.automatic_flag           := 'Y';
        x_modifiers_rec.override_flag            := 'N';
        x_modifiers_rec.comments                 := p_offerDiscountLineId;
        ---------------------Accumulation attributes ------------------------
--        x_modifiers_rec.accum_attribute          := 'PRICING_ATTRIBUTE19';
        populate_advanced_options
        (
        p_listHeaderId      => l_discountDetails.list_header_id
        , x_modifiers_rec   => x_modifiers_rec
        );
    END LOOP;
END populate_discounts;
PROCEDURE populate_pbh_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerDiscountLineId   IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
)
IS
BEGIN
--dbms_output.put_line('IN populate pbh line');
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
--dbms_output.put_line('Before populate discounts1');
x_modifier_line_tbl(1).operation                    := QP_GLOBALS.G_OPR_CREATE;
x_modifier_line_tbl(1).list_line_type_code          := 'PBH';
x_modifier_line_tbl(1).automatic_flag               := 'Y';
populate_discounts
(
 x_modifiers_rec            => x_modifier_line_tbl(1)
, p_offerDiscountLineId     => p_offerDiscountLineId
);
--dbms_output.put_line('After populate discounts1');
END populate_pbh_line;

PROCEDURE populate_pricing_attr
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerDiscountLineId   IN   NUMBER
  , x_pricing_attr_rec      IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_rec_type
  , p_index                 IN  NUMBER
)
IS
CURSOR c_pricingAttr(cp_offerDiscountLineId NUMBER) IS
SELECT
nvl(a.uom_code,b.uom_code) uom_code
, b. offer_discount_line_id
, b.volume_from
, b.volume_to
, nvl( a.volume_type,b.volume_type) volume_type
, nvl(b.volume_operator,'BETWEEN') comparison_operator_code
FROM ozf_offer_discount_lines b , ozf_offer_discount_lines a
WHERE b.offer_discount_line_id = cp_offerDiscountLineId
AND b.parent_discount_line_id = a.offer_discount_line_id(+);
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
for l_pricingAttr in c_pricingAttr(cp_offerDiscountLineId => p_offerDiscountLineId) LOOP
        x_pricing_attr_rec.product_uom_code          := l_pricingAttr.uom_code;
        x_pricing_attr_rec.pricing_attr_value_from   := l_pricingAttr.volume_from;
        x_pricing_attr_rec.pricing_attr_value_to     := l_pricingAttr.volume_to;
        x_pricing_attr_rec.pricing_attribute_context := 'VOLUME';
        x_pricing_attr_rec.pricing_attribute         := l_pricingAttr.volume_type;
        x_pricing_attr_rec.comparison_operator_code  := l_pricingAttr.comparison_operator_code;
        x_pricing_attr_rec.modifiers_index           := p_index;
        x_pricing_attr_rec.operation                 := Qp_Globals.G_OPR_CREATE;
END LOOP;
END populate_pricing_attr;

FUNCTION getMinVolumeFrom
(
p_offDiscountProductId NUMBER
)
RETURN NUMBER
IS
l_volumeFrom NUMBER;
CURSOR c_minVolume(cp_offDiscountProductId NUMBER)
IS
SELECT min(volume_from)
FROM ozf_offer_discount_lines a, ozf_offer_discount_products b
WHERE a.parent_discount_line_id = b.offer_discount_line_id
AND b.off_discount_product_id = cp_offDiscountProductId;
BEGIN
OPEN c_minVolume(cp_offDiscountProductId => p_offDiscountProductId);
FETCH c_minVolume INTO l_volumeFrom;
IF c_minVolume%NOTFOUND THEN
    l_volumeFrom := null;
END IF;
CLOSE c_minVolume;
RETURN l_volumeFrom;
END getMinVolumeFrom;

PROCEDURE populateZeroDiscount
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offDiscountProductId IN NUMBER
  , p_offerDiscountLineId IN NUMBER
  , x_modifier_line_rec     IN OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Rec_Type
  , x_pricing_attr_rec      IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_rec_type
)
IS
BEGIN
        populate_discounts
        (
         x_modifiers_rec            => x_modifier_line_rec
        , p_offerDiscountLineId     => p_offerDiscountLineId
        );
         populate_pricing_attr
        (
          x_return_status           => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_offerDiscountLineId   => p_offerDiscountLineId
          , x_pricing_attr_rec      => x_pricing_attr_rec
          , p_index                 => 2
        );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
    x_modifier_line_rec.operand := 0;
    x_modifier_line_rec.comments:= -1;
    x_pricing_attr_rec.pricing_attr_value_from  := '0';
    x_pricing_attr_rec.pricing_attr_value_to    := to_char(getMinVolumeFrom(p_offDiscountProductId => p_offDiscountProductId));
END populateZeroDiscount;

PROCEDURE populate_dis_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerDiscountLineId   IN   NUMBER
  , p_offDiscountProductId  IN  NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , p_pricing_attr_rec      IN Qp_Modifiers_Pub.pricing_attr_rec_type
  , x_pricing_attr_tbl      OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_Tbl_type
)
IS
CURSOR c_discountLines(cp_parentDiscountLineId NUMBER , cp_offDiscountProductId NUMBER)
IS
SELECT a.offer_discount_line_id , b.apply_discount_flag
FROM ozf_offer_discount_lines a, ozf_offer_discount_products b
WHERE parent_discount_line_id = cp_parentDiscountLineId
AND a.parent_discount_line_id = b.offer_discount_line_id
AND b.off_discount_product_id = cp_offDiscountProductId;

i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
i := 2;
    IF getMinVolumeFrom(p_offDiscountProductId => p_offDiscountProductId) IS NOT NULL AND getMinVolumeFrom(p_offDiscountProductId => p_offDiscountProductId) > 0 THEN
        x_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
        x_modifier_line_tbl(i).list_line_type_code          := 'DIS';
        x_modifier_line_tbl(i).start_date_active            := null;
        x_modifier_line_tbl(i).rltd_modifier_grp_type        := 'PRICE BREAK';
        x_modifier_line_tbl(i).rltd_modifier_grp_no          := 1;
        x_modifier_line_tbl(i).modifier_parent_index         := 1;
        x_pricing_attr_tbl(i)       := p_pricing_attr_rec;
        populateZeroDiscount
        (
          x_return_status           => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , x_modifier_line_rec     => x_modifier_line_tbl(i)
          , p_offDiscountProductId  => p_offDiscountProductId
          , p_offerDiscountLineId   => p_offerDiscountLineId
          , x_pricing_attr_rec      => x_pricing_attr_tbl(i)
         );
        i := i + 1;
    END IF;
FOR l_discountLines IN c_discountLines(cp_parentDiscountLineId => p_offerDiscountLineId , cp_offDiscountProductId => p_offDiscountProductId) LOOP
        x_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
        x_modifier_line_tbl(i).list_line_type_code          := 'DIS';
        x_modifier_line_tbl(i).start_date_active            := null;
        x_modifier_line_tbl(i).rltd_modifier_grp_type        := 'PRICE BREAK';
        x_modifier_line_tbl(i).rltd_modifier_grp_no          := 1;
        x_modifier_line_tbl(i).modifier_parent_index         := 1;
        x_pricing_attr_tbl(i)       := p_pricing_attr_rec;

        populate_discounts
        (
         x_modifiers_rec            => x_modifier_line_tbl(i)
        , p_offerDiscountLineId     => l_discountLines.offer_discount_line_id
        );
        IF l_discountLines.apply_discount_flag = 'N' THEN
            x_modifier_line_tbl(i).operand := 0;
        END IF;

        populate_pricing_attr
        (
          x_return_status           => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_offerDiscountLineId   => l_discountLines.offer_Discount_Line_Id
          , x_pricing_attr_rec      => x_pricing_attr_tbl(i)
          , p_index                 => i
        );
        i := i + 1;
END LOOP;
END populate_dis_line;


PROCEDURE populate_discounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerDiscountLineId   IN   NUMBER
  , p_offDiscountProductId  IN  NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , p_pricing_attr_rec      IN Qp_Modifiers_Pub.pricing_attr_Rec_type
  , x_pricing_attr_tbl      OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_Tbl_type
)
IS
l_dis_modifier_line_tbl     QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pbh_modifier_line_tbl     QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_dis_pricing_attr_tbl      Qp_Modifiers_Pub.pricing_attr_Tbl_type;
l_pbh_pricing_attr_tbl      Qp_Modifiers_Pub.pricing_attr_Tbl_type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_dis_modifier_line_tbl.delete;
l_pbh_modifier_line_tbl.delete;
l_dis_pricing_attr_tbl.delete;
l_pbh_pricing_attr_tbl.delete;
populate_pbh_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerDiscountLineId   => p_offerDiscountLineId
  , x_modifier_line_tbl     => l_pbh_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
l_pbh_pricing_attr_tbl(1)                   := p_pricing_attr_rec;
--dbms_output.put_line('l_pbh_pricing_attr_tbl(1)                   := p_pricing_attr_rec;'||l_pbh_pricing_attr_tbl(1).product_attr_value);
l_pbh_pricing_attr_tbl(1).modifiers_index   := 1;
populate_pricing_attr
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerDiscountLineId   => p_offerDiscountLineId
  , x_pricing_attr_rec      => l_pbh_pricing_attr_tbl(1)
  , p_index                 => 1
);
--dbms_output.put_line('l_pbh_pricing_attr_tbl(1)                   := p_pricing_attr_rec;'||l_pbh_pricing_attr_tbl(1).product_attr_value);
populate_dis_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerDiscountLineId   => p_offerDiscountLineId
  , p_offDiscountProductId  => p_offDiscountProductId
  , x_modifier_line_tbl    => l_dis_modifier_line_tbl
  , p_pricing_attr_rec      => p_pricing_attr_rec
  , x_pricing_attr_tbl      => l_dis_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--dbms_output.put_line('After populate_dis_line');
merge_modifiers
(
  px_to_modifier_line_tbl    => l_pbh_modifier_line_tbl
  , p_from_modifier_line_tbl => l_dis_modifier_line_tbl
--  , x_modifier_line_tbl      => x_modifier_line_tbl
);
x_modifier_line_tbl      := l_pbh_modifier_line_tbl;
merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => l_pbh_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_dis_pricing_attr_tbl
--  , x_pricing_attr_tbl      =>x_pricing_attr_tbl
);
x_pricing_attr_tbl      := l_pbh_pricing_attr_tbl;
--dbms_output.put_line('end POpulate complete discounts');
END populate_discounts;

/**
Note not initializing the  record to attribute_grouping_no leads to unexpected error cannot insert null into qp_pricing_attributes.attribute_grouping_no
*/
/**
This method populates product attributes ie. Product Attribute, Product Attr Value , excluder flag
into a Qp_Modifiers_Pub.pricing_attr_rec_type record given the Product Id in ozf_offer_discount_products table
*/
PROCEDURE populate_product_attributes
(
 x_pricing_attr_rec         OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_rec_type
 , p_offDiscountProductId   IN NUMBER
-- , p_index IN NUMBER
)
IS
CURSOR c_productAttributes(cp_offDiscountProductId NUMBER) IS
SELECT
product_context
, product_attribute
, product_attr_value
, excluder_flag
, apply_discount_flag
, include_volume_flag
FROM
ozf_offer_discount_products
WHERE off_discount_product_id = cp_offDiscountProductId;
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_pricing_attr_rec := null;
    --dbms_output.put_line('Product Id :'||p_offDiscountProductId);
FOR l_productAttributes IN c_productAttributes(cp_offDiscountProductId => p_offDiscountProductId) LOOP
    x_pricing_attr_rec := null;
    x_pricing_attr_rec.pricing_attribute_id := FND_API.G_MISS_NUM;
    x_pricing_attr_rec.attribute_grouping_no := FND_API.G_MISS_NUM;
    x_pricing_attr_rec.product_attribute_context := l_productAttributes.product_context;
    x_pricing_attr_rec.product_attribute         := l_productAttributes.product_attribute;
    x_pricing_attr_rec.product_attr_value        := l_productAttributes.product_attr_value;
--    x_pricing_attr_rec.product_uom_code          := l_pricingAttributes.product_uom_code;
    x_pricing_attr_rec.excluder_flag             := l_productAttributes.excluder_flag;
/*    x_pricing_attr_rec.pricing_attr_value_from   := l_pricingAttributes.pricing_attr_value_from;
    x_pricing_attr_rec.pricing_attr_value_to     := l_pricingAttributes.pricing_attr_value_to;
    x_pricing_attr_rec.pricing_attribute_context := l_pricingAttributes.pricing_attribute_context;
    x_pricing_attr_rec.pricing_attribute         := l_pricingAttributes.pricing_attribute;
*/
    x_pricing_attr_rec.operation                 := Qp_Globals.G_OPR_CREATE;
--    x_pricing_attr_rec.comparison_operator_code  := l_pricingAttributes.comparison_operator_code;
--    x_pricing_attr_rec.modifiers_index           := P_INDEX;
END LOOP;
-- initialize
-- loop thru. off_discount_products and populate pricing attributes
END populate_product_attributes;

/**
This procedure creates the OZF qp mapping given the offDiscountProductId.
This is a procedure for mapping a single product in OZF to the corresponding structure in QP
The logic and assumptions used here are:
1. All the  qp_list_lines are created with the offer_discount_line_id stored in the comments.
2. The offDiscountProductId passed in is mapped to all the pricing_attribute_id 's passed in
*/
PROCEDURE map_ozf_qp_data
        (
            p_offDiscountProductId  IN NUMBER
            , p_modifiers_tbl       IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
            , p_pricing_attr_tbl    IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
            , x_return_status         OUT NOCOPY  VARCHAR2
            , x_msg_count             OUT NOCOPY  NUMBER
            , x_msg_data              OUT NOCOPY  VARCHAR2
        )
IS
l_qpDiscountsRec OZF_QP_DISCOUNTS_PVT.qp_discount_rec_type;
l_qpProductsRec OZF_QP_PRODUCTS_PVT.qp_product_rec_type;
l_qpDiscountId NUMBER;
l_qpProductId NUMBER;
l_objectVersion NUMBER;
l_prodObjectVersion NUMBER;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR i IN p_modifiers_tbl.first .. p_modifiers_tbl.last LOOP
        IF p_modifiers_tbl.exists(i) THEN
        IF p_modifiers_tbl(i).comments <> -1 THEN
            --dbms_output.put_line('Disocunt Mapping:'||i||' : '||p_modifiers_tbl(i).comments||' : '||p_modifiers_tbl(i).list_line_id);
                l_qpDiscountsRec := null;
                l_qpDiscountsRec.list_line_id            := p_modifiers_tbl(i).list_line_id;
                l_qpDiscountsRec.offer_discount_line_id  := p_modifiers_tbl(i).comments;
                l_qpDiscountsRec.start_date              := sysdate;
                OZF_QP_DISCOUNTS_PVT.Create_ozf_qp_discount
                                            (
                                                p_api_version_number         => 1.0
                                                , p_init_msg_list              => FND_API.G_FALSE
                                                , p_commit                     => FND_API.G_FALSE
                                                , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                , x_return_status              =>  x_return_status
                                                , x_msg_count                  => x_msg_count
                                                , x_msg_data                   => x_msg_data
                                                , p_qp_disc_rec                => l_qpDiscountsRec
                                                , x_qp_discount_id             => l_qpDiscountId
                                            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        END IF;
    END LOOP;
    FOR i in p_pricing_attr_tbl.first .. p_pricing_attr_tbl.last LOOP
    IF p_pricing_attr_tbl.exists(i) THEN
            --dbms_output.put_line('Product Mapping:'||i||' : '||p_offDiscountProductId||' : '||p_pricing_attr_tbl(i).pricing_attribute_id);
            l_qpProductsRec := null;
            l_qpProductsRec.off_discount_product_id := p_offDiscountProductId;
            l_qpProductsRec.pricing_attribute_id    := p_pricing_attr_tbl(i).pricing_attribute_id;
            OZF_QP_PRODUCTS_PVT.Create_ozf_qp_product(
                                                            p_api_version_number         => 1.0
                                                            , p_init_msg_list              => FND_API.G_FALSE
                                                            , p_commit                     => FND_API.G_FALSE
                                                            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                            , x_return_status              => x_return_status
                                                            , x_msg_count                  => x_msg_count
                                                            , x_msg_data                   => x_msg_data
                                                            , p_qp_product_rec             => l_qpProductsRec
                                                            , x_qp_product_id              => l_qpProductId
                                                        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    END LOOP;
END map_ozf_qp_data;

/**
This procedure maps given offDiscountProductId to every pricing_attribute_id in the given pricing_attributes table
*/
PROCEDURE map_ozf_qp_products
        (
        p_offDiscountProductId IN NUMBER
        , p_pricing_attr_tbl   IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
        , x_return_status         OUT NOCOPY  VARCHAR2
        , x_msg_count             OUT NOCOPY  NUMBER
        , x_msg_data              OUT NOCOPY  VARCHAR2
        )
IS
l_qpProductsRec OZF_QP_PRODUCTS_PVT.qp_product_rec_type;
l_qpProductId NUMBER;
l_prodObjectVersion NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR i in p_pricing_attr_tbl.first .. p_pricing_attr_tbl.last LOOP
    IF p_pricing_attr_tbl.exists(i) THEN
            l_qpProductsRec := null;
            l_qpProductsRec.off_discount_product_id := p_offDiscountProductId;
            l_qpProductsRec.pricing_attribute_id    := p_pricing_attr_tbl(i).pricing_attribute_id;
                OZF_QP_PRODUCTS_PVT.Create_ozf_qp_product(
                                                            p_api_version_number         => 1.0
                                                            , p_init_msg_list              => FND_API.G_FALSE
                                                            , p_commit                     => FND_API.G_FALSE
                                                            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                            , x_return_status              => x_return_status
                                                            , x_msg_count                  => x_msg_count
                                                            , x_msg_data                   => x_msg_data
                                                            , p_qp_product_rec             => l_qpProductsRec
                                                            , x_qp_product_id              => l_qpProductId
                                                        );
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
    END IF;
END LOOP;
END map_ozf_qp_products;

/**
Creates exclusions in All QP Discount structires corresponding to the structure to which the current exclusion is made
*/
PROCEDURE create_new_exclusions
(
    p_offDiscountProductId      IN NUMBER
    , x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  NUMBER
    , x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
l_pricing_attr_tbl      QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
i NUMBER;
CURSOR c_qpListLines(cp_offDiscountProductId NUMBER)
IS
SELECT b.list_line_id, a.product_attribute, a.product_attr_value , c.list_header_id
FROM ozf_offer_discount_products a, ozf_qp_discounts b , qp_list_lines c
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.list_line_id = c.list_line_id
AND a.off_discount_product_id = p_offDiscountProductId;

l_errorLoc NUMBER;
V_MODIFIER_LIST_rec             QP_MODIFIERS_PUB.Modifier_List_Rec_Type;
V_MODIFIER_LIST_val_rec         QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type;
V_MODIFIERS_tbl                 QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
V_MODIFIERS_val_tbl             QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type;
V_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
V_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
V_PRICING_ATTR_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
V_PRICING_ATTR_val_tbl          QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type;
BEGIN
-- initialize
-- retrieve all the qp_list_lines corresponding to the discount structure to which the exclusion is added.
-- exclude this new product from all the qp discount structures.
-- map the newly created qp_pricing_attributes to this exclusion product.
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_pricing_attr_tbl.delete;
i := 1;
FOR l_qpListLines IN c_qpListLines(cp_offDiscountProductId => p_offDiscountProductId) LOOP
    l_pricing_attr_tbl(i).product_attribute_context := 'ITEM';
    l_pricing_attr_tbl(i).product_attribute         := l_qpListLines.product_attribute;
    l_pricing_attr_tbl(i).product_attr_value        := l_qpListLines.product_attr_value;
    l_pricing_attr_tbl(i).list_line_id              := l_qpListLines.list_line_id;
    l_pricing_attr_tbl(i).list_header_id            := l_qpListLines.list_header_id;
    l_pricing_attr_tbl(i).excluder_flag             := 'Y';
    l_pricing_attr_tbl(i).operation                 := QP_GLOBALS.G_OPR_CREATE;
    --dbms_output.put_line('Details are:'||l_qpListLines.list_line_id||':'||l_qpListLines.list_header_id||':'||i);
    i := i + 1;
END LOOP;
           QP_Modifiers_PUB.process_modifiers(
                                              p_api_version_number     => 1.0,
                                              p_init_msg_list          => FND_API.G_TRUE,
                                              p_return_values          => FND_API.G_TRUE,
                                              x_return_status          => x_return_status,
                                              x_msg_count              => x_msg_count,
                                              x_msg_data               => x_msg_data,
                                              p_pricing_attr_tbl       => l_pricing_attr_tbl,
                                              x_modifier_list_rec      => v_modifier_list_rec,
                                              x_modifier_list_val_rec  => v_modifier_list_val_rec,
                                              x_modifiers_tbl          => v_modifiers_tbl,
                                              x_modifiers_val_tbl      => v_modifiers_val_tbl,
                                              x_qualifiers_tbl         => v_qualifiers_tbl,
                                              x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
                                              x_pricing_attr_tbl       => v_pricing_attr_tbl,
                                              x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
                                             );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        map_ozf_qp_products
        (
            p_offDiscountProductId => p_offDiscountProductId
            , p_pricing_attr_tbl   => v_pricing_attr_tbl
            , x_return_status          => x_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
        );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END create_new_exclusions;

/**
this procedure populates modifiers with details related to adjustements
As of now only the start_date_active
The assumption is that this procedure is called only multi-tier lines
FOr now this is used only for populating the start_date_active of new qp lines to be created
*/
PROCEDURE  process_modifiers_for_adj
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerAdjustmentId     IN   NUMBER
  , px_modifier_line_tbl    IN OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
)
IS
CURSOR c_adjDetails(cp_offerAdjustmentId NUMBER) IS
SELECT
effective_date
FROM ozf_offer_adjustments_b
WHERE offer_adjustment_id = cp_offerAdjustmentId;
l_adjDetails c_adjDetails%ROWTYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_adjDetails(cp_offerAdjustmentId => p_offerAdjustmentId);
FETCH c_adjDetails INTO l_adjDetails;
CLOSE c_adjDetails;
IF nvl(px_modifier_line_tbl.count,0) > 0 THEN
    FOR i in px_modifier_line_tbl.first .. px_modifier_line_tbl.last LOOP
        IF px_modifier_line_tbl.exists(i) THEN
            IF px_modifier_line_tbl(i).list_line_type_code = 'PBH' THEN
                px_modifier_line_tbl(i).start_date_active := l_adjDetails.effective_date;
            END IF;
        END IF;
    END LOOP;
END IF;
END process_modifiers_for_adj;

/**
Creates QP discount Structures for products entered thru. Adjustments.
As of Tue Mar 14 2006:11/21 AM  this API only processes new products entered thru. the adjustments UI.
The Updates to old products are not handled.
Even if the old discounts will be processed it will only change the definition of the offer and not affect the Volume Calculations.
*/
PROCEDURE create_new_qp_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_products(cp_offerAdjustmentId NUMBER) IS
SELECT a.off_discount_product_id
, a.offer_discount_line_id
FROM ozf_offer_adjustment_products a
WHERE offer_adjustment_id = cp_offerAdjustmentId
AND product_attr_value IS NOT NULL
AND excluder_flag = 'N';

CURSOR c_exclusions(cp_offerAdjustmentId NUMBER) IS
SELECT a.off_discount_product_id
, a.offer_discount_line_id
FROM ozf_offer_adjustment_products a
WHERE offer_adjustment_id = cp_offerAdjustmentId
AND product_attr_value IS NOT NULL
AND excluder_flag = 'Y';

l_modifier_line_tbl     QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pricing_attr_tbl      QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
l_pricing_attr_rec      QP_MODIFIERS_PUB.Pricing_Attr_Rec_Type;
i NUMBER;
l_errorLoc NUMBER;
V_MODIFIER_LIST_rec             QP_MODIFIERS_PUB.Modifier_List_Rec_Type;
V_MODIFIER_LIST_val_rec         QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type;
V_MODIFIERS_tbl                 QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
V_MODIFIERS_val_tbl             QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type;
V_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
V_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
V_PRICING_ATTR_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
V_PRICING_ATTR_val_tbl          QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type;
BEGIN
-- initialize
-- query new products entered using adjustments.
-- for each new product id get the offer_discount_line_id
-- create the whole discount structure for the product
-- map the new ozf_qp lines and products
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    i := 1;
    l_modifier_line_tbl.delete;
    l_pricing_attr_tbl.delete;
    FOR l_products IN c_products(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
    -- populate discounts
    -- populate products
    -- create qp data
    -- map ozf_qp_data
        l_pricing_attr_rec := null;
        populate_product_attributes
        (
         x_pricing_attr_rec        => l_pricing_attr_rec
         , p_offDiscountProductId  => l_products.off_discount_product_id
        -- , p_index IN NUMBER
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        populate_discounts
        (
          x_return_status           => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_offerDiscountLineId   => l_products.offer_discount_line_id
          , p_offDiscountProductId  => l_products.off_discount_product_id
          , x_modifier_line_tbl     => l_modifier_line_tbl
          , x_pricing_attr_tbl      => l_pricing_attr_tbl
          , p_pricing_attr_rec        => l_pricing_attr_rec
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        process_modifiers_for_adj
        (
           x_return_status           => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , px_modifier_line_tbl     => l_modifier_line_tbl
          , p_offerAdjustmentId     => p_offerAdjustmentId
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
           QP_Modifiers_PUB.process_modifiers(
                                              p_api_version_number     => 1.0,
                                              p_init_msg_list          => FND_API.G_TRUE,
                                              p_return_values          => FND_API.G_TRUE,
                                              x_return_status          => x_return_status,
                                              x_msg_count              => x_msg_count,
                                              x_msg_data               => x_msg_data,
                                              p_modifiers_tbl          => l_modifier_line_tbl,
                                              p_pricing_attr_tbl       => l_pricing_attr_tbl,
                                              x_modifier_list_rec      => v_modifier_list_rec,
                                              x_modifier_list_val_rec  => v_modifier_list_val_rec,
                                              x_modifiers_tbl          => v_modifiers_tbl,
                                              x_modifiers_val_tbl      => v_modifiers_val_tbl,
                                              x_qualifiers_tbl         => v_qualifiers_tbl,
                                              x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
                                              x_pricing_attr_tbl       => v_pricing_attr_tbl,
                                              x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
                                             );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --dbms_output.put_line('After Create QP Data');

        map_ozf_qp_data
        (
            p_offDiscountProductId => l_products.off_discount_product_id
            , p_modifiers_tbl          => v_modifiers_tbl
            , p_pricing_attr_tbl       => v_pricing_attr_tbl
            , x_return_status          => x_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
        );
        --dbms_output.put_line('After Map data');
    END LOOP;
        --dbms_output.put_line('Processing exclusions');
    FOR l_exclusions in c_exclusions(cp_offerAdjustmentId => p_offerAdjustmentId ) LOOP
        create_new_exclusions
        (
            p_offDiscountProductId => l_exclusions.off_discount_product_id
            , x_return_status          => x_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
        --dbms_output.put_line('End Create new qp products');

END create_new_qp_products;

/**
    This procedure processes the new products added to an offer using an offer Adjustment.
*/
PROCEDURE adjust_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
l_modifier_line_tbl     QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
l_pricing_attr_tbl      QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
        New Products are added to Particular discount tables, so discount table id is stored .
        Create new Product in OZF Tables
        Get the Discount table id for the new product and create QP list lines using the Discount table.(1)[1]
        Create new discount-tier mapping.(1)
*/
create_new_products
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
create_new_qp_products
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
  , x_modifier_line_tbl     => l_modifier_line_tbl
  , x_pricing_attr_tbl      => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( 'VOLUME_OFFER_ADJ','adjust_new_products');
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END adjust_new_products;


/**
This procedure processes a given adjustment.
It sequencially processes the discount changes made thru. the adjustment.
Then it processes the new products added thru. the adjustment.
*/
PROCEDURE process_vo_adjustments
(
  p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
BEGIN
-- initialize
-- process discount changes
-- process product additions.
x_return_status := FND_API.G_RET_STS_SUCCESS;

adjust_old_discounts
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
adjust_new_products
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END process_vo_adjustments;
END OZF_VOLUME_OFFER_ADJ;

/
