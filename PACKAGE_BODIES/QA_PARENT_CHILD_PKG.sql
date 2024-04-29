--------------------------------------------------------
--  DDL for Package Body QA_PARENT_CHILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PARENT_CHILD_PKG" as
/* $Header: qapcb.pls 120.26.12010000.8 2010/04/08 12:24:16 skolluku ship $ */

 --
 -- bug 7588376
 -- New collection to store the values corresponding to the
 -- relationship elements selected from the parent collection
 -- plan
 -- skolluku
 Type parent_plan_vales_tab_typ is table of varchar2(2000) index by varchar2(2000);
 parent_plan_vales_tab parent_plan_vales_tab_typ;

-- Bug 4343758
-- R12 OAF Txn Integration Project
-- Standard Global variable
-- shkalyan 05/07/2005.
g_pkg_name      CONSTANT VARCHAR2(30)   := 'QA_PARENT_CHILD_PKG';

--
-- Through out this package all the functions will return 'T' or 'F'
-- instead of 'TRUE' or 'FALSE'. The reason is, we may call this
-- serverside functions from Java or by other platforms.
--

 FUNCTION aggregate_functions(p_sql_string IN VARCHAR2,
                               p_occurrence IN NUMBER,
                               p_child_plan_id IN NUMBER,
                               x_value OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
   l_value NUMBER;

  BEGIN
     BEGIN
         EXECUTE IMMEDIATE p_sql_string INTO l_value USING p_occurrence,p_child_plan_id;

         -- Bug 2716973
         -- Even though fix here is not required, but for consistency adding NVL function here.
         -- rponnusa Sun Jan 12 23:59:07 PST 2003

         x_value := NVL(l_value,0);
         RETURN 'T';
     EXCEPTION
        WHEN OTHERS THEN
             RETURN 'F';
     END;

 END aggregate_functions;

 --
 -- bug 5682448
 -- added the Txn_header_id parameter
 -- ntungare Wed Feb 21 07:28:43 PST 2007
 --
 FUNCTION aggregate_functions(p_sql_string IN VARCHAR2,
                              p_occurrence IN NUMBER,
                              p_child_plan_id IN NUMBER,
                              p_txn_header_id IN NUMBER,
                              x_value OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
   l_value NUMBER;

  BEGIN
     BEGIN
         EXECUTE IMMEDIATE p_sql_string INTO l_value
           USING p_occurrence,p_child_plan_id,p_txn_header_id;

         -- Bug 2716973
         -- Even though fix here is not required, but for consistency adding NVL function here.
         -- rponnusa Sun Jan 12 23:59:07 PST 2003
         x_value := NVL(l_value,0);
         RETURN 'T';
     EXCEPTION
        WHEN OTHERS THEN
             RETURN 'F';
     END;

 END aggregate_functions;


 FUNCTION commit_allowed(p_plan_id NUMBER, p_collection_id NUMBER,
                         p_occurrence NUMBER ,p_child_plan_ids VARCHAR2)   RETURN VARCHAR2 IS
  l_incomplete_plan_ids VARCHAR2(10000);
  BEGIN

    -- Bug 5161719. SHKALYAN 13-Apr-2006
    -- Modified to call the new overloaded commit_allowed to avoid
    -- code duplication
    RETURN commit_allowed
           (
             p_plan_id => p_plan_id,
             p_collection_id => p_collection_id,
             p_occurrence => p_occurrence,
             p_child_plan_ids => p_child_plan_ids,
             x_incomplete_plan_ids => l_incomplete_plan_ids
           );
  END commit_allowed;

  -- Bug 5161719. SHKALYAN 13-Apr-2006
  -- Created this overloaded commit_allowed function to pass back to the
  -- caller a list of incomplete child plan ids in x_incomplete_plan_ids
  -- This is because in OAF Txn integration project the message is expected
  -- to have the incomplete child plan information.
  -- Rest of the logic was moved from the old get_plan_name
  -- to avoid code duplication.
  FUNCTION commit_allowed(
                 p_plan_id                         NUMBER,
                 p_collection_id                   NUMBER,
                 p_occurrence                      NUMBER,
                 p_child_plan_ids                  VARCHAR2,
                 x_incomplete_plan_ids  OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

---
--- Simple function which returns True when results are collected for
--- immediate child plans else returns False.
---
--- Important thing to remember here is  that collection_id for parent
--- child plan are same in case of EQR. That is the reason I have included
--- one more where condtion in the cursor c2. See the following statement
---          'AND   child_collection_id = p_collection_id '
---
--- The parameter 'p_child_plan_ids' will contain all the immediate child plan ids
--- separated by comma operator.


  l_child_id_array       ChildPlanArray;
  l_child_plan_id        NUMBER;
  l_total_length         NUMBER;
  l_result               VARCHAR2(1);
  separator  CONSTANT    VARCHAR2(1) := ',';

-- Bug 2300962. Removed child_collection_id in the where clause
-- To check, child is entered or not child plan id is enough.

  CURSOR c2(c_child_plan_id NUMBER)  IS
               SELECT 'T' FROM qa_pc_results_relationship
               WHERE  parent_plan_id = p_plan_id
               AND    parent_collection_id = p_collection_id
               AND    parent_occurrence = p_occurrence
               AND    child_plan_id = c_child_plan_id
               AND    rownum =1;

  BEGIN
   l_result := 'F';
   l_total_length := LENGTH(p_child_plan_ids);

   -- We need check for all the child_plan_ids one by one to see whether records are
   -- entered for the child plan or not.

  -- anagarwa Mon Apr 15 15:51:58 PDT 2002
  -- Bug 2320896 was being caused due to error in logic.
  -- This code is being replaced to avoid character to number conversion


   parse_list(p_child_plan_ids, l_child_id_array);

   FOR i IN 1..l_child_id_array.COUNT LOOP
      l_child_plan_id := l_child_id_array(i);
      OPEN c2(l_child_plan_id);
      FETCH c2 INTO l_result;
      IF (c2%NOTFOUND) THEN
         l_result := 'F';

         -- Bug 5161719. SHKALYAN 13-Apr-2006
         -- In addition to setting result as false form the list of
         -- incomplete plan ids
         x_incomplete_plan_ids := x_incomplete_plan_ids || separator || l_child_plan_id;
         CLOSE c2;
         EXIT;
      END IF;
      CLOSE c2;

   END LOOP;

   -- Bug 5161719. SHKALYAN 13-Apr-2006
   -- Remove the leading comma
   IF ( x_incomplete_plan_ids IS NOT NULL ) THEN
     x_incomplete_plan_ids := SUBSTR( x_incomplete_plan_ids, LENGTH(separator) + 1 );
   END IF;

   RETURN l_result;

 END commit_allowed;


 PROCEDURE enable_and_fire_actions(p_collection_id    NUMBER) IS

---
---  This procedure commits all the records corresponding to one single session with status = 2.
---  This is required since all the child records will be saved with qa_results.status =1
---  When the child record is enabled, status code will be changed to 2. The status of
---  child record is changed to 2 only when Parent record gets committed
---

  BEGIN
       qa_results_api.enable_and_fire_action(p_collection_id);
 END enable_and_fire_actions;

 FUNCTION get_descendants(
      p_plan_id         NUMBER,
      p_collection_id   NUMBER,
      p_occurrence      NUMBER,
      x_plan_ids          OUT NOCOPY dbms_sql.number_table,
      x_collection_ids    OUT NOCOPY dbms_sql.number_table,
      x_occurrences       OUT NOCOPY dbms_sql.number_table)  RETURN VARCHAR2 IS

---
--- Given a parent record (plan/collection/occurrence), this procedure finds all the child and
--- grandchildren records (therefore, descendants) of the record.  These are returned in the
--- three output PL/SQL tables.  The parent record itself is not included in the output.
--- The query technical is called hierarchical subquery.  The final where clause makes
--- sure the child record is actually enabled in the  qa_results table.
---

  BEGIN

    SELECT      child_plan_id,  child_collection_id,  child_occurrence
    BULK COLLECT INTO
                x_plan_ids,  x_collection_ids,  x_occurrences
    FROM        qa_pc_results_relationship r
    WHERE EXISTS (
                SELECT 1
                FROM qa_results qr
                WHERE qr.plan_id = r.child_plan_id AND
                      qr.collection_id = r.child_collection_id AND
                      qr.occurrence = r.child_occurrence AND
                      (qr.status IS NULL or qr.status=2) )
    START WITH  parent_plan_id = p_plan_id AND
                parent_collection_id = p_collection_id AND
                parent_occurrence = p_occurrence
    CONNECT BY  PRIOR child_occurrence = parent_occurrence;

    IF (SQL%FOUND) THEN
      RETURN 'T';
    ELSE
      RETURN 'F';
    END IF;

 END get_descendants;

---------------------------------------------------------------------------
 FUNCTION evaluate_child_lov_criteria( p_plan_id          IN NUMBER,
                                        p_criteria_values  IN VARCHAR2,
                                        x_child_plan_ids  OUT NOCOPY VARCHAR2)
                                        RETURN VARCHAR2 IS
---
--- This function finds all the matching child plan for the current plan.
--- First converts the values passed through p_criteria_values
--- into array. For each child plan we checking for the criteria values
--- by calling another function 'criteria_matched'.
--- We will concatenate all the child id into string with separator as ','
--- Return true if any matching child availabe with the concatenated
--- child plan_id's otherwise return false.
---

      -- Bug 2448888. when all child plans have effective from and to date range is
      -- outside the sysdate then, FRM-41084:- Error getting Group Cell raised when
      -- child button is hit. This is similar to bug Bug 2355817.
      -- Make a join to qa_plans in cursor C and fetch only effective child plans.
      -- rponnusa Tue Jul  9 00:25:19 PDT 2002

      CURSOR c IS SELECT qpr.plan_relationship_id,qpr.child_plan_id
                  FROM   qa_plans qp,
                         qa_pc_plan_relationship qpr
                  WHERE  qpr.parent_plan_id = p_plan_id
                  AND    qpr.child_plan_id = qp.plan_id
                  AND    qpr.plan_relationship_type = 1
                  AND    qpr.data_entry_mode in (1,2,3)
                  AND ((qp.effective_to IS NULL AND TRUNC(SYSDATE) >= qp.effective_from)
                       OR (qp.effective_from IS NULL AND TRUNC(SYSDATE) <= qp.effective_to)
                       OR (qp.effective_from IS NOT NULL AND qp.effective_to IS NOT NULL
                           AND TRUNC(SYSDATE) BETWEEN qp.effective_from AND qp.effective_to)
                       OR (qp.effective_from IS NULL AND qp.effective_to IS NULL ));

     current_child_plan_id  NUMBER;
     p_plan_relationship_id NUMBER;
     ret_value              VARCHAR2(1);
     childexist             BOOLEAN;
     elements               qa_txn_grp.ElementsArray;
  BEGIN
     ret_value := 'F';
     childexist := FALSE;
     elements := qa_txn_grp.result_to_array(p_criteria_values);
     OPEN c;
     LOOP
        FETCH c INTO p_plan_relationship_id,current_child_plan_id;
        IF (c%NOTFOUND) THEN
          EXIT;
        END IF;

        IF( criteria_matched(p_plan_relationship_id,elements) = 'T') THEN

            IF( childexist) THEN
               x_child_plan_ids := x_child_plan_ids ||','||current_child_plan_id;
            ELSE
               x_child_plan_ids :=current_child_plan_id;
               childexist := TRUE;
            END IF;
        END IF;
     END LOOP;

     IF (c%ROWCOUNT = 0) THEN
        ret_value := 'F';
     ELSIF (x_child_plan_ids IS NULL) THEN
        ret_value := 'F';
     ELSE
        ret_value := 'T';
     END IF;
     CLOSE c;

     RETURN ret_value;
 END evaluate_child_lov_criteria;

/* following function added to be able to view history records in VQR.
   The name is eval_updateview_lov_criteria and NOT evaluate_updateview_lov_criteria
   because there's a character limit for length of function name in package.
*/

 FUNCTION eval_updateview_lov_criteria( p_plan_id          IN NUMBER,
                                        p_criteria_values  IN VARCHAR2,
                                        x_child_plan_ids  OUT NOCOPY VARCHAR2)
                                        RETURN VARCHAR2 IS
---
--- This function finds all the matching child plan for the current plan.
--- First converts the values passed through p_criteria_values
--- into array. For each child plan we checking for the criteria values
--- by calling another function 'criteria_matched'.
--- We will concatenate all the child id into string with separator as ','
--- Return true if any matching child availabe with the concatenated
--- child plan_id's otherwise return false.
---

      -- Bug 2448888. when all child plans have effective from and to date range is
      -- outside the sysdate then, FRM-41084:- Error getting Group Cell raised when
      -- child button is hit. This is similar to bug Bug 2355817.
      -- Make a join to qa_plans in cursor C and fetch only effective child plans.
      -- rponnusa Tue Jul  9 00:25:19 PDT 2002

      CURSOR c IS SELECT qpr.plan_relationship_id,qpr.child_plan_id
                  FROM   qa_plans qp,
                         qa_pc_plan_relationship qpr
                  WHERE  qpr.parent_plan_id = p_plan_id
                  AND    qpr.child_plan_id = qp.plan_id
                  AND    qpr.plan_relationship_type = 1
                  AND    qpr.data_entry_mode in (1,2,3,4)
                  AND ((qp.effective_to IS NULL AND TRUNC(SYSDATE) >= qp.effective_from)
                       OR (qp.effective_from IS NULL AND TRUNC(SYSDATE) <= qp.effective_to)
                       OR (qp.effective_from IS NOT NULL AND qp.effective_to IS NOT NULL
                           AND TRUNC(SYSDATE) BETWEEN qp.effective_from AND qp.effective_to)
                       OR (qp.effective_from IS NULL AND qp.effective_to IS NULL ));

     current_child_plan_id  NUMBER;
     p_plan_relationship_id NUMBER;
     ret_value              VARCHAR2(1);
     childexist             BOOLEAN;
     elements               qa_txn_grp.ElementsArray;
  BEGIN
     ret_value := 'F';
     childexist := FALSE;
     elements := qa_txn_grp.result_to_array(p_criteria_values);
     OPEN c;
     LOOP
        FETCH c INTO p_plan_relationship_id,current_child_plan_id;
        IF (c%NOTFOUND) THEN
          EXIT;
        END IF;

        IF( criteria_matched(p_plan_relationship_id,elements) = 'T') THEN

            IF( childexist) THEN
               x_child_plan_ids := x_child_plan_ids ||','||current_child_plan_id;
            ELSE
               x_child_plan_ids :=current_child_plan_id;
               childexist := TRUE;
            END IF;
        END IF;
     END LOOP;

     IF (c%ROWCOUNT = 0) THEN
        ret_value := 'F';
     ELSIF (x_child_plan_ids IS NULL) THEN
        ret_value := 'F';
     ELSE
        ret_value := 'T';
     END IF;
     CLOSE c;

     RETURN ret_value;

 END eval_updateview_lov_criteria;

-----------------------------------------------------------------------------------------------------
 FUNCTION criteria_matched(p_plan_relationship_id IN NUMBER,
                            p_criteria_array qa_txn_grp.ElementsArray)
                            RETURN VARCHAR2 IS

---
--- This function first finds out all the criteria for the parent-child
--- relationship through plan_relationship_id in qa_pc_criteria table.
--- If no criteria found then return true
--- else finds out all the char_id and its associated values
--- for the plan_relationship_id.

--- Check for each char_id (ie,. element ) to see value available
--- in the parent form. We are checking this condition in the
--- element array (which contains all the parent-form char_id and
--- its associated value). If, not able to find the char_id in the
--- element array then return false.

--- If there is matching char_id in element array then compare
--- the value in the element array with the low_value, high_value.
--- If everything is ok then return true, false otherwise.
---

    l_char_id      NUMBER ;
    l_operator     NUMBER ;
    l_low_value    VARCHAR2(150);
    l_high_value   VARCHAR2(150);
    l_ret_value    VARCHAR2(1);
    l_datatype     NUMBER;

    CURSOR c IS SELECT qpc.char_id,qpc.operator,qpc.low_value,qpc.high_value,qc.datatype
                FROM   qa_pc_criteria qpc ,qa_chars qc
                WHERE  qpc.plan_relationship_id = p_plan_relationship_id
                AND    qpc.char_id = qc.char_id;
  BEGIN

    l_ret_value := 'F';
    OPEN c;

    -- To launch a single child plan there may be more than one criteria defined.
    -- Hence going into the loop to match all criteria. In case of more than one
    -- criteria, all the criteria should match in order to return TRUE

    LOOP
       FETCH c INTO l_char_id,  l_operator, l_low_value, l_high_value, l_datatype;
       IF (c%NOTFOUND) THEN
          EXIT;
       END IF;

      -- There are records for the plan_relationship_id, our next job is to
      -- check the value entered in the parent plan for the element, matches
      -- with the criteria  for the same element in qa_pc_criteria

       IF (p_criteria_array.EXISTS(l_char_id)) THEN

         IF( QLTCOMPB.compare(p_criteria_array(l_char_id).value,
                              l_operator,l_low_value,
                              l_high_value,l_datatype)) THEN

            l_ret_value := 'T';
         ELSE
             -- For example if 3 criteria defined and matching condition
             -- fails in the first criteria itself then we need not check for
             -- other criterias, we can simply exit from the loop and
             -- return FALSE

            l_ret_value := 'F';
            EXIT;
         END IF;
       ELSE
          -- This is a worst case. There is no value found in the element array
          -- for the char_id
          l_ret_value := 'F';
       END IF;
    END LOOP;

    IF (c%ROWCOUNT = 0) THEN
        -- No criteria defined for the plan, so simply return TRUE
        l_ret_value := 'T';
    END IF;
    CLOSE c;

    RETURN l_ret_value;
  END criteria_matched;

------------------------------------------------------------------------------------------
  FUNCTION evaluate_criteria(p_plan_id            IN NUMBER,
                             p_criteria_values    IN VARCHAR2,
                             p_relationship_type  IN NUMBER,
                             p_data_entry_mode    IN NUMBER,
                             x_child_plan_ids     OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
  --
  -- This function finds out the matching child plan for the given data_entry_mode and
  -- relationship_type. In case of matching child found returns TRUE with the child
  -- plan_id in a comma separated string through x_child_plan_ids.
  -- In case of no match simply returns FALSE
  --

    CURSOR c IS SELECT   plan_relationship_id,child_plan_id
                  FROM   qa_pc_plan_relationship
                  WHERE  parent_plan_id    = p_plan_id
                  AND    plan_relationship_type = p_relationship_type
                  AND    data_entry_mode   = p_data_entry_mode;

  -- Added the cursor below to check the effectivity of the child plan.
  -- The Cursor will fetch the child_plan only if it falls in the effective
  -- data range. Bug 2355817. kabalakr 06 MAY 2002.

    CURSOR p(l_child_plan_id NUMBER) IS
       SELECT plan_id
       FROM qa_plans
       WHERE plan_id = l_child_plan_id
       AND ((effective_to IS NULL AND TRUNC(SYSDATE) >= effective_from)
             OR (effective_from IS NULL AND TRUNC(SYSDATE) <= effective_to)
             OR (effective_from IS NOT NULL AND effective_to IS NOT NULL
                 AND TRUNC(SYSDATE) BETWEEN effective_from AND effective_to)
             OR (effective_from IS NULL AND effective_to IS NULL ));


     current_child_plan_id  NUMBER ;
     p_plan_relationship_id NUMBER ;
     ret_value              VARCHAR2(1);
     childexist             BOOLEAN;
     separator  CONSTANT    VARCHAR2(1) := ',';

     elements               qa_txn_grp.ElementsArray;

  -- Bug 2355817. kabalakr
     l_child_pl_id          NUMBER;

  BEGIN
     ret_value := 'F';
     childexist := FALSE;
     elements := qa_txn_grp.result_to_array(p_criteria_values);
     OPEN c;
     -- Get all the child plan id for the parent plan to find out any matching
     -- childplan is exist or not.
     LOOP

        FETCH c INTO p_plan_relationship_id,current_child_plan_id;
        IF (c%NOTFOUND) THEN
          EXIT;
        END IF;

        -- Open cursor p for the current child_plan_id. Call criteria_matched
        -- only if the cursor fetches the plan. Bug 2355817.
        -- kabalakr 06 MAY 2002.

        OPEN p(current_child_plan_id);
        FETCH p INTO l_child_pl_id;

        IF (p%FOUND) THEN

          IF( criteria_matched(p_plan_relationship_id,elements) = 'T') THEN

        -- The following 'if' condition is required because we should not return the
        -- child plan ids with last character as the separator ( comma here)

             IF( childexist) THEN
               x_child_plan_ids := x_child_plan_ids || separator ||current_child_plan_id;
             ELSE
               x_child_plan_ids :=current_child_plan_id;
               childexist := TRUE;
             END IF;

          END IF;
        END IF;

        CLOSE p;

     END LOOP;

     IF (c%ROWCOUNT = 0) THEN
        -- This scanario can happen if the  parent plan dont have child plan associated
        -- with it.
        ret_value := 'F';

     ELSIF (x_child_plan_ids IS NULL) THEN
        -- This can happen when parent plan have child but the matching criteria to launch the
        -- child fails
        ret_value := 'F';
     ELSE
        ret_value := 'T';
     END IF;
     CLOSE c;

     RETURN ret_value;

  END evaluate_criteria;

    PROCEDURE parse_list(x_result IN VARCHAR2,
                         x_array OUT NOCOPY ChildPlanArray) IS

        -- For longcomments enhancement, Bug 2234299
        -- changed 'value' type from qa_results.character1%TYPE to varchar2(2000)
        -- rponnusa Thu Mar 14 21:27:04 PST 2002

        value VARCHAR2(2000);
        c VARCHAR2(10);
        separator CONSTANT VARCHAR2(1) := ',';
        arr_index INTEGER;
        p INTEGER;
        n INTEGER;

    BEGIN
    --
    -- Loop until a single ',' is found or x_result is exhausted.
    --
        arr_index := 1;
        p := 1;
        n := length(x_result);
        WHILE p <= n LOOP
            c := substr(x_result, p, 1);
            p := p + 1;
            IF (c = separator) THEN
               x_array(arr_index) := value;
               arr_index := arr_index + 1;
               value := '';
            ELSE
               value := value || c;
            END IF;

        END LOOP;
        x_array(arr_index) := value;
    END parse_list;

--
-- Removed DEFAULT clause for GSCC compliance
-- Before removal
--     p_txn_header_id IN NUMBER DEFAULT NULL
-- After removal
--     p_txn_header_id IN NUMBER
-- rkunchal
--

PROCEDURE insert_automatic_records(p_plan_id IN NUMBER,
                                   p_collection_id IN NUMBER,
                                   p_occurrence IN NUMBER,
                                   p_child_plan_ids IN VARCHAR2,
                                   p_relationship_type IN NUMBER,
                                   p_data_entry_mode IN NUMBER,
                                   p_criteria_values IN VARCHAR2,
                                   p_org_id IN NUMBER,
                                   p_spec_id IN NUMBER,
                                   x_status OUT NOCOPY VARCHAR2,
                                   p_txn_header_id IN NUMBER) IS

 parent_values_array    qa_txn_grp.ElementsArray;
 l_child_id_array       ChildPlanArray;
 l_sysdate              DATE;
 l_length               INTEGER;
 l_row_count            INTEGER;
 l_count                INTEGER;
 l_child_char_id        INTEGER;
 l_parent_char_id       INTEGER;
 l_p                    INTEGER;
 l_return_int           INTEGER;
 l_occurrence           NUMBER;
 l_child_plan_id        NUMBER;
 l_child_element_values VARCHAR2(32000);
 l_messages             VARCHAR2(32000);
 l_rowid                VARCHAR2(1000);

 --
 -- Bug 9015927
 -- Added the following variables/types for fetching
 -- the default values for elements and store them in
 -- an array.
 -- skolluku
 --
 TYPE def_arr_typ IS TABLE OF QA_PLAN_CHARS.DEFAULT_VALUE%TYPE INDEX BY BINARY_INTEGER;
 def_arr def_arr_typ;
 cntr NUMBER;
 CURSOR def_cur(c_child_plan_id NUMBER) IS
   SELECT
       qpc.char_id,
       qpc.default_value
   FROM qa_plan_chars qpc,
        qa_plans qp
   WHERE qp.plan_id = qpc.plan_id
     AND qpc.default_value IS NOT NULL
     AND qpc.enabled_flag=1
     AND qp.plan_id = c_child_plan_id;

 CURSOR row_num_cur(c_child_plan_id NUMBER) IS
      SELECT auto_row_count
      FROM   qa_pc_plan_relationship
      WHERE  parent_plan_id = p_plan_id
      AND    child_plan_id = c_child_plan_id;


 -- anagarwa Mon Dec 16 16:55:09 PST 2002
 -- Bug 2701777
 -- if parent or child elements are disabled and the parent child relationship
 -- still exists for them then insert API  qa_mqa_results.post_result raises
 -- returns an error and prevents the history as well as automatic results
 -- from being saved. It causes a ON-INSERT trigger being raised on forms
 -- and even the parent results cannot be saved.
 -- To fix the problem, qa_pc_result_column_v is being modified to have parent
 -- and child char's enabled flags which are checked to be 1 before the values
 -- are copied.

 CURSOR char_id_cur(c_child_plan_id NUMBER) IS
      SELECT parent_char_id, child_char_id
      FROM   qa_pc_result_columns_v
      WHERE  parent_plan_id = p_plan_id
      AND    child_plan_id = c_child_plan_id
      AND    parent_enabled_flag = 1
      AND    child_enabled_flag = 1;

 -- Bug 3678910. In Automatic data collection, sequence generation should be
 -- enabled for Sequence type elements. The below cursor will fetch all the
 -- sequence element char_ids which is not a target for Copy Element relation.
 -- If there exist any copy relation with sequence element as target, the value
 -- will be copied from the parent plan. Sequence will not get generated in that
 -- case. kabalakr.

 -- Bug 4958734.  SQL Repository Fix SQL ID: 15007931
 CURSOR child_seq_char_ids(c_child_plan_id NUMBER) IS
    SELECT qc.char_id
      FROM qa_plan_chars qpc, qa_chars qc
      WHERE qpc.plan_id = c_child_plan_id
        AND qpc.char_id = qc.char_id
        AND qpc.enabled_flag = 1
        AND qc.datatype = 5
    MINUS
      SELECT child_char_id
      FROM qa_pc_result_columns_v
      WHERE parent_plan_id = p_plan_id
        AND child_plan_id = c_child_plan_id
        AND parent_enabled_flag = 1
        AND child_enabled_flag = 1;
/*
      SELECT qc.char_id
      FROM   qa_plan_chars qpc,
             qa_chars qc
      WHERE  qpc.plan_id = c_child_plan_id
      AND    qpc.char_id = qc.char_id
      AND    qpc.enabled_flag = 1
      AND    qc.datatype = 5
      AND    qc.char_id NOT IN
                (SELECT child_char_id
                 FROM   qa_pc_result_columns_v
                 WHERE  parent_plan_id = p_plan_id
                 AND    child_plan_id = c_child_plan_id
                 AND    parent_enabled_flag = 1
                 AND    child_enabled_flag = 1);
*/

 l_seq_default_str VARCHAR(30);

 --
 -- Bug 5383667
 -- String to hold the Id values
 -- ntungare
 --
 l_char_id_val  VARCHAR2(2000);
 l_id_str       VARCHAR2(2000);

 --
 -- bug 6086385
 -- New variable to catch the status returned
 -- by the insert_history_auto_rec_QWB proc
 -- called for the subsequent child records
 -- ntungare Thu Jul  5 06:50:27 PDT 2007
 --
 auto_hist_proc_stat varchar2(2000);

 --
 -- bug 6086385
 -- New variable to read the occurrence of
 -- the Child plan record enetred
 -- ntungare Thu Jul  5 06:50:27 PDT 2007
 --
 l_child_occurrence    NUMBER;

 --
 -- Bug 9015927
 --
 flag boolean;
 BEGIN
     l_length := length(p_child_plan_ids);
     l_count  := 1;
     l_sysdate := sysdate;

     -- flatten the p_criteria_values string into an array
     parent_values_array := qa_txn_grp.result_to_array(p_criteria_values);

     --parse p_child_plan_ids to get child plan ids in an array
     IF p_child_plan_ids IS NOT NULL THEN
         l_p := 0;
         parse_list(p_child_plan_ids, l_child_id_array);
     END IF;
     --for each child plan insert automatic rows as follows
     FOR i IN 1..l_child_id_array.COUNT LOOP

         l_child_plan_id := l_child_id_array(i);
         --
         -- Bug 9015927
         -- Initialize the default values array for
         -- the current child plan.
         -- skolluku
         --
         def_arr.delete();
         FOR def_rec IN def_cur(l_child_plan_id) LOOP
             def_arr(def_rec.char_id) := def_rec.default_value;
         END LOOP;

         --if p_relationship_type=1 and p_data_entry_mode=4, it means we are
         --entering rows for History plan. The number of rows to be entered
         -- in this case is always 1. ELSE get the number of rows to be entered.
         IF(p_relationship_type=1 AND p_data_entry_mode=4) THEN
             l_row_count := 1;
         ELSE
             OPEN row_num_cur(l_child_id_array(i));
             fetch row_num_cur into l_row_count;
             CLOSE row_num_cur;
         END IF;
         --for row_count
         WHILE l_count <= l_row_count LOOP
             --OPEN cursor of parent_char_id and child_char_id from
             -- QA_PC_RESULTS_COLUMN_V for p_plan_id and current child plan id
             --for each cursor row
             l_child_element_values := '';
             FOR char_id_record IN char_id_cur(l_child_id_array(i)) LOOP
                 l_parent_char_id := char_id_record.parent_char_id;
                 l_child_char_id := char_id_record.child_char_id;
                 --
                 -- Bug 9015927
                 -- Remove the element getting its value from Parent
                 -- plan, from the default array so that the copied value
                 -- is not overwritten by the default value.
                 -- skolluku
                 --
                 def_arr.delete(l_child_char_id);

                 -- Bug 2403395
                 -- Added 'replace' command to doubly encode ''@' character
                 -- if the l_parent_char_id.value contains '@' character.
                 -- rponnusa Wed Jun  5 00:49:14 PDT 2002
                 l_child_element_values := l_child_element_values || '@' ||
                       l_child_char_id || '=' ||
                       replace(parent_values_array(l_parent_char_id).value,'@','@@');

                 --
                 -- Bug 5383667
                 -- Constructing the Id str
                 -- The id string has to be built of the format
                 -- charid=value@charid=value.
                 -- ntungare
                 --
                 l_char_id_val := qa_plan_element_api.get_id_val
                                        (l_child_char_id,
                                         p_plan_id,
                                         p_collection_id,
                                         p_occurrence);

                 If l_char_id_val IS NOT NULL THEN
                    l_id_str := l_id_str || '@' || l_child_char_id || '='|| l_char_id_val;
                 End If;

             END LOOP; -- for all columns to be copied
             --
             -- Bug 9015927
             -- Add the default values for the elements that are not
             -- copied from the Parent plan.
             -- skolluku
             --
             cntr := def_arr.first;
             WHILE cntr <= def_arr.last LOOP
                l_child_element_values := l_child_element_values || '@' ||
                    cntr || '=' ||
                    replace(def_arr(cntr),'@','@@');
                cntr := def_arr.next(cntr);
             END LOOP;

             -- Bug 3678910. Now, check whether we are inserting records for
             -- data entry mode - Automatic. If yes, we should make sure to generate
             -- sequence numbers (assign the string 'Automatic') for sequence type
             -- elements that are not copy targets. kabalakr.

             IF(p_relationship_type=1 AND p_data_entry_mode=2) THEN

               fnd_message.set_name('QA','QA_SEQ_DEFAULT');
               l_seq_default_str := fnd_message.get;

               FOR seq_char_id_record IN child_seq_char_ids(l_child_id_array(i))
               LOOP
                  l_child_element_values := l_child_element_values || '@' ||
                                            seq_char_id_record.char_id || '=' ||
                                            l_seq_default_str;
               END LOOP;

             END IF; -- If Automatic. End of bug 3678910.

             --
             -- Bug 5383667
             -- Removing the extra @ appended at the start
             -- ntungare
             --
             If l_id_str IS NOT NULL THEN
                l_id_str := SUBSTR(l_id_str, 2);
             END If;

             IF (l_child_element_values IS NOT NULL) THEN
                 l_child_element_values := substr(l_child_element_values,2);
                 l_p :=1;

                 --
                 -- bug 5682448
                 -- modified the call to the proc to send the commit
                 -- flag as no (0)
                 -- ntungare Wed Feb 21 07:31:00 PST 2007
                 --

                 -- Bug 2290747.Added parameter p_txn_header_id to enable
                 -- history plan record when parent plan gets updated
                 -- rponnusa Mon Apr  1 22:25:49 PST 2002

                 -- anagarwa Thu Dec 19 15:43:27 PST 2002
                 -- Bug 2701777
                 -- post_result_with_no_validation inserts records into
                 -- qa_results without any validations. This prevents any
                 -- errors if user changes element values in parent plan
                 -- but not the History plan

                 --
                 -- bug 5383667
                 -- Passing the Id string as well
                 -- ntungare
                 --
                 l_return_int:= qa_mqa_results.post_result_with_no_validation(
                                            l_occurrence,
                                            p_org_id,
                                            l_child_plan_id, p_spec_id,
                                            p_collection_id,
                                            l_child_element_values,
                                            l_id_str, '', l_p, 0, l_messages,
                                            p_txn_header_id);

                 --ilawler - bug #2648137 - Fri Mar 19 09:50:07 2004
                 --added post_result return check
                 IF l_return_int = -1 THEN
                    x_status := 'F';
                    RETURN;
                 END IF;

                 -- anagarwa Fri Aug 30 13:07:05 PDT 2002
                 -- Bug 2517932
                 -- following added to copy attachments to History records.

                 IF p_data_entry_mode = 4 THEN
                     FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                               X_from_entity_name => 'QA_RESULTS',
                               X_from_pk1_value   => to_char(p_occurrence),
                               X_from_pk2_value   => to_char(p_collection_id),
                               X_from_pk3_value   => to_char(p_plan_id),
                               X_to_entity_name   => 'QA_RESULTS',
                               X_to_pk1_value     => to_char(l_occurrence),
                               X_to_pk2_value     => to_char(p_collection_id),
                               X_to_pk3_value     => to_char(l_child_plan_id));
                 END IF;

                 -- insert the relationships
                 -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
                 -- passing child_txn_header_id
                 QA_PC_RESULTS_REL_PKG.Insert_Row(
                       X_Rowid                   => l_rowid,
                       X_Parent_Plan_Id          => p_plan_id,
                       X_Parent_Collection_Id    => p_collection_id,
                       X_Parent_Occurrence       => p_occurrence,
                       X_Child_Plan_Id           => l_child_plan_id,
                       X_Child_Collection_Id     => p_collection_id,
                       X_Child_Occurrence        => l_occurrence,
                       X_Enabled_Flag            => 1,
                       X_Last_Update_Date        => l_sysdate,
                       X_Last_Updated_By         => fnd_global.user_id,
                       X_Creation_Date           => l_sysdate,
                       X_Created_By              => fnd_global.user_id,
                       X_Last_Update_Login       => fnd_global.user_id,
                       X_Child_Txn_Header_Id     => p_txn_header_id);

             END IF;
             l_count := l_count + 1;
             --
             -- Bug 9015927
             -- Added following call to the actions processor to fire actions only
             -- for automatic child records.
             -- skolluku
             --
             flag := QLTDACTB.DO_ACTIONS(p_collection_id,  1, NULL,  NULL,
                                    TRUE , FALSE, 'BACKGROUND_ASSIGN_VALUE' , 'COLLECTION_ID',
                                    l_occurrence,l_child_plan_id,'COLLECTION_ID');

             --
             -- Bug 5383667
             -- Resetting the Id string for the next row being
             -- processed
             -- ntungare
             l_id_str :=  NULL;

             --
             -- bug 6086385
             -- Getting the Occurrence of the Child record that has been
             -- inserted
             -- nutngare Thu Jul  5 05:21:16 PDT 2007
             --
             SELECT MAX(occurrence)
               into l_child_occurrence
                FROM   qa_results
              WHERE  plan_id = l_child_plan_id and
                     collection_id = p_collection_id and
                     organization_id = p_org_id and
                     txn_header_id = p_txn_header_id;

             --
             -- bug 6086385
             -- Processing the Subsequent Automatic Child plans
             -- Using the insert_history_auto_rec_QWB instead of
             -- insert_history_auto_rec to make sure that the Txn_header_id
             -- is not incremented
             -- ntungare Thu Jul  5 05:15:29 PDT 2007
             --
             insert_history_auto_rec_QWB(p_plan_id           => l_child_plan_id,
                                         p_collection_id     => p_collection_id,
                                         p_occurrence        => l_child_occurrence,
                                         p_organization_id   => p_org_id,
                                         p_txn_header_id     => p_txn_header_id,
                                         p_relationship_type => 1,
                                         p_data_entry_mode   => 2 ,
                                         x_status            => auto_hist_proc_stat);

             --
             -- bug 6086385
             -- Processing the History Child plans
             -- Using the insert_history_auto_rec_QWB instead of
             -- insert_history_auto_rec to make sure that the Txn_header_id
             -- is not incremented
             -- ntungare Thu Jul  5 05:15:29 PDT 2007
             --
             insert_history_auto_rec_QWB(p_plan_id           => l_child_plan_id,
                                         p_collection_id     => p_collection_id,
                                         p_occurrence        => l_child_occurrence,
                                         p_organization_id   => p_org_id,
                                         p_txn_header_id     => p_txn_header_id,
                                         p_relationship_type => 1,
                                         p_data_entry_mode   => 4 ,
                                         x_status            => auto_hist_proc_stat);

         END LOOP; --for number of rows

 /* Bug 3223081 : Added the following statement to reset the l_count to 1 after all the rows are inserted for one child plan
                        l_count :=1;
    - akbhatia
 */
           l_count :=1;
        -- i := i + 1;
     END LOOP; --outer for loop for child plans
     x_status := 'T';
 END;




FUNCTION descendants_exist(p_plan_id NUMBER,
                           p_collection_id NUMBER,
                           p_occurrence NUMBER)
         RETURN VARCHAR2 IS
---
--- This function takes in plan_id, collection_id and occurrence and returns a 'T'
--- if it finds any child record for this record. Otherwise it returns 'F'.
---

--l_exists INTEGER;
  l_exists VARCHAR2(1);

    CURSOR descendant_cur IS
           SELECT  'T'
           FROM  qa_pc_results_relationship
           WHERE parent_occurrence = p_occurrence
           AND   rownum = 1;


 BEGIN
    l_exists := 'F';
    OPEN descendant_cur;
    FETCH descendant_cur INTO l_exists;
    IF (descendant_cur%NOTFOUND) THEN
       l_exists := 'F';
    END IF;

    CLOSE descendant_cur;
    RETURN l_exists;

 END;

FUNCTION get_disabled_descendants(p_plan_id NUMBER,
                             p_collection_id NUMBER,
                             p_occurrence NUMBER,
                             --p_enabled    NUMBER,
                             x_plan_ids OUT NOCOPY dbms_sql.number_table,
                             x_collection_ids OUT NOCOPY dbms_sql.number_table,
                             x_occurrences OUT NOCOPY dbms_sql.number_table)
         RETURN VARCHAR2 IS
---
--- This function is similar to get_descendants above with one difference
--- it looks for all disabled records .
---

 BEGIN

  BEGIN
    SELECT     child_plan_id, child_collection_id, child_occurrence
    BULK COLLECT INTO
           x_plan_ids, x_collection_ids, x_occurrences
    FROM       qa_pc_results_relationship r
    WHERE EXISTS (
               SELECT 1
               FROM  qa_results qr
               WHERE qr.plan_id = r.child_plan_id AND
                     qr.collection_id = r.child_collection_id AND
                     qr.occurrence = r.child_occurrence AND
                    qr.status = 1 )
    START WITH parent_plan_id = p_plan_id AND
           parent_collection_id = p_collection_id AND
           parent_occurrence = p_occurrence
    CONNECT BY PRIOR child_occurrence = parent_occurrence;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN 'F';
  END;

  IF SQL%FOUND THEN
     RETURN 'T';
  ELSE
     RETURN 'F';
  END IF;

 END;

PROCEDURE delete_child_rows(p_plan_ids IN dbms_sql.number_table,
                            p_collection_ids IN dbms_sql.number_table,
                            p_occurrences IN dbms_sql.number_table,
                            p_parent_plan_id       NUMBER ,
                            p_parent_collection_id NUMBER ,
                            p_parent_occurrence    NUMBER ,
                            p_enabled_flag         VARCHAR2)

          IS
---
--- The following procedure takes in plan_id, collection id and occurrece and
--- deletes these rows from QA_RESULTS. It also deletes entry for these rows
--- from relationships tables.
---
--- p_enabled_flag holds    'T'  => delete only enabled child records
---                         'F'  => delete only disabled child records

  i INTEGER ;

 BEGIN

    i := 0;

    -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
    -- Call the sequence api to capture audit information for the child/grand
    -- child record records. Audit info. for toplevel parent is not
    -- collected here.

    -- capture audit only when enabled child records (status NULL or 2)
    -- are deleted
    IF p_enabled_flag = 'T' THEN

       QA_SEQUENCE_API.audit_sequence_values(
                                p_plan_ids,
                                p_collection_ids,
                                p_occurrences,
                                p_parent_plan_id,
                                p_parent_collection_id,
                                p_parent_occurrence);
    END IF;

    FORALL i IN p_occurrences.FIRST .. p_occurrences.LAST
       DELETE from QA_RESULTS
       WHERE  plan_id       = p_plan_ids(i)
       AND    collection_id = p_collection_ids(i)
       AND    occurrence    = p_occurrences(i);

   FORALL i IN p_occurrences.FIRST .. p_occurrences.LAST
       DELETE from QA_PC_RESULTS_RELATIONSHIP
       WHERE  child_occurrence =  p_occurrences(i);
 END delete_child_rows;


 PROCEDURE enable_fire_for_txn_hdr_id(p_txn_header_id IN NUMBER) IS
 flag BOOLEAN ;

 BEGIN

     IF p_txn_header_id is not null THEN
        UPDATE qa_results
        SET status = 2
        WHERE txn_header_id = p_txn_header_id;

        flag := QLTDACTB.DO_ACTIONS(p_txn_header_id,  1, NULL,  NULL,
                                    FALSE , FALSE, 'DEFERRED' , 'TXN_HEADER_ID');
     END IF;
 END;

 --
 -- bug 5682448
 -- New proc to enable the records and fire
 -- the actions for all those enabled records
 -- ntungare Wed Feb 21 07:34:11 PST 2007
 --
 PROCEDURE enable_fire_for_coll_id(p_txn_header_id IN NUMBER) IS
    flag BOOLEAN ;

    Type num_tab_typ is table of number index by binary_integer;

    plan_id_tab        num_tab_typ;
    collection_id_tab  num_tab_typ;
    occurrence_tab     num_tab_typ;

 BEGIN
     IF p_txn_header_id is not null THEN

        -- Updating the rows in the QA_RESULTS which are currently
        -- invalid
        --
        UPDATE qa_results
        SET status = 2
        WHERE txn_header_id = p_txn_header_id
          and status =1
        RETURNING plan_id, collection_id, occurrence
          BULK COLLECT INTO plan_id_tab, collection_id_tab, occurrence_tab;

        -- Looping through all the updated records and firing
        -- actions for them
        --
        For Cntr in 1..plan_id_tab.COUNT
             LOOP
                -- Calling the do_actions for the plan_id, collection_id,
                -- Occurrence combination
                --
                flag := QLTDACTB.DO_ACTIONS
                          (X_TXN_HEADER_ID         => collection_id_tab(cntr),
                           X_CONCURRENT            => 1,
                           X_PO_TXN_PROCESSOR_MODE => NULL,
                           X_GROUP_ID              => NULL,
                           X_BACKGROUND            => FALSE ,
                           X_DEBUG                 => FALSE,
                           X_ACTION_TYPE           => 'DEFERRED' ,
                           X_PASSED_ID_NAME        => 'COLLECTION_ID',
                           P_OCCURRENCE            => occurrence_tab(cntr),
                           P_PLAN_ID               => plan_id_tab(cntr));
             END LOOP;
     END IF; --p_txn_header_id is not null
 END enable_fire_for_coll_id;


 -- Bug 4270911. CU2 SQL Literal fix. TD #18
 -- Uses FND_DSQL package for the case of unknown number of binds.
 -- srhariha. Fri Apr 15 06:40:15 PDT 2005.

FUNCTION find_parent(p_child_plan_id IN NUMBER,
                     p_child_collection_id IN NUMBER,
                     p_child_occurrence IN NUMBER,
                     x_parent_plan_id OUT NOCOPY NUMBER,
                     x_parent_collection_id OUT NOCOPY NUMBER,
                     x_parent_occurrence OUT NOCOPY NUMBER)
                     RETURN VARCHAR2 IS

--
-- This function intelligently finding out parent plan record when child plan record information
-- is passed. First find out parent_plan_id from qa_pc_plan_relationship. Then findout all
-- element ids with which parent and child plans are related. Take only those elements which have
-- link_flag = 1 in qa_pc_element_relationship table.

-- Find the values of the elements from qa_results for the child plan.  Then find the first record
-- for the parent plan which has all the elements (only those related in the qa_pc_element_relation)
-- same value for those of child plan. Return the parent record information.

 l_plan_relationship_id NUMBER;
 l_parent_plan_id       NUMBER;
 l_temp_var             NUMBER;
 l_res_col              VARCHAR2(150);                 -- stores result column name in qa_results
 l_res_value            VARCHAR2(150);                 -- stores result column value in qa_results

 query_clause VARCHAR2(32000):= NULL;
 select_clause VARCHAR2(80)  := NULL;
 from_clause CONSTANT VARCHAR2(80)    := ' FROM QA_RESULTS ';
 where_clause VARCHAR2(5000) := NULL;
 parent_where_clause VARCHAR2(5000):= NULL;


 Type resCurTyp IS REF CURSOR; --define weak REF CURSOR type
 res_cur resCurTyp; --define cursor variable

 CURSOR plan_cursor(p_child_plan_id NUMBER) IS
   SELECT plan_relationship_id,parent_plan_id
   FROM   qa_pc_plan_relationship
   WHERE  child_plan_id = p_child_plan_id
   AND    rownum = 1;

-- Bug 2357067. Modified the element_cursor so that all parent,child columns
-- can be fetched once.

CURSOR element_cursor(p_relationship_id NUMBER) IS
select pe.parent_char_id,
       qpc1.result_column_name parent_database_column,
       pe.child_char_id,
       qpc2.result_column_name child_database_column
from
       qa_pc_plan_relationship pr,
       qa_pc_element_relationship pe,
       qa_plan_chars qpc1,
       qa_plan_chars qpc2
where
       pr.plan_relationship_id = pe.plan_relationship_id and
       pr.parent_plan_id = qpc1.plan_id and
       pe.parent_char_id = qpc1.char_id and
       pr.child_plan_id = qpc2.plan_id and
       pe.child_char_id = qpc2.char_id and
       pe.plan_relationship_id = p_relationship_id and
       pe.element_relationship_type = 1 and
       pe.link_flag = 1;

-- Bug 4270911. CU2 SQL Literal fix.
-- New cursor handler.
cursor_handle NUMBER;
no_of_rows NUMBER;
BEGIN
   l_temp_var := -99;
   -- Bug 4270911. CU2 SQL Literal fix.
   -- Use bind variables.
   -- srhariha. Fri Apr 15 06:22:04 PDT 2005.

   where_clause := ' WHERE plan_id = :p_child_plan_id' ||
                   ' AND collection_id = :p_child_collection_id' ||
                   ' AND occurrence = :p_child_occurrence';

   -- get the parent_plan_id for the child plan
   OPEN plan_cursor(p_child_plan_id);
   FETCH plan_cursor INTO l_plan_relationship_id,l_parent_plan_id;
   IF (plan_cursor%NOTFOUND) THEN
      CLOSE plan_cursor;
      RETURN 'F';
   END IF;

   CLOSE plan_cursor;

  -- Bug 4270911. CU2 SQL Literal fix.
   -- Use fnd_dsql package.
   -- srhariha. Fri Apr 15 06:22:04 PDT 2005.

  select_clause := ' SELECT 1, plan_id, collection_id, occurrence ';
  fnd_dsql.init;
  fnd_dsql.add_text(select_clause || from_clause || ' ');
  fnd_dsql.add_text(' WHERE plan_id =');
  fnd_dsql.add_bind(l_parent_plan_id);
  fnd_dsql.add_text(' ');

   --  parent_where_clause := ' WHERE plan_id = ' || parent_plan_id ;

   -- get all the child plan elements which has relationship
   -- and link_flag = 1. This flag is specifically used for flow workstation integration.

   FOR ele_rec IN element_cursor(l_plan_relationship_id) LOOP

      select_clause := ' SELECT ' ||  ele_rec.child_database_column;
      query_clause := select_clause || from_clause || where_clause;

     -- Bug 4270911. CU2 SQL Literal fix.
     -- Use bind variables.
     -- srhariha. Fri Apr 15 06:22:04 PDT 2005.


      OPEN res_cur FOR query_clause USING p_child_plan_id, p_child_collection_id, p_child_occurrence;
      FETCH res_cur INTO l_res_value;
      CLOSE res_cur;

      -- If the copy element in child record is null, then build the query accordingly

      IF l_res_value IS NULL THEN
        --parent_where_clause := parent_where_clause || ' AND ' ||
        --                     ele_rec.parent_database_column || ' IS NULL';
        fnd_dsql.add_text(' AND ' || ele_rec.parent_database_column || ' IS NULL ');
      ELSE
/* rkaza 06/04/2002. Bug 2302554. Enclosing l_res_value with single quotes. */
--        parent_where_clause := parent_where_clause || ' AND ' ||
--                               ele_rec.parent_database_column || ' = ' || '''' || qa_core_pkg.dequote(l_res_value) || '''';

        fnd_dsql.add_text(' AND ' || ele_rec.parent_database_column || ' = ');
        fnd_dsql.add_bind(l_res_value);
        fnd_dsql.add_text(' ');
      END IF;

   END LOOP;

   --Necessary to say rownum=1 to avoid multiple rows
--   parent_where_clause := parent_where_clause || ' AND ROWNUM = 1 ';
   fnd_dsql.add_text(' AND ROWNUM = 1 ');

--   query_clause := select_clause || from_clause || parent_where_clause;

--   OPEN res_cur FOR query_clause USING l_parent_plan_id;
--   FETCH res_cur INTO l_temp_var, x_parent_plan_id,
--                      x_parent_collection_id, x_parent_occurrence;
--   CLOSE res_cur;


    cursor_handle := dbms_sql.open_cursor;
    fnd_dsql.set_cursor(cursor_handle);

    query_clause := fnd_dsql.get_text;
    dbms_sql.parse(cursor_handle,query_clause,dbms_sql.NATIVE);
    fnd_dsql.do_binds;

    dbms_sql.define_column(cursor_handle,1,l_temp_var);
    dbms_sql.define_column(cursor_handle,2,x_parent_plan_id);
    dbms_sql.define_column(cursor_handle,3,x_parent_collection_id);
    dbms_sql.define_column(cursor_handle,4,x_parent_occurrence);

    no_of_rows := dbms_sql.execute(cursor_handle);

    no_of_rows := dbms_sql.fetch_rows(cursor_handle);

    l_temp_var := 0;
    IF (no_of_rows > 0) THEN
       dbms_sql.column_value(cursor_handle,1,l_temp_var);
       dbms_sql.column_value(cursor_handle,2,x_parent_plan_id);
       dbms_sql.column_value(cursor_handle,3,x_parent_collection_id);
       dbms_sql.column_value(cursor_handle,4,x_parent_occurrence);


    END IF;

   dbms_sql.close_cursor(cursor_handle);

   IF (l_temp_var = 1) THEN
        RETURN 'T';
   ELSE
        RETURN 'F';
   END IF;

END find_parent;

 -- 12. QWB Usability Improvements
 -- added 2 new prameters to return a comma separated list
 -- of Parent plan elements for which the aggregation is done
 -- and the list of the aggregated values
 --
 --
 -- bug 7046071
 -- Added the parameter p_ssqr_operation parameter to check if the
 -- call is done from the OAF application or from Forms
 -- In case of the OAF application, the COMMIT that is
 -- executed in the aggregate_parent must not be called
 -- ntungare
 --
 PROCEDURE relate(p_parent_plan_id IN NUMBER,
                  p_parent_collection_id IN NUMBER,
                  p_parent_occurrence IN NUMBER,
                  p_child_plan_id IN NUMBER,
                  p_child_collection_id IN NUMBER,
                  p_child_occurrence IN NUMBER,
                  p_child_txn_header_id IN NUMBER,
                  x_agg_elements OUT NOCOPY VARCHAR2,
                  x_agg_val OUT NOCOPY VARCHAR2,
                  p_ssqr_operation IN NUMBER DEFAULT NULL) IS

 l_date     DATE;
 l_user_id  NUMBER;
 l_login_id NUMBER;
 l_rowid    VARCHAR2(18) := null;

 l_ret_value VARCHAR2(1);
 -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
 -- Added following cursor.

 l_child_txn_header_id NUMBER;

 CURSOR c IS
   SELECT txn_header_id FROM qa_results
   WHERE  plan_id       = p_child_plan_id AND
          collection_id = p_child_collection_id AND
          occurrence    = p_child_occurrence;

   -- 12.1 QWB Usability Improvements
   --
   agg_elements VARCHAR2(4000);
   agg_val      VARCHAR2(4000);
 BEGIN

   --anagarwa Fri Jun 11 15:08:03 PDT 2004
   -- bug 3678910
   -- If parent or child key is invalid then no need to create a relationship
   IF  p_parent_occurrence < 0 OR  p_parent_collection_id < 0 OR
       p_parent_plan_id < 0 OR  p_child_plan_id < 0 OR
       p_child_collection_id < 0 OR  p_child_occurrence < 0  THEN

      RETURN;
   END IF;

   l_user_id  := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   l_date := sysdate;

   -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
   -- Findout txn header ID for the child record

   IF p_child_txn_header_id IS NULL THEN
      OPEN c;
      FETCH c INTO l_child_txn_header_id;
      CLOSE c;
   ELSE
      l_child_txn_header_id := p_child_txn_header_id;
   END IF;

 -- Gapless Sequence Proj passing child_txn_header_id
 QA_PC_RESULTS_REL_PKG.Insert_Row(
      X_Rowid                   => l_rowid,
      X_Parent_Plan_Id          => p_parent_plan_id,
      X_Parent_Collection_Id    => p_parent_collection_id,
      X_Parent_Occurrence       => p_parent_occurrence,
      X_Child_Plan_Id           => p_child_plan_id,
      X_Child_Collection_Id     => p_child_collection_id,
      X_Child_Occurrence        => p_child_occurrence,
      X_Enabled_Flag            => 1,
      X_Last_Update_Date        => l_date,
      X_Last_Updated_By         => l_user_id,
      X_Creation_Date           => l_date,
      X_Created_By              => l_user_id,
      X_Last_Update_Login       => l_login_id,
      X_Child_Txn_Header_Id     => l_child_txn_header_id);

 -- Bug 2302554
 -- once the parent and child are related, parent record
 -- should be updated with child element values(if any aggregate
 -- relationship defined) and child record should be updated
 -- with parent plan values (if copy relation defined with
 -- link_flag = 2)
 -- 12.1 QWB Usabiltity improvements
 -- added 2 new parameters to get the parent element which
 -- is to have the aggregated value and to get the aggregated
 -- value
 --
 --
 -- bug 7046071
 -- Passing the parameter p_ssqr_operation parameter to check if the
 -- call is done from the OAF application or from Forms
 -- In case of the OAF application, the COMMIT that is
 -- executed in the aggregate_parent must not be called
 -- ntungare
 --
 l_ret_value := QA_PARENT_CHILD_PKG.update_parent(p_parent_plan_id ,
                  p_parent_collection_id ,
                  p_parent_occurrence,
                  p_child_plan_id,
                  p_child_collection_id ,
                  p_child_occurrence,
                  agg_elements,
                  agg_val,
                  p_ssqr_operation);

 -- 12.1 QWB Usability Improvements
 --
 x_agg_elements := agg_elements;
 x_agg_val      := agg_val;

 --
 -- bug 7588376
 -- Starting with a fresh copy of the collection
 -- that stores the values of the relactionship elements
 -- in the parent plan
 --
 parent_plan_vales_tab.delete;
 l_ret_value:= QA_PARENT_CHILD_PKG.update_child(p_parent_plan_id ,
                  p_parent_collection_id ,
                  p_parent_occurrence,
                  p_child_plan_id,
                  p_child_collection_id ,
                  p_child_occurrence );
 --
 -- bug 7588376
 -- resetting the collection
 --
 parent_plan_vales_tab.delete;

END relate;

FUNCTION get_plan_name(p_plan_ids IN VARCHAR2 , x_plan_name OUT NOCOPY VARCHAR2) return VARCHAR2 IS

-- This functions returns the name of the plan when plan_id is passed.
-- This can take the plan_id in the comma separated string like '501,502,503'
-- and returns all the plan_name in the comma separated string.

-- This function is useful when we need to display the message to user about the
-- childplan name or parent plan name.

  l_child_id_array       ChildPlanArray;
  l_total_length NUMBER;
  l_plan_name VARCHAR2(10000) := NULL;
  l_name      VARCHAR2(30);
  l_plan_id   NUMBER;
  l_str_from  NUMBER := 1;
  l_str_to    NUMBER;
  l_separator CONSTANT VARCHAR2(1) := ',';

  CURSOR plan_cursor(c_plan_id NUMBER) IS
    SELECT name
    FROM qa_plans
    WHERE plan_id = c_plan_id;

 BEGIN
  l_total_length := LENGTH(p_plan_ids);

   -- We need check for all the child_plan_ids one by one or parent_plan_id to
   -- to get plan name

  -- anagarwa Mon Apr 15 15:51:58 PDT 2002
  -- Bug 2320896 was being caused due to error in logic.
  -- This code is being replaced to avoid character to number conversion

/*

   LOOP
        l_str_to := instr(p_plan_ids,l_separator,l_str_from);
        IF (l_str_to = 0) THEN
            -- we are here if only one plan id is passed or we are in the
            -- last child plan id

            l_plan_id := to_number(substr(p_plan_ids,  l_str_from, l_total_length));
        ELSE
            l_plan_id := to_number(substr(p_plan_ids, l_str_from, l_str_to -1 ));

            -- Adding +1 with the l_str_to to make l_str_from variable pointing to first
            -- character after the comma separator

            l_str_from := l_str_to +1;
        END IF;

       OPEN plan_cursor;
       FETCH plan_cursor INTO l_name;
       IF (plan_cursor%NOTFOUND) THEN
          CLOSE plan_cursor;
          RETURN 'F';
       END IF;

       IF l_plan_name IS NULL THEN
           l_plan_name := l_name;
       ELSE
           l_plan_name := l_plan_name || l_separator || l_name;
       END IF;
       CLOSE plan_cursor;

       IF (l_str_to = 0 ) THEN
           -- We parsed all the child plan ids.
           EXIT;
       END IF;
   END LOOP;
*/

   parse_list(p_plan_ids, l_child_id_array);

   FOR i IN 1..l_child_id_array.COUNT LOOP
      l_plan_id := l_child_id_array(i);
      OPEN plan_cursor(l_plan_id);
      FETCH plan_cursor INTO l_name;
      IF (plan_cursor%NOTFOUND) THEN
         CLOSE plan_cursor;
         RETURN 'F';
      END IF;

      IF l_plan_name IS NULL THEN
          l_plan_name := l_name;
      ELSE
          l_plan_name := l_plan_name || l_separator || l_name;
      END IF;
      CLOSE plan_cursor;

   END LOOP;
   x_plan_name := l_plan_name;

   RETURN 'T';
 END get_plan_name;

 FUNCTION should_parent_spec_be_copied(p_parent_plan_id NUMBER, p_child_plan_id NUMBER)
        RETURN VARCHAR2 IS

  -- This function returns true if parent plan specification_id can be copied to child
  -- else return false.

  l_default_parent NUMBER := -99;

  CURSOR default_cursor IS
        SELECT default_parent_spec
        FROM   qa_pc_plan_relationship
        WHERE  parent_plan_id = p_parent_plan_id
        AND    child_plan_id = p_child_plan_id;


 BEGIN

    -- As of now just return true. To implement this function we should have a new field
    -- default_parent_spec column in table qa_pc_plan_relationship.
    -- Hence i am commenting out the actual implementation of this function.

 --   RETURN 'T';

    OPEN default_cursor;
    FETCH default_cursor INTO l_default_parent;
    IF (default_cursor%NOTFOUND) THEN
      l_default_parent := -99;
    END IF;
    CLOSE default_cursor;
    IF l_default_parent = 1 THEN
        RETURN 'T';
    ELSE
        RETURN 'F';
    END IF;

 END should_parent_spec_be_copied;

 FUNCTION is_parent_child_plan(p_plan_id NUMBER) RETURN VARCHAR2 IS
 -- this functions return 'T' if the plan is parent-child relationship
 -- plan. ie pc relationship is defined for this plan.

 l_is_parent_plan VARCHAR2(1);

 CURSOR plan_cursor(p_plan_id NUMBER) IS
   SELECT 'T'
   FROM   qa_pc_plan_relationship
   WHERE  parent_plan_id = p_plan_id
   OR     child_plan_id = p_plan_id
   AND    rownum = 1;
 BEGIN
    l_is_parent_plan := 'F';
    OPEN plan_cursor(p_plan_id);
    FETCH plan_cursor INTO l_is_parent_plan;
    IF( plan_cursor%NOTFOUND) THEN
        l_is_parent_plan := 'F';
    END IF;
    CLOSE plan_cursor;
    RETURN l_is_parent_plan;
 END is_parent_child_plan;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- Added p_commit parameter to the existing update_parent function
  -- and renamed it as aggregate_parent since we do not want
  -- the explicit commit for OAF Txn Delete Flows
  -- shkalyan 05/13/2005.
 --
 -- 12.1 QWB Usability Improvements
 -- added 2 new parameters to get the list of the
 -- aggregated elements and the aggregated values.
 --
 FUNCTION aggregate_parent(p_parent_plan_id IN NUMBER,
                           p_parent_collection_id IN NUMBER,
                           p_parent_occurrence IN NUMBER,
                           p_child_plan_id IN NUMBER,
                           p_child_collection_id IN NUMBER,
                           p_child_occurrence IN NUMBER,
                           p_commit IN VARCHAR2,
                           x_agg_elements OUT NOCOPY VARCHAR2,
                           x_agg_val OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2 IS

 l_sql_string VARCHAR2(32000);
 l_update_parent_sql VARCHAR2(32000);
 l_value NUMBER;

 --
 -- Bug 6450756
 -- Declaration of variables needed for
 -- locking the row that needs to be
 -- updated with the aggregating values.
 -- bhsankar  Sun Sep 30 23:38:58 PDT 2007
 --
 l_parent_db_col  VARCHAR2(30);
 l_select_sql     VARCHAR2(32000);

 -- anagarwa Mon Dec 16 16:55:09 PST 2002
 -- Bug 2701777
 -- added parent_enabled_flag and child_enabled_flag to where clause
 -- to limit working on onlly those elements that are enabled.
 CURSOR element_cursor IS
    SELECT parent_database_column,
           child_database_column,
           element_relationship_type,
           parent_char_id
    FROM   qa_pc_result_columns_v
    WHERE  parent_plan_id = p_parent_plan_id
    AND    child_plan_id = p_child_plan_id
    AND    element_relationship_type in (2,3,4,5,6,7,8)
    AND    parent_enabled_flag = 1
    AND    child_enabled_flag = 1;

 --
 -- Bug 6450756
 -- User Defined exception for handling row locks
 -- in scenarios U->V->U or U->V->E
 -- where aggegating into top most parent will
 -- result in a lock.
 -- bhsankar  Sun Sep 30 23:38:58 PDT 2007
 --
 ROW_LOCK_FAILED EXCEPTION;
 PRAGMA EXCEPTION_INIT(ROW_LOCK_FAILED, -54);


 BEGIN

  FOR cur_rec IN element_cursor LOOP

      -- build the required sql string

      l_sql_string := 'FROM qa_results qr, qa_pc_results_relationship pc'
                    || ' WHERE qr.plan_id=pc.child_plan_id'
                    || ' AND qr.collection_id=pc.child_collection_id'
                    || ' AND qr.occurrence=pc.child_occurrence'
                    || ' AND pc.parent_occurrence= :p_parent_occurrence'
                    || ' AND pc.child_plan_id= :p_child_plan_id'
                    --
                    -- bug 5682448
                    -- Added the extra condititon to aggregate only the
                    -- enabled records in stauts 2 or NULL
                    -- ntungare Wed Feb 21 07:38:04 PST 2007
                    --
                    || ' AND (qr.status = 2 OR qr.status IS NULL)';

      -- Bug 2427337. Fix here is not related this bug. To use aggregate functions
      -- on a element which is stored in character col in qa_results table, we need
      -- to use to_number function, or else, unwanted value will be returned.
      -- rponnusa Tue Jun 25 06:15:48 PDT 2002

      IF (cur_rec.element_relationship_type = 2  ) THEN  -- sum
         l_sql_string := 'SELECT SUM(to_number(qr.'||cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 3 ) THEN  -- average or Mean
         l_sql_string := 'SELECT AVG(to_number(qr.'||cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 4 ) THEN -- std. deviation
         l_sql_string := 'SELECT STDDEV(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;

      ELSIF (cur_rec.element_relationship_type = 5 ) THEN -- min
         l_sql_string := 'SELECT MIN(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 6 ) THEN -- max
         l_sql_string := 'SELECT MAX(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 7 ) THEN -- variance
         l_sql_string := 'SELECT VARIANCE(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 8 ) THEN -- count
         -- anagarwa  Tue Feb 18 11:13:20 PST 2003
         -- Bug 2789847
         -- Count may be done on non numeric elements like Sequence Numbers and
         -- even Nonconformance Status, Source etc.
         -- A to_number will cause an exception in such a case and is hence
         -- removed from sql statement.
         l_sql_string := 'SELECT COUNT(qr.'|| cur_rec.child_database_column||') ' || l_sql_string;
      END IF;
      -- find out the aggregate value for the element in child plan.
      BEGIN
         EXECUTE IMMEDIATE l_sql_string INTO l_value
                 USING p_parent_occurrence,p_child_plan_id;
      EXCEPTION
        WHEN OTHERS THEN raise;

      END;

      -- Bug 2716973
      -- When the child aggregate relationship element value is updated to parent record,
      -- Post-Forms-Commit Trigger error raised if child element contain null value.
      -- rponnusa Sun Jan 12 23:59:07 PST 2003

      l_value := NVL(l_value,0);

      -- See 2624112
      -- The maximum allowed precision is now expanded to 12.
      -- Rounding to 12...
      -- rkunchal Thu Oct 17 22:51:45 PDT 2002

      -- rounding off to 6 digits is required since, for a number field, the maximum allowd
      -- decimal places is 6.

      -- l_value := round(l_value,6);
      l_value := round(l_value,12);
      --
      -- Bug 6450756
      -- Lock the row in the parent so that the
      -- values can be aggregated from the child
      -- If the row is not getting locked, then
      -- it might be because of the following flow
      -- U->V->U or U->V->E. Catch the exception and
      -- dont take any action since the aggregations
      -- would anyway fire at the parent level.
      -- bhsankar  Sun Sep 30 23:38:58 PDT 2007
      --
      l_select_sql := 'SELECT '
                      || cur_rec.parent_database_column
                      || ' FROM qa_results WHERE  plan_id = :p_parent_plan_id'
                      || ' AND collection_id= :p_parent_collection_id'
                      || ' AND occurrence= :p_parent_occurrence FOR UPDATE NOWAIT';

      BEGIN
         EXECUTE IMMEDIATE l_select_sql INTO l_parent_db_col
                 USING p_parent_plan_id,p_parent_collection_id,p_parent_occurrence;

         -- now we need to update the parent record. Build the sql here.

         l_update_parent_sql := 'UPDATE qa_results  SET '
                            || cur_rec.parent_database_column || ' = :l_value'
                            || ' WHERE plan_id= :p_parent_plan_id'
                            || ' AND collection_id= :p_parent_collection_id'
                            || ' AND occurrence= :p_parent_occurrence';
              BEGIN
                 EXECUTE IMMEDIATE l_update_parent_sql
                         USING l_value,p_parent_plan_id,p_parent_collection_id,p_parent_occurrence;

                -- 12.1 QWB Usability improvements
                -- Building a list of the Aggregated parent plan elements
                --
                x_agg_elements := x_agg_elements ||','||
                                  qa_ak_mapping_api.get_vo_attribute_name(cur_rec.parent_char_id, p_parent_plan_id);
                -- 12.1 QWB Usability improvements
                -- Building a list of the Aggregated values
                --
                x_agg_val := x_agg_val ||','|| l_value;

              EXCEPTION
                WHEN OTHERS THEN raise;
              END;

      EXCEPTION
         WHEN ROW_LOCK_FAILED THEN NULL;
         WHEN OTHERS THEN RAISE;
      END;

  END LOOP;
  -- we are returning true when the parent record is updated or
  -- there is no aggregate relationship defined for the parent,child plans.

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- Added check based on p_commit parameter since we do not want to commit
  -- by default if invoked from OAF Pages.
  -- shkalyan 05/13/2005.
  IF ( p_commit = 'T' ) THEN
    -- Bug 2300962. Needs explicit commit, if called from post-database-commit trigger
    COMMIT;
  END IF;

  RETURN 'T';

 END aggregate_parent;

 FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

   -- 12.1 QWB Usability Improvements
   agg_elements VARCHAR2(4000);
   agg_val      VARCHAR2(4000);
BEGIN
   -- 12.1 QWB Usability Improvements
   return update_parent(p_parent_plan_id,
                       p_parent_collection_id,
                       p_parent_occurrence,
                       p_child_plan_id,
                       p_child_collection_id,
                       p_child_occurrence,
                       agg_elements,
                       agg_val);
END;

 -- 12.1 QWB Usability Improvements
 -- Overloaded method that has 2 additional parameters
 -- that return a list of Aggregated elements and
 -- their values
 --
 -- bug 7046071
 -- Passing the parameter p_ssqr_operation parameter to check if the
 -- call is done from the OAF application or from Forms
 -- In case of the OAF application, the COMMIT that is
 -- executed in the aggregate_parent must not be called
 -- ntungare
 --
 FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER,
                       x_agg_elements OUT NOCOPY VARCHAR2,
                       x_agg_val OUT NOCOPY VARCHAR2,
		       p_ssqr_operation IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2 IS
   l_return_status VARCHAR2(1);

   agg_elements VARCHAR2(4000);
   agg_val      VARCHAR2(4000);

   -- bug 7046071
   l_commit     VARCHAR2(1) := 'T';
 BEGIN
  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- Moved the entire code to aggregate_parent function because
  -- this function was committing by default. Since we do not want
  -- the explicit commit for OAF Txn Delete Flows we have introduced this
  -- new procedure which accepts the commit flag as input.

   --
   -- bug 7046071
   -- If this processing is initiated from the OAF application
   -- either standalone or through OAF txn then the commit must
   -- not be done since this would taken care by the framework
   -- so setting the commit flag as 'F'
   -- ntungare
   --
   IF (p_ssqr_operation IN (1,2)) THEN
        l_commit := 'F';
   END IF;

   -- 12.1 QWB Usabitlity Improvements.
   -- Passing parameters for the aggregated elements
   --
   -- bug 7046071
   -- Passing the derived value for the commit flag
   -- ntungare
   --
   l_return_status :=
   aggregate_parent
   (
        p_parent_plan_id       => p_parent_plan_id,
        p_parent_collection_id => p_parent_collection_id,
        p_parent_occurrence    => p_parent_occurrence,
        p_child_plan_id        => p_child_plan_id,
        p_child_collection_id  => p_child_collection_id,
        p_child_occurrence     => p_child_occurrence,
        p_commit               => l_commit,
        x_agg_elements         => agg_elements,
        x_agg_val              => agg_val
   );

   x_agg_elements := agg_elements;
   x_agg_val      := agg_val;

   -- Bug 4343758. OA Framework Integration project.
   -- Function should return the status back to caller.
   -- srhariha. Tue May 24 22:56:13 PDT 2005.
   RETURN l_return_status;
 END update_parent;

 --
 -- bug 6266439
 -- New procedure to peform the date conversions while
 -- selecting and updating the data in the QA_RESULTS
 -- table, while peforming a Child record update.
 -- ntungare Thu Aug  2 03:32:32 PDT 2007
 --
 PROCEDURE DATE_SELECT_UPDATE(p_parent_result_column  IN     VARCHAR2,
                              p_child_result_column   IN     VARCHAR2,
                              p_parent_plan_id        IN     NUMBER,
                              p_child_plan_id         IN     NUMBER,
                              p_var                   IN     NUMBER,
                              p_select_column     OUT NOCOPY VARCHAR2,
                              p_update_column     OUT NOCOPY VARCHAR2)
      IS

   -- Cursor to check if the resultcolumn is
   -- of the DateTime/Date type and whether its a Hardcoded
   -- element
   -- Bug 8546279.Changed cursor query to inclide date type elements too
   -- collecting datatype too for datatype 3,date and 6,datetime.pdube
   Cursor cur (p_plan_id in NUMBER, p_res_col in VARCHAR2) is
     Select 1, qc.hardcoded_column, qc.datatype
       from qa_plan_chars qpc, qa_chars qc
     where qpc.plan_id = p_plan_id
       and qpc.char_id = qc.char_id
       and qpc.result_column_name = p_res_col
       and qc.datatype in (3,6);

   data_found       PLS_INTEGER := 0;
   hardcoded_column QA_CHARS.HARDCODED_COLUMN%TYPE := NULL;
   -- Bug 8546279 FP of 8446050.Added variables.pdube
   datatype         NUMBER;
   child_is_datetime       BOOLEAN := FALSE;
   datetimetype            CONSTANT NUMBER := 6;
   datetype                CONSTANT NUMBER := 3;

   parent_is_date          BOOLEAN := FALSE;
   child_is_date           BOOLEAN := FALSE;
   parent_hardcoded_column BOOLEAN := FALSE;
   child_hardcoded_column  BOOLEAN := FALSE;
 BEGIN
   -- Checking if the Parent element is a date element
   Open cur (p_parent_plan_id, p_parent_result_column);
   -- Bug 8546279.FP 8446050.fetching the datatype too.pdube
   -- Fetch cur into data_found, hardcoded_column;
   fetch cur into data_found, hardcoded_column, datatype;
   Close cur;

   If data_found =1 Then
     parent_is_date := TRUE;
     data_found :=0;
     -- Bug 8546279.FP for pdube
     datatype   := NULL;

     -- Checking if the Parent element is a HC date
     If hardcoded_column IS NOT NULL THEN
       parent_hardcoded_column := TRUE;
       hardcoded_column := NULL;
     END If;
   End If;

   -- This processing is to be performed only if the
   -- elements are dates. If the parent element is not a date
   -- then the child element too won't be of the date type since
   -- relationship with any other datatype cannot be established
   -- in which case, the processing can be terminated.
   --
   If parent_is_date <> TRUE THEN
     RETURN;
   ELSE
     -- Checking if the Child element is a date element
     Open cur (p_child_plan_id, p_child_result_column);
     -- Bug 8546279.FP 8446050.fetching the datatype too.pdube
     -- fetch cur into data_found, hardcoded_column;
     fetch cur into data_found, hardcoded_column, datatype;
     Close cur;

     If data_found =1 Then
       -- Bug 8546279.FP for 8446050.Added this if else ladder to set
       -- the boolean variables for checking date/datetime elements.pdube
       -- child_is_date := TRUE;
       IF (datatype = datetimetype) THEN
           child_is_datetime := TRUE;
	   datatype          := NULL;
       ELSE
           child_is_date := TRUE;
	   datatype          := NULL;
       END IF;
       data_found :=0;
       -- Checking if the Child element is a HC date
       If hardcoded_column IS NOT NULL THEN
         child_hardcoded_column := TRUE;
         hardcoded_column := NULL;
       END If;
     End If;


     -- Bug 8546279.FP for 8446050.
     -- If the parent element is a HC date then we have to convert it to the
     -- Canonical format while selecting. If the Parent element is a SC date
     -- then since the data is fetched from the Deref view which anyways converts
     -- the character string to the date format, we have to get the dereferenced
     -- name of the element and then convert it to the canonical character format.
     -- For the target elements in the update clause, if the target element is HC
     -- date then we have to convert the data which is selected as string in the
     -- canonical format into a date. For SC target elements, since the data is
     -- already in the canonical format, we can update it directly.Made changes to
     -- handle the date and datetime elements.pdube
     If (parent_is_date) AND (parent_hardcoded_column) THEN
         --HC-> HC
         --  If (child_is_date) AND (child_hardcoded_column) THEN
         --    p_select_column := 'to_char('||p_parent_result_column||',''DD-MON-YYYY HH24:MI:SS'') ';
         --    p_update_column := 'to_date(:'||to_char(p_var)||',''DD-MON-YYYY HH24:MI:SS'') ';
         IF (child_is_datetime OR child_is_date) AND (child_hardcoded_column) THEN
             p_select_column := 'to_char('||p_parent_result_column||',''YYYY/MM/DD HH24:MI:SS'') ';
             p_update_column := 'to_date(:'||to_char(p_var)||',''YYYY/MM/DD HH24:MI:SS'') ';

         --HC-> SC datetime
         ELSIF (child_is_datetime) AND (child_hardcoded_column = FALSE) THEN
             p_select_column := 'to_char('||p_parent_result_column||',''YYYY/MM/DD HH24:MI:SS'') ';
             p_update_column := ':'||to_char(p_var);

         --HC-> SC date
         ELSIF (child_is_date) AND (child_hardcoded_column = FALSE) THEN
             -- p_select_column := 'QLTDATE.date_to_canon_dt('||p_parent_result_column||') ';
             p_select_column := 'to_char('||p_parent_result_column||',''YYYY/MM/DD'') ';
             p_update_column := ':'||to_char(p_var);
         END IF;
     ELSIF (parent_is_date) AND (parent_hardcoded_column = FALSE) THEN
         --SC-> HC
         -- If (child_is_date) AND (child_hardcoded_column) THEN
         --    p_select_column := p_parent_result_column;
         --    p_update_column := 'qltdate.canon_to_date(:'||to_char(p_var)||') ';
         If (child_is_datetime) AND (child_hardcoded_column) THEN
             get_deref_column(p_parent_result_column => p_parent_result_column,
                                    p_parent_plan_id       => p_parent_plan_id,
                                    x_select_column        => p_select_column);
             p_select_column := 'to_char('||p_select_column||',''YYYY/MM/DD HH24:MI:SS'') ';
             p_update_column := 'to_date(:'||to_char(p_var)||',''YYYY/MM/DD HH24:MI:SS'') ';

         --SC-> SC Date
         ELSIF (child_is_date) AND (child_hardcoded_column = FALSE) THEN
             -- p_select_column := p_parent_result_column;
             -- p_update_column := ':'||to_char(p_var);
             get_deref_column(p_parent_result_column => p_parent_result_column,
                                    p_parent_plan_id       => p_parent_plan_id,
                                    x_select_column        => p_select_column);
             p_select_column := 'to_char('||p_select_column||',''YYYY/MM/DD'') ';
             p_update_column := ':'||to_char(p_var);

	 --SC-> SC Date time
         ELSIF (child_is_datetime) AND (child_hardcoded_column = FALSE) THEN
             get_deref_column(p_parent_result_column => p_parent_result_column,
                                    p_parent_plan_id       => p_parent_plan_id,
                                    x_select_column        => p_select_column);
             p_select_column := 'to_char('||p_select_column||',''YYYY/MM/DD HH24:MI:SS'') ';
             p_update_column := ':'||to_char(p_var);
	 END If;
     END If;
     -- End of bug 8546279.FP for 8446050.pdube
   END If;
 END DATE_SELECT_UPDATE;

 --
 -- bug 7588376
 -- New procedure to select the dereferenced column for
 -- a hardcoded column, if its value is being copied to
 -- a softcoded element in the child plan.
 -- skolluku
 --
 PROCEDURE get_deref_column(p_parent_result_column IN     VARCHAR2,
                            p_parent_plan_id       IN     NUMBER,
                            x_select_column        OUT NOCOPY VARCHAR2)
      IS

   -- of a Hardcoded element and also to fetch its
   -- dereferenced column.
   Cursor cur (p_plan_id in NUMBER, p_res_col in VARCHAR2) is
     Select UPPER(TRANSLATE(qc.name,   ' ''*{}',   '_____')) name, qc.hardcoded_column
       from qa_plan_chars qpc, qa_chars qc
     where qpc.plan_id = p_plan_id
       and qpc.char_id = qc.char_id
       and qpc.result_column_name = p_res_col;

   parent_element_name       varchar2(2000):= NULL;
   hardcoded_column QA_CHARS.HARDCODED_COLUMN%TYPE := NULL;

 BEGIN
   -- init the select column to null.
   x_select_column := NULL;

   -- Checking if the Parent element is a hardcoded element
   Open cur (p_parent_plan_id, p_parent_result_column);
   fetch cur into parent_element_name, hardcoded_column;
   Close cur;

   -- Assign the dereferenced column to copy to SC child element.
   x_select_column := parent_element_name;
 END get_deref_column;

-- 5114865
-- Function to perform the Updation of the Child
-- Plan Columns those which have been identified
-- as having a Copy Relationship with the corresponding
-- Parent Plans
-- This section of code was earlier a part of
-- update_child Function and was extraced so that
-- it can be used in common by function
-- update_sequence_Child
-- nutngare Wed Mar  8 09:00:46 PST 2006
--
FUNCTION perform_child_update(p_parentchild_element_tab IN QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type,
                              p_parent_plan_id IN NUMBER,
                              p_parent_collection_id IN NUMBER,
                              p_parent_occurrence IN NUMBER,
                              p_child_plan_id IN NUMBER,
                              p_child_collection_id IN NUMBER,
                              p_child_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

 l_sql_string VARCHAR2(32000) := NULL;
 l_update_clause VARCHAR2(32000) := NULL;
 -- bug 6266477
 -- Increased the width to 32000 from 2000 for l_value
 -- skolluku Sun Oct 14 03:26:31 PDT 2007
 l_value VARCHAR2(32000);
 l_append BOOLEAN := FALSE;
 l_comma  CONSTANT VARCHAR2(3) := ' , ';


 c1         NUMBER;
 ignore     NUMBER;
 l_var      NUMBER := 1;
 -- bug 6266477
 -- Commented the bindTab array since the elementsarray would
 -- be used to build the array out of the string of values.
 -- l_bind_var would be declared as an object of ElementsArray
 -- skolluku Sun Oct 14 03:26:31 PDT 2007
 --
 -- TYPE bindTab IS TABLE OF l_value%TYPE INDEX BY BINARY_INTEGER;
 -- l_bind_var bindTab;
 l_bind_var   qa_txn_grp.ElementsArray;

 --
 -- bug 6266439
 -- New variable to hold the name of the column
 -- to be selected from the QA_RESULTS table
 -- ntungare Thu Aug  2 03:40:42 PDT 2007
 --
 select_column varchar2(2000);

 -- New variable to hold the bind variable
 -- to be updated in the QA_RESULTS table
 update_column varchar2(2000);
 --
 -- Bug 7588376
 -- A new variable to get the plan view naem for
 -- parent plan.
 -- skolluku
 --
 l_plan_view_name varchar2(1000);
BEGIN
    For element_cntr in 1..p_parentchild_element_tab.count
       LOOP
         --
         -- Bug 6266477
         -- Moved the if block below for better framing.
         -- skolluku Sun Oct 14 03:26:31 PDT 2007
         --
         -- IF(l_append) THEN
         --    l_update_clause := l_update_clause  || l_comma;
         -- END IF;

         --
         -- bug 6266439
         -- If the result column names are not of the sequenceXX or CommentsXX
         -- type, then they can be of the HC or SC date Type.
         -- So make a call to the new proc to get the appropriate Select
         -- and update columns
         -- ntungare Thu Aug  2 03:42:18 PDT 2007
         --
         If ((Substr(UPPER(p_parentchild_element_tab(element_cntr).parent_database_column),1,8) <> 'SEQUENCE')  AND
             (Substr(UPPER(p_parentchild_element_tab(element_cntr).parent_database_column),1,7) <> 'COMMENT')) THEN

            DATE_SELECT_UPDATE(p_parent_result_column => UPPER(p_parentchild_element_tab(element_cntr).parent_database_column),
                               p_child_result_column  => UPPER(p_parentchild_element_tab(element_cntr).child_database_column),
                               p_parent_plan_id       => p_parent_plan_id,
                               p_child_plan_id        => p_child_plan_id,
                               p_var                  => l_var,
                               p_select_column        => select_column,
                               p_update_column        => update_column);


         End If;
         --
         -- Bug 7588376
         -- Check if the child is a softcoded element. If it is, call the new procedure get_deref_column
         -- which returns the dereferenced column if the child is a SC element. This will help in copying the
         -- dereferenced value to the child instead of the ID.
         -- skolluku
         --
         --
	 --  Bug 8546279.FP for 8446050.extended to SEQUENCE and COMMENT element support.pdube
	 If ((Substr(UPPER(p_parentchild_element_tab(element_cntr).child_database_column),1,9) = 'CHARACTER' OR
	      Substr(UPPER(p_parentchild_element_tab(element_cntr).child_database_column),1,8) = 'SEQUENCE' OR
	      Substr(UPPER(p_parentchild_element_tab(element_cntr).child_database_column),1,7) = 'COMMENT') AND
 	              select_column IS NULL ) THEN --AND
 	              -- NOT parent_plan_vales_tab.exists(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence)) THEN

                 get_deref_column(p_parent_result_column => UPPER(p_parentchild_element_tab(element_cntr).parent_database_column),
                            p_parent_plan_id       => p_parent_plan_id,
                            x_select_column        => select_column);

         End If;
         -- bug 6266477
         -- Moved if block below for easier framing of
         -- the select clause.
         -- skolluku Sun Oct 14 03:26:31 PDT 2007
         --
         IF(l_append) THEN
            l_update_clause := l_update_clause  || l_comma;
            --
            -- bug 6266477
            -- Added the following to execute the query
            -- to fetch all the parent result column values
            -- in a single hit to qa_results table
            -- The string is built as 1=<result_column_value1>@2=result_column_value2>
            -- so that the result_to_array can be reused to collect into an array.
            -- skolluku Sun Oct 14 03:26:31 PDT 2007
            --
            l_sql_string := l_sql_string || ' || ''@';
            l_sql_string := l_sql_string || element_cntr || '='' || '
                            || 'replace(' || NVL(select_column, p_parentchild_element_tab(element_cntr).parent_database_column) || ', ''@'', ''@@'')';
         ELSE
            l_sql_string := l_sql_string || '''' || element_cntr || '='' || '
                            || 'replace(' || NVL(select_column,  p_parentchild_element_tab(element_cntr).parent_database_column) || ', ''@'', ''@@'')';
         END IF;

         --
         -- bug 6266439
         -- Making use of the select columns string
         -- ntungare Thu Aug  2 03:42:18 PDT 2007
         --
         /*
         l_sql_string := 'SELECT ' || p_parentchild_element_tab(element_cntr).parent_database_column
           || ' FROM qa_results '
           || ' WHERE plan_id= :p_parent_plan_id'
           || ' AND collection_id= :p_parent_collection_id'
           || ' AND occurrence= :p_parent_occurrence';
         */
          --
          -- bug 626477
          -- Commented out the execution of the built string,
          -- since this query needs to be executed
          -- only once to better performance.
          -- skolluku Sun Oct 14 03:26:31 PDT 2007
          --
          /*
         l_sql_string := 'SELECT ' || NVL(select_column, p_parentchild_element_tab(element_cntr).parent_database_column)
              || ' FROM qa_results '
              || ' WHERE plan_id= :p_parent_plan_id'
              || ' AND collection_id= :p_parent_collection_id'
              || ' AND occurrence= :p_parent_occurrence';

         BEGIN
            EXECUTE IMMEDIATE l_sql_string INTO l_value
               USING p_parent_plan_id,p_parent_collection_id,p_parent_occurrence;
         EXCEPTION
            WHEN OTHERS THEN RETURN 'F';
         END;
         */
         -- anagarwa Fri May 24 11:09:43 PDT 2002
         -- bug 2388986. Though not directly related to this bug, it was found
         -- during the analysis/review. If there's a single quote in value then
         -- this whole thing will fail. adding dequote prevents such catastrophic
         -- scenarios.

         -- Bug 2976810. Instead of the literal value concatenation and execution using
         -- EXECUTE IMMEDIATE, we'll pack these values into an array, bind them and
         -- and execute using DBMS_SQL.execute. kabalakr

         -- l_update_clause := l_update_clause || cur_rec.child_database_column ||
         --                    ' = ' || ''''||qa_core_pkg.dequote(l_value) ||'''';

         --
         -- bug 6266439
         -- Making use of the update columns string
         -- ntungare Thu Aug  2 03:45:10 PDT 2007
         --
         /*
         l_update_clause := l_update_clause ||
                            p_parentchild_element_tab(element_cntr).child_database_column ||
                            ' = :'||to_char(l_var);
         */
         l_update_clause := l_update_clause ||
                            p_parentchild_element_tab(element_cntr).child_database_column ||
                            ' = '||NVL(update_column, ':'||to_char(l_var));
         --
         -- bug 6266477
         -- Commented the below assignment
         -- since it will happen after statement execution
         -- outside the loop.
         -- skolluku Sun Oct 14 03:26:31 PDT 2007
         --
         -- l_bind_var(l_var) := l_value;
         l_var := l_var + 1;

         l_append := TRUE;

         -- Bug 8546279.FP for 8446050.pdube
         -- Reinitializing the select and update column variables for next
         -- collection element.
         select_column := NULL;
         update_column := NULL;
       END LOOP;

    IF( l_update_clause IS NULL) THEN
        -- this will happen only if the element_cursor does not fetch any records.
        RETURN 'T';
    END IF;
    --
    -- Bug 7588376
    -- Fetch the plan view name for the parent plan. The deref view
    -- will be used instead of QA_RESULTS table to copy the values
    -- from parent to child because QA_RESULTS does not contain the
    -- dereferenced values for hardcoded elements. If the parent
    -- element is HC and child is SC, the value, instead of the ID,
    -- should be copied, and using QA_RESULTS will not accomplish that.
    -- The value will be picked from the deref_view only if the value
    -- is not cached in the collection
    -- skolluku
    --
    --
    --  Bug 8546279.FP for 8446050.pdube
    -- IF NOT parent_plan_vales_tab.exists(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence) THEN
    IF NOT parent_plan_vales_tab.exists(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence||'*'||p_child_plan_id) THEN
       SELECT deref_view_name INTO l_plan_view_name
        FROM qa_plans
        WHERE plan_id = p_parent_plan_id;

    --
    -- Bug 7588376
    -- Replace QA_RESULTS with the l_plan_view_name for the reason explained above.
    -- skolluku
    --
    --
    --
    -- bug 6266477
    -- Execute the select statement here to hit the table
    -- QA_RESULTS only once to improve performance and get
    -- the values into anl_bind_var array.
    -- skolluku Sun Oct 14 03:26:31 PDT 2007
    --
    l_sql_string := 'Select ' || l_sql_string
                           -- || ' FROM qa_results '
                           || ' FROM ' || l_plan_view_name
                           || ' WHERE plan_id= :p_parent_plan_id'
                           || ' AND collection_id= :p_parent_collection_id'
                           || ' AND occurrence= :p_parent_occurrence';
    BEGIN
       EXECUTE IMMEDIATE l_sql_string INTO l_value
         USING p_parent_plan_id,p_parent_collection_id,p_parent_occurrence;
       -- Bug 8546279.FP for 8446050.Introduced child_plan_id to uniquely identify the record.pdube
       -- parent_plan_vales_tab(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence) := l_value;
       parent_plan_vales_tab(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence||'*'||p_child_plan_id) := l_value;
    EXCEPTION
       WHEN OTHERS THEN RETURN 'F';
    END;
    -- Picking the cached value
    ELSE
       -- Bug 8546279.FP for 8446050.pdube
       -- l_value := parent_plan_vales_tab(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence);
       l_value := parent_plan_vales_tab(p_parent_plan_id ||'*'||p_parent_collection_id||'*'||p_parent_occurrence||'*'||p_child_plan_id);
    END IF;

    l_bind_var := qa_txn_grp.result_to_array(l_value);

    l_update_clause := 'UPDATE qa_results  SET ' || l_update_clause
         || ' WHERE plan_id= :p_child_plan_id'
         || ' AND collection_id= :p_child_collection_id'
         || ' AND occurrence= :p_child_occurrence';

    BEGIN

        c1 := dbms_sql.open_cursor;
        dbms_sql.parse(c1, l_update_clause, dbms_sql.native);

        l_var := l_bind_var.FIRST;

        WHILE (l_var IS NOT NULL) LOOP
           --
           -- bug 6266477
           -- Replaced bind statement since, l_bind_val is
           -- an object of qa_txn_grp.ElementsArray which
           -- will have 2 fields and we are interested
           -- only in the value field.
           -- skolluku Sun Oct 14 03:26:31 PDT 2007
           --
           -- dbms_sql.bind_variable(c1, ':' || to_char(l_var), l_bind_var(l_var));
           dbms_sql.bind_variable(c1, ':' || to_char(l_var), l_bind_var(l_var).value);
	   l_var := l_bind_var.NEXT(l_var);
        END LOOP;

        dbms_sql.bind_variable(c1, ':p_child_plan_id', p_child_plan_id);
        dbms_sql.bind_variable(c1, ':p_child_collection_id', p_child_collection_id);
        dbms_sql.bind_variable(c1, ':p_child_occurrence', p_child_occurrence);

        ignore := dbms_sql.execute(c1);

        --bug# 5510747 shkalyan. Added close cursor
	dbms_sql.close_cursor(c1);

    EXCEPTION
       WHEN OTHERS THEN
        --
        -- Bug 4675642.
        -- The cursor c1 was not being closed in case of error during processing the records. Doing
        -- that now.
        -- ntungare Sun Oct 16 21:38:29 PDT 2005
        --
           IF dbms_sql.is_open(c1)
             THEN
               dbms_sql.close_cursor(c1);
           END IF;
           RETURN 'F';
    END;
    Return 'T';
END perform_child_update;

FUNCTION update_child(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

 -- the following cursor contains sql text used for the view
 -- qa_pc_result_columns_v. I added link_flag in where clause.

 -- anagarwa Mon Dec 16 16:55:09 PST 2002
 -- Bug 2701777
 -- added parent_enabled_flag and child_enabled_flag to where clause
 -- to limit working on onlly those elements that are enabled.

 CURSOR element_cursor IS
   SELECT qprc.parent_database_column,
          qprc.child_database_column
   FROM
       qa_pc_result_columns_v qprc
  WHERE
       qprc.parent_plan_id = p_parent_plan_id and
       qprc.child_plan_id = p_child_plan_id and
       qprc.element_relationship_type = 1 and
       parent_enabled_flag = 1 and
       child_enabled_flag = 1;

 -- suramasw.Bug 3561911.

 -- The following cursor was added to generate sequence numbers
 -- for sequence elements in child plan which donot have copy
 -- relation from the parent plan in date entry mode 'Automatic'.

 -- The cursor does the following(starting from the inner join)
 -- 1.get the child plan collection elements char_id's which have
 --   copy relation with the parent plan and when the date entry
 --   mode is 'Automatic'.
 -- 2.get the child plan collection elements char_ids which are
 --   of datatype sequence and which donot belong to the set of
 --   values fetched in step 1 mentioned above.
 -- 3.get the result_column_name(SEQUENCE1, SEQUENCE2, ......)
 --   for the values fetched in step 2 mentioned above.

/* Bug 3678910. Commenting out the changes done for bug 3561911.
   Please see the bug for more info. kabalakr.

 CURSOR seq_cursor is
    SELECT qpc.char_id,
           qpc.result_column_name
    FROM   qa_chars qc,
           qa_plan_chars qpc
    WHERE  qpc.plan_id = p_child_plan_id
    AND qpc.char_id NOT IN
        (SELECT child_char_id
         FROM qa_pc_element_relationship qper,
              qa_pc_plan_relationship qppr
         WHERE qper.plan_relationship_id  = qppr.plan_relationship_id
         AND qppr.parent_plan_id = p_parent_plan_id
         AND qppr.child_plan_id = p_child_plan_id
         AND qppr.data_entry_mode = 2)
    AND qpc.char_id = qc.char_id
    AND qc.datatype =5;

 l_seq VARCHAR2(2000);

*/


  -- 5114865
  -- Collection to hold the PC relationship elements
  l_element_cursor_tab QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type;

  -- Counter for the PC elements
  l_element_cntr  PLS_INTEGER := 1;

  l_ret_val  VARCHAR2(10);

BEGIN
  -- Bug 5114865
  -- Collecting the child plan elements which are
  -- to be updated into a collection that would be
  -- passed to perform_child_update to processing
  -- ntungare Wed Mar  8 09:04:26 PST 2006
  --
  FOR cur_rec IN element_cursor LOOP
     l_element_cursor_tab(l_element_cntr).parent_database_column:= cur_rec.parent_database_column;
     l_element_cursor_tab(l_element_cntr).child_database_column := cur_rec.child_database_column;
     l_element_cntr := l_element_cntr + 1;
  END LOOP;

   -- Bug 5114865
   -- Calling the proedure to perform the update
   -- ntungare Wed Mar  8 09:04:26 PST 2006
   --
   l_ret_val := perform_child_update
                       (p_parentchild_element_tab => l_element_cursor_tab,
                        p_parent_plan_id          => p_parent_plan_id ,
                        p_parent_collection_id    => p_parent_collection_id,
                        p_parent_occurrence       => p_parent_occurrence,
                        p_child_plan_id           => p_child_plan_id ,
                        p_child_collection_id     => p_child_collection_id,
                        p_child_occurrence        => p_child_occurrence);

   If l_ret_val = 'F'
     THEN RETURN 'F';
   END IF;

 RETURN 'T';
END update_child;

-- bug 5114865
-- New Function to get a list of all the elements
-- in the Child Plan that get the value from a seq
-- type element in the Parent plan or from a char
-- element having a sequence Ancestor
-- ntungare Wed Mar 22 01:13:53 PST 2006
--
FUNCTION get_seq_rel_elements (p_parent_plan_id      IN NUMBER,
                               p_child_plan_id       IN NUMBER,
                               p_topmostRel_flag     IN BOOLEAN,
                               p_parent_elements_tab IN QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type,
                               p_elements_tab       OUT NOCOPY QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type)

       RETURN BOOLEAN AS

   l_parent_datatype      NUMBER;
   l_childdbcolname       VARCHAR2(1000);
   l_prev_parentdbcolname VARCHAR2(1000);

   -- Cursor to fetch the Char elements in the child plan
   -- having sequence ancestor but not a direct Seq-char
   -- relation
   Cursor element_cur(p_parentdbcol VARCHAR2) IS
   SELECT qprc.parent_database_column parent_database_column,
           qprc.child_database_column  child_database_column
    FROM
        qa_pc_result_columns_v qprc
   WHERE
        qprc.parent_plan_id = p_parent_plan_id and
        qprc.child_plan_id = p_child_plan_id and
        qprc.element_relationship_type = 1 and
        parent_enabled_flag = 1 and
        child_dataType <> 5 and
        child_enabled_flag = 1 and
        parent_database_column = p_parentdbcol ;

   elements_tab_count PLS_INTEGER;
BEGIN
   -- Fetching the Sequence to Char Relation Elements
   SELECT qprc.parent_database_column parent_database_column,
           qprc.child_database_column  child_database_column
      BULK COLLECT INTO  p_elements_tab
    FROM
        qa_pc_result_columns_v qprc
   WHERE
        qprc.parent_plan_id = p_parent_plan_id and
        qprc.child_plan_id = p_child_plan_id and
        qprc.element_relationship_type = 1 and
        parent_enabled_flag = 1 and
        child_dataType <> 5 and
        child_enabled_flag = 1 and
        parent_dataType = 5 ;

    -- A topmost plan-child combination will only have
    -- Seq-Char copy relation. However, further down the
    -- hierarchy the copy relationship can be between
    -- two char elements, the one on the parent having a
    -- Sequence Ancestor. The following section of code
    -- fetches these relations
    -- ntungare
    If p_topmostRel_flag = FALSE THEN
       elements_tab_count := NVL(p_elements_tab.LAST,0);

       -- Looping through the elements that have been copied onto the
       -- Current parent plan, when it was processed as a child, and
       -- Checking if any of these have to be futher copied down on to
       -- the Current Child plan.
       FOR cntr in 1..p_parent_elements_tab.COUNT
          LOOP
             -- Fetching the values from the Cursor defined above
             -- passing the Parent and Child Plan Id and the Parent
             -- DB columns and setting the Child DB column where they need
             -- to be copied .
             FOR elem in element_cur(p_parent_elements_tab(cntr).child_database_column)
               LOOP
                  elements_tab_count := elements_tab_count +1;
                  p_elements_tab(elements_tab_count).parent_database_column := elem.parent_database_column;
                  p_elements_tab(elements_tab_count).child_database_column := elem.child_database_column;
               END LOOP;
          END LOOP;
    END IF;

    -- Checking if any P-C relations exist
    -- If they do then the function return
    -- TRUE after wich furhter processing can
    -- be done.
    IF p_elements_tab.COUNT <> 0 THEN
       RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END get_seq_rel_elements;

-- Bug 5114865
-- New Procedure to get a list of the elements that
-- have been copied onto the plan Id passed when it
-- is processed as a child plan.
-- The elements those have been copied at every level
-- are stored in the Collection nested in p_parentchild_Tab
-- ntungare Wed Mar 22 01:14:24 PST 2006
--
PROCEDURE get_parent_elementscopied(p_parentchild_Tab     IN QA_PARENT_CHILD_PKG.ParentChildTabTyp,
                                    p_current_plan_id     IN NUMBER,
                                    p_parent_elements_tab OUT NOCOPY QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type)
  AS
BEGIN
  -- Looping through all the P-C relations
  -- Till we reach a level where the Plan Id passed
  -- has been a child plan
  For cntr in 1..p_parentchild_Tab.COUNT
    LOOP
       If p_current_plan_id = p_parentchild_Tab(cntr).child_plan_id
         THEN
            -- If the level if found then the elements
            -- those have been copied in it when it was a child
            -- are returned in a collection.
            -- These are the only elements whose values may or
            -- maynot have to be propagated further to the
            -- subsequent Children, if such a relationship exists
            p_parent_elements_tab := p_parentchild_Tab(cntr).parentelement_tab;
            EXIT;
       END IF;
    END LOOP;
END get_parent_elementscopied;


-- Bug 5114865
-- Function to copy the values from the Parent to the Child plans
-- only when the source element in the Parent plan is of the
-- Sequence Type and that in the child is of the Char Type
-- ntungare Wed Mar 22 01:15:26 PST 2006
--
FUNCTION update_sequence_child(p_ParentChild_Tab IN QA_PARENT_CHILD_PKG.ParentChildTabTyp)
       RETURN VARCHAR2 IS

Type Num_tab_Typ is table of NUMBER INDEX BY BINARY_INTEGER;
parentCol_DataType_Tab Num_tab_Typ;
parentwithSeq_flag BOOLEAN;

l_ParentChild_Tab         QA_PARENT_CHILD_PKG.ParentChildTabTyp;
l_elements_toprocess_tab  QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type;
l_parent_elements_tab     QA_PARENT_CHILD_PKG.g_parentchild_elementtab_type;

l_ret_val VARCHAR2(10);

l_element_cntr  PLS_INTEGER := 1;

l_topmostRel_flag BOOLEAN;
l_topmost_plan_id NUMBER;

BEGIN
     l_ParentChild_Tab := p_ParentChild_Tab;
     parentwithSeq_flag := FALSE;
     l_topmostRel_flag := TRUE;

     --Getting the Topmost Plan Id
     l_topmost_plan_id := l_ParentChild_Tab(1).parent_plan_id;

     -- Looping through the P-C plan combinations to be processed
     For cntr in 1..l_ParentChild_Tab.COUNT
       LOOP
          -- If the current Parent Plan Id is the same as the
          -- Topmost plan id then setting the flag accordingly
          -- This flag would determine if we need to look at what
          -- elements have been copied to the Current Parent plan
          -- when it was processed as a child, or not, as it would
          -- have no meaning for the Topmost level Plan.
          If l_ParentChild_Tab(cntr).parent_plan_id = l_topmost_plan_id
            THEN l_topmostRel_flag := TRUE;
            ELSE l_topmostRel_flag := FALSE;
          END IF;

          -- Getting the elements copied to the current Parent Plan
          -- during its processing as a child Plan.
          -- For the Topmost level plan, this would be of no meaning
          IF l_topmostRel_flag = FALSE THEN
             get_parent_elementscopied(p_ParentChild_Tab     => l_ParentChild_Tab,
                                       p_current_plan_id     => l_ParentChild_Tab(cntr).parent_plan_id,
                                       p_parent_elements_tab => l_parent_elements_tab);
          END IF;

          -- Getting a list of the the elements in the child plan
          -- that either get the value from a sequence element in
          -- the parent plan or a Char element which is turn may
          -- have received the data from a sequence element
          --
          parentwithSeq_flag := get_seq_rel_elements
                                        (p_parent_plan_id      => l_ParentChild_Tab(cntr).parent_plan_id,
                                         p_child_plan_id       => l_ParentChild_Tab(cntr).child_plan_id,
                                         p_topmostRel_flag     => l_topmostRel_flag,
                                         p_parent_elements_tab => l_parent_elements_tab,
                                         p_elements_tab        => l_elements_toprocess_tab);

          -- Processing the list of elements obtained from above
          -- and captured in l_pc_elementstoprocess_tab
          -- The parentwithSeq_flag would be TRUE only if any of
          -- the elements of the Child Plan have copy relations
          -- with Seq Type elements or with Char elements with Seq
          -- Type ancestors, in the parent plan
          --
          IF parentwithSeq_flag THEN
             l_ret_val := perform_child_update
                                 (p_parentchild_element_tab => l_elements_toprocess_tab,
                                  p_parent_plan_id          => l_ParentChild_Tab(cntr).parent_plan_id,
                                  p_parent_collection_id    => l_ParentChild_Tab(cntr).parent_collection_id,
                                  p_parent_occurrence       => l_ParentChild_Tab(cntr).parent_occurrence,
                                  p_child_plan_id           => l_ParentChild_Tab(cntr).child_plan_id,
                                  p_child_collection_id     => l_ParentChild_Tab(cntr).child_collection_id,
                                  p_child_occurrence        => l_ParentChild_Tab(cntr).child_occurrence);

             If l_ret_val = 'F'
                THEN RETURN 'F';
             END IF;

             -- Resetting the flag value
             parentwithSeq_flag := FALSE;

             -- Copying the list of the elements copied to the
             -- Child plan into the nested collection in l_ParentChild_Tab
             -- as this would be looked up when the Current Child plan is
             -- processed as a Parent Plan
             --
             l_ParentChild_Tab(cntr).parentelement_tab:= l_elements_toprocess_tab;

             -- Emptying the elements collection
             l_elements_toprocess_tab.DELETE;
          END IF;
        END LOOP;
   RETURN 'T';
END update_sequence_child;

PROCEDURE get_criteria_values(p_parent_plan_id IN NUMBER,
                              p_parent_collection_id IN NUMBER,
                              p_parent_occurrence IN NUMBER,
                              p_organization_id IN NUMBER,
                              x_criteria_values OUT NOCOPY VARCHAR2) IS


CURSOR parent_cur IS
   /*
     anagarwa Tue Jul 16 18:36:52 PDT 2002
     Bug 2465920 reports that when hardcoded elements have to be copied to
     history or automatic plans in collection imports, it (histor/automatic
     functionality) fails.
     By selecting form_field instead of database_column we can fix it.
     However, item, comp_item, locator and  comp_locator don't exist in
     QA_RESULTS_V. So we add special handling for these later.
  */
   --SELECT char_id,database_column
   SELECT char_id, replace(form_field, 'DISPLAY' , 'CHARACTER') database_column,
        datatype
   FROM qa_pc_plan_columns_v
   WHERE plan_id = p_parent_plan_id;

 --
 -- bug 6266477
 -- Increased the width of the variables
 -- l_res_value, select_clause to 32000
 -- skolluku Mon Oct 15 02:57:40 PDT 2007
 --
 l_res_value  VARCHAR2(32000);
 l_string     VARCHAR2(32000);
 l_append     BOOLEAN;

 select_clause VARCHAR2(32000);
 from_clause CONSTANT VARCHAR2(80)    := ' FROM QA_RESULTS_V ';
 where_clause VARCHAR2(5000);
 query_clause VARCHAR2(32000);
 -- anagarwa Tue Jul 16 18:36:52 PDT 2002
 -- Bug 2465920: new variable to handle  item, comp_item, locator and
 -- comp_locator
 column_name  VARCHAR2(150);


 -- Bug 3776542. Performance issue due to use of literals in the SQL to fetch
 -- criteria value from QA_RESULTS_V. Earlier we were using reference cursor to
 -- fetch the value with a SQL that had literals. After fix, we are using EXECUTE_IMMEDIATE
 -- with SQL containing bind variables. This ref cursor is needed no more, hence commenting
 -- it out.Thu Jul 29 02:02:03 PDT 2004.
 -- srhariha.

-- Type resCurTyp IS REF CURSOR; --define weak REF CURSOR type
-- res_cur resCurTyp; --define cursor variable

BEGIN

  -- Bug 3776542. Performance issue due to use of literals in the SQL. Modified the
  -- string to include bind variables.
  -- srhariha.Thu Jul 29 02:02:03 PDT 2004.
  l_append := FALSE;
  where_clause := ' WHERE plan_id = ' || ':p_parent_plan_id' ||
                   ' AND collection_id = ' ||':p_parent_collection_id' ||
                   ' AND occurrence = ' || ':p_parent_occurrence';

  -- finding out the values for each element of parent record
  FOR parent_rec IN parent_cur LOOP
      -- anagarwa Tue Jul 16 18:36:52 PDT 2002
      -- Bug 2465920: item, comp_item, locator and comp_locator don't exist in
      -- QA_REULTS_V so we select id's instead.
      column_name := parent_rec.database_column;
      IF column_name = 'ITEM' THEN
          column_name := 'ITEM_ID';

      ELSIF column_name = 'COMP_ITEM' THEN
          column_name := 'COMP_ITEM_ID';

      ELSIF column_name = 'LOCATOR' THEN
          column_name := 'LOCATOR_ID';

      ELSIF column_name = 'COMP_LOCATOR' THEN
          column_name := 'COMP_LOCATOR_ID';

      -- Bug 2694385. Added bill_reference,routing_reference,to_locator since
      -- these elements will not present in qa_results_v.
      -- rponnusa Wed Dec 18 05:38:40 PST 2002

      ELSIF column_name = 'BILL_REFERENCE' THEN
          column_name  := 'BILL_REFERENCE_ID';

      ELSIF column_name = 'ROUTING_REFERENCE' THEN
          column_name  := 'ROUTING_REFERENCE_ID';

      ELSIF column_name = 'TO_LOCATOR' THEN
          column_name  := 'TO_LOCATOR_ID';

      -- Bug 3424886 ksoh Mon Feb  9 13:39:41 PST 2004
      -- need to convert hardcoded dates to canonical string
      ELSIF (substr(column_name, 1, 9) <> 'CHARACTER') AND
            (parent_rec.datatype = qa_ss_const.datetime_datatype) THEN
          column_name  := 'FND_DATE.DATE_TO_CANONICAL(' || column_name || ')';
      END IF;
      --
      -- bug 6266477
      -- Commenting the below code since the handling is done
      -- differently to avoid multiple hits to QA_RESULTS_V
      -- skolluku Mon Oct 15 02:57:40 PDT 2007
      --
      /*select_clause := 'SELECT ' || column_name;
      query_clause := select_clause || from_clause || where_clause;

      -- Bug 3776542. Performance issue due to use of literals in the SQL to fetch
      -- criteria value from QA_RESULTS_V. Earlier we were using reference cursor to
      -- fetch the value with a SQL that had literals. After fix, we are using EXECUTE_IMMEDIATE
      -- with SQL containing bind variables. This ref cursor is needed no more, hence commenting
      -- it out.
      -- srhariha.Thu Jul 29 02:02:03 PDT 2004

      --OPEN res_cur FOR query_clause ;
      --FETCH res_cur INTO l_res_value;
      --CLOSE res_cur;
      EXECUTE IMMEDIATE query_clause
              INTO      l_res_value
              USING     p_parent_plan_id,
                        p_parent_collection_id,
                        p_parent_occurrence;

      IF (l_append) THEN
           l_string    := l_string || '@';
      END IF;
      */


      -- Bug 2694385. Commented existing IF condition and added following code with
      -- bill_reference,routing_reference,to_locator
      -- rponnusa Wed Dec 18 05:38:40 PST 2002

    /*
      IF ((parent_rec.char_id = 10) or  parent_rec.char_id = 60) then
              l_res_value := qa_flex_util.item(p_organization_id , l_res_value);
      ELSIF ((parent_rec.char_id = 15) or (parent_rec.char_id = 65)) then
              l_res_value := qa_flex_util.locator(p_organization_id, l_res_value);
      END IF;
    */
      -- Bug 6266477
      -- Commented below code.
      -- skollluku Mon Oct 15 02:57:40 PDT 2007
      /*IF parent_rec.char_id IN (qa_ss_const.item, qa_ss_const.comp_item,
                                qa_ss_const.routing_reference, qa_ss_const.bill_reference) THEN
            l_res_value := qa_flex_util.item(p_organization_id , l_res_value);

      ELSIF parent_rec.char_id IN (qa_ss_const.locator, qa_ss_const.comp_locator,
                                   qa_ss_const.to_locator) THEN
            l_res_value := qa_flex_util.locator(p_organization_id, l_res_value);
      END IF;

      -- Bug 2403395
      -- If the l_res_value contains '@' character then doubly encode it.
      -- rponnusa Wed Jun  5 00:49:14 PDT 2002
      l_res_value := replace(l_res_value,'@','@@');

      l_string := l_string || parent_rec.char_id || '=' || l_res_value;
      */
      --
      -- bug 6266477
      -- Added the below code to enhance performance
      -- by hitting the view QA_RESULTS_V just once
      -- skolluku Mon Oct 15 02:57:40 PDT 2007
      --
      IF parent_rec.char_id IN (qa_ss_const.item, qa_ss_const.comp_item,
                                qa_ss_const.routing_reference, qa_ss_const.bill_reference) THEN
            column_name := 'qa_flex_util.item(' || p_organization_id || ', ' || column_name || ')';

      ELSIF parent_rec.char_id IN (qa_ss_const.locator, qa_ss_const.comp_locator,
                                   qa_ss_const.to_locator) THEN
            column_name := 'qa_flex_util.locator(' || p_organization_id || ', ' || column_name || ')';
      END IF;

      column_name := 'replace(' || column_name || ', ''@'', ''@@'')';
      if (l_append) then
         l_string    := l_string || ' || ''@';
         l_string := l_string || parent_rec.char_id || '='' || ' || column_name;
      else
         l_string := l_string || '''' || parent_rec.char_id || '='' || ' || column_name;
      end if;

      l_append := TRUE;

  END LOOP;
  --
  -- bug 6266477
  -- Executing the statement outside the loop
  -- to improve performance.
  -- skolluku Mon Oct 15 02:57:40 PDT 2007
  --
  select_clause := 'SELECT ' || l_string;
  query_clause := select_clause || from_clause || where_clause;
  EXECUTE IMMEDIATE query_clause
          INTO      l_res_value
          USING     p_parent_plan_id,
                    p_parent_collection_id,
                    p_parent_occurrence;
  --
  -- bug 6266477
  -- Modified since l_res_value needs be
  -- assigned to x_criteria_values
  -- skolluku Mon Oct 15 02:57:40 PDT 2007
  --
  -- x_criteria_values := l_string;
  x_criteria_values := l_res_value;

END get_criteria_values;



PROCEDURE insert_history_auto_rec(p_parent_plan_id IN NUMBER,
                                  p_txn_header_id IN NUMBER,
                                  p_relationship_type IN NUMBER,
                                  p_data_entry_mode IN NUMBER) IS

 CURSOR plan_cur IS
  SELECT 1
  FROM qa_pc_plan_relationship
  WHERE parent_plan_id = p_parent_plan_id
  AND plan_relationship_type = p_relationship_type
  AND data_entry_mode = p_data_entry_mode;

 CURSOR res_cur IS
  SELECT collection_id,occurrence,organization_id
  FROM qa_results
  WHERE plan_id = p_parent_plan_id
  AND txn_header_id = p_txn_header_id;


l_dummy   NUMBER := -99;
l_spec_id NUMBER;
x_status  VARCHAR2(1);
l_status  VARCHAR2(1);

l_criteria_values VARCHAR2(32000);
l_child_plan_ids  VARCHAR2(10000);

-- variables declared for bug 2302539
l_child_txn_header_id NUMBER;
l_fire_action         BOOLEAN := FALSE;

BEGIN
  IF(QA_PARENT_CHILD_PKG.is_parent_child_plan(p_parent_plan_id ) = 'F') THEN
      -- don't do anything
     RETURN;
  END IF;
  OPEN plan_cur;
  FETCH plan_cur INTO l_dummy;
  CLOSE plan_cur;

  IF(l_dummy <> 1) THEN
    -- no history or automatic child plans
    RETURN;
  END IF;

  -- Bug 2302539
  -- Parent and child records txn_header_id should be different in order to fire
  -- actions for the child plans, since action firing for the parent record
  -- was taken care in collection import code. We just needs to fire actions
  -- for the child records.
  -- rponnusa Tue May 28 01:52:47 PDT 2002
  FOR c1 in (SELECT mtl_material_transactions_s.nextval txn_header_id FROM DUAL) LOOP

      l_child_txn_header_id := c1.txn_header_id;
      EXIT;
  END LOOP;

  FOR import_rec IN res_cur LOOP
     get_criteria_values(p_parent_plan_id,
                         import_rec.collection_id,
                         import_rec.occurrence,
                         import_rec.organization_id,
                         l_criteria_values);
     l_status := evaluate_criteria(p_parent_plan_id,
                                   l_criteria_values,
                                   p_relationship_type,
                                   p_data_entry_mode,
                                   l_child_plan_ids);

     IF(l_status = 'T') THEN

        insert_automatic_records(p_parent_plan_id,
                                 import_rec.collection_id,
                                 import_rec.occurrence,
                                 l_child_plan_ids,
                                 p_relationship_type,
                                 p_data_entry_mode,
                                 l_criteria_values,
                                 import_rec.organization_id,
                                 l_spec_id,
                                 x_status,
                                 l_child_txn_header_id);
        l_fire_action := TRUE;
     END IF;


  END LOOP;

  -- Bug 2302539
  -- enable and fire actions only if atleast one history/automatic record is inserted.
  -- Passing child_txn_header_id to fire actions for the child plans.
  -- rponnusa Tue May 28 01:52:47 PDT 2002

  IF l_fire_action THEN
    enable_fire_for_txn_hdr_id(l_child_txn_header_id);
  END IF;

END insert_history_auto_rec;

FUNCTION is_parent_saved(p_plan_id  IN NUMBER,
                          p_collection_id IN NUMBER,
                          p_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

 -- Return true if the given parent record is saved in enable status

 CURSOR c IS
    SELECT 1
    FROM qa_results
    WHERE plan_id = p_plan_id
    AND collection_id = p_collection_id
    AND occurrence = p_occurrence
    AND status = 2;

 l_status NUMBER := -99;
BEGIN
  OPEN c;
  FETCH c INTO  l_status;
  CLOSE c;
  IF (l_status = 1) THEN
     RETURN 'T';
  ELSE
     RETURN 'F';
  END IF;

END is_parent_saved;

FUNCTION update_all_children(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

  l_return_value  VARCHAR2(1);
  l_dummy VARCHAR2(1);

  -- anagarwa Fri May 24 09:57:43 PDT 2002
  -- bug 2388986
  -- the cursor was incorrect because it was updating all children including
  -- history records. this is incorrect as instead of just inserting a new
  --  record for history, all previour records are updated with new data.
  -- This in turn causes the audit trail to be lost thereby defeating the
  -- whole purpose of having history plans!
  -- I've added a new join with qa_pc_plan_relationship to ensure this does
  -- NOT happen for history plans.
  -- IT IS EXTREMELY IMPORTANT TO ENSURE THAT A SINGLE PAIR OF PARENT CHILD
  -- PLANS FORM A SINGLE RELATIONSHIP. IF NOT THAT THIS JOIN WILL FAIL !
  CURSOR children_cur IS
        select qprr.child_plan_id,
               qprr.child_collection_id,
               qprr.child_occurrence
        from   qa_pc_results_relationship qprr,
               qa_pc_plan_relationship    qpr
        where  qprr.parent_occurrence = p_parent_occurrence
        and    qprr.parent_plan_id = p_parent_plan_id
        and    qprr.parent_collection_id = p_parent_collection_id
        and    qpr.parent_plan_id = qprr.parent_plan_id
        and    qpr.child_plan_id = qprr.child_plan_id
        and    qpr.data_entry_mode <> 4;

BEGIN
    l_return_value := 'T';
    l_dummy := 'T';
    --
    -- bug 7588376
    -- Starting with a fresh copy of the collection
    -- that stores the values of the relactionship elements
    -- in the parent plan
    --
    parent_plan_vales_tab.delete;

        FOR children_rec IN children_cur
        LOOP
                l_return_value :=
                        update_child (  p_parent_plan_id,
                                p_parent_collection_id,
                                p_parent_occurrence,
                                children_rec.child_plan_id,
                                children_rec.child_collection_id,
                                children_rec.child_occurrence);

                --check if the fetched child has any children
                IF (descendants_exist(children_rec.child_plan_id,
                                children_rec.child_collection_id,
                                children_rec.child_occurrence) = 'T')
                THEN
                        --Recursive call
                   l_dummy :=
                      update_all_children(children_rec.child_plan_id,
                                children_rec.child_collection_id,
                                children_rec.child_occurrence);
                END IF;
        END LOOP;
        --
        -- bug 7588376
        -- resetting the collection
        --
        parent_plan_vales_tab.delete;
        RETURN l_return_value;

END update_all_children;


 FUNCTION applicable_child_plans_eqr( p_plan_id          IN NUMBER ,
                                        p_criteria_values  IN VARCHAR2)
                                        RETURN VARCHAR2 IS

 ret_flag VARCHAR2(10);
 child_plan_list VARCHAR2(1000);

 BEGIN

    ret_flag := evaluate_child_lov_criteria (p_plan_id, p_criteria_values,
                                             child_plan_list);

   RETURN child_plan_list;


 END applicable_child_plans_eqr;

 FUNCTION applicable_child_plans(p_plan_id            IN NUMBER,
                                   p_criteria_values    IN VARCHAR2)
      RETURN VARCHAR2
   IS
   --similar to evaluate_child_lov_criteria except no data_entry_mode
   -- restriction
      CURSOR c IS
          SELECT qpr.plan_relationship_id,
                 qpr.child_plan_id,
                 qpr.data_entry_mode
          FROM   qa_plans qp,
                 qa_pc_plan_relationship qpr
          WHERE  qpr.parent_plan_id = p_plan_id
          AND    qpr.child_plan_id = qp.plan_id
          AND    qpr.plan_relationship_type = 1
          AND ((qp.effective_to IS NULL AND TRUNC(SYSDATE) >= qp.effective_from)
                OR (qp.effective_from IS NULL AND TRUNC(SYSDATE) <= qp.effective_to)
                OR (qp.effective_from IS NOT NULL AND qp.effective_to IS NOT NULL
                    AND TRUNC(SYSDATE) BETWEEN qp.effective_from AND qp.effective_to)
                OR (qp.effective_from IS NULL AND qp.effective_to IS NULL));
     l_separator             CONSTANT VARCHAR2(1) := '@';
     l_subseparator          CONSTANT VARCHAR2(1) := '=';
     l_child_plan_id         NUMBER;
     l_data_entry_mode       NUMBER;
     l_plan_relationship_id  NUMBER;
     l_childexist            BOOLEAN;
     l_return_string         VARCHAR2(4000);
     l_elements              qa_txn_grp.ElementsArray;
   BEGIN
      l_childexist := FALSE;

      l_elements := qa_txn_grp.result_to_array(p_criteria_values);
      OPEN c;
      LOOP
         FETCH c INTO l_plan_relationship_id, l_child_plan_id, l_data_entry_mode;
         IF (c%NOTFOUND) THEN
            EXIT;
         END IF;

         IF (qa_parent_child_pkg.criteria_matched(l_plan_relationship_id,
                                                  l_elements) = 'T') THEN
            IF (l_childexist) THEN
               l_return_string := l_return_string || l_separator
                                  || l_child_plan_id || l_subseparator
                                  || l_data_entry_mode;
            ELSE
               l_return_string := l_child_plan_id || l_subseparator
                                  || l_data_entry_mode;
               l_childexist := TRUE;
            END IF;
         END IF;
      END LOOP;

      CLOSE c;
      RETURN l_return_string;
   END;



 --anagarwa
 -- Bug 3195431
 -- only copy elements are context elements. So
 -- element_relationship type added to the cursor
 FUNCTION is_context_element( p_plan_id IN NUMBER ,
                              p_char_id IN NUMBER,
                              p_parent_plan_id IN NUMBER,
                              p_txn_or_child_flag IN NUMBER)
                                        RETURN VARCHAR2 IS

 CURSOR c IS SELECT 1
   FROM qa_pc_result_columns_v
   WHERE child_plan_id  = p_plan_id and
         child_char_id  = p_char_id and
         parent_plan_id = p_parent_plan_id and
         ELEMENT_RELATIONSHIP_TYPE = 1;


 l_context VARCHAR2(1);
 ret_val NUMBER;


 BEGIN
       l_context := 'N';

       OPEN c;
       FETCH c INTO ret_val;
       IF(c%NOTFOUND) THEN
         l_context := 'N';
       ELSIF ret_val = 1 THEN
         l_context := 'Y';
       END IF;
       CLOSE c;

       RETURN l_context;

 END is_context_element;



 FUNCTION get_parent_vo_attribute_name(p_child_char_id IN NUMBER,
                                       p_plan_id IN NUMBER)
                                        RETURN VARCHAR2 IS

 CURSOR c IS SELECT parent_char_id
   FROM qa_pc_result_columns_v
   WHERE parent_plan_id  = p_plan_id and
         child_char_id  = p_child_char_id and
         element_relationship_type = 1;

 l_parent_char_id NUMBER;


 BEGIN

       OPEN c;
       FETCH c INTO l_parent_char_id;
       IF(c%NOTFOUND) THEN
         CLOSE c;
         RETURN NULL;
       END IF;
       CLOSE c;

       RETURN qa_ak_mapping_api.get_vo_attribute_name(l_parent_char_id,
                                                      p_plan_id);

 END get_parent_vo_attribute_name;

 --
 -- bug 8417775
 -- overloaded the function to read the child plan id
 -- ntungare
 --
 FUNCTION get_parent_vo_attribute_name(p_child_char_id IN NUMBER,
                                       p_plan_id IN NUMBER,
                                       p_child_plan_id IN NUMBER)
                                        RETURN VARCHAR2 IS

 CURSOR c IS SELECT parent_char_id
   FROM qa_pc_result_columns_v
   WHERE parent_plan_id  = p_plan_id and
         child_plan_id   = p_child_plan_id and
         child_char_id  = p_child_char_id and
         element_relationship_type = 1;

 l_parent_char_id NUMBER;


 BEGIN

       OPEN c;
       FETCH c INTO l_parent_char_id;
       IF(c%NOTFOUND) THEN
         CLOSE c;
         RETURN NULL;
       END IF;
       CLOSE c;

       RETURN qa_ak_mapping_api.get_vo_attribute_name(l_parent_char_id,
                                                      p_plan_id);

 END get_parent_vo_attribute_name;


 FUNCTION get_layout_mode (p_parent_plan_id IN NUMBER,
                           p_child_plan_id IN NUMBER)
                        RETURN NUMBER IS
 CURSOR c is
        SELECT layout_mode
        FROM   qa_pc_plan_relationship
        WHERE  parent_plan_id = p_parent_plan_id
        AND    child_plan_id = p_child_plan_id;

 l_layout_mode NUMBER := 0;

 BEGIN

      OPEN c;
      FETCH c INTO l_layout_mode;
      IF(c%NOTFOUND) THEN
         CLOSE c;
         RETURN -1;
      END IF;
      CLOSE c;
      RETURN l_layout_mode;

 END get_layout_mode;

 FUNCTION ssqr_post_actions(p_txn_hdr_id IN NUMBER,
                            p_plan_id IN NUMBER,
                            p_transaction_number IN NUMBER,
                            x_sequence_string OUT NOCOPY VARCHAR2)
                           RETURN VARCHAR2 IS

 x_status VARCHAR2(10) ;

 BEGIN

     --initialize the sequence string to empty value
     x_sequence_string := '';
     x_status := '';

     QA_SEQUENCE_API.generate_seq_for_DDE(p_txn_hdr_id, p_plan_id,
                                          x_status, x_sequence_string);


     -- generate sequences

     -- call enable and fire actions

     IF p_transaction_number > 0 THEN
         -- do nothing in case of transaction.
        RETURN x_status;
     ELSE
         enable_fire_for_txn_hdr_id(p_txn_hdr_id);
         RETURN x_status;
     END IF;

 END;
 FUNCTION count_updated(p_plan_id IN NUMBER,
                        p_txn_header_id IN NUMBER) RETURN NUMBER IS
---
--- Bug 3095436: Self Service Quality project
--- Simple function to count the number of rows updated in a plan
--- with a particular txn_header_id
--- Used by the Plan Search VO
---
  cnt NUMBER;

  cursor c is
    select count(plan_id)
    from qa_results
    where plan_id = p_plan_id
    and txn_header_id = p_txn_header_id;

  BEGIN
    open c;
    fetch c into cnt;
    if (c%notfound) then
        return 0;
    else
        return cnt;
    end if;
    close c;

  END count_updated;

FUNCTION get_vud_allowed ( p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS
---
--- Bug 3095436: Self Service Quality project
--- Simple function to tell if the current user has privilege to
--- view, update or delete results in a particular plan
--- Used by the Plan Search VO
---

BEGIN

    IF (qa_web_txn_api.allowed_for_plan('QA_RESULTS_VIEW', p_plan_id) = 'T') or
       (qa_web_txn_api.allowed_for_plan('QA_RESULTS_DELETE', p_plan_id) = 'T') or
       (qa_web_txn_api.allowed_for_plan('QA_RESULTS_UPDATE', p_plan_id) = 'T') THEN
      RETURN 'T';
    ELSE
      RETURN 'F';
    END IF;

END get_vud_allowed;

 --12.1 QWB Usaibilty Improvements
 -- Overloaded this function so as to cause minimum
 -- impact to the existing code
 FUNCTION update_parent(p_parent_plan_id       IN NUMBER,
                        p_parent_collection_id IN NUMBER,
                        p_parent_occurrence    IN NUMBER,
                        p_child_plan_id        IN NUMBER,
                        p_child_collection_id  IN NUMBER,
                        p_child_occurrence     IN NUMBER,
                        p_child_txn_hdr_id     IN NUMBER)
        RETURN VARCHAR2 IS
    agg_elements VARCHAR2(4000);
    agg_val      VARCHAR2(4000);
 BEGIN
    return update_parent(
                       p_parent_plan_id,
                       p_parent_collection_id,
                       p_parent_occurrence,
                       p_child_plan_id,
                       p_child_collection_id,
                       p_child_occurrence,
                       p_child_txn_hdr_id,
                       agg_elements,
                       agg_val);
 END update_parent;

 -- anagarwa Fri Jan 23 12:10:04 PST 2004
 -- Bug 3384986 Actions for CAR master not fired when child is updated
 -- This is a copy of update_parent above with one extra param, txn_header_id
 -- In SSQR when we update the child record, then we call this to update parent
 -- and since now we would ike to fire background actions of parent, we update the
 -- txn_header_id too.
 -- NOTE: I did not modify the existing update_parent but duplicated the code
 -- because changing the parameters of existing procedure/function is strongly
 -- discouraged per Safe Spec Guide located at
 -- http://www-apps.us.oracle.com/%7Epwallack/SafeSpecs.htm

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- Added p_commit parameter since we do not want to commit by default
  -- If invoked from OAF Pages.
  -- shkalyan 05/13/2005.
 FUNCTION update_parent(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER,
                       p_child_plan_id IN NUMBER,
                       p_child_collection_id IN NUMBER,
                       p_child_occurrence IN NUMBER,
                       p_child_txn_hdr_id IN NUMBER,
                       x_agg_elements OUT NOCOPY VARCHAR2,
                       x_agg_val OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2 IS

 l_sql_string VARCHAR2(32000);
 l_update_parent_sql VARCHAR2(32000);
 l_value NUMBER;

 -- anagarwa Mon Dec 16 16:55:09 PST 2002
 -- Bug 2701777
 -- added parent_enabled_flag and child_enabled_flag to where clause
 -- to limit working on onlly those elements that are enabled.
 CURSOR element_cursor IS
    SELECT parent_database_column,
           child_database_column,
           element_relationship_type,
           parent_char_id
    FROM   qa_pc_result_columns_v
    WHERE  parent_plan_id = p_parent_plan_id
    AND    child_plan_id = p_child_plan_id
    AND    element_relationship_type in (2,3,4,5,6,7,8)
    AND    parent_enabled_flag = 1
    AND    child_enabled_flag = 1;


 BEGIN

  FOR cur_rec IN element_cursor LOOP

      -- build the required sql string

      l_sql_string := 'FROM qa_results qr, qa_pc_results_relationship pc'
                    || ' WHERE qr.plan_id=pc.child_plan_id'
                    || ' AND qr.collection_id=pc.child_collection_id'
                    || ' AND qr.occurrence=pc.child_occurrence'
                    || ' AND pc.parent_occurrence= :p_parent_occurrence'
                    || ' AND pc.child_plan_id= :p_child_plan_id'
                    --
                    -- bug 5682448
                    -- Added the extra condititon to aggregate only the
                    -- enabled records in stauts 2 or NULL
                    -- ntungare Wed Feb 21 07:36:09 PST 2007
                    --
                    || ' AND (qr.status = 2 OR qr.status IS NULL)';

      -- Bug 2427337. Fix here is not related this bug. To use aggregate functions
      -- on a element which is stored in character col in qa_results table, we need
      -- to use to_number function, or else, unwanted value will be returned.
      -- rponnusa Tue Jun 25 06:15:48 PDT 2002

      IF (cur_rec.element_relationship_type = 2  ) THEN  -- sum
         l_sql_string := 'SELECT SUM(to_number(qr.'||cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 3 ) THEN  -- average or Mean
         l_sql_string := 'SELECT AVG(to_number(qr.'||cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 4 ) THEN -- std. deviation
         l_sql_string := 'SELECT STDDEV(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;

      ELSIF (cur_rec.element_relationship_type = 5 ) THEN -- min
         l_sql_string := 'SELECT MIN(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 6 ) THEN -- max
         l_sql_string := 'SELECT MAX(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 7 ) THEN -- variance
         l_sql_string := 'SELECT VARIANCE(to_number(qr.'|| cur_rec.child_database_column||')) ' || l_sql_string;
      ELSIF (cur_rec.element_relationship_type = 8 ) THEN -- count
         -- anagarwa  Tue Feb 18 11:13:20 PST 2003
         -- Bug 2789847
         -- Count may be done on non numeric elements like Sequence Numbers and
         -- even Nonconformance Status, Source etc.
         -- A to_number will cause an exception in such a case and is hence
         -- removed from sql statement.
         l_sql_string := 'SELECT COUNT(qr.'|| cur_rec.child_database_column||') ' || l_sql_string;
      END IF;
      -- find out the aggregate value for the element in child plan.
      BEGIN
         EXECUTE IMMEDIATE l_sql_string INTO l_value
                 USING p_parent_occurrence,p_child_plan_id;
      EXCEPTION
        WHEN OTHERS THEN raise;

      END;

      -- Bug 2716973
      -- When the child aggregate relationship element value is updated to parent record,
      -- Post-Forms-Commit Trigger error raised if child element contain null value.
      -- rponnusa Sun Jan 12 23:59:07 PST 2003

      l_value := NVL(l_value,0);

      -- See 2624112
      -- The maximum allowed precision is now expanded to 12.
      -- Rounding to 12...
      -- rkunchal Thu Oct 17 22:51:45 PDT 2002

      -- rounding off to 6 digits is required since, for a number field, the maximum allowd
      -- decimal places is 6.

      -- l_value := round(l_value,6);
      l_value := round(l_value,12);

      -- now we need to update the parent record. Build the sql here.

      -- Bug 4270911. CU2 SQL Literal fix.TD #19
      -- Use bind variable for child txn hdr id.
      -- srhariha. Fri Apr 15 05:55:04 PDT 2005.

      l_update_parent_sql := 'UPDATE qa_results  SET '
                            || cur_rec.parent_database_column || ' = :l_value'
                            || ' ,txn_header_id = :p_child_txn_hdr_id'
                            || ' WHERE plan_id= :p_parent_plan_id'
                            || ' AND collection_id= :p_parent_collection_id'
                            || ' AND occurrence= :p_parent_occurrence';
      BEGIN
         EXECUTE IMMEDIATE l_update_parent_sql
                 USING l_value,p_child_txn_hdr_id,p_parent_plan_id,p_parent_collection_id,p_parent_occurrence;

         -- 12.1 QWB Usability improvements
         -- Building a list of the Aggregated parent plan elements
         --
         x_agg_elements := x_agg_elements ||','||
                           qa_ak_mapping_api.get_vo_attribute_name(cur_rec.parent_char_id, p_parent_plan_id);
         -- 12.1 QWB Usability improvements
         -- Building a list of the Aggregated values
         --
         x_agg_val := x_agg_val ||','|| l_value;
      EXCEPTION
        WHEN OTHERS THEN raise;
      END;


  END LOOP;
  -- we are returning true when the parent record is updated or
  -- there is no aggregate relationship defined for the parent,child plans.

  -- Bug 2300962. Needs explicit commit, if called from post-database-commit trigger
  -- bug 5306909
  -- Commenting this COMMIT as this Update_parent function
  -- with the Txn_header_id is called from QWB
  -- wherein the Commits are appropriately handled
  --  ntungare
  --
  -- COMMIT;

  RETURN 'T';

 END update_parent;

  -- Bug 3536025. Adding a new procedure insert_history_auto_rec_QWB,which will be
  -- called from qltssreb.pls (Quality Workbench). This procedure is very much
  -- similar to insert_history_auto_rec ,except this procedure doesnot changes
  -- the child plan's txn_header_id and doesnot fire actions for child plans.
  -- srhariha. Wed May 26 22:31:28 PDT 2004

-- Bug 3681815.
-- Removing the old procedure insert_history_auto_rec_QWB with the new code
-- saugupta Tue, 15 Jun 2004 05:23:07 -0700 PDT
--This procedure is similar to the insert_history_auto_rec but is
--simplified for the needs of the SSQR post/update results processing.
--The primary differences are that this procedure is limited to a single
--parent row, the children have the same txn_header_id as the parent, and
--the results are not enabled/don't have actions fired.  This
--enabling/action firing is deferred to the ssqr_post_actions() method.
--Instead, this procedure checks for children using the criteria and then
--passes off to insert_automatic_records to actually create the child
--result rows and relationship rows.
--ilawler Thu Jun 10 17:24:08 2004

PROCEDURE insert_history_auto_rec_QWB(p_plan_id           IN NUMBER,
                                      p_collection_id     IN NUMBER,
                                      p_occurrence        IN NUMBER,
                                      p_organization_id   IN NUMBER,
                                      p_txn_header_id     IN NUMBER,
                                      p_relationship_type IN NUMBER,
                                      p_data_entry_mode   IN NUMBER,
                                      x_status       OUT NOCOPY VARCHAR2) IS

CURSOR child_check_cur(c_plan_id NUMBER) IS
       SELECT 'T'
       FROM qa_pc_plan_relationship
       WHERE parent_plan_id = c_plan_id
       AND plan_relationship_type = p_relationship_type
       AND data_entry_mode = p_data_entry_mode;

l_status          VARCHAR2(1);
l_criteria_values VARCHAR2(32000);
l_child_plan_ids  VARCHAR2(10000);

BEGIN
--sanity check, make sure this plan has relevant children
BEGIN
    OPEN child_check_cur(p_plan_id);
    FETCH child_check_cur INTO l_status;
    CLOSE child_check_cur;
EXCEPTION
    WHEN OTHERS THEN
    l_status := 'F';
END;

IF (l_status <> 'T' OR l_status is NULL) THEN
  -- no child plans with type and entry mode provided
  RETURN;
END IF;

--check plan's values against child plans' criteria to get a list of
--applicable children in l_child_plan_ids
get_criteria_values(p_parent_plan_id       => p_plan_id,
                    p_parent_collection_id => p_collection_id,
                    p_parent_occurrence    => p_occurrence,
                    p_organization_id      => p_organization_id,
                    x_criteria_values      => l_criteria_values);

l_status := evaluate_criteria(p_plan_id       => p_plan_id,
                              p_criteria_values   => l_criteria_values,
                              p_relationship_type => p_relationship_type,
                              p_data_entry_mode   => p_data_entry_mode,
                              x_child_plan_ids    => l_child_plan_ids);

IF (l_status = 'T') THEN

  --when evaluate_criteria returns T, we have children that need to be
  --created so call insert_automatic_records to do the grunt child row
  --creation.
  insert_automatic_records(p_plan_id           => p_plan_id,
                           p_collection_id      => p_collection_id,
                           p_occurrence         => p_occurrence,
                           p_child_plan_ids     => l_child_plan_ids,
                           p_relationship_type  => p_relationship_type,
                           p_data_entry_mode    => p_data_entry_mode,
                           p_criteria_values    => l_criteria_values,
                           p_org_id             => p_organization_id,
                           p_spec_id            => null,
                           x_status             => l_status,
                           p_txn_header_id      => p_txn_header_id);

  --make sure the insert_automatic succeeded
  IF (l_status <> 'T') THEN
    x_status := l_status;
    RETURN;
  END IF;
END IF;

--don't worry about firing actions, this is handled in
--ssqr_post_actions

x_status := 'T';
RETURN;

END insert_history_auto_rec_QWB;

-- The following procedure was added to remove the entry
-- from QA_PC_RESULTS_RELATIONSHIP table when the user
-- deletes the record from the child plan and saves the
-- child plan. This procedure is called from procedure
-- key_delete_dependent_rows in QLTRES.pld.
-- Bug 3646166.suramasw.

PROCEDURE DELETE_RELATIONSHIP_ROW(p_child_plan_id IN NUMBER,
                                  p_child_occurrence IN NUMBER) IS

BEGIN

      DELETE FROM  qa_pc_results_relationship
             WHERE child_plan_id = p_child_plan_id
             AND   child_occurrence = p_child_occurrence;

END;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- Function to delete a Result Row and and it's parent child relationship
  -- shkalyan 05/13/2005.
  FUNCTION delete_row(
      p_plan_id          IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_occurrence       IN         NUMBER,
      p_enabled          IN         NUMBER := NULL) RETURN VARCHAR2
  IS

    l_api_name        CONSTANT VARCHAR2(30)   := 'DELETE_ROW';
    l_parent_plan_id           NUMBER;
    l_parent_collection_id     NUMBER;
    l_parent_occurrence        NUMBER;

    l_return_status            VARCHAR2(1);

  -- Bug 4343758. OA Framework Integration project.
  -- Cursor to fetch relationship details.
  -- srhariha. Tue May 24 22:56:13 PDT 2005.

  CURSOR c1 IS
       SELECT  parent_plan_id,
               parent_collection_id,
               parent_occurrence
       FROM    QA_PC_RESULTS_RELATIONSHIP
       WHERE   child_plan_id = p_plan_id
       AND     child_collection_id = p_collection_id
       AND     child_occurrence = p_occurrence;

    agg_elements VARCHAR2(4000);
    agg_val     VARCHAR2(4000);

  BEGIN

    IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
       FND_LOG.string
       (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE: P_PLAN_ID: ' || p_plan_id || ' P_COLLECTION_ID: ' || p_collection_id || ' P_OCCURRENCE: ' || p_occurrence || ' P_ENABLED: ' || p_enabled
       );
    END IF;

    DELETE QA_RESULTS
    WHERE  occurrence = p_occurrence
    AND    plan_id = p_plan_id
    AND    collection_id = p_collection_id;

    IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'DELETED ROW IN QA RESULTS. GETTING PARENT'
        );
    END IF;

    -- Bug 4343758. Oa Framework Integration project.
    -- Use cursor to fetch relationship details.
    -- srhariha. Tue May 24 22:56:13 PDT 2005.
    l_parent_plan_id := null;

    OPEN C1;
    FETCH C1 INTO l_parent_plan_id,l_parent_collection_id,l_parent_occurrence;
    CLOSE C1;

    IF ( l_parent_plan_id IS NOT NULL ) THEN
      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE DELETING RELATIONSHIP ROW FOR CHILD'
        );
      END IF;

      delete_relationship_row
      (
        p_child_plan_id     => p_plan_id,
        p_child_occurrence  => p_occurrence
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE UPDATING PARENT FOR AGGREGATION PLAN_ID: ' || l_parent_plan_id || ' COLLECTION_ID: ' || l_parent_collection_id || ' OCCURRENCE: ' || l_parent_occurrence || ' FOR AGGREGATION '
        );
      END IF;

      -- 12.1 QWB Usability Improvements
      -- Added 2 new parameters to get a list of Aggregated elements
      -- and their values
      --
      l_return_status :=
      aggregate_parent
      (
        p_parent_plan_id       => l_parent_plan_id,
        p_parent_collection_id => l_parent_collection_id,
        p_parent_occurrence    => l_parent_occurrence,
        p_child_plan_id        => p_plan_id,
        p_child_collection_id  => TO_NUMBER( NULL ),
        p_child_occurrence     => TO_NUMBER( NULL ),
        p_commit               => 'F',
        x_agg_elements         => agg_elements,
        x_agg_val              => agg_val
      );
    END IF;

    IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
       FND_LOG.string
       (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
       );
    END IF;

    RETURN 'T';

  END delete_row;


   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.5, 4.9.6 and 4.9.7
   -- Modularization. Parent child API's must be defined in parent pkg.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

   --
   -- Parent-Child collections API. Operaters on collection of records.
   --


   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.10.1
   -- Using static SQL.
   -- srhariha. Thu Sep 29 00:09:40 PDT 2005.

PROCEDURE create_relationship_for_coll
                             ( p_parent_plan_id NUMBER,
                               p_parent_collection_id NUMBER,
                               p_parent_occurrence NUMBER,
                               p_child_plan_id NUMBER,
                               p_child_collection_id NUMBER,
                               p_org_id NUMBER) IS

 l_sql_string VARCHAR2(1000);

   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

  l_api_name CONSTANT VARCHAR2(40) := 'CREATE_RELATIONSHIP ()';

BEGIN
 INSERT INTO QA_PC_RESULTS_RELATIONSHIP (PARENT_PLAN_ID,
                                         PARENT_COLLECTION_ID,
                                         PARENT_OCCURRENCE,
                                         CHILD_PLAN_ID,
                                         CHILD_COLLECTION_ID,
                                         CHILD_OCCURRENCE,
                                         ENABLED_FLAG,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         LAST_UPDATE_LOGIN,
                                         CHILD_TXN_HEADER_ID)
                                  SELECT  p_parent_plan_id,
                                          p_parent_collection_id,
                                          p_parent_occurrence,
                                          QR.PLAN_ID,
                                          QR.COLLECTION_ID,
                                          QR.OCCURRENCE,
                                          2,
                                          SYSDATE,
                                          FND_GLOBAL.USER_ID,
                                          SYSDATE,
                                          FND_GLOBAL.USER_ID,
                                          FND_GLOBAL.USER_ID,
                                          QR.TXN_HEADER_ID
                                     FROM QA_RESULTS QR
                                    WHERE QR.PLAN_ID = p_child_plan_id
                                      AND QR.COLLECTION_ID = p_child_collection_id
                                      AND QR.ORGANIZATION_ID = p_org_id;


   EXCEPTION

      WHEN OTHERS THEN
       IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

        RAISE;

END create_relationship_for_coll;


PROCEDURE get_copy_result_cols(p_parent_plan_id NUMBER,
                               p_child_plan_id NUMBER,
                               x_parent_rc_str OUT NOCOPY VARCHAR2,
                               x_child_rc_str OUT NOCOPY VARCHAR2 ) IS

  CURSOR C IS
   SELECT qprc.parent_database_column,
          qprc.child_database_column
   FROM   qa_pc_result_columns_v qprc
  WHERE   qprc.parent_plan_id = p_parent_plan_id and
          qprc.child_plan_id = p_child_plan_id and
          qprc.element_relationship_type = 1 and
          parent_enabled_flag = 1 and
          child_enabled_flag = 1;

  p_rc DBMS_SQL.VARCHAR2_TABLE;
  c_rc DBMS_SQL.VARCHAR2_TABLE;


BEGIN

   OPEN C;
   FETCH C BULK COLLECT INTO p_rc,c_rc;
   CLOSE C;

   if(p_rc is null OR c_rc is null) then
    return;
   end if;


   FOR i IN p_rc.FIRST .. p_rc.LAST LOOP
     x_parent_rc_str := x_parent_rc_str || p_rc(i);
     x_child_rc_str :=  x_child_rc_str || c_rc(i);

     IF (i <> p_rc.LAST) THEN
       x_parent_rc_str := x_parent_rc_str || ', ';
       x_child_rc_str :=  x_child_rc_str || ', ';
     END IF;


   END LOOP;



END get_copy_result_cols;

PROCEDURE copy_from_parent_for_coll
                           (p_parent_plan_id NUMBER,
                            p_parent_collection_id NUMBER,
                            p_parent_occurrence NUMBER,
                            p_child_plan_id NUMBER,
                            p_child_collection_id NUMBER,
                            p_org_id NUMBER) IS

 l_sql_string VARCHAR2(32000);
 l_src_string VARCHAR2(32000);
 l_dest_string VARCHAR2(32000);
   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

 l_api_name CONSTANT VARCHAR2(40) := 'COPY_FROM_PARENT_FOR_COLL';
BEGIN

  -- get parent and child result column names
  get_copy_result_cols(p_parent_plan_id => p_parent_plan_id,
                       p_child_plan_id => p_child_plan_id,
                       x_parent_rc_str => l_src_string,
                       x_child_rc_str => l_dest_string);

  l_sql_string := ' UPDATE QA_RESULTS   '  ||
                  '  SET (  ' || l_dest_string || ' ) = ' ||
                 ' ( SELECT ' || l_src_string || ' ' ||
                  '  FROM QA_RESULTS QR1       ' ||
                  '  WHERE QR1.PLAN_ID = :1    ' ||
                  '  AND QR1.COLLECTION_ID = :2' ||
                  '  AND QR1.OCCURRENCE = :3)  ' ||
                ' WHERE PLAN_ID = :4 '       ||
                ' AND COLLECTION_ID = :5  ';

  EXECUTE IMMEDIATE l_sql_string USING p_parent_plan_id,
                                       p_parent_collection_id,
                                       p_parent_occurrence,
                                       p_child_plan_id,
                                       p_child_collection_id;

   EXCEPTION

      WHEN OTHERS THEN
       IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

        RAISE;
END copy_from_parent_for_coll;

   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.10.2
   -- Rewriting the logic based on new interesting algo
   -- suggested by Bryan.
   -- srhariha. Thu Sep 29 00:09:40 PDT 2005.

 PROCEDURE create_history_for_coll (
             p_plan_id NUMBER,
             p_collection_id NUMBER,
             p_org_id NUMBER,
             p_txn_header_id NUMBER) IS

 l_sql_string VARCHAR2(32000);


 CURSOR c(x_plan_id NUMBER) IS
   SELECT child_plan_id
   FROM qa_pc_plan_relationship
   WHERE parent_plan_id = x_plan_id
   AND data_entry_mode = 4;

 l_src_string VARCHAR2(32000);
 l_dest_string VARCHAR2(32000);
   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

 l_api_name CONSTANT VARCHAR2(40) := 'CREATE_HISTORY';

 BEGIN

    -- get history plan id

    FOR hst_rec IN c(p_plan_id) LOOP

      INSERT INTO QA_PC_RESULTS_RELATIONSHIP (
                     PARENT_PLAN_ID,
                     PARENT_COLLECTION_ID,
                     PARENT_OCCURRENCE,
                     CHILD_PLAN_ID ,
                     CHILD_COLLECTION_ID,
                     CHILD_OCCURRENCE,
                     ENABLED_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY ,
                     LAST_UPDATE_LOGIN,
                     CHILD_TXN_HEADER_ID)
              SELECT QR.PLAN_ID,
                     QR.COLLECTION_ID,
                     QR.OCCURRENCE,
                     hst_rec.child_plan_id,
                     p_collection_id,
                     QA_OCCURRENCE_S.NEXTVAL,
                     2,
                     SYSDATE,
                     FND_GLOBAL.USER_ID,
                     SYSDATE,
                     FND_GLOBAL.USER_ID,
                     FND_GLOBAL.USER_ID,
                     p_txn_header_id
                FROM QA_RESULTS QR
               WHERE QR.PLAN_ID = p_plan_id
                 AND QR.COLLECTION_ID = p_collection_id
                 AND QR.ORGANIZATION_ID = p_org_id;



      -- get parent and child result column names
      get_copy_result_cols(p_parent_plan_id => p_plan_id,
                           p_child_plan_id => hst_rec.child_plan_id,
                           x_parent_rc_str => l_src_string,
                           x_child_rc_str => l_dest_string);


    l_sql_string := ' INSERT INTO qa_results (     collection_id, ' ||
                                                '  occurrence,  ' ||
                                                '  last_update_date, ' ||
                                                '  qa_last_update_date, '||
                                                '  last_updated_by, ' ||
                                                '  qa_last_updated_by, ' ||
                                                '  creation_date,  ' ||
                                                '  qa_creation_date, ' ||
                                                '  created_by, ' ||
                                                '  last_update_login, ' ||
                                                '  qa_created_by, ' ||
                                                '  status, ' ||
                                                '  transaction_number, ' ||
                                                '  organization_id, ' ||
                                                '  plan_id, ' ||
                                                '  txn_header_id, ' ||
                                                l_dest_string || ')' ||
                                        ' SELECT   QPRR.CHILD_COLLECTION_ID,  ' ||
                                             '     QPRR.CHILD_OCCURRENCE, ' ||
                                             '     sysdate, ' ||
                                             '     sysdate, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     sysdate, ' ||
                                             '     sysdate, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     2, ' ||
                                             '     -1, ' ||
                                             '     QR.ORGANIZATION_ID, ' ||
                                             '     QPRR.CHILD_PLAN_ID, ' ||
                                             '     QPRR.CHILD_TXN_HEADER_ID,  ' ||
                                             l_src_string || ' ' ||
                                       ' FROM  QA_RESULTS QR, QA_PC_RESULTS_RELATIONSHIP QPRR ' ||
                                       ' WHERE QPRR.CHILD_PLAN_ID = :1 ' ||
                                       ' AND QPRR.CHILD_COLLECTION_ID = :2 ' ||
                                       ' AND QPRR.PARENT_PLAN_ID = :3 ' ||
                                       ' AND QPRR.PARENT_COLLECTION_ID = :4 ' ||
                                       ' AND QPRR.PARENT_OCCURRENCE = QR.OCCURRENCE ';

    EXECUTE IMMEDIATE l_sql_string USING hst_rec.child_plan_id,
                                         p_collection_id,
                                         p_plan_id,
                                         p_collection_id;



  END LOOP; -- hst_rec

     EXCEPTION

      WHEN OTHERS THEN
       IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

        RAISE;


 END create_history_for_coll;


 -- Bug 4502450. R12 Esig Status support in Multirow UQR
 -- saugupta Wed, 24 Aug 2005 08:40:56 -0700 PDT

 -- Function returns only all ancestors i.e parent and grandparent plan rows
 -- for a given child plan and does not retrun child itself.
 FUNCTION get_ancestors( p_child_plan_id IN NUMBER,
                          p_child_occurrence IN NUMBER,
                          p_child_collection_id IN NUMBER,
                          x_parent_plan_ids          OUT NOCOPY dbms_sql.number_table,
                          x_parent_collection_ids    OUT NOCOPY dbms_sql.number_table,
                          x_parent_occurrences       OUT NOCOPY dbms_sql.number_table)
 RETURN VARCHAR2
 IS

 BEGIN
      -- check for NULL values
      IF( p_child_plan_id IS NULL OR
          p_child_occurrence IS NULL OR
          p_child_collection_id IS NULL) THEN
          -- return False
          RETURN 'F';
      END IF;

      -- Given a child occurrence this query finds all the parents
      -- and grandparent records, therefore ancestors, of the child record.
      -- These are returned in the three output PL/SQL tables.
      -- The child record itself is not included in the output.
      SELECT parent_plan_id, parent_collection_id, parent_occurrence
      BULK COLLECT INTO x_parent_plan_ids, x_parent_collection_ids, x_parent_occurrences
      FROM qa_pc_results_relationship
      START WITH child_plan_id = p_child_plan_id
            AND child_occurrence = p_child_occurrence
            AND child_collection_id = p_child_collection_id
      CONNECT BY PRIOR  parent_occurrence = child_occurrence;

      IF (SQL%FOUND) THEN
        RETURN 'T';
      ELSE
        RETURN 'F';
      END IF;


 END get_ancestors;

 --
 -- Bug 5435657
 -- New procedure to update the Aggregate values on
 -- all the ancestors of the plan_id passed, in case
 -- such a P-C relationship exists
 -- ntungare Wed Aug  2 20:53:40 PDT 2006
 --
 PROCEDURE update_all_ancestors(p_parent_plan_id       IN NUMBER,
                                p_parent_collection_id IN NUMBER,
                                p_parent_occurrence    IN NUMBER) IS

     l_parent_plan_id_tab       DBMS_SQL.NUMBER_TABLE;
     l_parent_collection_id_tab DBMS_SQL.NUMBER_TABLE;
     l_parent_occurrence_tab    DBMS_SQL.NUMBER_TABLE;

     l_current_child_planid   NUMBER;
     l_current_child_collid   NUMBER;
     l_current_child_occrid   NUMBER;
     l_current_parent_planid  NUMBER;
     l_current_parent_collid  NUMBER;
     l_current_parent_occrid  NUMBER;

 BEGIN
     -- Calling the function get_ancestors to get a
     -- List of the Ancestors if they exist
     IF ( QA_PARENT_CHILD_PKG.get_ancestors(
             p_parent_plan_id,
             p_parent_occurrence,
             p_parent_collection_id,
             l_parent_plan_id_tab,
             l_parent_collection_id_tab,
             l_parent_occurrence_tab) = 'T') THEN

       l_current_child_planid := p_parent_plan_id;
       l_current_child_collid := p_parent_collection_id;
       l_current_child_occrid := p_parent_occurrence;

       -- Ancestors exist for the plan_id passed so
       -- Need to check if an aggregate P-C relationship
       -- exists and do the aggregation
       -- Looping through all the ancestors
       For ancestors_cntr in 1..l_parent_plan_id_tab.COUNT
         LOOP
            l_current_parent_planid := l_parent_plan_id_tab(ancestors_cntr);
            l_current_parent_collid := l_parent_collection_id_tab(ancestors_cntr);
            l_current_parent_occrid := l_parent_occurrence_tab(ancestors_cntr);

            -- Calling the procedure to check for aggregate relationships
            -- and do the agrregation
            IF(QA_PARENT_CHILD_PKG.update_parent
                            (l_current_parent_planid,
                             l_current_parent_collid,
                             l_current_parent_occrid,
                             l_current_child_planid,
                             l_current_child_collid,
                             l_current_child_occrid)='T')
            THEN
               NULL;
            END IF;

            -- Assigning the Current Parrent plan Id, Collection Id
            -- and the occurrences as the Child plan Plan id,
            -- Collcetion Id and occurrences, for the next round of
            -- processing of the ancestors collection
            --
            l_current_child_planid := l_current_parent_planid;
            l_current_child_collid := l_current_parent_collid;
            l_current_child_occrid := l_current_parent_occrid;
         END LOOP; -- End of Ancestors Loop

     END If; -- End of If ancestors Found
 END update_all_ancestors;

 --
 -- bug 6134920
 -- Added a new procedure to delete all the status
 -- 1 invalid child records, generated during an
 -- incomplete txn
 -- ntungare Tue Jul 10 23:08:22 PDT 2007
 --
 PROCEDURE delete_invalid_children(p_txn_header_id IN NUMBER) IS
     PRAGMA AUTONOMOUS_TRANSACTION;

     TYPE child_plan_id_tab_typ IS TABLE OF qa_pc_results_relationship.child_plan_id%TYPE
                                                                 INDEX BY BINARY_INTEGER;
     TYPE child_collection_id_tab_typ IS TABLE OF qa_pc_results_relationship.child_collection_id%TYPE
                                                                 INDEX BY BINARY_INTEGER;
     TYPE child_occurrence_tab_typ IS TABLE OF qa_pc_results_relationship.child_occurrence%TYPE
                                                                 INDEX BY BINARY_INTEGER;

     child_plan_id_tab       child_plan_id_tab_typ;
     child_collection_id_tab child_collection_id_tab_typ;
     child_occurrence_tab    child_occurrence_tab_typ;

 BEGIN
     DELETE FROM qa_results
       WHERE txn_header_id = p_txn_header_id
         AND status        = 1
     RETURNING plan_id, collection_id, occurrence
       BULK COLLECT INTO child_plan_id_tab,
                         child_collection_id_tab,
                         child_occurrence_tab;

     FORALL cntr in 1..child_plan_id_tab.COUNT
       DELETE from qa_pc_results_relationship
         WHERE child_txn_header_id = p_txn_header_id
           AND child_plan_id       = child_plan_id_tab(cntr)
           AND child_collection_id = child_collection_id_tab(cntr)
           AND child_occurrence    = child_occurrence_tab(cntr);

     COMMIT;
 END delete_invalid_children;

-- 12.1 QWB Usability Improvements
-- New method to check if a Parent Plan record
-- has any applicable child plan into which data can be
-- entered.
--
FUNCTION has_enterable_child(p_plan_id in number,
                             p_collection_id in number,
                             p_occurrence in number)
 RETURN varchar2 as
   TYPE plan_det IS RECORD (char_id      varchar2(200),
                            res_col_name varchar2(200)) ;

   TYPE res_col_tab_typ IS TABLE OF plan_det INDEX BY binary_integer;
   res_col_tab res_col_tab_typ;
   str varchar2(32767);
   result_string varchar2(32767);
   -- Bug 9382356
   -- New variable to hold the result string for Comments type elements.
   -- skolluku
   comments_result_string varchar2(4000);
   plans qa_txn_grp.ElementsArray;

   cntr NUMBER;
BEGIN
   -- Getting the list of the result_column_names from the
   -- qa_plan_chars table
   SELECT char_id, result_column_name
    BULK COLLECT INTO res_col_tab
   FROM qa_plan_chars
    WHERE plan_id = p_plan_id;

   -- building the select query
   FOR cntr in 1..res_col_tab.count
     LOOP
       -- Bug 9382356
       -- Do this loop only for Non-Comments type elements. Comments processing comes later.
       -- skolluku
       IF res_col_tab(cntr).res_col_name NOT LIKE 'COMMENT%' THEN
        str := res_col_tab(cntr).char_id ||
	       '=''||REPLACE('||res_col_tab(cntr).res_col_name||
               ',''@'',''@@'')||''@'||str;
       END IF;
     END LOOP;
   str := rtrim(str, '||''@');

   -- Use the columns list built above to query
   -- qa_results table, to build the result_string
   -- Bug 9382356
   -- Added NULL check as this would error out in case there
   -- is only COMMENTS element in the plan.
   -- skolluku
   IF str IS NOT NULL THEN
   EXECUTE IMMEDIATE
   'Select '''||str||
   ' from qa_results where plan_id = :plan_id  and
          collection_id = :collection_id and
          occurrence = :occurrence'
     INTO result_string USING p_plan_id,
                              p_collection_id ,
                              p_occurrence;
    END IF;
    -- Bug 9382356
    -- Iterating through the loop again. This time only Comments elements will be picked.
    -- If present, the result string for the Comments element is created and appended to
    -- the existing result string. This had to be done, as if the result string is greater
    -- than 4000 in case there are Comments elements, the Execute Immediate fails, due to
    -- SQL limitation.
    -- skolluku
    FOR cntr in 1..res_col_tab.count
     LOOP
       IF res_col_tab(cntr).res_col_name LIKE 'COMMENT%' THEN
           str := res_col_tab(cntr).char_id ||
	              '=''||REPLACE('||res_col_tab(cntr).res_col_name||
                  ',''@'',''@@'')';
           EXECUTE IMMEDIATE
               'Select '''||str||
               ' from qa_results where plan_id = :plan_id  and
                 collection_id = :collection_id and
                 occurrence = :occurrence'
           INTO comments_result_string USING p_plan_id,
                                             p_collection_id ,
                                             p_occurrence;
           IF result_string IS NOT NULL THEN
              result_string := result_string || '@' || comments_result_string;
           ELSE
              result_string := comments_result_string;
           END IF;
       END IF;
    END LOOP;

   -- Pass the result string to the applicable_child_plans
   -- to get a list of applicable Child plans for the entered data
   -- and convert the list of plans returned as a string
   -- into an array
   plans :=  qa_txn_grp.result_to_array(
                qa_parent_child_pkg.applicable_child_plans(p_plan_id,
                                                           result_string));

   cntr := plans.first;

   -- looping through the child plans list to check
   -- if there is any non History child plan
   WHILE cntr <= plans.LAST
    LOOP
      IF plans(cntr).VALUE <>4
        THEN RETURN 'CHILD_Y';
      END IF;
      cntr := plans.next(cntr);
    END LOOP;
    RETURN 'CHILD_N';
END has_enterable_child;

-- 12.1 QWB Usability Improvements
-- New method to check if there aare any updatable child records
--
FUNCTION child_exists_for_update(p_plan_id       IN NUMBER,
                                 p_collection_id IN NUMBER,
                                 p_occurrence    IN NUMBER)
  RETURN VARCHAR2 AS
  --
  -- removed the Immediate plans check
  -- ntungare
  --
  CURSOR cur is
     select 'UPDATE_CHILD_Y'
       from qa_pc_results_relationship qpc,
            qa_results qr,
            qa_pc_plan_relationship qpr
       where qpc.parent_plan_id = p_plan_id             and
             qpc.parent_collection_id = p_collection_id and
             qpc.parent_occurrence  = p_occurrence      and
             qpc.child_plan_id = qr.plan_id             and
             qpc.child_collection_id = qr.collection_id and
             qpc.child_occurrence = qr.occurrence       and
             (qr.status = 2 or qr.status is NULL)       and
             qpr.parent_plan_id = p_plan_id             and
             qpr.child_plan_id = qpc.child_plan_id      and
             qpr.data_entry_mode  <> 4                  and
             qa_web_txn_api.allowed_for_plan('QA_RESULTS_UPDATE', qpc.child_plan_id) = 'T';
             --rownum =1;

  has_child VARCHAR2(100) :='UPDATE_CHILD_N';
BEGIN
  /*
    This procedure has a bit of a complexity in the form that if the
    Criteria defined for the P-C relationship is changed later, then
    the child data that has already been collected would be no longer
    be applicable, in which case the child records though present in
    the relationship table should be ignored. For this we need to
    make a call to the "has_enterable" procedure to check for the
    applicable children, which would be a severe overhead. A better
    way is to prevent the user from changing the criteria if Child
    records that match the criteria have already been collected.
  */
  OPEN cur;
  FETCH cur INTO has_child;
  CLOSE cur;

  RETURN has_child;
END child_exists_for_update;

-- 12.1 QWB usability Improvements
-- New method to get a count of child records
-- present for any parent plan record
--
FUNCTION getChildCount(p_plan_id       IN NUMBER,
                       p_collection_id IN NUMBER,
                       p_occurrence    IN NUMBER)
  RETURN NUMBER AS

  childCount NUMBER := 0;
BEGIN
  SELECT count(*) INTO childCount
   FROM qa_pc_results_relationship qpc,
        qa_results qr
   WHERE qpc.parent_plan_id = p_plan_id             and
         qpc.parent_collection_id = p_collection_id and
         qpc.parent_occurrence  = p_occurrence      and
         qpc.child_plan_id = qr.plan_id             and
         qpc.child_collection_id = qr.collection_id and
         qpc.child_occurrence = qr.occurrence       and
        (qr.status = 2 or qr.status is NULL);

  RETURN childCount;
end getChildCount;

-- 12.1 Quality Inline Transaction INtegration
-- New method to identify whether a plan has
-- child plans associated with it or not
--
FUNCTION has_child(p_plan_id IN NUMBER)
  RETURN INTEGER AS

  childCount NUMBER;
BEGIN
  SELECT count(*) INTO childCount
   FROM qa_pc_plan_relationship
   WHERE parent_plan_id=p_plan_id;
  IF childCount > 0 THEN
    RETURN 1;
  ELSE
    RETURN 2;
  END IF;
END has_child;

-- 12.1 QWB Usability Improvements project
-- Function to update all the History
-- Child records corresponding to a parent record
FUNCTION update_hist_children(p_parent_plan_id IN NUMBER,
                       p_parent_collection_id IN NUMBER,
                       p_parent_occurrence IN NUMBER)
        RETURN VARCHAR2 IS

  l_return_value  VARCHAR2(1);
  l_dummy VARCHAR2(1);

  CURSOR children_cur IS
        select qprr.child_plan_id,
               qprr.child_collection_id,
               qprr.child_occurrence
        from   qa_pc_results_relationship qprr,
               qa_pc_plan_relationship    qpr
        where  qprr.parent_occurrence = p_parent_occurrence
        and    qprr.parent_plan_id = p_parent_plan_id
        and    qprr.parent_collection_id = p_parent_collection_id
        and    qpr.parent_plan_id = qprr.parent_plan_id
        and    qpr.child_plan_id = qprr.child_plan_id
        and    qpr.data_entry_mode = 4;

BEGIN
    l_return_value := 'T';
    l_dummy := 'T';

        FOR children_rec IN children_cur
        LOOP
           l_return_value :=
                  update_child (  p_parent_plan_id,
                          p_parent_collection_id,
                          p_parent_occurrence,
                          children_rec.child_plan_id,
                          children_rec.child_collection_id,
                          children_rec.child_occurrence);
        END LOOP;

        RETURN l_return_value;
END update_hist_children;

-- Bug 7436465.FP for Bug 7035041.pdube Fri Sep 26 03:46:20 PDT 2008
-- Inroduced this procedure to check if any child record exists for parent record.
FUNCTION IF_CHILD_RECORD_EXISTS( p_plan_id IN NUMBER,
                                 p_collection_id IN NUMBER,
                                 p_occurrence IN NUMBER) RETURN result_column_name_tab_typ IS
  result_column_name_tab result_column_name_tab_typ;
BEGIN
  SELECT REPLACE(DECODE(QC.HARDCODED_COLUMN, NULL ,QAPC.RESULT_COLUMN_NAME,QC.DEVELOPER_NAME),
                        'CHARACTER','DISPLAY') FORM_FIELD
       BULK COLLECT INTO  result_column_name_tab
  FROM qa_pc_plan_relationship qppr,
       qa_pc_criteria qpc,
       qa_results qr,
       qa_plan_chars qapc,
       qa_chars qc
  WHERE qpc.plan_relationship_id = qppr.plan_relationship_id
  AND   qapc.char_id = qpc.char_id
  AND   qapc.char_id = qc.char_id
  AND   qr.occurrence =  p_occurrence
  AND   qr.collection_id = p_collection_id
  AND   qr.plan_id = p_plan_id
  AND   qr.plan_id = qapc.plan_id
  AND   qppr.parent_plan_id = qr.plan_id
  AND EXISTS
 (SELECT 1 FROM
   qa_pc_results_relationship qprr
   WHERE qppr.child_plan_id = qprr.child_plan_id
   AND   qppr.parent_plan_id = qprr.parent_plan_id
   AND   qppr.child_plan_id = qprr.child_plan_id
   AND  qprr.parent_plan_id = qr.plan_id
   AND  qprr.parent_collection_id = p_collection_id
   AND  qprr.parent_occurrence = p_occurrence
   AND  qprr.parent_plan_id = p_plan_id
   AND  ROWNUM = 1);

   RETURN result_column_name_tab;
 EXCEPTION
    WHEN OTHERS THEN
    RAISE;
    RETURN result_column_name_tab;
 END IF_CHILD_RECORD_EXISTS;

END  QA_PARENT_CHILD_PKG;

/
