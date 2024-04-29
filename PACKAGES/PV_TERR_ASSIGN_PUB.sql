--------------------------------------------------------
--  DDL for Package PV_TERR_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_TERR_ASSIGN_PUB" AUTHID CURRENT_USER as
/* $Header: pvxpptas.pls 120.2 2005/08/11 00:18:42 appldev ship $ */

 g_partner_name        CONSTANT NUMBER := -1702 ;
 g_city                CONSTANT NUMBER := -1066 ;
 g_county              CONSTANT NUMBER := -1069 ;
 g_state               CONSTANT NUMBER := -1068 ;
 g_province            CONSTANT NUMBER := -1071 ;
 g_postal_code         CONSTANT NUMBER := -1067 ;
 g_country             CONSTANT NUMBER := -1065 ;
 g_area_code           CONSTANT NUMBER := -1009 ;
 g_cust_catgy_code     CONSTANT NUMBER := -1081 ;
 g_partner_type        CONSTANT NUMBER := -1703 ;
 g_partner_level       CONSTANT NUMBER := -1704 ;
 g_number_of_employee  CONSTANT NUMBER := -1016 ;
 g_Annual_Revenue      CONSTANT NUMBER := -1101 ;

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             partner_qualifiers_rec_type
--   -------------------------------------------------------
--   Parameters:
--       partner_name
--       area_code
--       city
--       country
--       county
--       postal_code
--       province
--       state
--       Annual_Revenue
--       number_of_employee
--       customer_category_code
--       partner_type
--       partner_level
--
--    Required
--
--    Defaults
--
--   End of Comments

--===================================================================
TYPE partner_qualifiers_rec_type IS RECORD
(
       partner_name            VARCHAR2(360),
       party_site_id           NUMBER,
       party_id                NUMBER,
       area_code               VARCHAR2(10),
       city                    VARCHAR2(60),
       country                 VARCHAR2(60),
       county                  VARCHAR2(60),
       postal_code             VARCHAR2(60),
       province                VARCHAR2(60),
       state                   VARCHAR2(60),
       Annual_Revenue          NUMBER,
       number_of_employee      NUMBER,
       customer_category_code  VARCHAR2(30),
       partner_type            VARCHAR2(500),
       partner_level           VARCHAR2(30)
);

g_miss_partner_qualifiers_rec          partner_qualifiers_rec_type := NULL;
TYPE  partner_qualifiers_tbl_type      IS TABLE OF partner_qualifiers_rec_type INDEX BY BINARY_INTEGER;
g_miss_partner_qualifiers_tbl          partner_qualifiers_tbl_type;

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             prtnr_qflr_flg_rec_type
--   -------------------------------------------------------
--   Parameters:
--       partner_name_flg
--       party_site_id_flg
--       area_code_flg
--       city_flg
--       country_flg
--       county_flg
--       postal_code_flg
--       province_flg
--       state_flg
--       Annual_Revenue_flg
--       number_of_employee_flg
--       cust_catgy_code_flg
--       partner_type_flg
--       partner_level_flg
--
--    Required
--
--    Defaults
--
--   End of Comments

--===================================================================
TYPE prtnr_qflr_flg_rec_type IS RECORD
(
       partner_name_flg        VARCHAR2(1),
       party_site_id_flg       VARCHAR2(1),
       area_code_flg           VARCHAR2(1),
       city_flg                VARCHAR2(1),
       country_flg             VARCHAR2(1),
       county_flg              VARCHAR2(1),
       postal_code_flg         VARCHAR2(1),
       province_flg            VARCHAR2(1),
       state_flg               VARCHAR2(1),
       Annual_Revenue_flg      VARCHAR2(1),
       number_of_employee_flg  VARCHAR2(1),
       cust_catgy_code_flg     VARCHAR2(1),
       partner_type_flg        VARCHAR2(1),
       partner_level_flg       VARCHAR2(1)
);

g_miss_prtnr_qflr_flg_rec      prtnr_qflr_flg_rec_type := NULL;
TYPE  prtnr_qflr_flg_tbl_type  IS TABLE OF prtnr_qflr_flg_rec_type INDEX BY BINARY_INTEGER;
g_miss_prtnr_qflr_flg_tbl      prtnr_qflr_flg_tbl_type;

-- Start of Comments
--
--      Funtion name  : chk_prtnr_qflr_enabled
--      Type      : Public
--      Function  : The purpose of this function is to find out, whether
--                  the supplied partner qualifiers is enabled or not.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--			p_prtnr_qualifier   IN NUMBER
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Procedure to find out, whther the supplied partner qualifier
--                      is enabled in the Qualifier Setup.
--
--
-- End of Comments
FUNCTION chk_prtnr_qflr_enabled (p_prtnr_qualifier IN  NUMBER )
RETURN VARCHAR2 ;

TYPE ResourceList is TABLE OF NUMBER(15);
TYPE PersonList is TABLE OF NUMBER(15);
TYPE ResourceCategoryList is TABLE OF VARCHAR2(30);
TYPE GroupList is TABLE OF NUMBER(15);

TYPE ResourceRec is RECORD (
	resource_id       ResourceList ,
	person_id         PersonList ,
	resource_category ResourceCategoryList ,
	group_id          GroupList );

PROCEDURE GET_RES_FROM_TEAM_GROUP(
     P_RESOURCE_ID   IN NUMBER,
     P_RESOURCE_TYPE IN VARCHAR2,
     X_RESOURCE_REC  OUT NOCOPY PV_TERR_ASSIGN_PUB.ResourceRec
);

TYPE prtnr_aces_rec_type IS RECORD(
   partner_access_id        NUMBER );

g_miss_prtnr_aces_rec_type      prtnr_aces_rec_type := NULL;
TYPE  prtnr_aces_tbl_type  IS TABLE OF prtnr_aces_rec_type INDEX BY BINARY_INTEGER;
g_miss_prtnr_aces_tbl      prtnr_aces_tbl_type;



-- Start of Comments
--
--      API name  : Get_Partner_Details
--      Type      : Public
--      Function  : The purpose of this procedure is to build a partner qualifiers
--                  table for a given party_id
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--              p_party_id             IN  NUMBER
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_partner_qualifiers_tbl  OUT   partner_qualifiers_tbl_type
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE get_partner_details (
   p_party_id                IN   NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_partner_qualifiers_tbl  OUT NOCOPY  partner_qualifiers_tbl_type );

-- Start of Comments
--
-- NAME
--   PV_TERR_ASSIGN_PUB
--
-- PURPOSE
--   This package is a public API to create the channel team based on the user as well
--   as the pre defined qualifiers for the partner. This API will call the Do_Create_channel_team
--   which does all the required processing.This is more of an overloaded method for Do_Create_channel_team
--
--   Procedures:
--	Do_Create_Channel_Team
--
-- NOTES
--   This package is for private use only
--
--      Pre-reqs  : Existing resource should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    	p_validation_level     IN      NUMBER
--      p_partner_id           IN  NUMBER
--      p_vad_partner_id       IN  NUMBER
--      p_mode                 IN  VARCHAR2
--      p_login_user          IN  NUMBER ,
--
--
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     PV_TERR_ASSIGN_PUB.PartnerAccessRec
--
--      Version :
--                      Initial version         1.0
--
-- HISTORY
--   07/27/05   pinagara    Created
--
-- End of Comments

PROCEDURE Create_Channel_Team
(  p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);

-- Start of Comments
--
-- NAME
--   PV_TERR_ASSIGN_PUB
--
-- PURPOSE
--   This package is a public API to create the channel team based on the user as well
--   as the pre defined qualifiers for the partner. This API inturn calls apis to create
--   the channel team based on territory as well as the logged in user.
--
--   Procedures:
--	Do_Create_Channel_Team
--
-- NOTES
--   This package is for private use only
--
--      Pre-reqs  : Existing resource should have a "Channel Manager" or
--                  "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    	p_validation_level     IN      NUMBER
--      p_partner_id           IN  NUMBER
--      p_vad_partner_id       IN  NUMBER
--      p_mode                 IN  VARCHAR2
--      p_login_user          IN  NUMBER ,
--      p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
--
--
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     PV_TERR_ASSIGN_PUB.PartnerAccessRec
--
--      Version :
--                      Initial version         1.0
--
-- HISTORY
--   07/27/05   pinagara    Created
--
-- End of Comments

PROCEDURE Do_Create_Channel_Team
(  p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 ,
   p_login_user          IN  NUMBER ,
   p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);


-- Start of Comments
--
--      API name        : Create_Online_Channel_Team
--      Type            : Public
--      Function        : The purpose of this procedure is to create a Channel
--                        team for a given Partner_id in the PV_PARTNER_ACCESSES
--                        table.
--
--      Pre-reqs        : Existing resource should be a "Channel Manager" or
--                        "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--			 p_api_version_number   IN      NUMBER,
--		         p_init_msg_list        IN      VARCHAR2
--		         p_commit               IN      VARCHAR2
--    		         p_validation_level	IN	NUMBER
--
--                       p_partner_id           IN      NUMBER
--                       p_vad_partner_id       IN      NUMBER
--                       p_login_user           IN      NUMBER
--                       p_mode                 IN      VARCHAR2
--      OUT             :
--                       x_return_status        OUT     VARCHAR2(1)
--                       x_msg_count            OUT     NUMBER
--                       x_msg_data             OUT     VARCHAR2(2000)
--                       x_prtnr_access_id_tbl  OUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE Create_Online_Channel_Team
(       p_api_version_number  IN  NUMBER ,
        p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
	    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
	    p_partner_id          IN  NUMBER ,
        p_vad_partner_id      IN  NUMBER ,
        p_mode                IN  VARCHAR2 ,
        p_login_user          IN  NUMBER ,
        x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);

--Obsoleted
PROCEDURE Do_Cr_Online_Chnl_Team
(       p_api_version_number  IN  NUMBER ,
        p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
	    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
	    p_partner_id          IN  NUMBER ,
        p_vad_partner_id      IN  NUMBER ,
        p_mode                IN  VARCHAR2 ,
        p_login_user          IN  NUMBER ,
        p_partner_qualifiers_tbl  IN partner_qualifiers_tbl_type,
        x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);

-- Start of Comments
--
--      API name        : Create_VAD_Channel_Team
--      Type            : Public
--      Function        : The purpose of this procedure is to create a Channel
--                        team of all VAD employees for a given VAD_Partner_id in
--                        the PV_PARTNER_ACCESSES table.
--
--      Pre-reqs        : Existing resource should be a "Channel Manager" or
--                        "Channel Rep" role at group level.
--
--      Paramaeters     :
--      IN              :
--			 p_api_version_number   IN      NUMBER,
--		         p_init_msg_list        IN      VARCHAR2
--		         p_commit               IN      VARCHAR2
--    		         p_validation_level	IN	NUMBER
--
--                       p_partner_id           IN      NUMBER
--                       p_vad_partner_id       IN      NUMBER
--      OUT             :
--                       x_return_status        OUT     VARCHAR2(1)
--                       x_msg_count            OUT     NUMBER
--                       x_msg_data             OUT     VARCHAR2(2000)
--
--                       x_prtnr_access_id_tbl  OUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team of VAD employees for a
--                      Partner Organization.
--
--
-- End of Comments

PROCEDURE Create_VAD_Channel_Team
(       p_api_version_number  IN  NUMBER ,
        p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
	    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
 	    p_partner_id          IN  NUMBER,
        p_vad_partner_id      IN  NUMBER,
        x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);

-- Start of Comments
--
--      API name  : Update_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to Update a Channel
--                  team of a given partner_id, whenever there is an update
--                  in any of the partner qualifiers.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--		p_api_version_number   IN      NUMBER,
--		p_init_msg_list        IN      VARCHAR2
--		p_commit               IN      VARCHAR2
--    		p_validation_level     IN      NUMBER
--
--              p_partner_id           IN  NUMBER
--              p_vad_partner_id       IN  NUMBER
--              p_mode                 IN  VARCHAR2
--              p_prtnr_qualifier_rec  IN  partner_qualifiers_rec_type
--      OUT             :
--              x_return_status        OUT     VARCHAR2(1)
--              x_msg_count            OUT     NUMBER
--              x_msg_data             OUT     VARCHAR2(2000)
--              x_prtnr_access_id_tbl  OUT     JTF_NUMBER_TABLE
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          API for creating a Channel Team for a Partner Organization.
--
--
-- End of Comments

PROCEDURE Update_Channel_Team
(  p_api_version_number  IN  NUMBER ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE ,
   p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
   p_partner_id          IN  NUMBER ,
   p_vad_partner_id      IN  NUMBER ,
   p_mode                IN  VARCHAR2 := 'UPDATE',
   p_login_user          IN  NUMBER ,
   p_upd_prtnr_qflr_flg_rec  IN  prtnr_qflr_flg_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_prtnr_access_id_tbl OUT NOCOPY prtnr_aces_tbl_type
);

-- Start of Comments
--
--      API name  : Assign_Channel_Team
--      Type      : Public
--      Function  : The purpose of this procedure is to Update the Channel
--                  team for all partner_id by running in TOTAL_MODE. This procedure attached to
--                  'Territory assignment for partners in TOTAL mode' concurrent request program.
--                  It reads all the partner_id from PV_PARTNER_PROFILES table and re-assign the
--                  channel team.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--              ERRBUF                OUT NOCOPY VARCHAR2,
--              RETCODE               OUT NOCOPY VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Concurrent request program for re-assignment of Channel Team
--                      for all the Partner Organizations stored in PV_PARTNER_PROFILES
--                      table.
--
--
-- End of Comments

PROCEDURE Assign_Channel_Team(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_mode                IN  VARCHAR2,
    p_first_partner_id    IN  NUMBER,
    p_last_partner_id     IN  NUMBER
    ) ;

--
--      API name  : Process_Sub_Territories
--      Type      : Public
--      Function  : The purpose  of  this procedure  is  to  Update the  Channel team for
--                  all those Partner's,  who  get  affected  by the  change in territory
--                  definition.  This  procedure attached to  'Re-define Channel team for
--                  specific territories'  concurrent request  program. It  reads all the
--                  partner_id  from  PV_PARTNER_ACCESSES table and re-assign the channel
--                  team.
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--              ERRBUF                OUT NOCOPY VARCHAR2,
--              RETCODE               OUT NOCOPY VARCHAR2
--
--      Version :
--                      Initial version         1.0
--
--      Notes:          Concurrent request program for re-assignment of Channel Team
--                      for all the Partner Organizations stored in PV_PARTNER_PROFILES
--                      table.
--
--
-- End of Comments

PROCEDURE Process_Sub_Territories(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_terr_id1            IN  NUMBER,
    p_terr_id2            IN  NUMBER,
    p_terr_id3            IN  NUMBER,
    p_terr_id4            IN  NUMBER,
    p_terr_id5            IN  NUMBER,
    p_terr_id6            IN  NUMBER,
    p_terr_id7            IN  NUMBER,
    p_terr_id8            IN  NUMBER,
    p_terr_id9            IN  NUMBER,
    p_terr_id10           IN  NUMBER,
    p_terr_id11           IN  NUMBER,
    p_terr_id12           IN  NUMBER,
    p_terr_id13           IN  NUMBER,
    p_terr_id14           IN  NUMBER,
    p_terr_id15           IN  NUMBER,
    p_terr_id16           IN  NUMBER,
    p_terr_id17           IN  NUMBER,
    p_terr_id18           IN  NUMBER,
    p_terr_id19           IN  NUMBER,
    p_terr_id20           IN  NUMBER ) ;


END PV_TERR_ASSIGN_PUB;


 

/
