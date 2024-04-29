--------------------------------------------------------
--  DDL for Package JTF_TERR_SALES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_SALES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptsas.pls 120.0 2005/06/02 18:20:56 appldev ship $ */
---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_SALES_TERRITORY_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core Sales territory manager public api's.
--      This package is a public API for getting winning territories
--      or territory resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/14/99    VNEDUNGA         Created
--      12/22/99    vnedunga         Making chnages to filter
--                                   resource by resource type
--
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrAccount_Rec          IN    JTF_TERRITORY_PUB.JTF_Account_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
);


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers ### BULK ###
--    type           : public.
--    function       : Get winning territories members for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrAccount_Rec          IN    JTF_TERRITORY_PUB.JTF_Account_BULK_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_winners_rec              OUT NOCOPY   JTF_TERRITORY_PUB.Winning_BULK_rec_type,
    p_top_level_terr_id        IN    NUMBER := FND_API.G_MISS_NUM,
    p_num_winners              IN    NUMBER := FND_API.G_MISS_NUM
);


--    Start of Comments
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerritories
--    type           : public.
--    function       : Get the WINNING territories for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :
--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retrieving the winning territories
--                        This is an overloaded procedure for accounts,lead,
--                        opportunity, service requests, and collections.
--
--
-- end of comments
procedure Get_WinningTerritories
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    p_TerrAcct_Rec             IN    JTF_TERRITORY_PUB.JTF_Account_rec_type
);

--
--    Start of Comments
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerritories ### BULK ###
--    type           : public.
--    function       : Get the WINNING territories for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :
--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retrieving the winning territories
--                        This is an overloaded procedure for accounts,lead,
--                        opportunity, service requests, and collections.
--
--
-- end of comments

procedure Get_WinningTerritories
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    p_TerrAcct_Rec             IN    JTF_TERRITORY_PUB.JTF_Account_BULK_rec_type,
    x_winners_rec              OUT NOCOPY JTF_TERRITORY_PUB.Winning_BULK_rec_type,
    p_top_level_terr_id        IN    NUMBER := FND_API.G_MISS_NUM,
    p_num_winners              IN    NUMBER := FND_API.G_MISS_NUM,
    p_role                     IN    VARCHAR2 := FND_API.G_MISS_CHAR
);


/*========================================================================================*/
/*========================= OPPORTUNITY ==================================================*/
/*========================================================================================*/

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### SINGLE ###
--    type           : public.
--    function       : Get winning territories members for an OPPORTUNITY
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrOppor_Rec            IN    JTF_TERRITORY_PUB.JTF_Oppor_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
) ;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### BULK ###
--    type           : public.
--    function       : Get winning territories members for an OPPORTUNITY
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrOppor_Rec            IN    JTF_TERRITORY_PUB.JTF_Oppor_BULK_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_winners_rec              OUT NOCOPY   JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE
);


/*========================================================================================*/
/*========================= LEAD =========================================================*/
/*========================================================================================*/


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers  ### SINGLE ###
--    type           : public.
--    function       : Get winning territories members for a LEAD
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrLead_Rec             IN    JTF_TERRITORY_PUB.JTF_Lead_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         out   NOCOPY JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
);

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### BULK ###
--    type           : public.
--    function       : Get winning territories members for a LEAD
--    pre-reqs       : Territories needs to be setup first
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrLead_Rec             IN    JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_winners_rec              out   NOCOPY JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE
);



END JTF_TERR_SALES_PUB;

 

/
