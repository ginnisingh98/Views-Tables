--------------------------------------------------------
--  DDL for Package Body JTF_TERR_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_SERVICE_PUB" AS
/* $Header: jtfptsvb.pls 120.3.12010000.6 2009/06/19 08:42:25 gmarwah ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_SERVICE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
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
--      12/02/99    VNEDUNGA         Changing the dynamic SQL corresponsing
--                                   to new record defnition.
--      12/06/99    VNEDUNGA         CHanging the dynamic SQL to take out
--                                   interest_Type_id's depenency
--      12/22/99    VNEDUNGA         Making changes to confirm to
--                                   new assignement manager requirement
--      01/07/00    VNEDUNGA         Changing the dynamic to confirm to new
--                                   qualifer list
--      01/11/00    VNEDUNGA         Changing Get_WinningTerritories API
--      01/22/00    VNEDUNGA         Changing company_name_range to comp_name_range
--      02/01/00    VNEDUNGA         Changing the get resource SQL
--      02/08/00    VNEDUNGA         Fixing bug 1184799, local rec declaration
--                                   typo
--      02/24/00    vnedunga         Making chnages to call the newly designed
--                                   Generated Engine packages
--      02/24/00    vnedunga         Adding the code to rerturn Catch all
--                                   if there was no qualifying Ter
--      03/23/00    vnedunga         Making changes to return full_access_flag
--      05/01/00    VNEDUNGA         Taking out for update clause from resource cursor
--      06/14/00    vnedunga         Changeing the get winning Terr memeber api
--                                   to return group_id
--      05/08/01    arpatel          taken out Get_WinningTerritories for service requests.
--                                   Implemented jtf_bulk_trans_rec_type generic type in Get_WinningTerrMembers.
--                                   Directly call jtf_terr_1002_service_dyn.search_terr_rules in Get_WinningTerrMembers.
--      05/08/01    arpatel          taken out Get_WinningTerritories for service requests/tasks.
--      07/12/01    arpatel          changing 'country' to 'county' for squal_char06 values.
--      08/02/01    arpatel          added new bulk qualifier mappings for Oracle Service/Service-task
--      12/03/04    achanda          added new mapping for component and subcomponent : bug # 3726007
--      05/25/05    achanda          Modified to the new 12.0 architecture
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_SERVICE_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfptsvb.pls';

--    Start of Comments
--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an SERVICE_REQUEST
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--
--    IN:
--        p_api_version_number   IN  number               required
--        p_init_msg_list        IN  varchar2             optional --default = fnd_api.g_false
--        p_commit               IN  varchar2             optional --default = fnd_api.g_false
--        p_Org_Id               IN  number               required
--        p_TerrServReq_Rec      IN  JTF_Serv_Req_rec_type
--        p_Resource_Type        IN  varchar2
--        p_Role                 IN  varchar2
--        p_plan_start_date      IN  DATE DEFAULT NULL
--        p_plan_end_date        IN  DATE DEFAULT NULL
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
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrServReq_Rec          IN    JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_plan_start_date          IN          DATE DEFAULT NULL,
    p_plan_end_date            IN          DATE DEFAULT NULL,
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
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.start',
                   'Start of the procedure jtf_terr_service_pub.get_winningterrmembers');
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
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- debug message
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.parameters',
                   'Country : ' || p_TerrServReq_Rec.COUNTRY || ' City : ' || p_TerrServReq_Rec.CITY ||
                   ' Postal Code : ' || p_TerrServReq_Rec.POSTAL_CODE || ' State : ' || p_TerrServReq_Rec.STATE ||
                   ' Area Code : ' || p_TerrServReq_Rec.AREA_CODE || ' County : ' || p_TerrServReq_Rec.COUNTY ||
                   ' Company Name Range : ' || p_TerrServReq_Rec.COMP_NAME_RANGE || ' Province : ' || p_TerrServReq_Rec.PROVINCE ||
                   ' Problem Code : ' || p_TerrServReq_Rec.PROBLEM_CODE ||
                   ' sr creation channel : ' || p_TerrServReq_Rec.SR_CREATION_CHANNEL ||
                   ' vip customer : ' || p_TerrServReq_Rec.squal_char11 || ' sr problem code : ' || p_TerrServReq_Rec.squal_char12 ||
                   ' sr customer contact preference : ' || p_TerrServReq_Rec.squal_char13 ||
                   ' sr service contact coverage : ' || p_TerrServReq_Rec.squal_char21 ||
                   ' sr language : ' || p_TerrServReq_Rec.squal_char20 ||
                   ' Number of Employees : ' || p_TerrServReq_Rec.NUM_OF_EMPLOYEES || ' Party ID : ' || p_TerrServReq_Rec.PARTY_ID ||
                   ' Party Site ID : ' || p_TerrServReq_Rec.PARTY_SITE_ID ||
                   ' Incident Type ID : ' || p_TerrServReq_Rec.INCIDENT_TYPE_ID ||
                   ' Incident severity ID : ' || p_TerrServReq_Rec.INCIDENT_SEVERITY_ID ||
                   ' Incident urgency ID : ' || p_TerrServReq_Rec.INCIDENT_URGENCY_ID ||
                   ' Incident status ID : ' || p_TerrServReq_Rec.INCIDENT_STATUS_ID ||
                   ' platform ID : ' || p_TerrServReq_Rec.PLATFORM_ID || ' Support Site ID : ' || p_TerrServReq_Rec.SUPPORT_SITE_ID ||
                   ' Cust Site ID : ' || p_TerrServReq_Rec.CUSTOMER_SITE_ID ||
                   ' Inventory Item ID : ' || p_TerrServReq_Rec.INVENTORY_ITEM_ID ||
                   ' SR Platform Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM12 ||
                   ' SR Platform Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM13 ||
                   ' SR Product Category ID : ' || p_TerrServReq_Rec.SQUAL_NUM14 ||
                   ' PCS Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM15 ||
                   ' PCS Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM16 ||
                   ' PCS Component ID : ' || p_TerrServReq_Rec.SQUAL_NUM23 ||
                   ' PCS Subcomponent ID : ' || p_TerrServReq_Rec.SQUAL_NUM24 ||
                   ' SR Group Owner ID : ' || p_TerrServReq_Rec.SQUAL_NUM17 ||
                   ' SSI Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM18 ||
                   ' SSI Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM19||
                   ' p_plan_start_date: ' || p_plan_start_date ||
                   ' p_plan_end_date: ' || p_plan_end_date||
                   ' Day OF Week : ' || p_TerrServReq_Rec.DAY_OF_WEEK ||
                   ' Time OF Day : ' || p_TerrServReq_Rec.TIME_OF_DAY);

  END IF;

  /* delete and insert all the attributes into the trans table as name - value pair */
  DELETE jty_terr_nvp_trans_gt;
  INSERT INTO jty_terr_nvp_trans_gt (
     attribute_name
    ,num_value
    ,char_value
    ,date_value )
  ( SELECT 'COUNTRY'                  attribute_name
          ,null                       num_value
          ,p_TerrServReq_Rec.COUNTRY  char_value
          ,null                       date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CITY'                  attribute_name
          ,null                    num_value
          ,p_TerrServReq_Rec.CITY  char_value
          ,null                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'POSTAL_CODE'                  attribute_name
          ,null                           num_value
          ,p_TerrServReq_Rec.POSTAL_CODE  char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'STATE'                  attribute_name
          ,null                     num_value
          ,p_TerrServReq_Rec.STATE  char_value
          ,null                     date_value
    FROM  DUAL
    UNION ALL
    SELECT 'AREA_CODE'                  attribute_name
          ,null                         num_value
          ,p_TerrServReq_Rec.AREA_CODE  char_value
          ,null                         date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COUNTY'                  attribute_name
          ,null                      num_value
          ,p_TerrServReq_Rec.COUNTY  char_value
          ,null                      date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COMP_NAME_RANGE'                  attribute_name
          ,null                               num_value
          ,p_TerrServReq_Rec.COMP_NAME_RANGE  char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROVINCE'                  attribute_name
          ,null                        num_value
          ,p_TerrServReq_Rec.PROVINCE  char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROBLEM_CODE'                  attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.PROBLEM_CODE  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CREATION_CHANNEL'                  attribute_name
          ,null                                   num_value
          ,p_TerrServReq_Rec.SR_CREATION_CHANNEL  char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'VIP_CUSTOMER'                  attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char11  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_PROBLEM_CODE'               attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char12  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CUST_CNTCT_PREF'            attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char13  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_SRVC_CNTCT_CVG'             attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char21  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_LANGUAGE'                   attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char20  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_ID'                  attribute_name
          ,p_TerrServReq_Rec.PARTY_ID  num_value
          ,null                        char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.PARTY_SITE_ID  num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'NUM_OF_EMPLOYEES'                  attribute_name
          ,p_TerrServReq_Rec.NUM_OF_EMPLOYEES  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_TYPE_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_TYPE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_SEVERITY_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_SEVERITY_ID  num_value
          ,null                                    char_value
          ,null                                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_URGENCY_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_URGENCY_ID  num_value
          ,null                                   char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_STATUS_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_STATUS_ID  num_value
          ,null                                  char_value
          ,null                                  date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PLATFORM_ID'                  attribute_name
          ,p_TerrServReq_Rec.PLATFORM_ID  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SUPPORT_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.SUPPORT_SITE_ID  num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CUSTOMER_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.CUSTOMER_SITE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INVENTORY_ITEM_ID'                  attribute_name
          ,p_TerrServReq_Rec.INVENTORY_ITEM_ID  num_value
          ,null                                 char_value
          ,null                                 date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM12  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM13 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SPC_CATEGORY_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM14      num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM15  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM16 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_COMPONENT_ID'            attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM23 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_SUBCOMPONENT_ID'          attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM24  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_GROUP_OWNER_ID'               attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM17  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM18  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM19 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'DAY_OF_WEEK'                    attribute_name
          ,null                             num_value
          --,p_TerrServReq_Rec.DAY_OF_WEEK   char_value
          , DECODE(p_TerrServReq_Rec.DAY_OF_WEEK,FND_API.G_MISS_CHAR,null,
                   p_TerrServReq_Rec.DAY_OF_WEEK)   char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TIME_OF_DAY'                  attribute_name
          , null                            num_value
          --, p_TerrServReq_Rec.TIME_OF_DAY   char_value
          , DECODE(p_TerrServReq_Rec.TIME_OF_DAY,FND_API.G_MISS_CHAR,null,
                   p_TerrServReq_Rec.TIME_OF_DAY)   char_value
          ,null                             date_value
    FROM  DUAL

  );

  /*
    lp_Rec.squal_num01            := jtf_terr_number_list(p_TerrServReq_Rec.party_id);
    lp_Rec.squal_num02            := jtf_terr_number_list(p_TerrServReq_Rec.party_site_id);
    lp_Rec.squal_num03            := jtf_terr_number_list(p_TerrServReq_Rec.num_of_employees);
    lp_Rec.squal_num04            := jtf_terr_number_list(p_TerrServReq_Rec.incident_type_id);
    lp_Rec.squal_num05            := jtf_terr_number_list(p_TerrServReq_Rec.incident_severity_id);
    lp_Rec.squal_num06            := jtf_terr_number_list(p_TerrServReq_Rec.incident_urgency_id);
    lp_Rec.squal_num07            := jtf_terr_number_list(p_TerrServReq_Rec.incident_status_id);
    lp_Rec.squal_num08            := jtf_terr_number_list(p_TerrServReq_Rec.platform_id);
    lp_Rec.squal_num09            := jtf_terr_number_list(p_TerrServReq_Rec.support_site_id);
    lp_Rec.squal_num10            := jtf_terr_number_list(p_TerrServReq_Rec.customer_site_id);
    lp_Rec.squal_num11            := jtf_terr_number_list(p_TerrServReq_Rec.inventory_item_id);

    --arpatel 08/02
    Qualifier: SR Platform
    lp_Rec.squal_num12            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num12);  -- Inventory Item Id
    lp_Rec.squal_num13            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num13);  -- Organization Id

    Qualifier: SR Product Category
    lp_Rec.squal_num14            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num14);  -- Category Id

    Qualifier: SR Product, Component and Subcomponent
    lp_Rec.squal_num15            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num15);  -- Inventory Item Id
    lp_Rec.squal_num16            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num16);  -- Organization Id
    lp_Rec.squal_num23            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num23);  -- Component ID
    lp_Rec.squal_num24            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num24);  -- Subcomponent ID

    Qualifier: SR Group Owner
    lp_Rec.squal_num17            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num17);

    Contract Support Service Item
    lp_Rec.squal_num18            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num18);  -- Inventory Item Id
    lp_Rec.squal_num19            := jtf_terr_number_list(p_TerrServReq_Rec.squal_num19);  -- Organization Id

    lp_Rec.squal_char01           := jtf_terr_char_360list(p_TerrServReq_Rec.country);
    lp_Rec.squal_char02           := jtf_terr_char_360list(p_TerrServReq_Rec.city);
    lp_Rec.squal_char03           := jtf_terr_char_360list(p_TerrServReq_Rec.postal_code);
    lp_Rec.squal_char04           := jtf_terr_char_360list(p_TerrServReq_Rec.state);
    lp_Rec.squal_char05           := jtf_terr_char_360list(p_TerrServReq_Rec.area_code);
    lp_Rec.squal_char06           := jtf_terr_char_360list(p_TerrServReq_Rec.county);
    lp_Rec.squal_char07           := jtf_terr_char_360list(p_TerrServReq_Rec.comp_name_range);
    lp_Rec.squal_char08           := jtf_terr_char_360list(p_TerrServReq_Rec.province);
    lp_Rec.squal_char09           := jtf_terr_char_360list(p_TerrServReq_Rec.problem_code);
    lp_Rec.squal_char10           := jtf_terr_char_360list(p_TerrServReq_Rec.sr_creation_channel);

    --arpatel 08/02
    VIP Customers
    lp_Rec.squal_char11           := jtf_terr_char_360list(p_TerrServReq_Rec.squal_char11);

    Qualifier: SR Problem Code
    lp_Rec.squal_char12           := jtf_terr_char_360list(p_TerrServReq_Rec.squal_char12);

    Qualifier: SR Customer Contact Preference
    lp_Rec.squal_char13           := jtf_terr_char_360list(p_TerrServReq_Rec.squal_char13);

    Qualifier: SR Service Contract Coverage
    lp_Rec.squal_char21           := jtf_terr_char_360list(p_TerrServReq_Rec.squal_char21);

    SR Language -JDOCHERT 12/17/01 - bug#2152253
    lp_Rec.squal_char20            := jtf_terr_char_360list(p_TerrServReq_Rec.squal_char20);
  */

  JTY_ASSIGN_REALTIME_PUB.process_match (
         p_source_id     => -1002
        ,p_trans_id      => -1005
        ,p_program_name  => 'SERVICE/SERVICE REQUEST PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_match',
                     'API JTY_ASSIGN_REALTIME_PUB.process_match has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_match',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_match');
  END IF;

  JTY_ASSIGN_REALTIME_PUB.process_winners (
         p_source_id     => -1002
        ,p_trans_id      => -1005
        ,p_program_name  => 'SERVICE/SERVICE REQUEST PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,p_role          => p_role
        ,p_resource_type => p_resource_type
        ,p_plan_start_date => p_plan_start_date
        ,p_plan_end_date => p_plan_end_date
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,x_winners_rec   => lx_winners_rec);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_winners',
                     'API JTY_ASSIGN_REALTIME_PUB.process_winners has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_winners',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_winners');
  END IF;

  /*
    jtf_terr_1002_serv_req_dyn.search_terr_rules(
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
    x_TerrResource_tbl(l_counter).START_DATE           := lx_winners_rec.rsc_start_date(l_counter);
    x_TerrResource_tbl(l_counter).END_DATE             := lx_winners_rec.rsc_end_date(l_counter);
    x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := lx_winners_rec.absolute_rank(l_counter);

    l_counter := l_counter + 1;

  END LOOP;

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.end',
                   'End of the procedure jtf_terr_service_pub.get_winningterrmembers');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End Get_WinningTerrMembers;


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an SERVICE_REQUEST/TASK
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--
--    IN:
--        p_api_version_number   IN  number               required
--        p_init_msg_list        IN  varchar2             optional --default = fnd_api.g_false
--        p_commit               IN  varchar2             optional --default = fnd_api.g_false
--        p_Org_Id               IN  number               required
--        p_TerrSrvTask_Rec      IN  JTF_srv_Task_rec_type
--        p_Resource_Type        IN  varchar2
--        p_Role                 IN  varchar2
--        p_plan_start_date      IN  DATE DEFAULT NULL
--        p_plan_end_date        IN  DATE DEFAULT NULL
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
    p_TerrSrvTask_Rec          IN    JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_plan_start_date          IN          DATE DEFAULT NULL,
    p_plan_end_date            IN          DATE DEFAULT NULL,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
)
AS
  l_api_name                   CONSTANT VARCHAR2(30) := 'Get_WinningTerrMembers';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

  l_Counter                    NUMBER := 0;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
BEGIN
  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.start',
                   'Start of the procedure jtf_terr_service_pub.get_winningterrmembers');
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

  -- debug message
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.parameters',
                   'Country : ' || p_TerrSrvTask_Rec.COUNTRY || ' City : ' || p_TerrSrvTask_Rec.CITY ||
                   ' Postal Code : ' || p_TerrSrvTask_Rec.POSTAL_CODE || ' State : ' || p_TerrSrvTask_Rec.STATE ||
                   ' Area Code : ' || p_TerrSrvTask_Rec.AREA_CODE || ' County : ' || p_TerrSrvTask_Rec.COUNTY ||
                   ' Company Name Range : ' || p_TerrSrvTask_Rec.COMP_NAME_RANGE || ' Province : ' || p_TerrSrvTask_Rec.PROVINCE ||
                   ' Problem Code : ' || p_TerrSrvTask_Rec.PROBLEM_CODE ||
                   ' sr creation channel : ' || p_TerrSrvTask_Rec.SR_CREATION_CHANNEL ||
                   ' vip customer : ' || p_TerrSrvTask_Rec.squal_char11 || ' sr problem code : ' || p_TerrSrvTask_Rec.squal_char12 ||
                   ' sr customer contact preference : ' || p_TerrSrvTask_Rec.squal_char13 ||
                   ' sr service contact coverage : ' || p_TerrSrvTask_Rec.squal_char21 ||
                   ' sr language : ' || p_TerrSrvTask_Rec.squal_char20 ||
                   ' Number of Employees : ' || p_TerrSrvTask_Rec.NUM_OF_EMPLOYEES || ' Party ID : ' || p_TerrSrvTask_Rec.PARTY_ID ||
                   ' Party Site ID : ' || p_TerrSrvTask_Rec.PARTY_SITE_ID ||
                   ' Incident Type ID : ' || p_TerrSrvTask_Rec.INCIDENT_TYPE_ID ||
                   ' Incident severity ID : ' || p_TerrSrvTask_Rec.INCIDENT_SEVERITY_ID ||
                   ' Incident urgency ID : ' || p_TerrSrvTask_Rec.INCIDENT_URGENCY_ID ||
                   ' Incident status ID : ' || p_TerrSrvTask_Rec.INCIDENT_STATUS_ID ||
                   ' platform ID : ' || p_TerrSrvTask_Rec.PLATFORM_ID || ' Support Site ID : ' || p_TerrSrvTask_Rec.SUPPORT_SITE_ID ||
                   ' Cust Site ID : ' || p_TerrSrvTask_Rec.CUSTOMER_SITE_ID ||
                   ' Inventory Item ID : ' || p_TerrSrvTask_Rec.INVENTORY_ITEM_ID ||
                   ' Task Type ID : ' || p_TerrSrvTask_Rec.TASK_TYPE_ID ||
                   ' Task Status ID : ' || p_TerrSrvTask_Rec.TASK_STATUS_ID ||
                   ' Task Priority ID : ' || p_TerrSrvTask_Rec.TASK_PRIORITY_ID ||
                   ' SR Platform Inventory Item ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM12 ||
                   ' SR Platform Org ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM13 ||
                   ' SR Product Category ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM14 ||
                   ' PCS Inventory Item ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM15 ||
                   ' PCS Org ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM16 ||
                   ' PCS Component ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM23 ||
                   ' PCS Subcomponent ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM24 ||
                   ' SR Group Owner ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM17 ||
                   ' SSI Inventory Item ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM18 ||
                   ' SSI Org ID : ' || p_TerrSrvTask_Rec.SQUAL_NUM19||
                   ' p_plan_start_date: ' || p_plan_start_date ||
                   ' p_plan_end_date: ' || p_plan_end_date ||
                   ' Time Of Day : ' || p_TerrSrvTask_Rec.TIME_OF_DAY ||
                   ' Day Of week ' || p_TerrSrvTask_Rec.DAY_OF_WEEK);
  END IF;

  /* delete and insert all the attributes into the trans table as name - value pair */
  DELETE jty_terr_nvp_trans_gt;
  INSERT INTO jty_terr_nvp_trans_gt (
     attribute_name
    ,num_value
    ,char_value
    ,date_value )
  ( SELECT 'COUNTRY'                  attribute_name
          ,null                       num_value
          ,p_TerrSrvTask_Rec.COUNTRY  char_value
          ,null                       date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CITY'                  attribute_name
          ,null                    num_value
          ,p_TerrSrvTask_Rec.CITY  char_value
          ,null                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'POSTAL_CODE'                  attribute_name
          ,null                           num_value
          ,p_TerrSrvTask_Rec.POSTAL_CODE  char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'STATE'                  attribute_name
          ,null                     num_value
          ,p_TerrSrvTask_Rec.STATE  char_value
          ,null                     date_value
    FROM  DUAL
    UNION ALL
    SELECT 'AREA_CODE'                  attribute_name
          ,null                         num_value
          ,p_TerrSrvTask_Rec.AREA_CODE  char_value
          ,null                         date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COUNTY'                  attribute_name
          ,null                      num_value
          ,p_TerrSrvTask_Rec.COUNTY  char_value
          ,null                      date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COMP_NAME_RANGE'                  attribute_name
          ,null                               num_value
          ,p_TerrSrvTask_Rec.COMP_NAME_RANGE  char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROVINCE'                  attribute_name
          ,null                        num_value
          ,p_TerrSrvTask_Rec.PROVINCE  char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROBLEM_CODE'                  attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.PROBLEM_CODE  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CREATION_CHANNEL'                  attribute_name
          ,null                                   num_value
          ,p_TerrSrvTask_Rec.SR_CREATION_CHANNEL  char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'VIP_CUSTOMER'                  attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.squal_char11  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_PROBLEM_CODE'               attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.squal_char12  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CUST_CNTCT_PREF'            attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.squal_char13  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_SRVC_CNTCT_CVG'             attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.squal_char21  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_LANGUAGE'                   attribute_name
          ,null                            num_value
          ,p_TerrSrvTask_Rec.squal_char20  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.PARTY_ID  num_value
          ,null                        char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_SITE_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.PARTY_SITE_ID  num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'NUM_OF_EMPLOYEES'                  attribute_name
          ,p_TerrSrvTask_Rec.NUM_OF_EMPLOYEES  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_TYPE_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.INCIDENT_TYPE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_SEVERITY_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.INCIDENT_SEVERITY_ID  num_value
          ,null                                    char_value
          ,null                                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_URGENCY_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.INCIDENT_URGENCY_ID  num_value
          ,null                                   char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_STATUS_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.INCIDENT_STATUS_ID  num_value
          ,null                                  char_value
          ,null                                  date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PLATFORM_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.PLATFORM_ID  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SUPPORT_SITE_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.SUPPORT_SITE_ID  num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CUSTOMER_SITE_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.CUSTOMER_SITE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INVENTORY_ITEM_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.INVENTORY_ITEM_ID  num_value
          ,null                                 char_value
          ,null                                 date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_TYPE_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.TASK_TYPE_ID  num_value
          ,null                            char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_STATUS_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.TASK_STATUS_ID  num_value
          ,null                              char_value
          ,null                              date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TASK_PRIORITY_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.TASK_PRIORITY_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM12  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_ORG_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM13 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SPC_CATEGORY_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM14      num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM15  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_ORG_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM16 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_COMPONENT_ID'            attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM23 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_SUBCOMPONENT_ID'          attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM24  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_GROUP_OWNER_ID'               attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM17  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM18  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_ORG_ID'                  attribute_name
          ,p_TerrSrvTask_Rec.SQUAL_NUM19 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'DAY_OF_WEEK'                  attribute_name
          ,null                          num_value
          --,p_TerrSrvTask_Rec.DAY_OF_WEEK char_value
          , DECODE(p_TerrSrvTask_Rec.DAY_OF_WEEK,FND_API.G_MISS_CHAR,null,
                   p_TerrSrvTask_Rec.DAY_OF_WEEK)   char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TIME_OF_DAY'                  attribute_name
          ,null                          num_value
          --,p_TerrSrvTask_Rec.TIME_OF_DAY char_value
          ,DECODE(p_TerrSrvTask_Rec.TIME_OF_DAY ,FND_API.G_MISS_CHAR,null,
                   p_TerrSrvTask_Rec.TIME_OF_DAY ) char_value
          ,null                          date_value
    FROM  DUAL
  );

  /*
    lp_Rec.squal_num01            := jtf_terr_number_list(p_TerrSrvTask_Rec.party_id);
    lp_Rec.squal_num02            := jtf_terr_number_list(p_TerrSrvTask_Rec.party_site_id);
    lp_Rec.squal_num03            := jtf_terr_number_list(p_TerrSrvTask_Rec.num_of_employees);
    lp_Rec.squal_num04            := jtf_terr_number_list(p_TerrSrvTask_Rec.incident_type_id);
    lp_Rec.squal_num05            := jtf_terr_number_list(p_TerrSrvTask_Rec.incident_severity_id);
    lp_Rec.squal_num06            := jtf_terr_number_list(p_TerrSrvTask_Rec.incident_urgency_id);
    lp_Rec.squal_num07            := jtf_terr_number_list(p_TerrSrvTask_Rec.incident_status_id);
    lp_Rec.squal_num08            := jtf_terr_number_list(p_TerrSrvTask_Rec.platform_id);
    lp_Rec.squal_num09            := jtf_terr_number_list(p_TerrSrvTask_Rec.support_site_id);
    lp_Rec.squal_num10            := jtf_terr_number_list(p_TerrSrvTask_Rec.customer_site_id);
    lp_Rec.squal_num11            := jtf_terr_number_list(p_TerrSrvTask_Rec.inventory_item_id);

    lp_rec.squal_num20            := jtf_terr_number_list(p_TerrSrvTask_Rec.task_type_id);
    lp_rec.squal_num21            := jtf_terr_number_list(p_TerrSrvTask_Rec.task_status_id);
    lp_rec.squal_num22            := jtf_terr_number_list(p_TerrSrvTask_Rec.task_priority_id);

    --arpatel 08/02
    Qualifier: SR Platform
    lp_Rec.squal_num12            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num12);  -- Inventory Item Id
    lp_Rec.squal_num13            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num13);  -- Organization Id

    Qualifier: SR Product Category
    lp_Rec.squal_num14            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num14);  -- Category Id

    Qualifier: SR Product, Component, Subcomponent
    lp_Rec.squal_num15            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num15);  -- Inventory Item Id
    lp_Rec.squal_num16            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num16);  -- Organization Id
    lp_Rec.squal_num23            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num23);  -- Component ID
    lp_Rec.squal_num24            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num24);  -- Subcomponent ID

    Qualifier: SR Group Owner
    lp_Rec.squal_num17            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num17);

    Contract Support Service Item
    lp_Rec.squal_num18            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num18);  -- Inventory Item Id
    lp_Rec.squal_num19            := jtf_terr_number_list(p_TerrSrvTask_Rec.squal_num19);  -- Organization Id

    lp_Rec.squal_char01           := jtf_terr_char_360list(p_TerrSrvTask_Rec.country);
    lp_Rec.squal_char02           := jtf_terr_char_360list(p_TerrSrvTask_Rec.city);
    lp_Rec.squal_char03           := jtf_terr_char_360list(p_TerrSrvTask_Rec.postal_code);
    lp_Rec.squal_char04           := jtf_terr_char_360list(p_TerrSrvTask_Rec.state);
    lp_Rec.squal_char05           := jtf_terr_char_360list(p_TerrSrvTask_Rec.area_code);
    lp_Rec.squal_char06           := jtf_terr_char_360list(p_TerrSrvTask_Rec.county);
    lp_Rec.squal_char07           := jtf_terr_char_360list(p_TerrSrvTask_Rec.comp_name_range);
    lp_Rec.squal_char08           := jtf_terr_char_360list(p_TerrSrvTask_Rec.province);
    lp_Rec.squal_char09           := jtf_terr_char_360list(p_TerrSrvTask_Rec.problem_code);
    lp_Rec.squal_char10           := jtf_terr_char_360list(p_TerrSrvTask_Rec.sr_creation_channel);

    --arpatel 08/02
    VIP Customers
    lp_Rec.squal_char11           := jtf_terr_char_360list(p_TerrSrvTask_Rec.squal_char11);

    Qualifier: SR Problem Code
    lp_Rec.squal_char12           := jtf_terr_char_360list(p_TerrSrvTask_Rec.squal_char12);

    Qualifier: SR Customer Contact Preference
    lp_Rec.squal_char13           := jtf_terr_char_360list(p_TerrSrvTask_Rec.squal_char13);

    Qualifier: SR Service Contract Coverage
    lp_Rec.squal_char21           := jtf_terr_char_360list(p_TerrSrvTask_Rec.squal_char21);

    SR Language -JDOCHERT 12/17/01 - bug#2152253
    lp_Rec.squal_char20            := jtf_terr_char_360list(p_TerrSrvTask_Rec.squal_char20);
  */

  JTY_ASSIGN_REALTIME_PUB.process_match (
         p_source_id     => -1002
        ,p_trans_id      => -1009
        ,p_program_name  => 'SERVICE/SERVICE REQUEST AND TASKS PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_match',
                     'API JTY_ASSIGN_REALTIME_PUB.process_match has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_match',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_match');
  END IF;

  JTY_ASSIGN_REALTIME_PUB.process_winners (
         p_source_id     => -1002
        ,p_trans_id      => -1009
        ,p_program_name  => 'SERVICE/SERVICE REQUEST AND TASKS PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,p_role          => p_role
        ,p_resource_type => p_resource_type
        ,p_plan_start_date => p_plan_start_date
        ,p_plan_end_date => p_plan_end_date
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,x_winners_rec   => lx_winners_rec);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_winners',
                     'API JTY_ASSIGN_REALTIME_PUB.process_winners has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.process_winners',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_winners');
  END IF;

  /*
    jtf_terr_1002_srv_task_dyn.search_terr_rules(
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
    x_TerrResource_tbl(l_counter).START_DATE           := lx_winners_rec.rsc_start_date(l_counter);
    x_TerrResource_tbl(l_counter).END_DATE             := lx_winners_rec.rsc_end_date(l_counter);
    x_TerrResource_tbl(l_counter).ABSOLUTE_RANK        := lx_winners_rec.absolute_rank(l_counter);

    l_counter := l_counter + 1;

  END LOOP;

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.end',
                   'End of the procedure jtf_terr_service_pub.get_winningterrmembers');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_service_pub.get_winningterrmembers.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_WinningTerrMembers;

END JTF_TERR_SERVICE_PUB;

/
