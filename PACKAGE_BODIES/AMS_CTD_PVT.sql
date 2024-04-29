--------------------------------------------------------
--  DDL for Package Body AMS_CTD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTD_PVT" AS
/* $Header: amsvctdb.pls 120.5 2006/09/06 17:35:51 dbiswas noship $ */

TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ctd_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvctdb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_CTD_PVT
-- Purpose
--
-- This package contains all the program units for Click Through Destinations
--
-- History
--   02/27/04   rrajesh   bugfix: 3470296
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- write_debug_message
--
-- Purpose
-- This is a private procedure to write debug messages to the log table.
--
-- Private procedure to write debug message to FND_LOG table
-- ===============================================================
PROCEDURE write_debug_message(p_log_level       NUMBER,
                              p_procedure_name  VARCHAR2,
                              p_label           VARCHAR2,
                              p_text            VARCHAR2
                              )
IS
   l_module_name  VARCHAR2(400);
   DELIMETER    CONSTANT   VARCHAR2(1) := '.';

BEGIN
   IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      -- Set the Module Name
      l_module_name := 'ams'||DELIMETER||'plsql'||DELIMETER||G_PACKAGE_NAME||DELIMETER||p_procedure_name||DELIMETER||'-'||p_label;


      -- Log the Message
      AMS_UTILITY_PVT.debug_message(p_log_level,
                                    l_module_name,
                                    p_text
                                    );

   END IF;

      --dbms_output.put_line(l_module_name||': '||p_text);

END write_debug_message;
-- ===============================================================
-- Start of Comments
-- Name
-- DELETE_ASSOCIATION_AND_CTD
--
-- Purpose
-- This procedure deletes associations and all relevant CTD information
-- if no other object is using the CTD
--
Procedure DELETE_ASSOCIATION_AND_CTD(
  p_ctd_id_list    JTF_NUMBER_TABLE,
  p_used_by        VARCHAR2,
  p_used_by_val1   VARCHAR2
)
IS
   l_ctd_exists_count NUMBER;

   /* bugfix: 3470296. Added by rrajesh on 02/27/04 */
   CURSOR C_CHECK_CTD_ASSOCIATION_EXISTS
   IS
      SELECT ctd_id
      FROM ams_ctd_associations
      WHERE used_by_type = p_used_by AND used_by_val1 = p_used_by_val1;
   /* End bugfix: 3470296.*/

   /* Bugfix: 4261272. Fix for SQL repository issue: 11753011 */
   /* CURSOR C_GET_NOT_ASSOCIATED_CTD
   IS
   SELECT CTD_LIST1.CTD_ID
   FROM
      (SELECT column_value ctd_id
       FROM TABLE(CAST(p_ctd_id_list as JTF_NUMBER_TABLE)) ) CTD_LIST1
   WHERE CTD_LIST1.CTD_ID NOT IN
      (SELECT ASSOC.CTD_ID
       FROM   AMS_CTD_ASSOCIATIONS assoc,
             (SELECT column_value ctd_id
              FROM TABLE(CAST(p_ctd_id_list as JTF_NUMBER_TABLE))) ctd_list
       WHERE assoc.ctd_id = ctd_list.ctd_id
      ); */
   CURSOR C_GET_NOT_ASSOCIATED_CTD
   IS
   SELECT CTD_LIST1.CTD_ID
    FROM
       (SELECT column_value ctd_id
        FROM TABLE(CAST(p_ctd_id_list as JTF_NUMBER_TABLE)) ) CTD_LIST1
	WHERE NOT EXISTS (select 1 from AMS_CTD_ASSOCIATIONS assoc WHERE
			assoc.ctd_id = ctd_list1.ctd_id);
    /* End Bugfix: 4261272. */

   l_not_associated_ctd_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   PROCEDURE_NAME CONSTANT VARCHAR2(30) := 'DELETE_ASSOCIATION_AND_CTD';

BEGIN

   /* bugfix: 3470296. Added by rrajesh on 02/27/04 */
   -- Check if any CTD is associated to this; if not exit
   OPEN C_CHECK_CTD_ASSOCIATION_EXISTS;
   FETCH C_CHECK_CTD_ASSOCIATION_EXISTS INTO l_ctd_exists_count;
   IF C_CHECK_CTD_ASSOCIATION_EXISTS%NOTFOUND THEN
      CLOSE C_CHECK_CTD_ASSOCIATION_EXISTS;
      RETURN;
   END IF;
   CLOSE C_CHECK_CTD_ASSOCIATION_EXISTS;
   /* End bugfix: 3470296.*/

    write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'BEGIN',
                        'Number of CTDs to be deleted = '||to_char(p_ctd_id_list.count)|| 'for Used By = '||p_used_by|| 'Used By Id = '||p_used_by_val1
                       );
    write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'BEFORE_BULK_DELETE_ASSOCIATION',
                        'Before bulk delete of association'
                       );
   -- Delete the association
   FORALL i in p_ctd_id_list.FIRST .. p_ctd_id_list.LAST
   DELETE FROM AMS_CTD_ASSOCIATIONS
   WHERE CTD_ID = p_ctd_id_list(i)
   and used_by_type = p_used_by
   and used_by_val1 = p_used_by_val1;

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_BULK_DELETE_ASSOCIATION',
                        'Associations Deleted Successfully!!'
                       );

   -- Now, check if the CTDs are being used by any other object
   -- if not, remove the CTD and all other related objects
   OPEN C_GET_NOT_ASSOCIATED_CTD;
   FETCH C_GET_NOT_ASSOCIATED_CTD
   BULK COLLECT INTO l_not_associated_ctd_list;
   CLOSE C_GET_NOT_ASSOCIATED_CTD;

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_CURSOR_FETCH_C_GET_NOT_ASSOCIATED_CTD',
                        'Number of CTDs to be deleted = '||to_char(l_not_associated_ctd_list.count)
                       );

   -- delete from AMS_CTDS
   FORALL i in l_not_associated_ctd_list.FIRST .. l_not_associated_ctd_list.LAST
   DELETE FROM AMS_CTDS
   WHERE CTD_ID = l_not_associated_ctd_list(i);

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_CTD_BULK_DELETE',
                        'CTDs deleted successfully!!'
                       );

   -- delete from AMS_CTD_PARAM_VALUES
   FORALL i in l_not_associated_ctd_list.FIRST .. l_not_associated_ctd_list.LAST
   DELETE FROM AMS_CTD_PARAM_VALUES
   WHERE CTD_ID = l_not_associated_ctd_list(i);

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_CTD_PARAM_VALUES_BULK_DELETE',
                        'CTD Param Values deleted successfully!!'
                       );

   -- delete from AMS_CTD_ADHOC_PARAM_VALUES
   FORALL i in l_not_associated_ctd_list.FIRST .. l_not_associated_ctd_list.LAST
   DELETE FROM AMS_CTD_ADHOC_PARAM_VALUES
   WHERE CTD_ID = l_not_associated_ctd_list(i);

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_CTD_ADHOC_PARAM_VALUES_BULK_DELETE',
                        'CTD Adhoc Param Values deleted successfully!!'
                       );

END DELETE_ASSOCIATION_AND_CTD;
-- ===============================================================
-- Start of Comments
-- Name
-- CREATE_ASSOCIATION
--
-- Purpose
-- This procedure creates new associations between CTD Ids and the
-- Used By and Used By PK1
--

Procedure CREATE_ASSOCIATION(
  p_ctd_id_list   JTF_NUMBER_TABLE,
  p_used_by       VARCHAR2,
  p_used_by_val1   VARCHAR2
)
IS
   l_assoc_seq_id_list  NUMBER_TABLE;

   CURSOR C_GET_NEXT_SEQ_ID
   IS
   SELECT ams_ctd_associations_s.nextval
   FROM DUAL;

   l_list_count  NUMBER;
   list_count  NUMBER;
   l_sequence_id  NUMBER;
   PROCEDURE_NAME CONSTANT VARCHAR2(30) := 'CREATE_ASSOCIATION';

BEGIN
    write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'BEGIN',
                        'Begin procedure CREATE_ASSOCIATION'
                       );

   l_list_count := p_ctd_id_list.count;

   write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'WRITE_INPUT_PARAM',
                        'Input Param: Used By = '||p_used_by||' Used By val1 = '||p_used_by_val1||' Number of CTD Associations to be created ='||to_char(l_list_count)
                       );
   IF (l_list_count > 0 ) THEN
      FOR i in p_ctd_id_list.FIRST .. p_ctd_id_list.LAST
      LOOP
         OPEN C_GET_NEXT_SEQ_ID;
         FETCH C_GET_NEXT_SEQ_ID
         INTO l_sequence_id;
         CLOSE C_GET_NEXT_SEQ_ID;

         l_assoc_seq_id_list(i) := l_sequence_id;
      END LOOP;

      write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'BEFORE_CTD_ASSOCIATIONS_BULK_UPLOAD',
                        'About to bulk upload into AMS_CTD_ASSOCIATIONS'
                       );

      --Do a Bulk Upload
      FORALL i in p_ctd_id_list.FIRST .. p_ctd_id_list.LAST
      INSERT INTO
      AMS_CTD_ASSOCIATIONS
      (
        association_id,
        ctd_id,
        used_by_type,
        used_by_val1,
        used_by_val2,
        used_by_val3,
        used_by_val4,
        used_by_val5,
        object_version_number,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        security_group_id
      )
      VALUES
      (
        l_assoc_seq_id_list(i),
        p_ctd_id_list(i),
        p_used_by,
        p_used_by_val1,
        null,
        null,
        null,
        null,
        1,
        sysdate,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_ID,
        sysdate,
        FND_GLOBAL.USER_ID,
        null

      );

      write_debug_message(FND_LOG.LEVEL_EVENT,
                        PROCEDURE_NAME,
                        'AFTER_CTD_ASSOCIATIONS_BULK_UPLOAD',
                        'Bulk upload AMS_CTD_ASSOCIATIONS completed successfully!!'
                       );
   END IF;


END CREATE_ASSOCIATION;

-- ===============================================================
-- Start of Comments
-- Name
-- CREATE_AND_DELETE_ASSOCIATION
--
-- Purpose
-- 1. Establish new associations between CTD Id and Used-By,Used By Id combination
--    if not already exists in the CTD Association table.
--
-- 2. Delete the associations which are not more valid
--
Procedure CREATE_AND_DELETE_ASSOCIATION(
  p_ctd_id_list   JTF_NUMBER_TABLE,
  p_used_by       VARCHAR2,
  p_used_by_val1  VARCHAR2
)
IS
   CURSOR C_GET_NEW_ASSOCIATION
   IS
   SELECT CTD_LIST.CTD_ID
   FROM (SELECT column_value ctd_id
         FROM TABLE(CAST(p_ctd_id_list as JTF_NUMBER_TABLE)) ) ctd_list
   WHERE CTD_LIST.CTD_ID not in
      (SELECT ASSOC.CTD_ID
       FROM   AMS_CTD_ASSOCIATIONS assoc
       WHERE  assoc.used_by_type = p_used_by
       AND    assoc.used_by_val1 = p_used_by_val1
      );


   CURSOR C_REMOVED_ASSOCIATIONS
   IS
   SELECT CTD_ID
   FROM   AMS_CTD_ASSOCIATIONS
   WHERE  used_by_type = p_used_by
   AND    used_by_val1 = p_used_by_val1
   AND    CTD_ID NOT IN
   (SELECT column_value ctd_id
   FROM TABLE(CAST(p_ctd_id_list as JTF_NUMBER_TABLE))
   );

   l_new_ctd_id_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_removed_ctd_id_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


BEGIN
   -- Create the associations which do not already exist
   OPEN C_GET_NEW_ASSOCIATION;
   FETCH C_GET_NEW_ASSOCIATION
   BULK COLLECT INTO l_new_ctd_id_list;
   CLOSE C_GET_NEW_ASSOCIATION;

   CREATE_ASSOCIATION(
     p_ctd_id_list  => l_new_ctd_id_list,
     p_used_by   =>    p_used_by,
     p_used_by_val1 => p_used_by_val1
  );

   -- Get the CTDs which are no more associated with Cover letter
   -- but it's still available in the DB
   OPEN C_REMOVED_ASSOCIATIONS;
   FETCH C_REMOVED_ASSOCIATIONS
   BULK COLLECT INTO l_removed_ctd_id_list;
   CLOSE C_REMOVED_ASSOCIATIONS;

   IF (l_removed_ctd_id_list.exists(1)) THEN
      DELETE_ASSOCIATION_AND_CTD(l_removed_ctd_id_list
                                 ,p_used_by
                                 ,p_used_by_val1
                                );
   END IF;


END CREATE_AND_DELETE_ASSOCIATION;

-- ===============================================================
-- Start of Comments
-- Name
-- DELETE_ASSOCIATION_AND_CTD
--
-- Purpose
-- This procedure deletes associations and all relevant CTD information
-- if no other object is using the CTD
--
Procedure DELETE_ASSOCIATION_AND_CTD(
  p_used_by       VARCHAR2,
  p_used_by_val1   VARCHAR2
)
IS
   l_associated_ctd_list   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   CURSOR C_GET_ASSOCIATED_CTDS
   IS
   SELECT CTD_ID
   FROM AMS_CTD_ASSOCIATIONS
   WHERE USED_BY_TYPE = p_used_by
   AND   p_used_by_val1 = p_used_by_val1;

BEGIN

   OPEN C_GET_ASSOCIATED_CTDS;
   FETCH C_GET_ASSOCIATED_CTDS
   BULK COLLECT INTO l_associated_ctd_list;
   CLOSE C_GET_ASSOCIATED_CTDS;

   IF (l_associated_ctd_list.exists(1)) THEN
      DELETE_ASSOCIATION_AND_CTD(l_associated_ctd_list,
                                 p_used_by,
                                 p_used_by_val1
                                );
   END IF;

END DELETE_ASSOCIATION_AND_CTD;


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Ctd(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ctd_rec               IN   ctd_rec_type  := g_miss_ctd_rec,
    x_ctd_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ctd';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CTD_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_CTDS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_CTDS
      WHERE CTD_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ctd_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_ctd_rec.CTD_ID IS NULL OR p_ctd_rec.CTD_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_CTD_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_CTD_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ctd');

          -- Invoke validation procedures
          Validate_ctd(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ctd_rec  =>  p_ctd_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_CTDS_PKG.Insert_Row)
      AMS_CTDS_PKG.Insert_Row(
          px_ctd_id  => l_ctd_id,
          p_action_id  => p_ctd_rec.action_id,
          p_forward_url  => p_ctd_rec.forward_url,
          p_track_url  => p_ctd_rec.track_url,
          p_activity_product_id  => p_ctd_rec.activity_product_id,
          p_activity_offer_id  => p_ctd_rec.activity_offer_id,
          px_object_version_number  => l_object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_security_group_id  => p_ctd_rec.security_group_id);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_ctd_id := l_ctd_id;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO CREATE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ctd_PVT;
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
End Create_Ctd;


PROCEDURE Update_Ctd(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ctd_rec               IN    ctd_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
CURSOR c_get_ctd(ctd_id NUMBER) IS
    SELECT *
    FROM  AMS_CTDS;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ctd';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_CTD_ID    NUMBER;
l_ref_ctd_rec  c_get_Ctd%ROWTYPE ;
l_tar_ctd_rec  AMS_Ctd_PVT.ctd_rec_type := P_ctd_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ctd_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

/*
      OPEN c_get_Ctd( l_tar_ctd_rec.ctd_id);

      FETCH c_get_Ctd INTO l_ref_ctd_rec  ;

       If ( c_get_Ctd%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ctd') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Ctd;
*/


      If (l_tar_ctd_rec.object_version_number is NULL or
          l_tar_ctd_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ctd_rec.object_version_number <> l_ref_ctd_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ctd') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ctd');

          -- Invoke validation procedures
          Validate_ctd(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ctd_rec  =>  p_ctd_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_CTDS_PKG.Update_Row)
      AMS_CTDS_PKG.Update_Row(
          p_ctd_id  => p_ctd_rec.ctd_id,
          p_action_id  => p_ctd_rec.action_id,
          p_forward_url  => p_ctd_rec.forward_url,
          p_track_url  => p_ctd_rec.track_url,
          p_activity_product_id  => p_ctd_rec.activity_product_id,
          p_activity_offer_id  => p_ctd_rec.activity_offer_id,
          p_object_version_number  => p_ctd_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_security_group_id  => p_ctd_rec.security_group_id);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO UPDATE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ctd_PVT;
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
End Update_Ctd;


PROCEDURE Delete_Ctd(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ctd_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ctd';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ctd_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMS_CTDS_PKG.Delete_Row)
      AMS_CTDS_PKG.Delete_Row(
          p_CTD_ID  => p_CTD_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO DELETE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ctd_PVT;
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
End Delete_Ctd;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ctd(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ctd_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ctd';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_CTD_ID                  NUMBER;

CURSOR c_Ctd IS
   SELECT CTD_ID
   FROM AMS_CTDS
   WHERE CTD_ID = p_CTD_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Ctd;

  FETCH c_Ctd INTO l_CTD_ID;

  IF (c_Ctd%NOTFOUND) THEN
    CLOSE c_Ctd;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ctd;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ctd_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ctd_PVT;
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
End Lock_Ctd;


PROCEDURE check_ctd_uk_items(
    p_ctd_rec               IN   ctd_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CTDS',
         'CTD_ID = ''' || p_ctd_rec.CTD_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CTDS',
         'CTD_ID = ''' || p_ctd_rec.CTD_ID ||
         ''' AND CTD_ID <> ' || p_ctd_rec.CTD_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CTD_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ctd_uk_items;

PROCEDURE check_ctd_req_items(
    p_ctd_rec               IN  ctd_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ctd_rec.ctd_id = FND_API.g_miss_num OR p_ctd_rec.ctd_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_ctd_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.action_id = FND_API.g_miss_num OR p_ctd_rec.action_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_action_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.object_version_number = FND_API.g_miss_num OR p_ctd_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.last_update_date = FND_API.g_miss_date OR p_ctd_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.last_updated_by = FND_API.g_miss_num OR p_ctd_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.creation_date = FND_API.g_miss_date OR p_ctd_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.created_by = FND_API.g_miss_num OR p_ctd_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ctd_rec.ctd_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_ctd_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.action_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_action_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_ctd_req_items;

PROCEDURE check_ctd_FK_items(
    p_ctd_rec IN ctd_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ctd_FK_items;

PROCEDURE check_ctd_Lookup_items(
    p_ctd_rec IN ctd_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ctd_Lookup_items;

PROCEDURE Check_ctd_Items (
    P_ctd_rec     IN    ctd_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_ctd_uk_items(
      p_ctd_rec => p_ctd_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ctd_req_items(
      p_ctd_rec => p_ctd_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ctd_FK_items(
      p_ctd_rec => p_ctd_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_ctd_Lookup_items(
      p_ctd_rec => p_ctd_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_ctd_Items;


PROCEDURE Complete_ctd_Rec (
   p_ctd_rec IN ctd_rec_type,
   x_complete_rec OUT NOCOPY ctd_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_ctds
      WHERE ctd_id = p_ctd_rec.ctd_id;
   l_ctd_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ctd_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ctd_rec;
   CLOSE c_complete;

   -- ctd_id
   IF p_ctd_rec.ctd_id = FND_API.g_miss_num THEN
      x_complete_rec.ctd_id := l_ctd_rec.ctd_id;
   END IF;

   -- action_id
   IF p_ctd_rec.action_id = FND_API.g_miss_num THEN
      x_complete_rec.action_id := l_ctd_rec.action_id;
   END IF;

   -- forward_url
   IF p_ctd_rec.forward_url = FND_API.g_miss_char THEN
      x_complete_rec.forward_url := l_ctd_rec.forward_url;
   END IF;

   -- track_url
   IF p_ctd_rec.track_url = FND_API.g_miss_char THEN
      x_complete_rec.track_url := l_ctd_rec.track_url;
   END IF;

   -- activity_product_id
   IF p_ctd_rec.activity_product_id = FND_API.g_miss_num THEN
      x_complete_rec.activity_product_id := l_ctd_rec.activity_product_id;
   END IF;

   -- activity_offer_id
   IF p_ctd_rec.activity_offer_id = FND_API.g_miss_num THEN
      x_complete_rec.activity_offer_id := l_ctd_rec.activity_offer_id;
   END IF;

   -- object_version_number
   IF p_ctd_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ctd_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_ctd_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ctd_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ctd_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ctd_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_ctd_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ctd_rec.creation_date;
   END IF;

   -- created_by
   IF p_ctd_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ctd_rec.created_by;
   END IF;

   -- last_update_login
   IF p_ctd_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ctd_rec.last_update_login;
   END IF;

   -- security_group_id
   IF p_ctd_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_ctd_rec.security_group_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ctd_Rec;
PROCEDURE Validate_ctd(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ctd_rec               IN   ctd_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ctd';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ctd_rec  AMS_Ctd_PVT.ctd_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ctd_;

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
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_ctd_Items(
                 p_ctd_rec        => p_ctd_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_ctd_Rec(
         p_ctd_rec        => p_ctd_rec,
         x_complete_rec        => l_ctd_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ctd_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ctd_rec           =>    l_ctd_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO VALIDATE_Ctd_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ctd_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ctd_;
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
End Validate_Ctd;


PROCEDURE Validate_ctd_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ctd_rec               IN    ctd_rec_type
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
      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ctd_Rec;

--========================================================================
-- PROCEDURE
--    CHECK_MANDATORY_FIELDS
--
-- PURPOSE
--    This api is created to be used for validating ctd mandatory fields during
--    schedule status changes. Check ams_ctd_assoc_v
--
-- HISTORY
--  30-Aug-2006    dbiswas    Created.
--========================================================================

PROCEDURE CHECK_MANDATORY_FIELDS(
    P_ctd_rec     IN    ctd_rec_type,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS

BEGIN
      x_return_status := FND_API.g_ret_sts_success;

      IF P_ctd_rec.ctd_id = FND_API.g_miss_num OR P_ctd_rec.ctd_id IS NULL THEN
        --AMS_Utility_PVT.Error_Message('AMS_ctd_NO_ctd_id');
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('AMS', 'AMS_ctd_NO_ctd_id');
        FND_MSG_PUB.add;
       RETURN;
      END IF;

      IF P_ctd_rec.track_url IS NOT NULL THEN
         IF P_ctd_rec.forward_url IS NULL AND P_ctd_rec.action_id =1 THEN
           --AMS_Utility_PVT.Error_Message('AMS_ctd_NO_FORWARD_URL');
             x_return_status := FND_API.g_ret_sts_error;
             FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
             FND_MSG_PUB.add;
         RETURN;
	 ELSIF P_ctd_rec.action_id = 5 THEN -- Go to Section. Site and Section should be provided
              IF P_ctd_rec.forward_url like '%go=section%' AND (P_ctd_rec.forward_url not like '%minisite=%' OR  P_ctd_rec.forward_url not like '%section=%') THEN
	          x_return_status := FND_API.g_ret_sts_error;
                  FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
                  FND_MSG_PUB.add;
                  RETURN;
              END IF;
	 RETURN;

	 ELSIF P_ctd_rec.action_id = 7 THEN -- Goto Site. Site should be provided
              IF P_ctd_rec.forward_url like '%go=catalog%' AND P_ctd_rec.forward_url not like '%minisite=%'  THEN
	          x_return_status := FND_API.g_ret_sts_error;
                  FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
                  FND_MSG_PUB.add;
                  RETURN;
              END IF;
	 ELSIF P_ctd_rec.action_id = 8 AND P_ctd_rec.forward_url like '%TO_BE_COMPUTED%' THEN -- Goto Web Script. Script should be provided
	     x_return_status := FND_API.g_ret_sts_error;
             FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
             FND_MSG_PUB.add;
         RETURN;
	 ELSIF P_ctd_rec.action_id = 9 THEN -- Goto Content item. Item and stylesheet should be provided
	     IF P_ctd_rec.forward_url like '%cItemId=&%' OR P_ctd_rec.forward_url like '%stlId=&%' THEN
	          x_return_status := FND_API.g_ret_sts_error;
                  FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
                  FND_MSG_PUB.add;
                  RETURN;
              END IF;
         END IF;

	 ELSIF P_ctd_rec.action_id IS NOT NULL AND P_ctd_rec.track_url IS NULL THEN
	  x_return_status := FND_API.g_ret_sts_error;
                  FND_MESSAGE.set_name('AMS', 'AMS_CTD_NO_TRACK_GEN');
                  FND_MSG_PUB.add;
                  RETURN;
      END IF;

END CHECK_MANDATORY_FIELDS;

END AMS_CTD_PVT;

/
