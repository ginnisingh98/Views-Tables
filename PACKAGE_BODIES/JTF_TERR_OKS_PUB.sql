--------------------------------------------------------
--  DDL for Package Body JTF_TERR_OKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_OKS_PUB" AS
/* $Header: jtfptscb.pls 120.0 2005/06/02 18:20:57 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_OKS_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core Service Contracts territory manager public api's.
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
--          07/21/00    EIHSU       Created
--          02/15/01    SP          Modified to make it backward compatible
--                                  Changed datatypes of lp_rec and lx_rec
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_OKS_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfptscb.pls';

   G_NEW_LINE        VARCHAR2(02) := FND_GLOBAL.Local_Chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;
--
--    Start of Comments

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrKRen_Rec             IN    JTF_TERRITORY_PUB.JTF_KRen_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
)
AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers_Kren';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);
      l_Counter                    NUMBER := 0;
      l_RscCounter                 NUMBER := 0;
      l_NumberOfWinners            NUMBER ;
      l_RetCode                    BOOLEAN;

      lp_rec                       JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
      lx_rec                       JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
 BEGIN
      --dbms_output.put_line('J_T_O_P.Get_WinningTerrMembers: BEGIN');

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEMBERS_KREN_START');
          FND_MSG_PUB.Add;
      END IF;

    -------------------
    ----- API body ----
    -------------------

      x_return_status := FND_API.G_RET_STS_SUCCESS;

     lp_Rec.trans_object_id.EXTEND ;
     lp_Rec.trans_detail_object_id.EXTEND;
     lp_Rec.squal_char01.EXTEND;
     lp_Rec.squal_char04.EXTEND;
     lp_Rec.squal_char07.EXTEND;
     lp_Rec.squal_num01.EXTEND;

     /* initialise trans_object_id and trans_detail_object_id:
     ** required in JTF_TERR_1500_KREN_DYN.SEARCH_TERR_RULES
     */
     lp_Rec.trans_object_id(1)          := -1501;
     lp_Rec.trans_detail_object_id(1)   := -1501;

     /* initialise BULK tables with SINGLE record values */
     lp_Rec.squal_char01(1) := p_TerrKRen_Rec.comp_name_range;
     lp_Rec.squal_char04(1) := p_TerrKRen_Rec.state;
     lp_Rec.squal_char07(1) := NULL;
     lp_Rec.squal_num01(1)  := p_TerrKRen_Rec.party_id;

     jtf_terr_1500_kren_dyn.search_terr_rules(
               p_rec                => lp_rec
             , x_rec                => lx_rec
             , p_role               => p_role
             , p_resource_type      => p_resource_type );

     l_counter := lx_rec.terr_id.FIRST;

     WHILE (l_counter <= lx_rec.terr_id.LAST) LOOP

        x_TerrResource_tbl(l_counter).TERR_RSC_ID          := lx_rec.terr_rsc_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_ID          := lx_rec.resource_id(l_counter);
        x_TerrResource_tbl(l_counter).RESOURCE_TYPE        := lx_rec.resource_type(l_counter);
        x_TerrResource_tbl(l_counter).GROUP_ID             := lx_rec.group_id(l_counter);
        x_TerrResource_tbl(l_counter).ROLE                 := lx_rec.role(l_counter);
        x_TerrResource_tbl(l_counter).PRIMARY_CONTACT_FLAG := lx_rec.full_access_flag(l_counter);
        x_TerrResource_tbl(l_counter).FULL_ACCESS_FLAG     := lx_rec.primary_contact_flag(l_counter);
        x_TerrResource_tbl(l_counter).TERR_ID              := lx_rec.terr_id(l_counter);

        l_counter := l_counter + 1;

     END LOOP;

    IF (l_Counter = 1) THEN
      NULL;
      --dbms_output.put_line('No records returned');
    END IF;

      --
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEMBERS_KREN_END');
          FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );
      --dbms_output.put_line('Get_Escalation_TerrMembers: Exiting the API');
  EXCEPTION
  --
      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;
           FND_MSG_PUB.Count_And_Get
           ( p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
           );
  --
  End  Get_WinningTerrMembers;
--
END JTF_TERR_OKS_PUB;

/
