--------------------------------------------------------
--  DDL for Package Body AMS_DM_SCORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_SCORE_PVT" as
/* $Header: amsvdmsb.pls 120.3 2006/07/17 12:03:25 kbasavar noship $ */
-- Start of Comments
-- Package name     : AMS_DM_SCORE_PVT
-- Purpose          : PACKAGE BODY FOR PRIVATE API
-- History          :
-- 20-Nov-2000 julou    created
-- 21-Nov-2000 julou    added foreign key validation and lookup validation
--                      added name and description to insert_row and update_row
-- 18-Dec-2000 julou    added validation for object_version_number in delete procedure
-- 23-Jan-2001 choang   Changed ams_dm_models_b to ams_dm_models_all_b in uk validation.
-- 24-Jan-2001 choang   Changed package name to AMS_DM_SCORE_PVT.
-- 26-Jan-2001 choang   Added increment of object ver num in update api.
-- 29-Jan-2001 choang   Removed return statement in req item validation.
-- 12-Feb-2001 choang   1) Changed model_score to score. 2) added new columns.
-- 19-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 20-Feb-2001 choang   Added default N for logs_flag during insert.
-- 26-Feb-2001 choang   Added custom_setup_id and country_id.
-- 27-Feb-2001 choang   Added access functionality.
-- 28-Feb-2001 choang   Changed names of some error messages to reduce length to
--                      less than 30.
-- 06-Mar-2001 choang   Added default of status if not provided in create api call.
-- 10-Mar-2001 choang   1) added wf_itemkey. 2) added callout to wf startprocess,
--                      wf_revert(), process_score_success()
-- 11-Mar-2001 choang   Added handle_preview_request
-- 04-Apr-2001 choang   Added handle of scheduled_date change to cancel_process or change_schedule
--                      modified callout to startprocess to include scheduled_timezone_id and scheduled_date
-- 07-Apr-2001 choang   Added copy_score.
-- 11-Apr-2001 choang   1) changed spec of wf_revert 2) added wf_score
-- 12-Apr-2001 choang   1) Fixed scheduled date comparison to NULL in update_score. 2) added
--                      model_used_for_scoring
-- 26-Apr-2001 sveerave Changed column names to be of application column names from db column names
--                      in get_column_value call-out.
-- 09-May-2001 choang   handle_preview_request was not returning the request_id
-- 17-Aug-2001 choang   Added custom_setup_id in out param of create api.
-- 01-Oct-2001 choang   bug 2024520: custom setup id was not being returned by
--                      the create api.
-- 18-Oct-2001 choang   Changed logic to check for scoring run submission when
--                      in DRAFT status.
-- 26-Nov-2001 choang   fixed updating of model status in process score success.
-- 27-Nov-2001 choang   Added score_date and results_flag in process score success.
-- 13-Dec-2001 choang   Modified callout to change_schedule and added wf_startprocess
--                      to enable re-scoring.
-- 17-Dec-2001 choang   Added validation for owner update.
-- 20-Dec-2001 choang   Added logs_flag update in handle_preview_request.
-- 17-May-2002 choang   bug 2380113: removed g_user_id and g_login_id
-- 11-Jun-2002 choang   Fixed gscc error for bug 2380113.
-- 04-Oct-2002 choang   1) Added cancel_run_request
--                      2) Implementation of new Score States: PREVIEWING,
--                      INVALID and FAILED
--                      3) Added cleanupPreviousScoreData
-- 28-Nov-2002 rosharma Added validations for
--                      - min/max records >= 0
--			- max records >= min records
--			- 0 <= pct random <= 100
--			- If selection method is random, random pct is entered
--			- If selection method is every nth row, number of rows is entered
--
-- 30-Jan-2003 nyostos  Fixed the following:
--                      - Changed score name uniqueness code.
--                      - Bug related to WF process hanging when score owner is not a valid WF approver
-- 07-Feb-2003 nyostos  Added a different return status for errors encountered in submitting score wf process.
-- 09-Feb-2003 rosharma Random % should be > 0. Every Nth Row value should be greater than 0.
-- 10-Feb-2003 rosharma in copy method, Copy pct_random and nth_rowalso from ref record, if selection type is 'NTH_RECORD' or 'RANDOM'.
-- 14-Mar-2003 nyostos  Fixed return status for errors encountered in submitting score wf process.
-- 24-Mar-2003 nyostos  Fixed bug 2863861.
-- 01-May-2003 nyostos  Fixed copying of Data Selections Bug 2934000.
-- 17-Jun-2003 nyostos  Added cleanup code for AMS_DM_SCORE_PCT_RESULTS table.
-- 14-Aug-2003 nyostos  Added call to cleanupPreviousScoreData in wf_score.
-- 20-Aug-2003 rosharma Fixed bug 3104201.
-- 22-Aug-2003 nyostos  Changed create_score logic to insert appropriate custom_setup_id (145 or 146)
--                      depending on Scoring Run type. Response and Product Affinity scoring runs
--                      use custom_setup_id=146 which has Optimal Targeting Chart option.
-- 04-Sep-2003 rosharma Fixed bug 3127555.
-- 21-Sep-2003 rosharma Audience Data Source uptake changes to copy_score.
-- 09-Dec-2003 kbasavar Org Product Affinity change in create_score.
-- 09-May-2005 srivikri Fix for bug 4357993.
-- 19-May-2005 srivikri fix for bug 4220828
--
-- NOTE             :
-- End of Comments


G_PKG_NAME        CONSTANT VARCHAR2(30):= 'AMS_DM_SCORE_PVT';
G_FILE_NAME       CONSTANT VARCHAR2(12) := 'amsvdmsb.pls';
G_DEFAULT_STATUS  CONSTANT VARCHAR2(30) := 'DRAFT';
G_OBJECT_TYPE_SCORE  CONSTANT VARCHAR2(30) := 'SCOR';
G_STATUS_TYPE_SCORE  CONSTANT VARCHAR2(30) := 'AMS_DM_SCORE_STATUS';
G_STATUS_TYPE_MODEL  CONSTANT VARCHAR2(30) := 'AMS_DM_MODEL_STATUS';
G_STATUS_SCORING     CONSTANT VARCHAR2(30) := 'SCORING';
G_STATUS_AVAILABLE   CONSTANT VARCHAR2(30) := 'AVAILABLE';
G_STATUS_COMPLETED   CONSTANT VARCHAR2(30) := 'COMPLETED';
G_STATUS_SCHEDULED   CONSTANT VARCHAR2(30) := 'SCHEDULED';
G_STATUS_QUEUED      CONSTANT VARCHAR2(30) := 'QUEUED';
G_STATUS_INVALID     CONSTANT VARCHAR2(30) := 'INVALID';
G_STATUS_FAILED      CONSTANT VARCHAR2(30) := 'FAILED';
G_STATUS_PREVIEWING  CONSTANT VARCHAR2(30) := 'PREVIEWING';
G_STATUS_ARCHIVED    CONSTANT VARCHAR2(30) := 'ARCHIVED';

-- 22-Aug-2003 nyostos Added for cue card menu with Optimal Targeting Chart option.
G_OTGT_ACTIVITY_TYPE CONSTANT VARCHAR2(30) := 'OTGT';
G_MODEL_TYPE_EMAIL   CONSTANT VARCHAR2(30) := 'EMAIL';
G_MODEL_TYPE_DMAIL   CONSTANT VARCHAR2(30) := 'TELEMARKETING';
G_MODEL_TYPE_TELEM   CONSTANT VARCHAR2(30) := 'DIRECTMAIL';
G_MODEL_TYPE_PROD    CONSTANT VARCHAR2(30) := 'PRODUCT_AFFINITY';

--start changes rosharma 20-aug-2003 bug 3104201
G_SEEDED_ID_THRESHOLD      CONSTANT NUMBER       := 10000;
--end changes rosharma 20-aug-2003 bug 3104201

/***
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
***/

-- global cursors
CURSOR c_user_status_id (p_status_type IN VARCHAR2, p_status_code IN VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = p_status_type
   AND    system_status_code = p_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y'
   ;

-- Cursor to get the system_status_code for a specific system_status_type and user_status_id
   CURSOR c_user_status_code (p_status_type IN VARCHAR2, p_status_id IN NUMBER) IS
      SELECT system_status_code
      FROM   ams_user_statuses_b
      WHERE  system_status_type = p_status_type
      AND    user_status_id = p_status_id
      ;

-- foreward procedure and function declarations
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_Score_Rec (
   p_score_rec    IN Score_Rec_Type,
   x_complete_rec OUT NOCOPY   Score_Rec_Type
);


PROCEDURE check_access (
   p_score_rec       IN score_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
);


FUNCTION model_used_for_scoring (
   p_model_id           IN NUMBER,
   p_current_score_id   IN NUMBER
) RETURN VARCHAR2;


--
-- Purpose
-- Start Workflow process for Previewing Data Selections for the Scoring Run.
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE wf_startPreviewProcess (
   p_score_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_score_rec IN OUT NOCOPY score_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
);

--
-- Purpose
-- Cleanup previous Scoring Run results data and
-- records from ams_dm_source
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE cleanupPreviousScoreData(
   p_score_id IN NUMBER
);

--
-- Purpose
-- To check if a Preview request can be started. We cannot Preview
-- data selections for a Scoring Run if it has any of the following statuses:
-- SCHEDULED, SCORING, PREVIEWING, ARCHIVED, QUEUED..
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE proceedWithPreview(
   p_score_id     IN    NUMBER,
   x_proceed_flag OUT NOCOPY   VARCHAR2
);

--
-- Purpose
-- To check if there is data selected to be Previewed. We cannot Preview
-- data selections for a Scoring Run if it has list, segment, workbook,... selected.
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE dataToPreview(
   p_score_id           IN    NUMBER,
   x_data_exists_flag   OUT NOCOPY   VARCHAR2
);

--
-- Purpose
-- Returns Scoring Run Status_Code and User_Status_Id for a Scoring Run
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE getScoreStatus(
   p_score_id        IN    NUMBER,
   x_status_code     OUT NOCOPY   VARCHAR2,
   x_user_status_id  OUT NOCOPY NUMBER
);

--
-- Purpose
-- To check if Scoring Run data selection sizing options and selection
-- method have changed. This would INVALIDate a COMPLETED Scoring Run.
--
-- History
-- 07-Oct-2002 nyostos   Created.
PROCEDURE check_data_size_changes(
   p_input_score_rec          IN    score_rec_type,
   x_selections_changed_flag  OUT NOCOPY   VARCHAR2
);


--
-- Purpose
-- Start Workflow process for the scoring run.
--
-- History
-- 12-Dec-2001 choang   Created.
PROCEDURE wf_startprocess (
   p_score_id IN NUMBER,
   p_scheduled_date IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_score_rec IN OUT NOCOPY score_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
);


-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Score(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_score_id          IN  NUMBER,
    p_object_version    IN  NUMBER
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Score';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_score_id            NUMBER;

   CURSOR c_Score_b IS
      SELECT score_id
      FROM ams_dm_scores_all_b
      WHERE score_id = p_score_id
      AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;

   CURSOR c_Score_tl IS
      SELECT score_id
      FROM ams_dm_scores_all_tl
      WHERE score_id = p_score_id
      AND USERENV('LANG') IN (language, source_lang)
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
  OPEN c_Score_b;
  FETCH c_Score_b INTO l_score_id;
  IF (c_Score_b%NOTFOUND) THEN
    CLOSE c_Score_b;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Score_b;

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
     ROLLBACK TO LOCK_Score_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Score_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Score_PVT;
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
End Lock_Score;



-- Hint: Primary key needs to be returned.
PROCEDURE Create_Score(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2     := FND_API.G_FALSE,
    p_commit            IN VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_Score_rec         IN Score_Rec_Type  := G_MISS_Score_REC,
    x_custom_setup_id   OUT NOCOPY NUMBER,
    x_score_id          OUT NOCOPY NUMBER
)
IS
   l_api_name                 CONSTANT VARCHAR2(30) := 'Create_Score';
   l_api_version_number       CONSTANT NUMBER   := 1.0;

   l_object_version_number    NUMBER := 1;
   l_dummy                    NUMBER;
   l_score_rec                AMS_DM_SCORE_PVT.Score_Rec_Type := P_Score_Rec;

   l_access_rec               AMS_Access_PVT.access_rec_type;

   l_model_type               VARCHAR2(30);

   l_is_org_prod           BOOLEAN;

   CURSOR c_id IS
      SELECT ams_dm_scores_all_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ams_dm_scores_all_b
      WHERE score_id = l_id;

   CURSOR c_status_code (p_user_status_id IN NUMBER) IS
      SELECT system_status_code
      FROM ams_user_statuses_vl
      WHERE user_status_id = p_user_status_id;

   -- 22-Aug-2003 - nyostos
   -- Changed cursor to retrieve custom_setup_id = 145 or 146 (for cue card menu
   -- with optimal targeting option) depending on Scoring Run Type
   CURSOR c_custom_setup_id IS
      SELECT custom_setup_id
      FROM   ams_custom_setups_b
      WHERE  object_type = G_OBJECT_TYPE_SCORE
      AND    activity_type_code IS NULL
      AND    enabled_flag = 'Y'
      ;
   CURSOR c_custom_setup_id_otgt IS
      SELECT custom_setup_id
      FROM   ams_custom_setups_b
      WHERE  object_type = G_OBJECT_TYPE_SCORE
      AND    activity_type_code = G_OTGT_ACTIVITY_TYPE
      AND    enabled_flag = 'Y'
      ;

   -- 22-Aug-2003 - nyostos
   -- Cursor to get the model_type for the scoring run
   CURSOR c_model_type (l_model_id IN NUMBER) IS
      SELECT model_type
      FROM   ams_dm_models_all_b
      WHERE  model_id = l_model_id
      ;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SCORE_PVT;

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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_score_rec.score_id IS NULL OR l_score_rec.score_id = FND_API.g_miss_num THEN
         LOOP
            l_dummy := NULL;
            OPEN c_id;
            FETCH c_id INTO l_score_rec.score_id;
            CLOSE c_id;

            OPEN c_id_exists(l_score_rec.score_id);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;
            EXIT WHEN l_dummy IS NULL;
         END LOOP;
      END IF;

      IF NVL (l_score_rec.user_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND NVL (l_score_rec.status_code, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
         OPEN c_user_status_id (G_STATUS_TYPE_SCORE, G_DEFAULT_STATUS);
         FETCH c_user_status_id INTO l_score_rec.user_status_id;
         CLOSE c_user_status_id;
      ELSIF NVL (l_score_rec.user_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         OPEN c_user_status_id (G_STATUS_TYPE_SCORE, l_score_rec.status_code);
         FETCH c_user_status_id INTO l_score_rec.user_status_id;
         CLOSE c_user_status_id;
      END IF;

      OPEN c_status_code (l_score_rec.user_status_id);
      FETCH c_status_code INTO l_score_rec.status_code;
      CLOSE c_status_code;

      l_score_rec.status_date := SYSDATE;

      l_score_rec.country_id := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');

      -- 22-Aug-2003 - nyostos
      -- Get the Model type to determine which custom setup id to insert for the Scoring Run
      OPEN c_model_type (l_score_rec.model_id);
      FETCH c_model_type INTO l_model_type;
      CLOSE c_model_type;

      --kbasavar for Org Prod Affinity
      AMS_DMSelection_PVT.is_org_prod_affn(
            p_model_id => l_score_rec.model_id,
            x_is_org_prod     => l_is_org_prod
          );

      IF l_model_type IN (G_MODEL_TYPE_EMAIL, G_MODEL_TYPE_DMAIL, G_MODEL_TYPE_TELEM, G_MODEL_TYPE_PROD) AND l_is_org_prod = FALSE THEN
         OPEN c_custom_setup_id_otgt;
         FETCH c_custom_setup_id_otgt INTO l_score_rec.custom_setup_id;
         CLOSE c_custom_setup_id_otgt;
      ELSE
         OPEN c_custom_setup_id;
         FETCH c_custom_setup_id INTO l_score_rec.custom_setup_id;
         CLOSE c_custom_setup_id;
      END IF;


      -- default row_selection_type
      IF NVL (l_score_rec.row_selection_type, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
         l_score_rec.row_selection_type := 'STANDARD';
      END IF;

      -- Validation Section
      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
         -- Debug message
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Private API: Validate_Score');
         END IF;

         -- Invoke validation procedures
         Validate_Score (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            P_Score_Rec          => l_score_rec,
            p_validation_mode    => JTF_PLSQL_API.g_create,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
         );
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_DM_scoreS_B_PKG.Insert_Row)
      AMS_DM_scoreS_B_PKG.Insert_Row(
          p_score_id             => l_score_rec.score_ID,
          p_last_update_date     => SYSDATE,
          p_last_updated_by      => FND_GLOBAL.USER_ID,
          p_creation_date        => SYSDATE,
          p_created_by           => FND_GLOBAL.USER_ID,
          p_last_update_login    => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number   => l_object_version_number,
          p_model_id             => l_score_rec.model_id,
          p_user_status_id       => l_score_rec.user_status_id,
          p_status_code          => l_score_rec.status_code,
          p_status_date          => l_score_rec.status_date,
          p_owner_user_id        => l_score_rec.owner_user_id,
          p_results_flag         => NVL (l_score_rec.results_flag,'N'),
          p_logs_flag            => NVL (l_score_rec.logs_flag, 'N'),
          p_scheduled_date       => l_score_rec.scheduled_date,
          p_scheduled_timezone_id   => l_score_rec.scheduled_timezone_id,
          p_score_date           => l_score_rec.score_date,
          p_total_records        => l_score_rec.total_records,
          p_total_positives      => l_score_rec.total_positives,
          p_expiration_date      => l_score_rec.expiration_date,
          p_min_records          => l_score_rec.min_records,
          p_max_records          => l_score_rec.max_records,
          p_row_selection_type   => l_score_rec.row_selection_type,
          p_every_nth_row        => l_score_rec.every_nth_row,
          p_pct_random           => l_score_rec.pct_random,
          p_custom_setup_id      => l_score_rec.custom_setup_id,
          p_country_id           => l_score_rec.country_id,
          p_wf_itemkey           => l_score_rec.wf_itemkey,
          p_score_name           => l_score_rec.score_name,
          p_description          => l_score_rec.description,
          p_attribute_category   => l_score_rec.attribute_category,
          p_attribute1           => l_score_rec.attribute1,
          p_attribute2           => l_score_rec.attribute2,
          p_attribute3           => l_score_rec.attribute3,
          p_attribute4           => l_score_rec.attribute4,
          p_attribute5           => l_score_rec.attribute5,
          p_attribute6           => l_score_rec.attribute6,
          p_attribute7           => l_score_rec.attribute7,
          p_attribute8           => l_score_rec.attribute8,
          p_attribute9           => l_score_rec.attribute9,
          p_attribute10          => l_score_rec.attribute10,
          p_attribute11          => l_score_rec.attribute11,
          p_attribute12          => l_score_rec.attribute12,
          p_attribute13          => l_score_rec.attribute13,
          p_attribute14          => l_score_rec.attribute14,
          p_attribute15          => l_score_rec.attribute15);

      x_score_id := l_score_rec.score_id;
      x_custom_setup_id := l_score_rec.custom_setup_id;

      -- create an entry to the access table for the current
      -- user/owner.
      l_access_rec.act_access_to_object_id := l_score_rec.score_id;
      l_access_rec.arc_act_access_to_object := G_OBJECT_TYPE_SCORE;
      l_access_rec.user_or_role_id := l_score_rec.owner_user_id;
      l_access_rec.arc_user_or_role_type := 'USER';
      l_access_rec.owner_flag := 'Y';
      l_access_rec.admin_flag := 'Y';
      l_access_rec.delete_flag := 'N';

      AMS_Access_PVT.create_access (
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => FND_API.G_FALSE,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_access_rec         => l_access_rec,
         x_access_id          => l_access_rec.activity_access_id
      );
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
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
     ROLLBACK TO CREATE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Score_PVT;
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
End Create_Score;


PROCEDURE Update_Score(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_score_rec         IN   Score_Rec_Type,
    x_object_version_number   OUT NOCOPY  NUMBER
)
IS
   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Score';
   l_api_version_number       CONSTANT NUMBER   := 1.0;
   L_SCORE_STATUS_SCHEDULED   CONSTANT VARCHAR2(30) := 'SCHEDULED';

   -- Local Variables
   l_object_version_number    NUMBER;
   l_tar_score_rec            AMS_DM_SCORE_PVT.Score_Rec_Type := p_score_rec;
   l_rowid                    ROWID;
   l_user_timezone_name       VARCHAR2(80);
   l_user_status_id           NUMBER;
   l_monitor_url              VARCHAR2(4000);
   l_run_started              VARCHAR2(1);
   l_selections_changed_flag  VARCHAR2(1);
   l_return_status            VARCHAR2(1);
   l_model_status             VARCHAR2(30);
   l_data_exists_flag         VARCHAR2(1);
   l_schedule_date            DATE;
   l_scheduled_timezone_id    NUMBER;
   l_is_enabled               BOOLEAN;
   l_target_id                NUMBER;

   CURSOR c_reference (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id;
   l_reference_rec         c_reference%ROWTYPE;

   CURSOR c_status (p_id IN NUMBER) IS
      SELECT system_status_code
      FROM   ams_user_statuses_vl
      WHERE  user_status_id = p_id;

   CURSOR c_target_id (p_score_id IN NUMBER) IS
      SELECT m.target_id from ams_dm_models_all_b m,ams_dm_scores_all_b s
      WHERE  m.model_id = s.model_id
      AND    s.score_id = p_score_id
      ;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SCORE_PVT;

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

      -- Initialize run process flag to 'N'
      l_run_started := 'N';

      -- Initialize data selections changed flag to 'N'
      l_selections_changed_flag := 'N';

      --
      -- Initialize and default local variables
      Complete_Score_Rec(
         p_score_rec    => p_score_rec,
         x_complete_rec => l_tar_score_rec
      );

      OPEN c_reference (l_tar_score_rec.score_id);
      FETCH c_reference INTO l_reference_rec;
      IF (c_reference%NOTFOUND) THEN
         CLOSE c_reference;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'dm_score', FALSE);
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;
      CLOSE c_reference;

      OPEN c_target_id (l_tar_score_rec.score_id);
      FETCH c_target_id INTO l_target_id;
      CLOSE c_target_id;

      -- 24-Mar-2003 nyostos  Fixed bug 2863861.
      -- Check if the user is resubmitting the update request (via browser refresh button
      -- or by pressing the "update" button again) before re-loading the record.
      IF (p_score_rec.object_version_number <> l_reference_rec.object_version_number) THEN
         AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_tar_score_rec.country_id := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');

      IF (l_reference_rec.status_code = G_DEFAULT_STATUS OR    -- DRAFT
          l_reference_rec.status_code = G_STATUS_INVALID OR
          l_reference_rec.status_code = G_STATUS_FAILED) AND p_score_rec.scheduled_date <> FND_API.G_MISS_DATE THEN

         -- First check that Model is still AVAILABLE
         wf_checkModelStatus ( p_score_id        => l_tar_score_rec.score_id,
                               x_return_status   => l_return_status,
                               x_model_status    => l_model_status
                             );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- First check that the target is enabled
	    AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_target_id,
			 x_is_enabled => l_is_enabled
			 );
            IF l_is_enabled = FALSE THEN
	       IF (AMS_DEBUG_HIGH_ON) THEN
	          AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot score');
	       END IF;
	       -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	       -- displayed to the user
	       x_return_status := 'T';
	       RETURN;
            END IF;
            -- Also check that there is data selections for the Scoring Run
            -- We should not schedule the Run if there are no data selections
            dataToPreview (l_tar_score_rec.score_id, l_data_exists_flag);
            IF l_data_exists_flag = 'N' THEN
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Score');
               END IF;
               -- Set x_return_status to 'D' (for data error). This will results in a different message
               -- displayed to the user
               x_return_status := 'D';
               RETURN;
            END IF;

            /* choang - 13-dec-2002 - added for nocopy */
            l_schedule_date := l_tar_score_rec.scheduled_date;
            l_scheduled_timezone_id := l_tar_score_rec.scheduled_timezone_id;
            wf_startprocess (
               p_score_id        => l_reference_rec.score_id,
               p_scheduled_date  => l_schedule_date,
               p_scheduled_timezone_id => l_scheduled_timezone_id,
               p_orig_status_id  => l_reference_rec.user_status_id,
               x_tar_score_rec   => l_tar_score_rec,
               x_return_status   => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := 'W';
               RETURN;
            END IF;
            -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
            -- to be displayed on a custom confirmation message.
            l_run_started := 'Y';
            l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_score_rec.wf_itemkey, 'NO');
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
            END IF;
         ELSE
           AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_NOT_AVAILABLE',
                                         p_token_name   => 'STATUS',
                                         p_token_value  => l_model_status) ;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSIF l_reference_rec.status_code = G_STATUS_SCHEDULED AND l_reference_rec.scheduled_date <> l_tar_score_rec.scheduled_date THEN

         -- First check that Model is still AVAILABLE
         wf_checkModelStatus ( p_score_id        => l_tar_score_rec.score_id,
                               x_return_status   => l_return_status,
                               x_model_status    => l_model_status
                             );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- First check that the target is enabled
	    AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_target_id,
			 x_is_enabled => l_is_enabled
			 );
            IF l_is_enabled = FALSE THEN
	       IF (AMS_DEBUG_HIGH_ON) THEN
	          AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot score');
	       END IF;
	       -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	       -- displayed to the user
	       x_return_status := 'T';
	       RETURN;
            END IF;
            AMS_WFMod_PVT.change_schedule (
               p_itemkey         => l_tar_score_rec.wf_itemkey,
               p_scheduled_date  => l_tar_score_rec.scheduled_date,
               p_scheduled_timezone_id => l_tar_score_rec.scheduled_timezone_id,
               x_new_itemkey     => l_tar_score_rec.wf_itemkey,
               x_return_status   => x_return_status
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               -- if we cannot change the schedule, may be the process has been purged,
               -- then we go ahead and submit a new process and get a new wf_itemkey
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Change schedule failed' );
                  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Going to start new build process' );
               END IF;

               -- Check that there is data selections for the Scoring Run
               -- We should not schedule the Run if there are no data selections
               dataToPreview (l_tar_score_rec.score_id, l_data_exists_flag);
               IF l_data_exists_flag = 'N' THEN
                  IF (AMS_DEBUG_HIGH_ON) THEN
                     AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Score');
                  END IF;
                  -- Set x_return_status to 'D' (for data error). This will results in a different message
                  -- displayed to the user
                  x_return_status := 'D';
                  RETURN;
               END IF;

               -- Set reference model status to DRAFT
               OPEN c_user_status_id (G_STATUS_TYPE_SCORE, G_DEFAULT_STATUS);
               FETCH c_user_status_id INTO l_user_status_id;
               CLOSE c_user_status_id;

               l_reference_rec.status_code      := G_DEFAULT_STATUS;
               l_reference_rec.user_status_id   := l_user_status_id;

               /* choang - 13-dec-2002 - added for nocopy */
               l_schedule_date := l_tar_score_rec.scheduled_date;
               l_scheduled_timezone_id := l_tar_score_rec.scheduled_timezone_id;
               -- Submit a Build request
               wf_startprocess (
                  p_score_id              => l_reference_rec.score_id,
                  p_scheduled_date        => l_schedule_date,
                  p_scheduled_timezone_id => l_scheduled_timezone_id,
                  p_orig_status_id        => l_reference_rec.user_status_id,
                  x_tar_score_rec         => l_tar_score_rec,
                  x_return_status         => x_return_status
               );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  x_return_status := 'W';
                  RETURN;
               END IF;
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' New Item Key ' || l_tar_score_rec.wf_itemkey);
               END IF;

            END IF;

            -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
            -- to be displayed on a custom confirmation message.
            l_run_started := 'Y';
            l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_score_rec.wf_itemkey, 'NO');
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
            END IF;
         ELSE
            AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_NOT_AVAILABLE',
                                         p_token_name   => 'STATUS',
                                         p_token_value  => l_model_status) ;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF l_reference_rec.status_code = G_STATUS_COMPLETED AND l_reference_rec.scheduled_date <> l_tar_score_rec.scheduled_date THEN
         -- First check that Model is still AVAILABLE
         wf_checkModelStatus ( p_score_id        => l_tar_score_rec.score_id,
                               x_return_status   => l_return_status,
                               x_model_status    => l_model_status
                             );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- First check that the target is enabled
	    AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_target_id,
			 x_is_enabled => l_is_enabled
			 );
            IF l_is_enabled = FALSE THEN
	       IF (AMS_DEBUG_HIGH_ON) THEN
	          AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot score');
	       END IF;
	       -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	       -- displayed to the user
	       x_return_status := 'T';
	       RETURN;
            END IF;
            -- Check that there is data selections for the Scoring Run
            -- We should not schedule the Run if there are no data selections
            dataToPreview (l_tar_score_rec.score_id, l_data_exists_flag);
            IF l_data_exists_flag = 'N' THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Score');
               END IF;
               -- Set x_return_status to 'D' (for data error). This will results in a different message
               -- displayed to the user
               x_return_status := 'D';
               RETURN;
            END IF;

            /* choang - 13-dec-2002 - added for nocopy */
            l_schedule_date := l_tar_score_rec.scheduled_date;
            l_scheduled_timezone_id := l_tar_score_rec.scheduled_timezone_id;
            wf_startprocess (
               p_score_id        => l_reference_rec.score_id,
               p_scheduled_date  => l_schedule_date,
               p_scheduled_timezone_id => l_scheduled_timezone_id,
               p_orig_status_id  => l_reference_rec.user_status_id,
               x_tar_score_rec   => l_tar_score_rec,
               x_return_status   => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := 'W';
               RETURN;
            END IF;

            -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
            -- to be displayed on a custom confirmation message.
            l_run_started := 'Y';
            l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_score_rec.wf_itemkey, 'NO');
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
            END IF;
         ELSE
           AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_NOT_AVAILABLE',
                                         p_token_name   => 'STATUS',
                                         p_token_value  => l_model_status) ;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSIF l_reference_rec.status_code = G_STATUS_PREVIEWING  AND l_reference_rec.scheduled_date <> FND_API.G_MISS_DATE THEN

         -- if the Scoring Run is PREVIEWING, then cancel the preview process first and set the Scoring Run status to DRAFT
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Scoring Run is currently previewing');
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Going to cancel Preview Process. Item Key ' || l_tar_score_rec.wf_itemkey);
         END IF;

         -- First check that Model is still AVAILABLE
         wf_checkModelStatus ( p_score_id        => l_tar_score_rec.score_id,
                               x_return_status   => l_return_status,
                               x_model_status    => l_model_status
                             );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            -- First check that the target is enabled
	    AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_target_id,
			 x_is_enabled => l_is_enabled
			 );
            IF l_is_enabled = FALSE THEN
	       IF (AMS_DEBUG_HIGH_ON) THEN
	          AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot score');
	       END IF;
	       -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	       -- displayed to the user
	       x_return_status := 'T';
	       RETURN;
            END IF;
            -- Check that there is data selections for the Scoring Run
            -- We should not schedule the Run if there are no data selections
            dataToPreview (l_tar_score_rec.score_id, l_data_exists_flag);
            IF l_data_exists_flag = 'N' THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Build');
               END IF;
               -- Set x_return_status to 'D' (for data error). This will results in a different message
               -- displayed to the user
               x_return_status := 'D';
               RETURN;
            END IF;

            AMS_WFMod_PVT.cancel_process (
               p_itemkey         => l_tar_score_rec.wf_itemkey,
               x_return_status   => x_return_status
            );

            -- Set reference Scoring Run status to DRAFT
            OPEN c_user_status_id (G_STATUS_TYPE_SCORE, G_DEFAULT_STATUS);
            FETCH c_user_status_id INTO l_user_status_id;
            CLOSE c_user_status_id;

            l_reference_rec.status_code      := G_DEFAULT_STATUS;
            l_reference_rec.user_status_id   := l_user_status_id;
            l_tar_score_rec.wf_itemkey       := NULL;

            -- Submit a Score Run request
            /* choang - 13-dec-2002 - added for nocopy */
            l_schedule_date := l_tar_score_rec.scheduled_date;
            l_scheduled_timezone_id := l_tar_score_rec.scheduled_timezone_id;
            wf_startprocess (
               p_score_id              => l_reference_rec.score_id,
               p_scheduled_date        => l_schedule_date,
               p_scheduled_timezone_id => l_scheduled_timezone_id,
               p_orig_status_id        => l_user_status_id,
               x_tar_score_rec         => l_tar_score_rec,
               x_return_status         => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := 'W';
               RETURN;
            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' New Item Key ' || l_tar_score_rec.wf_itemkey);
            END IF;

            -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
            -- to be displayed on a custom confirmation message.
            l_run_started := 'Y';
            l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_score_rec.wf_itemkey, 'NO');
            IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
            END IF;
         ELSE
           AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_NOT_AVAILABLE',
                                         p_token_name   => 'STATUS',
                                         p_token_value  => l_model_status) ;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;     -- flipped to scheduled

      -- Validate if data selections changed for a COMPLETED Scoring Run, and set the
      -- Scoring Run status to INVALID. Make sure that a Run has not been started as
      -- this will mess up the statuses
      IF ( l_reference_rec.status_code = G_STATUS_COMPLETED AND l_run_started = 'N') THEN

         check_data_size_changes (l_tar_score_rec,
                                  l_selections_changed_flag);

         IF l_selections_changed_flag = 'Y' THEN
            l_tar_score_rec.status_code := G_STATUS_INVALID;

            OPEN c_user_status_id (G_STATUS_TYPE_SCORE, l_tar_score_rec.status_code);
            FETCH c_user_status_id INTO l_tar_score_rec.user_status_id;
            CLOSE c_user_status_id;
         END IF;

      END IF;

      -- Validate next staus
      IF l_reference_rec.user_status_id <> l_tar_score_rec.user_status_id THEN
         OPEN c_status (l_tar_score_rec.user_status_id);
         FETCH c_status INTO l_tar_score_rec.status_code;
         CLOSE c_status;
         l_tar_score_rec.status_date := SYSDATE;

         -- ************************************************
         -- BGEORGE - added status order rule driven validation
         -- ************************************************
         AMS_DM_MODEL_PVT.Validate_next_status (
            p_curr_status        => l_reference_rec.status_code,
            p_next_status        => l_tar_score_rec.status_code,
            p_system_status_type => G_STATUS_TYPE_SCORE,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Score');
          END IF;

         -- Invoke validation procedures
         Validate_Score (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_update,
            p_score_rec          => l_tar_score_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
         );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_LOW_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler',FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      END IF;

      BEGIN
         -- Invoke table handler(AMS_DM_scoreS_B_PKG.Update_Row)
         AMS_DM_scoreS_B_PKG.Update_Row(
             p_score_ID             => l_tar_score_rec.score_id,
             p_LAST_UPDATE_DATE     => SYSDATE,
             p_LAST_UPDATED_BY      => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN    => FND_GLOBAL.CONC_LOGIN_ID,
             p_OBJECT_VERSION_NUMBER  => l_tar_score_rec.OBJECT_VERSION_NUMBER,
             p_MODEL_ID             => l_tar_score_rec.MODEL_ID,
             p_USER_STATUS_ID       => l_tar_score_rec.USER_STATUS_ID,
             p_STATUS_CODE          => l_tar_score_rec.status_code,
             p_STATUS_DATE          => l_tar_score_rec.status_date,
             p_OWNER_USER_ID        => l_tar_score_rec.OWNER_USER_ID,
             p_RESULTS_FLAG         => l_tar_score_rec.RESULTS_FLAG,
             p_logs_flag            => l_tar_score_rec.logs_flag,
             p_SCHEDULED_DATE       => l_tar_score_rec.SCHEDULED_DATE,
             p_SCHEDULED_TIMEZONE_ID   => l_tar_score_rec.SCHEDULED_TIMEZONE_ID,
             p_SCORE_DATE           => l_tar_score_rec.SCORE_DATE,
             p_total_records        => l_tar_score_rec.total_records,
             p_total_positives      => l_tar_score_rec.total_positives,
             p_EXPIRATION_DATE      => l_tar_score_rec.EXPIRATION_DATE,
             p_min_records          => l_tar_score_rec.min_records,
             p_max_records          => l_tar_score_rec.max_records,
             p_row_selection_type   => l_tar_score_rec.row_selection_type,
             p_every_nth_row        => l_tar_score_rec.every_nth_row,
             p_pct_random           => l_tar_score_rec.pct_random,
             p_custom_setup_id      => l_tar_score_rec.custom_setup_id,
             p_country_id           => l_tar_score_rec.country_id,
             p_wf_itemkey           => l_tar_score_rec.wf_itemkey,
             P_score_NAME           => l_tar_score_rec.score_NAME,
             p_DESCRIPTION          => l_tar_score_rec.DESCRIPTION,
             p_ATTRIBUTE_CATEGORY   => l_tar_score_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1           => l_tar_score_rec.ATTRIBUTE1,
             p_ATTRIBUTE2           => l_tar_score_rec.ATTRIBUTE2,
             p_ATTRIBUTE3           => l_tar_score_rec.ATTRIBUTE3,
             p_ATTRIBUTE4           => l_tar_score_rec.ATTRIBUTE4,
             p_ATTRIBUTE5           => l_tar_score_rec.ATTRIBUTE5,
             p_ATTRIBUTE6           => l_tar_score_rec.ATTRIBUTE6,
             p_ATTRIBUTE7           => l_tar_score_rec.ATTRIBUTE7,
             p_ATTRIBUTE8           => l_tar_score_rec.ATTRIBUTE8,
             p_ATTRIBUTE9           => l_tar_score_rec.ATTRIBUTE9,
             p_ATTRIBUTE10          => l_tar_score_rec.ATTRIBUTE10,
             p_ATTRIBUTE11          => l_tar_score_rec.ATTRIBUTE11,
             p_ATTRIBUTE12          => l_tar_score_rec.ATTRIBUTE12,
             p_ATTRIBUTE13          => l_tar_score_rec.ATTRIBUTE13,
             p_ATTRIBUTE14          => l_tar_score_rec.ATTRIBUTE14,
             p_ATTRIBUTE15          => l_tar_score_rec.ATTRIBUTE15
          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.G_EXC_ERROR;
      END;

       x_object_version_number := p_score_rec.object_version_number + 1;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count  =>   x_msg_count,
         p_data   =>   x_msg_data
      );

      -- If a Run process has been scheduled, then return the monitor_url in x_msg_data
      IF l_run_started = 'Y' THEN
         x_msg_data := l_monitor_url;
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Score_PVT;
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
End Update_Score;


PROCEDURE Delete_Score(
    p_api_version     IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_score_id             IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS

   CURSOR c_obj_version(c_id NUMBER) IS
   SELECT object_version_number
   FROM ams_dm_scores_all_b
    WHERE score_id = c_id;

   l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Score';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Score_PVT;

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

      Open c_obj_version(P_score_ID);

      Fetch c_obj_version into l_object_version_number;

       If ( c_obj_version%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'API_MISSING_DELETE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'dm_scores', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       Close     c_obj_version;

      --
      -- Api body
      --
      IF P_Object_Version_Number <> l_object_version_number THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
            FND_MESSAGE.Set_Token('INFO', 'dm_score', FALSE);
            FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      END IF;
      -- Debug Message
      -- Invoke table handler(AMS_DM_scoreS_B_PKG.Delete_Row)
      AMS_DM_scoreS_B_PKG.Delete_Row(
         p_score_ID  => p_score_id);
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

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Score_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Score_PVT;
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
End Delete_Score;


PROCEDURE check_score_uk_items(
    p_score_rec          IN   Score_Rec_Type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS

   l_valid_flag  VARCHAR2(1);

   CURSOR c_score_name
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_scores_vl
                     WHERE UPPER(score_name) = UPPER(p_score_rec.score_name)) ;
   CURSOR c_score_name_updt
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_scores_vl
                     WHERE UPPER(score_name) = UPPER(p_score_rec.score_name)
                     AND score_id <> p_score_rec.score_id );

   l_dummy NUMBER ;



BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API:check_Score_uk_items');
      END IF;

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_SCORES_ALL_B',
         'SCORE_ID = ''' || p_score_rec.score_id ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_scoreS_ALL_B',
         'score_ID = ''' || p_score_rec.score_id ||
         ''' AND score_ID <> ' || p_score_rec.score_id
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_DUP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      --Validate unique score_name
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         OPEN c_score_name ;
         FETCH c_score_name INTO l_dummy;
         CLOSE c_score_name ;
      ELSE
         OPEN c_score_name_updt ;
         FETCH c_score_name_updt INTO l_dummy;
         CLOSE c_score_name_updt ;
      END IF;

     IF l_dummy IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SCORE_DUPLICATE_NAME');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_Score_uk_items;


PROCEDURE check_Score_req_items(
    p_score_rec            IN  Score_Rec_Type,
    p_validation_mode         IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_Score_req_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:mode ' || p_validation_mode);
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: id ' || p_score_rec.score_id);
      END IF;
      IF p_score_rec.model_id = FND_API.g_miss_num
     OR p_score_rec.model_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_MOD_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_score_rec.user_status_id = FND_API.g_miss_num
   OR p_score_rec.user_status_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_USR_STAT_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_score_rec.owner_user_id = FND_API.g_miss_num
   OR p_score_rec.owner_user_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_OWNER_USR_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_score_rec.score_name = FND_API.g_miss_char
   OR p_score_rec.score_name IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_NAME');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE  -- update operation
      IF p_score_rec.score_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_score_rec.object_version_number IS NULL OR p_score_rec.object_version_number = FND_API.G_MISS_NUM THEN
         AMS_Utility_PVT.error_message ('AMS_SCORE_NO_OBJECT_VERSION');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_score_rec.model_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_MOD_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_score_rec.user_status_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_USR_STAT_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_score_rec.owner_user_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_NO_OWNER_USR_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_Score_req_items;

PROCEDURE check_score_fk_items(
    p_score_rec      IN Score_Rec_Type,
    x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_Score_fk_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   --------------------model_id---------------------------
   IF p_score_rec.model_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'AMS_DM_MODELS_ALL_B',
            'MODEL_ID',
            p_score_rec.model_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_BAD_MOD_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --------------------- user_status_id ------------------------
   IF p_score_rec.user_status_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'AMS_USER_STATUSES_B',
            'USER_STATUS_ID',
            p_score_rec.user_status_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_BAD_USR_STAT_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_Score_FK_items;

PROCEDURE check_dm_mdl_scr_lookup_items(
    p_score_rec IN Score_Rec_Type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_Score_lookup_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

------------------ status_code ----------------------------------
  IF p_score_rec.status_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => G_STATUS_TYPE_SCORE,
             p_lookup_code => p_score_rec.status_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DM_SCORE_BAD_STAT_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_dm_mdl_scr_Lookup_items;

PROCEDURE Check_Score_Items (
    p_score_rec     IN    Score_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_Score_uk_items(
      p_score_rec => p_score_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_Score_req_items(
      p_score_rec => p_score_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_Score_FK_items(
      p_score_rec => p_score_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups

   check_dm_mdl_scr_Lookup_items(
      p_score_rec => p_score_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Start add rosharma 28-Nov-2002
   -- Min records should be number and more than 0, if entered
   IF p_score_rec.min_records IS NOT NULL AND
      p_score_rec.min_records <> FND_API.g_miss_num THEN
      DECLARE
         l_min_rec       NUMBER;
      BEGIN
         l_min_rec := TO_NUMBER (p_score_rec.min_records);
	 IF l_min_rec < 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NEGATIVE_NUMBER' , 'FIELD' , 'MIN_RECORDS');
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	 END IF;
      EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_NOT_NUMBER' , 'FIELD' , 'MIN_RECORDS');
               x_return_status := FND_API.G_RET_STS_ERROR;
	       RETURN;
      END;
   END IF;

   -- Max records should be number and more than 0, if entered
   IF p_score_rec.max_records IS NOT NULL AND
      p_score_rec.max_records <> FND_API.g_miss_num THEN
      DECLARE
         l_max_rec       NUMBER;
      BEGIN
         l_max_rec := TO_NUMBER (p_score_rec.max_records);
	 IF l_max_rec < 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NEGATIVE_NUMBER' , 'FIELD' , 'MAX_RECORDS');
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	 END IF;
      EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_NOT_NUMBER' , 'FIELD' , 'MAX_RECORDS');
               x_return_status := FND_API.G_RET_STS_ERROR;
	       RETURN;
      END;
   END IF;
   -- End add rosharma 28-Nov-2002

END Check_Score_Items;


PROCEDURE Complete_Score_Rec (
   p_score_rec    IN Score_Rec_Type,
   x_complete_rec OUT NOCOPY Score_Rec_Type
)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_scores_vl
      WHERE score_id = p_score_rec.score_id;
   l_score_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_score_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_score_rec;
   CLOSE c_complete;

   -- score_id
   IF p_score_rec.score_id = FND_API.g_miss_num THEN
      x_complete_rec.score_id := l_score_rec.score_id;
   END IF;

   -- org_id
   IF p_score_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_score_rec.org_id;
   END IF;

   -- model_id
   IF p_score_rec.model_id = FND_API.g_miss_num THEN
      x_complete_rec.model_id := l_score_rec.model_id;
   END IF;

   -- user_status_id
   IF p_score_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_score_rec.user_status_id;
   END IF;

   -- status_code
   IF p_score_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_score_rec.status_code;
   END IF;

   -- status_date
   IF p_score_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := l_score_rec.status_date;
   END IF;

   -- owner_user_id
   IF p_score_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_score_rec.owner_user_id;
   END IF;

   -- results_flag
   IF p_score_rec.results_flag = FND_API.g_miss_char THEN
      x_complete_rec.results_flag := l_score_rec.results_flag;
   END IF;

   -- logs_flag
   IF p_score_rec.logs_flag = FND_API.g_miss_char THEN
      x_complete_rec.logs_flag := l_score_rec.logs_flag;
   END IF;

   -- scheduled_date
   IF p_score_rec.scheduled_date = FND_API.g_miss_date THEN
      x_complete_rec.scheduled_date := l_score_rec.scheduled_date;
   END IF;

   -- scheduled_timezone_id
   IF p_score_rec.scheduled_timezone_id = FND_API.g_miss_num THEN
      x_complete_rec.scheduled_timezone_id := l_score_rec.scheduled_timezone_id;
   END IF;

   -- score_date
   IF p_score_rec.score_date = FND_API.g_miss_date THEN
      x_complete_rec.score_date := l_score_rec.score_date;
   END IF;

   -- expiration_date
   IF p_score_rec.expiration_date = FND_API.g_miss_date THEN
      x_complete_rec.expiration_date := l_score_rec.expiration_date;
   END IF;

   -- total_records
   IF p_score_rec.total_records = FND_API.g_miss_num THEN
      x_complete_rec.total_records := l_score_rec.total_records;
   END IF;

   -- total_positives
   IF p_score_rec.total_positives = FND_API.g_miss_num THEN
      x_complete_rec.total_positives := l_score_rec.total_positives;
   END IF;

   -- min_records
   IF p_score_rec.min_records = FND_API.g_miss_num THEN
      x_complete_rec.min_records := l_score_rec.min_records;
   END IF;

   -- max_records
   IF p_score_rec.max_records = FND_API.g_miss_num THEN
      x_complete_rec.max_records := l_score_rec.max_records;
   END IF;

   -- row_selection_type
   IF p_score_rec.row_selection_type = FND_API.g_miss_char THEN
      x_complete_rec.row_selection_type := l_score_rec.row_selection_type;
   END IF;

   -- every_nth_row
   IF p_score_rec.every_nth_row = FND_API.g_miss_num THEN
      x_complete_rec.every_nth_row := l_score_rec.every_nth_row;
   END IF;

   -- pct_random
   IF p_score_rec.pct_random = FND_API.g_miss_num THEN
      x_complete_rec.pct_random := l_score_rec.pct_random;
   END IF;

   -- custom_setup_id
   IF p_score_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_score_rec.custom_setup_id;
   END IF;

   -- country_id
   IF p_score_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := l_score_rec.country_id;
   END IF;

   -- attribute_category
   IF p_score_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_score_rec.attribute_category;
   END IF;

   -- score_name
   IF p_score_rec.score_name = FND_API.g_miss_char THEN
      x_complete_rec.score_name := l_score_rec.score_name;
   END IF;

   -- description
   IF p_score_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_score_rec.description;
   END IF;

   -- attribute1
   IF p_score_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_score_rec.attribute1;
   END IF;

   -- attribute2
   IF p_score_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_score_rec.attribute2;
   END IF;

   -- attribute3
   IF p_score_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_score_rec.attribute3;
   END IF;

   -- attribute4
   IF p_score_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_score_rec.attribute4;
   END IF;

   -- attribute5
   IF p_score_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_score_rec.attribute5;
   END IF;

   -- attribute6
   IF p_score_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_score_rec.attribute6;
   END IF;

   -- attribute7
   IF p_score_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_score_rec.attribute7;
   END IF;

   -- attribute8
   IF p_score_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_score_rec.attribute8;
   END IF;

   -- attribute9
   IF p_score_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_score_rec.attribute9;
   END IF;

   -- attribute10
   IF p_score_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_score_rec.attribute10;
   END IF;

   -- attribute11
   IF p_score_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_score_rec.attribute11;
   END IF;

   -- attribute12
   IF p_score_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_score_rec.attribute12;
   END IF;

   -- attribute13
   IF p_score_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_score_rec.attribute13;
   END IF;

   -- attribute14
   IF p_score_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_score_rec.attribute14;
   END IF;

   -- attribute15
   IF p_score_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_score_rec.attribute15;
   END IF;

   -- wf_itemkey
   IF p_score_rec.wf_itemkey = FND_API.g_miss_char THEN
      x_complete_rec.wf_itemkey := l_score_rec.wf_itemkey;
   END IF;
END Complete_Score_Rec;

PROCEDURE Validate_Score (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode   IN   VARCHAR2,
    p_score_rec         IN   Score_Rec_Type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Score';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Score_;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

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

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_Score_Items(
            p_score_rec       => p_score_rec,
            p_validation_mode => p_validation_mode,
            x_return_status   => x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
         Validate_Score_Rec(
            p_api_version     => 1.0,
            p_init_msg_list   => FND_API.G_FALSE,
            p_validation_mode => p_validation_mode,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_score_rec       => p_score_rec
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
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
     ROLLBACK TO VALIDATE_Score_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Score_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Score_;
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
End Validate_Score;


PROCEDURE Validate_Score_rec (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_mode IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_Score_rec       IN Score_Rec_Type
)
IS
   l_context_resource_id      NUMBER;
   l_is_owner                 VARCHAR2(1);

   -- add to select list as needed
   CURSOR c_reference (p_score_id IN NUMBER) IS
      SELECT owner_user_id
      FROM   ams_dm_scores_all_b
      WHERE  score_id = p_score_id;
   l_reference_rec      c_reference%ROWTYPE;
BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
      l_context_resource_id := AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);

      OPEN c_reference(p_score_rec.score_id);
      FETCH c_reference INTO l_reference_rec;
      CLOSE c_reference;

      check_access (
         p_score_rec       => p_score_rec,
         x_return_status   => x_return_status
      );

      -- the owner in the context needs to be the
      -- same as the owner of the record in order
      -- for owner to be changed
      IF l_reference_rec.owner_user_id <> p_score_rec.owner_user_id THEN
         l_is_owner := AMS_Access_PVT.check_owner (
                           p_object_type  => G_OBJECT_TYPE_SCORE,
                           p_object_id    => p_score_rec.score_id,
                           p_user_or_role_type  => 'USER',
                           p_user_or_role_id    => l_context_resource_id
                       );

         IF l_is_owner = 'N' AND NOT AMS_Access_PVT.Check_Admin_Access(l_context_resource_id) THEN
            AMS_Utility_PVT.error_message ('AMS_PRIC_UPDT_OWNER_PERM');
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;
   END IF;

   -- Start add rosharma 28-Nov-2002
   -- Max records must be more than Min records, if both are entered
   IF p_score_rec.min_records IS NOT NULL AND
      p_score_rec.min_records <> FND_API.g_miss_num AND
      p_score_rec.max_records IS NOT NULL AND
      p_score_rec.max_records <> FND_API.g_miss_num THEN
      DECLARE
         l_min_rec       NUMBER;
         l_max_rec       NUMBER;
      BEGIN
         l_min_rec := TO_NUMBER (p_score_rec.min_records);
         l_max_rec := TO_NUMBER (p_score_rec.max_records);
         IF l_max_rec < l_min_rec THEN
            AMS_Utility_PVT.error_message ('AMS_DM_MIN_MORE_THAN_MAX');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      END;
   END IF;

   -- If selection is every Nth row, there must be a value in number of rows
   -- and it must be greater than 0
   IF p_score_rec.row_selection_type = 'NTH_RECORD' THEN
      IF p_score_rec.every_nth_row IS NULL OR
         p_score_rec.every_nth_row = FND_API.g_miss_num THEN
         AMS_Utility_PVT.error_message ('AMS_DM_NO_NTH_RECORD');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
      --check for valid number
      DECLARE
         l_nth_row       NUMBER;
      BEGIN
         l_nth_row := ROUND(TO_NUMBER (p_score_rec.every_nth_row));
         IF l_nth_row <= 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_INVALID_NTH_ROW');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_NOT_NUMBER' , 'FIELD' , 'EVERY_NTH_ROW');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
      END;
   END IF;

   -- If selection is random, there must be a value in random percentage
   -- and it must be between 0 and 100
   IF p_score_rec.row_selection_type = 'RANDOM' THEN
      IF p_score_rec.pct_random IS NULL OR
         p_score_rec.pct_random = FND_API.g_miss_num THEN
         AMS_Utility_PVT.error_message ('AMS_DM_NO_PCT_RANDOM');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
      --check for valid number
      DECLARE
         l_pct_random       NUMBER;
      BEGIN
         l_pct_random := TO_NUMBER (p_score_rec.pct_random);
         IF l_pct_random <= 0 OR l_pct_random > 100 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_INVALID_PCT_RANDOM');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_NOT_NUMBER' , 'FIELD' , 'PCT_RANDOM');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
      END;
   END IF;
   -- End add rosharma 28-Nov-2002

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
END Validate_Score_Rec;

PROCEDURE check_access (
   p_score_rec       IN score_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_ACCESS_TYPE_USER      CONSTANT VARCHAR2(30) := 'USER';
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (AMS_DEBUG_HIGH_ON) THEN



ams_utility_pvt.debug_message ('score id: ' || p_score_rec.score_id || ' owner: ' || fnd_global.user_id);

END IF;
   -- validate access privileges
   IF AMS_Access_PVT.check_update_access (
         p_object_id       => p_score_rec.score_id,
         p_object_type     => G_OBJECT_TYPE_SCORE,
         p_user_or_role_id => AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id),
         p_user_or_role_type  => L_ACCESS_TYPE_USER) = 'N' THEN
      AMS_Utility_PVT.error_message ('AMS_SCOR_NO_UPDATE_ACCESS');
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END check_access;


PROCEDURE wf_revert (
   p_score_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
   l_model_status_id    NUMBER;

   CURSOR c_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM ams_dm_scores_all_b
      WHERE score_id = p_score_id
      ;
   l_score_rec       c_score%ROWTYPE;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_score (p_score_id);
   FETCH c_score INTO l_score_rec;
   CLOSE c_score;

   -- set the model that it used for scoring
   -- back to AVAILABLE -- the model was changed
   -- to scoring when scoring began
   --
   -- first check that the model isn't used by other
   -- scoring instances for scoring.
   IF model_used_for_scoring (l_score_rec.model_id, p_score_id) = FND_API.G_FALSE THEN
      OPEN c_user_status_id (G_STATUS_TYPE_MODEL, G_STATUS_AVAILABLE);
      FETCH c_user_status_id INTO l_model_status_id;
      CLOSE c_user_status_id;

      UPDATE ams_dm_models_all_b
      SET    last_update_date = SYSDATE
           , last_updated_by = FND_GLOBAL.user_id
           , last_update_login = FND_GLOBAL.conc_login_id
           , object_version_number = object_version_number + 1
           , status_code = G_STATUS_AVAILABLE
           , user_status_id = l_model_status_id
           , status_date = SYSDATE
      WHERE model_id = l_score_rec.model_id;
   END IF;

   -- set the scoring run status to p_status_code (Available or Failed)
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, p_status_code);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_scores_all_b
   SET    last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.conc_login_id
        , object_version_number = object_version_number + 1
        , status_code = p_status_code
        , user_status_id = l_user_status_id
        , status_date = SYSDATE
   WHERE  score_id = p_score_id;
END wf_revert;


PROCEDURE process_score_success (
   p_score_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
   l_model_status_id    NUMBER;

   CURSOR c_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_all_b
      WHERE score_id = p_score_id
      ;
   l_score_rec       c_score%ROWTYPE;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_score (p_score_id);
   FETCH c_score INTO l_score_rec;
   CLOSE c_score;

   -- set the model that it used for scoring
   -- back to AVAILABLE -- the model was changed
   -- to scoring when scoring began
   --
   -- first check that the model isn't used by other
   -- scoring instances for scoring.
   IF model_used_for_scoring (l_score_rec.model_id, p_score_id) = FND_API.G_FALSE THEN
      OPEN c_user_status_id (G_STATUS_TYPE_MODEL, G_STATUS_AVAILABLE);
      FETCH c_user_status_id INTO l_model_status_id;
      CLOSE c_user_status_id;

      UPDATE ams_dm_models_all_b
      SET    last_update_date = SYSDATE
           , last_updated_by = FND_GLOBAL.user_id
           , last_update_login = FND_GLOBAL.conc_login_id
           , object_version_number = object_version_number + 1
           , status_code = G_STATUS_AVAILABLE
           , user_status_id = l_model_status_id
           , status_date = SYSDATE
      WHERE model_id = l_score_rec.model_id;
   END IF;

   -- make the scoring run AVAILABLE for list creation.
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, p_status_code);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_scores_all_b
   SET    object_version_number = object_version_number + 1
        , last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , status_date = SYSDATE
        , status_code = p_status_code
        , user_status_id = l_user_status_id
        , score_date = SYSDATE
        , results_flag = 'Y'
   WHERE  score_id = p_score_id;
END process_score_success;


-- History
-- 04-Oct-2002 nyostos   Created.
-- Overloaded procedure. New implementation in 11.5.9 to start
-- the Build/Score/Preview Workflow process to handle Preview instead of
-- starting the AMS_DM_PREVIEW concurrent program.

PROCEDURE handle_preview_request (
   p_score_id        IN NUMBER,
   x_monitor_url     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_SCORE_QUALIFIER       CONSTANT VARCHAR2(30) := 'SCOR';
   L_ACCESS_TYPE_USER      CONSTANT VARCHAR2(30) := 'USER';
   l_owner_user_id         NUMBER := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);

   l_proceedWithPreviewFlag VARCHAR2(1);
   l_data_exists_flag       VARCHAR2(1);
   l_target_id              NUMBER;
   l_is_enabled             BOOLEAN;

   CURSOR c_ref_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;

   CURSOR c_target (p_score_id IN NUMBER) IS
      SELECT m.target_id from ams_dm_models_all_b m,ams_dm_scores_all_b s
      WHERE  m.model_id = s.model_id
      AND    s.score_id = p_score_id
      ;

   l_ref_score_rec      c_ref_score%ROWTYPE;

   l_tar_score_rec      ams_dm_score_pvt.score_rec_type;

   L_API_NAME        CONSTANT VARCHAR2(30) := 'handle_preview_request';

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Load the scoring run record to get the original status
   OPEN c_ref_score (p_score_id);
   FETCH c_ref_score INTO l_ref_score_rec;
   CLOSE c_ref_score;

   --First check if the user has access to preview operation
   IF AMS_Access_PVT.check_update_access (
         p_object_id       => p_score_id,
         p_object_type     => L_SCORE_QUALIFIER,
         p_user_or_role_id => l_owner_user_id,
         p_user_or_role_type  => L_ACCESS_TYPE_USER) = 'N' THEN
      x_return_status := 'A';
      return;
   END IF;

   -- Check if the target is enabled
   OPEN c_target(p_score_id);
   FETCH c_target INTO l_target_id;
   CLOSE c_target;

   AMS_DM_TARGET_PVT.is_target_enabled(
                 p_target_id  => l_target_id ,
		 x_is_enabled => l_is_enabled
		 );
   IF l_is_enabled = FALSE THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot preview');
      END IF;
      -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
      -- displayed to the user
      x_return_status := 'T';
      RETURN;
   END IF;

   -- Check if the Preview operation can be started
   proceedWithPreview (p_score_id, l_proceedWithPreviewFlag);
   IF l_proceedWithPreviewFlag = 'N' THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Cannot Proceed with Preview');
      END IF;
      -- Set x_return_status to expected error. This will results in a different message
      -- displayed to the user
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   dataToPreview (p_score_id, l_data_exists_flag);
   IF l_data_exists_flag = 'N' THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Preview');
      END IF;
      -- Set x_return_status to 'D' (for data error). This will results in a different message
      -- displayed to the user
      x_return_status := 'D';
      RETURN;
   END IF;

   wf_startPreviewProcess (
      p_score_id        => p_score_id,
      p_orig_status_id  => l_ref_score_rec.user_status_id,
      x_tar_score_rec   => l_tar_score_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Error from wf_startPreviewProcess');
      END IF;
      -- Set x_return_status to unexpected error. This will results in a different message
      -- displayed to the user
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
   -- to be displayed on a custom confirmation message.
   x_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_score_rec.wf_itemkey, 'NO');

   -- Update the Scoring Run record with the new status code (PREVIEWING) and Id
   -- and also with the WF Item Key
   UPDATE ams_dm_scores_all_b
   SET logs_flag              = 'Y',
       object_version_number  = object_version_number + 1,
       last_update_date       = SYSDATE,
       last_updated_by        = FND_GLOBAL.user_id,
       status_date            = SYSDATE,
       status_code            = l_tar_score_rec.status_code,
       user_status_id         = l_tar_score_rec.user_status_id,
       wf_itemkey             = l_tar_score_rec.wf_itemkey
   WHERE score_id = p_score_id;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

END handle_preview_request;




--
-- History
-- 11-Mar-2001 choang   Created.
-- 04-Oct-2002 nyostos  This procedure has been deprecated in 11.5.9. It
--                      is left for backward compatibility. It calls the
--                      overloaded handle_preview_request which starts
--                      the build/score workflow process instead of starting
--                      the AMS_DM_PREVIEW Concurrent Program.
PROCEDURE handle_preview_request (
   p_score_id     IN NUMBER,
   x_request_id   OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_monitor_url  VARCHAR2(1);

BEGIN

   handle_preview_request ( p_score_id,
                            l_monitor_url,
                            x_return_status);

   x_request_id := 0;
END handle_preview_request;


--
-- Note
-- Copy is broken into 4 sections:
--    - copy all required fields of the object
--    - copy all fields passed in thru the UI, but
--      use the value of the base object if the field
--      isn't passed through the UI
--    - copy all fields passed in thru the UI, but
--      leave the field as null if it isn't passed in
--    - copy all attributes passed in from the UI
--
-- History
-- 07-Apr-2001 choang   Created.
-- 26-Apr-2001 sveerave Changed column names to be of application column names from db column names
--                      in get_column_value call-out.

PROCEDURE copy_score (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_source_object_id   IN NUMBER,
   p_attributes_table   IN AMS_CpyUtility_PVT.copy_attributes_table_type,
   p_copy_columns_table IN AMS_CpyUtility_PVT.copy_columns_table_type,
   x_new_object_id      OUT NOCOPY NUMBER,
   x_custom_setup_id    OUT NOCOPY NUMBER
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_score';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;

   l_new_score_id    NUMBER;
   l_score_rec       score_rec_type;

   -- for non-standard out params in copy_act_access
   l_errnum          NUMBER;
   l_errcode         VARCHAR2(30);
   l_errmsg          VARCHAR2(4000);

   CURSOR c_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;
   --start changes rosharma 20-aug-2003 bug 3104201
   CURSOR c_data_source (p_model_id IN NUMBER) IS
      SELECT t.DATA_SOURCE_ID , t.target_id
      FROM   ams_dm_models_all_b m,ams_dm_targets_b t
      WHERE  m.model_id = p_model_id
      AND    m.target_id = t.target_id
      ;

   l_ds_id    NUMBER;
   --end changes rosharma 20-aug-2003 bug 3104201
   l_target_id          NUMBER;
   l_reference_rec      c_score%ROWTYPE;
   l_new_score_rec      c_score%ROWTYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT ams_score_pvt_copy_score;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body.
   --
   -- Initialize the new score record
   -- use ams_cpyutility_pvt.get_column_value to fetch a value
   -- to replace the reference column value with a new value
   -- passed in from the UI through p_copy_columns_table.
   OPEN c_score (p_source_object_id);
   FETCH c_score INTO l_reference_rec;
   CLOSE c_score;

   -- copy all required fields
   l_score_rec.status_code := 'DRAFT';
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, l_score_rec.status_code);
   FETCH c_user_status_id INTO l_score_rec.user_status_id;
   CLOSE c_user_status_id;
   l_score_rec.row_selection_type := l_reference_rec.row_selection_type;

   --added rosharma 10-Feb-2003 for copying pct_random and nth_row correctly
   IF l_score_rec.row_selection_type = 'NTH_RECORD' THEN
      l_score_rec.every_nth_row := l_reference_rec.every_nth_row;
   END IF;

   IF l_score_rec.row_selection_type = 'RANDOM' THEN
      l_score_rec.pct_random := l_reference_rec.pct_random;
   END IF;
   --end add rosharma 10-Feb-2003 for copying pct_random and nth_row correctly
   --added rosharma 04-sep-2003 bug # 3127555
   l_score_rec.min_records := l_reference_rec.min_records;
   l_score_rec.max_records := l_reference_rec.max_records;
   --end add rosharma 04-sep-2003 bug # 3127555

   -- copy flex field data. fix for 4220828
   l_score_rec.attribute_category  := l_reference_rec.attribute_category;
   l_score_rec.attribute1  := l_reference_rec.attribute1;
   l_score_rec.attribute2  := l_reference_rec.attribute2;
   l_score_rec.attribute3  := l_reference_rec.attribute3;
   l_score_rec.attribute4  := l_reference_rec.attribute4;
   l_score_rec.attribute5  := l_reference_rec.attribute5;
   l_score_rec.attribute6  := l_reference_rec.attribute6;
   l_score_rec.attribute7  := l_reference_rec.attribute7;
   l_score_rec.attribute8  := l_reference_rec.attribute8;
   l_score_rec.attribute9  := l_reference_rec.attribute9;
   l_score_rec.attribute10 := l_reference_rec.attribute10;
   l_score_rec.attribute11 := l_reference_rec.attribute11;
   l_score_rec.attribute12 := l_reference_rec.attribute12;
   l_score_rec.attribute13 := l_reference_rec.attribute13;
   l_score_rec.attribute14 := l_reference_rec.attribute14;
   l_score_rec.attribute15 := l_reference_rec.attribute15;

   -- if field is not passed in from copy_columns_table
   -- copy from the base object
   -- owner_user_id
   AMS_CpyUtility_PVT.get_column_value ('owner_user_id', p_copy_columns_table, l_score_rec.owner_user_id);
   l_score_rec.owner_user_id := NVL (l_score_rec.owner_user_id, l_reference_rec.owner_user_id);
   -- model_id
   AMS_CpyUtility_PVT.get_column_value ('model_id', p_copy_columns_table, l_score_rec.model_id);
   l_score_rec.model_id := NVL (l_score_rec.model_id, l_reference_rec.model_id);

   -- if field is not passed in from copy_columns_table
   -- don't copy
   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_score_rec.score_name);
   AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_score_rec.description);
   --AMS_CpyUtility_PVT.get_column_value ('mainRandNthRowSel', p_copy_columns_table, l_score_rec.every_nth_row);
   --AMS_CpyUtility_PVT.get_column_value ('mainRandPctRowSel', p_copy_columns_table, l_score_rec.pct_random);
   --commented rosharma 04-sep-2003 bug # 3127555
   --AMS_CpyUtility_PVT.get_column_value ('minRequested', p_copy_columns_table, l_score_rec.min_records);
   --AMS_CpyUtility_PVT.get_column_value ('maxRequested', p_copy_columns_table, l_score_rec.max_records);
   --end comment rosharma 04-sep-2003 bug # 3127555

   AMS_DM_Score_PVT.create_score (
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   => p_validation_level,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_score_rec       => l_score_rec,
      x_custom_setup_id => x_custom_setup_id,
      x_score_id        => l_new_score_id
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- copy data selections

   -- 01-May-2003 nyostos  Fixed copying of Data Selections Bug 2934000
   -- Used G_ATTRIBUTE_SELC instead of G_ATTRIBUTE_TRNG
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_CopyElements_PVT.G_ATTRIBUTE_SELC, p_attributes_table) = FND_API.G_TRUE THEN
      --start changes rosharma 20-aug-2003 bug 3104201
      OPEN c_data_source (l_reference_rec.model_id);
       FETCH c_data_source INTO l_ds_id , l_target_id;
      CLOSE c_data_source;
      -- Fix for bug 4357993. Workbook has to be copied for Custom score also.
      AMS_CopyElements_PVT.copy_list_select_actions (
          p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_FALSE,
          p_commit          => FND_API.G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_object_type     => G_OBJECT_TYPE_SCORE,
          p_src_object_id   => p_source_object_id,
          p_tar_object_id   => l_new_score_id
      );

      IF l_target_id >= G_SEEDED_ID_THRESHOLD THEN
         AMS_Adv_Filter_PVT.copy_filter_data (
		   p_api_version        => 1.0,
		   p_init_msg_list      => FND_API.G_FALSE,
		   p_commit             => FND_API.G_FALSE,
		   p_validation_level   => p_validation_level,
		   p_objType            => G_OBJECT_TYPE_SCORE,
		   p_old_objectId       => p_source_object_id,
		   p_new_objectId       => l_new_score_id,
		   p_dataSourceId       => l_ds_id,
		   x_return_status      => x_return_status,
		   x_msg_count          => x_msg_count,
		   x_msg_data           => x_msg_data
         );
      --end changes rosharma 20-aug-2003 bug 3104201
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy team
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_CopyElements_PVT.G_ATTRIBUTE_TEAM, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_access (
         p_src_act_type   => G_OBJECT_TYPE_SCORE,
         p_new_act_type   => G_OBJECT_TYPE_SCORE,
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_score_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
   END IF;

   -- currently, only needed to fetch custom_setup_id
   -- but can be used to return other values later.
   OPEN c_score (l_new_score_id);
   FETCH c_score INTO l_new_score_rec;
   CLOSE c_score;

   x_new_object_id := l_new_score_id;
--   x_custom_setup_id := l_new_score_rec.custom_setup_id;
   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ams_score_pvt_copy_score;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ams_score_pvt_copy_score;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO ams_score_pvt_copy_score;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
END copy_score;


PROCEDURE wf_score (
   p_score_id        IN NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
   l_model_status_id    NUMBER;

   CURSOR c_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_all_b
      WHERE  model_id = p_model_id;
   l_model_rec       c_model%ROWTYPE;

   CURSOR c_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_all_b
      WHERE score_id = p_score_id;
   l_score_rec       c_score%ROWTYPE;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_score (p_score_id);
   FETCH c_score INTO l_score_rec;
   CLOSE c_score;

   OPEN c_model (l_score_rec.model_id);
   FETCH c_model INTO l_model_rec;
   CLOSE c_model;

   -- if the model is not AVAILABLE or being used in SCORING, then
   -- it cannot be used for scoring.
   IF l_model_rec.status_code NOT IN (G_STATUS_AVAILABLE, G_STATUS_SCORING) THEN
      x_status_code := G_DEFAULT_STATUS;  -- draft
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
   END IF;
   x_status_code := G_STATUS_SCORING;

   -- When the Scoring Run status is SCORING, then we cleanup previous
   -- Scoring Run results.
   cleanupPreviousScoreData(p_score_id);

   -- update the model to indicate that it is
   -- being used to score a data set
   OPEN c_user_status_id (G_STATUS_TYPE_MODEL, G_STATUS_SCORING);
   FETCH c_user_status_id INTO l_model_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_models_all_b
   SET    last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.conc_login_id
        , object_version_number = object_version_number + 1
        , status_code = G_STATUS_SCORING
        , user_status_id = l_model_status_id
        , status_date = SYSDATE
   WHERE model_id = l_model_rec.model_id;

   -- set the scoring run status to scoring
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, G_STATUS_SCORING);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_scores_all_b
   SET    last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.conc_login_id
        , object_version_number = object_version_number + 1
        , status_code = G_STATUS_SCORING
        , user_status_id = l_user_status_id
        , status_date = SYSDATE
   WHERE  score_id = p_score_id;
END wf_score;

--
-- Purpose
--    Indicates whether a model is being used for
--    scoring.
-- History
-- 12-Apr-2001 choang   Created.
FUNCTION model_used_for_scoring (
   p_model_id           IN NUMBER,
   p_current_score_id   IN NUMBER
) RETURN VARCHAR2
IS
   l_dummy     NUMBER;

   CURSOR c_scoring_model IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_dm_scores_all_b
                    WHERE  model_id = p_model_id
                    AND    status_code = G_STATUS_SCORING
                    AND    score_id <> p_current_score_id)
      ;
BEGIN
   OPEN c_scoring_model;
   FETCH c_scoring_model INTO l_dummy;
   CLOSE c_scoring_model;

   IF l_dummy = 1 THEN
      RETURN FND_API.G_TRUE;
   END IF;

   RETURN FND_API.G_FALSE;
END model_used_for_scoring;


PROCEDURE wf_startprocess (
   p_score_id IN NUMBER,
   p_scheduled_date IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_score_rec IN OUT NOCOPY score_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   -- used with get_user_timezone api
   l_user_timezone_name    VARCHAR2(80);
BEGIN
   IF p_scheduled_timezone_id IS NULL THEN
      AMS_Utility_PVT.get_user_timezone (
         x_return_status   => x_return_status,
         x_user_time_id    => x_tar_score_rec.scheduled_timezone_id,
         x_user_time_name  => l_user_timezone_name
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      x_tar_score_rec.scheduled_timezone_id := p_scheduled_timezone_id;
   END IF;

   x_tar_score_rec.status_code := G_STATUS_SCHEDULED;
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, x_tar_score_rec.status_code);
   FETCH c_user_status_id INTO x_tar_score_rec.user_status_id;
   CLOSE c_user_status_id;

   -- Initiate Workflow process and grab the itemkey
   AMS_WFMOD_PVT.StartProcess(
      p_object_id       => p_score_id,
      p_object_type     => G_OBJECT_TYPE_SCORE,
      p_user_status_id  => p_orig_status_id,
      p_scheduled_timezone_id => x_tar_score_rec.scheduled_timezone_id,
      p_scheduled_date  => p_scheduled_date,
      p_request_type    => NULL,
      p_select_list     => NULL,
      x_itemkey         => x_tar_score_rec.wf_itemkey
   );

   IF x_tar_score_rec.wf_itemkey IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END wf_startprocess;


-- History
-- 04-Oct-2002 nyostos   Created.
-- Cancels the Score workflow process. If the Scoring Run is in SCHEDULED.
-- state (i.e. the first step in the WF process has not started yet),
-- the Scoring Run status will be reverted to its previous status.
-- If the Scoring status is SCORING (i.e. the Workflow process is in progress),
-- then the Scoring Run status will be set to DRAFT.

PROCEDURE cancel_run_request (
   p_score_id           IN NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_ref_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;
   l_ref_score_rec      c_ref_score%ROWTYPE;

   L_API_NAME           CONSTANT VARCHAR2(30) := 'cancel_run_request';

   l_original_status_id    VARCHAR2(30);
   l_status_code           VARCHAR2(30);
   l_user_status_id        NUMBER;
   l_model_status_id       NUMBER;
   l_return_status         VARCHAR2(1);

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
      p_log_used_by_id  => p_score_id,
      p_msg_data        => L_API_NAME || ': Begin'
   );

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Load the score record to get the original status and wf_itemkey
   OPEN c_ref_score (p_score_id);
   FETCH c_ref_score INTO l_ref_score_rec;
   CLOSE c_ref_score;

   IF l_ref_score_rec.wf_itemkey IS NOT NULL THEN

      IF l_ref_score_rec.status_code = G_STATUS_SCHEDULED OR
         l_ref_score_rec.status_code = G_STATUS_QUEUED    OR
         l_ref_score_rec.status_code = G_STATUS_SCORING  THEN

         -- Get the original status of the Model when then the WF process was scheduled
         AMS_WFMOD_PVT.get_original_status(
            p_itemkey         => l_ref_score_rec.wf_itemkey,
            x_orig_status_id  => l_original_status_id,
            x_return_status   => x_return_status
         );

         AMS_WFMod_PVT.cancel_process (
            p_itemkey         => l_ref_score_rec.wf_itemkey,
            x_return_status   => x_return_status
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            -- Report that an error occurred, but ifgnore it and proceed with re-setting
            -- the Scoring Run status.
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
               p_log_used_by_id  => p_score_id,
               p_msg_data        => L_API_NAME || ': Error while canceling Scoring Run process'
            );
            --RAISE FND_API.G_EXC_ERROR;
         ELSE
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
               p_log_used_by_id  => p_score_id,
               p_msg_data        => L_API_NAME || ': Successfully canceled Scoring Run Process'
            );
         END IF;

         -- Set wf_itemkey to null
         l_ref_score_rec.wf_itemkey := NULL;

         IF l_ref_score_rec.status_code = G_STATUS_SCORING THEN

            -- Scoring Run was in SCORING status, then set its status to DRAFT
            l_ref_score_rec.status_code := G_DEFAULT_STATUS;


            -- Set results_flag to 'N', since all score results have been cleaned
            l_ref_score_rec.results_flag := 'N';

            -- Set the user_status_id associated with the new status code
            OPEN c_user_status_id (G_STATUS_TYPE_SCORE, l_ref_score_rec.status_code);
            FETCH c_user_status_id INTO l_ref_score_rec.user_status_id;
            CLOSE c_user_status_id;

         ELSE
            -- Scoring Run was in SCHEDULED/QUEUED status, set its status to its original status
            -- when the WF process was started

            l_ref_score_rec.user_status_id := l_original_status_id;

            -- Set the system_status_code associated with the original status id
            OPEN c_user_status_code (G_STATUS_TYPE_SCORE, l_ref_score_rec.user_status_id);
            FETCH c_user_status_code INTO l_ref_score_rec.status_code;
            CLOSE c_user_status_code;

         END IF;


         -- update the Scoring Run record with new status code and id and with NULL wf_itemkey
         UPDATE ams_dm_scores_all_b
         SET object_version_number  = object_version_number + 1,
             last_update_date       = SYSDATE,
             last_updated_by        = FND_GLOBAL.user_id,
             status_date            = SYSDATE,
             status_code            = l_ref_score_rec.status_code,
             user_status_id         = l_ref_score_rec.user_status_id,
             wf_itemkey             = l_ref_score_rec.wf_itemkey,
             results_flag           = l_ref_score_rec.results_flag
         WHERE score_id = p_score_id;


         -- Update the Model back to AVAILABLE
         OPEN c_user_status_id (G_STATUS_TYPE_MODEL, G_STATUS_AVAILABLE);
         FETCH c_user_status_id INTO l_model_status_id;
         CLOSE c_user_status_id;

         UPDATE ams_dm_models_all_b
         SET    last_update_date       = SYSDATE
              , last_updated_by        = FND_GLOBAL.user_id
              , last_update_login      = FND_GLOBAL.conc_login_id
              , object_version_number  = object_version_number + 1
              , status_code            = G_STATUS_AVAILABLE
              , user_status_id         = l_model_status_id
              , status_date            = SYSDATE
         WHERE model_id = l_ref_score_rec.model_id;
      ELSE
         -- No Run Request/Process to cancel
         -- Set x_return_status to expected error. This will results in a different message
         -- displayed to the user
         x_return_status := FND_API.G_RET_STS_ERROR;

         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
            p_log_used_by_id  => p_score_id,
            p_msg_data        => L_API_NAME || ': No Scoring Run process to cancel'
         );
      END IF;
   ELSE
      -- No Run Request/Process to cancel
      -- Set x_return_status to expected error. This will results in a different message
      -- displayed to the user
      x_return_status := FND_API.G_RET_STS_ERROR;

      AMS_Utility_PVT.create_log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
         p_log_used_by_id  => p_score_id,
         p_msg_data        => L_API_NAME || ': No Scoring Run process to cancel'
      );
   END IF;

      AMS_Utility_PVT.create_log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => G_OBJECT_TYPE_SCORE,
         p_log_used_by_id  => p_score_id,
         p_msg_data        => L_API_NAME || ': End'
      );

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

END cancel_run_request;


PROCEDURE wf_startPreviewProcess (
   p_score_id        IN NUMBER,
   p_orig_status_id  IN NUMBER,
   x_tar_score_rec   IN OUT NOCOPY score_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   -- used with get_user_timezone api
   l_user_timezone_name    VARCHAR2(80);
   L_API_NAME              CONSTANT VARCHAR2(30) := 'wf_startPreviewProcess';

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- fix for bug 4961279. changed get_user_timezone to get_system_timezone
   AMS_Utility_PVT.get_system_timezone (
      x_return_status   => x_return_status,
      x_sys_time_id    => x_tar_score_rec.scheduled_timezone_id,
      x_sys_time_name  => l_user_timezone_name
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- When we submit a Preview request, we clean up all the previous
   -- Scoring Run results since we assume that the data selections may have
   -- changed which means that the previous results do not match the
   -- data selections.
   cleanupPreviousScoreData(p_score_id);

   -- Set the Scoring Run status to PREVIEWING
   x_tar_score_rec.status_code := G_STATUS_PREVIEWING;
   OPEN c_user_status_id (G_STATUS_TYPE_SCORE, x_tar_score_rec.status_code);
   FETCH c_user_status_id INTO x_tar_score_rec.user_status_id;
   CLOSE c_user_status_id;

   -- Initiate Workflow process and grab the itemkey
   AMS_WFMOD_PVT.StartProcess(
      p_object_id       => p_score_id,
      p_object_type     => G_OBJECT_TYPE_SCORE,
      p_user_status_id  => p_orig_status_id,
      p_scheduled_timezone_id => x_tar_score_rec.scheduled_timezone_id,
      p_scheduled_date  => SYSDATE,
      p_request_type    => 'PREVIEW',
      p_select_list     => NULL,
      x_itemkey         => x_tar_score_rec.wf_itemkey
   );

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

END wf_startPreviewProcess;

--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE cleanupPreviousScoreData(
    p_score_ID  NUMBER)
 IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'cleanupPreviousScoreData';

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Remove DM Source records
   delete /*+ index(AMS_DM_SOURCE AMS_DM_SOURCE_U2) */ from ams_dm_source
   where  arc_used_for_object = G_OBJECT_TYPE_SCORE
   and used_for_object_id = p_score_ID;

   -- ams_dm_score_results
   delete from ams_dm_score_results
   where score_id = p_score_id;

   -- ams_dm_score_pct_results
   delete from ams_dm_score_pct_results
   where score_id = p_score_id;

   -- Set the results_flag to 'N'
   UPDATE ams_dm_scores_all_b
    SET results_flag = 'N'
    WHERE score_id = p_score_id;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End.');
   END IF;

 END cleanupPreviousScoreData;


--
-- Purpose
-- To check if there is data selected to be Previewed. We cannot Preview
-- data selections for a Scoring Run  if it has no list, segment, workbook,... selected.
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE dataToPreview(
   p_score_id           IN    NUMBER,
   x_data_exists_flag   OUT NOCOPY   VARCHAR2
)
IS

   l_model_id                 NUMBER;
   l_seeded_ds_flag           VARCHAR2(1);
   l_data_selections_count    NUMBER;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'dataToPreview';

   CURSOR l_dataSelectionsExist (p_score_id IN NUMBER) IS
     SELECT count(*)
       FROM ams_list_select_actions
      WHERE arc_action_used_by = 'SCOR'
        AND action_used_by_id = p_score_id;

   CURSOR l_modelId (p_score_id IN NUMBER) IS
     SELECT model_id
       FROM ams_dm_scores_all_b
      WHERE score_id = p_score_id;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize x_data_exists_flag to 'Y'
   x_data_exists_flag := 'Y';

   -- Initialize l_seeded_ds_flag to 'N'
   l_seeded_ds_flag := 'N';

   -- Fetch model id for this scoring run
   OPEN  l_modelId (p_score_id);
   FETCH l_modelId INTO l_model_id;
   CLOSE l_modelId;

   -- Check if Model has a seeded data source
   AMS_DM_MODEL_PVT.seededDataSource (l_model_id, l_seeded_ds_flag);

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_seeded_ds_flag = ' || l_seeded_ds_flag);
   END IF;

   IF l_seeded_ds_flag = 'Y' THEN

      l_data_selections_count := 0;

      -- Check if the SCoring Run has any data selections
      OPEN l_dataSelectionsExist (p_score_id);
      FETCH l_dataSelectionsExist INTO l_data_selections_count;
      CLOSE l_dataSelectionsExist;

      -- If no data selections exist, then set the flag to N
      IF l_data_selections_count IS NULL or l_data_selections_count = 0 THEN
         x_data_exists_flag := 'N';
      END IF;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. x_data_exists_flag = ' || x_data_exists_flag);
   END IF;

END dataToPreview;

--
-- Purpose
-- To check if a Preview request can be started. We cannot Preview
-- data selections for a Scoring Run if it has any of the following statuses:
-- SCHEDULED, SCORING, PREVIEWING, ARCHIVED, QUEUED.
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE proceedWithPreview(
   p_score_id        IN    NUMBER,
   x_proceed_flag    OUT NOCOPY   VARCHAR2
)
IS

   l_status_code     VARCHAR2(30);
   l_user_status_id  NUMBER;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'proceedWithPreview';

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize proceed flag to 'Y'
   x_proceed_flag := 'Y';

   -- Check Scoring Run Status Code
   getScoreStatus( p_score_id, l_status_code , l_user_status_id);

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Status Code = ' || l_status_code);
   END IF;

   IF l_status_code = G_STATUS_SCHEDULED  OR
      l_status_code = G_STATUS_SCORING    OR
      l_status_code = G_STATUS_QUEUED     OR
      l_status_code = G_STATUS_PREVIEWING OR
      l_status_code = G_STATUS_ARCHIVED
   THEN
      x_proceed_flag := 'N';
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. Proceed Flag = ' || x_proceed_flag);
   END IF;

END proceedWithPreview;


--
-- Purpose
-- Returns Scoring Run Status_Code and User_Status_Id for a Scoring Run
--
-- History
-- 04-Oct-2002 nyostos   Created.
PROCEDURE getScoreStatus(
   p_score_id        IN    NUMBER,
   x_status_code     OUT NOCOPY   VARCHAR2,
   x_user_status_id  OUT NOCOPY NUMBER
)
IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'getScoreStatus';

   CURSOR c_score_status (p_score_id IN NUMBER) IS
      SELECT status_code, user_status_id
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Get the model status
   OPEN c_score_status (p_score_id);
   FETCH c_score_status INTO x_status_code, x_user_status_id;
   CLOSE c_score_status;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. Model Status Code = ' || x_status_code);
   END IF;

END getScoreStatus;


--
-- Purpose
-- To check if Scoring Run data selection sizing options and selection
-- method have changed. This would INVALIDate a COMPLETED Scornig Run.
--
-- History
-- 07-Oct-2002 nyostos   Created.
PROCEDURE check_data_size_changes(
   p_input_score_rec          IN    score_rec_type,
   x_selections_changed_flag  OUT NOCOPY   VARCHAR2
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'check_data_size_changes';

   CURSOR c_ref_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;
   l_ref_score_rec  c_ref_score%ROWTYPE;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Begin.');
   END IF;

   x_selections_changed_flag := 'N';

   -- get the reference Scoring Run, which contains
   -- data before the update operation.
   OPEN c_ref_score (p_input_score_rec.score_id);
   FETCH c_ref_score INTO l_ref_score_rec;
   CLOSE c_ref_score;

   -- min records
   IF (l_ref_score_rec.MIN_RECORDS IS NULL AND p_input_score_rec.MIN_RECORDS IS NOT NULL) OR
       (l_ref_score_rec.MIN_RECORDS <> p_input_score_rec.MIN_RECORDS) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- max records
   IF (l_ref_score_rec.MAX_RECORDS IS NULL  AND p_input_score_rec.MAX_RECORDS IS NOT NULL) OR
       (l_ref_score_rec.MAX_RECORDS <> p_input_score_rec.MAX_RECORDS) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- row_selection_type
   IF (l_ref_score_rec.row_selection_type IS NULL  AND p_input_score_rec.row_selection_type IS NOT NULL) OR
       (l_ref_score_rec.row_selection_type <> p_input_score_rec.row_selection_type) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

    -- every_nth_row
   IF (l_ref_score_rec.EVERY_NTH_ROW IS NULL  AND p_input_score_rec.EVERY_NTH_ROW IS NOT NULL) OR
       (l_ref_score_rec.EVERY_NTH_ROW <> p_input_score_rec.EVERY_NTH_ROW) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- pct_random
   IF (l_ref_score_rec.PCT_RANDOM IS NULL  AND p_input_score_rec.PCT_RANDOM IS NOT NULL) OR
       (l_ref_score_rec.PCT_RANDOM <> p_input_score_rec.PCT_RANDOM) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. Selections Changed Flag = ' || x_selections_changed_flag);
   END IF;

END check_data_size_changes;

--
-- Purpose
--    Checks whether a model is still AVAILABLE for scoring
-- History
-- 09-Oct-2002 nyostos   Created.
PROCEDURE wf_checkModelStatus (
   p_score_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_model_status    OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
   l_model_status_id    NUMBER;

   CURSOR c_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_all_b
      WHERE  model_id = p_model_id;
   l_model_rec       c_model%ROWTYPE;

   CURSOR c_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_all_b
      WHERE score_id = p_score_id;
   l_score_rec       c_score%ROWTYPE;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_score (p_score_id);
   FETCH c_score INTO l_score_rec;
   CLOSE c_score;

   OPEN c_model (l_score_rec.model_id);
   FETCH c_model INTO l_model_rec;
   CLOSE c_model;

   -- if the model is not AVAILABLE or being used in SCORING, then
   -- it cannot be used for scoring.
   x_model_status := l_model_rec.status_code;
   IF l_model_rec.status_code NOT IN (G_STATUS_AVAILABLE, G_STATUS_SCORING) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;

END wf_checkModelStatus;

--
-- Purpose
-- Procedure to handle data selection changes
-- This would INVALIDate a COMPLETED Scoring Run.
--
-- History
-- 14-Oct-2002 nyostos   Created.
PROCEDURE handle_data_selection_changes(
   p_score_id                 IN    NUMBER
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'handle_data_selection_changes';

   CURSOR c_ref_score (p_score_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_scores_vl
      WHERE  score_id = p_score_id
      ;
   l_ref_score_rec   c_ref_score%ROWTYPE;

   l_status_id       NUMBER;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Begin.');
   END IF;

   -- Load the score record to get the original status
   OPEN  c_ref_score (p_score_id);
   FETCH c_ref_score INTO l_ref_score_rec;
   CLOSE c_ref_score;

   -- If the Scoring Run is COMPLETED, then change its status to INVALID
   IF l_ref_score_rec.status_code = G_STATUS_COMPLETED THEN

      -- Get the status id for INVALID status code.
      OPEN c_user_status_id (G_STATUS_TYPE_SCORE, G_STATUS_INVALID);
      FETCH c_user_status_id INTO l_status_id;
      CLOSE c_user_status_id;

      -- update the Scoring Run record with new status code and id and with NULL wf_itemkey
--      UPDATE ams_dm_scores_all_b
--      SET object_version_number  = object_version_number + 1,
--          last_update_date       = SYSDATE,
--          last_updated_by        = FND_GLOBAL.user_id,
--          status_date            = SYSDATE,
--          status_code            = G_STATUS_INVALID,
--          user_status_id         = l_status_id
--      WHERE score_id = p_score_id;

      UPDATE ams_dm_scores_all_b
      SET last_update_date       = SYSDATE,
          last_updated_by        = FND_GLOBAL.user_id,
          status_date            = SYSDATE,
          status_code            = G_STATUS_INVALID,
          user_status_id         = l_status_id
      WHERE score_id = p_score_id;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Invalidated Scoring Run.');

      END IF;

   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End.');
   END IF;

END handle_data_selection_changes;

END ams_dm_score_pvt;

/
