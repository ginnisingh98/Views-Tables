--------------------------------------------------------
--  DDL for Package Body AMS_SCORERESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCORERESULT_PVT" as
/* $Header: amsvdrsb.pls 120.0 2005/05/31 20:21:35 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Scoreresult_PVT
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 24-Jan-2001 choang   Added setting of out id after create api.
-- 24-Jan-2001 choang   Changed call to update_row api to have object
--                      version number + 1.
-- 26-Jan-2001 choang   1) added summarize_results 2) changed response
--                      to score.
-- 12-Feb-2001 choang   Cursor in summarize_results needed to join to
--                      ams_dm_rules to get tree_node.
-- 28-Feb-2001 choang   Renamed some messages so name length is less than 30.
-- 13-Apr-2001 choang   Added generate_list and parse_tree_node_str
-- 21-May-2001 choang   Added overloaded generate_list
-- 10-Jul-2001 choang   Replaced tree_node with decile
-- 09-Oct-2001 choang   Added filter to summarize_results
-- 27-Nov-2001 choang   Fixed callout to generate_list
-- 07-Jan-2002 choang   Removed security group id
-- 17-May-2002 choang   bug 2380113: removed g_user_id and g_login_id
-- 10-Jun-2002 choang   Fixed gscc error for bug 2380113.
-- 08-Jul-2002 nyostos  Removed hardcoded ListSourceType in generate_list().
--                      Added code to look up the SOURCE_TYPE_CODE for the list_source_type_id
-- 19-Mar-2003 choang   Bug 2856138 - Added return status for OSOException in JSP.
-- 04-Apr-2003 choang   Bug 2888007 - fixed primary_key param in list create API
--                      invocation.
-- 17-Jun-2003 nyostos  Added procedure insert_percentile_results to summarize scoring
--                      run results by percentile in AMS_DM_SCORE_PCT_RESULTS table.
--                      These results are used in calculating the Optimal Targeting Chart.
-- 31-Jul-2003 nyostos  Fixed logic in insert_percentile_results to account for having fewer
--                      than 100 records.
-- 12-Aug-2003 kbasavar  For Customer profitability
-- 15-Aug-2003 nyostos  Fixed logic for updating random_result in insert_percentile_results.
-- 10-Sep-2003 kbasavar Changes made to check for seeded targets for Customer profitability
-- 15-Sep-2003 nyostos  Changes related to parallel mining processes using Global Temp Tables.
-- 20-Oct-2003 nyostos  Added check if no records found in insert_percentile_results.
-- 06-Nov-2003 rosharma Renamed ams_dm_org_contacts_stg to ams_dm_org_contacts
-- 17-Dec-2003 rosharma Fixed to update ams_dm_source when inserting percentiles in AMS_DM_SCORE_PCT_RESULTS
-- 30-Dec-2003 kbasavar Call insert_percentile_results only for models enabled for Optimal Targeting
-- 20-Jan-2004 rosharma bug # 3380057
-- 22-Jan-2004 kbasavar If List Generation is successful then insert into AMS_DM_SCORE_LISTS.
-- 23-Jan-2004 kbasavar Org Product Affinity Changes.
-- 20-Apr-2004 pkanukol SQL Bind Vars issue fixed
-- 22-Apr-2004 choang   Fixed install bug 3588127; reverted bind var change for insert_percentile_results
-- 4-May-2004 pkanukol  Tuned insert_percentile_results
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Scoreresult_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdrsb.pls';

/***
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
***/

G_LIST_SOURCE_NAME      VARCHAR2(30) := 'AMS_DM_SOURCE';

-- package global types
TYPE tree_node_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--Model types
G_MODEL_TYPE_EMAIL   CONSTANT VARCHAR2(30) := 'EMAIL';
G_MODEL_TYPE_DMAIL   CONSTANT VARCHAR2(30) := 'TELEMARKETING';
G_MODEL_TYPE_TELEM   CONSTANT VARCHAR2(30) := 'DIRECTMAIL';
G_MODEL_TYPE_PROD    CONSTANT VARCHAR2(30) := 'PRODUCT_AFFINITY';


-- forward procedure/function declarations
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

/*
-- Moved the definition to body
-- 3/24/2005 kbasavar for 4259733
-- 17-jun-2003 added by nyostos
PROCEDURE insert_percentile_results (
    p_score_id          IN   NUMBER
);
*/

PROCEDURE parse_tree_node_str (
   p_tree_node_str   IN VARCHAR2,
   x_tree_table      OUT NOCOPY tree_node_table_type,
   x_tab_ctr         OUT NOCOPY NUMBER
);


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,

    p_scoreresult_rec   IN   scoreresult_rec_type := g_miss_scoreresult_rec,
    x_score_result_id   OUT NOCOPY  NUMBER
)

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_SCORE_RESULT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_DM_SCORE_RESULTS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_DM_SCORE_RESULTS
                    WHERE SCORE_RESULT_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Scoreresult_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_scoreresult_rec.SCORE_RESULT_ID IS NULL OR p_scoreresult_rec.SCORE_RESULT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_SCORE_RESULT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_SCORE_RESULT_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Scoreresult');
          END IF;

          -- Invoke validation procedures
          Validate_scoreresult(
            p_api_version     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_create,
            p_scoreresult_rec  => p_scoreresult_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_DM_SCORE_RESULTS_PKG.Insert_Row)
      AMS_DM_SCORE_RESULTS_PKG.Insert_Row(
          px_score_result_id        => l_score_result_id,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => FND_GLOBAL.USER_ID,
          p_creation_date           => SYSDATE,
          p_created_by              => FND_GLOBAL.USER_ID,
          p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_score_id                => p_scoreresult_rec.score_id,
          p_decile                  => p_scoreresult_rec.decile,
          p_num_records             => p_scoreresult_rec.num_records,
          p_score                   => p_scoreresult_rec.score,
          p_confidence              => p_scoreresult_rec.confidence
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	 x_score_result_id := l_score_result_id;

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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Scoreresult_PVT;
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
End Create_Scoreresult;


PROCEDURE Update_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,

    p_scoreresult_rec         IN    scoreresult_rec_type,
    x_object_version_number   OUT NOCOPY  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_SCORE_RESULT_ID    NUMBER;
   l_tar_scoreresult_rec  AMS_Scoreresult_PVT.scoreresult_rec_type := P_scoreresult_rec;

   CURSOR c_get_scoreresult(p_score_result_id NUMBER) IS
      SELECT *
      FROM  AMS_DM_SCORE_RESULTS
      WHERE score_result_id = p_score_result_id;
   l_ref_scoreresult_rec  c_get_Scoreresult%ROWTYPE ;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Scoreresult_PVT;

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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Scoreresult( l_tar_scoreresult_rec.score_result_id);

      FETCH c_get_Scoreresult INTO l_ref_scoreresult_rec  ;

      IF ( c_get_Scoreresult%NOTFOUND) THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
            p_token_name   => 'INFO',
            p_token_value  => 'Scoreresult') ;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
       -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;
      CLOSE     c_get_Scoreresult;

      -- Check Whether record has been changed by someone else
      IF (l_tar_scoreresult_rec.object_version_number <> l_ref_scoreresult_rec.object_version_number) THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
            p_token_name   => 'INFO',
            p_token_value  => 'Scoreresult') ;
         RAISE FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Scoreresult');
          END IF;

          -- Invoke validation procedures
          Validate_scoreresult(
            p_api_version     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_update,
            p_scoreresult_rec  =>  p_scoreresult_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_DM_SCORE_RESULTS_PKG.Update_Row)
      AMS_DM_SCORE_RESULTS_PKG.Update_Row(
          p_score_result_id      => p_scoreresult_rec.score_result_id,
          p_last_update_date     => SYSDATE,
          p_last_updated_by      => FND_GLOBAL.USER_ID,
          p_creation_date        => SYSDATE,
          p_created_by           => l_ref_scoreresult_rec.created_by,
          p_last_update_login    => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_scoreresult_rec.object_version_number + 1,
          p_score_id             => p_scoreresult_rec.score_id,
          p_decile               => p_scoreresult_rec.decile,
          p_num_records          => p_scoreresult_rec.num_records,
          p_score                => p_scoreresult_rec.score,
          p_confidence           => p_scoreresult_rec.confidence
      );
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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Scoreresult_PVT;
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
End Update_Scoreresult;


PROCEDURE Delete_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_score_result_id         IN  NUMBER,
    p_object_version_number   IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Scoreresult_PVT;

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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_DM_SCORE_RESULTS_PKG.Delete_Row)
      AMS_DM_SCORE_RESULTS_PKG.Delete_Row(
          p_SCORE_RESULT_ID  => p_SCORE_RESULT_ID);
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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Scoreresult_PVT;
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
End Delete_Scoreresult;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,

    p_score_result_id   IN  NUMBER,
    p_object_version    IN  NUMBER
)
IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Lock_Scoreresult';
   L_API_VERSION_NUMBER    CONSTANT NUMBER   := 1.0;
   L_FULL_NAME             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_SCORE_RESULT_ID       NUMBER;

   CURSOR c_Scoreresult IS
      SELECT SCORE_RESULT_ID
      FROM AMS_DM_SCORE_RESULTS
      WHERE SCORE_RESULT_ID = p_SCORE_RESULT_ID
      AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
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
  OPEN c_Scoreresult;

  FETCH c_Scoreresult INTO l_SCORE_RESULT_ID;

  IF (c_Scoreresult%NOTFOUND) THEN
    CLOSE c_Scoreresult;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Scoreresult;

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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Scoreresult_PVT;
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
End Lock_Scoreresult;


PROCEDURE check_scoreresult_uk_items(
    p_scoreresult_rec   IN   scoreresult_rec_type,
    p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status     OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_SCORE_RESULTS',
         'SCORE_RESULT_ID = ''' || p_scoreresult_rec.SCORE_RESULT_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_SCORE_RESULTS',
         'SCORE_RESULT_ID = ''' || p_scoreresult_rec.SCORE_RESULT_ID ||
         ''' AND SCORE_RESULT_ID <> ' || p_scoreresult_rec.SCORE_RESULT_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','SCORE_RESULT_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_scoreresult_uk_items;

PROCEDURE check_scoreresult_req_items(
    p_scoreresult_rec               IN  scoreresult_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_scoreresult_rec.score_id = FND_API.g_miss_num OR p_scoreresult_rec.score_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_SCORE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.decile = FND_API.g_miss_char OR p_scoreresult_rec.decile IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_DECILE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.num_records = FND_API.g_miss_num OR p_scoreresult_rec.num_records IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_NUM_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.score = FND_API.g_miss_char OR p_scoreresult_rec.score IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_SCORE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.confidence = FND_API.g_miss_num OR p_scoreresult_rec.confidence IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_CONFIDENCE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE  -- update mode
      IF p_scoreresult_rec.score_result_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.score_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_score_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.decile IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_DECILE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.num_records IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_NUM_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.score IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_SCORE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_scoreresult_rec.confidence IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORRES_NO_CONFIDENCE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_scoreresult_req_items;

PROCEDURE check_scoreresult_FK_items(
    p_scoreresult_rec   IN scoreresult_rec_type,
    x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_scoreresult_rec.score_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
         'ams_dm_scores_all_b',
         'score_id',
         p_scoreresult_rec.score_id
      ) = FND_API.g_false THEN
         AMS_Utility_PVT.error_message ('AMS_SCORRES_BAD_SCORE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_scoreresult_FK_items;

PROCEDURE check_scoreresult_Lookup_items(
    p_scoreresult_rec IN scoreresult_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END check_scoreresult_Lookup_items;

PROCEDURE Check_scoreresult_Items (
    P_scoreresult_rec     IN    scoreresult_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_scoreresult_uk_items(
      p_scoreresult_rec => p_scoreresult_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_scoreresult_req_items(
      p_scoreresult_rec => p_scoreresult_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_scoreresult_FK_items(
      p_scoreresult_rec => p_scoreresult_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_scoreresult_Lookup_items(
      p_scoreresult_rec => p_scoreresult_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_scoreresult_Items;


PROCEDURE Complete_scoreresult_Rec (
    P_scoreresult_rec     IN    scoreresult_rec_type,
     x_complete_rec        OUT NOCOPY    scoreresult_rec_type
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Complete_scoreresult_Rec;

PROCEDURE Validate_scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode   IN   VARCHAR2,
    p_scoreresult_rec   IN   scoreresult_rec_type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_scoreresult_rec  AMS_Scoreresult_PVT.scoreresult_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Scoreresult_;

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
              Check_scoreresult_Items(
                 p_scoreresult_rec  => p_scoreresult_rec,
                 p_validation_mode  => JTF_PLSQL_API.g_update,
                 x_return_status    => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_scoreresult_Rec(
         p_scoreresult_rec => p_scoreresult_rec,
         x_complete_rec    => l_scoreresult_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_scoreresult_Rec(
           p_api_version      => 1.0,
           p_init_msg_list    => FND_API.G_FALSE,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_scoreresult_rec  => l_scoreresult_rec);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Scoreresult_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Scoreresult_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Scoreresult_;
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
End Validate_Scoreresult;


PROCEDURE Validate_scoreresult_rec(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_scoreresult_rec   IN    scoreresult_rec_type
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
END Validate_scoreresult_Rec;

-- 17-jun-2003 added by nyostos
PROCEDURE insert_percentile_results (
    p_score_id          IN   NUMBER
)
IS
   L_API_NAME              VARCHAR2(30) := 'insert_percentile_results';

   CURSOR c_total_records (p_score_id IN NUMBER) IS
      SELECT count(*)
      FROM   ams_dm_source s
      WHERE  s.arc_used_for_object = 'SCOR'
      AND    s.used_for_object_id = p_score_id
      AND    s.continuous_score IS NOT NULL;

   CURSOR c_results (p_score_id IN NUMBER) IS
      SELECT (s.continuous_score/100) confidence , party_id
      FROM   ams_dm_source s
      WHERE  s.arc_used_for_object = 'SCOR'
      AND    s.used_for_object_id = p_score_id
      AND    s.continuous_score IS NOT NULL
      ORDER BY  s.continuous_score desc;

   l_total_records         NUMBER := 0;
   l_record_count          NUMBER := 0;
   l_records_per_pct       NUMBER := 0;
   l_num_records_cum       NUMBER := 0;
   l_confidence            NUMBER := 0;
   l_confidence_cum        NUMBER := 0;
   l_avg_confidence        NUMBER := 0;
   l_avg_confidence_cum    NUMBER := 0;
   l_percentile            NUMBER := 1;
   l_percentile_multiplier NUMBER := 1;
   l_counter               NUMBER := 1;
   l_score_id              NUMBER := p_score_id;
   l_party_ids             VARCHAR2(4000) := '';
   l_sql_str             VARCHAR2(5000) := '';
   l_temp_party_id_list           dbms_sql.Varchar2_Table;
   l_party_id_list           dbms_sql.Varchar2_Table;
   l_conf_list      dbms_sql.NUMBER_table;
   l_bs_rows NUMBER := 0;
   l_ctr  NUMBER := 0;
   l_ctr_2   NUMBER :=0;
   l_percentile_list        dbms_sql.NUMBER_table;
   l_record_count_list       dbms_sql.NUMBER_table;
   l_num_recs_cum_list       dbms_sql.NUMBER_table;
   l_avg_conf_list           dbms_sql.NUMBER_table;
   l_avg_conf_cum_list        dbms_sql.NUMBER_table;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT insert_percentile_results;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- clear results from any previous execution
   DELETE FROM ams_dm_score_pct_results
   WHERE score_id = l_score_id;

   -- First get the total number of parties in ams_dm_scource
   OPEN c_total_records (l_score_id);
   FETCH c_total_records INTO l_total_records;
   CLOSE c_total_records;

   -- If there are no records return
   IF l_total_records <= 0 THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('No score results found in AMS_DM_SOURCE. Exiting.' );
      END IF;
      RETURN;
   END IF;

   l_bs_rows:= fnd_profile.value_specific('AMS_BATCH_SIZE');
   IF  (l_bs_rows  IS NULL  OR l_bs_rows < 1) THEN
      l_bs_rows :=1000;
   END IF;

   -- Calculate the number of records in each percent
   l_records_per_pct := CEIL(l_total_records / 100);

   IF l_total_records < 100 THEN
      l_percentile_multiplier := ROUND(100 / l_total_records, 4);
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Number of Parties in Scored Population : ' || l_total_records );
      AMS_UTILITY_PVT.debug_message('Number of Parties per Percentile : ' || l_records_per_pct );
      AMS_UTILITY_PVT.debug_message('Percentile Multiplier: ' || l_percentile_multiplier );
   END IF;


   --FOR l_result_rec IN c_results (l_score_id) LOOP

   OPEN c_results(l_score_id);
   LOOP
      FETCH c_results BULK COLLECT INTO l_conf_list, l_party_id_list  LIMIT l_bs_rows;

      FOR i IN 1..l_conf_list.COUNT LOOP

         l_record_count := l_record_count + 1;
         l_num_records_cum := l_num_records_cum + 1;
         l_confidence := l_confidence + l_conf_list(i);
         l_confidence_cum := l_confidence_cum + l_conf_list(i);

         l_ctr := l_ctr+1;
         l_temp_party_id_list(l_ctr) := l_party_id_list(i);

         /*     if LENGTH(l_party_ids) > 0 THEN
            l_party_ids := l_party_ids || ', ' || l_result_rec.party_id;
         ELSE
            l_party_ids := l_result_rec.party_id;
         END IF; */

         IF (l_record_count >= l_records_per_pct OR l_num_records_cum = l_total_records) THEN

            l_ctr_2 := l_ctr_2 +1;

            -- Calculate percentile
            IF l_num_records_cum = l_total_records THEN
               l_percentile := 100;
            ELSE
               l_percentile := TRUNC(l_counter * l_percentile_multiplier);
            END IF;

            -- Calculate average confidence for the percentile
            l_avg_confidence := l_confidence / l_record_count;

            -- Calculate cumulative average confidence up to this percentile
            l_avg_confidence_cum := l_confidence_cum / l_num_records_cum;

            -- Build the lists required for the bulk insert
            l_percentile_list(l_ctr_2) := l_percentile;
            l_record_count_list(l_ctr_2) := l_record_count;
            l_num_recs_cum_list(l_ctr_2) := l_num_records_cum;
            l_avg_conf_list(l_ctr_2) := l_avg_confidence;
            l_avg_conf_cum_list(l_ctr_2) := l_avg_confidence_cum;

            /*INSERT INTO ams_dm_score_pct_results (
               score_result_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               object_version_number,
               score_id,
               percentile,
               num_records,
               num_records_cum,
               confidence,
               confidence_cum,
               random_result
            ) VALUES (
               ams_dm_score_pct_results_s.NEXTVAL,
               SYSDATE,
               FND_GLOBAL.user_id,
               SYSDATE,
               FND_GLOBAL.user_id,
               FND_GLOBAL.conc_login_id,
               1,
               l_score_id,
               l_percentile,
               l_record_count,
               l_num_records_cum,
               l_avg_confidence,
               l_avg_confidence_cum,
               0
            ); */

            --update ams_dm_source set percentile = l_percentile
            --WHERE  arc_used_for_object = 'SCOR'
            --AND    used_for_object_id = p_score_id
            --AND    to_char(party_id) IN (l_party_ids);
            /*** reverting to old code until batch solution can be implemented
              target build 38
            l_sql_str := 'update ams_dm_source set percentile = :1' ;
            l_sql_str := l_sql_str || ' WHERE  arc_used_for_object = ''SCOR''';
            l_sql_str := l_sql_str || ' AND    used_for_object_id = :2';
            l_sql_str := l_sql_str || ' AND    party_id IN (:3)' ;
            ***/
            /*     l_sql_str := 'update ams_dm_source set percentile = :1' ;
            l_sql_str := l_sql_str || ' WHERE  arc_used_for_object = ''SCOR''';
            l_sql_str := l_sql_str || ' AND    used_for_object_id = :2';
            l_sql_str := l_sql_str || ' AND    party_id IN (' || l_party_ids || ')' ; */

            -- bug 3588127 - invalid package due to incorrect commenting
            --               reverted bind change for party ids; need to implement batch
            -- bug 3569505 - SQL Bind Vars fix - pkanukol
            --         EXECUTE IMMEDIATE l_sql_str using l_percentile, p_score_id, l_party_ids;
            --        EXECUTE IMMEDIATE l_sql_str using l_percentile, p_score_id;

            FORALL k in 1..l_temp_party_id_list.COUNT
	       update ams_dm_source set percentile = l_percentile
               WHERE arc_used_for_object = 'SCOR' AND used_for_object_id = l_score_id AND party_id = l_temp_party_id_list(k) ;

            -- reset record counter and confidence
            l_record_count := 0;
            l_confidence   := 0;
            --     l_party_ids := '';
            l_ctr := 0;
            l_temp_party_id_list.delete;

	    -- Increment counter
            l_counter := l_counter + 1;

         END IF;
      END LOOP;
      l_conf_list.delete;
      l_party_id_list.delete;
      EXIT WHEN c_results%NOTFOUND;
   END LOOP;
   CLOSE c_results;


     -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Inserted: ' || l_total_records  || ' Records');
   END IF;

   -- If some records were inserted, then insert a record for the zero percentile
   -- to start the graph from the origin
   IF l_total_records > 0 THEN
      FORALL h IN 1..l_percentile_list.COUNT
         INSERT INTO ams_dm_score_pct_results (
               score_result_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               object_version_number,
               score_id,
               percentile,
               num_records,
               num_records_cum,
               confidence,
               confidence_cum,
               random_result
            ) VALUES (
               ams_dm_score_pct_results_s.NEXTVAL,
               SYSDATE,
               FND_GLOBAL.user_id,
               SYSDATE,
               FND_GLOBAL.user_id,
               FND_GLOBAL.conc_login_id,
               1,
               l_score_id,
               l_percentile_list(h),
               l_record_count_list(h),
               l_num_recs_cum_list(h),
               l_avg_conf_list(h),
               l_avg_conf_cum_list(h),
               0
            );
         INSERT INTO ams_dm_score_pct_results (
            score_result_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            object_version_number,
            score_id,
            percentile,
            num_records,
            num_records_cum,
            confidence,
            confidence_cum,
            random_result
         ) VALUES (
            ams_dm_score_pct_results_s.NEXTVAL,
            SYSDATE,
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.user_id,
            FND_GLOBAL.conc_login_id,
            1,
            l_score_id,
            0,
            0,
            0,
            0,
            0,
            0
         );

      l_percentile_list.delete;
      l_record_count_list.delete;
      l_num_recs_cum_list.delete;
      l_avg_conf_list.delete;
      l_avg_conf_cum_list.delete;
      l_ctr_2 := 0;
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Inserted record for zeroth percentile: ');
         AMS_UTILITY_PVT.debug_message('Cumulative Average Confidence for 100th percentile: ' || l_avg_confidence_cum );
      END IF;

      UPDATE ams_dm_score_pct_results
         SET RANDOM_RESULT = l_avg_confidence_cum
       WHERE score_id = l_score_id
         AND percentile > 0;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO insert_percentile_results;
     AMS_UTILITY_PVT.debug_message(l_api_name || ': Error ');
     RAISE FND_API.G_EXC_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO insert_percentile_results;
     AMS_UTILITY_PVT.debug_message(l_api_name || ': Error ');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO insert_percentile_results;
     AMS_UTILITY_PVT.debug_message(l_api_name || ': Error ');
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_percentile_results;


PROCEDURE summarize_results (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_score_id          IN   NUMBER
)
IS
   L_API_NAME              VARCHAR2(30) := 'Summarize_Results';
   L_API_VERSION_NUMBER    NUMBER := 1.0;

   CURSOR c_results (p_score_id IN NUMBER) IS
      SELECT s.decile,
             s.score_result,
             AVG (s.continuous_score) confidence,
             COUNT(*) row_count
      FROM   ams_dm_source s
      WHERE  s.arc_used_for_object = 'SCOR'
      AND    s.used_for_object_id = p_score_id
      AND    s.decile IS NOT NULL
      AND    s.continuous_score IS NOT NULL
      GROUP BY s.decile, s.score_result;

   CURSOR c_model_type (p_score_id IN NUMBER) IS
      SELECT m.model_type, m.model_id
      FROM   ams_dm_scores_all_b s, ams_dm_models_all_b m
      WHERE  s.score_id = p_score_id
      AND    m.model_id = s.model_id;

   l_model_id            NUMBER;
   l_model_type               VARCHAR2(30);
   l_is_org_prod           BOOLEAN;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT summarize_Scoreresult_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
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
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- clear results from any previous execution
   DELETE FROM ams_dm_score_results
   WHERE score_id = p_score_id;

   FOR l_result_rec IN c_results (p_score_id) LOOP
      -- can't batch insert because of group by
      -- constraints on the sequence.
      INSERT INTO ams_dm_score_results (
         score_result_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         object_version_number,
         score_id,
         decile,
         num_records,
         score,
         confidence
      ) VALUES (
         ams_dm_score_results_s.NEXTVAL,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         FND_GLOBAL.conc_login_id,
         1,
         p_score_id,
         l_result_rec.decile,
         l_result_rec.row_count,
         l_result_rec.score_result,
         l_result_rec.confidence
      );
   END LOOP;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Inserted Decile Records ');
   END IF;

   --kbasavar 12/30/2003 Modified to Call insert_percentile_results only for models enabled for optimal targeting
   OPEN c_model_type(p_score_id);
   FETCH c_model_type INTO l_model_type,l_model_id;
   CLOSE c_model_type;

   AMS_DMSelection_PVT.is_org_prod_affn(
        p_model_id => l_model_id,
        x_is_org_prod     => l_is_org_prod
       );

   IF l_model_type IN (G_MODEL_TYPE_EMAIL, G_MODEL_TYPE_DMAIL, G_MODEL_TYPE_TELEM, G_MODEL_TYPE_PROD) AND l_is_org_prod = FALSE THEN
     -- 17-Jun-2003 nyostos  Insert percentile records
      insert_percentile_results (p_score_id);
   END IF;
   --kbasavar 12/30/2003 End Modified to Call insert_percentile_results only for models enabled for optimal targeting

   IF p_commit = FND_API.g_true THEN
      COMMIT;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO summarize_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO summarize_Scoreresult_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO summarize_Scoreresult_PVT;
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
END Summarize_Results;


PROCEDURE parse_tree_node_str (
   p_tree_node_str   IN VARCHAR2,
   x_tree_table      OUT NOCOPY tree_node_table_type,
   x_tab_ctr         OUT NOCOPY NUMBER
) IS
   v_tree_node    VARCHAR2(10);
   l_num          NUMBER;
   v_num          NUMBER;
   l_tree_node_str   VARCHAR2(400);
   l_tab_ctr      NUMBER := 0;
BEGIN
   l_num := 0;
   l_tree_node_str := p_tree_node_str || ',';

   WHILE l_num < LENGTH(l_tree_node_str) LOOP
      v_num := l_num + 1;
      l_num := INSTR(l_tree_node_str, ',', l_num + 1);
      v_tree_node := SUBSTR(l_tree_node_str, v_num,l_num - v_num);

      l_tab_ctr := l_tab_ctr + 1;
      x_tree_table(l_tab_ctr) := TO_NUMBER(v_tree_node);
   END LOOP;

   x_tab_ctr := l_tab_ctr;
END parse_tree_node_str;

PROCEDURE generate_list(
   p_score_id        IN NUMBER,
   p_model_type      IN VARCHAR2,   -- misnomer of variable; should be target group type
   p_tree_node_str   IN VARCHAR2,
   p_list_name       IN VARCHAR2 ,
   p_owner_user_id   IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_list_header_id  OUT NOCOPY VARCHAR2
) IS
   l_rule_id         NUMBER;
   l_model_id        NUMBER;
   l_sql_str         VARCHAR2(2000);
   l_master_type     VARCHAR2(30);
   l_primary_key     VARCHAR2(30);

   l_tree_table   tree_node_table_type;
   l_tab_ctr      NUMBER;

   CURSOR c_ListSourceTypeCode IS
   SELECT L.SOURCE_TYPE_CODE, l.source_object_pk_field,T.target_id
     FROM AMS_DM_SCORES_ALL_B S, AMS_DM_MODELS_ALL_B M, AMS_DM_TARGETS_B T, AMS_LIST_SRC_TYPES L
    WHERE S.SCORE_ID       = p_score_id
      AND S.MODEL_ID       = M.MODEL_ID
      AND M.TARGET_ID      = T.TARGET_ID
      AND T.DATA_SOURCE_ID = L.LIST_SOURCE_TYPE_ID;

   CURSOR c_model_type(p_model_id IN NUMBER) IS
      SELECT model_type
      FROM ams_dm_models_vl
      WHERE model_id=p_model_id;

   CURSOR c_model_id(p_scor_id IN NUMBER) IS
      SELECT model_id
      FROM AMS_DM_SCORES_ALL_B
      WHERE score_id=p_scor_id;

   l_model_type     VARCHAR2(30);
   l_is_b2b    BOOLEAN := FALSE;
   l_modl_id   NUMBER;
   l_target_id NUMBER;
   l_seeded_target BOOLEAN := FALSE;
   L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;

   CURSOR c_scoreListId IS
      SELECT AMS_DM_SCORE_LISTS_S.NEXTVAL
      FROM dual;
   l_insertSql      VARCHAR2(1000);
   l_scoreListId NUMBER;

BEGIN
   Fnd_Msg_Pub.initialize;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: generate_list start');
   END IF;

   OPEN c_ListSourceTypeCode;
   FETCH c_ListSourceTypeCode INTO l_master_type, l_primary_key, l_target_id;

   IF (c_ListSourceTypeCode%NOTFOUND) THEN
      CLOSE c_ListSourceTypeCode;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_ListSourceTypeCode;

   OPEN c_model_id(p_score_id);
   FETCH c_model_id into l_modl_id;
   CLOSE c_model_id;

   AMS_DMSelection_PVT.is_b2b_data_source(
         p_model_id => l_modl_id,
         x_is_b2b     => l_is_b2b
      );

   IF l_target_id < L_SEEDED_ID_THRESHOLD THEN
      l_seeded_target := TRUE;
   END IF;

   OPEN c_model_type(l_modl_id);
   FETCH c_model_type INTO l_model_type;
   CLOSE c_model_type;

   IF (AMS_DEBUG_HIGH_ON) THEN
      IF l_is_b2b then
	AMS_Utility_PVT.debug_message ('B2B');
      else
	AMS_Utility_PVT.debug_message ('B2C');
      end if;
      AMS_Utility_PVT.debug_message ('Model Type: ' || l_model_type);
   END IF;

-- start change rosharma 20-jan-2004 bug # 3380057
--   IF l_is_b2b AND l_model_type = 'CUSTOMER_PROFITABILITY' THEN
   IF l_is_b2b AND l_seeded_target AND l_model_type = 'CUSTOMER_PROFITABILITY' THEN
-- end change rosharma 20-jan-2004 bug # 3380057
--    nyostos Sep 15, 2003 - Use Global Temporary Table
--    l_sql_str := 'SELECT ams_dm_org_contacts_stg.party_id, '''|| l_master_type || '''';
--      l_sql_str := l_sql_str || ' FROM ams_dm_org_contacts_stg, ams_dm_source';
--      l_sql_str := l_sql_str || ' WHERE ams_dm_org_contacts_stg.arc_object_used_by= ''SCOR''';
--      l_sql_str := l_sql_str || ' AND ams_dm_org_contacts_stg.object_used_by_id = '|| p_score_id;
--      l_sql_str := l_sql_str || ' AND ams_dm_source.arc_used_for_object = ''SCOR''';
--      l_sql_str := l_sql_str || ' AND ams_dm_source.used_for_object_id = '|| p_score_id;
--      l_sql_str := l_sql_str || ' AND ams_dm_source.party_id = ams_dm_org_contacts_stg.org_party_id';
--      l_sql_str := l_sql_str || ' AND ams_dm_source.decile IN (' || p_tree_node_str || ')';
      l_sql_str := 'SELECT ams_dm_org_contacts.party_id, '''|| l_master_type || '''';
      l_sql_str := l_sql_str || ' FROM ams_dm_org_contacts, ams_dm_source';
      l_sql_str := l_sql_str || ' WHERE ams_dm_org_contacts.arc_object_used_by= ''SCOR''';
      l_sql_str := l_sql_str || ' AND ams_dm_org_contacts.object_used_by_id = '|| p_score_id;
      l_sql_str := l_sql_str || ' AND ams_dm_source.arc_used_for_object = ''SCOR''';
      l_sql_str := l_sql_str || ' AND ams_dm_source.used_for_object_id = '|| p_score_id;
      l_sql_str := l_sql_str || ' AND ams_dm_source.party_id = ams_dm_org_contacts.org_party_id';
      l_sql_str := l_sql_str || ' AND ams_dm_source.decile IN (' || p_tree_node_str || ')';

--      G_LIST_SOURCE_NAME := 'AMS_DM_ORG_CONTACTS_STG';
      G_LIST_SOURCE_NAME := 'ams_dm_org_contacts';

   ELSE
      l_sql_str := 'SELECT party_id, '''|| l_master_type || '''';
      l_sql_str := l_sql_str || ' FROM ams_dm_source';
      l_sql_str := l_sql_str || ' WHERE arc_used_for_object = ''SCOR''';
      l_sql_str := l_sql_str || ' AND used_for_object_id = '|| p_score_id;
      l_sql_str := l_sql_str || ' AND decile IN (' || p_tree_node_str || ')';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('generate_list  SQL = ' || l_sql_str);
   END IF;

   --
   -- choang - 03-apr-2003
   -- p_primary_key is the party_id from ams_dm_source which
   -- holds the primary key defined from the data source.  For
   -- seeded data sources, this holds the party id from TCA.
   AMS_LISTGENERATION_PKG.CREATE_LIST (
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_TRUE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      p_list_name       => p_list_name,
      p_owner_user_id   => p_owner_user_id,
      p_sql_string      => l_sql_str,
      p_primary_key     => 'PARTY_ID',
      p_source_object_name => G_LIST_SOURCE_NAME,
      p_master_type     => l_master_type,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_list_header_id  => x_list_header_id
   );
   IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   ELSE  -- If List Generation is successful then insert into AMS_DM_SCORE_LISTS. kbasavar 1/22/2004 for 3363509

      l_insertSql  := 'INSERT INTO AMS_DM_SCORE_LISTS(SCORE_LIST_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,';
      l_insertSql  := l_insertSql || 'CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER, SCORE_ID, LIST_HEADER_ID)' ;
      l_insertSql  := l_insertSql || ' VALUES(AMS_DM_SCORE_LISTS_S.NEXTVAL, SYSDATE, :1, SYSDATE, :2 ' ;
      l_insertSql  := l_insertSql || ', :3 , 1, :4, :5)';

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('SCORE LISTS  SQL = ' || l_insertSql);
      END IF;

      EXECUTE Immediate l_insertSql USING FND_GLOBAL.USER_ID,FND_GLOBAL.USER_ID,FND_GLOBAL.CONC_LOGIN_ID,p_score_id, x_list_header_id ;

   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END generate_list;


PROCEDURE generate_list (
   p_score_id        IN NUMBER,
   p_tree_node_str   IN VARCHAR2,
   p_list_name       IN VARCHAR2 ,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_list_header_id  OUT NOCOPY VARCHAR2
)
IS
   l_model_type         VARCHAR2(30);  -- misnomer of variable; should be target group type
   l_owner_user_id      NUMBER;

   CURSOR c_model_type (p_score_id IN NUMBER) IS
      SELECT m.target_group_type, s.owner_user_id
      FROM   ams_dm_scores_all_b s, ams_dm_models_all_b m
      WHERE  s.score_id = p_score_id
      AND    m.model_id = s.model_id;
BEGIN
   OPEN c_model_type (p_score_id);
   FETCH c_model_type INTO l_model_type, l_owner_user_id;
   CLOSE c_model_type;

   generate_list (
      p_score_id        => p_score_id,
      p_model_type      => l_model_type,
      p_tree_node_str   => p_tree_node_str,
      p_list_name       => p_list_name,
      p_owner_user_id   => l_owner_user_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_list_header_id  => x_list_header_id
   );
   IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END generate_list;


END AMS_Scoreresult_PVT;

/
