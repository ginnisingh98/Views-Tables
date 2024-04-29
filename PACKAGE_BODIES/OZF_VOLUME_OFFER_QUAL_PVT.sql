--------------------------------------------------------
--  DDL for Package Body OZF_VOLUME_OFFER_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOLUME_OFFER_QUAL_PVT" AS
/* $Header: ozfvvoqb.pls 120.7 2005/10/11 13:55:53 rssharma noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Volume_Offer_Qual_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvvoqb.pls';

OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE debug_message(p_message IN VARCHAR2)
IS
BEGIN
  IF (OZF_DEBUG_HIGH_ON) THEN
       ozf_utility_pvt.debug_message(p_message);
   END IF;
END debug_message;


PROCEDURE populate_mkt_option_qual_intf(
    p_mo_rec                     IN OZF_offer_Market_Options_PVT.vo_mo_rec_type
    , p_qualifiers_rec            qp_qualifier_rules_pub.qualifiers_rec_type
    , p_qual_mo_rec                IN  OUT NOCOPY  OZF_QUAL_MARKET_OPTION_PVT.qual_mo_rec_type
    , x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF create_mo_for_group(p_qualifiers_rec.qualifier_grouping_no, p_qualifiers_rec.list_header_id) = 'N' THEN
    IF get_market_option_id(p_qualifiers_rec.qualifier_grouping_no, p_qualifiers_rec.list_header_id) = -1 THEN
             OZF_Utility_PVT.Error_Message('OZF_OFFR_INV_MO');
             x_return_status := FND_API.g_ret_sts_error;
    END IF;
    p_qual_mo_rec.offer_market_option_id := get_market_option_id(p_qualifiers_rec.qualifier_grouping_no, p_qualifiers_rec.list_header_id);
ELSE
p_qual_mo_rec.offer_market_option_id := p_mo_rec.offer_market_option_id;
END IF;
p_qual_mo_rec.qp_qualifier_id := p_qualifiers_rec.qualifier_id;
END populate_mkt_option_qual_intf;

PROCEDURE populate_deflt_mkt_options(
    p_mo_rec                     IN OUT NOCOPY OZF_offer_Market_Options_PVT.vo_mo_rec_type
    , p_qualifiers_rec            qp_qualifier_rules_pub.qualifiers_rec_type
    , x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    )
    IS
    CURSOR c_offer_id(p_qp_list_header_id NUMBER) IS
    SELECT offer_id FROM ozf_offers
    WHERE qp_list_header_id = p_qp_list_header_id
    AND offer_type = 'VOLUME_OFFER';

    l_offer_id NUMBER;

    BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_offer_id(p_qualifiers_rec.list_header_id);
    FETCH c_Offer_id INTO l_offer_id;
    IF (c_offer_id%NOTFOUND) THEN
        OZF_UTILITY_PVT.Error_message('OZF_OFFR_INV_OFFER_ID');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    p_mo_rec.offer_id := l_offer_id;
    p_mo_rec.qp_list_header_id := p_qualifiers_rec.list_header_id;
    p_mo_rec.group_number := p_qualifiers_rec.qualifier_grouping_no;
    p_mo_rec.retroactive_flag := FND_PROFILE.VALUE('OZF_VO_RETROACTIVE');
--    l_mo_rec.beneficiary_party_id :=  null;;
    p_mo_rec.combine_schedule_flag := FND_PROFILE.VALUE('OZF_VO_COMBINE_DISCOUNTS_FLAG');
    p_mo_rec.volume_tracking_level_code := FND_PROFILE.VALUE('OZF_VO_VOLUME_TRACKING_LEVEL');
    p_mo_rec.accrue_to_code := FND_PROFILE.VALUE('OZF_VO_ACCRUE_TO');
    p_mo_rec.precedence := p_qualifiers_rec.qualifier_grouping_no;

    debug_message('Offer Id is : '||p_mo_rec.offer_id);
    END populate_deflt_mkt_options;



FUNCTION create_mo_for_group(
    p_group_number NUMBER
    , p_qp_list_header_id NUMBER
) RETURN VARCHAR2
IS
l_return VARCHAR2(1) := 'Y';
CURSOR c_create_mo(p_group_number NUMBER, p_qp_list_header_id NUMBER) IS
SELECT 'N' FROM dual WHERE EXISTS(SELECT 'X' FROM ozf_offr_market_options WHERE group_number = p_group_number and qp_list_header_id = p_qp_list_header_id);
BEGIN
OPEN c_create_mo(p_group_number,p_qp_list_header_id);
    FETCH c_create_mo INTO l_return;
    IF(c_create_mo%NOTFOUND) THEN
        l_return := 'Y';
    END IF;
CLOSE c_create_mo;
RETURN l_return;
END create_mo_for_group;

FUNCTION get_market_option_id(p_group_number NUMBER,p_qp_list_header_id NUMBER)
RETURN NUMBER
IS
CURSOR c_mkt_option_id(p_group_number NUMBER,p_qp_list_header_id NUMBER)IS
SELECT offer_market_option_id FROM ozf_offr_market_options WHERE qp_list_header_id = p_qp_list_header_id AND group_number = p_group_number;
l_market_option_id NUMBER := -1;
BEGIN
OPEN c_mkt_option_id(p_group_number ,p_qp_list_header_id);
    FETCH c_mkt_option_id INTO l_market_option_id;
    IF (c_mkt_option_id%NOTFOUND) THEN
        l_market_option_id := -1;
    END IF;
CLOSE c_mkt_option_id;
RETURN l_market_option_id;
END get_market_option_id;

PROCEDURE create_vo_qualifier
(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2

    , p_qualifiers_rec             IN   OZF_OFFER_PVT.qualifiers_Rec_Type
)
IS
x_qualifiers_tbl            qp_qualifier_rules_pub.qualifiers_tbl_type;
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_api_name                  CONSTANT VARCHAR2(30) := 'create_vo_qualifier';
l_qualifiers_tbl            OZF_OFFER_PVT.QUALIFIERS_TBL_TYPE;
l_qualifiers_rec            OZF_OFFER_PVT.QUALIFIERS_REC_TYPE;
x_error_location NUMBER;
l_mo_id NUMBER;
l_Mo_rec OZF_offer_Market_Options_PVT.vo_mo_rec_type;

l_qual_mo_rec  OZF_QUAL_MARKET_OPTION_PVT.qual_mo_rec_type;
l_qual_market_option_id NUMBER;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT create_volume_offer_qual_pvt;

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

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;
-- create market eligibility
l_qualifiers_tbl(1) := p_qualifiers_rec;


-- check if offer is volume offer

-- logic for creating qualifier
-- 1. Create a market eligibility.
-- 2. For the newly created market Eligibility , check if market option exists ie. does market option exist for the group
-- the qualifier belongs to
-- if market option already exists , get the market option id and create a qualifier market option relation.
-- if market optoin does not exist for the group, create the market option , get the market option id and then
-- create a market option-qualifier relation

l_qualifiers_tbl(1).operation := 'CREATE';
OZF_OFFER_PVT.process_market_qualifiers
(
   p_init_msg_list         => p_init_msg_list
  ,p_api_version           => p_api_version_number
  ,p_commit                => p_commit
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_qualifiers_tbl        => l_qualifiers_tbl
  ,x_error_location        => x_error_location
  ,x_qualifiers_tbl        => x_qualifiers_tbl
);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

debug_message('Return count is : '||x_qualifiers_tbl.count);

FOR i in 1 .. x_qualifiers_tbl.count
LOOP
debug_message('QUalifierId is : '||x_qualifiers_tbl(i).qualifier_id);
debug_message('List Header Id is : '||x_qualifiers_tbl(i).list_header_id);



IF x_qualifiers_tbl(i).qualifier_context IN ('CUSTOMER','CUSTOMER_GROUP','TERRITORY','SOLD_BY') THEN
IF create_mo_for_group(p_group_number => x_qualifiers_tbl(i).qualifier_grouping_no,p_qp_list_header_id => x_qualifiers_tbl(i).list_header_id) = 'Y'
THEN
populate_deflt_mkt_options(
    p_mo_rec                 => l_mo_rec
    , p_qualifiers_rec       => x_qualifiers_tbl(i)
    , x_return_status        => x_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

OZF_offer_Market_Options_PVT.Create_market_options
(
    p_api_version_number         => p_api_version_number
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_validation_level           => p_validation_level

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_mo_rec                     => l_mo_rec
    , x_vo_market_option_id        => l_mo_id
);

debug_message('Market option id is : '|| l_mo_id);
l_mo_rec.offer_market_option_id := l_mo_id;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

END IF;

populate_mkt_option_qual_intf(
    p_mo_rec                 => l_mo_rec
    , p_qualifiers_rec       => x_qualifiers_tbl(i)
    , p_qual_mo_rec          => l_qual_mo_rec
    , x_return_status        => x_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

OZF_QUAL_MARKET_OPTION_PVT.Create_qual_market_options(
    p_api_version_number         => p_api_version_number
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_validation_level           => p_validation_level

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_qual_mo_rec                     => l_qual_mo_rec
    , x_qual_market_option_id        => l_qual_market_option_id
);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
END IF;

END LOOP;

-- commit
  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;

--exception
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO create_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO create_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO create_volume_offer_qual_pvt;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END create_vo_qualifier;

FUNCTION get_group_members(p_qp_list_header_id NUMBER,  p_group_number NUMBER)
RETURN VARCHAR2
IS
--l_operation VARCHAR2(30);
CURSOR c_group_members_exist(p_qp_list_header_id NUMBER,p_group_number NUMBER) IS
SELECT 'Y' FROM dual WHERE EXISTS (SELECT 'X' FROM qp_qualifiers WHERE list_header_id = p_qp_list_header_id AND qualifier_grouping_no = p_group_number);
l_grp_mem_exist VARCHAR2(1) := 'A';
BEGIN
    OPEN c_group_members_exist(p_qp_list_header_id,p_group_number);
    FETCH c_group_members_exist INTO l_grp_mem_exist;
        IF (c_group_members_exist%NOTFOUND) THEN
            l_grp_mem_exist := 'N';
        END IF;
    CLOSE c_group_members_exist;

RETURN l_grp_mem_exist;

END get_group_members;


/*
Logic followed is
1. BEFORE update get the old group number of the qualifier
    check if members exist in the new group of the qualifier
2. Update the qualifier
3. check if members exist in the old group of the
4. If members did not exist in new group before creation of the qualifier
create a new market option
5. If members no longer exist in the old group delete the market option associated with the old group
6.Update the Market OPtion - QUalifier interface table to point to the new market_option
*/
PROCEDURE update_vo_qualifier
(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2

    , p_qualifiers_rec             IN   OZF_OFFER_PVT.qualifiers_Rec_Type
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'update_vo_qualifier';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_qualifiers_tbl OZF_OFFER_PVT.qualifiers_tbl_Type;
x_qualifiers_tbl            qp_qualifier_rules_pub.qualifiers_tbl_type;
x_error_location NUMBER;
l_group_number NUMBER := -5000;
l_operation VARCHAR2(30);
l_old_group_members_exist VARCHAR2(1);
l_new_group_members_exist VARCHAR2(1);

CURSOR c_group_number(p_qp_qualifier_id NUMBER) IS
SELECT qualifier_grouping_no FROM qp_qualifiers WHERE qualifier_id = p_qp_qualifier_id;

CURSOR c_mkt_opt_dtail(p_qp_qualifier_id NUMBER)
IS
SELECT offer_market_option_id, object_version_number FROM ozf_offr_market_options
WHERE offer_market_option_id = (SELECT offer_market_option_id FROM ozf_qualifier_market_option WHERE qp_qualifier_id = p_qp_qualifier_id);

l_mkt_opt_dtail c_mkt_opt_dtail%ROWTYPE;
l_mkt_option_found VARCHAR2(1) := 'N';
l_mo_id NUMBER;
l_mo_rec OZF_offer_Market_Options_PVT.vo_mo_rec_type;
l_qual_mo_rec OZF_QUAL_MARKET_OPTION_PVT.qual_mo_rec_type;

CURSOR c_qual_mo(p_qualifier_id NUMBER) IS
SELECT * FROM ozf_qualifier_market_option
WHERE qp_qualifier_id = p_qualifier_id;

l_qual_mo c_qual_mo%ROWTYPE;

CURSOR c_market_option_id(p_qp_list_header_id NUMBER, p_group_number NUMBER) IS
SELECT offer_market_option_id FROM ozf_offr_market_options WHERE qp_list_header_id = p_qp_list_header_id
AND group_number = p_group_number;

l_market_option_id NUMBER;

BEGIN
-- initialize
      SAVEPOINT update_volume_offer_qual_pvt;
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
-- update
l_qualifiers_tbl(1) := p_qualifiers_rec;

-- get old group number
OPEN c_group_number(l_qualifiers_tbl(1).qualifier_id);
    FETCH c_group_number INTO l_group_number;
    IF c_group_number%NOTFOUND THEN
        l_group_number := -1000;
    END IF;
CLOSE c_group_number;

-- check if members exist in the new group
l_new_group_members_exist := get_group_members(l_qualifiers_tbl(1).list_header_id,l_qualifiers_tbl(1).qualifier_grouping_no );

l_qualifiers_tbl(1).operation := 'UPDATE';
-- update the qualifier
debug_message('Calling update');
OZF_OFFER_PVT.process_market_qualifiers
(
   p_init_msg_list         => p_init_msg_list
  ,p_api_version           => p_api_version_number
  ,p_commit                => p_commit
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_qualifiers_tbl        => l_qualifiers_tbl
  ,x_error_location        => x_error_location
  ,x_qualifiers_tbl        => x_qualifiers_tbl
);


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- check if members still exist in the old group
l_old_group_members_exist := get_group_members(l_qualifiers_tbl(1).list_header_id,l_group_number );

FOR i in 1 .. x_qualifiers_tbl.count
LOOP
debug_message('QUalifier group nos are : old'||l_group_number || ' : NEW : '||x_qualifiers_tbl(i).qualifier_grouping_no);

-- get market option details of the old group using data in the interface table

-- do all processing to sync market options and interface table only id the group no. is updated
IF x_qualifiers_tbl(i).qualifier_context IN ('CUSTOMER','CUSTOMER_GROUP','TERRITORY','SOLD_BY') THEN

IF l_group_number <> p_qualifiers_rec.qualifier_grouping_no THEN

    OPEN c_mkt_opt_dtail(x_qualifiers_tbl(i).qualifier_id);
    FETCH c_mkt_opt_dtail INTO l_mkt_opt_dtail;

    IF (c_mkt_opt_dtail%NOTFOUND) THEN
        l_mkt_option_found := 'N';
    ELSE
        l_mkt_option_found := 'Y';
    END IF;
    CLOSE c_mkt_opt_dtail;

    debug_message('Market OPtion Found is : '||l_mkt_option_found);
    debug_message('Old Group members exist : '||l_old_group_members_exist);
    debug_message('New Group members exist : '||l_new_group_members_exist);


    IF l_mkt_option_found <> 'N' THEN
    -- if members do not exist in the old group delete the market option associated with the old group
        IF l_old_group_members_exist = 'N' THEN
        debug_message('Deleting old market option');
        OZF_offer_Market_Options_PVT.Delete_market_options(
            p_api_version_number         => p_api_version_number
            , p_init_msg_list              => p_init_msg_list
            , p_commit                     => p_commit
            , p_validation_level           => p_validation_level
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_offer_market_option_id     => l_mkt_opt_dtail.offer_market_option_id
            , p_object_version_number      => l_mkt_opt_dtail.object_version_number
            );
        END IF;
    END IF;
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                  END IF;

    -- if members did not exist in the new group before the creation of the offer create new market option
    IF l_new_group_members_exist = 'N' THEN
    debug_message('Creating new market options');
        populate_deflt_mkt_options(
            p_mo_rec                 => l_mo_rec
            , p_qualifiers_rec       => x_qualifiers_tbl(i)
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data
            );

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

        OZF_offer_Market_Options_PVT.Create_market_options
        (
            p_api_version_number         => p_api_version_number
            , p_init_msg_list              => p_init_msg_list
            , p_commit                     => p_commit
            , p_validation_level           => p_validation_level

            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data

            , p_mo_rec                     => l_mo_rec
            , x_vo_market_option_id        => l_mo_id
        );

        debug_message('Market option id is : '|| l_mo_id);
        l_mo_rec.offer_market_option_id := l_mo_id;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

    END IF; -- END IF l_new_group_members_exist = 'N'

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                  END IF;

    -- get the interface details for the qualifier id
    OPEN c_qual_mo(p_qualifiers_rec.qualifier_id);
    FETCH c_qual_mo INTO l_qual_mo;
        l_qual_mo_rec.qp_qualifier_id := l_qual_mo.qp_qualifier_id;
        l_qual_mo_rec.qualifier_market_option_id := l_qual_mo.qualifier_market_option_id;
        l_qual_mo_rec.object_version_number := l_qual_mo.object_version_number;
    CLOSE c_qual_mo;

    -- get the market option id for the group no
    -- -1 indicates that the group no for the QUalifier is -1 and qualifier-mo-interface exists for the qualifier
    -- the interface record is to be updated to -1 as the qualifier id
    -- -2 indicates that the group no for the qualifier is not -1 and no market option record exists for the qualifier
    -- this is a anomaly and raises error
    OPEN c_market_option_id(p_qualifiers_rec.list_header_id , p_qualifiers_rec.qualifier_grouping_no);
        FETCH c_market_option_id INTO l_market_option_id;
        IF (c_market_option_id%NOTFOUND) THEN
            IF p_qualifiers_rec.qualifier_grouping_no = -1 THEN
                l_market_option_id := -1;
            ELSE
                l_market_option_id := -2;
            END IF;
        END IF;
    CLOSE c_market_option_id;
    -- if market option exists for the group update the reference to the market option in the interface table
    IF l_market_option_id <> -2 THEN
        l_qual_mo_rec.offer_market_option_id := l_market_option_id;
        debug_message('uupdating interface');

        OZF_QUAL_MARKET_OPTION_PVT.update_qual_market_options(
            p_api_version_number            => p_api_version_number
            , p_init_msg_list               => p_init_msg_list
            , p_commit                      => p_commit
            , p_validation_level            => p_validation_level

            , x_return_status               => x_return_status
            , x_msg_count                   => x_msg_count
            , x_msg_data                    => x_msg_data

            , p_qual_mo_rec                 => l_qual_mo_rec
            );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

    ELSE
            OZF_Utility_PVT.Error_Message('OZF_CANT_UPDATE_INT');
            x_return_status := FND_API.g_ret_sts_error;
    END IF; -- END IF l_market_option_id <> -1

END IF; -- end if group nos are different
END IF; -- if qualifiers are in contexts CUSTOMER, CUSTOMER_GROUP, TERRITORY, SOLD_BY

END LOOP;

-- commit;
  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;

--exception
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO update_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO update_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO update_volume_offer_qual_pvt;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END update_vo_qualifier;



PROCEDURE Delete_vo_qualifier(
    p_api_version_number        IN NUMBER
    , p_init_msg_list           IN VARCHAR2     := FND_API.G_FALSE
    , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
    , p_validation_level        IN NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    , p_qualifier_id IN NUMBER
    )
    IS
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_volume_offer_qualifier';


CURSOR c_group_no(p_qualifier_id NUMBER)IS
SELECT qualifier_grouping_no,list_header_id FROM qp_qualifiers
WHERE qualifier_id = p_qualifier_id;
l_group_no c_group_no%ROWTYPE;
group_no NUMBER := 1000;

l_qualifiers_rec             OZF_OFFER_PVT.qualifiers_Rec_Type;
l_qualifiers_tbl             OZF_OFFER_PVT.qualifiers_TBL_Type;
x_error_location NUMBER;
x_qualifiers_tbl            qp_qualifier_rules_pub.qualifiers_tbl_type;


CURSOR c_mkt_opt_dtail(p_qp_qualifier_id NUMBER)
IS
SELECT offer_market_option_id, object_version_number FROM ozf_offr_market_options
WHERE offer_market_option_id = (SELECT offer_market_option_id FROM ozf_qualifier_market_option WHERE qp_qualifier_id = p_qp_qualifier_id);

l_mkt_opt_dtail c_mkt_opt_dtail%ROWTYPE;
l_mkt_option_found VARCHAR2(1);

CURSOR c_qual_mo(p_qualifier_id NUMBER)
IS
SELECT qualifier_market_option_id, object_version_number FROM ozf_qualifier_market_option
WHERE qp_qualifier_id = p_qualifier_id;
l_qual_mo c_qual_mo%ROWTYPE;

CURSOR c_qualifierContext(cp_qualifierId NUMBER) IS
SELECT qualifier_context FROM qp_qualifiers
WHERE qualifier_id = cp_qualifierId;
l_qualifierContext VARCHAR2(30);
    BEGIN
      SAVEPOINT Delete_volume_offer_qual_pvt;
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


    -- get group number
    OPEN c_group_no(p_qualifier_id);
    FETCH c_group_no INTO l_group_no;
    IF (c_group_no%NOTFOUND) THEN
        group_no := -1000;
    END IF;
    CLOSE c_group_no;
    -- delete the market eligibility
    l_qualifiers_rec.qualifier_id := p_qualifier_id;
    l_qualifiers_rec.operation := 'DELETE';
    l_qualifiers_tbl(1) := l_qualifiers_rec;

OZF_OFFER_PVT.process_market_qualifiers
    (
       p_init_msg_list         => p_init_msg_list
      ,p_api_version           => p_api_version_number
      ,p_commit                => p_commit
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      ,p_qualifiers_tbl        => l_qualifiers_tbl
      ,x_error_location        => x_error_location
      ,x_qualifiers_tbl        => x_qualifiers_tbl
    );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

OPEN c_qualifierContext( cp_qualifierId => p_qualifier_id);
    FETCH c_qualifierContext INTO l_qualifierContext;
CLOSE c_qualifierContext;

-- Market Option is created only for Customer Qualifiers. So deleting market options and interface records is only
-- required if the qualifier is a Customer Qualifier
IF l_qualifierContext IN ('CUSTOMER','CUSTOMER_GROUP','TERRITORY','SOLD_BY') THEN
        -- check if members still exist in the group
        -- if no delete the market option
        OPEN c_mkt_opt_dtail(p_qualifier_id);
        FETCH c_mkt_opt_dtail INTO l_mkt_opt_dtail;

        IF (c_mkt_opt_dtail%NOTFOUND) THEN
            l_mkt_option_found := 'N';
        ELSE
            l_mkt_option_found := 'Y';
        END IF;
        CLOSE c_mkt_opt_dtail;

    IF l_mkt_option_found = 'Y' THEN
    debug_message('Group no is : '||group_no);
        IF group_no <> -1000 THEN
        IF get_group_members(l_group_no.list_header_id,l_group_no.qualifier_grouping_no ) = 'N' THEN
            OZF_offer_Market_Options_PVT.Delete_market_options(
                p_api_version_number         => p_api_version_number
                , p_init_msg_list              => p_init_msg_list
                , p_commit                     => p_commit
                , p_validation_level           => p_validation_level
                , x_return_status              => x_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_offer_market_option_id     => l_mkt_opt_dtail.offer_market_option_id
                , p_object_version_number      => l_mkt_opt_dtail.object_version_number
                );

        END IF;
        ELSE
                OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_CANT_DELETE_MO');
                x_return_status := FND_API.g_ret_sts_error;
        END IF;
    END IF;
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

        -- delete the interface reference
    OPEN c_qual_mo(p_qualifier_id);
    FETCH c_qual_mo INTO l_qual_mo;
    IF (c_qual_mo%NOTFOUND) THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_INTF_REC_NOT_FOUND');
            x_return_status := FND_API.g_ret_sts_error;
    ELSE
        OZF_QUAL_MARKET_OPTION_PVT.Delete_qual_market_options(
                p_api_version_number         => p_api_version_number
                , p_init_msg_list              => p_init_msg_list
                , p_commit                     => p_commit
                , p_validation_level           => p_validation_level
                , x_return_status              => x_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_qualifier_market_option_id => l_qual_mo.qualifier_market_option_id
                , p_object_version_number      => l_qual_mo.object_version_number
        );

    END IF;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

END IF;
  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;

--exception
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO Delete_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO Delete_volume_offer_qual_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO Delete_volume_offer_qual_pvt;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );


    END Delete_vo_qualifier;

END OZF_Volume_Offer_Qual_PVT;

/
