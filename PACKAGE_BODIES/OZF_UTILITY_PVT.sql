--------------------------------------------------------
--  DDL for Package Body OZF_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_UTILITY_PVT" AS
/* $Header: ozfvutlb.pls 120.13.12010000.8 2010/05/10 11:51:37 bkunjan ship $ */

-- HISTORY
--
-- 15-Jun-2000    HOLIU       Added procedures to get qp details
-- 15-Jun-2000    PTENDULK    Commented the function is_in_my_area
--                            as it will be released in R2
-- 28-Jun-2000    RCHAHAL     Added Qualifier in get_qual_table_name_and_pk.
-- 13-Jul-2000    choang      Added get_resource_id
-- 07-Aug-2000    ptendulk    Added procedure Write_Conc_Log
-- 08-Aug-2000    ptendulk    Modified procedure Write_Conc_Log
-- 30-Jan-2001    MPande    Modified procedure  get_object_name
-- 30-Jan-2001    ptendulk    Modified Qualifier in get_qual_table_name_and_pk proc.
-- 13-Mar-2001    choang      Removed extra close cursor code in create_log.
--   03/27/2001    MPANDE    MOved 4 Procedures from OZF to OZF
--   03/29/2001    gjoby      Added LIST and SQL condtions
--                             in get_qual_table_name_and_pk
-- 29-Mar-2001    ptendulk    Modified get_system_status_type proc.
---13-Apr-2001    feliu       Modified create_log proc.
-- 23-Apr-2001    feliu      Modified create_log proc.
  -- skarumur - 25-apr-2000
-- 07-May-2001    choang      Added RCAM to get_qual_table_name_and_pk
-- 20-May-2001    ptendulk    Modified get_system_status_type procedure for Progrozf
-- 24-May-2001    feliu       Modified create_log proc.
-- 13-Jun-2001    ptendulk    Added code for MUKUMAR to add validation for EONE
-- 15-Jun-2001    choang      changed OFFR in get_qual_table_name_and_pk, and PRTN (to PTNR)
--                            in get_object_name
-- 16-Jun-2001    ptendulk    Added check_new_status_change procedure to obsolute
--                            the old check_status_change api
-- 19-Jun-2001    ptendulk    Modified Approval_Required_Flag function
-- 09-Jul-2001    ptendulk    Added new function Check_Status_Change
-- 13-Sep-2001    slkrishn    Added new function for amount rounding based on currency
-- 14-Jan-2001    sveerave    Added send_wf_standalone_message procedure, and
--                            Get_Resource_Role procedures for sending standalone mesages.
-- 18-Mar-2002    choang      Added checkfile to dbdrv
-- 27-Mar-2002    dmvincen    Added dialog and component validiation.
-- 17-May-2002    choang      bug 2224836: changed get_sytem_timezone and get_user_timezone
--                            to use HZ timezone profiles.
-- 06-Jun-2002    sveerave    Added overloaded check_lookup_exists
--                            which accepts view_application_id, query from fnd_lookups
-- 06-Jun-2002    sveerave    Modified previous check_lookup_exists to call
--                            newly created procedure.
-- 17-Jun-2002    sveerave    Modified cursor in check_lookup_exists to have p_view_app_id
--                            as NUMBER
-- 10-Jul-2002    musman      Modified the procedure check_new_status_change, checking for
--                            CAPL instead of TAPL if the object type is 'DELV'
-- 19-Dec-2002    mayjain     Added get_install_info
-- 13-Oct-2003    yzhao       get_qual_table_name_and_pk() for FUND, changed from ozf_fund_details_v to ozf_funds_all_b
--   Wed Oct 29 2003:3/44 PM  RSSHARMA Added function get_party_name . Changed get_product_name to include FAMILY in Product level since the lookup
--                            for product level for lumpsum , scandata and Net Accrual Offers has product level codes as PRODUCT AND FAMILY
--  Fri Jan 23 2004:3/20 PM RSSHARMA Added the following fuctions
--                          1. get_fnd_lookup_meaning
--                          2. get_currency_name
--                          3. get_media_name
--  17-FEB-2005   feliu    added  functions
                        --  get_commited_amount
                        --  get_recal_commited_amount
                        --  get_utilized_amount
                        --  get_paid_amount
                        --  get_earned_amount
-- 19-May-05      Sahana   Bug4382865: SQL Literal fix
-- 12-Jun-05      Ribha    #4173825 Modified get_product_name
-- 31-Aug-05      mkothari Changed AMS to OZF for forecast tbl
-- 17-May-2006    asylvia  fixed bug 5226685
-- Mon May 22 2006:5/59 PM rssharma Fixed bug # 5213655.Added getAttributeMethods to get AKAttribute long labels.
-- 09-Nov-2008    psomyaju Bug 7555174 - APPROVALS FOR 'GLOBAL' OFFERS - NO LEDGER DEFINED
-- 09-Nov-2008    psomyaju Bug 7415805 - INT1206.2:AMS:UNABLE TO APPROVE THE OFFER
-- 24-Nov-08      nirprasa Bug 7030415 - R12SIP WE CAN'T SETUP CURRENY CONVERSION TYPE FOR SPECIFIC OPERATING UNIT
-- 07-APR-2009    kdass    Bug 8402334 - BUDGET UTILIZATION API TO ACCEPT ORG ID
-- 06/12/2009     kdass    Bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API
-- 05-Mar-2010    BKUNJAN  ER 9382547 -  TM SLA Uptake
-- 10-May-2010    BKUNJAN  Bug 9666046 - TST1213:UNABLE TO POST THE ENTRIES TOGL DUE TO ERROR IN CREATE ACCOUNTING CC JOB
---------------------------------------------------------------------
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
-- 25-Apr-2000 skarumur Created.
-- 26-Apr-2000 choang   Modified to handle <> conditions.
---------------------------------------------------------------------
OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
G_OZF_APP_ID CONSTANT NUMBER := 682;

PROCEDURE bind_parse (
     p_string IN VARCHAR2,
     x_col_val_tbl OUT NOCOPY col_val_tbl
  );



--======================================================================
-- PROCEDURE
--    debug_message
--
-- PURPOSE
--    Writes the message to the log file for the spec'd level and module
--    if logging is enabled for this level and module
--
-- HISTORY
--    01-Oct-2003  huili  Create.
--======================================================================
PROCEDURE debug_message (p_log_level IN NUMBER,
                       p_module_name    IN VARCHAR2,
                       p_text   IN VARCHAR2)
IS
BEGIN
  IF( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(p_log_level, p_module_name, p_text);
  END IF;
END debug_message;


--======================================================================
-- PROCEDURE
--    log_message
--
-- PURPOSE
--    Writes a message to the log file if this level and module is enabled
--    The message gets set previously with FND_MESSAGE.SET_NAME,
--    SET_TOKEN, etc.
--    The message is popped off the message dictionary stack, if POP_MESSAGE
--    is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
--    displayed to the user later.
--    Example usage:
--    FND_MESSAGE.SET_NAME(...);    -- Set message
--    FND_MESSAGE.SET_TOKEN(...);   -- Set token in message
--    FND_LOG.MESSAGE(..., FALSE);  -- Log message
--    FND_MESSAGE.ERROR;            -- Display message
--
-- HISTORY
--    01-Oct-2003  huili  Create.
--======================================================================

PROCEDURE log_message(p_log_level   IN NUMBER,
                         p_module_name IN VARCHAR2,
                         p_RCS_ID      IN VARCHAR2 := NULL,
                         p_pop_message IN BOOLEAN DEFAULT NULL)
IS
BEGIN
  IF ( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.MESSAGE(p_log_level, p_module_name, p_pop_message);
    IF p_RCS_ID IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(G_RCS_ID, p_RCS_ID);
    END IF;
  END IF;
END log_message;

--======================================================================
-- FUNCTION
--    logging_enabled
--
-- PURPOSE
--    Return whether logging is enabled for a particular level
--
-- HISTORY
--    03-Oct-2003  huili  Create.
--======================================================================
FUNCTION logging_enabled (p_log_level IN NUMBER)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
END;


---------------------------------------------------------------------
-- FUNCTION
--    check_fk_exists
--
-- HISTORY
--    05/14/99  cklee  Created.
-- 25-Apr-2000 choang   modified to use bind variables.
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
   l_bind_tbl  col_val_tbl;

BEGIN
   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || UPPER(p_table_name);
   l_sql := l_sql || ' WHERE ' || UPPER(p_pk_name) || ' = :b1';

   IF p_additional_where_clause IS NOT NULL THEN

         -- Bug4382865: Start SQL Literal Fix
         bind_parse (p_additional_where_clause, l_bind_tbl);

         -- Support up to 4 WHERE conditions.
         IF l_bind_tbl.COUNT <= 4 THEN
              l_sql := l_sql || ' AND ' || l_bind_tbl(1).col_name || ' ' || l_bind_tbl(1).col_op || ' :b1';
              FOR i IN 2..l_bind_tbl.COUNT LOOP
                  l_sql := l_sql || ' AND ' || l_bind_tbl(i).col_name || ' ' || l_bind_tbl(i).col_op || ' :b' || i;
              END LOOP;
         ELSE
              -- Exceeded the number of conditions supported
              -- for bind variables.
             l_sql := l_sql || ' WHERE ' || p_additional_where_clause;
         END IF;
    END IF;

   l_sql := l_sql || ')';

   IF (OZF_DEBUG_HIGH_ON) THEN
      debug_message('SQL statement: '||l_sql);
   END IF;

   BEGIN
   IF p_additional_where_clause IS NOT NULL THEN
      IF l_bind_tbl.COUNT = 1 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING p_pk_value, l_bind_tbl(1).col_value;
      ELSIF l_bind_tbl.COUNT = 2 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING p_pk_value, l_bind_tbl(1).col_value, l_bind_tbl(2).col_value;
      ELSIF l_bind_tbl.COUNT = 3 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value;
      ELSIF l_bind_tbl.COUNT = 4 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING p_pk_value, l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value, l_bind_tbl(4).col_value;
      ELSE
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING p_pk_value;
      END IF;
   ELSE
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_pk_value;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;
   -- Bug4382865: End SQL Literal Fix

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
--    05/14/99  cklee  Created.
-- 25-Apr-2000 choang   Use bind variables.
-- 07-jun-2002  sveerave  if table name is specifically not passed, changes
--                        are made to call overloaded procedure.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_ozf_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN

  IF p_lookup_table_name = g_ozf_lookups THEN
    return check_lookup_exists (
          p_lookup_type =>  p_lookup_type
        , p_lookup_code =>  p_lookup_code
        , p_view_application_id => 682
        );
  ELSE
    l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || p_lookup_table_name;
    l_sql := l_sql || ' WHERE LOOKUP_TYPE = :b1';
    l_sql := l_sql || ' AND LOOKUP_CODE = :b2';
    l_sql := l_sql || ' AND ENABLED_FLAG = ''Y'')';

    IF (OZF_DEBUG_HIGH_ON) THEN
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
--   07-jun-2002  sveerave created.
--   17-Jun-2002  sveerave Modified cursor to have p_view_app_id as NUMBER
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
--   05/19/99  cklee  Created.
-- 25-Apr-2000 choang   Use bind_parse to enable use of bind variables.
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
   -- choang - 25-Apr-2000
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      debug_message('SQL statement: '||l_sql);
   END IF;

   --
   -- choang - 25-Apr-2000
   -- Modify here if number of WHERE conditions
   -- supported changes.
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
--   05/19/99  cklee  Created.
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
-- 10/10/99    holiu    Created.
-- 13-mar-2002 choang   bug 2262529 - g_miss_char is a nil char which
--                      caused some problems in the java layer; removed
--                      g_miss_char from the error message.
-- 14-mar-2002 choang   added text G_MISS_CHAR to be displayed in place
--                      of nil char for debugging purposes.
-- 09-Dec-2002 choang   All calls to debug should check for msg level
--                      before calling; removing the check in the debug
--                      procedure to avoid reduncy.
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := NULL
)
IS
BEGIN
   FND_MESSAGE.set_name('OZF', 'OZF_API_DEBUG_MESSAGE');
   FND_MESSAGE.set_token('TEXT', REPLACE (p_message_text, FND_API.G_MISS_CHAR, 'G_MISS_CHAR'));
   FND_MSG_PUB.add;
END debug_message;


---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
)
IS
BEGIN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', p_message_name);
      IF p_token_name IS NOT NULL THEN
         FND_MESSAGE.set_token(p_token_name, p_token_value);
      END IF;
      FND_MSG_PUB.add;
   END IF;
END error_message;


---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
--
-- HISTORY
--    10/26/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE display_messages
IS
   l_count  NUMBER;
   l_msg    VARCHAR2(2000);
BEGIN
   l_count := FND_MSG_PUB.count_msg;
   FOR i IN 1 .. l_count LOOP
      l_msg := FND_MSG_PUB.get(i, FND_API.g_false);
      -- holiu: remove since adchkdrv does not like it
--      DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
   END LOOP;
END display_messages;


---------------------------------------------------------------------
-- NAME
--    create_log
--
-- HISTORY
--   09/21/99  ptendulk  Created.
-- 12-Jan-2000 choang    Added autonomous transaction.
---------------------------------------------------------------------
PROCEDURE create_log(
   x_return_status    OUT NOCOPY VARCHAR2,
   p_arc_log_used_by  IN  VARCHAR2,
   p_log_used_by_id   IN  VARCHAR2,
   p_msg_data         IN  VARCHAR2,
   p_msg_level        IN  NUMBER    DEFAULT NULL,
   p_msg_type         IN  VARCHAR2  DEFAULT NULL,
   p_desc             IN  VARCHAR2  DEFAULT NULL,
   p_budget_id        IN  NUMBER    DEFAULT NULL,
   p_threshold_id     IN  NUMBER    DEFAULT NULL,
   p_transaction_id   IN  NUMBER    DEFAULT NULL,
   p_notification_creat_date    IN DATE DEFAULT NULL,
   p_activity_log_id   IN  NUMBER   DEFAULT NULL
)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   x_rowid         VARCHAR2(30);
   l_act_log_id    ams_act_logs.activity_log_id%TYPE;
   l_log_tran_id   ams_act_logs.log_transaction_id%TYPE;

   CURSOR c_log_seq IS
   SELECT ams_act_logs_s.NEXTVAL,
          ams_act_logs_transaction_id_s.NEXTVAL
     FROM DUAL;

   CURSOR c_log(l_my_log_id VARCHAR2) IS
   SELECT rowid
     FROM ams_act_logs
    WHERE activity_log_id = l_my_log_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_act_log;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   -- open cursor AND fetch into local variable
   OPEN c_log_seq;
   FETCH c_log_seq INTO l_act_log_id,l_log_tran_id ;
   CLOSE c_log_seq;


   INSERT INTO ams_act_logs (
      activity_log_id
      -- standard who columns
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,object_version_number
      ,act_log_used_by_id
      ,arc_act_log_used_by
      ,log_transaction_id
      ,log_message_text
      ,log_message_level
      ,log_message_type
      ,description
      ,budget_id
      ,threshold_id
      ,notification_creation_date
   )
   VALUES (
       NVL(p_activity_log_id,l_act_log_id)
      -- standard who columns
      ,SYSDATE
      ,FND_GLOBAL.User_Id
      ,SYSDATE
      ,FND_GLOBAL.User_Id
      ,FND_GLOBAL.Conc_Login_Id
      ,1                 -- Object Version Number
      ,p_log_used_by_id
      ,p_arc_log_used_by
      ,NVL(p_transaction_id,l_log_tran_id)
      ,p_msg_data
      ,p_msg_level
      ,p_msg_type
      ,p_desc
      ,p_budget_id
      ,p_threshold_id
      ,p_notification_creat_date
   ) ;


   OPEN c_log(l_act_log_id);
   FETCH c_log INTO x_rowid;
   IF (c_log%NOTFOUND) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   END IF;
   CLOSE c_log;

   --
   -- END of API body.
   --

   COMMIT;
EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO create_act_log;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END create_log;


---------------------------------------------------------------------
-- PROCEDURE
--    get_qual_table_name_and_pk
--
-- HISTORY
--    05/20/99    tdonohoe Created.
--    10/13/99    ptendulk Removed Parameter p_qual_id;
--       Added qualifiers DELI, EVEH;
--       Changed the name from Event Offerings to Event Offers
--       Changed the name from Event Offerings to Event Offers
--    01/06/99    ptendulk Changed the return Statuses to Standard
--    return statuses
--    04/24/00    tdonohoe Added Qualifier 'FCST' Forecast.
--    06/14/00    ptendulk Added qualifier 'OFFR' Offers
--    06/28/00    rchahal  Added Qualifier 'FUND' Fund.
-- 30-Jan-2001    ptendulk Modified Qualifier table for Schedules.
-- 06-Apr-2001    choang   Added DIWB, MODL and SCOR in get_qual_table_name_and_pk
--                         added error message if no valid sys_qual mapped.
-- 09-Apr-2001    choang   added CELL
-- 13-Jun-2001    ptendulk Added EONE
-- 15-Jun-2001    choang   Changed OFFR to return ozf_offers and qp_list_header_id.
---------------------------------------------------------------------
PROCEDURE get_qual_table_name_and_pk(
   p_sys_qual      IN    VARCHAR2,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_table_name    OUT NOCOPY   VARCHAR2,
   x_pk_name       OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   -- initialize return status
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_sys_qual ='CSCH') THEN
      -- Start of code modified by ptendulk on 30-Jan-2001
      --x_table_name    := 'AMS_CAMPAIGN_SCHEDULES';
      --x_pk_name       := 'CAMPAIGN_SCHEDULE_ID';
      -- End of code modified by ptendulk on 30-Jan-2001
      x_table_name    := 'AMS_CAMPAIGN_SCHEDULES_B';
      x_pk_name       := 'SCHEDULE_ID';
   ELSIF (p_sys_qual ='CAMP') THEN
      -- Start of code modified by ptendulk on 30-Jan-2001
      --x_table_name    := 'AMS_CAMPAIGNS_VL';
      -- End of code modified by ptendulk on 30-Jan-2001
      x_table_name    := 'AMS_CAMPAIGNS_ALL_B';
      x_pk_name       := 'CAMPAIGN_ID';
   ELSIF (p_sys_qual ='EVEO') THEN
      x_table_name    := 'AMS_EVENT_OFFERS_VL';
      x_pk_name       := 'EVENT_OFFER_ID';
   ELSIF (p_sys_qual ='EONE') THEN
      x_table_name    := 'AMS_EVENT_OFFERS_VL';
      x_pk_name       := 'EVENT_OFFER_ID';
   ELSIF (p_sys_qual ='EVEH') THEN
      x_table_name    := 'AMS_EVENT_HEADERS_VL';
      x_pk_name       := 'EVENT_HEADER_ID';
   ELSIF (p_sys_qual ='DELV') THEN
      x_table_name    := 'AMS_DELIVERABLES_VL';
      x_pk_name       := 'DELIVERABLE_ID';
   ELSIF (p_sys_qual ='AMET') THEN
      x_table_name    := 'OZF_ACT_METRICS_ALL';
      x_pk_name       := 'ACTIVITY_METRIC_ID';
   --=========================================================
   -- Following line of code is added by ptendulk on 14Jun2000
   --=========================================================
   ELSIF (p_sys_qual ='OFFR') THEN --added tdonohoe 04/24/2000
      x_table_name    := 'OZF_OFFERS';
      x_pk_name       := 'QP_LIST_HEADER_ID';
   ELSIF (p_sys_qual ='FCST') THEN --added tdonohoe 04/24/2000
      x_table_name    := 'OZF_ACT_FORECASTS_ALL';
      x_pk_name       := 'FORECAST_ID';
   ELSIF (p_sys_qual ='FUND') THEN --added rchahal 06/28/2000
      -- yzhao 10/13/2003 fix bug 3167497 changed from OZF_FUND_DETAILS_V to ozf_funds_all_b
      x_table_name    := 'OZF_FUNDS_ALL_B';  -- yzhao: 'OZF_FUND_DETAILS_V';
      x_pk_name       := 'FUND_ID';
    ELSIF (p_sys_qual ='PRIC') THEN --added skarumur 12/17/2000
       x_table_name    := 'AMS_PRICE_LIST_ATTRIBUTES';
       x_pk_name       := 'QP_LIST_HEADER_ID';
    ELSIF (p_sys_qual ='LIST') THEN --added gjoby 03/26/2001
       x_table_name    := 'OZF_LIST_HEADERS_VL';
       x_pk_name       := 'LIST_HEADER_ID';
    ELSIF (p_sys_qual ='IMPH') THEN --added gjoby 03/26/2001
       x_table_name    := 'AMS_IMP_LIST_HEADERS_VL';
       x_pk_name       := 'IMPORT_LIST_HEADER_ID';
    ELSIF (p_sys_qual ='SQL') THEN --added gjoby 03/26/2001
       x_table_name    := 'OZF_LIST_QUERIES_ALL';
       x_pk_name       := 'LIST_QUERY_ID';
   ELSIF p_sys_qual = 'DIWB' THEN
      x_table_name := 'OZF_DISCOVERER_SQL';
      x_pk_name := 'DISCOVERER_SQL_ID';
   ELSIF p_sys_qual = 'MODL' THEN
      x_table_name := 'OZF_DM_MODELS_ALL_B';
      x_pk_name := 'MODEL_ID';
   ELSIF p_sys_qual = 'SCOR' THEN
      x_table_name := 'OZF_DM_SCORES_ALL_B';
      x_pk_name := 'SCORE_ID';
   ELSIF p_sys_qual = 'CELL' THEN
      x_table_name := 'AMS_CELLS_ALL_B';
      x_pk_name := 'CELL_ID';
   ELSIF (p_sys_qual = 'RCAM') THEN
      x_table_name    := 'AMS_CAMPAIGNS_ALL_B';
      x_pk_name       := 'CAMPAIGN_ID';
   ELSIF p_sys_qual = 'DILG' THEN  -- Added dmvincen 03/27/2002
      x_table_name    := 'OZF_DIALOGS_ALL_B';
      x_pk_name       := 'DIALOG_ID';
   ELSIF p_sys_qual in  -- Added dmvincen 03/27/2002
         ('OZF_COMP_START', 'OZF_COMP_SHOW_WEB_PAGE', 'OZF_COMP_END') THEN
      x_table_name    := 'OZF_DLG_FLOW_COMPS_B';
      x_pk_name       := 'FLOW_COMPONENT_ID';
   ELSE
      OZF_Utility_PVT.error_message ('OZF_INVALID_SYS_QUAL', 'SYS_QUALIFIER', p_sys_qual);
      x_return_status := FND_API.g_ret_sts_unexp_error;
      x_table_name    := NULL;
      x_pk_name       := NULL;
   END IF;

END get_qual_table_name_and_pk;


--------------------------------------------------------------------
-- NAME
--    get_source_code
--
-- HISTORY
--   08/18/99  tdonohoe  Created.
--------------------------------------------------------------------
PROCEDURE get_source_code(
   p_activity_type IN    VARCHAR2,
   p_activity_id   IN    NUMBER,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_source_code   OUT NOCOPY   VARCHAR2 ,
   x_source_id     OUT NOCOPY   NUMBER
)
IS
BEGIN

   SELECT source_code,source_code_for_id INTO x_source_code,x_source_id
     FROM ams_source_codes
    WHERE arc_source_code_for = UPPER(p_activity_type)
      AND source_code_for_id  = UPPER(p_activity_id);



   IF SQL%NOTFOUND THEN
      x_return_status := FND_API.G_FALSE;
   ELSE
       x_return_status := FND_API.G_TRUE;
   END IF;


EXCEPTION

   WHEN OTHERS THEN
      x_source_code := NULL;
      x_source_id := NULL;
      x_return_status := FND_API.G_FALSE;

End;


---------------------------------------------------------------------
-- FUNCTION
--   get_object_name
--
-- HISTORY
--   10/15/99  holiu    Created.
--   11/03/99  mpande   inserted deliverable,event
--   11/16/99  tdonohoe inserted campaign schedule.
-- 09-Dec-1999 choang   Changed references of ozf_event_offers_all_vl to
--                      ams_event_offers_vl and ozf_event_headers_all_vl
--                      to ams_event_headers_vl.
-- 24-Aug-2000 choang   Added FUND
-- 28-Sep-2000 choang   Added PRTN
-- 13-Jun-2001    ptendulk Added EONE
-- 15-Jun-2001 choang   changed PRNT to PTNR
--------------------------------------------------------------------
FUNCTION get_object_name(
   p_sys_arc_qualifier IN VARCHAR2,
   p_object_id         IN NUMBER
)
RETURN VARCHAR2
IS

   l_object_name  VARCHAR2(1000);

   CURSOR c_campaign(p_object_id IN NUMBER) IS
   SELECT campaign_name
     FROM ams_campaigns_vl
    WHERE campaign_id = p_object_id;

  --added 11/16/99 tdonohoe
  CURSOR c_campaign_sched(p_object_id IN NUMBER) IS
  SELECT c.campaign_name
  FROM   ams_campaigns_vl c,
         ams_campaign_schedules s
  WHERE s.campaign_schedule_id = p_object_id
  AND   s.campaign_id          = c.campaign_id;

  CURSOR c_deliv(p_object_id IN NUMBER) IS
   SELECT deliverable_name
     FROM ams_deliverables_vl
    WHERE deliverable_id = p_object_id;

   CURSOR c_event_header(p_object_id IN NUMBER) IS
   SELECT event_header_name
     FROM ams_event_headers_vl
    WHERE event_header_id = p_object_id;

  CURSOR c_event_offer(p_object_id IN NUMBER) IS
   SELECT event_offer_name
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_object_id;
--- updated by mpande 01/30/2001 to look into ozf_funds_all_vl not ozf_funds_vl
   CURSOR c_fund (p_object_id IN NUMBER) IS
      SELECT short_name
      FROM   ozf_funds_all_vl
      WHERE  fund_id = p_object_id;

   CURSOR c_partner (p_object_id IN NUMBER) IS
      SELECT party_name
      FROM   hz_parties
      WHERE  party_id = p_object_id;
BEGIN

   l_object_name := NULL;

   IF p_sys_arc_qualifier IS NULL OR p_object_id IS NULL THEN
      RETURN l_object_name;
   END IF;

   IF p_sys_arc_qualifier = 'CAMP' THEN
      OPEN c_campaign(p_object_id);
      FETCH c_campaign INTO l_object_name;
      CLOSE c_campaign;
   ELSIF p_sys_arc_qualifier = 'CSCH' THEN
      OPEN c_campaign_sched(p_object_id);
      FETCH c_campaign_sched INTO l_object_name;
      CLOSE c_campaign_sched;
   ELSIF p_sys_arc_qualifier = 'DELI' THEN
      OPEN c_deliv(p_object_id);
      FETCH c_deliv INTO l_object_name;
      CLOSE c_deliv;
   ELSIF p_sys_arc_qualifier = 'EVEH' THEN
      OPEN c_event_header(p_object_id);
      FETCH c_event_header INTO l_object_name;
      CLOSE c_event_header;
   ELSIF p_sys_arc_qualifier = 'EVEO' THEN
      OPEN c_event_offer(p_object_id);
      FETCH c_event_offer INTO l_object_name;
      CLOSE c_event_offer;
   ELSIF p_sys_arc_qualifier = 'EONE' THEN
      OPEN c_event_offer(p_object_id);
      FETCH c_event_offer INTO l_object_name;
      CLOSE c_event_offer;
   ELSIF p_sys_arc_qualifier = 'FUND' THEN
      OPEN c_fund (p_object_id);
      FETCH c_fund INTO l_object_name;
      CLOSE c_fund;
   ELSIF p_sys_arc_qualifier = 'PTNR' THEN
      OPEN c_partner (p_object_id);
      FETCH c_partner INTO l_object_name;
      CLOSE c_partner;
   END IF;

   RETURN l_object_name;

END get_object_name;


---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE
--    Modified from code done by ptendulk.
-- HISTORY
-- 08-Dec-1999 choang        Created.
-- 31-Aug-2000 ptendulk      Added x_conversion_type parameter to the
--                           Convert_Closest_Amount procedure
-- 09-Oct-2000 choang        Modified error message handling for no rate
--                           and invalid currency.
---------------------------------------------------------------------
PROCEDURE Convert_Currency (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER
)
IS
   L_CONVERSION_TYPE_PROFILE  CONSTANT VARCHAR2(30) := 'OZF_CURR_CONVERSION_TYPE';
   L_USER_RATE             CONSTANT NUMBER := 1;   -- Currenty not used.
   L_MAX_ROLL_DAYS         CONSTANT NUMBER := -1;  -- Negative so API rolls back to find the last conversion rate.
   l_denominator           NUMBER;  -- Not used in Marketing.
   l_numerator             NUMBER;  -- Not used in Marketing.
   l_rate                  NUMBER;  -- Not used in Marketing.
   l_conversion_type       VARCHAR2(30);  -- Currency conversion type; see API documention for details.
   l_conv_date             DATE;
BEGIN
   -- Initialize return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the currency conversion type from profile option
   l_conversion_type := FND_PROFILE.Value (L_CONVERSION_TYPE_PROFILE);

   --bug 8532055
   IF p_conv_date = FND_API.G_MISS_DATE OR p_conv_date IS NULL THEN
      l_conv_date := SYSDATE;
   ELSE
      l_conv_date := p_conv_date;
   END IF;

   -- Call the proper GL API to convert the amount.
   GL_Currency_API.Convert_Closest_Amount (
      x_from_currency         => p_from_currency,
      x_to_currency           => p_to_currency,
      x_conversion_date       => l_conv_date,
      x_conversion_type       => l_conversion_type,
      x_user_rate             => L_USER_RATE,
      x_amount                => p_from_amount,
      x_max_roll_days         => L_MAX_ROLL_DAYS,
      x_converted_amount      => x_to_amount,
      x_denominator           => l_denominator,
      x_numerator             => l_numerator,
      x_rate                  => l_rate
   );
EXCEPTION
   WHEN GL_Currency_API.NO_RATE THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('OZF', 'OZF_NO_RATE');
         FND_MESSAGE.Set_Token ('CURRENCY_FROM', p_from_currency);
         FND_MESSAGE.Set_Token ('CURRENCY_TO', p_to_currency);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN GL_Currency_API.INVALID_CURRENCY THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('OZF', 'OZF_INVALID_CURR');
         FND_MESSAGE.Set_Token ('CURRENCY_FROM', p_from_currency);
         FND_MESSAGE.Set_Token ('CURRENCY_TO', p_to_currency);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
END Convert_Currency;

---------------------------------------------------------------------
-- PROCEDURE
--    get_lookup_meaning
-- created by mpande 01/11/00
-- PURPOSE
--    This procedure will return the meaning from ozf_lookups if
--  you pass the right lookup_type and lookup_code
-- HISTORY
-- 28-Apr-2000 choang   Modified to use explicit cursor.
-- 07-Aug-2000 choang   Added close cursor for success conditions
--                      in the fetch.
---------------------------------------------------------------------

PROCEDURE get_lookup_meaning (
   p_lookup_type      IN    VARCHAR2,
   p_lookup_code      IN   VARCHAR2,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_meaning       OUT NOCOPY   VARCHAR2
)
IS
   CURSOR c_meaning IS
      SELECT meaning
      FROM   ozf_lookups
      WHERE  lookup_type = UPPER (p_lookup_type)
      AND    lookup_code = UPPER (p_lookup_code);
BEGIN
   OPEN c_meaning;
   FETCH c_meaning INTO x_meaning;
   IF c_meaning%NOTFOUND THEN
      CLOSE c_meaning;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_meaning:=  NULL;
   ELSE
      CLOSE c_meaning;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF c_meaning%ISOPEN THEN
         CLOSE c_meaning;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_meaning :=  NULL;
END get_lookup_meaning;


---------------------------------------------------------------------
-- PROCEDURE
--    get_System_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the System Timezone profile option
-- HISTORY   created    04/24/2000 sugupta
-- 17-May-2002 choang   bug 2224836: changed to use SERVER_TIMEZONE_ID
---------------------------------------------------------------------
PROCEDURE get_System_Timezone(

x_return_status   OUT NOCOPY   VARCHAR2,
x_sys_time_id     OUT NOCOPY   NUMBER,
x_sys_time_name     OUT NOCOPY VARCHAR2
) IS

l_sys_time_id  NUMBER;
l_sys_name   VARCHAR2(80);

cursor c_get_name(l_time_id IN NUMBER) is
select NAME
 from  HZ_TIMEZONES_VL
 where TIMEZONE_ID = l_time_id;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_sys_time_id := FND_PROFILE.VALUE('SERVER_TIMEZONE_ID');
   OPEN c_get_name(l_sys_time_id);
   FETCH c_get_name into l_sys_name;
   IF (c_get_name%NOTFOUND) THEN
      CLOSE c_get_name;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     return;
    END IF;
   CLOSE c_get_name;

   x_sys_time_id := l_sys_time_id;
   x_sys_time_name := l_sys_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF (c_get_name%ISOPEN) THEN
         CLOSE c_get_name;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_System_Timezone;

---------------------------------------------------------------------
-- PROCEDURE
--    get_User_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the User Timezone profile option
-- HISTORY   created    04/24/2000 sugupta
-- 17-May-2002 choang   bug 2224836: changed to use CLIENT_TIMEZONE_ID
---------------------------------------------------------------------
PROCEDURE get_User_Timezone(

x_return_status   OUT NOCOPY   VARCHAR2,
x_user_time_id    OUT NOCOPY   NUMBER,
x_user_time_name  OUT NOCOPY   VARCHAR2
) IS

l_user_time_id  NUMBER;
l_user_time_name   VARCHAR2(80);

cursor get_name(l_time_id IN NUMBER) is
select NAME
 from  HZ_TIMEZONES_VL
 where TIMEZONE_ID = l_time_id;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_user_time_id := FND_PROFILE.VALUE('CLIENT_TIMEZONE_ID');
   OPEN get_name(l_user_time_id);
   FETCH get_name into l_user_time_name;
   IF (get_name%NOTFOUND) THEN
      CLOSE get_name;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     return;
    END IF;
   CLOSE get_name;

   x_user_time_id := l_user_time_id;
   x_user_time_name := l_user_time_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF (get_name%ISOPEN) THEN
         CLOSE get_name;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_User_Timezone;

-------------------------------------------------------------------------------------------------
-- PROCEDURE
--    Convert_Timezone
--
-- PURPOSE
--    This procedure will take the user timezone and the input time, depending on the parameter
--    p_convert_type it will convert the input time to System timezone or sent Usertimezone
-- HISTORY
--     04/24/2000    sugupta    created
--     04/26/2000    ptendulk   Modified Added a parameter which will tell
--                              which timezone to convert time into.
--                              If the convert type is 'SYS' then input time will be
--                              converted into system timezone else it will be
--                              converted to user timezone .
---------------------------------------------------------------------------------------------------
PROCEDURE Convert_Timezone(
  p_init_msg_list       IN     VARCHAR2   := FND_API.G_FALSE,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_user_tz_id          IN     NUMBER   := null,
  p_in_time             IN     DATE  ,  -- required
  p_convert_type        IN     VARCHAR2 := 'SYS' , --  (SYS/USER)

  x_out_time            OUT NOCOPY    DATE
) IS

   l_sys_time_id     NUMBER;
   l_user_tz_id      NUMBER := p_user_tz_id ;
   l_sys_time_name      VARCHAR2(80);
   l_user_time_name     VARCHAR2(80);
   l_return_status      VARCHAR2(1);  -- Return value from procedures

        l_from_timezone_id      NUMBER ;
        l_to_timezone_id        NUMBEr ;
BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_System_Timezone(
      l_return_status,
      l_sys_time_id,
      l_sys_time_name);

   IF (l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
      x_return_status := l_return_status;
      RETURN;
   END IF;

        -- If the user timezone is not sent
        -- get it from profiles
        IF l_user_tz_id IS NULL THEN
              Get_User_Timezone(
                    x_return_status    => l_return_status,
                    x_user_time_id     => l_user_tz_id ,
                    x_user_time_name   => l_user_time_name
                    ) ;
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
      x_return_status := l_return_status;
      RETURN;
   END IF;

        IF p_convert_type = 'SYS' THEN
            l_from_timezone_id := l_user_tz_id ;
            l_to_timezone_id   := l_sys_time_id ;
        ELSIF p_convert_type = 'USER' THEN
            l_from_timezone_id := l_sys_time_id ;
            l_to_timezone_id   :=  l_user_tz_id ;
        END IF;

   HZ_TIMEZONE_PUB.get_time(
         p_api_version       => 1.0,
         p_init_msg_list     => p_init_msg_list,
         p_source_tz_id      => l_from_timezone_id ,
         p_dest_tz_id        => l_to_timezone_id ,
         p_source_day_time   => p_in_time,
         x_dest_day_time     => x_out_time,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data
                             );

END Convert_Timezone ;


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
            FND_MESSAGE.set_name('OZF', 'OZF_UTIL_NO_WHERE_OPERATOR');
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


---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
-- USAGE
--    Example:
--       SELECT OZF_Utility_PVT.get_lookup_meaning ('AMS_CAMPAIGN_STATUS', status_code)
--       FROM   ams_campaigns_vl;
-- HISTORY
-- 28-Apr-2000 choang   Created.
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
      FROM   ozf_lookups
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
--    get_resource_name
-- USAGE
--    Example:
--       SELECT OZF_Utility_PVT.get_resource_name (owner_user_id)
--       FROM   ams_campaigns_vl
-- HISTORY
-- 28-Apr-2000 choang   Created.
---------------------------------------------------------------------
FUNCTION get_resource_name (
   p_resource_id IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_resource_name   VARCHAR2(240);

   CURSOR c_resource_name IS
      SELECT full_name
      FROM   ams_jtf_rs_emp_v
      WHERE  resource_id = p_resource_id;
BEGIN
   IF p_resource_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_resource_name;
   FETCH c_resource_name INTO l_resource_name;
   CLOSE c_resource_name;

   RETURN l_resource_name;
END get_resource_name;


-----------------------------------------------------------------------
-- FUNCTION
--    is_in_my_division
--
-- HISTORY
--    07/28/2000  holiu  Created.
-----------------------------------------------------------------------
FUNCTION is_in_my_division(
   p_object_type   IN  VARCHAR2,
   p_object_id     IN  NUMBER,
   p_country_id    IN  NUMBER
)
RETURN VARCHAR2
IS

   l_area2          VARCHAR2(30);
   l_obj_area2     VARCHAR2(30);

   CURSOR c_area2 IS
   SELECT area2_code
   FROM   jtf_loc_hierarchies_vl
   WHERE  location_hierarchy_id = p_country_id;

   CURSOR c_camp_area2 IS
   SELECT B.area2_code
   FROM   ams_campaigns_vl A, jtf_loc_hierarchies_vl B
   WHERE  A.campaign_id = p_object_id
   AND    A.city_id = B.location_hierarchy_id;

BEGIN

   OPEN c_area2;
   FETCH c_area2 INTO l_area2;
   CLOSE c_area2;

   IF l_area2 IS NULL THEN
      RETURN 'N';
   END IF;

   IF p_object_type = 'CAMP' THEN
      OPEN c_camp_area2;
      FETCH c_camp_area2 INTO l_obj_area2;
      CLOSE c_camp_area2;
   END IF;

   IF l_area2 = l_obj_area2 THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

END is_in_my_division;


---------------------------------------------------------------------
-- FUNCTION
--    get_product_name
-- HISTORY
-- 14-JUN-2000 holiu    Create.
-- 10-Apr-2002 choang   applied changes requested by skarumur: removed
--                      l_product_name because it was declared as a
--                      varchar2(76) - too small for product name.
-- 13-Jun-2005 Ribha    Use p_org_id = -1 for bypassing access check
--                      (organization identifier)
-- 17-May-2006 asylvia  Include Return NULL for the function fixed bug 5226685
---------------------------------------------------------------------
FUNCTION get_product_name(
   p_prod_level IN  VARCHAR2,
   p_prod_id    IN  NUMBER,
   p_org_id     IN  NUMBER := NULL
)
RETURN VARCHAR2
IS
   CURSOR c_product_name IS
      SELECT padded_concatenated_segments
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = p_prod_id
      AND    organization_id = p_org_id;

   CURSOR  c_product_name_all IS
      SELECT DISTINCT padded_concatenated_segments
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = p_prod_id;

   CURSOR c_category_name IS
      SELECT description
      FROM   mtl_categories_v
      WHERE  category_id = p_prod_id;

   l_product_name    c_product_name%ROWTYPE;
   l_product_name_all    c_product_name_all%ROWTYPE;
   l_category_name   c_category_name%ROWTYPE;
BEGIN
   IF p_prod_id IS NULL THEN
      RETURN NULL;
   END IF;

   IF p_prod_level IN ('PRICING_ATTRIBUTE1', 'PRODUCT') THEN
      IF p_org_id = -1 THEN
        OPEN c_product_name_all;
        FETCH c_product_name_all INTO l_product_name_all;
        CLOSE c_product_name_all;
        RETURN l_product_name_all.padded_concatenated_segments;
      ELSE
        OPEN c_product_name;
        FETCH c_product_name INTO l_product_name;
        CLOSE c_product_name;
        RETURN l_product_name.padded_concatenated_segments;
      END IF;
   ELSIF p_prod_level IN ('PRICING_ATTRIBUTE2', 'CATEGORY','FAMILY') THEN
      OPEN c_category_name;
      FETCH c_category_name INTO l_category_name;
      CLOSE c_category_name;
      RETURN l_category_name.description;
   END IF;
   RETURN NULL;
END get_product_name;



---------------------------------------------------------------------
-- FUNCTION
--    get_price_list_name
-- HISTORY
--    14-JUN-2000  holiu  Create.
---------------------------------------------------------------------
FUNCTION get_price_list_name(
   p_price_list_line_id   IN  NUMBER
)
RETURN VARCHAR2
IS
   l_name  VARCHAR2(240);

   CURSOR c_price_list_name IS
   SELECT qlh.name
   FROM   qp_list_headers_vl qlh, qp_list_lines qll
   WHERE  qll.list_header_id = qlh.list_header_id
   AND    qll.list_line_id = p_price_list_line_id;
BEGIN
   IF p_price_list_line_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_price_list_name;
   FETCH c_price_list_name INTO l_name;
   CLOSE c_price_list_name;

   RETURN l_name;
END get_price_list_name;


---------------------------------------------------------------------
-- FUNCTION
--    get_uom_name
-- HISTORY
--    14-JUN-2000  holiu  Create.
---------------------------------------------------------------------
FUNCTION get_uom_name(
   p_uom_code  IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_name  VARCHAR2(25);

   CURSOR c_uom IS
   SELECT unit_of_measure
   FROM   mtl_units_of_measure
   WHERE  uom_code = p_uom_code;
BEGIN
   IF p_uom_code IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_uom;
   FETCH c_uom INTO l_name;
   CLOSE c_uom;

   RETURN l_name;
END get_uom_name;


---------------------------------------------------------------------
-- FUNCTION
--    get_qp_lookup_meaning
-- DESCRIPTION
--    Get the meaning of the given lookup code in qp_lookups.
---------------------------------------------------------------------
FUNCTION get_qp_lookup_meaning(
   p_lookup_type  IN  VARCHAR2,
   p_lookup_code  IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning  VARCHAR2(80);

   CURSOR c_meaning IS
   SELECT meaning
   FROM   qp_lookups
   WHERE  lookup_type = UPPER(p_lookup_type)
   AND    lookup_code = UPPER(p_lookup_code);
BEGIN
   IF p_lookup_type IS NULL OR p_lookup_code IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_meaning;
   FETCH c_meaning INTO l_meaning;
   CLOSE c_meaning;

   RETURN l_meaning;
END get_qp_lookup_meaning;

---------------------------------------------------------------------
-- FUNCTION
--   get_resource_id
-- DESCRIPTION
--   Returns resource_id from the JTF Resource module given
--   an AOL user_id.
---------------------------------------------------------------------
FUNCTION get_resource_id (
   p_user_id IN NUMBER
)
RETURN NUMBER
IS
   l_resource_id     NUMBER;

   CURSOR c_resource IS
      SELECT resource_id
      FROM   ams_jtf_rs_emp_v
      WHERE  user_id = p_user_id;
BEGIN
   OPEN c_resource;
   FETCH c_resource INTO l_resource_id;
   IF c_resource%NOTFOUND THEN
      l_resource_id := -1;
      -- Adding an error message will cause the function
    -- to violate the WNDS pragma, preventing it from
    -- being able to be called from a SQL statement.
   END IF;
   CLOSE c_resource;

   RETURN l_resource_id;
END get_resource_id;

---------------------------------------------------------------------
-- FUNCTION
--   Write_Conc_Log
-- DESCRIPTION
--   Writes the log for Concurrent programs
-- History
--   07-Aug-2000   PTENDULK    Created
--   08-Aug-2000   PTENDULK    Write the output in to log instead of output
-- NOTE
--   If the parameter p_text is passed then the value sent will be printed
--   as log else the messages in the stack are printed.
---------------------------------------------------------------------
PROCEDURE Write_Conc_Log
(   p_text            IN     VARCHAR2 := NULL)
IS
    l_count NUMBER;
    l_msg   VARCHAR2(2000);
    l_cnt   NUMBER ;
BEGIN
   IF p_text IS NULL THEN
       l_count := FND_MSG_PUB.count_msg;
       FOR l_cnt IN 1 .. l_count
       LOOP
           l_msg := FND_MSG_PUB.get(l_cnt, FND_API.g_false);
           FND_FILE.PUT_LINE(FND_FILE.LOG, '(' || l_cnt || ') ' || l_msg);
       END LOOP;
   ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG, p_text );
   END IF;

END Write_Conc_Log ;


-----------------------------------------------------------------------
-- FUNCTION
--    get_system_status_type
--
-- HISTORY
--    14-SEP-2000  holiu      Create.
--    29-May-2001  ptendulk   Added system status for Schedule
--    20-May-2001  ptendulk   Added system status for programs.
--    13-Jun-2001  ptendulk   Added EONE
-----------------------------------------------------------------------
FUNCTION get_system_status_type(
   p_object  IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN

   IF p_object = 'CAMP' THEN
      RETURN 'AMS_CAMPAIGN_STATUS';
   ELSIF p_object IN ('EVEH', 'EVEO','EONE', 'EVET') THEN
      RETURN 'AMS_EVENT_STATUS';
   ELSIF p_object = 'DELV' THEN
      RETURN 'AMS_DELIV_STATUS';
   ELSIF p_object = 'CSCH' THEN
      RETURN 'AMS_CAMPAIGN_SCHEDULE_STATUS' ;
   ELSIF p_object = 'RCAM' THEN
      RETURN 'AMS_PROGRAM_STATUS' ;
   ELSIF p_object = 'OFFR' THEN
      RETURN 'OZF_OFFER_STATUS' ;
   ELSIF p_object = 'PRIC' THEN
      RETURN 'OZF_PRICELIST_STATUS' ;
   ELSE
      RETURN NULL;
   END IF;

END get_system_status_type;


-----------------------------------------------------------------------
-- FUNCTION
--    get_system_status_code
--
-- HISTORY
--    14-SEP-2000  holiu  Create.
-----------------------------------------------------------------------
FUNCTION get_system_status_code(
   p_user_status_id   IN  NUMBER
)
RETURN VARCHAR2
IS

   l_status_code   VARCHAR2(30);

   CURSOR c_status_code IS
   SELECT system_status_code
   FROM   ams_user_statuses_vl
   WHERE  user_status_id = p_user_status_id
   AND    enabled_flag = 'Y';

BEGIN

   OPEN c_status_code;
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;

   RETURN l_status_code;

END get_system_status_code;


-----------------------------------------------------------------------
-- FUNCTION
--    get_default_user_status
--
-- HISTORY
--    14-SEP-2000  holiu  Create.
-----------------------------------------------------------------------
FUNCTION get_default_user_status(
   p_status_type  IN  VARCHAR2,
   p_status_code  IN  VARCHAR2
)
RETURN VARCHAR2
IS

   l_status_id  NUMBER;

   CURSOR c_status_id IS
   SELECT user_status_id
   FROM   ams_user_statuses_vl
   WHERE  system_status_type = p_status_type
   AND    system_status_code = p_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y';

BEGIN

   OPEN c_status_id;
   FETCH c_status_id INTO l_status_id;
   CLOSE c_status_id;

   RETURN l_status_id;

END get_default_user_status;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_status_change
--
-- HISTORY
--    14-SEP-2000  holiu  Create.
-----------------------------------------------------------------------
PROCEDURE check_status_change(
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_old_status_id    IN  NUMBER,
   p_new_status_id    IN  NUMBER,
   x_approval_type    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_theme_flag       VARCHAR2(1);
   l_budget_flag      VARCHAR2(1);
   l_status_type      VARCHAR2(30);
   l_old_status_code  VARCHAR2(30);
   l_new_status_code  VARCHAR2(30);

   CURSOR c_approval_flag IS
   SELECT theme_approval_flag, budget_approval_flag
   FROM   ams_status_order_rules
   WHERE  system_status_type = l_status_type
   AND    current_status_code = l_old_status_code
   AND    next_status_code = l_new_status_code;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   x_approval_type := NULL;

   l_status_type := get_system_status_type(p_object_type);
   l_old_status_code := get_system_status_code(p_old_status_id);
   l_new_status_code := get_system_status_code(p_new_status_id);

   IF l_old_status_code = l_new_status_code THEN
      RETURN;
   END IF;

   OPEN c_approval_flag;
   FETCH c_approval_flag INTO l_theme_flag, l_budget_flag;
   IF c_approval_flag%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.error_message('OZF_CAMP_BAD_STATUS_CHANGE');
   END IF;
   CLOSE c_approval_flag;

   IF l_budget_flag = 'Y' THEN
      IF AMS_ObjectAttribute_PVT.check_object_attribute(
            p_object_type, p_object_id, 'BAPL') = FND_API.g_true
      THEN
         x_approval_type := 'BUDGET';
      END IF;
   ELSIF l_theme_flag = 'Y' THEN
      IF AMS_ObjectAttribute_PVT.check_object_attribute(
            p_object_type, p_object_id, 'TAPL') = FND_API.g_true
      THEN
         x_approval_type := 'THEME';
      END IF;
   END IF;

END check_status_change;


--========================================================================
-- Function
--    Approval_required_flag
-- Purpose
--    This function will return the approval required flag for the
--    given custom setup.
--
-- History
--   16-Jun-2001    ptendulk    Created
--   19-Jun-2001    ptendulk    Check specific attribute (bug in last code)
--========================================================================
FUNCTION Approval_Required_Flag( p_custom_setup_id    IN   NUMBER ,
                                 p_approval_type      IN   VARCHAR2)
RETURN VARCHAR2 IS
   CURSOR c_custom_attr IS
   SELECT attr_available_flag
   FROM   ams_custom_setup_attr
   WHERE  custom_setup_id = p_custom_setup_id
   -- Following line is added by ptendulk on 19-Jun-2001
   AND    object_attribute = p_approval_type ;

   l_flag VARCHAR2(1) ;
BEGIN

   OPEN c_custom_attr;
   FETCH c_custom_attr INTO l_flag ;
   CLOSE c_custom_attr ;
   RETURN l_flag ;

END Approval_Required_Flag;

-----------------------------------------------------------------------
-- PROCEDURE
--    check_status_change
--
-- PURPOSE
--    This procedure is created to override the obsoleted check_status_change
--    procedure as object_attribute table is obsoleted now.
--
-- HISTORY
--    16-Jun-2001   ptendulk    Created
--    02-Jul-2002   musman      Added changes for deliverable approvals
-----------------------------------------------------------------------
PROCEDURE check_new_status_change(
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_old_status_id    IN  NUMBER,
   p_new_status_id    IN  NUMBER,
   p_custom_setup_id  IN  NUMBER,
   x_approval_type    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_theme_flag       VARCHAR2(1);
   l_budget_flag      VARCHAR2(1);
   l_status_type      VARCHAR2(30);
   l_old_status_code  VARCHAR2(30);
   l_new_status_code  VARCHAR2(30);

   l_custom_setup_attr   VARCHAR2(4) := 'TAPL';

   CURSOR c_approval_flag IS
   SELECT theme_approval_flag, budget_approval_flag
   FROM   ams_status_order_rules
   WHERE  system_status_type = l_status_type
   AND    current_status_code = l_old_status_code
   AND    next_status_code = l_new_status_code;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   x_approval_type := NULL;

   l_status_type := get_system_status_type(p_object_type);
   l_old_status_code := get_system_status_code(p_old_status_id);
   l_new_status_code := get_system_status_code(p_new_status_id);

   IF l_old_status_code = l_new_status_code THEN
      RETURN;
   END IF;

   OPEN c_approval_flag;
   FETCH c_approval_flag INTO l_theme_flag, l_budget_flag;
   IF c_approval_flag%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.error_message('OZF_CAMP_BAD_STATUS_CHANGE');
   END IF;
   CLOSE c_approval_flag;

   IF l_budget_flag = 'Y' THEN
      IF Approval_Required_Flag(p_custom_setup_id, 'BAPL') = 'Y'
      THEN
         x_approval_type := 'BUDGET';
      END IF;
   ELSIF l_theme_flag = 'Y' THEN

      /* since Deliv has only concept approval  */
      IF  p_object_type = 'DELV'
      THEN
         l_custom_setup_attr := 'CAPL';
      END IF;
      IF Approval_Required_Flag(p_custom_setup_id, l_custom_setup_attr) = 'Y'
      THEN
         x_approval_type := 'THEME';
      END IF;
   END IF;

END check_new_status_change;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE
-- HISTORY
-- 01-Sep-2000 slkrishn        Created.
-- 12-SEP-2000    mpande    Updated
-- 02/23/2001    mpande     Updated for getting org id query
-- 03/27/2001    MPANDE    MOved from OZF to OZF
---------------------------------------------------------------------
PROCEDURE convert_currency(
   p_set_of_books_id   IN       NUMBER
  ,p_from_currency     IN       VARCHAR2
  ,p_conversion_date   IN       DATE
  ,p_conversion_type   IN       VARCHAR2
  ,p_conversion_rate   IN       NUMBER
  ,p_amount            IN       NUMBER
  ,x_return_status     OUT NOCOPY      VARCHAR2
  ,x_acc_amount        OUT NOCOPY      NUMBER
  ,x_rate              OUT NOCOPY      NUMBER)
IS
   l_api_name         VARCHAR2(30) := 'Convert Currency';
   l_to_currenvy      VARCHAR2(30);
   l_max_roll_days    NUMBER       := -1;
   l_user_rate        NUMBER       := NVL(p_conversion_rate, 1);
   l_numerator        NUMBER;
   l_denominator      NUMBER;
   l_org_id           NUMBER;
   l_sob              NUMBER;
   l_to_currency      VARCHAR2(30);

   --
   -- get functional currency
   --       gs.mrc_sob_type_code,

   /*   CURSOR c_get_gl_info(
      p_org_id   IN   NUMBER)
   IS
      SELECT   gs.set_of_books_id
              ,gs.currency_code
      FROM     gl_sets_of_books gs
              ,org_organization_definitions org
      WHERE  gs.mrc_sob_type_code = 'P'
         AND org.set_of_books_id = gs.set_of_books_id
         AND org.operating_unit = p_org_id;
   */
   --02/23/2001 mpande changed as per Hornet requirements
   CURSOR c_get_gl_info( p_org_id   IN   NUMBER)
   IS
      SELECT gs.set_of_books_id
      ,      gs.currency_code
      FROM   gl_sets_of_books gs
      ,      ozf_sys_parameters_all org
      WHERE  org.set_of_books_id = gs.set_of_books_id
      AND    NVL(org.org_id, -99) = NVL(p_org_id, -99);

BEGIN

   l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

   IF l_org_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_ORG_ID_NOTFOUND');
         fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
     END IF;

   OPEN c_get_gl_info(l_org_id);
     FETCH c_get_gl_info INTO l_sob, l_to_currency;

     IF c_get_gl_info%NOTFOUND THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_GL_SOB_NOTFOUND');
         fnd_msg_pub.add;
       END IF;

       RAISE fnd_api.g_exc_error;
     END IF;
   CLOSE c_get_gl_info;

   --
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => l_to_currency
     ,x_conversion_date => p_conversion_date
     ,x_conversion_type => p_conversion_type
     ,x_user_rate => l_user_rate
     ,x_amount => p_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_acc_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_rate);
   --

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      RAISE;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END convert_currency;

---------------------------------------------------------------------
-- PROCEDURE
--    get_code_combinations
--
-- PURPOSE
--      get code_combination concacnenated segments and ids
-- 20-Sep-2000    slkrishn       Created
--   03/27/2001    MPANDE    MOved from OZF to OZF
---------------------------------------------------------------------
FUNCTION get_code_combinations(
   p_code_combination_id    IN   NUMBER
  ,p_chart_of_accounts_id   IN   NUMBER)
   RETURN VARCHAR2
IS
   l_api_name     VARCHAR2(30) := 'Get_Code_Combinations';
   l_result       BOOLEAN;
   l_app_name     VARCHAR2(30) := 'SQLGL';
   l_flex_code    VARCHAR2(30) := 'GL#';
BEGIN
   l_result := fnd_flex_keyval.validate_ccid(
                  appl_short_name => l_app_name
                 ,key_flex_code => l_flex_code
                 ,structure_number => p_chart_of_accounts_id
                 ,combination_id => p_code_combination_id);

   IF l_result THEN
      RETURN fnd_flex_keyval.concatenated_descriptions;
   ELSE
      RETURN '';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END get_code_combinations;
---------------------------------------------------------------------
-- PROCEDURE
--    Convert_functional_Curr
-- NOTE
-- This procedures takes in amount and converts it to the functional currency
--  and returns the converted amount,exchange_rate,set_of_book_id,
--  f-nctional_currency_code,exchange_rate_date

-- HISTORY
-- 20-Jul-2000 mpande        Created.
-- 02/23/2001    MPAnde     Updated for getting org id query
-- 03/27/2001    MPANDE    MOved from OZF to OZF
-- 01/13/2003    yzhao      fix bug BUG 2750841(same as 2741039) - pass in org_id, default to null
--parameter x_Amount1 IN OUT NUMBER -- reqd Parameter -- amount to be converted
--   x_TC_CURRENCY_CODE IN OUT VARCHAR2,
--   x_Set_of_books_id OUT NUMBER,
--   x_MRC_SOB_TYPE_CODE OUT NUMBER, 'P' and 'R'
--     We only do it for primary ('P' because we donot supprot MRC)
--   x_FC_CURRENCY_CODE OUT VARCHAR2,
--   x_EXCHANGE_RATE_TYPE OUT VARCHAR2,
--     comes from a OZF profile  or what ever is passed
--   x_EXCHANGE_RATE_DATE  OUT DATE,
--     could come from a OZF profile but right now is sysdate
--   x_EXCHANGE_RATE       OUT VARCHAR2,
--   x_return_status      OUT VARCHAR2
-- The following is the rule in the GL API
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required

---------------------------------------------------------------------


PROCEDURE calculate_functional_curr(
   p_from_amount          IN       NUMBER
  ,p_conv_date            IN       DATE DEFAULT SYSDATE
  ,p_tc_currency_code     IN       VARCHAR2
  ,p_org_id               IN       NUMBER DEFAULT NULL
  ,x_to_amount            OUT NOCOPY      NUMBER
  ,x_set_of_books_id      OUT NOCOPY      NUMBER
  ,x_mrc_sob_type_code    OUT NOCOPY      VARCHAR2
  ,x_fc_currency_code     OUT NOCOPY      VARCHAR2
  ,x_exchange_rate_type   IN OUT NOCOPY   VARCHAR2
  ,x_exchange_rate        IN OUT NOCOPY   NUMBER
  ,x_return_status        OUT NOCOPY      VARCHAR2)
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'OZF_CURR_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   -- Currenty not used. --  this should be a profile
   l_max_roll_days              CONSTANT NUMBER       := -1;
   -- Negative so API rolls back to find the last conversion rate.
   -- this should be a profile
   l_denominator                         NUMBER;   -- Not used in Marketing.
   l_numerator                           NUMBER;   -- Not used in Marketing.
   l_conversion_type                     VARCHAR2(30);
   l_org_id                              NUMBER;

   -- Cursor to get the primary set_of_books_id ,functional_currency_code
   -- changed the above query to look into operating unit and not organization_id
   --SEP12 mpande
   /*
   CURSOR c_get_gl_info(
      p_org_id   IN   NUMBER)
   IS
      SELECT   gs.set_of_books_id
              ,gs.currency_code
      FROM     gl_sets_of_books gs
              ,org_organization_definitions org
      WHERE  org.set_of_books_id = gs.set_of_books_id
         AND org.operating_unit = p_org_id;
   */
   --02/23/2001 mpande changed as per Hornet requirements
   CURSOR c_get_gl_info(p_org_id   IN   NUMBER)
   IS
      SELECT  gs.set_of_books_id
      ,       gs.currency_code
      FROM   gl_sets_of_books gs
      ,      ozf_sys_parameters_all org
      WHERE  org.set_of_books_id = gs.set_of_books_id
      AND    NVL(org.org_id, -99) = NVL(p_org_id, -99);

BEGIN
   -- Initialize return status.
   x_return_status := fnd_api.g_ret_sts_success;

   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   --    Mumu Pande        09/20/2000        Updated the following
   --    Get the currency conversion type from profile option
   IF x_exchange_rate_type IS NULL THEN
      l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);
   ELSE
      l_conversion_type := x_exchange_rate_type;
   END IF;

   IF l_conversion_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      IF ozf_utility_pvt.check_fk_exists('GL_DAILY_CONVERSION_TYPES',
                                       'CONVERSION_TYPE'
                         ,l_conversion_type) = fnd_api.g_false
    THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_WRONG_CONVERSION_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
   /* yzhao: 01/13/2003 fix bug BUG 2750841(same as 2741039) - use org_id if it is passed,
      otherwise get from login session */
   IF (p_org_id IS NOT NULL) THEN
       l_org_id := p_org_id;
   ELSE

       l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

       IF l_org_id IS NULL THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name('OZF', 'OZF_ORG_ID_NOTFOUND');
             fnd_msg_pub.add;
          END IF;

          RAISE fnd_api.g_exc_error;
       END IF;


   END IF;

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message('debug: start ' || l_org_id);
   END IF;

   x_mrc_sob_type_code := 'P';
   OPEN c_get_gl_info(l_org_id);
   FETCH c_get_gl_info INTO x_set_of_books_id, x_fc_currency_code;

   IF c_get_gl_info%NOTFOUND THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_GL_SOB_NOTFOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE c_get_gl_info;
   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_tc_currency_code
     ,x_to_currency => x_fc_currency_code
     ,x_conversion_date => p_conv_date
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => x_exchange_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_exchange_rate);

   x_exchange_rate_type := l_conversion_type;
   --

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_functional_curency');
      END IF;
END calculate_functional_curr;


--======================================================================
-- FUNCTION
--  get_fund_ledger

-- PURPOSE
--    The api return the budget's ledger in order:
--    ledger on budget if specified - ledger on budget category if specified - budget creator default OU's ledger
--    used for deriving budget's functional currency
-- HISTORY
--    30-Sep-2005  kdass  Create.
--======================================================================

PROCEDURE get_fund_ledger(
    p_fund_id       IN         NUMBER
   ,x_org_id        OUT NOCOPY NUMBER
   ,x_ledger_id     OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
   l_ledger_name               VARCHAR2(30) := NULL;

   CURSOR c_fund_ledger IS
       SELECT ledger_id
       FROM   ozf_funds_all_b
       WHERE  fund_id = p_fund_id;

BEGIN
    x_ledger_id := NULL;

    OPEN c_fund_ledger;
    FETCH c_fund_ledger INTO x_ledger_id;
    CLOSE c_fund_ledger;

    --07-APR-09 kdass bug 8402334 -- defaulted org_id to NULL for budget
    x_org_id := NULL;
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'OZF_UTLITY_PVT');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
      END IF;

END get_fund_ledger;


--======================================================================
-- FUNCTION
--  get_object_org_ledger

-- PURPOSE
--    The api return the object's org_id and ledger:
--      offer: org_id for local offer
--             user default org_id for global offer
--      pric:  org_id for price list
--      budget: budget's org_id
--              ledger on budget if specified - ledger on budget category if specified - budget creator default OU's ledger
--      others: user default org_id for global offer
-- HISTORY
--    13-Oct-2005  yzhao  Create.
--======================================================================

PROCEDURE get_object_org_ledger(
    p_object_id       IN         NUMBER
   ,p_object_type     IN         VARCHAR2
   ,x_org_id        OUT NOCOPY NUMBER
   ,x_ledger_id     OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
   l_ledger_name                 VARCHAR2(30);

      -- Cursor to get the org_id for offer
      CURSOR c_offer_org_id (p_list_header_id IN NUMBER)IS
         SELECT org_id
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_list_header_id;

      -- Cursor to get the org_id for pric
      CURSOR c_pric_org_id (p_list_header_id IN NUMBER)IS
         SELECT orig_org_id
         FROM   qp_list_headers_b
         WHERE  list_header_id = p_list_header_id;

--Bugfix: 7555174, 7415805 (Start)
      CURSOR C_GET_OFFERS_BUDGET_ID(p_list_header_id IN NUMBER)IS
         SELECT budget_source_id, budget_source_type
         FROM ozf_act_budgets
         WHERE act_budget_used_by_id=p_list_header_id;

      CURSOR c_camp_budget_id(p_campaign_id IN NUMBER) IS
         SELECT budget_source_id
         FROM ozf_act_budgets
         WHERE act_budget_used_by_id = p_campaign_id;

      l_budget_source_id NUMBER;
      l_budget_source_type VARCHAR2(30);
--Bugfix: 7555174, 7415805 (End)

BEGIN
    x_org_id := NULL;
    x_ledger_id := NULL;

    IF p_object_type = 'OFFR' THEN
       OPEN c_offer_org_id( p_object_id) ;
       FETCH c_offer_org_id INTO x_org_id ;
       CLOSE c_offer_org_id ;
       IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_pvt.debug_message ('get_object_org_ledger()  org_id for offer =' || x_org_id);
       END IF;
    ELSIF p_object_type = 'PRIC' THEN
       OPEN c_pric_org_id( p_object_id) ;
       FETCH c_pric_org_id INTO x_org_id ;
       CLOSE c_pric_org_id ;
       IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_pvt.debug_message ('get_object_org_ledger()  org_id for pric =' || x_org_id);
       END IF;
    ELSIF p_object_type = 'FUND' THEN
       get_fund_ledger(p_fund_id => p_object_id
                     , x_org_id => x_org_id
                     , x_ledger_id => x_ledger_id
                     , x_return_status => x_return_status);
       IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_pvt.debug_message ('get_object_org_ledger()  org_id for fund =' || x_org_id
                                         ||  ' ledger_id=' || x_ledger_id);
       END IF;
       IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END IF;

    --Bugfix - 7555174 : Modified x_org_id check
    --Start (Bug-7555174)
    /*
    IF x_org_id IS NULL THEN
       x_org_id := NVL(mo_global.get_current_org_id, mo_utils.get_default_org_id);
    END IF;
    */

    IF x_org_id IS NULL AND p_object_type = 'OFFR'  THEN
         OPEN C_GET_OFFERS_BUDGET_ID(p_object_id);
         FETCH C_GET_OFFERS_BUDGET_ID INTO l_budget_source_id,l_budget_source_type;
         CLOSE C_GET_OFFERS_BUDGET_ID;

         IF l_budget_source_type = 'CAMP' THEN
          OPEN c_camp_budget_id(l_budget_source_id);
          FETCH c_camp_budget_id INTO l_budget_source_id;
          CLOSE c_camp_budget_id;
         END IF;

        ozf_utility_pvt.debug_message ('NP get_object_org_ledger() l_budget_source_id '|| l_budget_source_id);
        get_fund_ledger(p_fund_id => l_budget_source_id
                     , x_org_id => x_org_id
                     , x_ledger_id => x_ledger_id
                     , x_return_status => x_return_status);
    END IF;

    IF x_org_id IS NULL AND p_object_type <> 'OFFR'  THEN
       x_org_id := NVL(mo_global.get_current_org_id, mo_utils.get_default_org_id);
    END IF;
    --End (Bug-7555174)

    IF x_org_id IS NOT NULL AND
       x_ledger_id IS NULL THEN
        MO_UTILS.Get_Ledger_Info (
            p_operating_unit     =>  x_org_id,
            p_ledger_id          =>  x_ledger_id,
            p_ledger_name        =>  l_ledger_name
        );
    END IF;

   IF OZF_DEBUG_HIGH_ON THEN
        ozf_utility_pvt.debug_message ('get_object_org_ledger()  final org_id =' || x_org_id
                                     ||  ' ledger_id=' || x_ledger_id);
   END IF;
    x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'OZF_UTLITY_PVT');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
      END IF;

END get_object_org_ledger;


---------------------------------------------------------------------
-- PROCEDURE
--    calculate_functional_currency
-- NOTE
-- This procedures takes in amount and converts it to the functional currency
--  and returns the converted amount,exchange_rate,ledger_id,
--  functional_currency_code,exchange_rate_date

-- HISTORY
-- 29-SEP-2005 kdass       Created.
---------------------------------------------------------------------
PROCEDURE calculate_functional_currency(
   p_from_amount          IN       NUMBER
  ,p_conv_date            IN       DATE DEFAULT SYSDATE
  ,p_tc_currency_code     IN       VARCHAR2
  ,p_ledger_id            IN       NUMBER DEFAULT NULL
  ,x_to_amount            OUT NOCOPY      NUMBER
  ,x_mrc_sob_type_code    OUT NOCOPY      VARCHAR2
  ,x_fc_currency_code     OUT NOCOPY      VARCHAR2
  ,x_exchange_rate_type   IN OUT NOCOPY   VARCHAR2
  ,x_exchange_rate        IN OUT NOCOPY   NUMBER
  ,x_return_status        OUT NOCOPY      VARCHAR2)
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'OZF_CURR_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   -- Currenty not used. --  this should be a profile
   l_max_roll_days              CONSTANT NUMBER       := -1;
   -- Negative so API rolls back to find the last conversion rate.
   -- this should be a profile
   l_denominator                         NUMBER;   -- Not used in Marketing.
   l_numerator                           NUMBER;   -- Not used in Marketing.
   l_conversion_type                     VARCHAR2(30);
   l_conv_date                           DATE;

   CURSOR c_get_gl_info(p_ledger_id IN NUMBER)
   IS
      SELECT currency_code
      FROM   gl_ledgers_public_v
      WHERE  ledger_id = p_ledger_id;

BEGIN
   -- Initialize return status.
   x_return_status := fnd_api.g_ret_sts_success;

   IF x_exchange_rate_type IS NULL OR x_exchange_rate_type=FND_API.G_MISS_CHAR THEN
      l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);
   ELSE
      l_conversion_type := x_exchange_rate_type;
   END IF;

   --bug 8532055
   IF p_conv_date = FND_API.G_MISS_DATE OR p_conv_date IS NULL THEN
      l_conv_date := SYSDATE;
   ELSE
      l_conv_date := p_conv_date;
   END IF;

   IF l_conversion_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
      IF ozf_utility_pvt.check_fk_exists('GL_DAILY_CONVERSION_TYPES',
                                       'CONVERSION_TYPE'
                         ,l_conversion_type) = fnd_api.g_false
    THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_WRONG_CONVERSION_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   x_mrc_sob_type_code := 'P';

   OPEN c_get_gl_info(p_ledger_id);
   FETCH c_get_gl_info INTO x_fc_currency_code;
   CLOSE c_get_gl_info;

   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_tc_currency_code
     ,x_to_currency => x_fc_currency_code
     ,x_conversion_date => l_conv_date
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => x_exchange_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_exchange_rate);

   x_exchange_rate_type := l_conversion_type;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_functional_curency');
      END IF;
END calculate_functional_currency;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE

-- HISTORY
-- 20-Jul-2000 mpande        Created.
--parameter p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_conv_date          IN  DATE DEFAULT SYSDATE,
--   p_from_amount        IN  NUMBER,
--   x_to_amount          OUT NUMBER
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required
-- 02/23/2001    MPAnde     Updated for getting org id query
-- 03/27/2001    MPANDE    MOved from OZF to OZF
-- 04/07/2001    slkrishn   Added p_conv_type and p_conv_rate with defaults
---------------------------------------------------------------------

PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER)
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'OZF_CURR_CONVERSION_TYPE';
   l_user_rate                  CONSTANT NUMBER       := 1;
   -- Currenty not used.
   -- this should be a profile
   l_max_roll_days              CONSTANT NUMBER       := -1;
   -- Negative so API rolls back to find the last conversion rate.
   -- this should be a profile
   l_denominator      NUMBER;   -- Not used in Marketing.
   l_numerator        NUMBER;   -- Not used in Marketing.
   l_conversion_type  VARCHAR2(30); -- Curr conversion type; see API doc for details.
   l_conv_date        DATE;
BEGIN
   -- Initialize return status.
   x_return_status := fnd_api.g_ret_sts_success;

   -- condition added to pass conversion types
   IF p_conv_type = FND_API.G_MISS_CHAR OR p_conv_type IS NULL THEN --Added for bug 7030415
     -- Get the currency conversion type from profile option
     l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);
     -- Conversion type cannot be null in profile
     IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
     END IF;
   ELSE
     l_conversion_type := p_conv_type;
   END IF;

   --bug 8532055
   IF p_conv_date = FND_API.G_MISS_DATE OR p_conv_date IS NULL THEN
      l_conv_date := SYSDATE;
   ELSE
      l_conv_date := p_conv_date;
   END IF;

   -- Call the proper GL API to convert the amount.
   gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => p_to_currency
     ,x_conversion_date => l_conv_date
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => p_conv_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => x_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => x_rate);
   --

EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_curency');
      END IF;
END convert_currency;

/*============================================================================*/
-- Start of Comments
-- NAME
--   Get_Resource_Role
--
-- PURPOSE
--   This Procedure will be return the workflow user role for
--   the resourceid sent
-- Called By
-- NOTES
-- End of Comments

/*============================================================================*/

PROCEDURE Get_Resource_Role
(  p_resource_id            IN     NUMBER,
   x_role_name          OUT NOCOPY    VARCHAR2,
   x_role_display_name  OUT NOCOPY    VARCHAR2 ,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_error_msg              VARCHAR2(4000);

   CURSOR c_resource IS
   SELECT employee_id , user_id, category
   FROM ams_jtf_rs_emp_v
   WHERE resource_id = p_resource_id ;

   l_person_id number;
   l_user_id number;
   l_category  varchar2(30);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN c_resource ;
   FETCH c_resource INTO l_person_id , l_user_id, l_category;
   IF c_resource%NOTFOUND THEN
      CLOSE c_resource ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OZF_Utility_PVT.error_message ('OZF_APPR_INVALID_RESOURCE_ID');
      return;
   END IF;
   CLOSE c_resource ;
      -- Pass the Employee ID to get the Role
   IF l_category = 'PARTY' THEN
      WF_DIRECTORY.getrolename
      (  p_orig_system     => 'FND_USR',
         p_orig_system_id    => l_user_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
      );
      IF x_role_name is null  then
         x_return_status := FND_API.G_RET_STS_ERROR;
         OZF_Utility_PVT.error_message ('OZF_APPR_INVALID_ROLE');
         return;
      END IF;
   ELSE
      WF_DIRECTORY.getrolename
      (  p_orig_system     => 'PER',
         p_orig_system_id    => l_person_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
      );
      IF x_role_name is null  then
         x_return_status := FND_API.G_RET_STS_ERROR;
         OZF_Utility_PVT.error_message ('OZF_APPR_INVALID_ROLE');
         return;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Get_Resource_Role');
      END IF;
      RAISE;
END Get_Resource_Role;

--======================================================================
-- Procedure Name: send_wf_standalone_message
-- Type          : Generic utility
-- Pre-Req :
-- Notes:
--    Common utility to send standalone message without initiating
--    process using workflow.
-- Parameters:
--    IN:
--    p_item_type          IN  VARCHAR2   Required   Default =  "MAPGUTIL"
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
--    p_send_to_res_id     IN   NUMBER   Optional
--                             Resource Id that will be used to get role name from WF_DIRECTORY.
--                             This is required if role name is not passed.

--   OUT:
--    x_notif_id           OUT  NUMBER
--                             Notification Id created that is being sent to recipient.
--    x_return_status      OUT   VARCHAR2
--                             Return status. If it is error, messages will be put in mesg pub.
-- History:
-- 11-Jan-2002 sveerave        Created.
--======================================================================

PROCEDURE send_wf_standalone_message(
   p_item_type          IN       VARCHAR2 := 'MAPGUTIL'
  ,p_message_name       IN       VARCHAR2 := 'GEN_STDLN_MESG'
  ,p_subject            IN       VARCHAR2
  ,p_body               IN       VARCHAR2 := NULL
  ,p_send_to_role_name  IN       VARCHAR2  := NULL
  ,p_send_to_res_id     IN       NUMBER := NULL
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
      OZF_UTILITY_PVT.get_resource_role
      (  p_resource_id   =>    p_send_to_res_id,
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

--======================================================================
-- FUNCTION
--    Check_Status_Change
--
-- PURPOSE
--    Created to check if the status change is valid or not.
--    Returns FND_API.G_TRUE if it is valid status change
--          or will return FND_API.G_FALSE
--
-- HISTORY
--    09-Jul-2001  ptendulk  Create.
--======================================================================
FUNCTION Check_Status_Change(
   p_status_type      IN  VARCHAR2,
   p_current_status   IN  VARCHAR2,
   p_next_status      IN  VARCHAR2
)
RETURN VARCHAR2
IS
   CURSOR c_stat_det IS
   SELECT 1 FROM DUAL
   WHERE EXISTS (SELECT * FROM ams_status_order_rules
                 WHERE current_status_code = p_current_status
                 AND   next_status_code = p_next_status
                 AND   system_status_type = p_status_type ) ;
   l_dummy NUMBER ;
BEGIN

   OPEN c_stat_det ;
   FETCH c_stat_det INTO l_dummy ;
   CLOSE c_stat_det;

   IF l_dummy IS NULL THEN
      RETURN FND_API.G_FALSE ;
   ELSE
      RETURN FND_API.G_TRUE ;
   END IF ;
END Check_Status_Change;
--======================================================================
-- FUNCTION
--    CurrRound
--
-- PURPOSE
--    Returns the round value for an amount based on the currency
--
-- HISTORY
--    13-Sep-2001  slkrishn  Create.
--======================================================================
FUNCTION CurrRound(
    p_amount IN NUMBER,
    p_currency_code IN VARCHAR2
)
RETURN NUMBER
IS
BEGIN
 RETURN gl_mc_currency_pkg.CurrRound(p_amount, p_currency_code);
END CurrRound;

--======================================================================
-- PROCEDURE
--    get_install_info
--
-- PURPOSE
--    Gets the installation information for an application
--    with application_id p_dep_appl_id
--
-- HISTORY
--    19-Dec-2002  mayjain  Create.
--======================================================================
procedure get_install_info(p_appl_id     in  number,
                           p_dep_appl_id in  number,
                           x_status      out nocopy varchar2,
                           x_industry    out nocopy varchar2,
                           x_installed   out nocopy number)
        IS
          l_installed BOOLEAN;

        BEGIN
           l_installed := fnd_installation.get( appl_id     => p_appl_id,
                                                dep_appl_id => p_dep_appl_id,
                                                status      => x_status,
                                                industry    => x_industry );
          IF (l_installed) THEN
             x_installed := 1;
          ELSE
             x_installed := 0;
          END IF;

        END get_install_info;

--======================================================================
-- PROCEDURE
--    Get_Object_Name
--
-- PURPOSE
--    Callback method for IBC to get the Associated Object name for an
--    Electronic Deliverable Attachment.
--
-- HISTORY
--    3/7/2003  mayjain  Create.
--======================================================================
PROCEDURE Get_Object_Name(
          p_association_type_code       IN              VARCHAR2
        ,p_associated_object_val1       IN              VARCHAR2
        ,p_associated_object_val2       IN              VARCHAR2
        ,p_associated_object_val3       IN              VARCHAR2 DEFAULT NULL
        ,p_associated_object_val4       IN              VARCHAR2 DEFAULT NULL
        ,p_associated_object_val5       IN              VARCHAR2 DEFAULT NULL
        ,x_object_name                  OUT NOCOPY      VARCHAR2
        ,x_object_code                  OUT NOCOPY      VARCHAR2
        ,x_return_status                OUT NOCOPY      VARCHAR2
        ,x_msg_count                    OUT NOCOPY      NUMBER
        ,x_msg_data                     OUT NOCOPY      VARCHAR2
)
IS


CURSOR Cur_Delv(p_delv_id IN NUMBER)
IS
SELECT  deliverable_name
FROM    ams_deliverables_vl
WHERE   deliverable_id = p_delv_id;


l_api_name  CONSTANT VARCHAR2(30)   := 'GET_OBJECT_NAME';
G_PKG_NAME  CONSTANT VARCHAR2(30)   := 'OZF_UTILITY_PVT';

BEGIN

        If p_association_type_code = 'OZF_DELV' then
          x_return_status := FND_API.G_RET_STS_SUCCESS;

                OPEN Cur_Delv(p_associated_object_val1);
                FETCH Cur_Delv INTO x_object_name;
                CLOSE Cur_Delv;


        END IF;
        -- here you can add processing for other association type as the else part

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get (      p_count => x_msg_count,
                                                p_data  => x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get (      p_count => x_msg_count,
                                                p_data  => x_msg_data);
           WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
               THEN
                   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
               END IF;
               FND_MSG_PUB.Count_And_Get (      p_count => x_msg_count,
                                                p_data  => x_msg_data);

        END Get_Object_Name;



     --========================================================================
     -- PROCEDURE
     --    get_user_id
     --
     -- PURPOSE
     --    This api will take a resource id and give the corresponding user_id
     --
     -- NOTE
     --
     -- HISTORY
     --  28-may-2003    soagrawa    Created
     --========================================================================


     FUNCTION get_user_id (
        p_resource_id IN NUMBER
     )
     RETURN NUMBER
     IS
        l_user_id     NUMBER;

        CURSOR c_user IS
           SELECT user_id
           FROM   ams_jtf_rs_emp_v
           WHERE  resource_id = p_resource_id;
     BEGIN
        OPEN c_user;
        FETCH c_user INTO l_user_id;
        IF c_user%NOTFOUND THEN
           l_user_id := -1;
        END IF;
        CLOSE c_user;

        RETURN l_user_id;
     END get_user_id;

--========================================================================
-- PROCEDURE
--    get_party_name
--
-- PURPOSE
--    This api returns party name given the customer_account_id
--
-- NOTE
--
-- HISTORY
--  Wed Oct 29 2003:3/36 PM     rssharma    Created
--========================================================================

FUNCTION get_party_name(p_cust_account_id IN NUMBER)
RETURN VARCHAR2
IS
CURSOR c_party_name(p_cust_account_id NUMBER)
IS
SELECT hp.party_name FROM hz_parties hp , hz_cust_accounts hca
WHERE hca.party_id = hp.party_id
AND hca.status = 'A'
AND hca.cust_account_id = p_cust_account_id;
l_party_name hz_parties.party_name%type;
BEGIN
OPEN c_party_name(p_cust_account_id );
FETCH c_party_name INTO l_party_name;
CLOSE c_party_name;
RETURN l_party_name;
END;

--========================================================================
-- PROCEDURE
--    get_user_status_name
--
-- PURPOSE
--    This api returns user_status_name given the user_status_id and the system_status_code
--
-- NOTE
--
-- HISTORY
--  Wed Jan 21 2004:4/18 PM      rssharma    Created
--========================================================================

FUNCTION get_user_status_name(p_user_status_id IN NUMBER , p_system_status_type IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c_user_status_name (p_user_status_id NUMBER , p_system_status_type VARCHAR2)IS
SELECT name FROM ams_user_statuses_vl where user_status_id = p_user_status_id
AND system_status_type = p_system_status_type;
l_user_status_name ams_user_statuses_tl.name%type;
BEGIN
OPEN c_user_status_name(p_user_status_id , p_system_status_type );
FETCH c_user_status_name INTO l_user_status_name;
CLOSE c_user_status_name;
RETURN l_user_status_name;
END;

--========================================================================
-- PROCEDURE
--    get_currency_name
--
-- PURPOSE
--    This api returns Currency Name given the Currency Code
--
-- NOTE
--
-- HISTORY
--  Fri Jan 23 2004:3/18 PM      rssharma    Created
--========================================================================
FUNCTION get_currency_name(p_currency_code IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR C_CURR_NAME(p_currency_code VARCHAR2) IS
SELECT name FROM fnd_currencies_vl WHERE currency_code = p_currency_code;

l_currency_name fnd_currencies_vl.name%type;

BEGIN
OPEN C_CURR_NAME(p_currency_code);
FETCH C_CURR_NAME INTO l_currency_name;
CLOSE C_CURR_NAME;
return l_currency_name;
END;

--========================================================================
-- PROCEDURE
--    get_currency_name
--
-- PURPOSE
--    This api returns Media Name given the Media id
--
-- NOTE
--
-- HISTORY
--  Fri Jan 23 2004:3/18 PM      rssharma    Created
--========================================================================
FUNCTION get_media_name(p_media_id IN NUMBER) RETURN VARCHAR2
IS
CURSOR c_media_name(p_media_id NUMBER) IS
SELECT media_name FROM ams_media_vl
WHERE media_id = p_media_id;
l_media_name ams_media_tl.media_name%type;

BEGIN
OPEN c_media_name(p_media_id);
FETCH c_media_name INTO l_media_name;
CLOSE c_media_name;

RETURN l_media_name;
END;

--========================================================================
-- PROCEDURE
--    get_fnd_lookup_meaning
--
-- PURPOSE
--    This api returns Meaning of a NON-OZF FND lookup given the lookupcode and lookup_type
--
-- NOTE
--
-- HISTORY
--  Fri Jan 23 2004:3/18 PM      rssharma    Created
--========================================================================

FUNCTION get_fnd_lookup_meaning(p_lookup_type IN VARCHAR2,p_lookup_code IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR c_lookup_meaning(p_lookup_type VARCHAR2,p_lookup_code VARCHAR2) IS
SELECT meaning FROM fnd_lookups WHERE lookup_type = p_lookup_type
AND lookup_code = p_lookup_code;

l_lookup_meaning fnd_lookups.meaning%type;
BEGIN
OPEN c_lookup_meaning(p_lookup_type,p_lookup_code);
FETCH c_lookup_meaning INTO l_lookup_meaning;
CLOSE c_lookup_meaning;

RETURN l_lookup_meaning;
END;

--======================================================================
-- FUNCTION
--    Has_Sales_Rep_Role
--
-- PURPOSE
--    This api returns FND_API.g_true if the given user has the "Sales
--    Representative" role. It returns FND_API.g_false otherwise.
--
-- HISTORY
--    23-Feb-2004  yizhang  Create.
--======================================================================
FUNCTION Has_Sales_Rep_Role(
   p_resource_id      IN  NUMBER
) RETURN VARCHAR2
IS
   l_role_id    number;

   CURSOR csr_sales_rep(cv_resource_id IN NUMBER) IS
   select rr.role_id
   from jtf_rs_role_relations rr
   ,    jtf_rs_roles_vl rl
   where rr.role_id = rl.role_id
   and rl.role_type_code = 'SALES'
   and rl.role_code = 'SALES_REP'
   and rr.delete_flag = 'N'
   and TRUNC(sysdate) between TRUNC(rr.start_date_active)
                          and TRUNC(nvl(rr.end_date_active,sysdate))
   and rr.role_resource_id = cv_resource_id;

BEGIN
   OPEN csr_sales_rep(p_resource_id);
   FETCH csr_sales_rep INTO l_role_id;
   IF csr_sales_rep%NOTFOUND THEN
      CLOSE csr_sales_rep;
      RETURN FND_API.g_false;
   END IF;
   CLOSE csr_sales_rep;

   RETURN FND_API.g_true;
END;

--======================================================================
-- FUNCTION
--  get_commited_amount

-- PURPOSE
--    The api return committed budget amount.

-- HISTORY
--    17-Feb-2005  feliu  Create.
--======================================================================

FUNCTION get_commited_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_committed_amount NUMBER := 0;

  CURSOR curr_committed_amount(list_header_id NUMBER) IS
    SELECT SUM(NVL(plan_curr_committed_amt,0))
    FROM ozf_object_fund_summary
    WHERE object_id = list_header_id
    AND object_type = 'OFFR';
/*
SELECT SUM(AMOUNT)
FROM(
SELECT  uti.plan_curr_amount amount
FROM ozf_funds_utilized_all_b uti, ozf_act_budgets act
WHERE uti.utilization_type ='REQUEST'
AND component_type = 'OFFR'
AND component_id = list_header_id
AND act.activity_budget_id = uti.ams_activity_budget_id
AND act.recal_flag is NULL
UNION ALL
SELECT 0-uti.plan_curr_amount amount
FROM ozf_funds_utilized_all_b uti, ozf_act_budgets act
WHERE uti.utilization_type ='TRANSFER'
AND plan_type = 'OFFR'
AND plan_id = list_header_id
AND act.activity_budget_id = uti.ams_activity_budget_id
AND act.recal_flag is NULL);
*/
BEGIN
  OPEN curr_committed_amount( p_list_header_id ) ;
  FETCH curr_committed_amount INTO p_committed_amount ;
  CLOSE curr_committed_amount ;
  RETURN p_committed_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;

--======================================================================
-- FUNCTION
--  get_commited_amount

-- PURPOSE
--    The api return recal-committed budget amount.

-- HISTORY
--    17-Feb-2005  feliu  Create.
--======================================================================

FUNCTION get_recal_commited_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_committed_amount NUMBER := 0;

  CURSOR curr_committed_amount(list_header_id NUMBER) IS
    SELECT SUM(NVL(plan_curr_recal_committed_amt,0))
    FROM ozf_object_fund_summary
    WHERE object_id = list_header_id
    AND object_type = 'OFFR';
/*
  SELECT SUM(AMOUNT)
FROM(
SELECT  uti.plan_curr_amount amount
FROM ozf_funds_utilized_all_b uti
WHERE uti.utilization_type ='REQUEST'
AND component_type = 'OFFR'
AND component_id = list_header_id
UNION ALL
SELECT 0-uti.plan_curr_amount amount
FROM ozf_funds_utilized_all_b uti
WHERE uti.utilization_type ='TRANSFER'
AND plan_type = 'OFFR'
AND plan_id = list_header_id);
*/
BEGIN
  OPEN curr_committed_amount( p_list_header_id ) ;
  FETCH curr_committed_amount INTO p_committed_amount ;
  CLOSE curr_committed_amount ;
  RETURN p_committed_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;


FUNCTION get_utilized_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_utilized_amount NUMBER := 0;

  CURSOR curr_utilized_amount(list_header_id NUMBER) IS
    SELECT SUM(NVL(plan_curr_utilized_amt,0))
    FROM ozf_object_fund_summary
    WHERE object_id = list_header_id
    AND object_type = 'OFFR';

  /*
  SELECT SUM(uti.plan_curr_amount)
FROM ozf_funds_utilized_all_vl uti
WHERE uti.utilization_type IN
('UTILIZED','ACCRUAL','ADJUSTMENT','CHARGEBACK','LEAD_ACCRUAL')
AND plan_type = 'OFFR'
AND plan_id = list_header_id;
*/
BEGIN
  OPEN curr_utilized_amount( p_list_header_id ) ;
  FETCH curr_utilized_amount INTO p_utilized_amount ;
  CLOSE curr_utilized_amount ;
  RETURN p_utilized_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;

--======================================================================
-- FUNCTION
--  get_commited_amount

-- PURPOSE
--    The api return earned budget amount.

-- HISTORY
--    17-Feb-2005  feliu  Create.
--======================================================================

FUNCTION get_earned_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_earned_amount NUMBER := 0;

  CURSOR curr_earned_amount(list_header_id NUMBER) IS
    SELECT SUM(NVL(plan_curr_earned_amt,0))
    FROM ozf_object_fund_summary
    WHERE object_id = list_header_id
    AND object_type = 'OFFR';
/*
  SELECT SUM(uti.plan_curr_amount)
FROM ozf_funds_utilized_all_vl uti
WHERE uti.utilization_type IN
('UTILIZED','ACCRUAL','ADJUSTMENT','CHARGEBACK','LEAD_ACCRUAL')
AND plan_type = 'OFFR'
AND plan_id = p_list_header_id
AND gl_posted_flag NOT in('N','F');
*/
BEGIN
  OPEN curr_earned_amount( p_list_header_id ) ;
  FETCH curr_earned_amount INTO p_earned_amount ;
  CLOSE curr_earned_amount ;
  RETURN p_earned_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;

--======================================================================
-- FUNCTION
--  get_commited_amount

-- PURPOSE
--    The api return paid budget amount.

-- HISTORY
--    17-Feb-2005  feliu  Create.
--======================================================================

FUNCTION get_paid_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_paid_amount NUMBER := 0;

  CURSOR curr_paid_amount(list_header_id NUMBER) IS
    SELECT SUM(NVL(plan_curr_paid_amt,0))
    FROM ozf_object_fund_summary
    WHERE object_id = list_header_id
    AND object_type = 'OFFR';

/*

 SELECT SUM(AMOUNT) FROM
(SELECT SUM(plan_curr_amount - NVL(plan_curr_amount_remaining,0)) amount
FROM ozf_funds_utilized_all_b util
WHERE utilization_type = 'UTILIZED'
AND NVL(util.gl_posted_flag,'Y') = 'Y'
AND plan_type = 'OFFR'
AND plan_id =  list_header_id
UNION AlL
SELECT cuti.plan_curr_amount  amount
FROM ozf_funds_utilized_all_b util,
     ozf_claim_lines_util_all cuti,
     ozf_claim_lines_all cln,
     ozf_claims_all cla
WHERE util.utilization_id(+) = cuti.utilization_id
AND util.utilization_type IN ('ACCRUAL','ADJUSTMENT', 'CHARGEBACK', 'LEAD_ACCRUAL')
AND cuti.claim_line_id = cln.claim_line_id
AND cln.claim_id = cla.claim_id
AND cla.status_code = 'CLOSED'
AND util.plan_type = 'OFFR'
AND util.plan_id =  list_header_id);
*/

BEGIN
  OPEN curr_paid_amount( p_list_header_id ) ;
  FETCH curr_paid_amount INTO p_paid_amount ;
  CLOSE curr_paid_amount ;
  RETURN p_paid_amount ;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END;

FUNCTION get_org_name(p_org_id NUMBER)
RETURN VARCHAR2
IS
/*
  -- Bug 5065276 SQL ID 16501642
  -- The name can be fetched directly from the source table
  -- rather than the view
  CURSOR c_org_name IS
  SELECT name
  FROM   hr_operating_units
  WHERE  organization_id = p_org_id;
*/

 CURSOR c_org_name IS
 SELECT name
 FROM hr_all_organization_units_tl
 WHERE organization_id = p_org_id
 AND language = userenv('LANG');

 l_org_name VARCHAR2(240);

BEGIN
  OPEN  c_org_name;
  FETCH c_org_name INTO l_org_name;
  CLOSE c_org_name;

  RETURN l_org_name;
END get_org_name;

FUNCTION getAttributeName
(
    p_attributeCode  IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    return getAttributeName(p_attributeCode => p_attributeCode, p_applicationId => G_OZF_APP_ID );
END getAttributeName;

FUNCTION getAttributeName
(
p_attributeCode  IN VARCHAR2
, p_applicationId IN NUMBER
)  RETURN VARCHAR2
  IS
      CURSOR c_name(cp_attributeCode VARCHAR2, cp_applicationId NUMBER) IS
      SELECT ak.attribute_label_long
      FROM ak_attributes_vl ak
      WHERE ak.attribute_code = upper(cp_attributeCode)
      AND   ak.attribute_application_id = cp_applicationId;

    l_attributeName AK_ATTRIBUTES_VL.NAME%TYPE;
  BEGIN
   OPEN c_name(cp_attributeCode => p_attributeCode, cp_applicationId => p_applicationId);
   FETCH c_name INTO l_attributeName;
   IF c_name%NOTFOUND THEN
    l_attributeName := null;
   END IF;
   CLOSE c_name;
  RETURN l_attributeName;
END getAttributeName;
--======================================================================
-- FUNCTION
--  get_revenue_account

-- PURPOSE
--    The function returns the revenue account for Off-Invoice offer.
--
-- HISTORY
-- 05-Mar-2010    BKUNJAN   ER 9382547 - TM SLA Uptake
-- 10-May-2010    BKUNJAN   Fixed Bug 9666046
--======================================================================

FUNCTION get_revenue_account (p_utilization_id IN NUMBER
                             ,p_org_id IN NUMBER)
RETURN NUMBER
IS

CURSOR get_om_profile IS
select parameter_value from oe_sys_parameters_all
where parameter_code = 'OE_DISCOUNT_DETAILS_ON_INVOICE'
and org_id = p_org_id;

--//Bug 9666046
CURSOR get_offer_type_cur (p_utilization_id IN NUMBER)IS
SELECT offer_type
FROM ozf_offers offers
    ,ozf_funds_utilized_all_b funds
WHERE offers.qp_list_header_id = funds.plan_id
AND   funds.utilization_id     = p_utilization_id;

CURSOR get_revenue_acct_csr1 IS
select cgl.code_combination_id
from   ozf_funds_utilized_all_b fu
,      oe_price_adjustments pa
,      oe_order_lines_all ol
,      oe_order_headers_all oh
,      ra_customer_trx_lines_all ctl
,      ra_cust_trx_line_gl_dist_all cgl
where fu.price_adjustment_id = pa.price_adjustment_id
and   ol.line_id = pa.line_id
and   ol.header_id = oh.header_id
and   ctl.interface_line_attribute1 = to_char(oh.order_number)
and   ctl.sales_order_line = ol.line_number
and   cgl.customer_trx_line_id = ctl.customer_trx_line_id
and   cgl.account_class = 'REV'
and   fu.utilization_id = p_utilization_id
and   fu.order_line_id = ctl.interface_line_attribute6;

CURSOR get_revenue_acct_csr2 IS
select cgl.code_combination_id
from   ozf_funds_utilized_all_b fu
,      oe_price_adjustments pa
,      oe_order_lines_all ol
,      oe_order_headers_all oh
,      ra_customer_trx_lines_all ctl
,      ra_cust_trx_line_gl_dist_all cgl
where fu.price_adjustment_id = pa.price_adjustment_id
and   ol.line_id = pa.line_id
and   ol.header_id = oh.header_id
and   ctl.interface_line_attribute1 = to_char(oh.order_number)
and   ctl.sales_order_line = ol.line_number
and   ctl.INTERFACE_LINE_ATTRIBUTE11 = TO_CHAR(pa.price_adjustment_id)
and   cgl.customer_trx_line_id = ctl.customer_trx_line_id
and   cgl.account_class = 'REV'
and   fu.utilization_id = p_utilization_id;

l_oe_disc_dtls_on_invoice VARCHAR2(1);
l_revenue_acct            NUMBER;
l_offer_type              VARCHAR2(30);

BEGIN
   --//Bug 9666046
   OPEN get_offer_type_cur(p_utilization_id);
   FETCH get_offer_type_cur INTO l_offer_type;
   CLOSE get_offer_type_cur;

   OPEN get_om_profile;
   FETCH get_om_profile INTO l_oe_disc_dtls_on_invoice;
   CLOSE get_om_profile;

   l_oe_disc_dtls_on_invoice := NVL(l_oe_disc_dtls_on_invoice,'N');

   IF (l_oe_disc_dtls_on_invoice = 'Y' AND l_offer_type <> 'TERMS') THEN
      OPEN get_revenue_acct_csr2;
      FETCH get_revenue_acct_csr2 INTO l_revenue_acct;
      CLOSE get_revenue_acct_csr2;
   ELSE

      OPEN get_revenue_acct_csr1;
      FETCH get_revenue_acct_csr1 INTO l_revenue_acct;
      CLOSE get_revenue_acct_csr1;
   END IF;

   return l_revenue_acct;

END get_revenue_account;

END OZF_Utility_PVT;

/
