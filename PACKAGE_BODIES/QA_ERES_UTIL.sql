--------------------------------------------------------
--  DDL for Package Body QA_ERES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_ERES_UTIL" AS
/* $Header: qaedrutb.pls 120.7.12010000.2 2009/12/29 10:27:00 ntungare ship $ */


---------------------------------------------------------------------
  PROCEDURE find_topmost_parent
                        (p_child_occ       IN  NUMBER,
                         p_child_coll_id   IN  NUMBER,
                         p_child_plan_id   IN  NUMBER,
                         p_parent_occ      OUT NOCOPY NUMBER,
                         p_parent_coll_id  OUT NOCOPY NUMBER,
                         p_parent_plan_id  OUT NOCOPY NUMBER) IS
---------------------------------------------------------------------


    CURSOR C1 (l_occ NUMBER) IS
      SELECT parent_occurrence, parent_collection_id, parent_plan_id
        FROM qa_pc_results_relationship qprr
     CONNECT BY prior qprr.parent_occurrence = qprr.child_occurrence
       START WITH qprr.child_occurrence = l_occ
    ORDER BY level desc;

  BEGIN

    OPEN C1(p_child_occ);
    FETCH C1 INTO p_parent_occ, p_parent_coll_id, p_parent_plan_id;

    IF C1%NOTFOUND THEN
       CLOSE C1;

       p_parent_occ     := p_child_occ;
       p_parent_coll_id := p_child_coll_id;
       p_parent_plan_id := p_child_plan_id;

    END IF;

    --
    -- bug 7478786
    -- Added a check before closing the cursor
    -- ntungare
    --
    IF C1%ISOPEN THEN
      CLOSE C1;
    END IF;

  END find_topmost_parent;


---------------------------------------------------------------------
  FUNCTION get_result_esig_status (p_occurrence IN NUMBER,
                                   p_coll_id    IN NUMBER,
                                   p_plan_id    IN NUMBER,
                                   p_char_id    IN NUMBER)
  RETURN VARCHAR2 IS
---------------------------------------------------------------------

    l_res_col    VARCHAR2(30);
    l_sql_string VARCHAR2(1000);
    l_status     VARCHAR2(80);

  BEGIN

    l_res_col := QA_FLEX_UTIL.qpc_result_column_name(p_plan_id, p_char_id);

    IF l_res_col IS NULL THEN
      return NULL;
    END IF;


    l_sql_string := 'SELECT '||l_res_col ||' FROM QA_RESULTS '
                    || 'WHERE plan_id = :1'
                    || ' AND collection_id = :2'
                    || ' AND occurrence = :3';

    EXECUTE IMMEDIATE l_sql_string INTO l_status
             USING p_plan_id, p_coll_id, p_occurrence;

    return l_status;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN  --needed for bug 3225461
		return NULL;

  END get_result_esig_status;


---------------------------------------------------------------------
  FUNCTION get_mfg_lookups_meaning (p_lookup_type IN VARCHAR2,
                                    p_lookup_code IN NUMBER)
  RETURN VARCHAR2 IS
---------------------------------------------------------------------

    l_meaning  VARCHAR2(80);

    CURSOR C1 IS
      SELECT meaning
      FROM   mfg_lookups
      WHERE  lookup_code = p_lookup_code
      AND    lookup_type = p_lookup_type;

  BEGIN

    OPEN  C1;
    FETCH C1 INTO l_meaning;

    IF C1%NOTFOUND THEN
      CLOSE C1;
      RETURN 'NO_CODE_FOUND';

    END IF;

    --
    -- bug 7478786
    -- Closing the cursor before returning
    -- ntungare
    --
    IF C1%ISOPEN THEN
       CLOSE C1;
    END IF;

    RETURN l_meaning;

  END get_mfg_lookups_meaning;

   -- R12 ERES Support in Service Family. Bug 4345768
   -- START
   -- This function returns if a given plan is
   -- enabled for deferred eSignatures. Returns Y or N

   FUNCTION is_def_sig_enabled (p_plan_id IN NUMBER)
   RETURN VARCHAR2
   IS
     CURSOR check_plan_element( c_plan_id NUMBER ) IS
       SELECT 'Y'
       FROM   QA_PLAN_CHARS
       WHERE  char_id = 2147483572
       AND    enabled_flag = 1
       AND    plan_id = c_plan_id;

     l_return_status VARCHAR2(1);

   BEGIN
     l_return_status := 'N';

     OPEN  check_plan_element( p_plan_id );
     FETCH check_plan_element INTO l_return_status;
     CLOSE check_plan_element;

     RETURN l_return_status;

   END is_def_sig_enabled;

   -- This procedure enables a given collection plan for Deferred
   -- Esignatures by adding the 'eSignature Status' element to the plan.
   PROCEDURE add_esig_status ( p_plan_id IN NUMBER )
   IS
     l_prompt        QA_CHARS.prompt%TYPE;
     l_prompt_seq    QA_PLAN_CHARS.prompt_sequence%TYPE;
     l_result_seq    NUMBER;
     l_result_column QA_PLAN_CHARS.result_column_name%TYPE;
     l_char_id       QA_CHARS.char_id%TYPE;

     l_message       QA_PLAN_CHAR_ACTIONS.message%TYPE;
     l_user_id       NUMBER;
     l_qpcat_id      QA_PLAN_CHAR_ACTION_TRIGGERS.plan_char_action_trigger_id%TYPE;
     l_qpca_id       QA_PLAN_CHAR_ACTIONS.plan_char_action_id%TYPE;

     CURSOR  get_prompt_seq( c_plan_id NUMBER ) IS
     SELECT  MAX( prompt_sequence ) + 10
     FROM    QA_PLAN_CHARS
     WHERE   plan_id = c_plan_id;

     -- Bug 4958731: SQL Repository Fix

     -- Bug 5218065. SHKALYAN 10-May-2006.
     -- When No Softcoded or user defined elements with result column
     -- of type CHARACTERXXare present in the plan, this SQL returns  NULL
     -- thereby leading to undesirable results. Added the NVL so that
     -- this SQL always returns a value ( 0 in such cases ).
     CURSOR  get_result_column( c_plan_id NUMBER ) IS
        SELECT
            nvl( max( to_number(substr(result_column_name,10,3)) ), 0 )
        FROM qa_plan_chars qpc,
            qa_chars qc
        WHERE qpc.plan_id = c_plan_id
            AND qc.char_id = qpc.char_id
            AND qc.hardcoded_column is null
            AND qc.datatype in (1,2,3,6);

   BEGIN

     -- Get the Char ID of eSignature Status element
     l_char_id := QA_SS_CONST.esignature_status;

     -- Get the Prompt for the eSignature Status element
     l_prompt := QA_CHARS_API.prompt( l_char_id );

     -- Get the Next Prompt Sequence for the Given Plan
     OPEN  get_prompt_seq( p_plan_id );
     FETCH get_prompt_seq INTO l_prompt_seq;
     CLOSE get_prompt_seq;

     -- Get the Max Result Column for the Given Plan
     OPEN  get_result_column( p_plan_id );
     FETCH get_result_column INTO l_result_seq;
     CLOSE get_result_column;

     -- Derive the Result Column Name
     l_result_column := 'CHARACTER' || TO_CHAR( l_result_seq + 1 );

     l_user_id := FND_GLOBAL.user_id;

     -- Insert the eSignature status plan element
     INSERT INTO QA_PLAN_CHARS
     (
          plan_id,
          char_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          prompt_sequence,
          prompt,
          enabled_flag,
          mandatory_flag,
          read_only_flag,
          ss_poplist_flag,
          information_flag,
          values_exist_flag,
          displayed_flag,
          result_column_name
     )
     VALUES
     (
          p_plan_id,
          l_char_id,
          SYSDATE,
          l_user_id,
          SYSDATE,
          l_user_id,
          l_prompt_seq,
          l_prompt,
          1,
          2,
          1,
          2,
          2,
          2,
          1,
          l_result_column
     );

     -- Need to Insert the 'Reject the Input' action to prevent
     -- the user from updating a Qa Result when the eSignature
     -- status element is PENDING.

     -- Get the Plan Element Action Trigger ID
     SELECT qa_plan_char_action_triggers_s.nextval
     INTO   l_qpcat_id
     FROM   dual;

     -- Create a new Plan Element Action Trigger
     INSERT INTO qa_plan_char_action_triggers
     (
           plan_char_action_trigger_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           trigger_sequence,
           plan_id,
           char_id,
           operator,
           low_value_lookup,
           high_value_lookup,
           low_value_other,
           high_value_other,
           low_value_other_id,
           high_value_other_id
     )
     VALUES
     (
           l_qpcat_id,
           sysdate,
           l_user_id,
           sysdate,
           l_user_id,
           10,
           p_plan_id,
           l_char_id,
           1,
           NULL,
           NULL,
           'PENDING',
           NULL,
           NULL,
           NULL
     );

     -- Generate the Plan Element Action ID
     SELECT qa_plan_char_actions_s.nextval
     INTO   l_qpca_id
     FROM   dual;

     -- Get the Rejection Message
     l_message := FND_MESSAGE.get_string( 'QA', 'QA_ERES_CANNOT_UPDATE_RESULT' );

     INSERT INTO qa_plan_char_actions
     (
         plan_char_action_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         plan_char_action_trigger_id,
         action_id,
         message,
         assign_type
     )
     VALUES
     (
         l_qpca_id,
         sysdate,
         l_user_id,
         sysdate,
         l_user_id,
         l_qpcat_id,
         2,
         l_message,
         --'Results may not be entered while the eSignature Status is Pending.',
         'F'
     );

   END add_esig_status;

   -- END
   -- R12 ERES Support in Service Family. Bug 4345768


   -- Bug 4502450. R12 Esig Status support in Multirow UQR
   -- saugupta Wed, 24 Aug 2005 08:37:40 -0700 PDT

   -- For a row in a plan Function return T if eSign
   -- Status is PENDING else returns F
   FUNCTION is_esig_status_pending(p_plan_id IN NUMBER,
                                   p_collection_id IN NUMBER,
                                   p_occurrence IN NUMBER)
   RETURN VARCHAR2
   IS
   -- eSignature Status is seeded as varchar(20)
   l_status VARCHAR2(20);

   BEGIN
       -- check for null parameters
       IF( p_plan_id IS NULL OR
           p_occurrence IS NULL OR
           p_collection_id IS NULL) THEN
           -- return False
           RETURN 'F';
       END IF;

       -- get result esig status
       l_status :=
           QA_ERES_UTIL.get_result_esig_status
                           (p_occurrence => p_occurrence,
                            p_coll_id    => p_collection_id,
                            p_plan_id    => p_plan_id,
                            p_char_id    => qa_ss_const.esignature_status); -- check if this API checks for Eres Profile

       -- check if the  eSignature Status is PENDING.
       -- We can safely compare it with Harcoded PENDING String
       -- as Description is different in for transalation issues
       IF ( l_status = 'PENDING') THEN
           return 'T';
       ELSE
           return 'F';
       END IF;

   END is_esig_status_pending;

   -- R12.1 MES ERES Integration with Quality Start
   -- This procedure takes in the collection id for a transaction
   -- and generates the XML CLOB object for that transaction.
   PROCEDURE generate_xml(p_collection_id IN varchar2,
                          x_xml_result OUT NOCOPY CLOB) IS
   	l_temp_xml CLOB;

   	CURSOR c(coll_id IN varchar2) is SELECT distinct plan_id
                 FROM qa_results
                 WHERE plan_id || '-' || collection_id || '-' || occurrence NOT IN
                      (SELECT child_plan_id || '-' || child_collection_id || '-' || child_occurrence
                       FROM qa_pc_results_relationship
                       WHERE parent_collection_id = coll_id)
                 AND collection_id = coll_id;

   BEGIN
   	dbms_lob.createtemporary(x_xml_result,true);
   	dbms_lob.append(x_xml_result,'<QA_RESULTS>' );
   	FOR l_plan IN c(p_collection_id)
   	LOOP
   		generate_xml_for_plan(p_collection_id,l_plan.plan_id,l_temp_xml);
   		dbms_lob.append(x_xml_result,'<QA_ERES_INTEGRATION_PLANS>');
   		dbms_lob.append(x_xml_result,l_temp_xml);
   		dbms_lob.append(x_xml_result,'</QA_ERES_INTEGRATION_PLANS>');
   	END LOOP;
   	dbms_lob.append(x_xml_result,'</QA_RESULTS>');

   END generate_xml;

   -- This procedure takes in the collection id, plan_id
   -- and generates the XML CLOB object for that plan in the transaction
   PROCEDURE generate_xml_for_plan(p_collection_id varchar2,
                                   p_plan_id IN varchar2,
                                   x_xml_result_plan OUT NOCOPY CLOB) IS
     l_temp_xml CLOB;
     CURSOR c(coll_id IN varchar2, l_plan_id IN varchar2) is SELECT plan_id || '-' || collection_id || '-' || occurrence doc_id
                 FROM qa_results
                 WHERE plan_id = l_plan_id
                 AND collection_id = coll_id;
     BEGIN
       dbms_lob.createtemporary(x_xml_result_plan,true);
       FOR l_doc_id IN c(p_collection_id, p_plan_id)
       LOOP
         get_xml_for_row(l_doc_id.doc_id,l_temp_xml);
         dbms_lob.append(x_xml_result_plan,l_temp_xml);
       END LOOP;
     END generate_xml_for_plan;

   -- This procedure generates the XML CLOB object for for a particular
   -- result row identified by plan_id, collection_id and occurrence
   PROCEDURE get_xml_for_row(p_document_id IN varchar2,
                             x_xml_result_row OUT NOCOPY CLOB) IS
     err_code NUMBER;
     err_msg  VARCHAR2(4000);
     log_file  VARCHAR2(4000);
     BEGIN
       EDR_UTILITIES.GENERATE_XML( P_MAP_CODE     => 'qa_results',
                               P_DOCUMENT_ID  => p_document_id,
                               P_XML          =>  x_xml_result_row,
                               P_ERROR_CODE   =>  err_code,
                               P_ERROR_MSG    =>  err_msg,
                               P_LOG_FILE     =>  log_file );
     END get_xml_for_row;
    -- R12.1 MES ERES Integration with Quality End

END QA_ERES_UTIL;


/
