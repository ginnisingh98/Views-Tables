--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DEF_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DEF_MGMT_PUB" AS
/* $Header: jtfpdefb.pls 120.0 2005/06/02 18:20:39 appldev ship $ */


--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERR_DEF_MGMT_PUB
--  ---------------------------------------------------
--  PURPOSE
--    Defect Management territory manager public api's.
--    This package is a public API for getting winning territories
--    or territory resources.
--
--  Procedures:
--    (see below for specification)
--
--  NOTES
--    This package is publicly available for use
--
--  HISTORY
--    01/07/99    VNEDUNGA         Created
--    01/10/00    VNEDUNGA         Added LANGUAGE_CODE_ID to DEF_MGMT
--                                 rec type
--    01/18/00    VNEDUNGA         Fixing mispelled platform_id
--    02/01/00    vnedunga         Chnaging the get resource SQL
--    02/11/00    vnedunga         Fixng call to the dynamic package
--    02/24/00    vnedunga         Making changes to call the newly designed
--                                 Generated Engine packages
--    02/24/00    vnedunga         Adding the code to rerturn Catch all
--                                 if there was no qualifying Ter
--    03/23/00    vnedunga         Making changes to return full_access_flag
--    05/02/00    vnedunga         Take out for UPDATE from get rsc cursor
--    10/16/00    vvuyyuru         Changed the Defect Management Record Definition
--                                 to make it more generic and also changed the
--                                 related code for the Defects
--
--
--  End of Comments
--



--  ***************************************************
--              GLOBAL VARIABLES
--  ***************************************************

    G_PKG_NAME        CONSTANT VARCHAR2(30) :='JTF_TERR_DEF_MGMT_PUB';
    G_FILE_NAME       CONSTANT VARCHAR2(12) :='jtfpdefb.pls';

    G_NEW_LINE        VARCHAR2(02)          := fnd_global.local_chr(10);
    G_APPL_ID         NUMBER                := FND_GLOBAL.Prog_Appl_Id;
    G_LOGIN_ID        NUMBER                := FND_GLOBAL.Conc_Login_Id;
    G_PROGRAM_ID      NUMBER                := FND_GLOBAL.Conc_Program_Id;
    G_USER_ID         NUMBER                := FND_GLOBAL.User_Id;
    G_REQUEST_ID      NUMBER                := FND_GLOBAL.Conc_Request_Id;
    G_APP_SHORT_NAME  VARCHAR2(15)          := FND_GLOBAL.Application_Short_Name;




--  ***************************************************
--  start of comments
--  ***************************************************
--  api name       : Get_WinningTerrMembers
--  end of comments
  PROCEDURE Get_WinningTerrMembers
  (
    p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrDefMgmt_Rec          IN    JTF_TERRITORY_PUB.JTF_Def_Mgmt_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
  )
  AS

    l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers';
    l_api_version_number         CONSTANT NUMBER       := 1.0;
    l_return_status              VARCHAR2(1);
    l_Counter                    NUMBER                := 0;
    l_RscCounter                 NUMBER                := 0;
    l_NumberOfWinners            NUMBER;
    l_RetCode                    BOOLEAN;

    lp_rec                       JTF_TERRITORY_PUB.jtf_bulk_trans_rec_type;
    lx_rec                       JTF_TERRITORY_PUB.Winning_bulk_rec_type;

  BEGIN
    --dbms_output.put_line('Get_WinningTerrMembers: Entering the API');

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
             l_api_version_number,
             p_api_version_number,
             l_api_name,
             G_PKG_NAME
           ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEM_DEF_MGMT_START');
      FND_MSG_PUB.Add;
    END IF;

    -------------------
    ----- API body ----
    -------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* initialise trans_object_id and trans_detail_object_id:
     ** required in JTF_TERR_1004_DEF_MGMT_DYN.SEARCH_TERR_RULES
     */
     lp_Rec.trans_object_id          := jtf_terr_number_list(-1010);
     lp_Rec.trans_detail_object_id   := jtf_terr_number_list(-1010);

     /* initialise BULK tables with SINGLE record values */
     lp_Rec.squal_char01            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char01);
     lp_Rec.squal_char02            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char02);
     lp_Rec.squal_char03            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char03);
     lp_Rec.squal_char04            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char04);
     lp_Rec.squal_char05            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char05);
     lp_Rec.squal_char06            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char06);
     lp_Rec.squal_char07            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char07);
     lp_Rec.squal_char08            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char08);
     lp_Rec.squal_char09            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char09);
     lp_Rec.squal_char10            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char10);
     lp_Rec.squal_char11            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char11);
     lp_Rec.squal_char12            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char12);
     lp_Rec.squal_char13            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char13);
     lp_Rec.squal_char14            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char14);
     lp_Rec.squal_char15            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char15);
     lp_Rec.squal_char16            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char16);
     lp_Rec.squal_char17            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char17);
     lp_Rec.squal_char18            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char18);
     lp_Rec.squal_char19            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char19);
     lp_Rec.squal_char20            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char20);
     lp_Rec.squal_char21            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char21);
     lp_Rec.squal_char22            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char22);
     lp_Rec.squal_char23            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char23);
     lp_Rec.squal_char24            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char24);
     lp_Rec.squal_char25            := jtf_terr_char_360list(p_TerrDefMgmt_rec.squal_char25);
     lp_Rec.squal_num01             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num01);
     lp_Rec.squal_num02             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num02);
     lp_Rec.squal_num03             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num03);
     lp_Rec.squal_num04             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num04);
     lp_Rec.squal_num05             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num05);
     lp_Rec.squal_num06             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num06);
     lp_Rec.squal_num07             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num07);
     lp_Rec.squal_num08             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num08);
     lp_Rec.squal_num09             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num09);
     lp_Rec.squal_num10             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num10);
     lp_Rec.squal_num11             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num11);
     lp_Rec.squal_num12             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num12);
     lp_Rec.squal_num13             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num13);
     lp_Rec.squal_num14             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num14);
     lp_Rec.squal_num15             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num15);
     lp_Rec.squal_num16             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num16);
     lp_Rec.squal_num17             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num17);
     lp_Rec.squal_num18             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num18);
     lp_Rec.squal_num19             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num19);
     lp_Rec.squal_num20             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num20);
     lp_Rec.squal_num21             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num21);
     lp_Rec.squal_num22             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num22);
     lp_Rec.squal_num23             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num23);
     lp_Rec.squal_num24             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num24);
     lp_Rec.squal_num25             := jtf_terr_number_list(p_TerrDefMgmt_rec.squal_num25);

     jtf_terr_1004_def_mgmt_dyn.search_terr_rules(
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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEM_DEF_MGMT_END');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data
    );
    --dbms_output.put_line('Get_Escalation_TerrMembers: Exiting the API');

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count   =>  x_msg_count,
        p_data    =>  x_msg_data
      );

  END Get_WinningTerrMembers;


END JTF_TERR_DEF_MGMT_PUB;

/
