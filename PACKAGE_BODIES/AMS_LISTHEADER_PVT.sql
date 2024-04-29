--------------------------------------------------------
--  DDL for Package Body AMS_LISTHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTHEADER_PVT" as
/* $Header: amsvlshb.pls 120.4 2005/12/14 05:30:55 bmuthukr ship $ */
-- Start of Comments
--
-- NAME
--   AMS_ListHeader_PVT
--
-- PURPOSE
--   Private API for Oracle Marketing(AMS) List Headers
--
--   Procedures:

--   Create_ListHeader
--   Update_ListHeader
--   Delete_ListHeader
--   Lock_ListHeader

--   Validate_ListHeader
--   Validate_List_Record
--   Validate_List_Items
--   Validate_ListStatus

--   Check_List_Req_Items
--   Check_List_uk_items
--   Check_List_fk_items
--   Check_List_lookup_items
--   Check_List_flag_items

--   Complete_ListHeader_rec
--   Init_ListHeader_rec
--   Update_Prev_contacted_count

-- HISTORY
--   05/12/1999        tdonohoe   created
--   01/03/2001        gjoby      Added validations, for list header type,
--                                source type, moved the name and description
--                                to tl tables, cue cards validation

-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ListHeader_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvlshb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Start of Comments
--
-- NAME
--   Validate_ListStatus
--
-- PURPOSE
--   This Function validates the changing of a list status.
-- NOTES
--
--
-- HISTORY
--   10/13/1999 tdonohoe created.
--   06/30/2000 tdonohoe commented out TEMPLATE list restriction.
--   06/30/2000 tdonohoe commented out status check as there are no STATUS rules in AMS_STATUS_ORDER_RULES.
--   01/18/2001 gjoby check ams_lookups for ams_list_status
-- End of Comments



PROCEDURE Validate_ListStatus(p_user_status_id IN  NUMBER,
                              x_system_status_code  OUT NOCOPY  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

  l_meaning varchar2(80);
  CURSOR c_system_status_code is
  SELECT system_status_code
  FROM   ams_user_statuses_vl
  WHERE  user_status_id = p_user_status_id ;
BEGIN
  --  Initialize API/Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  open c_system_status_code ;
  fetch c_system_status_code into x_system_status_code;
  if c_system_status_code%notfound then
         x_return_status := FND_API.g_ret_sts_error;
  end if;
  close c_system_status_code ;
END Validate_ListStatus;

---------------------------------------------------------------------
-- PROCEDURE
--    check_list_flag_items
--
-- HISTORY
--    10/12/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_list_flag_items(
   p_listheader_rec   IN list_header_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- ENABLE_LOG_FLAG ------------------------
   IF p_listheader_rec.ENABLE_LOG_FLAG <> FND_API.g_miss_char
     AND p_listheader_rec.ENABLE_LOG_FLAG IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.ENABLE_LOG_FLAG) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_LOG_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- ENABLE_WORD_REPLACEMENT_FLAG------------------------
   IF p_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG <> FND_API.g_miss_char
      AND p_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_WORD_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- ENABLE_PARALLEL_DML_FLAG------------------------
   IF p_listheader_rec.ENABLE_PARALLEL_DML_FLAG <> FND_API.g_miss_char
      AND p_listheader_rec.ENABLE_PARALLEL_DML_FLAG IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.ENABLE_PARALLEL_DML_FLAG) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_DML_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- DEDUPE_DURING_GENERATION_FLAG ------------------------
   IF p_listheader_rec.DEDUPE_DURING_GENERATION_FLAG <> FND_API.g_miss_char
      AND p_listheader_rec.DEDUPE_DURING_GENERATION_FLAG IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.DEDUPE_DURING_GENERATION_FLAG) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_DEDUPE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- GENERATE_CONTROL_GROUP_FLAG ------------------------
   IF p_listheader_rec.GENERATE_CONTROL_GROUP_FLAG <> FND_API.g_miss_char
      AND p_listheader_rec.GENERATE_CONTROL_GROUP_FLAG IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.GENERATE_CONTROL_GROUP_FLAG) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_CONTROL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ---------------  LAST_GENERATION_SUCCESS_FLAG    ------------------------

   IF p_listheader_rec.LAST_GENERATION_SUCCESS_FLAG    <> FND_API.g_miss_char
      AND p_listheader_rec.LAST_GENERATION_SUCCESS_FLAG    IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.LAST_GENERATION_SUCCESS_FLAG   ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_GEN_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ---------------  LAST_GENERATION_SUCCESS_FLAG    ------------------------

   IF p_listheader_rec.ENABLED_FLAG    <> FND_API.g_miss_char
      AND p_listheader_rec.ENABLED_FLAG    IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.ENABLED_FLAG   ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ---------------  PURGE_FLAG    ------------------------

   IF p_listheader_rec.PURGE_FLAG    <> FND_API.g_miss_char
      AND p_listheader_rec.PURGE_FLAG    IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_listheader_rec.PURGE_FLAG ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_PURGE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- check other flags

END check_list_flag_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_list_lookup_items
--
-- HISTORY
--    10/12/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_list_lookup_items(
   p_listheader_rec        IN  list_header_rec_type,
   x_return_status         OUT NOCOPY  VARCHAR2
)
IS
   x_status_code   varchar2(80);
   l_valid_flag varchar2(1) := 'N';
  cursor c_check_source_type(cur_list_source_type varchar2)  is
  select 'Y'
  from ams_list_src_types
  where list_source_type in   ('TARGET','ANALYTICS')
  and source_type_code =   cur_list_source_type
  and master_source_type_flag = 'Y'
  and enabled_flag = 'Y' ;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- LIST STATUS ORDER RULES -----------------------

   IF p_listheader_rec.user_status_id <> FND_API.g_miss_num
   AND p_listheader_rec.user_status_id IS NOT NULL THEN
       Validate_ListStatus(p_user_status_id => p_listheader_rec.user_status_id,
                           x_system_status_code => x_status_code,
                           x_return_status  => x_return_status) ;

       if x_return_status = FND_API.g_ret_sts_error THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_STATUS_INVALID');
             FND_MSG_PUB.add;
          END IF;
         RETURN;
       end if;
   END IF;


   ----------------------- STATUS_CODE ------------------------
   IF p_listheader_rec.status_code <> FND_API.g_miss_char
   AND p_listheader_rec.status_code IS NOT NULL THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_STATUS',
            p_lookup_code => p_listheader_rec.status_code
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_STATUS_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- GENERATION_TYPE ------------------------
   IF p_listheader_rec.generation_type <> FND_API.g_miss_char
   AND p_listheader_rec.generation_type IS NOT NULL THEN

      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_GENERATION_TYPE',
            p_lookup_code => p_listheader_rec.generation_type
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_GEN_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

  ----------------------- ROW_SELECTION_TYPE -------------------------
  IF p_listheader_rec.row_selection_type <> FND_API.g_miss_char
  AND p_listheader_rec.row_selection_type IS NOT NULL THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_ROW_SELECT_TYPE',
            p_lookup_code => p_listheader_rec.row_selection_type
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_ROW_SELECT_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- LIST TYPE ------------------------
   IF p_listheader_rec.list_type <> FND_API.g_miss_char
   AND p_listheader_rec.list_type IS NOT NULL THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_TYPE',
            p_lookup_code => p_listheader_rec.list_type
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_TYPE_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- LIST SOURCE TYPE ------------------------
-- validate if list type is only std. -- for telesales requirement
IF p_listheader_rec.list_type = 'STANDARD' then
   IF p_listheader_rec.list_source_type <> FND_API.g_miss_char
   AND p_listheader_rec.list_source_type IS NOT NULL THEN
    IF p_listheader_rec.list_source_type <> 'EMPLOYEE_LIST' then
      open c_check_source_type(p_listheader_rec.list_source_type );
      fetch c_check_source_type into l_valid_flag;
      close c_check_source_type;
        IF l_valid_flag = 'N' THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_LIST_SOURCE_TYPE_INVALID');
              FND_MSG_PUB.add;
           END IF;

           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
    END IF;
   END IF;
END IF;

   ----------------------- PURPOSE_CODE ------------------------
   IF p_listheader_rec.purpose_code <> FND_API.g_miss_char
   AND p_listheader_rec.purpose_code IS NOT NULL THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_ACTIVITY_PURPOSES',
            p_lookup_code => p_listheader_rec.purpose_code
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_PURPOSE_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_list_lookup_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_list_fk_items
--
-- HISTORY
--    10/12/99  tdonohoe  Created.
--    04/24/2000 sugupta   modified  added fk validation for timezone
---------------------------------------------------------------------
PROCEDURE check_list_fk_items(
   p_listheader_rec        IN  list_header_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- TIMEZONE_ID ------------------------
   IF p_listheader_rec.timezone_id <> FND_API.g_miss_num
     AND p_listheader_rec.timezone_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
                                         'fnd_timezones_b',
                                         'upgrade_tz_id',
                                         p_listheader_rec.timezone_id
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_TIMEZONE_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   IF p_listheader_rec.owner_user_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'jtf_rs_resource_extns',
            'resource_id',
            p_listheader_rec.owner_user_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_LIST_BAD_OWNER_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- view application_id ------------------------
   IF p_listheader_rec.view_application_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_listheader_rec.view_application_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_LIST_BAD_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- program application_id ------------------------
   IF p_listheader_rec.program_application_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_listheader_rec.program_application_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_LIST_BAD_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_list_fk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_list_uk_items
--
-- HISTORY
--    10/12/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_list_uk_items(
   p_listheader_rec        IN  list_header_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_dummy_flag  varchar2(1) := FND_API.g_true ;
cursor c_check_create_mode  is
select FND_API.g_false
from ams_list_headers_vl
where list_name = p_listheader_rec.list_name
and view_application_id not in (522,691);
cursor c_check_update_mode  is
select FND_API.g_false
from ams_list_headers_vl
where list_name = p_listheader_rec.list_name
and list_header_id <> p_listheader_rec.list_header_id
and view_application_id not in (522,691);
cursor c_check_update_mode_02  is
select FND_API.g_false
from ams_list_headers_vl
where list_name = p_listheader_rec.list_name
and list_header_id <> p_listheader_rec.list_header_id
and nvl(purge_flag,'N') = 'N'
and view_application_id in (522,691)
and owner_user_id = p_listheader_rec.owner_user_id ;
cursor c_check_create_mode_02  is
select FND_API.g_false
from ams_list_headers_vl
where list_name = p_listheader_rec.list_name
and nvl(purge_flag,'N') = 'N'
and view_application_id in (522,691)
and owner_user_id = p_listheader_rec.owner_user_id ;
BEGIN

   --  Initialize API/Procedure return status to success
   x_return_status := FND_API.g_ret_sts_success;

   -----------------------------------------------------------------
   -- For create_listheader, when list_header_id is passed in,
   -- we need to check if this list_header_id is unique.
   -----------------------------------------------------------------
   IF ( p_validation_mode = JTF_PLSQL_API.g_create
   AND  p_listheader_rec.list_header_id IS NOT NULL) THEN

       IF AMS_Utility_PVT.check_uniqueness(
              'ams_list_headers_all',
              'list_header_id = ' || p_listheader_rec.list_header_id
            ) = FND_API.g_false
        THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_PK_EXISTS');
             FND_MSG_PUB.add;
          END IF;

      x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

   -----------------------------------------------------------------
   -- Check if list_name is unique. Need to handle create and
   -- update differently.
   -----------------------------------------------------------------
   IF (p_listheader_rec.view_application_id <> 522
      and p_listheader_rec.view_application_id <> 691  )then
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         open c_check_create_mode;
         fetch c_check_create_mode into l_valid_flag ;
         close c_check_create_mode;
      ELSE
         open c_check_update_mode;
         fetch c_check_update_mode into l_valid_flag ;
         close c_check_update_mode;
      END IF;
   ELSE
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         open c_check_create_mode_02  ;
         fetch c_check_create_mode_02 into l_valid_flag ;
         close c_check_create_mode_02  ;
      ELSE
         open c_check_update_mode_02  ;
         fetch c_check_update_mode_02 into l_valid_flag ;
         close c_check_update_mode_02  ;
      END IF;
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_DUPLICATE_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_list_uk_items;


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Check_Req_List_Items
--
-- HISTORY
--    10/12/99  tdonohoe  Created.
---------------------------------------------------------------------
-- End of Comments

PROCEDURE Check_List_Req_Items
( p_listheader_rec                       IN     list_header_rec_type,
  x_return_status                        OUT NOCOPY    VARCHAR2
) IS

l_api_name     varchar2(30);
BEGIN
    l_api_name := 'Check_list_req_items';
    --  Initialize API/Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------------
    --The List Name is Mandatory.
    -----------------------------------------------------------------------
    IF(p_listheader_rec.list_name IS NULL) THEN
         IF(FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR))THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_NAME_MISSING');
             FND_MSG_PUB.Add;
         END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            -- If any errors happen abort API/Procedure.
         return;
    END IF;

    -----------------------------------------------------------------------
    --The List Type is Mandatory.
    -----------------------------------------------------------------------
    IF (p_listheader_rec.list_type  IS NULL) THEN
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_TYPE_MISSING');
                FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
    END IF;

    -----------------------------------------------------------------------
    --The List source Type is Mandatory.
    -----------------------------------------------------------------------
    IF (p_listheader_rec.list_source_type  IS NULL) THEN
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_SOURCE_TYPE_MISSING');
                FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
    END IF;

    -----------------------------------------------------------------------
    --The List Owner User Id  is Mandatory.
    -----------------------------------------------------------------------
    IF (p_listheader_rec.owner_user_id  IS NULL) THEN
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_OWNER_MISSING');
                FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
    END IF;

    -----------------------------------------------------------------------
    --Not Mandatory but if a value is specified then validate.
    -----------------------------------------------------------------------
    IF  (p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION IS NOT NULL) AND
        (p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION <> FND_API.G_MISS_NUM)
    THEN

      IF ((p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION < 0) OR
          (p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION >= 100) )THEN
         IF(FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_RANDOM_PCT');
            FND_MESSAGE.Set_Token('RAND_VALUE',p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION);
            FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -----------------------------------------------------------------------
    --Not Mandatory but if a value is specified then validate.
    -----------------------------------------------------------------------
    IF  (p_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION IS NOT NULL)  AND
        (p_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION <> FND_API.G_MISS_NUM)
    THEN
      IF ((p_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION < 0) OR
          (p_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION > 100) )THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_CONTROL_PCT_INVALID');
             FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    EXCEPTION
       WHEN FND_API.g_exc_error THEN
         x_return_status := FND_API.g_ret_sts_error;
      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error ;
      WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
           THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
END Check_List_Req_Items;


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_List_Record
--
-- PURPOSE
--    Validate the list record level business rules.
--
-- PARAMETERS
--    p_listheader_rec: the record to be validated; may contain attributes
--                      as FND_API.g_miss_char/num/date
--    p_complete_rec:   the complete record after all "g_miss" items
--                      have been replaced by current database values
---------------------------------------------------------------------
-- End Of Comments
PROCEDURE Validate_List_Record
( p_listheader_rec                       IN     list_header_rec_type,
  p_complete_rec                         IN     list_header_rec_type := NULL,
  x_return_status                        OUT NOCOPY    VARCHAR2

) IS
        -- Status Local Variables
   l_return_status           VARCHAR2(1);  -- Return value from procedures
   l_listheader_rec          list_header_rec_type := p_complete_rec;
   l_table_name              VARCHAR2(30);
   l_pk_name                 VARCHAR2(30);
   l_source_code             AMS_SOURCE_CODES.SOURCE_CODE%TYPE;
BEGIN
  -- Debug Message
  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_List_Record: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF; */


       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message('AMS_ListHeader_PVT.Validate_List_Record: Start');
     END IF;


  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (p_listheader_rec.forecasted_start_date <> FND_API.g_miss_date) OR
     (p_listheader_rec.forecasted_end_date <> FND_API.g_miss_date) THEN
     IF (l_listheader_rec.forecasted_start_date > l_listheader_rec.forecasted_end_date) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_FCAST_RANGE_INVALID');
           FND_MSG_PUB.Add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;


--Modified by VB 09/20/2000 instead of using user_entered_start_time we should use main_gen_end_time which is a system date

    IF  (p_listheader_rec.sent_out_date <> FND_API.g_miss_date) OR
        (p_listheader_rec.main_gen_end_time <> FND_API.g_miss_date)
    THEN

         IF (l_listheader_rec.main_gen_end_time > l_listheader_rec.sent_out_date) THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.set_name('AMS', 'AMS_LIST_GEN_START_DATE');
                    FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               -- If any errors happen abort API/Procedure.
               RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;



    IF (p_listheader_rec.no_of_rows_min_requested <> FND_API.g_miss_num) OR
       (p_listheader_rec.no_of_rows_max_requested <> FND_API.g_miss_num)
    THEN

        IF l_listheader_rec.no_of_rows_max_requested < 0 THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                    FND_MESSAGE.set_name('AMS', 'AMS_LIST_MIN_MAX_NEGATIVE');
                    FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_listheader_rec.no_of_rows_min_requested < 0 THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                   FND_MESSAGE.set_name('AMS', 'AMS_LIST_MIN_MAX_NEGATIVE');
                    FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_listheader_rec.no_of_rows_max_requested <= l_listheader_rec.no_of_rows_min_requested THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                    FND_MESSAGE.set_name('AMS', 'AMS_LIST_MIN_MAX_RANGE_INVALID');
                    FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -----------------------------------------------------------------------
    --The List must be associated to a valid Marketing Activity.
    -----------------------------------------------------------------------
    IF(p_listheader_rec.arc_list_used_by <> FND_API.g_miss_char) THEN
      IF(l_listheader_rec.arc_list_used_by <> 'NONE')THEN
        AMS_UTILITY_PVT.get_qual_table_name_and_pk
          (p_sys_qual      => l_listheader_rec.arc_list_used_by,
           x_return_status => x_return_status,
           x_table_name    => l_table_name,
           x_pk_name       => l_pk_name);

        IF((l_table_name is not null) and (l_pk_name is not null))THEN
          IF(AMS_UTILITY_PVT.Check_FK_Exists(l_table_name,l_pk_name,p_listheader_rec.list_used_by_id) = FND_API.G_FALSE)THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACTIVITY_INVALID');
             FND_MESSAGE.Set_Token('LIST_ACTIVITY_CODE',p_listheader_rec.arc_list_used_by);
             FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            -- If any errors happen abort API/Procedure.
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
        -- Error, check the msg level and added an error message to the
        -- API message list
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACTIVTY_INVALID');
             FND_MESSAGE.Set_Token('LIST_ACTIVITY_CODE',p_listheader_rec.arc_list_used_by);
             FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any errors happen abort API/Procedure.
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;
    END IF;--The List must be associcated to a valid Marketing Activity.

    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
       FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
       FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_List_Record', TRUE);
       FND_MSG_PUB.Add;
    END IF;


    /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_List_Record: END', TRUE);
       FND_MSG_PUB.Add;
    END IF; */

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_List_Record;


PROCEDURE Validate_List_PK
( p_listheader_rec   IN     list_header_rec_type,
  x_listheader_id    OUT NOCOPY    NUMBER,
  x_return_status   OUT NOCOPY    VARCHAR2
) IS

l_dummy         NUMBER;
l_list_header_id    AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE;

CURSOR C (p_list_header_id varchar2) IS
SELECT COUNT(1)
FROM   AMS_LIST_HEADERS_ALL
WHERE  LIST_HEADER_ID = p_list_header_id;

-- list header sequence #
CURSOR listheader_seq IS
SELECT ams_list_headers_all_s.nextval
FROM DUAL;

BEGIN

--  Initialize API/Procedure return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_listheader_rec.list_header_id IS NOT NULL THEN
     OPEN C(p_listheader_rec.list_header_id );
     FETCH C INTO l_dummy;
     CLOSE C;
     IF l_dummy >= 1 THEN
     -- Error, check the msg level and added an error message to the
     -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_PK_EXISTS');
           FND_MESSAGE.Set_Token('LIST_PK',p_listheader_rec.list_header_id, FALSE);
           FND_MSG_PUB.Add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        x_listheader_id := p_listheader_rec.list_header_id;
     END IF;

    ELSE
      <<Get_PK>>
      LOOP
        --------------------------------------------
        -- open cursor AND fetch into local variable
        open listheader_seq;
        --------------------------------------------
        FETCH listheader_seq INTO l_list_header_id;
        CLOSE listheader_seq;

        OPEN C(l_list_header_id);
        FETCH C INTO l_dummy;
        CLOSE C;

        x_listheader_id := l_list_header_id;

        -- exit when unique key found
        EXIT WHEN l_dummy = 0;

      END LOOP;

    END IF;

END Validate_List_PK;

-- Start of Comments
--
-- NAME
--   Validate_List_Items
--
-- PURPOSE
--   This procedure is to validate list header items
--
-- NOTES
--
--
-- HISTORY
--   05/18/1999       tdonohoe           created
-- End of Comments


PROCEDURE Validate_List_Items
( p_listheader_rec                       IN     list_header_rec_type,
  p_validation_mode                      IN     VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status                        OUT NOCOPY    VARCHAR2
) IS

BEGIN
    --  Initialize API/Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    check_list_req_items(
      p_listheader_rec       => p_listheader_rec,
      x_return_status        => x_return_status);

    IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
    END IF;
    check_list_uk_items(
      p_listheader_rec  => p_listheader_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status);

    IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
    END IF;

    check_list_fk_items(
      p_listheader_rec => p_listheader_rec,
      x_return_status  => x_return_status);

    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    check_list_lookup_items(
      p_listheader_rec  => p_listheader_rec,
      x_return_status   => x_return_status);

    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
   check_list_flag_items(
      p_listheader_rec  => p_listheader_rec,
      x_return_status   => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

END Validate_List_Items;


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListHeader
--
-- PURPOSE
--    Validate a List Header Record.
--
-- PARAMETERS
--    p_listheader_rec: the list header record to be validated
--
-- NOTES
--    1. p_listheader_rec_rec should be the complete list header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments


PROCEDURE Validate_ListHeader
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  p_listheader_rec         IN     list_header_rec_type
)  IS

l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_ListHeader';
l_api_version         CONSTANT NUMBER        := 1.0;

-- Status Local Variables
l_return_status                VARCHAR2(1);  -- Return value from procedures
l_listheader_rec               list_header_rec_type := p_listheader_rec;
l_default_listhd_rec           list_header_rec_type;
l_listheader_id                number;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListHeader: Start', TRUE);
      FND_MSG_PUB.Add;
   END IF; */

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.Validate_listheaders: Start');
        END IF;



   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --

    -- Step 1.
    -- Validate all non missing attributes (Item level validation)
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
        Validate_List_Items
        ( p_listheader_rec                  => l_listheader_rec,
          p_validation_mode                 => JTF_PLSQL_API.g_update,
          x_return_status                   => x_return_status
        );
        -- If any errors happen abort API.
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    -- Step 2.
    -- Perform cross attribute validation and missing attribute checks. Record
    -- level validation.
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

        Validate_List_Record
        ( p_listheader_rec      => p_listheader_rec,
          p_complete_rec        => l_listheader_rec,
          x_return_status       => x_return_status);

        -- If any errors happen abort API.
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

        --
        -- END of API body.
        --

        -- Success Message
        -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListHeader', TRUE);
            FND_MSG_PUB.Add;
        END IF;


    /* ckapoor    IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListHeader: END', TRUE);
            FND_MSG_PUB.Add;
        END IF; */
      -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
       ( p_count    => x_msg_count,
         p_data     => x_msg_data,
         p_encoded  => FND_API.G_FALSE
         );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
       ( p_count    =>  x_msg_count,
       p_data     =>  x_msg_data,
       p_encoded  =>  FND_API.G_FALSE
       );
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;

          FND_MSG_PUB.Count_AND_Get
            ( p_count    =>      x_msg_count,
              p_data     =>      x_msg_data,
              p_encoded  =>      FND_API.G_FALSE
            );
END Validate_ListHeader;




-- Start of Comments
--
-- NAME
--   Create_ListHeader
--
-- PURPOSE
--   This procedure creates a list header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments
PROCEDURE Create_ListHeader
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level      IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_listheader_rec        IN     list_header_rec_type,
  x_listheader_id         OUT NOCOPY    NUMBER
)  IS

l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListHeader';
l_api_version         CONSTANT NUMBER        := 1.0;
-- Status Local Variables
l_return_status                VARCHAR2(1);  -- Return value from procedures
l_listheader_rec               list_header_rec_type := p_listheader_rec;
l_listheader_id                number;

x_rowid VARCHAR2(30);

l_sqlerrm varchar2(600);
l_sqlcode varchar2(100);

l_list_count     NUMBER;
l_main_gen_time  DATE := null;

CURSOR c_list_seq IS
SELECT ams_list_headers_all_s.NEXTVAL
FROM DUAL;

CURSOR c_list_count(p_list_header_id IN NUMBER) IS
SELECT COUNT(*)
FROM   ams_list_headers_all
WHERE  list_header_id = p_list_header_id;
L_OBJECT_TYPE  VARCHAR2(10) := 'LIST';

CURSOR c_custom_setup_id(c_list_type in varchar2) IS
SELECT custom_setup_id
FROM   ams_custom_setups_b
WHERE  object_type = L_OBJECT_TYPE
and   activity_type_code  = c_list_type
--AND    enabled_flag = 'Y'
      ;

CURSOR c_default_list_user_status_id IS
SELECT user_status_id
       FROM ams_user_statuses_vl
       WHERE system_status_type = 'AMS_LIST_STATUS'
       AND system_status_code = 'DRAFT'
       AND enabled_flag = 'Y'
       AND default_flag = 'Y';


l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Create_listheaders_PVT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeaders_PVT.Create_listheaders: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF; */

     IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.Create_listheaders: Start');
     END IF;


  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  IF (l_listheader_rec.list_header_id IS NULL OR
      l_listheader_rec.list_header_id = FND_API.g_miss_num) THEN LOOP
     OPEN  c_list_seq;
     FETCH c_list_seq INTO l_listheader_rec.list_header_id;
     CLOSE c_list_seq;

     OPEN  c_list_count(l_listheader_rec.list_header_id);
     FETCH c_list_count INTO l_list_count;
     CLOSE c_list_count;

     EXIT WHEN l_list_count = 0;
     END LOOP;
  END IF;

  IF (l_listheader_rec.USER_ENTERED_START_TIME IS NOT NULL
     AND l_listheader_rec.TIMEZONE_ID IS NOT NULL
     AND l_listheader_rec.TIMEZONE_ID <> FND_API.g_miss_num) THEN

     AMS_UTILITY_PVT.Convert_Timezone(
            p_init_msg_list    => l_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_user_tz_id       => l_listheader_rec.TIMEZONE_ID,
            p_in_time          => l_listheader_rec.USER_ENTERED_START_TIME,
            p_convert_type     => 'SYS',
            x_out_time         => l_main_gen_time
            );

       -- If any errors happen abort API.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


      -- initialize any default values
      OPEN c_custom_setup_id(l_listheader_rec.list_type);
      FETCH c_custom_setup_id INTO l_listheader_rec.custom_setup_id;
      CLOSE c_custom_setup_id;

      OPEN c_default_list_user_status_id;
      FETCH c_default_list_user_status_id INTO l_listheader_rec.user_status_id;
      CLOSE c_default_list_user_status_id;

      IF l_listheader_rec.country IS NULL OR l_listheader_rec.country = FND_API.g_miss_num THEN
         l_listheader_rec.country := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');
      END IF;

    Validate_ListHeader
    ( p_api_version              => 1.0
      ,p_init_msg_list           => l_init_msg_list
      ,p_validation_level        => p_validation_level
      ,x_return_status           => x_return_status
      ,x_msg_count               => x_msg_count
      ,x_msg_data                => x_msg_data
      ,p_listheader_rec          => l_listheader_rec
     );


    -- If any errors happen abort API.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  insert into AMS_LIST_HEADERS_ALL (
   LIST_HEADER_ID   ,
   LAST_UPDATE_DATE   ,
   LAST_UPDATED_BY   ,
   CREATION_DATE   ,
   CREATED_BY   ,
   LAST_UPDATE_LOGIN   ,
   OBJECT_VERSION_NUMBER   ,
   REQUEST_ID   ,
   PROGRAM_ID   ,
   PROGRAM_APPLICATION_ID   ,
   PROGRAM_UPDATE_DATE   ,
   VIEW_APPLICATION_ID   ,
   LIST_USED_BY_ID   ,
   ARC_LIST_USED_BY   ,
   LIST_TYPE   ,
   STATUS_CODE   ,
   STATUS_DATE   ,
   GENERATION_TYPE   ,
   REPEAT_EXCLUDE_TYPE   ,
   ROW_SELECTION_TYPE   ,
   OWNER_USER_ID   ,
   ACCESS_LEVEL   ,
   ENABLE_LOG_FLAG   ,
   ENABLE_WORD_REPLACEMENT_FLAG   ,
   ENABLE_PARALLEL_DML_FLAG   ,
   DEDUPE_DURING_GENERATION_FLAG   ,
   GENERATE_CONTROL_GROUP_FLAG   ,
   LAST_GENERATION_SUCCESS_FLAG   ,
   FORECASTED_START_DATE   ,
   FORECASTED_END_DATE   ,
   ACTUAL_END_DATE   ,
   SENT_OUT_DATE   ,
   DEDUPE_START_DATE   ,
   LAST_DEDUPE_DATE   ,
   LAST_DEDUPED_BY_USER_ID   ,
   WORKFLOW_ITEM_KEY   ,
   NO_OF_ROWS_DUPLICATES   ,
   NO_OF_ROWS_MIN_REQUESTED   ,
   NO_OF_ROWS_MAX_REQUESTED   ,
   NO_OF_ROWS_IN_LIST   ,
   NO_OF_ROWS_IN_CTRL_GROUP   ,
   NO_OF_ROWS_ACTIVE   ,
   NO_OF_ROWS_INACTIVE   ,
   NO_OF_ROWS_MANUALLY_ENTERED   ,
   NO_OF_ROWS_DO_NOT_CALL   ,
   NO_OF_ROWS_DO_NOT_MAIL   ,
   NO_OF_ROWS_RANDOM   ,
   ORG_ID   ,
   MAIN_GEN_START_TIME   ,
   MAIN_GEN_END_TIME   ,
   MAIN_RANDOM_NTH_ROW_SELECTION   ,
   MAIN_RANDOM_PCT_ROW_SELECTION   ,
   CTRL_RANDOM_NTH_ROW_SELECTION   ,
   CTRL_RANDOM_PCT_ROW_SELECTION   ,
   REPEAT_SOURCE_LIST_HEADER_ID   ,
   RESULT_TEXT   ,
   KEYWORDS   ,
   DESCRIPTION   ,
   LIST_PRIORITY   ,
   ASSIGN_PERSON_ID   ,
   LIST_SOURCE   ,
   LIST_SOURCE_TYPE   ,
   LIST_ONLINE_FLAG   ,
   RANDOM_LIST_ID   ,
   ENABLED_FLAG   ,
   ASSIGNED_TO   ,
   QUERY_ID   ,
   OWNER_PERSON_ID   ,
   ARCHIVED_BY   ,
   ARCHIVED_DATE   ,
   ATTRIBUTE_CATEGORY   ,
   ATTRIBUTE1   ,
   ATTRIBUTE2   ,
   ATTRIBUTE3   ,
   ATTRIBUTE4   ,
   ATTRIBUTE5   ,
   ATTRIBUTE6   ,
   ATTRIBUTE7   ,
   ATTRIBUTE8   ,
   ATTRIBUTE9   ,
   ATTRIBUTE10   ,
   ATTRIBUTE11   ,
   ATTRIBUTE12   ,
   ATTRIBUTE13   ,
   ATTRIBUTE14   ,
   ATTRIBUTE15   ,
   TIMEZONE_ID   ,
   USER_ENTERED_START_TIME   ,
   USER_STATUS_ID   ,
   QUANTUM   ,
   RELEASE_CONTROL_ALG_ID   ,
   DIALING_METHOD   ,
   CALLING_CALENDAR_ID   ,
   RELEASE_STRATEGY   ,
   CUSTOM_SETUP_ID   ,
   COUNTRY   ,
   CALLBACK_PRIORITY_FLAG   ,
   CALL_CENTER_READY_FLAG   ,
   PURGE_FLAG   ,
   QUOTA   ,
   QUOTA_RESET   ,
   RECYCLING_ALG_ID   ,
   PUBLIC_FLAG   ,
   LIST_CATEGORY ,
   no_of_rows_prev_contacted,
   APPLY_TRAFFIC_COP,
   purpose_code,
    CTRL_CONF_LEVEL,
    CTRL_REQ_RESP_RATE	,
    CTRL_LIMIT_OF_ERROR	,
    STATUS_CODE_OLD,
    CTRL_CONC_JOB_ID	,
    CTRL_STATUS_CODE	,
    CTRL_GEN_MODE	,
 APPLY_SUPPRESSION_FLAG
  ) values (
   decode(l_listheader_rec.LIST_HEADER_ID ,FND_API.g_miss_num,null,l_listheader_rec.LIST_HEADER_ID) ,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
   decode(l_listheader_rec.REQUEST_ID ,FND_API.g_miss_num,null,l_listheader_rec.REQUEST_ID) ,
   decode(l_listheader_rec.PROGRAM_ID ,FND_API.g_miss_num,null,l_listheader_rec.PROGRAM_ID) ,
   decode(l_listheader_rec.PROGRAM_APPLICATION_ID ,FND_API.g_miss_num,null,l_listheader_rec.PROGRAM_APPLICATION_ID) ,
   decode(l_listheader_rec.PROGRAM_UPDATE_DATE ,FND_API.g_miss_date,null,l_listheader_rec.PROGRAM_UPDATE_DATE) ,
   decode(l_listheader_rec.VIEW_APPLICATION_ID ,FND_API.g_miss_num,530,nvl(l_listheader_rec.VIEW_APPLICATION_ID,530)) ,
   decode(l_listheader_rec.LIST_USED_BY_ID ,FND_API.g_miss_num,0,nvl(l_listheader_rec.LIST_USED_BY_ID,0)) ,
   decode(l_listheader_rec.ARC_LIST_USED_BY ,FND_API.g_miss_char,'NONE',nvl(l_listheader_rec.ARC_LIST_USED_BY,'NONE')) ,
   decode(l_listheader_rec.LIST_TYPE ,FND_API.g_miss_char,null,l_listheader_rec.LIST_TYPE) ,
   decode(l_listheader_rec.STATUS_CODE ,FND_API.g_miss_char,'DRAFT',nvl(l_listheader_rec.STATUS_CODE,'DRAFT')) ,
   decode(l_listheader_rec.STATUS_DATE ,FND_API.g_miss_date,sysdate,nvl(l_listheader_rec.STATUS_DATE,sysdate)) ,
   decode(l_listheader_rec.GENERATION_TYPE ,FND_API.g_miss_char,'STANDARD',nvl(l_listheader_rec.GENERATION_TYPE,'STANDARD')) ,
   decode(l_listheader_rec.REPEAT_EXCLUDE_TYPE ,FND_API.g_miss_char,null,l_listheader_rec.REPEAT_EXCLUDE_TYPE) ,
   decode(l_listheader_rec.ROW_SELECTION_TYPE ,FND_API.g_miss_char,'STANDARD',nvl(l_listheader_rec.ROW_SELECTION_TYPE,'STANDARD')) ,
   decode(l_listheader_rec.OWNER_USER_ID ,FND_API.g_miss_num,null,l_listheader_rec.OWNER_USER_ID) ,
   decode(l_listheader_rec.ACCESS_LEVEL ,FND_API.g_miss_char,'USER',nvl(l_listheader_rec.ACCESS_LEVEL,'USER')) ,
   decode(l_listheader_rec.ENABLE_LOG_FLAG ,FND_API.g_miss_char,'Y',nvl(l_listheader_rec.ENABLE_LOG_FLAG,'Y')) ,
   decode(l_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG ,FND_API.g_miss_char,'N',nvl(l_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG,'N')) ,
   decode(l_listheader_rec.ENABLE_PARALLEL_DML_FLAG ,FND_API.g_miss_char,'N',nvl(l_listheader_rec.ENABLE_PARALLEL_DML_FLAG,'N')) ,
   decode(l_listheader_rec.DEDUPE_DURING_GENERATION_FLAG ,FND_API.g_miss_char,'N',nvl(l_listheader_rec.DEDUPE_DURING_GENERATION_FLAG,'N')) ,
   decode(l_listheader_rec.GENERATE_CONTROL_GROUP_FLAG ,FND_API.g_miss_char,'N',nvl(l_listheader_rec.GENERATE_CONTROL_GROUP_FLAG,'N')) ,
   decode(l_listheader_rec.LAST_GENERATION_SUCCESS_FLAG ,FND_API.g_miss_char,'N',nvl(l_listheader_rec.LAST_GENERATION_SUCCESS_FLAG,'N')) ,
   decode(l_listheader_rec.FORECASTED_START_DATE ,FND_API.g_miss_date,sysdate,nvl(l_listheader_rec.FORECASTED_START_DATE,sysdate)) ,
   decode(l_listheader_rec.FORECASTED_END_DATE ,FND_API.g_miss_date,null,l_listheader_rec.FORECASTED_END_DATE) ,
   decode(l_listheader_rec.ACTUAL_END_DATE ,FND_API.g_miss_date,null,l_listheader_rec.ACTUAL_END_DATE) ,
   decode(l_listheader_rec.SENT_OUT_DATE ,FND_API.g_miss_date,null,l_listheader_rec.SENT_OUT_DATE) ,
   decode(l_listheader_rec.DEDUPE_START_DATE ,FND_API.g_miss_date,null,l_listheader_rec.DEDUPE_START_DATE) ,
   decode(l_listheader_rec.LAST_DEDUPE_DATE ,FND_API.g_miss_date,null,l_listheader_rec.LAST_DEDUPE_DATE) ,
   decode(l_listheader_rec.LAST_DEDUPED_BY_USER_ID ,FND_API.g_miss_num,null,l_listheader_rec.LAST_DEDUPED_BY_USER_ID) ,
   decode(l_listheader_rec.WORKFLOW_ITEM_KEY ,FND_API.g_miss_num,null,l_listheader_rec.WORKFLOW_ITEM_KEY) ,
   decode(l_listheader_rec.NO_OF_ROWS_DUPLICATES ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_DUPLICATES) ,
   decode(l_listheader_rec.NO_OF_ROWS_MIN_REQUESTED ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_MIN_REQUESTED) ,
   decode(l_listheader_rec.NO_OF_ROWS_MAX_REQUESTED ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_MAX_REQUESTED) ,
   decode(l_listheader_rec.NO_OF_ROWS_IN_LIST ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_IN_LIST) ,
   decode(l_listheader_rec.NO_OF_ROWS_IN_CTRL_GROUP ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_IN_CTRL_GROUP) ,
   decode(l_listheader_rec.NO_OF_ROWS_ACTIVE ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_ACTIVE) ,
   decode(l_listheader_rec.NO_OF_ROWS_INACTIVE ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_INACTIVE) ,
   decode(l_listheader_rec.NO_OF_ROWS_MANUALLY_ENTERED ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_MANUALLY_ENTERED) ,
   decode(l_listheader_rec.NO_OF_ROWS_DO_NOT_CALL ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_DO_NOT_CALL) ,
   decode(l_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL) ,
   decode(l_listheader_rec.NO_OF_ROWS_RANDOM ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_RANDOM) ,
   decode(l_listheader_rec.ORG_ID ,FND_API.g_miss_num,
                TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)),
  nvl(l_listheader_rec.ORG_ID,TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)))) ,
   decode(l_listheader_rec.MAIN_GEN_START_TIME ,FND_API.g_miss_date,null,l_listheader_rec.MAIN_GEN_START_TIME) ,
   decode(l_listheader_rec.MAIN_GEN_END_TIME ,FND_API.g_miss_date,null,l_listheader_rec.MAIN_GEN_END_TIME) ,
   decode(l_listheader_rec.MAIN_RANDOM_NTH_ROW_SELECTION ,FND_API.g_miss_num,null,l_listheader_rec.MAIN_RANDOM_NTH_ROW_SELECTION) ,
   decode(l_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION ,FND_API.g_miss_num,null,l_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION) ,
   decode(l_listheader_rec.CTRL_RANDOM_NTH_ROW_SELECTION ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_RANDOM_NTH_ROW_SELECTION) ,
   decode(l_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION) ,
   decode(l_listheader_rec.REPEAT_SOURCE_LIST_HEADER_ID ,FND_API.g_miss_char,null,l_listheader_rec.REPEAT_SOURCE_LIST_HEADER_ID) ,
   decode(l_listheader_rec.RESULT_TEXT ,FND_API.g_miss_char,null,l_listheader_rec.RESULT_TEXT) ,
   decode(l_listheader_rec.KEYWORDS ,FND_API.g_miss_char,null,l_listheader_rec.KEYWORDS) ,
   decode(l_listheader_rec.DESCRIPTION ,FND_API.g_miss_char,null,l_listheader_rec.DESCRIPTION) ,
   decode(l_listheader_rec.LIST_PRIORITY ,FND_API.g_miss_num,null,l_listheader_rec.LIST_PRIORITY) ,
   decode(l_listheader_rec.ASSIGN_PERSON_ID ,FND_API.g_miss_num,null,l_listheader_rec.ASSIGN_PERSON_ID) ,
   decode(l_listheader_rec.LIST_SOURCE ,FND_API.g_miss_char,null,l_listheader_rec.LIST_SOURCE) ,
   decode(l_listheader_rec.LIST_SOURCE_TYPE ,FND_API.g_miss_char,null,l_listheader_rec.LIST_SOURCE_TYPE) ,
   decode(l_listheader_rec.LIST_ONLINE_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.LIST_ONLINE_FLAG) ,
   decode(l_listheader_rec.RANDOM_LIST_ID ,FND_API.g_miss_num,null,l_listheader_rec.RANDOM_LIST_ID) ,
   decode(l_listheader_rec.ENABLED_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.ENABLED_FLAG) ,
   decode(l_listheader_rec.ASSIGNED_TO ,FND_API.g_miss_num,null,l_listheader_rec.ASSIGNED_TO) ,
   decode(l_listheader_rec.QUERY_ID ,FND_API.g_miss_num,null,l_listheader_rec.QUERY_ID) ,
   decode(l_listheader_rec.OWNER_PERSON_ID ,FND_API.g_miss_num,null,l_listheader_rec.OWNER_PERSON_ID) ,
   decode(l_listheader_rec.ARCHIVED_BY ,FND_API.g_miss_num,null,l_listheader_rec.ARCHIVED_BY) ,
   decode(l_listheader_rec.ARCHIVED_DATE ,FND_API.g_miss_date,null,l_listheader_rec.ARCHIVED_DATE) ,
   decode(l_listheader_rec.ATTRIBUTE_CATEGORY ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE_CATEGORY) ,
   decode(l_listheader_rec.ATTRIBUTE1 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE1) ,
   decode(l_listheader_rec.ATTRIBUTE2 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE2) ,
   decode(l_listheader_rec.ATTRIBUTE3 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE3) ,
   decode(l_listheader_rec.ATTRIBUTE4 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE4) ,
   decode(l_listheader_rec.ATTRIBUTE5 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE5) ,
   decode(l_listheader_rec.ATTRIBUTE6 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE6) ,
   decode(l_listheader_rec.ATTRIBUTE7 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE7) ,
   decode(l_listheader_rec.ATTRIBUTE8 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE8) ,
   decode(l_listheader_rec.ATTRIBUTE9 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE9) ,
   decode(l_listheader_rec.ATTRIBUTE10 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE10) ,
   decode(l_listheader_rec.ATTRIBUTE11 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE11) ,
   decode(l_listheader_rec.ATTRIBUTE12 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE12) ,
   decode(l_listheader_rec.ATTRIBUTE13 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE13) ,
   decode(l_listheader_rec.ATTRIBUTE14 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE14) ,
   decode(l_listheader_rec.ATTRIBUTE15 ,FND_API.g_miss_char,null,l_listheader_rec.ATTRIBUTE15) ,
   decode(l_listheader_rec.TIMEZONE_ID ,FND_API.g_miss_num,null,l_listheader_rec.TIMEZONE_ID) ,
   decode(l_listheader_rec.USER_ENTERED_START_TIME ,FND_API.g_miss_date,null,l_listheader_rec.USER_ENTERED_START_TIME) ,
--   decode(l_listheader_rec.USER_STATUS_ID ,FND_API.g_miss_num,300,nvl(l_listheader_rec.USER_STATUS_ID,300)) ,
   decode(l_listheader_rec.USER_STATUS_ID ,FND_API.g_miss_num,null,l_listheader_rec.USER_STATUS_ID) ,
   decode(l_listheader_rec.QUANTUM ,FND_API.g_miss_num,null,l_listheader_rec.QUANTUM) ,
   decode(l_listheader_rec.RELEASE_CONTROL_ALG_ID ,FND_API.g_miss_num,null,l_listheader_rec.RELEASE_CONTROL_ALG_ID) ,
   decode(l_listheader_rec.DIALING_METHOD ,FND_API.g_miss_char,null,l_listheader_rec.DIALING_METHOD) ,
   decode(l_listheader_rec.CALLING_CALENDAR_ID ,FND_API.g_miss_num,null,l_listheader_rec.CALLING_CALENDAR_ID) ,
   decode(l_listheader_rec.RELEASE_STRATEGY ,FND_API.g_miss_char,null,l_listheader_rec.RELEASE_STRATEGY) ,
   decode(l_listheader_rec.CUSTOM_SETUP_ID ,FND_API.g_miss_num,null,l_listheader_rec.CUSTOM_SETUP_ID) ,
   decode(l_listheader_rec.COUNTRY ,FND_API.g_miss_num,null,l_listheader_rec.COUNTRY) ,
   decode(l_listheader_rec.CALLBACK_PRIORITY_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.CALLBACK_PRIORITY_FLAG) ,
   decode(l_listheader_rec.CALL_CENTER_READY_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.CALL_CENTER_READY_FLAG) ,
   decode(l_listheader_rec.PURGE_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.PURGE_FLAG) ,
   decode(l_listheader_rec.QUOTA ,FND_API.g_miss_num,null,l_listheader_rec.QUOTA) ,
   decode(l_listheader_rec.QUOTA_RESET ,FND_API.g_miss_num,null,l_listheader_rec.QUOTA_RESET) ,
   decode(l_listheader_rec.RECYCLING_ALG_ID ,FND_API.g_miss_num,null,l_listheader_rec.RECYCLING_ALG_ID) ,
   decode(l_listheader_rec.PUBLIC_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.PUBLIC_FLAG) ,
   decode(l_listheader_rec.LIST_CATEGORY ,FND_API.g_miss_char,null,l_listheader_rec.LIST_CATEGORY) ,
   decode(l_listheader_rec.NO_OF_ROWS_prev_contacted ,FND_API.g_miss_num,null,l_listheader_rec.NO_OF_ROWS_prev_contacted) ,
   decode(l_listheader_rec.APPLY_TRAFFIC_COP ,FND_API.g_miss_char,null,l_listheader_rec.APPLY_TRAFFIC_COP),
   decode(l_listheader_rec.PURPOSE_CODE ,FND_API.g_miss_char,'GENERAL',null,'GENERAL',l_listheader_rec.PURPOSE_CODE) ,

 -- ckapoor R12 enhancement for copy target group changes
   decode(l_listheader_rec.CTRL_CONF_LEVEL ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_CONF_LEVEL) ,
   decode(l_listheader_rec.CTRL_REQ_RESP_RATE ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_REQ_RESP_RATE) ,
   decode(l_listheader_rec.CTRL_LIMIT_OF_ERROR ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_LIMIT_OF_ERROR) ,
   decode(l_listheader_rec.STATUS_CODE_OLD ,FND_API.g_miss_char,null,l_listheader_rec.STATUS_CODE_OLD) ,
   decode(l_listheader_rec.CTRL_CONC_JOB_ID ,FND_API.g_miss_num,null,l_listheader_rec.CTRL_CONC_JOB_ID) ,
   decode(l_listheader_rec.CTRL_STATUS_CODE ,FND_API.g_miss_char,null,l_listheader_rec.CTRL_STATUS_CODE) ,
   decode(l_listheader_rec.CTRL_GEN_MODE ,FND_API.g_miss_char,null, l_listheader_rec.CTRL_GEN_MODE) ,
   decode(l_listheader_rec.APPLY_SUPPRESSION_FLAG ,FND_API.g_miss_char,null,l_listheader_rec.APPLY_SUPPRESSION_FLAG)
-- end ckapoor R12 enhancement for copy target group changes

  );

  insert into AMS_LIST_HEADERS_ALL_TL (
    LANGUAGE,
    SOURCE_LANG,
    LIST_NAME,
    DESCRIPTION,
    LIST_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
   decode(l_listheader_rec.LIST_NAME ,FND_API.g_miss_char,null,l_listheader_rec.LIST_NAME) ,
   decode(l_listheader_rec.DESCRIPTION ,FND_API.g_miss_char,null,l_listheader_rec.DESCRIPTION) ,
   decode(l_listheader_rec.LIST_HEADER_ID ,FND_API.g_miss_num,null,l_listheader_rec.LIST_HEADER_ID) ,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_HEADERS_ALL_TL T
    where T.LIST_HEADER_ID = l_listheader_rec.LIST_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


      -- set OUT value
      x_listheader_id := l_listheader_rec.list_header_id;

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Create_listheaders', TRUE);
            FND_MSG_PUB.Add;
      END IF;

      /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Create_listheaders: END', TRUE);
            FND_MSG_PUB.Add;
      END IF; */


      -- Standard call to get message count AND IF count is 1, get message info.
      FND_MSG_PUB.Count_AND_Get
          ( p_count        =>      x_msg_count,
            p_data         =>      x_msg_data,
            p_encoded      =>        FND_API.G_FALSE
          );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_listheaders_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
           );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_listheaders_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      ( p_count      =>      x_msg_count,
        p_data       =>      x_msg_data,
        p_encoded    =>      FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO Create_listheaders_PVT;
      FND_MESSAGE.set_name('AMS','SQL ERROR ->' || sqlerrm );
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

END Create_listheader;


-- Start of Comments
-----------------------------------------------------------------------------
-- NAME
--   Update_listheader
--
-- PURPOSE
--   This procedure is to update a List Header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/12/1999 tdonohoe  created
--   03/02/2000 tdonohoe  modified  code to update Source Code details on the
--                        list entry table when the list association is updated.
--   02/11/2000 tdonohoe  modified code to update STATUS_CODE to LOCKED when the
--                        sent out date is populated.
-- End of Comments

PROCEDURE Update_ListHeader
( p_api_version          IN     NUMBER,
  p_init_msg_list        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_listheader_rec       IN     list_header_rec_type
) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Update_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;
  -- Status Local Variables
  l_return_status                VARCHAR2(1);  -- Return value from procedures
  l_listheader_rec               list_header_rec_type := p_listheader_rec;
  l_sqlerrm varchar2(600);
  l_sqlcode varchar2(100);
  l_msg_count      number;
  l_msg_data       varchar2(500);
  l_item_type varchar2(100) := 'AMSLISTG';
  l_item_key   varchar2(100);
  cursor check_wf
  is select item_key
  from wf_item_activity_statuses
  where item_type = l_item_type
  and   item_key like p_listheader_rec.list_header_id || '_%'
  and activity_status in ('ERROR','ACTIVE');

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Update_listheaders_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message
 /* ckapoor  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders: Start', TRUE);
     FND_MSG_PUB.Add;
   END IF; */

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.Update_listheaders: Start');
        END IF;


   ----------------------------------------------------------
   --  Initialize API return status to success
   ----------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------------------------------------------
   -- replace g_miss_char/num/date with current column values
   ----------------------------------------------------------
   complete_listheader_rec(p_listheader_rec, l_listheader_rec);

   IF (p_listheader_rec.USER_ENTERED_START_TIME <> fnd_api.g_miss_date
   AND p_listheader_rec.USER_ENTERED_START_TIME is not null)THEN

  if (p_listheader_rec.timezone_id is not null AND
            p_listheader_rec.timezone_id <> FND_API.g_miss_num ) then
        AMS_UTILITY_PVT.Convert_Timezone(
              p_init_msg_list        => p_init_msg_list,
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data            => x_msg_data,
              p_user_tz_id            => l_listheader_rec.TIMEZONE_ID,
              p_in_time            => l_listheader_rec.USER_ENTERED_START_TIME,
              p_convert_type        => 'SYS',
              x_out_time            => l_listheader_rec.MAIN_GEN_START_TIME);
  end if;

        -- If any errors happen abort API.
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

   -- Debug Message
  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders: Done Timezone', TRUE);
        FND_MSG_PUB.Add;
   END IF; */

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.Update_listheaders: Done timezone');
        END IF;



   ----------------------- validate ----------------------
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_list_items(
         p_listheader_rec  => l_listheader_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => x_return_status
      );

      IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- Debug Message
   /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders: Item Level Validation', TRUE);
        FND_MSG_PUB.Add;
   END IF; */

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.Update_listheaders: Item level validation');
        END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_list_record(
         p_listheader_rec => p_listheader_rec,
         p_complete_rec   => l_listheader_rec,
         x_return_status  => x_return_status
      );

   IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   END IF;
 END IF;

 -- Perform the database operation
 /* ckapoor IF (AMS_DEBUG_LOW_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT - update ams_listheaders', TRUE);
      FND_MSG_PUB.Add;
 END IF; */

      IF (AMS_DEBUG_LOW_ON) THEN
          AMS_Utility_PVT.debug_message('AMS_ListHeaders_PVT.update ams_listheaders');
      END IF;


    IF (l_listheader_rec.STATUS_CODE ='DRAFT' OR
        l_listheader_rec.STATUS_CODE ='ARCHIVED' OR
        l_listheader_rec.STATUS_CODE ='CANCELLED' ) THEN

        open  check_wf ;
        fetch check_wf into l_item_key;
        close  check_wf ;
        if l_item_key is not null then
         begin
            WF_ENGINE.abortProcess(l_item_type ,
                                l_item_key);
        exception
            when no_data_found then
                 null;
        end;
        end if;

    END IF;

    IF(l_listheader_rec.STATUS_CODE ='CANCELLED' ) THEN
    -- Delete all existing entries for this list which are in the
    -- temporary table.--
    --------------------------------------------------------------------------
      DELETE FROM ams_list_tmp_entries
      WHERE list_header_id = l_listheader_rec.list_header_id;

      ----------------------------------------------
      --Delete all existing entries for this list.--
      ----------------------------------------------
      DELETE FROM ams_list_entries
      WHERE  list_header_id =l_listheader_rec.list_header_id;

      ------------------------------------------------------------------------------
      --Delete all entries in the ams_list_src_type_usages table.                 --
      --These entries must be refreshed each time that a list is refreshed.       --
      ------------------------------------------------------------------------------
      DELETE FROM ams_list_src_type_usages
      WHERE  list_header_id =l_listheader_rec.list_header_id;

      --clear associations
      l_listheader_rec.list_used_by_id:=0;
      l_listheader_rec.arc_list_used_by:='NONE';
      --set size of list to be NULL
      l_listheader_rec.no_of_rows_in_list:=NULL;
      l_listheader_rec.no_of_rows_active:=NULL;
      l_listheader_rec.no_of_rows_inactive:=NULL;
      l_listheader_rec.no_of_rows_duplicates:=NULL;
    END IF;


    UPDATE ams_list_headers_all
    SET
    last_update_date          = sysdate
    ,last_updated_by           = FND_GLOBAL.User_Id
    ,last_update_login         = FND_GLOBAL.Conc_Login_Id
    ,object_version_number     = l_listheader_rec.object_version_number + 1
    ,request_id                = l_listheader_rec.request_id
    ,program_id                = l_listheader_rec.program_id
    ,program_application_id    = l_listheader_rec.program_application_id
    ,quantum                   = l_listheader_rec.quantum
    ,release_control_alg_id    = l_listheader_rec.release_control_alg_id
    ,dialing_method            = l_listheader_rec.dialing_method
    ,calling_calendar_id       = l_listheader_rec.calling_calendar_id
    ,release_strategy          = l_listheader_rec.release_strategy
    ,custom_setup_id           = l_listheader_rec.custom_setup_id
    ,country                   = l_listheader_rec.country
    ,purge_flag                = l_listheader_rec.PURGE_FLAG
    ,public_flag               = l_listheader_rec.public_flag
    ,list_category             = l_listheader_rec.list_category
    ,quota                     = l_listheader_rec.QUOTA
    ,quota_reset               = l_listheader_rec.QUOTA_RESET
    ,recycling_alg_id          = l_listheader_rec.RECYCLING_ALG_ID
    ,callback_priority_flag    = l_listheader_rec.callback_priority_flag
    ,call_center_ready_flag    = l_listheader_rec.call_center_ready_flag
    ,user_status_id            = l_listheader_rec.user_status_id
    ,program_update_date       = l_listheader_rec.program_update_date
    --,list_name                 = l_listheader_rec.list_name
    ,list_used_by_id           = l_listheader_rec.list_used_by_id
    ,arc_list_used_by          = l_listheader_rec.arc_list_used_by
    ,list_type                 = l_listheader_rec.list_type
    ,status_code               = l_listheader_rec.status_code
    ,status_date               = l_listheader_rec.status_date
    ,generation_type           = l_listheader_rec.generation_type
    ,row_selection_type        = l_listheader_rec.row_selection_type
    ,owner_user_id             = l_listheader_rec.owner_user_id
    ,access_level              = l_listheader_rec.access_level
    ,enable_log_flag           = l_listheader_rec.enable_log_flag
    ,enable_word_replacement_flag  = l_listheader_rec.enable_word_replacement_flag
    ,dedupe_during_generation_flag = l_listheader_rec.dedupe_during_generation_flag  --added vbhandar 10/12/2000
    ,generate_control_group_flag   = l_listheader_rec.generate_control_group_flag
    ,forecasted_start_date     = l_listheader_rec.forecasted_start_date
    ,forecasted_end_date       = l_listheader_rec.forecasted_end_date
    ,actual_end_date           = l_listheader_rec.actual_end_date
    ,sent_out_date             = l_listheader_rec.sent_out_date
    ,dedupe_start_date         = l_listheader_rec.dedupe_start_date
    ,last_dedupe_date          = l_listheader_rec.last_dedupe_date
    ,last_deduped_by_user_id   = l_listheader_rec.last_deduped_by_user_id
    ,workflow_item_key         = l_listheader_rec.workflow_item_key
    ,no_of_rows_duplicates     = l_listheader_rec.no_of_rows_duplicates
    ,no_of_rows_min_requested  = l_listheader_rec.no_of_rows_min_requested
    ,no_of_rows_max_requested  = l_listheader_rec.no_of_rows_max_requested
    ,no_of_rows_in_list        = l_listheader_rec.no_of_rows_in_list
    ,no_of_rows_in_ctrl_group  = l_listheader_rec.no_of_rows_in_ctrl_group
    ,no_of_rows_active         = l_listheader_rec.no_of_rows_active
    ,no_of_rows_inactive       = l_listheader_rec.no_of_rows_inactive
    ,no_of_rows_manually_entered  = l_listheader_rec.no_of_rows_manually_entered
    ,no_of_rows_do_not_call    = l_listheader_rec.no_of_rows_do_not_call
    ,no_of_rows_do_not_mail    = l_listheader_rec.no_of_rows_do_not_mail
    ,no_of_rows_random         = l_listheader_rec.no_of_rows_random
    ,timezone_id               = l_listheader_rec.timezone_id
    ,user_entered_start_time   = l_listheader_rec.user_entered_start_time
    ,main_gen_start_time       = l_listheader_rec.main_gen_start_time
    ,main_gen_end_time         = l_listheader_rec.main_gen_end_time
    ,main_random_nth_row_selection = l_listheader_rec.main_random_nth_row_selection
    ,main_random_pct_row_selection = l_listheader_rec.main_random_pct_row_selection
    ,ctrl_random_nth_row_selection = l_listheader_rec.ctrl_random_nth_row_selection
    ,ctrl_random_pct_row_selection = l_listheader_rec.ctrl_random_pct_row_selection
    ,result_text               = l_listheader_rec.result_text
    ,keywords                  = l_listheader_rec.keywords
    -- ,description               = l_listheader_rec.description
    ,list_priority             = l_listheader_rec.list_priority
    ,assign_person_id          = l_listheader_rec.assign_person_id
    ,list_source               = l_listheader_rec.list_source
    ,list_source_type          = l_listheader_rec.list_source_type
    ,list_online_flag          = l_listheader_rec.list_online_flag
    ,random_list_id            = l_listheader_rec.random_list_id
    ,enabled_flag              = l_listheader_rec.enabled_flag
    ,assigned_to               = l_listheader_rec.assigned_to
    ,query_id                  = l_listheader_rec.query_id
    ,owner_person_id           = l_listheader_rec.owner_person_id
    ,attribute_category        = l_listheader_rec.attribute_category
    ,attribute1                = l_listheader_rec.attribute1
    ,attribute2                = l_listheader_rec.attribute2
    ,attribute3                = l_listheader_rec.attribute3
    ,attribute4                = l_listheader_rec.attribute4
    ,attribute5                = l_listheader_rec.attribute5
    ,attribute6                = l_listheader_rec.attribute6
    ,attribute7                = l_listheader_rec.attribute7
    ,attribute8                = l_listheader_rec.attribute8
    ,attribute9                = l_listheader_rec.attribute9
    ,attribute10               = l_listheader_rec.attribute10
    ,attribute11               = l_listheader_rec.attribute11
    ,attribute12               = l_listheader_rec.attribute12
    ,attribute13               = l_listheader_rec.attribute13
    ,attribute14               = l_listheader_rec.attribute14
    ,attribute15               = l_listheader_rec.attribute15
    ,no_of_rows_prev_contacted  = l_listheader_rec.no_of_rows_prev_contacted
    ,apply_traffic_cop          =l_listheader_rec.apply_traffic_cop

    -- ckapoor R12 control group enhancements

    ,CTRL_CONF_LEVEL          =l_listheader_rec.CTRL_CONF_LEVEL
    ,CTRL_REQ_RESP_RATE       =l_listheader_rec.CTRL_REQ_RESP_RATE
    ,CTRL_LIMIT_OF_ERROR      =l_listheader_rec.CTRL_LIMIT_OF_ERROR
    ,STATUS_CODE_OLD          =l_listheader_rec.STATUS_CODE_OLD
    ,CTRL_CONC_JOB_ID         =l_listheader_rec.CTRL_CONC_JOB_ID
    ,CTRL_STATUS_CODE         =l_listheader_rec.CTRL_STATUS_CODE
    ,CTRL_GEN_MODE            =l_listheader_rec.CTRL_GEN_MODE
    ,APPLY_SUPPRESSION_FLAG   =l_listheader_rec.APPLY_SUPPRESSION_FLAG

    -- end ckapoor R12 control group enhancements



    WHERE list_header_id       = l_listheader_rec.list_header_id;
 --  AND object_version_number  = l_listheader_rec.object_version_number;

   IF (SQL%NOTFOUND)THEN
     ------------------------------------------------------------------
     -- Error, check the msg level and added an error message to the --
     -- API message list.                                            --
     ------------------------------------------------------------------
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
        FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders API', TRUE);
        FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  update AMS_LIST_HEADERS_ALL_TL set
    LIST_NAME = l_listheader_rec.LIST_NAME,
    DESCRIPTION = l_listheader_rec.DESCRIPTION,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_BY = FND_GLOBAL.user_id,
    LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
    SOURCE_LANG = userenv('LANG')
  where LIST_HEADER_ID = l_listheader_rec.LIST_HEADER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND)THEN
     ------------------------------------------------------------------
     -- Error, check the msg level and added an error message to the --
     -- API message list.                                            --
     ------------------------------------------------------------------
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
        FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders API', TRUE);
        FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --added tdonohoe 03/02/2000
   -----------------------------------------------------------------------
   --If the List Association has changed then any existing list entries --
   --must be updated.                                                   --
   --The Procedure which is called checks if the list association is new--
   --only then will it perfrom an update of the list entries.           --
    -----------------------------------------------------------------------
    IF(l_listheader_rec.ARC_LIST_USED_BY <>'NONE')THEN
      AMS_ListEntry_PVT.Update_ListEntry_Source_Code
				    (p_api_version   => 1.0,
                         p_list_id       => l_listheader_rec.list_header_id,
                         x_return_status => x_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      =>  l_msg_data);
    END IF;
    --end added tdonohoe 03/02/2000


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
       FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
       FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders', TRUE);
       FND_MSG_PUB.Add;
    END IF;

    /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Update_listheaders: END', TRUE);
       FND_MSG_PUB.Add;
    END IF; */

    -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_listheaders_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded     =>      FND_API.G_FALSE
         );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_listheaders_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded     =>      FND_API.G_FALSE
          );
   WHEN OTHERS THEN
      ROLLBACK TO Update_listheaders_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded     =>      FND_API.G_FALSE
      );

END Update_listheader;


-- Start of Comments
--
-- NAME
--   Delete_listheader
--
-- PURPOSE
--   This procedure deletes a list header record that satisfy caller needs
--
-- NOTES
-- Deletes from The following tables Ams_List_Src_Type_Usages,
--                                   Ams_List_Rule_Usages,
--                                   Ams_List_Entries,
--                                   Ams_List_Select_Actions
--                                   Ams_List_Headers_All.
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments

PROCEDURE Delete_ListHeader
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level      IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_listheader_id         IN     number) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Delete_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;

  -- Status Local Variables
  l_return_status                VARCHAR2(1);  -- Return value from procedures
  l_list_header_id               NUMBER   := p_listheader_id;
  l_return_val                   VARCHAR2(1);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Delete_listheader_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Delete_listheaders: Start', TRUE);
      FND_MSG_PUB.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Check required parameters
   IF (l_list_header_id  = FND_API.G_MISS_NUM OR l_list_header_id IS NULL )THEN
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
         FND_MESSAGE.Set_Name('AMS', 'API_INCOMPLETE_INFO');
         FND_MESSAGE.Set_Token ('PARAM', 'listheader_id', FALSE);
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      -- Perform the database operation

   IF (AMS_DEBUG_LOW_ON) THEN
      NULL;
   END IF;

   DELETE FROM ams_list_src_type_usages
   WHERE  list_header_id = l_list_header_id;

   DELETE FROM ams_list_rule_usages
   WHERE  list_header_id = l_list_header_id;

   DELETE FROM ams_list_entries
   WHERE  list_header_id = l_list_header_id;

   DELETE FROM ams_list_select_actions
   WHERE  list_header_id = l_list_header_id;

   DELETE FROM ams_list_headers_all
   WHERE  list_header_id = l_list_header_id;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
       FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
       FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Delete_listheaders', TRUE);
       FND_MSG_PUB.Add;
    END IF;


    IF (AMS_DEBUG_HIGH_ON) THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Delete_listheader: END', TRUE);
       FND_MSG_PUB.Add;
    END IF;


    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count           =>      x_msg_count,
      p_data            =>      x_msg_data,
      p_encoded         =>      FND_API.G_FALSE
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_listheader_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_listheader_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
      );


   WHEN OTHERS THEN
      ROLLBACK TO Delete_listheader_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded     =>      FND_API.G_FALSE
       );

END Delete_listheader;



-- Start of Comments
--
-- NAME
--   Lock_listheader
--
-- PURPOSE
--   This procedure is to lock a list header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/13/1999        tdonohoe            created
-- End of Comments


PROCEDURE Lock_ListHeader
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level           IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,
  p_listheader_id              IN     NUMBER,
  p_object_version             IN  NUMBER
) IS


  l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_list_header_id      NUMBER;

  CURSOR c_list_header_id IS
  SELECT list_header_id
  FROM   ams_list_headers_all
  WHERE  list_header_id = p_listheader_id
  AND    object_version_number = p_object_version
  FOR UPDATE OF list_header_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_list_header_id;
   FETCH c_list_header_id INTO l_list_header_id;
   IF (c_list_header_id%NOTFOUND) THEN
      CLOSE c_list_header_id;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_list_header_id;

     -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

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

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Lock_listheader;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListHeader_rec
--
-- HISTORY
--    10/11/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE Init_ListHeader_Rec(
   x_listheader_rec  OUT NOCOPY  list_header_rec_type
)
IS
BEGIN

   x_listheader_rec.LIST_HEADER_ID         := FND_API.g_miss_num;
   x_listheader_rec.LAST_UPDATE_DATE       := FND_API.g_miss_date;
   x_listheader_rec.LAST_UPDATED_BY        := FND_API.g_miss_num;
   x_listheader_rec.CREATION_DATE          := FND_API.g_miss_date;
   x_listheader_rec.CREATED_BY             := FND_API.g_miss_num;
   x_listheader_rec.LAST_UPDATE_LOGIN      := FND_API.g_miss_num;
   x_listheader_rec.OBJECT_VERSION_NUMBER  := FND_API.g_miss_num;
   x_listheader_rec.REQUEST_ID             := FND_API.g_miss_num;
   x_listheader_rec.PROGRAM_ID             := FND_API.g_miss_num;
   x_listheader_rec.PROGRAM_APPLICATION_ID := FND_API.g_miss_num;
   x_listheader_rec.PROGRAM_UPDATE_DATE    := FND_API.g_miss_date;
   x_listheader_rec.VIEW_APPLICATION_ID    := FND_API.g_miss_num;
   x_listheader_rec.LIST_NAME              := FND_API.g_miss_char;
   x_listheader_rec.LIST_USED_BY_ID        := FND_API.g_miss_num;
   x_listheader_rec.ARC_LIST_USED_BY       := FND_API.g_miss_char;
   x_listheader_rec.LIST_TYPE              := FND_API.g_miss_char;
   x_listheader_rec.STATUS_CODE            := FND_API.g_miss_char;
   x_listheader_rec.STATUS_DATE            := FND_API.g_miss_date;
   x_listheader_rec.GENERATION_TYPE        := FND_API.g_miss_char;
   x_listheader_rec.ROW_SELECTION_TYPE     := FND_API.g_miss_char;
   x_listheader_rec.OWNER_USER_ID          := FND_API.g_miss_num;
   x_listheader_rec.ACCESS_LEVEL           := FND_API.g_miss_char;
   x_listheader_rec.ENABLE_LOG_FLAG        := FND_API.g_miss_char;
   x_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG   := FND_API.g_miss_char;
   x_listheader_rec.ENABLE_PARALLEL_DML_FLAG       := FND_API.g_miss_char;
   x_listheader_rec.DEDUPE_DURING_GENERATION_FLAG  := FND_API.g_miss_char;
   x_listheader_rec.GENERATE_CONTROL_GROUP_FLAG    := FND_API.g_miss_char;
   x_listheader_rec.LAST_GENERATION_SUCCESS_FLAG   := FND_API.g_miss_char;
   x_listheader_rec.FORECASTED_START_DATE  := FND_API.g_miss_date;
   x_listheader_rec.FORECASTED_END_DATE    := FND_API.g_miss_date;
   x_listheader_rec.ACTUAL_END_DATE        := FND_API.g_miss_date;
   x_listheader_rec.SENT_OUT_DATE          := FND_API.g_miss_date;
   x_listheader_rec.DEDUPE_START_DATE      := FND_API.g_miss_date;
   x_listheader_rec.LAST_DEDUPE_DATE       := FND_API.g_miss_date;
   x_listheader_rec.LAST_DEDUPED_BY_USER_ID  := FND_API.g_miss_num;
   x_listheader_rec.WORKFLOW_ITEM_KEY        := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_DUPLICATES    := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_MIN_REQUESTED := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_MAX_REQUESTED := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_IN_LIST       := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_IN_CTRL_GROUP := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_ACTIVE        := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_INACTIVE      := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_MANUALLY_ENTERED  := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_DO_NOT_CALL   := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL   := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_RANDOM        := FND_API.g_miss_num;
   x_listheader_rec.ORG_ID                   := FND_API.g_miss_num;
   x_listheader_rec.TIMEZONE_ID                 := FND_API.g_miss_num;
   x_listheader_rec.USER_ENTERED_START_TIME  := FND_API.g_miss_date;
   x_listheader_rec.MAIN_GEN_START_TIME      := FND_API.g_miss_date;
   x_listheader_rec.MAIN_GEN_END_TIME        := FND_API.g_miss_date;
   x_listheader_rec.MAIN_RANDOM_NTH_ROW_SELECTION  := FND_API.g_miss_num;
   x_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION  := FND_API.g_miss_num;
   x_listheader_rec.CTRL_RANDOM_NTH_ROW_SELECTION  := FND_API.g_miss_num;
   x_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION  := FND_API.g_miss_num;
   x_listheader_rec.REPEAT_SOURCE_LIST_HEADER_ID   := FND_API.g_miss_char;
   x_listheader_rec.RESULT_TEXT                    := FND_API.g_miss_char;
   x_listheader_rec.KEYWORDS                       := FND_API.g_miss_char;
   x_listheader_rec.DESCRIPTION                    := FND_API.g_miss_char;
   x_listheader_rec.LIST_PRIORITY                  := FND_API.g_miss_num;
   x_listheader_rec.ASSIGN_PERSON_ID               := FND_API.g_miss_num;
   x_listheader_rec.LIST_SOURCE                    := FND_API.g_miss_char;
   x_listheader_rec.LIST_SOURCE_TYPE               := FND_API.g_miss_char;
   x_listheader_rec.LIST_ONLINE_FLAG               := FND_API.g_miss_char;
   x_listheader_rec.RANDOM_LIST_ID                 := FND_API.g_miss_num;
   x_listheader_rec.ENABLED_FLAG                   := FND_API.g_miss_char;
   x_listheader_rec.ASSIGNED_TO                    := FND_API.g_miss_num;
   x_listheader_rec.QUERY_ID                       := FND_API.g_miss_num;
   x_listheader_rec.OWNER_PERSON_ID                := FND_API.g_miss_num;
   x_listheader_rec.ATTRIBUTE_CATEGORY := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE1         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE2         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE3         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE4         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE5         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE6         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE7         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE8         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE9         := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE10        := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE11        := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE12        := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE13        := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE14        := FND_API.g_miss_char;
   x_listheader_rec.ATTRIBUTE15        := FND_API.g_miss_char;
   x_listheader_rec.QUANTUM            := FND_API.g_miss_num;
   x_listheader_rec.RELEASE_CONTROL_ALG_ID :=FND_API.g_miss_num;
   x_listheader_rec.DIALING_METHOD     := FND_API.g_miss_char;
   x_listheader_rec.CALLING_CALENDAR_ID :=FND_API.g_miss_num;
   x_listheader_rec.release_strategy := FND_API.g_miss_char;
   x_listheader_rec.custom_setup_id  :=FND_API.g_miss_num;
   x_listheader_rec.country   :=FND_API.g_miss_num;
   x_listheader_rec.PURGE_FLAG    := FND_API.g_miss_char ;
   x_listheader_rec.PUBLIC_FLAG    := FND_API.g_miss_char ;
   x_listheader_rec.LIST_CATEGORY    := FND_API.g_miss_char ;
   x_listheader_rec.QUOTA             := FND_API.g_miss_num ;
   x_listheader_rec.QUOTA_RESET            := FND_API.g_miss_num ;
   x_listheader_rec.RECYCLING_ALG_ID       := FND_API.g_miss_num ;
   x_listheader_rec.CALLBACK_PRIORITY_FLAG  := FND_API.g_miss_char;
   x_listheader_rec.CALL_CENTER_READY_FLAG  := FND_API.g_miss_char;
   x_listheader_rec.USER_STATUS_ID     := FND_API.g_miss_num;
   x_listheader_rec.NO_OF_ROWS_prev_contacted  := FND_API.g_miss_num;
   x_listheader_rec.APPLY_TRAFFIC_COP  := FND_API.g_miss_char;

   -- ckapoor R12 copy target group enhancement

   x_listheader_rec.CTRL_CONF_LEVEL             := FND_API.g_miss_num ;
x_listheader_rec.CTRL_REQ_RESP_RATE            := FND_API.g_miss_num ;
x_listheader_rec.CTRL_LIMIT_OF_ERROR       := FND_API.g_miss_num ;
x_listheader_rec.STATUS_CODE_OLD  := FND_API.g_miss_char;
x_listheader_rec.CTRL_CONC_JOB_ID  := FND_API.g_miss_num;
x_listheader_rec.CTRL_STATUS_CODE     := FND_API.g_miss_char;
x_listheader_rec.CTRL_GEN_MODE  := FND_API.g_miss_char;
x_listheader_rec.APPLY_SUPPRESSION_FLAG  := FND_API.g_miss_char;

   -- end ckapoor

END Init_ListHeader_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListHeader_rec
--
-- HISTORY
--    10/11/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE Complete_ListHeader_rec(
   p_listheader_rec  IN  list_header_rec_type,
   x_complete_rec     OUT NOCOPY list_header_rec_type
)
IS

   CURSOR c_listheader IS
   SELECT *
   FROM   ams_list_headers_vl
   WHERE list_header_id = p_listheader_rec.list_header_id;

   l_listheader_rec  c_listheader%ROWTYPE;

BEGIN

   x_complete_rec := p_listheader_rec;
   OPEN c_listheader;
   FETCH c_listheader INTO l_listheader_rec;
   IF c_listheader%NOTFOUND THEN
      CLOSE c_listheader;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_listheader;


   IF p_listheader_rec.LIST_HEADER_ID   = FND_API.g_miss_num THEN
         x_complete_rec.LIST_HEADER_ID   := l_listheader_rec.LIST_HEADER_ID;
   END IF;
   IF p_listheader_rec.LAST_UPDATE_DATE = FND_API.g_miss_date THEN
         x_complete_rec.LAST_UPDATE_DATE := l_listheader_rec.LAST_UPDATE_DATE;
   END IF;
   IF p_listheader_rec.LAST_UPDATED_BY  = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATED_BY  := l_listheader_rec.LAST_UPDATED_BY;
   END IF;
   IF p_listheader_rec.CREATION_DATE    = FND_API.g_miss_date THEN
         x_complete_rec.CREATION_DATE    := l_listheader_rec.CREATION_DATE;
   END IF;
   IF p_listheader_rec.CREATED_BY       = FND_API.g_miss_num THEN
         x_complete_rec.CREATED_BY       := l_listheader_rec.CREATED_BY;
   END IF;
   IF p_listheader_rec.LAST_UPDATE_LOGIN = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATE_LOGIN := l_listheader_rec.LAST_UPDATE_LOGIN;
   END IF;
   IF p_listheader_rec.OBJECT_VERSION_NUMBER = FND_API.g_miss_num THEN
         x_complete_rec.OBJECT_VERSION_NUMBER := l_listheader_rec.OBJECT_VERSION_NUMBER ;
   END IF;
   IF p_listheader_rec.REQUEST_ID            = FND_API.g_miss_num THEN
         x_complete_rec.REQUEST_ID           := l_listheader_rec.REQUEST_ID;
   END IF;
   IF p_listheader_rec.PROGRAM_ID            = FND_API.g_miss_num THEN
         x_complete_rec.PROGRAM_ID           := l_listheader_rec.PROGRAM_ID ;
   END IF;
   IF p_listheader_rec.PROGRAM_APPLICATION_ID = FND_API.g_miss_num THEN
         x_complete_rec.PROGRAM_APPLICATION_ID := l_listheader_rec.PROGRAM_APPLICATION_ID;
   END IF;
   IF p_listheader_rec.PROGRAM_UPDATE_DATE    = FND_API.g_miss_date THEN
         x_complete_rec.PROGRAM_UPDATE_DATE := l_listheader_rec.PROGRAM_UPDATE_DATE;
   END IF;
   IF p_listheader_rec.VIEW_APPLICATION_ID    = FND_API.g_miss_num THEN
         x_complete_rec.VIEW_APPLICATION_ID   := l_listheader_rec.VIEW_APPLICATION_ID;
   END IF;

   IF p_listheader_rec.LIST_NAME              = FND_API.g_miss_char THEN
         x_complete_rec.LIST_NAME             := l_listheader_rec.LIST_NAME;
   END IF;
   IF p_listheader_rec.LIST_USED_BY_ID        = FND_API.g_miss_num THEN
         x_complete_rec.LIST_USED_BY_ID       := l_listheader_rec.LIST_USED_BY_ID ;
   END IF;
   IF p_listheader_rec.ARC_LIST_USED_BY       = FND_API.g_miss_char THEN
         x_complete_rec.ARC_LIST_USED_BY      := l_listheader_rec.ARC_LIST_USED_BY;
   END IF;
   IF p_listheader_rec.LIST_TYPE              = FND_API.g_miss_char THEN
         x_complete_rec.LIST_TYPE             := l_listheader_rec.LIST_TYPE;
   END IF;

   IF p_listheader_rec.STATUS_DATE            = FND_API.g_miss_date THEN
         x_complete_rec.STATUS_DATE           := l_listheader_rec.STATUS_DATE  ;
   END IF;
   IF p_listheader_rec.GENERATION_TYPE        = FND_API.g_miss_char THEN
         x_complete_rec.GENERATION_TYPE       := l_listheader_rec.GENERATION_TYPE;
   END IF;
   IF p_listheader_rec.ROW_SELECTION_TYPE     = FND_API.g_miss_char THEN
         x_complete_rec.ROW_SELECTION_TYPE    := l_listheader_rec.ROW_SELECTION_TYPE;
   END IF;
   IF p_listheader_rec.OWNER_USER_ID          = FND_API.g_miss_num THEN
   x_complete_rec.OWNER_USER_ID               := l_listheader_rec.OWNER_USER_ID;
   END IF;
   IF p_listheader_rec.ACCESS_LEVEL           = FND_API.g_miss_char THEN
   x_complete_rec.ACCESS_LEVEL                := l_listheader_rec.ACCESS_LEVEL;
   END IF;
   IF p_listheader_rec.ENABLE_LOG_FLAG        = FND_API.g_miss_char THEN
   x_complete_rec.ENABLE_LOG_FLAG             := l_listheader_rec.ENABLE_LOG_FLAG;
   END IF;
   IF p_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG   = FND_API.g_miss_char THEN
   x_complete_rec.ENABLE_WORD_REPLACEMENT_FLAG        := l_listheader_rec.ENABLE_WORD_REPLACEMENT_FLAG ;
   END IF;
   IF p_listheader_rec.ENABLE_PARALLEL_DML_FLAG       = FND_API.g_miss_char THEN
   x_complete_rec.ENABLE_PARALLEL_DML_FLAG            := l_listheader_rec.ENABLE_PARALLEL_DML_FLAG;
   END IF;
   IF p_listheader_rec.DEDUPE_DURING_GENERATION_FLAG  = FND_API.g_miss_char THEN
   x_complete_rec.DEDUPE_DURING_GENERATION_FLAG       := l_listheader_rec.DEDUPE_DURING_GENERATION_FLAG;
   END IF;
   IF p_listheader_rec.GENERATE_CONTROL_GROUP_FLAG    = FND_API.g_miss_char THEN
   x_complete_rec.GENERATE_CONTROL_GROUP_FLAG         := l_listheader_rec.GENERATE_CONTROL_GROUP_FLAG ;
   END IF;
   IF p_listheader_rec.LAST_GENERATION_SUCCESS_FLAG   = FND_API.g_miss_char THEN
   x_complete_rec.LAST_GENERATION_SUCCESS_FLAG        := l_listheader_rec.LAST_GENERATION_SUCCESS_FLAG;
   END IF;
   IF p_listheader_rec.FORECASTED_START_DATE  = FND_API.g_miss_date THEN
   x_complete_rec.FORECASTED_START_DATE       := l_listheader_rec.FORECASTED_START_DATE ;
   END IF;
   IF p_listheader_rec.FORECASTED_END_DATE    = FND_API.g_miss_date THEN
   x_complete_rec.FORECASTED_END_DATE         := l_listheader_rec.FORECASTED_END_DATE;
   END IF;
   IF p_listheader_rec.ACTUAL_END_DATE        = FND_API.g_miss_date THEN
   x_complete_rec.ACTUAL_END_DATE             := l_listheader_rec.ACTUAL_END_DATE;
   END IF;
   IF p_listheader_rec.SENT_OUT_DATE          = FND_API.g_miss_date THEN
   x_complete_rec.SENT_OUT_DATE               := l_listheader_rec.SENT_OUT_DATE;
   END IF;
   IF p_listheader_rec.DEDUPE_START_DATE      = FND_API.g_miss_date THEN
   x_complete_rec.DEDUPE_START_DATE           := l_listheader_rec.DEDUPE_START_DATE  ;
   END IF;
   IF p_listheader_rec.LAST_DEDUPE_DATE       = FND_API.g_miss_date THEN
   x_complete_rec.LAST_DEDUPE_DATE            := l_listheader_rec.LAST_DEDUPE_DATE;
   END IF;
   IF p_listheader_rec.LAST_DEDUPED_BY_USER_ID  = FND_API.g_miss_num THEN
   x_complete_rec.LAST_DEDUPED_BY_USER_ID       := l_listheader_rec.LAST_DEDUPED_BY_USER_ID  ;
   END IF;
   IF p_listheader_rec.WORKFLOW_ITEM_KEY        = FND_API.g_miss_num THEN
   x_complete_rec.WORKFLOW_ITEM_KEY             := l_listheader_rec.WORKFLOW_ITEM_KEY ;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_DUPLICATES    = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_DUPLICATES         := l_listheader_rec.NO_OF_ROWS_DUPLICATES;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_MIN_REQUESTED = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_MIN_REQUESTED      := l_listheader_rec.NO_OF_ROWS_MIN_REQUESTED;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_MAX_REQUESTED = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_MAX_REQUESTED      := l_listheader_rec.NO_OF_ROWS_MAX_REQUESTED ;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_IN_LIST       = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_IN_LIST            := l_listheader_rec.NO_OF_ROWS_IN_LIST;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_IN_CTRL_GROUP = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_IN_CTRL_GROUP      := l_listheader_rec.NO_OF_ROWS_IN_CTRL_GROUP;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_ACTIVE        = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_ACTIVE             := l_listheader_rec.NO_OF_ROWS_ACTIVE;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_INACTIVE      = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_INACTIVE           := l_listheader_rec.NO_OF_ROWS_INACTIVE;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_MANUALLY_ENTERED  = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_MANUALLY_ENTERED       := l_listheader_rec.NO_OF_ROWS_MANUALLY_ENTERED;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_DO_NOT_CALL   = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_DO_NOT_CALL        := l_listheader_rec.NO_OF_ROWS_DO_NOT_CALL ;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL   = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_DO_NOT_MAIL        := l_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL;
   END IF;
   IF p_listheader_rec.NO_OF_ROWS_RANDOM        = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_RANDOM             := l_listheader_rec.NO_OF_ROWS_RANDOM;
   END IF;
   IF p_listheader_rec.ORG_ID                   = FND_API.g_miss_num THEN
   x_complete_rec.ORG_ID                        := l_listheader_rec.ORG_ID;
   END IF;
   IF p_listheader_rec.TIMEZONE_ID              = FND_API.g_miss_num THEN
   x_complete_rec.TIMEZONE_ID                   := l_listheader_rec.TIMEZONE_ID;
   END IF;
   IF p_listheader_rec.USER_ENTERED_START_TIME   = FND_API.g_miss_date THEN
   x_complete_rec.USER_ENTERED_START_TIME       := l_listheader_rec.USER_ENTERED_START_TIME ;
   END IF;
   IF p_listheader_rec.MAIN_GEN_START_TIME      = FND_API.g_miss_date THEN
   x_complete_rec.MAIN_GEN_START_TIME           := l_listheader_rec.MAIN_GEN_START_TIME ;
   END IF;
   IF p_listheader_rec.MAIN_GEN_END_TIME        = FND_API.g_miss_date THEN
   x_complete_rec.MAIN_GEN_END_TIME             := l_listheader_rec.MAIN_GEN_END_TIME ;
   END IF;
   IF p_listheader_rec.MAIN_RANDOM_NTH_ROW_SELECTION  = FND_API.g_miss_num THEN
   x_complete_rec.MAIN_RANDOM_NTH_ROW_SELECTION       := l_listheader_rec.MAIN_RANDOM_NTH_ROW_SELECTION;
   END IF;
   IF p_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION  = FND_API.g_miss_num THEN
   x_complete_rec.MAIN_RANDOM_PCT_ROW_SELECTION       := l_listheader_rec.MAIN_RANDOM_PCT_ROW_SELECTION ;
   END IF;
   IF p_listheader_rec.CTRL_RANDOM_NTH_ROW_SELECTION  = FND_API.g_miss_num THEN
   x_complete_rec.CTRL_RANDOM_NTH_ROW_SELECTION       := l_listheader_rec.CTRL_RANDOM_NTH_ROW_SELECTION ;
   END IF;
   IF p_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION  = FND_API.g_miss_num THEN
   x_complete_rec.CTRL_RANDOM_PCT_ROW_SELECTION       := l_listheader_rec.CTRL_RANDOM_PCT_ROW_SELECTION ;
   END IF;
   IF p_listheader_rec.REPEAT_SOURCE_LIST_HEADER_ID   = FND_API.g_miss_char THEN
   x_complete_rec.REPEAT_SOURCE_LIST_HEADER_ID        := l_listheader_rec.REPEAT_SOURCE_LIST_HEADER_ID;
   END IF;
   IF p_listheader_rec.RESULT_TEXT                    = FND_API.g_miss_char THEN
   x_complete_rec.RESULT_TEXT                         := l_listheader_rec.RESULT_TEXT;
   END IF;
   IF p_listheader_rec.KEYWORDS                       = FND_API.g_miss_char THEN
   x_complete_rec.KEYWORDS                            := l_listheader_rec.KEYWORDS;
   END IF;
   IF p_listheader_rec.DESCRIPTION                    = FND_API.g_miss_char THEN
   x_complete_rec.DESCRIPTION                         := l_listheader_rec.DESCRIPTION  ;
   END IF;
   IF p_listheader_rec.LIST_PRIORITY                  = FND_API.g_miss_num THEN
   x_complete_rec.LIST_PRIORITY                       := l_listheader_rec.LIST_PRIORITY;
   END IF;
   IF p_listheader_rec.ASSIGN_PERSON_ID               = FND_API.g_miss_num THEN
   x_complete_rec.ASSIGN_PERSON_ID                    := l_listheader_rec.ASSIGN_PERSON_ID;
   END IF;
   IF p_listheader_rec.LIST_SOURCE                    = FND_API.g_miss_char THEN
   x_complete_rec.LIST_SOURCE                         := l_listheader_rec.LIST_SOURCE ;
   END IF;
   IF p_listheader_rec.LIST_SOURCE_TYPE               = FND_API.g_miss_char THEN
   x_complete_rec.LIST_SOURCE_TYPE                    := l_listheader_rec.LIST_SOURCE_TYPE;
   END IF;
   IF p_listheader_rec.LIST_ONLINE_FLAG               = FND_API.g_miss_char THEN
   x_complete_rec.LIST_ONLINE_FLAG                    := l_listheader_rec.LIST_ONLINE_FLAG;
   END IF;
   IF p_listheader_rec.RANDOM_LIST_ID                 = FND_API.g_miss_num THEN
   x_complete_rec.RANDOM_LIST_ID                      := l_listheader_rec.RANDOM_LIST_ID ;
   END IF;
   IF p_listheader_rec.ENABLED_FLAG                   = FND_API.g_miss_char THEN
   x_complete_rec.ENABLED_FLAG                        := l_listheader_rec.ENABLED_FLAG;
   END IF;
   IF p_listheader_rec.ASSIGNED_TO                    = FND_API.g_miss_num THEN
   x_complete_rec.ASSIGNED_TO                         := l_listheader_rec.ASSIGNED_TO ;
   END IF;
   IF p_listheader_rec.QUERY_ID                       = FND_API.g_miss_num THEN
   x_complete_rec.QUERY_ID                            := l_listheader_rec.QUERY_ID ;
   END IF;
   IF p_listheader_rec.OWNER_PERSON_ID                = FND_API.g_miss_num THEN
   x_complete_rec.OWNER_PERSON_ID                     := l_listheader_rec.OWNER_PERSON_ID;
   END IF;
   IF p_listheader_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE_CATEGORY      := l_listheader_rec.ATTRIBUTE_CATEGORY;
   END IF;
   IF p_listheader_rec.ATTRIBUTE1         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE1              := l_listheader_rec.ATTRIBUTE1 ;
   END IF;
   IF p_listheader_rec.ATTRIBUTE2         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE2              := l_listheader_rec.ATTRIBUTE2    ;
   END IF;
   IF p_listheader_rec.ATTRIBUTE3         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE3              := l_listheader_rec.ATTRIBUTE3;
   END IF;
   IF p_listheader_rec.ATTRIBUTE4         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE4              := l_listheader_rec.ATTRIBUTE4;
   END IF;
   IF p_listheader_rec.ATTRIBUTE5         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE5              := l_listheader_rec.ATTRIBUTE5 ;
   END IF;
   IF p_listheader_rec.ATTRIBUTE6         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE6              := l_listheader_rec.ATTRIBUTE6;
   END IF;
   IF p_listheader_rec.ATTRIBUTE7         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE7              := l_listheader_rec.ATTRIBUTE7 ;
   END IF;
   IF p_listheader_rec.ATTRIBUTE8         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE8              := l_listheader_rec.ATTRIBUTE8;
   END IF;
   IF p_listheader_rec.ATTRIBUTE9         = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE9              := l_listheader_rec.ATTRIBUTE9;
   END IF;
   IF p_listheader_rec.ATTRIBUTE10        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE10             := l_listheader_rec.ATTRIBUTE10;
   END IF;
   IF p_listheader_rec.ATTRIBUTE11        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE11             := l_listheader_rec.ATTRIBUTE11 ;
   END IF;
   IF p_listheader_rec.ATTRIBUTE12        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE12             := l_listheader_rec.ATTRIBUTE12;
   END IF;
   IF p_listheader_rec.ATTRIBUTE13        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE13             := l_listheader_rec.ATTRIBUTE13;
   END IF;
   IF p_listheader_rec.ATTRIBUTE14        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE14             := l_listheader_rec.ATTRIBUTE14;
   END IF;
   IF p_listheader_rec.ATTRIBUTE15        = FND_API.g_miss_char THEN
   x_complete_rec.ATTRIBUTE15             := l_listheader_rec.ATTRIBUTE15;
   END IF;
   IF p_listheader_rec.QUANTUM             = FND_API.g_miss_num THEN
      x_complete_rec.QUANTUM             := l_listheader_rec.QUANTUM ;
   END IF;
   IF p_listheader_rec.RELEASE_CONTROL_ALG_ID =FND_API.g_miss_num  THEN
      x_complete_rec.RELEASE_CONTROL_ALG_ID
						   := l_listheader_rec.RELEASE_CONTROL_ALG_ID ;
   END IF;
   IF p_listheader_rec.DIALING_METHOD     = FND_API.g_miss_char  THEN
      x_complete_rec.DIALING_METHOD     := l_listheader_rec.DIALING_METHOD ;
   END IF;
   IF p_listheader_rec.RELEASE_CONTROL_ALG_ID =FND_API.g_miss_num  THEN
      x_complete_rec.RELEASE_CONTROL_ALG_ID := l_listheader_rec.RELEASE_CONTROL_ALG_ID ;
   END IF;
   IF p_listheader_rec.CALLING_CALENDAR_ID =FND_API.g_miss_num  THEN
      x_complete_rec.CALLING_CALENDAR_ID := l_listheader_rec.CALLING_CALENDAR_ID ;
   END IF;
   IF p_listheader_rec.release_strategy   = FND_API.g_miss_char  THEN
      x_complete_rec.release_strategy     := l_listheader_rec.release_strategy ;
   END IF;
   IF p_listheader_rec.custom_setup_id =FND_API.g_miss_num  THEN
      x_complete_rec.custom_setup_id := l_listheader_rec.custom_setup_id ;
   END IF;
   IF p_listheader_rec.country =FND_API.g_miss_num  THEN
      x_complete_rec.country := l_listheader_rec.country ;
   END IF;
   IF p_listheader_rec.PURGE_FLAG    =FND_API.g_miss_char  THEN
      x_complete_rec.purge_flag := l_listheader_rec.purge_flag ;
   END IF;
   IF p_listheader_rec.PUBLIC_FLAG    =FND_API.g_miss_char  THEN
      x_complete_rec.PUBLIC_FLAG := l_listheader_rec.PUBLIC_FLAG ;
   END IF;
   IF p_listheader_rec.LIST_CATEGORY    =FND_API.g_miss_char  THEN
      x_complete_rec.LIST_CATEGORY := l_listheader_rec.LIST_CATEGORY ;
   END IF;
   IF p_listheader_rec.quota =FND_API.g_miss_num  THEN
      x_complete_rec.quota := l_listheader_rec.quota ;
   END IF;
   IF p_listheader_rec.quota_reset =FND_API.g_miss_num  THEN
      x_complete_rec.quota_reset := l_listheader_rec.quota_reset ;
   END IF;
   IF p_listheader_rec.recycling_alg_id =FND_API.g_miss_num  THEN
      x_complete_rec.recycling_alg_id := l_listheader_rec.recycling_alg_id ;
   END IF;
   IF p_listheader_rec.CALLBACK_PRIORITY_FLAG  = FND_API.g_miss_char  THEN
      x_complete_rec.CALLBACK_PRIORITY_FLAG  := l_listheader_rec.CALLBACK_PRIORITY_FLAG  ;
   END IF;
   IF p_listheader_rec.CALL_CENTER_READY_FLAG  = FND_API.g_miss_char  THEN
      x_complete_rec.CALL_CENTER_READY_FLAG  := l_listheader_rec.CALL_CENTER_READY_FLAG  ;
   END IF;
   IF p_listheader_rec.USER_STATUS_ID     = FND_API.g_miss_num  THEN
      x_complete_rec.USER_STATUS_ID     := l_listheader_rec.USER_STATUS_ID    ;
   END IF;

   IF p_listheader_rec.NO_OF_ROWS_prev_contacted  = FND_API.g_miss_num THEN
   x_complete_rec.NO_OF_ROWS_prev_contacted     := l_listheader_rec.NO_OF_ROWS_prev_contacted;
   END IF;

    IF p_listheader_rec.APPLY_TRAFFIC_COP  = FND_API.g_miss_char  THEN
      x_complete_rec.APPLY_TRAFFIC_COP  := l_listheader_rec.APPLY_TRAFFIC_COP  ;
   END IF;

   x_complete_rec.status_code := AMS_Utility_PVT.get_system_status_code(
	 x_complete_rec.user_status_id );


   -- ckapoor R12 copy target group changes

   IF p_listheader_rec.CTRL_CONF_LEVEL =FND_API.g_miss_num  THEN
      x_complete_rec.CTRL_CONF_LEVEL := l_listheader_rec.CTRL_CONF_LEVEL ;
   END IF;
   IF p_listheader_rec.CTRL_REQ_RESP_RATE =FND_API.g_miss_num  THEN
      x_complete_rec.CTRL_REQ_RESP_RATE := l_listheader_rec.CTRL_REQ_RESP_RATE ;
   END IF;
   IF p_listheader_rec.CTRL_LIMIT_OF_ERROR =FND_API.g_miss_num  THEN
      x_complete_rec.CTRL_LIMIT_OF_ERROR := l_listheader_rec.CTRL_LIMIT_OF_ERROR ;
   END IF;
   IF p_listheader_rec.STATUS_CODE_OLD  = FND_API.g_miss_char  THEN
      x_complete_rec.STATUS_CODE_OLD  := l_listheader_rec.STATUS_CODE_OLD  ;
   END IF;
   IF p_listheader_rec.CTRL_CONC_JOB_ID  = FND_API.g_miss_num  THEN
      x_complete_rec.CTRL_CONC_JOB_ID  := l_listheader_rec.CTRL_CONC_JOB_ID  ;
   END IF;
   IF p_listheader_rec.CTRL_STATUS_CODE     = FND_API.g_miss_char  THEN
      x_complete_rec.CTRL_STATUS_CODE     := l_listheader_rec.CTRL_STATUS_CODE    ;
   END IF;

   IF p_listheader_rec.CTRL_GEN_MODE  = FND_API.g_miss_char THEN
   x_complete_rec.CTRL_GEN_MODE     := l_listheader_rec.CTRL_GEN_MODE;
   END IF;

    IF p_listheader_rec.APPLY_SUPPRESSION_FLAG  = FND_API.g_miss_char  THEN
      x_complete_rec.APPLY_SUPPRESSION_FLAG  := l_listheader_rec.APPLY_SUPPRESSION_FLAG  ;
   END IF;


   -- end ckapoor R12 copy target group changes


-- dbms_output.put_line('end ofcomplete list header rec');
END Complete_ListHeader_rec;

PROCEDURE Update_list_header_count(
   p_list_header_id           IN  number,
   p_init_msg_list            IN    VARCHAR2   := FND_API.G_FALSE,
   p_commit                   IN    VARCHAR2   := FND_API.G_FALSE,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS
cursor c_count_list_entries(cur_p_list_header_id number) is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(part_of_control_group_flag,'Y',1,0)),
       sum(decode(marked_as_random_flag,'Y',1,0)),
       sum(decode(marked_as_duplicate_flag,'Y',1,0)),
       sum(decode(manually_entered_flag,
                     'Y',decode(enabled_flag,'Y','1',0),
                     0))
from ams_list_entries
where list_header_id = cur_p_list_header_id ;

l_no_of_rows_duplicates         number;
l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_manually_entered   number;
l_no_of_rows_in_ctrl_group      number;
l_no_of_rows_random             number;
l_min_rows                      number;
l_new_status                    varchar2(30);
l_new_status_id                 number;
--l_no_of_rows_prev_contacted   number;
BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  open c_count_list_entries(p_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_active            ,
        l_no_of_rows_inactive          ,
        l_no_of_rows_in_list           ,
        l_no_of_rows_in_ctrl_group     ,
        l_no_of_rows_random            ,
        l_no_of_rows_duplicates        ,
        l_no_of_rows_manually_entered  ;
  close c_count_list_entries;


 SELECT nvl(no_of_rows_min_requested,0)
 INTO   l_min_rows
 FROM   ams_list_headers_all
 WHERE  list_header_id = p_list_header_id;

 if l_min_rows > l_no_of_rows_active then
    l_new_status :=  'DRAFT';
    l_new_status_id   :=  300;
 else
    l_new_status :=  'AVAILABLE';
    l_new_status_id   :=  303;
 end if;
  update ams_list_headers_all
  set no_of_rows_in_list           = l_no_of_rows_in_list,
      no_of_rows_active            = l_no_of_rows_active,
      no_of_rows_inactive          = l_no_of_rows_inactive,
      no_of_rows_in_ctrl_group     = l_no_of_rows_in_ctrl_group,
      no_of_rows_random            = l_no_of_rows_random,
      no_of_rows_duplicates        = l_no_of_rows_duplicates,
      no_of_rows_manually_entered  = l_no_of_rows_manually_entered       ,
      last_generation_success_flag = decode(l_new_status_id,303,'Y','N'),
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate,
      last_update_date             = sysdate
  WHERE  list_header_id            = p_list_header_id;

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_LIST_HEADER_UPDATE: END');
     FND_MSG_PUB.Add;
  END IF;


       IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message('AMS_LIST_HEADER_UPDATE: END');
       END IF;


      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);


END;




---------------------------------------------------------------------
-- PROCEDURE
--    Update_Prev_contacted_count
--
-- PURPOSE
--    aDDED TO SUPPORT TRIGGER BACKPORT FUNCTIONALITY
--    Gived a schedule id / one off event id or event header id and the last contacted date
--    update all list entries of the related target group or invite list ,
--	who were not contacted earlier, with the last contacted date
--	also populate list header with total number of records with last contacted date populated
-- PARAMETERS
--    p_used_by:  eg CSCH/EVEO/EVEH
--    p_used_by  : Schedule Id/ or One off Event Id or Event Header Id
--    p_last_contacted_date :last contacted date to be populated in to the list entries table
---------------------------------------------------------------------


PROCEDURE Update_Prev_contacted_count(
   p_used_by_id			IN  number,
   p_used_by			IN  VARCHAR2,
   p_last_contacted_date	IN  DATE,
   p_init_msg_list            IN    VARCHAR2   := FND_API.G_FALSE,
   p_commit                   IN    VARCHAR2   := FND_API.G_FALSE,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2
)

IS

cursor c_get_list_header_id(cur_p_used_by varchar2,cur_p_used_by_id number) is
select list_header_id
from ams_act_lists
where LIST_USED_BY_ID = cur_p_used_by_id
 and LIST_USED_BY = cur_p_used_by
 and LIST_ACT_TYPE ='TARGET';



cursor c_count_list_entries(cur_p_list_header_id number) is
select count(LAST_CONTACTED_DATE)
from ams_list_entries
where list_header_id = cur_p_list_header_id
 and enabled_flag = 'Y'
 and LAST_CONTACTED_DATE is not null;

l_no_of_rows_prev_contacted   number;
l_list_header_id  number;

BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;


  open c_get_list_header_id(p_used_by,p_used_by_id);
  fetch c_get_list_header_id
   into l_list_header_id  ;
  close c_get_list_header_id;

--only update entries which have not been updated already
  update ams_list_entries
  set LAST_CONTACTED_DATE           = p_last_contacted_date,
      last_update_date             = sysdate
  WHERE  list_header_id            = l_list_header_id
  and enabled_flag = 'Y'
  and LAST_CONTACTED_DATE is null;


    open c_count_list_entries(l_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_prev_contacted ;
  close c_count_list_entries;


  update ams_list_headers_all
  set no_of_rows_prev_contacted  = l_no_of_rows_prev_contacted,
  last_update_date               = sysdate
  WHERE  list_header_id          = l_list_header_id;




  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;


 IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_LIST_HEADER_UPDATE: END');
     FND_MSG_PUB.Add;
  END IF;



      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);


END;








-- Start of Comments
--
-- NAME
--   Copy_List
--
-- PURPOSE
--   This procedure creates a list header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments
PROCEDURE Copy_List
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level      IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_source_listheader_id        IN     NUMBER,
  p_listheader_rec        IN     list_header_rec_type,
  p_copy_select_actions   IN     VARCHAR2  := 'Y',
  p_copy_list_queries     IN     VARCHAR2  := 'Y',
  p_copy_list_entries     IN     VARCHAR2  := 'Y',

  x_listheader_id         OUT NOCOPY    NUMBER
)  IS

l_api_name            CONSTANT VARCHAR2(30)  := 'Copy_List';
l_api_version         CONSTANT NUMBER        := 1.0;
-- Status Local Variables
l_return_status                VARCHAR2(1);  -- Return value from procedures

l_listheader_id                number;

x_rowid VARCHAR2(30);

l_sqlerrm varchar2(600);
l_sqlcode varchar2(100);

/*
CURSOR fetch_list_details (list_id NUMBER) IS
SELECT * FROM ams_list_headers_vl
WHERE list_header_id = list_id ;
l_reference_rec             fetch_list_details%ROWTYPE;
*/

l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;

l_new_listheader_rec           list_header_rec_type := p_listheader_rec;
l_trg_listheader_rec           list_header_rec_type;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Copy_Lists_PVT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeaders_PVT.Copy_Lists: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF; */

      IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message('AMS_ListHeader_PVT.Copy_List: Start');
   END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


 l_new_listheader_rec.list_header_id:= p_source_listheader_id;
  ----------------------------------------------------------
   -- replace g_miss_char/num/date with current column values
   ----------------------------------------------------------

   complete_listheader_rec(l_new_listheader_rec, l_trg_listheader_rec);


   --    Null fields
   l_trg_listheader_rec.list_header_id := FND_API.g_miss_num;

   l_trg_listheader_rec.request_id                 := NULL;
   l_trg_listheader_rec.program_id                 := NULL;
   l_trg_listheader_rec.program_application_id     := NULL;
   l_trg_listheader_rec.program_update_date        := NULL;


   l_trg_listheader_rec.user_status_id           := AMS_Utility_PVT.get_default_user_status('AMS_LIST_STATUS','AVAILABLE');
   l_trg_listheader_rec.status_code              := 'AVAILABLE';
   l_trg_listheader_rec.status_date              := SYSDATE;

   -- ----------------------------
   -- call create api
   -- ----------------------------
    Create_ListHeader( p_api_version=>l_api_version,
       p_init_msg_list=>l_init_msg_list,
       p_commit=>p_commit,
       p_validation_level=>p_validation_level,
       x_return_status=> x_return_status,
       x_msg_count=>x_msg_count,
       x_msg_data=> x_msg_data,
       p_listheader_rec => l_trg_listheader_rec,
       x_listheader_id => l_listheader_id );


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- set OUT value
   x_listheader_id := l_listheader_id;

  /* IF p_copy_select_actions = 'Y' THEN
    -- call api to copy select actions
   END IF;
*/
   IF p_copy_list_queries = 'Y' THEN
    -- call api to copy list queries
    AMS_List_Query_PVT.Copy_List_Queries
  (  l_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_source_listheader_id,
      l_listheader_id,
      l_trg_listheader_rec.list_name,
      x_return_status,
      x_msg_count,
      x_msg_data
 );

   END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   IF p_copy_list_entries = 'Y' THEN
    -- call api to copy list entries
     AMS_List_Entries_PVT.Copy_List_Entries
(
      l_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_listheader_id,
      l_listheader_id
);

   END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Copy_Lists', TRUE);
            FND_MSG_PUB.Add;
      END IF;

    /* ckapoor   IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Copy_Lists: END', TRUE);
            FND_MSG_PUB.Add;
      END IF; */


      -- Standard call to get message count AND IF count is 1, get message info.
      FND_MSG_PUB.Count_AND_Get
          ( p_count        =>      x_msg_count,
            p_data         =>      x_msg_data,
            p_encoded      =>        FND_API.G_FALSE
          );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Copy_Lists_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
           );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_Lists_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      ( p_count      =>      x_msg_count,
        p_data       =>      x_msg_data,
        p_encoded    =>      FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_Lists_PVT;
      FND_MESSAGE.set_name('AMS','SQL ERROR ->' || sqlerrm );
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

END Copy_List;

END AMS_listheader_PVT;

/
