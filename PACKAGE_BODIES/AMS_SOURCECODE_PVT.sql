--------------------------------------------------------
--  DDL for Package Body AMS_SOURCECODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SOURCECODE_PVT" AS
/*$Header: amsvscgb.pls 115.29 2002/11/22 23:38:55 dbiswas ship $*/

g_pkg_name  CONSTANT VARCHAR2(30) := 'AMS_SourceCode_PVT';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

 -- Forward declaration
 /*PROCEDURE modify_sourcecode(
  p_source_code                IN  VARCHAR2,
  p_object_type                 IN  VARCHAR2,
  p_object_id		     IN   NUMBER,
  p_sourcecode_id          IN NUMBER,
  p_related_sourcecode    IN  VARCHAR2 := NULL,
  p_releated_sourceobj    IN  VARCHAR2 := NULL,
  p_related_sourceid      IN  NUMBER   := NULL,

  x_return_status     OUT NOCOPY VARCHAR2
) ;*/

-----------------------------------------------------------------
-- FUNCTION
--    is_source_code_unique(p_source_code)
-----------------------------------------------------------------


FUNCTION is_source_code_unique(
   p_source_code  IN VARCHAR2
)
RETURN VARCHAR2 IS

   CURSOR c_source_code IS
   SELECT 1
     FROM ams_source_codes
    WHERE source_code = p_source_code;

   l_dummy  NUMBER;

BEGIN

   OPEN c_source_code;
   FETCH c_source_code INTO l_dummy;
   CLOSE c_source_code;

   IF l_dummy = 1 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END;


-----------------------------------------------------------------
-- FUNCTION
--    get_unique_sequence
-- DESCRIPTION
--    Return a unique sequence to be used as part of the
--    generated source code.
-- PARAMETERS
--    p_geo_code - code corresponding to the geographic region
--          of the user.
--    p_date_code - code corresponding to the current date using
--          the format specified in the profile.
--    p_cust_code - code associated to the marketing activity's
--          custom setup type.
-----------------------------------------------------------------
FUNCTION get_unique_sequence (
   p_geo_code IN VARCHAR2,
   p_date_code IN VARCHAR2,
   p_cust_code IN VARCHAR2
)
RETURN VARCHAR2;

-----------------------------------------------------------------
-- FUNCTION
--    get_new_source_code (p_object_type, p_custsetup_id, p_global_flag)
-- NOTES
--    Internal Rollout Ref #20:
--    New source code generation algorithm
--       - geographic region code
--       - current month year
--       - numeric sequence
--       - suffix from custom seteups
--    Not doing anything with the p_object_type in the
--    current version.
-----------------------------------------------------------------
FUNCTION get_new_source_code (
   p_object_type IN VARCHAR2,
   p_custsetup_id IN NUMBER,
   p_global_flag IN VARCHAR2 := FND_API.g_false
)
RETURN VARCHAR2
IS
   L_CITY_PROFILE    CONSTANT VARCHAR2(30) := 'AMS_SRCGEN_USER_CITY';
   L_DATE_PROFILE    CONSTANT VARCHAR2(30) := 'AMS_SRCGEN_DATE_PATTERN';
   L_USER_GEO_TYPE   CONSTANT VARCHAR2(30) := 'CITY';
   MAX_GEO_LENGTH    CONSTANT NUMBER := 5;
   MAX_CUST_LENGTH   CONSTANT NUMBER := 5;
   MAX_DATE_LENGTH   CONSTANT NUMBER := 6;

   l_geo_code     VARCHAR2(10);
   l_date_code    VARCHAR2(10);
   l_num_code     VARCHAR2(10);
   l_cust_code    VARCHAR2(10);

   l_loc_hierarchy_id   NUMBER;
   l_date_pattern       VARCHAR2(30);
   l_sequence_length    NUMBER;
   l_sequence_code      VARCHAR2(10);
   l_target_area_type   VARCHAR2(30) := 'AREA2';

   l_source_code  VARCHAR2(30);

   l_exit_flag       NUMBER;

   CURSOR c_geo_code (p_global_flag IN VARCHAR2, p_loc_hierarchy_id IN NUMBER) IS
--    Following one line is changed by ptendulk on 30-Aug-2000 to support
--    the global flag
--    SELECT DECODE (p_global_flag, FND_API.g_true, area1_code, area2_code)
      SELECT DECODE (p_global_flag, 'Y', area1_code, area2_code)
      FROM jtf_loc_hierarchies_vl
      WHERE location_hierarchy_id = p_loc_hierarchy_id
      ;

   CURSOR c_custom_setup (p_id NUMBER) IS
      SELECT cte.source_code_suffix
      FROM   ams_custom_setups_vl cte
      WHERE  cte.custom_setup_id = p_id
      ;
BEGIN
   -------------------------------------------------
   -- Source Code consists of the following pattern:
   --    AAAMMYY999CUST
   -------------------------------------------------

   -- Need to validate that the code returned in
   -- profiles is a number
   BEGIN
      --
      -- Pattern: AAA
      -- User's geographic code
      l_loc_hierarchy_id := TO_NUMBER (FND_PROFILE.value (L_CITY_PROFILE));

      -- Use AREA1 if the object is global
      OPEN c_geo_code (p_global_flag, l_loc_hierarchy_id);
      FETCH c_geo_code INTO l_geo_code;
      CLOSE c_geo_code;
      -- strip out the spaces
      l_geo_code := UPPER (SUBSTR (REPLACE (l_geo_code, ' '), 1, MAX_GEO_LENGTH));
   EXCEPTION
	 WHEN VALUE_ERROR THEN
         l_geo_code := NULL;
   END;

   --
   -- Pattern: MMYY
   -- Date pattern used to denote month and year
   l_date_pattern := FND_PROFILE.value (L_DATE_PROFILE);

   --
   -- choang - 18-May-2000
   -- Added additional error handling for missing date
   -- format and invalid date format.
   IF l_date_pattern IS NULL OR l_date_pattern = '' THEN
      AMS_Utility_PVT.error_message ('AMS_SRCGEN_NO_DATE_PATTERN');
      RAISE FND_API.g_exc_error;
   ELSIF LENGTH (l_date_pattern) > MAX_DATE_LENGTH THEN
      AMS_Utility_PVT.error_message ('AMS_SRCGEN_DATE_TOO_LONG');
      RAISE FND_API.g_exc_error;
   END IF;

   BEGIN
      l_date_code := TO_CHAR (SYSDATE, l_date_pattern);
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -1821 THEN -- date format not recognized
            AMS_Utility_PVT.error_message ('AMS_SRCGEN_BAD_DATE_PATTERN');
            RAISE FND_API.g_exc_error;
         END IF;
   END;

   --
   -- Pattern: CUST
   -- Custom setup code
   OPEN c_custom_setup (p_custsetup_id);
   FETCH c_custom_setup INTO l_cust_code;
   CLOSE c_custom_setup;
   l_cust_code := UPPER (SUBSTR (REPLACE (l_cust_code, ' '), 1, MAX_CUST_LENGTH)); -- strip out the spaces.

   --
   -- Pattern: 999
   -- Numeric sequence generated for a combination
   -- of AAAMMYYCUST.
   l_sequence_code := get_unique_sequence (l_geo_code, l_date_code, l_cust_code);

   l_source_code := l_geo_code || l_date_code || l_sequence_code || l_cust_code;
   RETURN l_source_code;
EXCEPTION
   WHEN OTHERS THEN
      IF c_geo_code%ISOPEN THEN
         CLOSE c_geo_code;
      END IF;
      IF c_custom_setup%ISOPEN THEN
         CLOSE c_custom_setup;
      END IF;
      RAISE;
END get_new_source_code;


-----------------------------------------------------------------
-- FUNCTION
--    get_source_code(p_arc_object, p_type_code)
-----------------------------------------------------------------
FUNCTION get_source_code(
   p_arc_object  IN VARCHAR2,
   p_type_code   IN VARCHAR2
)
RETURN VARCHAR2 IS

   l_source_code  VARCHAR2(30);
   l_lookup_type  VARCHAR2(30);
   l_prefix       VARCHAR2(30);
   l_code         VARCHAR2(30);
   l_dummy        NUMBER;

   CURSOR c_seq IS
   SELECT TO_CHAR(ams_source_codes_gen_s.NEXTVAL)
     FROM DUAL;

   CURSOR c_prefix IS
   SELECT tag
     FROM ams_lookups
    WHERE lookup_type = l_lookup_type
      AND lookup_code = p_type_code;

BEGIN

   IF p_arc_object = 'CAMP' THEN
      l_lookup_type := 'AMS_CAMPAIGN_PURPOSE';
   ELSIF p_arc_object = 'EVEH' THEN
      l_lookup_type := 'AMS_EVENT_TYPE';
   ELSIF p_arc_object = 'OFFR' THEN
      l_lookup_type := 'AMS_OFFER_TYPE';
   ELSE
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
   END IF;

   IF p_type_code IS NULL THEN
      l_prefix := p_arc_object;
   ELSE
      OPEN c_prefix;
      FETCH c_prefix INTO l_prefix;
      CLOSE c_prefix;

      IF l_prefix IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_SCG_BAD_TYPE_CODE');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   LOOP
      OPEN c_seq;
      FETCH c_seq INTO l_code;
      CLOSE c_seq;

      l_source_code := l_prefix || l_code;
      EXIT WHEN is_source_code_unique(l_source_code) = FND_API.g_true;
   END LOOP;

   RETURN l_source_code;

END;


-----------------------------------------------------------------
-- FUNCTION
--    get_source_code(p_parent_id, p_arc_object)
-----------------------------------------------------------------
FUNCTION get_source_code(
   p_parent_id   IN NUMBER,
   p_arc_object  IN VARCHAR2
)
RETURN VARCHAR2 IS

   l_prefix   VARCHAR2(30);
   l_type     VARCHAR2(30);
   l_code     VARCHAR2(30);
   l_dummy    NUMBER;

   CURSOR c_camp IS
   SELECT campaign_type
     FROM ams_campaigns_vl
    WHERE campaign_id = p_parent_id;

   CURSOR c_eveh IS
   SELECT event_type_code
     FROM ams_event_headers_vl
    WHERE event_header_id = p_parent_id;

BEGIN

   IF p_arc_object = 'CSCH' THEN
      OPEN c_camp;
      FETCH c_camp INTO l_type;
      IF c_camp%NOTFOUND THEN
         CLOSE c_camp;
         AMS_Utility_PVT.error_message('AMS_SCG_BAD_PARENT_ID');
         RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_camp;
      RETURN get_source_code('CAMP', l_type);
   ELSIF p_arc_object = 'EVEO' THEN
      OPEN c_eveh;
      FETCH c_eveh INTO l_type;
      IF c_eveh%NOTFOUND THEN
         CLOSE c_eveh;
         AMS_Utility_PVT.error_message('AMS_SCG_BAD_PARENT_ID');
         RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_eveh;
      RETURN get_source_code('EVEH', l_type);
   ELSE
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
   END IF;

END;

-----------------------------------------------------------------
-- FUNCTION
-- Added by MPANDE 02/16/2001
--    get_source_code(p_category_id, p_arc_object_from)
-----------------------------------------------------------------
FUNCTION get_source_code(
   p_category_id   IN NUMBER,
   p_arc_object_for  IN VARCHAR2
)
RETURN VARCHAR2 IS

   l_prefix   VARCHAR2(30);
   l_code     VARCHAR2(30);
   -- change the cursor to ponit to ams_categories_vl table 03/05/2001
   CURSOR c_suffix IS
   SELECT budget_code_suffix
     FROM ams_categories_vl
    WHERE category_id = p_category_id;

BEGIN

      OPEN c_suffix;
      FETCH c_suffix INTO l_prefix;
      CLOSE c_suffix;
      RETURN l_prefix||get_source_code();

END get_source_code;

-----------------------------------------------------------------
-- FUNCTION
--    get_source_code
-----------------------------------------------------------------
FUNCTION get_source_code RETURN VARCHAR2 IS

   l_code VARCHAR2(30);

   CURSOR c_seq IS
   SELECT TO_CHAR(ams_source_codes_gen_s.NEXTVAL)
     FROM DUAL;

BEGIN

   LOOP
      OPEN c_seq;
      FETCH c_seq INTO l_code;
      CLOSE c_seq;
      EXIT WHEN is_source_code_unique(l_code) = FND_API.g_true;
   END LOOP;
   RETURN l_code;

END get_source_code;

-----------------------------------------------------------------
-- PROCEDURE
--    create_sourcecode
-----------------------------------------------------------------
PROCEDURE create_sourcecode(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sourcecode            IN  VARCHAR2,
   p_sourcecode_for	       IN   VARCHAR2,
   p_sourcecode_for_id     IN   NUMBER,
   p_related_sourcecode    IN  VARCHAR2 := NULL,
   p_releated_sourceobj    IN  VARCHAR2 := NULL,
   p_related_sourceid      IN  NUMBER := NULL,
   x_sourcecode_id         OUT NOCOPY   NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_sourcecode';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_source_code IS
   SELECT source_code_id, active_flag
     FROM ams_source_codes
    WHERE source_code = p_sourcecode;

    CURSOR c_active_object IS
   SELECT 'x'
     FROM ams_source_codes
    WHERE arc_source_code_for  = p_sourcecode_for
           AND source_code_for_id = p_sourcecode_for_id
	   AND active_flag = 'Y';

   CURSOR c_sourcecode_seq IS
   SELECT AMS_SOURCE_CODES_S.NEXTVAL
     FROM DUAL;

   CURSOR c_related_source_code IS
   SELECT 1
   FROM   ams_source_codes
   WHERE  source_code = p_related_sourcecode;

   l_return_status  VARCHAR2(1);
   l_sc_active_flag  varchar2(1) := 'Y';
   l_sourcecode_id  NUMBER;
   l_active_flag   varchar2(1) := 'Y';
   l_dummy_char varchar2(1);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_sourcecode;

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
      NULL;
      --RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   -- check arc object
    -- FOllowing line is modified by rrajesh on 02/02/02 to add a new object DILG.
    --IF p_sourcecode_for   not  in ( 'CAMP', 'CSCH', 'OFFR', 'EVEH', 'EVEO','EONE')
    IF p_sourcecode_for   not  in ( 'CAMP', 'CSCH', 'OFFR', 'EVEH', 'EVEO','EONE', 'DILG')
     THEN
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
    END IF;
/* 12-APR-2001  julou  removed validation as Nari requested
    -- 10-APR-2001  julou  added validation for related source
    -- validate related source code

    -- check arc obj for related source code
    IF p_releated_sourceobj NOT IN ( 'CAMP', 'CSCH', 'OFFR', 'EVEH', 'EVEO','EONE')
     THEN
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
    END IF;

    -- check the existense of related source code
    IF p_related_sourcecode IS NOT NULL THEN
      OPEN c_related_source_code;
      FETCH c_related_source_code INTO l_dummy_char;
      IF c_related_source_code%NOTFOUND THEN
        CLOSE c_related_source_code;
        AMS_UTILITY_PVT.error_message('AMS_RELATE_SRC_CODE_NOT_FOUND');
        RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_related_source_code;
    END IF;
    -- end of the added by julou
*/
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': check if source code for object is already active');
  END IF;

  open c_active_object;
  fetch c_active_object into l_dummy_char;
  if c_active_object%found
  then
           close c_active_object;
         -- raise an error  The object already uses a valid source code.
        AMS_UTILITY_PVT.error_message('AMS_OBJECT_CODE_ACTIVE');
        RAISE FND_API.g_exc_error ;
 end if;
close c_active_object;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name ||': check uniqueness');

  END IF;

if  is_source_code_unique(p_sourcecode) = FND_API.g_true
then
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_Utility_PVT.debug_message(l_full_name ||': insert source code');
	END IF;

	-- fetch the source code id
	open c_sourcecode_seq;
	fetch c_sourcecode_seq into l_sourcecode_id;
	close c_sourcecode_seq;

	 -- insert source code
	insert into AMS_SOURCE_CODES (
	  SOURCE_CODE_ID,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_LOGIN,
	  OBJECT_VERSION_NUMBER,
	  SOURCE_CODE,
	  SOURCE_CODE_FOR_ID,
	  ARC_SOURCE_CODE_FOR,
	  ACTIVE_FLAG
    ,RELATED_SOURCE_CODE
    ,RELATED_SOURCE_OBJECT
    ,RELATED_SOURCE_ID)
	values (
	  l_sourcecode_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         FND_GLOBAL.conc_login_id,
         1,  -- object_version_number,
	 p_sourcecode,
	 p_sourcecode_for_id,
	 p_sourcecode_for,
	 l_active_flag
   ,p_related_sourcecode
   ,p_releated_sourceobj
   ,p_related_sourceid
	);
	x_sourcecode_id := l_sourcecode_id;
else
      -- if the source code is not unique then check if it is active
	open c_source_code;
	fetch c_source_code into  l_sourcecode_id, l_sc_active_flag;
	close c_source_code;
	if l_sc_active_flag = 'N'
       then
       -- if the source is cancelled then modify it
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message(l_full_name ||': modifying source code');
          END IF;
          modify_sourcecode(
            p_source_code    =>  p_sourcecode,
            p_object_type       =>  p_sourcecode_for,
            p_object_id	   =>  p_sourcecode_for_id,
            p_sourcecode_id => l_sourcecode_id,
            p_related_sourcecode => p_related_sourcecode,
            p_releated_sourceobj => p_releated_sourceobj,
            p_related_sourceid => p_related_sourceid,
            x_return_status    =>  l_return_status
           ) ;
         IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
         END IF;
     elsif   l_sc_active_flag = 'Y'
     then
         -- raise an error  The source code is already being used.
        AMS_UTILITY_PVT.error_message('AMS_DUPLICATE_SOURCE_CODE');
        RAISE FND_API.g_exc_error;
    end if;
end if;


  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_sourcecode;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_sourcecode;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_sourcecode;
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

  END create_sourcecode;


 -----------------------------------------------------------------
-- PROCEDURE
--    revoke_sourcecode
-----------------------------------------------------------------
 PROCEDURE revoke_sourcecode(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sourcecode                IN  VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'revoke_source_code';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status  VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT revoke_sourcecode;

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

   x_return_status := FND_API.g_ret_sts_success;

  update AMS_SOURCE_CODES
  set        active_flag = 'N',
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
  where   SOURCE_CODE = p_sourcecode;

      IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO revoke_sourcecode;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO revoke_sourcecode;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO revoke_sourcecode;
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

END revoke_sourcecode;


 -----------------------------------------------------------------
-- PROCEDURE
--    modify_sourcecode
-----------------------------------------------------------------
PROCEDURE modify_sourcecode(
  p_source_code                IN  VARCHAR2,
  p_object_type                 IN  VARCHAR2,
  p_object_id		     IN   NUMBER,
  p_sourcecode_id          IN NUMBER,
  p_related_sourcecode    IN  VARCHAR2 := NULL,
  p_releated_sourceobj    IN  VARCHAR2 := NULL,
  p_related_sourceid      IN  NUMBER   := NULL,

  x_return_status     OUT NOCOPY VARCHAR2
)
IS

  l_return_status  VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------

 x_return_status := FND_API.g_ret_sts_success;

 IF (AMS_DEBUG_HIGH_ON) THEN



 AMS_Utility_PVT.debug_message(' modifying source code record');

 END IF;

  update AMS_SOURCE_CODES
  set        ARC_SOURCE_CODE_FOR  = p_object_type,
               SOURCE_CODE_FOR_ID = p_object_id,
	       OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	       ACTIVE_FLAG = 'Y'
         ,RELATED_SOURCE_CODE = p_related_sourcecode
         ,RELATED_SOURCE_OBJECT = p_releated_sourceobj
         ,RELATED_SOURCE_ID = p_related_sourceid
  where  SOURCE_CODE_ID = p_sourcecode_id;

     IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

 IF (AMS_DEBUG_HIGH_ON) THEN



 AMS_Utility_PVT.debug_message(' modify source code end ');

 END IF;


END modify_sourcecode;


FUNCTION get_unique_sequence (
   p_geo_code IN VARCHAR2,
   p_date_code IN VARCHAR2,
   p_cust_code IN VARCHAR2
)
RETURN VARCHAR2
IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   L_LENGTH_PROFILE  CONSTANT VARCHAR2(30) := 'AMS_SRCGEN_SEQUENCE_LENGTH';
   MIN_SEQUENCE_LENGTH  CONSTANT NUMBER := 1;
   MAX_SEQUENCE_LENGTH  CONSTANT NUMBER := 10;

   l_sequence_length    NUMBER;
   l_sequence_value     NUMBER;
   l_sequence_code      VARCHAR2(10);
   l_number_format      VARCHAR2(30) := '0';
   l_code_chars         VARCHAR2(30);
   l_source_code        VARCHAR2(30);

   l_ref_sequence    NUMBER;  -- reference number used to determine if sequences exhausted

   CURSOR c_sequence_value (x_code_key VARCHAR2) IS
      SELECT gde.scode_number_element
      FROM   ams_generated_codes gde
      WHERE gde.scode_char_element = x_code_key
      FOR UPDATE
      ;
BEGIN
   l_sequence_length := TO_NUMBER (FND_PROFILE.value (L_LENGTH_PROFILE));
   l_code_chars := p_geo_code || p_date_code || p_cust_code;

   --
   -- choang - 18-May-2000
   -- Added error handling for sequence_length.
   IF l_sequence_length IS NULL THEN
      AMS_Utility_PVT.error_message ('AMS_SRCGEN_NO_NUMBER_SIZE');
      RAISE FND_API.g_exc_error;
   END IF;
   IF l_sequence_length NOT BETWEEN MIN_SEQUENCE_LENGTH AND MAX_SEQUENCE_LENGTH THEN
      AMS_Utility_PVT.error_message ('AMS_SRCGEN_BAD_NUMBER_SIZE');
      RAISE FND_API.g_exc_error;
   END IF;

   -- Pad the number format with 9's
   -- if the number of digits is more
   -- than 2.
   FOR i IN 2..l_sequence_length LOOP
      l_number_format := l_number_format || '9';
   END LOOP;
   OPEN c_sequence_value (l_code_chars);
   FETCH c_sequence_value INTO l_sequence_value;
   CLOSE c_sequence_value;
   IF l_sequence_value IS NULL THEN
      l_sequence_value := 0;

      -- Create a generated code
      INSERT INTO ams_generated_codes (
         gen_code_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         object_version_number,
         scode_char_element,
         scode_number_element,
         arc_source_code_for
      ) VALUES (
         ams_source_codes_gen_s.NEXTVAL,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLObAL.user_id,
         FND_GLOBAL.conc_login_id,
         1,    -- object version number
         l_code_chars,
         0,
         'NONE'   -- Not generated for any specific object
      );

      COMMIT;
   ELSIF LENGTH (l_sequence_value) > l_sequence_length THEN
      l_sequence_value := MOD (l_sequence_value, POWER(10, l_sequence_length) - 1);
   END IF;

   -- exit loop only after a unique code is generated
   l_ref_sequence := l_sequence_value;
   LOOP
      l_sequence_value := MOD (l_sequence_value + 1, POWER(10, l_sequence_length) - 1);
      l_sequence_code := LTRIM (TO_CHAR (l_sequence_value, l_number_format));
      l_source_code := p_geo_code || p_date_code || l_sequence_code || p_cust_code;

      EXIT WHEN is_source_code_unique (l_source_code) = FND_API.g_true;

      --
      -- Loop through all possible sequences
      -- within the range of digits before
      -- giving an error message.
      IF l_ref_sequence = l_sequence_value THEN
         AMS_Utility_PVT.error_message ('AMS_SRCGEN_OUT_OF_NUMBERS');
         RAISE FND_API.g_exc_error;
      END IF;
   END LOOP;

   -- Update the generate code with the new
   -- upper limit of the numeric sequence.
   UPDATE ams_generated_codes gde
   SET    gde.scode_number_element = l_sequence_value
   WHERE  gde.scode_char_element = l_code_chars;

   COMMIT;

   RETURN l_sequence_code;
EXCEPTION
   WHEN OTHERS THEN
      IF c_sequence_value%ISOPEN THEN
         CLOSE c_sequence_value;
      END IF;
      RAISE;
END get_unique_sequence;


END AMS_SourceCode_PVT;

/
