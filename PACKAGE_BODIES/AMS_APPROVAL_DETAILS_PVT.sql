--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_DETAILS_PVT" AS
/* $Header: amsvapdb.pls 120.2 2005/12/28 00:14:47 vmodur noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_APPROVAL_DETAILS_PVT
--
-- PURPOSE
--    This package is a Private API for managing Approval details
--    in AMS.  It contains specification for pl/sql records and tables
--
--    AMS_APPROVAL_DETAILS_VL:
--    Create_Approval_Details (see below for specification)
--    Update_Approval_Details (see below for specification)
--    Delete_Approval_Details (see below for specification)
--    Lock_Approval_Details (see below for specification)
--    Validate_Approval_Details (see below for specification)
--
--    Check_Approval_Details_Items (see below for specification)
--    Check_Approval_Details_Record (see below for specification)
--    Init_Approval_Details_Rec
--    Complete_Approval_Details_Rec
--
-- NOTES
--
--
-- HISTORY
-- 19-OCT-2000    mukumar      Created.
-- 08-JAN-2001    MUKUMAR      In validation for lookup type
--                             AMS_FUND_SOURCE replaced with
--                             AMS_APPEOVAL_RULE_FOR.
-- 26-DEC-2001    SVEERAVE     Replaced logic in Check_Approval_Dtls_UK_Items
--                             to fix bug# 2155701
-- 05-FEB-2002    VMODUR       Change Check_Unique_Rule from a function to a
--                             procedure to also return the name of overlapping
--                             rule for bug# 2195020. Token is used to display
--                             this rule name in the jsp
-- 30-APR-2002    VMODUR       Country Code is now an integral part of Approval Rule
--                             Validation Enh 1578624
-- 09-MAY-2002    VMODUR       Fix for Bug 2340052 - Overlapping Rules
--                             Currency Code is also used to determine uniqueness
--                             and overlapping
-- 20-JUN-2002    VMODUR       Bug 2195020 - Fix for Budget and Concept Approval Rule Overlap
--                             to return the name of the overlapping rule. Function
--                             Check_Approval_Amounts_Overlap was changed to a procedure and
--                             new proc get_Approval_Rule_Name added
-- 24-Jul-2002    VMODUR       Fix for Bug 2474782 - Allow Negative Amounts For Claims
--                             and call check_approval_details_items during update also
-- 12-Sep-2002    VMODUR       l_meaning changed from Varchar2(30) to Varchar2(80) for MLS Bug
-- 31-Jan-2003    VMODUR       Bug 2776795 Fix
-- 29-Jul-2003    VMODUR       Bug 3068835 fix from 11.5.9 Cert
-- 13-Sep-2003    VMODUR       11.5.10 Changes for LITE CSCH - No Budget Min Amt null Validation
-- 30-Oct-2003    VMODUR       11.5.10 Amount Overlap Changes
-- 01-DEC-2003    VMODUR       Bug 3275739 Fix
-- 12-MAY-2004    VMODUR       Perf Repository Fix. Use _VL instead of _V
-- 12-JUL-2004    VMODUR       Bug 3737174 Fix
-- 04-OCT-2004    VMODUR       Bug 3871802 Fix in 11.5.11
-- 14-SEP-2005    VMODUR       R12 Changes - No LITE/PHAT distinction for CSCH
-----------------------------------------------------------

-- Global CONSTANTS
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_Approval_Details_PVT';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION compare_columns(
   p_approval_details_rec   IN  Approval_Details_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

FUNCTION seed_needs_update(
   p_approval_details_rec   IN  Approval_Details_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

--       Check_Approval_Dtls_Req_Items
PROCEDURE Check_Approval_Dtls_Req_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approval_Dtls_UK_Items
PROCEDURE Check_Approval_Dtls_UK_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_validation_mode     IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approval_Dtls_FK_Items
PROCEDURE Check_Approval_Dtls_FK_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);
--       Check_Approval_Dtls_Lkup_Items
PROCEDURE Check_Approval_Dtls_Lkup_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);

--       Check_Approval_Dtls_Flag_Items
PROCEDURE Check_Approval_Dtls_Flag_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Approval_Amounts_Overlap (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_appoval_ids            IN  t_approval_id_table,
   x_exist_rule_name        OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2
);

FUNCTION Check_Dates_Overlap (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_validation_mode IN VARCHAR2
) RETURN VARCHAR2;   -- FND_API.g_true/g_false


PROCEDURE Check_Unique_Rule (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_exist_rule_name        OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2 -- FND_API.g_true/g_false
);

PROCEDURE Get_Approval_Rule_Name(
   p_approval_detail_id     IN  NUMBER,
   x_rule_name              OUT NOCOPY VARCHAR2)
IS
l_rule_name  VARCHAR2(240);
BEGIN
SELECT name
INTO l_rule_name
FROM ams_approval_details_v
where approval_detail_id = p_approval_detail_id;
x_rule_name := l_rule_name;
END;

FUNCTION Is_Usage_Lite(
   p_custom_setup_id   IN  NUMBER
   ) RETURN VARCHAR2 -- FND_API.g_true/g_false
IS
l_usage VARCHAR2(30);
BEGIN
SELECT usage
INTO l_usage
FROM ams_custom_setups_b
WHERE custom_setup_id = p_custom_setup_id;

IF l_usage = 'LITE' THEN
   return FND_API.g_true;
ELSE
   return FND_API.g_false;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  return FND_API.g_false;
END;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Approval_Details
--
-- PURPOSE
--    Create Approval Details entry.
--
-- PARAMETERS
--    p_approval_detail_rec: the record representing AMS_APPROVAL_DETAILS_VL view..
--    x_approval_detail_id: the approval_detail_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If approval_detail_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_approval_details_rec  IN  Approval_Details_Rec_Type,
   x_approval_detail_id    OUT NOCOPY NUMBER
)
IS

   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Create_Approval_Details';
   L_FULL_NAME    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_Approval_Details_rec   Approval_Details_Rec_Type := p_approval_details_rec;
   l_exist_rule_name    AMS_APPROVAL_DETAILS_V.Name%TYPE;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_row_id             VARCHAR2(40);

   CURSOR c_seq IS
     SELECT ams_approval_details_s.NEXTVAL
     FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
     SELECT 1 FROM   dual
       WHERE EXISTS (SELECT 1 FROM   ams_approval_details
                   WHERE  approval_detail_id = x_id);
BEGIN
   --------------------- initialize -----------------------
    SAVEPOINT Create_Approval_Details;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message (l_full_name || ': Start');
    END IF;
        IF FND_API.to_boolean (p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
        END IF;
        IF NOT FND_API.compatible_api_call (
            L_API_VERSION,
            p_api_version,
            L_API_NAME,
            G_PKG_NAME
          ) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;
        x_return_status := FND_API.g_ret_sts_success;


  ----------------Similar Rule Already Exists Or Not ---------------------------

   Check_Unique_Rule(p_approval_details_rec => l_Approval_Details_rec,
                     x_exist_rule_name      => l_exist_rule_name,
                     x_return_status        => l_return_status);
   IF l_return_status = FND_API.g_true THEN
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_APPR_RULE_EXISTS');
         FND_MESSAGE.set_token('EXIST_RULE_NAME', l_exist_rule_name);
         FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

  ----------------------- validate -----------------------
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
        END IF;
     Validate_approval_details (
        p_api_version       =>  L_API_VERSION,
        p_init_msg_list     =>  p_init_msg_list,
        p_commit            =>  p_commit,
        p_validation_level  =>  p_validation_level,
        x_return_status     =>  l_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data,
        p_approval_details_rec   =>  l_Approval_Details_rec
     );
     IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
     END IF;
     --
     -- Check for the ID.
     --
    IF l_Approval_Details_rec.approval_detail_id IS NULL THEN
      LOOP
      --
      -- If the ID is not passed into the API, then
      -- grab a value from the sequence.
        OPEN c_seq;
        FETCH c_seq INTO l_Approval_Details_rec.approval_detail_id;
        CLOSE c_seq;
      --
      -- Check to be sure that the sequence does not exist.
        OPEN c_id_exists (l_Approval_Details_rec.approval_detail_id);
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

   AMS_Utility_PVT.debug_message (l_full_name || ': Insert');
   END IF;
   --
   -- Insert into mutli-language supported table.
   --
   AMS_APPROVAL_DETAILS_PKG.INSERT_ROW (
      X_ROWID => l_row_id,
      X_APPROVAL_DETAIL_ID => l_Approval_Details_rec.APPROVAL_DETAIL_ID,
      X_START_DATE_ACTIVE => l_Approval_Details_rec.START_DATE_ACTIVE,
      X_END_DATE_ACTIVE => l_Approval_Details_rec.END_DATE_ACTIVE,
      X_OBJECT_VERSION_NUMBER => 1, --l_Approval_Details_rec.OBJECT_VERSION_NUMBER,
      --X_SECURITY_GROUP_ID => l_Approval_Details_rec.SECURITY_GROUP_ID,
      X_BUSINESS_GROUP_ID => l_Approval_Details_rec.BUSINESS_GROUP_ID,
      X_BUSINESS_UNIT_ID => l_Approval_Details_rec.BUSINESS_UNIT_ID,
      X_ORGANIZATION_ID => l_Approval_Details_rec.ORGANIZATION_ID,
      X_CUSTOM_SETUP_ID => l_Approval_Details_rec.CUSTOM_SETUP_ID,
      X_APPROVAL_OBJECT => l_Approval_Details_rec.APPROVAL_OBJECT,
      X_APPROVAL_OBJECT_TYPE => l_Approval_Details_rec.APPROVAL_OBJECT_TYPE,
      X_APPROVAL_TYPE => l_Approval_Details_rec.APPROVAL_TYPE,
      X_APPROVAL_PRIORITY => l_Approval_Details_rec.APPROVAL_PRIORITY,
      X_APPROVAL_LIMIT_TO => l_Approval_Details_rec.APPROVAL_LIMIT_TO,
      X_APPROVAL_LIMIT_FROM => l_Approval_Details_rec.APPROVAL_LIMIT_FROM,
      X_SEEDED_FLAG => nvl(l_Approval_Details_rec.SEEDED_FLAG, 'N'),
      X_ACTIVE_FLAG => nvl(l_Approval_Details_rec.ACTIVE_FLAG, 'Y'),
      X_CURRENCY_CODE => l_Approval_Details_rec.CURRENCY_CODE,
      X_USER_COUNTRY_CODE => l_Approval_Details_rec.USER_COUNTRY_CODE,
      X_NAME => l_Approval_Details_rec.NAME,
      X_DESCRIPTION => l_Approval_Details_rec.DESCRIPTION,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => FND_GLOBAL.User_Id,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.Conc_Login_Id
      ) ;
        -- set OUT value
     x_approval_detail_id := l_Approval_Details_rec.APPROVAL_DETAIL_ID;
     --
     -- END of API body.
     --
     -- Standard check of p_commit.
     IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
     END IF;
        FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
           );
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message (l_full_name || ': End');
        END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
       ROLLBACK TO Create_Approval_Details;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
       );
    WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO Create_Approval_Details;
       x_return_status := FND_API.g_ret_sts_unexp_error ;
       FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
       );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Approval_Details;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );
END Create_approval_details;
   --------------------------------------------------------------------
-- PROCEDURE
--    Update_approval_details
--
-- PURPOSE
--    Update an approval details entry.
--
-- PARAMETERS
--    p_approval_details_rec: the record representing AMS_APPROVAL_DETAILS_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_details_rec   IN  Approval_Details_Rec_Type
)
IS

   L_API_VERSION   CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Approval_Details';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_Approval_Details_rec   Approval_Details_Rec_Type := p_approval_details_rec;
   l_exist_rule_name    AMS_APPROVAL_DETAILS_V.Name%TYPE;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

      CURSOR c_rec_exists (x_id IN NUMBER, ver IN NUMBER) IS
                SELECT 1 FROM   ams_approval_details
                   WHERE  approval_detail_id = x_id
                     AND object_version_number = ver;

BEGIN
     --------------------- initialize -----------------------
    SAVEPOINT Update_approval_details;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message (l_full_name || ': Start');
    END IF;
    IF FND_API.to_boolean (p_init_msg_list) THEN
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
    x_return_status := FND_API.g_ret_sts_success;


     ----------------Similar Rule Already Exists Or Not ---------------------------
   Check_Unique_Rule(p_approval_details_rec => l_Approval_Details_rec,
                     x_exist_rule_name      => l_exist_rule_name,
                     x_return_status        => l_return_status);
   IF l_return_status = FND_API.g_true THEN
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_APPR_RULE_EXISTS');
         FND_MESSAGE.set_token('EXIST_RULE_NAME',l_exist_rule_name);
         FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;
   -- replace g_miss_char/num/date with current column values
   Complete_approval_details_Rec(p_approval_details_rec,l_approval_details_Rec);
   IF l_approval_details_Rec.seeded_flag = 'Y' THEN
     IF compare_columns(l_approval_details_Rec) = FND_API.g_false THEN
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_SEED_DATA');
         FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
     END IF;
   ELSE
	 IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
	    Check_approval_details_Items (
		  p_approval_details_rec  => l_approval_details_Rec ,
	       p_validation_mode =>  JTF_PLSQL_API.g_update,
		  x_return_status   => l_return_status
	    );
	    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
	       RAISE FND_API.g_exc_unexpected_error;
	    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
	       RAISE FND_API.g_exc_error;
	    END IF;
	 END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
	    Check_approval_details_Record (
	        p_approval_details_rec => p_approval_details_rec,
		   p_complete_rec  =>  l_approval_details_rec,
	        x_return_status => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END IF; -- check for seeded flag
   -- Check to see if the row is seeded if the row is seeded then can't update
   -- modified.. enabled flag for seeded rows can be updated.. added seed_needs_   -- update function
   IF l_approval_details_rec.seeded_flag='N'
	    OR seed_needs_update(l_approval_details_rec) = FND_API.g_true
	 THEN
   -------------------------- update --------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message (l_full_name || ': Update');
      END IF;
	    OPEN c_rec_exists (l_Approval_Details_rec.approval_detail_id, p_Approval_Details_rec.OBJECT_VERSION_NUMBER);
        FETCH c_rec_exists INTO l_dummy;
        If c_rec_exists%NOTFOUND THEN
			CLOSE c_rec_exists;
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
				FND_MSG_PUB.add;
			END IF;
			RAISE FND_API.g_exc_error;
		else
			CLOSE c_rec_exists;
		end IF;

	 AMS_APPROVAL_DETAILS_PKG.UPDATE_ROW(
        X_APPROVAL_DETAIL_ID => l_Approval_Details_rec.approval_detail_id,
        X_START_DATE_ACTIVE => l_approval_details_rec.START_DATE_ACTIVE,
        X_END_DATE_ACTIVE => l_approval_details_rec.END_DATE_ACTIVE,
        X_OBJECT_VERSION_NUMBER => l_approval_details_rec.OBJECT_VERSION_NUMBER+1,
        --X_SECURITY_GROUP_ID => l_approval_details_rec.SECURITY_GROUP_ID,
        X_BUSINESS_GROUP_ID => l_approval_details_rec.BUSINESS_GROUP_ID,
        X_BUSINESS_UNIT_ID => l_approval_details_rec.BUSINESS_UNIT_ID,
        X_ORGANIZATION_ID => l_approval_details_rec.ORGANIZATION_ID,
        X_CUSTOM_SETUP_ID => l_approval_details_rec.CUSTOM_SETUP_ID,
        X_APPROVAL_OBJECT => l_approval_details_rec.APPROVAL_OBJECT,
        X_APPROVAL_OBJECT_TYPE => l_approval_details_rec.APPROVAL_OBJECT_TYPE,
        X_APPROVAL_TYPE => l_approval_details_rec.APPROVAL_TYPE,
        X_APPROVAL_PRIORITY => l_approval_details_rec.APPROVAL_PRIORITY,
        X_APPROVAL_LIMIT_TO => l_approval_details_rec.APPROVAL_LIMIT_TO,
        X_APPROVAL_LIMIT_FROM => l_approval_details_rec.APPROVAL_LIMIT_FROM,
        X_SEEDED_FLAG => l_approval_details_rec.SEEDED_FLAG,
        X_ACTIVE_FLAG => l_Approval_Details_rec.ACTIVE_FLAG,
        X_CURRENCY_CODE => l_Approval_Details_rec.CURRENCY_CODE,
	X_USER_COUNTRY_CODE => l_Approval_Details_rec.USER_COUNTRY_CODE,
        X_NAME  => l_approval_details_rec.NAME,
        X_DESCRIPTION   => l_approval_details_rec.DESCRIPTION,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
        X_LAST_UPDATE_LOGIN => FND_GLOBAL.Conc_Login_Id
        );
   END IF;-- ending if loop for second seeded_flag check
   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;
   FND_MSG_PUB.count_and_get (
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Update_approval_details;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get (
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );

  WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO Update_approval_details;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get (
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );

  WHEN OTHERS THEN
     ROLLBACK TO Update_approval_details;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
        FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );
END Update_approval_details;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_approval_details
--
-- PURPOSE
--    Delete a approval details entry.
--
-- PARAMETERS
--    p_approval_detail_id: the approval_detail_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_detail_id          IN  NUMBER,
   p_object_version    IN  NUMBER
) IS

   CURSOR c_approval_details IS
   SELECT   *
   FROM  ams_approval_details_vl
   WHERE approval_detail_id = p_approval_detail_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.

   l_approval_details_rec    c_approval_details%ROWTYPE;
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Approval_Details';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

Begin

   OPEN c_approval_details;
   FETCH c_approval_details INTO l_approval_details_rec;
   IF c_approval_details%NOTFOUND THEN
      CLOSE c_approval_details;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_approval_details;
    --------------------- initialize -----------------------
    SAVEPOINT Delete_approval_details;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message (l_full_name || ': Start');
    END IF;
    IF FND_API.to_boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call (
       l_api_version,
       p_api_version,
       l_api_name,
       g_pkg_name
    ) THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;

    ------------------------ delete ------------------------
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message (l_full_name || ': Delete');
    END IF;
    -- Delete TL data
    IF l_approval_details_rec.seeded_flag='N'
    THEN
       AMS_APPROVAL_DETAILS_PKG.DELETE_ROW (p_approval_detail_id);
    ELSE
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name ('AMS', 'AMS_API_SEED_DATA');
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
       END IF;
    END IF;
    -------------------- finish --------------------------
    IF FND_API.to_boolean (p_commit) THEN
       COMMIT;
    END IF;
    FND_MSG_PUB.count_and_get (
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
    );
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message (l_full_name || ': End');
    END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO Delete_approval_details;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get (
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data
     );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO Delete_approval_details;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );

   WHEN OTHERS THEN
	ROLLBACK TO Delete_approval_details;
	x_return_status := FND_API.g_ret_sts_unexp_error ;
	IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
	THEN
	   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
	END IF;
	FND_MSG_PUB.count_and_get (
	   p_encoded => FND_API.g_false,
	   p_count   => x_msg_count,
	   p_data    => x_msg_data
	);
END Delete_approval_details;

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_approval_details
--
-- PURPOSE
--    Lock a approval details entry.
--
-- PARAMETERS
--    p_approval_detail_id: the approval_detail
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_detail_id          IN  NUMBER,
   p_object_version    IN  NUMBER
) IS
BEGIN
   NULL;
END;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_approval_details
--
-- PURPOSE
--    Validate a approval_details entry.
--
-- PARAMETERS
--    p_approval_details_rec: the record representing AMS_APPROVAL_DETAILS_VL (without ROW_ID).
--
-- NOTES
--    1. p_approval_details_rec should be the complete approval_details record.
--       There should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_details_rec         IN  approval_details_rec_type
) IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_approval_details';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_return_status   VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;
   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   IF NOT FND_API.compatible_api_call (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Check items');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_Approval_details_Items (
         p_approval_details_rec => p_approval_details_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Check record');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Approval_details_Record (
         p_approval_details_rec => p_approval_details_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
   -----------------check the start date <= end date ------

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
   x_return_status := FND_API.g_ret_sts_error;
   FND_MSG_PUB.count_and_get (
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
   WHEN FND_API.g_exc_unexpected_error THEN
   x_return_status := FND_API.g_ret_sts_unexp_error ;
   FND_MSG_PUB.count_and_get (
   p_encoded => FND_API.g_false,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   WHEN OTHERS THEN
   x_return_status := FND_API.g_ret_sts_unexp_error;
   IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
   THEN
   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
   END IF;
   FND_MSG_PUB.count_and_get (
   p_encoded => FND_API.g_false,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );

END Validate_approval_details;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approval_details_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_approval_details_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_approval_details_Items (
   p_approval_details_rec       IN  approval_details_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
) IS
BEGIN
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items0');
   END IF;

   --IF p_validation_mode = JTF_PLSQL_API.g_create THEN --VMODUR 24-Jul-2002
   --- some logic
     If (p_approval_details_rec.start_date_active > p_approval_details_rec.end_date_active) THEN
	    --dbms_output.put_line('st > ed ');
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_SD_BFR_ED');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
     END IF;

     If (p_approval_details_rec.approval_type = 'BUDGET' )THEN
      -- if (p_approval_details_rec.approval_object = 'CSCH') THEN -- R12
       --  if Is_Usage_Lite(p_approval_details_rec.custom_setup_id) = FND_API.g_false THEN -- R12
    	    if((p_approval_details_rec.approval_limit_from is NULL
		  or p_approval_details_rec.approval_limit_from = FND_API.g_miss_num)
		  AND(p_approval_details_rec.approval_limit_to is NULL
		  OR p_approval_details_rec.approval_limit_to = FND_API.g_miss_num))THEN
	        -- dbms_output.put_line('AMS_APPR_BGT_NO_MIN_AMT');
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.set_name('AMS', 'AMS_APPR_BGT_NO_MIN_AMT');
                   FND_MSG_PUB.add;
                   x_return_status := FND_API.g_ret_sts_error;
                 RETURN;
                 END IF;
            END IF;
	--  END IF;
       -- END IF;
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message ('Checking for the -ve max amounts');

     END IF;
     -- For Claims, negative max amount is OK
     If (p_approval_details_rec.approval_limit_to  IS NOT NULL
	    AND p_approval_details_rec.approval_limit_to <> FND_API.g_miss_num
       AND p_approval_details_rec.approval_limit_to < 0
            AND p_approval_details_rec.approval_object <> 'CLAM')
	  THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         --  FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_NO_CURR');
	   FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_MAX_AMT_LS_ZERO');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message ('Checking for the -ve min amounts');

     END IF;
     -- For Claims, negative min amount is OK
     If (p_approval_details_rec.approval_limit_from  IS NOT NULL
	    AND p_approval_details_rec.approval_limit_from <> FND_API.g_miss_num
       AND p_approval_details_rec.approval_limit_from < 0
            AND p_approval_details_rec.approval_object <> 'CLAM')
	  THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_MIN_AMT_LS_ZERO');
	      --dbms_output.put_line('AMS_APPR_DTL_MIN_AMT_LS_ZERO');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items1');

     END IF;
     If (p_approval_details_rec.approval_limit_from >= p_approval_details_rec.approval_limit_to) THEN
	      --dbms_output.put_line('AMS_APPR_MIN_MAX_AMT_ERR');
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_APPR_MIN_MAX_AMT_ERR');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items2');

     END IF;
     If (((p_approval_details_rec.approval_limit_to  IS NOT NULL
	    AND p_approval_details_rec.approval_limit_to <> FND_API.g_miss_num)
	    OR (p_approval_details_rec.approval_limit_from IS NOT NULL
	    AND p_approval_details_rec.approval_limit_from <> FND_API.g_miss_num))
	    AND (p_approval_details_rec.currency_code is NULL
		 OR p_approval_details_rec.currency_code = FND_API.g_miss_char)) THEN
	      --dbms_output.put_line('AMS_APPR_DTL_NO_CURR');
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_NO_CURR');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
     END IF;
  --END IF; -- VMODUR 24-Jul-2002


   --- some logic
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items3');
   END IF;
   -- Validate required items.
   Check_approval_dtls_Req_Items (
      p_approval_details_rec       => p_approval_details_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items4');
   END IF;
   -- Validate uniqueness.
   Check_approval_dtls_UK_Items (
      p_approval_details_rec          => p_approval_details_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN

      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items6');
   END IF;
/*   Check_approval_dtls_FK_Items(
      p_approval_details_rec       => p_approval_details_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   */
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items7');
   END IF;
   Check_approval_dtls_Lkup_Items (
      p_approval_details_rec          => p_approval_details_rec,
      x_return_status      => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items8');
   END IF;
   Check_approval_dtls_Flag_Items(
      p_approval_details_rec       => p_approval_details_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
  /*
   --- some logic
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items9');
   END IF;
   If (p_approval_details_rec.start_date_active > p_approval_details_rec.end_date_active) THEN
	    --dbms_output.put_line('st > ed ');
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_SD_BFR_ED');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items10');
END IF;
   If (p_approval_details_rec.approval_type = 'BUDGET' )THEN
	 if((p_approval_details_rec.approval_limit_from is NULL
		or p_approval_details_rec.approval_limit_from = FND_API.g_miss_num)
		AND(p_approval_details_rec.approval_limit_to is NULL
		OR p_approval_details_rec.approval_limit_to = FND_API.g_miss_num))THEN
	      -- dbms_output.put_line('AMS_APPR_BGT_NO_MIN_AMT');
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_APPR_BGT_NO_MIN_AMT');
            FND_MSG_PUB.add;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items11');
END IF;
   If (p_approval_details_rec.approval_limit_from >= p_approval_details_rec.approval_limit_to) THEN
	    --dbms_output.put_line('AMS_APPR_MIN_MAX_AMT_ERR');
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_APPR_MIN_MAX_AMT_ERR');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_Utility_PVT.debug_message ('Inside Check_approval_details_Items12');
END IF;
   If (((p_approval_details_rec.approval_limit_to  IS NOT NULL
	  AND p_approval_details_rec.approval_limit_to <> FND_API.g_miss_num)
	  OR (p_approval_details_rec.approval_limit_from IS NOT NULL
	  AND p_approval_details_rec.approval_limit_from <> FND_API.g_miss_num))
	  AND (p_approval_details_rec.currency_code is NULL
		 OR p_approval_details_rec.currency_code = FND_API.g_miss_char)) THEN
	    --dbms_output.put_line('AMS_APPR_DTL_NO_CURR');
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_APPR_DTL_NO_CURR');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
  */
END Check_approval_details_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approval_details_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_approval_details_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_approval_details_Record (
   p_approval_details_rec        IN  approval_details_Rec_Type,
   p_complete_rec     IN  approval_details_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
) IS
     l_start_date_active      DATE;
	l_end_date_active        DATE;
BEGIN
   --
   -- Use local vars to reduce amount of typing.
   if p_complete_rec.start_date_active IS NOT NULL then
      l_start_date_active := p_complete_rec.start_date_active;
   else
      if p_approval_details_rec.start_date_active is NOT NULL AND
         p_approval_details_rec.start_date_active <> FND_API.g_miss_date then
          l_start_date_active := p_approval_details_rec.start_date_active;
      end if;
   end if;
   if p_complete_rec.end_date_active IS NOT NULL then
       l_end_date_active := p_complete_rec.end_date_active;
   else
      if p_approval_details_rec.end_date_active is NOT NULL AND
         p_approval_details_rec.end_date_active <> FND_API.g_miss_date then
          l_end_date_active := p_approval_details_rec.end_date_active;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_start_date_active IS NOT NULL AND l_end_date_active IS NOT NULL THEN
     IF l_start_date_active > l_end_date_active THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_FROMDT_GTR_TODT');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;
END Check_approval_details_Record;
---------------------------------------------------------------------
-- PROCEDURE
--    Init_approval_details_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_approval_details_Rec (
   x_approval_details_rec         OUT NOCOPY  approval_details_Rec_Type
) IS
BEGIN
      x_approval_details_rec.approval_detail_id := FND_API.g_miss_num;
      x_approval_details_rec.start_date_active := FND_API.g_miss_date;
      x_approval_details_rec.end_date_active := FND_API.g_miss_date;
      x_approval_details_rec.object_version_number := FND_API.g_miss_num;
      --x_approval_details_rec.security_group_id := FND_API.g_miss_num;
      x_approval_details_rec.business_group_id := FND_API.g_miss_num;
      x_approval_details_rec.business_unit_id := FND_API.g_miss_num;
      x_approval_details_rec.organization_id := FND_API.g_miss_num;
      x_approval_details_rec.custom_setup_id := FND_API.g_miss_num;
      x_approval_details_rec.approval_object := FND_API.g_miss_char;
      x_approval_details_rec.approval_object_type := FND_API.g_miss_char;
      x_approval_details_rec.approval_type := FND_API.g_miss_char;
      x_approval_details_rec.approval_priority := FND_API.g_miss_char;
      x_approval_details_rec.approval_limit_to := FND_API.g_miss_num;
      x_approval_details_rec.approval_limit_from := FND_API.g_miss_num;
      x_approval_details_rec.seeded_flag := FND_API.g_miss_char;
      x_approval_details_rec.active_flag := FND_API.g_miss_char;
      x_approval_details_rec.currency_code := FND_API.g_miss_char;
      x_approval_details_rec.user_country_code := FND_API.g_miss_char;
      x_approval_details_rec.name := FND_API.g_miss_char;
      x_approval_details_rec.description := FND_API.g_miss_char;
END;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_approval_details_Rec
--
-- PURPOSE
--    For Update_approval_details, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_approval_details_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--    Changes have been made as g_miss_xxxx is no longer used
---------------------------------------------------------------------
PROCEDURE Complete_approval_details_Rec (
   p_approval_details_rec      IN  approval_details_Rec_Type,
   x_complete_rec   OUT NOCOPY approval_details_Rec_Type
) IS
   CURSOR c_approval_details IS
   SELECT   *
   FROM     ams_approval_details_vl
   WHERE    approval_detail_id = p_approval_details_rec.approval_detail_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_approval_details_rec    c_approval_details%ROWTYPE;
BEGIN
   x_complete_rec := p_approval_details_rec;
   OPEN c_approval_details;
   FETCH c_approval_details INTO l_approval_details_rec;
   IF c_approval_details%NOTFOUND THEN
      CLOSE c_approval_details;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_approval_details;
   --
      If p_approval_details_rec.approval_detail_id is null THEN
         x_complete_rec.approval_detail_id := l_approval_details_rec.approval_detail_id;
      END IF;
      -- Don't fill in dates as they can be null
/*
      IF p_approval_details_rec.start_date_active is null THEN
         x_complete_rec.start_date_active := l_approval_details_rec.start_date_active;
      END IF;

      IF p_approval_details_rec.end_date_active is null THEN
         x_complete_rec.end_date_active := l_approval_details_rec.end_date_active;
      END IF;
*/
      IF p_approval_details_rec.object_version_number is null THEN
         x_complete_rec.object_version_number := l_approval_details_rec.object_version_number;
      END IF;

/*    IF p_approval_details_rec.security_group_id is null THEN
         x_complete_rec.security_group_id := l_approval_details_rec.security_group_id;
      END IF;
*/

      IF p_approval_details_rec.business_group_id is null THEN
         x_complete_rec.business_group_id := l_approval_details_rec.business_group_id;
      END IF;

      IF p_approval_details_rec.business_unit_id is null THEN
         x_complete_rec.business_unit_id := l_approval_details_rec.business_unit_id;
      END IF;

      IF p_approval_details_rec.organization_id is null THEN
         x_complete_rec.organization_id := l_approval_details_rec.organization_id;
      END IF;

      IF p_approval_details_rec.custom_setup_id is null THEN
         x_complete_rec.custom_setup_id := l_approval_details_rec.custom_setup_id;
      END IF;

      IF p_approval_details_rec.approval_object is null THEN
         x_complete_rec.approval_object := l_approval_details_rec.approval_object;
      END IF;

      IF p_approval_details_rec.approval_object_type is null THEN
         x_complete_rec.approval_object_type := l_approval_details_rec.approval_object_type;
      END IF;

      IF p_approval_details_rec.approval_type is null THEN
         x_complete_rec.approval_type := l_approval_details_rec.approval_type;
      END IF;

      IF p_approval_details_rec.approval_priority is null THEN
         x_complete_rec.approval_priority := l_approval_details_rec.approval_priority;
      END IF;
      -- Limits can be null
/*
      IF p_approval_details_rec.approval_limit_to is null THEN
         x_complete_rec.approval_limit_to := l_approval_details_rec.approval_limit_to;
      END IF;

      IF p_approval_details_rec.approval_limit_from is null THEN
         x_complete_rec.approval_limit_from := l_approval_details_rec.approval_limit_from;
      END IF;
*/
      IF p_approval_details_rec.seeded_flag is null THEN
         x_complete_rec.seeded_flag := l_approval_details_rec.seeded_flag;
      END IF;

      IF p_approval_details_rec.active_flag is null THEN
         x_complete_rec.active_flag := l_approval_details_rec.active_flag;
      END IF;

      IF p_approval_details_rec.currency_code is null THEN
         x_complete_rec.currency_code := l_approval_details_rec.currency_code;
      END IF;
      /*
      IF p_approval_details_rec.user_country_code is null THEN
         x_complete_rec.user_country_code := l_approval_details_rec.user_country_code;
      END IF;
      */

      IF p_approval_details_rec.name is null THEN
         x_complete_rec.name := l_approval_details_rec.name;
      END IF;
      -- Description can be null
--    Bug 3737174
/*
      IF p_approval_details_rec.description is null THEN
         x_complete_rec.description := l_approval_details_rec.description;
      END IF;
*/
END Complete_approval_details_Rec;

---------------------------------------------------------
--  Function Compare Columns
-- added sugupta 05/22/2000
-- this procedure will compare that no values have been modified for seeded statuses
-----------------------------------------------------------------
FUNCTION compare_columns(
   p_approval_details_rec         in  approval_details_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.DEBUG_MESSAGE('sTART DATE:'|| to_char( p_approval_details_rec.start_date_active,'DD_MON_YYYY'));
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.DEBUG_MESSAGE('end DATE:'|| to_char( p_approval_details_rec.end_Date_active,'DD-MON-YYYY'));
END IF;

	if p_approval_details_rec.start_date_active is NOT NULL then
        if p_approval_details_rec.end_Date_active is NOT NULL then
           BEGIN
	        select 1 into l_count
		   from AMS_APPROVAL_DETAILS_VL
		   where approval_detail_id =p_approval_details_rec.approval_detail_id
		   and name =  p_approval_details_rec.name
		   and description =  p_approval_details_rec.description
		   and start_date_active = p_approval_details_rec.start_date_active
		   and end_date_active = p_approval_details_rec.end_Date_active
		  -- and security_group_id = p_approval_details_rec.security_group_id
		   and business_group_id = p_approval_details_rec.business_group_id
		   and user_country_code = p_approval_details_rec.user_country_code
		   and organization_id = p_approval_details_rec.organization_id
		   and custom_setup_id = p_approval_details_rec.custom_setup_id
		   and approval_object = p_approval_details_rec.approval_object
		   and approval_object_type = p_approval_details_rec.approval_object_type
		   and approval_type = p_approval_details_rec.approval_type
		   and approval_priority = p_approval_details_rec.approval_priority
		   and approval_limit_to = p_approval_details_rec.approval_limit_to
		   and approval_limit_from = p_approval_details_rec.approval_limit_from
		   and seeded_flag = 'Y'
		   and active_flag = 'Y'
		   and currency_code = p_approval_details_rec.currency_code;
		 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
		   l_count := 0;
	      END;
	   else -- for end date
		BEGIN
		   select 1 into l_count
		   from AMS_APPROVAL_DETAILS_VL
		   where approval_detail_id =p_approval_details_rec.approval_detail_id
		   and name =  p_approval_details_rec.name
		   and description =  p_approval_details_rec.description
		   and start_date_active = p_approval_details_rec.start_date_active
		   and end_date_active = p_approval_details_rec.end_Date_active
		   -- and security_group_id = p_approval_details_rec.security_group_id
		   and business_group_id = p_approval_details_rec.business_group_id
		   and user_country_code = p_approval_details_rec.user_country_code
		   and organization_id = p_approval_details_rec.organization_id
		   and custom_setup_id = p_approval_details_rec.custom_setup_id
		   and approval_object = p_approval_details_rec.approval_object
		   and approval_object_type = p_approval_details_rec.approval_object_type
		   and approval_type = p_approval_details_rec.approval_type
		   and approval_priority = p_approval_details_rec.approval_priority
		   and approval_limit_to = p_approval_details_rec.approval_limit_to
		   and approval_limit_from = p_approval_details_rec.approval_limit_from
		   and seeded_flag = 'Y'
		   and active_flag = 'Y'
		   and currency_code = p_approval_details_rec.currency_code;
		EXCEPTION
		   WHEN NO_DATA_FOUND THEN
		   l_count := 0;
		END;
	   end if; -- for end date
	else
	   BEGIN
	      select 1 into l_count
		 from AMS_APPROVAL_DETAILS_VL
		 where approval_detail_id =p_approval_details_rec.approval_detail_id
		 and name =  p_approval_details_rec.name
		 and description =  p_approval_details_rec.description
		 and start_date_active = p_approval_details_rec.start_date_active
		 and end_date_active = p_approval_details_rec.end_Date_active
		-- and security_group_id = p_approval_details_rec.security_group_id
		 and business_group_id = p_approval_details_rec.business_group_id
		 and user_country_code = p_approval_details_rec.user_country_code
		 and organization_id = p_approval_details_rec.organization_id
		 and custom_setup_id = p_approval_details_rec.custom_setup_id
		 and approval_object = p_approval_details_rec.approval_object
		 and approval_object_type =p_approval_details_rec.approval_object_type
		 and approval_type = p_approval_details_rec.approval_type
		 and approval_priority = p_approval_details_rec.approval_priority
		 and approval_limit_to = p_approval_details_rec.approval_limit_to
		 and approval_limit_from = p_approval_details_rec.approval_limit_from
		 and seeded_flag = 'Y'
		 and active_flag = 'Y'
		 and currency_code = p_approval_details_rec.currency_code;
	   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_count := 0;
	   END;
	end if;
     IF l_count = 0 THEN
        RETURN FND_API.g_false;
     ELSE
        RETURN FND_API.g_true;
     END IF;
END compare_columns;

---------------------------------------------------------
--  Function seed_needs_update
-- added sugupta 05/22/2000
-- this procedure will look at enabled flag and determine if update is needed
-----------------------------------------------------------------
FUNCTION seed_needs_update(
	p_approval_details_rec         in  approval_details_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
   BEGIN
	select 1 into l_count
	from AMS_APPROVAL_DETAILS
	where approval_detail_id = p_approval_details_rec.approval_detail_id
	and   seeded_flag = 'Y';
   EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_true;  -- needs update
   ELSE
      RETURN FND_API.g_false;  -- doesnt need update
   END IF;
END seed_needs_update;

-------------------------------------------------------------
--       Check_Approval_Dtls_Req_Items
-------------------------------------------------------------
PROCEDURE Check_Approval_Dtls_Req_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
) IS
BEGIN

   IF p_approval_details_rec.name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END;
-------------------------------------------------------------
--       Check_Approval_Dtls_UK_Items
-------------------------------------------------------------
PROCEDURE Check_Approval_Dtls_UK_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_validation_mode     IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS

   l_valid_flag    VARCHAR2(1);
/*
	l_dummy         NUMBER;
	l_rec   approval_details_Rec_Type;
	l_exists1  NUMBER := 1;
	l_exists2  NUMBER := 1;



	CURSOR c_approval_details(id_in IN NUMBER) IS
	SELECT   *
	FROM     ams_approval_details_vl
	WHERE    approval_detail_id = id_in;

	cursor c_appr_name1(name_in IN VARCHAR2) IS
	SELECT 1 FROM DUAL WHERE EXISTS (select 1 from AMS_APPROVAL_DETAILS_VL
							   where name = name_in);

	cursor c_appr_name2(name_in IN VARCHAR2, id_in IN NUMBER) IS
	SELECT 1 FROM DUAL WHERE EXISTS (select 1 from AMS_APPROVAL_DETAILS_VL
							   where name = name_in
								and approval_detail_id = id_in);

	l_approval_details_rec    c_approval_details%ROWTYPE;
*/
        cursor c_rule_name(name_in IN VARCHAR2, id_in IN NUMBER) IS
	SELECT '1' FROM DUAL WHERE EXISTS (select 1 from AMS_APPROVAL_DETAILS_VL
                                         where name = name_in
					 and approval_detail_id <> id_in);

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:Check_Approval_Dtls_UK_Items');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Validate unique approval_id
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'ams_approval_details',
      'approval_detail_id = ''' || p_approval_details_rec.approval_detail_id ||'''');
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'ams_approval_details',
      'approval_detail_id = ''' || p_approval_details_rec.approval_detail_id ||
      ''' AND approval_detail_id <> ' || p_approval_details_rec.approval_detail_id);
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_APPR_DUPLICATE_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --Validate unique apporval rule name
   -- Commented due to Bug 2776795 ams_utility_pvt check_uniqueness cannot handle names containing
   -- operators like 'AND'
   /*

   l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'ams_approval_details_vl',  'NAME = ''' || p_approval_details_rec.name ||
      ''' AND approval_detail_id <> ' || NVL(p_approval_details_rec.approval_detail_id,FND_API.G_MISS_NUM));
   */

   OPEN c_rule_name(p_approval_details_rec.name,NVL(p_approval_details_rec.approval_detail_id,FND_API.G_MISS_NUM));
   FETCH c_rule_name INTO l_valid_flag;
   IF c_rule_name%NOTFOUND THEN
      NULL;
   END IF;
   CLOSE c_rule_name;


   IF l_valid_flag = '1' THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Check_Approval_Dtls_UK_Items: Inside error');
         END IF;
         FND_MESSAGE.set_name('AMS', 'AMS_DUP_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


/*
	IF p_validation_mode = JTF_PLSQL_API.g_create
	AND p_approval_details_rec.approval_detail_id IS NOT NULL THEN
		OPEN c_appr_name2(P_approval_details_rec.name,P_approval_details_rec.approval_detail_id);
		fetch c_appr_name2 into l_dummy;
		close c_appr_name2;

		IF l_dummy = 1 THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name ('AMS', 'AMS_DUP_NAME');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.g_ret_sts_error;
			RETURN;
		END IF;

	END IF;


   -- check if NAME is UNIQUE
	IF p_validation_mode = JTF_PLSQL_API.g_create THEN
		OPEN c_appr_name1(P_approval_details_rec.name);
		fetch c_appr_name1 into l_dummy;
		close c_appr_name1;
		IF l_dummy <> 1 THEN
			l_valid_flag := FND_API.g_false;
		END IF;
	ELSE
		OPEN c_appr_name2(P_approval_details_rec.name, P_approval_details_rec.approval_detail_id);
		fetch c_appr_name2 into l_dummy;
		close c_appr_name2;
		IF l_dummy <> 1 THEN
			l_valid_flag := FND_API.g_false;
		END IF;
	END IF;


	IF l_valid_flag = FND_API.g_false THEN
		IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name ('AMS', 'AMS_DUP_NAME');
			FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;

*/
    /* Check dates over lap. If Approval Type is Concept, we will check only for Dates overlap. If it is
       Budget, we call Amounts Over Lap function with in Dates Overlap function which checks for Budget
       Overlap.
     */

    IF( Check_Dates_Overlap ( p_approval_details_rec , p_validation_mode)) = FND_API.g_true THEN
          RAISE FND_API.g_exc_error;
    END IF;

END Check_Approval_Dtls_UK_Items;
-------------------------------------------------------------
--       Check_Approval_Dtls_FK_Items
-------------------------------------------------------------
PROCEDURE Check_Approval_Dtls_FK_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
   l_lookup_type           varchar2(30);
   l_count                 number;
   l_meaning               varchar2(80);
   l_dummy                 number;

   CURSOR c_get_org(cur_organization_id number,
      cur_business_group_id number,
      cur_org_type  varchar2) is
      SELECT count(1)
      FROM hr_organization_units  hou
      WHERE hou.organization_id   = cur_organization_id
      --AND hou.business_group_id = cur_business_group_id
      AND hou.type              = nvl(cur_org_type,hou.type)
      AND sysdate between hou.date_from and nvl(hou.date_to,sysdate +1 );

   Cursor c_appr_objt_type_exists(id_in IN NUMBER) IS
	 SELECT 1 FROM   dual
	 WHERE EXISTS (SELECT 1 FROM   ams_categories_b
		                WHERE  enabled_flag = 'Y'
				AND arc_category_created_for = 'FUND'
				AND category_id = id_in);

   cursor c_cust_setup_id_c_exists(id_in IN NUMBER) IS
   SELECT 1 from dual
   where EXISTS (select 1 FROM ams_custom_setups_b
			   WHERE enabled_flag = 'Y'
			   AND object_type IN ('RCAM','ECAM'));

   cursor c_cust_setup_id_exists(id_in IN NUMBER, p_lookup_code IN VARCHAR2) IS
   SELECT 1 from dual
   where EXISTS (select 1 FROM ams_custom_setups_b
			   WHERE enabled_flag = 'Y'
			   AND object_type = p_lookup_code);
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- check approval_object
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items0');
	END IF;
	If p_approval_details_rec.approval_object <> FND_API.g_miss_char THEN
		ams_utility_pvt.get_lookup_meaning( 'AMS_APPROVAL_RULE_FOR',
			p_approval_details_rec.approval_object,
			x_return_status,
			l_meaning
		);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.set_name('AMS', 'AMS_BAD_APPROVAL_OBJECT_TYPE');
				FND_MSG_PUB.add;
				RETURN;
			END IF;
		END IF;
	END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items1');
	END IF;
	If p_approval_details_rec.approval_type <> FND_API.g_miss_char THEN
		ams_utility_pvt.get_lookup_meaning( 'AMS_APPROVAL_TYPE',
			p_approval_details_rec.approval_type,
			x_return_status,
			l_meaning
		);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.set_name('AMS', 'AMS_INVALID_APPROVAL_TYPE');
				FND_MSG_PUB.add;
				RETURN;
			END IF;
		END IF;
	END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items2');
	END IF;
	If (p_approval_details_rec.approval_object_type <> FND_API.g_miss_char
		AND p_approval_details_rec.approval_object_type IS NOT NULL) THEN
		IF (AMS_DEBUG_HIGH_ON) THEN

		AMS_Utility_PVT.debug_message ('Inside Check_FK__Items21');
		END IF;
		IF p_approval_details_rec.approval_object = 'FUND' then
			IF (AMS_DEBUG_HIGH_ON) THEN

			AMS_Utility_PVT.debug_message ('Inside Check_FK__Items22');
			END IF;
			open c_appr_objt_type_exists(to_number(p_approval_details_rec.approval_object_type));
			fetch c_appr_objt_type_exists INTO l_dummy;
			close c_appr_objt_type_exists;
			IF l_dummy <> 1 THEN
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					FND_MESSAGE.set_name('AMS', 'AMS_BAD_APPROVAL_OBJECT_TYPE');
					FND_MSG_PUB.add;
					x_return_status := FND_API.g_ret_sts_error;
					RETURN;
				END IF;
			END IF;
		ELSIF p_approval_details_rec.approval_object = 'CAMP' OR
			p_approval_details_rec.approval_object = 'EVEH'   OR
			p_approval_details_rec.approval_object = 'EONE'   OR
			p_approval_details_rec.approval_object = 'EVEO' then
			IF (AMS_DEBUG_HIGH_ON) THEN

			AMS_Utility_PVT.debug_message ('Inside Check_FK__Items3');
			END IF;
			IF p_approval_details_rec.approval_object = 'CAMP' then
				l_lookup_type := 'AMS_MEDIA_TYPE';
			ELSE
				l_lookup_type := 'AMS_EVENT_TYPE';
			END IF;
			ams_utility_pvt.get_lookup_meaning( l_lookup_type,
				p_approval_details_rec.approval_object_type,
				x_return_status,
				l_meaning
			);
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					FND_MESSAGE.set_name('AMS', 'AMS_BAD_APPROVAL_OBJECT_TYPE');
					FND_MSG_PUB.add;
					RETURN;
				END IF;
			END IF;
		END IF;
	END iF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items4');
	END IF;
	IF (p_approval_details_rec.approval_priority IS NOT NULL AND
		p_approval_details_rec.approval_priority <> FND_API.g_miss_char) THEN
		IF p_approval_details_rec.approval_object = 'CAMP' OR
			p_approval_details_rec.approval_object = 'EVEH'   OR
			p_approval_details_rec.approval_object = 'EVEO' then
				ams_utility_pvt.get_lookup_meaning( 'AMS_PRIORITY',
				 p_approval_details_rec.approval_priority,
				x_return_status,
				l_meaning
			);
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					FND_MESSAGE.set_name('AMS', 'AMS_APPR_NO_PRIORITY_LKUP');
					FND_MSG_PUB.add;
					RETURN;
				END IF;
			END IF;
		END IF;
	END iF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items5');
	END IF;

	If p_approval_details_rec.custom_setup_id <> FND_API.g_miss_num THEN
		IF p_approval_details_rec.approval_object <> FND_API.g_miss_char THEN
			IF p_approval_details_rec.approval_object = 'CAMP' THEN
				open c_cust_setup_id_c_exists(p_approval_details_rec.custom_setup_id);
				fetch  c_cust_setup_id_c_exists INTO l_dummy;
				close  c_cust_setup_id_c_exists;
				IF l_dummy <> 1 THEN
					IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
						FND_MESSAGE.set_name('AMS', 'AMS_BAD_CUSTOM_SETUP_ID');
						FND_MSG_PUB.add;
						x_return_status := FND_API.g_ret_sts_error;
						RETURN;
					END IF;
				END IF;
			ELSIF p_approval_details_rec.approval_object = 'EVEH'
			OR p_approval_details_rec.approval_object = 'EVEO'
			OR p_approval_details_rec.approval_object = 'FUND' THEN
				open c_cust_setup_id_exists(p_approval_details_rec.custom_setup_id, p_approval_details_rec.approval_object);
				fetch  c_cust_setup_id_exists INTO l_dummy;
				close  c_cust_setup_id_exists;
				IF l_dummy <> 1 THEN
					IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
						FND_MESSAGE.set_name('AMS', 'AMS_BAD_CUSTOM_SETUP_ID');
						FND_MSG_PUB.add;
						x_return_status := FND_API.g_ret_sts_error;
						RETURN;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items6');
	END IF;
	IF p_approval_details_rec.business_unit_id is not null then
		OPEN c_get_org(p_approval_details_rec.business_unit_id ,
         p_approval_details_rec.business_group_id, 'BU') ;
		fetch c_get_org into l_count;
		close c_get_org;
		IF l_count = 0 then
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.set_name('AMS', 'AMS_BAD_BU_ID');
				FND_MSG_PUB.add;
				x_return_status := FND_API.g_ret_sts_error;
				RETURN;
			END IF;
		END IF;
	END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message ('Inside Check_FK__Items7');
	END IF;
	IF p_approval_details_rec.organization_id is not null then
		OPEN c_get_org(p_approval_details_rec.organization_id ,
         p_approval_details_rec.business_group_id, '') ;
		fetch c_get_org into l_count;
		close c_get_org;
		IF l_count = 0 then
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.set_name('AMS', 'AMS_BAD_ORG_ID');
				FND_MSG_PUB.add;
				x_return_status := FND_API.g_ret_sts_error;
				RETURN;
			END IF;
		END IF;
	END IF;
END Check_Approval_Dtls_FK_Items;
-------------------------------------------------------------
--       Check_Approval_Dtls_Lkup_Items
-------------------------------------------------------------
PROCEDURE Check_Approval_Dtls_Lkup_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
)IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Check_Approval_Dtls_Lkup_Items;

-------------------------------------------------------------
--       Check_Approval_Dtls_Flag_Items
-------------------------------------------------------------
PROCEDURE Check_Approval_Dtls_Flag_Items (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_return_status       OUT NOCOPY   VARCHAR2
) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Check_Approval_Dtls_Flag_Items;
--------------------------------------------------------------------

-------------------------------------------------------------
--       Check_Approval_Amounts_Overlap
-------------------------------------------------------------
-- Bug 2195020 This was changed from a function to a procedure to return
-- the name of the overlapping rule
PROCEDURE Check_Approval_Amounts_Overlap (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_appoval_ids            IN  t_approval_id_table,
   x_exist_rule_name        OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2)
IS

l_Approval_Details_rec   Approval_Details_Rec_Type;
l_max_amount   NUMBER;
l_min_amount   NUMBER;
l_approval_id  NUMBER;
p_max_amount   NUMBER := p_approval_details_rec.approval_limit_to;
p_min_amount   NUMBER := p_approval_details_rec.approval_limit_from;
l_id           NUMBER := 1;
amount_overlap BOOLEAN := FND_API.to_boolean(FND_API.g_false);
l_rule_name    VARCHAR2(240);

CURSOR c_approval_rule (l_approval_id IN NUMBER)IS
         SELECT approval_limit_from, approval_limit_to
	 FROM ams_approval_details
         WHERE  approval_detail_id = l_approval_id;

BEGIN

     FOR l_id IN 1..p_appoval_ids.COUNT LOOP

         l_approval_id :=  p_appoval_ids(l_id);

         OPEN c_approval_rule(l_approval_id);
         FETCH c_approval_rule INTO l_min_amount, l_max_amount;
         CLOSE c_approval_rule;

         IF ( l_max_amount IS NULL AND l_min_amount IS NOT NULL AND p_min_amount IS NOT NULL AND p_max_amount IS NOT NULL) THEN
            IF ( p_max_amount > l_min_amount) THEN
                amount_overlap := FND_API.to_boolean(FND_API.g_true);
            END IF;
         END IF;

         IF NOT amount_overlap AND
	   (l_max_amount IS NOT NULL AND l_min_amount IS NOT NULL AND p_max_amount IS NULL AND p_min_amount IS NOT NULL) THEN
             IF ( p_min_amount < l_max_amount) THEN
               amount_overlap := FND_API.to_boolean(FND_API.g_true);
            END IF;
         END IF;

         -- Condition added by VMODUR for bug 2340052
      -- Case when max amounts are null and a rule is setup for which min amountis greater than or equal existing amount
         IF NOT amount_overlap AND
	   (l_min_amount IS NOT NULL and l_max_amount IS NULL and p_min_amount IS NOT NULL and p_max_amount IS NULL) THEN

            IF (p_min_amount >= l_min_amount) THEN
              amount_overlap := FND_API.to_boolean(FND_API.g_true);
            END IF;
         END IF;

         IF NOT amount_overlap AND
	   ( l_max_amount IS NOT NULL AND l_min_amount IS NOT NULL AND p_max_amount IS NOT NULL AND p_min_amount IS NOT NULL) THEN


            IF ( p_min_amount >= l_min_amount AND p_min_amount < l_max_amount ) THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The budget range is overlapping with that of existing rule ');
                END IF;
                amount_overlap := FND_API.to_boolean(FND_API.g_true);

            ELSIF ( p_max_amount > l_min_amount AND p_max_amount <= l_max_amount ) THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The budget range is overlapping with that of existing rule ');
                END IF;
                amount_overlap := FND_API.to_boolean(FND_API.g_true);

            ELSIF ( p_min_amount < l_min_amount AND p_max_amount > l_max_amount ) THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The budget range is overlapping with that of existing rule ');
                END IF;
                amount_overlap := FND_API.to_boolean(FND_API.g_true);

            END IF;

        END IF;

	IF amount_overlap THEN
	   Get_Approval_Rule_Name(p_approval_detail_id => l_approval_id,
	                          x_rule_name          => l_rule_name);

           x_exist_rule_name := l_rule_name;
	   x_return_status   := FND_API.g_true;
	   EXIT;
	ELSE
	   x_return_status := FND_API.g_false;
	END IF;

     END LOOP;

END Check_Approval_Amounts_Overlap;

------------------------------------------------------------------------
-- Bug# 2195020 VMODUR
PROCEDURE Check_Unique_Rule (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_exist_rule_name        OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_count                  NUMBER       := 0;
l_miss_num               NUMBER := FND_API.g_miss_num;
l_miss_char              VARCHAR2(30) := FND_API.g_miss_char;
l_miss_date              DATE := FND_API.g_miss_date;
l_approval_detail_id     NUMBER;
l_approval_rule_name     AMS_APPROVAL_DETAILS_V.Name%TYPE;

   CURSOR c_approval_unique IS
          select approval_detail_id, name
            from AMS_APPROVAL_DETAILS_VL --  Perf Bug Fix. Was previously using _V
            where nvl(start_date_active,l_miss_date)  = nvl(p_approval_details_rec.start_date_active, l_miss_date)
            and nvl(end_date_active,l_miss_date)  = nvl(p_approval_details_rec.end_date_active, l_miss_date)
            and nvl(business_unit_id,l_miss_num)  = nvl(p_approval_details_rec.business_unit_id, l_miss_num)
            and nvl(user_country_code,l_miss_char) = nvl(p_approval_details_rec.user_country_code, l_miss_char)
            and nvl(currency_code,l_miss_char) = nvl(p_approval_details_rec.currency_code, l_miss_char)
            and nvl(organization_id,l_miss_num)  = nvl(p_approval_details_rec.organization_id, l_miss_num)
            and nvl(custom_setup_id,l_miss_num)  = nvl(p_approval_details_rec.custom_setup_id, l_miss_num)
            and approval_object = p_approval_details_rec.approval_object
            and nvl(approval_object_type,l_miss_char)  = nvl(p_approval_details_rec.approval_object_type, l_miss_char)
            and nvl(approval_type,l_miss_char)  = nvl(p_approval_details_rec.approval_type, l_miss_char)
            and nvl(approval_priority,l_miss_char)  = nvl(p_approval_details_rec.approval_priority, l_miss_char)
            -- Bug 3068835 both lines were using limit_to
            and nvl(approval_limit_from,l_miss_num)  = nvl(p_approval_details_rec.approval_limit_from, l_miss_num)
            and nvl(approval_limit_to,l_miss_num)  = nvl(p_approval_details_rec.approval_limit_to, l_miss_num);



BEGIN

        OPEN c_approval_unique;
        FETCH c_approval_unique INTO l_approval_detail_id, l_approval_rule_name;
        CLOSE c_approval_unique ;

        IF l_approval_detail_id IS NOT NULL THEN
                    IF  p_approval_details_rec.approval_detail_id IS NOT NULL THEN
                       IF l_approval_detail_id <> p_approval_details_rec.approval_detail_id THEN
                              x_return_status := Fnd_Api.g_true;
                       ELSE
                              x_return_status := Fnd_Api.g_false;
                       END IF;
                    ELSE
                       x_return_status := Fnd_Api.g_true;
                    END IF;
        ELSE
                     x_return_status := Fnd_Api.g_false;
        END IF;

           x_exist_rule_name := l_approval_rule_name;
END Check_Unique_Rule;

----------------------------------------------------------------------------------

-------------------------------------------------------------
--       Check_Dates_Overlap
-------------------------------------------------------------
FUNCTION Check_Dates_Overlap (
   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   p_validation_mode IN VARCHAR2
) RETURN VARCHAR2
IS

l_Approval_Details_rec   Approval_Details_Rec_Type;
l_start_date DATE;
l_end_date DATE;
p_start_date DATE := TRUNC(p_approval_details_rec.start_date_active);
p_end_date DATE := TRUNC(p_approval_details_rec.end_date_active);
l_approval_detail_id    NUMBER ;

l_temp NUMBER := 0;

l_miss_num               NUMBER := FND_API.g_miss_num;
l_miss_char              VARCHAR2(30) := FND_API.g_miss_char;
l_miss_date              DATE := FND_API.g_miss_date;
l_rule_name              VARCHAR2(240);
l_return_status          VARCHAR2(1);


   v_approvalIds t_approval_id_table;

   CURSOR c_approval_dates IS
         SELECT TRUNC(start_date_active) , TRUNC(end_date_active) FROM ams_approval_details
                 WHERE approval_detail_id = p_approval_details_rec.approval_detail_id;

   CURSOR c_approval_rule IS
         SELECT approval_detail_id, TRUNC(start_date_active), TRUNC(end_date_active) FROM ams_approval_details
                where nvl(business_unit_id,l_miss_num)  = nvl(p_approval_details_rec.business_unit_id, l_miss_num)
                and nvl(user_country_code,l_miss_char) = nvl(p_approval_details_rec.user_country_code, l_miss_char)
                and nvl(currency_code,l_miss_char) = nvl(p_approval_details_rec.currency_code, l_miss_char)
                and nvl(organization_id,l_miss_num)  = nvl(p_approval_details_rec.organization_id, l_miss_num)
                and nvl(custom_setup_id,l_miss_num)  = nvl(p_approval_details_rec.custom_setup_id, l_miss_num)
                and approval_object  = p_approval_details_rec.approval_object
                and nvl(approval_object_type,l_miss_char)  = nvl(p_approval_details_rec.approval_object_type, l_miss_char)
                and approval_type  = p_approval_details_rec.approval_type
                and nvl(approval_priority,l_miss_char)  = nvl(p_approval_details_rec.approval_priority, l_miss_char)
                AND approval_detail_id NOT IN(nvl(p_approval_details_rec.approval_detail_id,0));


 BEGIN

   /* If the Rule is already active i.e. start_date is < SYSDATE, you cannot update the start_date */
	IF p_validation_mode = JTF_PLSQL_API.g_update THEN

     OPEN c_approval_dates;
     FETCH c_approval_dates INTO l_start_date, l_end_date;
     CLOSE c_approval_dates;

      IF (AMS_DEBUG_HIGH_ON) THEN
        Ams_Utility_Pvt.debug_message('l_start_date '||l_start_date);
        Ams_Utility_Pvt.debug_message('l_end_date '||l_end_date);
        Ams_Utility_Pvt.debug_message('p_rec_start_date '||p_start_date);
        Ams_Utility_Pvt.debug_message('p_rec_end_date '||p_end_date);
      END IF;

      IF (p_start_date IS NOT NULL ) THEN

         IF (l_start_date <= trunc(SYSDATE) AND p_start_date <> l_start_date ) THEN
             IF (AMS_DEBUG_HIGH_ON) THEN
               Ams_Utility_Pvt.debug_message('You cannot update the Approval Rule start date as it is already active');
         END IF;

             IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                Fnd_Message.set_name('AMS', 'AMS_APRD_START_DATE_NO_UPDATE');
                Fnd_Msg_Pub.ADD;
                RETURN FND_API.g_true;
             END IF;

         END IF;

         IF ( l_start_date IS NOT NULL AND l_start_date > trunc(SYSDATE)
              AND p_start_date < trunc(SYSDATE)
            ) THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

               Ams_Utility_Pvt.debug_message('Approval Rule Start Date cannot be less than the system date');
               END IF;

            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APRD_START_DATE_LT_SYSDATE');
              Fnd_Msg_Pub.ADD;
              RETURN FND_API.g_true;
            END IF;
         END IF;


       END IF;

    END IF;


    IF p_validation_mode = JTF_PLSQL_API.g_create THEN

       /* Checking the Dates are Valid Or Not */
       IF (p_start_date IS NOT NULL AND p_start_date < trunc(SYSDATE)) THEN
           IF (AMS_DEBUG_HIGH_ON) THEN

           Ams_Utility_Pvt.debug_message('Approval Rule Start Date cannot be less than the system date');
           END IF;

           IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APRD_START_DATE_LT_SYSDATE');
              Fnd_Msg_Pub.ADD;
              RETURN FND_API.g_true;
           END IF;
       END IF;

    END IF;

    IF (p_start_date IS NOT NULL AND p_start_date < trunc(SYSDATE)
        AND l_start_date IS NOT NULL AND l_start_date > trunc(SYSDATE)) THEN
        IF (AMS_DEBUG_HIGH_ON) THEN

        Ams_Utility_Pvt.debug_message('Approval Rule Start Date cannot be less than the system date');
        END IF;

        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
           Fnd_Message.set_name('AMS', 'AMS_APRD_START_DATE_LT_SYSDATE');
           Fnd_Msg_Pub.ADD;
           RETURN FND_API.g_true;
        END IF;
    END IF;

    IF (p_end_date IS NOT NULL AND p_end_date < trunc(SYSDATE)) THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       Ams_Utility_Pvt.debug_message('Approval Rule End Date cannot be less than the system date');
       END IF;

       IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
          Fnd_Message.set_name('AMS', 'AMS_APRD_END_DATE_LT_SYSDATE');
          Fnd_Msg_Pub.ADD;
          RETURN FND_API.g_true;
       END IF;
     END IF;

     IF (p_start_date IS NOT NULL AND p_end_date IS NOT NULL) THEN
        IF ( p_start_date > p_end_date ) THEN
           IF (AMS_DEBUG_HIGH_ON) THEN

           Ams_Utility_Pvt.debug_message('Approval Rule END Date cannot be less than  Start Date');
           END IF;

           IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APRD_ED_DATE_LT_ST_DATE');
              Fnd_Msg_Pub.ADD;
              RETURN FND_API.g_true;
           END IF;
        END IF;
     END IF;




     /* Checking for Date Overlap with any other record if exists with the same rule parameters */

     OPEN c_approval_rule;
     FETCH c_approval_rule INTO l_approval_detail_id, l_start_date, l_end_date;

     WHILE c_approval_rule%FOUND LOOP

      IF ( l_end_date IS NULL AND l_start_date IS NOT NULL AND p_start_date IS NOT NULL AND p_end_date IS NOT NULL) THEN
         IF( p_end_date >= l_start_date) THEN

           IF (AMS_DEBUG_HIGH_ON) THEN



           Ams_Utility_Pvt.debug_message('Entered Condition 1 ');

           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

           Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
           END IF;

           l_temp := l_temp + 1;
           v_approvalIds(l_temp) := l_approval_detail_id;

         END IF;
      END IF;

      IF ( l_end_date IS NULL AND l_start_date IS NOT NULL AND p_start_date IS NOT NULL AND p_end_date IS NULL) THEN
         IF( p_start_date >= l_start_date) THEN

           IF (AMS_DEBUG_HIGH_ON) THEN



           Ams_Utility_Pvt.debug_message('Entered Condition 1 ');

           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

           Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
           END IF;

           l_temp := l_temp + 1;
           v_approvalIds(l_temp) := l_approval_detail_id;

         END IF;
      END IF;



      IF (l_end_date IS NOT NULL AND l_start_date IS NOT NULL AND p_end_date IS NULL AND p_start_date IS NOT NULL) THEN
          IF( p_start_date <= l_end_date) THEN

           IF (AMS_DEBUG_HIGH_ON) THEN



           Ams_Utility_Pvt.debug_message('Entered Condition 2 ');

           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

           Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
           END IF;

           l_temp := l_temp + 1;
           v_approvalIds(l_temp) := l_approval_detail_id;


         END IF;
      END IF;


      IF( l_end_date IS NOT NULL AND l_start_date IS NOT NULL AND p_end_date IS NOT NULL AND p_start_date IS NOT NULL) THEN

         IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_Pvt.debug_message('Entered Condition 3 ');
         Ams_Utility_Pvt.debug_message('p_start_date is ' || to_char(p_start_date));
         Ams_Utility_Pvt.debug_message('p_end_date is ' || to_char(p_end_date));
         Ams_Utility_Pvt.debug_message('l_start_date is ' || to_char(l_start_date));
         Ams_Utility_Pvt.debug_message('l_end_date is ' || to_char(l_end_date));
         END IF;

         IF ( p_start_date >= l_start_date AND p_start_date <= l_end_date
         -- AND Condition added due to Bug 3275739
         -- We don't need to validate overlap with expired approval rules
          AND l_end_date >= trunc(SYSDATE)) THEN
             IF (AMS_DEBUG_HIGH_ON) THEN

             Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
             END IF;

             l_temp := l_temp + 1;
             v_approvalIds(l_temp) := l_approval_detail_id;

         ELSIF ( p_end_date >= l_start_date AND p_end_date <= l_end_date
         -- AND Condition added due to Bug 3275739
         -- We don't need to validate overlap with expired approval rules
         AND l_end_date >= trunc(SYSDATE)) THEN
             IF (AMS_DEBUG_HIGH_ON) THEN

             Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
             END IF;

             l_temp := l_temp + 1;
             v_approvalIds(l_temp) := l_approval_detail_id;

         ELSIF ( p_start_date <= l_start_date AND p_end_date >= l_end_date
         -- AND Condition added due to Bug 3275739
         -- We don't need to validate overlap with expired approval rules
         AND l_end_date >= trunc(SYSDATE)) THEN
             IF (AMS_DEBUG_HIGH_ON) THEN

             Ams_Utility_Pvt.debug_message('The date range is overlapping with that of existing rule ');
             END IF;

             l_temp := l_temp + 1;
             v_approvalIds(l_temp) := l_approval_detail_id;

         END IF;

      END IF;

      FETCH c_approval_rule INTO l_approval_detail_id, l_start_date, l_end_date;

          END LOOP;

     CLOSE c_approval_rule;

     IF(p_approval_details_rec.approval_type = 'CONCEPT') THEN
        IF(l_temp <> 0) THEN -- date overlap is there

           Get_Approval_Rule_Name(p_approval_detail_id => v_approvalIds(1),
                                  x_rule_name          => l_rule_name);

           IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
              Fnd_Message.set_name('AMS', 'AMS_APRD_DATE_OVERLAP');
              Fnd_Message.set_token('EXIST_RULE_NAME', l_rule_name);
              Fnd_Msg_Pub.ADD;
              RETURN FND_API.g_true;
           END IF;
        END IF;
     --ELSIF (p_approval_details_rec.approval_type = 'BUDGET') THEN --- VMODUR 30-Oct-2003
     -- Change because claims etc. are not being checked for Amt Overlap
     ELSE
        IF(l_temp <> 0) THEN -- date overlap is there
           Check_Approval_Amounts_Overlap  (p_approval_details_rec => p_approval_details_rec,
                                            p_appoval_ids          => v_approvalIds,
                                            x_exist_rule_name      => l_rule_name,
                                            x_return_status        => l_return_status);
           IF l_return_status = FND_API.g_true THEN
             IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                 Fnd_Message.set_name('AMS', 'AMS_APRD_MIN_MAX_AMT_OVERLAP');
                 Fnd_Message.set_token('EXIST_RULE_NAME', l_rule_name);
                 Fnd_Msg_Pub.ADD;
                 RETURN FND_API.g_true;
              END IF;
           END IF;
        END IF;
     END IF;

     RETURN FND_API.g_false;

END Check_Dates_Overlap;
--------------------------------------------------------------------

END AMS_approval_details_PVT;

/
