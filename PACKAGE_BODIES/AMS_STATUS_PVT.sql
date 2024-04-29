--------------------------------------------------------
--  DDL for Package Body AMS_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_STATUS_PVT" as
/* $Header: amsvstsb.pls 115.7 2002/12/05 00:57:25 dbiswas ship $ */

--
-- NAME
--   AMS_STATUS_PVT
--
-- HISTORY
--   10/26/1999		   holiu        CREATED
--   11/19/1999		   ptendulk     MODIFIED for User Statuses
--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_STATUS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvstsb.pls';
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Debug mode
--g_debug boolean := FALSE;
--g_debug boolean := TRUE;

/***************************  PRIVATE ROUTINES  *********************************/

-----------------------------------------------------------
-- NAME
--    get_status_lookup_type
--
-- USAGE
--    Given the arc qualifier for a certain area such as
--    'PROM', RETURN the lookup type for the statuses
--    IN that area, such as 'AMS_CAMPAIGN_STATUS'.
--
--    RETURN NULL IF no corresponding lookup type.
--
-----------------------------------------------------------
FUNCTION get_status_lookup_type(p_arc_status_for IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   IF p_arc_status_for = 'CAMP' THEN
      RETURN 'AMS_CAMPAIGN_STATUS';
   ELSIF p_arc_status_for = 'CSCH' THEN
      RETURN 'AMS_CAMPAIGN_SCHEDULE_STATUS';
   ELSIF p_arc_status_for = 'EVEH' THEN
      RETURN 'AMS_EVENT_STATUS';
   ELSIF p_arc_status_for = 'EVEO' THEN
      RETURN 'AMS_EVENT_STATUS';
   ELSIF p_arc_status_for = 'DELV' THEN
      RETURN 'AMS_DELIV_STATUS';
   ELSE
      RETURN NULL;
   END IF;
END;


-----------------------------------------------------------
-- NAME
--    get_lookup_meaning
--
-- USAGE
--    Given the lookup type AND lookup code, get the meaning.
--    RETURN NULL IF invalid type or code provided.
--
-----------------------------------------------------------
FUNCTION get_lookup_meaning(
   p_lookup_type  IN VARCHAR2,
   p_lookup_code  IN VARCHAR2
)
RETURN VARCHAR2 IS

   l_meaning  VARCHAR2(80);

   CURSOR c_ams_lookups IS
   SELECT meaning
     FROM ams_lookups
    WHERE lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

BEGIN

   OPEN c_ams_lookups;
   FETCH c_ams_lookups INTO l_meaning;
   CLOSE c_ams_lookups;

   RETURN l_meaning;

END;


--------------- start of comments --------------------------
-- NAME
--    Is_Approval_Needed
--
-- USAGE
--    Check IF a certain type of approval IS needed for an
--    object area (AND activity type).
--
--------------- END of comments ----------------------------

FUNCTION Is_Approval_Needed(
   p_arc_approval_for    IN  VARCHAR2,
   p_approval_type       IN  VARCHAR2,
   p_activity_type_code  IN  VARCHAR2 := NULL
)
RETURN VARCHAR2 IS

   l_count NUMBER;

   CURSOR c_approval_rules IS
   SELECT count(*)
     FROM ams_approval_rules
    WHERE arc_approval_for_object = p_arc_approval_for
      AND approval_type = p_approval_type
      AND (activity_type_code = p_activity_type_code
          or activity_type_code IS NULL);

BEGIN

   OPEN c_approval_rules;
   FETCH c_approval_rules INTO l_count;
   CLOSE c_approval_rules;

   IF l_count > 0 THEN
      RETURN fnd_api.g_true;
   ELSE
      RETURN fnd_api.g_false;
   END IF;

END is_approval_needed;


---------------------- start of comments --------------------------
-- NAME
--    Get_Next_Statuses
--
-- USAGE
--    For a certain status IN an object area, RETURN all the
--    valid next statuses IN a PL/SQL table.
--
--    The client side may use it to populate list items.
--
----------------------- END of comments ----------------------------
PROCEDURE Get_Next_Statuses(
   p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_arc_status_for       IN  VARCHAR2,
   p_current_status_id    IN  NUMBER,
   p_activity_type_code   IN  VARCHAR2 := NULL,
   x_next_status_tbl      OUT NOCOPY next_status_tbl_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_system_stat IS
   SELECT system_status_code,system_status_type
   FROM   ams_user_statuses_vl
   WHERE  user_status_id = p_current_status_id ;

   CURSOR c_next_statuses(l_stat_code VARCHAR2,l_stat_type VARCHAR2) IS
   SELECT next_status_code
   FROM ams_status_order_rules
   WHERE current_status_code = l_stat_code
   AND   system_status_type  = l_stat_type
   AND   show_in_lov_flag = 'Y' ;

   CURSOR c_user_statuses(l_stat_code VARCHAR2,l_stat_type VARCHAR2) IS
   SELECT user_status_id,system_status_type,system_status_code,
          default_flag,name
   FROM   ams_user_statuses_vl
   WHERE  system_status_code = l_stat_code
   AND    system_status_type  = l_stat_type
   AND    start_date_active   < SYSDATE
   AND    (end_date_active IS NULL    OR
           end_date_active > SYSDATE) ;

   TYPE temp_status_tbl_type IS TABLE OF c_next_statuses%ROWTYPE
   INDEX BY BINARY_INTEGER;

   l_next_status_tbl  temp_status_tbl_type ;
   l_temp_status_rec  c_next_statuses%ROWTYPE;
   l_system_stat_code    VARCHAR2(30);
   l_system_stat_type    VARCHAR2(30);
   l_user_stat_rec       next_status_rec_type;

   l_index         BINARY_INTEGER;
   l_total         BINARY_INTEGER;

   l_approval_flag VARCHAR2(1);  -- fnd_api.g_true, fnd_api.g_false
   l_lookup_type   VARCHAR(30);
   l_api_name      CONSTANT VARCHAR2(30) := 'get_next_statuses';

BEGIN

   ----------------------- initialize -----------------------------
   x_return_status := fnd_api.g_ret_sts_success;

   l_lookup_type := get_status_lookup_type(p_arc_status_for);
   IF l_lookup_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('AMS', 'INVALID_ARC_QUALIFIER');
         fnd_message.set_token('ARG', p_arc_status_for, FALSE);
         fnd_msg_pub.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RETURN  ;
   END IF;

   --------------------- Get System Status Code --------------------
   OPEN  c_system_stat ;
   FETCH c_system_stat INTO l_system_stat_code,l_system_stat_type ;
   CLOSE c_system_stat ;

   --------------------- find next system statuses -----------------
   l_total := 0;

   OPEN c_next_statuses(l_system_stat_code,l_system_stat_type);
   LOOP
       FETCH c_next_statuses INTO l_temp_status_rec ;
       EXIT WHEN c_next_statuses%NOTFOUND ;
       l_next_status_tbl(l_total) := l_temp_status_rec ;
       l_total := l_total + 1 ;
   END LOOP;
   CLOSE c_next_statuses ;


--   OPEN c_next_statuses(l_system_stat_code,l_system_stat_type);
--   LOOP
--      FETCH c_next_statuses INTO l_temp_status_rec ;
--      EXIT WHEN c_next_statuses%NOTFOUND;
--      l_total := l_total + 1;
--      l_temp_status_tbl(l_total) := l_temp_status_rec;
--      IF l_temp_status_rec.approval_type IS NOT NULL THEN
--         l_index := l_total;
--      END IF;
--   END LOOP;
--
--   IF l_total = 0 THEN  -- no valid next status, e.g. 'ARCHIVED'
--      RETURN;
--   END IF;
--
--   IF l_index = 0 THEN  -- no approval needed
--      l_approval_flag := fnd_api.g_false;
--   ELSE
--      l_approval_flag := Is_Approval_Needed(
--            p_arc_status_for,
--            l_temp_status_tbl(l_index).approval_type,
--            p_activity_type_code
--      );
--   END IF;

-------------- Find Next System Statuses based on Approval Results -----------

--   l_index := 0;  -- the index for l_next_status_tbl
--   FOR i IN 1..l_total LOOP
--      IF (l_temp_status_tbl(i).no_approval_flag = 'Y'
--            AND l_approval_flag = fnd_api.g_false)
--         or (l_temp_status_tbl(i).approval_flag = 'Y'
--            AND l_approval_flag = fnd_api.g_true)
--      THEN
--         l_index := l_index + 1;
--         l_next_status_tbl(l_index) := l_temp_status_tbl(i);
--      END IF;
---   END LOOP;
--
------------------------- find User Statuses ---------------------------------
   l_index := 0;  -- the index for x_next_status_tbl
   FOR i IN 1..l_next_status_tbl.last
   LOOP
      OPEN  c_user_statuses(l_next_status_tbl(i).next_status_code,l_system_stat_type) ;
      LOOP
        FETCH c_user_statuses INTO l_user_stat_rec;
        EXIT WHEN c_user_statuses%NOTFOUND ;
        l_index := l_index + 1;
        x_next_status_tbl(l_index) := l_user_stat_rec ;
      END LOOP;
      CLOSE c_user_statuses ;
   END LOOP;


END get_next_statuses;


--------------- start of comments --------------------------
-- NAME
--    validate_status_change
--
-- USAGE
--    Check whether a status change IS valid or not.
--    Server side API may use it for validate status changes.
--
--------------- END of comments ----------------------------

PROCEDURE validate_status_change(
   p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_arc_status_for       IN  VARCHAR2,
   p_current_status_id    IN  VARCHAR2,
   p_next_status_id       IN  VARCHAR2,
   p_activity_type_code   IN  VARCHAR2 := NULL,
   x_valid_flag           OUT NOCOPY VARCHAR2,  -- fnd_api.g_true, fnd_api.g_false
   x_return_status        OUT NOCOPY VARCHAR2
)
IS

   l_temp_status_tbl  next_status_tbl_type;

   l_index         binary_integer;
   l_total         binary_integer;

   l_lookup_type   ams_lookups.lookup_type%type;
   l_api_name      constant VARCHAR2(30) := 'validate_status_change';

BEGIN

   x_return_status := fnd_api.g_ret_sts_success;
   x_valid_flag    := fnd_api.g_false;

   l_lookup_type := get_status_lookup_type(p_arc_status_for);
   IF l_lookup_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('AMS', 'INVALID_ARC_QUALIFIER');
         fnd_message.set_token('ARG', p_arc_status_for, FALSE);
         fnd_msg_pub.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RETURN  ;
   END IF;

   -- Get the Valid Next Statuses
   get_next_statuses(
       p_init_msg_list        => p_init_msg_list,
       x_msg_count            => x_msg_count,
       x_msg_data             => x_msg_data,
       p_arc_status_for       => p_arc_status_for,
       p_current_status_id    => p_current_status_id,
       p_activity_type_code   => p_activity_type_code,
       x_next_status_tbl      => l_temp_status_tbl,
       x_return_status        => x_return_status
                        );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
   END IF;

   FOR i IN 1..l_temp_status_tbl.last LOOP
      IF (l_temp_status_tbl(i).user_status_id = p_next_status_id)
      THEN
         x_valid_flag := fnd_api.g_true;
         RETURN;
      END IF;
   END LOOP;

END validate_status_change;

END AMS_STATUS_PVT;

/
