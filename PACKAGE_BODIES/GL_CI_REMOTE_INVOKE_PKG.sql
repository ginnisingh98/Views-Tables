--------------------------------------------------------
--  DDL for Package Body GL_CI_REMOTE_INVOKE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CI_REMOTE_INVOKE_PKG" as
/* $Header: glucirmb.pls 120.10.12010000.2 2010/03/12 09:42:32 sommukhe ship $ */



  TYPE t_RefCur       IS REF CURSOR;
  batch               gl_ci_remote_invoke_PKG.batch_table;    --+ holds batch names

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+drop any table
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure drop_table (
   p_table_name       IN varchar2)
IS
BEGIN
    gl_journal_import_pkg.drop_table(p_table_name);
END drop_table;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the chart of account information
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Get_Target_Je_source_Name(
         p_adb_name         OUT NOCOPY varchar2,
         p_name             OUT NOCOPY varchar2)
IS
BEGIN
   SELECT USER_JE_SOURCE_NAME
   INTO p_adb_name
   FROM GL_JE_SOURCES
   WHERE JE_SOURCE_NAME = 'Average Consolidation';

   SELECT USER_JE_SOURCE_NAME
   INTO p_name
   FROM GL_JE_SOURCES
   WHERE JE_SOURCE_NAME = 'Consolidation';

END Get_Target_Je_source_Name;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the chart of account information
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure coa_info (
   p_coa_id           IN NUMBER,
   p_count            IN OUT NOCOPY Number)
IS
   v_R_COACursor      t_RefCur;
   v_R_SQL            varchar2(3000);
   l_r_segment_num    FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE;
   l_r_column_name    FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE;
   l_r_display_size   FND_ID_FLEX_SEGMENTS.DISPLAY_SIZE%TYPE;
   l_app_id           FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
   l_gl_short_name    FND_ID_FLEX_SEGMENTS.ID_FLEX_CODE%TYPE;
   l_r_index          number;
   l_chart            coa_table;
BEGIN
   l_r_index := 1;
   l_app_id := 101;
   l_gl_short_name := 'GL#';

   v_R_SQL := 'SELECT s.SEGMENT_NUM, ' ||
            's.APPLICATION_COLUMN_NAME, ' ||
            's.DISPLAY_SIZE ' ||
            'FROM FND_FLEX_VALUE_SETS vs, ' ||
            'FND_ID_FLEX_SEGMENTS s ' ||
            'WHERE vs.flex_value_set_id = s.flex_value_set_id ' ||
            'AND s.ID_FLEX_NUM = :coa_id ' ||
            'AND s.application_id = :app_id ' ||
            'AND s.id_flex_code = :gl' ||
            ' order by segment_num';
   OPEN v_R_COACursor FOR v_R_SQL USING p_coa_id, l_app_id, l_gl_short_name;

   LOOP
      FETCH v_R_COACursor INTO l_r_segment_num, l_r_column_name, l_r_display_size;
      EXIT WHEN v_R_COACursor%NOTFOUND;
      l_chart(l_r_index).segment_num := l_r_segment_num;
      l_chart(l_r_index).application_column_name := l_r_column_name;
      l_chart(l_r_index).display_size := l_r_display_size;
      l_r_index := l_r_index + 1;
   END LOOP;
   CLOSE v_R_COACursor;
   p_count := l_r_index;

END coa_info;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the chart of account information for each segment in the chart of accounts
--+ p_count is the index to the coa_table.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Get_Detail_coa_info (
    p_coa_id          IN NUMBER,
    p_count           IN Number,
    p_column_name     IN OUT NOCOPY varchar2,
    p_display_size    IN OUT NOCOPY number)
IS
   v_R_COACursor      t_RefCur;
   v_R_SQL            varchar2(3000);
   l_r_segment_num    FND_ID_FLEX_SEGMENTS.SEGMENT_NUM%TYPE;
   l_r_column_name    FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE;
   l_r_display_size   FND_ID_FLEX_SEGMENTS.DISPLAY_SIZE%TYPE;
   l_app_id           FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
   l_gl_short_name    FND_ID_FLEX_SEGMENTS.ID_FLEX_CODE%TYPE;
   l_r_index          number;
   l_chart            coa_table;
BEGIN
   l_r_index := 1;
   l_app_id := 101;
   l_gl_short_name := 'GL#';
   v_R_SQL := 'SELECT s.SEGMENT_NUM, ' ||
            's.APPLICATION_COLUMN_NAME, ' ||
            's.DISPLAY_SIZE ' ||
            'FROM FND_FLEX_VALUE_SETS vs, ' ||
            'FND_ID_FLEX_SEGMENTS s ' ||
            'WHERE vs.flex_value_set_id = s.flex_value_set_id ' ||
            'AND s.ID_FLEX_NUM = :coa_id ' ||
            'AND s.application_id = :app_id ' ||
            'AND s.id_flex_code = :gl_name' ||
            ' order by segment_num';
   OPEN v_R_COACursor FOR v_R_SQL USING p_coa_id, l_app_id, l_gl_short_name;
   LOOP
      FETCH v_R_COACursor INTO l_r_segment_num, l_r_column_name, l_r_display_size;
      EXIT WHEN v_R_COACursor%NOTFOUND;
      l_chart(l_r_index).segment_num := l_r_segment_num;
      l_chart(l_r_index).application_column_name := l_r_column_name;
      l_chart(l_r_index).display_size := l_r_display_size;
      l_r_index := l_r_index + 1;
   END LOOP;
   CLOSE v_R_COACursor;
   p_column_name := l_chart(p_count).application_column_name;
   p_display_size := l_chart(p_count).display_size;

END Get_Detail_coa_info;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the email address of a specific user
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_eMAIL_Address(
     p_user_name        IN varchar2
) return varchar2
IS
  l_email_address  FND_USER.EMAIL_ADDRESS%TYPE;
  v_SQL            varchar2(500);
  CURSOR C IS
      SELECT email_address
      FROM   fnd_user
      WHERE  user_name = p_user_name;

  v_Users        C%ROWTYPE;
begin
   OPEN C;
   FETCH C INTO v_Users;
   if (C%FOUND) then
     l_email_address := v_Users.email_address;
   else
     l_email_address := 'GETFAILURE';
   end if;
   CLOSE C;
   return l_email_address;
end Get_eMAIL_Address;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the user id
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_User_ID(
   user_name        IN varchar2
) return number
IS
   l_user_id        FND_USER.USER_ID%TYPE;
   v_SQL1           varchar2(500);
begin
   v_SQL1 := 'select user_id from fnd_user' ||
                  ' where user_name = :name';
   EXECUTE IMMEDIATE v_SQL1 INTO l_user_id USING user_name;
   return l_user_id;
end Get_User_ID;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the responsibility id
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Resp_ID(
   resp_name        IN varchar2
) return number
IS
   l_resp_id        number;
   v_SQL1           varchar2(500);
   l_app_id         FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
begin
   l_app_id := 101;
   v_SQL1 := 'select responsibility_id from fnd_responsibility_tl' ||
                  ' where responsibility_name = :name' ||
                  ' and application_id = :app_id' ||
                  ' and language = :l';
   EXECUTE IMMEDIATE v_SQL1 INTO l_resp_id USING resp_name, l_app_id, userenv('LANG');
   return l_resp_id;
end Get_Resp_ID;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the name of the ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Ledger_Name(
   ledger_id             IN number
) return varchar2
IS
   l_ledger_name      GL_LEDGERS.NAME%TYPE;
   v_SQL1             varchar2(500);
begin
   v_SQL1 := 'select name from gl_ledgers' ||
               ' WHERE ledger_id = :l_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_ledger_name USING ledger_id;
   return l_ledger_name;
end Get_Ledger_Name;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the suspense flag for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Suspense_Flag(
   ledger_id             IN number
) return varchar2
IS
   l_suspense_flag    GL_LEDGERS.SUSPENSE_ALLOWED_FLAG%TYPE;
   v_SQL1             varchar2(500);
begin
   v_SQL1 := 'select suspense_allowed_flag from gl_ledgers' ||
               ' WHERE ledger_id = :l_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_suspense_flag USING ledger_id;
   return l_suspense_flag;
end Get_Suspense_Flag;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the average balance flag for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Daily_Balance_Flag(
   ledger_id             IN number
) return varchar2
IS
   l_balance_flag     GL_LEDGERS.ENABLE_AVERAGE_BALANCES_FLAG%TYPE;
   v_SQL1             varchar2(500);
begin
   v_SQL1 := 'select enable_average_balances_flag from gl_ledgers' ||
               ' where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_balance_flag USING ledger_id;
   return l_balance_flag;
end Get_Daily_Balance_Flag;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the consolidation ledger flag for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Cons_ledger_Flag(
   ledger_id             IN number
) return varchar2
IS
   l_cons_ledger_flag    GL_LEDGERS.CONSOLIDATION_LEDGER_FLAG%TYPE;
   v_SQL1                varchar2(500);
begin
   v_SQL1 := 'select consolidation_ledger_flag from gl_ledgers' ||
               ' where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_cons_ledger_flag USING ledger_id;
   return l_cons_ledger_flag;
end Get_Cons_ledger_Flag;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the currency code for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Currency_Code(
   ledger_id             IN number
) return varchar2
IS
   l_currency_code    GL_LEDGERS.CURRENCY_CODE%TYPE;
   v_SQL1             varchar2(500);
begin
   v_SQL1 := 'SELECT CURRENCY_CODE FROM gl_ledgers' ||
               ' WHERE ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_currency_code USING ledger_id;
   return l_currency_code;
end Get_Currency_Code;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the chart of accounts id for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_COA_Id(
   ledger_id             IN number
) return number
IS
   l_coa_id   GL_LEDGERS.CHART_OF_ACCOUNTS_ID%TYPE;
   v_SQL1     varchar2(500);
begin
   v_SQL1 := 'select chart_of_accounts_id from gl_ledgers' ||
               ' where ledger_id = :ledger_id';
   EXECUTE IMMEDIATE v_SQL1 INTO l_coa_id USING ledger_id;
   return l_coa_id;
end Get_COA_Id;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Does the input period name exists in this ledger?
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Period_Exists(
     ledger_id           IN number,
     period_name      IN varchar2
) return number
IS
     l_count          number;
     v_SQL1           varchar2(1000);
begin
   v_SQL1 := 'select count(*) from gl_periods p, gl_ledgers l ' ||
               'where p.period_set_name = l.period_set_name ' ||
               'and p.period_type = l.accounted_period_type ' ||
               'and l.ledger_id = :s ' ||
               'and p.period_name = :pd';
   EXECUTE IMMEDIATE v_SQL1 INTO l_count USING ledger_id, period_name;
   return l_count;
end Period_Exists;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get information on a specific period for a specific ledger
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Get_Period_Info(
   ledger_id          IN number,
   period_name        IN varchar2,
   start_date         OUT NOCOPY varchar2,
   end_date           OUT NOCOPY varchar2,
   quarter_date       OUT NOCOPY varchar2,
   year_date          OUT NOCOPY varchar2
) IS
   v_PDSQL            varchar2(1000);

BEGIN
      v_PDSQL := 'select p.start_date, p.end_date, p.quarter_start_date, ' ||
                 'p.year_start_date from ' ||
                 'gl_periods p, gl_ledgers l ' ||
                 'where p.period_set_name = l.period_set_name ' ||
                 'and p.period_type = l.accounted_period_type ' ||
                 'and l.ledger_id = :s ' ||
                 'and p.period_name = :pd';
      EXECUTE IMMEDIATE v_PDSQL INTO start_date, end_date, quarter_date, year_date USING ledger_id, period_name;

END Get_Period_Info;

procedure GLOBAL_INITIALIZE(
    user_id           in number,
    resp_id           in number,
    resp_appl_id      in number,
    security_group_id in number default 0)
IS
BEGIN
   --fnd_global.Apps_Initialize(user_id, resp_id, resp_appl_id);
   NULL;
END GLOBAL_INITIALIZE;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get user id, responsibility id
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Login_Ids(
   p_user_name           IN varchar2,
   p_resp_name           IN varchar2,
   user_id               OUT NOCOPY number,
   resp_id               OUT NOCOPY number
)return number
 IS
   v_SQL1                varchar2(500);
   cursor user_id_cursor is
      select user_id
      from fnd_user
      where user_name = p_user_name;
   return_value boolean;
   l_app_id           FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
BEGIN
   return_value := FALSE;
   open user_id_cursor;
   fetch user_id_cursor into user_id;
   return_value := user_id_cursor%FOUND;
   close user_id_cursor;
   if NOT return_value then
      return 1;
   end if;
   l_app_id := 101;
   v_SQL1 := 'select responsibility_id from fnd_responsibility_tl ' ||
                  'where responsibility_name = :name ' ||
                  'and application_id = :app_id ' ||
                  'and language = :l';
   EXECUTE IMMEDIATE v_SQL1 INTO resp_id USING p_resp_name, l_app_id, userenv('LANG');
   return 0;

END Get_Login_Ids;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Validate responsibility name
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Validate_Resp(
     resp_name     IN varchar2
) return number
IS
   l_count        number;
   v_SelectSQL2   varchar2(1000);
   l_error_code   number;
   l_app_id       FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE;
begin
   l_error_code := 0;
   l_app_id := 101;
   l_count := 0;
   v_SelectSQL2 := 'select count(*) from fnd_responsibility_tl ' ||
                   'where responsibility_name = :resp_name ' ||
                   'and application_id = :app_id ' ||
                   'and language = :l';
   EXECUTE IMMEDIATE v_SelectSQL2 INTO l_count USING resp_name, l_app_id,userenv('LANG');
   if l_count = 0 then
      l_error_code := 2;
      return l_error_code;
   end if;
   return l_error_code;

end Validate_Resp;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Check for Oracle Application Menu exclusion for Journal Import and Post
--+Can not use fnd_function.test to test the accessiblility of GL_SU_J_IMPORT
--+because it is a menu not a function.  Therefore, is forced to access the
--+fnd_resp_functions table direcly to get the exclusion info for this menu
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Menu_Validation(
     user_id       IN number,
     resp_id       IN number,
     app_id        IN number,
     import_flag   IN varchar2,
     post_flag     IN varchar2
) return varchar2
IS
     l_menu        number;
     v_SQL         varchar2(500);
     l_count       number;
     l_rule_type   varchar2(1);
begin
  -- fnd_global.Apps_Initialize(user_id, resp_id, app_id);
   l_rule_type := 'M';
   IF (import_flag = 'Y' ) THEN
      --l_menu := 67905;
      SELECT menu_id INTO l_menu from fnd_menus where menu_name = 'GL_SU_J_IMPORT';
      v_SQL := 'select count(*) from fnd_resp_functions' ||
               ' where application_id = :app_id' ||
               ' and responsibility_id = :r_id' ||
               ' and action_id = :menu_id' ||
               ' and rule_type = :r';
      EXECUTE IMMEDIATE v_SQL INTO l_count USING app_id, resp_id, l_menu, l_rule_type;

      --+ fnd_resp_functions contains all functions that are excluded from this responsibility
      if l_count > 0 then
         return 'IMPORT FAIL';
      end if;
      IF (FND_FUNCTION.TEST('GLXJIRUN') = FALSE) THEN
         return 'IMPORT FAIL';
      END IF;

   END IF;
   IF (post_flag = 'Y' ) THEN
      IF (FND_FUNCTION.TEST('GLXSTAPO') = FALSE) or (FND_FUNCTION.TEST('GLXJEPST') = FALSE) or
         (FND_FUNCTION.TEST('GLXCOWRK_P') = FALSE) or (FND_FUNCTION.TEST('GLPAUTOP_A') = FALSE)THEN
         return 'POST FAIL';
      END IF;
   END IF;

   return 'SUCCESS';
end Menu_Validation;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the budget version id
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Budget_Version_ID(
     p_user_id       IN number,
     p_resp_id       IN number,
     p_app_id        IN number,
     p_budget_name   IN varchar2
) return number
IS
  budget_version_id        number;
  temp_n                   number;
  cursor budget_cursor is
     select budget_version_id
     from gl_budget_versions
     where budget_name = p_budget_name;
  return_value boolean;
begin
  return_value := TRUE;
   --fnd_global.Apps_Initialize(p_user_id, p_resp_id, p_app_id);
   open budget_cursor;
   fetch budget_cursor into temp_n;
   return_value := budget_cursor%FOUND;
   close budget_cursor;
   if return_value then
      budget_version_id := temp_n;
   else
      budget_version_id := -100;
   end if;
   return budget_version_id;

end Get_Budget_Version_ID;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the ledger id
--+also check if this ledger is granted read/write access right.
--+returns the ledger id only if the ledger has both read/write access right.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get_Ledger_ID(
     p_user_id       IN number,
     p_resp_id       IN number,
     p_app_id        IN number,
     p_access_set_id OUT NOCOPY number,
     p_access_set    OUT NOCOPY varchar2,
     p_access_code   OUT NOCOPY varchar2,
     p_to_ledger_name        IN VARCHAR2
) return number
IS
    profile_val         VARCHAR2(100);
    defined_flag        BOOLEAN;
    l_ledger_id         NUMBER;
    l_access_set_id     number;
    l_access_code       varchar2(1);
    v_ReturnCursor      t_RefCur;
    v_SQL               varchar2(500);
begin
  -- fnd_global.Apps_Initialize(p_user_id, p_resp_id, p_app_id);
   fnd_profile.get_specific(name_z => 'GL_ACCESS_SET_ID',
                            val_z => profile_val,
                            defined_z=> defined_flag);
   if(profile_val IS NULL OR defined_flag = FALSE) then
      app_exception.raise_exception;
   end if;
   l_access_set_id := to_number(profile_val);
   SELECT NAME
   INTO p_access_set
   FROM GL_ACCESS_SETS
   WHERE ACCESS_SET_ID = l_access_set_id;

   /*v_SQL := 'select default_ledger_id from gl_access_sets' ||
                  ' where access_set_id = :s';*/
   v_SQL := 'select ledger_id from gl_ledgers' ||
                  ' where name = :s';
   OPEN v_ReturnCursor FOR v_SQL USING p_to_ledger_name;
   FETCH v_ReturnCursor INTO l_ledger_id;
   IF v_ReturnCursor%NOTFOUND THEN
      l_ledger_id := -1;  --no default ledger is found
   END IF;
   CLOSE v_ReturnCursor;

   IF l_ledger_id >= 0 THEN
      v_SQL := 'select access_privilege_code from gl_access_set_assignments' ||
                  ' where access_set_id = :s and ledger_id = :l';
      OPEN v_ReturnCursor FOR v_SQL USING l_access_set_id, l_ledger_id;
      FETCH v_ReturnCursor INTO p_access_code;
      CLOSE v_ReturnCursor;
   END IF;
   p_access_set_id := l_access_set_id;
   return l_ledger_id;
   exception
      when NO_DATA_FOUND then
         return -1;
end Get_Ledger_ID;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+get the group id for the target db
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION Get_Group_ID RETURN number
IS
   CURSOR gp_id IS
      SELECT GL_INTERFACE_CONTROL_S.NEXTVAL
      FROM sys.DUAL;
   l_group_id       number;
BEGIN
   OPEN gp_id;
      FETCH gp_id INTO l_group_id;
   CLOSE gp_id;
   RETURN l_group_id;
END Get_Group_ID;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+ grant delete, update, insert, select rights on
--+ gl_cons_interface_groupid table to a specific user
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Grant_Rights(
   group_id         IN number,
   db_username      IN varchar2
)
IS
   l_table_name     varchar2(30);
   v_SQL            varchar2(500);
   errbuf           varchar2(500);
BEGIN
   l_table_name := 'GL_CONS_INTERFACE_' || group_id;
   v_SQL := 'grant select, update, insert, delete on ' || l_table_name
            || ' to ' || db_username;
   EXECUTE IMMEDIATE v_SQL;
   exception
      when OTHERS then
       errbuf := SUBSTR(SQLCODE || ' ; ' || SQLERRM, 1, 255);
       errbuf := errbuf;
END Grant_Rights;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+ the group_ID will be returned
--+ the table with the given name and its index will be created
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Create_Interface_Table(
   group_id         IN number,
   db_username      IN varchar2
)
IS
   l_table_name     varchar2(30);
BEGIN
   l_table_name := 'GL_CONS_INTERFACE_' || group_id;
   gl_journal_import_pkg.create_table(l_table_name);
   Grant_Rights(group_id, db_username);
END Create_Interface_Table;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+this procedure can be called from a remote database. It will initialize the user id
--+responsibility id and application id.
--+load the input group id to the parallel gl_interface table and
--+update the gl_interface_control table with the necessary info for Journal Import.
--+ call this procedure to populate the gl_interface_control table
--+  PROCEDURE populate_interface_control(
--+              user_je_source_name    VARCHAR2,
--+                  group_id           IN OUT NUMBER,
--+                  ledger_id            NUMBER,
--+              interface_run_id       IN OUT NUMBER,
--+                  table_name                 VARCHAR2 DEFAULT NULL,
--+              processed_data_action          VARCHAR2 DEFAULT NULL);
--+ interface_run_id will be returned from this procedure
--+ when gl_interface_control table is populated here, the new gl_cons_interface_n
--+ table name is also saved in the table for Journal Import to use.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Apps_Initialize (
   user_id             IN number,
   resp_id             IN number,
   app_id              IN number,
   ledger_id           IN number,
   group_id            IN number,
   pd_name             IN varchar2,
   actual_flag         IN varchar2,
   avg_flag            IN varchar2
) return number
IS
   l_group_id          number;
   inter_run_id        number;
   l_table_name        varchar2(30);
   v_UpdateSQL         varchar2(500);
   v_SelectSQL         varchar2(1000);
   l_reference1        varchar2(15);
   l_user_je_source_name  varchar2(25);
   l_adb_je_source        varchar2(25);
   l_je_source            varchar2(25);
begin
   l_group_id := group_id;
   --fnd_global.Apps_Initialize(user_id, resp_id, app_id);
   l_adb_je_source := 'Average Consolidation';
   l_je_source := 'Consolidation';

   l_table_name := 'GL_CONS_INTERFACE_' || group_id;
   IF avg_flag = 'Y' THEN
      v_SelectSQL := 'select user_je_source_name from gl_je_sources ' ||
                  'WHERE je_source_name = :s_name';
      EXECUTE IMMEDIATE v_SelectSQL INTO l_user_je_source_name USING l_adb_je_source;
      gl_journal_import_pkg.populate_interface_control(
--+        'Average Consolidation',
        l_user_je_source_name,
        l_group_id,
        ledger_id,
        inter_run_id,
        l_table_name,
        'R');  --+drop interface table

      v_UpdateSQL := 'UPDATE ' || l_table_name ||
            ' SET group_id = :group_id' ||
            ' WHERE ledger_id = :ledger_id' ||
            ' AND period_name = :period_name' ||
            ' AND actual_flag = :flag' ||
            ' AND user_je_source_name = :s_name';
      EXECUTE IMMEDIATE v_UpdateSQL USING group_id, ledger_id, pd_name,
                        actual_flag, l_user_je_source_name;
   ELSE
      v_SelectSQL := 'select user_je_source_name from gl_je_sources ' ||
                  'WHERE je_source_name = :s_name';
      EXECUTE IMMEDIATE v_SelectSQL INTO l_user_je_source_name USING l_je_source;
      gl_journal_import_pkg.populate_interface_control(
--+        'Consolidation',
        l_user_je_source_name,
        l_group_id,
        ledger_id,
        inter_run_id,
        l_table_name,
        'R');  --+drop interface table

      v_UpdateSQL := 'UPDATE ' || l_table_name ||
            ' SET group_id = :group_id' ||
            ' WHERE ledger_id = :ledger_id' ||
            ' AND period_name = :period_name' ||
            ' AND actual_flag = :flag' ||
            ' AND user_je_source_name = :s_name';
      EXECUTE IMMEDIATE v_UpdateSQL USING group_id, ledger_id, pd_name,
                        actual_flag, l_user_je_source_name;
   END IF;

   return inter_run_id;
end Apps_Initialize;

--+set_mode() is necessary to get rid of the ORA= 2074
--+Error -2074: ORA-02074: cannot SET SAVEPOINT in a distributed transaction
--+ORA-06512: at "APPS.FND_REQUEST", line 2434
--+ORA-06512: at "APPS.GL_FND_REQUEST_PKG", line 54
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Submit a concurrent request to do Journal Import
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Run_Journal_Import(
   user_id          IN number,
   resp_id          IN number,
   app_id           IN number,
   inter_run_id     IN number,
   ledger_id        IN number,
   csj_flag         IN VARCHAR2
) return number
IS
   reqid            number;
   value_return     boolean;
begin
     --fnd_global.Apps_Initialize(user_id, resp_id, app_id);
     value_return := fnd_request.set_mode(TRUE);
     reqid := fnd_request.submit_request(
            'SQLGL',
            'GLLEZL',
            '',
            '',
            FALSE,
            to_char(inter_run_id),
            to_char(ledger_id),
            'N', '', '',
            csj_flag,
            'N',
           --+ 'NODEL',
           --+ '',
            chr(0),
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '', '', '', '',
            '');

  return reqid;
END Run_Journal_Import;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get either postable rows or posted rows, decided by the status ('U' or 'P')
--+each batch may have multiple headers
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Get_Postable_Rows(
   ledger_id                IN number,
   pd_name               IN varchar2,
   batch_id              IN number,
   status                IN varchar2,
   actual_flag           IN varchar2,
   avg_flag              IN varchar2,
   postable_rows         OUT NOCOPY number
) IS
   v_SelectSQL           varchar2(500);
   v_SelectSQL2          varchar2(500);
   v_ReturnCursor        t_RefCur;
   v_Headers             gl_je_headers%ROWTYPE;
   v_header_id           number;
   v_count               number;
   v_temp                number;
   l_adb_je_source       GL_JE_HEADERS.JE_SOURCE%type;
   l_je_source           GL_JE_HEADERS.JE_SOURCE%type;

BEGIN
   v_temp := 0;
   l_adb_je_source := 'Average Consolidation';
   l_je_source := 'Consolidation';
   IF avg_flag = 'Y' THEN
      v_SelectSQL := 'select * from gl_je_headers' ||
                  ' where status = :s and je_batch_id = :b_id' ||
                  ' and ledger_id = :sid' ||
                  ' and je_source = :je' ||
                  ' and period_name = :name' ||
                  ' and actual_flag = :flag';
      OPEN v_ReturnCursor FOR v_SelectSQL USING status, batch_id, ledger_id,
                              l_adb_je_source, pd_name, actual_flag;
   ELSE
      v_SelectSQL := 'select * from gl_je_headers' ||
                  ' where status = :s and je_batch_id = :b_id' ||
                  ' and ledger_id = :sid' ||
                  ' and je_source = :je' ||
                  ' and period_name = :name' ||
                  ' and actual_flag = :flag';
      OPEN v_ReturnCursor FOR v_SelectSQL USING status, batch_id, ledger_id,
                              l_je_source, pd_name, actual_flag;
   END IF;
   LOOP  --+for every batch in this transfer
      FETCH v_ReturnCursor INTO v_Headers;
      EXIT WHEN v_ReturnCursor%NOTFOUND;
      v_header_id := v_Headers.je_header_id;
      v_SelectSQL2 := 'select count(*) from gl_je_lines' ||
                      ' where je_header_id = :id';
      EXECUTE IMMEDIATE v_SelectSQL2 INTO v_count USING v_header_id;
      v_temp := v_temp + v_count;
   END LOOP;
   CLOSE v_ReturnCursor;
   postable_rows := v_temp;
   --+dbms_output.put_line('postatble rows are' || postable_rows || ' rows');

END Get_Postable_Rows;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Do Journal Post
--+need to set the status to 'S' in gl_je_batches, means selected to be posted
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Run_Journal_Post(
   user_id            IN number,
   resp_id            IN number,
   app_id             IN number,
   ledger_id             IN number,
   pd_name            IN varchar2,
   group_id           IN number,
   import_request_id  IN number,
   batch_id           IN number,
   actual_flag        IN varchar2,
   access_set_id      IN number,
   post_run_id        OUT NOCOPY number,
   reqid              OUT NOCOPY number

)
IS
   CURSOR get_new_id IS
      SELECT gl_je_posting_s.NEXTVAL
      FROM sys.dual;

   cursor ledger is
      select chart_of_accounts_id
      from gl_ledgers
      where ledger_id = ledger_id;

   value_return       boolean;
   l_coa_id           number;
   l_ledger_id        NUMBER(15);
   l_count            number;
   v_UpdateSQL        varchar2(1000);
   v_SelectSQL        varchar2(1000);
   v_Ledger_SQL       varchar2(1000);
   v_ALC_SQL          varchar2(1000);
   l_batch_name       varchar2(100);
   v_ReturnCursor     t_RefCur;
   v_Ledger_Cursor    t_RefCur;
   v_ALC_Cursor       t_RefCur;
   v_Batches          gl_je_batches%ROWTYPE;

   l_status           varchar2(1);
   l_request_id       number(15);
   dummy              NUMBER(1);
   l_ok_to_post       boolean;
   call_status        BOOLEAN;
   rphase             VARCHAR2(80);
   rstatus            VARCHAR2(80);
   dphase             VARCHAR2(30);
   dstatus            VARCHAR2(30);
   message            VARCHAR2(240);
   l_batch_status     GL_JE_BATCHES.STATUS%TYPE;
   l_budgetary_status GL_JE_BATCHES.BUDGETARY_CONTROL_STATUS%TYPE;

BEGIN
   l_count := 1;
   l_ok_to_post := TRUE;
   --+dbms_output.put_line('start journal post');
   --fnd_global.Apps_Initialize(user_id, resp_id, app_id);
   open ledger;
      fetch ledger into l_coa_id;
   close ledger;
   l_coa_id := get_coa_id(ledger_id);

   value_return := fnd_request.set_mode(TRUE);
  --+bug fix for bug#3278513, check the status of this batch
  --+if it is 'S'= SELECTED and concurrent request is found and not COMPLETED
  --+or it is 'I' = UNDERWAY and concurrent request is RUNNING then don't post
  --+if the status is 'P', don't post again, just exit
  --+ lock this row too!
   v_SelectSQL := 'select status, request_id, budgetary_control_status ' ||
                  'from gl_je_batches ' ||
                  'WHERE je_batch_id = :b_id ' ||
                  'and default_period_name = :pd ' ||
  --                'and ledger_id = :ledger ' ||
                  'and actual_flag = :flag ' ||
                  'FOR UPDATE OF status, posting_run_id';
   EXECUTE IMMEDIATE v_SelectSQL INTO l_status, l_request_id, l_budgetary_status USING batch_id, pd_name, actual_flag;

   --+ if status is 'P', then can't post the batch again. get out of here.
   --+ if the status is neither 'P' nor 'I' nor 'S', then it is ok to post
   IF (l_status = 'P') THEN
      l_ok_to_post := FALSE;
   ELSIF (l_status IN ('S', 'I')) THEN
          IF (l_budgetary_status = 'I') THEN
            --+ added budgetary_control_status check for the bug 5003755.
            l_ok_to_post := FALSE;
          ELSIF (l_request_id IS NULL) THEN
            --+ This should not happen but just in case
            l_ok_to_post := FALSE;
          ELSE
            call_status :=
            FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id,
                                            null,
                                            null,
                                            rphase,
                                            rstatus,
                                            dphase,
                                            dstatus,
                                            message);

            IF (NOT call_status) THEN
              l_ok_to_post := FALSE;

            ELSIF (l_status = 'S' AND ( dphase = 'COMPLETE'
                    AND (dstatus = 'CANCELLED' OR dstatus = 'TERMINATED'))) THEN
              l_ok_to_post := TRUE;

            ELSIF (l_status = 'I' AND
                   dphase <> 'RUNNING') THEN
              l_ok_to_post := TRUE;

            ELSE
              l_ok_to_post := FALSE;

            END IF;
          END IF; --+IF (l_request_id IS NULL) THEN
   END IF; --+   IF (l_status = 'P') THEN
   IF (l_ok_to_post) THEN
      l_batch_status := 'S';
      open get_new_id;
         fetch get_new_id into post_run_id;
      close get_new_id;
      v_UpdateSQL := 'UPDATE gl_je_batches ' ||
         'SET posting_run_id = :post_run_id, ' ||
         'status = :bs ' ||
         'WHERE je_batch_id = :b_id ' ||
         'and default_period_name = :pd ' ||
--         'and ledger_id = :ledger ' ||
         'and actual_flag = :flag';
      EXECUTE IMMEDIATE v_UpdateSQL USING post_run_id,l_batch_status,
                          batch_id, pd_name, actual_flag;
      v_SelectSQL := 'select name from gl_je_batches ' ||
                  'WHERE je_batch_id = :b_id';
      EXECUTE IMMEDIATE v_SelectSQL INTO l_batch_name USING batch_id;
      --+dbms_output.put_line('get batch name');

      v_Ledger_SQL := 'SELECT max(JEH.ledger_id) ' ||
                      'FROM   GL_JE_HEADERS JEH ' ||
                      'WHERE  JEH.je_batch_id = :je_batch_id ' ||
                      'GROUP BY JEH.je_batch_id ' ||
                      'HAVING count(distinct JEH.ledger_id) = 1';
      OPEN v_Ledger_Cursor FOR v_Ledger_SQL USING batch_id;
      FETCH v_Ledger_Cursor INTO l_ledger_id;
      IF v_Ledger_Cursor%NOTFOUND THEN
         l_ledger_id := -99;
      ELSE
         v_ALC_SQL := 'SELECT 1 ' ||
                      'FROM   GL_JE_HEADERS JEH ' ||
                      'WHERE  JEH.je_batch_id = :je_batch_id ' ||
                      'AND    JEH.actual_flag != ' || '''' || 'B' || '''' ||
                      ' AND    JEH.reversed_je_header_id IS NULL ' ||
                      'AND EXISTS ' ||
                          '(SELECT 1 ' ||
                           'FROM   GL_LEDGER_RELATIONSHIPS LRL ' ||
                           'WHERE  LRL.source_ledger_id = JEH.ledger_id ' ||
                           'AND    LRL.target_ledger_category_code = ' ||
                           '''' || 'ALC' || '''' ||
                           ' AND    LRL.relationship_type_code IN ( ' ||
                           '''' || 'JOURNAL' || '''' || ', ' ||
                           '''' || 'SUBLEDGER' || '''' || ') ' ||
                           'AND    LRL.application_id = 101 ' ||
                           'AND    LRL.relationship_enabled_flag = ' ||
                           '''' || 'Y' || '''' ||
                           ' AND    JEH.je_source NOT IN ' ||
                            '(SELECT INC.je_source_name ' ||
                             'FROM   GL_JE_INCLUSION_RULES INC ' ||
                             'WHERE  INC.je_rule_set_id =  ' ||
                                      'LRL.gl_je_conversion_set_id ' ||
                             'AND    INC.je_source_name = JEH.je_source ' ||
                             'AND    INC.je_category_name = ' ||
                             '''' || 'Other' || '''' ||
                             ' AND    INC.include_flag = ' ||
                             '''' || 'N' || '''' ||
                             ' AND    INC.user_updatable_flag = ' ||
                             '''' || 'N' || '''' || '))';
         OPEN v_ALC_Cursor FOR v_ALC_SQL USING batch_id;
         FETCH v_ALC_Cursor INTO dummy;
         IF v_Ledger_Cursor%FOUND THEN
            l_ledger_id := -99;
         END IF;
         CLOSE v_ALC_Cursor;
      END IF;
      CLOSE v_Ledger_Cursor;

      IF (l_ledger_id = -99) THEN
         reqid := fnd_request.submit_request(
               'SQLGL',
               'GLPPOS',
               '',
               '',
               FALSE,
               to_char(l_ledger_id),
               to_char(access_set_id),
               to_char(l_coa_id),
               to_char(post_run_id),
               chr(0),'', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '');
       ELSE
         reqid := fnd_request.submit_request(
               'SQLGL',
               'GLPPOSS',
               '',
               '',
               FALSE,
               to_char(l_ledger_id),
               to_char(access_set_id),
               to_char(l_coa_id),
               to_char(post_run_id),
               chr(0),'', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '', '', '', '', '', '', '', '', '', '',
               '');
       END IF;
       --+dbms_output.put_line('after post submitted' || reqid);

      IF (reqid <> 0) THEN
         v_UpdateSQL := 'UPDATE gl_je_batches ' ||
            'SET request_id = :request_id ' ||
            'WHERE je_batch_id = :b_id ' ||
            'and default_period_name = :pd ' ||
    --        'and ledger_id = :ledger ' ||
            'and posting_run_id = :post_run_id ' ||
            'and actual_flag = :flag';
         EXECUTE IMMEDIATE v_UpdateSQL USING reqid, batch_id, pd_name, post_run_id, actual_flag;
      END IF;
   ELSE  --+don't post, return
      post_run_id := 0;
      reqid := 0;
   END IF;   --+IF (l_ok_to_post) THEN
--+ commit;  do the commit in the calling routine
END Run_Journal_Post;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Verify Journal Import by the number of rows left in the
--+gl_interface_control table
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Verify_Journal_Import(
   p_group_id         IN number,
   result             OUT NOCOPY varchar2
)
IS
   l_count            number;
   v_SelectSQL        varchar2(300);
BEGIN
   v_SelectSQL := 'select count(*) from gl_interface_control '||
                  'where group_id = :group_id';
   EXECUTE IMMEDIATE v_SelectSQL INTO l_count USING p_group_id;
   if l_count = 0 then
      result := 'SUCCESS';
   else
      result := 'FAILURE';
   end if;
END Verify_Journal_Import;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Verify Journal Post by comparing th epostable rows before Journal Post and
--+ the posted rows after Journal Post.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE Verify_Journal_Post(
   l_pd_name        IN varchar2,
   postable_rows    IN number,
   l_ledger_id         IN number,
   l_batch_id       IN number,
   actual_flag      IN varchar2,
   avg_flag         IN varchar2,
   result           OUT NOCOPY varchar2
)
IS
   l_count          number;
   v_SelectSQL      varchar2(500);
BEGIN
   Get_Postable_Rows(l_ledger_id, l_pd_name, l_batch_id, 'P', actual_flag, avg_flag, l_count);
   if l_count = postable_rows then
      result := 'SUCCESS';
   else
      result := 'FAILURE';
   end if;

END Verify_Journal_Post;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Wait for concurrent request to complete
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure wait_for_request(
   request_id      IN number,
   result          OUT NOCOPY varchar2
)
IS
   phase           varchar2(80);
   status          varchar2(80);
   dev_phase       varchar2(30);
   dev_status      varchar2(30);
   message         varchar2(240);
   success         boolean;
begin
  if request_id <> 0 then
     success := fnd_concurrent.wait_for_request(request_id,
                  30, 360000, phase, status, dev_phase, dev_status,
                  message);
  end if;
  If dev_phase = 'COMPLETE' AND
     dev_status In ('NORMAL','WARNING' ) Then
     result := 'COMPLETE:PASS';
  Else
     result := 'COMPLETE:FAIL';
  End If;
end wait_for_request;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+Get the status of the concurrent request
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function get_request_status(
   request_id       IN number,
   result           OUT NOCOPY varchar2
) return boolean
IS
   phase            varchar2(80);
   status           varchar2(80);
   dev_phase        varchar2(30);
   dev_status       varchar2(30);
   message          varchar2(240);
   success          boolean;
   reqid            number;
begin
  if request_id <> 0 then
     reqid := request_id;
     success := fnd_concurrent.get_request_status(reqid,
                  '', '', phase, status, dev_phase, dev_status,
                  message);
  end if;
  If dev_phase = 'COMPLETE' AND
     dev_status In ('NORMAL','WARNING' ) Then
     result := 'COMPLETE:PASS';
  Else
     result := 'COMPLETE:FAIL';
  End If;
  return success;
end get_request_status;

--+the code below works
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+To test the procedure from SQL Navigator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Test_run
is
l_inter_run_id  number;
l_request_id    number;
l_group_id      number;

BEGIN
--+    l_group_id := Create_Interface_Table;
--+transfer data from gl_interface to gl_cons_interface_groupid table
--+populate the gl_interface_control table to prepare for Journal Import
--+    l_inter_run_id := Apps_Initialize(1238,50023,101,42, l_group_id, 'Apr-01');
    l_inter_run_id := Apps_Initialize(1238,50023,101,42, 3873, 'Apr-01','A','Y');
--+    l_request_id := Run_Journal_Import(1238, 50023, 101, l_inter_run_id,42);

END Test_Run;

END gl_ci_remote_invoke_pkg;

/
