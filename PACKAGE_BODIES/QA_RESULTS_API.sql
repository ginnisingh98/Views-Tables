--------------------------------------------------------
--  DDL for Package Body QA_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULTS_API" AS
/* $Header: qltrsiub.plb 120.7.12010000.1 2008/07/25 09:22:15 appldev ship $ */


PROCEDURE enable_and_fire_action (p_collection_id     IN  NUMBER ) IS

BEGIN

     UPDATE qa_results
     SET status=2
     WHERE collection_id = p_collection_id;

     commit_qa_results(p_collection_id);

END enable_and_fire_action;


PROCEDURE commit_qa_results(p_collection_id     IN  NUMBER ) IS

    actions_request_id             NUMBER;

BEGIN

    COMMIT;

    --
    -- Bug 1580498.  The concurrent program qltactwb always passed
    -- TXN_HEADER_ID as argument to do_actions.  This is not correct
    -- in the api situation.  In order to make minimal impact to
    -- testing and release, I am now passing a negative collection ID
    -- to qltactwb to indicate COLLECTION_ID instead of TXN_HEADER_ID
    -- be passed to the do_actions function.
    -- bso Thu Jan 11 19:22:51 PST 2001
    --

    actions_request_id := fnd_request.submit_request('QA', 'QLTACTWB', NULL,
                  NULL, FALSE, to_char(-p_collection_id));

    COMMIT;

END commit_qa_results;

--
-- 12.1 QWB Usability Improvements
-- added a new parameter, p_ssqr_opperation to ensure
-- that the validation is not done again at the time of
-- inserting rows through QWB
--
FUNCTION insert_row( p_plan_id                 IN  NUMBER,
                     p_spec_id                 IN  NUMBER DEFAULT NULL,
                     p_org_id                  IN  NUMBER,
                     p_transaction_number      IN  NUMBER DEFAULT NULL,
                     p_transaction_id          IN  NUMBER DEFAULT 0,
                     p_collection_id           IN  OUT NOCOPY NUMBER,
                     p_who_last_updated_by     IN  NUMBER := fnd_global.user_id,
                     p_who_created_by          IN  NUMBER := fnd_global.user_id,
                     p_who_last_update_login   IN  NUMBER := fnd_global.user_id,
                     p_enabled_flag            IN  NUMBER,
                     p_commit_flag             IN  BOOLEAN DEFAULT FALSE,
                     p_error_found             OUT NOCOPY BOOLEAN,
                     p_occurrence              IN  OUT NOCOPY NUMBER,
                     p_do_action_return        OUT NOCOPY BOOLEAN,
                     p_message_array           OUT NOCOPY qa_validation_api.MessageArray,
                     p_row_elements            IN  OUT NOCOPY qa_validation_api.ElementsArray,
                     p_txn_header_id           IN  NUMBER DEFAULT NULL,
                     p_ssqr_operation          IN  NUMBER DEFAULT NULL,
                     p_last_update_date        IN  DATE   DEFAULT SYSDATE)
    RETURN qa_validation_api.ErrorArray  IS



    return_results_array       qa_validation_api.ResultRecordArray;
    master_error_list          qa_validation_api.ErrorArray;

    insert_string              varchar2(6000)  := null;
    value_string               varchar2(30000) := null;
    sql_string                 varchar2(32000) := null;
    column_name                varchar2(240)   := null;
    column_value               varchar2(2000);

    i                          NUMBER;
    j                          NUMBER;
    x_collection_id            NUMBER;
    x_occurrence               NUMBER;
    x_txn_header_id            NUMBER;
    actions_request_id         NUMBER;
    x_sysdate                  DATE;

    c                         INTEGER; /* cursor handler */
    insert_dbms_sql_feedback   INTEGER;

    -- 12.1 QWB Usability Improvements
    charctr  NUMBER;

    --
    -- bug 6933282
    -- Variable to hold the decimal precision
    -- defined for a numeric element.
    -- ntungare
    --
    l_precision                NUMBER;
BEGIN
    x_collection_id         := p_collection_id;

    IF x_collection_id IS NULL THEN
        SELECT QA_COLLECTION_ID_S.NEXTVAL INTO x_collection_id FROM DUAL;
        p_collection_id := x_collection_id;
    END IF;

   -- Ankur: Following logic makes sure that if OCCURRENCE is an IN parameter
   -- then we put this value else we select next sequence value.
    x_occurrence         := p_occurrence;

    IF x_occurrence IS NULL THEN
        SELECT QA_OCCURRENCE_S.NEXTVAL INTO x_occurrence FROM DUAL;
        p_occurrence := x_occurrence;
    END IF;

    -- Bug 2290747. In Parent-Child scanario History plan record is
    -- inserted with status 1. When parent plan gets saved, history
    -- record gets enabled ie status = 2. In UQR mode, enabling is
    -- done using txn_header_id. For this parent and history record
    -- should have the same txn_header_id. In order to achieve this
    -- txn_header_id is passed from the form.
    -- rponnusa Mon Apr  1 22:25:49 PST 2002

    IF p_txn_header_id IS NULL THEN
       SELECT sysdate,
         MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
       INTO x_sysdate,
         x_txn_header_id
       FROM DUAL;
    ELSE
       SELECT sysdate INTO x_sysdate FROM DUAL;
       x_txn_header_id := p_txn_header_id;
    END IF;

    -- 12.1 QWB Usability Improvements
    -- If the value of the variable p_ssqr_operation is 1 it means
    -- that the data insert is happening from a standalone QWB application, in
    -- which case the validations is not needed since its done online however
    -- in case of an OAF Txn Integration the valiadtion needs to be done to
    -- derive the Id values for the context elements
    --
    If (p_ssqr_operation IS NULL OR
        p_ssqr_operation = 2) THEN
        master_error_list := qa_validation_api.validate_row(
                                p_plan_id,
                                p_spec_id,
                                p_org_id,
                                p_who_created_by,
                                p_transaction_number,
                                p_transaction_id,
                                return_results_array,
                                p_message_array,
                                p_row_elements,
                                p_ssqr_operation);
    END IF;
    -- In case the call is from the self-service application
    -- then the results_record_arry needs to be populated
    --
    IF  (p_ssqr_operation = 1 OR
         p_ssqr_operation = 2) THEN
          -- For an ssqr operation the validations are not needed. Also
          -- all the online actions except those corresponding to the
          -- value not entered trigger conditiion would not be fired.
          -- hence making a call to the api processNotEnteredActions that
          -- would process those action conditions
          --
          master_error_list := qa_validation_api.processNotEnteredActions(
                                      p_plan_id        => p_plan_id,
                                      p_spec_id        => p_spec_id,
                                      p_ssqr_operation => p_ssqr_operation,
                                      p_row_elements   => p_row_elements,
                                      p_return_results_array => return_results_array,
                                      message_array          => p_message_array);

    END If;
    IF qa_validation_api.no_errors(master_error_list) THEN

       p_error_found := FALSE;

       -- construct INSERT sql part
       -- e.g insert statement trying to build INSERT INTO
       -- qa_results (collection_id, occurrence) VALUES (111, 222);

       insert_string := 'INSERT INTO qa_results (
                            collection_id,
                            occurrence,
                            last_update_date,
                            qa_last_update_date,
                            last_updated_by,
                            qa_last_updated_by,
                            creation_date,
                            qa_creation_date,
                            created_by,
                            last_update_login,
                            qa_created_by,
                            status,
                            transaction_number,
                            organization_id,
                            plan_id,
                            spec_id,
                            transaction_id,
                            txn_header_id ';


       -- construct VALUES sql part
       -- anagarwa: a bind variable current_date is introduced
       -- to store time in MM-DD-YYYY HH24:MI:SS format.
       -- This is a fix for bug #1691501 and 1708891(duplicate)
       -- If we don't use bind variable but use x_sysdate or sysdate
       -- the date is inserted as MM-DD-YYYY 00:00:00.
       -- For example on 6th Apr, 2001 the date inserted will be
       -- 06-06-2001 00:00:00
       --
       -- Bug 5912439.
       -- Performance issue due to the use of literals in the SQL below.
       -- Modified the SQL string to include bind variables. This is used
       -- to insert data in QA_RESULTS.
       -- skolluku Mon Apr 23 23:39:10 PDT 2007.
       --

       -- construct VALUES sql part
       /*value_string:=' VALUES ('||x_collection_id||', '||
                         x_occurrence||', '||
                         ':current_date'||', '||
                         ':current_date'||', '||
                         ''''||p_who_last_updated_by||''''|| ', '||
                         ''''||p_who_last_updated_by||''''||', '||
                         ':current_date'||', '||
                         ':current_date'||', '||
                         ''''||p_who_created_by||''''||', '||
                         ''''|| to_char(p_who_last_update_login)||''''||', '||
                         ''''||p_who_created_by||''''||', '||
                         p_enabled_flag || ', '||
                         nvl(to_char(p_transaction_number),'NULL')||', '||
                         to_char(p_org_id)||', '||
                         to_char(p_plan_id)||', '||
                         nvl(to_char(p_spec_id),'NULL')||', '||
                         nvl(to_char(p_transaction_id),'NULL')||', '||
                         x_txn_header_id;*/

        value_string:=' VALUES (:x_collection_id, :x_occurrence, :current_date, '
                          ||':current_date, :p_who_last_updated_by, '
                          ||':p_who_last_updated_by, :current_date, :current_date, '
                          ||':p_who_created_by, :p_who_last_update_login, '
                          ||':p_who_created_by, :p_enabled_flag, :p_transaction_number, '
                          ||':p_org_id, :p_plan_id, :p_spec_id, '
                          ||':p_transaction_id, :x_txn_header_id';



       i := return_results_array.first;
       j := 0;

       WHILE (i <= return_results_array.last) LOOP

           j := j+1;

           --
           -- Bug 3402251.  This small inefficiency was found during
           -- this bug fix, return_results_array(i).element_id is
           -- always the same as i.  In some rare assign-a-value case
           -- element_id was not populated.  So it is more correct to
           -- use i as the second parameter here.
           -- bso Mon Feb  9 21:42:46 PST 2004
           --
           column_name := qa_plan_element_api.get_result_column_name(
               p_plan_id, i);

          -- anagarwa Fri Dec 20 18:49:19 PST 2002
          -- Bug 2701777
          -- Though not directly related , the following issue was
          -- found while fixing this bug
          -- killing redundant code to avoid confusion

/*

           IF return_results_array(i).id IS NOT NULL THEN
               column_value := to_char(return_results_array(i).id);
           ELSE
               column_value := return_results_array(i).canonical_value;
           END IF;

           IF return_results_array(i).actual_datatype = qa_ss_const.date_datatype THEN

               column_value := qltdate.canon_to_user(column_value);

           ELSE

              -- other datatypes are character and number datatype
              -- need to put quotes for character data type

              column_value := '''' || column_value || '''';

           END IF;

*/
           insert_string := insert_string||','|| column_name;

           -- anagarwa Fri Dec 20 18:49:19 PST 2002
           -- Bug 2701777
           -- Though not directly related , the following issue was
           -- found while fixing this bug
           -- replaced value string to get correct date format
           -- value_string  := value_string ||','||':X'||to_char(j)||' ';

           IF return_results_array(i).actual_datatype in
                (qa_ss_const.date_datatype, qa_ss_const.datetime_datatype) THEN
              value_string := value_string ||', fnd_date.canonical_to_date(:X' || j || ') ';
           ELSE
              value_string  := value_string ||','||':X'||to_char(j)||' ';
           END IF;

           i := return_results_array.next(i);

       END LOOP;

       -- concatenate
       sql_string := insert_string||') '||value_string||') ';

       c := DBMS_SQL.OPEN_CURSOR;

       --dbms_output.put_line('DBMS PARSE');
       DBMS_SQL.PARSE(c, sql_string, DBMS_SQL.NATIVE);


       i := return_results_array.first;
       j := 0;

       WHILE (i <= return_results_array.last) LOOP

           j := j+1;

           IF return_results_array(i).id IS NOT NULL THEN
               column_value := to_char(return_results_array(i).id);
           ELSE
               column_value := return_results_array(i).canonical_value;
           END IF;

          -- anagarwa Fri Dec 20 18:49:19 PST 2002
          -- Bug 2701777
          -- Though not directly related , the following issue was
          -- found while fixing this bug
          -- canonical values have already been derived. The following code is
          -- redundant and incorrect
          -- killing incorrect code
/*

           IF return_results_array(i).actual_datatype = qa_ss_const.date_datatype THEN
               column_value := qltdate.canon_to_user(column_value);

           END IF;

*/
           -- Bug 5335509. SHKALYAN 15-Jun-2006
           -- Need to insert the value 'Automatic' for Sequences while
           -- posting results. Calling Sequence API function
           -- so as to get the translated value for 'Automatic'
           IF return_results_array(i).actual_datatype = qa_ss_const.sequence_datatype THEN
             column_value := QA_SEQUENCE_API.get_sequence_default_value;
           END IF;
           --
           -- bug 6933282
           -- Round off the number element to the decimal precision defined
           -- either on the plan level or on the element level before saving
           -- ntungare
           --
           IF qa_plan_element_api.get_element_datatype(return_results_array(i).element_id)
                    = qa_ss_const.number_datatype THEN
             l_precision := nvl(qa_plan_element_api.decimal_precision(p_plan_id,
                                                                      return_results_array(i).element_id),
                          qa_chars_api.decimal_precision(return_results_array(i).element_id));
             column_value := round(qltdate.any_to_number(column_value),nvl(l_precision, 240));
           END IF;

           DBMS_SQL.BIND_VARIABLE(c, ':X'||to_char(j), column_value);
           i := return_results_array.next(i);

       END LOOP;

       --dbms_output.put_line('DBMS EXECUTE');
       --
       -- Bug 5912439
       -- Performance issue due to the use of literals in the SQL .
       -- Binding the variables with corresponding values.
       -- skolluku Mon Apr 23 23:39:10 PDT 2007.
       --
       DBMS_SQL.BIND_VARIABLE(c, ':x_collection_id', x_collection_id);
       DBMS_SQL.BIND_VARIABLE(c, ':x_occurrence', x_occurrence);
       DBMS_SQL.BIND_VARIABLE(c, ':p_who_last_updated_by', p_who_last_updated_by);
       DBMS_SQL.BIND_VARIABLE(c, ':p_who_created_by', p_who_created_by);
       DBMS_SQL.BIND_VARIABLE(c, ':p_who_last_update_login', p_who_last_update_login);
       DBMS_SQL.BIND_VARIABLE(c, ':p_enabled_flag', p_enabled_flag);
       DBMS_SQL.BIND_VARIABLE(c, ':p_transaction_number', p_transaction_number);
       DBMS_SQL.BIND_VARIABLE(c, ':p_org_id', p_org_id);
       DBMS_SQL.BIND_VARIABLE(c, ':p_plan_id', p_plan_id);
       DBMS_SQL.BIND_VARIABLE(c, ':p_spec_id', p_spec_id);
       DBMS_SQL.BIND_VARIABLE(c, ':p_transaction_id', p_transaction_id);
       DBMS_SQL.BIND_VARIABLE(c, ':x_txn_header_id', x_txn_header_id);

       DBMS_SQL.BIND_VARIABLE(c, ':current_date', p_last_update_date);

       insert_dbms_sql_feedback := DBMS_SQL.EXECUTE(c);

       --dbms_output.put_line('DBMS CLOSE');
       DBMS_SQL.CLOSE_CURSOR(c);


       IF (p_commit_flag = TRUE) THEN
           COMMIT;

           IF p_enabled_flag=2 or p_enabled_flag= NULL THEN

               -- rkaza. bug 3183284. 12/11/2003.
               -- Modified x_colelction_id to x_txn_header_id
               -- Only EAM Asset Query and deferred completion should pass
               -- commit flag as true.
               actions_request_id := fnd_request.submit_request('QA', 'QLTACTWB', NULL,
                  NULL, FALSE, x_txn_header_id);

               p_do_action_return := TRUE;
           ELSE
               p_do_action_return := FALSE;

           END IF;


        END IF;

    ELSE

        p_error_found := TRUE;

    END IF;

    RETURN master_error_list;


    EXCEPTION  when others then
        raise;


END insert_row;

--
-- 12.1 QWB Usability Improvements
-- added a new parameter, p_ssqr_opperation to ensure
-- that the validation is not done again at the time of
-- updating rows through QWB
--
FUNCTION update_row( p_plan_id                 IN  NUMBER,
                     p_spec_id                 IN  NUMBER,
                     p_org_id                  IN  NUMBER,
                     p_transaction_number      IN  NUMBER  DEFAULT NULL,
                     p_transaction_id          IN  NUMBER  DEFAULT NULL,
                     p_collection_id           IN  NUMBER,
                     p_who_last_updated_by     IN  NUMBER  := fnd_global.user_id,
                     p_who_created_by          IN  NUMBER  := fnd_global.user_id,
                     p_who_last_update_login   IN  NUMBER  := fnd_global.user_id,
                     p_enabled_flag            IN  NUMBER,
                     p_commit_flag             IN  BOOLEAN DEFAULT FALSE,
                     p_error_found             OUT NOCOPY BOOLEAN,
                     p_occurrence              IN  NUMBER,
                     p_do_action_return        OUT NOCOPY BOOLEAN,
                     p_message_array           OUT NOCOPY qa_validation_api.MessageArray,
                     p_row_elements            IN  OUT NOCOPY qa_validation_api.ElementsArray,
                     p_txn_header_id           IN  NUMBER DEFAULT NULL,
                     p_ssqr_operation          IN  NUMBER DEFAULT NULL,
                     p_last_update_date        IN  DATE DEFAULT SYSDATE)
    RETURN qa_validation_api.ErrorArray IS



    return_results_array       qa_validation_api.ResultRecordArray;
    master_error_list          qa_validation_api.ErrorArray;

    update_string              varchar2(25)    := null;
    where_clause               varchar2(500)   := null;
    value_string               varchar2(30000) := null;
    insert_qruh                varchar2(1000)  := null;
    value_qruh                 varchar2(1000)  := null;
    sql_qruh                   varchar2(3000)  := null;

    sql_string                 varchar2(32000) := null;
    column_name                varchar2(240)   := null;
    update_column_value        varchar2(2000);

    i                          NUMBER;
    j                          NUMBER;
    k                          NUMBER;
    x_collection_id            NUMBER;
    x_txn_header_id            NUMBER;
    x_update_id                NUMBER;
    actions_request_id         NUMBER;
    x_sysdate                  date;

    c1                         INTEGER; /* cursor handler */
    update_dbms_sql_feedback   INTEGER;

    -- 12.1 QWB Usability improvements
    charctr NUMBER;

    --
    -- bug 6933282
    -- Variable to hold the decimal precision
    -- defined for a numeric element.
    -- ntungare
    --
    l_precision                NUMBER;
BEGIN

    x_collection_id         := p_collection_id;

    --    x_sysdate := sysdate;
    x_sysdate := p_last_update_date;

    -- anagarwa Sep 30 2003
    -- SSQR project relies upon txn_header_id to enable and fire actions
    -- following code looks for txn_header_id and generates a new one if
    -- not found.

    IF p_txn_header_id IS NULL THEN
       SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
       INTO x_txn_header_id
       FROM DUAL;
    ELSE
       x_txn_header_id := p_txn_header_id;
    END IF;

    -- 12.1 QWB Usability Improvements
    -- Call the validateRow Method only if the parameter
    -- p_ssqr_operation is NULL which means that the call
    -- of not from the self service application
    --
    If (p_ssqr_operation IS NULL) THEN
        master_error_list := qa_validation_api.validate_row(p_plan_id,
            p_spec_id, p_org_id, p_who_created_by, p_transaction_number,
            p_transaction_id, return_results_array, p_message_array,
            p_row_elements);
    -- In case the call is from the self-service application
    -- then the results_record_arry needs to be populated
    --
    ELSIF  (p_ssqr_operation = 1) THEN
        --perf
        charctr := p_row_elements.first;
        while charctr <= p_row_elements.last
           loop
              -- Set the element Id
              return_results_array(charctr).element_id := charctr;

              -- Check if the id value for the element is present
              if p_row_elements(charctr).id  IS NOT NULL THEN
                -- Set the id value
                return_results_array(charctr).id              := p_row_elements(charctr).id;
              ELSE
                -- Set the canonical value
                return_results_array(charctr).canonical_value := p_row_elements(charctr).value;

                --
                -- bug 6933282
                -- Round off the number element to the decimal precision defined
                -- either on the plan level or on the element level before saving
                -- ntungare
                --
                IF qa_plan_element_api.get_element_datatype(charctr)
                         = qa_ss_const.number_datatype THEN
                  l_precision := nvl(qa_plan_element_api.decimal_precision(p_plan_id,
                                                                           charctr),
                                     qa_chars_api.decimal_precision(charctr));
                  return_results_array(charctr).canonical_value :=
                                 round(qltdate.any_to_number(return_results_array(charctr).canonical_value),
                                       nvl(l_precision, 240));
                END IF;
              END If;

              -- Set the actual data type
              return_results_array(charctr).actual_datatype := qa_plan_element_api.get_actual_datatype(charctr);

              charctr := p_row_elements.next(charctr);
           end loop;
    END If;

    IF qa_validation_api.no_errors(master_error_list) THEN

        p_error_found := FALSE;


        update_string := 'UPDATE QA_RESULTS ';

        -- Bug 3776542. Performance issue due to the use of literals in the SQL below.
        -- Modified the SQL string to include bind variables.This where_clause is used
        -- to update/insert data in QA_RESULTS and QA_RESULTS_UPDATE_HISTORY.
        -- srhariha. Thu Jul 29 00:27:59 PDT 2004.
        where_clause  := 'WHERE collection_id     = '||':x_collection_id'||
                             ' AND '||'occurrence = '||':p_occurrence'||
                             ' AND '||'plan_id    = '||':p_plan_id';


    -- anagarwa Sep 30 2003
    -- SSQR project relies upon txn_header_id to enable and fire actions

        -- anagarwa Mon Mar  8 12:18:47 PST 2004
        -- Bug 3489530 Last_update_date was missing from this sql
        -- also made qa_last_update_date a bind variable so that the
        -- time portion  is stored properly
        -- Finally rest of the sql string is also modified to use bind
        -- variables to follow standards as currently enforced
        value_string  := 'SET  qa_last_update_date = '|| ':current_date'||', '||
                             ' last_update_date = '|| ':current_date'||', '||
                             ' last_updated_by = '|| ':updated_by'||', '||
                             ' qa_last_updated_by = '|| ':updated_by'||', '||
                             ' last_update_login = '|| ':update_login'||', '||
                             ' txn_header_id = '|| ':txn_hdr_id';

        insert_qruh   := ' INSERT INTO qa_results_update_history (creation_date,
                                                                  last_update_date,
                                                                  created_by,
                                                                  last_update_login,
                                                                  last_updated_by,
                                                                  occurrence,
                                                                  update_id,
                                                                  old_value,
                                                                  char_id) ';

        -- Bug 3776542. Performance issue due to the use of literals in the SQL below.
        -- Modified the string to include bind variables.
        -- srhariha. Thu Jul 29 00:27:59 PDT 2004.

        value_qruh    := '(SELECT '||':creation_date'||','||
                                     ':last_upd_date'||','||
                                     ':created_by'|| ' ,'||
                                     ':update_login'|| ' ,'||
                                     ':updated_by'|| ' ,'||
                                     ':p_occurrence'||' ,';




        i := return_results_array.first;
        k := 0;

        WHILE (i <= return_results_array.last) LOOP

            k := k +1;

            -- See comments above for Bug 3402251
            column_name := qa_plan_element_api.get_result_column_name(
                p_plan_id, i);

            -- bug 3178307. rkaza. 10/06/2003. Timezone support.
            IF return_results_array(i).actual_datatype in
                (qa_ss_const.date_datatype, qa_ss_const.datetime_datatype) THEN
              value_string := value_string || ', ' || column_name || ' = ' || 'fnd_date.canonical_to_date(:X' || k || ') ';
            ELSE
              value_string  := value_string || ', ' || column_name || ' = ' || ':X' || to_char(k) || ' ';
            END IF;

            SELECT QA_RESULTS_UPDATE_HISTORY_S.NEXTVAL INTO x_update_id FROM DUAL;

           -- Bug 3776542. Performance issue due to the use of literals in the SQL below.
           -- Modified the string to include bind variables.
           -- srhariha. Thu Jul 29 00:27:59 PDT 2004.

            sql_qruh :=  insert_qruh|| value_qruh||':x_update_id'||', '||column_name||','||
                             ':element_id'||' FROM QA_RESULTS  '||where_clause ||' )';

            -- Bug 3776542. Performance issue due to the use of literals in the SQL .
            -- Binding the variables with corresponding values.
            -- srhariha. Thu Jul 29 00:27:59 PDT 2004.

            EXECUTE IMMEDIATE sql_qruh
                    USING     x_sysdate,
                              x_sysdate,
                              p_who_last_updated_by,
                              p_who_last_updated_by,
                              p_who_last_updated_by,
                              p_occurrence,
                              x_update_id,
                              return_results_array(i).element_id,
                              x_collection_id,
                              p_occurrence,
                              p_plan_id;

            i := return_results_array.next(i);


        END LOOP;

        -- concatenate

        sql_string := update_string||' '||value_string||' '||where_clause;

        c1 := DBMS_SQL.OPEN_CURSOR;

        --dbms_output.put_line('DBMS PARSE');
        DBMS_SQL.PARSE(c1, sql_string, DBMS_SQL.NATIVE);

        j := return_results_array.first;
        k := 0;

        WHILE (j <= return_results_array.last) LOOP

            k := k +1;

            column_name := qa_plan_element_api.get_result_column_name(
                p_plan_id, return_results_array(j).element_id);


            IF return_results_array(j).id IS NOT NULL THEN
                 update_column_value := to_char(return_results_array(j).id);
            ELSE
                 update_column_value := return_results_array(j).canonical_value;
            END IF;

            -- dbms_output.put_line('bind varaible ->'||':X'||to_char(k));

            DBMS_SQL.BIND_VARIABLE(c1, ':X'||to_char(k), update_column_value);
            -- anagarwa Mon Mar  8 12:18:47 PST 2004
            -- Bug 3489530 last_update_Date is added as bind variable so
            -- we need to bind value here.
            -- also updated_by and update login were made bind variables to
            -- comply with coding standards
            DBMS_SQL.BIND_VARIABLE(c1, ':current_date', x_sysdate);
            DBMS_SQL.BIND_VARIABLE(c1, ':updated_by', p_who_last_updated_by);
            DBMS_SQL.BIND_VARIABLE(c1, ':update_login', p_who_last_updated_by);
            DBMS_SQL.BIND_VARIABLE(c1, ':txn_hdr_id', x_txn_header_id);

            -- Bug 3776542. Performance issue due to the use of literals in the SQL .
            -- Binding the variables with corresponding values.
            -- srhariha. Thu Jul 29 00:27:59 PDT 2004.

            DBMS_SQL.BIND_VARIABLE(c1, ':x_collection_id', x_collection_id);
            DBMS_SQL.BIND_VARIABLE(c1, ':p_occurrence', p_occurrence);
            DBMS_SQL.BIND_VARIABLE(c1, ':p_plan_id', p_plan_id);



            j := return_results_array.next(j);


         END LOOP;

         update_dbms_sql_feedback := DBMS_SQL.EXECUTE(c1);

         DBMS_SQL.CLOSE_CURSOR(c1);


         IF (p_commit_flag = TRUE) THEN
             COMMIT;

             IF p_enabled_flag=2 or p_enabled_flag= NULL THEN

                 actions_request_id := fnd_request.submit_request('QA', 'QLTACTWB', NULL,
                     NULL, FALSE, x_collection_id);

                 p_do_action_return := TRUE;
             ELSE
                 p_do_action_return := FALSE;

             END IF;


         END IF;


    ELSE

        p_error_found := TRUE;

    END IF;

    RETURN master_error_list;


    EXCEPTION  when others then
        raise;



END update_row;

/* akbhatia - Bug 3345279 : Added the following procedure enable. */

PROCEDURE enable (p_collection_id     IN  NUMBER ) IS

BEGIN

     UPDATE qa_results
     SET status=2
     WHERE collection_id = p_collection_id;

    EXCEPTION  when others then
        raise;

END enable;

END qa_results_api;


/
