--------------------------------------------------------
--  DDL for Package Body QA_TXN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_TXN_GRP" AS
/* $Header: qagtxnb.pls 120.13.12010000.4 2009/11/12 07:21:51 pdube ship $ */

-- Bug 4343758
-- R12 OAF Txn Integration Project
-- Standard Global variable
-- shkalyan 05/07/2005.
g_pkg_name      CONSTANT VARCHAR2(30)   := 'QA_TXN_GRP';

FUNCTION qa_enabled(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER) RETURN VARCHAR2 IS

    l_txn_id    NUMBER;
    l_status   VARCHAR2(1);
    l_industry VARCHAR2(10);
    l_schema   VARCHAR2(30);
    dummy BOOLEAN;

    CURSOR txn_plans IS
        SELECT  /*+ ordered use_nl(qp) */ qpt.plan_transaction_id
        FROM    qa_plan_transactions qpt,
                qa_plans qp
        WHERE   qpt.transaction_number = p_txn_number AND
                qpt.plan_id = qp.plan_id AND
                qpt.enabled_flag = 1 AND
                qp.organization_id = p_org_id AND
                trunc(sysdate) BETWEEN
                    nvl(trunc(qp.effective_from), trunc(sysdate)) AND
                    nvl(trunc(qp.effective_to), trunc(sysdate));

BEGIN
    IF p_txn_number = txn_number_cache AND p_org_id = org_id_cache THEN
        RETURN qa_enabled_cache;
    END IF;

    txn_number_cache := p_txn_number;
    org_id_cache := p_org_id;

    qa_enabled_cache := 'F';
    dummy := fnd_installation.get_app_info('QA', l_status,
        l_industry, l_schema);
    IF l_status IN ('I', 'S') THEN
        OPEN txn_plans;
        FETCH txn_plans INTO l_txn_id;
        IF txn_plans%FOUND THEN
            qa_enabled_cache := 'T';
        END IF;
        CLOSE txn_plans;
    END IF;

    RETURN qa_enabled_cache;
END qa_enabled;



--------------------
FUNCTION commit_allowed(
    p_txn_number IN VARCHAR2,
    p_org_id IN NUMBER,
    p_plan_txn_ids IN VARCHAR2,
    p_collection_id IN NUMBER,
    x_plan_ids OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    l_plan_list VARCHAR2(5000) DEFAULT NULL;
    l_plan_id NUMBER;

    select_stmt VARCHAR2(10000);

    TYPE result_cursor IS REF CURSOR;
    c_plans_results result_cursor;

BEGIN
/*
Bug: 2345277
rkaza: 05/06/2002. return true if there are no applicable plans.
Otherwise the sql statement
qpt.plan_transaction_id IN ( )
would error out.
*/
    If p_plan_txn_ids is null then
	return 'T';
    End if;
   -- Bug 4270911. CU2 SQL Literal fix. TD #20
   -- Add p_plan_txn_ds into temp table and rewrite the
   -- query to select the id from it.
   -- srhariha. Mon Apr 18 03:52:46 PDT 2005.

  qa_performance_temp_pkg.purge_and_add_ids('QAGTXNB.COMMIT_ALLOWED', p_plan_txn_ids);


    select_stmt :=
        'SELECT DISTINCT qpt.plan_id' ||
        ' FROM qa_plan_transactions qpt' ||
        ' WHERE qpt.plan_transaction_id IN ' ||
                                      '( SELECT id FROM qa_performance_temp ' ||
                                      ' WHERE key=''QAGTXNB.COMMIT_ALLOWED'' ) '||
        ' AND qpt.enabled_flag = 1' ||
        ' AND qpt.mandatory_collection_flag = 1' ||
        ' AND qpt.background_collection_flag = 2' ||
        ' AND NOT EXISTS' ||
        ' (SELECT 1' ||
        '  FROM   qa_results qr ' ||
        '  WHERE  qr.plan_id = qpt.plan_id ' ||
        '  AND qr.collection_id = :c)';

    OPEN c_plans_results FOR select_stmt USING p_collection_id;
    LOOP
        FETCH c_plans_results INTO l_plan_id;
        EXIT WHEN c_plans_results%NOTFOUND;
        l_plan_list := l_plan_list || ',' || l_plan_id;
    END LOOP;
    CLOSE c_plans_results;

    IF l_plan_list IS NOT NULL THEN
       x_plan_ids := substr(l_plan_list, 2);
       RETURN 'F';
    END IF;

    RETURN 'T';
END commit_allowed;


--------------------
FUNCTION get_collection_id RETURN NUMBER IS

   l_coll_id NUMBER;

BEGIN
   SELECT qa_collection_id_s.nextval INTO l_coll_id FROM dual;
   RETURN l_coll_id;
END get_collection_id;

---------------------------------------------------


FUNCTION parse_id(x_result IN VARCHAR2, n IN INTEGER,
    p IN INTEGER, q IN INTEGER) RETURN NUMBER IS
BEGIN
    RETURN to_number(substr(x_result, p, q-p));
END parse_id;


FUNCTION parse_value(x_result IN VARCHAR2, n IN INTEGER,
    p IN OUT NOCOPY INTEGER) RETURN VARCHAR2 IS

    -- changed the variable type from qa_results.character1%TYPE to
    -- qa_results.comment1%TYPE for LongComments Project
    -- Bug 2234299
    -- rponnusa Thu Mar 14 05:33:00 PST 2002

/*
Bug: 2369332
rkaza: 05/10/2002. Changing type comment to varchar2(2000) to
avoid dependencies on case changes for long comments.
*/
    -- value qa_results.comment1%TYPE := '';
    value varchar2(2000) := '';
    c VARCHAR2(10);
    separator CONSTANT VARCHAR2(1) := '@';

BEGIN
    --
    -- Loop until a single @ is found or x_result is exhausted.
    --
    p := p + 1;                   -- add 1 before substr to skip '='
    WHILE p <= n LOOP
        c := substr(x_result, p, 1);
        p := p + 1;
        IF (c = separator) THEN
            IF substr(x_result, p, 1) <> separator THEN
            --
            -- take a peak at the next character, if not another @,
            -- we have reached the end.  Otherwise, skip this @
            --
                RETURN value;
            ELSE
                p := p + 1;
            END IF;
        END IF;
        value := value || c;
    END LOOP;

    RETURN value;
END parse_value;


FUNCTION result_to_array(x_result IN VARCHAR2)
    RETURN ElementsArray IS

    elements ElementsArray;
    n INTEGER := length(x_result);
    p INTEGER;            -- starting string position
    q INTEGER;            -- ending string position
    x_char_id NUMBER;

     -- changed the variable type from qa_results.character1%TYPE to
     -- qa_results.comment1%TYPE for LongComments Project
     -- Bug 2234299
     -- rponnusa Thu Mar 14 05:33:00 PST 2002

/*
Bug: 2369332
rkaza: 05/10/2002. Changing type comment to varchar2(2000) to
avoid dependencies on case changes for long comments.
*/
    -- x_value qa_results.comment1%TYPE;
    x_value varchar2(2000);

BEGIN
    p := 1;
    WHILE p < n LOOP
        q := instr(x_result, '=', p);
        --
        -- found the first = sign.  To the left, must be char_id
        --
        x_char_id := parse_id(x_result, n, p, q);
        --
        -- To the right, must be the value
        --
        x_value := parse_value(x_result, n, q);
        elements(x_char_id).value := x_value;
        p := q;
    END LOOP;

    RETURN elements;
END result_to_array;

--
-- Bug 4995406
-- Added a new function to convert the
-- Normalized Ids passed by the EAM
-- transactions into the denormalized values
-- ntungare Wed Feb 22 06:52:41 PST 2006
--
-- Bug 5279941
-- Modified the function to a Proceudre
-- the array that was being returned has now
-- been defined as an IN OUT param
-- ntungare Wed Jun 21 02:09:36 PDT 2006
--
PROCEDURE eam_denormalize_array(x_normalized_id_array IN OUT NOCOPY ElementsArray,
                                x_Org_Id              IN NUMBER)
    IS
BEGIN
    --
    -- Bug 5279941
    -- Denormalizing the Asset Group
    -- ntungare
    --
    If x_normalized_id_array.exists(qa_ss_const.asset_group) THEN
       x_normalized_id_array(qa_ss_const.asset_group).value := QA_FLEX_UTIL.ITEM
                                                                (x_org_id,
                                                                 x_normalized_id_array(qa_ss_const.asset_group).value);
    End If;

    --
    -- Bug 5279941
    -- Denormalizing the Asset Activity
    -- ntungare
    --
    If x_normalized_id_array.exists(qa_ss_const.asset_activity) THEN
       x_normalized_id_array(qa_ss_const.asset_activity).value :=
                                                               QA_FLEX_UTIL.ITEM
                                                                (x_org_id,
                                                                 x_normalized_id_array(qa_ss_const.asset_activity).value);
    End If;

    --
    -- Bug 5279941
    -- Denormalizing the Asset Instance Number
    -- ntungare
    --
    If x_normalized_id_array.exists(qa_ss_const.asset_instance_number) THEN
       x_normalized_id_array(qa_ss_const.asset_instance_number).value :=
                                                               QA_FLEX_UTIL.GET_ASSET_INSTANCE_NAME
                                                                (x_normalized_id_array(qa_ss_const.asset_instance_number).value);
    End If;

END eam_denormalize_array;

FUNCTION triggers_matched(p_plan_txn_id IN NUMBER, elements ElementsArray)
RETURN VARCHAR2 IS

BEGIN

    FOR plan_record in (
        SELECT qpct.operator,
               qpct.Low_Value,
               qpct.High_Value ,
               qc.datatype,
               qc.char_id
        FROM   qa_plan_collection_triggers qpct,
               qa_chars qc
        WHERE  qpct.Collection_Trigger_ID = qc.char_id and
               qpct.plan_transaction_id = p_plan_txn_id) LOOP

        IF NOT elements.EXISTS(plan_record.char_id) THEN
            RETURN 'F';
        END IF;

        /*
          Added NVL condition for the IF condition below to handle the
          condition when null is returned by qltcompb.compare.Before
          the fix if qltcompb.compare returns null then the following
          condition is not satisfied and True is returned which is not
          correct.Take for Eg., elements(plan_record.char_id).value is
          Null and plan_record.Low_Value has the value 'Test' and
          plan_record.operator is 1(equals) then qltcompb.compare will
          return Null and because of that the following call fails. If
          Null is retruned then it has to be considered as False.
          Bug 3810082. suramasw.
        */

        IF NOT (NVL(qltcompb.compare(
            elements(plan_record.char_id).value,
            plan_record.operator,
            plan_record.Low_Value,
            plan_record.High_Value,
            plan_record.datatype),FALSE)) THEN
            RETURN 'F';
        END IF;

    END LOOP;

    RETURN 'T';
END triggers_matched;


FUNCTION evaluate_triggers(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_context_values IN VARCHAR2,
    x_plan_txn_ids OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    elements ElementsArray;
    plan_txn_list VARCHAR2(10000);

    --
    -- Bug 8744187
    -- The following 3 variables would be used to fetch
    -- the item category.
    -- skolluku
    --
    p_item varchar2(100);
    p_category varchar2(1000);
    p_category_id varchar2(1000);

BEGIN
    elements := result_to_array(p_context_values);
    -- Bug 9098649.pdube
    -- Included this if condition to avoid unnecessary no_data_found
    -- exceptions for EAM transacitons where item is not context.
    -- Also, setting the value only when category is null.
    IF (elements.EXISTS(10) AND
       elements(10).value IS NOT NULL) THEN
        IF (NOT elements.EXISTS(11) OR
           (elements.EXISTS(11) AND
           elements(11).value IS NULL)) THEN
            --
            -- Bug 8744187
            -- Fetch the item category using the procedure
            -- from qa_ss_core and assign it to elements(11)
            -- which is not populated from the parent transaction.
            -- skolluku
            --
            p_item := elements(10).value;
            qa_ss_core.get_item_category_val(
                      p_org_id => p_org_id,
                      p_item_val => p_item,
                      x_category_val => p_category,
                      x_category_id => p_category_id);
            elements(11).value := p_category;
         END IF;
    END IF;
/*
Bug: 2345277
rkaza: 05/06/2002. Added date restriction for the applicable
collection plans.
*/
    FOR pt IN (
        SELECT qpt.plan_transaction_id
        FROM   qa_plan_transactions qpt, qa_plans qp
        WHERE  qpt.transaction_number = p_txn_number
        AND    qpt.plan_id = qp.plan_id
        AND    qp.organization_id = p_org_id
        AND    trunc(sysdate) between
		nvl(trunc(qp.effective_from), trunc(sysdate)) and
		nvl(trunc(qp.effective_to), trunc(sysdate))
        AND    qpt.enabled_flag = 1) LOOP

        IF triggers_matched(pt.plan_transaction_id, elements) = 'T' THEN
            plan_txn_list := plan_txn_list || ',' || pt.plan_transaction_id;
        END IF;

    END LOOP;

    IF plan_txn_list IS NOT NULL THEN
        x_plan_txn_ids := substr(plan_txn_list, 2);
        RETURN 'T';
    END IF;

    RETURN 'F';
END evaluate_triggers;

-- bug 4995406
-- New procedure to evaluate the Transaction
-- triggers on the Context elements for
-- EAM Transactions and Insert the results
-- for the applicable Plans
-- ntungare Wed Feb 22 06:52:59 PST 2006
--
PROCEDURE evaltriggers_InsertRes_eamtxn(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_context_values IN VARCHAR2,
    p_plans_tab IN QA_PARENT_CHILD_PKG.ChildPlanArray,
    p_collection_id  IN NUMBER) IS

    elements            ElementsArray;
    denormalized_values ElementsArray;
    plan_txn_id         NUMBER;

    --
    -- Bug 5335509
    -- Variable to get the return status of the Seq
    -- generation procedure
    -- ntungare Tue Jul  4 06:20:09 PDT 2006
    --
    l_return_status VARCHAR2(3);

BEGIN
    elements := result_to_array(p_context_values);

    denormalized_values := elements;

    --Since the Context values sent in the EAM transaction are
    --normalized so calling the function to get the demormalized
    --values array
    --
    -- Bug 5279941
    -- Made the necessary changes as the
    -- method eam_denormalize_array has
    -- been modified to a procedure
    -- ntungare
    --
    eam_denormalize_array(x_normalized_id_array => denormalized_values,
                          x_Org_Id              => p_org_id);

    plan_txn_id :=  p_plans_tab.FIRST;

    -- Looping through the plan_txn_ids and checking
    -- for the applicable ids
    WHILE plan_txn_id <= p_plans_tab.LAST
       LOOP
          -- Checking if the Triggers Match
          IF triggers_matched(plan_txn_id, denormalized_values) = 'T' THEN

            -- If they do then the Plan is applicable, so insert the results
            insert_results(p_plans_tab(plan_txn_id), p_org_id, p_collection_id, elements);
          END IF;
          plan_txn_id := p_plans_tab.NEXT(plan_txn_id);
       END LOOP;

    --
    -- Bug 5335509
    -- Calling the Sequence generation Api
    -- to generate the sequences
    -- ntungare Tue Jul  4 06:20:09 PDT 2006
    --
    QA_SEQUENCE_API.Generate_Seq_for_Txn
    ( p_collection_id,
      l_return_status);

END evaltriggers_InsertRes_eamtxn;

------------------------------------------------------


FUNCTION fmt(value VARCHAR2, datatype NUMBER, column_name VARCHAR2)
    RETURN VARCHAR2 IS
BEGIN
    IF value IS NULL THEN
        RETURN 'NULL';

    ELSIF datatype = 1 THEN -- string
        RETURN '''' || qa_core_pkg.dequote(value) || '''';

    ELSIF datatype = 2 THEN -- number
        IF column_name LIKE 'CHARACTER%' THEN -- multiradix
            RETURN '''' || qltdate.number_user_to_canon(value) || '''';
        ELSE -- real number
            RETURN qltdate.number_user_to_canon(value);
        END IF;

    ELSIF datatype = 3 THEN -- date
        IF column_name LIKE 'CHARACTER%' THEN -- flexdate
            RETURN '''' || qltdate.date_to_canon(
                to_date(value, fnd_date.name_in_dt_mask)) || '''';
        ELSE -- real date
            RETURN 'to_date(''' || value || ''', ''' ||
                fnd_date.name_in_dt_mask || ''')';
        END IF;

    -- Bug 5335509. SHKALYAN 15-Jun-2006
    -- Need to insert the value 'Automatic' for Sequences while
    -- posting background results. Calling Sequence API function
    -- so as to consistently get the translated value for 'Automatic'
    ELSIF datatype = 5 THEN -- sequence
      RETURN QA_SEQUENCE_API.get_sequence_default_value;

    -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
    -- Added datetime datatype

    ELSIF datatype = 6 THEN -- datetime
          IF column_name LIKE 'CHARACTER%' THEN -- flexdate
               RETURN '''' || qltdate.date_to_canon_dt(to_date(value,
                                  fnd_date.name_in_dt_mask)) || '''';
          ELSE -- real date
               RETURN 'to_date (''' || value || ''', ''' ||fnd_date.name_in_dt_mask || ''')';
          END IF;
    END IF;

    --
    -- By coincident, the above will also work for normalized IDs
    --

    RETURN NULL;
END fmt;


PROCEDURE insert_results(
    p_plan_id IN NUMBER,
    p_org_id IN NUMBER,
    p_collection_id IN NUMBER,
    elements IN ElementsArray) IS

    uid NUMBER := fnd_global.user_id;

    l_insert_columns VARCHAR2(10000);
    l_insert_values VARCHAR2(10000);

BEGIN
   l_insert_columns :=
       'INSERT INTO qa_results ' ||
       ' (status, plan_id, organization_id, collection_id, occurrence,' ||
       ' last_update_date, qa_last_update_date, ' ||
       ' creation_date, qa_creation_date, ' ||
       ' last_updated_by,  qa_last_updated_by, ' ||
       ' created_by, qa_created_by ';

   l_insert_values :=
       ' VALUES(1, :c1, :c2, :c3, qa_occurrence_s.nextval,' ||
       ' sysdate, sysdate,' ||
       ' sysdate, sysdate,' ||
       ' :c4, :c5,' ||
       ' :c6, :c7';

   FOR c IN (
       --
       -- Bug 5365165
       -- Fetching the default value
       -- set either on the plan or the element
       -- level
       -- ntungare
       --
       SELECT qpc.char_id, qpc.result_column_name, qc.datatype,
              NVL(qpc.default_value, qc.default_value) default_value
       FROM   qa_plan_chars qpc, qa_chars qc
       WHERE  plan_id = p_plan_id AND qpc.char_id = qc.char_id) LOOP

       IF elements.EXISTS(c.char_id) THEN
           l_insert_columns := l_insert_columns || ',' || c.result_column_name;
           l_insert_values := l_insert_values || ',' ||
               fmt(elements(c.char_id).value, c.datatype, c.result_column_name);

       --
       -- Bug 5335509
       -- The sequence elements won't be passed as context
       -- Values and hence won't be present in the "elements" array
       -- So explicitly checking for the sequence elements
       -- and initializing them to Automatic.
       -- ntungare Tue Jul  4 06:20:09 PDT 2006
       --
       ELSIF c.datatype = qa_ss_const.sequence_datatype THEN
           l_insert_columns := l_insert_columns || ',' || c.result_column_name;
           l_insert_values := l_insert_values || ', '''
                                              || QA_SEQUENCE_API.get_sequence_default_value
                                              || '''';

       --
       -- Bug 5365165
       -- Added the handling for default values
       -- ntungare
       --
       ELSIF c.default_value IS NOT NULL THEN
           l_insert_columns := l_insert_columns || ',' || c.result_column_name;
           l_insert_values := l_insert_values || ', '''
                                              || c.default_value
                                              || '''';
       END IF;

   END LOOP;

   l_insert_columns := l_insert_columns || ')';
   l_insert_values := l_insert_values || ')';
   EXECUTE IMMEDIATE l_insert_columns || l_insert_values
       USING p_plan_id, p_org_id, p_collection_id, uid, uid, uid, uid;
   EXCEPTION WHEN OTHERS THEN

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'QA_TXN_GRP.INSERT_RESULTS.err', l_insert_columns || l_insert_values );
    end if;

END insert_results;


PROCEDURE post_background_results(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_plan_txn_ids IN VARCHAR2,
    p_context_values IN VARCHAR2,
    p_collection_id IN NUMBER) IS

    select_stmt VARCHAR2(10000);
    TYPE ref_cursor IS REF CURSOR;
    c ref_cursor;

    l_plan_id NUMBER;
    elements  ElementsArray;

    --
    -- Bug 5335509
    -- Variable to get the return status of the Seq
    -- generation procedure
    -- ntungare Tue Jul  4 06:20:09 PDT 2006
    --
    l_return_status VARCHAR2(3);

BEGIN
/*
 Bug 2440015
 suramasw: Thu Jul 18 04:26:41 PDT 2002
 Added only the IF condition.
 Only if the Service Request Type has applicable collection plans then the IF
 condition is used else it is skipped */
    IF p_plan_txn_ids is NOT NULL then

     -- Bug 4270911. CU2 SQL Literal fix. TD #21
     -- Add p_plan_txn_ds into temp table and rewrite the
     -- query to select the id from it.
     -- srhariha. Mon Apr 18 03:52:46 PDT 2005.

     qa_performance_temp_pkg.purge_and_add_ids('QAGTXNB.POST_BACKGROUND_RESULTS', p_plan_txn_ids);

      elements := result_to_array(p_context_values);
      select_stmt :=
          'SELECT DISTINCT qpt.plan_id' ||
          ' FROM  qa_plan_transactions qpt' ||
          ' WHERE qpt.plan_transaction_id IN ' ||
                                       '( SELECT id FROM qa_performance_temp ' ||
                                      ' WHERE key=''QAGTXNB.POST_BACKGROUND_RESULTS'' ) '||
          ' AND qpt.enabled_flag = 1' ||
          ' AND qpt.background_collection_flag = 1' ||
          ' AND NOT EXISTS ' ||
          ' (SELECT 1 ' ||
          '  FROM   qa_results qr ' ||
          '  WHERE  qr.plan_id = qpt.plan_id ' ||
          '  AND qr.collection_id = :c)';

      OPEN c FOR select_stmt USING p_collection_id;
      LOOP
          FETCH c INTO l_plan_id;
          EXIT WHEN c%NOTFOUND;
          insert_results(l_plan_id, p_org_id, p_collection_id, elements);

      END LOOP;
      CLOSE c;

      --
      -- Bug 5335509
      -- Calling the Sequence generation Api
      -- to generate the sequences
      -- ntungare Tue Jul  4 06:20:09 PDT 2006
      --
      QA_SEQUENCE_API.Generate_Seq_for_Txn
        (p_collection_id,
         l_return_status);

    END IF;

END post_background_results;

--Bug 4995406
--Procedure to post the results for Background
--Collection Plans, for EAM Transctions
--This procedure is different from the
--Background Plan Procssing Procedure for
--other Transaction in the way that it does not
--handle the Parent Child Scenarios. It
--also doesn't do the actions firing
--as this is done by the EAM Txn
--ntungare Wed Feb 22 06:47:38 PST 2006
PROCEDURE eam_post_background_results(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_context_values IN VARCHAR2,
    p_collection_id IN NUMBER) IS

    elements  ElementsArray;

    -- Cursor to get a listing of the Enabled
    -- Background Plans for which the results
    -- Havent been collected

    CURSOR c1(txn_no number, org_id number, col_id number) is
        SELECT DISTINCT qpt.plan_id plan_id,
                        qpt.plan_transaction_id plan_txn_id
        FROM  qa_plan_transactions qpt, qa_plans qp
        WHERE  qpt.transaction_number = txn_no
         AND    qpt.plan_id = qp.plan_id
         AND    qp.organization_id = org_id
         AND    trunc(sysdate) between
		nvl(trunc(qp.effective_from), trunc(sysdate)) and
		nvl(trunc(qp.effective_to), trunc(sysdate))
         AND    qpt.enabled_flag = 1
         AND qpt.background_collection_flag = 1
         AND NOT EXISTS
         (SELECT 1
          FROM   qa_results qr
          WHERE  qr.plan_id = qpt.plan_id
          AND qr.collection_id = col_id);

    plan_id_tab QA_PARENT_CHILD_PKG.ChildPlanArray;

BEGIN
     -- Populating the array of the Plan_ids with the
     -- Plan Txn Ids as the Indices
     For curval in c1(p_txn_number, p_org_id, p_collection_id)
       LOOP
          plan_id_tab(curval.plan_txn_id) := curval.plan_id;
       END LOOP;

     -- Calling evaltriggers_InsertRes_eamtxn
     -- to get the list of the applicable plan Txn Ids
     -- and insert the data for the corresponding plans
     --
     -- Bug 5279941
     -- Calling the procedure only in case there
     -- are any background plans setup
     -- ntungare Wed Jun 21 00:37:54 PDT 2006
     --
     If plan_id_tab.COUNT <> 0 Then
         evaltriggers_InsertRes_eamtxn(p_txn_number     => p_txn_number ,
                                       p_org_id         => p_org_id,
                                       p_context_values => p_context_values,
                                       p_plans_tab      => plan_id_tab,
                                       p_collection_id  => p_collection_id);
     End If;
END eam_post_background_results;

-- Bug 5161719. SHKALYAN 13-Apr-2006
-- Added new function to accept prefix and suffix for plan names
-- and construct a message string in the form of
-- <prefix> || <plan name> || <suffix>
-- rest of the logic was moved from the old get_plan_name
-- to avoid code duplication.
FUNCTION get_plan_names_message(
  p_plan_ids IN VARCHAR2,
  p_prefix IN VARCHAR2,
  p_suffix IN VARCHAR2
) RETURN VARCHAR2 IS
    TYPE ref_cursor IS REF CURSOR;
    c ref_cursor;
    s VARCHAR2(1000);
    l_name qa_plans.name%TYPE;
    l_names VARCHAR2(20000) DEFAULT NULL;
BEGIN

     -- Bug 4270911. CU2 SQL Literal fix. TD #22
     -- Add p_plan_ids into temp table and rewrite the
     -- query to select the id from it.
     -- srhariha. Mon Apr 18 03:52:46 PDT 2005.

    qa_performance_temp_pkg.purge_and_add_ids('QAGTXNB.GET_PLAN_NAMES', p_plan_ids);

    s := 'SELECT name FROM qa_plans WHERE plan_id IN ' ||
                                       '( SELECT id FROM qa_performance_temp ' ||
                                      ' WHERE key=''QAGTXNB.GET_PLAN_NAMES'' ) ';

    OPEN c FOR s;
    LOOP
        FETCH c INTO l_name;
        EXIT WHEN c%NOTFOUND;

        -- Bug 5161719. SHKALYAN 13-Apr-2006
        -- Added these conditions to add prefix and suffix to the output message
        -- only if non null values are passed for prefix and suffix.
        IF ( l_names IS NOT NULL ) THEN
          l_names := l_names || ', ';
        END IF;

        IF ( p_prefix IS NOT NULL ) THEN
          l_names := l_names || p_prefix;
        END IF;

        l_names := l_names || l_name;

        IF ( p_suffix IS NOT NULL ) THEN
          l_names := l_names || p_suffix;
        END IF;

    END LOOP;
    CLOSE c;

    RETURN l_names;
END get_plan_names_message;

FUNCTION get_plan_names(p_plan_ids IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  -- Bug 5161719. SHKALYAN 13-Apr-2006
  -- Modified the original get_plan_names to call get_plan_names_message
  -- with null prefix and suffix (to avoid code duplication).
  -- This will return the vanila plan names in a comma separated string
  -- as before.
  return get_plan_names_message( p_plan_ids => p_plan_ids,
                                 p_prefix => null,
                                 p_suffix => null);
END get_plan_names;


PROCEDURE relate_results(p_collection_id NUMBER) IS
	parent_plan_id number;
	parent_collection_id number;
	parent_occurrence number;
	child_plan_id number;
	child_collection_id number;
	child_occurrence number;
	parent_rec_found varchar2(1);

	cursor child_rec(col_id NUMBER) IS
		select plan_id, occurrence
		from qa_results
		where collection_id = col_id;

        -- 12.1 QWB Usability improvements
        agg_elements VARCHAR2(4000);
        agg_vals     VARCHAR2(4000);
BEGIN
	child_collection_id := p_collection_id;

	open child_rec(child_collection_id);
	fetch child_rec into child_plan_id, child_occurrence;

        parent_rec_found :=
        QA_PARENT_CHILD_PKG.find_parent(
                p_child_plan_id => child_plan_id,
                p_child_collection_id => child_collection_id,
                p_child_occurrence => child_occurrence,
                x_parent_plan_id => parent_plan_id,
                x_parent_collection_id => parent_collection_id,
                x_parent_occurrence => parent_occurrence);

	If parent_rec_found = 'T' then
	Loop
                -- 12.1 QWB Usability improvements
                QA_PARENT_CHILD_PKG.relate(
                        p_parent_plan_id => parent_plan_id,
                        p_parent_collection_id => parent_collection_id,
                        p_parent_occurrence => parent_occurrence,
                        p_child_plan_id => child_plan_id,
                        p_child_collection_id => child_collection_id,
                        p_child_occurrence => child_occurrence,
                        x_agg_elements => agg_elements,
                        x_agg_val => agg_vals);
		fetch child_rec into child_plan_id, child_occurrence;
		exit when child_rec%NOTFOUND;
	End Loop;
	end if;

	close child_rec;

END relate_results;


PROCEDURE clear_customs IS
BEGIN
    g_custom1 := '';
    g_custom2 := '';
    g_custom3 := '';
    g_custom4 := '';
    g_custom5 := '';
    g_custom6 := '';
    g_custom7 := '';
    g_custom8 := '';
    g_custom9 := '';
    g_custom10 := '';
    g_custom11 := '';
    g_custom12 := '';
    g_custom13 := '';
    g_custom14 := '';
    g_custom15 := '';
END clear_customs;


PROCEDURE put_custom1(p_value IN VARCHAR2) IS BEGIN g_custom1 := p_value; END;
PROCEDURE put_custom2(p_value IN VARCHAR2) IS BEGIN g_custom2 := p_value; END;
PROCEDURE put_custom3(p_value IN VARCHAR2) IS BEGIN g_custom3 := p_value; END;
PROCEDURE put_custom4(p_value IN VARCHAR2) IS BEGIN g_custom4 := p_value; END;
PROCEDURE put_custom5(p_value IN VARCHAR2) IS BEGIN g_custom5 := p_value; END;
PROCEDURE put_custom6(p_value IN VARCHAR2) IS BEGIN g_custom6 := p_value; END;
PROCEDURE put_custom7(p_value IN VARCHAR2) IS BEGIN g_custom7 := p_value; END;
PROCEDURE put_custom8(p_value IN VARCHAR2) IS BEGIN g_custom8 := p_value; END;
PROCEDURE put_custom9(p_value IN VARCHAR2) IS BEGIN g_custom9 := p_value; END;
PROCEDURE put_custom10(p_value IN VARCHAR2) IS BEGIN g_custom10 := p_value; END;
PROCEDURE put_custom11(p_value IN VARCHAR2) IS BEGIN g_custom11 := p_value; END;
PROCEDURE put_custom12(p_value IN VARCHAR2) IS BEGIN g_custom12 := p_value; END;
PROCEDURE put_custom13(p_value IN VARCHAR2) IS BEGIN g_custom13 := p_value; END;
PROCEDURE put_custom14(p_value IN VARCHAR2) IS BEGIN g_custom14 := p_value; END;
PROCEDURE put_custom15(p_value IN VARCHAR2) IS BEGIN g_custom15 := p_value; END;

FUNCTION get_custom1 RETURN VARCHAR2 IS BEGIN RETURN g_custom1; END;
FUNCTION get_custom2 RETURN VARCHAR2 IS BEGIN RETURN g_custom2; END;
FUNCTION get_custom3 RETURN VARCHAR2 IS BEGIN RETURN g_custom3; END;
FUNCTION get_custom4 RETURN VARCHAR2 IS BEGIN RETURN g_custom4; END;
FUNCTION get_custom5 RETURN VARCHAR2 IS BEGIN RETURN g_custom5; END;
FUNCTION get_custom6 RETURN VARCHAR2 IS BEGIN RETURN g_custom6; END;
FUNCTION get_custom7 RETURN VARCHAR2 IS BEGIN RETURN g_custom7; END;
FUNCTION get_custom8 RETURN VARCHAR2 IS BEGIN RETURN g_custom8; END;
FUNCTION get_custom9 RETURN VARCHAR2 IS BEGIN RETURN g_custom9; END;
FUNCTION get_custom10 RETURN VARCHAR2 IS BEGIN RETURN g_custom10; END;
FUNCTION get_custom11 RETURN VARCHAR2 IS BEGIN RETURN g_custom11; END;
FUNCTION get_custom12 RETURN VARCHAR2 IS BEGIN RETURN g_custom12; END;
FUNCTION get_custom13 RETURN VARCHAR2 IS BEGIN RETURN g_custom13; END;
FUNCTION get_custom14 RETURN VARCHAR2 IS BEGIN RETURN g_custom14; END;
FUNCTION get_custom15 RETURN VARCHAR2 IS BEGIN RETURN g_custom15; END;


  -- Bug 4343758. OA Framework Integration Project.
  -- Helper method to build result string for background plan.
  -- srhariha. Wed May  4 03:12:40 PDT 2005.


 FUNCTION build_result_string(elements ElementsArray, p_plan_id IN NUMBER)
                                                   RETURN VARCHAR2 IS

     l_ret_string varchar2(32000);

     --
     -- bug 5365251
     -- modified the Cursor to fetch the default values
     -- ntungare
     --
     -- bug 5335509
     -- modified the cursor definition
     -- to select the datatype of the collection element
     -- ntunagre
     --
     CURSOR C1 IS
       /*
       SELECT char_id
       from qa_plan_chars
       where plan_id = p_plan_id
       and enabled_flag = 1;
       */
       SELECT qpc.char_id,
              NVL(qpc.default_value, qc.default_value) default_value,
              qc.datatype
       from qa_plan_chars qpc, qa_chars qc
       where qpc.plan_id = p_plan_id
       and qpc.char_id = qc.char_id
       and qpc.enabled_flag = 1;

 BEGIN
    l_ret_string := null;
    for pc_rec in c1 loop
      if elements.EXISTS(pc_rec.char_id) then
       -- Bug 4343758. OA Framework Integration.
       -- Code review incorporation. CR DOC Ref 4.6.1
       -- Encode the value.
       -- srhariha. Tue Jun 21 03:12:31 PDT 2005.

          l_ret_string := l_ret_string || '@' || to_char(pc_rec.char_id) || '=' || replace(elements(pc_rec.char_id).value,'@','@@');

      --
      -- bug 5335509
      -- checking if the element is of the seq type
      -- in which case set the default val as
      -- 'Automatic'
      -- ntungare
      --
      elsif pc_rec.datatype = qa_ss_const.sequence_datatype THEN
          l_ret_string := l_ret_string || '@' || to_char(pc_rec.char_id) || '=' || QA_SEQUENCE_API.get_sequence_default_value;

      --
      -- Bug 5365251
      -- Checking if any collection element has
      -- a default value
      -- ntungare
      --
      elsif pc_rec.default_value IS NOT NULL THEN
          l_ret_string := l_ret_string || '@' || to_char(pc_rec.char_id) || '=' || replace(pc_rec.default_value,'@','@@');
      end if;
    end loop;

    if (l_ret_string is not null) then
       return substr(l_ret_string,2);
    end if;
    return null;
 END build_result_string;


  -- Bug 4343758. OA Integration Project.
  -- Function to insert post background results
  -- transaction scenario. Similar to post_back_ground_result
  -- except it uses qa_ss_results_.ssqr_post_result.
  -- srhariha. Wed May  4 03:12:40 PDT 2005.


 PROCEDURE ssqr_post_background_results( p_txn_number IN NUMBER,
                                         p_org_id IN NUMBER,
                                         p_plan_txn_ids IN VARCHAR2,
                                         p_context_values IN VARCHAR2,
                                         p_collection_id IN NUMBER,
                                         p_txn_header_id IN NUMBER) IS

    CURSOR C1 IS
       SELECT qa_occurrence_s.nextval
       FROM DUAL;

    CURSOR C2(c_collection_id NUMBER) IS
         SELECT DISTINCT qpt.plan_id
         FROM  qa_plan_transactions qpt
         WHERE qpt.plan_transaction_id IN
                                       ( SELECT id FROM qa_performance_temp
                                         WHERE key='QAGTXNB.SSQR_POST_BACKGROUND_RESULTS' )
         AND qpt.enabled_flag = 1
         AND qpt.background_collection_flag = 1
         AND NOT EXISTS (SELECT 1
                         FROM   qa_results qr
                         WHERE  qr.plan_id = qpt.plan_id
                         AND qr.collection_id = c_collection_id);

    l_plan_id NUMBER;
    elements  ElementsArray;
    l_occurrence NUMBER;
    l_ret VARCHAR2(10);
    l_result_string VARCHAR2(32000);
    x_out_message VARCHAR2(32000);

    -- 12.1 QWB Usability Improvements
    agg_elements VARCHAR2(4000);
    agg_vals     VARCHAR2(4000);
BEGIN

     IF p_plan_txn_ids is NOT NULL then

      qa_performance_temp_pkg.purge_and_add_ids('QAGTXNB.SSQR_POST_BACKGROUND_RESULTS', p_plan_txn_ids);

      elements := result_to_array(p_context_values);

       -- Bug 4343758. OA Framework Integration.
       -- Code review incorporation. CR DOC Ref 4.6.1
       -- Used static SQL cursor.
       -- srhariha. Tue Jun 21 03:12:31 PDT 2005.
       FOR crec IN C2(p_collection_id) LOOP

            -- get occurrence
            OPEN C1;
            FETCH C1 into l_occurrence;
            CLOSE C1;

            l_result_string := build_result_string(elements,crec.plan_id);

            if(l_result_string is not null AND length(l_result_string) >= 0) then
              --
              -- Bug 4932622. Background results not posted in WIP move transaction.
              -- Pass transaction number so that validation API can set proper flags
              -- for context elements.
              -- srhariha.Wed Jan 11 20:55:18 PST 2006
              --
              -- 12.1 QWB Usability Improvements
              l_ret := QA_SS_RESULTS.SSQR_POST_RESULT(X_OCCURRENCE => l_occurrence,
                                                      X_ORG_ID => p_org_id,
                                                      X_PLAN_ID => crec.plan_id,
                                                      X_SPEC_ID => null,
                                                      X_COLLECTION_ID => p_collection_id,
                                                      X_TXN_HEADER_ID => p_txn_header_id,
                                                      X_PAR_PLAN_ID => null,
                                                      X_PAR_COL_ID => null,
                                                      X_PAR_OCC => null,
                                                      X_RESULT => l_result_string,
                                                      X_RESULT1 => null,
                                                      X_RESULT2 => null,
                                                      X_ENABLED => 1,
                                                      X_COMMITTED => 0,
                                                      X_TRANSACTION_NUMBER => p_txn_number, -- bug 4932622
                                                      X_MESSAGES => x_out_message,
                                                      X_AGG_ELEMENTS => agg_elements,
                                                      X_AGG_VAL      => agg_vals);


             end if;
      END LOOP;
    END IF; -- p_plan_txn_ids

    EXCEPTION
        WHEN OTHERS THEN
        raise;

 END ssqr_post_background_results;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/07/2005.

  PROCEDURE get_child_plans
  (
    p_plan_id           IN NUMBER,
    p_org_id            IN NUMBER,
    p_collection_id     IN NUMBER,
    p_occurrence        IN NUMBER,
    p_relationship_type IN NUMBER,
    p_data_entry_mode   IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_criteria_values   OUT NOCOPY VARCHAR2,
    x_child_plan_ids    OUT NOCOPY VARCHAR2
  )
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'GET_CHILD_PLANS';
  BEGIN
      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE GETTING PC CRITERIA VALUES'
        );
      END IF;

      QA_PARENT_CHILD_PKG.get_criteria_values
      (
          p_parent_plan_id       => p_plan_id,
          p_parent_collection_id => p_collection_id,
          p_parent_occurrence    => p_occurrence,
          p_organization_id      => p_org_id,
          x_criteria_values      => x_criteria_values
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE EVALUATING PC CRITERIA'
        );
      END IF;

      x_return_status :=
      QA_PARENT_CHILD_PKG.evaluate_criteria
      (
          p_plan_id            => p_plan_id,
          p_criteria_values    => x_criteria_values,
          p_relationship_type  => p_relationship_type,
          p_data_entry_mode    => p_data_entry_mode,
          x_child_plan_ids     => x_child_plan_ids
      );

  END get_child_plans;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/07/2005.

  PROCEDURE insert_child_results
  (
    p_plan_id           IN NUMBER,
    p_org_id            IN NUMBER,
    p_collection_id     IN NUMBER,
    p_occurrence        IN NUMBER,
    p_relationship_type IN NUMBER,
    p_data_entry_mode   IN NUMBER,
    p_txn_header_id     IN NUMBER
  )
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'INSERT_CHILD_RESULTS';
      l_criteria_values VARCHAR2(32000);
      l_child_plan_ids  VARCHAR2(10000);
      l_return_status   VARCHAR2(1);

  BEGIN

      get_child_plans
      (
        p_plan_id           => p_plan_id,
        p_org_id            => p_org_id,
        p_collection_id     => p_collection_id,
        p_occurrence        => p_occurrence,
        p_relationship_type => p_relationship_type,
        p_data_entry_mode   => p_data_entry_mode,
        x_return_status     => l_return_status,
        x_criteria_values   => l_criteria_values,
        x_child_plan_ids    => l_child_plan_ids
      );

      IF( l_return_status = 'T' ) THEN
        QA_PARENT_CHILD_PKG.insert_automatic_records
        (
            p_plan_id            => p_plan_id,
            p_collection_id      => p_collection_id,
            p_occurrence         => p_occurrence,
            p_child_plan_ids     => l_child_plan_ids,
            p_relationship_type  => p_relationship_type,
            p_data_entry_mode    => p_data_entry_mode,
            p_criteria_values    => l_criteria_values,
            p_org_id             => p_org_id,
            p_spec_id            => null,
            x_status             => l_return_status,
            p_txn_header_id      => p_txn_header_id
        );
      END IF;

  END insert_child_results;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/10/2005.
  -- This function is used by parent Txns to check whether the Quality
  -- Results entered during the Transaction can be committed.
  FUNCTION is_commit_allowed(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER := NULL,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      x_plan_names       OUT NOCOPY VARCHAR2) RETURN VARCHAR2
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'IS_COMMIT_ALLOWED';

      -- Bug 5161719. SHKALYAN 13-Apr-2006
      -- Added these variables to form the message in the required format
      -- Final message will be of the form
      -- "Quality Collection Plan: XXX" (or)
      -- "Quality Collection Plan: YYY ( Child of ZZZ )"
      l_space           CONSTANT VARCHAR2(2) := ' ';
      l_separator       CONSTANT VARCHAR2(2) := ', ';
      l_prefix1         VARCHAR2(30);
      l_prefix2         CONSTANT VARCHAR2(2) := ': ';
      l_suffix1         CONSTANT VARCHAR2(3) := ' ( ';
      l_suffix2         VARCHAR2(30);
      l_suffix3         CONSTANT VARCHAR2(3) := ' ) ';

      l_criteria_values VARCHAR2(32000);
      l_plan_ids        VARCHAR2(10000);
      l_child_plan_ids  VARCHAR2(10000);
      l_return_status   VARCHAR2(1);

      TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_plans           number_tab;

      -- Bug 5161719. SHKALYAN 13-Apr-2006
      -- this array is needed for storing parent plan names for the message
      TYPE plan_name_tab IS TABLE OF qa_plans.name%TYPE INDEX BY BINARY_INTEGER;
      l_plan_names      plan_name_tab;

      l_occurrences     number_tab;

  BEGIN

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE: p_txn_number: ' || p_txn_number || ' p_org_id: ' || p_org_id || ' p_txn_header_id: ' || p_txn_header_id || ' p_collection_id: ' || p_collection_id || ' p_plan_txn_ids: ' || p_plan_txn_ids
        );
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE CHECKING MANDATORY COLLECTION'
        );
      END IF;

      -- Bug 5161719. SHKALYAN 13-Apr-2006
      -- Populate the prefix and suffix text from seed.
      -- contains text "Quality Collection Plan: "
      FND_MESSAGE.set_name('QA','QA_QLTY_COLLECTION_PLAN');
      l_prefix1 := FND_MESSAGE.get;

      -- contains text "Child of ";
      FND_MESSAGE.set_name('QA','QA_CHILD_OF');
      l_suffix2 := FND_MESSAGE.get;

      -- Check if Results have been entered for all mandatory plans
      -- for the given Txn
      l_return_status :=
      commit_allowed
      (
        p_txn_number    => p_txn_number,
        p_org_id        => p_org_id,
        p_plan_txn_ids  => p_plan_txn_ids,
        p_collection_id => p_collection_id,
        x_plan_ids      => l_plan_ids
      );

      IF ( l_return_status <> 'T' ) THEN

        -- Return a Comma separated list of plan names which are incomplete
        -- Bug 5161719. SHKALYAN 13-Apr-2006
        -- Modified to call new function with prefix and suffix
        x_plan_names :=
        get_plan_names_message
        (
          p_plan_ids => l_plan_ids,
          p_prefix => l_prefix1 || l_prefix2,
          p_suffix => NULL
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: INCOMPLETE PLANS - IDS: ' || l_plan_ids || ' NAMES: ' || x_plan_names
          );
        END IF;

        return 'F';
      END IF;

      l_plan_ids := '';

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE VALIDATING IMMEDIATE CHILD COLLECTION'
        );
      END IF;

      -- Get all the distinct plans and occurences from QA_RESULTS
      -- for the given collection_id
      -- Bug 5161719. SHKALYAN 13-Apr-2006
      -- Modified cursor to include plan name for the message
      SELECT QR.plan_id,
             QP.name,
             QR.occurrence
      BULK COLLECT INTO
             l_plans,
             l_plan_names,
             l_occurrences
      FROM   QA_RESULTS QR,
             QA_PLANS QP
      WHERE  QP.plan_id = QR.plan_id
      AND    QR.collection_id = p_collection_id;

      -- Bug 4343758. OA Framework Integration project.
      -- Added a null check.
      -- srhariha. Tue May 24 23:18:48 PDT 2005.

      IF l_plans.FIRST IS NOT NULL THEN

        FOR i IN l_plans.FIRST .. l_plans.LAST LOOP

          IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
             FND_LOG.string
             (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'BEFORE GETTING CHILD PLANS FOR PLAN_ID: ' || l_plans(i) || ' OCCURRENCE: ' || l_occurrences(i)
             );
          END IF;

          -- Bug 4343758. OA Framework Integration project.
          -- data_entry_mode for immediate is 1.
          -- srhariha. Tue May 24 22:53:40 PDT 2005.

          -- Get Immediate Children for the current plan
          get_child_plans
          (
            p_plan_id           => l_plans(i),
            p_org_id            => p_org_id,
            p_collection_id     => p_collection_id,
            p_occurrence        => l_occurrences(i),
            p_relationship_type => 1,
            p_data_entry_mode   => 1, -- Immediate
            x_return_status     => l_return_status,
            x_criteria_values   => l_criteria_values,
            x_child_plan_ids    => l_child_plan_ids
          );

          IF( l_return_status = 'T' ) THEN

            IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
              FND_LOG.string
              (
                FND_LOG.level_statement,
                g_pkg_name || '.' || l_api_name,
                'BEFORE CHECKING IF COMMIT IS ALLOWED FOR IMMEDIATE CHILDREN: ' || l_child_plan_ids
              );
            END IF;

           -- Check if Results have been submitted for Immediate Child Plans
           -- Bug 5161719. SHKALYAN 13-Apr-2006
           -- Modified to call new overloaded QA_PARENT_CHILD_PKG.commit_allowed
           -- so that incomplete child plan ids are obtained
            l_return_status :=
            QA_PARENT_CHILD_PKG.commit_allowed
            (
              p_plan_id             => l_plans(i),
              p_collection_id       => p_collection_id,
              p_occurrence          => l_occurrences(i),
              p_child_plan_ids      => l_child_plan_ids,
              x_incomplete_plan_ids => l_plan_ids
            );

            IF ( l_return_status <> 'T' ) THEN

              IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
                FND_LOG.string
                (
                  FND_LOG.level_statement,
                  g_pkg_name || '.' || l_api_name,
                  'ALL CHILD RESULTS ARE NOT CAPTURED FOR PLAN: ' || l_plans(i)
                );
              END IF;

              -- Bug 5161719. SHKALYAN 13-Apr-2006
              -- Form the message for each child plan that is not completed
              -- Message will be of the form:
              -- "Quality Collection Plan: <Child Plan Name> ( Child of <Parent Plan Name> )"
              x_plan_names := x_plan_names ||
                              l_separator ||
                              get_plan_names_message
                              (
                                p_plan_ids => l_plan_ids,
                                p_prefix   => l_prefix1 || l_prefix2,
                                p_suffix   => l_suffix1 ||
                                              l_suffix2 ||
                                              l_space ||
                                              l_plan_names(i) ||
                                              l_suffix3
                              );

              l_plan_ids := '';
            END IF;

          END IF; -- l_return_status ='T'
        END LOOP;

      END IF; -- l_plans.FIRST is not null

      IF ( LENGTH( x_plan_names ) > 0 ) THEN

        -- Bug 5161719. SHKALYAN 13-Apr-2006
        -- Remove the leading comma
        x_plan_names := SUBSTR( x_plan_names , LENGTH(l_separator) + 1 );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: INCOMPLETE PLANS : ' || x_plan_names
          );
        END IF;

        return 'F';
      END IF;

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: COMMIT IS ALLOWED'
        );
      END IF;

      return 'T';

  END is_commit_allowed;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/07/2005.
  -- This is an API for performing the post commit processing in
  -- transaction integration scenario. This API performs the following actions
  -- Insert Automatic and History Results.
  -- Post Background results for the transaction.
  -- Generate Sequence element values.
  -- Enable the Quality Results
  -- Fire Background actions.

  PROCEDURE process_txn_post_commit(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      p_context_values   IN         VARCHAR2,
      p_context_ids      IN         VARCHAR2 := NULL,
      p_generated_values IN         VARCHAR2 := NULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2)
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'PROCESS_TXN_POST_COMMIT';
      l_api_version     CONSTANT NUMBER         := 1.0;

      l_commit          BOOLEAN;
      l_return_status   VARCHAR2(1);

      TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_plan_ids        number_tab;
      l_occurrences     number_tab;
  BEGIN

      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE: p_txn_number: ' || p_txn_number || ' p_org_id: ' || p_org_id || ' p_txn_header_id: ' || p_txn_header_id ||
          ' p_collection_id: ' || p_collection_id || ' p_plan_txn_ids: ' || p_plan_txn_ids || ' p_context_values: ' || p_context_values || ' p_context_ids: ' || p_context_ids
        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT process_txn_post_commit_GRP;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE POSTING BACKGROUND RESULTS'
        );
      END IF;

      -- Post Background Results for the Given Context
      ssqr_post_background_results
      (
        p_txn_number     => p_txn_number,
        p_org_id         => p_org_id,
        p_plan_txn_ids   => p_plan_txn_ids,
        p_context_values => p_context_values,
        p_collection_id  => p_collection_id,
        p_txn_header_id  => p_txn_header_id
      );

      -- Get all the distinct plans and occurences from QA_RESULTS
      SELECT plan_id,
             occurrence
      BULK COLLECT INTO
             l_plan_ids,
             l_occurrences
      FROM   QA_RESULTS
      WHERE  collection_id = p_collection_id;


      -- Bug 4343758. OA Framework Integration project.
      -- Added a null check.
      -- srhariha. Tue May 24 23:18:48 PDT 2005.

      IF l_plan_ids.FIRST IS NOT NULL THEN

        FOR i IN l_plan_ids.FIRST .. l_plan_ids.LAST LOOP

          IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
            FND_LOG.string
            (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'BEFORE INSERTING AUTOMATIC RECORDS FOR PLAN_ID: ' || l_plan_ids(i) || ' OCCURRENCE: ' || l_occurrences(i)
            );
          END IF;

          -- Insert Automatic Child Records
          insert_child_results
          (
            p_plan_id           => l_plan_ids(i),
            p_org_id            => p_org_id,
            p_collection_id     => p_collection_id,
            p_occurrence        => l_occurrences(i),
            p_relationship_type => 1,
            p_data_entry_mode   => 2, -- Automatic
            p_txn_header_id     => p_txn_header_id
          );

          IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
            FND_LOG.string
            (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'BEFORE INSERTING HISTORY RECORDS FOR PLAN_ID: ' || l_plan_ids(i) || ' OCCURRENCE: ' || l_occurrences(i)
            );
          END IF;

          -- Insert History Child Records
          insert_child_results
          (
            p_plan_id           => l_plan_ids(i),
            p_org_id            => p_org_id,
            p_collection_id     => p_collection_id,
            p_occurrence        => l_occurrences(i),
            p_relationship_type => 1,
            p_data_entry_mode   => 4, -- History
            p_txn_header_id     => p_txn_header_id
          );

        END LOOP;
      END IF; -- l_plan_ids.FIRST is not null

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE ENABLING QA RESULTS'
        );
      END IF;

      -- Enable the Results
      UPDATE qa_results
      SET    status = 2
      WHERE  collection_id = p_collection_id;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE GENERATING SEQUENCES'
        );
      END IF;

      -- Generate Sequences
      QA_SEQUENCE_API.generate_seq_for_txn
      (
        p_collection_id  => p_collection_id,
        p_return_status  => l_return_status
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE FIRING BACKGROUND ACTIONS'
        );
      END IF;

      -- launch quality actions
      -- only actions that are performed in commit cycle are to be
      -- launched here
      IF ( QLTDACTB.do_actions
           (
             p_collection_id,
             1,
             NULL,
             NULL,
             FALSE ,
             FALSE,
             'DEFERRED' ,
             'COLLECTION_ID'
           ) = FALSE ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Commit (if requested)
      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
        );
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO process_txn_post_commit_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO process_txn_post_commit_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO process_txn_post_commit_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

  END process_txn_post_commit;

  -- Bug 4343758
  -- R12 OAF Txn Integration Project
  -- shkalyan 05/10/2005.
  -- This function is used for Purging QA Results and their associated
  -- Records. This API is called when the parent Transaction is Unsuccessful.
  FUNCTION purge_records(
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER := NULL,
      p_collection_id    IN         NUMBER) RETURN NUMBER
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'PURGE_RECORDS';
      l_result_count    NUMBER;
  BEGIN

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE: P_TXN_NUMBER: ' || p_txn_number || ' P_ORG_ID: ' || p_org_id || ' P_TXN_HEADER_ID: ' || p_txn_header_id || ' P_COLLECTION_ID: ' || p_collection_id
        );
      END IF;

      DELETE  qa_results
      WHERE   collection_id = p_collection_id;

      l_result_count := SQL%ROWCOUNT;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'DELETED ' || l_result_count || ' ROWS FROM QA_RESULTS'
        );
      END IF;

      IF ( l_result_count > 0 ) THEN
        DELETE  qa_pc_results_relationship
        WHERE   parent_collection_id = p_collection_id
        OR      child_collection_id = p_collection_id;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'DELETED ' || SQL%ROWCOUNT || ' ROWS FROM QA_PC_RESULTS_RELATIONSHIP'
          );
        END IF;

      END IF;

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
        );
      END IF;

      RETURN l_result_count;

  END purge_records;

  -- Bug 4343758. OA Integration Project.
  -- Wrapper around evaluate_triggers.
  -- Returns comma separated list of transaction id
  -- srhariha. Wed May  4 03:12:40 PDT 2005.

  FUNCTION ssqr_evaluate_triggers(p_txn_number IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_context_values IN VARCHAR2)
                                                 RETURN VARCHAR2 IS

  l_txn_id_list VARCHAR2(32000);
  l_ret VARCHAR2(3);

  BEGIN
    l_ret := evaluate_triggers(p_txn_number,p_org_id,p_context_values,l_txn_id_list);

    IF l_ret = 'T' THEN
        return l_txn_id_list;
    END IF;

    return null;

  END ssqr_evaluate_triggers;

  -- This API performs the following actions before eres is fired to have
  -- complete data in Quality e-Record in MES.
  -- Insert Automatic and History Results.
  -- Post Background results for the transaction.
  -- Generate Sequence element values.
  -- saugupta Mon, 07 Jan 2008 02:37:52 -0800 PDT

  PROCEDURE process_txn_for_eres(
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_txn_number       IN         NUMBER,
      p_org_id           IN         NUMBER,
      p_txn_header_id    IN         NUMBER,
      p_collection_id    IN         NUMBER,
      p_plan_txn_ids     IN         VARCHAR2 := NULL,
      p_context_values   IN         VARCHAR2,
      p_context_ids      IN         VARCHAR2 := NULL,
      p_generated_values IN         VARCHAR2 := NULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2)
  IS
      l_api_name        CONSTANT VARCHAR2(30)   := 'PROCESS_TXN_FOR_ERES';
      l_api_version     CONSTANT NUMBER         := 1.0;

      l_commit          BOOLEAN;
      l_return_status   VARCHAR2(1);

      TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_plan_ids        number_tab;
      l_occurrences     number_tab;
  BEGIN

      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE: p_txn_number: ' || p_txn_number || ' p_org_id: ' || p_org_id || ' p_txn_header_id: ' || p_txn_header_id ||
          ' p_collection_id: ' || p_collection_id || ' p_plan_txn_ids: ' || p_plan_txn_ids || ' p_context_values: ' || p_context_values || '
p_context_ids: ' || p_context_ids
        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT process_txn_for_eres_GRP;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE FIRING MES ERES EVENT'
        );
      END IF;

      -- Post Background Results for the Given Context
      ssqr_post_background_results
      (
        p_txn_number     => p_txn_number,
        p_org_id         => p_org_id,
        p_plan_txn_ids   => p_plan_txn_ids,
        p_context_values => p_context_values,
        p_collection_id  => p_collection_id,
        p_txn_header_id  => p_txn_header_id
      );

      -- Get all the distinct plans and occurences from QA_RESULTS
      SELECT plan_id,
             occurrence
      BULK COLLECT INTO
             l_plan_ids,
             l_occurrences
      FROM   QA_RESULTS
      WHERE  collection_id = p_collection_id;

      IF l_plan_ids.FIRST IS NOT NULL THEN

        FOR i IN l_plan_ids.FIRST .. l_plan_ids.LAST LOOP

          IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
            FND_LOG.string
            (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'BEFORE INSERTING AUTOMATIC RECORDS FOR PLAN_ID: ' || l_plan_ids(i) || ' OCCURRENCE: ' || l_occurrences(i)
            );
          END IF;

          -- Insert Automatic Child Records
          insert_child_results
          (
            p_plan_id           => l_plan_ids(i),
            p_org_id            => p_org_id,
            p_collection_id     => p_collection_id,
            p_occurrence        => l_occurrences(i),
            p_relationship_type => 1,
            p_data_entry_mode   => 2, -- Automatic
            p_txn_header_id     => p_txn_header_id
          );

          IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
            FND_LOG.string
            (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'BEFORE INSERTING HISTORY RECORDS FOR PLAN_ID: ' || l_plan_ids(i) || ' OCCURRENCE: ' || l_occurrences(i)
            );
          END IF;
          -- Insert History Child Records
          insert_child_results
          (
            p_plan_id           => l_plan_ids(i),
            p_org_id            => p_org_id,
            p_collection_id     => p_collection_id,
            p_occurrence        => l_occurrences(i),
            p_relationship_type => 1,
            p_data_entry_mode   => 4, -- History
            p_txn_header_id     => p_txn_header_id
          );

        END LOOP;
      END IF; -- l_plan_ids.FIRST is not null


      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE ENABLING QA RESULTS'
        );
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE GENERATING SEQUENCES'
        );
      END IF;

      -- Generate Sequences
      QA_SEQUENCE_API.generate_seq_for_txn
      (
        p_collection_id  => p_collection_id,
        p_return_status  => l_return_status
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE FIRING BACKGROUND ACTIONS'
        );
      END IF;

      -- Enable the Results
      /*
      UPDATE qa_results
      SET    status = 2
      WHERE  collection_id = p_collection_id;
      */

      -- launch quality actions
      -- only actions that are performed in commit cycle are to be
      -- launched here
     /* IF ( QLTDACTB.do_actions
           (
             p_collection_id,
             1,
             NULL,
             NULL,
             FALSE ,
             FALSE,
             'DEFERRED' ,
             'COLLECTION_ID'
           ) = FALSE ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */

      -- Commit (if requested)
      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
        );
      END IF;


    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO process_txn_for_eres_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO process_txn_for_eres_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO process_txn_for_eres_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

  END process_txn_for_eres;

  -- enable and fire background actions for Applicable plans in ERES flow
  -- saugupta Mon, 07 Jan 2008 05:47:37 -0800 PDT
  PROCEDURE enable_and_fire_action (
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_collection_id IN NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2 ) IS

      l_api_name        CONSTANT VARCHAR2(30)   := 'ENABLE_AND_FIRE_ACTION';
      l_api_version     CONSTANT NUMBER         := 1.0;

      l_commit          BOOLEAN;
      l_return_status   VARCHAR2(1);

  BEGIN

      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE' );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT enable_and_fire_action_GRP;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE ENABLING RESULTS'
        );
      END IF;

      UPDATE qa_results
      SET status=2
      WHERE collection_id = p_collection_id;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'BEFORE FIRING BACKGROUND ACTIONS'
        );
      END IF;

      -- launch quality actions
      -- only actions that are performed in commit cycle are to be
      -- launched here
      IF ( QLTDACTB.do_actions
           (
             p_collection_id,
             1,
             NULL,
             NULL,
             FALSE ,
             FALSE,
             'DEFERRED' ,
             'COLLECTION_ID'
           ) = FALSE ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
        );
      END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO enable_and_fire_action_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO enable_and_fire_action_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO enable_and_fire_action_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;


END enable_and_fire_action;


END qa_txn_grp;

/
