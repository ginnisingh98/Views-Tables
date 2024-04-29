--------------------------------------------------------
--  DDL for Package Body AMS_DMSOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMSOURCE_PVT" as
/* $Header: amsvdsrb.pls 120.0 2005/05/31 14:45:59 appldev noship $ */
-- Start of Comments
-- Package name     : AMS_DMSource_PVT
-- Purpose          :
-- History          :
-- 25-Jan-2001 choang   Removed req validation of model_type.
-- 26-Jan-2001 choang   Added increment of object ver num in update api.
-- 29-Jan-2001 choang   Removed return statement from item validation.
-- 30-jan-2001 choang   Changed p_tree_node to p_rule_id.
-- 28-Feb-2001 choang   Removed model_type from validation.
-- 10-Jul-2001 choang   Added bin_probability.
-- 12-Jul-2001 choang   Added process_scores.
-- 26-Jul-2001 choang   Added generate_odm_input_views, randomize_build_data
-- 16-Aug-2001 choang   Added columns to view definitions.
-- 31-Aug-2001 choang   Changed interest_others_flag to interest_other_flag.
-- 18-Oct-2001 choang   Fixed training_data_flag updation logic.
-- 26-Nov-2001 choang   Changed process_scores logic to use local staging table
--                      for performance.
-- 07-Jan-2002 choang   Removed security group id
-- 09-May-2002 choang   Changed training/test data to 70/30 ratio
-- 17-May-2002 choang   bug 2380113: g_user_id and g_login_id removed
-- 07-Jun-2002 choang   Added support for data mining data sources.
-- 15-May-2003 rosharma Bug # 2961532.
-- 24-June-2003 kbasavar For Balanced Data Set enhancement.
-- 28-Jul-2003 nyostos  Added PERCENTILE column and code in bin_probability to calculate the
--                      score percentile.
-- 15-Sep-2003 nyostos  Changes related to parallel mining processes using Global Temp Tables.
-- 20-Sep-2003 rosharma Changes related to Audience data source uptake.
-- 22-Sep-2003 nyostos  Fixed error handling in generate_odm_input_views.
-- 08-Oct-2003 nyostos  Changed logic to CREATE or REPLACE synonyms for ODM views in case
--                      synonyms are not dropped because of errors in build/apply.
-- 31-Oct-2003 kbasavar Changed get_from_where_clause to handle CUSTOMER PROFITABILITY MODEL
-- 31-Oct-2003 rosharma Changed get_select_fields to filter out attributes which are not NUMBER or VARCHAR2
-- 18-Nov-2003 rosharma obsoleted profile AMS_ODM_OUTPUT_SCHEMA, use ODM schema always
-- 30-Dec-2003 kbasavar grant select privilage and create synonym only if single instance setup.
--                                 Basically check if profile AMS_DM_USE_DBLINK is N or null
-- 23-Jan-2004 rosharma Bug # 3390720
-- 12-Feb-2004 rosharma Fixed bug # 3436093
-- 24-Feb-2004 rosharma Fixed bug # 3461297
-- 24-Feb-2004 kbasavar Fixed bug # 3466690
-- 08-Nov-2004 spendem  Fixed bug # 4027150 (Exclude source_id and target_value from selected fields)
--                      (Added table alias before the column name training_data_flag in create_build_views procedure )

-- 17-Dec-2004 kbasavar Perf Bug 4074433 Modified get_from_where_clause to return two where clause strings
--                      one for creating view and the other for querying.String for selections with bind variables.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DMSource_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdsrb.pls';

/***
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
***/


--
-- PURPOSE
--    Randomly set the build data flag to indicate that
--    an individual row in model data selection is to be
--    used for either training or testing.
--
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


-- ODM External Schema Lookup Code
G_ODM_SCHEMA_LOOKUP VARCHAR2(30) := 'ODMSCHEMA';

-- Default ODM Schema name
G_ODM_SCHEMA_NAME VARCHAR2(30) := 'ODM';


PROCEDURE randomize_build_data (
   p_object_type  IN VARCHAR2,
   p_object_id    IN NUMBER
);


--
-- PURPOSE
--    obseleted
PROCEDURE get_select_list (
   p_target_type     IN VARCHAR2,
   x_select_list     OUT NOCOPY VARCHAR2
);


PROCEDURE create_build_views (
   p_object_id    IN NUMBER,
   p_select_list  IN VARCHAR2,
   p_from_clause  IN VARCHAR2,
   p_where_clause IN VARCHAR2
);


PROCEDURE create_apply_views (
   p_object_id    IN NUMBER,
   p_select_list  IN VARCHAR2,
   p_from_clause  IN VARCHAR2,
   p_where_clause IN VARCHAR2
);


---------------------------------------------------------------
-- Purpose:
--    Retrieve the selected fields for model building.
--
-- Parameter:
--    p_data_source_id
--    x_select_fields
--    x_return_status
---------------------------------------------------------------
PROCEDURE get_select_fields (
   p_data_source_id  IN NUMBER,
   p_target_id       IN NUMBER,
   p_is_b2bcustprof      IN BOOLEAN,
   x_select_fields   OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------
-- Purpose:
--    Retrieve the from and where clauses for the dynamic
--    creation of the input views for ODM.
--
-- Parameter:
--    p_object_type
--    p_object_id
--    p_data_source_id
--    x_from_clause
--    x_where_clause
--    x_return_status
---------------------------------------------------------------
PROCEDURE get_from_where_clause (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   p_data_source_id  IN NUMBER,
   x_from_clause     OUT NOCOPY VARCHAR2,
   x_where_clause_sel    OUT NOCOPY VARCHAR2,
   x_where_clause    OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Source(
    p_api_version    IN   NUMBER,
    P_Init_Msg_List  IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status  OUT NOCOPY  VARCHAR2,
    X_Msg_Count      OUT NOCOPY  NUMBER,
    X_Msg_Data       OUT NOCOPY  VARCHAR2,

    p_SOURCE_ID      IN  NUMBER,
    p_object_version IN  NUMBER
)

 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Source';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(61) := g_pkg_name ||'.'|| l_api_name;
   l_SOURCE_ID                  NUMBER;

CURSOR c_Source IS
   SELECT SOURCE_ID
   FROM ams_dm_source
   WHERE SOURCE_ID = p_SOURCE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Source;

  FETCH c_Source INTO l_SOURCE_ID;

  IF (c_Source%NOTFOUND) THEN
    CLOSE c_Source;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Source;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_source_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Source;



-- Hint: Primary key needs to be returned.
PROCEDURE Create_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,

    P_source_rec        IN Source_Rec_Type  := G_MISS_source_rec,
    X_SOURCE_ID         OUT NOCOPY  NUMBER
)

 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Source';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_SOURCE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_dm_source_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM ams_dm_source
                    WHERE SOURCE_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_source_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version,
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_source_rec.SOURCE_ID IS NULL OR p_source_rec.SOURCE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_SOURCE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_SOURCE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
      l_source_id := p_source_rec.source_id;
   END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Source');
          END IF;

          -- Invoke validation procedures
          Validate_Source(
            p_api_version => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_create,
            P_source_rec         => P_source_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(ams_dm_source_PKG.Insert_Row)
      BEGIN
         ams_dm_source_PKG.Insert_Row(
             px_SOURCE_ID           => l_SOURCE_ID,
             p_LAST_UPDATE_DATE     => SYSDATE,
             p_LAST_UPDATED_BY      => FND_GLOBAL.user_id,
             p_CREATION_DATE        => SYSDATE,
             p_CREATED_BY           => FND_GLOBAL.user_id,
             p_LAST_UPDATE_LOGIN    => FND_GLOBAL.CONC_LOGIN_ID,
             px_OBJECT_VERSION_NUMBER  => l_object_version_number,
             p_MODEL_TYPE           => p_source_rec.model_type,
             p_ARC_USED_FOR_OBJECT  => p_source_rec.arc_used_for_object,
             p_USED_FOR_OBJECT_ID   => p_source_rec.used_for_object_id,
             p_PARTY_ID             => p_source_rec.party_id,
             p_SCORE_RESULT         => p_source_rec.score_result,
             p_TARGET_VALUE         => p_source_rec.target_value,
             p_CONFIDENCE           => p_source_rec.confidence,
             p_CONTINUOUS_SCORE     => p_source_rec.continuous_score,
             p_decile               => p_source_rec.decile,
             p_percentile           => p_source_rec.percentile);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            AMS_Utility_PVT.error_message ('AMS_API_NO_INSERT');
            RAISE FND_API.g_exc_error;
      END;
--
-- End of API body
--
      x_source_id := l_source_id;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Source;


PROCEDURE Update_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,

    P_source_rec        IN    Source_Rec_Type,
    X_Object_Version_Number   OUT NOCOPY  NUMBER
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Source';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   CURSOR c_reference (p_source_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_source
      WHERE  source_id = p_source_id;

   -- Local Variables
   l_object_version_number     NUMBER;
   l_SOURCE_ID       NUMBER;
   l_reference_rec   c_reference%ROWTYPE;
   l_tar_source_rec  AMS_DMSource_PVT.Source_Rec_Type := P_source_rec;
   l_rowid  ROWID;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_source_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version,
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_reference (l_tar_source_rec.source_id);
      FETCH c_reference INTO l_reference_rec;
      IF ( c_reference%NOTFOUND) THEN
         CLOSE c_reference;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'dm_source', FALSE);
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;
      CLOSE c_reference;

      -- Check Whether record has been changed by someone else
      IF (l_tar_source_rec.object_version_number <> l_reference_rec.object_version_number) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
            FND_MESSAGE.Set_Token('INFO', 'dm_source', FALSE);
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Source');
          END IF;

          -- Invoke validation procedures
          Validate_Source(
            p_api_version     => 1.0,
            p_init_msg_list   => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            P_source_rec      =>  P_source_rec,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data);
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      -- Debug Message
      IF (AMS_DEBUG_LOW_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler', FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      END IF;

      -- Invoke table handler(ams_dm_source_PKG.Update_Row)
      ams_dm_source_PKG.Update_Row(
         p_source_id             => p_source_rec.source_id,
         p_last_update_date      => SYSDATE,
         p_last_updated_by       => FND_GLOBAL.user_id,
         p_last_update_login     => FND_GLOBAL.CONC_LOGIN_ID,
         p_object_version_number => p_source_rec.object_version_number + 1,
         p_model_type            => p_source_rec.model_type,
         p_arc_used_for_object   => p_source_rec.arc_used_for_object,
         p_used_for_object_id    => p_source_rec.used_for_object_id,
         p_party_id              => p_source_rec.party_id,
         p_score_result          => p_source_rec.score_result,
         p_target_value          => p_source_rec.target_value,
         p_confidence            => p_source_rec.confidence,
         p_continuous_score      => p_source_rec.continuous_score,
         p_decile                => p_source_rec.decile,
         p_percentile            => p_source_rec.percentile);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Source;


PROCEDURE Delete_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,
    P_SOURCE_ID         IN  NUMBER,
    P_Object_Version_Number   IN   NUMBER
)
IS
   CURSOR c_obj_version(c_id NUMBER) IS
      SELECT object_version_number
      FROM ams_dm_source
      WHERE source_id = c_id;

   l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Source';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_source_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version,
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      END IF;

      OPEN c_obj_version(p_source_id);
      FETCH c_obj_version INTO l_object_version_number;
      IF ( c_obj_version%NOTFOUND) THEN
         AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
         RAISE FND_API.g_exc_error;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;
      CLOSE c_obj_version;

      --
      -- Api body
      --
      -- Debug Message
      IF P_Object_Version_Number = l_object_version_number THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
         END IF;

      -- Invoke table handler(AMS_DM_MODEL_SCORES_B_PKG.Delete_Row)
      BEGIN
         ams_dm_source_pkg.Delete_Row(
             p_source_id  => p_source_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
      END;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
            FND_MESSAGE.Set_Token('INFO', 'dm_source', FALSE);
            FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_source_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_source_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Source;


PROCEDURE check_source_uk_items(
    p_source_rec        IN   Source_Rec_Type,
    p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status     OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_source_uk_items');
   END IF;
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_dm_source',
         'SOURCE_ID = ''' || p_source_rec.SOURCE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_dm_source',
         'SOURCE_ID = ''' || p_source_rec.SOURCE_ID ||
         ''' AND SOURCE_ID <> ' || p_source_rec.SOURCE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_ID_DUPLICATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_source_uk_items;

PROCEDURE check_source_req_items(
    p_source_rec        IN  Source_Rec_Type,
    p_validation_mode   IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_source_req_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_source_rec.ARC_USED_FOR_OBJECT = FND_API.g_miss_char OR p_source_rec.ARC_USED_FOR_OBJECT IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SRC_NO_ARC_USED_FOR_OBJ');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_source_rec.USED_FOR_OBJECT_ID = FND_API.g_miss_num OR p_source_rec.USED_FOR_OBJECT_ID IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SRC_NO_USED_FOR_OBJ_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_source_rec.PARTY_ID = FND_API.g_miss_num OR p_source_rec.PARTY_ID IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_NO_PARTY_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE  -- update mode
      IF p_source_rec.SOURCE_ID IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_NO_SOURCE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_source_rec.ARC_USED_FOR_OBJECT IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SRC_NO_ARC_USED_FOR_OBJ');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_source_rec.USED_FOR_OBJECT_ID IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SRC_NO_USED_FOR_OBJ_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_source_rec.PARTY_ID IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_NO_PARTY_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_source_req_items;

PROCEDURE check_source_FK_items(
    p_source_rec IN Source_Rec_Type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_source_fk_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   --------------------used_for_object_id---------------------------
   IF p_source_rec.arc_used_for_object = 'MODL' THEN
      IF p_source_rec.used_for_object_id <> FND_API.g_miss_num THEN
         IF AMS_Utility_PVT.check_fk_exists(
               'ams_dm_models_all_b',
               'model_id',
               p_source_rec.used_for_object_id
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_BAD_MODEL_ID');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;
   ELSIF p_source_rec.arc_used_for_object = 'SCOR' THEN
      IF p_source_rec.used_for_object_id <> FND_API.g_miss_num THEN
         IF AMS_Utility_PVT.check_fk_exists(
               'ams_dm_scores_all_b',
               'score_id',
               p_source_rec.used_for_object_id
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_DM_SOURCE_BAD_SCORE_ID');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;
   END IF;

END check_source_FK_items;

PROCEDURE check_source_Lookup_items(
    p_source_rec IN Source_Rec_Type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END check_source_Lookup_items;

PROCEDURE Check_source_Items (
    P_source_rec     IN    Source_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   check_source_uk_items(
      p_source_rec => p_source_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

   -- Check Items Required/NOT NULL API calls
   check_source_req_items(
      p_source_rec => p_source_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

   -- Check Items Foreign Keys API calls
   check_source_FK_items(
      p_source_rec => p_source_rec,
      x_return_status => x_return_status);

   -- Check Items Lookups
   check_source_Lookup_items(
      p_source_rec => p_source_rec,
      x_return_status => x_return_status);

END Check_source_Items;


PROCEDURE Complete_source_rec (
    P_source_rec     IN    Source_Rec_Type,
     x_complete_rec        OUT NOCOPY    Source_Rec_Type
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Complete_source_rec;

PROCEDURE Validate_Source(
    p_api_version         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_source_rec              IN   Source_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Source';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_source_rec  AMS_DMSource_PVT.Source_Rec_Type;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version,
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
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_source_Items(
                 p_source_rec        => p_source_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_source_rec(
         p_source_rec        => p_source_rec,
         x_complete_rec        => l_source_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
         Validate_source_rec(
           p_api_version     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           P_source_rec           =>    l_source_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Source;


PROCEDURE Validate_source_rec(
    p_api_version         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_source_rec               IN    Source_Rec_Type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_source_rec;


PROCEDURE bin_probability (
   p_api_version           IN NUMBER,
   p_init_msg_list         IN VARCHAR2,
   p_commit                IN VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_score_id              IN NUMBER
)
IS
   L_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'bin_probability';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT bin_probability;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   UPDATE ams_dm_source
   SET decile = (10 - FLOOR (LEAST (99, continuous_score)/10))
   WHERE arc_used_for_object = 'SCOR'
   AND   used_for_object_id = p_score_id
   AND   continuous_score IS NOT NULL;

   UPDATE ams_dm_source
   SET percentile = (100 - FLOOR (LEAST (99, continuous_score)))
   WHERE arc_used_for_object = 'SCOR'
   AND   used_for_object_id = p_score_id
   AND   continuous_score IS NOT NULL;

   -- Standard check for p_commit
   IF FND_API.to_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO bin_probability;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
END bin_probability;


--
-- ASSUMPTIONS
--    - data mining engine output table: ODM_OMO_APPLY_RESULT
--    - output table columns: idkey, score, probability
--    - if AMS_ODM_DBLINK profile is set, the database
--      link must exist.
--
PROCEDURE process_scores (
   p_api_version           IN NUMBER,
   p_init_msg_list         IN VARCHAR2,
   p_commit                IN VARCHAR2,
   p_score_id              IN NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'process_scores';

   l_source_object         VARCHAR2(100) := 'ODM_OMO_APPLY_RESULT';

   l_dblink                VARCHAR2(30);
   l_odm_schema            VARCHAR2(30);
   l_sql                   VARCHAR2(32000);

   l_target_positive_value VARCHAR2(30);

   l_return_status         varchar2(1);
   l_db_instance           VARCHAR2(9);

   CURSOR c_db_instance_name IS
      SELECT name
      FROM   V$DATABASE;

   CURSOR c_target_positive_value (p_score_id IN NUMBER) IS
      SELECT m.target_positive_value
      FROM   ams_dm_scores_all_b s, ams_dm_models_all_b m
      WHERE  s.model_id = m.model_id
      AND    s.score_id = p_score_id;
BEGIN


   -- Get the name of the database instance. The scoring run results table
   -- that is created by ODM contains the DB instance name and scoring run id.
   OPEN  c_db_instance_name ();
   FETCH c_db_instance_name INTO l_db_instance;
   CLOSE c_db_instance_name;

   l_source_object := 'OMO_' || l_db_instance || '_' || p_score_id || '_SRT';

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - l_source_object: ' || l_source_object);
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT process_scores;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- if the data mining database is remote
   -- from the CRM database, then we need to
   -- access the results through a database
   -- link.
   --
   -- note: if the profile is null or -1, then
   -- the data mining database is local to the
   -- CRM database.
   l_dblink := FND_PROFILE.value ('AMS_ODM_DBLINK');
   IF l_dblink IS NOT NULL OR l_dblink <> '-1' THEN
      l_source_object := l_source_object || '@' || l_dblink;
   END IF;

   -- changed rosharma 18-nov-2003
   --l_odm_schema := FND_PROFILE.value ('AMS_ODM_OUTPUT_SCHEMA');
   l_odm_schema := FND_ORACLE_SCHEMA.GetOuValue('ODMSCHEMA');
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - ODM output schema: ' || l_odm_schema);
   END IF;
   -- end change rosharma 18-nov-2003
   IF l_odm_schema IS NOT NULL THEN
      l_source_object := l_odm_schema || '.' || l_source_object;
   END IF;

   -- stage all data into local table for processing
-- nyostos - Sep 15, 2003 - Use Global Temporary Table
-- l_sql := 'INSERT INTO ams_dm_apply_stg (SELECT idkey, score, probability FROM ' || l_source_object || ')';
   l_sql := 'INSERT INTO ams_dm_apply_stg_gt (SELECT idkey, score, probability FROM ' || l_source_object || ')';

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - SQL: ' || l_sql);
   END IF;

   -- execute dynamic sql
   EXECUTE IMMEDIATE l_sql;

   --
   -- choang - 03-jul-2002 - without the commit, the application
   -- throws a ora-00164 exception which workflow has trouble
   -- handling
   COMMIT;

   -- due to the potential requirement
   -- of the database link, we need to
   -- construct the sql statement and
   -- execute dynamically.
   OPEN c_target_positive_value (p_score_id);
   FETCH c_target_positive_value INTO l_target_positive_value;
   CLOSE c_target_positive_value;

   UPDATE ams_dm_source s
   SET (score_result, confidence, continuous_score) = (SELECT score, probability * 100, DECODE (score, l_target_positive_value, probability, 1 - probability) * 100
--                                                       FROM ams_dm_apply_stg stg
                                                       FROM ams_dm_apply_stg_gt stg
                                                       WHERE stg.source_id = s.source_id)
--   WHERE s.source_id IN (SELECT source_id from ams_dm_apply_stg);
   WHERE s.source_id IN (SELECT source_id from ams_dm_apply_stg_gt);

--   DELETE FROM ams_dm_apply_stg;
   DELETE FROM ams_dm_apply_stg_gt;

   -- Standard check for p_commit
   IF FND_API.to_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO process_scores;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
END process_scores;

-- cleanup_odm_input_views
--
-- 15-Sep-2003 nyostos  Created.
-- Added to remove ODM input views as patr of allowing parallel mining processes.
--
PROCEDURE cleanup_odm_input_views (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'cleanup_odm_input_views';
   l_training_view      VARCHAR2(30);
   l_test_view          VARCHAR2(30);
   l_apply_view         VARCHAR2(30);
   l_odm_schema         VARCHAR2(30);
BEGIN


    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ': BEGIN');
    END IF;

   -- Get the ODM schema name that willbe used later for GRANTS and SYNONYMS
   l_odm_schema := fnd_oracle_schema.GetOuValue(G_ODM_SCHEMA_LOOKUP);
   IF l_odm_schema IS NULL THEN
      l_odm_schema := G_ODM_SCHEMA_NAME;
   END IF;



   IF p_object_type = 'MODL' THEN
      l_training_view   := 'AMS_DM_' || p_object_id || '_TRAIN_V';
      l_test_view       := 'AMS_DM_' || p_object_id || '_TEST_V';

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('ODM Schema'  || l_odm_schema );
         AMS_Utility_PVT.debug_message ('Dropping Training View ' || l_training_view  );
         AMS_Utility_PVT.debug_message ('Dropping Test View ' || l_test_view  );
      END IF;

      EXECUTE IMMEDIATE 'DROP VIEW ' || l_training_view ;
      EXECUTE IMMEDIATE 'DROP VIEW ' || l_test_view;

      IF FND_PROFILE.Value('AMS_DM_USE_DBLINK') = 'N' OR FND_PROFILE.Value('AMS_DM_USE_DBLINK') IS NULL THEN
         -- Also delete synonyms for the views in the ODM schema
         EXECUTE IMMEDIATE 'DROP synonym ' || l_odm_schema || '.' || l_training_view;
         EXECUTE IMMEDIATE 'DROP synonym ' || l_odm_schema || '.' || l_test_view;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message ('deleting synonyms for views in ' || l_odm_schema || ' schema.' );
         END IF;
      END IF;

   ELSE
      l_apply_view       := 'AMS_DM_' || p_object_id || '_APPLY_V';

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('ODM Schema'  || l_odm_schema );
         AMS_Utility_PVT.debug_message ('Dropping APPLY View  '  ||  l_apply_view);
      END IF;

      -- drop the apply view
      EXECUTE IMMEDIATE 'DROP VIEW ' || l_apply_view;


      IF FND_PROFILE.Value('AMS_DM_USE_DBLINK') = 'N' OR FND_PROFILE.Value('AMS_DM_USE_DBLINK') IS NULL THEN
         -- Also drop synonyms for the view in the ODM schema
         EXECUTE IMMEDIATE 'DROP synonym ' || l_odm_schema || '.' || l_apply_view ;
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message ('drop synonyms for apply views in ' || l_odm_schema || ' schema.' );
         END IF;
      END IF;

   END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ': END');
    END IF;

END cleanup_odm_input_views;


PROCEDURE generate_odm_input_views (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   p_data_source_id  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
)
IS
   L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;
   L_API_VERSION_NUMBER    CONSTANT NUMBER := 2.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'generate_odm_input_views';

   l_select_list           VARCHAR2(32000);
   l_from_clause           VARCHAR2(4000);
   l_where_clause          VARCHAR2(32000);
   l_target_id             NUMBER;

   l_where_clause_sel          VARCHAR2(32000);

   l_return_status         VARCHAR2(1);
   l_log_return_status  VARCHAR2(1);
   --SOURCE_OBJECT_ALIAS     VARCHAR2(2) := 'ds';

   CURSOR c_target_model (p_model_id IN NUMBER) IS
      SELECT model.target_id
      FROM   ams_dm_models_all_b model
      WHERE  model.model_id = p_model_id
      ;

   CURSOR c_target_score (p_score_id IN NUMBER) IS
      SELECT model.target_id,model.model_id
      FROM   ams_dm_scores_all_b score, ams_dm_models_all_b model
      WHERE  model.model_id = score.model_id
      AND    score.score_id = p_score_id
      ;

   CURSOR c_ds_pk_field (p_data_source_id IN NUMBER) IS
      SELECT SOURCE_OBJECT_NAME || '.' || SOURCE_OBJECT_PK_FIELD
      FROM   AMS_LIST_SRC_TYPES
      WHERE  LIST_SOURCE_TYPE_ID = p_data_source_id
      ;

    CURSOR c_model_type(p_model_id IN NUMBER) is
       SELECT model_type
       FROM ams_dm_models_vl
       WHERE model_id=p_model_id
       ;

   l_model_id           NUMBER;
   l_model_type         VARCHAR2(30);
   l_is_b2b             BOOLEAN := FALSE;
   l_is_seeded         BOOLEAN := FALSE;
   l_is_b2b_cust      BOOLEAN := FALSE;

   l_ds_pk_field          VARCHAR2(61);
   l_check_sql            VARCHAR2(32000);
   l_dummy                NUMBER;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- kbasavar 27-Jun-2003 validate for object type. Call randomize_build_data only for build
   IF p_object_type = 'MODL' THEN
     randomize_build_data (
        p_object_type  => p_object_type,
        p_object_id    => p_object_id
     );
   END IF;

   IF p_object_type = 'MODL' THEN
      OPEN c_target_model (p_object_id);
      FETCH c_target_model INTO l_target_id;
      CLOSE c_target_model;
      l_model_id := p_object_id;
   ELSE
      OPEN c_target_score (p_object_id);
      FETCH c_target_score INTO l_target_id,l_model_id;
      CLOSE c_target_score;
   END IF;


   OPEN c_model_type(l_model_id);
   FETCH c_model_type into l_model_type;
   CLOSE c_model_type;

   IF l_target_id < L_SEEDED_ID_THRESHOLD THEN
       l_is_seeded := TRUE;
   END IF;

   IF l_model_type = 'CUSTOMER_PROFITABILITY' AND l_is_seeded THEN
      AMS_DMSelection_PVT.is_b2b_data_source(
          p_model_id => l_model_id,
          x_is_b2b     => l_is_b2b
       );

    IF l_is_b2b THEN
        l_is_b2b_cust := TRUE ;
    END IF;
   END IF;

   IF l_is_b2b_cust THEN
       AMS_UTILITY_PVT.debug_message('Note: None of the attributes from the data source "Organization Contacts" will be used for mining as they are not relevant for this model.');
   END IF;

   get_select_fields (
      p_data_source_id  => p_data_source_id,
      p_target_id       => l_target_id,
      p_is_b2bcustprof      => l_is_b2b_cust,
      x_select_fields   => l_select_list,
      x_return_status   => l_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --kbasavar 12/17/2004 Perf Bug 4074433
   --This procedure will return two where clause strings one for creating view and the other for querying
   --The string for selections comes with bind variables.
   get_from_where_clause (
      p_object_type     => p_object_type,
      p_object_id       => p_object_id,
      p_data_source_id  => p_data_source_id,
      x_from_clause     => l_from_clause,
      x_where_clause_sel => l_where_clause_sel,
      x_where_clause    => l_where_clause,
      x_return_status   => l_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => SUBSTR ('SQL: ' || l_select_list || l_from_clause || l_where_clause, 1, 4000),
      p_msg_type        => 'DEBUG'
   );

   --added rosharma 20-sep-2003
   --check to see that only one row exists in the data source for the primary key
   OPEN c_ds_pk_field (p_data_source_id);
   FETCH c_ds_pk_field INTO l_ds_pk_field;
   CLOSE c_ds_pk_field;

   l_check_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (';
   l_check_sql := l_check_sql || 'SELECT ' || l_ds_pk_field || ', COUNT(*) ' || l_from_clause || l_where_clause_sel;
   l_check_sql := l_check_sql || ' GROUP BY ' || l_ds_pk_field || ' HAVING COUNT(*) > 1)';


   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => SUBSTR ('SQL: ' || l_check_sql, 1, 4000)
   );

   BEGIN
     EXECUTE IMMEDIATE l_check_sql INTO l_dummy USING p_object_type,p_object_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_dummy := 0;
   END;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => 'l_dummy :: ' || l_dummy
   );

   IF l_dummy = 1 THEN
      AMS_UTILITY_PVT.debug_message(L_API_NAME || ' :: ' || 'Data Source mapping not 1-to-1, raising error...');
      AMS_Utility_PVT.Error_Message('AMS_DM_DS_MAPPING_ERROR');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_object_type = 'MODL' THEN
      create_build_views (
         p_object_id,
         l_select_list,
         l_from_clause,
         l_where_clause
      );
   ELSE
      create_apply_views (
         p_object_id,
         l_select_list,
         l_from_clause,
         l_where_clause
      );
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => ' Exception in   generate_odm_input_views  status ' || x_return_status
   );
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
END generate_odm_input_views;


PROCEDURE randomize_build_data (
   p_object_type  IN VARCHAR2,
   p_object_id    IN NUMBER

)
IS
  CURSOR c_check_targets(data_flag VARCHAR2) IS
    SELECT COUNT(*) FROM ams_dm_source
    WHERE  training_data_flag = data_flag
    AND   arc_used_for_object = p_object_type
    AND   used_for_object_id = p_object_id
    AND TARGET_VALUE = '1';
  l_target_count NUMBER;

BEGIN
   DBMS_RANDOM.initialize (TO_NUMBER (TO_CHAR (SYSDATE, 'DDSSSS')));

   -- choang - 09-may-2002
   -- per ODM development, changed build data split as:
   -- 70% training data, 30% test data.
--   UPDATE ams_dm_source
--   SET training_data_flag = DECODE (MOD (DBMS_RANDOM.random, 2), 0, 'N', 'Y')
--   SET training_data_flag = DECODE (MOD (ABS (DBMS_RANDOM.random), 10), 0, 'N', 1, 'N', 2, 'N', 'Y')
-- WHERE arc_used_for_object = p_object_type
--   AND   used_for_object_id = p_object_id;

-- kbasavar - 24-June-2003
-- per 11.5.10 enhancements changed to split the positive and negative targets by 70-30
    UPDATE ams_dm_source
    SET training_data_flag = DECODE (MOD (ABS (DBMS_RANDOM.random), 10), 0, 'N', 1, 'N', 2, 'N', 'Y')
    WHERE arc_used_for_object = p_object_type
    AND   used_for_object_id = p_object_id
    AND   TARGET_VALUE = '0';

    UPDATE ams_dm_source
    SET training_data_flag = DECODE (MOD (ABS (DBMS_RANDOM.random), 10), 0, 'N', 1, 'N', 2, 'N', 'Y')
    WHERE arc_used_for_object = p_object_type
    AND   used_for_object_id = p_object_id
    AND   TARGET_VALUE = '1';

    OPEN c_check_targets('Y');
    FETCH c_check_targets INTO l_target_count;

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('Training dataset target count..' || l_target_count);
    END IF;

    IF (c_check_targets%NOTFOUND OR l_target_count=0) THEN
      AMS_Utility_PVT.Error_Message('AMS_MODEL_NO_BAL_POSITIVE_TGTS');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   CLOSE c_check_targets;

    OPEN c_check_targets('N');
    FETCH c_check_targets INTO l_target_count;

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('Test dataset  target count..' || l_target_count);
    END IF;

    IF (c_check_targets%NOTFOUND  OR l_target_count=0) THEN
      AMS_Utility_PVT.Error_Message('AMS_MODEL_NO_BAL_POSITIVE_TGTS');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   CLOSE c_check_targets;

   DBMS_RANDOM.terminate;
END randomize_build_data;


-- choang - 03-jun-2002 - obseleted
PROCEDURE get_select_list (
   p_target_type     IN VARCHAR2,
   x_select_list     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_select_list := '';

END get_select_list;


--
-- NOTE
--    Using ad_ddl.do_ddl, the table names must be fully qualified
--    with the schema name, otherwise, a table or view not found
--    exception will be thrown.
--
PROCEDURE create_build_views (
   p_object_id    IN NUMBER,
   p_select_list  IN VARCHAR2,
   p_from_clause  IN VARCHAR2,
   p_where_clause IN VARCHAR2
)
IS

l_return_status   VARCHAR2(1);

   l_result          BOOLEAN;
   l_status          VARCHAR2(10);
   l_industry        VARCHAR2(10);
   l_sql_str         VARCHAR2(32000);
   l_training_view   VARCHAR2(30);
   l_test_view       VARCHAR2(30);
   l_odm_schema      VARCHAR2(30);

BEGIN
    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('create_build_views  BEGIN' );
    END IF;

   -- Get the ODM schema name that willbe used later for GRANTS and SYNONYMS
   l_odm_schema := fnd_oracle_schema.GetOuValue(G_ODM_SCHEMA_LOOKUP);
   IF l_odm_schema IS NULL THEN
      l_odm_schema := G_ODM_SCHEMA_NAME;
   END IF;

   l_sql_str := 'SELECT ' || p_select_list;
   l_sql_str := l_sql_str || p_from_clause;
   l_sql_str := l_sql_str || p_where_clause;

   l_training_view   := 'AMS_DM_' || p_object_id || '_TRAIN_V';
   l_test_view       := 'AMS_DM_' || p_object_id || '_TEST_V';

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('ODM Schema'  || l_odm_schema );
      AMS_Utility_PVT.debug_message ('Creating Training View ' || l_training_view  );
      AMS_Utility_PVT.debug_message ('Creating Test View ' || l_test_view );

    END IF;

   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || l_training_view || ' AS ' || l_sql_str || ' AND s.training_data_flag = ''Y''';
      -- fix for bug # 4027150. ( Added table alias before the column name )

   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || l_test_view || ' AS ' || l_sql_str || ' AND s.training_data_flag = ''N''';
      -- fix for bug # 4027150. ( Added table alias before the column name )

   IF FND_PROFILE.Value('AMS_DM_USE_DBLINK') = 'N' OR FND_PROFILE.Value('AMS_DM_USE_DBLINK') IS NULL THEN
      -- Grant SELECT permissions to the ODM schema to read from these view
      EXECUTE IMMEDIATE 'GRANT SELECT on ' || l_training_view || ' to ' || l_odm_schema;
      EXECUTE IMMEDIATE 'GRANT SELECT on ' || l_test_view || ' to ' || l_odm_schema;

      -- Also create synonyms for the views in the ODM schema
      EXECUTE IMMEDIATE 'CREATE OR REPLACE synonym ' || l_odm_schema || '.' || l_training_view || ' for ' || l_training_view;
      EXECUTE IMMEDIATE 'CREATE OR REPLACE synonym ' || l_odm_schema || '.' || l_test_view || ' for ' || l_test_view;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('Created synonyms for views in ' || l_odm_schema || ' schema.' );
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('create_build_views  END' );
   END IF;

END create_build_views;


--
-- NOTE
--    Using ad_ddl.do_ddl, the table names must be fully qualified
--    with the schema name, otherwise, a table or view not found
--    exception will be thrown.
--
PROCEDURE create_apply_views (
   p_object_id    IN NUMBER,
   p_select_list  IN VARCHAR2,
   p_from_clause  IN VARCHAR2,
   p_where_clause IN VARCHAR2
)
IS

   l_result          BOOLEAN;
   l_status          VARCHAR2(10);
   l_industry        VARCHAR2(10);
   l_sql_str         VARCHAR2(32000);
   l_apply_view      VARCHAR2(30);
   l_odm_schema      VARCHAR2(30);
BEGIN

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('create_apply_views  BEGIN' );
    END IF;

   -- Get the ODM schema name that willbe used later for GRANTS and SYNONYMS
   l_odm_schema := fnd_oracle_schema.GetOuValue(G_ODM_SCHEMA_LOOKUP);
   IF l_odm_schema IS NULL THEN
      l_odm_schema := G_ODM_SCHEMA_NAME;
   END IF;


   l_sql_str := 'SELECT ' || p_select_list;
   l_sql_str := l_sql_str || p_from_clause;
   l_sql_str := l_sql_str || p_where_clause;

   l_apply_view       := 'AMS_DM_' || p_object_id || '_APPLY_V';

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('ODM Schema'  || l_odm_schema );
      AMS_Utility_PVT.debug_message ('Creating APPLY View '  ||  l_apply_view);
    END IF;

   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || l_apply_view || ' AS ' || l_sql_str;

   IF FND_PROFILE.Value('AMS_DM_USE_DBLINK') = 'N' OR FND_PROFILE.Value('AMS_DM_USE_DBLINK') IS NULL THEN
      -- Grant SELECT permissions to the ODM schema to read from apply view
      EXECUTE IMMEDIATE 'GRANT SELECT on ' || l_apply_view || ' to ' || l_odm_schema;

      -- Also create synonyms for the view in the ODM schema
      EXECUTE IMMEDIATE 'CREATE OR REPLACE synonym ' || l_odm_schema || '.' || l_apply_view || ' for ' || l_apply_view;
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('Created synonyms for views in ' || l_odm_schema || ' schema.' );
      END IF;
   END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('create_apply_views  END' );
    END IF;

END create_apply_views;


   ---------------------------------------------------------------
   -- Purpose:
   --    Retrieve the selected fields for model building.
   --
   -- NOTE:
   --    Only select fields from the data source which are active
   --    and not used as a target field.
   --
   --    Maximum number of fields depends on the size of the
   --    field name.  The maximum number of characters the
   --    x_select_fields varchar2 buffer is 32000.
   -- Parameter:
   --    p_data_source_id
   --    x_select_fields
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_select_fields (
      p_data_source_id  IN NUMBER,
      p_target_id       IN NUMBER,
      p_is_b2bcustprof          IN BOOLEAN,
      x_select_fields   OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_dup_fields (p_data_source_id IN NUMBER, p_target_field IN NUMBER, p_target_id IN NUMBER) IS
         SELECT lsf.source_column_name
         FROM   ams_list_src_fields lsf , ams_list_src_types lst
         WHERE  (lst.list_source_type_id = p_data_source_id
	         OR lst.list_source_type_id IN
		   (SELECT dts.data_source_id
		    FROM ams_dm_target_sources dts , ams_list_src_type_assocs lsa
		    WHERE dts.target_id = p_target_id
		    AND   lsa.sub_source_type_id = dts.data_source_id
		    AND   lsa.master_source_type_id = p_data_source_id
		    AND   lsa.enabled_flag = 'Y')
		)
	 AND    lst.enabled_flag = 'Y'
         AND    lsf.list_source_type_id = lst.list_source_type_id
	 AND    lsf.analytics_flag = 'Y'
	 AND    lsf.field_data_type in ('NUMBER' , 'VARCHAR2')
         AND    lsf.list_source_field_id <> p_target_field
         AND    lsf.enabled_flag = 'Y'
	 GROUP BY lsf.source_column_name
	 HAVING   COUNT(*) > 1
         ;

      CURSOR c_fields (p_data_source_id IN NUMBER, p_target_field IN NUMBER, p_target_id IN NUMBER) IS
         SELECT lst.source_object_name || '.' || lsf.source_column_name
         FROM   ams_list_src_fields lsf , ams_list_src_types lst
         WHERE  (lst.list_source_type_id = p_data_source_id
	         OR lst.list_source_type_id IN
		   (SELECT dts.data_source_id
		    FROM ams_dm_target_sources dts , ams_list_src_type_assocs lsa
		    WHERE dts.target_id = p_target_id
		    AND   lsa.sub_source_type_id = dts.data_source_id
		    AND   lsa.master_source_type_id = p_data_source_id
		    AND   lsa.enabled_flag = 'Y')
		)
	 AND    lst.enabled_flag = 'Y'
         AND    lsf.list_source_type_id = lst.list_source_type_id
	 AND    lsf.analytics_flag = 'Y'
	 AND    lsf.field_data_type in ('NUMBER' , 'VARCHAR2')
         AND    lsf.list_source_field_id <> p_target_field
         AND    lsf.enabled_flag = 'Y'
	 AND    lsf.source_column_name not in ('SOURCE_ID', 'TARGET_VALUE')
 	 -- Fix for bug # 4027150, added a filter not to select source_id and target_value
         ;

      CURSOR c_dup_fields_custprof (p_data_source_id IN NUMBER, p_target_field IN NUMBER, p_target_id IN NUMBER) IS
         SELECT lsf.source_column_name
         FROM   ams_list_src_fields lsf , ams_list_src_types lst
         WHERE  lst.list_source_type_id IN
                    (SELECT dts.data_source_id
                     FROM ams_dm_target_sources dts , ams_list_src_type_assocs lsa
                     WHERE dts.target_id = p_target_id
                     AND   lsa.sub_source_type_id = dts.data_source_id
                     AND   lsa.master_source_type_id = p_data_source_id
		    AND   lsa.enabled_flag = 'Y')
	 AND    lst.enabled_flag = 'Y'
         AND    lsf.list_source_type_id = lst.list_source_type_id
	 AND    lsf.analytics_flag = 'Y'
	 AND    lsf.field_data_type in ('NUMBER' , 'VARCHAR2')
         AND    lsf.list_source_field_id <> p_target_field
         AND    lsf.enabled_flag = 'Y'
	 GROUP BY lsf.source_column_name
	 HAVING   COUNT(*) > 1
         ;

      CURSOR c_fields_custprof (p_data_source_id IN NUMBER, p_target_field IN NUMBER, p_target_id IN NUMBER) IS
         SELECT lst.source_object_name || '.' || lsf.source_column_name
         FROM   ams_list_src_fields lsf , ams_list_src_types lst
         WHERE  lst.list_source_type_id IN
		   (SELECT dts.data_source_id
		    FROM ams_dm_target_sources dts , ams_list_src_type_assocs lsa
		    WHERE dts.target_id = p_target_id
		    AND   lsa.sub_source_type_id = dts.data_source_id
		    AND   lsa.master_source_type_id = p_data_source_id
		    AND   lsa.enabled_flag = 'Y')
	 AND    lst.enabled_flag = 'Y'
         AND    lsf.list_source_type_id = lst.list_source_type_id
	 AND    lsf.analytics_flag = 'Y'
	 AND    lsf.field_data_type in ('NUMBER' , 'VARCHAR2')
         AND    lsf.list_source_field_id <> p_target_field
         AND    lsf.enabled_flag = 'Y'
         ;

      CURSOR c_target_field (p_target_id IN NUMBER) IS
         SELECT target.source_field_id
         FROM   ams_dm_targets_b target
         WHERE  target.target_id = p_target_id
         ;

      l_field        VARCHAR2(151);
      l_target_field NUMBER;
      l_count NUMBER;
      l_dup_fields   VARCHAR2(32767);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      x_select_fields := 'distinct s.source_id';  -- mandatory identifier for ODM results

      OPEN c_target_field (p_target_id);
      FETCH c_target_field INTO l_target_field;
      CLOSE c_target_field;

      IF p_is_b2bcustprof THEN
         OPEN c_dup_fields_custprof (p_data_source_id, l_target_field, p_target_id);
         FETCH c_dup_fields_custprof INTO l_field;
         l_dup_fields := l_field;
         LOOP
            l_field := NULL;
             FETCH c_dup_fields_custprof INTO l_field;
             EXIT WHEN c_dup_fields_custprof%NOTFOUND;
            l_dup_fields := l_dup_fields || ', ' || l_field;
         END LOOP;
         l_count:=c_dup_fields_custprof%ROWCOUNT;
         IF l_count <> 0 THEN
            IF l_count <= 15 THEN
               AMS_Utility_PVT.error_message ('AMS_DM_DUP_SOURCE_FIELDS' , 'FIELDS' , l_dup_fields);
               x_return_status := FND_API.G_RET_STS_ERROR;
            ELSE
               AMS_Utility_PVT.error_message ('AMS_DM_DUP_SOURCE_FIELDS_NUM' , 'FIELD_COUNT' , l_count);
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         CLOSE c_dup_fields_custprof;
         return;
         END IF;
         CLOSE c_dup_fields_custprof;

         OPEN c_fields_custprof (p_data_source_id, l_target_field, p_target_id);
         -- logic:
         --    fetch first field into out param
         --    loop through all other fields
         --    append ", <column name>" to out param
         --    if cursor has no rows, return error
         FETCH c_fields_custprof INTO l_field;
         --changed rosharma 15-may-2003 bug # 2961532
         x_select_fields := x_select_fields || ', ' || l_field;
         --x_select_fields := x_select_fields || ', ds' || l_counter || '.' || l_field;
         --end change rosharma 15-may-2003 bug # 2961532
         LOOP
            l_field := NULL;
            -- if only one field or no field was fetched
            -- exit immediately
            FETCH c_fields_custprof INTO l_field;
            EXIT WHEN c_fields_custprof%NOTFOUND;
            --changed rosharma 15-may-2003 bug # 2961532
            x_select_fields := x_select_fields || ', ' || l_field;
            --x_select_fields := x_select_fields || ', ds' || l_counter || '.' || l_field;
            --end change rosharma 15-may-2003 bug # 2961532
         END LOOP;

         IF c_fields_custprof%ROWCOUNT = 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NO_VALID_SOURCE_FIELDS');
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE c_fields_custprof;



      ELSE
         OPEN c_dup_fields (p_data_source_id, l_target_field, p_target_id);
         FETCH c_dup_fields INTO l_field;
         l_dup_fields := l_field;
         LOOP
            l_field := NULL;
             FETCH c_dup_fields INTO l_field;
             EXIT WHEN c_dup_fields%NOTFOUND;
            l_dup_fields := l_dup_fields || ', ' || l_field;
         END LOOP;
         l_count:=c_dup_fields%ROWCOUNT;
         IF l_count <> 0 THEN
            IF l_count <= 15 THEN
               AMS_Utility_PVT.error_message ('AMS_DM_DUP_SOURCE_FIELDS' , 'FIELDS' , l_dup_fields);
               x_return_status := FND_API.G_RET_STS_ERROR;
            ELSE
               AMS_Utility_PVT.error_message ('AMS_DM_DUP_SOURCE_FIELDS_NUM' , 'FIELD_COUNT' , l_count);
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         CLOSE c_dup_fields;
         return;
         END IF;
         CLOSE c_dup_fields;


         OPEN c_fields (p_data_source_id, l_target_field, p_target_id);
         -- logic:
         --    fetch first field into out param
         --    loop through all other fields
         --    append ", <column name>" to out param
         --    if cursor has no rows, return error
         FETCH c_fields INTO l_field;
         --changed rosharma 15-may-2003 bug # 2961532
         x_select_fields := x_select_fields || ', ' || l_field;
         --x_select_fields := x_select_fields || ', ds' || l_counter || '.' || l_field;
         --end change rosharma 15-may-2003 bug # 2961532
         LOOP
            l_field := NULL;
            -- if only one field or no field was fetched
            -- exit immediately
            FETCH c_fields INTO l_field;
            EXIT WHEN c_fields%NOTFOUND;
            --changed rosharma 15-may-2003 bug # 2961532
            x_select_fields := x_select_fields || ', ' || l_field;
            --x_select_fields := x_select_fields || ', ds' || l_counter || '.' || l_field;
            --end change rosharma 15-may-2003 bug # 2961532
         END LOOP;

         IF c_fields%ROWCOUNT = 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NO_VALID_SOURCE_FIELDS');
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE c_fields;

      END IF;

      x_select_fields := x_select_fields || ', s.target_value';   -- mandatory target field
   END get_select_fields;


PROCEDURE get_from_where_clause (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   p_data_source_id  IN NUMBER,
   x_from_clause     OUT NOCOPY VARCHAR2,
   x_where_clause_sel    OUT NOCOPY VARCHAR2,
   x_where_clause    OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;

   -- assume data source is enabled.
   CURSOR c_data_source (p_data_source_id IN NUMBER) IS
      SELECT source_object_name
             , source_object_name||decode(UPPER(remote_flag),'Y','@'||database_link,'')
             , source_object_pk_field
      FROM ams_list_src_types
      WHERE list_source_type_id = p_data_source_id
      ;

   l_object_name      VARCHAR2(30);
   l_object_name_full VARCHAR2(151);
   l_pk_field         VARCHAR2(30);

   CURSOR c_target_id_model (p_model_id IN NUMBER) IS
      SELECT target_id
      FROM   ams_dm_models_v
      WHERE  model_id = p_model_id
      ;

   CURSOR c_target_id_score (p_score_id IN NUMBER) IS
      SELECT model.target_id,model.model_id
      FROM   ams_dm_models_v model , ams_dm_scores_v score
      WHERE  model.model_id = score.model_id
      AND    score.score_id = p_score_id
      ;

   l_target_id       NUMBER;

   CURSOR c_child_sources (p_target_id IN NUMBER) IS
      SELECT a.source_object_name , a.source_object_name||decode(UPPER(a.remote_flag),'Y','@'||a.database_link,''), a.list_source_type_id
      FROM   ams_list_src_types a, ams_dm_target_sources b
      WHERE  a.list_source_type_id = b.data_source_id
      AND    a.enabled_flag = 'Y'
      AND    b.target_id = p_target_id
      AND EXISTS (SELECT 1 FROM ams_list_src_type_assocs c,ams_dm_targets_b d
                  WHERE d.target_id = p_target_id
                  AND c.MASTER_SOURCE_TYPE_ID = d.data_source_id
                  AND c.SUB_SOURCE_TYPE_ID = b.data_source_id
                  AND c.enabled_flag = 'Y')
      ;

    CURSOR c_model_type(p_model_id IN NUMBER) is
       SELECT model_type
       FROM ams_dm_models_vl
       WHERE model_id=p_model_id
       ;


   l_child_object_name VARCHAR2(30);
   l_child_object_name_full VARCHAR2(151);
   l_child_ds_id     NUMBER;
   l_relation_cond   VARCHAR2(15000) := '';
   l_composite_relation_cond VARCHAR2(15000) := '';

   l_result          BOOLEAN;
   l_status          VARCHAR2(10);
   l_industry        VARCHAR2(10);
   l_ams_schema      VARCHAR2(30);
   l_apps_schema     VARCHAR2(30);

   l_model_id           NUMBER;
   l_model_type         VARCHAR2(30);
   l_is_b2b             BOOLEAN := FALSE;
   l_is_seeded         BOOLEAN := FALSE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_data_source (p_data_source_id);
   FETCH c_data_source INTO l_object_name, l_object_name_full, l_pk_field;
   IF c_data_source%NOTFOUND THEN
      CLOSE c_data_source;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;
   CLOSE c_data_source;

   IF p_object_type = 'MODL' THEN
      OPEN c_target_id_model (p_object_id);
      FETCH c_target_id_model INTO l_target_id;
      CLOSE c_target_id_model;
      l_model_id := p_object_id;
   ELSE
      OPEN c_target_id_score (p_object_id);
      FETCH c_target_id_score INTO l_target_id,l_model_id;
      CLOSE c_target_id_score;
   END IF;


   OPEN c_model_type(l_model_id);
   FETCH c_model_type into l_model_type;
   CLOSE c_model_type;

   IF l_target_id < L_SEEDED_ID_THRESHOLD THEN
       l_is_seeded := TRUE;
   END IF;

   IF l_model_type = 'CUSTOMER_PROFITABILITY' AND l_is_seeded THEN
      AMS_DMSelection_PVT.is_b2b_data_source(
          p_model_id => l_model_id,
          x_is_b2b     => l_is_b2b
       );
   END IF;

   l_result := fnd_installation.get_app_info(
                  'AMS',
                  l_status,
                  l_industry,
                  l_ams_schema
               );

   x_from_clause := ' FROM ' || l_ams_schema || '.ams_dm_source s, ';
   x_from_clause := x_from_clause || l_object_name_full;
   IF l_model_type = 'CUSTOMER_PROFITABILITY' AND l_is_b2b AND l_is_seeded THEN
      x_where_clause := ' WHERE s.party_id = ' || l_object_name || '.ORGANIZATION_ID';
   ELSE
      x_where_clause := ' WHERE s.party_id = ' || l_object_name || '.' || l_pk_field;
   END IF;

   OPEN c_child_sources (l_target_id);
   LOOP
    FETCH c_child_sources INTO l_child_object_name , l_child_object_name_full, l_child_ds_id;
    EXIT WHEN c_child_sources%NOTFOUND;
    x_from_clause := x_from_clause || ', ' || l_child_object_name_full;
    -- Get the relation conditions for all the related data sources and plug in
    AMS_DMSelection_PVT.get_related_ds_condition ( p_master_ds_id => p_data_source_id,
   			       p_child_ds_id  => l_child_ds_id,
   			       x_sql_stmt     => l_relation_cond);
    IF LENGTH(l_composite_relation_cond) > 0 THEN
       l_composite_relation_cond := l_composite_relation_cond || ' AND ';
    END IF;
    l_composite_relation_cond := l_composite_relation_cond || l_relation_cond;
   END LOOP;
   CLOSE c_child_sources;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('get_from_where_clause' || ' :: relation condition : ' || l_composite_relation_cond);
   END IF;
   IF LENGTH(l_composite_relation_cond) > 0 THEN
      IF l_model_type = 'CUSTOMER_PROFITABILITY' AND l_is_seeded THEN
         l_composite_relation_cond := REPLACE(l_composite_relation_cond , 'AMS_DM_PARTY_PROFIT_V.PARTY_ID' , 'AMS_DM_PARTY_PROFIT_V.PARTY_ID(+)');
	 IF l_is_b2b THEN
            l_composite_relation_cond := REPLACE(l_composite_relation_cond , 'AMS_DM_PARTY_ATTRIBUTES_V.PARTY_ID = AMS_ORG_CONTACT_DETAILS_V.PARTY_ID' , 'AMS_DM_PARTY_ATTRIBUTES_V.PARTY_ID = AMS_ORG_CONTACT_DETAILS_V.ORGANIZATION_ID');
	 END IF;
      END IF;
      x_where_clause := x_where_clause || ' AND ' || l_composite_relation_cond;
   END IF;
   x_where_clause_sel := x_where_clause || ' AND s.arc_used_for_object = :1 ';
   x_where_clause_sel := x_where_clause_sel || ' AND s.used_for_object_id = :2 ';

   x_where_clause := x_where_clause || ' AND s.arc_used_for_object = ''' || p_object_type || '''';
   x_where_clause := x_where_clause || ' AND s.used_for_object_id = ' || p_object_id;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('get_from_where_clause' || ' :: from condition for data source : ' || x_from_clause);
      AMS_Utility_PVT.debug_message ('get_from_where_clause' || ' :: where condition for data source : ' || x_where_clause);
   END IF;
END get_from_where_clause;


End AMS_DMSource_PVT;

/
