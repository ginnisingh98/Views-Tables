--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_FORMULA_PVT" AS
/* $Header: amsvmtfb.pls 115.10 2004/06/30 08:00:09 sunkumar noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_metric_formula_PVT
-- Purpose
--
-- History
-- ??-???-2003 dmvincen Created.
-- 12-Nov-2003 choang   Modified transform_formula
-- 01-Dec-2003 dmvincen Return error for invalid formula.
-- 22-Dec-2003 dmvincen BUG3325199: check sequence in validate.
-- 09-Jan-2004 dmvincen BUG3354319: Default sequence value.
-- 30-Jun-2004 sunkumar bug#3687362: FORMULA METRIC VALIDATION ERROR MESSAGE IS UNCLEAR
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_metric_formula_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmtdb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

G_SEQUENCE_INCREMENT CONSTANT NUMBER := 10;

TYPE stack_rec_type IS RECORD
(
       source_name                     VARCHAR2(150),
       token                           VARCHAR2(30),
       sequence                        NUMBER,
       object_version_number           NUMBER,
       metric_formula_id               NUMBER,
       notation_type                   VARCHAR2(30),
       source_type                     VARCHAR2(30) := 'EMPTY',
       use_sub_id_flag                 VARCHAR2(1),
       source_value                    NUMBER,
       source_id                       NUMBER,
       source_sub_id                   NUMBER
);

TYPE  stack_tbl_type      IS TABLE OF stack_rec_type INDEX BY BINARY_INTEGER;
TYPE  varchar30_tbl_type  is table of varchar2(30) index by binary_integer;
type  number_tbl_type     is table of number index by binary_integer;
g_stack_tbl          stack_tbl_type;
g_infix_tbl          stack_tbl_type;
g_postfix_tbl        stack_tbl_type;
g_infix_index        number := 0;
g_infix_formula      varchar2(4000);
g_valid_formula      boolean;
g_error_sequence     number := null;
g_current_sequence   number := null;

g_source_type_tbl    varchar30_tbl_type;
g_source_id_tbl      number_tbl_type;
g_source_sub_id_tbl  number_tbl_type;
g_source_value_tbl   number_tbl_type;
g_token_tbl          varchar30_tbl_type;
g_use_sub_id_flag_tbl varchar30_tbl_type;
g_index_tbl          number_tbl_type;

PROCEDURE Complete_metric_formula_Rec (
   p_ref_metric_formula_rec IN met_formula_rec_type,
   x_tar_metric_formula_rec IN OUT NOCOPY met_formula_rec_type);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_met_formula_rec            IN   met_formula_rec_type  := g_miss_met_formula_rec,
    x_metric_formula_id          OUT nocopy NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_metric_formula';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_METRIC_FORMULA_ID         NUMBER;
   l_dummy                     NUMBER;
   l_rowid  ROWID;

   CURSOR c_id IS
      SELECT AMS_METRIC_FORMULAS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_METRIC_FORMULAS
      WHERE METRIC_FORMULA_ID = l_id;

   CURSOR c_get_max_sequence (l_metric_id IN NUMBER) IS
      select nvl(max(sequence),0)
      from ams_metric_formulas
      where metric_id = l_metric_id;

   l_metric_formula_rec  met_formula_rec_type := p_met_formula_rec;
   l_max_sequence number := null;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_metric_formula_SP;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   --sunkumar 30/01/2003
  --check if the template is a seeded one
 /* IF p_metric_formula_rec.metric_tpl_header_id  < 10000 THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF; */


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF l_metric_formula_rec.METRIC_FORMULA_ID IS NULL OR
      l_metric_formula_rec.METRIC_FORMULA_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_METRIC_FORMULA_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_METRIC_FORMULA_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      l_metric_formula_rec.METRIC_FORMULA_ID := l_METRIC_FORMULA_ID;
       -- Debug message
       IF (AMS_DEBUG_HIGH_ON) THEN

       Ams_Utility_Pvt.debug_message('Private API: New formula id='||l_metric_formula_id);
       END IF;
   END IF;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

   IF FND_GLOBAL.User_Id IS NULL
   THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   if l_metric_formula_rec.sequence is null then
      open c_get_max_sequence(l_metric_formula_rec.metric_id);
      fetch c_get_max_sequence into l_max_sequence;
      close c_get_max_sequence;
      l_metric_formula_rec.sequence :=
         nvl(l_max_sequence,0) + G_SEQUENCE_INCREMENT;
   end if;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
       -- Debug message
       IF (AMS_DEBUG_HIGH_ON) THEN

       Ams_Utility_Pvt.debug_message('Private API: Validate_metric_formula');
       END IF;

       -- Invoke validation procedures
       Validate_metric_formula(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_validation_mode => JTF_PLSQL_API.g_create,
         p_metric_formula_rec  =>  l_metric_formula_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message( 'Private API: Calling Ams_Metric_Formulas_Pkg.Insert_Row');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_DETAILS_PKG.Insert_Row)
   Ams_Metric_Formulas_Pkg.Insert_Row(
      X_ROWID => l_rowid,
      X_METRIC_FORMULA_ID => l_metric_formula_id,
      X_METRIC_ID => l_metric_formula_rec.metric_id,
      X_SOURCE_TYPE => l_metric_formula_rec.source_type,
      X_SOURCE_ID => l_metric_formula_rec.source_id,
      X_SOURCE_SUB_ID => l_metric_formula_rec.source_sub_id,
      X_USE_SUB_ID_FLAG => l_metric_formula_rec.use_sub_id_flag,
      X_SOURCE_VALUE => l_metric_formula_rec.source_value,
      X_TOKEN => l_metric_formula_rec.token,
      X_SEQUENCE => l_metric_formula_rec.sequence,
      X_NOTATION_TYPE => l_metric_formula_rec.notation_type,
      X_OBJECT_VERSION_NUMBER => 1,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
   );

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message( 'Private API: return_status='||x_return_status||', x_metric_formula_id='||x_metric_formula_id);
   END IF;

   x_METRIC_FORMULA_ID := l_METRIC_FORMULA_ID;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_metric_formula_SP;
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
END Create_metric_formula;


PROCEDURE Update_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_met_formula_rec            IN    met_formula_rec_type,
    x_object_version_number      OUT nocopy NUMBER
    )
IS
   CURSOR c_get_metric_formula(l_METRIC_FORMULA_ID NUMBER)
   return met_formula_rec_type IS
       SELECT
       metric_formula_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       object_version_number,
       metric_id,
       source_type,
       source_id,
       source_sub_id,
       source_value,
       token,
       notation_type,
       use_sub_id_flag,
       sequence
       FROM  AMS_METRIC_FORMULAS
      WHERE METRIC_FORMULA_ID = l_METRIC_FORMULA_ID;

   CURSOR c_get_max_sequence(l_metric_id NUMBER) is
      select nvl(max(sequence),G_SEQUENCE_INCREMENT) from ams_metric_formulas
      where metric_id = l_metric_id;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_metric_formula';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_METRIC_FORMULA_ID NUMBER;
   l_ref_metric_formula_rec  met_formula_rec_type ;
   l_tar_metric_formula_rec  met_formula_rec_type := p_met_formula_rec;
   l_rowid  ROWID;
   l_max_sequence NUMBER := null;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_metric_formula_sp;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
     Ams_Utility_Pvt.debug_message('Private API: - Open Cursor to Select');
   END IF;

   OPEN c_get_metric_formula( l_tar_metric_formula_rec.METRIC_FORMULA_ID);

   FETCH c_get_metric_formula INTO l_ref_metric_formula_rec;

   IF ( c_get_metric_formula%NOTFOUND) THEN
      CLOSE c_get_metric_formula;
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
         p_token_name   => 'INFO',
         p_token_value  => 'metric_formula_id='||l_tar_metric_formula_rec.METRIC_FORMULA_ID);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE c_get_metric_formula;

   Complete_metric_formula_rec(l_ref_metric_formula_rec, l_tar_metric_formula_rec);

   IF (l_tar_metric_formula_rec.object_version_number IS NULL OR
       l_tar_metric_formula_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
         p_token_name   => 'COLUMN',
         p_token_value  => 'OBJECT_VERSION_NUMBER');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Whether record has been changed by someone else
   IF (l_tar_metric_formula_rec.object_version_number <> l_ref_metric_formula_rec.object_version_number) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
         p_token_name   => 'INFO',
         p_token_value  => 'metric_formula_id='||l_tar_metric_formula_rec.METRIC_FORMULA_ID);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  --check if we are trying to update a seeded metric formula
  IF l_tar_metric_formula_rec.metric_id  < 10000 THEN
   IF ( (l_tar_metric_formula_rec.METRIC_FORMULA_ID <>l_ref_metric_formula_rec.METRIC_FORMULA_ID )
     OR (l_tar_metric_formula_rec.metric_id   <>l_ref_metric_formula_rec.metric_id)
      ) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_SEEDED_METR');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   if l_tar_metric_formula_rec.sequence is null then
      if l_ref_metric_formula_rec.sequence is not null then
         l_tar_metric_formula_rec.sequence := l_ref_metric_formula_rec.sequence;
      else
         open c_get_max_sequence(l_tar_metric_formula_rec.metric_id);
         fetch c_get_max_sequence into l_max_sequence;
         close c_get_max_sequence;
         l_tar_metric_formula_rec.sequence := nvl(l_max_sequence,G_SEQUENCE_INCREMENT);
      end if;
   end if;

   IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_Pvt.debug_message('Private API: Validate_metric_formula');
      END IF;

      -- Invoke validation procedures
      Validate_metric_formula(
        p_api_version_number => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_validation_level => p_validation_level,
        p_validation_mode  => JTF_PLSQL_API.g_update,
        p_metric_formula_rec  => l_tar_metric_formula_rec,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_Pvt.debug_message('Private API: Validate_metric_formula: return status='||x_return_status);
      END IF;
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_object_version_number :=
       l_ref_metric_formula_rec.object_version_number + 1;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
     Ams_Utility_Pvt.debug_message('Private API: Calling Ams_Metric_Formulas_Pkg.Update_Row, sequence='||l_tar_metric_formula_rec.sequence);
   END IF;

   -- Invoke table handler(Ams_Metric_Formulas_Pkg.Update_Row)
   Ams_Metric_Formulas_Pkg.Update_Row(
      X_METRIC_FORMULA_ID => l_tar_metric_formula_rec.METRIC_FORMULA_ID,
      X_METRIC_ID => l_tar_metric_formula_rec.metric_id,
      X_SOURCE_TYPE => l_tar_metric_formula_rec.source_type,
      X_SOURCE_ID => l_tar_metric_formula_rec.source_id,
      X_SOURCE_SUB_ID => l_tar_metric_formula_rec.source_sub_id,
      X_USE_SUB_ID_FLAG => l_tar_metric_formula_rec.use_sub_id_flag,
      X_SOURCE_VALUE => l_tar_metric_formula_rec.source_value,
      X_TOKEN => l_tar_metric_formula_rec.token,
      X_SEQUENCE => l_tar_metric_formula_rec.sequence,
      X_NOTATION_TYPE => l_tar_metric_formula_rec.notation_type,
      X_OBJECT_VERSION_NUMBER => l_object_version_number,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID);

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_metric_formula_sp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_metric_formula_sp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_metric_formula_sp;
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
END Update_metric_formula;


PROCEDURE Delete_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,
    p_metric_formula_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_metric_formula';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_metric_formula_SP;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

  --check if the formula is a seeded one
  IF  p_METRIC_FORMULA_ID   < 10000 THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_SEEDED_METR');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Api body
   --
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'Private API: Calling delete table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_DETAILS_PKG.Delete_Row)
   AMS_METRIC_FORMULAS_PKG.Delete_Row(
       X_METRIC_FORMULA_ID  => p_METRIC_FORMULA_ID);
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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_metric_formula_SP;
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
END Delete_metric_formula;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_metric_formula_id          IN  NUMBER,
    p_object_version             IN  NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_metric_formula';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_METRIC_FORMULA_ID NUMBER;

   CURSOR c_metric_formula IS
      SELECT METRIC_FORMULA_ID
      FROM AMS_METRIC_FORMULAS
      WHERE METRIC_FORMULA_ID = p_METRIC_FORMULA_ID
      AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;

BEGIN

   savepoint LOCK_metric_formula_SP;
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
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
     Ams_Utility_Pvt.debug_message(l_full_name||': start');
  END IF;

  OPEN c_metric_formula;

  FETCH c_metric_formula INTO l_METRIC_FORMULA_ID;

  IF (c_metric_formula%NOTFOUND) THEN
    CLOSE c_metric_formula;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_metric_formula;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN
     Ams_Utility_Pvt.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_metric_formula_SP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_metric_formula_SP;
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
END Lock_metric_formula;


PROCEDURE check_metric_formula_uk_items(
    p_metric_formula_rec            IN  met_formula_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
/*
l_dummy NUMBER;

   cursor c_check_sequence_update(p_metric_formula_id number, p_metric_id number,
          p_sequence NUMBER) IS
     select COUNT(1) from ams_metric_formulas
     where metric_id = p_metric_id
     and metric_formula_id <> p_metric_formula_id
     and sequence = p_sequence;

   cursor c_check_sequence_new(p_metric_id number,
          p_sequence NUMBER) IS
     select COUNT(1) from ams_metric_formulas
     where metric_id = p_metric_id
     and sequence = p_sequence;
*/
BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_uk_items : START');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
      'AMS_METRIC_FORMULAS',
      'METRIC_FORMULA_ID = ' || p_metric_formula_rec.METRIC_FORMULA_ID
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_FORMULA_ID_DUP');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
/*
   l_dummy := 0;
   IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
      open c_check_sequence_new(p_metric_formula_rec.metric_id,
            p_metric_formula_rec.sequence);
      fetch c_check_sequence_new INTO l_dummy;
      close c_check_sequence_new;
   elsif p_validation_mode = JTF_PLSQL_API.G_UPDATE THEN
      open c_check_sequence_update(p_metric_formula_rec.metric_formula_id,
            p_metric_formula_rec.metric_id, p_metric_formula_rec.sequence);
      fetch c_check_sequence_update INTO l_dummy;
      close c_check_sequence_update;
   END IF;

   IF l_dummy > 0 THEN
      AMS_UTILITY_PVT.ERROR_MESSAGE(p_message_name => 'AMS_METR_INVALID_SEQUENCE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
*/
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_uk_items : END');
   END IF;
END check_metric_formula_uk_items;

PROCEDURE check_metric_formula_req_items(
    p_metric_formula_rec               IN  met_formula_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : START');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : metric_id='||p_metric_formula_rec.metric_id);
   END IF;
      IF p_metric_formula_rec.metric_id = FND_API.g_miss_num OR p_metric_formula_rec.metric_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : source_type='||p_metric_formula_rec.source_type);
   END IF;
      IF p_metric_formula_rec.source_type = FND_API.G_MISS_CHAR OR p_metric_formula_rec.source_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','SOURCE_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_formula_rec.source_type IN ('METRIC','CATEGORY') THEN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : source_id='||p_metric_formula_rec.source_id);
   END IF;
         IF  p_metric_formula_rec.source_id IS NULL OR p_metric_formula_rec.source_id = FND_API.G_MISS_NUM THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
            FND_MESSAGE.set_token('MISS_FIELD','SOURCE_ID');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : use_sub_id_flag='||p_metric_formula_rec.use_sub_id_flag);
   END IF;
         IF p_metric_formula_rec.source_type = 'CATEGORY' AND
            (p_metric_formula_rec.use_sub_id_flag IS NULL OR p_metric_formula_rec.use_sub_id_flag = FND_API.G_MISS_CHAR) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
            FND_MESSAGE.set_token('MISS_FIELD','USE_SUB_ID_FLAG');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      ELSIF p_metric_formula_rec.source_type = 'OPERAND' and
         (p_metric_formula_rec.TOKEN IS NULL OR p_metric_formula_rec.TOKEN = FND_API.G_MISS_CHAR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','TOKEN');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF p_metric_formula_rec.source_type = 'NUMBER' and
         (p_metric_formula_rec.source_value IS NULL OR p_metric_formula_rec.source_value = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','SOURCE_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : notation_type='||p_metric_formula_rec.notation_type);
   END IF;
      IF p_metric_formula_rec.notation_type = FND_API.g_miss_char OR p_metric_formula_rec.notation_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','NOTATION_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE  -- Update

      IF p_metric_formula_rec.METRIC_FORMULA_ID = FND_API.g_miss_num OR p_metric_formula_rec.METRIC_FORMULA_ID IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_FORMULA_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_formula_rec.sequence = FND_API.g_miss_num OR p_metric_formula_rec.sequence IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','SEQUENCE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_req_items : END');
   END IF;
END check_metric_formula_req_items;

PROCEDURE check_metric_formula_FK_items(
    p_metric_formula_rec IN met_formula_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_check_metric_parent(p_metric_id NUMBER) IS
      SELECT arc_metric_used_for_object, metric_calculation_type
      FROM ams_metrics_all_b
     WHERE metric_id = p_metric_id;

   CURSOR c_check_category(p_CATEGORY_ID NUMBER) IS
      SELECT count(1) FROM AMS_CATEGORIES_VL
     WHERE CATEGORY_ID = p_CATEGORY_ID
     and arc_category_created_for = 'METR';

   CURSOR c_check_sub_category(p_CATEGORY_ID NUMBER, p_SUB_CATEGORY_ID NUMBER) IS
      SELECT count(1) FROM AMS_CATEGORIES_VL
     WHERE CATEGORY_ID = p_SUB_CATEGORY_ID
     and parent_category_id = p_category_id
     and arc_category_created_for = 'METR';

   CURSOR c_check_metric_source(p_metric_id NUMBER) IS
      SELECT arc_metric_used_for_object FROM ams_metrics_all_b
     WHERE metric_id = p_metric_id
     and metric_calculation_type <> 'FORMULA';

   l_dummy NUMBER;
   l_object_type VARCHAR2(30);
   l_calculation_type VARCHAR2(30);
   l_source_object_type VARCHAR2(30);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

   -- Validate metric_id exists.
   OPEN c_check_metric_parent(p_metric_formula_rec.metric_id);
   FETCH c_check_metric_parent INTO l_object_type, l_calculation_type;
   IF c_check_metric_parent%NOTFOUND THEN
     Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_METRIC_ID',
        p_token_name => 'METRIC_ID',
        p_token_value => p_metric_formula_rec.metric_id);
      x_return_status := FND_API.g_ret_sts_error;
   elsif l_calculation_type <> 'FORMULA' THEN
     Ams_Utility_pvt.error_message(p_message_name => 'AMS_METR_INVALID_FORMULA_TYPE');
     x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_check_metric_parent;

   -- Validate the metric_id exists
   IF p_metric_formula_rec.source_type = 'METRIC' THEN
      OPEN c_check_metric_source(p_metric_formula_rec.SOURCE_id);
      FETCH c_check_metric_source INTO l_source_object_type;
      IF c_check_metric_source%NOTFOUND THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_METRIC_SOURCE');
         x_return_status := FND_API.g_ret_sts_error;
      ELSIF l_object_type = 'ANY' and l_source_object_type <> 'ANY' then
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_METRIC_SOURCE');
         x_return_status := FND_API.g_ret_sts_error;
      ELSIF l_object_type <> 'ANY' and l_source_object_type NOT in ('ANY', l_object_type) THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_METRIC_SOURCE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_check_metric_source;
   ELSIF p_metric_formula_rec.source_type = 'CATEGORY' THEN
      OPEN c_check_category(p_metric_formula_rec.source_id);
      FETCH c_check_category INTO l_dummy;
      CLOSE c_check_category;
      IF l_dummy <> 1 then
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_CATEGORY_SRC');
         x_return_status := FND_API.g_ret_sts_error;
      ELSE
         IF p_metric_formula_rec.use_sub_id_flag = 'Y' AND
            p_metric_formula_rec.source_sub_id is not null THEN
            open c_check_sub_category(p_metric_formula_rec.source_id, p_metric_formula_rec.source_sub_id);
            fetch c_check_sub_category into l_dummy;
            close c_check_sub_category;
            IF l_dummy <> 1 then
               Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_CATEGORY_SRC');
               x_return_status := FND_API.g_ret_sts_error;
            END IF;
         end if;
      END IF;
   END IF;

END check_metric_formula_FK_items;

PROCEDURE check_metric_formula_lookups(
    p_metric_formula_rec IN met_formula_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
   IF p_metric_formula_rec.use_sub_id_flag is not null and
      Ams_Utility_Pvt.is_y_or_n(p_metric_formula_rec.use_sub_id_flag) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name=>'AMS_METR_INVALID_USE_SUB_ID',
           p_token_name => 'USE_SUB_ID_FLAG',
           p_token_value=>p_metric_formula_rec.use_sub_id_flag);
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ams_utility_pvt.check_lookup_exists('AMS_LOOKUPS','AMS_METRIC_SOURCE_TYPE',p_metric_formula_rec.source_type) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_SOURCE_TYPE',
           p_token_name => 'SOURCE_TYPE',
           p_token_value => p_metric_formula_rec.source_type);
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ams_utility_pvt.check_lookup_exists('AMS_LOOKUPS','AMS_METRIC_NOTATION_TYPE',p_metric_formula_rec.notation_type) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_NOTATION_TYPE',
           p_token_name => 'NOTATION_TYPE',
           p_token_value => p_metric_formula_rec.notation_type);
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF p_metric_formula_rec.source_type = 'OPERATOR' and p_metric_formula_rec.TOKEN is not null and
      ams_utility_pvt.check_lookup_exists('AMS_LOOKUPS','AMS_METRIC_OPERAND_TYPE',p_metric_formula_rec.token) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_METR_INVALID_OPERATOR',
           p_token_name => 'OPERATOR',
           p_token_value => p_metric_formula_rec.token);
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END check_metric_formula_lookups;

PROCEDURE Check_metric_formula_Items (
    p_metric_formula_rec  IN    met_formula_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_items : START');
   END IF;
   -- Check Items Uniqueness API calls

   check_metric_formula_uk_items(
      p_metric_formula_rec => p_metric_formula_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_metric_formula_req_items(
      p_metric_formula_rec => p_metric_formula_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_metric_formula_FK_items(
      p_metric_formula_rec => p_metric_formula_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_metric_formula_lookups(
      p_metric_formula_rec => p_metric_formula_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: check_metric_formula_items : END');
   END IF;
END Check_metric_formula_Items;

PROCEDURE Complete_metric_formula_Rec (
   p_ref_metric_formula_rec IN met_formula_rec_type,
   x_tar_metric_formula_rec IN OUT NOCOPY met_formula_rec_type)
IS
--    l_return_status  VARCHAR2(1);

--    CURSOR c_complete IS
--       SELECT *
--       FROM ams_met_tpl_details
--       WHERE METRIC_FORMULA_ID = p_metric_formula_rec.METRIC_FORMULA_ID;
--    l_metric_formula_rec c_complete%ROWTYPE;
BEGIN
   -- metric_id
   IF x_tar_metric_formula_rec.metric_id = FND_API.g_miss_num THEN
      x_tar_metric_formula_rec.metric_id := p_ref_metric_formula_rec.metric_id;
   END IF;

   -- source_type
   IF x_tar_metric_formula_rec.source_type = FND_API.G_MISS_CHAR THEN
      x_tar_metric_formula_rec.source_type := p_ref_metric_formula_rec.source_type;
   END IF;

   -- source_id
   IF x_tar_metric_formula_rec.source_id = FND_API.g_miss_num THEN
      x_tar_metric_formula_rec.source_id := p_ref_metric_formula_rec.source_id;
   END IF;

   -- source_sub_id
   IF x_tar_metric_formula_rec.source_sub_id = FND_API.g_miss_num THEN
      x_tar_metric_formula_rec.source_sub_id := p_ref_metric_formula_rec.source_sub_id;
   END IF;

   -- source_value
   IF x_tar_metric_formula_rec.source_value = FND_API.g_miss_num THEN
      x_tar_metric_formula_rec.source_value := p_ref_metric_formula_rec.source_value;
   END IF;

   -- use_sub_id_flag
   IF x_tar_metric_formula_rec.use_sub_id_flag = FND_API.g_miss_char THEN
      x_tar_metric_formula_rec.use_sub_id_flag := p_ref_metric_formula_rec.use_sub_id_flag;
   END IF;

   -- token
   IF x_tar_metric_formula_rec.token = FND_API.g_miss_char THEN
      x_tar_metric_formula_rec.token := p_ref_metric_formula_rec.token;
   END IF;

   -- sequence
   IF x_tar_metric_formula_rec.sequence = FND_API.g_miss_num THEN
      x_tar_metric_formula_rec.sequence := p_ref_metric_formula_rec.sequence;
   END IF;

   -- notation_type
   IF x_tar_metric_formula_rec.notation_type = FND_API.g_miss_char THEN
      x_tar_metric_formula_rec.notation_type := p_ref_metric_formula_rec.notation_type;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_metric_formula_Rec;


PROCEDURE Validate_metric_formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_metric_formula_rec         IN   met_formula_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_metric_formula';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_metric_formula_rec        met_formula_rec_type;

BEGIN
   -- Standard Start of API savepoint
--   SAVEPOINT VALIDATE_metric_formula_SP;

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
      Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': START');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_metric_formula_Items(
         p_metric_formula_rec        => p_metric_formula_rec,
         p_validation_mode   => p_validation_mode,
         x_return_status     => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

--    Complete_metric_formula_Rec(
--       p_metric_formula_rec        => p_metric_formula_rec,
--       x_complete_rec        => l_metric_formula_rec
--    );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_metric_formula_Rec(
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_metric_formula_rec     => l_metric_formula_rec);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': END');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
--     ROLLBACK TO VALIDATE_metric_formula_sp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--     ROLLBACK TO VALIDATE_metric_formula_sp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
--     ROLLBACK TO VALIDATE_metric_formula_sp;
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
END Validate_metric_formula;


PROCEDURE Validate_metric_formula_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_formula_rec         IN    met_formula_rec_type
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
         Ams_Utility_Pvt.debug_message('PRIVATE API: Validate_metric_formula_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_metric_formula_Rec;

procedure push(p_stack_rec IN stack_rec_type)
is
  l_index number;
begin
   l_index := g_stack_tbl.count + 1;
   g_stack_tbl(l_index) := p_stack_rec;
end push;

procedure pop(x_stack_rec OUT nocopy stack_rec_type)
is
   l_index number;
begin
   if g_stack_tbl.count = 0 then
      x_stack_rec.source_type := 'EMPTY';
   else
      l_index := g_stack_tbl.count;
      x_stack_rec := g_stack_tbl(l_index);
      g_stack_tbl.delete(l_index);
   end if;
end pop;

procedure peek(x_stack_rec out nocopy stack_rec_type)
is
   l_index number;
begin
   if g_stack_tbl.count = 0 then
      x_stack_rec.source_type := 'EMPTY';
   else
      l_index := g_stack_tbl.last;
      x_stack_rec := g_stack_tbl(l_index);
   end if;
end peek;

function has_more_infix
return boolean
is
begin
return g_infix_index <= g_infix_tbl.last;
end has_more_infix;

procedure error_infix
is
   l_error_msg VARCHAR2(150);
begin
   l_error_msg := ams_utility_pvt.get_lookup_meaning('AMS_METRIC_STRINGS','ERROR');
   g_infix_formula := g_infix_formula || ' ' || l_error_msg;
   g_valid_formula := false;
   if g_error_sequence is null then
      g_error_sequence := g_current_sequence;
   end if;
end error_infix;

procedure next_infix(x_formula_rec out nocopy stack_rec_type)
is
begin
   x_formula_rec := g_infix_tbl(g_infix_index);
   if g_current_sequence is not null AND
      g_current_sequence = x_formula_rec.sequence THEN
      AMS_UTILITY_PVT.ERROR_MESSAGE(p_message_name => 'AMS_METR_INVALID_SEQUENCE');
      error_infix;
   end if;
   g_current_sequence := x_formula_rec.sequence;
   g_infix_index := g_infix_tbl.next(g_infix_index);
   if length(g_infix_formula) > 0 then
      g_infix_formula := g_infix_formula || ' ';
   end if;
   g_infix_formula := g_infix_formula || x_formula_rec.source_name;
end next_infix;

procedure add_postfix(p_formula_rec in stack_rec_type)
is
   l_index number;
begin
   if p_formula_rec.source_type <> 'EMPTY' then
      l_index := g_source_type_tbl.count + 1;

      g_source_type_tbl(l_index) := p_formula_rec.source_type;
      g_source_id_tbl(l_index) := p_formula_rec.source_id;
      g_source_sub_id_tbl(l_index) := p_formula_rec.source_sub_id;
      g_source_value_tbl(l_index) := p_formula_rec.source_value;
      g_token_tbl(l_index) := p_formula_rec.token;
      g_use_sub_id_flag_tbl(l_index) := p_formula_rec.use_sub_id_flag;
      g_index_tbl(l_index) := l_index;
   end if;
end add_postfix;

procedure reset_postfix
is
begin
g_source_type_tbl.delete;
g_source_id_tbl.delete;
g_source_sub_id_tbl.delete;
g_source_value_tbl.delete;
g_token_tbl.delete;
g_use_sub_id_flag_tbl.delete;
g_index_tbl.delete;
g_stack_tbl.delete;
g_error_sequence := null;
end reset_postfix;

--
-- Purpose
--    < we need to add a descriptive purpose of this procedure >
--
-- Change History
-- ??-???-2003 dmvincen Created
-- 12-Nov-2003 choang   Added validation for first and last tokens in the formula.
--
procedure transform_formula
is
  l_formula_rec stack_rec_type;
  l_lefthand_rec stack_rec_type;
  l_righthand_rec stack_rec_type;
  l_operator_rec stack_rec_type;
  l_paren_count NUMBER := 0;
begin
  while has_more_infix loop
      next_infix(l_formula_rec);

      IF (l_lefthand_rec.source_type = 'EMPTY') AND
         (l_formula_rec.source_type = 'OPERATOR' AND l_formula_rec.token <> 'LEFTPAREN') THEN
         -- choang - 12-nov-2003 - this validates that the first token of the formula
         --          cannot be an operator unless it is a left paren.
         error_infix;

         -- Process formula indiscriminately
         push(l_formula_rec);
         IF l_formula_rec.token = 'RIGHTPAREN' THEN
            l_paren_count := l_paren_count - 1;
         END IF;
      elsif (l_formula_rec.source_type = 'OPERATOR' and
          l_formula_rec.token = 'LEFTPAREN') THEN
          if l_lefthand_rec.source_type in ('NUMBER','CATEGORY','METRIC') then
             error_infix;
          end if;
          push(l_formula_rec);
          l_paren_count := l_paren_count + 1;
      elsif (l_formula_rec.source_type = 'OPERATOR' and
          l_formula_rec.token = 'RIGHTPAREN') THEN
          if l_lefthand_rec.source_type in ('OPERATOR') and
             l_lefthand_rec.token <> 'RIGHTPAREN' then
             error_infix;
          end if;
          if l_paren_count <= 0 then
             error_infix;
          end if;
          l_paren_count := l_paren_count - 1;
          pop(l_operator_rec);
          add_postfix(l_operator_rec);
          pop(l_operator_rec); -- should be left paren.
          if l_operator_rec.token <> 'LEFTPAREN' then
             error_infix;
          end if;
      elsif (l_formula_rec.source_type in ('NUMBER','CATEGORY','METRIC')) THEN
          if l_lefthand_rec.source_type in ('NUMBER','CATEGORY','METRIC') then
             error_infix;
          end if;
          add_postfix(l_formula_rec);
      elsif (l_formula_rec.source_type = 'OPERATOR' and
          l_formula_rec.token IN ('TIMES','DIVIDE')) THEN
          if l_lefthand_rec.source_type in ('OPERATOR') and
             l_lefthand_rec.token in ('TIMES','DIVIDE','PLUS','MINUS') then
             error_infix;
          end if;
          peek(l_operator_rec);
          if l_operator_rec.source_type = 'EMPTY' then
             push(l_formula_rec);
          elsif l_operator_rec.source_type = 'OPERATOR' and
                l_operator_rec.token = 'LEFTPAREN' then
             push(l_formula_rec);
          elsif l_operator_rec.token in ('TIMES','DIVIDE') then
             add_postfix(l_operator_rec);
             pop(l_operator_rec);
             push(l_formula_rec);
          elsif l_operator_rec.token in ('PLUS','MINUS') then
             push(l_formula_rec);
          end if;
      elsif (l_formula_rec.source_type = 'OPERATOR' and
          l_formula_rec.token in ('PLUS','MINUS')) THEN
          if l_lefthand_rec.source_type in ('OPERATOR') and
             l_lefthand_rec.token in ('TIMES','DIVIDE','PLUS','MINUS') then
             error_infix;
          end if;
          peek(l_operator_rec);
          if l_operator_rec.source_type = 'EMPTY' then
             push(l_formula_rec);
          elsif l_operator_rec.source_type = 'OPERATOR' and
                l_operator_rec.token = 'LEFTPAREN' then
             push(l_formula_rec);
          elsif l_operator_rec.source_type = 'OPERATOR' and
                l_operator_rec.token in ('TIMES','DIVIDE') then
             add_postfix(l_operator_rec);
             pop(l_operator_rec);
             peek(l_operator_rec);
             if l_operator_rec.source_type = 'EMPTY' then
                push(l_formula_rec);
             elsif l_operator_rec.source_type = 'OPERATOR' and
                   l_operator_rec.token = 'LEFTPAREN' then
                push(l_formula_rec);
             elsif l_operator_rec.token in ('PLUS','MINUS') then
                add_postfix(l_operator_rec);
                pop(l_operator_rec);
                push(l_formula_rec);
             end if;
          end if;
      END IF;
      l_lefthand_rec := l_formula_rec;
   end loop;

   -- check the last token here
   --
   if l_lefthand_rec.source_type = 'OPERATOR' AND l_lefthand_rec.token <> 'RIGHTPAREN' THEN
      error_infix;
   end if;

   loop
      pop(l_operator_rec);
      exit when l_operator_rec.source_type = 'EMPTY';
      if l_operator_rec.source_type = 'OPERATOR' and
         l_operator_rec.token = 'LEFTPAREN' then
         error_infix;
      else
      add_postfix(l_operator_rec);
      end if;
   end loop;
   if l_paren_count <> 0 then
      error_infix;
   end if;
end transform_formula;

PROCEDURE VALIDATE_FORMULA(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_id                  IN    NUMBER,
    p_object_version_number      IN    NUMBER
)
IS
  cursor c_get_formula(l_metric_id number)
  return stack_rec_type is
    SELECT
       decode(source_type, 'METRIC', m.metrics_name,
          'CATEGORY', c.category_name||delim.meaning||
             decode(source_sub_id, null,
                decode(use_sub_id_flag,'Y',excsubcat.meaning,incsubcat.meaning),
                sc.category_name), 'OPERATOR', opers.meaning,
					 to_char(source_value)) source_name,
        f.TOKEN, f.sequence ,
        f.object_version_number ,
        f.metric_formula_id,
        f.notation_type ,
        f.source_type ,
        f.use_sub_id_flag ,
        f.source_value ,
        f.source_id,
        f.source_sub_id
    FROM ams_metric_formulas f, ams_metrics_vl m, ams_lookups opers,
         ams_categories_vl c, ams_categories_vl sc, ams_lookups delim,
         ams_lookups incsubcat, ams_lookups excsubcat
    WHERE f.metric_id = l_metric_id
      AND f.source_id = m.metric_id(+)
      AND f.source_id = c.category_id(+)
      AND c.arc_category_created_for(+) = 'METR'
      AND f.source_sub_id = sc.category_id(+)
      AND sc.arc_category_created_for(+) = 'METR'
      AND f.token = opers.lookup_code(+)
      AND opers.lookup_type(+) = 'AMS_METRIC_OPERAND_TYPE'
      AND f.notation_type = 'INFIX'
      AND delim.lookup_type = 'AMS_METRIC_STRINGS'
      AND delim.lookup_code = 'COLON_COLON'
      AND incsubcat.lookup_type = 'AMS_METRIC_STRINGS'
      AND incsubcat.lookup_code = 'INC_SUB_CAT'
      AND excsubcat.lookup_type = 'AMS_METRIC_STRINGS'
      AND excsubcat.lookup_code = 'EXC_SUB_CAT'
      ORDER BY f.sequence ASC ;

  l_formula_str ams_metrics_all_b.formula%type;
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(4000);

  l_parentheses_count number := 0;
  l_infix_rec stack_rec_type;
  l_valid_msg varchar2(200);
BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: VALIDATE_FORMULA');
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   g_infix_tbl.delete;
   g_current_sequence := null;
   open c_get_formula(p_metric_id);
   LOOP
      fetch c_get_formula into l_infix_rec;
      exit when c_get_formula%NOTFOUND;
      g_infix_tbl(g_infix_tbl.count+1) := l_infix_rec;
   end loop;
   close c_get_formula;
   g_infix_formula := '';
   if g_infix_tbl.count > 0 then
		g_valid_formula := true;
      g_infix_index := g_infix_tbl.first;
      reset_postfix;
      transform_formula;
   end if;

   if not g_valid_formula then

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_METR_INVALID_FORMULA_DEF');
         FND_MESSAGE.set_token('FORMULA', g_infix_formula);
         FND_MESSAGE.set_token('SEQUENCE', g_error_sequence);
         FND_MSG_PUB.add;
      END IF;

       x_msg_data :=  g_infix_formula;
       x_return_status := FND_API.g_ret_sts_error;


	 RAISE FND_API.G_EXC_ERROR;
   else

      ams_metric_pvt_w.update_metric(
         p_api_version => 1,
         p_init_msg_list => FND_API.G_FALSE,
         p_commit => FND_API.G_FALSE,
         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p7_a0 => p_metric_id,
         p7_a6 => p_object_version_number,
         p7_a25 => g_infix_formula
      );



      delete from ams_metric_formulas
      where metric_id = p_metric_id
      and notation_type = 'POSTFIX';

      if g_source_type_tbl.count > 0 then
      forall l_index in g_source_type_tbl.first..g_source_type_tbl.last
         insert into ams_metric_formulas
            (METRIC_FORMULA_ID            ,
            LAST_UPDATE_DATE              ,
            LAST_UPDATED_BY               ,
            CREATION_DATE                 ,
            CREATED_BY                    ,
            LAST_UPDATE_LOGIN             ,
            OBJECT_VERSION_NUMBER         ,
            METRIC_ID                     ,
            SOURCE_TYPE                   ,
            SOURCE_ID                     ,
            TOKEN                         ,
            SEQUENCE                      ,
            NOTATION_TYPE                 ,
            SOURCE_VALUE                  ,
            SOURCE_SUB_ID                 ,
            USE_SUB_ID_FLAG               )
         values
            (AMS_METRIC_FORMULAS_S.nextval,
            sysdate,
            0,
            sysdate,
            0,
            0,
            1,
            p_metric_id,
            g_source_type_tbl(l_index),
            g_source_id_tbl(l_index),
            g_token_tbl(l_index)     ,
            g_index_tbl(l_index)   ,
            'POSTFIX',
            g_source_value_tbl(l_index)      ,
            g_source_sub_id_tbl(l_index)      ,
            g_use_sub_id_flag_tbl(l_index)     );
      end if;

   end if;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: VALIDATE_FORMULA');
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

 EXCEPTION


   WHEN FND_API.G_EXC_ERROR THEN
--     ROLLBACK TO VALIDATE_metric_formula_sp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END VALIDATE_FORMULA;

END Ams_metric_formula_Pvt;

/
