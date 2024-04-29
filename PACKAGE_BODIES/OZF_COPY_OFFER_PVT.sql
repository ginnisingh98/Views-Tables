--------------------------------------------------------
--  DDL for Package Body OZF_COPY_OFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_COPY_OFFER_PVT" AS
/* $Header: ozfvcpob.pls 120.11.12010000.3 2008/12/11 03:50:15 nirprasa ship $ */

G_CREATE CONSTANT VARCHAR2(30) := 'CREATE';
TYPE line_mapping_rec_type IS RECORD
(org_line_id NUMBER
,new_line_id NUMBER);

TYPE line_mapping_tbl_type IS TABLE OF  line_mapping_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE copy_vo_mkt_options
(
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_sourceObjectId       IN NUMBER
           , p_destOfferId          IN NUMBER
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_mkt_options';
l_api_version_number CONSTANT NUMBER := 1.0;
l_mo_rec        OZF_offer_Market_Options_PVT.vo_mo_rec_type  ;

CURSOR c_sourceMktOptions(cp_listHeaderId NUMBER , cp_groupNumber NUMBER) IS
SELECT group_number, retroactive_flag, beneficiary_party_id, combine_schedule_flag, volume_tracking_level_code, accrue_to_code, precedence
FROM ozf_offr_market_options
WHERE qp_list_header_id = cp_listHeaderId
AND group_number = cp_groupNumber;

CURSOR c_destMktOptions(cp_offerId NUMBER) IS
SELECT offer_market_option_id , object_version_number, group_number
FROM  ozf_offr_market_options
WHERE offer_id = cp_offerId;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_destMktOptions IN c_destMktOptions(cp_offerId => p_destOfferId) LOOP
l_mo_rec.offer_market_option_id     := l_destMktOptions.offer_market_option_id;
l_mo_rec.object_version_number      := l_destMktOptions.object_version_number;
l_mo_rec.group_number               := l_destMktOptions.group_number;
FOR l_sourceMktOptions IN c_sourceMktOptions(cp_listHeaderId => p_sourceObjectId, cp_groupNumber => l_destMktOptions.group_number) LOOP
l_mo_rec.retroactive_flag           := l_sourceMktOptions.retroactive_flag;
l_mo_rec.beneficiary_party_id       := l_sourceMktOptions.beneficiary_party_id;
l_mo_rec.combine_schedule_flag      := l_sourceMktOptions.combine_schedule_flag;
l_mo_rec.volume_tracking_level_code := l_sourceMktOptions.volume_tracking_level_code;
l_mo_rec.accrue_to_code             := l_sourceMktOptions.accrue_to_code;
l_mo_rec.precedence                 := l_sourceMktOptions.precedence;
END LOOP;


OZF_offer_Market_Options_PVT.Update_market_options(
    p_api_version_number         => 1.0
    , p_init_msg_list              => FND_API.G_FALSE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_mo_rec                     => l_mo_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_vo_mkt_options;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_mkt_options;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_mkt_options;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END copy_vo_mkt_options;


PROCEDURE copy_vo_products
        (
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_sourceTierHeaderId   IN NUMBER
           , p_destTierHeaderId     IN NUMBER
           , p_destOfferId          IN NUMBER
        )
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_products';
l_productId NUMBER;

CURSOR c_products(cp_sourceTierHeaderId NUMBER) IS
SELECT product_context
    , product_attribute
    , product_attr_value
    , apply_discount_flag
    , include_volume_flag
    , excluder_flag
FROM ozf_offer_discount_products
WHERE offer_discount_line_id = cp_sourceTierHeaderId;
l_vo_prod_rec OZF_Volume_Offer_disc_PVT.vo_prod_rec_type;
BEGIN
-- initialize
SAVEPOINT copy_vo_products;
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru and create products
FOR l_products IN c_products(cp_sourceTierHeaderId => p_sourceTierHeaderId) LOOP
l_vo_prod_rec.excluder_flag := l_products.excluder_flag;
l_vo_prod_rec.offer_discount_line_id := p_destTierHeaderId;
l_vo_prod_rec.offer_id := p_destOfferId;
l_vo_prod_rec.product_context := l_products.product_context;
l_vo_prod_rec.product_attribute := l_products.product_attribute;
l_vo_prod_rec.product_attr_value := l_products.product_attr_value;
l_vo_prod_rec.apply_discount_flag := l_products.apply_discount_flag;
l_vo_prod_rec.include_volume_flag := l_products.include_volume_flag;

OZF_Volume_Offer_disc_PVT.Create_vo_product(
    p_api_version_number            => 1.0
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_validation_level            => FND_API.G_VALID_LEVEL_FULL

    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data

    , p_vo_prod_rec                 => l_vo_prod_rec
    , x_off_discount_product_id     => l_productId
    );

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

-- exception
END copy_vo_products;

PROCEDURE copy_vo_qualifiers
        (
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_destListHeaderId     IN NUMBER
           , p_sourceListHeaderId   IN NUMBER
        )
IS
CURSOR c_qualifiers(cp_listHeaderId NUMBER) IS
SELECT qualifier_context
       , qualifier_attribute
       , qualifier_attr_value
       , comparison_operator_code
       , qualifier_attr_value_to
       , qualifier_grouping_no
       , list_header_id
       , start_date_active
       , end_date_active
       , active_flag
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
FROM qp_qualifiers
WHERE list_header_id = cp_listHeaderId;

l_qualifiers_rec OZF_OFFER_PVT.qualifiers_Rec_Type;
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_qualifiers';
BEGIN
-- initialize
SAVEPOINT copy_vo_qualifiers;
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru and create qualifiers
FOR l_qualifiers IN c_qualifiers(cp_listHeaderId => p_sourceListHeaderId) LOOP

l_qualifiers_rec.qualifier_context          := l_qualifiers.qualifier_context;
l_qualifiers_rec.qualifier_attribute        := l_qualifiers.qualifier_attribute;
l_qualifiers_rec.qualifier_attr_value       := l_qualifiers.qualifier_attr_value;
l_qualifiers_rec.comparison_operator_code   := l_qualifiers.comparison_operator_code;
l_qualifiers_rec.qualifier_attr_value_to    := l_qualifiers.qualifier_attr_value_to;
l_qualifiers_rec.qualifier_grouping_no      := l_qualifiers.qualifier_grouping_no;
l_qualifiers_rec.list_header_id             := p_destListHeaderId;
l_qualifiers_rec.start_date_active          := l_qualifiers.start_date_active;
l_qualifiers_rec.end_date_active            := l_qualifiers.end_date_active;
--l_qualifiers_rec.active_flag                := l_qualifiers.active_flag;
l_qualifiers_rec.context                    := l_qualifiers.context;
l_qualifiers_rec.attribute1                 := l_qualifiers.attribute1;
l_qualifiers_rec.attribute2                 := l_qualifiers.attribute2;
l_qualifiers_rec.attribute3                 := l_qualifiers.attribute3;
l_qualifiers_rec.attribute4                 := l_qualifiers.attribute4;
l_qualifiers_rec.attribute5                 := l_qualifiers.attribute5;
l_qualifiers_rec.attribute6                 := l_qualifiers.attribute6;
l_qualifiers_rec.attribute7                 := l_qualifiers.attribute7;
l_qualifiers_rec.attribute8                 := l_qualifiers.attribute8;
l_qualifiers_rec.attribute9                 := l_qualifiers.attribute9;
l_qualifiers_rec.attribute10                := l_qualifiers.attribute10;
l_qualifiers_rec.attribute11                := l_qualifiers.attribute11;
l_qualifiers_rec.attribute12                := l_qualifiers.attribute12;
l_qualifiers_rec.attribute13                := l_qualifiers.attribute13;
l_qualifiers_rec.attribute14                := l_qualifiers.attribute14;
l_qualifiers_rec.attribute15                := l_qualifiers.attribute15;


OZF_Volume_Offer_Qual_PVT.create_vo_qualifier
(
    p_api_version_number         => 1.0
    , p_init_msg_list            => FND_API.G_FALSE
    , p_commit                   => FND_API.G_FALSE
    , p_validation_level         => FND_API.G_VALID_LEVEL_FULL

    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data

    , p_qualifiers_rec           => l_qualifiers_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_vo_qualifiers;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_qualifiers;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_qualifiers;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

-- exception
END copy_vo_qualifiers;



PROCEDURE copy_vo_tiers
        (
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_sourceTierHeaderId   IN NUMBER
           , p_destTierHeaderId     IN NUMBER
           , p_destOfferId          IN NUMBER
        )
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_tiers';
CURSOR c_tiers(cp_parentDiscountId NUMBER) IS
SELECT volume_from
        , volume_to
        , discount
        , formula_id
        , tier_type
        , volume_operator
        , volume_break_type
        , tier_level
FROM ozf_offer_discount_lines
WHERE parent_discount_line_id = cp_parentDiscountId;

l_discountLineId NUMBER;
l_vo_disc_rec OZF_Volume_Offer_disc_PVT.vo_disc_rec_type;

BEGIN
-- initialize
SAVEPOINT copy_vo_tiers;
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru and populate discounts
-- create tiers
FOR l_tiers IN c_tiers(cp_parentDiscountId => p_sourceTierHeaderId) LOOP
l_vo_disc_rec.offer_id                  := p_destOfferId;
l_vo_disc_rec.parent_discount_line_id   := p_destTierHeaderId;
l_vo_disc_rec.tier_type                 := l_tiers.tier_type;
l_vo_disc_rec.volume_from               := l_tiers.volume_from;
l_vo_disc_rec.volume_to                 := l_tiers.volume_to;
l_vo_disc_rec.volume_operator           := l_tiers.volume_operator;
l_vo_disc_rec.volume_break_type         := l_tiers.volume_break_type;
l_vo_disc_rec.discount                  := l_tiers.discount;
l_vo_disc_rec.formula_id                := l_tiers.formula_id;
l_vo_disc_rec.tier_level                := l_tiers.tier_level;

OZF_Volume_Offer_disc_PVT.Create_vo_discount(
    p_api_version_number            => 1.0
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_validation_level            => FND_API.G_VALID_LEVEL_FULL

    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data

    , p_vo_disc_rec                 => l_vo_disc_rec
    , x_vo_discount_line_id         => l_discountLineId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Discount LineId created is: '||l_discountLineId);


END LOOP;

-- exception
null;
END copy_vo_tiers;

PROCEDURE copy_vo_discounts
        (
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_sourceObjectId       IN NUMBER
           , p_destOfferId          IN NUMBER
        )
IS
l_vo_disc_rec OZF_Volume_Offer_disc_PVT.vo_disc_rec_type;
l_discountLineId NUMBER;
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_discounts';


CURSOR c_pbh (cp_offerId NUMBER) IS
SELECT  a.volume_type
        , a.volume_break_type
        , a.discount_type
        , a.uom_code
        , c.discount_table_name
        , c.description
        , a.tier_level
        , a.offer_discount_line_id
FROM ozf_offer_discount_lines a, ozf_offr_disc_struct_name_b b , ozf_offr_disc_struct_name_tl c
WHERE a.offer_discount_line_id = b.offer_discount_Line_id
AND b.offr_disc_struct_name_id = c.offr_disc_struct_name_id
AND c.language = USERENV('LANG')
AND a.offer_id = cp_offerId;

CURSOR c_offerId(cp_listHeaderId NUMBER) IS
SELECT offer_id FROM ozf_offers
WHERE qp_list_header_id = cp_listHeaderId;
l_sourceOfferId NUMBER := null;
BEGIN
-- initialize
SAVEPOINT copy_vo_discounts;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_sourceOfferId := null;

OPEN c_offerId(cp_listHeaderId => p_sourceObjectId);
    FETCH c_offerId INTO l_sourceOfferId;
    IF c_offerId%NOTFOUND THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_CPY_NO_OFFER');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
CLOSE c_offerId;


FOR l_pbh in c_pbh(cp_offerId => l_sourceOfferId ) LOOP

l_vo_disc_rec.offer_id := p_destOfferId;
l_vo_disc_rec.tier_type := 'PBH';
l_vo_disc_rec.volume_type := l_pbh.volume_type;
l_vo_disc_rec.volume_break_type := l_pbh.volume_break_type;
l_vo_disc_rec.discount_type := l_pbh.discount_type;
l_vo_disc_rec.uom_code := l_pbh.uom_code;
l_vo_disc_rec.name := l_pbh.discount_table_name;
l_vo_disc_rec.description := l_pbh.description;
l_vo_disc_rec.tier_level := l_pbh.tier_level;

ozf_utility_pvt.debug_message('Calling create PBH disc');
OZF_Volume_Offer_disc_PVT.Create_vo_discount(
    p_api_version_number            => 1.0
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_validation_level            => FND_API.G_VALID_LEVEL_FULL

    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data

    , p_vo_disc_rec                 => l_vo_disc_rec
    , x_vo_discount_line_id         => l_discountLineId
);

ozf_utility_pvt.debug_message('PBH Id is:'||l_discountLineId);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- create discounts
copy_vo_tiers
        (
           p_api_version            => 1.0
           , p_init_msg_list        => FND_API.G_FALSE
           , p_commit               => FND_API.G_FALSE
           , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
           , x_return_status        => x_return_status
           , x_msg_count            => x_msg_count
           , x_msg_data             => x_msg_data
           , p_sourceTierHeaderId   => l_pbh.offer_discount_line_id
           , p_destTierHeaderId     => l_discountLineId
           , p_destOfferId          => p_destOfferId
        );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('Discount Tier created is:'||l_discountLineId);

-- create products
copy_vo_products
        (
           p_api_version            => 1.0
           , p_init_msg_list        => FND_API.G_FALSE
           , p_commit               => FND_API.G_FALSE
           , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
           , x_return_status        => x_return_status
           , x_msg_count            => x_msg_count
           , x_msg_data             => x_msg_data
           , p_sourceTierHeaderId   => l_pbh.offer_discount_line_id
           , p_destTierHeaderId     => l_discountLineId
           , p_destOfferId          => p_destOfferId
        );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_vo_discounts;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_discounts;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_discounts;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

-- loop thru source discounts
-- create pbh
-- use pbh id to create discount lines
-- use pbh id to create products

--   exception
END copy_vo_discounts;

PROCEDURE copy_vo_preset_tiers
(
           p_api_version            IN NUMBER
           , p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_sourceObjectId       IN NUMBER
           , p_destOfferId          IN NUMBER
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_preset_tiers';
l_api_version_number CONSTANT NUMBER := 1.0;
BEGIN
-- initialize
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- loop thru. and copy the preset tiers for source object
/*l_preset_tier_rec.offer_market_option_id := 101000;
l_preset_tier_rec.pbh_offer_discount_id := 7001;
l_preset_tier_rec.dis_offer_discount_id := 7002;*/
/*OZF_MO_PRESET_TIERS_PVT.Create_mo_preset_tiers(
    p_api_version_number         => 1.0
    , p_init_msg_list              => FND_API.G_FALSE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_preset_tier_rec            => l_preset_tier_rec
    , x_market_preset_tier_id      => l_market_preset_tier_id
);*/
-- exception
END copy_vo_preset_tiers;



PROCEDURE copy_vo_header(
           p_api_version            IN  NUMBER
           , p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
           , p_commit               IN  VARCHAR2 := FND_API.G_FALSE
           , p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
           , x_return_status        OUT NOCOPY VARCHAR2
           , x_msg_count            OUT NOCOPY NUMBER
           , x_msg_data             OUT NOCOPY VARCHAR2
           , p_listHeaderId         IN  NUMBER
           , x_OfferId              OUT NOCOPY NUMBER
           , x_listHeaderId         OUT NOCOPY NUMBER
           , p_copy_columns_table   IN  AMS_CpyUtility_PVT.copy_columns_table_type
           , p_attributes_table   IN  AMS_CpyUtility_PVT.copy_attributes_table_type
           , p_custom_setup_id      IN  NUMBER
           )
IS
l_modifier_list_rec OZF_OFFER_PVT.modifier_list_rec_type ;
l_modifier_line_tbl OZF_OFFER_PVT.MODIFIER_LINE_TBL_TYPE ;
l_listHeaderId NUMBER;
l_errLoc NUMBER;
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'copy_vo_header';
l_offer_type CONSTANT VARCHAR2(30) := 'VOLUME_OFFER';
l_offer_id NUMBER;
CURSOR c_offer_details (p_listHeaderId NUMBER) IS
SELECT a.modifier_level_code
       , a.offer_type
       , a.activity_media_id
       , a.reusable
       , b.list_type_code
       , a.transaction_currency_code
       , a.perf_date_from
       , a.perf_date_to
       , a.custom_setup_id
       , a.functional_currency_code
       , b.currency_code
       , b.ask_for_flag
       , b.start_date_active_first
       , b.end_date_active_first
       , b.active_date_first_type
       , b.start_date_active_second
       , b.end_date_active_second
       , b.active_date_second_type
       , a.budget_source_type
       , a.budget_source_id
       , a.budget_amount_tc
       , a.offer_amount
       , a.volume_offer_type
       , a.budget_offer_yn
       , a.confidential_flag
       , a.source_from_parent
       , b.global_flag
       , b.orig_org_id
       , b.context
       , b.attribute1
       , b.attribute2
       , b.attribute3
       , b.attribute4
       , b.attribute5
       , b.attribute6
       , b.attribute7
       , b.attribute8
       , b.attribute9
       , b.attribute10
       , b.attribute11
       , b.attribute12
       , b.attribute13
       , b.attribute14
       , b.attribute15
       FROM ozf_offers a, qp_list_headers_all b
       WHERE a.qp_list_header_id = b.list_header_id
       AND a.qp_list_header_id = p_listHeaderId;

CURSOR c_offerId (cp_listHeaderId NUMBER) IS
SELECT offer_id FROM ozf_offers
WHERE qp_list_header_id = cp_listHeaderId ;

BEGIN
-- establish save point
    SAVEPOINT copy_vo_header;
    -- check api version compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- initialize the record sent to api for creation
    l_modifier_list_rec := null;

    -- populate ui values into record.
    AMS_CpyUtility_PVT.get_column_value ('newObjName'         , p_copy_columns_table  , l_modifier_list_rec.description);
    AMS_CpyUtility_PVT.get_column_value ('offerCode'          , p_copy_columns_table  , l_modifier_list_rec.offer_code);
    AMS_CpyUtility_PVT.get_column_value ('startDateActive'    , p_copy_columns_table  , l_modifier_list_rec.start_date_active);
    AMS_CpyUtility_PVT.get_column_value ('endDateActive'      , p_copy_columns_table  , l_modifier_list_rec.end_date_active);
    AMS_CpyUtility_PVT.get_column_value ('ownerId'            , p_copy_columns_table  , l_modifier_list_rec.owner_id);
    AMS_CpyUtility_PVT.get_column_value ('description'        , p_copy_columns_table  , l_modifier_list_rec.comments);

    FOR l_offer_details IN c_offer_details(p_listHeaderId) LOOP
    -- populate source object values into the record
        l_modifier_list_rec.modifier_level_code         := l_offer_details.modifier_level_code;
        l_modifier_list_rec.offer_type                  := l_offer_type;
        l_modifier_list_rec.activity_media_id           := l_offer_details.activity_media_id;
        l_modifier_list_rec.reusable                    := l_offer_details.reusable;
        l_modifier_list_rec.list_type_code              := l_offer_details.list_type_code;
        l_modifier_list_rec.transaction_currency_code   := l_offer_details.transaction_currency_code;
        l_modifier_list_rec.perf_date_from              := l_offer_details.perf_date_from;
        l_modifier_list_rec.perf_date_to                := l_offer_details.perf_date_to;
        l_modifier_list_rec.custom_setup_id             := p_custom_setup_id;
        l_modifier_list_rec.functional_currency_code    := l_offer_details.functional_currency_code;
        l_modifier_list_rec.currency_code               := l_offer_details.currency_code;
        l_modifier_list_rec.ask_for_flag                := l_offer_details.ask_for_flag;
        l_modifier_list_rec.start_date_active_first     := l_offer_details.start_date_active_first;
        l_modifier_list_rec.end_date_active_first       := l_offer_details.end_date_active_first;
        l_modifier_list_rec.active_date_first_type      := l_offer_details.active_date_first_type;
        l_modifier_list_rec.start_date_active_second    := l_offer_details.start_date_active_second;
        l_modifier_list_rec.end_date_active_second      := l_offer_details.end_date_active_second;
        l_modifier_list_rec.active_date_second_type     := l_offer_details.active_date_second_type;
        l_modifier_list_rec.budget_source_type          := l_offer_details.budget_source_type;
        l_modifier_list_rec.budget_source_id            := l_offer_details.budget_source_id;
        l_modifier_list_rec.budget_amount_tc            := l_offer_details.budget_amount_tc;
        l_modifier_list_rec.budget_offer_yn             := l_offer_details.budget_offer_yn ;
        l_modifier_list_rec.offer_amount                := l_offer_details.offer_amount;
        l_modifier_list_rec.volume_offer_type           := l_offer_details.volume_offer_type;
        l_modifier_list_rec.confidential_flag           := l_offer_details.confidential_flag;
        --l_modifier_list_rec.committed_amount_eq_max     :=
        l_modifier_list_rec.source_from_parent          := l_offer_details.source_from_parent;
        l_modifier_list_rec.global_flag                 := l_offer_details.global_flag;
        l_modifier_list_rec.orig_org_id                  := l_offer_details.orig_org_id;
        l_modifier_list_rec.modifier_operation          := G_CREATE;
        l_modifier_list_rec.offer_operation             := G_CREATE;

        l_modifier_list_rec.offer_id                    := FND_API.G_MISS_NUM;
        l_modifier_list_rec.amount_limit_id             := FND_API.G_MISS_NUM;
        l_modifier_list_rec.uses_limit_id               := FND_API.G_MISS_NUM;
        l_modifier_list_rec.qp_list_header_id           := FND_API.G_MISS_NUM;


        l_modifier_list_rec.context                     := l_offer_details.context;
        l_modifier_list_rec.attribute1                  := l_offer_details.attribute1;
        l_modifier_list_rec.attribute2                  := l_offer_details.attribute2;
        l_modifier_list_rec.attribute3                  := l_offer_details.attribute3;
        l_modifier_list_rec.attribute4                  := l_offer_details.attribute4;
        l_modifier_list_rec.attribute5                  := l_offer_details.attribute5;
        l_modifier_list_rec.attribute6                  := l_offer_details.attribute6;
        l_modifier_list_rec.attribute7                  := l_offer_details.attribute7;
        l_modifier_list_rec.attribute8                  := l_offer_details.attribute8;
        l_modifier_list_rec.attribute9                  := l_offer_details.attribute9;
        l_modifier_list_rec.attribute10                 := l_offer_details.attribute10;
        l_modifier_list_rec.attribute11                 := l_offer_details.attribute11;
        l_modifier_list_rec.attribute12                 := l_offer_details.attribute12;
        l_modifier_list_rec.attribute13                 := l_offer_details.attribute13;
        l_modifier_list_rec.attribute14                 := l_offer_details.attribute14;
        l_modifier_list_rec.attribute15                 := l_offer_details.attribute15;

    END LOOP;

    -- call api to create new header
    OZF_OFFER_PVT.process_modifiers
    (
    p_init_msg_list         => FND_API.G_FALSE
    ,p_api_version           => 1.0
    ,p_commit                => FND_API.G_FALSE
    ,x_return_status         => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
    ,p_offer_type            => l_offer_type
    ,p_modifier_list_rec     => l_modifier_list_rec
    ,p_modifier_line_tbl     => l_modifier_line_tbl
    ,x_qp_list_header_id     => l_listHeaderId
    ,x_error_location        => l_errLoc
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_offer_id := null;

    OPEN c_offerId(cp_listHeaderId => l_listHeaderId);
        FETCH c_offerId into l_offer_id;
        IF c_offerId%NOTFOUND THEN
            l_offer_id := -1;
        END IF;
    CLOSE c_offerId;

    copy_vo_discounts
            (
               p_api_version        => 1.0
               , p_init_msg_list      => FND_API.G_FALSE
               , p_commit             => FND_API.G_FALSE
               , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
               , x_return_status      => x_return_status
               , x_msg_count          => x_msg_count
               , x_msg_data           => x_msg_data
               , p_sourceObjectId      => p_listHeaderId
               , p_destOfferId        => l_offer_id
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        -- copy qualifiers
    IF AMS_CpyUtility_PVT.is_copy_attribute ('ELIG', p_attributes_table) = FND_API.G_TRUE THEN
        ozf_utility_pvt.debug_message('Copy Eligibility');
        copy_vo_qualifiers
                (
                   p_api_version        => 1.0
                   , p_init_msg_list      => FND_API.G_FALSE
                   , p_commit             => FND_API.G_FALSE
                   , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                   , x_return_status      => x_return_status
                   , x_msg_count          => x_msg_count
                   , x_msg_data           => x_msg_data
                   , p_sourceListHeaderId => p_listHeaderId
                   , p_destListHeaderId   => l_listHeaderId
                );
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        -- copy market options
        -- market options are created with default options, so update the market options to the ones in the source offer
        IF AMS_CpyUtility_PVT.is_copy_attribute ('MKT_OPT', p_attributes_table) = FND_API.G_TRUE THEN
        ozf_utility_pvt.debug_message('Copy Market Options');
            copy_vo_mkt_options
            (
                       p_api_version        => 1.0
                       , p_init_msg_list      => FND_API.G_FALSE
                       , p_commit             => FND_API.G_FALSE
                       , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                       , x_return_status      => x_return_status
                       , x_msg_count          => x_msg_count
                       , x_msg_data           => x_msg_data
                       , p_sourceObjectId     => p_listHeaderId
                       , p_destOfferId        => l_offer_id
            );

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    ozf_utility_pvt.debug_message('QplistHeaderId returned :'||l_listHeaderId);

    ozf_utility_pvt.debug_message('OfferId  :'||l_offer_id);
    x_OfferId := l_offer_id;
    x_listHeaderId := l_listHeaderId;
-- exception
EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_vo_header;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_header;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_vo_header;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END copy_vo_header;


FUNCTION get_rltd_line_id(l_org_list_header_id NUMBER, l_new_list_header_id NUMBER)
RETURN line_mapping_tbl_type
IS

  l_line_mapping_tbl line_mapping_tbl_type;
  l_index    NUMBER := 0;

  CURSOR c_mod_sum IS
  SELECT *
    FROM qp_modifier_summary_v
   WHERE list_header_id = l_org_list_header_id;
--  l_mod_sum_rec c_mod_sum%ROWTYPE;

  CURSOR c_list_line_id(l_mod_sum_rec c_mod_sum%ROWTYPE) IS
  SELECT list_line_id
    FROM qp_modifier_summary_v
   WHERE list_header_id = l_new_list_header_id
     AND list_line_type_code = l_mod_sum_rec.list_line_type_code
     AND automatic_flag = l_mod_sum_rec.automatic_flag
     AND modifier_level_code = l_mod_sum_rec.modifier_level_code
     AND NVL(price_break_type_code,'z') = NVL(l_mod_sum_rec.price_break_type_code,'z')
     AND NVL(operand,-99999) = NVL(l_mod_sum_rec.operand,-99999)
     AND NVL(arithmetic_operator,'z') = NVL(l_mod_sum_rec.arithmetic_operator,'z')
     AND NVL(override_flag,'z') = NVL(l_mod_sum_rec.override_flag,'z')
     AND NVL(print_on_invoice_flag,'z') = NVL(l_mod_sum_rec.print_on_invoice_flag,'z')
     AND NVL(pricing_group_sequence,-99999) = NVL(l_mod_sum_rec.pricing_group_sequence,-99999)
     AND NVL(incompatibility_grp_code,'z') = NVL(l_mod_sum_rec.incompatibility_grp_code,'z')
     AND NVL(product_precedence,-99999) = NVL(l_mod_sum_rec.product_precedence,-99999)
     AND NVL(pricing_phase_id,-99999) = NVL(l_mod_sum_rec.pricing_phase_id,-99999)
     AND NVL(product_attribute_context,'z') = NVL(l_mod_sum_rec.product_attribute_context,'z')
     AND NVL(product_attr,'z') = NVL(l_mod_sum_rec.product_attr,'z')
     AND NVL(product_attr_val,'z') = NVL(l_mod_sum_rec.product_attr_val,'z')
     AND NVL(product_uom_code,'z') = NVL(l_mod_sum_rec.product_uom_code,'z')
     AND NVL(comparison_operator_code,'z') = NVL(l_mod_sum_rec.comparison_operator_code,'z')
     AND NVL(pricing_attribute_context,'z') = NVL(l_mod_sum_rec.pricing_attribute_context,'z')
     AND NVL(pricing_attr,'z') = NVL(l_mod_sum_rec.pricing_attr,'z')
     AND NVL(pricing_attr_value_from,'z') = NVL(l_mod_sum_rec.pricing_attr_value_from,'z')
     AND NVL(pricing_attr_value_to,'z') = NVL(l_mod_sum_rec.pricing_attr_value_to,'z')
     AND NVL(excluder_flag,'z') = NVL(l_mod_sum_rec.excluder_flag,'z')
     AND NVL(attribute_grouping_no,-99999) = NVL(l_mod_sum_rec.attribute_grouping_no,-99999)
     AND NVL(to_rltd_modifier_id,'z') = NVL(l_mod_sum_rec.to_rltd_modifier_id,'z')
     AND NVL(rltd_modifier_id,'z') = NVL(l_mod_sum_rec.rltd_modifier_id,'z')
     AND NVL(accrual_flag,'z') = NVL(l_mod_sum_rec.accrual_flag,'z')
     AND NVL(accrual_conversion_rate,-99999) = NVL(l_mod_sum_rec.accrual_conversion_rate,-99999)
     AND NVL(estim_accrual_rate,-99999) = NVL(l_mod_sum_rec.estim_accrual_rate,-99999)
     AND NVL(price_by_formula_id,-99999) = NVL(l_mod_sum_rec.price_by_formula_id,-99999)
     AND NVL(generate_using_formula_id,-99999) = NVL(l_mod_sum_rec.generate_using_formula_id,-99999);
/*
     AND LIST_LINE_TYPE_CODE = l_mod_sum_rec.LIST_LINE_TYPE_CODE
     AND AUTOMATIC_FLAG = l_mod_sum_rec.AUTOMATIC_FLAG
     AND MODIFIER_LEVEL_CODE = l_mod_sum_rec.MODIFIER_LEVEL_CODE
     AND NVL(LIST_PRICE,-99999) = NVL(l_mod_sum_rec.LIST_PRICE,-99999)
     AND NVL(LIST_PRICE_UOM_CODE,'z') = NVL(l_mod_sum_rec.LIST_PRICE_UOM_CODE,'z')
     AND NVL(PRIMARY_UOM_FLAG,'z') = NVL(l_mod_sum_rec.PRIMARY_UOM_FLAG,'z')
     AND NVL(INVENTORY_ITEM_ID,-99999) = NVL(l_mod_sum_rec.INVENTORY_ITEM_ID,-99999)
     AND NVL(ORGANIZATION_ID,-99999) = NVL(l_mod_sum_rec.ORGANIZATION_ID,-99999)
     AND NVL(RELATED_ITEM_ID,-99999) = NVL(l_mod_sum_rec.RELATED_ITEM_ID,-99999)
     AND NVL(RELATIONSHIP_TYPE_ID,-99999) = NVL(l_mod_sum_rec.RELATIONSHIP_TYPE_ID,-99999)
     AND NVL(SUBSTITUTION_CONTEXT,'z') = NVL(l_mod_sum_rec.SUBSTITUTION_CONTEXT,'z')
     AND NVL(SUBSTITUTION_ATTR,'z') = NVL(l_mod_sum_rec.SUBSTITUTION_ATTR,'z')
     AND NVL(SUBSTITUTION_VAL,'z') = NVL(l_mod_sum_rec.SUBSTITUTION_VAL,'z')
     AND NVL(REVISION,'z') = NVL(l_mod_sum_rec.REVISION,'z')
     AND NVL(REVISION_REASON_CODE,'z') = NVL(l_mod_sum_rec.REVISION_REASON_CODE,'z')
     AND NVL(CONTEXT,'z') = NVL(l_mod_sum_rec.CONTEXT,'z')
     AND NVL(ATTRIBUTE1,'z') = NVL(l_mod_sum_rec.ATTRIBUTE1,'z')
     AND NVL(ATTRIBUTE2,'z') = NVL(l_mod_sum_rec.ATTRIBUTE2,'z')
     AND NVL(COMMENTS,'z') = NVL(l_mod_sum_rec.COMMENTS,'z')
     AND NVL(ATTRIBUTE3,'z') = NVL(l_mod_sum_rec.ATTRIBUTE3,'z')
     AND NVL(ATTRIBUTE4,'z') = NVL(l_mod_sum_rec.ATTRIBUTE4,'z')
     AND NVL(ATTRIBUTE5,'z') = NVL(l_mod_sum_rec.ATTRIBUTE5,'z')
     AND NVL(ATTRIBUTE6,'z') = NVL(l_mod_sum_rec.ATTRIBUTE6,'z')
     AND NVL(ATTRIBUTE7,'z') = NVL(l_mod_sum_rec.ATTRIBUTE7,'z')
     AND NVL(ATTRIBUTE8,'z') = NVL(l_mod_sum_rec.ATTRIBUTE8,'z')
     AND NVL(ATTRIBUTE9,'z') = NVL(l_mod_sum_rec.ATTRIBUTE9,'z')
     AND NVL(ATTRIBUTE10,'z') = NVL(l_mod_sum_rec.ATTRIBUTE10,'z')
     AND NVL(INCLUDE_ON_RETURNS_FLAG,'z') = NVL(l_mod_sum_rec.INCLUDE_ON_RETURNS_FLAG,'z')
     AND NVL(ATTRIBUTE11,'z') = NVL(l_mod_sum_rec.ATTRIBUTE11,'z')
     AND NVL(ATTRIBUTE12,'z') = NVL(l_mod_sum_rec.ATTRIBUTE12,'z')
     AND NVL(ATTRIBUTE13,'z') = NVL(l_mod_sum_rec.ATTRIBUTE13,'z')
     AND NVL(ATTRIBUTE14,'z') = NVL(l_mod_sum_rec.ATTRIBUTE14,'z')
     AND NVL(ATTRIBUTE15,'z') = NVL(l_mod_sum_rec.ATTRIBUTE15,'z')
     AND NVL(PRICE_BREAK_TYPE_CODE,'z') = NVL(l_mod_sum_rec.PRICE_BREAK_TYPE_CODE,'z')
     AND NVL(PERCENT_PRICE,-99999) = NVL(l_mod_sum_rec.PERCENT_PRICE,-99999)
     AND NVL(EFFECTIVE_PERIOD_UOM,'z') = NVL(l_mod_sum_rec.EFFECTIVE_PERIOD_UOM,'z')
     AND NVL(NUMBER_EFFECTIVE_PERIODS,-99999) = NVL(l_mod_sum_rec.NUMBER_EFFECTIVE_PERIODS,-99999)
     AND NVL(OPERAND,-99999) = NVL(l_mod_sum_rec.OPERAND,-99999)
     AND NVL(ARITHMETIC_OPERATOR,'z') = NVL(l_mod_sum_rec.ARITHMETIC_OPERATOR,'z')
     AND NVL(OVERRIDE_FLAG,'z') = NVL(l_mod_sum_rec.OVERRIDE_FLAG,'z')
     AND NVL(PRINT_ON_INVOICE_FLAG,'z') = NVL(l_mod_sum_rec.PRINT_ON_INVOICE_FLAG,'z')
     AND NVL(REBATE_TRANSACTION_TYPE_CODE,'z') = NVL(l_mod_sum_rec.REBATE_TRANSACTION_TYPE_CODE,'z')
     AND NVL(DB_ESTIM_ACCRUAL_RATE,-99999) = NVL(l_mod_sum_rec.DB_ESTIM_ACCRUAL_RATE,-99999)
     AND NVL(PRICE_BY_FORMULA_ID,-99999) = NVL(l_mod_sum_rec.PRICE_BY_FORMULA_ID,-99999)
     AND NVL(GENERATE_USING_FORMULA_ID,-99999) = NVL(l_mod_sum_rec.GENERATE_USING_FORMULA_ID,-99999)
     AND NVL(REPRICE_FLAG,'z') = NVL(l_mod_sum_rec.REPRICE_FLAG,'z')
     AND NVL(DB_ACCRUAL_FLAG,'z') = NVL(l_mod_sum_rec.DB_ACCRUAL_FLAG,'z')
     AND NVL(PRICING_GROUP_SEQUENCE,-99999) = NVL(l_mod_sum_rec.PRICING_GROUP_SEQUENCE,-99999)
     AND NVL(INCOMPATIBILITY_GRP_CODE,'z') = NVL(l_mod_sum_rec.INCOMPATIBILITY_GRP_CODE,'z')
     AND NVL(LIST_LINE_NO,'z') = NVL(l_mod_sum_rec.LIST_LINE_NO,'z')
     AND NVL(PRODUCT_PRECEDENCE,-99999) = NVL(l_mod_sum_rec.PRODUCT_PRECEDENCE,-99999)
     AND NVL(PRICING_PHASE_ID,-99999) = NVL(l_mod_sum_rec.PRICING_PHASE_ID,-99999)
     AND NVL(DB_NUMBER_EXPIRATION_PERIODS,-99999) = NVL(l_mod_sum_rec.DB_NUMBER_EXPIRATION_PERIODS,-99999)
     AND NVL(DB_EXPIRATION_PERIOD_UOM,'z') = NVL(l_mod_sum_rec.DB_EXPIRATION_PERIOD_UOM,'z')
     AND NVL(ESTIM_GL_VALUE,-99999) = NVL(l_mod_sum_rec.ESTIM_GL_VALUE,-99999)
     AND NVL(DB_ACCRUAL_CONVERSION_RATE,-99999) = NVL(l_mod_sum_rec.DB_ACCRUAL_CONVERSION_RATE,-99999)
     AND NVL(BENEFIT_PRICE_LIST_LINE_ID,-99999) = NVL(l_mod_sum_rec.BENEFIT_PRICE_LIST_LINE_ID,-99999)
     AND NVL(PRORATION_TYPE_CODE,'z') = NVL(l_mod_sum_rec.PRORATION_TYPE_CODE,'z')
     AND NVL(DB_BENEFIT_QTY,-99999) = NVL(l_mod_sum_rec.DB_BENEFIT_QTY,-99999)
     AND NVL(DB_BENEFIT_UOM_CODE,'z') = NVL(l_mod_sum_rec.DB_BENEFIT_UOM_CODE,'z')
     AND NVL(CHARGE_TYPE_CODE,'z') = NVL(l_mod_sum_rec.CHARGE_TYPE_CODE,'z')
     AND NVL(CHARGE_SUBTYPE_CODE,'z') = NVL(l_mod_sum_rec.CHARGE_SUBTYPE_CODE,'z')
     AND NVL(BENEFIT_LIMIT,-99999) = NVL(l_mod_sum_rec.BENEFIT_LIMIT,-99999)
     AND NVL(PRODUCT_ATTRIBUTE_CONTEXT,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTRIBUTE_CONTEXT,'z')
     AND NVL(PRODUCT_ATTR,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTR,'z')
     AND NVL(PRODUCT_ATTR_VAL,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTR_VAL,'z')
     AND NVL(PRODUCT_UOM_CODE,'z') = NVL(l_mod_sum_rec.PRODUCT_UOM_CODE,'z')
     AND NVL(COMPARISON_OPERATOR_CODE,'z') = NVL(l_mod_sum_rec.COMPARISON_OPERATOR_CODE,'z')
     AND NVL(PRICING_ATTRIBUTE_CONTEXT,'z') = NVL(l_mod_sum_rec.PRICING_ATTRIBUTE_CONTEXT,'z')
     AND NVL(PRICING_ATTR,'z') = NVL(l_mod_sum_rec.PRICING_ATTR,'z')
     AND NVL(PRICING_ATTR_VALUE_FROM,'z') = NVL(l_mod_sum_rec.PRICING_ATTR_VALUE_FROM,'z')
     AND NVL(PRICING_ATTR_VALUE_TO,'z') = NVL(l_mod_sum_rec.PRICING_ATTR_VALUE_TO,'z')
     AND NVL(PRICING_ATTRIBUTE_DATATYPE,'z') = NVL(l_mod_sum_rec.PRICING_ATTRIBUTE_DATATYPE,'z')
     AND NVL(PRODUCT_ATTRIBUTE_DATATYPE,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTRIBUTE_DATATYPE,'z')
     AND NVL(EXCLUDER_FLAG,'z') = NVL(l_mod_sum_rec.EXCLUDER_FLAG,'z')
     AND NVL(ATTRIBUTE_GROUPING_NO,-99999) = NVL(l_mod_sum_rec.ATTRIBUTE_GROUPING_NO,-99999)
     AND NVL(TO_RLTD_MODIFIER_ID,'z') = NVL(l_mod_sum_rec.TO_RLTD_MODIFIER_ID,'z')
     AND NVL(RLTD_MODIFIER_GRP_NO,'z') = NVL(l_mod_sum_rec.RLTD_MODIFIER_GRP_NO,'z')
     AND NVL(RLTD_MODIFIER_GRP_TYPE,'z') = NVL(l_mod_sum_rec.RLTD_MODIFIER_GRP_TYPE,'z')
     AND NVL(RLTD_MODIFIER_ID,'z') = NVL(l_mod_sum_rec.RLTD_MODIFIER_ID,'z')
     AND NVL(PRORATION_TYPE,'z') = NVL(l_mod_sum_rec.PRORATION_TYPE,'z')
     AND NVL(PRICING_PHASE,'z') = NVL(l_mod_sum_rec.PRICING_PHASE,'z')
     AND NVL(INCOMPATIBILITY_GRP,'z') = NVL(l_mod_sum_rec.INCOMPATIBILITY_GRP,'z')
     AND NVL(MODIFIER_LEVEL,'z') = NVL(l_mod_sum_rec.MODIFIER_LEVEL,'z')
     AND NVL(LIST_LINE_TYPE,'z') = NVL(l_mod_sum_rec.LIST_LINE_TYPE,'z')
     AND NVL(PRICE_BREAK_TYPE,'z') = NVL(l_mod_sum_rec.PRICE_BREAK_TYPE,'z')
     AND NVL(CHARGE_NAME,'z') = NVL(l_mod_sum_rec.CHARGE_NAME,'z')
     AND NVL(FORMULA,'z') = NVL(l_mod_sum_rec.FORMULA,'z')
     AND NVL(ARITHMETIC_OPERATOR_TYPE,'z') = NVL(l_mod_sum_rec.ARITHMETIC_OPERATOR_TYPE,'z')
     AND NVL(NUMBER_EXPIRATION_PERIODS,-99999) = NVL(l_mod_sum_rec.NUMBER_EXPIRATION_PERIODS,-99999)
     AND NVL(EXPIRATION_PERIOD_UOM,'z') = NVL(l_mod_sum_rec.EXPIRATION_PERIOD_UOM,'z')
     AND NVL(COUP_NUMBER_EXPIRATION_PERIODS,-99999) = NVL(l_mod_sum_rec.COUP_NUMBER_EXPIRATION_PERIODS,-99999)
     AND NVL(COUP_EXPIRATION_PERIOD_UOM,'z') = NVL(l_mod_sum_rec.COUP_EXPIRATION_PERIOD_UOM,'z')
     AND NVL(BRK_NUMBER_EXPIRATION_PERIODS,-99999) = NVL(l_mod_sum_rec.BRK_NUMBER_EXPIRATION_PERIODS,-99999)
     AND NVL(BRK_EXPIRATION_PERIOD_UOM,'z') = NVL(l_mod_sum_rec.BRK_EXPIRATION_PERIOD_UOM,'z')
     AND NVL(REBATE_TRANSACTION_TYPE,'z') = NVL(l_mod_sum_rec.REBATE_TRANSACTION_TYPE,'z')
     AND NVL(BRK_REB_TRANSACTION_TYPE,'z') = NVL(l_mod_sum_rec.BRK_REB_TRANSACTION_TYPE,'z')
     AND NVL(BENEFIT_QTY,-99999) = NVL(l_mod_sum_rec.BENEFIT_QTY,-99999)
     AND NVL(BENEFIT_UOM_CODE,'z') = NVL(l_mod_sum_rec.BENEFIT_UOM_CODE,'z')
     AND NVL(COUP_BENEFIT_QTY,-99999) = NVL(l_mod_sum_rec.COUP_BENEFIT_QTY,-99999)
     AND NVL(COUP_BENEFIT_UOM_CODE,'z') = NVL(l_mod_sum_rec.COUP_BENEFIT_UOM_CODE,'z')
     AND NVL(COUP_LIST_LINE_NO,'z') = NVL(l_mod_sum_rec.COUP_LIST_LINE_NO,'z')
     AND NVL(ACCRUAL_FLAG,'z') = NVL(l_mod_sum_rec.ACCRUAL_FLAG,'z')
     AND NVL(BRK_ACCRUAL_FLAG,'z') = NVL(l_mod_sum_rec.BRK_ACCRUAL_FLAG,'z')
     AND NVL(ACCRUAL_CONVERSION_RATE,-99999) = NVL(l_mod_sum_rec.ACCRUAL_CONVERSION_RATE,-99999)
     AND NVL(COUP_ACCRUAL_CONVERSION_RATE,-99999) = NVL(l_mod_sum_rec.COUP_ACCRUAL_CONVERSION_RATE,-99999)
     AND NVL(COUP_ESTIM_ACCRUAL_RATE,-99999) = NVL(l_mod_sum_rec.COUP_ESTIM_ACCRUAL_RATE,-99999)
     AND NVL(BRK_ACCRUAL_CONVERSION_RATE,-99999) = NVL(l_mod_sum_rec.BRK_ACCRUAL_CONVERSION_RATE,-99999)
     AND NVL(ESTIM_ACCRUAL_RATE,-99999) = NVL(l_mod_sum_rec.ESTIM_ACCRUAL_RATE,-99999)
     AND NVL(BRK_ESTIM_ACCRUAL_RATE,-99999) = NVL(l_mod_sum_rec.BRK_ESTIM_ACCRUAL_RATE,-99999)
     AND NVL(BREAK_LINE_TYPE_CODE,'z') = NVL(l_mod_sum_rec.BREAK_LINE_TYPE_CODE,'z')
     AND NVL(BREAK_LINE_TYPE,'z') = NVL(l_mod_sum_rec.BREAK_LINE_TYPE,'z')
     AND NVL(PRODUCT_ID,'z') = NVL(l_mod_sum_rec.PRODUCT_ID,'z')
     AND NVL(DESCRIPTION,'z') = NVL(l_mod_sum_rec.DESCRIPTION,'z')
     AND NVL(PRICING_ATTR_SEG_NAME,'z') = NVL(l_mod_sum_rec.PRICING_ATTR_SEG_NAME,'z')
     AND NVL(PROD_ATTR_SEGMENT_NAME,'z') = NVL(l_mod_sum_rec.PROD_ATTR_SEGMENT_NAME,'z')
     AND NVL(RELATED_ITEM,'z') = NVL(l_mod_sum_rec.RELATED_ITEM,'z')
     AND NVL(SUBSTITUTION_ATTRIBUTE,'z') = NVL(l_mod_sum_rec.SUBSTITUTION_ATTRIBUTE,'z')
     AND NVL(SUBSTITUTION_VALUE,'z') = NVL(l_mod_sum_rec.SUBSTITUTION_VALUE,'z')
     AND NVL(SUB_SEGMENT_NAME,'z') = NVL(l_mod_sum_rec.SUB_SEGMENT_NAME,'z')
     AND NVL(PRODUCT_ATTRIBUTE_TYPE,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTRIBUTE_TYPE,'z')
     AND NVL(PRODUCT_ATTR_VALUE,'z') = NVL(l_mod_sum_rec.PRODUCT_ATTR_VALUE,'z')
     AND NVL(PRICING_ATTRIBUTE,'z') = NVL(l_mod_sum_rec.PRICING_ATTRIBUTE,'z');
*/
BEGIN

  FOR l_mod_sum_rec IN c_mod_sum LOOP
    FOR l_list_line IN c_list_line_id(l_mod_sum_rec) LOOP
      l_index := l_index + 1;
      l_line_mapping_tbl(l_index).org_line_id := l_mod_sum_rec.list_line_id;
      l_line_mapping_tbl(l_index).new_line_id := l_list_line.list_line_id;
    END LOOP;
  END LOOP;

  RETURN l_line_mapping_tbl;

END get_rltd_line_id;


PROCEDURE copy_discount_line(p_org_line_id    IN  NUMBER
                            ,p_parent_line_id IN  NUMBER
                            ,p_offer_id       IN  NUMBER
                            ,x_new_line_id    OUT NOCOPY NUMBER)
IS
  CURSOR c_new_line_id IS
  SELECT ozf_offer_discount_lines_s.NEXTVAL
    FROM DUAL;

  CURSOR c_line_id_exists(l_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM ozf_offer_discount_lines
                  WHERE offer_discount_line_id = l_id);

  CURSOR c_line_detail IS
  SELECT *
  FROM   ozf_offer_discount_lines
  WHERE  offer_discount_line_id = p_org_line_id;

  l_line_detail c_line_detail%ROWTYPE;
  l_count NUMBER;
BEGIN
  LOOP
    l_count := NULL;

    OPEN  c_new_line_id;
    FETCH c_new_line_id INTO x_new_line_id;
    CLOSE c_new_line_id;

    OPEN  c_line_id_exists(x_new_line_id);
    FETCH c_line_id_exists INTO l_count;
    CLOSE c_line_id_exists;

    EXIT WHEN l_count IS NULL;
  END LOOP;

  OPEN  c_line_detail;
  FETCH c_line_detail INTO l_line_detail;
  CLOSE c_line_detail;

  INSERT INTO ozf_offer_discount_lines(offer_discount_line_id
                                      ,parent_discount_line_id
                                      ,volume_from
                                      ,volume_to
                                      ,volume_operator
                                      ,volume_type
                                      ,volume_break_type
                                      ,discount
                                      ,discount_type
                                      ,tier_type
                                      ,tier_level
                                      ,incompatibility_group
                                      ,precedence
                                      ,bucket
                                      ,scan_value
                                      ,scan_data_quantity
                                      ,scan_unit_forecast
                                      ,channel_id
                                      ,adjustment_flag
                                      ,start_date_active
                                      ,end_date_active
                                      ,uom_code
                                      ,creation_date
                                      ,created_by
                                      ,last_update_date
                                      ,last_updated_by
                                      ,last_update_login
                                      ,object_version_number
                                      ,offer_id)
                                VALUES(x_new_line_id
                                      ,p_parent_line_id
                                      ,l_line_detail.volume_from
                                      ,l_line_detail.volume_to
                                      ,l_line_detail.volume_operator
                                      ,l_line_detail.volume_type
                                      ,l_line_detail.volume_break_type
                                      ,l_line_detail.discount
                                      ,l_line_detail.discount_type
                                      ,l_line_detail.tier_type
                                      ,l_line_detail.tier_level
                                      ,l_line_detail.incompatibility_group
                                      ,l_line_detail.precedence
                                      ,l_line_detail.bucket
                                      ,l_line_detail.scan_value
                                      ,l_line_detail.scan_data_quantity
                                      ,l_line_detail.scan_unit_forecast
                                      ,l_line_detail.channel_id
                                      ,l_line_detail.adjustment_flag
                                      ,l_line_detail.start_date_active
                                      ,l_line_detail.end_date_active
                                      ,l_line_detail.uom_code
                                      ,SYSDATE
                                      ,FND_GLOBAL.user_id
                                      ,SYSDATE
                                      ,FND_GLOBAL.user_id
                                      ,FND_GLOBAL.conc_login_id
                                      ,1
                                      ,p_offer_id);
END copy_discount_line;


PROCEDURE copy_discount_prod(p_org_prod_id    IN  NUMBER
                            ,p_parent_prod_id IN  NUMBER
                            ,p_offer_id       IN  NUMBER
                            ,p_new_line_id    IN  NUMBER
                            ,x_new_prod_id    OUT NOCOPY NUMBER)
IS
  CURSOR c_new_prod_id IS
  SELECT ozf_offer_discount_products_s.NEXTVAL
    FROM DUAL;

  CURSOR c_prod_id_exists(l_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT 1
                   FROM ozf_offer_discount_products
                  WHERE off_discount_product_id = l_id);

  CURSOR c_product_detail IS
  SELECT *
  FROM   ozf_offer_discount_products
  WHERE  off_discount_product_id = p_org_prod_id;

  l_product_detail c_product_detail%ROWTYPE;
  l_count NUMBER;
BEGIN
  LOOP
    l_count := NULL;

    OPEN  c_new_prod_id;
    FETCH c_new_prod_id INTO x_new_prod_id;
    CLOSE c_new_prod_id;

    OPEN  c_prod_id_exists(x_new_prod_id);
    FETCH c_prod_id_exists INTO l_count;
    CLOSE c_prod_id_exists;

    EXIT WHEN l_count IS NULL;
  END LOOP;

  OPEN  c_product_detail;
  FETCH c_product_detail INTO l_product_detail;
  CLOSE c_product_detail;

  INSERT INTO ozf_offer_discount_products(off_discount_product_id
                                         ,product_level
                                         ,product_id
                                         ,excluder_flag
                                         ,uom_code
                                         ,start_date_active
                                         ,end_date_active
                                         ,offer_discount_line_id
                                         ,offer_id
                                         ,creation_date
                                         ,created_by
                                         ,last_update_date
                                         ,last_updated_by
                                         ,last_update_login
                                         ,object_version_number
                                         ,parent_off_disc_prod_id)
                                   VALUES(x_new_prod_id
                                         ,l_product_detail.product_level
                                         ,l_product_detail.product_id
                                         ,l_product_detail.excluder_flag
                                         ,l_product_detail.uom_code
                                         ,l_product_detail.start_date_active
                                         ,l_product_detail.end_date_active
                                         ,p_new_line_id
                                         ,p_offer_id
                                         ,SYSDATE
                                         ,FND_GLOBAL.user_id
                                         ,SYSDATE
                                         ,FND_GLOBAL.user_id
                                         ,FND_GLOBAL.conc_login_id
                                         ,1
                                         ,p_parent_prod_id);
END copy_discount_prod;


PROCEDURE copy_na_line_offer(p_source_object_id IN NUMBER
                            ,p_new_offer_id     IN NUMBER)
IS
  CURSOR c_parent_lines IS
  SELECT offer_discount_line_id
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id)
  AND    parent_discount_line_id IS NULL; -- start from main line, then process multi-tier and excl

  CURSOR c_tier_excl_lines(p_parent_line_id NUMBER) IS
  SELECT offer_discount_line_id
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id)
  AND    parent_discount_line_id = p_parent_line_id;

  CURSOR c_product_id(p_line_id NUMBER) IS
  SELECT off_discount_product_id
  FROM   ozf_offer_discount_products
  WHERE  offer_discount_line_id = p_line_id;

  l_new_line_id NUMBER;
  l_product_id  NUMBER;
  l_dummy       NUMBER;
BEGIN
  FOR l_parent_line IN c_parent_lines LOOP
    copy_discount_line(p_org_line_id    => l_parent_line.offer_discount_line_id
                      ,p_parent_line_id => NULL
                      ,p_offer_id       => p_new_offer_id
                      ,x_new_line_id    => l_new_line_id); -- new line_id. will be used for prod, tier, and excl

    OPEN  c_product_id(l_parent_line.offer_discount_line_id);
    FETCH c_product_id INTO l_product_id;
    CLOSE c_product_id;

    copy_discount_prod(p_org_prod_id    => l_product_id
                      ,p_parent_prod_id => NULL
                      ,p_offer_id       => p_new_offer_id
                      ,p_new_line_id    => l_new_line_id
                      ,x_new_prod_id    => l_dummy);

    FOR l_tier_excl_line IN c_tier_excl_lines(l_parent_line.offer_discount_line_id) LOOP
      copy_discount_line(p_org_line_id    => l_tier_excl_line.offer_discount_line_id
                        ,p_parent_line_id => l_new_line_id
                        ,p_offer_id       => p_new_offer_id
                        ,x_new_line_id    => l_dummy);

    END LOOP;
  END LOOP;
END copy_na_line_offer;


PROCEDURE copy_na_header_offer(p_source_object_id IN NUMBER
                              ,p_new_offer_id     IN NUMBER)
IS
  CURSOR c_line_tiers IS
  SELECT offer_discount_line_id
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id);

  CURSOR c_parent_products IS
  SELECT off_discount_product_id
  FROM   ozf_offer_discount_products
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id)
  AND    parent_off_disc_prod_id IS NULL;

  CURSOR c_excl_products(p_parent_prod_id NUMBER) IS
  SELECT off_discount_product_id
  FROM   ozf_offer_discount_products
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id)
  AND    parent_off_disc_prod_id = p_parent_prod_id;

  l_new_prod_id NUMBER;
  l_dummy       NUMBER;
BEGIN
  FOR l_line_tier IN c_line_tiers LOOP
    copy_discount_line(p_org_line_id    => l_line_tier.offer_discount_line_id
                      ,p_parent_line_id => NULL
                      ,p_offer_id       => p_new_offer_id
                      ,x_new_line_id    => l_dummy);
  END LOOP;

  FOR l_parent_product IN c_parent_products LOOP
    copy_discount_prod(p_org_prod_id    => l_parent_product.off_discount_product_id
                      ,p_parent_prod_id => NULL
                      ,p_offer_id       => p_new_offer_id
                      ,p_new_line_id    => -1
                      ,x_new_prod_id    => l_new_prod_id);

    FOR l_excl_prod IN c_excl_products(l_parent_product.off_discount_product_id) LOOP
      copy_discount_prod(p_org_prod_id    => l_excl_prod.off_discount_product_id
                        ,p_parent_prod_id => l_new_prod_id
                        ,p_offer_id       => p_new_offer_id
                        ,p_new_line_id    => -1
                        ,x_new_prod_id    => l_dummy);
    END LOOP;
  END LOOP;
END copy_na_header_offer;


PROCEDURE copy_na_market_elig(p_source_object_id IN NUMBER
                             ,p_new_offer_id     IN NUMBER)
IS
  CURSOR c_new_qual_id IS
  SELECT ozf_offer_qualifiers_s.NEXTVAL
    FROM DUAL;

  CURSOR c_qual_id_exists(l_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT 1
                   FROM ozf_offer_qualifiers
                  WHERE qualifier_id = l_id);

  CURSOR c_market_elig IS
  SELECT *
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = (SELECT offer_id
                     FROM   ozf_offers
                     WHERE  qp_list_header_id = p_source_object_id);

  l_new_qual_id NUMBER;
  l_count       NUMBER;
BEGIN
  LOOP
    l_count := NULL;

    OPEN  c_new_qual_id;
    FETCH c_new_qual_id INTO l_new_qual_id;
    CLOSE c_new_qual_id;

    OPEN  c_qual_id_exists(l_new_qual_id);
    FETCH c_qual_id_exists INTO l_count;
    CLOSE c_qual_id_exists;

    EXIT WHEN l_count IS NULL;
  END LOOP;

  FOR l_market_elig IN c_market_elig LOOP
    INSERT INTO ozf_offer_qualifiers(qualifier_id
                                    ,creation_date
                                    ,created_by
                                    ,last_update_date
                                    ,last_updated_by
                                    ,last_update_login
                                    ,qualifier_grouping_no
                                    ,qualifier_context
                                    ,qualifier_attribute
                                    ,qualifier_attr_value
                                    ,start_date_active
                                    ,end_date_active
                                    ,offer_id
                                    ,offer_discount_line_id
                                    ,context
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
                                    ,active_flag
                                    ,object_version_number)
                              VALUES(l_new_qual_id
                                    ,SYSDATE
                                    ,FND_GLOBAL.user_id
                                    ,SYSDATE
                                    ,FND_GLOBAL.user_id
                                    ,FND_GLOBAL.conc_login_id
                                    ,l_market_elig.qualifier_grouping_no
                                    ,l_market_elig.qualifier_context
                                    ,l_market_elig.qualifier_attribute
                                    ,l_market_elig.qualifier_attr_value
                                    ,l_market_elig.start_date_active
                                    ,l_market_elig.end_date_active
                                    ,p_new_offer_id
                                    ,NULL
                                    ,l_market_elig.context
                                    ,l_market_elig.attribute1
                                    ,l_market_elig.attribute2
                                    ,l_market_elig.attribute3
                                    ,l_market_elig.attribute4
                                    ,l_market_elig.attribute5
                                    ,l_market_elig.attribute6
                                    ,l_market_elig.attribute7
                                    ,l_market_elig.attribute8
                                    ,l_market_elig.attribute9
                                    ,l_market_elig.attribute10
                                    ,l_market_elig.attribute11
                                    ,l_market_elig.attribute12
                                    ,l_market_elig.attribute13
                                    ,l_market_elig.attribute14
                                    ,l_market_elig.attribute15
                                    ,l_market_elig.active_flag
                                    ,1);
  END LOOP;
END copy_na_market_elig;




PROCEDURE copy_offer_detail(
                     p_api_version        IN  NUMBER,
                     p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
                     p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     x_return_status      OUT NOCOPY VARCHAR2,
                     x_msg_count          OUT NOCOPY NUMBER,
                     x_msg_data           OUT NOCOPY VARCHAR2,
                     p_source_object_id   IN  NUMBER,
                     p_attributes_table   IN  AMS_CpyUtility_PVT.copy_attributes_table_type,
                     p_copy_columns_table IN  AMS_CpyUtility_PVT.copy_columns_table_type,
                     x_new_object_id      OUT NOCOPY NUMBER,
                     p_custom_setup_id    IN  NUMBER)
IS

  l_api_name                  CONSTANT VARCHAR2(30) := 'copy_offer_detail';
  l_api_version_number        CONSTANT NUMBER   := 1.0;
  l_src_list_header_id        NUMBER;
  l_new_list_header_id        NUMBER;
  l_index1                    NUMBER := 0;
  l_index2                    NUMBER := 0;
  l_modifier_list_rec         ozf_offer_pvt.modifier_list_rec_type;

  l_return_status             VARCHAR2(1);

  l_errnum	                  NUMBER;
  l_errcode                   VARCHAR2(80);
  l_errmsg                    VARCHAR2(3000);
  l_error_location            NUMBER;

  l_dummy                     NUMBER;
  l_errbuf                    VARCHAR2(3000);
  l_retcode                   NUMBER;
  l_count_ozf_code            NUMBER;
  l_count_qp_code             NUMBER;
  l_code_is_unique            VARCHAR2(1);
  l_new_offer_id              NUMBER;
  l_new_limit_id              NUMBER;
  l_new_limit_line_id         NUMBER;
  l_new_qual_id               NUMBER;
  l_new_qual_line_id          NUMBER;
  l_line_mapping_tbl          line_mapping_tbl_type;
  l_limit_mapping_tbl         line_mapping_tbl_type;
  l_qual_mapping_tbl          line_mapping_tbl_type;
  l_new_modifier_id           NUMBER;
  l_new_rltd_modifier_id      NUMBER;
  l_related_lines_rec         ozf_related_lines_pvt.related_lines_rec_type;
  l_related_deal_lines_id     NUMBER;
  l_act_product_id            NUMBER;
  l_temp_id                   NUMBER;
  l_prev_line_id              NUMBER;
  l_default_team              NUMBER;

  CURSOR c_list_header_detail IS
  SELECT *
    FROM qp_list_headers
   WHERE list_header_id = p_source_object_id;
  l_list_header_rec c_list_header_detail%ROWTYPE;

  CURSOR c_offer_detail IS
  SELECT *
    FROM ozf_offers
   WHERE qp_list_header_id = p_source_object_id;
  l_offer_rec c_offer_detail%ROWTYPE;

  CURSOR c_count_ozf_code(l_code VARCHAR2) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM ozf_offers
                  WHERE offer_code = l_code);

  CURSOR c_count_qp_code(l_code VARCHAR2) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_list_headers
                  WHERE name = l_code);

  CURSOR c_get_list_header_id(l_name VARCHAR2) IS
  SELECT list_header_id
    FROM qp_list_headers
   WHERE name = l_name;

  CURSOR c_new_offer_id IS
  SELECT ozf_offers_s.NEXTVAL
    FROM DUAL;

  CURSOR c_offer_id_exists (l_id IN NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM ozf_offers
                  WHERE offer_id = l_id);

  CURSOR c_new_limit_id IS
  SELECT qp_limits_s.NEXTVAL
    FROM DUAL;

  CURSOR c_limit_id_exists (l_id IN NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_limits
                  WHERE limit_id = l_id);

  CURSOR c_related_deal_lines IS
  SELECT *
    FROM ozf_related_deal_lines
   WHERE qp_list_header_id = p_source_object_id;

  CURSOR c_vol_offer_tiers IS
  SELECT *
    FROM ozf_volume_offer_tiers
   WHERE qp_list_header_id = p_source_object_id;
  l_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;

  CURSOR c_act_products IS
  SELECT *
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_source_object_id;
  l_act_product_rec ams_actproduct_pvt.act_product_rec_type;

  CURSOR c_excluded_products(l_act_prod_id NUMBER) IS
  SELECT *
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'PROD'
     AND act_product_used_by_id = l_act_prod_id;

  CURSOR c_offer_lines IS
  SELECT list_line_id
    FROM qp_list_lines
   WHERE list_header_id = p_source_object_id;

  CURSOR c_line_limits IS
  SELECT *
    FROM qp_limits
   WHERE list_header_id = p_source_object_id
   ORDER BY list_line_id;

  CURSOR c_contact_point IS
  SELECT *
    FROM ams_act_contact_points
   WHERE arc_contact_used_by = 'OFFR'
     AND act_contact_used_by_id = p_source_object_id;
  l_contact_point_rec ams_cnt_point_pvt.cnt_point_rec_type;

  CURSOR c_market_elig IS
  SELECT qualifier_context
        ,qualifier_attribute
        ,qualifier_attr_value
        ,qualifier_attr_value_to
        ,comparison_operator_code
        ,qualifier_grouping_no
        ,list_line_id
        ,list_header_id
        ,start_date_active
        ,end_date_active
    FROM qp_qualifiers
   WHERE list_header_id = p_source_object_id;
  l_qualifier_tbl ozf_offer_pvt.qualifiers_tbl_type;

  CURSOR c_adv_options IS
  SELECT modifier_level_code
        ,pricing_phase_id
        ,incompatibility_grp_code
        ,product_precedence
        ,pricing_group_sequence
        ,print_on_invoice_flag
    FROM qp_list_lines
   WHERE list_header_id = p_source_object_id;
  l_adv_options_rec Ozf_Offer_Pvt.Advanced_Option_Rec_Type;

  -- bug 3747303
  CURSOR c_vol_off_discount IS
  SELECT discount_type_code, discount
  FROM   ozf_volume_offer_tiers
  WHERE  qp_list_header_id = p_source_object_id
  AND    tier_value_from =
         (SELECT MIN(tier_value_from)
          FROM   ozf_volume_offer_tiers
          WHERE  qp_list_header_id = p_source_object_id);
  l_discount_type VARCHAR2(30);
  l_discount      NUMBER;
  l_offer_id NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT copy_offer_detail;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_offer_detail;
  FETCH c_offer_detail INTO l_offer_rec;
  CLOSE c_offer_detail;

  l_offer_rec.custom_setup_id := p_custom_setup_id;

  -- getting values from UI
  AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_modifier_list_rec.description);
  AMS_CpyUtility_PVT.get_column_value ('offerCode', p_copy_columns_table, l_offer_rec.offer_code);
  --AMS_CpyUtility_PVT.get_column_value ('offerCode', p_copy_columns_table, l_modifier_list_rec.name);
  AMS_CpyUtility_PVT.get_column_value ('startDateActive', p_copy_columns_table, l_modifier_list_rec.start_date_active);
  AMS_CpyUtility_PVT.get_column_value ('endDateActive', p_copy_columns_table, l_modifier_list_rec.end_date_active);
  AMS_CpyUtility_PVT.get_column_value ('ownerId', p_copy_columns_table, l_offer_rec.owner_id);
  AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_modifier_list_rec.comments);

  -- bug fix 2779988: validate start date and end date
  IF l_modifier_list_rec.start_date_active IS NOT NULL
  AND l_modifier_list_rec.start_date_active <> FND_API.G_MISS_DATE THEN
    IF l_modifier_list_rec.start_date_active < TRUNC(SYSDATE) AND l_offer_rec.offer_type <> 'NET_ACCRUAL' THEN
      Fnd_Message.SET_NAME('OZF','OZF_OFFR_STARTDATE_LT_SYSDATE');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- end validation start date if

  IF l_modifier_list_rec.end_date_active IS NOT NULL
  AND l_modifier_list_rec.end_date_active <> FND_API.G_MISS_DATE THEN
    IF l_modifier_list_rec.end_date_active < TRUNC(SYSDATE) AND l_offer_rec.offer_type <> 'NET_ACCRUAL' THEN
      Fnd_Message.SET_NAME('OZF','OZF_OFFR_ENDDATE_LT_SYSDATE');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- end end date validation if

  IF l_offer_rec.offer_type IN ('SCAN_DATA', 'NET_ACCRUAL') OR (l_offer_rec.offer_type = 'LUMPSUM' AND l_offer_rec.custom_setup_id <> 110) THEN -- not applicable to soft fund
    IF l_modifier_list_rec.start_date_active IS NULL THEN
      ozf_utility_pvt.error_message('OZF_OFFR_NO_START_DATE');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- end scan data lumpsum start date validation if

  IF l_modifier_list_rec.start_date_active IS NOT NULL
  AND l_modifier_list_rec.start_date_active <> FND_API.G_MISS_DATE
  AND l_modifier_list_rec.end_date_active IS NOT NULL
  AND l_modifier_list_rec.end_date_active <> FND_API.G_MISS_DATE
  THEN
    IF l_modifier_list_rec.start_date_active > l_modifier_list_rec.end_date_active THEN
      Fnd_Message.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- end start date before end date validation

  -- validate source code
  IF l_offer_rec.offer_code IS NULL OR l_offer_rec.offer_code = FND_API.G_MISS_CHAR THEN
    LOOP
      l_count_ozf_code := 0;
      l_count_qp_code := 0;

      l_offer_rec.offer_code := Ams_Sourcecode_Pvt.get_new_source_code (
                   p_object_type => 'OFFR',
                   p_custsetup_id => l_offer_rec.custom_setup_id,
                   p_global_flag   => Fnd_Api.g_false
               );

      OPEN c_count_ozf_code(l_offer_rec.offer_code);
      FETCH c_count_ozf_code INTO l_count_ozf_code;
      CLOSE c_count_ozf_code;

      OPEN c_count_qp_code(l_offer_rec.offer_code);
      FETCH c_count_qp_code INTO l_count_qp_code;
      CLOSE c_count_qp_code;

      IF l_count_ozf_code = 0 AND l_count_qp_code = 0 THEN
        l_code_is_unique := 'Y';
      ELSE
        l_code_is_unique := 'N';
      END IF;

      EXIT WHEN l_code_is_unique = 'Y';
    END LOOP;
  ELSE
    OPEN c_count_ozf_code(l_offer_rec.offer_code);
    FETCH c_count_ozf_code INTO l_count_ozf_code;
    CLOSE c_count_ozf_code;

    OPEN c_count_qp_code(l_offer_rec.offer_code);
    FETCH c_count_qp_code INTO l_count_qp_code;
    CLOSE c_count_qp_code;

    IF l_count_ozf_code > 0 OR l_count_qp_code > 0 THEN
      ozf_utility_pvt.error_message('OZF_OFFR_COPY_DUP_CODE');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;   -- end validate source code

  IF l_offer_rec.offer_type  <> 'VOLUME_OFFER' THEN
    OPEN c_list_header_detail;
    FETCH c_list_header_detail INTO l_list_header_rec;
    CLOSE c_list_header_detail;
    -- copy header and lines, limits and related lines not copied yet

QP_COPY_MODIFIERS_PVT.Copy_Discounts
(
 errbuf                     => l_errbuf
 , retcode                  => l_retcode
 , p_from_list_header_id    => p_source_object_id
 , p_new_price_list_name    => l_offer_rec.offer_code
 , p_description            => l_modifier_list_rec.description
 , p_start_date_active      => fnd_date.date_to_canonical(l_modifier_list_rec.start_date_active)
 , p_end_date_active        => fnd_date.date_to_canonical(l_modifier_list_rec.end_date_active)
 , p_rounding_factor        => NULL
 , p_effective_dates_flag   => 'N'
--added for moac bug 4673872
 , p_global_flag            => l_list_header_rec.global_flag
 , p_org_id                 => l_list_header_rec.orig_org_id
);

    -- get new header id
    OPEN c_get_list_header_id(l_offer_rec.offer_code);
    FETCH c_get_list_header_id INTO l_offer_rec.qp_list_header_id;
    CLOSE c_get_list_header_id;
--14-Jan-2003  JULOU Copy did not put the new description from the UI
-- put description from UI
    UPDATE qp_list_headers_b
    SET comments = l_modifier_list_rec.comments
    WHERE list_header_id = l_offer_rec.qp_list_header_id;

    -- insert into ozf_offers
    LOOP
      l_dummy := NULL;
      OPEN c_new_offer_id;
      FETCH c_new_offer_id INTO l_offer_rec.offer_id;
      CLOSE c_new_offer_id;

      OPEN c_offer_id_exists(l_offer_rec.offer_id);
      FETCH c_offer_id_exists INTO l_dummy;
      CLOSE c_offer_id_exists;
      EXIT WHEN l_dummy IS NULL;
	  END LOOP;



    INSERT INTO ozf_offers
    (offer_id
    ,qp_list_header_id
    ,offer_type
    ,offer_code
    ,reusable
    ,custom_setup_id
    ,user_status_id
    ,owner_id
    ,object_version_number
    ,customer_reference
    ,buying_group_contact_id
    ,perf_date_from
    ,perf_date_to
    ,status_code
    ,order_value_discount_type
    ,modifier_level_code
    ,offer_amount
    ,lumpsum_amount
    ,lumpsum_payment_type
    ,security_group_id
    ,distribution_type
    ,budget_amount_fc
    ,budget_amount_tc
    ,transaction_currency_code
    ,functional_currency_code
    ,account_closed_flag
    ,activity_media_id
    ,qualifier_id
    ,qualifier_type
    ,budget_offer_yn
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,qualifier_deleted
    ,break_type
    ,volume_offer_type
    ,confidential_flag
    ,budget_source_type
    ,budget_source_id
    ,retroactive
    ,source_from_parent
    ,last_recal_date
    ,buyer_name
    ,tier_level
    ,na_rule_header_id
    ,autopay_flag
    ,autopay_days
    ,autopay_method
    ,autopay_party_attr
    ,autopay_party_id
    ,beneficiary_account_id
    ,sales_method_flag
    ,org_id
    ,fund_request_curr_code)
    VALUES
    (l_offer_rec.offer_id
    ,l_offer_rec.qp_list_header_id
    ,l_offer_rec.offer_type
    ,l_offer_rec.offer_code
    ,l_offer_rec.reusable
    ,l_offer_rec.custom_setup_id
    ,ozf_utility_pvt.get_default_user_status('OZF_OFFER_STATUS','DRAFT')
    ,l_offer_rec.owner_id
    ,1
    ,l_offer_rec.customer_reference
    ,l_offer_rec.buying_group_contact_id
    ,l_offer_rec.perf_date_from
    ,l_offer_rec.perf_date_to
    ,'DRAFT'
    ,l_offer_rec.order_value_discount_type
    ,l_offer_rec.modifier_level_code
    ,l_offer_rec.offer_amount
    ,l_offer_rec.lumpsum_amount
    ,l_offer_rec.lumpsum_payment_type
    ,l_offer_rec.security_group_id
    ,l_offer_rec.distribution_type
    ,l_offer_rec.budget_amount_fc
    ,l_offer_rec.budget_amount_tc
    ,l_offer_rec.transaction_currency_code
    ,l_offer_rec.functional_currency_code
    ,'N'
    ,l_offer_rec.activity_media_id
    ,l_offer_rec.qualifier_id
    ,l_offer_rec.qualifier_type
    ,DECODE(l_offer_rec.custom_setup_id, 101, 'Y', 108, 'Y', 'N')--l_offer_rec.budget_offer_yn
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.conc_login_id
    ,NULL
    ,l_offer_rec.break_type
    ,l_offer_rec.volume_offer_type
    ,l_offer_rec.confidential_flag
    ,l_offer_rec.budget_source_type
    ,l_offer_rec.budget_source_id
    ,l_offer_rec.retroactive
    ,l_offer_rec.source_from_parent
    ,l_modifier_list_rec.start_date_active -- default last_recal_date to offer start date
    ,l_offer_rec.buyer_name
    ,l_offer_rec.tier_level
    ,l_offer_rec.na_rule_header_id
    ,l_offer_rec.autopay_flag
    ,l_offer_rec.autopay_days
    ,l_offer_rec.autopay_method
    ,l_offer_rec.autopay_party_attr
    ,l_offer_rec.autopay_party_id
    ,l_offer_rec.beneficiary_account_id
    ,l_offer_rec.sales_method_flag
    ,l_offer_rec.org_id
    ,NVL(l_offer_rec.transaction_currency_code, fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY')));
    -- end insert into ozf_offers

    --7627663,insert the offer details to AMS_SOURCE_CODES for all offers except volume offer.
      AMS_CampaignRules_PVT.push_source_code(
         l_offer_rec.offer_code,
         'OFFR',
         l_offer_rec.qp_list_header_id
       );


    -- create access for new offer owner
    INSERT INTO ams_act_access
    (activity_access_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,act_access_to_object_id
    ,arc_act_access_to_object
    ,user_or_role_id
    ,arc_user_or_role_type
    ,last_update_login
    ,object_version_number
    ,active_from_date
    ,admin_flag
    ,approver_flag
    ,active_to_date
    ,security_group_id
    ,delete_flag
    ,owner_flag)
    VALUES
    (ams_act_access_s.NEXTVAL
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,l_offer_rec.qp_list_header_id
    ,'OFFR'
    ,l_offer_rec.owner_id
    ,'USER'
    ,FND_GLOBAL.conc_login_id
    ,1
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,'N'
    ,'Y');
    -- end create access for owner

    -- create access in ams_act_access_denorm for new offer owner
    INSERT INTO ams_act_access_denorm
    (access_denorm_id
    ,object_type
    ,object_id
    ,resource_id
    ,edit_metrics_yn
    ,source_code
    ,access_type
    ,creation_date
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by)
    VALUES
    (ams_act_access_denorm_s.NEXTVAL
    ,'OFFR'
    ,l_offer_rec.qp_list_header_id
    ,l_offer_rec.owner_id
    ,'Y'
    ,l_offer_rec.offer_code
    ,NULL
    ,SYSDATE
    ,SYSDATE
    ,FND_GLOBAL.conc_login_id
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.user_id);
    -- end create access in ams_act_access_denorm

    -- create access for default team
    l_default_team := FND_PROFILE.value('OZF_DEFAULT_OFFER_TEAM');
    IF l_default_team IS NOT NULL AND l_default_team <> FND_API.G_MISS_NUM THEN
      INSERT INTO ams_act_access
      (activity_access_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,act_access_to_object_id
      ,arc_act_access_to_object
      ,user_or_role_id
      ,arc_user_or_role_type
      ,last_update_login
      ,object_version_number
      ,active_from_date
      ,admin_flag
      ,approver_flag
      ,active_to_date
      ,security_group_id
      ,delete_flag
      ,owner_flag)
      VALUES
      (ams_act_access_s.NEXTVAL
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,l_offer_rec.qp_list_header_id
      ,'OFFR'
      ,l_default_team
      ,'GROUP'
      ,FND_GLOBAL.conc_login_id
      ,1
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,'N'
      ,'N');
    END IF;
    -- end create default access for default team

    -- copy NET_ACCRUAL offer
    IF l_offer_rec.offer_type = 'NET_ACCRUAL' THEN
      IF l_offer_rec.tier_level = 'LINE' THEN -- line based discount
        copy_na_line_offer(p_source_object_id => p_source_object_id
                          ,p_new_offer_id     => l_offer_rec.offer_id);
      ELSIF l_offer_rec.tier_level = 'HEADER' THEN-- tier based discount
        copy_na_header_offer(p_source_object_id => p_source_object_id
                            ,p_new_offer_id     => l_offer_rec.offer_id);
      END IF;
    END IF;

    -- build list line id mapping table
    l_line_mapping_tbl := get_rltd_line_id(p_source_object_id, l_offer_rec.qp_list_header_id);
    l_limit_mapping_tbl := get_rltd_line_id(p_source_object_id, l_offer_rec.qp_list_header_id);
    -- end build mapping table

    -- process limits
    FOR l_line_limits IN c_line_limits LOOP
      IF l_line_limits.list_line_id = -1 THEN
        LOOP
          --l_new_limit_id := NULL;
          l_dummy := NULL;
          OPEN c_new_limit_id;
          FETCH c_new_limit_id INTO l_new_limit_id;
          CLOSE c_new_limit_id;

          OPEN c_limit_id_exists(l_new_limit_id);
          FETCH c_limit_id_exists INTO l_dummy;
          CLOSE c_limit_id_exists;
          EXIT WHEN l_dummy IS NULL;
        END LOOP;

        INSERT INTO qp_limits
        (limit_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,program_application_id
        ,program_id
        ,program_update_date
        ,request_id
        ,list_header_id
        ,list_line_id
        ,limit_number
        ,basis
        ,organization_flag
        ,limit_level_code
        ,limit_exceed_action_code
        ,limit_hold_flag
        ,multival_attr1_type
        ,multival_attr1_context
        ,multival_attribute1
        ,multival_attr1_datatype
        ,multival_attr2_type
        ,multival_attr2_context
        ,multival_attribute2
        ,multival_attr2_datatype
        ,amount
        ,context
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
        ,each_attr_exists
        ,non_each_attr_count
        ,total_attr_count)
        VALUES
        (l_new_limit_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,l_line_limits.program_application_id
        ,l_line_limits.program_id
        ,SYSDATE
        ,NULL
        ,l_offer_rec.qp_list_header_id
        ,-1
        ,l_line_limits.limit_number
        ,l_line_limits.basis
        ,l_line_limits.organization_flag
        ,l_line_limits.limit_level_code
        ,l_line_limits.limit_exceed_action_code
        ,l_line_limits.limit_hold_flag
        ,l_line_limits.multival_attr1_type
        ,l_line_limits.multival_attr1_context
        ,l_line_limits.multival_attribute1
        ,l_line_limits.multival_attr1_datatype
        ,l_line_limits.multival_attr2_type
        ,l_line_limits.multival_attr2_context
        ,l_line_limits.multival_attribute2
        ,l_line_limits.multival_attr2_datatype
        ,l_line_limits.amount
        ,l_line_limits.context
        ,l_line_limits.attribute1
        ,l_line_limits.attribute2
        ,l_line_limits.attribute3
        ,l_line_limits.attribute4
        ,l_line_limits.attribute5
        ,l_line_limits.attribute6
        ,l_line_limits.attribute7
        ,l_line_limits.attribute8
        ,l_line_limits.attribute9
        ,l_line_limits.attribute10
        ,l_line_limits.attribute11
        ,l_line_limits.attribute12
        ,l_line_limits.attribute13
        ,l_line_limits.attribute14
        ,l_line_limits.attribute15
        ,l_line_limits.each_attr_exists
        ,l_line_limits.non_each_attr_count
        ,l_line_limits.total_attr_count);
      ELSE
        IF l_prev_line_id <> l_line_limits.list_line_id THEN
          -- remove assigned source line id from mapping tablel
          FOR i IN 1..l_limit_mapping_tbl.count LOOP
            IF l_new_limit_line_id = l_limit_mapping_tbl(i).new_line_id THEN
              l_limit_mapping_tbl(i) := NULL;
            END IF;
          END LOOP;
        END IF;

        l_new_limit_line_id := NULL;

        FOR i IN 1..l_limit_mapping_tbl.count LOOP
          IF l_line_limits.list_line_id = l_limit_mapping_tbl(i).org_line_id THEN
            l_new_limit_line_id := l_limit_mapping_tbl(i).new_line_id;
            -- find matching line, populate limits
            LOOP
              --l_new_limit_id := NULL;
              l_dummy := NULL;
              OPEN c_new_limit_id;
              FETCH c_new_limit_id INTO l_new_limit_id;
              CLOSE c_new_limit_id;

              OPEN c_limit_id_exists(l_new_limit_id);
              FETCH c_limit_id_exists INTO l_dummy;
              CLOSE c_limit_id_exists;
              EXIT WHEN l_dummy IS NULL;
            END LOOP;

            INSERT INTO qp_limits
            (limit_id
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,program_application_id
            ,program_id
            ,program_update_date
            ,request_id
            ,list_header_id
            ,list_line_id
            ,limit_number
            ,basis
            ,organization_flag
            ,limit_level_code
            ,limit_exceed_action_code
            ,limit_hold_flag
            ,multival_attr1_type
            ,multival_attr1_context
            ,multival_attribute1
            ,multival_attr1_datatype
            ,multival_attr2_type
            ,multival_attr2_context
            ,multival_attribute2
            ,multival_attr2_datatype
            ,amount
            ,context
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
            ,each_attr_exists
            ,non_each_attr_count
            ,total_attr_count)
            VALUES
            (l_new_limit_id
            ,SYSDATE
            ,FND_GLOBAL.user_id
            ,SYSDATE
            ,FND_GLOBAL.user_id
            ,FND_GLOBAL.conc_login_id
            ,l_line_limits.program_application_id
            ,l_line_limits.program_id
            ,SYSDATE
            ,NULL
            ,l_offer_rec.qp_list_header_id
            ,l_new_limit_line_id
            ,l_line_limits.limit_number
            ,l_line_limits.basis
            ,l_line_limits.organization_flag
            ,l_line_limits.limit_level_code
            ,l_line_limits.limit_exceed_action_code
            ,l_line_limits.limit_hold_flag
            ,l_line_limits.multival_attr1_type
            ,l_line_limits.multival_attr1_context
            ,l_line_limits.multival_attribute1
            ,l_line_limits.multival_attr1_datatype
            ,l_line_limits.multival_attr2_type
            ,l_line_limits.multival_attr2_context
            ,l_line_limits.multival_attribute2
            ,l_line_limits.multival_attr2_datatype
            ,l_line_limits.amount
            ,l_line_limits.context
            ,l_line_limits.attribute1
            ,l_line_limits.attribute2
            ,l_line_limits.attribute3
            ,l_line_limits.attribute4
            ,l_line_limits.attribute5
            ,l_line_limits.attribute6
            ,l_line_limits.attribute7
            ,l_line_limits.attribute8
            ,l_line_limits.attribute9
            ,l_line_limits.attribute10
            ,l_line_limits.attribute11
            ,l_line_limits.attribute12
            ,l_line_limits.attribute13
            ,l_line_limits.attribute14
            ,l_line_limits.attribute15
            ,l_line_limits.each_attr_exists
            ,l_line_limits.non_each_attr_count
            ,l_line_limits.total_attr_count);
            EXIT;
          END IF;
        END LOOP;
      END IF;
      l_prev_line_id := l_line_limits.list_line_id;
    END LOOP;
    -- end processing limits

    IF l_offer_rec.offer_type = 'DEAL' THEN
      -- process related lines for trade deal offers
      FOR l_related_deal_line IN c_related_deal_lines LOOP
        l_new_modifier_id := NULL;
        l_new_rltd_modifier_id := NULL;

        -- get new source line id
        FOR i IN 1..l_line_mapping_tbl.count LOOP
          IF l_related_deal_line.modifier_id = l_line_mapping_tbl(i).org_line_id THEN
            l_new_modifier_id := l_line_mapping_tbl(i).new_line_id;
            EXIT;
          END IF;
        END LOOP;

        -- remove assigned source line id from mapping table
        FOR i IN 1..l_line_mapping_tbl.count LOOP
          IF l_new_modifier_id = l_line_mapping_tbl(i).new_line_id THEN
            l_line_mapping_tbl(i) := NULL;
          END IF;
        END LOOP;

        IF l_related_deal_line.related_modifier_id IS NOT NULL
        AND l_related_deal_line.related_modifier_id <> FND_API.G_MISS_NUM
        THEN
          -- get new rltd line id
          FOR i IN 1..l_line_mapping_tbl.count LOOP
            IF l_related_deal_line.related_modifier_id = l_line_mapping_tbl(i).org_line_id  THEN
              l_new_rltd_modifier_id := l_line_mapping_tbl(i).new_line_id;
              EXIT;
            END IF;
          END LOOP;

          -- remove assigned rltd line id from mapping table
          FOR i IN 1..l_line_mapping_tbl.count LOOP
            IF l_new_rltd_modifier_id = l_line_mapping_tbl(i).new_line_id THEN
              l_line_mapping_tbl(i) := NULL;
            END IF;
          END LOOP;
        ELSE
          l_new_rltd_modifier_id := NULL;
        END IF;

        -- create related line info in ozf_related_deal_lines
        l_related_lines_rec.modifier_id := l_new_modifier_id;
        l_related_lines_rec.related_modifier_id := l_new_rltd_modifier_id;
        l_related_lines_rec.object_version_number := 1;
        l_related_lines_rec.estimated_qty_is_max := l_related_deal_line.estimated_qty_is_max;
        l_related_lines_rec.estimated_amount_is_max := l_related_deal_line.estimated_amount_is_max;
        l_related_lines_rec.estimated_qty := l_related_deal_line.estimated_qty;
        l_related_lines_rec.estimated_amount := l_related_deal_line.estimated_amount;
        l_related_lines_rec.estimate_qty_uom := l_related_deal_line.estimate_qty_uom;
        l_related_lines_rec.qp_list_header_id := l_offer_rec.qp_list_header_id;

        ozf_Related_Lines_PVT.Create_related_lines
            (p_api_version_number       => 1.0
            ,x_return_status            => x_return_Status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            ,p_related_lines_rec        => l_related_lines_rec
            ,x_related_deal_lines_id    => l_related_deal_lines_id);
      END LOOP;
      -- end processing related lines for trade deal
    --END IF;

    ELSIF l_offer_rec.offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
    -- copy lines for lumpsum and scan data
    FOR l_act_product IN c_act_products LOOP
      l_act_product_rec.act_product_used_by_id := l_offer_rec.qp_list_header_id;
      l_act_product_rec.arc_act_product_used_by := 'OFFR';
      l_act_product_rec.product_sale_type := l_act_product.product_sale_type;
      l_act_product_rec.primary_product_flag := l_act_product.primary_product_flag;
      l_act_product_rec.enabled_flag := l_act_product.enabled_flag;
      l_act_product_rec.excluded_flag := l_act_product.excluded_flag;
      l_act_product_rec.category_id := l_act_product.category_id;
      l_act_product_rec.category_set_id := l_act_product.category_set_id;
      l_act_product_rec.organization_id := l_act_product.organization_id;
      l_act_product_rec.inventory_item_id := l_act_product.inventory_item_id;
      l_act_product_rec.level_type_code := l_act_product.level_type_code;
      l_act_product_rec.line_lumpsum_amount := l_act_product.line_lumpsum_amount;
      l_act_product_rec.line_lumpsum_qty := l_act_product.line_lumpsum_qty;
      l_act_product_rec.attribute_category := l_act_product.attribute_category;
      l_act_product_rec.attribute1 := l_act_product.attribute1;
      l_act_product_rec.attribute2 := l_act_product.attribute2;
      l_act_product_rec.attribute3 := l_act_product.attribute3;
      l_act_product_rec.attribute4 := l_act_product.attribute4;
      l_act_product_rec.attribute5 := l_act_product.attribute5;
      l_act_product_rec.attribute6 := l_act_product.attribute6;
      l_act_product_rec.attribute7 := l_act_product.attribute7;
      l_act_product_rec.attribute8 := l_act_product.attribute8;
      l_act_product_rec.attribute9 := l_act_product.attribute9;
      l_act_product_rec.attribute10 := l_act_product.attribute10;
      l_act_product_rec.attribute11 := l_act_product.attribute11;
      l_act_product_rec.attribute12 := l_act_product.attribute12;
      l_act_product_rec.attribute13 := l_act_product.attribute13;
      l_act_product_rec.attribute14 := l_act_product.attribute14;
      l_act_product_rec.attribute15 := l_act_product.attribute15;
      l_act_product_rec.channel_id := l_act_product.channel_id;
      l_act_product_rec.uom_code := l_act_product.uom_code;
      l_act_product_rec.quantity := l_act_product.quantity;
      l_act_product_rec.scan_value := l_act_product.scan_value;
      l_act_product_rec.scan_unit_forecast := l_act_product.scan_unit_forecast;
      l_act_product_rec.adjustment_flag := l_act_product.adjustment_flag;

      ams_ActProduct_PVT.Create_Act_Product(p_api_version      => p_api_version
                                           ,p_init_msg_list    => p_init_msg_list
                                           ,p_commit           => p_commit
                                           ,p_validation_level => p_validation_level
                                           ,x_return_status    => x_return_status
                                           ,x_msg_count        => x_msg_count
                                           ,x_msg_data         => x_msg_data
                                           ,p_act_Product_rec  => l_act_product_rec
                                           ,x_act_Product_id   => l_act_product_id);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_temp_id := l_act_product_id;

      -- copy exclusion
      FOR l_excluded_product IN c_excluded_products(l_act_product.activity_product_id) LOOP
        l_act_product_rec := NULL;

        l_act_product_rec.act_product_used_by_id := l_temp_id;
        l_act_product_rec.arc_act_product_used_by := 'PROD';
        l_act_product_rec.product_sale_type := l_excluded_product.product_sale_type;
        l_act_product_rec.primary_product_flag := l_excluded_product.primary_product_flag;
        l_act_product_rec.enabled_flag := l_excluded_product.enabled_flag;
        l_act_product_rec.excluded_flag := l_excluded_product.excluded_flag;
        l_act_product_rec.category_id := l_excluded_product.category_id;
        l_act_product_rec.category_set_id := l_excluded_product.category_set_id;
        l_act_product_rec.organization_id := l_excluded_product.organization_id;
        l_act_product_rec.inventory_item_id := l_excluded_product.inventory_item_id;
        l_act_product_rec.level_type_code := l_excluded_product.level_type_code;
        l_act_product_rec.line_lumpsum_amount := l_excluded_product.line_lumpsum_amount;
        l_act_product_rec.line_lumpsum_qty := l_excluded_product.line_lumpsum_qty;
        l_act_product_rec.attribute_category := l_excluded_product.attribute_category;
        l_act_product_rec.attribute1 := l_excluded_product.attribute1;
        l_act_product_rec.attribute2 := l_excluded_product.attribute2;
        l_act_product_rec.attribute3 := l_excluded_product.attribute3;
        l_act_product_rec.attribute4 := l_excluded_product.attribute4;
        l_act_product_rec.attribute5 := l_excluded_product.attribute5;
        l_act_product_rec.attribute6 := l_excluded_product.attribute6;
        l_act_product_rec.attribute7 := l_excluded_product.attribute7;
        l_act_product_rec.attribute8 := l_excluded_product.attribute8;
        l_act_product_rec.attribute9 := l_excluded_product.attribute9;
        l_act_product_rec.attribute10 := l_excluded_product.attribute10;
        l_act_product_rec.attribute11 := l_excluded_product.attribute11;
        l_act_product_rec.attribute12 := l_excluded_product.attribute12;
        l_act_product_rec.attribute13 := l_excluded_product.attribute13;
        l_act_product_rec.attribute14 := l_excluded_product.attribute14;
        l_act_product_rec.attribute15 := l_excluded_product.attribute15;
        l_act_product_rec.channel_id := l_excluded_product.channel_id;
        l_act_product_rec.uom_code := l_excluded_product.uom_code;
        l_act_product_rec.quantity := l_excluded_product.quantity;
        l_act_product_rec.scan_value := l_excluded_product.scan_value;
        l_act_product_rec.scan_unit_forecast := l_excluded_product.scan_unit_forecast;
        l_act_product_rec.adjustment_flag := l_excluded_product.adjustment_flag;
        ams_ActProduct_PVT.Create_Act_Product(p_api_version      => p_api_version
                                             ,p_init_msg_list    => p_init_msg_list
                                             ,p_commit           => p_commit
                                             ,p_validation_level => p_validation_level
                                             ,x_return_status    => x_return_status
                                             ,x_msg_count        => x_msg_count
                                             ,x_msg_data         => x_msg_data
                                             ,p_act_Product_rec  => l_act_product_rec
                                             ,x_act_Product_id   => l_act_product_id);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      -- end copying exclusion
    END LOOP;
    -- end copying lines for lumpsum and scan data
    END IF;

    ELSIF l_offer_rec.offer_type = 'VOLUME_OFFER' THEN
    -- if volume offer, copy tier info
    -- copy list header
    DECLARE
    l_listHeaderId NUMBER;
    BEGIN
    copy_vo_header
    (
           p_api_version          => 1.0
           , p_init_msg_list      => FND_API.G_FALSE
           , p_commit             => FND_API.G_FALSE
           , p_validation_level   => p_validation_level
           , x_return_status      => x_return_status
           , x_msg_count          => x_msg_count
           , x_msg_data           => x_msg_data
           , p_listHeaderId       => p_source_object_id
           , x_OfferId            => l_offer_id
           , x_listHeaderId       => l_listHeaderId
           , p_copy_columns_table => p_copy_columns_table
           , p_attributes_table   => p_attributes_table
           , p_custom_setup_id    => p_custom_setup_id
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_offer_rec.qp_list_header_id := l_listHeaderId;
    END;
 END IF;

  IF AMS_CpyUtility_PVT.is_copy_attribute ('ATCH', p_attributes_table) = FND_API.G_TRUE THEN
    l_errnum := 0;
    l_errcode := NULL;
    l_errmsg := NULL;
    ams_copyelements_pvt.copy_act_attachments( p_src_act_type  => 'OZF_OFFR',
                                               p_src_act_id    => p_source_object_id,
                                               p_new_act_id    => l_offer_rec.qp_list_header_id,
                                               p_errnum        => l_errnum,
                                               p_errcode       => l_errcode,
                                               p_errmsg        => l_errmsg);
  END IF;

  IF AMS_CpyUtility_PVT.is_copy_attribute ('CPNT', p_attributes_table) = FND_API.G_TRUE THEN
    FOR l_contact_point IN c_contact_point LOOP
      l_contact_point_rec.contact_point_id       := Fnd_Api.g_miss_num;
      l_contact_point_rec.last_update_date       := SYSDATE;
      l_contact_point_rec.last_updated_by        := FND_GLOBAL.user_id;
      l_contact_point_rec.creation_date          := SYSDATE;
      l_contact_point_rec.created_by             := FND_GLOBAL.user_id;
      l_contact_point_rec.last_update_login      := FND_GLOBAL.conc_login_id;
      l_contact_point_rec.object_version_number  := 1;
      l_contact_point_rec.arc_contact_used_by    := 'OFFR';
      l_contact_point_rec.act_contact_used_by_id := l_offer_rec.qp_list_header_id;
      l_contact_point_rec.contact_point_type     := l_contact_point.contact_point_type;
      l_contact_point_rec.contact_point_value    := l_contact_point.contact_point_value;
      l_contact_point_rec.city                   := l_contact_point.city;
      l_contact_point_rec.country                := l_contact_point.country;
      l_contact_point_rec.zipcode                := l_contact_point.zipcode;
      l_contact_point_rec.attribute_category     := l_contact_point.attribute_category;
      l_contact_point_rec.attribute1             := l_contact_point.attribute1;
      l_contact_point_rec.attribute2             := l_contact_point.attribute2;
      l_contact_point_rec.attribute3             := l_contact_point.attribute3;
      l_contact_point_rec.attribute4             := l_contact_point.attribute4;
      l_contact_point_rec.attribute5             := l_contact_point.attribute5;
      l_contact_point_rec.attribute6             := l_contact_point.attribute6;
      l_contact_point_rec.attribute7             := l_contact_point.attribute7;
      l_contact_point_rec.attribute8             := l_contact_point.attribute8;
      l_contact_point_rec.attribute9             := l_contact_point.attribute9;
      l_contact_point_rec.attribute10            := l_contact_point.attribute10;
      l_contact_point_rec.attribute11            := l_contact_point.attribute11;
      l_contact_point_rec.attribute12            := l_contact_point.attribute12;
      l_contact_point_rec.attribute13            := l_contact_point.attribute13;
      l_contact_point_rec.attribute14            := l_contact_point.attribute14;
      l_contact_point_rec.attribute15            := l_contact_point.attribute15;

      ams_cnt_point_pvt.create_cnt_point(p_api_version_number => p_api_version
                                        ,p_init_msg_list      => p_init_msg_list
                                        ,p_commit             => p_commit
                                        ,p_validation_level   => p_validation_level
                                        ,x_return_status      => x_return_status
                                        ,x_msg_count          => x_msg_count
                                        ,x_msg_data           => x_msg_data
                                        ,p_cnt_point_rec      => l_contact_point_rec
                                        ,x_contact_point_id   => l_dummy
                                        );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;
/* ELIG is copied by QP API
  IF AMS_CpyUtility_PVT.is_copy_attribute ('ELIG', p_attributes_table) = FND_API.G_TRUE THEN
    FOR l_market_elig_rec IN c_market_elig LOOP
      l_index2 := l_index2 + 1;
      l_qualifier_tbl(l_index2).qualifier_context := l_market_elig_rec.qualifier_context;
      l_qualifier_tbl(l_index2).qualifier_attribute := l_market_elig_rec.qualifier_attribute;
      l_qualifier_tbl(l_index2).qualifier_attr_value := l_market_elig_rec.qualifier_attr_value;
      l_qualifier_tbl(l_index2).qualifier_attr_value_to := l_market_elig_rec.qualifier_attr_value_to;
      l_qualifier_tbl(l_index2).comparison_operator_code := l_market_elig_rec.comparison_operator_code;
      l_qualifier_tbl(l_index2).qualifier_grouping_no := l_market_elig_rec.qualifier_grouping_no;
      l_qualifier_tbl(l_index2).list_line_id := l_market_elig_rec.list_line_id;
      l_qualifier_tbl(l_index2).list_header_id := l_offer_rec.qp_list_header_id;
      l_qualifier_tbl(l_index2).start_date_active := l_market_elig_rec.start_date_active;
      l_qualifier_tbl(l_index2).end_date_active := l_market_elig_rec.end_date_active;
      l_qualifier_tbl(l_index2).operation := 'CREATE';
    END LOOP;

    IF l_index2 > 0 THEN -- if no market elig l_index2=0
      ozf_offer_pvt.process_market_qualifiers(p_init_msg_list  => p_init_msg_list
                                             ,p_api_version    => p_api_version
                                             ,p_commit         => p_commit
                                             ,x_return_status  => x_return_status
                                             ,x_msg_count      => x_msg_count
                                             ,x_msg_data       => x_msg_data
                                             ,p_qualifiers_tbl => l_qualifier_tbl
                                             ,x_error_location => l_error_location);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
*/
  IF AMS_CpyUtility_PVT.is_copy_attribute ('ELIG', p_attributes_table) = FND_API.G_FALSE THEN
    IF l_offer_rec.offer_type IN ('ACCRUAL', 'OFF_INVOICE', 'TERMS', 'ORDER', 'OID') THEN
      DELETE FROM qp_qualifiers
            WHERE list_header_id = l_offer_rec.qp_list_header_id
              AND list_line_id = -1;
    END IF;
  ELSE
    IF l_offer_rec.offer_type = 'NET_ACCRUAL' THEN
      copy_na_market_elig(p_source_object_id => p_source_object_id
                         ,p_new_offer_id     => l_offer_rec.offer_id);
    END IF;
  END IF;

  IF AMS_CpyUtility_PVT.is_copy_attribute ('CONTENT', p_attributes_table) = FND_API.G_TRUE THEN
    l_errnum := 0;
    l_errcode := NULL;
    l_errmsg := NULL;
    ams_copyelements_pvt.copy_act_content(p_src_act_type => 'OZF_OFFR',
                                          p_src_act_id   => p_source_object_id,
                                          p_new_act_id   => l_offer_rec.qp_list_header_id,
                                          p_errnum       => l_errnum,
                                          p_errcode      => l_errcode,
                                          p_errmsg       => l_errmsg);
  END IF;

  IF AMS_CpyUtility_PVT.is_copy_attribute ('TEAM', p_attributes_table) = FND_API.G_TRUE THEN
    l_errnum := 0;
    l_errcode := NULL;
    l_errmsg := NULL;
    ams_copyelements_pvt.copy_act_access(p_src_act_type => 'OFFR',
                                         p_new_act_type => 'OFFR',
                                         p_src_act_id   => p_source_object_id,
                                         p_new_act_id   => l_offer_rec.qp_list_header_id,
                                         p_errnum       => l_errnum,
                                         p_errcode      => l_errcode,
                                         p_errmsg       => l_errmsg);
  END IF;

  x_new_object_id := l_offer_rec.qp_list_header_id;

  EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_offer_detail;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_offer_detail;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_offer_detail;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END copy_offer_detail;

PROCEDURE copy_offer(p_api_version        IN  NUMBER,
                     p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
                     p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     x_return_status      OUT NOCOPY VARCHAR2,
                     x_msg_count          OUT NOCOPY NUMBER,
                     x_msg_data           OUT NOCOPY VARCHAR2,
                     p_source_object_id   IN  NUMBER,
                     p_attributes_table   IN  AMS_CpyUtility_PVT.copy_attributes_table_type,
                     p_copy_columns_table IN  AMS_CpyUtility_PVT.copy_columns_table_type,
                     x_new_object_id      OUT NOCOPY NUMBER,
                     x_custom_setup_id    OUT NOCOPY NUMBER)
IS
  CURSOR c_budget_offer_yn IS
  SELECT budget_offer_yn, offer_type, custom_setup_id
  FROM   ozf_offers
  WHERE  qp_list_header_id = p_source_object_id;

  l_budget_offer_yn VARCHAR2(1);
  l_offer_type      VARCHAR2(30);
  l_api_name        VARCHAR2(30) := 'copy_offer';
BEGIN
  SAVEPOINT copy_offer;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  c_budget_offer_yn;
  FETCH c_budget_offer_yn INTO l_budget_offer_yn, l_offer_type, x_custom_setup_id;
  CLOSE c_budget_offer_yn;

  IF l_budget_offer_yn = 'Y' THEN
    IF l_offer_type = 'ACCRUAL' THEN
      x_custom_setup_id := 91;
    ELSIF l_offer_type = 'VOLUME_OFFER' THEN
      x_custom_setup_id := 98;
    END IF;
  END IF;

  copy_offer_detail
            (p_api_version        => p_api_version,
             p_init_msg_list      => p_init_msg_list,
             p_commit             => p_commit,
             p_validation_level   => p_validation_level,
             x_return_status      => x_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_source_object_id   => p_source_object_id,
             p_attributes_table   => p_attributes_table,
             p_copy_columns_table => p_copy_columns_table,
             x_new_object_id      => x_new_object_id,
             p_custom_setup_id    => x_custom_setup_id);

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO copy_offer;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_offer;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO copy_offer;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END copy_offer;

END OZF_COPY_OFFER_PVT;

/
