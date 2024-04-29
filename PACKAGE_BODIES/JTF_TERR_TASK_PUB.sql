--------------------------------------------------------
--  DDL for Package Body JTF_TERR_TASK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_TASK_PUB" AS
/* $Header: jtfpttsb.pls 120.3 2005/11/18 15:07:17 achanda ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_TASK_PUB
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
--      12/09/99    VNEDUNGA         Making changes to get_WinningTerritories
--                                   procedure
--      01/07/99    VNEDUNGA         Changing the procedure to reflect
--                                   qualifer chnages
--      02/01/00    VNEDUNGA         Changing the get resource SQL
--      02/08/00    VNEDUNGA         Fixing bug 1184799, local rec declaration
--                                   typo
--      02/24/00    vnedunga         Making chnages to call the newly designed
--                                   Generated Engine packages
--      02/24/00    vnedunga         Adding the code to rerturn Catch all
--                                   if there was no qualifying Ter
--      03/23/00    vnedunga         Making changes to return full_access_flag
--      05/01/00    vnedunga         Taking out FOR UPDATE clause from Resource
--                                   cursor
--      06/14/00    vnedunga         Changeing the get winning Terr memeber api
--                                   to return group_id
--      05/07/01    EIHSU            GetWinningTerritories removed
--
--      05/24/05    ACHANDA          Modified to the new 12.0 architecture
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_TASK_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfpttsb.pls';

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--
--    IN:
--        p_api_version_number   IN  number               required
--        p_init_msg_list        IN  varchar2             optional --default = fnd_api.g_false
--        p_commit               IN  varchar2             optional --default = fnd_api.g_false
--        p_Org_Id               IN  number               required
--        p_TerrTask_Rec      IN JTF_ServiceReqst_rec_type
--
--    out:
--        x_return_status        out varchar2(1)
--        x_msg_count            out number
--        x_msg_data             out varchar2(2000)
--        x_TerrRes_tbl          out TerrRes_tbl_type
--
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
    p_TerrTask_Rec             IN    JTF_TERRITORY_PUB.JTF_Task_rec_type,
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

  l_Counter                    NUMBER;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;

BEGIN

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.begin',
                   'Start of the procedure jtf_terr_task_pub.get_winningterrmembers');
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

  ------------------
  -- API body
  ------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- debug message
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.parameters',
                   'Country : ' || p_TerrTask_rec.COUNTRY || ' City : ' || p_TerrTask_rec.CITY || ' Postal Code : ' ||
                   p_TerrTask_rec.POSTAL_CODE || ' State : ' || p_TerrTask_rec.STATE || ' Area Code : ' || p_TerrTask_rec.AREA_CODE ||
                   ' County : ' || p_TerrTask_rec.COUNTY || ' Company Name Range : ' || p_TerrTask_rec.COMP_NAME_RANGE ||
                   ' Province : ' || p_TerrTask_rec.PROVINCE || ' Number of Employees : ' || p_TerrTask_rec.NUM_OF_EMPLOYEES ||
                   ' Party ID : ' || p_TerrTask_rec.PARTY_ID || ' Party Site ID : ' || p_TerrTask_rec.PARTY_SITE_ID || ' Task Type ID : ' ||
                   p_TerrTask_rec.TASK_TYPE_ID || ' Task Status ID : ' || p_TerrTask_rec.TASK_STATUS_ID || ' Task Priority ID : ' ||
                   p_TerrTask_rec.TASK_PRIORITY_ID);
  END IF;

  /* insert all the attributes into the trans table as name - value pair */
  DELETE jty_terr_nvp_trans_gt;
  INSERT INTO jty_terr_nvp_trans_gt (
     attribute_name
    ,num_value
    ,char_value
    ,date_value )
  ( SELECT 'COUNTRY'               attribute_name
          ,null                    num_value
          ,p_TerrTask_rec.COUNTRY  char_value
          ,null                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CITY'                  attribute_name
          ,null                    num_value
          ,p_TerrTask_rec.CITY     char_value
          ,null                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'POSTAL_CODE'              attribute_name
          ,null                       num_value
          ,p_TerrTask_rec.POSTAL_CODE char_value
          ,null                       date_value
    FROM  DUAL
    UNION ALL
    SELECT 'STATE'               attribute_name
          ,null                  num_value
          ,p_TerrTask_rec.STATE  char_value
          ,null                  date_value
    FROM  DUAL
    UNION ALL
    SELECT 'AREA_CODE'               attribute_name
          ,null                      num_value
          ,p_TerrTask_rec.AREA_CODE  char_value
          ,null                      date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COUNTY'               attribute_name
          ,null                   num_value
          ,p_TerrTask_rec.COUNTY  char_value
          ,null                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COMP_NAME_RANGE'               attribute_name
          ,null                            num_value
          ,p_TerrTask_rec.COMP_NAME_RANGE  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROVINCE'               attribute_name
          ,null                     num_value
          ,p_TerrTask_rec.PROVINCE  char_value
          ,null                     date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_ID'               attribute_name
          ,p_TerrTask_rec.PARTY_ID  num_value
          ,null                     char_value
          ,null                     date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_SITE_ID'               attribute_name
          ,p_TerrTask_rec.PARTY_SITE_ID  num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'NUM_OF_EMPLOYEES'               attribute_name
          ,p_TerrTask_rec.NUM_OF_EMPLOYEES  num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_TYPE_ID'               attribute_name
          ,p_TerrTask_rec.TASK_TYPE_ID  num_value
          ,null                         char_value
          ,null                         date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_STATUS_ID'               attribute_name
          ,p_TerrTask_rec.TASK_STATUS_ID  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_PRIORITY_ID'               attribute_name
          ,p_TerrTask_rec.TASK_PRIORITY_ID  num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_ID'                        attribute_name
          ,p_TerrTask_rec.TASK_ID           num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'ORGANIZATION_ID'                attribute_name
          ,p_TerrTask_rec.ORGANIZATION_ID   num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
  );

  /*
      lp_Rec.squal_char01            := jtf_terr_char_360list(p_TerrTask_rec.COUNTRY);
      lp_Rec.squal_char02            := jtf_terr_char_360list(p_TerrTask_rec.CITY);
      lp_Rec.squal_char03            := jtf_terr_char_360list(p_TerrTask_rec.POSTAL_CODE);
      lp_Rec.squal_char04            := jtf_terr_char_360list(p_TerrTask_rec.STATE);
      lp_Rec.squal_char05            := jtf_terr_char_360list(p_TerrTask_rec.AREA_CODE);
      lp_Rec.squal_char06            := jtf_terr_char_360list(p_TerrTask_rec.COUNTY);
      lp_Rec.squal_char07            := jtf_terr_char_360list(p_TerrTask_rec.COMP_NAME_RANGE);
      lp_Rec.squal_char08            := jtf_terr_char_360list(p_TerrTask_rec.PROVINCE);

      lp_Rec.squal_num01             := jtf_terr_number_list(p_TerrTask_rec.PARTY_ID);
      lp_Rec.squal_num02             := jtf_terr_number_list(p_TerrTask_rec.PARTY_SITE_ID);
      lp_Rec.squal_num03             := jtf_terr_number_list(p_TerrTask_rec.NUM_OF_EMPLOYEES);
      lp_Rec.squal_num20             := jtf_terr_number_list(p_TerrTask_rec.TASK_TYPE_ID);
      lp_Rec.squal_num21             := jtf_terr_number_list(p_TerrTask_rec.TASK_STATUS_ID);
      lp_Rec.squal_num22             := jtf_terr_number_list(p_TerrTask_rec.TASK_PRIORITY_ID);
  */

  JTY_ASSIGN_REALTIME_PUB.process_match (
         p_source_id     => -1002
        ,p_trans_id      => -1006
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,p_program_name  => 'SERVICE/TASKS PROGRAM'
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.process_match',
                     'API JTY_ASSIGN_REALTIME_PUB.process_match has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.process_match',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_match');
  END IF;

  JTY_ASSIGN_REALTIME_PUB.process_winners (
         p_source_id     => -1002
        ,p_trans_id      => -1006
        ,p_program_name  => 'SERVICE/TASKS PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,p_role          => p_role
        ,p_resource_type => p_resource_type
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,x_winners_rec   => lx_winners_rec);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.process_winners',
                     'API JTY_ASSIGN_REALTIME_PUB.process_winners has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.process_winners',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_winners');
  END IF;

  /*
      jtf_terr_1002_task_dyn.search_terr_rules(
                p_rec                => lp_rec
              , x_rec                => lx_rec
              , p_role               => p_role
              , p_resource_type      => p_resource_type );
  */

  l_counter := lx_winners_rec.terr_id.FIRST;
  WHILE (l_counter <= lx_winners_rec.terr_id.LAST) LOOP

    x_TerrResource_tbl(l_counter).TERR_RSC_ID          := lx_winners_rec.terr_rsc_id(l_counter);
    x_TerrResource_tbl(l_counter).RESOURCE_ID          := lx_winners_rec.resource_id(l_counter);
    x_TerrResource_tbl(l_counter).RESOURCE_TYPE        := lx_winners_rec.resource_type(l_counter);
    x_TerrResource_tbl(l_counter).GROUP_ID             := lx_winners_rec.group_id(l_counter);
    x_TerrResource_tbl(l_counter).ROLE                 := lx_winners_rec.role(l_counter);
    x_TerrResource_tbl(l_counter).PRIMARY_CONTACT_FLAG := lx_winners_rec.PRIMARY_CONTACT_FLAG(l_counter);
    x_TerrResource_tbl(l_counter).FULL_ACCESS_FLAG     := lx_winners_rec.FULL_ACCESS_FLAG(l_counter);
    x_TerrResource_tbl(l_counter).TERR_ID              := lx_winners_rec.terr_id(l_counter);
    x_TerrResource_tbl(l_counter).START_DATE           := lx_winners_rec.terr_start_date(l_counter);
    x_TerrResource_tbl(l_counter).END_DATE             := lx_winners_rec.terr_end_date(l_counter);
    x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := lx_winners_rec.absolute_rank(l_counter);

    l_counter := l_counter + 1;

  END LOOP;

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.end',
                   'End of the procedure jtf_terr_task_pub.get_winningterrmembers');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_task_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_WinningTerrMembers;

END JTF_TERR_TASK_PUB;

/
