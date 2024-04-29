--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_RESOURCE_PVT" AS
/* $Header: jtfvtrsb.pls 120.4.12010000.2 2009/09/07 06:31:43 vpalle ship $ */

--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_RESOURCE_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory resource private api's.
--      This package is a private API for inserting territory
--      resources into JTF tables. It contains specification
--      for pl/sql records and tables related to territory
--      resource.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for PRIVATE USE ONLY use
--
--    HISTORY
--      07/29/99   VNEDUNGA         Created
--      12/22/99   NEDUNGA          Making changes to confirm to
--                                  JTF_TERR_RSC_ALL table change
--      01/06/00   VNEDUNGA         Fixing problem with the build rule
--                                  expression
--      01/16/00   VNEDUNGA         Commenting out dbms_output
--      01/17/00   VNEDUNGA         Cahnging the the hard code value for
--                                  resourece qualifer type from 1 to -1001
--      02/10/00   VNEDUNGA         Changing call to table handlers
--      03/15/00   VNEDUNGA         Fixng the messaging and record validation
--      06/08/00   VNEDUNGA         Adding group id column to resource record
--
--      06/12/00   JDOCHERT         Added function (get_group_name)
--                                  to get the name
--                                  of the group that the resource
--                                  belongs to
--
--      07/20/00   JDOCHERT         Changed as follows in Create_TerrResource
--                                  as this meant that a terr_rsc_id passed
--                                  into Create API was ignored:
--                                  l_terr_type_id := 0;
--                                  TO
--                                  L_TerrRsc_Id                 NUMBER := P_TERRRSC_REC.TERR_RSC_ID;
--
--     09/16/00    VVUYYURU         Added the NEW procedure Copy_Terr_Resources
--
--     09/19/00    JDOCHERT         Added 'validate_terr_rsc_access_UK'
--                                  and 'Transfer_Resource_Territories' procedures
--
--     10/04/00    JDOCHERT         Added get_rs_type_name function
--
--     02/15/01    ARPATEL          Adapted 'Transfer_Resource_Territories' to allow mass updates
--     09/04/01    ARPATEL          Adapted 'Transfer_Resource_Territories' to allow mass assignment of unallocated terrs
--     05/30/01	   ARPATEL	    Added commit processing to transfer_resource_territories and removed from JTFTRMRU.fmb form
--     05/30/01    ARPATEL	    Added end_date_active checks for cursors of transfer_resource_territories
--     06/06/01    ARPATEL	    Changed SYSDATE-1 to SYSDATE in transfer_resource_territories
--     06/14/01    ARPATEL	    Taken out start/end date active clauses in transfer_resource_territories cursors.
--     04/06/04    SHLI             Took out check_for_duplicate2 from update_terr_resource.
--     04/13/04    VXSRINIV         Added new proc check_for_duplicate2_updates and called from update_terr_resource.
--     09/15/05	   mhtran	    added TRANS_ACCESS_CODE
--
--     End of Comments




-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
    G_PKG_NAME        CONSTANT VARCHAR2(30):='JTF_TERRITORY_RESOURCE_PVT';
    G_FILE_NAME       CONSTANT VARCHAR2(12):='jtfvtrsb.pls';


    G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
    G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
    G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
    G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
    G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;



--Vai: Bug # 3520561
PROCEDURE Check_for_duplicate2_updates (
   P_TerrRsc_Rec        IN  TerrResource_Rec_type,
   x_Return_Status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2) AS

   l_start_date_active   DATE;
   l_end_date_active     DATE;
   l_index               NUMBER := 0;
   l_Res_Counter         NUMBER := 0;
   l_Temp                VARCHAR2(1);
   l_Terr_Id             NUMBER;

   --check if duplicate resource_id, group, role exists for this territory
   cursor c_res (p_terr_id NUMBER)is
   Select JTR2.start_date_active, nvl(JTR2.end_date_active,to_date('31/12/4712','DD/MM/RRRR')) end_date_active
   from JTF_TERR_RSC_ALL JTR1, JTF_TERR_RSC_ALL JTR2
   where JTR2.TERR_ID = p_Terr_Id
   AND JTR1.TERR_RSC_ID = P_TerrRsc_Rec.Terr_Rsc_Id
   --resource with same role and group assigned to this territory
   AND JTR2.RESOURCE_ID = decode(P_TerrRsc_Rec.Resource_Id, FND_API.G_MISS_NUM, JTR1.RESOURCE_ID, P_TerrRsc_Rec.Resource_Id)
   AND JTR2.RESOURCE_TYPE = decode(P_TerrRsc_Rec.Resource_TYPE , FND_API.G_MISS_CHAR, JTR1.RESOURCE_TYPE, P_TerrRsc_Rec.Resource_TYPE)
   AND JTR2.GROUP_ID = decode( P_TerrRsc_Rec.GROUP_ID , FND_API.G_MISS_NUM,JTR1.GROUP_ID,P_TerrRsc_Rec.GROUP_ID )
   AND JTR2.ROLE = decode(P_TerrRsc_Rec.ROLE, FND_API.G_MISS_CHAR, JTR1.ROLE, P_TerrRsc_Rec.ROLE )
   AND JTR2.TERR_RSC_ID <> P_TerrRsc_Rec.Terr_Rsc_Id;

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get the missing values from the database to check the duplicate resource.
   BEGIN
       SELECT terr_id, start_date_active, nvl(end_date_active,to_date('31/12/4712','DD/MM/RRRR')) end_date_active
       INTO l_terr_id,l_start_date_active, l_end_date_active
       FROM JTF_TERR_RSC_ALL
       WHERE TERR_RSC_ID = P_TerrRsc_Rec.Terr_Rsc_Id;

       IF ( P_TerrRsc_Rec.START_DATE_ACTIVE IS NOT NULL AND P_TerrRsc_Rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
          l_start_date_active :=   P_TerrRsc_Rec.START_DATE_ACTIVE;
       END IF;
       -- Else use the date from Database

       IF ( P_TerrRsc_Rec.END_DATE_ACTIVE IS NOT NULL AND P_TerrRsc_Rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
          l_end_date_active :=   P_TerrRsc_Rec.END_DATE_ACTIVE;
       END IF;
       -- Else use the date from Database

       IF ( P_TerrRsc_Rec.TERR_ID IS NOT NULL AND P_TerrRsc_Rec.TERR_ID <> FND_API.G_MISS_NUM ) THEN
          l_Terr_Id :=   P_TerrRsc_Rec.TERR_ID;
       END IF;
       -- Else use the date from Database

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'NO_DATA_FOUND Exception in Chack Duplicate2_update procedure : ' || SQLERRM);
        END IF;
   END;

   FOR l_c_res IN c_res(l_Terr_Id) LOOP

       IF l_start_date_active IS NOT NULL AND l_end_date_active IS NOT NULL THEN

           IF l_start_date_active BETWEEN l_c_res.start_date_active AND l_c_res.end_date_active THEN
               l_temp := 'X';
                EXIT;
           END IF;

           IF l_end_date_active BETWEEN l_c_res.start_date_active AND l_c_res.end_date_active THEN
               l_temp := 'X';
               EXIT;
           END IF;

           IF l_c_res.start_date_active BETWEEN l_start_date_active AND l_end_date_active THEN
               l_temp := 'X';
               EXIT;
           END IF;

           IF l_c_res.end_date_active BETWEEN l_start_date_active AND l_end_date_active THEN
               l_temp := 'X';
               EXIT;
           END IF;

       END IF;

   END LOOP;

   if l_temp = 'X' then
      fnd_msg_pub.initialize;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('JTF', 'JTF_TERR_DUPLICATE_RESOURCE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(  P_count          =>   x_msg_count,
                                  P_data           =>   x_msg_data);
   end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --no duplicates
      NULL;
   WHEN OTHERS THEN
      X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others Exception in Check_for_duplicate2 ' || SQLERRM);
      END IF;

END Check_for_duplicate2_updates;

/* ARPATEL: bug#2849410 fix */
PROCEDURE Check_for_duplicate2 (
   P_TerrRsc_Rec        IN  TerrResource_Rec_type,
   x_Return_Status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) AS
   l_index               NUMBER := 0;
   l_Res_Counter         NUMBER := 0;
   l_Temp                VARCHAR2(1);
   l_Terr_Id             NUMBER;

   cursor c_res is
   Select start_date_active, nvl(end_date_active,to_date('31/12/4712','DD/MM/RRRR')) end_date_active
   from JTF_TERR_RSC_ALL
   where TERR_ID = P_TerrRsc_Rec.Terr_Id
   --resource with same role and group assigned to this territory
   AND RESOURCE_ID = P_TerrRsc_Rec.Resource_Id
   AND ( (RESOURCE_TYPE IS NULL  and ( ( P_TerrRsc_Rec.Resource_TYPE IS NULL ) OR (P_TerrRsc_Rec.Resource_TYPE = FND_API.G_MISS_CHAR) ) )
        OR  (RESOURCE_TYPE = P_TerrRsc_Rec.Resource_TYPE))
   AND ( (GROUP_ID IS NULL and ( ( P_TerrRsc_Rec.GROUP_ID IS NULL ) OR (P_TerrRsc_Rec.GROUP_ID = FND_API.G_MISS_NUM ) ) )
        OR  (P_TerrRsc_Rec.GROUP_ID = GROUP_ID) )
   AND ( (ROLE IS NULL and ( (P_TerrRsc_Rec.ROLE IS NULL ) OR (P_TerrRsc_Rec.ROLE = FND_API.G_MISS_CHAR) ) )
        OR  (P_TerrRsc_Rec.ROLE = ROLE));

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR l_c_res IN c_res LOOP

       IF P_TerrRsc_Rec.START_DATE_ACTIVE IS NOT NULL AND P_TerrRsc_Rec.END_DATE_ACTIVE IS NOT NULL THEN

           IF P_TerrRsc_Rec.START_DATE_ACTIVE BETWEEN l_c_res.start_date_active AND l_c_res.end_date_active THEN
               l_temp := 'X';
                EXIT;
           END IF;

           IF P_TerrRsc_Rec.END_DATE_ACTIVE BETWEEN l_c_res.start_date_active AND l_c_res.end_date_active THEN
               l_temp := 'X';
               EXIT;
           END IF;

           IF l_c_res.start_date_active BETWEEN P_TerrRsc_Rec.START_DATE_ACTIVE AND P_TerrRsc_Rec.END_DATE_ACTIVE THEN
               l_temp := 'X';
               EXIT;
           END IF;

           IF l_c_res.end_date_active BETWEEN P_TerrRsc_Rec.START_DATE_ACTIVE AND P_TerrRsc_Rec.END_DATE_ACTIVE THEN
               l_temp := 'X';
               EXIT;
           END IF;

       END IF;

   END LOOP;

   if l_temp = 'X' then
      fnd_msg_pub.initialize;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('JTF', 'JTF_TERR_DUPLICATE_RESOURCE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get (  P_count =>   x_msg_count, P_data =>   x_msg_data);
   end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --no duplicates
      NULL;
   WHEN OTHERS THEN
      X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'Others Exception in Check_for_duplicate2 ' || SQLERRM);
      END IF;
END check_for_duplicate2;

PROCEDURE convert_terrrsc_wflex (
    p_terrrsc_tbl_wflex   IN       TerrResource_tbl_type_wflex,
    x_terrrsc_tbl   OUT NOCOPY      TerrResource_tbl_type
)
   AS
      l_counter                     NUMBER;
   BEGIN
      -- If the table is empty
      IF p_terrrsc_tbl_wflex.COUNT = 0
      THEN
         RETURN;
      END IF;

    --
    FOR l_counter IN 1 .. p_terrrsc_tbl_wflex.COUNT
    LOOP
       --
         x_terrrsc_tbl (l_counter).terr_rsc_id :=
            p_terrrsc_tbl_wflex (l_counter).terr_rsc_id;
         x_terrrsc_tbl (l_counter).last_update_date :=
            p_terrrsc_tbl_wflex (l_counter).last_update_date;
         x_terrrsc_tbl (l_counter).last_updated_by :=
            p_terrrsc_tbl_wflex (l_counter).last_updated_by;
         x_terrrsc_tbl (l_counter).creation_date :=
            p_terrrsc_tbl_wflex (l_counter).creation_date;
         x_terrrsc_tbl (l_counter).created_by :=
            p_terrrsc_tbl_wflex (l_counter).created_by;
         x_terrrsc_tbl (l_counter).last_update_login :=
            p_terrrsc_tbl_wflex (l_counter).last_update_login;
         x_terrrsc_tbl (l_counter).terr_id :=
            p_terrrsc_tbl_wflex (l_counter).terr_id;
         x_terrrsc_tbl (l_counter).resource_id :=
            p_terrrsc_tbl_wflex (l_counter).resource_id;
         x_terrrsc_tbl (l_counter).group_id :=
            p_terrrsc_tbl_wflex (l_counter).group_id;
         x_terrrsc_tbl (l_counter).resource_type :=
            p_terrrsc_tbl_wflex (l_counter).resource_type;
         x_terrrsc_tbl (l_counter).role := p_terrrsc_tbl_wflex (l_counter).role;
         x_terrrsc_tbl (l_counter).primary_contact_flag :=
            p_terrrsc_tbl_wflex (l_counter).primary_contact_flag;
         x_terrrsc_tbl (l_counter).start_date_active :=
            p_terrrsc_tbl_wflex (l_counter).start_date_active;
         x_terrrsc_tbl (l_counter).end_date_active :=
            p_terrrsc_tbl_wflex (l_counter).end_date_active;
         x_terrrsc_tbl (l_counter).full_access_flag :=
            p_terrrsc_tbl_wflex (l_counter).full_access_flag;
         x_terrrsc_tbl (l_counter).org_id := p_terrrsc_tbl_wflex (l_counter).org_id;
         x_terrrsc_tbl (l_counter).ATTRIBUTE_CATEGORY := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE_CATEGORY;
         x_terrrsc_tbl (l_counter).ATTRIBUTE1  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE1;
         x_terrrsc_tbl (l_counter).ATTRIBUTE2  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE2;
         x_terrrsc_tbl (l_counter).ATTRIBUTE3  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE3;
         x_terrrsc_tbl (l_counter).ATTRIBUTE4  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE4;
         x_terrrsc_tbl (l_counter).ATTRIBUTE5  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE5;
         x_terrrsc_tbl (l_counter).ATTRIBUTE6  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE6;
         x_terrrsc_tbl (l_counter).ATTRIBUTE7  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE7;
         x_terrrsc_tbl (l_counter).ATTRIBUTE8  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE8;
         x_terrrsc_tbl (l_counter).ATTRIBUTE9  := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE9;
         x_terrrsc_tbl (l_counter).ATTRIBUTE10 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE10;
         x_terrrsc_tbl (l_counter).ATTRIBUTE11 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE11;
         x_terrrsc_tbl (l_counter).ATTRIBUTE12 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE12;
         x_terrrsc_tbl (l_counter).ATTRIBUTE13 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE13;
         x_terrrsc_tbl (l_counter).ATTRIBUTE14 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE14;
         x_terrrsc_tbl (l_counter).ATTRIBUTE15 := p_terrrsc_tbl_wflex (l_counter).ATTRIBUTE15;
    END LOOP;
   --
END convert_terrrsc_wflex;



--    ***************************************************
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrResource
--    Type      : PUBLIC
--    Function  : To create Territory Resources - which will insert
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type_wflex      := G_MISS_TERRRESOURCE_TBL_WFLEX
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Create_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type_wflex := G_MISS_TERRRESOURCE_TBL_WFLEX,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type
    )
  IS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Create_TerrResource';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);
      l_Res_Counter                NUMBER;
      l_Res_Access_Counter         NUMBER;
      l_TerrRsc_Tbl                TerrResource_tbl_type;
  --
  BEGIN
      --dbms_output.put_line('Create_TerrResource PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TERRRESOURCE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- Convert incomming data from public to private Tbl format
      convert_terrrsc_wflex (
         p_terrrsc_tbl_wflex => p_terrrsc_tbl,
         x_terrrsc_tbl => l_TerrRsc_Tbl
      );
      --
      -- API body
      --
      create_terrresource (
         p_api_version_number => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_validation_level => fnd_api.g_valid_level_full,
         x_return_status => x_Return_Status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_terrrsc_tbl => l_TerrRsc_Tbl,
         p_terrrsc_access_tbl => p_TerrRsc_Access_Tbl,
         x_terrrsc_out_tbl => x_TerrRsc_Out_Tbl,
         x_terrrsc_access_out_tbl => x_TerrRsc_Access_Out_Tbl
      );


      IF x_Return_Status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_Return_Status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      -- End of API body.
      --
      -- Debug Message
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         fnd_msg_pub.add;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Create_TerrResource PVT: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_TerrResource PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Create_TerrResource PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Create_TerrResource PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Create_TerrResource ' || sqlerrm);
         END IF;
  --
  END Create_TerrResource;

--    start of comments
--    ***************************************************
--    API name  : Create_TerrResource
--    Type      : PUBLIC
--    Function  : To create Territory Resources - which will insert
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Create_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type
    )
  IS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Create_TerrResource';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);
      l_Res_Counter                NUMBER;
      l_Res_Access_Counter         NUMBER;
      l_Res_def_Acc_Counter        NUMBER;
      l_TerrRsc_Tbl                TerrResource_tbl_type;
      l_TerrRsc_Access_Tbl         TerrRsc_Access_tbl_type;
      l_TerrRsc_def_Acc_Tbl        TerrRsc_Access_tbl_type;
      l_TerrRsc_Out_Tbl            TerrResource_out_tbl_type;
      l_TerrRsc_Access_Out_Tbl     TerrRsc_Access_out_tbl_type;
      l_terrRsc_Id                 NUMBER := 0;
      l_index                      NUMBER := 0;
      l_Counter                    NUMBER := 0;
      l_terr_res_access            VARCHAR2 (20) ;
      l_trans_access_code          VARCHAR2 (20);

      CURSOR C_TERR_RES_ACCESS (p_terr_id NUMBER)
      IS
      SELECT NAME
        FROM JTF_TERR_QTYPE_USGS_all jtqu,
             jtf_qual_type_usgs_all jqtu ,
             jtf_qual_types_all jqt
       WHERE jtqu.terr_id = p_terr_id
         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
         AND jqt.qual_type_id = jqtu.qual_type_id;

  --
  BEGIN
      --dbms_output.put_line('Create_TerrResource PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TERRRESOURCE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Territory parameters Access
      -- ******************************************************************

      --mark#2
      If(p_validation_level <> FND_API.G_VALID_LEVEL_NONE) Then
         --dbms_output.put_line('Create_TerrResource PVT: About to call Validate_TerrResource_Data');

         --Validate the incomming data for territory creation
         Validate_TerrResource_Data(p_TerrRsc_Tbl        => p_TerrRsc_Tbl,
                                    p_TerrRsc_Access_Tbl => p_TerrRsc_Access_Tbl,
                                    x_Return_Status      => l_return_status,
                                    x_Msg_Count          => x_Msg_Count,
                                    x_Msg_Data           => x_Msg_Data);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            --dbms_output.put_line('Create_TerrResource PVT: Returned x_return_status <> FND_API.G_RET_STS_SUCCESS');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      End If;
      --
            --
      -- If incomming data is good
      -- Start creating territory related records
      --
      --dbms_output.put_line('Create_TerrResource PVT: Before Calling Create_Terr_Resource PVT');
      --
      For l_Res_Counter IN p_TerrRsc_Tbl.first .. p_TerrRsc_Tbl.count LOOP
          --
          l_TerrRsc_Tbl(1) := p_TerrRsc_Tbl(l_Res_Counter);
          l_TerrRsc_Access_Tbl.Delete;
          l_index := 0;
          --
          --dbms_output.put_line('Inside the for loop');
          --
          IF p_TerrRsc_Access_Tbl.count > 0 THEN
              For l_Res_Access_Counter IN p_TerrRsc_Access_Tbl.first .. p_TerrRsc_Access_Tbl.count LOOP
                  --dbms_output.put_line('Inside Values loop - ' || to_char(l_Res_Access_Counter) );
                  -- If the table index changes, then skip the loop
                  If p_TerrRsc_Access_Tbl(l_Res_Access_Counter).qualifier_tbl_index = l_Res_Counter Then
                     l_index := l_index + 1;
                     --dbms_output.put_line('Found values - ' || to_char(l_Res_Counter) || ' Index - ' || to_char(l_index) );
                     l_TerrRsc_Access_Tbl(l_index) :=  p_TerrRsc_Access_Tbl(l_Res_Access_Counter);
                  End If;
              END LOOP;
          END IF;

          --dbms_output.put_line('Before calling create Territory Resource');
          --
          -- Create the territory qualifier record
          --
          Create_Terr_Resource(P_TerrRsc_Tbl => l_TerrRsc_Tbl,
                               p_api_version_number => p_api_version_number,
                               p_init_msg_list => p_init_msg_list,
                               p_commit => p_commit,
                               p_validation_level => p_validation_level,
                               x_return_status => l_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,
                               X_TerrRsc_Out_Tbl   => l_TerrRsc_Out_Tbl);


          --Save the output status
          x_TerrRsc_Out_Tbl(nvl(x_TerrRsc_Out_Tbl.first, 0)+1)  := l_TerrRsc_Out_Tbl(1);

          -- Save the terr qualifier id
          l_TerrRsc_Id := l_TerrRsc_Out_Tbl(1).TERR_RSC_ID;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             X_Return_Status := l_return_status;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- Add the access types
          -- Get into this loop only if there are access records found
          If l_TerrRsc_Access_Tbl.Count > 0 Then
             --dbms_output.put_line('l_TerrRsc_Access_Tbl.Count > 0. Before calling Create_TerrResc_Access');
             --
             Create_Resource_Access(p_TerrRsc_Id             => l_TerrRsc_Id,
                                    p_TerrRsc_Access_Tbl     => l_TerrRsc_Access_Tbl,
                                    p_api_version_number => p_api_version_number,
                                    p_init_msg_list => p_init_msg_list,
                                    p_commit => p_commit,
                                    p_validation_level => p_validation_level,
                                    x_return_status => l_return_status,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    x_TerrRsc_Access_Out_Tbl => l_TerrRsc_Access_Out_Tbl);
             --
             -- Get the last index used
             l_index := x_TerrRsc_Access_Out_Tbl.Count;
             --
             -- Save the OUT parameters to the original PAI out parametrs
             For l_Counter IN l_TerrRsc_Access_Out_Tbl.first .. l_TerrRsc_Access_Out_Tbl.count LOOP
                 l_index := l_index + 1;
                 x_TerrRsc_Access_Out_Tbl(l_index) := l_TerrRsc_Access_Out_Tbl(l_counter);
             End LOOP;
             --
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                X_Return_Status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             -- Reset the table and records to G_MISS_RECORD and G_MISS_TABLE
             l_TerrRsc_Tbl         := G_MISS_TERRRESOURCE_TBL;
             l_TerrRsc_Access_Tbl  := G_MISS_TERRRSC_ACCESS_TBL;
          ELSE
               -- Get the default trans_access_code for the usage.
               BEGIN
                    SELECT DECODE(source_id, '-1001' , 'FULL_ACCESS' , 'DEFAULT' )
                      INTO l_trans_access_code
                      FROM jtf_terr_usgs_all WHERE terr_id = l_TerrRsc_Tbl(1).terr_id ;
                EXCEPTION
                WHEN OTHERS THEN
                    NULL;
                END;
             -- For Every Resource, create the defualt access as FULL_ACCESS for all
             -- access types.
                BEGIN
                    l_TerrRsc_def_Acc_Tbl.DELETE;
                    l_Res_def_Acc_Counter := 1;
                    OPEN C_TERR_RES_ACCESS (l_TerrRsc_Tbl(1).terr_id);
                    LOOP
                        FETCH C_TERR_RES_ACCESS
                        INTO l_terr_res_access;
                        EXIT WHEN C_TERR_RES_ACCESS%NOTFOUND;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).terr_rsc_access_id := NULL;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).last_update_date :=   l_TerrRsc_Tbl(1).last_update_date;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).last_updated_by :=    l_TerrRsc_Tbl(1).last_updated_by;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).creation_date :=      l_TerrRsc_Tbl(1).creation_date;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).created_by :=         l_TerrRsc_Tbl(1).created_by;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).last_update_login :=  l_TerrRsc_Tbl(1).last_update_login;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).terr_rsc_id :=        l_TerrRsc_Id;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).access_type :=        l_terr_res_access;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).org_id :=             l_TerrRsc_Tbl(1).org_id;
                        l_TerrRsc_def_Acc_Tbl (l_Res_def_Acc_Counter).TRANS_ACCESS_CODE :=  l_trans_access_code;
                        l_Res_def_Acc_Counter := l_Res_def_Acc_Counter + 1 ;
                     END LOOP;
                     CLOSE C_TERR_RES_ACCESS;

                    EXCEPTION
                     WHEN OTHERS THEN
                         CLOSE C_TERR_RES_ACCESS;
                  END;

                   --
                   -- Get into this loop only if there are access records found
                   If l_TerrRsc_def_Acc_Tbl.Count > 0 Then
                     --dbms_output.put_line('l_TerrRsc_Access_Tbl.Count > 0. Before calling Create_TerrResc_Access');
                     --
                       Create_Resource_Access(p_TerrRsc_Id             => l_TerrRsc_Id,
                                              p_TerrRsc_Access_Tbl     => l_TerrRsc_def_Acc_Tbl,
                                              p_api_version_number => p_api_version_number,
                                              p_init_msg_list => p_init_msg_list,
                                              p_commit => p_commit,
                                              p_validation_level => p_validation_level,
                                              x_return_status => l_return_status,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data,
                                              x_TerrRsc_Access_Out_Tbl => l_TerrRsc_Access_Out_Tbl);
                         --
                         -- Get the last index used
                         l_index := x_TerrRsc_Access_Out_Tbl.Count;
                         --
                         -- Save the OUT parameters to the original PAI out parametrs
                         For l_Counter IN l_TerrRsc_Access_Out_Tbl.first .. l_TerrRsc_Access_Out_Tbl.count LOOP
                             l_index := l_index + 1;
                             x_TerrRsc_Access_Out_Tbl(l_index) := l_TerrRsc_Access_Out_Tbl(l_counter);
                         End LOOP;
                         --
                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            X_Return_Status := l_return_status;
                            RAISE FND_API.G_EXC_ERROR;
                         END IF;
                       END IF;
             -- Reset the table and records to G_MISS_RECORD and G_MISS_TABLE
             l_TerrRsc_Tbl         := G_MISS_TERRRESOURCE_TBL;
             l_TerrRsc_Access_Tbl  := G_MISS_TERRRSC_ACCESS_TBL;

          End If;
      --
      End LOOP;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         X_Return_Status := l_return_status;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Create_TerrResource PVT: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_TerrResource PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Create_TerrResource PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Create_TerrResource PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Create_TerrResource ' || sqlerrm);
         END IF;
  --
  END Create_TerrResource;




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Resource
--    Type      : PUBLIC
--    Function  : To delete resources associated with
--                Territories
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_TerrRsc_Id               NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--      p_validation_level         NUMBER                           FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name             Data Type
--      X_Return_Status            VARCHAR2(1)
--      X_Msg_Count                NUMBER
--      X_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict
--
--    End of Comments
--

  PROCEDURE Delete_Terr_Resource
    (
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status           OUT NOCOPY VARCHAR2,
      X_Msg_Count               OUT NOCOPY NUMBER,
      X_Msg_Data                OUT NOCOPY VARCHAR2,
      p_TerrRsc_Id              IN  NUMBER
    )
  AS
      l_Terr_rsc_access_id         NUMBER;


  --Declare cursor to get resource accesses
  Cursor C_GetTerrRscAccess (v_TerrRsc_Id IN NUMBER) IS
          Select  JTRA.TERR_RSC_ACCESS_ID
            From  JTF_TERR_RSC_ACCESS_ALL JTRA
           Where  TERR_RSC_ID = v_TerrRsc_Id;

  l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Terr_Resource';
  l_api_version_number        CONSTANT NUMBER       := 1.0;

  l_return_status             VARCHAR2(1);

  BEGIN
  --
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_TERR_RESOURCE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      OPEN C_GetTerrRscAccess (p_TerrRsc_Id);
      LOOP
      FETCH C_GetTerrRscAccess INTO l_Terr_rsc_access_id;
      EXIT WHEN C_GetTerrRscAccess%NOTFOUND ;

              Delete_TerrRsc_Access(P_Api_Version_Number,
                             P_Init_Msg_List,
                             P_Commit,
                             l_Terr_rsc_access_id,
                             l_Return_Status,
                             X_Msg_Count,
                             X_Msg_Data);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
      --
      END LOOP;

      CLOSE C_GetTerrRscAccess;
      --
      --

      Delete_TerrResource(P_Api_Version_Number,
                          P_Init_Msg_List,
                          P_Commit,
                          p_TerrRsc_Id,
                          l_Return_Status,
                          X_Msg_Count,
                          X_Msg_Data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO DELETE_TERR_RESOURCE_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO DELETE_TERR_RESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
    WHEN NO_DATA_FOUND THEN
         CLOSE C_GetTerrRscAccess;
         x_return_status     := FND_API.G_RET_STS_ERROR ;

    WHEN OTHERS THEN
         ROLLBACK TO DELETE_TERR_RESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
  --
  END Delete_Terr_Resource;




--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_TerrResource
--    Type      : PUBLIC
--    Function  : To Update Territory Resources - which will update
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_Terr_Usgs_Out_Tbl           TerrResource_out_tbl_type
--      x_Terr_QualTypeUsgs_Out_Tbl   TerrRes_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Update_TerrResource
    (
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN    NUMBER                    := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
      x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
      x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type
    )
  AS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Update_TerrResource (Tbl)';
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_return_status             VARCHAR2(1);


  BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TERRRESOURCE_PVT;

      --ARPATEL: bug#2849410
    /* Check_for_duplicate (p_TerrRsc_Tbl         => p_TerrRsc_Tbl,
                          x_Return_Status       => l_return_status,
                          x_msg_count           => x_msg_count,
                          x_Msg_Data            => x_Msg_Data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;
    */
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
          fnd_message.set_name ('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;


      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      If P_TerrRsc_Tbl.Count > 0 Then
         --
         Update_Terr_Resource(P_TerrRsc_Tbl          => P_TerrRsc_Tbl,
                              p_api_version_number => p_api_version_number,
                              p_init_msg_list => p_init_msg_list,
                              p_commit => p_commit,
                              p_validation_level => p_validation_level,
                              x_return_status => l_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              X_TerrRsc_Out_Tbl      => X_TerrRsc_Out_Tbl);


         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
      End If;
      --
      If p_TerrRsc_Access_Tbl.Count > 0 Then
      --
         Update_Resource_Access(p_TerrRsc_Access_Tbl     => p_TerrRsc_Access_Tbl,
                                p_api_version_number => p_api_version_number,
                                p_init_msg_list => p_init_msg_list,
                                p_commit => p_commit,
                                p_validation_level => p_validation_level,
                                x_return_status => l_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                X_TerrRsc_Access_Out_Tbl => x_TerrRsc_Access_Out_Tbl);
         --
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      --
      End If;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
  --
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO UPDATE_TERRRESOURCE_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO UPDATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         ROLLBACK TO UPDATE_TERRRESOURCE_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
  --
  END Update_TerrResource;

---------------------------------------------------------------------
--             Validate Resource
---------------------------------------------------------------------
PROCEDURE Validate_Resource
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Rec                 IN  TerrResource_Rec_type
    )
  AS
      l_temp                        VARCHAR2(3);
      l_rsc_lov_sql                 VARCHAR2(30000);
      l_rsc_validate_sql            VARCHAR2(30000);

BEGIN
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT JSA.RSC_LOV_SQL
    INTO  l_rsc_lov_sql
    FROM  JTF_TERR_ALL JTA,
          JTF_TERR_USGS_ALL JTU,
          JTF_SOURCES_ALL JSA
    WHERE JTA.TERR_ID =  P_TerrRsc_Rec.Terr_Id
      AND JTA.TERR_ID = JTU.TERR_ID
      AND JTU.SOURCE_ID = JSA.SOURCE_ID;

    l_rsc_validate_sql :=  'SELECT ''X'' FROM ( ' || l_rsc_lov_sql || ' ) ' ;
    l_rsc_validate_sql := l_rsc_validate_sql || 'WHERE RESOURCE_ID = ' || P_TerrRsc_Rec.Resource_Id  ;
    l_rsc_validate_sql := l_rsc_validate_sql || ' AND DB_RSC_TYPE = ''' || P_TerrRsc_Rec.Resource_TYPE || '''';

    IF (( P_TerrRsc_Rec.GROUP_ID IS NULL ) OR (P_TerrRsc_Rec.GROUP_ID = FND_API.G_MISS_NUM ) ) THEN
        l_rsc_validate_sql := l_rsc_validate_sql || ' AND GROUP_ID IS NULL ' ;
    ELSE
        l_rsc_validate_sql := l_rsc_validate_sql || ' AND GROUP_ID = ' ||  P_TerrRsc_Rec.GROUP_ID ;
    END IF;

    IF (( P_TerrRsc_Rec.ROLE IS NULL ) OR (P_TerrRsc_Rec.ROLE = FND_API.G_MISS_CHAR ) ) THEN
        l_rsc_validate_sql := l_rsc_validate_sql ||' AND ROLE_CODE IS NULL ' ;
    ELSE
        l_rsc_validate_sql := l_rsc_validate_sql ||' AND ROLE_CODE = ''' || P_TerrRsc_Rec.ROLE || '''';
    END IF;

    l_rsc_validate_sql := l_rsc_validate_sql ||'AND ROWNUM <= 1 ';

    BEGIN
        EXECUTE IMMEDIATE l_rsc_validate_sql INTO l_temp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            fnd_message.set_name('JTF', 'JTY_TERR_INVALID_RESOURCE');
            FND_MSG_PUB.ADD;
    END;
    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'NO_DATA_FOUND Exception in Validate_Resource ' || SQLERRM
             );
         END IF;
    WHEN OTHERS THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Resource ' || SQLERRM
             );
         END IF;
  --
END Validate_Resource;
-- Validate the resource while updating the resource details.
PROCEDURE Validate_Resource_update
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Rec                 IN  TerrResource_Rec_type
    )
  AS
      l_temp                        VARCHAR2(3);
      l_rsc_lov_sql                 VARCHAR2(30000);
      l_rsc_validate_sql            VARCHAR2(30000);
      l_resource_id                   NUMBER;
      l_group_id                      NUMBER;
      l_role                          VARCHAR2(300);
      l_resource_type                 VARCHAR2(100);

BEGIN
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        SELECT JSA.RSC_LOV_SQL
        INTO  l_rsc_lov_sql
        FROM  JTF_TERR_ALL JTA,
              JTF_TERR_RSC_ALL JTR,
              JTF_TERR_USGS_ALL JTU,
              JTF_SOURCES_ALL JSA
        WHERE JTR.terr_rsc_id = P_TerrRsc_Rec.Terr_Rsc_Id
          AND JTR.TERR_ID =  JTA.Terr_Id
          AND JTA.TERR_ID = JTU.TERR_ID
          AND JTU.SOURCE_ID = JSA.SOURCE_ID;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'NO_DATA_FOUND Exception in Validate_Resource_update procedure : ' || SQLERRM);
        END IF;
   END;

   --Get the missing values from the database to Valiadte the resource.
   BEGIN
       SELECT resource_id,   group_id,   role,   resource_type
       INTO   l_resource_id, l_group_id, l_role, l_resource_type
       FROM JTF_TERR_RSC_ALL
       WHERE TERR_RSC_ID = P_TerrRsc_Rec.Terr_Rsc_Id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'NO_DATA_FOUND Exception in Validate_Resource_update procedure : ' || SQLERRM);
        END IF;
   END;

    IF P_TerrRsc_Rec.Resource_Id <> FND_API.G_MISS_NUM  THEN
        l_resource_id := P_TerrRsc_Rec.Resource_Id;
    END IF;

    IF P_TerrRsc_Rec.Resource_Type <> FND_API.G_MISS_CHAR THEN
        l_resource_type := P_TerrRsc_Rec.Resource_Type;
    END IF;

    IF P_TerrRsc_Rec.GROUP_ID <> FND_API.G_MISS_NUM  THEN
        l_group_id := P_TerrRsc_Rec.GROUP_ID;
    END IF;

    IF P_TerrRsc_Rec.ROLE <> FND_API.G_MISS_CHAR THEN
        l_role := P_TerrRsc_Rec.ROLE;
    END IF;

    l_rsc_validate_sql :=  'SELECT ''X'' FROM ( ' || l_rsc_lov_sql || ' ) ' ;
    l_rsc_validate_sql := l_rsc_validate_sql || 'WHERE RESOURCE_ID = ' || l_resource_id ;
    l_rsc_validate_sql := l_rsc_validate_sql || ' AND DB_RSC_TYPE = ''' || l_resource_type || '''';

    IF l_group_id IS NULL THEN
        l_rsc_validate_sql := l_rsc_validate_sql || ' AND GROUP_ID IS NULL ' ;
    ELSE
        l_rsc_validate_sql := l_rsc_validate_sql || ' AND GROUP_ID = ' ||  l_group_id ;
    END IF;

    IF l_role IS NULL THEN
        l_rsc_validate_sql := l_rsc_validate_sql ||' AND ROLE_CODE IS NULL ' ;
    ELSE
        l_rsc_validate_sql := l_rsc_validate_sql ||' AND ROLE_CODE = ''' || l_role || '''';
    END IF;

    l_rsc_validate_sql := l_rsc_validate_sql ||'AND ROWNUM <= 1 ';

    BEGIN
        EXECUTE IMMEDIATE l_rsc_validate_sql INTO l_temp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            fnd_message.set_name('JTF', 'JTY_TERR_INVALID_RESOURCE');
            FND_MSG_PUB.ADD;
    END;
    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'NO_DATA_FOUND Exception in Validate_Resource_update ' || SQLERRM
             );
         END IF;
    WHEN OTHERS THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Resource_update ' || SQLERRM
             );
         END IF;
  --
END Validate_Resource_update;


--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories resource
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Rec                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Rec             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Create_Terr_Resource
    (
      P_TerrRsc_Rec        IN  TerrResource_Rec_type,
      p_Api_Version_Number IN  NUMBER,
      p_Init_Msg_List      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit             IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level   IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status      OUT NOCOPY VARCHAR2,
      x_Msg_Count          OUT NOCOPY NUMBER,
      x_Msg_Data           OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Rec    OUT NOCOPY TerrResource_out_Rec_type
    )
  AS
    l_rowid                      ROWID;
    l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Terr_Resource';
    L_TerrRsc_Id                 NUMBER := P_TERRRSC_REC.TERR_RSC_ID;
    l_return_status              VARCHAR2(1);

BEGIN
   --dbms_output.put_line('Create_Terr_Resource REC: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
   THEN

       -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Rsc');
           FND_MSG_PUB.Add;
        END IF;
        --
        -- Invoke validation procedures
        Validate_Terr_Rsc(p_init_msg_list    => FND_API.G_FALSE,
                          x_Return_Status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data,
                          P_TerrRsc_Rec      => P_TerrRsc_Rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
   END IF;

   Validate_Resource(p_init_msg_list    => FND_API.G_FALSE,
                     x_Return_Status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     P_TerrRsc_Rec      => P_TerrRsc_Rec);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    Check_for_duplicate2 (P_TerrRsc_Rec         => P_TerrRsc_Rec,
                          x_Return_Status       => l_return_status,
                          x_msg_count           => x_msg_count,
                          x_Msg_Data            => x_Msg_Data);

    IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise used passed in value
      */
      IF (l_TerrRsc_id = FND_API.G_MISS_NUM) THEN
          l_TerrRsc_id := NULL;
      END IF;

   --dbms_output.put_line('Create_Terr_Resource REC: Before Calling JTF_TERR_RSC_PKG.Insert_Row');
   JTF_TERR_RSC_PKG.Insert_Row(x_Rowid                          => l_rowid,
                               x_TERR_RSC_ID                    => l_TerrRsc_Id,
                               x_LAST_UPDATE_DATE               => P_TerrRsc_Rec.LAST_UPDATE_DATE,
                               x_LAST_UPDATED_BY                => P_TerrRsc_Rec.LAST_UPDATED_BY,
                               x_CREATION_DATE                  => P_TerrRsc_Rec.CREATION_DATE,
                               x_CREATED_BY                     => P_TerrRsc_Rec.CREATED_BY,
                               x_LAST_UPDATE_LOGIN              => P_TerrRsc_Rec.LAST_UPDATE_LOGIN,
                               x_TERR_ID                        => P_TerrRsc_Rec.TERR_ID,
                               x_RESOURCE_ID                    => P_TerrRsc_Rec.RESOURCE_ID,
                               x_GROUP_ID                       => P_TerrRsc_Rec.GROUP_ID,
                               x_RESOURCE_TYPE                  => P_TerrRsc_Rec.RESOURCE_TYPE,
                               x_ROLE                           => P_TerrRsc_Rec.ROLE,
                               x_PRIMARY_CONTACT_FLAG           => P_TerrRsc_Rec.PRIMARY_CONTACT_FLAG,
                               X_START_DATE_ACTIVE              => P_TerrRsc_Rec.START_DATE_ACTIVE,
                               X_END_DATE_ACTIVE                => P_TerrRsc_Rec.END_DATE_ACTIVE,
                               X_FULL_ACCESS_FLAG               => P_TerrRsc_Rec.FULL_ACCESS_FLAG,
                               X_ORG_ID                         => P_TerrRsc_Rec.ORG_ID,
                               X_ATTRIBUTE_CATEGORY             => P_TerrRsc_Rec.ATTRIBUTE_CATEGORY,
                               X_ATTRIBUTE1                     => P_TerrRsc_Rec.ATTRIBUTE1,
                               X_ATTRIBUTE2                     => P_TerrRsc_Rec.ATTRIBUTE2,
                               X_ATTRIBUTE3                     => P_TerrRsc_Rec.ATTRIBUTE3,
                               X_ATTRIBUTE4                     => P_TerrRsc_Rec.ATTRIBUTE4,
                               X_ATTRIBUTE5                     => P_TerrRsc_Rec.ATTRIBUTE5,
                               X_ATTRIBUTE6                     => P_TerrRsc_Rec.ATTRIBUTE6,
                               X_ATTRIBUTE7                     => P_TerrRsc_Rec.ATTRIBUTE7,
                               X_ATTRIBUTE8                     => P_TerrRsc_Rec.ATTRIBUTE8,
                               X_ATTRIBUTE9                     => P_TerrRsc_Rec.ATTRIBUTE9,
                               X_ATTRIBUTE10                    => P_TerrRsc_Rec.ATTRIBUTE10,
                               X_ATTRIBUTE11                    => P_TerrRsc_Rec.ATTRIBUTE11,
                               X_ATTRIBUTE12                    => P_TerrRsc_Rec.ATTRIBUTE12,
                               X_ATTRIBUTE13                    => P_TerrRsc_Rec.ATTRIBUTE13,
                               X_ATTRIBUTE14                    => P_TerrRsc_Rec.ATTRIBUTE14,
                               X_ATTRIBUTE15                    => P_TerrRsc_Rec.ATTRIBUTE15 );

   --dbms_output.put_line('After calling JTF_TERR_RSC_PKG.Insert_Row');
   -- Save the terr_usg_id and
   X_TerrRsc_Out_Rec.TERR_RSC_ID := l_TerrRsc_Id;

   -- If successful then save the success status for the record
   X_TerrRsc_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

   --dbms_output.put_line('Create_Terr_Resource REC: Exiting API');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_Terr_Resource: FND_API.G_EXC_ERROR');

         X_TerrRsc_Out_Rec.TERR_RSC_ID   := NULL;
         X_TerrRsc_Out_Rec.return_status := x_return_status;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

   WHEN OTHERS THEN
        --dbms_output.put_line('Create_Terr_Resource REC: OTHERS - ' || SQLERRM);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        X_TerrRsc_Out_Rec.TERR_RSC_ID  := NULL;
        X_TerrRsc_Out_Rec.return_status := x_return_status;
        --
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Terr_Resource ' || SQLERRM);
        END IF;
--
End Create_Terr_Resource;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories qualifier
--
--    Pre-reqs  :
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Tbl                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Tbl             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--

  PROCEDURE Create_Terr_Resource
    (
      P_TerrRsc_Tbl        IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
      p_Api_Version_Number IN  NUMBER,
      p_Init_Msg_List      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit             IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level   IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status      OUT NOCOPY VARCHAR2,
      x_Msg_Count          OUT NOCOPY NUMBER,
      x_Msg_Data           OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Tbl    OUT NOCOPY TerrResource_out_tbl_type
    )
  AS
    l_return_Status               VARCHAR2(1);

    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Resource_Access (Tbl)';
    l_TerrRsc_Tbl_Count           NUMBER                := P_TerrRsc_Tbl.Count;
    l_TerrRsc_out_Tbl_Count       NUMBER;
    l_TerrRsc_Out_Tbl             TerrResource_out_tbl_type;
    l_TerrRsc_Out_Rec             TerrResource_out_Rec_type;

    l_Counter                     NUMBER;

BEGIN
   --dbms_output.put_line('Create_Terr_Resource TBL: Entering API');

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_TerrRsc_Tbl_Count LOOP
   --
       --dbms_output.put_line('Create_Terr_Resource TBL: Before Calling Create_Terr_Resource PVT');
   --
       Create_Terr_Resource(P_TerrRsc_Rec =>  P_TerrRsc_Tbl(l_counter),
                            p_api_version_number => p_api_version_number,
                            p_init_msg_list => p_init_msg_list,
                            p_commit => p_commit,
                            p_validation_level => p_validation_level,
                            x_return_status => l_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            X_TerrRsc_Out_Rec             =>  l_TerrRsc_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --dbms_output.put_line('Create_Terr_Resource TBL: l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR');

           -- Save the terr_usg_id and
           X_TerrRsc_Out_Tbl(l_counter).TERR_RSC_ID  := NULL;

           -- If save the ERROR status for the record
           X_TerrRsc_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output.put_line('Create_Terr_Resource TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');

           -- Save the terr_usg_id and
           X_TerrRsc_Out_Tbl(l_counter).TERR_RSC_ID   := l_TerrRsc_Out_Rec.TERR_RSC_ID;

           -- If successful then save the success status for the record
           X_TerrRsc_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   --Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_TerrRsc_Out_Tbl_Count    := X_TerrRsc_Out_Tbl.Count;

   FOR l_Counter IN 1 ..  l_TerrRsc_Out_Tbl_Count  LOOP
       If x_TerrRsc_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          x_TerrRsc_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;
   --dbms_output.put_line('Create_Terr_Resource TBL: Exiting API');
--
End Create_Terr_Resource;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Resource _Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_REC
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--
  PROCEDURE Create_Resource_Access
    (
      p_TerrRsc_Id                  NUMBER,
      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type         := G_MISS_TERRRSC_ACCESS_REC,
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Rec      OUT NOCOPY TerrRsc_Access_out_rec_type
    )
  AS
    l_rowid                       ROWID;
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Resource_Access';
    l_terrRsc_Access_id           NUMBER := P_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID;

BEGIN
   --dbms_output.put_line('Create_Resource _Access REC: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
   THEN
        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Rsc_Access');
           FND_MSG_PUB.Add;
        END IF;
         --Check created by
        IF ( p_TerrRsc_Access_Rec.CREATED_BY is NULL OR
             p_TerrRsc_Access_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
                FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;

        --Check creation date
        If ( p_TerrRsc_Access_Rec.CREATION_DATE is NULL OR
             p_TerrRsc_Access_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
        --
        --Check ACCESS_TYPE
        IF ( p_TerrRsc_Access_Rec.ACCESS_TYPE is NULL OR
             p_TerrRsc_Access_Rec.ACCESS_TYPE = FND_API.G_MISS_CHAR )  THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'ACCESS_TYPE' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
        --
        --Check TRANS_ACCESS_CODE
        IF ( p_TerrRsc_Access_Rec.TRANS_ACCESS_CODE is NULL OR
             p_TerrRsc_Access_Rec.TRANS_ACCESS_CODE = FND_API.G_MISS_CHAR )  THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'TRANS_ACCESS_CODE' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
        --
        --
        -- Invoke validation procedures
        Validate_Terr_Rsc_Access(p_init_msg_list      => FND_API.G_FALSE,
                                 x_Return_Status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_TerrRsc_Id         => p_TerrRsc_Id,
                                 p_TerrRsc_Access_Rec => P_TerrRsc_Access_Rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
   END IF;

   -- jdochert 09/09
   -- check for Unique Key constraint violation
   validate_terr_rsc_access_UK(
               p_Terr_Rsc_Id     => p_terrrsc_id,
               p_Access_Type     => p_TerrRsc_access_rec.access_type,
               p_init_msg_list   => FND_API.G_FALSE,
               x_Return_Status   => x_return_status,
               x_msg_count       => x_msg_count,
               x_msg_data        => x_msg_data );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Call insert Terr_Resource_Access table handler
   --
      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise used passed in value
      */
      IF (l_TerrRsc_Access_id = FND_API.G_MISS_NUM) THEN
          l_TerrRsc_Access_id := NULL;
      END IF;

   --dbms_output.put_line('Create_Resource _Access REC: Calling JTF_TERR_RSC_ACCESS_PKG.Insert_Row');
   JTF_TERR_RSC_ACCESS_PKG.Insert_Row(x_Rowid                => l_rowid,
                                      x_TERR_RSC_ACCESS_ID   => l_terrRsc_Access_id,
                                      x_LAST_UPDATE_DATE     => P_TerrRsc_Access_Rec.LAST_UPDATE_DATE,
                                      x_LAST_UPDATED_BY      => P_TerrRsc_Access_Rec.LAST_UPDATED_BY,
                                      x_CREATION_DATE        => P_TerrRsc_Access_Rec.CREATION_DATE,
                                      x_CREATED_BY           => P_TerrRsc_Access_Rec.CREATED_BY,
                                      x_LAST_UPDATE_LOGIN    => P_TerrRsc_Access_Rec.LAST_UPDATE_LOGIN,
                                      x_TERR_RSC_ID          => p_TerrRsc_Id,
                                      x_ACCESS_TYPE          => P_TerrRsc_Access_Rec.ACCESS_TYPE,
                                      x_TRANS_ACCESS_CODE    => P_TerrRsc_Access_Rec.TRANS_ACCESS_CODE,
                                      X_ORG_ID               => P_TerrRsc_Access_Rec.ORG_ID  );

  -- Save the terr_usg_id and
   X_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID := l_terrRsc_Access_id;

   -- If successful then save the success status for the record
   X_TerrRsc_Access_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

   --dbms_output.put_line('Create_Resource _Access REC: Exiting API');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Create_Resource_Access: FND_API.G_EXC_ERROR');

         x_return_status := FND_API.G_RET_STS_ERROR ;
         X_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID  := NULL;
         X_TerrRsc_Access_Out_Rec.return_status       := x_return_status;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

   WHEN OTHERS THEN
        --dbms_output.put_line('Others exception in Create_Resource_Access' || SQLERRM);
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        X_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID  := NULL;
        X_TerrRsc_Access_Out_Rec.return_status       := x_return_status;
        --
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Resource _Access');
        END IF;
--
End Create_Resource_Access;




--
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Resource _Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--    End of Comments
--

  PROCEDURE Create_Resource_Access
    (
      p_TerrRsc_Id                  NUMBER,
      P_TerrRsc_Access_Tbl          TerrRsc_Access_Tbl_type   := G_MISS_TERRRSC_ACCESS_TBL,
      p_Api_Version_Number          IN  NUMBER,
      p_Init_Msg_List               IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                      IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_Msg_Count                   OUT NOCOPY NUMBER,
      x_Msg_Data                    OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_Tbl_type
    )
  AS
    l_terr_value_id               NUMBER;

    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Resource_Access (Tbl)';
    l_return_Status               VARCHAR2(1);
    l_TerrRsc_Access_Tbl_Count    NUMBER                := P_TerrRsc_Access_Tbl.Count;

    l_TerrRscAcc_Out_Tbl_Count    NUMBER;
    l_TerrRsc_Access_Out_Tbl      TerrRsc_Access_out_Tbl_type;
    l_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_Rec_type;

    l_Counter                     NUMBER := 0;

BEGIN
   --dbms_output.put_line('Create_Resource_Access TBL: Entering API - ' || to_char(l_TerrRsc_Access_Tbl_Count));

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;


   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_TerrRsc_Access_Tbl_Count LOOP
   --
       --dbms_output.put_line('Inside Create_Resource_Access - ' || to_char(P_TerrRsc_Access_Tbl(l_counter).QUALIFIER_TBL_INDEX) );
       Create_Resource_Access(P_TerrRsc_Id   =>  p_TerrRsc_Id,
                              P_TerrRsc_Access_Rec =>  P_TerrRsc_Access_Tbl(l_counter),
                              p_api_version_number => p_api_version_number,
                              p_init_msg_list => p_init_msg_list,
                              p_commit => p_commit,
                              p_validation_level => p_validation_level,
                              x_return_status => l_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              x_TerrRsc_Access_Out_Rec =>  l_TerrRsc_Access_Out_Rec);
       --
       --If there is a major error
       IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output.put_line('Create_Resource _Access REC: l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR');
           -- Save the terr_usg_id and
           X_TerrRsc_Access_Out_Tbl(l_counter).TERR_RSC_ACCESS_ID  := NULL;
           -- If save the ERROR status for the record
           X_TerrRsc_Access_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output.put_line('Create_Resource _Access REC: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_TerrRsc_Access_Out_Tbl(l_counter).TERR_RSC_ACCESS_ID := l_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID;

           -- If successful then save the success status for the record
           X_TerrRsc_Access_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   --Get the API overall return status
   --Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_TerrRscAcc_Out_Tbl_Count   := X_TerrRsc_Access_Out_Tbl.Count;

   FOR l_Counter IN 1 ..  l_TerrRscAcc_Out_Tbl_Count  LOOP
       If x_TerrRsc_Access_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          x_TerrRsc_Access_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
       fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
       fnd_message.set_name ('PROC_NAME', l_api_name);
       FND_MSG_PUB.Add;
   END IF;

--
End Create_Resource_Access;




--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrRsc_Access
--   Type    :  PRIVATE
--   Pre-Req :
--   Parameters:
--    IN
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        IN   NUMBER,
--     P_Init_Msg_List             IN   VARCHAR2     := FND_API.G_FALSE
--     P_Commit                    IN   VARCHAR2     := FND_API.G_FALSE
--     P_TerrRsc_Id                IN   NUMBER
--
--     Optional:
--
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--

  PROCEDURE  Delete_TerrRsc_Access
    (
      P_Api_Version_Number         IN   NUMBER,
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_TerrRsc_Access_Id          IN   NUMBER,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  VARCHAR2,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
  AS
      l_row_count                  NUMBER;
      l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_TerrRsc_Access';
      l_api_version_number         CONSTANT NUMBER   := 1.0;
      l_return_status              VARCHAR2(1);

BEGIN
   -- Standard start of PAI savepoint
   SAVEPOINT  DELETE_TERRRSC_ACCESS_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'Delete TerrRscAccess : Start');
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   JTF_TERR_RSC_ACCESS_PKG.Delete_Row(x_TERR_RSC_ACCESS_ID  => P_TerrRsc_Access_Id );
      --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','TERR_RSCACCESSES_DELETED');

   IF SQL%FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;

   --Prepare message token
   FND_MESSAGE.SET_NAME('ITEMS_DELETED', l_row_count);
   --Add message to API message list
   FND_MSG_PUB.ADD();

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'Delete TerrRscAccess: End');
      FND_MSG_PUB.Add;
   END IF;


   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   --
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;
          --Prepare message token
          FND_MESSAGE.SET_NAME('ITEMS_DELETED', l_row_count);
          --Add message to API message list
          FND_MSG_PUB.ADD();
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO  DELETE_TERRRSC_ACCESS_PVT;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          ROLLBACK TO  DELETE_TERRRSC_ACCESS_PVT;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_TerrRsc_Access');
          END IF;
END Delete_TerrRsc_Access;




--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrResource
--   Type    :  PRIVATE
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        IN   NUMBER,
--     P_Init_Msg_List             IN   VARCHAR2     := FND_API.G_FALSE
--     P_Commit                    IN   VARCHAR2     := FND_API.G_FALSE
--     P_TerrRsc_Id                IN   NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--

  PROCEDURE Delete_TerrResource
    (
      P_Api_Version_Number         IN   NUMBER,
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_TerrRsc_Id                 IN   NUMBER,
      X_Return_Status              OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  OUT NOCOPY  VARCHAR2,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
  AS
      l_row_count                  NUMBER;
      l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_TerrResource';
      l_api_version_number         CONSTANT NUMBER   := 1.0;
      l_return_status              VARCHAR2(1);

BEGIN
   -- Standard start of PAI savepoint
   SAVEPOINT  DELETE_TERRRSC_PVT;

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
      fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
      fnd_message.set_name ('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   JTF_TERR_RSC_PKG.Delete_Row(x_TERR_RSC_ID   => P_TerrRsc_Id);
   --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','TERR_RESOURCE_DELETED');

   IF SQL%FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;

   --Prepare message token
   FND_MESSAGE.SET_TOKEN('ITEMS_DELETED', l_row_count);

   --Add message to API message list
   FND_MSG_PUB.ADD();

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      fnd_message.set_name ('JTF', 'JTF_TERR_END_MSG');
      fnd_message.set_name ('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;


   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   --
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          ROLLBACK TO  DELETE_TERRRSC_PVT;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;

          --Prepare message token
          FND_MESSAGE.SET_NAME('ITEMS_DELETED', l_row_count);

          --Add message to API message list
          FND_MSG_PUB.ADD();
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO  DELETE_TERRRSC_PVT;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          ROLLBACK TO  DELETE_TERRRSC_PVT;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_Territory_Resource');
          END IF;
--
End Delete_TerrResource;
--


---------------------------------------------------------------------
--             Validate Territory Resource
---------------------------------------------------------------------
-- Columns Validated
--         Make sure the Territory Id is valid
---------------------------------------------------------------------

  PROCEDURE Validate_Terr_Rsc_update
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Rec                 IN  TerrResource_Rec_type
    )
  AS
      l_Validate_id                 NUMBER;
      l_dummy                       NUMBER;
      l_res_start_date_active       DATE;
      l_res_end_date_active         DATE;
      l_terr_start_date             DATE;
      l_terr_end_date               DATE;
      l_terr_id                     NUMBER;
BEGIN
    --dbms_output.put_line('Inside Validate_Terr_Rsc: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the territory Id
    l_Validate_id := p_TerrRsc_Rec.Terr_Id;
    If l_Validate_id <> FND_API.G_MISS_NUM Then
       -- --dbms_output.put_line('Validate_Terr_Qtype_Usage: TERR_ID(' || to_char(l_Validate_id) || ')');
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
          --dbms_output.put_line('Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR');
             FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
    End If;

    --Get the missing values from the database to check with the territory dates.
    BEGIN
       SELECT terr_id, start_date_active, nvl(end_date_active,to_date('31/12/4712','DD/MM/RRRR')) end_date_active
       INTO l_terr_id, l_res_start_date_active, l_res_end_date_active
       FROM JTF_TERR_RSC_ALL
       WHERE TERR_RSC_ID = P_TerrRsc_Rec.Terr_Rsc_Id;

       IF ( P_TerrRsc_Rec.START_DATE_ACTIVE IS NOT NULL AND P_TerrRsc_Rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
          l_res_start_date_active :=   P_TerrRsc_Rec.START_DATE_ACTIVE;
       END IF;
       -- Else use the date from Database

       IF ( P_TerrRsc_Rec.END_DATE_ACTIVE IS NOT NULL AND P_TerrRsc_Rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
          l_res_end_date_active :=   P_TerrRsc_Rec.END_DATE_ACTIVE;
       END IF;

       -- Else use the date from Database
       IF ( P_TerrRsc_Rec.TERR_ID IS NOT NULL AND P_TerrRsc_Rec.TERR_ID <> FND_API.G_MISS_NUM ) THEN
          l_Terr_Id :=   P_TerrRsc_Rec.TERR_ID;
       END IF;
       -- Else use the date from Database

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
                X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'NO_DATA_FOUND Exception in Validate_Terr_Rsc ' || SQLERRM);
                END IF;
      WHEN OTHERS THEN
                X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'Other Exception in Validate_Terr_Rsc ' || SQLERRM);
                END IF;
    END;

    IF (l_res_start_date_active IS NOT NULL  ) AND (l_res_end_date_active IS NOT NULL ) THEN
        IF ( l_res_start_date_active > l_res_end_date_active ) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_INV_DATE_RANGE');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END IF;

        -- Resource start and end active dates should fall in territory dates.
        BEGIN

             SELECT jta.start_date_active,jta.end_date_active
               INTO l_terr_start_date,l_terr_end_date
               FROM jtf_terr_all jta
              WHERE jta.terr_id = l_terr_id ;

             -- Validate start date .
             IF ( l_res_start_date_active < l_terr_start_date ) OR ( l_res_start_date_active > l_terr_end_date ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_STARTDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
             END IF;

             -- Validate end date.
             IF ( l_res_end_date_active < l_terr_start_date ) OR ( l_res_end_date_active > l_terr_end_date ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_ENDDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
             END IF;

        EXCEPTION
           WHEN OTHERS THEN
                X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'Others Exception in Validate_Terr_Rsc_update ' || SQLERRM);
                END IF;
        END;

    END IF;

    -- Validate last updated by
    IF  ( p_TerrRsc_Rec.LAST_UPDATED_BY is NULL OR
          p_TerrRsc_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_TerrRsc_Rec.LAST_UPDATE_DATE IS NULL OR
         p_TerrRsc_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_TerrRsc_Rec.LAST_UPDATE_LOGIN  is NULL OR
         p_TerrRsc_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Terr_Rsc_update ' || SQLERRM
             );
         END IF;
  --
  END Validate_Terr_Rsc_update;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Resource
--    Type      : PRIVATE
--    Function  : To update Territories resource
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Rec                 TerrResource_tbl_type
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Rec             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

PROCEDURE Update_Terr_Resource (
   P_TerrRsc_Rec         IN  TerrResource_Rec_type,
   p_Api_Version_Number  IN  NUMBER,
   p_Init_Msg_List       IN  VARCHAR2              := FND_API.G_FALSE,
   p_Commit              IN  VARCHAR2              := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
   x_Return_Status       OUT NOCOPY VARCHAR2,
   x_Msg_Count           OUT NOCOPY NUMBER,
   x_Msg_Data            OUT NOCOPY VARCHAR2,
   x_TerrRsc_Out_Rec     OUT NOCOPY TerrResource_out_Rec_type) AS

   Cursor C_GetTerrResource(l_TerrRsc_id Number) IS
   Select Rowid, TERR_RSC_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
          LAST_UPDATE_LOGIN, TERR_ID, RESOURCE_ID, RESOURCE_TYPE, ROLE, PRIMARY_CONTACT_FLAG, ORG_ID
   From   jtf_terr_rsc_ALL
   Where  TERR_RSC_ID = l_TerrRsc_id
   FOR    Update NOWAIT;

   --Local variable declaration
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Terr_Resource';
   l_rowid                   VARCHAR2(50);
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_return_status           VARCHAR2(1);
   l_ref_TerrRsc_Rec         TerrResource_Rec_type;

BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for TERR_RSC_ID
    OPEN C_GetTerrResource( P_TerrRsc_Rec.TERR_RSC_ID);
    Fetch C_GetTerrResource into l_Rowid, l_ref_TerrRsc_Rec.TERR_RSC_ID, l_ref_TerrRsc_Rec.LAST_UPDATE_DATE,
          l_ref_TerrRsc_Rec.LAST_UPDATED_BY, l_ref_TerrRsc_Rec.CREATION_DATE, l_ref_TerrRsc_Rec.CREATED_BY,
          l_ref_TerrRsc_Rec.LAST_UPDATE_LOGIN, l_ref_TerrRsc_Rec.TERR_ID, l_ref_TerrRsc_Rec.RESOURCE_ID,
          l_ref_TerrRsc_Rec.RESOURCE_TYPE, l_ref_TerrRsc_Rec.ROLE, l_ref_TerrRsc_Rec.PRIMARY_CONTACT_FLAG,
          l_ref_TerrRsc_Rec.ORG_ID;

   If (C_GetTerrResource%NOTFOUND) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
         FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_RSC');
         FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_TerrRsc_Rec.TERR_RSC_ID));
         FND_MSG_PUB.Add;
      END IF;
      raise FND_API.G_EXC_ERROR;
   End if;
   CLOSE C_GetTerrResource;

   --Validate the incomming record
   IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Rsc');
         FND_MSG_PUB.Add;
      END IF;

      -- Invoke validation procedures
      Validate_Terr_Rsc_update(p_init_msg_list      => FND_API.G_FALSE,
                        x_Return_Status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_TerrRsc_Rec        => P_TerrRsc_Rec);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Check if the resource exist or not.
   Validate_Resource_update(P_TerrRsc_Rec        => P_TerrRsc_Rec,
                                x_Return_Status       => l_return_status,
                                x_msg_count           => x_msg_count,
                                x_Msg_Data            => x_Msg_Data);

   IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for duplicates.
   Check_for_duplicate2_updates(P_TerrRsc_Rec        => P_TerrRsc_Rec,
                                x_Return_Status       => l_return_status,
                                x_msg_count           => x_msg_count,
                                x_Msg_Data            => x_Msg_Data);

   IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   JTF_TERR_RSC_PKG.Update_Row(x_Rowid                          => l_rowid,
                               x_TERR_RSC_ID                    => P_TerrRsc_Rec.Terr_Rsc_Id,
                               x_LAST_UPDATE_DATE               => P_TerrRsc_Rec.LAST_UPDATE_DATE,
                               x_LAST_UPDATED_BY                => P_TerrRsc_Rec.LAST_UPDATED_BY ,
                               x_CREATION_DATE                  => P_TerrRsc_Rec.CREATION_DATE,
                               x_CREATED_BY                     => P_TerrRsc_Rec.CREATED_BY,
                               x_LAST_UPDATE_LOGIN              => P_TerrRsc_Rec.LAST_UPDATE_LOGIN ,
                               x_TERR_ID                        => P_TerrRsc_Rec.TERR_ID,
                               x_RESOURCE_ID                    => P_TerrRsc_Rec.RESOURCE_ID,
                               x_GROUP_ID                       => P_TerrRsc_Rec.GROUP_ID,
                               x_RESOURCE_TYPE                  => P_TerrRsc_Rec.RESOURCE_TYPE,
                               x_ROLE                           => P_TerrRsc_Rec.ROLE,
                               x_PRIMARY_CONTACT_FLAG           => P_TerrRsc_Rec.PRIMARY_CONTACT_FLAG,
                               X_START_DATE_ACTIVE              => P_TerrRsc_Rec.START_DATE_ACTIVE,
                               X_END_DATE_ACTIVE                => P_TerrRsc_Rec.END_DATE_ACTIVE,
                               X_FULL_ACCESS_FLAG               => P_TerrRsc_Rec.FULL_ACCESS_FLAG,
                               -- ORG_ID can't be updated. -- VPALLE
                               X_ORG_ID                         => FND_API.G_MISS_NUM,
                               x_attribute_category             => P_TerrRsc_Rec.attribute_category,
                               x_attribute1                     => P_TerrRsc_Rec.attribute1,
                               x_attribute2                     => P_TerrRsc_Rec.attribute2,
                               x_attribute3                     => P_TerrRsc_Rec.attribute3,
                               x_attribute4                     => P_TerrRsc_Rec.attribute4,
                               x_attribute5                     => P_TerrRsc_Rec.attribute5,
                               x_attribute6                     => P_TerrRsc_Rec.attribute6,
                               x_attribute7                     => P_TerrRsc_Rec.attribute7,
                               x_attribute8                     => P_TerrRsc_Rec.attribute8,
                               x_attribute9                     => P_TerrRsc_Rec.attribute9,
                               x_attribute10                    => P_TerrRsc_Rec.attribute10,
                               x_attribute11                    => P_TerrRsc_Rec.attribute11,
                               x_attribute12                    => P_TerrRsc_Rec.attribute12,
                               x_attribute13                    => P_TerrRsc_Rec.attribute13,
                               x_attribute14                    => P_TerrRsc_Rec.attribute14,
                               x_attribute15                    => P_TerrRsc_Rec.attribute15
                               );

   -- Save the terr_usg_id and
   X_TerrRsc_Out_Rec.TERR_RSC_ID := P_TerrRsc_Rec.Terr_Rsc_Id;

   -- If successful then save the success status for the record
   X_TerrRsc_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(P_count          =>   x_msg_count,
                                P_data           =>   x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_TerrRsc_Out_Rec.TERR_RSC_ID  := NULL;
      x_TerrRsc_Out_Rec.return_status := x_return_status;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Update_Territory_Resources');
      END IF;

End Update_Terr_Resource;




--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Resource
--    Type      : PRIVATE
--    Function  : To create Territories qualifier
--
--    Pre-reqs  :
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Tbl                 TerrResource_tbl_type
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Out_Tbl             TerrResource_out_tbl_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--

  PROCEDURE Update_Terr_Resource
    (
      P_TerrRsc_Tbl         IN  TerrResource_tbl_type := G_MISS_TERRRESOURCE_TBL,
      p_Api_Version_Number  IN  NUMBER,
      p_Init_Msg_List       IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit              IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level    IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status       OUT NOCOPY VARCHAR2,
      x_Msg_Count           OUT NOCOPY NUMBER,
      x_Msg_Data            OUT NOCOPY VARCHAR2,
      X_TerrRsc_Out_Tbl     OUT NOCOPY TerrResource_out_tbl_type
    )
  AS
      l_return_Status               VARCHAR2(1);
      l_TerrRsc_Tbl_Count           NUMBER                       := P_TerrRsc_Tbl.Count;
      l_TerrRsc_out_Tbl_Count       NUMBER;
      l_TerrRsc_Out_Tbl             TerrResource_out_tbl_type;
      l_TerrRsc_Out_Rec             TerrResource_out_Rec_type;

      l_Counter                     NUMBER;

BEGIN
   --dbms_output.put_line('Update_Terr_Resource TBL: Entering API');

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_TerrRsc_Tbl_Count LOOP
   --
       --dbms_output.put_line('Update_Terr_Resource TBL: Before Calling Create_Terr_Resource PVT');

       Update_Terr_Resource(P_TerrRsc_Rec                 =>  P_TerrRsc_Tbl(l_counter),
                            p_api_version_number => p_api_version_number,
                            p_init_msg_list => p_init_msg_list,
                            p_commit => p_commit,
                            p_validation_level => p_validation_level,
                            x_return_status => l_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            X_TerrRsc_Out_Rec             =>  l_TerrRsc_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output.put_line('Update_Terr_Resource TBL: l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR');
           -- Save the terr_usg_id and
           X_TerrRsc_Out_Tbl(l_counter).TERR_RSC_ID  := NULL;

           -- If save the ERROR status for the record
           X_TerrRsc_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output.put_line('Update_Terr_Resource TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_TerrRsc_Out_Tbl(l_counter).TERR_RSC_ID   := l_TerrRsc_Out_Rec.TERR_RSC_ID;
           -- If successful then save the success status for the record
           X_TerrRsc_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   --Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_TerrRsc_Out_Tbl_Count    := X_TerrRsc_Out_Tbl.Count;

   FOR l_Counter IN 1 ..  l_TerrRsc_Out_Tbl_Count  LOOP
       If x_TerrRsc_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          x_TerrRsc_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;
   --dbms_output.put_line('Update_Terr_Resource TBL: Exiting API');
--
End Update_Terr_Resource;




--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Resource_Access
--    Type      : PUBLIC
--    Function  : To Update Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_REC
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--

  PROCEDURE Update_Resource_Access
    (
      P_TerrRsc_Access_Rec      TerrRsc_Access_rec_type   := G_MISS_TERRRSC_ACCESS_REC,
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status           OUT NOCOPY VARCHAR2,
      x_Msg_Count               OUT NOCOPY NUMBER,
      x_Msg_Data                OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Rec  OUT NOCOPY TerrRsc_Access_out_rec_type
    )
  AS
      Cursor C_GetTerrResAccess(l_TerrRsc_Access_id Number) IS
          Select Rowid,
                 TERR_RSC_ACCESS_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 TERR_RSC_ID,
                 ACCESS_TYPE,
				 TRANS_ACCESS_CODE,
				 ORG_ID
           From  jtf_terr_rsc_access_ALL
          Where  TERR_RSC_ACCESS_ID = l_TerrRsc_Access_id
          FOR    Update NOWAIT;

      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Update_Resource_Access';
      l_rowid                   VARCHAR2(50);
      l_api_version_number      CONSTANT NUMBER   := 1.0;
      l_return_status           VARCHAR2(1);
      l_ref_TerrRsc_Access_Rec  TerrRsc_Access_rec_type;

BEGIN
      --dbms_output.put_line('Update_Resource_Access REC: Entering API');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
      THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Rsc_Access');
              FND_MSG_PUB.Add;
           END IF;
           --
           -- Invoke validation procedures
           Validate_Terr_Rsc_Access(p_init_msg_list      => FND_API.G_FALSE,
                                    x_Return_Status      => l_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data,
                                    p_TerrRsc_Id         => P_TerrRsc_Access_Rec.terr_rsc_id,
                                    p_TerrRsc_Access_Rec => P_TerrRsc_Access_Rec);

           IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
      --
      END IF;

      OPEN  C_GetTerrResAccess( P_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID);
      Fetch C_GetTerrResAccess into
            l_Rowid,
            l_ref_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID,
            l_ref_TerrRsc_Access_Rec.LAST_UPDATE_DATE,
            l_ref_TerrRsc_Access_Rec. LAST_UPDATED_BY,
            l_ref_TerrRsc_Access_Rec.CREATION_DATE,
            l_ref_TerrRsc_Access_Rec.CREATED_BY,
            l_ref_TerrRsc_Access_Rec.LAST_UPDATE_LOGIN,
            l_ref_TerrRsc_Access_Rec.TERR_RSC_ID,
            l_ref_TerrRsc_Access_Rec.ACCESS_TYPE,
			l_ref_TerrRsc_Access_Rec.TRANS_ACCESS_CODE,
            l_ref_TerrRsc_Access_Rec.ORG_ID;

      If ( C_GetTerrResAccess%NOTFOUND) Then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             --dbms_output.put_line('Update_Resource_Access REC: DATA-NOT-FOUND');
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_RSC_ACCESS');
             FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID));
             FND_MSG_PUB.Add;
         END IF;
         raise FND_API.G_EXC_ERROR;
      End if;
      CLOSE C_GetTerrResAccess;

   -- jdochert 09/09
   -- check for Unique Key constraint violation
   /*
   validate_terr_rsc_access_UK(
               p_Terr_Rsc_Id     => p_TerrRsc_access_rec.terr_rsc_id,
               p_Access_Type     => p_TerrRsc_access_rec.access_type,
               p_init_msg_list   => FND_API.G_FALSE,
               x_Return_Status   => x_return_status,
               x_msg_count       => x_msg_count,
               x_msg_data        => x_msg_data );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   */
      --
      --dbms_output.put_line('Update_Resource_Access REC: Calling JTF_TERR_RSC_ACCESS_PKG.Insert_Row');
      JTF_TERR_RSC_ACCESS_PKG.Update_Row(x_Rowid                => l_rowid,
                                         x_TERR_RSC_ACCESS_ID   => P_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID,
                                         x_LAST_UPDATE_DATE     => P_TerrRsc_Access_Rec.LAST_UPDATE_DATE,
                                         x_LAST_UPDATED_BY      => P_TerrRsc_Access_Rec.LAST_UPDATED_BY,
                                         x_CREATION_DATE        => P_TerrRsc_Access_Rec.CREATION_DATE,
                                         x_CREATED_BY           => P_TerrRsc_Access_Rec.CREATED_BY,
                                         x_LAST_UPDATE_LOGIN    => P_TerrRsc_Access_Rec.LAST_UPDATE_LOGIN,
                                         x_TERR_RSC_ID          => P_TerrRsc_Access_Rec.TERR_RSC_ID,
                                         x_ACCESS_TYPE          => P_TerrRsc_Access_Rec.ACCESS_TYPE,
                                         x_TRANS_ACCESS_CODE    => P_TerrRsc_Access_Rec.TRANS_ACCESS_CODE,
                                         -- ORG_ID can't be updated. -- VPALEE
                                         X_ORG_ID               => FND_API.G_MISS_NUM  );

  -- Save the terr_usg_id and
   X_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID := P_TerrRsc_Access_Rec.TERR_RSC_ACCESS_ID;
   -- If successful then save the success status for the record
   X_TerrRsc_Access_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

   --dbms_output.put_line('Update_Resource_Access REC: Exiting API');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Update_Resource_Access: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

   WHEN OTHERS THEN
        --dbms_output.put_line('Others exception in Update_Territory_Qualifiers');
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        X_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID  := NULL;
        X_TerrRsc_Access_Out_Rec.return_status       := x_return_status;
        --
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Update_Resource _Access');
        END IF;
--
End Update_Resource_Access;




--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Resource _Access
--    Type      : PUBLIC
--    Function  : To create Territories resource Access
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrRsc_Access_Rec          TerrRsc_Access_rec_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_rec_type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--    End of Comments
--

  PROCEDURE Update_Resource_Access
    (
      P_TerrRsc_Access_Tbl      TerrRsc_Access_Tbl_type   := G_MISS_TERRRSC_ACCESS_TBL,
      p_Api_Version_Number      IN  NUMBER,
      p_Init_Msg_List           IN  VARCHAR2              := FND_API.G_FALSE,
      p_Commit                  IN  VARCHAR2              := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER                := FND_API.G_VALID_LEVEL_FULL,
      x_Return_Status           OUT NOCOPY VARCHAR2,
      x_Msg_Count               OUT NOCOPY NUMBER,
      x_Msg_Data                OUT NOCOPY VARCHAR2,
      X_TerrRsc_Access_Out_Tbl  OUT NOCOPY TerrRsc_Access_out_Tbl_type
    )
  AS
      l_terr_value_id               NUMBER;


      l_return_Status               VARCHAR2(1);
      l_TerrRsc_Access_Tbl_Count    NUMBER                          := P_TerrRsc_Access_Tbl.Count;

      l_TerrRscAcc_Out_Tbl_Count    NUMBER;
      l_TerrRsc_Access_Out_Tbl      TerrRsc_Access_out_Tbl_type;
      l_TerrRsc_Access_Out_Rec      TerrRsc_Access_out_Rec_type;

      l_Counter                     NUMBER;

BEGIN
   --dbms_output.put_line('Update_Resource _Access REC: Entering API');

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- -- Call overloaded Update_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_TerrRsc_Access_Tbl_Count LOOP
   --
       --dbms_output.put_line('Inside Update_Resource_Access - ' || to_char(P_TerrRsc_Access_Tbl(l_counter).QUALIFIER_TBL_INDEX) );
       Update_Resource_Access(P_TerrRsc_Access_Rec =>  P_TerrRsc_Access_Tbl(l_counter),
                              p_api_version_number => p_api_version_number,
                              p_init_msg_list => p_init_msg_list,
                              p_commit => p_commit,
                              p_validation_level => p_validation_level,
                              x_return_status => l_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              x_TerrRsc_Access_Out_Rec      =>  l_TerrRsc_Access_Out_Rec);
       --
       --If there is a major error
       IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output.put_line('Update_Resource _Access REC: l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR');
           -- Save the terr_usg_id and
           X_TerrRsc_Access_Out_Tbl(l_counter).TERR_RSC_ACCESS_ID  := NULL;
           -- If save the ERROR status for the record
           X_TerrRsc_Access_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output.put_line('Update_Resource _Access REC: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_TerrRsc_Access_Out_Tbl(l_counter).TERR_RSC_ACCESS_ID := l_TerrRsc_Access_Out_Rec.TERR_RSC_ACCESS_ID;
           -- If successful then save the success status for the record
           X_TerrRsc_Access_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   --Get the API overall return status
   --Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_TerrRscAcc_Out_Tbl_Count   := X_TerrRsc_Access_Out_Tbl.Count;

   FOR l_Counter IN 1 ..  l_TerrRscAcc_Out_Tbl_Count  LOOP
       If x_TerrRsc_Access_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          x_TerrRsc_Access_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;
--
End Update_Resource_Access;
--


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Validate_Foreign_Keys
--    Type      : PUBLIC
--    Function  : Validate Territory Resources
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Validate_Foreign_Keys
    (
      p_TerrRsc_Tbl         IN  TerrResource_tbl_type,
      x_Return_Status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2
    )
  AS
      l_index               NUMBER := 0;
      l_Res_Counter         NUMBER := 0;
      l_Temp                VARCHAR2(1);
      l_Terr_Id             NUMBER;

BEGIN
--
    --dbms_output.put_line('Inside Validate_Foreign_Keys');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    For l_Res_Counter IN p_TerrRsc_Tbl.first .. p_TerrRsc_Tbl.count LOOP
    --
        l_Terr_Id := p_TerrRsc_Tbl(l_res_counter).Terr_Id;
        --
        --dbms_output.put_line('Inside the for loop. Before validating Terr_Id');
        Select 'X' into l_temp
          from JTF_TERR_ALL
         where TERR_ID = p_TerrRsc_Tbl(l_res_counter).Terr_Id;
        --
    --
    End LOOP;
--
EXCEPTION
--
    WHEN NO_DATA_FOUND THEN
         --dbms_output.put_line('Validate_Foreign_Keys: NO_DATA_FOUND');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_message.set_name('JTF', 'JTF_TERR_INVALID_TERRITORY');
         fnd_message.Set_Token('TERR_ID', to_char(l_Terr_Id) );
         FND_MSG_PUB.ADD;
	     FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Foreign_Keys: OTHERS - ' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Foreign_Keys ' || SQLERRM
             );
         END IF;
--
END Validate_Foreign_Keys;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Validate_Resorce_Object
--    Type      : PUBLIC
--    Function  : Validate Territory Resources
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Validate_Primary_Flag
    (
      p_TerrRsc_Tbl         IN  TerrResource_tbl_type,
      p_TerrRsc_Access_Tbl  IN  TerrRsc_Access_tbl_type,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_Return_Status       OUT NOCOPY VARCHAR2
    )
  AS
      l_Primary_Count       NUMBER := 0;
      l_Res_Counter         NUMBER := 0;
      l_Res_Access_Counter  NUMBER := 0;

BEGIN
--
    --Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    For l_Res_Counter IN p_TerrRsc_Tbl.first .. p_TerrRsc_Tbl.count LOOP
    --
        If p_TerrRsc_Tbl(l_Res_Counter).PRIMARY_CONTACT_FLAG = 'Y' Then
           l_Primary_Count := l_Primary_Count + 1;
        End If;
    --
    End LOOP;

    -- Cannot have more than one Primary flag
    If  l_Primary_Count > 1 Then
    --
        fnd_message.set_name('JTF', 'JTF_TERR_MULTIPLE_PRIMARY_FLAG');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
    --
    End If;
--
EXCEPTION
--
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Validate_Primary_Flag: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_Primary_Flag: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Primary_Flag: OTHERS - ' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Primary_Flag ' || SQLERRM
             );
         END IF;
--
END Validate_Primary_Flag;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Validate_TerrResource_Data
--    Type      : PUBLIC
--    Function  : Validate Territory Resources
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--    Notes:
--
--
--    End of Comments
--

  PROCEDURE Validate_TerrResource_Data
    (
      p_TerrRsc_Tbl         IN  TerrResource_tbl_type,
      p_TerrRsc_Access_Tbl  IN  TerrRsc_Access_tbl_type,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_Return_Status       OUT NOCOPY VARCHAR2
    )
  AS
      l_Return_Status    VARCHAR2(01);

BEGIN
--
    --dbms_output.put_line('Inside Validate_TerrResource_Data');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --ARPATEL: bug#2849410
     /*
      Check_for_duplicate (p_TerrRsc_Tbl         => p_TerrRsc_Tbl,
                          x_Return_Status       => l_return_status,
                          x_msg_count           => x_msg_count,
                          x_Msg_Data            => x_Msg_Data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;
     */
    -- If the territory resource records is missing
    If (p_TerrRsc_Tbl.count  = 0 ) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERRRES_REC');
           FND_MSG_PUB.ADD;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        raise FND_API.G_EXC_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --dbms_output.put_line('Before Calling Validate_Primary_Flag');
    Validate_Primary_Flag(p_TerrRsc_Tbl         => p_TerrRsc_Tbl ,
                          p_TerrRsc_Access_Tbl  => p_TerrRsc_Access_Tbl,
                          x_Return_Status       => l_Return_Status,
                          x_msg_count           => x_msg_count,
                          x_Msg_Data            => x_Msg_Data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;

    --dbms_output.put_line('Before Calling Validate_Foreign_Keys');
    Validate_Foreign_Keys(p_TerrRsc_Tbl         => p_TerrRsc_Tbl,
                          x_Return_Status       => l_return_status,
                          x_msg_count           => x_msg_count,
                          x_Msg_Data            => x_Msg_Data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;
--
EXCEPTION
--
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Validate_TerrResource_Data: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_TerrResource_Data: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_TerrResource_Data: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_TerrResource_Data ' || SQLERRM
             );
         END IF;

--
END Validate_TerrResource_Data;

---------------------------------------------------------------------
--             Validate Territory Resource
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Resource and Resource_Type is specified
--         Make sure the Territory Id is valid
---------------------------------------------------------------------

  PROCEDURE Validate_Terr_Rsc
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Rec                 IN  TerrResource_Rec_type
    )
  AS
      l_Validate_id                 NUMBER;
      l_dummy                       NUMBER;
      l_terr_start_date             DATE;
      l_terr_end_date               DATE;

BEGIN
    --dbms_output.put_line('Inside Validate_Terr_Rsc: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the territory Id
    l_Validate_id := p_TerrRsc_Rec.Terr_Id;
    If l_Validate_id IS NOT NULL Then
       -- --dbms_output.put_line('Validate_Terr_Qtype_Usage: TERR_ID(' || to_char(l_Validate_id) || ')');
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
          --dbms_output.put_line('Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR');
             FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
    Else
       -- Invalid Territory Id specified
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'TERR_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check created by
    IF ( p_TerrRsc_Rec.CREATED_BY is NULL OR
        p_TerrRsc_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check creation date
    If ( p_TerrRsc_Rec.CREATION_DATE is NULL OR
        p_TerrRsc_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check ORG_ID
    If ( p_TerrRsc_Rec.ORG_ID  is NULL OR
        p_TerrRsc_Rec.ORG_ID  = FND_API.G_MISS_NUM )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check RESOURCE_ID
    If ( p_TerrRsc_Rec.RESOURCE_ID  is NULL OR
         p_TerrRsc_Rec.RESOURCE_ID  = FND_API.G_MISS_NUM )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'RESOURCE_ID' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check RESOURCE_TYPE
    If ( p_TerrRsc_Rec.RESOURCE_TYPE  is NULL OR
         p_TerrRsc_Rec.RESOURCE_TYPE  = FND_API.G_MISS_CHAR )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'RESOURCE_TYPE' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check START_DATE_ACTIVE
    If ( p_TerrRsc_Rec.START_DATE_ACTIVE  is NULL OR
         p_TerrRsc_Rec.START_DATE_ACTIVE  = FND_API.G_MISS_DATE )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'START_DATE_ACTIVE' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --Check END_DATE_ACTIVE
    If ( p_TerrRsc_Rec.END_DATE_ACTIVE  is NULL OR
         p_TerrRsc_Rec.END_DATE_ACTIVE  = FND_API.G_MISS_DATE )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'END_DATE_ACTIVE' );
            FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    IF (p_TerrRsc_Rec.START_DATE_ACTIVE IS NOT NULL AND p_TerrRsc_Rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE )
       AND (p_TerrRsc_Rec.END_DATE_ACTIVE IS NOT NULL AND p_TerrRsc_Rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN

        IF ( p_TerrRsc_Rec.START_DATE_ACTIVE > p_TerrRsc_Rec.END_DATE_ACTIVE ) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_INV_DATE_RANGE');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END IF;

        -- Resource start and end active dates should fall in territory dates.
        BEGIN

             SELECT jta.start_date_active,jta.end_date_active
               INTO l_terr_start_date,l_terr_end_date
               FROM jtf_terr_all jta
              WHERE jta.terr_id = p_TerrRsc_Rec.Terr_Id ;

             -- Validate start date .
             IF ( p_TerrRsc_Rec.START_DATE_ACTIVE < l_terr_start_date ) OR ( p_TerrRsc_Rec.START_DATE_ACTIVE > l_terr_end_date ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_STARTDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
             END IF;

             -- Validate end date.
             IF ( p_TerrRsc_Rec.END_DATE_ACTIVE < l_terr_start_date ) OR ( p_TerrRsc_Rec.END_DATE_ACTIVE > l_terr_end_date ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTY_RSC_ENDDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
             END IF;

        EXCEPTION
           WHEN OTHERS THEN
                X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'Others Exception in Validate_Terr_Rsc ' || SQLERRM);
                END IF;
        END;

    END IF;

    -- Validate last updated by
    IF  ( p_TerrRsc_Rec.LAST_UPDATED_BY is NULL OR
          p_TerrRsc_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_TerrRsc_Rec.LAST_UPDATE_DATE IS NULL OR
         p_TerrRsc_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_TerrRsc_Rec.LAST_UPDATE_LOGIN  is NULL OR
         p_TerrRsc_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Terr_Rsc ' || SQLERRM
             );
         END IF;
  --
  END Validate_Terr_Rsc;

---------------------------------------------------------------------
--             Validate Territory Resource Access record
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a TERR_RSC_ID is valid
--         Make sure the ACCESS_TYPE is valid
---------------------------------------------------------------------

  PROCEDURE Validate_Terr_Rsc_Access
    (
      p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
      x_Return_Status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      p_TerrRsc_Id                  IN  NUMBER,
      p_TerrRsc_Access_Rec          IN  TerrRsc_Access_Rec_type
    )
  AS
      l_Temp                        VARCHAR2(01);
      l_Validate_id                 NUMBER;
      l_dummy                       NUMBER;

BEGIN
    --dbms_output.put_line('Inside Validate_Terr_Rsc_Access: TERR_RSC_ID ' || to_char(p_TerrRsc_Access_Rec.TERR_RSC_ID) );

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the territory Id
    l_Validate_id := p_TerrRsc_Id;
    If l_Validate_id IS NOT NULL Then
       -- --dbms_output.put_line('Validate_Terr_Qtype_Usage: TERR_ID(' || to_char(l_Validate_id) || ')');
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_RSC_ID', 'JTF_TERR_RSC_ALL') <> FND_API.G_TRUE Then
          --dbms_output.put_line('Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_RSC');
             FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_RSC_ID');
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
    Else
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'TERR_RSC_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Validate the access type
    IF ( p_TerrRsc_Access_Rec.ACCESS_TYPE IS NOT NULL AND
         p_TerrRsc_Access_Rec.ACCESS_TYPE <> FND_API.G_MISS_CHAR )  THEN
        BEGIN
           select 'x' into l_Temp
             from JTF_QUAL_TYPES jqt
            Where jqt.NAME = p_TerrRsc_Access_Rec.ACCESS_TYPE;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                -- Invalid Territory Id specified
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
                FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_QUAL_TYPES');
                FND_MESSAGE.Set_Token('COLUMN_NAME', 'ACCESS_TYPE');
                FND_MSG_PUB.ADD;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END;
    END IF;
     -- Validate the TRANS_ACCESS_CODE
    IF ( p_TerrRsc_Access_Rec.TRANS_ACCESS_CODE is NOT NULL AND
         p_TerrRsc_Access_Rec.TRANS_ACCESS_CODE <> FND_API.G_MISS_CHAR )  THEN
        BEGIN
              SELECT 'X' INTO l_Temp
               FROM ( select DISTINCT lookup_code LOOKUP_CODE
                      from fnd_lookups
                      where lookup_type IN  ( select rsc_access_lkup
                                               from jtf_sources_all)
                     )
               WHERE LOOKUP_CODE = p_TerrRsc_Access_Rec.TRANS_ACCESS_CODE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Invalid TRANS_ACCESS_CODE specified
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
            FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_LOOKUPS');
            FND_MESSAGE.Set_Token('COLUMN_NAME', 'TRANS_ACCESS_CODE');
            FND_MSG_PUB.ADD;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END;
    END IF;

    -- Validate last updated by
    IF  ( p_TerrRsc_Access_Rec.LAST_UPDATED_BY is NULL OR
          p_TerrRsc_Access_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_TerrRsc_Access_Rec.LAST_UPDATE_DATE IS NULL OR
         p_TerrRsc_Access_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_TerrRsc_Access_Rec.LAST_UPDATE_LOGIN  is NULL OR
         p_TerrRsc_Access_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Validate_Terr_Rsc ' || SQLERRM
             );
         END IF;
  --
  END Validate_Terr_Rsc_Access;



  -- This function will build the rule expression

  FUNCTION  BuildRuleExpression
    (
      p_Terr_Id      NUMBER,
      p_qual_type_id NUMBER
    ) return  VARCHAR2
  AS
      v_Terr_Qual_Id number;

      CURSOR c_Terr_ResQual IS
           SELECT JTQ.TERR_QUAL_ID
             FROM jtf_seeded_qual_usgs_v jsquv, JTF_TERR_QUAL JTQ
            WHERE JTQ.terr_id = p_Terr_id and
                  JTQ.qual_usg_id = jsquv.qual_usg_id and
                  jsquv.qual_type_id = -1001 and
                  jsquv.qual_type_id in ( select related_id
                                               from JTF_QUAL_TYPE_DENORM_V
                                              where qual_type_id = p_qual_type_id);

      CURSOR c_Values IS
               Select JTV.COMPARISON_OPERATOR, JTV.INCLUDE_FLAG, jsquv.QUAL_COL1,
                      jsquv.QUAL_COL1_TABLE, jsquv.QUAL_COL1_ALIAS, jsquv.PRIM_INT_CDE_COL_ALIAS,
                      jsquv.SEC_INT_CDE_COL_ALIAS, jtv.low_value_char,jtv.high_value_char,
                      jtv.low_value_number, jtv.high_value_number,
                      jtv.INTEREST_TYPE_ID, jtv.PRIMARY_INTEREST_CODE_ID,
                      jtv.SECONDARY_INTEREST_CODE_ID, jsquv.DISPLAY_TYPE, jsquv.CONVERT_TO_ID_FLAG,
                      jtv.ID_USED_FLAG, jtv.CURRENCY_CODE, jtv.LOW_VALUE_CHAR_ID
                 from jtf_seeded_qual_usgs_v jsquv, jtf_terr_values jtv, jtf_terr_qual jtq
                where jtv.terr_qual_id = v_Terr_Qual_Id and
                      jtv.terr_qual_id = jtq.terr_qual_id and
                      jtq.qual_usg_id = jsquv.qual_usg_id;

      Type t_Pkgname IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
      l_Expr_Tbl       t_Pkgname;
      l_Expr_Pointer   NUMBER := 0;
      l_Record         JTF_TERR_ENGINE_GEN_PVT.Terr_Value_Rec_Type;

      v_Expression     VARCHAR2(5000);
      v_Temp           VARCHAR2(256);
      v_State          BOOLEAN;
      v_Counter        NUMBER := 0;
      l_Row            NUMBER := 0;

  BEGIN
      -- Reinitialize the v_Temp to NULL
      v_Temp   := NULL;

      FOR C IN c_Terr_ResQual LOOP
          l_Expr_Pointer := l_Expr_Pointer + 1;
          v_Terr_Qual_Id := C.terr_qual_Id;

          --dbms_output.put_line( '[1] Inside BuildRuleExpression -> Terr_Qual_Id - ' || to_char(v_Terr_Qual_Id) );
          v_Counter := 1;

          If v_Counter = 1 and l_Expr_Pointer = 1 Then
             l_Expr_Tbl(l_Expr_Pointer) := ' (( ';
             -- Inside the loop for the first qualifer
          ElsIf v_Counter = 1 Then
             l_Expr_Tbl(l_Expr_Pointer) := ' AND  (( ';
          End If;

          Open c_Values;

          LOOP
              Fetch c_Values INTO l_Record;

              Exit WHEN c_Values%NOTFOUND;

              --for second set of qualifer value
              If l_Expr_Pointer > 1 and v_counter <> 1 Then
                 l_Expr_Pointer := l_Expr_Pointer + 1;
                 l_Expr_Tbl(l_Expr_Pointer) := ' OR ( ';
              End If;

              v_Counter := v_Counter + 1;
              l_Expr_Pointer := l_Expr_Pointer + 1;

              --dbms_output.put_line('Values -> l_Expr_Pointer ' || to_char( l_Expr_Pointer) );

              -- --dbms_output.put_line( '[1] Inside the VALUES loop - '|| l_Record.DISPLAY_TYPE);
              -- Do all the special processing for for interest Category/Primary Intererst/ Secondary types
              IF  l_Record.DISPLAY_TYPE = 'INTEREST_TYPE' Then
                  --dbms_output.put_line( 'Inside first if interest_type');
                  v_Temp := JTF_TERRITORY_RESOURCE_PVT.Get_Expression_Interest_Type(l_Record => l_record);
              -- This display type is only for resource qualifer (competence/competence level)
              ELSIf  l_Record.DISPLAY_TYPE = 'COMPETENCE' Then
                  --dbms_output.put_line( 'Inside first if competence');
                  v_Temp := JTF_TERRITORY_RESOURCE_PVT.Get_Expression_COMPETENCE(l_Record => l_record);
              ELSIf l_Record.DISPLAY_TYPE = 'NUMERIC' Then
                  --dbms_output.put_line( 'Inside char number if');
                  v_Temp := JTF_TERRITORY_RESOURCE_PVT.Get_Expression_NUMERIC(l_Record => l_record);
              ELSIf l_Record.DISPLAY_TYPE like 'CHAR' Then
                  --dbms_output.put_line( 'Inside char number if');
                  v_Temp := JTF_TERRITORY_RESOURCE_PVT.Get_Expression_CHAR(l_Record => l_record);
              ELSIf l_Record.DISPLAY_TYPE = 'SPECIAL_FUNCTION' Then
                   -- Need to add this
                   null;
              ELSIF l_Record.DISPLAY_TYPE = 'CURRENCY' Then
                   v_Temp := JTF_TERRITORY_RESOURCE_PVT.Get_Expression_CURRENCY(l_Record => l_record);
              End If;
              --
              l_Expr_Tbl(l_Expr_Pointer) := v_Temp;

              l_Expr_Pointer := l_Expr_Pointer + 1;
              l_Expr_Tbl(l_Expr_Pointer) := ' ) ';
           --
           END LOOP;

           Close c_Values;
           --
           l_Expr_Pointer := l_Expr_Pointer + 1;
           l_Expr_Tbl(l_Expr_Pointer) := ' ) ';
      END LOOP;
      --
      FOR l_Row IN 1 .. l_Expr_Tbl.Count LOOP
          If l_Row = l_Expr_Pointer and rtrim(l_Expr_Tbl(l_Row)) is not NULL Then
             v_Expression := v_Expression || rtrim(l_Expr_Tbl(l_Row));
             --dbms_output.put_line(l_Expr_Tbl(l_Row) );
          ElsIf rtrim(l_Expr_Tbl(l_Row)) is not NULL Then
             v_Expression := v_Expression || rtrim(l_Expr_Tbl(l_Row));
             --dbms_output.put_line(l_Expr_Tbl(l_Row) );
          End If;
      End LOOP;
      return v_Expression;
  EXCEPTION
      WHEN OTHERS Then
           v_Expression := NULL;
           return v_Expression;
  END BuildRuleExpression;




  FUNCTION Get_Expression_Interest_Type
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2
  AS
      l_Expression VARCHAR2(1000);

  BEGIN
       If l_Record.COMPARISON_OPERATOR = '=' Then
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' = ';
          -- If the following condition is NOT true then it is a bug/data problem
          If l_Record.INTEREST_TYPE_ID IS NOT NULL Then
             l_Expression := l_Expression || to_char(l_Record.INTEREST_TYPE_ID) || ' ';
             If l_Record.PRIMARY_INTEREST_CODE_ID is NOT NULL Then
                l_Expression := l_Expression || 'AND P_RECORD.' ||
                                l_Record.PRIM_INT_CDE_COL_ALIAS || ' = ' ||
                                to_char(l_Record.PRIMARY_INTEREST_CODE_ID) || ' ';
                If l_Record.SECONDARY_INTEREST_CODE_ID IS NOT NULL Then
                   l_Expression := l_Expression || 'AND P_RECORD.' ||
                                   l_Record.SEC_INT_CDE_COL_ALIAS || ' = ' ||
                                   to_char(l_Record.SECONDARY_INTEREST_CODE_ID) || ' ';
                End If;
             End If;
          -- If the interest type id is NULL. This is actually data error
          Else
             l_Expression := NULL;
          End If;
       -- For interest type Other operator should be invalid
       Else
          l_Expression := NULL;
       End If;
       --dbms_output.put_line(l_Expression);

       return l_Expression;
  END Get_Expression_Interest_Type;




  -- NUMERIC Display Type

  FUNCTION Get_Expression_NUMERIC
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2
  AS
      l_Expression VARCHAR2(1000);

  BEGIN
       --process between operator
       If l_Record.COMPARISON_OPERATOR IN  ('BETWEEN', 'NOT BETWEEN')  Then
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ' || to_char(l_Record.LOW_VALUE_NUMBER) || ' AND ' ||
                          to_char(l_Record.HIGH_VALUE_NUMBER) || ' ';
       -- Process like operator
       ElsIf l_Record.COMPARISON_OPERATOR IN  ('NOT LIKE', 'LIKE')  Then
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ''' || to_char(l_Record.LOW_VALUE_NUMBER) || '%''';

       --Other operator like <, >, <=, >=, <>, <, =
       Else
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ' || to_char(l_Record.LOW_VALUE_NUMBER);
       End If;
       return l_Expression;

       --dbms_output.put_line(l_Expression);
  END Get_Expression_NUMERIC;




  -- CURRENCY Display Type

  FUNCTION Get_Expression_CURRENCY
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2
  AS
      l_Expression VARCHAR2(1000);

  BEGIN
       -----------------------------------------------------------
       --     Need to add the currency convertion routine
       ------------------------------------------------------------

       --process between operator
       If l_Record.COMPARISON_OPERATOR IN  ('BETWEEN', 'NOT BETWEEN')  Then
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ' || to_char(l_Record.LOW_VALUE_NUMBER) || ' AND ' ||
                          to_char(l_Record.HIGH_VALUE_NUMBER) || ' ';
       --Other operator like <, >, <=, >=, <>, <, =
       Else
          l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ' || to_char(l_Record.LOW_VALUE_NUMBER);
       End If;
       --dbms_output.put_line(l_Expression);

       return l_Expression;

  END Get_Expression_CURRENCY;




   -- VARCHAR2 Display Type

  FUNCTION Get_Expression_CHAR
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2
  AS
      l_Expression VARCHAR2(1000);

  BEGIN
       If nvl(l_Record.CONVERT_TO_ID_FLAG, 'N') = 'N' Then
          --process between operator
          If l_Record.COMPARISON_OPERATOR IN  ('BETWEEN', 'NOT BETWEEN')  Then
             l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                             ' ''' || l_Record.LOW_VALUE_CHAR || ''' AND ''' || l_Record.HIGH_VALUE_CHAR || '''';

          -- Process like operator
          ElsIf l_Record.COMPARISON_OPERATOR IN  ('NOT LIKE', 'LIKE')  Then
             l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                              '''' || l_Record.LOW_VALUE_CHAR || '%''';

          --Other operator like <, >, <=, >=, <>, <, =
          Else
              l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                          ' ''' || l_Record.LOW_VALUE_CHAR || ''' ';

          End If;
       --
       --If the Convert to ID flag is Turned off
       Else
          If  nvl(l_Record.ID_USED_FLAG, 'N')  =  'N'  Then
               If l_Record.COMPARISON_OPERATOR IN  ('BETWEEN', 'NOT BETWEEN')  Then
                  l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                             '''' || l_Record.LOW_VALUE_CHAR || ''' AND ''' || l_Record.HIGH_VALUE_CHAR || '''';

               End If;
        Else
          -- Process like operator
          If l_Record.COMPARISON_OPERATOR IN  ('NOT LIKE', 'LIKE')  Then
                 l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                             '''' || l_Record.LOW_VALUE_CHAR || '%'' ';

              --Other operator like <, >, <=, >=, <>, <, =
          Else
              l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' ' || l_Record.COMPARISON_OPERATOR ||
                             ' ' || to_char(l_Record.LOW_VALUE_CHAR_ID) || ' ';
          End If;
        end if;
       End If;
       --dbms_output.put_line(l_Expression);
       return l_Expression;
   --
  END Get_Expression_CHAR;




  FUNCTION Get_Expression_Competence
    (
      l_Record JTF_TERR_ENGINE_GEN_PVT.TERR_VALUE_REC_TYPE
    ) RETURN VARCHAR2
  AS
      l_Expression VARCHAR2(1000);

  BEGIN
        If l_Record.COMPARISON_OPERATOR = '=' Then
           l_Expression := ' P_RECORD.' || l_Record.QUAL_COL1_ALIAS || ' = ';

           -- If the following condition is NOT true then it is a bug/data problem
           If l_Record.INTEREST_TYPE_ID IS NOT NULL Then
              l_Expression := l_Expression || to_char(l_Record.INTEREST_TYPE_ID) || ' ';
              If l_Record.PRIMARY_INTEREST_CODE_ID is NOT NULL Then
                 l_Expression := l_Expression || 'AND P_RECORD.' ||
                                l_Record.PRIM_INT_CDE_COL_ALIAS || ' = ' ||
                                to_char(l_Record.PRIMARY_INTEREST_CODE_ID) || ' ';
              End If;
           -- If the competence id is NULL. This is actually data error
           Else
              l_Expression := NULL;
           End If;

       -- For interest type Other operator should be invalid
       Else
          l_Expression := NULL;
       End If;
       --dbms_output.put_line(l_Expression);
       return l_Expression;
  --
  END Get_Expression_Competence;




  -- Function used in JTF_TERR_RESOURCES_V to return
  -- the group_name for the group_id of a resource

  FUNCTION get_group_name
    (
      p_group_id  NUMBER
    ) RETURN VARCHAR2 IS

    x_group_name      VARCHAR2(60);

    /* cursor to get group_name */

    CURSOR c_get_group_name (p_group_id NUMBER) IS
      SELECT jrgv.group_name
      FROM   jtf_rs_groups_vl jrgv
      WHERE  jrgv.group_id = p_group_id
      AND    rownum < 2;

  BEGIN

    IF ( p_group_id = FND_API.G_MISS_NUM OR
         p_group_id IS NULL) THEN

      /* no group_id so return NULL */
      RETURN NULL;

    ELSE  /* get group_name */

      OPEN c_get_group_name(p_group_id);
      FETCH c_get_group_name INTO x_group_name;
      CLOSE c_get_group_name;

      RETURN x_group_name;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  END get_group_name;

    /* 10/12/00 JDOCHERT */
  -- Function used in views to return
  -- the resource name
  FUNCTION get_resource_name  ( p_resource_id    NUMBER
                              , p_resource_type  VARCHAR2)
  RETURN VARCHAR2 IS

    lx_resource_name      VARCHAR2(240);

    /* cursor to get resource type name */
    CURSOR csr_get_rs_name ( lp_resource_id    NUMBER
                           , lp_resource_type  VARCHAR2) IS
      SELECT jv.resource_name
      FROM   jtf_rs_resources_vl jv
      WHERE  jv.resource_id = lp_resource_id
        AND  jv.resource_type = lp_resource_type
        AND  rownum < 2;

     lx_rs_type_code     VARCHAR2(60);

  BEGIN

      lx_rs_type_code := p_resource_type;

      /* 3/19/02: JDOCHERT: 2144381 + 2195839 bug fixes */
      IF lx_rs_type_code = 'RS_SUPPLIER' THEN
         lx_rs_type_code := 'RS_SUPPLIER_CONTACT';
      END IF;

       /* get resource type name */
      OPEN csr_get_rs_name(p_resource_id, lx_rs_type_code);
      FETCH csr_get_rs_name INTO lx_resource_name;
      CLOSE csr_get_rs_name;

      RETURN lx_resource_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  END get_resource_name;

/* 10/04/00 JDOCHERT */
  -- Function used in views to return
  -- the resource type name for the resource type code
  -- of a resource
  FUNCTION get_rs_type_name  (p_rs_type_code  VARCHAR2)
  RETURN VARCHAR2 IS

    lx_rs_type_name      VARCHAR2(60);

    /* cursor to get resource type name */
    CURSOR csr_get_rs_type_name (lp_rs_type_code  VARCHAR2) IS
      SELECT jo.name
      FROM   jtf_objects_vl jo
      WHERE  jo.object_code = lp_rs_type_code
        AND  rownum < 2;

  BEGIN

      OPEN csr_get_rs_type_name(p_rs_type_code);
      FETCH csr_get_rs_type_name INTO lx_rs_type_name;
      CLOSE csr_get_rs_type_name;

      RETURN lx_rs_type_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  END get_rs_type_name;


/* 09/16/00    VVUYYURU */
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Copy_Terr_Resources
--    Type      : PUBLIC
--    Function  : Copy Territory Resources and Resource Access
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          IN  NUMBER,
--      p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
--      p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
--      p_source_terr_id              NUMBER                           := G_MISS_NUM
--      p_dest_terr_id                NUMBER                           := G_MISS_NUM
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2
--      x_msg_count                   NUMBER
--      x_msg_data                    VARCHAR2
--    Notes:
--
--
--    End of Comments
--
  PROCEDURE Copy_Terr_Resources
    (
      p_Api_Version_Number  IN  NUMBER,
      p_Init_Msg_List       IN  VARCHAR2     := FND_API.G_FALSE,
      p_Commit              IN  VARCHAR2     := FND_API.G_FALSE,
      p_validation_level    IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_source_terr_id              IN  NUMBER,
      p_dest_terr_id                IN  NUMBER,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2,
      x_return_status               OUT NOCOPY VARCHAR2
    )
  IS

    l_api_name                    CONSTANT VARCHAR2(30) := 'Copy_Terr_Resources';
    l_api_version_number          CONSTANT NUMBER       := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);

    l_dest_terr_rsc_id            NUMBER;
    l_source_terr_rsc_id          NUMBER;

    l_TerrRsc_rec                 TerrResource_rec_type;
    l_TerrRsc_Access_rec          TerrRsc_Access_rec_type;
    l_TerrRsc_Out_rec             TerrResource_out_rec_type;
    l_TerrRsc_Access_Out_rec      TerrRsc_Access_out_rec_type;


    CURSOR csr_rsc_all (lp_terr_id NUMBER) IS
      SELECT terr_rsc_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             --terr_id,
             resource_id,
             group_id,
             resource_type,
             role,
             primary_contact_flag,
             start_date_active,
             end_date_active,
             full_access_flag,
             org_id
      FROM   jtf_terr_rsc_ALL
      WHERE  terr_id = lp_terr_id;


    CURSOR csr_rsc_access_all (lp_terr_rsc_id NUMBER) IS
      SELECT
             --terr_rsc_access_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             --terr_rsc_id,
             access_type,
             org_id
      FROM   jtf_terr_rsc_access_ALL
      WHERE  terr_rsc_id = lp_terr_rsc_id;


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT COPY_TERR_RESOURCES;

    /*
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    */


    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      fnd_message.set_name ('JTF', 'JTF_TERR_START_MSG');
      fnd_message.set_name ('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API Body starts here

    OPEN csr_rsc_all (p_source_terr_id);
    LOOP
      FETCH csr_rsc_all INTO
            l_source_terr_rsc_id,
            l_TerrRsc_rec.last_update_date,
            l_TerrRsc_rec.last_updated_by,
            l_TerrRsc_rec.creation_date,
            l_TerrRsc_rec.created_by,
            l_TerrRsc_rec.last_update_login,
            --l_TerrRsc_rec.terr_id,
            l_TerrRsc_rec.resource_id,
            l_TerrRsc_rec.group_id,
            l_TerrRsc_rec.resource_type,
            l_TerrRsc_rec.role,
            l_TerrRsc_rec.primary_contact_flag,
            l_TerrRsc_rec.start_date_active,
            l_TerrRsc_rec.end_date_active,
            l_TerrRsc_rec.full_access_flag,
            l_TerrRsc_rec.org_id;

      l_TerrRsc_rec.terr_id := p_dest_terr_id;

      EXIT WHEN csr_rsc_all%NOTFOUND;

      JTF_TERRITORY_RESOURCE_PVT.Create_Terr_Resource
        (
          p_TerrRsc_Rec          =>   l_TerrRsc_rec,
          p_Api_Version_Number   =>   l_api_version_number,
          p_Init_Msg_List        =>   NULL,
          p_Commit               =>   NULL,
          p_validation_level     =>   NULL,
          x_Return_Status        =>   x_Return_Status,
          x_Msg_Count            =>   x_Msg_Count,
          x_Msg_Data             =>   x_Msg_Data,
          x_TerrRsc_Out_Rec      =>   l_TerrRsc_Out_rec
        );

        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN

          /*
          dbms_output.put_line(
          'Unexpected Execution Error from call to Create Terr Resource API');
          */

          fnd_message.set_name('JTF', 'JTF_ERROR_TERRRSC_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;

        END IF;

      l_dest_terr_rsc_id := l_TerrRsc_Out_rec.terr_rsc_id;

      OPEN csr_rsc_access_all(l_source_terr_rsc_id);
      LOOP
        FETCH csr_rsc_access_all INTO
              --l_TerrRsc_Access_rec.terr_rsc_access_id,
              l_TerrRsc_Access_rec.last_update_date,
              l_TerrRsc_Access_rec.last_updated_by,
              l_TerrRsc_Access_rec.creation_date,
              l_TerrRsc_Access_rec.created_by,
              l_TerrRsc_Access_rec.last_update_login,
              --l_TerrRsc_Access_rec.terr_rsc_id,
              l_TerrRsc_Access_rec.access_type,
              l_TerrRsc_Access_rec.org_id;

        l_TerrRsc_Access_rec.terr_rsc_id := l_dest_terr_rsc_id;

        EXIT WHEN csr_rsc_access_all%NOTFOUND;

        --dbms_output.put_line('Terr Resource ID : '||l_TerrRsc_Access_rec.terr_rsc_id);

        JTF_TERRITORY_RESOURCE_PVT.Create_Resource_Access
          (
            p_TerrRsc_Id               =>   l_dest_terr_rsc_id,
            p_TerrRsc_Access_Rec       =>   l_TerrRsc_Access_rec,
            p_Api_Version_Number       =>   l_api_version_number,
            p_Init_Msg_List            =>   FND_API.G_FALSE,
            p_Commit                   =>   FND_API.G_FALSE,
            p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL,
            x_Return_Status            =>   x_Return_Status,
            x_Msg_Count                =>   x_Msg_Count,
            x_Msg_Data                 =>   x_Msg_Data,
            x_TerrRsc_Access_Out_Rec   =>   l_TerrRsc_Access_Out_rec
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            /*
            dbms_output.put_line(
            'Unexpected Execution Error from call to Create Terr Resource Access API');
            */
            fnd_message.set_name('JTF', 'JTF_ERROR_TERRRSCACCESS_API');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

      END LOOP;
      CLOSE csr_rsc_access_all;

    END LOOP;
    CLOSE csr_rsc_all;

  /*
    x_Return_Status    :=   l_Return_Status;
    x_Msg_Count        :=   l_Msg_Count;
    x_Msg_Data         :=   l_Msg_Data;
  */


    /* Standard call to get message count and
    the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Copy Territory Resources : FND_API.G_EXC_ERROR');
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Copy Territory Resources : FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Copy Territory Resources : OTHERS - ' || SQLERRM);
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
             FND_MSG_PUB.Add_Exc_Msg
             (  G_PKG_NAME,
                'Others Exception in Copy_Terr_Resources ' || SQLERRM
             );
         END IF;

  END Copy_Terr_Resources;



/* procedure to check that UK constraint is not
** being violated on JTF_TERR_RSC_ALL table
** -- jdochert 09/19
*/
PROCEDURE validate_terr_rsc_access_UK(
               p_Terr_Rsc_Id             IN  NUMBER,
               p_Access_Type             IN  VARCHAR2,
               p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2 )
  AS

     -- cursor to check that Unique Key constraint not violated
     CURSOR csr_chk_uk_violation ( lp_terr_rsc_id     NUMBER
                                 , lp_access_type     VARCHAR2) IS
      SELECT 'X'
      FROM JTF_TERR_RSC_ACCESS_ALL
      WHERE terr_rsc_id = lp_terr_rsc_id
        AND access_type = lp_access_type;

     l_return_csr    VARCHAR2(1);

  BEGIN

    --dbms_output('Validate_Unique_Key: Entering API');
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* check that Unique Key constraint not violated */
    IF ( p_terr_rsc_id IS NOT NULL AND p_terr_rsc_id <> FND_API.G_MISS_NUM  AND
         p_access_type IS NOT NULL AND p_access_type <> FND_API.G_MISS_CHAR ) THEN

         /* check if rec already exists */
         OPEN csr_chk_uk_violation ( p_terr_rsc_id
                                   , p_access_type);
         FETCH csr_chk_uk_violation INTO l_return_csr;

         IF csr_chk_uk_violation%FOUND THEN

            x_return_status := FND_API.G_RET_STS_ERROR;

            /* Debug message */
            --arpatel bug#1500581 (part of fix)
            --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_RSC_ACCESS_UK_CON');
               --FND_MESSAGE.Set_Token ('TABLE', 'JTF_TERR_RSC_ACCESS_ALL');
               FND_MSG_PUB.ADD;
            --END IF;

         END IF; /* c_chk_uk_violation%FOUND */
         CLOSE csr_chk_uk_violation;

      END IF;

      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data);

 EXCEPTION

    WHEN OTHERS THEN
         --dbms_output('Validate_Foreign_Key: Others exception' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Unique_Key' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

END validate_terr_rsc_access_UK;



/* 09/19/00 JDOCHERT */
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Transfer_Resource_Territories
--    Type      : PUBLIC
--    Function  : Transfer one Resource's Territories to another resource
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          IN  NUMBER,
--      p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
--      p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
--      p_source_resource_rec         TerrResource_Rec_type
--      p_p_dest_resource_rec        TerrResource_Rec_type
--      p_all_terr_flag            IN  VARCHAR2     := 'Y',
--      p_terr_ids_tbl             IN  Terr_Ids_Tbl_Type,
--      p_replace_flag             IN  VARCHAR2     := 'Y',
--      p_add_flag                 IN  VARCHAR2     := 'N',
--      p_delete_flag              IN  VARCHAR2     := 'Y',
--
--      Optional
--      Parameter Name                Data Type  Default
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2
--      x_msg_count                   NUMBER
--      x_msg_data                    VARCHAR2
--    Notes:
--
--
--    End of Comments
--
  PROCEDURE Transfer_Resource_Territories
    (
      p_Api_Version_Number       IN  NUMBER,
      p_Init_Msg_List            IN  VARCHAR2     := FND_API.G_FALSE,
      p_Commit                   IN  VARCHAR2     := FND_API.G_FALSE,
      p_validation_level         IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_source_resource_rec      IN  TerrResource_Rec_type,
      p_dest_resource_rec        IN  TerrResource_Rec_type,
      p_all_terr_flag            IN  VARCHAR2     := 'Y',
      p_terr_ids_tbl             IN  Terr_Ids_Tbl_Type,
      p_replace_flag             IN  VARCHAR2     := 'Y',
      p_add_flag                 IN  VARCHAR2     := 'N',
      p_delete_flag              IN  VARCHAR2     := 'Y',
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
    ) AS

      l_api_name                   CONSTANT VARCHAR2(30) := 'Transfer_Resource_Territories';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_terr_ids_tbl               Terr_Ids_Tbl_Type;

  CURSOR csr_terr_rsc(l_resource_id NUMBER, l_resource_type VARCHAR) IS
    select j.terr_id
    from   jtf_terr_rsc_ALL j, jtf_terr_ALL jt
    where  j.resource_id = l_resource_id
      and    j.resource_type = l_resource_type
      and    j.terr_id = jt.terr_id
      and    jt.template_flag = 'N'
      and    jt.escalation_territory_flag = 'N'
      --ARPATEL: bug#2897391
      and    ( jt.terr_group_flag is null OR jt.terr_group_flag = 'N' )
      and not jt.terr_id = 1;

  CURSOR csr_unassigned_terrs IS
    select terr_id
    from JTF_TERR_ALL jt
    where NOT EXISTS (select jtr.terr_id
                      from   jtf_terr_rsc_ALL jtr
                      where  jt.terr_id = jtr.terr_id
                      )
      and jt.template_flag = 'N'
      and jt.escalation_territory_flag = 'N'
      --ARPATEL: bug#2897391
      and ( jt.terr_group_flag is null OR jt.terr_group_flag = 'N' )
      and not jt.terr_id = 1;

  BEGIN
     -- Standard Start of API savepoint
    SAVEPOINT TRANSFER_TERR_RES;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;



    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      fnd_message.set_name ('JTF', 'JTF_TERRITORY_START_MSG');
      fnd_message.set_name ('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API Body starts here
      -- create list of the source resource territories

      IF p_all_terr_flag = 'Y' and p_source_resource_rec.resource_id is not null
      THEN
            OPEN csr_terr_rsc(p_source_resource_rec.resource_id, p_source_resource_rec.resource_type);
            FETCH csr_terr_rsc
              BULK COLLECT INTO l_terr_ids_tbl;
            CLOSE csr_terr_rsc;
      ELSIF p_all_terr_flag = 'Y' and p_source_resource_rec.resource_id is null
      THEN
            OPEN csr_unassigned_terrs;
            FETCH csr_unassigned_terrs
              BULK COLLECT INTO l_terr_ids_tbl;
            CLOSE csr_unassigned_terrs;
      ELSE
            l_terr_ids_tbl := p_terr_ids_tbl;
      END IF;


      IF p_add_flag = 'Y'
      THEN
          FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
           INSERT INTO JTF_TERR_RSC_ALL(
           TERR_RSC_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           RESOURCE_ID,
           GROUP_ID,
           RESOURCE_TYPE,
           ROLE,
           PRIMARY_CONTACT_FLAG,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           FULL_ACCESS_FLAG,
           ORG_ID
          ) VALUES (
           JTF_TERR_RSC_s.nextval,
           decode( p_dest_resource_rec.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.LAST_UPDATE_DATE),
           decode( p_dest_resource_rec.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATED_BY),
           decode( p_dest_resource_rec.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.CREATION_DATE),
           decode( p_dest_resource_rec.CREATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.CREATED_BY),
           decode( p_dest_resource_rec.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATE_LOGIN),
           decode( l_terr_ids_tbl(i), FND_API.G_MISS_NUM, NULL,l_terr_ids_tbl(i)),
           decode( p_dest_resource_rec.RESOURCE_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.RESOURCE_ID),
           decode( p_dest_resource_rec.GROUP_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.GROUP_ID),
           decode( p_dest_resource_rec.RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.RESOURCE_TYPE),
           decode( p_dest_resource_rec.ROLE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.ROLE),
           decode( p_dest_resource_rec.PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.PRIMARY_CONTACT_FLAG),
           decode( p_dest_resource_rec.START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.START_DATE_ACTIVE),
           decode( p_dest_resource_rec.END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.END_DATE_ACTIVE),
           decode( p_dest_resource_rec.FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.FULL_ACCESS_FLAG),
           decode( p_dest_resource_rec.ORG_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.ORG_ID)
           );


        ELSIF p_replace_flag = 'Y'
        THEN
            IF p_delete_flag = 'Y'
            THEN

               FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
                INSERT INTO JTF_TERR_RSC_ALL(
                TERR_RSC_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                TERR_ID,
                RESOURCE_ID,
                GROUP_ID,
                RESOURCE_TYPE,
                ROLE,
                PRIMARY_CONTACT_FLAG,
                START_DATE_ACTIVE,
                END_DATE_ACTIVE,
                FULL_ACCESS_FLAG,
                ORG_ID
                ) VALUES (
                JTF_TERR_RSC_s.nextval,
                decode( p_dest_resource_rec.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.LAST_UPDATE_DATE),
                decode( p_dest_resource_rec.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATED_BY),
                decode( p_dest_resource_rec.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.CREATION_DATE),
                decode( p_dest_resource_rec.CREATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.CREATED_BY),
                decode( p_dest_resource_rec.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATE_LOGIN),
                decode( l_terr_ids_tbl(i), FND_API.G_MISS_NUM, NULL,l_terr_ids_tbl(i)),
                decode( p_dest_resource_rec.RESOURCE_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.RESOURCE_ID),
                decode( p_dest_resource_rec.GROUP_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.GROUP_ID),
                decode( p_dest_resource_rec.RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.RESOURCE_TYPE),
                decode( p_dest_resource_rec.ROLE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.ROLE),
                decode( p_dest_resource_rec.PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.PRIMARY_CONTACT_FLAG),
                decode( p_dest_resource_rec.START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.START_DATE_ACTIVE),
                decode( p_dest_resource_rec.END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.END_DATE_ACTIVE),
                decode( p_dest_resource_rec.FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.FULL_ACCESS_FLAG),
                decode( p_dest_resource_rec.ORG_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.ORG_ID)
           );

           --ARPATEL: 11/06/2003 BUG#2798581 START
          FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
           INSERT INTO JTF_TERR_RSC_ACCESS_ALL(
           TERR_RSC_ACCESS_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_RSC_ID,
           ACCESS_TYPE,
           ORG_ID
          )
          SELECT
               JTF_TERR_RSC_ACCESS_s.nextval,
               SYSDATE,
               G_USER_ID,
               SYSDATE,
               G_USER_ID,
               G_LOGIN_ID,
               ntra.terr_rsc_id, -- needs to be the newly created terr_rsc_id from above
               raa.access_type,
               p_dest_resource_rec.ORG_ID
          FROM
                JTF_TERR_RSC_ACCESS_ALL raa
               ,JTF_TERR_RSC_ALL tra -- use old record to find access_type
               ,JTF_TERR_RSC_ALL ntra -- pick up new records from above
          WHERE
                tra.terr_rsc_id = NVL(raa.terr_rsc_id, tra.terr_rsc_id)
          AND   tra.resource_id = p_source_resource_rec.resource_id
          AND   ntra.terr_id = tra.terr_id
          AND   ntra.resource_id = p_dest_resource_rec.resource_id
          AND   tra.terr_id = l_terr_ids_tbl(i)
           ;

           --Do all the deleting of old records at the end

           FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
            DELETE from jtf_terr_rsc_ALL
            where terr_id = l_terr_ids_tbl(i)
            and resource_id = p_source_resource_rec.resource_id;


           --ARPATEL: 11/06/2003 BUG#2798581 END



           ELSE

                FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
                INSERT INTO JTF_TERR_RSC_ALL(
                TERR_RSC_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                TERR_ID,
                RESOURCE_ID,
                GROUP_ID,
                RESOURCE_TYPE,
                ROLE,
                PRIMARY_CONTACT_FLAG,
                START_DATE_ACTIVE,
                END_DATE_ACTIVE,
                FULL_ACCESS_FLAG,
                ORG_ID
                ) VALUES (
                JTF_TERR_RSC_s.nextval,
                decode( p_dest_resource_rec.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.LAST_UPDATE_DATE),
                decode( p_dest_resource_rec.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATED_BY),
                decode( p_dest_resource_rec.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_dest_resource_rec.CREATION_DATE),
                decode( p_dest_resource_rec.CREATED_BY, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.CREATED_BY),
                decode( p_dest_resource_rec.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.LAST_UPDATE_LOGIN),
                decode( l_terr_ids_tbl(i), FND_API.G_MISS_NUM, NULL,l_terr_ids_tbl(i)),
                decode( p_dest_resource_rec.RESOURCE_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.RESOURCE_ID),
                decode( p_dest_resource_rec.GROUP_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.GROUP_ID),
                decode( p_dest_resource_rec.RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.RESOURCE_TYPE),
                decode( p_dest_resource_rec.ROLE, FND_API.G_MISS_CHAR, NULL, p_dest_resource_rec.ROLE),
                decode( p_dest_resource_rec.PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.PRIMARY_CONTACT_FLAG),
                decode( p_dest_resource_rec.START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.START_DATE_ACTIVE),
                decode( p_dest_resource_rec.END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_dest_resource_rec.END_DATE_ACTIVE),
                decode( p_dest_resource_rec.FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL,p_dest_resource_rec.FULL_ACCESS_FLAG),
                decode( p_dest_resource_rec.ORG_ID, FND_API.G_MISS_NUM, NULL,p_dest_resource_rec.ORG_ID)
           );

                 --ARPATEL: 11/06/2003 BUG#2798581 START
                FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
                 INSERT INTO JTF_TERR_RSC_ACCESS_ALL(
                 TERR_RSC_ACCESS_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 TERR_RSC_ID,
                 ACCESS_TYPE,
                 ORG_ID
                )
                SELECT
                     JTF_TERR_RSC_ACCESS_s.nextval,
                     SYSDATE,
                     G_USER_ID,
                     SYSDATE,
                     G_USER_ID,
                     G_LOGIN_ID,
                     ntra.terr_rsc_id, -- needs to be the newly created terr_rsc_id from above
                     raa.access_type,
                     p_dest_resource_rec.ORG_ID
                FROM
                      JTF_TERR_RSC_ACCESS_ALL raa
                     ,JTF_TERR_RSC_ALL tra -- use old record to find access_type
                     ,JTF_TERR_RSC_ALL ntra -- pick up new records from above
                WHERE
                      tra.terr_rsc_id = NVL(raa.terr_rsc_id, tra.terr_rsc_id)
                AND   tra.resource_id = p_source_resource_rec.resource_id
                AND   ntra.terr_id = tra.terr_id
                AND   ntra.resource_id = p_dest_resource_rec.resource_id
                AND   tra.terr_id = l_terr_ids_tbl(i)
                 ;

               --UPDATE old rsc to soft delete - end date
               FORALL i IN l_terr_ids_tbl.FIRST..l_terr_ids_tbl.LAST
                UPDATE jtf_terr_rsc_all j
                SET j.end_date_active = SYSDATE
                WHERE j.resource_id = p_source_resource_rec.RESOURCE_ID
                  AND j.resource_type = p_source_resource_rec.RESOURCE_TYPE
                  AND j.terr_id = l_terr_ids_tbl(i);

            --ARPATEL: 11/06/2003 BUG#2798581 END


            END IF;

        END IF;

    --dbms_output.put_line('Value of l_terr_ids_tbl.first='||TO_CHAR(l_terr_ids_tbl.first));
    --dbms_output.put_line('Value of l_terr_ids_tbl.last='||TO_CHAR(l_terr_ids_tbl.last));

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TERRITORY_END_MSG');
         fnd_message.set_name ('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --dbms_output.put_line('Transfer_Resource_Territories: Exiting API');
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output.put_line('Transfer_Resource_Territories: FND_API.G_EXC_ERROR');
         ROLLBACK TO TRANSFER_TERR_RES;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Transfer_Resource_Territories: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO TRANSFER_TERR_RES;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Transfer_Resource_Territories PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO TRANSFER_TERR_RES;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (
              g_pkg_name,
              'Error inside Transfer_Resource_Territories ' || sqlerrm);
         END IF;

  END Transfer_Resource_Territories;

END JTF_TERRITORY_RESOURCE_PVT;


/
