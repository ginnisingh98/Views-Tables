--------------------------------------------------------
--  DDL for Package Body JTF_TERR_SALES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_SALES_PUB" AS
/* $Header: jtfptsab.pls 120.5 2005/11/11 15:00:50 achanda ship $ */
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
--      12/02/99    VNEDUNGA         Chaging the Dynamic SQL
--                                   Added a call to reset global variable
--                                   in the Gte_WinningTerrMember procedure
--      12/22/99    vnedunga         Making chnages to filter
--                                   resource by resource type
--      01/05/00    vnedunga         Making chnages to API to confirm
--                                   with new qualifier chnages
--      01/12/00    vnedunga         Adding Currency code get_WinnigTerr API
--      02/01/00    vnedunga         Chnaging the get resource SQL
--      02/08/00    vnedunga         Chnaging the get resource SQL, = NULL to IS NULL
--      02/08/00    vnedunga         Type in third_party_flag in oppor/lead api
--      02/24/00    vnedunga         Making chnages to call the newly designed
--                                   Generated Engine packages
--      02/24/00    vnedunga         Adding the code to rerturn Catch all
--                                   if there was no qualifying Territory
--      03/23/00    vnedunga         Making changes to return full_access_flag
--      05/04/00    vnedunga         Adding pricing_date for sales
--      06/14/00    vnedunga         Changeing the get winning Terr memeber api
--                                   to return group_id
--      06/19/00    vnedunga         Adding partner_id inplace of third_party_flag
--                                   and category_code in place of line_of_business
--      07/26/01    EIHSU            changed all char_list references to 360
--      07/31/01    EIHSU	     9i compatibility changes: no more tbl of records
--                         	     casted to table for cursor definition
--      05/25/05    achanda          Modified to 12.0 architecture
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_SALES_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfptsab.pls';

   G_NEW_LINE        VARCHAR2(02) := FND_GLOBAL.Local_Chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;


/*========================================================================================*/
/*========================= ACCOUNT ======================================================*/
/*========================================================================================*/

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### BULK ###
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
    x_winners_rec              OUT NOCOPY   JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE,
    p_top_level_terr_id        IN    NUMBER := FND_API.G_MISS_NUM,
    p_num_winners              IN    NUMBER := FND_API.G_MISS_NUM
)
AS
  l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers_Acct';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

  l_Counter                    NUMBER;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
  l_sysdate        DATE;

BEGIN
  null;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_WinningTerrMembers;



/*========================================================================================*/
/*========================= OPPORTUNITY ==================================================*/
/*========================================================================================*/

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
)
AS
  l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers_Oppor';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

  l_Counter                    NUMBER;
  l_sysdate                    DATE;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;

BEGIN

  null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_WinningTerrMembers;




/*========================================================================================*/
/*========================= LEAD =========================================================*/
/*========================================================================================*/

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
    x_winners_rec              OUT NOCOPY   JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE
)
AS
  l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers_Lead';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

  l_Counter                    NUMBER;
  l_sysdate                    DATE;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
  l_trans_rec      JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;

BEGIN
  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.begin',
                   'Start of the procedure jtf_terr_sales_pub.get_winningterrmembers');
  END IF;

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

  --
  -- API body
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate       := SYSDATE;

  FOR i IN p_TerrLead_Rec.sales_lead_id.FIRST .. p_TerrLead_Rec.sales_lead_id.LAST LOOP
    l_trans_rec.trans_object_id1 := jtf_terr_number_list(p_TerrLead_Rec.sales_lead_id(i));
    l_trans_rec.trans_object_id2 := jtf_terr_number_list(null);
    l_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
    l_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
    l_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
    l_trans_rec.txn_date := jtf_terr_date_list(null);

    JTY_ASSIGN_REALTIME_PUB.get_winners(
      p_api_version_number       => 1.0,
      p_init_msg_list            => FND_API.G_FALSE,
      p_source_id                => -1001,
      p_trans_id                 => -1003,
      p_mode                     => 'REAL TIME:RESOURCE',
      p_param_passing_mechanism  => 'PBR',
      p_program_name             => 'SALES/LEAD PROGRAM',
      p_trans_rec                => l_trans_rec,
      p_name_value_pair          => null,
      p_role                     => null,
      p_resource_type            => null,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      x_winners_rec              => lx_winners_rec
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.get_winners',
                       'API JTY_ASSIGN_REALTIME_PUB.get_winners has failed');
      END IF;
      RAISE	FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.get_winners',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.get_winners');
  END IF;

  /*
      lp_Lead_rec :=  p_terrlead_rec;
      lp_Lead_rec.trans_object_id := p_terrlead_rec.sales_lead_id;

      jtf_terr_1001_lead_dyn.search_terr_rules(
               p_rec            => lp_Lead_rec
             , x_rec            => x_winners_rec
             , p_role           => p_role
             , p_resource_type  => p_resource_type );
  */

  l_counter := lx_winners_rec.terr_id.FIRST;
  WHILE (l_counter <= lx_winners_rec.terr_id.LAST) LOOP

    x_winners_rec.PARTY_ID.EXTEND;
    x_winners_rec.PARTY_SITE_ID.EXTEND;
    x_winners_rec.TRANS_OBJECT_ID.EXTEND;
    x_winners_rec.TRANS_DETAIL_OBJECT_ID.EXTEND;
    x_winners_rec.TERR_ID.EXTEND;
    x_winners_rec.ABSOLUTE_RANK.EXTEND;
    x_winners_rec.TERR_RSC_ID.EXTEND;
    x_winners_rec.RESOURCE_ID.EXTEND;
    x_winners_rec.RESOURCE_TYPE.EXTEND;
    x_winners_rec.GROUP_ID.EXTEND;
    x_winners_rec.ROLE.EXTEND;
    x_winners_rec.PRIMARY_CONTACT_FLAG.EXTEND;
    x_winners_rec.FULL_ACCESS_FLAG.EXTEND;

    x_winners_rec.PARTY_ID(l_counter)                := lx_winners_rec.trans_object_id(l_counter);
    x_winners_rec.PARTY_SITE_ID(l_counter)           := lx_winners_rec.trans_detail_object_id(l_counter);
    x_winners_rec.TRANS_OBJECT_ID(l_counter)         := lx_winners_rec.trans_object_id(l_counter);
    x_winners_rec.TRANS_DETAIL_OBJECT_ID(l_counter)  := lx_winners_rec.trans_detail_object_id(l_counter);
    x_winners_rec.TERR_ID(l_counter)                 := lx_winners_rec.terr_id(l_counter);
    x_winners_rec.ABSOLUTE_RANK(l_counter)           := lx_winners_rec.absolute_rank(l_counter);
    x_winners_rec.TERR_RSC_ID(l_counter)             := lx_winners_rec.terr_rsc_id(l_counter);
    x_winners_rec.RESOURCE_ID(l_counter)             := lx_winners_rec.resource_id(l_counter);
    x_winners_rec.RESOURCE_TYPE(l_counter)           := lx_winners_rec.resource_type(l_counter);
    x_winners_rec.GROUP_ID(l_counter)                := lx_winners_rec.group_id(l_counter);
    x_winners_rec.ROLE(l_counter)                    := lx_winners_rec.role(l_counter);
    x_winners_rec.PRIMARY_CONTACT_FLAG(l_counter)    := lx_winners_rec.PRIMARY_CONTACT_FLAG(l_counter);
    x_winners_rec.FULL_ACCESS_FLAG(l_counter)        := lx_winners_rec.FULL_ACCESS_FLAG(l_counter);

    l_counter := l_counter + 1;

  END LOOP;

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.end',
                   'End of the procedure jtf_terr_sales_pub.get_winningterrmembers');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_sales_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_WinningTerrMembers;




--####################################################
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THE
-- FOLLOWING APIs SHOULD NO LONGER BE USED
--####################################################


/*========================================================================================*/
/*========================= ACCOUNT ======================================================*/
/*========================================================================================*/
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### SINGLE ###
--    type           : public.


--
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THIS API SHOULD NOT BE USED
--


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
) AS

   p_Rec                JTF_TERRITORY_PUB.JTF_Account_bulk_rec_type;
   x_rec                JTF_TERRITORY_PUB.Winning_bulk_rec_type;
   l_RscCounter         NUMBER := 0;
   l_counter            NUMBER := 0;

BEGIN
     /* initialise BULK tables with SINGLE record values */
     p_Rec.party_id                := jtf_terr_number_list(p_terraccount_rec.party_id);
     p_Rec.party_site_id           := jtf_terr_number_list(p_terraccount_rec.party_site_id);
     p_rec.city                    := jtf_terr_char_360list(p_terraccount_rec.city);
     p_Rec.postal_code             := jtf_terr_char_360list(p_terraccount_rec.postal_code);
     p_rec.state                   := jtf_terr_char_360list(p_terraccount_rec.state);
     p_rec.province                := jtf_terr_char_360list(p_terraccount_rec.province);
     p_rec.county                  := jtf_terr_char_360list(p_terraccount_rec.county);
     p_rec.country                 := jtf_terr_char_360list(p_terraccount_rec.country);
     p_rec.interest_type_id        := jtf_terr_number_list(p_terraccount_rec.interest_type_id);
     p_rec.primary_interest_id     := jtf_terr_number_list(p_terraccount_rec.primary_interest_id);
     p_rec.secondary_interest_id   := jtf_terr_number_list(p_terraccount_rec.secondary_interest_id);
     p_rec.area_code               := jtf_terr_char_360list(p_terraccount_rec.area_code);
     p_rec.comp_name_range         := jtf_terr_char_360list(p_terraccount_rec.comp_name_range);
     p_rec.partner_id              := jtf_terr_number_list(p_terraccount_rec.partner_id);
     p_rec.num_of_employees        := jtf_terr_number_list(p_terraccount_rec.num_of_employees);
     p_rec.category_code           := jtf_terr_char_360list(p_terraccount_rec.category_code);
     p_rec.party_relationship_id   := jtf_terr_number_list(p_terraccount_rec.party_relationship_id);
     p_rec.sic_code                := jtf_terr_char_360list(p_terraccount_rec.sic_code);
     p_rec.attribute1              := jtf_terr_char_360list(p_terraccount_rec.attribute1);
     p_rec.attribute2              := jtf_terr_char_360list(p_terraccount_rec.attribute2);
     p_rec.attribute3              := jtf_terr_char_360list(p_terraccount_rec.attribute3);
     p_rec.attribute4              := jtf_terr_char_360list(p_terraccount_rec.attribute4);
     p_rec.attribute5              := jtf_terr_char_360list(p_terraccount_rec.attribute5);
     p_rec.attribute6              := jtf_terr_char_360list(p_terraccount_rec.attribute6);
     p_rec.attribute7              := jtf_terr_char_360list(p_terraccount_rec.attribute7);
     p_rec.attribute8              := jtf_terr_char_360list(p_terraccount_rec.attribute8);
     p_rec.attribute9              := jtf_terr_char_360list(p_terraccount_rec.attribute9);
     p_rec.attribute10             := jtf_terr_char_360list(p_terraccount_rec.attribute10);
     p_rec.attribute11             := jtf_terr_char_360list(p_terraccount_rec.attribute11);
     p_rec.attribute12             := jtf_terr_char_360list(p_terraccount_rec.attribute12);
     p_rec.attribute13             := jtf_terr_char_360list(p_terraccount_rec.attribute13);
     p_rec.attribute14             := jtf_terr_char_360list(p_terraccount_rec.attribute14);
     p_rec.attribute15             := jtf_terr_char_360list(p_terraccount_rec.attribute15);


     JTF_TERR_SALES_PUB.Get_WinningTerrMembers(
         P_Api_Version_Number     =>  P_Api_Version_Number,
         P_Init_Msg_List          =>  p_init_msg_list,
         p_TerrAccount_Rec        =>  p_Rec,
         p_resource_type          =>  p_resource_type,
         p_Role                   =>  p_role,
         X_Return_Status          =>  x_return_status,
         X_Msg_Count              =>  x_Msg_Count,
         X_Msg_Data               =>  x_Msg_Data,
         x_winners_rec            =>  x_rec);

     l_counter := x_rec.terr_id.FIRST;

     WHILE (l_counter <= x_rec.terr_id.LAST) LOOP

        x_TerrResource_tbl(l_counter).TERR_RSC_ID          := x_rec.terr_rsc_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_ID          := x_rec.resource_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_TYPE        := x_rec.resource_type(l_counter);
        x_TerrResource_tbl(l_counter).GROUP_ID             := x_rec.group_id(l_counter);
        x_TerrResource_tbl(l_counter).ROLE                 := x_rec.role(l_counter);
        x_TerrResource_tbl(l_counter).PRIMARY_CONTACT_FLAG := x_rec.primary_contact_flag(l_counter);
        x_TerrResource_tbl(l_counter).FULL_ACCESS_FLAG     := x_rec.full_access_flag(l_counter);
        x_TerrResource_tbl(l_counter).TERR_ID              := x_rec.terr_id(l_counter);
        x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := x_rec.absolute_rank(l_counter);

        l_counter := l_counter + 1;

     END LOOP;

end Get_WinningTerrMembers;


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerritories - ### SINGLE ###
--    type           : public.

--
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THIS API SHOULD NOT BE USED
--

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
)AS

   p_Rec                 JTF_TERRITORY_PUB.JTF_Account_bulk_rec_type;
   x_rec                 JTF_TERRITORY_PUB.Winning_bulk_rec_type;

   l_RscCounter                   NUMBER := 0;

BEGIN

     /* initialise BULK tables with SINGLE record values */
     p_Rec.POSTAL_CODE             := jtf_terr_char_360list(p_terracct_rec.postal_code);
     p_Rec.PARTY_ID                := jtf_terr_number_list(p_terracct_rec.party_id);
     p_Rec.PARTY_SITE_ID           := jtf_terr_number_list(p_terracct_rec.party_site_id);
     p_rec.city                    := jtf_terr_char_360list(p_terracct_rec.city);
     p_Rec.postal_code             := jtf_terr_char_360list(p_terracct_rec.postal_code);
     p_rec.state                   := jtf_terr_char_360list(p_terracct_rec.state);
     p_rec.province                := jtf_terr_char_360list(p_terracct_rec.province);
     p_rec.county                  := jtf_terr_char_360list(p_terracct_rec.county);
     p_rec.country                 := jtf_terr_char_360list(p_terracct_rec.country);
     p_rec.interest_type_id        := jtf_terr_number_list(p_terracct_rec.interest_type_id);
     p_rec.primary_interest_id     := jtf_terr_number_list(p_terracct_rec.primary_interest_id);
     p_rec.secondary_interest_id   := jtf_terr_number_list(p_terracct_rec.secondary_interest_id);
     p_rec.area_code               := jtf_terr_char_360list(p_terracct_rec.area_code);
     p_rec.comp_name_range         := jtf_terr_char_360list(p_terracct_rec.comp_name_range);
     p_rec.partner_id              := jtf_terr_number_list(p_terracct_rec.partner_id);
     p_rec.num_of_employees        := jtf_terr_number_list(p_terracct_rec.num_of_employees);
     p_rec.category_code           := jtf_terr_char_360list(p_terracct_rec.category_code);
     p_rec.party_relationship_id   := jtf_terr_number_list(p_terracct_rec.party_relationship_id);
     p_rec.sic_code                := jtf_terr_char_360list(p_terracct_rec.sic_code);
     p_rec.attribute1              := jtf_terr_char_360list(p_terracct_rec.attribute1);
     p_rec.attribute2              := jtf_terr_char_360list(p_terracct_rec.attribute2);
     p_rec.attribute3              := jtf_terr_char_360list(p_terracct_rec.attribute3);
     p_rec.attribute4              := jtf_terr_char_360list(p_terracct_rec.attribute4);
     p_rec.attribute5              := jtf_terr_char_360list(p_terracct_rec.attribute5);
     p_rec.attribute6              := jtf_terr_char_360list(p_terracct_rec.attribute6);
     p_rec.attribute7              := jtf_terr_char_360list(p_terracct_rec.attribute7);
     p_rec.attribute8              := jtf_terr_char_360list(p_terracct_rec.attribute8);
     p_rec.attribute9              := jtf_terr_char_360list(p_terracct_rec.attribute9);
     p_rec.attribute10             := jtf_terr_char_360list(p_terracct_rec.attribute10);
     p_rec.attribute11             := jtf_terr_char_360list(p_terracct_rec.attribute11);
     p_rec.attribute12             := jtf_terr_char_360list(p_terracct_rec.attribute12);
     p_rec.attribute13             := jtf_terr_char_360list(p_terracct_rec.attribute13);
     p_rec.attribute14             := jtf_terr_char_360list(p_terracct_rec.attribute14);
     p_rec.attribute15             := jtf_terr_char_360list(p_terracct_rec.attribute15);

      JTF_TERR_SALES_PUB.Get_WinningTerritories( p_api_version_number  => 1.0,
                                                     p_init_msg_list       => p_init_msg_list,
                                                     x_return_status       => x_return_status,
                                                     x_msg_count           => x_msg_count,
                                                     X_msg_data            => X_msg_data,
                                                     p_TerrAcct_Rec        => p_Rec,
                                                     x_winners_rec         => x_rec);
end Get_WinningTerritories;


--
--    Start of Comments
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerritories - ### BULK ###
--    type           : public.

--
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THIS API SHOULD NOT BE USED
--

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
    x_winners_rec              OUT NOCOPY   JTF_TERRITORY_PUB.Winning_BULK_rec_type,
    p_top_level_terr_id        IN    NUMBER := FND_API.G_MISS_NUM,
    p_num_winners              IN    NUMBER := FND_API.G_MISS_NUM,
    p_role                     IN    VARCHAR2 := FND_API.G_MISS_CHAR
)
AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerritories_Acct';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);
      l_counter                    NUMBER;
      l_Org_Id                     NUMBER ;
      l_cursor                     NUMBER ;
      l_sql                        VARCHAR2(32767) ;
      l_num_rows                   NUMBER ;
      l_RetCode                    BOOLEAN;
      l_Num_Of_Winners             NUMBER;
      l_Profile_Value              VARCHAR2(25);
      l_NoOfWinTerr                NUMBER;
      l_Terr_Record                JTF_TERRITORY_PUB.WinningTerr_Rec_type;

      l_two_levels                 VARCHAR2(10) := 'TRUE';
      l_count                      NUMBER := 1;
      l_count1                     NUMBER := 0;
      l_count2                     NUMBER := 0;

      /* This cursor is not allowed in 9i
      CURSOR c_get_win_terr IS
           SELECT DISTINCT wt.column_value
           FROM TABLE ( CAST( x_winners_rec.terr_id AS JTF_TERR_NUMBER_LIST) ) AS wt;
      */


      /* 2167091 bug fix: JDOCHERT: 01/17/02 */
      lp_Acc_Rec                   JTF_TERRITORY_PUB.JTF_Account_BULK_rec_type;

BEGIN
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
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_WIN_ACCT_START');
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --Reset the global variables
      l_RetCode := JTF_TERRITORY_GLOBAL_PUB.Reset;

      /* 2167091 bug fix: JDOCHERT: 01/17/02 */
      lp_Acc_Rec := p_TerrAcct_Rec;
      lp_Acc_Rec.trans_object_id :=  p_TerrAcct_Rec.party_id;

      jtf_terr_1001_account_dyn.search_terr_rules(
               p_rec                => lp_Acc_Rec
             , x_rec                => x_winners_rec
             , p_top_level_terr_id  => p_top_level_terr_id
             , p_num_winners        => p_num_winners
             , p_role               => p_role);

        /*=======================================================================================
           START OF CODE USED BY AMS (Oracle Marketing)
        =======================================================================================*/
        IF (x_winners_rec.terr_id.LAST >= 1) THEN

            -- put first terr_id into global table record
            JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl(1).terr_id
                := x_winners_rec.terr_id(x_winners_rec.terr_id.first);

            -- insert additional territories if they do not exist in the global table record
            l_count1 := x_winners_rec.terr_id.FIRST;
            WHILE (l_count1 <= x_winners_rec.terr_id.LAST) LOOP
                l_count2 := JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl.FIRST;

                WHILE (l_count2 <= JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl.LAST) LOOP
                    EXIT WHEN JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl(l_count2).terr_id = x_winners_rec.terr_id(l_count1);

                    IF (l_count2 = JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl.LAST) THEN
                        JTF_TERRITORY_GLOBAL_PUB.G_WinningTerr_Tbl(l_count2 + 1).terr_id := x_winners_rec.terr_id(l_count1);
                    END IF;
                    l_count2 := l_count2 + 1;

                END LOOP;
                l_count1 := l_count1 + 1;

            END LOOP;

        END IF;

        -- Get the number of Territories in the Global Table
        l_NoOfWinTerr := JTF_TERRITORY_GLOBAL_PUB.get_RecordCount;

        /* If the program did not find qualifying Territory then
        ** add Catch all
        */
        If l_NoOfWinTerr = 0 Then

           l_Terr_Record.TERR_ID        := 1;
           l_Terr_Record.RANK           := 0;
           JTF_TERRITORY_GLOBAL_PUB.Add_Record( p_WinningTerr_Rec => l_Terr_Record,
                                                p_Number_Of_Winners => l_Num_Of_Winners,
                                                X_Return_Status   => l_Return_Status);
        End If;

        /*=======================================================================================
           END OF CODE USED BY AMS (Oracle Marketing)
        =======================================================================================*/

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_WIN_ACCT_END');
           FND_MSG_PUB.Add;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
            p_data            =>      x_msg_data
        );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
           );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
           );


      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_GEN_TERR_PACKAGE');
              FND_MESSAGE.Set_Token('JTF', 'JTF_TERR_1001_ACCOUNT_DYN');
              FND_MSG_PUB.Add;
           END IF;

           FND_MSG_PUB.Count_And_Get
           ( p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
           );
  --
End  Get_WinningTerritories;


/*========================================================================================*/
/*========================= OPPORTUNITY ==================================================*/
/*========================================================================================*/

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### SINGLE ###
--    type           : public.


--
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THIS API SHOULD NOT BE USED
--


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
) AS

   p_Rec                JTF_TERRITORY_PUB.JTF_Oppor_bulk_rec_type;
   x_rec                JTF_TERRITORY_PUB.Winning_bulk_rec_type;
   l_RscCounter         NUMBER := 0;
   l_counter            NUMBER := 0;

BEGIN


     /* initialise BULK tables with SINGLE record values */
     p_Rec.lead_id                           := jtf_terr_number_list(p_terroppor_rec.lead_id);
     p_Rec.lead_line_id                      := jtf_terr_number_list(p_terroppor_rec.lead_line_id);
     p_rec.city                              := jtf_terr_char_360list(p_terroppor_rec.city);
     p_Rec.postal_code                       := jtf_terr_char_360list(p_terroppor_rec.postal_code);
     p_rec.state                             := jtf_terr_char_360list(p_terroppor_rec.state);
     p_rec.province                          := jtf_terr_char_360list(p_terroppor_rec.province);
     p_rec.county                            := jtf_terr_char_360list(p_terroppor_rec.county);
     p_rec.country                           := jtf_terr_char_360list(p_terroppor_rec.country);
     p_rec.interest_type_id                  := jtf_terr_number_list(p_terroppor_rec.interest_type_id);
     p_rec.primary_interest_id               := jtf_terr_number_list(p_terroppor_rec.primary_interest_id);
     p_rec.secondary_interest_id             := jtf_terr_number_list(p_terroppor_rec.secondary_interest_id);
     p_Rec.party_id                          := jtf_terr_number_list(p_terroppor_rec.party_id);
     p_Rec.party_site_id                     := jtf_terr_number_list(p_terroppor_rec.party_site_id);
     p_rec.area_code                         := jtf_terr_char_360list(p_terroppor_rec.area_code);
     p_rec.comp_name_range                   := jtf_terr_char_360list(p_terroppor_rec.comp_name_range);
     p_rec.partner_id                        := jtf_terr_number_list(p_terroppor_rec.partner_id);
     p_rec.num_of_employees                  := jtf_terr_number_list(p_terroppor_rec.num_of_employees);
     p_rec.category_code                     := jtf_terr_char_360list(p_terroppor_rec.category_code);
     p_rec.party_relationship_id             := jtf_terr_number_list(p_terroppor_rec.party_relationship_id);
     p_rec.sic_code                          := jtf_terr_char_360list(p_terroppor_rec.sic_code);
     p_rec.target_segment_current            := jtf_terr_char_360list(p_terroppor_rec.target_segment_current);
     p_rec.total_amount                      := jtf_terr_number_list(p_terroppor_rec.total_amount);
     p_rec.currency_code                     := jtf_terr_char_360list(p_terroppor_rec.currency_code);
     p_rec.pricing_date                      := jtf_terr_date_list(p_terroppor_rec.pricing_date);
     p_rec.channel_code                      := jtf_terr_char_360list(p_terroppor_rec.channel_code);
     p_rec.inventory_item_id                 := jtf_terr_number_list(p_terroppor_rec.inventory_item_id);
     p_rec.opp_interest_type_id              := jtf_terr_number_list(p_terroppor_rec.opp_interest_type_id);
     p_rec.opp_primary_interest_id           := jtf_terr_number_list(p_terroppor_rec.opp_primary_interest_id);
     p_rec.opp_secondary_interest_id         := jtf_terr_number_list(p_terroppor_rec.opp_secondary_interest_id);
     p_rec.opclss_interest_type_id           := jtf_terr_number_list(p_terroppor_rec.opclss_interest_type_id);
     p_rec.opclss_primary_interest_id        := jtf_terr_number_list(p_terroppor_rec.opclss_primary_interest_id);
     p_rec.opclss_secondary_interest_id      := jtf_terr_number_list(p_terroppor_rec.opclss_secondary_interest_id);
     p_rec.attribute1                        := jtf_terr_char_360list(p_terroppor_rec.attribute1);
     p_rec.attribute2                        := jtf_terr_char_360list(p_terroppor_rec.attribute2);
     p_rec.attribute3                        := jtf_terr_char_360list(p_terroppor_rec.attribute3);
     p_rec.attribute4                        := jtf_terr_char_360list(p_terroppor_rec.attribute4);
     p_rec.attribute5                        := jtf_terr_char_360list(p_terroppor_rec.attribute5);
     p_rec.attribute6                        := jtf_terr_char_360list(p_terroppor_rec.attribute6);
     p_rec.attribute7                        := jtf_terr_char_360list(p_terroppor_rec.attribute7);
     p_rec.attribute8                        := jtf_terr_char_360list(p_terroppor_rec.attribute8);
     p_rec.attribute9                        := jtf_terr_char_360list(p_terroppor_rec.attribute9);
     p_rec.attribute10                       := jtf_terr_char_360list(p_terroppor_rec.attribute10);
     p_rec.attribute11                       := jtf_terr_char_360list(p_terroppor_rec.attribute11);
     p_rec.attribute12                       := jtf_terr_char_360list(p_terroppor_rec.attribute12);
     p_rec.attribute13                       := jtf_terr_char_360list(p_terroppor_rec.attribute13);
     p_rec.attribute14                       := jtf_terr_char_360list(p_terroppor_rec.attribute14);
     p_rec.attribute15                       := jtf_terr_char_360list(p_terroppor_rec.attribute15);


     JTF_TERR_SALES_PUB.Get_WinningTerrMembers(
         P_Api_Version_Number     =>  P_Api_Version_Number,
         P_Init_Msg_List          =>  p_init_msg_list,
         p_TerrOppor_Rec          =>  p_Rec,
         p_resource_type          =>  p_resource_type,
         p_Role                   =>  p_role,
         X_Return_Status          =>  x_return_status,
         X_Msg_Count              =>  x_Msg_Count,
         X_Msg_Data               =>  x_Msg_Data,
         x_winners_rec            =>  x_rec);


     l_counter := x_rec.terr_id.FIRST;

     WHILE (l_counter <= x_rec.terr_id.LAST) LOOP

        x_TerrResource_tbl(l_counter).TERR_RSC_ID          := x_rec.terr_rsc_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_ID          := x_rec.resource_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_TYPE        := x_rec.resource_type(l_counter);
        x_TerrResource_tbl(l_counter).GROUP_ID             := x_rec.group_id(l_counter);
        x_TerrResource_tbl(l_counter).ROLE                 := x_rec.role(l_counter);
        x_TerrResource_tbl(l_counter).PRIMARY_CONTACT_FLAG := x_rec.primary_contact_flag(l_counter);
        x_TerrResource_tbl(l_counter).FULL_ACCESS_FLAG     := x_rec.full_access_flag(l_counter);
        x_TerrResource_tbl(l_counter).TERR_ID              := x_rec.terr_id(l_counter);
        x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := x_rec.absolute_rank(l_counter);

        l_counter := l_counter + 1;

     END LOOP;

end Get_WinningTerrMembers;


/*========================================================================================*/
/*========================= LEAD =========================================================*/
/*========================================================================================*/

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers - ### SINGLE ###
--    type           : public.

--
-- For APPLICATIONS RELEASE 11.5.6 AND BEYOND, THIS API SHOULD NOT BE USED
--

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
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
) AS

   p_Rec                JTF_TERRITORY_PUB.JTF_Lead_bulk_rec_type;
   x_rec                JTF_TERRITORY_PUB.Winning_bulk_rec_type;
   l_RscCounter         NUMBER := 0;
   l_counter            NUMBER := 0;

BEGIN


     /* initialise BULK tables with SINGLE record values */
     p_Rec.sales_lead_id                     := jtf_terr_number_list(p_terrlead_rec.sales_lead_id);
     p_Rec.sales_lead_line_id                := jtf_terr_number_list(p_terrlead_rec.sales_lead_line_id);
     p_rec.city                              := jtf_terr_char_360list(p_terrlead_rec.city);
     p_Rec.postal_code                       := jtf_terr_char_360list(p_terrlead_rec.postal_code);
     p_rec.state                             := jtf_terr_char_360list(p_terrlead_rec.state);
     p_rec.province                          := jtf_terr_char_360list(p_terrlead_rec.province);
     p_rec.county                            := jtf_terr_char_360list(p_terrlead_rec.county);
     p_rec.country                           := jtf_terr_char_360list(p_terrlead_rec.country);
     p_rec.interest_type_id                  := jtf_terr_number_list(p_terrlead_rec.interest_type_id);
     p_rec.primary_interest_id               := jtf_terr_number_list(p_terrlead_rec.primary_interest_id);
     p_rec.secondary_interest_id             := jtf_terr_number_list(p_terrlead_rec.secondary_interest_id);
     p_Rec.party_id                          := jtf_terr_number_list(p_terrlead_rec.party_id);
     p_Rec.party_site_id                     := jtf_terr_number_list(p_terrlead_rec.party_site_id);
     p_rec.area_code                         := jtf_terr_char_360list(p_terrlead_rec.area_code);
     p_rec.comp_name_range                   := jtf_terr_char_360list(p_terrlead_rec.comp_name_range);
     p_rec.partner_id                        := jtf_terr_number_list(p_terrlead_rec.partner_id);
     p_rec.num_of_employees                  := jtf_terr_number_list(p_terrlead_rec.num_of_employees);
     p_rec.category_code                     := jtf_terr_char_360list(p_terrlead_rec.category_code);
     p_rec.party_relationship_id             := jtf_terr_number_list(p_terrlead_rec.party_relationship_id);
     p_rec.sic_code                          := jtf_terr_char_360list(p_terrlead_rec.sic_code);
     p_rec.budget_amount                     := jtf_terr_number_list(p_terrlead_rec.budget_amount);
     p_rec.currency_code                     := jtf_terr_char_360list(p_terrlead_rec.currency_code);
     p_rec.pricing_date                      := jtf_terr_date_list(p_terrlead_rec.pricing_date);
     p_rec.source_promotion_id               := jtf_terr_number_list(p_terrlead_rec.source_promotion_id);
     p_rec.inventory_item_id                 := jtf_terr_number_list(p_terrlead_rec.inventory_item_id);
     p_rec.lead_interest_type_id             := jtf_terr_number_list(p_terrlead_rec.lead_interest_type_id);
     p_rec.lead_primary_interest_id          := jtf_terr_number_list(p_terrlead_rec.lead_primary_interest_id);
     p_rec.lead_secondary_interest_id        := jtf_terr_number_list(p_terrlead_rec.lead_secondary_interest_id);
     p_rec.purchase_amount                   := jtf_terr_number_list(p_terrlead_rec.purchase_amount);
     p_rec.attribute1                        := jtf_terr_char_360list(p_terrlead_rec.attribute1);
     p_rec.attribute2                        := jtf_terr_char_360list(p_terrlead_rec.attribute2);
     p_rec.attribute3                        := jtf_terr_char_360list(p_terrlead_rec.attribute3);
     p_rec.attribute4                        := jtf_terr_char_360list(p_terrlead_rec.attribute4);
     p_rec.attribute5                        := jtf_terr_char_360list(p_terrlead_rec.attribute5);
     p_rec.attribute6                        := jtf_terr_char_360list(p_terrlead_rec.attribute6);
     p_rec.attribute7                        := jtf_terr_char_360list(p_terrlead_rec.attribute7);
     p_rec.attribute8                        := jtf_terr_char_360list(p_terrlead_rec.attribute8);
     p_rec.attribute9                        := jtf_terr_char_360list(p_terrlead_rec.attribute9);
     p_rec.attribute10                       := jtf_terr_char_360list(p_terrlead_rec.attribute10);
     p_rec.attribute11                       := jtf_terr_char_360list(p_terrlead_rec.attribute11);
     p_rec.attribute12                       := jtf_terr_char_360list(p_terrlead_rec.attribute12);
     p_rec.attribute13                       := jtf_terr_char_360list(p_terrlead_rec.attribute13);
     p_rec.attribute14                       := jtf_terr_char_360list(p_terrlead_rec.attribute14);
     p_rec.attribute15                       := jtf_terr_char_360list(p_terrlead_rec.attribute15);

     JTF_TERR_SALES_PUB.Get_WinningTerrMembers(
         P_Api_Version_Number     =>  P_Api_Version_Number,
         P_Init_Msg_List          =>  p_init_msg_list,
         p_TerrLead_Rec           =>  p_Rec,
         p_resource_type          =>  p_resource_type,
         p_Role                   =>  p_role,
         X_Return_Status          =>  x_return_status,
         X_Msg_Count              =>  x_Msg_Count,
         X_Msg_Data               =>  x_Msg_Data,
         x_winners_rec            =>  x_rec);

     l_counter := x_rec.terr_id.FIRST;

     WHILE (l_counter <= x_rec.terr_id.LAST) LOOP

        x_TerrResource_tbl(l_counter).TERR_RSC_ID          := x_rec.terr_rsc_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_ID          := x_rec.resource_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_TYPE        := x_rec.resource_type(l_counter);
        x_TerrResource_tbl(l_counter).GROUP_ID             := x_rec.group_id(l_counter);
        x_TerrResource_tbl(l_counter).ROLE                 := x_rec.role(l_counter);
        x_TerrResource_tbl(l_counter).PRIMARY_CONTACT_FLAG := x_rec.primary_contact_flag(l_counter);
        x_TerrResource_tbl(l_counter).FULL_ACCESS_FLAG     := x_rec.full_access_flag(l_counter);
        x_TerrResource_tbl(l_counter).TERR_ID              := x_rec.terr_id(l_counter);
        x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := x_rec.absolute_rank(l_counter);

        l_counter := l_counter + 1;

     END LOOP;

end Get_WinningTerrMembers;

END JTF_TERR_SALES_PUB;

/
