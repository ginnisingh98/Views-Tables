--------------------------------------------------------
--  DDL for Package Body QA_SS_PARENT_CHILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_PARENT_CHILD_PKG" AS
/* $Header: qapcssb.pls 120.2 2005/12/19 04:00:27 srhariha noship $ */

  FUNCTION check_for_elements (
                        p_plan_id IN NUMBER,
                        p_search_array IN qa_txn_grp.ElementsArray)
        RETURN VARCHAR2

  IS
        x_char_id NUMBER;
  BEGIN

        x_char_id := p_search_array.FIRST;

        WHILE x_char_id IS NOT NULL LOOP
                IF (qa_plan_element_api.element_in_plan(p_plan_id, x_char_id))
                THEN
                        x_char_id := p_search_array.NEXT(x_char_id);
                ELSE
                        RETURN 'N';
                END IF;
        END LOOP;

        --All Collection Elements Present
        RETURN 'Y';
  END check_for_elements;


   --ilawler - bug #3436428 - Wed Mar  3 14:03:14 2004
   --Rewrote this function to take into account the datatype when searching
   --for plans with matching results.  As an invariant, numbers, dates and
   --datetimes are passed in the canonical form/server timezone.  This conversion
   --is handled by the client CO before passing the criteria to the PL/SQL.
   FUNCTION check_for_results (p_plan_id        IN NUMBER,
                               p_search_array   IN qa_txn_grp.ElementsArray)
      RETURN VARCHAR2
   IS
      l_select_clause   VARCHAR2(10) := 'SELECT 1';
      l_from_clause     VARCHAR2(20) := ' FROM QA_RESULTS_V';
      l_where_clause    VARCHAR2(4000) := ' WHERE plan_id = :1';
      l_query_clause    VARCHAR2(4030);

      l_char_id         NUMBER;
      l_res_col_name    VARCHAR2(60);
      l_data_type       NUMBER;
      l_precision       NUMBER;
      c1                NUMBER;
      i                 NUMBER;
      l_ignore          NUMBER;

      --array to store bind variable values along with a bind var counter
      --that starts at 2 because of plan_id
      TYPE bindVarTab IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
      l_bind_vars       bindVarTab;
      l_bind_var_count  NUMBER := 2;
      l_bind_var_name   VARCHAR2(60);

   BEGIN
      --add plan_id as a bind var
      l_bind_vars(1) := p_plan_id;

      --Compose our own where clause here instead of using get_where_clause
      --because we can do binding here and get_where_clause can't because
      --it's called by the getters for the VQR VO sql.
      l_char_id := p_search_array.FIRST;
      WHILE l_char_id IS NOT NULL LOOP
         --left side of where condition
         l_res_col_name := qa_core_pkg.get_result_column_name(l_char_id,
                                                              p_plan_id);
         IF (l_char_id = qa_ss_const.item) THEN
            l_res_col_name := 'qa_flex_util.item(organization_id, item_id)';
         END IF;

         --store value and init right side of condition to the bind var
         l_bind_vars(l_bind_var_count) := qa_core_pkg.dequote(p_search_array(l_char_id).value);
         l_bind_var_name := ':'||l_bind_var_count;

         --depending on the plan char's properties we need to add modifiers to
         --handle the different datatypes
         l_data_type := qa_chars_api.datatype(l_char_id);
         IF l_data_type = 2 THEN
            --number
            l_precision := qa_chars_api.decimal_precision(l_char_id);
            IF l_precision IS NOT NULL THEN
               l_bind_var_name := 'round(nvl(qltdate.canon_to_number(' || l_bind_var_name || '), 0), '|| l_precision || ')';
            ELSE
               l_bind_var_name := 'nvl(qltdate.canon_to_number(' || l_bind_var_name || '), 0)';
            END IF;
         END IF;
         --only do a to_date conversion when comparing against hardcoded fields,
         --otherwise do straight canonical string comparison with soft coded dates
         IF l_res_col_name NOT LIKE 'CHARACTER%' THEN
            IF l_data_type = 3 then
               --date
               l_bind_var_name := 'qltdate.any_to_date(' || l_bind_var_name || ')';
            ELSIF l_data_type = 6 THEN
               --datetime
               l_bind_var_name := 'qltdate.any_to_datetime(' || l_bind_var_name || ')';
            END IF;
         END IF;

         --finally append this res col/value pair to the where clause
         l_where_clause := l_where_clause || ' AND ' ||
                           l_res_col_name || ' = ' || l_bind_var_name;

         l_bind_var_count := l_bind_var_count + 1;
         l_char_id := p_search_array.NEXT(l_char_id);
      END LOOP;

      --For performance, only retrieve one row
      l_where_clause := l_where_clause || ' AND ROWNUM = 1';
      l_query_clause := l_select_clause || l_from_clause || l_where_clause;

      --PREPARE the query for execution
      c1 := dbms_sql.open_cursor;
      dbms_sql.parse(c1, l_query_clause, dbms_sql.native);

      --go through the bind var values array and do the bindings
      i := l_bind_vars.FIRST;
      WHILE (i IS NOT NULL) LOOP
         dbms_sql.bind_variable(c1, ':'||to_char(i), l_bind_vars(i));
         i := l_bind_vars.NEXT(i);
      END LOOP;

      --dummy return value
      dbms_sql.define_column(c1, 1, i);

      --EXECUTE the result check query
      l_ignore := dbms_sql.execute(c1);

      --if it returned a row, return success
      IF dbms_sql.fetch_rows(c1) > 0 THEN
         dbms_sql.close_cursor(c1);
         return 'Y';
      ELSE
         dbms_sql.close_cursor(c1);
         return 'N';
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         --whenever we encounter an error, silence it and just return a failed result check
         return 'N';

   END check_for_results;


   --ilawler - bug #3436428 - Thu Mar  4 11:17:32 2004
   --Rewrote it, as with check_for_results, to consider data types. The
   --same invariants apply here: numbers, dates and datetimes are passed
   --in the canonical form/server timezone.
   FUNCTION get_where_clause (p_plan_id         IN NUMBER,
                              p_search_array    IN qa_txn_grp.ElementsArray)
      RETURN VARCHAR2
   IS
      l_where_clause VARCHAR2(4000) := ' WHERE plan_id = '||p_plan_id;

      l_char_id         NUMBER;
      l_res_col_name    VARCHAR2(60);
      l_res_col_value   VARCHAR2(210);
      l_data_type       NUMBER;
      l_precision       NUMBER;

   BEGIN
      --Compose a where clause by concatenating result column names and
      --values into one long static string.  Bind variables are not an
      --option since this where clause is passed to VQR VOs
      l_char_id := p_search_array.FIRST;
      WHILE l_char_id IS NOT NULL LOOP
         --left side of where condition
         l_res_col_name := qa_core_pkg.get_result_column_name(l_char_id,
                                                              p_plan_id);
         IF (l_char_id = qa_ss_const.item) THEN
            l_res_col_name := 'qa_flex_util.item(organization_id, item_id)';
         END IF;

         --initialize the res_col_value to a dequoted string of our input
         l_res_col_value := ''''||qa_core_pkg.dequote(p_search_array(l_char_id).value)||'''';

         --depending on the plan char's properties we need to add modifiers to
         --handle the different datatypes
         l_data_type := qa_chars_api.datatype(l_char_id);
         IF l_data_type = 2 THEN
            --number
            l_precision := qa_chars_api.decimal_precision(l_char_id);
            IF l_precision IS NOT NULL THEN
               l_res_col_value := 'round(nvl(qltdate.canon_to_number(' || l_res_col_value || '), 0), '|| l_precision || ')';
            ELSE
               l_res_col_value := 'nvl(qltdate.canon_to_number(' || l_res_col_value || '), 0)';
            END IF;
         END IF;
         --only do a to_date conversion when comparing against hardcoded fields,
         --otherwise do straight canonical string comparison with soft coded dates
         IF l_res_col_name NOT LIKE 'CHARACTER%' THEN
            IF l_data_type = 3 then
               --date
               l_res_col_value := 'qltdate.any_to_date(' || l_res_col_value || ')';
            ELSIF l_data_type = 6 THEN
               --datetime
               l_res_col_value := 'qltdate.any_to_datetime(' || l_res_col_value || ')';
            END IF;
         END IF;

         --finally append this res col/value pair to the where clause
         l_where_clause := l_where_clause || ' AND ' ||
                           l_res_col_name || ' = ' || l_res_col_value;

         l_char_id := p_search_array.NEXT(l_char_id);
      END LOOP;

      RETURN l_where_clause;

  END get_where_clause;


  PROCEDURE post_error_messages (p_errors IN ErrorTable)
    IS

    l_message_name VARCHAR2(1000);

  BEGIN

     fnd_msg_pub.Initialize();
     fnd_msg_pub.reset();

     FOR i IN p_errors.FIRST .. p_errors.LAST LOOP
        l_message_name := p_errors(i);
        fnd_message.set_name('QA', l_message_name);
        fnd_msg_pub.add();
     END LOOP;

  END post_error_messages;


  /*

   This procedure is called from QaPcPlanRelVORowImpl. It validates the parent
   and child plans for validity and return 'T' is they are valid, else it
   return 'F'

  */
  PROCEDURE insert_plan_rel_chk(
                           p_parent_plan_id       IN NUMBER,
                           p_parent_plan_name     IN VARCHAR2,
                           p_child_plan_id        IN NUMBER,
                           p_child_plan_name      IN VARCHAR2,
                           p_data_entry_mode      IN NUMBER,
                           p_layout_mode          IN NUMBER,
                           p_num_auto_rows        IN NUMBER,
                           x_parent_plan_id       OUT NOCOPY NUMBER,
                           x_child_plan_id        OUT NOCOPY NUMBER,
                           x_status               OUT NOCOPY VARCHAR2)
  IS

  ret_status       VARCHAR2(1) := 'T';
  l_error_array    ErrorTable;
  result_num       NUMBER;
  l_count          NUMBER;
  l_rel_exists     NUMBER;
  -- bug 2390520
  -- anagarwa Fri May 24 12:36:23 PDT 2002
  l_parent_plan_id NUMBER;
  l_child_plan_id  NUMBER;

  -- local variables will be used instead of input variables.
  CURSOR c(c_parent_plan_id NUMBER,
           c_child_plan_id NUMBER) IS
     SELECT 1
     FROM   qa_pc_plan_relationship
     WHERE  parent_plan_id = c_parent_plan_id
     AND    child_plan_id = c_child_plan_id;

  BEGIN

     fnd_msg_pub.Initialize();
     fnd_msg_pub.reset();

     l_error_array.delete;
     l_parent_plan_id := p_parent_plan_id;

     IF (p_parent_plan_id is NULL OR p_parent_plan_id <0) THEN
        select qa_plans_api.plan_id(p_parent_plan_name) into result_num from dual;
        IF (result_num IS NULL OR result_num < 1) THEN
           ret_status := 'F';
           l_error_array(1) := 'QA_PC_SS_INVALID_PARENT_PLAN';
        ELSE
           l_parent_plan_id := result_num;
        END IF;
     END IF;

     l_child_plan_id := p_child_plan_id;
     IF (p_child_plan_id is NULL OR p_child_plan_id <0) THEN
        select qa_plans_api.plan_id(p_child_plan_name) into result_num from dual;
        IF (result_num IS NULL OR result_num < 1) THEN
           ret_status := 'F';
           l_count := l_error_array.count +1;
           l_error_array(l_count) := 'QA_PC_SS_INVALID_CHILD_PLAN';
        ELSE
           l_child_plan_id := result_num;
        END IF;
     END IF;

     IF l_child_plan_id = l_parent_plan_id THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_SAME_PLAN';
     END IF;

     OPEN c(l_parent_plan_id, l_child_plan_id) ;
     FETCH c INTO l_rel_exists;
     IF l_rel_exists IS NOT NULL AND
        l_rel_exists = 1 THEN
         -- bug 2390520
         -- anagarwa Fri May 24 12:36:23 PDT 2002
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_REL_EXISTS';
     END IF;
     CLOSE c;


     --if data entry mode=automatic, then ensure that num. of rows is entered.
     IF p_data_entry_mode = 2 AND
        (p_num_auto_rows is NULL OR p_num_auto_rows <1) THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_ROW_COUNT_REQD';

     -- set an error message here.
     ELSIF p_data_entry_mode <> 2 AND p_num_auto_rows >0 THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_ROW_COUNT_NOT_REQD';
     END IF;

     -- assign out variables to local var.
     x_status := ret_status;
     x_child_plan_id := l_child_plan_id;
     x_parent_plan_id := l_parent_plan_id;

     IF ret_status = 'F' THEN
        -- call post_error_message
        post_error_messages(l_error_array);

     END IF;

  END insert_plan_rel_chk;

  PROCEDURE update_plan_rel_chk(
                           p_parent_plan_id       IN NUMBER,
                           p_parent_plan_name     IN VARCHAR2,
                           p_child_plan_id        IN NUMBER,
                           p_child_plan_name      IN VARCHAR2,
                           p_data_entry_mode      IN NUMBER,
                           p_layout_mode          IN NUMBER,
                           p_num_auto_rows        IN NUMBER,
                           p_new_plan             IN VARCHAR2,
                           x_parent_plan_id       OUT NOCOPY NUMBER,
                           x_child_plan_id        OUT NOCOPY NUMBER,
                           x_status               OUT NOCOPY VARCHAR2)
  IS

  ret_status       VARCHAR2(1) := 'T';
  l_error_array    ErrorTable;
  result_num       NUMBER;
  l_count          NUMBER;
  l_rel_exists     NUMBER;

  -- bug 2390520
  -- anagarwa Fri May 24 12:36:23 PDT 2002
  l_parent_plan_id NUMBER;
  l_child_plan_id  NUMBER;

  -- local variables will be used instead of inout variables.
  CURSOR c(c_parent_plan_id NUMBER,
           c_child_plan_id NUMBER) IS
     SELECT 1
     FROM   qa_pc_plan_relationship
     WHERE  parent_plan_id = c_parent_plan_id
     AND    child_plan_id = c_child_plan_id;

  BEGIN
     fnd_msg_pub.Initialize();

     fnd_msg_pub.reset();

     l_error_array.delete;
     l_parent_plan_id := p_parent_plan_id;

     IF (p_parent_plan_id is NULL OR p_parent_plan_id <0) THEN
        select qa_plans_api.plan_id(p_parent_plan_name) into result_num from dual;
        IF (result_num IS NULL OR result_num < 1) THEN
           ret_status := 'F';
           l_error_array(1) := 'QA_PC_SS_INVALID_PARENT_PLAN';
        ELSE
           l_parent_plan_id := result_num;
        END IF;
     END IF;

     l_child_plan_id := p_child_plan_id;
     IF (p_child_plan_id is NULL OR p_child_plan_id <0) THEN
        select qa_plans_api.plan_id(p_child_plan_name) into result_num from dual;
        IF (result_num IS NULL OR result_num < 1) THEN
           ret_status := 'F';
           l_count := l_error_array.count +1;
           l_error_array(l_count) := 'QA_PC_SS_INVALID_CHILD_PLAN';
        ELSE
           l_child_plan_id := result_num;
        END IF;
     END IF;

     IF l_child_plan_id = l_parent_plan_id THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_SAME_PLAN';
     END IF;

     OPEN c(l_parent_plan_id, l_child_plan_id) ;
     FETCH c INTO l_rel_exists;
     IF l_rel_exists IS NOT NULL AND
        l_rel_exists = 1 AND
        p_new_plan = 'Y' THEN
         -- bug 2390520
         -- anagarwa Fri May 24 12:36:23 PDT 2002
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_REL_EXISTS';
     END IF;
     CLOSE c;


     IF p_data_entry_mode = 2 AND
        (p_num_auto_rows is NULL OR p_num_auto_rows <1) THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_ROW_COUNT_REQD';

     -- set an error message here.
     ELSIF p_data_entry_mode <> 2 AND p_num_auto_rows >0 THEN
         ret_status := 'F';
         l_count := l_error_array.count +1;
         l_error_array(l_count) := 'QA_PC_SS_ROW_COUNT_NOT_REQD';
     END IF;

     x_status := ret_status;
     x_child_plan_id := l_child_plan_id;
     x_parent_plan_id := l_parent_plan_id;

     IF ret_status = 'F' THEN
        -- call post_error_message
        post_error_messages(l_error_array);

     END IF;

  END update_plan_rel_chk;


  PROCEDURE insert_plan_rel(p_parent_plan_id      NUMBER,
                            p_child_plan_id       NUMBER,
                            p_plan_relationship_type NUMBER,
                            p_data_entry_mode     NUMBER,
                            p_layout_mode         NUMBER,
                            p_auto_row_count      NUMBER,
                            p_default_parent_spec VARCHAR2,
                            p_last_updated_by     NUMBER := fnd_global.user_id,
                            p_created_by          NUMBER := fnd_global.user_id,
                            p_last_update_login   NUMBER := fnd_global.user_id,
                            x_plan_relationship_id IN OUT NOCOPY NUMBER)
      IS

  l_sysdate DATE;
  x_row_id  VARCHAR2(1000);
  l_default_parent_spec  NUMBER := 2;
  l_request_id NUMBER;
  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      IF p_default_parent_spec = 'Y' THEN
         l_default_parent_spec := 1;
      END IF;

      QA_PC_PLAN_REL_PKG.Insert_Row(
                       X_Rowid => x_row_id,
                       X_Plan_Relationship_Id =>x_plan_relationship_id,
                       X_Parent_Plan_Id => p_parent_plan_id,
                       X_Child_Plan_id => p_child_plan_id,
                       X_Plan_Relationship_Type => p_plan_relationship_type,
                       X_Data_Entry_Mode => p_data_entry_mode,
                       X_Layout_Mode => p_layout_mode,
                       X_Auto_Row_Count => p_auto_row_count,
                       X_Default_Parent_Spec => l_default_parent_spec,
                       X_Last_Update_Date =>l_sysdate,
                       X_Last_Updated_By => p_last_updated_by,
                       X_Creation_Date  =>l_sysdate,
                       X_Created_By    => p_created_by,
                       X_Last_Update_Login => p_last_update_login);

        -- call mapping API twice to do AK mapping
        -- AK mapping for VQR results inquiry
        -- twice: once for parent planid and then child planid
         l_request_id := fnd_request.submit_request('QA',
                                                    'QLTSSCPB',
                                                    null,
                                                    null,
                                                    FALSE,
                                                    'CREATE',
                                                    'PLAN',
                                                to_char(p_parent_plan_id));

         l_request_id := fnd_request.submit_request('QA',
                                                    'QLTSSCPB',
                                                    null,
                                                    null,
                                                    FALSE,
                                                    'CREATE',
                                                    'PLAN',
                                                to_char(p_child_plan_id));

        --No more calls to AK mapping. Converted to JRAD
        --Also, better to go through concurrent request. so change made
        --qa_ak_mapping_api.map_plan(p_parent_plan_id, 250, 250);
        --qa_ak_mapping_api.map_plan(p_child_plan_id, 250, 250);
  END insert_plan_rel;


  PROCEDURE insert_element_rel_chk(p_parent_char_id    NUMBER,
                                   p_child_char_id     NUMBER,
                                   p_relationship_type NUMBER,
                                   x_status            OUT NOCOPY VARCHAR2) IS

  l_error_array     ErrorTable;
  l_status          VARCHAR2(1) := 'T';
  l_count           NUMBER;
  l_parent_datatype NUMBER := -1;
  l_child_datatype  NUMBER := -1;
  c_char_id         NUMBER;

  CURSOR c(c_char_id NUMBER) IS
    SELECT datatype
    FROM qa_chars
    WHERE char_id = c_char_id;

  BEGIN

     fnd_msg_pub.Initialize();
     fnd_msg_pub.reset();

     IF l_error_array.count > 0 THEN
        l_error_array.delete;
     END IF;

     IF p_parent_char_id IS NULL OR
        p_parent_char_id < 0 THEN
        l_status := 'F';
        l_error_array(1) := 'QA_PC_SS_INVALID_PARENT_ELMNT';
     END IF;

     IF p_child_char_id IS NULL OR
        p_child_char_id < 0  THEN
        l_status := 'F';
        l_count := l_error_array.count +1;
        l_error_array(l_count) := 'QA_PC_SS_INVALID_CHILD_ELEMENT';
     END IF;

     IF p_relationship_type IS NULL OR
       p_relationship_type <0 THEN
        l_status := 'F';
        l_count := l_error_array.count +1;
        l_error_array(l_count) := 'QA_PC_SS_INVALID_ELMT_REL';
     END IF;

     --also check for datatypes and mandatory flags.

     OPEN c(p_parent_char_id);
     FETCH c INTO l_parent_datatype;
     CLOSE c;

     OPEN c(p_child_char_id);
     FETCH c INTO l_child_datatype;
     CLOSE c;

     -- anagarwa Mon Apr 29 11:29:08 PDT 2002
     -- Bug 2345082 : If relationship is count then datatypes don't matter.

     IF( l_parent_datatype IS NOT NULL AND
         l_child_datatype  IS NOT NULL AND
         l_parent_datatype <> l_child_datatype AND
         p_relationship_type <> 8) THEN

        -- anagarwa Wed Nov 27 10:36:00 PDT 2002
        -- Bug 2642484. this enhancement is done for Nonconformance Sol.
        -- Now SEQUENCE element can be copied to CHARACTER element.
        IF (p_relationship_type = 1  AND
            l_parent_datatype = 5 AND
            l_child_datatype = 1) THEN
            -- do nothing
            null;
        ELSE
            l_status := 'F';
            l_count := l_error_array.count + 1;
            l_error_array(l_count) := 'QA_PC_SS_ELEMENT_MISMATCH';
        END IF;
     END IF;

     x_status := l_status;
     IF l_status = 'F' THEN
        -- call post_error_message
        post_error_messages(l_error_array);
     END IF;

  END insert_element_rel_chk;

  PROCEDURE insert_element_rel(
                p_plan_relationship_id        NUMBER,
                p_parent_char_id              NUMBER,
                p_child_char_id               NUMBER,
                p_element_relationship_type   NUMBER,
                p_link_flag                   VARCHAR2,
                p_last_updated_by             NUMBER  := fnd_global.user_id,
                p_created_by                  NUMBER  := fnd_global.user_id,
                p_last_update_login           NUMBER  := fnd_global.user_id,
                x_element_relationship_id OUT NOCOPY NUMBER) IS

  l_sysdate   DATE;
  l_row_id    VARCHAR2(1000);
  l_link_flag NUMBER;

  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      IF p_link_flag = 'Y' THEN
         l_link_flag := 1;
      ELSE
         l_link_flag := 2;
      END IF;

      QA_PC_ELEMENT_REL_PKG.Insert_Row(
                       X_Rowid => l_row_id,
                       X_Element_Relationship_Id => x_element_relationship_id,
                       X_Plan_Relationship_Id =>p_plan_relationship_id,
                       X_Parent_Char_id => p_parent_char_id,
                       X_Child_Char_id  => p_child_char_id,
                       X_Element_Relationship_Type=>p_element_relationship_type,
                       X_Link_Flag=>l_link_flag,
                       X_Last_Update_Date=>l_sysdate,
                       X_Last_Updated_By => p_last_updated_by,
                       X_Creation_Date =>l_sysdate,
                       X_Created_By   => p_created_by,
                       X_Last_Update_Login => p_last_update_login);

  END insert_element_rel;

  PROCEDURE insert_criteria_rel(p_plan_relationship_id       NUMBER,
                p_char_id           NUMBER,
                p_operator          NUMBER,
                p_low_value         VARCHAR2,
--                p_low_value_id      NUMBER,
                p_high_value        VARCHAR2,
--                p_high_value_id     NUMBER,
                p_last_updated_by   NUMBER  := fnd_global.user_id,
                p_created_by        NUMBER  := fnd_global.user_id,
                p_last_update_login NUMBER  := fnd_global.user_id,
                x_criteria_id       OUT NOCOPY NUMBER) IS

  l_sysdate   DATE;
  l_row_id    VARCHAR2(1000);

  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      QA_PC_CRITERIA_PKG.Insert_Row(
                       X_Rowid => l_row_id,
                       X_Criteria_Id => x_criteria_id,
                       X_Plan_Relationship_Id =>p_plan_relationship_id,
                       X_Char_id => p_char_id,
                       X_Operator => p_operator,
                       X_Low_Value => p_low_value,
                       X_Low_Value_Id => null,
                       X_High_Value => p_high_value,
                       X_High_Value_Id => null,
                       X_Last_Update_Date=>l_sysdate,
                       X_Last_Updated_By => p_last_updated_by,
                       X_Creation_Date =>l_sysdate,
                       X_Created_By   => p_created_by,
                       X_Last_Update_Login => p_last_update_login);

  END insert_criteria_rel;


  PROCEDURE update_plan_rel(
                            -- p_rowid                  VARCHAR2,
                            p_plan_relationship_id   NUMBER,
                            p_parent_plan_id         NUMBER,
                            p_child_plan_id          NUMBER,
                            p_plan_relationship_type NUMBER,
                            p_data_entry_mode        NUMBER,
                            p_layout_mode            NUMBER,
                            p_auto_row_count         NUMBER,
                            p_default_parent_spec    VARCHAR2,
                            p_last_updated_by        NUMBER:=fnd_global.user_id,
                            p_created_by             NUMBER:=fnd_global.user_id,
                            p_last_update_login      NUMBER:=fnd_global.user_id
                           ) IS
  l_sysdate   DATE;
  l_rowid    VARCHAR2(1000);
  l_default_parent_spec NUMBER := 2;

  CURSOR c IS

  select rowid
  from   qa_pc_plan_relationship
  where  plan_relationship_id = p_plan_relationship_id;

  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      OPEN c ;
      FETCH c INTO l_rowid;
      CLOSE c;

      IF p_default_parent_spec = 'Y' THEN
         l_default_parent_spec := 1;
      END IF;

      QA_PC_PLAN_REL_PKG.Update_Row(
                       X_Rowid                  => l_rowid,
                       X_Plan_Relationship_Id   => p_plan_relationship_id,
                       X_Parent_Plan_Id         => p_parent_plan_id,
                       X_Child_Plan_id          => p_child_plan_id,
                       X_Plan_Relationship_Type => p_plan_relationship_type,
                       X_Data_Entry_Mode        => p_data_entry_mode,
                       X_Layout_Mode            => p_layout_mode,
                       X_Auto_Row_Count         => p_auto_row_count,
                       X_Default_Parent_Spec    => l_default_parent_spec,
                       X_Last_Update_Date       => l_sysdate,
                       X_Last_Updated_By        => p_last_updated_by,
                       X_Creation_Date          => l_sysdate,
                       X_Created_By             => p_created_by,
                       X_Last_Update_Login      => p_last_update_login );


  END update_plan_rel;

  PROCEDURE update_element_rel(
                p_element_relationship_id     NUMBER,
                p_plan_relationship_id        NUMBER,
                p_parent_char_id              NUMBER,
                p_child_char_id               NUMBER,
                p_element_relationship_type   NUMBER,
                p_link_flag                   VARCHAR2,
                p_last_updated_by             NUMBER  := fnd_global.user_id,
                p_created_by                  NUMBER  := fnd_global.user_id,
                p_last_update_login           NUMBER  := fnd_global.user_id,
                p_row_id                      VARCHAR2) IS

  l_sysdate   DATE;
  l_row_id    VARCHAR2(1000);
  l_link_flag NUMBER;

  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      IF p_link_flag = 'Y' THEN
         l_link_flag := 1;
      ELSE
         l_link_flag := 2;
      END IF;

      QA_PC_ELEMENT_REL_PKG.Update_Row(
                       X_Rowid => p_row_id,
                       X_Element_Relationship_Id => p_element_relationship_id,
                       X_Plan_Relationship_Id =>p_plan_relationship_id,
                       X_Parent_Char_id => p_parent_char_id,
                       X_Child_Char_id  => p_child_char_id,
                       X_Element_Relationship_Type=>p_element_relationship_type,
                       X_Link_Flag=>l_link_flag,
                       X_Last_Update_Date=>l_sysdate,
                       X_Last_Updated_By => p_last_updated_by,
                       X_Creation_Date =>l_sysdate,
                       X_Created_By   => p_created_by,
                       X_Last_Update_Login => p_last_update_login);

  END update_element_rel;


  PROCEDURE update_criteria_rel(
                p_rowid                VARCHAR2,
                p_plan_relationship_id NUMBER,
                p_char_id              NUMBER,
                p_operator             NUMBER,
                p_low_value            VARCHAR2,
                p_high_value           VARCHAR2,
                p_last_updated_by      NUMBER  := fnd_global.user_id,
                p_created_by           NUMBER  := fnd_global.user_id,
                p_last_update_login    NUMBER  := fnd_global.user_id,
                p_criteria_id          NUMBER) IS

  l_sysdate   DATE;

  BEGIN

      SELECT sysdate INTO l_sysdate
      FROM DUAL;

      QA_PC_CRITERIA_PKG.Update_Row(
                       X_Rowid => p_rowid,
                       X_Criteria_Id => p_criteria_id,
                       X_Plan_Relationship_Id =>p_plan_relationship_id,
                       X_Char_id => p_char_id,
                       X_Operator => p_operator,
                       X_Low_Value => p_low_value,
                       X_Low_Value_Id => null,
                       X_High_Value => p_high_value,
                       X_High_Value_Id => null,
                       X_Last_Update_Date=>l_sysdate,
                       X_Last_Updated_By => p_last_updated_by,
                       X_Creation_Date =>l_sysdate,
                       X_Created_By   => p_created_by,
                       X_Last_Update_Login => p_last_update_login);

  END update_criteria_rel;

  PROCEDURE delete_element_rel(p_element_relationship_id NUMBER) IS

  BEGIN
      --QA_PC_CRITERIA_PKG.Delete_Row(X_Rowid => p_rowid);
    DELETE FROM QA_PC_ELEMENT_RELATIONSHIP
    WHERE element_relationship_id = p_element_relationship_id;

  END delete_element_rel;


  PROCEDURE delete_criteria(p_criteria_id NUMBER) IS

  BEGIN
      --QA_PC_CRITERIA_PKG.Delete_Row(X_Rowid => p_rowid);
    DELETE FROM QA_PC_CRITERIA
    WHERE criteria_id = p_criteria_id;

  END delete_criteria;



/*
This function takes in plan_id, collection_id and occurrence and returns a 'T'
if it finds any child record for this record. Otherwise it returns 'F'.
*/

FUNCTION descendant_plans_exist(p_plan_id NUMBER)
         RETURN VARCHAR2 IS

CURSOR c(c_child_plan_id NUMBER) IS
    SELECT 1
    FROM  qa_pc_plan_relationship
    WHERE parent_plan_id = c_child_plan_id;

l_exists NUMBER:= -1;

 BEGIN

    OPEN c(p_plan_id);
    FETCH c INTO l_exists;
    CLOSE c;

    IF (l_exists <> 1) THEN
       RETURN 'No';
    END IF;

    RETURN  'Yes';
 END descendant_plans_exist;


FUNCTION is_plan_applicable (
                p_plan_id IN NUMBER,
                search_array IN qa_txn_grp.ElementsArray)
        RETURN VARCHAR2
IS
        security_profile NUMBER;
        allow VARCHAR2(1) := 'T';
BEGIN

        /*
        --add security related logic here
        --
        security_profile := FND_PROFILE.VALUE('QA_SECURITY_USED');
        IF (security_profile = 1) THEN --make use of security
                allow :=  fnd_data_security.check_function(
                                p_api_version => 1.0,
                                p_function => 'QA_RESULTS_VIEW',
                                p_object_name => 'QA_PLANS',
                                p_instance_pk1_value => p_plan_id
                                );
                        --user name is default current user
                        --not necessary to pass in
                if (allow = 'F') then
                        return 'N';--plan does not apply
                end if; --else continue on below
        END IF;--end if for security profile
        --end security related logic
        */


        IF ( check_for_elements(p_plan_id, search_array) = 'N')
        THEN
                RETURN 'N'; --plan does not apply
        END IF;

        IF ( check_for_results(p_plan_id, search_array) = 'N')
        THEN
                RETURN 'N';
        END IF;

        -- if reached here all checks passed fine
        RETURN 'Y'; --plan applies

END is_plan_applicable; --end function

FUNCTION get_plan_vqr_sql (
                p_plan_id IN NUMBER,
                p_search_str IN VARCHAR2,
                p_collection_id IN NUMBER,
                p_occurrence IN NUMBER,
                p_search_str2 IN VARCHAR2 default null, --future use
                p_search_str3 IN VARCHAR2 default null) --future use
        RETURN VARCHAR2
IS
        search_array qa_txn_grp.ElementsArray;
        SelectFromClause VARCHAR2(20000);
        WhereClause VARCHAR2(20000);
BEGIN
        --p_search_str is of form 10=XYZ@19=Ssaf@87=fsfsf
        --should not have '@' at the beginning or end
        --

        SelectFromClause :=
                qa_results_interface_pkg.get_plan_vqr_sql (p_plan_id);

        --below for direct link, first check coll id and occ values

        if (p_collection_id is not null and p_occurrence is not null
                and p_collection_id <> -1 and p_occurrence <> -1) then
                WhereClause := ' WHERE plan_id = '||p_plan_id
                               || ' AND collection_id = '||p_collection_id
                               || ' AND occurrence = ' || p_occurrence;
        else

                search_array := qa_txn_grp.result_to_array(p_search_str);

                WhereClause := get_where_clause(p_plan_id, search_array);
        end if; --for direct link embedding in if clause

        RETURN SelectFromClause || WhereClause;

END get_plan_vqr_sql; --end function

FUNCTION get_child_vqr_sql (
                p_child_plan_id IN NUMBER,
                p_parent_plan_id IN NUMBER,
                p_parent_collection_id IN NUMBER,
                p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2
IS

        SelectFromClause VARCHAR2(20000);
        WhereClause VARCHAR2(20000);
BEGIN

        SelectFromClause :=
                qa_results_interface_pkg.get_plan_vqr_sql (p_child_plan_id);


        WhereClause := ' WHERE PLAN_ID = ' || p_child_plan_id
                        || ' AND (COLLECTION_ID, OCCURRENCE) IN (SELECT CHILD_COLLECTION_ID, CHILD_OCCURRENCE FROM QA_PC_RESULTS_RELATIONSHIP WHERE PARENT_OCCURRENCE = ' || p_parent_occurrence || ' AND CHILD_PLAN_ID = ' || p_child_plan_id || ' ) ';


        RETURN SelectFromClause || WhereClause;

END get_child_vqr_sql; --end function

FUNCTION get_parent_vqr_sql (
                p_parent_plan_id IN NUMBER,
                p_parent_collection_id IN NUMBER,
                p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2
IS

        SelectFromClause VARCHAR2(20000);
        WhereClause VARCHAR2(20000);
BEGIN

        SelectFromClause :=
                qa_results_interface_pkg.get_plan_vqr_sql (p_parent_plan_id);


        WhereClause := ' WHERE PLAN_ID = ' || p_parent_plan_id
                        || ' AND COLLECTION_ID = ' || p_parent_collection_id
                        || ' AND OCCURRENCE = ' || p_parent_occurrence;


        RETURN SelectFromClause || WhereClause;

END get_parent_vqr_sql; --end function



  PROCEDURE delete_plan_rel(p_plan_relationship_id NUMBER) IS

  BEGIN

    DELETE FROM QA_PC_PLAN_RELATIONSHIP
    WHERE plan_relationship_id = p_plan_relationship_id;

    DELETE FROM QA_PC_ELEMENT_RELATIONSHIP
    WHERE plan_relationship_id = p_plan_relationship_id;

    DELETE FROM QA_PC_CRITERIA
    WHERE plan_relationship_id = p_plan_relationship_id;

  END delete_plan_rel;

   --ilawler - bug #3436428 - Thu Mar  4 11:17:32 2004
   --cleaned up the code and changed return semantics
   --
   --p_search_str is of form: '<char_id1>=<val1>@<char_id2>=<val2>@...'
   --if plans found, returns string in the form: '<plan_id1>, <plan_id2>, ...'
   --
   --Invariants: p_search_str should not have a '@' at the beginning or end
   FUNCTION get_plan_ids (p_search_str  IN VARCHAR2,
                          p_org_id      IN VARCHAR2 default null,
                          p_search_str2 IN VARCHAR2 default null, --future use
                          p_search_str3 IN VARCHAR2 default null)
   RETURN VARCHAR2
   IS
      l_plan_ids        VARCHAR2(2000) := '';
      l_plan_seen       BOOLEAN := false;
      l_plan_separator  VARCHAR2(1) := ',';
      l_applicable      VARCHAR2(1);
      l_search_array    qa_txn_grp.ElementsArray;

      cursor l_plans_cursor IS
         select distinct qpr.parent_plan_id
         from qa_pc_plan_relationship qpr, qa_plans qp
         where qpr.parent_plan_id = qp.plan_id
         and qp.organization_id = p_org_id;
   BEGIN
      --sanity check, don't let them blink search using an org
      IF (p_search_str IS NULL) THEN
         RETURN '';
      END IF;

      --parse the search criteria into an array
      l_search_array := qa_txn_grp.result_to_array(p_search_str);

      --loop over possible parent plans, checking each one
      FOR l_plan_rec IN l_plans_cursor LOOP
         l_applicable := is_plan_applicable(l_plan_rec.parent_plan_id,
                                            l_search_array);
         IF (l_applicable = 'Y') THEN
            IF l_plan_seen THEN
               l_plan_ids := l_plan_ids || l_plan_separator || l_plan_rec.parent_plan_id;
            ELSE
               l_plan_ids := l_plan_rec.parent_plan_id;
               l_plan_seen := true;
            END IF;
         END IF;

      END LOOP;

      RETURN l_plan_ids;
END get_plan_ids;

END qa_ss_parent_child_pkg;


/
