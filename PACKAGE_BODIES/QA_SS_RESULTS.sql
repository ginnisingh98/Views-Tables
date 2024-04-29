--------------------------------------------------------
--  DDL for Package Body QA_SS_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_RESULTS" AS
/* $Header: qltssreb.plb 120.25.12010000.2 2010/04/16 11:56:59 skolluku ship $ */


    g_message_table mesg_table;


PROCEDURE populate_message_table IS

BEGIN

    g_message_table(qa_validation_api.not_enabled_error) :=
        'QA_API_NOT_ENABLED';
    g_message_table(qa_validation_api.no_values_error) := 'QA_API_NO_VALUES';
    g_message_table(qa_validation_api.mandatory_error) := 'QA_API_MANDATORY';
    g_message_table(qa_validation_api.not_revision_controlled_error) :=
        'QA_API_REVISION_CONTROLLED';
    g_message_table(qa_validation_api.mandatory_revision_error) :=
        'QA_API_MANDATORY_REVISION';
    g_message_table(qa_validation_api.no_values_error) := 'QA_API_NO_VALUES';
    g_message_table(qa_validation_api.keyflex_error) := 'QA_API_KEYFLEX';
    g_message_table(qa_validation_api.id_not_found_error) :=
        'QA_API_ID_NOT_FOUND';
    g_message_table(qa_validation_api.spec_limit_error) := 'QA_API_SPEC_LIMIT';
    g_message_table(qa_validation_api.immediate_action_error) :=
        'QA_API_IMMEDIATE_ACTION';
    g_message_table(qa_validation_api.lower_limit_error) :=
        'QA_API_LOWER_LIMIT';
    g_message_table(qa_validation_api.upper_limit_error) :=
        'QA_API_UPPER_LIMIT';
    g_message_table(qa_validation_api.value_not_in_sql_error) :=
        'QA_API_VALUE_NOT_IN_SQL';
    g_message_table(qa_validation_api.sql_validation_error) :=
        'QA_API_SQL_VALIDATION';
    g_message_table(qa_validation_api.date_conversion_error) :=
        'QA_API_INVALID_DATE';
    g_message_table(qa_validation_api.data_type_error) := 'QA_API_DATA_TYPE';
    g_message_table(qa_validation_api.number_conversion_error) :=
        'QA_API_INVALID_NUMBER';
    g_message_table(qa_validation_api.no_data_found_error) :=
        'QA_API_NO_DATA_FOUND';
    g_message_table(qa_validation_api.not_locator_controlled_error) :=
        'QA_API_NOT_LOCATOR_CONTROLLED';
    g_message_table(qa_validation_api.item_keyflex_error) :=
        'QA_API_ITEM_KEYFLEX';
    g_message_table(qa_validation_api.comp_item_keyflex_error) :=
        'QA_API_COMP_ITEM_KEYFLEX';
    g_message_table(qa_validation_api.comp_locator_keyflex_error) :=
        'QA_API_COMP_LOCATOR_KEYFLEX';
    g_message_table(qa_validation_api.invalid_number_error) :=
        'QA_API_INVALID_NUMBER';
    g_message_table(qa_validation_api.invalid_date_error) :=
        'QA_API_INVALID_DATE';
    g_message_table(qa_validation_api.spec_error) := 'QA_API_SPEC';
    g_message_table(qa_validation_api.ok) := 'QA_API_NO_ERROR';
    g_message_table(qa_validation_api.unknown_error) := 'QA_API_UNKNOWN';
    g_message_table(qa_validation_api.reject_an_entry_error) :=
        'QA_API_REJECT_AN_ENTRY';

       -- Bug 3679762.Initialising the message array for the missing assign a value target
       -- column error message.
       -- srhariha.Wed Jun 16 06:54:06 PDT 2004

    g_message_table(qa_validation_api.missing_assign_column) :=
        'QA_MISSING_ASSIGN_COLUMN';


END populate_message_table;

    --
    -- Bug 5932426
    -- New Procedure to check if the data entered in a
    -- collection element during an update Txn has been
    -- changed, in which case the validation is not to be
    -- performed and so the action on that element wont
    -- refire.
    -- ntungare Sat Apr 14 00:51:48 PDT 2007
    --
    PROCEDURE update_validation_flg(elements    IN OUT NOCOPY qa_validation_api.ElementsArray,
                                    p_plan_id       IN NUMBER,
                                    p_collection_id IN NUMBER,
                                    p_occurrence    IN NUMBER) AS

       char_id     INTEGER;
       input_val   VARCHAR2(32767);
       saved_val   VARCHAR2(32767);
       --
       -- bug 6266477
       -- Variable declaration
       -- skolluku Sun Oct 14 03:26:31 PDT 2007
       --
       l_append     BOOLEAN := FALSE;
       l_rescol     VARCHAR2(30);
       l_rescol_val VARCHAR2(32767);
       l_sql_string VARCHAR2(32767);
       elements_db  qa_validation_api.ElementsArray;

       -- Bug 9582246
       -- New variables for obtaining COMMENTS result String.
       -- skolluku
       l_comments_rescol_val VARCHAR2(32767);
       l_comments_sql_string VARCHAR2(32767);
       l_comments_result_string VARCHAR2(32767);

    BEGIN
       char_id:= elements.first;

       -- Looping through the elements
       --
       --
       -- bug 6266477
       -- Loop through all the char_id and get their
       -- result_column_names to build the select clause
       -- for fetching their values from QA_RESULTS_FULL_V
       -- skolluku Sun Oct 14 03:26:31 PDT 2007
       --
       WHILE char_id <= elements.last
          LOOP
             --input_val := elements(char_id).value;

             -- Getting the result_column_name stored in QA_PLAN_CHARS,
             -- for the collection and append it to the string.
             --
             l_rescol := QA_ERES_PKG.get_result_column_name(p_plan_id, char_id);
             --
             -- bug 7194013
             -- Check if the derived result column name is NULL in which
             -- case the collection element needs to be removed from the
             -- elements array since it does not exist in the Collection
             -- plan
             -- ntungare
             --
             IF (l_rescol IS NOT NULL) THEN
               -- Bug 9582246
               -- Condition required because separate processing would be done for COMMENTS elements.
               -- skolluku
               IF (l_rescol NOT LIKE 'COMMENT%') THEN
                IF(l_append) THEN
                   l_sql_string := l_sql_string || ' || ''@';
                   l_sql_string := l_sql_string || char_id || '='' || ' || 'replace(' || l_rescol || ', ''@'', ''@@'')';
                ELSE
                   l_sql_string := l_sql_string || '''' || char_id || '='' || ' || 'replace(' || l_rescol || ', ''@'', ''@@'')';
                END IF;
               ELSE
                 -- Bug 9582246
                 -- Here we will build result string for each COMMENT type element in the plan, separately
                 -- and concatenate them together to form a single COMMENTS result string to be used later in the code.
                 -- This is needed because of the limit in SQL output of 4000 characters.
                 -- skolluku
                 l_comments_sql_string := 'SELECT ''' || char_id || '='' || ' || 'replace(' || l_rescol || ', ''@'', ''@@'') FROM QA_RESULTS_FULL_V WHERE plan_id = :2 and collection_id = :3 and occurrence = :4';
                 EXECUTE IMMEDIATE l_comments_sql_string INTO l_comments_result_string USING p_plan_id, p_collection_id, p_occurrence;
                 IF l_comments_rescol_val IS NULL THEN -- First time.
                   l_comments_rescol_val := l_comments_result_string;
                 ELSE
                   l_comments_rescol_val := l_comments_rescol_val || '@' || l_comments_result_string;
                 END IF;
               END IF; -- Bug 9582246
               l_append := TRUE;
             ELSE
                elements.delete(char_id);
             END IF;

             char_id:= elements.next(char_id);
          END LOOP;

       -- Execute the statement and fetch the values into an array
       -- using result_to_array.
       -- Bug 9582246
       -- In case only COMMENTS elements are present, skip this part.
       -- skolluku
       IF l_sql_string IS NOT NULL THEN
          l_sql_string := 'SELECT ' || l_sql_string || ' FROM QA_RESULTS_FULL_V WHERE plan_id = :2 and collection_id = :3 and occurrence = :4';
          EXECUTE IMMEDIATE l_sql_string INTO l_rescol_val USING p_plan_id, p_collection_id, p_occurrence;
       END IF;

       -- Bug 9582246
       -- Append the COMMENTS result string obtained earlier to the other result string.
       -- skolluku
       IF l_comments_rescol_val IS NOT NULL THEN
         IF l_rescol_val IS NULL THEN
            l_rescol_val := l_comments_rescol_val;
         ELSE
            l_rescol_val := l_rescol_val || '@' || l_comments_rescol_val;
         END IF;
       END IF; -- End changes for bug 9582246
                 elements_db := qa_validation_api.result_to_array(l_rescol_val);

       -- Reinitialize the char_id variable since, the comparison
       -- needs to be done here. So, looping again...
       char_id:= elements.first;
       -- Looping through the elements
       --
       WHILE char_id <= elements.last
          LOOP
             input_val := elements(char_id).value;
             --
             -- bug 6266477
             -- Commented the call to get_result_column_value since,
             -- it fetches one value at a time from QA_RESULTS_FULL_V
             -- resulting in performance issues. To avoid this the hit
             -- to QA_RESULTS_FULL_V is done just once and collected
             -- into the array elements_db in the earlier processing.
             -- skolluku Sun Oct 14 03:26:31 PDT 2007
             --
             -- Getting the value stored in QA_RESULTS, for the collection
             -- element being processed
             --
             /*
             saved_val := QA_ERES_PKG.get_result_column_value(
                                 p_plan_id       => p_plan_id,
                                 p_collection_id => p_collection_id,
                                 p_occurrence    => p_occurrence,
                                 p_char_id       => char_id);
             */
             saved_val := elements_db(char_id).value;
             -- If the input value is the same as the
             -- value already existing in QA_RESULTS, it means that
             -- the element has not been updated, in which case the
             -- actions based on it are not to be fired. So setting
             -- the validation flag for this element accordingly
             --
             If NVL(input_val,'0') = NVL(saved_val,'0') THEN
                elements(char_id).validation_flag := qa_validation_api.action_fired;
             End If;

             char_id:= elements.next(char_id);
          END LOOP;
    END update_validation_flg;


    FUNCTION get_error_code(code IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        --
        -- Should figure out the error message from dictionary.
        --
        RETURN qa_validation_api.get_error_message (code);
    END get_error_code;


    --
    -- Get the error messages and append them into an @-separated
    -- string.
    --
    PROCEDURE get_error_messages(
        p_errors IN qa_validation_api.ErrorArray,
        p_plan_id IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2) IS

        separator CONSTANT VARCHAR2(1) := '@';
        name qa_chars.prompt%TYPE;
        code VARCHAR2(2000);

        -- Bug 5307450
        -- Cursor to get the message entered by the user for the
        -- 'Reject the input' action in the collection plan.
        -- ntungare Tue Mar 28 08:02:43 PST 2006.
        --
        CURSOR cur_mesg(p_plan_id NUMBER,p_char_id NUMBER) IS
               SELECT message
                 FROM qa_plan_char_actions
                WHERE plan_char_action_trigger_id IN
                      (SELECT plan_char_action_trigger_id
                         FROM qa_plan_char_action_triggers
                        WHERE plan_id = p_plan_id
                          AND char_id = p_char_id)
                  AND action_id = 2;
    BEGIN
        x_messages := '';

        --
        -- This bug is discovered during bug fix for 3402251.
        -- In some rare situation, this proc can be called when
        -- error stack is actually empty.  Should return
        -- immediately.
        -- bso Mon Feb  9 22:06:09 PST 2004
        --
        IF p_errors.count = 0 then
            RETURN;
        END IF;

        FOR i IN p_errors.FIRST .. p_errors.LAST LOOP
            name := qa_plan_element_api.get_prompt(p_plan_id,
                p_errors(i).element_id);
            --
            -- Just in case the prompt contains @
            --
            name := replace(name, separator, separator||separator);

            -- Bug 5307450
            -- In QWB if the action is 'Reject the input' we were displaying the
            -- seeded error message 'QA_API_REJECT_AN_ENTRY' and not the message
            -- added in the collection plan setup by the user. Now the following
            -- condition would get the 'Reject the input' action message
            -- from the collection plan and put in the variable code. If the action
            -- is not 'Reject the input' then the existing code is used.
            -- ntunagre Tue Mar 28 08:04:54 PST 2006.
            --
            If p_errors(i).error_code = qa_validation_api.reject_an_entry_error then
              OPEN cur_mesg(p_plan_id, p_errors(i).element_id);
              FETCH cur_mesg INTO code;
              CLOSE cur_mesg;
            else
              code := get_error_code(p_errors(i).error_code);
            End If;

            x_messages := x_messages || name || ': ' || code;
            IF i < p_errors.LAST THEN
                x_messages := x_messages || separator;
            END IF;
        END LOOP;
    END get_error_messages;


    --
    -- Get the action messages and append them into an @-separated
    -- string.
    --
    PROCEDURE get_action_messages(
        msg_array IN qa_validation_api.MessageArray,
        plan_id IN NUMBER,
        messages OUT NOCOPY VARCHAR2) IS

        separator CONSTANT VARCHAR2(1) := '@';
        name qa_chars.prompt%TYPE;
        code VARCHAR2(2000);
    BEGIN

        messages := '';

        IF msg_array.COUNT <> 0 THEN
            FOR i IN msg_array.FIRST .. msg_array.LAST LOOP
               --ilawler - bug #3340004 - Mon Feb 16 18:53:29 2004
               --According to bso, the message should always be <target> = <value>

               /*
               name := qa_plan_element_api.get_prompt(plan_id, msg_array(i).element_id);

               --
               -- Just in case the prompt contains @
               --
               name := replace(name, separator, separator||separator);
               messages := messages || name || ':' || msg_array(i).message;
               */
               messages := messages || msg_array(i).message;

               IF i < msg_array.LAST THEN
                  messages := messages || separator;
               END IF;
            END LOOP;
        END IF;

    END get_action_messages;

    --
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row
    --
    -- This function is used by
    --
    -- CMRO/QA Integration /ahldev/ahl/12.0/patch/115/sql/AHLVQARB.pls
    --
    -- MQA DDE /qadev/qa/12.0/patch/115/sql/qaresb.pls
    --
    -- Return 0 if OK
    -- Return -1 if error.
    --
    FUNCTION nontxn_post_result(
        x_occurrence OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_messages OUT NOCOPY VARCHAR2)
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);
    BEGIN

    --
    -- Bug 2617638
    -- The original statement returns if x_result IS NULL.
    -- Undesirable if caller passes all validated IDs in x_result1.
    -- Added AND x_result1 IS NULL
    -- bso Tue Oct  8 18:34:38 PDT 2002
    --
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;

        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --
        elements := qa_validation_api.result_to_array(x_result);
        elements := qa_validation_api.id_to_array(x_result1, elements);
        qa_validation_api.set_validation_flag(elements);

    --
    -- Bug 2617638
    -- The follow statement is needed to process x_result1.
    -- This has been included in function post_result but
    -- was missed out in this procedure.
    -- bso Tue Oct  8 18:37:00 PDT 2002
    --

        qa_results_pub.insert_row(
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_org_id => x_org_id,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_transaction_number => null,
            p_transaction_id => null,
            p_enabled_flag => x_enabled,
            p_commit => y_committed,
            x_collection_id => y_collection_id,
            x_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result);

        IF qa_validation_api.no_errors(error_array) AND
           return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            RETURN 0;
        ELSE
            get_error_messages(error_array, x_plan_id, x_messages);
        END IF;

        RETURN -1;
    END nontxn_post_result;

    --
    -- Bug 5955808
    -- New procedure to initalize the Sequence Type
    -- Collection elements with the default value of
    -- Automatic, using which the Sequence generation
    -- program will generate sequences. This is very
    -- important in case of Background result collection
    -- ntungare Mon Mar 26 06:20:05 PDT 2007
    --
    PROCEDURE initialize_seq_elements(x_plan_id IN NUMBER,
                                      elements IN OUT NOCOPY qa_validation_api.ElementsArray)
      IS
        TYPE seq_charid_tab_typ IS TABLE OF qa_chars.char_id%TYPE INDEX BY BINARY_INTEGER;
        seq_charid_tab seq_charid_tab_typ;

        def_seq_val VARCHAR2(100);
    BEGIN
        SELECT qc.char_id
          BULK COLLECT INTO seq_charid_tab
           FROM qa_chars qc, qa_plan_chars qpc
         WHERE qpc.plan_id = x_plan_id
           AND qc.char_id = qpc.char_id
           AND qc.datatype = 5;

         IF seq_charid_tab.COUNT <> 0 THEN
           def_seq_val := QA_SEQUENCE_API.get_sequence_default_value();
         END IF;

         FOR cntr IN 1..seq_charid_tab.COUNT
           LOOP
               If elements(seq_charid_tab(cntr)).VALUE IS NULL THEN
                  elements(seq_charid_tab(cntr)).VALUE := def_seq_val;
               End If;
           END LOOP;
    END initialize_seq_elements;

    --
    -- This overloaded method is for transaction only
    -- Post a result to the database.  This is a wrapper to the QA API
    -- qa_results_api.insert_row
    --
    -- This function is used by
    --
    -- iSP /qadev/qa/12.0/java/dde/eam/server/QaResultsVORowImpl.java
    --
    -- EAM /qadev/qa/12.0/java/selfservice/server/QaResultsVORowImpl.java
    --
    -- MQA Txn /qadev/qa/12.0/patch/115/sql/qaresb.pls
    --
    -- Return 0 if OK
    -- Return -1 if error.
    --
    FUNCTION post_result(
        x_occurrence IN OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2)
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);
    BEGIN

    --
    -- Bug 2617638
    -- The original statement returns if x_result IS NULL.
    -- Undesirable if caller passes all validated IDs in x_result1.
    -- Added AND x_result1 IS NULL
    -- bso Tue Oct  8 18:34:38 PDT 2002
    --
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

        IF x_transaction_number IS NULL THEN
            RETURN -1;
        END IF;

        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;
        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --
        elements := qa_validation_api.result_to_array(x_result);
        elements := qa_validation_api.id_to_array(x_result1, elements);

        IF (x_transaction_number IS NOT NULL) AND (x_transaction_number > 0) THEN
            qa_validation_api.set_validation_flag_txn(
                x_elements => elements,
                p_plan_id => x_plan_id,
                p_transaction_number => x_transaction_number,
                p_plan_transaction_id => NULL);
        END IF;

        --
        -- bug 5955808
        -- Making a call to the proc which would initialize
        -- the seq type collection elements with the value
        -- automatic
        -- Mon Mar 26 06:21:43 PDT 2007
        --
        initialize_seq_elements(x_plan_id, elements);

        qa_results_pub.insert_row(
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_org_id => x_org_id,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_transaction_number => x_transaction_number,
            p_transaction_id => null,
            p_enabled_flag => x_enabled,
            p_commit => y_committed,
            x_collection_id => y_collection_id,
            x_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result);

        IF qa_validation_api.no_errors(error_array) AND
           return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            get_action_messages(message_array, x_plan_id, x_messages);
            RETURN 0;
        ELSE
            get_error_messages(error_array, x_plan_id, x_messages);
            --
            -- Remove commit; completely.  The insert_row API
            -- will take care of committing according to the
            -- x_committed flag.
            --
        END IF;


        RETURN -1;
    END post_result;

    --
    -- This overloaded method is for ssqr
    -- Same as post_result. In addition, it inserts pc history and automatic records.
    --
    -- Used only by QWB and Fwk Integration
    -- /qadev/qa/12.0/java/ssqr/server/QualityResultsEOImpl.java
    --
    -- Pass -1 to x_transaction_number when using standalone.
    --
    -- Return 0 if OK
    -- Return -1 if error.
    --
    -- 12.1 QWB Usability Improvements
    -- Added 2 new parameters x_agg_elements and x_agg_val
    -- to ensure that the value aggregated for any of the parent
    -- collection elements is pushed into the JAVA layer for
    -- assigned to the appropriate EO attributes.
    --
    FUNCTION ssqr_post_result(
        x_occurrence IN OUT NOCOPY NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_txn_header_id IN NUMBER,
        x_par_plan_id IN NUMBER,
        x_par_col_id IN NUMBER,
        x_par_occ IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        x_agg_elements OUT NOCOPY VARCHAR2,
        x_agg_val OUT NOCOPY VARCHAR2,
        p_last_update_date IN DATE DEFAULT SYSDATE)
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);

        -- anagarwa Wed May 26 17:07:29 PDT 2004
        -- bug 3667449
        l_ret_value VARCHAR2(1);

        -- bug 4658275
        -- for supporting Eres functionality
        l_esig_status BOOLEAN ;

        -- 12.1 QWB Usability Improvements
        --
        agg_elements  VARCHAR2(4000);
        agg_vals      VARCHAR2(4000);

	l_ssqr_operation  NUMBER;

        l_dummy VARCHAR2(1);

    BEGIN

 --messages should be cleared everytime a Submit is clicked on client
    fnd_msg_pub.Initialize();
    fnd_msg_pub.reset();

    --
    -- Bug 2617638
    -- The original statement returns if x_result IS NULL.
    -- Undesirable if caller passes all validated IDs in x_result1.
    -- Added AND x_result1 IS NULL
    -- bso Tue Oct  8 18:34:38 PDT 2002
    --
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

/*
        IF x_transaction_number IS NULL THEN
            RETURN -1;
        END IF;
*/
        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;

        -- Bug 4658275. eres support in QWB
        -- check for the collection id of parent and child
        -- if collection Id is same then we are entering
        -- child row immediately in the same session
        -- check is only required when parent row is
        -- already in database in status 2
        IF ( x_par_col_id <> x_collection_id ) THEN
           l_esig_status := validate_esig_for_insert(p_plan_id  => x_par_plan_id,
                                 p_plan_collection_id => x_par_col_id,
                                 p_plan_occurrence => x_par_occ );
           IF NOT l_esig_status THEN
                RETURN -1;
            END IF;
        END IF; -- x_par_col_id <> x_collection_id

        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --
        elements := qa_validation_api.result_to_array(x_result);
        elements := qa_validation_api.id_to_array(x_result1, elements);

        IF (x_transaction_number IS NOT NULL) AND (x_transaction_number > 0) THEN
            qa_validation_api.set_validation_flag_txn(
                x_elements => elements,
                p_plan_id => x_plan_id,
                p_transaction_number => x_transaction_number,
                p_plan_transaction_id => NULL);
        END IF;

        -- If the Txn number is 0 or -1 then it means that the
        -- txn is not an OAF Txn so set the value as 1 else 2
        -- The difference is that for the OAF Txns (stauts 2)
        -- the validation needs to be done again to derive the
        -- Id values for the context elements.
        -- This is not needed in case of Standalone entry in QWB
        --
	If x_transaction_number IN (0, -1) then
	   l_ssqr_operation := 1;
        Else
	   l_ssqr_operation := 2;
        End If;

	-- 12.1 QWB Usability Improvements
        -- Passing a new parameter p_ssqr_operation to indicate
        -- that the processing is being done for QWB application
        -- that would ensure that the Row Validation is not done
        -- again at the time of the data insertion
        --
        qa_results_pub.insert_row(
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_org_id => x_org_id,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_transaction_number => x_transaction_number,
            p_transaction_id => null,
            p_txn_header_id => x_txn_header_id,
            p_enabled_flag => x_enabled,
            p_commit => y_committed,
            x_collection_id => y_collection_id,
            x_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result,
            p_ssqr_operation => l_ssqr_operation,
            p_last_update_date => p_last_update_date);

        IF qa_validation_api.no_errors(error_array) AND
           return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            get_action_messages(message_array, x_plan_id, x_messages);

            --create relationship with parent

            -- Bug 4343758. OA Framework Integration project.
            -- Shouldnt create relationship if parent plan is null.
            -- srhariha. Wed May 18 04:34:53 PDT 2005.
            -- 12.1 QWB Usability Improvements
            -- Get the aggregated values for tge Parent plan elements
            --

            if(x_par_plan_id is not null) then
                 --
                 -- bug 7046071
                 -- Passing the p_ssqr_operation parameter to check if the
                 -- call is done from the OAF application or from Forms
                 -- In case of the OAF application, the COMMIT that is
                 -- executed in the aggregate_parent must not be called
                 -- ntungare
                 --
                 qa_parent_child_pkg.relate(x_par_plan_id, x_par_col_id,
                                           x_par_occ, x_plan_id,
                                           x_collection_id, x_occurrence,
                                           x_txn_header_id,
                                           agg_elements,
                                           agg_vals,
                                           l_ssqr_operation);
                 -- If the parent Collection id is not equal to the child collection
                 -- Id it means that the Child record is being added to an existing
                 -- parent record in which case the Aggregation processing needs to
                 -- be done
                 --
                 -- Bug 6729769
                 -- This check is no longer needed since OAF will always call
                 -- the update API for the parent when a Child record is inserted.
                 -- The History record would be inserted when the update for parent is
                 -- called. If a Hist record is already present for the parent record
                 -- for the txn then it would be updated
                 -- ntungare
                 --
                 --if (x_par_col_id <> x_collection_id) THEN
                    x_agg_elements := RTRIM(LTRIM(agg_elements,','),',');
                    x_agg_val      := RTRIM(LTRIM(agg_vals,','),',');
                 -- else if both the parent and the child records are being
                 -- inserted anew then History child records need to be explicitly
                 -- updated if the aggregation has happened
                 --
		 /*
                 else
                    if (agg_elements IS NOT NULL) THEN
                       l_dummy := QA_PARENT_CHILD_PKG.update_hist_children(
		                       p_parent_plan_id       => x_par_plan_id,
                                       p_parent_collection_id => x_par_col_id,
                                       p_parent_occurrence    => x_par_occ);
                    end if;
                 end if;
                 */
            end if;

            -- Bug 3536025. Calling new procedure insert_history_auto_rec_QWB
            -- instead of insert_history_auto_rec. The new procedure is same as
            -- the old one except it doesnot changes child plan's txn_header_id
            -- and doesnot fire actions for child plans.
            -- srhariha. Wed May 26 22:31:28 PDT 2004


/*
            qa_parent_child_pkg.insert_history_auto_rec_QWB(x_plan_id,
                                                            x_txn_header_id,
                                                            1,
                                                            2);
            qa_parent_child_pkg.insert_history_auto_rec_QWB(x_plan_id,
                                                            x_txn_header_id,
                                                            1,
                                                            4);
*/

            -- Bug 4343758. OA Framework Integration project.
            -- Shouldnt create history and automatic for txn scenario.
            -- srhariha. Wed May 18 04:34:53 PDT 2005.

            -- Bug 3681815. Changing the call to proc below as the signature got
            -- changed due to the bug.
            -- commenting the previous calls to proc above.
            -- saugupta Tue, 15 Jun 2004 05:51:00 -0700 PDT

            -- insert automatic records
            if (x_enabled = 2 or x_enabled is null) then

                 qa_parent_child_pkg.insert_history_auto_rec_QWB(p_plan_id => x_plan_id,
                                            p_collection_id     => y_collection_id,
                                            p_occurrence        => x_occurrence,
                                            p_organization_id   => x_org_id,
                                            p_txn_header_id     => x_txn_header_id,
                                            p_relationship_type => 1,
                                            p_data_entry_mode   => 2,
                                            x_status            => return_status);
                 -- insert history records
                 qa_parent_child_pkg.insert_history_auto_rec_QWB(p_plan_id => x_plan_id,
                                            p_collection_id     => y_collection_id,
                                            p_occurrence        => x_occurrence,
                                            p_organization_id   => x_org_id,
                                            p_txn_header_id     => x_txn_header_id,
                                            p_relationship_type => 1,
                                            p_data_entry_mode   => 4,
                                            x_status            => return_status);
            end if;



            -- Bug 4343758. OA Framework Integration project.
            -- Shouldnt update parent if parent plan is null.
            -- srhariha. Wed May 18 04:34:53 PDT 2005.

            -- Bug 5355933. Do not call update if Insert has not happened
            -- saugupta Wed, 26 Jul 2006 05:55:14 -0700 PDT
            if(x_par_plan_id is not null and return_status = 'T' ) then
               -- anagarwa Wed May 26 17:07:29 PDT 2004
               -- bug 3667449
               -- if parent copy source element is updated, then update the
               -- child too.
              l_ret_value:= QA_PARENT_CHILD_PKG.update_child(x_par_plan_id,
                                                             x_par_col_id,
                                                             x_par_occ, x_plan_id,
                                                             x_collection_id, x_occurrence);
            end if;

            RETURN 0;
        ELSE
            get_error_messages(error_array, x_plan_id, x_messages);
            --
            -- Remove commit; completely.  The insert_row API
            -- will take care of committing according to the
            -- x_committed flag.
            --
        END IF;

        RETURN -1;
    END ssqr_post_result;


    --
    -- This seems to be used only by EAM transactions.
    -- /qadev/qa/12.0/java/dde/eam/server/QaResultsVORowImpl.java
    --
    FUNCTION update_result(
        x_occurrence IN NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2)
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);

        -- esig status boolean variable
        l_esig_status BOOLEAN;
    BEGIN
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

        --IF x_transaction_number IS NULL THEN
        --    RETURN -1;
        --END IF;

        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;


        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --

        elements := qa_validation_api.result_to_array(x_result);
        elements := qa_validation_api.id_to_array(x_result1, elements);

        IF (x_transaction_number IS NOT NULL) AND (x_transaction_number > 0) THEN
            qa_validation_api.set_validation_flag_txn(
                x_elements => elements,
                p_plan_id => x_plan_id,
                p_transaction_number => x_transaction_number,
                p_plan_transaction_id => NULL);
        END IF;

        qa_results_pub.update_row(
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_commit => y_committed,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_org_id => x_org_id,
            p_transaction_number => x_transaction_number,
            p_transaction_id => null,
            p_enabled_flag => x_enabled,
            p_collection_id => y_collection_id,
            p_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result);

        IF qa_validation_api.no_errors(error_array) THEN

            -- Bug 4057388. Display a message action was not firing in eam.
            -- message_array returned from qa_results_pub.update_row was
            -- not converted to output string x_mesasges.
            -- srhariha.Thu Dec 30 22:32:00 PST 2004

            get_action_messages(message_array, x_plan_id, x_messages);


            RETURN 0;
        ELSIF return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            get_error_messages(error_array, x_plan_id, x_messages);
        END IF;

        RETURN -1;
    END update_result;


PROCEDURE post_error_messages (p_errors IN qa_validation_api.ErrorArray,
                               plan_id NUMBER) IS

    l_message_name VARCHAR2(30);
    l_char_prompt VARCHAR2(100);

    -- bug 5307450
    -- Cursor to get the message entered by the user for the
    -- 'Reject the input' action in the collection plan.
    -- ntungare Tue Mar 28 08:07:05 PST 2006.
    --
    CURSOR cur_mesg(p_plan_id NUMBER,p_char_id NUMBER) IS
           SELECT message
             FROM qa_plan_char_actions
            WHERE plan_char_action_trigger_id IN
                  (SELECT plan_char_action_trigger_id
                     FROM qa_plan_char_action_triggers
                    WHERE plan_id = p_plan_id
                      AND char_id = p_char_id)
              AND action_id = 2;

    l_mesg varchar2(2000);

BEGIN


 --messages should be cleared everytime a Submit is clicked on client
    fnd_msg_pub.Initialize();
    fnd_msg_pub.reset();

    FOR i IN p_errors.FIRST .. p_errors.LAST LOOP
        -- Bug 5307450
        -- In QWB if the action is 'Reject the input' we were displaying the
        -- seeded error message 'QA_API_REJECT_AN_ENTRY' and not the message
        -- added in the collection plan setup by the user. Now the following
        -- IF condition would get the 'Reject the input' action message from
        -- the collection plan and pass it to the token of a seeded meesage.
        -- If the action is not 'Reject the input' then the existing code is
        -- used.
        -- Also a new seeded message  has been created with a token as the message
        -- description. This token would be replaced with the message added by
        -- the user in the collection plan setup for 'Reject the input' action.
        -- ntungare Tue Mar 28 08:10:23 PST 2006.
        --
        IF p_errors(i).error_code = qa_validation_api.reject_an_entry_error then
          OPEN cur_mesg(plan_id,p_errors(i).element_id);
          FETCH cur_mesg INTO l_mesg;
          CLOSE cur_mesg;

          l_message_name := g_message_table(p_errors(i).error_code);
          l_char_prompt := qa_plan_element_api.get_prompt(plan_id, p_errors(i).element_id);

          fnd_message.set_name('QA','QA_API_REJECT_INPUT');
          fnd_message.set_token('CHAR_PROMPT', l_char_prompt);
          fnd_message.set_token('REJECT_MESSAGE', l_mesg);
          fnd_msg_pub.add();
        ELSE
          l_message_name := g_message_table(p_errors(i).error_code);
          l_char_prompt := qa_plan_element_api.get_prompt(plan_id, p_errors(i).element_id);

          fnd_message.set_name('QA', l_message_name);
          fnd_message.set_token('CHAR_ID', p_errors(i).element_id);
          fnd_message.set_token('CHAR_PROMPT', l_char_prompt);
          fnd_msg_pub.add();
        End If;
    END LOOP;

END post_error_messages;

    --
    -- Used only by QWB and Fwk Integration
    -- /qadev/qa/12.0/java/ssqr/server/QualityResultsEOImpl.java
    --
    -- Pass -1 to p_transaction_number when using standalone.
    --
    --
    -- Bug 6881303
    -- added 2 new elements, one a comma separated list of the
    -- Parent collection elements that would receive aggregated
    -- values and the other a comma separated list of the
    -- aggregated values.
    -- ntungare Fri Mar 21 01:19:03 PDT 2008
    --
    FUNCTION ssqr_update_result(
        x_occurrence IN NUMBER,
        x_org_id IN NUMBER,
        x_plan_id IN NUMBER,
        x_spec_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_txn_header_id IN NUMBER,
        x_par_plan_id IN NUMBER,
        x_par_col_id IN NUMBER,
        x_par_occ IN NUMBER,
        x_result IN VARCHAR2,
        x_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        x_result2 IN VARCHAR2,      -- not used yet, for future expansion
        x_enabled IN INTEGER,
        x_committed IN INTEGER,
        x_transaction_number IN NUMBER,
        x_messages OUT NOCOPY VARCHAR2,
        x_agg_elements OUT NOCOPY VARCHAR2,
        x_agg_val OUT NOCOPY VARCHAR2,
        p_last_update_date IN DATE DEFAULT SYSDATE)
    RETURN INTEGER IS
        elements qa_validation_api.ElementsArray;
        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);
        y_spec_id NUMBER;
        y_collection_id NUMBER;
        y_committed VARCHAR2(1);

        -- anagarwa Wed May 26 17:07:29 PDT 2004
        -- bug 3667449
        l_ret_value VARCHAR2(1);

        l_esig_status BOOLEAN;

        --
        -- bug 6729769
        -- Record and a collection to get the details of History Child
        -- Plan plans for which data has been collected in a Txn
        -- ntungare
        --
        TYPE hist_plan_rec IS RECORD (plan_id       NUMBER,
                                      collection_id NUMBER,
                                      occurrence    NUMBER);
        TYPE hist_plan_tab_typ IS TABLE OF hist_plan_rec INDEX BY binary_integer;
        hist_plan_tab hist_plan_tab_typ ;
    BEGIN
    --messages should be cleared everytime a Submit is clicked on client
    fnd_msg_pub.Initialize();
    fnd_msg_pub.reset();

    --
    -- Bug 2617638
    -- The original statement returns if x_result IS NULL.
    -- Undesirable if caller passes all validated IDs in x_result1.
    -- Added AND x_result1 IS NULL
    -- bso Tue Oct  8 18:34:38 PDT 2002
    --
        IF x_result IS NULL AND x_result1 IS NULL THEN
            RETURN -1;
        END IF;

        IF x_committed = 1 THEN
            y_committed := fnd_api.g_true;
        ELSE
            y_committed := fnd_api.g_false;
        END IF;

        --
        -- Some input can be -1, if that's the case, set to null
        --
        IF x_collection_id = -1 THEN
            y_collection_id := NULL;
        ELSE
            y_collection_id := x_collection_id;
        END IF;
        IF x_spec_id = -1 THEN
            y_spec_id := NULL;
        ELSE
            y_spec_id := x_spec_id;
        END IF;


        -- Bug 4502450. esig status support for multirow uqr
        -- check for validation before update
        -- saugupta Wed, 24 Aug 2005 08:49:45 -0700 PDT
        l_esig_status :=
            validate_esig_for_update(p_plan_id            => x_plan_id,
                                     p_plan_collection_id => x_collection_id,
                                     p_plan_occurrence    => x_occurrence);
        IF ( NOT l_esig_status ) THEN
            RETURN -1;
        END IF;


        --
        -- The flatten string is a representation that looks like this:
        --
        -- 10=Item@101=Defected@102=20 ...
        --
        -- namely, it is an @ separated list of charID=value.  In case
        -- value contains @, then it is doubly encoded.
        --
        -- First task is to decode this string into the row_element
        -- array.
        --
        elements := qa_validation_api.result_to_array(x_result);
        elements := qa_validation_api.id_to_array(x_result1, elements);

        IF (x_transaction_number IS NOT NULL) AND (x_transaction_number > 0) THEN
            qa_validation_api.set_validation_flag_txn(
                x_elements => elements,
                p_plan_id => x_plan_id,
                p_transaction_number => x_transaction_number,
                p_plan_transaction_id => NULL);
        END IF;

        -- 12.1 QWB Usability Improvements
        -- Passing a new parameter p_ssqr_operation to indicate
        -- that the processing is being done for QWB application
        -- that would ensure that the Row Validation is not done
        -- again at the time of the data updation
        --
        qa_results_pub.update_row(
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_commit => y_committed,
            p_plan_id => x_plan_id,
            p_spec_id => y_spec_id,
            p_org_id => x_org_id,
            p_transaction_number => x_transaction_number,
            p_transaction_id => null,
            p_txn_header_id => x_txn_header_id,
            p_enabled_flag => x_enabled,
            p_collection_id => y_collection_id,
            p_occurrence => x_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result,
            p_ssqr_operation => 1,
            p_last_update_date => p_last_update_date);

        IF qa_validation_api.no_errors(error_array) THEN

            -- anagarwa Fri Jan 23 12:10:04 PST 2004
            -- Bug 3384986 Actions for CAR master not fired when child is updated
            -- update parent and also update parent txn id so that the actions like
            -- sending an email can be fired.
            -- NOTE: In SsqrAMImpl.processEqrApply we already call
            -- setParentAttributes that recursively updates parent rows with the
            -- current txn header id. However, that is done only to set the
            -- completed status and it exits once it finds the completed flag for
            -- parent row. The following update parent causes some
            -- backward relationships to be fired and if there are actions associated
            -- with those then they should be fired too. So we set txn header id
            -- of the parent records so that actions get fired in
            -- qapcb.ssqr_post_commit
            IF(QA_PARENT_CHILD_PKG.update_parent(
                x_par_plan_id,
                x_par_col_id,
                x_par_occ,
                x_plan_id,
                x_collection_id,
                x_occurrence,
                x_txn_header_id,
                x_agg_elements,
                x_agg_val
		) = 'T') THEN
                  NULL;
                  -- 12.1 QWB Usabiility Improvements
                  -- Insert the History for Parent if it has been updated
                  --
                  -- bug 6936302
                  -- This is not needed since OAF now calls the update
                  -- method for the parent row whenever a child record
                  -- is changed since R12.1 XBuid4 which automatically
                  -- creates a History child for the parent
                  -- ntungare
                  --
                  /*
                  if ((x_enabled = 2 or x_enabled is null) AND
                       x_agg_elements IS NOT NULL) then
                        qa_parent_child_pkg.insert_history_auto_rec_QWB(
                                                    p_plan_id           => x_par_plan_id,
                                                    p_collection_id     => x_par_col_id,
                                                    p_occurrence        => x_par_occ,
                                                    p_organization_id   => x_org_id,
                                                    p_txn_header_id     => x_txn_header_id,
                                                    p_relationship_type => 1,
                                                    p_data_entry_mode   => 4,
                                                    x_status            => return_status);
                  end If;
                  */
            END IF;

            get_action_messages(message_array, x_plan_id, x_messages);

            -- Bug 3536025. Calling new procedure insert_history_auto_rec_QWB
            -- instead of insert_history_auto_rec. The new procedure is same as
            -- the old one except it doesnot changes child plan's txn_header_id
            -- and doesnot fire actions for child plans.
            -- srhariha. Wed May 26 22:31:28 PDT 2004.

/*
            qa_parent_child_pkg.insert_history_auto_rec_QWB(x_plan_id,
                                                            x_txn_header_id,
                                                            1,
                                                            4);
*/

            -- Bug 4343758. OA Framework Integration project.
            -- Shouldnt create history and automatic for txn scenario.
            -- srhariha. Wed May 18 04:34:53 PDT 2005.

            -- Bug 3681815. Changing the call to proc below as the signature got
            -- changed due to the bug.
            -- commenting the previous calls to proc above.
            -- saugupta Tue, 15 Jun 2004 05:51:00 -0700 PDT

            -- insert history records

            if (x_enabled = 2 or x_enabled is null)  then
                --
                -- bug 6729769
                -- Check if History Child records already
                -- exist for this Txn in which case a new
                -- record is not to be created. The existing
                -- hist records would be updated.
                -- ntungare
                --
                SELECT b.child_plan_id,
                       b.child_collection_id,
                       b.child_occurrence
                BULK COLLECT INTO hist_plan_tab
                  FROM qa_pc_results_relationship b, qa_pc_plan_relationship a
                WHERE a.parent_plan_id = x_plan_id
                  AND a.parent_plan_id = b.parent_plan_id
                  AND a.child_plan_id  = b.child_plan_id
                  AND a.data_entry_mode = 4
                  AND b.parent_collection_id = y_collection_id
                  AND b.parent_occurrence = x_occurrence
                  AND b.child_txn_header_id = x_txn_header_id;

                -- If the Hist plan data not collected then
                -- insert the history records
                IF (hist_plan_tab.count = 0) THEN
                   qa_parent_child_pkg.insert_history_auto_rec_QWB(p_plan_id => x_plan_id,
                                               p_collection_id     => y_collection_id,
                                               p_occurrence        => x_occurrence,
                                               p_organization_id   => x_org_id,
                                               p_txn_header_id     => x_txn_header_id,
                                               p_relationship_type => 1,
                                               p_data_entry_mode   => 4,
                                               x_status            => return_status);
                ELSE
                   --
                   -- bug 6729769
                   -- for history records that are present we need to
                   -- update them to ensure that the aggregated values
                   -- reflect in them
                   -- ntungare
                   FOR hist_plan_cntr in 1..hist_plan_tab.count
                      LOOP
                         l_ret_value:= QA_PARENT_CHILD_PKG.update_child(x_plan_id,
                                                                       y_collection_id,
                                                                       x_occurrence,
                                                                       hist_plan_tab(hist_plan_cntr).plan_id,
                                                                       hist_plan_tab(hist_plan_cntr).collection_id,
                                                                       hist_plan_tab(hist_plan_cntr).occurrence);
                      END LOOP;
                END IF;
            end if;



            -- anagarwa Wed May 26 17:07:29 PDT 2004
            -- bug 3667449
            -- if parent copy source element is updated, then update the
            -- child too.
            -- we need to check and call both the methods because of following
            -- scenario. A is parent of B is parent of C is parent of D.
            -- Element X is copied from B to C to D. If D is updated and
            -- X is updated in B ,  we want both C and D to be updated.

             IF (x_par_occ > 0 ) THEN
                 l_ret_value:= QA_PARENT_CHILD_PKG.update_child(x_par_plan_id,
                                                                x_par_col_id,
                                                                x_par_occ,
                                                                x_plan_id,
                                                                x_collection_id,
                                                                x_occurrence);
             ELSE
                 l_ret_value := QA_PARENT_CHILD_PKG.update_all_children(x_plan_id,
                                          x_collection_id, x_occurrence);
             END IF;

            RETURN 0;
        ELSIF return_status <> FND_API.G_RET_STS_ERROR AND
           return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
            get_error_messages(error_array, x_plan_id, x_messages);
        END IF;

        RETURN -1;

    END ssqr_update_result;

-- bug 5306909
-- Added p_last_update_date parameter. This parameter is used
-- to check whether the record which the user is trying to
-- update has been updated already by some other user.
-- ntungare Mon Apr 10 07:03:13 PDT 2006
--
FUNCTION ssqr_lock_row (
        p_occurrence IN NUMBER,
        p_plan_id IN NUMBER,
        p_last_update_date IN DATE,
        x_status OUT NOCOPY VARCHAR2)
    RETURN INTEGER IS

l_occurrence NUMBER;

-- Bug 5306909
-- Modified the cursor definition to fetch the
-- last_update_date
-- ntungare Mon Apr 10 07:03:13 PDT 2006
--
CURSOR upd_cur  IS
  SELECT occurrence, last_update_date
  FROM qa_results
  WHERE occurrence = p_occurrence
  AND   plan_id = p_plan_id
  FOR UPDATE NOWAIT;

-- Bug 5306909
-- New variable to get the last_update_date
-- ntungare Mon Apr 10 07:03:13 PDT 2006
--
l_last_update_date DATE;

BEGIN

        x_status := '1';
        OPEN upd_cur;

        --
        -- Bug 5306909
        -- Modified the Fetch statement to fetch
        -- the last_update_date
	-- ntungare Mon Apr 10 07:15:42 PDT 2006
        --
        FETCH upd_cur INTO l_occurrence, l_last_update_date;

        IF (upd_cur%NOTFOUND) THEN
           RETURN -1;
        END IF;

	CLOSE upd_cur;

        -- bug 5306909
        -- If the p_last_update_date is not equal to what is
	-- there in the database (l_last_update_date) then it
	-- means the record has been updated by some other user.
	-- So we return -1, to QualityResultsEOImpl.java which
	-- would display the seeded QA_SSQR_LOCK_FAILED error
	-- message.
        -- ntungare Mon Apr 10 07:06:39 PDT 2006
        --
        IF (p_last_update_date <> l_last_update_date) THEN
          RETURN -1;
        END IF;

        RETURN 1;

        EXCEPTION  when others then
             IF upd_cur%ISOPEN THEN
                CLOSE upd_cur;
                RETURN -1;
             ELSE
                RETURN -1;
             END IF;
             --raise;

END ssqr_lock_row;


--
-- Removed procedure wb_set_valid_flag entirely because
-- the new qa_validation_api.set_validation_flag_txn is a superset.
--

--
-- Used only by QWB and Fwk Integration
-- /qadev/qa/12.0/java/ssqr/server/QualityResultsEOImpl.java
--
-- Pass -1 to p_transaction_number when using standalone.
--
-- 12.1 QWB Usability Improvement
-- Added 2 new parameters x_charid_str and x_id_str
-- TO return the list of Id values for the HC elements
--
FUNCTION ssqr_validate_row (
        p_occurrence IN OUT NOCOPY NUMBER,
        p_org_id IN NUMBER,
        p_plan_id IN NUMBER,
        p_spec_id IN NUMBER,
        p_collection_id IN NUMBER,
        p_result IN VARCHAR2,
        p_result1 IN VARCHAR2,      -- R12 Project MOAC 4637896, ID passing
        p_result2 IN VARCHAR2,      -- not used yet, for future expansion
        p_enabled IN INTEGER,
        p_committed IN INTEGER,
        p_transaction_number IN NUMBER,
        p_transaction_id IN  NUMBER DEFAULT 0,
        x_messages OUT NOCOPY VARCHAR2,
        x_charid_str OUT NOCOPY VARCHAR2,
        x_id_str out NOCOPY VARCHAR2)
    RETURN INTEGER IS

elements              qa_validation_api.ElementsArray;
error_array           qa_validation_api.ErrorArray;
l_results_array       qa_validation_api.ResultRecordArray;
l_message_array       qa_validation_api.MessageArray;

--
-- Bug 5932426
-- Checing if the Txn is an update Txn or an
-- Insert Txn. If the txn is update, then the
-- Plan_id - Collection_id - Occurrence combination
-- would be present in the QA_RESULTS table.
-- ntungare Sat Apr 14 00:53:40 PDT 2007
--
Cursor C1 is
  Select 1 from QA_RESULTS
   WHERE plan_id        = p_plan_id
     and collection_id = p_collection_id
     and occurrence     = p_occurrence;

update_txn  PLS_INTEGER := 0;

-- 12.1 QWB Usability Improvements
--
id_ctr      Number;
charid_str  VARCHAR2(4000);
id_str      VARCHAR2(4000);


BEGIN

    --clearing cache so that errors are not shown over and over again.
    fnd_msg_pub.Initialize();
    fnd_msg_pub.reset();
    elements := qa_validation_api.result_to_array(p_result);
    elements := qa_validation_api.id_to_array(p_result1, elements);

    --
    -- Bug 5932426
    -- Updating the validation flag only if the
    -- Txn is an update txn
    -- ntungare Sat Apr 14 00:55:08 PDT 2007
    --
    Open C1;
    Fetch C1 into update_txn;
    Close C1;

    If update_txn = 1 then
       update_validation_flg(elements,
                             p_plan_id,
                             p_collection_id,
                             p_occurrence);
       update_txn := 0;
    End If;

    --
    -- Replaced the following by set_validation_flag_txn which
    -- is a superset of wb_set_valid_flag.
    --
    -- Bug 4519558. OA Framework Integration project. UT bug fix.
    -- Set validation flag.
    -- srhariha. Tue Aug  2 22:38:59 PDT 2005.
    -- wb_set_valid_flag(p_elements => elements,
    --     p_transaction_number => p_transaction_number);
    --
    IF (p_transaction_number IS NOT NULL) AND (p_transaction_number > 0) THEN
        qa_validation_api.set_validation_flag_txn(
            x_elements => elements,
            p_plan_id => p_plan_id,
            p_transaction_number => p_transaction_number,
            p_plan_transaction_id => NULL);
    END IF;

    -- 12.1 QWB Usability Improvements
    -- Passing the value for the P_ssqr_operation flag as
    -- 1 to indicate that the online actions firing is
    -- not be done
    --
    error_array := qa_validation_api.validate_row(p_plan_id,
        p_spec_id, p_org_id, fnd_global.user_id, p_transaction_number,
        p_transaction_id, l_results_array, l_message_array,
        elements, 1);

    -- 12.1 QWB Usability Improvements
    -- If the IDs values are present for HC elements then
    -- the build a string of the Id elements
    id_ctr := l_results_array.first;
    while id_ctr <= l_results_array.last
       loop
         If  l_results_array(id_ctr).id IS NOT NULL THEN
           -- Append the HC element column name to the char id string
           charid_str := charid_str ||
                         qa_chars_api.hardcoded_column(l_results_array(id_ctr).element_id)||
                         ',';
           -- Append the Id value to Normalized id string
           id_str     := id_str || l_results_array(id_ctr).id||',';
         End If;
         id_ctr := l_results_array.next(id_ctr);
       end loop;

    If charid_str IS NOT NULL THEN
       charid_str := LTRIM(RTRIM(charid_str,','),',');
       id_str     := LTRIM(RTRIM(id_str,','),',');
    End If;

    x_charId_str := charid_str;
    x_Id_str     := id_str;

    -- End of 12.1 QWB Usability Improvements

    IF qa_validation_api.no_errors(error_array) THEN
       get_action_messages(l_message_array, p_plan_id, x_messages);
       RETURN 0;
    ELSE
       get_error_messages(error_array, p_plan_id, x_messages);
       post_error_messages(error_array, p_plan_id);
    END IF;

    RETURN -1;
END ssqr_validate_row;

    --
    -- Delete a result.
    --
    PROCEDURE delete_result(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrence IN NUMBER) IS
    BEGIN
        DELETE FROM qa_results
        WHERE  plan_id = x_plan_id AND
               collection_id = x_collection_id AND
               occurrence = x_occurrence;
    END delete_result;

    --
    -- Batch delete a set of results (supply occurrences in
    -- comma-separated list.)
    --
    PROCEDURE delete_results(
        x_plan_id IN NUMBER,
        x_collection_id IN NUMBER,
        x_occurrences IN VARCHAR2) IS

        c_key CONSTANT VARCHAR2(30) := 'QA_SS_RESULTS.DELETE_RESULTS';

    BEGIN
        --
        -- For SQL Bind Compliance, change dynamic SQL to
        -- static using qa_performance_temp table
        -- bso Sat Oct  1 13:03:17 PDT 2005
        --
        qa_performance_temp_pkg.add_ids(c_key, x_occurrences);

        DELETE FROM qa_results
        WHERE  plan_id = x_plan_id AND
               collection_id = x_collection_id AND
               occurrence IN
               (SELECT id
                FROM   qa_performance_temp
                WHERE  key = c_key);

        qa_performance_temp_pkg.purge(c_key);
    END delete_results;

    --
    -- Perform database commit.  Do not use in transaction integration,
    -- otherwise we will be committing the parent's data without their
    -- knowing!  Actions will be fired in the background.
    --
    PROCEDURE commit_results IS
    BEGIN
        commit;
        --
        -- work on action later.
        --
    END commit_results;

     PROCEDURE wrapper_fire_action (
       q_collection_id          IN      NUMBER,
       q_return_status          OUT     NOCOPY VARCHAR2,
       q_msg_count              OUT     NOCOPY NUMBER,
       q_msg_data               OUT     NOCOPY VARCHAR2)
    IS

    BEGIN

     qa_results_pub.enable_and_fire_action (
                p_api_version => 1.0,
                p_commit => FND_API.G_TRUE,
                p_collection_id => q_collection_id,
                x_return_status => q_return_status,
                x_msg_count     => q_msg_count,
                x_msg_data      => q_msg_data);

    END wrapper_fire_action;


   PROCEDURE GET_COLLECTION_ID (x_collection_id OUT NOCOPY NUMBER)
   IS
        CURSOR cid_cur IS
                SELECT QA_COLLECTION_ID_S.NEXTVAL FROM DUAL;
   BEGIN
        OPEN cid_cur;
        FETCH cid_cur INTO x_collection_id;
        CLOSE cid_cur;

        EXCEPTION  when others then
             IF cid_cur%ISOPEN THEN
                CLOSE cid_cur;
             END IF;
             raise;
  END GET_COLLECTION_ID;


   -- Bug 4502450. R12 eSig Status functionality for PENDING Status
   -- function checks for eSignature elements present for current
   -- plan as well as for all the parent plans
   -- if status is not pending i.e if update is allowed by any means
   -- returns TRUE else returns FALSE
   -- sets the message if eSig Status is PENDING for any row for
   -- the current plan relationship
   -- saugupta Wed, 24 Aug 2005 08:50:00 -0700 PDT
   --
   -- Reformatted indentation and cases to make it easier
   -- to read.  Syntactically equivalent to previous revision.
   -- bso Sat Oct  1 13:16:08 PDT 2005

   FUNCTION validate_esig_for_update(
       p_plan_id            IN NUMBER,
       p_plan_collection_id IN NUMBER,
       p_plan_occurrence    IN NUMBER)
   RETURN BOOLEAN
   IS
       l_eres_profile           VARCHAR2(3);
       l_esig_status            VARCHAR(20);
       l_par_esig_status        VARCHAR(20);
       l_ancestors_exists       VARCHAR(1);
       i                        NUMBER;
       parent_plan_ids          dbms_sql.number_table;
       parent_collection_ids    dbms_sql.number_table;
       parent_occurrences       dbms_sql.number_table;

   BEGIN

       l_eres_profile := fnd_profile.value('EDR_ERES_ENABLED');
       -- Check if the profile is on if not return TRUE
       IF ( l_eres_profile IS NULL OR l_eres_profile = 'N' )  THEN
           RETURN TRUE;
       END IF;


       -- check if eSig Status is pending for current plan
       l_esig_status := qa_eres_util.is_esig_status_pending(
           p_plan_id       => p_plan_id ,
           p_collection_id => p_plan_collection_id,
           p_occurrence    => p_plan_occurrence);


       IF ( l_esig_status = 'T' ) THEN
           -- current plan has eSig status as PENDING
           -- fill the error array and return
           fnd_message.set_name('QA', 'QA_ERES_CANNOT_UPDATE_RESULT');
           fnd_msg_pub.add();
           RETURN FALSE;
       END IF; -- l_esig_status = T
       -- esig status is false for child plan
       -- check esig status in ancestor plans
       -- before check if ancestor plans exists

       l_ancestors_exists := qa_parent_child_pkg.get_ancestors(
           p_child_plan_id         => p_plan_id,
           p_child_occurrence      => p_plan_occurrence,
           p_child_collection_id   => p_plan_collection_id,
           x_parent_plan_ids       => parent_plan_ids,
           x_parent_collection_ids => parent_collection_ids,
           x_parent_occurrences    => parent_occurrences);
       -- if ancestors does not exists, meaning record is updateable
       IF ( l_ancestors_exists = 'F' ) THEN
           RETURN TRUE;
       END IF;

       -- if not, we need to check  esig Status for all ancestors
       i := parent_occurrences.FIRST;
       l_par_esig_status := 'F';
       WHILE i IS NOT NULL LOOP
           l_par_esig_status := qa_eres_util.is_esig_status_pending(
               p_plan_id       => parent_plan_ids(i) ,
               p_collection_id => parent_collection_ids(i),
               p_occurrence    => parent_occurrences(i));
           EXIT WHEN l_par_esig_status = 'T';
           i := parent_occurrences.NEXT(i);
       END LOOP; -- while i is not null

       IF ( l_par_esig_status = 'F' ) THEN -- no parent has status pending
           RETURN TRUE;
       END IF;
       -- current plan ancestors has eSig status as PENDING
       -- fill the error array and return
       fnd_message.set_name('QA', 'QA_ERES_CANNOT_UPDATE_RESULT');
       fnd_msg_pub.add();
       return FALSE;

   END validate_esig_for_update;

   -- bug 4658275. eSig functionality support in QWB
   -- this new method checks if user can insert a new
   -- child row if ERES is enables
   -- saugupta Tue, 18 Oct 2005 02:55:19 -0700 PDT
   FUNCTION validate_esig_for_insert(p_plan_id            IN NUMBER,
                                     p_plan_collection_id IN NUMBER,
                                     p_plan_occurrence    IN NUMBER)
   RETURN BOOLEAN
   IS
       l_eres_profile           VARCHAR2(3);
       l_esig_status            VARCHAR(20);
       l_par_esig_status        VARCHAR(20);
       l_ancestors_exists       VARCHAR(1);
       i                        NUMBER;
       parent_plan_ids          dbms_sql.number_table;
       parent_collection_ids    dbms_sql.number_table;
       parent_occurrences       dbms_sql.number_table;

   BEGIN

       l_eres_profile := FND_PROFILE.VALUE('EDR_ERES_ENABLED');
       -- Check if the profile is on if not return TRUE
       IF ( l_eres_profile IS NULL OR l_eres_profile = 'N' )  THEN
           return TRUE;
       END IF;

       -- check if eSig Status is pending for parent plan
       -- in the method we are passing the parent plan id's
       -- as we can add a new row with eSignature status
       -- is pending but not when eSig Status is pending
       -- for the parnet plan

       l_esig_status :=
            QA_ERES_UTIL.is_esig_status_pending(p_plan_id       => p_plan_id ,
                                                p_collection_id => p_plan_collection_id,
                                                p_occurrence    => p_plan_occurrence);


       IF ( l_esig_status = 'T' ) THEN
           -- current plan has eSig status as PENDING
           -- fill the error array and return
           fnd_message.set_name('QA', 'QA_ERES_CANNOT_ENTER_CHILD');
           fnd_msg_pub.add();
           return FALSE;
       END IF; -- l_esig_status = T


       -- esig status is false for child plan
       -- check esig status in ancestor plans
       -- before check if ancestor plans exists
       l_ancestors_exists :=
         QA_PARENT_CHILD_PKG.get_ancestors(p_child_plan_id         => p_plan_id,
                                           p_child_occurrence      => p_plan_occurrence,
                                           p_child_collection_id   => p_plan_collection_id,
                                           x_parent_plan_ids       => parent_plan_ids,
                                           x_parent_collection_ids => parent_collection_ids,
                                           x_parent_occurrences    => parent_occurrences);
       -- if ancestors does not exists, meaning record can be inserted

       IF ( l_ancestors_exists = 'F' ) THEN
           return TRUE;
       END IF;

       -- if not, we need to check  esig Status for all ancestors
       i := parent_occurrences.FIRST;
       l_par_esig_status := 'F';
       WHILE i IS NOT NULL
       LOOP
            l_par_esig_status :=
                QA_ERES_UTIL.is_esig_status_pending(p_plan_id       => parent_plan_ids(i) ,
                                                    p_collection_id => parent_collection_ids(i),
                                                    p_occurrence    => parent_occurrences(i));
            EXIT WHEN  l_par_esig_status = 'T';
            i := parent_occurrences.NEXT(i);
       END LOOP; -- while i is not null

       IF ( l_par_esig_status = 'F' ) THEN -- no parent has status pending
           return TRUE;
       END IF;
       -- current plan ancestors has eSig status as PENDING
       -- fill the error array and return
       fnd_message.set_name('QA', 'QA_ERES_CANNOT_ENTER_CHILD');
       fnd_msg_pub.add();
       return FALSE;

   END validate_esig_for_insert;

   -- R12.1 QWB Usability Improvements project
   -- Function to perform deletetion of rows
   --
   FUNCTION delete_row(p_plan_id        IN  NUMBER,
                       p_collection_id  IN  NUMBER,
                       p_occurrence     IN  NUMBER,
                       p_org_id         IN  NUMBER,
                       p_txn_header_id  IN  NUMBER,
                       p_par_plan_id    IN  NUMBER DEFAULT -1,
                       p_par_col_id     IN  NUMBER DEFAULT -1,
                       p_par_occ        IN  NUMBER DEFAULT -1)
           RETURN VARCHAR2 AS
       delete_api_ret_val VARCHAR2(1);
       insert_api_ret_val VARCHAR2(1);
       CURSOR check_agg_rel_cur IS
          SELECT 1
             FROM   qa_pc_result_columns_v
          WHERE parent_plan_id = p_par_plan_id
            AND child_plan_id  = p_plan_id
            AND element_relationship_type in (2,3,4,5,6,7,8)
            AND parent_enabled_flag = 1
            AND child_enabled_flag = 1;

       agg_rel_flag  NUMBER;
   BEGIN
       delete_api_ret_val := QA_PARENT_CHILD_PKG.delete_row (
                                  p_plan_id       => p_plan_id,
                                  p_collection_id => p_collection_id,
                                  p_occurrence    => p_occurrence);

       -- Check for successful deletion
       IF (delete_api_ret_val = 'T') THEN
           -- Check if a parent record exists for the current record
           -- and if an aggregate relationship exists between then in which
           -- case History record needs to be created for the parent
           --
           IF (p_par_plan_id <> -1 AND
               p_par_col_id  <> -1 AND
               p_par_occ     <> -1) THEN

               OPEN  check_agg_rel_cur;
               FETCH check_agg_rel_cur INTO agg_rel_flag;
               CLOSE check_agg_rel_cur;

               IF (agg_rel_flag = 1) THEN --Aggregate relation exists
                   -- Hence insert history record for the parent
                   -- as the deletion of the child record would
                   -- impact the aggregated value on the parent.
                   qa_parent_child_pkg.insert_history_auto_rec_QWB(
                                    p_plan_id           => p_par_plan_id,
                                    p_collection_id     => p_par_col_id,
                                    p_occurrence        => p_par_occ,
                                    p_organization_id   => p_org_id,
                                    p_txn_header_id     => p_txn_header_id,
                                    p_relationship_type => 1,
                                    p_data_entry_mode   => 4,
                                    x_status            => insert_api_ret_val);
               END IF;
           END IF;
       END IF;

       RETURN 'T';
   END;

--anagarwa 3197700 Wed Oct 15 17:38:56 PDT 2003

BEGIN

    populate_message_table;
END qa_ss_results;

/
