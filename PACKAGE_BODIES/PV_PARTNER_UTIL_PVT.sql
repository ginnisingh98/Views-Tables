--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_UTIL_PVT" AS
/* $Header: pvxvputb.pls 120.13 2006/02/26 21:01:48 rdsharma noship $ */

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE map_location_rec( p_location_rec   IN PV_PARTNER_UTIL_PVT.location_rec_type,
                            x_location_rec   OUT NOCOPY HZ_LOCATION_V2PUB.location_rec_type)
IS
BEGIN

    x_location_rec.orig_system_reference := p_location_rec.orig_system_reference ;
    x_location_rec.orig_system		 := p_location_rec.orig_system  ;
    x_location_rec.country               := p_location_rec.country ;
    x_location_rec.address1              := p_location_rec.address1 ;
    x_location_rec.address2              := p_location_rec.address2 ;
    x_location_rec.address3              := p_location_rec.address3 ;
    x_location_rec.address4              := p_location_rec.address4 ;
    x_location_rec.city                  := p_location_rec.city ;
    x_location_rec.postal_code           := p_location_rec.postal_code ;
    x_location_rec.state                 := p_location_rec.state ;
    x_location_rec.province              := p_location_rec.province ;
    x_location_rec.county                := p_location_rec.county ;
    x_location_rec.address_key           := p_location_rec.address_key ;
    x_location_rec.address_style         := p_location_rec.address_style ;
    x_location_rec.validated_flag        := p_location_rec.validated_flag ;
    x_location_rec.address_lines_phonetic:= p_location_rec.address_lines_phonetic ;
    x_location_rec.po_box_number         := p_location_rec.po_box_number ;
    x_location_rec.house_number          := p_location_rec.house_number ;
    x_location_rec.street_suffix         := p_location_rec.street_suffix ;
    x_location_rec.street                := p_location_rec.street ;
    x_location_rec.street_number         := p_location_rec.street_number ;
    x_location_rec.floor                 := p_location_rec.floor ;
    x_location_rec.suite                 := p_location_rec.suite ;
    x_location_rec.postal_plus4_code     := p_location_rec.postal_plus4_code ;
    x_location_rec.position              := p_location_rec.position ;
    x_location_rec.location_directions   := p_location_rec.location_directions ;
    x_location_rec.address_effective_date:= p_location_rec.address_effective_date ;
    x_location_rec.address_expiration_date := p_location_rec.address_expiration_date ;
    x_location_rec.clli_code             := p_location_rec.clli_code ;
    x_location_rec.language              := p_location_rec.language ;
    x_location_rec.short_description     := p_location_rec.short_description ;
    x_location_rec.description           := p_location_rec.description ;
    x_location_rec.geometry_status_code  := p_location_rec.geometry_status_code ;
    x_location_rec.loc_hierarchy_id      := p_location_rec.loc_hierarchy_id ;
    x_location_rec.sales_tax_geocode     := p_location_rec.sales_tax_geocode ;
    x_location_rec.sales_tax_inside_city_limits := p_location_rec.sales_tax_inside_city_limits ;
    x_location_rec.fa_location_id        := p_location_rec.fa_location_id ;
    x_location_rec.content_source_type   := p_location_rec.content_source_type ;
    x_location_rec.attribute_category    := p_location_rec.attribute_category ;
    x_location_rec.attribute1            := p_location_rec.attribute1 ;
    x_location_rec.attribute2            := p_location_rec.attribute2 ;
    x_location_rec.attribute3            := p_location_rec.attribute3 ;
    x_location_rec.attribute4            := p_location_rec.attribute4 ;
    x_location_rec.attribute5            := p_location_rec.attribute5 ;
    x_location_rec.attribute6            := p_location_rec.attribute6 ;
    x_location_rec.attribute7            := p_location_rec.attribute7 ;
    x_location_rec.attribute8            := p_location_rec.attribute8 ;
    x_location_rec.attribute9            := p_location_rec.attribute9 ;
    x_location_rec.attribute10           := p_location_rec.attribute10 ;
    x_location_rec.attribute11           := p_location_rec.attribute11 ;
    x_location_rec.attribute12           := p_location_rec.attribute12 ;
    x_location_rec.attribute13           := p_location_rec.attribute13 ;
    x_location_rec.attribute14           := p_location_rec.attribute14 ;
    x_location_rec.attribute15           := p_location_rec.attribute15 ;
    x_location_rec.attribute16           := p_location_rec.attribute16 ;
    x_location_rec.attribute17           := p_location_rec.attribute17 ;
    x_location_rec.attribute18           := p_location_rec.attribute18 ;
    x_location_rec.attribute19           := p_location_rec.attribute19 ;
    x_location_rec.attribute20           := p_location_rec.attribute20 ;
    x_location_rec.timezone_id           := p_location_rec.timezone_id ;
    x_location_rec.created_by_module     := p_location_rec.created_by_module ;
    x_location_rec.application_id        := p_location_rec.application_id ;
    x_location_rec.actual_content_source := p_location_rec.actual_content_source ;

END map_location_rec;

PROCEDURE map_person_rec(
              p_person_rec   IN PV_PARTNER_UTIL_PVT.person_rec_type,
              x_person_rec   OUT NOCOPY HZ_PARTY_V2PUB.person_rec_type)
IS
BEGIN

    x_person_rec.person_pre_name_adjunct := p_person_rec.person_pre_name_adjunct;
    x_person_rec.person_first_name := p_person_rec.person_first_name ;
    x_person_rec.person_middle_name := p_person_rec.person_middle_name;
    x_person_rec.person_last_name := p_person_rec.person_last_name ;
    x_person_rec.person_name_suffix := p_person_rec.person_name_suffix ;
    x_person_rec.person_title := p_person_rec.person_title ;
    x_person_rec.person_academic_title := p_person_rec.person_academic_title ;
    x_person_rec.person_previous_last_name := p_person_rec.person_previous_last_name ;
    x_person_rec.person_initials := p_person_rec.person_initials  ;
    x_person_rec.known_as := p_person_rec.known_as  ;
    x_person_rec.known_as2 := p_person_rec.known_as2 ;
    x_person_rec.known_as3 := p_person_rec.known_as3 ;
    x_person_rec.known_as4 := p_person_rec.known_as4 ;
    x_person_rec.known_as5 := p_person_rec.known_as5 ;
    x_person_rec.person_name_phonetic := p_person_rec.person_name_phonetic ;
    x_person_rec.person_first_name_phonetic := p_person_rec.person_first_name_phonetic ;
    x_person_rec.person_last_name_phonetic  := p_person_rec.person_last_name_phonetic ;
    x_person_rec.middle_name_phonetic := p_person_rec.middle_name_phonetic ;
    x_person_rec.tax_reference := p_person_rec.tax_reference ;
    x_person_rec.jgzz_fiscal_code := p_person_rec.jgzz_fiscal_code ;
    x_person_rec.person_iden_type := p_person_rec.person_iden_type ;
    x_person_rec.person_identifier := p_person_rec.person_identifier;
    x_person_rec.date_of_birth := p_person_rec.date_of_birth  ;
    x_person_rec.place_of_birth := p_person_rec.place_of_birth ;
    x_person_rec.date_of_death := p_person_rec.date_of_death ;
    x_person_rec.deceased_flag := null;
    x_person_rec.gender := p_person_rec.gender ;
    x_person_rec.declared_ethnicity := p_person_rec.declared_ethnicity ;
    x_person_rec.marital_status := p_person_rec.marital_status ;
    x_person_rec.marital_status_effective_date := p_person_rec.marital_status_effective_date ;
    x_person_rec.personal_income := p_person_rec.personal_income ;
    x_person_rec.head_of_household_flag := p_person_rec.head_of_household_flag ;
    x_person_rec.household_income := p_person_rec.household_income ;
    x_person_rec.household_size := p_person_rec.household_size ;
    x_person_rec.rent_own_ind := p_person_rec.rent_own_ind ;
    x_person_rec.last_known_gps := p_person_rec.last_known_gps ;
    x_person_rec.content_source_type := p_person_rec.content_source_type ;
    x_person_rec.internal_flag := p_person_rec.internal_flag ;
    x_person_rec.attribute_category := p_person_rec.attribute_category ;
    x_person_rec.attribute1 := p_person_rec.attribute1 ;
    x_person_rec.attribute2 := p_person_rec.attribute2 ;
    x_person_rec.attribute3 := p_person_rec.attribute3 ;
    x_person_rec.attribute4 := p_person_rec.attribute4 ;
    x_person_rec.attribute5 := p_person_rec.attribute5 ;
    x_person_rec.attribute6 := p_person_rec.attribute6 ;
    x_person_rec.attribute7 := p_person_rec.attribute7 ;
    x_person_rec.attribute8 := p_person_rec.attribute8 ;
    x_person_rec.attribute9 := p_person_rec.attribute9 ;
    x_person_rec.attribute10 := p_person_rec.attribute10 ;
    x_person_rec.attribute11 := p_person_rec.attribute11 ;
    x_person_rec.attribute12 := p_person_rec.attribute12 ;
    x_person_rec.attribute13 := p_person_rec.attribute13 ;
    x_person_rec.attribute14 := p_person_rec.attribute14 ;
    x_person_rec.attribute15 := p_person_rec.attribute15 ;
    x_person_rec.attribute16 := p_person_rec.attribute16 ;
    x_person_rec.attribute17 := p_person_rec.attribute17 ;
    x_person_rec.attribute18 := p_person_rec.attribute18 ;
    x_person_rec.attribute19 := p_person_rec.attribute19 ;
    x_person_rec.attribute20 := p_person_rec.attribute20 ;
    x_person_rec.created_by_module := p_person_rec.created_by_module ;
    x_person_rec.application_id := p_person_rec.application_id ;
    x_person_rec.actual_content_source := p_person_rec.actual_content_source ;
    x_person_rec.party_rec := p_person_rec.party_rec ;

END map_person_rec;

FUNCTION get_Person_ID(p_resource_id  IN NUMBER)
RETURN NUMBER
IS
    l_person_id      NUMBER;

    CURSOR l_person_id_csr(cv_resource_id NUMBER) IS
        SELECT source_id
        FROM jtf_rs_resource_extns
        WHERE resource_id = cv_resource_id
        AND category='EMPLOYEE' ;
BEGIN

      OPEN l_person_id_csr(p_resource_id );
      FETCH l_person_id_csr INTO l_person_id;
      CLOSE l_person_id_csr;

      return l_person_id;
END get_Person_ID;

/*============================================================================
-- Start of comments
--  API name  : Create_Search_Attr_Values
--  Type      : Private.
--  Function  : This API consolidates three operations in single API call. These
--              operations are as follows -
--                  * Create a party
--                  * Create a location
--                  * Create a party site
--              for a given party. Once the party is successfully created then
--              it return the PARTY_ID of that organization.
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version      IN NUMBER   Required
--          p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_organization_rec    IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE Required
--          p_location_rec        IN PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE  Required
--          p_party_site_rec      IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status    OUT VARCHAR2(1)
--          x_msg_count        OUT NUMBER
--          x_msg_data         OUT VARCHAR2(2000)
--          x_party_id         NUMBER
--          x_default_resp_id  OUT NOCOPY NUMBER
--          x_group_id         OUT NOCOPY NUMBER
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE Create_Search_Attr_Values (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_partner_id          IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  ) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Create_Search_Attr_values';
    l_partner_id    NUMBER := p_partner_id;
begin

    -- vansub
    -- Start : Rivendell Changes
    -- Insert into pv_search_attr_values at the time of creating partner
    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Start : Inserting into pv_search_attr_values table  for partner :'||l_partner_id);
      END IF;

      EXECUTE IMMEDIATE
      '   INSERT INTO pv_search_attr_values
      SELECT  pv_search_attr_values_s.nextval
           ,  partner_id
           ,  null
           ,  attr_text
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  1.0
           ,  FND_GLOBAL.user_id
           ,  null
           ,  attribute_id
           ,  null
      from (
      SELECT distinct 4 attribute_id, hl.country attr_text, pvpp.partner_id partner_id
      FROM   hz_locations hl,
             hz_party_sites hs,
             pv_partner_profiles pvpp
      WHERE  hl.location_id = hs.location_id
      AND    hs.party_id =  pvpp.partner_party_id
      AND    pvpp.partner_id = :1
      AND   (hs.status = ''A'' OR hs.status IS NULL)
      UNION all
      SELECT  11 attribute_id, UPPER(PARTNER.party_name) attr_text ,PVPP.partner_id partner_id
      FROM   hz_organization_profiles HZOP_PRT,
             pv_enty_attr_values PEAV,
             hz_parties PARTNER,
             hz_organization_profiles HZOP,
             hz_parties INTERNAL,
             hz_relationships HZR,
             pv_partner_profiles PVPP
      WHERE   HZR.party_id = PVPP.partner_id
      AND     HZR.object_id = INTERNAL.party_id
      AND     HZR.subject_id = PVPP.partner_party_id
      AND     HZR.subject_id = PARTNER.party_id
      AND     HZR.subject_table_name = ''HZ_PARTIES''
      AND     HZR.object_table_name = ''HZ_PARTIES''
      AND     HZR.subject_type = ''ORGANIZATION''
      AND     HZR.object_type = ''ORGANIZATION''
      AND     HZR.RELATIONSHIP_TYPE IN (''PARTNER'',''PARTNER_MANAGED_CUSTOMER'')
      AND     INTERNAL.PARTY_TYPE=''ORGANIZATION''
      AND     PARTNER.PARTY_TYPE =''ORGANIZATION''
      AND     HZOP.party_id = INTERNAL.party_id
      AND     HZOP.effective_end_date is null
      AND     INTERNAL.status IN (''A'',''I'')
      AND     PARTNER.status IN  (''A'',''I'')
      AND     HZR.status IN  (''A'',''I'')
      AND     HZOP_PRT.party_id = PARTNER.party_id
      AND     HZOP_PRT.effective_end_date is null
      AND     PEAV.entity_id(+) = HZR.party_id
      AND     PEAV.entity(+) = ''PARTNER''
      AND     PEAV.attribute_id(+) = 3
      AND     PEAV.attr_value(+) = ''VAD''
      AND     PEAV.latest_flag(+) = ''Y''
      AND     HZOP.internal_flag = ''Y''
      AND     PVPP.partner_id = :1
      UNION all
      SELECT 3 attribute_id,pear.attr_value attr_text, pear.entity_id partner_id
      FROM   pv_enty_attr_values pear
      WHERE  pear.entity_id = :1
      AND    pear.latest_flag = ''Y''
      AND    attr_value is not null
      AND    attribute_id = 3 )' USING l_partner_id,l_partner_id,l_partner_id ;

    -- end : Rivendell Changes
    -- vansub
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('End : Inserting into search table ');
      END IF;

   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

end Create_Search_Attr_values;
/*============================================================================
-- Start of comments
--  API name  : Create_Partner
--  Type      : Public.
--  Function  : This API consolidates three operations in single API call. These
--              operations are as follows -
--                  * Create a party
--                  * Create a location
--                  * Create a party site
--              for a given party. Once the party is successfully created then
--              it return the PARTY_ID of that organization.
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version      IN NUMBER   Required
--          p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_organization_rec    IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE Required
--          p_location_rec        IN PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE  Required
--          p_party_site_rec      IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status    OUT VARCHAR2(1)
--          x_msg_count        OUT NUMBER
--          x_msg_data         OUT VARCHAR2(2000)
--          x_party_id         NUMBER
--          x_default_resp_id  OUT NOCOPY NUMBER
--          x_group_id         OUT NOCOPY NUMBER
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE Create_Partner (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_organization_rec    IN  HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_location_rec        IN  PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE,
    p_party_site_rec      IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  --  p_partner_types_tbl   IN  partner_types_tbl_type := g_miss_partner_types_tbl,
    p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type,
    p_vad_partner_id      IN  NUMBER,
    p_member_type         IN  VARCHAR2 ,
    p_global_partner_id   IN  NUMBER ,
    x_party_id            OUT NOCOPY NUMBER,
    x_default_resp_id     OUT NOCOPY NUMBER,
    x_resp_map_rule_id    OUT NOCOPY NUMBER,
    x_group_id            OUT NOCOPY NUMBER
  ) IS

   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Partner';
   L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;

   -- Local variable declaration for Organization API.
   l_organization_rec   HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
   l_party_id          NUMBER;
   l_party_number      VARCHAR2(30);

   -- Local variable declaration for Location API.
   l_location_rec       HZ_LOCATION_V2PUB.location_rec_type;
   l_location_id        NUMBER;

   -- Local variable declaration for Party Site API.
   l_party_site_rec     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE ;
   l_party_site_id     NUMBER;
   l_party_site_number VARCHAR2(30);

   -- Local variable declaration for Create_Relationship API.
   l_partner_id        NUMBER;
   l_default_resp_id   NUMBER;

   -- Local variable declaration for Standard Out variables.
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);

   -- Declaration of variable for some other common purpose.
   l_profile_id        NUMBER;
   l_vad_partner_id    NUMBER;
   l_resp_map_rule_id  NUMBER;
   l_group_id          NUMBER;


 BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT create_partner_pvt;

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

   -- Local variable initialization
      l_organization_rec.organization_name :=  p_organization_rec.organization_name;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message( 'Public API: Calling create Organization API');
      END IF;

   -- Call HZ_PARTY_V2PUB.Create_Organization API, for creating a Party record
   -- in HZ_PARTIES table for the supplied organization.

      HZ_PARTY_V2PUB.Create_organization (
        p_init_msg_list	    =>  FND_API.G_FALSE,
        p_organization_rec  =>  p_organization_rec,
        x_return_status     =>  l_return_status,
        x_msg_count         =>  l_msg_count,
        x_msg_data          =>  l_msg_data,
        x_party_id          =>  l_party_id,
        x_party_number      =>  l_party_number,
        x_profile_id        =>  l_profile_id
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message( 'Public API: Successfully completed HZ_PARTY_V2PUB.Create_Organization API Call');
      END IF;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message( 'Private API: Calling create Location API');
      END IF;

   -- Initialize the l_location rec from the supplied parameter p_location_rec variable.
      map_location_rec( p_location_rec => p_location_rec ,
                        x_location_rec => l_location_rec );

   -- Call the HZ_LOCATION_V2PUB.Create_Location API for creating the location.
      HZ_LOCATION_V2PUB.Create_Location(
         p_init_msg_list   => FND_API.G_FALSE,
         p_location_rec    => l_location_rec,
         x_location_id     => l_location_id,
         x_return_status   => l_return_status,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message( 'Public API: Successfully completed HZ_LOCATION_V2PUB.Create_Location API Call');
      END IF;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message( 'Public API: Calling create Party Site API');
      END IF;

   -- Initialize some of the Party Site related variable.
      l_party_site_rec := p_party_site_rec;
      l_party_site_rec.location_id := l_location_id;
      l_party_site_rec.party_id := l_party_id;

   -- Call the HZ_PARTY_SITE_V2PUB.Create_Party_site API for creating the party site.

      HZ_PARTY_SITE_V2PUB.create_party_site (
         p_init_msg_list     => FND_API.G_FALSE,
         p_party_site_rec    => l_party_site_rec,
         x_party_site_id     => l_party_site_id,
         x_party_site_number => l_party_site_number,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
       );


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message( 'Private API: Successfully completed create Party Site API Call');
      END IF;

   -- Call the Create_Realtionship  API for creating rest of the stuff
   -- related to partner organization.

      Create_Relationship(
         p_api_version_number => 1.0
   	 ,p_init_msg_list     => FND_API.G_FALSE
   	 ,p_commit            => FND_API.G_FALSE
   	 ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status     => l_return_status
   	 ,x_msg_data          => l_msg_data
   	 ,x_msg_count         => l_msg_count
         ,p_party_id	      => l_party_id
         ,p_partner_types_tbl => p_partner_types_tbl
	 ,p_vad_partner_id    => p_vad_partner_id
	 ,p_member_type       => p_member_type
         ,p_global_partner_id => p_global_partner_id
         ,x_partner_id        => l_partner_id
         ,x_default_resp_id   => l_default_resp_id
	 ,x_resp_map_rule_id  => l_resp_map_rule_id
	 ,x_group_id          => l_group_id
	    );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Initialize the output parameters
      x_party_id := l_party_id;
      x_default_resp_id := l_default_resp_id;
      x_resp_map_rule_id  :=  l_resp_map_rule_id;
      x_group_id := l_group_id;


Create_Search_Attr_Values (
             p_api_version_number => 1.0
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,x_return_status     => l_return_status
            ,x_msg_data          => l_msg_data
            ,x_msg_count         => l_msg_count
            ,p_partner_id        => l_partner_id
        	);
/*

    -- vansub
    -- Start : Rivendell Changes
    -- Insert into pv_search_attr_values at the time of creating partner
    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Start : Inserting into pv_search_attr_values table  for partner :'||l_partner_id);
      END IF;

      EXECUTE IMMEDIATE
      '   INSERT INTO pv_search_attr_values
      SELECT  pv_search_attr_values_s.nextval
           ,  partner_id
           ,  null
           ,  attr_text
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  1.0
           ,  FND_GLOBAL.user_id
           ,  null
           ,  attribute_id
           ,  null
      from (
      SELECT distinct 4 attribute_id, hl.country attr_text, pvpp.partner_id partner_id
      FROM   hz_locations hl,
             hz_party_sites hs,
             pv_partner_profiles pvpp
      WHERE  hl.location_id = hs.location_id
      AND    hs.party_id =  pvpp.partner_party_id
      AND    pvpp.partner_id = :1
      AND   (hs.status = ''A'' OR hs.status IS NULL)
      UNION all
      SELECT  11 attribute_id, UPPER(PARTNER.party_name) attr_text ,PVPP.partner_id partner_id
      FROM   hz_organization_profiles HZOP_PRT,
             pv_enty_attr_values PEAV,
             hz_parties PARTNER,
             hz_organization_profiles HZOP,
             hz_parties INTERNAL,
             hz_relationships HZR,
             pv_partner_profiles PVPP
      WHERE   HZR.party_id = PVPP.partner_id
      AND     HZR.object_id = INTERNAL.party_id
      AND     HZR.subject_id = PVPP.partner_party_id
      AND     HZR.subject_id = PARTNER.party_id
      AND     HZR.subject_table_name = ''HZ_PARTIES''
      AND     HZR.object_table_name = ''HZ_PARTIES''
      AND     HZR.subject_type = ''ORGANIZATION''
      AND     HZR.object_type = ''ORGANIZATION''
      AND     HZR.RELATIONSHIP_TYPE IN (''PARTNER'',''PARTNER_MANAGED_CUSTOMER'')
      AND     INTERNAL.PARTY_TYPE=''ORGANIZATION''
      AND     PARTNER.PARTY_TYPE =''ORGANIZATION''
      AND     HZOP.party_id = INTERNAL.party_id
      AND     HZOP.effective_end_date is null
      AND     INTERNAL.status IN (''A'',''I'')
      AND     PARTNER.status IN  (''A'',''I'')
      AND     HZR.status IN  (''A'',''I'')
      AND     HZOP_PRT.party_id = PARTNER.party_id
      AND     HZOP_PRT.effective_end_date is null
      AND     PEAV.entity_id(+) = HZR.party_id
      AND     PEAV.entity(+) = ''PARTNER''
      AND     PEAV.attribute_id(+) = 3
      AND     PEAV.attr_value(+) = ''VAD''
      AND     PEAV.latest_flag(+) = ''Y''
      AND     HZOP.internal_flag = ''Y''
      AND     PVPP.partner_id = :1
      UNION all
      SELECT 3 attribute_id,pear.attr_value attr_text, pear.entity_id partner_id
      FROM   pv_enty_attr_values pear
      WHERE  pear.entity_id = :1
      AND    pear.latest_flag = ''Y''
      AND    attr_value is not null
      AND    attribute_id = 3 )' USING l_partner_id,l_partner_id,l_partner_id ;

    -- end : Rivendell Changes
    -- vansub
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('End : Inserting into search table ');
      END IF;

   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
*/
 EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_partner_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
        hz_utility_v2pub.debug('Create_Partner (-)');
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_partner_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
        hz_utility_v2pub.debug('Create_Partner (-)');
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO create_partner_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
        hz_utility_v2pub.debug('Create_Partner (-)');
     END IF;

End Create_Partner;

/*============================================================================
-- Start of comments
--  API name  : Create_Party_Site_Uses
--  Type      : Public.
--  Function  : This api checks if the party already has party sites with
--              BILL_TO and SHIP_TO site use type. If it does not exists adds
--              these use types to the identifying address
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    :
--          p_party_id            IN NUMBER  Required
--
--  OUT   : x_return_status       OUT VARCHAR2(1)
--          x_msg_count           OUT NUMBER
--          x_msg_data            OUT VARCHAR2(2000)
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/

PROCEDURE Create_Party_Site_Uses (
	  p_party_id		  IN  NUMBER
     ,x_return_status     OUT NOCOPY  VARCHAR2
     ,x_msg_data          OUT NOCOPY  VARCHAR2
     ,x_msg_count         OUT NOCOPY  NUMBER
	 )
IS


CURSOR get_site_use_type(cv_party_id NUMBER) IS
       SELECT  distinct site_use_type
       FROM hz_party_site_uses hpsu,
            hz_party_sites hps
       WHERE hpsu.party_site_id = hps.party_site_id
       AND site_use_type in ('SHIP_TO','BILL_TO')
       AND hps.party_id = cv_party_id ;

CURSOR get_ident_party_site_dtls(cv_party_id  NUMBER) is
    SELECT party_site_id FROM HZ_PARTY_SITES  WHERE PARTY_ID = CV_PARTY_ID AND IDENTIFYING_ADDRESS_FLAG = 'Y';


    l_party_site_use_rec  HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_vendor_org_id  number;
    l_party_site_id  number;
    l_party_site_use_id number;
    l_party_site_use VARCHAR2(20);

   -- Local variable declaration for Standard Out variables.
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);
   l_cnt	       NUMBER;
   cur_cnt  get_site_use_type%ROWTYPE;


BEGIN

     hz_utility_v2pub.debug('Party Id:' || p_party_id);

     l_cnt := 0;
     FOR cur_cnt IN get_site_use_type(p_party_id)
     LOOP
       l_party_site_use:= cur_cnt.site_use_type;
       l_cnt := l_cnt + 1;
     END LOOP;

     IF NOT (l_cnt = 2) then

        OPEN get_ident_party_site_dtls(p_party_id);
        FETCH get_ident_party_site_dtls into l_party_site_id;
        close get_ident_party_site_dtls ;



        l_party_site_use_rec.party_site_use_id := FND_API.G_MISS_NUM;
        l_party_site_use_rec.comments          := FND_API.G_MISS_CHAR ;

        l_party_site_use_rec.party_site_id     := l_party_site_id;
        l_party_site_use_rec.primary_per_type  := FND_API.G_MISS_CHAR;
        l_party_site_use_rec.status            := 'A';
        l_party_site_use_rec.created_by_module := 'PV';
        l_party_site_use_rec.application_id    := '691';


        IF (l_party_site_use = 'SHIP_TO') THEN
            l_party_site_use_rec.site_use_type     := 'BILL_TO';

            hz_party_site_v2pub.create_party_site_use (
               p_init_msg_list         => FND_API.G_FALSE,
               p_party_site_use_rec    => l_party_site_use_rec,
               x_party_site_use_id     => l_party_site_use_id,
               x_return_status         => l_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data );


               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END IF;


        ELSIF (l_party_site_use = 'BILL_TO') then
               l_party_site_use_rec.site_use_type     := 'SHIP_TO';

               hz_party_site_v2pub.create_party_site_use (
                  p_init_msg_list         => FND_API.G_FALSE,
                  p_party_site_use_rec    => l_party_site_use_rec,
                  x_party_site_use_id     => l_party_site_use_id,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data );

                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                  END IF;

        ELSE

               l_party_site_use_rec.site_use_type     := 'BILL_TO';

               hz_party_site_v2pub.create_party_site_use (
                  p_init_msg_list         => FND_API.G_FALSE,
                  p_party_site_use_rec    => l_party_site_use_rec,
                  x_party_site_use_id     => l_party_site_use_id,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data );


                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                  END IF;


                  l_party_site_use_rec.site_use_type     := 'SHIP_TO';

                  hz_party_site_v2pub.create_party_site_use (
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_party_site_use_rec    => l_party_site_use_rec,
                        x_party_site_use_id     => l_party_site_use_id,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data );


                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                               RAISE FND_API.G_EXC_ERROR;
                            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
	END IF;
     END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_Party_Site_Uses;
/*============================================================================
-- Start of comments
--  API name  : Do_Create_Relationship
--  Type      : Public.
--  Function  : This API consolidates few artner creation related operations in
--              single API call. These operations are as follows -
--                  *  Get the vendor Organization based on the default
--                     responsibility of the logged in user
--                  *  Create a relationship record between Vendor Org and the Partner Org
--	                *  Create Resource for the partner
--                  *  Create role for the above resource
--                  *  Create Group for the above resource
--                  *  Create Partner Profile
--                  *  Get Sales Team for the given partner
--                  *  Add Sales Team for the given Partner
--                  *  Add Channel Manager in Channel Team from TAP
--                  *  Add Partner types to Attributes table
--                  *  If partner type is subsidiary, establish a relationship with the global partner
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version         IN NUMBER   Required
--          p_init_msg_list       IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit              IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level    IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_party_id            IN NUMBER  Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status       OUT VARCHAR2(1)
--          x_msg_count           OUT NUMBER
--          x_msg_data            OUT VARCHAR2(2000)
--          x_partner_id          OUT NOCOPY NUMBER
--          x_default_resp_id     OUT NOCOPY NUMBER
--          x_resp_map_rule_id    OUT NOCOPY NUMBER,
--          x_group_id            OUT NOCOPY NUMBER
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/

  PROCEDURE Do_Create_Relationship(
     p_api_version_number IN  NUMBER
     ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
     ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
     ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status     OUT NOCOPY  VARCHAR2
     ,x_msg_data          OUT NOCOPY  VARCHAR2
     ,x_msg_count         OUT NOCOPY  NUMBER
     ,p_party_id	  IN  NUMBER
     ,p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type
     ,p_vad_partner_id    IN  NUMBER
     ,p_member_type       IN  VARCHAR2
     ,p_global_partner_id   IN  NUMBER
     ,p_partner_qualifiers_tbl  IN PV_TERR_ASSIGN_PUB.partner_qualifiers_tbl_type
     ,x_partner_id        OUT NOCOPY NUMBER
     ,x_default_resp_id   OUT NOCOPY NUMBER
     ,x_resp_map_rule_id  OUT NOCOPY NUMBER
     ,x_group_id          OUT NOCOPY NUMBER
) IS

   L_API_NAME           CONSTANT VARCHAR2(30) := 'Do_Create_Relationship';
   L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;

    l_partner_qualifiers_tbl    PV_TERR_ASSIGN_PUB.partner_qualifiers_tbl_type := p_partner_qualifiers_tbl;
   -- Cursor l_org_details_csr to get partner party details
   CURSOR l_org_details_csr (cv_party_id NUMBER) IS
     SELECT party_site_id
     FROM   hz_party_sites
     WHERE  party_id = cv_party_id
       AND  identifying_address_flag = 'Y'
       AND  status = 'A';

   -- Cursor l_relationship_details_csr to get partner party details
   CURSOR l_relationship_details_csr (cv_partner_id NUMBER) IS
     SELECT party_name
     FROM   hz_parties PARTY
     WHERE  PARTY.party_id = cv_partner_id
     AND    PARTY.status = 'A'
     AND    PARTY.party_type = 'PARTY_RELATIONSHIP';


   -- Cursor l_chk_relationship_exists_csr to check whether the relationship
   -- exists in between Partner and the Vendor organizations.
   CURSOR l_chk_relationship_exists_csr (cv_vendor_party_id NUMBER,
                                         cv_partner_party_id NUMBER) IS
     SELECT hzr.relationship_id relationship_id,
            hzp.party_id party_id,
	    hzp.party_number party_number
     FROM hz_relationships hzr,
          hz_parties  hzp
     WHERE hzr.subject_id = cv_partner_party_id
     AND   hzr.object_id = cv_vendor_party_id
     AND   hzr.status = 'A'
     AND   hzr.end_date > sysdate
     AND   relationship_code = 'PARTNER_OF'
     AND   relationship_type = 'PARTNER'
     AND   hzr.party_id = hzp.party_id;

   l_party_id          NUMBER ;
   l_partner_types     VARCHAR2(500);
   l_partner_level     VARCHAR2(30);
   l_party_site_id     NUMBER ;
   l_user_role_code    VARCHAR2(30):= Pv_User_Resp_Pvt.G_PRIMARY;
   l_responsibility_id NUMBER;
   l_resp_map_rule_id  NUMBER;
   l_application_id    NUMBER := 691;
   l_vendor_org_id     NUMBER;
   l_defined_flag      BOOLEAN;

   -- Delaration of local variables needed in Create_Relationship API call
   l_relationship_id   NUMBER;
   l_party_number      VARCHAR2(30);
   l_partner_id	       NUMBER;
   l_relactionship_rec HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
   l_relship_party_name VARCHAR2(360);

   -- Declaration of local variables needed in Create_Resource API call
   l_party_name       VARCHAR2(360);
   l_admin_rec        PVX_MISC_PVT.ADMIN_REC_TYPE;
   l_resource_id      NUMBER;
   l_resource_number  VARCHAR2(30);
   l_mode             VARCHAR2(10);

   -- Declaration of local variables needed in Create_Role API call
   l_role_relate_id   NUMBER;

   -- Declaration of local variables needed in Create_Group API call
   l_group_id         NUMBER;
   l_group_number     VARCHAR2(30);
   l_group_usage_id   NUMBER;
   l_group_member_id  NUMBER;

   -- Declaration of local variables needed in Create_Prtnr_Prfls API call
   l_prtnr_prfls_rec  PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type;
   l_partner_profile_id  NUMBER;

   -- Declaration of local variables needed in TAP_Get_Channel_Managers API call
   l_resource_id_tbl JTF_NUMBER_TABLE;
   l_group_id_tbl    JTF_NUMBER_TABLE;

   -- Declaration of local variables needed in Create_SalesTeam API call
   l_admin_group_id  NUMBER;
   l_person_id       NUMBER;
   l_def_cm_id       NUMBER;
   l_user_id         NUMBER := FND_GLOBAL.user_id;
   l_chk_access_flag VARCHAR2(1);
   l_admin_flag      VARCHAR2(1);
   l_identity_sales_force_id NUMBER;
   l_access_id       NUMBER;
   l_access_profile_rec AS_ACCESS_PUB.access_profile_rec_type;

   l_attr_value_tbl  PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
   l_prtnr_access_id_tbl PV_TERR_ASSIGN_PUB.prtnr_aces_tbl_type;

   -- Local variable declaration for Standard Out variables.
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);

BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT create_relationship_pvt;

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
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization
      l_party_id         :=  p_party_id;

   -- Initilize the l_relationship_rec with required values.
      l_relactionship_rec.subject_id := l_party_id;
      l_relactionship_rec.subject_type := 'ORGANIZATION';
      l_relactionship_rec.subject_table_name := 'HZ_PARTIES';

   -- Get the Default responsibility for the supplied Organization Id.
      Pv_User_Resp_Pvt.get_default_org_resp(
         p_api_version_number   => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,x_return_status       => l_return_status
         ,x_msg_count           => l_msg_count
         ,x_msg_data            => l_msg_data
         ,p_partner_org_id      => l_party_id
         ,p_user_role_code      => l_user_role_code
         ,x_responsibility_id   => l_responsibility_id
         ,x_resp_map_rule_id    => l_resp_map_rule_id
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Get the default vendor org id, for the supplied responsibility id.
      FND_PROFILE.GET_SPECIFIC(
          NAME_Z               => 'PV_DEFAULT_VENDOR_ORG'
          ,USER_ID_Z           => null
	  ,RESPONSIBILITY_ID_Z => l_responsibility_id
	  ,APPLICATION_ID_Z    => l_application_id
	  ,VAL_Z               => l_vendor_org_id
	  ,DEFINED_Z           => l_defined_flag
	  ,ORG_ID_Z            => null
	  ,SERVER_ID_Z         => null);

      IF l_vendor_org_id IS NULL OR l_vendor_org_id = FND_API.g_miss_num THEN
         l_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_message.Set_Name('PV', 'PV_NO_DEF_VENDOR_ORG');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      OPEN l_chk_relationship_exists_csr(l_vendor_org_id, l_party_id);
      FETCH l_chk_relationship_exists_csr INTO l_relationship_id, l_partner_id, l_party_number;

      IF l_chk_relationship_exists_csr%NOTFOUND THEN

         -- Iniliatize the local variables required for Relationship creation.
         l_relactionship_rec.object_id := l_vendor_org_id ;
         l_relactionship_rec.object_type := 'ORGANIZATION';
         l_relactionship_rec.object_table_name := 'HZ_PARTIES';
         l_relactionship_rec.relationship_code := 'PARTNER_OF';
         l_relactionship_rec.relationship_type := 'PARTNER';
         l_relactionship_rec.start_date := SYSDATE;
         l_relactionship_rec.created_by_module:= 'PV';
         l_relactionship_rec.application_id:= l_application_id;
         l_relactionship_rec.status:= 'A';

         -- Create the relationship.
         HZ_RELATIONSHIP_V2PUB.create_relationship (
            p_init_msg_list      => FND_API.G_FALSE,
            p_relationship_rec   => l_relactionship_rec,
            x_relationship_id    => l_relationship_id,
            x_party_id           => l_partner_id,
            x_party_number	 => l_party_number,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_create_org_contact => 'N');

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;  -- End if of check l_chk_relationship_exists_csr

      -- Close the cursor l_chk_relationship_exists_csr
      CLOSE l_chk_relationship_exists_csr;

   -- set the out variables
      x_partner_id := l_partner_id ;
      x_default_resp_id   := l_responsibility_id;
      x_resp_map_rule_id := l_resp_map_rule_id;


   -- After successful creation of relationship, create resource for the
   -- partner by calling the Admin_Resource API from PVX_MISC_PVT package.

   -- Initilize the l_admin_rec with required values.
      l_admin_rec.partner_relationship_id := l_relationship_id;
      l_admin_rec.partner_id := l_partner_id;
      l_admin_rec.resource_type := 'PARTNER';

   -- Get the Partner relationship name from cursor l_relationship_details_csr.
      OPEN l_relationship_details_csr(l_partner_id);
      FETCH l_relationship_details_csr INTO l_relship_party_name;
      CLOSE l_relationship_details_csr;

   -- Get the partner details from l_partner_details_csr cursor for a given partner_id.
      l_admin_rec.source_name := l_relship_party_name;
      l_admin_rec.resource_name := l_relship_party_name;

   -- Get the party site details from l_org_details_csr cursor.
      OPEN l_org_details_csr(l_party_id);
      FETCH l_org_details_csr INTO l_party_site_id;
      CLOSE l_org_details_csr;

      l_admin_rec.party_site_id := l_party_site_id;
      l_mode := 'CREATE';


   -- Create the resource for the partner relationship
      PVX_MISC_PVT.Admin_Resource (
         p_api_version	      => 1.0
         ,p_init_msg_list     => FND_API.g_false
         ,p_commit            => FND_API.g_false
         ,x_return_status     => l_return_status
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,p_admin_rec         => l_admin_rec
         ,p_mode              => l_mode
         ,x_resource_id       => l_resource_id
         ,x_resource_number   => l_resource_number);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

  -- After successful creation of partner resource, create role for the resource,
  -- created in the previous step by calling Admin_Role API from PVX_MISC_PVT package.

  -- Initilize the l_admin_rec with required values.
     l_admin_rec.role_resource_id := l_resource_id;
     l_admin_rec.role_resource_type := 'RS_INDIVIDUAL';
     l_admin_rec.role_code := 'PARTNER_ORGANIZATION';


     PVX_MISC_PVT.Admin_Role(
        p_api_version	    => 1.0
        ,p_init_msg_list    => FND_API.g_false
        ,p_commit           => FND_API.g_false
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data
        ,p_admin_rec        => l_admin_rec
        ,p_mode             => FND_API.G_MISS_CHAR
        ,x_role_relate_id   => l_role_relate_id);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- After successful creation of resource role, create Group for the
      -- partner resource by calling Admin_Group API from PVX_MISC_PVT package.

      -- Initilize the l_admin_rec with required values.
	     l_admin_rec.role_resource_id := l_resource_id;
	     l_admin_rec.resource_number  := l_resource_number;

      -- Create the Group
         PVX_MISC_PVT.Admin_Group(
            p_api_version      => 1.0
            ,p_init_msg_list   => FND_API.g_false
            ,p_commit          => FND_API.g_false
            ,x_return_status   => l_return_status
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,p_admin_rec       => l_admin_rec
            ,p_mode            => FND_API.G_MISS_CHAR
            ,x_group_id        => l_group_id
            ,x_group_number    => l_group_number
            ,x_group_usage_id  => l_group_usage_id
            ,x_group_member_id => l_group_member_id);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- set the out variables
       x_group_id := l_group_id ;

      -- Create the partner profile by calling Create_Prtnr_Prfls API from
      -- PVX_PRTNR_PRFLS_PVT package.

      -- Initialize the auto_match_allowed_flag.
       l_prtnr_prfls_rec.auto_match_allowed_flag := 'N';
       l_prtnr_prfls_rec.lead_share_appr_flag := 'N';
       l_prtnr_prfls_rec.sales_partner_flag := 'N';
       l_prtnr_prfls_rec.indirectly_managed_flag := 'N';

       l_prtnr_prfls_rec.partner_id := l_partner_id;
       l_prtnr_prfls_rec.partner_relationship_id := l_relationship_id;
       l_prtnr_prfls_rec.partner_resource_id := l_resource_id;
       l_prtnr_prfls_rec.partner_group_id := l_group_id;
       l_prtnr_prfls_rec.partner_group_number := l_group_number;
       l_prtnr_prfls_rec.partner_party_id := l_party_id;

      -- Added to add default partner level during create partner in case
      -- of Invite Partner or Customer to Partner conversion for bug # 3418136.
        l_prtnr_prfls_rec.partner_level := fnd_profile.value('PV_DEFAULT_PARTNER_LEVEL');

     -- Removing the reference of SALES_PARTNER_FLAG in case of Partner Type
     -- is 'VAD' or 'RESELLER'.
     -- Set the Sales_Partner_Flag based on the Partner types.
     -- FOR i IN p_partner_types_tbl.first..p_partner_types_tbl.last LOOP
     --     l_partner_types := p_partner_types_tbl(i).attr_value ;
     --     IF l_partner_types= 'RESELLER' or l_partner_types = 'VAD' THEN
     --        l_prtnr_prfls_rec.sales_partner_flag  := 'Y';
     --        EXIT;
     --     END IF;
     --   END LOOP;

        -- Call the Create_Prtnr_Prfls API.
        PVX_PRTNR_PRFLS_PVT.Create_Prtnr_Prfls (
           p_api_version	 => 1.0
           ,p_init_msg_list      => FND_API.g_false
           ,p_commit             => FND_API.g_false
           ,p_validation_level   => FND_API.g_valid_level_full
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           ,p_prtnr_prfls_rec	 => l_prtnr_prfls_rec
           ,x_partner_profile_id => l_partner_profile_id );

        -- Check the return status.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Add all Partner types in the attribute table by calling
      -- Upsert_Attr_Value API from PV_ENTY_ATTR_VALUE_PUB package.

      FOR  I IN p_partner_types_tbl.first..p_partner_types_tbl.last
      LOOP
	 l_partner_types := p_partner_types_tbl(I).attr_value;
	 l_attr_value_tbl(I).attr_value:= l_partner_types;
	 l_attr_value_tbl(I).attr_value_extn := p_partner_types_tbl(I).attr_value_extn;
      END LOOP;

      -- Call the API to insert the partner types in the attribute table.
      PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value (
         p_api_version_number=> 1.0
         ,p_init_msg_list    => FND_API.g_false
         ,p_commit           => FND_API.g_false
         ,p_validation_level => FND_API.g_valid_level_full
         ,x_return_status    => l_return_status
         ,x_msg_count        => l_msg_count
         ,x_msg_data         => l_msg_data
         ,p_attribute_id     => 3
         ,p_entity	     => 'PARTNER'
         ,p_entity_id	     => l_partner_id
         ,p_version          => 0
         ,p_attr_val_tbl     => l_attr_value_tbl
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Call Register_term_ptr_memb_type API from Pv_ptr_member_type_pvt package
      -- to tag a partner with a member type.

      Pv_ptr_member_type_pvt.Register_term_ptr_memb_type (
         p_api_version_number  => 1.0
        ,p_init_msg_list       => FND_API.G_FALSE
        ,p_commit              => FND_API.G_FALSE
        ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
        ,p_partner_id          => l_partner_id
        ,p_current_memb_type   => null
        ,p_new_memb_type       => p_member_type
        ,p_global_ptr_id       => p_global_partner_id
        ,x_return_status       => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data            => l_msg_data );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Create the Channel Team
/*
	PV_TERR_ASSIGN_PUB.Create_Channel_Team (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE ,
            p_commit              => FND_API.G_FALSE ,
	    p_validation_level	  => FND_API.G_VALID_LEVEL_FULL ,
 	    p_partner_id          => l_partner_id,
            p_vad_partner_id      => p_vad_partner_id,
            p_mode                => 'CREATE',
            p_login_user          => l_user_id,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data,
            x_prtnr_access_id_tbl => l_prtnr_access_id_tbl
        );
*/
-- Change the call to create channel team with qualifiers record


	PV_TERR_ASSIGN_PUB.Do_Create_Channel_Team (
                p_api_version_number  => 1.0,
                p_init_msg_list       => FND_API.G_FALSE ,
                p_commit              => FND_API.G_FALSE ,
                p_validation_level	  => FND_API.G_VALID_LEVEL_FULL ,
                p_partner_id          => l_partner_id,
                p_vad_partner_id      => p_vad_partner_id,
                p_mode                => 'CREATE',
                p_login_user          => l_user_id,
                p_partner_qualifiers_tbl  => l_partner_qualifiers_tbl,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_prtnr_access_id_tbl => l_prtnr_access_id_tbl
                    );


	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

	-- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Prior to calling Create_Default_Membership API ');
      END IF;

	 pv_prgm_approval_pvt.Create_Default_Membership (
           p_api_version_number     => p_api_version_number
          ,p_init_msg_list          => FND_API.g_false
          ,p_commit                 => FND_API.G_FALSE
          ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
          ,p_partner_id             => l_partner_id
          ,p_requestor_resource_id  => -1
          ,x_return_status          => l_return_status
          ,x_msg_count              => l_msg_count
          ,x_msg_data               => l_msg_data
         );

 	-- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('After call to Create_Default_Membership API. l_return_status: ' || l_return_status);
      END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;

	 -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Prior to calling update_elig_prgm_4_new_ptnr ');
      END IF;


       PV_USER_MGMT_PVT.update_elig_prgm_4_new_ptnr(
           p_api_version_number         =>  p_api_version_number
          ,p_init_msg_list              =>  FND_API.g_false
          ,p_commit                     =>  FND_API.G_FALSE
          ,p_validation_level           =>  FND_API.g_valid_level_full
          ,x_return_status              =>  l_return_status
          ,x_msg_count                  =>  l_msg_count
          ,x_msg_data                   =>  l_msg_data
          ,p_partner_id                 =>  l_partner_id
          ,p_member_type                =>  NULL
        );

	 	-- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('After call to update_elig_prgm_4_new_ptnr API. l_return_status: ' || l_return_status);
      END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


       -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );




EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_relationship_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_relationship_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
      ROLLBACK TO create_relationship_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END Do_Create_Relationship;

/*============================================================================
-- Start of comments
--  API name  : Create_Relationship
--  Type      : Public.
--  Function  : This API consolidates few partner creation related operations in
--              single API call. These operations are as follows -
--                  *  Get the vendor Organization based on the default
--                     responsibility for the supplied partner org id.
--                  *  Create a relationship record between Vendor Org and the Partner Org
--	            *  Create Resource for the partner
--                  *  Create role for the above resource
--                  *  Create Group for the above resource
--                  *  Create Partner Profile
--                  *  Add Channel Manager in Channel Team from TAP
--                  *  Add Partner types to Attributes table
--                  *  If partner type is subsidiary, establish a relationship with the global partner
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version      IN NUMBER   Required
--          p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_party_id            IN NUMBER  Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status      OUT VARCHAR2(1)
--          x_msg_count          OUT NUMBER
--          x_msg_data           OUT VARCHAR2(2000)
--          x_partner_id         OUT NUMBER
--          x_default_resp_id    OUT NUMBER
--          x_resp_map_rule_id   OUT NOCOPY NUMBER
--          x_group_id           OUT NOCOPY NUMBER
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
  PROCEDURE Create_Relationship(
     p_api_version_number IN  NUMBER
     ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
     ,p_commit         	  IN  VARCHAR2 := FND_API.G_FALSE
     ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status     OUT NOCOPY  VARCHAR2
     ,x_msg_data          OUT NOCOPY  VARCHAR2
     ,x_msg_count         OUT NOCOPY  NUMBER
     ,p_party_id          IN  NUMBER
--     ,p_partner_types_tbl IN  partner_types_tbl_type := g_miss_partner_types_tbl
     ,p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type
     ,p_vad_partner_id    IN  NUMBER
     ,p_member_type        IN  VARCHAR2
     ,p_global_partner_id  IN  NUMBER
     ,x_partner_id        OUT NOCOPY NUMBER
     ,x_default_resp_id   OUT NOCOPY NUMBER
     ,x_resp_map_rule_id  OUT NOCOPY NUMBER
     ,x_group_id          OUT NOCOPY NUMBER
)  IS

   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Relationship';
   L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;


--Table for qualifier records
   l_partner_qualifiers_tbl  PV_TERR_ASSIGN_PUB.partner_qualifiers_tbl_type;
   l_party_id          NUMBER := p_party_id;

-- Local variable declaration for Standard Out variables.
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);

BEGIN

    -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        SAVEPOINT create_relationship_pvt;
--Code to build the qualifiers rec and call the relationshi API

        PV_TERR_ASSIGN_PUB. get_partner_details(
		         p_party_id               => l_party_id ,
		         x_return_status          => l_return_status ,
		         x_msg_count              => l_msg_count ,
		         x_msg_data               => l_msg_data ,
		         x_partner_qualifiers_tbl => l_partner_qualifiers_tbl );

    	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;


      Do_Create_Relationship(
            p_api_version_number => 1.0
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status     => l_return_status
            ,x_msg_data          => l_msg_data
            ,x_msg_count         => l_msg_count
            ,p_party_id	         => l_party_id
            ,p_partner_types_tbl => p_partner_types_tbl
            ,p_vad_partner_id    => p_vad_partner_id
            ,p_member_type       => p_member_type
            ,p_global_partner_id => p_global_partner_id
            ,p_partner_qualifiers_tbl => l_partner_qualifiers_tbl
            ,x_partner_id        => x_partner_id
            ,x_default_resp_id   => x_default_resp_id
            ,x_resp_map_rule_id  => x_resp_map_rule_id
            ,x_group_id          => x_group_id
        	    );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;



  --PINAGARA Changes for the ER # 4715607
    --Call the API to create party site uses BILL_TO and SHIP_TO

    Create_Party_Site_Uses (
                	  p_party_id		  => l_party_id
                     ,x_return_status     => l_return_status
                     ,x_msg_data          => l_msg_count
                     ,x_msg_count         => l_msg_data);


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;


EXCEPTION


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_relationship_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
      ROLLBACK TO create_relationship_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

End Create_Relationship;

/*============================================================================
-- Start of comments
--  API name  : Invite_Partner
--  Type      : Public.
--  Function  : Detail has to be entered.
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version      IN NUMBER   Required
--          p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_party_id         IN NUMBER  Required
--          p_partner_types    IN JTF_VARCHAR2  Required
--          p_vad_partner_id   IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status      OUT VARCHAR2(1)
--          x_msg_count          OUT NUMBER
--          x_msg_data           OUT VARCHAR2(2000)
--          x_partner_id         OUT NUMBER
--          x_default_resp_id    OUT NUMBER
--          x_resp_map_rule_id   OUT NOCOPY NUMBER
--          x_group_id           OUT NOCOPY NUMBER
--
--  Version : Current version   1.0
--            Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
  PROCEDURE Invite_Partner(
     p_api_version_number  IN  NUMBER
     ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
     ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
     ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status      OUT NOCOPY  VARCHAR2
     ,x_msg_data           OUT NOCOPY  VARCHAR2
     ,x_msg_count          OUT NOCOPY  NUMBER
/*
     ,p_organization_rec   IN  HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
     ,p_location_rec       IN  PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE
     ,p_party_site_rec     IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
*/

     ,p_party_id            IN Number
     ,p_partner_qualifiers_tbl  IN PV_TERR_ASSIGN_PUB.partner_qualifiers_tbl_type
--    ,p_partner_types_tbl  IN  partner_types_tbl_type
     ,p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type
     ,p_vad_partner_id     IN  NUMBER
     ,p_person_rec         IN  PV_PARTNER_UTIL_PVT.PERSON_REC_TYPE
     ,p_phone_rec          IN  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE
     ,p_email_rec          IN  HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE
     ,p_member_type        IN  VARCHAR2
     ,p_global_partner_id  IN  NUMBER
     ,x_partner_party_id   OUT NOCOPY NUMBER
     ,x_partner_id         OUT NOCOPY NUMBER
     ,x_cnt_party_id       OUT NOCOPY NUMBER
     ,x_cnt_partner_id     OUT NOCOPY NUMBER
     ,x_cnt_rel_start_date OUT NOCOPY DATE
     ,x_default_resp_id    OUT NOCOPY NUMBER
     ,x_resp_map_rule_id   OUT NOCOPY NUMBER
     ,x_group_id           OUT NOCOPY NUMBER
)  IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Invite_Partner';
   L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;

   -- Cursor l_partner_csr to get partner details
   CURSOR l_partner_csr (cv_party_id NUMBER) IS
     SELECT partner_id
     FROM   pv_partner_profiles
     WHERE  partner_party_id = cv_party_id;


   -- Details of local variables used in Create_Partner API call.
--   l_organization_rec      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE := p_organization_rec;
--   l_location_rec          PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE := p_location_rec;
--   l_party_site_rec        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE := p_party_site_rec;
   l_partner_types_tbl     PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type := p_partner_types_tbl;
   l_partner_id            NUMBER ;
   l_vad_partner_id        NUMBER :=  p_vad_partner_id;
   l_member_type           VARCHAR2(30) := p_member_type;
   l_global_partner_id     NUMBER := p_global_partner_id;
   l_partner_party_id      NUMBER;
   l_default_resp_id       NUMBER;
   l_resp_map_rule_id      NUMBER;
   l_group_id              NUMBER;

    l_party_id              NUMBER := p_party_id;
    l_partner_qualifiers_tbl PV_TERR_ASSIGN_PUB.partner_qualifiers_tbl_type := p_partner_qualifiers_tbl;
   -- Details of local variables used in Create_Person API call.
   l_person_rec            HZ_PARTY_V2PUB.PERSON_REC_TYPE := HZ_PARTY_V2PUB.g_miss_person_rec;
   l_cnt_per_party_id      NUMBER;
   l_cnt_per_party_number  NUMBER;
   l_cnt_per_profile_id    NUMBER;


   -- Details of local variables used in Create_Org_Contact API call.
   l_org_contact_rec       HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type ;
   l_org_contact_id        NUMBER;
   l_contact_rel_id        NUMBER;
   l_contact_rel_party_id  NUMBER;
   l_person_party_number   NUMBER;

   -- Details of local variables used in Create_Phone_Contact_Point API call.
   l_contact_point_rec     HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE ;
   l_phone_rec             HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE := p_phone_rec;
   l_phone_cnt_point_id    NUMBER;

   -- Details of local variables used in Create_Email_Contact_Point API call.
   l_email_rec             HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE := p_email_rec;
   l_email_cnt_point_id    NUMBER;

   -- Some common local variables used by all the API call.
   l_application_id        NUMBER := 691; -- FND_GLOBAL.application_id;
   l_appl_short_name       VARCHAR2(5) := 'PV'; -- FND_GLOBAL.APPLICATION_SHORT_NAME;

   -- Local variable declaration for Standard Out variables.
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);

BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT invite_partner_pvt;

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
      PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization


   -- Call the Create_Partner API to create the following -
   --     *  Partner Organization record in HZ_PARTIES table
   --     *  Partner Location record in HZ_LOCATIONS table
   --     *  Partner Party Site record in HZ_PARTY_SITES table
   --     *  Call the Create_Relationship API to create the followings -
   -- 		o  Get the Default responsibility for the supplied Organization Id
   --       	o  Get the default vendor org id, for the supplied Responsibility id
   --     	o  Create Partner Relationship record in HZ_RELATIONSHIPS table
   -- 		o  Create resource for the partner by calling the Admin_Resource API
   -- 		o  Create role for the resource by calling Admin_Role API
   --  		o  Create Group for the partner resource by calling Admin_Group API

/*
      Create_Partner(
        p_api_version_number =>  1.0,
        p_init_msg_list      =>  FND_API.G_FALSE ,
        p_commit             =>  FND_API.G_FALSE ,
        p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status      =>  l_return_status,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data,
        p_organization_rec   =>  l_organization_rec   ,
        p_location_rec       =>  l_location_rec,
        p_party_site_rec     =>  l_party_site_rec,
        p_partner_types_tbl  =>  l_partner_types_tbl,
        p_vad_partner_id     =>  l_vad_partner_id,
        p_member_type        =>  l_member_type,
        p_global_partner_id  =>  l_global_partner_id  ,
        x_party_id           =>  l_partner_party_id,
        x_default_resp_id    =>  l_default_resp_id,
        x_resp_map_rule_id   =>  l_resp_map_rule_id   ,
        x_group_id           =>  l_group_id );

*/


      Do_Create_Relationship(
            p_api_version_number => 1.0
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status     => l_return_status
            ,x_msg_data          => l_msg_data
            ,x_msg_count         => l_msg_count
            ,p_party_id	         => l_party_id
            ,p_partner_types_tbl => p_partner_types_tbl
            ,p_vad_partner_id    => p_vad_partner_id
            ,p_member_type       => p_member_type
            ,p_global_partner_id => p_global_partner_id
            ,p_partner_qualifiers_tbl => l_partner_qualifiers_tbl
            ,x_partner_id        => x_partner_id
            ,x_default_resp_id   => x_default_resp_id
            ,x_resp_map_rule_id  => x_resp_map_rule_id
            ,x_group_id          => x_group_id
        	    );


   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    Create_Search_Attr_Values (
             p_api_version_number => 1.0
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,x_return_status     => l_return_status
            ,x_msg_data          => l_msg_data
            ,x_msg_count         => l_msg_count
            ,p_partner_id        => x_partner_id
        	);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;


   -- Map the person-rec from PV_PARTNER_UTIL_PVT's person_rec_type to
   -- HZ_PARTY_V2PUB's person_rec_type
      map_person_rec( p_person_rec  => p_person_rec,
                      x_person_rec  => l_person_rec);

   -- Call the Create_Person API to create the contact person as a Party record
   -- in HZ_PARTIES table.
      HZ_PARTY_V2PUB.create_person (
        p_init_msg_list      =>  FND_API.G_FALSE,
        p_person_rec         =>  l_person_rec,
        x_party_id           =>  l_cnt_per_party_id,
        x_party_number       =>  l_cnt_per_party_number,
	x_profile_id         =>  l_cnt_per_profile_id,
	x_return_status      =>  l_return_status,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_PARTY_V2PUB.create_person');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Iniliatize the local variables required for Relationship creation
   -- between the Contact and the Partner Organinzation.
      l_org_contact_rec.application_id := l_application_id;
      l_org_contact_rec.created_by_module:= l_appl_short_name;
      l_org_contact_rec.party_rel_rec.subject_id := l_cnt_per_party_id;
      l_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
      l_org_contact_rec.party_rel_rec.subject_table_name := 'HZ_PARTIES';
      l_org_contact_rec.party_rel_rec.object_id := l_party_id ;
      l_org_contact_rec.party_rel_rec.object_type := 'ORGANIZATION';
      l_org_contact_rec.party_rel_rec.object_table_name := 'HZ_PARTIES';
      l_org_contact_rec.party_rel_rec.relationship_code := 'EMPLOYEE_OF';
      l_org_contact_rec.party_rel_rec.relationship_type := 'EMPLOYMENT';
      l_org_contact_rec.party_rel_rec.start_date := SYSDATE;
      l_org_contact_rec.party_rel_rec.created_by_module:= l_appl_short_name;
      l_org_contact_rec.party_rel_rec.application_id:= l_application_id;
      l_org_contact_rec.party_rel_rec.status:= 'A';

   -- Call the Create_Org_Contact API to create a contact person relationship record
   -- with the Partner organization in HZ_RELATIONSHIPS table.
      HZ_PARTY_CONTACT_V2PUB.create_org_contact (
    	p_init_msg_list      =>  FND_API.G_FALSE,
    	p_org_contact_rec    =>  l_org_contact_rec,
	x_org_contact_id     =>  l_org_contact_id,
	x_party_rel_id       =>  l_contact_rel_id,
    	x_party_id           =>  l_contact_rel_party_id,
    	x_party_number       =>  l_person_party_number,
    	x_return_status      =>  l_return_status,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_PARTY_CONTACT_V2PUB.create_org_contact');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Call the create_phone_contact_point API to create a Phone type Contact Point record
   -- in HZ_CONTACT_POINTS table.

      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := l_contact_rel_party_id;
      l_contact_point_rec.status := 'A';
      l_contact_point_rec.primary_flag := 'Y';
      l_contact_point_rec.contact_point_type := 'PHONE';
      l_contact_point_rec.application_id :=  l_application_id;
      l_contact_point_rec.created_by_module:= l_appl_short_name;
      l_phone_rec.phone_line_type := 'GEN';

      HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
    	p_init_msg_list      =>  FND_API.G_TRUE,
        p_contact_point_rec  =>  l_contact_point_rec,
	p_phone_rec          =>  l_phone_rec,
        x_contact_point_id   =>  l_phone_cnt_point_id,
	x_return_status      =>  l_return_status,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CONTACT_POINT_V2PUB.create_phone_contact_point');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- Call the create_email_contact_point API to create a Email type Contact Point record
   -- in HZ_CONTACT_POINTS table.

      l_contact_point_rec.contact_point_type := 'EMAIL';

      HZ_CONTACT_POINT_V2PUB.create_email_contact_point (
    	p_init_msg_list      =>  FND_API.G_FALSE,
        p_contact_point_rec  =>  l_contact_point_rec,
        p_email_rec          =>  l_email_rec,
        x_contact_point_id   =>  l_email_cnt_point_id,
	x_return_status      =>  l_return_status,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CONTACT_POINT_V2PUB.create_email_contact_point');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   -- set the out variables
--      x_partner_party_id   := l_partner_party_id;
      x_partner_party_id   := l_party_id;
      x_cnt_party_id       := l_cnt_per_party_id;
      x_cnt_partner_id     := l_contact_rel_party_id;
      x_cnt_rel_start_date := l_org_contact_rec.party_rel_rec.start_date;
      x_default_resp_id    := l_default_resp_id;
      x_resp_map_rule_id   := l_resp_map_rule_id;
      x_group_id           := l_group_id;

      OPEN l_partner_csr(l_party_id);
      FETCH l_partner_csr INTO l_partner_id;
      CLOSE l_partner_csr;
      x_partner_id         := l_partner_id;

   -- Call Create_Default_Membership API to create membership into a
   -- default program to fix bug # 3435989.

   -- Commented out by SPEDDU on 11/22/05 as this call is part of do_create_relationship API as part of fix bug # 4748978

   /** pv_prgm_approval_pvt.Create_Default_Membership (
        p_api_version_number  =>  1.0
        ,p_init_msg_list      =>  FND_API.G_FALSE
        ,p_commit             =>  FND_API.G_FALSE
        ,p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL
        ,p_partner_id         => l_partner_id
        ,p_requestor_resource_id => -1
	,x_return_status      =>  l_return_status
        ,x_msg_count          =>  l_msg_count
        ,x_msg_data           =>  l_msg_data);

   -- Check for return status of the API call.
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_PRGM_APPROVAL_PVT.Create_Default_Membership');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
      **/

   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' end.');
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invite_partner_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invite_partner_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
      ROLLBACK TO invite_partner_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

End Invite_Partner;


-- -------------------------------------------------------------------------------
-- FUNCTION:       can_see_all_partners
--
-- Given a resource_id, the function returns
--
-- 0 - if the resource does not have any of the following permissions:
--     PV_UPDATE_ALL_PARTNERS, PV_VIEW_ALL_PARTNERS
--
-- 1 - if the resource has either or both or the permissions:
--     PV_UPDATE_ALL_PARTNERS, PV_VIEW_ALL_PARTNERS
--
-- -------------------------------------------------------------------------------
FUNCTION can_see_all_partners (
   p_resource_id  IN NUMBER
)
RETURN NUMBER
IS
   l_ret_val NUMBER := 0;

BEGIN
   FOR x IN (
      SELECT COUNT(*) cnt
      FROM   jtf_rs_resource_extns   jtfre,
             jtf_auth_principals_b   jtfp1,
             jtf_auth_principal_maps jtfpm,
             jtf_auth_domains_b      jtfd,
             jtf_auth_principals_b   jtfp2,
             jtf_auth_role_perms     jtfrp,
             jtf_auth_permissions_b  jtfperm
      WHERE  jtfre.resource_id                  = p_resource_id AND
             jtfre.user_name                    = jtfp1.principal_name AND
             jtfp1.is_user_flag                 = 1 AND
             jtfp1.jtf_auth_principal_id        = jtfpm.jtf_auth_principal_id AND
             jtfpm.jtf_auth_domain_id           = jtfd.jtf_auth_domain_id AND
             jtfd.domain_name                   = 'CRM_DOMAIN'  AND
             jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id AND
             jtfp2.is_user_flag                 = 0 AND
             jtfp2.jtf_auth_principal_id        = jtfrp.jtf_auth_principal_id AND
             jtfrp.positive_flag                = 1  AND
             jtfrp.jtf_auth_permission_id       = jtfperm.jtf_auth_permission_id AND
             jtfperm.permission_name IN ('PV_UPDATE_ALL_PARTNERS', 'PV_VIEW_ALL_PARTNERS'))
   LOOP
      IF (x.cnt > 0) THEN
         l_ret_val := 1;
      END IF;
   END LOOP;

   RETURN l_ret_val;
END;


END PV_PARTNER_UTIL_PVT;

/
