--------------------------------------------------------
--  DDL for Package Body CZ_DEVELOPER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_DEVELOPER_UTILS_PVT" AS
/*      $Header: czdevub.pls 120.58.12010000.11 2010/05/18 20:37:29 smanna ship $                */

gDB_SETTING_USE_SECURITY  BOOLEAN    := TRUE;
G_DEFAULT_ITEM_TYPE       CONSTANT INTEGER := 0;
G_RULE_TYPE               CONSTANT VARCHAR2(10) := 'R';
G_INTL_TEXT_TYPE          CONSTANT VARCHAR2(10) := 'T';
G_UI_ACTION_TYPE          CONSTANT VARCHAR2(10) := 'A';
modelReportRun BOOLEAN := FALSE; -- vsingava: 24-Nov-2008; Bug 7297669
mINCREMENT         INTEGER:=20;
currPSSeqVal       CZ_PS_NODES.ps_node_id%TYPE:=0;
currentPSNode      CZ_PS_NODES.ps_node_id%TYPE:=mINCREMENT;

-- FOR MODEL REPORT, storing default seeded data in static data 5404051
TYPE tRuleName          IS TABLE OF cz_rules.name%TYPE INDEX BY BINARY_INTEGER;
TYPE tTemplateToken     IS TABLE OF cz_rules.template_token%TYPE INDEX BY BINARY_INTEGER;
TYPE tRuleId            IS TABLE OF cz_rules.rule_id%TYPE INDEX BY BINARY_INTEGER;

h_RuleName              tRuleName;
h_TemplateToken         tTemplateToken;
h_RuleId                tRuleId;
TYPE t_int_array_tbl_type     IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE t_int_array_tbl_type_idx_vc2     IS TABLE OF INTEGER INDEX BY VARCHAR2(15);
TYPE t_varchar_array_tbl_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE t_varchar_array_tbl_type_vc2 IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(15);-- kdande; Bug 6880555; 12-Mar-2008
TYPE t_num_array_tbl_type     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_char_array_tbl_type    IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE t_varchar_map_type        IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
TYPE t_varchar_to_num_map_type IS TABLE OF NUMBER INDEX BY VARCHAR2(255);
TYPE t_indexes IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- vsingava bug6638552 23rd Nov '08
-- performance fix for model report
TYPE tNodeId            IS TABLE OF cz_model_ref_expls.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tParentId          IS TABLE OF cz_model_ref_expls.parent_expl_node_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tComponentId       IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tReferringId       IS TABLE OF cz_model_ref_expls.referring_node_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tNodeType          IS TABLE OF cz_model_ref_expls.ps_node_type%TYPE INDEX BY BINARY_INTEGER;

-- tables to cache model explosion data
v_NodeId                tNodeId;
v_ParentId              tParentId;
v_ComponentId           tComponentId;
v_ReferringId           tReferringId;
v_NodeType              tNodeType;
h_ParentId              tParentId;
h_NodeType              tNodeType;
h_ReferringId           tReferringId;
h_ComponentId           tComponentId;

OBJECT_NOT_FOUND EXCEPTION;
SEEDED_OBJ_EXCEP EXCEPTION;
NO_TXT_FOUND_EXCP EXCEPTION;
COPY_RULE_FAILURE EXCEPTION;

CZ_R_NO_PARTICIPANTS        EXCEPTION;
CZ_R_WRONG_EXPRESSION_NODE  EXCEPTION;
CZ_G_INVALID_RULE_EXPLOSION EXCEPTION;
CZ_R_INCORRECT_NODE_ID      EXCEPTION;
CZ_R_LITERAL_NO_VALUE       EXCEPTION;

g_attribute_map     t_varchar_map_type;
g_element_type_tbl  t_varchar_to_num_map_type;

RULE_CLASS_DEFAULT         CONSTANT INTEGER := 1;
RULE_CLASS_SEARCH_DECISION CONSTANT INTEGER := 2;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize IS
BEGIN
    SELECT CZ_PS_NODES_S.NEXTVAL INTO currentPSNode FROM dual;
    currPSSeqVal:=currentPSNode;

    SELECT TO_NUMBER(value) INTO mINCREMENT FROM cz_db_settings
    WHERE UPPER(setting_id)=UPPER('OracleSequenceIncr') AND section_name='SCHEMA';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         mINCREMENT:=20;
    WHEN OTHERS THEN
         mINCREMENT:=20;
END Initialize;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getPSSeqVal RETURN INTEGER IS
BEGIN

       IF currentPSNode<currPSSeqVal+mINCREMENT-1 THEN
          currentPSNode:=currentPSNode+1;
       ELSE
          SELECT CZ_PS_NODES_S.nextval INTO currPSSeqVal FROM dual;
          currentPSNode:=currPSSeqVal;
       END IF;
    RETURN currentPSNode;
END getPSSeqVal;



FUNCTION is_val_number(p_str IN VARCHAR2)
RETURN VARCHAR2
IS

v_numval	NUMBER;

BEGIN
	IF (p_str IS NOT NULL) THEN
		v_numval := TO_NUMBER(p_str);
		RETURN 'TRUE';
	ELSE
		RETURN 'FALSE';
	END IF;
EXCEPTION
WHEN OTHERS THEN
	RETURN 'FALSE';
END is_val_number;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION GetRunID return INTEGER IS
RUN_ID NUMBER;
BEGIN
 select CZ_XFR_RUN_INFOS_S.NEXTVAL INTO RUN_ID FROM dual;
 return RUN_ID;
END GetRunID;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this method add log message to fnd log table
--
PROCEDURE LOG_REPORT
(p_run_id        IN VARCHAR2,
 p_error_message IN VARCHAR2) IS
  l_return BOOLEAN;
BEGIN
  l_return := cz_utils.log_report(Msg        => p_error_message,
                                  Urgency    => 1,
                                  ByCaller   => 'CZ_DEVELOPER_UTILS_PVT',
                                  StatusCode => 11276,
                                  RunId      => p_run_id);
END LOG_REPORT;

--
-- initialize global run_id ( <-> CZ_DB_LOGS.run_id )
--
--PROCEDURE Initialize IS
--BEGIN
--    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO gRUN_ID FROM dual;
--    fnd_msg_pub.initialize;
--END Initialize;

--
--
-- add FND error message
--
PROCEDURE add_Error_Message(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 DEFAULT NULL,
                            p_token_value1  IN VARCHAR2 DEFAULT NULL,
                            p_token_name2   IN VARCHAR2 DEFAULT NULL,
                            p_token_value2  IN VARCHAR2 DEFAULT NULL,
                            p_token_name3   IN VARCHAR2 DEFAULT NULL,
                            p_token_value3  IN VARCHAR2 DEFAULT NULL) IS
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(32000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', p_message_name);
  IF p_token_name1 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
  END IF;
  IF p_token_name2 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name2, p_token_value2);
  END IF;
  IF p_token_name3 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name3, p_token_value3);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.count_and_get(p_count => l_msg_count,
                            p_data  => l_msg_data);
END add_Error_Message;

--
-- handle exception and put error message to FND stack
--
PROCEDURE handle_Error
(p_message_name  IN  VARCHAR2,
 p_token_name1   IN  VARCHAR2 DEFAULT NULL,
 p_token_value1  IN  VARCHAR2 DEFAULT NULL,
 p_token_name2   IN  VARCHAR2 DEFAULT NULL,
 p_token_value2  IN  VARCHAR2 DEFAULT NULL,
 p_token_name3   IN  VARCHAR2 DEFAULT NULL,
 p_token_value3  IN  VARCHAR2 DEFAULT NULL,
 x_return_status OUT NOCOPY VARCHAR2,
 x_msg_count     OUT NOCOPY NUMBER,
 x_msg_data      OUT NOCOPY VARCHAR2) IS
BEGIN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    add_Error_Message(p_message_name  => p_message_name,
                      p_token_name1   => p_token_name1,
                      p_token_value1  => p_token_value1,
                      p_token_name2   => p_token_name2,
                      p_token_value2  => p_token_value2,
                      p_token_name3   => p_token_name3,
                      p_token_value3  => p_token_value3);
    x_msg_data  := fnd_msg_pub.GET(1,fnd_api.g_false);
END handle_Error;

--
-- handle exception and put error message to FND stack
--
PROCEDURE handle_Error
(p_procedure_name IN  VARCHAR2,
 p_error_message  IN  VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2) IS
BEGIN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := 'Fatal error : '||p_error_message;
    fnd_msg_pub.add_exc_msg('CZ_DEVELOPER_UTILS_PVT', p_procedure_name, x_msg_data);
END handle_Error;

/*
 * This procedure loops over the objects in a folder checking/logging
 * models and UIC templates that are currently locked.
 *
 *   p_rp_folder_id         - folder_id
 *   x_return_status        - status string
 *   x_msg_count            - number of error messages
 *   x_msg_data             - string which contains error messages
 */

PROCEDURE check_folder_for_locks(p_rp_folder_id     IN NUMBER,
                                 x_return_status    OUT  NOCOPY   VARCHAR2,
                                 x_msg_count        OUT  NOCOPY   NUMBER,
                                 x_msg_data         OUT  NOCOPY   VARCHAR2)
IS

  TYPE t_checkout_user_tbl IS TABLE OF cz_devl_projects.checkout_user%TYPE INDEX BY BINARY_INTEGER;
  TYPE number_type_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE name_tbl	IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;

  l_user_name             cz_ui_templates.checkout_user%type;
  l_rp_folder             NUMBER;
  l_rp_model_tbl          number_type_tbl;
  l_rp_fld_tbl            number_type_tbl;
  l_uct_tbl               number_type_tbl;
  l_checkout_user_tbl     t_checkout_user_tbl;
  l_devl_prj_name_tbl     name_tbl;
  l_template_name_tbl     name_tbl;

BEGIN

   x_return_status    := FND_API.g_ret_sts_success;
   x_msg_count        := 0;
   x_msg_data         := '';

   l_user_name := FND_GLOBAL.user_name;

   --check if p_rp_folder_id exists
   SELECT object_id
   INTO   l_rp_folder
   FROM   cz_rp_entries
   WHERE  cz_rp_entries.object_id    = p_rp_folder_id
   AND    cz_rp_entries.object_type  = 'FLD'
   AND    cz_rp_entries.deleted_flag = '0';

   l_rp_fld_tbl.DELETE;

   -- Get all folders and subfolders
   SELECT object_id
   BULK
   COLLECT
   INTO   l_rp_fld_tbl
   FROM   cz_rp_entries
   WHERE  cz_rp_entries.deleted_flag = '0'
   AND    cz_rp_entries.object_type  = 'FLD'
   START WITH cz_rp_entries.object_type = 'FLD'
         AND cz_rp_entries.object_id = l_rp_folder
   CONNECT BY PRIOR cz_rp_entries.object_id = cz_rp_entries.enclosing_folder
    AND   PRIOR cz_rp_entries.object_type = 'FLD';

   IF (l_rp_fld_tbl.COUNT > 0) THEN
	FOR I IN l_rp_fld_tbl.FIRST..l_rp_fld_tbl.LAST
	LOOP

	   ----collect all projects
	   l_rp_model_tbl.DELETE;
	   SELECT object_id, checkout_user, cz_devl_projects.name
	   BULK COLLECT
	   INTO  l_rp_model_tbl, l_checkout_user_tbl, l_devl_prj_name_tbl
	   FROM  cz_rp_entries, cz_devl_projects
	   WHERE cz_rp_entries.object_type = 'PRJ'
	   AND  cz_rp_entries.deleted_flag = '0'
	   AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i)
           AND  cz_rp_entries.object_id = cz_devl_projects.devl_project_id;

	   IF (l_rp_model_tbl.COUNT > 0) THEN
		FOR J IN l_rp_model_tbl.FIRST..l_rp_model_tbl.LAST
		LOOP
                    IF (l_checkout_user_tbl(j) IS NOT NULL AND l_checkout_user_tbl(j) <> l_user_name ) THEN
  		   	FND_MESSAGE.SET_NAME('CZ', 'CZ_COPY_MODEL_IS_LOCKED');
  		    	FND_MESSAGE.SET_TOKEN('MODELNAME', l_devl_prj_name_tbl(j));
  		    	FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user_tbl(j));
  		    	FND_MSG_PUB.ADD;
                        x_return_status    := FND_API.g_ret_sts_error;
                    END IF;
		END LOOP;
	   END IF;

  	  ----get uct
          l_uct_tbl.DELETE;
   	  SELECT object_id, checkout_user, template_name
	  BULK COLLECT
	  INTO  l_uct_tbl, l_checkout_user_tbl, l_template_name_tbl
	  FROM  cz_rp_entries, cz_ui_templates
	  WHERE cz_rp_entries.object_type = 'UCT'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.seeded_flag <> '1'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i)
          AND  cz_rp_entries.object_id = cz_ui_templates.template_id
          AND  cz_ui_templates.ui_def_id = 0;

	  IF (l_uct_tbl.COUNT > 0) THEN
	     FOR J IN l_uct_tbl.FIRST..l_uct_tbl.LAST
	     LOOP
                    IF (l_checkout_user_tbl(j) IS NOT NULL AND l_checkout_user_tbl(j) <> l_user_name ) THEN
  		   	FND_MESSAGE.SET_NAME('CZ', 'CZ_COPY_TMPL_IS_LOCKED');
  		    	FND_MESSAGE.SET_TOKEN('UCTNAME', l_template_name_tbl(j));
  		    	FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user_tbl(j));
  		    	FND_MSG_PUB.ADD;
                        x_return_status := FND_API.g_ret_sts_error;
                    END IF;
	     END LOOP;
	  END IF;

       END LOOP;
    END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
WHEN OTHERS THEN
   handle_Error(p_procedure_name => 'check_folder_for_locks',
                p_error_message  => SQLERRM,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);

END check_folder_for_locks;

--
-- update node names in rule text
-- Parameters : p_rule_id - identifies rule
-- Returns    : rule text with updated node names
--
FUNCTION replace_Rule_Text(p_rule_id     IN NUMBER,
                           p_use_profile IN NUMBER DEFAULT 0) RETURN CLOB IS

     MAX_CHUNK_SIZE     INTEGER := 32000;
     l_var_str          VARCHAR2(32000);
     l_var_str1         VARCHAR2(32000);
     l_var_str2         VARCHAR2(32000);
     l_var_path         VARCHAR2(32000);
     l_rule_text_str    VARCHAR2(32000);
     l_source_offset    NUMBER;
     l_model_id         NUMBER;

     PROCEDURE put_String_Into_CLOB(p_buffer IN VARCHAR2) IS

         l_clob_loc       CLOB;
         l_amount         BINARY_INTEGER;
         l_position       INTEGER := 1;

     BEGIN

         UPDATE CZ_RULES
         SET rule_text = EMPTY_CLOB()
         WHERE rule_id = p_rule_id;

         SELECT rule_text INTO l_clob_loc FROM CZ_RULES
         WHERE rule_id = p_rule_id;

         DBMS_LOB.OPEN(l_clob_loc,DBMS_LOB.lob_readwrite);

         l_amount:=LENGTH(p_buffer);

         DBMS_LOB.WRITE(l_clob_loc, l_amount, l_position, p_buffer);

         DBMS_LOB.CLOSE (l_clob_loc);

     END put_String_Into_CLOB;

     FUNCTION get_String_From_CLOB RETURN VARCHAR2 IS

         l_clob_loc       CLOB;
         l_chunksize      INTEGER;
         l_amount         BINARY_INTEGER;
         l_position       INTEGER := 1;
         l_buffer         VARCHAR2(32000);

     BEGIN

         --Bug #6936712. Removing calls to opening-closing DBMS_LOB procedures.
         --The following SELECT creates a temporary LOB, so there is no need in
         --explicit call to CREATETEMPORARY. Temporary LOBs will get freed
         --automatically - examples in Oracle Doc do not call FREETEMPORARY.
         --Also, Oracle Doc says that calls to OPEN-CLOSE are not required. It
         --seems that DBMS successfully manages LOBs.

         SELECT rule_text INTO l_clob_loc FROM CZ_RULES
         WHERE rule_id = p_rule_id;

         l_chunksize := DBMS_LOB.GETCHUNKSIZE(l_clob_loc);
         --vsingava 18th Dec '08 bug7316397
         IF (l_chunksize < MAX_CHUNK_SIZE) THEN
            l_amount := FLOOR(MAX_CHUNK_SIZE / l_chunksize) * l_chunksize;
         ELSE
            l_amount := MAX_CHUNK_SIZE;
         END IF;

         BEGIN
             LOOP
                DBMS_LOB.READ (l_clob_loc, l_amount, l_position, l_buffer);
                l_position := l_position + l_amount;
             END LOOP;
         EXCEPTION
             WHEN OTHERS THEN
                  NULL;
         END;

         RETURN l_buffer;

     END get_String_From_CLOB;

--This procedure retrieves the full model path and cuts it according to node_depth.

     FUNCTION get_Path(p_model_id IN NUMBER,p_ps_node_id IN NUMBER,
                       p_model_ref_expl_id IN NUMBER, p_depth IN NUMBER)
       RETURN VARCHAR2 IS

         l_nodes_tbl  t_varchar_array_tbl_type;
         l_depth      NUMBER;
         l_path       VARCHAR2(32000);
         l_full_path  VARCHAR2(32000);
         l_substr     VARCHAR2(32000);
         l_name       CZ_PS_NODES.name%TYPE;
         l_to         NUMBER;
         l_from       NUMBER;
         l_index      NUMBER;
         l_shift      NUMBER;

     BEGIN

       IF(p_use_profile = 0)THEN

         l_full_path := get_Full_Model_Path(p_ps_node_id          => p_ps_node_id,
                                            p_model_ref_expl_id   => p_model_ref_expl_id,
                                            p_model_id            => p_model_id);
       ELSE

         l_full_path := get_Full_Label_Path(p_ps_node_id          => p_ps_node_id,
                                            p_model_ref_expl_id   => p_model_ref_expl_id,
                                            p_model_id            => p_model_id);
       END IF;

       l_substr := REPLACE(l_full_path, '\''', FND_GLOBAL.LOCAL_CHR(7) || FND_GLOBAL.LOCAL_CHR(8));
       LOOP

          IF(SUBSTR(l_substr, 1, 1) = '''')THEN

            l_index := INSTR(l_substr,'''.');

            --The original node name can start with ., so '. will be found at the position 1.
            --In this case we need the second one.

            IF(l_index = 1)THEN l_index := INSTR(l_substr, '''.', 2); END IF;
            l_shift := 2;
          ELSE

            l_index := INSTR(l_substr,'.');
            l_shift := 1;
          END IF;

          IF l_index > 0 THEN
            l_nodes_tbl(l_nodes_tbl.COUNT + 1) := SUBSTR(l_substr, 1, l_index - 2 + l_shift);
            l_substr := SUBSTR(l_substr, l_index + l_shift);
          ELSE
            l_nodes_tbl(l_nodes_tbl.COUNT + 1) := l_substr;
            EXIT;
          END IF;
       END LOOP;

       l_to   := l_nodes_tbl.Count;

       FOR i IN 1..l_to LOOP

         --Bug #3545083 - we need all the names enclosed in single quotes for the purposes of the
         --replace_Rule_Text procedure, therefore enclose it here if necessary.

         IF(SUBSTR(l_nodes_tbl(i), 1, 1) <> '''')THEN l_nodes_tbl(i) := '''' || l_nodes_tbl(i) || ''''; END IF;
       END LOOP;

       l_from := l_to - p_depth + 1;
       IF(l_from <= l_to)THEN l_path := l_nodes_tbl(l_from); END IF;

       FOR i IN l_from + 1..l_to LOOP
         l_path := l_path || '.' || l_nodes_tbl(i);
       END LOOP;

       RETURN REPLACE(l_path, FND_GLOBAL.LOCAL_CHR(7) || FND_GLOBAL.LOCAL_CHR(8), '\''');
     END get_Path;

     FUNCTION get_Property(p_property_id IN NUMBER) RETURN VARCHAR2 IS
         l_property_name CZ_PROPERTIES.NAME%TYPE;
     BEGIN
         SELECT NAME INTO l_property_name FROM CZ_PROPERTIES
         WHERE property_id=p_property_id;
         RETURN '"' || l_property_name || '"';
     END get_Property;

BEGIN

    SELECT devl_project_id INTO l_model_id FROM CZ_RULES
    WHERE rule_id=p_rule_id;

    l_rule_text_str := get_String_From_CLOB();

    FOR i IN(SELECT source_offset,source_length,display_node_depth,
             ps_node_id,property_id,model_ref_expl_id FROM CZ_EXPRESSION_NODES
             WHERE rule_id = p_rule_id AND expr_type IN(205,207)
             AND deleted_flag='0' ORDER BY -source_offset)
    LOOP

       IF i.source_offset=0 THEN
          l_source_offset := 1;
       ELSE
          l_source_offset := i.source_offset;
       END IF;

       IF l_source_offset =1 THEN
          l_var_str1 := '';
       ELSE
          l_var_str1 := SUBSTR(l_rule_text_str,1,l_source_offset-1);
       END IF;

       l_var_str2 := SUBSTR(l_rule_text_str,l_source_offset+i.source_length);
       IF i.property_id IS NULL THEN
          l_var_path := get_Path(l_model_id,i.ps_node_id,i.model_ref_expl_id,i.display_node_depth);
       ELSE
          l_var_path := get_Property(i.property_id);
       END IF;

       l_rule_text_str := l_var_str1||l_var_path||l_var_str2;
    END LOOP;

    RETURN l_rule_text_str;

END replace_Rule_Text;

--
-- generate NEW ID FROM a given sequence
--  Parameters : p_sequence_name - name of DB sequence
--  Return     : next id from sequence
--
FUNCTION allocateId(p_sequence_name IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
BEGIN
    EXECUTE IMMEDIATE
    'SELECT '||p_sequence_name||'.NEXTVAL FROM dual' INTO l_id;
    RETURN l_id;
END allocateId;

--
-- create a copy of INTL TEXT record
-- Parameters :
--   p_intl_text_id - identifies INTL TEXT record
-- Returns : id of new INTL TEXT record
--
FUNCTION copy_INTL_TEXT(p_intl_text_id IN VARCHAR2) RETURN NUMBER IS

    l_new_intl_text_id NUMBER;
    l_counter          NUMBER := 0;

BEGIN

    IF p_intl_text_id IS NULL THEN
       RETURN NULL;
    END IF;

    l_new_intl_text_id := allocateId('CZ_INTL_TEXTS_S');

    FOR i IN(SELECT intl_text_id,language,localized_str,source_lang FROM CZ_LOCALIZED_TEXTS
             WHERE intl_text_id=p_intl_text_id AND deleted_flag='0')
    LOOP
       INSERT INTO CZ_LOCALIZED_TEXTS
                     (INTL_TEXT_ID,
                      LOCALIZED_STR,
                      LANGUAGE,
                      SOURCE_LANG,
                      DELETED_FLAG,
                      SECURITY_MASK,
                      CHECKOUT_USER,
                      UI_DEF_ID,
                      MODEL_ID,
		      PERSISTENT_INTL_TEXT_ID,
                      SEEDED_FLAG)
       SELECT
                      l_new_intl_text_id,
                      LOCALIZED_STR,
                      LANGUAGE,
                      SOURCE_LANG,
                      DELETED_FLAG,
                      SECURITY_MASK,
                      CHECKOUT_USER,
                      UI_DEF_ID,
                      MODEL_ID,
			    l_new_intl_text_id,
                            '0'
       FROM CZ_LOCALIZED_TEXTS
       WHERE intl_text_id=p_intl_text_id AND
             language=i.LANGUAGE AND
             source_lang=i.SOURCE_LANG AND deleted_flag='0';
       l_counter := l_counter + 1;
    END LOOP;
    IF l_counter = 0 THEN
       RETURN -1;
    END IF;
    RETURN l_new_intl_text_id;
END copy_INTL_TEXT;

--
-- copy subtree
--
--
PROCEDURE copy_Expl_Subtree
(
 p_model_ref_expl_id          IN NUMBER,
 p_curr_node_depth            IN NUMBER,
 p_new_parent_expl_id         IN NUMBER,
 p_new_parent_expl_node_depth IN NUMBER,
 p_ps_nodes_tbl               IN t_int_array_tbl_type_idx_vc2,
 x_expl_nodes_tbl             OUT NOCOPY t_int_array_tbl_type
) IS

    l_new_expl_id         NUMBER;
    l_new_parent_expl_id  NUMBER;
    l_new_component_id    NUMBER;
    l_referring_node_id   NUMBER;
    l_node_depth          NUMBER;
    l_index               NUMBER;
    l_delta               NUMBER;

BEGIN
    l_delta := p_curr_node_depth -  p_new_parent_expl_node_depth;

    FOR i IN(SELECT * FROM CZ_MODEL_REF_EXPLS
             START WITH model_ref_expl_id=p_model_ref_expl_id AND deleted_flag='0'
             CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0'
             AND PRIOR deleted_flag='0')
    LOOP
       x_expl_nodes_tbl(i.model_ref_expl_id) := allocateId('CZ_MODEL_REF_EXPLS_S');
--dbms_output.put_line('i.model_ref_expl_id:'||i.model_ref_expl_id);
--dbms_output.put_line(x_expl_nodes_tbl(i.model_ref_expl_id));
    END LOOP;

    l_index := x_expl_nodes_tbl.FIRST;

    LOOP
       IF l_index IS NULL THEN
          EXIT;
       END IF;

       FOR i IN(SELECT * FROM CZ_MODEL_REF_EXPLS
                WHERE model_ref_expl_id = l_index )
       LOOP

          l_referring_node_id  := NULL;
          l_new_component_id   := NULL;
          l_new_parent_expl_id := NULL;
          l_node_depth := i.node_depth - l_delta + 1;
          l_new_expl_id := x_expl_nodes_tbl(i.model_ref_expl_id);

          IF i.parent_expl_node_id IS NULL OR i.model_ref_expl_id=p_model_ref_expl_id THEN
             l_new_parent_expl_id := p_new_parent_expl_id;
          ELSE
             l_new_parent_expl_id := x_expl_nodes_tbl(i.parent_expl_node_id);
          END IF;

          IF (p_ps_nodes_tbl.EXISTS(i.component_id)) THEN
              l_new_component_id := p_ps_nodes_tbl(i.component_id);
          ELSE
             l_new_component_id := i.component_id;
          END IF;

          IF (p_ps_nodes_tbl.EXISTS(i.referring_node_id)) THEN
             l_referring_node_id := p_ps_nodes_tbl(i.referring_node_id);
          ELSE
             l_referring_node_id := i.referring_node_id;
          END IF;

          INSERT INTO CZ_MODEL_REF_EXPLS
          (
           MODEL_REF_EXPL_ID
           ,COMPONENT_ID
           ,PARENT_EXPL_NODE_ID
           ,PS_NODE_TYPE
           ,MODEL_ID
           ,VIRTUAL_FLAG
           ,NODE_DEPTH
           ,DELETED_FLAG
           ,REFERRING_NODE_ID
           ,CHILD_MODEL_EXPL_ID
           ,EXPL_NODE_TYPE
           ,HAS_TRACKABLE_CHILDREN
           )
           VALUES
           (
                        l_new_expl_id
                        ,l_new_component_id
                        ,l_new_parent_expl_id
           ,i.PS_NODE_TYPE
           ,i.MODEL_ID
           ,i.VIRTUAL_FLAG
                       ,l_node_depth
           ,i.DELETED_FLAG
                       ,l_referring_node_id
           ,i.CHILD_MODEL_EXPL_ID
           ,i.EXPL_NODE_TYPE
           ,i.HAS_TRACKABLE_CHILDREN
           );

       END LOOP;
       l_index := x_expl_nodes_tbl.NEXT(l_index);
    END LOOP;

END copy_Expl_Subtree;

--
-- copy subtree of Model tree
-- Parameters :
--   p_node_id       - identifies root node of subtree
--   p_new_parent_id - identifies new parent node
--   p_copy_mode     - specifies mode of copying
--   x_run_id        - OUT parameter : if =0 => no errors
--                   - else =CZ_DB_LOGS.run_id
--   x_return_status - status string
--   x_msg_count     - number of error messages
--   x_msg_data      - string which contains error messages
--
PROCEDURE copy_PS_Subtree
(
p_node_id IN NUMBER,
p_new_parent_id      IN  NUMBER,
p_copy_mode          IN  VARCHAR2,
x_run_id             OUT NOCOPY NUMBER,
x_return_status      OUT NOCOPY VARCHAR2,
x_msg_count          OUT NOCOPY NUMBER,
x_msg_data           OUT NOCOPY VARCHAR2
) IS

    l_new_intl_text_id    NUMBER;
    l_new_violation_text_id  NUMBER;
    l_new_node_id         NUMBER;
    l_new_parent_id       NUMBER;
    l_model_id            NUMBER;
    l_component_id        NUMBER;
    l_new_component_id    NUMBER;
    l_reference_id        NUMBER;
    l_parent_expl_id      NUMBER;
    l_new_pr_expl_id      NUMBER;
    l_parent_component_id NUMBER;
    l_expl_id             NUMBER;
    l_node_depth          NUMBER;
    l_parent_id           NUMBER;
    l_tree_seq            NUMBER;
    l_index               NUMBER;
    l_name                CZ_PS_NODES.name%TYPE;
    l_virtual_flag        VARCHAR2(1);

    l_ps_nodes_tbl         t_int_array_tbl_type_idx_vc2;
    l_persistent_tbl       t_int_array_tbl_type_idx_vc2;
    l_ps_node_type_tbl     t_int_array_tbl_type_idx_vc2;
    l_comp_tbl             t_int_array_tbl_type_idx_vc2;
    l_node_name_tbl        t_varchar_array_tbl_type_vc2;-- kdande; Bug 6880555; 12-Mar-2008
    l_top_ref_node_id      NUMBER;
    l_node_counter         NUMBER;
    l_expl_nodes_tbl       t_int_array_tbl_type;
    l_curr_node_depth      NUMBER;
    l_min_node_depth       NUMBER;
    l_text_id              NUMBER;
    l_ps_node_type         NUMBER;
    l_expl_nodes_all_tbl   t_int_array_tbl_type;
    l_new_expl_id          NUMBER;

BEGIN

    FND_MSG_PUB.initialize;
    Initialize;
    l_ps_nodes_tbl.delete;
    l_persistent_tbl.delete;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- get the info from the node to be copied
    SELECT devl_project_id,parent_id,reference_id,component_id,virtual_flag,ps_node_type
    INTO l_model_id,l_parent_id,l_reference_id,l_component_id,l_virtual_flag,l_ps_node_type
    FROM CZ_PS_NODES
    WHERE ps_node_id=p_node_id;

    -- if not a reference node, get the model_refexpl_id record in model ref expls
    IF l_reference_id IS NULL THEN
       SELECT model_ref_expl_id, node_depth INTO l_expl_id, l_curr_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND component_id=l_component_id AND
       child_model_expl_id IS NULL AND deleted_flag='0';
    ELSE
       SELECT MIN(node_depth) INTO l_min_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND referring_node_id=p_node_id
             AND deleted_flag='0';

       SELECT model_ref_expl_id, node_depth INTO l_expl_id, l_curr_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND referring_node_id=p_node_id AND
       node_depth=l_min_node_depth AND deleted_flag='0';
    END IF;

    -- get the ref expl id and node depth of the destination node in ref expls
    SELECT model_ref_expl_id,node_depth INTO l_new_pr_expl_id, l_node_depth
    FROM CZ_MODEL_REF_EXPLS
    WHERE model_id=l_model_id AND component_id=(SELECT component_id
    FROM CZ_PS_NODES WHERE ps_node_id = p_new_parent_id) AND referring_node_id IS NULL AND
    child_model_expl_id IS NULL AND deleted_flag='0';

    FOR i IN (SELECT ps_node_id, ps_node_type, component_id, persistent_node_id, name FROM CZ_PS_NODES
              START WITH ps_node_id=p_node_id AND deleted_flag='0'
              CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag='0' AND PRIOR deleted_flag='0')
    LOOP
        l_ps_nodes_tbl(i.ps_node_id) := getPSSeqVal;
        l_ps_node_type_tbl(i.ps_node_id) := i.ps_node_type;
        l_node_name_tbl(i.ps_node_id) := i.name;
        l_comp_tbl(i.ps_node_id) := i.component_id;
        l_persistent_tbl(i.persistent_node_id) := l_ps_nodes_tbl(i.ps_node_id);
    END LOOP;
    l_index := l_ps_nodes_tbl.FIRST;
    LOOP
       IF l_index IS NULL THEN
          EXIT;
       END IF;

       FOR i IN (SELECT * FROM CZ_PS_NODES
                 WHERE ps_node_id=l_index AND deleted_flag='0')
       LOOP
          IF i.ps_node_id=p_node_id THEN
             l_new_parent_id := p_new_parent_id;
             SELECT NVL(MAX(tree_seq),0) + 1 INTO l_tree_seq
             FROM cz_ps_nodes
             WHERE parent_id=p_new_parent_id;
          ELSE
             l_new_parent_id := l_ps_nodes_tbl(i.parent_id);
             l_tree_seq := i.TREE_SEQ;
          END IF;

          l_new_node_id := l_ps_nodes_tbl(i.ps_node_id);

          IF i.intl_text_id IS NOT NULL THEN
             l_text_id := i.intl_text_id;
             l_new_intl_text_id := copy_INTL_TEXT(i.intl_text_id);
             IF l_new_intl_text_id = -1 THEN
               RAISE NO_TXT_FOUND_EXCP;
             END IF;
          ELSE
             l_new_intl_text_id:=NULL;
          END IF;

          IF i.violation_text_id IS NOT NULL THEN
             l_text_id := i.violation_text_id;
             l_new_violation_text_id := copy_INTL_TEXT(i.violation_text_id);
             IF l_new_violation_text_id = -1 THEN
               RAISE NO_TXT_FOUND_EXCP;
             END IF;
          ELSE
             l_new_violation_text_id:=NULL;
          END IF;

          IF l_new_parent_id=p_new_parent_id THEN
            SELECT COUNT(*) INTO l_node_counter FROM CZ_PS_NODES
            WHERE parent_id=p_new_parent_id AND
                  (name=i.NAME OR name LIKE 'Copy (%) of '||i.NAME) AND deleted_flag='0';
            IF l_node_counter > 0 THEN
              l_name := 'Copy ('||TO_CHAR(l_node_counter)||') of '||i.NAME;
            ELSE
              l_name := i.NAME;
            END IF;
          ELSE
            l_name := i.NAME;
          END IF;

          INSERT INTO CZ_PS_NODES
          (
           PS_NODE_ID
          ,DEVL_PROJECT_ID
          ,FROM_POPULATOR_ID
          ,PROPERTY_BACKPTR
          ,ITEM_TYPE_BACKPTR
          ,INTL_TEXT_ID
          ,SUB_CONS_ID
          ,ITEM_ID
          ,NAME
          ,ORIG_SYS_REF
          ,RESOURCE_FLAG
          ,INITIAL_VALUE
          ,PARENT_ID
          ,MINIMUM
          ,MAXIMUM
          ,PS_NODE_TYPE
          ,FEATURE_TYPE
          ,PRODUCT_FLAG
          ,REFERENCE_ID
          ,MULTI_CONFIG_FLAG
          ,ORDER_SEQ_FLAG
          ,SYSTEM_NODE_FLAG
          ,TREE_SEQ
          ,COUNTED_OPTIONS_FLAG
          ,UI_OMIT
          ,UI_SECTION
          ,BOM_TREATMENT
          ,COMPONENT_SEQUENCE_ID
          ,BOM_REQUIRED_FLAG
          ,SO_ITEM_TYPE_CODE
          ,MINIMUM_SELECTED
          ,MAXIMUM_SELECTED
          ,DELETED_FLAG
          ,EFF_FROM
          ,EFF_TO
          ,SECURITY_MASK
          ,EFF_MASK
          ,CHECKOUT_USER
          ,USER_NUM01
          ,USER_NUM02
          ,USER_NUM03
          ,USER_NUM04
          ,USER_STR01
          ,USER_STR02
          ,USER_STR03
          ,USER_STR04
          ,VIRTUAL_FLAG
          ,EFFECTIVE_USAGE_MASK
          ,EFFECTIVE_FROM
          ,EFFECTIVE_UNTIL
          ,DECIMAL_QTY_FLAG
          ,PERSISTENT_NODE_ID
          ,COMPONENT_SEQUENCE_PATH
          ,VIOLATION_TEXT_ID
          ,EFFECTIVITY_SET_ID
          ,QUOTEABLE_FLAG
          ,PRIMARY_UOM_CODE
          ,BOM_SORT_ORDER
          ,IB_TRACKABLE
          ,COMPONENT_ID
          ,ACCUMULATOR_FLAG
          ,NOTES_TEXT_ID
          ,INSTANTIABLE_FLAG
          ,INITIAL_NUM_VALUE
          ,SRC_APPLICATION_ID
          ,MAX_LENGTH
          ,DISPLAYNAME_CAPT_RULE_ID
          ,DISPLAYNAME_TEXT_ID
          )
          VALUES
          (
                               l_new_node_id
          ,i.DEVL_PROJECT_ID
          ,i.FROM_POPULATOR_ID
          ,i.PROPERTY_BACKPTR
          ,i.ITEM_TYPE_BACKPTR
                               ,l_new_intl_text_id
          ,i.SUB_CONS_ID
          ,i.ITEM_ID
                               ,l_name
          ,NULL
          ,i.RESOURCE_FLAG
          ,i.INITIAL_VALUE
                               ,l_new_parent_id
          ,i.MINIMUM
          ,i.MAXIMUM
          ,i.PS_NODE_TYPE
          ,i.FEATURE_TYPE
          ,i.PRODUCT_FLAG
          ,i.REFERENCE_ID
          ,i.MULTI_CONFIG_FLAG
          ,i.ORDER_SEQ_FLAG
          ,i.SYSTEM_NODE_FLAG
          ,l_tree_seq
          ,i.COUNTED_OPTIONS_FLAG
          ,i.UI_OMIT
          ,i.UI_SECTION
          ,i.BOM_TREATMENT
          ,i.COMPONENT_SEQUENCE_ID
          ,i.BOM_REQUIRED_FLAG
          ,i.SO_ITEM_TYPE_CODE
          ,i.MINIMUM_SELECTED
          ,i.MAXIMUM_SELECTED
          ,i.DELETED_FLAG
          ,i.EFF_FROM
          ,i.EFF_TO
          ,i.SECURITY_MASK
          ,i.EFF_MASK
          ,i.CHECKOUT_USER
          ,i.USER_NUM01
          ,i.USER_NUM02
          ,i.USER_NUM03
          ,i.USER_NUM04
          ,i.USER_STR01
          ,i.USER_STR02
          ,i.USER_STR03
          ,i.USER_STR04
          ,i.VIRTUAL_FLAG
          ,i.EFFECTIVE_USAGE_MASK
          ,i.EFFECTIVE_FROM
          ,i.EFFECTIVE_UNTIL
          ,i.DECIMAL_QTY_FLAG
                                       ,l_new_node_id
          ,i.COMPONENT_SEQUENCE_PATH
                                       ,l_new_violation_text_id
          ,i.EFFECTIVITY_SET_ID
          ,i.QUOTEABLE_FLAG
          ,i.PRIMARY_UOM_CODE
          ,i.BOM_SORT_ORDER
          ,i.IB_TRACKABLE
          ,i.COMPONENT_ID
          ,i.ACCUMULATOR_FLAG
          ,i.NOTES_TEXT_ID
          ,i.INSTANTIABLE_FLAG
          ,i.INITIAL_NUM_VALUE
          ,i.SRC_APPLICATION_ID
          ,i.MAX_LENGTH
          ,i.DISPLAYNAME_CAPT_RULE_ID
          ,i.DISPLAYNAME_TEXT_ID
          );

         -- copy ps node property values, if any

         INSERT INTO CZ_PS_PROP_VALS(
            PS_NODE_ID
           ,PROPERTY_ID
           ,DATA_VALUE
           ,DELETED_FLAG
           ,EFF_FROM
           ,EFF_TO
           ,SECURITY_MASK
            ,EFF_MASK
           ,CHECKOUT_USER
           ,ORIG_SYS_REF
           ,DATA_NUM_VALUE
           )
         SELECT
                         l_new_node_id
           ,PROPERTY_ID
           ,DATA_VALUE
           ,DELETED_FLAG
           ,EFF_FROM
           ,EFF_TO
           ,SECURITY_MASK
           ,EFF_MASK
           ,CHECKOUT_USER
                          ,NULL
           ,DATA_NUM_VALUE
         FROM CZ_PS_PROP_VALS
         WHERE PS_NODE_ID=l_index
         AND DELETED_FLAG='0';

       END LOOP;

       l_index := l_ps_nodes_tbl.NEXT(l_index);

    END LOOP;

    IF (l_virtual_flag='1' OR l_virtual_flag IS NULL) AND l_parent_id IS NOT NULL AND l_ps_node_type IN(COMPONENT_TYPE) THEN
        FOR i IN(SELECT model_ref_expl_id, node_depth FROM CZ_MODEL_REF_EXPLS
                  WHERE parent_expl_node_id=l_expl_id AND
                  (referring_node_id IS NULL AND component_id IN
                   (SELECT ps_node_id FROM CZ_PS_NODES
                    START WITH ps_node_id=p_node_id
                    CONNECT BY PRIOR ps_node_id=parent_id AND
                    deleted_flag='0' AND PRIOR deleted_flag='0'))
                 UNION
                 SELECT model_ref_expl_id, node_depth FROM CZ_MODEL_REF_EXPLS
                  WHERE parent_expl_node_id=l_expl_id AND
                  (referring_node_id IS NOT NULL AND referring_node_id IN
                 (SELECT ps_node_id FROM CZ_PS_NODES
                  START WITH ps_node_id=p_node_id
                  CONNECT BY PRIOR ps_node_id=parent_id AND
                  deleted_flag='0' AND PRIOR deleted_flag='0')))

         LOOP

            copy_Expl_Subtree(p_model_ref_expl_id          => i.model_ref_expl_id,
                              p_curr_node_depth            => i.node_depth,
                              p_new_parent_expl_id         => l_new_pr_expl_id,
                              p_new_parent_expl_node_depth => l_node_depth,
                              p_ps_nodes_tbl               => l_ps_nodes_tbl,
                              x_expl_nodes_tbl             => l_expl_nodes_tbl);

            --
            --   save in the new map to use later for updating the expl ids for rules
            --

            l_index:=l_expl_nodes_tbl.FIRST;
            LOOP
              IF l_index IS NULL THEN
               EXIT;
              END IF;
              l_expl_nodes_all_tbl(l_index):=l_expl_nodes_tbl(l_index);
              l_index := l_expl_nodes_tbl.NEXT(l_index);
            END LOOP;

         END LOOP;

    ELSIF (l_virtual_flag='0' OR l_parent_id IS NULL) OR l_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE)  THEN

       copy_Expl_Subtree(p_model_ref_expl_id          => l_expl_id,
                         p_curr_node_depth            => l_curr_node_depth,
                         p_new_parent_expl_id         => l_new_pr_expl_id,
                         p_new_parent_expl_node_depth => l_node_depth,
                         p_ps_nodes_tbl               => l_ps_nodes_tbl,
                         x_expl_nodes_tbl             => l_expl_nodes_tbl);

    END IF;

    CZ_REFS.populate_Component_Id(l_model_id);
    --vsingava bug7831246
    CZ_REFS.populate_parent_expl_tree(p_ps_node_id   =>  l_ps_nodes_tbl(p_node_id),
                                      p_model_id     =>  l_model_id);


    /* begining of copy associated rules option */

  IF (p_copy_mode = '2') THEN
    DECLARE
      l_rule_folder_id_tbl       t_num_array_tbl_type;
      l_rule_id_tbl              t_num_array_tbl_type;
      l_rule_type_tbl            t_num_array_tbl_type;
      l_rule_compid_tbl          t_num_array_tbl_type;
      l_rule_model_refexpl_tbl   t_num_array_tbl_type;
      l_ref_models_tbl           t_num_array_tbl_type;
      l_ref_model_id_tbl         t_num_array_tbl_type;
      l_rule_node_model_tbl      t_num_array_tbl_type;
      l_model_ref_expl_tbl       t_num_array_tbl_type;
      l_rule_nodes_tbl           t_num_array_tbl_type;
      l_new_rule_id              NUMBER;
      l_run_id                   NUMBER;
      l_return_status            VARCHAR2(1);
      l_msg_count                NUMBER;
      l_msg_data                 VARCHAR2(2000);
      l_copy_rule                BOOLEAN:=FALSE;
      l_node_found               BOOLEAN:=FALSE;
      l_referenced_model_id      NUMBER;
      l_count                    NUMBER;
      l_ref_node_found           BOOLEAN:=FALSE;
      -------------------------------------------
      -- cursor to load all rules in this project
      -------------------------------------------
      CURSOR l_model_rules_csr is
      SELECT rule_id, rule_folder_id, rule_type, component_id, model_ref_expl_id
      FROM cz_rules
      WHERE devl_project_id = l_model_id
      AND deleted_flag = '0'
      AND rule_type IN (RULE_TYPE_EXPRESSION,RULE_TYPE_COMPAT_TABLE,RULE_TYPE_DESIGNCHART,RULE_TYPE_JAVA_METHOD);
      ------------------------------------------------------------------------
      -- cursor to load all participating ps nodes in a expression or CX rule
      ------------------------------------------------------------------------
      CURSOR l_rule_nodes_csr (iRuleId NUMBER) IS
      SELECT DISTINCT e.ps_node_id, p.devl_project_id, e.model_ref_expl_id
      FROM cz_expression_nodes e, cz_rules r, cz_ps_nodes p
      WHERE e.deleted_flag = '0'
      AND r.deleted_flag = '0'
      AND p.deleted_flag = '0'
      AND p.ps_node_id = e.ps_node_id
      AND r.rule_id = e.rule_id
      AND r.rule_id = iRuleId
      AND e.ps_node_id IS NOT NULL;
      ----------------------------------------------------------------------------------
      -- cursor to load all participating ps nodes in design chart or explicit comp rule
      ----------------------------------------------------------------------------------
      CURSOR l_rule_nodes_csr2 (iRuleId NUMBER) IS
      SELECT DISTINCT f.feature_id, p.devl_project_id, f.model_ref_expl_id
      FROM cz_des_chart_features f, cz_rules r, cz_ps_nodes p
      WHERE f.deleted_flag = '0'
      AND r.deleted_flag = '0'
      AND p.deleted_flag = '0'
      AND p.ps_node_id = f.feature_id
      AND r.rule_id = f.rule_id
      AND r.rule_id = iRuleId
      AND f.feature_id IS NOT NULL;

    BEGIN
      -----------------------------------
      -- load all the rules of this model
      -----------------------------------
      OPEN l_model_rules_csr;
      FETCH l_model_rules_csr BULK COLLECT INTO
      l_rule_id_tbl, l_rule_folder_id_tbl, l_rule_type_tbl, l_rule_compid_tbl, l_rule_model_refexpl_tbl;
      CLOSE l_model_rules_csr;

      --
      -- get the nearest expl id of the newly created root node of the subtree
      --
      l_index := l_ps_nodes_tbl.FIRST;
      IF l_index = NULL THEN
        RETURN;
      END IF;

      IF (l_ps_node_type_tbl(l_index) IN (263, 264)) THEN
          SELECT model_ref_expl_id INTO l_new_expl_id
          FROM cz_model_ref_expls a, cz_ps_nodes b
          WHERE a.referring_node_id = l_ps_nodes_tbl(l_index)
          AND a.referring_node_id = b.ps_node_id
          AND b.devl_project_id = l_model_id
          AND a.model_id = l_model_id
          AND b.ps_node_type = l_ps_node_type_tbl(l_index)
          AND a.deleted_flag='0'
          AND b.deleted_flag='0';
      ELSE
          SELECT component_id INTO l_new_component_id
          FROM cz_ps_nodes
          WHERE ps_node_id=l_ps_nodes_tbl(l_index);

          SELECT model_ref_expl_id INTO l_new_expl_id
          FROM cz_model_ref_expls a, cz_ps_nodes b
          WHERE a.component_id = b.ps_node_id
          AND b.ps_node_id = l_new_component_id
          AND b.devl_project_id = l_model_id
          AND a.model_id = b.devl_project_id
          AND a.deleted_flag = '0'
          AND b.deleted_flag = '0';
      END IF;

      IF (l_rule_id_tbl.COUNT > 0) THEN
        FOR i IN l_rule_id_tbl.FIRST..l_rule_id_tbl.LAST LOOP
          l_copy_rule := TRUE;

          IF (l_rule_type_tbl(i) = RULE_TYPE_JAVA_METHOD AND NOT l_ps_nodes_tbl.EXISTS(l_rule_compid_tbl(i))) THEN

            SELECT devl_project_id INTO l_referenced_model_id
            FROM cz_ps_nodes
            WHERE ps_node_id = l_rule_compid_tbl(i)
            AND deleted_flag = '0';

            l_node_found := FALSE;
            l_index := l_ps_nodes_tbl.FIRST;
            LOOP
              IF l_index IS NULL THEN
                 EXIT;
              END IF;
                   IF (l_ps_node_type_tbl(l_index) IN (263, 264)) THEN

                     FOR k IN (SELECT * FROM cz_model_ref_expls
                               START WITH model_id=l_model_id AND referring_node_id = l_index
                                      AND component_id = l_comp_tbl(l_index) AND ps_node_type = l_ps_node_type_tbl(l_index)
                                      AND deleted_flag = '0'
                               CONNECT BY PRIOR model_ref_expl_id = parent_expl_node_id
                                      AND deleted_flag = '0' AND PRIOR deleted_flag = '0')
                     LOOP

                        IF(k.component_id = l_referenced_model_id AND k.model_ref_expl_id = l_rule_model_refexpl_tbl(i)) THEN
                            l_node_found := TRUE;
                            EXIT;
                        END IF;
                     END LOOP;
                   END IF;
              l_index := l_ps_nodes_tbl.NEXT(l_index);
            END LOOP;

            IF (l_node_found = FALSE) THEN
                l_copy_rule := FALSE;
            END IF;

          END IF;

          l_rule_nodes_tbl.delete; l_rule_node_model_tbl.delete; l_model_ref_expl_tbl.delete;

          --
          -- load all the participants ps nodes in this rule
          --

          IF l_copy_rule = TRUE THEN
            IF l_rule_type_tbl(i) IN (RULE_TYPE_EXPRESSION, RULE_TYPE_JAVA_METHOD) THEN
              OPEN l_rule_nodes_csr(l_rule_id_tbl(i));
              FETCH l_rule_nodes_csr BULK COLLECT  INTO l_rule_nodes_tbl, l_rule_node_model_tbl, l_model_ref_expl_tbl;
              CLOSE l_rule_nodes_csr;
            ELSIF l_rule_type_tbl(i) IN (RULE_TYPE_DESIGNCHART, RULE_TYPE_COMPAT_TABLE) THEN
              OPEN l_rule_nodes_csr2(l_rule_id_tbl(i));
              FETCH l_rule_nodes_csr2 BULK COLLECT  INTO l_rule_nodes_tbl, l_rule_node_model_tbl, l_model_ref_expl_tbl;
              CLOSE l_rule_nodes_csr2;
            END IF;
          END IF;

          IF (l_rule_nodes_tbl.COUNT > 0) THEN
            FOR j IN l_rule_nodes_tbl.FIRST..l_rule_nodes_tbl.LAST LOOP

              l_node_found := FALSE;
              -------------------------------------------------
              -- check if this ps node belongs to this model
              -- if so, search the entire subtree for this node
              -------------------------------------------------
              IF (l_rule_node_model_tbl(j) = l_model_id) THEN
                    IF l_ps_nodes_tbl.EXISTS(l_rule_nodes_tbl(j)) THEN
                      l_node_found := TRUE;
                    END IF;
              ELSE
                 ----------------------------------------------------------------------------
                 --  check if the ps node belongs to any of models referenced in this subtree
                 ----------------------------------------------------------------------------
                 l_index := l_ps_node_type_tbl.FIRST;
                 LOOP
                   IF l_index IS NULL THEN
                     EXIT;
                   END IF;
                   IF (l_ps_node_type_tbl(l_index) IN (263, 264)) THEN

                     FOR k IN (SELECT * FROM cz_model_ref_expls
                               START WITH model_id=l_model_id AND referring_node_id = l_index
                                      AND component_id = l_comp_tbl(l_index) AND ps_node_type = l_ps_node_type_tbl(l_index)
                                      AND deleted_flag = '0'
                               CONNECT BY PRIOR model_ref_expl_id = parent_expl_node_id
                                      AND deleted_flag = '0' AND PRIOR deleted_flag = '0')
                     LOOP

                        IF(k.component_id = l_rule_node_model_tbl(j) AND k.model_ref_expl_id = l_model_ref_expl_tbl(j)) THEN
                            l_node_found := TRUE;
                            EXIT;
                        END IF;
                     END LOOP;
                   END IF;
                   IF (l_node_found = TRUE) THEN
                     EXIT;
                   END IF;
                   l_index := l_ps_nodes_tbl.NEXT(l_index);
                 END LOOP;

              END IF; /* l_rule_node_model_tbl(j) = l_model_id) */

              IF (l_node_found = FALSE) THEN
                l_copy_rule := FALSE;
                EXIT;
              END IF;

            END LOOP; /* next node, for j */
         END IF; -- if l_rule_nodes.count > 0
            ---------------------------------------------------------------------
            -- copy the rule because all ps nodes  in this rule are in the subtree being copied
            ---------------------------------------------------------------------
            IF (l_copy_rule = TRUE AND (l_rule_type_tbl(i) = RULE_TYPE_JAVA_METHOD OR l_rule_nodes_tbl.COUNT > 0)) THEN

                copy_Rule(l_rule_id_tbl(i),
                          l_rule_folder_id_tbl(i),
                          FND_API.G_FALSE,
                          l_new_rule_id,
                          x_run_id,
                          l_return_status,
                          l_msg_count,
                          l_msg_data);

                ----------------------------------------------------------
                -- update node ids and expl ids of the newly created rules
                ----------------------------------------------------------

                IF (l_return_status = 'S' AND l_new_rule_id IS NOT NULL) THEN

                   IF (l_rule_type_tbl(i) IN (RULE_TYPE_EXPRESSION, RULE_TYPE_JAVA_METHOD)) THEN

                      --
                      -- update node ids
                      --

                        l_index := l_ps_nodes_tbl.FIRST;
                        LOOP
                          IF l_index IS NULL THEN
         	                  EXIT;
                          END IF;

                          UPDATE cz_expression_nodes
                          SET ps_node_id = l_ps_nodes_tbl(l_index)
                          WHERE ps_node_id =  l_index
                          AND rule_id = l_new_rule_id;

                          l_index := l_ps_nodes_tbl.NEXT(l_index);
                        END LOOP;

                      IF (l_rule_type_tbl(i) = RULE_TYPE_JAVA_METHOD) THEN

                         --
                         -- update relative_node_path
                         --

                         l_index := l_persistent_tbl.FIRST;
                         LOOP
                            IF l_index IS NULL THEN
   	                       EXIT;
                            END IF;
                            UPDATE cz_expression_nodes
                            SET relative_node_path = REPLACE(relative_node_path,TO_CHAR(l_index),TO_CHAR(l_persistent_tbl(l_index)))
                            WHERE rule_id = l_new_rule_id
                            AND relative_node_path IS NOT NULL;
                            l_index := l_persistent_tbl.NEXT(l_index);
                         END LOOP;

                         --
                         -- update component_id in cz_rules
                         --

                         l_index := l_ps_nodes_tbl.FIRST;
                         LOOP
                            IF l_index IS NULL THEN
   	                       EXIT;
                            END IF;
                            UPDATE cz_rules
                            SET component_id = l_ps_nodes_tbl(l_index)
                            WHERE rule_id = l_new_rule_id
                            AND component_id = l_index
                            AND deleted_flag = '0';
                            l_index := l_ps_nodes_tbl.NEXT(l_index);
                         END LOOP;

                      END IF;

                      --
                      -- update expl ids
                      --

                      IF l_virtual_flag='0' OR l_parent_id IS NULL THEN

        		    l_index := l_expl_nodes_tbl.FIRST;
        		    LOOP
        		      IF l_index IS NULL THEN
        			    EXIT;
        		      END IF;

        		      UPDATE cz_expression_nodes
        		      SET model_ref_expl_id = l_expl_nodes_tbl(l_index)
        		      WHERE model_ref_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

        		      l_index := l_expl_nodes_tbl.NEXT(l_index);
                            END LOOP;

                            IF (l_rule_type_tbl(i) = RULE_TYPE_JAVA_METHOD) THEN

                              --
                              -- update model_ref_expl_id in cz_rules
                              --

          		      l_index := l_expl_nodes_tbl.FIRST;
        		      LOOP
        		        IF l_index IS NULL THEN
        			      EXIT;
        		        END IF;

                                UPDATE cz_rules
                                SET model_ref_expl_id = l_expl_nodes_tbl(l_index)
                                WHERE model_ref_expl_id = l_index
                                AND rule_id = l_new_rule_id;

        		        l_index := l_expl_nodes_tbl.NEXT(l_index);
                              END LOOP;
                            END IF;

                      ELSE  -- root has no expls but the rest of subtree contains expls

        		    l_index := l_expl_nodes_all_tbl.FIRST;
        		    LOOP
        		      IF l_index IS NULL THEN
        			    EXIT;
        		      END IF;

        		      UPDATE cz_expression_nodes
        		      SET model_ref_expl_id = l_expl_nodes_all_tbl(l_index)
        		      WHERE model_ref_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

        		      l_index := l_expl_nodes_all_tbl.NEXT(l_index);
        		    END LOOP;

                             -- also update those nodes in subtree under the non-virtual root

                             UPDATE cz_expression_nodes
                             SET model_ref_expl_id = l_new_expl_id
                             WHERE rule_id=l_new_rule_id
                             AND model_ref_expl_id=l_expl_id;

                             IF (l_rule_type_tbl(i) = RULE_TYPE_JAVA_METHOD) THEN

                               --
                               -- update model_ref_expl_id in cz_rules
                               --

          		       l_index := l_expl_nodes_all_tbl.FIRST;
        		       LOOP
        		         IF l_index IS NULL THEN
        			      EXIT;
        		         END IF;

                                 UPDATE cz_rules
                                 SET model_ref_expl_id = l_expl_nodes_all_tbl(l_index)
                                 WHERE model_ref_expl_id = l_index
                                 AND rule_id = l_new_rule_id;

        		         l_index := l_expl_nodes_all_tbl.NEXT(l_index);
                               END LOOP;
                             END IF;

                      END IF;  -- vf

                   ELSIF l_rule_type_tbl(i) IN (RULE_TYPE_DESIGNCHART, RULE_TYPE_COMPAT_TABLE) THEN

                    --
                    -- update node ids
                    --

                      l_index := l_ps_nodes_tbl.FIRST;
                      LOOP
                        IF l_index IS NULL THEN
       	                  EXIT;
                        END IF;

                              --des chart cells primary_opt_id
        		      UPDATE cz_des_chart_cells
        		      SET primary_opt_id = l_ps_nodes_tbl(l_index)
        		      WHERE primary_opt_id =  l_index
        		      AND rule_id = l_new_rule_id;

                              -- des chart cells secondary_opt_id
        		      UPDATE cz_des_chart_cells
        		      SET secondary_opt_id = l_ps_nodes_tbl(l_index)
        		      WHERE secondary_opt_id =  l_index
        		      AND rule_id = l_new_rule_id;

                              -- des chart cells secondary_feature_id
        		      UPDATE cz_des_chart_cells
        		      SET secondary_feature_id = l_ps_nodes_tbl(l_index)
        		      WHERE secondary_feature_id =  l_index
        		      AND rule_id = l_new_rule_id;

                              -- des chart features feature_id
        		      UPDATE cz_des_chart_features
        		      SET feature_id = l_ps_nodes_tbl(l_index)
        		      WHERE feature_id =  l_index
        		      AND rule_id = l_new_rule_id;

                        l_index := l_ps_nodes_tbl.NEXT(l_index);
                      END LOOP; -- updated node ids

                    --
                    -- update expl ids
                    --

                        IF l_virtual_flag='0' OR l_parent_id IS NULL THEN
        		    l_index := l_expl_nodes_tbl.FIRST;
        		    LOOP
        		      IF l_index IS NULL THEN
        			    EXIT;
        		      END IF;

                              -- des_chart_cells secondary_feature_expl_id
        		      UPDATE cz_des_chart_cells
        		      SET secondary_feat_expl_id = l_expl_nodes_tbl(l_index)
        		      WHERE secondary_feat_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

                              -- des_chart_features model_ref_expl_id
        		      UPDATE cz_des_chart_features
        		      SET model_ref_expl_id = l_expl_nodes_tbl(l_index)
        		      WHERE model_ref_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

        		      l_index := l_expl_nodes_tbl.NEXT(l_index);
        		    END LOOP;

                        ELSE  -- root has no expls but the rest of subtree contains expls

        		    l_index := l_expl_nodes_all_tbl.FIRST;
        		    LOOP
        		      IF l_index IS NULL THEN
        			    EXIT;
        		      END IF;

                              -- des_chart_cells secondary_feature_expl_id
        		      UPDATE cz_des_chart_cells
        		      SET secondary_feat_expl_id = l_expl_nodes_all_tbl(l_index)
        		      WHERE secondary_feat_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

                              -- des_chart_features model_ref_expl_id
        		      UPDATE cz_des_chart_features
        		      SET model_ref_expl_id = l_expl_nodes_all_tbl(l_index)
        		      WHERE model_ref_expl_id =  l_index
        		      AND rule_id = l_new_rule_id;

        		      l_index := l_expl_nodes_all_tbl.NEXT(l_index);
        		    END LOOP;

                             -- also update those nodes in subtree under the non-virtual root

                              -- des_chart_cells secondary_feature_expl_id
        		      UPDATE cz_des_chart_cells
        		      SET secondary_feat_expl_id = l_new_expl_id
        		      WHERE secondary_feat_expl_id =  l_expl_id
        		      AND rule_id = l_new_rule_id;

                              -- des_chart_features model_ref_expl_id
        		      UPDATE cz_des_chart_features
        		      SET model_ref_expl_id = l_new_expl_id
        		      WHERE model_ref_expl_id =  l_expl_id
        		      AND rule_id = l_new_rule_id;

                        END IF;  -- vf
                   END IF;  -- rule type

                END IF; -- (l_return_status = 'S')
            END IF; -- (l_copy_rule = TRUE)

      END LOOP; -- FOR i IN l_rule_id_tbl.FIRST

    END IF; -- l_rule_id_tbl.COUNT > 0
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END; -- begin
  END IF; -- if p_copy_mode = '2'


EXCEPTION
  WHEN NO_TXT_FOUND_EXCP THEN
    handle_Error(p_message_name   => 'CZ_COPY_PSSUBTREE_NO_TXT',
                 p_token_name1    => 'TEXTID',
                 p_token_value1   => TO_CHAR(l_text_id),
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data);
    x_run_id := GetRunID;
    LOG_REPORT(x_run_id,x_msg_data);
  WHEN OTHERS THEN
    handle_Error(p_procedure_name => 'copy_PS_Subtree',
                 p_error_message  => SQLERRM,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data);

    x_run_id := GetRunID;
    LOG_REPORT(x_run_id,x_msg_data);
END copy_PS_Subtree;

--
-- copy single Rule
-- Parameters :
--   p_rule_id              - identifies rule to copy
--   p_rule_folder_id       - identifies rule folder in which rule will be copied
--   x_out_new_rule_id      - OUT variable - id of new rule
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 p_init_msg_list            IN   VARCHAR2,
 p_ui_def_id                IN   NUMBER,
 p_ui_page_id               IN   NUMBER,
 p_ui_page_element_id       IN   VARCHAR2,
 x_out_new_rule_id          OUT  NOCOPY NUMBER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2) IS

    l_model_id               NUMBER;
    l_rule_folder_id         NUMBER;
    l_new_rule_id            NUMBER;
    l_new_reason_id          NUMBER;
    l_new_unsatisfied_msg_id NUMBER;
    l_new_seq_nbr            NUMBER;
    l_filter_set_id          NUMBER;
    l_new_filter_set_id      NUMBER;
    l_new_populator_id       NUMBER;
    l_new_expr_id            NUMBER;
    l_new_tree_seq           NUMBER;
    l_new_rfl_id             NUMBER;
    l_rule_type              NUMBER;
    l_reference_ps_node_id   NUMBER;
    l_persistent_node_id     NUMBER;
    l_seeded_flag            cz_rules.seeded_flag%TYPE;

    l_new_exprnode_tbl         t_int_array_tbl_type_idx_vc2;--t_num_array_tbl_type;
    l_new_parent_exprnode_tbl  t_int_array_tbl_type_idx_vc2;--t_num_array_tbl_type;
    l_exprnode_tbl             t_int_array_tbl_type_idx_vc2;--t_num_array_tbl_type; Not used anywhere.
    l_parent_exprnode_tbl      t_int_array_tbl_type_idx_vc2;--t_num_array_tbl_type;
    l_key                      NUMBER;
    l_new_parent               NUMBER;
    l_object_type              cz_rule_folders.object_type%type;
    l_effective_from           DATE;
    l_effective_until          DATE;
    l_effective_set_id         NUMBER;
    l_devl_project_id          NUMBER;

    SEEDED_FLAG_EXCP           EXCEPTION;
    INVALID_FOLDER_ID_EXCP     EXCEPTION;
    PAGEBASE_NOT_FOUND_EXCP    EXCEPTION;
    l_text_id                  NUMBER;
    l_component_id             NUMBER;
    l_model_ref_expl_id        NUMBER;
    l_class_seq                NUMBER;

BEGIN
    IF p_init_msg_list = FND_API.G_TRUE THEN
       FND_MSG_PUB.initialize;
    END IF;
    x_run_id := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT devl_project_id,rule_folder_id, rule_type, seeded_flag
    INTO   l_model_id,l_rule_folder_id, l_rule_type, l_seeded_flag
    FROM CZ_RULES
    WHERE rule_id=p_rule_id AND deleted_flag='0';

    IF (l_seeded_flag = '1' AND l_rule_type NOT IN (RULE_TYPE_DISPLAY_CONDITION, RULE_TYPE_ENABLED_CONDITION,
                                                    RULE_TYPE_CAPTION, RULE_TYPE_JAVA_SYS_PROP)) THEN
         RAISE SEEDED_FLAG_EXCP;
    END IF;

/* need to investigate this, sselahi*/

if l_rule_type = RULE_TYPE_POPULATOR then
    BEGIN
        SELECT filter_set_id INTO l_filter_set_id
        FROM CZ_FILTER_SETS
        WHERE rule_id=p_rule_id AND rownum<2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
    END;
end if;

    IF p_rule_folder_id IS NOT NULL THEN
      IF (l_rule_type NOT IN (RULE_TYPE_DISPLAY_CONDITION, RULE_TYPE_ENABLED_CONDITION,
                              RULE_TYPE_CAPTION, RULE_TYPE_JAVA_SYS_PROP)) THEN
        BEGIN
          SELECT object_type INTO l_object_type
          FROM CZ_RULE_FOLDERS
          WHERE rule_folder_id=p_rule_folder_id
          AND object_type IN ('RFL','RSQ')
          AND deleted_flag='0';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE INVALID_FOLDER_ID_EXCP;
        END;
      ELSIF (l_rule_type IN (RULE_TYPE_DISPLAY_CONDITION, RULE_TYPE_ENABLED_CONDITION,
                             RULE_TYPE_CAPTION, RULE_TYPE_JAVA_SYS_PROP)
             AND p_rule_folder_id <> 0) THEN
           RAISE INVALID_FOLDER_ID_EXCP;
      END IF;
    END IF;

    l_new_rule_id := allocateId('CZ_RULES_S');
    x_out_new_rule_id := l_new_rule_id;

    FOR i IN (SELECT * FROM CZ_RULES
             WHERE rule_id=p_rule_id AND deleted_flag='0')
    LOOP
       IF i.reason_id IS NOT NULL THEN
         l_text_id := i.reason_id;
         l_new_reason_id := copy_INTL_TEXT(i.reason_id);
         IF l_new_reason_id = -1 THEN
            RAISE NO_TXT_FOUND_EXCP;
         END IF;
       ELSE
         l_new_reason_id := NULL;
       END IF;

       IF i.unsatisfied_msg_id IS NOT NULL THEN
         l_text_id := i.unsatisfied_msg_id;
         l_new_unsatisfied_msg_id := copy_INTL_TEXT(i.unsatisfied_msg_id);
         IF l_new_unsatisfied_msg_id = -1 THEN
            RAISE NO_TXT_FOUND_EXCP;
         END IF;
       ELSE
         l_new_unsatisfied_msg_id := NULL;
       END IF;

       IF (i.reason_type IN (0,1) ) THEN
       BEGIN
         UPDATE cz_localized_texts
         SET localized_str=REPLACE(localized_str, i.NAME, i.NAME||'-'||TO_CHAR(l_new_rule_id))
         WHERE intl_text_id = l_new_reason_id;
       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;
       END IF;

       IF (i.unsatisfied_msg_source IN (0,1)) THEN
       BEGIN
         UPDATE cz_localized_texts
         SET localized_str=REPLACE(localized_str, i.NAME, i.NAME||'-'||TO_CHAR(l_new_rule_id))
         WHERE intl_text_id = l_new_unsatisfied_msg_id;
       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;
	 END IF;

       IF p_rule_folder_id IS NOT NULL AND p_rule_folder_id<>-1 THEN
          l_new_rfl_id := p_rule_folder_id;
       ELSE
          l_new_rfl_id := i.RULE_FOLDER_ID;
       END IF;

       SELECT NVL(MAX(seq_nbr),0)+1
       INTO l_new_seq_nbr
       FROM CZ_RULES
       WHERE rule_folder_id=l_new_rfl_id AND deleted_flag='0';

       IF l_object_type='RSQ' THEN
         IF i.EFFECTIVITY_SET_ID IS NULL OR i.EFFECTIVITY_SET_ID=-1 THEN
           l_effective_set_id := NULL;
           l_effective_from   := CZ_UTILS.EPOCH_END_;
           l_effective_until  := CZ_UTILS.EPOCH_BEGIN_;
         ELSE
           SELECT effective_from,effective_until
             INTO l_effective_from,l_effective_until
             FROM CZ_EFFECTIVITY_SETS
            WHERE effectivity_set_id = i.EFFECTIVITY_SET_ID;

           IF l_effective_from  = CZ_UTILS.EPOCH_END_ AND
              l_effective_until = CZ_UTILS.EPOCH_BEGIN_ THEN
              l_effective_set_id := i.EFFECTIVITY_SET_ID;
              l_effective_from   := i.EFFECTIVE_FROM;
              l_effective_until  := i.EFFECTIVE_UNTIL;
           ELSE
              l_effective_set_id := NULL;
              l_effective_from   := CZ_UTILS.EPOCH_END_;
              l_effective_until  := CZ_UTILS.EPOCH_BEGIN_;
           END IF;

         END IF;
       ELSE
         l_effective_from   := i.EFFECTIVE_FROM;
         l_effective_until  := i.EFFECTIVE_UNTIL;
         l_effective_set_id := i.EFFECTIVITY_SET_ID;
       END IF;

       IF (i.rule_type IN (RULE_TYPE_DISPLAY_CONDITION,
                           RULE_TYPE_ENABLED_CONDITION,
                           RULE_TYPE_CAPTION) AND (p_ui_def_id IS NOT NULL AND p_ui_def_id<>0) AND p_ui_page_id IS NOT NULL) THEN
          BEGIN
            SELECT devl_project_id INTO l_devl_project_id FROM CZ_UI_DEFS
             WHERE ui_def_id=p_ui_def_id AND deleted_flag='0';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE PAGEBASE_NOT_FOUND_EXCP;
          END;
          BEGIN

             --
             -- here we are getting persistent_node_id of base page
             --
             SELECT persistent_node_id,pagebase_expl_node_id
             INTO l_persistent_node_id, l_model_ref_expl_id
             FROM cz_ui_pages
             WHERE page_id=p_ui_page_id
             AND ui_def_id=p_ui_def_id;

             --
             -- here there is a block for converting persistent_node_id of base page
             -- to its ps_node_id based on l_model_ref_expl_id of base page
             -- ( using l_model_ref_expl_id of base page we can find devl_project_id
             -- of model which has a ps node of base page
             --
             BEGIN
               --
               -- first - try to get ps_node_id from the current mode,
               -- because in most cases ps node is under the current model
               --
               SELECT ps_node_id INTO l_component_id FROM CZ_PS_NODES
                WHERE devl_project_id=l_devl_project_id AND
                      persistent_node_id=l_persistent_node_id  AND
                      deleted_flag='0';
             EXCEPTION
               --
               -- if ps node is not under the current model
               -- then try to find it by using l_model_ref_expl_id if page base
               --
               WHEN NO_DATA_FOUND THEN -- node is under some referenced model
                 -- find ps_node_id of nearest reference above
                 FOR p IN (SELECT referring_node_id
                             FROM cz_model_ref_expls
                           START WITH model_ref_expl_id=l_model_ref_expl_id
                           CONNECT by PRIOR parent_expl_node_id=model_ref_expl_id AND
                                      deleted_flag='0' AND PRIOR deleted_flag='0' AND
                                      PRIOR referring_node_id IS NULL)
                 LOOP
                   l_reference_ps_node_id := p.referring_node_id;
                 END LOOP;

                 -- we need to use l_model_ref_expl_id in this case
                 SELECT ps_node_id INTO l_component_id FROM CZ_PS_NODES
                 WHERE devl_project_id=
                       (
                        SELECT devl_project_id FROM CZ_PS_NODES
                        WHERE ps_node_id=l_reference_ps_node_id
                       ) AND
                       persistent_node_id=l_persistent_node_id  AND
                       deleted_flag='0';
             END;

           EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE PAGEBASE_NOT_FOUND_EXCP;
           END;
       ELSE
         l_component_id := i.component_id;
         l_model_ref_expl_id := i.model_ref_expl_id;
         l_devl_project_id := i.devl_project_id;
       END IF;

       l_class_seq := i.class_seq;
       IF i.rule_class IS NOT NULL AND i.rule_class IN (RULE_CLASS_DEFAULT, RULE_CLASS_SEARCH_DECISION) THEN
         SELECT max(nvl(class_seq,0))+1 INTO l_class_seq
         FROM cz_rules
         WHERE deleted_flag = '0' AND devl_project_id = l_devl_project_id
         AND rule_class = i.rule_class;
       END IF;

       INSERT INTO CZ_RULES(
              RULE_ID,
              SUB_CONS_ID,
              REASON_ID,
              AMOUNT_ID,
              GRID_ID,
              RULE_FOLDER_ID,
              DEVL_PROJECT_ID,
              INVALID_FLAG,
              DESC_TEXT,
              NAME,
              ANTECEDENT_ID,
              CONSEQUENT_ID,
              RULE_TYPE,
              EXPR_RULE_TYPE,
              COMPONENT_ID,
              REASON_TYPE,
              DISABLED_FLAG,
              ORIG_SYS_REF,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER,
              EFFECTIVITY_SET_ID,
              EFFECTIVE_FROM,
              EFFECTIVE_UNTIL,
              EFFECTIVE_USAGE_MASK,
              SEQ_NBR,
              RULE_FOLDER_TYPE,
              UNSATISFIED_MSG_ID,
              UNSATISFIED_MSG_SOURCE,
              SIGNATURE_ID,
              TEMPLATE_PRIMITIVE_FLAG,
              PRESENTATION_FLAG,
              TEMPLATE_TOKEN,
              RULE_TEXT,
              NOTES,
              CLASS_NAME,
              INSTANTIATION_SCOPE,
              MODEL_REF_EXPL_ID,
              MUTABLE_FLAG,
              SEEDED_FLAG,
              UI_DEF_ID,
              UI_PAGE_ID,
              UI_PAGE_ELEMENT_ID,
              RULE_CLASS,
              CLASS_SEQ,
              CONFIG_ENGINE_TYPE,
              ACCUMULATOR_FLAG)
        VALUES(
                                   l_new_rule_id,
              i.SUB_CONS_ID,
                                   l_new_reason_id,
              i.AMOUNT_ID,
              i.GRID_ID,
                                   l_new_rfl_id,
                                   l_devl_project_id,
              i.INVALID_FLAG,
              i.DESC_TEXT,
                                   i.NAME||'-'||TO_CHAR(l_new_rule_id),
              i.ANTECEDENT_ID,
              i.CONSEQUENT_ID,
              i.RULE_TYPE,
              i.EXPR_RULE_TYPE,
                                   l_component_id,
              i.REASON_TYPE,
              i.DISABLED_FLAG,
              NULL,
              i.DELETED_FLAG,
              i.SECURITY_MASK,
              i.CHECKOUT_USER,
                                    l_effective_set_id,
                                    l_effective_from,
                                    l_effective_until,
              i.EFFECTIVE_USAGE_MASK,
                                    l_new_seq_nbr,
              i.RULE_FOLDER_TYPE,
                                    l_new_unsatisfied_msg_id,
              i.UNSATISFIED_MSG_SOURCE,
              i.SIGNATURE_ID,
              i.TEMPLATE_PRIMITIVE_FLAG,
              i.PRESENTATION_FLAG,
              i.TEMPLATE_TOKEN,
              i.RULE_TEXT,
              i.NOTES,
              i.CLASS_NAME,
              i.INSTANTIATION_SCOPE,
                                    l_model_ref_expl_id,
              i.MUTABLE_FLAG,
                                    '0',
              DECODE(p_ui_def_id,NULL,i.ui_def_id,p_ui_def_id),
              DECODE(p_ui_page_id,NULL,i.ui_page_id,p_ui_page_id),
              DECODE(p_ui_page_element_id,NULL,i.ui_page_element_id,p_ui_page_element_id),
              i.RULE_CLASS,
              l_class_seq,
              i.CONFIG_ENGINE_TYPE,
              i.ACCUMULATOR_FLAG
              );

	   SELECT NVL(MAX(tree_seq),0)+1
	   INTO l_new_tree_seq
	   FROM CZ_RULE_FOLDERS
	   WHERE parent_rule_folder_id=l_new_rfl_id
           AND deleted_flag='0';

        INSERT INTO CZ_RULE_FOLDERS
           (RULE_FOLDER_ID,
            FOLDER_TYPE,
            NAME,
            DESC_TEXT,
            PARENT_RULE_FOLDER_ID,
            TREE_SEQ,
            DEVL_PROJECT_ID,
            PERSISTENT_RULE_FOLDER_ID,
            EFFECTIVE_USAGE_MASK,
            EFFECTIVE_FROM,
            EFFECTIVE_UNTIL,
            EFFECTIVITY_SET_ID,
            DELETED_FLAG,
            SECURITY_MASK,
            CHECKOUT_USER,
            OBJECT_TYPE,
            DISABLED_FLAG,
            ORIG_SYS_REF)
       SELECT
                        l_new_rule_id,
            FOLDER_TYPE,
            NAME||'-'||TO_CHAR(l_new_rule_id),
            DESC_TEXT,
                        l_new_rfl_id,
                        l_new_tree_seq,
            DEVL_PROJECT_ID,
                        l_new_rule_id,
            EFFECTIVE_USAGE_MASK,
            EFFECTIVE_FROM,
            EFFECTIVE_UNTIL,
            EFFECTIVITY_SET_ID,
            DELETED_FLAG,
            SECURITY_MASK,
            CHECKOUT_USER,
            OBJECT_TYPE,
            DISABLED_FLAG,
            ORIG_SYS_REF
       FROM CZ_RULE_FOLDERS
       WHERE rule_folder_id=p_rule_id AND parent_rule_folder_id = l_rule_folder_id AND deleted_flag='0';

    END LOOP;

    INSERT INTO CZ_DES_CHART_CELLS
      (RULE_ID,
       PRIMARY_OPT_ID,
       SECONDARY_OPT_ID,
       MARK_CHAR,
       SECONDARY_FEAT_EXPL_ID,
       SECONDARY_FEATURE_ID,
       DELETED_FLAG,
       SECURITY_MASK ,
       CHECKOUT_USER )
    SELECT
                         l_new_rule_id,
       PRIMARY_OPT_ID,
       SECONDARY_OPT_ID,
       MARK_CHAR,
       SECONDARY_FEAT_EXPL_ID,
       SECONDARY_FEATURE_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER
    FROM CZ_DES_CHART_CELLS
    WHERE rule_id=p_rule_id AND deleted_flag='0';

    INSERT INTO CZ_DES_CHART_FEATURES
      (RULE_ID,
       FEATURE_ID,
       FEATURE_TYPE ,
       MODEL_REF_EXPL_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER )
     SELECT
                      l_new_rule_id,
       FEATURE_ID,
       FEATURE_TYPE ,
       MODEL_REF_EXPL_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER
     FROM CZ_DES_CHART_FEATURES
     WHERE rule_id=p_rule_id AND deleted_flag='0';

/* need to investigate this, sselahi */
if l_rule_type = RULE_TYPE_POPULATOR then
    l_new_filter_set_id := allocateId('CZ_FILTER_SETS_S');

    INSERT INTO CZ_FILTER_SETS
    (
     FILTER_SET_ID
     ,DEVL_PROJECT_ID
     ,RULE_ID
     ,EXPRESS_ID
     ,SOURCE_TYPE
     ,DELETED_FLAG
     ,EFF_FROM
     ,EFF_TO
     ,SECURITY_MASK
     ,EFF_MASK
     ,CHECKOUT_USER
     ,SOURCE_SYNTAX
     ,SOURCE_VIEW_OWNER
     ,SOURCE_VIEW_NAME
    )
    SELECT
                    l_new_filter_set_id
     ,DEVL_PROJECT_ID
                    ,l_new_rule_id
     ,EXPRESS_ID
     ,SOURCE_TYPE
     ,DELETED_FLAG
     ,EFF_FROM
     ,EFF_TO
     ,SECURITY_MASK
     ,EFF_MASK
     ,CHECKOUT_USER
     ,SOURCE_SYNTAX
     ,SOURCE_VIEW_OWNER
     ,SOURCE_VIEW_NAME
    FROM  CZ_FILTER_SETS
    WHERE rule_id = p_rule_id AND deleted_flag='0';

    l_new_populator_id := allocateId('CZ_POPULATORS_S');

    INSERT INTO CZ_POPULATORS
    (
     POPULATOR_ID
     ,OWNED_BY_NODE_ID
     ,FILTER_SET_ID
     ,RESULT_TYPE
     ,DELETED_FLAG
     ,EFF_FROM
     ,EFF_TO
     ,SECURITY_MASK
     ,EFF_MASK
     ,CHECKOUT_USER
     ,PERSISTENT_POPULATOR_ID
     ,DESCRIPTION
     ,NAME
     ,HAS_LEVEL
     ,HAS_DESCRIPTION
     ,HAS_PROPERTY
     ,HAS_ITEM_TYPE
     ,HAS_ITEM
     ,VIEW_NAME
     ,FEATURE_TYPE
     ,QUERY_SYNTAX
     ,XFR_GROUP
     ,SEEDED_FLAG
    )
    SELECT
                       l_new_populator_id
     ,OWNED_BY_NODE_ID
                       ,l_new_filter_set_id
     ,RESULT_TYPE
     ,DELETED_FLAG
     ,EFF_FROM
     ,EFF_TO
     ,SECURITY_MASK
     ,EFF_MASK
     ,CHECKOUT_USER
                       ,l_new_populator_id
     ,DESCRIPTION
     ,NAME
     ,HAS_LEVEL
     ,HAS_DESCRIPTION
     ,HAS_PROPERTY
     ,HAS_ITEM_TYPE
     ,HAS_ITEM
     ,VIEW_NAME
     ,FEATURE_TYPE
     ,QUERY_SYNTAX
     ,XFR_GROUP
     ,SEEDED_FLAG
    FROM CZ_POPULATORS
    WHERE filter_set_id=l_filter_set_id AND deleted_flag='0';
end if;

  l_new_exprnode_tbl.delete;
  l_parent_exprnode_tbl.delete;
  l_new_parent_exprnode_tbl.delete;

  FOR i IN (
    SELECT expr_node_id, expr_parent_id
    FROM CZ_EXPRESSION_NODES
    WHERE rule_id=p_rule_id AND deleted_flag='0') LOOP
      l_new_exprnode_tbl(i.expr_node_id) := allocateId('CZ_EXPRESSION_NODES_S');
      l_parent_exprnode_tbl(i.expr_node_id) := i.expr_parent_id;
  END LOOP;

  l_key := l_new_exprnode_tbl.FIRST;
  LOOP
      IF l_key IS NULL THEN
        EXIT;
      END IF;
      IF (l_parent_exprnode_tbl(l_key) IS NOT NULL) THEN
        l_new_parent := l_new_exprnode_tbl(l_parent_exprnode_tbl(l_key));
      ELSE
        l_new_parent := NULL;
      END IF;

      INSERT INTO CZ_EXPRESSION_NODES
      (
       EXPR_NODE_ID
       ,EXPRESS_ID
       ,SEQ_NBR
       ,ITEM_TYPE_ID
       ,PS_NODE_ID
       ,ITEM_ID
       ,FILTER_SET_ID
       ,GRID_COL_ID
       ,EXPR_PARENT_ID
       ,PROPERTY_ID
       ,COMPILE_ADVICE
       ,COL
       ,DATA_VALUE
       ,FIELD_NAME
       ,EXPR_TYPE
       ,EXPR_SUBTYPE
       ,TOKEN_LIST_SEQ
       ,DELETED_FLAG
       ,EFF_FROM
       ,EFF_TO
       ,SECURITY_MASK
       ,EFF_MASK
       ,CHECKOUT_USER
       ,CONSEQUENT_FLAG
       ,MODEL_REF_EXPL_ID
       ,RULE_ID
       ,TEMPLATE_ID
       ,ARGUMENT_SIGNATURE_ID
       ,ARGUMENT_INDEX
       ,PARAM_SIGNATURE_ID
       ,PARAM_INDEX
       ,DATA_TYPE
       ,COLLECTION_FLAG
       ,DISPLAY_NODE_DEPTH
       ,ARGUMENT_NAME
       ,SOURCE_OFFSET
       ,SOURCE_LENGTH
       ,MUTABLE_FLAG
       ,RELATIVE_NODE_PATH
       ,EVENT_EXECUTION_SCOPE
       ,DATA_NUM_VALUE
       ,SEEDED_FLAG
       )
      SELECT
           l_new_exprnode_tbl(l_key)
       ,EXPRESS_ID
       ,SEQ_NBR
       ,ITEM_TYPE_ID
       ,PS_NODE_ID
       ,ITEM_ID
           ,decode(l_rule_type, RULE_TYPE_POPULATOR,l_new_filter_set_id, FILTER_SET_ID)
       ,GRID_COL_ID
           ,l_new_parent
       ,PROPERTY_ID
       ,COMPILE_ADVICE
       ,COL
       ,DATA_VALUE
       ,FIELD_NAME
       ,EXPR_TYPE
       ,EXPR_SUBTYPE
       ,TOKEN_LIST_SEQ
       ,DELETED_FLAG
       ,EFF_FROM
       ,EFF_TO
       ,SECURITY_MASK
       ,EFF_MASK
       ,CHECKOUT_USER
       ,CONSEQUENT_FLAG
       ,MODEL_REF_EXPL_ID
            ,l_new_rule_id
       ,TEMPLATE_ID
       ,ARGUMENT_SIGNATURE_ID
       ,ARGUMENT_INDEX
       ,PARAM_SIGNATURE_ID
       ,PARAM_INDEX
       ,DATA_TYPE
       ,COLLECTION_FLAG
       ,DISPLAY_NODE_DEPTH
       ,ARGUMENT_NAME
       ,SOURCE_OFFSET
       ,SOURCE_LENGTH
       ,MUTABLE_FLAG
       ,RELATIVE_NODE_PATH
       ,EVENT_EXECUTION_SCOPE
       ,DATA_NUM_VALUE
       ,SEEDED_FLAG
      FROM CZ_EXPRESSION_NODES
      WHERE expr_node_id=l_key;
      l_key := l_new_exprnode_tbl.NEXT(l_key);
  END LOOP;

EXCEPTION
  WHEN NO_TXT_FOUND_EXCP THEN
     handle_Error(p_message_name   => 'CZ_COPY_RULE_NO_TXT',
                  p_token_name1    => 'TEXTID',
                  p_token_value1   => TO_CHAR(l_text_id),
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
     x_run_id := GetRunID;
     LOG_REPORT(x_run_id,x_msg_data);
   WHEN SEEDED_FLAG_EXCP THEN
          handle_Error(p_message_name   => 'CZ_COPY_RULE_SEEDED_DATA',
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
     x_run_id := GetRunID;
     LOG_REPORT(x_run_id,x_msg_data);
   WHEN INVALID_FOLDER_ID_EXCP THEN
          handle_Error(p_message_name   => 'CZ_COPY_RULE_INV_FOLDERID',
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
     x_run_id := GetRunID;
     LOG_REPORT(x_run_id,x_msg_data);
   WHEN PAGEBASE_NOT_FOUND_EXCP THEN
          handle_Error(p_message_name   => 'CZ_COPY_RULE_PAGEBASE',
                  p_token_name1    => 'UIPAGEID',
                  p_token_value1   => TO_CHAR(p_ui_page_id),
                  p_token_name2    => 'UIDEFID',
                  p_token_value2   => TO_CHAR(p_ui_def_id),
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
     x_run_id := GetRunID;
     LOG_REPORT(x_run_id,x_msg_data);
   WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'copy_Rule',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

     x_run_id := GetRunID;
     LOG_REPORT(x_run_id,x_msg_data);

END copy_Rule;

PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 x_out_new_rule_id          OUT  NOCOPY INTEGER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2) IS
BEGIN

          copy_Rule(p_rule_id           => p_rule_id,
                    p_rule_folder_id    => p_rule_folder_id,
                    p_init_msg_list     => FND_API.G_TRUE,
                    x_out_new_rule_id   => x_out_new_rule_id,
                    x_run_id            => x_run_id,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data);
END copy_rule;


PROCEDURE copy_Rule
(p_rule_id                  IN   NUMBER,
 p_rule_folder_id           IN   NUMBER DEFAULT NULL,
 p_init_msg_list            IN   VARCHAR2,
 x_out_new_rule_id          OUT  NOCOPY INTEGER,
 x_run_id                   OUT  NOCOPY NUMBER,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2) IS

BEGIN
          copy_Rule(p_rule_id            => p_rule_id,
                    p_rule_folder_id     => p_rule_folder_id,
                    p_init_msg_list      => p_init_msg_list,
                    p_ui_def_id          => NULL,
                    p_ui_page_id         => NULL,
                    p_ui_page_element_id => NULL,
                    x_out_new_rule_id    => x_out_new_rule_id,
                    x_run_id             => x_run_id,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

END copy_rule;

--
-- copy Rule Folder
-- Parameters :
--   p_rule_folder_id       - identifies rule folder to copy
--   p_new_parent_folder_id - identifies new parent rule folder
--   p_init_msg_list        - indicates if initializing message stack
--   x_out_new_rule_id      - OUR parameter - id of new copied rule folder
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Rule_Folder
(p_rule_folder_id           IN   NUMBER,
 p_new_parent_folder_id     IN   NUMBER,
 p_init_msg_list            IN   VARCHAR2,
 x_out_rule_folder_id       OUT  NOCOPY   INTEGER,
 x_run_id                   OUT  NOCOPY   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2) IS

    l_rule_id              NUMBER;
    l_rule_folder_id       NUMBER;
    l_locked_entities_tbl  cz_security_pvt.number_type_tbl;
    l_has_priveleges       VARCHAR2(255);
    l_msg_data             VARCHAR2(32000);
    l_lock_status          VARCHAR2(255);
    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;

BEGIN
    IF p_init_msg_list = FND_API.G_TRUE THEN
       FND_MSG_PUB.initialize;
    END IF;

    x_run_id := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- check global flag that equals '1' if model is already locked
    -- by calling sequirity package
    --
    IF gDB_SETTING_USE_SECURITY THEN

       cz_security_pvt.has_privileges (p_model_id      => p_new_parent_folder_id,
                                       p_function_name => cz_security_pvt.LOCK_RULEFOLDER_FUNC,
                                       x_return_status => l_return_status,
                                       x_msg_data      => l_msg_data,
                                       x_msg_count     => l_msg_count);

       IF (l_return_status IN(cz_security_pvt.UNEXPECTED_ERROR,cz_security_pvt.HAS_NO_PRIVILEGE)) THEN
  	    x_run_id := GetRunID;
  	    LOG_REPORT(x_run_id,l_msg_count);
          RETURN;
       END IF;

       l_locked_entities_tbl.DELETE;

 	 cz_security_pvt.lock_entity(p_rule_folder_id,
                                   cz_security_pvt.LOCK_RULEFOLDER_FUNC,
	   	       	           l_locked_entities_tbl,
					     l_lock_status,
					     l_msg_count,
					     l_msg_data);

      IF l_lock_status <> 'S' THEN
         x_run_id := GetRunID;
         LOG_REPORT(x_run_id,l_msg_count);
         RETURN;
      END IF;

    END IF;

    BEGIN
        SELECT CZ_RULE_FOLDERS_S.NEXTVAL INTO x_out_rule_folder_id FROM dual;
        INSERT INTO CZ_RULE_FOLDERS
           (RULE_FOLDER_ID,
            FOLDER_TYPE,
            NAME,
            DESC_TEXT,
            PARENT_RULE_FOLDER_ID,
            TREE_SEQ,
            DEVL_PROJECT_ID,
            PERSISTENT_RULE_FOLDER_ID,
            EFFECTIVE_USAGE_MASK,
            EFFECTIVE_FROM,
            EFFECTIVE_UNTIL,
            EFFECTIVITY_SET_ID,
            DELETED_FLAG,
            SECURITY_MASK,
            CHECKOUT_USER,
            OBJECT_TYPE,
            DISABLED_FLAG,
            ORIG_SYS_REF)
       SELECT
                          x_out_rule_folder_id,
            FOLDER_TYPE,
            NAME||'-'||TO_CHAR(x_out_rule_folder_id),
            DESC_TEXT,
                        p_new_parent_folder_id,
            TREE_SEQ,
            DEVL_PROJECT_ID,
                        x_out_rule_folder_id,
            EFFECTIVE_USAGE_MASK,
            EFFECTIVE_FROM,
            EFFECTIVE_UNTIL,
            EFFECTIVITY_SET_ID,
            DELETED_FLAG,
            SECURITY_MASK,
            CHECKOUT_USER,
            OBJECT_TYPE,
            DISABLED_FLAG,
            ORIG_SYS_REF
       FROM CZ_RULE_FOLDERS
       WHERE rule_folder_id=p_rule_folder_id AND object_type IN ('RFL', 'RSQ') AND deleted_flag='0';

       FOR i IN (SELECT rule_folder_id, object_type FROM CZ_RULE_FOLDERS
                 WHERE parent_rule_folder_id=p_rule_folder_id AND deleted_flag='0')
       LOOP
         IF i.object_type IN ('RFL', 'RSQ') THEN
           copy_rule_folder(p_rule_folder_id       => i.rule_folder_id
                           ,p_new_parent_folder_id => x_out_rule_folder_id
                           ,p_init_msg_list        => FND_API.G_FALSE
                           ,x_out_rule_folder_id   => l_rule_folder_id
                           ,x_run_id               => x_run_id
                           ,x_return_status        => x_return_status
                           ,x_msg_count            => x_msg_count
                           ,x_msg_data             => x_msg_data);
         ELSE
           copy_Rule(p_rule_id           => i.rule_folder_id,
                     p_rule_folder_id    => x_out_rule_folder_id,
                     p_init_msg_list     => FND_API.G_FALSE,
                     x_out_new_rule_id   => l_rule_id,
                     x_run_id            => x_run_id,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data);
         END IF;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
         END IF;
       END LOOP;

    EXCEPTION
       WHEN OTHERS THEN
         handle_Error(p_procedure_name => 'copy_Rule_Folder',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);

         x_run_id := GetRunID;
         LOG_REPORT(x_run_id,x_msg_data);
    END;

    IF l_locked_entities_tbl.COUNT>0 AND gDB_SETTING_USE_SECURITY THEN
 	 cz_security_pvt.unlock_entity(p_rule_folder_id,
                                     cz_security_pvt.LOCK_RULEFOLDER_FUNC,
	   	       	             l_locked_entities_tbl,
					       x_return_status,
					       x_msg_count,
					       x_msg_data);
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_run_id := GetRunID;
          LOG_REPORT(x_run_id,x_msg_count);
          RETURN;
       END IF;
    END IF;

END copy_Rule_Folder;

--
-- copy Rule Folder
-- Parameters :
--   p_rule_folder_id       - identifies rule folder to copy
--   p_new_parent_folder_id - identifies new parent rule folder
--   x_out_new_rule_id      - OUR parameter - id of new copied rule folder
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--
PROCEDURE copy_Rule_Folder
(p_rule_folder_id           IN   NUMBER,
 p_new_parent_folder_id     IN   NUMBER,
 x_out_rule_folder_id       OUT  NOCOPY   INTEGER,
 x_run_id                   OUT  NOCOPY   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2) IS

BEGIN
  copy_rule_folder(p_rule_folder_id       => p_rule_folder_id
                  ,p_new_parent_folder_id => p_new_parent_folder_id
                  ,p_init_msg_list        => FND_API.G_TRUE
                  ,x_out_rule_folder_id   => x_out_rule_folder_id
                  ,x_run_id               => x_run_id
                  ,x_return_status        => x_return_status
                  ,x_msg_count            => x_msg_count
                  ,x_msg_data             => x_msg_data
                  );
END copy_Rule_Folder;

-- Function set_name_entity.
-- Returns the name, enclosed in single quotes, if the name contains
-- any of the special characters.
-- If the name contains a single quote, the quote is escaped.
--
FUNCTION set_name_entity(p_name IN VARCHAR2) RETURN VARCHAR2 IS

  v_name     VARCHAR2(32000) := p_name;
  v_quotepos PLS_INTEGER     := INSTR(p_name, '''');
BEGIN

  IF(v_quotepos > 0)THEN

    --The name contains a single quote, need to escape.

    v_name := REPLACE(v_name, '''', '\''');
  END IF;

  --Now check for other special characters (including '\').

  IF(LENGTH(TRANSLATE(v_name, 'X /\-*.+|&=<>^,;:@$#!', 'X')) < LENGTH(v_name))THEN

    v_name := '''' || v_name || '''';
    RETURN v_name;
  END IF;

  --Bug #4665333. If the node name is a lexical number, need the quotes.
  --The '.' is not in the name, so we can use it as a not-null third argument as required by TRANSLATE.
  --By parser request we need to make it more strict - enclose in quotes if the first character is numeric.

  IF(TRANSLATE(SUBSTR(v_name, 1, 1), '.0123456789', '.') IS NULL)THEN

    v_name := '''' || v_name || '''';
    RETURN v_name;
  END IF;

 RETURN v_name;
END set_name_entity;

--
-- get absolute model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--   px_model_path - OUT parameter - absolute model path
--
PROCEDURE get_Absolute_Model_Path
(
 p_ps_node_id  IN NUMBER,
 px_model_path OUT NOCOPY VARCHAR2
) IS

BEGIN

    px_model_path := get_Absolute_Model_Path(p_ps_node_id);
END get_Absolute_Model_Path;

--
-- get absolute model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--
FUNCTION get_Absolute_Model_Path
(
 p_ps_node_id  IN NUMBER
) RETURN VARCHAR2 IS

    l_model_path VARCHAR2(32000);
    l_name       VARCHAR2(32000);
BEGIN

    FOR i IN(SELECT NAME FROM CZ_PS_NODES
             START WITH ps_node_id=p_ps_node_id AND deleted_flag='0'
             CONNECT BY PRIOR parent_id=ps_node_id AND
             PRIOR deleted_flag='0' AND deleted_flag='0')
    LOOP

       --If the node name contains special characters (bug #3817913), enclose the name into single quotes.

       l_name := set_name_entity(i.NAME);

       IF l_model_path IS NULL THEN
          l_model_path := l_name;
       ELSE
          l_model_path := l_name || '.' || l_model_path;
       END IF;
    END LOOP;
    RETURN l_model_path;
END get_Absolute_Model_Path;

--
-- get full model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id        - identifies model tree node
--   p_model_ref_expl_id - identifies model_ref_expl_id of model tree node
--   p_model_id          - identifies current model
--   px_model_path       - OUT parameter - full model path
--
PROCEDURE get_Full_Model_Path
(
 p_ps_node_id          IN  NUMBER,
 p_model_ref_expl_id   IN  NUMBER,
 p_model_id            IN  NUMBER,
 px_model_path         OUT NOCOPY VARCHAR2
) IS
BEGIN

  px_model_path := get_Full_Model_Path(p_ps_node_id          => p_ps_node_id,
                                       p_model_ref_expl_id   => p_model_ref_expl_id,
                                       p_model_id            => p_model_id);
END get_Full_Model_Path;

--
-- get full model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id        - identifies model tree node
--   p_model_ref_expl_id - identifies model_ref_expl_id of model tree node
--   p_model_id          - identifies current model
--  RETURN : full model path
--
FUNCTION get_Full_Model_Path
(
 p_ps_node_id          IN  NUMBER,
 p_model_ref_expl_id   IN  NUMBER,
 p_model_id            IN  NUMBER)  RETURN VARCHAR2 IS

    l_model_path      VARCHAR2(32000);
    l_ref_model_path  VARCHAR2(32000);
    l_ps_node_id      NUMBER;

BEGIN

    BEGIN
      SELECT ps_node_id INTO l_ps_node_id
        FROM CZ_PS_NODES
       WHERE ps_node_id=p_ps_node_id AND devl_project_id=p_model_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_model_path := get_Absolute_Model_Path(p_ps_node_id  => p_ps_node_id);

    --
    -- if ps_node_id is in the model with model_id=p_model_id
    -- then Full path = Absolute path
    --
    IF l_ps_node_id IS NOT NULL THEN
      RETURN l_model_path;
    END IF;

    FOR i IN(SELECT * FROM CZ_MODEL_REF_EXPLS
             START WITH model_ref_expl_id=p_model_ref_expl_id
             CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id
             AND deleted_flag='0' AND PRIOR deleted_flag='0')
    LOOP

      IF i.referring_node_id IS NOT NULL THEN

        IF(i.referring_node_id = p_ps_node_id)THEN

          --The ps node is a reference itself. In this case l_ref_model_path calculated below will
          --duplicate the l_model_path calculated above, but we need it only once.

          l_model_path := NULL;
        ELSE

          --if it's not a connector we need to cut off the model name. If it is in single quotes, we need to account for that
          --and search for "'." on the other side of the model's name. Otherwise we just search for "."

          IF i.ps_node_type<>CONNECTOR_TYPE THEN
            IF(SUBSTR(l_model_path, 1, 1) = '''')THEN
              l_model_path := SUBSTR(l_model_path, INSTR(l_model_path,'''.') + 2);
            ELSE
              l_model_path := SUBSTR(l_model_path, INSTR(l_model_path,'.') + 1);
            END IF;
          END IF;
        END IF;

        l_ref_model_path := get_Absolute_Model_Path(p_ps_node_id  => i.referring_node_id);
        IF(l_model_path IS NULL)THEN

          l_model_path := l_ref_model_path;
        ELSE

          l_model_path := l_ref_model_path || '.' || l_model_path;
        END IF;
      END IF;
    END LOOP;

    RETURN l_model_path;
END get_Full_Model_Path;

--
-- get relative model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--   px_model_path - OUT parameter - absolute model path
--
PROCEDURE get_Relative_Model_Path
(
 p_ps_node_id  IN NUMBER,
 px_model_path OUT NOCOPY VARCHAR2
) IS

    l_ps_node_id  CZ_PS_NODES.ps_node_id%TYPE;
    l_name        CZ_PS_NODES.name%TYPE;
    l_model_path  VARCHAR2(32000);

BEGIN

    FOR i IN(SELECT parent_id,name FROM CZ_PS_NODES
             START WITH ps_node_id=p_ps_node_id AND deleted_flag='0'
             CONNECT BY PRIOR parent_id=ps_node_id AND
             PRIOR deleted_flag='0' AND deleted_flag='0' AND NVL(virtual_flag,'1')='1')
    LOOP

       l_name := set_name_entity(i.NAME);

       IF l_model_path IS NULL THEN
          l_model_path:=l_name;
       ELSE
          l_model_path:=l_name||'.'||l_model_path;
       END IF;
       l_ps_node_id := i.parent_id;
    END LOOP;

    IF l_ps_node_id IS NOT NULL THEN
       SELECT name INTO l_name FROM CZ_PS_NODES
       WHERE ps_node_id=l_ps_node_id;

       l_name := set_name_entity(l_name);
       l_model_path := l_name||'.'||l_model_path;
    END IF;

    px_model_path := l_model_path;
END get_Relative_Model_Path;

--
-- get relative model path ( <=> path from root node )
-- Parameters :
--   p_ps_node_id  - identifies model tree node
--
FUNCTION get_Relative_Model_Path
(
 p_ps_node_id  IN NUMBER
) RETURN VARCHAR2 IS

    l_ps_node_id  CZ_PS_NODES.ps_node_id%TYPE;
    l_name        CZ_PS_NODES.name%TYPE;
    l_model_path  VARCHAR2(32000);

BEGIN

    FOR i IN(SELECT parent_id,name FROM CZ_PS_NODES
             START WITH ps_node_id=p_ps_node_id AND deleted_flag='0'
             CONNECT BY PRIOR parent_id=ps_node_id AND
             PRIOR deleted_flag='0' AND deleted_flag='0' AND NVL(virtual_flag,'1')='1')
    LOOP

       l_name := set_name_entity(i.NAME);

       IF l_model_path IS NULL THEN
          l_model_path:=l_name;
       ELSE
          l_model_path:=l_name||'.'||l_model_path;
       END IF;
       l_ps_node_id := i.parent_id;
    END LOOP;

    IF l_ps_node_id IS NOT NULL THEN
       SELECT name INTO l_name FROM CZ_PS_NODES
       WHERE ps_node_id=l_ps_node_id;

       l_name := set_name_entity(l_name);
       l_model_path := l_name||'.'||l_model_path;
    END IF;

    RETURN l_model_path;
END get_Relative_Model_Path;
--------------------------------------------------------------------------------------
FUNCTION get_absolute_label_path(p_ps_node_id   IN NUMBER,
                                 p_label_bom    IN VARCHAR2,
                                 p_label_nonbom IN VARCHAR2) RETURN VARCHAR2
IS
  l_model_path VARCHAR2(32000);
  l_name       VARCHAR2(32000);
BEGIN
    FOR i IN (SELECT name, intl_text_id, ps_node_type FROM cz_ps_nodes
               START WITH ps_node_id = p_ps_node_id AND deleted_flag='0'
             CONNECT BY PRIOR parent_id = ps_node_id AND
                        PRIOR deleted_flag='0' AND deleted_flag='0') LOOP

       l_name := i.name;

       --If the profile option value is 'Description', read the description.

       IF((i.ps_node_type >= BOM_MODEL_TYPE AND p_label_bom = OPTION_VALUE_LABEL_DESC) OR
          (i.ps_node_type < BOM_MODEL_TYPE AND p_label_nonbom = OPTION_VALUE_LABEL_DESC))THEN

         BEGIN
           SELECT text_str INTO l_name FROM cz_localized_texts_vl WHERE intl_text_id = i.intl_text_id;
           l_name := NVL(l_name, i.name);
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_name := i.name;
         END;
       END IF;

       l_name := set_name_entity(l_name);

       IF l_model_path IS NULL THEN
          l_model_path := l_name;
       ELSE
          l_model_path := l_name || '.' || l_model_path;
       END IF;
    END LOOP;
    RETURN l_model_path;
END get_absolute_label_path;
--------------------------------------------------------------------------------------
PROCEDURE get_full_label_path(p_ps_node_id        IN  NUMBER,
                              p_model_ref_expl_id IN  NUMBER,
                              p_model_id          IN  NUMBER,
                              px_model_path       OUT NOCOPY VARCHAR2)
IS
BEGIN
  px_model_path := get_full_label_path(p_ps_node_id          => p_ps_node_id,
                                       p_model_ref_expl_id   => p_model_ref_expl_id,
                                       p_model_id            => p_model_id);
END get_full_label_path;
--------------------------------------------------------------------------------------
FUNCTION get_node_label(p_ps_node_type  IN NUMBER,
                        p_name          IN VARCHAR2,
                        p_description   IN VARCHAR2) RETURN VARCHAR2
IS
  v_label       VARCHAR2(240);
BEGIN

  IF(p_ps_node_type >= BOM_MODEL_TYPE)THEN

    v_label := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_BOM), OPTION_VALUE_LABEL_NAME);
  ELSE

    v_label := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_NONBOM), OPTION_VALUE_LABEL_NAME);
  END IF;

 IF(v_label = OPTION_VALUE_LABEL_NAME)THEN RETURN p_name; ELSE RETURN NVL(p_description, p_name); END IF;
END get_node_label;
--------------------------------------------------------------------------------------
FUNCTION get_node_label(p_ps_node_id IN NUMBER) RETURN VARCHAR2
IS
  v_label         VARCHAR2(240);
  v_ps_node_type  NUMBER;
  v_name          VARCHAR2(4000);
  v_description   VARCHAR2(4000);
  v_intl_text_id  NUMBER;
BEGIN

  SELECT ps_node_type, intl_text_id, name INTO v_ps_node_type,  v_intl_text_id, v_name
    FROM cz_ps_nodes WHERE ps_node_id = p_ps_node_id;

  v_description := v_name;

  IF(v_intl_text_id IS NOT NULL)THEN

    BEGIN
      SELECT text_str INTO v_description FROM cz_localized_texts_vl WHERE intl_text_id = v_intl_text_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  IF(v_ps_node_type >= BOM_MODEL_TYPE)THEN

    v_label := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_BOM), OPTION_VALUE_LABEL_NAME);
  ELSE

    v_label := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_NONBOM), OPTION_VALUE_LABEL_NAME);
  END IF;

 IF(v_label = OPTION_VALUE_LABEL_NAME)THEN RETURN v_name; ELSE RETURN NVL(v_description, v_name); END IF;
END get_node_label;
--------------------------------------------------------------------------------------
FUNCTION get_full_label_path(p_ps_node_id        IN  NUMBER,
                             p_model_ref_expl_id IN  NUMBER,
                             p_model_id          IN  NUMBER) RETURN VARCHAR2
IS
  l_model_path      VARCHAR2(32000);
  l_ref_model_path  VARCHAR2(32000);
  l_ps_node_id      NUMBER;
  v_label_bom       VARCHAR2(240);
  v_label_nonbom    VARCHAR2(240);
BEGIN

    --Read and default the profile option values to 'Name'.

    v_label_bom := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_BOM), OPTION_VALUE_LABEL_NAME);
    v_label_nonbom := NVL(fnd_profile.value_wnps(PROFILE_OPTION_LABEL_NONBOM), OPTION_VALUE_LABEL_NAME);

    BEGIN
      SELECT ps_node_id INTO l_ps_node_id
        FROM CZ_PS_NODES
       WHERE ps_node_id=p_ps_node_id AND devl_project_id=p_model_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_model_path := get_absolute_label_path(p_ps_node_id   => p_ps_node_id,
                                            p_label_bom    => v_label_bom,
                                            p_label_nonbom => v_label_nonbom);

    --If ps_node_id is in the model with model_id = p_model_id  then full path is equal to absolute path.

    IF l_ps_node_id IS NOT NULL THEN RETURN l_model_path; END IF;

    FOR i IN (SELECT * FROM cz_model_ref_expls
               START WITH model_ref_expl_id = p_model_ref_expl_id
             CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id
                 AND deleted_flag='0' AND PRIOR deleted_flag='0') LOOP

      IF i.referring_node_id IS NOT NULL THEN
        IF(i.referring_node_id = p_ps_node_id)THEN

          --The ps node is a reference itself. In this case l_ref_model_path calculated below will
          --duplicate the l_model_path calculated above, but we need it only once.

          l_model_path := NULL;
        ELSE

          --If it's not a connector we need to cut off the model name. If it is in single quotes, we need to
          --account for that and search for "'." on the other side of the model's name. Otherwise we just
          --search for "."

          IF(i.ps_node_type <> CONNECTOR_TYPE)THEN
            IF(SUBSTR(l_model_path, 1, 1) = '''')THEN
              l_model_path := SUBSTR(l_model_path, INSTR(l_model_path, '''.') + 2);
            ELSE
              l_model_path := SUBSTR(l_model_path, INSTR(l_model_path, '.') + 1);
            END IF;
          END IF;
        END IF;

        l_ref_model_path := get_absolute_label_path(p_ps_node_id   => i.referring_node_id,
                                                    p_label_bom    => v_label_bom,
                                                    p_label_nonbom => v_label_nonbom);
        IF(l_model_path IS NULL)THEN

          l_model_path := l_ref_model_path;
        ELSE

          l_model_path := l_ref_model_path || '.' || l_model_path;
        END IF;
      END IF;
    END LOOP;

    RETURN l_model_path;
END get_full_label_path;
--------------------------------------------------------------------------------------
--
-- get path in Repository
-- Parameters :
--   p_object_id   - identifies object
--   p_object_type - identifies object type
--
FUNCTION get_Repository_Path
(
 p_object_id   IN NUMBER,
 p_object_type IN VARCHAR2
) RETURN VARCHAR2 IS

    l_name              CZ_RP_ENTRIES.name%TYPE;
    l_root_name         CZ_RP_ENTRIES.name%TYPE;
    l_enclosing_folder  CZ_RP_ENTRIES.enclosing_folder%TYPE;
    l_repository_path   VARCHAR2(32000);

BEGIN

    SELECT name,enclosing_folder INTO l_repository_path,l_enclosing_folder FROM CZ_RP_ENTRIES
    WHERE object_id=p_object_id AND object_type=p_object_type AND deleted_flag='0';

    l_repository_path := set_name_entity(l_repository_path);

    IF l_enclosing_folder<>0 THEN
       FOR i IN(SELECT name FROM CZ_RP_ENTRIES
                START WITH object_id=l_enclosing_folder AND object_type='FLD' AND deleted_flag='0'
                CONNECT BY PRIOR enclosing_folder=object_id
                AND deleted_flag='0' AND PRIOR deleted_flag='0'
                AND object_type='FLD'  AND PRIOR object_type='FLD' AND object_id<>0 AND PRIOR object_id<>0)
       LOOP

          l_name := set_name_entity(i.NAME);
          l_repository_path:=l_name||'/'||l_repository_path;
       END LOOP;
    END IF;

    IF NOT(l_enclosing_folder=0 AND p_object_id=0 AND p_object_type='FLD') THEN
       BEGIN
           SELECT name INTO l_root_name FROM CZ_RP_ENTRIES
           WHERE object_id=0 AND object_type='FLD' AND deleted_flag='0' AND rownum<2;

                 --If the name contains special symbols, enclose the name in single quotes.

                 l_root_name := set_name_entity(l_root_name);
                 l_repository_path := l_root_name||'/'||l_repository_path;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
       END;
    END IF;

    RETURN l_repository_path;
END get_Repository_Path;

--
-- get path in Rule Folders
-- Parameters :
--   p_rule_folder_id   - identifies object
--   p_object_type     - identifies object type
--
FUNCTION get_Rule_Folder_Path
(
 p_rule_folder_id   IN NUMBER,
 p_object_type      IN VARCHAR2
) RETURN VARCHAR2 IS

    l_name              CZ_RP_ENTRIES.name%TYPE;
    l_root_name         CZ_RP_ENTRIES.name%TYPE;
    l_enclosing_folder  CZ_RP_ENTRIES.enclosing_folder%TYPE;
    l_rule_folder_path  VARCHAR2(32000);

BEGIN

    SELECT name,NVL(parent_rule_folder_id,0)
      INTO l_rule_folder_path,l_enclosing_folder FROM CZ_RULE_FOLDERS
     WHERE rule_folder_id=p_rule_folder_id AND object_type=p_object_type AND deleted_flag='0';

     l_rule_folder_path := set_name_entity(l_rule_folder_path);

    IF l_enclosing_folder<>0 THEN
       FOR i IN(SELECT name FROM CZ_RULE_FOLDERS
                START WITH rule_folder_id=l_enclosing_folder AND object_type='RFL' AND deleted_flag='0'
                CONNECT BY PRIOR parent_rule_folder_id=rule_folder_id
                AND deleted_flag='0' AND PRIOR deleted_flag='0'
                AND object_type='RFL'  AND PRIOR object_type='RFL')
       LOOP

          l_name := set_name_entity(i.NAME);
          l_rule_folder_path := l_name||'/'||l_rule_folder_path;
       END LOOP;
    END IF;

    RETURN l_rule_folder_path;
END get_Rule_Folder_Path;

/*
 * copy Repository folders 6718191 Need to display locked objects
 * This procedure is a wrapper for calling copy_repository_folder.
 * It loops over all of the folders calling a procedure to check for
 * locked Models or Templates and logs them before continuing to do the actual
 *  copy operation.
 *
 *   p_folder_ids           - identifies folders to copy
 *   p_encl_folder_id       - enclosing folder to copy to
 *   x_folder_id            - folder_id
 *   x_return_status        - status string
 *   x_msg_count            - number of error messages
 *   x_msg_data             - string which contains error messages
 */

PROCEDURE copy_repository_folders
(
  p_folder_ids       IN   system.cz_number_tbl_type,
  p_encl_folder_id   IN   NUMBER,
  x_folder_id        OUT  NOCOPY   NUMBER,
  x_run_id           OUT  NOCOPY   NUMBER,
  x_return_status    OUT  NOCOPY   VARCHAR2,
  x_msg_count        OUT  NOCOPY   NUMBER,
  x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

   l_folder_id                  NUMBER;
   l_return_status              VARCHAR2(1);
   l_lock_profile               VARCHAR2(3);

BEGIN

   fnd_msg_pub.initialize;
   l_return_status := FND_API.g_ret_sts_success;

   ----check if locking is enabled
   ----if the site level profile for locking is not enabled then
   ----there is no need to check for locked objects in the folder
   l_lock_profile := cz_security_pvt.get_locking_profile_value;
   IF (UPPER(NVL(l_lock_profile,'Y')) IN ('Y','YES')) THEN
     FOR i IN 1..p_folder_ids.COUNT LOOP
       l_folder_id := p_folder_ids(i);

       -- Log all locked models or UIC templates for display in UI
       check_folder_for_locks(l_folder_id,
                              x_return_status,
                              x_msg_count,
                              x_msg_data);

       -- Need to store status as we are looping and the status will get overwritten for
       -- each folder.
       IF (l_return_status = FND_API.g_ret_sts_success AND x_return_status <> FND_API.g_ret_sts_success) THEN
         l_return_status := x_return_status;
       END IF;
     END LOOP;
   END IF;

  -- If there are locked objects, outro, else perform copy operation
  IF (l_return_status <> FND_API.g_ret_sts_success) THEN
     x_return_status := l_return_status;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     RETURN;
  ELSE
    FOR i IN 1..p_folder_ids.COUNT LOOP
      l_folder_id := p_folder_ids(i);

      -- Copy will also show locked models and UIC templates if locking happens
      -- during copy process
      copy_Repository_Folder(l_folder_id,
                             p_encl_folder_id,
                             x_folder_id,
                             x_run_id,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             FND_API.G_FALSE);

     END LOOP;
  END IF;
END;

--
--   copy Repository folder
--   p_folder_id            - identifies folder to copy
--   p_encl_folder_id       - enclosing folder to copy to
--   x_folder_id            - new copied folder
--   x_run_id               - OUT parameter : if = 0 => no errors
--                          - else = CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--   p_init_msg_list        - yes/no indicates whether to init FND message data
--
PROCEDURE copy_Repository_Folder
(
  p_folder_id        IN   NUMBER,
  p_encl_folder_id   IN   NUMBER,
  x_folder_id        OUT  NOCOPY   NUMBER,
  x_run_id           OUT  NOCOPY   NUMBER,
  x_return_status    OUT  NOCOPY   VARCHAR2,
  x_msg_count        OUT  NOCOPY   NUMBER,
  x_msg_data         OUT  NOCOPY   VARCHAR2,
  p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_TRUE
) IS

    INVALID_ENCL_FLD_EXCP        EXCEPTION;
    INVALID_FLD_EXCP             EXCEPTION;

    l_object_id_tbl              t_int_array_tbl_type;
    l_encl_folder_tbl            t_int_array_tbl_type;
    l_object_type_tbl            t_varchar_array_tbl_type;
    l_new_object_id_tbl          t_int_array_tbl_type;
    l_new_encl_folder_tbl        t_int_array_tbl_type;
    l_folder_id                  NUMBER;
    l_model_id                   NUMBER;
    l_run_id                     NUMBER;
    l_status                     VARCHAR2(255);
    l_new_id                     NUMBER;
    l_folder_name                cz_rp_entries.name%TYPE;

BEGIN

     --initialize the message stack depending on the input parameter
    IF (p_init_msg_list = FND_API.G_TRUE ) THEN
       fnd_msg_pub.initialize;
    END IF;

    x_run_id := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT name INTO l_folder_name
      FROM cz_rp_entries
      WHERE object_id = p_encl_folder_id
      AND object_type = 'FLD'
      AND deleted_flag = '0';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_ENCL_FLD_EXCP;
    END;

    BEGIN
      SELECT object_id,object_type , enclosing_folder
      BULK COLLECT INTO l_object_id_tbl,l_object_type_tbl, l_encl_folder_tbl
      FROM CZ_RP_ENTRIES
      START WITH object_id=p_folder_id AND object_type='FLD' AND deleted_flag='0'
      CONNECT BY PRIOR object_id=ENCLOSING_FOLDER AND PRIOR object_type = 'FLD' AND deleted_flag='0'
      AND PRIOR deleted_flag='0';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_FLD_EXCP;
    END;

    IF l_object_id_tbl.COUNT=0 THEN
       RETURN;
    END IF;

    FOR i IN l_object_id_tbl.FIRST..l_object_id_tbl.LAST
    LOOP

       -- update enclosing folder
       IF i=1 THEN
          l_new_encl_folder_tbl(i) := p_encl_folder_id;
       ELSE

	   FOR j in l_object_id_tbl.FIRST..i LOOP
	     IF (l_encl_folder_tbl(i) = l_object_id_tbl(j) AND l_object_type_tbl(j) = 'FLD') THEN
	         l_new_encl_folder_tbl(i) := l_new_object_id_tbl(j);
	         EXIT;
	     END IF;

           END LOOP;
       END IF;

       IF l_object_type_tbl(i)='FLD' THEN
          l_new_object_id_tbl(i) := allocateId('CZ_RP_ENTRIES_S');

    	   -- Create the new folder

	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
			,l_new_object_id_tbl(i)
	    ,l_new_encl_folder_tbl(i)
			,NAME||' - '||TO_CHAR(l_new_object_id_tbl(i))
	    ,DESCRIPTION
	    ,NOTES
	    ,0
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id=l_object_id_tbl(i) AND object_type=l_object_type_tbl(i)
	   AND deleted_flag='0';

       ELSIF l_object_type_tbl(i)='EFF' THEN

          copy_effectivity_set(
		p_effectivity_set_id         =>   l_object_id_tbl(i),
		p_encl_folder_id             =>   l_new_encl_folder_tbl(i),
		x_new_effectivity_set_id     =>   l_new_object_id_tbl(i),
		x_return_status              =>   x_return_status,
		x_msg_count                  =>   x_msg_count,
		x_msg_data                   =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='PRP' THEN

          copy_property(
		p_property_id         =>   l_object_id_tbl(i),
		p_encl_folder_id      =>   l_new_encl_folder_tbl(i),
		x_new_property_id     =>   l_new_object_id_tbl(i),
		x_return_status       =>   x_return_status,
		x_msg_count           =>   x_msg_count,
		x_msg_data            =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='USG' THEN

          copy_model_usage(
		p_model_usage_id             =>   l_object_id_tbl(i),
		p_encl_folder_id             =>   l_new_encl_folder_tbl(i),
		x_new_model_usage_id         =>   l_new_object_id_tbl(i),
		x_return_status              =>   x_return_status,
		x_msg_count                  =>   x_msg_count,
		x_msg_data                   =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='ARC' THEN

          copy_archive(
		p_archive_id        	     =>   l_object_id_tbl(i),
		p_encl_folder_id             =>   l_new_encl_folder_tbl(i),
		x_new_archive_id             =>   l_new_object_id_tbl(i),
		x_return_status              =>   x_return_status,
		x_msg_count                  =>   x_msg_count,
		x_msg_data                   =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='UCT' THEN

          copy_ui_template(
		p_template_id                =>   l_object_id_tbl(i),
		p_encl_folder_id             =>   l_new_encl_folder_tbl(i),
		x_new_template_id            =>   l_new_object_id_tbl(i),
		x_return_status              =>   x_return_status,
		x_msg_count                  =>   x_msg_count,
		x_msg_data                   =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='UMT' THEN

          copy_ui_master_template(
		p_ui_def_id                  =>   l_object_id_tbl(i),
		p_encl_folder_id             =>   l_new_encl_folder_tbl(i),
		x_new_ui_def_id              =>   l_new_object_id_tbl(i),
		x_return_status              =>   x_return_status,
		x_msg_count                  =>   x_msg_count,
		x_msg_data                   =>   x_msg_data);

       ELSIF l_object_type_tbl(i)='PRJ' THEN
          --  6718191 Need to display locked objects
          cz_pb_mgr.deep_model_copy(
                        p_model_id           => l_object_id_tbl(i),
                        p_server_id          => 0,
		        p_folder             => l_new_encl_folder_tbl(i),
			p_copy_rules	     => 1,
			p_copy_uis 	     => 1,
			p_copy_root	     => 1,
                   	x_return_status      => x_return_status,
		        x_msg_count          => x_msg_count,
	                x_msg_data           => x_msg_data,
                        p_init_msg_list      => p_init_msg_list);

      END IF;

   END LOOP;

   x_folder_id := l_new_object_id_tbl(1);

EXCEPTION
    WHEN INVALID_ENCL_FLD_EXCP THEN
        handle_Error(p_message_name   => 'CZ_COPY_RPFLD_ENCLFLD_ID',
                     p_token_name1     => 'OBJID',
                     p_token_value1    => TO_CHAR(p_encl_folder_id),
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
         x_run_id           := GetRunID;
         LOG_REPORT(x_run_id,x_msg_data);
    WHEN INVALID_FLD_EXCP THEN
        handle_Error(p_message_name   => 'CZ_COPY_RPFLD_FLD_ID',
                     p_token_name1    => 'OBJID',
                     p_token_value1   => TO_CHAR(p_folder_id),
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
         x_run_id           := GetRunID;
         LOG_REPORT(x_run_id,x_msg_data);
    WHEN OTHERS THEN
         ROLLBACK;
         handle_Error(p_procedure_name => 'copy_Repository_Folder',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
         x_run_id           := GetRunID;
         LOG_REPORT(x_run_id,x_msg_data);
END copy_Repository_Folder;

--
-- delete_model_node
-- Parameters :
--   p_ps_node_id           -
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_model_node
(p_ps_node_id               IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2)
IS

 l_procedure_name CONSTANT VARCHAR2(30) := 'delete_model_node';

 TYPE l_tName IS TABLE OF cz_devl_projects.name%TYPE INDEX BY BINARY_INTEGER;

 MODEL_LOCKED_EXCP              EXCEPTION;
 INVALID_PS_NODE_ID_EXCP        EXCEPTION;
 NO_PRIV_EXCP                   EXCEPTION;
 NOT_EDITABLE_EXCP              EXCEPTION;
 BOM_NODE_DELETION_EXCP         EXCEPTION;
 USER_IS_NULL_EXCP              EXCEPTION;
 MODEL_UNLOCKED_EXCP            EXCEPTION;
 REF_EXPLS_DEL_EXCP             EXCEPTION;

 l_model_id_tbl    t_num_array_tbl_type;
 l_model_name_tbl  t_varchar_array_tbl_type;
 l_node_name_tbl   t_varchar_array_tbl_type;

 l_devl_project_id cz_ps_nodes.devl_project_id%TYPE;
 l_name_tbl        l_tName;
 l_priv	           VARCHAR2(1) := 'F';

 l_node_type       cz_ps_nodes.ps_node_type%TYPE;
 l_feature_type    cz_ps_nodes.feature_type%TYPE;
 l_vf              cz_ps_nodes.virtual_flag%TYPE;
 l_parent_id       cz_ps_nodes.parent_id%TYPE;
 l_tree_seq        cz_ps_nodes.tree_seq%TYPE;
 l_node_name       cz_ps_nodes.name%TYPE;

 p_out_err         INTEGER;
 p_del_logically   INTEGER:=1;

 l_user_name       VARCHAR2(40);


 -- child nodes
 CURSOR l_children_csr (inPsNodeId NUMBER) IS
 SELECT ps_node_id, ps_node_type, virtual_flag
   FROM cz_ps_nodes
  WHERE parent_id = inPsNodeId
    AND deleted_flag = '0';

        ---------------------------------------------------------
        -- this procedure is called to process child nodes
        -- it calls itself to complete processing the child nodes
        -- as it finds more children in deeper levels
        ---------------------------------------------------------

        PROCEDURE process_children(p_ps_node_id IN NUMBER) IS

          l_ps_node_tbl        t_int_array_tbl_type;
          l_node_type_tbl      t_int_array_tbl_type;
          l_virtual_flag_tbl   t_varchar_array_tbl_type;
          l_feature_type_tbl   t_int_array_tbl_type;

          p_out_err INTEGER;
          p_del_logically INTEGER:=1;

          CURSOR l_children_csr IS
          SELECT ps_node_id, ps_node_type, virtual_flag, feature_type
            FROM cz_ps_nodes
           WHERE parent_id = p_ps_node_id
             AND deleted_flag = '0';

        BEGIN

            ------------------------------
            -- get the children if any
            -- and process them one by one
            ------------------------------

            OPEN l_children_csr;
            FETCH l_children_csr
            BULK COLLECT
            INTO l_ps_node_tbl, l_node_type_tbl, l_virtual_flag_tbl, l_feature_type_tbl;

            IF (l_ps_node_tbl.COUNT > 0) THEN
		FOR i IN l_ps_node_tbl.FIRST..l_ps_node_tbl.LAST LOOP

		    ------------------------------------
		    -- if it may have children, it calls
		    -- itself to process any children
		    ------------------------------------

		    IF (l_node_type_tbl(i) = COMPONENT_TYPE) OR
                       (l_node_type_tbl(i) = FEATURE_TYPE AND l_feature_type_tbl(i) = OPTION_FEATURE_TYPE) THEN
		      process_children(l_ps_node_tbl(i));
		    END IF;

		    --------------------------
		    -- finally delete this child node
		    --------------------------

		    UPDATE cz_ps_nodes
		       SET deleted_flag = '1'
		     WHERE ps_node_id = l_ps_node_tbl(i)
		       AND ps_node_type NOT IN (436,437,438);

		END LOOP;
            END IF;

            CLOSE l_children_csr;

        EXCEPTION
          WHEN OTHERS THEN
            CLOSE l_children_csr;
            RAISE;
        END process_children;

BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------------
    -- Get the node info and return error if BOM node
    --------------------------------------------------

    BEGIN
      SELECT virtual_flag, ps_node_type, feature_type,
             parent_id, tree_seq, devl_project_id, name
        INTO l_vf, l_node_type, l_feature_type,
             l_parent_id, l_tree_seq, l_devl_project_id, l_node_name
        FROM cz_ps_nodes
       WHERE ps_node_id = p_ps_node_id
         AND deleted_flag = '0';

      IF l_node_type IN (436,437,438) THEN
        RAISE BOM_NODE_DELETION_EXCP;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_PS_NODE_ID_EXCP;
    END;

   /* l_user_name := FND_GLOBAL.user_name;
    IF (l_user_name IS NULL) THEN
	  RAISE USER_IS_NULL_EXCP;
    END IF;

    l_priv := cz_security_pvt.has_privileges  (1.0,
		  l_user_name ,cz_security_pvt.LOCK_MODEL_FUNC,cz_security_pvt.MODEL,l_devl_project_id);
    IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
      RAISE NO_PRIV_EXCP;
    END IF;
*/

/*
    ----attempt to get a lock
    cz_security_pvt.lock_model (l_devl_project_id,x_return_status,x_msg_count,x_msg_data);
    IF (x_return_status <> 'T') THEN
	  RAISE MODEL_LOCKED_EXCP;
    END IF;
*/
    ----------------------------------------------------------
    -- if it has refs, call to delete the refs in expls table
    ----------------------------------------------------------

    IF (l_node_type IN (COMPONENT_TYPE, REFERENCE_TYPE, CONNECTOR_TYPE)) THEN
        CZ_REFS.delete_node(p_ps_node_id,l_node_type,p_out_err,p_del_logically);
        IF (p_out_err <> 0) THEN
          RAISE REF_EXPLS_DEL_EXCP;
        END IF;
    END IF;

    -----------------------------------------------------------------
    -- if it may have children, then recursively process the children
    -----------------------------------------------------------------

    IF (l_node_type = COMPONENT_TYPE) OR
          (l_node_type =  FEATURE_TYPE AND l_feature_type = OPTION_FEATURE_TYPE) THEN
       process_children(p_ps_node_id);
    END IF;

    ------------------------------------------
    -- finally delete the node if not BOM node
    ------------------------------------------

    UPDATE cz_ps_nodes
    SET deleted_flag = '1'
    WHERE ps_node_id = p_ps_node_id
    AND ps_node_type NOT IN (436,437,438);

    --------------------
    --  Update tree_seq
    --------------------

           UPDATE cz_ps_nodes
              SET tree_seq = tree_seq - 1
            WHERE parent_id = l_parent_id
              AND devl_project_id = l_devl_project_id
              AND tree_seq > l_tree_seq
              AND deleted_flag = '0';
/*
    -------------------
    -- Unlock the model
    -------------------

    cz_security_pvt.unlock_model (l_devl_project_id,x_return_status,x_msg_count,x_msg_data);
    IF (x_return_status <> 'T') THEN
	RAISE MODEL_UNLOCKED_EXCP;
    END IF;
*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN REF_EXPLS_DEL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_NODE_DEL_EXLS',
                      p_token_name1    => 'RUNID',
                      p_token_value1   => TO_CHAR(p_out_err),
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN BOM_NODE_DELETION_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_NODE_BOMNODE',
                      p_token_name1    => 'NODENAME',
                      p_token_value1   => l_node_name,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_NODE_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN MODEL_LOCKED_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_NODE_LOCKED_MODEL',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN NO_PRIV_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_NODE_NO_PRIV',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN INVALID_PS_NODE_ID_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_NODE_INV_NODE_ID',
                     p_token_name1    => 'PSNODEID',
                     p_token_value1   => TO_CHAR(p_ps_node_id),
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
        handle_Error(p_procedure_name => 'delete_model_node',
                     p_error_message  => SQLERRM,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
END delete_model_node;

--
-- delete_ui_def
-- Parameters :
--   p_ui_def_id            -
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_ui_def
(p_ui_def_id                IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2)
IS

 TYPE l_tName IS TABLE OF cz_ui_defs.name%TYPE INDEX BY BINARY_INTEGER;

 l_procedure_name CONSTANT VARCHAR2(30) := 'delete_ui_def';

 UIDEF_LOCKED_EXCP              EXCEPTION;
 UIDEF_REFERENCED_EXCP          EXCEPTION;
 INVALID_UIDEF_ID_EXCP          EXCEPTION;
 SEEDED_FLAG_EXCP               EXCEPTION;
 NO_PRIV_EXCP                   EXCEPTION;
 NOT_EDITABLE_EXCP              EXCEPTION;
 MODEL_LOCKED_EXCP              EXCEPTION;
 USER_IS_NULL_EXCP              EXCEPTION;
 DEL_UI_IS_PUBLISHED            EXCEPTION;

 l_user_name       VARCHAR2(40);
 l_checkout_user           cz_devl_projects.checkout_user%TYPE;
 l_priv	    VARCHAR2(1) := 'F';
 l_ui_def_tbl           t_num_array_tbl_type;
 l_name_tbl             l_tName;

 l_model_name_tbl       t_varchar_array_tbl_type;
 l_devl_project_id      cz_ps_nodes.devl_project_id%TYPE;
 l_ui_style             cz_ui_defs.ui_style%TYPE;
 l_seeded_flag          cz_ui_defs.seeded_flag%TYPE;
 l_uidef_name           cz_ui_defs.name%TYPE;

 p_out_err INTEGER;
 p_del_logically INTEGER:=1;

 l_ui_is_published      BOOLEAN;

 ---------------------------------
 -- referencing UI Defs JRAD Style
 ---------------------------------
 CURSOR l_ref_ui_def_jrad_csr (inUIDefID integer) IS
 SELECT DISTINCT r.ui_def_id, d.name
   FROM cz_ui_refs r, cz_ui_defs d
  WHERE r.ref_ui_def_id = inUIDefID
    AND r.ui_def_id = d.ui_def_id
    AND d.deleted_flag = '0'
    AND r.deleted_flag = '0'
    AND d.devl_project_id IN (SELECT object_id
					FROM   cz_rp_entries
					WHERE  cz_rp_entries.object_type = 'PRJ'
					AND    cz_rp_entries.deleted_flag = '0');

 ---------------------------------
 -- referencing UI Defs HTML Style
 ---------------------------------
 CURSOR l_ref_ui_def_0_csr (inUIDefID integer) IS
 SELECT DISTINCT d.ui_def_id, d.name
   FROM cz_ui_nodes n, cz_ui_defs d
  WHERE n.ui_def_ref_id = inUIDefID
    AND n.ui_def_id = d.ui_def_id
    AND d.deleted_flag = '0'
    AND n.deleted_flag = '0';

BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------
    -- get the devl project id
    --------------------------

    BEGIN
        SELECT devl_project_id, seeded_flag, ui_style, name
          INTO l_devl_project_id, l_seeded_flag,  l_ui_style, l_uidef_name
          FROM cz_ui_defs
         WHERE ui_def_id = p_ui_def_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_UIDEF_ID_EXCP;
    END;

    --------------------
    -- check seeded flag
    --------------------

    IF l_seeded_flag = '1' THEN
       RAISE SEEDED_FLAG_EXCP;
    END IF;

    -------------
    -- check priv
    -------------
    /* changes related to bug #3613346
    l_user_name := FND_GLOBAL.user_name;
    IF (l_user_name IS NULL) THEN
	  RAISE USER_IS_NULL_EXCP;
    END IF;
    */

/*
    l_priv := cz_security_pvt.has_privileges  (1.0,
		  l_user_name ,cz_security_pvt.LOCK_MODEL_FUNC,cz_security_pvt.MODEL,l_devl_project_id);
    IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
      RAISE NO_PRIV_EXCP;
    END IF;

    ---------------------------------
    -- attempt to get a lock
    ---------------------------------

    IF (cz_security_pvt.lock_ui_def(p_ui_def_id) <> 'T') THEN
	  RAISE UIDEF_LOCKED_EXCP;
    END IF;
*/

    l_ui_def_tbl.DELETE;
    l_model_name_tbl.DELETE;

    --------------------------------------
    -- check for references to this UI Def
    --------------------------------------

    --
    -- need to check the style to
    -- know what table to look
    --

    IF (l_ui_style = 0) THEN

        OPEN l_ref_ui_def_0_csr(p_ui_def_id);

        FETCH l_ref_ui_def_0_csr BULK COLLECT INTO l_ui_def_tbl, l_name_tbl;

        CLOSE l_ref_ui_def_0_csr;

        IF (l_ui_def_tbl.COUNT > 0) THEN
            x_msg_count := 0;
            FOR i IN l_ui_def_tbl.first..l_ui_def_tbl.last LOOP
              FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_UIDEF_IS_REFED');
              FND_MESSAGE.SET_TOKEN('UIDEFNAME', l_uidef_name);
              FND_MESSAGE.SET_TOKEN('REFUIDEFNAME', l_name_tbl(i));
              FND_MSG_PUB.ADD;
            END LOOP;
            RAISE UIDEF_REFERENCED_EXCP;
        END IF;
    ELSIF (l_ui_style = CZ_UIOA_PVT.G_OA_STYLE_UI) THEN

        OPEN l_ref_ui_def_jrad_csr(p_ui_def_id);

        FETCH l_ref_ui_def_jrad_csr BULK COLLECT INTO l_ui_def_tbl, l_name_tbl;

        CLOSE l_ref_ui_def_jrad_csr;

        IF (l_ui_def_tbl.COUNT > 0) THEN
            x_msg_count := 0;
            FOR i IN l_ui_def_tbl.first..l_ui_def_tbl.last LOOP
              FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_UIDEF_IS_REFED');
              FND_MESSAGE.SET_TOKEN('UIDEFNAME', l_uidef_name);
              FND_MESSAGE.SET_TOKEN('REFUIDEFNAME', l_name_tbl(i));
              FND_MSG_PUB.ADD;
            END LOOP;
            RAISE UIDEF_REFERENCED_EXCP;
        END IF;
    END IF;

    --------------------------------------
    -- check - if this UI published or no
    --------------------------------------
    l_ui_is_published := FALSE;
    x_msg_count := 0;
    FOR k IN(SELECT publication_id FROM CZ_MODEL_PUBLICATIONS
             WHERE ui_def_id=p_ui_def_id AND deleted_flag='0')
    LOOP
      l_ui_is_published := TRUE;
      add_Error_Message(p_message_name  => 'CZ_DEL_UI_IS_PUBLISHED',
                        p_token_name1   => 'PUBID',
                        p_token_value1  => TO_CHAR(k.publication_id));
    END LOOP;

    IF l_ui_is_published THEN
      RAISE DEL_UI_IS_PUBLISHED;
    END IF;

    ----------------------------
    -- finally delete the ui def
    ----------------------------

    UPDATE cz_ui_defs
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_RULES
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_LOCALIZED_TEXTS
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_UI_ACTIONS
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_UI_PAGE_REFS
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_UI_PAGES
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_UI_PAGE_SETS
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    UPDATE CZ_UI_PAGE_ELEMENTS
       SET deleted_flag = '1'
     WHERE ui_def_id = p_ui_def_id;

    FOR I in (SELECT JRAD_DOC from CZ_UI_PAGES
	      WHERE  ui_def_id = p_ui_def_id)
     LOOP

      IF jdr_docbuilder.documentexists(i.JRAD_DOC)=TRUE
      THEN
	 jdr_docbuilder.deleteDocument(i.JRAD_DOC);
      END IF;

     END LOOP;

EXCEPTION
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_UIDEF_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN UIDEF_LOCKED_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_UIDEF_LOCKED',
                     p_token_name1    => 'UIDEFNAME',
                     p_token_value1   => l_uidef_name,
                     p_token_name2    => 'CHECKOUT_USER',
                     p_token_value2   => l_checkout_user,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN NO_PRIV_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_UIDEF_NO_PRIV',
                      p_token_name1    => 'UIDEFNAME',
                      p_token_value1   =>  l_uidef_name,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN SEEDED_FLAG_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_UIDEF_SEEDED_DATA',
                      p_token_name1    => 'UIDEFNAME',
                      p_token_value1   =>  l_uidef_name,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN MODEL_LOCKED_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_UIDEF_MODEL_LOCKED',
                      p_token_name1    => 'UIDEFNAME',
                      p_token_value1   =>  l_uidef_name,
                      p_token_name2    => 'CHECKOUT_USER',
                      p_token_value2   => l_checkout_user,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN UIDEF_REFERENCED_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_UIDEF_REFS_EXIST',
                      p_token_name1    => 'UIDEFNAME',
                      p_token_value1   =>  l_uidef_name,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);

    WHEN INVALID_UIDEF_ID_EXCP THEN
         handle_Error(p_message_name   => 'CZ_INVALID_UIDEF',
                      p_token_name1    => 'UIDEFID',
                      p_token_value1   => TO_CHAR(p_ui_def_id),
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN DEL_UI_IS_PUBLISHED THEN
        x_return_status  :=  FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        x_msg_data  := fnd_msg_pub.GET(1,fnd_api.g_false);
    WHEN OTHERS THEN
         handle_Error(p_procedure_name => 'delete_ui_def',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
END delete_ui_def;

--
-- delete_rule_folder
-- Parameters :
--   p_rule_folder_id       -
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_rule_folder
(p_rule_folder_id         IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2)
IS

 l_procedure_name CONSTANT VARCHAR2(30) := 'delete_rule_folder';
 l_priv	    VARCHAR2(1) := 'F';

 RFL_LOCKED_EXCP           EXCEPTION;
 MODEL_LOCKED_EXCP         EXCEPTION;
 INVALID_RFL_EXCP          EXCEPTION;
 SEEDED_FLAG_EXCP          EXCEPTION;
 NO_PRIV_EXCP              EXCEPTION;
 NOT_EDITABLE_EXCP         EXCEPTION;
 USER_IS_NULL_EXCP         EXCEPTION;

 l_user_name               VARCHAR2(40);
 l_checkout_user           cz_devl_projects.checkout_user%TYPE;
 l_model_name_tbl          t_varchar_array_tbl_type;
 l_rule_folder_id_tbl      t_num_array_tbl_type;
 l_object_type_tbl         t_varchar_array_tbl_type;
 l_devl_project_id         cz_rule_folders.devl_project_id%TYPE;
 l_parent_rule_folder_id   cz_rule_folders.parent_rule_folder_id%TYPE;
 l_rfl_name                cz_rule_folders.name%TYPE;

 p_out_err INTEGER;
 p_del_logically INTEGER:=1;

BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------
    -- get the devl project id
    --------------------------

    l_parent_rule_folder_id := 0;

    BEGIN
        SELECT devl_project_id, nvl(parent_rule_folder_id,0), name
          INTO l_devl_project_id, l_parent_rule_folder_id, l_rfl_name
          FROM cz_rule_folders
         WHERE rule_folder_id = p_rule_folder_id
           AND object_type = 'RFL'
           AND deleted_flag = '0';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_RFL_EXCP;
    END;

    --------------------
    -- check seeded flag
    --------------------

    IF (l_parent_rule_folder_id = 0) THEN
       RAISE SEEDED_FLAG_EXCP;
    END IF;

    -------------
    -- check priv
    -------------
    /* changes related to bug #3613346
    l_user_name := FND_GLOBAL.user_name;
    IF (l_user_name IS NULL) THEN
	  RAISE USER_IS_NULL_EXCP;
    END IF;
    */
/*
    l_priv := cz_security_pvt.has_privileges  (1.0,
		  l_user_name ,cz_security_pvt.LOCK_MODEL_FUNC,cz_security_pvt.MODEL,l_devl_project_id);
    IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
      RAISE NO_PRIV_EXCP;
    END IF;

    ----------------------------------
    -- attempt to get a lock
    ----------------------------------

    IF (cz_security_pvt.lock_rulefolder(p_rule_folder_id) <> 'T') THEN
    	  RAISE RFL_LOCKED_EXCP;
    END IF;
*/
    ------------------------------------------------------------------------------------
    -- logically delete all from cz_rule_folders, the trigger takes care of other tables
    ------------------------------------------------------------------------------------

        l_rule_folder_id_tbl.delete;
    	SELECT rule_folder_id, object_type
          BULK
       COLLECT
          INTO l_rule_folder_id_tbl, l_object_type_tbl
          FROM cz_rule_folders
    	 START WITH rule_folder_id = p_rule_folder_id and object_type='RFL'
       CONNECT BY PRIOR rule_folder_id = parent_rule_folder_id
      	   AND PRIOR object_type in  ('RFL','RSQ')
           AND PRIOR deleted_flag = '0'
           AND deleted_flag = '0';

       IF (l_rule_folder_id_tbl.COUNT > 0) THEN

           FOR i IN l_rule_folder_id_tbl.FIRST..l_rule_folder_id_tbl.LAST LOOP
                update cz_rule_folders
                set deleted_flag = '1'
                where rule_folder_id = l_rule_folder_id_tbl(i)
		and object_type=l_object_type_tbl(i);
            END LOOP;

       END IF;

EXCEPTION
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_RFL_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN SEEDED_FLAG_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RFL_SEEDED_DATA',
                     p_token_name1    => 'RFLNAME',
                     p_token_value1   => l_rfl_name,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN MODEL_LOCKED_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RFL_LOCKED_MODEL',
                     p_token_name1    => 'RFLNAME',
                     p_token_value1   => l_rfl_name,
                     p_token_name2    => 'CHECKOUTUSER',
                     p_token_value2   => l_checkout_user,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN RFL_LOCKED_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RFL_LOCKED_RFL',
                     p_token_name1    => 'RFLNAME',
                     p_token_value1   => l_rfl_name,
                     p_token_name2    => 'CHECKOUTUSER',
                     p_token_value2   => l_checkout_user,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN NO_PRIV_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RFL_NO_PRIV',
                     p_token_name1    => 'RFLNAME',
                     p_token_value1   => l_rfl_name,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN INVALID_RFL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_INVALID_RFL',
                      p_token_name1    => 'RFLID',
                      p_token_value1   => TO_CHAR(p_rule_folder_id),
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
         handle_Error(p_procedure_name => 'delete_rule_folder',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                     x_msg_data        => x_msg_data);
END delete_rule_folder;


--
-- delete_rule_sequence
-- Parameters :
--   p_rule_sequence_id     -
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_rule_sequence
(p_rule_sequence_id         IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2)
IS

 l_procedure_name CONSTANT VARCHAR2(30) := 'delete_rule_sequence';
 l_priv	    VARCHAR2(1) := 'F';


 MODEL_LOCKED_EXCP         EXCEPTION;
 RSQ_LOCKED_EXCP           EXCEPTION;
 INVALID_RSQ_EXCP          EXCEPTION;
 SEEDED_FLAG_EXCP          EXCEPTION;
 NO_PRIV_EXCP              EXCEPTION;
 NOT_EDITABLE_EXCP         EXCEPTION;
 USER_IS_NULL_EXCP         EXCEPTION;

 l_user_name               VARCHAR2(40);
 l_checkout_user           cz_devl_projects.checkout_user%TYPE;
 l_ui_def_tbl  t_num_array_tbl_type; -- the referencing models
 l_model_name_tbl t_varchar_array_tbl_type;
 l_devl_project_id cz_ps_nodes.devl_project_id%TYPE;

 l_rsq_name cz_rule_folders.name%TYPE;

 p_out_err INTEGER;
 p_del_logically INTEGER:=1;

BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------
    -- get the devl project id
    --------------------------

    BEGIN
        SELECT devl_project_id, name
          INTO l_devl_project_id, l_rsq_name
          FROM cz_rule_folders
         WHERE rule_folder_id = p_rule_sequence_id
           AND object_type = 'RSQ';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_RSQ_EXCP;
    END;

    -------------
    -- check priv
    -------------
    /* changes related to bug #3613346
    l_user_name := FND_GLOBAL.user_name;
    IF (l_user_name IS NULL) THEN
	  RAISE USER_IS_NULL_EXCP;
    END IF;
    */
/*
    l_priv := cz_security_pvt.has_privileges  (1.0,
		  l_user_name ,cz_security_pvt.LOCK_MODEL_FUNC,cz_security_pvt.MODEL,l_devl_project_id);
    IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
      RAISE NO_PRIV_EXCP;
    END IF;

    ----------------------------------
    -- attempt to get a lock
    ----------------------------------

    IF (cz_security_pvt.lock_rulefolder(p_rule_sequence_id) <> 'T') THEN
   	  RAISE RSQ_LOCKED_EXCP;
    END IF;
*/
    ----------------------------------
    -- delete the rules in this folder
    ----------------------------------

    UPDATE cz_rules
       SET deleted_flag = '1'
     WHERE rule_folder_id = p_rule_sequence_id;

    -------------------------
    -- delete the rule folder
    -------------------------

    UPDATE cz_rule_folders
       SET deleted_flag = '1'
     WHERE rule_folder_id = p_rule_sequence_id
       AND object_type = 'RSQ';

EXCEPTION
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_RSQ_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN SEEDED_FLAG_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RSQ_SEEDED_DATA',
                     p_token_name1    => 'RSQNAME',
                     p_token_value1   => l_rsq_name,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN MODEL_LOCKED_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RSQ_LOCKED_RSQ',
                     p_token_name1    => 'RSQNAME',
                     p_token_value1   => l_rsq_name,
                     p_token_name2    => 'CHECKOUTUSER',
                     p_token_value2   => l_checkout_user,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN RSQ_LOCKED_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_RSQ_LOCKED_RSQ',
                      p_token_name1    => 'RSQNAME',
                      p_token_value1   => l_rsq_name,
                      p_token_name2    => 'CHECKOUTUSER',
                      p_token_value2   => l_checkout_user,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN NO_PRIV_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_RSQ_NO_PRIV',
                     p_token_name1    => 'RSQNAME',
                     p_token_value1   => l_rsq_name,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN INVALID_RSQ_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_RSQ_INVALID_RSQ_ID',
                      p_token_name1    => 'RSQID',
                      p_token_value1   => TO_CHAR(p_rule_sequence_id),
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
        handle_Error(p_procedure_name => 'delete_rule_sequence',
                     p_error_message  => SQLERRM,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
END delete_rule_sequence;

--
-- delete_item_type
-- Parameters :
--   p_item_type_id         -
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages
--

PROCEDURE delete_item_type
(p_item_type_id             IN   NUMBER,
 x_return_status            OUT  NOCOPY   VARCHAR2,
 x_msg_count                OUT  NOCOPY   NUMBER,
 x_msg_data                 OUT  NOCOPY   VARCHAR2)
IS

 l_procedure_name          CONSTANT VARCHAR2(30) := 'delete_item_type';
 l_priv	                   VARCHAR2(1) := 'F';

 SEEDED_FLAG_EXCP          EXCEPTION;
 INVALID_ITEM_TYPE_ID_EXCP EXCEPTION;
 USER_IS_NULL_EXCP         EXCEPTION;
 NO_PRIV_EXCP	           EXCEPTION;

 l_user_name               VARCHAR2(40);
 l_checkout_user           cz_devl_projects.checkout_user%TYPE;
 l_item_id_tbl             t_num_array_tbl_type;

 CURSOR l_item_csr IS
 SELECT item_id
   FROM cz_item_masters
  WHERE item_type_id = p_item_type_id
    AND deleted_flag = '0';

BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_item_type_id = G_DEFAULT_ITEM_TYPE) THEN
       RAISE SEEDED_FLAG_EXCP;
    END IF;

    -------------
    -- check priv
    -------------
    /* changes related to bug #3613346
    l_user_name := FND_GLOBAL.user_name;
    IF (l_user_name IS NULL) THEN
	  RAISE USER_IS_NULL_EXCP;
    END IF;
    */
/*
    l_priv := cz_security_pvt.has_privileges  (1.0,
		  l_user_name ,cz_security_pvt.LOCK_MODEL_FUNC,cz_security_pvt.MODEL,l_devl_project_id);
    IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
      RAISE NO_PRIV_EXCP;
    END IF;
*/

    ----------------------------------
    -- delete any item property values
    ----------------------------------

    OPEN l_item_csr;
    l_item_id_tbl.DELETE;
    FETCH l_item_csr BULK COLLECT INTO l_item_id_tbl;

    IF (l_item_id_tbl.COUNT > 0) THEN

        FORALL i IN l_item_id_tbl.FIRST..l_item_id_tbl.LAST
            UPDATE cz_item_property_values
               SET deleted_flag = '1'
             WHERE item_id = l_item_id_tbl(i);

    END IF;
    CLOSE l_item_csr;

    -------------------------------------------------------------
    -- change the item type of items in this item type to default
    -------------------------------------------------------------

    UPDATE cz_item_masters
       SET item_type_id = G_DEFAULT_ITEM_TYPE
     WHERE item_type_id = p_item_type_id;

    ----------------------------------
    -- delete the item type properties
    ----------------------------------

    UPDATE cz_item_type_properties
       SET deleted_flag ='1'
     WHERE item_type_id = p_item_type_id;

    -----------------------
    -- delete the item type
    -----------------------

    UPDATE cz_item_types
       SET deleted_flag ='1'
     WHERE item_type_id = p_item_type_id;

    IF SQL%NOTFOUND THEN
      RAISE INVALID_ITEM_TYPE_ID_EXCP;
    END IF;

EXCEPTION
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_IT_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN SEEDED_FLAG_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_IT_SEEDED_DATA',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN NO_PRIV_EXCP THEN
        handle_Error(p_message_name   => 'CZ_DEL_IT_NO_PRIV',
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
    WHEN INVALID_ITEM_TYPE_ID_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_IT_INVALID_ITEM_TYPE_ID',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
         handle_Error(p_procedure_name => 'delete_item_type',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
END delete_item_type;

--
-- is_model_deleteable
-- Parameters :
--   p_model_id             - object_id in cz_rp_entries where object_type = 'PRJ'
--   x_return_status        - status string: 'S', 'E', 'U'
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages

PROCEDURE is_model_deleteable (p_model_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2)
IS

 TYPE number_type_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE tModelNames IS TABLE OF cz_devl_projects.name%TYPE INDEX BY BINARY_INTEGER;
 TYPE tModelIds IS TABLE OF cz_devl_projects.devl_project_id%TYPE INDEX BY BINARY_INTEGER;

 SEEDED_FLAG_EXCP          EXCEPTION;
 MODEL_LOCKED              EXCEPTION;
 NO_PRIV                   EXCEPTION;
 REFS_EXIST                EXCEPTION;
 INVALID_MODEL_ID          EXCEPTION;
 UNEXPECTED_ERROR          EXCEPTION;
 MODEL_PUBS_EXIST          EXCEPTION;
 USER_IS_NULL_EXCP         EXCEPTION;
 MODEL_DELETED		   EXCEPTION;

 l_user_name               VARCHAR2(40);
 l_checkout_user           cz_devl_projects.checkout_user%TYPE;
 l_model_name              cz_devl_projects.name%TYPE;
 l_devl_project_id         cz_devl_projects.devl_project_id%TYPE;

 l_priv	                   VARCHAR2(1) := 'F';
 l_return_status           VARCHAR2(1);
 l_msg_count               NUMBER := 0;
 l_msg_data                VARCHAR2(2000);

 x_ref_model_ids_tbl       tModelIds;
 l_publication_tbl         tModelIds;
 x_ref_model_names_tbl     tModelNames;
 l_seeded_flag             VARCHAR2(1);
 l_deleted_flag             VARCHAR2(1);

 l_procedure_name CONSTANT VARCHAR2(30) := 'is_model_deleteable';

BEGIN

        FND_MSG_PUB.initialize;
        l_user_name := FND_GLOBAL.user_name;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        ------------------------------
        -- check for valid p_model_id
        ------------------------------
        BEGIN
            SELECT a.seeded_flag, a.name, a.deleted_flag, checkout_user
              INTO l_seeded_flag, l_model_name, l_deleted_flag, l_checkout_user
              FROM cz_rp_entries a, cz_devl_projects b
             WHERE object_id = p_model_id
               AND object_type = 'PRJ'
               AND object_id = devl_project_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE INVALID_MODEL_ID;
        END;

        IF (l_deleted_flag = '1') THEN
	  RAISE MODEL_DELETED;
	END IF;

        IF (l_seeded_flag = '1') THEN
          RAISE SEEDED_FLAG_EXCP;
        END IF;

        IF ( l_checkout_user IS NOT NULL AND l_checkout_user <> l_user_name ) THEN
          RAISE MODEL_LOCKED;
        END IF;

       -------------------------------------
       -- check for user privs on this model
       -------------------------------------
       l_priv := cz_security_pvt.has_model_privileges(p_model_id,'PRJ');
       IF (l_priv <> cz_security_pvt.HAS_PRIVILEGE) THEN
          RAISE NO_PRIV;
       ELSIF (l_priv = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE UNEXPECTED_ERROR;
       END IF;

      ----------------------------------
      -- check for model refs/connectors
      ----------------------------------
      BEGIN

            SELECT d.devl_project_id, d.name
              BULK COLLECT INTO x_ref_model_ids_tbl, x_ref_model_names_tbl
              FROM cz_ps_nodes p, cz_devl_projects d
             WHERE p.reference_id = p_model_id
               AND p.ps_node_type IN (263, 264)
               AND p.deleted_flag = '0'
               AND p.devl_project_id = d.devl_project_id
		   AND d.deleted_flag = '0';
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL; -- good, no refs or connectors to worry about
      END;

      IF x_ref_model_ids_tbl.COUNT > 0 THEN
         FOR i IN 1..x_ref_model_ids_tbl.COUNT LOOP
  		  FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_IS_REFD_BY');
  		  FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name);
  		  FND_MESSAGE.SET_TOKEN('REFMODELNAME', x_ref_model_names_tbl(i));
  		  FND_MSG_PUB.ADD;
         END LOOP;
         RAISE REFS_EXIST;
      END IF;

      ---------------------------------------
      -- finally, check for published models
      ---------------------------------------
      BEGIN
          SELECT publication_id BULK COLLECT INTO l_publication_tbl
          FROM cz_model_publications
          WHERE object_id = p_model_id
          AND object_type = 'PRJ'
          AND deleted_flag = '0';

          IF (l_publication_tbl.COUNT > 0) THEN

             RAISE MODEL_PUBS_EXIST;

          END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL; -- good no published models to worry about
      END;

EXCEPTION
    WHEN USER_IS_NULL_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_MODEL_NULL_USER',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN INVALID_MODEL_ID THEN
         handle_Error(p_message_name   => 'CZ_DEL_MODEL_NOT_FOUND',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN MODEL_DELETED THEN
	   NULL;
    WHEN SEEDED_FLAG_EXCP THEN
         handle_Error(p_message_name   => 'CZ_DEL_MODEL_SEEDED_DATA',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN MODEL_LOCKED THEN
         handle_Error(p_message_name   => 'CZ_DEL_MODEL_LOCKED_MODEL',
                      p_token_name1    => 'MODELNAME',
                      p_token_value1   => l_model_name,
                      p_token_name2    => 'CHECKOUTUSER',
                      p_token_value2   => l_checkout_user,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN REFS_EXIST THEN
                      FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_REFS_EXIST');
                      FND_MSG_PUB.ADD;
                      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                                p_data  => x_msg_data);
                      x_return_status  :=  FND_API.G_RET_STS_ERROR;
    WHEN MODEL_PUBS_EXIST THEN
                      FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_IS_PUBSHD');
       		      FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name);
                      FND_MSG_PUB.ADD;
                      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                                p_data  => x_msg_data);
                      x_return_status  :=  FND_API.G_RET_STS_ERROR;
    WHEN NO_PRIV THEN
         handle_Error(p_message_name   => 'CZ_DEL_MODEL_NO_MODEL_PRIV',
                      p_token_name1    => 'MODELNAME',
                      p_token_value1   => l_model_name,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN UNEXPECTED_ERROR THEN
         handle_Error(p_procedure_name => 'is_model_deleteable',
                      p_error_message  => ' unexpected error in cz_security_pvt.has_model_privileges()',
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
         handle_Error(p_procedure_name => 'is_model_deleteable',
                      p_error_message  => SQLERRM,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
END is_model_deleteable;
--------------------------------------------------------------------------------
PROCEDURE delete_model(p_model_id             IN  NUMBER
                      ,x_return_status        OUT NOCOPY  VARCHAR2
                      ,x_msg_count            OUT NOCOPY  NUMBER
                      ,x_msg_data             OUT NOCOPY  VARCHAR2)
IS
  LOCK_MODEL_EXCP  EXCEPTION;
  l_locked_model_tbl        cz_security_pvt.number_type_tbl;
BEGIN

  FND_MSG_PUB.initialize;

  is_model_deleteable(p_model_id, x_return_status, x_msg_count, x_msg_data);

  IF ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

     cz_security_pvt.lock_model(
                        p_api_version           =>   1.0,
			p_model_id              =>   p_model_id,
			p_lock_child_models     =>   FND_API.G_FALSE,
			p_commit_flag           =>   FND_API.G_FALSE,
			x_locked_entities       =>   l_locked_model_tbl,
			x_return_status         =>   x_return_status,
			x_msg_count             =>   x_msg_count,
			x_msg_data              =>   x_msg_data);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE LOCK_MODEL_EXCP;
     END IF;

     UPDATE cz_devl_projects
        SET deleted_flag = '1',
            name = append_name (p_model_id, 'PRJ', name)
      WHERE devl_project_id = p_model_id
        AND deleted_flag = '0';
  END IF;

EXCEPTION
  WHEN LOCK_MODEL_EXCP THEN
       FND_MESSAGE.SET_NAME('CZ','CZ_DEL_MODEL_LOCK_ERR');
       FND_MSG_PUB.ADD;
       x_msg_count := x_msg_count + 1;
       x_msg_data  := fnd_msg_pub.GET(x_msg_count,fnd_api.g_false);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'delete_model',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
END delete_model;


--
--   copy_model_usage
--   p_model_usage_id       - identifies folder to copy
--   p_encl_folder_id       - enclosing folder to copy to
--   x_folder_id            - new copied folder
--   x_run_id               - OUT parameter : if =0 => no errors
--                          - else =CZ_DB_LOGS.run_id
--   x_return_status        - status string
--   x_msg_count            - number of error messages
--   x_msg_data             - string which contains error messages

PROCEDURE copy_model_usage
(
p_model_usage_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_model_usage_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'copy_model_usage';
  INVALID_MODEL_USAGE_ID_EXCP     EXCEPTION;
  USER_IS_NULL_EXCP               EXCEPTION;
  usageID NUMBER := 0;
  l_usage_name cz_model_usages.name%TYPE;
BEGIN
    FND_MSG_PUB.initialize;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    new_usage (p_encl_folder_id,usageID);
    IF (usageID = -2) THEN
	 x_return_status :=  FND_API.G_RET_STS_ERROR;
	 x_msg_count := 1;
	 handle_Error(p_message_name   => 'CZ_COPY_MODELUSG_MAX',
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
     ELSE
	 l_usage_name := copy_name(p_model_usage_id,'USG');

	 UPDATE cz_rp_entries
	 SET    name = l_usage_name
	 WHERE  object_id = usageID
	  AND   object_type = 'USG';

	 UPDATE cz_model_usages
	 SET    name = l_usage_name,
	        note=(select note from cz_model_usages
	 where model_usage_id=usageID)
	 WHERE  model_usage_id = usageID;


	 update cz_model_usages_tl target
	 set (LANGUAGE,SOURCE_LANG,DESCRIPTION)=(select  LANGUAGE,SOURCE_LANG,DESCRIPTION
         from
         cz_model_usages_tl  source where model_usage_id=p_model_usage_id and target.language=source.language)
         where model_usage_id=usageID;

	 x_new_model_usage_id := usageID;
     END IF;
EXCEPTION
  WHEN INVALID_MODEL_USAGE_ID_EXCP THEN
       handle_Error(p_message_name   => 'CZ_COPY_MODELUSG_INV_ID',
                    p_token_name1    => 'USGID',
                    p_token_value1   => TO_CHAR(p_model_usage_id),
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_model_usage',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
END copy_model_usage;


PROCEDURE copy_property
(
p_property_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_property_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'copy_property';
  INVALID_PROPERTY_ID_EXCP  EXCEPTION;
  USER_IS_NULL_EXCP         EXCEPTION;
  l_name	            cz_rp_entries.name%TYPE;
  l_new_intl_text_id        cz_localized_texts.intl_text_id%TYPE;
  l_text_id                 NUMBER;

BEGIN

          x_return_status :=  FND_API.G_RET_STS_SUCCESS;
          x_new_property_id := allocateId('CZ_PROPERTIES_S');
	    l_name := copy_name(p_property_id,'PRP');
          INSERT INTO CZ_PROPERTIES
          (
           PROPERTY_ID
           ,PROPERTY_UNIT
           ,DESC_TEXT
           ,NAME
           ,DATA_TYPE
           ,DEF_VALUE
           ,USER_NUM01
           ,USER_NUM02
           ,USER_NUM03
           ,USER_NUM04
           ,USER_STR01
           ,USER_STR02
           ,USER_STR03
           ,USER_STR04
           ,DELETED_FLAG
           ,EFF_FROM
           ,EFF_TO
           ,SECURITY_MASK
           ,EFF_MASK
           ,CHECKOUT_USER
	     ,def_num_value
           )
           SELECT
            x_new_property_id
           ,PROPERTY_UNIT
           ,DESC_TEXT
           ,l_name
           ,DATA_TYPE
           ,DEF_VALUE
           ,USER_NUM01
           ,USER_NUM02
           ,USER_NUM03
           ,USER_NUM04
           ,USER_STR01
           ,USER_STR02
           ,USER_STR03
           ,USER_STR04
           ,DELETED_FLAG
           ,EFF_FROM
           ,EFF_TO
           ,SECURITY_MASK
           ,EFF_MASK
           ,CHECKOUT_USER
           ,def_num_value
           FROM CZ_PROPERTIES
           WHERE property_id=p_property_id;

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_PROPERTY_ID_EXCP;
           END IF;

           -- Create new text if the type is translateable text
           FOR i IN (SELECT def_num_value FROM cz_properties
                     WHERE property_id=p_property_id
                     AND data_type=8
                     AND def_num_value IS NOT NULL) LOOP
               l_text_id := i.def_num_value;
               l_new_intl_text_id := copy_INTL_TEXT(i.def_num_value);
               IF l_new_intl_text_id = -1 THEN
                 RAISE NO_TXT_FOUND_EXCP;
               END IF;
               UPDATE cz_properties
               SET def_num_value=l_new_intl_text_id
               WHERE property_id=x_new_property_id;
           END LOOP;

           --Create Repository Entry

	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
	    ,x_new_property_id
	    ,p_encl_folder_id
	    ,l_name
	    ,DESCRIPTION
	    ,NOTES
          ,'0'
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id= p_property_id AND object_type='PRP'
	   AND deleted_flag='0';

         IF SQL%ROWCOUNT = 0 THEN
            RAISE INVALID_PROPERTY_ID_EXCP;
         END IF;
EXCEPTION
  WHEN INVALID_PROPERTY_ID_EXCP THEN
       handle_Error(p_message_name   => 'CZ_COPY_PRP_INV_ID',
                    p_token_name1    => 'OBJID',
                    p_token_value1   => TO_CHAR(p_property_id),
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
WHEN NO_TXT_FOUND_EXCP THEN
         handle_Error(p_message_name   => 'CZ_COPY_PROP_NO_TXT',
                      p_token_name1    => 'TEXTID',
                      p_token_value1   => TO_CHAR(l_text_id),
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_property',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
END copy_property;

PROCEDURE copy_effectivity_set
(
p_effectivity_set_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_effectivity_set_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'copy_effectivity_set';
  INVALID_EFF_SET_ID_EXCP   EXCEPTION;
  USER_IS_NULL_EXCP               EXCEPTION;
  l_name	cz_rp_entries.name%TYPE;
BEGIN
          FND_MSG_PUB.initialize;
	    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
          x_new_effectivity_set_id := allocateId('CZ_EFFECTIVITY_SETS_S');
	    l_name := copy_name(p_effectivity_set_id,'EFF');
	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
	    ,x_new_effectivity_set_id
	    ,p_encl_folder_id
          ,l_name
	    ,DESCRIPTION
	    ,NOTES
          ,'0'
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id= p_effectivity_set_id AND object_type='EFF'
	   AND deleted_flag='0';

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_EFF_SET_ID_EXCP;
           END IF;

          INSERT INTO CZ_EFFECTIVITY_SETS
          (
           EFFECTIVITY_SET_ID
           ,NAME
           ,DESCRIPTION
           ,NOTE
           ,EFFECTIVE_FROM
           ,EFFECTIVE_UNTIL
           ,USER_STR01
           ,USER_STR02
           ,USER_STR03
           ,USER_STR04
           ,USER_NUM01
           ,USER_NUM02
           ,USER_NUM03
           ,USER_NUM04
           ,DELETED_FLAG
          )
          SELECT
           x_new_effectivity_set_id
          ,l_name
          ,DESCRIPTION
          ,NOTE
          ,EFFECTIVE_FROM
          ,EFFECTIVE_UNTIL
          ,USER_STR01
           ,USER_STR02
           ,USER_STR03
           ,USER_STR04
           ,USER_NUM01
           ,USER_NUM02
           ,USER_NUM03
           ,USER_NUM04
           ,DELETED_FLAG
          FROM CZ_EFFECTIVITY_SETS
          WHERE effectivity_set_id = p_effectivity_set_id;

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_EFF_SET_ID_EXCP;
           END IF;

EXCEPTION
  WHEN INVALID_EFF_SET_ID_EXCP THEN
       handle_Error(p_message_name   => 'CZ_COPY_EFF_INV_ID',
                    p_token_name1    => 'OBJID',
                    p_token_value1   => TO_CHAR(p_effectivity_set_id),
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_effectivity_set',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
END copy_effectivity_set;

PROCEDURE copy_archive
(
p_archive_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_archive_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

  l_api_version                  CONSTANT NUMBER := 1.0;
  l_api_name                     CONSTANT VARCHAR2(30) := 'copy_archive';
  INVALID_ARCHIVE_ID_EXCP    EXCEPTION;
  USER_IS_NULL_EXCP               EXCEPTION;

BEGIN
          x_new_archive_id := allocateId('CZ_ARCHIVES_S');
	  INSERT INTO CZ_ARCHIVES(
		 ARCHIVE_ID
		,NAME
		,DESCRIPTION
		,ARCHIVE_TYPE
		,ARCHIVE_BLOB
                ,ARCHIVE_URL
                ,PERSISTENT_ARCHIVE_ID
                ,DELETED_FLAG
                ,DOCUMENTATION_URL
                )
                SELECT
		       x_new_archive_id
                      ,NAME||' - '||TO_CHAR(x_new_archive_id)
		,DESCRIPTION
		,ARCHIVE_TYPE
		,ARCHIVE_BLOB
                ,ARCHIVE_URL
                ,PERSISTENT_ARCHIVE_ID
                ,DELETED_FLAG
                ,DOCUMENTATION_URL
                FROM CZ_ARCHIVES
                WHERE archive_id = p_archive_id;

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_ARCHIVE_ID_EXCP;
           END IF;

           --Create Repository Entry

	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
			,x_new_archive_id
	                ,p_encl_folder_id
			,NAME||' - '||TO_CHAR(x_new_archive_id)
	    ,DESCRIPTION
	    ,NOTES
	                ,'0'
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id= p_archive_id AND object_type='ARC'
	   AND deleted_flag='0';

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_ARCHIVE_ID_EXCP;
           END IF;

       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN INVALID_ARCHIVE_ID_EXCP THEN
        handle_Error(p_message_name   => 'CZ_COPY_ARC_INV_ID',
                     p_token_name1    => 'OBJID',
                     p_token_value1   => TO_CHAR(p_archive_id),
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_archive',
                    p_error_message   => SQLERRM,
                    x_return_status   => x_return_status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => x_msg_data);
END copy_archive;

-------------------------- copy_ui_template ----------------------------
FUNCTION get_Attribute_Value(p_node      IN xmldom.DOMNode,
                             p_attr_name IN VARCHAR2) RETURN VARCHAR2 IS

    l_node_map_tbl xmldom.DOMNamedNodeMap;
    l_node_attr    xmldom.DOMNode;
    l_attr_value   VARCHAR2(32000);
    l_length       NUMBER;

  BEGIN

    IF xmldom.IsNull(p_node) THEN
      RETURN NULL;
    END IF;
    l_node_map_tbl := xmldom.getAttributes(p_node);

    IF (xmldom.isNull(l_node_map_tbl) = FALSE) THEN
      l_length := xmldom.getLength(l_node_map_tbl);
      --
      -- loop through attributes
      --
      FOR i IN 0 .. l_length - 1
      LOOP
        l_node_attr := xmldom.item(l_node_map_tbl, i);
        IF xmldom.getNodeName(l_node_attr) = p_attr_name THEN
          l_attr_value := xmldom.getNodeValue(l_node_attr);
          EXIT;
        END IF;
      END LOOP;
    END IF;
    RETURN l_attr_value;
  END get_Attribute_Value;

FUNCTION get_User_Attribute(p_user_attribute_value IN VARCHAR2,
                            p_cz_attribute_name    IN VARCHAR2)
    RETURN VARCHAR2 IS

    l_ind1    NUMBER;
    l_ind2    NUMBER;
    l_substr  VARCHAR2(32000);

  BEGIN
    l_ind1 := INSTR(p_user_attribute_value,p_cz_attribute_name);

    IF l_ind1 > 0 THEN
      l_substr := SUBSTR(p_user_attribute_value,l_ind1+LENGTH(p_cz_attribute_name)+LENGTH('='));
      l_ind2 := INSTR(l_substr, '|');
      IF l_ind2 > 0 THEN
        RETURN SUBSTR(l_substr,1,l_ind2-1);
      ELSE
        RETURN l_substr;
      END IF;
    ELSE
      RETURN NULL;
    END IF;
  END get_User_Attribute;

PROCEDURE set_Attribute(p_dom_element     xmldom.DOMElement,
                        p_attribute_name  IN VARCHAR2,
                        p_attribute_value IN VARCHAR2) IS

BEGIN
  xmldom.setAttribute(p_dom_element, p_attribute_name, p_attribute_value);
END set_Attribute;

FUNCTION replace_attrib_value (p_attrib_name IN VARCHAR2,
                               p_attrib_val IN VARCHAR2,
                               p_tag_name   IN VARCHAR2,
                               p_old_switcher_id IN VARCHAR2,
                               p_new_document_name IN VARCHAR2)
RETURN VARCHAR2
IS
  l_new_seq     NUMBER;
  l_attrib_val  VARCHAR2(4000);
  l_index       NUMBER;
  l_case_name   VARCHAR2(4000);
  l_new_case_name VARCHAR2(4000);
  l_old_tree_tag_id VARCHAR2(60);
  l_new_tree_tag_id VARCHAR2(60);
BEGIN
  l_attrib_val := '';

  IF ( (p_attrib_name = 'id') ) THEN
    -- check if a new id has already been assigned for this tag. This can happen in two situations
    -- 1. The user:attribute3 containing the switcherDefaultCaseName attribute is processed before
    --    the <oa:switcher id attribute
    -- 2. In case of <oa:stackLayout immediately following the <ui:case. There is always a
    --    <oa:stackLayout following a <ui:case
    IF ( g_attribute_map.EXISTS(p_attrib_val) ) THEN
      l_attrib_val := g_attribute_map(p_attrib_val);
    ELSE
      SELECT cz_ui_page_elements_s.nextval INTO l_new_seq FROM dual;
      l_attrib_val := '_czc'||l_new_seq;
      g_attribute_map(p_attrib_val) := l_attrib_val;
    END IF;

  ELSIF (p_tag_name = 'switcher' AND p_attrib_name = 'user:attribute3') THEN
    -- replace the defaultCaseName attribute on the switcher, if present
    l_case_name := get_User_Attribute(p_attrib_val, 'switcherDefaultCaseName');
    IF ( l_case_name IS NOT NULL ) THEN
      -- get the new switcher id
      IF ( g_attribute_map.EXISTS(p_old_switcher_id) ) THEN
        l_attrib_val := g_attribute_map(p_old_switcher_id);
      ELSE
        -- This case can happen when user:attribute3 is processed before the id attribute
        -- We have no control over the order in which these attributes are returned.
        -- So this case can occur. Since id is not yet processed we dont have the new id
        -- So let us just create a new id for the switcher right now and put it in the map
        SELECT cz_ui_page_elements_s.nextval INTO l_new_seq FROM dual;
        -- this is the new id attribute value for the switcher.
        -- We will put it in the map so that it gets used when processing the id attribute in the
        -- first If block in this function
        l_attrib_val := '_czc'||l_new_seq;

        g_attribute_map(p_old_switcher_id) := l_attrib_val;
      END IF;

      -- form the new case name by replacing the old switcher id with the new one
      l_new_case_name := REPLACE(l_case_name, p_old_switcher_id, l_attrib_val);
      -- replace the case value in user attribute with the new one
      l_attrib_val := REPLACE(p_attrib_val,'switcherDefaultCaseName=' || l_case_name, 'switcherDefaultCaseName=' || l_new_case_name);

    ELSE
      l_attrib_val := p_attrib_val;
    END IF;

  ELSIF (p_tag_name = 'case' AND p_attrib_name = 'name') THEN

    l_case_name := p_attrib_val;
    -- get the new switcher id. If we don't find the switcher id in the map, then it would
    -- be either because of a code bug or data corruption. Therefore not protecting the
    -- fetch using an EXISTS check

    l_attrib_val := g_attribute_map(p_old_switcher_id);

    -- form the new case name by replacing the old switcher id with the new one
    l_attrib_val := REPLACE(l_case_name, p_old_switcher_id, l_attrib_val);

    g_attribute_map(p_attrib_val) := l_attrib_val;

  ELSIF (p_attrib_name = 'ancestorNode') THEN

      l_index := INSTR(p_attrib_val, '.');
      l_old_tree_tag_id := SUBSTR(p_attrib_val, l_index+1);
      -- By the time the ancestorNode attribute is processed, we will have already seen
      -- and processed the <oa:tree tag and its id attribute. This id attribute should
      -- be in the map already

      l_new_tree_tag_id := g_attribute_map(l_old_tree_tag_id);
      l_attrib_val := p_new_document_name || '.' || l_new_tree_tag_id;

  ELSE
    -- not an attribute we are interested in
    RETURN p_attrib_val;
  END IF;

  RETURN  l_attrib_val;
END;

---------------------
function createElement (p_namespace IN OUT NOCOPY VARCHAR2,
			      p_tagname   IN VARCHAR2)
RETURN jdr_docbuilder.ELEMENT
IS
  l_child_element   jdr_docbuilder.ELEMENT;

BEGIN
 IF (p_namespace IS NULL) THEN
	p_namespace := 'jrad:';
 END IF;
 l_child_element := jdr_docbuilder.createElement(p_namespace,p_tagname);
 RETURN l_child_element;
EXCEPTION
WHEN OTHERS THEN
   RAISE;
END;

-----------------------

FUNCTION replace_global_ids(p_user_attr_value IN VARCHAR2,
                            p_new_template_id IN NUMBER) RETURN VARCHAR2 IS

  l_user_attribute_value VARCHAR2(4000);

  FUNCTION replace_global_ids(p_attribute_value IN VARCHAR2, p_id_type VARCHAR2) RETURN VARCHAR2 IS

    l_tkn_start             NUMBER;
    l_attr_end_ind          NUMBER := 1;
    l_token                 VARCHAR2(20);
    l_length_of_tkn         NUMBER;
    l_elementId_str         VARCHAR2(255);
    l_element_id            NUMBER;
    l_persistent_element_id NUMBER;
    l_rule_folder_id        NUMBER;
    l_new_element_id        NUMBER;
    l_new_user_attr_value   VARCHAR2(4000) := NULL;
    l_return_status         VARCHAR2(1);
    l_run_id                NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN
    -- Get the start of the first 'CondnId' attribute
    IF ( p_id_type = G_RULE_TYPE ) THEN
      l_token := 'CondnId=';
    ELSIF ( p_id_type = G_INTL_TEXT_TYPE ) THEN
      l_token := 'IntlTextId=';
    ELSE
      l_token := 'actionId=';
    END IF;

    l_length_of_tkn := length(l_token);

    l_tkn_start := instr(p_attribute_value, l_token);

    l_new_user_attr_value := '';

    IF (l_tkn_start > 0) THEN
      LOOP
        -- If no Token found then exit the loop
        IF (l_tkn_start < 1) THEN
          IF ( l_attr_end_ind > 0 ) THEN
            -- The last part of the string is yet to be added
            l_new_user_attr_value := l_new_user_attr_value || SUBSTR(p_attribute_value, l_attr_end_ind);
          END IF;
          EXIT;
        END IF;

        -- move the start pointer to the start of the actual Rule Id
        l_tkn_start := l_tkn_start + l_length_of_Tkn;

        -- save the part from the end of previous CondnId values to start of this CondnId attribute
        l_new_user_attr_value := l_new_user_attr_value || SUBSTR(p_attribute_value, l_attr_end_ind, (l_tkn_start-l_attr_end_ind));

        -- Look for the delimiter Pipe character
        l_attr_end_ind := INSTR(p_attribute_value, '|', l_tkn_start);

        IF l_attr_end_ind > 0 THEN
          -- Delimiter found; extract the Rule Id and move the l_tkn_start the start of the
          -- next CondnId token
          l_elementId_str := SUBSTR(p_attribute_value, l_tkn_start, l_attr_end_ind-l_tkn_start);
          l_tkn_start := INSTR(p_attribute_value, l_token, l_attr_end_ind);
        ELSE
          -- Delimiter not found, which means we are at the end of the user:attribute
          -- Obviously there won't be any more CondnId tokens, so set l_tkn_start to -1
          l_elementId_str := SUBSTR(p_attribute_value, l_tkn_start);
          l_tkn_start := -1;
        END IF;

        -- now we have the RuleId in l_condnId_str
        l_persistent_element_id := TO_NUMBER(l_elementId_str);

        -- In case of Global source templates elements (element_id = persistent_element_id) is true
        -- This assumes that element_id is always = persistent_element_id in case of a source
        -- template_id regardless of how the template got created (developer, copy or migration)
        l_element_id := l_persistent_element_id;

        IF( g_element_type_tbl.EXISTS(p_id_type || l_element_id) ) THEN

          IF ( p_id_type = G_RULE_TYPE ) THEN

            SELECT rule_folder_id INTO l_rule_folder_id
            FROM  cz_rules
            WHERE cz_rules.rule_id = l_element_id
            AND   cz_rules.deleted_flag = '0';


            cz_developer_utils_pvt.copy_Rule (l_element_id,
                                              l_rule_folder_id,
                                              FND_API.G_TRUE,
                                              l_new_element_id,
                                              l_run_id,
                                              l_return_status,
                                              l_msg_count,
                                              l_msg_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE COPY_RULE_FAILURE;
            END IF;

          ELSIF ( p_id_type = G_INTL_TEXT_TYPE ) THEN

            l_new_element_id := copy_INTL_TEXT(l_element_id);

            IF l_new_element_id = -1 THEN
              RAISE NO_TXT_FOUND_EXCP;
            END IF;

          ELSE

            SELECT cz_ui_actions_s.nextval INTO l_new_element_id  FROM dual;

            INSERT INTO CZ_UI_ACTIONS
              (UI_ACTION_ID,UI_DEF_ID,SOURCE_PAGE_ID,CONTEXT_COMPONENT_ID,ELEMENT_ID,RENDER_CONDITION_ID,
              UI_ACTION_TYPE,TARGET_UI_DEF_ID,TARGET_PERSISTENT_NODE_ID,TARGET_NODE_PATH,TARGET_PAGE_SET_ID,
              TARGET_PAGE_ID,TARGET_URL,FRAME_NAME,TARGET_ANCHOR,DELETED_FLAG,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
              LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,SEEDED_FLAG,CX_COMMAND_NAME,WINDOW_PARAMETERS,TARGET_WINDOW_TYPE,TARGET_WINDOW_NAME,
              TARGET_EXPL_NODE_ID,URL_PROPERTY_ID )
              SELECT l_new_element_id,UI_DEF_ID,SOURCE_PAGE_ID,CONTEXT_COMPONENT_ID,ELEMENT_ID,RENDER_CONDITION_ID,
                UI_ACTION_TYPE,TARGET_UI_DEF_ID,TARGET_PERSISTENT_NODE_ID,TARGET_NODE_PATH,TARGET_PAGE_SET_ID,
                TARGET_PAGE_ID,TARGET_URL,FRAME_NAME,TARGET_ANCHOR,DELETED_FLAG,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
                LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,SEEDED_FLAG,CX_COMMAND_NAME,WINDOW_PARAMETERS,TARGET_WINDOW_TYPE,TARGET_WINDOW_NAME,
                TARGET_EXPL_NODE_ID,URL_PROPERTY_ID FROM CZ_UI_ACTIONS
              WHERE ui_def_id = 0
              AND UI_ACTION_ID = l_element_id;

          END IF;

          INSERT
          INTO cz_ui_template_elements (TEMPLATE_ID,
                                        UI_DEF_ID,
                                        ELEMENT_TYPE,
                                        ELEMENT_ID,
                                        PERSISTENT_ELEMENT_ID,
                                        DELETED_FLAG,
                                        SEEDED_FLAG)
          VALUES (p_new_template_id,
                  0,
                  g_element_type_tbl(p_id_type || l_element_id),
                  l_new_element_id,
                  l_new_element_id,
                  '0',
                  '0');
        ELSE
          -- This can happen in case of seeded template elements
          -- Seeded template elements do not have a record in cz_ui_template_elements
          -- In such a case we do not create the new template_element record
          -- and continue using the same element_id
          l_new_element_id := l_element_id;

        END IF; -- if element_id exists in g_element_type_tbl

        -- l_newuser_attr_value is not like "....xxxxxxCondnId="
        -- Add the new rule_id to the end of this
        l_new_user_attr_value := l_new_user_attr_value || l_new_element_id;

      END LOOP;
    ELSE
      l_new_user_attr_value := p_attribute_value;
    END IF;
    RETURN l_new_user_attr_value;

  END replace_global_ids;

BEGIN

   l_user_attribute_value := replace_global_ids(p_user_attr_value, G_RULE_TYPE);
   l_user_attribute_value := replace_global_ids(l_user_attribute_value, G_INTL_TEXT_TYPE);
   l_user_attribute_value := replace_global_ids(l_user_attribute_value, G_UI_ACTION_TYPE);

   RETURN l_user_attribute_value;

END replace_global_ids;

-----

PROCEDURE copyAttributes(p_source_node IN xmldom.DOMNode,
                         p_dest_element IN jdr_docbuilder.ELEMENT,
                         p_new_template_id IN NUMBER,
                         p_new_document_name IN VARCHAR2,
                         p_old_switcher_id IN VARCHAR2)
IS

  l_attributes    xmldom.DOMNamedNodeMap;
  l_attrib_node   xmldom.DOMNode;
  l_attrib_count  NUMBER := 0;
  l_tagname       VARCHAR2(255);
  attrname        VARCHAR2(255);
  attrval         VARCHAR2(4000);
  l_ampers        VARCHAR2(1) := fnd_global.local_chr(38);

BEGIN

  l_attributes    := xmldom.getAttributes(p_source_node);
  l_tagname       := SUBSTR(xmldom.getNodeName(p_source_node),INSTR(xmldom.getNodeName(p_source_node),':') + 1);

  l_attrib_count := xmldom.getLength(l_attributes);

  IF (l_attrib_count > 0) then
    FOR attrCount IN 0..l_attrib_count - 1
    LOOP
      l_attrib_node := xmldom.item(l_attributes,attrCount);
      attrname      := xmldom.getNodeName(l_attrib_node);
      attrval       := xmldom.getNodeValue(l_attrib_node);

      IF ( attrname = 'user:attribute3' ) THEN
        -- user:attribute3 can contain global Ids like Rule Ids (for UI Conditions), Intl_text_ids
        -- and Ui_action_ids
        attrval := replace_global_ids(attrval,
                                      p_new_template_id);

      ELSIF ( attrname IN('text','caption','prompt','shortDesc') ) THEN

        IF ( INSTR(attrval,l_ampers) > 0
          AND  INSTR(attrval,l_ampers||'amp') = 0 ) THEN
          attrval    := REPLACE(attrval, l_ampers, l_ampers||'amp;');
        END IF;

        attrval       := REPLACE(attrval, '<',  l_ampers||'lt;');
        attrval 	  := REPLACE(attrval, '"',  l_ampers||'quot;');
        attrval       := REPLACE(attrval, '''', l_ampers||'apos;');

      END IF;

      attrval := replace_attrib_value (attrname,attrval,l_tagname,p_old_switcher_id,p_new_document_name);

      jdr_docbuilder.setAttribute(p_dest_element,attrname,attrval);

    END LOOP;
  END IF;

END copyAttributes;


PROCEDURE exploreTree(p_new_template_id IN NUMBER,
                      p_new_document_name VARCHAR2,
                      p_jrad_parent_element IN jdr_docbuilder.ELEMENT,
                      p_dom_parent_element  IN xmldom.DOMNode,
                      p_grouping_tag        IN VARCHAR2,
                      p_enclosing_switcher_id IN VARCHAR2)
IS

  l_child_nodes      xmldom.DOMNodeList;
  l_child_node       xmldom.DOMNode;
  l_parent_xml_node  xmldom.DOMNode;
  l_child_count      NUMBER := 0;
  l_namespace        VARCHAR2(255);
  l_tagname          VARCHAR2(255);
  l_tag_name         VARCHAR2(255);
  l_groupingNS       VARCHAR2(255);
  l_groupingTagName  VARCHAR2(255);
  l_grouping_tag     VARCHAR2(255);
  l_child_element    jdr_docbuilder.ELEMENT;
  l_parent_tag_name  VARCHAR2(255);
  l_old_switcher_id  VARCHAR2(60);
  l_attributes       xmldom.DOMNamedNodeMap;
  l_attrib_count     NUMBER := 0;

BEGIN
  l_child_nodes    := xmldom.getChildNodes(p_dom_parent_element);
  l_child_count    := xmldom.getLength(l_child_nodes);

  IF (l_child_count > 0) THEN
    FOR childCount IN 0..l_child_count - 1
    LOOP
      l_child_node   := xmldom.item(l_child_nodes,childCount);
      l_grouping_tag :='';
      l_tag_name     := xmldom.getNodeName(l_child_node);
      l_parent_xml_node := xmldom.getParentNode(l_child_node);

      l_attributes   := xmldom.getAttributes(l_child_node);
      l_attrib_count := xmldom.getLength(l_attributes);

      l_old_switcher_id := p_enclosing_switcher_id;

      IF (l_tag_name = 'oa:switcher') THEN
        l_old_switcher_id := get_Attribute_value(l_child_node, 'id');
      END IF;

      IF NOT(xmldom.isNull(l_parent_xml_node)) THEN
        l_parent_tag_name := xmldom.getNodeName(l_parent_xml_node);
      END IF;

      IF ( (l_attrib_count = 0) AND (l_tag_name not in ('ui:firePartialAction') ) ) THEN
        l_grouping_tag := l_tag_name;
      END IF;

      l_namespace     := SUBSTR(xmldom.getNodeName(l_child_node),1,INSTR(xmldom.getNodeName(l_child_node),':'));
      l_tagname       := SUBSTR(xmldom.getNodeName(l_child_node),INSTR(xmldom.getNodeName(l_child_node),':') + 1);
      l_child_element := createElement(l_namespace,l_tagname);

      copyAttributes(l_child_node,
                     l_child_element,
                     p_new_template_id,
                     p_new_document_name,
                     l_old_switcher_id);

      IF (p_grouping_tag IS NOT NULL) THEN

        l_groupingNS      :=SUBSTR(p_grouping_tag,1,INSTR(p_grouping_tag,':'));
        l_groupingTagName :=SUBSTR(p_grouping_tag,INSTR(p_grouping_tag,':')+1);

        IF (l_groupingNS IS NULL) THEN l_groupingNS := 'jrad:'; END IF;

        jdr_docbuilder.AddChild(p_jrad_parent_element,l_groupingNS,l_groupingTagName,l_child_element);
        exploreTree(p_new_template_id, p_new_document_name, l_child_element,l_child_node,l_grouping_tag,l_old_switcher_id);

      ELSE

        IF (l_grouping_tag IS NULL) THEN
          jdr_docbuilder.AddChild(p_jrad_parent_element,l_child_element);
          exploreTree(p_new_template_id, p_new_document_name, l_child_element,l_child_node,l_grouping_tag,l_old_switcher_id);
        ELSE
          exploreTree(p_new_template_id, p_new_document_name, p_jrad_parent_element,l_child_node,l_grouping_tag,l_old_switcher_id);
        END IF;

      END IF;

    END LOOP;
  END IF;
END exploreTree;

---------------------
PROCEDURE replace_global_ids_in_XML (p_template_id       IN NUMBER,
			      p_new_template_id   		   IN NUMBER,
			      p_old_document_name 		   IN VARCHAR2,
			      p_new_document_name 		   IN VARCHAR2,
			      x_return_status     		  OUT  NOCOPY   VARCHAR2,
			      x_msg_count         		  OUT  NOCOPY   NUMBER,
			      x_msg_data         		  OUT  NOCOPY   VARCHAR2 )
IS

TYPE char_tbl_type IS TABLE OF VARCHAR2(255);
g_toplevel_attr_tbl  char_tbl_type := char_tbl_type ('version','xml:lang','xmlns:oa',
'xmlns:ui','xmlns:jrad','xmlns:user','xmlns');

DOCUMENT_IS_NULL  EXCEPTION;

l_lob             CLOB;
l_length          BINARY_INTEGER;
l_buffer          VARCHAR2(32767);
firstChunk        VARCHAR2(32767);
p                 xmlparser.parser;
doc               xmldom.DOMDocument;
n                 xmldom.DOMNode;
top_node          xmldom.DOMNODE;
nnm               xmldom.DOMNamedNodeMap;
attrname          VARCHAR2(255);
attrval           VARCHAR2(4000);  -- jdr_attributes.att_value
name_space        VARCHAR2(255);
tag_name          VARCHAR2(255);
l_doc             jdr_docbuilder.DOCUMENT;
top_element       jdr_docbuilder.ELEMENT;
jrad_save_status  PLS_INTEGER;
g_jrad_trans_list jdr_utils.translationlist := jdr_utils.translationlist();
l_exportfinished  BOOLEAN;
BEGIN
    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    jdr_docbuilder.refresh;

    IF (p_old_document_name IS NULL) THEN
	    RAISE DOCUMENT_IS_NULL;
    END IF;

    g_element_type_tbl.DELETE;

    FOR i in (SELECT persistent_element_id,
                     element_type,
                     decode(element_type,
                            552, G_UI_ACTION_TYPE,
                            8, G_INTL_TEXT_TYPE,
                            G_RULE_TYPE) entity_type
              FROM cz_ui_template_elements
              WHERE template_id = p_template_id
              AND ui_def_Id = 0
              AND deleted_flag = '0')
    LOOP
      -- Populate the table as follows
      --   R12345 => 33
      --   R64354 => 34
      --   T12345 => 8
      -- We need to use the prefixes (R,T,A) because the rule_ids, text_ids and action_ids can clash
      -- We use the following table for two purposes
      -- 1. To determine if an id found in the XML has a representation in cz_ui_template_elements
      --    If it does, we copy the cz_ui_tempalte_elements record. If it does not, then the id is
      --    probably a seeded id and we wont create a cz_ui_template_elements record for it.
      -- 2. In case of a UI Condition, to find the rule_type which can be 33 or 34.
      g_element_type_tbl(i.entity_type || TO_CHAR(i.persistent_element_id)) := i.element_type;
    END LOOP;



   SYS.DBMS_LOB.CREATETEMPORARY(l_lob,TRUE,dbms_lob.session);
   SYS.DBMS_LOB.OPEN (l_lob,DBMS_LOB.LOB_READWRITE);
   firstChunk := jdr_utils.EXPORTDOCUMENT(p_old_document_name,l_exportfinished);

   IF (firstChunk IS NULL) THEN
	RAISE DOCUMENT_IS_NULL;
   END IF;

  l_buffer   := LTRIM(RTRIM(firstChunk));
  l_length   := LENGTH(l_buffer);
  BEGIN
    SYS.DBMS_LOB.writeappend(l_lob,l_length,l_buffer);
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  LOOP
      l_buffer := jdr_utils.EXPORTDOCUMENT(NULL,l_exportfinished);
      l_buffer := LTRIM(RTRIM(l_buffer));

      EXIT WHEN l_buffer IS NULL;
      l_length := LENGTH(l_buffer);
      SYS.DBMS_LOB.writeappend(l_lob,l_length,l_buffer);
  END LOOP;

  l_length := SYS.DBMS_LOB.getlength(l_lob);
  p := xmlparser.newParser;
  xmlparser.parseCLOB(p,l_lob);
  doc := xmlparser.getDocument(p);

  SYS.DBMS_LOB.CLOSE (l_lob);
  SYS.DBMS_LOB.FREETEMPORARY(l_lob);

  l_doc := jdr_docbuilder.createDocument(p_new_document_name);
  top_node := xmldom.makeNode(xmldom.getDocumentElement(doc));

  IF (g_toplevel_attr_tbl.COUNT > 0) THEN
    FOR I IN g_toplevel_attr_tbl.FIRST..g_toplevel_attr_tbl.LAST
    LOOP
      begin
        xmldom.removeAttribute(xmldom.makeElement(top_node),g_toplevel_attr_tbl(i));
      exception
        when others then
          NULL;
      end;
    END LOOP;
   END IF;

   name_space:=SUBSTR(xmldom.getNodeName(top_node),1,INSTR(xmldom.getNodeName(top_node),':'));
   tag_name :=SUBSTR(xmldom.getNodeName(top_node),INSTR(xmldom.getNodeName(top_node),':')+1);
   top_element := createElement(name_space,tag_name);
   nnm := xmldom.getAttributes(top_node);

    IF (xmldom.isNull(nnm) = FALSE) then
     l_length := xmldom.getLength(nnm);
     FOR i in 0..l_length-1
     LOOP
        n := xmldom.item(nnm, i);
        attrname := xmldom.getNodeName(n);
        attrval := xmldom.getNodeValue(n);
       IF( attrname = 'user:attribute10' ) THEN
         -- Have to check for user:attribute3
         attrval := replace_global_ids(attrval, p_new_template_id);
       END IF;
	  jdr_docbuilder.setAttribute(top_element,attrname,attrval);
        END LOOP;
    END IF;

   jdr_docbuilder.setTopLevelElement(l_doc,top_element);

   g_attribute_map.DELETE;

   exploreTree(p_new_template_id, p_new_document_name, top_element, top_node,'',' ');

   jrad_save_status := jdr_docbuilder.SAVE;
   xmlparser.freeParser(p);
   g_jrad_trans_list := jdr_utils.translationList();
   g_jrad_trans_list := jdr_utils.getTranslations(p_old_document_name);
   IF (g_jrad_trans_list IS NOT NULL) THEN
      jdr_utils.saveTranslations(p_new_document_name,g_jrad_trans_list);
   END IF;
   jdr_docbuilder.refresh;
EXCEPTION
WHEN DOCUMENT_IS_NULL THEN
     NULL;

WHEN COPY_RULE_FAILURE THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE;
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE;
END replace_global_ids_in_XML ;

--------------------------------------------------------
PROCEDURE copy_ui_template
(
p_template_id      IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_template_id  OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

--  l_api_version                  CONSTANT NUMBER := 1.0;
--  l_api_name                     CONSTANT VARCHAR2(30) := 'copy_ui_template';
  l_jrad_doc                     CZ_UI_TEMPLATES.jrad_doc%TYPE;
  l_copied_jrad_doc              CZ_UI_TEMPLATES.jrad_doc%TYPE;
  INVALID_TEMPLATE_ID_EXCP       EXCEPTION;
  l_name             	         cz_rp_entries.name%TYPE;
  l_title_id                     NUMBER;
  l_main_message_id              NUMBER;
  l_old_title_id                 NUMBER;
  l_old_main_message_id          NUMBER;
  l_index                        NUMBER;
  l_template_type                NUMBER;
  l_template_name                cz_ui_templates.template_name%TYPE;
  l_templates                    cz_security_pvt.number_type_tbl;
  l_locked_templates             cz_security_pvt.number_type_tbl;
  l_return_status                VARCHAR2(1);
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  FAILED_TO_LOCK_UCT             EXCEPTION;

BEGIN
       SELECT jrad_doc, template_name, template_type
       INTO l_jrad_doc, l_template_name, l_template_type
       FROM CZ_UI_TEMPLATES
       WHERE ui_def_id=0 AND template_id=p_template_id;

       l_templates(1) := p_template_id;
       cz_security_pvt.lock_template(
                      p_api_version           =>   1.0,
		     	    p_templates_to_lock     =>   l_templates,
			    p_commit_flag           =>   FND_API.G_FALSE,
                      p_init_msg_list         =>   FND_API.G_FALSE,
                      x_locked_templates      =>   l_locked_templates,
		  	    x_return_status         =>   x_return_status,
			    x_msg_count             =>   x_msg_count,
			    x_msg_data              =>   x_msg_data);
       IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FAILED_TO_LOCK_UCT;
       END IF;
       x_new_template_id := allocateId('CZ_UI_TEMPLATES_S');
       l_name := copy_name(p_template_id,'UCT');

       -- The jrad_doc is broken up into pieces (paths and fileName) and saved in
       -- jdr_paths.path_name. jdr_paths.path_name is a varchar2(60) type. So the fileName
       -- cannot exceed 60 characters. So we cannot keep adding the template_id
       -- to the jrad_doc on every copy. We will create the fileName just like Developer
       -- does <template_id>_<template_type>

       -- look for the last '/'
       l_index := INSTR(l_jrad_doc, '/', -1);

       l_copied_jrad_doc := SUBSTR(l_jrad_doc, 1, l_index)
                             || TO_CHAR(x_new_template_id) || '_' || TO_CHAR(l_template_type);

       -- Copy corresponding JRAD document

	 replace_global_ids_in_XML (p_template_id,
				    x_new_template_id,
			      	    l_jrad_doc,
			      	    l_copied_jrad_doc,
			      	    x_return_status,
			      	    x_msg_count,
			      	    x_msg_data);

       INSERT INTO CZ_UI_TEMPLATES(
                 TEMPLATE_ID
                ,UI_DEF_ID
                ,TEMPLATE_NAME
                ,TEMPLATE_TYPE
                ,TEMPLATE_DESC
                ,PARENT_CONTAINER_TYPE
                ,JRAD_DOC
                ,BUTTON_BAR_TEMPLATE_ID
                ,MESSAGE_TYPE
                ,MAIN_MESSAGE_ID
                ,TITLE_ID
                ,DELETED_FLAG
                ,SEEDED_FLAG
                ,LAYOUT_UI_STYLE
                ,ROOT_REGION_TYPE
                ,BUTTON_BAR_TEMPL_UIDEF_ID
		,ROOT_ELEMENT_SIGNATURE_ID
                ,AMN_USAGE
                )
                SELECT
		    x_new_template_id
                ,UI_DEF_ID
                ,l_name
                ,TEMPLATE_TYPE
		    ,TEMPLATE_DESC
                ,PARENT_CONTAINER_TYPE
        	    ,l_copied_jrad_doc
                ,BUTTON_BAR_TEMPLATE_ID
                ,MESSAGE_TYPE
                ,MAIN_MESSAGE_ID
                ,TITLE_ID
                ,DELETED_FLAG
                     ,'0'
                ,LAYOUT_UI_STYLE
                ,ROOT_REGION_TYPE
                ,BUTTON_BAR_TEMPL_UIDEF_ID
		,ROOT_ELEMENT_SIGNATURE_ID
                ,AMN_USAGE
                FROM CZ_UI_TEMPLATES
                WHERE ui_def_id=0 AND template_id = p_template_id;

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_TEMPLATE_ID_EXCP;
           END IF;

	     -----create new title id and main message id fix for bug# 3939234
		SELECT title_id, main_message_id
		INTO  l_old_title_id, l_old_main_message_id
		FROM  cz_ui_templates
		WHERE template_id = p_template_id
		AND   ui_def_id = 0;

		IF (l_old_title_id IS NOT NULL) THEN
     	          l_title_id := copy_INTL_TEXT(l_old_title_id);
		END IF;

		IF (l_old_main_message_id IS NOT NULL) THEN
               l_main_message_id := copy_INTL_TEXT(l_old_main_message_id);
		END IF;

     	      UPDATE cz_ui_templates
		SET   title_id 	    = l_title_id,
			main_message_id = l_main_message_id
     		WHERE  template_id     = x_new_template_id
		AND   ui_def_id       = 0;


	     -- Create Template Refs

           INSERT INTO CZ_UI_REF_TEMPLATES
           (
           TEMPLATE_ID
           ,REF_TEMPLATE_ID
           ,DELETED_FLAG
           ,TEMPLATE_UI_DEF_ID
           ,REF_TEMPLATE_UI_DEF_ID
	     ,SEEDED_FLAG
	     ,REF_TEMPL_SEEDED_FLAG
             ,REF_COUNT
           )
           SELECT
            x_new_template_id
            ,REF_TEMPLATE_ID
            ,DELETED_FLAG
            ,0
            ,REF_TEMPLATE_UI_DEF_ID
		,'0'
		,REF_TEMPL_SEEDED_FLAG
                ,REF_COUNT
           FROM CZ_UI_REF_TEMPLATES
           WHERE template_id=p_template_id AND
                 template_ui_def_id=0 AND
                 deleted_flag='0';

           --Create Repository Entry

	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
	      ,x_new_template_id
	      ,p_encl_folder_id
		,l_name
	    ,DESCRIPTION
	    ,NOTES
	                ,'0'
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id= p_template_id AND object_type='UCT'
	   AND deleted_flag='0';

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_TEMPLATE_ID_EXCP;
           END IF;
           IF ( l_locked_templates.COUNT > 0 ) THEN
              cz_security_pvt.unlock_template(
                            p_api_version           =>   1.0,
		     	    p_templates_to_unlock   =>   l_locked_templates,
			    p_commit_flag           =>   FND_API.G_FALSE,
                            p_init_msg_list         =>   FND_API.G_FALSE,
		  	    x_return_status         =>   x_return_status,
			    x_msg_count             =>   x_msg_count,
			    x_msg_data              =>   x_msg_data);
           END IF;
           x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN INVALID_TEMPLATE_ID_EXCP THEN
       handle_Error(p_message_name   => 'CZ_COPY_UCT_INV_ID',
                    p_token_name1    => 'OBJID',
                    p_token_value1   => TO_CHAR(p_template_id),
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
WHEN FAILED_TO_LOCK_UCT THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     add_error_message(p_message_name   => 'CZ_CP_CANNOT_LOC_UCT',
                       p_token_name1    => 'UICTNAME',
                       p_token_value1   => l_template_name);
     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_ui_template',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
       IF ( l_locked_templates.COUNT > 0 ) THEN
         cz_security_pvt.unlock_template(p_api_version           =>   1.0,
                                         p_templates_to_unlock   =>   l_locked_templates,
                                         p_commit_flag           =>   FND_API.G_FALSE,
                                         p_init_msg_list         =>   FND_API.G_FALSE,
                                         x_return_status         =>   l_return_status,
                                         x_msg_count             =>   l_msg_count,
                                         x_msg_data              =>   l_msg_data);

         -- propogate the status from unlock template only in case of an error during unlock
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           x_msg_count := l_msg_count;
           x_msg_data := l_msg_data;
         END IF;

       END IF;
END copy_ui_template;

----------------------------------------------------------------------
PROCEDURE copy_ui_master_template
(
p_ui_def_id        IN   NUMBER,
p_encl_folder_id   IN   NUMBER,
x_new_ui_def_id        OUT  NOCOPY   NUMBER,
x_return_status    OUT  NOCOPY   VARCHAR2,
x_msg_count        OUT  NOCOPY   NUMBER,
x_msg_data         OUT  NOCOPY   VARCHAR2
) IS

  l_api_version           CONSTANT NUMBER := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'copy_ui_master_template';
  INVALID_UIDEF_ID_EXCP   EXCEPTION;
  l_name	            cz_rp_entries.name%TYPE;

BEGIN
          x_new_ui_def_id := allocateId('CZ_UI_DEFS_S');
          l_name := copy_name(p_ui_def_id,'UMT');
	  INSERT INTO CZ_UI_DEFS(
             UI_DEF_ID
            ,DESC_TEXT
	    ,NAME
	    ,DEVL_PROJECT_ID
	    ,COMPONENT_ID
	    ,TREE_SEQ
	    ,DELETED_FLAG
	    ,EFF_FROM
	    ,EFF_TO
	    ,SECURITY_MASK
	    ,EFF_MASK
	    ,UI_STYLE
	    ,GEN_VERSION
	    ,TREENODE_DISPLAY_SOURCE
	    ,GEN_HEADER
	    ,LOOK_AND_FEEL
	    ,CONTROLS_PER_SCREEN
	    ,PRIMARY_NAVIGATION
	    ,PERSISTENT_UI_DEF_ID
	    ,MODEL_TIMESTAMP
	    ,UI_STATUS
	    ,PAGE_SET_ID
	    ,START_PAGE_ID
	    ,ERR_RUN_ID
	    ,START_URL
	    ,PAGE_LAYOUT
	    ,PRICE_UPDATE
            ,SEEDED_FLAG
	    ,MASTER_TEMPLATE_FLAG
	    ,PRICE_DISPLAY
	    ,FROM_MASTER_TEMPLATE_ID
	    ,PAGIN_MAXCONTROLS
	    ,PAGIN_NONINST
	    ,PAGIN_NONINST_REFCOMP
	    ,CONTROL_LAYOUT
	    ,PAGIN_DRILLDOWNCTRL
	    ,OUTER_TEMPLATE_USAGE
	    ,PAGIN_BOMOC
	    ,BOMUI_LAYOUT
	    ,BOMQTYINPUTCTRLS
	    ,CTRLTEMPLUSE_BOM
	    ,CTRLTEMPLUSE_NONBOM
	    ,NONBOM_UILAYOUT
	    ,CTRLTEMPLUSE_COMMON
	    ,CTRLTEMPLUSE_REQDMSG
	    ,CTRLTEMPLUSE_OPTMSG
	    ,MENU_CAPTION_RULE_ID
	    ,PAGE_CAPTION_RULE_ID
	    ,PRESERVE_MODEL_HIERARCHY
	    ,EMPTY_UI_FLAG
	    ,SHOW_TRAIN
	    ,PAGINATION_SLOT
	    ,DRILLDOWN_CONTROL_TEXT_ID
	    ,DRILLDOWN_IMAGE_URL
	    ,ROWS_PER_TABLE
	    ,CTRLTEMPLATEUSE_BUTTONBAR
	    ,CTRLTEMPLATEUSE_UTILITYPAGE
	    ,OPTION_SORT_SELECT_FIRST
	    ,OPTION_SORT_ORDER
	    ,OPTION_SORT_METHOD
	    ,OPTION_SORT_PROPERTY_ID
	    ,SHOW_ALL_NODES_FLAG
             )
          SELECT
		       x_new_ui_def_id
            ,DESC_TEXT
                      ,l_name
	    ,DEVL_PROJECT_ID
	    ,COMPONENT_ID
	    ,TREE_SEQ
	    ,DELETED_FLAG
	    ,EFF_FROM
	    ,EFF_TO
	    ,SECURITY_MASK
	    ,EFF_MASK
	    ,UI_STYLE
	    ,GEN_VERSION
	    ,TREENODE_DISPLAY_SOURCE
	    ,GEN_HEADER
	    ,LOOK_AND_FEEL
	    ,CONTROLS_PER_SCREEN
	    ,PRIMARY_NAVIGATION
	    ,PERSISTENT_UI_DEF_ID
	    ,MODEL_TIMESTAMP
	    ,UI_STATUS
	    ,PAGE_SET_ID
	    ,START_PAGE_ID
	    ,ERR_RUN_ID
	    ,START_URL
	    ,PAGE_LAYOUT
	    ,PRICE_UPDATE
	               ,'0'
	    ,MASTER_TEMPLATE_FLAG
	    ,PRICE_DISPLAY
	    ,FROM_MASTER_TEMPLATE_ID
	    ,PAGIN_MAXCONTROLS
	    ,PAGIN_NONINST
	    ,PAGIN_NONINST_REFCOMP
	    ,CONTROL_LAYOUT
	    ,PAGIN_DRILLDOWNCTRL
	    ,OUTER_TEMPLATE_USAGE
	    ,PAGIN_BOMOC
	    ,BOMUI_LAYOUT
	    ,BOMQTYINPUTCTRLS
	    ,CTRLTEMPLUSE_BOM
	    ,CTRLTEMPLUSE_NONBOM
	    ,NONBOM_UILAYOUT
	    ,CTRLTEMPLUSE_COMMON
	    ,CTRLTEMPLUSE_REQDMSG
	    ,CTRLTEMPLUSE_OPTMSG
	    ,MENU_CAPTION_RULE_ID
	    ,PAGE_CAPTION_RULE_ID
	    ,PRESERVE_MODEL_HIERARCHY
	    ,EMPTY_UI_FLAG
	    ,SHOW_TRAIN
	    ,PAGINATION_SLOT
	    ,DRILLDOWN_CONTROL_TEXT_ID
	    ,DRILLDOWN_IMAGE_URL
	    ,ROWS_PER_TABLE
	    ,CTRLTEMPLATEUSE_BUTTONBAR
	    ,CTRLTEMPLATEUSE_UTILITYPAGE
	    ,OPTION_SORT_SELECT_FIRST
	    ,OPTION_SORT_ORDER
	    ,OPTION_SORT_METHOD
	    ,OPTION_SORT_PROPERTY_ID
	    ,SHOW_ALL_NODES_FLAG
          FROM CZ_UI_DEFS
          WHERE ui_def_id = p_ui_def_id;

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_UIDEF_ID_EXCP;
           END IF;

         -- Create ui content type templates for this newly copied ui def

         INSERT INTO CZ_UI_CONT_TYPE_TEMPLS(
	    UI_DEF_ID
	   ,CONTENT_TYPE
	   ,TEMPLATE_ID
	   ,DELETED_FLAG
	   ,MASTER_TEMPLATE_FLAG
	   ,SEEDED_FLAG
	   ,TEMPLATE_UI_DEF_ID
	   ,WRAP_TEMPLATE_FLAG
           )
         SELECT
	         x_new_ui_def_id
	   ,CONTENT_TYPE
	   ,TEMPLATE_ID
	   ,DELETED_FLAG
	   ,MASTER_TEMPLATE_FLAG
	        ,'0'
	   ,TEMPLATE_UI_DEF_ID
	   ,WRAP_TEMPLATE_FLAG
         FROM CZ_UI_CONT_TYPE_TEMPLS
         WHERE ui_def_id = p_ui_def_id;

         -- Create ui images for this newly copied ui def
         INSERT INTO CZ_UI_IMAGES
         (
         UI_DEF_ID
         ,MASTER_TEMPLATE_FLAG
         ,IMAGE_USAGE_CODE
         ,IMAGE_FILE
         ,DELETED_FLAG
         ,SEEDED_FLAG
         ,ENTITY_CODE
         )
         SELECT
           x_new_ui_def_id
           ,MASTER_TEMPLATE_FLAG
           ,IMAGE_USAGE_CODE
           ,IMAGE_FILE
           ,DELETED_FLAG
           ,'0'
           ,ENTITY_CODE
         FROM CZ_UI_IMAGES
         WHERE ui_def_id = p_ui_def_id AND deleted_flag='0';

         --Create Repository Entry

	   INSERT INTO CZ_RP_ENTRIES
	   (
	    OBJECT_TYPE
	    ,OBJECT_ID
	    ,ENCLOSING_FOLDER
	    ,NAME
	    ,DESCRIPTION
	    ,NOTES
	    ,SEEDED_FLAG
	    ,DELETED_FLAG
	   )
	   SELECT
	     OBJECT_TYPE
			,x_new_ui_def_id
	                ,p_encl_folder_id
			,l_name
	    ,DESCRIPTION
	    ,NOTES
	                ,'0'
	    ,DELETED_FLAG
	   FROM CZ_RP_ENTRIES
	   WHERE object_id= p_ui_def_id AND object_type='UMT'
	   AND deleted_flag='0';

           IF SQL%ROWCOUNT = 0 THEN
             RAISE INVALID_UIDEF_ID_EXCP;
           END IF;

       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN INVALID_UIDEF_ID_EXCP THEN
     handle_Error(p_message_name   => 'CZ_COPY_UMT_INV_ID',
                  p_token_name1    => 'OBJID',
                  p_token_value1   => TO_CHAR(p_ui_def_id),
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

  WHEN OTHERS THEN
       handle_Error(p_procedure_name => 'copy_ui_master_template',
                    p_error_message  => SQLERRM,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data);
END copy_ui_master_template;

-------------------delete API(s)
--------is effset deletable
 PROCEDURE is_eff_set_deleteable(p_eff_set_id IN  NUMBER,
  	       x_return_status OUT NOCOPY VARCHAR2,
	       x_msg_count     OUT NOCOPY NUMBER,
	       x_msg_data      OUT NOCOPY VARCHAR2)
IS

  TYPE prj_name_tbl_type IS TABLE of cz_devl_projects.name%TYPE INDEX BY BINARY_INTEGER;
  l_prj_name_tbl  prj_name_tbl_type;

  l_eff_set_id  NUMBER;
  l_eff_name    VARCHAR2(255);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  ----check if eff set exists
  SELECT object_id,name
  INTO   l_eff_set_id,l_eff_name
  FROM   cz_rp_entries
  WHERE  cz_rp_entries.object_id    = p_eff_set_id
   AND   cz_rp_entries.object_type  = 'EFF'
   AND   cz_rp_entries.deleted_flag = '0'
   AND   cz_rp_entries.seeded_flag  <> '1';

  SELECT name BULK COLLECT INTO l_prj_name_tbl
  FROM cz_devl_projects
  WHERE deleted_flag = '0' AND devl_project_id IN
    (SELECT devl_project_id FROM cz_rules
     WHERE  effectivity_set_id = p_eff_set_id
     AND    deleted_flag = '0'
     UNION ALL
     SELECT devl_project_id FROM cz_ps_nodes
     WHERE  effectivity_set_id = p_eff_set_id
     AND    deleted_flag = '0');

  IF l_prj_name_tbl.COUNT > 0 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FOR i IN l_prj_name_tbl.FIRST..l_prj_name_tbl.LAST
    LOOP
      FND_MESSAGE.SET_NAME('CZ', 'CZ_DEV_UTILS_EFF_SET_IN_USE');
      FND_MESSAGE.SET_TOKEN('EFFSETNAME', l_eff_name);
      FND_MESSAGE.SET_TOKEN('MODELNAME',  l_prj_name_tbl(i));
      FND_MSG_PUB.ADD;
    END LOOP;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'is_eff_set_deleteable',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END is_eff_set_deleteable;

--------------------------------------------
---- delete effectivity sets
PROCEDURE delete_eff_set(p_eff_set_id    IN  NUMBER,
	       x_return_status OUT NOCOPY VARCHAR2,
	       x_msg_count     OUT NOCOPY NUMBER,
	       x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  is_eff_set_deleteable(p_eff_set_id,l_return_status,l_msg_count,l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     UPDATE cz_effectivity_sets
	SET   deleted_flag = '1',
	name = append_name(p_eff_set_id, 'EFF', name)
      WHERE effectivity_set_id = p_eff_set_id;

     UPDATE cz_rp_entries
     SET    deleted_flag = '1',
		name = append_name(p_eff_set_id, 'EFF', name)
     WHERE  object_id = p_eff_set_id
	AND   object_type = 'EFF';
  ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
 END IF;
EXCEPTION
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_eff_set',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_eff_set;

-------------------------------------------
-----------------------------------------------
-------can delete archive
PROCEDURE is_archive_deleteable(p_archive_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_devl_project_tbl t_indexes;
l_object_id       cz_rp_entries.object_id%TYPE;
l_object_name     cz_rp_entries.name%TYPE;
l_seeded_flag     cz_rp_entries.seeded_flag%TYPE;
l_devl_name	      cz_devl_projects.name%TYPE;
BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  ----check if archive exists
  BEGIN
    SELECT object_id,name,seeded_flag
    INTO   l_object_id,l_object_name,l_seeded_flag
    FROM   cz_rp_entries
    WHERE  cz_rp_entries.object_id = p_archive_id
    AND    cz_rp_entries.object_type = 'ARC'
    AND    cz_rp_entries.deleted_flag = '0';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_object_id := -1;
  END;

  IF (l_object_id = -1) THEN
	RAISE OBJECT_NOT_FOUND;
  END IF;

  IF (l_seeded_flag = '1') THEN
	RAISE SEEDED_OBJ_EXCEP;
  END IF;

  l_devl_project_tbl.DELETE;
  SELECT DISTINCT devl_project_id
  BULK
  COLLECT
  INTO   l_devl_project_tbl
  FROM   cz_archive_refs
  WHERE  cz_archive_refs.archive_id = p_archive_id
  AND    cz_archive_refs.deleted_flag = '0'
  AND    cz_archive_refs.devl_project_id IN (SELECT object_id
							   FROM   cz_rp_entries
							   WHERE  object_type = 'PRJ'
							    AND   deleted_flag = '0');

  IF (l_devl_project_tbl.COUNT > 0) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	FOR I IN l_devl_project_tbl.FIRST..l_devl_project_tbl.LAST
	LOOP
   	   x_msg_count := x_msg_count + 1;
	   SELECT name into l_devl_name FROM cz_devl_projects WHERE devl_project_id = l_devl_project_tbl(i);
    	   handle_Error(p_message_name   => 'CZ_ARC_IN_USE',
                  p_token_name1    => 'ARCHIVENAME',
                  p_token_value1   => l_object_name,
                  p_token_name2    => 'MODELNAME',
                  p_token_value2   => l_devl_name,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
	END LOOP;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    NULL;
WHEN OBJECT_NOT_FOUND THEN
     NULL;
WHEN SEEDED_OBJ_EXCEP THEN
     handle_Error(p_message_name   => 'CZ_OBJ_SEEDED',
                  p_token_name1    => 'NAME',
                  p_token_value1   => l_object_name,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

WHEN OTHERS THEN
   handle_Error(p_procedure_name => 'is_archive_deleteable',
                p_error_message  => SQLERRM,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);
END is_archive_deleteable;

---------------------------------------
--------delete archive
PROCEDURE delete_archive(p_archive_id  IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1);
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  is_archive_deleteable(p_archive_id,l_return_status,l_msg_count,l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  	UPDATE cz_rp_entries
       set   deleted_flag = '1',
	 	 name = append_name(p_archive_id, 'ARC', name)
       where  object_id = p_archive_id
	  and   object_type = 'ARC'
	  and   deleted_flag = '0'
	  and   seeded_flag <> '1';

       UPDATE cz_archives
         SET  cz_archives.deleted_flag = '1',
	 	  cz_archives.name = append_name(p_archive_id, 'ARC', name)
	 WHERE  cz_archives.archive_id = p_archive_id;
  ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
  END IF;
EXCEPTION
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_archive',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_archive;

---------------------------------
-----can delete property
PROCEDURE is_property_deleteable (p_property_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_object_id       cz_rp_entries.object_id%TYPE;
l_object_name     cz_rp_entries.name%TYPE;
l_seeded_flag     cz_rp_entries.seeded_flag%TYPE;
l_ps_prop_count   NUMBER := 0;
l_item_prop_count NUMBER := 0;
l_ui_pages_count  NUMBER := 0;
l_prop_count	NUMBER := 0;

PROPERTY_IN_USE EXCEPTION;

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  ----check if prop exists
  BEGIN
    SELECT object_id,name,seeded_flag
    INTO   l_object_id,l_object_name,l_seeded_flag
    FROM   cz_rp_entries
    WHERE  cz_rp_entries.object_id = p_property_id
    AND    cz_rp_entries.object_type = 'PRP'
    AND    cz_rp_entries.deleted_flag = '0';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_object_id := -1;
  END;

  IF (l_object_id = -1) THEN
	RAISE OBJECT_NOT_FOUND;
  END IF;

  IF (l_seeded_flag = '1') THEN
	RAISE SEEDED_OBJ_EXCEP;
  END IF;


  BEGIN
   SELECT 1
   INTO   l_prop_count
   FROM   CZ_PSNODE_PROPVAL_V
   WHERE  ps_node_id IN (select ps_node_id
				 from   cz_ps_nodes
				 where  cz_ps_nodes.deleted_flag = '0')
   AND    property_id = p_property_id
   AND    rownum < 2;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    l_prop_count := 0;
 END;
 IF (l_prop_count > 0) THEN
	RAISE PROPERTY_IN_USE ;
 END IF;

 BEGIN
   SELECT 1
   INTO   l_item_prop_count
   FROM   CZ_ITEM_TYPE_PROPERTIES
   WHERE  item_type_id IN (select item_type_id
				   from   cz_item_types
				   where  deleted_flag = '0')
   AND    property_id = p_property_id
   AND    deleted_flag = '0';
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    l_prop_count := 0;
 END;
 IF (l_item_prop_count > 0) THEN
	RAISE PROPERTY_IN_USE;
 END IF;

BEGIN
   SELECT 1
   INTO   l_ui_pages_count
   FROM   CZ_UI_PAGES
   WHERE  property_id = p_property_id
   AND    deleted_flag = '0';
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    l_prop_count := 0;
 END;
 IF (l_item_prop_count > 0) THEN
	  RAISE PROPERTY_IN_USE;
 END IF;

EXCEPTION
WHEN OBJECT_NOT_FOUND THEN
   NULL;
WHEN SEEDED_OBJ_EXCEP THEN
   handle_Error(p_message_name   => 'CZ_OBJ_SEEDED',
                p_token_name1    => 'NAME',
                p_token_value1   => l_object_name,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);
WHEN PROPERTY_IN_USE THEN
   handle_Error(p_message_name   => 'CZ_PROP_IN_USE',
                p_token_name1    => 'NAME',
                p_token_value1   => l_object_name,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'is_property_deleteable',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END is_property_deleteable ;

----------------------------------------------
------------------delete property
PROCEDURE delete_property(p_property_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1);
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  is_property_deleteable(p_property_id,l_return_status,l_msg_count,l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	UPDATE cz_rp_entries
       SET   deleted_flag = '1',
		 name = append_name(p_property_id, 'PRP', name)
	WHERE  object_id = p_property_id
	AND    object_type = 'PRP'
      AND    deleted_flag = '0'
      AND    seeded_flag <> '1';

      UPDATE cz_properties
	  SET  cz_properties.deleted_flag = '1',
	       cz_properties.name = append_name(p_property_id, 'PRP', name)
	 WHERE property_id = p_property_id;
  ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
  END IF;
EXCEPTION
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_property',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_property;

----can delete umt
PROCEDURE is_umt_deleteable (p_umt_id IN NUMBER,
	     x_return_status OUT NOCOPY VARCHAR2,
	     x_msg_count     OUT NOCOPY NUMBER,
	     x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_object_id   cz_rp_entries.object_id%TYPE;
l_object_name cz_rp_entries.name%TYPE;
l_seeded_flag VARCHAR2(1);
TYPE ui_name_tbl is TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
l_ui_name_tbl ui_name_tbl;

BEGIN
   FND_MSG_PUB.initialize;
   ----check if p_umt_id exists
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data  := '';

   BEGIN
	SELECT object_id,name,seeded_flag
	INTO   l_object_id,l_object_name,l_seeded_flag
	FROM   cz_rp_entries
	WHERE  cz_rp_entries.object_id = p_umt_id
      AND    cz_rp_entries.object_type = 'UMT'
	AND    cz_rp_entries.deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	      l_object_id := -1;
   END;
   IF (l_object_id = -1) THEN
    	RAISE OBJECT_NOT_FOUND;
   END IF;

   IF (l_seeded_flag = '1') THEN
    	RAISE SEEDED_OBJ_EXCEP;
   END IF;

   BEGIN
     SELECT name
     BULK
     COLLECT
     INTO   l_ui_name_tbl
     FROM   cz_ui_defs ui
     WHERE  from_master_template_id = p_umt_id
     AND    deleted_flag = '0'
     AND    seeded_flag <> '1'
     AND    exists (SELECT 1 FROM cz_rp_entries WHERE deleted_flag = '0'
                    AND object_id = ui.devl_project_id and object_type = 'PRJ');
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	l_object_id := -1;
   END;

   IF (l_ui_name_tbl.count > 0 ) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FOR I IN l_ui_name_tbl.FIRST..l_ui_name_tbl.LAST
     LOOP
       FND_MESSAGE.SET_NAME('CZ', 'CZ_UMT_IN_USE');
  	 FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
	 FND_MESSAGE.SET_TOKEN('UI', l_ui_name_tbl(i));
  	 FND_MSG_PUB.ADD;
      END LOOP;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
   END IF;

EXCEPTION
WHEN OBJECT_NOT_FOUND THEN
     NULL;
WHEN SEEDED_OBJ_EXCEP THEN
   handle_Error(p_message_name   => 'CZ_OBJ_SEEDED',
                p_token_name1    => 'UMTNAME',
                p_token_value1   => l_object_name,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);
WHEN OTHERS THEN
   handle_Error(p_procedure_name => 'is_umt_deleteable',
                p_error_message   => SQLERRM,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data);
END is_umt_deleteable;

------------delete umt
PROCEDURE delete_umt(p_umt_id        IN NUMBER,
	   x_return_status OUT NOCOPY VARCHAR2,
	   x_msg_count     OUT NOCOPY NUMBER,
	   x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1);
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

 is_umt_deleteable(p_umt_id,l_return_status,l_msg_count,l_msg_data);
 IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    UPDATE cz_rp_entries
     SET   deleted_flag = '1',
		name = append_name(p_umt_id, 'UMT', name)
    WHERE  object_id = p_umt_id
     AND   object_type = 'UMT';

    UPDATE cz_ui_defs
	set deleted_flag = '1',
	    name = append_name(p_umt_id, 'UMT', name)
    WHERE ui_def_id = p_umt_id
	AND master_template_flag = '1'
	AND seeded_flag <> '1';
 ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
 END IF;
EXCEPTION
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_umt',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_umt;

--------------------------------------------------------------------------------
-- can delete uct ?
PROCEDURE is_uct_deleteable(p_uct_id IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2)
IS
  TYPE ui_name_tbl is TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE num_type_tbl is TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  l_object_id   cz_rp_entries.object_id%TYPE;
  l_object_name cz_rp_entries.name%TYPE;
  l_seeded_flag VARCHAR2(1);
  l_ui_name_tbl ui_name_tbl;
  l_mt_flag_tbl ui_name_tbl;
  l_ref_template_tbl num_type_tbl;
  l_ref_templ_ui_tbl num_type_tbl;
  l_ref_template_name cz_ui_templates.template_name%TYPE;

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  -- check if p_uct_id exists
  BEGIN
    SELECT object_id,name,seeded_flag
    INTO   l_object_id,l_object_name,l_seeded_flag
    FROM   cz_rp_entries
    WHERE  cz_rp_entries.object_id = p_uct_id
    AND    cz_rp_entries.object_type = 'UCT'
    AND    cz_rp_entries.deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_object_id := -1;
  END;

  IF (l_object_id = -1) THEN
    RAISE OBJECT_NOT_FOUND;
  END IF;

  IF (l_seeded_flag = '1') THEN
    RAISE SEEDED_OBJ_EXCEP;
  END IF;

  l_ui_name_tbl.DELETE;
  BEGIN
    SELECT name name, master_template_flag
    BULK COLLECT INTO l_ui_name_tbl, l_mt_flag_tbl
    FROM   cz_ui_defs ui
    WHERE  deleted_flag = '0'
    AND    ui_def_id IN
        (SELECT ui_def_id
         FROM   cz_ui_cont_type_templs
         WHERE  cz_ui_cont_type_templs.template_id = p_uct_id
         AND    cz_ui_cont_type_templs.template_ui_def_id = 0
         AND    cz_ui_cont_type_templs.deleted_flag = '0'
       UNION ALL
         SELECT ui_def_id
         FROM  cz_ui_page_elements
         WHERE cz_ui_page_elements.ctrl_template_id = p_uct_id
         AND   cz_ui_page_elements.ctrl_template_ui_def_id = 0
         AND   cz_ui_page_elements.deleted_flag = '0')
    AND exists (SELECT 1 FROM cz_rp_entries WHERE deleted_flag = '0'
                AND object_id = ui.devl_project_id and object_type = 'PRJ');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_object_id := -1;
  END;

  IF (l_ui_name_tbl.count > 0 ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FOR I IN l_ui_name_tbl.FIRST..l_ui_name_tbl.LAST
    LOOP
      IF l_mt_flag_tbl(i) = '1' THEN
        FND_MESSAGE.SET_NAME ('CZ', 'CZ_UCT_IN_USE_TEMPL');
        FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
        FND_MESSAGE.SET_TOKEN('TEMPLNAME',l_ui_name_tbl(i));
      ELSE
        FND_MESSAGE.SET_NAME('CZ', 'CZ_UCT_IN_USE');
        FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
        FND_MESSAGE.SET_TOKEN('UINAME', l_ui_name_tbl(i));
      END IF;
      FND_MSG_PUB.ADD;
    END LOOP;
  END IF;

  BEGIN
    SELECT template_id, template_ui_def_id
    BULK COLLECT INTO l_ref_template_tbl, l_ref_templ_ui_tbl
    FROM   cz_ui_ref_templates
    WHERE  cz_ui_ref_templates.deleted_flag = '0'
    AND cz_ui_ref_templates.ref_template_id = p_uct_id
    AND cz_ui_ref_templates.ref_template_ui_def_id = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  IF (l_ref_template_tbl.COUNT > 0) THEN
    FOR I IN l_ref_template_tbl.FIRST..l_ref_template_tbl.LAST
    LOOP
      BEGIN
        SELECT template_name INTO l_ref_template_name
        FROM   cz_ui_templates
        WHERE  cz_ui_templates.template_id = l_ref_template_tbl(i)
        AND cz_ui_templates.ui_def_id = l_ref_templ_ui_tbl(i)
        AND cz_ui_templates.deleted_flag = '0';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_ref_template_name := NULL;
      END;

      IF l_ref_template_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME ('CZ', 'CZ_UCT_IN_USE_TEMPL');
        FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
        FND_MESSAGE.SET_TOKEN('TEMPLNAME',l_ref_template_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END LOOP;
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
EXCEPTION
  WHEN OBJECT_NOT_FOUND THEN
    NULL;
  WHEN SEEDED_OBJ_EXCEP THEN
    handle_Error(p_message_name   => 'CZ_OBJ_SEEDED',
                 p_token_name1    => 'UCTNAME',
                 p_token_value1   => l_object_name,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data);
  WHEN OTHERS THEN
    handle_Error(p_procedure_name => 'is_uct_deleteable',
                p_error_message   => SQLERRM,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data);
END is_uct_deleteable;

--------------------------------------------------------------------------------
------delete uct
PROCEDURE delete_uct(p_uct_id IN NUMBER,
	   x_return_status OUT NOCOPY VARCHAR2,
	   x_msg_count     OUT NOCOPY NUMBER,
	   x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1);
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data  := '';

  is_uct_deleteable(p_uct_id,l_return_status,l_msg_count,l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       UPDATE cz_rp_entries
	  SET   deleted_flag = '1',
		  name = append_name(p_uct_id, 'UCT', name)
	 WHERE  object_id = p_uct_id
	  AND   object_type = 'UCT'
	  AND   seeded_flag <> '1';

       UPDATE cz_ui_templates
	  SET   deleted_flag = '1',
		  template_name = append_name(p_uct_id, 'UCT', template_name)
	  WHERE template_id = p_uct_id;
   ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
   END IF;
EXCEPTION
WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_uct',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_uct;

--------------------------------
FUNCTION hextobinary (hexnum in char)
RETURN VARCHAR2
 IS
  result  VARCHAR2(4) :='';
  current_digit_dec number;
BEGIN
      if hexnum in ('A','B','C','D','E','F','a','b','c','d','e','f') then
         current_digit_dec := ascii(UPPER(hexnum)) - ascii('A') + 10;
      else
         current_digit_dec := to_number(hexnum);
      end if;
     LOOP
        result := to_char(MOD(current_digit_dec,2))||result;
 	 current_digit_dec := trunc(current_digit_dec/2);
 	 EXIT WHEN (current_digit_dec < 1);
      end loop;
      result := LPAD(result,4,'0');
   return result;
END;
-----------------------------------
FUNCTION mapHasUsageId(usageId in number, usageMap VARCHAR2)
return number
is
 l_str varchar2(1) :='';
 l_length number;
 l_hex varchar2(16) default '0123456789ABCDEF';
 l_bits VARCHAR2(64) := '';
 current_digit VARCHAR2(1);
 l_length1 number;
begin
 l_length := LENGTH(usageMap);
 FOR I IN 1..l_length
 LOOP
   current_digit := SUBSTR(usageMap,i,1);
   l_length1 := LENGTH(l_bits);
   l_bits := l_bits||hextobinary(current_digit);
 END LOOP;
 l_str := substr(l_bits,-(usageid+1),1);
 IF( to_number(l_str) = 1) THEN
  return 1;
 ELSE
  return 0;
 END IF;
end mapHasUsageId;

-------------------
FUNCTION power_func (p_power IN NUMBER)
RETURN number
IS
result  number := 1;
BEGIN
  for x in 1..p_power
  loop
  	result := result*2;
  end loop;
  return result;
END;

----------------------------
FUNCTION hextodec (hexnum in char)
RETURN number
 IS
  x       number;
  digits  number;
  result  number := 0;
  current_digit char(1);
  current_digit_dec number;
BEGIN
  digits := length(hexnum);
  for x in 1..digits
  loop
      current_digit := SUBSTR(hexnum, x, 1);
      if current_digit in ('A','B','C','D','E','F') then
         current_digit_dec := ascii(current_digit) - ascii('A') + 10;
      else
         current_digit_dec := to_number(current_digit);
      end if;
      result := (result * 16) + current_digit_dec;
   end loop;
   return result;
END;

----------------------------
FUNCTION MAP_LESS_USAGE_ID(usageId in number, usageMap VARCHAR2 )
RETURN VARCHAR2
IS
l_str varchar2(255) default NULL;
l_num number;
l_hex varchar2(16)  default '0123456789ABCDEF';

BEGIN
l_num := hextodec(usageMap) - power_func(usageId);

loop
  l_str := substr( l_hex, mod(l_num,16)+1, 1 ) || l_str;
  l_num := trunc( l_num/16 );
  exit when ( l_num = 0 );
 end loop;

 l_str := lpad(l_str,16,'0');

return l_str;
END MAP_LESS_USAGE_ID;

--------------------------------
PROCEDURE is_usage_deleteable(p_usage_id     IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count     OUT NOCOPY NUMBER,
				    x_msg_data      OUT NOCOPY VARCHAR2)
IS
TYPE t_indexes IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_mask	IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;

NO_USG_EXISTS    EXCEPTION;
USG_IN_USE       EXCEPTION;
l_usage_count    NUMBER := 0;
l_map_has_usg_id NUMBER := 1;
v_nodes		t_indexes;
v_rules		t_indexes;
v_masks_nodes	t_mask;
v_masks_rules	t_mask;
l_usage_name      cz_model_usages.name%TYPE;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data  := '';

   BEGIN
   	SELECT name
   	INTO   l_usage_name
   	FROM   cz_model_usages
   	WHERE  cz_model_usages.model_usage_id = p_usage_id
   	AND    cz_model_usages.in_use <> 'X';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	RAISE NO_USG_EXISTS;
   END;

   BEGIN
   	SELECT 1
   	INTO   l_usage_count
   	FROM   cz_publication_usages
   	WHERE  cz_publication_usages.usage_id = p_usage_id
   	AND    cz_publication_usages.publication_id IN (SELECT publication_id
								    FROM  cz_model_publications
								   WHERE  cz_model_publications.deleted_flag = '0')
  	 AND    rownum < 2;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	NULL;
   END;

   IF (l_usage_count = 1) THEN
      RAiSE USG_IN_USE;
   END IF;

   v_nodes.DELETE;
   v_rules.DELETE;
   v_masks_nodes.DELETE;
   v_masks_rules.DELETE;
   BEGIN
 	SELECT ps_node_id,
	       effective_usage_mask
	BULK
	COLLECT
	INTO	v_nodes,
		v_masks_nodes
 	FROM cz_ps_nodes
	WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
	AND     deleted_flag = '0'
	ORDER BY effective_usage_mask;
   EXCEPTION
   WHEN OTHERS THEN
     NULL;
   END;

   BEGIN
	SELECT rule_id,
	       effective_usage_mask
	BULK
	COLLECT
	INTO	v_rules,
		v_masks_rules
	FROM cz_rules
	WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
	AND     deleted_flag = '0'
	ORDER BY effective_usage_mask;
   EXCEPTION
   WHEN OTHERS THEN
     NULL;
   END;

   IF (v_nodes.COUNT > 0) THEN
      FOR I IN v_nodes.FIRST..v_nodes.LAST
	LOOP
	   l_map_has_usg_id := mapHasUsageId(p_usage_id, v_masks_nodes(i));
	   IF (l_map_has_usg_id = 1) THEN
		RAISE USG_IN_USE;
    	      EXIT;
	   END IF;
	END LOOP;
   END IF;

   IF (v_rules.COUNT > 0) THEN
      FOR I IN v_rules.FIRST..v_rules.LAST
	LOOP
	   l_map_has_usg_id := mapHasUsageId(p_usage_id, v_masks_rules(i));
	   IF (l_map_has_usg_id = 1) THEN
		RAISE USG_IN_USE;
    	      EXIT;
	   END IF;
	END LOOP;
   END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := NULL;
WHEN NO_USG_EXISTS THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := NULL;
WHEN USG_IN_USE THEN
  FND_MESSAGE.SET_NAME('CZ','CZ_USG_IN_USE');
  FND_MESSAGE.SET_TOKEN('USAGE',l_usage_name);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.g_ret_sts_error;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
WHEN OTHERS THEN
     handle_Error(p_message_name   => 'CZ_DEL_USG_FATAL_ERR',
                  p_token_name1    => 'USAGE',
                  p_token_value1   => TO_CHAR(p_usage_id),
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END is_usage_deleteable;
------------------------------------------
PROCEDURE DELETE_USAGE(usageId IN NUMBER, delete_status IN OUT NOCOPY VARCHAR2)
AS

TYPE t_indexes IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_mask	IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;
v_nodes		t_indexes;
v_rules		t_indexes;
v_masks_nodes	t_mask;
v_masks_rules	t_mask;
v_new_mask	      VARCHAR2(16);
v_last_old_mask	VARCHAR2(16);
v_first_index BINARY_INTEGER;

BEGIN
 FND_MSG_PUB.initialize;
 v_nodes.DELETE;
 v_rules.DELETE;
 v_masks_nodes.DELETE;
 v_masks_rules.DELETE;

 BEGIN
	SELECT ps_node_id,
	       effective_usage_mask
	BULK
	COLLECT
	INTO	v_nodes,
		v_masks_nodes
	FROM cz_ps_nodes
	WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
	ORDER BY effective_usage_mask;
EXCEPTION
WHEN OTHERS THEN
 NULL;
END;

BEGIN
	SELECT rule_id,
	       effective_usage_mask
	BULK
	COLLECT
	INTO	v_rules,
		v_masks_rules
	FROM cz_rules
	WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
	ORDER BY effective_usage_mask;
EXCEPTION
WHEN OTHERS THEN
 NULL;
END;

BEGIN
  UPDATE cz_model_usages
  SET     in_use = 'X',
	    name = append_name(usageId, 'USG', name)
  WHERE model_usage_id = usageId;

  DELETE FROM cz_publication_usages
  WHERE usage_id = usageId;

  DELETE FROM cz_rp_entries
  WHERE object_type ='USG' and object_id = usageId;

  IF (v_nodes.COUNT > 0) THEN
	v_first_index := v_masks_nodes.FIRST;
	v_last_old_mask := v_masks_nodes(v_first_index);
	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_nodes(v_first_index));
	v_masks_nodes(v_first_index) := v_new_mask;

	FOR i IN v_masks_nodes.NEXT(v_first_index)..v_masks_nodes.LAST
	LOOP
	   IF v_masks_nodes(i) = v_last_old_mask THEN
		v_masks_nodes(i) := v_masks_nodes(i-1);
	   ELSE
		v_last_old_mask := v_masks_nodes(i);
	  	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_nodes(i));
	  	v_masks_nodes(i) := v_new_mask;
	   END IF;
 	END LOOP;

	FORALL i IN v_nodes.FIRST..v_nodes.LAST
	 UPDATE cz_ps_nodes
       SET effective_usage_mask = v_masks_nodes(i)
	 WHERE  ps_node_id = v_nodes(i);
  END IF;

  IF (v_rules.COUNT > 0) THEN
	v_first_index := v_masks_rules.FIRST;
	v_last_old_mask := v_masks_rules(v_first_index);
	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_rules(v_first_index));
	v_masks_rules(v_first_index) := v_new_mask;

	FOR i IN v_masks_rules.NEXT(v_first_index)..v_masks_rules.LAST
	LOOP
	   IF v_masks_rules(i) = v_last_old_mask THEN
		v_masks_rules(i) := v_masks_rules(i-1);
	   ELSE
		v_last_old_mask := v_masks_rules(i);
	  	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_rules(i));
	  	v_masks_rules(i) := v_new_mask;
	   END IF;
	END LOOP;
	FORALL i IN v_rules.FIRST..v_rules.LAST
	UPDATE cz_rules
	SET    effective_usage_mask = v_masks_rules(i)
	WHERE  rule_id = v_rules(i);
  END IF;
EXCEPTION
WHEN OTHERS THEN
 delete_status := '-1';
END;

IF SQLCODE = 0 THEN
   delete_status := '0';
END IF;
END DELETE_USAGE;

------------------------------------------
PROCEDURE delete_usage (p_usage_id      IN NUMBER,
				x_return_status OUT NOCOPY VARCHAR2,
				x_msg_count     OUT NOCOPY NUMBER,
				x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1);
l_usg_status    NUMBER := 0;
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);
DEL_USG_ERR     EXCEPTION;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data  := '';

   is_usage_deleteable(p_usage_id,l_return_status,l_msg_count,l_msg_data);
   IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      delete_usage(p_usage_id,l_usg_status);
      IF (l_usg_status <> 0) THEN
		RAISE DEL_USG_ERR ;
	END IF;
   ELSE
	x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
   END IF;
EXCEPTION
WHEN DEL_USG_ERR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  handle_Error(p_message_name   => 'CZ_CANNOT_DEL_USG',
                  p_token_name1    => 'USAGE',
                  p_token_value1   => TO_CHAR(p_usage_id),
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_usage',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_usage;

---------------------------------------
PROCEDURE is_repos_fld_deleteable ( p_rp_folder_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2)
IS

TYPE number_type_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE model_names_tbl IS TABLE OF cz_devl_projects.name%TYPE INDEX BY BINARY_INTEGER;
TYPE t_mask	IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;
TYPE name_tbl	IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
TYPE t_checkout_user_tbl IS TABLE OF cz_devl_projects.checkout_user%TYPE INDEX BY BINARY_INTEGER;
l_rp_folder     NUMBER;
l_rp_fld_tbl    number_type_tbl;
l_rp_model_tbl  number_type_tbl;
l_rp_model_ref  number_type_tbl;
l_eff_set_tbl   number_type_tbl;
l_eff_set_ref   number_type_tbl;
l_eff_tbl      number_type_tbl;
l_eff_ref      number_type_tbl;
l_eff_idx_ref  number_type_tbl;
l_eff_set_id   NUMBER := 0;
l_encl_eff_fld NUMBER := 0;
l_eff_name     VARCHAR2(255);

l_devl_project_tbl number_type_tbl;
l_object_id       cz_rp_entries.object_id%TYPE;
l_object_name     cz_rp_entries.name%TYPE;
l_seeded_flag     cz_rp_entries.seeded_flag%TYPE;
l_devl_name	  cz_devl_projects.name%TYPE;
l_encl_arc_fld    NUMBER := 0;

l_usg_tbl       number_type_tbl;
l_usg_ref       number_type_tbl;
l_arc_tbl       number_type_tbl;
l_arc_ref       number_type_tbl;
l_prp_tbl      number_type_tbl;
l_prp_ref       number_type_tbl;
l_umt_tbl       number_type_tbl;
l_umt_ref       number_type_tbl;
l_uct_tbl       number_type_tbl;
l_uct_ref       number_type_tbl;
l_publication_tbl number_type_tbl;
l_encl_tbl      number_type_tbl;
l_encl_fld_tbl  number_type_tbl;
l_encl_idx_ref  number_type_tbl;
l_encl_devl_tbl      number_type_tbl;
l_ref_model_ids_tbl   number_type_tbl;
l_ref_model_names_tbl model_names_tbl;
l_eff_encl_fld_id   NUMBER := 0;
rec_count	    NUMBER := 0;
l_checkout_user     cz_devl_projects.checkout_user%TYPE;
l_model_name        cz_devl_projects.name%TYPE;
l_template_name     cz_ui_templates.template_name%TYPE;
l_fld_name	    cz_rp_entries.name%TYPE;
l_priv	            VARCHAR2(1) := 'F';
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_ref_count         NUMBER:=0;
l_orig_sys_ref      VARCHAR2(255);

l_ps_prop_count   NUMBER := 0;
l_item_prop_count NUMBER := 0;
l_ui_pages_count  NUMBER := 0;
l_prop_count	  NUMBER := 0;
l_folder_count    NUMBER := 0;
l_ui_name_tbl     model_names_tbl;
l_usage_name      cz_model_usages.name%TYPE;

l_usage_count      NUMBER := 0;
l_map_has_usg_id   NUMBER := 1;
v_nodes		 number_type_tbl ;
v_rules		 number_type_tbl ;
l_nodes_project_tbl  number_type_tbl ;
l_rules_project_tbl  number_type_tbl ;
v_masks_nodes	 t_mask;
v_masks_rules	 t_mask;
l_nodes_name_tbl name_tbl;
l_rules_name_tbl name_tbl;
l_ref_model_name  cz_devl_projects.name%TYPE;
l_locked_models_tbl     number_type_tbl;
l_all_locked_models_tbl number_type_tbl;
l_checkout_user_tbl     t_checkout_user_tbl;
l_user_name             cz_devl_projects.checkout_user%TYPE;
l_devl_prj_name_tbl     name_tbl;
l_template_name_tbl     name_tbl;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status    := FND_API.g_ret_sts_success;
   x_msg_count        := 0;
   x_msg_data         := '';

   l_user_name := FND_GLOBAL.user_name;
   ------check if p_rp_folder_id exists
   SELECT object_id
   INTO   l_rp_folder
   FROM   cz_rp_entries
   WHERE  cz_rp_entries.object_id    = p_rp_folder_id
   AND    cz_rp_entries.object_type  = 'FLD'
   AND    cz_rp_entries.deleted_flag = '0';

   l_rp_fld_tbl.DELETE;
   l_encl_idx_ref.DELETE;
   l_encl_fld_tbl.DELETE;
   SELECT object_id,enclosing_folder
   BULK
   COLLECT
   INTO   l_rp_fld_tbl,l_encl_fld_tbl
   FROM   cz_rp_entries
   WHERE  cz_rp_entries.deleted_flag = '0'
   AND    cz_rp_entries.object_type  = 'FLD'
   START WITH cz_rp_entries.object_type = 'FLD'
         AND cz_rp_entries.object_id = l_rp_folder
   CONNECT BY PRIOR cz_rp_entries.object_id = cz_rp_entries.enclosing_folder
    AND   PRIOR cz_rp_entries.object_type = 'FLD';

    ---l_folder_count := l_rp_fld_tbl.COUNT + 1;
    ---l_rp_fld_tbl(l_folder_count)   := l_rp_folder;
    ---l_encl_fld_tbl(l_folder_count) := -1;
   IF (l_rp_fld_tbl.COUNT > 0) THEN
	FOR I IN l_rp_fld_tbl.FIRST..l_rp_fld_tbl.LAST
	LOOP
	   l_encl_idx_ref(l_rp_fld_tbl(i)) := l_rp_fld_tbl(i);

	   ----collect all projects
	   l_rp_model_tbl.DELETE;
	   SELECT object_id, checkout_user, cz_devl_projects.name
	   BULK COLLECT
	   INTO  l_rp_model_tbl, l_checkout_user_tbl, l_devl_prj_name_tbl
	   FROM  cz_rp_entries, cz_devl_projects
	   WHERE cz_rp_entries.object_type = 'PRJ'
	   AND  cz_rp_entries.deleted_flag = '0'
	   AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i)
           AND  cz_rp_entries.object_id = cz_devl_projects.devl_project_id;

	   IF (l_rp_model_tbl.COUNT > 0) THEN
		rec_count := l_rp_model_ref.COUNT;
		FOR J IN l_rp_model_tbl.FIRST..l_rp_model_tbl.LAST
		LOOP
                    IF ( l_checkout_user_tbl(j) IS NOT NULL AND l_checkout_user_tbl(j) <> l_user_name ) THEN
  		   	FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_LOCKED_MODEL');
  		    	FND_MESSAGE.SET_TOKEN('MODELNAME', l_devl_prj_name_tbl(j));
  		    	FND_MESSAGE.SET_TOKEN('CHECKOUTUSER', l_checkout_user_tbl(j));
  		    	FND_MSG_PUB.ADD;
                        x_return_status    := FND_API.g_ret_sts_error;
                    END IF;
		    rec_count := rec_count + 1;
		    l_rp_model_ref(rec_count) := l_rp_model_tbl(j);
		END LOOP;
	   END IF;

	  ----get eff sets
          l_eff_set_tbl.DELETE;
   	  SELECT object_id
	  BULK COLLECT
	  INTO  l_eff_set_tbl
	  FROM  cz_rp_entries
	  WHERE cz_rp_entries.object_type = 'EFF'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i);

	  IF (l_eff_set_tbl.COUNT > 0) THEN
	     rec_count := l_eff_set_ref.COUNT;
	     FOR J IN l_eff_set_tbl.FIRST..l_eff_set_tbl.LAST
	     LOOP
		rec_count := rec_count + 1;
		l_eff_set_ref(rec_count) := l_eff_set_tbl(j);
	     END LOOP;
	  END IF;

	  ----get usages
          l_usg_tbl.DELETE;
   	  SELECT object_id
	  BULK COLLECT
	  INTO  l_usg_tbl
	  FROM  cz_rp_entries
	  WHERE cz_rp_entries.object_type = 'USG'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i);

	  IF (l_usg_tbl.COUNT > 0) THEN
	     rec_count := l_usg_ref.COUNT;
	     FOR J IN l_usg_tbl.FIRST..l_usg_tbl.LAST
	     LOOP
		rec_count := rec_count + 1;
		l_usg_ref(rec_count) := l_usg_tbl(j);
	     END LOOP;
	  END IF;

	  ----get archives
          l_arc_tbl.DELETE;
   	  SELECT object_id
	  BULK COLLECT
	  INTO  l_arc_tbl
	  FROM  cz_rp_entries
	  WHERE cz_rp_entries.object_type = 'ARC'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.seeded_flag <> '1'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i);

	  IF (l_arc_tbl.COUNT > 0) THEN
	     rec_count := l_arc_ref.COUNT;
	     FOR J IN l_arc_tbl.FIRST..l_arc_tbl.LAST
	     LOOP
		rec_count := rec_count + 1;
		l_arc_ref(rec_count) := l_arc_tbl(j);
	     END LOOP;
	  END IF;

  	  ----get properties
          l_prp_tbl.DELETE;
   	  SELECT object_id
	  BULK COLLECT
	  INTO  l_prp_tbl
	  FROM  cz_rp_entries
	  WHERE cz_rp_entries.object_type = 'PRP'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.seeded_flag <> '1'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i);

	  IF (l_prp_tbl.COUNT > 0) THEN
	     rec_count := l_prp_ref.COUNT;
	     FOR J IN l_prp_tbl.FIRST..l_prp_tbl.LAST
	     LOOP
		rec_count := rec_count + 1;
		l_prp_ref(rec_count) := l_prp_tbl(j);
	     END LOOP;
	  END IF;

  	  ----get master tmp
          l_umt_tbl.DELETE;
   	  SELECT object_id
	  BULK COLLECT
	  INTO  l_umt_tbl
	  FROM  cz_rp_entries
	  WHERE cz_rp_entries.object_type = 'UMT'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.seeded_flag <> '1'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i);

	  IF (l_umt_tbl.COUNT > 0) THEN
	     rec_count := l_umt_ref.COUNT;
	     FOR J IN l_umt_tbl.FIRST..l_umt_tbl.LAST
	     LOOP
		rec_count := rec_count + 1;
		l_umt_ref(rec_count) := l_umt_tbl(j);
	     END LOOP;
	  END IF;

  	  ----get uct
          l_uct_tbl.DELETE;
   	  SELECT object_id, checkout_user, template_name
	  BULK COLLECT
	  INTO  l_uct_tbl, l_checkout_user_tbl, l_template_name_tbl
	  FROM  cz_rp_entries, cz_ui_templates
	  WHERE cz_rp_entries.object_type = 'UCT'
	  AND  cz_rp_entries.deleted_flag = '0'
	  AND  cz_rp_entries.seeded_flag <> '1'
	  AND  cz_rp_entries.enclosing_folder = l_rp_fld_tbl(i)
          AND  cz_rp_entries.object_id = cz_ui_templates.template_id
          AND  cz_ui_templates.ui_def_id = 0;

	  IF (l_uct_tbl.COUNT > 0) THEN
	     rec_count := l_uct_ref.COUNT;
	     FOR J IN l_uct_tbl.FIRST..l_uct_tbl.LAST
	     LOOP
                    IF ( l_checkout_user_tbl(j) IS NOT NULL AND l_checkout_user_tbl(j) <> l_user_name ) THEN
  		   	FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_TMPL_IS_LOCKED');
  		    	FND_MESSAGE.SET_TOKEN('UCTNAME', l_template_name_tbl(j));
  		    	FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user_tbl(j));
  		    	FND_MSG_PUB.ADD;
                        x_return_status    := FND_API.g_ret_sts_error;
                    END IF;
		rec_count := rec_count + 1;
		l_uct_ref(rec_count) := l_uct_tbl(j);
	     END LOOP;
	  END IF;

       END LOOP;
    END IF;

    IF (l_rp_model_ref.COUNT > 0) THEN
	FOR modelId IN l_rp_model_ref.FIRST..l_rp_model_ref.LAST
	LOOP
	   l_ref_model_ids_tbl.DELETE;
	   l_encl_devl_tbl.DELETE;
	   l_ref_model_names_tbl.DELETE;
	   SELECT d.devl_project_id,d.name, rp.enclosing_folder
	   BULK
	   COLLECT
	   INTO l_ref_model_ids_tbl,l_ref_model_names_tbl,l_encl_devl_tbl
	   FROM  cz_ps_nodes p,
	         cz_devl_projects d,
	         cz_rp_entries rp
	   WHERE p.reference_id = l_rp_model_ref(modelId)
	   AND   p.ps_node_type IN (263, 264)
	   AND   p.deleted_flag = '0'
	   AND   p.devl_project_id = d.devl_project_id
	   AND   rp.object_id = d.devl_project_id
	   AND   rp.object_type = 'PRJ'
	   AND   d.deleted_flag = '0';

	   IF (l_ref_model_ids_tbl.COUNT > 0) THEN
	     FOR I IN l_ref_model_ids_tbl.FIRST..l_ref_model_ids_tbl.LAST
	     LOOP
		 IF (NOT l_encl_idx_ref.EXISTS( l_encl_devl_tbl(i) ) ) THEN
		     SELECT name into l_model_name from cz_devl_projects
		     WHERE devl_project_id = l_ref_model_ids_tbl(i);

		     SELECT name into l_ref_model_name from cz_devl_projects
		     WHERE devl_project_id = l_rp_model_ref(modelId);

		     FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_IS_REFD_BY');
  		     FND_MESSAGE.SET_TOKEN('MODELNAME',l_ref_model_name);
  		     FND_MESSAGE.SET_TOKEN('REFMODELNAME',l_model_name);
  		     FND_MSG_PUB.ADD;
		     x_return_status    := FND_API.g_ret_sts_error;
		 END IF;

		  l_publication_tbl.DELETE;
	   	  SELECT  publication_id
	   	  BULK
	   	  COLLECT
	   	  INTO   l_publication_tbl
	   	  FROM   cz_model_publications
	   	  WHERE  object_id = l_ref_model_ids_tbl(i)
	   	  AND    object_type = 'PRJ'
	   	  AND    deleted_flag = '0';

              IF (l_publication_tbl.COUNT > 0) THEN
                 FOR I IN l_publication_tbl.FIRST..l_publication_tbl.LAST
		     LOOP
		        SELECT name into l_model_name from cz_devl_projects
		        WHERE devl_project_id = l_ref_model_ids_tbl(i);
  		   	  FND_MESSAGE.SET_NAME('CZ', 'CZ_DEL_MODEL_IS_PUBLD');
  		    	  FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name);
  		   	  FND_MESSAGE.SET_TOKEN('PUBID', l_publication_tbl(i));
  		    	  FND_MSG_PUB.ADD;
		        x_return_status    := FND_API.g_ret_sts_error;
                  END LOOP;
	      END IF;
             END LOOP;
           END IF;
	END LOOP;
   END IF;

   IF (l_eff_set_ref.COUNT > 0) THEN
	FOR I IN l_eff_set_ref.FIRST..l_eff_set_ref.LAST
	LOOP
   	   BEGIN
	  	SELECT  object_id,name
		 INTO   l_eff_set_id,l_eff_name
		 FROM   cz_rp_entries
		 WHERE  cz_rp_entries.object_id    = l_eff_set_ref(i)
		 AND    cz_rp_entries.object_type  = 'EFF'
		 AND    cz_rp_entries.deleted_flag = '0'
		 AND    cz_rp_entries.seeded_flag  <> '1';

 	 	l_eff_tbl.DELETE;
	 	SELECT distinct devl_project_id
		BULK
		COLLECT
		INTO   l_eff_tbl
	  	FROM   cz_rules
	  	WHERE  cz_rules.effectivity_set_id = l_eff_set_ref(i)
	  	AND    cz_rules.deleted_flag = '0';

		 rec_count := l_eff_ref.COUNT;
		 IF (l_eff_tbl.COUNT > 0) THEN
		    FOR I IN l_eff_tbl.FIRST..l_eff_tbl.LAST
		    LOOP
        		rec_count := rec_count + 1;
		        l_eff_ref(rec_count) := l_eff_tbl(i);
        		l_eff_idx_ref(l_eff_tbl(i)) := l_eff_tbl(i);
		    END LOOP;
		  END IF;

		  l_eff_tbl.DELETE;
		  SELECT distinct devl_project_id
		  BULK
		  COLLECT
		  INTO   l_eff_tbl
		  FROM   cz_ps_nodes
		  WHERE  cz_ps_nodes.effectivity_set_id = l_eff_set_ref(i)
		  AND    cz_ps_nodes.deleted_flag = '0';

 		  rec_count := l_eff_ref.COUNT;
		  IF (l_eff_tbl.COUNT > 0) THEN
		    FOR I IN l_eff_tbl.FIRST..l_eff_tbl.LAST
		    LOOP
			  IF (NOT l_eff_idx_ref.EXISTS(l_eff_tbl(i)) ) THEN
	        	     rec_count := rec_count + 1;
	        	     l_eff_ref(rec_count) := l_eff_tbl(i);
			  END IF;
	    	    END LOOP;
  		  END IF;

	 	IF (l_eff_ref.COUNT > 0) THEN
 	  	    FOR I IN l_eff_ref.FIRST..l_eff_ref.LAST
  	  	    LOOP
	   	        BEGIN
		            SELECT enclosing_folder,name
			     INTO   l_encl_eff_fld,l_model_name
		  	     from   cz_rp_entries
		 	     WHERE  object_id = l_eff_ref(i)
		  	     AND    object_type = 'PRJ'
		  	     AND    deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
			    l_model_name := NULL;
			END;

  	     		IF ( (l_model_name IS NOT NULL)
			   AND (NOT l_encl_idx_ref.EXISTS(l_encl_eff_fld ) ) ) THEN
		    	     x_return_status := FND_API.G_RET_STS_ERROR;
		   	     FND_MESSAGE.SET_NAME('CZ', 'CZ_DEV_UTILS_EFF_SET_IN_USE');
  	   		     FND_MESSAGE.SET_TOKEN('EFFSETNAME', l_eff_name);
	 	   	     FND_MESSAGE.SET_TOKEN('MODELNAME',  l_model_name);
		  	     FND_MSG_PUB.ADD;
			END IF;
   	 	     END LOOP;
		 END IF;
    	EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		NULL;
   	 END;
     END LOOP;
  END IF;

  IF (l_arc_ref.COUNT > 0) THEN
    FOR modelId IN l_arc_ref.FIRST..l_arc_ref.LAST
    LOOP
	BEGIN
 	  ----check if archive exists
  	  SELECT object_id,name,seeded_flag,enclosing_folder
	  INTO   l_object_id,l_object_name,l_seeded_flag,l_encl_arc_fld
	  FROM   cz_rp_entries
	  WHERE  cz_rp_entries.object_id = l_arc_ref(modelId)
	  AND    cz_rp_entries.object_type = 'ARC'
	  AND    cz_rp_entries.deleted_flag = '0';

  	  l_devl_project_tbl.DELETE;
	  SELECT DISTINCT devl_project_id
	  BULK
	  COLLECT
	  INTO   l_devl_project_tbl
	  FROM   cz_archive_refs
	  WHERE  cz_archive_refs.archive_id = l_arc_ref(modelId)
	  AND    cz_archive_refs.deleted_flag = '0'
	  AND    cz_archive_refs.devl_project_id IN (SELECT object_id
						   FROM   cz_rp_entries
						   WHERE  object_type = 'PRJ'
						    AND   deleted_flag = '0');
	  IF (l_devl_project_tbl.COUNT > 0) THEN
		FOR I IN l_devl_project_tbl.FIRST..l_devl_project_tbl.LAST
		LOOP
		     SELECT name,enclosing_folder
		      into  l_devl_name,l_encl_arc_fld
		      FROM  cz_rp_entries
		      WHERE object_id = l_devl_project_tbl(i)
			AND object_type = 'PRJ';
		     IF ( NOT l_encl_idx_ref.EXISTS(l_encl_arc_fld ) ) THEN
		    	 x_return_status := FND_API.G_RET_STS_ERROR;
	    		 FND_MESSAGE.SET_NAME('CZ','CZ_ARC_IN_USE');
	  	    	 FND_MESSAGE.SET_TOKEN('ARCHIVENAME',l_object_name);
 		    	 FND_MESSAGE.SET_TOKEN('MODELNAME',l_devl_name);
	    		 FND_MSG_PUB.ADD;
		     END IF;
		END LOOP;
	   END IF;
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
   	 NULL;
	END;
     END LOOP;
  END IF;

 IF (l_prp_ref.COUNT > 0) THEN
	FOR modelId IN l_prp_ref.FIRST..l_prp_ref.LAST
	LOOP
  		BEGIN

		    SELECT object_id,name,seeded_flag
		    INTO   l_object_id,l_object_name,l_seeded_flag
		    FROM   cz_rp_entries
		    WHERE  cz_rp_entries.object_id = l_prp_ref(modelId)
		    AND    cz_rp_entries.object_type = 'PRP'
		    AND    cz_rp_entries.deleted_flag = '0';

                    SELECT devl_project_id BULK COLLECT INTO l_devl_project_tbl
                      FROM (SELECT devl_project_id
                              FROM cz_ps_prop_vals psp,
                                   cz_ps_nodes ps
                             WHERE psp.deleted_flag = '0'
                               AND ps.deleted_flag = '0'
                               AND ps.ps_node_id = psp.ps_node_id
                               AND property_id = l_prp_ref(modelId)
                            UNION
                            SELECT devl_project_id
                              FROM cz_item_type_properties itypr,
                                   cz_item_masters itm,
                                   cz_ps_nodes psnd
                             WHERE itypr.deleted_flag = '0'
                               AND itypr.item_type_id = itm.item_type_id
                               AND itm.deleted_flag = '0'
                               AND psnd.item_id = itm.item_id
                               AND psnd.deleted_flag = '0'
                               AND itypr.property_id = l_prp_ref(modelId));

		    IF (l_devl_project_tbl.COUNT > 0) THEN
			FOR J IN l_devl_project_tbl.FIRST..l_devl_project_tbl.LAST
			LOOP
	 		    SELECT enclosing_folder into l_encl_arc_fld
			    FROM  cz_rp_entries WHERE object_id = l_devl_project_tbl(j)
			    AND   object_type = 'PRJ';
			    IF ( NOT l_encl_idx_ref.EXISTS(l_encl_arc_fld) ) THEN
			     x_return_status := FND_API.G_RET_STS_ERROR;
			     FND_MESSAGE.SET_NAME('CZ','CZ_PROP_IN_USE');
  	        	     FND_MESSAGE.SET_TOKEN('NAME',l_object_name);
			     FND_MSG_PUB.ADD;
			     EXIT;
			    END IF;
			 END LOOP;
		     END IF;

		     BEGIN
		  	 SELECT 1
		   	 INTO   l_item_prop_count
		   	 FROM   CZ_ITEM_TYPE_PROPERTIES
		   	 WHERE  item_type_id IN (select item_type_id
						   from   cz_item_types
						   where  deleted_flag = '0')
		   	AND     property_id = l_prp_ref(modelId)
		   	AND     deleted_flag = '0';
		     EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		        l_prop_count := 0;
		     END;

		     IF (l_item_prop_count > 0) THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CZ','CZ_PROP_IN_USE');
		  	FND_MESSAGE.SET_TOKEN('NAME',l_object_name);
			FND_MSG_PUB.ADD;
		     END IF;

		     BEGIN
		     	SELECT 1
			INTO   l_ui_pages_count
			FROM   CZ_UI_PAGES
			WHERE  property_id = l_prp_ref(modelId)
			AND    deleted_flag = '0';
		     EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		        l_prop_count := 0;
		     END;
	     	     IF (l_item_prop_count > 0) THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CZ','CZ_PROP_IN_USE');
  			FND_MESSAGE.SET_TOKEN('NAME',l_object_name);
			FND_MSG_PUB.ADD;
		     END IF;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;
	END LOOP;
   END IF;

IF (l_umt_ref.COUNT > 0) THEN
   FOR modelId IN l_umt_ref.FIRST..l_umt_ref.LAST
   LOOP
   BEGIN
       SELECT object_id,name,seeded_flag
    	INTO  l_object_id,l_object_name,l_seeded_flag
    	FROM  cz_rp_entries
    	WHERE cz_rp_entries.object_id = l_umt_ref(modelId)
        AND   cz_rp_entries.object_type = 'UMT'
        AND   cz_rp_entries.deleted_flag = '0';

      l_ui_name_tbl.DELETE;
     	SELECT name
     	BULK
     	COLLECT
     	INTO   l_ui_name_tbl
     	FROM   cz_ui_defs
     	WHERE  cz_ui_defs.from_master_template_id = l_umt_ref(modelId)
     	AND    cz_ui_defs.deleted_flag = '0'
     	AND    cz_ui_defs.seeded_flag <> '1';

        IF (l_ui_name_tbl.count > 0 ) THEN
    	   x_return_status := FND_API.G_RET_STS_ERROR;
     	   FOR I IN l_ui_name_tbl.FIRST..l_ui_name_tbl.LAST
         LOOP
            FND_MESSAGE.SET_NAME('CZ', 'CZ_UMT_IN_USE');
  	      FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
	      FND_MESSAGE.SET_TOKEN('UI', l_ui_name_tbl(i));
  	      FND_MSG_PUB.ADD;
		EXIT;
         END LOOP;
 	 END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
    END;
    END LOOP;
END IF;

 IF (l_uct_ref.COUNT > 0) THEN
    FOR modelId IN l_uct_ref.FIRST..l_uct_ref.LAST
    LOOP
    BEGIN
     	SELECT object_id,name,seeded_flag
	INTO   l_object_id,l_object_name,l_seeded_flag
	FROM   cz_rp_entries
	WHERE  cz_rp_entries.object_id = l_uct_ref(modelId)
        AND  cz_rp_entries.object_type = 'UCT'
	AND    cz_rp_entries.deleted_flag = '0';

      l_ui_name_tbl.DELETE;
      SELECT name
	BULK
     	COLLECT
     	INTO   l_ui_name_tbl
     	FROM   cz_ui_defs
     	WHERE  cz_ui_defs.ui_def_id IN (SELECT ui_def_id
				       FROM   cz_ui_cont_type_templs
     				       WHERE  cz_ui_cont_type_templs.template_id = l_uct_ref(modelId)
     					 AND  cz_ui_cont_type_templs.deleted_flag = '0'
     					 AND  cz_ui_cont_type_templs.seeded_flag <> '1')
        AND   cz_ui_defs.deleted_flag = '0';

        IF (l_ui_name_tbl.count > 0 ) THEN
    	   x_return_status := FND_API.G_RET_STS_ERROR;
     	   FOR I IN l_ui_name_tbl.FIRST..l_ui_name_tbl.LAST
           LOOP
            FND_MESSAGE.SET_NAME('CZ', 'CZ_UCT_IN_USE');
  	      FND_MESSAGE.SET_TOKEN('NAME', l_object_name);
	      FND_MESSAGE.SET_TOKEN('UI', l_ui_name_tbl(i));
  	      FND_MSG_PUB.ADD;
           END LOOP;
 	 END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
    END;
    END LOOP;
END IF;

IF (l_usg_ref.COUNT > 0) THEN
   FOR modelId IN l_usg_ref.FIRST..l_usg_ref.LAST
   LOOP
      BEGIN
	   SELECT model_usage_id,name
	   INTO   l_usage_count,l_usage_name
	   FROM   cz_model_usages
	   WHERE  cz_model_usages.model_usage_id = l_usg_ref(modelId)
	   AND    cz_model_usages.in_use <> 'X';

	   BEGIN
	       SELECT 1
	       INTO   l_usage_count
	       FROM   cz_publication_usages
	       WHERE  cz_publication_usages.usage_id = l_usg_ref(modelId)
	       AND    cz_publication_usages.publication_id IN (SELECT publication_id
							   FROM  cz_model_publications
							   WHERE  cz_model_publications.deleted_flag = '0')
   	       AND    rownum < 2;
	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		l_usage_count := 0;
	  END;

 	  IF (l_usage_count = 1) THEN
	     FND_MESSAGE.SET_NAME('CZ','CZ_USG_IN_USE');
  	     FND_MESSAGE.SET_TOKEN('USAGE',l_usage_name);
  	     FND_MSG_PUB.ADD;
	     x_return_status := FND_API.g_ret_sts_error;
	     EXIT;
   	  END IF;

          v_nodes.DELETE;
          v_rules.DELETE;
          v_masks_nodes.DELETE;
          v_masks_rules.DELETE;
	  l_nodes_name_tbl.DELETE;
	  l_rules_name_tbl.DELETE;

   	  BEGIN
 	     SELECT ps_node_id,effective_usage_mask,devl_project_id,name
	     BULK
	     COLLECT
	     INTO   v_nodes,v_masks_nodes,l_nodes_project_tbl,l_nodes_name_tbl
 	     FROM   cz_ps_nodes
	     WHERE  effective_usage_mask NOT IN ('0', '0000000000000000')
	     ORDER BY effective_usage_mask;
   	  EXCEPTION
   	  WHEN OTHERS THEN
    	     NULL;
   	  END;

  	 BEGIN
	    SELECT rule_id,effective_usage_mask,devl_project_id,name
	    BULK
	    COLLECT
	    INTO   v_rules,v_masks_rules,l_rules_project_tbl,l_rules_name_tbl
	    FROM   cz_rules
	    WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
	    ORDER BY effective_usage_mask;
       EXCEPTION
       WHEN OTHERS THEN
     	   NULL;
   	 END;

        IF (v_nodes.COUNT > 0) THEN
     	   FOR I IN v_nodes.FIRST..v_nodes.LAST
	   LOOP
	   	l_map_has_usg_id := mapHasUsageId(l_usg_ref(modelId), v_masks_nodes(i));
	   	IF (l_map_has_usg_id = 1) THEN
		  SELECT enclosing_folder,name into l_encl_arc_fld,l_model_name
		   FROM  cz_rp_entries WHERE object_id = l_nodes_project_tbl(i)
		   AND   object_type = 'PRJ';
		   IF ( NOT l_encl_idx_ref.EXISTS(l_encl_arc_fld) ) THEN
		     FND_MESSAGE.SET_NAME('CZ','CZ_USG_IN_USE');
 		     FND_MESSAGE.SET_TOKEN('USAGE',l_usage_name);
		     FND_MESSAGE.SET_TOKEN('PSNODE',l_nodes_name_tbl(i));
		     FND_MESSAGE.SET_TOKEN('PROJECT',l_model_name);
		     FND_MSG_PUB.ADD;
		     x_return_status := FND_API.g_ret_sts_error;
		     EXIT;
	         END IF;
	      END IF;
	   END LOOP;
   	 END IF;

        IF (v_rules.COUNT > 0) THEN
         FOR I IN v_rules.FIRST..v_rules.LAST
	   LOOP
	      l_map_has_usg_id := mapHasUsageId(l_usg_ref(modelId), v_masks_rules(i));
	      IF (l_map_has_usg_id = 1) THEN
		  SELECT enclosing_folder,name into l_encl_arc_fld,l_model_name
		   FROM  cz_rp_entries WHERE object_id = l_nodes_project_tbl(i)
		   AND   object_type = 'PRJ';
		 IF ( NOT l_encl_idx_ref.EXISTS(l_encl_arc_fld) ) THEN
		   FND_MESSAGE.SET_NAME('CZ','CZ_USG_IN_USE');
 		   FND_MESSAGE.SET_TOKEN('USAGE',l_usage_name);
		   FND_MESSAGE.SET_TOKEN('RULE',l_rules_name_tbl(i));
		   FND_MESSAGE.SET_TOKEN('PROJECT',l_model_name);
		   FND_MSG_PUB.ADD;
		   x_return_status := FND_API.g_ret_sts_error;
		   EXIT;
	       END IF;
		END IF;
	   END LOOP;
        END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     NULL;
      END;
   END LOOP;
 END IF;
 FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
WHEN OTHERS THEN
   handle_Error(  p_procedure_name => 'is_repos_fld_deleteable',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END is_repos_fld_deleteable;

--------------------------------------------------
PROCEDURE delete_repository_folder (p_rp_folder_id IN NUMBER,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2)
IS
TYPE number_type_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE object_type_tbl IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
l_rp_fld_tbl        number_type_tbl;
l_object_id_tbl     number_type_tbl;
l_object_typ_tbl    object_type_tbl;
l_locked_models_tbl cz_security_pvt.number_type_tbl;
l_model_name        cz_devl_projects.name%TYPE;
l_template_name     cz_ui_templates.template_name%TYPE;
l_count   NUMBER := 0;
FAILED_TO_LOCK_PRJ EXCEPTION;
FAILED_TO_LOCK_UCT EXCEPTION;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status    := FND_API.g_ret_sts_success;
   x_msg_count        := 0;
   x_msg_data         := '';

   ---check if models in the repository folder are locked
   l_rp_fld_tbl.DELETE;
   SELECT object_id
   BULK
   COLLECT
   INTO   l_rp_fld_tbl
   FROM   cz_rp_entries
   WHERE  cz_rp_entries.deleted_flag = '0'
   AND    cz_rp_entries.object_type  = 'FLD'
   START WITH cz_rp_entries.object_type = 'FLD'
         AND cz_rp_entries.object_id = p_rp_folder_id
   CONNECT BY PRIOR cz_rp_entries.object_id = cz_rp_entries.enclosing_folder
         AND   PRIOR cz_rp_entries.object_type = 'FLD';

   is_repos_fld_deleteable (p_rp_folder_id,x_return_status,x_msg_count,x_msg_data);
   IF ( (x_return_status = FND_API.g_ret_sts_success)
	  AND (l_rp_fld_tbl.COUNT > 0) )  THEN
	FOR I IN l_rp_fld_tbl.FIRST..l_rp_fld_tbl.LAST
	LOOP
	  l_object_typ_tbl.DELETE;
	  l_object_id_tbl.DELETE;
	  BEGIN
        	SELECT  object_id, object_type
		BULK
		COLLECT
		INTO	l_object_id_tbl, l_object_typ_tbl
		FROM    cz_rp_entries
		WHERE   object_type <> 'FLD'
		AND     enclosing_folder = l_rp_fld_tbl(i)
		AND     deleted_flag = '0';
	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		NULL;
	  END;
	  IF (l_object_id_tbl.COUNT > 0) THEN
		FOR I IN l_object_id_tbl.FIRST..l_object_id_tbl.LAST
		LOOP
		    IF (l_object_typ_tbl(i) = 'PRJ') THEN
                        cz_security_pvt.lock_model(
                            p_api_version           =>   1.0,
                            p_model_id              =>   l_object_id_tbl(i),
                            p_lock_child_models     =>   FND_API.G_FALSE,
                            p_commit_flag           =>   FND_API.G_FALSE,
                            x_locked_entities       =>   l_locked_models_tbl,
                            x_return_status         =>   x_return_status,
                            x_msg_count             =>   x_msg_count,
                            x_msg_data              =>   x_msg_data);
                         IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		             SELECT name INTO l_model_name FROM cz_devl_projects
		             WHERE devl_project_id = l_object_id_tbl(i);
                             RAISE FAILED_TO_LOCK_PRJ;
                         END IF;
			 UPDATE cz_devl_projects
			 SET   deleted_flag = '1'
			 WHERE  devl_project_id = l_object_id_tbl(i) ;

		    ELSIF (l_object_typ_tbl(i) = 'UCT') THEN
                         cz_security_pvt.lock_template(
                            p_api_version           =>   1.0,
		     	    p_template_id           =>   l_object_id_tbl(i),
			    p_commit_flag           =>   FND_API.G_FALSE,
                            p_init_msg_list         =>   FND_API.G_FALSE,
		  	    x_return_status         =>   x_return_status,
			    x_msg_count             =>   x_msg_count,
			    x_msg_data              =>   x_msg_data);
                         IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		            SELECT template_name INTO l_template_name FROM cz_ui_templates
		            WHERE template_id = l_object_id_tbl(i);
                            RAISE FAILED_TO_LOCK_UCT;
                         END IF;
			 UPDATE cz_ui_templates
			  SET   deleted_flag = '1'
			 WHERE  template_id = l_object_id_tbl(i)
			 AND    ui_def_id = 0;

		    ELSIF (l_object_typ_tbl(i) = 'UMT') THEN
			 UPDATE cz_ui_defs
			  SET   deleted_flag = '1'
			 WHERE  ui_def_id = l_object_id_tbl(i);
		    ELSIF (l_object_typ_tbl(i) = 'USG') THEN
			 UPDATE cz_model_usages
			  SET   in_use = 'X'
			  WHERE  model_usage_id = l_object_id_tbl(i);
			  DELETE FROM CZ_RP_ENTRIES
			  WHERE OBJECT_TYPE = 'USG'
			  AND   OBJECT_ID = l_object_id_tbl(i);
		    ELSIF (l_object_typ_tbl(i) = 'ARC') THEN
			UPDATE cz_archives
			  SET  deleted_flag = '1'
			WHERE  archive_id = l_object_id_tbl(i);
		    ELSIF (l_object_typ_tbl(i) = 'EFF') THEN
			UPDATE cz_effectivity_sets
			SET    deleted_flag = '1'
			WHERE  effectivity_set_id = l_object_id_tbl(i);
		    ELSIF (l_object_typ_tbl(i) = 'PRP') THEN
			UPDATE cz_properties
			SET    deleted_flag = '1'
			WHERE  property_id = l_object_id_tbl(i);
		    END IF;
		 END LOOP;
	 	 COMMIT;
 	     END IF;
	     UPDATE  cz_rp_entries
             SET   deleted_flag = '1',
	             name = append_name (object_id,object_type,name)
             WHERE object_type <> 'FLD'
	       AND   enclosing_folder = l_rp_fld_tbl(i);
	END LOOP;

	l_count := l_rp_fld_tbl.COUNT;
	WHILE (l_count > 0)
	LOOP
	  UPDATE cz_rp_entries
          SET    deleted_flag = '1',
	           name = append_name (l_rp_fld_tbl(l_count), 'FLD', name)
          WHERE  object_type = 'FLD'
          AND    object_id = l_rp_fld_tbl(l_count);
	    l_count := l_count - 1;
	END LOOP;
   END IF;
EXCEPTION
 WHEN FAILED_TO_LOCK_PRJ THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     add_error_message(p_message_name   => 'CZ_CANNOT_LOC_PRJ',
                        p_token_name1    => 'PRJNAME',
                        p_token_value1   => l_model_name);
     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FAILED_TO_LOCK_UCT THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     add_error_message(p_message_name   => 'CZ_CANNOT_LOC_UCT',
                        p_token_name1    => 'UCTNAME',
                        p_token_value1   => l_template_name);
     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN OTHERS THEN
     handle_Error(p_procedure_name => 'delete_repository_folder',
                  p_error_message  => SQLERRM,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
END delete_repository_folder;

----------------------------------------
-- Returns -2 if all 64 usages plus 'Any Usage' are in use.
PROCEDURE NEW_USAGE (enclosingFolderId IN NUMBER,
                     usageId IN OUT NOCOPY NUMBER) AS
  try_id NUMBER := -1;
  nextVal NUMBER;
  CURSOR Xed_usages IS
    SELECT model_usage_id
    FROM cz_model_usages
    WHERE in_use = 'X'
    AND model_usage_id < 64
    ORDER BY model_usage_id;
BEGIN
   usageId := -2;
   OPEN Xed_usages;
   LOOP
    FETCH Xed_usages INTO try_id;
    EXIT WHEN Xed_usages%NOTFOUND;
    usageId := try_id;
    UPDATE cz_model_usages SET
    in_use = '1', name = 'New Usage ' || try_id
    WHERE model_usage_id = try_id AND in_use = 'X';
    INSERT INTO cz_rp_entries(object_id, object_type, enclosing_folder, name)
    VALUES (usageId, 'USG',enclosingFolderId, 'New Usage ' || try_id);
    EXIT;
   END LOOP;
   CLOSE Xed_usages;
END NEW_USAGE;

------------------------------------------------------
FUNCTION append_name(p_object_id IN NUMBER, p_object_type IN VARCHAR2, p_object_name IN VARCHAR2)
         RETURN VARCHAR2 IS
BEGIN
  RETURN '_d:'||p_object_type||':'||p_object_id||';'||p_object_name;
END append_name;

FUNCTION copy_name(p_object_id   IN NUMBER,
		   p_object_type IN VARCHAR2)
RETURN VARCHAR2

AS

original_name	cz_devl_projects.name%TYPE;
copy_name		cz_devl_projects.name%TYPE;
L 			PLS_INTEGER := 0;
x_error		BOOLEAN := FALSE;

BEGIN
	BEGIN
		SELECT	name
		INTO		original_name
		FROM		cz_rp_entries
		WHERE		object_id  = p_object_id
		 AND        object_type = p_object_type
		 AND		deleted_flag = '0';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		original_name := NULL;
	WHEN OTHERS THEN
		original_name := NULL;
	END;

	IF (original_name IS NOT NULL) THEN

		BEGIN

			SELECT	nvl(max(to_number(substr(SUBSTR(name, 1, instr(name,original_name, -1, 1)-1),7,instr(SUBSTR(name, 1, instr(name,original_name, -1, 1)-1),')',7)-7))),0)
			INTO		L
						FROM		cz_rp_entries
						WHERE	 name LIKE 'Copy (%) of '||original_name
						and  instr(SUBSTR(name, 1, instr(name,original_name, -1, 1)-1),'Copy (',7)=0
		                                and is_val_number(substr(SUBSTR(name, 1, instr(name,original_name, -1, 1)-1),7,instr(SUBSTR(name, 1, instr(name,original_name, -1, 1)-1),')',7)-7))='TRUE'
						AND     deleted_flag = '0' and object_type=p_object_type;

		--	L	 :=	to_number(substr(copy_name,7,instr(copy_name,')',7)-7));

		EXCEPTION
		WHEN	NO_DATA_FOUND THEN
			L := 0;
		END;
	END IF;

	L := L + 1;
	copy_name := 'Copy ('||to_char(L)||') of '||original_name;
	RETURN	copy_name ;
EXCEPTION
  WHEN OTHERS THEN
    RETURN copy_name ;
END copy_name;
------------------------------------------------------
FUNCTION parse_to_statement (p_rule_id IN NUMBER) RETURN VARCHAR2 IS

  EXPR_OPERATOR           CONSTANT PLS_INTEGER := 200;
  EXPR_LITERAL            CONSTANT PLS_INTEGER := 201;
  EXPR_PSNODE             CONSTANT PLS_INTEGER := 205;
  EXPR_PROP               CONSTANT PLS_INTEGER := 207;
  EXPR_PUNCT              CONSTANT PLS_INTEGER := 208;
  EXPR_SYS_PROP           CONSTANT PLS_INTEGER := 210;
  EXPR_CONSTANT           CONSTANT PLS_INTEGER := 211;
  EXPR_ARGUMENT           CONSTANT PLS_INTEGER := 221;
  EXPR_TEMPLATE           CONSTANT PLS_INTEGER := 222;
  EXPR_FORALL             CONSTANT PLS_INTEGER := 223;
  EXPR_ITERATOR           CONSTANT PLS_INTEGER := 224;
  EXPR_WHERE              CONSTANT PLS_INTEGER := 225;
  EXPR_COMPATIBLE         CONSTANT PLS_INTEGER := 226;
  EXPR_OPERATORBYNAME     CONSTANT PLS_INTEGER := 229;

  DATA_TYPE_INTEGER       CONSTANT PLS_INTEGER := 1;
  DATA_TYPE_DECIMAL       CONSTANT PLS_INTEGER := 2;
  DATA_TYPE_BOOLEAN       CONSTANT PLS_INTEGER := 3;
  DATA_TYPE_TEXT          CONSTANT PLS_INTEGER := 4;

  PS_NODE_TYPE_REFERENCE  CONSTANT PLS_INTEGER := 263;
  PS_NODE_TYPE_CONNECTOR  CONSTANT PLS_INTEGER := 264;

  EXPR_CONSTANT_E         CONSTANT PLS_INTEGER := 0;
  EXPR_CONSTANT_PI        CONSTANT PLS_INTEGER := 1;

  CONSTANT_PI             CONSTANT VARCHAR2(3) := 'pi';
  CONSTANT_E              CONSTANT VARCHAR2(3) := 'e';

  NewLine                 CONSTANT VARCHAR2(25) := FND_GLOBAL.NEWLINE;
  StoreNlsCharacters               VARCHAR2(16) := NlsNumericCharacters;

  CZ_RT_NO_SUCH_RULE      EXCEPTION;
  CZ_RT_INCORRECT_DATA    EXCEPTION;
  CZ_RT_MULTIPLE_ROOTS    EXCEPTION;
  CZ_RT_UNKNOWN_TYPE      EXCEPTION;
  CZ_RT_INCORRECT_PROP    EXCEPTION;
  CZ_RT_INCORRECT_NODE    EXCEPTION;
  CZ_RT_TEMPLATE_UNKNOWN  EXCEPTION;
  CZ_R_INCORRECT_DATA     EXCEPTION;
  CZ_RT_INCORRECT_TOKEN   EXCEPTION;
  CZ_RT_NO_SYSTEM_PROP    EXCEPTION;

  TYPE tStringTable       IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(15);
  TYPE tIntegerTable      IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(15);
  TYPE tNumberTable       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE tPsNodeName        IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPropertyName      IS TABLE OF cz_properties.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprId            IS TABLE OF cz_expression_nodes.expr_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParentId      IS TABLE OF cz_expression_nodes.expr_parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprType          IS TABLE OF cz_expression_nodes.expr_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprTemplateId    IS TABLE OF cz_expression_nodes.template_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprPsNodeId      IS TABLE OF cz_expression_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExplNodeId        IS TABLE OF cz_expression_nodes.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprPropertyId    IS TABLE OF cz_expression_nodes.property_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataType      IS TABLE OF cz_expression_nodes.data_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataValue     IS TABLE OF cz_expression_nodes.data_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataNumValue  IS TABLE OF cz_expression_nodes.data_num_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParamIndex    IS TABLE OF cz_expression_nodes.param_index%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgumentName  IS TABLE OF cz_expression_nodes.argument_name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgumentIndex IS TABLE OF cz_expression_nodes.argument_index%TYPE INDEX BY BINARY_INTEGER;

  h_PsNodeName            tPsNodeName;
  h_PropertyName          tPropertyName;
  h_FullName              tIntegerTable;

  h_ContextPath           tStringTable;
  h_ModelPath             tStringTable;
  h_NodeName              tStringTable;

  v_template_flag         cz_rules.presentation_flag%TYPE;
  v_devl_project_id       cz_rules.devl_project_id%TYPE;
  nLocalExprId            PLS_INTEGER := 1000;
  nDebug                  PLS_INTEGER;

  v_ExprId                tExprId;
  v_ExprParentId          tExprParentId;
  v_ExprType              tExprType;
  v_ExprTemplateId        tExprTemplateId;
  v_ExprPsNodeId          tExprPsNodeId;
  v_ExplNodeId            tExplNodeId;
  v_ExprPropertyId        tExprPropertyId;
  v_ExprDataType          tExprDataType;
  v_ExprDataValue         tExprDataValue;
  v_ExprDataNumValue      tExprDataNumValue;
  v_ExprParamIndex        tExprParamIndex;
  v_ExprArgumentName      tExprArgumentName;

  vi_ExprId               tExprId;
  vi_Name                 tStringTable;
  vi_Depth                tIntegerTable;
  vi_Occurrence           tIntegerTable;

  v_ChildrenIndex         t_int_array_tbl_type_idx_vc2;--tIntegerTable;
  v_NumberOfChildren      t_int_array_tbl_type_idx_vc2;--tIntegerTable;
  v_RuleText              VARCHAR2(32767);
  errmsg1                 VARCHAR2(2000);
  errmsg2                 VARCHAR2(2000);
  rootIndex               PLS_INTEGER;
  isCompatible            PLS_INTEGER := 0;
----------------------------------Bug6243144-------------------------------------------
  PROCEDURE SET_NLS_CHARACTERS(p_nls_characters IN VARCHAR2) IS
    BEGIN

      IF(NlsNumericCharacters <> StoreNlsCharacters)THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '''||p_nls_characters || '''';
      END IF;

    END;

---------------------------------------------------------------------------------------
  FUNCTION parse_expr_node (j IN PLS_INTEGER) RETURN VARCHAR2 IS

    v_RuleText           VARCHAR2(32767);
    v_Name               VARCHAR2(32767);
    v_Index              PLS_INTEGER;
    v_token              cz_rules.template_token%TYPE;
---------------------------------------------------------------------------------------
    FUNCTION generate_model_path (p_ps_node_id IN NUMBER) RETURN VARCHAR2 IS
      v_Name             VARCHAR2(32767);
    BEGIN

nDebug := 40;

      IF(h_ModelPath.EXISTS(p_ps_node_id))THEN RETURN h_ModelPath(p_ps_node_id); END IF;

      FOR c_name IN (SELECT name, parent_id FROM cz_ps_nodes
                      START WITH ps_node_id = p_ps_node_id
                    CONNECT BY PRIOR parent_id = ps_node_id) LOOP

        IF(v_Name IS NULL)THEN

          v_Name := '''' || REPLACE(c_name.name, '''', '\''') || '''';
          h_NodeName(p_ps_node_id) := v_Name;

          FOR c_node IN (SELECT NULL FROM cz_ps_nodes WHERE deleted_flag = '0'
                            AND devl_project_id = v_devl_project_id
                            AND name = c_name.name
                            AND ps_node_id <> p_ps_node_id)LOOP
            h_FullName(p_ps_node_id) := 1;
            EXIT;
          END LOOP;
          FOR c_node IN (SELECT NULL FROM cz_ps_nodes WHERE deleted_flag = '0'
                            AND devl_project_id IN
                              (SELECT component_id FROM cz_model_ref_expls
                                WHERE deleted_flag = '0'
                                  AND model_id = v_devl_project_id
                                  AND ps_node_type IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))
                            AND name = c_name.name)LOOP
            h_FullName(p_ps_node_id) := 1;
            EXIT;
          END LOOP;
        ELSIF(c_name.parent_id IS NOT NULL)THEN -- This is to exclude the root model name from the path.
          v_Name := '''' || REPLACE(c_name.name, '''', '\''') || '''' || FND_GLOBAL.LOCAL_CHR(8) || v_Name;
        END IF;
      END LOOP;

      h_ModelPath(p_ps_node_id) := v_Name;
     RETURN v_Name;
    END generate_model_path;
---------------------------------------------------------------------------------------
    FUNCTION generate_context_path (p_expl_id IN NUMBER) RETURN VARCHAR2 IS
      v_Node             NUMBER;
      v_Name             VARCHAR2(32767);
      v_ModelName        VARCHAR2(32767);
    BEGIN

nDebug := 50;

      --The path cashing is disabled because now it depends not only on expl_id, but also on the
      --participating node (see comment below).

      --IF(h_ContextPath.EXISTS(p_expl_id))THEN RETURN h_ContextPath(p_expl_id); END IF;

      v_Node := p_expl_id;

      WHILE(v_Node IS NOT NULL)LOOP

        IF(h_NodeType(v_Node) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

          v_ModelName := NULL;

          IF(h_NodeType(v_Node) = PS_NODE_TYPE_CONNECTOR AND

             --We do not need to add the connected model name if the participating node is the model
             --itself, otherwise it will be twice in the path.

             h_ComponentId(v_Node) <> v_ExprPsNodeId(j))THEN

            BEGIN

              SELECT name INTO v_ModelName FROM cz_ps_nodes
               WHERE ps_node_id = h_ComponentId(v_Node);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;

          IF(v_ModelName IS NOT NULL)THEN

            v_ModelName := FND_GLOBAL.LOCAL_CHR(7) || '''' || REPLACE(v_ModelName, '''', '\''') || '''';
          END IF;

          IF(v_Name IS NULL)THEN v_Name := generate_model_path(h_ReferringId(v_Node)) || v_ModelName;
          ELSE v_Name := generate_model_path(h_ReferringId(v_Node)) || v_ModelName || FND_GLOBAL.LOCAL_CHR(8) || v_Name;
          END IF;
        END IF;

        v_Node := h_ParentId(v_Node);
      END LOOP;

      --h_ContextPath(p_expl_id) := v_Name;
     RETURN v_Name;
    END generate_context_path;
---------------------------------------------------------------------------------------
    FUNCTION generate_name RETURN VARCHAR2 IS
      v_expl_id          NUMBER := v_ExplNodeId(j);
      v_this             VARCHAR2(32767);
      v_that             VARCHAR2(32767);
      v_subthis          VARCHAR2(32767);
      v_subthat          VARCHAR2(32767);
      v_name             VARCHAR2(32767);
      v_level            PLS_INTEGER;
      v_depth            PLS_INTEGER := 0;
      v_aux              PLS_INTEGER;
    BEGIN

nDebug := 60;

      IF(v_ExprPsNodeId(j) = h_ReferringId(v_expl_id))THEN
        v_expl_id := h_ParentId(v_expl_id);
      END IF;

      IF(v_expl_id IS NOT NULL)THEN v_this := generate_context_path(v_expl_id); END IF;
      v_name := generate_model_path(v_ExprPsNodeId(j));

      IF(v_this IS NULL)THEN
        IF(NOT h_FullName.EXISTS(v_ExprPsNodeId(j)))THEN v_name := h_NodeName(v_ExprPsNodeId(j)); END IF;
      ELSE

        FOR i IN 1..v_NodeId.COUNT LOOP

          IF(h_ComponentId(v_NodeId(i)) = h_ComponentId(v_expl_id) AND v_NodeId(i) <> v_expl_id)THEN

            v_that := generate_context_path(v_NodeId(i));
            v_level := 1;

            LOOP

              v_subthis := SUBSTR(v_this, INSTR(v_this, FND_GLOBAL.LOCAL_CHR(8), -1, v_level) + 1);
              v_subthat := SUBSTR(v_that, INSTR(v_that, FND_GLOBAL.LOCAL_CHR(8), -1, v_level) + 1);

              IF(v_subthis = v_this)THEN EXIT; END IF;
              IF(v_subthat = v_that)THEN v_Level := v_Level + 1; EXIT; END IF;
              IF(v_subthis <> v_subthat)THEN EXIT; END IF;

              v_level := v_level + 1;
            END LOOP;

            IF(v_level > v_depth)THEN v_depth := v_level; END IF;
          END IF;
        END LOOP;

        IF(v_depth = 0)THEN

          --Bug #4590481 - in this case we also need to concatenate the path. If the full path is not
          --required, the second line will reset it to just the node name.

          v_name := v_this || FND_GLOBAL.LOCAL_CHR(8) || v_name;

          IF(NOT h_FullName.EXISTS(v_ExprPsNodeId(j)))THEN v_name := h_NodeName(v_ExprPsNodeId(j)); END IF;
        ELSE v_name := SUBSTR(v_this, INSTR(v_this, FND_GLOBAL.LOCAL_CHR(8), -1, v_depth) + 1) || FND_GLOBAL.LOCAL_CHR(8) || v_name;
        END IF;
      END IF;

      v_aux := 1;

      FOR i IN 1..vi_Name.COUNT LOOP
        IF(v_name = vi_Name(i))THEN v_aux := v_aux + 1; END IF;
      END LOOP;

      v_Index := vi_ExprId.COUNT + 1;
      vi_ExprId(v_Index) := v_ExprId(j);
      vi_Name(v_Index) := v_name;
      vi_Occurrence(v_Index) := v_aux;

      v_Level := 1;
      WHILE(INSTR(v_name, FND_GLOBAL.LOCAL_CHR(8), 1, v_Level) <> 0)LOOP v_Level := v_Level + 1; END LOOP;
      vi_Depth(v_Index) := v_Level;

      v_name := REPLACE(v_name, '''' || FND_GLOBAL.LOCAL_CHR(7) || '''', '''.''');
      v_name := REPLACE(v_name, '''' || FND_GLOBAL.LOCAL_CHR(8) || '''', '''.''');

     RETURN v_name;
    END generate_name;
---------------------------------------------------------------------------------------
  BEGIN

    IF(v_ExprType(j) IN (EXPR_OPERATOR, EXPR_OPERATORBYNAME))THEN

nDebug := 1000;

      --First correct a data_type upgrade problem from czrules1.sql. This is an operator, its children
      --has not been generated into text yet. We will update data_type and data_num_value for children
      --in memory, if necessary, so that children will or will not be enclosed in quotes correctly. At
      --the end, we physically update the columns in cz_expression_nodes.

      IF(v_ExprTemplateId(j) IN
          (318,320,321,322,323,350,351,352,353,399,401,402,403,
           404,405,406,407,408,409,410,411,412,413,414,415,416,
           417,418,430,431,432,433,434,435,436,437,438,439,551)
         AND v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        --This is one of the operators with only numeric operands or = or <>.

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          IF(v_ExprType(v_Index) = EXPR_LITERAL AND v_ExprDataType(v_Index) IS NULL AND
             v_ExprDataNumValue(v_Index) IS NULL)THEN

            --This is a literal child of the operator with undefined data_type and data_num_value.
            --Here we fix data only for such operands.

            BEGIN

              v_ExprDataNumValue(v_Index) := TO_NUMBER(v_ExprDataValue(v_Index));
              v_ExprDataType(v_Index) := DATA_TYPE_DECIMAL;
              IF(v_ExprTemplateId(j) = 551)THEN v_ExprDataType(v_Index) := DATA_TYPE_INTEGER; END IF;

            EXCEPTION
              WHEN OTHERS THEN
                v_ExprDataType(v_Index) := DATA_TYPE_TEXT;
            END;
          END IF;

          v_Index := v_Index + 1;
          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                     (v_ExprParentId(v_Index) IS NULL) OR
                     (v_ExprParentId(v_Index) <> v_ExprId(j));
        END LOOP;
      END IF;

      --Done with the data fix for data_type, data_num_value population after czrules1.sql.

      IF(v_ExprType(j) = EXPR_OPERATORBYNAME)THEN

         FOR n IN 1..h_RuleId.COUNT LOOP

           IF(h_RuleName(h_RuleId(n)) = v_ExprArgumentName(j))THEN v_ExprTemplateId(j) := h_RuleId(n); EXIT; END IF;
         END LOOP;
      END IF;

      IF(NOT h_TemplateToken.EXISTS(v_ExprTemplateId(j)))THEN
        errmsg1 := TO_CHAR(v_ExprTemplateId(j));
        RAISE CZ_RT_INCORRECT_TOKEN;
      END IF;

      v_token := h_TemplateToken(v_ExprTemplateId(j));

      IF((v_token IS NULL AND UPPER(h_RuleName(v_ExprTemplateId(j))) NOT IN ('CONTRIBUTESTO', 'CONSUMESFROM', 'ADDSTO', 'SUBTRACTSFROM')) OR
          v_NumberOfChildren(v_ExprId(j)) > 2)THEN

        IF(UPPER(h_RuleName(v_ExprTemplateId(j))) <> 'NONE')THEN
          v_RuleText := NVL(h_RuleName(v_ExprTemplateId(j)), v_token) || '(';
        END IF;

        IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

          v_Index := v_ChildrenIndex(v_ExprId(j));

          LOOP

            v_RuleText := v_RuleText || parse_expr_node(v_Index);
            v_Index := v_Index + 1;

            EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                      (v_ExprParentId(v_Index) IS NULL) OR
                      (v_ExprParentId(v_Index) <> v_ExprId(j));

            v_RuleText := v_RuleText || ', ';
          END LOOP;
        END IF;

        IF(UPPER(h_RuleName(v_ExprTemplateId(j))) <> 'NONE')THEN
          v_RuleText := v_RuleText || ')';
        END IF;
      ELSE

        IF(v_token IS NULL)THEN v_token := h_RuleName(v_ExprTemplateId(j)); END IF;

        IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

          v_Index := v_ChildrenIndex(v_ExprId(j));

          IF(v_NumberOfChildren(v_ExprId(j)) = 2)THEN
            IF(UPPER(v_token) IN ('CONTRIBUTESTO', 'CONSUMESFROM', 'ADDSTO', 'SUBTRACTSFROM'))THEN

              IF(UPPER(v_token) = 'CONSUMESFROM')THEN
                v_RuleText := 'Contribute ((' || parse_expr_node(v_Index) || ') * -1) TO';
              ELSIF (UPPER(v_token) = 'CONTRIBUTESTO') THEN
                v_RuleText := 'Contribute ' || parse_expr_node(v_Index) || ' TO';
              ELSIF (UPPER(v_token) = 'ADDSTO') THEN
                v_RuleText := 'Add ' || parse_expr_node(v_Index) || ' TO';
              ELSIF (UPPER(v_token) = 'SUBTRACTSFROM') THEN
                v_RuleText := 'Subtract ' || parse_expr_node(v_Index) || ' FROM';
              END IF;
              v_token := NULL;
            ELSE

              v_RuleText := parse_expr_node(v_Index) || ' ';
            END IF;

            v_Index := v_Index + 1;
          END IF;

          IF(UPPER(v_token) = 'CONSUMESFROM')THEN
            v_RuleText := v_RuleText || 'Contribute ((' || parse_expr_node(v_Index) || ') * -1) TO';
          ELSIF(UPPER(v_token) = 'CONTRIBUTESTO')THEN
            v_RuleText := v_RuleText || 'Contribute ' || parse_expr_node(v_Index) || ' TO';
          ELSIF(UPPER(v_token) = 'ADDSTO')THEN
            v_RuleText := v_RuleText || 'Add ' || parse_expr_node(v_Index) || ' TO';
          ELSIF(UPPER(v_token) = 'SUBTRACTSFROM')THEN
            v_RuleText := v_RuleText || 'Subtract ' || parse_expr_node(v_Index) || ' FROM';
          ELSE
            v_RuleText := v_RuleText || v_token || ' ' || parse_expr_node(v_Index);
          END IF;
        ELSE

          v_RuleText := v_token;
        END IF;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_LITERAL)THEN

nDebug := 1001;

      IF(v_ExprPropertyId(j) IS NULL)THEN
        IF(v_ExprDataType(j) IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

          v_RuleText := NVL ( NVL ( v_ExprDataNumValue(j), v_ExprDataValue(j)), '1');

        ELSIF(v_ExprDataType(j) = DATA_TYPE_TEXT OR (v_ExprDataType(j) IS NULL AND v_ExprDataNumValue(j) IS NULL))THEN

          v_RuleText := '"' || v_ExprDataValue(j) || '"';

        ELSE

          v_RuleText := NVL ( NVL ( v_ExprDataNumValue(j), v_ExprDataValue(j)), '1');

        END IF;
      ELSE

        --This is a literal representing property name.

        v_RuleText := '.Property("' || v_ExprDataValue(j) || '")';
      END IF;

    ELSIF(v_ExprType(j) = EXPR_PSNODE)THEN

nDebug := 1002;

      v_RuleText := generate_name;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_PROP)THEN

nDebug := 1003;

      IF(NOT h_PropertyName.EXISTS(v_ExprPropertyId(j)))THEN

        --We don't want to account for deleted_flag in this query because we want to parse a rule even
        --if it refers to a deleted property instead of ignoring the rule.

        BEGIN
          SELECT name INTO v_Name FROM cz_properties
           WHERE property_id = v_ExprPropertyId(j);

          h_PropertyName(v_ExprPropertyId(j)) := v_Name;

        EXCEPTION
          WHEN OTHERS THEN
            errmsg1 := TO_CHAR(v_ExprId(j));
            errmsg2 := TO_CHAR(v_ExprPropertyId(j));
            RAISE CZ_RT_INCORRECT_PROP;
        END;
      ELSE

        v_Name := h_PropertyName(v_ExprPropertyId(j));
      END IF;

      v_RuleText := '.Property("' || v_Name || '")';

    ELSIF(v_ExprType(j) = EXPR_SYS_PROP)THEN

nDebug := 1004;

      IF(v_ExprTemplateId(j) IS NULL)THEN
        RAISE CZ_RT_NO_SYSTEM_PROP;
      END IF;

      IF(isCompatible = 0)THEN v_RuleText := '.' || h_RuleName(v_ExprTemplateId(j)) || '()'; END IF;

    ELSIF(v_ExprType(j) = EXPR_ARGUMENT)THEN

nDebug := 1005;

      v_RuleText := v_ExprArgumentName(j);
      IF(SUBSTR(v_RuleText, 1, 1) <> FND_GLOBAL.LOCAL_CHR(38))THEN

        v_RuleText := FND_GLOBAL.LOCAL_CHR(38) || v_RuleText;
      END IF;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_TEMPLATE)THEN

nDebug := 1006;

      v_RuleText := '@' || h_RuleName(v_ExprTemplateId(j));

    ELSIF(v_ExprType(j) = EXPR_FORALL)THEN

nDebug := 1007;

      v_RuleText := ' FOR ALL' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j)) + v_NumberOfChildren(v_ExprId(j)) - 1;

        IF(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j) AND
           v_ExprType(v_Index) NOT IN (EXPR_ITERATOR, EXPR_WHERE))THEN
          IF(v_ExprParentId(j) IS NULL)THEN
            v_RuleText := parse_expr_node(v_Index) || v_RuleText;
          ELSE
            v_RuleText := '{ COLLECT ' || parse_expr_node(v_Index) || v_RuleText;
          END IF;
        END IF;

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprType(v_Index) NOT IN (EXPR_ITERATOR, EXPR_WHERE)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          IF(v_ExprType(v_Index - 1) = EXPR_ITERATOR AND v_ExprType(v_Index) = EXPR_ITERATOR)THEN
            v_RuleText := v_RuleText || ',';
          END IF;
          v_RuleText := v_RuleText || NewLine;
        END LOOP;
        IF(v_ExprParentId(j) IS NOT NULL)THEN v_RuleText := v_RuleText || '}'; END IF;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_ITERATOR)THEN

nDebug := 1008;

      IF(isCompatible = 1)THEN v_RuleText := v_ExprArgumentName(j) || ' OF ';
      ELSE v_RuleText := v_ExprArgumentName(j) || ' IN {'; END IF;
      IF(SUBSTR(v_RuleText, 1, 1) <> FND_GLOBAL.LOCAL_CHR(38))THEN

        v_RuleText := FND_GLOBAL.LOCAL_CHR(38) || v_RuleText;
      END IF;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          v_RuleText := v_RuleText || ', ';
        END LOOP;
      END IF;

      IF(isCompatible = 0)THEN v_RuleText := v_RuleText || '}'; END IF;

    ELSIF(v_ExprType(j) = EXPR_WHERE)THEN

nDebug := 1009;

      v_RuleText := ' WHERE' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_COMPATIBLE)THEN

nDebug := 1010;

      isCompatible := 1;
      v_RuleText := 'COMPATIBLE' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          IF(v_ExprType(v_Index - 1) = EXPR_ITERATOR AND v_ExprType(v_Index) = EXPR_ITERATOR)THEN
            v_RuleText := v_RuleText || ',';
          END IF;
          v_RuleText := v_RuleText || NewLine;
        END LOOP;
      END IF;
      isCompatible := 0;
    ELSIF(v_ExprType(j) = EXPR_CONSTANT)THEN

      IF(v_ExprTemplateId(j) =  EXPR_CONSTANT_E)THEN

        v_RuleText := CONSTANT_E;
      ELSE

        v_RuleText := CONSTANT_PI;
      END IF;
    ELSE
      errmsg1 := TO_CHAR(v_ExprId(j));
      errmsg2 := TO_CHAR(v_ExprType(j));
      RAISE CZ_RT_UNKNOWN_TYPE;
    END IF;

   RETURN v_RuleText;
  END parse_expr_node;
---------------------------------------------------------------------------------------
FUNCTION parse_template_application (j IN PLS_INTEGER) RETURN VARCHAR2 IS

  h_mapExprId          t_int_array_tbl_type_idx_vc2;--tIntegerTable;
  jdef                 PLS_INTEGER;
  templateStart        PLS_INTEGER;
  templateEnd          PLS_INTEGER;
  v_index              PLS_INTEGER;

  v_ParamIndex         tIntegerTable;
  v_multiply_id        NUMBER;
  v_operator_index     PLS_INTEGER;
  v_iterator_index     PLS_INTEGER;
  v_argument_index     PLS_INTEGER;
  v_literal_index      PLS_INTEGER;
  l_options_applied    PLS_INTEGER;

  v_tTmplNodeId        tExplNodeId;
  v_tTmplType          tExprType;
  v_tTmplId            tExprId;
  v_tTmplParentId      tExprParentId;
  v_tTmplTemplateId    tExprTemplateId;
  v_tTmplPsNodeId      tExplNodeId;
  v_tTmplDataType      tExprDataType;
  v_tTmplDataValue     tExprDataValue;
  v_tTmplDataNumValue  tExprDataValue;
  v_tTmplPropertyId    tExprPropertyId;
  v_tTmplArgumentIndex tExprArgumentIndex;
  v_tTmplArgumentName  tExprArgumentName;
---------------------------------------------------------------------------------------
PROCEDURE read_template (p_template_id IN NUMBER) IS
BEGIN
  SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, template_id,
         ps_node_id, data_value, property_id, argument_index,
         argument_name, data_num_value, data_type
    BULK COLLECT INTO v_tTmplNodeId, v_tTmplType, v_tTmplId, v_tTmplParentId, v_tTmplTemplateId,
                      v_tTmplPsNodeId, v_tTmplDataValue, v_tTmplPropertyId,
                      v_tTmplArgumentIndex, v_tTmplArgumentName, v_tTmplDataNumValue, v_tTmplDataType
    FROM cz_expression_nodes
   WHERE rule_id = p_template_id
     AND expr_type <> EXPR_PUNCT
     AND deleted_flag = '0'
   ORDER BY expr_parent_id, seq_nbr;

   IF(v_tTmplId.COUNT = 0)THEN
     RAISE CZ_RT_TEMPLATE_UNKNOWN;
   END IF;
END read_template;
---------------------------------------------------------------------------------------
FUNCTION copy_expression_node (j_from IN PLS_INTEGER, j_parent IN PLS_INTEGER) RETURN PLS_INTEGER IS
  j_to  PLS_INTEGER;
BEGIN

nDebug := 10;

   j_to := v_ExprId.COUNT + 1;
   nLocalExprId := nLocalExprId + 1;

   v_ExprId(j_to) := nLocalExprId;
   v_ExprParentId(j_to) := j_parent;

   v_ExplNodeId(j_to)       := v_ExplNodeId(j_from);
   v_ExprType(j_to)         := v_ExprType(j_from);
   v_ExprTemplateId(j_to)   := v_ExprTemplateId(j_from);
   v_ExprParamIndex(j_to)   := v_ExprParamIndex(j_from);
   v_ExprPsNodeId(j_to)     := v_ExprPsNodeId(j_from);
   v_ExprDataType(j_to)     := v_ExprDataType(j_from);
   v_ExprDataValue(j_to)    := v_ExprDataValue(j_from);
   v_ExprDataNumValue(j_to) := v_ExprDataNumValue(j_from);
   v_ExprPropertyId(j_to)   := v_ExprPropertyId(j_from);
   v_ExprArgumentName(j_to) := v_ExprArgumentName(j_from);

nDebug := 19;

 RETURN j_to;
END copy_expression_node;
---------------------------------------------------------------------------------------
PROCEDURE copy_expression_tree (j_from IN PLS_INTEGER, j_parent IN PLS_INTEGER) IS
  j_child     PLS_INTEGER;
  j_children  t_int_array_tbl_type_idx_vc2;--tIntegerTable;
BEGIN

nDebug := 20;

  IF(v_ChildrenIndex.EXISTS(v_ExprId(j_from)))THEN

    j_child := v_ChildrenIndex(v_ExprId(j_from));

    WHILE(v_ExprParentId(j_child) = v_ExprId(j_from))LOOP

      j_children(j_child) := copy_expression_node(j_child, j_parent);
      j_child := j_child + 1;
    END LOOP;

    j_child := v_ChildrenIndex(v_ExprId(j_from));

    WHILE(v_ExprParentId(j_child) = v_ExprId(j_from))LOOP

      copy_expression_tree(j_child, j_children(j_child));
      j_child := j_child + 1;
    END LOOP;
  END IF;

nDebug := 29;

END copy_expression_tree;
---------------------------------------------------------------------------------------
PROCEDURE store_expr_node (j IN PLS_INTEGER) IS
BEGIN
    v_ExprParentId(-1)     := v_ExprParentId(j);
    v_ExplNodeId(-1)       := v_ExplNodeId(j);
    v_ExprType(-1)         := v_ExprType(j);
    v_ExprTemplateId(-1)   := v_ExprTemplateId(j);
    v_ExprPsNodeId(-1)     := v_ExprPsNodeId(j);
    v_ExprDataType(-1)     := v_ExprDataType(j);
    v_ExprDataValue(-1)    := v_ExprDataValue(j);
    v_ExprDataNumValue(-1) := v_ExprDataNumValue(j);
    v_ExprPropertyId(-1)   := v_ExprPropertyId(j);
    v_ExprArgumentName(-1) := v_ExprArgumentName(j);
    v_ExprParamIndex(-1)   := v_ExprParamIndex(j);
    v_ExprId(-1)           := v_ExprId(j);
END store_expr_node;
---------------------------------------------------------------------------------------
PROCEDURE restore_expr_node (j IN PLS_INTEGER) IS
BEGIN
    v_ExprParentId(j)     := v_ExprParentId(-1);
    v_ExplNodeId(j)       := v_ExplNodeId(-1);
    v_ExprType(j)         := v_ExprType(-1);
    v_ExprTemplateId(j)   := v_ExprTemplateId(-1);
    v_ExprPsNodeId(j)     := v_ExprPsNodeId(-1);
    v_ExprDataType(j)     := v_ExprDataType(-1);
    v_ExprDataValue(j)    := v_ExprDataValue(-1);
    v_ExprDataNumValue(j) := v_ExprDataNumValue(-1);
    v_ExprPropertyId(j)   := v_ExprPropertyId(-1);
    v_ExprArgumentName(j) := v_ExprArgumentName(-1);
    v_ExprParamIndex(j)   := v_ExprParamIndex(-1);
    v_ExprId(j)           := v_ExprId(-1);

    v_ExprParentId.DELETE(-1);
    v_ExplNodeId.DELETE(-1);
    v_ExprType.DELETE(-1);
    v_ExprTemplateId.DELETE(-1);
    v_ExprPsNodeId.DELETE(-1);
    v_ExprDataType.DELETE(-1);
    v_ExprDataValue.DELETE(-1);
    v_ExprDataNumValue.DELETE(-1);
    v_ExprPropertyId.DELETE(-1);
    v_ExprArgumentName.DELETE(-1);
    v_ExprParamIndex.DELETE(-1);
    v_ExprId.DELETE(-1);
END restore_expr_node;
---------------------------------------------------------------------------------------
PROCEDURE shift_nodes_right (j_start IN PLS_INTEGER, j_end IN PLS_INTEGER) IS
BEGIN
  FOR i IN REVERSE j_start..j_end LOOP
    v_ExprParentId(i + 1)     := v_ExprParentId(i);
    v_ExplNodeId(i + 1)       := v_ExplNodeId(i);
    v_ExprType(i + 1)         := v_ExprType(i);
    v_ExprTemplateId(i + 1)   := v_ExprTemplateId(i);
    v_ExprPsNodeId(i + 1)     := v_ExprPsNodeId(i);
    v_ExprDataType(i + 1)     := v_ExprDataType(i);
    v_ExprDataValue(i + 1)    := v_ExprDataValue(i);
    v_ExprDataNumValue(i + 1) := v_ExprDataNumValue(i);
    v_ExprPropertyId(i + 1)   := v_ExprPropertyId(i);
    v_ExprArgumentName(i + 1) := v_ExprArgumentName(i);
    v_ExprParamIndex(i + 1)   := v_ExprParamIndex(i);
    v_ExprId(i + 1)           := v_ExprId(i);
  END LOOP;
END shift_nodes_right;
---------------------------------------------------------------------------------------
BEGIN

nDebug := 30;

  read_template(v_ExprTemplateId(j));
  templateStart := v_ExprId.COUNT + 1;
  l_options_applied := 0;

  FOR i IN 1..v_tTmplId.COUNT LOOP
    IF(v_tTmplType(i) = EXPR_ARGUMENT AND v_tTmplArgumentIndex(i) IS NOT NULL)THEN

      --This is an argument, may correspond to a collection of paramaters in the template
      --application.

      jdef := 0;

      FOR ii IN 1..templateStart - 1 LOOP
        IF(v_ExprParamIndex(ii) = v_tTmplArgumentIndex(i))THEN

          jdef := 1;
          v_index := v_ExprId.COUNT + 1;
          nLocalExprId := nLocalExprId + 1;

          IF(UPPER(h_RuleName(v_ExprTemplateId(j))) IN ('SIMPLENUMERICRULE', 'SIMPLEACCUMULATORRULE'))THEN
            IF(v_tTmplArgumentIndex(i) = 1)THEN

              --This is the first argument of the SimpleNumericRule template application. If this is a
              --collection, we will have to rewrite the rule as a FORALL expression. Store the indexes
              --of these nodes for later use.

              v_ParamIndex(v_ParamIndex.COUNT + 1) := v_index;

              --Also, check if there is Options() property applied to the first argument - in this case
              --we again need a FORALL - bug #5350405.

              IF(v_ChildrenIndex.EXISTS(v_ExprId(ii)) AND
                 h_RuleName.EXISTS(v_ExprTemplateId(v_ChildrenIndex(v_ExprId(ii)))) AND
                 UPPER(h_RuleName(v_ExprTemplateId(v_ChildrenIndex(v_ExprId(ii))))) = 'OPTIONS')THEN

                 l_options_applied := 1;
              END IF;
            ELSIF(v_tTmplArgumentIndex(i) = 2)THEN

              --This is the literal operand of the 'Multiply' operator.

              v_literal_index := v_index;

            ELSIF(v_tTmplArgumentIndex(i) = 3)THEN

              --This is the third argument of the SimpleNumericRule template application. Remember the
              --index for possible later use in case of converting to FORALL.

              v_operator_index := v_index;
            END IF;
          END IF;

          v_ExprId(v_index)           := nLocalExprId;
          h_mapExprId(v_ExprId(ii))   := nLocalExprId;

          --If this entry gets overwritten many times, it is not a problem because in this case it
          --will never be used.

          h_mapExprId(v_tTmplId(i))   := nLocalExprId;

          v_ExprParentId(v_index)     := v_tTmplParentId(i);
          v_ExplNodeId(v_index)       := v_ExplNodeId(ii);
          v_ExprType(v_index)         := v_ExprType(ii);
          v_ExprTemplateId(v_index)   := v_ExprTemplateId(ii);
          v_ExprPsNodeId(v_index)     := v_ExprPsNodeId(ii);
          v_ExprDataType(v_index)     := v_ExprDataType(ii);
          v_ExprDataValue(v_index)    := v_ExprDataValue(ii);
          v_ExprDataNumValue(v_index) := v_ExprDataNumValue(ii);
          v_ExprPropertyId(v_index)   := v_ExprPropertyId(ii);
          v_ExprArgumentName(v_index) := v_ExprArgumentName(ii);
          v_ExprParamIndex(v_index)   := v_ExprParamIndex(ii);

          IF(v_ExprType(v_index) = EXPR_TEMPLATE)THEN v_ExprType(v_index) := EXPR_OPERATOR; END IF;
        END IF;
      END LOOP;
    ELSE

      --This is a regular node in the template definition, just copy.

      v_index := v_ExprId.COUNT + 1;
      nLocalExprId := nLocalExprId + 1;

      v_ExprId(v_index)           := nLocalExprId;
      h_mapExprId(v_tTmplId(i))    := nLocalExprId;

      v_ExprParentId(v_index)     := v_tTmplParentId(i);
      v_ExplNodeId(v_index)       := v_tTmplNodeId(i);
      v_ExprType(v_index)         := v_tTmplType(i);
      v_ExprTemplateId(v_index)   := v_tTmplTemplateId(i);
      v_ExprPsNodeId(v_index)     := v_tTmplPsNodeId(i);
      v_ExprDataType(v_index)     := v_tTmplDataType(i);
      v_ExprDataValue(v_index)    := v_tTmplDataValue(i);
      v_ExprDataNumValue(v_index) := v_tTmplDataNumValue(i);
      v_ExprPropertyId(v_index)   := v_tTmplPropertyId(i);
      v_ExprArgumentName(v_index) := v_tTmplArgumentName(i);

      IF(UPPER(h_RuleName(v_ExprTemplateId(j))) IN ('SIMPLENUMERICRULE', 'SIMPLEACCUMULATORRULE') AND
         UPPER(h_RuleName(v_ExprTemplateId(v_index))) = 'MULTIPLY')THEN

        --This is a SimpleNumericRule template application which we may need to convert to a FORALL rule.
        --Store the expr_node_id of the 'multiply' operator for possible later use.

        v_multiply_id := v_ExprId(v_index);
        v_ExprParamIndex(v_index) := NULL;

      END IF;
    END IF;
  END LOOP;

nDebug := 31;

  templateEnd := v_ExprId.COUNT;

  FOR i IN templateStart..templateEnd LOOP
    IF(v_ExprParentId(i) IS NOT NULL)THEN

      IF(NOT h_mapExprId.EXISTS(v_ExprParentId(i)))THEN RAISE CZ_R_INCORRECT_DATA; END IF;
      v_ExprParentId(i) := h_mapExprId(v_ExprParentId(i));
    END IF;
  END LOOP;

  FOR i IN 1..templateStart - 1 LOOP
    IF(h_mapExprId.EXISTS(v_ExprId(i)))THEN

      copy_expression_tree(i, h_mapExprId(v_ExprId(i)));
    END IF;
  END LOOP;

  --Convert to FORALL if necessary.

  IF(v_ParamIndex.COUNT > 1 OR l_options_applied = 1)THEN

    v_index := v_ExprId.COUNT + 1;

    --Create the FORALL node.

    v_ExprParentId(v_index)     := NULL;
    v_ExplNodeId(v_index)       := NULL;
    v_ExprType(v_index)         := EXPR_FORALL;
    v_ExprTemplateId(v_index)   := NULL;
    v_ExprPsNodeId(v_index)     := NULL;
    v_ExprDataType(v_index)     := NULL;
    v_ExprDataValue(v_index)    := NULL;
    v_ExprDataNumValue(v_index) := NULL;
    v_ExprPropertyId(v_index)   := NULL;
    v_ExprArgumentName(v_index) := NULL;
    v_ExprParamIndex(v_index)   := NULL;

    nLocalExprId := nLocalExprId + 1;
    v_ExprId(v_index)           := nLocalExprId;

    --Make the rule operator a child of the FORALL.

    v_ExprParentId(v_operator_index) := nLocalExprId;
    v_index := v_index + 1;

    --Create the iterator node as a child of the FORALL.

    v_ExprParentId(v_index)     := nLocalExprId;
    v_ExplNodeId(v_index)       := NULL;
    v_ExprType(v_index)         := EXPR_ITERATOR;
    v_ExprTemplateId(v_index)   := NULL;
    v_ExprPsNodeId(v_index)     := NULL;
    v_ExprDataType(v_index)     := NULL;
    v_ExprDataValue(v_index)    := NULL;
    v_ExprDataNumValue(v_index) := NULL;
    v_ExprPropertyId(v_index)   := NULL;
    v_ExprArgumentName(v_index) := FND_GLOBAL.LOCAL_CHR(38) || 'x';
    v_ExprParamIndex(v_index)   := NULL;

    nLocalExprId := nLocalExprId + 1;
    v_ExprId(v_index)           := nLocalExprId;
    v_iterator_index            := v_index;

    --Move all the 'Multiply' operands to be the children of the iterator.

    FOR i IN 1..v_ParamIndex.COUNT LOOP

      v_ExprParentId(v_ParamIndex(i)) := nLocalExprId;
    END LOOP;
    v_index := v_index + 1;

    --Create the argument node as a child of the 'Multiply' operator.

    v_ExprParentId(v_index)     := v_multiply_id;
    v_ExplNodeId(v_index)       := NULL;
    v_ExprType(v_index)         := EXPR_ARGUMENT;
    v_ExprTemplateId(v_index)   := NULL;
    v_ExprPsNodeId(v_index)     := NULL;
    v_ExprDataType(v_index)     := NULL;
    v_ExprDataValue(v_index)    := NULL;
    v_ExprDataNumValue(v_index) := NULL;
    v_ExprPropertyId(v_index)   := NULL;
    v_ExprArgumentName(v_index) := FND_GLOBAL.LOCAL_CHR(38) || 'x';
    v_ExprParamIndex(v_index)   := NULL;

    nLocalExprId := nLocalExprId + 1;
    v_ExprId(v_index)           := nLocalExprId;
    v_argument_index            := v_index;

    --Now the new expression tree is build but we added three nodes at the end of the tree. However,
    --we need to emulate the ordering by expr_parent_id, seq_nbr which is significantly used in the
    --code.

    --The newly added iterator node should be exactly before the rule operator node.

    store_expr_node(v_iterator_index);
    shift_nodes_right(v_operator_index, v_iterator_index - 1);
    restore_expr_node(v_operator_index);

    --We may need to adjust the stored index for the literal operand.

    IF(v_literal_index > v_operator_index)THEN v_literal_index := v_literal_index + 1; END IF;

    --The newly added argument node should be exactly before the literal operand.

    store_expr_node(v_argument_index);
    shift_nodes_right(v_literal_index, v_argument_index - 1);
    restore_expr_node(v_literal_index);
  END IF;

  --We need to populate all the auxiliary arrays because now this is the expression we will be
  --processing. We don't really have to empty these arrays.

nDebug := 32;

  templateEnd := v_ExprId.COUNT;
  v_NumberOfChildren.DELETE;
  v_ChildrenIndex.DELETE;

  FOR i IN templateStart..templateEnd LOOP
    IF(v_ExprParentId(i) IS NOT NULL)THEN

      IF(v_NumberOfChildren.EXISTS(v_ExprParentId(i)))THEN
        v_NumberOfChildren(v_ExprParentId(i)) := v_NumberOfChildren(v_ExprParentId(i)) + 1;
      ELSE
        v_NumberOfChildren(v_ExprParentId(i)) := 1;
      END IF;

      IF(NOT v_ChildrenIndex.EXISTS(v_ExprParentId(i)))THEN
        v_ChildrenIndex(v_ExprParentId(i)) := i;
      END IF;

    ELSE

      --This is the root of the exploded template application expression tree.

      jdef := i;
    END IF;
  END LOOP;

nDebug := 39;

  RETURN parse_expr_node(jdef);
END parse_template_application;
---------------------------------------------------------------------------------------
PROCEDURE prep_rule_seed_templ_arr IS
      v_RuleName              tRuleName;
      v_TemplateToken         tTemplateToken;
  BEGIN
   --Initialize the rule data for resolving token names.
   SELECT rule_id, name, template_token BULK COLLECT INTO h_RuleId, v_RuleName, v_TemplateToken
     FROM cz_rules
    WHERE devl_project_id = 0
      AND deleted_flag = '0'
      AND disabled_flag = '0'
      AND seeded_flag = '1';

   FOR i IN 1..h_RuleId.COUNT LOOP

     h_RuleName(h_RuleId(i)) := v_RuleName(i);
     h_TemplateToken(h_RuleId(i)) := v_TemplateToken(i);
   END LOOP;
  END prep_rule_seed_templ_arr;
---------------------------------------------------------------------------------------
BEGIN

 SELECT value INTO StoreNlsCharacters FROM NLS_SESSION_PARAMETERS
        WHERE UPPER(parameter) = 'NLS_NUMERIC_CHARACTERS';

        SET_NLS_CHARACTERS(NlsNumericCharacters);

 BEGIN

nDebug := 1;

   BEGIN
     SELECT devl_project_id, presentation_flag INTO v_devl_project_id, v_template_flag FROM cz_rules
      WHERE deleted_flag = '0'
        AND rule_id = p_rule_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE CZ_RT_NO_SUCH_RULE;
   END;

nDebug := 2;

    -- Prepare static seeded rule data template
    IF (h_RuleName.COUNT = 0) THEN
	prep_rule_seed_templ_arr();
    END IF;

   --Performance fix for model report ( bug6638552 )
   --Intitialize the explosion data.
   -- vsingava: 24-Nov-2008; Bug 7297669; Populate the data for all non-ModelReport runs
   IF NOT modelReportRun THEN
     SELECT model_ref_expl_id, parent_expl_node_id, component_id, referring_node_id, ps_node_type
     BULK COLLECT INTO v_NodeId, v_ParentId, v_ComponentId, v_ReferringId, v_NodeType
     FROM cz_model_ref_expls
     WHERE model_id = v_devl_project_id
      AND deleted_flag = '0';

     FOR i IN 1..v_NodeId.COUNT LOOP

       h_ParentId(v_NodeId(i)) := v_ParentId(i);
       h_NodeType(v_NodeId(i)) := v_NodeType(i);
       h_ReferringId(v_NodeId(i)) := v_ReferringId(i);
       h_ComponentId(v_NodeId(i)) := v_ComponentId(i);
     END LOOP;
   END IF;

   --Read the expression into memory.

   SELECT expr_node_id, expr_parent_id, expr_type, template_id,
          ps_node_id, model_ref_expl_id, property_id, data_type, data_value, data_num_value,
          param_index, argument_name
     BULK COLLECT INTO v_ExprId, v_ExprParentId, v_ExprType, v_ExprTemplateId,
                       v_ExprPsNodeId, v_ExplNodeId, v_ExprPropertyId, v_ExprDataType, v_ExprDataValue, v_ExprDataNumValue,
                       v_ExprParamIndex, v_ExprArgumentName
     FROM cz_expression_nodes
    WHERE rule_id = p_rule_id
      AND expr_type <> EXPR_PUNCT
      AND deleted_flag = '0'
    ORDER BY expr_parent_id, seq_nbr;

   rootIndex := 0;

   FOR i IN 1..v_ExprId.COUNT LOOP

     IF(NOT v_NumberOfChildren.EXISTS(v_ExprId(i)))THEN v_NumberOfChildren(v_ExprId(i)) := 0; END IF;

     IF(v_ExprParentId(i) IS NOT NULL)THEN

       IF(v_NumberOfChildren.EXISTS(v_ExprParentId(i)))THEN
         v_NumberOfChildren(v_ExprParentId(i)) := v_NumberOfChildren(v_ExprParentId(i)) + 1;
       ELSE
         v_NumberOfChildren(v_ExprParentId(i)) := 1;
       END IF;

       IF(NOT v_ChildrenIndex.EXISTS(v_ExprParentId(i)))THEN
         v_ChildrenIndex(v_ExprParentId(i)) := i;
       END IF;
     ELSE

       IF(rootIndex = 0)THEN rootIndex := i; ELSE RAISE CZ_RT_MULTIPLE_ROOTS; END IF;
     END IF;
   END LOOP;

nDebug := 3;

   IF(rootIndex  = 0)THEN
     RAISE CZ_RT_INCORRECT_DATA;
   END IF;

   IF(v_template_flag IS NULL OR v_template_flag = '1')THEN v_RuleText := parse_template_application(rootIndex);
   ELSE v_RuleText := parse_expr_node(rootIndex); END IF;

   RETURN v_RuleText;

 END;

 SET_NLS_CHARACTERS(StoreNlsCharacters);

EXCEPTION
  WHEN CZ_RT_NO_SUCH_RULE THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': cannot find the rule.');
  WHEN CZ_RT_MULTIPLE_ROOTS THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': more than one record with null expr_parent_id.');
  WHEN CZ_RT_INCORRECT_DATA THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': no rule data found.');
  WHEN CZ_RT_UNKNOWN_TYPE THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': unknown expression type, expr_type = ' || errmsg2 || '.');
  WHEN CZ_RT_INCORRECT_PROP THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': no such property, property_id = ' || errmsg2 || '.');
  WHEN CZ_RT_INCORRECT_NODE THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': no such node, ps_node_id = ' || errmsg2 || '.');
  WHEN CZ_RT_TEMPLATE_UNKNOWN THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': template definition not available.');
  WHEN CZ_R_INCORRECT_DATA THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': incorrect data in template application.');
  WHEN CZ_RT_INCORRECT_TOKEN THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': unable to resolve template token for ' || errmsg1 || '.');
  WHEN CZ_RT_NO_SYSTEM_PROP THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ': no system property specified for a system property node.');
  WHEN OTHERS THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    errmsg1 := SQLERRM;
    RETURN NULL; --DBMS_OUTPUT.PUT_LINE('rule_id = ' || p_rule_id || ' at ' || nDebug || ': ' || errmsg1);
END parse_to_statement;
---------------------------------------------------------------------------------------
FUNCTION cut_dot(p_string IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  IF(SUBSTR(p_string, LENGTH(p_string), 1) = '.')THEN RETURN SUBSTR(p_string, 1, LENGTH(p_string) - 1);
  ELSE RETURN p_string; END IF;
END;
---------------------------------------------------------------------------------------
--This function generates a path of persistent_node_ids within a model.

--p_start_node_id - start node ps_node_id;
--p_end_node_id - end node ps_node_id.

FUNCTION generate_model_path(p_start_node_id      IN NUMBER,
                             p_end_node_id        IN NUMBER,
                             p_annotate           IN PLS_INTEGER)
  RETURN VARCHAR2 IS

  v_path                 VARCHAR2(32000);
  v_local_path           VARCHAR2(32000);

  v_ps_node_id_hash      t_varchar_array_tbl_type_vc2;-- kdande; Bug 6880555; 12-Mar-2008
  v_start_node_id_tab    t_num_array_tbl_type;
  v_start_parent_id_tab  t_num_array_tbl_type;
  v_start_persist_id_tab t_num_array_tbl_type;
  v_end_node_id_tab      t_num_array_tbl_type;
  v_end_parent_id_tab    t_num_array_tbl_type;
  v_end_persist_id_tab   t_num_array_tbl_type;
  v_start_virtual_tab    t_char_array_tbl_type;
  v_end_virtual_tab      t_char_array_tbl_type;

  v_separator            VARCHAR2(1) := '/';
  v_annotation           VARCHAR2(8) := '';

  FUNCTION annotate(p_virtual_flag IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF(p_virtual_flag = '0')THEN RETURN v_annotation; END IF;
    RETURN '';
  END;
BEGIN

  IF(p_annotate = 1)THEN v_separator := '.'; v_annotation := '[#ANY]'; END IF;
  IF((p_start_node_id IS NULL AND p_end_node_id IS NULL) OR (p_start_node_id = p_end_node_id))THEN RETURN NULL; END IF;

  SELECT ps_node_id, parent_id, persistent_node_id, virtual_flag
    BULK COLLECT INTO v_start_node_id_tab, v_start_parent_id_tab, v_start_persist_id_tab, v_start_virtual_tab
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
   START WITH ps_node_id = p_start_node_id
 CONNECT BY PRIOR parent_id = ps_node_id;

  SELECT ps_node_id, parent_id, persistent_node_id, virtual_flag
    BULK COLLECT INTO v_end_node_id_tab, v_end_parent_id_tab, v_end_persist_id_tab, v_end_virtual_tab
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
   START WITH ps_node_id = p_end_node_id
 CONNECT BY PRIOR parent_id = ps_node_id;

  IF(p_start_node_id IS NULL OR v_start_node_id_tab.COUNT = 1)THEN

    --We need to construct the path down from the root to the end node.

    FOR i IN 1..v_end_node_id_tab.COUNT - 1 LOOP

      v_path := TO_CHAR(v_end_persist_id_tab(i)) || annotate(v_end_virtual_tab(i)) || v_separator || v_path;
    END LOOP;
    RETURN v_path;
  END IF;

  IF(p_end_node_id IS NULL OR v_end_parent_id_tab.COUNT = 1)THEN

    --We need to construct the '..' path up to the root from the start node.

    FOR i IN 1..v_start_node_id_tab.COUNT - 1 LOOP

      v_path := '..' || v_separator || v_path;
    END LOOP;
    RETURN v_path;
  END IF;

  --We need to construct a mixed path from the start node to the end node.
  --In order to find the LCA of the two nodes, first build a hash map from the end node to the root.

  FOR i IN 1..v_end_node_id_tab.COUNT LOOP

    v_ps_node_id_hash(v_end_node_id_tab(i)) := v_local_path;
    v_local_path := TO_CHAR(v_end_persist_id_tab(i)) || annotate(v_end_virtual_tab(i)) || v_separator || v_local_path;

    --In case the start node is a direct ancestor of the end node.

    IF(v_end_parent_id_tab(i) = p_start_node_id)THEN RETURN v_local_path; END IF;
  END LOOP;

  --We know that the start node is not a direct ancestor of the end node. Go up from the start node
  --until one of the following occurs: we hit the end node which is a direct ancestor of the start
  --node, or we hit entry in the hash table meaning the LCA.

  FOR i IN 1..v_start_node_id_tab.COUNT LOOP

    v_path := '..' || v_separator || v_path;

    IF(v_start_parent_id_tab(i) = p_end_node_id)THEN RETURN v_path; END IF;
    IF(v_ps_node_id_hash.EXISTS(v_start_parent_id_tab(i)))THEN

      RETURN v_path || v_ps_node_id_hash(v_start_parent_id_tab(i));
    END IF;
  END LOOP;

 RETURN v_path || v_local_path;
END generate_model_path;
---------------------------------------------------------------------------------------
FUNCTION in_boundary (p_base_expl_id            IN NUMBER,
                      p_node_expl_id            IN NUMBER,
                      p_node_persistent_node_id IN NUMBER)
  RETURN PLS_INTEGER IS

  v_base_expl_id_tab    t_num_array_tbl_type;
  v_base_expl_type_tab  t_num_array_tbl_type;
  v_node_expl_id_tab    t_num_array_tbl_type;
  v_node_expl_type_tab  t_num_array_tbl_type;
  v_base_path_expl_id   t_num_array_tbl_type;

  YES                   CONSTANT PLS_INTEGER := 1;
  NO                    CONSTANT PLS_INTEGER := 0;
  MANDATORY             CONSTANT PLS_INTEGER := 2;
  CONNECTOR             CONSTANT PLS_INTEGER := 3;

  l_model_id            NUMBER;
  l_component_id        NUMBER;
  l_referring_node_id   NUMBER;
  l_ps_node_id          NUMBER;
  l_root_model_id       NUMBER;
  l_persistent_node_id  NUMBER;
  l_it_is_in_subtree    BOOLEAN := FALSE;

BEGIN

  IF(p_base_expl_id = p_node_expl_id)THEN RETURN YES; END IF;

  SELECT model_id,component_id,referring_node_id
    INTO l_root_model_id, l_component_id, l_referring_node_id
    FROM CZ_MODEL_REF_EXPLS WHERE model_ref_expl_id=p_node_expl_id;

  IF l_referring_node_id IS NULL THEN
    SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
    WHERE ps_node_id=l_component_id;

    SELECT ps_node_id INTO l_ps_node_id FROM CZ_PS_NODES
   WHERE devl_project_id=l_model_id AND
         persistent_node_id=p_node_persistent_node_id AND
         deleted_flag='0';

    IF l_ps_node_id<>l_component_id THEN
      l_it_is_in_subtree := TRUE;
    END IF;

  ELSE

    SELECT persistent_node_id INTO l_persistent_node_id FROM CZ_PS_NODES
    WHERE ps_node_id=l_referring_node_id;

    IF p_node_persistent_node_id=l_persistent_node_id THEN
      SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
      WHERE ps_node_id=l_referring_node_id;
    ELSE
      SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
      WHERE ps_node_id=l_component_id;
    END IF;

    SELECT ps_node_id INTO l_ps_node_id FROM CZ_PS_NODES
    WHERE devl_project_id=l_model_id AND
          persistent_node_id=p_node_persistent_node_id AND
          deleted_flag='0';

    IF l_ps_node_id<>l_referring_node_id THEN
      l_it_is_in_subtree := TRUE;
    END IF;

  END IF;

  SELECT model_ref_expl_id, expl_node_type
    BULK COLLECT INTO v_base_expl_id_tab, v_base_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_base_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  SELECT model_ref_expl_id, expl_node_type
    BULK COLLECT INTO v_node_expl_id_tab, v_node_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_node_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  FOR i IN 1..v_base_expl_id_tab.COUNT LOOP

    --Go up the tree from the base node.

    IF(v_base_expl_id_tab(i) = v_node_expl_id_tab(1))THEN

      --We hit the argument node on the way up.

      RETURN YES;
    END IF;

    IF(v_base_expl_type_tab(i) = CONNECTOR AND i > 1)THEN

      --We hit a connector on the way up before the argument node. However, the base node itself can
      --be a connector.

      RETURN NO;
    END IF;

    --Hash the explosion_id in order to detect a fork when going up from the argument.

    v_base_path_expl_id(v_base_expl_id_tab(i)) := 1;
  END LOOP;

  --We went all the way up from the base node but we haven't hit the argument node. So the
  --argument node is either down the tree or in a different branch.

  FOR i IN 1..v_node_expl_id_tab.COUNT LOOP

    --Go up the tree from the argument node. The rules for this walk are slightly different.

    IF(v_node_expl_id_tab(i) = v_base_expl_id_tab(1))THEN

      --We hit the base node on the way up without hitting non-virtual nodes or connectors.

      RETURN YES;
    END IF;

    IF(v_base_path_expl_id.EXISTS(v_node_expl_id_tab(i)))THEN

      --We hit a node on the path up from the base - there is a fork in the boundary.

      RETURN YES;
    END IF;

    IF(v_node_expl_type_tab(i) = CONNECTOR AND i>1)THEN

      --We hit a connector on the way up before the base node.

      RETURN NO;
    END IF;

    IF(v_node_expl_type_tab(i) <> MANDATORY) THEN

      IF i>1 OR l_it_is_in_subtree THEN
        --We hit a non-virtual node on the way up before the base node - this is not allowed
        --for argument nodes because the base node should be in the deepest non-virtual net.
        RETURN NO;
      END IF;

    END IF;

  END LOOP;

  --If we are here, the base and argument nodes are in different branches but still in
  --the allowable context.

  RETURN YES;
END in_boundary;
---------------------------------------------------------------------------------------
FUNCTION in_cx_boundary (p_base_expl_id  IN NUMBER,
                         p_base_node_id  IN NUMBER,
                         p_node_expl_id  IN NUMBER,
                         p_node_node_id  IN NUMBER)
  RETURN PLS_INTEGER IS

  v_base_expl_id_tab    t_num_array_tbl_type;
  v_base_expl_type_tab  t_num_array_tbl_type;
  v_node_expl_id_tab    t_num_array_tbl_type;
  v_node_expl_type_tab  t_num_array_tbl_type;
  v_base_path_expl_id   t_num_array_tbl_type;

  YES                   CONSTANT PLS_INTEGER := 0;
  BASE_UNDER_CONNECTOR  CONSTANT PLS_INTEGER := 1;
  ARG_UNDER_CONNECTOR   CONSTANT PLS_INTEGER := 2;
  CROSS_BOUNDARY        CONSTANT PLS_INTEGER := 3;

  MANDATORY             CONSTANT PLS_INTEGER := 2;
  CONNECTOR             CONSTANT PLS_INTEGER := 3;

  l_component_id        NUMBER;
  l_referring_node_id   NUMBER;
  base_is_in_subtree    BOOLEAN := FALSE;
  node_is_in_subtree    BOOLEAN := FALSE;
BEGIN

  SELECT component_id, referring_node_id
    INTO l_component_id, l_referring_node_id
    FROM cz_model_ref_expls WHERE model_ref_expl_id = p_base_expl_id;

  IF(p_base_node_id <> NVL(l_referring_node_id, l_component_id))THEN base_is_in_subtree := TRUE; END IF;

  SELECT component_id, referring_node_id
    INTO l_component_id, l_referring_node_id
    FROM cz_model_ref_expls WHERE model_ref_expl_id = p_node_expl_id;

  IF(p_node_node_id <> NVL(l_referring_node_id, l_component_id))THEN node_is_in_subtree := TRUE; END IF;

  SELECT model_ref_expl_id, expl_node_type
    BULK COLLECT INTO v_base_expl_id_tab, v_base_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_base_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  SELECT model_ref_expl_id, expl_node_type
    BULK COLLECT INTO v_node_expl_id_tab, v_node_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_node_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  --First check if base or argument nodes are in a connected structure - this is prohibited.

  FOR i IN 1..v_base_expl_id_tab.COUNT LOOP
    IF(v_base_expl_type_tab(i) = CONNECTOR AND (i > 1 OR base_is_in_subtree))THEN

      --We hit a connector on the way up (the base node itself can be a connector).

      RETURN BASE_UNDER_CONNECTOR;
    END IF;
  END LOOP;

  FOR i IN 1..v_node_expl_id_tab.COUNT LOOP
    IF(v_node_expl_type_tab(i) = CONNECTOR AND (i > 1 OR node_is_in_subtree))THEN

      --We hit a connector on the way up (the argument itself can be a connector).

      RETURN ARG_UNDER_CONNECTOR;
    END IF;
  END LOOP;

  IF(p_base_expl_id = p_node_expl_id)THEN RETURN YES; END IF;

  FOR i IN 1..v_base_expl_id_tab.COUNT LOOP

    --Go up the tree from the base node.

    IF(v_base_expl_id_tab(i) = v_node_expl_id_tab(1))THEN

      --We hit the argument node on the way up.

      RETURN YES;
    END IF;

    --Hash the explosion_id in order to detect a fork when going up from the argument.

    v_base_path_expl_id(v_base_expl_id_tab(i)) := 1;
  END LOOP;

  --We went all the way up from the base node but we haven't hit the argument node. So the
  --argument node is either down the tree or in a different branch.

  FOR i IN 1..v_node_expl_id_tab.COUNT LOOP

    --Go up the tree from the argument node. The rules for this walk are slightly different.

    IF(v_node_expl_id_tab(i) = v_base_expl_id_tab(1))THEN

      --We hit the base node on the way up without hitting non-virtual nodes or connectors.

      RETURN YES;
    END IF;

    IF(v_base_path_expl_id.EXISTS(v_node_expl_id_tab(i)))THEN

      --We hit a node on the path up from the base - there is a fork in the boundary.

      RETURN YES;
    END IF;

    IF(v_node_expl_type_tab(i) <> MANDATORY AND (i > 1 OR node_is_in_subtree)) THEN

      --We hit a non-virtual node on the way up before the base node - this is not allowed
      --for argument nodes because the base node should be in the deepest non-virtual net.

      RETURN CROSS_BOUNDARY;
    END IF;
  END LOOP;

  --If we are here, the base and argument nodes are in different branches but still in
  --the allowable context.

  RETURN YES;
END in_cx_boundary;
---------------------------------------------------------------------------------------
FUNCTION generate_relative_path_(p_base_expl_id IN NUMBER,
                                 p_base_node_id IN NUMBER,
                                 p_node_expl_id IN NUMBER,
                                 p_node_node_id IN NUMBER,
                                 p_annotate     IN PLS_INTEGER)
  RETURN VARCHAR2 IS

  v_base_expl_id_tab    t_num_array_tbl_type;
  v_base_expl_type_tab  t_num_array_tbl_type;
  v_base_ref_id_tab     t_num_array_tbl_type;
  v_node_expl_id_tab    t_num_array_tbl_type;
  v_node_expl_type_tab  t_num_array_tbl_type;
  v_node_ref_id_tab     t_num_array_tbl_type;

  v_path                VARCHAR2(32000);
  v_expl_path_hash      t_varchar_array_tbl_type;

  v_base_ref_expl_index PLS_INTEGER;
  v_node_ref_expl_index PLS_INTEGER;
  v_base_ref_expl_id    NUMBER;
  v_node_ref_expl_id    NUMBER;
  v_prev_referring_id   NUMBER;
  v_base_project_id     NUMBER;
  v_node_project_id     NUMBER;

  REFERENCE             CONSTANT PLS_INTEGER := 263;
  CONNECTOR             CONSTANT PLS_INTEGER := 264;

BEGIN

  IF(p_base_node_id = p_node_node_id)THEN RETURN NULL; END IF;

  SELECT devl_project_id INTO v_base_project_id FROM cz_ps_nodes
   WHERE ps_node_id = p_base_node_id;

  SELECT devl_project_id INTO v_node_project_id FROM cz_ps_nodes
   WHERE ps_node_id = p_node_node_id;

  IF(v_base_project_id = v_node_project_id)THEN

    --The nodes are in the same model regardless of their types.

    RETURN cut_dot(generate_model_path(p_base_node_id, p_node_node_id, p_annotate));
  END IF;

  SELECT model_ref_expl_id, referring_node_id, ps_node_type
    BULK COLLECT INTO v_base_expl_id_tab, v_base_ref_id_tab, v_base_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_base_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  SELECT model_ref_expl_id, referring_node_id, ps_node_type
    BULK COLLECT INTO v_node_expl_id_tab, v_node_ref_id_tab, v_node_expl_type_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_node_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  --Here we need to work only with references, because whatever explosions are within a model, they
  --will be processed in one call to generate_model_path. So, find the deepest references above the
  --base and argument nodes to start. Can as well be the root model or the nodes themselves.

  FOR i IN 1..v_base_expl_id_tab.COUNT LOOP

    v_base_ref_expl_index := i;
    IF(v_base_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN EXIT; END IF;
  END LOOP;

  FOR i IN 1..v_node_expl_id_tab.COUNT LOOP

    v_node_ref_expl_index := i;
    IF(v_node_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN EXIT; END IF;
  END LOOP;

  --Explosion ids of the deepest references above the base and argument.

  v_base_ref_expl_id := v_base_expl_id_tab(v_base_ref_expl_index);
  v_node_ref_expl_id := v_node_expl_id_tab(v_node_ref_expl_index);

  IF(v_base_ref_expl_id = v_node_ref_expl_id)THEN
    IF(p_base_node_id = v_base_ref_id_tab(v_base_ref_expl_index))THEN

      --The base node is the reference itself, so the argument is a node in the referenced model.

      RETURN cut_dot(generate_model_path(NULL, p_node_node_id, p_annotate));
    ELSIF(p_node_node_id = v_node_ref_id_tab(v_node_ref_expl_index))THEN

      --The argument node is the reference itself, so the base is a node in the referenced model.

      RETURN cut_dot(generate_model_path(p_base_node_id, NULL, p_annotate));
    ELSE

      --Both base and argument are in the same model.

      RETURN cut_dot(generate_model_path(p_base_node_id, p_node_node_id, p_annotate));
    END IF;
  END IF;

  --Now we know that base and argument are in different models. Check if the base node is in the
  --root model. If it is, we skip going up from it.

  IF(v_base_ref_id_tab(v_base_ref_expl_index) IS NOT NULL)THEN

    --We will go up from the base node because it is not in the root model.
    --If the base node is not the reference itself, we start the path with the model path from
    --the base node up.

    IF(p_base_node_id <> v_base_ref_id_tab(v_base_ref_expl_index))THEN

      v_path := generate_model_path(p_base_node_id, NULL, p_annotate);
    END IF;

    v_prev_referring_id := v_base_ref_id_tab(v_base_ref_expl_index);

    FOR i IN v_base_ref_expl_index + 1..v_base_expl_id_tab.COUNT LOOP

      IF(v_base_expl_id_tab(i) = v_node_ref_expl_id)THEN

        --We hit the argument node's explosion on the way up. If the argument node is the reference
        --itself, we build the path through the whole model, otherwise the argument is an internal
        --node, so we use a partial model path from the reference.

        IF(p_node_node_id = v_node_ref_id_tab(v_node_ref_expl_index))THEN

          v_path := v_path || generate_model_path(v_prev_referring_id, NULL, p_annotate);
        ELSE

          v_path := v_path || generate_model_path(v_prev_referring_id, p_node_node_id, p_annotate);
        END IF;
        RETURN cut_dot(v_path);
      ELSIF(v_base_expl_type_tab(i) IN (REFERENCE, CONNECTOR) OR i = v_base_expl_id_tab.COUNT)THEN

        v_path := v_path || generate_model_path(v_prev_referring_id, NULL, p_annotate);
        v_prev_referring_id := v_base_ref_id_tab(i);

        --Create an entry in the hash table which may be used to find the LCA of the base and
        --argument nodes.

        v_expl_path_hash(v_base_expl_id_tab(i)) := v_path;
      END IF;
    END LOOP;
  END IF; --the base node is not in the root model.

  --We went all the way up from the base node but we haven't hit the argument node. So the
  --argument node is either down the tree or in a different branch. We are going to go up
  --from the argument node. If the argument node is not the reference itself, we start
  --the path with the model path from the argument node up.

  --v_node_ref_id_tab(v_node_ref_expl_index) is not null: argument is not in the root model
  --otherwise we would have hit it before.

  v_path := NULL;
  v_prev_referring_id := v_node_ref_id_tab(v_node_ref_expl_index);

  IF(p_node_node_id <> v_node_ref_id_tab(v_node_ref_expl_index))THEN

    v_path := generate_model_path(NULL, p_node_node_id, p_annotate);
  END IF;

  FOR i IN v_node_ref_expl_index + 1..v_node_expl_id_tab.COUNT LOOP

    --Go up the tree from the argument node's explosion.

    IF(v_node_expl_id_tab(i) = v_base_ref_expl_id)THEN

      --We hit the base node's explosion on the way up. If the base node is the reference itself
      --(or the root model) we build the path through the whole model, otherwise the base is an
      --internal node, so we use a partial model path from the reference.

      IF(p_base_node_id = v_base_ref_id_tab(v_base_ref_expl_index))THEN

        v_path := generate_model_path(NULL, v_prev_referring_id, p_annotate) || v_path;
      ELSE

        v_path := generate_model_path(p_base_node_id, v_prev_referring_id, p_annotate) || v_path;
      END IF;
     RETURN cut_dot(v_path);
    ELSIF(v_node_expl_type_tab(i) IN (REFERENCE, CONNECTOR) OR i = v_node_expl_id_tab.COUNT)THEN

      v_path := generate_model_path(NULL, v_prev_referring_id, p_annotate) || v_path;
      v_prev_referring_id := v_node_ref_id_tab(i);
    END IF;

    IF(v_expl_path_hash.EXISTS(v_node_expl_id_tab(i)))THEN

      --We hit the LCA. The base node is in the different branch, otherwise the hash entry would not
      --exist. This can be the very root model, so this is the ultimate return point.

      RETURN cut_dot(v_expl_path_hash(v_node_expl_id_tab(i)) || v_path);
    END IF;
  END LOOP;

 --Algorithmically we can never be here.

 RAISE CZ_G_INVALID_RULE_EXPLOSION;
END generate_relative_path_;
---------------------------------------------------------------------------------------
FUNCTION generate_relative_path(p_base_expl_id IN NUMBER,
                                p_base_node_id IN NUMBER,
                                p_node_expl_id IN NUMBER,
                                p_node_node_id IN NUMBER)
  RETURN VARCHAR2 IS
BEGIN
  RETURN generate_relative_path_(p_base_expl_id, p_base_node_id, p_node_expl_id, p_node_node_id, 0);
END;
---------------------------------------------------------------------------------------
PROCEDURE verify_special_rule(p_rule_id IN NUMBER,
                              p_name    IN VARCHAR,
                              x_run_id  IN OUT NOCOPY NUMBER) IS

  TYPE t_path_array_tbl_type IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

  EXPR_NODE_TYPE_LITERAL      CONSTANT PLS_INTEGER    := 201;
  EXPR_NODE_TYPE_NODE         CONSTANT PLS_INTEGER    := 205;
  EXPR_NODE_TYPE_PUNCT        CONSTANT PLS_INTEGER    := 208;
  EXPR_JAVA_METHOD            CONSTANT PLS_INTEGER    := 216;
  EXPR_EVENT_PARAMETER        CONSTANT PLS_INTEGER    := 217;
  EXPR_SYSTEM_PARAMETER       CONSTANT PLS_INTEGER    := 218;

  YES                         CONSTANT PLS_INTEGER    := 0;
  BASE_UNDER_CONNECTOR        CONSTANT PLS_INTEGER    := 1;
  ARG_UNDER_CONNECTOR         CONSTANT PLS_INTEGER    := 2;
  CROSS_BOUNDARY              CONSTANT PLS_INTEGER    := 3;

  DATA_TYPE_INTEGER           CONSTANT PLS_INTEGER    := 1;
  DATA_TYPE_DECIMAL           CONSTANT PLS_INTEGER    := 2;

  INSTANTIATION_SCOPE_INST    CONSTANT PLS_INTEGER    := 1;

  EVT_ON_COMMAND_NAME         CONSTANT VARCHAR2(30)   := 'ONCOMMAND';
  EVT_POSTADD_NAME            CONSTANT VARCHAR2(30)   := 'POSTINSTANCEADD';
  EVT_POSTDELETE_NAME         CONSTANT VARCHAR2(30)   := 'POSTINSTANCEDELETE';
  COMPONENT_JAVA_TYPE         CONSTANT VARCHAR2(2000) := 'oracle.apps.cz.cio.Component';
  COMPONENTSET_JAVA_TYPE      CONSTANT VARCHAR2(2000) := 'oracle.apps.cz.cio.ComponentSet';
  COMPONENTINST_JAVA_TYPE     CONSTANT VARCHAR2(2000) := 'oracle.apps.cz.cio.ComponentInstance';
  STRING_JAVA_TYPE            CONSTANT VARCHAR2(2000) := 'java.lang.String';

  CZ_R_NO_PARTICIPANTS        EXCEPTION;
  CZ_R_WRONG_EXPRESSION_NODE  EXCEPTION;
  CZ_G_INVALID_RULE_EXPLOSION EXCEPTION;
  CZ_R_INCORRECT_NODE_ID      EXCEPTION;
  CZ_R_LITERAL_NO_VALUE       EXCEPTION;

  flagInvalidCX               PLS_INTEGER;
  x_error                     PLS_INTEGER;
  v_number                    NUMBER;

  v_rule_type                 NUMBER;
  v_component_id              NUMBER;
  v_virtual_flag              VARCHAR2(1);
  v_persistent_id             NUMBER;
  v_base_name                 cz_ps_nodes.name%TYPE;
  v_node_name                 cz_ps_nodes.name%TYPE;
  v_expl_id                   NUMBER;
  v_class_name                VARCHAR2(2000);
  v_model_id                  NUMBER;
  v_rule_folder_id            NUMBER;
  v_signature_name            VARCHAR2(2000);
  v_rule_name                 VARCHAR2(2000);
  v_model_name                VARCHAR2(2000);
  v_seeded_flag               VARCHAR2(1);
  v_arg_count                 NUMBER;
  v_property_value            VARCHAR2(4000);
  v_property_name             cz_properties.name%TYPE;
  v_item_name                 cz_ps_nodes.name%TYPE;
  v_parent_name               cz_ps_nodes.name%TYPE;
  v_parent_id                 cz_ps_nodes.parent_id%TYPE;
  v_inst_scope                cz_rules.instantiation_scope%TYPE;

  v_tExprId                   t_num_array_tbl_type;
  v_tExprParentId             t_num_array_tbl_type;
  v_tExplNodeId               t_num_array_tbl_type;
  v_tExprType                 t_num_array_tbl_type;
  v_tExprSubtype              t_num_array_tbl_type;
  v_tExprPsNodeId             t_num_array_tbl_type;
  v_tExprArgSignature         t_num_array_tbl_type;
  v_tExprParSignature         t_num_array_tbl_type;
  v_tExprParamIndex           t_num_array_tbl_type;
  v_tExprDataValue            t_varchar_array_tbl_type;
  v_tExprDataNumValue         t_num_array_tbl_type;
  v_tArgumentIndex            t_num_array_tbl_type;
  v_tExprArgumentName         t_varchar_array_tbl_type;
  v_tExprDataType             t_num_array_tbl_type;
  v_tDataType                 t_num_array_tbl_type;
  v_tArgumentName             t_varchar_array_tbl_type;
  v_tPropertyId               t_num_array_tbl_type;
  v_tExprArgumentIndex        t_num_array_tbl_type;
  v_RelativeNodePath          t_path_array_tbl_type;
  v_tJavaDataType             t_varchar_array_tbl_type;
  h_tJavaDataType             t_varchar_array_tbl_type;
  h_tArgumentName             t_varchar_array_tbl_type;

  nDebug                      PLS_INTEGER := 20;
  aux_flag                    PLS_INTEGER;
  expressionSize              PLS_INTEGER;
  expressionStart             PLS_INTEGER;
  expressionEnd               PLS_INTEGER;
  initRuleStatus              PLS_INTEGER :=1;
---------------------------------------------------------------------------------------
  PROCEDURE report(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER) IS
  BEGIN
    INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
    VALUES (inMessage, nDebug, 'verify_special_rule', inUrgency, x_run_id, SYSDATE);
  END;
---------------------------------------------------------------------------------------
  PROCEDURE mark_rule_invalid IS
  BEGIN
    UPDATE cz_rules SET invalid_flag = '1' WHERE rule_id = p_rule_id;
  END;
---------------------------------------------------------------------------------------
  PROCEDURE mark_rule_valid IS
  BEGIN
    UPDATE cz_rules SET invalid_flag = '0' WHERE rule_id = p_rule_id;
  END;
---------------------------------------------------------------------------------------
 PROCEDURE set_status(initRuleStatus IN PLS_INTEGER) IS
  BEGIN
     if initRuleStatus='0'
     then
      mark_rule_invalid;
     end if;
  END;
---------------------------------------------------------------------------------------
FUNCTION rule_name RETURN VARCHAR2 IS
  v_qualified   VARCHAR2(4000) := '.';
  n_rule_name   PLS_INTEGER;
BEGIN

  IF(p_name IS NOT NULL)THEN RETURN p_name; END IF;
  IF(v_rule_folder_id IS NULL OR v_rule_folder_id = -1)THEN RETURN v_rule_name; END IF;

  n_rule_name := LENGTHB(v_rule_name);

  FOR folder IN (SELECT name FROM cz_rule_folders
                  WHERE deleted_flag = '0'
                    AND parent_rule_folder_id IS NOT NULL
                  START WITH rule_folder_id = v_rule_folder_id
                    AND object_type = 'RFL'
                CONNECT BY PRIOR parent_rule_folder_id = rule_folder_id
                    AND object_type = 'RFL')LOOP

     IF(LENGTHB(folder.name) + LENGTHB(v_qualified) + 1 < 2000 - n_rule_name)THEN

       v_qualified := '.' || folder.name || v_qualified;
     ELSE

       v_qualified := v_qualified || '...'; EXIT;
     END IF;
  END LOOP;
  RETURN v_qualified || v_rule_name;
END;
---------------------------------------------------------------------------------------
PROCEDURE verify_node(p_node_id IN NUMBER, x_persistent_id OUT NOCOPY NUMBER,
                      x_name OUT NOCOPY VARCHAR2, x_virtual_flag OUT NOCOPY VARCHAR2) IS
BEGIN
  SELECT persistent_node_id, name, virtual_flag
    INTO x_persistent_id, x_name, x_virtual_flag
    FROM cz_ps_nodes
   WHERE deleted_flag = '0' AND ps_node_id = p_node_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE CZ_R_WRONG_EXPRESSION_NODE;
END;
---------------------------------------------------------------------------------------
PROCEDURE verify_explosion(p_expl_id IN NUMBER) IS
BEGIN
  SELECT NULL INTO aux_flag FROM cz_model_ref_expls
   WHERE deleted_flag = '0' AND model_ref_expl_id = p_expl_id
     AND model_id = v_model_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE CZ_G_INVALID_RULE_EXPLOSION;
END;
---------------------------------------------------------------------------------------
FUNCTION is_compatible_event(p_signature_id IN NUMBER, p_data_type IN PLS_INTEGER, p_argument_index IN VARCHAR2)
RETURN BOOLEAN IS
  v_null  PLS_INTEGER;
BEGIN

  SELECT NULL INTO v_null FROM cz_conversion_rels_v rel, cz_cx_event_params_v par
   WHERE par.event_signature_id = p_signature_id
     AND par.argument_index = p_argument_index
     AND rel.subject_type = par.data_type
     AND rel.object_type = p_data_type AND par.p_model_id = v_model_id;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RETURN FALSE;
END;
---------------------------------------------------------------------------------------
FUNCTION is_compatible_system(p_data_type IN PLS_INTEGER, p_argument_name IN VARCHAR2) RETURN BOOLEAN IS
  v_null  PLS_INTEGER;
BEGIN

  SELECT NULL INTO v_null FROM cz_conversion_rels_v rel, cz_cx_system_params_v par
   WHERE par.data_value = p_argument_name
     AND rel.subject_type = par.data_type
     AND rel.object_type = p_data_type;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RETURN FALSE;
END;
---------------------------------------------------------------------------------------
BEGIN

  IF(x_run_id IS NULL OR x_run_id = 0)THEN
    SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  END IF;

  SELECT rule_type, component_id, model_ref_expl_id, devl_project_id, rule_folder_id, name,
         class_name, seeded_flag, invalid_flag, instantiation_scope
    INTO v_rule_type, v_component_id, v_expl_id, v_model_id, v_rule_folder_id, v_rule_name,
         v_class_name, v_seeded_flag, initRuleStatus, v_inst_scope
    FROM cz_rules
   WHERE rule_id = p_rule_id;

  IF(v_seeded_flag = '1')THEN x_run_id := 0; RETURN; END IF;

  IF v_model_id > 0 THEN
    BEGIN
      SELECT name INTO v_model_name
        FROM cz_devl_projects
       WHERE devl_project_id = v_model_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE;
    END;
  END IF;

  --We will mark the rule invalid by default. If the rule will pass all the verifications and the
  --relative node path will be successfully generated, we will mark the rule valid.
  --Bug #3526242.

 -- mark_rule_invalid;
  flagInvalidCX := 0;

  SELECT expr_node_id, expr_parent_id, model_ref_expl_id, expr_type, expr_subtype, ps_node_id,
         argument_signature_id, param_signature_id, param_index, data_value,
         data_num_value, argument_name, data_type, argument_index, property_id
    BULK COLLECT INTO v_tExprId, v_tExprParentId, v_tExplNodeId, v_tExprType, v_tExprSubtype, v_tExprPsNodeId,
                      v_tExprArgSignature, v_tExprParSignature, v_tExprParamIndex, v_tExprDataValue,
                      v_tExprDataNumValue, v_tExprArgumentName, v_tExprDataType, v_tExprArgumentIndex,
                      v_tPropertyId
    FROM cz_expression_nodes
   WHERE rule_id = p_rule_id
     AND expr_type <> EXPR_NODE_TYPE_PUNCT
     AND deleted_flag = '0';

  IF(v_tExprType.COUNT = 0)THEN
    RAISE CZ_R_NO_PARTICIPANTS;
  END IF;

  expressionSize := v_tExprType.COUNT;
  expressionStart := 1;
  expressionEnd := expressionSize;

  IF(v_rule_type = RULE_TYPE_JAVA_METHOD)THEN

    --This is Configurator Extention rule. Here we will validate all argument bindings and
    --data types.

    --If the class name is specified on the rule, verify there are some archives associated
    --with the model. We do not validate that such class does exist in one of the archives.
    --If there is no class name, report as incomplete.

    IF(v_class_name IS NULL)THEN

      --'Incomplete data: No class name specified for the Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

      report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_PROGRAM_STRING', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
      flagInvalidCX := 1;

    ELSIF(v_component_id IS NULL OR v_expl_id IS NULL)THEN

      --'Incomplete data: No base component specified for the Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

      report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_BASE_COMPONENT', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
      flagInvalidCX := 1;
    END IF;

    FOR i IN expressionStart..expressionEnd LOOP

      IF(v_tExprType(i) = EXPR_JAVA_METHOD)THEN

        --This is an event binding. Verify that argument_signature_id and param_signature_id are specified.

        IF(v_tExprArgSignature(i) IS NULL)THEN

          --'Incomplete data: No event binding specified for the Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

          report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_BINDING', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
          flagInvalidCX := 1;
        ELSE

          --Read the signature and verify that if the event is EVT_ON_COMMAND, data_value contains the command.

          BEGIN

            SELECT name INTO v_signature_name FROM cz_signatures
            WHERE deleted_flag = '0' AND signature_id = v_tExprArgSignature(i);

            IF(UPPER(v_signature_name) = EVT_ON_COMMAND_NAME AND v_tExprDataValue(i) IS NULL)THEN

              --'Incomplete data: No command string specified for the ''On Command'' event in the Configurator
              -- Extension ''%RULENAME'' in model ''%MODELNAME''.'

              report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_COMMAND', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
              flagInvalidCX := 1;
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_BINDING', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
              flagInvalidCX := 1;
          END;
        END IF;

        IF(v_tExprParSignature(i) IS NULL)THEN

          --'Incomplete data: No Java method signature specified in the Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

          report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_JAVA_SIGNATURE', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
          flagInvalidCX := 1;
        ELSE

          --Read the signature to verify the number of parameters.

          BEGIN

            SELECT argument_count INTO v_arg_count FROM cz_signatures
            WHERE deleted_flag = '0' AND signature_id = v_tExprParSignature(i);

            --Read the java signature arguments and verify the parameters and their types.

            v_tArgumentIndex.DELETE;
            v_tDataType.DELETE;
            v_tArgumentName.DELETE;
            v_tJavaDataType.DELETE;

            SELECT argument_index, data_type, argument_name, java_data_type
              BULK COLLECT INTO v_tArgumentIndex, v_tDataType, v_tArgumentName, v_tJavaDataType
              FROM cz_signature_arguments
             WHERE deleted_flag = '0'
               AND argument_signature_id = v_tExprParSignature(i);

            --Verify that the count of the arguments equals to the number specified in the signature,
            --then verify the binding and the type for every argument.

            IF(v_tArgumentIndex.COUNT <> v_arg_count)THEN

              --'Incorrect signature arguments data for Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

              report(CZ_UTILS.GET_TEXT('CZ_LCE_WRONG_ARGUMENTS', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
              flagInvalidCX := 1;
            END IF;

            FOR ii IN 1..v_tArgumentIndex.COUNT LOOP

              aux_flag := 0;

              FOR iii IN expressionStart..expressionEnd LOOP

                IF(v_tExprParSignature(iii) = v_tExprParSignature(i) AND
                   v_tExprParentId(iii) = v_tExprId(i) AND
                   v_tExprParamIndex(iii) = v_tArgumentIndex(ii))THEN

                  IF((v_tExprType(iii) = EXPR_EVENT_PARAMETER AND v_tExprArgSignature(iii) IS NOT NULL AND
                      v_tExprArgumentIndex(iii) IS NOT NULL AND is_compatible_event(v_tExprArgSignature(iii), v_tDataType(ii), v_tExprArgumentIndex(iii))) OR
                     (v_tExprType(iii) = EXPR_SYSTEM_PARAMETER AND v_tExprArgumentName(iii) IS NOT NULL AND
                      is_compatible_system(v_tDataType(ii), v_tExprArgumentName(iii))) OR
                     (v_tExprType(iii) = EXPR_NODE_TYPE_NODE AND v_tExprPsNodeId(iii) IS NOT NULL AND v_tExplNodeId(iii) IS NOT NULL) OR
                     (v_tExprType(iii) = EXPR_NODE_TYPE_LITERAL AND (v_tJavaDataType(ii) = STRING_JAVA_TYPE OR
                     (v_tExprDataValue(iii) IS NOT NULL OR v_tExprDataNumValue(iii) IS NOT NULL))) OR
                     v_tExprType(iii) NOT IN (EXPR_EVENT_PARAMETER, EXPR_SYSTEM_PARAMETER, EXPR_NODE_TYPE_NODE, EXPR_NODE_TYPE_LITERAL))THEN

                    aux_flag := iii;
                    h_tJavaDataType(iii) := v_tJavaDataType(ii);
                    h_tArgumentName(iii) := v_tArgumentName(ii);
                    EXIT;
                  END IF;
                END IF;
              END LOOP;

              IF(aux_flag = 0)THEN

                --'No parameter bound to the argument ''%ARGUMENTNAME'' in Configurator Extension ''%RULENAME'' in model ''%MODELNAME''.'

                report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_PARAM_BOUND', 'ARGUMENTNAME', v_tArgumentName(ii), 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
                flagInvalidCX := 1;
              END IF;
            END LOOP;

          EXCEPTION
            WHEN OTHERS THEN
              report(CZ_UTILS.GET_TEXT('CZ_LCE_NO_JAVA_SIGNATURE', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
              flagInvalidCX := 1;
          END;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF(flagInvalidCX = 0)THEN

    IF(v_component_id IS NOT NULL)THEN verify_node(v_component_id, v_persistent_id, v_base_name, v_virtual_flag); END IF;
    IF(v_expl_id IS NOT NULL)THEN verify_explosion(v_expl_id); END IF;

    FOR i IN expressionStart..expressionEnd LOOP

      v_RelativeNodePath(i) := NULL;

      IF(v_tExprPsNodeId(i) IS NOT NULL)THEN

        verify_node(v_tExprPsNodeId(i), v_persistent_id, v_node_name, v_virtual_flag);

        IF(v_rule_type = RULE_TYPE_JAVA_METHOD AND v_virtual_flag = '1' AND
           h_tJavaDataType.EXISTS(i) AND h_tJavaDataType(i) = COMPONENTSET_JAVA_TYPE)THEN

          --This is a mandatory component with java data type of ComponentSet (bug #4178506).

          --'You cannot bind a mandatory component to a component set. The Java parameter ''%ARGUMENTNAME'' is of the
          -- type ComponentSet. ''%NODENAME'' is a mandatory component.'
          report(CZ_UTILS.GET_TEXT('CZ_LCE_VIRTUAL_COMPONENT', 'ARGUMENTNAME', h_tArgumentName(i), 'NODENAME', v_node_name), 1);
          flagInvalidCX := 1;
        END IF;

        IF(v_tExplNodeId(i) IS NULL)THEN

          RAISE CZ_G_INVALID_RULE_EXPLOSION;
        ELSE
          verify_explosion(v_tExplNodeId(i));
        END IF;
      END IF;

      IF(v_rule_type = RULE_TYPE_JAVA_METHOD AND v_tPropertyId(i) IS NOT NULL)THEN

        FOR ii IN expressionStart..expressionEnd LOOP
          IF(v_tExprId(ii) = v_tExprParentId(i))THEN

            BEGIN
              SELECT NVL(property_value, property_num_value) INTO v_property_value
                FROM cz_psnode_propval_v
               WHERE ps_node_id = v_tExprPsNodeId(ii)
                 AND property_id = v_tPropertyId(i);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                v_property_value := NULL;
            END;

            IF(v_property_value IS NULL)THEN

              v_property_name := NULL;
              v_item_name := NULL;
              v_parent_id := NULL;
              v_parent_name := NULL;

              BEGIN
                SELECT name INTO v_property_name
                  FROM cz_properties
                 WHERE deleted_flag = '0'
                   AND property_id = v_tPropertyId(i);

                SELECT parent_id, name INTO v_parent_id, v_item_name
                  FROM cz_ps_nodes
                 WHERE deleted_flag = '0'
                   AND ps_node_id = v_tExprPsNodeId(ii);

                SELECT name INTO v_parent_name
                  FROM cz_ps_nodes
                 WHERE deleted_flag = '0'
                   AND ps_node_id = v_parent_id;
              EXCEPTION
                WHEN OTHERS THEN
                  --Just use the information we can get and log the following message.
                  NULL;
              END;

              --'Property value for ''%PROPERTYNAME'' is not defined for item ''%ITEMNAME'' with parent ''%PARENTNAME''
              -- in model ''%MODELNAME''. Rule ''%RULENAME'' ignored.
              report(CZ_UTILS.GET_TEXT('CZ_R_OPTION_NO_PROPERTY', 'PROPERTYNAME', v_property_name, 'ITEMNAME', v_item_name,
                                       'PARENTNAME', v_parent_name, 'MODELNAME', v_model_name, 'RULENAME', rule_name), 1);
              flagInvalidCX := 1;
            END IF;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      IF(v_tExprType(i) = EXPR_NODE_TYPE_NODE)THEN
        IF(v_tExprPsNodeId(i) IS NULL)THEN

          RAISE CZ_R_INCORRECT_NODE_ID;
        END IF;
      ELSIF(v_tExprType(i) = EXPR_NODE_TYPE_LITERAL)THEN
        IF(((NOT h_tJavaDataType.EXISTS(i)) OR h_tJavaDataType(i) IS NULL OR h_tJavaDataType(i) <> STRING_JAVA_TYPE) AND
           v_tExprDataValue(i) IS NULL AND v_tExprDataNumValue(i) IS NULL)THEN

          RAISE CZ_R_LITERAL_NO_VALUE;
        END IF;

        IF(v_tExprDataType(i) IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL) AND v_tExprDataNumValue(i) IS NULL)THEN

          BEGIN
            v_number := TO_NUMBER(v_tExprDataValue(i));
          EXCEPTION
            WHEN OTHERS THEN
              RAISE CZ_R_INCORRECT_NODE_ID;
          END;
        END IF;
      END IF;

      IF(v_tExprPsNodeId(i) IS NOT NULL AND v_expl_id IS NOT NULL AND v_component_id IS NOT NULL)THEN
        IF(v_rule_type = RULE_TYPE_JAVA_METHOD AND h_tJavaDataType.EXISTS(i))THEN

          x_error := in_cx_boundary(v_expl_id, v_component_id, v_tExplNodeId(i), v_tExprPsNodeId(i));

          IF(x_error = YES)THEN

            v_RelativeNodePath(i) := generate_relative_path(v_expl_id, v_component_id, v_tExplNodeId(i), v_tExprPsNodeId(i));

            IF(v_virtual_flag = '0')THEN

              --Bug #4178506. This is an instantiable component or component set. Check the generated path.
              --If the path ends with ../ then we approach the argument from below, and so if it is a
              --component set, we need to add /../<id>/ to the path. If the path ends with <id>/ then we
              --are approaching the argument from above, and so if it is a component, it should be rejected.

              IF(SUBSTR(v_RelativeNodePath(i), LENGTH(v_RelativeNodePath(i)) - 2, 3) = '../')THEN
                IF(h_tJavaDataType(i) = COMPONENTSET_JAVA_TYPE)THEN

                  v_RelativeNodePath(i) := v_RelativeNodePath(i) || '../' || TO_CHAR(v_tExprPsNodeId(i)) || '/';
                END IF;
              ELSE
                IF(h_tJavaDataType(i) IN (COMPONENT_JAVA_TYPE, COMPONENTINST_JAVA_TYPE))THEN

                  --'You cannot bind an argument that is an instantiable component when it is not an ancestor of the
                  -- base node. The argument node ''%NODENAME'' is not an ancestor of the base node ''%BASENAME''.'
                  report(CZ_UTILS.GET_TEXT('CZ_LCE_NON_VIRTUAL_ARG', 'NODENAME', v_node_name, 'BASENAME', v_base_name), 1);
                  flagInvalidCX := 1;
                END IF;
              END IF;
            END IF;
          ELSIF(x_error = BASE_UNDER_CONNECTOR)THEN

            --'You cannot choose a base node that is a node in the target of a Connector. ''%BASENAME'' is in the
            -- target of a Connector.'
            report(CZ_UTILS.GET_TEXT('CZ_LCE_BASE_CONNECTED', 'BASENAME', v_base_name), 1);
            flagInvalidCX := 1;
          ELSIF(x_error = ARG_UNDER_CONNECTOR)THEN

            --'You cannot choose an argument node that is a node in the target of a Connector. ''%NODENAME'' is
            -- in the target of a Connector.'
            report(CZ_UTILS.GET_TEXT('CZ_LCE_ARG_CONNECTED', 'NODENAME', v_node_name), 1);
            flagInvalidCX := 1;
          ELSIF(x_error = CROSS_BOUNDARY)THEN

            --'An instance of an argument node must be accessible at runtime from an instance of the base node.
            -- The argument node ''%NODENAME'' is not accessible in this way from the base node ''%BASENAME''.'
            report(CZ_UTILS.GET_TEXT('CZ_LCE_CROSS_BOUNDARY', 'NODENAME', v_node_name, 'BASENAME', v_base_name), 1);
            flagInvalidCX := 1;
          END IF;
        ELSE --This is not a Configurator Extension.
          IF(in_boundary(v_expl_id, v_tExplNodeId(i), v_persistent_id) = 1)THEN

            v_RelativeNodePath(i) := generate_relative_path(v_expl_id, v_component_id, v_tExplNodeId(i), v_tExprPsNodeId(i));
          ELSE
            --'Rule ''%RULENAME'' cannot be generated because it relates an incorrect combination of components. Rule ignored.'
            report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_R_INVALID_RULE', 'RULENAME', rule_name), 1);
            flagInvalidCX := 1;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF(flagInvalidCX = 0)THEN

    FORALL i IN expressionStart..expressionEnd
      UPDATE cz_expression_nodes SET relative_node_path = v_RelativeNodePath(i)
       WHERE expr_node_id = v_tExprId(i);

    IF(initRuleStatus = '1')THEN

       mark_rule_valid;
    END IF;

    x_run_id := 0;

  ELSE

    IF(initRuleStatus = '0')THEN

      mark_rule_invalid;
    END IF;

    --'The Configurator Extension Rule ''%RULENAME'' in the Model ''%MODELNAME'' will be disabled.'
    report(CZ_UTILS.GET_TEXT('CZ_LCE_DISABLE_CX_RULE', 'RULENAME', rule_name, 'MODELNAME', v_model_name), 1);
  END IF;
    --NO COMMIT;
EXCEPTION
  WHEN CZ_R_NO_PARTICIPANTS THEN
    set_status(initRuleStatus);
--'Incomplete rule - no participants, rule ''%RULENAME'' ignored'
    report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_R_NO_PARTICIPANTS', 'RULENAME', rule_name), 1);
  WHEN CZ_R_WRONG_EXPRESSION_NODE THEN
    set_status(initRuleStatus);
--'Incorrect node in expression, rule ''%RULENAME'' ignored'
    report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_R_WRONG_EXPRESSION_NODE', 'RULENAME', rule_name), 1);
  WHEN CZ_G_INVALID_RULE_EXPLOSION THEN
    set_status(initRuleStatus);
--'Unable to generate rule ''%RULENAME'', internal data error.'
    report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_G_INTERNAL_RULE_ERROR', 'RULENAME', rule_name), 1);
  WHEN CZ_R_INCORRECT_NODE_ID THEN
    set_status(initRuleStatus);
--'Incomplete or invalid data in rule ''%RULENAME'', rule ignored'
    report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_NODE_ID', 'RULENAME', rule_name), 1);
  WHEN CZ_R_LITERAL_NO_VALUE THEN
    set_status(initRuleStatus);
--'No literal value specified in rule ''%RULENAME'', rule ignored'
    report('(' || p_rule_id || '): ' || CZ_UTILS.GET_TEXT('CZ_R_LITERAL_NO_VALUE', 'RULENAME', rule_name), 1);
END verify_special_rule;
---------------------------------------------------------------------------------------
PROCEDURE in_boundary (p_base_expl_id            IN NUMBER,
                       p_node_expl_id            IN NUMBER,
                       p_node_persistent_node_id IN NUMBER,
                       x_output                  OUT NOCOPY PLS_INTEGER) IS
BEGIN
  x_output := in_boundary (p_base_expl_id, p_node_expl_id, p_node_persistent_node_id);
END in_boundary;
---------------------------------------------------------------------------------------
--This function generates a path of persistent_node_ids within a model using the runtime
--notation: #PARENT.<id>.

--p_start_node_id - start node ps_node_id;
--p_end_node_id - end node ps_node_id.

FUNCTION runtime_model_path(p_start_node_id      IN NUMBER,
                            p_end_node_id        IN NUMBER)
  RETURN VARCHAR2 IS

  v_path                 VARCHAR2(32000);
  v_local_path           VARCHAR2(32000);

  v_ps_node_id_hash      t_varchar_array_tbl_type_vc2;-- kdande; Bug 6880555; 12-Mar-2008
  v_start_node_id_tab    t_num_array_tbl_type;
  v_start_parent_id_tab  t_num_array_tbl_type;
  v_start_persist_id_tab t_num_array_tbl_type;
  v_end_node_id_tab      t_num_array_tbl_type;
  v_end_parent_id_tab    t_num_array_tbl_type;
  v_end_persist_id_tab   t_num_array_tbl_type;

BEGIN

  IF((p_start_node_id IS NULL AND p_end_node_id IS NULL) OR (p_start_node_id = p_end_node_id))THEN RETURN NULL; END IF;

  SELECT ps_node_id, parent_id, persistent_node_id
    BULK COLLECT INTO v_start_node_id_tab, v_start_parent_id_tab, v_start_persist_id_tab
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
   START WITH ps_node_id = p_start_node_id
 CONNECT BY PRIOR parent_id = ps_node_id;

  SELECT ps_node_id, parent_id, persistent_node_id
    BULK COLLECT INTO v_end_node_id_tab, v_end_parent_id_tab, v_end_persist_id_tab
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
   START WITH ps_node_id = p_end_node_id
 CONNECT BY PRIOR parent_id = ps_node_id;

  IF(p_start_node_id IS NULL OR v_start_node_id_tab.COUNT = 1)THEN

    --We need to construct the path down from the root to the end node.

    FOR i IN 1..v_end_node_id_tab.COUNT - 1 LOOP

      v_path := TO_CHAR(v_end_persist_id_tab(i)) || '.' || v_path;
    END LOOP;
    RETURN v_path;
  END IF;

  IF(p_end_node_id IS NULL OR v_end_parent_id_tab.COUNT = 1)THEN

    --We need to construct the '#PARENT' path up to the root from the start node.

    FOR i IN 1..v_start_node_id_tab.COUNT - 1 LOOP

      v_path := '#PARENT.' || v_path;
    END LOOP;
    RETURN v_path;
  END IF;

  --We need to construct a mixed path from the start node to the end node.
  --In order to find the LCA of the two nodes, first build a hash map from the end node to the root.

  FOR i IN 1..v_end_node_id_tab.COUNT LOOP

    v_ps_node_id_hash(v_end_node_id_tab(i)) := v_local_path;
    v_local_path := TO_CHAR(v_end_persist_id_tab(i)) || '.' || v_local_path;

    --In case the start node is a direct ancestor of the end node.

    IF(v_end_parent_id_tab(i) = p_start_node_id)THEN RETURN v_local_path; END IF;
  END LOOP;

  --We know that the start node is not a direct ancestor of the end node. Go up from the start node
  --until one of the following occurs: we hit the end node which is a direct ancestor of the start
  --node, or we hit entry in the hash table meaning the LCA.

  FOR i IN 1..v_start_node_id_tab.COUNT LOOP

    v_path := '#PARENT.' || v_path;

    IF(v_start_parent_id_tab(i) = p_end_node_id)THEN RETURN v_path; END IF;
    IF(v_ps_node_id_hash.EXISTS(v_start_parent_id_tab(i)))THEN

      RETURN v_path || v_ps_node_id_hash(v_start_parent_id_tab(i));
    END IF;
  END LOOP;

 RETURN v_path || v_local_path;
END runtime_model_path;
---------------------------------------------------------------------------------------
FUNCTION runtime_relative_path(p_base_expl_id IN NUMBER,
                               p_base_pers_id IN NUMBER,
                               p_node_expl_id IN NUMBER,
                               p_node_pers_id IN NUMBER)
  RETURN VARCHAR2 IS

  v_base_expl_id_tab      t_num_array_tbl_type;
  v_base_expl_type_tab    t_num_array_tbl_type;
  v_base_ref_id_tab       t_num_array_tbl_type;
  v_base_component_id_tab t_num_array_tbl_type;
  v_node_expl_id_tab      t_num_array_tbl_type;
  v_node_expl_type_tab    t_num_array_tbl_type;
  v_node_ref_id_tab       t_num_array_tbl_type;
  v_node_component_id_tab t_num_array_tbl_type;

  v_path                  VARCHAR2(32000);
  v_expl_path_hash        t_varchar_array_tbl_type;

  v_base_ref_expl_index   PLS_INTEGER;
  v_node_ref_expl_index   PLS_INTEGER;
  v_base_ref_expl_id      NUMBER;
  v_node_ref_expl_id      NUMBER;
  v_prev_referring_id     NUMBER;
  v_base_node_type        NUMBER;
  v_node_node_type        NUMBER;
  v_base_devl_project_id  NUMBER;
  v_node_devl_project_id  NUMBER;

  p_base_node_id          NUMBER;
  p_node_node_id          NUMBER;

  REFERENCE               CONSTANT PLS_INTEGER := 263;
  CONNECTOR               CONSTANT PLS_INTEGER := 264;

BEGIN

  IF(p_base_pers_id = p_node_pers_id AND p_base_expl_id = p_node_expl_id)THEN RETURN NULL; END IF;

  SELECT model_ref_expl_id, referring_node_id, ps_node_type, component_id
    BULK COLLECT INTO v_base_expl_id_tab, v_base_ref_id_tab, v_base_expl_type_tab, v_base_component_id_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_base_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  SELECT model_ref_expl_id, referring_node_id, ps_node_type, component_id
    BULK COLLECT INTO v_node_expl_id_tab, v_node_ref_id_tab, v_node_expl_type_tab, v_node_component_id_tab
    FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
   START WITH model_ref_expl_id = p_node_expl_id
 CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id;

  SELECT ps_node_type INTO v_base_node_type
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
     AND persistent_node_id = p_base_pers_id
     AND ROWNUM = 1;

  SELECT ps_node_type INTO v_node_node_type
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
     AND persistent_node_id = p_node_pers_id
     AND ROWNUM = 1;

  --Here we need to work only with references, because whatever explosions are within a model, they
  --will be processed in one call to generate_model_path. So, find the deepest references above the
  --base and argument nodes to start. Can as well be the root model or the nodes themselves.

  FOR i IN 1..v_base_expl_id_tab.COUNT LOOP

    v_base_ref_expl_index := i;
    IF(v_base_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN EXIT; END IF;
  END LOOP;

  FOR i IN 1..v_node_expl_id_tab.COUNT LOOP

    v_node_ref_expl_index := i;
    IF(v_node_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN EXIT; END IF;
  END LOOP;

  --Explosion ids of the deepest references above the base and argument.

  v_base_ref_expl_id := v_base_expl_id_tab(v_base_ref_expl_index);
  v_node_ref_expl_id := v_node_expl_id_tab(v_node_ref_expl_index);

  IF(v_base_node_type IN (REFERENCE, CONNECTOR))THEN

    --If the node is a reference, it must be specified together with its own explosion.

    p_base_node_id := v_base_ref_id_tab(v_base_ref_expl_index);

    SELECT devl_project_id INTO v_base_devl_project_id FROM cz_ps_nodes
     WHERE deleted_flag = '0' AND ps_node_id = p_base_node_id;
  ELSE

    SELECT ps_node_id, devl_project_id INTO p_base_node_id, v_base_devl_project_id FROM cz_ps_nodes
     WHERE deleted_flag = '0'
       AND persistent_node_id = p_base_pers_id
       AND devl_project_id =
         (SELECT devl_project_id FROM cz_ps_nodes WHERE ps_node_id = v_base_component_id_tab(v_base_ref_expl_index));
  END IF;

  IF(v_node_node_type IN (REFERENCE, CONNECTOR))THEN

    --If the node is a reference, it must be specified together with its own explosion.

    p_node_node_id := v_node_ref_id_tab(v_node_ref_expl_index);

    SELECT devl_project_id INTO v_node_devl_project_id FROM cz_ps_nodes
     WHERE deleted_flag = '0' AND ps_node_id = p_node_node_id;
  ELSE

    SELECT ps_node_id, devl_project_id INTO p_node_node_id, v_node_devl_project_id FROM cz_ps_nodes
     WHERE deleted_flag = '0'
       AND persistent_node_id = p_node_pers_id
       AND devl_project_id =
         (SELECT devl_project_id FROM cz_ps_nodes WHERE ps_node_id = v_node_component_id_tab(v_node_ref_expl_index));
  END IF;

  IF(p_base_node_id = v_base_ref_id_tab(v_base_ref_expl_index) AND
     p_node_node_id = v_node_ref_id_tab(v_node_ref_expl_index) AND
     v_base_devl_project_id = v_node_devl_project_id)THEN

    --Both base and argument are references and are in the same model.

    RETURN cut_dot(runtime_model_path(p_base_node_id, p_node_node_id));
  END IF;

  IF(v_base_ref_expl_id = v_node_ref_expl_id)THEN
    IF(p_base_node_id = v_base_ref_id_tab(v_base_ref_expl_index))THEN

      --The base node is the reference itself, so the argument is a node in the referenced model.

      RETURN cut_dot(runtime_model_path(NULL, p_node_node_id));
    ELSIF(p_node_node_id = v_node_ref_id_tab(v_node_ref_expl_index))THEN

      --The argument node is the reference itself, so the base is a node in the referenced model.

      RETURN cut_dot(runtime_model_path(p_base_node_id, NULL));
    ELSE

      --Both base and argument are in the same model.

      RETURN cut_dot(runtime_model_path(p_base_node_id, p_node_node_id));
    END IF;
  END IF;

  --Now we know that base and argument are in different models. Check if the base node is in the
  --root model. If it is, we skip going up from it.

  IF(v_base_ref_id_tab(v_base_ref_expl_index) IS NOT NULL)THEN

    --We will go up from the base node because it is not in the root model.
    --If the base node is not the reference itself, we start the path with the model path from
    --the base node up.

    IF(p_base_node_id <> v_base_ref_id_tab(v_base_ref_expl_index))THEN

      v_path := runtime_model_path(p_base_node_id, NULL);
    END IF;

    v_prev_referring_id := v_base_ref_id_tab(v_base_ref_expl_index);

    FOR i IN v_base_ref_expl_index + 1..v_base_expl_id_tab.COUNT LOOP

      IF(v_base_expl_id_tab(i) = v_node_ref_expl_id)THEN

        --We hit the argument node's explosion on the way up. If the argument node is the reference
        --itself, we build the path through the whole model, otherwise the argument is an internal
        --node, so we use a partial model path from the reference.

        IF(p_node_node_id = v_node_ref_id_tab(v_node_ref_expl_index))THEN

          v_path := v_path || runtime_model_path(v_prev_referring_id, NULL);
        ELSE

          v_path := v_path || runtime_model_path(v_prev_referring_id, p_node_node_id);
        END IF;
        RETURN cut_dot(v_path);
      ELSIF(v_base_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN

        v_path := v_path || runtime_model_path(v_prev_referring_id, NULL);
        v_prev_referring_id := v_base_ref_id_tab(i);

        --Create an entry in the hash table which may be used to find the LCA of the base and
        --argument nodes.

        v_expl_path_hash(v_base_expl_id_tab(i)) := v_path;
      END IF;
    END LOOP;
  END IF; --the base node is not in the root model.

  --We went all the way up from the base node but we haven't hit the argument node. So the
  --argument node is either down the tree or in a different branch. We are going to go up
  --from the argument node. If the argument node is not the reference itself, we start
  --the path with the model path from the argument node up.

  --v_node_ref_id_tab(v_node_ref_expl_index) is not null: argument is not in the root model
  --otherwise we would have hit it before.

  v_path := NULL;
  v_prev_referring_id := v_node_ref_id_tab(v_node_ref_expl_index);

  IF(p_node_node_id <> v_node_ref_id_tab(v_node_ref_expl_index))THEN

    v_path := runtime_model_path(NULL, p_node_node_id);
  END IF;

  FOR i IN v_node_ref_expl_index + 1..v_node_expl_id_tab.COUNT LOOP

    --Go up the tree from the argument node's explosion.

    IF(v_node_expl_id_tab(i) = v_base_ref_expl_id)THEN

      --We hit the base node's explosion on the way up. If the base node is the reference itself
      --(or the root model) we build the path through the whole model, otherwise the base is an
      --internal node, so we use a partial model path from the reference.

      IF(p_base_node_id = v_base_ref_id_tab(v_base_ref_expl_index))THEN

        v_path := runtime_model_path(NULL, v_prev_referring_id) || v_path;
      ELSE

        v_path := runtime_model_path(p_base_node_id, v_prev_referring_id) || v_path;
      END IF;
     RETURN (cut_dot(v_path));
    ELSIF(v_expl_path_hash.EXISTS(v_node_expl_id_tab(i)))THEN

      --We hit the LCA. The base node is in the different branch, otherwise the hash entry would not
      --exist. This can be the very root model, so this is the ultimate return point.

      RETURN cut_dot(v_expl_path_hash(v_node_expl_id_tab(i)) || v_path);

    ELSIF(v_node_expl_type_tab(i) IN (REFERENCE, CONNECTOR))THEN

      v_path := runtime_model_path(NULL, v_prev_referring_id) || v_path;
      v_prev_referring_id := v_node_ref_id_tab(i);
    END IF;
  END LOOP;

 --Algorithmically we can never be here.

 RETURN NULL;
END runtime_relative_path;

---- this functions does validations required during the time of
---- moving a rule or rule folder to a different folder
PROCEDURE is_rule_movable(p_src_rule_id    IN cz_rule_folders.rule_folder_id%TYPE,
					    p_src_rule_type   IN cz_rule_folders.object_type%TYPE,
					    p_tgt_rule_fld_id IN cz_rule_folders.rule_folder_id%TYPE,
					    x_return_status OUT NOCOPY VARCHAR2,
				  	    x_msg_count      OUT NOCOPY NUMBER,
					    x_msg_data       OUT NOCOPY VARCHAR2)
IS
TYPE t_ref is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_src_rule_id    	  NUMBER;
l_src_object_type	  cz_rule_folders.object_type%TYPE;
l_tgt_object_type         cz_rule_folders.object_type%TYPE;
l_tgt_rule_fld_id 	  NUMBER;
l_parent_rule_folder_id   NUMBER;
l_tgt_parent_fld_id 	  NUMBER;
l_deleted_flag    	  VARCHAR2(1);
l_valid_move      	  NUMBER := 0;
l_tgt_devl_project_id     NUMBER;
l_src_devl_project_id     NUMBER;
SRCRULE_DOES_NOT_EXIST    EXCEPTION;
SRCRULE_IS_DELETED        EXCEPTION;
TGTRULEFLD_DOES_NOT_EXIST EXCEPTION;
INVALID_CIRCULAR_MOVE     EXCEPTION;
CANNOT_MOVE_TO_THIS_FLD   EXCEPTION;
CAN_MOVE_IN_SAME_PROJECT  EXCEPTION;
OBJTYPE_NOT_ALLOWED      EXCEPTION;
l_rule_fld_tbl		  t_ref;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   fnd_msg_pub.initialize;

   BEGIN
	SELECT rule_folder_id,object_type,deleted_flag,parent_rule_folder_id,devl_project_id
	INTO   l_src_rule_id,l_src_object_type,l_deleted_flag,l_parent_rule_folder_id,l_src_devl_project_id
	FROM   cz_rule_folders
	WHERE  cz_rule_folders.rule_folder_id = p_src_rule_id
	AND    cz_rule_folders.object_type    = p_src_rule_type;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	l_src_rule_id := -1;
   END;

   IF (l_src_rule_id = -1) THEN
	RAISE SRCRULE_DOES_NOT_EXIST;
   END IF;

   IF (l_deleted_flag = '1') THEN
	RAISE SRCRULE_IS_DELETED;
   END IF;

   BEGIN
	SELECT rule_folder_id,parent_rule_folder_id,devl_project_id,object_type
	INTO   l_tgt_rule_fld_id,l_tgt_parent_fld_id,l_tgt_devl_project_id,l_tgt_object_type
	FROM   cz_rule_folders
	WHERE  cz_rule_folders.rule_folder_id = p_tgt_rule_fld_id
	AND    cz_rule_folders.object_type IN ('RFL','RSQ')
	AND    cz_rule_folders.deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	l_tgt_rule_fld_id := -1;
   END;

   IF (l_tgt_rule_fld_id = -1) THEN
	RAISE TGTRULEFLD_DOES_NOT_EXIST;
   END IF;

   IF (( (p_src_rule_id = p_tgt_rule_fld_id) AND (p_src_rule_type = 'RFL'))
	OR ( (l_tgt_parent_fld_id = p_tgt_rule_fld_id) AND (p_src_rule_type <> 'RFL') ) ) THEN
	RAISE INVALID_CIRCULAR_MOVE;
   END IF;

   IF ( p_src_rule_type in ('FNC','RFL','RSQ') AND (l_tgt_object_type = 'RSQ') ) THEN
       RAISE OBJTYPE_NOT_ALLOWED;
   END IF;

   IF (p_src_rule_type = 'RFL') THEN
   BEGIN
	l_rule_fld_tbl.DELETE;
	SELECT rule_folder_id
	BULK
	COLLECT
	INTO   l_rule_fld_tbl
	FROM   cz_rule_folders
	WHERE  cz_rule_folders.object_type = 'RFL'
	AND    cz_rule_folders.deleted_flag = '0'
        START WITH cz_rule_folders.rule_folder_id = p_src_rule_id
        CONNECT BY PRIOR rule_folder_id = parent_rule_folder_id
	AND PRIOR object_type = 'RFL'
	AND PRIOR deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	NULL;
   END;
   END IF;

   IF (l_rule_fld_tbl.COUNT > 0) THEN
	FOR I IN l_rule_fld_tbl.FIRST..l_rule_fld_tbl.LAST
	LOOP
	   IF (l_rule_fld_tbl(i) = p_tgt_rule_fld_id) THEN
		l_valid_move := 1;
		EXIT;
	   END IF;
	END LOOP;
      IF (l_valid_move = 1) THEN
	RAISE CANNOT_MOVE_TO_THIS_FLD;
      END IF;
   END IF;

   IF (l_src_devl_project_id <> l_tgt_devl_project_id) THEN
	RAISE CAN_MOVE_IN_SAME_PROJECT;
   END IF;

EXCEPTION
WHEN SRCRULE_DOES_NOT_EXIST THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_SRCRULE_DOES_NOT_EXIST');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN SRCRULE_IS_DELETED THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_SRCRULE_IS_DELETED');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN TGTRULEFLD_DOES_NOT_EXIST THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_TGTRULEFLD_DOES_NOT_EXIST');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN INVALID_CIRCULAR_MOVE THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_INVALID_CIRCULAR_MOVE');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN OBJTYPE_NOT_ALLOWED THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_DEV_FOLDER_SEQ_INCOMPAT_ERR');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN  CANNOT_MOVE_TO_THIS_FLD  THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_CANNOT_MOVE_TO_THIS_FLD');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN CAN_MOVE_IN_SAME_PROJECT THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_CAN_MOVE_IN_SAME_PROJECT');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_CANNOT_MOVE_TO_THIS_FLD');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
END is_rule_movable;
---------------------------------------------------------------------------------------
/*#
 * This function is used for effectivity filtering in CZ_EXPLNODES_IMAGE_EFF_V. When called
 * on a node and given the node's parent identity and node's effectivity parameters it
 * returns 1 if the node is visible with the current effectivity filtering settings,
 * 0 otherwise.
 *
 * @param p_parent_psnode_id   correspond to cz_explmodel_nodes_v.effective_parent_id
 * @param p_parent_expl_id     correspond to cz_explmodel_nodes_v.parent_psnode_expl_id
 * p_model_id                  correspond to cz_explmodel_nodes_v.model_id
 * p_self_eff_from             correspond to cz_explmodel_nodes_v.effective_from
 * p_self_eff_until            correspond to cz_explmodel_nodes_v.effective_until
 * p_self_eff_set_id           correspond to cz_explmodel_nodes_v.effectivity_set_id
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Auxiliary function for using in CZ_EXPLNODES_IMAGE_EFF_V
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category Effectivity Filtering
 */

FUNCTION is_node_visible(p_parent_psnode_id  IN NUMBER,
                         p_parent_expl_id    IN NUMBER,
                         p_model_id          IN NUMBER,
                         p_self_eff_from     IN DATE,
                         p_self_eff_until    IN DATE,
                         p_self_eff_set_id   IN NUMBER) RETURN PLS_INTEGER IS

  v_parent_id   NUMBER := p_parent_psnode_id;
  v_expl_id     NUMBER := p_parent_expl_id;
  v_eff_from    DATE   := p_self_eff_from;
  v_eff_until   DATE   := p_self_eff_until;
  v_eff_set_id  NUMBER := p_self_eff_set_id;

  v_filter      VARCHAR2(240);

  TYPE date_hash_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  h_eff_from    date_hash_table;
  h_eff_until   date_hash_table;
BEGIN

  --v_parent_id (cz_explmodel_nodes_v.effective_parent_id) can only be null for the root model node
  --which is always effective by definition, so we don't even have to read the profile value, just
  --return 1 immediately.

  WHILE(v_parent_id IS NOT NULL)LOOP

    IF(v_eff_set_id IS NOT NULL)THEN
      IF(h_eff_from.EXISTS(v_eff_set_id))THEN

        v_eff_from := h_eff_from(v_eff_set_id);
        v_eff_until := h_eff_until(v_eff_set_id);
      ELSE

        SELECT effective_from, effective_until INTO v_eff_from, v_eff_until
          FROM cz_effectivity_sets
         WHERE deleted_flag = '0'
           AND effectivity_set_id = v_eff_set_id;

        h_eff_from(v_eff_set_id) := v_eff_from;
        h_eff_until(v_eff_set_id) := v_eff_until;
      END IF;
    END IF;

    --The actual reading of the profile option value will be done only once or, if the node on which
    --the function is called, is always effective - never.

    IF(v_filter IS NULL)THEN
      v_filter := NVL(fnd_profile.value_wnps(PROFILE_OPTION_EFF_FILTER), OPTION_VALUE_FILTER_ALL);
      IF(v_filter = OPTION_VALUE_FILTER_ALL)THEN RETURN 1; END IF;
    END IF;

    IF(v_eff_until < v_eff_from)THEN RETURN 0; END IF;

    IF((v_filter = OPTION_VALUE_FILTER_FUTURE AND v_eff_until <= SYSDATE) OR
       (v_filter = OPTION_VALUE_FILTER_CURRENT AND (SYSDATE < v_eff_from OR SYSDATE >= v_eff_until))
      )THEN RETURN 0; END IF;

    SELECT effective_parent_id, parent_psnode_expl_id, effective_from, effective_until, effectivity_set_id
      INTO v_parent_id, v_expl_id, v_eff_from, v_eff_until, v_eff_set_id
      FROM cz_explmodel_nodes_v
     WHERE model_id = p_model_id
       AND model_ref_expl_id = v_expl_id
       AND ps_node_id = v_parent_id;

  END LOOP;
 RETURN 1;
END;

/*#
 * This function is used for effectivity filtering. It takes a node identity and arrays of effectivity
 * parameters for the children of this node. It returns an array with 0 or 1 for every child of this
 * node, 1 if the child node is visible with the current effectivity filtering settings, 0 otherwise.
 *
 * @param p_parent_psnode_id   ps_node_id of the node
 * @param p_parent_expl_id     model_ref_expl_id of the node
 * p_self_eff_from             array of effective_from values for children of the node
 * p_self_eff_until            array of effective_until values for children of the node
 * p_self_eff_set_id           array of effectivity_set_id values for children of the node
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Auxiliary function for effectivity filtering
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */

FUNCTION get_visibility(p_parent_psnode_id  IN NUMBER,
                        p_parent_expl_id    IN NUMBER,
                        p_self_eff_from     IN system.cz_date_tbl_type,
                        p_self_eff_until    IN system.cz_date_tbl_type,
                        p_self_eff_set_id   IN system.cz_number_tbl_type)
  RETURN system.cz_number_tbl_type IS

  v_parent_id   NUMBER := p_parent_psnode_id;
  v_expl_id     NUMBER := p_parent_expl_id;
  v_eff_from    DATE;
  v_eff_until   DATE;
  v_eff_set_id  NUMBER;

  v_filter      VARCHAR2(240);
  v_flag        PLS_INTEGER;
  v_return      system.cz_number_tbl_type := system.cz_number_tbl_type();

  TYPE date_hash_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  h_eff_from    date_hash_table;
  h_eff_until   date_hash_table;
BEGIN

  v_filter := NVL(fnd_profile.value_wnps(PROFILE_OPTION_EFF_FILTER), OPTION_VALUE_FILTER_ALL);
  IF(v_filter = OPTION_VALUE_FILTER_ALL)THEN
    FOR i IN 1..p_self_eff_set_id.COUNT LOOP
      v_return.EXTEND();
      v_return(i) := 1;
    END LOOP;
   RETURN v_return;
  END IF;

  WHILE(v_expl_id IS NOT NULL)LOOP
    WHILE(v_parent_id IS NOT NULL)LOOP

      SELECT parent_id, effective_from, effective_until, effectivity_set_id
        INTO v_parent_id, v_eff_from, v_eff_until, v_eff_set_id
        FROM cz_ps_nodes
       WHERE deleted_flag = '0'
         AND ps_node_id = v_parent_id;

      IF(v_eff_set_id IS NOT NULL)THEN
        IF(h_eff_from.EXISTS(v_eff_set_id))THEN

          v_eff_from := h_eff_from(v_eff_set_id);
          v_eff_until := h_eff_until(v_eff_set_id);
        ELSE

          SELECT effective_from, effective_until INTO v_eff_from, v_eff_until
            FROM cz_effectivity_sets
           WHERE deleted_flag = '0'
             AND effectivity_set_id = v_eff_set_id;

          h_eff_from(v_eff_set_id) := v_eff_from;
          h_eff_until(v_eff_set_id) := v_eff_until;
        END IF;
      END IF;

      IF(v_eff_until < v_eff_from)THEN
        FOR i IN 1..p_self_eff_set_id.COUNT LOOP
          v_return.EXTEND();
          v_return(i) := 0;
        END LOOP;
       RETURN v_return;
      END IF;

      IF((v_filter = OPTION_VALUE_FILTER_FUTURE AND v_eff_until <= SYSDATE) OR
         (v_filter = OPTION_VALUE_FILTER_CURRENT AND (SYSDATE < v_eff_from OR SYSDATE >= v_eff_until))
        )THEN
          FOR i IN 1..p_self_eff_set_id.COUNT LOOP
            v_return.EXTEND();
            v_return(i) := 0;
          END LOOP;
         RETURN v_return;
      END IF;
    END LOOP;

    SELECT referring_node_id, parent_expl_node_id INTO v_parent_id, v_expl_id
      FROM cz_model_ref_expls
     WHERE deleted_flag = '0'
       AND model_ref_expl_id = v_expl_id;
  END LOOP;

  v_return.extend(p_self_eff_set_id.COUNT);

  FOR i IN 1..p_self_eff_set_id.COUNT LOOP

    v_eff_from := p_self_eff_from(i);
    v_eff_until := p_self_eff_until(i);
    v_eff_set_id := p_self_eff_set_id(i);

    IF(v_eff_set_id IS NOT NULL)THEN
      IF(h_eff_from.EXISTS(v_eff_set_id))THEN

        v_eff_from := h_eff_from(v_eff_set_id);
        v_eff_until := h_eff_until(v_eff_set_id);
      ELSE

        SELECT effective_from, effective_until INTO v_eff_from, v_eff_until
          FROM cz_effectivity_sets
         WHERE deleted_flag = '0'
           AND effectivity_set_id = v_eff_set_id;

        h_eff_from(v_eff_set_id) := v_eff_from;
        h_eff_until(v_eff_set_id) := v_eff_until;
      END IF;
    END IF;

    IF(v_eff_until < v_eff_from)THEN v_return(i) := 0;

    ELSIF((v_filter = OPTION_VALUE_FILTER_FUTURE AND v_eff_until <= SYSDATE) OR
       (v_filter = OPTION_VALUE_FILTER_CURRENT AND (SYSDATE < v_eff_from OR SYSDATE >= v_eff_until))
      )THEN v_return(i) := 0;

    ELSE v_return(i) := 1; END IF;
  END LOOP;
 RETURN v_return;
END;

/*#
 * This procedure is a wrapper over the function to be called by the Developer.
 *
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Wrapper over the function for Developer
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */

PROCEDURE get_visibility(p_parent_psnode_id  IN NUMBER,
                         p_parent_expl_id    IN NUMBER,
                         p_self_eff_from     IN system.cz_date_tbl_type,
                         p_self_eff_until    IN system.cz_date_tbl_type,
                         p_self_eff_set_id   IN system.cz_number_tbl_type,
                         x_is_visible        IN OUT NOCOPY system.cz_number_tbl_type) IS
BEGIN
  x_is_visible := get_visibility(p_parent_psnode_id,
                                 p_parent_expl_id,
                                 p_self_eff_from,
                                 p_self_eff_until,
                                 p_self_eff_set_id);
END;
---------------------------------------------------------------------------------------
FUNCTION annotated_node_path(p_model_id           IN NUMBER,
                             p_model_ref_expl_id  IN NUMBER,
                             p_ps_node_id         IN NUMBER) RETURN VARCHAR2
IS
  v_model_expl_id  cz_model_ref_expls.model_ref_expl_id%TYPE;
BEGIN

  SELECT model_ref_expl_id INTO v_model_expl_id FROM cz_model_ref_expls
   WHERE deleted_flag = '0'
     AND model_id = p_model_id
     AND parent_expl_node_id IS NULL;

  RETURN generate_relative_path_(v_model_expl_id, p_model_id, p_model_ref_expl_id, p_ps_node_id, 1);
END;
---------------------------------------------------------------------------------------
/*#
 * This function is used for getting translated description for a given object id and object type.
 * It takes object_id and object_type as an input and returns the translated description.
 *
 * @param object_id               object_id of the repository object
 * @param object_type             object_type of the repository object
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname Function for getting translated usage description.
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category
 */

FUNCTION get_trans_desc(object_id  IN NUMBER,object_type  IN varchar2) RETURN VARCHAR2 IS

trans_desc cz_model_usages_tl.description%TYPE;

BEGIN

  IF (OBJECT_TYPE='USG')
  THEN
  SELECT description INTO trans_desc FROM cz_model_usages_tl
  where model_usage_id=object_id AND language = userenv('LANG');
  END IF;

  RETURN trans_desc;

EXCEPTION

WHEN NO_DATA_FOUND THEN
RETURN NULL;
END;
---------------------------------------------------------------------------------------

/*
 * This function returns the date when the logic generation occured
 * It uses the model id to determine engine type for switching between
 * cz_lce_headers (LCE) and cz_fce_files (FCE).
 *
 * @param p_model_id              model id
 */
FUNCTION GET_LAST_LOGIC_GEN_DATE(p_model_id in NUMBER)
  RETURN CZ_FCE_FILES.CREATION_DATE%TYPE

IS
  l_last_log_gen_date cz_fce_files.creation_date%TYPE;
  l_config_engine_type cz_devl_projects.config_engine_type%TYPE;
BEGIN

    SELECT config_engine_type
    INTO l_config_engine_type
    FROM cz_devl_projects
    WHERE devl_project_id = p_model_id;


    if (l_config_engine_type = LCE_ENGINE_TYPE OR l_config_engine_type IS NULL) THEN
      SELECT creation_date
      INTO   l_last_log_gen_date
      FROM   cz_lce_headers
      WHERE  deleted_flag = 0 AND
             net_type = 1 AND
             component_id = devl_project_id AND devl_project_id = p_model_id;
    ELSE
      SELECT MAX(creation_date)
      INTO   l_last_log_gen_date
      FROM   cz_fce_files
      WHERE  deleted_flag = 0 AND
             component_id = p_model_id AND
             fce_file_type = 1;
   END IF;

  return l_last_log_gen_date;

  EXCEPTION
    when NO_DATA_FOUND then
    return null;
END GET_LAST_LOGIC_GEN_DATE;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION convertClassName(p_class_name IN VARCHAR2,p_pattern IN VARCHAR2) RETURN VARCHAR2 IS
    l_substr          CZ_RULES.class_name%TYPE;
    l_output          CZ_RULES.class_name%TYPE;
    l_reverse_string  CZ_RULES.class_name%TYPE;
    l_reverse_pattern CZ_RULES.class_name%TYPE;
    l_index           NUMBER;
    l_next_index      NUMBER;
BEGIN

    SELECT REVERSE(p_class_name) INTO l_reverse_string FROM dual;
    SELECT REVERSE(p_pattern) INTO l_reverse_pattern FROM dual;

    l_index := INSTR(l_reverse_string,'.');

    IF l_index=0 THEN
      l_output := p_pattern||'.'||p_class_name;
    ELSE
      l_next_index := INSTR(SUBSTR(l_reverse_string,l_index+1),'.');
      IF l_next_index=0 THEN
         l_substr := SUBSTR(l_reverse_string,l_index);
      ELSE
         l_substr := SUBSTR(l_reverse_string, l_index,l_next_index);
      END IF;

      IF l_substr='.'||l_reverse_pattern THEN
        l_output := p_class_name;
      ELSE
        l_output := REPLACE(p_class_name,SUBSTR(p_class_name,1,LENGTH(p_class_name)-l_index),
        SUBSTR(p_class_name,1,LENGTH(p_class_name)-l_index)||'.'||p_pattern);
      END IF;
    END IF;
    RETURN l_output;
END convertClassName;

PROCEDURE ConvertModelCXs
(
p_model_id      IN NUMBER,
x_return_status OUT  NOCOPY VARCHAR2,
x_msg_count     OUT  NOCOPY NUMBER,
x_msg_data      OUT  NOCOPY VARCHAR2
) IS
    l_new_class_name   CZ_RULES.class_name%TYPE;
BEGIN

  x_return_status    := FND_API.g_ret_sts_success;
  x_msg_count        := 0;
  x_msg_data         := '';

  FOR i IN(SELECT args.argument_signature_id, args.java_data_type, args.data_type, args.argument_index, rul.class_name, rul.rule_id
             FROM CZ_RULES rul,
                  CZ_EXPRESSION_NODES expr,
                  CZ_SIGNATURE_ARGUMENTS args
            WHERE rul.rule_type = 300 AND rul.devl_project_id = p_model_id AND
                  expr.rule_id = rul.rule_id AND expr.expr_parent_id is null AND
                  expr.param_signature_id = args.argument_signature_id AND
                  args.java_data_type like 'oracle.apps.cz.cio.%' AND
                  args.deleted_flag = '0' AND args.seeded_flag = '0' AND
                  rul.deleted_flag = '0' AND expr.deleted_flag = '0')
  LOOP
    UPDATE CZ_SIGNATURE_ARGUMENTS arg
       SET java_data_type = REPLACE(i.java_data_type,'oracle.apps.cz.cio.','oracle.apps.cz.cioemu.')
     WHERE argument_signature_id=i.argument_signature_id AND
           argument_index=i.argument_index AND
           EXISTS(SELECT NULL FROM cz_node_type_Classes
                   WHERE class_name = arg.java_data_type);

    l_new_class_name := convertClassName(i.class_name,'emu');
    IF l_new_class_name<>i.class_name THEN
      UPDATE CZ_RULES
         SET class_name=l_new_class_name
       WHERE rule_id=i.rule_id;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    handle_Error
    (p_procedure_name => 'ConvertModelCXs',
     p_error_message  => SQLERRM,
     x_return_status  => x_return_status,
     x_msg_count      => x_msg_count,
     x_msg_data       => x_msg_data);
END ConvertModelCXs;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE start_model_report (p_devl_project_id IN NUMBER)
IS
BEGIN
  modelReportRun := TRUE; -- vsingava: 24-Nov-2008; Bug 7297669
  --Intitialize the explosion data.
  SELECT model_ref_expl_id, parent_expl_node_id, component_id, referring_node_id, ps_node_type
  BULK COLLECT INTO v_NodeId, v_ParentId, v_ComponentId, v_ReferringId, v_NodeType
  FROM cz_model_ref_expls
  WHERE model_id IN (SELECT component_id FROM cz_model_ref_expls
      WHERE model_id = p_devl_project_id AND deleted_flag = '0')
  AND deleted_flag = '0';

  h_ParentId.DELETE;
  h_NodeType.DELETE;
  h_ReferringId.DELETE;
  h_ComponentId.DELETE;

  FOR i IN 1..v_NodeId.COUNT LOOP
    h_ParentId(v_NodeId(i)) := v_ParentId(i);
    h_NodeType(v_NodeId(i)) := v_NodeType(i);
    h_ReferringId(v_NodeId(i)) := v_ReferringId(i);
    h_ComponentId(v_NodeId(i)) := v_ComponentId(i);
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    	LOG_REPORT( -1, 'Exception in start_model_report :' || SQLERRM );
END start_model_report;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE end_model_report IS
BEGIN
  modelReportRun := FALSE; -- vsingava: 24-Nov-2008; Bug 7297669
  v_NodeId.DELETE;
  v_ParentId.DELETE;
  v_ComponentId.DELETE;
  v_ReferringId.DELETE;
  v_NodeType.DELETE;
  h_ParentId.DELETE;
  h_NodeType.DELETE;
  h_ReferringId.DELETE;
  h_ComponentId.DELETE;
EXCEPTION
    WHEN OTHERS THEN
    	LOG_REPORT( -1, 'Exception in end_model_report :' || SQLERRM );
END end_model_report;


END CZ_DEVELOPER_UTILS_PVT;

/
