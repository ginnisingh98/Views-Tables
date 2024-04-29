--------------------------------------------------------
--  DDL for Package Body AMW_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_UTILITY_PVT" AS
/* $Header: amwvutlb.pls 120.6.12000000.4 2007/08/02 14:32:51 shelango ship $ */
-- HISTORY
-- 4/20/2003    mpande     Creates
---------------------------------------------------------------------

/* abedajna add begin */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_Utility_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwvutlb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
/* abedajna add end */

/** dliao add **/
g_initialize_log BOOLEAN :=FALSE;
g_session_id     NUMBER;
/** dliao add end **/

  -- Added for use by bind_parse.
  TYPE col_val_rec IS RECORD (
      col_name    VARCHAR2(2000),
      col_op      VARCHAR2(10),
      col_value   VARCHAR2(2000) );

  TYPE col_val_tbl IS TABLE OF col_val_rec INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--    bind_parse
--
-- DESCRIPTION
--    Given a string containing the WHERE conditions in a WHERE
--    clause, return a tuple of column name and column value.
-- HISTORY
-- 4/20/2003 mpande Created.
---------------------------------------------------------------------
AMW_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMW_DEBUG_LOW_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMW_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE bind_parse (
     p_string IN VARCHAR2,
     x_col_val_tbl OUT NOCOPY col_val_tbl
  );


---------------------------------------------------------------------
-- FUNCTION
--    check_fk_exists
--
-- HISTORY
--    4/20/2003  mpande  Created.
---------------------------------------------------------------------
FUNCTION check_fk_exists(
   p_table_name   IN VARCHAR2,
   p_pk_name      IN VARCHAR2,
   p_pk_value     IN VARCHAR2,
   p_pk_data_type IN NUMBER := g_number,
   p_additional_where_clause  IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN
   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || UPPER(p_table_name);
   l_sql := l_sql || ' WHERE ' || UPPER(p_pk_name) || ' = :b1';

   IF p_additional_where_clause IS NOT NULL THEN
      -- given time, incorporate bind_parse
      l_sql := l_sql || ' AND ' || p_additional_where_clause;
   END IF;

   l_sql := l_sql || ')';

   IF (AMW_DEBUG_HIGH_ON) THEN
      debug_message('SQL statement: '||l_sql);
   END IF;

   BEGIN
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_pk_value;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_fk_exists;


---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
-- HISTORY
--    4/20/2003  mpande  Created.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_amw_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN

  IF p_lookup_table_name = g_amw_lookups THEN
    return check_lookup_exists (
          p_lookup_type =>  p_lookup_type
        , p_lookup_code =>  p_lookup_code
        , p_view_application_id => 242
        );
  ELSE
    l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || p_lookup_table_name;
    l_sql := l_sql || ' WHERE LOOKUP_TYPE = :b1';
    l_sql := l_sql || ' AND LOOKUP_CODE = :b2';
    l_sql := l_sql || ' AND ENABLED_FLAG = ''Y'')';

    IF (AMW_DEBUG_HIGH_ON) THEN
       debug_message('SQL statement: '||l_sql);
    END IF;

    BEGIN
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_lookup_type, p_lookup_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
    END;
    IF l_count = 0 THEN
      RETURN FND_API.g_false;
    ELSE
      RETURN FND_API.g_true;
    END IF;
  END IF;

END check_lookup_exists;



---------------------------------------------------------------------
-- FUNCTION
--    overloaded check_lookup_exists
-- PURPOSE
--    This function checks if a lookup_code is valid from fnd_lookups when
--    view_application_id is passed in.
-- HISTORY
--   4/20/2003  mpande created.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2,
   p_view_application_id  IN  NUMBER
)
Return VARCHAR2
IS
  CURSOR cur_check_lookup_exists(  p_lookup_type VARCHAR2
                                 , p_lookup_code VARCHAR2
                                 , p_view_app_id NUMBER)  IS
      SELECT 1 FROM fnd_lookup_values lkup
        WHERE lkup.LOOKUP_TYPE = p_lookup_type
          AND lkup.LOOKUP_CODE = p_lookup_code
          AND lkup.view_application_id = p_view_app_id
          AND lkup.ENABLED_FLAG = 'Y'
          AND lkup.language = USERENV('LANG')
          AND lkup.security_group_id = to_number(decode(substrb(userenv('CLIENT_INFO'),55,1
                                                               ), ' ', '0'
                                                                 , NULL, '0'
                                                                 , substrb(userenv('CLIENT_INFO'),55,10
                                                                          )
                                                        )
                                                 );
    l_count NUMBER := 0;

BEGIN

  OPEN cur_check_lookup_exists(  p_lookup_type
                               , p_lookup_code
                               , p_view_application_id);
  FETCH cur_check_lookup_exists INTO l_count;
  CLOSE cur_check_lookup_exists;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_lookup_exists;


---------------------------------------------------------------------
-- FUNCTION
--    check_uniqueness
--
-- HISTORY
--   4/20/2003 mpande  Created.
---------------------------------------------------------------------
FUNCTION check_uniqueness(
   p_table_name    IN VARCHAR2,
   p_where_clause  IN VARCHAR2
)
RETURN VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

   l_bind_tbl  col_val_tbl;

BEGIN

   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || UPPER(p_table_name);
--   l_sql := l_sql || ' WHERE ' || p_where_clause;

   bind_parse (p_where_clause, l_bind_tbl);

   --
   -- Support up to 4 WHERE conditions for uniqueness.  If
   -- the number of conditions changes, then must also revise
   -- the execute portion of the code.
   IF l_bind_tbl.COUNT <= 4 THEN
      l_sql := l_sql || ' WHERE ' || l_bind_tbl(1).col_name || ' ' || l_bind_tbl(1).col_op || ' :b1';
      FOR i IN 2..l_bind_tbl.COUNT LOOP
         l_sql := l_sql || ' AND ' || l_bind_tbl(i).col_name || ' ' || l_bind_tbl(i).col_op || ' :b' || i;
      END LOOP;
   ELSE
      -- Exceeded the number of conditions supported
      -- for bind variables.
      l_sql := l_sql || ' WHERE ' || p_where_clause;
   END IF;

   l_sql := l_sql || ')';

   IF (AMW_DEBUG_HIGH_ON) THEN
      debug_message('SQL statement: '||l_sql);
   END IF;


   BEGIN
      IF l_bind_tbl.COUNT = 1 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value;
      ELSIF l_bind_tbl.COUNT = 2 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value;
      ELSIF l_bind_tbl.COUNT = 3 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value;
      ELSIF l_bind_tbl.COUNT = 4 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value, l_bind_tbl(4).col_value;
      ELSE
         EXECUTE IMMEDIATE l_sql INTO l_count;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;

END check_uniqueness;


---------------------------------------------------------------------
-- FUNCTION
--    is_Y_or_N
--
-- HISTORY
--   4/20/2003  mpande  Created.
---------------------------------------------------------------------
FUNCTION is_Y_or_N(
   p_value IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
   IF p_value = 'Y' or p_value = 'N' THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;
END is_Y_or_N;


---------------------------------------------------------------------
-- PROCEDURE
--    debug_message
--
-- HISTORY
--  4/20/2003   mpande    Created.
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := NULL
)
IS
BEGIN
   IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH) THEN
      FND_MESSAGE.set_name('AMW', 'AMW_API_DEBUG_MESSAGE');
      FND_MESSAGE.set_token('TEXT', REPLACE (p_message_text, FND_API.G_MISS_CHAR, 'G_MISS_CHAR'));
      FND_MSG_PUB.add;
   END IF;
END debug_message;


---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
-- HISTORY
--    4/20/2003  mpande  Created.
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
)
IS
BEGIN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMW', p_message_name);
      IF p_token_name IS NOT NULL THEN
         FND_MESSAGE.set_token(p_token_name, p_token_value, TRUE);
      END IF;
      FND_MSG_PUB.add;
   END IF;
END error_message;


---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
--
-- HISTORY
--    4/20/2003  mpande  Created.
---------------------------------------------------------------------
PROCEDURE display_messages
IS
   l_count  NUMBER;
   l_msg    VARCHAR2(2000);
BEGIN
   l_count := FND_MSG_PUB.count_msg;
   FOR i IN 1 .. l_count LOOP
      l_msg := FND_MSG_PUB.get(i, FND_API.g_false);
--      DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
   END LOOP;
END display_messages;



---------------------------------------------------------------------
-- PROCEDURE
--    bind_parse
-- USAGE
--    bind_parse (varchar2, col_val_tbl);
--    The input string must have a space between the AND and operator clause
--    and it must exclude the initial WHERE/AND statement.
--    Example: source_code = 'xyz' and campaign_id <> 1
---------------------------------------------------------------------
PROCEDURE bind_parse (
   p_string IN VARCHAR2,
   x_col_val_tbl OUT NOCOPY col_val_tbl)
IS
   l_new_str   VARCHAR2(4000);
   l_str       VARCHAR2(4000) := p_string;
   l_curr_pos  NUMBER;  -- the position index of the operator string
   l_eq_pos    NUMBER;
   l_not_pos   NUMBER;
   l_and_pos   NUMBER;
   i         NUMBER := 1;
BEGIN
   LOOP
      l_and_pos := INSTR (UPPER (l_str), ' AND ');
      -- handle condition where no more AND's are
      -- left -- usually if only one condition or
      -- the last condition in the WHERE clause.
      IF l_and_pos = 0 THEN
         l_new_str := l_str;
      ELSE
         l_new_str := SUBSTR (l_str, 1, l_and_pos - 1);
      END IF;

      --
      -- The operator should also be passed
      -- back to the calling program.
      l_eq_pos := INSTR (l_new_str, '=');
      l_not_pos := INSTR (l_new_str, '<>');
      --
      -----------------------------------
      -- operator    equal    not equal
      -- error       0        0
      -- =           1        0
      -- <>          0        1
      -- =           1        2
      -- <>          2        1
      -----------------------------------
      IF l_eq_pos = 0 AND l_not_pos = 0 THEN
         -- Could not find either an = or an <>
         -- operator.
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('AMW', 'AMW_UTIL_NO_WHERE_OPERATOR');
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      ELSIF l_eq_pos > 0 AND l_not_pos = 0 THEN
         l_curr_pos := l_eq_pos;
         x_col_val_tbl(i).col_op := '=';
      ELSIF l_not_pos > 0 AND l_eq_pos = 0 THEN
         l_curr_pos := l_not_pos;
         x_col_val_tbl(i).col_op := '<>';
      ELSIF l_eq_pos < l_not_pos THEN
         l_curr_pos := l_eq_pos;
         x_col_val_tbl(i).col_op := '=';
      ELSE
         l_curr_pos := l_not_pos;
         x_col_val_tbl(i).col_op := '<>';
      END IF;

      x_col_val_tbl(i).col_name := UPPER (LTRIM (RTRIM (SUBSTR (l_new_str, 1, l_curr_pos - 1))));
      -- Add 2 to the current position for '<>'.
      x_col_val_tbl(i).col_value := LTRIM (RTRIM (SUBSTR (l_new_str, l_curr_pos + 2)));
      --
      -- Remove the single quotes from the begin and end of the string value;
      -- no action if a numeric value.
      IF INSTR (x_col_val_tbl(i).col_value, '''', 1) = 1 THEN
         x_col_val_tbl(i).col_value := SUBSTR (x_col_val_tbl(i).col_value,2);
         x_col_val_tbl(i).col_value := SUBSTR (x_col_val_tbl(i).col_value, 1, LENGTH(x_col_val_tbl(i).col_value) - 1);
      END IF;

      IF l_and_pos = 0 THEN
         EXIT; -- no more to parse
      END IF;

      l_str := SUBSTR (l_str, l_and_pos + 4);
      i := i + 1;
   END LOOP;
END bind_parse;

-------------------------------------------------------------------------------
-- Start of Comments
-- NAME
--   Get_Person_Role
--
-- PURPOSE
--   This Procedure will be return the User role for
--   the userid sent
-- Called By
-- NOTES
-- HISTORY
--   11/17/2003        MUMU PANDE        CREATION
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_person_Role(
   p_person_id            IN     NUMBER,
   x_role_name          OUT NOCOPY    VARCHAR2,
   x_role_display_name  OUT NOCOPY    VARCHAR2 ,
   x_return_status      OUT NOCOPY    VARCHAR2) IS
l_employee_id   FND_USER.EMPLOYEE_ID%TYPE ;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Pass the Employee Id (which is Person Id) to get the Role
   WF_DIRECTORY.getrolename(
      p_orig_system      => 'PER',
      p_orig_system_id   => p_person_id ,
      p_name         => x_role_name,
      p_display_name      => x_role_display_name );

   IF x_role_name is null   then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('AMW','AMW_APPR_INVALID_ROLE');
      FND_MSG_PUB.Add;
   END IF;
END Get_person_Role;



--======================================================================
-- Procedure Name: send_wf_standalone_message
-- Type          : Generic utility
-- Pre-Req :
-- Notes:
--    Common utility to send standalone message without initiating
--    process using workflow.
-- Parameters:
--    IN:
--    p_item_type          IN  VARCHAR2   Required   Default =  "AMWGUTIL"
--                               item type for the workflow utility.
--    p_message_name       IN  VARCHAR2   Required   Default =  "GEN_STDLN_MESG"
--                               Internal name for standalone message name
--    p_subject            IN  VARCHAR2   Required
--                             Subject for the message
--    p_body               IN  VARCHAR2   Optional
--                             Body for the message
--    p_send_to_role_name  IN  VARCHAR2   Optional
--                             Role name to whom message is to be sent.
--                             Instead of this, one can send even p_send_to_res_id
--    p_send_to_person_id     IN   NUMBER   Optional
--                             Person Id that will be used to get role name from WF_DIRECTORY.
--                             This is required if role name is not passed.

--   OUT:
--    x_notif_id           OUT  NUMBER
--                             Notification Id created that is being sent to recipient.
--    x_return_status      OUT   VARCHAR2
--                             Return status. If it is error, messages will be put in mesg pub.
-- History:
-- 4/20/2003 mpande        Created.
--======================================================================

PROCEDURE send_wf_standalone_message(
   p_item_type          IN       VARCHAR2 := 'AMWGUTIL'
  ,p_message_name       IN       VARCHAR2 := 'GEN_STDLN_MESG'
  ,p_subject            IN       VARCHAR2
  ,p_body               IN       VARCHAR2 := NULL
  ,p_send_to_role_name  IN       VARCHAR2  := NULL
  ,p_send_to_person_id     IN       NUMBER := NULL
  ,x_notif_id           OUT NOCOPY      NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
  l_role_name           VARCHAR2(100) := p_send_to_role_name;
  l_display_role_name   VARCHAR2(240);
  l_notif_id            NUMBER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_send_to_role_name IS NULL THEN

      AMW_UTILITY_PVT.get_person_role
      (  p_person_id   =>    p_send_to_person_id,
         x_role_name     =>    l_role_name,
         x_role_display_name  => l_display_role_name,
         x_return_status   => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         return;
      END IF;
   END IF;
   l_notif_id := WF_NOTIFICATION.Send
                           (  role => l_role_name
                            , msg_type => p_item_type
                            , msg_name => p_message_name
                           );
   WF_NOTIFICATION.SetAttrText(  l_notif_id
                               , 'GEN_MSG_SUBJECT'
                               , p_subject
                              );
   WF_NOTIFICATION.SetAttrText(  l_notif_id
                               , 'GEN_MSG_BODY'
                               , p_body
                              );
   WF_NOTIFICATION.SetAttrText(  l_notif_id
                               , 'GEN_MSG_SEND_TO'
                               , l_role_name
                              );
   WF_NOTIFICATION.Denormalize_Notification(l_notif_id);
   x_notif_id := l_notif_id;
END send_wf_standalone_message;


---------------------------------------------------------------------
-- FUNCTION
--    Find_Hierarchy_Level
-- PURPOSE
--    This function returns the level in hierarchy of an entity
--    to be displayed on the HGrid
-- HISTORY
--   4/23/2003  abedajna created.
---------------------------------------------------------------------
FUNCTION Find_Hierarchy_Level(
   entity_name        IN VARCHAR2
)
Return number
IS
Hier_Level number;
BEGIN
	begin
   /* mpande commented
	select HLevel
	into Hier_Level
	from AMW_HIERARCHY_LEVELS_V
	where Process_Name = entity_name;
	exception
		when others then
		Hier_Level := null;
      */
      NULL;
	end;

return Hier_Level;

END Find_Hierarchy_Level;

---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
-- USAGE
--    Example:
--       SELECT AMw_Utility_PVT.get_lookup_meaning ('AMS_RISK_STATUS', status_code)
--       FROM   amw ....;
-- HISTORY
-- 6/4/2003 mpande   Created.
---------------------------------------------------------------------
FUNCTION get_lookup_meaning (
   p_lookup_type IN VARCHAR2,
   p_lookup_code IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning   VARCHAR2(80);

   CURSOR c_meaning IS
      SELECT meaning
      FROM   amw_lookups
      WHERE  lookup_type = UPPER (p_lookup_type)
      AND    lookup_code = UPPER (p_lookup_code);
BEGIN
   OPEN c_meaning;
   FETCH c_meaning INTO l_meaning;
   CLOSE c_meaning;

   RETURN l_meaning;
END get_lookup_meaning;


---------------------------------------------------------------------
-- FUNCTION
--    get_employess_name
-- USAGE
--    Example:
--       SELECT AMW_Utility_PVT.get_employee_name (party_id)
--       FROM   dual
-- HISTORY
-- 6/19/2003 mpande  Created.
---------------------------------------------------------------------
FUNCTION get_employee_name (
   p_party_id IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_name   VARCHAR2(360);

   CURSOR c_employee_name IS
      SELECT full_name
      FROM   amw_employees_current_v
      WHERE  party_id = p_party_id;
BEGIN
   IF p_party_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_employee_name;
   FETCH c_employee_name INTO l_name;
   CLOSE c_employee_name;

   RETURN l_name;
END get_employee_name;


FUNCTION GET_LOOKUP_VALUE(p_lookup_type  in  varchar2,
                          p_lookup_code  in varchar2) return varchar2 is
l_meaning   varchar2(80);
begin
   select meaning
   into   l_meaning
   from   amw_lookups
   where  lookup_type = p_lookup_type
   and    lookup_code = p_lookup_code;

   return   l_meaning;
exception
    when no_data_found then
        return null;
    when others then
        return null;
end;



---------------------------------------------------------------------
-- PROCEDURE
--    wait_for_req
-- USAGE
-- PL/SQL wrapper package over FND_CONCURRENT.WAIT_FOR_REQUEST that
-- follows api calling from java standards
-- HISTORY
-- 8/22/2003 ABEDAJNA  Created.
---------------------------------------------------------------------

procedure wait_for_req (
p_request_id			IN NUMBER,
p_interval			IN number,
p_max_wait			IN number,
p_phase				OUT nocopy varchar2,
p_status			OUT nocopy varchar2,
p_dev_phase			OUT nocopy varchar2,
p_dev_status			OUT nocopy varchar2,
p_message			OUT nocopy varchar2,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'wait_for_req';
wait boolean;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

wait := FND_CONCURRENT.WAIT_FOR_REQUEST(p_request_id, p_interval, p_max_wait, p_phase, p_status, p_dev_phase, p_dev_status, p_message);

exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end wait_for_req;



---------------------------------------------------------------------
-- PROCEDURE
--    get_lob_meaning
-- HISTORY
-- 9/16/2003 ABEDAJNA  Created.
---------------------------------------------------------------------

FUNCTION get_lob_meaning(p_lob_name  in varchar2) return varchar2 is
l_lob_desc   varchar2(240);
begin
	select ffvt.description
	into l_lob_desc
	from
	 fnd_id_flex_structures fft,
	 fnd_segment_attribute_values fsav,
	 fnd_id_flex_segments seg,
	 fnd_flex_values ffv,
	 fnd_flex_values_tl ffvt
	where fft.application_id = 450
	and fft.id_flex_code = 'FII#'
	and fft.id_flex_structure_code = 'DBI_DEFAULT_STRUCTURE'
	and fsav.application_id = 450
	and fsav.id_flex_code = 'FII#'
	and fsav.id_flex_num = fft.id_flex_num
	and fsav.segment_attribute_type = 'FII_LOB'
	and fsav.attribute_value = 'Y'
	and seg.application_id=450
	and seg.id_flex_code='FII#'
	and seg.id_flex_num = fft.id_flex_num
	and seg.application_column_name=fsav.application_column_name
	and seg.flex_value_set_id = ffv.flex_value_set_id
	and ffv.summary_flag = 'N'
	and ffv.flex_value_id  = ffvt.flex_value_id
	and ffvt.language=userenv('LANG')
	and ffvt.flex_value_meaning = p_lob_name;

	return   l_lob_desc;
exception
    when no_data_found then
        return null;
    when others then
        return null;
end;





---------------------------------------------------------------------
-- PROCEDURE
--    get_process_name
-- HISTORY
-- 11/25/2003 ABEDAJNA  Created.
---------------------------------------------------------------------


FUNCTION get_process_name(p_process_id  in number) return varchar2 is
l_process_name   varchar2(240);
begin
	select watl.display_name into l_process_name
	from wf_activities_tl watl, wf_activities wa, amw_process ap
	where ap.process_id = p_process_id
	and ap.name = wa.name
	and wa.item_type = 'AUDITMGR'
	and wa.end_date is null
	and watl.name = wa.name
	and watl.item_type = 'AUDITMGR'
	and watl.version = wa.version
	and watl.language = userenv('LANG');

	return   l_process_name;
exception
    when no_data_found then
        return null;
    when others then
        return null;
end;




FUNCTION get_message_text(p_message_name in varchar2) return varchar2 is
l_message_text varchar2(4000);
begin
fnd_message.set_name('AMW',p_message_name);
l_message_text := fnd_message.get;
return l_message_text;
end get_message_text;

FUNCTION get_risk_name(p_risk_id in number) return varchar2 is
l_risk_name varchar2(240);

begin
      select rt.name into l_risk_name
      from amw_risks_all_vl rt
      where
      rt.risk_id = p_risk_id and
      rt.LATEST_REVISION_FLAG = 'Y';

      return l_risk_name;

exception
	when others then
		return null;
end get_risk_name;

FUNCTION get_control_name(p_control_id in number) return varchar2 is
l_control_name varchar2(240);

begin
      select ct.name into l_control_name
      from amw_controls_all_vl  ct
      where
      ct.control_id = p_control_id and
      ct.LATEST_REVISION_FLAG = 'Y';

      return l_control_name;

exception
	when others then
		return null;
end get_control_name;

FUNCTION get_organization_name(p_organization_id in number) return varchar2 is
l_organization_name varchar2(240);

begin
      select ot.name into l_organization_name
      from amw_audit_units_v ot
      where
      ot.organization_id = p_organization_id;

      return l_organization_name;

exception
	when others then
		return null;
end get_organization_name;



---------------------------------------------------------------------
-- PROCEDURE
--    get_proc_org_cert_status
-- HISTORY
-- 11/25/2003 ABEDAJNA  Created.
---------------------------------------------------------------------


FUNCTION get_proc_org_opinion_status(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2 is

l_last_audit_status varchar2(240);

begin

select audit_result
into l_last_audit_status
from amw_opinions_v
where pk1_value = p_process_id and pk3_value = p_org_id
and object_opinion_type_id =
    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') )
and last_update_date =
	(select max(last_update_date) from amw_opinions_v
	where pk1_value = p_process_id and pk3_value = p_org_id
	and object_opinion_type_id =
	    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
	    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
	    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') ) );

return   l_last_audit_status;

exception
    when no_data_found then
        return null;
    when others then
        return null;

end get_proc_org_opinion_status;



FUNCTION get_proc_org_opinion_date(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2 is

l_last_update_date date;

begin

select max(last_update_date) into l_last_update_date from amw_opinions_v
	where pk1_value = p_process_id and pk3_value = p_org_id
	and object_opinion_type_id =
	    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
	    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
	    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') );

return   l_last_update_date;

exception
    when no_data_found then
        return null;
    when others then
        return null;

end get_proc_org_opinion_date;


FUNCTION get_exception_name(p_type in varchar2, p_exception_id in number) return varchar2
is
l_process_name   varchar2(240);
begin
	if p_type = 'A'  then
		select new_process_name into l_process_name
		from amw_exceptions_tl aetl
		where
		aetl.exception_id = p_exception_id
		and aetl.language = userenv('LANG');
	elsif p_type='D' then
		select old_process_name into l_process_name
		from amw_exceptions_tl aetl
		where
		aetl.exception_id = p_exception_id
		and aetl.language = userenv('LANG');
	else
		return null;
	end if;
	return l_process_name;
exception
    when no_data_found then
        return null;
    when others then
        return null;
end;



procedure isUserProcessOwner (
p_pk				IN number,
p_userid			IN number,
p_objectContext			IN varchar2,
p_retval			OUT nocopy varchar2,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'isUserProcessOwner';
process_owner_id number;
f_party number;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

if (p_pk is null) or (p_userid is null) or (p_objectContext is null) then
	p_retval := 'N';
else
	if p_objectContext = 'PROCESS' then
		select Process_Owner_Id
		into process_owner_id
		from amw_process
		where process_id = p_pk;
	elsif p_objectContext = 'PROCESS_ORG' then
		select Process_Owner_Id
		into process_owner_id
		from amw_process_organization
		where process_organization_id = p_pk;
	end if;

	select person_party_id
	into f_party
	from fnd_user
	where user_id = p_userid;

	if f_party = process_owner_id then
		p_retval := 'Y';
	else
		p_retval := 'N';
	end if;
end if;


exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end isUserProcessOwner;

---------------------------------------------------------------------
--FUNCTION
-- get_risktype_text
-- Notes :
-- gives the Risk Type heading for webadi columns
-- Parameters :
-- p_type   :- p_risktype_token , The risk type name
-- HISTORY
--07/30/2004 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_risktype_text(p_risktype_token in varchar2) return varchar2 is
l_message_text varchar2(4000);
begin
fnd_message.set_name('AMW','AMW_WEBADI_RISK_TYPE_TEXT');
fnd_message.set_token('RISK_TYPE_NAME',p_risktype_token);
l_message_text := fnd_message.get;
return l_message_text;
end get_risktype_text;


---------------------------------------------------------------------
--FUNCTION
-- get_parameter_type
-- Notes :
-- gives the value of the parameter given the column name of the
-- pareameter name for an organization from amw_library_parameter
-- Parameters :
-- p_org_id   :- Organization_id  ( -1 if for RiskLibrary)
-- p_param_name :- column name of the parameter
-- EXAMPLE:- get_parameter(3970,'PROCESS_APPROVAL_OPTION')
--                  gives the value of parameter 'PROCESS_APPROVAL_OPTION' for organization with id 3970.
-- HISTORY
--11/05/2004 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_parameter(p_org_id in number, p_param_name in varchar2) return varchar2 is

l_value VARCHAR2(80);

BEGIN

if p_param_name = 'PROCESS_APPROVAL_OPTION'  then
	if g_appr_values_cached then
		if g_appr_opt_val.exists(p_org_id) then
			return g_appr_opt_val(p_org_id);
		else
			null;
		end if;
	end if;
end if;

    SELECT PARAMETER_VALUE INTO l_value
    FROM AMW_PARAMETERS
    WHERE PARAMETER_NAME = p_param_name
    AND PK1 = p_org_id;
    return l_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    return null;
    WHEN OTHERS THEN
    return null;
END get_parameter;


FUNCTION get_process_name_approved (p_process_id in number) return varchar2
is
l_display_name amw_process_names_tl.display_name%type;
begin
select display_name into l_display_name
from   amw_process amwp,
       amw_process_names_tl amwp_tl
where  amwp.process_rev_id = amwp_tl.process_rev_id and
       amwp.process_id = p_process_id and
       amwp.approval_date is not null and
       amwp.approval_end_date is null and
       amwp_tl.language=userenv('LANG');

return l_display_name;

exception
  when no_data_found then
    return null;
  when others then
    return null;


end get_process_name_approved;

FUNCTION get_process_name_by_status(p_process_id in number,
                                    p_status in varchar2) return varchar2

is
l_display_name amw_process_names_tl.display_name%type;
begin

if(p_status = 'L')
then
select display_name into l_display_name
from   amw_process amwp,
       amw_process_names_tl amwp_tl
where  amwp.process_rev_id = amwp_tl.process_rev_id and
       amwp.process_id = p_process_id and
       amwp.end_date is null and
       amwp_tl.language=userenv('LANG');

return l_display_name;
end if;

if(p_status = 'A')
then
select display_name into l_display_name
from   amw_process amwp,
       amw_process_names_tl amwp_tl
where  amwp.process_rev_id = amwp_tl.process_rev_id and
       amwp.process_id = p_process_id and
       amwp.approval_date is not null and
       amwp.approval_end_date is null and
       amwp_tl.language=userenv('LANG');

return l_display_name;
end if;

exception
  when no_data_found then
    return null;
  when others then
    return null;

end get_process_name_by_status;

---------------------------------------------------------------------
--FUNCTION
-- get_approved_org_process_name
-- Notes :
-- gives the display name of the approved org process revision
-- Parameters :
-- p_process_id   :- process Id ,p_org_id   :- org Id
-- HISTORY
--11/06/2004 KOSRINIV Created
---------------------------------------------------------------------
FUNCTION get_approved_org_process_name (p_process_id in number, p_org_id in number) return varchar2
is
l_display_name amw_process_names_tl.display_name%type;
begin
select display_name into l_display_name
from amw_process_organization apo,
        amw_process_names_tl amwp_tl
where apo.approval_date is not null
        and apo.approval_end_date is null
        and apo.rl_process_rev_id = amwp_tl.process_rev_id
        and apo.process_id = p_process_id
        and apo.organization_id = p_org_id
        and  amwp_tl.language=userenv('LANG');
return l_display_name;

exception
  when no_data_found then
    return null;
  when others then
    return null;
end get_approved_org_process_name;

FUNCTION is_process_locked(p_process_id in number, p_org_id in number) return varchar2
is
l_dummy number;
begin

  if p_process_id IS null then
    select 1 INTO l_dummy
    from amw_process_locks
    where organization_id = p_org_id;
else
    select 1
    into l_dummy
    from amw_process_locks
    where locked_process_id = p_process_id
    and organization_id = p_org_id;
end if;

    return 'Y';
exception
    when no_data_found then
        return 'N';

    when too_many_rows then
        return 'Y';
end is_process_locked;

--===================================================================================
FUNCTION get_project_count( p_org_id in number) return number
is
l_dummy number:=0;
begin

  SELECT COUNT(AP.AUDIT_PROJECT_ID) into l_dummy
  FROM AMW_AUDIT_PROJECTS AP,
  AMW_EXECUTION_SCOPE AES
  WHERE
  AP.AUDIT_PROJECT_ID = AES.ENTITY_ID
  AND AES.ENTITY_TYPE = 'PROJECT'
  AND AES.LEVEL_ID = 3
  AND AP.AUDIT_PROJECT_STATUS = 'ACTI'
  AND AES.ORGANIZATION_ID = p_org_id;
/* Commenting the code which returning the wrong count..
  SELECT COUNT(APV.AUDIT_PROJECT_ID) into l_dummy
  FROM AMW_AUDIT_PROJECTS_V APV,
  AMW_ENTITY_HIERARCHIES AEH
  WHERE
  APV.AUDIT_PROJECT_ID = AEH.ENTITY_ID
  AND AEH.ENTITY_TYPE = 'PROJECT'
  AND AEH.OBJECT_TYPE = 'ORGANIZATION'
  AND APV.PROJECT_STATUS_CODE = 'ACTI'
  AND AEH.OBJECT_ID = p_org_id;
*/
 return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return 0;
end get_project_count;
--===================================================================================
FUNCTION get_contrlol_objective_name(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number)
return varchar2
is
l_dummy varchar2(80):=null;
begin
  SELECT APV.name into l_dummy
  FROM AMW_PROCESS_OBJECTIVES_VL APV,
  AMW_OBJECTIVE_ASSOCIATIONS AOA
  WHERE
  APV.PROCESS_OBJECTIVE_ID =AOA.PROCESS_OBJECTIVE_ID
  AND AOA.PK1 = p_org_id
  AND AOA.PK2 = p_proc_id
  AND AOA.PK3 = p_risk_id
  AND AOA.PK4 = p_control_id
  AND AOA.DELETION_DATE IS NULL
  AND AOA.OBJECT_TYPE = 'CONTROL_ORG';
 return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return NULL;
end get_contrlol_objective_name;
--===================================================================================
FUNCTION get_contrlol_objective_id(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number)
return NUMBER
is
l_dummy NUMBER :=null;
begin
  SELECT AOA.PROCESS_OBJECTIVE_ID into l_dummy
  FROM AMW_OBJECTIVE_ASSOCIATIONS AOA
  WHERE
   AOA.PK1 = p_org_id
  AND AOA.PK2 = p_proc_id
  AND AOA.PK3 = p_risk_id
  AND AOA.PK4 = p_control_id
  AND AOA.DELETION_DATE IS NULL
  AND AOA.OBJECT_TYPE = 'CONTROL_ORG';
 return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return NULL;
end get_contrlol_objective_id;
--===================================================================================
FUNCTION is_contrlol_objective_approved(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number)
return varchar2
is
l_dummy DATE:=null;
begin
  SELECT AOA.approval_date into l_dummy
  FROM AMW_OBJECTIVE_ASSOCIATIONS AOA
  WHERE  AOA.PK1 = p_org_id
  AND AOA.PK2 = p_proc_id
  AND AOA.PK3 = p_risk_id
  AND AOA.PK4 = p_control_id
  AND AOA.DELETION_DATE IS NULL
  AND AOA.OBJECT_TYPE = 'CONTROL_ORG';
 if l_dummy is null then
   return 'N';
END IF;
RETURN 'Y';
EXCEPTION
 WHEN OTHERS THEN
   return 'N';
end is_contrlol_objective_approved;
--===================================================================================================
FUNCTION get_cobj_name_approved(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number)
return varchar2
is
l_dummy varchar2(80):=null;
begin
  SELECT APV.name into l_dummy
  FROM AMW_PROCESS_OBJECTIVES_VL APV,
  AMW_OBJECTIVE_ASSOCIATIONS AOA
  WHERE
  APV.PROCESS_OBJECTIVE_ID =AOA.PROCESS_OBJECTIVE_ID
  AND AOA.PK1 = p_org_id
  AND AOA.PK2 = p_proc_id
  AND AOA.PK3 = p_risk_id
  AND AOA.PK4 = p_control_id
  AND AOA.DELETION_DATE IS NULL
  AND AOA.APPROVAL_DATE IS NOT NULL
  AND AOA.OBJECT_TYPE = 'CONTROL_ORG';
 return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return NULL;
end get_cobj_name_approved;
--======================================================================================================
FUNCTION exist_in_latest_hier(p_org_id in number,p_proc_id in number) return varchar2
is
l_dummy varchar2(1) := 'N';
BEGIN
  SELECT 'Y'  INTO l_dummy from dual
  where exists ( select 1 from amw_latest_hierarchies
               where organization_id = p_org_id
                and (parent_id = p_proc_id or child_id = p_proc_id));
  return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return l_dummy;
end exist_in_latest_hier;
--======================================================================================================

FUNCTION get_proc_change_id(p_org_id in number,p_proc_id in number, p_rev_num in number) return NUMBER
is
l_dummy NUMBER;
BEGIN

  if p_org_id = -1 then
    select max(ecs.change_id) INTO l_dummy
 from eng_change_subjects ecs
  ,eng_engineering_changes eec
   where ecs.entity_name='AMW_REVISION_ETTY'
    and ecs.pk1_value=p_proc_id
    and ecs.pk2_value=p_rev_num
    and ecs.subject_level=1
    and ecs.change_id=eec.change_id
    and eec.status_type <> 5;
  else
    select max(ecs.change_id) INTO l_dummy
    from eng_change_subjects ecs, eng_engineering_changes eec
    where ecs.entity_name='AMW_ORG_REV_ETTY'
    and ecs.pk1_value=p_org_id
    and ecs.pk2_value=p_proc_id
    and ecs.pk3_value=p_rev_num
    and ecs.subject_level=1
    and eec.change_id=ecs.change_id
    and eec.status_type <> 5;
  end if;
  return l_dummy;
EXCEPTION
 WHEN OTHERS THEN
   return l_dummy;
end get_proc_change_id;

--======================================================================================================

FUNCTION has_child_morethan_two(p_proc_id in number,p_org_id in number) return VARCHAR
is
l_dummy NUMBER;
BEGIN

   select 1 INTO l_dummy
   from amw_latest_hierarchies
   where parent_id = p_proc_id
   and organization_id = p_org_id;
   return 'N';
EXCEPTION
 WHEN too_many_rows THEN
   return 'Y';
  WHEN OTHERS THEN
   return 'N';
end has_child_morethan_two;

--=====================================================================================================
FUNCTION is_control_associated_to_risk(p_process_id in number, p_revision_number in number, p_risk_id in number) return varchar2
is
dummy_count NUMBER;
BEGIN
select
	count(1) into dummy_count
from
     amw_control_associations aca,
     amw_process ap
where
aca.pk1 = ap.process_id
and   aca.object_type = 'RISK'
and   aca.pk1 = ap.process_id
and ap.process_id = p_process_id and ap.revision_number = p_revision_number and aca.pk2= p_risk_id
and   ((ap.approval_date is null and ap.end_date is null and aca.deletion_date is null ) OR
(ap.approval_date is not null and aca.approval_date <= ap.approval_date and
(aca.deletion_approval_date is null or aca.deletion_approval_date >= ap.approval_end_date)) );

if dummy_count > 0 then
  return GET_LOOKUP_MEANING('AMW_YES_NO','Y');
else
  return GET_LOOKUP_MEANING('AMW_YES_NO','N');
end if;

EXCEPTION
 WHEN OTHERS THEN
   return GET_LOOKUP_MEANING('AMW_YES_NO','N');
end is_control_associated_to_risk;

--=====================================================================================================
FUNCTION is_ctrl_assotd_to_all_risks(p_process_id in number, p_revision_number in number, p_risk_id in number) return varchar2
is
dummy_count NUMBER;
BEGIN
select
((select count(1)
from
       amw_control_associations aca,
       amw_process_vl apvl
where
aca.object_type = 'RISK'
and    aca.pk1 = apvl.process_id
and    aca.pk2 = p_risk_id
and   ((apvl.approval_date is null and apvl.end_date is null and aca.deletion_date is null) 	OR
(apvl.approval_date is not null and apvl.approval_end_date is null and aca.approval_date is not null and aca.deletion_approval_date is null))
and apvl.process_id = p_process_id and apvl.revision_number = p_revision_number)
+
(select count(1)
from
     amw_control_associations aca,
     Amw_Proc_Hierarchy_Denorm aphd,
     amw_process ap
where aphd.process_id = ap.process_id
and   aphd.up_down_ind = 'D'
and   ap.process_id = aphd.parent_child_id
and   aca.object_type = 'RISK'
and   aca.pk1 = aphd.parent_child_id
and   aca.pk2 = p_risk_id
and   ((ap.approval_date is null and ap.end_date is null and aphd.hierarchy_type = 'L' and aca.deletion_date is null) OR
       (ap.approval_date is not null and ap.approval_end_date is null and aphd.hierarchy_type = 'A' and aca.approval_date is not null and aca.deletion_approval_date is null)
      )
and   ap.process_id = aphd.parent_child_id
and ap.process_id = p_process_id and ap.revision_number = p_revision_number))
into dummy_count from dual;

if dummy_count > 0 then
  return GET_LOOKUP_MEANING('AMW_YES_NO','Y');
else
  return GET_LOOKUP_MEANING('AMW_YES_NO','N');
end if;

EXCEPTION
 WHEN OTHERS THEN
   return GET_LOOKUP_MEANING('AMW_YES_NO','N');
end is_ctrl_assotd_to_all_risks;
--===================================================================================
FUNCTION is_control_objective_approved(p_process_id in number, p_risk_id in number, p_control_id in number)
return varchar2
is
l_dummy DATE:=null;
begin
  SELECT AOA.approval_date into l_dummy
  FROM AMW_OBJECTIVE_ASSOCIATIONS AOA
  WHERE  AOA.PK1 = p_process_id
  AND AOA.PK2 = p_risk_id
  AND AOA.PK3 = p_control_id
  AND AOA.DELETION_DATE IS NULL
  AND AOA.OBJECT_TYPE = 'CONTROL';
 if l_dummy is null then
   return 'N';
END IF;
RETURN 'Y';
EXCEPTION
 WHEN OTHERS THEN
   return 'N';
end is_control_objective_approved;

--04.01.2005 npanandi: added below method to return
--display value for Ineff Ctrls / Evaluated Ctrls / Total Ctrls
--bug 4201078 fix
function get_display_value(
   p_ineff_ctrl in number
  ,p_eval_ctrl in number
  ,p_total_ctrl in number)
return varchar2
is
   l_profile_value varchar2(240) := null;
   l_display_value varchar2(10) := '';

   l_ineff_ctrl number;
   l_eval_ctrl number;
   l_total_ctrl number;
begin
   l_ineff_ctrl := nvl(p_ineff_ctrl,0);
   l_eval_ctrl := nvl(p_eval_ctrl,0);
   l_total_ctrl := nvl(p_total_ctrl,0);

   l_profile_value := nvl(fnd_profile.VALUE('AMW_OPINION_NUMBERS_OPTION'),'PERCENTAGE');
   /*************************************************************************/
   /** 'INEFF'                -->  Only Not Effective                      **/
   /** 'INEFF_TOTAL'          -->  Not Effective and Total                 **/
   /** 'INEFF_VERFIED'        -->  Not Effective and Total Verified        **/
   /** 'INEFF_VERIFIED_TOTAL' -->  Not Effective, Total Verified and Total **/
   /** 'PERCENTAGE'           -->  Percentage of Not Effective over Total  **/
   /*************************************************************************/
   if(l_total_ctrl = 0)then
      return l_display_value;
   end if;

   if(l_profile_value = 'INEFF')then
      ---dbms_output.put_line( 'INEFF' );
      l_display_value := to_char(l_ineff_ctrl);
   elsif(l_profile_value = 'INEFF_TOTAL')then
      ---dbms_output.put_line( 'INEFF_TOTAL' );
      l_display_value := to_char(l_ineff_ctrl)||'/'||to_char(l_total_ctrl);
   elsif(l_profile_value = 'INEFF_VERIFIED')then
      l_display_value := to_char(l_ineff_ctrl)||'/'||to_char(l_eval_ctrl);
   elsif(l_profile_value = 'INEFF_VERIFIED_TOTAL')then
      ---dbms_output.put_line( 'INEFF_VERIFIED_TOTAL' );
      l_display_value := to_char(l_ineff_ctrl)||'/'||to_char(l_eval_ctrl)||'/'||to_char(l_total_ctrl);
   elsif(l_profile_value = 'PERCENTAGE')then
      ---dbms_output.put_line( 'PERCENTAGE' );
      l_display_value := to_char(round(((l_ineff_ctrl*100)/l_total_ctrl),2))||'%';
   end if;

   /*if(l_display_value = '0%' or l_display_value = '0')then
      l_display_value := '';
   end if;*/
   return l_display_value;
exception
   when others then
      return '';
end get_display_value;
--04.01.2005 npanandi: ends

--04.01.2005 npanandi: added below method to return
--display value for Process/Org Certified vs. Total Processes/Orgs
--bug 4201078 fix
function get_display_proc_cert(
   p_sub_process_cert       in number
  ,p_total_sub_process_cert in number) return varchar2
is
   l_profile_value varchar2(240) := null;
   l_display_value varchar2(10) := '';

   l_sub_process_cert number;
   l_total_sub_process_cert number;
begin
   /*************************************************************************/
   /** 'INEFF'                -->  Only Not Effective                      **/
   /** 'INEFF_TOTAL'          -->  Not Effective and Total                 **/
   /** 'INEFF_VERFIED'        -->  Not Effective and Total Verified        **/
   /** 'INEFF_VERIFIED_TOTAL' -->  Not Effective, Total Verified and Total **/
   /** 'PERCENTAGE'           -->  Percentage of Not Effective over Total  **/
   /*************************************************************************/
   l_profile_value := nvl(fnd_profile.VALUE('AMW_OPINION_NUMBERS_OPTION'),'PERCENTAGE');

   l_sub_process_cert := nvl(p_sub_process_cert,0);
   l_total_sub_process_cert := nvl(p_total_sub_process_cert,0);

/*
   if(l_sub_process_cert = 0 or l_total_sub_process_cert = 0)then
      return l_display_value;
   end if;
*/
   ---04.08.05 npanandi: return null only if total = 0
   if(l_total_sub_process_cert = 0)then
      return l_display_value;
   end if;

   if(l_profile_value = 'INEFF')then
      ---dbms_output.put_line( 'INEFF' );
      l_display_value := to_char(l_sub_process_cert);
   elsif(l_profile_value='INEFF_TOTAL' or l_profile_value='INEFF_VERIFIED' or l_profile_value='INEFF_VERIFIED_TOTAL') then
      l_display_value := to_char(l_sub_process_cert)||'/'||to_char(l_total_sub_process_cert);
   elsif(l_profile_value='PERCENTAGE') then
      l_display_value := to_char(round(((l_sub_process_cert*100)/l_total_sub_process_cert),2))||'%';
   end if;

   return l_display_value;

exception
   when others then
      return '';
end get_display_proc_cert;

FUNCTION GET_EX_REASONS(p_action IN VARCHAR2,
						p_object IN VARCHAR2,
						p_pk1 IN VARCHAR2,
						p_pk2 IN VARCHAR2,
						p_pk3 IN VARCHAR2,
						p_pk4 IN VARCHAR2  := NULL,
						p_pk5 IN VARCHAR2 := NULL) RETURN VARCHAR2
IS

CURSOR DEL_EXCEPTION IS
	   SELECT EXCEPTION_ID
	   FROM AMW_EXCEPTIONS_B
	   WHERE OBJECT_TYPE = p_object
	   AND OLD_PK1 = p_pk1
	   AND OLD_PK2 = p_pk2
	   AND OLD_PK3 = p_pk3
	   AND NVL(OLD_PK4, -99) = NVL(p_pk4, -99)
	   AND NVL(OLD_PK5, -99) = NVL(p_pk5, -99)
	   AND APPROVED_FLAG = 'Y'
	   AND END_DATE IS NULL;

CURSOR ADD_EXCEPTION IS
	   SELECT EXCEPTION_ID
	   FROM AMW_EXCEPTIONS_B
	   WHERE OBJECT_TYPE = p_object
	   AND NEW_PK1 = p_pk1
	   AND NEW_PK2 = p_pk2
	   AND NEW_PK3 = p_pk3
	   AND NVL(NEW_PK4, -99) = NVL(p_pk4, -99)
	   AND NVL(NEW_PK5, -99) = NVL(p_pk5, -99)
	   AND APPROVED_FLAG = 'Y'
	   AND END_DATE IS NULL;

CURSOR EX_REASONS(p_exception_id in NUMBER) IS
	   SELECT MEANING
	   FROM AMW_EXCEPTIONS_REASONS,
            AMW_LOOKUPS
       WHERE LOOKUP_TYPE = 'AMW_EXCEPTION_REASONS'
         AND LOOKUP_CODE =  REASON_CODE
         AND EXCEPTION_ID = p_exception_id;

l_reasons_string  VARCHAR2(4000) :=NULL;
l_exception_id    AMW_EXCEPTIONS_B.EXCEPTION_ID%TYPE;
BEGIN

	IF p_action = 'DEL' THEN
		OPEN DEL_EXCEPTION;
		FETCH DEL_EXCEPTION INTO l_exception_id;
		IF DEL_EXCEPTION%NOTFOUND THEN
			CLOSE DEL_EXCEPTION;
			RETURN NULL;
		END IF;
		CLOSE DEL_EXCEPTION;
	ELSIF p_action = 'ADD' THEN
		OPEN ADD_EXCEPTION;
		FETCH ADD_EXCEPTION INTO l_exception_id;
		IF ADD_EXCEPTION%NOTFOUND THEN
			CLOSE ADD_EXCEPTION;
			RETURN NULL;
		END IF;
		CLOSE ADD_EXCEPTION;
	END IF;
	FOR REASONS IN EX_REASONS(l_exception_id) LOOP
	EXIT WHEN EX_REASONS%NOTFOUND;
                IF l_reasons_string is null then
                  l_reasons_string :=  REASONS.MEANING;
                else
                  l_reasons_string := l_reasons_string || ',' || REASONS.MEANING;
                end if;
	END LOOP;
	return l_reasons_string;
EXCEPTION
	WHEN OTHERS THEN
		RETURN null;
END;

FUNCTION GET_EX_COMMENTS(p_action IN VARCHAR2,
						p_object IN VARCHAR2,
						p_pk1 IN VARCHAR2,
						p_pk2 IN VARCHAR2,
						p_pk3 IN VARCHAR2,
						p_pk4 IN VARCHAR2  := NULL,
						p_pk5 IN VARCHAR2 := NULL) RETURN VARCHAR2
IS

CURSOR DEL_EXCEPTION IS
	   SELECT EXCEPTION_ID
	   FROM AMW_EXCEPTIONS_B
	   WHERE OBJECT_TYPE = p_object
	   AND OLD_PK1 = p_pk1
	   AND OLD_PK2 = p_pk2
	   AND OLD_PK3 = p_pk3
	   AND NVL(OLD_PK4, -99) = NVL(p_pk4, -99)
	   AND NVL(OLD_PK5, -99) = NVL(p_pk5, -99)
	   AND APPROVED_FLAG = 'Y'
	   AND END_DATE IS NULL;

CURSOR ADD_EXCEPTION IS
	   SELECT EXCEPTION_ID
	   FROM AMW_EXCEPTIONS_B
	   WHERE OBJECT_TYPE = p_object
	   AND NEW_PK1 = p_pk1
	   AND NEW_PK2 = p_pk2
	   AND NEW_PK3 = p_pk3
	   AND NVL(NEW_PK4, -99) = NVL(p_pk4, -99)
	   AND NVL(NEW_PK5, -99) = NVL(p_pk5, -99)
	   AND APPROVED_FLAG = 'Y'
	   AND END_DATE IS NULL;

CURSOR EX_COMMENTS(p_exception_id in NUMBER) IS
	   SELECT JUSTIFICATION
  	   FROM AMW_EXCEPTIONS_TL
       WHERE EXCEPTION_ID = p_exception_id
  	   AND LANGUAGE = USERENV('LANG');

l_comments  VARCHAR2(4000) :=NULL;
l_exception_id    AMW_EXCEPTIONS_B.EXCEPTION_ID%TYPE;
BEGIN

	IF p_action = 'DEL' THEN
		OPEN DEL_EXCEPTION;
		FETCH DEL_EXCEPTION INTO l_exception_id;
		IF DEL_EXCEPTION%NOTFOUND THEN
			CLOSE DEL_EXCEPTION;
			RETURN NULL;
		END IF;
		CLOSE DEL_EXCEPTION;
	ELSIF p_action = 'ADD' THEN
		OPEN ADD_EXCEPTION;
		FETCH ADD_EXCEPTION INTO l_exception_id;
		IF ADD_EXCEPTION%NOTFOUND THEN
			CLOSE ADD_EXCEPTION;
			RETURN NULL;
		END IF;
		CLOSE ADD_EXCEPTION;
	END IF;
	OPEN EX_COMMENTS(l_exception_id);
	FETCH EX_COMMENTS INTO l_comments;
	IF EX_COMMENTS%NOTFOUND THEN
		CLOSE EX_COMMENTS;
		RETURN NULL;
	END IF;
	CLOSE EX_COMMENTS;
	RETURN l_comments;
EXCEPTION
	WHEN OTHERS THEN
		RETURN null;
END;

/* This procedure inserts a record into the FND_LOG_MESSAGES table
   FND uses an autonomous transaction so even when the hookinsert is
   rolled back because of an error the log messages still exists
*/
PROCEDURE LOG_MSG( v_object_id   IN VARCHAR2
                 , v_object_name IN VARCHAR2
                 , v_message     IN VARCHAR2
 --                , v_level_id    IN NUMBER := -1
                 , v_module      IN VARCHAR2)
IS
  l_log_level  NUMBER;
  l_module     VARCHAR2(64);
  l_message    VARCHAR2(4000);

BEGIN

  IF (FND_PROFILE.VALUE('AMW_DEBUG') = 'N') THEN
  	RETURN;
  END IF;

  l_module := v_module;
  -- Convert to the FND_LOG LEVEL
  l_log_level := 5 - FND_PROFILE.VALUE('AMW_DEBUG_LEVEL');
  --Create the message text
  l_message := 'Object '||v_object_name||'-'||v_object_id||' : '||v_message;

/*always log message to fnd_file because it will periodically be purged
  log file name can be found in fnd_temp_files. (fnd_temp_file_parameters)*/
 fnd_file.put_line (fnd_file.LOG, l_message);
 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module,l_message);
  end if;
---comment the following for bug5532010 --start
/*

  IF g_initialize_log = TRUE THEN
     IF FND_LOG_REPOSITORY.CHECK_ACCESS_INTERNAL (l_module, l_log_level) THEN
                FND_LOG_REPOSITORY.STRING_UNCHECKED_INTERNAL(l_log_level,
                                                 l_module,
                                                 l_message,
                                                 g_session_id );
         END IF;
  ELSE    */
 /* 1. Talk with IBE folks when they encounter the similar problem.
       they recommend that to user this user and responsibility,
       instead of the user from fnd_global. I will double confirm with FND.
       2. Why always forced to use user (5), we will only use it
          when there is no valid user
    */
    /*IF (FND_GLOBAL.USER_ID() is null or
        FND_GLOBAL.USER_ID() < -1) THEN
        FND_GLOBAL.APPS_INITIALIZE( 5, 20420, 1);
    ELSE
        FND_GLOBAL.APPS_INITIALIZE( FND_GLOBAL.USER_ID(),
                                    FND_GLOBAL.RESP_ID(),
                                    FND_GLOBAL.RESP_APPL_ID());
    END IF;

  SELECT amw_debug_log_s.nextval INTO g_session_id FROM DUAL;

    FND_LOG_REPOSITORY.INIT( SESSION_ID=> g_session_id);
    g_initialize_log := TRUE;
    IF FND_LOG_REPOSITORY.CHECK_ACCESS_INTERNAL (l_module, l_log_level) THEN
        FND_LOG_REPOSITORY.STRING_UNCHECKED_INTERNAL(l_log_level,
                                                     l_module,
                                                     l_message,
                                                     g_session_id);
    END IF;
  END IF;*/
EXCEPTION WHEN OTHERS THEN
  NULL;
END LOG_MSG;

FUNCTION GET_RISK_CONTROLS_EXIST(p_org_id IN NUMBER, p_process_id IN NUMBER, p_risk_id IN NUMBER, p_appr_date IN DATE) RETURN VARCHAR2
IS
l_dummy  varchar2(1):='N';
BEGIN
  IF p_appr_date is not null THEN
    select 'Y' into l_dummy
    from amw_control_associations
    where object_type = 'RISK_ORG'
    and pk1 = p_org_id
    and pk2 = p_process_id
    and pk3 = p_risk_id
    and approval_date is not null and deletion_approval_date is null;
  ELSE
      select 'Y' into l_dummy
      from amw_control_associations
      where object_type = 'RISK_ORG'
      and pk1 = p_org_id
      and pk2 = p_process_id
      and pk3 = p_risk_id
      and deletion_date is null;
  end if ;
  return l_dummy;
EXCEPTION
  when no_data_found then
        return 'N';
  when too_many_rows then
        return 'Y';
  WHEN OTHERS THEN
  RETURN 'N';
END;

FUNCTION IS_ORG_REGISTERED(p_org_id IN NUMBER) RETURN VARCHAR2
IS
l_dummy  varchar2(1):='N';
BEGIN
-- for the time being we just check for the existance of -2 row in org.if it present then the org is usable to assign processes.
  select 'Y' into l_dummy
  from amw_process_organization
  where organization_id = p_org_id
  and process_id = -2;
  return l_dummy;
EXCEPTION
  when no_data_found then
        return 'N';
  when too_many_rows then
        return 'Y';
  WHEN OTHERS THEN
  RETURN 'N';
END;

/* 03-APR-2007 rjohnson 5686374 start-1 added lang and terr */
PROCEDURE  submit_conc_request(p_template_code IN VARCHAR2,
                             p_template_lang IN VARCHAR2 default NULL,
                             p_template_territory IN VARCHAR2 default NULL,
                             p_certification_id IN NUMBER default NULL,
                             p_organization_id IN NUMBER default NULL,
                             p_process_id IN NUMBER default NULL,
                             p_from_date IN DATE default NULL,
                             p_to_date IN DATE default NULL,
                             p_include_orgs_with_issues IN VARCHAR2 default NULL,
                             p_key_controls IN VARCHAR2 default NULL,
                             p_material_risks IN VARCHAR2 default NULL,
                             p_significant_process IN VARCHAR2 default NULL,
                             p_request_id  OUT nocopy NUMBER)
IS

l_request_id            NUMBER;
l_msg                   VARCHAR2(2000);
l_reqdata               VARCHAR2(240);
xml_layout boolean;
l_data_source_code      VARCHAR2(80);

BEGIN

  select data_source_code into l_data_source_code
  from xdo_templates_b
  where template_code = p_template_code
  and application_short_name = 'AMW';

  /* 03-APR-2007 rjohnson 5686374 start-2 */
  /*xml_layout := FND_REQUEST.ADD_LAYOUT('AMW',p_template_code,'en','US','PDF');*/
  xml_layout := FND_REQUEST.ADD_LAYOUT('AMW',p_template_code,p_template_lang,p_template_territory,'PDF');
  /* 03-APR-2007 rjohnson 5686374 end-2 */

  /* Submit the request with relevant params depending on the template */
  IF p_template_code = 'AMWBUSPROCRPT' THEN

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW', l_data_source_code, null, null, FALSE,
                                               p_organization_id, p_process_id,
                                               p_from_date, p_to_date, p_key_controls, p_material_risks);
  ELSIF p_template_code = 'AMWSUBCERTRPT' THEN

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW', l_data_source_code, null, null, FALSE,
                                               p_certification_id, p_organization_id,
                                               p_include_orgs_with_issues, p_significant_process,
                                               p_key_controls, p_material_risks);
  ELSIF p_template_code = 'AMWORGDOCRPT' THEN

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW', l_data_source_code, null, null, FALSE,
                                               p_organization_id, p_from_date, p_to_date,
                                               p_significant_process, p_key_controls, p_material_risks);
  ELSIF p_template_code = 'AMWFSCTRLDEFRPT' THEN

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW', l_data_source_code, null, null, FALSE,
                                               p_certification_id, p_organization_id, p_significant_process,
                                               p_material_risks,p_key_controls, p_from_date, p_to_date);

  END IF;

  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Test XML report :' || l_request_id );
  END IF;

  COMMIT;

  p_request_id := l_request_id;

END submit_conc_request;


FUNCTION get_org_opinion_status(p_org_id in number, p_mode in varchar2) return
varchar2 is

l_last_audit_status varchar2(240);

begin

select audit_result
into l_last_audit_status
from amw_opinions_v
where pk1_value = p_org_id
and object_opinion_type_id =
    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b
where opinion_type_code = p_mode)
    and object_id = (select object_id from fnd_objects where obj_name =
'AMW_ORGANIZATION') )
and last_update_date =
	(select max(last_update_date) from amw_opinions_v
	where pk1_value = p_org_id
	and object_opinion_type_id =
	    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
	    where opinion_type_id = (select opinion_type_id from
amw_opinion_types_b where opinion_type_code = p_mode)
	    and object_id = (select object_id from fnd_objects where obj_name =
'AMW_ORGANIZATION') ) );

return   l_last_audit_status;

exception
    when no_data_found then
        return null;
    when others then
        return null;

end get_org_opinion_status;

procedure cache_appr_options
is
type tn is table of number;
type tvalues is table of varchar2(1);
l_param_values tvalues;
l_pk_values tn;
begin
	 select pk1, parameter_value bulk collect into l_pk_values,l_param_values
   from amw_parameters
   where parameter_name = 'PROCESS_APPROVAL_OPTION';

   for i in l_pk_values.first .. l_pk_values.last loop
   	g_appr_opt_val(l_pk_values(i)) := l_param_values(i);
   end loop;

   g_appr_values_cached := true;

exception
	when others then
		null;
end;

procedure unset_appr_cache
is
begin
g_appr_values_cached := false;
end;

END AMW_Utility_PVT;

/
