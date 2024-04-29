--------------------------------------------------------
--  DDL for Package Body AMS_VENUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUE_PVT" AS
/* $Header: amsvvnub.pls 120.5 2006/04/05 05:39:22 batoleti ship $ */

------------------------------------------------------------------------------------------
-- PACKAGE
--    AMS_Venue_PVT
--
-- PROCEDURES
--    AMS_VENUES_VL:
--       Check_Venue_Req_Items
--       Check_Venue_UK_Items
--       Check_Venue_FK_Items
--       Check_Venue_Lookup_Items
--       Check_Venue_Flag_Items
--

-- NOTES
--
--
-- HISTORY
-- 10-Dec-1999    rvaka      Created.
-- 05-Feb-2001    mukumar    bug 162651 reports while updating a venu getting
--                           following error
--                              The Venue already exists -- please specify a different name
-- 20-Sep-2001    dcastlem   Fixing HZ_locations country_code in update
-- 19-APR-2002    dcastlem   TCA integration
-- 07-JUN-2002    dcastlem   bug 2386818 - removed access creation code (a more thorough cleanup
--                           would also involve fixing the header file, but since this is a bug
--                           fix I do not want to risk destabilizing the code)
-- 05-Aug-2002    gmadana    Bug # 2497053.
--                           Added logic for checking -ve values.
-- 04-Sep-2002    musman     Bug # 2540837,Commenting out call to create hz_locations and hz_party_Sites in
--                           the update_venue,since in the screen we have user cannot update these columns
-- 09 May 2003   dbiswas  Added checks for length of the ceiling height and capacity
-- 04-Aug-2004    dhsingh    Added org classification code, party site use creation
-- 23-Feb-2005   vmodur      Fix for Bug 4083293
--12-Aug-2005  sikalyan TCA V2API Uptake
--13-Sep-2005  sikalyan TCA Mandates for created_by_module 'AMS_EVENT'
------------------------------------------------------------------------------------------

--
-- Global CONSTANTS
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_Venue_PVT';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Venue_Base (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2,
   x_venue_id          OUT NOCOPY NUMBER
);

PROCEDURE Update_Venue_Base (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2
);

--       Check_Venue_Req_Items
PROCEDURE Check_Venue_Req_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Venue_UK_Items
PROCEDURE Check_Venue_UK_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Venue_FK_Items
PROCEDURE Check_Venue_FK_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Venue_Lookup_Items
PROCEDURE Check_Venue_Lookup_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Venue_Flag_Items
PROCEDURE Check_Venue_Flag_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

-------------------------------------
-----        VENUE           -----
-------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Venue
--
--------------------------------------------------------------------
PROCEDURE Create_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   x_venue_id          OUT NOCOPY NUMBER
)
IS

   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Venue';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_venue_rec          Venue_Rec_Type := p_venue_rec;

   -- l_location_rec         HZ_LOCATION_PUB.Location_Rec_Type;
   -- l_org_rec            HZ_Party_PUB.Organization_Rec_Type;
   -- l_psite_rec          HZ_Party_PUB.Party_Site_Rec_Type;

   l_location_rec         HZ_LOCATION_V2PUB.Location_Rec_Type;
   l_org_rec            HZ_Party_V2PUB.Organization_Rec_Type;
   l_psite_rec          HZ_Party_Site_V2PUB.Party_Site_Rec_Type;

   l_sales_team_rec     AS_ACCESS_PUB.sales_team_rec_type;

   l_return_status      VARCHAR2(1);

   l_location_id        NUMBER;
   l_party_id           NUMBER;

   l_party_site_id      NUMBER;
   l_party_number       VARCHAR2(30);
   l_party_site_number  VARCHAR2(30);
   l_profile_id         NUMBER;
   l_access_id          NUMBER;

-- start dhsingh
--   l_party_site_use_rec   HZ_PARTY_PUB.party_site_use_rec_type;
   l_party_site_use_rec   HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
   l_party_site_use_id   NUMBER;
   -- soagrawa
--   l_code_assignment_rec_type  HZ_CLASSIFICATION_PUB.code_assignment_rec_type;
   l_code_assignment_rec_type  HZ_CLASSIFICATION_V2PUB.code_assignment_rec_type;
   l_code_assignment_id  NUMBER;
-- end dhsingh

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Venue;

   IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   -- Only Validate name here for parties - everything else will be done in the base
   IF (l_venue_rec.venue_name is null)
   THEN
      AMS_Utility_PVT.error_message('AMS_VENUE_NO_VENUE_NAME');
      RAISE FND_API.g_exc_error;
   END IF;

   l_location_rec.address1 := l_venue_rec.address1;
   l_location_rec.address2 := l_venue_rec.address2;
   l_location_rec.address3 := l_venue_rec.address3;
   l_location_rec.address4 := l_venue_rec.address4;
   l_location_rec.city := l_venue_rec.city;
   l_location_rec.state := l_venue_rec.state;
   l_location_rec.postal_code := l_venue_rec.postal_code;
   --l_location_rec.province := l_venue_rec.province;
   --l_location_rec.county := l_venue_rec.county;
   l_location_rec.country := l_venue_rec.country_code;
   l_location_rec.ORIG_SYSTEM_REFERENCE := -1;
   l_location_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';
     l_location_rec.created_by_module := 'AMS_EVENT';

   HZ_LOCATION_V2PUB.Create_Location(
                                    p_init_msg_list     => p_init_msg_list
                                   , p_location_rec      => l_location_rec
                                   , x_return_status     => l_return_status
                                   , x_msg_count         => x_msg_count
                                   , x_msg_data          => x_msg_data
                                   , x_location_id       => l_location_id
                                  );
   -- GDEODHAR : Sept. 29, 2000 : Changed the p_commit to false in the above call.
   -- This was giving me the savepoint not established error if something (such as
   -- resource creation) failed below from here to the exception block.

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.Debug_Message('Location ID: ' || to_char(l_location_id));

   END IF;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   l_org_rec.organization_name := l_venue_rec.venue_name;
   l_org_rec.created_by_module := 'AMS_EVENT';
   l_venue_rec.venue_name := 'DUMMY'; -- want to be clear that venue_name does not have a real value for VENU

   HZ_Party_V2PUB.Create_Organization(
                                     p_init_msg_list    => p_init_msg_list
                                    , p_organization_rec => l_org_rec
                                    , x_return_status    => l_return_status
                                    , x_msg_count        => x_msg_count
                                    , x_msg_data         => x_msg_data
                                    , x_party_id         => l_party_id
                                    , x_party_number     => l_party_number
                                    , x_profile_id       => l_profile_id
                                   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.Debug_Message('Party ID: ' || to_char(l_party_id));

   END IF;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

-- dhsingh start
   l_code_assignment_rec_type.owner_table_name     := 'HZ_PARTIES';
   l_code_assignment_rec_type.owner_table_id       := l_party_id;
   l_code_assignment_rec_type.class_category       := 'BUSINESS_FUNCTION';
   l_code_assignment_rec_type.class_code           := 'EVENT_VENUE';
--  l_code_assignment_rec_type.created_by_module    := 'Oracle Marketing';
--   l_code_assignment_rec_type.application_id       := 530;
   l_code_assignment_rec_type.primary_flag         := 'Y';
   l_code_assignment_rec_type.start_date_active    := sysdate;
   l_code_assignment_rec_type.created_by_module    := 'AMS_EVENT';

   HZ_CLASSIFICATION_V2PUB.create_code_assignment(
                                                 p_init_msg_list    => p_init_msg_list
                                                , p_code_assignment_rec      => l_code_assignment_rec_type
                                                , x_return_status            => l_return_status
                                                , x_msg_count                => x_msg_count
                                                , x_msg_data                 => x_msg_data
                                                , x_code_assignment_id       => l_code_assignment_id
                                                             );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
-- end dhsingh
   l_psite_rec.party_id                 := l_party_id;
   l_psite_rec.location_id              := l_location_id;
   l_psite_rec.identifying_address_flag := 'Y';
   l_psite_rec.created_by_module := 'AMS_EVENT';
   -- psite_rec.status                   := 'A';
/*
   hz_party_pub.create_party_site(  p_api_version       => 1.0
                                  , p_init_msg_list     => p_init_msg_list
                                  , p_commit            => FND_API.g_false
                                  , p_party_site_rec    => l_psite_rec
                                  , x_return_status     => l_return_status
                                  , x_msg_count         => x_msg_count
                                  , x_msg_data          => x_msg_data
                                  , x_party_site_id     => l_party_site_id
                                  , x_party_site_number => l_party_site_number
                                  , p_validation_level  => p_validation_level
                                 );
*/

HZ_Party_Site_V2PUB.create_party_site(
                                  p_init_msg_list     => p_init_msg_list
                                 , p_party_site_rec    => l_psite_rec
                                  , x_return_status     => l_return_status
                                  , x_msg_count         => x_msg_count
                                  , x_msg_data          => x_msg_data
                                  , x_party_site_id     => l_party_site_id
                                  , x_party_site_number => l_party_site_number
                                       );


   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.Debug_Message('Party Site ID: ' || to_char(l_party_site_id));

   END IF;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

-- start dhsingh
   l_party_site_use_rec.party_site_id             := l_party_site_id ;
   l_party_site_use_rec.site_use_type             := 'VENUE' ;
   l_party_site_use_rec.created_by_module  := 'AMS_EVENT';
/*
   hz_party_pub.create_party_site_use(  p_api_version         => 1.0
                                      , p_init_msg_list       => p_init_msg_list
                                      , p_commit              => FND_API.G_false
                                      , p_party_site_use_rec  => l_party_site_use_rec
                                      , x_return_status       => l_return_status
                                      , x_msg_count           => x_msg_count
                                      , x_msg_data            => x_msg_data
                                      , x_party_site_use_id   => l_party_site_use_id
                                      , p_validation_level    =>p_validation_level
                                      );
*/

 hz_party_site_v2pub.create_party_site_use(
                                       p_init_msg_list       => p_init_msg_list
                                     , p_party_site_use_rec  => l_party_site_use_rec
                                      , x_return_status       => l_return_status
                                      , x_msg_count           => x_msg_count
                                      , x_msg_data            => x_msg_data
                                      , x_party_site_use_id   => l_party_site_use_id
                                        );
   AMS_Utility_PVT.Debug_Message('Party Site ID: ' || to_char(l_party_site_use_id));

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

-- end dhsingh

/*
   Removing this as unnecessary (see bug 2386818)
   IF (    (l_venue_rec.salesforce_id is not null)
--     AND (FND_PROFILE.value('AS_CUST_ACCESS') <> 'F')
      )
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.Debug_Message('Creating row in AS_ACCESSES_ALL');
      END IF;

      l_sales_team_rec.salesforce_id         := l_venue_rec.salesforce_id;
      l_sales_team_rec.customer_id           := l_party_id;
      l_sales_team_rec.sales_group_id        := l_venue_rec.sales_group_id;
      l_sales_team_rec.person_id             := l_venue_rec.person_id;
      l_sales_team_rec.address_id            := l_party_site_id;
      l_sales_team_rec.salesforce_role_code  := FND_PROFILE.value('AS_DEF_CUST_ST_ROLE');

      as_access_pub.create_salesteam(  p_api_version_number       => 2.0
                                     , p_init_msg_list            => p_init_msg_list
                                     , p_commit                   => FND_API.g_false
                                     , p_validation_level         => p_validation_level
                                     , p_access_profile_rec         => NULL
                                     , p_check_access_flag        => 'N'
                                     , p_admin_flag               => 'N'
                                     , p_admin_group_id           => NULL
                                     , p_identity_salesforce_id   => l_venue_rec.salesforce_id
                                     , p_sales_team_rec           => l_sales_team_rec
                                     , x_return_status            => l_return_status
                                     , x_msg_count                => x_msg_count
                                     , x_msg_data                 => x_msg_data
                                     , x_access_id                => l_access_id
                                    );

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.Debug_Message('Access ID: ' || to_char(l_access_id));

      END IF;

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF; -- Create row in AS_ACCESSES_ALL
*/

/*
   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          l_venue_rec.location_id := l_location_id;
   END IF;
*/
   l_venue_rec.party_id := l_party_id;

   Create_Venue_Base(  p_api_version => p_api_version
                     , p_init_msg_list => p_init_msg_list
                     , p_commit => p_commit
                     , p_validation_level => p_validation_level
                     , x_return_status => x_return_status
                     , x_msg_count => x_msg_count
                     , x_msg_data => x_msg_data
                     , p_venue_rec => l_venue_rec
                     , p_object_type => 'VENU'
                     , x_venue_id => x_venue_id
                    );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Create_Venue;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Room
--
--------------------------------------------------------------------
PROCEDURE Create_Room (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   x_venue_id          OUT NOCOPY NUMBER
)
IS

   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Room';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_return_status      VARCHAR2(1);

   l_venue_rec          Venue_Rec_Type := p_venue_rec;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Venue;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF l_venue_rec.venue_type_code IS NULL THEN
      l_venue_rec.venue_type_code := 'ROOM';
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   Create_Venue_Base(  p_api_version => p_api_version
                     , p_init_msg_list => p_init_msg_list
                     , p_commit => p_commit
                     , p_validation_level => p_validation_level
                     , x_return_status => x_return_status
                     , x_msg_count => x_msg_count
                     , x_msg_data => x_msg_data
                     , p_venue_rec => l_venue_rec
                     , p_object_type => 'ROOM'
                     , x_venue_id => x_venue_id
                    );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Create_Room;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Venue_Base
--
--------------------------------------------------------------------
PROCEDURE Create_Venue_Base (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2,
   x_venue_id          OUT NOCOPY NUMBER
)
IS

   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Venue_Base';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_venue_rec          Venue_Rec_Type := p_venue_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_location_id        NUMBER;
   --l_msg_count        NUMBER;

   l_category   VARCHAR2(30);
   l_source_id  NUMBER;
   x_resource_id NUMBER;
   x_resource_number VARCHAR2(30);
   l_date DATE;

   CURSOR c_seq IS
      SELECT ams_venues_b_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_venues_vl
                    WHERE  venue_id = x_id);

   CURSOR c_date IS
   SELECT sysdate
   FROM dual;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   Validate_Venue (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_venue_rec          => l_venue_rec,
      p_object_type        => p_object_type
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Check IDs');

   END IF;
   --
   -- Check for the ID.
   --
   IF l_venue_rec.venue_id IS NULL THEN
      LOOP
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_venue_rec.venue_id;
         CLOSE c_seq;

         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_venue_rec.venue_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Insert ' || p_object_type || ', ' || l_venue_rec.venue_id);
   END IF;

   --
   -- Insert into mutli-language supported table.
   --
   INSERT INTO ams_venues_b (
        VENUE_ID,
       CUSTOM_SETUP_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER,
       VENUE_TYPE_CODE,
       DIRECT_PHONE_FLAG,
       INTERNAL_FLAG,
       ENABLED_FLAG,
       RATING_CODE,
       TELECOM_CODE,
       CAPACITY,
       AREA_SIZE,
       AREA_SIZE_UOM_CODE,
       CEILING_HEIGHT,
       CEILING_HEIGHT_UOM_CODE,
       USAGE_COST,
       USAGE_COST_UOM_CODE,
       USAGE_COST_CURRENCY_CODE,
       PARENT_VENUE_ID,
       LOCATION_ID,
       DIRECTIONS,
       VENUE_CODE,
       OBJECT_TYPE,
       PARTY_ID,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15
   )
   VALUES (
      l_venue_rec.venue_id,
      l_venue_rec.custom_setup_id,

      -- standard who columns
      SYSDATE,
      FND_GLOBAL.User_Id,
      SYSDATE,
      FND_GLOBAL.User_Id,
      FND_GLOBAL.Conc_Login_Id,

         1,    -- object_version_number
      l_venue_rec.venue_type_code,
      NVL (l_venue_rec.direct_phone_flag, 'N'),   -- Default is 'N'
       NVL (l_venue_rec.internal_flag, 'Y'),   -- Default is 'Y'
       NVL (l_venue_rec.enabled_flag, 'Y'),   -- Default is 'Y'

      l_venue_rec.rating_code,
      l_venue_rec.telecom_code,
      l_venue_rec.capacity,
      l_venue_rec.area_size,
      l_venue_rec.area_size_uom_code,
      l_venue_rec.ceiling_height,
      l_venue_rec.ceiling_height_uom_code,
      l_venue_rec.usage_cost,
      l_venue_rec.usage_cost_uom_code,
      l_venue_rec.usage_cost_currency_code,
      l_venue_rec.parent_venue_id,
      l_venue_rec.location_id,
      l_venue_rec.directions,
      l_venue_rec.venue_code,
      p_object_type,
      l_venue_rec.party_id,
      l_venue_rec.attribute_category,
       l_venue_rec.attribute1,
       l_venue_rec.attribute2,
       l_venue_rec.attribute3,
       l_venue_rec.attribute4,
       l_venue_rec.attribute5,
       l_venue_rec.attribute6,
       l_venue_rec.attribute7,
       l_venue_rec.attribute8,
       l_venue_rec.attribute9,
       l_venue_rec.attribute10,
       l_venue_rec.attribute11,
       l_venue_rec.attribute12,
       l_venue_rec.attribute13,
       l_venue_rec.attribute14,
       l_venue_rec.attribute15
   );

   INSERT INTO ams_venues_tl (
       venue_id,
      language,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       source_lang,
      venue_name,
       description
   )
   SELECT   l_venue_rec.venue_id,
            l.language_code,
            -- standard who columns
            SYSDATE,
            FND_GLOBAL.User_Id,
            SYSDATE,
            FND_GLOBAL.User_Id,
            FND_GLOBAL.Conc_Login_Id,
            USERENV('LANG'),
            l_venue_rec.venue_name,
            l_venue_rec.description
     FROM     fnd_languages l
     WHERE    l.installed_flag IN ('I', 'B')
     AND NOT EXISTS (SELECT  NULL
                    FROM    ams_venues_tl t
                    WHERE   t.venue_id = l_venue_rec.venue_id
                    AND     t.language = l.language_code);

   ------------------------- finish -------------------------------
   -- set OUT value
   x_venue_id := l_venue_rec.venue_id;
-- modified sugupta 9/11/2000
----------------- creare resource from recently created venue id--------
--- for now since AMS owns Venues, it will create a resource id whenever a new venue id is
-- created. However, AMS sjould own responsibility to take care of its data in jtf_rs_resources_extn
-- table. RCSINGH has guaranteed they do not delete or mess with data in this table.
-- the resource will of the category 'VENUES', a new JTF object has been craeted in jtf objects
-- for the purpose.
   l_category := 'VENUE';
   l_source_id := l_venue_rec.venue_id;

   OPEN c_date;
    FETCH c_date INTO l_date;
    CLOSE c_date;

   JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
      P_API_VERSION => 1.0,
      P_INIT_MSG_LIST =>    p_init_msg_list,
      P_COMMIT =>  FND_API.g_false,
      P_CATEGORY => l_category,
      p_source_id => l_source_id,
      P_START_DATE_ACTIVE => l_date,
      P_RESOURCE_NAME => l_venue_rec.venue_name,
      P_SOURCE_NAME => l_venue_rec.venue_name,
      X_RETURN_STATUS => l_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_resource_id => x_resource_id,
      x_resource_number => x_resource_number
      );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


-- GDEODHAR : Sept. 29, 2000 : Changed the p_commit to false in the above call.
-- It could give the savepoint not established error if something (if we add
-- something after this call and before commit) fails from below here to the
-- exception block.


        --
        -- END of API body.
        --

        -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   --IF (AMS_DEBUG_HIGH_ON) THEN AMS_Utility_PVT.debug_message (l_full_name || ': End');END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_Venue_Base;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Venue
--
--------------------------------------------------------------------
PROCEDURE Update_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type
)
IS

   CURSOR c_location(ven_id IN NUMBER) IS
      SELECT   loc.address1, loc.address2, loc.city, loc.state, loc.country
      FROM     hz_parties loc, ams_venues_vl ven
      WHERE    loc.party_id = ven.party_id
     and      ven.venue_id = ven_id;

--   l_location_rec   HZ_LOCATION_PUB.Location_Rec_Type;
   l_location_rec   HZ_LOCATION_V2PUB.Location_Rec_Type;
   l_location_id        NUMBER;
   l_address1    VARCHAR2(240);
   l_address2    VARCHAR2(240);
   l_city       VARCHAR2(60);
   l_state       VARCHAR2(60);
   l_country    VARCHAR2(60);

   --l_psite_rec          HZ_Party_PUB.Party_Site_Rec_Type;
   l_psite_rec          HZ_Party_Site_V2PUB.Party_Site_Rec_Type;
   l_party_site_id      NUMBER;
   l_party_site_number  VARCHAR2(30);

   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Venue';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_venue_rec          Venue_Rec_Type;
   l_return_status      VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Update_Venue;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
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

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
 -- 07/10/2000 IMPORTANT THING TO NOTE ABOUT UPDATE VENUES
 -- THE WAY SCREEN GOT DESIGNED... DONT BLAME ME.... p_venue_rec NOT
 -- INITILIZED TO FND_API.G_MISS_CHAR'S... FROM ONE OF THE VENUE SCREENS- AMSVENCR.JSP
 -- WE DONT LOSE ANY INFO BECAUSE THAT SCREEN IS SAME FOR CREATE AND UPDATE..
 -- ALL INFO FOR VENUE IS ALWAYS PASSED..

 -- At this point the p_venue_rec has all the data sent from the outside world
 -- such as the JSP page.

   Complete_Venue_Rec (p_venue_rec, l_venue_rec);
 -- CHECK FOR WHETHER NEW LOCATION NEEDS TO BE CREATED
      OPEN c_location(l_venue_rec.venue_id);
      FETCH c_location INTO l_address1, l_address2, l_city, l_state, l_country;
      IF c_location%NOTFOUND THEN
        CLOSE c_location;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_location;
/*

-- by musman 04-Sep-2002
-- Commenting out the creation of HZ_locations and HZ_party_sites since we
-- are not allowing the user to update the country,address ,city or state through the screen

     IF (l_venue_rec.address1 <> l_address1 OR
       l_venue_rec.address2 <> l_address2 OR
      l_venue_rec.city <> l_city OR
      l_venue_rec.state <> l_state OR
      l_venue_rec.country <> l_country) THEN

  The values on RHS / LHS or both can be NULL, You cannot compare NULL
  with NULL. murali 11/13/2000
-- *
      IF (nvl(l_venue_rec.address1, ' ') <> nvl(l_address1, ' ') OR
        nvl(l_venue_rec.address2, ' ') <> nvl(l_address2, ' ') OR
        nvl(l_venue_rec.city, ' ') <> nvl(l_city, ' ') OR
        nvl(l_venue_rec.state, ' ') <> nvl(l_state, ' ') OR
          nvl(l_venue_rec.country_code, ' ') <> nvl(l_country, ' ')) THEN

      l_location_rec.address1 := l_venue_rec.address1;
      l_location_rec.address2 := l_venue_rec.address2;
      --l_location_rec.address3 := l_venue_rec.address3;
      --l_location_rec.address4 := l_venue_rec.address4;
      l_location_rec.city := l_venue_rec.city;
      l_location_rec.state := l_venue_rec.state;
      l_location_rec.postal_code := l_venue_rec.postal_code;
      --l_location_rec.province := l_venue_rec.province;
      --l_location_rec.county := l_venue_rec.county;
      l_location_rec.country := l_venue_rec.country_code;
      l_location_rec.ORIG_SYSTEM_REFERENCE := -1;
      l_location_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';
      l_location_rec.created_by_module := 'AMS_EVENT';

      HZ_LOCATION_V2PUB.Create_Location(
         p_init_msg_list   => p_init_msg_list,
         p_location_rec      => l_location_rec,
         x_return_status   => l_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data      => x_msg_data,
         x_location_id      => l_location_id
            );

-- Changed the commit flag to false for the above call.
-- This could potentially give the savepoint not established error.
-- Refer to the create procedure for more details.

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_psite_rec.party_id                 := l_venue_rec.party_id;
      l_psite_rec.location_id              := l_location_id;
      l_psite_rec.identifying_address_flag := 'Y';
      l_psite_rec.created_by_module := 'AMS_EVENT';
      -- psite_rec.status                   := 'A';

    hz_party_site_v2pub.create_party_site(
                                      p_init_msg_list     => p_init_msg_list
                                     , p_party_site_rec    => l_psite_rec
                                     , x_return_status     => l_return_status
                                     , x_msg_count         => x_msg_count
                                     , x_msg_data          => x_msg_data
                                     , x_party_site_id     => l_party_site_id
                                     , x_party_site_number => l_party_site_number
                                       );

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.Debug_Message('Party Site ID: ' || to_char(l_party_site_id));

      END IF;

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF; --check for addr1, city, state, country
*/

   Update_Venue_Base(  p_api_version => p_api_version
                     , p_init_msg_list => p_init_msg_list
                     , p_commit => p_commit
                     , p_validation_level => p_validation_level
                     , x_return_status => x_return_status
                     , x_msg_count => x_msg_count
                     , x_msg_data => x_msg_data
                     , p_venue_rec => l_venue_rec
                     , p_object_type => 'VENU'
                    );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Update_Venue;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Room
--
--------------------------------------------------------------------
PROCEDURE Update_Room (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Room';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_venue_rec          Venue_Rec_Type;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Update_Venue;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
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

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
 -- 07/10/2000 IMPORTANT THING TO NOTE ABOUT UPDATE VENUES
 -- THE WAY SCREEN GOT DESIGNED... DONT BLAME ME.... p_venue_rec NOT
 -- INITILIZED TO FND_API.G_MISS_CHAR'S... FROM ONE OF THE VENUE SCREENS- AMSVENCR.JSP
 -- WE DONT LOSE ANY INFO BECAUSE THAT SCREEN IS SAME FOR CREATE AND UPDATE..
 -- ALL INFO FOR VENUE IS ALWAYS PASSED..

 -- At this point the p_venue_rec has all the data sent from the outside world
 -- such as the JSP page.

   Complete_Venue_Rec (p_venue_rec, l_venue_rec);

   Update_Venue_Base(  p_api_version => p_api_version
                     , p_init_msg_list => p_init_msg_list
                     , p_commit => p_commit
                     , p_validation_level => p_validation_level
                     , x_return_status => x_return_status
                     , x_msg_count => x_msg_count
                     , x_msg_data => x_msg_data
                     , p_venue_rec => l_venue_rec
                     , p_object_type => 'ROOM'
                    );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Update_Room;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Venue_Base
--
--   07/10/2000 modified sugupta   added code to create new loc id if
--                           address, city, state or country is changed
--------------------------------------------------------------------
PROCEDURE Update_Venue_Base (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2
)
IS
/*
   CURSOR c_location(ven_id IN NUMBER) IS
      SELECT   loc.address1, loc.address2, loc.city, loc.state, loc.country
      FROM     hz_locations loc, ams_venues_vl ven
      WHERE    loc.location_id = ven.location_id
     and      ven.venue_id = ven_id;
--   l_location_rec   HZ_LOCATION_PUB.Location_Rec_Type;
   l_location_rec   HZ_LOCATION_V2PUB.Location_Rec_Type;
   l_location_id        NUMBER;
   l_address1    VARCHAR2(240);
   l_address2    VARCHAR2(240);
   l_city       VARCHAR2(60);
   l_state       VARCHAR2(60);
   l_country    VARCHAR2(60);
*/
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Venue_Base';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_venue_rec          Venue_Rec_Type;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_rec_cnt            NUMBER;
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

    l_venue_rec := p_venue_rec;

 -- At this point the l_venue_rec has all the data that came from outside and all
 -- the other fields will have the old data. So all the fields will be available
 -- for the upcoming update call.


/* -- batoleti
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Venue_Items (
         p_venue_rec          => p_venue_rec,
         p_object_type        => p_object_type,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Venue_Record (
         p_venue_rec       => p_venue_rec,
         p_complete_rec    => l_venue_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
*/ -- batoleti
--batoleti
l_rec_cnt := 0;

SELECT count(*)
INTO l_rec_cnt
FROM ams_venues_tl
where venue_id <> l_venue_rec.venue_id
and   venue_name = l_venue_rec.venue_name
and   SOURCE_LANG = USERENV('LANG');

IF (l_rec_cnt > 0) THEN
  FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_DUP_NAME');
  FND_MSG_PUB.add;
  RAISE FND_API.g_exc_error;
END IF;



   --batoleti
   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Update');
   END IF;

   UPDATE ams_venues_b
   SET
   last_update_date        = SYSDATE,
   last_updated_by          = FND_GLOBAL.User_Id,
   last_update_login       = FND_GLOBAL.Conc_Login_Id,

   object_version_number   = object_version_number + 1,
        venue_type_code           = l_venue_rec.venue_type_code,
   custom_setup_id = l_venue_rec.custom_setup_id,
   direct_phone_flag       = NVL (l_venue_rec.direct_phone_flag, 'N'),
   internal_flag      = NVL (l_venue_rec.internal_flag, 'Y'),
   enabled_flag      = NVL (l_venue_rec.enabled_flag, 'Y'),
        rating_code             = l_venue_rec.rating_code,
        capacity                = l_venue_rec.capacity,
        area_size      = l_venue_rec.area_size,
   area_size_uom_code   = l_venue_rec.area_size_uom_code,
   ceiling_height      = l_venue_rec.ceiling_height,
   ceiling_height_uom_code   = l_venue_rec.ceiling_height_uom_code,
   usage_cost      = l_venue_rec.usage_cost,
   usage_cost_uom_code   = l_venue_rec.usage_cost_uom_code,
   usage_cost_currency_code = l_venue_rec.usage_cost_currency_code,
   parent_venue_id      = l_venue_rec.parent_venue_id,
   location_id      = l_venue_rec.location_id,
   directions      = l_venue_rec.directions,
   venue_code      = l_venue_rec.venue_code,
   telecom_code    = l_venue_rec.telecom_code, -- Added Bug 4083293
   attribute_category      = l_venue_rec.attribute_category,
   attribute1       = l_venue_rec.attribute1,
   attribute2       = l_venue_rec.attribute2,
   attribute3       = l_venue_rec.attribute3,
   attribute4       = l_venue_rec.attribute4,
   attribute5       = l_venue_rec.attribute5,
   attribute6       = l_venue_rec.attribute6,
   attribute7       = l_venue_rec.attribute7,
   attribute8       = l_venue_rec.attribute8,
   attribute9       = l_venue_rec.attribute9,
   attribute10       = l_venue_rec.attribute10,
   attribute11       = l_venue_rec.attribute11,
   attribute12       = l_venue_rec.attribute12,
   attribute13       = l_venue_rec.attribute13,
   attribute14       = l_venue_rec.attribute14,
   attribute15       = l_venue_rec.attribute15
   WHERE   venue_id = l_venue_rec.venue_id
     AND   object_version_number = l_venue_rec.object_version_number;
-- GDEODHAR : Sept 29, 2000 : Added the AND condition.

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   UPDATE ams_venues_tl
   SET
      last_update_date    = SYSDATE,
      last_updated_by    = FND_GLOBAL.User_Id,
      last_update_login    = FND_GLOBAL.Conc_Login_Id,
                source_lang          = USERENV('LANG'),
      venue_name         = l_venue_rec.venue_name,
          description       = l_venue_rec.description
     WHERE venue_id = l_venue_rec.venue_id
     AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Venue_Base;


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Venue
--
--------------------------------------------------------------------
PROCEDURE Delete_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Venue';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Venue;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Delete');
   END IF;

   -- Delete TL data
   DELETE FROM ams_venues_tl
   WHERE  venue_id = p_venue_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   DELETE FROM ams_venues_b
   WHERE  venue_id = p_venue_id
   AND    object_version_number = p_object_version;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Venue;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Venue;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_Venue;


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Venue
--
--------------------------------------------------------------------
PROCEDURE Lock_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Venue';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dummy        NUMBER;     -- Used by the lock cursor.

   --
   -- NOTE: Not necessary to distinguish between a record
   -- which does not exist and one which has been updated
   -- by another user.  To get that distinction, remove
   -- the object_version condition from the SQL statement
   -- and perform comparison in the body and raise the
   -- exception there.
   CURSOR c_lock IS
      SELECT object_version_number
      FROM   ams_venues_vl
      WHERE  venue_id = p_venue_id
      AND    object_version_number = p_object_version
      FOR UPDATE NOWAIT;
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Lock');
   END IF;

   OPEN c_lock;
   FETCH c_lock INTO l_dummy;
   IF (c_lock%NOTFOUND) THEN
      CLOSE c_lock;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lock;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RESOURCE_LOCKED');
         FND_MSG_PUB.add;
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Lock_Venue;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Venue
--
--------------------------------------------------------------------
PROCEDURE Validate_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Venue';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message (l_full_name || ': Check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Venue_Items (
         p_venue_rec          => p_venue_rec,
         p_object_type        => p_object_type,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': Check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Venue_Record (
         p_venue_rec       => p_venue_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Venue;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Venue_Items
-- HISTORY:
-- 09 May 2003   dbiswas  Added checks for length of the ceiling height and capacity
---------------------------------------------------------------------
PROCEDURE Check_Venue_Items (
   p_venue_rec       IN  Venue_Rec_Type,
   p_object_type     IN  VARCHAR2,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_Venue_Req_Items (
      p_venue_rec       => p_venue_rec,
      p_object_type     => p_object_type,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Venue_FK_Items(
      p_venue_rec       => p_venue_rec,
      p_object_type     => p_object_type,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.
   Check_Venue_UK_Items (
      p_venue_rec          => p_venue_rec,
      p_object_type        => p_object_type,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Venue_Lookup_Items (
      p_venue_rec          => p_venue_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Venue_Flag_Items(
      p_venue_rec       => p_venue_rec,
      x_return_status   => x_return_status
   );

   IF(p_venue_rec.usage_cost < 0)
   THEN
       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
       THEN
          Fnd_Message.set_name('AMS', 'AMS_USAGE_COST_NEG');
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

   IF(p_venue_rec.capacity < 0)
   THEN
       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
       THEN
          Fnd_Message.set_name('AMS', 'AMS_CAPACITY_NEG');
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

   IF(p_venue_rec.ceiling_height < 0)
   THEN
       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
       THEN
          Fnd_Message.set_name('AMS', 'AMS_CEILING_HEIGHT_NEG');
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

  /* dbiswas added the following two conditions to check that no more than 15 chars are inserted for
     ceiling height and capacity on May 9, 2003 for bug 2950429 */

   IF(length(p_venue_rec.ceiling_height) > 15)
   THEN
       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
       THEN
          Fnd_Message.set_name('AMS', 'AMS_OVERSIZE_CEILING_HEIGHT');
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

   IF(length(p_venue_rec.capacity) > 15)
   THEN
       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
       THEN
          Fnd_Message.set_name('AMS', 'AMS_OVERSIZE_CAPACITY');
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

   /* end update by dbiswas on May 9, 2003 */

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_Venue_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Venue_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_venue_rec: the record to be validated; may contain attributes
--    as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Venue_Record (
   p_venue_rec        IN  Venue_Rec_Type,
   p_complete_rec     IN  Venue_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Currently, no business rule for record
   -- level validation.
   x_return_status := FND_API.g_ret_sts_success;
END Check_Venue_Record;

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Venue_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_Venue_Rec (
   x_venue_rec         OUT NOCOPY  Venue_Rec_Type
)
IS
BEGIN
   x_venue_rec.venue_id := FND_API.g_miss_num;
   x_venue_rec.custom_setup_id := FND_API.g_miss_num;
   x_venue_rec.last_update_date := FND_API.g_miss_date;
   x_venue_rec.last_updated_by := FND_API.g_miss_num;
   x_venue_rec.creation_date := FND_API.g_miss_date;
   x_venue_rec.created_by := FND_API.g_miss_num;
   x_venue_rec.last_update_login := FND_API.g_miss_num;
   x_venue_rec.object_version_number := FND_API.g_miss_num;
   x_venue_rec.venue_type_code := FND_API.g_miss_char;
   x_venue_rec.direct_phone_flag := FND_API.g_miss_char;
   x_venue_rec.internal_flag := FND_API.g_miss_char;
   x_venue_rec.enabled_flag := FND_API.g_miss_char;
   x_venue_rec.rating_code := FND_API.g_miss_char;
   x_venue_rec.telecom_code := FND_API.g_miss_char;
   x_venue_rec.capacity := FND_API.g_miss_num;
   x_venue_rec.area_size := FND_API.g_miss_num;
   x_venue_rec.area_size_uom_code := FND_API.g_miss_char;
   x_venue_rec.ceiling_height := FND_API.g_miss_num;
   x_venue_rec.ceiling_height_uom_code := FND_API.g_miss_char;
   x_venue_rec.usage_cost := FND_API.g_miss_num;
   x_venue_rec.usage_cost_uom_code := FND_API.g_miss_char;
   x_venue_rec.usage_cost_currency_code := FND_API.g_miss_char;
   x_venue_rec.parent_venue_id := FND_API.g_miss_num;
   x_venue_rec.location_id := FND_API.g_miss_num;
   x_venue_rec.directions := FND_API.g_miss_char;
   x_venue_rec.venue_code := FND_API.g_miss_char;
   x_venue_rec.object_type := FND_API.g_miss_char;
   x_venue_rec.party_id := FND_API.g_miss_num;
   x_venue_rec.attribute_category := FND_API.g_miss_char;
   x_venue_rec.attribute1 := FND_API.g_miss_char;
   x_venue_rec.attribute2 := FND_API.g_miss_char;
   x_venue_rec.attribute3 := FND_API.g_miss_char;
   x_venue_rec.attribute4 := FND_API.g_miss_char;
   x_venue_rec.attribute5 := FND_API.g_miss_char;
   x_venue_rec.attribute6 := FND_API.g_miss_char;
   x_venue_rec.attribute7 := FND_API.g_miss_char;
   x_venue_rec.attribute8 := FND_API.g_miss_char;
   x_venue_rec.attribute9 := FND_API.g_miss_char;
   x_venue_rec.attribute10 := FND_API.g_miss_char;
   x_venue_rec.attribute11 := FND_API.g_miss_char;
   x_venue_rec.attribute12 := FND_API.g_miss_char;
   x_venue_rec.attribute13 := FND_API.g_miss_char;
   x_venue_rec.attribute14 := FND_API.g_miss_char;
   x_venue_rec.attribute15 := FND_API.g_miss_char;
   x_venue_rec.venue_name := FND_API.g_miss_char;
   x_venue_rec.description := FND_API.g_miss_char;
END Init_Venue_Rec;



---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Venue_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Venue_Rec (
   p_venue_rec      IN  Venue_Rec_Type,
   x_complete_rec   OUT NOCOPY Venue_Rec_Type
)
IS
   CURSOR c_venue (id_in IN NUMBER) IS
      SELECT   *
      FROM     ams_venues_vl
      WHERE    venue_id = id_in;

   CURSOR c_location(p_party_id IN NUMBER) IS
      SELECT   address1, address2, city, state, country
      FROM     hz_parties
      WHERE    party_id = p_party_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_venue_rec    c_venue%ROWTYPE;
   l_address1    VARCHAR2(240);
   l_address2    VARCHAR2(240);
   l_city       VARCHAR2(60);
   l_state       VARCHAR2(60);
   l_country    VARCHAR2(60);
BEGIN
   x_complete_rec := p_venue_rec;

   OPEN c_venue(p_venue_rec.venue_id);
   FETCH c_venue INTO l_venue_rec;
   IF c_venue%NOTFOUND THEN
      CLOSE c_venue;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_venue;

   IF l_venue_rec.party_id IS NOT NULL THEN
      OPEN c_location(l_venue_rec.party_id);
      FETCH c_location INTO l_address1, l_address2, l_city, l_state, l_country;
      IF c_location%NOTFOUND THEN
        CLOSE c_location;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_location;
   END IF;

   --
   -- venue_type_code
   IF p_venue_rec.venue_type_code = FND_API.g_miss_char THEN
      x_complete_rec.venue_type_code := l_venue_rec.venue_type_code;
   END IF;

   --
   -- custom_setup_id
   IF p_venue_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_venue_rec.custom_setup_id;
   END IF;

   --
   -- INTERNAL_FLAG
   IF p_venue_rec.internal_flag = FND_API.g_miss_char THEN
      x_complete_rec.internal_flag := l_venue_rec.internal_flag;
   END IF;

   --
   -- DIRECT_PHONE_FLAG
   IF p_venue_rec.direct_phone_flag = FND_API.g_miss_char THEN
      x_complete_rec.direct_phone_flag := l_venue_rec.direct_phone_flag;
   END IF;

   --
   -- ENABLED_FLAG
   IF p_venue_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_venue_rec.enabled_flag;
   END IF;

   --
   --RATING_CODE
   IF p_venue_rec.rating_code = FND_API.g_miss_char THEN
      x_complete_rec.rating_code := l_venue_rec.rating_code;
   END IF;

   --
   --TELECOM_CODE
   IF p_venue_rec.telecom_code = FND_API.g_miss_char THEN
      x_complete_rec.telecom_code := l_venue_rec.telecom_code;
   END IF;

   --
   --CAPACITY
   IF p_venue_rec.capacity = FND_API.g_miss_num THEN
      x_complete_rec.capacity := l_venue_rec.capacity;
   END IF;

   --
   --AREA_SIZE
   IF p_venue_rec.area_size = FND_API.g_miss_num THEN
      x_complete_rec.area_size := l_venue_rec.area_size;
   END IF;

   --
   --AREA_SIZE_UOM_CODE
   IF p_venue_rec.area_size_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.area_size_uom_code := l_venue_rec.area_size_uom_code;
   END IF;

   --
   -- CEILING_HEIGHT
   IF p_venue_rec.ceiling_height = FND_API.g_miss_num THEN
      x_complete_rec.ceiling_height := l_venue_rec.ceiling_height;
   END IF;

   --
   --CEILING_HEIGHT_UOM_CODE
   IF p_venue_rec.ceiling_height_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.ceiling_height_uom_code := l_venue_rec.ceiling_height_uom_code;
   END IF;

   --
   --USAGE_COST
   IF p_venue_rec.usage_cost = FND_API.g_miss_num THEN
      x_complete_rec.usage_cost := l_venue_rec.usage_cost;
   END IF;

   --
   --USAGE_COST_UOM_CODE
   IF p_venue_rec.usage_cost_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.usage_cost_uom_code := l_venue_rec.usage_cost_uom_code;
   END IF;
   --
   --USAGE_COST_CURRENCY_CODE
   IF p_venue_rec.usage_cost_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.usage_cost_currency_code := l_venue_rec.usage_cost_currency_code;
   END IF;

   --
   --PARENT_VENUE_ID
   IF p_venue_rec.parent_venue_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_venue_id := l_venue_rec.parent_venue_id;
   END IF;

   --
   --DIRECTIONS
   IF p_venue_rec.directions = FND_API.g_miss_char THEN
      x_complete_rec.directions := l_venue_rec.directions;
   END IF;

   --
   --VENUE_CODE
   IF p_venue_rec.venue_code = FND_API.g_miss_char THEN
      x_complete_rec.venue_code := l_venue_rec.venue_code;
   END IF;

   --
   --OBJECT_TYPE
   IF p_venue_rec.object_type = FND_API.g_miss_char THEN
      x_complete_rec.object_type := l_venue_rec.object_type;
   END IF;

   --
   -- ATTRIBUTE_CATEGORY
   IF p_venue_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_venue_rec.attribute_category;
   END IF;

   --
   -- ATTRIBUTE1
   IF p_venue_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_venue_rec.attribute1;
   END IF;

   --
   -- ATTRIBUTE2
   IF p_venue_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_venue_rec.attribute2;
   END IF;

   --
   -- ATTRIBUTE3
   IF p_venue_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_venue_rec.attribute3;
   END IF;

   --
   -- ATTRIBUTE4
   IF p_venue_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_venue_rec.attribute4;
   END IF;

   --
   -- ATTRIBUTE5
   IF p_venue_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_venue_rec.attribute5;
   END IF;

   --
   -- ATTRIBUTE6
   IF p_venue_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_venue_rec.attribute6;
   END IF;

   --
   -- ATTRIBUTE7
   IF p_venue_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_venue_rec.attribute7;
   END IF;

   --
   -- ATTRIBUTE8
   IF p_venue_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_venue_rec.attribute8;
   END IF;

   --
   -- ATTRIBUTE9
   IF p_venue_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_venue_rec.attribute9;
   END IF;

   --
   -- ATTRIBUTE10
   IF p_venue_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_venue_rec.attribute10;
   END IF;

   --
   -- ATTRIBUTE11
   IF p_venue_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_venue_rec.attribute11;
   END IF;

   --
   -- ATTRIBUTE12
   IF p_venue_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_venue_rec.attribute12;
   END IF;

   --
   -- ATTRIBUTE13
   IF p_venue_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_venue_rec.attribute13;
   END IF;

   --
   -- ATTRIBUTE14
   IF p_venue_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_venue_rec.attribute14;
   END IF;

   --
   -- ATTRIBUTE15
   IF p_venue_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_venue_rec.attribute15;
   END IF;

   --
   -- VENUE_NAME
   IF p_venue_rec.venue_name = FND_API.g_miss_char THEN
      x_complete_rec.venue_name := l_venue_rec.venue_name;
   END IF;

   --
   -- DESCRIPTION
   IF p_venue_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_venue_rec.description;
   END IF;

   -- modified sugupta 07/10/2000 added completion for city, state, country and address
   IF p_venue_rec.address1 = FND_API.g_miss_char THEN
      x_complete_rec.address1 := l_address1;
   END IF;
   IF p_venue_rec.address2 = FND_API.g_miss_char THEN
      x_complete_rec.address2 := l_address2;
   END IF;
   IF p_venue_rec.city = FND_API.g_miss_char THEN
      x_complete_rec.city := l_city;
   END IF;
   IF p_venue_rec.state = FND_API.g_miss_char THEN
      x_complete_rec.state := l_state;
   END IF;
   IF p_venue_rec.country = FND_API.g_miss_char THEN
      x_complete_rec.country := l_country;
   END IF;

   -- GDEODHAR : Sept. 29, 2000. Noticed that the complete rec does not complete
   -- the location id. This causes the update of location id with g_miss_num and
   -- gives rise to bugs. Added the following :

   --
   --LOCATION_ID
   IF p_venue_rec.location_id = FND_API.g_miss_num THEN
      x_complete_rec.location_id := l_venue_rec.location_id;
   END IF;

   --
   -- PARTY_ID
   IF p_venue_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := l_venue_rec.party_id;
   END IF;

END Complete_Venue_Rec;


--       Check_Venue_Req_Items
PROCEDURE Check_Venue_Req_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN

   -- venue_type_code
   IF (    (p_object_type <> 'ROOM')
       AND (p_venue_rec.venue_type_code IS NULL)
      )
   THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_NO_VENUE_TYPE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- VENUE_NAME
   IF (    (p_object_type = 'ROOM')
       AND (p_venue_rec.venue_name IS NULL)
      )
   THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_NO_VENUE_NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- PARENT_VENUE_ID (For Rooms Only)
   IF (    (p_object_type = 'ROOM')
       AND (p_venue_rec.parent_venue_id IS NULL)
      )
   THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_NO_PARENT_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


END Check_Venue_Req_Items;

--       Check_Venue_UK_Items
PROCEDURE Check_Venue_UK_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
   l_dummy NUMBER;
   /*
   cursor c_vnu_name(vnu_name_in IN VARCHAR2) IS
   SELECT 1 FROM DUAL WHERE EXISTS (select 1 from ams_venues_vl
          where VENUE_NAME = vnu_name_in);
   */
   cursor c_room_name(room_name_in IN VARCHAR2, venue_id_in IN NUMBER) IS
   SELECT 1 FROM DUAL WHERE EXISTS (select 1 from ams_venues_vl
          where VENUE_NAME = room_name_in and parent_venue_id = venue_id_in);
/*
   cursor c_vnu_name_up(vnu_name_in IN VARCHAR2, vnu_id_in in NUMBER) IS
   SELECT 1 FROM DUAL WHERE EXISTS (select 1 from ams_venues_vl
          where VENUE_NAME = vnu_name_in
          and  VENUE_ID = vnu_id_in);
 */
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- VENUE_ID
   -- For Create_Venue, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_venue_rec.venue_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_venues_vl',
            'venue_id = ' || p_venue_rec.venue_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_DUP_VENUE_ID');
            FND_MSG_PUB.add;

         END IF;
         x_return_status := FND_API.g_ret_sts_error;

         RETURN;
      END IF;
   END IF;

   -- VENUE_NAME
   /*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      open c_vnu_name_crt(p_venue_rec.venue_name);
      fetch c_vnu_name_crt into l_dummy;
      close c_vnu_name_crt;
    bug # 1490374
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         'ams_venues_vl',
         'venue_name = ''' || p_venue_rec.venue_name || ''''
      );

   ELSE
      open c_vnu_name_up(p_venue_rec.venue_name,p_venue_rec.venue_id);
      fetch c_vnu_name_up into l_dummy;
      close c_vnu_name_up;
    bug # 1490374
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         'ams_venues_vl',
         'venue_name = ''' || p_venue_rec.venue_name ||
            ''' AND venue_id <> ' || p_venue_rec.venue_id
      );

   END IF;
   */

   /* FIX FOR BUG #1625651 DO THE FOLLOWING BLOCK FOR CREATE */
   IF (    (p_validation_mode = JTF_PLSQL_API.g_create OR  p_validation_mode = JTF_PLSQL_API.g_update )
       AND (p_object_type = 'ROOM')
      )
   THEN

      open c_room_name(p_venue_rec.venue_name, p_venue_rec.parent_venue_id);
      fetch c_room_name into l_dummy;
      close c_room_name;
      /*
         open c_vnu_name(p_venue_rec.venue_name);
         fetch c_vnu_name into l_dummy;
         close c_vnu_name;
      */
       IF l_dummy = 1 THEN
      --IF l_valid_flag = FND_API.g_false THEN bug # 1490374

        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_DUP_NAME');
           FND_MSG_PUB.add;


        END IF;
        x_return_status := FND_API.g_ret_sts_error;

        RETURN;
     END IF;
   END IF;

END Check_Venue_UK_Items;

--       Check_Venue_FK_Items
PROCEDURE Check_Venue_FK_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   p_object_type     IN    VARCHAR2,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
--
-- Check for the Locations FK
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

----------------------- venue party_id ------------------------
   IF nvl(p_object_type, 'VENU') <> 'ROOM' THEN
      IF p_venue_rec.location_id <> FND_API.g_miss_num THEN
         IF AMS_Utility_PVT.check_fk_exists(
               'hz_parties',
               'party_id',
               p_venue_rec.party_id
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_VENUE_BAD_LOCATION_ID');
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   ELSE
      IF p_venue_rec.parent_venue_id <> FND_API.g_miss_num THEN
         IF AMS_Utility_PVT.check_fk_exists(
               'ams_venues_b',
               'venue_id',
               p_venue_rec.parent_venue_id
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_ROOM_BAD_PARENT_VENUE');
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

   END IF;

 /*
 --------------------- currency_code_fc ------------------------
   IF p_evh_rec.currency_code_fc <> FND_API.g_miss_char
      AND p_evh_rec.currency_code_fc IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_currencies_vl',
            'currency_code',
            p_evh_rec.currency_code_fc,
       AMS_Utility_PVT.g_varchar2
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_CURRENCY_CODE_FC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

*/
END Check_Venue_FK_Items;

--       Check_Venue_Lookup_Items
PROCEDURE Check_Venue_Lookup_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   L_VENUE_TYPE          CONSTANT VARCHAR(30) := 'AMS_VENUE_TYPE';
   L_AREA_SIZE_UOM_CODE    CONSTANT VARCHAR(30) := 'AMS_VENUE_AREA_SIZE_UOM_CODE';
   L_USAGE_COST_CURRENCY_CODE   CONSTANT VARCHAR(30) := 'AMS_USAGE_COST_CURRENCY_CODE';
   L_CEILING_HEIGHT_UOM_CODE   CONSTANT VARCHAR(30) := 'AMS_CEILING_HEIGHT_UOM_CODE';
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

 /*  --
   -- VENUE_TYPE_CODE
   IF p_venue_rec.venue_type_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => L_VENUE_TYPE,
            p_lookup_code => p_venue_rec.venue_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_VENUE_TYPE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/

 /*
  --
   -- AREA_SIZE_UOM_CODE
   IF p_venue_rec.area_size_uom_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => L_AREA_SIZE_UOM_CODE,
            p_lookup_code => p_venue_rec.area_size_uom_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_AREA_SIZE_UOM_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;



   --
   -- CEILING_HEIGHT_UOM_CODE
   IF p_venue_rec.ceiling_height_uom_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => L_CEILING_HEIGHT_UOM_CODE,
            p_lookup_code => p_venue_rec.ceiling_height_uom_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_CEILING_HEIGHT_UOM_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- USAGE_COST_CURRENCY_CODE
   IF p_venue_rec.usage_cost_currency_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => L_USAGE_COST_CURRENCY_CODE,
            p_lookup_code => p_venue_rec.usage_cost_currency_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_USAGE_COST_CURRENCY_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

*/

END Check_Venue_Lookup_Items;



--       Check_Venue_Flag_Items
PROCEDURE Check_Venue_Flag_Items (
   p_venue_rec       IN    Venue_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- INTERNAL_FLAG
   IF p_venue_rec.internal_flag <> FND_API.g_miss_char AND p_venue_rec.internal_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_venue_rec.internal_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_INTERNAL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- ENABLED_FLAG
   IF p_venue_rec.enabled_flag <> FND_API.g_miss_char AND p_venue_rec.enabled_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_venue_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- DIRECT_PHONE_FLAG
   IF p_venue_rec.direct_phone_flag <> FND_API.g_miss_char AND p_venue_rec.direct_phone_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_venue_rec.direct_phone_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_VENUE_BAD_DIRECT_PH');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Venue_Flag_Items;

END AMS_Venue_PVT;

/
