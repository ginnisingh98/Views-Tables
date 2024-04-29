--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_PVT" AS
/* $Header: jtfvterb.pls 120.3.12010000.3 2009/12/17 06:04:17 ppillai ship $ */
--    ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERRITORY_PVT
--  ---------------------------------------------------
--  PURPOSE
--    Joint task force core territory manager private api's.
--    This package is defins all private API for manupulating
--    territory related information in JTF Territory tables.
--
--  Procedures:
--    (see below for specification)
--
--  NOTES
--    This package is publicly available for use
--  HISTORY
--    06/09/99    VNEDUNGA     Created
--    11/29/99    VNEDUNGA     Fixing update_territory_record API
--                             for application_short_name
--    01/14/00    VNEDUNGA     PASSING ORG_ID to terr_api table handler
--    01/31/00    VNEDUNGA     Adding overlap_exists function
--    03/09/00    VNEDUNGA     Changing to validaton routines and
--                             adding FND_MESSAGE calls
--    04/04/00	  EIHSU	       Added Gen_Duplicate_Territory and relevant procs
--    04/20/94    VNEDUNGA     Fixing the qualifer validation from returning
--                             multiple rows
--    05/01/00    VNEDUNGA     Adding currency convertion routines
--    05/01/00    VNEDUNGA     changing the Delete_Territory API to use
--                             direct DELETE DMLs. Also changed the API
--                             to delete the whole hierarchy
--    05/03/00    VNEDUNGA     Eliminating ref to _all tables
--    06/14/00    VNEDUNGA     Changing the overlap exists function and
--                             added rownum < 2 to function to return desc
--    07/20/00    JDOCHERT     Changed as follows in Create_territory_record
--                             as this meant that a terr_id passed
--                             into Create API was ignored:
--                             l_terr_id := 0;
--                             TO
--                             l_terr_id                     NUMBER := P_TERR_ALL_REC.TERR_ID;
--    08/08/00    jdochert     Removing if statement that causes error when LOW_VALUE_CHAR = FND_API.G_MISS_CHAR
--                             and ID_USED_FLAG = 'Y": this was an error in logic.
--    08/21/00    jdochert     Changing overlap_exists procedure to do an UPPER on comparison operator
--    09/09/00    jdochert     Added Unique validation for JTF_TERR_USGS_ALL + JTF_TERR_QTYPE_USGS_ALL
--    09/17/00    jdochert     BUG#1408610 FIX
--
--    10/04/00    jdochert     Added validation for NUM_WINNERS
--    11/02/00    jdochert     Added processing for NUM_QUAL
--    12/07/00    jdochert
--    04/05/01    ARPATEL      Added processing for copy hierarchy in proc 'Copy Territory'
--    04/12/01    jdochert     Added PROCEDURE chk_num_copy_terr
--    04/20/01    ARPATEL      Added Concurrent_Copy_Territory procedure for concurrent requests
--    04/28/01    ARPATEL      Added FUNCTION conc_req_copy_terr returning concurrent request ID.
--    05/22/01	  ARPATEL      Added CNR_GROUP_ID to cursors selecting from JTF_TERR_VALUES.
--    07/13/01    ARPATEL      Added validation for territory templates without 'DYNAMIC QUALIFIERS'
--    09/06/01    ARPATEL      Added VALUE1_ID, VALUE2_ID AND VALUE3_ID to JTF_TERR_VALUES cursors
--                             and procedure create_new_terr_value_rec
--    09/18/01    ARPATEL      Removed debug message level checks to enable form to pick up these messages
--    12/03/04    achanda      Added value4_id : bug # 3726007
--
--
--  End of Comments
--

-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERRITORY_PVT';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfvterb.pls';


   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;
   /* ARPATEL 041801 */
   G_Debug           BOOLEAN  := FALSE;

  /*-------------------*/
  /* TYPE declarations */
  /*-------------------*/

  /* stores info about each qualifier used in mass generation of templates
  ** from a template territory
  ** start_record stores a pointer to the first record for the qualifier
  ** in g_values_table.
  ** num_records stores the number of values for the qualifier in
  ** g_values_table.
  ** current_record stores pointer to the current record used during
  ** the generation process.
  */
  TYPE Dynamic_Qual_Rec_Type IS RECORD (
     Rowid                         VARCHAR2(50) ,   -- := FND_API.G_MISS_CHAR,
     TERR_QUAL_ID                  NUMBER       ,   -- := FND_API.G_MISS_NUM,
     LAST_UPDATE_DATE              DATE         ,   -- := FND_API.G_MISS_DATE,
     LAST_UPDATED_BY               NUMBER       ,   -- := FND_API.G_MISS_NUM,
     CREATION_DATE                 DATE         ,   -- := FND_API.G_MISS_DATE,
     CREATED_BY                    NUMBER       ,   -- := FND_API.G_MISS_NUM,
     LAST_UPDATE_LOGIN             NUMBER       ,   -- := FND_API.G_MISS_NUM,
     TERR_ID                       NUMBER       ,   -- := FND_API.G_MISS_NUM,
     QUAL_USG_ID                   NUMBER       ,   -- := FND_API.G_MISS_NUM,
     USE_TO_NAME_FLAG              VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
     GENERATE_FLAG                 VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
     OVERLAP_ALLOWED_FLAG          VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
     QUALIFIER_MODE                VARCHAR2(30) ,   -- := FND_API.G_MISS_CHAR,
     ORG_ID                        NUMBER           -- := FND_API.G_MISS_NUM
   , START_RECORD                  NUMBER
   , NUM_RECORDS                   NUMBER
   , CURRENT_VALUE_SET             NUMBER
   , CURRENT_RECORD                NUMBER );

  TYPE Dynamic_Qual_Tbl_Type IS TABLE OF Dynamic_Qual_Rec_Type
                               INDEX BY BINARY_INTEGER;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of
--                following Territory Header, Territory Qualifier, terr Usages,
--                qualifier type usages Territory Qualifier Values
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--      p_validation_level            NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Id                     NUMBER
--      x_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      x_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      x_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--    Business Rules:
--      1. Make sure terr usages and terr qual usages are specified.
--      2. Make sure the qualifer matches the qualifer type usage
--      3. Make sure value records exists for every qualifer
--
--    End of Comments
--
 PROCEDURE Create_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  x_Return_Status               OUT NOCOPY VARCHAR2,
  x_Msg_Count                   OUT NOCOPY NUMBER,
  x_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
  p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl,
  x_Terr_Id                     OUT NOCOPY NUMBER,
  x_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
  x_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
  x_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
  x_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type)
 AS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Territory';
      l_api_version_number        CONSTANT NUMBER       := 1.0;

      -- Status Local Variables
      l_return_status             VARCHAR2(1);  -- Return value from procedures
      l_return_status_full        VARCHAR2(1);  -- Calculated return status from                                                -- all return values

      l_terr_all_out_rec          Terr_ALL_OUT_REC_TYPE;
      l_Terr_Usgs_Out_Tbl         Terr_Usgs_Out_Tbl_Type;
      l_Terr_QualTypeUsgs_Out_Tbl Terr_QualTypeUsgs_Out_Tbl_Type;
      l_Terr_Qual_Out_Tbl         Terr_Qual_Out_Tbl_Type;
      l_Terr_Values_Out_Tbl       Terr_Values_Out_Tbl_Type;

      l_Terr_Qual_Tbl             Terr_Qual_Tbl_Type;
      l_Terr_Values_Tbl           Terr_Values_Tbl_Type;
      l_Terr_Id                   NUMBER   := 0;
      l_Terr_Qual_Id              NUMBER   := 0;
      l_Qual_Counter              NUMBER   := 1;
      l_QualVal_Counter           NUMBER   := 0;
      l_counter                   NUMBER   := 0;
      l_index                     NUMBER   := 0;

      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);
      L_SHORT_NAME                VARCHAR2(15);

   BEGIN
      --dbms_output('Create_Territory PVT: Entering API -' || G_APP_SHORT_NAME);

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TERRITORY_PVT;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      --Check whether the Usage records are specified
      If (p_Terr_Usgs_Tbl.COUNT  = 0 ) Then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_USAGE');
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         raise FND_API.G_EXC_ERROR;
      END IF;
      --
      --dbms_output('About to check p_Terr_Values_Tbl.count - ' || to_char(p_Terr_Values_Tbl.count));
      --
      /*
      -- Check whether the Terr Transaction Types are specified.
      If (p_Terr_QualTypeUsgs_Tbl.COUNT  = 0 and
          p_Terr_All_Rec.ESCALATION_TERRITORY_FLAG <> 'Y') Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_QUAL_USG');
             FND_MSG_PUB.ADD;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          raise FND_API.G_EXC_ERROR;
      END IF;
      */
      --
      --
      -- API body
      --
      --
      -- If incomming data is good
      -- Start creating territory related records
      --
      --dbms_output('Create_Territory PVT: Before Calling Create_Territory_Header');
      --
      Create_Territory_Header(P_Api_Version_Number          =>  P_Api_Version_Number,
                              P_Init_Msg_List               =>  P_Init_Msg_List,
                              P_Commit                      =>  P_Commit,
                              p_validation_level            =>  p_validation_level,
                              P_Terr_All_Rec                =>  P_Terr_All_Rec,
                              P_Terr_Usgs_Tbl               =>  P_Terr_Usgs_Tbl,
                              --P_Terr_QualTypeUsgs_Tbl       =>  P_Terr_QualTypeUsgs_Tbl,
                              X_Return_Status               =>  l_Return_Status,
                              X_Msg_Count                   =>  l_Msg_Count,
                              X_Msg_Data                    =>  l_Msg_Data,
                              X_Terr_All_Out_Rec            =>  l_Terr_All_Out_Rec,
                              X_Terr_Usgs_Out_Tbl           =>  l_Terr_Usgs_Out_Tbl,
                              X_Terr_QualTypeUsgs_Out_Tbl   =>  l_Terr_QualTypeUsgs_Out_Tbl
                              );

      --Save the territory id for later use
      l_terr_id := l_Terr_All_Out_Rec.terr_id;
      X_terr_id := l_Terr_All_Out_Rec.terr_id;

      x_Terr_Usgs_Out_Tbl           := l_Terr_Usgs_Out_Tbl;
      x_Terr_QualTypeUsgs_Out_Tbl   := l_Terr_QualTypeUsgs_Out_Tbl;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         X_Return_Status := l_return_status;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

     --dbms_output.put_line('Value of  x_return_status='|| x_return_status);

      --Check whether the Qualifer records are specified
      --If (p_Terr_Qual_Tbl.count  = 0 ) Then
      --   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      --      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_QUAL');
      --      FND_MSG_PUB.ADD;
      --   END IF;
      --   x_return_status := FND_API.G_RET_STS_ERROR;
      --   raise FND_API.G_EXC_ERROR;
      --END IF;
      --

      IF (p_Terr_Qual_Tbl.COUNT > 0 ) THEN

         For l_Qual_Counter IN p_Terr_Qual_Tbl.first .. p_Terr_Qual_Tbl.count LOOP
             --
             l_Terr_Qual_Tbl(1) := p_Terr_Qual_Tbl(l_Qual_Counter);

             --
             --dbms_output('Create_Territory PVT: Inside the l_Qual_Counter LOOP');
             --dbms_output('Create_Territory PVT: Before calling create terr qualifier');
             --
             -- Create the territory qualifier record
                --
             --dbms_output('Create_Territory PVT: Before calling  Create_Terr_Qualifier');
             Create_Terr_Qualifier(P_Api_Version_Number          =>  P_Api_Version_Number,
                                   P_Init_Msg_List               =>  P_Init_Msg_List,
                                   P_Commit                      =>  P_Commit,
                                   p_validation_level            =>  p_validation_level,
                                   P_Terr_Id                     =>  l_terr_id,
                                   P_Terr_Qual_Tbl               =>  l_Terr_Qual_Tbl,
                                   X_Return_Status               =>  l_Return_Status,
                                   X_Msg_Count                   =>  l_Msg_Count,
                                   X_Msg_Data                    =>  l_Msg_Data,
                                   X_Terr_Qual_Out_Tbl           =>  l_Terr_Qual_Out_Tbl);

             --Save the output status
             x_Terr_Qual_Out_Tbl(nvl(x_Terr_Qual_Out_Tbl.first, 0)+1)  := l_Terr_Qual_Out_Tbl(1);
             -- Save the terr qualifier id
             l_Terr_Qual_Id := l_Terr_Qual_Out_Tbl(1).terr_qual_id;

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                X_Return_Status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             -- JDOCHERT 07/27 Territory Values no longer required
             IF (p_Terr_Values_Tbl.COUNT  > 0) THEN

                 l_terr_values_tbl.DELETE;
                 l_index := 0;

                 -- Save the qual value records for a particular qualifer into
                 -- local table
                 FOR l_QualVal_Counter IN p_Terr_Values_Tbl.FIRST .. p_Terr_Values_Tbl.LAST LOOP
                     -- Initalize the table
                     -- dbms_output('Create_Territory PVT: Inside l_QualVal_Counter loop - ' || to_char(l_QualVal_Counter) );
                     -- If the table index changes, then skip the loop
                     If p_Terr_Values_Tbl(l_QualVal_Counter).qualifier_tbl_index = l_Qual_Counter Then
                        l_index := l_index + 1;
                        --dbms_output('Create_Territory PVT: Found values - ' || to_char(l_Qual_Counter) || ' Index - ' || to_char(l_index) );
                        l_Terr_Values_Tbl(l_index) :=  p_Terr_Values_Tbl(l_QualVal_Counter);
                     End If;

                 END LOOP;

                 --Remove the qualifier if no values are specified.
                 BEGIN
                    IF l_index = 0 THEN
                        JTF_TERR_QUAL_PKG.Delete_Row(x_terr_qual_id  => l_Terr_Qual_Id );
                        FND_MESSAGE.Set_Name('JTF', 'JTY_TERR_MISSING_TERR_VALUES');
                        FND_MESSAGE.Set_Token('QUAL_USG_ID', to_char(l_Terr_Qual_Tbl(1).QUAL_USG_ID));
                        FND_MSG_PUB.ADD;
                     End If;
                 END;

                 IF  (l_terr_values_tbl.COUNT > 0) THEN

                     --dbms_output('Create_Territory PVT: Before calling create terr qualifier values');
                     --
                     l_Terr_Values_Out_Tbl.Delete;
                     Create_Terr_Value( P_Api_Version_Number  =>  P_Api_Version_Number,
                                        P_Init_Msg_List       =>  P_Init_Msg_List,
                                        P_Commit              =>  P_Commit,
                                        p_validation_level    =>  p_validation_level,
                                        P_Terr_Id             =>  l_terr_id,
                                        p_terr_qual_id        =>  l_Terr_Qual_Id,
                                        P_Terr_Value_Tbl      =>  l_Terr_Values_Tbl,
                                        X_Return_Status       =>  l_Return_Status,
                                        X_Msg_Count           =>  l_Msg_Count,
                                        X_Msg_Data            =>  l_Msg_Data,
                                        X_Terr_Value_Out_Tbl  =>  l_Terr_Values_Out_Tbl);
                     --
                     l_index := x_Terr_Values_Out_Tbl.COUNT;
                     --
                     -- Save the OUT parameters to the original API out parametrs
                     For l_Counter IN l_Terr_Values_Out_Tbl.FIRST .. l_Terr_Values_Out_Tbl.LAST LOOP
                         l_index := l_index + 1;
                         x_Terr_Values_Out_Tbl(l_index) := l_Terr_Values_Out_Tbl(l_counter);
                     End LOOP;

                 END IF;

                 --
                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    X_Return_Status := l_return_status;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

             END IF; /*  IF  (l_terr_values_tbl.COUNT > 0) */

              -- Reset the table and records to G_MISS_RECORD and G_MISS_TABLE
             l_Terr_Qual_Tbl    := G_MISS_TERR_QUAL_TBL;
             l_Terr_Values_Tbl  := G_MISS_TERR_VALUES_TBL;
             --
         End LOOP;

      END IF;   /* p_Terr_Qual_Tbl.count > 0 */

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         X_Return_Status := l_return_status;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --If the program reached here, that mena evry thing went smooth
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
         --dbms_output('Create_Territory PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERRITORY_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Create_Territory PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Create_Territory PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
   --
   END Create_Territory;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Territory
---    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                Territory Header, Territory Qualifier,
--                Territory Qualifier Values and Resources.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
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
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
PROCEDURE Delete_Territory
 (p_Api_Version_Number      IN  NUMBER,
  p_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
  p_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_Return_Status           OUT NOCOPY VARCHAR2,
  X_Msg_Count               OUT NOCOPY NUMBER,
  X_Msg_Data                OUT NOCOPY VARCHAR2,
  p_Terr_Id                 IN  NUMBER)
AS
  v_Terr_Id                 NUMBER := p_Terr_Id;

  --Declare cursor to get usages
  Cursor C_Terr IS
         select terr_id from jtf_terr_all
         connect by  parent_territory_id = prior terr_id AND TERR_ID <> 1
         start with terr_id = v_Terr_Id;

  CURSOR C_TERR_QUAL_IDS ( p_Terr_Id IN NUMBER) IS
         SELECT TERR_QUAL_ID
         FROM JTF_TERR_QUAL_ALL
         WHERE TERR_ID = p_Terr_Id;



  l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Territory';
  l_api_version_number        CONSTANT NUMBER       := 1.0;

  l_return_status             VARCHAR2(1);
  l_Terr_Value_Id             NUMBER;
  l_Terr_Qual_Id              NUMBER;
  l_Terr_Usg_Id               NUMBER;
  l_Terr_Qual_Type_Usg_Id     NUMBER;
  l_Terr_Id                   NUMBER;

BEGIN
--
      --dbms_output('Delete_Territory PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT Delete_Territory_Pvt;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Get all the Territories in the Hierarchy
      FOR c in c_Terr LOOP
      --
         BEGIN
              OPEN C_TERR_QUAL_IDS(c.Terr_Id);
              LOOP
                  FETCH C_TERR_QUAL_IDS INTO l_terr_qual_id;
                  EXIT WHEN C_TERR_QUAL_IDS%NOTFOUND;
                  --Delete Territory Values
                  DELETE from JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID = l_terr_qual_id;
              END LOOP;
              CLOSE C_TERR_QUAL_IDS;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
               CLOSE C_TERR_QUAL_IDS;
           WHEN OTHERS THEN
               CLOSE C_TERR_QUAL_IDS;
         END;

          --Delete Territory Qualifer records
          DELETE from JTF_TERR_QUAL_ALL WHERE TERR_ID = c.Terr_Id;

          --Delete Territory qual type usgs
          DELETE from JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID = c.Terr_Id;

          --Delete Territory usgs
          DELETE from JTF_TERR_USGS_ALL WHERE TERR_ID = c.Terr_Id;

          --Delete Territory Resource Access
          DELETE from JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
          ( SELECT TERR_RSC_ID FROM JTF_TERR_RSC_ALL WHERE TERR_ID = c.Terr_Id );

          -- Delete the Territory Resource records
          DELETE from JTF_TERR_RSC_ALL Where TERR_ID = c.Terr_Id;

          --Delete Territory record
          DELETE from JTF_TERR_ALL WHERE TERR_ID = c.Terr_Id;

      --
      END LOOP;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
      --dbms_output('Delete_Territory PVT: Exiting API');

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Delete_Territory PVT: FND_API.G_EXC_ERROR');
         --
         ROLLBACK TO DELETE_TERRITORY_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Delete_Territory PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO DELETE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Delete_Territory PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO DELETE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
--
END Delete_Territory;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Territory
--    Type      : PUBLIC
--    Function  : To update existINg Territories - which includes updates to the following tables
--                Territory Header, Territory Qualifier, terr Usages, qualifier type usages
--                Territory Qualifier Values and Assign Resources
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--      p_validation_level            NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_Terr_All_Out_Rec            Terr_All_Out_Rec
--      X_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      X_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      X_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
--  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
--  p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
--  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
--  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
--  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
--  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
--  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
--  X_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type
)
AS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Territory';
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_return_status             VARCHAR2(1);
BEGIN
      --dbms_output('Update_Territory PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TERRITORY_PVT;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      --Check whether the Territory_Id is Valid
      -- Parent Terr ID can't be null.
      If (p_Terr_All_Rec.TERR_ID is null) OR
         (p_Terr_All_Rec.TERR_ID = FND_API.G_MISS_NUM)
      Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
             FND_MESSAGE.Set_Token('COL_NAME', 'TERR_ID' );
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      If p_Terr_All_Rec.Terr_Id <> FND_API.G_MISS_NUM     Then
         --dbms_output('Update_Territory PVT: Before Calling Update_territory_Record');
         Update_territory_Record( P_Api_Version_Number          =>  P_Api_Version_Number,
                                  P_Init_Msg_List               =>  P_Init_Msg_List,
                                  P_Commit                      =>  P_Commit,
                                  p_validation_level            =>  p_validation_level,
                                  P_Terr_All_Rec                =>  p_Terr_All_Rec,
                                  X_Return_Status               =>  l_Return_Status,
                                  X_Msg_Count                   =>  x_Msg_Count,
                                  X_Msg_Data                    =>  x_Msg_Data,
                                  X_Terr_All_Out_rec            => X_Terr_All_Out_Rec);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      --
      End If;

     /* Usage can't be updated in R12. -- VPALLE
      -- Check whether ant data is passed for update of value table
     If P_Terr_Usgs_Tbl.Count > 0 Then
      --
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_QualType_Usage');
         Update_Territory_Usages( P_Api_Version_Number          =>  P_Api_Version_Number,
                                  P_Init_Msg_List               =>  P_Init_Msg_List,
                                  P_Commit                      =>  P_Commit,
                                  p_validation_level            =>  p_validation_level,
                                  P_Terr_Usgs_Tbl               =>  p_Terr_Usgs_Tbl,
                                  X_Return_Status               =>  l_Return_Status,
                                  X_Msg_Count                   =>  x_Msg_Count,
                                  X_Msg_Data                    =>  x_Msg_Data,
                                  X_Terr_Usgs_Out_Tbl           =>  X_Terr_Usgs_Out_Tbl);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
      --
      End If;
      */

      /* Transaction type usages are created based on the territory type while territory creation.
         As the Territory Type associated with a territory can't be updated in R12, we can't update
         Transaction Type usages. --VPALLE
      -- Check whether ant data is passed for update of value table
      If P_Terr_QualTypeUsgs_Tbl.Count > 0 Then
      --
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_QualType_Usage');
         Update_Terr_QualType_Usage( P_Api_Version_Number          =>  P_Api_Version_Number,
                                     P_Init_Msg_List               =>  P_Init_Msg_List,
                                     P_Commit                      =>  P_Commit,
                                     p_validation_level            =>  p_validation_level,
                                     P_Terr_QualTypeUsgs_Tbl       =>  p_Terr_QualTypeUsgs_Tbl,
                                     X_Return_Status               =>  l_Return_Status,
                                     X_Msg_Count                   =>  x_Msg_Count,
                                     X_Msg_Data                    =>  x_Msg_Data,
                                     X_Terr_QualTypeUsgs_Out_Tbl   => X_Terr_QualTypeUsgs_Out_Tbl);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      --
      End If;
      */

      -- Check whether ant data is passed for update of Qualifier table
 /*     If P_Terr_Qual_Tbl.Count > 0 Then
      --
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_Qualifier');
         Update_Terr_Qualifier( P_Api_Version_Number          =>  P_Api_Version_Number,
                                P_Init_Msg_List               =>  P_Init_Msg_List,
                                P_Commit                      =>  P_Commit,
                                p_validation_level            =>  p_validation_level,
                                P_Terr_Qual_Tbl               =>  p_Terr_Qual_Tbl,
                                X_Return_Status               =>  l_Return_Status,
                                X_Msg_Count                   =>  x_Msg_Count,
                                X_Msg_Data                    =>  x_Msg_Data,
                                X_Terr_Qual_Out_Tbl           => X_Terr_Qual_Out_Tbl);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      --
      End If;

      -- Check whether ant data is passed for update of value table
      If P_Terr_Values_Tbl.Count > 0 Then
         --dbms_output('Update_Territory PVT: Before Calling Update_Terr_Value');
         Update_Terr_Value( P_Api_Version_Number          =>  P_Api_Version_Number,
                            P_Init_Msg_List               =>  P_Init_Msg_List,
                            P_Commit                      =>  P_Commit,
                            p_validation_level            =>  p_validation_level,
                            P_Terr_Value_Tbl              =>  p_Terr_Values_Tbl,
                            X_Return_Status               =>  l_Return_Status,
                            X_Msg_Count                   =>  x_Msg_Count,
                            X_Msg_Data                    =>  x_Msg_Data,
                            X_Terr_Value_Out_Tbl          =>  X_Terr_Values_Out_Tbl);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      End If;
      --
*/
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
      --dbms_output('Update_Territory PVT: Exiting API');

  --
  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Update_Territory PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO UPDATE_TERRITORY_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Update_Territory PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO UPDATE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Update_Territory PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO UPDATE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
--
END Update_Territory;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Deactivate_Territory
--    Type      : PUBLIC
--    Function  : To deactivate Territories - this API also deactivates
--                any sub-territories of this territory.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--      p_validation_level         NUMBER                           FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Deactivate_Territory
 (p_api_version_number      IN NUMBER,
  p_INit_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  P_terr_Id                 IN NUMBER)
AS
        Cursor C_GetTerritory(l_terr_id Number) IS
          Select Rowid,
                 TERR_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 APPLICATION_SHORT_NAME,
                 NAME,
                 ENABLED_FLAG,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 PLANNED_FLAG,
                 PARENT_TERRITORY_ID,
                 TERRITORY_TYPE_ID,
                 TEMPLATE_TERRITORY_ID,
                 TEMPLATE_FLAG,
                 ESCALATION_TERRITORY_ID,
                 ESCALATION_TERRITORY_FLAG,
                 OVERLAP_ALLOWED_FLAG,
                 RANK,
                 DESCRIPTION,
                 UPDATE_FLAG,
                 AUTO_ASSIGN_RESOURCES_FLAG,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ORG_ID,
                 NUM_WINNERS,
                 NUM_QUAL
          From  JTF_TERR_ALL
          Where TERR_ID = l_terr_id
          For   Update NOWAIT;

      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Deactivate_territory';
      l_api_version_number      CONSTANT NUMBER   := 1.0;

      l_rowid                   VARCHAR2(50);
      l_return_status           VARCHAR2(1);
      l_ref_terr_all_rec        terr_all_rec_type;

BEGIN
      --dbms_output('Deactivate_Territory PVT: Entering API');

      -- Standard Start of API savepoint
      SAVEPOINT DEACTIVATE_TERRITORY_PVT;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --dbms_output('Deactivate_Territory PVT: opening cursor C_GetTerrTypeUsage');
      OPEN C_GetTerritory( P_Terr_Id);
      FETCH C_GetTerritory into
            l_Rowid,
            l_ref_terr_all_rec.TERR_ID,
            l_ref_terr_all_rec.LAST_UPDATE_DATE,
            l_ref_terr_all_rec.LAST_UPDATED_BY,
            l_ref_terr_all_rec.CREATION_DATE,
            l_ref_terr_all_rec.CREATED_BY,
            l_ref_terr_all_rec.LAST_UPDATE_LOGIN,
            l_ref_terr_all_rec.REQUEST_ID,
            l_ref_terr_all_rec.PROGRAM_APPLICATION_ID,
            l_ref_terr_all_rec.PROGRAM_ID,
            l_ref_terr_all_rec.PROGRAM_UPDATE_DATE,
            l_ref_terr_all_rec.APPLICATION_SHORT_NAME,
            l_ref_terr_all_rec.NAME,
            l_ref_terr_all_rec.ENABLED_FLAG,
            l_ref_terr_all_rec.START_DATE_ACTIVE,
            l_ref_terr_all_rec.END_DATE_ACTIVE,
            l_ref_terr_all_rec.PLANNED_FLAG,
            l_ref_terr_all_rec.PARENT_TERRITORY_ID,
            l_ref_terr_all_rec.TERRITORY_TYPE_ID,
            l_ref_terr_all_rec.TEMPLATE_TERRITORY_ID,
            l_ref_terr_all_rec.TEMPLATE_FLAG,
            l_ref_terr_all_rec.ESCALATION_TERRITORY_ID,
            l_ref_terr_all_rec.ESCALATION_TERRITORY_FLAG,
            l_ref_terr_all_rec.OVERLAP_ALLOWED_FLAG,
            l_ref_terr_all_rec.RANK,
            l_ref_terr_all_rec.DESCRIPTION,
            l_ref_terr_all_rec.UPDATE_FLAG,
            l_ref_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG,
            l_ref_terr_all_rec.ATTRIBUTE_CATEGORY,
            l_ref_terr_all_rec.ATTRIBUTE1,
            l_ref_terr_all_rec.ATTRIBUTE2,
            l_ref_terr_all_rec.ATTRIBUTE3,
            l_ref_terr_all_rec.ATTRIBUTE4,
            l_ref_terr_all_rec.ATTRIBUTE5,
            l_ref_terr_all_rec.ATTRIBUTE6,
            l_ref_terr_all_rec.ATTRIBUTE7,
            l_ref_terr_all_rec.ATTRIBUTE8,
            l_ref_terr_all_rec.ATTRIBUTE9,
            l_ref_terr_all_rec.ATTRIBUTE10,
            l_ref_terr_all_rec.ATTRIBUTE11,
            l_ref_terr_all_rec.ATTRIBUTE12,
            l_ref_terr_all_rec.ATTRIBUTE13,
            l_ref_terr_all_rec.ATTRIBUTE14,
            l_ref_terr_all_rec.ATTRIBUTE15,
            l_ref_terr_all_rec.ORG_ID,
            l_ref_terr_all_rec.NUM_WINNERS,
            l_ref_terr_all_rec.NUM_QUAL;

       If ( C_GetTerritory%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token('INFO', 'TERRITORY', FALSE);
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       End if;
       CLOSE C_GetTerritory;

       --dbms_output('Deactivate_Territory PVT: Before Calling JTF_TERR_PKG.Update_Row');
       JTF_TERR_PKG.Update_Row(x_rowid                 => l_rowid,
                              x_terr_id                    => p_terr_id,
                              x_last_update_date           => l_ref_terr_all_rec.LAST_UPDATE_DATE,
                              x_last_updated_by            => l_ref_terr_all_rec.LAST_UPDATED_BY,
                              x_creation_date              => l_ref_terr_all_rec.CREATION_DATE,
                              x_created_by                 => l_ref_terr_all_rec.CREATED_BY,
                              x_last_update_login          => l_ref_terr_all_rec.LAST_UPDATE_LOGIN,
                              x_request_id                 => null,
                              x_program_application_id     => null,
                              x_program_id                 => null,
                              x_program_update_date        => null,
                              x_application_short_name     => l_ref_terr_all_rec.APPLICATION_SHORT_NAME,
                              x_name                       => l_ref_terr_all_rec.name,
                              --x_enabled_flag               => l_ref_terr_all_rec.enabled_flag,
                              x_start_date_active          => l_ref_terr_all_rec.start_date_active,
                              x_end_date_active            => (sysdate -1),
                              x_planned_flag               => l_ref_terr_all_rec.planned_flag,
                              x_parent_territory_id        => l_ref_terr_all_rec.parent_territory_id,
                              -- x_territory_type_id          => l_ref_terr_all_rec.territory_type_id,
                              x_template_territory_id      => l_ref_terr_all_rec.template_territory_id,
                              x_template_flag              => l_ref_terr_all_rec.template_flag,
                              x_escalation_territory_id    => l_ref_terr_all_rec.escalation_territory_id,
                              x_escalation_territory_flag  => l_ref_terr_all_rec.escalation_territory_flag,
                              x_overlap_allowed_flag       => l_ref_terr_all_rec.overlap_allowed_flag,
                              x_rank                       => l_ref_terr_all_rec.rank,
                              x_description                => l_ref_terr_all_rec.description,
                              x_update_flag                => l_ref_terr_all_rec.update_flag,
                              x_auto_assign_resources_flag => l_ref_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG,
                              x_attribute_category         => l_ref_terr_all_rec.attribute_category,
                              x_attribute1                 => l_ref_terr_all_rec.attribute1,
                              x_attribute2                 => l_ref_terr_all_rec.attribute2,
                              x_attribute3                 => l_ref_terr_all_rec.attribute3,
                              x_attribute4                 => l_ref_terr_all_rec.attribute4,
                              x_attribute5                 => l_ref_terr_all_rec.attribute5,
                              x_attribute6                 => l_ref_terr_all_rec.attribute6,
                              x_attribute7                 => l_ref_terr_all_rec.attribute7,
                              x_attribute8                 => l_ref_terr_all_rec.attribute8,
                              x_attribute9                 => l_ref_terr_all_rec.attribute9,
                              x_attribute10                => l_ref_terr_all_rec.attribute10,
                              x_attribute11                => l_ref_terr_all_rec.attribute11,
                              x_attribute12                => l_ref_terr_all_rec.attribute12,
                              x_attribute13                => l_ref_terr_all_rec.attribute13,
                              x_attribute14                => l_ref_terr_all_rec.attribute14,
                              x_attribute15                => l_ref_terr_all_rec.attribute15,
                              x_org_id                     => l_ref_terr_all_rec.ORG_ID,
                              x_num_winners                => l_ref_terr_all_rec.NUM_WINNERS,
                              x_num_qual                   => l_ref_terr_all_rec.NUM_QUAL );

      X_return_status    := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
      --dbms_output('Deactivate_Territory PVT: Exiting API');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Deactivate_Territory PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO DEACTIVATE_TERRITORY_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Deactivate_Territory PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO DEACTIVATE_TERRITORY_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

     WHEN OTHERS THEN
          --dbms_output('Deactivate_Territory PVT: OTHERS - ' || SQLERRM);
          ROLLBACK TO DEACTIVATE_TERRITORY_PVT;
          X_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                      'Others exception inside Deactivate_Territory'
                                      || sqlerrm);
          END IF;
END Deactivate_Territory;


--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory_Header
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of following
--                Territory Header, Territory Usages, Territory qualifier type usages
--                table.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Api_Version_Number          NUMBER
--      P_Terr_All_Rec                Terr_All_Rec_Type                := G_Miss_Terr_All_Rec
--      P_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl
--      P_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      P_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      P_Commit                      VARCHAR2                         := FND_API.G_FALSE
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_Terr_All_Out_Rec            Terr_All_Out_Rec
--      X_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Territory_Header
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
 -- P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type)
AS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Territory_Header';
  l_rowid                       ROWID;
  l_return_status               VARCHAR2(1);
  l_Terr_id                     NUMBER;
  l_terr_usg_id                 NUMBER;
  l_terr_qual_type_usg_id       NUMBER;
  l_Terr_Usgs_Tbl_Count         NUMBER   := P_Terr_Usgs_Tbl.Count;
 -- l_Terr_QualTypeUsgs_Tbl_Count NUMBER   := P_Terr_QualTypeUsgs_Tbl.Count;
  l_Counter                     NUMBER;
  l_Terr_All_Out_Rec            Terr_All_Out_Rec_Type;
  l_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl_Type;
  l_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl_Type;
  l_qual_type_usg_id            NUMBER ;
  l_dummy                       NUMBER;
  l_iterator                    NUMBER;
  p_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;

  CURSOR C_QUAL_TYPE_USG_ID (P_terr_type_id NUMBER)
  is
  SELECT QUAL_TYPE_USG_ID from JTF_TYPE_QTYPE_USGS_ALL WHERE terr_type_id = P_terr_type_id ;

BEGIN
   --dbms_output('Create_Territory_Header PVT: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
    -- Check if the Parent Terr ID is valid for the given source.
    BEGIN
        IF ( p_terr_all_rec.PARENT_TERRITORY_ID IS NOT NULL
             AND p_terr_all_rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM
             AND p_terr_all_rec.PARENT_TERRITORY_ID <> 1 ) THEN

            SELECT 1
              INTO l_dummy
              FROM  jtf_terr_usgs_all jtua
             WHERE jtua.terr_id      = p_terr_all_rec.PARENT_TERRITORY_ID
               AND jtua.source_id   = p_terr_usgs_tbl (1).source_id
               AND jtua.org_id      = p_terr_all_rec.org_id ;
        END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_PARENT_TERR');
                FND_MESSAGE.Set_Token('TERR_ID', to_char(p_terr_all_rec.PARENT_TERRITORY_ID));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
    -- Check if the Terr Type is valid for the given source.
    BEGIN
        SELECT 1
        INTO l_dummy
        FROM jtf_terr_types_all a,
             jtf_terr_type_usgs_all b
       WHERE a.enabled_flag = 'Y'
         AND a.terr_type_id     = b.terr_type_id
         AND a.org_id           = b.org_id
         AND b.source_id        = p_terr_usgs_tbl (1).source_id
         AND b.org_id           = p_terr_all_rec.org_id
         AND a.terr_type_id     = p_terr_all_rec.territory_type_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name('JTF', 'JTY_TERR_INVALID_TERR_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;


   --dbms_output('Create_Territory_Header PVT: Before Calling Create_Territory_Record');
   -- Call create_territory_record API
   IF p_terr_all_rec.terr_id IS NULL OR p_terr_all_rec.terr_creation_flag IS NULL
   THEN
        Create_Territory_Record(P_Api_Version_Number          =>  P_Api_Version_Number,
                           P_Init_Msg_List               =>  P_Init_Msg_List,
                           P_Commit                      =>  P_Commit,
                           p_validation_level            =>  p_validation_level,
                           P_Terr_All_Rec                =>  P_Terr_All_Rec,
                           X_Return_Status               =>  l_Return_Status,
                           X_Msg_Count                   =>  X_Msg_Count,
                           X_Msg_Data                    =>  X_Msg_Data,
                           X_Terr_Id                     =>  l_terr_id,
                           X_Terr_All_Out_Rec            =>  l_Terr_All_Out_Rec);

    ELSE
            UPDATE JTF_TERR_ALL
            SET terr_group_id      = p_terr_all_rec.territory_group_id,
                LAST_UPDATED_BY    = p_terr_all_rec.LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN  = p_terr_all_rec.LAST_UPDATE_LOGIN,
                NAME               = p_terr_all_rec.NAME,
                START_DATE_ACTIVE  = p_terr_all_rec.START_DATE_ACTIVE,
                END_DATE_ACTIVE    = p_terr_all_rec.END_DATE_ACTIVE,
                PARENT_TERRITORY_ID= p_terr_all_rec.PARENT_TERRITORY_ID,
                RANK               = p_terr_all_rec.RANK,
                DESCRIPTION        = p_terr_all_rec.DESCRIPTION,
                NUM_WINNERS        = p_terr_all_rec.NUM_WINNERS,
                territory_type_id  = p_terr_all_rec.territory_type_id
            WHERE terr_id = p_terr_all_rec.terr_id;

            l_terr_id := p_terr_all_rec.terr_id;
            l_return_status :='S';
            l_terr_all_out_rec.terr_id := l_terr_id;
    END IF;
   --
   -- Save the statuses
   x_return_status     := l_return_status;
   --
   --Save the out status record
   X_Terr_All_Out_Rec  := l_Terr_All_Out_Rec;
   --If there is a major error
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   --
   --dbms_output('Create_Territory_Header PVT: Before Calling Create_Territory_Usages');
   --
   Create_Territory_Usages(P_Api_Version_Number          =>  P_Api_Version_Number,
                           P_Init_Msg_List               =>  P_Init_Msg_List,
                           P_Commit                      =>  P_Commit,
                           p_validation_level            =>  p_validation_level,
                           P_Terr_Id                     =>  l_terr_id,
                           P_Terr_Usgs_Tbl               =>  P_Terr_Usgs_Tbl,
                           X_Return_Status               =>  l_Return_Status,
                           X_Msg_Count                   =>  X_Msg_Count,
                           X_Msg_Data                    =>  X_Msg_Data,
                           X_Terr_Usgs_Out_Tbl           => l_Terr_Usgs_Out_Tbl);
   --
   -- Save the statuses
   x_return_status        := l_return_status;
   --
   --Save the out status record
   X_Terr_Usgs_Out_Tbl    := l_Terr_Usgs_Out_Tbl;
   l_terr_usg_id          := l_Terr_Usgs_Out_Tbl(1).Terr_Usg_Id;
   --
   --If there is a major error
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
    -- Create the P_Terr_QualTypeUsgs_Tbl based on the Territory Type.
    BEGIN
        l_iterator := 1;
        OPEN C_QUAL_TYPE_USG_ID (p_terr_all_rec.territory_type_id);
        LOOP
            FETCH C_QUAL_TYPE_USG_ID
            INTO l_qual_type_usg_id;
            EXIT WHEN C_QUAL_TYPE_USG_ID%NOTFOUND;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).terr_qual_type_usg_id := NULL ;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).terr_id               := NULL ;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).qual_type_usg_id      := l_qual_type_usg_id;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).last_update_date      := p_terr_all_rec.last_update_date;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).last_updated_by       := p_terr_all_rec.last_updated_by;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).creation_date         := p_terr_all_rec.creation_date;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).created_by            := p_terr_all_rec.created_by;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).last_update_login     := p_terr_all_rec.LAST_UPDATE_LOGIN;
            P_Terr_QualTypeUsgs_Tbl (l_iterator).org_id                := p_terr_all_rec.org_id;
            l_iterator := l_iterator + 1 ;
        END LOOP;
        CLOSE C_QUAL_TYPE_USG_ID;
    EXCEPTION
     WHEN OTHERS THEN
        CLOSE C_QUAL_TYPE_USG_ID;
    END;
   --  Call api to insert records into jtf_terr_qualtype_usgs
   --
   --dbms_output('Create_Territory_Header PVT: Before Calling Create_Terr_QualType_Usage');

   Create_Terr_QualType_Usage(P_Api_Version_Number          => P_Api_Version_Number,
                              P_Init_Msg_List               => P_Init_Msg_List,
                              P_Commit                      => P_Commit,
                              p_validation_level            => p_validation_level,
                              P_Terr_Id                     => l_terr_id,
                              P_Terr_QualTypeUsgs_Tbl       => P_Terr_QualTypeUsgs_Tbl,
                              X_Return_Status               => l_Return_Status,
                              X_Msg_Count                   => X_Msg_Count,
                              X_Msg_Data                    => X_Msg_Data,
                              X_Terr_QualTypeUsgs_Out_Tbl   => l_Terr_QualTypeUsgs_Out_Tbl);

   --
   -- Save the statuses
   x_return_status            := l_return_status;
   --
   --Save the out status record
   X_Terr_QualTypeUsgs_Out_Tbl  := l_Terr_QualTypeUsgs_Out_Tbl;
   --If there is a major error
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --dbms_output('Create_Territory_Header PVT: Exiting API');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Create_Territory_Header PVT: FND_API.G_EXC_ERROR');
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Create_Territory_Header PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
          X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

  WHEN OTHERS THEN
       --dbms_output('Create_Territory_Header PVT: OTHERS - ' || SQLERRM);
       x_return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                      'Others exception inside Create_Territory_Header'
                                      || sqlerrm);
       END IF;
END Create_Territory_Header;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory_record
--    Type      : PUBLIC
--    Function  : To create a records in jtf_Terr_all table
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                         Default
--      X_Terr_All_Rec                Terr_All_Rec_Type			:= G_Miss_Terr_All_Rec,
--
--     OUT     :
--      Parameter Name                Data Type
--      X_terr_id                     NUMBER;
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_All_Out_Rec            Terr_All_Out_Rec_Type
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Territory_Record
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Id                     OUT NOCOPY NUMBER,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
)
AS
  l_rowid                       ROWID;
  l_terr_id                     NUMBER := P_TERR_ALL_REC.TERR_ID;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Territory_Record';
  l_api_version_number          CONSTANT NUMBER   := 1.0;
BEGIN
  --dbms_output('Create_Territory_Record PVT: Entering API');

  -- Standard Start of API savepoint
  SAVEPOINT CREATE_TERR_REC_PVT;

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
     FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
     FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Territory_Record');
         FND_MSG_PUB.Add;
      END IF;
      --
      -- Invoke validation procedures
      Validate_Territory_Record(p_init_msg_list    => FND_API.G_FALSE,
                                x_Return_Status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_Terr_All_Rec     => P_Terr_All_Rec);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  -- Call insert terr_all table handler
  --
  --dbms_output('Create_Territory_Record PVT: Before Calling JTF_TERR_PKG.Insert_Row APP_SHORT_NAME-' ||  G_APP_SHORT_NAME);
  --dbms_output('Create_Territory_Record PVT: Before Calling JTF_TERR_PKG.Insert_Row p_terr_all_rec.APPLICATION_SHORT_NAME-' ||  p_terr_all_rec.APPLICATION_SHORT_NAME);

      /* Intialise to NULL if FND_API.G_MISS_NUM,
      ** otherwise use passed in value
      */
      IF (l_terr_id = FND_API.G_MISS_NUM) THEN
          l_terr_id := NULL;
      END IF;

  JTF_TERR_PKG.Insert_Row(x_rowid                      => l_rowid,
                          x_terr_id                    => l_terr_id,
                          x_last_update_date           => p_terr_all_rec.LAST_UPDATE_DATE,
                          x_last_updated_by            => p_terr_all_rec.LAST_UPDATED_BY,
                          x_creation_date              => p_terr_all_rec.CREATION_DATE,
                          x_created_by                 => p_terr_all_rec.CREATED_BY,
                          x_last_update_login          => p_terr_all_rec.LAST_UPDATE_LOGIN,
                          x_request_id                 => p_terr_all_rec.request_id,
                          x_program_application_id     => p_terr_all_rec.program_application_id,
                          x_program_id                 => p_terr_all_rec.program_id,
                          x_program_update_date        => p_terr_all_rec.program_update_date,
                          x_application_short_name     => p_terr_all_rec.APPLICATION_SHORT_NAME,
                          x_name                       => p_terr_all_rec.name,
                          x_enabled_flag               => 'Y',
                          x_start_date_active          => p_terr_all_rec.start_date_active,
                          x_end_date_active            => p_terr_all_rec.end_date_active,
                          x_planned_flag               => p_terr_all_rec.planned_flag,
                          x_parent_territory_id        => p_terr_all_rec.parent_territory_id,
                          x_territory_type_id          => p_terr_all_rec.territory_type_id,
                          x_template_territory_id      => p_terr_all_rec.template_territory_id,
                          x_template_flag              => p_terr_all_rec.template_flag,
                          x_escalation_territory_id    => p_terr_all_rec.escalation_territory_id,
                          x_escalation_territory_flag  => p_terr_all_rec.escalation_territory_flag,
                          x_overlap_allowed_flag       => p_terr_all_rec.overlap_allowed_flag,
                          x_rank                       => p_terr_all_rec.rank,
                          x_description                => p_terr_all_rec.description,
                          x_update_flag                => p_terr_all_rec.update_flag,
                          x_auto_assign_resources_flag => p_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG,
                          x_attribute_category         => p_terr_all_rec.attribute_category,
                          x_attribute1                 => p_terr_all_rec.attribute1,
                          x_attribute2                 => p_terr_all_rec.attribute2,
                          x_attribute3                 => p_terr_all_rec.attribute3,
                          x_attribute4                 => p_terr_all_rec.attribute4,
                          x_attribute5                 => p_terr_all_rec.attribute5,
                          x_attribute6                 => p_terr_all_rec.attribute6,
                          x_attribute7                 => p_terr_all_rec.attribute7,
                          x_attribute8                 => p_terr_all_rec.attribute8,
                          x_attribute9                 => p_terr_all_rec.attribute9,
                          x_attribute10                => p_terr_all_rec.attribute10,
                          x_attribute11                => p_terr_all_rec.attribute11,
                          x_attribute12                => p_terr_all_rec.attribute12,
                          x_attribute13                => p_terr_all_rec.attribute13,
                          x_attribute14                => p_terr_all_rec.attribute14,
                          x_attribute15                => p_terr_all_rec.attribute15,
                          x_org_id                     => P_terr_all_rec.ORG_ID,
                          x_num_winners                => p_terr_all_rec.NUM_WINNERS,
                          x_num_qual                   => p_terr_all_rec.NUM_QUAL);

     --
     --If there was no error in Table Handler Code gets here
     --else it goes to the exceptions block
     X_Terr_All_Out_Rec.Terr_id := l_terr_id;
     X_Terr_Id                  := l_terr_id;
     X_Terr_All_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
     THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
     END IF;

     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
        COMMIT WORK;
     END IF;


     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
        p_data           =>   x_msg_data
     );

     --dbms_output('Create_Territory_Record PVT: Exiting API');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERR_REC_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERR_REC_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );


     WHEN OTHERS THEN
          --dbms_output('Create_Territory_Record PVT: OTHERS - ' || SQLERRM);
          X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_All_Out_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          ROLLBACK TO CREATE_TERR_REC_PVT;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Territory_Record');
          END IF;
END Create_Territory_Record;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory_Usages
--    Type      : PUBLIC
--    Function  : To create Territories usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER;
--      P_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type
)
AS
  l_rowid                       ROWID;
  l_terr_usg_id                 NUMBER;
  l_Terr_Usgs_Tbl_Count         NUMBER                      := P_Terr_Usgs_Tbl.Count;
  l_Terr_Usgs_Out_Tbl_Count     NUMBER;
  l_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl_Type;
  l_Counter                     NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Territory_Usages';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
  --dbms_output('Create_Territory_Usages PVT: Entering API');
  --
  -- Standard Start of API savepoint
  SAVEPOINT CREATE_TERR_USG_PVT;

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
     FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  If (p_Terr_Usgs_Tbl.count  = 0 ) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_USAGE');
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  FOR l_Counter IN 1 ..  l_Terr_Usgs_Tbl_Count LOOP
   --
       BEGIN

          --dbms_output('Create_Territory_Usages PVT: Before Calling JTF_TERR_USGS_PKG.Insert_Row');

          --  Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF ( P_validation_level <> FND_API.G_VALID_LEVEL_NONE) THEN

             -- Debug message
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
             THEN
                   FND_MESSAGE.Set_Name('JTF', 'Create_Terr_Rec PVT: Valid');
                   FND_MSG_PUB.Add;
             END IF;
             --
             -- Invoke validation procedures
             Validate_Territory_Usage(p_init_msg_list    => FND_API.G_FALSE,
                                      x_Return_Status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_Terr_Id          => p_Terr_Id,
                                      p_Terr_Usgs_Rec    => P_Terr_Usgs_Tbl(l_Counter));
             --
             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          --

             -- jdochert 09/09
             -- check for Unique Key constraint violation
             validate_terr_usgs_UK(  p_Terr_Id          => p_Terr_Id,
                           p_Source_Id        => P_Terr_Usgs_Tbl(l_counter).source_id,
                           p_init_msg_list    => FND_API.G_FALSE,
                           x_Return_Status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;

          l_terr_usg_id := P_Terr_Usgs_Tbl(l_Counter).terr_usg_id;

          /* Intialise to NULL if FND_API.G_MISS_NUM,
          ** otherwise used passed in value
          */
          IF (l_terr_usg_id = FND_API.G_MISS_NUM) THEN
             l_terr_usg_id := NULL;
          END IF;

          JTF_TERR_USGS_PKG.Insert_Row(x_Rowid                     => l_rowid,
                                       x_TERR_USG_ID               => l_terr_usg_id,
                                       x_LAST_UPDATE_DATE          => P_Terr_Usgs_Tbl(l_Counter).LAST_UPDATE_DATE,
                                       x_LAST_UPDATED_BY           => P_Terr_Usgs_Tbl(l_Counter).LAST_UPDATED_BY,
                                       x_CREATION_DATE             => P_Terr_Usgs_Tbl(l_Counter).CREATION_DATE,
                                       x_CREATED_BY                => P_Terr_Usgs_Tbl(l_Counter).CREATED_BY,
                                       x_LAST_UPDATE_LOGIN         => P_Terr_Usgs_Tbl(l_Counter).LAST_UPDATE_LOGIN,
                                       x_TERR_ID                   => P_terr_id,
                                       x_SOURCE_ID                 => P_Terr_Usgs_Tbl(l_Counter).source_id,
                                       x_Org_Id                    => P_Terr_Usgs_Tbl(l_Counter).Org_Id);

          -- Save the terr_usg_id and
          X_Terr_Usgs_Out_Tbl(l_Counter).terr_usg_id := l_terr_usg_id;
          -- If successful then save the success status for the record
          X_Terr_Usgs_Out_Tbl(l_Counter).return_status := FND_API.G_RET_STS_SUCCESS;

       EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
              --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_ERROR');
              ROLLBACK TO CREATE_TERR_USG_PVT;
              x_return_status     := FND_API.G_RET_STS_ERROR ;
              X_Terr_Usgs_Out_Tbl(l_Counter).terr_usg_id := NULL;
              X_Terr_Usgs_Out_Tbl(l_Counter).return_status := X_return_status;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
              ROLLBACK TO CREATE_TERR_USG_PVT;
              X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
              X_Terr_Usgs_Out_Tbl(l_Counter).terr_usg_id := NULL;
              X_Terr_Usgs_Out_Tbl(l_Counter).return_status := X_return_status;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
               --dbms_output('Create_Territory_Usages PVT: OTHERS - ' || SQLERRM);
               X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	           X_Terr_Usgs_Out_Tbl(l_Counter).terr_usg_id := NULL;
               X_Terr_Usgs_Out_Tbl(l_Counter).return_status := X_return_status;
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
               THEN
                  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Territory_Usages');
               END IF;
       END;
   --
   END LOOP;

   -- Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --Get number of records in the ouput table
   l_Terr_Usgs_Out_Tbl_Count     := X_Terr_Usgs_Out_Tbl.Count;
   l_Terr_Usgs_Out_Tbl           := X_Terr_Usgs_Out_Tbl;

   FOR l_Counter IN 1 ..  l_Terr_Usgs_Out_Tbl_Count LOOP
       If l_Terr_Usgs_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Usgs_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;
   --
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
   END IF;
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
   --
   --dbms_output('Create_Territory_Usages PVT: Exiting API');
   --
End Create_Territory_Usages;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_QualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territories qualifier usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_usg_id                 NUMBER;
--      P_Terr_QualTypeUsgs_Rec       Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Id        OUT NOCOPY NUMBER,
  X_Terr_QualTypeUsgs_Out_Rec   OUT NOCOPY Terr_QualTypeUsgs_Out_Rec_Type
)
AS
  l_rowid                       ROWID;
  l_terr_qual_type_usg_id       NUMBER := P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Qualtype_Usage';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
   --dbms_output('Create_Terr_QualType_Usage PVT(REC): Entering API');

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_QTYPE_USG_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Qtype_Usage');
           FND_MSG_PUB.Add;
        END IF;

        -- Invoke validation procedures
        Validate_Terr_Qtype_Usage(p_init_msg_list         => FND_API.G_FALSE,
                                  x_Return_Status         => x_return_status,
                                  x_msg_count             => x_msg_count,
                                  x_msg_data              => x_msg_data,
                                  p_Terr_Id               => p_Terr_Id,
                                  P_Terr_QualTypeUsgs_Rec => P_Terr_QualTypeUsgs_Rec);
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;


      -- jdochert 09/09
      -- check for Unique Key constraint violation
      validate_terr_qtype_usgs_UK(  p_Terr_Id          => p_Terr_Id,
                           p_Qual_Type_Usg_id       => p_Terr_QualTypeUsgs_Rec.qual_type_usg_id,
                           p_init_msg_list    => FND_API.G_FALSE,
                           x_Return_Status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;
   --dbms_output('Create_Terr_QualType_Usage PVT(REC): Before Calling JTF_TERR_QTYPE_USGS_PKG.Insert_Row');

   /* Intialise to NULL if FND_API.G_MISS_NUM,
   ** otherwise used passed in value
   */
   IF (l_TERR_QUAL_TYPE_USG_ID = FND_API.G_MISS_NUM) THEN
       l_TERR_QUAL_TYPE_USG_ID := NULL;
   END IF;


   -- Call insert terr_Qual_Type_Usgs table handler
   JTF_TERR_QTYPE_USGS_PKG.Insert_Row(x_Rowid                      => l_rowid,
                                      x_TERR_QTYPE_USG_ID          => l_TERR_QUAL_TYPE_USG_ID,
                                      x_LAST_UPDATED_BY            => P_Terr_QualTypeUsgs_Rec.LAST_UPDATED_BY,
                                      x_LAST_UPDATE_DATE           => P_Terr_QualTypeUsgs_Rec.LAST_UPDATE_DATE,
                                      x_CREATED_BY                 => P_Terr_QualTypeUsgs_Rec.CREATED_BY,
                                      x_CREATION_DATE              => P_Terr_QualTypeUsgs_Rec.CREATION_DATE,
                                      x_LAST_UPDATE_LOGIN          => P_Terr_QualTypeUsgs_Rec.LAST_UPDATE_LOGIN,
                                      x_TERR_ID                    => p_terr_id,
                                      x_QUAL_TYPE_USG_ID           => P_Terr_QualTypeUsgs_Rec.QUAL_TYPE_USG_ID,
                                      x_ORG_ID                     => P_Terr_QualTypeUsgs_Rec.ORG_ID);

    -- Save the Save the terr_usg_id
    X_Terr_QualTypeUsgs_Id := l_TERR_QUAL_TYPE_USG_ID;
    X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID := l_TERR_QUAL_TYPE_USG_ID;

    -- If successful then save the success status for the record
    X_Return_Status                                   := FND_API.G_RET_STS_SUCCESS;
    X_Terr_QualTypeUsgs_Out_Rec.return_status         := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
    END IF;

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    --dbms_output('Create_Terr_QualType_Usage PVT(REC): Exiting API');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Create_Terr_QualType_Usage PVT(REC): FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERR_QTYPE_USG_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID   := NULL;
         X_Terr_QualTypeUsgs_Out_Rec.return_status := x_return_status;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Create_Terr_QualType_Usage PVT(REC): FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERR_QTYPE_USG_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID   := NULL;
         X_Terr_QualTypeUsgs_Out_Rec.return_status := x_return_status;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Create_Terr_QualType_Usage PVT(REC): OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERR_QTYPE_USG_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID   := NULL;
         X_Terr_QualTypeUsgs_Out_Rec.return_status := x_return_status;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Terr_QualType_Usage(REC)');
         END IF;
--
End Create_Terr_QualType_Usage;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_QualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territories qualifier usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_usg_id                 NUMBER;
--      P_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type
)
AS
  l_rowid                       ROWID;
  l_return_Status               VARCHAR2(1);
  l_terr_qual_type_usg_id       NUMBER;
  l_Terr_QualTypeUsgs_Tbl_Count NUMBER                               := P_Terr_QualTypeUsgs_Tbl.Count;
  l_Terr_QTypUsg_Out_Tbl_Count  NUMBER;
  l_Terr_QTypUsg_Out_Rec        Terr_QualTypeUsgs_Out_Rec_Type;
  l_Terr_QTypUsg_Out_Tbl        Terr_QualTypeUsgs_Out_Tbl_Type;
  l_Counter                     NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Qtype_Usage(Tbl)';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
   --dbms_output('Create_Terr_QualType_Usage PVT(TBL): Entering API');

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_QTYPE_USG_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call insert terr_Qual_Type_Usgs table handler
   --
   FOR l_Counter IN 1 ..  l_Terr_QualTypeUsgs_Tbl_Count LOOP
   --
       --dbms_output('Create_Terr_QualType_Usage PVT(TBL): Before Calling Create_Terr_QualType_Usage');

       Create_Terr_QualType_Usage( P_Api_Version_Number          =>  P_Api_Version_Number,
                                   P_Init_Msg_List               =>  P_Init_Msg_List,
                                   P_Commit                      =>  P_Commit,
                                   p_validation_level            =>  p_validation_level,
                                   P_Terr_Id                     =>  P_Terr_Id,
                                   P_Terr_QualTypeUsgs_Rec       =>  P_Terr_QualTypeUsgs_Tbl(l_counter),
                                   X_Return_Status               =>  l_Return_Status,
                                   X_Msg_Count                   =>  X_Msg_Count,
                                   X_Msg_Data                    =>  X_Msg_Data,
                                   X_Terr_QualTypeUsgs_Id        =>  l_terr_qual_type_usg_id,
                                   X_Terr_QualTypeUsgs_Out_Rec   =>  l_Terr_QTypUsg_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Create_Terr_QualType_Usage PVT(TBL): l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).TERR_QUAL_TYPE_USG_ID  := NULL;
           -- If save the ERROR status for the record
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Create_Terr_QualType_Usage PVT(TBL): l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).TERR_QUAL_TYPE_USG_ID := l_terr_qual_type_usg_id;
           -- If successful then save the success status for the record
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   -- Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_Terr_QTypUsg_Out_Tbl_Count  := X_Terr_QualTypeUsgs_Out_Tbl.Count;
   l_Terr_QTypUsg_Out_Tbl        := X_Terr_QualTypeUsgs_Out_Tbl;

   FOR l_Counter IN 1 ..  l_Terr_QTypUsg_Out_Tbl_Count LOOP
       If l_Terr_QTypUsg_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_QTypUsg_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --dbms_output('Create_Terr_QualType_Usage PVT(TBL): Exiting API');
   --
End Create_Terr_QualType_Usage;
--


/* update territory's number of qualifiers
*/
PROCEDURE update_terr_num_qual(p_terr_id IN NUMBER, p_qual_type_id IN NUMBER) AS
BEGIN

     UPDATE jtf_terr_ALL jt
     SET jt.num_qual = (
        SELECT COUNT(jtq.qual_usg_id)
        FROM jtf_terr_qual_ALL jtq, jtf_qual_usgs_ALL jqu, jtf_qual_type_usgs_ALL jqtu
        WHERE jtq.terr_id = jt.terr_id
          AND jtq.qual_usg_id = jqu.qual_usg_id
          AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
          AND jqtu.qual_type_id = p_qual_type_id
          AND jqtu.qual_type_id <> -1001
        )
     WHERE jt.terr_id = p_terr_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        NULL;
  WHEN OTHERS THEN
        NULL;

END update_terr_num_qual;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_QualIfier
--    Type      : PUBLIC
--    Function  : To create Territories qualifier
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      P_Terr_Qual_Tbl               Terr_Qual_Rec_Type               := G_Miss_Terr_Qual_Rec
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Terr_Qual_Id                NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl
--
--    Notes:    This is a an overloaded procedure for a SINGLE RECORD
--
--
--    End of Comments
--
PROCEDURE Create_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type     := G_Miss_Terr_Qual_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Id                OUT NOCOPY NUMBER,
  X_Terr_Qual_Out_Rec           OUT NOCOPY Terr_Qual_Out_Rec_Type
)
AS
  l_rowid                       ROWID;
  l_terr_qual_id                NUMBER := P_Terr_Qual_Rec.terr_qual_id;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Qualifier';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
   --dbms_output('Create_Terr_Qualifier REC: Entering API');

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_QUAL_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the validation level
   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)  THEN

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Qualifier');
           FND_MSG_PUB.Add;
        END IF;
        --  Check for ORG_ID
        IF (P_Terr_Qual_Rec.ORG_ID is NULL OR
            P_Terr_Qual_Rec.ORG_ID = FND_API.G_MISS_NUM ) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;

        --Check created by
        IF ( P_Terr_Qual_Rec.CREATED_BY is NULL OR
           P_Terr_Qual_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;

        --Check creation date
        If ( P_Terr_Qual_Rec.CREATION_DATE is NULL OR
             P_Terr_Qual_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
        --
        -- Invoke validation procedures
        Validate_Qualifier(p_init_msg_list         => FND_API.G_FALSE,
                           x_Return_Status         => x_return_status,
                           x_msg_count             => x_msg_count,
                           x_msg_data              => x_msg_data,
                           p_Terr_Id               => p_Terr_Id,
                           P_Terr_Qual_Rec         => P_Terr_Qual_Rec);

       --dbms_output('Create_Terr_Qualifier REC: x_return_status = ' || x_return_status);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
   --
   END IF;

   /* Intialise to NULL if FND_API.G_MISS_NUM,
   ** otherwise used passed in value
   */
   IF (l_terr_qual_id = FND_API.G_MISS_NUM) THEN
       l_terr_qual_id := NULL;
   END IF;

   -- Call insert terr_Qual_Type_Usgs table handler
   JTF_TERR_QUAL_PKG.Insert_Row(x_Rowid                          => l_rowid,
                                x_TERR_QUAL_ID                   => l_terr_qual_id,
                                x_LAST_UPDATE_DATE               => P_Terr_Qual_Rec.LAST_UPDATE_DATE,
                                x_LAST_UPDATED_BY                => P_Terr_Qual_Rec.LAST_UPDATED_BY,
                                x_CREATION_DATE                  => P_Terr_Qual_Rec.CREATION_DATE,
                                x_CREATED_BY                     => P_Terr_Qual_Rec.CREATED_BY,
                                x_LAST_UPDATE_LOGIN              => P_Terr_Qual_Rec.LAST_UPDATE_LOGIN,
                                x_TERR_ID                        => P_terr_id,
                                x_QUAL_USG_ID                    => P_Terr_Qual_Rec.QUAL_USG_ID,
                                x_USE_TO_NAME_FLAG               => P_Terr_Qual_Rec.USE_TO_NAME_FLAG,
                                x_GENERATE_FLAG                  => P_Terr_Qual_Rec.GENERATE_FLAG,
                                x_OVERLAP_ALLOWED_FLAG           => P_Terr_Qual_Rec.OVERLAP_ALLOWED_FLAG,
                                x_QUALIFIER_MODE                 => P_Terr_Qual_Rec.QUALIFIER_MODE,
                                x_ORG_ID                         => P_Terr_Qual_Rec.ORG_ID);

   --
   -- Save the terr_qual_id returned by the table handler
   X_Terr_Qual_Id                   := l_Terr_Qual_Id;
   X_Terr_Qual_Out_Rec.TERR_QUAL_ID := l_TERR_QUAL_ID;

   -- If successful then save the success status for the record
   X_Terr_Qual_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;


   /* update Sales territory's number of Account qualifiers
   */
   --update_terr_num_qual(p_terr_id, -1002);
   --

   --
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );


   --dbms_output('Create_Terr_Qualifier REC: Exiting API');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERR_QUAL_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         X_Terr_Qual_Out_Rec.TERR_QUAL_ID  := NULL;
         X_Terr_Qual_Out_Rec.return_status := x_return_status;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERR_QUAL_PVT;
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_Qual_Out_Rec.TERR_QUAL_ID  := NULL;
         X_Terr_Qual_Out_Rec.return_status := x_return_status;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );


     WHEN OTHERS THEN
         --dbms_output('Create_Terr_Qualifier REC: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERR_QUAL_PVT;
         x_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_Qual_Out_Rec.TERR_QUAL_ID  := NULL;
         X_Terr_Qual_Out_Rec.return_status := x_return_status;
         --
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Terr_Qualifier');
         END IF;
--
End Create_Terr_Qualifier;
--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_QualIfier
--    Type      : PUBLIC
--    Function  : To create Territories qualifier
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      P_Terr_Qual_Tbl               Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Terr_Qual_Id                NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--
PROCEDURE Create_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type
)
AS
  --l_rowid                     ROWID;
  l_terr_qual_id                NUMBER;
  l_return_Status               VARCHAR2(1);
  l_Terr_Qual_Tbl_Count         NUMBER                       := P_Terr_Qual_Tbl.Count;
  l_Terr_Qual_Out_Tbl_Count     NUMBER;
  l_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl_Type;
  l_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type;
  --l_Terr_Qual_Tbl               Terr_Qual_Tbl_Type;
  l_Counter                     NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Qualifier (Tbl)';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
   --dbms_output('Create_Terr_Qualifier TBL: Entering API');

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_QUAL_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_Terr_Qual_Tbl_Count LOOP
   --
       --dbms_output('Create_Terr_Qualifier TBL: Before Calling Create_Terr_Qualifier');
       --
       Create_Terr_Qualifier( P_Api_Version_Number          =>  P_Api_Version_Number,
                              P_Init_Msg_List               =>  P_Init_Msg_List,
                              P_Commit                      =>  P_Commit,
                              p_validation_level            =>  p_validation_level,
                              P_Terr_Id                     =>  p_Terr_Id,
                              P_Terr_Qual_Rec               =>  P_Terr_Qual_Tbl(l_counter),
                              X_Return_Status               =>  l_Return_Status,
                              X_Msg_Count                   =>  X_Msg_Count,
                              X_Msg_Data                    =>  X_Msg_Data,
                              X_Terr_Qual_Id                =>  l_Terr_qual_id,
                              X_Terr_Qual_Out_Rec           =>  l_Terr_Qual_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --dbms_output('Create_Terr_Qualifier TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Qual_Out_Tbl(l_counter).TERR_QUAL_ID  := NULL;
           -- If save the ERROR status for the record
           X_Terr_Qual_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
          --dbms_output('Create_Terr_Qualifier TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Qual_Out_Tbl(l_counter).TERR_QUAL_ID := l_TERR_QUAL_ID;
           -- If successful then save the success status for the record
           X_Terr_Qual_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_Terr_Qual_Out_Tbl_Count  := X_Terr_Qual_Out_Tbl.Count;
   l_Terr_Qual_Out_Tbl        := X_Terr_Qual_Out_Tbl;

   -- Get the API overall return status
   FOR l_Counter IN 1 ..  l_Terr_Qual_Out_Tbl_Count  LOOP
       If l_Terr_Qual_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Qual_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;
   --
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --dbms_output('Create_Terr_Qualifier TBL: Exiting API');
--
End Create_Terr_Qualifier;

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory_Qualifier
--    Type      :  PUBLIC
--    Function  : To create Territories Qualifiers and Territory Qualifier Values.
--                       Atleast one qualifier value need to provided  to create qualfier.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--      p_validation_level            NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    End of Comments
--
PROCEDURE Create_Terr_qualifier
  (
    p_Api_Version_Number  IN  NUMBER,
    p_Init_Msg_List       IN  VARCHAR2 := FND_API.G_FALSE,
    p_Commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_Return_Status       OUT NOCOPY VARCHAR2,
    x_Msg_Count           OUT NOCOPY NUMBER,
    x_Msg_Data            OUT NOCOPY VARCHAR2,
    P_Terr_Qual_Rec       IN  Terr_Qual_Rec_Type := G_Miss_Terr_Qual_Rec,
    p_Terr_Values_Tbl     IN  Terr_Values_Tbl_Type := G_Miss_Terr_Values_Tbl,
    X_Terr_Qual_Out_Rec   OUT NOCOPY Terr_Qual_Out_Rec_Type,
    x_Terr_Values_Out_Tbl OUT NOCOPY Terr_Values_Out_Tbl_Type
 )
AS
	l_api_name           CONSTANT VARCHAR2(30) := 'Create_Terr_Qualifier';
	l_api_version_number CONSTANT NUMBER       := 1.0;
	-- Status Local Variables
	l_return_status      VARCHAR2(1); -- Return value from procedures
	l_return_status_full VARCHAR2(1); -- Calculated return status from                                                -- all return values
	l_Terr_Qual_Out_Tbl Terr_Qual_Out_Tbl_Type;
	l_Terr_Values_Out_Tbl Terr_Values_Out_Tbl_Type;
	l_Terr_Qual_Id NUMBER := 0;
	l_msg_count    NUMBER;
	l_msg_data     VARCHAR2(2000);
	L_SHORT_NAME   VARCHAR2(15);
BEGIN
	--dbms_output('Create_Territory PVT: Entering API -' || G_APP_SHORT_NAME);
	-- Standard Start of API savepoint
	SAVEPOINT CREATE_TERRITORY_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
		FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
		FND_MSG_PUB.ADD;
	END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	--Check whether the territory values are specified
	IF (p_Terr_Values_Tbl.COUNT = 0 ) THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_VALUES');
			FND_MSG_PUB.ADD;
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Terr ID can't be null.
	IF (P_Terr_Qual_Rec.TERR_ID IS NULL) OR (P_Terr_Qual_Rec.TERR_ID = FND_API.G_MISS_NUM) THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
			FND_MESSAGE.Set_Token('COL_NAME', 'TERR_ID' );
			FND_MSG_PUB.ADD;
		END IF;
		x_Return_Status := FND_API.G_RET_STS_ERROR ;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    -- Validate the territory Id
    If ( P_Terr_Qual_Rec.TERR_ID IS NOT NULL )AND (P_Terr_Qual_Rec.TERR_ID = FND_API.G_MISS_NUM ) Then
       --dbms_output('Validate_Terr_Qtype_Usage: TERR_ID(' || to_char(l_Validate_id) || ')');
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(P_Terr_Qual_Rec.TERR_ID, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
          --dbms_output('Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_ALL');
             FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
    End If;
	-- Create the territory qualifier record
	--
	Create_Terr_Qualifier( P_Api_Version_Number          =>  P_Api_Version_Number,
                           P_Init_Msg_List               =>  P_Init_Msg_List,
                           P_Commit                      =>  P_Commit,
                           p_validation_level            =>  p_validation_level,
                           P_Terr_Id                     =>  P_Terr_Qual_Rec.TERR_ID,
                           P_Terr_Qual_Rec               =>  P_Terr_Qual_Rec,
                           X_Return_Status               =>  l_Return_Status,
                           X_Msg_Count                   =>  X_Msg_Count,
                           X_Msg_Data                    =>  X_Msg_Data,
                           X_Terr_Qual_Id                =>  l_Terr_qual_id,
                           X_Terr_Qual_Out_Rec           =>  X_Terr_Qual_Out_Rec);
    --

    --If there is a major error
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		-- Save the terr_usg_id and
		X_Terr_Qual_Out_Rec.TERR_QUAL_ID := NULL;
		-- If save the ERROR status for the record
		X_Terr_Qual_Out_Rec.return_status := X_Return_Status;
		X_Return_Status                   := l_return_status;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		-- Save the terr_usg_id and
		X_Terr_Qual_Out_Rec.TERR_QUAL_ID := l_TERR_QUAL_ID;
		-- If successful then save the success status for the record
		X_Terr_Qual_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	IF (p_Terr_Values_Tbl.COUNT > 0) THEN
		--
		Create_Terr_Value( P_Api_Version_Number  =>  P_Api_Version_Number,
                           P_Init_Msg_List       =>  P_Init_Msg_List,
                           P_Commit              =>  P_Commit,
                           p_validation_level    =>  p_validation_level,
                           P_Terr_Id             =>  P_Terr_Qual_Rec.TERR_ID,
                           p_terr_qual_id        =>  l_Terr_Qual_Id,
                           P_Terr_Value_Tbl      =>  p_Terr_Values_Tbl,
                           X_Return_Status       =>  l_Return_Status,
                           X_Msg_Count           =>  l_Msg_Count,
                           X_Msg_Data            =>  l_Msg_Data,
                           X_Terr_Value_Out_Tbl  =>  x_Terr_Values_Out_Tbl);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			X_Return_Status   := l_return_status;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;	/* p_Terr_Qual_Tbl.count > 0 */

	--If the program reached here, that mena evry thing went smooth
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
		FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
		FND_MSG_PUB.ADD;
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

	-- Standard check for p_commit
	IF FND_API.to_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	--
 EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_TERRITORY_PVT;
        x_return_status                    := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_TERRITORY_PVT;
        X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_TERRITORY_PVT;
        X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END Create_Terr_Qualifier;




--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Value
--    Type      : PUBLIC
--    Function  : To create Territories qualifier values
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_value_id               NUMBER
--      P_Terr_Value_Rec              Terr_Values_Rec_Type             := G_Miss_Terr_Values_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Terr_Value_Id               NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Value_Out_Rec          Terr_Values_Out_Rec
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--
PROCEDURE Create_Terr_Value
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  p_terr_qual_id                IN  NUMBER,
  P_Terr_Value_Rec              IN  Terr_Values_Rec_Type     := G_Miss_Terr_Values_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Id               OUT NOCOPY NUMBER,
  X_Terr_Value_Out_Rec          OUT NOCOPY Terr_Values_Out_Rec_Type
)
AS
  l_rowid                       ROWID;
  l_terr_Value_id               NUMBER := P_Terr_Value_Rec.terr_value_id;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Values';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
  l_dummy                       VARCHAR2(3);
BEGIN
   --dbms_output('Create_Terr_Value PVT: Entering API');
      -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_VALUE_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the validation level
   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)   THEN
        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
           FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_terr_Value_Rec');
           FND_MSG_PUB.Add;
        END IF;


        --Check created by
        IF ( p_Terr_Value_Rec.CREATED_BY is NULL OR
             p_Terr_Value_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;

        --Check creation date
        If ( p_Terr_Value_Rec.CREATION_DATE is NULL OR
             p_Terr_Value_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
              FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
              FND_MSG_PUB.ADD;
           END IF;
           x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Invoke validation procedures
        Validate_Terr_Value_Rec(p_init_msg_list    => FND_API.G_FALSE,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_terr_qual_id     => p_terr_qual_id,
                                p_Terr_Value_Rec   => P_Terr_Value_Rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Check for duplicate values
                -- Invoke validation procedures
        Check_duplicate_Value(p_init_msg_list    => FND_API.G_FALSE,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_terr_qual_id     => p_terr_qual_id,
                                p_Terr_Value_Rec   => P_Terr_Value_Rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

   END IF;

   /* Intialise to NULL if FND_API.G_MISS_NUM,
   ** otherwise used passed in value
   */
   IF (l_terr_value_id = FND_API.G_MISS_NUM) THEN
       l_terr_value_id := NULL;
   END IF;
   --
   --dbms_output('Create_Terr_Value PVT: Before Calling JTF_TERR_VALUES_PKG.Insert_Row');
   JTF_TERR_VALUES_PKG.Insert_Row(x_Rowid                       => l_rowid,
                                  x_TERR_VALUE_ID               => l_terr_value_id,
                                  x_LAST_UPDATED_BY             => P_Terr_Value_Rec.LAST_UPDATED_BY,
                                  x_LAST_UPDATE_DATE            => P_Terr_Value_Rec.LAST_UPDATE_DATE,
                                  x_CREATED_BY                  => P_Terr_Value_Rec.CREATED_BY,
                                  x_CREATION_DATE               => P_Terr_Value_Rec.CREATION_DATE,
                                  x_LAST_UPDATE_LOGIN           => P_Terr_Value_Rec.LAST_UPDATE_LOGIN,
                                  x_TERR_QUAL_ID                => P_terr_qual_id,
                                  x_INCLUDE_FLAG                => P_Terr_Value_Rec.INCLUDE_FLAG,
                                  x_COMPARISON_OPERATOR         => P_Terr_Value_Rec.COMPARISON_OPERATOR,
                                  x_LOW_VALUE_CHAR              => P_Terr_Value_Rec.LOW_VALUE_CHAR,
                                  x_HIGH_VALUE_CHAR             => P_Terr_Value_Rec.HIGH_VALUE_CHAR,
                                  x_LOW_VALUE_NUMBER            => P_Terr_Value_Rec.LOW_VALUE_NUMBER,
                                  x_HIGH_VALUE_NUMBER           => P_Terr_Value_Rec.HIGH_VALUE_NUMBER,
                                  x_VALUE_SET                   => P_Terr_Value_Rec.VALUE_SET,
                                  x_INTEREST_TYPE_ID            => P_Terr_Value_Rec.INTEREST_TYPE_ID,
                                  x_PRIMARY_INTEREST_CODE_ID    => P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID,
                                  x_SECONDARY_INTEREST_CODE_ID  => P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID,
                                  x_CURRENCY_CODE               => P_Terr_Value_Rec.CURRENCY_CODE,
                                  x_ID_USED_FLAG                => P_Terr_Value_Rec.ID_USED_FLAG,
                                  x_LOW_VALUE_CHAR_ID           => P_Terr_Value_Rec.LOW_VALUE_CHAR_ID,
                                  x_ORG_ID                      => P_Terr_Value_Rec.ORG_ID,
                                  x_CNR_GROUP_ID                => p_terr_value_rec.CNR_GROUP_ID,
                                  x_VALUE1_ID                   => p_terr_value_rec.VALUE1_ID,
                                  x_VALUE2_ID                   => p_terr_value_rec.VALUE2_ID,
                                  x_VALUE3_ID                   => p_terr_value_rec.VALUE3_ID,
                                  x_VALUE4_ID                   => p_terr_value_rec.VALUE4_ID );

   --
   -- Save the terr_qual_id returned by the table handler
   X_Terr_Value_Id                    := l_Terr_Value_Id;
   X_Terr_Value_Out_Rec.TERR_VALUE_ID := l_TERR_VALUE_ID;

   -- If successful then save the success status for the record
   X_Terr_Value_Out_Rec.return_status := FND_API.G_RET_STS_SUCCESS;

      --
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --dbms_output('Create_Terr_Value PVT: Exiting API');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO CREATE_TERR_VALUE_PVT;
         x_return_status                     := FND_API.G_RET_STS_ERROR ;
         X_Terr_Value_Out_Rec.TERR_VALUE_ID  := NULL;
         X_Terr_Value_Out_Rec.return_status  := x_return_status;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Create_Territory_Record PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO CREATE_TERR_VALUE_PVT;
         x_return_status                     := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_Value_Out_Rec.TERR_VALUE_ID  := NULL;
         X_Terr_Value_Out_Rec.return_status  := x_return_status;

         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Create_Terr_Value PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO CREATE_TERR_VALUE_PVT;
         x_return_status                     := FND_API.G_RET_STS_UNEXP_ERROR;
         X_Terr_Value_Out_Rec.TERR_VALUE_ID  := NULL;
         X_Terr_Value_Out_Rec.return_status  := x_return_status;
         --
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Others exception in Create_Terr_Value');
         END IF;
--
End Create_Terr_Value;

--
--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Value
--    Type      : PUBLIC
--    Function  : To create Territories qualifier values
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_Value_id                NUMBER
--      P_Terr_Qual_Tbl               Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl
--
--     OUT     :
--      Parameter Name                Data Type
--      X_Terr_Qual_Id                NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--
PROCEDURE Create_Terr_Value
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                   IN  NUMBER,
  p_terr_qual_id                IN  NUMBER,
  P_Terr_Value_Tbl              IN  Terr_Values_Tbl_Type             := G_Miss_Terr_Values_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Tbl          OUT NOCOPY Terr_Values_Out_Tbl_Type
)
AS
  --l_rowid                     ROWID;
  l_terr_value_id               NUMBER;
  l_return_Status               VARCHAR2(1);
  l_Terr_Value_Tbl_Count        NUMBER                          := P_Terr_Value_Tbl.Count;
  l_Terr_Value_Out_Tbl_Count    NUMBER;
  l_Terr_Value_Out_Tbl          Terr_Values_Out_Tbl_Type;
  l_Terr_Value_Out_Rec          Terr_Values_Out_Rec_Type;
  l_Counter                     NUMBER;

  l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Terr_Value (Tbl)';
  l_api_version_number          CONSTANT NUMBER       := 1.0;
BEGIN
   --dbms_output('Create_Terr_Value TBL: Entering API');

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_TERR_VALUE_PVT;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_Terr_Value_Tbl_Count LOOP
   --
       --dbms_output('Create_Terr_Value TBL: Before Calling Create_Terr_Value -' || to_char(P_Terr_Value_Tbl(l_counter).QUALIFIER_TBL_INDEX) );
       --
       Create_Terr_Value( P_Api_Version_Number          =>  P_Api_Version_Number,
                          P_Init_Msg_List               =>  P_Init_Msg_List,
                          P_Commit                      =>  P_Commit,
                          p_validation_level            =>  p_validation_level,
                          P_Terr_Id                     =>  p_Terr_Id,
                          P_Terr_Qual_Id                =>  p_Terr_Qual_Id,
                          P_Terr_Value_Rec              =>  P_Terr_Value_Tbl(l_counter),
                          X_Return_Status               =>  l_Return_Status,
                          X_Msg_Count                   =>  X_Msg_Count,
                          X_Msg_Data                    =>  X_Msg_Data,
                          X_Terr_Value_Id               =>  l_Terr_Value_id,
                          X_Terr_Value_Out_Rec          =>  l_Terr_Value_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Create_Terr_Value TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Value_Out_Tbl(l_counter).TERR_VALUE_ID  := NULL;
           -- If save the ERROR status for the record
           X_Terr_Value_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Create_Terr_Value TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Value_Out_Tbl(l_counter).TERR_VALUE_ID := l_TERR_VALUE_ID;
           -- If successful then save the success status for the record
           X_Terr_Value_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   -- Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_Terr_Value_Out_Tbl_Count   := X_Terr_Value_Out_Tbl.Count;
   l_Terr_Value_Out_Tbl         := X_Terr_Value_Out_Tbl;

   FOR l_Counter IN 1 ..  l_Terr_Value_Out_Tbl_Count  LOOP
       If l_Terr_Value_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Value_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;
   --
   --
   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --dbms_output('Create_Terr_Value TBL: Exiting API');
--
End Create_Terr_Value;

----------------------------------------------------------------------------------
--                              UPDATE  PROCEDURE STARTS HERE
----------------------------------------------------------------------------------
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_territory
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Territory_Record
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
)
AS
   Cursor C_GetTerritory(l_terr_id Number) IS
          Select Rowid,
                 TERR_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 APPLICATION_SHORT_NAME,
                 NAME,
                 ENABLED_FLAG,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 PLANNED_FLAG,
                 PARENT_TERRITORY_ID,
                 TERRITORY_TYPE_ID,
                 TEMPLATE_TERRITORY_ID,
                 TEMPLATE_FLAG,
                 ESCALATION_TERRITORY_ID,
                 ESCALATION_TERRITORY_FLAG,
                 OVERLAP_ALLOWED_FLAG,
                 RANK,
                 DESCRIPTION,
                 UPDATE_FLAG,
                 AUTO_ASSIGN_RESOURCES_FLAG,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ORG_ID,
                 NUM_WINNERS,
                 NUM_QUAL
          From  JTF_TERR_ALL
          Where TERR_ID = l_terr_id
          For   Update NOWAIT;

      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Update_territory';
      l_rowid                   VARCHAR2(50);
      l_api_version_number      CONSTANT NUMBER   := 1.0;
      l_return_status           VARCHAR2(1);
      l_ref_terr_all_rec        terr_all_rec_type;
 BEGIN
      --dbms_output('Create_Terr_Value TBL: Entering API');

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
      THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_TerrRec_Update');
              FND_MSG_PUB.Add;
           END IF;
           --
           -- Invoke validation procedures
           Validate_TerrRec_Update (p_init_msg_list    => FND_API.G_FALSE,
                                     x_Return_Status    => x_return_status,
                                     x_msg_count        => x_msg_count,
                                     x_msg_data         => x_msg_data,
                                     p_Terr_All_Rec     => P_Terr_All_Rec);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      --dbms_output('Update_territory_Record: opening cursor C_GetTerritory');
      OPEN C_GetTerritory( P_Terr_All_Rec.Terr_Id);

      FETCH C_GetTerritory into
            l_Rowid,
            l_ref_terr_all_rec.TERR_ID,
            l_ref_terr_all_rec.LAST_UPDATE_DATE,
            l_ref_terr_all_rec.LAST_UPDATED_BY,
            l_ref_terr_all_rec.CREATION_DATE,
            l_ref_terr_all_rec.CREATED_BY,
            l_ref_terr_all_rec.LAST_UPDATE_LOGIN,
            l_ref_terr_all_rec.REQUEST_ID,
            l_ref_terr_all_rec.PROGRAM_APPLICATION_ID,
            l_ref_terr_all_rec.PROGRAM_ID,
            l_ref_terr_all_rec.PROGRAM_UPDATE_DATE,
            l_ref_terr_all_rec.APPLICATION_SHORT_NAME,
            l_ref_terr_all_rec.NAME,
            l_ref_terr_all_rec.ENABLED_FLAG,
            l_ref_terr_all_rec.START_DATE_ACTIVE,
            l_ref_terr_all_rec.END_DATE_ACTIVE,
            l_ref_terr_all_rec.PLANNED_FLAG,
            l_ref_terr_all_rec.PARENT_TERRITORY_ID,
            l_ref_terr_all_rec.TERRITORY_TYPE_ID,
            l_ref_terr_all_rec.TEMPLATE_TERRITORY_ID,
            l_ref_terr_all_rec.TEMPLATE_FLAG,
            l_ref_terr_all_rec.ESCALATION_TERRITORY_ID,
            l_ref_terr_all_rec.ESCALATION_TERRITORY_FLAG,
            l_ref_terr_all_rec.OVERLAP_ALLOWED_FLAG,
            l_ref_terr_all_rec.RANK,
            l_ref_terr_all_rec.DESCRIPTION,
            l_ref_terr_all_rec.UPDATE_FLAG,
            l_ref_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG,
            l_ref_terr_all_rec.ATTRIBUTE_CATEGORY,
            l_ref_terr_all_rec.ATTRIBUTE1,
            l_ref_terr_all_rec.ATTRIBUTE2,
            l_ref_terr_all_rec.ATTRIBUTE3,
            l_ref_terr_all_rec.ATTRIBUTE4,
            l_ref_terr_all_rec.ATTRIBUTE5,
            l_ref_terr_all_rec.ATTRIBUTE6,
            l_ref_terr_all_rec.ATTRIBUTE7,
            l_ref_terr_all_rec.ATTRIBUTE8,
            l_ref_terr_all_rec.ATTRIBUTE9,
            l_ref_terr_all_rec.ATTRIBUTE10,
            l_ref_terr_all_rec.ATTRIBUTE11,
            l_ref_terr_all_rec.ATTRIBUTE12,
            l_ref_terr_all_rec.ATTRIBUTE13,
            l_ref_terr_all_rec.ATTRIBUTE14,
            l_ref_terr_all_rec.ATTRIBUTE15,
            l_ref_terr_all_rec.ORG_ID,
            l_ref_terr_all_rec.NUM_WINNERS,
            l_ref_terr_all_rec.NUM_QUAL;

       If ( C_GetTerritory%NOTFOUND) Then
           --dbms_output('Update_territory_Record: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_QTYPE_USGS');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(p_terr_all_rec.terr_id));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       End if;
       CLOSE C_GetTerritory;

       --dbms_output('Update_territory_Record: Before Calling JTF_TERR_PKG.Update_Row');
       JTF_TERR_PKG.Update_Row(x_rowid                 => l_rowid,
                              x_terr_id                    => p_terr_all_rec.terr_id,
                              x_last_update_date           => p_terr_all_rec.LAST_UPDATE_DATE,
                              x_last_updated_by            => p_terr_all_rec.LAST_UPDATED_BY,
                              x_creation_date              => p_terr_all_rec.CREATION_DATE,
                              x_created_by                 => p_terr_all_rec.CREATED_BY,
                              x_last_update_login          => p_terr_all_rec.LAST_UPDATE_LOGIN,
                              x_request_id                 => null,
                              x_program_application_id     => null,
                              x_program_id                 => null,
                              x_program_update_date        => null,
                              x_application_short_name     => p_terr_all_rec.application_short_name,
                              x_name                       => p_terr_all_rec.name,
                              -- x_enabled_flag               => p_terr_all_rec.enabled_flag,
                              x_start_date_active          => p_terr_all_rec.start_date_active,
                              x_end_date_active            => p_terr_all_rec.end_date_active,
                              x_planned_flag               => p_terr_all_rec.planned_flag,
                              x_parent_territory_id        => p_terr_all_rec.parent_territory_id,
                              --One Can't update the Territory Type in R12. -- VPALLE
                              -- x_territory_type_id          => p_terr_all_rec.territory_type_id,
                              x_template_territory_id      => p_terr_all_rec.template_territory_id,
                              x_template_flag              => p_terr_all_rec.template_flag,
                              x_escalation_territory_id    => p_terr_all_rec.escalation_territory_id,
                              x_escalation_territory_flag  => p_terr_all_rec.escalation_territory_flag,
                              x_overlap_allowed_flag       => p_terr_all_rec.overlap_allowed_flag,
                              x_rank                       => p_terr_all_rec.rank,
                              x_description                => p_terr_all_rec.description,
                              x_update_flag                => p_terr_all_rec.update_flag,
                              x_auto_assign_resources_flag => p_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG,
                              x_attribute_category         => p_terr_all_rec.attribute_category,
                              x_attribute1                 => p_terr_all_rec.attribute1,
                              x_attribute2                 => p_terr_all_rec.attribute2,
                              x_attribute3                 => p_terr_all_rec.attribute3,
                              x_attribute4                 => p_terr_all_rec.attribute4,
                              x_attribute5                 => p_terr_all_rec.attribute5,
                              x_attribute6                 => p_terr_all_rec.attribute6,
                              x_attribute7                 => p_terr_all_rec.attribute7,
                              x_attribute8                 => p_terr_all_rec.attribute8,
                              x_attribute9                 => p_terr_all_rec.attribute9,
                              x_attribute10                => p_terr_all_rec.attribute10,
                              x_attribute11                => p_terr_all_rec.attribute11,
                              x_attribute12                => p_terr_all_rec.attribute12,
                              x_attribute13                => p_terr_all_rec.attribute13,
                              x_attribute14                => p_terr_all_rec.attribute14,
                              x_attribute15                => p_terr_all_rec.attribute15,
                              -- We can't update the ORG_ID   -- VPALLE
                              x_org_id                     => FND_API.G_MISS_NUM,
                              x_num_winners                => p_terr_all_rec.NUM_WINNERS,
                              x_num_qual                   => p_terr_all_rec.NUM_QUAL);

       X_Terr_All_Out_Rec.Terr_id          := P_Terr_All_Rec.Terr_Id;
       X_Terr_All_Out_Rec.return_status    := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      --dbms_output('Update_territory_Record PVT: Exiting API');
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output('Validate_Territory_Record: FND_API.G_EXC_ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
          (  P_count          =>   x_msg_count,
             P_data           =>   x_msg_data
          );


     WHEN OTHERS THEN
          --dbms_output('Update_territory_Record PVT: OTHERS - ' || SQLERRM);
          X_return_status                  := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_All_Out_Rec.Terr_id       := P_Terr_All_Rec.Terr_Id;
          X_Terr_All_Out_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Update error inside Update_Territory_Record');
          END IF;
--
End Update_territory_Record;
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Territory_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_Terr_Usgs_Rec             Terr_Usgs_Rec_Type      G_MISS_TERR_USGS_REC
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_Terr_Usgs_Out_Rec         Terr_Usgs_Out_Rec_Type
--
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2            := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2            := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER              := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Usgs_Rec               IN  Terr_Usgs_Rec_Type  := G_MISS_TERR_USGS_REC,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Rec           OUT NOCOPY Terr_Usgs_Out_Rec_Type
)
AS
   Cursor C_GetTerritoryUsage(l_terr_usg_id Number) IS
          Select Rowid,
                 TERR_USG_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 TERR_ID,
                 SOURCE_ID
          From   JTF_TERR_USGS_ALL
          Where  terr_usg_id = l_terr_usg_id
          FOR    Update NOWAIT;
      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Update_territory_Usages';
      l_rowid                   VARCHAR2(50);
      l_api_version_number      CONSTANT NUMBER   := 1.0;
      l_return_status           VARCHAR2(1);
      l_ref_terr_Usg_rec        Terr_Usgs_Rec_Type;
 BEGIN
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Territory_Usage');
              FND_MSG_PUB.Add;
           END IF;
           --
           -- Invoke validation procedures
           Validate_Territory_Usage(p_init_msg_list    => FND_API.G_FALSE,
                                    x_Return_Status    => x_return_status,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data,
                                    p_Terr_Id          => P_Terr_Usgs_Rec.Terr_Id,
                                    P_Terr_Usgs_Rec    => P_Terr_Usgs_Rec);
           --
           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
      --
      END IF;

      --dbms_output('Update_Territory_Usages PVT: Entering API');
      OPEN  C_GetTerritoryUsage( P_Terr_Usgs_Rec.Terr_Usg_Id);

      --dbms_output('Update_Territory_Usages PVT: Opening cursor C_GetTerritoryUsage');
      FETCH C_GetTerritoryUsage into
            l_Rowid,
            l_ref_terr_Usg_rec.TERR_USG_ID,
            l_ref_terr_Usg_rec.LAST_UPDATE_DATE,
            l_ref_terr_Usg_rec.LAST_UPDATED_BY,
            l_ref_terr_Usg_rec.CREATION_DATE,
            l_ref_terr_Usg_rec.CREATED_BY,
            l_ref_terr_Usg_rec.LAST_UPDATE_LOGIN,
            l_ref_terr_Usg_rec.TERR_ID,
            l_ref_terr_Usg_rec.SOURCE_ID;

       If ( C_GetTerritoryUsage%NOTFOUND) Then
           --dbms_output('Update_Territory_Usages PVT: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_QTYPE_USGS');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_Terr_Usgs_Rec.terr_usg_id));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       End if;
       CLOSE C_GetTerritoryUsage;

       --dbms_output('Update_Territory_Usages PVT: Before Calling JTF_TERR_USGS_PKG.Update_Row');
       -- Call insert terr_Qual_Type_Usgs table handler
       JTF_TERR_USGS_PKG.Update_Row(x_Rowid                     => l_rowid,
                                    x_TERR_USG_ID               => P_Terr_Usgs_Rec.terr_usg_id,
                                    x_LAST_UPDATE_DATE          => P_Terr_Usgs_Rec.LAST_UPDATE_DATE,
                                    x_LAST_UPDATED_BY           => P_Terr_Usgs_Rec.LAST_UPDATED_BY,
                                    x_CREATION_DATE             => P_Terr_Usgs_Rec.CREATION_DATE,
                                    x_CREATED_BY                => P_Terr_Usgs_Rec.CREATED_BY,
                                    x_LAST_UPDATE_LOGIN         => P_Terr_Usgs_Rec.LAST_UPDATE_LOGIN,
                                    x_TERR_ID                   => P_Terr_Usgs_Rec.Terr_Id,
                                    x_SOURCE_ID                 => P_Terr_Usgs_Rec.source_id,
                                    x_ORG_ID                    => P_Terr_Usgs_Rec.org_id);

       X_Terr_Usgs_Out_Rec.TERR_USG_ID      := P_Terr_Usgs_Rec.Terr_Usg_Id;
       X_Terr_Usgs_Out_Rec.return_status    := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
       THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
       END IF;

       --dbms_output('Update_Territory_Usages PVT: Exiting API');
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output('Update_Territory_Usages: FND_API.G_EXC_ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
          (  P_count          =>   x_msg_count,
             P_data           =>   x_msg_data
          );


     WHEN OTHERS THEN
          --dbms_output('Update_Territory_Usages PVT: OTHERS - ' || SQLERRM);
          X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_Usgs_Out_Rec.Terr_Usg_Id   := P_Terr_Usgs_Rec.Terr_Usg_Id;
          X_Terr_Usgs_Out_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Update error inside Update_Territory_Usages');
          END IF;
--
End Update_Territory_Usages;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Territory_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_Terr_Usgs_Tbl             Terr_Usgs_Tbl_Type      G_MISS_TERR_USGS_TBL
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_Terr_Usgs_Out_Tbl         Terr_Usgs_Out_Tbl_Type
--
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type
)
AS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Update_territory_Usages (Tbl)';
  l_rowid                       ROWID;
  l_return_Status               VARCHAR2(1);
  l_terr_qual_type_usg_id       NUMBER;
  l_Terr_Usgs_Tbl_Count         NUMBER                := P_Terr_Usgs_Tbl.Count;
  l_Terr_Usgs_Out_Tbl_Count     NUMBER;
  l_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl_Type;
  l_Terr_Usg_Out_Rec            Terr_Usgs_Out_Rec_Type;
  l_Counter                     NUMBER;
BEGIN
   --dbms_output('Update_Territory_Usages TBL: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call insert terr_Qual_Type_Usgs table handler
   --
   FOR l_Counter IN 1 ..  l_Terr_Usgs_Tbl_Count LOOP
   --
       --dbms_output('Update_Territory_Usages TBL: Before Calling Update_Territory_Usages');
       Update_Territory_Usages( P_Api_Version_Number          =>  P_Api_Version_Number,
                                P_Init_Msg_List               =>  P_Init_Msg_List,
                                P_Commit                      =>  P_Commit,
                                p_validation_level            =>  p_validation_level,
                                P_Terr_Usgs_Rec               =>  P_Terr_Usgs_Tbl(l_counter),
                                X_Return_Status               =>  l_Return_Status,
                                X_Msg_Count                   =>  X_Msg_Count,
                                X_Msg_Data                    =>  X_Msg_Data,
                                X_Terr_Usgs_Out_Rec           =>  l_Terr_Usg_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Update_Territory_Usages TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Usgs_Out_Tbl(l_counter).TERR_USG_ID  := l_Terr_Usg_Out_Rec.terr_usg_id;
           -- If save the ERROR status for the record
           X_Terr_Usgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Update_Territory_Usages TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Usgs_Out_Tbl(l_counter).TERR_USG_ID := l_Terr_Usg_Out_Rec.terr_usg_id;
           -- If successful then save the success status for the record
           X_Terr_Usgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   --Get number of records in the ouput table
   l_Terr_Usgs_Out_Tbl_Count     := X_Terr_Usgs_Out_Tbl.Count;
   l_Terr_Usgs_Out_Tbl           := X_Terr_Usgs_Out_Tbl;

   --
   -- Get the API overall return status
   FOR l_Counter IN 1 ..  l_Terr_Usgs_Out_Tbl_Count LOOP
       If l_Terr_Usgs_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Usgs_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;
   --dbms_output('Update_Territory_Usages TBL: Exiting API');
--
END Update_Territory_Usages;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Terr_QualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type                      Default
--     P_Terr_QualTypeUsgs_Rec     Terr_QualTypeUsgs_Rec_Type     G_Miss_Terr_QualTypeUsgs_Rec
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type                      Default
--     X_Return_Status             VARCHAR2
--     X_Terr_QualTypeUsgs_Out_Rec Terr_QualTypeUsgs_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Rec   OUT NOCOPY Terr_QualTypeUsgs_Out_Rec_Type
)
AS
   Cursor C_GetTerrQualTypeUsgs(l_terr_qual_type_usg_id Number) IS
          Select rowid,
                 TERR_QTYPE_USG_ID,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATE_LOGIN,
                 TERR_ID,
                 QUAL_TYPE_USG_ID
        From     JTF_TERR_QTYPE_USGS_ALL
        Where    terr_qtype_usg_id = l_terr_qual_type_usg_id
        FOR      Update NOWAIT;
      --Local variable declaration
      l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Terr_QualType_Usage';
      l_rowid                      VARCHAR2(50);
      l_api_version_number         CONSTANT NUMBER   := 1.0;
      l_return_status              VARCHAR2(1);
      l_ref_Terr_QualTypeUsgs_Rec  Terr_QualTypeUsgs_Rec_Type;
 BEGIN
     --dbms_output('Update_Terr_QualType_Usage REC: Entering API');

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
     THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
     THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Qtype_Usage');
              FND_MSG_PUB.Add;
           END IF;
           -- Invoke validation procedures
           Validate_Terr_Qtype_Usage(p_init_msg_list         => FND_API.G_FALSE,
                                     x_Return_Status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data,
                                     p_Terr_Id               => P_Terr_QualTypeUsgs_Rec.Terr_Id,
                                     P_Terr_QualTypeUsgs_Rec => P_Terr_QualTypeUsgs_Rec);
           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           --
      END IF;

      --dbms_output('Update_Terr_QualType_Usage REC: opening cursor C_GetTerrQualTypeUsgs');
      OPEN  C_GetTerrQualTypeUsgs( P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID);
      FETCH C_GetTerrQualTypeUsgs into
            l_Rowid,
            l_ref_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID,
            l_ref_Terr_QualTypeUsgs_Rec.LAST_UPDATED_BY,
            l_ref_Terr_QualTypeUsgs_Rec.LAST_UPDATE_DATE,
            l_ref_Terr_QualTypeUsgs_Rec.CREATED_BY,
            l_ref_Terr_QualTypeUsgs_Rec.CREATION_DATE,
            l_ref_Terr_QualTypeUsgs_Rec.LAST_UPDATE_LOGIN,
            l_ref_Terr_QualTypeUsgs_Rec.TERR_ID,
            l_ref_Terr_QualTypeUsgs_Rec.QUAL_TYPE_USG_ID;
       If (C_GetTerrQualTypeUsgs%NOTFOUND) Then
           --dbms_output('Update_Terr_QualType_Usage REC: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_QTYPE_USGS');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       End if;
       CLOSE C_GetTerrQualTypeUsgs;

       --dbms_output('Update_Terr_QualType_Usage REC: Before Calling JTF_TERR_QTYPE_USGS_PKG.Update_Row');
       JTF_TERR_QTYPE_USGS_PKG.Update_Row(x_Rowid                   => l_rowid,
                                          x_TERR_QTYPE_USG_ID       => P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID,
                                          x_LAST_UPDATED_BY         => P_Terr_QualTypeUsgs_Rec.LAST_UPDATED_BY,
                                          x_LAST_UPDATE_DATE        => P_Terr_QualTypeUsgs_Rec.LAST_UPDATE_DATE,
                                          x_CREATED_BY              => P_Terr_QualTypeUsgs_Rec.CREATED_BY,
                                          x_CREATION_DATE           => P_Terr_QualTypeUsgs_Rec.CREATION_DATE,
                                          x_LAST_UPDATE_LOGIN       => P_Terr_QualTypeUsgs_Rec.LAST_UPDATE_LOGIN,
                                          x_TERR_ID                 => P_Terr_QualTypeUsgs_Rec.terr_id,
                                          x_QUAL_TYPE_USG_ID        => P_Terr_QualTypeUsgs_Rec.QUAL_TYPE_USG_ID,
                                          x_ORG_ID                  => P_Terr_QualTypeUsgs_Rec.ORG_ID);
       --
       X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID     := P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID;
       X_Terr_QualTypeUsgs_Out_Rec.return_status             := FND_API.G_RET_STS_SUCCESS;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
       THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
       END IF;

       --dbms_output('Update_Terr_QualType_Usage REC: Exiting API');
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output('Update_Terr_QualType_Usage: FND_API.G_EXC_ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
          (  P_count          =>   x_msg_count,
             P_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Update_Terr_QualType_Usage REC: OTHERS - ' || SQLERRM);
          X_return_status                                    := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_QualTypeUsgs_Out_Rec.TERR_QUAL_TYPE_USG_ID  := P_Terr_QualTypeUsgs_Rec.TERR_QUAL_TYPE_USG_ID;
          X_Terr_QualTypeUsgs_Out_Rec.return_status          := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Error: Inside Update_Terr_QualType_Usage');
          END IF;
--
End Update_Terr_QualType_Usage;
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Terr_QualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type                       Default
--     P_Terr_QualTypeUsgs_Tbl     Terr_QualTypeUsgs_Tbl_Type      G_Miss_Terr_QualTypeUsgs_Tbl
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type                       Default
--     X_Return_Status             VARCHAR2
--     X_Terr_QualTypeUsgs_Out_Tbl Terr_QualTypeUsgs_Out_Tbl_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type
)
AS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Terr_QualType_Usage Tbl';
  l_rowid                       ROWID;
  l_return_Status               VARCHAR2(1);
  l_terr_qual_type_usg_id       NUMBER;
  l_Terr_QualTypeUsgs_Tbl_Count NUMBER                := P_Terr_QualTypeUsgs_Tbl.Count;
  l_Terr_QTypUsg_Out_Tbl_Count  NUMBER;
  l_Terr_QTypUsg_Out_Tbl        Terr_QualTypeUsgs_Out_Tbl_Type;
  l_Terr_QTypUsg_Out_Rec        Terr_QualTypeUsgs_Out_Rec_Type;
  l_Counter                     NUMBER;
BEGIN
   --dbms_output('Update_Terr_QualType_Usage TBL: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Call insert terr_Qual_Type_Usgs table handler
   --
   FOR l_Counter IN 1 ..  l_Terr_QualTypeUsgs_Tbl_Count LOOP
   --
       --dbms_output('Update_Terr_QualType_Usage TBL: Before Calling Create_TerrType_Qualifier TBL');
       Update_Terr_QualType_Usage( P_Api_Version_Number          =>  P_Api_Version_Number,
                                   P_Init_Msg_List               =>  P_Init_Msg_List,
                                   P_Commit                      =>  P_Commit,
                                   p_validation_level            =>  p_validation_level,
                                   P_Terr_QualTypeUsgs_Rec       =>  P_Terr_QualTypeUsgs_Tbl(l_counter),
                                   X_Return_Status               =>  l_Return_Status,
                                   X_Msg_Count                   =>  X_Msg_Count,
                                   X_Msg_Data                    =>  X_Msg_Data,
                                   X_Terr_QualTypeUsgs_Out_Rec   =>  l_Terr_QTypUsg_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Update_Terr_QualType_Usage TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).TERR_QUAL_TYPE_USG_ID  := l_Terr_QTypUsg_Out_Rec.terr_qual_type_usg_id;
           -- If save the ERROR status for the record
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Update_Terr_QualType_Usage TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).TERR_QUAL_TYPE_USG_ID := l_Terr_QTypUsg_Out_Rec.terr_qual_type_usg_id;
           -- If successful then save the success status for the record
           X_Terr_QualTypeUsgs_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_Terr_QTypUsg_Out_Tbl_Count  := X_Terr_QualTypeUsgs_Out_Tbl.Count;
   l_Terr_QTypUsg_Out_Tbl        := X_Terr_QualTypeUsgs_Out_Tbl;

   --Get the API overall return status
   FOR l_Counter IN 1 ..  l_Terr_QTypUsg_Out_Tbl_Count LOOP
       If l_Terr_QTypUsg_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_QTypUsg_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --dbms_output('Update_Terr_QualType_Usage TBL: Exiting API');
--
END Update_Terr_QualType_Usage;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Terr_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Terr_Qual_Rec               Terr_Qual_Rec_Type               := G_Miss_Terr_Qual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type               := G_Miss_Terr_Qual_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Rec           OUT NOCOPY Terr_Qual_Out_Rec_Type
)
AS
   Cursor C_GetTerrQualifier(l_terr_qual_id Number) IS
          Select Rowid,
                 TERR_QUAL_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 TERR_ID,
                 QUAL_USG_ID,
                 USE_TO_NAME_FLAG,
                 GENERATE_FLAG,
                 OVERLAP_ALLOWED_FLAG
          From   JTF_TERR_QUAL_ALL
          Where  terr_qual_id = l_terr_qual_id
          FOR    Update NOWAIT;
      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Update_Terr_Qualifier';
      l_rowid                   VARCHAR2(50);
      l_api_version_number      CONSTANT NUMBER   := 1.0;
      l_return_status           VARCHAR2(1);
      l_ref_Terr_Qual_Rec       Terr_Qual_Rec_type;
 BEGIN
      --dbms_output('Update_Terr_Qualifier  REC: Entering API');

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Qualifier');
              FND_MSG_PUB.Add;
           END IF;
           --
           -- Invoke validation procedures
           Validate_Qualifier(p_init_msg_list         => FND_API.G_FALSE,
                              x_Return_Status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data,
                              p_Terr_Id               => P_Terr_Qual_Rec.Terr_Id,
                              P_Terr_Qual_Rec         => P_Terr_Qual_Rec);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
      --
      END IF;

      --dbms_output('Update_Terr_Qualifier  REC: opening cursor C_GetTerrQualifier');
      OPEN C_GetTerrQualifier( P_Terr_Qual_Rec.TERR_QUAL_ID);

      Fetch C_GetTerrQualifier into
               l_Rowid,
               l_ref_Terr_Qual_Rec.TERR_QUAL_ID,
               l_ref_Terr_Qual_Rec.LAST_UPDATE_DATE,
               l_ref_Terr_Qual_Rec.LAST_UPDATED_BY,
               l_ref_Terr_Qual_Rec.CREATION_DATE,
               l_ref_Terr_Qual_Rec.CREATED_BY,
               l_ref_Terr_Qual_Rec.LAST_UPDATE_LOGIN,
               l_ref_Terr_Qual_Rec.TERR_ID,
               l_ref_Terr_Qual_Rec.QUAL_USG_ID,
               l_ref_Terr_Qual_Rec.USE_TO_NAME_FLAG,
               l_ref_Terr_Qual_Rec.GENERATE_FLAG,
               l_ref_Terr_Qual_Rec.OVERLAP_ALLOWED_FLAG;
       If ( C_GetTerrQualifier%NOTFOUND) Then
           --dbms_output('Update_Terr_Qualifier  REC: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_QUAL');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_Terr_Qual_Rec.terr_qual_id));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       End if;
       CLOSE C_GetTerrQualifier;
       -- P_Terr_Qual_Rec.terr_qual_id cant be null
       --dbms_output('Update_Terr_Qualifier  REC: Before Calling JTF_TERR_QUAL_PKG.Update_Row');
       JTF_TERR_QUAL_PKG.Update_Row(x_Rowid                      => l_rowid,
                                x_TERR_QUAL_ID                   => P_Terr_Qual_Rec.terr_qual_id,
                                x_LAST_UPDATE_DATE               => P_Terr_Qual_Rec.LAST_UPDATE_DATE,
                                x_LAST_UPDATED_BY                => P_Terr_Qual_Rec.LAST_UPDATED_BY,
                                x_CREATION_DATE                  => P_Terr_Qual_Rec.creation_date,
                                x_CREATED_BY                     => P_Terr_Qual_Rec.created_by,
                                x_LAST_UPDATE_LOGIN              => P_Terr_Qual_Rec.LAST_UPDATE_LOGIN,
                                x_TERR_ID                        => P_Terr_Qual_Rec.Terr_Id,
                                x_QUAL_USG_ID                    => P_Terr_Qual_Rec.QUAL_USG_ID,
                                x_USE_TO_NAME_FLAG               => P_Terr_Qual_Rec.USE_TO_NAME_FLAG,
                                x_GENERATE_FLAG                  => P_Terr_Qual_Rec.GENERATE_FLAG,
                                x_OVERLAP_ALLOWED_FLAG           => P_Terr_Qual_Rec.OVERLAP_ALLOWED_FLAG,
                                x_QUALIFIER_MODE                 => P_Terr_Qual_Rec.QUALIFIER_MODE,
                                -- We can't update the ORG_ID   -- VPALLE
                                x_ORG_ID                         => FND_API.G_MISS_NUM );

       --Call the update table handler
       X_Terr_Qual_Out_Rec.TERR_QUAL_ID     := P_Terr_Qual_Rec.TERR_QUAL_ID;
       X_Terr_Qual_Out_Rec.return_status    := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
       THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
       END IF;

       --dbms_output('Update_Terr_Qualifier  REC: Exiting API');
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output('Validate_Territory_Record: FND_API.G_EXC_ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
          (  P_count          =>   x_msg_count,
             P_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Update_Terr_Qualifier  REC: OTHERS - ' || SQLERRM);
          X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_Qual_Out_Rec.TERR_QUAL_ID  := P_Terr_Qual_Rec.TERR_QUAL_ID;
          X_Terr_Qual_Out_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Update error inside Update_Terr_Qualifier');
          END IF;
End  Update_Terr_Qualifier;
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Terr_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Terr_Qual_Rec               Terr_Qual_Rec_Type               := G_Miss_Terr_Qual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type
)
AS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Terr_Qualifier (Tbl)';
  l_terr_qual_id                NUMBER;
  l_return_Status               VARCHAR2(1);
  l_Terr_Qual_Tbl_Count         NUMBER                := P_Terr_Qual_Tbl.Count;
  l_Terr_Qual_Out_Tbl_Count     NUMBER;
  l_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl_Type;
  l_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type;
  l_Counter                     NUMBER;
BEGIN
   --dbms_output('Update_Terr_Qualifier TBL: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_Terr_Qual_Tbl_Count LOOP
   --
       --dbms_output('Update_Terr_Qualifier TBL: Before Calling Create_TerrType_Qualifier TBL');
       Update_Terr_Qualifier( P_Api_Version_Number          =>  P_Api_Version_Number,
                              P_Init_Msg_List               =>  P_Init_Msg_List,
                              P_Commit                      =>  P_Commit,
                              p_validation_level            =>  p_validation_level,
                              P_Terr_Qual_Rec               =>  P_Terr_Qual_Tbl(l_counter),
                              X_Return_Status               =>  l_Return_Status,
                              X_Msg_Count                   =>  X_Msg_Count,
                              X_Msg_Data                    =>  X_Msg_Data,
                              X_Terr_Qual_Out_Rec           =>  l_Terr_Qual_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Update_Terr_Qualifier TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Qual_Out_Tbl(l_counter).TERR_QUAL_ID  := l_Terr_Qual_Out_Rec.TERR_QUAL_ID;
           -- If save the ERROR status for the record
           X_Terr_Qual_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Update_Terr_Qualifier TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Qual_Out_Tbl(l_counter).TERR_QUAL_ID := l_Terr_Qual_Out_Rec.TERR_QUAL_ID;
           -- If successful then save the success status for the record
           X_Terr_Qual_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;
   --Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --Get number of records in the ouput table
   l_Terr_Qual_Out_Tbl_Count  := X_Terr_Qual_Out_Tbl.Count;
   l_Terr_Qual_Out_Tbl        := X_Terr_Qual_Out_Tbl;
   FOR l_Counter IN 1 ..  l_Terr_Qual_Out_Tbl_Count  LOOP
       If l_Terr_Qual_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Qual_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;
   --dbms_output('Update_Terr_Qualifier TBL: Exiting API');
--
END Update_Terr_Qualifier;
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Terr_Value
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Terr_Value_Rec              Terr_Values_Rec_Type             := G_Miss_Terr_Value_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_Terr_Value_Out_Tbl          Terr_Values_Out_Tbl_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_Terr_Value
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Value_Rec              IN  Terr_Values_Rec_Type             := G_Miss_Terr_Values_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Rec          OUT NOCOPY Terr_Values_Out_Rec_Type
)
AS
   Cursor C_GetTerritoryValue(l_TERR_VALUE_ID Number) IS
          Select Rowid,
               TERR_VALUE_ID,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATE_LOGIN,
               TERR_QUAL_ID,
               INCLUDE_FLAG,
               COMPARISON_OPERATOR,
               LOW_VALUE_CHAR,
               HIGH_VALUE_CHAR,
               LOW_VALUE_NUMBER,
               HIGH_VALUE_NUMBER,
               VALUE_SET,
               INTEREST_TYPE_ID,
               PRIMARY_INTEREST_CODE_ID,
               SECONDARY_INTEREST_CODE_ID,
               CURRENCY_CODE,
               ID_USED_FLAG,
               LOW_VALUE_CHAR_ID,
               ORG_ID,
               CNR_GROUP_ID
        From  JTF_TERR_VALUES_ALL
        Where TERR_VALUE_ID = l_TERR_VALUE_ID
        For   Update NOWAIT;

   Cursor C_GetTerr_qual_id(l_TERR_VALUE_ID Number) IS
        Select TERR_QUAL_ID
        From  JTF_TERR_VALUES_ALL
        Where TERR_VALUE_ID = l_TERR_VALUE_ID ;

      --Local variable declaration
      l_api_name                CONSTANT VARCHAR2(30) := 'Update_Terr_Value';
      l_rowid                   VARCHAR2(50);
      l_api_version_number      CONSTANT NUMBER   := 1.0;
      l_return_status           VARCHAR2(1);
      l_ref_Terr_Value_Rec      Terr_Values_Rec_type;
BEGIN
      --dbms_output('Update_Terr_Value REC: Entering API');

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
         FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --dbms_output('Update_Terr_Value REC: opening cursor C_GetTerritoryValue');
      OPEN C_GetTerr_qual_id( P_Terr_Value_Rec.TERR_VALUE_ID);

      FETCH C_GetTerr_qual_id into
            l_ref_Terr_Value_Rec.TERR_QUAL_ID;
       --
       If ( C_GetTerr_qual_id%NOTFOUND) Then
       --
           --dbms_output('Update_Terr_Value REC: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_VALUES');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_Terr_Value_Rec.TERR_VALUE_ID));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;

       End if;
       CLOSE C_GetTerr_qual_id;

             -- Check the validation level
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
           -- Debug message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
              FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_terr_Value_Rec');
              FND_MSG_PUB.Add;
           END IF;

           -- Invoke validation procedures
           Validate_Terr_Value_Rec(p_init_msg_list    => FND_API.G_FALSE,
                                   x_return_status    => x_return_status,
                                   x_msg_count        => x_msg_count,
                                   x_msg_data         => x_msg_data,
                                   p_terr_qual_id     => nvl(P_Terr_Value_Rec.terr_qual_id, l_ref_Terr_Value_Rec.TERR_QUAL_ID),
                                   p_Terr_Value_Rec   => P_Terr_Value_Rec);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;
               -- Check for duplicate values
                -- Invoke validation procedures
        Check_duplicate_Value_update(p_init_msg_list    => FND_API.G_FALSE,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_terr_qual_id     => nvl(P_Terr_Value_Rec.terr_qual_id, l_ref_Terr_Value_Rec.TERR_QUAL_ID),
                                p_Terr_Value_Rec   => P_Terr_Value_Rec);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
       --
       -- Add check for concurrency
       -- X_TERR_VALUE_ID cant be null
      OPEN C_GetTerritoryValue( P_Terr_Value_Rec.TERR_VALUE_ID);

      FETCH C_GetTerritoryValue into
            l_Rowid,
            l_ref_Terr_Value_Rec.TERR_VALUE_ID,
            l_ref_Terr_Value_Rec.LAST_UPDATED_BY,
            l_ref_Terr_Value_Rec.LAST_UPDATE_DATE,
            l_ref_Terr_Value_Rec.CREATED_BY,
            l_ref_Terr_Value_Rec.CREATION_DATE,
            l_ref_Terr_Value_Rec.LAST_UPDATE_LOGIN,
            l_ref_Terr_Value_Rec.TERR_QUAL_ID,
            l_ref_Terr_Value_Rec.INCLUDE_FLAG,
            l_ref_Terr_Value_Rec.COMPARISON_OPERATOR,
            l_ref_Terr_Value_Rec.LOW_VALUE_CHAR,
            l_ref_Terr_Value_Rec.HIGH_VALUE_CHAR,
            l_ref_Terr_Value_Rec.LOW_VALUE_NUMBER,
            l_ref_Terr_Value_Rec.HIGH_VALUE_NUMBER,
            l_ref_Terr_Value_Rec.VALUE_SET,
            l_ref_Terr_Value_Rec.INTEREST_TYPE_ID,
            l_ref_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID,
            l_ref_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID,
            l_ref_Terr_Value_Rec.CURRENCY_CODE,
            l_ref_Terr_Value_Rec.ID_USED_FLAG,
            l_ref_Terr_Value_Rec.LOW_VALUE_CHAR_ID,
            l_ref_Terr_Value_Rec.ORG_ID,
            l_ref_Terr_Value_Rec.CNR_GROUP_ID;
       --
       If ( C_GetTerritoryValue%NOTFOUND) Then
       --
           --dbms_output('Update_Terr_Value REC: NO-RCORDS-FOUND');
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_UPDT_TARGET');
              FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_VALUES');
              FND_MESSAGE.Set_Token('PK_ID', TO_CHAR(P_Terr_Value_Rec.TERR_VALUE_ID));
              FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;

       End if;
       CLOSE C_GetTerritoryValue;
       --dbms_output('Update_Terr_Value REC: Before Calling JTF_TERR_VALUES_PKG.Update_Row');
       --call the table handler
       JTF_TERR_VALUES_PKG.Update_Row(x_Rowid                       => l_rowid,
                                      x_TERR_VALUE_ID               => P_Terr_Value_Rec.TERR_VALUE_ID,
                                      x_LAST_UPDATED_BY             => P_Terr_Value_Rec.LAST_UPDATED_BY,
                                      x_LAST_UPDATE_DATE            => P_Terr_Value_Rec.LAST_UPDATE_DATE,
                                      x_CREATED_BY                  => P_Terr_Value_Rec.created_by,
                                      x_CREATION_DATE               => P_Terr_Value_Rec.creation_date,
                                      x_LAST_UPDATE_LOGIN           => P_Terr_Value_Rec.LAST_UPDATE_LOGIN,
                                       x_TERR_QUAL_ID                => P_Terr_Value_Rec.terr_qual_id,
                                      x_INCLUDE_FLAG                => P_Terr_Value_Rec.INCLUDE_FLAG,
                                      x_COMPARISON_OPERATOR         => P_Terr_Value_Rec.COMPARISON_OPERATOR,
                                      x_LOW_VALUE_CHAR              => P_Terr_Value_Rec.LOW_VALUE_CHAR,
                                      x_HIGH_VALUE_CHAR             => P_Terr_Value_Rec.HIGH_VALUE_CHAR,
                                      x_LOW_VALUE_NUMBER            => P_Terr_Value_Rec.LOW_VALUE_NUMBER,
                                      x_HIGH_VALUE_NUMBER           => P_Terr_Value_Rec.HIGH_VALUE_NUMBER,
                                      x_VALUE_SET                   => P_Terr_Value_Rec.VALUE_SET,
                                      x_INTEREST_TYPE_ID            => P_Terr_Value_Rec.INTEREST_TYPE_ID,
                                      x_PRIMARY_INTEREST_CODE_ID    => P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID,
                                      x_SECONDARY_INTEREST_CODE_ID  => P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID,
                                      x_CURRENCY_CODE               => P_Terr_Value_Rec.CURRENCY_CODE,
                                      x_ID_USED_FLAG                => P_Terr_Value_Rec.ID_USED_FLAG,
                                      x_LOW_VALUE_CHAR_ID           => P_Terr_Value_Rec.LOW_VALUE_CHAR_ID,
                                      -- Can't update the ORG_ID  -- VPALLE
                                      x_ORG_ID                      => FND_API.G_MISS_NUM,
                                      x_CNR_GROUP_ID                => P_Terr_Value_Rec.CNR_GROUP_ID,
                                      x_VALUE1_ID                   => p_terr_value_rec.VALUE1_ID,
                                      x_VALUE2_ID                   => p_terr_value_rec.VALUE2_ID,
                                      x_VALUE3_ID                   => p_terr_value_rec.VALUE3_ID,
                                      x_VALUE4_ID                   => p_terr_value_rec.VALUE4_ID );

       X_Terr_Value_Out_Rec.TERR_VALUE_ID         := P_Terr_Value_Rec.TERR_VALUE_ID;
       X_Terr_Value_Out_Rec.return_status         := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
       THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
          FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
       END IF;

       --dbms_output('Update_Terr_Value REC: Exiting API');
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output('Validate_Territory_Record: FND_API.G_EXC_ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
          (  P_count          =>   x_msg_count,
             P_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Update_Terr_Value REC: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          X_Terr_Value_Out_Rec.TERR_VALUE_ID := P_Terr_Value_Rec.TERR_VALUE_ID;
          X_Terr_Value_Out_Rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Update error inside Update_Terr_Value');
          END IF;
End Update_Terr_Value;

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Value
--    Type      : PRIVATE
--    Function  : To create Territories qualifier values
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Terr_Value_Tbl              Terr_Values_Tbl_Type             := G_Miss_Terr_Value_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_Value_Out_Tbl          Terr_Values_Out_Tbl_Type
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--
PROCEDURE Update_Terr_Value
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Value_Tbl              IN  Terr_Values_Tbl_Type             := G_Miss_Terr_Values_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Tbl          OUT NOCOPY Terr_Values_Out_Tbl_Type
)
AS
  l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Terr_Value (Tbl)';
  l_return_Status               VARCHAR2(1);
  l_Terr_Value_Tbl_Count        NUMBER                          := P_Terr_Value_Tbl.Count;
  l_Terr_Value_Out_Tbl_Count    NUMBER;
  l_Terr_Value_Out_Tbl          Terr_Values_Out_Tbl_Type;
  l_Terr_Value_Out_Rec          Terr_Values_Out_Rec_Type;
  l_Terr_Qual_Tbl               Terr_Qual_Tbl_Type;
  l_Counter                     NUMBER;
BEGIN
   --dbms_output('Update_Terr_Value TBL: Entering API');

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- -- Call overloaded Create_Terr_Qualifier procedure
   --
   FOR l_Counter IN 1 ..  l_Terr_Value_Tbl_Count LOOP
   --
       --dbms_output('Update_Terr_Value TBL: Before Calling Update_Terr_Value');
       Update_Terr_Value( P_Api_Version_Number          =>  P_Api_Version_Number,
                          P_Init_Msg_List               =>  P_Init_Msg_List,
                          P_Commit                      =>  P_Commit,
                          p_validation_level            =>  p_validation_level,
                          P_Terr_Value_Rec              =>  P_Terr_Value_Tbl(l_counter),
                          X_Return_Status               =>  l_Return_Status,
                          X_Msg_Count                   =>  X_Msg_Count,
                          X_Msg_Data                    =>  X_Msg_Data,
                          X_Terr_Value_Out_Rec          =>  l_Terr_Value_Out_Rec);
       --
       --If there is a major error
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --dbms_output('Update_Terr_Value TBL: l_return_status <> FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Value_Out_Tbl(l_counter).TERR_VALUE_ID := l_Terr_Value_Out_Rec.TERR_VALUE_ID;
           -- If save the ERROR status for the record
           X_Terr_Value_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSE
           --dbms_output('Update_Terr_Value TBL: l_return_status = FND_API.G_RET_STS_SUCCESS');
           -- Save the terr_usg_id and
           X_Terr_Value_Out_Tbl(l_counter).TERR_VALUE_ID := l_Terr_Value_Out_Rec.TERR_VALUE_ID;
           -- If successful then save the success status for the record
           X_Terr_Value_Out_Tbl(l_counter).return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
   --
   END LOOP;

   --Get the API overall return status
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get number of records in the ouput table
   l_Terr_Value_Out_Tbl_Count   := X_Terr_Value_Out_Tbl.Count;
   l_Terr_Value_Out_Tbl         := X_Terr_Value_Out_Tbl;
   FOR l_Counter IN 1 ..  l_Terr_Value_Out_Tbl_Count  LOOP
       If l_Terr_Value_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
          l_Terr_Value_Out_Tbl(l_Counter).return_status = FND_API.G_RET_STS_ERROR
       THEN
          X_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;


   --dbms_output('Update_Terr_Value TBL: Exiting API');
--
End Update_Terr_Value;
-------------------------------------------------------------------------------------------------------
--                         DELETE PROCEDURE SECTION STARTS HERE
-------------------------------------------------------------------------------------------------------

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_territory_Record
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Terr_Id                   NUMBER
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
PROCEDURE Delete_territory_Record
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Id                    IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2)
AS
   l_row_count                  NUMBER;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_territory_Record';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_return_status              VARCHAR2(1);
BEGIN
   --dbms_output('Delete_territory_Record: Entering API');

   -- Standard start of PAI savepoint
   SAVEPOINT  Delete_territory_Record_Pvt;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   --dbms_output('Delete_territory_Record: Before Calling Create_TerrType_Qualifier TBL');
   --
   JTF_TERR_PKG.Delete_Row(x_terr_Id  => P_Terr_Id);
   --
      --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','JTF_TERR_RECORD_DELETED');

   IF SQL%FOUND THEN
      --dbms_output('Delete_territory_Record: # Records deleted -' || to_char(SQL%ROWCOUNT));
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;
   --prepare the message
   FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR');
   FND_MSG_PUB.ADD;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
   --dbms_output('Delete_territory_Record: Exiting API');
--
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;
          --Prepare message token
          FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
          FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR');
          FND_MSG_PUB.ADD;
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Delete_territory_Record: FND_API.G_EXC_UNEXPECTED_ERROR');
          ROLLBACK TO  Delete_territory_Record_Pvt;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Delete_territory_Record: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_territory_Record');
          END IF;
--
END  Delete_territory_Record;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Territory_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Terr_Id                   NUMBER
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
PROCEDURE Delete_Territory_Usages
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_usg_Id                IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2)
AS
   l_row_count                  NUMBER;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Territory_Usages';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_return_status              VARCHAR2(1);
BEGIN
   --dbms_output('Delete_Territory_Usages: Entering API');

   -- Standard start of PAI savepoint
   SAVEPOINT  Delete_Territory_Usages_Pvt;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   --dbms_output('Delete_Territory_Usages: Before Calling Create_TerrType_Qualifier TBL');
   --
   JTF_TERR_USGS_PKG.Delete_Row(x_TERR_USG_ID  =>   P_Terr_usg_Id);
   --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','JTF_TERR_RECORD_DELETED');
   IF SQL%FOUND THEN
      --dbms_output('Delete_Territory_Usages: # Records deleted -' || to_char(SQL%ROWCOUNT));
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;
   --Prepare message token
   FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_USGS');
   FND_MSG_PUB.ADD;

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
   --dbms_output('Delete_Territory_Usages: Exiting API');
--
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;
          --Prepare message token
          FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
          FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_USGS');
          FND_MSG_PUB.ADD;
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Delete_Territory_Usages: FND_API.G_EXC_UNEXPECTED_ERROR');
          ROLLBACK TO  Delete_Territory_Usages_Pvt;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Delete_Territory_Usages: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_Territory_Usages');
          END IF;
END Delete_Territory_Usages;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Terr_QualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Terr_Qual_Type_Usg_Id     NUMBER
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
PROCEDURE Delete_Terr_QualType_Usage
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Qual_Type_Usg_Id      IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2)
AS
   l_row_count                  NUMBER;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Terr_QualType_Usage';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_return_status              VARCHAR2(1);

BEGIN
   --dbms_output('Delete_Terr_QualType_Usage: Entering API');

   -- Standard start of PAI savepoint
   SAVEPOINT  Delete_Terr_QualType_Usage_Pvt;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --dbms_output('Delete_Terr_QualType_Usage: Before Calling JTF_TERR_QTYPE_USGS_PKG.Delete_Row');
   --
   JTF_TERR_QTYPE_USGS_PKG.Delete_Row(x_terr_qtype_usg_id =>  P_Terr_Qual_Type_Usg_Id);
   --
   --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','JTF_TERR_RECORD_DELETED');

   IF SQL%FOUND THEN
      --dbms_output('Delete_Terr_QualType_Usage: # Records deleted -' || to_char(SQL%ROWCOUNT));
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;

   --Prepare message token
   FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_QTYPE_USGS');
   FND_MSG_PUB.ADD;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
   --dbms_output('Delete_Terr_QualType_Usage: Exiting API');
--
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          --dbms_output('Delete_Terr_QualType_Usage: NO_DATA_FOUND');
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;

          --Prepare message token
          FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
          FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_QTYPE_USGS');
          FND_MSG_PUB.ADD;
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Delete_Terr_QualType_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
          ROLLBACK TO  Delete_Terr_QualType_Usage_Pvt;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Delete_Terr_QualType_Usage: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_Terr_QualType_Usage');
          END IF;
END Delete_Terr_QualType_Usage;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Terr_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Terr_Qual_Id              NUMBER
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
PROCEDURE  Delete_Terr_Qualifier
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Qual_Id               IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2)
AS
   l_row_count                  NUMBER;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Terr_Qualifier';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_return_status              VARCHAR2(1);


   /* for BULK deletes */
   TYPE NumTab                  IS TABLE OF NUMBER;
   deletedIds                   NUMTAB;

   lp_terr_id                   NUMBER;

BEGIN
   --dbms_output('Delete_Terr_Qualifier: Entering API');

   -- Standard start of PAI savepoint
   SAVEPOINT  Delete_Terr_Qualifier_Pvt;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   --dbms_output('Delete_Terr_Qualifier: Before Calling Create_TerrType_Qualifier TBL');
   --

   /* anonymous block to get territory id */
   BEGIN
     SELECT terr_id
       INTO lp_terr_id
     FROM jtf_terr_qual_ALL jtq
     WHERE jtq.terr_qual_id = p_terr_qual_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     WHEN OTHERS THEN
        NULL;
   END;

   /* Do a bulk delete of Territory Qualifier VALUES */
   DELETE jtf_terr_values_ALL
   WHERE terr_qual_id = p_terr_qual_id
   RETURNING terr_value_id
   BULK COLLECT INTO deletedIds;

   JTF_TERR_QUAL_PKG.Delete_Row(x_terr_qual_id  => P_Terr_Qual_Id );
      --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','JTF_TERR_RECORD_DELETED');
   IF SQL%FOUND THEN
       --dbms_output('Delete_Terr_Qualifier: # Records deleted -' || to_char(SQL%ROWCOUNT));
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;

   /* update Sales territory's number of Account qualifiers
   */
   -- update_terr_num_qual(lp_terr_id, -1002);

   --Prepare message token
   FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_QUALIFIERS');
   FND_MSG_PUB.ADD();

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
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
   --dbms_output('Delete_Terr_Qualifier: Exiting API');
   --
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;
          --Prepare message token
          FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
          FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_QUALIFIERS');
          --Add message to API message list
          FND_MSG_PUB.ADD();
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Delete_Terr_Qualifier: FND_API.G_EXC_UNEXPECTED_ERROR');
          ROLLBACK TO  Delete_Terr_Qualifier_Pvt;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Delete_Terr_Qualifier: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_Terr_Qualifier');
          END IF;
END Delete_Terr_Qualifier;
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Terr_Value
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Terr_Value_Id             NUMBER
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
PROCEDURE Delete_Terr_Value
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Value_Id              IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2)
AS
   l_row_count                  NUMBER;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Terr_Value';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_return_status              VARCHAR2(1);
BEGIN
   --dbms_output('Delete_Terr_Value: Entering API');

   -- Standard start of PAI savepoint
   SAVEPOINT  Delete_Terr_Value_Pvt;

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
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
      FND_MESSAGE.Set_Name('PROC_NAME', l_api_name);
      FND_MSG_PUB.Add;
   END IF;

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

   JTF_TERR_VALUES_PKG.Delete_Row(X_TERR_VALUE_ID   => P_Terr_Value_Id);
   --
   --Prepare message name
   FND_MESSAGE.SET_NAME('JTF','JTF_TERR_RECORD_DELETED');
   IF SQL%FOUND THEN
      --dbms_output('Delete_Terr_Value: # Records deleted -' || to_char(SQL%ROWCOUNT));
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_row_count     := SQL%ROWCOUNT;
   END IF;
   --Prepare message token
   FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_VALUES');
   FND_MSG_PUB.ADD();

      -- Debug Message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
      FND_MESSAGE.Set_Token('PROC_NAME', l_api_name );
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
   --dbms_output('Delete_Terr_Value: Exiting API');
   --
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          --dbms_output('Delete_Terr_Value: NO-DATA-FOUND');
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          l_row_count                        := 0;
          --Prepare message token
          FND_MESSAGE.SET_TOKEN('NO_OF_REC', TO_CHAR(l_row_count));
          FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'JTF_TERR_VALUES');
          --Add message to API message list
          FND_MSG_PUB.ADD();
          --
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output('Delete_Terr_Value: FND_API.G_EXC_UNEXPECTED_ERROR');
          ROLLBACK TO  Delete_Terr_Value_Pvt;
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

     WHEN OTHERS THEN
          --dbms_output('Delete_Terr_Value: OTHERS - ' || SQLERRM);
          X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Delete error inside Delete_Terr_Value');
          END IF;
  End Delete_Terr_Value;
  --
  -- This procedure will check whether the qualifiers passed are
  -- valid.
  --
  PROCEDURE Validate_Qualifier
  (p_Terr_Id                     IN  NUMBER,
   P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type     := G_Miss_Terr_Qual_Rec,
   p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 )
  AS
    l_Temp        VARCHAR2(01);
    l_qual_count  NUMBER;
  BEGIN
    --dbms_output('Validate_Qualifier: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    --dbms_output('Validate P_Terr_Qual_Rec.Qual_Usg_Id - ' || to_char(P_Terr_Qual_Rec.Qual_Usg_Id));
    --
    if (P_Terr_Qual_Rec.Qual_Usg_Id IS NULL) OR
       (P_Terr_Qual_Rec.Qual_Usg_Id = FND_API.G_MISS_NUM ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'QUAL_USG_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    END IF;

    --

    -- Check whether the qualfier is enabled or not.
    BEGIN
       IF ( p_Terr_Id IS NOT NULL ) AND
          ( P_Terr_Qual_Rec.Qual_Usg_Id IS NOT NULL ) Then
         /*  SELECT  'x'
            into  l_Temp
            from  jtf_qual_usgs_ALL jqu,
                  jtf_qual_type_usgs_ALL jqtu,
                  jtf_terr_qtype_usgs_ALL jtqu
           where  jtqu.terr_id = p_Terr_Id and
                  jqtu.qual_type_usg_id = jtqu.qual_type_usg_id and
                  jqu.qual_usg_id = P_Terr_Qual_Rec.Qual_Usg_Id and
                  jqu.enabled_flag = 'Y' and
                  jqtu.qual_type_id IN ( SELECT related_id
                                           FROM jtf_qual_type_denorm_v
                                          WHERE qual_type_id = jqtu.qual_type_id )
                  AND ROWNUM < 2; */

             SELECT 'x'
             INTO  l_Temp
             FROM  jtf_terr_all jta,
                   jtf_terr_type_qual_all jtqa,
                   jtf_qual_usgs_all jqua
             WHERE jta.terr_id = p_Terr_Id
               AND jta.territory_type_id = jtqa.terr_type_id
               AND jtqa.qual_usg_id = jqua.qual_usg_id
               AND jqua.org_id = jtqa.org_id
               AND jqua.enabled_flag = 'Y'
               AND jqua.qual_usg_id = P_Terr_Qual_Rec.Qual_Usg_Id
               AND ROWNUM < 2;
        END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            --dbms_output('Validate_Qualifier: NO_DATA_FOUND Exception');
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_DISABLED_TERR_QUAL');
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get
            (  P_count          =>   x_msg_count,
               P_data           =>   x_msg_data
            );
    END;

    -- Check for duplicate qualifiers.
    IF ( p_Terr_Id IS NOT NULL ) AND
       ( P_Terr_Qual_Rec.Qual_Usg_Id IS NOT NULL ) Then

        SELECT COUNT(*) INTO l_qual_count
        FROM JTF_TERR_QUAL_ALL
        WHERE TERR_ID = p_Terr_Id
        AND QUAL_USG_ID = P_Terr_Qual_Rec.Qual_Usg_Id ;

        IF ( l_qual_count IS NOT NULL ) AND
           ( l_qual_count > 0 ) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTY_DUPLICATE_QUALIFIER');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END IF;
    END IF ;

    /* --  Check for ORG_ID - obsolete: org_id is optional
    IF (P_Terr_Qual_Rec.ORG_ID is NULL OR
        P_Terr_Qual_Rec.ORG_ID = FND_API.G_MISS_NUM ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    */

    -- Validate last updated by
    IF  ( P_Terr_Qual_Rec.LAST_UPDATED_BY is NULL OR
          P_Terr_Qual_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( P_Terr_Qual_Rec.LAST_UPDATE_DATE IS NULL OR
         P_Terr_Qual_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --
    --Check last update login
    If ( P_Terr_Qual_Rec.LAST_UPDATE_LOGIN  is NULL OR
         P_Terr_Qual_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    --

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

    --dbms_output('Validate_Qualifier: Exiting API');
  EXCEPTION
  --
    WHEN NO_DATA_FOUND THEN
         --dbms_output('Validate_Qualifier: NO_DATA_FOUND Exception');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_DISABLED_TERR_QUAL');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Qualifier: Others Exception');
         X_return_status      := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Qualifer' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );
  --
  END Validate_Qualifier;

  -- Validate the Territory RECORD
  -- Validate Territory Name is specified and also check for not null columns
  -- If Parent Territory_id, ESCALATION_TERRITORY_ID, territory_type_id is specified
  PROCEDURE Validate_Territory_Record
    (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
     x_Return_Status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2,
     p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec)
  AS

     l_Return_Status               VARCHAR2(1);
     l_reason                      VARCHAR2(1);
     l_ter_name_count               NUMBER;

  BEGIN
    --dbms_output('Validate_Territory_Record: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether the territory Name is specified
    --
    IF (p_Terr_All_Rec.NAME is NULL) OR (p_Terr_All_Rec.NAME = FND_API.G_MISS_CHAR) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'NAME' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    ELSE -- Territory Name is not null.
        -- Check for Duplicate Territory Names.
        IF p_Terr_All_Rec.START_DATE_ACTIVE IS NOT NULL
           AND p_Terr_All_Rec.END_DATE_ACTIVE IS NOT NULL
           AND p_Terr_All_Rec.PARENT_TERRITORY_ID IS NOT NULL THEN

              Select count(*) INTO l_ter_name_count
                FROM JTF_TERR_ALL childterr,
                     HR_OPERATING_UNITS hr,
                     JTF_TERR_ALL parentterr
                WHERE childterr.org_id = hr.organization_id
                  AND childterr.parent_territory_id =   parentTerr.terr_id
                  AND childterr.org_id = parentTerr.org_id
                  AND childterr.NAME = p_Terr_All_Rec.NAME
                  AND childterr.terr_id <>  p_Terr_All_Rec.PARENT_TERRITORY_ID
                  AND (   ((childterr.END_DATE_ACTIVE  >=  p_Terr_All_Rec.START_DATE_ACTIVE and  childterr.START_DATE_ACTIVE <= p_Terr_All_Rec.START_DATE_ACTIVE)
                           or (childterr.END_DATE_ACTIVE >= p_Terr_All_Rec.END_DATE_ACTIVE and  childterr.START_DATE_ACTIVE <= p_Terr_All_Rec.END_DATE_ACTIVE ))
                        or ((childterr.START_DATE_ACTIVE  >=  p_Terr_All_Rec.START_DATE_ACTIVE and  childterr.START_DATE_ACTIVE <= p_Terr_All_Rec.END_DATE_ACTIVE)
                           or (childterr.END_DATE_ACTIVE >=  p_Terr_All_Rec.START_DATE_ACTIVE and  childterr.END_DATE_ACTIVE <= p_Terr_All_Rec.END_DATE_ACTIVE)));

                IF l_ter_name_count IS NOT NULL AND  l_ter_name_count > 0 THEN
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('JTF', 'JTY_TERR_DUP_NAME');
                       FND_MESSAGE.Set_Token('TERR_NAME', p_Terr_All_Rec.NAME );
                       FND_MSG_PUB.ADD;
                    END IF;
                    x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
        END IF;
    End If;

    -- Parent Terr ID can't be null.
    If (p_Terr_All_Rec.PARENT_TERRITORY_ID is null) OR
       (p_Terr_All_Rec.PARENT_TERRITORY_ID = FND_API.G_MISS_NUM)
    Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'PARENT_TERRITORY_ID' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    END IF;

    --dbms_output('Validate_Foreign_Key: Checking for Territory Type Id');
    -- Territory Type ID can't be null.
    If (p_Terr_All_Rec.TERRITORY_TYPE_ID is null) OR
       (p_Terr_All_Rec.TERRITORY_TYPE_ID = FND_API.G_MISS_NUM)
    then

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'TERRITORY_TYPE_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check whether application short name is specified
    --
    IF (p_Terr_All_Rec.APPLICATION_SHORT_NAME is NULL) OR
       (p_Terr_All_Rec.APPLICATION_SHORT_NAME = FND_API.G_MISS_CHAR) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'APPLICATION_SHORT_NAME' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    /* Check whether the enabled_flag is specified
    -- Obsolete: use date effectivity to determine
    -- whether territory is enabled
    IF (p_Terr_All_Rec.ENABLED_FLAG is NULL) OR
       (p_Terr_All_Rec.ENABLED_FLAG = FND_API.G_MISS_CHAR) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'ENABLED_FLAG' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;
    */

    -- Check for ORG_ID
    IF (p_Terr_All_Rec.ORG_ID is NULL) OR
       (p_Terr_All_Rec.ORG_ID = FND_API.G_MISS_NUM) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    If (p_Terr_All_Rec.ESCALATION_TERRITORY_FLAG = 'Y' and
        p_Terr_All_Rec.TEMPLATE_FLAG = 'Y' ) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_OVERLAPPING_FLAG');
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check created by
    IF ( p_Terr_All_Rec.CREATED_BY is NULL OR
         p_Terr_All_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check creation date
    If ( p_Terr_All_Rec.CREATION_DATE is NULL OR
         p_Terr_All_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Validate last updated by
    IF ( p_Terr_All_Rec.LAST_UPDATED_BY is NULL OR
         p_Terr_All_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_Terr_All_Rec.LAST_UPDATE_DATE IS NULL OR
         p_Terr_All_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    --If ( p_Terr_All_Rec.LAST_UPDATE_LOGIN  is NULL OR
    --     p_Terr_All_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
    --   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    --      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
    --      FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
    --      FND_MSG_PUB.ADD;
    --   END IF;
    --   x_Return_Status := FND_API.G_RET_STS_ERROR ;
    --End If;

    --Check start date active
    If ( p_Terr_All_Rec.START_DATE_ACTIVE IS NULL OR
         p_Terr_All_Rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'START_DATE_ACTIVE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check End date active
    If ( p_Terr_All_Rec.END_DATE_ACTIVE IS NULL OR
         p_Terr_All_Rec.END_DATE_ACTIVE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'END_DATE_ACTIVE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    IF (p_Terr_All_Rec.START_DATE_ACTIVE IS NOT NULL AND p_Terr_All_Rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE )
        AND (p_Terr_All_Rec.END_DATE_ACTIVE IS NOT NULL AND p_Terr_All_Rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
        IF ( p_Terr_All_Rec.START_DATE_ACTIVE > p_Terr_All_Rec.END_DATE_ACTIVE ) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_END_BAD');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END IF;
    END IF;

    --Check Rank
    If ( p_Terr_All_Rec.RANK IS NULL OR
         p_Terr_All_Rec.RANK = FND_API.G_MISS_NUM ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'RANK' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    /* Check Number Of Winners not set at
    ** a higher/lower level in the hierarchy
    ** 10/04/00 JDOCHERT
    */
    /* JDOCHERT: 06/27/03: bug#3020630
    IF ( p_terr_all_rec.NUM_WINNERS IS NOT NULL AND
         p_terr_all_rec.NUM_WINNERS <> FND_API.G_MISS_NUM )  THEN

       validate_num_winners(
               p_terr_all_rec     => p_terr_all_rec,
               p_init_msg_list    => p_init_msg_list,
               x_Return_Status    => l_Return_Status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               x_Reason           => l_reason );


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_Return_Status := l_return_Status;
       End If;

    End If;
    */


    --
    -- Validate foreign key references
    Validate_Foreign_Key(p_Terr_All_Rec    => p_Terr_All_Rec,
                         p_init_msg_list   => p_init_msg_list,
                         x_Return_Status   => l_Return_Status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_Return_Status := l_return_Status;
    End If;

    -- Since the message stack is already set
    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Territory_Record: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Territory_Record: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Territory_Record: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Territory_Record' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );
  --
  END Validate_Territory_Record;

  -- Validate the Territory RECORD while updating the territory
  PROCEDURE Validate_TerrRec_Update
    (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
     x_Return_Status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2,
     p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec)
  AS

     l_Return_Status                 VARCHAR2(1);
     l_reason                        VARCHAR2(1);
     l_ter_name                      VARCHAR2(200);
     l_ter_name_count                NUMBER;
     l_dummy                         NUMBER;
     l_start_date_active             DATE;
     l_end_date_active               DATE;
     l_pterr_start_date              DATE;
     l_pterr_end_date                DATE;
     l_parent_territory_id           NUMBER;
     l_Validate_id                   NUMBER;
  BEGIN
    --dbms_output('Validate_Territory_Record: Entering API');
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the territory Id
    l_Validate_id := p_Terr_All_Rec.TERR_ID;
    If l_Validate_id IS NOT NULL THEN
        If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
            --dbms_output('Validate_Territory_Usage: l_status <> FND_API.G_TRUE');
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
            FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR');
            FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
            FND_MSG_PUB.ADD;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        ELSE
         -- Terr_ID Is valid.
            SELECT name,
                   START_DATE_ACTIVE,
                   END_DATE_ACTIVE,
                   PARENT_TERRITORY_ID
              INTO l_ter_name,
                   l_start_date_active,
                   l_end_date_active,
                   l_parent_territory_id
              FROM JTF_TERR_ALL
             WHERE TERR_ID = p_Terr_All_Rec.TERR_ID;
            -- Following values are used in finding the duplicate names.
            IF (p_Terr_All_Rec.START_DATE_ACTIVE IS NOT NULL AND p_Terr_All_Rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
                l_start_date_active := p_Terr_All_Rec.START_DATE_ACTIVE ;
            END IF;

            IF (p_Terr_All_Rec.END_DATE_ACTIVE IS NOT NULL AND p_Terr_All_Rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE ) THEN
                l_end_date_active := p_Terr_All_Rec.END_DATE_ACTIVE ;
            END IF;

            IF (p_Terr_All_Rec.PARENT_TERRITORY_ID IS NOT NULL
                AND p_Terr_All_Rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM ) THEN
                l_parent_territory_id := p_Terr_All_Rec.PARENT_TERRITORY_ID ;
            END IF;
        END IF;
    END IF;
    -- Check whether the territory Name is specified
    --
    IF ( (p_Terr_All_Rec.NAME IS NOT NULL)
         AND (p_Terr_All_Rec.NAME <> FND_API.G_MISS_CHAR) )
        AND ( p_Terr_All_Rec.NAME <> l_ter_name )  THEN

        IF l_start_date_active IS NOT NULL
           AND l_end_date_active IS NOT NULL
           AND l_parent_territory_id IS NOT NULL THEN

              Select count(*) INTO l_ter_name_count
                FROM JTF_TERR_ALL childterr,
                     HR_OPERATING_UNITS hr,
                     JTF_TERR_ALL parentterr
                WHERE childterr.org_id = hr.organization_id
                  AND childterr.parent_territory_id =   parentTerr.terr_id
                  AND childterr.org_id = parentTerr.org_id
                  AND childterr.NAME = p_Terr_All_Rec.NAME
                  AND childterr.terr_id <> l_parent_territory_id
                  AND (   ((childterr.END_DATE_ACTIVE  >=  l_start_date_active and  childterr.START_DATE_ACTIVE <= l_start_date_active)
                           or (childterr.END_DATE_ACTIVE >= l_end_date_active and  childterr.START_DATE_ACTIVE <= l_end_date_active ))
                        or ((childterr.START_DATE_ACTIVE  >=  l_start_date_active and  childterr.START_DATE_ACTIVE <= l_end_date_active)
                           or (childterr.END_DATE_ACTIVE >=  l_start_date_active and  childterr.END_DATE_ACTIVE <= l_end_date_active)));

                IF l_ter_name_count IS NOT NULL AND  l_ter_name_count > 0 THEN
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('JTF', 'JTY_TERR_DUP_NAME');
                       FND_MESSAGE.Set_Token('TERR_NAME', p_Terr_All_Rec.NAME );
                       FND_MSG_PUB.ADD;
                    END IF;
                    x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
        END IF;
    End If;

    IF (l_start_date_active IS NOT NULL )
        AND (l_end_date_active IS NOT NULL ) THEN
        IF ( l_start_date_active > l_end_date_active ) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_END_BAD');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        END IF;
    END IF;

    -- Territory start and end active dates should fall in territory dates.
    IF (l_parent_territory_id IS NOT NULL AND l_parent_territory_id <> 1 )THEN
        BEGIN

            SELECT jta.start_date_active,jta.end_date_active
              INTO l_pterr_start_date,l_pterr_end_date
              FROM jtf_terr_all jta
             WHERE jta.terr_id = l_parent_territory_id ;

            -- Validate Terr start date .
            IF ( l_start_date_active IS NOT NULL ) AND ( ( l_start_date_active < l_pterr_start_date ) OR ( l_start_date_active > l_pterr_end_date ) ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_STARTDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
            END IF;

            -- Validate Terr end date.
            IF (l_end_date_active IS NOT NULL ) AND (( l_end_date_active < l_pterr_start_date ) OR ( l_end_date_active > l_pterr_end_date ) ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_ENDDATE_NOT_VALID');
                    FND_MESSAGE.Set_Token('RES_NAME', ' ' );
                    FND_MSG_PUB.ADD;
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR ;
            END IF;

        EXCEPTION
          WHEN OTHERS THEN
              X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                  FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, 'Others Exception in Validate_Terr_Record ' || SQLERRM);
               END IF;
        END;
    END IF; --l_parent_terr_id IS NOT NULL AND l_parent_terr_id <> 1

    --
    -- Check if the Parent Terr ID is valid for the given source.
    BEGIN
        IF ( p_terr_all_rec.PARENT_TERRITORY_ID IS NOT NULL
             AND p_terr_all_rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM
             AND p_terr_all_rec.PARENT_TERRITORY_ID <> 1) THEN

            SELECT 1
              INTO l_dummy
              FROM jtf_terr_usgs_all childusg, jtf_terr_usgs_all parusg
             WHERE childusg.terr_id     = p_terr_all_rec.TERR_ID
               AND parusg.terr_id       = p_terr_all_rec.PARENT_TERRITORY_ID
               AND childusg.source_id   = parusg.source_id
               AND childusg.org_id      = parusg.org_id ;

        END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_PARENT_TERR');
                FND_MESSAGE.Set_Token('TERR_ID', to_char(p_terr_all_rec.PARENT_TERRITORY_ID));
                FND_MSG_PUB.ADD;
     END;

    If (p_Terr_All_Rec.ESCALATION_TERRITORY_FLAG = 'Y' and
        p_Terr_All_Rec.TEMPLATE_FLAG = 'Y' ) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_OVERLAPPING_FLAG');
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Validate last updated by
    IF ( p_Terr_All_Rec.LAST_UPDATED_BY is NULL OR
         p_Terr_All_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_Terr_All_Rec.LAST_UPDATE_DATE IS NULL OR
         p_Terr_All_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_Terr_All_Rec.LAST_UPDATE_LOGIN  is NULL OR
         p_Terr_All_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- check that parent territory is not already a child of this territory
         validate_parent(p_Terr_All_Rec    => p_Terr_All_Rec,
                         p_init_msg_list   => p_init_msg_list,
                         x_Return_Status   => l_Return_Status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_Return_Status := l_return_Status;
    End If;

    -- Since the message stack is already set
    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

  EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Territory_Record: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Territory_Record: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Territory_Record: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_TerrRec_Update' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );
  --
  END Validate_TerrRec_Update;

--
--
-- Validate Foreign Key references
PROCEDURE Validate_Foreign_Key
  (p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec,
   p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 )
  AS
   l_Status                      VARCHAR2(01);
   l_parent_terr_id              NUMBER;
   PSTART_DATE_ACTIVE            DATE;
   PEND_DATE_ACTIVE              DATE;
  BEGIN
        --dbms_output('Validate_Foreign_Key: Entering API');
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    --dbms_output('Validate_Foreign_Key: Checking for PARENT Territory' || TO_CHAR(p_Terr_All_Rec.parent_territory_Id));
    If (p_Terr_All_Rec.PARENT_TERRITORY_ID is not null) AND
       (p_Terr_All_Rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM)
    Then
        --
        l_parent_terr_id := p_Terr_All_Rec.parent_territory_Id;
        --dbms_output('Validate_Foreign_Key: Returned from JTF_CTM_UTILITY_PVT.fk_id_is_valid');
        IF JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_parent_terr_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                --dbms_output('PARENT Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_PARENT_TERR');
                FND_MESSAGE.Set_Token('TERR_ID', to_char(l_parent_terr_id));
                FND_MSG_PUB.ADD;
            End If;
            x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
            -- Parent Terr is Valid. Hence compare the Start Date active and End Date Active with Child's
            -- Start Date Active and End_date_active.
            IF (p_Terr_All_Rec.START_DATE_ACTIVE IS NOT NULL
                AND p_Terr_All_Rec.END_DATE_ACTIVE IS NOT NULL AND p_Terr_All_Rec.PARENT_TERRITORY_ID <> 1 ) THEN

                SELECT START_DATE_ACTIVE, END_DATE_ACTIVE INTO PSTART_DATE_ACTIVE, PEND_DATE_ACTIVE
                FROM JTF_TERR_ALL
                WHERE TERR_ID = p_Terr_All_Rec.PARENT_TERRITORY_ID;

                IF PSTART_DATE_ACTIVE is NOT NULL
                   AND PSTART_DATE_ACTIVE > p_Terr_All_Rec.START_DATE_ACTIVE THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_STARTDATE_NOT_VALID');
                        FND_MSG_PUB.ADD;
                     END IF;
                     x_Return_Status := FND_API.G_RET_STS_ERROR ;
                 END IF;

                 IF PEND_DATE_ACTIVE is NOT NULL
                    AND PEND_DATE_ACTIVE < p_Terr_All_Rec.END_DATE_ACTIVE THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_ENDDATE_NOT_VALID');
                        FND_MSG_PUB.ADD;
                     END IF;
                     x_Return_Status := FND_API.G_RET_STS_ERROR ;
                END IF;
             END IF ;
        END IF;
    END IF;

    --
    --dbms_output('Validate_Foreign_Key: Checking for Territory Type Id');
    --
    If (p_Terr_All_Rec.TERRITORY_TYPE_ID is not null) AND
       (p_Terr_All_Rec.TERRITORY_TYPE_ID <> FND_API.G_MISS_NUM)
    then
       l_status := JTF_CTM_UTILITY_PVT.fk_id_is_valid(p_Terr_All_Rec.TERRITORY_TYPE_ID, 'TERR_TYPE_ID', 'JTF_TERR_TYPES_ALL');
       If l_status <> FND_API.G_TRUE Then
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             --dbms_output('TERR TYPE: Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_TYPE');
             FND_MESSAGE.Set_Token('TERR_TYPE_ID', to_char(p_Terr_All_Rec.TERRITORY_TYPE_ID));
             FND_MSG_PUB.ADD;
          End If;
       End If;
    End If;
    --
    --dbms_output('Validate_Foreign_Key: Checking for Organization ID');
    --
    If (p_Terr_All_Rec.ORG_ID is not null) AND
       (p_Terr_All_Rec.ORG_ID <> FND_API.G_MISS_NUM)
    then
       l_status := JTF_CTM_UTILITY_PVT.fk_id_is_valid(p_Terr_All_Rec.ORG_ID, 'ORGANIZATION_ID', 'HR_OPERATING_UNITS');
       If l_status <> FND_API.G_TRUE Then
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             --dbms_output('TERR TYPE: Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
             --Change the message name here
             FND_MESSAGE.Set_Name('JTF', 'JTY_TERR_MISSING_ORG_ID');
             FND_MESSAGE.Set_Token('ORG_ID', to_char(p_Terr_All_Rec.ORG_ID));
             FND_MSG_PUB.ADD;
          End If;
       End If;
    End If;
    --
    --dbms_output('Validate_Foreign_Key: Checking for TEMPLATE_TERRITORY_ID');
    --
    iF (p_Terr_All_Rec.TEMPLATE_TERRITORY_ID is not null) AND
       (p_Terr_All_Rec.TEMPLATE_TERRITORY_ID <> FND_API.G_MISS_NUM) Then
       l_status := JTF_CTM_UTILITY_PVT.fk_id_is_valid(p_Terr_All_Rec.TEMPLATE_TERRITORY_ID, 'TERR_ID', 'JTF_TERR_ALL');
       if l_status <> FND_API.G_TRUE Then
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             --dbms_output('TEMP: Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TEMP_TERR');
             FND_MESSAGE.Set_Token('TERR_ID', to_char(p_Terr_All_Rec.TEMPLATE_TERRITORY_ID));
             FND_MSG_PUB.ADD;
          End If;
       End If;
    End If;
    --
    --dbms_output('Validate_Foreign_Key: Checking for ESCALATION_TERRITORY_ID');
    --
    If (p_Terr_All_Rec.ESCALATION_TERRITORY_ID is not null)  AND
       (p_Terr_All_Rec.ESCALATION_TERRITORY_ID <> FND_API.G_MISS_NUM) Then
       l_status := JTF_CTM_UTILITY_PVT.fk_id_is_valid(p_Terr_All_Rec.escalation_territory_id, 'TERR_ID', 'JTF_TERR_ALL');
       if l_status <> FND_API.G_TRUE Then
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             --dbms_output('ESC TERR: Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_ESC_TERR');
             FND_MESSAGE.Set_Token('TERR_ID', to_char(p_Terr_All_Rec.terr_Id));
             FND_MSG_PUB.ADD;
          End If;
       End If;
    End If;

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
 EXCEPTION
 --
    WHEN OTHERS THEN
         --dbms_output('Validate_Foreign_Key: Others exception' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Foreign_Key' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
--
END Validate_Foreign_Key;

---------------------------------------------------------------------
--                Validae the Territory Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the territory usage Id is Valid
---------------------------------------------------------------------
PROCEDURE Validate_Territory_Usage
  (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Usgs_Rec               IN  Terr_Usgs_Rec_Type     := G_MISS_Terr_Usgs_Rec,
   p_Terr_Id                     IN  NUMBER)
AS
   l_Rec_Counter                 NUMBER;
   l_Validate_id                 NUMBER;
BEGIN
    --dbms_output('Validate_Territory_Usage: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the territory Id
    If p_Terr_Id IS NOT NULL THEN
       l_Validate_id := p_Terr_Id;
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
          --dbms_output('Validate_Territory_Usage: l_status <> FND_API.G_TRUE');
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
          FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR');
          FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
          FND_MSG_PUB.ADD;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
       --dbms_output('Validate_Territory_Usage: TERR_ID(' || to_char(l_Validate_id) || ') is valid');
    End If;

    -- Validate the source_id
    l_Validate_id := p_Terr_Usgs_rec.SOURCE_ID;
    -- Make sure the foreign key source_id is valid
    If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'SOURCE_ID', 'JTF_SOURCES_ALL') <> FND_API.G_TRUE Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            --dbms_output('Validate_Territory_Usage: FND_MSG_PUB.ADD');
            FND_MESSAGE.Set_Name('JTF',  'JTF_TERR_INVALID_FOREIGN_KEY');
            FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_SOURCES');
            FND_MESSAGE.Set_Token('COLUMN_NAME', 'SOURCE_ID');
            FND_MSG_PUB.ADD;
        End If;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;



   --  Check for ORG_ID
   IF JTF_CTM_UTILITY_PVT.fk_id_is_valid(p_Terr_Usgs_rec.ORG_ID, 'ORGANIZATION_ID', 'HR_OPERATING_UNITS') <> FND_API.G_TRUE THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           --dbms_output('TERR TYPE: Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_TERR_TYPE');
           FND_MESSAGE.Set_Token('ORG_ID', to_char(p_Terr_Usgs_rec.ORG_ID));
           FND_MSG_PUB.ADD;
        End If;
        x_return_status := FND_API.G_RET_STS_ERROR;
    End If;

   --Check created by
   IF ( p_Terr_Usgs_rec.CREATED_BY is NULL OR
        p_Terr_Usgs_rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;

   --Check creation date
   If ( p_Terr_Usgs_rec.CREATION_DATE is NULL OR
        p_Terr_Usgs_rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;

   -- Validate last updated by
   IF  ( p_Terr_Usgs_rec.LAST_UPDATED_BY is NULL OR
         p_Terr_Usgs_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
            FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
            FND_MSG_PUB.ADD;
         END IF;
         x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;

   -- Check last update date
   If ( p_Terr_Usgs_rec.LAST_UPDATE_DATE IS NULL OR
        p_Terr_Usgs_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
           FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
           FND_MSG_PUB.ADD;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;

   --Check last update login
   --If ( p_Terr_Usgs_rec.LAST_UPDATE_LOGIN  is NULL OR
   --     p_Terr_Usgs_rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
   --     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
   --        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
   --        FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
   --        FND_MSG_PUB.ADD;
   --     END IF;
   --     x_Return_Status := FND_API.G_RET_STS_ERROR ;
   --End If;

   --
   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                              p_data  => x_msg_data);

EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Territory_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Territory_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Territory_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Territory_Usage' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );
--
END Validate_Territory_Usage;

---------------------------------------------------------------------
--             Validate the Territory Qualifer Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Qual Type Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the QUAL_TYPE_USG_ID is valid
---------------------------------------------------------------------
PROCEDURE Validate_Terr_Qtype_Usage
  (p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type  := G_Miss_Terr_QualTypeUsgs_Rec,
   p_Terr_Id                     IN  NUMBER)
AS
   l_Rec_Counter                 NUMBER;
   l_Validate_id                 NUMBER;
   l_dummy                       NUMBER := NULL;
   l_source_id                   NUMBER;
   l_qual_Type_Usg_id            NUMBER;
BEGIN
    --dbms_output('Validate_Terr_Qtype_Usage: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- This block will validate territory
    -- qual_Type_Usg_id specified
    BEGIN
       l_qual_Type_Usg_id  := p_Terr_QualTypeUsgs_Rec.QUAL_TYPE_USG_ID;
       --Check the qual_type_usg_id specified is valid
       Select 1
         into l_dummy
         From jtf_terr_usgs_ALL jtu, jtf_qual_type_usgs_ALL jqtu
        where jtu.terr_id = p_Terr_Id and
              jqtu.source_id = jtu.source_id and
              jqtu.qual_type_usg_id = l_qual_Type_Usg_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_QTYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- Validate the territory Id
    l_Validate_id := p_Terr_Id;
    If p_Terr_Id IS NOT NULL Then
       --dbms_output('Validate_Terr_Qtype_Usage: TERR_ID(' || to_char(l_Validate_id) || ')');
       If JTF_CTM_UTILITY_PVT.fk_id_is_valid(l_Validate_id, 'TERR_ID', 'JTF_TERR_ALL') <> FND_API.G_TRUE Then
          --dbms_output('Validate_Foreign_Key: l_status <> FND_API.G_TRUE');
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
             FND_MESSAGE.Set_Token('TABLE_NAME', 'JTF_TERR_ALL');
             FND_MESSAGE.Set_Token('COLUMN_NAME', 'TERR_ID');
             FND_MSG_PUB.ADD;
          END IF;
          x_Return_Status := FND_API.G_RET_STS_ERROR ;
       End If;
    End If;

    --
    --
    /*--  Check for ORG_ID - obsolete: org_id is optional
    IF (p_Terr_QualTypeUsgs_Rec.ORG_ID is NULL) OR
       (p_Terr_QualTypeUsgs_Rec.ORG_ID = FND_API.G_MISS_NUM) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;
   */

    --Check created by
    IF ( p_Terr_QualTypeUsgs_Rec.CREATED_BY is NULL OR
         p_Terr_QualTypeUsgs_Rec.CREATED_BY = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check creation date
    If ( p_Terr_QualTypeUsgs_Rec.CREATION_DATE is NULL OR
         p_Terr_QualTypeUsgs_Rec.CREATION_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'CREATION_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Validate last updated by
    IF  ( p_Terr_QualTypeUsgs_Rec.LAST_UPDATED_BY is NULL OR
          p_Terr_QualTypeUsgs_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_Terr_QualTypeUsgs_Rec.LAST_UPDATE_DATE IS NULL OR
         p_Terr_QualTypeUsgs_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    --If ( p_Terr_QualTypeUsgs_Rec.LAST_UPDATE_LOGIN  is NULL OR
    --     p_Terr_QualTypeUsgs_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
    --   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    --      FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
    --      FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
    --      FND_MSG_PUB.ADD;
    --   END IF;
    --   x_Return_Status := FND_API.G_RET_STS_ERROR ;
    --End If;

    --
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Terr_Qtype_Usage' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );
  --
  END Validate_Terr_Qtype_Usage;

/* Function used in JTF_TERR_VALUES_DESC_V to return
** descriptive values for ids and lookup_codes
*/
PROCEDURE Validate_terr_Value
    (p_init_msg_list               IN           VARCHAR2              := FND_API.G_FALSE,
     x_Return_Status               OUT NOCOPY   VARCHAR2,
     x_msg_count                   OUT NOCOPY   NUMBER,
     x_msg_data                    OUT NOCOPY   VARCHAR2,
     p_convert_to_id_flag          IN           VARCHAR2,
     p_display_type                IN           VARCHAR2,
     p_display_sql                 IN           VARCHAR2              := FND_API.G_MISS_CHAR,
     p_terr_value1                 IN           VARCHAR2,
     p_terr_value2                 IN           VARCHAR2              :=  FND_API.G_MISS_CHAR )
IS
    query_str       VARCHAR2(1000);
    value_desc      VARCHAR2(1000);
    l_terr_value1    VARCHAR2(360);
    l_terr_value2    VARCHAR2(360);

BEGIN
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( p_display_sql IS NOT NULL AND p_display_sql <> FND_API.G_MISS_CHAR ) THEN
        query_str := p_display_sql;
        l_terr_value1 := p_terr_value1;
        l_terr_value2 := p_terr_value2;

        IF (p_display_type IN ('CHAR_2IDS', 'DEP_2FIELDS_CHAR_2IDS', 'DEP_3FIELDS_CHAR_3IDS')) THEN
            query_str := p_display_sql;
        /* check if value is NUMBER or VARCHAR2 */
        ELSIF (  ( p_display_type = 'CHAR' AND  p_convert_to_id_flag = 'Y' )
               OR  p_display_type = 'NUMERIC'
               OR  p_display_type = 'INTEREST_TYPE'
               OR  p_display_type = 'COMPETENCE' ) THEN

            query_str := query_str || ' TO_NUMBER(:terr_value)' ;
        ELSE
            query_str := query_str || ' :terr_value1' ;
        END IF;

        query_str := query_str || ' AND rownum < 2' ;

        IF (p_display_type IN ('CHAR_2IDS', 'DEP_2FIELDS_CHAR_2IDS', 'DEP_3FIELDS_CHAR_3IDS')) THEN
            EXECUTE IMMEDIATE query_str
            INTO value_desc
            USING l_terr_value1, l_terr_value2;
        ELSE
            EXECUTE IMMEDIATE query_str
            INTO value_desc
            USING l_terr_value1;
        END IF;

    END IF; -- p_display_sql IS NOT NULL

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        X_return_status   := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
            FND_MSG_PUB.ADD;
        END IF;

    WHEN OTHERS THEN
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_terr_Value' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );


END Validate_terr_Value;

---------------------------------------------------------------------
--          Validate the Territory Qualifer Values passed in
---------------------------------------------------------------------
-- Columns Validated
--         Make sure the values are in the right columns as per the
--         qualifer setup
--         Eg:
--               If the qualifer, diplay_type    = 'CHAR' and
--                                col1_data_type =  'NUMBER'
--               then make sure the ID is passed in LOW_VALUE_CHAR_ID
--
--
---------------------------------------------------------------------
PROCEDURE Validate_terr_Value_Rec
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Qual_Id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec)
AS
   Cursor C_QualDef1 IS
          -- Get the qualifier usage related information
          select jqu.qual_usg_id,
                 jqu.qual_col1_datatype,
                 jqu.display_type,
                 jqu.convert_to_id_flag,
                 jqu.display_sql1,
                 jqu.display_sql2,
                 jqu.display_sql3,
                 html_lov_sql1
            from jtf_qual_usgs_ALL jqu, jtf_terr_qual_ALL jtq
           where jqu.qual_usg_id = jtq.qual_Usg_Id and
		         jqu.org_id = jtq.org_id AND
                 jtq.terr_qual_id = p_Terr_Qual_Id;

   l_display_type       VARCHAR2(30);
   l_qual_col1_datatype VARCHAR2(30);
   l_convert_to_id_flag VARCHAR2(01);
   l_display_sql1        VARCHAR2(31000);
   l_display_sql2        VARCHAR2(31000);
   l_display_sql3        VARCHAR2(31000);
   l_html_lov_sql1       VARCHAR2(31000);
   l_qual_usg_id         VARCHAR2(20);
BEGIN
    --dbms_output('Validate_terr_Value_Rec: - terr_qual_id' || to_char(p_Terr_Qual_Id) );

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN   C_QualDef1;
    FETCH  C_QualDef1
    INTO l_qual_usg_id,
         l_qual_col1_datatype,
         l_display_type,
         l_convert_to_id_flag,
         l_display_sql1,
         l_display_sql2,
         l_display_sql3,
         l_html_lov_sql1;
    CLOSE  C_QualDef1;

    --dbms_output('l_display_type - ' || l_display_type );
    --dbms_output('l_qual_col1_datatype - ' || l_qual_col1_datatype );
    --dbms_output('l_convert_to_id_flag - ' || l_convert_to_id_flag );

    /*-- Check for ORG_ID - obsolete: org_id is optional
    IF (p_Terr_Value_Rec.ORG_ID is NULL) OR
       (p_Terr_Value_Rec.ORG_ID = FND_API.G_MISS_NUM) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'ORG_ID' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;
   */


   /* ----- ARPATEL 041101 Bug#1508750 FIX -----------------------------------

   If ( p_Terr_Value_Rec.ID_USED_FLAG IS NULL  OR
        p_Terr_Value_Rec.ID_USED_FLAG = FND_API.G_MISS_CHAR ) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'ID_USED_FLAG' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
   End If;
   -------------------------------------------------------------------------*/


    -- Validate last updated by
    IF  ( p_Terr_Value_Rec.LAST_UPDATED_BY is NULL OR
          p_Terr_Value_Rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATED_BY' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check last update date
    If ( p_Terr_Value_Rec.LAST_UPDATE_DATE IS NULL OR
         p_Terr_Value_Rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_DATE' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    --Check last update login
    If ( p_Terr_Value_Rec.LAST_UPDATE_LOGIN  is NULL OR
         p_Terr_Value_Rec.LAST_UPDATE_LOGIN  = FND_API.G_MISS_NUM )  THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MISSING_COL_VALUE');
          FND_MESSAGE.Set_Token('COL_NAME', 'LAST_UPDATE_LOGIN' );
          FND_MSG_PUB.ADD;
       END IF;
       x_Return_Status := FND_API.G_RET_STS_ERROR ;
    End If;

    -- Check the operator.
    /*  All the qualifiers are divided into four groups based on their
        display type and html_lov_sql1.  Below logic is to find the group,
        and retrun the error status if the comparison operator doesnot match.

        ----------------------------
        Group       Operators Supported
        ----------------------------
        GROUP1 	    =
        GROUP2 	    =, BETWEEN, LIKE
        GROUP3 	    =, BETWEEN
        GROUP4 	    =
        -----------------------------

    */
    IF ( ( (l_display_type = 'CHAR_2IDS')
            OR (l_display_type = 'CHAR')
            OR (l_display_type = 'NUMERIC') )
       AND (l_html_lov_sql1 IS NOT NULL)) THEN

        --  groupType = "GROUP1";
        IF ( p_Terr_Value_Rec.COMPARISON_OPERATOR <> '=' ) THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                FND_MSG_PUB.ADD;

            END IF;

            x_Return_Status := FND_API.G_RET_STS_ERROR ;

        END IF;

    ELSIF (  (l_display_type = 'CHAR') AND ( l_html_lov_sql1 IS NUll )) THEN

        /* for DUNS qualifier and Registry_ID only "=" should be allowed 3402736 */
        IF((l_qual_usg_id = '-1120') OR (l_qual_usg_id = '-1129')) THEN

            --   groupType = "GROUP4";
            IF ( p_Terr_Value_Rec.COMPARISON_OPERATOR <> '=' ) THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                    FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                    FND_MSG_PUB.ADD;

                END IF;

                x_Return_Status := FND_API.G_RET_STS_ERROR ;

            END IF;

        ELSE
            --  groupType = "GROUP2";
            IF ( p_Terr_Value_Rec.COMPARISON_OPERATOR <> '='
                AND p_Terr_Value_Rec.COMPARISON_OPERATOR <> 'LIKE'
                AND p_Terr_Value_Rec.COMPARISON_OPERATOR <> 'BETWEEN' ) THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                    FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                    FND_MSG_PUB.ADD;

                END IF;

                x_Return_Status := FND_API.G_RET_STS_ERROR ;

            END IF;

        END IF;

    ELSIF ((  (l_display_type = 'NUMERIC') OR (l_display_type = 'CURRENCY') )
          AND ( l_html_lov_sql1 IS NOT NULL)) THEN

        -- groupType = "GROUP3";
        IF ( p_Terr_Value_Rec.COMPARISON_OPERATOR <> '='
            AND p_Terr_Value_Rec.COMPARISON_OPERATOR <> 'BETWEEN') THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                FND_MSG_PUB.ADD;

            END IF;

            x_Return_Status := FND_API.G_RET_STS_ERROR ;

        END IF;

    ELSE
        -- Display Types : INTEREST_TYPE,
        --                  DEP_2FIELDS
        --                  DEP_2FIELDS_1CHAR_1ID
        --                  DEP_2FIELDS_CHAR_2IDS
        --                  DEP_3FIELDS_CHAR_3IDS
        -- groupType = "GROUP4";
        IF ( p_Terr_Value_Rec.COMPARISON_OPERATOR <> '=' ) THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                FND_MSG_PUB.ADD;

            END IF;

            x_Return_Status := FND_API.G_RET_STS_ERROR ;

        END IF;

    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output('Before the main validation.');
    ---------- Start Qualifier Value Validation. --------------
    -- Character Type
    IF ( l_display_type = 'CHAR' AND
         ( l_convert_to_id_flag = 'N' or l_convert_to_id_flag is NULL ) ) THEN

        IF (   ( p_Terr_Value_Rec.LOW_VALUE_CHAR IS NULL or
                 p_Terr_Value_Rec.LOW_VALUE_CHAR = FND_API.G_MISS_CHAR  ) OR
                 p_Terr_Value_Rec.ID_USED_FLAG   = 'Y'  OR
               ( p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
                 p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) OR
               ( p_Terr_Value_Rec.LOW_VALUE_CHAR_ID IS NOT NULL and
                 p_Terr_Value_Rec.LOW_VALUE_CHAR_ID <> FND_API.G_MISS_NUM ) OR
               ( p_Terr_Value_Rec.LOW_VALUE_NUMBER IS NOT NULL  and
                 p_Terr_Value_Rec.LOW_VALUE_NUMBER <> FND_API.G_MISS_NUM ) OR
               ( p_Terr_Value_Rec.HIGH_VALUE_NUMBER IS NOT NULL and
                 p_Terr_Value_Rec.HIGH_VALUE_NUMBER <> FND_API.G_MISS_NUM ) OR
               ( p_Terr_Value_Rec.INTEREST_TYPE_ID IS NOT NULL and
                 p_Terr_Value_Rec.INTEREST_TYPE_ID <> FND_API.G_MISS_NUM ) ) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;
        ELSE
            IF  ( p_Terr_Value_Rec.LOW_VALUE_CHAR IS NOT NULL AND
                  p_Terr_Value_Rec.LOW_VALUE_CHAR <> FND_API.G_MISS_CHAR  ) THEN
                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.LOW_VALUE_CHAR);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

             END IF;
        END IF;
    -- Numeric with CHAR dsiplay as in Customer Name
    ElsIf ( l_display_type = 'CHAR' AND
            ( l_convert_to_id_flag = 'Y' or l_convert_to_id_flag is NULL ) ) Then
        --dbms_output('Inside CHAR');
        -- If the Id is not specified in low_value_char_id or
        -- id_used_flag is not null or the operation is not
        -- specified, then flag exception
        If  (  (p_Terr_Value_Rec.LOW_VALUE_CHAR_ID   IS NULL or
                p_Terr_Value_Rec.LOW_VALUE_CHAR_ID   = FND_API.G_MISS_NUM ) OR
               (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
                p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) OR
                -- Description may be null
                -- 08/08/00 Change jdochert
                --p_Terr_Value_Rec.LOW_VALUE_CHAR      = FND_API.G_MISS_CHAR OR
               (p_Terr_Value_Rec.ID_USED_FLAG        IS NULL OR
                p_Terr_Value_Rec.ID_USED_FLAG        =  FND_API.G_MISS_CHAR OR
                p_Terr_Value_Rec.ID_USED_FLAG        <> 'Y' ) OR
               (p_Terr_Value_Rec.LOW_VALUE_NUMBER    IS NOT NULL  and
                p_Terr_Value_Rec.LOW_VALUE_NUMBER    <> FND_API.G_MISS_NUM ) OR
               (p_Terr_Value_Rec.HIGH_VALUE_NUMBER   IS NOT NULL  and
                p_Terr_Value_Rec.LOW_VALUE_NUMBER    <> FND_API.G_MISS_NUM ) OR
               (p_Terr_Value_Rec.INTEREST_TYPE_ID    IS NOT NULL and
                p_Terr_Value_Rec.INTEREST_TYPE_ID    <> FND_API.G_MISS_NUM ) ) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;

        ELSE
            IF  ( p_Terr_Value_Rec.LOW_VALUE_CHAR_ID IS NOT NULL AND
                  p_Terr_Value_Rec.LOW_VALUE_CHAR_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.LOW_VALUE_CHAR_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

             END IF;
        END IF;

    ElsIf ( l_display_type = 'NUMERIC' ) Then

        --dbms_output('Inside NUMERIC');
        -- Check whether the atleast LOW_VALUE_NUMBER, operator
        -- is specified
        If (  (p_Terr_Value_Rec.LOW_VALUE_NUMBER    IS NULL OR
               p_Terr_Value_Rec.LOW_VALUE_NUMBER    =  FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) ) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;

/*        ELSIF -- No values validation is required for 'NUMERIC' data type.
*/
         END IF; -- l_display_type = 'CHAR'

    ElsIf ( l_display_type = 'CURRENCY' ) Then

        --dbms_output('Inside CURRENCY');
        -- Check whether the atleast LOW_VALUE_NUMBER, operator
        -- is specified
        If (  (p_Terr_Value_Rec.LOW_VALUE_NUMBER IS NULL OR
               p_Terr_Value_Rec.LOW_VALUE_NUMBER = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) OR
              (p_Terr_Value_Rec.CURRENCY_CODE       IS NULL OR
               p_Terr_Value_Rec.CURRENCY_CODE       = FND_API.G_MISS_CHAR ) OR
              (p_Terr_Value_Rec.LOW_VALUE_CHAR    IS NOT NULL  and
               p_Terr_Value_Rec.LOW_VALUE_CHAR    <> FND_API.G_MISS_CHAR ) OR
              (p_Terr_Value_Rec.INTEREST_TYPE_ID    IS NOT NULL and
               p_Terr_Value_Rec.INTEREST_TYPE_ID    <> FND_API.G_MISS_NUM ) ) THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;
        --ELSIF
        -- No validations required for CURRENCY display type. Display sql1 is not defined for this.

        END IF;

    ElsIf ( l_display_type = 'INTEREST_TYPE' ) Then

        --dbms_output('Inside INTEREST_TYPE');
        -- Check whether the atleast LOW_VALUE_NUMBER, operator
        -- is specified
        If (  (p_Terr_Value_Rec.INTEREST_TYPE_ID IS NULL OR
               p_Terr_Value_Rec.INTEREST_TYPE_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) OR
              (p_Terr_Value_Rec.LOW_VALUE_NUMBER    IS NOT NULL  and
               p_Terr_Value_Rec.LOW_VALUE_NUMBER    <> FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.LOW_VALUE_CHAR    IS NOT NULL  and
               p_Terr_Value_Rec.LOW_VALUE_CHAR    <> FND_API.G_MISS_CHAR ) )  THEN

               --dbms_output('Error INTEREST_TYPE');
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;

        ELSE
            -- Validate the Intrest Type ID being passed if it is not null.
            IF  ( p_Terr_Value_Rec.INTEREST_TYPE_ID IS NOT NULL AND
                 p_Terr_Value_Rec.INTEREST_TYPE_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.INTEREST_TYPE_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF ;

            IF  ( p_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID IS NOT NULL AND
                 p_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF ;
            -- Validate SECONDARY_INTEREST_CODE_ID value if it is not null.
            IF  ( p_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID IS NOT NULL AND
                 p_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql3,
                    p_terr_value1        => p_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF  ;
         END IF;
    ElsIf ( l_display_type = 'CHAR_2IDS' ) Then
        --
        If (  (p_Terr_Value_Rec.VALUE1_ID IS NULL OR
               p_Terr_Value_Rec.VALUE1_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.VALUE2_ID IS NULL OR
               p_Terr_Value_Rec.VALUE2_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) OR
              (p_Terr_Value_Rec.LOW_VALUE_NUMBER    IS NOT NULL  and
               p_Terr_Value_Rec.LOW_VALUE_NUMBER    <> FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.LOW_VALUE_CHAR    IS NOT NULL  and
               p_Terr_Value_Rec.LOW_VALUE_CHAR    <> FND_API.G_MISS_CHAR ) )  THEN

               --dbms_output('Error INTEREST_TYPE');
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;

        ELSIF  ( p_Terr_Value_Rec.VALUE1_ID IS NOT NULL AND
                 p_Terr_Value_Rec.VALUE1_ID <> FND_API.G_MISS_NUM AND
                 p_Terr_Value_Rec.VALUE2_ID IS NOT NULL AND
                 p_Terr_Value_Rec.VALUE2_ID <> FND_API.G_MISS_NUM ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID,
                    p_terr_value2        => p_Terr_Value_Rec.VALUE2_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

        END IF; -- l_display_type = 'CHAR_2IDS'

    ElsIf ( l_display_type = 'DEP_2FIELDS' ) Then

        If (  (p_Terr_Value_Rec.VALUE1_ID IS NULL OR
               p_Terr_Value_Rec.VALUE1_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) )  THEN

               --dbms_output('Error INTEREST_TYPE');
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;

               x_Return_Status := FND_API.G_RET_STS_ERROR ;

        ELSE
            IF  ( p_Terr_Value_Rec.VALUE1_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE1_ID <> FND_API.G_MISS_NUM ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

            IF  ( p_Terr_Value_Rec.VALUE2_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE2_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE2_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;
        END IF; -- l_display_type = 'DEP_2FIELDS'

    ElsIf ( l_display_type = 'DEP_2FIELDS_CHAR_2IDS' ) Then

        IF (  (p_Terr_Value_Rec.VALUE1_ID IS NULL OR
               p_Terr_Value_Rec.VALUE1_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) )  THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;
               x_Return_Status := FND_API.G_RET_STS_ERROR ;
        ELSE
            IF  ( p_Terr_Value_Rec.VALUE1_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE1_ID <> FND_API.G_MISS_NUM ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID,
                    p_terr_value2        => -9999 );

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

            IF  ( p_Terr_Value_Rec.VALUE2_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE2_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID,
                    p_terr_value2        => p_Terr_Value_Rec.VALUE2_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;
        END IF; -- l_display_type = 'DEP_2FIELDS_CHAR_2IDS'

    ElsIf ( l_display_type = 'DEP_3FIELDS_CHAR_3IDS' ) Then

        IF (  (p_Terr_Value_Rec.VALUE1_ID IS NULL OR
               p_Terr_Value_Rec.VALUE1_ID = FND_API.G_MISS_NUM ) OR
              (p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
               p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR ) )  THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;
               x_Return_Status := FND_API.G_RET_STS_ERROR ;
        ELSE
            IF  ( p_Terr_Value_Rec.VALUE1_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE1_ID <> FND_API.G_MISS_NUM ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID,
                    p_terr_value2        => -9999 );

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

            IF  ( p_Terr_Value_Rec.VALUE2_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE2_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE1_ID,
                    p_terr_value2        => -9999);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

               IF  ( p_Terr_Value_Rec.VALUE3_ID IS NOT NULL AND
                  p_Terr_Value_Rec.VALUE3_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.VALUE3_ID,
                    p_terr_value2        => -9999);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

        END IF; -- l_display_type = 'DEP_3FIELDS_CHAR_3IDS'

    ElsIf ( l_display_type = 'DEP_2FIELDS_1CHAR_1ID' ) Then

        IF (   ( p_Terr_Value_Rec.LOW_VALUE_CHAR IS NULL or
                 p_Terr_Value_Rec.LOW_VALUE_CHAR = FND_API.G_MISS_CHAR  ) OR
               ( p_Terr_Value_Rec.COMPARISON_OPERATOR IS NULL OR
                 p_Terr_Value_Rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR )  )  THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_INVALID_TERR_VALUE');
                  FND_MSG_PUB.ADD;
               END IF;
               x_Return_Status := FND_API.G_RET_STS_ERROR ;
        ELSE
            IF  ( p_Terr_Value_Rec.LOW_VALUE_CHAR IS NOT NULL AND
                  p_Terr_Value_Rec.LOW_VALUE_CHAR <> FND_API.G_MISS_CHAR ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql1,
                    p_terr_value1        => p_Terr_Value_Rec.LOW_VALUE_CHAR);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

            IF  ( p_Terr_Value_Rec.LOW_VALUE_CHAR_ID IS NOT NULL AND
                  p_Terr_Value_Rec.LOW_VALUE_CHAR_ID <> FND_API.G_MISS_NUM  ) THEN

                --Validate the value being passed.
                Validate_terr_Value(
                    p_init_msg_list      => p_init_msg_list,
                    x_Return_Status      => x_Return_Status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_convert_to_id_flag => l_convert_to_id_flag,
                    p_display_type       => l_display_type,
                    p_display_sql        => l_display_sql2,
                    p_terr_value1        => p_Terr_Value_Rec.LOW_VALUE_CHAR_ID);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END IF;

        END IF; -- l_display_type = 'DEP_2FIELDS_1CHAR_1ID  '

     End If;


    --
   /* FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);
*/
EXCEPTION
  --
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_terr_Value_Rec' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

End Validate_terr_Value_Rec;

   -- CHECK FOR DUPLICATES VALUES
   --
PROCEDURE Check_duplicate_Value
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Qual_Id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec)
AS
    l_dummy        VARCHAR2(5);
    BEGIN

         Select 'X'
         into l_dummy
         From  JTF_TERR_VALUES_ALL
         WHERE TERR_QUAL_ID  =  P_terr_qual_id
          AND nvl(COMPARISON_OPERATOR , '-9999')    = nvl( decode(P_Terr_Value_Rec.COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.COMPARISON_OPERATOR ) , '-9999')
          AND nvl(LOW_VALUE_CHAR , '-9999')         = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.LOW_VALUE_CHAR ) , '-9999')
          AND nvl(HIGH_VALUE_CHAR , '-9999')        = nvl( decode(P_Terr_Value_Rec.HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.HIGH_VALUE_CHAR ) , '-9999')
          AND nvl(LOW_VALUE_NUMBER , -9999)         = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.LOW_VALUE_NUMBER ) , -9999)
          AND nvl(HIGH_VALUE_NUMBER , -9999)        = nvl( decode(P_Terr_Value_Rec.HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.HIGH_VALUE_NUMBER ) , -9999)
          AND nvl(VALUE_SET , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE_SET, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE_SET ) , -9999)
          AND nvl(INTEREST_TYPE_ID , -9999)         = nvl( decode(P_Terr_Value_Rec.INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.INTEREST_TYPE_ID ) , -9999)
          AND nvl(PRIMARY_INTEREST_CODE_ID,-9999)   = nvl( decode(P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID ) , -9999)
          AND nvl(SECONDARY_INTEREST_CODE_ID,-9999) = nvl( decode(P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID ), -9999)
          AND nvl(CURRENCY_CODE , '-9999')          = nvl( decode(P_Terr_Value_Rec.CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.CURRENCY_CODE ) , '-9999')
          AND nvl(LOW_VALUE_CHAR_ID , -9999)        = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.LOW_VALUE_CHAR_ID ) , -9999)
          AND nvl(ORG_ID , -9999)                   = nvl( decode(P_Terr_Value_Rec.ORG_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.ORG_ID ) , -9999)
          AND nvl(CNR_GROUP_ID , -9999)             = nvl( decode(P_Terr_Value_Rec.CNR_GROUP_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.CNR_GROUP_ID ) , -9999)
          AND nvl(VALUE1_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE1_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE1_ID ) , -9999)
          AND nvl(VALUE2_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE2_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE2_ID ) , -9999)
          AND nvl(VALUE3_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE3_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE3_ID ) , -9999)
          AND nvl(VALUE4_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE4_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE4_ID ) , -9999) ;

        IF l_dummy = 'X' THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTY_DUP_TRANS_ATTR_VAL');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
    EXCEPTION
          --
    WHEN NO_DATA_FOUND THEN
           NULL;
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Check_duplicate_Value');
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    END Check_duplicate_Value;
  -- CHECK FOR DUPLICATES VALUES
   --
PROCEDURE Check_duplicate_Value_update
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Qual_Id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec)
AS
    l_dummy        VARCHAR2(5);
    BEGIN
         Select 'X'
         into l_dummy
         From  JTF_TERR_VALUES_ALL
         WHERE TERR_VALUE_ID <> P_Terr_Value_Rec.TERR_VALUE_ID
          AND TERR_QUAL_ID  =  P_terr_qual_id
          AND nvl(COMPARISON_OPERATOR , '-9999')    = nvl( decode(P_Terr_Value_Rec.COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.COMPARISON_OPERATOR ) , '-9999')
          AND nvl(LOW_VALUE_CHAR , '-9999')         = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.LOW_VALUE_CHAR ) , '-9999')
          AND nvl(HIGH_VALUE_CHAR , '-9999')        = nvl( decode(P_Terr_Value_Rec.HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.HIGH_VALUE_CHAR ) , '-9999')
          AND nvl(LOW_VALUE_NUMBER , -9999)         = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.LOW_VALUE_NUMBER ) , -9999)
          AND nvl(HIGH_VALUE_NUMBER , -9999)        = nvl( decode(P_Terr_Value_Rec.HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.HIGH_VALUE_NUMBER ) , -9999)
          AND nvl(VALUE_SET , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE_SET, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE_SET ) , -9999)
          AND nvl(INTEREST_TYPE_ID , -9999)         = nvl( decode(P_Terr_Value_Rec.INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.INTEREST_TYPE_ID ) , -9999)
          AND nvl(PRIMARY_INTEREST_CODE_ID,-9999)   = nvl( decode(P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.PRIMARY_INTEREST_CODE_ID ) , -9999)
          AND nvl(SECONDARY_INTEREST_CODE_ID,-9999) = nvl( decode(P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.SECONDARY_INTEREST_CODE_ID ), -9999)
          AND nvl(CURRENCY_CODE , '-9999')          = nvl( decode(P_Terr_Value_Rec.CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL , P_Terr_Value_Rec.CURRENCY_CODE ) , '-9999')
          AND nvl(LOW_VALUE_CHAR_ID , -9999)        = nvl( decode(P_Terr_Value_Rec.LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.LOW_VALUE_CHAR_ID ) , -9999)
          AND nvl(ORG_ID , -9999)                   = nvl( decode(P_Terr_Value_Rec.ORG_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.ORG_ID ) , -9999)
          AND nvl(CNR_GROUP_ID , -9999)             = nvl( decode(P_Terr_Value_Rec.CNR_GROUP_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.CNR_GROUP_ID ) , -9999)
          AND nvl(VALUE1_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE1_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE1_ID ) , -9999)
          AND nvl(VALUE2_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE2_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE2_ID ) , -9999)
          AND nvl(VALUE3_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE3_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE3_ID ) , -9999)
          AND nvl(VALUE4_ID , -9999)                = nvl( decode(P_Terr_Value_Rec.VALUE4_ID, FND_API.G_MISS_NUM, NULL , P_Terr_Value_Rec.VALUE4_ID ) , -9999) ;

        IF l_dummy = 'X' THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('JTF', 'JTY_DUP_TRANS_ATTR_VAL');
                FND_MSG_PUB.ADD;
            END IF;
            x_Return_Status := FND_API.G_RET_STS_ERROR ;
        End If;
    EXCEPTION
          --
    WHEN NO_DATA_FOUND THEN
           NULL;
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Terr_Qtype_Usage: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Terr_Qtype_Usage: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Check_duplicate_Value');
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    END Check_duplicate_Value_update;
  ---------------------------------------------------------------------
  --             Get_Max_Rank
  ---------------------------------------------------------------------
  --
  --         Gets the maximum rank at a particular Level
  ---------------------------------------------------------------------
  PROCEDURE Get_Max_Rank
  (p_Parent_Terr_Id              IN  NUMBER,
   p_Source_Id                   IN  NUMBER,
   X_Rank                        OUT NOCOPY NUMBER)
  AS
  BEGIN
          Select Max(rank)
           into  x_Rank
          from   jtf_terr_ALL jt, jtf_terr_usgs_ALL jtu
          where  jt.Parent_Territory_id = p_Parent_Terr_Id and
                 jt.Terr_Id = jtu.Terr_Id and
                 jtu.source_id = p_Source_Id;

          If x_Rank is NULL Then
             x_Rank := 0;
          End If;

  Exception
          When NO_DATA_FOUND Then
               x_Rank := 0;
  END Get_Max_Rank;
--
--
--
--
---------------------------------------
---------------------------------------
--  MASS CREATE TERRITORY FUNCTIONALITY
---------------------------------------
---------------------------------------
--
/*--------------------------------------------------------------------------------------*/
  /* This function does validation checks for the template territory record
  ** Validations:
  ** 1. id passed is a valid template id
  ** 2. At least 1 qualifier should be specified for use in generation.
  ** 3. lock the template so that no other user can use that template for
  ** generation or update the template.
  */
  PROCEDURE Validate_Template_Record (
     p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
     p_template_terr_id            IN  NUMBER,
     x_Return_Status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
  )
  AS

    /* (1) check template exists */
    CURSOR c_chk_template (p_template_terr_id NUMBER) IS
    SELECT 'X'
    FROM   jtf_terr_ALL j
    WHERE  j.terr_id = p_template_terr_id
    AND    j.template_flag = 'Y';


    /* (2) check that at least 1 dynamic is specified for use in generation */
    CURSOR c_chk_qual_mode (p_template_terr_id NUMBER) IS
    SELECT COUNT(*)
    FROM   jtf_terr_qual j
    WHERE  j.terr_id = p_template_terr_id
    AND    j.qualifier_mode = 'DYNAMIC';

    l_terr_id             NUMBER := 0;
    l_qualifier_code      VARCHAR2(30);
    l_qualifier_name      VARCHAR2(60);

    l_csr_rtn             VARCHAR2(1);
    l_use_to_name_count   NUMBER := 0;
    l_dynamic_qual_count  NUMBER := 0;

  BEGIN

    --dbms_output('Validate_Template_Record: Entering API');

    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* (1) check template exists  */
    OPEN c_chk_template (p_template_terr_id);
    FETCH c_chk_template INTO l_csr_rtn;
    IF (c_chk_template%NOTFOUND) THEN

      fnd_message.set_name('JTF', 'JTF_TERR_INVALID_TEMPLATE');
      --fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
    CLOSE c_chk_template;

    /* (3)  check that at least 1 qualifier is specified for use in generation */
    OPEN c_chk_qual_mode(p_template_terr_id);
    FETCH c_chk_qual_mode INTO l_dynamic_qual_count;

    --arpatel 07/13 bug#1872642
    --IF (c_chk_qual_mode%NOTFOUND) THEN

      IF (l_dynamic_qual_count = 0) THEN
      fnd_message.set_name ('JTF', 'JTF_TERR_NO_DYNAMIC_QUALIFIERS');
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
    CLOSE c_chk_qual_mode;

    /* (4) lock the template so that no other user can use that template for
    **     generation or update the template
    */
    BEGIN

      --OPEN c_lock_template (p_template_terr_id);

      SELECT j1.terr_id
      INTO   l_terr_id
      FROM   jtf_terr j1
      WHERE  j1.terr_id = p_template_terr_id
      FOR UPDATE NOWAIT;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('JTF','JTF_TERR_TEMPLATE_LOCKED');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;  /* block for validation (4) */

    --dbms_output('Validate_Template_Record: x_return_status = '|| x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Validate_Template_Record: FND_API.G_EXC_ERROR');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Validate_Template_Record: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output('Validate_Template_Record: OTHERS - ' || SQLERRM);
         X_return_status                    := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

  END validate_template_record;

/*--------------------------------------------------------------------------------------*/
  /* 1. returns template territory record
  ** 2. returns number of territories that will be generated
  ** 3. returns a table of terr usages for the territory
  ** 4. returns a table of terr qual type usgs for the territory
  */
  PROCEDURE initialise ( p_template_terr_id     IN  NUMBER
                       , x_tmpl_terr_rec        OUT NOCOPY Terr_All_Rec_Type
                       , x_num_gen_terr         OUT NOCOPY NUMBER
                       , x_tmpl_usgs_tbl        OUT NOCOPY Terr_Usgs_Tbl_Type
                       , x_tmpl_qtype_usgs_tbl  OUT NOCOPY Terr_QualTypeUsgs_Tbl_Type) IS

   /* cursor to get template territory's setails */
    CURSOR c_get_terr ( p_template_terr_id NUMBER ) IS
       SELECT j1.TERR_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.APPLICATION_SHORT_NAME
            , j1.NAME
            , j1.ENABLED_FLAG
            , j1.REQUEST_ID
            , j1.PROGRAM_APPLICATION_ID
            , j1.PROGRAM_ID
            , j1.PROGRAM_UPDATE_DATE
            , j1.START_DATE_ACTIVE
            , j1.RANK
            , j1.END_DATE_ACTIVE
            , j1.DESCRIPTION
            , j1.UPDATE_FLAG
            , j1.AUTO_ASSIGN_RESOURCES_FLAG
            , j1.PLANNED_FLAG
            , j1.TERRITORY_TYPE_ID
            , j1.PARENT_TERRITORY_ID
            , j1.TEMPLATE_FLAG
            , j1.TEMPLATE_TERRITORY_ID
            , j1.ESCALATION_TERRITORY_FLAG
            , j1.ESCALATION_TERRITORY_ID
            , j1.OVERLAP_ALLOWED_FLAG
            , j1.ATTRIBUTE_CATEGORY
            , j1.ATTRIBUTE1
            , j1.ATTRIBUTE2
            , j1.ATTRIBUTE3
            , j1.ATTRIBUTE4
            , j1.ATTRIBUTE5
            , j1.ATTRIBUTE6
            , j1.ATTRIBUTE7
            , j1.ATTRIBUTE8
            , j1.ATTRIBUTE9
            , j1.ATTRIBUTE10
            , j1.ATTRIBUTE11
            , j1.ATTRIBUTE12
            , j1.ATTRIBUTE13
            , j1.ATTRIBUTE14
            , j1.ATTRIBUTE15
            , j1.ORG_ID
            , j1.NUM_WINNERS
         FROM   jtf_terr j1
         WHERE  j1.terr_id = p_template_terr_id;

   /* cursor to get the number of territories that will be generated */
    CURSOR c_get_max_value_set (p_template_terr_id NUMBER) IS
       SELECT MAX (j1.VALUE_SET)
       FROM jtf_terr_values j1, jtf_terr_qual j2, jtf_terr j3
       WHERE j1.terr_qual_id = j2.terr_qual_id
         AND j2.terr_id = j3.terr_id
         AND j3.terr_id = p_template_terr_id
         AND j2.qualifier_mode = 'DYNAMIC'
       GROUP BY j2.qual_usg_id;

   /* cursor to get territory's usages */
   CURSOR c_get_terr_usgs (p_template_terr_id NUMBER) IS
      SELECT j1.TERR_USG_ID
           , j1.SOURCE_ID
           , j1.TERR_ID
           , j1.LAST_UPDATE_DATE
           , j1.LAST_UPDATED_BY
           , j1.CREATION_DATE
           , j1.CREATED_BY
           , j1.LAST_UPDATE_LOGIN
           , j1.ORG_ID
      FROM jtf_terr_usgs j1
      WHERE j1.terr_id = p_template_terr_id;

   /* cursor to get territory's qual type usages */
   CURSOR c_get_terr_qtype_usgs (p_template_terr_id NUMBER) IS
      SELECT j1.TERR_QTYPE_USG_ID
           , j1.TERR_ID
           , j1.QUAL_TYPE_USG_ID
           , j1.LAST_UPDATE_DATE
           , j1.LAST_UPDATED_BY
           , j1.CREATION_DATE
           , j1.CREATED_BY
           , j1.LAST_UPDATE_LOGIN
           , j1.ORG_ID
      from jtf_terr_qtype_usgs j1
      WHERE j1.terr_id = p_template_terr_id;

    l_product         NUMBER := 1;
    l_num_gen_terr    NUMBER := 1;

    /* table counters */
    i                 NUMBER := 0;
    j                 NUMBER := 0;

  BEGIN


       --dbms_output('Initialise: start');

       /* load the template record  */
       OPEN c_get_terr (p_template_terr_id);
       FETCH c_get_terr INTO
              x_tmpl_terr_rec.TERR_ID
            , x_tmpl_terr_rec.LAST_UPDATE_DATE
            , x_tmpl_terr_rec.LAST_UPDATED_BY
            , x_tmpl_terr_rec.CREATION_DATE
            , x_tmpl_terr_rec.CREATED_BY
            , x_tmpl_terr_rec.LAST_UPDATE_LOGIN
            , x_tmpl_terr_rec.APPLICATION_SHORT_NAME
            , x_tmpl_terr_rec.NAME
            , x_tmpl_terr_rec.ENABLED_FLAG
            , x_tmpl_terr_rec.REQUEST_ID
            , x_tmpl_terr_rec.PROGRAM_APPLICATION_ID
            , x_tmpl_terr_rec.PROGRAM_ID
            , x_tmpl_terr_rec.PROGRAM_UPDATE_DATE
            , x_tmpl_terr_rec.START_DATE_ACTIVE
            , x_tmpl_terr_rec.RANK
            , x_tmpl_terr_rec.END_DATE_ACTIVE
            , x_tmpl_terr_rec.DESCRIPTION
            , x_tmpl_terr_rec.UPDATE_FLAG
            , x_tmpl_terr_rec.AUTO_ASSIGN_RESOURCES_FLAG
            , x_tmpl_terr_rec.PLANNED_FLAG
            , x_tmpl_terr_rec.TERRITORY_TYPE_ID
            , x_tmpl_terr_rec.PARENT_TERRITORY_ID
            , x_tmpl_terr_rec.TEMPLATE_FLAG
            , x_tmpl_terr_rec.TEMPLATE_TERRITORY_ID
            , x_tmpl_terr_rec.ESCALATION_TERRITORY_FLAG
            , x_tmpl_terr_rec.ESCALATION_TERRITORY_ID
            , x_tmpl_terr_rec.OVERLAP_ALLOWED_FLAG
            , x_tmpl_terr_rec.ATTRIBUTE_CATEGORY
            , x_tmpl_terr_rec.ATTRIBUTE1
            , x_tmpl_terr_rec.ATTRIBUTE2
            , x_tmpl_terr_rec.ATTRIBUTE3
            , x_tmpl_terr_rec.ATTRIBUTE4
            , x_tmpl_terr_rec.ATTRIBUTE5
            , x_tmpl_terr_rec.ATTRIBUTE6
            , x_tmpl_terr_rec.ATTRIBUTE7
            , x_tmpl_terr_rec.ATTRIBUTE8
            , x_tmpl_terr_rec.ATTRIBUTE9
            , x_tmpl_terr_rec.ATTRIBUTE10
            , x_tmpl_terr_rec.ATTRIBUTE11
            , x_tmpl_terr_rec.ATTRIBUTE12
            , x_tmpl_terr_rec.ATTRIBUTE13
            , x_tmpl_terr_rec.ATTRIBUTE14
            , x_tmpl_terr_rec.ATTRIBUTE15
            , x_tmpl_terr_rec.ORG_ID
            , x_tmpl_terr_rec.NUM_WINNERS;

       CLOSE c_get_terr;

       --dbms_output('Initialise: [1]');

       /* get the number of territories that will be generated
       ** this is the product (X) of the maximum value_sets for
       ** each dynamic qualifier
       */
       OPEN c_get_max_value_set (p_template_terr_id);
       LOOP

         FETCH c_get_max_value_set INTO l_product;
         EXIT WHEN c_get_max_value_set%NOTFOUND;

         l_num_gen_terr := l_num_gen_terr * l_product;

       END LOOP;
       CLOSE c_get_max_value_set;

       x_num_gen_terr := l_num_gen_terr;

       --dbms_output('Initialise: Value of x_num_gen_terr = '||TO_CHAR(x_num_gen_terr));

       /* load terr usages */
       OPEN c_get_terr_usgs (p_template_terr_id);
       LOOP
          FETCH c_get_terr_usgs INTO
             x_tmpl_usgs_tbl(i).TERR_USG_ID
           , x_tmpl_usgs_tbl(i).SOURCE_ID
           , x_tmpl_usgs_tbl(i).TERR_ID
           , x_tmpl_usgs_tbl(i).LAST_UPDATE_DATE
           , x_tmpl_usgs_tbl(i).LAST_UPDATED_BY
           , x_tmpl_usgs_tbl(i).CREATION_DATE
           , x_tmpl_usgs_tbl(i).CREATED_BY
           , x_tmpl_usgs_tbl(i).LAST_UPDATE_LOGIN
           , x_tmpl_usgs_tbl(i).ORG_ID;

          EXIT WHEN c_get_terr_usgs%NOTFOUND;
          --dbms_output('Initialise: Value of i = '||TO_CHAR(i) || ' source_id = ' || x_tmpl_usgs_tbl(i).source_id);
          i := i + 1;
       END LOOP;
       CLOSE c_get_terr_usgs;

       /* load terr qual type usages */
       OPEN c_get_terr_qtype_usgs (p_template_terr_id);
       LOOP
          FETCH c_get_terr_qtype_usgs INTO
             x_tmpl_qtype_usgs_tbl(j).TERR_QUAL_TYPE_USG_ID
           , x_tmpl_qtype_usgs_tbl(j).TERR_ID
           , x_tmpl_qtype_usgs_tbl(j).QUAL_TYPE_USG_ID
           , x_tmpl_qtype_usgs_tbl(j).LAST_UPDATE_DATE
           , x_tmpl_qtype_usgs_tbl(j).LAST_UPDATED_BY
           , x_tmpl_qtype_usgs_tbl(j).CREATION_DATE
           , x_tmpl_qtype_usgs_tbl(j).CREATED_BY
           , x_tmpl_qtype_usgs_tbl(j).LAST_UPDATE_LOGIN
           , x_tmpl_qtype_usgs_tbl(j).ORG_ID;

          EXIT WHEN c_get_terr_qtype_usgs%NOTFOUND;
          --dbms_output('Initialise: Value of j = '||TO_CHAR(j) || ' qual_type_usg_id = ' || x_tmpl_qtype_usgs_tbl(j).qual_type_usg_id);
          j := j + 1;
       END LOOP;
       CLOSE c_get_terr_qtype_usgs;


   END initialise;


/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_new_terr( p_template_terr_rec  IN  Terr_All_Rec_Type
                           , p_num                IN  NUMBER
                           , x_new_terr_id        OUT NOCOPY NUMBER )
  IS

     /* local standard API variables */
     l_return_status             VARCHAR2(200);
     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(2000);

     /* local variables */
     l_new_terr_rec          Terr_All_Rec_Type;
     l_terr_out_rec          Terr_All_Out_Rec_Type;
     l_new_terr_id           NUMBER;

  BEGIN

     --dbms_output('create_new_terr START');

     l_new_terr_rec.TERR_ID                      := FND_API.G_MISS_NUM;
     l_new_terr_rec.LAST_UPDATE_DATE             := SYSDATE;
     l_new_terr_rec.LAST_UPDATED_BY              := FND_GLOBAL.USER_ID;
     l_new_terr_rec.CREATION_DATE                := SYSDATE;
     l_new_terr_rec.CREATED_BY                   := FND_GLOBAL.USER_ID;
     l_new_terr_rec.LAST_UPDATE_LOGIN            := FND_GLOBAL.LOGIN_ID;
     l_new_terr_rec.APPLICATION_SHORT_NAME       := FND_GLOBAL.APPLICATION_SHORT_NAME;

     /* name of new territory is derived from template name */
     l_new_terr_rec.NAME                         := p_template_terr_rec.name ||
                                                    ' - ' || ' #';

     l_new_terr_rec.ENABLED_FLAG                 := 'Y';
     l_new_terr_rec.REQUEST_ID                   := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_APPLICATION_ID       := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_ID                   := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_UPDATE_DATE          := FND_API.G_MISS_DATE;
     l_new_terr_rec.START_DATE_ACTIVE            := p_template_terr_rec.start_date_active;
     l_new_terr_rec.RANK                         := p_template_terr_rec.rank;
     l_new_terr_rec.END_DATE_ACTIVE              := p_template_terr_rec.end_date_active;
     l_new_terr_rec.DESCRIPTION                  := p_template_terr_rec.description;
     l_new_terr_rec.ORG_ID                       := p_template_terr_rec.org_id;
     l_new_terr_rec.UPDATE_FLAG                  := p_template_terr_rec.update_flag;
     l_new_terr_rec.AUTO_ASSIGN_RESOURCES_FLAG   := p_template_terr_rec.auto_assign_resources_flag;
     l_new_terr_rec.PLANNED_FLAG                 := p_template_terr_rec.planned_flag;
     l_new_terr_rec.TERRITORY_TYPE_ID            := p_template_terr_rec.territory_type_id;
     l_new_terr_rec.PARENT_TERRITORY_ID          := p_template_terr_rec.parent_territory_id;
     l_new_terr_rec.TEMPLATE_FLAG                := 'N';
     l_new_terr_rec.TEMPLATE_TERRITORY_ID        := p_template_terr_rec.terr_id;
     l_new_terr_rec.ESCALATION_TERRITORY_FLAG    := p_template_terr_rec.escalation_territory_flag;
     l_new_terr_rec.ESCALATION_TERRITORY_ID      := p_template_terr_rec.escalation_territory_id;
     l_new_terr_rec.OVERLAP_ALLOWED_FLAG         := p_template_terr_rec.overlap_allowed_flag;
     l_new_terr_rec.ATTRIBUTE_CATEGORY           := p_template_terr_rec.attribute_category;
     l_new_terr_rec.ATTRIBUTE1                   := p_template_terr_rec.attribute1;
     l_new_terr_rec.ATTRIBUTE2                   := p_template_terr_rec.attribute2;
     l_new_terr_rec.ATTRIBUTE3                   := p_template_terr_rec.attribute3;
     l_new_terr_rec.ATTRIBUTE4                   := p_template_terr_rec.attribute4;
     l_new_terr_rec.ATTRIBUTE5                   := p_template_terr_rec.attribute5;
     l_new_terr_rec.ATTRIBUTE6                   := p_template_terr_rec.attribute6;
     l_new_terr_rec.ATTRIBUTE7                   := p_template_terr_rec.attribute7;
     l_new_terr_rec.ATTRIBUTE8                   := p_template_terr_rec.attribute8;
     l_new_terr_rec.ATTRIBUTE9                   := p_template_terr_rec.attribute9;
     l_new_terr_rec.ATTRIBUTE10                  := p_template_terr_rec.attribute10;
     l_new_terr_rec.ATTRIBUTE11                  := p_template_terr_rec.attribute11;
     l_new_terr_rec.ATTRIBUTE12                  := p_template_terr_rec.attribute12;
     l_new_terr_rec.ATTRIBUTE13                  := p_template_terr_rec.attribute13;
     l_new_terr_rec.ATTRIBUTE14                  := p_template_terr_rec.attribute14;
     l_new_terr_rec.ATTRIBUTE15                  := p_template_terr_rec.attribute15;
     l_new_terr_rec.ORG_ID                       := p_template_terr_rec.org_id;
     l_new_terr_rec.NUM_WINNERS                  := p_template_terr_rec.NUM_WINNERS;

     /* create the territory record */
     create_territory_record (
          P_Api_Version_Number  => 1.0,
          P_Init_Msg_List       => FND_API.G_TRUE,
          P_Commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          P_Terr_All_Rec        => l_new_terr_rec,
          X_Return_Status       => l_return_status,
          X_Msg_Count           => l_msg_count,
          X_Msg_Data            => l_msg_data,
          X_Terr_Id             => l_new_terr_id,
          X_Terr_All_Out_Rec    => l_terr_out_rec );

     /* store the terr_id */
     l_new_terr_rec.TERR_ID := l_new_terr_id;
     /* update the territory's name */
     l_new_terr_rec.NAME := l_new_terr_rec.name || TO_CHAR(l_new_terr_id);

     update_territory_record (
          P_Api_Version_Number  => 1.0,
          P_Init_Msg_List       => FND_API.G_TRUE,
          P_Commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          P_Terr_All_Rec        => l_new_terr_rec,
          X_Return_Status       => l_return_status,
          X_Msg_Count           => l_msg_count,
          X_Msg_Data            => l_msg_data,
          X_Terr_All_Out_Rec    => l_terr_out_rec );

     x_new_terr_id := l_new_terr_id;

     --dbms_output( 'create_new_terr END => l_return_status = ' ||  l_return_status || ' name = ' || l_new_terr_rec.NAME ||' x_new_terr_id = ' || TO_CHAR (x_new_terr_id));

  END create_new_terr;

/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_copied_terr( p_copied_terr_rec      IN  Terr_All_Rec_Type
                              , p_new_terr_rec         IN  Terr_All_Rec_Type
                              , p_num                  IN  NUMBER
                              , p_copy_hierarchy_flag  IN  VARCHAR2
                              , p_first_terr_node_flag IN  VARCHAR2
                              , x_new_terr_id          OUT NOCOPY NUMBER )
  IS

     /* local standard API variables */
     l_return_status             VARCHAR2(200);
     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(2000);

     /* local variables */
     l_new_terr_rec          Terr_All_Rec_Type;
     l_terr_out_rec          Terr_All_Out_Rec_Type;
     l_new_terr_id           NUMBER;

  BEGIN

    --dbms_output('create_copied_terr START');

     l_new_terr_rec.TERR_ID                      := FND_API.G_MISS_NUM;
     l_new_terr_rec.LAST_UPDATE_DATE             := SYSDATE;
     l_new_terr_rec.LAST_UPDATED_BY              := FND_GLOBAL.USER_ID;
     l_new_terr_rec.CREATION_DATE                := SYSDATE;
     l_new_terr_rec.CREATED_BY                   := FND_GLOBAL.USER_ID;
     l_new_terr_rec.LAST_UPDATE_LOGIN            := FND_GLOBAL.LOGIN_ID;
     l_new_terr_rec.APPLICATION_SHORT_NAME       := FND_GLOBAL.APPLICATION_SHORT_NAME;

     -- dbms_output.put_line('JTF_TERRITORY_PVT:create_copied_terr:l_new_terr_rec.APPLICATION_SHORT_NAME-' || l_new_terr_rec.APPLICATION_SHORT_NAME);

     -- 04/06/01 ARPATEL - START
     IF (p_copy_hierarchy_flag = 'Y') THEN

        IF (p_first_terr_node_flag = 'Y') THEN
           l_new_terr_rec.NAME                         := p_new_terr_rec.name;
           l_new_terr_rec.START_DATE_ACTIVE            := p_new_terr_rec.start_date_active;
           l_new_terr_rec.END_DATE_ACTIVE              := p_new_terr_rec.end_date_active;
           l_new_terr_rec.DESCRIPTION                  := p_new_terr_rec.description;
           l_new_terr_rec.RANK                         := p_new_terr_rec.rank;
        ELSE
           l_new_terr_rec.NAME                         := p_copied_terr_rec.name;
           l_new_terr_rec.RANK                         := p_copied_terr_rec.rank;
           l_new_terr_rec.DESCRIPTION                  := p_copied_terr_rec.description;
           l_new_terr_rec.START_DATE_ACTIVE            := p_copied_terr_rec.start_date_active;
           l_new_terr_rec.END_DATE_ACTIVE              := p_copied_terr_rec.end_date_active;
        END IF;

     ELSE

        /* set new territory record details */
        l_new_terr_rec.NAME                         := p_new_terr_rec.name;
        l_new_terr_rec.START_DATE_ACTIVE            := p_new_terr_rec.start_date_active;
        l_new_terr_rec.END_DATE_ACTIVE              := p_new_terr_rec.end_date_active;
        l_new_terr_rec.DESCRIPTION                  := p_new_terr_rec.description;
        l_new_terr_rec.RANK                         := p_new_terr_rec.rank;
     END IF;
     -- 04/06/01 ARPATEL - END

     l_new_terr_rec.ENABLED_FLAG                 := 'Y';
     l_new_terr_rec.REQUEST_ID                   := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_APPLICATION_ID       := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_ID                   := FND_API.G_MISS_NUM;
     l_new_terr_rec.PROGRAM_UPDATE_DATE          := FND_API.G_MISS_DATE;

     l_new_terr_rec.ORG_ID                       := p_copied_terr_rec.org_id;
     l_new_terr_rec.UPDATE_FLAG                  := 'Y';    --- p_copied_terr_rec.update_flag;
     l_new_terr_rec.AUTO_ASSIGN_RESOURCES_FLAG   := p_copied_terr_rec.auto_assign_resources_flag;
     l_new_terr_rec.PLANNED_FLAG                 := p_copied_terr_rec.planned_flag;
     l_new_terr_rec.TERRITORY_TYPE_ID            := p_copied_terr_rec.territory_type_id;
     l_new_terr_rec.PARENT_TERRITORY_ID          := p_copied_terr_rec.parent_territory_id;
     l_new_terr_rec.TEMPLATE_FLAG                := p_copied_terr_rec.template_flag;
     l_new_terr_rec.TEMPLATE_TERRITORY_ID        := FND_API.G_MISS_NUM;
     l_new_terr_rec.ESCALATION_TERRITORY_FLAG    := p_copied_terr_rec.escalation_territory_flag;
     l_new_terr_rec.ESCALATION_TERRITORY_ID      := p_copied_terr_rec.escalation_territory_id;
     l_new_terr_rec.OVERLAP_ALLOWED_FLAG         := p_copied_terr_rec.overlap_allowed_flag;
     l_new_terr_rec.ATTRIBUTE_CATEGORY           := p_copied_terr_rec.attribute_category;
     l_new_terr_rec.ATTRIBUTE1                   := p_copied_terr_rec.attribute1;
     l_new_terr_rec.ATTRIBUTE2                   := p_copied_terr_rec.attribute2;
     l_new_terr_rec.ATTRIBUTE3                   := p_copied_terr_rec.attribute3;
     l_new_terr_rec.ATTRIBUTE4                   := p_copied_terr_rec.attribute4;
     l_new_terr_rec.ATTRIBUTE5                   := p_copied_terr_rec.attribute5;
     l_new_terr_rec.ATTRIBUTE6                   := p_copied_terr_rec.attribute6;
     l_new_terr_rec.ATTRIBUTE7                   := p_copied_terr_rec.attribute7;
     l_new_terr_rec.ATTRIBUTE8                   := p_copied_terr_rec.attribute8;
     l_new_terr_rec.ATTRIBUTE9                   := p_copied_terr_rec.attribute9;
     l_new_terr_rec.ATTRIBUTE10                  := p_copied_terr_rec.attribute10;
     l_new_terr_rec.ATTRIBUTE11                  := p_copied_terr_rec.attribute11;
     l_new_terr_rec.ATTRIBUTE12                  := p_copied_terr_rec.attribute12;
     l_new_terr_rec.ATTRIBUTE13                  := p_copied_terr_rec.attribute13;
     l_new_terr_rec.ATTRIBUTE14                  := p_copied_terr_rec.attribute14;
     l_new_terr_rec.ATTRIBUTE15                  := p_copied_terr_rec.attribute15;
     l_new_terr_rec.ORG_ID                       := p_copied_terr_rec.org_id;
     l_new_terr_rec.NUM_WINNERS                  := p_copied_terr_rec.NUM_WINNERS;

     /* create the territory record */
     create_territory_record (
          P_Api_Version_Number  => 1.0,
          P_Init_Msg_List       => FND_API.G_TRUE,
          P_Commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          P_Terr_All_Rec        => l_new_terr_rec,
          X_Return_Status       => l_return_status,
          X_Msg_Count           => l_msg_count,
          X_Msg_Data            => l_msg_data,
          X_Terr_Id             => l_new_terr_id,
          X_Terr_All_Out_Rec    => l_terr_out_rec );


     /* update the territory's name */
     l_new_terr_rec.NAME := l_new_terr_rec.name || TO_CHAR(l_new_terr_id);

     x_new_terr_id := l_new_terr_id;

    --dbms_output( 'create_copied_terr END => l_return_status = ' ||  l_return_status || ' name = ' || l_new_terr_rec.NAME ||  ' x_new_terr_id = ' || TO_CHAR (x_new_terr_id));

  END create_copied_terr;


/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_new_terr_usgs(  p_new_terr_id         IN  NUMBER
                                 , p_terr_usgs_tbl       IN  Terr_Usgs_Tbl_Type )
  IS
      /* local standard API variables */
      l_api_version_number        NUMBER := 1.0;
      l_return_status             VARCHAR2(200);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      /* local record variables */
      l_terr_usgs_rec             Terr_Usgs_Rec_Type;
      l_terr_usgs_tbl             Terr_Usgs_Tbl_Type;
      l_terr_usgs_out_tbl         Terr_Usgs_Out_Tbl_Type;

  BEGIN

    --dbms_output('create_new_terr_usgs_rec START');

     FOR i IN 0..p_terr_usgs_tbl.COUNT-1 LOOP

        /* Instantiate record items from FORM items */
        l_terr_usgs_rec.TERR_USG_ID             := FND_API.G_MISS_NUM;
        l_terr_usgs_rec.LAST_UPDATE_DATE        := SYSDATE;
        l_terr_usgs_rec.LAST_UPDATED_BY         := FND_GLOBAL.USER_ID;
        l_terr_usgs_rec.CREATION_DATE           := SYSDATE;
        l_terr_usgs_rec.CREATED_BY              := FND_GLOBAL.USER_ID;
        l_terr_usgs_rec.LAST_UPDATE_LOGIN       := FND_GLOBAL.LOGIN_ID;
        l_terr_usgs_rec.TERR_ID                 := p_new_terr_id;

        l_terr_usgs_rec.SOURCE_ID               := p_terr_usgs_tbl(i).source_id;
        l_terr_usgs_rec.ORG_ID                  := p_terr_usgs_tbl(i).org_id;

        --dbms_output( '    Value of p_terr_usgs_tbl(i).source_id = ' || TO_CHAR(p_terr_usgs_tbl(i).source_id));

        l_terr_usgs_tbl(1) :=  l_terr_usgs_rec;

        /* 11i - territory can only have one usage */
        create_territory_usages (
          P_Api_Version_Number  => l_api_version_number,
          P_Init_Msg_List       => FND_API.G_TRUE,
          P_Commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          P_Terr_id             => p_new_terr_id,
          P_Terr_Usgs_Tbl       => l_terr_usgs_tbl,
          X_Return_Status       => l_return_status,
          X_Msg_Count           => l_msg_count,
          X_Msg_Data            => l_msg_data,
          X_Terr_Usgs_Out_Tbl   => l_terr_usgs_out_Tbl );

        --dbms_output( 'create_new_terr_usgs_rec END: l_return_status = ' || l_return_status || ' terr_usg_id = ' || TO_CHAR(l_terr_usgs_out_tbl(1).terr_usg_id));

     END LOOP;

  END create_new_terr_usgs;

/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_new_terr_qtype_usgs (
               p_new_terr_id         IN  NUMBER
             , p_terr_qtype_usgs_tbl IN  Terr_QualTypeUsgs_Tbl_Type ) IS

      /* local standard API variables */
      l_api_version_number              NUMBER := 1.0;
      l_return_status                   VARCHAR2(200);
      l_msg_count                       NUMBER;
      l_msg_data                        VARCHAR2(2000);

      /* local record variables */
      l_terr_qtype_usgs_rec             Terr_QualTypeUsgs_Rec_Type;
      l_terr_qtype_usgs_out_rec         Terr_QualTypeUsgs_Out_Rec_Type;
      l_terr_qtype_usg_id               NUMBER;

  BEGIN

     --dbms_output('create_new_terr_qtype_usg_rec START');

     FOR i IN 0..p_terr_qtype_usgs_tbl.COUNT-1 LOOP

        /* Instantiate record items from appropriate items */
        l_terr_qtype_usgs_rec.TERR_QUAL_TYPE_USG_ID    := FND_API.G_MISS_NUM;
        l_terr_qtype_usgs_rec.TERR_ID                  := p_new_terr_id;
        l_terr_qtype_usgs_rec.QUAL_TYPE_USG_ID         := p_terr_qtype_usgs_tbl(i).qual_type_usg_id;
        l_terr_qtype_usgs_rec.LAST_UPDATE_DATE         := SYSDATE;
        l_terr_qtype_usgs_rec.LAST_UPDATED_BY          := FND_GLOBAL.USER_ID;
        l_terr_qtype_usgs_rec.CREATION_DATE            := SYSDATE;
        l_terr_qtype_usgs_rec.CREATED_BY               := FND_GLOBAL.USER_ID;
        l_terr_qtype_usgs_rec.LAST_UPDATE_LOGIN        := FND_GLOBAL.LOGIN_ID;
        l_terr_qtype_usgs_rec.ORG_ID                   := p_terr_qtype_usgs_tbl(i).org_id;


        create_terr_qualtype_usage(
              P_Api_Version_Number        => l_api_version_number,
              P_Init_Msg_List             => FND_API.G_TRUE,
              P_Commit                    => FND_API.G_FALSE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              P_Terr_Id                   => p_new_terr_id,
              P_Terr_QualTypeUsgs_Rec     => l_terr_qtype_usgs_rec,
              X_Return_Status             => l_return_status,
              X_Msg_Count                 => l_msg_count,
              X_Msg_Data                  => l_msg_data,
              X_Terr_QualTypeUsgs_Id      => l_terr_qtype_usg_id,
              X_Terr_QualTypeUsgs_Out_Rec => l_terr_qtype_usgs_out_rec);

        --dbms_output( 'create_new_terr_qtype_usgs END: l_return_status = ' ||l_return_status || ' terr_qtype_usg_id = ' || TO_CHAR(l_terr_qtype_usgs_out_rec.terr_qual_type_usg_id));

     END LOOP;

     --dbms_output('create_new_terr_qtype_usg_rec END');

  END create_new_terr_qtype_usgs;

/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_new_terr_qual_rec( p_new_terr_id         IN  NUMBER
                                    , p_terr_qual_rec       IN  Terr_Qual_Rec_Type
                                    , x_new_terr_qual_id    OUT NOCOPY NUMBER )
  IS
      /* local standard API variables */
      l_api_version_number        NUMBER := 1.0;
      l_return_status             VARCHAR2(200);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      /* local record variables */
      l_new_terr_qual_rec         Terr_Qual_Rec_Type;
      l_terr_qual_out_rec         Terr_Qual_Out_Rec_Type;

      l_new_terr_qual_id          NUMBER;

      /* START OF 1520656 BUG FIX - JDOCHERT 12/07 */
      CURSOR c_get_terr(lp_terr_id NUMBER)
      IS SELECT 'Y'
      FROM jtf_terr_ALL
      WHERE template_flag = 'Y'
        AND terr_id = lp_terr_id;

      l_template_flag      VARCHAR2(1);
      /* END OF 1520656 BUG FIX - JDOCHERT 12/07 */

  BEGIN

     --dbms_output('create_new_terr_qual_rec START');

     /* Instantiate record items from appropriate template items */
     l_new_terr_qual_rec.Rowid                   := NULL;
     l_new_terr_qual_rec.TERR_QUAL_ID            := FND_API.G_MISS_NUM;
     l_new_terr_qual_rec.LAST_UPDATE_DATE        := SYSDATE;
     l_new_terr_qual_rec.LAST_UPDATED_BY         := FND_GLOBAL.USER_ID;
     l_new_terr_qual_rec.CREATION_DATE           := SYSDATE;
     l_new_terr_qual_rec.CREATED_BY              := FND_GLOBAL.USER_ID;
     l_new_terr_qual_rec.LAST_UPDATE_LOGIN       := FND_GLOBAL.LOGIN_ID;

     /* this value is passed into procedure */
     l_new_terr_qual_rec.TERR_ID                 := p_new_terr_id;

     l_new_terr_qual_rec.QUAL_USG_ID             := p_terr_qual_rec.qual_usg_id;
     l_new_terr_qual_rec.USE_TO_NAME_FLAG        := p_terr_qual_rec.use_to_name_flag;
     l_new_terr_qual_rec.GENERATE_FLAG           := p_terr_qual_rec.generate_flag;
     l_new_terr_qual_rec.OVERLAP_ALLOWED_FLAG    := p_terr_qual_rec.overlap_allowed_flag;
     l_new_terr_qual_rec.QUALIFIER_MODE          := '';
     l_new_terr_qual_rec.ORG_ID                  := p_terr_qual_rec.org_id;


     /* START OF 1520656 BUG FIX - JDOCHERT 12/07 */
     OPEN c_get_terr(p_new_terr_id);
     FETCH c_get_terr INTO l_template_flag;
     CLOSE c_get_terr;

     IF (l_template_flag = 'Y') THEN
        l_new_terr_qual_rec.QUALIFIER_MODE  := p_terr_qual_rec.qualifier_mode;
     ELSE
        l_new_terr_qual_rec.QUALIFIER_MODE  := NULL;
     END IF;
     /* END OF 1520656 BUG FIX - JDOCHERT 12/07 */

     create_terr_qualifier(
           P_Api_Version_Number   => l_api_version_number,
           P_Init_Msg_List        => FND_API.G_TRUE,
           P_Commit               => FND_API.G_FALSE,
           p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
           P_Terr_Id              => l_new_terr_qual_rec.terr_id,
           P_Terr_Qual_rec        => l_new_terr_qual_rec,
           X_Return_Status        => l_return_status,
           X_Msg_Count            => l_msg_count,
           X_Msg_Data             => l_msg_data,
           X_Terr_Qual_Id         => l_new_terr_qual_id,
           X_Terr_Qual_Out_Rec    => l_terr_qual_out_rec);


    x_new_terr_qual_id := l_new_terr_qual_id;

    --dbms_output('create_new_terr_qual_rec END: l_return_status = ' || l_return_status);
    --dbms_output('create_new_terr_qual_rec END: terr_qual_id = ' || TO_CHAR(x_new_terr_qual_id));

  END create_new_terr_qual_rec;


/*--------------------------------------------------------------------------------------*/
  PROCEDURE create_new_terr_value_rec( p_new_terr_id         IN  NUMBER
                                     , p_new_terr_qual_id    IN  NUMBER
                                     , p_terr_value_rec      IN  Terr_Values_Rec_Type
                                     , x_new_terr_value_id   OUT NOCOPY NUMBER )
  IS
      /* local standard API variables */
      l_api_version_number        NUMBER := 1.0;
      l_return_status             VARCHAR2(200);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      /* local record variables */
      l_new_terr_value_rec        Terr_Values_Rec_Type;
      l_terr_value_out_rec        Terr_Values_Out_Rec_Type;

      l_new_terr_value_id             NUMBER;

      /* START OF 1520656 BUG FIX - JDOCHERT 12/07 */
      CURSOR c_get_terr(lp_terr_id NUMBER)
      IS SELECT 'Y'
      FROM jtf_terr
      WHERE template_flag = 'Y'
        AND terr_id = lp_terr_id;

      l_template_flag      VARCHAR2(1);
      /* END OF 1520656 BUG FIX - JDOCHERT 12/07 */

  BEGIN

     --dbms_output('create_new_terr_value_rec START');

          /* Instantiate record items from template qualifier value record */
          l_new_terr_value_rec.TERR_VALUE_ID                    := NULL;
          l_new_terr_value_rec.LAST_UPDATE_DATE                 := SYSDATE;
          l_new_terr_value_rec.LAST_UPDATED_BY                  := fnd_global.user_id;
          l_new_terr_value_rec.CREATION_DATE                    := SYSDATE;
          l_new_terr_value_rec.CREATED_BY                       := fnd_global.user_id;
          l_new_terr_value_rec.LAST_UPDATE_LOGIN                := fnd_global.login_id;

          /* this value comes from newly created territory qualifier (above) */
          l_new_terr_value_rec.TERR_QUAL_ID                     := p_new_terr_qual_id;

          l_new_terr_value_rec.INCLUDE_FLAG                     := p_terr_value_rec.include_flag;
          l_new_terr_value_rec.COMPARISON_OPERATOR              := p_terr_value_rec.comparison_operator;
          l_new_terr_value_rec.LOW_VALUE_CHAR                   := p_terr_value_rec.low_value_char;
          l_new_terr_value_rec.HIGH_VALUE_CHAR                  := p_terr_value_rec.high_value_char;
          l_new_terr_value_rec.LOW_VALUE_NUMBER                 := p_terr_value_rec.low_value_number;
          l_new_terr_value_rec.HIGH_VALUE_NUMBER                := p_terr_value_rec.high_value_number;
          l_new_terr_value_rec.VALUE_SET                        := NULL;
          l_new_terr_value_rec.INTEREST_TYPE_ID                 := p_terr_value_rec.interest_type_id;
          l_new_terr_value_rec.PRIMARY_INTEREST_CODE_ID         := p_terr_value_rec.primary_interest_code_id;
          l_new_terr_value_rec.SECONDARY_INTEREST_CODE_ID       := p_terr_value_rec.secondary_interest_code_id;
          l_new_terr_value_rec.CURRENCY_CODE                    := p_terr_value_rec.currency_code;
          l_new_terr_value_rec.ID_USED_FLAG                     := p_terr_value_rec.id_used_flag;
          l_new_terr_value_rec.LOW_VALUE_CHAR_ID                := p_terr_value_rec.low_value_char_id;
          --l_new_terr_value_rec.QUALIFIER_TBL_INDEX            := p_terr_value_rec.qualifier_tbl_index;
          l_new_terr_value_rec.ORG_ID                           := p_terr_value_rec.org_id;
          l_new_terr_value_rec.CNR_GROUP_ID                     := p_terr_value_rec.cnr_group_id;

          --arpatel 09/06
          l_new_terr_value_rec.VALUE1_ID                        := p_terr_value_rec.value1_id;
          l_new_terr_value_rec.VALUE2_ID                        := p_terr_value_rec.value2_id;
          l_new_terr_value_rec.VALUE3_ID                        := p_terr_value_rec.value3_id;
          l_new_terr_value_rec.VALUE4_ID                        := p_terr_value_rec.value4_id;

           /* START OF 1520656 BUG FIX - JDOCHERT 12/07 */
           OPEN c_get_terr(p_new_terr_id);
           FETCH c_get_terr INTO l_template_flag;
           CLOSE c_get_terr;

           IF (l_template_flag = 'Y') THEN
              l_new_terr_value_rec.value_set  := p_terr_value_rec.value_set;
           ELSE
              l_new_terr_value_rec.value_set      := NULL;
           END IF;
           /* END OF 1520656 BUG FIX - JDOCHERT 12/07 */

          /* insert value */
          create_terr_value(
             P_Api_Version_Number   => 1.0,
             P_Init_Msg_List        => FND_API.G_TRUE,
             P_Commit               => FND_API.G_FALSE,
             p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
             P_Terr_Id              => p_new_terr_id,
             P_Terr_Qual_id         => l_new_terr_value_rec.terr_qual_id,
             P_Terr_Value_Rec       => l_new_terr_value_rec,
             X_Return_Status        => l_return_status,
             X_Msg_Count            => l_msg_count,
             X_Msg_Data             => l_msg_data,
             X_Terr_Value_Id        => l_new_terr_value_id,
             X_Terr_Value_Out_Rec   => l_terr_value_out_rec);


    x_new_terr_value_id := l_new_terr_value_id;

    --dbms_output('create_new_terr_value_rec END: terr_value_id = ' || TO_CHAR(x_new_terr_value_id));

  END create_new_terr_value_rec;

/*--------------------------------------------------------------------------------------*/
  -- inserts the constant qualifiers and values for copied territories
  PROCEDURE insert_copied_qual_values ( p_template_terr_id    NUMBER
                                      , p_new_terr_id         NUMBER ) IS

      /* local standard API variables */
      l_api_version_number        NUMBER := 1.0;
      l_return_status             VARCHAR2(200);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);

      /* cursor to get STATIC qualifiers */
      CURSOR c_get_terr_qual (p_template_terr_id NUMBER) IS
       SELECT j1.rowid
            , j1.TERR_QUAL_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_ID
            , j1.QUAL_USG_ID
            , j1.USE_TO_NAME_FLAG
            , j1.GENERATE_FLAG
            , j1.OVERLAP_ALLOWED_FLAG
            , j1.QUALIFIER_MODE
            , j1.ORG_ID
      FROM   jtf_terr_qual j1
      WHERE  j1.terr_id = p_template_terr_id;

      /* cursor to get values for STATIC qualifiers' values */
      CURSOR c_get_terr_value (p_terr_qual_id NUMBER) IS
       SELECT j1.TERR_VALUE_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_QUAL_ID
            , j1.INCLUDE_FLAG
            , j1.COMPARISON_OPERATOR
            , j1.LOW_VALUE_CHAR
            , j1.HIGH_VALUE_CHAR
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , j1.VALUE_SET
            , j1.INTEREST_TYPE_ID
            , j1.PRIMARY_INTEREST_CODE_ID
            , j1.SECONDARY_INTEREST_CODE_ID
            , j1.CURRENCY_CODE
            , j1.ORG_ID
            , j1.ID_USED_FLAG
            , j1.LOW_VALUE_CHAR_ID
            , NULL QUALIFIER_TBL_INDEX
            , j1.CNR_GROUP_ID
            , j1.VALUE1_ID
            , j1.VALUE2_ID
            , j1.VALUE3_ID
            , j1.VALUE4_ID
      FROM   jtf_terr_values j1
      WHERE  j1.terr_qual_id = p_terr_qual_id;

      /* local record variables */
      l_tmpl_terr_qual_rec        Terr_Qual_Rec_Type;

      l_tmpl_terr_value_rec       Terr_Values_Rec_Type;
      l_terr_value_out_rec        Terr_Values_Out_Rec_Type;

      l_new_terr_qual_id          NUMBER;
      l_new_terr_value_id         NUMBER;

   BEGIN

     --dbms_output('insert_copied_qual_values START');

      /* get the STATIC qualifiers for this template */
      OPEN c_get_terr_qual (p_template_terr_id);
      LOOP

        FETCH c_get_terr_qual INTO
              l_tmpl_terr_qual_rec.rowid
            , l_tmpl_terr_qual_rec.TERR_QUAL_ID
            , l_tmpl_terr_qual_rec.LAST_UPDATE_DATE
            , l_tmpl_terr_qual_rec.LAST_UPDATED_BY
            , l_tmpl_terr_qual_rec.CREATION_DATE
            , l_tmpl_terr_qual_rec.CREATED_BY
            , l_tmpl_terr_qual_rec.LAST_UPDATE_LOGIN
            , l_tmpl_terr_qual_rec.TERR_ID
            , l_tmpl_terr_qual_rec.QUAL_USG_ID
            , l_tmpl_terr_qual_rec.USE_TO_NAME_FLAG
            , l_tmpl_terr_qual_rec.GENERATE_FLAG
            , l_tmpl_terr_qual_rec.OVERLAP_ALLOWED_FLAG
            , l_tmpl_terr_qual_rec.QUALIFIER_MODE
            , l_tmpl_terr_qual_rec.ORG_ID;

        EXIT WHEN c_get_terr_qual%NOTFOUND;

        --dbms_output('qual id = ' || l_tmpl_terr_qual_rec.QUAL_USG_ID);

        create_new_terr_qual_rec( p_new_terr_id, l_tmpl_terr_qual_rec, l_new_terr_qual_id);

        /* get the values for this template qualifier */
        OPEN c_get_terr_value (l_tmpl_terr_qual_rec.terr_qual_id);
        LOOP

          FETCH c_get_terr_value INTO
              l_tmpl_terr_value_rec.TERR_VALUE_ID
            , l_tmpl_terr_value_rec.LAST_UPDATE_DATE
            , l_tmpl_terr_value_rec.LAST_UPDATED_BY
            , l_tmpl_terr_value_rec.CREATION_DATE
            , l_tmpl_terr_value_rec.CREATED_BY
            , l_tmpl_terr_value_rec.LAST_UPDATE_LOGIN
            , l_tmpl_terr_value_rec.TERR_QUAL_ID
            , l_tmpl_terr_value_rec.INCLUDE_FLAG
            , l_tmpl_terr_value_rec.COMPARISON_OPERATOR
            , l_tmpl_terr_value_rec.LOW_VALUE_CHAR
            , l_tmpl_terr_value_rec.HIGH_VALUE_CHAR
            , l_tmpl_terr_value_rec.LOW_VALUE_NUMBER
            , l_tmpl_terr_value_rec.HIGH_VALUE_NUMBER
            , l_tmpl_terr_value_rec.VALUE_SET
            , l_tmpl_terr_value_rec.INTEREST_TYPE_ID
            , l_tmpl_terr_value_rec.PRIMARY_INTEREST_CODE_ID
            , l_tmpl_terr_value_rec.SECONDARY_INTEREST_CODE_ID
            , l_tmpl_terr_value_rec.CURRENCY_CODE
            , l_tmpl_terr_value_rec.ORG_ID
            , l_tmpl_terr_value_rec.ID_USED_FLAG
            , l_tmpl_terr_value_rec.LOW_VALUE_CHAR_ID
            , l_tmpl_terr_value_rec.QUALIFIER_TBL_INDEX
            , l_tmpl_terr_value_rec.CNR_GROUP_ID
            , l_tmpl_terr_value_rec.VALUE1_ID
            , l_tmpl_terr_value_rec.VALUE2_ID
            , l_tmpl_terr_value_rec.VALUE3_ID
            , l_tmpl_terr_value_rec.VALUE4_ID;

          EXIT WHEN c_get_terr_value%NOTFOUND;

          create_new_terr_value_rec( p_new_terr_id
                                   , l_new_terr_qual_id
                                   , l_tmpl_terr_value_rec
                                   , l_new_terr_value_id);

        END LOOP;
        CLOSE c_get_terr_value;

     END LOOP;
     CLOSE c_get_terr_qual;

     --dbms_output('insert_copied_qual_values END');

  END insert_copied_qual_values;


/*--------------------------------------------------------------------------------------*/
  -- inserts the constant qualifiers and values
  PROCEDURE insert_static_qual_values ( p_template_terr_id    NUMBER
                                      , p_new_terr_id         NUMBER ) IS

      /* local standard API variables */
      l_api_version_number        NUMBER := 1.0;
      l_return_status             VARCHAR2(200);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);


      /* cursor to get STATIC qualifiers */
      CURSOR c_get_terr_qual (p_template_terr_id NUMBER) IS
       SELECT j1.rowid
            , j1.TERR_QUAL_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_ID
            , j1.QUAL_USG_ID
            , j1.USE_TO_NAME_FLAG
            , j1.GENERATE_FLAG
            , j1.OVERLAP_ALLOWED_FLAG
            , j1.QUALIFIER_MODE
            , j1.ORG_ID
      FROM   jtf_terr_qual j1
      WHERE  j1.terr_id = p_template_terr_id
      AND    j1.qualifier_mode = 'STATIC';

      /* cursor to get values for STATIC qualifiers' values */
      CURSOR c_get_terr_value (p_terr_qual_id NUMBER) IS
       SELECT j1.TERR_VALUE_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_QUAL_ID
            , j1.INCLUDE_FLAG
            , j1.COMPARISON_OPERATOR
            , j1.LOW_VALUE_CHAR
            , j1.HIGH_VALUE_CHAR
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , j1.VALUE_SET
            , j1.INTEREST_TYPE_ID
            , j1.PRIMARY_INTEREST_CODE_ID
            , j1.SECONDARY_INTEREST_CODE_ID
            , j1.CURRENCY_CODE
            , j1.ORG_ID
            , j1.ID_USED_FLAG
            , j1.LOW_VALUE_CHAR_ID
            , NULL QUALIFIER_TBL_INDEX
            , j1.CNR_GROUP_ID
            , j1.VALUE1_ID
            , j1.VALUE2_ID
            , j1.VALUE3_ID
            , j1.VALUE4_ID
      FROM   jtf_terr_values j1
      WHERE  j1.terr_qual_id = p_terr_qual_id;

      /* local record variables */
      l_tmpl_terr_qual_rec        Terr_Qual_Rec_Type;

      l_tmpl_terr_value_rec       Terr_Values_Rec_Type;
      l_terr_value_out_rec        Terr_Values_Out_Rec_Type;

      l_new_terr_qual_id          NUMBER;
      l_new_terr_value_id         NUMBER;

   BEGIN

     --dbms_output('insert_static_qual_values START');

      /* get the STATIC qualifiers for this template */
      OPEN c_get_terr_qual (p_template_terr_id);
      LOOP

        FETCH c_get_terr_qual INTO
              l_tmpl_terr_qual_rec.rowid
            , l_tmpl_terr_qual_rec.TERR_QUAL_ID
            , l_tmpl_terr_qual_rec.LAST_UPDATE_DATE
            , l_tmpl_terr_qual_rec.LAST_UPDATED_BY
            , l_tmpl_terr_qual_rec.CREATION_DATE
            , l_tmpl_terr_qual_rec.CREATED_BY
            , l_tmpl_terr_qual_rec.LAST_UPDATE_LOGIN
            , l_tmpl_terr_qual_rec.TERR_ID
            , l_tmpl_terr_qual_rec.QUAL_USG_ID
            , l_tmpl_terr_qual_rec.USE_TO_NAME_FLAG
            , l_tmpl_terr_qual_rec.GENERATE_FLAG
            , l_tmpl_terr_qual_rec.OVERLAP_ALLOWED_FLAG
            , l_tmpl_terr_qual_rec.QUALIFIER_MODE
            , l_tmpl_terr_qual_rec.ORG_ID;

        EXIT WHEN c_get_terr_qual%NOTFOUND;

        create_new_terr_qual_rec( p_new_terr_id, l_tmpl_terr_qual_rec, l_new_terr_qual_id);

        /* get the values for this template qualifier */
        OPEN c_get_terr_value (l_tmpl_terr_qual_rec.terr_qual_id);
        LOOP

          FETCH c_get_terr_value INTO
              l_tmpl_terr_value_rec.TERR_VALUE_ID
            , l_tmpl_terr_value_rec.LAST_UPDATE_DATE
            , l_tmpl_terr_value_rec.LAST_UPDATED_BY
            , l_tmpl_terr_value_rec.CREATION_DATE
            , l_tmpl_terr_value_rec.CREATED_BY
            , l_tmpl_terr_value_rec.LAST_UPDATE_LOGIN
            , l_tmpl_terr_value_rec.TERR_QUAL_ID
            , l_tmpl_terr_value_rec.INCLUDE_FLAG
            , l_tmpl_terr_value_rec.COMPARISON_OPERATOR
            , l_tmpl_terr_value_rec.LOW_VALUE_CHAR
            , l_tmpl_terr_value_rec.HIGH_VALUE_CHAR
            , l_tmpl_terr_value_rec.LOW_VALUE_NUMBER
            , l_tmpl_terr_value_rec.HIGH_VALUE_NUMBER
            , l_tmpl_terr_value_rec.VALUE_SET
            , l_tmpl_terr_value_rec.INTEREST_TYPE_ID
            , l_tmpl_terr_value_rec.PRIMARY_INTEREST_CODE_ID
            , l_tmpl_terr_value_rec.SECONDARY_INTEREST_CODE_ID
            , l_tmpl_terr_value_rec.CURRENCY_CODE
            , l_tmpl_terr_value_rec.ORG_ID
            , l_tmpl_terr_value_rec.ID_USED_FLAG
            , l_tmpl_terr_value_rec.LOW_VALUE_CHAR_ID
            , l_tmpl_terr_value_rec.QUALIFIER_TBL_INDEX
            , l_tmpl_terr_value_rec.CNR_GROUP_ID
            , l_tmpl_terr_value_rec.VALUE1_ID
            , l_tmpl_terr_value_rec.VALUE2_ID
            , l_tmpl_terr_value_rec.VALUE3_ID
            , l_tmpl_terr_value_rec.VALUE4_ID;

          EXIT WHEN c_get_terr_value%NOTFOUND;

          create_new_terr_value_rec( p_new_terr_id
                                   , l_new_terr_qual_id
                                   , l_tmpl_terr_value_rec
                                   , l_new_terr_value_id);

        END LOOP;
        CLOSE c_get_terr_value;

     END LOOP;
     CLOSE c_get_terr_qual;

     --dbms_output('insert_static_qual_values END');

  END insert_static_qual_values;


/*--------------------------------------------------------------------------------------*/
  -- loads the values for generation into a PL/SQL table
  PROCEDURE load_dynamic_qual_values ( p_template_terr_id IN  NUMBER
                                     , x_qual_tbl         OUT NOCOPY Dynamic_Qual_Tbl_Type
                                     , x_val_tbl          OUT NOCOPY Terr_Values_Tbl_Type ) IS

    /* cursor to get dynamic qualifiers */
    CURSOR c_get_terr_qual (p_template_terr_id NUMBER) IS
       SELECT j1.rowid
            , j1.TERR_QUAL_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_ID
            , j1.QUAL_USG_ID
            , j1.USE_TO_NAME_FLAG
            , j1.GENERATE_FLAG
            , j1.OVERLAP_ALLOWED_FLAG
            , j1.QUALIFIER_MODE
            , j1.ORG_ID
      FROM   jtf_terr_qual j1
      WHERE  j1.terr_id = p_template_terr_id
      AND    j1.qualifier_mode = 'DYNAMIC';

    /* cursor to get values for dynamic qualifier values */
    CURSOR c_get_terr_values (p_terr_qual_id NUMBER) IS
       SELECT j1.TERR_VALUE_ID
            , j1.LAST_UPDATE_DATE
            , j1.LAST_UPDATED_BY
            , j1.CREATION_DATE
            , j1.CREATED_BY
            , j1.LAST_UPDATE_LOGIN
            , j1.TERR_QUAL_ID
            , j1.INCLUDE_FLAG
            , j1.COMPARISON_OPERATOR
            , j1.LOW_VALUE_CHAR
            , j1.HIGH_VALUE_CHAR
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , j1.VALUE_SET
            , j1.INTEREST_TYPE_ID
            , j1.PRIMARY_INTEREST_CODE_ID
            , j1.SECONDARY_INTEREST_CODE_ID
            , j1.CURRENCY_CODE
            , j1.ID_USED_FLAG
            , j1.LOW_VALUE_CHAR_ID
            , NULL QUALIFIER_TBL_INDEX
            , j1.ORG_ID
            , j1.CNR_GROUP_ID
            , j1.VALUE1_ID
            , j1.VALUE2_ID
            , j1.VALUE3_ID
            , j1.VALUE4_ID
      FROM   jtf_terr_values j1
      WHERE  j1.terr_qual_id = p_terr_qual_id
      ORDER BY j1.value_set;

    l_tmpl_terr_qual_rec        Terr_Qual_Rec_Type;

    l_qual_curr_rec_num         NUMBER := 0;
    l_val_curr_rec_num          NUMBER := 0;

  BEGIN

    --dbms_output('[1] load_dynamic_qual_values');

    /* get the DYNAMIC qualifiers for this template territory */
    OPEN c_get_terr_qual(p_template_terr_id);
    LOOP
       FETCH c_get_terr_qual INTO
              l_tmpl_terr_qual_rec.rowid
            , l_tmpl_terr_qual_rec.TERR_QUAL_ID
            , l_tmpl_terr_qual_rec.LAST_UPDATE_DATE
            , l_tmpl_terr_qual_rec.LAST_UPDATED_BY
            , l_tmpl_terr_qual_rec.CREATION_DATE
            , l_tmpl_terr_qual_rec.CREATED_BY
            , l_tmpl_terr_qual_rec.LAST_UPDATE_LOGIN
            , l_tmpl_terr_qual_rec.TERR_ID
            , l_tmpl_terr_qual_rec.QUAL_USG_ID
            , l_tmpl_terr_qual_rec.USE_TO_NAME_FLAG
            , l_tmpl_terr_qual_rec.GENERATE_FLAG
            , l_tmpl_terr_qual_rec.OVERLAP_ALLOWED_FLAG
            , l_tmpl_terr_qual_rec.QUALIFIER_MODE
            , l_tmpl_terr_qual_rec.ORG_ID;

       EXIT WHEN c_get_terr_qual%NOTFOUND;

       --dbms_output('[2] load_dynamic_qual_values');

       x_qual_tbl(l_qual_curr_rec_num).QUAL_USG_ID             := l_tmpl_terr_qual_rec.qual_usg_id;

       x_qual_tbl(l_qual_curr_rec_num).USE_TO_NAME_FLAG        := l_tmpl_terr_qual_rec.use_to_name_flag;
       x_qual_tbl(l_qual_curr_rec_num).GENERATE_FLAG           := l_tmpl_terr_qual_rec.generate_flag;
       x_qual_tbl(l_qual_curr_rec_num).OVERLAP_ALLOWED_FLAG    := l_tmpl_terr_qual_rec.overlap_allowed_flag;
       x_qual_tbl(l_qual_curr_rec_num).QUALIFIER_MODE          := '';
       x_qual_tbl(l_qual_curr_rec_num).ORG_ID                  := l_tmpl_terr_qual_rec.org_id;


       x_qual_tbl(l_qual_curr_rec_num).start_record            := l_val_curr_rec_num;
       x_qual_tbl(l_qual_curr_rec_num).current_record          := 0;

       x_qual_tbl(l_qual_curr_rec_num).current_value_set       := 1;

       --dbms_output('[3] load_dynamic_qual_values');

       /* get the values for this territory qualifier */
       OPEN c_get_terr_values(l_tmpl_terr_qual_rec.terr_qual_id);
       LOOP
          FETCH c_get_terr_values INTO
              x_val_tbl(l_val_curr_rec_num).TERR_VALUE_ID
            , x_val_tbl(l_val_curr_rec_num).LAST_UPDATE_DATE
            , x_val_tbl(l_val_curr_rec_num).LAST_UPDATED_BY
            , x_val_tbl(l_val_curr_rec_num).CREATION_DATE
            , x_val_tbl(l_val_curr_rec_num).CREATED_BY
            , x_val_tbl(l_val_curr_rec_num).LAST_UPDATE_LOGIN
            , x_val_tbl(l_val_curr_rec_num).TERR_QUAL_ID
            , x_val_tbl(l_val_curr_rec_num).INCLUDE_FLAG
            , x_val_tbl(l_val_curr_rec_num).COMPARISON_OPERATOR
            , x_val_tbl(l_val_curr_rec_num).LOW_VALUE_CHAR
            , x_val_tbl(l_val_curr_rec_num).HIGH_VALUE_CHAR
            , x_val_tbl(l_val_curr_rec_num).LOW_VALUE_NUMBER
            , x_val_tbl(l_val_curr_rec_num).HIGH_VALUE_NUMBER
            , x_val_tbl(l_val_curr_rec_num).VALUE_SET
            , x_val_tbl(l_val_curr_rec_num).INTEREST_TYPE_ID
            , x_val_tbl(l_val_curr_rec_num).PRIMARY_INTEREST_CODE_ID
            , x_val_tbl(l_val_curr_rec_num).SECONDARY_INTEREST_CODE_ID
            , x_val_tbl(l_val_curr_rec_num).CURRENCY_CODE
            , x_val_tbl(l_val_curr_rec_num).ID_USED_FLAG
            , x_val_tbl(l_val_curr_rec_num).LOW_VALUE_CHAR_ID
            , x_val_tbl(l_val_curr_rec_num).QUALIFIER_TBL_INDEX
            , x_val_tbl(l_val_curr_rec_num).ORG_ID
            , x_val_tbl(l_val_curr_rec_num).CNR_GROUP_ID
            , x_val_tbl(l_val_curr_rec_num).VALUE1_ID
            , x_val_tbl(l_val_curr_rec_num).VALUE2_ID
            , x_val_tbl(l_val_curr_rec_num).VALUE3_ID
            , x_val_tbl(l_val_curr_rec_num).VALUE4_ID;

          EXIT WHEN c_get_terr_values%NOTFOUND;

          /* increment loop counter */
          l_val_curr_rec_num := l_val_curr_rec_num + 1;

          --dbms_output('Value of l_val_curr_rec_num = '||TO_CHAR(l_val_curr_rec_num ));

       END LOOP;

       /* get number of value records for this qualifier */
       x_qual_tbl(l_qual_curr_rec_num).num_records := c_get_terr_values%ROWCOUNT;

      CLOSE c_get_terr_values;

      /* increment loop counter */
      l_qual_curr_rec_num := l_qual_curr_rec_num + 1;

    END LOOP;

    CLOSE c_get_terr_qual;

  END load_dynamic_qual_values;


/*--------------------------------------------------------------------------------------*/
  /* increments counter for the values used in generation
  ** THis is called after generation of each territory.
  ** Works like a digital counter where the last (right-most) digit is
  ** incremented. If it reaches its max value, it is set to zero and the
  ** previous digit is incremented. THis is done recursively until you reach
  ** a digit which has not reached its max value.
  ** THe number of digits here is the number of qualifiers used in generation.
  ** THe max value for each digit is the number of values for each qualifier.
  */
  FUNCTION increment_counter( p_dyn_qual_tbl      IN OUT NOCOPY Dynamic_Qual_Tbl_Type
                            , p_qual_index        IN     NUMBER
                            , p_dyn_qual_val_tbl  IN     Terr_Values_Tbl_Type)
  RETURN BOOLEAN
  IS

     i              NUMBER;
     l_start_rec    NUMBER;
     l_rec_counter  NUMBER := 0;

  BEGIN

    --dbms_output( '[1]Increment Counter: p_qual_index = ' || p_qual_index);

    --dbms_output(  '[2]Increment Counter: p_dyn_qual_tbl(i).current_record = ' || TO_char(p_dyn_qual_tbl(p_qual_index).current_record));

    --dbms_output( '[3]Increment Counter:p_dyn_qual_tbl(i).start_record = ' || TO_CHAR(p_dyn_qual_tbl(p_qual_index).start_record));

    /**/
    l_start_rec := p_dyn_qual_tbl(p_qual_index).start_record +
                   p_dyn_qual_tbl(p_qual_index).current_record;

    i := l_start_rec;

    --dbms_output( '[4]Increment Counter: l_start_rec = ' || TO_CHAR(l_start_rec));

    FOR i in l_start_rec .. p_dyn_qual_val_tbl.COUNT-1 LOOP

      /* added March 4 */
      EXIT WHEN ( p_dyn_qual_val_tbl(i).value_set <>
                       p_dyn_qual_tbl(p_qual_index).current_value_set );

      l_rec_counter := l_rec_counter + 1;

      --dbms_output( '[5]Increment Counter: value_set = ' || TO_CHAR(p_dyn_qual_val_tbl(i).value_set) || ' l_rec_counter = ' || l_rec_counter );

    END LOOP;
    /**/

    /* move current record pointer to start of next value set */
    p_dyn_qual_tbl(p_qual_index).current_record :=
                                      p_dyn_qual_tbl(p_qual_index).current_record + l_rec_counter;
    /**/

    --dbms_output(  '[6]Increment Counter: p_dyn_qual_tbl(i).current_record = ' || TO_char(p_dyn_qual_tbl(p_qual_index).current_record));

    /* increment current value_set counter */
    p_dyn_qual_tbl(p_qual_index).current_value_set :=
                                      p_dyn_qual_tbl(p_qual_index).current_value_set + 1;
    /**/

      --dbms_output( '[7]Increment Counter: value_set = ' || TO_CHAR(p_dyn_qual_tbl(p_qual_index).current_value_set));

    /* last value for qualifier reached, so reset and increment previous qualifier */
    IF ( p_dyn_qual_tbl(p_qual_index).current_record =
                                   p_dyn_qual_tbl(p_qual_index).num_records ) THEN

         --dbms_output( '[-]last value for the CURRENT qualifier reached');
         p_dyn_qual_tbl(p_qual_index).current_record := 0;

         /* added March 3 */
         p_dyn_qual_tbl(p_qual_index).current_value_set := 1;
         /**/

         IF (p_qual_index = 0) THEN
            --dbms_output( '[-]last value for the first qualifier reached');

             -- last value for the first qualifier reached
             RETURN FALSE;
         ELSE
            --dbms_output( '[-]Recursively calling increment_counter');

            RETURN increment_counter(p_dyn_qual_tbl, p_qual_index -1, p_dyn_qual_val_tbl);
         END IF;

    ELSE
      RETURN TRUE;
    END IF;

  END increment_counter;

  /* for debugging */
  --PROCEDURE print_qual_table (p_qualifier_table Dynamic_Qual_Tbl_Type) IS
  --BEGIN
  --  dbms_output.put_line('--------');
  --  FOR i IN 0 .. p_qualifier_table.COUNT-1 LOOP
  --    dbms_output.put_line('Qual_Usg_Id: ' || to_char(p_qualifier_table(i).qual_usg_id));
  --    dbms_output.put_line('Start_record: '||to_char(p_qualifier_table(i).start_record)
  --            ||'  Number of records: '||to_char(p_qualifier_table(i).num_records)
  --            ||'   Current record: '||to_char(p_qualifier_table(i).current_record));
  --  END LOOP;
  --END print_qual_table;


/*--------------------------------------------------------------------------------------*/
   PROCEDURE Gen_Template_Territories (
    p_Api_Version_Number          IN  NUMBER,
    p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
    p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level            IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_Template_Terr_Id            IN  NUMBER,
    x_Return_Status               OUT NOCOPY VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_Msg_Data                    OUT NOCOPY VARCHAR2,
    x_num_gen_terr                OUT NOCOPY NUMBER
   )
   AS

      /* local standard API variables */
      l_api_name              CONSTANT VARCHAR2(30) := 'Generate_Template_Territories';
      l_api_version_number    CONSTANT NUMBER       := 1.0;
      l_return_status         VARCHAR2(200);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(2000);

      /* local variables */
      l_template_terr_rec     Terr_All_Rec_Type;
      l_new_terr_id           NUMBER;

      l_tmpl_usgs_tbl         Terr_Usgs_Tbl_Type;
      l_tmpl_qtype_usgs_tbl   Terr_QualTypeUsgs_Tbl_Type;

      l_dyn_qual_tbl          Dynamic_Qual_Tbl_Type;
      l_tmpl_terr_qual_rec    Terr_Qual_Rec_Type;
      l_new_terr_qual_id      NUMBER;

      l_dyn_qual_val_tbl      Terr_Values_Tbl_Type;
      l_new_terr_value_id     NUMBER;

      l_num_gen_terr          NUMBER := 0;
      l_rec_index             NUMBER := 0;
      l_terr_count            NUMBER := 0;
      l_tbl_count             NUMBER;

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT GEN_TEMPLATE_TERR_PVT;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      /* ===================== */
      /*    API BODY START     */
      /* ======================*/

      --arpatel 07/13 bug#1872642
      --IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

         /* Debug message */
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
         THEN
            FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_VALIDATE_MSG');
            FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Template_Record');
            FND_MSG_PUB.Add;
         END IF;

         /* Invoke validation procedures */
         Validate_Template_Record( p_init_msg_list    => FND_API.G_FALSE
                                 , p_Template_Terr_Id => p_template_terr_id
                                 , x_Return_Status    => x_return_status
                                 , x_msg_count        => x_msg_count
                                 , x_msg_data         => x_msg_data );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
         END IF;

      --END IF;

      initialise( p_template_terr_id
                , l_template_terr_rec
                , l_num_gen_terr
                , l_tmpl_usgs_tbl
                , l_tmpl_qtype_usgs_tbl);

      --dbms_output( '[1] After Initialize: l_num_gen_terr = ' || TO_CHAR(l_num_gen_terr) );

      load_dynamic_qual_values(p_template_terr_id, l_dyn_qual_tbl, l_dyn_qual_val_tbl);

      /* for debugging purposes */
      --print_qual_table(l_dyn_qual_tbl);

      LOOP

         /* create new territory record */
         create_new_terr(l_template_terr_rec, l_terr_count, l_new_terr_id);

         --dbms_output('------------------------------------------------------');
         --dbms_output('------------------------------------------------------');
         --dbms_output( '[' || l_terr_count || '] AFTER create_new_terr PVT: l_new_terr_id = ' || TO_CHAR(l_new_terr_id));

         /* create new territory usages record(s) */
         create_new_terr_usgs(l_new_terr_id, l_tmpl_usgs_tbl);

         /* create new territory qual type usages record(s) */
         create_new_terr_qtype_usgs(l_new_terr_id, l_tmpl_qtype_usgs_tbl);

         /* for all STATIC qualifier values */
         insert_static_qual_values(p_template_terr_id, l_new_terr_id);

         FOR i IN 0 .. l_dyn_qual_tbl.COUNT-1 LOOP

            /* Instantiate record items from appropriate items */
            l_tmpl_terr_qual_rec.qual_usg_id           := l_dyn_qual_tbl(i).QUAL_USG_ID;
            l_tmpl_terr_qual_rec.use_to_name_flag      := l_dyn_qual_tbl(i).USE_TO_NAME_FLAG;
            l_tmpl_terr_qual_rec.generate_flag         := l_dyn_qual_tbl(i).GENERATE_FLAG;
            l_tmpl_terr_qual_rec.overlap_allowed_flag  := l_dyn_qual_tbl(i).OVERLAP_ALLOWED_FLAG;
            l_tmpl_terr_qual_rec.qualifier_mode        := l_dyn_qual_tbl(i).QUALIFIER_MODE;
            l_tmpl_terr_qual_rec.org_id                := l_dyn_qual_tbl(i).ORG_ID;

            /* insert record IN JTF_TERR_QUAL_ALL  */
            create_new_terr_qual_rec(l_new_terr_id, l_tmpl_terr_qual_rec, l_new_terr_qual_id);

           l_rec_index := l_dyn_qual_tbl(i).start_record + l_dyn_qual_tbl(i).current_record;

           --dbms_output( '      Inserting Terr Qual: Qual_Usg_id = ' || TO_CHAR(l_dyn_qual_tbl(i).QUAL_USG_ID) || ' L_REC_INDEX = ' || l_rec_index);

    /*******************************************************************************************/
           LOOP

              /* exit if last qualifier's last value is reached - */
              /* prevents NO_DATA_FOUND exception being raised */
              /* by referring to a non-existent table element */
              EXIT WHEN ( l_tbl_count = l_rec_index );

              --EXIT WHEN ( l_dyn_qual_val_tbl(l_rec_index).value_set =
              --                             l_dyn_qual_tbl(i).current_value_set + 1);

              /* added March 3rd - JDOCHERT */
              /* exit when value set changes */
              EXIT WHEN ( l_dyn_qual_val_tbl(l_rec_index).value_set <>
                                           l_dyn_qual_tbl(i).current_value_set);

              --OR l_dyn_qual_val_tbl(l_rec_index).qual_usg_id
              --                             <> l_dyn_qual_tbl(i).qual_usg_id

              create_new_terr_value_rec( l_new_terr_id
                                       , l_new_terr_qual_id
                                       , l_dyn_qual_val_tbl(l_rec_index)
                                       , l_new_terr_value_id );
/*
              --dbms_output( '           Inserting Terr Val: Value_Set = ' ||
              --                      TO_CHAR(l_dyn_qual_val_tbl(l_rec_index).value_set) ||
              --                      ' l_rec_index = ' || l_rec_index ||
              --                      ' table_count = ' || l_dyn_qual_val_tbl.COUNT);
*/

             l_tbl_count := l_dyn_qual_val_tbl.COUNT;

             /* increment counter to point to next value in value set */
             l_rec_index := l_rec_index + 1;
             --dbms_output('l_tbl_count = ' || l_tbl_count);

             --IF (l_tbl_count = l_rec_index) THEN
             --  dbms_output.put_line('l_rec_index = l_tbl_count = ' || l_tbl_count);
             --END IF;

            END LOOP;

            --dbms_output('exited values inner loop');


    /*******************************************************************************************/

         END LOOP;

         l_terr_count := l_terr_count + 1;

         IF (increment_counter( l_dyn_qual_tbl
                              , l_dyn_qual_tbl.COUNT-1
                              , l_dyn_qual_val_tbl) = FALSE) THEN
            EXIT;
         END IF;

        ----dbms_output( 'Generate_Template_Territories PVT: l_terr_count = ' ||  TO_CHAR(l_terr_count));

        --EXIT WHEN l_terr_count =  l_num_gen_terr;

      END LOOP;

      /* return number of territories that
      ** were generated from template
      */
      x_num_gen_terr := l_terr_count;

      IF (l_terr_count <>  l_num_gen_terr) THEN
         x_return_status     := FND_API.G_RET_STS_ERROR ;
      END IF;

      /* ===================== */
      /*    API BODY END       */
      /* ======================*/

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
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

     WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Generate_Template_Territories PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO GEN_TEMPLATE_TERR_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Generate_Template_Territories PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO GEN_TEMPLATE_TERR_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

     WHEN OTHERS THEN
         --dbms_output('Generate_Template_Territories PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO GEN_TEMPLATE_TERR_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

END Gen_Template_Territories;



/*--------------------------------------------------------------------------------------*/
-- eihsu100
   PROCEDURE Copy_Territory (
    p_Api_Version_Number          IN  NUMBER,
    p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
    p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level            IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_copy_source_terr_Id         IN  NUMBER,
    p_new_terr_rec                IN  Terr_All_Rec_Type,
    p_copy_rsc_flag               IN  VARCHAR2 := 'N',
    p_copy_hierarchy_flag         IN  VARCHAR2 := 'N',
    p_first_terr_node_flag        IN  VARCHAR2 := 'N',
    x_Return_Status               OUT NOCOPY VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_Msg_Data                    OUT NOCOPY VARCHAR2,
    x_Terr_Id                     OUT NOCOPY NUMBER
   )
   AS
      /* local standard API variables */
      l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Territory';
      l_api_version_number    CONSTANT NUMBER       := 1.0;
      l_return_status         VARCHAR2(200);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(2000);

      /* local variables */
      l_copy_source_terr_rec     Terr_All_Rec_Type;
      l_new_terr_id           NUMBER;
      l_terr_id               NUMBER;

      l_tmpl_usgs_tbl         Terr_Usgs_Tbl_Type;
      l_tmpl_qtype_usgs_tbl   Terr_QualTypeUsgs_Tbl_Type;

      l_dyn_qual_tbl          Dynamic_Qual_Tbl_Type;
      l_tmpl_terr_qual_rec    Terr_Qual_Rec_Type;
      l_new_terr_qual_id      NUMBER;

      l_dyn_qual_val_tbl      Terr_Values_Tbl_Type;
      l_new_terr_value_id     NUMBER;

      l_num_gen_terr          NUMBER := 0;
      l_rec_index             NUMBER := 0;
      l_terr_count            NUMBER := 0;
      l_tbl_count             NUMBER;

      CURSOR csr_child_terrs (p_terr_id NUMBER) IS
	  select jta.terr_id
	  from JTF_TERR_ALL jta
	  where jta.parent_territory_id = p_terr_Id;

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT COPY_TERR_PVT;

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
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
          FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
          FND_MSG_PUB.Add;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      /* ===================== */
      /*    API BODY START     */
      /* ======================*/

      /* (validation procedures not necessary) */

      --dbms_output('JTF_TERRITORY_PVT:gen_dupliacte_territory: - BEGIN');
      -- get table of terr usages and terr qual type usages for the source territory
      initialise( p_copy_source_terr_id        -- input TERR_ID
                , l_copy_source_terr_rec       -- output desc
                , l_num_gen_terr            -- output (irrelevant)
                , l_tmpl_usgs_tbl           -- output usages
                , l_tmpl_qtype_usgs_tbl);   -- output transaction types

      --dbms_output( '[1] After Initialize: l_num_gen_terr = ' || TO_CHAR(l_num_gen_terr) );

         /* create new territory record */
         -- (l_copy_source_terr_rec, l_terr_count, l_new_terr_id);
         create_copied_terr(l_copy_source_terr_rec, p_new_terr_rec, 1, p_copy_hierarchy_flag, p_first_terr_node_flag, l_new_terr_id);

         /* create new territory usages record(s) */
         create_new_terr_usgs(l_new_terr_id, l_tmpl_usgs_tbl);

         /* create new territory qual type usages record(s) */
         create_new_terr_qtype_usgs(l_new_terr_id, l_tmpl_qtype_usgs_tbl);

         /* for all qualifier values */
         insert_copied_qual_values(p_copy_source_terr_id, l_new_terr_id);
      --dbms_output('JTF_TERRITORY_PVT:gen_dupliacte_territory: - END');

       /* START: 09/17/00 - JDOCHERT  */
       IF (p_copy_rsc_flag = 'Y') THEN

          JTF_TERRITORY_RESOURCE_PVT.copy_terr_resources( p_Api_Version_Number  => p_Api_Version_Number,
                                                          p_Init_Msg_List       => p_Init_Msg_List,
                                                          p_Commit              => p_Commit,
                                                          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                                          p_source_terr_id      => p_copy_source_terr_id,
                                                          p_dest_terr_id        => l_new_terr_id,
                                                          x_msg_count           => x_msg_count,
                                                          x_msg_data            => x_msg_data,
                                                          x_return_status       => x_return_status );

        END IF;
        /* END: 09/17/00 - JDOCHERT  */

      /* START: 04/05/01 - ARPATEL */
      IF (p_copy_hierarchy_flag = 'Y') THEN


        for terr_rec in csr_child_terrs(p_copy_Source_terr_id)
	    loop

        --p_new_terr_rec.parent_territory_id := l_new_terr_id;

        JTF_TERRITORY_PVT.Copy_Territory (
           p_Api_Version_Number   =>  p_Api_Version_Number,
           p_Init_Msg_List        =>  p_Init_Msg_List,
           p_Commit               =>  p_Commit,
           p_validation_level     =>  p_validation_level,
           p_copy_source_terr_Id  =>  terr_rec.terr_id,
           p_new_terr_rec         =>  p_new_terr_rec,
           p_copy_rsc_flag        =>  p_copy_rsc_flag,
	       p_copy_hierarchy_flag  =>  p_copy_hierarchy_flag,
           p_first_terr_node_flag =>  'N',
           x_Return_Status        =>  l_return_status,
           x_Msg_Count            =>  l_msg_count,
           x_Msg_Data             =>  l_msg_data,
           x_terr_id              =>  l_terr_id );

        update JTF_TERR_ALL
	    set parent_territory_id = l_new_terr_id
	    where terr_id = l_terr_id;

        end loop;

      END IF;

        /* END: 04/05/01 - ARPATEL */

      /* return new territory id */
      x_terr_id := l_new_terr_id;

      /* ===================== */
      /*    API BODY END       */
      /* ======================*/

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
         FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
         FND_MSG_PUB.Add;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
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

     WHEN FND_API.G_EXC_ERROR THEN
         --dbms_output('Generate_Duplicate_Territory PVT: FND_API.G_EXC_ERROR');
         ROLLBACK TO COPY_TERR_PVT;
         x_return_status     := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output('Generate_Duplicate_Territory PVT: FND_API.G_EXC_UNEXPECTED_ERROR');
         ROLLBACK TO COPY_TERR_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

     WHEN OTHERS THEN
         --dbms_output('Generate_Duplicate_Territory PVT: OTHERS - ' || SQLERRM);
         ROLLBACK TO COPY_TERR_PVT;
         X_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

END Copy_Territory;


---------------------------------------------------------------------
--                overlap_exists
---------------------------------------------------------------------
--
--        Check whether overlap exists for a
--        qualifier usage value passed in. Overlap is
--        checked only under a single parent.
---------------------------------------------------------------------
FUNCTION Overlap_Exists(p_Parent_Terr_Id              IN  NUMBER,
                        p_Qual_Usg_Id                 IN  NUMBER,
                        p_terr_value_record           IN  jtf_terr_values%ROWTYPE )
RETURN VARCHAR2
AS
    dummy                  NUMBER        := 0;
    l_found                NUMBER        := 0;
    l_qual_col1_datatype   VARCHAR2(25);
    l_display_type         VARCHAR2(25);
    l_convert_to_id_flag   VARCHAR2(2);
BEGIN
    -- Get the qualifier usage related information
    select jqu.qual_col1_datatype, jqu.display_type, jqu.convert_to_id_flag
      into l_qual_col1_datatype, l_display_type, l_convert_to_id_flag
      from jtf_qual_usgs jqu
     where jqu.qual_usg_id = p_Qual_Usg_Id;

    -- Character
    -- low value char
    IF ( l_display_type = 'CHAR' and
         l_qual_col1_datatype = 'VARCHAR2' and
         ( l_convert_to_id_flag IN ('N', FND_API.G_MISS_CHAR) or
           l_convert_to_id_flag is NULL ) )
    Then
       If  p_terr_value_record.low_value_char is NOT NULL Then
           Select count(*)
             into dummy
             from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
            Where jt.parent_territory_id = p_Parent_Terr_Id
                  and jtq.terr_id = jt.terr_id
                  and jtq.qual_usg_id = p_Qual_Usg_Id
                  and jtv.terr_qual_id = jtq.terr_qual_id
                  and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.low_value_char < jtv.low_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.low_value_char <= jtv.low_value_char )
                       or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.low_value_char <> jtv.low_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.low_value_char = jtv.low_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '=' and jtv.low_value_char
                            between p_terr_value_record.low_value_char and p_terr_value_record.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.low_value_char > jtv.low_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.low_value_char >= jtv.low_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.low_value_char between jtv.low_value_char and jtv.high_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'LIKE' and p_terr_value_record.low_value_char LIKE jtv.low_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.low_value_char not between jtv.low_value_char and jtv.high_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT LIKE' and p_terr_value_record.low_value_char NOT LIKE jtv.low_value_char ) )
                   and rownum < 2;
             If dummy > 0 Then
                l_found := dummy;
             End If;
        End If;

        -- Check the high_value_char
        If  p_terr_value_record.high_value_char is NOT NULL Then
           Select count(*)
             into dummy
             from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
            Where jt.parent_territory_id = p_Parent_Terr_Id
                  and jtq.terr_id = jt.terr_id
                  and jtq.qual_usg_id = p_Qual_Usg_Id
                  and jtv.terr_qual_id = jtq.terr_qual_id
                  and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.high_value_char < jtv.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.high_value_char <= jtv.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.high_value_char <> jtv.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.high_value_char = jtv.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.high_value_char > jtv.high_value_char )
                       or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.high_value_char >= jtv.high_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.high_value_char between jtv.low_value_char and jtv.high_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'LIKE' and p_terr_value_record.high_value_char LIKE jtv.low_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.high_value_char not between jtv.low_value_char and jtv.high_value_char )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT LIKE' and p_terr_value_record.high_value_char NOT LIKE jtv.low_value_char ) )
                   and rownum < 2;
             If dummy > 0 Then
                l_found := dummy;
             End If;
        End If;

    -- Numeric with CHAR display WHERE id is stored, e.g., Company Name
    ElsIf ( l_qual_col1_datatype = 'NUMBER' AND
            l_display_type = 'CHAR' AND
            l_convert_to_id_flag = 'Y' )
    Then

       -- only check for a subset of the availabel operator as these are the only
       -- available one for this combination
       Select count(*)
         into dummy
         from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
        Where jt.parent_territory_id = p_Parent_Terr_Id
              and jtq.terr_id = jt.terr_id
              and jtq.qual_usg_id = p_Qual_Usg_Id
              and jtv.terr_qual_id = jtq.terr_qual_id
              and jtv.LOW_VALUE_CHAR_ID =  p_terr_value_record.LOW_VALUE_CHAR_ID
              and rownum < 2;
       If dummy > 0 Then
          l_found := dummy;
       End If;

    ElsIf ( l_qual_col1_datatype = 'NUMBER' and l_display_type = 'NUMERIC'
            and  ( l_convert_to_id_flag = 'N' or l_convert_to_id_flag is NULL ) )
    Then

        If  p_terr_value_record.low_value_number is NOT NULL Then
            Select 1
              into dummy
             from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
             Where jt.parent_territory_id = p_Parent_Terr_Id
                   and jtq.terr_id = jt.terr_id
                   and jtq.qual_usg_id = p_Qual_Usg_Id
                   and jtv.terr_qual_id = jtq.terr_qual_id
                   and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.LOW_VALUE_number < jtv.low_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.LOW_VALUE_number <= jtv.low_value_number )
                        or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.LOW_VALUE_number <> jtv.low_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.LOW_VALUE_number = jtv.low_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.LOW_VALUE_number > jtv.low_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.LOW_VALUE_number >= jtv.low_value_number )
                        or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.LOW_VALUE_number between jtv.low_value_number and jtv.high_value_number )
                        or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.LOW_VALUE_number not between jtv.low_value_number and jtv.high_value_number ))
                   and rownum < 2;
            If dummy > 0 Then
               l_found := dummy;
            End If;
         End If;

         If  p_terr_value_record.high_value_number is NOT NULL Then
             Select 1
               into dummy
              from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
              Where jt.parent_territory_id = p_Parent_Terr_Id
                    and jtq.terr_id = jt.terr_id
                    and jtq.qual_usg_id = p_Qual_Usg_Id
                    and jtv.terr_qual_id = jtq.terr_qual_id
                    and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.high_value_number < jtv.high_value_number )
                         or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.high_value_number <= jtv.high_value_number )
                         or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.high_value_number <> jtv.high_value_number )
                         or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.high_value_number = jtv.high_value_number )
                         or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.high_value_number > jtv.high_value_number )
                         or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.high_value_number >= jtv.high_value_number )
                         or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.high_value_number between jtv.low_value_number and jtv.high_value_number )
                         or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.high_value_number not between jtv.low_value_number and jtv.high_value_number ))
                    and rownum < 2;
             If dummy > 0 Then
                l_found := dummy;
             End If;
         End If;

    ElsIf ( l_qual_col1_datatype = 'NUMBER' AND
            l_display_type = 'CURRENCY' AND
            ( l_convert_to_id_flag IN ('N', FND_API.G_MISS_CHAR) OR
              l_convert_to_id_flag is NULL ) )
    Then

       If  p_terr_value_record.low_value_number is NOT NULL Then
           Select count(*)
             into dummy
            from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
            Where jt.parent_territory_id = p_Parent_Terr_Id
                  and jtq.terr_id = jt.terr_id
                  and jtq.qual_usg_id = p_Qual_Usg_Id
                  and jtv.terr_qual_id = jtq.terr_qual_id
                  and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.LOW_VALUE_number < jtv.low_value_number )
                       or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.LOW_VALUE_number <= jtv.low_value_number )
                       or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.LOW_VALUE_number <> jtv.low_value_number )
                       or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.LOW_VALUE_number = jtv.low_value_number )
                       or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.LOW_VALUE_number > jtv.low_value_number )
                       or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.LOW_VALUE_number >= jtv.low_value_number )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.LOW_VALUE_number between jtv.low_value_number and jtv.high_value_number )
                       or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.LOW_VALUE_number not between jtv.low_value_number and jtv.high_value_number ))
               and rownum < 2;
               If dummy > 0 Then
                  l_found := dummy;
               End If;
        End If;

        If  p_terr_value_record.high_value_number is NOT NULL Then
            Select count(*)
              into dummy
             from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
             Where jt.parent_territory_id = p_Parent_Terr_Id
                   and jtq.terr_id = jt.terr_id
                   and jtq.qual_usg_id = p_Qual_Usg_Id
                   and jtv.terr_qual_id = jtq.terr_qual_id
                   and (   ( jtv.COMPARISON_OPERATOR = '<'  and p_terr_value_record.HIGH_VALUE_number < jtv.high_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '<=' and p_terr_value_record.HIGH_VALUE_number <= jtv.high_value_number )
                        or ( jtv.COMPARISON_OPERATOR IN ('!=', '<>') and p_terr_value_record.HIGH_VALUE_number <> jtv.high_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '='  and p_terr_value_record.HIGH_VALUE_number = jtv.high_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '>'  and p_terr_value_record.HIGH_VALUE_number > jtv.high_value_number )
                        or ( jtv.COMPARISON_OPERATOR = '>=' and p_terr_value_record.HIGH_VALUE_number >= jtv.high_value_number )
                        or ( UPPER(jtv.COMPARISON_OPERATOR) = 'BETWEEN' and p_terr_value_record.HIGH_VALUE_number between jtv.low_value_number and jtv.high_value_number )
                        or ( UPPER(jtv.COMPARISON_OPERATOR) = 'NOT BETWEEN' and p_terr_value_record.HIGH_VALUE_number not between jtv.low_value_number and jtv.high_value_number ))
                   and rownum < 2;
               If dummy > 0 Then
                  l_found := dummy;
               End If;
        End If;

    ElsIf ( l_qual_col1_datatype = 'NUMBER' AND
            l_display_type = 'INTEREST_TYPE'AND
            ( l_convert_to_id_flag IN ('N', FND_API.G_MISS_CHAR) OR
              l_convert_to_id_flag is NULL ) )
    Then
       Select count(*)
         into dummy
        from jtf_terr_values jtv, jtf_terr_qual jtq, jtf_terr jt
        Where jt.parent_territory_id = p_Parent_Terr_Id
              and jtq.terr_id = jt.terr_id
              and jtq.qual_usg_id = p_Qual_Usg_Id
              and jtv.terr_qual_id = jtq.terr_qual_id
              and ( ( jtv.interest_type_id = p_terr_value_record.interest_type_id )
              and ( jtv.primary_interest_code_id = p_terr_value_record.primary_interest_code_id or
                    ( jtv.primary_interest_code_id IS NULL and p_terr_value_record.primary_interest_code_id is NULL) )
              and ( jtv.secondary_interest_code_id = p_terr_value_record.secondary_interest_code_id or
                    ( jtv.secondary_interest_code_id is NULL  and p_terr_value_record.secondary_interest_code_id is NULL) ) )
              and rownum < 2;
       If dummy > 0 Then
          l_found := dummy;
       End If;
    End If;

    If l_found > 0 Then
       RETURN FND_API.G_TRUE;
    Else
       RETURN FND_API.G_FALSE;
    End If;
EXCEPTION
    WHEN NO_DATA_FOUND Then
         RETURN FND_API.G_FALSE;

    WHEN OTHERS THEN
         RETURN FND_API.G_FALSE;

END Overlap_Exists;

  -- jdochert 09/09
  -- check for Unique Key constraint violation on JTF_TERR_USGS table
  PROCEDURE validate_terr_usgs_UK(
               p_Terr_Id          IN  NUMBER,
               p_Source_Id        IN  NUMBER,
               p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2 )
  AS

     -- cursor to check that Unique Key constraint not violated
     CURSOR csr_chk_uk_violation ( lp_terr_id       NUMBER
                                 , lp_source_id     NUMBER) IS
      SELECT 'X'
      FROM JTF_TERR_USGS_ALL
      WHERE terr_id = lp_terr_id
        AND source_id = lp_source_id;

     l_return_csr  VARCHAR2(1);

  BEGIN

    --dbms_output.put_line('Validate TERR USGS Unique_Key: Entering API ' || p_terr_id || '   ' || p_source_id);
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* check that Unique Key constraint not violated */
    IF ( p_terr_id IS NOT NULL AND p_terr_id <> FND_API.G_MISS_NUM  AND
         p_source_id IS NOT NULL AND p_source_id <> FND_API.G_MISS_NUM ) THEN

         /* check if rec already exists */
         OPEN csr_chk_uk_violation (p_terr_id, p_source_id);
         FETCH csr_chk_uk_violation INTO l_return_csr;

         IF csr_chk_uk_violation%FOUND THEN

            --dbms_output.put_line('Validate_Unique_Key: jtf_terr_usgs: VIOLATION');

            x_return_status := FND_API.G_RET_STS_ERROR;

            /* Debug message */
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_USGS_UK_CON');
               FND_MSG_PUB.ADD;
            END IF;

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

END validate_terr_usgs_UK;

  -- jdochert 09/09
  -- check for Unique Key constraint violation on JTF_TERR_QTYPE_USGS table
  PROCEDURE validate_terr_qtype_usgs_UK(
               p_Terr_Id                 IN  NUMBER,
               p_Qual_Type_Usg_Id        IN  NUMBER,
               p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2 )
  AS

     -- cursor to check that Unique Key constraint not violated
     CURSOR csr_chk_uk_violation ( lp_terr_id              NUMBER
                                 , lp_qual_type_usg_id     NUMBER) IS
      SELECT 'X'
      FROM JTF_TERR_QTYPE_USGS_ALL
      WHERE terr_id = lp_terr_id
        AND qual_type_usg_id = lp_qual_type_usg_id;

     l_return_csr  VARCHAR2(1);

  BEGIN

    --dbms_output.put_line('Validate QUAL_TYPE_USGS Unique_Key: Entering API');
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* check that Unique Key constraint not violated */
    IF ( p_terr_id IS NOT NULL AND p_terr_id <> FND_API.G_MISS_NUM  AND
         p_qual_type_usg_id IS NOT NULL AND p_qual_type_usg_id <> FND_API.G_MISS_NUM ) THEN

         /* check if rec already exists */
         OPEN csr_chk_uk_violation ( p_terr_id
                                   , p_qual_type_usg_id);
         FETCH csr_chk_uk_violation INTO l_return_csr;

         IF csr_chk_uk_violation%FOUND THEN
         --dbms_output.put_line('Validate QUAL_TYPE_USGS Unique_Key Violation');

            x_return_status := FND_API.G_RET_STS_ERROR;

            /* Debug message */
            --arpatel 09/18 - set message for form to pick up.
            --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_QTYPE_USGS_UK_CON');
               FND_MSG_PUB.ADD;

               FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data);

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

END validate_terr_qtype_usgs_UK;


  -- jdochert 10/04
  -- check that Number of Winners is valid for this territory
  PROCEDURE validate_num_winners(
               p_Terr_All_Rec     IN  Terr_All_Rec_Type  := G_Miss_Terr_All_Rec,
               p_init_msg_list    IN  VARCHAR2           := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2,
               x_reason           OUT NOCOPY VARCHAR2 )
  AS

     /* Check Number Of Winners not set ABOVE
     ** this territory in the hierarchy
     ** 09/17/00 JDOCHERT BUG#1408610 FIX
     */
     CURSOR csr_chk_num_winners (lp_terr_id       NUMBER) IS
      SELECT 'X'
      FROM jtf_terr_ALL j
      WHERE j.parent_territory_id = 1
        AND j.terr_id = lp_terr_id;

     l_return_csr  VARCHAR2(1);

  BEGIN

    --dbms_output.put_line('Validate_Num_Winners: Entering API ' || p_terr_id || '   ' || p_source_id);
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    If ( p_terr_all_rec.parent_territory_id <> 1 AND
         p_terr_all_rec.num_winners IS NOT NULL AND
         p_terr_all_rec.num_winners <> FND_API.G_MISS_NUM ) THEN

         IF ( p_terr_all_rec.template_flag = 'Y' OR
              p_terr_all_rec.escalation_territory_flag = 'Y' ) THEN

            x_reason := 'F';

         ELSE

            x_reason := 'A';

         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;

         /* Debug message */
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_NUM_WINNERS_TOP_LEVEL');
            FND_MSG_PUB.ADD;
         END IF;

     END IF;

      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data);

 EXCEPTION

    WHEN OTHERS THEN
         --dbms_output('Validate_Num_Winners: Others exception' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Num_Winners' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

END validate_num_winners;


/* JDOCHERT - 041201 */
PROCEDURE chk_num_copy_terr( p_node_terr_id     IN  NUMBER,
                             p_limit_num        IN  NUMBER := 10,
                             x_Return_Status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2,
                             x_terr_num         OUT NOCOPY NUMBER,
                             x_copy_status      OUT NOCOPY VARCHAR2 )
AS

  CURSOR csr_get_terr_num (lp_terr_id NUMBER) IS
  SELECT COUNT(*)
  FROM jtf_terr_all jt
  CONNECT BY PRIOR jt.terr_id = jt.parent_territory_id
  START WITH jt.terr_id = lp_terr_id;

BEGIN

    --dbms_output.put_line('chk_num_copy_terr: Entering API ' || p_terr_id );
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN csr_get_terr_num(p_node_terr_id);
   FETCH csr_get_terr_num INTO x_terr_num;
   CLOSE csr_get_terr_num;

   IF (x_terr_num <= p_limit_num) THEN

      x_copy_status := FND_API.G_TRUE;

   ELSE
      x_copy_status := FND_API.G_FALSE;

   END IF;


   /* Debug message */
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_NUM_COPY_TERR');
      FND_MSG_PUB.ADD;
   END IF;

   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                              p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
         --dbms_output('chk_num_copy_terr: Others exception' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'chk_num_copy_terr' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

END chk_num_copy_terr;

PROCEDURE Concurrent_Copy_Territory (
                           errbuf                        OUT NOCOPY VARCHAR2,
                           retcode                       OUT NOCOPY VARCHAR2,
                           p_copy_source_terr_Id         IN  NUMBER,
                           p_name                        IN  VARCHAR2,
                           p_description                 IN  VARCHAR2     := FND_API.G_MISS_CHAR,
                           p_rank                        IN  NUMBER       := FND_API.G_MISS_NUM,
                           p_start_date                  IN  DATE,
                           p_end_date                    IN  DATE         := FND_API.G_MISS_DATE,
                           p_copy_rsc_flag               IN  VARCHAR2     := 'N',
                           p_copy_hierarchy_flag         IN  VARCHAR2     := 'N',
                           p_first_terr_node_flag        IN  VARCHAR2     := 'N',
                           p_debug_flag                  IN  VARCHAR2     := 'N',
                           p_sql_trace                   IN  VARCHAR2     := 'N'   ) AS

    /* local record variables */
    l_terr_rec     	   JTF_TERRITORY_PVT.TERR_ALL_REC_TYPE;

    /* local item variables */
    l_terr_id		   NUMBER;
    l_hier_terr_count  NUMBER;

    /* local standard API variables */
      l_api_name              CONSTANT VARCHAR2(30) := 'Concurrent_Copy_Territory';
      l_api_version_number    CONSTANT NUMBER       := 1.0;
      l_return_status         VARCHAR2(200);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(2000);

    BEGIN

      --dbms_output.put_line('ENTERING Concurrent_Copy_Territory');
    -- Standard Start of API savepoint
      SAVEPOINT CONC_COPY_TERR_PVT;

      /* If the SQL trace flag is turned on, then turn on the trace */
      /* ARPATEL: 12/15/2003: Bug#3305019 fix */
      --If lower(p_SQL_Trace) = 'Y' Then
      --   dbms_session.set_sql_trace(TRUE);
      --Else
      --   dbms_session.set_sql_trace(FALSE);
      --End If;

      /* If the debug flag is set, Then turn on the debug message logging */
      If upper( rtrim(p_Debug_Flag) ) = 'Y' Then
         G_Debug := TRUE;
      End If;

      If G_Debug Then
         Write_Log(2, 'Concurrent Copy Territory Start');
         Write_Log(2, 'Source Territory ID is - ' || TO_CHAR(p_copy_source_terr_Id) );
         Write_Log(2, 'Source Territory Name is - ' || p_name );
      End If;


      /* ===================== */
      /*    API BODY START     */
      /* ======================*/

     l_terr_rec.NAME := p_name;
     l_terr_rec.DESCRIPTION := p_description;
     l_terr_rec.RANK := p_rank;
     l_terr_rec.START_DATE_ACTIVE := p_start_date;
     l_terr_rec.END_DATE_ACTIVE := p_end_date;

     l_terr_rec.ENABLED_FLAG := 'Y';
     l_terr_rec.TERR_ID			            := FND_API.G_MISS_NUM;
     l_terr_rec.LAST_UPDATE_DATE  	        := FND_API.G_MISS_DATE;
     l_terr_rec.LAST_UPDATED_BY             := FND_API.G_MISS_NUM;
     l_terr_rec.CREATION_DATE               := FND_API.G_MISS_DATE;
     l_terr_rec.CREATED_BY                  := FND_API.G_MISS_NUM;
     l_terr_rec.LAST_UPDATE_LOGIN           := FND_API.G_MISS_NUM;
     l_terr_rec.APPLICATION_SHORT_NAME      := FND_API.G_MISS_CHAR;
     l_terr_rec.REQUEST_ID                  := FND_API.G_MISS_NUM;
     l_terr_rec.PROGRAM_APPLICATION_ID      := FND_API.G_MISS_NUM;
     l_terr_rec.PROGRAM_ID                  := FND_API.G_MISS_NUM;
     l_terr_rec.PROGRAM_UPDATE_DATE         := FND_API.G_MISS_DATE;
     l_terr_rec.ORG_ID                      := FND_API.G_MISS_NUM;
     l_terr_rec.UPDATE_FLAG                 := FND_API.G_MISS_CHAR;
     l_terr_rec.AUTO_ASSIGN_RESOURCES_FLAG  := FND_API.G_MISS_CHAR;
     l_terr_rec.PLANNED_FLAG                := FND_API.G_MISS_CHAR;
     l_terr_rec.TERRITORY_TYPE_ID           := FND_API.G_MISS_NUM;
     l_terr_rec.PARENT_TERRITORY_ID         := FND_API.G_MISS_NUM;
     l_terr_rec.TEMPLATE_FLAG               := FND_API.G_MISS_CHAR;
     l_terr_rec.TEMPLATE_TERRITORY_ID       := FND_API.G_MISS_NUM;
     l_terr_rec.ESCALATION_TERRITORY_FLAG   := FND_API.G_MISS_CHAR;
     l_terr_rec.ESCALATION_TERRITORY_ID     := FND_API.G_MISS_NUM;
     l_terr_rec.OVERLAP_ALLOWED_FLAG        := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE_CATEGORY          := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE1                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE2                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE3                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE4                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE5                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE6                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE7                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE8                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE9                  := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE10                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE11                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE12                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE13                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE14                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ATTRIBUTE15                 := FND_API.G_MISS_CHAR;
     l_terr_rec.ORG_ID                      := FND_API.G_MISS_NUM;
     l_terr_rec.NUM_WINNERS                 := FND_API.G_MISS_NUM;

    JTF_TERRITORY_PVT.Copy_Territory (
           p_Api_Version_Number   =>  l_Api_Version_Number,
           p_Init_Msg_List        =>  FND_API.G_TRUE,
           p_Commit               =>  FND_API.G_TRUE,
           p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
           p_copy_source_terr_Id  =>  p_copy_source_terr_Id,
           p_new_terr_rec         =>  l_terr_rec,
           p_copy_rsc_flag        =>  p_copy_rsc_flag,
	       p_copy_hierarchy_flag  =>  p_copy_hierarchy_flag,
           p_first_terr_node_flag =>  p_first_terr_node_flag,
           x_Return_Status        =>  l_return_status,
           x_Msg_Count            =>  l_msg_count,
           x_Msg_Data             =>  l_msg_data,
           x_terr_id              =>  l_terr_id );

      --dbms_output.put_line('***l_return_status ' ||l_return_status);

    IF  (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        IF (G_Debug) THEN
             Write_Log(2, 'Copy Territories hierarchy has NOT completed successfully');
             errbuf := 'Program completed with errors';
             retcode := 1;
        END IF;

    ELSE

        IF (G_Debug) THEN
             Write_Log(2, 'Copy Territories hierarchy has completed successfully');
             errbuf := 'Program completed successfully';
             retcode := 0;
        END IF;

    END IF;

    IF (G_Debug) THEN

            SELECT COUNT(*)
            INTO l_hier_terr_count
            FROM jtf_terr_all jt
            CONNECT BY PRIOR jt.terr_id = jt.parent_territory_id
            START WITH jt.terr_id = p_copy_source_terr_Id;

            Write_Log(2, ' ');
            Write_Log(2, '/***************** BEGIN: COPY TERRITORY STATUS *********************/');
            Write_Log(2, 'Populating JTF_TERR_ALL table. Copied ' || l_hier_terr_count || ' territories.');
            Write_Log(2, 'Inserted ' || l_hier_terr_count || ' rows into JTF_TERR_ALL ');
            Write_Log(2, '/***************** END: COPY TERRITORY STATUS *********************/');

    END IF;

      /* ===================== */
      /*    API BODY END       */
      /* ======================*/

      Write_Log(2,ERRBUF);

  EXCEPTION

     WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error Then
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           If G_Debug Then
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           End If;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;

  END Concurrent_Copy_Territory;

  --------------------------------------------------------------------
   --                  Logging PROCEDURE
   --
   --     which = 1. write to log
   --     which = 2, write to output
   --------------------------------------------------------------------
   --
   PROCEDURE Write_Log(which number, mssg  varchar2 )
   IS
   BEGIN
   --
       --dbms_output.put_line(' LOG: ' || mssg );
       FND_FILE.put(which, mssg);
       FND_FILE.NEW_LINE(which, 1);
       --
       -- If the output message and if debug flag is set then also write
       -- to the log file
       --
       If Which = 2 Then
          If G_Debug Then
             FND_FILE.put(1, mssg);
             FND_FILE.NEW_LINE(1, 1);
          End If;
       End IF;
   --
   END Write_Log;

 FUNCTION conc_req_copy_terr (
                           p_copy_source_terr_Id         IN  NUMBER,
                           p_name                        IN  VARCHAR2,
                           p_description                 IN  VARCHAR2     := FND_API.G_MISS_CHAR,
                           p_rank                        IN  NUMBER       := FND_API.G_MISS_NUM,
                           p_start_date                  IN  DATE,
                           p_end_date                    IN  DATE         := FND_API.G_MISS_DATE,
                           p_copy_rsc_flag               IN  VARCHAR2     := 'N',
                           p_copy_hierarchy_flag         IN  VARCHAR2     := 'N',
                           p_first_terr_node_flag        IN  VARCHAR2     := 'N'
                            )
 RETURN NUMBER
   AS
   l_process_id NUMBER;
   BEGIN

   l_process_id := FND_REQUEST.submit_request (
			  application    => 'JTF' ,
			  program        => 'COPY_TERR_HIERARCHY_NODE' ,
			  argument1      => p_copy_source_terr_Id ,
			  argument2   	 => p_name ,
  			  argument3   	 => p_description ,
			  argument4   	 => p_rank ,
			  argument5   	 => p_start_date ,
			  argument6   	 => p_end_date ,
			  argument7   	 => p_copy_rsc_flag ,
			  argument8   	 => p_copy_hierarchy_flag ,
			  argument9      => p_first_terr_node_flag ,
			  argument10	 => 'Y' ,
			  argument11	 => 'Y'
                       );

    /* Debug message */

      FND_MESSAGE.Set_Name ('JTF', 'JTF_CONC_REQ_COPY_TERR');
      FND_MESSAGE.Set_Token ('Template Territory ID', p_copy_source_terr_Id);
      FND_MESSAGE.Set_Token('Concurrent request ID',l_process_id);
      FND_MSG_PUB.add;

      RETURN l_process_id;
   END conc_req_copy_terr;



  -- jdochert 06/06/01
  -- check that parent territory is not already a child of this territory
  -- circular reference check
  PROCEDURE validate_parent(
               p_Terr_All_Rec     IN  Terr_All_Rec_Type  := G_Miss_Terr_All_Rec,
               p_init_msg_list    IN  VARCHAR2           := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2 )
  AS

     e_Circular_Reference    EXCEPTION;
     PRAGMA                  EXCEPTION_INIT(e_Circular_Reference, -01436);

     l_return_csr               NUMBER;
     l_existing_parent_terr_id  NUMBER;

  BEGIN

    --dbms_output.put_line('[1]Validate_Parent: Entering API ');
    -- Initialize the status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --dbms_output.put_line('[2]Validate_Parent: Entering API ');

    BEGIN

       SELECT j.parent_territory_id
       INTO l_existing_parent_terr_id
       FROM jtf_terr_all j
       WHERE j.terr_id = p_terr_all_rec.terr_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           NULL;
    END;

    IF ( p_terr_all_rec.parent_territory_id <> l_existing_parent_terr_id) THEN

       /* Top down checking if new parent
       ** territory is already a child
       ** of the current territory
       */
       SELECT COUNT(*)
       INTO l_return_csr
       FROM jtf_terr_all j
       WHERE j.terr_id = p_terr_all_rec.parent_territory_id -- new parent territory id
       CONNECT BY PRIOR j.terr_id = j.parent_territory_id
       START WITH j.terr_id = p_terr_all_rec.terr_id; -- territory_id

       IF (l_return_csr <> 0 )THEN
          RAISE e_Circular_Reference;
       END IF;

   END IF;

    --dbms_output.put_line('[3]l_return_csr =  ' || l_return_csr);

    /* Debug message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_CIRCULAR_REFERENCE');
        FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

 EXCEPTION

     WHEN e_Circular_Reference THEN
         --dbms_output.put_line('Validate_Parent: e_Circular_Reference exception' || SQLERRM);

         X_return_status   := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_CIRCULAR_REFERENCE');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Parent' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --dbms_output.put_line('Validate_Parent: FND_API.G_EXC_UNEXPECTED_ERROR');
         X_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Parent' );
         FND_MSG_PUB.Count_And_Get
         (  P_count          =>   x_msg_count,
            P_data           =>   x_msg_data
         );

    WHEN OTHERS THEN
         --dbms_output.put_line('Validate_Parent: Others exception' || SQLERRM);
         X_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_UNEXPECTED_ERROR');
         FND_MESSAGE.Set_Token('PROC_NAME', 'Validate_Parent' );
         FND_MESSAGE.Set_Token('ERROR', sqlerrm );
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
         );
END validate_parent;


/* Function used in JTF_TERR_VALUES_DESC_V to return
** descriptive values for ids and lookup_codes
*/
FUNCTION get_terr_value_desc (
                           p_convert_to_id_flag  VARCHAR2
                         , p_display_type        VARCHAR2
                         , p_column_count        NUMBER   := FND_API.G_MISS_NUM
                         , p_display_sql         VARCHAR2 := FND_API.G_MISS_CHAR
                         , p_terr_value1         VARCHAR2
                         , p_terr_value2         VARCHAR2 :=  FND_API.G_MISS_CHAR
                         )
RETURN VARCHAR2 IS

    query_str       VARCHAR2(1000);
    value_desc      VARCHAR2(1000);
    l_terr_value1    VARCHAR2(360);
    l_terr_value2    VARCHAR2(360);

BEGIN

    IF ( p_display_sql = FND_API.G_MISS_CHAR OR
         p_display_sql IS NULL) THEN

      --dbms_output( 'LOV_SQL IS NULL, returning value = ' || p_terr_value);

      RETURN p_terr_value1;

    ELSE  /* build dynamic SQl */

      query_str := p_display_sql;

      l_terr_value1 := p_terr_value1;
      l_terr_value2 := p_terr_value2;

      IF (p_display_type IN ('CHAR_2IDS', 'DEP_2FIELDS_CHAR_2IDS', 'DEP_3FIELDS_CHAR_3IDS')) THEN

         query_str := p_display_sql;

      /* check if value is NUMBER or VARCHAR2 */
      ELSIF ( ( p_display_type = 'CHAR' AND
             p_convert_to_id_flag = 'Y' ) OR
           p_display_type = 'NUMERIC' OR
           p_display_type = 'INTEREST_TYPE' OR
           p_display_type = 'COMPETENCE' ) THEN

          query_str := query_str || ' TO_NUMBER(:terr_value)' ;

      ELSE
        --dbms_output( 'convert_to_id_flag = N');

        query_str := query_str || ' :terr_value1' ;

      END IF;

      query_str := query_str || ' AND rownum < 2' ;

      --dbms_output('query_str = ' || query_str);

      IF (p_display_type IN ('CHAR_2IDS', 'DEP_2FIELDS_CHAR_2IDS', 'DEP_3FIELDS_CHAR_3IDS')) THEN

          /* execute dynamic SQl */
          EXECUTE IMMEDIATE query_str
            INTO value_desc
            USING l_terr_value1, l_terr_value2;

      ELSE

          /* execute dynamic SQl */
          EXECUTE IMMEDIATE query_str
            INTO value_desc
            USING l_terr_value1;

      END IF;

      --dbms_output( 'returning value = ' || p_terr_value);

      RETURN value_desc;

    END IF;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN NULL;

END get_terr_value_desc;


   -- Package Body
END JTF_TERRITORY_PVT;


/
