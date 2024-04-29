--------------------------------------------------------
--  DDL for Package Body AMS_APPROVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVERS_PVT" AS
/* $Header: amsvaprb.pls 120.0 2005/05/31 20:24:52 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_APPROVERS_PVT
--
--
-- PURPOSE
--    This package is a Private API for managing Approvers
--    in AMS.  It contains specification for pl/sql records and tables
--
--    AMS_APPROVERS:
--    Create_approver (see below for specification)
--    Update_approver (see below for specification)
--    Delete_approver (see below for specification)
--    Lock_approver (see below for specification)
--    Validate_approver (see below for specification)
--
--    Check_Approvers_Items (see below for specification)
--    Check_Approvers_Record (see below for specification)
--    Init_Approvers_Rec
--    Complete_Approvers_Rec
--
-- NOTES
--
--
-- HISTORY
-- 24-OCT-2000    mukumar      Created.
-- 09-APR-2002    vmodur       Fix for Bug 2285556
--                             Approver Dates were being validated even
--                             when only the approver sequence was being changed
-- 12-SEP-2002    vmodur       Changed l_meaning from Varchar2(30) to Varchar2(80)
--                             for bug 2544992
-- 29-APR-2003    vmodur       Bug 2898250 added check_func_use_valid
-- 14-NOV-2003    vmodur       Bug 2677401 prevent addition or role with more than 1 user
-- 22-NOV-2004    vmodur       Bug 3979814 Fix in 11.5.11
-- 24-MAR-2005    vmodur       SQL Repository Fixes
-----------------------------------------------------------

-- Global CONSTANTS
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_APPROVERS_PVT';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION compare_columns(
   p_approvers_rec   IN  Approvers_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

FUNCTION seed_needs_update(
   p_approvers_rec   IN  Approvers_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

--       Check_Approvers_Req_Items
PROCEDURE Check_Approvers_Req_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approvers_UK_Items
PROCEDURE Check_Approvers_UK_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   p_validation_mode     IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approvers_FK_Items
PROCEDURE Check_Approvers_FK_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approvers_Lkup_Items
PROCEDURE Check_Approvers_Lkup_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);

--       Check_Approvers_Flag_Items
PROCEDURE Check_Approvers_Flag_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);

--      Check Aprrover  Dates
PROCEDURE Check_Dates_Create_Range (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Dates_Update_Range (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Func_Use_Valid(
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
);
--------------------------------------------------------------------
-- PROCEDURE
--    Create_Approvers
--
-- PURPOSE
--    Create Approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVER .
--    x_approver_id: the approver_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If approver_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec   IN  Approvers_Rec_Type,
   x_approver_id    OUT NOCOPY NUMBER
)
IS

   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Create_Approvers';
   L_FULL_NAME    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_approvers_rec   Approvers_Rec_Type := p_approvers_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_row_id             VARCHAR2(40);

   CURSOR c_seq IS
     SELECT ams_approvers_s.NEXTVAL
     FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
     SELECT 1 FROM   dual
       WHERE EXISTS (SELECT 1 FROM   ams_approvers
                   WHERE  approver_id = x_id);
BEGIN
   --------------------- initialize -----------------------
    SAVEPOINT Create_Approvers;
    IF (AMS_DEBUG_HIGH_ON) THEN

    Ams_Utility_Pvt.debug_message (l_full_name || ': Start');
    END IF;
   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
       L_API_VERSION,
       p_api_version,
       L_API_NAME,
       G_PKG_NAME
     ) THEN
       RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;
  ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Validate');
   END IF;
     Validate_approvers (
        p_api_version       =>  L_API_VERSION,
        p_init_msg_list     =>  p_init_msg_list,
        p_commit            =>  p_commit,
        p_validation_level  =>  p_validation_level,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_approvers_rec   =>  l_approvers_rec
     );
     IF l_return_status = Fnd_Api.g_ret_sts_error THEN
       RAISE Fnd_Api.g_exc_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
       RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;
     --
     -- Check for the ID.
     --
    IF l_approvers_rec.approver_id IS NULL THEN
      LOOP
      --
      -- If the ID is not passed into the API, then
      -- grab a value from the sequence.
        OPEN c_seq;
        FETCH c_seq INTO l_approvers_rec.approver_id;
        CLOSE c_seq;
      --
      -- Check to be sure that the sequence does not exist.
        OPEN c_id_exists (l_approvers_rec.approver_id);
        FETCH c_id_exists INTO l_dummy;
        CLOSE c_id_exists;
      --
      -- If the value for the ID already exists, then
      -- l_dummy would be populated with '1', otherwise,
      -- it receives NULL.

        EXIT WHEN l_dummy IS NULL;
     END LOOP;
   END IF;
  -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Insert');
   END IF;
   --
   -- Insert into mutli-language supported table.
   --
   Ams_Approvers_Pkg.INSERT_ROW (
       X_ROWID  => l_row_id,
       X_APPROVER_ID => l_approvers_rec.approver_id,
       X_SEEDED_FLAG => NVL(l_approvers_rec.SEEDED_FLAG, 'N'),
       X_ACTIVE_FLAG => NVL(l_approvers_rec.ACTIVE_FLAG, 'Y'),
       X_START_DATE_ACTIVE => l_approvers_rec.START_DATE_ACTIVE,
       X_END_DATE_ACTIVE => l_approvers_rec.END_DATE_ACTIVE,
       X_OBJECT_VERSION_NUMBER => 1, --l_approvers_rec.l_obj_verno,
       --X_SECURITY_GROUP_ID => l_approvers_rec.SECURITY_GROUP_ID,
       X_AMS_APPROVAL_DETAIL_ID => l_approvers_rec.AMS_APPROVAL_DETAIL_ID,
       X_APPROVER_SEQ => l_approvers_rec.APPROVER_SEQ,
       X_APPROVER_TYPE => l_approvers_rec.APPROVER_TYPE,
       X_OBJECT_APPROVER_ID => l_approvers_rec.OBJECT_APPROVER_ID,
       X_NOTIFICATION_TYPE => l_approvers_rec.NOTIFICATION_TYPE,
       X_NOTIFICATION_TIMEOUT => l_approvers_rec.NOTIFICATION_TYPE,
       X_CREATION_DATE => SYSDATE,
       X_CREATED_BY => Fnd_Global.User_Id,
       X_LAST_UPDATE_DATE => SYSDATE,
       X_LAST_UPDATED_BY => Fnd_Global.User_Id,
       X_LAST_UPDATE_LOGIN => Fnd_Global.Conc_Login_Id
      ) ;
   -- set OUT value
     x_approver_id := l_approvers_rec.approver_id;
     --
     -- END of API body.
     --
     -- Standard check of p_commit.
     IF Fnd_Api.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
     END IF;
   Fnd_Msg_Pub.count_and_get(
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': End');
   END IF;


EXCEPTION
    WHEN Fnd_Api.g_exc_error THEN
       ROLLBACK TO Create_Approvers;
       x_return_status := Fnd_Api.g_ret_sts_error;
       Fnd_Msg_Pub.count_and_get(
        p_encoded => Fnd_Api.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
       );
    WHEN Fnd_Api.g_exc_unexpected_error THEN
       ROLLBACK TO Create_Approvers;
       x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
       Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
       );
    WHEN OTHERS THEN
     ROLLBACK TO Create_Approvers;
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
     THEN
        Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     Fnd_Msg_Pub.count_and_get (
       p_encoded => Fnd_Api.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
     );
END Create_approvers;
   --------------------------------------------------------------------
-- PROCEDURE
--    Update_approvers
--
-- PURPOSE
--    Update an approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVERS (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec   IN  Approvers_Rec_Type
)
IS

   L_API_VERSION   CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Approvers';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_approvers_rec   Approvers_Rec_Type := p_approvers_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

BEGIN
     --------------------- initialize -----------------------
    SAVEPOINT Update_approvers;
    IF (AMS_DEBUG_HIGH_ON) THEN

    Ams_Utility_Pvt.debug_message (l_full_name || ': Start');
    END IF;
    IF Fnd_Api.to_boolean (p_init_msg_list) THEN
       Fnd_Msg_Pub.initialize;
    END IF;
    IF NOT Fnd_Api.compatible_api_call(
       l_api_version,
       p_api_version,
       l_api_name,
       g_pkg_name
     ) THEN
       RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
    x_return_status := Fnd_Api.g_ret_sts_success;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Validate');
   END IF;
   -- replace g_miss_char/num/date with current column values
   Complete_approvers_Rec(p_approvers_rec,l_approvers_rec);
   IF l_approvers_rec.seeded_flag = 'Y' THEN
     IF compare_columns(l_approvers_rec) = Fnd_Api.g_false THEN
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AMS', 'AMS_STATUS_SEED_DATA');
         Fnd_Msg_Pub.ADD;
       END IF;
       RAISE Fnd_Api.g_exc_error;
     END IF;
   ELSE
    IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
       Check_approvers_Items (
        p_approvers_rec  => l_approvers_rec ,
          p_validation_mode =>  Jtf_Plsql_Api.g_update,
        x_return_status   => l_return_status
       );
       IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
       ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
       END IF;
    END IF;


   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_record THEN
       Check_approvers_Record (
           p_approvers_rec => l_approvers_rec,
           p_complete_rec  =>  l_approvers_rec,
           x_return_status => l_return_status
         );
         IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
         ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
         END IF;
      END IF;
   END IF; -- check for seeded flag
   -- Check to see if the row is seeded if the row is seeded then can't update
   -- modified.. enabled flag for seeded rows can be updated.. added seed_needs_   -- update function
   IF l_approvers_rec.seeded_flag='N'
       OR seed_needs_update(l_approvers_rec) = Fnd_Api.g_true
    THEN
   -------------------------- update --------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message (l_full_name || ': Update');
      END IF;
    Ams_Approvers_Pkg.UPDATE_ROW(
         X_APPROVER_ID => l_approvers_rec.approver_id,
         X_SEEDED_FLAG => l_approvers_rec.SEEDED_FLAG,
       X_ACTIVE_FLAG => l_approvers_rec.ACTIVE_FLAG,
         X_START_DATE_ACTIVE => l_approvers_rec.START_DATE_ACTIVE,
         X_END_DATE_ACTIVE => l_approvers_rec.END_DATE_ACTIVE,
         X_OBJECT_VERSION_NUMBER => l_approvers_rec.OBJECT_VERSION_NUMBER+1,
         --X_SECURITY_GROUP_ID => l_approvers_rec.SECURITY_GROUP_ID,
         X_AMS_APPROVAL_DETAIL_ID => l_approvers_rec.AMS_APPROVAL_DETAIL_ID,
         X_APPROVER_SEQ => l_approvers_rec.APPROVER_SEQ,
         X_APPROVER_TYPE => l_approvers_rec.APPROVER_TYPE,
         X_OBJECT_APPROVER_ID => l_approvers_rec.OBJECT_APPROVER_ID,
         X_NOTIFICATION_TYPE => l_approvers_rec.NOTIFICATION_TYPE,
         X_NOTIFICATION_TIMEOUT => l_approvers_rec.NOTIFICATION_TIMEOUT,
         X_LAST_UPDATE_DATE => SYSDATE,
         X_LAST_UPDATED_BY => Fnd_Global.User_Id,
         X_LAST_UPDATE_LOGIN => Fnd_Global.Conc_Login_Id
        );
   END IF;-- ending if loop for second seeded_flag check
   -------------------- finish --------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;
   Fnd_Msg_Pub.count_and_get (
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': End');
   END IF;


EXCEPTION
  WHEN Fnd_Api.g_exc_error THEN
     ROLLBACK TO Update_approvers;
     x_return_status := Fnd_Api.g_ret_sts_error;
     Fnd_Msg_Pub.count_and_get (
       p_encoded => Fnd_Api.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );

  WHEN Fnd_Api.g_exc_unexpected_error THEN
     ROLLBACK TO Update_approvers;
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.count_and_get (
       p_encoded => Fnd_Api.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );

  WHEN OTHERS THEN
     ROLLBACK TO Update_approvers;
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
     THEN
        Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     Fnd_Msg_Pub.count_and_get (
        p_encoded => Fnd_Api.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );
END Update_approvers;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_approvers
--
-- PURPOSE
--    Delete a approvers entry.
--
-- PARAMETERS
--    p_approver_id: the approver_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approver_id          IN  NUMBER,
   p_object_version    IN  NUMBER
) IS

   CURSOR c_approvers IS
   SELECT   *
   FROM  ams_approvers
   WHERE approver_id = p_approver_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.

   l_approvers_rec    c_approvers%ROWTYPE;
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Approvers';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN

   OPEN c_approvers;
   FETCH c_approvers INTO l_approvers_rec;
   IF c_approvers%NOTFOUND THEN
      CLOSE c_approvers;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
        Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
        Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_approvers;
    --------------------- initialize -----------------------
    SAVEPOINT Delete_approvers;
    IF (AMS_DEBUG_HIGH_ON) THEN

    Ams_Utility_Pvt.debug_message (l_full_name || ': Start');
    END IF;
    IF Fnd_Api.to_boolean (p_init_msg_list) THEN
       Fnd_Msg_Pub.initialize;
    END IF;
    IF NOT Fnd_Api.compatible_api_call (
       l_api_version,
       p_api_version,
       l_api_name,
       g_pkg_name
    ) THEN
       RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
    x_return_status := Fnd_Api.g_ret_sts_success;

    ------------------------ delete ------------------------
    IF (AMS_DEBUG_HIGH_ON) THEN

    Ams_Utility_Pvt.debug_message (l_full_name || ': Delete');
    END IF;
    -- Delete TL data
    IF l_approvers_rec.seeded_flag='N'
    THEN
       Ams_Approvers_Pkg.DELETE_ROW (p_approver_id);
    ELSE
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name ('AMS', 'AMS_API_SEED_DATA');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.g_exc_error;
       END IF;
    END IF;
    -------------------- finish --------------------------
    IF Fnd_Api.to_boolean (p_commit) THEN
       COMMIT;
    END IF;
    Fnd_Msg_Pub.count_and_get (
       p_encoded => Fnd_Api.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
    );
    IF (AMS_DEBUG_HIGH_ON) THEN

    Ams_Utility_Pvt.debug_message (l_full_name || ': End');
    END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
     ROLLBACK TO Delete_approvers;
     x_return_status := Fnd_Api.g_ret_sts_error;
     Fnd_Msg_Pub.count_and_get (
     p_encoded => Fnd_Api.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data
     );

   WHEN Fnd_Api.g_exc_unexpected_error THEN
     ROLLBACK TO Delete_approvers;
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.count_and_get (
        p_encoded => Fnd_Api.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );

   WHEN OTHERS THEN
   ROLLBACK TO Delete_approvers;
   x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
   IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
   THEN
      Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
   END IF;
   Fnd_Msg_Pub.count_and_get (
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
END Delete_approvers;

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_approvers
--
-- PURPOSE
--    Lock a approval entry.
--
-- PARAMETERS
--    p_approver_id: the approvers
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approver_id          IN  NUMBER,
   p_object_version    IN  NUMBER
) IS
BEGIN
   NULL;
END;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_approvers
--
-- PURPOSE
--    Validate a approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVERS (without ROW_ID).
--
-- NOTES
--    1. p_approvers_rec should be the complete approvers record.
--       There should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec         IN  Approvers_Rec_Type
) IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_approvers';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_return_status   VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Start');
   END IF;
   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Check items');
   END IF;
   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
         Check_Approvers_Items (
         p_approvers_rec => p_approvers_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': Check record');
   END IF;
   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_record THEN
      Check_Approvers_Record (
         p_approvers_rec => p_approvers_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;




   -------------------- finish --------------------------
   Fnd_Msg_Pub.count_and_get (
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message (l_full_name || ': End');
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
   x_return_status := Fnd_Api.g_ret_sts_error;
   Fnd_Msg_Pub.count_and_get (
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
   x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
   Fnd_Msg_Pub.count_and_get (
   p_encoded => Fnd_Api.g_false,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   WHEN OTHERS THEN
   x_return_status := Fnd_Api.g_ret_sts_unexp_error;
   IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
   THEN
   Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
   END IF;
   Fnd_Msg_Pub.count_and_get (
   p_encoded => Fnd_Api.g_false,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );

END Validate_approvers;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approvers_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_approvers_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_approvers_Items (
   p_approvers_rec       IN  Approvers_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
) IS
BEGIN
   --
   -- Validate required items.
   Check_approvers_Req_Items (
      p_approvers_rec       => p_approvers_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
   -- Validate uniqueness.
   Check_approvers_UK_Items (
      p_approvers_rec          => p_approvers_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_approvers_FK_Items(
      p_approvers_rec       => p_approvers_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_approvers_Lkup_Items (
      p_approvers_rec          => p_approvers_rec,
      x_return_status      => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_approvers_Flag_Items(
      p_approvers_rec       => p_approvers_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (p_approvers_rec.start_date_active > p_approvers_rec.end_date_active) THEN
     --dbms_output.put_line('st > ed ');
     IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
        Fnd_Message.set_name('AMS', 'AMS_APPR_DTL_SD_BFR_ED');
        Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;
END Check_approvers_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approvers_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_approvers_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_approvers_Record (
   p_approvers_rec        IN  Approvers_Rec_Type,
   p_complete_rec     IN  Approvers_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
) IS
     l_start_date_active      DATE;
   l_end_date_active        DATE;
BEGIN
   --
   -- Use local vars to reduce amount of typing.
   IF p_complete_rec.start_date_active IS NOT NULL THEN
      l_start_date_active := p_complete_rec.start_date_active;
   ELSE
      IF p_approvers_rec.start_date_active IS NOT NULL AND
         p_approvers_rec.start_date_active <> Fnd_Api.g_miss_date THEN
          l_start_date_active := p_approvers_rec.start_date_active;
      END IF;
   END IF;
   IF p_complete_rec.end_date_active IS NOT NULL THEN
       l_end_date_active := p_complete_rec.end_date_active;
   ELSE
      IF p_approvers_rec.end_date_active IS NOT NULL AND
         p_approvers_rec.end_date_active <> Fnd_Api.g_miss_date THEN
          l_end_date_active := p_approvers_rec.end_date_active;
      END IF;
   END IF;
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF l_start_date_active IS NOT NULL AND l_end_date_active IS NOT NULL THEN
     IF l_start_date_active > l_end_date_active THEN
        IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
           Fnd_Message.set_name ('AMS', 'AMS_APPR_APRVR_SD_BFR_ED');
           Fnd_Msg_Pub.ADD;
        END IF;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;
END Check_approvers_Record;
---------------------------------------------------------------------
-- PROCEDURE
--    Init_approvers_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_approvers_Rec (
   x_approvers_rec         OUT NOCOPY  Approvers_Rec_Type
) IS
BEGIN
      x_approvers_rec.approver_id := Fnd_Api.g_miss_num;
      x_approvers_rec.start_date_active := Fnd_Api.g_miss_date;
      x_approvers_rec.end_date_active := Fnd_Api.g_miss_date;
      x_approvers_rec.object_version_number := Fnd_Api.g_miss_num;
      --x_approvers_rec.security_group_id := Fnd_Api.g_miss_num;
      x_approvers_rec.ams_approval_detail_id := Fnd_Api.g_miss_num;
      x_approvers_rec.approver_seq := Fnd_Api.g_miss_num;
      x_approvers_rec.approver_type := Fnd_Api.g_miss_char;
      x_approvers_rec.object_approver_id := Fnd_Api.g_miss_num;
      x_approvers_rec.notification_type := Fnd_Api.g_miss_char;
      x_approvers_rec.notification_timeout := Fnd_Api.g_miss_num;
      x_approvers_rec.seeded_flag := Fnd_Api.g_miss_char;
END;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_approvers_Rec
--
-- PURPOSE
--    For Update_approvers, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--    change g_miss to null VM 12-29-2002
-- PARAMETERS
--    p_approvers_rec: the record which may contain attributes as
--       null
--    x_complete_rec: the complete record after all null items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_approvers_Rec (
   p_approvers_rec      IN  Approvers_Rec_Type,
   x_complete_rec   OUT NOCOPY Approvers_Rec_Type
) IS
   CURSOR c_approvers IS
   SELECT   *
   FROM     ams_approvers
   WHERE    approver_id = p_approvers_rec.approver_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_approvers_rec    c_approvers%ROWTYPE;
BEGIN
   x_complete_rec := p_approvers_rec;
   OPEN c_approvers;
   FETCH c_approvers INTO l_approvers_rec;
   IF c_approvers%NOTFOUND THEN
      CLOSE c_approvers;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_approvers;
   --
      IF p_approvers_rec.approver_id is null THEN
         x_complete_rec.approver_id := l_approvers_rec.approver_id;
      END IF;
/*
      -- Don't replace null date with date from db
      IF p_approvers_rec.start_date_active is null THEN
         x_complete_rec.start_date_active := l_approvers_rec.start_date_active;
      END IF;

      IF p_approvers_rec.end_date_active is null THEN
         x_complete_rec.end_date_active := l_approvers_rec.end_date_active;
      END IF;
*/
      IF p_approvers_rec.object_version_number is null THEN
         x_complete_rec.object_version_number := l_approvers_rec.object_version_number;
      END IF;

     /* IF p_approvers_rec.security_group_id is null THEN
         x_complete_rec.security_group_id := l_approvers_rec.security_group_id;
      END IF;
      */

      IF p_approvers_rec.ams_approval_detail_id is null THEN
         x_complete_rec.ams_approval_detail_id := l_approvers_rec.ams_approval_detail_id;
      END IF;

      IF p_approvers_rec.approver_seq is null THEN
         x_complete_rec.approver_seq := l_approvers_rec.approver_seq;
      END IF;

      IF p_approvers_rec.approver_type is null THEN
         x_complete_rec.approver_type := l_approvers_rec.approver_type;
      END IF;

      IF p_approvers_rec.object_approver_id is null THEN
         x_complete_rec.object_approver_id := l_approvers_rec.object_approver_id;
      END IF;

      IF p_approvers_rec.notification_type is null THEN
         x_complete_rec.notification_type := l_approvers_rec.notification_type;
      END IF;

      IF p_approvers_rec.notification_timeout is null THEN
         x_complete_rec.notification_timeout := l_approvers_rec.notification_timeout;
      END IF;

      IF p_approvers_rec.seeded_flag is null THEN
         x_complete_rec.seeded_flag := l_approvers_rec.seeded_flag;
      END IF;

      IF p_approvers_rec.active_flag is null THEN
         x_complete_rec.active_flag := l_approvers_rec.active_flag;
      END IF;

END Complete_approvers_Rec;

---------------------------------------------------------
--  Function Compare Columns
-- added sugupta 05/22/2000
-- this procedure will compare that no values have been modified for seeded statuses
-----------------------------------------------------------------
FUNCTION compare_columns(
   p_approvers_rec         IN  Approvers_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
IF (AMS_DEBUG_HIGH_ON) THEN

Ams_Utility_Pvt.DEBUG_MESSAGE('sTART DATE:'|| TO_CHAR( p_approvers_rec.start_date_active,'DD_MON_YYYY'));
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

Ams_Utility_Pvt.DEBUG_MESSAGE('end DATE:'|| TO_CHAR( p_approvers_rec.end_Date_active,'DD-MON-YYYY'));
END IF;

   IF p_approvers_rec.start_date_active IS NOT NULL THEN
        IF p_approvers_rec.end_Date_active IS NOT NULL THEN
           BEGIN
           SELECT 1 INTO l_count
         FROM AMS_APPROVERS
         WHERE approver_id =p_approvers_rec.approver_id
         AND start_date_active = p_approvers_rec.start_date_active
         AND end_date_active = p_approvers_rec.end_Date_active
         --AND security_group_id = p_approvers_rec.security_group_id
         AND ams_approval_detail_id = p_approvers_rec.ams_approval_detail_id
         AND approver_seq = p_approvers_rec.approver_seq
         AND approver_type = p_approvers_rec.approver_type
         AND object_approver_id = p_approvers_rec.object_approver_id
         AND notification_type = p_approvers_rec.notification_type
         AND notification_timeout = p_approvers_rec.notification_timeout
             AND seeded_flag = 'Y';
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         l_count := 0;
         END;
      ELSE -- for end date
      BEGIN
         SELECT 1 INTO l_count
         FROM AMS_APPROVERS
         WHERE approver_id =p_approvers_rec.approver_id
         AND start_date_active = p_approvers_rec.start_date_active
         AND end_date_active = p_approvers_rec.end_Date_active
         --AND security_group_id = p_approvers_rec.security_group_id
         AND ams_approval_detail_id = p_approvers_rec.ams_approval_detail_id
         AND approver_seq = p_approvers_rec.approver_seq
         AND approver_type = p_approvers_rec.approver_type
         AND object_approver_id = p_approvers_rec.object_approver_id
         AND notification_type = p_approvers_rec.notification_type
         AND notification_timeout = p_approvers_rec.notification_timeout
         AND seeded_flag = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         l_count := 0;
      END;
      END IF; -- for end date
   ELSE
      BEGIN
         SELECT 1 INTO l_count
       FROM AMS_APPROVERS
       WHERE approver_id =p_approvers_rec.approver_id
       AND start_date_active = p_approvers_rec.start_date_active
       AND end_date_active = p_approvers_rec.end_Date_active
       --AND security_group_id = p_approvers_rec.security_group_id
       AND ams_approval_detail_id = p_approvers_rec.ams_approval_detail_id
       AND approver_seq = p_approvers_rec.approver_seq
       AND approver_type = p_approvers_rec.approver_type
       AND object_approver_id = p_approvers_rec.object_approver_id
       AND notification_type = p_approvers_rec.notification_type
       AND notification_timeout = p_approvers_rec.notification_timeout
       AND seeded_flag = 'Y';
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_count := 0;
      END;
   END IF;
     IF l_count = 0 THEN
        RETURN Fnd_Api.g_false;
     ELSE
        RETURN Fnd_Api.g_true;
     END IF;
END compare_columns;

---------------------------------------------------------
--  Function seed_needs_update
-- added sugupta 05/22/2000
-- this procedure will look at enabled flag and determine if update is needed
-----------------------------------------------------------------
FUNCTION seed_needs_update(
   p_approvers_rec         IN  Approvers_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
   BEGIN
   SELECT 1 INTO l_count
   FROM AMS_APPROVERS
   WHERE approver_id = p_approvers_rec.approver_id
   AND   seeded_flag = 'Y';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN Fnd_Api.g_true;  -- needs update
   ELSE
      RETURN Fnd_Api.g_false;  -- doesnt need update
   END IF;
END seed_needs_update;

-------------------------------------------------------------
--       Check_Approvers_Req_Items
-------------------------------------------------------------
PROCEDURE Check_Approvers_Req_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
) IS
   l_start_date  DATE;
   l_end_date    DATE;
   CURSOR get_parent_date (id_in IN NUMBER)IS
   SELECT START_DATE_ACTIVE, END_DATE_ACTIVE
   FROM AMS_APPROVAL_DETAILS
   WHERE APPROVAL_DETAIL_ID = id_in;

BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    IF p_approvers_rec.ams_approval_detail_id = NULL
    OR p_approvers_rec.ams_approval_detail_id = Fnd_Api.g_miss_num
    THEN
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AMS', 'AMS_NO_APPROVAL_DETAIL_ID');
         Fnd_Msg_Pub.ADD;
       END IF;
       x_return_status := Fnd_Api.g_ret_sts_error;
       RETURN;
    END IF;
    --check for valid date range murali
    OPEN get_parent_date(p_approvers_rec.ams_approval_detail_id);
    FETCH get_parent_date INTO l_start_date, l_end_date;
    CLOSE get_parent_date;
   IF (p_approvers_rec.START_DATE_ACTIVE IS NOT NULL
       AND p_approvers_rec.START_DATE_ACTIVE <> Fnd_Api.g_miss_date)
   THEN
      IF p_approvers_rec.START_DATE_ACTIVE < l_start_date THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_SD_LT_APD_SD');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_approvers_rec.START_DATE_ACTIVE > l_end_date THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_SD_LT_APD_ED');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   IF (p_approvers_rec.END_DATE_ACTIVE IS NOT NULL
       OR p_approvers_rec.END_DATE_ACTIVE <> Fnd_Api.g_miss_date)
   THEN
      IF p_approvers_rec.END_DATE_ACTIVE < l_start_date THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_ED_LT_APD_SD');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_approvers_rec.END_DATE_ACTIVE > l_end_date THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_ED_LT_APD_ED');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END;
-------------------------------------------------------------
--       Check_Approvers_UK_Items
-------------------------------------------------------------
PROCEDURE Check_Approvers_UK_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   p_validation_mode     IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
   l_dummy NUMBER;
   CURSOR c_appr_seq_exists(seq_num_in IN NUMBER, id_in IN NUMBER) IS
      SELECT 1 FROM   dual
      WHERE EXISTS (SELECT 1 FROM   ams_approvers
            WHERE  approver_seq = seq_num_in
            AND ams_approval_detail_id = id_in
            AND active_flag = 'Y'
            );
BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF p_validation_mode = Jtf_Plsql_Api.g_create
      THEN
      OPEN c_appr_seq_exists (p_approvers_rec.approver_seq,
                 p_approvers_rec.ams_approval_detail_id
                 );
      FETCH  c_appr_seq_exists INTO l_dummy;
      CLOSE  c_appr_seq_exists;
      IF l_dummy = 1 THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_DUP_SEQ');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
          END IF;
      END IF;
   END IF;


   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
      Check_Dates_Create_Range (
            p_approvers_rec => p_approvers_rec,
            x_return_status      => x_return_status
         );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
      END IF;
   ELSIF (p_validation_mode = Jtf_Plsql_Api.g_update
         AND (p_approvers_rec.active_flag = 'Y' OR
              p_approvers_rec.active_flag = NULL OR p_approvers_rec.active_flag = Fnd_Api.g_miss_char)) THEN
      Check_Dates_Update_Range (
            p_approvers_rec => p_approvers_rec,
            x_return_status  => x_return_status
            );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

END Check_Approvers_UK_Items;
-------------------------------------------------------------
--       Check_Approvers_FK_Items
-------------------------------------------------------------
PROCEDURE Check_Approvers_FK_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
   l_dummy NUMBER;
   CURSOR c_uappr_id_exists(id_in IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM ams_jtf_rs_emp_v
            WHERE  RESOURCE_ID = id_in);
   CURSOR c_rappr_id_exists(id_in IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS ( SELECT 1
                     FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
                     WHERE rr.role_id = rl.role_id
                     AND rr.role_resource_type = 'RS_INDIVIDUAL'
                     AND rr.delete_flag = 'N'
                     AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
                     AND rl.role_type_code in ( 'MKTGAPPR', 'AMSAPPR')
                     AND rr.role_id = id_in);
      -- Replaced for SQL Repository Fix
      /*
      SELECT 1 FROM JTF_RS_DEFRESROLES_vl
            WHERE  ROLE_ID = id_in);
      */
   CURSOR c_multi_appr_exists(id_in IN NUMBER) IS
      SELECT COUNT(1)
      FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
      WHERE rr.role_id = rl.role_id
      AND rr.role_resource_type = 'RS_INDIVIDUAL'
      AND rr.delete_flag = 'N'
      AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
      AND rl.role_type_code in ( 'MKTGAPPR', 'AMSAPPR')
      AND rr.role_id = id_in;

 -- Replaced for SQL Repository Fix
      /*
        FROM jtf_rs_defresroles_vl
       WHERE role_type_code IN ('MKTGAPPR','AMSAPPR')
         AND role_id   = id_in
         AND role_resource_type = 'RS_INDIVIDUAL'
         AND delete_flag = 'N'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(res_rl_start_date)
         AND TRUNC(NVL(res_rl_end_date,SYSDATE));
      */
BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   Ams_Utility_Pvt.debug_message('The approver type is ' || p_approvers_rec.approver_type);

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('The object_approver_id  is ' || p_approvers_rec.object_approver_id);
   END IF;

   IF p_approvers_rec.approver_type = 'USER' THEN
      OPEN c_uappr_id_exists (p_approvers_rec.object_approver_id);
      FETCH  c_uappr_id_exists INTO l_dummy;
      CLOSE  c_uappr_id_exists;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('The l_dummy   is ' || l_dummy);
      END IF;

      IF l_dummy <> 1 THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_NO_RESORS');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   ELSIF p_approvers_rec.approver_type = 'ROLE' THEN
        IF (AMS_DEBUG_HIGH_ON) THEN

        Ams_Utility_Pvt.debug_message('The approver type is ' || p_approvers_rec.approver_type);
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        Ams_Utility_Pvt.debug_message('The object_approver_id  is ' || p_approvers_rec.object_approver_id);
        END IF;


      OPEN c_rappr_id_exists (p_approvers_rec.object_approver_id);
      FETCH c_rappr_id_exists INTO l_dummy;
      CLOSE c_rappr_id_exists;
      IF l_dummy <> 1 THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_NO_RESORS');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      -- Added as part of Bug 2677401
      OPEN c_multi_appr_exists(p_approvers_rec.object_approver_id);
      FETCH c_multi_appr_exists INTO l_dummy;
      CLOSE c_multi_appr_exists;
      IF l_dummy > 1 THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.set_name('AMS', 'AMS_MANY_DEFAULT_ROLE');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

   ELSIF p_approvers_rec.approver_type = 'FUNCTION' THEN
        Check_Func_Use_Valid(p_approvers_rec => p_approvers_rec,
	                     x_return_status => x_return_status);
   END IF;
END Check_Approvers_FK_Items;
-------------------------------------------------------------
--       Check_Approvers_Lkup_Items
-------------------------------------------------------------
PROCEDURE Check_Approvers_Lkup_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
  -- Changed from varchar2(30) for bug 2544992
  l_meaning               VARCHAR2(80);
BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF p_approvers_rec.approver_type <> Fnd_Api.g_miss_char THEN
      Ams_Utility_Pvt.get_lookup_meaning( 'AMS_APPROVER_TYPE',
         p_approvers_rec.approver_type,
         x_return_status,
         l_meaning
      );
      IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
            Fnd_Message.set_name('AMS', 'AMS_APPR_NO_APPR_TYPE');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;
END Check_Approvers_Lkup_Items;

-------------------------------------------------------------
--       Check_Approvers_Flag_Items
-------------------------------------------------------------
PROCEDURE Check_Approvers_Flag_Items (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
BEGIN
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
END Check_Approvers_Flag_Items;
--------------------------------------------------------------------


-------------------------------------------------------------
--       Check_Dates_Create_Range
-------------------------------------------------------------
PROCEDURE Check_Dates_Create_Range (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
p_start_date DATE := p_approvers_rec.start_date_active;
p_end_date DATE := p_approvers_rec.end_date_active;
l_start_date DATE;
l_end_date DATE;


CURSOR c_approval_rule IS
       SELECT start_date_active , end_date_active FROM ams_approval_details
              WHERE approval_detail_id = p_approvers_rec.ams_approval_detail_id;

BEGIN

   OPEN c_approval_rule;
   FETCH c_approval_rule INTO l_start_date,l_end_date;
   CLOSE c_approval_rule;


   IF (p_start_date IS NULL AND p_end_date IS NOT NULL) THEN
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       IF (AMS_DEBUG_HIGH_ON) THEN

       Ams_Utility_Pvt.debug_message('Approver end date cannot be specified without start date');
       END IF;

       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_NO_START_DATE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
       END IF;

       RETURN;
   END IF;

   IF (p_start_date IS NOT NULL) THEN
      IF(p_start_date < trunc(SYSDATE)) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver start date cannot be less than the system date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_START_DATE_LT_SYSDATE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      ELSIF ( p_start_date < l_start_date ) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver Start Date cannot be less than the Approval Rule Start Date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_STDT_GT_APRD_STDT');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      END IF;
   END IF;

   IF (p_end_date IS NOT NULL ) THEN
      IF( p_end_date < trunc(SYSDATE)) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver end date cannot be less than the system date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_END_DATE_LT_SYSDATE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      ELSIF (p_end_date > l_end_date) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver end date cannot be greater than the Approval Rule end date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_EDDT_GT_APRD_EDDT');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      END IF;
   END IF;


END Check_Dates_Create_Range;
--------------------------------------------------------------------

-------------------------------------------------------------
--       Check_Dates_Update_Range
-------------------------------------------------------------
PROCEDURE Check_Dates_Update_Range (
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
p_start_date DATE := p_approvers_rec.start_date_active;
p_end_date DATE := p_approvers_rec.end_date_active;
l_start_date DATE;
l_end_date DATE;
l_start_date_ar DATE;
l_end_date_ar DATE;


CURSOR c_approval_rule IS
       SELECT start_date_active , end_date_active FROM ams_approval_details
              WHERE approval_detail_id = p_approvers_rec.ams_approval_detail_id;

CURSOR c_approver IS
       SELECT start_date_active , end_date_active FROM ams_approvers
              WHERE approver_id = p_approvers_rec.approver_id;

BEGIN

   OPEN c_approval_rule;
   FETCH c_approval_rule INTO l_start_date,l_end_date;
   CLOSE c_approval_rule;


   OPEN c_approver;
   FETCH c_approver INTO l_start_date_ar,l_end_date_ar;
   CLOSE c_approver;

-- Check whether Approver has a End Date without a Start Date
   IF (p_start_date IS NULL AND p_end_date IS NOT NULL) THEN
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       IF (AMS_DEBUG_HIGH_ON) THEN

       Ams_Utility_Pvt.debug_message('Approver End Date cannot be specified without Start Date');
       END IF;

       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_NO_START_DATE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
       END IF;

       RETURN;
   END IF;

   -- Check whether the approver start date has been changed and if it is less than current date
   IF (p_start_date IS NOT NULL) THEN
      IF(l_start_date_ar < trunc(SYSDATE) AND
         l_start_date_ar <> p_start_date) THEN -- Clause added for Bug 2285556
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver start date cannot be changed as it is already active');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_STDT_NO_CHANGE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;

      -- Check whether approver start date is less than approval rule start date
      ELSIF ( p_start_date < l_start_date ) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver start date cannot be less than the Approval Rule start date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_STDT_LT_APRD_STDT');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      END IF;
   END IF;

   -- Check whether the approver end date has been changed and if it is less than current date
   IF (p_end_date IS NOT NULL ) THEN
      IF( p_end_date < trunc(SYSDATE) AND
          p_end_date <> l_end_date_ar) THEN -- Clause Added for Bug 2285556
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver end date cannot be less than the system date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_END_DATE_LT_SYSDATE');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;

      -- Check whether approver end date is greater than approval rule end date
      ELSIF (p_end_date > l_end_date) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Approver end date cannot be greater than the Approval Rule end date');
         END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_EDDT_GT_APRD_EDDT');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

         RETURN;
      END IF;
   /* Commented OUT NOCOPY the hanging elsif during fix for 2285556
   -- Approval Rule End date overrides the approver end date and hence this is not required
   ELSIF(l_end_date IS NOT NULL) THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        IF (AMS_DEBUG_HIGH_ON) THEN

        Ams_Utility_Pvt.debug_message('Approver end date cannot be open as the end date for Approval Rule is Closed');
        END IF;

         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APPR_EDDT_OPEN');
              Fnd_Msg_Pub.ADD;
              x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;

        RETURN;
   */
   END IF;


END Check_Dates_Update_Range;
--------------------------------------------------------------------
PROCEDURE Check_Func_Use_Valid(
   p_approvers_rec   IN  Approvers_Rec_Type,
   x_return_status  OUT NOCOPY   VARCHAR2
) IS

l_approval_object   VARCHAR2(30);
l_approval_type     VARCHAR2(30);
l_seeded_flag       VARCHAR2(1);
l_package_name      VARCHAR2(80);
l_proc_name         VARCHAR2(80);

CURSOR c_approval_rule IS
       SELECT approval_object, approval_type
       FROM ams_approval_details
       WHERE approval_detail_id = p_approvers_rec.ams_approval_detail_id;

CURSOR c_obj_rule IS
       SELECT seeded_flag, package_name, procedure_name
       FROM ams_object_rules_vl
       WHERE object_rule_id = p_approvers_rec.object_approver_id;

BEGIN
x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

OPEN c_approval_rule;
FETCH c_approval_rule INTO l_approval_object, l_approval_type;
CLOSE c_approval_rule;

OPEN c_obj_rule;
FETCH c_obj_rule INTO l_seeded_flag, l_package_name, l_proc_name;
CLOSE c_obj_rule;

IF l_seeded_flag = 'Y' THEN
-- Check Validity of use only for Seeded Functions

  IF l_approval_object NOT IN ('CAMP','EVEH','EVEO','CSCH','DELV','EONE')
  AND l_package_name = 'AMS_APPROVAL_UTIL_PVT'
  AND l_proc_name = 'GET_OBJECT_OWNER' THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('Invalid Use of Function for this objects Approval');
      END IF;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.set_name('AMS', 'AMS_APPR_FUNC_INVALID');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

    RETURN;
  END IF;

  IF l_approval_object NOT IN ('CSCH', 'EVEO', 'OFFR')
  AND l_package_name = 'AMS_APPROVAL_UTIL_PVT'
  AND l_proc_name = 'GET_PARENT_OBJECT_OWNER' THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('Invalid Use of Function for this objects Approval');
      END IF;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.set_name('AMS', 'AMS_APPR_FUNC_INVALID');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

    RETURN;
  END IF;

  IF l_approval_object IN ('CSCH', 'EVEO')
  AND l_package_name = 'AMS_APPROVAL_UTIL_PVT'
  AND l_proc_name = 'GET_PARENT_OBJECT_OWNER' THEN

    IF NVL(Fnd_Profile.Value(name => 'AMS_SOURCE_FROM_PARENT'), 'N') = 'N' THEN
      Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('Invalid Use of Function for this objects Approval as SFP is NO');
      END IF;
      RETURN;
    END IF;

  END IF;

  IF l_approval_object NOT IN ('FUND', 'FREQ')
  AND l_package_name = 'AMS_APPROVAL_UTIL_PVT'
  AND l_proc_name = 'GET_BUDGET_OWNER' THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('Invalid Use of Function for this objects Approval');
      END IF;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.set_name('AMS', 'AMS_APPR_FUNC_INVALID');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

    RETURN;
  END IF;

  IF l_approval_object NOT IN ('FREQ') -- RFRQ not right Bug 3979814
  AND l_package_name = 'AMS_APPROVAL_UTIL_PVT'
  AND l_proc_name = 'GET_PARENT_BUDGET_OWNER' THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('Invalid Use of Function for this objects Approval');
      END IF;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
         Fnd_Message.set_name('AMS', 'AMS_APPR_FUNC_INVALID');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

    RETURN;
  END IF;

END IF;

END Check_Func_Use_Valid;

END Ams_Approvers_Pvt;

/
