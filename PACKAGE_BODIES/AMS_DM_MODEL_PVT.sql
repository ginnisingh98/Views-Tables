--------------------------------------------------------
--  DDL for Package Body AMS_DM_MODEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_MODEL_PVT" as
/* $Header: amsvdmmb.pls 120.4 2006/07/17 12:03:14 kbasavar noship $ */
-- Start of Comments
-- Package name     : AMS_DM_MODEL_PVT
-- Purpose          : PACKAGE BODY FOR PRIVATE API
-- History          : 11/10/00  JIE LI  CREATED
-- 11/16/00    SVEERAVE@US    In Check_req_items, all required fields are also compared
--                            with null for insert action.
-- History          : 01/23/2001  BGEORGE  Modified for Standards and business rules
-- History          : 01/23/2001  BGEORGE  Added new proc Validate_next_status
-- 25-Jan-2001 choang   Fixed close cursor for status in update api.
-- 26-Jan-2001 choang   Added increment of object ver num in update api.
-- 29-Jan-2001 choang   Removed return statements from req item validation.
-- 29-Jan-2001 choang   Removed return statements from all item validation.
-- 02-Feb-2001 choang   Added new columns.
-- 08-Feb-2001 choang   Modified ams_dm_models_b to ams_dm_models_all_b in
--                      update api.
-- 08-Feb-2001 choang   Changed callout to table handler to remove IN/OUT params.
-- 16-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 21-Feb-2001 choang   1) Added callouts to access apis in create.  2) Added check_access
--                      api which calls check_update_access + others.
-- 22-Feb-2001 choang   Added complete rec.
-- 23-Feb-2001 choang   Defaulted row_selection_type to STANDARD in create.
-- 26-Feb-2001 choang   Added custom_setup_id, country_id and best_subtree.
-- 28-Feb-2001 choang   1) Replaced DM_MODEL with MODEL in messages. 2) Shortened
--                      message codes to be less than 30.
-- 06-Mar-2001 choang   Added expire_models for oncurrent processing.
-- 06-Mar-2001 choang   Added code to handle default status code if no status in create.
-- 08-Mar-2001 choang   1) Added wf_revert. 2) Added wf_itemkey.
-- 08-Mar-2001 choang   1) Added wf_revert. 2) Added wf_itemkey to rec type. 3) Added
--                      process_build_success. 4) added unexpire_model
-- 11-Mar-2001 choang   Added handle_preview_request
-- 30-Mar-2001 choang   Added callouts to ams_wfmod_pvt.cancel_process and change_schedule
-- 10-Apr-2001 choang   Change status back to DRAFT if cancel scheduled.
-- 11-Apr-2001 choang   1) changed spec of wf_revert 2) added wf_build
-- 12-Apr-2001 choang   Fixed scheduled_date comparison to NULL in update_model
-- 17-Apr-2001 choang   Replaced != with <> for adchkdrv compliance.
-- 20-Apr-2001 sveerave Changed column names to be of application column names from db column names
--                      in get_column_value call-out.
-- 09-May-2001 choang   handle_preview_request was not returning request_id
-- 17-Aug-2001 choang   Added custom_setup_id in out param of create api.
-- 18-Oct-2001 choang   Changed logic to check for model build submission when
--                      in DRAFT status.
-- 06-Dec-2001 choang   Added update for results_flag in process_build_success.
-- 07-Dec-2001 choang   Modified callout to change_schedule.
-- 10-Dec-2001 choang   Added wf_startprocess to modularize workflow start api
--                      callout; added handling of re-build.
-- 17-Dec-2001 choang   Added validation for owner update.
-- 20-Dec-2001 choang   Enable log after a preview request is made.
-- 01-Feb-2002 choang   Removed created by in update api
-- 18-Mar-2002 choang   Added checkfile to dbdrv
-- 17-May-2002 choang   bug 2380113: removed use of g_user_id and g_login_id
-- 05-Jun-2002 choang   Obseleted target_group_type; added target_id
-- 28-Jun-2002 choang   Added cleanupPreviousBuildData procedure to clean previous model test,
--                      lift and important attributes data before submitting the WF process.
-- 18-Sep-2002 nyostos  Changes to support new Model States
--                      - handle_preview_request - starts Build/Score Workflow Process
--                        instead of AMS_DM_PREVIEW concurrent process.
--                      - Added wf_startPreviewProcess to handle specific parameters to
--                        pass to the WF Process for Preview.
--                      - added cancel_build_request to cancel Build request.
--                      - changed Update_dm_model to handle new statuses
-- 28-Nov-2002 rosharma Added validations for
--                      - min/max records >= 0
--			- max records >= min records
--			- 0 <= pct random <= 100
--			- If selection method is random, random pct is entered
--			- If selection method is every nth row, number of rows is entered
--
-- 30-Jan-2003 nyostos  Fixed the following:
--                      - Changed model name uniqueness code.
--                      - Bug related to WF process hanging when model owner is not a valid WF approver
-- 07-Feb-2003 nyostos  Added a different return status for errors encountered in submitting build wf process.
-- 09-Feb-2003 rosharma Random % should be > 0. Every Nth Row value should be greater than 0.
-- 10-Feb-2003 rosharma in copy method, Copy pct_random and nth_rowalso from ref record, if selection type is 'NTH_RECORD' or 'RANDOM'.
-- 13-Feb-2003 nyostos  Added check for model name as a required item in case mandatory rules are missing
--                      Also added check for NULL values on create in check_dm_model_req_items().
-- 14-Mar-2003 nyostos  Fixed return status for errors encountered in submitting build wf process.
-- 24-Mar-2003 nyostos  Fixed bug 2863861.
-- 20-Aug-2003 rosharma Fixed bug 3104201.
-- 04-Sep-2003 rosharma Fixed bug 3127555.
-- 12-Sep-2003 kbasavar For Product Affinity.
-- 21-Sep-2003 rosharma Audience Data Source uptake changes to copy_model.
-- 22-Sep-2003 kbasavar Modified copy_model to copy Product selections for Product Affinity model.
-- 05-Nov-2003 rosharma Modified seededDataSource for list DS uptake in 11.5.10
-- 12-Feb-2004 rosharma Bug # 3436093
-- 19-Feb-2004 rosharma Bug # 3451341
-- 26-Feb-2004 kbasavar Bug # 3466964
-- 27-Apr-2005 srivikri fix for bug 4333415
-- 19-May-2005 srivikri fix for bug 4220828


-- NOTE             :
-- End of Comments


G_PKG_NAME                 CONSTANT VARCHAR2(30):= 'AMS_DM_MODEL_PVT';
G_FILE_NAME                CONSTANT VARCHAR2(12) := 'amsvdmmb.pls';
G_DEFAULT_STATUS           CONSTANT VARCHAR2(30) := 'DRAFT';
G_MODEL_STATUS_AVAILABLE   CONSTANT VARCHAR2(30) := 'AVAILABLE';
G_MODEL_STATUS_BUILDING    CONSTANT VARCHAR2(30) := 'BUILDING';
G_OBJECT_TYPE_MODEL        CONSTANT VARCHAR2(30) := 'MODL';
G_MODEL_STATUS_TYPE        CONSTANT VARCHAR2(30) := 'AMS_DM_MODEL_STATUS';
G_MODEL_STATUS_SCHEDULED   CONSTANT VARCHAR2(30) := 'SCHEDULED';


G_MODEL_STATUS_DRAFT       CONSTANT VARCHAR2(30) := 'DRAFT';
G_MODEL_STATUS_SCORING     CONSTANT VARCHAR2(30) := 'SCORING';
G_MODEL_STATUS_QUEUED      CONSTANT VARCHAR2(30) := 'QUEUED';
G_MODEL_STATUS_PREVIEWING  CONSTANT VARCHAR2(30) := 'PREVIEWING';
G_MODEL_STATUS_INVALID     CONSTANT VARCHAR2(30) := 'INVALID';
G_MODEL_STATUS_FAILED      CONSTANT VARCHAR2(30) := 'FAILED';
G_MODEL_STATUS_ARCHIVED    CONSTANT VARCHAR2(30) := 'ARCHIVED';
G_MODEL_STATUS_EXPIRED     CONSTANT VARCHAR2(30) := 'EXPIRED';


G_SEEDED_ID_THRESHOLD      CONSTANT NUMBER       := 10000;
/***
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
***/

-- global cursors

-- Cursor to get the user_status_id for a specific system_status_type and system_status_code
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


--
-- Purpose
-- Validate access privileges of the selected
-- model.  Access privileges can include team
-- based access and also access as defined by
-- model status.
--
-- History
-- 21-Feb-2001 choang   Created.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE check_access (
   p_model_rec       IN dm_model_rec_type,
   p_validation_mode IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


PROCEDURE Complete_dm_model_rec (
   p_dm_model_rec IN DM_MODEL_Rec_Type,
   x_complete_rec OUT NOCOPY DM_MODEL_Rec_Type
);


--
-- Purpose
-- Start Workflow process for the model.
--
-- History
-- 10-Dec-2001 choang   Created.
PROCEDURE wf_startprocess (
   p_model_id IN NUMBER,
   p_scheduled_date IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_model_rec IN OUT NOCOPY dm_model_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
);


--
-- Purpose
-- Start Workflow process for Previewing Data Selections for the model.
--
-- History
-- 18-Sep-2002 nyostos   Created.
PROCEDURE wf_startPreviewProcess (
   p_model_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_model_rec IN OUT NOCOPY dm_model_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
);

--
-- Purpose
-- Cleanup previous model build data. Category Matrix, lift and
-- important attributes record are deleted.
--
-- History
-- 28-Jun-2002 nyostos   Created.
PROCEDURE cleanupPreviousBuildData(
   p_model_id IN NUMBER
);


--
-- Purpose
-- Returns Model Status_Code and User_Status_Id for a Model
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE getModelStatus(
   p_model_id        IN    NUMBER,
   x_status_code     OUT NOCOPY   VARCHAR2,
   x_user_status_id  OUT NOCOPY NUMBER
);

--
-- Purpose
-- To check if a Preview request can be started. We cannot Preview
-- data selections for a Model if it has any of the following statuses:
-- SCHEDULED, BUILDING, SCORING, PREVIEWING, ARCHIVED, QUEUED, EXPIRED.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE proceedWithPreview(
   p_model_id     IN    NUMBER,
   x_proceed_flag OUT NOCOPY   VARCHAR2
);

--
-- Purpose
-- To check if there is data selected to be Previewed. We cannot Preview
-- data selections for a Model with seeded data source if it has no campaign
-- schedule, list, segment, workbook,... selected.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE dataToPreview(
   p_model_id           IN    NUMBER,
   x_data_exists_flag   OUT NOCOPY   VARCHAR2
);



--
-- Purpose
-- To check if Model data selection sizing options and selection
-- method have changed. This would INVALIDate an AVAILABLE model.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE check_data_size_changes(
   p_input_model_rec          IN    DM_MODEL_Rec_Type,
   x_selections_changed_flag  OUT NOCOPY   VARCHAR2
);

--Proceduire added by BGEORGE on 01/23/2001
--validates the next permissible status
--this proc can used for WF callouts too
PROCEDURE Validate_next_status(
    p_curr_status     IN   VARCHAR2,
    p_next_status     IN   VARCHAR2,
    p_system_status_type    IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2)
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_next_status';

   --select important info for the row in ams_status_order_rules
   CURSOR c_status_check IS
      SELECT show_in_lov_flag,
         theme_approval_flag, budget_approval_flag
      FROM ams_status_order_rules
      WHERE system_status_type = p_system_status_type
      AND current_status_code = p_curr_status
      AND next_status_code = p_next_status;

   l_status_check c_status_check%ROWTYPE;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_NEXT_STATUS;

            -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      OPEN c_status_check;
      FETCH c_status_check INTO l_status_check;
      IF c_status_check%NOTFOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      CLOSE c_status_check;

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
     ROLLBACK TO VALIDATE_NEXT_STATUS;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_NEXT_STATUS;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_NEXT_STATUS;
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
End validate_next_status;

-- Hint: Primary key needs to be returned.
PROCEDURE Lock_dm_model(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_MODEL_ID                   IN  NUMBER,
    p_object_version             IN  NUMBER
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_dm_model';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_MODEL_ID                  NUMBER;

   CURSOR c_dm_model_b IS
      SELECT MODEL_ID
        FROM ams_dm_models_all_b
        WHERE MODEL_ID = p_MODEL_ID
        AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;

   CURSOR c_dm_model_tl IS
      SELECT MODEL_ID
        FROM ams_dm_models_all_tl
        WHERE MODEL_ID = p_MODEL_ID
        AND USERENV('LANG') IN (language, source_lang)
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
                                      p_api_version_number,
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
   OPEN c_dm_model_b;

   FETCH c_dm_model_b INTO l_MODEL_ID;

   IF (c_dm_model_b%NOTFOUND) THEN
      CLOSE c_dm_model_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_dm_model_b;

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
     ROLLBACK TO LOCK_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_DM_MODEL_PVT;
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
End Lock_dm_model;



-- Hint: Primary key needs to be returned.
PROCEDURE Create_dm_model(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2 := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2,

    P_DM_MODEL_Rec         IN   DM_MODEL_Rec_Type := G_MISS_DM_MODEL_REC,
    x_custom_setup_id      OUT NOCOPY NUMBER,
    X_MODEL_ID             OUT NOCOPY  NUMBER
)
IS
   l_api_name                 CONSTANT VARCHAR2(30) := 'Create_dm_model';
   l_api_version_number       CONSTANT NUMBER   := 1.0;
   L_DEFAULT_SELECTION_TYPE   CONSTANT VARCHAR2(30) := 'STANDARD';
   L_DEFAULT_POSITIVE_VALUE   CONSTANT VARCHAR2(30) := '1';

   l_return_status_full       VARCHAR2(1);
   l_object_version_number    NUMBER := 1;
   l_org_id                   NUMBER := FND_API.G_MISS_NUM;
   l_dm_model_count           NUMBER;
   l_dm_model_rec             AMS_dm_model_PVT.DM_MODEL_Rec_Type := p_dm_model_rec;

   l_access_rec               AMS_Access_PVT.access_rec_type;

   CURSOR c_dm_model_seq IS
      SELECT ams_dm_models_all_b_s.NEXTVAL
        FROM DUAL;

   CURSOR c_dm_model_count(p_model_id IN NUMBER) IS
      SELECT 1
        FROM ams_dm_models_vl
       WHERE model_id = p_model_id;

   CURSOR c_pass_status_code (p_user_status_id IN NUMBER) IS
      SELECT system_status_code
      FROM ams_user_statuses_vl
      WHERE user_status_id = p_user_status_id;

   CURSOR c_custom_setup_id IS
      SELECT custom_setup_id
      FROM   ams_custom_setups_b
      WHERE  object_type = G_OBJECT_TYPE_MODEL
      AND    enabled_flag = 'Y'
      ;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_DM_MODEL_PVT;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

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

      --  try to generate a unique id from the sequence
      IF l_dm_model_rec.model_id IS NULL OR l_dm_model_rec.model_id = FND_API.G_MISS_NUM THEN
         LOOP
            --  dbms_output.put_line('MODEL ID = ' ||l_MODEL_ID);
            OPEN c_dm_model_seq;
            FETCH c_dm_model_seq INTO l_dm_model_rec.model_id;
            CLOSE c_dm_model_seq;

            --  l_dm_model_count := 0;
            OPEN c_dm_model_count(l_dm_model_rec.model_id);
            FETCH c_dm_model_count INTO l_dm_model_count;
            CLOSE c_dm_model_count;

            EXIT WHEN l_dm_model_count IS NULL;
         END LOOP;
      END IF;

      -- initialize any default values
      l_dm_model_rec.target_positive_value := L_DEFAULT_POSITIVE_VALUE;

      OPEN c_custom_setup_id;
      FETCH c_custom_setup_id INTO l_dm_model_rec.custom_setup_id;
      CLOSE c_custom_setup_id;

      IF l_dm_model_rec.country_id IS NULL OR l_dm_model_rec.country_id = FND_API.g_miss_num THEN
         l_dm_model_rec.country_id := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');
      END IF;

      IF l_dm_model_rec.row_selection_type IS NULL OR l_dm_model_rec.row_selection_type = FND_API.g_miss_char THEN
         l_dm_model_rec.row_selection_type := L_DEFAULT_SELECTION_TYPE;
      END IF;

      -- Assign a default user status if neither id or code are passed.
      IF NVL (l_dm_model_rec.user_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND NVL (l_dm_model_rec.status_code, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
         OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_DEFAULT_STATUS);
         FETCH c_user_status_id INTO l_dm_model_rec.user_status_id;
         CLOSE c_user_status_id;
      ELSIF NVL (l_dm_model_rec.user_status_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         OPEN c_user_status_id (G_MODEL_STATUS_TYPE, l_dm_model_rec.status_code);
         FETCH c_user_status_id INTO l_dm_model_rec.user_status_id;
         CLOSE c_user_status_id;
      END IF;

      OPEN c_pass_status_code (l_dm_model_rec.user_status_id);
      FETCH c_pass_status_code INTO l_dm_model_rec.status_code;
      CLOSE c_pass_status_code;

      l_dm_model_rec.status_date := SYSDATE;

      -- validate the input values
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model');
          END IF;

          -- Invoke validation procedures
          Validate_dm_model(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_create,
            p_dm_model_rec       => l_dm_model_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(ams_dm_models_b_PKG.Insert_Row)
      AMS_DM_MODELS_B_PKG.Insert_Row(
         p_model_id           => l_dm_model_rec.model_id,
         p_last_update_date   => sysdate,
         p_last_updated_by    => FND_GLOBAL.USER_ID,
         p_creation_date      => sysdate,
         p_created_by         => FND_GLOBAL.USER_ID,
         p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
         p_object_version_number => l_object_version_number,
         p_model_type         => l_dm_model_rec.model_type,
         p_user_status_id     => l_dm_model_rec.user_status_id,
         p_status_code        => l_dm_model_rec.status_code,
         p_status_date        => l_dm_model_rec.status_date,
         p_last_build_date    => l_dm_model_rec.last_build_date,
         p_owner_user_id      => l_dm_model_rec.owner_user_id,
         p_performance        => l_dm_model_rec.performance,
         p_target_group_type  => l_dm_model_rec.target_group_type,
         p_darwin_model_ref   => l_dm_model_rec.darwin_model_ref,
         p_model_name         => l_dm_model_rec.model_name,
         p_description        => l_dm_model_rec.description,
         p_scheduled_date     => l_dm_model_rec.scheduled_date,
         p_scheduled_timezone_id => l_dm_model_rec.scheduled_timezone_id,
         p_expiration_date    => l_dm_model_rec.expiration_date,
         p_results_flag       => NVL (l_dm_model_rec.results_flag, 'N'),
         p_LOGS_FLAG          => NVL (p_dm_model_rec.LOGS_FLAG, 'N'),
         p_TARGET_FIELD       => l_dm_model_rec.TARGET_FIELD,
         p_TARGET_TYPE        => l_dm_model_rec.TARGET_TYPE,
         p_TARGET_POSITIVE_VALUE => l_dm_model_rec.TARGET_POSITIVE_VALUE,
         p_TOTAL_RECORDS      => l_dm_model_rec.TOTAL_RECORDS,
         p_TOTAL_POSITIVES    => l_dm_model_rec.TOTAL_POSITIVES,
         p_MIN_RECORDS        => l_dm_model_rec.MIN_RECORDS,
         p_MAX_RECORDS        => l_dm_model_rec.MAX_RECORDS,
         p_row_selection_type => NVL (l_dm_model_rec.row_selection_type, L_DEFAULT_SELECTION_TYPE),
         p_EVERY_NTH_ROW      => l_dm_model_rec.EVERY_NTH_ROW,
         p_PCT_RANDOM         => l_dm_model_rec.PCT_RANDOM,
         p_best_subtree       => l_dm_model_rec.best_subtree,
         p_custom_setup_id    => l_dm_model_rec.custom_setup_id,
         p_country_id         => l_dm_model_rec.country_id,
         p_wf_itemkey         => l_dm_model_rec.wf_itemkey,
         p_target_id          => l_dm_model_rec.target_id,
         p_attribute_category => l_dm_model_rec.attribute_category,
         p_attribute1         => l_dm_model_rec.attribute1,
         p_attribute2         => l_dm_model_rec.attribute2,
         p_attribute3         => l_dm_model_rec.attribute3,
         p_attribute4         => l_dm_model_rec.attribute4,
         p_attribute5         => l_dm_model_rec.attribute5,
         p_attribute6         => l_dm_model_rec.attribute6,
         p_attribute7         => l_dm_model_rec.attribute7,
         p_attribute8         => l_dm_model_rec.attribute8,
         p_attribute9         => l_dm_model_rec.attribute9,
         p_attribute10        => l_dm_model_rec.attribute10,
         p_attribute11        => l_dm_model_rec.attribute11,
         p_attribute12        => l_dm_model_rec.attribute12,
         p_attribute13        => l_dm_model_rec.attribute13,
         p_attribute14        => l_dm_model_rec.attribute14,
         p_attribute15        => l_dm_model_rec.attribute15
      );

      x_model_id := l_dm_model_rec.model_id;
      x_custom_setup_id := l_dm_model_rec.custom_setup_id;

      -- choang - 21-feb-2001
      -- create an entry to the access table for the current
      -- user/owner.
      l_access_rec.act_access_to_object_id := l_dm_model_rec.model_id;
      l_access_rec.arc_act_access_to_object := G_OBJECT_TYPE_MODEL;
      l_access_rec.user_or_role_id := l_dm_model_rec.owner_user_id;
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
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
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
     ROLLBACK TO CREATE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_DM_MODEL_PVT;
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
End Create_dm_model;


PROCEDURE Update_dm_model(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    p_dm_model_rec               IN    DM_MODEL_Rec_Type,
    x_object_version_number      OUT NOCOPY   NUMBER)

IS

   l_api_name                 CONSTANT VARCHAR2(30)   := 'Update_dm_model';
   l_api_version_number       CONSTANT NUMBER         := 1.0;
   L_STATUS_TYPE_MODEL        CONSTANT VARCHAR2(30)   := 'AMS_DM_MODEL_STATUS';

   -- Local Variables
   l_model_id                 NUMBER;
   l_object_version_number    NUMBER;
   l_tar_model_rec            ams_dm_model_pvt.dm_model_rec_type;
   l_schedule_date            DATE;
   l_monitor_url              VARCHAR2(4000);
   l_build_started            VARCHAR2(1);
   l_scheduled_timezone_id    NUMBER;
   l_user_status_id           NUMBER;
   l_wf_itemkey               VARCHAR2(240);

   CURSOR c_pass_status_code (p_user_status_id IN NUMBER) IS
      SELECT system_status_code
      FROM ams_user_statuses_vl
      WHERE user_status_id = p_user_status_id;

   CURSOR c_ref_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;

   l_ref_model_rec            c_ref_model%ROWTYPE;
   l_selections_changed_flag  VARCHAR2(1);
   l_data_exists_flag         VARCHAR2(1);
   l_is_enabled               BOOLEAN;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DM_MODEL_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize build process flag to 'N'
      l_build_started := 'N';

      -- Initialize data selections changed flag to 'N'
      l_selections_changed_flag := 'N';

      -- Handle default values or derived variables --

      -- complete rec must be called before any other
      -- operations because conditional operations don't
      -- go against g_miss values.
      complete_dm_model_rec (
         p_dm_model_rec => p_dm_model_rec,
         x_complete_rec => l_tar_model_rec
      );

      -- get the reference model, which contains
      -- data before the update operation.
      OPEN c_ref_model (p_dm_model_rec.model_id);
      FETCH c_ref_model INTO l_ref_model_rec;
      CLOSE c_ref_model;

      IF (AMS_DEBUG_HIGH_ON) THEN
         ams_utility_pvt.debug_message ('input object version number : ' || p_dm_model_rec.object_version_number);
         ams_utility_pvt.debug_message ('completed object version number : ' || l_ref_model_rec.object_version_number);
         ams_utility_pvt.debug_message ('model id before: ' || l_tar_model_rec.model_id);
      END IF;

      -- 24-Mar-2003 nyostos  Fixed bug 2863861.
      -- Check if the user is resubmitting the update request (via browser refresh button
      -- or by pressing the "update" button again) before re-loading the record.
      IF (p_dm_model_rec.object_version_number <> l_ref_model_rec.object_version_number) THEN
         AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- Process workflow based on the scheduled date
      --    - if user just entered scheduled_date or previous schedule was aborted,
      --      create a new process
      --    - if user changed the scheduled_date, cancel current WF process
      --      and start new one; get new itemkey
      --    - if model already AVAILABLE, user can choose to rebuild by
      --      changing the scheduled date.
      --    - user can also request a build if model is in FAILED or INVALID states
      --    - if model status is PREVIEWING, then the Preview process will be canceled
      --      and build will be started.

      IF (l_ref_model_rec.status_code = G_DEFAULT_STATUS       OR    -- DRAFT
          l_ref_model_rec.status_code = G_MODEL_STATUS_INVALID OR
          l_ref_model_rec.status_code = G_MODEL_STATUS_FAILED) AND p_dm_model_rec.scheduled_date <> FND_API.G_MISS_DATE THEN

         -- First check that the target is enabled
	 AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_ref_model_rec.target_id ,
			 x_is_enabled => l_is_enabled
			 );
         IF l_is_enabled = FALSE THEN
	    IF (AMS_DEBUG_HIGH_ON) THEN
	       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot build');
	    END IF;
	    -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	    -- displayed to the user
	    x_return_status := 'T';
	    RETURN;
         END IF;
         -- First check that there is data selections if the Model has a seeded Data Source
         -- We should not schedule the build if there are no data selections
         dataToPreview (p_dm_model_rec.model_id, l_data_exists_flag);
         IF l_data_exists_flag = 'N' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Build');
            END IF;
            -- Set x_return_status to 'D' (for data error). This will results in a different message
            -- displayed to the user
            x_return_status := 'D';
            RETURN;
         END IF;

         -- Submit a Build request
         /* choang - 13-dec-2002 - added for nocopy */
         l_schedule_date := l_tar_model_rec.scheduled_date;
         l_scheduled_timezone_id := l_tar_model_rec.scheduled_timezone_id;

         wf_startprocess (
            p_model_id              => l_ref_model_rec.model_id,
            p_scheduled_date        => l_schedule_date,
            p_scheduled_timezone_id => l_scheduled_timezone_id,
            p_orig_status_id        => l_ref_model_rec.user_status_id,
            x_tar_model_rec         => l_tar_model_rec,
            x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := 'W';
            RETURN;
         END IF;

         -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
         -- to be displayed on a custom confirmation message.
         l_build_started := 'Y';
         l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_model_rec.wf_itemkey, 'NO');
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
         END IF;

      ELSIF l_ref_model_rec.status_code = G_MODEL_STATUS_SCHEDULED AND l_ref_model_rec.scheduled_date <> l_tar_model_rec.scheduled_date THEN

         -- First check that the target is enabled
	 AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_tar_model_rec.target_id ,
			 x_is_enabled => l_is_enabled
			 );
         IF l_is_enabled = FALSE THEN
	    IF (AMS_DEBUG_HIGH_ON) THEN
	       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot build');
	    END IF;
	    -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	    -- displayed to the user
	    x_return_status := 'T';
	    RETURN;
         END IF;
         -- First check that there is data selections if the Model has a seeded Data Source
         -- We should not schedule the build if there are no data selections
         dataToPreview (p_dm_model_rec.model_id, l_data_exists_flag);
         IF l_data_exists_flag = 'N' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Build');
            END IF;
            -- Set x_return_status to 'D' (for data error). This will results in a different message
            -- displayed to the user
            x_return_status := 'D';
            RETURN;
         END IF;

         /* choang - 13-dec-2002 - used l_wf_itemkey for nocopy */
         AMS_WFMod_PVT.change_schedule (
            p_itemkey               => l_tar_model_rec.wf_itemkey,
            p_scheduled_date        => l_tar_model_rec.scheduled_date,
            p_scheduled_timezone_id => l_tar_model_rec.scheduled_timezone_id,
            x_new_itemkey           => l_wf_itemkey,
            x_return_status         => x_return_status
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

            -- if we cannot change the schedule, may be the process has been purged,
            -- then we go ahead and submit a new process and get a new wf_itemkey
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Change schedule failed. Going to start new build process' );
            END IF;

            -- Set reference model status to DRAFT
            OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_DEFAULT_STATUS);
            FETCH c_user_status_id INTO l_user_status_id;
            CLOSE c_user_status_id;

            l_ref_model_rec.status_code      := G_DEFAULT_STATUS;
            l_ref_model_rec.user_status_id   := l_user_status_id;

            -- Submit a Build request
            /* choang - 13-dec-2002 - added for nocopy */
            l_schedule_date := l_tar_model_rec.scheduled_date;
            l_scheduled_timezone_id := l_tar_model_rec.scheduled_timezone_id;

            wf_startprocess (
               p_model_id              => l_ref_model_rec.model_id,
               p_scheduled_date        => l_schedule_date,
               p_scheduled_timezone_id => l_scheduled_timezone_id,
               p_orig_status_id        => l_ref_model_rec.user_status_id,
               x_tar_model_rec         => l_tar_model_rec,
               x_return_status         => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := 'W';
               RETURN;
            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' New Item Key ' || l_tar_model_rec.wf_itemkey);
            END IF;

         END IF;

         -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
         -- to be displayed on a custom confirmation message.
         l_build_started := 'Y';
         l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_model_rec.wf_itemkey, 'NO');
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
         END IF;

      ELSIF l_ref_model_rec.status_code = G_MODEL_STATUS_AVAILABLE AND l_ref_model_rec.scheduled_date <> l_tar_model_rec.scheduled_date THEN

         -- First check that the target is enabled
	 AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_tar_model_rec.target_id ,
			 x_is_enabled => l_is_enabled
			 );
         IF l_is_enabled = FALSE THEN
	    IF (AMS_DEBUG_HIGH_ON) THEN
	       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot build');
	    END IF;
	    -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	    -- displayed to the user
	    x_return_status := 'T';
	    RETURN;
         END IF;
         -- First check that there is data selections if the Model has a seeded Data Source
         -- We should not schedule the build if there are no data selections
         dataToPreview (p_dm_model_rec.model_id, l_data_exists_flag);
         IF l_data_exists_flag = 'N' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Build');
            END IF;
            -- Set x_return_status to 'D' (for data error). This will results in a different message
            -- displayed to the user
            x_return_status := 'D';
            RETURN;
         END IF;

         /* choang - 13-dec-2002 - added for nocopy */
         l_schedule_date := l_tar_model_rec.scheduled_date;
         l_scheduled_timezone_id := l_tar_model_rec.scheduled_timezone_id;

         wf_startprocess (
            p_model_id              => l_ref_model_rec.model_id,
            p_scheduled_date        => l_schedule_date,
            p_scheduled_timezone_id => l_scheduled_timezone_id,
            p_orig_status_id        => l_ref_model_rec.user_status_id,
            x_tar_model_rec         => l_tar_model_rec,
            x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := 'W';
            RETURN;
         END IF;

         -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
         -- to be displayed on a custom confirmation message.
         l_build_started := 'Y';
         l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_model_rec.wf_itemkey, 'NO');
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
         END IF;

      ELSIF l_ref_model_rec.status_code = G_MODEL_STATUS_PREVIEWING  AND l_ref_model_rec.scheduled_date <> FND_API.G_MISS_DATE THEN

         -- First check that the target is enabled
	 AMS_DM_TARGET_PVT.is_target_enabled(
			 p_target_id  => l_tar_model_rec.target_id ,
			 x_is_enabled => l_is_enabled
			 );
         IF l_is_enabled = FALSE THEN
	    IF (AMS_DEBUG_HIGH_ON) THEN
	       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Target is disabled, cannot build');
	    END IF;
	    -- Set x_return_status to 'T' (for target disabled error). This will results in a different message
	    -- displayed to the user
	    x_return_status := 'T';
	    RETURN;
         END IF;
         -- First check that there is data selections if the Model has a seeded Data Source
         -- We should not schedule the build if there are no data selections
         dataToPreview (p_dm_model_rec.model_id, l_data_exists_flag);
         IF l_data_exists_flag = 'N' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' No Data Selections to Build');
            END IF;
            -- Set x_return_status to 'D' (for data error). This will results in a different message
            -- displayed to the user
            x_return_status := 'D';
            RETURN;
         END IF;

         -- if the model is PREVIEWING, then cancel the preview process first and set the Model status to DRAFT
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Model is currently previewing');
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Going to cancel Preview Process. Item Key ' || l_tar_model_rec.wf_itemkey);
         END IF;


         AMS_WFMod_PVT.cancel_process (
            p_itemkey         => l_tar_model_rec.wf_itemkey,
            x_return_status   => x_return_status
         );

         -- Set reference model status to DRAFT
         OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_DEFAULT_STATUS);
         FETCH c_user_status_id INTO l_user_status_id;
         CLOSE c_user_status_id;

         l_ref_model_rec.status_code      := G_DEFAULT_STATUS;
         l_ref_model_rec.user_status_id   := l_user_status_id;
         l_tar_model_rec.wf_itemkey       := NULL;

         /* choang - 13-dec-2002 - added for nocopy */
         l_schedule_date := l_tar_model_rec.scheduled_date;
         l_scheduled_timezone_id := l_tar_model_rec.scheduled_timezone_id;

         -- Submit a Build request
         wf_startprocess (
            p_model_id              => l_ref_model_rec.model_id,
            p_scheduled_date        => l_schedule_date,
            p_scheduled_timezone_id => l_scheduled_timezone_id,
            p_orig_status_id        => l_user_status_id,
            x_tar_model_rec         => l_tar_model_rec,
            x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := 'W';
            RETURN;
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' New Item Key ' || l_tar_model_rec.wf_itemkey);
         END IF;

         -- Construct the URL that could be used to monitor the WF process. This will be returned to the caller
         -- to be displayed on a custom confirmation message.
         l_build_started := 'Y';
         l_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_model_rec.wf_itemkey, 'NO');
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_monitor_url = ' || l_monitor_url );
         END IF;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         ams_utility_pvt.debug_message ('model id after: ' || l_tar_model_rec.model_id);
         ams_utility_pvt.debug_message ('l_ref_model_rec.status_code  ' || l_ref_model_rec.status_code );
         ams_utility_pvt.debug_message ('l_tar_model_rec.status_code  ' || l_tar_model_rec.status_code );
      END IF;

      -- Validate if data selections changed for an AVAILABLE Model, and set the
      -- Model status to INVALID. Make sure that a build has not been started as
      -- this will mess up the statuses
      IF ( l_ref_model_rec.status_code = G_MODEL_STATUS_AVAILABLE AND l_build_started = 'N') THEN

         check_data_size_changes (l_tar_model_rec,
                                  l_selections_changed_flag);

         IF l_selections_changed_flag = 'Y' THEN
            l_tar_model_rec.status_code := G_MODEL_STATUS_INVALID;

            OPEN c_user_status_id (G_MODEL_STATUS_TYPE, l_tar_model_rec.status_code);
            FETCH c_user_status_id INTO l_tar_model_rec.user_status_id;
            CLOSE c_user_status_id;
         END IF;

      END IF;


      OPEN c_pass_status_code (l_tar_model_rec.user_status_id);
      FETCH c_pass_status_code into l_tar_model_rec.status_code;
      CLOSE c_pass_status_code;

      IF (l_tar_model_rec.status_code <> l_ref_model_rec.status_code) THEN
         Validate_next_status(
            p_curr_status        => l_ref_model_rec.status_code,
            p_next_status        => l_tar_model_rec.status_code,
            p_system_status_type => G_MODEL_STATUS_TYPE,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_tar_model_rec.status_date := sysdate;
      END IF;

      --if no user_status_id passing, keep the current status_code value
      IF l_tar_model_rec.user_status_id = FND_API.G_MISS_NUM THEN
         l_tar_model_rec.status_code := l_ref_model_rec.status_code;
      END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model');
          END IF;

          -- Invoke validation procedures
          Validate_dm_model(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => jtf_plsql_api.g_update,
            p_dm_model_rec       => l_tar_model_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      BEGIN
         -- Invoke table handler(AMS_DM_MODELS_B_PKG.Update_Row)
         AMS_DM_MODELS_B_PKG.Update_Row(
            p_model_id           => l_tar_model_rec.model_id,
            p_last_update_date   => sysdate,
            p_last_updated_by    => FND_GLOBAL.USER_ID,
            p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
            p_object_version_number => l_tar_model_rec.object_version_number,
            p_model_type         => l_tar_model_rec.model_type,
            p_user_status_id     => l_tar_model_rec.user_status_id,
            p_status_code        => l_tar_model_rec.status_code,
            p_status_date        => l_tar_model_rec.status_date,
            p_last_build_date    => l_tar_model_rec.last_build_date,
            p_owner_user_id      => l_tar_model_rec.owner_user_id,
            p_performance        => l_tar_model_rec.performance,
            p_target_group_type  => l_tar_model_rec.target_group_type,
            p_darwin_model_ref   => l_tar_model_rec.darwin_model_ref,
            p_model_name         => l_tar_model_rec.model_name,
            p_description        => l_tar_model_rec.description,
            p_scheduled_date     =>l_tar_model_rec.scheduled_date,
            p_scheduled_timezone_id =>l_tar_model_rec.scheduled_timezone_id,
            p_expiration_date    => l_tar_model_rec.expiration_date,
            p_results_flag       => l_tar_model_rec.results_flag,
            p_LOGS_FLAG          => l_tar_model_rec.LOGS_FLAG,
            p_TARGET_FIELD       => l_tar_model_rec.TARGET_FIELD,
            p_TARGET_TYPE        => l_tar_model_rec.TARGET_TYPE,
            p_TARGET_POSITIVE_VALUE => l_tar_model_rec.TARGET_POSITIVE_VALUE,
            p_TOTAL_RECORDS      => l_tar_model_rec.TOTAL_RECORDS,
            p_TOTAL_POSITIVES    => l_tar_model_rec.TOTAL_POSITIVES,
            p_MIN_RECORDS        => l_tar_model_rec.MIN_RECORDS,
            p_MAX_RECORDS        => l_tar_model_rec.MAX_RECORDS,
            p_row_selection_type => l_tar_model_rec.row_selection_type,
            p_EVERY_NTH_ROW      => l_tar_model_rec.EVERY_NTH_ROW,
            p_PCT_RANDOM         => l_tar_model_rec.PCT_RANDOM,
            p_best_subtree       => l_tar_model_rec.best_subtree,
            p_custom_setup_id    => l_tar_model_rec.custom_setup_id,
            p_country_id         => l_tar_model_rec.country_id,
            p_wf_itemkey         => l_tar_model_rec.wf_itemkey,
            p_target_id          => l_tar_model_rec.target_id,
            p_attribute_category => l_tar_model_rec.attribute_category,
            p_attribute1      => l_tar_model_rec.attribute1,
            p_attribute2      => l_tar_model_rec.attribute2,
            p_attribute3      => l_tar_model_rec.attribute3,
            p_attribute4      => l_tar_model_rec.attribute4,
            p_attribute5      => l_tar_model_rec.attribute5,
            p_attribute6      => l_tar_model_rec.attribute6,
            p_attribute7      => l_tar_model_rec.attribute7,
            p_attribute8      => l_tar_model_rec.attribute8,
            p_attribute9      => l_tar_model_rec.attribute9,
            p_attribute10     => l_tar_model_rec.attribute10,
            p_attribute11     => l_tar_model_rec.attribute11,
            p_attribute12     => l_tar_model_rec.attribute12,
            p_attribute13     => l_tar_model_rec.attribute13,
            p_attribute14     => l_tar_model_rec.attribute14,
            p_attribute15     => l_tar_model_rec.attribute15
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.G_EXC_ERROR;
      END;

      x_object_version_number := l_tar_model_rec.object_version_number + 1;

      -- Change the owner in the access table
      IF (l_tar_model_rec.owner_user_id <> FND_API.G_MISS_NUM AND l_tar_model_rec.owner_user_id <> l_ref_model_rec.owner_user_id) THEN
         AMS_Access_PVT.update_object_owner (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_object_type        => 'MODL',
            p_object_id          => l_tar_model_rec.model_id,
            p_resource_id        => l_tar_model_rec.owner_user_id,
            p_old_resource_id    => l_ref_model_rec.owner_user_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

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
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- If a build process has been scheduled, then return the monitor_url in x_msg_data
      IF l_build_started = 'Y' THEN
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
     ROLLBACK TO UPDATE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_DM_MODEL_PVT;
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
End Update_dm_model;


PROCEDURE Delete_dm_model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_model_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_dm_model';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_DM_MODEL_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
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

      -- Invoke table handler(AMS_DM_MODELS_B_PKG.Delete_Row)

      BEGIN
   AMS_DM_MODELS_B_PKG.Delete_Row(p_model_id  => p_model_id);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE FND_API.G_EXC_ERROR;
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
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_DM_MODEL_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_DM_MODEL_PVT;
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
End Delete_dm_model;

-----------------------------------------------------------------------
-- Procedure name     : check_dm_model_fk_items
-- Purpose        : Validate forgein key for table ams_dm_models_all_b
-----------------------------------------------------------------------
PROCEDURE check_dm_model_fk_items(
   p_dm_model_rec    IN  dm_model_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_dm_model_fk_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
--------------------owner_user_id---------------------------
   IF p_dm_model_rec.owner_user_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'jtf_rs_resource_extns',
            'resource_id',
            p_dm_model_rec.owner_user_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'OWNER_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --------------------- user_status_id ------------------------
   IF p_dm_model_rec.user_status_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_user_statuses_b',
            'user_status_id',
            p_dm_model_rec.user_status_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --------------------- target_id ------------------------
   IF p_dm_model_rec.target_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_dm_targets_b',
            'target_id',
            p_dm_model_rec.target_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_dm_model_fk_items;

-----------------------------------------------------------------------
-- Procedure name     : check_dm_model_lookup_items
-- Purpose        : Validate Look up for table ams_dm_models_all_b
-----------------------------------------------------------------------
PROCEDURE check_dm_model_lookup_items(
   p_dm_model_rec        IN  dm_model_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_dm_model_lookup_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

 /*lookup type can be get from the detail design doc */
 ----------------------- model_type  ------------------------
   IF p_dm_model_rec.model_type <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_DM_MODEL_TYPE',
            p_lookup_code => p_dm_model_rec.model_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_INVALID_LOOKUP');
            FND_MESSAGE.set_token ('LOOKUP_CODE', p_dm_model_rec.model_type);
            FND_MESSAGE.set_token ('COLUMN_NAME', 'MODEL_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

------------------ status_code ---------------------------------------
  IF p_dm_model_rec.status_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => 'AMS_DM_MODEL_STATUS',
             p_lookup_code => p_dm_model_rec.status_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_INVALID_LOOKUP');
            FND_MESSAGE.set_token ('LOOKUP_CODE', p_dm_model_rec.status_code);
            FND_MESSAGE.set_token ('COLUMN_NAME', 'STATUS_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

------------------ target_group_type ---------------------------------------
/* the following should be uncommentted when data is ready */

/*** choang - 05-jun-2002 - OBSELETED
  IF p_dm_model_rec.target_group_type <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => 'AMS_DM_TARGET_GROUP_TYPE',
             p_lookup_code => p_dm_model_rec.target_group_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_BAD_TARGET_GROUP');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
***/
END check_dm_model_lookup_items;

-----------------------------------------------------------------------
-- Procedure name     : check_dm_model_uk_items
-- Purpose        : Validate Uniqueness for table ams_dm_models_all_b
-----------------------------------------------------------------------
PROCEDURE check_dm_model_uk_items(
    p_DM_MODEL_rec               IN   DM_MODEL_Rec_Type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

   CURSOR c_model_name
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_models_all_tl
                     WHERE UPPER(model_name) = UPPER(p_dm_model_rec.model_name) and LANGUAGE = userenv('LANG')) ;
   CURSOR c_model_name_updt
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_models_vl
                     WHERE UPPER(model_name) = UPPER(p_dm_model_rec.model_name)
                     AND model_id <> p_DM_MODEL_rec.model_id );

   l_dummy NUMBER ;

BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API:check_dm_model_uk_items');
      END IF;
      x_return_status := FND_API.g_ret_sts_success;

      --Validate unique model_id
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_dm_models_all_b',
         'MODEL_ID = ''' || p_dm_model_rec.model_id ||'''');
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_dm_models_all_b',
         'MODEL_ID = ''' || p_dm_model_rec.model_id ||
         ''' AND MODEL_ID <> ' || p_dm_model_rec.model_id);
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      --Validate unique model_name
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         OPEN c_model_name ;
         FETCH c_model_name INTO l_dummy;
         CLOSE c_model_name ;
      ELSE
         OPEN c_model_name_updt ;
         FETCH c_model_name_updt INTO l_dummy;
         CLOSE c_model_name_updt ;
      END IF;

     IF l_dummy IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_DUPLICATE_NAME');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_dm_model_uk_items;

------------------------------------------------------------------------------------
-- Procedure name     : check_dm_model_req_items
-- Purpose        : Validate Required/NOT NULL column for table ams_dm_models_all_b
-- History
-- 21-Feb-2001 choang   Added check for g_miss_num on model_id and object_version_number.
-- 13-Feb-2003 nyostos  Added check for missing or NULL Model Name. Also added check for NULL
--                      values in Create.
------------------------------------------------------------------------------------
PROCEDURE check_dm_model_req_items(
    p_DM_MODEL_rec               IN  DM_MODEL_rec_type,
    p_validation_mode            IN  VARCHAR2 ,
    x_return_status           OUT NOCOPY VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

--for update API, check if NULL value, if the parameter is missing,
--it is handled by table handler

   IF (p_validation_mode = jtf_plsql_api.g_update) THEN

      IF (AMS_DEBUG_HIGH_ON) THEN
         ams_utility_pvt.debug_message('Private API:check_dm_model_req_items for update');
      END IF;

      IF (p_dm_model_rec.model_id IS NULL OR p_dm_model_rec.model_id = FND_API.G_MISS_NUM) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_MODEL_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF (p_dm_model_rec.object_version_number IS NULL OR p_dm_model_rec.object_version_number = FND_API.G_MISS_NUM) THEN
        AMS_Utility_PVT.error_message ('AMS_MODEL_NO_OBJ_VERSION');
        x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.model_type IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_MODEL_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.user_status_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_USER_STATUS_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.status_code IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_STATUS_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.status_date IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_STATUS_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.owner_user_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_OWNER_USER_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*** choang - 05-jun-2002 - OBSELETED
      IF p_dm_model_rec.target_group_type IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_TARGET_GROUP_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
***/

      IF p_dm_model_rec.RESULTS_FLAG IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_RESULTS_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.LOGS_FLAG IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_LOGS_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_dm_model_rec.row_selection_type IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MODEL_NO_ROW_SELECT_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- nyostos  Feb 13, 2003. Added check for model name in case the mandatory rule
      -- for model name is missing
      IF p_dm_model_rec.model_name IS NULL  THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MODEL_NAME');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.target_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE
      -- nyostos  Feb 13, 2003. Added check for NULL values on Create

      -- for insert API, check if the parameter is missing or NULL
      IF (AMS_DEBUG_HIGH_ON) THEN
         ams_utility_pvt.debug_message('Private API:check_dm_model_req_items for create');
      END IF;

      IF p_dm_model_rec.model_type = FND_API.G_MISS_CHAR OR p_dm_model_rec.model_type IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MODEL_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.user_status_id = FND_API.G_MISS_NUM OR p_dm_model_rec.user_status_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.status_code = FND_API.G_MISS_CHAR OR p_dm_model_rec.status_code IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'STATUS_CODE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.status_date = FND_API.G_MISS_DATE OR p_dm_model_rec.status_date IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'STATUS_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF (p_dm_model_rec.owner_user_id = FND_API.G_MISS_NUM) OR p_dm_model_rec.owner_user_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OWNER_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

/**** - choang - 05-jun-2002 - OBSELETED
      IF p_dm_model_rec.target_group_type = FND_API.G_MISS_CHAR THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_GROUP_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
***/
      -- nyostos  Feb 13, 2003. Added check for model name in case the mandatory rule
      -- for model name is missing
      IF p_dm_model_rec.model_name = FND_API.G_MISS_CHAR OR p_dm_model_rec.model_name IS NULL  THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MODEL_NAME');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_dm_model_rec.target_id = FND_API.G_MISS_NUM OR p_dm_model_rec.target_id IS NULL  THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

END check_dm_model_req_items;

---------------------------------------------------------------------------------------
-- Procedure name     : Check_DM_MODEL_Items
-- Purpose        : Validate items for table ams_dm_models_all_b
--                      It contains uniqueness, forgein key, required, look up checking
---------------------------------------------------------------------------------------
PROCEDURE Check_dm_model_items (
    P_DM_MODEL_Rec     IN    DM_MODEL_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:call check_dm_model_uk_items');
   END IF;
   Check_dm_model_uk_items(
      p_dm_model_rec    =>p_dm_model_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API:call check_dm_model_req_items');
   END IF;
   Check_dm_model_req_items(
      p_dm_model_rec    =>p_dm_model_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Key API calls
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API:call check_dm_model_fk_items');
   END IF;
   Check_dm_model_fk_items(
      p_dm_model_rec    =>p_dm_model_rec,
      x_return_status   => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookup API calls
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API:call check_dm_model_lookup_items');
   END IF;
   Check_dm_model_lookup_items(
      p_dm_model_rec    =>p_dm_model_rec,
      x_return_status   => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Start add rosharma 28-Nov-2002
   -- Min records should be number and more than 0, if entered
   IF p_dm_model_rec.min_records IS NOT NULL AND
      p_dm_model_rec.min_records <> FND_API.g_miss_num THEN
      DECLARE
         l_min_rec       NUMBER;
      BEGIN
         l_min_rec := TO_NUMBER (p_dm_model_rec.min_records);
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
   IF p_dm_model_rec.max_records IS NOT NULL AND
      p_dm_model_rec.max_records <> FND_API.g_miss_num THEN
      DECLARE
         l_max_rec       NUMBER;
      BEGIN
         l_max_rec := TO_NUMBER (p_dm_model_rec.max_records);
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

END Check_DM_MODEL_Items;

---------------------------------------------------------------------------------------
-- Procedure name     : Check_DM_MODEL_Items
-- Purpose        : Validate records for table ams_dm_models_all_b
-- History
-- 21-Feb-2001 choang   Added p_validation_mode to params.  Added
--                      callout to check_access.
---------------------------------------------------------------------------------------
PROCEDURE Validate_dm_model_rec(
    P_Api_Version_Number   IN NUMBER,
    P_Init_Msg_List        IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_mode      IN VARCHAR2,
    X_Return_Status        OUT NOCOPY VARCHAR2,
    X_Msg_Count            OUT NOCOPY NUMBER,
    X_Msg_Data             OUT NOCOPY VARCHAR2,
    P_DM_MODEL_Rec         IN DM_MODEL_Rec_Type
    )
IS
   l_context_resource_id      NUMBER;
   l_is_owner                 VARCHAR2(1);

   -- add to select list as needed
   CURSOR c_reference (p_model_id IN NUMBER) IS
      SELECT owner_user_id
      FROM   ams_dm_models_all_b
      WHERE  model_id = p_model_id;
   l_reference_rec      c_reference%ROWTYPE;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      IF p_validation_mode = JTF_PLSQL_API.G_UPDATE THEN
         l_context_resource_id := AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);

         OPEN c_reference(p_dm_model_rec.model_id);
         FETCH c_reference INTO l_reference_rec;
         CLOSE c_reference;

         check_access (
            p_model_rec       => p_dm_model_rec,
            p_validation_mode => p_validation_mode,
            x_return_status   => x_return_status
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- the owner in the context needs to be the
         -- same as the owner of the record in order
         -- for owner to be changed
         IF l_reference_rec.owner_user_id <> p_dm_model_rec.owner_user_id THEN
            l_is_owner := AMS_Access_PVT.check_owner (
                              p_object_type  => G_OBJECT_TYPE_MODEL,
                              p_object_id    => p_dm_model_rec.model_id,
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
      IF p_dm_model_rec.min_records IS NOT NULL AND
         p_dm_model_rec.min_records <> FND_API.g_miss_num AND
         p_dm_model_rec.max_records IS NOT NULL AND
         p_dm_model_rec.max_records <> FND_API.g_miss_num THEN
         DECLARE
            l_min_rec       NUMBER;
            l_max_rec       NUMBER;
         BEGIN
            l_min_rec := TO_NUMBER (p_dm_model_rec.min_records);
            l_max_rec := TO_NUMBER (p_dm_model_rec.max_records);
            IF l_max_rec < l_min_rec THEN
               AMS_Utility_PVT.error_message ('AMS_DM_MIN_MORE_THAN_MAX');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
            END IF;
         END;
      END IF;

      -- If selection is every Nth row, there must be a value in number of rows
      -- and it must be greater than 0
      IF p_dm_model_rec.row_selection_type = 'NTH_RECORD' THEN
         IF p_dm_model_rec.every_nth_row IS NULL OR
            p_dm_model_rec.every_nth_row = FND_API.g_miss_num THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NO_NTH_RECORD');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
         --check for valid number
         DECLARE
            l_nth_row       NUMBER;
         BEGIN
            l_nth_row := ROUND(TO_NUMBER (p_dm_model_rec.every_nth_row));
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
      IF p_dm_model_rec.row_selection_type = 'RANDOM' THEN
         IF p_dm_model_rec.pct_random IS NULL OR
            p_dm_model_rec.pct_random = FND_API.g_miss_num THEN
            AMS_Utility_PVT.error_message ('AMS_DM_NO_PCT_RANDOM');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
         --check for valid number
         DECLARE
            l_pct_random       NUMBER;
         BEGIN
            l_pct_random := TO_NUMBER (p_dm_model_rec.pct_random);
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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_dm_model_rec;

---------------------------------------------------------------------------------------
-- Procedure name     : Complete_DM_MODEL_Rec
-- Purpose        :
---------------------------------------------------------------------------------------
PROCEDURE Complete_dm_model_rec (
   p_dm_model_rec IN DM_MODEL_Rec_Type,
   x_complete_rec OUT NOCOPY DM_MODEL_Rec_Type
)
IS
   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_models_vl
      WHERE model_id = p_dm_model_rec.model_id
      ;
   l_model_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_dm_model_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_model_rec;
   IF c_complete%NOTFOUND THEN
      CLOSE c_complete;
      AMS_Utility_PVT.error_message ('AMS_MODEL_BAD_ID');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c_complete;

   -- model_id
   IF p_dm_model_rec.model_id = FND_API.g_miss_num THEN
      x_complete_rec.model_id := l_model_rec.model_id;
   END IF;

   -- last_update_date
   IF p_dm_model_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_model_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_dm_model_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_model_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_dm_model_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_model_rec.creation_date;
   END IF;

   -- created_by
   IF p_dm_model_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_model_rec.created_by;
   END IF;

   -- last_update_login
   IF p_dm_model_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_model_rec.last_update_login;
   END IF;

   -- org_id
   IF p_dm_model_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_model_rec.org_id;
   END IF;

   -- object_version_number
   IF p_dm_model_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_model_rec.object_version_number;
   END IF;

   -- model_type
   IF p_dm_model_rec.model_type = FND_API.g_miss_char THEN
      x_complete_rec.model_type := l_model_rec.model_type;
   END IF;

   -- user_status_id
   IF p_dm_model_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_model_rec.user_status_id;
   END IF;

   -- status_code
   IF p_dm_model_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_model_rec.status_code;
   END IF;

   -- status_date
   IF p_dm_model_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := l_model_rec.status_date;
   END IF;

   -- owner_user_id
   IF p_dm_model_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_model_rec.owner_user_id;
   END IF;

   -- last_build_date
   IF p_dm_model_rec.last_build_date = FND_API.g_miss_date THEN
      x_complete_rec.last_build_date := l_model_rec.last_build_date;
   END IF;

   -- scheduled_date
   IF p_dm_model_rec.scheduled_date = FND_API.g_miss_date THEN
      x_complete_rec.scheduled_date := l_model_rec.scheduled_date;
   END IF;

   -- scheduled_timezone_id
   IF p_dm_model_rec.scheduled_timezone_id = FND_API.g_miss_num THEN
      x_complete_rec.scheduled_timezone_id := l_model_rec.scheduled_timezone_id;
   END IF;

   -- expiration_date
   IF p_dm_model_rec.expiration_date = FND_API.g_miss_date THEN
      x_complete_rec.expiration_date := l_model_rec.expiration_date;
   END IF;

   -- results_flag
   IF p_dm_model_rec.results_flag = FND_API.g_miss_char THEN
      x_complete_rec.results_flag := l_model_rec.results_flag;
   END IF;

   -- logs_flag
   IF p_dm_model_rec.logs_flag = FND_API.g_miss_char THEN
      x_complete_rec.logs_flag := l_model_rec.logs_flag;
   END IF;

   -- target_field
   IF p_dm_model_rec.target_field = FND_API.g_miss_char THEN
      x_complete_rec.target_field := l_model_rec.target_field;
   END IF;

   -- target_type
   IF p_dm_model_rec.target_type = FND_API.g_miss_char THEN
      x_complete_rec.target_type := l_model_rec.target_type;
   END IF;

   -- target_positive_value
   IF p_dm_model_rec.target_positive_value = FND_API.g_miss_char THEN
      x_complete_rec.target_positive_value := l_model_rec.target_positive_value;
   END IF;

   -- total_records
   IF p_dm_model_rec.total_records = FND_API.g_miss_num THEN
      x_complete_rec.total_records := l_model_rec.total_records;
   END IF;

   -- total_positives
   IF p_dm_model_rec.total_positives = FND_API.g_miss_num THEN
      x_complete_rec.total_positives := l_model_rec.total_positives;
   END IF;

   -- min_records
   IF p_dm_model_rec.min_records = FND_API.g_miss_num THEN
      x_complete_rec.min_records := l_model_rec.min_records;
   END IF;

   -- max_records
   IF p_dm_model_rec.max_records = FND_API.g_miss_num THEN
      x_complete_rec.max_records := l_model_rec.max_records;
   END IF;

   -- row_selection_type
   IF p_dm_model_rec.row_selection_type = FND_API.g_miss_char THEN
      x_complete_rec.row_selection_type := l_model_rec.row_selection_type;
   END IF;

   -- every_nth_row
   IF p_dm_model_rec.every_nth_row = FND_API.g_miss_num THEN
      x_complete_rec.every_nth_row := l_model_rec.every_nth_row;
   END IF;

   -- pct_random
   IF p_dm_model_rec.pct_random = FND_API.g_miss_num THEN
      x_complete_rec.pct_random := l_model_rec.pct_random;
   END IF;

   -- performance
   IF p_dm_model_rec.performance = FND_API.g_miss_num THEN
      x_complete_rec.performance := l_model_rec.performance;
   END IF;

   -- target_group_type
   IF p_dm_model_rec.target_group_type = FND_API.g_miss_char THEN
      x_complete_rec.target_group_type := l_model_rec.target_group_type;
   END IF;

   -- darwin_model_ref
   IF p_dm_model_rec.darwin_model_ref = FND_API.g_miss_char THEN
      x_complete_rec.darwin_model_ref := l_model_rec.darwin_model_ref;
   END IF;

   -- attribute_category
   IF p_dm_model_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_model_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_dm_model_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_model_rec.attribute1;
   END IF;

   -- attribute2
   IF p_dm_model_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_model_rec.attribute2;
   END IF;

   -- attribute3
   IF p_dm_model_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_model_rec.attribute3;
   END IF;

   -- attribute4
   IF p_dm_model_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_model_rec.attribute4;
   END IF;

   -- attribute5
   IF p_dm_model_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_model_rec.attribute5;
   END IF;

   -- attribute6
   IF p_dm_model_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_model_rec.attribute6;
   END IF;

   -- attribute7
   IF p_dm_model_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_model_rec.attribute7;
   END IF;

   -- attribute8
   IF p_dm_model_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_model_rec.attribute8;
   END IF;

   -- attribute9
   IF p_dm_model_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_model_rec.attribute9;
   END IF;

   -- attribute10
   IF p_dm_model_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_model_rec.attribute10;
   END IF;

   -- attribute11
   IF p_dm_model_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_model_rec.attribute11;
   END IF;

   -- attribute12
   IF p_dm_model_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_model_rec.attribute12;
   END IF;

   -- attribute13
   IF p_dm_model_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_model_rec.attribute13;
   END IF;

   -- attribute14
   IF p_dm_model_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_model_rec.attribute14;
   END IF;

   -- attribute15
   IF p_dm_model_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_model_rec.attribute15;
   END IF;

   -- best_subtree
   IF p_dm_model_rec.best_subtree = FND_API.g_miss_num THEN
      x_complete_rec.best_subtree := l_model_rec.best_subtree;
   END IF;

   -- custom_setup_id
   IF p_dm_model_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_model_rec.custom_setup_id;
   END IF;

   -- country_id
   IF p_dm_model_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := l_model_rec.country_id;
   END IF;

   -- wf_itemkey
   IF p_dm_model_rec.wf_itemkey = FND_API.g_miss_char THEN
      x_complete_rec.wf_itemkey := l_model_rec.wf_itemkey;
   END IF;

   -- target_id
   IF p_dm_model_rec.target_id = FND_API.g_miss_num THEN
      x_complete_rec.target_id := l_model_rec.target_id;
   END IF;

END Complete_dm_model_rec;

-------------------------------------------------------------------------------------
-- Procedure name     : Validate_dm_model
-- Purpose        : Validate for table ams_dm_models_all_b
--                      It contains items checking and records checking
-- History
-- 21-Feb-2001 choang   Added p_validation_mode to validate_rec callout.
-------------------------------------------------------------------------------------
PROCEDURE Validate_dm_model(
   p_api_version_number IN   NUMBER,
   p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_validation_mode    IN   VARCHAR2,
   p_dm_model_rec       IN   DM_MODEL_Rec_Type,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_dm_model';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_DM_MODEL;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                      p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Private API:call Check_DM_MODEL_Items');
         END IF;
         Check_dm_model_items(
            p_dm_model_rec    => p_dm_model_rec,
            p_validation_mode => p_validation_mode,
            x_return_status   => x_return_status);
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_dm_model_rec (
            p_api_version_number  => 1.0,
            p_init_msg_list       => fnd_api.g_false,
            p_validation_mode     => p_validation_mode,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_dm_model_rec        => p_dm_model_rec);
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
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
     ROLLBACK TO VALIDATE_DM_MODEL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_DM_MODEL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_DM_MODEL;
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
End Validate_dm_model;


--
-- History
-- 21-Feb-2001 choang   Created.
PROCEDURE check_access (
   p_model_rec       IN dm_model_rec_type,
   p_validation_mode IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_MODEL_QUALIFIER       CONSTANT VARCHAR2(30) := 'MODL';
   L_ACCESS_TYPE_USER      CONSTANT VARCHAR2(30) := 'USER';

   -- user id of the currently logged in user.
   l_owner_user_id         NUMBER := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--IF (AMS_DEBUG_HIGH_ON) THENams_utility_pvt.debug_message ('qualifier: ' || l_model_qualifier || ' id: ' || p_model_rec.model_id || ' resource: ' || l_owner_user_id);END IF;
   -- validate access privileges
   IF AMS_Access_PVT.check_update_access (
         p_object_id       => p_model_rec.model_id,
         p_object_type     => L_MODEL_QUALIFIER,
         p_user_or_role_id => l_owner_user_id,
         p_user_or_role_type  => L_ACCESS_TYPE_USER) = 'N' THEN
      AMS_Utility_PVT.error_message ('AMS_MODEL_NO_UPDATE_ACCESS');
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END check_access;


--
-- History
-- 06-Mar-2001 choang   Created.
--
PROCEDURE expire_models (
   errbuf      OUT NOCOPY VARCHAR2,
   retcode     OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Expire Models';
--   L_STATUS_CODE_EXPIRED      CONSTANT VARCHAR2(30) := 'EXPIRED';

   l_new_status_id            VARCHAR2(30);

   CURSOR c_expired_models IS
      SELECT model_id, status_code
      FROM   ams_dm_models_all_b
      WHERE  status_code <> 'EXPIRED'
      AND    expiration_date <= SYSDATE
      ;

   CURSOR c_user_status_id IS
      SELECT user_status_id
      FROM   ams_user_statuses_b
      WHERE  system_status_type = G_MODEL_STATUS_TYPE
      AND    system_status_code = G_MODEL_STATUS_EXPIRED
      ;
BEGIN
   retcode := 0;

   FOR l_expired_models_rec IN c_expired_models LOOP
      OPEN c_user_status_id;
      FETCH c_user_status_id INTO l_new_status_id;
      CLOSE c_user_status_id;

      UPDATE ams_dm_models_all_b
      SET    user_status_id = l_new_status_id
             , status_code = G_MODEL_STATUS_EXPIRED
             , status_date = SYSDATE
             , object_version_number = object_version_number + 1
             , last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
      WHERE  model_id = l_expired_models_rec.model_id;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := L_API_NAME || ': ' || sqlerrm;
END expire_models;


--
-- History
-- 08-Mar-2001 choang   Created.
-- 11-Apr-2001 choang   Changed procedure spec and use global cursor
--
PROCEDURE wf_revert (
   p_model_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id  VARCHAR2(30);
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, p_status_code);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_models_all_b
   SET    last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.conc_login_id
        , object_version_number = object_version_number + 1
        , status_code = p_status_code
        , user_status_id = l_user_status_id
        , status_date = SYSDATE
   WHERE  model_id = p_model_id;
END wf_revert;


--
-- Note
--    Currently, only updates the status
--    back to AVAILABLE.
-- History
-- 08-Mar-2001 choang   Created.
--
PROCEDURE unexpire_model (
   p_model_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_MODEL_STATUS_AVAILABLE);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_models_all_b
   SET    object_version_number = object_version_number + 1
        , last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , status_date = SYSDATE
        , status_code = G_MODEL_STATUS_AVAILABLE
        , user_status_id = l_user_status_id
   WHERE  model_id = p_model_id;
END unexpire_model;


PROCEDURE process_build_success (
   p_model_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id     NUMBER;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, p_status_code);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_models_all_b
   SET    object_version_number = object_version_number + 1
        , last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , status_date = SYSDATE
        , status_code = p_status_code
        , user_status_id = l_user_status_id
        , last_build_date = SYSDATE
        , results_flag = 'Y'
   WHERE  model_id = p_model_id;
END process_build_success;


-- History
-- 25-Sep-2002 nyostos   Created.
-- cancel_build_request cancels the Build workflow process.
-- If the Model is in SCHEDULED/QUEUED state (i.e. the first step
-- in the WF process has not started yet), the Model status will be
-- reverted to its previous status. If the Model status is BUILDING (i.e. the Workflow
-- process is in progress), then the Model status will be set to DRAFT.

PROCEDURE cancel_build_request (
   p_model_id           IN NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_ref_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;
   l_ref_model_rec      c_ref_model%ROWTYPE;

   L_API_NAME           CONSTANT VARCHAR2(30) := 'cancel_build_request';

   l_original_status_id    VARCHAR2(30);
   l_status_code           VARCHAR2(30);
   l_user_status_id        NUMBER;
   l_return_status         VARCHAR2(1);

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
      p_log_used_by_id  => p_model_id,
      p_msg_data        => L_API_NAME || ': begin '
   );

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Load the model record to get the original status and wf_itemkey
   OPEN c_ref_model (p_model_id);
   FETCH c_ref_model INTO l_ref_model_rec;
   CLOSE c_ref_model;


   IF l_ref_model_rec.wf_itemkey IS NOT NULL THEN

      IF l_ref_model_rec.status_code = G_MODEL_STATUS_SCHEDULED OR
         l_ref_model_rec.status_code = G_MODEL_STATUS_QUEUED    OR
         l_ref_model_rec.status_code = G_MODEL_STATUS_BUILDING  THEN

         -- Get the original status of the Model when then the WF process was scheduled
         AMS_WFMOD_PVT.get_original_status(
            p_itemkey         => l_ref_model_rec.wf_itemkey,
            x_orig_status_id  => l_original_status_id,
            x_return_status   => x_return_status
         );

         AMS_WFMod_PVT.cancel_process (
            p_itemkey         => l_ref_model_rec.wf_itemkey,
            x_return_status   => x_return_status
         );


         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            -- Report that an error occurred, but ifgnore it and proceed with re-setting
            -- the Model status.
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
               p_log_used_by_id  => p_model_id,
               p_msg_data        => L_API_NAME || ': Error while canceling Model Build '
            );

            --RAISE FND_API.G_EXC_ERROR;
         ELSE
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
               p_log_used_by_id  => p_model_id,
               p_msg_data        => L_API_NAME || ': Model Build Process Canceled '
            );
         END IF;

         -- Set wf_itemkey to null
         l_ref_model_rec.wf_itemkey := NULL;

         IF l_ref_model_rec.status_code = G_MODEL_STATUS_BUILDING THEN

            -- Model was in BUILDING status, then set its status to DRAFT
            l_ref_model_rec.status_code := G_DEFAULT_STATUS;

            -- Set results_flag to 'N', since all model results have been cleaned
            l_ref_model_rec.results_flag := 'N';

            -- Set the user_status_id associated with the new status code
            OPEN c_user_status_id (G_MODEL_STATUS_TYPE, l_ref_model_rec.status_code);
            FETCH c_user_status_id INTO l_ref_model_rec.user_status_id;
            CLOSE c_user_status_id;

         ELSE
            -- Model was in SCHEDULED/QUEUED status, set its status to its original status
            -- when the WF process was started

            l_ref_model_rec.user_status_id := l_original_status_id;

            -- Set the system_status_code associated with the original status id
            OPEN c_user_status_code (G_MODEL_STATUS_TYPE, l_ref_model_rec.user_status_id);
            FETCH c_user_status_code INTO l_ref_model_rec.status_code;
            CLOSE c_user_status_code;

         END IF;


         -- update the Model record with new status code and id and with NULL wf_itemkey
         UPDATE ams_dm_models_all_b
         SET object_version_number  = object_version_number + 1,
             last_update_date       = SYSDATE,
             last_updated_by        = FND_GLOBAL.user_id,
             status_date            = SYSDATE,
             status_code            = l_ref_model_rec.status_code,
             user_status_id         = l_ref_model_rec.user_status_id,
             wf_itemkey             = l_ref_model_rec.wf_itemkey,
             results_flag           = l_ref_model_rec.results_flag
         WHERE model_id = p_model_id;
      ELSE
         -- No Build Request/Process to cancel
         -- Set x_return_status to expected error. This will results in a different message
         -- displayed to the user
         x_return_status := FND_API.G_RET_STS_ERROR;
         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
            p_log_used_by_id  => p_model_id,
            p_msg_data        => L_API_NAME || ': No Model Build To Cancel '
         );
      END IF;
   ELSE
      -- No Build Request/Process to cancel
      -- Set x_return_status to expected error. This will results in a different message
      -- displayed to the user
      x_return_status := FND_API.G_RET_STS_ERROR;
         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
            p_log_used_by_id  => p_model_id,
            p_msg_data        => L_API_NAME || ': No Model Build To Cancel '
         );
   END IF;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_OBJECT_TYPE_MODEL,
      p_log_used_by_id  => p_model_id,
      p_msg_data        => L_API_NAME || ': End '
   );

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

END cancel_build_request;

-- History
-- 18-Sep-2002 nyostos   Created.
-- Overloaded procedure. New implementation in 11.5.9 to start
-- the Build/Score/Preview Workflow process to handle Preview instead of
-- starting the AMS_DM_PREVIEW concurrent program.

PROCEDURE handle_preview_request (
   p_model_id        IN NUMBER,
   x_monitor_url     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_MODEL_QUALIFIER       CONSTANT VARCHAR2(30) := 'MODL';
   L_ACCESS_TYPE_USER      CONSTANT VARCHAR2(30) := 'USER';
   l_owner_user_id         NUMBER := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);

   l_proceedWithPreviewFlag VARCHAR2(1);
   l_data_exists_flag       VARCHAR2(1);
   l_target_id              NUMBER;
   l_is_enabled             BOOLEAN;

   CURSOR c_ref_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;

   CURSOR c_target (p_model_id IN NUMBER) IS
      SELECT target_id from ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;

   l_ref_model_rec      c_ref_model%ROWTYPE;

   l_tar_model_rec      ams_dm_model_pvt.dm_model_rec_type;

   L_API_NAME        CONSTANT VARCHAR2(30) := 'handle_preview_request';

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Load the model record to get the original status
   OPEN c_ref_model (p_model_id);
   FETCH c_ref_model INTO l_ref_model_rec;
   CLOSE c_ref_model;

   --First check if the user has access to preview operation
   IF AMS_Access_PVT.check_update_access (
         p_object_id       => p_model_id,
         p_object_type     => L_MODEL_QUALIFIER,
         p_user_or_role_id => l_owner_user_id,
         p_user_or_role_type  => L_ACCESS_TYPE_USER) = 'N' THEN
      x_return_status := 'A';
      return;
   END IF;

   --Check if the target is enabled
   OPEN c_target(p_model_id);
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
   proceedWithPreview (p_model_id, l_proceedWithPreviewFlag);
   IF l_proceedWithPreviewFlag = 'N' THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Cannot Proceed with Preview');
      END IF;
      -- Set x_return_status to expected error. This will results in a different message
      -- displayed to the user
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   dataToPreview (p_model_id, l_data_exists_flag);
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
      p_model_id        => p_model_id,
      p_orig_status_id  => l_ref_model_rec.user_status_id,
      x_tar_model_rec   => l_tar_model_rec,
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
   x_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_tar_model_rec.wf_itemkey, 'NO');

   -- Update the Model record with the new status code (PREVIEWING) and Id
   -- and also with the WF Item Key
   UPDATE ams_dm_models_all_b
   SET logs_flag              = 'Y',
       object_version_number  = object_version_number + 1,
       last_update_date       = SYSDATE,
       last_updated_by        = FND_GLOBAL.user_id,
       status_date            = SYSDATE,
       status_code            = l_tar_model_rec.status_code,
       user_status_id         = l_tar_model_rec.user_status_id,
       wf_itemkey             = l_tar_model_rec.wf_itemkey
   WHERE model_id = p_model_id;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

END handle_preview_request;




--
-- History
-- 11-Mar-2001 choang   Created.
-- 19-Sep-2002 nyostos  This procedure has been deprecated in 11.5.9. It
--                      is left for backward compatibility. It calls the
--                      overloaded handle_preview_request which starts
--                      the build/score workflow process instead of starting
--                      the AMS_DM_PREVIEW Concurrent Program.
PROCEDURE handle_preview_request (
   p_model_id     IN NUMBER,
   x_request_id   OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_monitor_url  VARCHAR2(1);

BEGIN

   handle_preview_request ( p_model_id,
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
-- 05-Apr-2001 choang   Created.
-- 20-Apr-2001 sveerave Changed column names to be of application column names from db column names
--                      in get_column_value call-out.
PROCEDURE copy_model (
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
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_model';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;

   l_new_model_id    NUMBER;
   l_model_rec       dm_model_rec_type;
   l_custom_setup_id NUMBER;

   -- for non-standard out params in copy_act_access
   l_errnum          NUMBER;
   l_errcode         VARCHAR2(30);
   l_errmsg          VARCHAR2(4000);

   CURSOR c_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;
   --start changes rosharma 20-aug-2003 bug 3104201
   CURSOR c_data_source (p_model_id IN NUMBER) IS
      SELECT t.DATA_SOURCE_ID
      FROM   ams_dm_models_all_b m,ams_dm_targets_b t
      WHERE  m.model_id = p_model_id
      AND    m.target_id = t.target_id
      ;

   l_ds_id    NUMBER;
   --end changes rosharma 20-aug-2003 bug 3104201
   l_reference_rec      c_model%ROWTYPE;
   l_new_model_rec      c_model%ROWTYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT ams_model_pvt_copy_model;

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
   -- Initialize the new model record
   -- use ams_cpyutility_pvt.get_column_value to fetch a value
   -- to replace the reference column value with a new value
   -- passed in from the UI through p_copy_columns_table.
   OPEN c_model (p_source_object_id);
   FETCH c_model INTO l_reference_rec;
   CLOSE c_model;

   -- copy all required fields
   l_model_rec.model_type := l_reference_rec.model_type;
   l_model_rec.target_group_type := l_reference_rec.target_group_type;
   l_model_rec.status_code := G_DEFAULT_STATUS;
   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, l_model_rec.status_code);
   FETCH c_user_status_id INTO l_model_rec.user_status_id;
   CLOSE c_user_status_id;
   l_model_rec.row_selection_type := l_reference_rec.row_selection_type;

   --added rosharma 10-Feb-2003 for copying pct_random and nth_row correctly
   IF l_model_rec.row_selection_type = 'NTH_RECORD' THEN
      l_model_rec.every_nth_row := l_reference_rec.every_nth_row;
   END IF;

   IF l_model_rec.row_selection_type = 'RANDOM' THEN
      l_model_rec.pct_random := l_reference_rec.pct_random;
   END IF;
   --end add rosharma 10-Feb-2003 for copying pct_random and nth_row correctly
   --added rosharma 04-sep-2003 bug # 3127555
   l_model_rec.min_records := l_reference_rec.min_records;
   l_model_rec.max_records := l_reference_rec.max_records;
   --end add rosharma 04-sep-2003 bug # 3127555

   l_model_rec.target_id := l_reference_rec.target_id;

   --copy the flex field data. fix for 4220828
   l_model_rec.ATTRIBUTE_CATEGORY  := l_reference_rec.ATTRIBUTE_CATEGORY;
   l_model_rec.ATTRIBUTE1  := l_reference_rec.ATTRIBUTE1;
   l_model_rec.ATTRIBUTE2  := l_reference_rec.ATTRIBUTE2;
   l_model_rec.ATTRIBUTE3  := l_reference_rec.ATTRIBUTE3;
   l_model_rec.ATTRIBUTE4  := l_reference_rec.ATTRIBUTE4;
   l_model_rec.ATTRIBUTE5  := l_reference_rec.ATTRIBUTE5;
   l_model_rec.ATTRIBUTE6  := l_reference_rec.ATTRIBUTE6;
   l_model_rec.ATTRIBUTE7  := l_reference_rec.ATTRIBUTE7;
   l_model_rec.ATTRIBUTE8  := l_reference_rec.ATTRIBUTE8;
   l_model_rec.ATTRIBUTE9  := l_reference_rec.ATTRIBUTE9;
   l_model_rec.ATTRIBUTE10 := l_reference_rec.ATTRIBUTE10;
   l_model_rec.ATTRIBUTE11 := l_reference_rec.ATTRIBUTE11;
   l_model_rec.ATTRIBUTE12 := l_reference_rec.ATTRIBUTE12;
   l_model_rec.ATTRIBUTE13 := l_reference_rec.ATTRIBUTE13;
   l_model_rec.ATTRIBUTE14 := l_reference_rec.ATTRIBUTE14;
   l_model_rec.ATTRIBUTE15 := l_reference_rec.ATTRIBUTE15;

   -- if field is not passed in from copy_columns_table
   -- copy from the base object
   AMS_CpyUtility_PVT.get_column_value ('ownerId', p_copy_columns_table, l_model_rec.owner_user_id);
   l_model_rec.owner_user_id := NVL (l_model_rec.owner_user_id, l_reference_rec.owner_user_id);

   -- if field is not passed in from copy_columns_table
   -- don't copy
   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_model_rec.model_name);
   AMS_CpyUtility_PVT.get_column_value ('expirationDate', p_copy_columns_table, l_model_rec.expiration_date);
   AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_model_rec.description);
   --AMS_CpyUtility_PVT.get_column_value ('mainRandNthRowSel', p_copy_columns_table, l_model_rec.every_nth_row);
   --AMS_CpyUtility_PVT.get_column_value ('mainRandPctRowSel', p_copy_columns_table, l_model_rec.pct_random);
   --commented rosharma 04-sep-2003 bug # 3127555
   --AMS_CpyUtility_PVT.get_column_value ('minRequested', p_copy_columns_table, l_model_rec.min_records);
   --AMS_CpyUtility_PVT.get_column_value ('maxRequested', p_copy_columns_table, l_model_rec.max_records);
   --end comment rosharma 04-sep-2003 bug # 3127555

   AMS_DM_Model_PVT.create_dm_model (
      p_api_version_number => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   => p_validation_level,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_dm_model_rec    => l_model_rec,
      x_custom_setup_id => l_custom_setup_id,
      x_model_id        => l_new_model_id
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- copy training data
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_CopyElements_PVT.G_ATTRIBUTE_TRNG, p_attributes_table) = FND_API.G_TRUE THEN

      -- fix for bug 4333415. Workbook has to be copied for custom model also
      AMS_CopyElements_PVT.copy_list_select_actions (
          p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_FALSE,
          p_commit          => FND_API.G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_object_type     => G_OBJECT_TYPE_MODEL,
          p_src_object_id   => p_source_object_id,
          p_tar_object_id   => l_new_model_id
      );

      IF l_reference_rec.target_id >= G_SEEDED_ID_THRESHOLD THEN
         --start changes rosharma 20-aug-2003 bug 3104201
         OPEN c_data_source (p_source_object_id);
          FETCH c_data_source INTO l_ds_id;
         CLOSE c_data_source;

	 AMS_Adv_Filter_PVT.copy_filter_data (
		   p_api_version        => 1.0,
		   p_init_msg_list      => FND_API.G_FALSE,
		   p_commit             => FND_API.G_FALSE,
		   p_validation_level   => p_validation_level,
		   p_objType            => G_OBJECT_TYPE_MODEL,
		   p_old_objectId       => p_source_object_id,
		   p_new_objectId       => l_new_model_id,
		   p_dataSourceId       => l_ds_id,
		   x_return_status      => x_return_status,
		   x_msg_count          => x_msg_count,
		   x_msg_data           => x_msg_data
         );
      ELSE
      --end changes rosharma 20-aug-2003 bug 3104201
        -- kbasavar to copy product info for Product affinity model
        IF l_model_rec.model_type='PRODUCT_AFFINITY' THEN
             l_errnum := 0;
             l_errcode := NULL;
             l_errmsg := NULL;
             ams_copyelements_pvt.copy_act_prod (
                      p_src_act_type  => 'MODL',
                      p_new_act_type  => 'MODL',
                      p_src_act_id    => p_source_object_id,
                      p_new_act_id    => l_new_model_id,
                      p_errnum        => l_errnum,
                      p_errcode       => l_errcode,
                      p_errmsg        => l_errmsg
             );

	    IF (l_errnum <> 0) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
	END IF;
      END IF;
        -- kbasavar end changes
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy team
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_CopyElements_PVT.G_ATTRIBUTE_TEAM, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_access (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_model_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
   END IF;

   -- currently, only needed to fetch custom_setup_id
   -- but can be used to return other values later.
   OPEN c_model (l_new_model_id);
   FETCH c_model INTO l_new_model_rec;
   CLOSE c_model;

   x_new_object_id := l_new_model_id;
   x_custom_setup_id := l_custom_setup_id;
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
      ROLLBACK TO ams_model_pvt_copy_model;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ams_model_pvt_copy_model;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO ams_model_pvt_copy_model;
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
END copy_model;


--
-- History
-- 11-Apr-2001 choang   Created.
PROCEDURE wf_build (
   p_model_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_user_status_id  VARCHAR2(30);
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- When the Model status is BUILDING, then we cleanup previous
   -- Model results.
   cleanupPreviousBuildData(p_model_id);

   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_MODEL_STATUS_BUILDING);
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   UPDATE ams_dm_models_all_b
   SET    last_update_date = SYSDATE
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.conc_login_id
        , object_version_number = object_version_number + 1
        , status_code = G_MODEL_STATUS_BUILDING
        , user_status_id = l_user_status_id
        , status_date = SYSDATE
   WHERE  model_id = p_model_id;
END wf_build;


PROCEDURE wf_startprocess (
   p_model_id IN NUMBER,
   p_scheduled_date IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   p_orig_status_id IN NUMBER,
   x_tar_model_rec IN OUT NOCOPY dm_model_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   -- used with get_user_timezone api
   l_user_timezone_name    VARCHAR2(80);
BEGIN
   IF p_scheduled_timezone_id IS NULL THEN
      AMS_Utility_PVT.get_user_timezone (
         x_return_status   => x_return_status,
         x_user_time_id    => x_tar_model_rec.scheduled_timezone_id,
         x_user_time_name  => l_user_timezone_name
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      x_tar_model_rec.scheduled_timezone_id := p_scheduled_timezone_id;
   END IF;

   -- 28-Jun-2002 nyostos
   -- Cleanup previous model test, lift and important attributes information

   -- 18-Sep-2002 - We are not cleaning model results when the Model is SCHEDULED
   -- because now we allow the user to cancel the scheduled build operation. When the Model
   -- status becomes BUILDING, then we will call cleanup.
   -- cleanupPreviousBuildData(p_model_id);

   x_tar_model_rec.status_code := G_MODEL_STATUS_SCHEDULED;
   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, x_tar_model_rec.status_code);
   FETCH c_user_status_id INTO x_tar_model_rec.user_status_id;
   CLOSE c_user_status_id;

   -- Initiate Workflow process and grab the itemkey
   AMS_WFMOD_PVT.StartProcess(
      p_object_id       => p_model_id,
      p_object_type     => G_OBJECT_TYPE_MODEL,
      p_user_status_id  => p_orig_status_id,
      p_scheduled_timezone_id => x_tar_model_rec.scheduled_timezone_id,
      p_scheduled_date  => p_scheduled_date,
      p_request_type    => NULL,
      p_select_list     => NULL,
      x_itemkey         => x_tar_model_rec.wf_itemkey
   );

   IF x_tar_model_rec.wf_itemkey IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END wf_startprocess;


PROCEDURE wf_startPreviewProcess (
   p_model_id        IN NUMBER,
   p_orig_status_id  IN NUMBER,
   x_tar_model_rec   IN OUT NOCOPY dm_model_rec_type,
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
      x_sys_time_id    => x_tar_model_rec.scheduled_timezone_id,
      x_sys_time_name  => l_user_timezone_name
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      AMS_UTILITY_PVT.debug_message(' Error in get_user_timezone.');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- When we submit a Preview request, we clean up all the previous
   -- Model results since we assume that the data selections may have
   -- changed which means that the previous results do not match the
   -- data selections.
   cleanupPreviousBuildData(p_model_id);

   -- Set the Model status to PREVIEWING
   x_tar_model_rec.status_code := G_MODEL_STATUS_PREVIEWING;
   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, x_tar_model_rec.status_code);
   FETCH c_user_status_id INTO x_tar_model_rec.user_status_id;
   CLOSE c_user_status_id;

   -- Initiate Workflow process and grab the itemkey
   AMS_WFMOD_PVT.StartProcess(
      p_object_id       => p_model_id,
      p_object_type     => G_OBJECT_TYPE_MODEL,
      p_user_status_id  => p_orig_status_id,
      p_scheduled_timezone_id => x_tar_model_rec.scheduled_timezone_id,
      p_scheduled_date  => SYSDATE,
      p_request_type    => 'PREVIEW',
      p_select_list     => NULL,
      x_itemkey         => x_tar_model_rec.wf_itemkey
   );

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
   END IF;

   IF x_tar_model_rec.wf_itemkey IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      --RAISE FND_API.G_EXC_ERROR;
   END IF;


END wf_startPreviewProcess;


--
-- History
-- 28-Jun-2002 nyostos   Created.
PROCEDURE cleanupPreviousBuildData(
    p_MODEL_ID  NUMBER)
 IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'cleanupPreviousBuildData';

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Remove DM Source records
   delete /*+ index(AMS_DM_SOURCE AMS_DM_SOURCE_U2) */ from ams_dm_source
   where  arc_used_for_object = 'MODL'
   and used_for_object_id = p_MODEL_ID;

   -- Remove Category Matrix entries for this model
   DELETE FROM ams_dm_performance
    WHERE MODEL_ID = p_MODEL_ID;

   -- Remove Lift entries for this model
   DELETE FROM ams_dm_lift
    WHERE MODEL_ID = p_MODEL_ID;

   -- Remove Important Attribte entries for this model
   DELETE FROM ams_dm_imp_attributes
    WHERE MODEL_ID = p_MODEL_ID;

   -- Set the results_flag to 'N'
   UPDATE ams_dm_models_all_b
    SET results_flag = 'N'
    WHERE MODEL_ID = p_MODEL_ID;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End.');
   END IF;

 END cleanupPreviousBuildData;

--
-- Purpose
-- Returns Model Status_Code and User_Status_Id for a Model
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE getModelStatus(
   p_model_id        IN    NUMBER,
   x_status_code     OUT NOCOPY   VARCHAR2,
   x_user_status_id  OUT NOCOPY   NUMBER
)
IS

   L_API_NAME        CONSTANT VARCHAR2(30) := 'getModelStatus';
--   l_return_status   VARCHAR2(1);

   CURSOR c_model_status (p_model_id IN NUMBER) IS
      SELECT status_code, user_status_id
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Get the model status
   OPEN c_model_status (p_model_id);
   FETCH c_model_status INTO x_status_code, x_user_status_id;
   CLOSE c_model_status;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. Model Status Code = ' || x_status_code);
   END IF;

END getModelStatus;

--
-- Purpose
-- To check if there is data selected to be Previewed. We cannot Preview
-- data selections for a Model with seeded data source if it has no campaign
-- schedule, list, segment, workbook,... selected.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE dataToPreview(
   p_model_id           IN    NUMBER,
   x_data_exists_flag   OUT NOCOPY   VARCHAR2
)
IS

   l_seeded_ds_flag           VARCHAR2(1);
   l_data_selections_count    NUMBER;
   l_model_type        VARCHAR (30);
   l_prod_selections_count    NUMBER;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'dataToPreview';

   CURSOR l_dataSelectionsExist (p_model_id IN NUMBER) IS
     SELECT count(*)
       FROM ams_list_select_actions
      WHERE arc_action_used_by = 'MODL'
        AND action_used_by_id = p_model_id;

   CURSOR c_model_type(p_model_id IN NUMBER) IS
      SELECT  m.model_type
      FROM   ams_dm_models_all_b m
      WHERE  m.model_id = p_model_id
      ;

   CURSOR c_prodSelectionExist(p_model_id IN NUMBER) IS
     SELECT count(*)
     FROM ams_act_products
     WHERE arc_act_product_used_by = 'MODL'
     AND act_product_used_by_id = p_model_id;


BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize x_data_exists_flag to 'Y'
   x_data_exists_flag := 'Y';

   -- Initialize l_seeded_ds_flag to 'N'
   l_seeded_ds_flag := 'N';

   -- Check if Model has a seeded data source
   seededDataSource (p_model_id, l_seeded_ds_flag);

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' l_seeded_ds_flag = ' || l_seeded_ds_flag);
   END IF;

   IF l_seeded_ds_flag = 'Y' THEN

      l_data_selections_count := 0;

      -- Check if the Model has any data selections
      OPEN l_dataSelectionsExist (p_model_id);
      FETCH l_dataSelectionsExist INTO l_data_selections_count;
      CLOSE l_dataSelectionsExist;

      -- If no data selections exist, then set the flag to N
      IF l_data_selections_count IS NULL or l_data_selections_count = 0 THEN
         x_data_exists_flag := 'N';
      END IF;

      --kbasavar for Product affiity
      OPEN c_model_type (p_model_id);
      FETCH c_model_type INTO l_model_type;
      CLOSE c_model_type;

      IF l_model_type = 'PRODUCT_AFFINITY' THEN
          OPEN c_prodSelectionExist(p_model_id);
	  FETCH c_prodSelectionExist into l_prod_selections_count;
	  CLOSE c_prodSelectionExist;

          IF l_prod_selections_count IS NULL or l_prod_selections_count = 0 THEN
	      x_data_exists_flag := 'N';
          END IF;
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
-- data selections for a Model if it has any of the following statuses:
-- SCHEDULED, BUILDING, SCORING, PREVIEWING, ARCHIVED, QUEUED, EXPIRED.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE proceedWithPreview(
   p_model_id        IN    NUMBER,
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

   -- Check Model Status Code
   getModelStatus( p_model_id, l_status_code , l_user_status_id);

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Status Code = ' || l_status_code);
   END IF;

   IF l_status_code = G_MODEL_STATUS_SCHEDULED  OR
      l_status_code = G_MODEL_STATUS_BUILDING   OR
      l_status_code = G_MODEL_STATUS_SCORING    OR
      l_status_code = G_MODEL_STATUS_QUEUED     OR
      l_status_code = G_MODEL_STATUS_PREVIEWING OR
      l_status_code = G_MODEL_STATUS_ARCHIVED   OR
      l_status_code = G_MODEL_STATUS_EXPIRED

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
-- To check if Model is using a Seeded data source.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE seededDataSource(
   p_model_id     IN    NUMBER,
   x_seeded_flag  OUT NOCOPY   VARCHAR2
)
IS
   l_target_id  NUMBER;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'seededDataSource';

   CURSOR  l_datasource (p_model_id IN NUMBER) IS
    SELECT target_id
      FROM ams_dm_models_all_b
     WHERE model_id  = p_model_id;
BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   END IF;

   -- Initialize proceed flag to 'Y'
   x_seeded_flag := 'Y';

   -- Get the Data Source Id for the model
   OPEN l_datasource (p_model_id);
   FETCH l_datasource INTO l_target_id;
   CLOSE l_datasource;

   -- Check if the data source id is greater or equal to the G_SEEDED_ID_THRESHOLD
   IF l_target_id >= G_SEEDED_ID_THRESHOLD THEN
      x_seeded_flag := 'N';
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End. Seeded Flag = ' || x_seeded_flag);
   END IF;

END seededDataSource;

--
-- Purpose
-- To check if Model data selection sizing options and selection
-- method have changed. This would INVALIDate an AVAILABLE model.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE check_data_size_changes(
   p_input_model_rec          IN    DM_MODEL_Rec_Type,
   x_selections_changed_flag  OUT NOCOPY   VARCHAR2
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'check_data_size_changes';

   CURSOR c_ref_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;
   l_ref_model_rec  c_ref_model%ROWTYPE;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Begin.');
   END IF;

   x_selections_changed_flag := 'N';

   -- get the reference model, which contains
   -- data before the update operation.
   OPEN c_ref_model (p_input_model_rec.model_id);
   FETCH c_ref_model INTO l_ref_model_rec;
   CLOSE c_ref_model;

   -- min records
   IF (l_ref_model_rec.MIN_RECORDS IS NULL AND p_input_model_rec.MIN_RECORDS IS NOT NULL) OR
       (l_ref_model_rec.MIN_RECORDS <> p_input_model_rec.MIN_RECORDS) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- max records
   IF (l_ref_model_rec.MAX_RECORDS IS NULL  AND p_input_model_rec.MAX_RECORDS IS NOT NULL) OR
       (l_ref_model_rec.MAX_RECORDS <> p_input_model_rec.MAX_RECORDS) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- row_selection_type
   IF (l_ref_model_rec.row_selection_type IS NULL  AND p_input_model_rec.row_selection_type IS NOT NULL) OR
       (l_ref_model_rec.row_selection_type <> p_input_model_rec.row_selection_type) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

    -- every_nth_row
   IF (l_ref_model_rec.EVERY_NTH_ROW IS NULL  AND p_input_model_rec.EVERY_NTH_ROW IS NOT NULL) OR
       (l_ref_model_rec.EVERY_NTH_ROW <> p_input_model_rec.EVERY_NTH_ROW) THEN
      x_selections_changed_flag := 'Y';
      RETURN;
   END IF;

   -- pct_random
   IF (l_ref_model_rec.PCT_RANDOM IS NULL  AND p_input_model_rec.PCT_RANDOM IS NOT NULL) OR
       (l_ref_model_rec.PCT_RANDOM <> p_input_model_rec.PCT_RANDOM) THEN
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
-- Procedure to handle data selection changes
-- This would INVALIDate an AVAILABLE model.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE handle_data_selection_changes(
   p_model_id                 IN    NUMBER
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'handle_data_selection_changes';

   CURSOR c_ref_model (p_model_id IN NUMBER) IS
      SELECT *
      FROM   ams_dm_models_vl
      WHERE  model_id = p_model_id
      ;
   l_ref_model_rec  c_ref_model%ROWTYPE;

   l_status_id       NUMBER;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Begin.');
   END IF;

   -- Load the model record to get the original status
   OPEN  c_ref_model (p_model_id);
   FETCH c_ref_model INTO l_ref_model_rec;
   CLOSE c_ref_model;

   -- If the Model is AVAILABLE, then change its status to INVALID
   IF l_ref_model_rec.status_code = G_MODEL_STATUS_AVAILABLE THEN

      -- Get the status id for INVALID status code.
      OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_MODEL_STATUS_INVALID);
      FETCH c_user_status_id INTO l_status_id;
      CLOSE c_user_status_id;

      -- update the Scoring Run record with new status code and id and with NULL wf_itemkey
--      UPDATE ams_dm_models_all_b
--      SET object_version_number  = object_version_number + 1,
--          last_update_date       = SYSDATE,
--          last_updated_by        = FND_GLOBAL.user_id,
--          status_date            = SYSDATE,
--          status_code            = G_MODEL_STATUS_INVALID,
--          user_status_id         = l_status_id
--      WHERE model_id = p_model_id;

      UPDATE ams_dm_models_all_b
      SET last_update_date       = SYSDATE,
          last_updated_by        = FND_GLOBAL.user_id,
          status_date            = SYSDATE,
          status_code            = G_MODEL_STATUS_INVALID,
          user_status_id         = l_status_id
      WHERE model_id = p_model_id;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Invalidated Model.');

      END IF;

   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End.');
   END IF;

END handle_data_selection_changes;

--
-- Purpose
-- Procedure to handle data source changes
-- This would INVALIDate a AVAILABLE Model.
--
-- History
-- 14-Oct-2002 nyostos   Created.
PROCEDURE handle_data_source_changes(
   p_datasource_id            IN    NUMBER
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'handle_data_source_changes';

   CURSOR c_models_using_datasource IS
    SELECT m.model_id, m.status_code
      FROM ams_dm_models_all_b m, ams_dm_targets_b t
     WHERE m.target_id = t.target_id
       AND t.data_source_id  = p_datasource_id
    UNION
    SELECT m.model_id, m.status_code
      FROM ams_dm_models_all_b m, ams_dm_targets_b t, ams_dm_target_sources s
     WHERE m.target_id = t.target_id
       AND s.target_id  = t.target_id
       AND s.data_source_id = p_datasource_id;

   l_status_id       NUMBER;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Begin.');
   END IF;

   -- Get the user status id for INVALID status
   OPEN c_user_status_id (G_MODEL_STATUS_TYPE, G_MODEL_STATUS_INVALID);
   FETCH c_user_status_id INTO l_status_id;
   CLOSE c_user_status_id;

   -- Loop for all models using the given data source id
   FOR l_models IN c_models_using_datasource LOOP

      -- If the model is AVAILABLE, then INVALIDate the model
      IF l_models.status_code = G_MODEL_STATUS_AVAILABLE THEN
         UPDATE ams_dm_models_all_b
            SET object_version_number  = object_version_number + 1,
                last_update_date       = SYSDATE,
                last_updated_by        = FND_GLOBAL.user_id,
                status_date            = SYSDATE,
                status_code            = G_MODEL_STATUS_INVALID,
                user_status_id         = l_status_id
         WHERE  model_id = l_models.model_id;
      END IF;
   END LOOP;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End.');
   END IF;

END handle_data_source_changes;

END Ams_dm_model_pvt;

/
