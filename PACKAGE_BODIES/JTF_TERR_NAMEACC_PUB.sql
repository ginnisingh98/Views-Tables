--------------------------------------------------------
--  DDL for Package Body JTF_TERR_NAMEACC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_NAMEACC_PUB" AS
/* $Header: jtftrnpb.pls 120.6 2006/04/21 13:15:17 spai ship $ */
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_NAMEACC_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtftrnpb.pls';
   G_NEW_LINE        VARCHAR2(02) := FND_GLOBAL.Local_Chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;
---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_NAMEACC_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package is a public API for getting winning territory
--      resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--
--    HISTORY
--    08/01/00    ARPATEL     Created
--    01/07/04    SGKUMAR     changed the code to get parent territory from
--                            JTF_TERR_ALL to JTF_TERR
--    End of Comments
procedure Set_Winners_tbl
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_party_id                 IN    number  ,
    p_party_site_id            IN    number  ,
    p_asof_date                IN    date,
    p_source_id                IN    number,
    p_trans_id                 IN    number,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_api_mode                 IN    varchar2,
    x_party_name               OUT NOCOPY  varchar2,
    x_session_id               OUT NOCOPY  number,
    x_return_status            OUT NOCOPY  varchar2,
    x_msg_count                OUT NOCOPY  number,
    x_msg_data                 OUT NOCOPY  varchar2
)
AS
   l_Terr_Id                 NUMBER := 0;
   lP_Init_Msg_List          VARCHAR2(2000);
   lP_resource_type          VARCHAR2(60) := NULL;
   lP_role                   VARCHAR2(60) := NULL;
   lX_Return_Status          VARCHAR2(1);
   lX_Msg_Count              NUMBER;
   lX_Msg_Data               VARCHAR2(2000);
   lp_trans_Rec               JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
     -- JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
   lx_winners_rec           JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type ;
--        JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Set_Winners_tbl';
   l_api_version_number         CONSTANT NUMBER       := 1.0;
   l_return_status              VARCHAR2(1);
   l_Counter                    NUMBER := 0;
   l_RscCounter                 NUMBER := 0;
   l_NumberOfWinners            NUMBER ;
   l_RetCode                    BOOLEAN;
   dummy1                      VARCHAR2(30);
   l_state                     VARCHAR2(60);
   l_terr_group_name           VARCHAR(240) := 'Test';
   l_role_name                 VARCHAR2(240);
   l_num_res_rows              NUMBER := 0;
BEGIN
    -- New logging guidelines
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl.begin',
                   'Start of the procedure JTF_TERR_NAMEACC_PUB.Set_Winners_tbl');
    END IF;
    FND_MSG_PUB.initialize;
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
        FND_MESSAGE.Set_Name('JTF', G_PKG_NAME || '_START');
        FND_MSG_PUB.Add;
    END IF;
    -- API body
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    lx_return_status := FND_API.G_RET_STS_SUCCESS;
    lx_msg_data := null;

    -- Code for party name here...
    if p_party_id is not null
    then
       Select distinct party_name
       into x_party_name
       from HZ_PARTIES
       where party_id = p_party_id;
    end if;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl.begin',
                   'Initializing Input and Output records');
  END IF;
    -- Assign input parameters to lp_trans_Rec
  lp_trans_rec.trans_object_id1 := jtf_terr_number_list(p_party_id);
  IF p_party_site_id is not null
  THEN
     lp_trans_rec.trans_object_id2 := jtf_terr_number_list(p_party_site_id);
  ELSE
       lp_trans_rec.trans_object_id2 := jtf_terr_number_list(null);
  END If;
  lp_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
  lp_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
  lp_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
  IF p_asof_date is null
  THEN
     lp_trans_rec.txn_date := jtf_terr_date_list(null);
  ELSE
     lp_trans_rec.txn_date := jtf_terr_date_list(p_asof_date);
  END IF;
    --dbms_output.put_line('Resetting global vars ');
    --Reset the global variables
    l_RetCode := JTF_TERRITORY_GLOBAL_PUB.Reset;
  IF p_api_mode = 'CURRENT'
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_REALTIME_PUB.get_winners',
                   'Calling procedure JTY_ASSIGN_REALTIME_PUB.get_winners in RealTime Mode');
    END IF;
    JTY_ASSIGN_REALTIME_PUB.get_winners(
	P_api_version_number => 1.0,
	P_init_msg_list => FND_API.G_FALSE,
	P_source_id => -1001,
	P_trans_id => -1002,
        P_mode => 'REAL TIME:LOOKUP',
        P_param_passing_mechanism => 'PBR',
        P_program_name => 'SALES/ACCOUNT PROGRAM',
        P_trans_rec => lp_trans_rec,
        P_name_value_pair => null,
        P_resource_type => null,
        P_role => null,
        X_return_status => lx_return_status,
        X_msg_count => lx_msg_count,
        X_msg_data => lx_msg_data,
        X_winners_rec => lx_winners_rec);
   ELSE
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_REALTIME_PUB.get_winners',
                   'Calling procedure JTY_ASSIGN_REALTIME_PUB.get_winners in Date EFfective Mode');
    END IF;
    JTY_ASSIGN_REALTIME_PUB.get_winners(
	P_api_version_number => 1.0,
	P_init_msg_list => FND_API.G_FALSE,
	P_source_id => -1001,
	P_trans_id => -1002,
        P_mode => 'DATE EFFECTIVE:LOOKUP',
        P_param_passing_mechanism => 'PBR',
        P_program_name => 'SALES/ACCOUNT PROGRAM',
        P_trans_rec => lp_trans_rec,
        P_name_value_pair => NULL,
        P_resource_type => NULL,
        P_role => NULL,
        X_return_status => lx_return_status,
        X_msg_count => lx_msg_count,
        X_msg_data => lx_msg_data,
        X_winners_rec => lx_winners_rec);
   END IF;
  IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- debug message
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_REALTIME_PUB.get_winners',
                     'JTY_ASSIGN_REALTIME_PUB.get_winners API has failed');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_REALTIME_PUB.get_winners',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.get_winners');
    END IF;
/*
    JTF_TERR_ASSIGN_PUB.get_winners
    (   p_api_version_number    =>          p_api_version_number,
        p_init_msg_list         =>          p_init_msg_list,
        p_use_type              =>          'LOOKUP',
        p_source_id             =>          -1001, -- -1001 Oracle Sales
        p_trans_id              =>          -1002, -- -1002 Account
        p_trans_rec             =>          lp_trans_Rec,
        p_resource_type         =>          FND_API.G_MISS_CHAR,
        p_role                  =>          FND_API.G_MISS_CHAR,
        p_top_level_terr_id     =>          FND_API.G_MISS_NUM,
        p_num_winners           =>          FND_API.G_MISS_NUM,
        x_return_status         =>          lx_return_status,
        x_msg_count             =>          lx_msg_count,
        x_msg_data              =>          lx_msg_data,
        x_winners_rec           =>          lx_winners_rec
    );
*/
   IF (( lx_winners_rec.terr_id.FIRST is not null) OR (TRUNC(lx_winners_rec.terr_id.FIRST)<>'' ))
   THEN
     BEGIN
         SELECT jtf_terr_results_s.nextval into x_session_id FROM sys.dual;
         FOR i in lx_winners_rec.terr_id.FIRST..lx_winners_rec.terr_id.LAST
         LOOP
     -- add processing to find the territory group name
     -- assumption that territory group is the parent territory of the winning territory
/*
     SELECT TA.NAME
     INTO l_terr_group_name
     FROM JTF_TERR TA,
          JTF_TERR TA2
     WHERE
          TA.TERR_ID = TA2.PARENT_TERRITORY_ID
     AND  TA2.TERR_ID = lx_winners_rec.terr_id(i);
 */
     -- Added processing to show role_name 01/28/03
     if lx_winners_rec.role(i) is not null
     then
     SELECT ROLE_NAME
     INTO l_role_name
     FROM JTF_RS_ROLES_VL
     WHERE ROLE_CODE = lx_winners_rec.role(i);
     end if;
     l_num_res_rows := l_num_res_rows + 1;
     --Insert into temporary table here
     INSERT INTO JTF_TAE_RPT_STAGING_OUT(
           TRANS_OBJECT_ID,
           TRANS_DETAIL_OBJECT_ID,
           TRANS_OBJECT_TYPE_ID,
           SOURCE_ID,
           SESSION_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           TERR_RANK,
           RESOURCE_ID,
           RESOURCE_TYPE,
           GROUP_ID,
           ROLE,
           RESOURCE_NAME,
           AT_CHAR01,
           AT_CHAR02,
           AT_CHAR03,
           AT_CHAR04,
           AT_CHAR05,
           AT_CHAR06,
           AT_CHAR07
          ) VALUES (
          lx_winners_rec.trans_object_id(i),
          nvl(lx_winners_rec.trans_detail_object_id(i), -1),
          -1,
          -1, --p_source_id,
          x_session_id,
          SYSDATE,
          -1,
          -1,
          SYSDATE,
          -1,
          lx_winners_rec.terr_id(i),
          lx_winners_rec.absolute_rank(i),
          lx_winners_rec.resource_id(i),
          lx_winners_rec.resource_type(i),
          lx_winners_rec.group_id(i),
          lx_winners_rec.role(i),
          lx_winners_rec.resource_name(i),
          lx_winners_rec.resource_job_title(i),
          lx_winners_rec.resource_phone(i),
          lx_winners_rec.resource_email(i),
          lx_winners_rec.resource_mgr_name(i),
          lx_winners_rec.resource_mgr_phone(i),
          l_role_name,
          lx_winners_rec.resource_mgr_email(i)
          );
     end loop;
   END;
  END IF;
  COMMIT;
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl',
                   'Number of winning resources : ' || l_num_res_rows);
  END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', G_PKG_NAME || '_END');
        FND_MSG_PUB.Add;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
            p_data            =>      x_msg_data
        );
    --dbms_output.put_line('JTF_TERR_LOOKUP_PUB: End ');
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl',
                   'End of the procedure tf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl');
  END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     IF ( lx_msg_data is null )
     THEN
       x_msg_data := SQLCODE || ' : ' || SQLERRM;
       x_msg_count := 1;
      ELSE
        x_msg_data := lx_msg_data;
        x_msg_count := lx_msg_count;

      END IF;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTF_TERR_NAMEACC_PUB.Set_Winners_tbl.OTHERS',
                     substr(x_msg_data, 1, 4000));
    END IF;
  End  Set_Winners_tbl;
END JTF_TERR_NAMEACC_PUB;


/
