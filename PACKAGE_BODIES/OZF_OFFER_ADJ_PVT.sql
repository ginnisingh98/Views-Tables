--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_PVT" AS
/* $Header: ozfvoajb.pls 120.6.12000000.2 2007/03/21 10:12:03 nirprasa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
-- Purpose
--
-- History
--  Mon Apr 03 2006:1/38 PM RSSHARMA Added procedure updateHeaderDate to update the start date
-- of the offer if the adjustment is a backdated adjustment.
-- Fri Aug 04 2006:3/36 PM  RSSHARMA Fixed bug # 5439172. Pass start date also while end dating list lines for trade deal offers
-- Mon Aug 07 2006:7/56 PM RSSHARMA Fixed bug # 5439172. Fixed the getEndDate procedure
-- 3/21/2007 nirprasa Fixed bug # 5715744.
-- NOTE
--
-- End of Comments
-- ===============================================================
FUNCTION getAdjustmentId( p_offerAdjNewLineId IN NUMBER)
RETURN NUMBER
IS
CURSOR c_offerAdjustmentId(cp_offerAdjNewLineId NUMBER)
IS
SELECT offer_adjustment_id
FROM ozf_offer_adj_new_lines
WHERE offer_adj_new_line_id = cp_offerAdjNewLineId;
l_offerAdjustmentId NUMBER;
BEGIN
    OPEN c_offerAdjustmentId(cp_offerAdjNewLineId => p_offerAdjNewLineId);
        FETCH c_offerAdjustmentId INTO l_offerAdjustmentId;
        IF c_offerAdjustmentId%NOTFOUND THEN
            l_offerAdjustmentId := null;
        END IF;
    CLOSE c_offerAdjustmentId;
RETURN l_offerAdjustmentId;
END getAdjustmentId;

/**

*/
FUNCTION getOfferType( p_offerAdjNewLineId NUMBER)
RETURN VARCHAR2
IS
CURSOR c_offerType(cp_offerAdjNewLineId NUMBER) IS
SELECT offer_type
FROM ozf_offers a, ozf_offer_adjustments_b b, ozf_offer_adj_new_lines c
WHERE
a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = c.offer_adjustment_id
AND c.offer_adj_new_line_id = cp_offerAdjNewLineId;
l_offerType VARCHAR2(30);
BEGIN
    OPEN c_offerType(cp_offerAdjNewLineId => p_offerAdjNewLineId);
        FETCH c_offerType INTO l_offerType;
        IF c_offerType%NOTFOUND THEN
            l_offerType := null;
        END IF;
    CLOSE c_offerType;
    RETURN l_offerType;
END getOfferType;

/**
This function gets the modified discount for a list Line id
*/
FUNCTION getModifiedDiscount
(
  p_offerAdjustmentLineId IN NUMBER
)
RETURN NUMBER
IS
l_modifiedDiscount NUMBER;
CURSOR c_modifiedDiscount( cp_offerAdjustmentLineId  NUMBER)IS
SELECT a.modified_discount
FROM ozf_offer_adjustment_lines a
WHERE a.offer_adjustment_line_id = cp_offerAdjustmentLineId;
BEGIN
    OPEN c_modifiedDiscount(cp_offerAdjustmentLineId => p_offerAdjustmentLineId) ;
        FETCH c_modifiedDiscount INTO l_modifiedDiscount;
        IF c_modifiedDiscount%NOTFOUND THEN
            l_modifiedDiscount := null;
        END IF;
    CLOSE C_modifiedDiscount;
    RETURN l_modifiedDiscount;
END ;

FUNCTION getEffectiveDate
(
    p_offerAdjustmentId NUMBER
)
RETURN DATE IS
l_effectiveDate DATE;
CURSOR c_effectiveDate(cp_offerAdjustmentId NUMBER) IS
SELECT effective_date
FROM ozf_offer_adjustments_b
WHERE offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
l_effectiveDate := null;

OPEN c_effectiveDate(cp_offerAdjustmentId => p_offerAdjustmentId);
    FETCH c_effectiveDate INTO l_effectiveDate;
    IF c_effectiveDate%NOTFOUND THEN
        l_effectiveDate := null;
    END IF;
CLOSE c_effectiveDate;
return l_effectiveDate;
END getEffectiveDate;

FUNCTION getEndDate
(
    p_offerAdjustmentId NUMBER
    , p_listLineId  NUMBER
)
RETURN DATE IS
l_headerStDt DATE := NULL;
l_lineStDt DATE := NULL;
l_effectiveDt DATE := NULL;
l_tmpDt DATE := NULL;
l_endDt DATE := NULL;
l_allDtNull VARCHAR2(1) := 'N';
BEGIN
select h.start_date_active
      ,l.start_date_active
      ,a.effective_date
INTO l_headerStDt
     ,l_lineStDt
     ,l_effectiveDt
FROM ozf_offer_adjustments_b a
     ,qp_list_headers_b h
     ,qp_list_lines l
WHERE a.list_header_id = h.list_header_id
     and a.list_header_id = l.list_header_id
     and l.list_line_id = p_listLineId
     and a.offer_adjustment_id = p_offerAdjustmentId;
ozf_utility_pvt.debug_message('in getEndDate :-Adjustment Id:'||p_offerAdjustmentId || '-List Line Id:' || p_listLineId);

l_allDtNull := 'N';
IF (l_lineStDt is null) THEN
    IF (l_headerStDt is null) THEN
        l_tmpDt := l_effectiveDt;
        l_allDtNull := 'Y';
    ELSE
        l_tmpDt := l_headerStDt;
    END IF;
ELSE
    l_tmpDt := l_lineStDt;
END IF;


IF ((l_tmpDt < l_effectiveDt) or (l_allDtNull = 'Y')) THEN
     l_endDt := l_effectiveDt - 1;
ELSE
     l_endDt := l_tmpDt;
END IF;
return l_endDt;
END getEndDate;


-------------------------------------------------------------------------------------------
-- Procedure :
--  Name : update_adj_lines
--  Updates the tiers and Discounts for Volume Offer tiers
-------------------------------------------------------------------------------------------

PROCEDURE createAdjLines
(
   x_return_status         OUT  NOCOPY VARCHAR2
  ,x_msg_count             OUT  NOCOPY NUMBER
  ,x_msg_data              OUT  NOCOPY VARCHAR2
  ,p_modifiers_tbl         IN qp_modifiers_pub.modifiers_tbl_type
  ,p_offerAdjustmentId   IN NUMBER
)
IS
l_adj_line_rec OZF_Offer_Adj_Line_PVT.offadj_line_rec_type;
l_offer_adjustment_line_id NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru the lines
-- for lines with operation = create , eleminate the dis lines for multi-tier
-- for these lines create adjustment_lines with created_from_adjustment= y

   IF p_modifiers_tbl.COUNT > 0 THEN
    FOR k IN p_modifiers_tbl.first..p_modifiers_tbl.last LOOP
         IF p_modifiers_tbl.EXISTS(k) THEN

             IF p_modifiers_tbl(k).operation <> 'CREATE' THEN
                 null;
             ELSIF p_modifiers_tbl(k).list_line_type_code = 'DIS'
                    AND p_modifiers_tbl(k).modifier_parent_index <> FND_API.G_MISS_NUM
                    AND p_modifiers_tbl(k).modifier_parent_index IS NOT NULL
             THEN
                    null;
             ELSE
                l_adj_line_rec := null;
                l_adj_line_rec.offer_adjustment_id  := p_offerAdjustmentId;
                l_adj_line_rec.list_line_id         := p_modifiers_tbl(k).list_line_id;
                l_adj_line_rec.arithmetic_operator  := p_modifiers_tbl(k).arithmetic_operator;
                l_adj_line_rec.original_discount    := p_modifiers_tbl(k).operand;
                l_adj_line_rec.modified_discount    := p_modifiers_tbl(k).operand;
                l_adj_line_rec.list_header_id       := p_modifiers_tbl(k).list_header_id;
                l_adj_line_rec.created_from_adjustments := 'Y';
                IF p_modifiers_tbl(k).list_line_type_code = 'PBH' THEN
                    l_adj_line_rec.modified_discount := -1;
                    l_adj_line_rec.original_discount := -1;
                END IF;
                OZF_Offer_Adj_Line_PVT.Create_Offer_Adj_Line(
                        p_api_version_number         => 1.0
                        , p_init_msg_list              => FND_API.G_FALSE
                        , p_commit                     => FND_API.G_FALSE
                        , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                        , x_return_status              => x_return_status
                        , x_msg_count                  => x_msg_count
                        , x_msg_data                   => x_msg_data
                    --    p_offadj_line_rec              IN   offadj_line_rec_type  := g_miss_offadj_line_rec,
                        , p_offadj_line_rec              => l_adj_line_rec
                        , x_offer_adjustment_line_id   => l_offer_adjustment_line_id
                     );

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        return;
                     END IF;
             END IF;
         END IF;
     END LOOP;
   END IF;
END createAdjLines;



PROCEDURE populateDisLines
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pbhListLineId            IN   NUMBER
  ,x_modifier_line_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 , x_pricing_attr_tbl        OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_disLines(cp_pbhListLineId NUMBER) IS
SELECT to_rltd_modifier_id
FROM qp_rltd_modifiers
WHERE from_rltd_modifier_id = cp_pbhListLineId
ORDER BY to_rltd_modifier_id asc;
i NUMBER;
l_pricing_attr_tbl        QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;

BEGIN
-- initialize
-- loop thru. dis lines
-- populate discounts
-- populate pricing_attributes
-- merge pricing_attributes
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_pricing_attr_tbl.delete;
i := 2;
-- this method assumes that the pbh has been poopulated at index 1
FOR l_disLines IN c_disLines(cp_pbhListLineId => p_pbhListLineId) LOOP
    l_pricing_attr_tbl.delete;
    x_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
    x_modifier_line_tbl(i).list_line_type_code          := 'DIS';
    x_modifier_line_tbl(i).start_date_active            := null;
    x_modifier_line_tbl(i).rltd_modifier_grp_type        := 'PRICE BREAK';
    x_modifier_line_tbl(i).rltd_modifier_grp_no          := 1;
    x_modifier_line_tbl(i).modifier_parent_index         := 1;
OZF_VOLUME_OFFER_ADJ.populate_discounts
(
 x_modifiers_rec  => x_modifier_line_tbl(i)
, p_list_line_id  => l_disLines.to_rltd_modifier_id
);
OZF_VOLUME_OFFER_ADJ.populate_pricing_attributes
(
 x_pricing_attr_tbl => l_pricing_attr_tbl
 , p_list_line_id   => l_disLines.to_rltd_modifier_id
 , p_index          => i
);
OZF_VOLUME_OFFER_ADJ.merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricing_attr_tbl
);
i := i + 1;
END LOOP;
END populateDisLines;

PROCEDURE populatePbhStructure
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pbhListLineId            IN   NUMBER
  ,x_modifier_line_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 , x_pricing_attr_tbl        OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
 l_modifier_line_tbl       qp_modifiers_pub.modifiers_tbl_type;
 l_pricing_attr_tbl        QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OZF_VOLUME_OFFER_ADJ.populate_pbh_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_pbhListLineId
  , x_modifier_line_tbl     => x_modifier_line_tbl
  , x_pricing_attr_tbl      => x_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateDisLines
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_pbhListLineId         => p_pbhListLineId
  , x_modifier_line_tbl     => l_modifier_line_tbl
  , x_pricing_attr_tbl      => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

OZF_VOLUME_OFFER_ADJ.merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricing_attr_tbl
);
OZF_VOLUME_OFFER_ADJ.merge_modifiers
(
  px_to_modifier_line_tbl    => x_modifier_line_tbl
  , p_from_modifier_line_tbl => l_modifier_line_tbl
);

END populatePbhStructure;

/**
This procedure populates the discounts and start date into a PBH discount structure.
Since there are no keys to actually link the discounts to the structure, order by asc on to_rltd_modifier_id
in qp_rltd_modifiers is used during populating the original discount structure and here also, which serves as
the link
*/
PROCEDURE processPbhStructure
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pbhListLineId            IN   NUMBER
  , p_offerAdjustmentId     IN NUMBER
  ,px_modifier_line_tbl       IN OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 , px_pricing_attr_tbl        IN OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_discounts(cp_offerAdjustmentId NUMBER, cp_pbhListLineId NUMBER) IS
SELECT
nvl(a.modified_discount,c.operand) discount
FROM
ozf_offer_adjustment_lines a, qp_rltd_modifiers b,  qp_list_lines c
WHERE
a.list_line_id (+) =  b.to_rltd_modifier_id
AND b.to_rltd_modifier_id = c.list_line_id
AND b.from_rltd_modifier_id = cp_pbhListLineId
AND a.offer_adjustment_id (+) = cp_offerAdjustmentId
ORDER BY b.to_rltd_modifier_id asc;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 2;
FOR l_discounts IN c_discounts(cp_offerAdjustmentId => p_offerAdjustmentId, cp_pbhListLineId => p_pbhListLineId) LOOP
    px_modifier_line_tbl(i).operand := l_discounts.discount;
    i := i + 1;
END LOOP;
px_modifier_line_tbl(1).start_date_active := getEffectiveDate(p_offerAdjustmentId => p_offerAdjustmentId);
END processPbhStructure;


/**
Populates a limits record with limits data for a given limitId
*/
PROCEDURE populate_limits_rec
(
x_limits_rec OUT NOCOPY QP_Limits_PUB.Limits_Rec_Type
, x_return_status         OUT NOCOPY  VARCHAR2
, p_limitId IN NUMBER
)
IS
CURSOR c_limits(cp_limitId NUMBER)
IS
SELECT *
FROM qp_limits
WHERE limit_id = cp_limitId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_limits_rec := null;
FOR l_limits IN c_limits(cp_limitId => p_limitId) LOOP
x_limits_rec.attribute1              := l_limits.attribute1              ;
x_limits_rec.attribute10             := l_limits.attribute10             ;
x_limits_rec.attribute11             := l_limits.attribute11             ;
x_limits_rec.attribute12             := l_limits.attribute12             ;
x_limits_rec.attribute13             := l_limits.attribute13             ;
x_limits_rec.attribute14             := l_limits.attribute14             ;
x_limits_rec.attribute15             := l_limits.attribute15             ;
x_limits_rec.attribute2              := l_limits.attribute2              ;
x_limits_rec.attribute3              := l_limits.attribute3              ;
x_limits_rec.attribute4              := l_limits.attribute4              ;
x_limits_rec.attribute5              := l_limits.attribute5              ;
x_limits_rec.attribute6              := l_limits.attribute6              ;
x_limits_rec.attribute7              := l_limits.attribute7              ;
x_limits_rec.attribute8              := l_limits.attribute8              ;
x_limits_rec.attribute9              := l_limits.attribute9              ;
x_limits_rec.context                 := l_limits.context                 ;
x_limits_rec.limit_id                := FND_API.G_MISS_NUM;
x_limits_rec.multival_attr1_type     := l_limits.multival_attr1_type     ;
x_limits_rec.multival_attr1_context  := l_limits.multival_attr1_context  ;
x_limits_rec.multival_attribute1     := l_limits.multival_attribute1     ;
x_limits_rec.multival_attr1_datatype := l_limits.multival_attr1_datatype ;
x_limits_rec.multival_attr2_type     := l_limits.multival_attr2_type     ;
x_limits_rec.multival_attr2_context  := l_limits.multival_attr2_context  ;
x_limits_rec.multival_attribute2     := l_limits.multival_attribute2     ;
x_limits_rec.multival_attr2_datatype := l_limits.multival_attr2_datatype ;

x_limits_rec.amount                  := l_limits.amount                  ;
x_limits_rec.limit_hold_flag         := l_limits.limit_hold_flag         ;
x_limits_rec.organization_flag       := l_limits.organization_flag       ;
x_limits_rec.operation               := QP_GLOBALS.G_OPR_CREATE;
x_limits_rec.limit_level_code        := l_limits.limit_level_code        ;
x_limits_rec.basis                   := l_limits.basis                   ;
x_limits_rec.limit_number            := l_limits.limit_number            ;
x_limits_rec.limit_exceed_action_code:= FND_PROFILE.value('QP_LIMIT_EXCEED_ACTION');
--x_limits_rec.list_header_id          := l_limits.list_header_id         ;
END LOOP;
END populate_limits_rec;

/**
Populates additional information related to a list_line_id into a limits record.
*/
PROCEDURE processLimitsRec
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , px_limitsRec            IN OUT NOCOPY QP_Limits_PUB.Limits_Rec_Type
  , p_toListLineId          IN NUMBER
)
IS
CURSOR c_listHeaderId (cp_listLineId NUMBER) IS
SELECT list_header_id
FROM qp_list_lines
WHERE list_line_id = cp_listLineId;
l_listHeaderId NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_listHeaderId(cp_listLineId => p_toListLineId);
FETCH c_listHeaderId INTO l_listHeaderId;
CLOSE c_listHeaderId;
IF px_limitsRec.OPERATION IS NOT NULL OR px_limitsRec.OPERATION <> FND_API.G_MISS_CHAR THEN
    px_limitsRec.list_line_id   := p_toListLineId;
    px_limitsRec.list_header_id := l_listHeaderId;
END IF;
END processLimitsRec;

/**
Copies limits data for a list_line_id into a new list_line_id
*/
PROCEDURE copyLimits
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_fromListLineId        IN NUMBER
  , p_toListLineId         IN NUMBER
)
IS
l_limitsRec QP_Limits_PUB.Limits_Rec_Type;
  v_limits_rec                    QP_Limits_PUB.Limits_Rec_Type;
  v_limits_val_rec                QP_Limits_PUB.Limits_Val_Rec_Type;
  v_limit_attrs_tbl               QP_Limits_PUB.Limit_Attrs_Tbl_Type;
  v_limit_attrs_val_tbl           QP_Limits_PUB.Limit_Attrs_Val_Tbl_Type;
  v_limit_balances_tbl            QP_Limits_PUB.Limit_Balances_Tbl_Type;
  v_limit_balances_val_tbl        QP_Limits_PUB.Limit_Balances_Val_Tbl_Type;
BEGIN
-- initialize
-- populate limits records
-- process the limits records
-- create limits
x_return_status := FND_API.G_RET_STS_SUCCESS;

FOR l_limits in (SELECT limit_id, list_line_id FROM qp_limits WHERE list_line_id = p_fromListLineId) LOOP
populate_limits_rec
(
x_limits_rec        => l_limitsRec
, x_return_status   => x_return_status
, p_limitId    => l_limits.limit_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processLimitsRec
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , px_limitsRec            => l_limitsRec
  , p_toListLineId          => p_toListLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
  QP_Limits_PUB.Process_Limits
  ( p_init_msg_list           =>  FND_API.g_true,
    p_api_version_number      =>  1.0,
    p_commit                  =>  FND_API.g_false,
    x_return_status           =>  x_return_status,
    x_msg_count               =>  x_msg_count,
    x_msg_data                =>  x_msg_data,
    p_LIMITS_rec              =>  l_limitsRec,
    x_LIMITS_rec              =>  v_LIMITS_rec,
    x_LIMITS_val_rec          =>  v_LIMITS_val_rec,
    x_LIMIT_ATTRS_tbl         =>  v_LIMIT_ATTRS_tbl,
    x_LIMIT_ATTRS_val_tbl     =>  v_LIMIT_ATTRS_val_tbl,
    x_LIMIT_BALANCES_tbl      =>  v_LIMIT_BALANCES_tbl,
    x_LIMIT_BALANCES_val_tbl  =>  v_LIMIT_BALANCES_val_tbl
  );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      return;
  END IF;
END LOOP;

END copyLimits;

/**
Populates a qualifiers recors with Qualifier data for a given list_line_id
*/
PROCEDURE populateQualifiers
(
x_qualifiers_tbl  OUT NOCOPY QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
, p_listLineId    IN NUMBER
)
IS
CURSOR c_qualifiers(cp_listLineId NUMBER)
IS
SELECT
qualifier_id
, qualifier_grouping_no
, qualifier_context
, qualifier_attribute
, qualifier_attr_value
, comparison_operator_code
, excluder_flag
, start_date_active
, end_date_active
, qualifier_precedence
, list_header_id
, list_line_id
, qualifier_attr_value_to
, context
, attribute1
, attribute2
, attribute3
, attribute4
, attribute5
, attribute6
, attribute7
, attribute8
, attribute9
, attribute10
, attribute11
, attribute12
, attribute13
, attribute14
, attribute15
, active_flag
FROM qp_qualifiers
WHERE list_line_id = cp_listLineId;
i NUMBER;
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
x_qualifiers_tbl.delete;
i := 1;
FOR l_qualifiers in c_qualifiers(cp_listLineId => p_listLineId) LOOP
    x_qualifiers_tbl(i).qualifier_grouping_no   := l_qualifiers.qualifier_grouping_no;
    x_qualifiers_tbl(i).qualifier_context       := l_qualifiers.qualifier_context;
    x_qualifiers_tbl(i).qualifier_attribute     := l_qualifiers.qualifier_attribute;
    x_qualifiers_tbl(i).qualifier_attr_value    := l_qualifiers.qualifier_attr_value;
    x_qualifiers_tbl(i).comparison_operator_code:= l_qualifiers.comparison_operator_code;
    x_qualifiers_tbl(i).excluder_flag           := l_qualifiers.excluder_flag;
    x_qualifiers_tbl(i).start_date_active       := l_qualifiers.start_date_active;
    x_qualifiers_tbl(i).end_date_active         := l_qualifiers.end_date_active;
    x_qualifiers_tbl(i).qualifier_precedence    := l_qualifiers.qualifier_precedence;
    x_qualifiers_tbl(i).list_header_id          := l_qualifiers.list_header_id;
    x_qualifiers_tbl(i).qualifier_attr_value_to := l_qualifiers.qualifier_attr_value_to;
    x_qualifiers_tbl(i).context                 := l_qualifiers.context;
    x_qualifiers_tbl(i).attribute1              := l_qualifiers.attribute1;
    x_qualifiers_tbl(i).attribute2              := l_qualifiers.attribute2;
    x_qualifiers_tbl(i).attribute3              := l_qualifiers.attribute3;
    x_qualifiers_tbl(i).attribute4              := l_qualifiers.attribute4;
    x_qualifiers_tbl(i).attribute5              := l_qualifiers.attribute5;
    x_qualifiers_tbl(i).attribute6              := l_qualifiers.attribute6;
    x_qualifiers_tbl(i).attribute7              := l_qualifiers.attribute7;
    x_qualifiers_tbl(i).attribute8              := l_qualifiers.attribute8;
    x_qualifiers_tbl(i).attribute9              := l_qualifiers.attribute9;
    x_qualifiers_tbl(i).attribute10             := l_qualifiers.attribute10;
    x_qualifiers_tbl(i).attribute11             := l_qualifiers.attribute11;
    x_qualifiers_tbl(i).attribute12             := l_qualifiers.attribute12;
    x_qualifiers_tbl(i).attribute13             := l_qualifiers.attribute13;
    x_qualifiers_tbl(i).attribute14             := l_qualifiers.attribute14;
    x_qualifiers_tbl(i).attribute15             := l_qualifiers.attribute15;
    x_qualifiers_tbl(i).active_flag             := l_qualifiers.active_flag;
    i := i + 1;
END LOOP;
END populateQualifiers;
PROCEDURE processQualifierTable
(
    px_qualifiers_tbl  IN OUT NOCOPY QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
    , p_listLineId  IN NUMBER
)
IS
BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(px_qualifiers_tbl.count,0) > 0 THEN
    FOR i in px_qualifiers_tbl.first .. px_qualifiers_tbl.last LOOP
        IF px_qualifiers_tbl.exists(i) THEN
            px_qualifiers_tbl(i).operation      := QP_GLOBALS.G_OPR_CREATE;
            px_qualifiers_tbl(i).list_line_id   := p_listLineId;
        END IF;
    END LOOP;
END IF;

END processQualifierTable;

/**
Copies qualifiers of a qp list_line into a new qp list_line
*/
PROCEDURE copyQualifiers
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_fromListLineId        IN NUMBER
  , p_toListLineId         IN NUMBER
)
IS
l_qualifiers_tbl  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
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
--initialize
-- populate qualifiers
-- populate the new list line into the qualifiers
-- create qualifiers
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_qualifiers_tbl.delete;
populateQualifiers
(
    x_qualifiers_tbl  => l_qualifiers_tbl
    , p_listLineId    => p_fromListLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processQualifierTable
(
px_qualifiers_tbl => l_qualifiers_tbl
, p_listLineId    => p_toListLineId
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
      p_qualifiers_tbl          => l_qualifiers_tbl,
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
END copyQualifiers;

/**
COpies qualifiers from old list_line_id to a new list_line_id for records in a table.
Note the procedure assumes that the old list_line_id is populated in comments column
and the new list_line_id is populated in the list_line_id column.
*/
PROCEDURE copyQualifier
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_line_tbl     IN qp_modifiers_pub.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_modifier_line_tbl.count,0) > 0 THEN
    FOR i in p_modifier_line_tbl.first .. p_modifier_line_tbl.last LOOP
        IF p_modifier_line_tbl.exists(i) THEN
            copyQualifiers
            (
              x_return_status          => x_return_status
              , x_msg_count             => x_msg_count
              , x_msg_data              => x_msg_data
              , p_fromListLineId        => to_number( p_modifier_line_tbl(i).comments)
              , p_toListLineId         => p_modifier_line_tbl(i).list_line_id
            );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
         END IF;
        END IF;
    END LOOP;
END IF;
END copyQualifier;

/**
COpies Limits from old list_line_id to a new list_line_id for records in a table.
Note the procedure assumes that the old list_line_id is populated in comments column
and the new list_line_id is populated in the list_line_id column.
*/
PROCEDURE copyLimit
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_line_tbl     IN qp_modifiers_pub.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_modifier_line_tbl.count,0) > 0 THEN
    FOR i in p_modifier_line_tbl.first .. p_modifier_line_tbl.last LOOP
        IF p_modifier_line_tbl.exists(i) THEN
        copyLimits
        (
              x_return_status          => x_return_status
              , x_msg_count             => x_msg_count
              , x_msg_data              => x_msg_data
              , p_fromListLineId        => to_number( p_modifier_line_tbl(i).comments)
              , p_toListLineId         => p_modifier_line_tbl(i).list_line_id
        );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
         END IF;
        END IF;
    END LOOP;
END IF;

END copyLimit;

/**
Copies a details of a pbh line into a new pbh line
*/
PROCEDURE copyPbhLine
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pbhListLineId            IN   NUMBER
  ,p_offerAdjustmentId   IN   NUMBER
  ,x_modifier_line_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  )
  IS

l_pbhLineId NUMBER;
l_modifier_line_tbl       qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl        QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;

V_MODIFIER_LIST_rec             QP_MODIFIERS_PUB.Modifier_List_Rec_Type;
V_MODIFIER_LIST_val_rec         QP_MODIFIERS_PUB.Modifier_List_Val_Rec_Type;
V_MODIFIERS_tbl                 QP_MODIFIERS_PUB.Modifiers_Tbl_Type;
V_MODIFIERS_val_tbl             QP_MODIFIERS_PUB.Modifiers_Val_Tbl_Type;
V_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
V_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
V_PRICING_ATTR_tbl              QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
V_PRICING_ATTR_val_tbl          QP_MODIFIERS_PUB.Pricing_Attr_Val_Tbl_Type;
BEGIN
  -- initialise
  -- populate lines
  -- copy list line
  -- copy qualifiers
  -- copy limits
  -- return created lines
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_modifier_line_tbl.delete;
  populatePbhStructure
  (
  x_return_status          => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_pbhListLineId          => p_pbhListLineId
  ,x_modifier_line_tbl      => l_modifier_line_tbl
 , x_pricing_attr_tbl       => l_pricing_attr_tbl
  );
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  processPbhStructure
  (
    x_return_status          => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_pbhListLineId          => p_pbhListLineId
  ,p_offerAdjustmentId      => p_offerAdjustmentId
  ,px_modifier_line_tbl      => l_modifier_line_tbl
 , px_pricing_attr_tbl       => l_pricing_attr_tbl
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
copyQualifier
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifier_line_tbl       => v_modifiers_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyLimit
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifier_line_tbl       => v_modifiers_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
x_modifier_line_tbl := v_modifiers_tbl;
  END copyPbhLine;

PROCEDURE processOldPbhLines
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
l_phbLineId NUMBER;
l_modifier_line_tbl       qp_modifiers_pub.modifiers_tbl_type;
CURSOR c_pbhLines(cp_offerAdjustmentId NUMBER) IS
SELECT distinct b.from_rltd_modifier_id
FROM ozf_offer_adjustment_lines a, qp_rltd_modifiers b
WHERE a.list_line_id  = b.to_rltd_modifier_id
AND a.offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
-- initialize
-- end date line
-- copy line
-- relate lines
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_pbhLines IN c_pbhLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
OZF_VOLUME_OFFER_ADJ.end_qp_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => l_pbhLines.from_rltd_modifier_id
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyPbhLine
(
 x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId     => p_offerAdjustmentId
  , p_pbhListLineId        => l_pbhLines.from_rltd_modifier_id
  ,x_modifier_line_tbl       => l_modifier_line_tbl
 );
 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

OZF_VOLUME_OFFER_ADJ.relate_lines
(
 p_modifiers_tbl          => l_modifier_line_tbl
  , p_offer_adjustment_id => p_offerAdjustmentId
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END LOOP;
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END processOldPbhLines;


/**
Given the list line Id, this procedure populates the list_line details and pricing attribute details
in the modifier table and pricing attributes table respectively
Note the assumption here is that the input list_line_id is the primary list_line_id/
ie. for Multi-tier discount it is the PBH line id.
*/
PROCEDURE populate_dis_qp_data
(
  x_return_status          OUT NOCOPY  VARCHAR2
 , x_msg_count             OUT NOCOPY  NUMBER
 , x_msg_data              OUT NOCOPY  VARCHAR2
 , p_listLineId            IN NUMBER
 , x_modifier_line_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 , x_pricing_attr_tbl        OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_listLineDetails(cp_listLineId NUMBER) IS
    SELECT
    list_line_id
    FROM qp_list_lines
    WHERE list_line_id = cp_listLineId;
i NUMBER;
l_pricing_attr_tbl QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
-- initialize
-- loop thru. list Lines
-- populate list_lines progressively
-- populate the new discounts and start date
-- populate pricing_attributes
-- merge pricing attributes -> required, since each pricing_attribute can have multiple pricing attributes
-- so the API returning pricing attributes returns a table, each time you get a table it has to be merged with
-- existing table
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_pricing_attr_tbl.delete;
i := 1;
FOR l_listLineDetails in c_listLineDetails(cp_listLineId => p_listLineId) LOOP
l_pricing_attr_tbl.delete;
x_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
x_modifier_line_tbl(i).automatic_flag               := 'Y';
OZF_VOLUME_OFFER_ADJ.populate_discounts
(
 x_modifiers_rec  => x_modifier_line_tbl(i)
, p_list_line_id  => l_listLineDetails.list_line_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_VOLUME_OFFER_ADJ.populate_pricing_attributes
(
 x_pricing_attr_tbl => l_pricing_attr_tbl
 , p_list_line_id   => p_listLineId
 , p_index          => i
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_VOLUME_OFFER_ADJ.merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
i := i + 1;
END LOOP;
END populate_dis_qp_data;

PROCEDURE populate_adjustments_data
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,x_modifier_line_tbl      IN OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  ,p_offerAdjustmentId      IN NUMBER
  ,p_offerAdjustmentLineId  IN NUMBER
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR i in x_modifier_line_tbl.first .. x_modifier_line_tbl.last LOOP
    IF nvl(x_modifier_line_tbl.count,0) > 0 THEN
        IF x_modifier_line_tbl.exists(i) THEN
            x_modifier_line_tbl(i).operand          := getModifiedDiscount(p_offerAdjustmentLineId => p_offerAdjustmentLineId );
            x_modifier_line_tbl(i).start_date_active:= getEffectiveDate(p_offerAdjustmentId => p_offerAdjustmentId);
        END IF;
    END IF;
END LOOP;
END populate_adjustments_data;
/**
Creates a copy of a QP list line
*/
PROCEDURE create_dis_line
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_listLineId            IN   NUMBER
  ,x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  ,x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId      IN NUMBER
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
-- initialize
-- populate data from qp_list_line
-- populate adjustments data
-- create qp data
-- return created tables and pricing attributes
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;

populate_dis_qp_data
(
 x_return_status          => x_return_status
 , x_msg_count             => x_msg_count
 , x_msg_data              => x_msg_data
 , p_listLineId            => p_listLineId
 , x_modifier_line_tbl       => x_modifier_line_tbl
 , x_pricing_attr_tbl        => x_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populate_adjustments_data
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,x_modifier_line_tbl     => x_modifier_line_tbl
  ,p_offerAdjustmentId => p_offerAdjustmentId
  ,p_offerAdjustmentLineId => p_offerAdjustmentLineId
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
      p_modifiers_tbl          => x_modifier_line_tbl,
      p_pricing_attr_tbl       => x_pricing_attr_tbl,
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

    IF nvl(x_modifier_line_tbl.count,0) > 0 THEN
        FOR i IN x_modifier_line_tbl.first .. x_modifier_line_tbl.last LOOP
            IF x_modifier_line_tbl.exists(i) THEN
                        x_listLineId := x_modifier_line_tbl(i).list_line_id;
            END IF;
        END LOOP;
    END IF;
/*OZF_OFFER_PVT.process_qp_list_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,p_list_header_id        IN   NUMBER
 ,x_modifier_line_tbl     OUT NOCOPY  qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
);
*/
END create_dis_line;




/**
This procedure copies a qp_list_line into a new list_line.
It copies the qp_list_line, the pricing_attributes, including exclusions, the advanced options and the limits
*/
PROCEDURE copyListLine
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN   NUMBER
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId      IN NUMBER
)
IS
l_modifier_line_tbl       qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl        QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
-- initialise
-- create Discount lines and pricing attributes(including exclusions)
-- create qualifiers
-- create limits
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;
create_dis_line
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_listLineId            => p_listLineId
  ,x_modifier_line_tbl     => l_modifier_line_tbl
  ,x_pricing_attr_tbl      => l_pricing_attr_tbl
  , x_listLineId           => x_listLineId
  , p_offerAdjustmentLineId => p_offerAdjustmentLineId
  , p_offerAdjustmentId     => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyQualifiers
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_fromListLineId        => p_listLineId
  , p_toListLineId         => x_listLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyLimits
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_fromListLineId        => p_listLineId
  , p_toListLineId         => x_listLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END copyListLine;


/**
Processes a simple Discount Line, ie a list_line_id of the type DIS.
It end dates the given list_line_id with the Effective date of the adjustment.
Creates a new Line with start Date as effective date of the Adjustment.
Creates relation between the new and old lines.
*/
PROCEDURE process_old_dis_discount
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_listLineId             IN  NUMBER
  ,p_offerAdjustmentId      IN   NUMBER
  , p_offerAdjustmentLineId IN NUMBER
)
IS
CURSOR c_listLineId(cp_offerAdjustmentLineId NUMBER) IS
SELECT list_line_id
FROM ozf_offer_adjustment_lines
WHERE offer_adjustment_line_id = cp_offerAdjustmentLineId;
l_listLineId NUMBER;
BEGIN
-- initialize
-- end date existing line
-- create new qp_list_line/s
-- create new to old mapping
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- check if list_line_id is passed in, in case not, get the list_line_id from the offer_adjustment_line_id, if cannot be located
--  raise error

IF p_offerAdjustmentLineId IS NULL OR p_offerAdjustmentLineId = FND_API.G_MISS_NUM THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'INVALID_ADJUSTMENT_LINE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
END IF;
/*
IF (p_listLineId IS NULL OR p_listLineId = FND_API.G_MISS_NUM) THEN
OPEN c_listLineId(cp_offerAdjustmentLineId => p_offerAdjustmentLineId);
    FETCH c_listLineId INTO l_listLineId;
    IF c_listLineId%NOTFOUND THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'INVALID_LIST_LINE');
         x_return_status := FND_API.g_ret_sts_error;
         CLOSE c_listLineId;
         RETURN;
    END IF;
CLOSE c_listLineId;
p_listLineId := l_listLineId;
END IF;
*/
OZF_VOLUME_OFFER_ADJ.end_qp_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyListLine
(
  x_return_status          => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  , x_listLineId           => l_listLineId
  , p_offerAdjustmentLineId => p_offerAdjustmentLineId
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_VOLUME_OFFER_ADJ.relate_lines
(
  p_from_list_line_id       => p_listLineId
  , p_to_list_line_id       => l_listLineId
  , p_offer_adjustment_id   => p_offerAdjustmentId
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END process_old_dis_discount;




PROCEDURE processOldDisLines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjustmentLines(cp_offerAdjustmentId NUMBER)
IS
SELECT a.list_line_id, b.list_line_type_code , a.offer_adjustment_line_id
FROM ozf_offer_adjustment_lines a, qp_list_lines b
WHERE
a.list_line_id = b.list_line_id
AND b.qualification_ind in (0,2,4,6,8,10,12,14,16,18,20,22,24,26, 28, 30, 32)
AND offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_adjustmentLines IN c_adjustmentLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
process_old_dis_discount
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => l_adjustmentLines.list_line_id
  , p_offerAdjustmentId     => p_offerAdjustmentId
  , p_offerAdjustmentLineId => l_adjustmentLines.offer_adjustment_line_id
);
END LOOP;
END processOldDisLines;

/**
Process an Adjustment on an Off-Invoice or Accrual offers
*/
PROCEDURE process_old_reg_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
BEGIN
-- initialize
-- loop thru. adjustment lines
-- for each adjustment line end date the existing qp_list_line and create new qp_list_line
x_return_status := FND_API.G_RET_STS_SUCCESS;
processOldDisLines
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId     => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processOldPbhLines
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId     => p_offerAdjustmentId
);

END process_old_reg_discount;

PROCEDURE populatePgDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_listLineId            IN NUMBER
  , x_pricing_attr_tbl      OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
)
IS
/**
This cursor probably may have issues and we may have to join qp_list_lines and put a filter on list_line_type_code = PRG
*/
CURSOR c_getPrgLineId(cp_listLineId NUMBER) IS
SELECT from_rltd_modifier_id
FROM qp_rltd_modifiers
WHERE rltd_modifier_grp_type = 'BENEFIT'
AND rltd_modifier_grp_no  = 1
AND to_rltd_modifier_id = cp_listLineId;

l_getPrgLineId c_getPrgLineId%ROWTYPE;
BEGIN
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;

populate_dis_qp_data
(
 x_return_status          => x_return_status
 , x_msg_count             => x_msg_count
 , x_msg_data              => x_msg_data
 , p_listLineId            => p_listLineId
 , x_modifier_line_tbl       => x_modifier_line_tbl
 , x_pricing_attr_tbl        => x_pricing_attr_tbl
);

IF nvl(x_modifier_line_tbl.count,0) > 0 THEN
  OPEN c_getPrgLineId(cp_listLineId => p_listLineId);
      FETCH c_getPrgLineId INTO l_getPrgLineId;
  CLOSE c_getPrgLineId;
    FOR i IN x_modifier_line_tbl.first .. x_modifier_line_tbl.last LOOP
        IF x_modifier_line_tbl.exists(i) THEN
                x_modifier_line_tbl(i).from_rltd_modifier_id  := l_getPrgLineId.from_rltd_modifier_id;
                x_modifier_line_tbl(i).rltd_modifier_grp_type := 'BENEFIT';
                x_modifier_line_tbl(i).rltd_modifier_grp_no   := 1;
        END IF;
    END LOOP;
END IF;
END populatePgDiscounts;

PROCEDURE processPgDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId     IN NUMBER
  , x_pricing_attr_tbl      IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
  , x_modifier_line_tbl     IN OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR i in x_modifier_line_tbl.first .. x_modifier_line_tbl.last LOOP
IF x_modifier_line_tbl.exists(i) THEN
    x_modifier_line_tbl(i).operand              := getModifiedDiscount(p_offerAdjustmentLineId => p_offerAdjustmentLineId);
    x_modifier_line_tbl(i).start_date_active    := getEffectiveDate(p_offerAdjustmentId => p_offerAdjustmentId);
END IF;
END LOOP;
END processPgDiscounts;

PROCEDURE createPgLine
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_listLineId            IN NUMBER
  , x_listLineId            OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId     IN NUMBER
  , x_pricing_attr_tbl      OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
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
BEGIN
-- initialize
-- populate modifiers table and pricing attribute table
-- process modifiers table and pricing attribute table
-- create qp data
-- return list_line_id
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_pricing_attr_tbl.delete;
x_modifier_line_tbl.delete;
populatePgDiscounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_listLineId            => p_listLineId
  , x_pricing_attr_tbl      => x_pricing_attr_tbl
  , x_modifier_line_tbl     => x_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processPgDiscounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , x_pricing_attr_tbl      => x_pricing_attr_tbl
  , x_modifier_line_tbl     => x_modifier_line_tbl
  , p_offerAdjustmentLineId => p_offerAdjustmentLineId
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
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => x_modifier_line_tbl,
      p_pricing_attr_tbl       => x_pricing_attr_tbl,
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

    x_pricing_attr_tbl      := v_pricing_attr_tbl;
    x_modifier_line_tbl     := v_modifiers_tbl;

FOR i in v_modifiers_tbl.first .. v_modifiers_tbl.last LOOP
    IF v_modifiers_tbl.exists(i) THEN
        x_listLineId := v_modifiers_tbl(i).list_line_id;
    END IF;
END LOOP;
END createPgLine;


PROCEDURE copyPGListLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId           IN NUMBER
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  ,p_offerAdjustmentId   IN NUMBER
)
IS
l_modifier_line_tbl       qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl        QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
-- initialise
-- create Discount lines and pricing attributes(including exclusions)
-- create qualifiers
-- create limits
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;
createPgLine
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_listLineId            => p_listLineId
  ,x_modifier_line_tbl     => l_modifier_line_tbl
  ,x_pricing_attr_tbl      => l_pricing_attr_tbl
  , x_listLineId           => x_listLineId
  , p_offerAdjustmentLineId => p_offerAdjustmentLineId
  , p_offerAdjustmentId     => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyQualifiers
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_fromListLineId        => p_listLineId
  , p_toListLineId         => x_listLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyLimits
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_fromListLineId        => p_listLineId
  , p_toListLineId         => x_listLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END copyPGListLine;

PROCEDURE processOldPgDiscount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentLineId   IN   NUMBER
  , p_offerAdjustmentId     in NUMBER
  , p_listLineId            IN NUMBER
)
IS
l_listLineId NUMBER;
BEGIN
-- initialize
-- end date existing line
-- create new qp_list_line/s
-- create new to old mapping
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- check if list_line_id is passed in, in case not, get the list_line_id from the offer_adjustment_line_id, if cannot be located
--  raise error
/*IF p_offerAdjustmentLineId IS NULL OR p_offerAdjustmentLineId = FND_API.G_MISS_NUM THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'INVALID_ADJUSTMENT_LINE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
END IF;
*/
OZF_VOLUME_OFFER_ADJ.end_qp_line
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyPGListLine
(
  x_return_status          => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_listLineId            => p_listLineId
  , x_listLineId           => l_listLineId
  , p_offerAdjustmentLineId => p_offerAdjustmentLineId
  ,p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_VOLUME_OFFER_ADJ.relate_lines
(
  p_from_list_line_id       => p_listLineId
  , p_to_list_line_id       => l_listLineId
  , p_offer_adjustment_id   => p_offerAdjustmentId
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END processOldPgDiscount;

PROCEDURE process_old_pg_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_listLine(cp_offerAdjustmentId NUMBER)IS
SELECT list_line_id, offer_adjustment_line_id
FROM ozf_offer_adjustment_lines
WHERE offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_listLine in c_listLine(cp_offerAdjustmentId => p_offerAdjustmentId ) LOOP
    processOldPgDiscount
    (
      x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , p_offerAdjustmentId => p_offerAdjustmentId
      , p_offerAdjustmentLineId => l_listLine.offer_adjustment_line_id
      , p_listLineId            => l_listLine.list_line_id
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END LOOP;
END process_old_pg_discount;


PROCEDURE populateTdPricingAttr
(
  px_modifier_line_rec      IN OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_REC_TYPE
  , p_listLineId         IN NUMBER
  ,x_return_status         OUT  NOCOPY VARCHAR2
  ,x_msg_count             OUT  NOCOPY NUMBER
  ,x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_pricingAttr IN (SELECT product_attribute, product_attr_value, product_uom_code,pricing_attribute,  pricing_attr_value_from
                        FROM qp_pricing_attributes
                        WHERE list_line_id = p_listLineId
                        AND excluder_flag = 'N')
LOOP
    px_modifier_line_rec.product_attr             := l_pricingAttr.product_attribute;
    px_modifier_line_rec.product_attr_val         := l_pricingAttr.product_attr_value;
    px_modifier_line_rec.product_uom_code         := l_pricingAttr.product_uom_code;
    px_modifier_line_rec.pricing_attr             := l_pricingAttr.pricing_attribute;
    px_modifier_line_rec.pricing_attr_value_from  := l_pricingAttr.pricing_attr_value_from;
END LOOP;
END populateTdPricingAttr;

PROCEDURE populateTdCrtLines
(
  x_modifier_line_rec      OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_REC_TYPE
  , p_listLineId         IN NUMBER
  , x_return_status         OUT  NOCOPY VARCHAR2
  , x_msg_count             OUT  NOCOPY NUMBER
  , x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
CURSOR c_tdAdjustmentLines(cp_listLineId NUMBER) IS
SELECT
a.list_header_id
, a.list_line_id
, decode(nvl(a.accrual_flag,'N'),'N',a.arithmetic_operator, c.arithmetic_operator) operator
, decode(nvl(a.accrual_flag,'N'),'Y',a.arithmetic_operator, c.arithmetic_operator) accrual_operator
FROM
qp_list_lines a
, ozf_related_deal_lines b
, qp_list_lines c
WHERE
a.list_line_id = b.MODIFIER_ID
AND b.RELATED_MODIFIER_ID = c.list_line_id(+)
AND a.list_line_id =cp_listLineId;

l_modifier_line_rec ozf_offer_pvt.MODIFIER_LINE_REC_TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_tdAdjustmentLines IN c_tdAdjustmentLines(cp_listLineId => p_listLineId )
LOOP
    l_modifier_line_rec.operation                := 'CREATE';
    l_modifier_line_rec.list_line_type_code      := 'DIS';
    l_modifier_line_rec.list_header_id           := l_tdAdjustmentLines.list_header_id;
    l_modifier_line_rec.end_date_active          := null;
    l_modifier_line_rec.arithmetic_operator      := l_tdAdjustmentLines.operator;
--    l_modifier_line_rec.operand                  := l_tdAdjustmentLines.modified_discount;
    l_modifier_line_rec.qd_arithmetic_operator   := l_tdAdjustmentLines.accrual_operator;
--    l_modifier_line_rec.qd_operand               := l_tdAdjustmentLines.modified_discount_td;
    populateTdPricingAttr
    (
      px_modifier_line_rec      => l_modifier_line_rec
      , p_listLineId         => p_listLineId
      ,x_return_status          => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
END LOOP;
x_modifier_line_rec := l_modifier_line_rec;
END populateTdCrtLines;

PROCEDURE processTdCrtLines
(
  px_modifier_line_rec      IN OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_REC_TYPE
  , p_offerAdjustmentId     IN NUMBER
  , p_listLineId            IN NUMBER
  , x_return_status         OUT  NOCOPY VARCHAR2
  , x_msg_count             OUT  NOCOPY NUMBER
  , x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
CURSOR c_tdCrtLineDetails(cp_offerAdjustmentId NUMBER, cp_listLineId NUMBER) IS
SELECT b.effective_date
, nvl(a.modified_discount,a.original_discount) discount
, nvl(a.modified_discount_td, a.original_discount_td) discount_td
FROM ozf_offer_adjustment_lines a, ozf_offer_adjustments_b b
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND a.offer_adjustment_id = cp_offerAdjustmentId
AND a.list_line_id = cp_listLineId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_tdCrtLineDetails in c_tdCrtLineDetails(cp_offerAdjustmentId => p_offerAdjustmentId, cp_listLineId => p_listLineId) LOOP
    px_modifier_line_rec.start_date_active  := getEffectiveDate(p_offerAdjustmentId => p_offerAdjustmentId);
    px_modifier_line_rec.operand            := l_tdCrtLineDetails.discount;
    px_modifier_line_rec.qd_operand         := l_tdCrtLineDetails.discount_td;
END LOOP;
END processTdCrtLines;

PROCEDURE populateTdUpdLines
(
  x_modifier_line_rec      OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_REC_TYPE
  , p_listLineId           IN NUMBER
  ,x_return_status         OUT  NOCOPY VARCHAR2
  ,x_msg_count             OUT  NOCOPY NUMBER
  ,x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
CURSOR c_tdUpdAdjustmentLines(cp_listLineId NUMBER) IS
SELECT
decode(nvl(a.accrual_flag,'N'),'N',b.modifier_id,b.related_modifier_id) list_line_id
, a.list_header_id
, a.accrual_flag
--, greatest(a.start_date_active, d.start_date_active) start_date_active
, decode(nvl(a.accrual_flag,'N'),'N',a.arithmetic_operator, c.arithmetic_operator) arithmetic_operator
, decode(nvl(a.accrual_flag,'N'),'Y',a.arithmetic_operator, c.arithmetic_operator) arithmetic_operator_td
, decode(nvl(a.accrual_flag,'N'),'N',a.operand, c.operand) operand
, decode(nvl(a.accrual_flag,'N'),'Y',a.operand,c.operand) operand_td
, decode(nvl(a.accrual_flag,'N'),'Y',b.modifier_id, b.related_modifier_id) related_modifier_id
, b.related_deal_lines_id
, b.object_version_number
, a.start_date_active
FROM
 qp_list_lines a
, ozf_related_deal_lines b
, qp_list_lines c
, qp_list_headers_b d
WHERE
a.list_line_id = b.modifier_id
AND b.related_modifier_id = c.list_line_id(+)
AND a.list_header_id = d.list_header_id
AND a.list_line_id = cp_listLineId;

l_modifier_line_rec      ozf_offer_pvt.MODIFIER_LINE_REC_TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_tdUpdAdjustmentLines IN c_tdUpdAdjustmentLines(cp_listLineId => p_listLineId)
LOOP
    l_modifier_line_rec.operation := 'UPDATE';
    l_modifier_line_rec.list_line_id             := l_tdUpdAdjustmentLines.list_line_id;
    l_modifier_line_rec.list_header_id           := l_tdUpdAdjustmentLines.list_header_id;
    l_modifier_line_rec.inactive_flag            := 'Y';
    l_modifier_line_rec.arithmetic_operator      := l_tdUpdAdjustmentLines.arithmetic_operator;
    l_modifier_line_rec.operand                  := l_tdUpdAdjustmentLines.operand;
    l_modifier_line_rec.qd_arithmetic_operator   := l_tdUpdAdjustmentLines.arithmetic_operator_td;
    l_modifier_line_rec.qd_operand               := l_tdUpdAdjustmentLines.operand_td;
    l_modifier_line_rec.qd_list_line_id          := l_tdUpdAdjustmentLines.related_modifier_id;
    l_modifier_line_rec.qd_related_deal_lines_id := l_tdUpdAdjustmentLines.related_deal_lines_id;
    l_modifier_line_rec.qd_object_version_number := l_tdUpdAdjustmentLines.object_version_number;
    l_modifier_line_rec.start_date_active        := l_tdUpdAdjustmentLines.start_date_active;
END LOOP;
x_modifier_line_rec := l_modifier_line_rec;
END populateTdUpdLines;

PROCEDURE processTdUpdLines
(
  px_modifier_line_rec      IN OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_REC_TYPE
  , p_offerAdjustmentId    IN NUMBER
  , p_listLineId            IN NUMBER
  ,x_return_status         OUT  NOCOPY VARCHAR2
  ,x_msg_count             OUT  NOCOPY NUMBER
  ,x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    px_modifier_line_rec.end_date_active := getEndDate( p_offerAdjustmentId => p_offerAdjustmentId , p_listLineId => p_listLineId);
END processTdUpdLines;


PROCEDURE createTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_modifier_tbl          OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
)

IS
l_modifier_line_tbl      ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE;
lx_modifier_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
l_errorLocation NUMBER;
BEGIN
-- initialize
-- populate td lines
-- process td lines
-- create discount rules
-- return table created
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
populateTdCrtLines
(
  x_modifier_line_rec      => l_modifier_line_tbl(1)
  , p_listLineId         => p_listLineId
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);
----dbms_output.put_line('Populated creat lines');
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processTdCrtLines
(
  px_modifier_line_rec      => l_modifier_line_tbl(1)
  , p_listLineId            => p_listLineId
  , p_offerAdjustmentId     => p_offerAdjustmentId
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);
----dbms_output.put_line('Processed creat lines:'|| l_modifier_line_tbl(1).list_line_id||':'||l_modifier_line_tbl(1).product_attr_val||l_modifier_line_tbl(1).list_header_id);
--dbms_output.put_line('operand:'|| l_modifier_line_tbl(1).operand||':'||l_modifier_line_tbl(1).qd_operand);
--dbms_output.put_line('Arithmetic operator:'|| l_modifier_line_tbl(1).arithmetic_operator||':'||l_modifier_line_tbl(1).qd_arithmetic_operator);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_offer_pvt.process_qp_list_lines
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offer_type            => 'DEAL'
  ,p_modifier_line_tbl     => l_modifier_line_tbl
  ,p_list_header_id        => l_modifier_line_tbl(1).list_header_id
  ,x_modifier_line_tbl     => lx_modifier_tbl --QP_MODIFIERS_PUB.modifiers_tbl_type
  ,x_error_location        => l_errorLocation
 );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_modifier_tbl := lx_modifier_tbl;

EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END createTdLine;

PROCEDURE populateTdExclusion
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_fromListLineId       IN NUMBER
  ,x_pricing_attr_tbl     OUT NOCOPY OZF_OFFER_PVT.PRICING_ATTR_TBL_TYPE
)
IS
i NUMBER;
CURSOR c_productAttributes(cp_listLineId NUMBER)
IS
SELECT product_attribute, product_attr_value , list_header_id
FROM qp_pricing_attributes
WHERE list_line_id = cp_listLineId
and excluder_flag = 'Y';
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_pricing_attr_tbl.delete;
i := 0;
--dbms_output.put_line('inside loop1'||p_fromListLineId);
FOR l_productAttributes IN c_productAttributes(cp_listLineId => p_fromListLineId)
LOOP
    i := i + 1;
--dbms_output.put_line('inside loop2'||i);
    x_pricing_attr_tbl(i).product_attribute := l_productAttributes.product_attribute;
    x_pricing_attr_tbl(i).product_attr_value := l_productAttributes.product_attr_value;
--    x_pricing_attr_tbl(i).list_header_id     := l_productAttributes.list_header_id;
    --dbms_output.put_line('inside loop2:'||x_pricing_attr_tbl(i).product_attribute);
    --dbms_output.put_line('inside loop2:'||x_pricing_attr_tbl(i).product_attr_value);
END LOOP;
----dbms_output.put_line(sqlerrm);
END populateTdExclusion;

PROCEDURE processTdExclusion
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_toListLineId       IN NUMBER
  ,px_pricing_attr_tbl    IN OUT NOCOPY OZF_OFFER_PVT.PRICING_ATTR_TBL_TYPE
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(px_pricing_attr_tbl.count,0) > 0 THEN
    FOR i in px_pricing_attr_tbl.first .. px_pricing_attr_tbl.last LOOP
        IF px_pricing_attr_tbl.exists(i) THEN
            px_pricing_attr_tbl(i).list_line_id := p_toListLineId;
            px_pricing_attr_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;
        END IF;
    END LOOP;
END IF;
END processTdExclusion;


PROCEDURE copyListLineExclusion
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_fromListLineId IN NUMBER
  ,p_toListLineId IN NUMBER
)
IS
 l_pricing_attr_tbl      OZF_OFFER_PVT.PRICING_ATTR_TBL_TYPE;
 l_errorLocation NUMBER;
BEGIN
-- initialize
-- populate records
--create exclusions
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_pricing_attr_tbl.delete;
populateTdExclusion
(
 p_fromListLineId       => p_fromListLineId
,x_pricing_attr_tbl     => l_pricing_attr_tbl
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processTdExclusion
(
    p_toListLineId       => p_toListLineId
    ,px_pricing_attr_tbl     => l_pricing_attr_tbl
    ,x_return_status         => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--dbms_output.put_line('Table cnt is :'||nvl(l_pricing_attr_tbl.count,0));
OZF_OFFER_PVT.process_exclusions
(
   p_init_msg_list         => FND_API.G_FALSE
  ,p_api_version           => 1.0
  ,p_commit                => FND_API.G_FALSE
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_pricing_attr_tbl      => l_pricing_attr_tbl
  ,x_error_location        => l_errorLocation
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
--dbms_output.put_line(sqlerrm);
x_return_status := FND_API.G_RET_STS_ERROR;
OE_MSG_PUB.count_and_get(
     p_count => x_msg_count
    , p_data  => x_msg_data
    );
END copyListLineExclusion;

/**
COpies Line level limits from a given qp_list_line to another qp_list_line
 * p_listLineId     List Line used to fetch the limits
 * p_modifier_tbl   the Table used to fetch the newly created list lines into which the limits are to be copied
*/
PROCEDURE copyTdLimits
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_listLineId        IN NUMBER
  , p_modifier_tbl          IN QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_modifier_tbl.count,0) > 0 THEN
    FOR i in p_modifier_tbl.first .. p_modifier_tbl.last LOOP
        IF p_modifier_tbl.exists(i) THEN
        copyLimits
        (
          x_return_status          => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_fromListLineId        => p_listLineId
          , p_toListLineId => p_modifier_tbl(i).list_line_id
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        END IF;
    END LOOP;
END IF;
END copyTdLimits;

/**
Copies Exclusions from a given qp_list_line to another qp_list_line
 * p_listLineId     List Line used to fetch the Exclusions
 * p_modifier_tbl   the Table used to fetch the newly created list lines into which the exclusions are to be copied
*/
PROCEDURE copyTdExclusions
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN NUMBER
  , x_modifier_tbl          IN QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru. modifiers tbl
-- for each list_line_id in the table copy exclusion
IF nvl(x_modifier_tbl.count,0) > 0 THEN
    FOR i in x_modifier_tbl.first .. x_modifier_tbl.last LOOP
        IF x_modifier_tbl.exists(i) THEN
            copyListLineExclusion
            (
              x_return_status         => x_return_status
              ,x_msg_count             => x_msg_count
              ,x_msg_data              => x_msg_data
              ,p_fromListLineId => p_listLineId
             , p_toListLineId => x_modifier_tbl(i).list_line_id
            );
            --dbms_output.PUT_LINE('List line id passed in is:'||p_listLineId||':'||x_modifier_tbl(i).list_line_id);
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END LOOP;
END IF;
END copyTdExclusions;

/**
Copies Qualifiers from a given qp_list_line to another qp_list_line
 * p_listLineId     List Line used to fetch the Qualifiers
 * p_modifier_tbl   the Table used to fetch the newly created list lines into which the Qualifiers are to be copied
*/
PROCEDURE copyTdQualifiers
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN NUMBER
  , x_modifier_tbl          IN QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(x_modifier_tbl.count,0) > 0 THEN
    FOR i in  x_modifier_tbl.first .. x_modifier_tbl.last LOOP
        IF x_modifier_tbl.exists(i) THEN
            copyQualifiers
            (
              x_return_status          => x_return_status
              , x_msg_count             => x_msg_count
              , x_msg_data              => x_msg_data
              , p_fromListLineId        => p_listLineId
              , p_toListLineId         => x_modifier_tbl(i).list_line_id
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             return;
            END IF;
        END IF;
    END LOOP;
END IF;
END copyTdQualifiers;



FUNCTION getTdLine(p_listLineId IN NUMBER)
RETURN NUMBER
IS
CURSOR c_getTdLine(cp_listLineId NUMBER) IS
SELECT related_modifier_id
FROM ozf_related_deal_lines
WHERE modifier_id = cp_listLineId;
l_relatedLineId NUMBER;
BEGIN
OPEN c_getTdLine(cp_listLineId => p_listLineId);
FETCH c_getTdLine INTO l_relatedLineId;
IF c_getTdLine%NOTFOUND  THEN
    l_relatedLineId := null;
END IF;
CLOSE c_getTdLine;

return l_relatedLineId;
END getTdLine;


/**
Relates a trade deal Discount rule to a group of qp_list_lines. these qp_list_lines are actually the components of a single trade deal discount rule.
* p_offerAdjustmentId   The Adjustment under which the Relation was created
* p_listLineId the primary list_line_id of the Trade Deal Discount Rule.
* p_modifier_tbl   the Table used to fetch the newly created list lines into which the Qualifiers are to be copied
*/
PROCEDURE relateTdLines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , p_modifier_tbl          IN QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
CURSOR c_accrualFlag(cp_listLineId NUMBER)
IS
SELECT accrual_flag
FROM qp_list_lines
WHERE list_line_id = cp_listLineId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- get accrual flag for given list line
-- loop thru. the passed in table
-- if the accrual flag for the list_line_id is the same as
FOR l_accrualFlag IN c_accrualFlag(cp_listLineId => p_listLineId) LOOP
    IF nvl(P_modifier_tbl.count,0) > 0 THEN
        FOR j in p_modifier_tbl.first .. p_modifier_tbl.last LOOP
            IF p_modifier_tbl.exists(j) THEN
                IF nvl(l_accrualFlag.accrual_flag,'N') = nvl(p_modifier_tbl(j).accrual_flag,'N') THEN
                    OZF_VOLUME_OFFER_ADJ.relate_lines
                    (
                      p_from_list_line_id       => p_listLineId
                      , p_to_list_line_id       => p_modifier_tbl(j).list_line_id
                      , p_offer_adjustment_id   => p_offerAdjustmentId
                      , x_return_status         => x_return_status
                      , x_msg_count             => x_msg_count
                      , x_msg_data              => x_msg_data
                    );
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                    IF getTdLine(p_listLineId) IS NOT NULL AND getTdLine(p_modifier_tbl(j).list_line_id) IS NOT NULL THEN
                        OZF_VOLUME_OFFER_ADJ.relate_lines
                        (
                          p_from_list_line_id       => getTdLine(p_listLineId)
                          , p_to_list_line_id       => getTdLine(p_modifier_tbl(j).list_line_id)
                          , p_offer_adjustment_id   => p_offerAdjustmentId
                          , x_return_status         => x_return_status
                          , x_msg_count             => x_msg_count
                          , x_msg_data              => x_msg_data
                        );
                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END IF;
END LOOP;
END relateTdLines;

/**
Copies a list line into a new list line, with the start date as the effective date of the adjustmentid passed in
*/
PROCEDURE copyTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_listLineId            IN NUMBER
  , x_modifier_tbl          OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
BEGIN
-- initialize
-- create discount rules
-- copy exclusions
-- copy qualifiers
-- return list_line_id created
-- return record created
x_return_status := FND_API.G_RET_STS_SUCCESS;
createTdLine
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
  , p_listLineId            => p_listLineId
  , x_modifier_tbl          => x_modifier_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyTdExclusions
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_listLineId            => p_listLineId
  , x_modifier_tbl          => x_modifier_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyTdQualifiers
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_listLineId            => p_listLineId
  , x_modifier_tbl          => x_modifier_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
copyTdLimits
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_listLineId            => p_listLineId
  , p_modifier_tbl          => x_modifier_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END copyTdLine;
/**
End Dates a Trade Deal Discount Rule with the effective date of the Adjustment id passed in
*/
PROCEDURE endDateTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
)
IS
l_modifier_line_tbl ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE;
lx_modifier_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
l_errorLocation NUMBER;
BEGIN
-- initialize
-- populate end date lines
-- process end date lines
-- end date line
x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('before populateTdUpdLines :'||x_return_status);
populateTdUpdLines
(
  x_modifier_line_rec      => l_modifier_line_tbl(1)
  , p_listLineId         => p_listLineId
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
);
ozf_utility_pvt.debug_message('after populateTdUpdLines :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('before processTdUpdLines :'||x_return_status);

processTdUpdLines
(
  px_modifier_line_rec      => l_modifier_line_tbl(1)
  , p_offerAdjustmentId    => p_offerAdjustmentId
  , p_listLineId           => p_listLineId
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
);
ozf_utility_pvt.debug_message('after processTdUpdLines :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('before process_qp_list_lines :'||x_return_status);
ozf_offer_pvt.process_qp_list_lines
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offer_type            => 'DEAL'
  ,p_modifier_line_tbl     => l_modifier_line_tbl
  ,p_list_header_id        => l_modifier_line_tbl(1).list_header_id
  ,x_modifier_line_tbl     => lx_modifier_tbl --QP_MODIFIERS_PUB.modifiers_tbl_type
  ,x_error_location        => l_errorLocation
 );
ozf_utility_pvt.debug_message('after process_qp_list_lines :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END endDateTdLine;


PROCEDURE processOldTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
)
IS
l_modifier_tbl          QP_MODIFIERS_PUB.modifiers_tbl_type;
l_listLineId number;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('before endDateTdLine :'||x_return_status);
endDateTdLine
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
  , p_listLineId           => p_listLineId
);
ozf_utility_pvt.debug_message('after endDateTdLine :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('before copyTdLine :'||x_return_status);
copyTdLine
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
  , p_listLineId           => p_listLineId
  , x_listLineId           => l_listLineId
  , x_modifier_tbl         => l_modifier_tbl
);
ozf_utility_pvt.debug_message('after copyTdLine :'||x_return_status);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('before relateTdLine :'||x_return_status);
relateTdLines
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
  , p_listLineId           => p_listLineId
  , p_modifier_tbl         => l_modifier_tbl
);
ozf_utility_pvt.debug_message('after relateTdLine :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END ;
/**
Processes adjustment lines for Trade deal Adjustments
*/
PROCEDURE process_old_td_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjLines(cp_offerAdjustmentId NUMBER) IS
SELECT
list_line_id
FROM ozf_offer_adjustment_lines
WHERE offer_adjustment_id = cp_offerAdjustmentId;

BEGIN
-- initialize
-- loop thru. all adjustment lines
-- end date list_line
-- copy list_line
-- relate list_lines
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_adjLines in c_adjLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
--dbms_output.put_line('Processiung :'||l_adjLines.list_line_id);
ozf_utility_pvt.debug_message('before process old td line discounts :'||x_return_status);

processOldTdLine
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjustmentId   => p_offerAdjustmentId
  , p_listLineId            => l_adjLines.list_line_id
);
ozf_utility_pvt.debug_message('after process old td line discounts :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END LOOP;
END process_old_td_discount;

PROCEDURE process_old_discounts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_offerType(cp_offerAdjustmentId NUMBER) IS
SELECT
offer_type
FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;
l_offerType c_offerType%ROWTYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_offerType(cp_offerAdjustmentId  => p_offerAdjustmentId);
    FETCH c_offerType INTO l_offerType;
CLOSE c_offerType;
IF l_offerType.offer_type = 'DEAL' THEN
ozf_utility_pvt.debug_message('before process old td discounts :'||x_return_status);
process_old_td_discount
(
  x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId   => p_offerAdjustmentId
);
ozf_utility_pvt.debug_message('after process old td discounts :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ELSIF l_offerType.offer_type = 'OID' THEN
process_old_pg_discount
(
  x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ELSIF l_offerType.offer_type = 'VOLUME_OFFER' THEN
OZF_VOLUME_OFFER_ADJ.adjust_old_discounts
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

ELSIF l_offerType.offer_type IN ( 'ORDER','ACCRUAL','OFF_INVOICE') THEN
process_old_reg_discount
(
  x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END IF;
END process_old_discounts;
---------------------------------------Process pg products--------------------
PROCEDURE populateNewBuyProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE
)
IS
CURSOR c_newBuy(cp_offerAdjNewLineId NUMBER) IS
SELECT
a.product_attribute
, a.product_attr_value
, a.uom_code
, b.volume_from
, b.volume_to
, b.volume_type
, b.end_date_active
, c.effective_date
, c.list_header_id
FROM
ozf_offer_adj_new_products a, ozf_offer_adj_new_lines b , ozf_offer_adjustments_b c
WHERE a.offer_adj_new_line_id = b.offer_adj_new_line_id
AND a.excluder_flag = 'N'
AND b.offer_adjustment_id = c.offer_adjustment_id
AND b.offer_adj_new_line_id = cp_offerAdjNewLineId;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
i := 1;
FOR l_newBuy in c_newBuy(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    x_modifier_line_tbl(i).product_attr             := l_newBuy.product_attribute;
    x_modifier_line_tbl(i).product_attr_val         := l_newBuy.product_attr_value;
    x_modifier_line_tbl(i).product_uom_code         := l_newBuy.uom_code;
    x_modifier_line_tbl(i).pricing_attr_value_from  := l_newBuy.volume_from;
    x_modifier_line_tbl(i).pricing_attr             := l_newBuy.volume_type;
    x_modifier_line_tbl(i).end_date_active          := l_newBuy.end_date_active;
    x_modifier_line_tbl(i).start_date_active        := l_newBuy.effective_date;
    x_modifier_line_tbl(i).list_header_id           := l_newBuy.list_header_id;
    x_modifier_line_tbl(i).price_break_type_code    := 'POINT';
    i := i+ 1;
END LOOP;
END populateNewBuyProduct;

PROCEDURE processNewBuyProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN   NUMBER
  ,px_modifier_line_tbl     IN OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(px_modifier_line_tbl.count,0) > 0 THEN
FOR i in px_modifier_line_tbl.first .. px_modifier_line_tbl.last LOOP
IF px_modifier_line_tbl.exists(i) THEN
    px_modifier_line_tbl(i).operation                := QP_GLOBALS.G_OPR_CREATE;
    px_modifier_line_tbl(i).list_line_type_code      := 'RLTD';
    px_modifier_line_tbl(i).inactive_flag            := 'Y';
END IF;
END LOOP;
END IF;
END processNewBuyProduct;

/**
NOte that YOU cannot add new buy items to a PG offer if the modifier_level_code is LINE. This is a new QP Validation.
So dont let the user add new buy lines to  a PG offer and adjustment if the modifier level code is LINE
Throw error QP_INVALID_PHASE_RLTD in the UI itself
*/
PROCEDURE createNewBuyProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN   NUMBER
  , x_modifier_tbl         OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
l_modifier_line_tbl      ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE;
lx_modifier_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
l_errorLocation NUMBER;
BEGIN
-- initilize
-- populate data
-- process data
-- create
-- return created table
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
lx_modifier_tbl.delete;

populateNewBuyProduct
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjNewLineId     => p_offerAdjNewLineId
  , x_modifier_line_tbl     => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processNewBuyProduct
(
  x_return_status           => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjNewLineId     => p_offerAdjNewLineId
  , px_modifier_line_tbl    => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_OFFER_PVT.process_qp_list_lines
(
 x_return_status         => x_return_status
 ,x_msg_count             => x_msg_count
 ,x_msg_data              => x_msg_data
 ,p_offer_type            => getOfferType(p_offerAdjNewLineId => p_offerAdjNewLineId)
 ,p_modifier_line_tbl     => l_modifier_line_tbl
 ,p_list_header_id        => l_modifier_line_tbl(1).list_header_id
 ,x_modifier_line_tbl     => lx_modifier_tbl
 ,x_error_location        => l_errorLocation
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
x_modifier_tbl := lx_modifier_tbl;
EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END createNewBuyProduct;

PROCEDURE processNewBuyProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId   IN   NUMBER
)
IS
l_modifiers_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
BEGIN
-- initialize
-- create new line
-- create line in ozf_offer_adjustment_lines
x_return_status := FND_API.G_RET_STS_SUCCESS;
createNewBuyProduct
(
  x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offerAdjNewLineId     => p_offerAdjNewLineId
  , x_modifier_tbl         => l_modifiers_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
createAdjLines
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifiers_tbl         => l_modifiers_tbl
  ,p_offerAdjustmentId     => getAdjustmentId( p_offerAdjNewLineId => p_offerAdjNewLineId)
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END processNewBuyProduct;

PROCEDURE processNewBuyProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjLines(cp_offerAdjustmentId NUMBER) IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE tier_type <> 'DIS'
AND offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
-- initialize
-- loop thru. individual lines and process each line
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_adjLines IN c_adjLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
        processNewBuyProduct
        (
          x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_offerAdjNewLineId     => l_adjLines.offer_adj_new_line_id
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END processNewBuyProducts;
----------------------------End PG Buy products------------------------------
PROCEDURE populateNewGetProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId     IN NUMBER
  ,x_modifier_line_tbl     OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE
)
IS
CURSOR c_newGet(cp_offerAdjNewLineId NUMBER) IS
SELECT
a.end_date_active
, a.benefit_price_list_line_id
, a.discount
, a.discount_type
, a.quantity
, b.product_attribute
, b.product_attr_value
, b.uom_code
, c.effective_date
, c.list_header_id
FROM ozf_offer_adj_new_lines a, ozf_offer_adj_new_products b, ozf_offer_adjustments_b c
WHERE a.offer_adj_new_line_id = b.offer_adj_new_line_id
AND a.offer_adjustment_id = c.offer_adjustment_id
AND a.offer_adj_new_line_id = cp_offerAdjNewLineId;

i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
i := 1;
FOR l_newGet IN c_newGet(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    x_modifier_line_tbl(i).start_date_active            := l_newGet.effective_date;
    x_modifier_line_tbl(i).end_date_active              := l_newGet.end_date_active;
    x_modifier_line_tbl(i).list_header_id               := l_newGet.list_header_id;
    x_modifier_line_tbl(i).product_attr                 := l_newGet.product_attribute;
    -- fix for bug # 5715744.
    --x_modifier_line_tbl(i).product_attr_val             := l_newGet.product_attribute;
    x_modifier_line_tbl(i).product_attr_val             := l_newGet.product_attr_value;
    -- end of bug # 5715744.
    x_modifier_line_tbl(i).benefit_price_list_line_id   := l_newGet.benefit_price_list_line_id;
    x_modifier_line_tbl(i).benefit_uom_code             := l_newGet.uom_code;
    x_modifier_line_tbl(i).operand                      := l_newGet.discount;
    x_modifier_line_tbl(i).arithmetic_operator          := l_newGet.discount_type;
    x_modifier_line_tbl(i).benefit_qty                  := l_newGet.quantity;
i := i + 1;
END LOOP;
END populateNewGetProduct;

PROCEDURE processNewGetProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId     IN NUMBER
  ,px_modifier_line_tbl     IN OUT NOCOPY ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(px_modifier_line_tbl.count,0) > 0 THEN
    FOR i in px_modifier_line_tbl.first .. px_modifier_line_tbl.last LOOP
        IF px_modifier_line_tbl.exists(i) THEN
            px_modifier_line_tbl(i).operation                    := QP_GLOBALS.G_OPR_CREATE;
            px_modifier_line_tbl(i).list_line_type_code          := 'DIS';
            px_modifier_line_tbl(i).inactive_flag                := 'Y';
            --dbms_output.put_line('Dates :'||px_modifier_line_tbl(i).start_date_active||':'||px_modifier_line_tbl(i).end_date_active);
        END IF;
    END LOOP;
END IF;
END processNewGetProduct;

PROCEDURE createNewGetProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId     IN NUMBER
  ,x_modifier_tbl          OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
)
IS
l_modifier_line_tbl      ozf_offer_pvt.MODIFIER_LINE_Tbl_TYPE;
lx_modifier_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
l_errorLocation NUMBER;
BEGIN
-- initialize
-- populate data in qp structures
-- process data in qp structures
-- create
-- return the created table
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;

populateNewGetProduct
(
          x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_offerAdjNewLineId     => p_offerAdjNewLineId
          ,x_modifier_line_tbl     => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processNewGetProduct
(
          x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_offerAdjNewLineId     => p_offerAdjNewLineId
          ,px_modifier_line_tbl     => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_OFFER_PVT.process_qp_list_lines
(
 x_return_status         => x_return_status
 ,x_msg_count             => x_msg_count
 ,x_msg_data              => x_msg_data
 ,p_offer_type            => getOfferType(p_offerAdjNewLineId => p_offerAdjNewLineId)
 ,p_modifier_line_tbl     => l_modifier_line_tbl
 ,p_list_header_id        => l_modifier_line_tbl(1).list_header_id
 ,x_modifier_line_tbl     => lx_modifier_tbl
 ,x_error_location        => l_errorLocation
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
x_modifier_tbl := lx_modifier_tbl;
END createNewGetProduct;

PROCEDURE processNewGetProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
    ,p_offerAdjNewLineId     IN NUMBER
)
IS
l_modifiers_tbl QP_MODIFIERS_PUB.modifiers_tbl_type;
BEGIN
-- initialize
-- create new get product
-- create offer_adjustment_line
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifiers_tbl.delete;
createNewGetProduct
(
          x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_offerAdjNewLineId     => p_offerAdjNewLineId
          ,x_modifier_tbl         => l_modifiers_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
createAdjLines
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifiers_tbl         => l_modifiers_tbl
  ,p_offerAdjustmentId     => getAdjustmentId( p_offerAdjNewLineId => p_offerAdjNewLineId)
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END processNewGetProduct;

PROCEDURE processNewGetProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjLines(cp_offerAdjustmentId NUMBER) IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE tier_type = 'DIS'
AND offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
-- initialize
-- loop thru. individual lines and process each line
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_adjLines IN c_adjLines(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
        processNewGetProduct
        (
          x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_offerAdjNewLineId     => l_adjLines.offer_adj_new_line_id
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END processNewGetProducts;

PROCEDURE processNewPgProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- initialize
-- process new buy products
-- process new get products
processNewBuyProducts
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
processNewGetProducts
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
EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END processNewPgProducts;
---------------end process pg products--------------------------
PROCEDURE populateDisDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  ,x_modifier_line_tbl      OUT NOCOPY ozf_offer_pvt.modifier_line_tbl_type
)
IS
CURSOR c_offerAdjustmentLines(cp_offerAdjNewLineId NUMBER)
IS
SELECT
a.offer_adj_new_line_id
, a.offer_adjustment_id
, a.volume_from
, a.volume_to
, a.volume_type
, a.discount
, a.discount_type
, a.tier_type
, a.td_discount
, a.td_discount_type
, a.quantity
, a.benefit_price_list_line_id
, a.parent_adj_line_id
, a.start_date_active
, a.end_date_active
, b.product_context
, b.product_attribute
, b.product_attr_value
, b.excluder_flag
, b.uom_code
, c.list_header_id
, c.effective_date
FROM
ozf_offer_adj_new_lines a, ozf_offer_adj_new_products b , ozf_offer_adjustments_b c
WHERE a.offer_adj_new_line_id = b.offer_adj_new_line_id
AND a.offer_adjustment_id    = c.offer_adjustment_id
and a.offer_adj_new_line_id = cp_offerAdjNewLineId;
i NUMBER;

BEGIN
-- initialize
-- loop thru. the records and populate
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
i := 1;
FOR l_offerAdjustmentLines IN c_offerAdjustmentLines(cp_offerAdjNewLineId => p_offerAdjNewLineId)
LOOP
    x_modifier_line_tbl(i).list_header_id               := l_offerAdjustmentLines.list_header_id;
    x_modifier_line_tbl(i).list_line_id                 := FND_API.G_MISS_NUM;
    x_modifier_line_tbl(i).list_line_type_code          := l_offerAdjustmentLines.tier_type;
    x_modifier_line_tbl(i).operand                      := l_offerAdjustmentLines.discount;
    x_modifier_line_tbl(i).arithmetic_operator          := l_offerAdjustmentLines.discount_type;
    x_modifier_line_tbl(i).product_attr                 := l_offerAdjustmentLines.product_attribute;
    x_modifier_line_tbl(i).product_attr_val             := l_offerAdjustmentLines.product_attr_value;
    x_modifier_line_tbl(i).product_uom_code             := l_offerAdjustmentLines.uom_code;
    x_modifier_line_tbl(i).pricing_attr                 := l_offerAdjustmentLines.volume_type;
    x_modifier_line_tbl(i).pricing_attr_value_from      := l_offerAdjustmentLines.volume_from;
    x_modifier_line_tbl(i).inactive_flag                := 'Y';
    x_modifier_line_tbl(i).pricing_attribute_id         := FND_API.G_MISS_NUM;

END LOOP;
END populateDisDiscounts;

PROCEDURE processDisDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  ,px_modifier_line_tbl      IN OUT NOCOPY ozf_offer_pvt.modifier_line_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(px_modifier_line_tbl.count,0) > 0 THEN
    FOR i IN px_modifier_line_tbl.first .. px_modifier_line_tbl.last LOOP
        IF px_modifier_line_tbl.exists(i) THEN
            px_modifier_line_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;
            px_modifier_line_tbl(i).start_date_active := getEffectiveDate(getAdjustmentId(p_offerAdjNewLineId => p_offerAdjNewLineId));
        END IF;
    END LOOP;
END IF;
END processDisDiscounts;

PROCEDURE processNewStProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
)
IS
l_modifier_line_tbl      ozf_offer_pvt.modifier_line_tbl_type;
l_modifiers_tbl qp_modifiers_pub.modifiers_tbl_type;
l_errorLocation NUMBER;
BEGIN
-- initialize
-- populate discounts
-- create qp_list_lines
-- create ozf_offer_adjustment_lines with created from adjustments = y -- required only for processing with bugets
-- need to look at relating offer_adj_new_line_id with the qp list_line_id created. may be useful later for audit reporting and Sarbines-Auxley compliance.
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
populateDisDiscounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  ,x_modifier_line_tbl      => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processDisDiscounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  ,px_modifier_line_tbl      => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_OFFER_PVT.process_qp_list_lines
(
 x_return_status         => x_return_status
 ,x_msg_count             => x_msg_count
 ,x_msg_data              => x_msg_data
 ,p_offer_type            => getOfferType(p_offerAdjNewLineId => p_offerAdjNewLineId)
 ,p_modifier_line_tbl     => l_modifier_line_tbl
 ,p_list_header_id        => l_modifier_line_tbl(1).list_header_id
 ,x_modifier_line_tbl     => l_modifiers_tbl
 ,x_error_location        => l_errorLocation
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
createAdjLines
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifiers_tbl         => l_modifiers_tbl
  ,p_offerAdjustmentId     => getAdjustmentId( p_offerAdjNewLineId => p_offerAdjNewLineId)
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END processNewStProduct;


PROCEDURE populateAdvancedOptions
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_listHeaderId            IN NUMBER
  , px_modifier_line_rec     IN OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
)
IS
CURSOR c_advOpt(cp_listHeaderId NUMBER) IS
SELECT
proration_type_code
, product_precedence
, pricing_group_sequence
, pricing_phase_id
, print_on_invoice_flag
, incompatibility_grp_code
FROM qp_list_lines
WHERE list_header_id = cp_listHeaderId
AND rownum < 2;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_advOpt IN c_advOpt(cp_listHeaderId => p_listHeaderId ) LOOP
    px_modifier_line_rec.proration_type_code          := l_advOpt.proration_type_code;
    px_modifier_line_rec.product_precedence           := l_advOpt.product_precedence;
    px_modifier_line_rec.pricing_group_sequence       := l_advOpt.pricing_group_sequence;
    px_modifier_line_rec.pricing_phase_id             := l_advOpt.pricing_phase_id;
    px_modifier_line_rec.print_on_invoice_flag        := l_advOpt.print_on_invoice_flag;
    px_modifier_line_rec.incompatibility_grp_code     := l_advOpt.incompatibility_grp_code;
END LOOP;
END populateAdvancedOptions;

PROCEDURE processPbhData
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , px_modifier_line_rec     IN OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
)
IS
CURSOR c_offerDetails(cp_offerAdjNewLineId NUMBER) IS
SELECT
b.effective_date
, b.list_header_id
, decode(c.offer_type,'ACCRUAL','Y','N') accrual_flag
, c.modifier_level_code
FROM
ozf_offer_adj_new_lines a, ozf_offer_adjustments_b b, ozf_offers c
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND b.list_header_id = c.qp_list_header_id
AND a.offer_adj_new_line_id = cp_offerAdjNewLineId;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 1;
FOR l_offerDetails IN c_offerDetails(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    px_modifier_line_rec.operation                      := QP_GLOBALS.G_OPR_CREATE;
    px_modifier_line_rec.start_date_active              := l_offerDetails.effective_date;
    px_modifier_line_rec.list_header_id                 := l_offerDetails.list_header_id;
    px_modifier_line_rec.accrual_flag                   := l_offerDetails.accrual_flag;
--    x_modifiers_tbl(i).proration_type_code          := l_advOpt.proration_type_code;
--    x_modifiers_tbl(i).product_precedence           := l_advOpt.product_precedence;
    px_modifier_line_rec.modifier_level_code          := l_offerDetails.modifier_level_code;
    px_modifier_line_rec.price_break_type_code        := 'POINT';

--    x_modifiers_tbl(i).pricing_group_sequence       := l_advOpt.pricing_group_sequence;
--    x_modifiers_tbl(i).pricing_phase_id             := l_advOpt.pricing_phase_id;
--    x_modifiers_tbl(i).print_on_invoice_flag        := l_advOpt.print_on_invoice_flag;
--    x_modifiers_tbl(i).incompatibility_grp_code     := l_advOpt.incompatibility_grp_code;
--    px_modifier_line_rec.price_break_type_code          := l_offerDetails.price_break_type_code;
    populateAdvancedOptions
    (
      x_return_status           => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,p_listHeaderId            => l_offerDetails.list_header_id
      , px_modifier_line_rec     => px_modifier_line_rec
    );
i := i + 1;
END LOOP;
END processPbhData;

PROCEDURE populatePbhPricingAttr
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  ,x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_index                 IN NUMBER
)
IS
CURSOR c_productAttributes(cp_offerAdjNewLineId NUMBER) IS
SELECT a.product_context
, a.product_attribute
, a.product_attr_value
, a.uom_code
, a.excluder_flag
, b.volume_type
FROM ozf_offer_adj_new_products a, ozf_offer_adj_new_lines b
WHERE
a.offer_adj_new_line_id = b.offer_adj_new_line_id
AND a.offer_adj_new_line_id = cp_offerAdjNewLineId;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 1;
FOR l_productAttributes IN c_productAttributes(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    x_pricing_attr_tbl(i).product_attribute_context := l_productAttributes.product_context;
    x_pricing_attr_tbl(i).product_attribute         := l_productAttributes.product_attribute;
    x_pricing_attr_tbl(i).product_attr_value        := l_productAttributes.product_attr_value;
    x_pricing_attr_tbl(i).product_uom_code          := l_productAttributes.uom_code;
    x_pricing_attr_tbl(i).excluder_flag             := l_productAttributes.excluder_flag;
    x_pricing_attr_tbl(i).pricing_attribute_context := 'VOLUME'; --l_mtLines.pricing_attribute_context;
    x_pricing_attr_tbl(i).pricing_attribute         := l_productAttributes.volume_type;
    x_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';
    x_pricing_attr_tbl(i).modifiers_index            := p_index;
    x_pricing_attr_tbl(i).operation                  := QP_GLOBALS.G_OPR_CREATE;
    x_pricing_attr_tbl(i).pricing_attribute_id      := FND_API.G_MISS_NUM;
    x_pricing_attr_tbl(i).attribute_grouping_no     := FND_API.G_MISS_NUM;
i := i + 1;
END LOOP;
END populatePbhPricingAttr;

PROCEDURE populatePbhDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_rec     OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
)
IS
CURSOR c_pbhData (cp_offerAdjNewLineId NUMBER) IS
SELECT
 a.tier_type
--, c.effective_date
--, c.list_header_id
--, d.modifier_level_code
--, decode(d.offer_type, 'ACCRUAL','Y','N') accrual_flag
, a.end_date_active
FROM ozf_offer_adj_new_lines a
WHERE a.offer_adj_new_line_id = cp_offerAdjNewLineId;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_pbhData IN c_pbhData(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    x_modifier_line_rec.operation                    := QP_GLOBALS.G_OPR_CREATE;
    x_modifier_line_rec.list_line_type_code          := 'PBH';
    x_modifier_line_rec.automatic_flag               := 'Y';
--    x_modifiers_tbl(i).start_date_active            := l_hdrLines.effective_date;
    x_modifier_line_rec.end_date_active              := l_pbhData.end_date_active;
--    x_modifiers_tbl(i).list_header_id               := l_hdrLines.list_header_id;
--    x_modifiers_tbl(i).accrual_flag                 := l_hdrLines.accrual_flag;
--    x_modifiers_tbl(i).proration_type_code          := l_advOpt.proration_type_code;
--    x_modifiers_tbl(i).product_precedence           := l_advOpt.product_precedence;
--    x_modifiers_tbl(i).modifier_level_code          := l_hdrLines.modifier_level_code;
--    x_modifiers_tbl(i).pricing_group_sequence       := l_advOpt.pricing_group_sequence;
--    x_modifiers_tbl(i).pricing_phase_id             := l_advOpt.pricing_phase_id;
--    x_modifiers_tbl(i).print_on_invoice_flag        := l_advOpt.print_on_invoice_flag;
--    x_modifiers_tbl(i).incompatibility_grp_code     := l_advOpt.incompatibility_grp_code;
    x_modifier_line_rec.price_break_type_code          := 'POINT'; --
    processPbhData
    (
      x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_offerAdjNewLineId          => p_offerAdjNewLineId
      , px_modifier_line_rec        => x_modifier_line_rec
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END LOOP;
END populatePbhDiscounts;
/*
PROCEDURE populateCDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_rec     OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- initialize
-- loop thru. discount lines and populate discounts for each line

END populateDisDiscounts;*/

PROCEDURE populateDisDiscounts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  ,x_modifier_line_rec     OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
)
IS
CURSOR c_discounts(cp_offerAdjNewLineId NUMBER) IS
SELECT
 discount
, discount_type
, tier_type
FROM ozf_offer_adj_new_lines
WHERE offer_adj_new_line_id = cp_offerAdjNewLineId;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_discounts IN c_discounts(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP

    x_modifier_line_rec.operation                    := QP_GLOBALS.G_OPR_CREATE;
    x_modifier_line_rec.list_line_type_code          := l_discounts.tier_type;
    x_modifier_line_rec.automatic_flag               := 'Y';
    x_modifier_line_rec.operand                      := l_discounts.discount;
    x_modifier_line_rec.arithmetic_operator          := l_discounts.discount_type;
    x_modifier_line_rec.rltd_modifier_grp_type       := 'PRICE BREAK';
    x_modifier_line_rec.rltd_modifier_grp_no         := 1;
    x_modifier_line_rec.modifier_parent_index        := 1;
--    x_modifier_line_rec.price_break_type_code        := 'POINT';
    processPbhData
    (
      x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_offerAdjNewLineId          => p_offerAdjNewLineId
      , px_modifier_line_rec        => x_modifier_line_rec
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END LOOP;
END populateDisDiscounts;

PROCEDURE populateDisPricingAttributes
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_pricing_attr_rec      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Rec_Type
  , p_index                 IN NUMBER
)
IS
CURSOR c_pricingAttributes(cp_offerAdjNewLineId NUMBER) IS
SELECT a.product_context
, a.product_attribute
, a.product_attr_value
, a.uom_code
, a.excluder_flag
, b.volume_type
, b.volume_from
, b.volume_to
FROM ozf_offer_adj_new_products a, ozf_offer_adj_new_lines b
WHERE
a.offer_adj_new_line_id = b.parent_adj_line_id
AND a.excluder_flag     = 'N'
AND b.offer_adj_new_line_id = cp_offerAdjNewLineId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_pricing_attr_rec := null;
FOR l_pricingAttributes in c_pricingAttributes(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
    x_pricing_attr_rec.pricing_attribute_id      := FND_API.G_MISS_NUM;
    x_pricing_attr_rec.attribute_grouping_no     := FND_API.G_MISS_NUM;
    x_pricing_attr_rec.product_attribute_context := l_pricingAttributes.product_context;
    x_pricing_attr_rec.product_attribute         := l_pricingAttributes.product_attribute;
    x_pricing_attr_rec.product_attr_value        := l_pricingAttributes.product_attr_value;
    x_pricing_attr_rec.product_uom_code          := l_pricingAttributes.uom_code;
    x_pricing_attr_rec.excluder_flag             := l_pricingAttributes.excluder_flag;
    x_pricing_attr_rec.pricing_attribute_context := 'VOLUME';
    x_pricing_attr_rec.pricing_attribute         := l_pricingAttributes.volume_type;
    x_pricing_attr_rec.pricing_attr_value_from   := l_pricingAttributes.volume_from;
    x_pricing_attr_rec.pricing_attr_value_to     := l_pricingAttributes.volume_to;
    x_pricing_attr_rec.comparison_operator_code   := 'BETWEEN';
    x_pricing_attr_rec.modifiers_index            := p_index;
    x_pricing_attr_rec.operation                  := QP_GLOBALS.G_OPR_CREATE;
END LOOP;
END populateDisPricingAttributes;


PROCEDURE populateDisData
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
CURSOR c_adjNewLines(cp_offerAdjNewLineId NUMBER) IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE parent_adj_line_id = cp_offerAdjNewLineId;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 2; -- hardcode since dis lines will always start at 2
FOR l_adjNewLines IN c_adjNewLines(cp_offerAdjNewLineId => p_offerAdjNewLineId) LOOP
populateDisDiscounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => l_adjNewLines.offer_adj_new_line_id
  , x_modifier_line_rec     => x_modifier_line_tbl(i)
);
x_modifier_line_tbl(i).start_date_active := null;
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateDisPricingAttributes
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => l_adjNewLines.offer_adj_new_line_id
  , x_pricing_attr_rec     => x_pricing_attr_tbl(i)
  , p_index                 => i
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
i := i + 1;
END LOOP;
-- populate discounts
-- populate pricing attributes
END populateDisData;



PROCEDURE populatePbhData
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_rec     OUT NOCOPY qp_modifiers_pub.modifiers_rec_type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_rec := null;
x_pricing_attr_tbl.delete;
i := 1;
-- populate pbh discounts
-- populate pbh product attributes
populatePbhDiscounts
(
  x_return_status              => x_return_status
  ,x_msg_count                  => x_msg_count
  ,x_msg_data                   => x_msg_data
  ,p_offerAdjNewLineId          => p_offerAdjNewLineId
  , x_modifier_line_rec         => x_modifier_line_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populatePbhPricingAttr
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  ,x_pricing_attr_tbl      => x_pricing_attr_tbl
  , p_index                 => 1
);
END populatePbhData;

PROCEDURE populateNewMtProducts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
)
IS
l_modifier_line_tbl     qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl      QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_modifier_line_tbl.delete;
x_pricing_attr_tbl.delete;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;
-- populate PBH header record
-- populate populate DIS records
populatePbhData
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  , x_modifier_line_rec     => x_modifier_line_tbl(1)
  , x_pricing_attr_tbl      => x_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateDisData
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  , x_modifier_line_tbl     => l_modifier_line_tbl
  , x_pricing_attr_tbl      => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_VOLUME_OFFER_ADJ.merge_pricing_attributes
(
  px_to_pricing_attr_tbl    => x_pricing_attr_tbl
  , p_from_pricing_attr_tbl => l_pricing_attr_tbl
);
OZF_VOLUME_OFFER_ADJ.merge_modifiers
(
  px_to_modifier_line_tbl    => x_modifier_line_tbl
  , p_from_modifier_line_tbl => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END populateNewMtProducts;

/**
Creates a multi-tier discount line in QP corresponding to data entered in ozf_offer_adj_new_lines and ozf_offer_adj_new_products
* p_offerAdjNewLineId offer_adj_new_line_id for which the qp data is to be created
* note as of now the price_break_type_code is not captured in the UI or in the database so it is hardcoded to point.
*/
PROCEDURE createNewMtProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
)
IS
l_modifier_line_tbl qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type;
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
-- populate records
-- process data
-- create qp data
-- return created table
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;
l_pricing_attr_tbl.delete;

populateNewMtProducts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  , x_modifier_line_tbl     => l_modifier_line_tbl
  , x_pricing_attr_tbl      => l_pricing_attr_tbl
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
EXCEPTION
WHEN OTHERS THEN
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
x_return_status := FND_API.G_RET_STS_ERROR;
END createNewMtProduct;

/**
Processes a Multi-tier offer_adjustment_line
*/
PROCEDURE processNewMtProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
)
IS
l_modifier_line_tbl qp_modifiers_pub.modifiers_tbl_type;
BEGIN
-- initialize
-- create a product qp data
-- back create ozf_offer_adjustment_lines
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_modifier_line_tbl.delete;

createNewMtProduct
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjNewLineId      => p_offerAdjNewLineId
  , x_modifier_line_tbl     => l_modifier_line_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
createAdjLines
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifiers_tbl         => l_modifier_line_tbl
  ,p_offerAdjustmentId     => getAdjustmentId( p_offerAdjNewLineId => p_offerAdjNewLineId)
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END processNewMtProduct;


PROCEDURE processStRegProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjustmentProducts(cp_offerAdjustmentId NUMBER) IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE tier_type = 'DIS'
AND parent_adj_line_id IS NULL
AND offer_adjustment_id = cp_offerAdjustmentId;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_adjustmentProducts IN c_adjustmentProducts(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
        processNewStProduct
        (
          x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_offerAdjNewLineId      => l_adjustmentProducts.offer_adj_new_line_id
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END processStRegProducts;

PROCEDURE processMtRegProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_adjustmentProducts(cp_offerAdjustmentId NUMBER)
IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE offer_adjustment_id = cp_offerAdjustmentId
AND parent_adj_line_id IS NULL
AND tier_type = 'PBH';

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR l_adjustmentProducts IN c_adjustmentProducts(cp_offerAdjustmentId => p_offerAdjustmentId) LOOP
        processNewMtProduct
        (
          x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_offerAdjNewLineId      => l_adjustmentProducts.offer_adj_new_line_id
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END processMtRegProducts;

PROCEDURE processNewRegProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
BEGIN
-- initialize
-- process single tier lines
-- process multi-tier lines
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    processStRegProducts
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
    processMtRegProducts
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
END processNewRegProducts;

PROCEDURE process_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_offerType(cp_offerAdjustmentId NUMBER) IS
SELECT
offer_type
FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;
l_offerType c_offerType%ROWTYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_offerType(cp_offerAdjustmentId  => p_offerAdjustmentId);
    FETCH c_offerType INTO l_offerType;
CLOSE c_offerType;
IF l_offerType.offer_type = 'DEAL' THEN
NULL; -- NO NEW PRODUCTS CURRENTLY SUPPORTED FOR TRADE DEAL OFFERS
ELSIF l_offerType.offer_type = 'VOLUME_OFFER' THEN
OZF_VOLUME_OFFER_ADJ.adjust_new_products
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
ELSIF l_offerType.offer_type = 'OID' THEN
processNewPgProducts
(
  x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ELSIF l_offerType.offer_type IN ( 'ORDER','ACCRUAL','OFF_INVOICE') THEN
processNewRegProducts
(
  x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offerAdjustmentId   => p_offerAdjustmentId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END IF;
END process_new_products;

PROCEDURE updateHeaderDate
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
)
IS
CURSOR c_dates(cp_offerAdjustmentId NUMBER) IS
SELECT a.effective_date , b.start_date_active , a.list_header_id , c.offer_type , c.object_version_number
FROM ozf_offer_adjustments_b a, qp_list_headers_b b , ozf_offers c
WHERE a.list_header_id = b.list_header_id
AND b.list_header_id = c.qp_list_header_id
AND a.offer_adjustment_id = cp_offerAdjustmentId ;

l_offerType VARCHAR2(30);
l_qpListHeaderId NUMBER;
l_errorLocation NUMBER;
l_modifier_rec ozf_offer_pvt.Modifier_LIST_Rec_Type;
l_modifier_line_tbl ozf_offer_pvt.MODIFIER_LINE_TBL_TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_dates in c_dates(p_offerAdjustmentId) LOOP

    IF l_dates.start_date_active IS NOT NULL AND l_dates.start_date_active <> FND_API.G_MISS_DATE THEN
-- if effective date is before start_date of the offer update the start_date of the offer
        IF l_dates.effective_date < l_dates.start_date_active THEN
            l_modifier_rec.start_date_active := l_dates.effective_date;
        END IF;
    END IF;
    l_modifier_rec.qp_list_header_id := l_dates.list_header_id;
    l_modifier_rec.OFFER_OPERATION := Qp_Globals.G_OPR_UPDATE;
    l_modifier_rec.MODIFIER_OPERATION := Qp_Globals.G_OPR_UPDATE;
    l_modifier_rec.object_version_number := l_dates.object_version_number;
    l_offerType := l_dates.offer_type;
    OZF_OFFER_PVT.process_modifiers
    (
       p_init_msg_list         => FND_API.g_false
      ,p_api_version           => 1.0
      ,p_commit                => FND_API.g_false
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      ,p_offer_type            => l_offerType
      ,p_modifier_list_rec     => l_modifier_rec
      ,p_modifier_line_tbl     => l_modifier_line_tbl
      ,x_qp_list_header_id     => l_qpListHeaderId
      ,x_error_location        => l_errorLocation
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END LOOP;

END updateHeaderDate;
/**
Processes an Adjustment.
For a given adjustment.
End dates old discounts and creates corresponding new discounts
Create new disocunts for new products added thru. Adjustments
Maps the old list_line_id to the new list_line_id
*/
PROCEDURE process_adjustment
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
-- update header date
-- process old discounts
-- process new products
x_return_status := FND_API.G_RET_STS_SUCCESS;
updateHeaderDate
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
);
ozf_utility_pvt.debug_message('GR Updated header date:'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
process_old_discounts
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
);
ozf_utility_pvt.debug_message('after process old discounts :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
process_new_products
(
  x_return_status           => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offerAdjustmentId
);
ozf_utility_pvt.debug_message('process new products :'||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END process_adjustment;


END OZF_OFFER_ADJ_PVT;

/
