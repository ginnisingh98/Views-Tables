--------------------------------------------------------
--  DDL for Package PV_PARTNER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvputs.pls 120.4 2005/11/14 21:03:45 pinagara ship $ */

/*----------------------------------------------------------------------------
-- HISTORY
--    20-SEP-2002   rdsharma  Created
-----------------------------------------------------------------------------*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PARTNER_UTIL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvputs.pls';

 geometry_status_code_default   CONSTANT VARCHAR2(30) := 'DIRTY';
 g_miss_content_source_type     CONSTANT VARCHAR2(30) := 'USER_ENTERED';
/*-----------------------------------------------------------------------------
-- Declaration of Location_rec_type
------------------------------------------------------------------------------*/

TYPE location_rec_type IS RECORD(
    location_id                  NUMBER,
    orig_system_reference        VARCHAR2(240),
    orig_system			         VARCHAR2(30),
    country                      VARCHAR2(60),
    address1                     VARCHAR2(240),
    address2                     VARCHAR2(240),
    address3                     VARCHAR2(240),
    address4                     VARCHAR2(240),
    city                         VARCHAR2(60),
    postal_code                  VARCHAR2(60),
    state                        VARCHAR2(60),
    province                     VARCHAR2(60),
    county                       VARCHAR2(60),
    address_key                  VARCHAR2(500),
    address_style                VARCHAR2(30),
    validated_flag               VARCHAR2(1),
    address_lines_phonetic       VARCHAR2(560),
    po_box_number                VARCHAR2(50),
    house_number                 VARCHAR2(50),
    street_suffix                VARCHAR2(50),
    street                       VARCHAR2(50),
    street_number                VARCHAR2(50),
    floor                        VARCHAR2(50),
    suite                        VARCHAR2(50),
    postal_plus4_code            VARCHAR2(10),
    position                     VARCHAR2(50),
    location_directions          VARCHAR2(640),
    address_effective_date       DATE,
    address_expiration_date      DATE,
    clli_code                    VARCHAR2(60),
    language                     VARCHAR2(4) ,
    short_description            VARCHAR2(240),
    description                  VARCHAR2(2000),
    geometry_status_code         VARCHAR2(30) := geometry_status_code_default,
    loc_hierarchy_id             NUMBER,
    sales_tax_geocode            VARCHAR2(30),
    sales_tax_inside_city_limits VARCHAR2(30),
    fa_location_id               NUMBER,
    content_source_type          VARCHAR2(30) := g_miss_content_source_type,
    attribute_category           VARCHAR2(30) ,
    attribute1                   VARCHAR2(150),
    attribute2                   VARCHAR2(150),
    attribute3                   VARCHAR2(150),
    attribute4                   VARCHAR2(150),
    attribute5                   VARCHAR2(150),
    attribute6                   VARCHAR2(150),
    attribute7                   VARCHAR2(150),
    attribute8                   VARCHAR2(150),
    attribute9                   VARCHAR2(150),
    attribute10                  VARCHAR2(150),
    attribute11                  VARCHAR2(150),
    attribute12                  VARCHAR2(150),
    attribute13                  VARCHAR2(150),
    attribute14                  VARCHAR2(150),
    attribute15                  VARCHAR2(150),
    attribute16                  VARCHAR2(150),
    attribute17                  VARCHAR2(150),
    attribute18                  VARCHAR2(150),
    attribute19                  VARCHAR2(150),
    attribute20                  VARCHAR2(150),
    timezone_id                  NUMBER,
    created_by_module            VARCHAR2(150),
    application_id               NUMBER,
    actual_content_source        VARCHAR2(30)
  );

/*-----------------------------------------------------------------------------
-- Declaration of person_rec_type
------------------------------------------------------------------------------*/
TYPE person_rec_type IS RECORD(
    person_pre_name_adjunct         VARCHAR2(30),
    person_first_name               VARCHAR2(150),
    person_middle_name              VARCHAR2(60),
    person_last_name                VARCHAR2(150),
    person_name_suffix              VARCHAR2(30),
    person_title                    VARCHAR2(60),
    person_academic_title           VARCHAR2(30),
    person_previous_last_name       VARCHAR2(150),
    person_initials                 VARCHAR2(6),
    known_as                        VARCHAR2(240),
    known_as2                       VARCHAR2(240),
    known_as3                       VARCHAR2(240),
    known_as4                       VARCHAR2(240),
    known_as5                       VARCHAR2(240),
    person_name_phonetic            VARCHAR2(320),
    person_first_name_phonetic      VARCHAR2(60),
    person_last_name_phonetic       VARCHAR2(60),
    middle_name_phonetic            VARCHAR2(60),
    tax_reference                   VARCHAR2(50),
    jgzz_fiscal_code                VARCHAR2(20),
    person_iden_type                VARCHAR2(30),
    person_identifier               VARCHAR2(60),
    date_of_birth                   DATE,
    place_of_birth                  VARCHAR2(60),
    date_of_death                   DATE,
    deceased_flag                   VARCHAR2(1),
    gender                          VARCHAR2(30),
    declared_ethnicity              VARCHAR2(60),
    marital_status                  VARCHAR2(30),
    marital_status_effective_date   DATE,
    personal_income                 NUMBER,
    head_of_household_flag          VARCHAR2(1),
    household_income                NUMBER,
    household_size                  NUMBER,
    rent_own_ind                    VARCHAR2(30),
    last_known_gps                  VARCHAR2(60),
    content_source_type             VARCHAR2(30):= HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE,
    internal_flag                   VARCHAR2(2),
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150) ,
    attribute2                      VARCHAR2(150) ,
    attribute3                      VARCHAR2(150) ,
    attribute4                      VARCHAR2(150) ,
    attribute5                      VARCHAR2(150) ,
    attribute6                      VARCHAR2(150) ,
    attribute7                      VARCHAR2(150) ,
    attribute8                      VARCHAR2(150) ,
    attribute9                      VARCHAR2(150) ,
    attribute10                     VARCHAR2(150) ,
    attribute11                     VARCHAR2(150) ,
    attribute12                     VARCHAR2(150) ,
    attribute13                     VARCHAR2(150) ,
    attribute14                     VARCHAR2(150) ,
    attribute15                     VARCHAR2(150) ,
    attribute16                     VARCHAR2(150) ,
    attribute17                     VARCHAR2(150) ,
    attribute18                     VARCHAR2(150) ,
    attribute19                     VARCHAR2(150) ,
    attribute20                     VARCHAR2(150) ,
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    actual_content_source           VARCHAR2(30) := HZ_PARTY_V2PUB.G_SST_SOURCE_TYPE,
    party_rec                       HZ_PARTY_V2PUB.PARTY_REC_TYPE := HZ_PARTY_V2PUB.G_MISS_PARTY_REC
);

 G_MISS_PERSON_REC                   PERSON_REC_TYPE;

/**** Commented out for 11.5.11 or R12 release.
TYPE partner_rec_type IS RECORD
(
 partner_type       VARCHAR2(500)
);

TYPE  partner_types_tbl_type   IS TABLE OF partner_rec_type INDEX BY BINARY_INTEGER;
g_miss_partner_types_tbl     partner_types_tbl_type;
******/

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
--  IN    : p_api_version         IN NUMBER   Required
--          p_init_msg_list       IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit              IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level    IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_organization_rec    IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE Required
--          p_location_rec        IN PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE  Required
--          p_party_site_rec      IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
--
--  OUT   : x_return_status       OUT VARCHAR2(1)
--          x_msg_count           OUT NUMBER
--          x_msg_data            OUT VARCHAR2(2000)
--          x_party_id            OUT NUMBER
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
    x_group_id            OUT NOCOPY NUMBER);

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
	 );
/*============================================================================
-- Start of comments
--  API name  : Create_Relationship
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
  PROCEDURE Create_Relationship(
     p_api_version_number IN  NUMBER
     ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
     ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
     ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status     OUT NOCOPY  VARCHAR2
     ,x_msg_data          OUT NOCOPY  VARCHAR2
     ,x_msg_count         OUT NOCOPY  NUMBER
     ,p_party_id	  IN  NUMBER
--     ,p_partner_types_tbl IN  partner_types_tbl_type := g_miss_partner_types_tbl
     ,p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type
     ,p_vad_partner_id    IN  NUMBER
     ,p_member_type       IN  VARCHAR2
     ,p_global_partner_id   IN  NUMBER
     ,x_partner_id        OUT NOCOPY NUMBER
     ,x_default_resp_id   OUT NOCOPY NUMBER
     ,x_resp_map_rule_id  OUT NOCOPY NUMBER
     ,x_group_id          OUT NOCOPY NUMBER
) ;


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
) ;


/*============================================================================
-- Start of comments
--  API name  : Invite_Partner
--  Type      : Public.
--  Function  : This API consolidates few partner creation related operations in
--
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version         IN NUMBER   Required
--          p_init_msg_list       IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_commit              IN VARCHAR2 Optional Default = FND_API.G_FALSE
--          p_validation_level    IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--
--          p_organization_rec    IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE Required
--          p_location_rec        IN PV_PARTNER_UTIL_PVT.LOCATION_REC_TYPE  Required
--          p_party_site_rec      IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE Required
--          p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.ATTR_VALUE_TBL_TYPE
--          p_vad_partner_id      IN NUMBER
--          p_person_rec          IN  PV_PARTNER_UTIL_PVT.PERSON_REC_TYPE
--          p_phone_rec           IN  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE
--          p_email_rec           IN  HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE
--          p_member_type         IN  VARCHAR2
--          p_global_partner_id   IN  NUMBER
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
--     ,p_partner_types_tbl  IN  partner_types_tbl_type := g_miss_partner_types_tbl
     ,p_partner_types_tbl   IN PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type
     ,p_vad_partner_id     IN  NUMBER
     ,p_person_rec         IN  PV_PARTNER_UTIL_PVT.PERSON_REC_TYPE
     ,p_phone_rec          IN  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE := HZ_CONTACT_POINT_v2PUB.g_miss_phone_rec
     ,p_email_rec          IN  HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE := HZ_CONTACT_POINT_v2PUB.g_miss_email_rec
     ,p_member_type        IN  VARCHAR2
     ,p_global_partner_id  IN  NUMBER
     ,x_partner_party_id   OUT NOCOPY NUMBER
     ,x_partner_id         OUT NOCOPY NUMBER
     ,x_cnt_party_id       OUT NOCOPY NUMBER
     ,x_cnt_partner_id     OUT NOCOPY NUMBER
     ,x_cnt_rel_start_date OUT NOCOPY DATE
     ,x_default_resp_id    OUT NOCOPY NUMBER
     ,x_resp_map_rule_id   OUT NOCOPY NUMBER
     ,x_group_id           OUT NOCOPY NUMBER ) ;


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
RETURN NUMBER;


END PV_PARTNER_UTIL_PVT;

 

/
