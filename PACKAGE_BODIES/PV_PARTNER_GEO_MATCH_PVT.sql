--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_GEO_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_GEO_MATCH_PVT" as
/* $Header: pvxvpgmb.pls 115.2 2004/06/02 18:57:03 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Geo_Match_PVT
-- Purpose
--
-- History
--      02-JUN-2004   ktsao  Fixed for sql repository issues
--
-- NOTE
--
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Partner_Geo_Match_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpgmb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
TYPE address_rec_type IS RECORD
(
     postal_code                     NUMBER
    ,city                            NUMBER
    ,state                           NUMBER
    ,country                         NUMBER
);

-- Foreward Procedure Declarations
--

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Get_Matched_Geo_Hierarchy_Id
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER                   Required
--       p_init_msg_list           IN   VARCHAR2                 Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Get_Matched_Geo_Hierarchy_Id(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_partner_party_id           IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Matched_Geog_Hierarchy_Id';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_ordered_loc IS
      select LH.location_hierarchy_id,
      LH.LOCATION_TYPE_CODE TYPE_CODE,
      DECODE(LH.LOCATION_TYPE_CODE,
      'AREA1', LH.AREA1_CODE,
      'AREA2',LH.AREA2_CODE,
      'COUNTRY', LH.COUNTRY_CODE,
      'CREGION', LH.COUNTRY_REGION_CODE,
      'STATE', LH.STATE_CODE,
      'SREGION', LH.STATE_REGION_CODE,
      'CITY', LH.CITY_CODE,
      'POSTAL_CODE', LH.POSTAL_CODE_START||'-'||LH.POSTAL_CODE_END) LOWEST_CODE,
      DECODE(LH.LOCATION_TYPE_CODE, 'POSTAL_CODE',1,
      'CITY', 2,
      'SREGION', 3,
      'STATE', 4,
      'CREGION', 5,
      'COUNTRY', 6,
      'AREA2', 7,
      'AREA1', 8) LOC_TYPE
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.location_hierarchy_id in (
      	SELECT * FROM TABLE (CAST(p_geo_hierarchy_id AS JTF_NUMBER_TABLE))
      )
      and lh.location_type_code in ('AREA1', 'AREA2', 'COUNTRY', 'CREGION', 'STATE', 'SREGION', 'CITY', 'POSTAL_CODE')
      order by loc_type;

   CURSOR c_get_address(cv_partner_party_id NUMBER) IS
      select L.postal_code, L.city, L.state, L.country
      from hz_party_sites PS, hz_locations L
      where PS.location_id = L.location_id
            and PS.party_id = cv_partner_party_id
            and PS.identifying_address_flag = 'Y';

   CURSOR c_exist_postal (cv_postal_code VARCHAR2, cv_city_code VARCHAR2,
                          cv_state_code VARCHAR2, cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.postal_code_start <= cv_postal_code
            and LH.postal_code_end >= cv_postal_code
            and LH.city_code = cv_city_code
            and LH.state_code = cv_state_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'POSTAL_CODE';

   CURSOR c_exist_postal_sregion (cv_postal_code VARCHAR2, cv_city_code VARCHAR2,
                                  cv_state_region_code VARCHAR2, cv_state_code VARCHAR2,
                                  cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.postal_code_start <= cv_postal_code
            and LH.postal_code_end >= cv_postal_code
            and LH.city_code = cv_city_code
            and LH.state_region_code = cv_state_region_code
            and LH.state_code = cv_state_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'POSTAL_CODE';

   CURSOR c_exist_postal_cregion (cv_postal_code VARCHAR2, cv_city_code VARCHAR2,
                                  cv_state_code VARCHAR2, cv_country_region_code VARCHAR2,
                                  cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.postal_code_start <= cv_postal_code
            and LH.postal_code_end >= cv_postal_code
            and LH.city_code = cv_city_code
            and LH.state_code = cv_state_code
            and LH.country_region_code = cv_country_region_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'POSTAL_CODE';

   CURSOR c_exist_city (cv_city_code VARCHAR2, cv_state_code VARCHAR2,
                        cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.city_code = cv_city_code
            and LH.state_code = cv_state_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'CITY';

   CURSOR c_exist_city_sregion (cv_city_code VARCHAR2, cv_state_code VARCHAR2,
                                cv_state_region_code VARCHAR2, cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.city_code = cv_city_code
            and LH.state_region_code = cv_state_region_code
            and LH.state_code = cv_state_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'CITY';

   CURSOR c_exist_city_cregion (cv_city_code VARCHAR2, cv_state_code VARCHAR2,
                                cv_country_code VARCHAR2, cv_country_region_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.city_code = cv_city_code
            and LH.state_code = cv_state_code
            and LH.country_region_code = cv_country_region_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'CITY';

   CURSOR c_exist_state (cv_state_code VARCHAR2, cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.state_code = cv_state_code
            and LH.country_code = cv_country_code
            and lh.location_type_code = 'STATE';

   CURSOR c_exist_state_cregion (cv_state_code VARCHAR2, cv_country_code VARCHAR2,
                                 cv_country_region_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.state_code = cv_state_code
            and LH.country_region_code = cv_country_region_code
            and LH.country_code = cv_country_code
            and LH.location_type_code = 'STATE';

   CURSOR c_exist_country (cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
            and LH.location_type_code = 'COUNTRY';

   CURSOR c_exist_country_area2 (cv_country_code VARCHAR2, cv_area2_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
            and LH.area2_code = cv_area2_code
            and LH.location_type_code = 'COUNTRY';

   CURSOR c_exist_country_area1 (cv_country_code VARCHAR2, cv_area1_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
            and LH.area1_code = cv_area1_code
            and LH.location_type_code = 'COUNTRY';

   l_address_rec              c_get_address%ROWTYPE;
   l_exist_address_flag       VARCHAR2(1)    := 'Y';
   l_ordered_loc_rec          c_get_ordered_loc%ROWTYPE;
   l_geo_hierarchy_id         NUMBER;
   l_postal_code_start        VARCHAR2(6);
   l_postal_code_end          VARCHAR2(6);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Get_Matched_Geo_Hierarchy_Id;

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
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;



   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- open c_get_address fetch into l_address_rec;
   OPEN c_get_address(p_partner_party_id);
   FETCH c_get_address INTO l_address_rec;
   IF c_get_address%NOTFOUND THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Address not found.');
      END IF;
      l_exist_address_flag := 'N';
   END IF;
   CLOSE c_get_address;

   IF l_exist_address_flag = 'Y' THEN
      <<ordered_loc_loop>>
      FOR l_ordered_loc_rec IN c_get_ordered_loc
      LOOP
         IF l_ordered_loc_rec.type_code = 'POSTAL_CODE' THEN
            -- If the code is the same, try to see if the partner address
            -- exists in JTF_LOC_HIERARCHIES_VL.
            SELECT substr(l_ordered_loc_rec.lowest_code, instr(l_ordered_loc_rec.lowest_code, '-')+1)
               INTO l_postal_code_start
               FROM dual;

            SELECT substr(l_ordered_loc_rec.lowest_code, 1, instr(l_ordered_loc_rec.lowest_code, '-')-1)
               INTO l_postal_code_end
               FROM dual;

            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('l_postal_code_start = ' || l_postal_code_start);
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('l_postal_code_end = ' || l_postal_code_end);
            END IF;

            IF l_postal_code_start <= l_address_rec.postal_code AND
               l_address_rec.postal_code >= l_postal_code_end THEN
               -- call c_exist_postal
               FOR x IN c_exist_postal(l_address_rec.postal_code,
                                       l_address_rec.city,
                                       l_address_rec.state,
                                       l_address_rec.country) LOOP
                  -- if found, get l_ordered_loc_rec.location_hierarchy_id
                  l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
                  EXIT ordered_loc_loop;
               END LOOP;
            END IF;

         ELSIF l_ordered_loc_rec.type_code = 'CITY' THEN
            IF l_ordered_loc_rec.lowest_code = l_address_rec.city THEN
               -- If the code is the same, try to see if the partner address
               -- exists in JTF_LOC_HIERARCHIES_VL.
               -- call c_exist_city
               FOR x IN c_exist_city(l_address_rec.city,
                                     l_address_rec.state,
                                     l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
                  l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
                  EXIT ordered_loc_loop;
               END LOOP;
            END IF;

         ELSIF l_ordered_loc_rec.type_code = 'SREGION' THEN
            -- Because partner's address information doesn't contain state region,
            -- if there is a location hierarchy id defined for a state region, we need to add
            -- state region as a WHERE condition
            -- call c_exist_postal_sregion
            FOR x IN c_exist_postal_sregion(l_address_rec.postal_code,
                                            l_address_rec.city,
                                            l_ordered_loc_rec.lowest_code,
                                            l_address_rec.state,
                                            l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

            -- If the l_address_rec.postal_code doesn't exist in JTF_LOC_HIERARCHIES_VL,
            -- the city might exist. We drop the postal_code and try to match from city up.
            -- call c_exist_city_sregion
            FOR x IN c_exist_city_sregion(l_address_rec.city,
                                          l_ordered_loc_rec.lowest_code,
                                          l_address_rec.state,
                                          l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

         ELSIF l_ordered_loc_rec.type_code = 'STATE' THEN
            IF l_ordered_loc_rec.lowest_code = l_address_rec.state THEN
               -- call c_exist_state
               FOR x IN c_exist_state(l_address_rec.state,
                                      l_address_rec.country) LOOP
                  -- if found, get l_ordered_loc_rec.location_hierarchy_id
                  l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
                  EXIT ordered_loc_loop;
               END LOOP;
            END IF;

         ELSIF l_ordered_loc_rec.type_code = 'CREGION' THEN
            -- Because partner's address information doesn't contain country region,
            -- if there is a location hierarchy id defined for a country region, we need to add
            -- country region as a WHERE condition
            -- call c_exist_postal_cregion
            FOR x IN c_exist_postal_cregion(l_address_rec.postal_code,
                                            l_address_rec.city,
                                            l_address_rec.state,
                                            l_ordered_loc_rec.lowest_code,
                                            l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

            -- If the l_address_rec.postal_code doesn't exist in JTF_LOC_HIERARCHIES_VL,
            -- the city might exist. We drop the postal_code and then try to
            -- match from city up.
            -- call c_exist_city_cregion
            FOR x IN c_exist_city_cregion(l_address_rec.city,
                                          l_address_rec.state,
                                          l_ordered_loc_rec.lowest_code,
                                          l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

            -- If the l_address_rec.postal_code doesn't exist in JTF_LOC_HIERARCHIES_VL,
            -- the city might exist. We drop the postal_code and city and then try to
            -- match from state up.
            -- call c_exist_state_cregion
            FOR x IN c_exist_state_cregion(l_address_rec.state,
                                           l_ordered_loc_rec.lowest_code,
                                           l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

         ELSIF l_ordered_loc_rec.type_code = 'COUNTRY' THEN
            IF l_ordered_loc_rec.lowest_code = l_address_rec.country THEN
               -- If the code is the same, try to see if the partner address
               -- exists in JTF_LOC_HIERARCHIES_VL.
               -- call c_exist_country
               FOR x IN c_exist_country(l_address_rec.country) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
               END LOOP;
            END IF;

         ELSIF l_ordered_loc_rec.type_code = 'AREA2' THEN
            -- call c_exist_country_area2
            FOR x IN c_exist_country_area2 (l_address_rec.country,
                                            l_ordered_loc_rec.lowest_code) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;

         ELSIF l_ordered_loc_rec.type_code = 'AREA1' THEN
            -- call c_exist_country_area1
            FOR x IN c_exist_country_area1 (l_address_rec.country,
                                            l_ordered_loc_rec.lowest_code) LOOP
               -- if found, get l_ordered_loc_rec.location_hierarchy_id
               l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
               EXIT ordered_loc_loop;
            END LOOP;
         END IF;
      END LOOP;
   END IF;

   x_geo_hierarchy_id := l_geo_hierarchy_id;

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Final used geo_hierarchy_id = ' || x_geo_hierarchy_id);
   END IF;


   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Get_Matched_Geo_Hierarchy_Id;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Matched_Geo_Hierarchy_Id;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Get_Matched_Geo_Hierarchy_Id;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );


END Get_Matched_Geo_Hierarchy_Id;

/**********
 *
 * Get_Matched_Geo_Id_By_Country will match only for locaton type above Country.
 * That is, only match for Area 1, Area 2, and Country
 *
 ******/
PROCEDURE Get_Matched_Geo_Id_By_Country (
     p_country                    IN   VARCHAR2
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    )
 IS
   CURSOR c_get_ordered_loc IS
      select LH.location_hierarchy_id,
      LH.LOCATION_TYPE_CODE TYPE_CODE,
      DECODE(LH.LOCATION_TYPE_CODE,
      'AREA1', LH.AREA1_CODE,
      'AREA2',LH.AREA2_CODE,
      'COUNTRY', LH.COUNTRY_CODE) LOWEST_CODE,
      DECODE(LH.LOCATION_TYPE_CODE,
      'COUNTRY', 6,
      'AREA2', 7,
      'AREA1', 8) LOC_TYPE
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.location_hierarchy_id in (
      	SELECT * FROM TABLE (CAST(p_geo_hierarchy_id AS JTF_NUMBER_TABLE))
      )
      and LH.LOCATION_TYPE_CODE in ('AREA1', 'AREA2', 'COUNTRY')
      order by loc_type;

   CURSOR c_exist_country (cv_country_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
      and LH.location_type_code = 'COUNTRY';

   CURSOR c_exist_country_area2 (cv_country_code VARCHAR2, cv_area2_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
      and LH.area2_code = cv_area2_code
      and LH.location_type_code = 'COUNTRY';

   CURSOR c_exist_country_area1 (cv_country_code VARCHAR2, cv_area1_code VARCHAR2) IS
      select 'x'
      from JTF_LOC_HIERARCHIES_VL LH
      where LH.country_code = cv_country_code
      and LH.area1_code = cv_area1_code
      and LH.location_type_code = 'COUNTRY';

   l_ordered_loc_rec          c_get_ordered_loc%ROWTYPE;
   l_geo_hierarchy_id         NUMBER;


BEGIN
   <<ordered_loc_loop>>
   FOR l_ordered_loc_rec IN c_get_ordered_loc
   LOOP
      IF l_ordered_loc_rec.type_code = 'COUNTRY' THEN
         IF l_ordered_loc_rec.lowest_code = p_country THEN
            -- If the code is the same, try to see if the partner address
            -- exists in JTF_LOC_HIERARCHIES_VL.
            -- call c_exist_country
            FOR x IN c_exist_country(p_country) LOOP
            -- if found, get l_ordered_loc_rec.location_hierarchy_id
            l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
            EXIT ordered_loc_loop;
            END LOOP;
         END IF;

      ELSIF l_ordered_loc_rec.type_code = 'AREA2' THEN
         -- call c_exist_country_area2
         FOR x IN c_exist_country_area2 (p_country,
                                         l_ordered_loc_rec.lowest_code) LOOP
            -- if found, get l_ordered_loc_rec.location_hierarchy_id
            l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
            EXIT ordered_loc_loop;
         END LOOP;

      ELSIF l_ordered_loc_rec.type_code = 'AREA1' THEN
         -- call c_exist_country_area1
         FOR x IN c_exist_country_area1 (p_country,
                                         l_ordered_loc_rec.lowest_code) LOOP
            -- if found, get l_ordered_loc_rec.location_hierarchy_id
            l_geo_hierarchy_id := l_ordered_loc_rec.location_hierarchy_id;
            EXIT ordered_loc_loop;
         END LOOP;
      END IF;
   END LOOP;

   x_geo_hierarchy_id := l_geo_hierarchy_id;

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Final used geo_hierarchy_id = ' || x_geo_hierarchy_id);
   END IF;
END Get_Matched_Geo_Id_By_Country;


/**********
 *
 * Get_Ptnr_Matched_Geo_Id will match only for locaton type above
 * Country by passing in the partner id.
 * That is, only match for Area 1, Area 2, and Country
 *
 ******/
PROCEDURE Get_Ptnr_Matched_Geo_Id (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_partner_id                 IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Ptnr_Matched_Geo_Id';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_address(cv_partner_id NUMBER) IS
      select L.country
      from hz_party_sites PS, hz_locations L, pv_partner_profiles PP
      where PS.location_id = L.location_id
            and PP.partner_party_id = PS.party_id
            and PP.partner_id = cv_partner_id
            and PS.identifying_address_flag = 'Y';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Get_Ptnr_Matched_Geo_Id;

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
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR x in c_get_address(p_partner_id)
   LOOP
      Get_Matched_Geo_Id_By_Country (
          p_country            => x.country
         ,p_geo_hierarchy_id   => p_geo_hierarchy_id
         ,x_geo_hierarchy_id   => x_geo_hierarchy_id
      );
   END LOOP;

   -- Standard call to get message count and if count=1, get the message
   Fnd_Msg_Pub.Count_And_Get (
          p_encoded => Fnd_Api.G_FALSE
         ,p_count => x_msg_count
         ,p_data  => x_msg_data
   );

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO Get_Ptnr_Matched_Geo_Id;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

END Get_Ptnr_Matched_Geo_Id;

/**********
 *
 * Get_Ptnr_Org_Matched_Geo_Id will match only for locaton type above
 * Country by passing the partner org id.
 * That is, only match for Area 1, Area 2, and Country
 *
 ******/
PROCEDURE Get_Ptnr_Org_Matched_Geo_Id (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_party_id                   IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Ptnr_Org_Matched_Geo_Id';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_address(cv_party_id NUMBER) IS
      select L.country
      from hz_party_sites PS, hz_locations L
      where PS.location_id = L.location_id
            and PS.party_id = cv_party_id
            and PS.identifying_address_flag = 'Y';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Get_Ptnr_Org_Matched_Geo_Id;

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
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR x in c_get_address(p_party_id)
   LOOP
      Get_Matched_Geo_Id_By_Country (
          p_country            => x.country
         ,p_geo_hierarchy_id   => p_geo_hierarchy_id
         ,x_geo_hierarchy_id   => x_geo_hierarchy_id
      );
   END LOOP;

   -- Standard call to get message count and if count=1, get the message
   Fnd_Msg_Pub.Count_And_Get (
          p_encoded => Fnd_Api.G_FALSE
         ,p_count => x_msg_count
         ,p_data  => x_msg_data
   );

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO Get_Ptnr_Org_Matched_Geo_Id;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

END Get_Ptnr_Org_Matched_Geo_Id;


END PV_Partner_Geo_Match_PVT;

/
